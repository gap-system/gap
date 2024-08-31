#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Isabel Araújo and Andrew Solomon.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains code for the Knuth-Bendix rewriting system for semigroups
##  and monoids.
##

InstallGlobalFunction(EmptyKBDAG,function(genids)
local offset,deadend;
  if Length(genids)=0 then
    offset:=0;
    deadend:=[];
  else
    offset:=Minimum(genids);
    deadend:=ListWithIdenticalEntries(Maximum(genids)-offset+1,fail);
  fi;
  # index shifting so we always start at 1
  if offset>0 then offset:=offset-1;
  else offset:=1-offset;fi;
  return rec(IsKBDAG:=true,
    genids:=genids,
    offset:=offset,
    deadend:=deadend,
    backpoint:=[],
    dag:=ShallowCopy(deadend));
end);

InstallGlobalFunction(AddRuleKBDAG,function(d,left,idx)
local offset,node,j,a;
  offset:=d.offset;
  node:=d.dag;
  for j in [1..Length(left)] do
    a:=left[j]+offset;
    if node[a]=fail then
      if j=Length(left) then
        # store index position
        d.backpoint[idx]:=[node,a];
        node[a]:=idx;
        return true;
      else
        node[a]:=ShallowCopy(d.deadend); # at least one symbol more
        node:=node[a];
      fi;
    elif IsList(node[a]) then
      if j<Length(left) then
        node:=node[a]; # go to next letter
      else
        # rule would reduce existing LHS
        return fail;
      fi;
    else
      #LHS could have been reduced with existing rules
      return false;
    fi;
  od;
  return true;
end);

InstallGlobalFunction(DeleteRuleKBDAG, function(d,left,idx)
local backpoint,i,a,node,offset;
  backpoint:=d.backpoint;
  backpoint[idx][1][backpoint[idx][2]]:=fail; # #rule indicator is gone
  for i in [idx+1..Length(backpoint)] do
    a:=backpoint[i][2];
#if backpoint[i][1][a]<>i then Error("poss");fi;
    backpoint[i][1][a]:=backpoint[i][1][a]-1; # decrease index numbers
    backpoint[i-1]:=backpoint[i]; # and correct back pointers
  od;
  Remove(backpoint);
  # now trace through the word and kill nodes that are all fail

  offset:=d.offset;
  a:=Length(left)-2;
  while a>-1 do
    node:=d.dag;
    for i in [1..a] do
      node:=node[left[i]+offset];
    od;
    # where are we at length a+1?
    if node[left[a+1]+offset]=d.deadend then
      node[left[a+1]+offset]:=fail;
    else
      a:=0;
    fi;
    a:=a-1;
  od;

end);

InstallGlobalFunction(RuleAtPosKBDAG,function(d,w,p)
local node,q;
  node:=d.dag;
  q:=p;
  while IsList(node) and q<=Length(w) do
    node:=node[w[q]+d.offset];
    q:=q+1;
  od;
  if IsInt(node) then
    return node; # the rule number to apply
  else
    # fail or list -- no rule applies
    return fail;
  fi;
end);

# Function to test validity of DAG structure
# BindGlobal("VerifyKBDAG",function(d,tzrules)
# local offset,node,j,a,idx,left,recurse;
#   if Length(d!.backpoint)<>Length(tzrules) then Error("len");fi;
#   offset:=d.offset;
#   for idx in [1..Length(tzrules)] do
#     left:=tzrules[idx][1];
#
#     node:=d.dag;
#     for j in [1..Length(left)] do
#       a:=left[j]+offset;
#       if node[a]=fail then
#        Error("not stored");
#      elif j=Length(left) then
#        # end -- check
#        if d.backpoint[idx]<>[node,a] or node[a]<>idx then Error("data!"); fi;
#      else
#        if not IsList(node[a]) then Error("too short");fi;
#        node:=node[a]; # go to next letter
#      fi;
#    od;
#  od;
#
#  recurse:=function(n)
#  local i,flag;
#    if not IsList(n) then
#      return;
#    else
#      flag:=true;
#      for i in n do
#        if IsList(i) then
#          recurse(i);
#          flag:=false;
#        elif IsInt(i) then
#          flag:=false;
#        fi;
#      od;
#      if flag and n<>d.dag then Error("stored fail list");fi;
#    fi;
#  end;
#
#  recurse(d.dag);
#end);

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
##  which we call rules, and a list of pairs of numbers
##  or more generalized form for saving memory (pairs2check).
##  Each lhs of a rule has to be greater than its rhs
##  (so when we apply a rule to a word, we are effectively reducing it -
##  according to the ordering considered)
##  Each number in a pair of the list pairs2check
##  refers to one of the rules. A pair corresponds to a pair
##  of rules where confluence was not yet checked (according to
##  the Knuth Bendix algorithm).
##  Pairs might also be given in the form of a 3-entry list
##  ['A',x,l] to denote all pairs of the form [x,y] for y in l,
##  respectively ['B',l,y] for pairs [x,y] with x in l.
##
##  Note that at this stage the kb rws obtained might not be reduced
##  (the same relation might even appear several times).
##
InstallGlobalFunction(CreateKnuthBendixRewritingSystem,
function(fam, wordord)
local r,kbrws,rwsfam,relations_with_correct_order,CantorList,relwco,
      w,freefam,gens;

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
    return Unique(q);
  end;

  # generates the list of all pairs (x,y)
  # where x,y are distinct elements of the set [1..n]
  # encoded in compact form
  CantorList:=function(n)
  local i,l;
    l:=[];
    for i in [2..n] do
      Add(l,['A',i,[1..i-1]]);
      Add(l,['B',[1..i-1],i]);
    od;
    return(l);
  end;

  if ValueOption("isconfluent")=true then
    CantorList:=n->[];
  fi;

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
    gens:=GeneratorsOfMonoid(FreeMonoidOfFpMonoid(w));
  else
    w:=CollectionsFamily(fam)!.wholeSemigroup;
    r:=RelationsOfFpSemigroup(w);
    freefam:=ElementsFamily(FamilyObj(FreeSemigroupOfFpSemigroup(w)));
    gens:=GeneratorsOfSemigroup(FreeSemigroupOfFpSemigroup(w));
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
    freefam:=freefam,
    generators:=gens));

  kbrws!.kbdag:=EmptyKBDAG(Concatenation(List(gens,LetterRepAssocWord)));

  if ValueOption("isconfluent")=true then
    kbrws!.createdconfluent:=true;
  fi;

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
        ptc,    # do we need to check pairs
        v;      # a rule

  ptc:=not (IsBound(rws!.createdconfluent) and rws!.createdconfluent);
  r := ShallowCopy(rws!.tzrules);
  rws!.tzrules:=[];
  if ptc then
    rws!.pairs2check:=[];
  else
    Unbind(rws!.pairs2check);
  fi;
  rws!.reduced := true;

  if IsBound(rws!.kbdag) then
    rws!.kbdag.stepback:=11;
  fi;

  for v in r do
    AddRuleReduced(rws, v);
  od;
  if not ptc then
    rws!.pairs2check:=[];
  fi;
end);

# use bit lists to reduce the numbers of rules to test
# this should ultimately become part of the kernel routine
BindGlobal("ReduceLetterRepWordsRewSysNew",function(tzrules,w,dag)
local has,n,p,back;
  if not IsRecord(dag) then
    return ReduceLetterRepWordsRewSys(tzrules,w);
  fi;
  w:=ShallowCopy(w); # so we can replace
  if IsBound(dag.stepback) then back:=dag.stepback;
  else back:=11;fi;

  repeat
    has:=false;
    p:=1;
    while p<=Length(w) do
      # find the rule applying at the position in the dag
      n:=RuleAtPosKBDAG(dag,w,p);
      if n<>fail then
        # now apply rule
        if Length(tzrules[n][1])=Length(tzrules[n][2]) then
          w{[p..p+Length(tzrules[n][1])-1]}:=tzrules[n][2];
        else
          w:=Concatenation(w{[1..p-1]},tzrules[n][2],
            w{[p+Length(tzrules[n][1])..Length(w)]});
        fi;
        has:=true;
        # step a bit back. It doesn't really matter, as we only terminate if
        # we have once run through the whole list without doing any change.
        p:=Maximum(0,p-back);
      fi;
      p:=p+1;
    od;
  until has=false;
  return w;
end);

InstallOtherMethod(AddRule,
  "Fallback Method, call AddRuleReduced", true,
  [ IsKnuthBendixRewritingSystem and IsMutable
     and IsKnuthBendixRewritingSystemRep, IsList ], -1,
function(kbrws,v)
  Info(InfoWarning,1,"Fallback method -- calling `AddRuleReduced` instead");
  AddRuleReduced(kbrws,v);
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
  [ IsKnuthBendixRewritingSystem and IsMutable
     and IsKnuthBendixRewritingSystemRep, IsList ], 0,
function(kbrws,v)

local u,a,b,c,k,n,s,add_rule,fam,ptc,kbdag,abi,rem,
  remove_rules;

  # did anyone fiddle with the rules that there are invalid pairs?
  # This happens e.g. in the fr package.
  if IsBound(kbrws!.pairs2check)
    # only do this if its within the fr package to not slow down other uses
    and not IsBound(kbrws!.kbdag) then
    b:=kbrws!.pairs2check;
    k:=false;
    a:=Length(kbrws!.tzrules);
    for n in [1..Length(b)] do
      s:=b[n];
      if (Length(s)=2 and s[1]>a or s[2]>a)
          or (s[1]='A' and s[2]>a) or (s[1]='B' and s[3]>a) then
        b[n]:=fail; k:=true;
      elif s[1]='A' and ForAny(s[3],x->x>a) then
        s[3]:=Filtered(s[3],x->x<=a);
      elif s[1]='B' and ForAny(s[2],x->x>a) then
        s[2]:=Filtered(s[2],x->x<=a);
      fi;
    od;
    if k then kbrws!.pairs2check:=Filtered(b,x->x<>fail);fi;
  fi;



    # the fr package assigns initial tzrules on its own, this messes up
    # the dag structure. Delete ...
    if IsBound(kbrws!.kbdag) and
      Length(kbrws!.kbdag.backpoint)<>Length(kbrws!.tzrules) then
      Info(InfoPerformance,2,
       "Cannot use dag for lookup since rules were assigned directly");
      #a:=EmptyKBDAG(kbrws!.kbdag.genids);
      #kbrws!.kbdag:=a;
      #for b in [1..Length(kbrws!.tzrules)] do
      #  AddRuleKBDAG(a,kbrws!.tzrules[b][1],b);
      #od;
      Unbind(kbrws!.kbdag);
    fi;

    # allow to give rule also as words in free monoid
    if ForAll(v,IsAssocWord) and
      IsIdenticalObj(kbrws!.freefam,FamilyObj(v[1])) then
      v:=List(v,LetterRepAssocWord);
    fi;

    ptc:=IsBound(kbrws!.pairs2check);

    if IsBound(kbrws!.kbdag) then
      kbdag:=kbrws!.kbdag;
    else
      kbdag:=fail;
    fi;

#   older, less efficient version for just single rule
#    #given a Knuth Bendix Rewriting System, kbrws,
#    #removes rule i of the set of rules of kbrws and
#    #modifies the list pairs2check in such a way that the previous indexes
#    #are modified so they correspond to same pairs as before
#    remove_rule:=function(i)
#      local j,q,l,kk;
#
#      if kbdag<>fail then
#        # update lookup structure
#        DeleteRuleKBDAG(kbdag,kbrws!.tzrules[i][1],i);
#      fi;
#
#      #remove rule from the set of rules
#      #q:=kbrws!.tzrules{[1..i-1]};
#      #Append(q,kbrws!.tzrules{[i+1..Length(kbrws!.tzrules)]});
#      #kbrws!.tzrules:=q;
#      q:=kbrws!.tzrules;
#      Remove(q,i);
#
#      if ptc then
#        #delete pairs of indexes that include i
#        #and change occurrences of indexes k greater than i in the
#        #list of pairs and change them to k-1
#
#        kk:=kbrws!.pairs2check;
#
#        #So we'll construct a new list with the right pairs
#        l:=[];
#        for j in [1..Length(kk)] do
#          if Length(kk[j])=2 then
#            if kk[j][1]<i then
#              if kk[j][2]<i then
#                Add(l,kk[j]);
#              elif kk[j][2]>i then
#                # reindex
#                Add(l,[kk[j][1],kk[j][2]-1]);
#              fi;
#            elif kk[j][1]>i then
#              if kk[j][2]<i then
#                # reindex
#                Add(l,[kk[j][1]-1,kk[j][2]]);
#              elif kk[j][2]>i then
#                # reindex
#                Add(l,[kk[j][1]-1,kk[j][2]-1]);
#              fi;
#            # else rule gets deleted
#            fi;
#          elif kk[j][1]='A' then
#            if kk[j][2]<i then
#              Add(l,kk[j]); # all smaller, no delete
#            elif kk[j][2]>i then
#              Add(l,['A',kk[j][2]-1,Concatenation(
#                Filtered(kk[j][3],x->x<i),Filtered(kk[j][3],x->x>i)-1)]);
#            # else pairs deleted since rule deleted
#            fi;
#          else # 'B' case
#            if kk[j][3]<i then
#              Add(l,kk[j]); # all smaller, no delete
#            elif kk[j][3]>i then
#              Add(l,['B',Concatenation(Filtered(kk[j][2],x->x<i),
#                Filtered(kk[j][2],x->x>i)-1),kk[j][3]-1]);
#            # else pairs deleted since rule deleted
#            fi;
#          fi;
#
#        od;
#        kbrws!.pairs2check:=l;
#      fi;
#
#    end;

    #given a Knuth Bendix Rewriting System, kbrws,
    #removes the rules indexed by weg from the set of rules of kbrws and
    #modifies the list pairs2check in such a way that the previous indexes
    #are modified so they correspond to same pairs as before
    remove_rules:=function(weg)
      local j,q,a,l,kk,i,neu,x,y;

      if kbdag<>fail then
        for i in weg do
          # update lookup structure
          DeleteRuleKBDAG(kbdag,kbrws!.tzrules[i][1],i);
        od;
      fi;

      #remove rule from the set of rules
      q:=kbrws!.tzrules;

      kk:=Minimum(weg);
      neu:=[1..kk-1];
      for i in [kk..Length(q)] do
        if i in weg then
          neu[i]:=fail;
        else
          q[kk]:=q[i];
          neu[i]:=kk;
          kk:=kk+1;
        fi;
      od;
      for i in [Length(q),Length(q)-1..Length(q)-Length(weg)+1] do
        Unbind(q[i]);
      od;

      if ptc then
        #delete pairs of indexes that include i
        #and change occurrences of indexes k greater than i in the
        #list of pairs and change them to k-1

        kk:=kbrws!.pairs2check;

        #So we'll construct a new list with the right pairs
        l:=[];
        for j in [1..Length(kk)] do
          if Length(kk[j])=2 then
            if not(kk[j][1] in weg or kk[j][2] in weg) then
              Add(l,neu{kk[j]});
            # otherwise, one is killed
            fi;
          elif kk[j][1]='A' and not kk[j][2] in weg then
            #a:=Difference(neu{kk[j][3]},[fail]);
            a:=kk[j][3];
            x:=neu[a[1]];y:=neu[a[Length(a)]];
            if IsRange(a) and x<>fail and y<>fail then
              a:=[x..y];
            else
              a:=Set(neu{kk[j][3]});
              if Last(a)=fail then Remove(a);fi;
            fi;

            if Length(a)>0 then
              Add(l,['A',neu[kk[j][2]],a]);
            fi;
          elif kk[j][1]='B' and not kk[j][3] in weg then
            #a:=Difference(neu{kk[j][2]},[fail]);
            a:=kk[j][2];
            x:=neu[a[1]];y:=neu[a[Length(a)]];
            if IsRange(a) and x<>fail and y<>fail then
              a:=[x..y];
            else
              a:=Set(neu{kk[j][2]});
              if Last(a)=fail then Remove(a);fi;
            fi;

            if Length(a)>0 then
              Add(l,['B',a,neu[kk[j][3]]]);
            fi;
          fi;

        od;
        kbrws!.pairs2check:=l;
      fi;
    end;

    #given a Knuth Bendix Rewriting System this function returns it
    #with the given extra rule adjoined to the set of rules
    #and the necessary pairs adjoined to pairs2check
    #(the pairs that we have to put in pairs2check correspond to the
    #new rule together with all the ones that were in the set of rules
    #previously)
    add_rule:=function(u,kbrws)
      local l,i,j,n,p,any;

      #insert rule
      Add(kbrws!.tzrules,u);
      if kbdag<>fail then
        l:=AddRuleKBDAG(kbdag,u[1],Length(kbrws!.tzrules));
        if l<>true then Error("rulesubset"); fi;
      fi;
      #VerifyKBDAG(kbdag,kbrws!.tzrules);

      if ptc then
        #insert new pairs
        l:=kbrws!.pairs2check;
        n:=Length(kbrws!.tzrules);
        Add(l,[n,n]);
        #for i in [1..n-1] do
        #  Append(l,[[i,n],[n,i]]);
        #od;
        if n>1 then
          Add(l,['A',n,[1..n-1]]);
          Add(l,['B',[1..n-1],n]);
        fi;

        kbrws!.pairs2check:=l;
      fi;

      if IsBound(kbrws!.invmap) then
        # free cancel part
        u:=List(u,ShallowCopy);
        i:=1;
        while i<=Length(u[1]) and i<=Length(u[2]) and u[1][i]=u[2][i] do
          i:=i+1;
        od;

        any:=false;
        for j in [i..Length(u[2])] do
          p:=Concatenation(kbrws!.invmap{u[1]{[j,j-1..i]}},
            u[2]{[i..j]});
          l:=ReduceLetterRepWordsRewSysNew(kbrws!.tzrules,p,kbdag);
  #Print("fellow ",List(u,Length),Length(p)," ",Length(l),"\n");
          if not l in kbrws!.fellowTravel then
            Add(kbrws!.fellowTravel,l);
            any:=true;
            if Length(kbrws!.fellowTravel) mod 200=0 then
              kbrws!.fellowTravel:=List(kbrws!.fellowTravel,
                x->ReduceLetterRepWordsRewSysNew(kbrws!.tzrules,x,kbdag));
              kbrws!.fellowTravel:=Unique(kbrws!.fellowTravel);
            fi;
          fi;
        od;
        if any then
          kbrws!.flaute:=0;
        else
          kbrws!.flaute:=kbrws!.flaute+1;
        fi;
      fi;
    end;

    #the stack is a list of pairs of words such that if two words form a pair
    #they have to be equivalent, that is, they have to reduce to same word

    #TODO
    fam:=kbrws!.freefam;
    #we put the pair v in the stack
    s:=[v];

    #while the stack is non empty
    while not(IsEmpty(s)) do

    #VerifyKBDAG(kbdag,kbrws!.tzrules);
      #pop the first rule from the stack
      #use rules available to reduce both sides of rule
      u:=s[1];
      s:=s{[2..Length(s)]};
      a:=ReduceLetterRepWordsRewSysNew(kbrws!.tzrules,u[1],kbdag);
      b:=ReduceLetterRepWordsRewSysNew(kbrws!.tzrules,u[2],kbdag);

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

        #Now we have to check if by adjoining this rule
        #any of the other active ones become redundant

        n:=Length(kbrws!.tzrules);
        # go descending to avoid having to reindex
        rem:=[];
        for k in [n,n-1..1] do

          #if lhs of rule k contains lhs of new rule
          #as a subword then we delete rule k
          #but add it to the stack, since it has to still hold

          if  PositionSublist(kbrws!.tzrules[k][1],a,0)<>fail then
            Add(s,kbrws!.tzrules[k]);
            Add(rem,k);
            n:=Length(kbrws!.tzrules)-1;
          fi;
        od;
        if Length(rem)>0 then
          remove_rules(rem);
        fi;

        #VerifyKBDAG(kbdag,kbrws!.tzrules);

        # and store new rule
        add_rule([a,b],kbrws);
        kbrws!.reduced := false;

        n:=Length(kbrws!.tzrules);
        for k in [n,n-1..1] do
          #else if rhs of rule k contains the new rule
          #as a subword then we use the new rule
          #to reduce that rhs
          if  PositionSublist(kbrws!.tzrules[k][2],a,0)<>fail then
            kbrws!.tzrules[k][2]:=
              ReduceLetterRepWordsRewSysNew(kbrws!.tzrules,
                kbrws!.tzrules[k][2],kbdag);
          fi;
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

# We store compressed data -- expand, (and also delete old stuff)
BindGlobal("KBRWSUnpackPairsAt",function(kbrws,p)
local i,a;
  i:=kbrws!.pairs2check[p];
  if IsChar(i[1]) then
    # We store compressed data -- expand, (and also delete old stuff)
    if i[1]='A' then
      a:=List(i[3],x->[i[2],x]);
    elif i[1]='B' then
      a:=List(i[2],x->[x,i[3]]);
    else Error("kind"); fi;
    kbrws!.pairs2check:=Concatenation(a,kbrws!.pairs2check{[p+1..Length(kbrws!.pairs2check)]});
    p:=1;
  fi;
  return p;
end);



#u and v are pairs of rules, kbrws is a kb RWS
#look for proper overlaps of lhs (lhs of u ends as lhs of v starts)
#Check confluence does not fail here, adjoining extra rules if necessary
BindGlobal("KBOverlaps",function(ui,vi,kbrws,p)
local u,v,m,k,a,c,lsu,lsv,lu,eq,i,j;

  # work around copied code in kan package
  if IsChar(ui) then # must unpack
    p:=KBRWSUnpackPairsAt(kbrws,p);
    vi:=kbrws!.pairs2check[p];
    ui:=vi[1];vi:=vi[2];
  fi;

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
        # already used pairs
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
local   pn,lp,rl,p,i;

  if IsBound(kbrws!.invmap) then
    kbrws!.fellowTravel:=[];
  fi;
  kbrws!.flaute:=0; # how often no new fellow traveler?

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
  rl:=49;
  pn:=Length(kbrws!.pairs2check);
  lp:=Length(kbrws!.pairs2check);
  while lp>=p do
    i:=kbrws!.pairs2check[p];
    if IsChar(i[1]) then
      # We store compressed data -- expand, (and also delete old stuff)
      p:=KBRWSUnpackPairsAt(kbrws,p);
    fi;

    p:=KBOverlaps(i[1],i[2],kbrws,p)+1;
    lp:=Length(kbrws!.pairs2check);
    if Length(kbrws!.tzrules)>rl
      or AbsInt(lp-pn)>10000 then
      Info(InfoKnuthBendix,1,Length(kbrws!.tzrules)," rules, ",
                            lp," pairs, ",kbrws!.flaute," no new fellow");
      rl:=Length(kbrws!.tzrules)+49;
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
  local i, copy_of_kbrws, u, tzr;

  # if the rws already knows it is reduced return true
  if kbrws!.reduced then return true; fi;

  tzr := TzRules(kbrws);
  for i in [1..Length(tzr)] do

    u := tzr[i];

    copy_of_kbrws := ShallowCopy(kbrws);
    copy_of_kbrws!.tzrules := [];
    Append(copy_of_kbrws!.tzrules,kbrws!.tzrules{[1..i-1]});
    Append(copy_of_kbrws!.tzrules,kbrws!.tzrules
            {[i+1..Length(kbrws!.tzrules)]});

    if ReduceLetterRepWordsRewSys(copy_of_kbrws!.tzrules,u[1])<>u[1] or
       ReduceLetterRepWordsRewSys(copy_of_kbrws!.tzrules,u[2])<>u[2] then
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
##  to assure compatibility with gap4.2
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
  local fam;

  fam := ElementsFamily(FamilyObj(s));
  return KnuthBendixRewritingSystem(fam,wordord);
end);

InstallOtherMethod(KnuthBendixRewritingSystem,
"for an fp monoid and an order on the family of words of the underlying free monoid", true,
[IsFpMonoid, IsOrdering], 0,
function(m,wordord)
  local fam;

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
function(kbrws)
local new;
  new:=Objectify( Subtype( TypeObj(kbrws), IsMutable ),
              rec(
                  generators:=StructuralCopy(kbrws!.generators),
                  family := kbrws!.family,
                  reduced := false,
                  tzrules:= StructuralCopy(kbrws!.tzrules),
                  pairs2check:= [],
                  ordering :=kbrws!.ordering,
                  freefam := kbrws!.freefam,
                  tzordering := kbrws!.tzordering));
  if IsBound(kbrws!.kbdag) then
    new!.kbdag:=StructuralCopy(kbrws!.kbdag);
  fi;
  return new;
end);

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
