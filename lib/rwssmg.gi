#############################################################################
##
#W  rwssmg.gi           GAP library                             Isabel Araujo
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for semigroups defined by rws.
##
Revision.rwssmg_gi :=
    "@(#)$Id$";

############################################################################
##
#A  ReducedConfluentRewritingSystem( <S>)
##
##  returns a reduced confluent rewriting system of the fp semigroup
##  <S> with respect to the shortlex ordering on words.
##
InstallMethod(ReducedConfluentRewritingSystem,
"for an fp semigroup", true,
[IsFpSemigroup], 0,
function(S)
  return ReducedConfluentRewritingSystem(S,
								IsShortLexLessThanOrEqual);
end);

############################################################################
##
#A  ReducedConfluentRewritingSystemFromKbrwsNC( <kbrws>)
##
##  if we have a knuth bendix rws that we know is reduced and
##  confluent we can certainly transform it into a reduced
##  confluent rewriting system
##  This performs no checking!!!
##
BindGlobal("ReducedConfluentRewritingSystemFromKbrwsNC",
function(kbrws)
  local fam,rws;

  fam := NewFamily("Family of reduced confluent rewriting systems",
          IsReducedConfluentRewritingSystem);
  rws:= Objectify(NewType(fam,IsAttributeStoringRep and
          IsReducedConfluentRewritingSystem and
          IsBuiltFromSemigroup), rec());
  SetRules(rws,StructuralCopy(Rules(kbrws)));
  SetIsReduced(rws,true);
  SetIsConfluent(rws,true);
  SetSemigroupOfRewritingSystem(rws,
    SemigroupOfRewritingSystem(kbrws));
  SetOrderOfRewritingSystem(rws,OrderOfRewritingSystem(kbrws));

  return rws;

end);

############################################################################
##
#A  ReducedConfluentRewritingSystem( <S>,<lteq>)
##
##  returns a reduced confluent rewriting system of the fp semigroup
##  <S> with respect to a supplied reduction order.
##  lteq(<a>,<b>) returns true iff <a> <= <b> in the order corresponding
##  to lteq.
##
InstallOtherMethod(ReducedConfluentRewritingSystem,
"for an fp semigroup and an order on the underlying free semigroup", true,
[IsFpSemigroup, IsFunction], 0,
function(S,lteq)
  local kbrws, rws;

	# we start by building a knuth bendix rws for the semigroup
	kbrws := KnuthBendixRewritingSystem(S,lteq);
	# then we make it confleunt (and reduced)
	MakeConfluent(kbrws);

	# now we are sure we have a Knuth Bendix rws which is both confluent and 
	# reduced so we make into a ReducedConfluentRewritingSystem
	rws := ReducedConfluentRewritingSystemFromKbrwsNC(kbrws);

	# we now set the attribute
  SetReducedConfluentRewritingSystem(S, rws);

  return rws;
end);



#############################################################################
##
#M  IsConfluent(<RWS>)
##
##  checks confluence of a rewriting system built from a semigroup
##
InstallMethod(IsConfluent,
"for a semigroup rewriting system", true,
[IsRewritingSystem and IsBuiltFromSemigroup], 0,
function(rws)
    local p,r,i,b,l,u,v,w,length_of_longest_common_prefix;
  ##########################################################
  # it returns the length of the longest common prefix of the words b and r
  # or 0 if they don't have a common prefix
  length_of_longest_common_prefix:= function(b,r)
    local l;

    #it runs through the words until finding a different letter
    for l in [1..Minimum(Length(r),Length(b))] do

      if Subword(b,l,l)<>Subword(r,l,l) then
        # if l=1 it means that the words b and r don't have a common prefix
        if l=1 then
          return 0;
        else
          # otherwise they are equal up to letter l-1
          return l-1;
        fi;
      fi;
    od;

    #here we know that the smallest word is a subword of the other
    #Hence the smallest word is a prefix of the other
    #and its length is l
    return l;

  end;
 
  #####################
  # the proper function
  #####################
  for p in Rules(rws) do
    for r in Rules(rws) do

      for i in [1..Length(p[1])] do
        # b is a sufix of p[1]
        b := Subword(p[1],Length(p[1])-i+1,Length(p[1]));

        l := length_of_longest_common_prefix(b,r[1]);

        # b and r overlap iff |b|=l or |r|=l
        # if |b|=l it means that p[1] and r[1] overlap
        # if |r|=l it means that r[1] is a subword of p[1]
        # if one of these cases occur then confluence might fail

        if Length(b)=l or Length(r[1])=l then

          # let u be the longest common prefix of b and r[1]
          u := Subword(b,1,l);

          # Now, if we have b=ud and r=ue
          # either d or e is empty
          # and if p[1]=ab then to check confluence we have to
          # check the equality of the reduced forms of
          # the words v=ar[2]d and w=p[2]e

          # so in p[1] we substitute the first occurence of u in b by r[2]
          v := SubstitutedWord(p[1],u,Length(p[1])-i+1,r[2]);
          # and in r[1] we subsitute the first occurence of u by p[2]
          w := SubstitutedWord(r[1],u,1,p[2]);
          # the reduced form of v and w must be equal if the rws is confluent
          if ReducedForm(rws,v)<>ReducedForm(rws,w) then
            return false;
          fi;
        fi;
      od;
    od;
  od;

  # at this stage we know that the rws is confluent
  return true;

end);

############################################################################
##
#A  PrintObj(<rws>)
##
##
InstallMethod(ViewObj, "for a semigroup rewriting system", true,
[IsRewritingSystem and IsBuiltFromSemigroup], 0,
function(rws)
  Print("Rewriting System for ");
  Print(SemigroupOfRewritingSystem(rws));
  Print(" with rules \n");
  Print(Rules(rws));
end);

#############################################################################
##
#F  ReduceWordUsingRewritingSystem (<RWS>,<w>)
##
##  w is a word of free semigroup, RWS is a Rewriting System
##  Given a rewriting system and a word in the free semigroup,
##  uses the rewriting system to reduce the word and return
##  a 'minimal' one.
##
InstallGlobalFunction(ReduceWordUsingRewritingSystem,
function(rws,w)
  local i,k,n,v,rules;

  #check that rws is Rewriting System
  if not IsRewritingSystem(rws) or not(IsBuiltFromSemigroup(rws)) then
    Error("Can only reduce word given Rewriting System built from a semigroup");
  elif not IsWord(w) then
    Error("Can only reduce word from fp semigroup");
  fi;

  #given a word we look for left sides of relations and use such relations
  #to transform the word into a irreducible word

  n:=Length(w);
	rules:=Rules(rws);

  #we look at the prefixes of the given word
  i:=1;
  while i in [1..n] do

    #v is the prefix of w, consisting of the first i letters of e
    v:=Subword(w,1,i);
    #run through the relations of the set of relations RWS
    #and use them to reduce w
    k:=1;
    while k in [1..Length(rules)] do

      #look for lhs of relations which are sufixes of v
      #ie, lhs of relations which are subwords of w
      if Length(rules[k][1])<=Length(v) then
        if rules[k][1]=Subword(v,Length(v)-Length(rules[k][1])+1,Length(v)) then

          #when finding a lhs which is a sufix of v, a rule
          #can be applied to the w to reduce it

          #so we substitute the occurence of the lhs
         #of the rule in w, by its rhs
          w:=SubstitutedWord(w,i-Length(rules[k][1])+1,i,rules[k][2]);

          #we have a new word, w, and hence different prefixes
          #so we go back to the last one we examined
          i:=i-Length(rules[k][1]);

          #we also altered the length of the word z
          n:=Length(w);

          #and we want to go to the outer loop
          k:=Length(rules);
        fi;
      fi;

      #if we haven't applied any relation yet, look at next relation
      k:=k+1;
    od;

    #avance a letter to look to the 'next prefix' of z
    i:=i+1;
  od;

  return w;

end);


#############################################################################
##
#M  ReducedForm(<RWS>, <e>)
##
InstallMethod(ReducedForm,
"for a semigroup rewriting system and a word on the underlying free semigroup", true,
[IsRewritingSystem and IsBuiltFromSemigroup, IsAssocWord], 0,
function(rws,w)

  if not (w in FreeSemigroupOfRewritingSystem(rws)) then
      Error( Concatenation(
              "Usage: ReducedForm(<rws>, <w>)", "- <w> in FreeSemigroupRewritingSystem(<rws>)") );;
  fi;
  return ReduceWordUsingRewritingSystem(rws,w);

end);


#############################################################################
##
#M  FreeSemigroupOfRewritingSystem(<RWS>)
##
##
InstallMethod(FreeSemigroupOfRewritingSystem,
"for a semigroup rewriting system", true,
[IsRewritingSystem and IsBuiltFromSemigroup], 0,
function(rws)
  return FreeSemigroupOfFpSemigroup(
    SemigroupOfRewritingSystem(rws));
end);


#############################################################################
##
#E

