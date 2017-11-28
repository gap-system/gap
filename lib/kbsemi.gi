#############################################################################
##
#W  kbsemi.gi           GAP library         Isabel Araújo and Andrew Solomon
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains code for the Knuth-Bendix rewriting system for semigroups
##  and monoids.
##  

############################################################################
##
#R  IsKnuthBendixRewritingSystemRep(<obj>)
## 
##  reduced - is the system known to be reduced
##  fam - the family of elements of the fp smg/monoid
##
DeclareRepresentation("IsKnuthBendixRewritingSystemRep", 
  IsComponentObjectRep,
  ["family", "tzrules","pairs2check", "reduced", "ordering"]);


#############################################################################
##
#F  CreateKnuthBendixRewritingSystem(<fam>, <wordord>)
##  
##  <wordord> is a  reduction ordering 
##  (compatible with left and right multiplication).
##  
##  A Knuth Bendix rewriting system consists of a list of relations,
##  which we call rules, and a list of pairs of numbers (pairs2check).
##  Each lhs of a rule has to be greater than its rhs
##  (so when we apply a rule to a word, we are effectively reducing it - 
##  according to the ordering considered)
##  Each number in a pair of the list pairs2check
##  refers to one of the rules. A pair corresponds to a pair
##  of rules where confluence was not yet checked (according to
##  the Knuth Bendix algorithm).
##
##  Note that at this stage the kb rws obtained might not be reduced
##  (the same relation might even appear several times).
##  
InstallGlobalFunction(CreateKnuthBendixRewritingSystem,
function(fam, wordord)
local r,kbrws,rwsfam,relations_with_correct_order,CantorList,relwco,
      w,freefam;

  #changes the set of relations so that lhs is greater then rhs
  # and removes trivial rules (like u=u)
  relations_with_correct_order:=function(r,wordord)
    local i,q;

    q:=ShallowCopy(r);
    for i in [1..Length(q)] do
      if q[i][1]=q[i][2] then
        Unbind(q[i]);
      elif IsLessThanUnder(wordord,q[i][1],q[i][2]) then
        q[i]:=[q[i][2],q[i][1]];
      fi;
    od;
    return Set(q);
  end;

  # generates the list of all pairs (x,y) 
  # where x,y are distinct elements of the set [1..n]
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

  # check that fam is a family of elements of an fp smg or monoid
  if not (IsElementOfFpMonoidFamily(fam) or IsElementOfFpSemigroupFamily(fam))
  then
    Error(
      "Can only create a KB rewriting system for an fp semigroup or monoid");
  fi;

  # check the second argument is a reduction ordering 
  if not (IsOrdering(wordord) and IsReductionOrdering(wordord)) then
    Error("Second argument must be a reduction ordering");
  fi;
  
  if IsElementOfFpMonoidFamily(fam) then
    w:=CollectionsFamily(fam)!.wholeMonoid;
    r:=RelationsOfFpMonoid(w);
    freefam:=ElementsFamily(FamilyObj(FreeMonoidOfFpMonoid(w)));
  else
    w:=CollectionsFamily(fam)!.wholeSemigroup;
    r:=RelationsOfFpSemigroup(w);
    freefam:=ElementsFamily(FamilyObj(FreeSemigroupOfFpSemigroup(w)));
  fi;


  rwsfam := NewFamily("Family of Knuth-Bendix Rewriting systems", 
    IsKnuthBendixRewritingSystem);

  relwco:=relations_with_correct_order(r,wordord);

  kbrws := Objectify(NewType(rwsfam, 
    IsMutable and IsKnuthBendixRewritingSystem and 
    IsKnuthBendixRewritingSystemRep), 
    rec(family:= fam,
    reduced:=false,
    tzrules:=List(relwco,i->
     [LetterRepAssocWord(i[1]),LetterRepAssocWord(i[2])]),
    pairs2check:=CantorList(Length(r)),
    ordering:=wordord,
    freefam:=freefam));

  if HasLetterRepWordsLessFunc(wordord) then
    kbrws!.tzordering:=LetterRepWordsLessFunc(wordord);
  else
    kbrws!.tzordering:=false;
  fi;
  if IsElementOfFpMonoidFamily(fam) then
    SetIsBuiltFromMonoid(kbrws,true); 
  else
    SetIsBuiltFromSemigroup(kbrws,true);
  fi;

  return kbrws;

end);


#############################################################################
##
#A  ReduceRules(<RWS>)
##
##  Reduces the set of rules of a Knuth Bendix Rewriting System
##
InstallMethod(ReduceRules,
"for a Knuth Bendix rewriting system", true,
[ IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep and IsMutable ], 0, 
function(rws)
  local
        r,      # local copy of the rules
        v;      # a rule

  r := ShallowCopy(rws!.tzrules);
  rws!.tzrules:=[];
  rws!.pairs2check:=[];
  rws!.reduced := true;
  for v in r do
    AddRuleReduced(rws, v);
  od;
end);


#############################################################################
##
#O  AddRuleReduced(<RWS>, <tzrule>)
##
##  Add a rule to a rewriting system and, if the system is already
##  reduced it will remain reduced. Note, this also changes the pairs 
##  of rules to check.
##
##  given a pair v of words that have to be equal it checks whether that
##  happens or not and adjoin new rules if necessary. Then checks that we
##  still have something reduced and keep removing and adding rules, until
##  we have a reduced system where the given equality holds and everything
##  that was equal before is still equal. It returns the resulting rws
##
##  See Sims: "Computation with finitely presented groups".
##
InstallOtherMethod(AddRuleReduced,
"for a Knuth Bendix rewriting system and a rule", true,
[ IsKnuthBendixRewritingSystem and IsMutable and IsKnuthBendixRewritingSystemRep, IsList ], 0,
function(kbrws,v)

  local u,a,b,c,k,n,s,add_rule,remove_rule,fam;

    #given a Knuth Bendix Rewriting System, kbrws,
    #removes rule i of the set of rules of kbrws and    
    #modifies the list pairs2check in such a way that the previous indexes 
    #are modified so they correspond to same pairs as before
    remove_rule:=function(i,kbrws)
      local j,q,a,k,l;
  
      #first remove rule from the set of rules
      q:=kbrws!.tzrules{[1..i-1]};
      Append(q,kbrws!.tzrules{[i+1..Length(kbrws!.tzrules)]});
      kbrws!.tzrules:=q;

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
      Add(kbrws!.tzrules,u);
    
      #insert new pairs
      l:=kbrws!.pairs2check;
      n:=Length(kbrws!.tzrules);
      Add(l,[n,n]);
      for i in [1..n-1] do
        Append(l,[[i,n],[n,i]]);
      od;
  
      kbrws!.pairs2check:=l;
    end;

    #the stack is a list of pairs of words such that if two words form a pair 
    #they have to be equivalent, that is, they have to reduce to same word

    #TODO
    fam:=kbrws!.freefam;
    #we put the pair v in the stack
    s:=[v];

    #while the stack is non empty
    while not(IsEmpty(s)) do
    
      #pop the first rule from the stack
      #use rules available to reduce both sides of rule
      u:=s[1];
      s:=s{[2..Length(s)]};
      a:=ReduceLetterRepWordsRewSys(kbrws!.tzrules,u[1]);
      b:=ReduceLetterRepWordsRewSys(kbrws!.tzrules,u[2]);

      #if both sides reduce to different words
      #have to adjoin a new rule to the set of rules
      if not(a=b) then
	#TODO
	if kbrws!.tzordering=false then
	  c:=IsLessThanUnder(kbrws!.ordering,
	    AssocWordByLetterRep(fam,a),AssocWordByLetterRep(fam,b));
	else
	  c:=kbrws!.tzordering(a,b);
	fi;
        if c then
          c:=a; a:=b; b:=c;
        fi;
        add_rule([a,b],kbrws);
        kbrws!.reduced := false;
    
        #Now we have to check if by adjoining this rule
        #any of the other active ones become redudant

        k:=1; n:=Length(kbrws!.tzrules)-1;
        while k in [1..n] do
          
          #if lhs of rule k contains lhs of new rule
          #as a subword then we delete rule k
          #but add it to the stack, since it has to still hold

          if PositionSublist(kbrws!.tzrules[k][1],a,0)<>fail then
          #if PositionWord(kbrws!.rules[k][1],a,1)<>fail then
            Add(s,kbrws!.tzrules[k]);
            remove_rule(k,kbrws);
            n:=Length(kbrws!.tzrules)-1;
            k:=k-1;

          #else if rhs of rule k contains the new rule 
          #as a subword then we use the new rule
          #to irreduce that rhs
          elif PositionSublist(kbrws!.tzrules[k][2],a,0)<>fail then
          #elif PositionWord(kbrws!.rules[k][2],a,1)<>fail then
            kbrws!.tzrules[k][2]:=
              ReduceLetterRepWordsRewSys(kbrws!.tzrules, kbrws!.tzrules[k][2]);
          fi;
          k:=k+1;
      
        od;
      fi;
    od;
    kbrws!.reduced := true;
end);


#############################################################################
##
#M  MakeKnuthBendixRewritingSystemConfluent (<KBRWS>)
##  
##  RWS is a Knuth Bendix Rewriting System
##  This function takes a Knuth Bendix Rws (ie a set of rules
##  and a set of pairs which indicate the rules that
##  still have to be checked for confluence) and
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
InstallGlobalFunction( MakeKnuthBendixRewritingSystemConfluent,
function ( rws )
  Info( InfoKnuthBendix, 1, "MakeKnuthBendixRewritingSystemConfluent called" );
  # call the KB plugin
  KB_REW.MakeKnuthBendixRewritingSystemConfluent(rws);
  Info( InfoKnuthBendix, 1, "KB terminates with ",Length(rws!.tzrules),
       " rules" );
end);




#u and v are pairs of rules, kbrws is a kb RWS
#look for proper overlaps of lhs (lhs of u ends as lhs of v starts)
#Check confluence does not fail here, adjoining extra rules if necessary
BindGlobal("KBOverlaps",function(ui,vi,kbrws,p)
local u,v,m,k,a,c,lsu,lsv,lu,eq,i,j;

  u:=kbrws!.tzrules[ui]; v:=kbrws!.tzrules[vi];
  lsu:=u[1];
  lu:=Length(lsu);
  lsv:=v[1];

  #we are only going to consider proper overlaps
  #m:=Minimum(lu,Length(lsv))-1;
  m:=Length(lsv)-1;
  if lu<=m then
    m:=lu-1;
  fi;

  #any overlap will have length less than m
  k:=1;
  while k<=m do

    #if the last k letters of u[1] are the same as the 1st k letters of v[1]
    #they overlap
    #if Subword(u[1],Length(u[1])-k+1,Length(u[1]))=Subword(v[1],1,k) then
    eq:=true;
    i:=lu-k+1;
    j:=1;
    while eq and j<=k do
      eq:=lsu[i]=lsv[j];
      i:=i+1;
      j:=j+1;
    od;

    if eq then
      #a:=Subword(u[1],1,Length(u[1])-k)*v[2];
      #c:=u[2]*Subword(v[1],k+1,Length(v[1]));
      # we can't have cancellation
      a:=Concatenation(lsu{[1..lu-k]},v[2]);
      c:=Concatenation(u[2],lsv{[j..Length(lsv)]});
      #for guarantee confluence a=c has to hold

      #we change rws, if necessary, so a=c is verified
      if a <> c then
	# `AddRuleReduced' might affect the pairs. So first throw away the
	# `old' pairs
	kbrws!.pairs2check:=
	  kbrws!.pairs2check{[p+1..Length(kbrws!.pairs2check)]};
	p:=0; # no remaining pair was looked at
	AddRuleReduced(kbrws,[a,c]);
      fi;
    fi;
    k:=k+1;
  od;
  return p;
end);

############################################################
#
#            Function proper
#
###########################################################

BindGlobal("GKB_MakeKnuthBendixRewritingSystemConfluent",
function(kbrws)
local   pn,lp,rl,p,i;              #loop variables

  # kbrws!.reduced is true than it means that the system know it is
  # reduced. If it is false it might be reduced or not.
  if not kbrws!.reduced then
    ReduceRules(kbrws);
  fi;

  # we check all pairs of relations for overlaps. In most cases there will
  # be no overlaps. Therefore cally an inde xp in the pairs list and reduce
  # this list, only if `AddRules' gets called. This avoids creating a lot of
  # garbage lists.
  p:=1;
  rl:=50;
  pn:=Length(kbrws!.pairs2check);
  lp:=Length(kbrws!.pairs2check);
  while lp>=p do
    i:=kbrws!.pairs2check[p];
    p:=KBOverlaps(i[1],i[2],kbrws,p)+1;
    lp:=Length(kbrws!.pairs2check);
    if Length(kbrws!.tzrules)>rl 
      or AbsInt(lp-pn)>10000 then
      Info(InfoKnuthBendix,1,Length(kbrws!.tzrules)," rules, ",
			    lp," pairs");
      rl:=Length(kbrws!.tzrules)+50;
      pn:=lp;
    fi;
  od;
  kbrws!.pairs2check:=[];

end);
GAPKB_REW.MakeKnuthBendixRewritingSystemConfluent :=
  GKB_MakeKnuthBendixRewritingSystemConfluent;

if IsHPCGAP then
    MakeReadOnlyObj( GAPKB_REW );
fi;

#############################################################################
##
#M  MakeConfluent (<KB RWS>)
##
InstallMethod(MakeConfluent,
"for Knuth Bendix Rewriting System",
true,
[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep and IsMutable
and IsBuiltFromSemigroup],0,
function(kbrws)
  local rws;

  MakeKnuthBendixRewritingSystemConfluent(kbrws);
  # if the semigroup of the kbrws does not have a 
  # ReducedConfluentRws build one from kbrws and then store it in 
  # the semigroup
  if not HasReducedConfluentRewritingSystem(
           SemigroupOfRewritingSystem(kbrws)) then
   rws := ReducedConfluentRwsFromKbrwsNC(kbrws);
   SetReducedConfluentRewritingSystem(SemigroupOfRewritingSystem(kbrws),
         rws);
  fi;

end);

InstallMethod(MakeConfluent,
"for Knuth Bendix Rewriting System",
true,
[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep and IsMutable
and IsBuiltFromMonoid],0,
function(kbrws)
  local rws;

  MakeKnuthBendixRewritingSystemConfluent(kbrws);
  # if the monoid of the kbrws does not have a 
  # ReducedConfluentRws build one from kbrws and then store it in 
  # the monoid 
  if not HasReducedConfluentRewritingSystem(
            MonoidOfRewritingSystem(kbrws)) then
   rws := ReducedConfluentRwsFromKbrwsNC(kbrws);
   SetReducedConfluentRewritingSystem(MonoidOfRewritingSystem(kbrws),
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

    #TODO
    copy_of_kbrws := ShallowCopy(kbrws);
    copy_of_kbrws!.tzrules := [];
    Append(copy_of_kbrws!.tzrules,kbrws!.tzrules{[1..i-1]});
    Append(copy_of_kbrws!.tzrules,kbrws!.tzrules
            {[i+1..Length(kbrws!.tzrules)]});

    if ReduceLetterRepWordsRewSys(copy_of_kbrws!.tzrules,u[1])<>u[1] then
      return false;
    fi;
    if ReduceLetterRepWordsRewSys(copy_of_kbrws!.tzrules,u[2])<>u[2] then
       return false;
    fi;

  od;

  return true;

end);


#############################################################################
## 
#M  KnuthBendixRewritingSystem(<fam>)
#M  KnuthBendixRewritingSystem(<fam>,<wordord>)
#M  KnuthBendixRewritingSystem(<m>)
#M  KnuthBendixRewritingSystem(<m>,<wordord>)
#M  KnuthBendixRewritingSystem(<s>)
#M  KnuthBendixRewritingSystem(<s>,<wordord>)
##
##  creates the Knuth Bendix rewriting system for a family of
##  word of an fp monoid or semigroup 
##  using a supplied reduction ordering.
##
##  We also allow using a function giving the ordering 
##  to assure compatability with gap4.2
##  In that case the function <lteq> should be the less than or equal
##  function of a reduction ordering (no checking is performed)
##
InstallMethod(KnuthBendixRewritingSystem,
"for a family of words of an fp semigroup and on ordering on that family", true,
[IsElementOfFpSemigroupFamily, IsOrdering], 0,
function(fam,wordord)
  local freefam,kbrws;

  freefam := ElementsFamily(FamilyObj(fam!.freeSemigroup));
  # the ordering has to be an ordering on the family freefam
  if not freefam=FamilyForOrdering(wordord) then
    Error("family <fam> and ordering <wordord> are not compatible");
  fi;

  kbrws := CreateKnuthBendixRewritingSystem(fam,wordord);

  return kbrws; 
end);

InstallMethod(KnuthBendixRewritingSystem,
"for a family of words of an fp monoid and on ordering on that family", true,
[IsElementOfFpMonoidFamily, IsOrdering], 0,
function(fam,wordord)
  local freefam,kbrws;

  freefam := ElementsFamily(FamilyObj(fam!.freeMonoid));
  # the ordering has to be an ordering on the family fam
  if not freefam=FamilyForOrdering(wordord) then
    Error("family <fam> and ordering <wordord> are not compatible");
  fi;

  kbrws := CreateKnuthBendixRewritingSystem(fam,wordord);

  return kbrws; 
end);

InstallOtherMethod(KnuthBendixRewritingSystem,
"for an fp semigroup and an order on the family of words of the underlying free semigroup", true,
[IsFpSemigroup, IsOrdering], 0,
function(s,wordord)
  local kbrws,fam;

  fam := ElementsFamily(FamilyObj(s));
  return KnuthBendixRewritingSystem(fam,wordord); 
end);

InstallOtherMethod(KnuthBendixRewritingSystem,
"for an fp monoid and an order on the family of words of the underlying free monoid", true,
[IsFpMonoid, IsOrdering], 0,
function(m,wordord)
  local kbrws,fam;

  fam := ElementsFamily(FamilyObj(m));
  return KnuthBendixRewritingSystem(fam,wordord); 
end);

InstallOtherMethod(KnuthBendixRewritingSystem,
"for an fp semigroup and a function", true,
[IsFpSemigroup, IsFunction], 0,
function(s,lt)
  local wordord,fam;

  wordord := OrderingByLessThanOrEqualFunctionNC(ElementsFamily
	      (FamilyObj(FreeSemigroupOfFpSemigroup(s))),lt,[IsReductionOrdering]);
  fam := ElementsFamily(FamilyObj(s));
  return KnuthBendixRewritingSystem(fam,wordord);
end);

InstallOtherMethod(KnuthBendixRewritingSystem,
"for an fp monoid and a function", true,
[IsFpMonoid, IsFunction], 0,
function(m,lt)
  local wordord,fam;

  wordord := OrderingByLessThanOrEqualFunctionNC(ElementsFamily
	      (FamilyObj(FreeMonoidOfFpMonoid(m))),lt,[IsReductionOrdering]);
  fam := ElementsFamily(FamilyObj(m));
  return KnuthBendixRewritingSystem(fam,wordord);
end);


#############################################################################
##  
#M  KnuthBendixRewritingSystem(<m>) 
## 
##  Create the a KB rewriting system for the fp monoid <m> using the
##  shortlex order.
## 
InstallOtherMethod(KnuthBendixRewritingSystem,
"for an fp monoid", true, 
[IsFpMonoid], 0,
function(m)
  return KnuthBendixRewritingSystem(m,
          ShortLexOrdering(ElementsFamily(FamilyObj(
          FreeMonoidOfFpMonoid(m)))));
end);

InstallOtherMethod(KnuthBendixRewritingSystem,
"for an fp semigroup", true, 
[IsFpSemigroup], 0,
function(s)
  return KnuthBendixRewritingSystem(s,
          ShortLexOrdering(ElementsFamily(FamilyObj(
          FreeSemigroupOfFpSemigroup(s)))));
end);


#############################################################################
##  
#M  MonoidOfRewritingSystem(<KB RWS>) 
## 
##  for a Knuth Bendix Rewriting System
##  returns the monoid of the rewriting system
##
InstallMethod(MonoidOfRewritingSystem, 
"for a Knuth Bendix rewriting system", true, 
[IsRewritingSystem and IsBuiltFromMonoid], 0,
function(kbrws)
  local fam;
    
  fam := FamilyForRewritingSystem(kbrws);
  return CollectionsFamily(fam)!.wholeMonoid;
end);

#############################################################################
## 
#M  SemigroupOfRewritingSystem(<KB RWS>)
##
##  for a Knuth Bendix Rewriting System
##  returns the semigroup of the rewriting system
##
InstallMethod(SemigroupOfRewritingSystem,
"for a Knuth Bendix rewriting system", true,
[IsRewritingSystem and IsBuiltFromSemigroup], 0,
function(kbrws)
  local fam;
    
  fam := FamilyForRewritingSystem(kbrws);
  return CollectionsFamily(fam)!.wholeSemigroup;
end);


#############################################################################
##
#M  Rules(<KB RWS>)
##
##  for a Knuth Bendix Rewriting System
##  returns the set of rules of the rewriting system
##
InstallMethod(Rules,
"for a Knuth Bendix rewriting system", true,
[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep], 0,
function(kbrws)
local fam;
  fam:=kbrws!.freefam;
  return List(kbrws!.tzrules,
    i->[AssocWordByLetterRep(fam,i[1]),AssocWordByLetterRep(fam,i[2])]);
end);

#############################################################################
##
#M  TzRules(<KB RWS>)
##
##  for a Knuth Bendix Rewriting System
##  returns the set of rules of the rewriting system in compact form
##
InstallMethod(TzRules,"for a Knuth Bendix rewriting system", true,
  [IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep], 0,
function(kbrws)
local fam;
  return List(kbrws!.tzrules,i->[ShallowCopy(i[1]),ShallowCopy(i[2])]);
end);


#############################################################################
##
#A  OrderingOfRewritingSystem(<rws>)
##
##  for a rewriting system rws
##  returns the order used by the rewriting system
##  
InstallMethod(OrderingOfRewritingSystem,
"for a Knuth Bendix rewriting system", true,
[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep], 0,
function(kbrws)
  return kbrws!.ordering;
end);


#############################################################################
##
#A  FamilyForRewritingSystem(<rws>)
##
##  for a rewriting system rws
## 
InstallMethod(FamilyForRewritingSystem,
"for a Knuth Bendix rewriting system", true,
[IsKnuthBendixRewritingSystem and IsKnuthBendixRewritingSystemRep], 0,
function(kbrws)
  return kbrws!.family;
end);


############################################################################
##
#A  ViewObj(<KB RWS>)
##
##
InstallMethod(ViewObj, "for a Knuth Bendix rewriting system", true,
[IsKnuthBendixRewritingSystem and IsBuiltFromMonoid], 0, 
function(kbrws) 
  Print("Knuth Bendix Rewriting System for "); 
  Print(MonoidOfRewritingSystem(kbrws));
  Print(" with rules \n");
  Print(Rules(kbrws));
end);

InstallMethod(ViewObj, "for a Knuth Bendix rewriting system", true,
[IsKnuthBendixRewritingSystem and IsBuiltFromSemigroup], 0, 
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
                  family := kbrws!.family,
                  reduced := false,
                  tzrules:= StructuralCopy(kbrws!.tzrules),
                  pairs2check:= [],
                  ordering :=kbrws!.ordering)));

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
    rws1!.family=rws2!.family
    and
    IsSubset(rws1!.tzrules,rws2!.tzrules)
    and
    IsSubset(rws2!.tzrules,rws1!.tzrules)
    and 
    rws1!.ordering=rws2!.ordering;
  end);


#############################################################################
##
#E

