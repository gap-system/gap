#############################################################################
##
#W    sift.gi              The GenSift package                Max Neunhoeffer
##                                                             Cheryl Praeger
##                                                            Csaba Schneider
##
##    @(#)$Id: sift.gi,v 1.5 2009/07/25 22:15:27 gap Exp $
##
##  This file contains the generic implementation of the sift methods.
##

############################################################################
# Implementation of GeneralizedSift:
############################################################################


InstallGlobalFunction(PrepareSiftRecords,
function(psr,grp)
  # psr must be a list of pre-sift records and grp a group with generators.
  # Does all the preparations and gives a new list sr containing (shallow) 
  # copies of the record in psr that are proper sift records.
  # Algorithm: First we go down and calculate the subgroup chain using
  # the "subgpSLP" entries. Having all the "group" and "subgp" entries
  # set up, we go bottom up and replace all straight line programs we find
  # with their results, all relative to the "group" entry in the same level.
  # We keep the SLPs in the SLP components together with a reference
  # with respect to which generators they are.
  # Finally resolve "fromUp" and "fromDown" entries.

  local RecursivelyCopyReplacingSLPs,RecursivelyCopyInRecords,curgrp,i,sr,l;

  # We want a copy of the whole structure:
  l := Length(psr);
  sr := List([1..l],x->rec());

  # First top-bottom for the subgroups:
  curgrp := grp;
  for i in [1..l] do
    if IsBound(psr[i].groupSLP) then
        # In this case we begin again from the somewhere:
        if psr[i].groupSLP = TrivialSubgroup then
            sr[i].group := TrivialSubgroup(grp);
            sr[i].groupSLP := StraightLineProgram( [[[1,0]]], 
                                 Length(GeneratorsOfGroup(grp)));
        elif IsList(psr[i].groupSLP) and Length(psr[i].groupSLP) = 2 and
             IsStraightLineProgram(psr[i].groupSLP[1]) and
             IsInt(psr[i].groupSLP[2]) and psr[i].groupSLP[2] < i then
            sr[i].group := Group(ResultOfStraightLineProgram(psr[i].groupSLP[1],
                         GeneratorsOfGroup(sr[psr[i].groupSLP[2]].group)));
            sr[i].groupSLP := psr[i].groupSLP;
        else  # then it must be an SLP from the top:
            sr[i].group := Group(ResultOfStraightLineProgram(psr[i].groupSLP,
                                      GeneratorsOfGroup(grp)));
            sr[i].groupSLP := [psr[i].groupSLP,1];
        fi;
        curgrp := sr[i].group;
    else
        sr[i].group := curgrp;
    fi;
    if psr[i].subgpSLP = TrivialSubgroup then
        sr[i].subgp := TrivialSubgroup(curgrp);
        sr[i].subgpSLP := StraightLineProgram( [[[1,0]]],
                              Length(GeneratorsOfGroup(grp)));
    else
        sr[i].subgp := Group(ResultOfStraightLineProgram(psr[i].subgpSLP,
                                       GeneratorsOfGroup(curgrp)));
        sr[i].subgpSLP := psr[i].subgpSLP;
    fi;
    curgrp := sr[i].subgp;       # go one step down
  od;
  
  # Now go bottom-up to replace the straight line programs using:
  
  RecursivelyCopyReplacingSLPs := function(psr,sr,r,rr,depth)
    # Recursively (with respect to records) copies r to rr, thereby
    # substituting slps in r by real elements. depth is the current
    # reference point.

    local ReplaceSLPs,different,i,iSLP,j,li,li2,res;

        ReplaceSLPs := function(sr,ob,depth)
            local gens;
            # Replaces one slp, covers case of ob = [slp,int]
            if IsStraightLineProgram(ob) then
                gens := GeneratorsOfGroup(sr[depth].group);
                return [ResultOfStraightLineProgram(ob,gens),
                        [ob,depth]];
            elif IsList(ob) and Length(ob) = 2 and 
                 IsStraightLineProgram(ob[1]) and IsInt(ob[2]) and
                 ob[2] >= 1 and ob[2] <= Length(sr) then
                gens := GeneratorsOfGroup(sr[ob[2]].group);
                return [ResultOfStraightLineProgram(ob[1],gens),ob];
            else
                return ob;
            fi;
        end;

    for i in RecFields(r) do
        if Length(i) < 3 or i{[Length(i)-2..Length(i)]} <> "SLP" then
            # leave subgpSLP and groupSLP untouched!
            if IsRecord(r.(i)) then
                rr.(i) := rec();
                RecursivelyCopyReplacingSLPs(psr,sr,r.(i),rr.(i),depth);
            else
                res := ReplaceSLPs(sr,r.(i),depth);
                if not(IsIdenticalObj(res,r.(i))) then
                    rr.(i) := res[1];
                    iSLP := Concatenation(i,"SLP");
                    rr.(iSLP) := res[2];
                elif IsList(r.(i)) then   # do one level of lists:
                    li := [];
                    li2 := [];
                    different := false;
                    for j in [1..Length(r.(i))] do
                        if IsBound(r.(i)[j]) then
                            res := ReplaceSLPs(sr,r.(i)[j],depth);
                            if not(IsIdenticalObj(res,r.(i)[j])) then
                                different := true;
                                li[j] := res[1];
                                li2[j] := res[2];
                            else
                                li[j] := res;
                                li2[j] := res;
                            fi;
                        fi;
                    od;
                    if different then
                        rr.(i) := li;
                        iSLP := Concatenation(i,"SLP");
                        rr.(iSLP) := li2;
                    else
                        rr.(i) := r.(i);
                    fi;
                else
                    rr.(i) := r.(i);
                fi;
            fi;
        fi;
    od;
    return rr;
  end;

  for i in [1..Length(sr)] do
      RecursivelyCopyReplacingSLPs(psr,sr,psr[i],sr[i],i);
  od;

  RecursivelyCopyInRecords := function(src,dst,keyword)
    # Recursively runs through the data structure dst (entering records).
    # All components that are equal to keyword are replaced by the 
    # corresponding value in dst. The data structures src and dst must be
    # compatible with respect to the records in there.
    local i,iSLP;
    for i in RecFields(dst) do
        if dst.(i) = keyword then
            dst.(i) := src.(i);   # and must have the same component
            iSLP := Concatenation(i,"SLP");
            if IsBound(src.(iSLP)) then
                dst.(iSLP) := src.(iSLP);
            fi;
        elif IsRecord(dst.(i)) and IsBound(src.(i)) and IsRecord(src.(i)) then
            RecursivelyCopyInRecords(src.(i),dst.(i),keyword);
        fi;
    od;
  end;

  # Now help moving things between the level, first moving down:
  for i in [2..Length(sr)] do
      RecursivelyCopyInRecords(sr[i-1],sr[i],"fromUp");
  od;
  # Now moving up:
  for i in [Length(sr)-1,Length(sr)-2 .. 1] do
      RecursivelyCopyInRecords(sr[i+1],sr[i],"fromDown");
  od;

  return sr;
end);

GenSift.MakeSLPFromTop := function(srl,s)
  # s is a pair of a slp and a level. Returns an slp that is in terms
  # of the generators of the original group.
  local lev,l,ss;
  lev := s[2];
  s := s[1];
  l := LinesOfStraightLineProgram(s);
  if Length(l) = 1 and l[1] = [1,0] then
      # A trivial case:
      # We must give a program with the correct number of inputs:
      return StraightLineProgram( [ [1,0] ],
                     Length(GeneratorsOfGroup(srl[1].group)));
  fi;
  repeat
    if lev = 1 then   # we are already on top
        return s;
    elif IsBound(srl[lev].groupSLP) then  # this is in terms of somewhere
        ss := GenSift.MakeSLPFromTop(srl,srl[lev].groupSLP);
        return CompositionOfStraightLinePrograms(s,ss);
    else
        lev := lev-1;
        s := CompositionOfStraightLinePrograms(s,srl[lev].subgpSLP);
        # Now s is in terms of the generators of lev again!
    fi;
  until false;
  # never reached
end;

############################################################################
# Profiling infrastructure:
############################################################################

InstallValue( GeneralizedSiftProfile, rec());

# Number of calls to GeneralizedSift:
GeneralizedSiftProfile.GeneralizedSiftCalls := 0;

# We profile by level, globally for all groups and representations:

# Number of multiplications (apart from order tests, and random elements):
GeneralizedSiftProfile.Multiplications := [];

# Number of inversions of elements:
GeneralizedSiftProfile.Inversions := [];

# Number of random elements chosen:
GeneralizedSiftProfile.RandomElements := [];

# Number of multiplications for creation of random elements:
GeneralizedSiftProfile.RandomElementsMults := [];
# Note that the multiplications are counted in "pseudorandslp.gi" and
# copied here by "GeneralizedSift"!

# Number of Order tests:
GeneralizedSiftProfile.OrderTests := [];

# Number of multiplications for order test:
GeneralizedSiftProfile.OrderTestsMults := [];
# Note that this is not increased in case of usage of "Order"!

GeneralizedSiftProfile.currentLevel := 1;  # set by "GeneralizedSift"


InstallGlobalFunction( ResetGeneralizedSiftProfile, function(arg)
  # Resets the generalized sift profile for sifting with "levels" levels.
  local l,gsp,levels;
  if Length(arg) = 0 then
      levels := 1;
  else
      levels := arg[1];
  fi;
  l := ListWithIdenticalEntries(levels,0);
  gsp := GeneralizedSiftProfile;
  gsp.GeneralizedSiftCalls := 0;
  gsp.Multiplications := ShallowCopy(l);
  gsp.Inversions := ShallowCopy(l);
  gsp.RandomElements := ShallowCopy(l); 
  PseudoRandomSLPMultiplications := 0;
  gsp.RandomElementsMults := ShallowCopy(l);
  gsp.OrderTests := ShallowCopy(l);
  gsp.OrderTestsMults := ShallowCopy(l);
  gsp.currentLevel := 1;  # this is set by "GeneralizedSift"
end);

InstallGlobalFunction( DisplayGeneralizedSiftProfile, function()
  local gsp,n,nh,dolist;

  gsp := GeneralizedSiftProfile;

  dolist := function(l)
    local i;
    Print("  ",String(QuoInt(Sum(l)+nh,n),6)," [",QuoInt(l[1]+nh,n));
    for i in [2..Length(l)] do
        Print(",",QuoInt(l[i]+nh,n));
    od;
    Print("]\n");
  end;
  
  Print("Number of calls to GeneralizedSift  : ",gsp.GeneralizedSiftCalls,"\n");
  n := gsp.GeneralizedSiftCalls;
  if n = 0 then
      Print("No data yet.\n");
      return;
  fi;
  nh := QuoInt(n,2);  # for rounding
  Print("The following numbers are per call to GeneralizedSift:\n\n");
  Print("Number of multiplications (*)       : \n");
  dolist(gsp.Multiplications);
  Print("Number of inversions                : \n");
  dolist(gsp.Inversions);
  Print("Number of random elements generated : \n");
  dolist(gsp.RandomElements);
  Print("Number of mults for random elements : \n");
  dolist(gsp.RandomElementsMults);
  Print("Number of order tests               : \n");
  dolist(gsp.OrderTests);
  Print("Number of mults for order tests     : \n");
  dolist(gsp.OrderTestsMults);
  Print("Total number of multiplications (**): \n");
  dolist(gsp.Multiplications+gsp.RandomElementsMults+gsp.OrderTestsMults);
  Print("\n(*)  not including order tests and random elements\n");
  Print("(**) counting inversions as multiplications\n");
end);
        
# Here come the generic functions for the generalized sift:

GenSift.SpecialActionUseIsMemberInfo := function(srl,lev,ret)
  # This is a function which can be plugged into the "specialaction" 
  # component of a BasicSift record. It uses a possible information from
  # the IsMember test to apply an additional element. ret is modified,
  # but no further action needs to be taken.
  local r;
  r := ret.ismemberresult;
  if r = true then   # no additional information
      return;
  fi;
  # in that case r has to be a positive integer and
  # a component extraels has to be bound
  Add(ret.slp,srl[lev].ismember.extraelsSLP[r]);
  GeneralizedSiftProfile.Multiplications[lev] := 
      GeneralizedSiftProfile.Multiplications[lev]+2;
  ret.el := ret.el * srl[lev].ismember.extraels[r];
  ret.new := ret.new * srl[lev].ismember.extraels[r];
  return;
end;

InstallGlobalFunction( BasicSiftRandom,function(srl,lev,g,eps)
  # Does one BasicSift step using the data given in srl
  # srl is a list of SiftRecords, lev the level in which to sift, 
  # g a group element, and eps a limit for the error prob.
  # returns either a pair: an element y of the group that multiplies g into
  #                        the subset and a slp in the gens for y
  #         or     fail

  local N,e,i,n,r,s,s2,sr,ss,y,z,gsp,ret;

  gsp := GeneralizedSiftProfile;

  if not(IS_MACFLOAT(eps)) then
      if IsRat(eps) then
          eps :=  MACFLOAT_INT(NumeratorRat(eps))
                 /MACFLOAT_INT(DenominatorRat(eps));
      else
          Error("eps must be a rational number or a floating point number");
      fi;
  fi;
  # Now eps is a floating point number

  sr := srl[lev];   # this is our record
  if sr.ismember.isdeterministic then
      e := MACFLOAT_INT(0);
      N := LOG_MACFLOAT(eps)/LOG_MACFLOAT(1-sr.p);
  else    
      e := eps * sr.p / (2 * (1-sr.p));
      N := LOG_MACFLOAT(eps/MACFLOAT_INT(2))/LOG_MACFLOAT(1-sr.p);
  fi;
  ResetPseudoRandomSLP( sr.group );
  n := MACFLOAT_INT(0);
  repeat
      y := PseudoRandomSLP( sr.group );
      gsp.RandomElements[lev] := gsp.RandomElements[lev]+1;
      if SIFT_VERBOSITY >= 1 then Print("r\c"); fi;
      z := g * y;
      gsp.Multiplications[lev] := gsp.Multiplications[lev]+1;
      r := sr.ismember.method(sr.ismember,sr.subgp, z,e);
      if r <> false then
          ret := rec(el := y,
                     slp := [[PseudoRandomAsSLP(sr.group),lev]],
                     ismemberresult := r,
                     new := z);
          if IsBound(sr.specialaction) then
              sr.specialaction(srl,lev,ret);
              # ret may change here, especially ".action" could be set!
          fi;
          return ret;
      fi;
      n := n + One(n);
  until n >= N;
  return fail;
end);


InstallGlobalFunction( BasicSiftCosetReps, function(srl,lev,g,eps)
  # Does one BasicSift step using an exhaustive search through known
  # coset representatives for subgp in group. We just apply those stored
  # in the sift record.

  local i,c,cr,e,k,r,sr,n,gsp,z,ret;
  
  gsp := GeneralizedSiftProfile;

  sr := srl[lev];  # this is our record

  # We need a smaller error probability for the membership test, because
  # we need more than one to find the result:
  if not(IS_MACFLOAT(eps)) then eps := FLOAT_RAT(eps); fi;
  k := Length(sr.cosetreps);  # the identity is stored!
  if srl[lev].ismember.isdeterministic then
      e := MACFLOAT_INT(0);   # a deterministic IsMember test!
  else
      n := k * srl[lev].p;      # we have p = n/k
      e := (n+MACFLOAT_INT(1))/(MACFLOAT_INT(k)-n)*eps;
      if e > FLOAT_RAT(1/3) then
          e := FLOAT_RAT(1/3);
      fi;
  fi;
  cr := List([1..Length(sr.cosetreps)],i->[i,sr.cosetreps[i]]);  
            # for the random selection
  for i in [1..Length(sr.cosetreps)] do
      # Pick a random coset representative not yet tried:
      r := Random([1..Length(cr)]);
      c := cr[r];
      cr[r] := cr[Length(cr)];
      Unbind(cr[Length(cr)]);
      gsp.Multiplications[lev] := gsp.Multiplications[lev]+1;
      z := g * c[2];
      r := sr.ismember.method(sr.ismember,sr.subgp,z,e);
      if r <> false then
          ret := rec(el := c[2],
                     slp := [ sr.cosetrepsSLP[c[1]] ],
                     ismemberresult := r,
                     new := z);
          if IsBound(sr.specialaction) then
              sr.specialaction(srl,lev,ret);
              # ret may change here, especially ".action" could be set!
          fi;
          return ret;
      fi;
  od;
  # if we reach this point, an error must have occured further up in the
  # sift because our membership test is one sided Monte Carlo. So give up.
  return fail;
end);

InstallGlobalFunction( BasicSiftCosetRepsWithT, function(srl,lev,g,eps)
  # The same as BasicSiftCosetReps, only the elements of the component
  # T are in addition multiplied after the coset representatives.
  local i,j,c,cr,e,k,n,r,s,sr,ss,s2,gsp,p,re,z;
  
  gsp := GeneralizedSiftProfile;

  sr := srl[lev];   # this is our record

  # We need a smaller error probability for the membership test, because
  # we need more than one to find the result:
  if not(IS_MACFLOAT(eps)) then eps := FLOAT_RAT(eps); fi;
  k := Length(sr.cosetreps)*Length(sr.T);  # the identity is stored!
  if srl[lev].ismember.isdeterministic then
      e := MACFLOAT_INT(0);   # a deterministic IsMember test!
  else
      n := k * srl[lev].p;      # we have p = n/k
      e := (n+MACFLOAT_INT(1))/(MACFLOAT_INT(k)-n)*eps;
      if e > FLOAT_RAT(1/3) then
          e := FLOAT_RAT(1/3);
      fi;
  fi;
  for j in [1..Length(sr.T)] do
      cr := List([1..Length(sr.cosetreps)],i->[i,sr.cosetreps[i]]);  
                # for the random selection
      for i in [1..Length(sr.cosetreps)] do
          # Pick a random coset representative not yet tried:
          r := Random([1..Length(cr)]);
          c := cr[r];
          cr[r] := cr[Length(cr)];
          Unbind(cr[Length(cr)]);
          gsp.Multiplications[lev] := gsp.Multiplications[lev]+2;
          p := c[2]*sr.T[j];
          z := g*p;
          re := sr.ismember.method( sr.ismember,sr.subgp, z, e );
          if re then
              s := GenSift.MakeSLPFromTop( srl, sr.cosetrepsSLP[c[1]] );
              s2 := GenSift.MakeSLPFromTop( srl, sr.TSLP[j] );
              #ss := IntegratedStraightLineProgram([s,s2]);
              return rec( el := c[2]*sr.T[j],
                          slp := [[s,1],[s2,1]],
                          ismemberresult := re,
                          new := z );
          fi;
      od;
  od;
  # if we reach this point, an error must have occured further up in the
  # sift because our membership test is one sided Monte Carlo. So give up.
  return fail;
end);

InstallGlobalFunction( BasicSiftShort ,function(srl,lev,g,eps)
  # Does one BasicSift step using the data given in srl
  # srl is a list of SiftRecords, lev the level in which to sift, 
  # g a group element, and eps a limit for the error prob.
  # returns either a pair: an element y of the group that multiplies g into
  #                        the subset and a slp in the gens for y
  #         or     fail
  local sr,e,y,slp,ret,myismember,itsresult;
  if not(IS_MACFLOAT(eps)) then
      if IsRat(eps) then
          eps :=  MACFLOAT_INT(NumeratorRat(eps))
                 /MACFLOAT_INT(DenominatorRat(eps));
      else
          Error("eps must be a rational number or a floating point number");
      fi;
  fi;
  # Now eps is a floating point number

  sr := srl[lev];   # this is our record
  if sr.ismember.isdeterministic then
      e := MACFLOAT_INT(0);
  else    
      e := eps * sr.p / (2 * (1-sr.p));
  fi;

  # Here is a little hack to use FindShortEl and still preserve the result:
  myismember := function(a,b,c,d)
    itsresult := sr.ismember.method(a,b,c,d);
    return itsresult <> false;
  end;

  y := FindShortEl(sr.group,x->myismember(sr.ismember,sr.subgp,g*x,e));
  if Length(y[2]) = 0 then
      slp := [StraightLineProgram([[1,0]],
                  Length(GeneratorsOfGroup(srl[1].group))),1];
  else
      slp := [StraightLineProgram([GenSift.SLPWord(y[2])],
                  Length(GeneratorsOfGroup(srl[1].group))),lev];
  fi;
  ret := rec(el := y[1],
             slp := [slp],
             ismemberresult := itsresult,
             new := g*y[1]);
  if IsBound(sr.specialaction) then
      sr.specialaction(srl,lev,ret);
      # ret may change here, especially ".action" could be set!
  fi;
  return ret;
end);


# Routines for order determination:
InstallGlobalFunction( SiftHasOrderInByOrder, function(x,orders,slp)
  # slp is not needed here, only in other variant SiftHasOrderInBlackBox.
  local gsp;
  gsp := GeneralizedSiftProfile;
  gsp.OrderTests[gsp.currentLevel] := gsp.OrderTests[gsp.currentLevel]+1;
  return Order(x) in orders;
end);

InstallGlobalFunction( SiftHasOrderInByProjOrder, function(x,orders,slp)
  # slp is not needed here, only in other variant SiftHasOrderInBlackBox.
  local gsp;
  gsp := GeneralizedSiftProfile;
  gsp.OrderTests[gsp.currentLevel] := gsp.OrderTests[gsp.currentLevel]+1;
  return ProjectiveOrder(x)[1] in orders;
end);

InstallGlobalFunction( SiftHasOrderInBlackBox, function(x,orders,slp)
  local gsp,i,l,new;
  gsp := GeneralizedSiftProfile;
  gsp.OrderTests[gsp.currentLevel] := gsp.OrderTests[gsp.currentLevel]+1;
  l := [x];
  if GenSift.IsOne(x) then
      return 1 in orders;
  fi;
  for i in [1..Length(slp)] do
      new := l[slp[i][1]] * l[slp[i][2]];
      gsp.OrderTestsMults[gsp.currentLevel] := 
                     gsp.OrderTestsMults[gsp.currentLevel] + 1;
      Add(l,new);
      if GenSift.IsOne(new) then
          if slp[i][3]=1 then
              return true;
          else
              return false;
          fi;
      fi;
  od;
  return false;
end);


# The following can be set according to the group in question to
#   SiftHasOrderInByOrder : just calculate order and lookup
# or
#   SiftHasOrderInBlackBox : do a black box order calculation
GenSift.HasOrderIn := SiftHasOrderInBlackBox;
GenSift.IsOne := IsOne;
GenSift.IsEq := EQ;

InstallGlobalFunction( IsMemberOrderOfElement, function( ismember, grp, z, e )
  # A deterministic test, whether z is in grp.
  # We use only the element order of z, because we need: z is in grp iff
  # its order is in ismember.orders. 
  return GenSift.HasOrderIn( z, ismember.orders, ismember.ordersslp );
end);

InstallGlobalFunction( IsMemberOrders, function( ismember, grp, z, e )
  # Tests, whether z is in grp
  # We use element orders, ismember.orders and ismember.p0 must be bound.

  local N,gens,h,n,gsp;

  gsp := GeneralizedSiftProfile;

  # Perhaps our new element already has an interesting order?
  if GenSift.HasOrderIn(z,ismember.orders,ismember.ordersslp) then
      return false;
  fi;

  if not(IS_MACFLOAT(e)) then e := FLOAT_RAT(e); fi;
  N := LOG_MACFLOAT(e)/LOG_MACFLOAT(1-ismember.p0);
  gens := ShallowCopy(GeneratorsOfGroup(grp));
  Add(gens,z);
  grp := Group(gens);
  n := MACFLOAT_INT(0);
  repeat
      if SIFT_VERBOSITY >= 1 then Print("o\c"); fi;
      gsp.RandomElements[gsp.currentLevel] :=
          gsp.RandomElements[gsp.currentLevel]+1;   
      if GenSift.HasOrderIn(PseudoRandomSLP(grp), ismember.orders, 
                                                  ismember.ordersslp) then
          return false;
      fi;
      n := n + One(n);
  until n >= N;
  return true;
end);

InstallGlobalFunction( IsMemberConjugates, function( ismember, grp, z, e )
  # Tests, whether z is in C_{grp}(sr.a) * grp or equivalently,
  #        whether a^z is in grp
  # This uses the "ismember" subrecord in its own ismember record.
  local gsp;
  gsp := GeneralizedSiftProfile;
  gsp.Multiplications[gsp.currentLevel] := 
      gsp.Multiplications[gsp.currentLevel]+2;
  gsp.Inversions[gsp.currentLevel] := 
      gsp.Inversions[gsp.currentLevel]+1;
  return ismember.ismember.method(ismember.ismember,grp,
                                  z^-1 * ismember.a * z,e);
end);

InstallGlobalFunction( IsMemberIsOne, function( ismember, grp, z, e )
  if GenSift.IsOne(z) then
      return true;
  else
      return false;
  fi;
end);

InstallGlobalFunction( IsMemberCentralizer, function( ismember, grp, z, e )
  local g,gsp;

  gsp := GeneralizedSiftProfile;

  # This is deterministic. ismember.centof must be a list of group elements.
  for g in ismember.centof do
      gsp.Multiplications[gsp.currentLevel] :=
          gsp.Multiplications[gsp.currentLevel]+2;
      if not(GenSift.IsEq(g * z,z * g)) then
          return false;
      fi;
  od;
  return true;
end);

InstallGlobalFunction( IsMemberCentralizers, function( ismember, grp, z, e )
  local g,gsp,i;

  gsp := GeneralizedSiftProfile;

  # This is deterministic. ismember.centof must be a list of group elements.
  for i in [1..Length(ismember.centof)] do
      g := ismember.centof[i];
      gsp.Multiplications[gsp.currentLevel] :=
          gsp.Multiplications[gsp.currentLevel]+2;
      if GenSift.IsEq(g * z,z * g) then
          return i;
      fi;
  od;
  return false;
end);

InstallGlobalFunction( IsMemberNormalizerOfCyclicSubgroup,
function( ismember, grp, z, e )
  local y,gsp;
  # This is deterministic. ismember.generator must be the generator of
  # the cyclic subgroup and ismember.conjugates must be its conjugates
  # (other than the generator itself).

  gsp := GeneralizedSiftProfile;
  gsp.Multiplications[gsp.currentLevel] :=
      gsp.Multiplications[gsp.currentLevel]+2;
  gsp.Inversions[gsp.currentLevel] := 
      gsp.Inversions[gsp.currentLevel]+1;

  y := z^-1 * ismember.generator * z;
  return GenSift.IsEq(y,ismember.generator) or 
         ForAny(ismember.conjugates,x->GenSift.IsEq(x,y));
end);

InstallGlobalFunction( IsMemberNormalizer, function( ismember, grp, z, e)
  # This is deterministic. ismember.generators must be a list of generators
  # of the subgroup and ismember.conjugates must be its conjugates (including
  # the generators itself)
  local i,y,zi,gsp;

  gsp := GeneralizedSiftProfile;
  gsp.Inversions[gsp.currentLevel] := 
      gsp.Inversions[gsp.currentLevel]+1;

  zi := z^-1;
  for i in ismember.generators do
      gsp.Multiplications[gsp.currentLevel] :=
          gsp.Multiplications[gsp.currentLevel]+2;
      y := zi * i * z;
      if not(y in ismember.conjugates) then
          return false;
      fi;
  od;
  return true;
end);

InstallGlobalFunction( IsMemberWithSetConjugating,
function( ismember, grp, z, e )
  #Input ismember tests if z is in K. We have a set T.
  #return false if z not in {Kt^(-1): t in T}
  #return true if z in K
  #return i if zT[i] in K

  local i,l,T,gsp;
 
  gsp := GeneralizedSiftProfile;

  T:=ismember.extraels;
  if ismember.ismember.method(ismember.ismember, grp, z, e) then
      return true;
  else
      l:=Length(T);
      for i in [1..l] do
          gsp.Multiplications[gsp.currentLevel] :=
              gsp.Multiplications[gsp.currentLevel]+2;
          gsp.Inversions[gsp.currentLevel] := 
              gsp.Inversions[gsp.currentLevel]+1;
          if ismember.ismember.method(ismember.ismember,grp,
             T[i]^-1*z*T[i],e) then
              return i;
          fi;
      od;
  fi;
  return false;
end); 

InstallGlobalFunction( IsMemberWithSet, function( ismember, grp, z, e )
  #Input ismember tests if z is in K. We have a set T.
  #return false if z not in {Kt^(-1): t in T}
  #return true if z in K
  #return i if zT[i] in K

  local i,l,T,gsp;
 
  gsp := GeneralizedSiftProfile;

  T:=ismember.extraels;
  if ismember.ismember.method(ismember.ismember, grp, z, e) then
      return true;
  else
      l:=Length(T);
      for i in [1..l] do
          gsp.Multiplications[gsp.currentLevel] :=
              gsp.Multiplications[gsp.currentLevel]+1;
          if  ismember.ismember.method(ismember.ismember,grp,z*T[i],e) then
              return i;
          fi;
      od;
  fi;
  return false;
end); 


InstallGlobalFunction( IsMemberSet, function(ismember,grp,z,e)
  return (z in ismember.set);
end); 


InstallGlobalFunction( IsMemberSetWithExtraEls, function(ismember,grp,z,e)
  local p;
  p := Position(ismember.set,z);
  if p = fail then
      return false;
  else
      return p;
  fi;
end);


###########################################################################
# Here comes the main function:
###########################################################################

InstallGlobalFunction( GeneralizedSift, function(sr, x, eps)
  local i,j,l,nrrand,xx,y,gsp,ret;

  gsp := GeneralizedSiftProfile;

  l := Length(sr);
  if Length(gsp.Multiplications) <> l then
      Info(InfoGenSift,1,"Reset profile because length did not match!");
      ResetGeneralizedSiftProfile(l);
  fi;

  gsp.GeneralizedSiftCalls := gsp.GeneralizedSiftCalls+1;

  if not(IS_MACFLOAT(eps)) then eps := FLOAT_RAT(eps); fi;
  # First determine the number of randomized tests:
  nrrand := 0;
  for i in [1..l] do
      if not(sr[i].isdeterministic) then
          nrrand := nrrand+1;
      fi;
  od;
  y := [];
  xx := x;
  i := 1;
  while i <= l do

      gsp.currentLevel := i;
      PseudoRandomSLPMultiplications := 0;

      y[i] := sr[i].basicsift( sr, i, xx, eps/MACFLOAT_INT(nrrand) );
      if SIFT_VERBOSITY >= 1 then Print(i,"\c"); fi;

      gsp.RandomElementsMults[i] := gsp.RandomElementsMults[i] +
                  PseudoRandomSLPMultiplications;

      if y[i] = fail then
          if SIFT_VERBOSITY >= 1 then Print("\n"); fi;
          Info(InfoGenSift,1,"GeneralizedSift: FAILURE!");
          return y;
      fi;
      xx := y[i].new;

      # Did we have a special action?
      if IsBound(y[i].action) then
          if y[i].action = "EXIT" then
              # in this case, y is shorter than originally intended!
              i := l+1;
          elif y[i].action = "GOTO" then
              # We jump to step y[i].to:   (only forward jumps are allowed!)
              i := y[i].to;
          else
              i := i + 1;     # like without specialaction
          fi;
      else
          i := i + 1;      # no specialaction
      fi;
  od;
  if SIFT_VERBOSITY >= 1 then Print("\n"); fi;
  # Now xx must be the identity!
  if not(GenSift.IsOne(xx)) then
      # Note that this cannot happen, if the last basic sift step is
      # deterministic!
      Add(y,fail);
      Info(InfoGenSift,1,"GeneralizedSift: FAILURE!");
  else
      Info(InfoGenSift,1,"GeneralizedSift: SUCCESS!");
  fi;
  return y;
end);

InstallGlobalFunction( TestGeneralizedSift, function(sr, g, eps, n)
  # Does a statistical test by generating pseudo random elements in g and
  # sifting them, altogether n times, each with error probability smaller
  # or equal than eps. The result is a vector of length Length(sr)+3.
  # The numbers in there are numbers of results. The first Length(sr)+1
  # entries count failures in the corresponding steps, Length(sr)+1 meaning,
  # that in the final test the result was not the identity.
  # The number at position Length(sr)+2 is the number of successes and
  # the last number the percentage of failures.
  local i,l,x,y;
  l := ListWithIdenticalEntries(Length(sr)+2,0);
  for i in [1..n] do
      x := PseudoRandom(g);
      y := GeneralizedSift(sr,x,eps);
      if y[Length(y)] = fail then
          l[Length(y)] := l[Length(y)]+1;   # this is the step that failed
      else
          l[Length(sr)+2] := l[Length(sr)+2] + 1;
      fi;
  od;
  Add(l,MACFLOAT_INT(n-l[Length(sr)+2])/MACFLOAT_INT(n));
  return l;
end);

InstallGlobalFunction( CheckSLPOfResult, function(srl,g,y)
  # Just checks, whether the SLP output of GeneralizedSift is correct:
  local i,x,slp;
  for i in [1..Length(y)] do
      if y[i] = fail then
          Print("GeneralizedSift had failed, no point to check!\n");
          return fail;
      fi;
  od;
  slp := MakeCompleteSLP(srl,y);
  x := ResultOfStraightLineProgram(slp,GeneratorsOfGroup(g));
  if not(GenSift.IsEq(x,Product(y,i->i.el))) then
      Print("Error in SLP!");
      return false;
  fi;
  return true;
end);

InstallGlobalFunction( ShortSift, function(sr, x, eps)
  local gsp,l,nrrand,y,xx,i;

  gsp := GeneralizedSiftProfile;

  l := Length(sr);
  if Length(gsp.Multiplications) <> l then
      Info(InfoGenSift,1,"Reset profile because length did not match!");
      ResetGeneralizedSiftProfile(l);
  fi;

  if not(IS_MACFLOAT(eps)) then eps := FLOAT_RAT(eps); fi;
  # First determine the number of randomized tests:
  nrrand := 0;
  for i in [1..l] do
      if not(sr[i].isdeterministic) then
          nrrand := nrrand+1;
      fi;
  od;
  y := [];
  xx := x;
  i := 1;
  while i <= l do
      gsp.currentLevel := i;

      y[i] := BasicSiftShort( sr, i, xx, eps/MACFLOAT_INT(nrrand) );
      if SIFT_VERBOSITY >= 1 then Print(i,"\c"); fi;

      xx := y[i].new;

      # Did we have a special action?
      if IsBound(y[i].action) then
          if y[i].action = "EXIT" then
              # in this case, y is shorter than originally intended!
              i := l+1;
          elif y[i].action = "GOTO" then
              # We jump to step y[i].to:   (only forward jumps are allowed!)
              i := y[i].to;
          else
              i := i + 1;     # like without specialaction
          fi;
      else
          i := i + 1;      # no specialaction
      fi;
  od;
  if SIFT_VERBOSITY >= 1 then Print("\n"); fi;
  # Now xx must be the identity!
  if not(GenSift.IsOne(xx)) then
      # Note that this cannot happen, if the last basic sift step is
      # deterministic!
      Add(y,fail);
      Info(InfoGenSift,1,"GeneralizedSift: FAILURE!");
  else
      Info(InfoGenSift,1,"GeneralizedSift: SUCCESS!");
  fi;
  return y;
end);


GenSift.NeededSLPs := function(srl,lev)
  # lev is a level
  local needed;
  needed := [];
  if lev = 1 then
      return [];
  elif IsBound(srl[lev].groupSLP) then
      AddSet(needed,[lev,1]);
      return Union(needed,GenSift.NeededSLPs(srl,srl[lev].groupSLP[2]));
  else
      AddSet(needed,[lev-1,2]);
      return Union(needed,GenSift.NeededSLPs(srl,lev-1));
  fi;
end; 

GenSift.UsedSlotsAndResultSLP := function(slp)
  local used,l,i,li,res;
  used := [];
  for i in [1..NrInputsOfStraightLineProgram(slp)] do
      used[i] := 1;
  od;
  l := LinesOfStraightLineProgram(slp);
  for li in l do
      if IsInt(li[1]) then   # this is case 1: an associative word
          Add(used,1);
          res := Length(used);
      elif Length(li) = 2 and IsList(li[1]) and IsInt(li[2]) then
          # this is case 2: an associative word with target slot
          used[li[2]] := 1;
          res := li[2];
      else   # the final result
          return [Length(used),li];
      fi;
  od;
  return [Length(used),res];
end;

InstallGlobalFunction( MakeCompleteSLP, function(srl,y)
  # computes one (reasonably efficient SLP) to make the element:
  local isfirst,CopyDownInputs,maxslot,needed,i,j,x,p,l,ll,resultpos,
        slp,nrresults,nrgens,res,CopySLP;

  isfirst := true;   # this is changed in the following function:

  CopyDownInputs := function(srl,resultpos,lev)
      # changes l in outside function
      local i;
      if lev > 1 then   # not from the top, so copy previous results down:
          if IsBound(srl[lev].groupSLP) then
              for i in [1..resultpos[lev][1][2]] do
                  Add(l,[[i+resultpos[lev][1][1],1],i]);
              od;
          else
              for i in [1..resultpos[lev-1][2][2]] do
                  Add(l,[[i+resultpos[lev-1][2][1],1],i]);
              od;
          fi;
          isfirst := false;
      else   # from the top:
          if not(isfirst) then
              isfirst := false;
              for i in [1..resultpos[1][1][2]] do
                  Add(l,[[i+resultpos[1][1][1],1],i]);
              od;
          fi;
      fi;
  end;
  
  CopySLP := function(slp)
    # modifies outside l, assumes inputs in place
    local ll,maxused,li,lastused,i;

    ll := LinesOfStraightLineProgram(slp);
    maxused := NrInputsOfStraightLineProgram(slp);
    lastused := 0;
    for i in [1..Length(ll)] do
        li := ll[i];
        if IsInt(li[1]) then    # an associatice word
            maxused := maxused+1;
            Add(l,[li,maxused]);
            lastused := maxused;
        elif Length(li) = 2 and IsList(li[1]) and IsInt(li[2]) then
            Add(l,li);
            if li[2] > maxused then maxused := li[2]; fi;
            lastused := li[2];
        else
            return li;   # return result vector
        fi;
    od;
    return lastused;
  end;

  maxslot := 0;
  needed := [];
  for i in [1..Length(y)] do
      if IsBound(y[i]) then
          for j in [1..Length(y[i].slp)] do
              ll := LinesOfStraightLineProgram(y[i].slp[j][1]);
              if ll <> [[1,0]] then
                  needed := Union(needed,
                                  GenSift.NeededSLPs(srl,y[i].slp[j][2]));
                  x := GenSift.UsedSlotsAndResultSLP(y[i].slp[j][1]);
                  if x[1] > maxslot then maxslot := x[1]; fi;
              fi;
          od;
      fi;
  od;
  for p in needed do
      if p[2] = 1 then  # the groupSLP
          x := GenSift.UsedSlotsAndResultSLP(srl[p[1]].groupSLP[1]);
          if x[1] > maxslot then maxslot := x[1]; fi;
      else   # the subgpSLP
          x := GenSift.UsedSlotsAndResultSLP(srl[p[1]].subgpSLP);
          if x[1] > maxslot then maxslot := x[1]; fi;
      fi;
  od;
  l := [];   # here we collect our SLP
  nrgens := Length(GeneratorsOfGroup(srl[1].group));
  # we store where the intermediate results are:
  resultpos := List([1..Length(srl)],x->[]);
  # We assume the original generators for the top level to be in the
  # first few slots. Also there will be a needed SLP using them:
  # As result of srl[1].groupSLP we consider the original generators:
  resultpos[1][1] := [maxslot,nrgens];
  # We copy the original generators up:
  for i in [1..nrgens] do
      Add(l,[[i,1],maxslot+i]);
  od;
  maxslot := maxslot + nrgens;
  for p in needed do
      if p[2] = 1 then
          slp := srl[p[1]].groupSLP;
      else
          slp := [srl[p[1]].subgpSLP,p[1]];
      fi;
      # Copy down inputs:
      CopyDownInputs(srl,resultpos,slp[2]);
      # Now copy SLP:
      ll := LinesOfStraightLineProgram(slp[1]);
      res := CopySLP(slp[1]);
      if IsInt(res) then   # one single result
          resultpos[p[1]][p[2]] := [maxslot,1];
          Add(l,[[res,1],maxslot+1]);
          maxslot := maxslot + 1;
      else
          resultpos[p[1]][p[2]] := [maxslot,Length(res)];
          for i in [1..Length(res)] do
              Add(l,[res[i],maxslot+i]);
          od;
          maxslot := maxslot + Length(res);
      fi;
  od;
  nrresults := 0;
  for i in [1..Length(y)] do
      if IsBound(y[i]) then
          for j in [1..Length(y[i].slp)] do
              ll := LinesOfStraightLineProgram(y[i].slp[j][1]);
              if ll <> [[1,0]] then
                  CopyDownInputs(srl,resultpos,y[i].slp[j][2]);
                  # Now copy SLP:
                  res := CopySLP(y[i].slp[j][1]);
                  nrresults := nrresults+1;
                  Add(l,[[res,1],maxslot+nrresults]);
              fi;
          od;
      fi;
  od;
  # Finally form the product:
  ll := [];
  for i in [1..nrresults] do
      Add(ll,maxslot+i);
      Add(ll,1);
  od;
  Add(l,[ll,1]);
  return StraightLineProgramNC(l,nrgens);
end);
  
#############################################################################
# Data structures for sift:
#############################################################################

InstallValue( PreSift, rec());   # Here we store all the data

