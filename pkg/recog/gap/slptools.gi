#############################################################################
##
##  slptools.gi        recog package                      Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2005 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  Some additional things for straight line programs.
##
##  $Id: slptools.gi,v 1.12 2005/12/17 12:46:14 gap Exp $
##
#############################################################################


InstallGlobalFunction( SLPChangesSlots,
  function(l,nrinps)
    # l must be the lines of an slp, nrinps the number of inputs.
    # changes must be an empty list. This function changes changes to
    # Returns a list with the same length than l, containing at each position
    # the number of the slot that is changed in the corresponding line of the
    # slp. In addition one more number is appended to the list, namely the
    # number of the biggest slot used.
    local biggest,changes,i,line;
    changes := [];   # a list of integers for each line of the slp, which
                     # says, which element is changed
    biggest := nrinps;
    for i in [1..Length(l)] do
        line := l[i];
        if IsInt(line[1]) then   # the first case
            biggest := biggest + 1;
            Add(changes,biggest);
        elif Length(line) = 2 and IsInt(line[2]) then
            # the second case, provided that we have not been in the first
            Add(changes,line[2]);
            if line[2] > biggest then
                biggest := line[2];
            fi;
        elif i < Length(l) then
            Error( "Bad line in slp: ",i );
        else
            Add(changes,0); 
            # the last line does not change anything in this case
        fi;
    od;
    Add(changes,biggest);
    return changes;
  end);

InstallGlobalFunction( SLPOnlyNeededLinesBackward,
  function(l,i,nrinps,changes,needed,slotsused,ll)
    # l is a list of lines of an slp, nrinps the number of inputs.
    # i is the number of the last line, that is not a line of type 3 (results).
    # changes is the result of SLPChangesSlots for that slp.
    # needed is a list, where those entries are bound to true that are
    # needed in the end of the slp. slotsused is a list that should be
    # initialized with [1..nrinps] and which contains in the end the set
    # of slots used.
    # ll is any list.
    # This functions goes backwards through the slp and adds exactly those 
    # lines of the slp to ll that have to be executed to produce the
    # result (in backward order). All lines are transformed into type 2
    # lines ([assocword,slot]). Note that needed is changed underways.
    local j,line;
    while i >= 1 do
        if IsBound(needed[changes[i]]) then
            AddSet(slotsused,changes[i]);   # this slot will be used
            Unbind(needed[changes[i]]);     # as this line overwrites it,
                         # the previous result obviously was no longer needed
            line := l[i];
            if IsInt(line[1]) then
                Add(ll,[ShallowCopy(line),changes[i]]);
            else
                Add(ll,[ShallowCopy(line[1]),line[2]]);   # copy the line
                line := line[1];
            fi;
            for j in [1,3..Length(line)-1] do
                needed[line[j]] := true;
            od;
        fi;
        i := i - 1;
    od;
  end);

InstallGlobalFunction( SLPReversedRenumbered,
  function(ll,slotsused,nrinps,invtab)
    # invtab must be an empty list and is modified!
    local biggest,i,kk,kl,lll,resultslot;
    for i in [1..Length(slotsused)] do
        invtab[slotsused[i]] := i;
    od;
    lll := [];  # here we collect the final program
    biggest := nrinps;
    for i in [Length(ll),Length(ll)-1 .. 1] do
        resultslot := invtab[ll[i][2]];
        if resultslot = biggest+1 then   # we can use a type 1 line
            kl := [];
            for kk in [1,3..Length(ll[i][1])-1] do
                Add(kl,invtab[ll[i][1][kk]]);
                Add(kl,ll[i][1][kk+1]);
            od;
            Add(lll,kl);
            biggest := biggest + 1;
        else
            kl := [];
            for kk in [1,3..Length(ll[i][1])-1] do
                Add(kl,invtab[ll[i][1][kk]]);
                Add(kl,ll[i][1][kk+1]);
            od;
            Add(lll,[kl,resultslot]);
            if resultslot > biggest then
                biggest := resultslot;
            fi;
        fi;
    od;
    return lll;
  end);

InstallGlobalFunction( RestrictOutputsOfSLP,
  function(slp,k)
    # Returns a new slp that calculates only those outputs specified by
    # k. k may be an integer or a list of integers. If k is an integer,
    # the resulting slp calculates only the result with that number. 
    # If k is a list of integers, the resulting slp calculates those
    # results with numbers in k. In both cases the resulting slp
    # does only, what is necessary. The slp must have a line with at least
    # k expressions (lists) as its last line.
    # slp is either a slp or a pair where the first entry are the lines
    # of the slp and the second is the number of inputs.
    # This assumes general straight line programs (with overwriting of slots).
    # If you know that your SLPs do not overwrite slots, then use
    # "RestrictOutputsOfSLPWithoutOverwrite" which is much faster in this case!
    local biggest,changes,i,invtab,j,kk,kkl,kl,klist,l,lastline,line,ll,lll,n,
          needed,nrinps,slotsused;

    if IsInt(k) then
        klist := [k];
    else
        klist := k;
    fi;

    if IsStraightLineProgram(slp) then
        l := LinesOfStraightLineProgram( slp );
        nrinps := NrInputsOfStraightLineProgram( slp );
    else
        l := slp[1];
        nrinps := slp[2];
    fi;
    # The following has to be done, because the SLP might overwrite its
    # intermediate results:
    changes := SLPChangesSlots(l,nrinps);
    biggest := changes[Length(changes)];
    ll := [];   # Here we collect the lines of the result, but reversed
    slotsused := [1..nrinps];   # set of slots used at all
    needed := [];  # here we mark the needed entries for the rest of the prog.
    i := Length(l);
    if IsInt(k) then
        if Length(l[i]) < k or not(IsList(l[i][k])) then
            Error("slp does not have result number ",k);
        fi;
        line := l[i][k];
        for j in [1,3..Length(line)-1] do
            needed[line[j]] := true;
        od;
        if Length(line) > 2 or (Length(line)=2 and line[2] <> 1) then
            ll[1] := [ShallowCopy(line),biggest+1];
            AddSet(slotsused,biggest+1);
        fi;   
        lastline := fail;
        # if Length(line)=2 and line[2]=1 then the last result is the result
    else   # a list of results:
        lastline := [];  # Here we collect results
        for n in klist do
            line := l[i][n];
            for j in [1,3..Length(line)-1] do
                needed[line[j]] := true;
            od;
            Add(lastline,ShallowCopy(line));
        od;
    fi;
    
    SLPOnlyNeededLinesBackward(l,i-1,nrinps,changes,needed,slotsused,ll);
    # Now we have the program in reversed order in ll. The slots used
    # during that calculation are in slotsused. We want to renumber
    # them from [1..Length(slotsused)]:
    invtab := [];
    lll := SLPReversedRenumbered(ll,slotsused,nrinps,invtab);
    if lastline <> fail then
        # Add the results line:
        kkl := [];
        for j in lastline do
            kl := [];
            for kk in [1,3..Length(j)-1] do
                Add(kl,invtab[j[kk]]);
                Add(kl,j[kk+1]);
            od;
            Add(kkl,kl);
        od;
        Add(lll,kkl);
    fi;
    if Length(lll) = 0 then  # One of the original generators!
        if IsList(k) then
            ll := [];
            for i in k do
                Add(ll,[i,1]);
            od;
            return StraightLineProgramNC([ll],nrinps);
        else
            return StraightLineProgramNC([[k,1]],nrinps);
        fi;
    else
       return StraightLineProgramNC(lll, nrinps);
    fi;
  end);

InstallGlobalFunction( IntermediateResultOfSLP,
  function(slp,k)
    # Returns a new slp that calculates only the value of slot k
    # at the end of slp doing only, what is necessary. 
    # slp is either a slp or a pair where the first entry are the lines
    # of the slp and the second is the number of inputs.
    # Note that this assumes a general SLP with possible overwriting.
    # If you know that your SLP does not overwrite slots, please use
    # "IntermediateResultOfSLPWithoutOverwrite", which is much faster in this
    # case.
    local biggest,changes,i,invtab,j,kk,kl,l,line,ll,lll,needed,nrinps,
          resultslot,slotsused;

    if IsStraightLineProgram(slp) then
        l := LinesOfStraightLineProgram( slp );
        nrinps := NrInputsOfStraightLineProgram( slp );
    else
        l := slp[1];
        nrinps := slp[2];
    fi;
    # The following has to be done, because the SLP might overwrite its
    # intermediate results:
    changes := SLPChangesSlots(l,nrinps);
    biggest := changes[Length(changes)];
    slotsused := [1..nrinps];   # set of slots used at all
    needed := [];  # here we mark the needed entries for the rest of the prog.
    needed[k] := true; 
    # we are interested only in the value of slot k in the end
    ll := [];   # Here we collect the lines of the result, but reversed
    i := Length(l);
    if changes[i] = 0 then   # we are not interested in a result line
        i := i - 1;
    fi;
    SLPOnlyNeededLinesBackward(l,i,nrinps,changes,needed,slotsused,ll);
    if Length(ll) = 0 or not(k in slotsused) then
        # the slot was never assigned!
        Error("Slot not used in SLP!");
    fi;
    # Now we have the program in reversed order in ll. The slots used
    # during that calculation are in slotsused. We want to renumber
    # them from [1..Length(slotsused)]:
    invtab := [];
    lll := SLPReversedRenumbered(ll,slotsused,nrinps,invtab);
    return StraightLineProgramNC(lll, nrinps);
    #  TO BE DEBUGGED HERE
  end);
              
InstallGlobalFunction( IntermediateResultsOfSLPWithoutOverwriteInner,
  function(slp,k)
    # Only used internally.
    local i,invtab,j,kk,kl,l,line,ll,lll,m,needed,nrinps,nrslotsused,slotsused;

    if IsStraightLineProgram(slp) then
        l := LinesOfStraightLineProgram( slp );
        nrinps := NrInputsOfStraightLineProgram( slp );
    else
        l := slp[1];
        nrinps := slp[2];
    fi;
    m := Maximum(k);
    needed := Set(k);
              # here we note the needed entries for the rest of the prog.
    ll := [];   # Here we collect the lines of the result, but reversed
    slotsused := [];   # here we collect a (reversed) list of slots used
    while Length(needed) > 0 do
        i := needed[Length(needed)];
        if i > nrinps then
            Add(slotsused,i);   # this slot is used
            line := l[i-nrinps];
            # We know that all lines are plain lists of integers!
            Add(ll,line);
            for j in [1,3..Length(line)-1] do
                AddSet(needed,line[j]);
            od;
        fi;
        Unbind(needed[Length(needed)]);
    od;
    # Now we have the program in reversed order in ll. The slots used
    # during that calculation are in slotsused. We want to renumber
    # them from [1..Length(slotsused)]:
    if Length(slotsused) > 0 then
        invtab := ListWithIdenticalEntries(slotsused[1],0);
    else
        invtab := [];
    fi;
    nrslotsused := Length(slotsused);
    for i in [1..nrslotsused] do
        invtab[slotsused[i]] := nrinps+nrslotsused+1-i;
    od;
    for i in [1..nrinps] do
        invtab[i] := i;
    od;
    lll := [];  # here we collect the final program
    for i in [Length(ll),Length(ll)-1 .. 1] do
        kl := [];
        for kk in [1,3..Length(ll[i])-1] do
            Add(kl,invtab[ll[i][kk]]);
            Add(kl,ll[i][kk+1]);
        od;
        Add(lll,kl);
    od;
    return [nrinps,invtab,lll];
  end);

InstallGlobalFunction( IntermediateResultsOfSLPWithoutOverwrite, 
  function(slp,k)
    # Returns a new slp that calculates only the value of slots contained
    # in the list k.
    # Note that SLP must not overwrite slots but only append!!!
    # Use IntermediateResultOfSLP in the other case!
    # slp is either a slp or a pair where the first entry are the lines
    # of the slp and the second is the number of inputs.
    local i,invtab,line,lll,nrinps,r;

    # Call the real code:
    r := IntermediateResultsOfSLPWithoutOverwriteInner(slp,k);
    nrinps := r[1];
    invtab := r[2];
    lll := r[3];

    # Construct the last line:
    line := [];
    for i in k do
        if i = 0 then
            Add(line,[1,0]);
        else
            Add(line,[invtab[i],1]);
        fi;
    od;
    Add(lll,line);  # the result

    return StraightLineProgramNC(lll, nrinps);
  end);

InstallGlobalFunction( IntermediateResultOfSLPWithoutOverwrite,
  function(slp,k)
    # Returns a new slp that calculates only the value of slot k.
    # Note that SLP must not overwrite slots but only append!!!
    # Use IntermediateResultOfSLP in the other case!
    # slp is either a slp or a pair where the first entry are the lines
    # of the slp and the second is the number of inputs.
    local r;
    r := IntermediateResultsOfSLPWithoutOverwriteInner(slp,[k]);
    if k = 0 then
        return StraightLineProgramNC([[1,0]],r[1]);
    elif k <= r[1] then   # a generator
        return StraightLineProgramNC([[k,1]], r[1]);
    else
        return StraightLineProgramNC(r[3], r[1]);
    fi;
  end);
              
InstallGlobalFunction( ProductOfStraightLinePrograms,
  function(s1,s2)
    # s1 and s2 must be two slps that return a single element with the same
    # number of inputs. This function contructs an slp that returns the result
    # s1(g_1,...,g_n) * s2(g_1,...,g_n) for all possible inputs g_1,...,g_n
    local biggest,biggest2,biggest3,changes,changes2,i,j,l,l1,l2,l3,line,
          newline,nrinps;

    l1 := ShallowCopy(LinesOfStraightLineProgram(s1));
    l2 := LinesOfStraightLineProgram(s2);
    nrinps := NrInputsOfStraightLineProgram(s1);
    if nrinps <> NrInputsOfStraightLineProgram(s2) then
        Error("s1 and s2 do not have the same number of inputs!");
    fi;
    l := Length(l1);
    # we have to run through s1 to see how many slots are produced:
    changes := SLPChangesSlots(l1,nrinps);
    biggest := changes[Length(changes)];
    changes2 := SLPChangesSlots(l2,nrinps);
    biggest2 := changes2[Length(changes2)];
    biggest3 := Maximum(biggest,biggest2);
    # First we make a copy of the original generators:
    l3 := [];
    for i in [1..nrinps] do
        Add(l3,[[i,1],biggest3+i]);
    od;
    # Now make a copy of l1, we have to use lines of type 2:
    for i in [1..Length(l1)] do
        line := l1[i];
        if IsInt(line[1]) then   # a line without overwriting
            newline := [ShallowCopy(line),changes[i]];
        else   # a line with overwriting
            newline := [ShallowCopy(line[1]),line[2]];
        fi;
        Add(l3,newline);
    od;
    # Copy result up:
    Add(l3,[[changes[Length(l1)],1],biggest3+nrinps+1]);
    # Now append the second program, change low slots to high ones:
    for i in [1..Length(l2)] do
        line := l2[i];
        if not(IsInt(line[1])) then
            line := line[1];
        fi;
        newline := [];
        for j in [1,3..Length(line)-1] do
            if line[j] > nrinps then
                Add(newline,line[j]);
            else
                Add(newline,line[j]+biggest3);
            fi;
            Add(newline,line[j+1]);
        od;
        if changes2[i] <= nrinps then
            Add(l3,[newline,changes2[i]+biggest3]);
        else
            Add(l3,[newline,changes2[i]]);
        fi;
    od;
    # the result of s2 is now in slot results2
    if changes2[Length(l2)] <= nrinps then
        Add(l3,[biggest3+nrinps+1,1,changes2[Length(l2)]+biggest3,1]);
    else
        Add(l3,[biggest3+nrinps+1,1,changes2[Length(l2)],1]);
    fi;
    return StraightLineProgramNC(l3,nrinps);
  end);
 
InstallGlobalFunction( RewriteStraightLineProgram,
function(s,l,lsu,inputs,tabuslots)
  # Purpose: Append the slp s to the one currently built in l.
  # The prospective inputs are already standing somewhere and some
  # slots may not be used by the new copy of s within l.
  #
  # s must be a GAP straight line program
  # l must be a mutable list making the beginning of a straight line program
  # without result line so far. lsu must be the largest used slot of the
  # slp in l so far. inputs is a list of slot numbers, in which the
  # inputs are, that the copy of s in l should work on, that is, its length
  # must be equal to the number of inputs s taks. tabuslots is a list of
  # slot numbers which will not be overwritten by the new copy of s in l.
  # Changes l and returns a record with components "l" being l, "results" being
  # a list of slot numbers, in which the results of s are stored in the end
  # and "lsu" being the number of the largest slot used by l up to now.
  local FindNextNew,TranslateAssocWord,i,j,li,line,max,newline,newwrite,
        nextnew,nrinps,oldwrite,res,results,trans;

  FindNextNew := function(nextnew)
    repeat
      nextnew := nextnew + 1;
    until not(nextnew in tabuslots or nextnew in inputs);
    return nextnew;
  end;

  TranslateAssocWord := function(assocword)
    local i,new;
    new := ShallowCopy(assocword);
    for i in [1,3..Length(assocword)-1] do
        new[i] := trans[new[i]];
    od;
    return new;
  end;

  li := LinesOfStraightLineProgram(s);
  nrinps := NrInputsOfStraightLineProgram(s);
  if nrinps <> Length(inputs) then
      Error("inputs must be a list of the same length as the inputs of s");
      return fail;
  fi;
  tabuslots := Set(tabuslots);
  trans := ShallowCopy(inputs);   # we start with this translation
  max := nrinps;
  nextnew := FindNextNew(0);
  results := [0];

  for i in [1..Length(li)] do
      line := li[i];
      if IsInt(line[1]) then   # a line without a writing position
          newline := TranslateAssocWord(line);
          oldwrite := max+1;
          max := max + 1;
      elif Length(line) = 2 and IsInt(line[2]) then
          # a line with a writing position
          newline := TranslateAssocWord(line[1]);
          oldwrite := line[2];
          if line[2] > max then
              max := line[2];
          fi;
      else
          # First see whether the result line just has powers 1:
          if ForAll(line,x->Length(x) = 2 and x[2] = 1) then
              results := List(line,x->trans[x[1]]);
          else
              # the result line, we write to the next few free entries:
              for j in [1..Length(line)] do
                  res := TranslateAssocWord(line[j]);
                  newwrite := nextnew;
                  nextnew := FindNextNew(nextnew);
                  results[j] := newwrite;
                  if newwrite = lsu+1 then
                      Add(l,res);
                      lsu := lsu + 1;
                  else
                      Add(l,[res,newwrite]);
                      if newwrite > lsu then
                          lsu := newwrite;
                      fi;
                  fi;
              od;
          fi;
          break;  # do not do the rest of the loop
      fi;
      # we would write to newwrite:
      if not(IsBound(trans[oldwrite])) or trans[oldwrite] in tabuslots then
          trans[oldwrite] := nextnew;
          newwrite := nextnew;
          nextnew := FindNextNew(nextnew);
      else
          newwrite := trans[oldwrite];
      fi;
      results[1] := newwrite;
      if newwrite = lsu+1 then
          Add(l,newline);
          lsu := lsu + 1;
      else
          Add(l,[newline,newwrite]);
          if newwrite > lsu then
              lsu := newwrite;
          fi;
      fi;
  od;
  return rec(l := l,results := results,lsu := lsu);
end);

InstallGlobalFunction( NewCompositionOfStraightLinePrograms,
function(s2,s1)
  local l,la,nr,x,y;
  nr := NrInputsOfStraightLineProgram(s1);
  x := RewriteStraightLineProgram(s1,[],0,[1..nr],[]);
  y := RewriteStraightLineProgram(s2,x.l,x.lsu,x.results,[]);
  l := LinesOfStraightLineProgram(s2);
  la := l[Length(l)];
  if Length(la) < 2 or (IsList(la[1]) and IsList(la[2])) then
      # we have a return line, so add one:
      Add(y.l,List(y.results,z->[z,1]));
  fi;
  return StraightLineProgramNC(y.l,nr);
end);

InstallGlobalFunction( NewProductOfStraightLinePrograms,
function(s1,inputs1,s2,inputs2,newnrinputs)
  # s1 and s2 must be slps producing exactly one result (or a list of one
  # result). inputs1 and inputs2 must be lists of slot numbers, both as long
  # as the number of inputs of s1 and s2 respectively. A new straight line
  # program is generated with newnrinputs inputs, that calculates the product
  # of the result of s1, given the values in the slots inputs1 as inputs
  # and the result of s2, given the values in the slots inputs2 as inputs
  # inputs1 and inputs2 may overlap, in which case the first program 
  # might have to be rewritten, not to overwrite the inputs.
  local nr1,nr2,x,y;
  nr1 := NrInputsOfStraightLineProgram(s1);
  nr2 := NrInputsOfStraightLineProgram(s2);
  if nr1 <> Length(inputs1) or nr2 <> Length(inputs2) then
      Error("inputs1 and inputs2 must have the right number of entries");
      return fail;
  fi;
  x := RewriteStraightLineProgram(s1,[],0,inputs1,inputs2);
  y := RewriteStraightLineProgram(s2,x.l,x.lsu,inputs2,x.results);
  Add(y.l,[x.results[1],1,y.results[1],1]);
  return StraightLineProgramNC(y.l,newnrinputs);
end);
            

