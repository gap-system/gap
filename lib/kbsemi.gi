#############################################################################
##
#W  kbsemi.gi           GAP library         Isabel Araujo and Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains code for the Knuth-Bendix rewriting system for semigroups
##

Revision.kbsemi_gi :=
    "@(#)$Id$";


############################################################################
##
#R  IsKnuthBendixRewritingSystemRep(<obj>)
## 
##  reduced - is the system known to be reduced
##  lessthanorequal(a, b) - is <a> less than or equal<b> in the word order
##
DeclareRepresentation("IsKnuthBendixRewritingSystemRep", 
IsComponentObjectRep,["semigroup", "rules", "pairs2check", "reduced", 
"lessthanorequal"]);


#############################################################################
##
#F  CreateKnuthBendixRewritingSystemOfFpSemigroup (<S>, <lt>)
##  
##  It is assumed that <lt> is a  reduction ordering 
##  (compatible with left and right multiplication).
##  
##  A Knuth Bendix rewriting system consists of a list of relations,
##	which we call rules, and a list of pairs of numbers (pairs2check).
##  Each lhs of a rule has to be greater than its rhs
##  (so when we apply a rule to a word, we are effectively reducing it - 
##  according to the ordering considered)
##	Each number in a pair of the list pairs2check
##	refers to one of the rules. A pair corresponds to a pair
##	of rules where confluence was not yet checked (according to
##	the Knuth Bendix algorithm).
##
##	Note that at this stage the kb rws obtained might not be reduced
##	(the same relation might even appear several times).
##	
InstallGlobalFunction(CreateKnuthBendixRewritingSystemOfFpSemigroup,
function(s, wordlt)
 	local r,kbrws,fam,relations_with_correct_order,CantorList;

	#changes the set of relations so that lhs is greater then rhs
	# and removes trivial rules (like u=u)
	relations_with_correct_order:=function(r)
		local i,q;

		q:=ShallowCopy(r);
		for i in [1..Length(q)] do
			if wordlt(q[i][1],q[i][2]) then
				q[i]:=[q[i][2],q[i][1]];
			fi;
			if q[i][1]=q[i][2] then
        Unbind(q[i]);
      fi;
		od;
		return Set(q);
	end;

	#generates the list of all pairs (x,y) where x,y are in [1..n]
	CantorList:=function(n)
     local i,j,l;
     l:=[];
     for i in [1..n] do
          Add(l,[i,i]);
          for j in [1..i-1] do
               Append(l,[[i,j],[j,i]]);
          od;
     od;
     return(l);
	end;

	#check that it is an fp-semigroup.
	if not IsFpSemigroup(s) then
		Error("Can only create a KB rewriting system for an fp-semigroup");
	fi;

	if not IsFunction(wordlt)then
		Error("Second argument must be a reduction ordering function");
	fi;
	
	r:=RelationsOfFpSemigroup(s);

	fam := NewFamily("Family of Knuth-Bendix Rewriting systems", 
		IsKnuthBendixRewritingSystem);

	kbrws := Objectify(NewType(fam, 
		IsMutable and IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep), 
		rec(semigroup:= s,
		reduced:=false,
		rules:=relations_with_correct_order(r),
		pairs2check:=CantorList(Length(r)),
		lessthanorequal:=wordlt));

	#ReduceRules(kbrws);

	return kbrws;

end);


#############################################################################
##
#A  ReduceRules(<RWS>)
##
##	Reduces the set of rules of a Knuth Nebdix Rewriting System
##
InstallMethod(ReduceRules,
"for a Knuth Bendix rewriting system", true,
[ IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep and IsMutable ], 0, 
function(rws)
	local
				r, 			# local copy of the rules
				v;			# a rule

	r := ShallowCopy(rws!.rules);
	rws!.rules:= [];
	rws!.pairs2check:=[];
	rws!.reduced := true;
	for v in r do
		AddRuleReduced(rws, v);
	od;
end);


#############################################################################
##
#O  AddRuleReduced(<RWS>, <rule>)
##
##  Add a rule to a rewriting system and, if the system is already
##  reduced it will remain reduced. Note, this also changes the pairs 
##  of rules to check.
##
##  given a pair v of words that have to be equal it checks whether that happens or not
##  and adjoin new rules if necessary. Then checks that we still have something reduced
##  and keep removing and adding rules, until we have a reduced
##  system where the given equality holds and everything that was equal before
##  is still equal. It returns the resulting rws
##  See Sims: "Computation with finitely presented groups".
##
InstallMethod(AddRuleReduced,
"for a Knuth Bendix rewriting system and a rule", true,
[ IsKnuthBendixRewritingSystem and IsMutable and IsKnuthBendixRewritingSystemRep, IsHomogeneousList ], 0,
function(kbrws,v)

	local u,a,b,c,k,n,s,add_rule,remove_rule;

		#given a Knuth Bendix Rewriting System, kbrws,
		#removes rule i of the set of rules of kbrws and		
		#modifies the list pairs2check in such a way that the previous indexes 
		#are modified so they correspond to same pairs as before
		remove_rule:=function(i,kbrws)
			local j,q,a,k,l;
	
			#first remove rule from the set of rules
			q:=kbrws!.rules{[1..i-1]};
			Append(q,kbrws!.rules{[i+1..Length(kbrws!.rules)]});

			#delete pairs pairs of indexes that include i
			#and change ocurrences of indexes k greater than i in the 
			#list of pairs and change them to k-1
			#So we'll construct a new list with the right pairs
			l:=[];
			for j in [1..Length(kbrws!.pairs2check)] do
				if kbrws!.pairs2check[j][1]<>i and kbrws!.pairs2check[j][2]<>i then
					a:=kbrws!.pairs2check[j];
					for k in [1..2] do
						if kbrws!.pairs2check[j][k]>i then
							a[k]:=kbrws!.pairs2check[j][k]-1;
						fi;
					od;
					Add(l,a);
				fi;
			od;
			kbrws!.pairs2check:=l;
			kbrws!.rules:=q;
			return kbrws;
		end;


		#given a Knuth Bendix Rewriting System this function returns it
		#with the given extra rule adjoined to the set of rules
		#and the necessary pairs adjoined to pairs2check 
		#(the pairs that we have to put in pairs2check correspond to the
		#new rule together with all the ones that were in the set of rules
		#previously)
		add_rule:=function(u,kbrws)
			local q,l,i,n;

			#insert rule 
			q:=kbrws!.rules;
			Add(q,u);
		
			#insert new pairs
			l:=kbrws!.pairs2check;
			n:=Length(q);
			Add(l,[n,n]);
			for i in [1..n-1] do
        Append(l,[[i,n],[n,i]]);
			od;
	
			kbrws!.rules:=q;
			kbrws!.pairs2check:=l;
			return kbrws;
		end;


		#the stack is a list of pairs of words such that if two words form a pair 
		#they have to be equivalent, that is, they have to reduce to same word

		#we put the pair v in the stack
		s:=[v];

		#while the stack is non empty
		while not(IsEmpty(s)) do
		
			#pop the first rule from the stack
			#use rules available to irreduce both sides of rule
			u:=s[1];
			s:=s{[2..Length(s)]};
			a:=ReducedForm(kbrws,u[1]);
			b:=ReducedForm(kbrws,u[2]);

			#if both sides reduce to different words
			#have to adjoin a new rule to the set of rules
			if not(a=b) then
				if kbrws!.lessthanorequal(a,b) then
					c:=a; a:=b; b:=c;
				fi;
				kbrws:=add_rule([a,b],kbrws);
				kbrws!.reduced := false;
		
				#Now we have to check if by adjoining this rule
				#any of the other active ones become redudant

				k:=1; n:=Length(kbrws!.rules)-1;
				while k in [1..n] do
					
					#if lhs of rule k contains lhs of new rule
					#as a subword then we delete rule k
					#but add it to the stack, since it has to still hold

					if PositionWord(kbrws!.rules[k][1],a,1)<>fail then
						Add(s,kbrws!.rules[k]);
						kbrws:=remove_rule(k,kbrws);
						n:=Length(kbrws!.rules)-1;
						k:=k-1;

					#else if rhs of rule k contains the new rule 
					#as a subword then we use the new rule
					#to irreduce that rhs
          elif PositionWord(kbrws!.rules[k][2],a,1)<>fail then
						kbrws!.rules[k][2]:=
							ReducedForm(kbrws, kbrws!.rules[k][2]);
					fi;
					k:=k+1;
			
				od;
			fi;
		od;
		kbrws!.reduced := true;
end);


#############################################################################
##
#F  MakeKnuthBendixRewritingSystemConfluent (<KBRWS>)
##  
##  RWS is a Knuth Bendix Rewriting System
##  This function takes a Knuth Bendix Rws (ie a set of rules
##	and a set of pairs which indicate the rules that
##	still have to be checked for confluence) and
##  applies the Knuth Bendix algorithm for strigs to it to get a reduced
##  confluent rewriting system.
## 
##  Confluence means the following: if w is a word which can be reduced
##  using two different rules, say w->u and w->v, then the irreducible forms
##  of u and v are the same word.
##
##  To construct a rws from a set of rules consists of adjoining new
##  rules if necessary to be sure the confluence property holds
##
##  This implementation of Knuth-bendix also guarantees that we will
##  obtain a reduced rws, meaning that there are not redundant rules
##
##  Note (see Sims, `Computation with finitely presented groups', 1994)
##  a reduced confluent rewriting system for a semigroup with a given set of 
##  generators is unique, under a given ordering.
## 
InstallGlobalFunction(MakeKnuthBendixRewritingSystemConfluent,
function(kbrws)
	
	local 	i,j,							#loop variables
					u,v,							#rules
					overlaps;					#function that looks for overlaps of rules

	#u and v are pairs of rules, kbrws is a kb RWS
	#look for proper overlaps of lhs (lhs of u ends as lhs of v starts)
	#Check confluence does not fail here, adjoining extra rules if necessary
	overlaps:=function(u,v,kbrws)

		local m,k,a,c;

		#we are only going to consider proper overlaps
		m:=Minimum(Length(u[1]),Length(v[1]))-1;
	
		#any overlap will have length less than m
		k:=1;
		while k<=m do

			#if the last k letters of u[1] are the same as the 1st k letters of v[1]
			#they overlap
			if Subword(u[1],Length(u[1])-k+1,Length(u[1]))=Subword(v[1],1,k) then
	
				a:=Subword(u[1],1,Length(u[1])-k)*v[2];
				c:=u[2]*Subword(v[1],k+1,Length(v[1]));
				#for guarantee confluence a=c has to hold

				#we change rws, if necessary, so a=c is verified
				if a <> c then
					AddRuleReduced(kbrws, [a,c]);;
				fi;
			fi;
			k:=k+1;
		od;
		return kbrws;
	end;

	############################################################
	#
	#            Function proper
	#
	###########################################################

	#check that kbrws is a Knuth Bendix Rewriting System
	if not IsKnuthBendixRewritingSystem(kbrws) then
		Error("Knuth Bendix Rewriting System is required");
	fi;

	# kbrws!.reduced is true than it means that the system know it is
	# reduced. If it is false it might be reduced or not.
	if not kbrws!.reduced then
		ReduceRules(kbrws);
	fi;

	
	i:=1;j:=1;

	#we check all pairs of relations for overlaps
	while not(IsEmpty(kbrws!.pairs2check)) do
		i:=kbrws!.pairs2check[1][1];j:=kbrws!.pairs2check[1][2];
		u:=kbrws!.rules[i]; v:=kbrws!.rules[j];

		kbrws!.pairs2check:=kbrws!.pairs2check{[2..Length(kbrws!.pairs2check)]};
		kbrws:=overlaps(u,v,kbrws);;
	od;

end);


#############################################################################
##
#M  MakeConfluent (<KB RWS>)
##
InstallMethod(MakeConfluent,
"for Knuth Bendix Rewriting System",
true,[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep and IsMutable],0,
function(kbrws)
	local rws;

  MakeKnuthBendixRewritingSystemConfluent(kbrws);
  # if the semigroup of the kbrws does not have a ReducedConfluentRws 
	# build one from kbrws and then store it in the semigroup  
  if not HasReducedConfluentRewritingSystem(
            SemigroupOfRewritingSystem(kbrws)) then
		rws := ReducedConfluentRewritingSystemFromKbrwsNC(kbrws);
		SetReducedConfluentRewritingSystem(SemigroupOfRewritingSystem(kbrws),
					rws);
  fi;

end);


#############################################################################
##
#P  IsReduced( <rws> )
##
##  True iff the rws is reduced
##  A rws is reduced if for each (u,v) in rws both u and v are
##  irreducible with respect to rws-{(u,v)}
##
InstallMethod(IsReduced,
"for a Knuth Bendix rewriting system", true,
[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep and IsMutable], 0,
function(kbrws)
  local i,copy_of_kbrws,u;

	# if the rws already knows it is reduced return true
  if kbrws!.reduced then return true; fi;

  for i in [1..Length(Rules(kbrws))] do

    u := Rules(kbrws)[i];

    copy_of_kbrws := ShallowCopy(kbrws);
    copy_of_kbrws!.rules := [];
    Append(copy_of_kbrws!.rules,Rules(kbrws){[1..i-1]});
    Append(copy_of_kbrws!.rules,Rules(kbrws)
            {[i+1..Length(Rules(kbrws))]});

    if ReducedForm(copy_of_kbrws,u[1])<>u[1] then
      return false;
    fi;
    if ReducedForm(copy_of_kbrws,u[2])<>u[2] then
       return false;
    fi;

  od;

  return true;

end);


#############################################################################
## 
#M  KnuthBendixRewritingSystem(<S>,<lteq>)
##
##  creates the Knuth Bendix rewriting system for the semigroup S
##  using a supplied reduction order.
##	lteq(<a>,<b>) returns true iff <a> <= <b> in the order corresponding
##  to lteq.	
##
InstallMethod(KnuthBendixRewritingSystem,
"for an fp semigroup and an order on the words of the underlying free semigroup", true,
[IsFpSemigroup, IsFunction], 0,
function(S,lt)
	local kbrws;

	kbrws := CreateKnuthBendixRewritingSystemOfFpSemigroup(S,lt);
  return kbrws; 
end);


#############################################################################
##  
#M  KnuthBendixRewritingSystem(<S>) 
## 
##  Create the a KB rewriting system for the semigroup S using the
##  shortlex order.
## 
InstallOtherMethod(KnuthBendixRewritingSystem,
"for an fp semigroup", true, 
[IsFpSemigroup], 0,
function(S)
	return CreateKnuthBendixRewritingSystemOfFpSemigroup(S,
					IsShortLexLessThanOrEqual);
end);

InstallTrueMethod(IsBuiltFromSemigroup,IsKnuthBendixRewritingSystem);


#############################################################################
##  
#M  SemigroupOfRewritingSystem(<KB RWS>) 
## 
##	for a Knuth Bendix Rewriting System
##  returns the semigroup of the rewriting system
##
InstallMethod(SemigroupOfRewritingSystem, 
"for a Knuth Bendix rewriting system", true, 
[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep], 0,
function(kbrws)
  return kbrws!.("semigroup");
end);


#############################################################################
##
#M  Rules(<KB RWS>)
##
##	for a Knuth Bendix Rewriting System
##	returns the set of rules of the rewriting system
##
InstallMethod(Rules,
"for a Knuth Bendix rewriting system", true,
[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep], 0,
function(kbrws)
  return kbrws!.rules;
end);


#############################################################################
##
#A  OrderOfRewritingSystem(<rws>)
##
##  for a rewriting system rws
##  returns the order used by the rewriting system
##  
InstallMethod(OrderOfRewritingSystem,
"for a Knuth Bendix rewriting system", true,
[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep], 0,
function(kbrws)
	return kbrws!.lessthanorequal;
end);


############################################################################
##
#A  ViewObj(<KB RWS>)
##
##
InstallMethod(ViewObj, "for a Knuth Bendix rewriting system", true,
[IsKnuthBendixRewritingSystem], 0, 
function(kbrws) 
	Print("Knuth Bendix Rewriting System for "); 
	Print(SemigroupOfRewritingSystem(kbrws));
	Print(" with rules \n");
	Print(Rules(kbrws));
end);


###############################################################################
##
#M ShallowCopy
##
InstallMethod( ShallowCopy, 
	"for a Knuth Bendix rewriting system",
	true,
	[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep], 0,
	kbrws -> Objectify( Subtype( TypeObj(kbrws), IsMutable ),
							rec(
									semigroup := SemigroupOfRewritingSystem(kbrws),
									reduced := false,
									rules:= StructuralCopy( Rules(kbrws) ),
									pairs2check:= [],
									lessthanorequal:=kbrws!.lessthanorequal)));

###############################################################################
##
#M \=
##
InstallMethod( \=, 
	"for two Knuth-Bendix rewriting systems",
	IsIdenticalObj,
	[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep,
	IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep],0,	
	function(rws1,rws2)
	return 
		SemigroupOfRewritingSystem(rws1)=SemigroupOfRewritingSystem(rws2)
		and
		IsSubset(Rules(rws1),Rules(rws2))
		and
		IsSubset(Rules(rws2),Rules(rws1))
		and 
		rws1!.lessthanorequal=rws2!.lessthanorequal ;
	end);


#############################################################################
##
#E

