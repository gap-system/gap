#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains method for combinatorics.
##


#############################################################################
##
#F  Factorial( <n> )  . . . . . . . . . . . . . . . . factorial of an integer
##
InstallGlobalFunction(Factorial, FACTORIAL_INT);


#############################################################################
##
#F  GaussianCoefficient( <n>, <k>, <q> ) . . . . . . . .  number of subspaces
##
InstallGlobalFunction(GaussianCoefficient,function ( n, k, q )
local   gc, i;
  if   k < 0 or n<0 or k>n  then
    return 0;
  else
    gc:=1;
    for i in [1..k] do
      gc:=gc*(q^(n-i+1)-1)/(q^i-1);
    od;
    return gc;
  fi;
end);


#############################################################################
##
#F  Binomial( <n>, <k> )  . . . . . . . . .  binomial coefficient of integers
##
InstallGlobalFunction(Binomial, BINOMIAL_INT);


#############################################################################
##
#F  Bell( <n> ) . . . . . . . . . . . . . . . . .  value of the Bell sequence
##
InstallGlobalFunction(Bell,function ( n )
    local   bell, k, i;
    bell := [ 1 ];
    for i  in [1..n-1]  do
        bell[i+1] := bell[1];
        for k  in [0..i-1]  do
            bell[i-k] := bell[i-k] + bell[i-k+1];
        od;
    od;
    return bell[1];
end);


#############################################################################
##
#F  Stirling1( <n>, <k> ) . . . . . . . . . Stirling number of the first kind
##
InstallGlobalFunction(Stirling1,function ( n, k )
    local   sti, i, j;
    if   n < k  then
        sti := 0;
    elif n = k  then
        sti := 1;
    elif n < 0 and k < 0  then
        sti := Stirling2( -k, -n );
    elif k <= 0  then
        sti := 0;
    else
        sti := [ 1 ];
        for j  in [2..n-k+1]  do
            sti[j] := 0;
        od;
        for i  in [1..k]  do
            sti[1] := 1;
            for j  in [2..n-k+1]  do
                sti[j] := (i+j-2) * sti[j-1] + sti[j];
            od;
        od;
        sti := sti[n-k+1];
    fi;
    return sti;
end);


#############################################################################
##
#F  Stirling2( <n>, <k> ) . . . . . . . .  Stirling number of the second kind
##
##  Uses $S_2(n,k) = (-1)^k \sum_{i=1}^{k}{(-1)^i {k \choose i} i^k} / k!$.
##
InstallGlobalFunction(Stirling2,function ( n, k )
    local   sti, bin, fib, i;
    if   n < k  then
        sti := 0;
    elif n = k  then
        sti := 1;
    elif n < 0 and k < 0  then
        sti := Stirling1( -k, -n );
    elif k <= 0  then
        sti := 0;
    else
        bin := 1;                       # (k 0)
        sti := 0;                       # (-1)^0 (k 0) 0^k
        fib := 1;                       # 0!
        for i  in [1..k]  do
            bin := (k-i+1)/i * bin;     # (k i) = (k-(i-1))/i (k i-1)
            sti := bin * i^n - sti;     # (-1)^i sum (-1)^j (k j) j^k
            fib := fib * i;             # i!
        od;
        sti := sti / fib;
    fi;
    return sti;
end);


#############################################################################
##
#F  Combinations( <mset> )  . . . . . .  set of sorted sublists of a multiset
##
##  'CombinationsA( <mset>, <m>,  <n>, <comb>, <i> )' returns  the set of all
##  combinations of the multiset <mset>, which has size  <n>, that begin with
##  '<comb>[[1..<i>-1]]'.  To do  this it finds  all elements of <mset>  that
##  can go at '<comb>[<i>]' and calls itself  recursively for each candidate.
##  <m>-1 is the position of '<comb>[<i>-1]' in <mset>, so the candidates for
##  '<comb>[<i>]' are exactly the elements 'Set( <mset>[[<m>..<n>]] )'.
##
##  'CombinationsK( <mset>, <m>, <n>, <k>, <comb>, <i>  )' returns the set of
##  all combinations  of the multiset <mset>,  which has size  <n>, that have
##  length '<i>+<k>-1', and that begin with '<comb>[[1..<i>-1]]'.  To do this
##  it finds  all elements of  <mset> that can go  at '<comb>[<i>]' and calls
##  itself recursively  for   each candidate.    <m>-1 is   the  position  of
##  '<comb>[<i>-1]'  in <mset>,  so  the  candidates  for '<comb>[<i>]'   are
##  exactly the elements 'Set( <mset>[<m>..<n>-<k>+1] )'.
##
##  'Combinations' only calls 'CombinationsA' or 'CombinationsK' with initial
##  arguments.
##
DeclareGlobalName( "CombinationsA" );
BindGlobal( "CombinationsA", function ( mset, m, n, comb, i )
    local   combs, l;
    if m = n+1  then
        comb  := ShallowCopy(comb);
        combs := [ comb ];
    else
        comb  := ShallowCopy(comb);
        combs := [ ShallowCopy(comb) ];
        for l  in [m..n]  do
            if l = m or mset[l] <> mset[l-1]  then
                comb[i] := mset[l];
                Append( combs, CombinationsA(mset,l+1,n,comb,i+1) );
            fi;
        od;
    fi;
    return combs;
end );

DeclareGlobalName( "CombinationsK" );
BindGlobal( "CombinationsK", function ( mset, m, n, k, comb, i )
    local   combs, l;
    if k = 0  then
        comb  := ShallowCopy(comb);
        combs := [ comb ];
    else
        combs := [];
        for l  in [m..n-k+1]  do
            if l = m or mset[l] <> mset[l-1]  then
                comb[i] := mset[l];
                Append( combs, CombinationsK(mset,l+1,n,k-1,comb,i+1) );
            fi;
        od;
    fi;
    return combs;
end );

InstallGlobalFunction(Combinations,function ( mset, arg... )
    local   combs;
    mset := ShallowCopy(mset);  Sort( mset );
    if Length(arg) = 0  then
        combs := CombinationsA( mset, 1, Length(mset), [], 1 );
    elif Length(arg) = 1  then
        combs := CombinationsK( mset, 1, Length(mset), arg[1], [], 1 );
    else
        Error("usage: Combinations( <mset> [, <k>] )");
    fi;
    return combs;
end);

#############################################################################
##
#F  IteratorOfCombinations( <mset>[, <k> ] )
#F  EnumeratorOfCombinations( <mset> )
##
InstallGlobalFunction(EnumeratorOfCombinations, function(mset)
  local c, max, l, mods, size, els, ElementNumber, NumberElement;
  c := Collected(mset);
  max := List(c, a-> a[2]);
  els := List(c, a-> a[1]);
  l := Length(max);
  mods := max+1;
  size := Product(mods);
  # a combination can contain els[i] from 0 to max[i] times (mods[i]
  # possibilities), we number the combination that contains a[i] times els[i]
  # for all i by n = 1 + sum_i a[i]*m[i] where m[i] = prod_(j<i) mods[i]
  ElementNumber := function(enu, n)
    local comb, res, i, j;
    if n > size then
      Error("Index ", n, " not bound.");
    fi;
    comb := EmptyPlist(l);
    n := n-1;
    for i in [1..l] do
      comb[i] := n mod mods[i];
      n := (n - comb[i])/mods[i];
    od;
    res := [];
    for i in [1..l] do
      for j in [1..comb[i]] do
        Add(res, els[i]);
      od;
    od;
    return res;
  end;
  NumberElement := function(enu, comb)
    local c, d, pos, n, a, i;
    if not IsList(comb) then
      return fail;
    fi;
    c := Collected(comb);
    d := 0*max;
    for a in c do
      pos := PositionSorted(els, a[1]);
      if not IsBound(els[pos]) or els[pos] <> a[1] or a[2] > max[pos] then
        return fail;
      else
        d[pos] := a[2];
      fi;
    od;
    n := 0;
    for i in [l,l-1..1] do
      n := n*mods[i] + d[i];
    od;
    return n+1;
  end;
  return EnumeratorByFunctions(ListsFamily, rec(
           ElementNumber := ElementNumber,
           NumberElement := NumberElement,
           els := els,
           Length := x->size,
           max := max));
end);

BindGlobal("NextIterator_Combinations_set", function(it)
  local res, comb, k, i, len;
  comb := it!.comb;
  if comb = fail then
    Error("No more elements in iterator.");
  fi;
  # first create combination to return
  res := it!.els{comb};
  # now construct indices for next combination
  len := it!.len;
  k := it!.k;
  for i in [1..k] do
    if i = k or comb[i]+1 < comb[i+1] then
      comb[i] := comb[i] + 1;
      comb{[1..i-1]} := [1..i-1];
      break;
    fi;
  od;
  # check if done
  if k = 0 or comb[k] > len then
    it!.comb := fail;
  fi;
  return res;
end);

# helper function to substitute elements described by r!.comb[j],
# j in [1..i] by smallest possible ones
BindGlobal("Distr_Combinations", function(r, i)
  local max, kk, l, comb, j;
  max := r!.max;
  kk := 0;
  l := Length(max);
  comb := r!.comb;
  for j in [1..i] do
    kk := kk + comb[j];
    comb[j] := 0;
  od;
  for i in [1..l] do
    if kk <= max[i] then
      comb[i] := kk;
      break;
    else
      comb[i] := max[i];
      kk := kk - max[i];
    fi;
  od;
end);
BindGlobal("NextIterator_Combinations_mset", function(it)
  local res, comb, l, els, i, j, max;
  if it!.comb = fail then
    Error("No more elements in iterator.");
  fi;
  comb := it!.comb;
  max := it!.max;
  l := Length(comb);
  # first create the combination to return, this is the time critical
  # code which is more efficient in the proper set case above
  res := EmptyPlist(it!.k);
  els := it!.els;
  for i in [1..l] do
    for j in [1..comb[i]] do
      Add(res, els[i]);
    od;
  od;
  # now find next combination if there is one;
  # for this find smallest element which can be substituted by the next
  # larger element and reset the previous ones to the smallest
  # possible ones
  i := 1;
  while i < l and (comb[i] = 0 or comb[i+1] = max[i+1]) do
    i := i+1;
  od;
  if i = l then
    it!.comb := fail;
  else
    comb[i+1] := comb[i+1] + 1;
    comb[i] := comb[i] - 1;
    Distr_Combinations(it, i);
  fi;
  return res;
end);
BindGlobal("IsDoneIterator_Combinations", function(it)
  return it!.comb = fail;
end);
BindGlobal("ShallowCopy_Combinations", function(it)
  return rec(
    NextIterator := it!.NextIterator,
    IsDoneIterator := it!.IsDoneIterator,
    ShallowCopy := it!.ShallowCopy,
    els := it!.els,
    max := it!.max,
    len := it!.len,
    k := it!.k,
    comb := ShallowCopy(it!.comb));
end);
InstallGlobalFunction(IteratorOfCombinations,  function(mset, arg...)
  local k, c, max, els, len, comb, NextFunc;
  len := Length(mset);
  if Length(arg) = 0 then
    # case of one argument, call 2-arg version for each k and concatenate
    return ConcatenationIterators(List([0..len], k->
                                         IteratorOfCombinations(mset, k)));
  fi;
  k := arg[1];
  if k > len then
    return IteratorList([]);
  elif len = 0 then
    return TrivialIterator( [] );
  fi;
  c := Collected(mset);
  max := List(c, a-> a[2]);
  els := List(c, a-> a[1]);
  if Maximum(max) = 1 then
    # in case of a proper set 'mset' we use 'comb' for indices of
    # elements in current combination; this way the generation
    # of the actual combinations is a bit more efficient than below in the
    # general case of a multiset
    comb := [1..k];
    NextFunc := NextIterator_Combinations_set;
  else
    # the general case of a multiset, here 'comb'
    # describes the combination which contains comb[i] times els[i] for all i
    comb := 0*max;
    comb[1] := k;
    # initialize first combination
    Distr_Combinations(rec(comb := comb,max := max),1);
    NextFunc := NextIterator_Combinations_mset;
  fi;
  return IteratorByFunctions(rec(
    NextIterator := NextFunc,
    IsDoneIterator := IsDoneIterator_Combinations,
    ShallowCopy := ShallowCopy_Combinations,
    els := els,
    max := max,
    len := len,
    k := k,
    comb := comb));
end);


#############################################################################
##
#F  NrCombinations( <mset> )  . . . . number of sorted sublists of a multiset
##
##  'NrCombinations' just calls  'NrCombinationsSetA', 'NrCombinationsMSetA',
##  'NrCombinationsSetK' or 'NrCombinationsMSetK' depending on the arguments.
##
##  'NrCombinationsSetA' and 'NrCombinationsSetK' use well known identities.
##
##  'NrCombinationsMSetA'  and 'NrCombinationsMSetK' call  'NrCombinationsX',
##  and return either the sum or the last element of this list.
##
##  'NrCombinationsX'   returns the list  'nrs', such  that 'nrs[l+1]' is the
##  number of combinations of length l.  It uses  a recursion formula, taking
##  more and more of the elements of <mset>.
##
BindGlobal( "NrCombinationsX", function ( mset, k )
    local  nrs, nr, cnt, n, l, i;

    # count how often each element appears
    cnt := List( Collected( mset ), pair -> pair[2] );

    # there is one combination of length 0 and no other combination
    # using none of the elements
    nrs := ListWithIdenticalEntries( k+1, 0 );
    nrs[0+1] := 1;

    # take more and more elements
    for n  in [1..Length(cnt)]  do

        # loop over the possible lengths of combinations
        for l  in [k,k-1..0]  do

            # compute the number of combinations of length <l>
            # using only the first <n> elements of <mset>
            nr := 0;
            for i  in [0..Minimum(cnt[n],l)]  do

                # add the number of combinations of length <l>
                # that consist of <l>-<i> of the first <n>-1 elements
                # and <i> copies of the <n>th element
                nr := nr + nrs[l-i+1];

            od;

            nrs[l+1] := nr;

        od;

    od;

    # return the numbers
    return nrs;
end );

BindGlobal( "NrCombinationsSetA", function ( set )
    local  nr;
    nr := 2 ^ Size(set);
    return nr;
end );

BindGlobal( "NrCombinationsMSetA", function ( mset )
    local  nr;
    nr := Product( Set(mset), i->Number(mset,j->i=j)+1 );
    return nr;
end );

BindGlobal( "NrCombinationsSetK", function ( set, k )
    local  nr;
    if k <= Size(set)  then
        nr := Binomial( Size(set), k );
    else
        nr := 0;
    fi;
    return nr;
end );

BindGlobal( "NrCombinationsMSetK", function ( mset, k )
    local  nr;
    if k <= Length(mset)  then
        nr := NrCombinationsX( mset, k )[k+1];
    else
        nr := 0;
    fi;
    return nr;
end );

InstallGlobalFunction(NrCombinations,function ( mset, arg... )
    local   nr;
    mset := ShallowCopy(mset);  Sort( mset );
    if Length(arg) = 0  then
        if IsSSortedList( mset )  then
            nr := NrCombinationsSetA( mset );
        else
            nr := NrCombinationsMSetA( mset );
        fi;
    elif Length(arg) = 1  then
        if IsSSortedList( mset )  then
            nr := NrCombinationsSetK( mset, arg[1] );
        else
            nr := NrCombinationsMSetK( mset, arg[1] );
        fi;
    else
        Error("usage: NrCombinations( <mset> [, <k>] )");
    fi;
    return nr;
end);


#############################################################################
##
#F  Arrangements( <mset> )  . . . . set of ordered combinations of a multiset
##
##  'ArrangementsA( <mset>,  <m>, <n>, <comb>, <i>  )' returns the set of all
##  arrangements of the multiset <mset>, which has  size <n>, that begin with
##  '<comb>[[1..<i>-1]]'.   To do this it  finds all  elements of <mset> that
##  can go at '<comb>[<i>]' and calls itself  recursively for each candidate.
##  <m> is a boolean list of size <n> that contains  'true' for every element
##  of <mset> that we have not yet taken, so the candidates for '<comb>[<i>]'
##  are exactly the elements '<mset>[<l>]' such that '<m>[<l>]'  is  'true'.
##  Some care must be taken to take a candidate only once if it appears  more
##  than once in <mset>.
##
##  'ArrangementsK( <mset>, <m>, <n>, <k>, <comb>, <i> )'  returns the set of
##  all arrangements  of the multiset <mset>,  which has size  <n>, that have
##  length '<i>+<k>-1', and that begin with '<comb>[[1..<i>-1]]'.  To do this
##  it finds  all elements of  <mset> that can  go at '<comb>[<i>]' and calls
##  itself recursively for each candidate.  <m> is a boolean list of size <n>
##  that contains 'true' for every element  of <mset>  that we  have  not yet
##  taken,  so  the candidates for   '<comb>[<i>]' are  exactly the elements
##  '<mset>[<l>]' such that '<m>[<l>]' is 'true'.  Some care must be taken to
##  take a candidate only once if it appears more than once in <mset>.
##
##  'Arrangements' only calls 'ArrangementsA' or 'ArrangementsK' with initial
##  arguments.
##
DeclareGlobalName( "ArrangementsA" );
BindGlobal( "ArrangementsA", function ( mset, m, n, comb, i )
    local   combs, l;
    if i = n+1  then
        comb  := ShallowCopy(comb);
        combs := [ comb ];
    else
        comb  := ShallowCopy(comb);
        combs := [ ShallowCopy(comb) ];
        for l  in [1..n]  do
            if m[l] and (l=1 or m[l-1]=false or mset[l]<>mset[l-1])  then
                comb[i] := mset[l];
                m[l] := false;
                Append( combs, ArrangementsA( mset, m, n, comb, i+1 ) );
                m[l] := true;
            fi;
        od;
    fi;
    return combs;
end );

DeclareGlobalName( "ArrangementsK" );
BindGlobal( "ArrangementsK", function ( mset, m, n, k, comb, i )
    local   combs, l;
    if k = 0  then
        comb := ShallowCopy(comb);
        combs := [ comb ];
    else
        combs := [];
        for l  in [1..n]  do
            if m[l] and (l=1 or m[l-1]=false or mset[l]<>mset[l-1])  then
                comb[i] := mset[l];
                m[l] := false;
                Append( combs, ArrangementsK( mset, m, n, k-1, comb, i+1 ) );
                m[l] := true;
            fi;
        od;
    fi;
    return combs;
end );

InstallGlobalFunction(Arrangements,function ( mset, arg... )
    local   combs, m;
    mset := ShallowCopy(mset);  Sort( mset );
    m := List( mset, ReturnTrue );
    if Length(arg) = 0  then
        combs := ArrangementsA( mset, m, Length(mset), [], 1 );
    elif Length(arg) = 1  then
        combs := ArrangementsK( mset, m, Length(mset), arg[1], [], 1 );
    else
        Error("usage: Arrangements( <mset> [, <k>] )");
    fi;
    return combs;
end);


#############################################################################
##
#F  NrArrangements( <mset> )  .  number of ordered combinations of a multiset
##
##  'NrArrangements' just calls  'NrArrangementsSetA', 'NrArrangementsMSetA',
##  'NrArrangementsSetK' or 'NrArrangementsMSetK' depending on the arguments.
##
##  'NrArrangementsSetA' and 'NrArrangementsSetK' use well known identities.
##
##  'NrArrangementsMSetA'  and 'NrArrangementsMSetK' call  'NrArrangementsX',
##  and return either the sum or the last element of this list.
##
##  'NrArrangementsX'   returns the list  'nrs', such  that 'nrs[l+1]' is the
##  number of arrangements of length l.  It uses  a recursion formula, taking
##  more and more of the elements of <mset>.
##
BindGlobal( "NrArrangementsX", function ( mset, k )
    local  nrs, nr, cnt, bin, n, l, i;

    # count how often each element appears
    cnt := List( Collected( mset ), pair -> pair[2] );

    # there is one arrangement of length 0 and no other arrangement
    # using none of the elements
    nrs := ListWithIdenticalEntries( k+1, 0 );
    nrs[0+1] := 1;

    # take more and more elements
    for n  in [1..Length(cnt)]  do

        # loop over the possible lengths of arrangements
        for l  in [k,k-1..0]  do

            # compute the number of arrangements of length <l>
            # using only the first <n> elements of <mset>
            nr := 0;
            bin := 1;
            for i  in [0..Minimum(cnt[n],l)]  do

                # add the number of arrangements of length <l>
                # that consist of <l>-<i> of the first <n>-1 elements
                # and <i> copies of the <n>th element
                nr := nr + bin * nrs[l-i+1];
                bin := bin * (l-i) / (i+1);

            od;

            nrs[l+1] := nr;

        od;

    od;

    # return the numbers
    return nrs;
end );

BindGlobal( "NrArrangementsSetA", function ( set )
    local  nr, i;
    nr := 0;
    for i  in [0..Size(set)]  do
        nr := nr + Product([Size(set)-i+1..Size(set)]);
    od;
    return nr;
end );

BindGlobal( "NrArrangementsMSetA", function ( mset, k )
    local  nr;
    nr := Sum( NrArrangementsX( mset, k ) );
    return nr;
end );

BindGlobal( "NrArrangementsSetK", function ( set, k )
    local  nr;
    if k <= Size(set)  then
        nr := Product([Size(set)-k+1..Size(set)]);
    else
        nr := 0;
    fi;
    return nr;
end );

BindGlobal( "NrArrangementsMSetK", function ( mset, k )
    local  nr;
    if k <= Length(mset)  then
        nr := NrArrangementsX( mset, k )[k+1];
    else
        nr := 0;
    fi;
    return nr;
end );

InstallGlobalFunction(NrArrangements,function ( mset, arg... )
    local   nr;
    mset := ShallowCopy(mset);  Sort( mset );
    if Length(arg) = 0  then
        if IsSSortedList( mset )  then
            nr := NrArrangementsSetA( mset );
        else
            nr := NrArrangementsMSetA( mset, Length(mset) );
        fi;
    elif Length(arg) = 1  then
        if not (IsInt(arg[1]) and arg[1] >= 0) then
             Error("<k> must be a nonnegative integer");
        fi;
        if IsSSortedList( mset )  then
            nr := NrArrangementsSetK( mset, arg[1] );
        else
            nr := NrArrangementsMSetK( mset, arg[1] );
        fi;
    else
        Error("usage: NrArrangements( <mset> [, <k>] )");
    fi;
    return nr;
end);


#############################################################################
##
#F  UnorderedTuples( <set>, <k> ) . . . .  set of unordered tuples from a set
##
##  'UnorderedTuplesK( <set>, <n>, <m>, <k>, <tup>, <i> )' returns the set of
##  all unordered tuples of  the  set <set>,  which  has size <n>, that  have
##  length '<i>+<k>-1', and that begin with  '<tup>[[1..<i>-1]]'.  To do this
##  it  finds all elements  of <set>  that  can go  at '<tup>[<i>]' and calls
##  itself   recursively  for   each  candidate.  <m>  is    the  position of
##  '<tup>[<i>-1]' in <set>, so the  candidates for '<tup>[<i>]' are exactly
##  the elements '<set>[[<m>..<n>]]',  since we require that unordered tuples
##  be sorted.
##
##  'UnorderedTuples' only calls 'UnorderedTuplesK' with initial arguments.
##
DeclareGlobalName( "UnorderedTuplesK" );
BindGlobal( "UnorderedTuplesK", function ( set, n, m, k, tup, i )
    local   tups, l;
    if k = 0  then
        tup := ShallowCopy(tup);
        tups := [ tup ];
    else
        tups := [];
        for l  in [m..n]  do
            tup[i] := set[l];
            Append( tups, UnorderedTuplesK( set, n, l, k-1, tup, i+1 ) );
        od;
    fi;
    return tups;
end );

InstallGlobalFunction(UnorderedTuples,function ( set, k )
    set := Set(set);
    return UnorderedTuplesK( set, Size(set), 1, k, [], 1 );
end);


#############################################################################
##
#F  NrUnorderedTuples( <set>, <k> ) . . number unordered of tuples from a set
##
InstallGlobalFunction(NrUnorderedTuples,function ( set, k )
    return Binomial( Size(Set(set))+k-1, k );
end);


#############################################################################
##
#F  IteratorOfCartesianProduct( list1, list2, ... )
#F  IteratorOfCartesianProduct( list )
##
##  All elements of the cartesian product of lists
##  <list1>, <list2>, ... are returned in the lexicographic order.
##
BindGlobal( "IsDoneIterator_Cartesian", iter -> ( iter!.next = false ) );

BindGlobal( "NextIterator_Cartesian",
    function( iter )
    local succ, n, sets, res, i, k;
    succ := iter!.next;
    n := iter!.n;
    sets := iter!.sets;
    res := [];
    i := n;
    while i > 0 do
      res[i] := sets[i][succ[i]];
      i := i-1;
    od;

    if succ = iter!.sizes then
      iter!.next := false;
    else
      succ[n] := succ[n] + 1;
      for k in [n,n-1..2] do
        if succ[k] > iter!.sizes[k] then
          succ[k] := 1;
          succ[k-1] := succ[k-1] + 1;
        else
          break;
        fi;
      od;
    fi;

    return res;
    end);

BindGlobal( "ShallowCopy_Cartesian",
            iter -> rec(
                      sets := iter!.sets,
                     sizes := iter!.sizes,
                         n := iter!.n,
                      next := ShallowCopy( iter!.next ) ) );

BindGlobal( "IteratorOfCartesianProduct2",
    function( listsets )
    local s, n;
    if not ForAll( listsets, IsListOrCollection ) and ForAll( listsets, IsFinite ) then
      Error( "Each argument must be a finite list or collection" );
    fi;
    if ForAny( listsets, IsEmpty ) then
      return Iterator( [] );
    fi;
    s := List( listsets, Set );
    n := Length( s );
    # from now s is a list of n finite sets
    return IteratorByFunctions(
      rec( IsDoneIterator := IsDoneIterator_Cartesian,
           NextIterator   := NextIterator_Cartesian,
           ShallowCopy    := ShallowCopy_Cartesian,
           sets           := s,                      # list of sets
           sizes          := MakeImmutable( List( s, Size ) ),
           n              := n,                      # number of sets
           next           := 0 * [ 1 .. n ] + 1 ) ); # list of 1's
    end);

InstallGlobalFunction( "IteratorOfCartesianProduct",
    function( arg )
    # this mimics usage of functions Cartesian and Cartesian2
    if Length( arg ) = 1  then
        return IteratorOfCartesianProduct2( arg[1] );
    fi;
    return IteratorOfCartesianProduct2( arg );
    end);

BindGlobal( "NumberElement_Cartesian",
function(enum, x)
  local n, mults, colls, sum, pos, i;

  n:=enum!.n;
  mults:=enum!.mults;
  colls:=enum!.colls;

  if Length(x)<>n then
    return fail;
  fi;

  sum:=0;
  for i in [1..n-1] do
    pos:=Position(colls[i], x[i]);
    if pos=fail then
      return fail;
    else
      pos:=pos-1;
    fi;
    sum:=sum+pos*mults[i];
  od;

  pos:=Position(colls[n], x[n]);

  if pos=fail then
    return fail;
  fi;

  return sum+pos;
end);

BindGlobal( "ElementNumber_Cartesian",
function(enum, x)
  local n, mults, out, i, colls;

  if x>Length(enum) then
    return fail;
  fi;

  x:=x-1;

  n:=enum!.n;
  mults:=enum!.mults;
  colls:=enum!.colls;
  out:=EmptyPlist(n);

  for i in [1..n-1] do
    out[i]:=QuoInt(x, mults[i]);
    x:=x-out[i]*mults[i];
    out[i]:=colls[i][out[i]+1];
  od;
  out[n]:=colls[n][x+1];

  return out;
end);

BindGlobal( "EnumeratorOfCartesianProduct2",
  function(colls)
  local new_colls, mults, k, out, i, j;

    if (not ForAll(colls, IsFinite)) or not (ForAll(colls, IsCollection) or
     ForAll(colls, IsEnumeratorByFunctions)) then
      ErrorNoReturn("usage: each argument must be a finite collection or enumerator,");
    fi;

    new_colls:=[];
    for i in [1..Length(colls)] do
      if IsDomain(colls[i]) then
        new_colls[i]:=Enumerator(colls[i]);
      else
        new_colls[i]:=colls[i];
      fi;
    od;

    mults:=List(new_colls, Length);
    for i in [1..Length(new_colls)-1] do
      k:=1;
      for j in [i+1..Length(new_colls)] do
        k:=k*Length(new_colls[j]);
      od;
      mults[i]:=k;
    od;
    mults[Length(new_colls)]:=0;

    out:=EnumeratorByFunctions(ListsFamily,
      rec( NumberElement := NumberElement_Cartesian,
           ElementNumber := ElementNumber_Cartesian,
           mults:=mults,
           n:=Length(colls),
           colls:=new_colls,
           Length:=enum-> Maximum([mults[1],1])*Length(new_colls[1])));
    SetIsFinite(out, true);
    return out;
end);

InstallGlobalFunction( "EnumeratorOfCartesianProduct",
    function( arg )
    # this mimics usage of functions Cartesian and Cartesian2
    if IsEmpty(arg) or ForAny(arg, IsEmpty) then
      return [];
    elif Length( arg ) = 1  then
        return EnumeratorOfCartesianProduct2( arg[1] );
    fi;
    return EnumeratorOfCartesianProduct2( arg );
end);

#############################################################################
##
#F  Tuples( <set>, <k> )  . . . . . . . . .  set of ordered tuples from a set
##
##  'TuplesK( <set>, <k>, <tup>, <i> )' returns the set  of all tuples of the
##  set   <set>   that have   length     '<i>+<k>-1',  and  that  begin  with
##  '<tup>[[1..<i>-1]]'.  To do this  it loops  over  all elements of  <set>,
##  puts them at '<tup>[<i>]' and calls itself recursively.
##
##  'Tuples' only calls 'TuplesK' with initial arguments.
##
DeclareGlobalName( "TuplesK" );
BindGlobal( "TuplesK", function ( set, k, tup, i )
    local   tups, l;
    if k = 0  then
        tup := ShallowCopy(tup);
        tups := [ tup ];
    else
        tups := [];
        for l  in set  do
            tup[i] := l;
            Append( tups, TuplesK( set, k-1, tup, i+1 ) );
        od;
    fi;
    return tups;
end );

InstallGlobalFunction(Tuples,function ( set, k )
    set := Set(set);
    return TuplesK( set, k, [], 1 );
end);


#############################################################################
##
#F  EnumeratorOfTuples( <set>, <k> )
##
InstallGlobalFunction( EnumeratorOfTuples, function( set, k )
    local enum;

    # Handle some trivial cases first.
    if k = 0 then
      return Immutable( [ [] ] );
    elif IsEmpty( set ) then
      return Immutable( [] );
    fi;

    # Construct the object.
    enum:= EnumeratorByFunctions( CollectionsFamily( FamilyObj( set ) ), rec(
        # Add the functions.
        ElementNumber:= function( enum, n )
          local nn, t, i;
          nn:= n-1;
          t:= [];
          for i in [ 1 .. enum!.k ] do
            t[i]:= RemInt( nn, Length( enum!.set ) ) + 1;
            nn:= QuoInt( nn, Length( enum!.set ) );
          od;
          if nn <> 0 then
            Error( "<enum>[", n, "] must have an assigned value" );
          fi;
          nn:= enum!.set{ Reversed( t ) };
          MakeImmutable( nn );
          return nn;
        end,

        NumberElement:= function( enum, elm )
          local n, i;
          if not IsList( elm ) then
            return fail;
          fi;
          elm:= List( elm, x -> Position( enum!.set, x ) );
          if fail in elm or Length( elm ) <> enum!.k then
            return fail;
          fi;
          n:= 0;
          for i in [ 1 .. enum!.k ] do
            n:= Length( enum!.set ) * n + elm[i] - 1;
          od;
          return n+1;
        end,

        Length:= enum -> Length( enum!.set )^enum!.k,

        PrintObj:= function( enum )
          Print( "EnumeratorOfTuples( ", enum!.set, ", ", enum!.k, " )" );
        end,

        # Add the data.
        set:= Set( set ),
        k:= k ) );

    # We know that this enumerator is strictly sorted.
    SetIsSSortedList( enum, true );

    # Return the result.
    return enum;
    end );


#############################################################################
##
#F  IteratorOfTuples( <set>, <n> )
##
##  All ordered tuples of length <n> of the set <set>
##  are returned in lexicographic order.
##
BindGlobal( "IsDoneIterator_Tuples", iter -> ( iter!.next = false ) );

BindGlobal( "NextIterator_Tuples", function( iter )
    local t, m, n, succ, k;

    t := iter!.next;
    m := iter!.m;
    n := iter!.n;

    if t = iter!.last then
      succ := false;
    else
      succ := ShallowCopy( t );
      succ[n] := succ[n] + 1;
      for k in [n,n-1..2] do
        if succ[k] > m then
          succ[k] := succ[k] - m;
          succ[k-1] := succ[k-1] + 1;
        else
          break;
        fi;
      od;
    fi;

    iter!.next:= succ;
    return iter!.set{t};
    end );

BindGlobal( "ShallowCopy_Tuples",
    iter -> rec( m    := iter!.m,
                 n    := iter!.n,
                 last := iter!.last,
                 set  := iter!.set,
                 next := ShallowCopy( iter!.next ) ) );

InstallGlobalFunction( "IteratorOfTuples",
    function( s, n )

    if not ( n=0 or IsPosInt( n ) ) then
        Error( "The second argument <n> must be a non-negative integer" );
    fi;

    if not ( IsCollection( s ) and IsFinite( s ) or IsEmpty( s ) and n=0 ) then
        if s = [] then
            return IteratorByFunctions(
              rec( IsDoneIterator := ReturnTrue,
                   NextIterator   := NextIterator_Tuples,
                   ShallowCopy    := ShallowCopy_Tuples,
                             next := false) );
        else
            Error( "The first argument <s> must be a finite collection or empty" );
        fi;
    fi;
    s := Set(s);
    # from now on s is a finite set and n is its Cartesian power to be enumerated
    return IteratorByFunctions(
      rec( IsDoneIterator := IsDoneIterator_Tuples,
           NextIterator   := NextIterator_Tuples,
           ShallowCopy    := ShallowCopy_Tuples,
           set            := s,
           m              := Size(s),
           last           := 0 * [1..n] + ~!.m,
           n              := n,
           next           := 0 * [ 1 .. n ] + 1 ) );
    end );


#############################################################################
##
#F  NrTuples( <set>, <k> )  . . . . . . . number of ordered tuples from a set
##
InstallGlobalFunction(NrTuples,function ( set, k )
    return Size(Set(set)) ^ k;
end);


#############################################################################
##
#F  PermutationsList( <mset> )  . . . . . . set of permutations of a multiset
##
##  'PermutationsListK( <mset>, <m>, <n>, <k>, <perm>, <i> )' returns the set
##  of all  permutations  of the multiset  <mset>, which  has  size <n>, that
##  begin  with '<perm>[[1..<i>-1]]'.  To do   this it finds all elements  of
##  <mset> that can go at '<perm>[<i>]' and calls itself recursively for each
##  candidate.  <m> is a  boolean  list of size  <n> that contains 'true' for
##  every element of <mset> that we have not yet taken, so the candidates for
##  '<perm>[<i>]'  are    exactly the   elements   '<mset>[<l>]' such   that
##  '<m>[<l>]' is 'true'.  Some care must be taken to take a  candidate  only
##  once if it appears more than once in <mset>.
##
##  'Permutations' only calls 'PermutationsListK' with initial arguments.
##
DeclareGlobalName( "PermutationsListK" );
BindGlobal( "PermutationsListK", function ( mset, m, n, k, perm, i )
    local   perms, l;
    if k = 0  then
        perm := ShallowCopy(perm);
        perms := [ perm ];
    else
        perms := [];
        for l  in [1..n]  do
            if m[l] and (l=1 or m[l-1]=false or mset[l]<>mset[l-1])  then
                perm[i] := mset[l];
                m[l] := false;
                Append( perms, PermutationsListK(mset,m,n,k-1,perm,i+1) );
                m[l] := true;
            fi;
        od;
    fi;
    return perms;
end );

InstallGlobalFunction(PermutationsList,function ( mset )
    local   m;
    mset := ShallowCopy(mset);  Sort( mset );
    m := List( mset, ReturnTrue );
    return PermutationsListK(mset,m,Length(mset),Length(mset),[],1);
end);


#############################################################################
##
#F  NrPermutationsList( <mset> )  . . .  number of permutations of a multiset
##
##  'NrPermutationsList' uses the well known multinomial coefficient formula.
##
InstallGlobalFunction(NrPermutationsList,function ( mset )
    local   nr, m;
    nr := Factorial( Length(mset) );
    for m  in Set(mset)  do
        nr := nr / Factorial( Number( mset, i->i = m ) );
    od;
    return nr;
end);


#############################################################################
##
#F  Derangements( <list> ) . . . . set of fixpointfree permutations of a list
##
##  'DerangementsK( <mset>, <m>, <n>, <list>, <k>, <perm>, <i> )' returns the
##  set of all permutations of the multiset <mset>, which  has size <n>, that
##  have no element  at the  same position  as <list>,  and that begin   with
##  '<perm>[[1..<i>-1]]'.   To do this it finds  all elements  of <mset> that
##  can go at '<perm>[<i>]' and calls itself  recursively for each candidate.
##  <m> is a boolean list of size <n> that contains  'true' for every element
##  that we have not  yet taken, so the  candidates for '<perm>[<i>]' are the
##  elements '<mset>[<l>]' such that '<m>[<l>]' is 'true'.  Some care must be
##  taken  to  take a candidate   only once if  it  append more  than once in
##  <mset>.
##
DeclareGlobalName( "DerangementsK" );
BindGlobal( "DerangementsK", function ( mset, m, n, list, k, perm, i )
    local   perms, l;
    if k = 0  then
        perm := ShallowCopy(perm);
        perms := [ perm ];
    else
        perms := [];
        for l  in [1..n]  do
            if m[l] and (l=1 or m[l-1]=false or mset[l]<>mset[l-1])
              and mset[l] <> list[i]  then
                perm[i] := mset[l];
                m[l] := false;
                Append( perms, DerangementsK(mset,m,n,list,k-1,perm,i+1) );
                m[l] := true;
            fi;
        od;
    fi;
    return perms;
end );

InstallGlobalFunction(Derangements,function ( list )
    local   mset, m;
    mset := ShallowCopy(list);  Sort( mset );
    m := List( mset, ReturnTrue );
    return DerangementsK(mset,m,Length(mset),list,Length(mset),[],1);
end);


#############################################################################
##
#F  NrDerangements( <list> ) .  number of fixpointfree permutations of a list
##
##  'NrDerangements' uses well known  identities if <mset>  is a proper  set.
##  If <mset> is a multiset it  uses 'NrDerangementsK', which works just like
##  'DerangementsK'.
##
DeclareGlobalName( "NrDerangementsK" );
BindGlobal( "NrDerangementsK", function ( mset, m, n, list, k, i )
    local   perms, l;
    if k = 0  then
        perms := 1;
    else
        perms := 0;
        for l  in [1..n]  do
            if m[l] and (l=1 or m[l-1]=false or mset[l]<>mset[l-1])
              and mset[l] <> list[i]  then
                m[l] := false;
                perms := perms + NrDerangementsK(mset,m,n,list,k-1,i+1);
                m[l] := true;
            fi;
        od;
    fi;
    return perms;
end );

InstallGlobalFunction(NrDerangements,function ( list )
    local   nr, mset, m, i;
    mset := ShallowCopy(list);  Sort( mset );
    if IsSSortedList(mset)  then
        if Size(mset) = 0  then
            nr := 1;
        elif Size(mset) = 1  then
            nr := 0;
        else
            m := - Factorial(Size(mset));
            nr := 0;
            for i  in [2..Size(mset)]  do
                m := - m / i;
                nr := nr + m;
            od;
        fi;
    else
        m := List( mset, ReturnTrue );
        nr := NrDerangementsK(mset,m,Length(mset),list,Length(mset),1);
    fi;
    return nr;
end);


#############################################################################
##
#F  Permanent( <mat> )  . . . . . . . . . . . . . . . . permanent of a matrix
##
DeclareGlobalName( "Permanent2" );
BindGlobal( "Permanent2", function ( mat, m, n, r, v, i, sum )
    local   p,  k;
    if i = n+1  then
        p := v;
        for k  in sum  do p := p * k;  od;
    else
        p := Permanent2( mat, m, n, r, v, i+1, sum )
             + Permanent2( mat, m, n, r+1, v*(r-m)/(n-r), i+1, sum+mat[i] );
    fi;
    return p;
end );

InstallMethod(Permanent,
   "for matrices",
   [ IsMatrix ],
function ( mat )
    local m, n;

    m := NrRows(mat);
    n := NrCols(mat);
    while n<m do
        Error("Matrix may not have fewer columns than rows");
    od;
    mat := TransposedMat(mat);
    return Permanent2( mat, m, n, 0, (-1)^m*Binomial(n,m), 1, 0*mat[1] );
end);


#############################################################################
##
#F  PartitionsSet( <set> )  . . . . . . . . . . .  set of partitions of a set
##
##  'PartitionsSetA( <set>,  <n>, <m>, <o>, <part>,  <i>, <j> )'  returns the
##  set  of all partitions of  the set <set>, which  has size <n>, that begin
##  with  '<part>[[1..<i>-1]]'  and   where the    <i>-th   set begins   with
##  '<part>[<i>][[1..<j>]]'.    To do so  it  does two things.   It finds all
##  elements of  <mset> that can  go at '<part>[<i>][<j>+1]' and calls itself
##  recursively for  each candidate.  And it  considers the set '<part>[<i>]'
##  to be complete  and starts a  new  set '<part>[<i>+1]', which must  start
##  with the smallest element of <mset> not yet taken, because we require the
##  returned partitions to be  sorted lexicographically.  <mset> is a boolean
##  list that contains 'true' for every element of <mset> not yet taken.  <o>
##  is the position  of '<part>[<i>][<j>]' in  <mset>, so the candidates  for
##  '<part>[<i>][<j>+1]' are  those elements '<mset>[<l>]'  for  which '<o> <
##  <l>' and '<m>[<l>]' is 'true'.
##
##  'PartitionsSetK( <set>, <n>,  <m>, <o>, <k>,  <part>, <i>, <j> )' returns
##  the set of all partitions of the set <set>, which has size <n>, that have
##  '<k>+<i>-1' subsets, and  that begin with '<part>[[1..<i>-1]]'  and where
##  the <i>-th set begins with '<part>[<i>][[1..<j>]]'.  To do so it does two
##  things.  It   finds    all  elements   of   <mset>    that  can   go   at
##  '<part>[<i>][<j>+1]'  and calls  itself  recursively for  each candidate.
##  And,  if <k> is  larger than 1, it considers  the set '<part>[<i>]' to be
##  complete and starts a new set '<part>[<i>+1]',  which must start with the
##  smallest element of <mset> not yet taken, because we require the returned
##  partitions to be sorted lexicographically.  <mset> is a boolean list that
##  contains 'true' for every element  of <mset> not yet  taken.  <o> is  the
##  position    of '<part>[<i>][<j>]'  in    <mset>,  so  the  candidates for
##  '<part>[<i>][<j>+1]' are those elements  '<mset>[<l>]'  for which '<o>  <
##  <l>' and '<m>[<l>]' is 'true'.
##
##  'PartitionsSet' only  calls   'PartitionsSetA' or  'PartitionsSetK'  with
##  initial arguments.
##
DeclareGlobalName( "PartitionsSetA" );
BindGlobal( "PartitionsSetA", function ( set, n, m, o, part, i, j )
    local   parts, npart, l;
    l := Position(m,true);
    if l = fail  then
        part := List(part,ShallowCopy);
        parts := [ part ];
    else
        npart := ShallowCopy(part);
        m[l] := false;
        npart[i+1] := [ set[l] ];
        parts := PartitionsSetA(set,n,m,l+1,npart,i+1,1);
        m[l] := true;
        part := ShallowCopy(part);
        part[i] := ShallowCopy(part[i]);
        for l  in [o..n]  do
            if m[l]   then
                m[l] := false;
                part[i][j+1] := set[l];
                Append( parts, PartitionsSetA(set,n,m,l+1,part,i,j+1));
                m[l] := true;
            fi;
        od;
    fi;
    return parts;
end );

DeclareGlobalName( "PartitionsSetK" );
BindGlobal( "PartitionsSetK", function ( set, n, m, o, k, part, i, j )
    local   parts, npart, l;
    l := Position(m,true);
    parts := [];
    if k = 1  then
        part := List(part,ShallowCopy);
        for l  in [k..n]  do
            if m[l]  then
                Add( part[i], set[l] );
            fi;
        od;
        parts := [ part ];
    elif l <> fail  then
        npart := ShallowCopy(part);
        m[l] := false;
        npart[i+1] := [ set[l] ];
        parts := PartitionsSetK(set,n,m,l+1,k-1,npart,i+1,1);
        m[l] := true;
        part := ShallowCopy(part);
        part[i] := ShallowCopy(part[i]);
        for l  in [o..n]  do
            if m[l]  then
                m[l] := false;
                part[i][j+1] := set[l];
                Append( parts, PartitionsSetK(set,n,m,l+1,k,part,i,j+1));
                m[l] := true;
            fi;
        od;
    fi;
    return parts;
end );

InstallGlobalFunction(PartitionsSet,function ( set, arg... )
    local   parts, m, k;
    if not IsSSortedList(set)  then
        Error("PartitionsSet: <set> must be a set");
    fi;
    if Length(arg) = 0  then
        if set = []  then
            parts := [ [  ] ];
        else
            m := List( set, ReturnTrue );
            m[1] := false;
            parts := PartitionsSetA(set,Length(set),m,2,[[set[1]]],1,1);
        fi;
    elif Length(arg) = 1  then
        k := arg[1];
        if set = []  then
            if k = 0  then
                parts := [ [ ] ];
            else
                parts := [ ];
            fi;
        else
            m := List( set, ReturnTrue );
            m[1] := false;
            parts := PartitionsSetK(
                        set, Length(set), m, 2, k, [[set[1]]], 1, 1 );
        fi;
    else
        Error("usage: PartitionsSet( <n> [, <k>] )");
    fi;
    return parts;
end);


#############################################################################
##
#F  NrPartitionsSet( <set> )  . . . . . . . . . number of partitions of a set
##
InstallGlobalFunction(NrPartitionsSet,function ( set, arg... )
    local   nr;
    if not IsSSortedList(set)  then
        Error("NrPartitionsSet: <set> must be a set");
    fi;
    if Length(arg) = 0  then
        nr := Bell( Size(set) );
    elif Length(arg) = 1  then
        nr := Stirling2( Size(set), arg[1] );
    else
        Error("usage: NrPartitionsSet( <n> [, <k>] )");
    fi;
    return nr;
end);


#############################################################################
##
#F  Partitions( <n> ) . . . . . . . . . . . . set of partitions of an integer
##
##  'PartitionsA( <n>, <m>, <part>, <i> )' returns the  set of all partitions
##  of '<n> +  Sum(<part>[[1..<i>-1]])' that begin with '<part>[[1..<i>-1]]'.
##  To do so  it finds  all values that  can go  at  '<part>[<i>]' and  calls
##  itself recursively for each   candidate.  <m> is '<part>[<i>-1]', so  the
##  candidates  for   '<part>[<i>]'  are '[1..Minimum(<m>,<n>)]',   since  we
##  require that partitions are nonincreasing.
##
##  There is one hack  that needs some comments.   Each call to 'PartitionsA'
##  contributes one  partition  without   going into recursion,    namely the
##  'Concatenation(  <part>[[1..<i>-1]], [1,1,...,1]  )'.  Of all  partitions
##  returned by 'PartitionsA'  this  is the smallest,  i.e.,  it will be  the
##  first  one in the result  set.   Therefore it is  put  into the result set
##  before anything else is done.  However it  is not immediately padded with
##  1, this is  the last  thing  'PartitionsA' does before  returning.  In the
##  meantime the  list is  used as a   temporary that is passed  to recursive
##  invocations.  Note that the fact that each call contributes one partition
##  without going into recursion means that  the number of recursive calls to
##  'PartitionsA'  (and the number  of  calls to  'ShallowCopy') is equal  to
##  'NrPartitions(<n>)'.
##
##  'PartitionsK( <n>,  <m>,  <k>, <part>,  <i>  )' returns  the  set of  all
##  partitions    of  '<n>  +   Sum(<part>[[1..<i>-1]])'  that    have length
##  '<k>+<i>-1' and that begin with '<part>[[1..<i>-1]]'.   To do so it finds
##  all values that can go at '<part>[<i>]' and  calls itself recursively for
##  each  candidate.    <m>  is  '<part>[<i>-1]',   so  the   candidates  for
##  '<part>[<i>]' must be  less than or  equal to <m>,  since we require that
##  partitions    are  nonincreasing.   Also    '<part>[<i>]' must    be  \<=
##  '<n>+1-<k>', since  we need at   least  <k>-1  ones  to  fill the   <k>-1
##  positions of <part> remaining after  filling '<part>[<i>]'.  On the other
##  hand '<part>[<i>]'  must be  >=  '<n>/<k>', because otherwise  we  cannot
##  fill the <k>-1 remaining positions nonincreasingly.   It is not difficult
##  to show  that for  each  candidate satisfying these properties   there is
##  indeed a partition, i.e., we never run into a dead end.
##
##  'Partitions'  only  calls  'PartitionsA'  or  'PartitionsK'  with initial
##  arguments.
##
DeclareGlobalName( "PartitionsA" );
BindGlobal( "PartitionsA", function ( n, m, part, i )
    local   parts, l;
    if n = 0  then
        part := ShallowCopy(part);
        parts := [ part ];
    elif n <= m  then
        part := ShallowCopy(part);
        parts := [ part ];
        for l  in [2..n]  do
            part[i] := l;
            Append( parts, PartitionsA( n-l, l, part, i+1 ) );
        od;
        for l  in [i..i+n-1]  do
            part[l] := 1;
        od;
    else
        part := ShallowCopy(part);
        parts := [ part ];
        for l  in [2..m]  do
            part[i] := l;
            Append( parts, PartitionsA( n-l, l, part, i+1 ) );
        od;
        for l  in [i..i+n-1]  do
            part[l] := 1;
        od;
    fi;
    return parts;
end );

DeclareGlobalName( "PartitionsK" );
BindGlobal( "PartitionsK", function ( n, m, k, part, i )
    local   parts, l;
    if k = 1  then
        part := ShallowCopy(part);
        part[i] := n;
        parts := [ part ];
    elif n+1-k < m  then
        parts := [];
        for l  in [QuoInt(n+k-1,k)..n+1-k]  do
            part[i] := l;
            Append( parts, PartitionsK( n-l, l, k-1, part, i+1 ) );
        od;
    else
        parts := [];
        for l  in [QuoInt(n+k-1,k)..m]  do
            part[i] := l;
            Append( parts, PartitionsK( n-l, l, k-1, part, i+1 ) );
        od;
    fi;
    return parts;
end );

# The following used to be `Partitions' but was renamed, because
# the new `Partitions' is much faster and produces less garbage, see
# below.
InstallGlobalFunction(PartitionsRecursively,function ( n, arg... )
    local   parts, k;
    if Length(arg) = 0  then
        parts := PartitionsA( n, n, [], 1 );
    elif Length(arg) = 1  then
        k := arg[1];
        if n = 0  then
            if k = 0  then
                parts := [ [  ] ];
            else
                parts := [  ];
            fi;
        else
            if k = 0  then
                parts := [  ];
            else
                parts := PartitionsK( n, n, k, [], 1 );
            fi;
        fi;
    else
        Error("usage: Partitions( <n> [, <k>] )");
    fi;
    return parts;
end);


BindGlobal( "GPartitionsEasy", function(n)
  # Returns a list of all Partitions of n, sorted lexicographically.
  # Algorithm/Proof: Let P_n be the set of partitions of n.
  # Let B_n^k be the set of partitions of n with all parts less or equal to k.
  # Then P_n := Union_{k=1}^n [k] + B_{n-k}^k, where "[k]+" means, that
  # a part k is added. Note that the union is a disjoint union.
  # The algorithm first enumerates B_{n-k}^k for k=1,2,...,n-1 and then
  # puts everything together by adding the greatest part.
  # The GAP list B has as its j'th entry B[j] := B_{n-j}^j for j=1,...,n-1.
  # Note the greatest part of all partitions in all of B is less than or
  # equal to QuoInt(n,2).
  # The first stage of the algorithm consists of a loop, where k runs
  # from 1 to QuoInt(n,2) and for each k all partitions are added to all
  # B[j] with greatest part k. Because we run j in descending direction,
  # we already have B[j+k] (partitions of n-j-k) ready up to greatest part k
  # when we handle for B[j] (partitions of n-j) the partitions with greatest
  # part k.
  # In the second stage we only have to add the correct greatest part to get
  # a partition of n.
  # Note that `GPartitions' improves this by including the work for the
  # second step in the first one, such that less garbage objects are generated.
  # n must be a natural number >= 1.
  local B,j,k,l,p,res;
  B := List([1..n-1],x->[]);
  for k in [1..QuoInt(n,2)] do
    # Now we add all partitions for all entries of B with greatest part k.
    Add(B[n-k],[k]);   # the trivial partition with greatest part k
    for j in [n-k-1,n-k-2..k] do
      # exactly in those are partitions with greatest part k. Think!
      # we handle B[j] (partitions of n-j) with greatest part k
      for p in B[j+k] do    # those are partitions of n-j-k
        l := [k];
        Append(l,p);    # This prolonges the bag without creating garbage!
        Add(B[j],l);
      od;
    od;
  od;
  res := [];    # here we collect the result
  for k in [1..n-1] do   # handle partitions with greatest part k
    for p in B[k] do     # use B[k] = B_{n-k}^k
      l := [k];          # add a part k
      Append(l,p);
      Add(res,l);        # collect
    od;
  od;
  Add(res,[n]);    # one more case
  return res;
end );

BindGlobal( "GPartitions", function(n)
  # Returns a list of all Partitions of n, sorted lexicographically.
  # Algorithm/Proof: See first the comment of `GPartitionsEasy'.
  # This function does exactly the same as `GPartitionsEasy' by the same
  # algorithm, but it produces nearly no garbage, because in contrast
  # to `GPartitionsEasy' the greatest part added in the second stage is
  # already added in the first stage.
  # n must be a natural number >= 1.
  local B,j,k,l,p;
  B := List([1..n],x->[]);
  for k in [1..QuoInt(n,2)] do
    # Now we add all partitions for all entries of B with greatest part k.
    Add(B[n-k],[n-k,k]);   # the trivial partition with greatest part k
    for j in [n-k-1,n-k-2..k] do
      # exactly in those are partitions with greatest part k. Think!
      # we handle B[j] (partitions of n-j) with greatest part k
      for p in B[j+k] do    # those are partitions of n-j-k
        l := [j];       # This is the greatest part for stage 2
        Append(l,p);    # This prolonges the bag without creating garbage!
        l[2] := k;      # here used to be the greatest part for stage 2, now k
        Add(B[j],l);
      od;
    od;
  od;
  B[n][1] := [n];       # one more case
  return Concatenation(B);
end );

BindGlobal( "GPartitionsNrPartsHelper", function(n,m,ones)
  # Helper function for GPartitionsNrParts (see below) for the case
  # m > n. This is used only internally if m > QuoInt(n,2), because then
  # the standard routine does not work. Here we just calculate all partitions
  # of n and append a part m to it. We use exactly the algorithm in
  # `GPartitions'.
  local B,j,k,p,res;
  B := List([1..n-1],x->[]);
  for k in [1..QuoInt(n,2)] do
    # Now we add all partitions for all entries of B with greatest part k.
    Add(B[n-k],ones[m]+ones[k]);   # the trivial partition with greatest part k
    for j in [n-k-1,n-k-2..k] do
      # exactly in those are partitions with greatest part k. Think!
      # we handle B[j] (partitions of n-j) with greatest part k
      for p in B[j+k] do    # those are partitions of n-j-k
        Add(B[j],p + ones[k]);
      od;
    od;
  od;
  res := [];    # here we collect the result
  for k in [1..n-1] do   # handle partitions with greatest part k
    for p in B[k] do     # use B[k] = B_{n-k}^k
      AddRowVector(p,ones[k]);
      Add(res,p);        # collect
    od;
  od;
  Add(res,ones[m]+ones[n]);    # one more case
  return res;
end );


BindGlobal( "GPartitionsNrParts", function(n,m)
  # This function enumerates the set of all partitions of <n> into exactly
  # <m> parts.
  # We call a partition "admissible", if
  #  0) the sum s of its entries is <= n
  #  1) it has less or equal to m parts
  #  2) let g be its greatest part and k the number of parts,
  #     (m-k)*g+s <= n
  #     [this means that it may eventually lead to a partition of n with
  #      exactly m parts]
  # We proceed in steps. In the first step we write down all admissible
  # partitions with exactly 1 part, sorted by their greatest part.
  # In the t-th step (t from 2 to m-2) we use the partitions from step
  # t-1 to enumerate all admissible partitions with exactly t parts
  # sorted by their greatest part. In step m we add exactly the difference
  # of n and the sum of the entries to get a partition of n.
  #
  # We use the following Lemma: Leaving out the greatest part is a
  # surjective mapping of the set of admissible partitions with k parts
  # to the set of admissible partitions of k-1 parts. Therefore we get
  # every admissible partition with k parts from a partition with k-1
  # parts by adding a part which is greater or equal the greatest part.
  #
  # Note that all our partitions are vectors of length m and until the
  # last step we store n-(the sum) in the first entry.
  #
  local B,BB,i,j,k,p,pos,pp,prototype,t;

  # some special cases:
  if n <= 0 or m < 1 then
    return [];
  elif m = 1 then
    return [[n]];
  fi;
  # from now on we have m >= 2

  prototype := [1..m]*0;

  # Note that there are no admissible partitions of s<n with greatest part
  # greater than QuoInt(n,2) and no one-part-admissible partitions with
  # greatest part greater than QuoInt(n,m):
  # Therefore this is step 1:
  B := [];
  for i in [1..QuoInt(n,m)] do
    B[i] := [ShallowCopy(prototype)];
    B[i][1][1] := n-i;   # remember: here is the sum of the parts
    B[i][1][m] := i;
  od;
  for i in [QuoInt(n,m)+1..QuoInt(n,2)] do
    B[i] := [];
  od;

  # Now to steps 2 to m-1:
  for t in [2..m-1] do
    BB := List([1..QuoInt(n,2)],i->[]);
    pos := m+1-t;  # here we add a number, this is also number of parts to add
    for j in [1..QuoInt(n,2)] do
      # run through B[j] and add greatest part:
      for p in B[j] do
        # add all possible greatest parts:
        for k in [j+1..QuoInt(p[1],pos)] do
          pp := ShallowCopy(p);
          pp[pos] := k;
          pp[1] := pp[1]-k;
          Add(BB[k],pp);
        od;
        p[pos] := j;
        p[1] := p[1]-j;
        Add(BB[j],p);
      od;
    od;
    B := BB;
  od;

  # In step m we only collect everything (the first entry is already OK!):
  BB := List([1..n-m+1],i->[]);
  for j in [1..Length(B)] do
    for p in B[j] do
      Add(BB[p[1]],p);
    od;
  od;
  return Concatenation(BB);
end );


# The following replaces what is now `PartitionsRecursively':
# It now calls `GPartitions' and friends, which is much faster
# and more environment-friendly because it produces less garbage.
# Thanks to Götz Pfeiffer for the ideas!
InstallGlobalFunction(Partitions,function ( n, arg... )
    local   parts, k;
    if not IsInt(n) then
        Error("Partitions: <n> must be an integer");
    fi;
    if Length(arg) = 0  then
        if n <= 0 then
            parts := [[]];
        else
            parts := GPartitions( n );
        fi;
    elif Length(arg) = 1  then
        k := arg[1];
        if not IsInt(k) then
            Error("Partitions: <k> must be an integer");
        fi;
        if n < 0 or k < 0 then
            parts := [];
        else
            if n = 0  then
                if k = 0  then
                    parts := [ [  ] ];
                else
                    parts := [  ];
                fi;
            else
                if k = 0  then
                    parts := [  ];
                else
                    parts := GPartitionsNrParts( n, k );
                fi;
            fi;
        fi;
    else
        ErrorNoReturn("usage: Partitions( <n> [, <k>] )");
    fi;
    return parts;
end);

#############################################################################
##
#F  NrPartitions( <n> [, <k>] ) . . . . .  number of partitions of an integer
##
##  To compute $p(n) = NrPartitions(n)$ we use Euler\'s theorem, that asserts
##  $p(n) = \sum_{k>0}{ (-1)^{k+1} (p(n-(3m^2-m)/2) + p(n-(3m^2+m)/2)) }$.
##
##  To compute $p(n,k)$ we use $p(m,1) = p(m,m) = 1$, $p(m,l) = 0$ if $m\<l$,
##  and the recurrence  $p(m,l) = p(m-1,l-1) + p(m-l,l)$  if $1 \<   l \< m$.
##  This recurrence can be proved by splitting the number of ways to write $m$
##  as a  sum of $l$  summands in two subsets,  those  sums that have  1 as a
##  summand and those that do not.  The number of ways  to write $m$ as a sum
##  of $l$ summands that have 1 as a  summand is $p(m-1,l-1)$, because we can
##  take away  the  1 and obtain  a new sums with   $l-1$ summands  and value
##  $m-1$.  The number of ways to  write  $m$  as a sum  of $l$ summands such
##  that no summand is 1 is $P(m-l,l)$, because we  can  subtract 1 from each
##  summand and obtain new sums that still have $l$ summands but value $m-l$.
##
InstallGlobalFunction(NrPartitions,function ( n, arg... )
    local   s, m, p, k, l;

    if Length(arg) = 0  then
        s := 1;                             # p(0) = 1
        p := [ s ];
        for m  in [1..n]  do
            s := 0;
            k := 1;
            l := 1;                         # k*(3*k-1)/2
            while 0 <= m-(l+k)  do
                s := s - (-1)^k * (p[m-l+1] + p[m-(l+k)+1]);
                k := k + 1;
                l := l + 3*k - 2;
            od;
            if 0 <= m-l  then
                s := s - (-1)^k * p[m-l+1];
            fi;
            p[m+1] := s;
        od;

    elif Length(arg) = 1  then
        k := arg[1];
        if n = k  then
            s := 1;
        elif n < k  or k = 0  then
            s := 0;
        else
            p := [];
            for m  in [1..n]  do
                p[m] := 1;                  # p(m,1) = 1
            od;
            for l  in [2..k]  do
                for m  in [l+1..n-l+1]  do
                    p[m] := p[m] + p[m-l];  # p(m,l) = p(m,l-1) + p(m-l,l)
                od;
            od;
            s := p[n-k+1];
        fi;

    else
        Error("usage: NrPartitions( <n> [, <k>] )");
    fi;

    return s;
end);


#############################################################################
##
#F  PartitionsGreatestLE( <n>, <m> ) . . .  set of partitions of n parts <= m
##
##  returns the set of all (unordered) partitions of the integer <n> having
##  parts less or equal to the integer <m>.
##

BindGlobal( "GPartitionsGreatestLEEasy", function(n,m)
  # Returns a list of all Partitions of n with greatest part less or equal
  # than m, sorted lexicographically.
  # This works essentially as `GPartitions', but the greatest parts are
  # limited.
  # Algorithm/Proof:
  # Let B_n^k be the set of partitions of n with all parts less or equal to k.
  # Then P_n^m := Union_{k=1}^m [k] + B_{n-k}^k}, where "[k]+"
  # means, that a part k is added. Note that the union is a disjoint union.
  # Note that in the end we only need B_{n-k}^k for k<=m but to produce them
  # we need also partial information about B_{n-k}^k for k>m.
  # The algorithm first enumerates B_{n-k}^k for k=1,2,...,m and begins
  # to enumerate B_{n-k}^k for k>m as necessary and then puts everything
  # together by adding the greatest part.
  # The GAP list B has as its j'th entry B[j] := B_{n-j}^j for j=1,...,n-1.
  # Note the greatest part of all partitions in all of B is less than or
  # equal to QuoInt(n,2) and less than or equal to m.
  # The first stage of the algorithm consists of a loop, where k runs
  # from 1 to min(QuoInt(n,2),m) and for each k all partitions are added to all
  # B[j] with greatest part k. Because we run j in descending direction,
  # we already have B[j+k] (partitions of n-j-k) ready up to greatest part k
  # when we handle for B[j] (partitions of n-j) the partitions with greatest
  # part k.
  # In the second stage we only have to add the correct greatest part to get
  # a partition of n.
  # Note that `GPartitionsGreatestLE' improves this by including the
  # work for the second step in the first one, such that less garbage
  # objects are generated.
  # n and m must be a natural numbers >= 1.
  local B,j,k,l,p,res;
  if m >= n then return GPartitions(n); fi;   # a special case
  B := List([1..n-1],x->[]);
  for k in [1..Minimum(QuoInt(n,2),m)] do
    # Now we add all partitions for all entries of B with greatest part k.
    Add(B[n-k],[k]);   # the trivial partition with greatest part k
    for j in [n-k-1,n-k-2..k] do
      # exactly in those are partitions with greatest part k. Think!
      # we handle B[j] (partitions of n-j) with greatest part k
      for p in B[j+k] do    # those are partitions of n-j-k
        l := [k];
        Append(l,p);    # This prolonges the bag without creating garbage!
        Add(B[j],l);
      od;
    od;
  od;
  res := [];    # here we collect the result
  for k in [1..m] do   # handle partitions with greatest part k
    for p in B[k] do     # use B[k] = B_{n-k}^k
      l := [k];          # add a part k
      Append(l,p);
      Add(res,l);        # collect
    od;
  od;
  return res;
end );

BindGlobal( "GPartitionsGreatestLE", function(n,m)
  # Returns a list of all Partitions of n with greatest part less or equal
  # than m, sorted lexicographically.
  # This works exactly as `GPartitionsGreatestLEEasy', but faster.
  # This is done by doing all the work necessary for step 2 already in step 1.
  # n and m must be a natural numbers >= 1.
  local B,j,k,l,p,res;
  if m >= n then return GPartitions(n); fi;   # a special case
  B := List([1..n-1],x->[]);
  for k in [1..Minimum(QuoInt(n,2),m)] do
    # Now we add all partitions for all entries of B with greatest part k.
    Add(B[n-k],[n-k,k]);   # the trivial partition with greatest part k
    for j in [n-k-1,n-k-2..k] do
      # exactly in those are partitions with greatest part k. Think!
      # we handle B[j] (partitions of n-j) with greatest part k
      for p in B[j+k] do    # those are partitions of n-j-k
        l := [j];       # for step 2
        Append(l,p);    # This prolonges the bag without creating garbage!
        l[2] := k;      # here we add a new part k
        Add(B[j],l);
      od;
    od;
  od;
  return Concatenation(B{[1..m]});
end );

InstallGlobalFunction( PartitionsGreatestLE,
function(n,m)
    local parts;
    if not(IsInt(n) and IsInt(m)) then
        ErrorNoReturn("usage: PartitionsGreatestLE( <n>, <m> )");
    elif n < 0 or m < 0 then
        parts := [];
    else
        if n = 0  then
            if m = 0  then
                parts := [ [  ] ];
            else
                parts := [  ];
            fi;
        else
            if m = 0  then
                parts := [  ];
            else
                parts := GPartitionsGreatestLE( n, m );
            fi;
        fi;
    fi;
    return parts;
end);


#############################################################################
##
#F  PartitionsGreatestEQ( <n>, <m> ) . . . . set of partitions of n parts = n
##
##  returns the set of all (unordered) partitions of the integer <n> having
##  greatest part equal to the integer <m>.
##
BindGlobal( "GPartitionsGreatestEQHelper", function(n,m)
  # Helper function for GPartitionsGreatestEQ (see below) for the case
  # m > n. This is used only internally if m > QuoInt(n,2), because then
  # the standard routine does not work. Here we just calculate all partitions
  # of n and append a part m to it. We use exactly the algorithm in
  # `GPartitions'.
  local B,j,k,l,p;
  B := List([1..n],x->[]);
  for k in [1..QuoInt(n,2)] do
    # Now we add all partitions for all entries of B with greatest part k.
    Add(B[n-k],[m,n-k,k]);   # the trivial partition with greatest part k
    for j in [n-k-1,n-k-2..k] do
      # exactly in those are partitions with greatest part k. Think!
      # we handle B[j] (partitions of n-j) with greatest part k
      for p in B[j+k] do    # those are partitions of n-j-k
        l := [m];       # the greatest part
        Append(l,p);    # This prolonges the bag without creating garbage!
        l[2] := j;      # This is the greatest part for stage 2
        l[3] := k;      # here used to be the greatest part for stage 2, now k
        Add(B[j],l);
      od;
    od;
  od;
  B[n][1] := [m,n];       # one more case
  return Concatenation(B);
end );

BindGlobal( "GPartitionsGreatestEQ", function(n,m)
  # Returns a list of all Partitions of n with greatest part equal to
  # m, sorted lexicographically.
  # This works exactly as `GPartitionsGreatestLE' for n-m and m and
  # adds a part m to all partitions. This is however done effectively
  # during the work.
  # This is the same as `Partitions(n,m)' in the GAP library.
  # n and m must be a natural numbers >= 1.
  local B,j,k,l,p,res;
  if m > n then return []; fi;     # a special case
  if m = n then return [[m]]; fi;  # another special case
  n := n - m;    # this is >= 1
  if m >= n then return GPartitionsGreatestEQHelper(n,m); fi;
  B := List([1..n-1],x->[]);
  for k in [1..Minimum(QuoInt(n,2),m)] do
    # Now we add all partitions for all entries of B with greatest part k.
    Add(B[n-k],[m,n-k,k]);   # the trivial partition with greatest part k
    for j in [n-k-1,n-k-2..k] do
      # exactly in those are partitions with greatest part k. Think!
      # we handle B[j] (partitions of n-j) with greatest part k
      for p in B[j+k] do    # those are partitions of n-j-k
        l := [m];       # the greatest part m
        Append(l,p);    # This prolonges the bag without creating garbage!
        l[2] := j;      # for step 2
        l[3] := k;      # here we add a new part k
        Add(B[j],l);
      od;
    od;
  od;
  return Concatenation(B{[1..m]});
end );

InstallGlobalFunction( PartitionsGreatestEQ,
function(n,m)
    local parts;
    if not(IsInt(n) and IsInt(m)) then
        ErrorNoReturn("usage: PartitionsGreatestEQ( <n>, <m> )");
    elif n < 0 or m < 0 then
        parts := [];
    else
        if m = 0 or n = 0 then
            parts := [];
        else
            parts := GPartitionsGreatestEQ( n, m );
        fi;
    fi;
    return parts;
end);


#############################################################################
##
#F  OrderedPartitions( <n> ) . . . .  set of ordered partitions of an integer
##
##  'OrderedPartitionsA( <n>,  <part>, <i> )' returns  the set of all ordered
##  partitions  of  '<n>  +    Sum(<part>[[1..<i>-1]])'   that  begin    with
##  '<part>[[1..<i>-1]]'.   To do    so   it puts   all  possible  values  at
##  '<part>[<i>]', which are of course exactly the elements of '[1..n]', and
##  calls itself recursively.
##
##  'OrderedPartitionsK(  <n>,  <k>, <part>,  <i>  )' returns the set  of all
##  ordered partitions of   '<n> + Sum(<part>[[1..<i>-1]])'  that have length
##  '<k>+<i>-1', and that begin with '<part>[[1..<i>-1]]'.  To  do so it puts
##  all possible  values at '<part>[<i>]', which are   of course exactly the
##  elements of '[1..<n>-<k>+1]', and calls itself recursively.
##
##  'OrderedPartitions'      only       calls     'OrderedPartitionsA'     or
##  'OrderedPartitionsK' with initial arguments.
##
DeclareGlobalName( "OrderedPartitionsA" );
BindGlobal( "OrderedPartitionsA", function ( n, part, i )
    local   parts, l;
    if n = 0  then
        part := ShallowCopy(part);
        parts := [ part ];
    else
        part := ShallowCopy(part);
        parts := [];
        for l  in [1..n-1]  do
            part[i] := l;
            Append( parts, OrderedPartitionsA( n-l, part, i+1 ) );
        od;
        part[i] := n;
        Add( parts, part );
    fi;
    return parts;
end );

DeclareGlobalName( "OrderedPartitionsK" );
BindGlobal( "OrderedPartitionsK", function ( n, k, part, i )
    local   parts, l;
    if k = 1  then
        part := ShallowCopy(part);
        part[i] := n;
        parts := [ part ];
    else
        parts := [];
        for l  in [1..n-k+1]  do
            part[i] := l;
            Append( parts, OrderedPartitionsK( n-l, k-1, part, i+1 ) );
        od;
    fi;
    return parts;
end );

InstallGlobalFunction(OrderedPartitions,function ( n, arg... )
    local   parts, k;
    if Length(arg) = 0  then
        parts := OrderedPartitionsA( n, [], 1 );
    elif Length(arg) = 1  then
        k := arg[1];
        if n = 0  then
            if k = 0  then
                parts := [ [  ] ];
            else
                parts := [  ];
            fi;
        else
            if k = 0  then
                parts := [  ];
            else
                parts := OrderedPartitionsK( n, k, [], 1 );
            fi;
        fi;
    else
        Error("usage: OrderedPartitions( <n> [, <k>] )");
    fi;
    return parts;
end);


#############################################################################
##
#F  NrOrderedPartitions( <n> ) . . number of ordered partitions of an integer
##
##  'NrOrderedPartitions' uses well known identities to compute the number of
##  ordered partitions of <n>.
##
InstallGlobalFunction(NrOrderedPartitions,function ( n, arg... )
    local   nr, k;
    if Length(arg) = 0  then
        if n = 0  then
            nr := 1;
        else
            nr := 2^(n-1);
        fi;
    elif Length(arg) = 1  then
        k := arg[1];
        if n = 0  then
            if k = 0  then
                nr := 1;
            else
                nr := 0;
            fi;
        else
            nr := Binomial(n-1,k-1);
        fi;
    else
        Error("usage: NrOrderedPartitions( <n> [, <k>] )");
    fi;
    return nr;
end);


#############################################################################
##
#F  RestrictedPartitions( <n>, <set> )  . restricted partitions of an integer
##
##  'RestrictedPartitionsA( <n>, <set>, <m>,  <part>, <i> )' returns the  set
##  of  all partitions of  '<n> +  Sum(<part>[[1..<i>-1]])' that contain only
##  elements of <set> and that begin with '<part>[[1..<i>-1]]'.   To do so it
##  finds all elements of <set> that can go at '<part>[<i>]' and calls itself
##  recursively for each candidate.  <m>  is the position of  '<part>[<i>-1]'
##  in   <set>,  so the   candidates for  '<part>[<i>]'  are  the elements of
##  '<set>[[1..<m>]]' that  are less    than  <n>,  since we   require   that
##  partitions are nonincreasing.
##
##  'RestrictedPartitionsK( <n>, <set>, <m>, <k>,  <part>, <i> )' returns the
##  set  of all  partitions of  '<n>  + Sum(<part>[[1..<i>-1]])' that contain
##  only elements of <set>, that have length '<k>+<i>-1', and that begin with
##  '<part>[[1..<i>-1]]'.   To do so it finds  all elements fo <set> that can
##  go at '<part>[<i>]' and calls itself recursively for each candidate.  <m>
##  is  the  position  of '<part>[<i>-1]'   in  <set>, so the  candidates for
##  '<part>[<i>]' are the elements  of '<set>[[1..<m>]]'  that are less  than
##  <n>, since we require that partitions are nonincreasing.
##
DeclareGlobalName( "RestrictedPartitionsA" );
BindGlobal( "RestrictedPartitionsA", function ( n, set, m, part, i )
    local   parts, l;
    if n = 0  then
        part := ShallowCopy(part);
        parts := [ part ];
    else
        part := ShallowCopy(part);
        if n mod set[1] = 0  then
            parts := [ part ];
        else
            parts := [ ];
        fi;
        for l  in [2..m]  do
            if set[l] <= n  then
                part[i] := set[l];
                Append(parts,RestrictedPartitionsA(n-set[l],set,l,part,i+1));
            fi;
        od;
        if n mod set[1] = 0  then
            for l  in [i..i+n/set[1]-1]  do
                part[l] := set[1];
            od;
        fi;
    fi;
    return parts;
end );

DeclareGlobalName( "RestrictedPartitionsK" );
BindGlobal( "RestrictedPartitionsK", function ( n, set, m, k, part, i )
    local   parts, l;
    if k = 1  then
        if n in set  then
            part := ShallowCopy(part);
            part[i] := n;
            parts := [ part ];
        else
            parts := [];
        fi;
    else
        part := ShallowCopy(part);
        parts := [ ];
        for l  in [1..m]  do
            if set[l]+(k-1)*set[1] <= n  and n <= k*set[l]  then
                part[i] := set[l];
                Append(parts,
                       RestrictedPartitionsK(n-set[l],set,l,k-1,part,i+1) );
            fi;
        od;
    fi;
    return parts;
end );

InstallGlobalFunction(RestrictedPartitions,function ( n, set, arg... )
    local   parts, k;
    if Length(arg) = 0  then
        parts := RestrictedPartitionsA(n, set, Length(set), [], 1);
    elif Length(arg) = 1  then
        k := arg[1];
        if n = 0  then
            if k = 0  then
                parts := [ [  ] ];
            else
                parts := [  ];
            fi;
        else
            if not ForAll(set,IsPosInt) then
                Error("RestrictedPartitions: Set entries must be positive integers");
            fi;
            parts := RestrictedPartitionsK(
                         n, set, Length(set), k, [], 1 );
        fi;
    else
        Error("usage: RestrictedPartitions( <n>, <set> [, <k>] )");
    fi;
    return parts;
end);


#############################################################################
##
#F  NrRestrictedPartitions(<n>,<set>) . . . . number of restricted partitions
##
#N  22-Jul-91 martin there should be a better way to do this for given <k>
##
DeclareGlobalName( "NrRestrictedPartitionsK" );
BindGlobal( "NrRestrictedPartitionsK", function ( n, set, m, k, part, i )
    local   parts, l;
    if k = 1  then
        if n in set  then
            parts := 1;
        else
            parts := 0;
        fi;
    else
        part := ShallowCopy(part);
        parts := 0;
        for l  in [1..m]  do
            if set[l]+(k-1)*set[1] <= n  and n <= k*set[l]  then
                part[i] := set[l];
                parts := parts +
                        NrRestrictedPartitionsK(n-set[l],set,l,k-1,part,i+1);
            fi;
        od;
    fi;
    return parts;
end );

InstallGlobalFunction(NrRestrictedPartitions,function ( n, set, arg... )
    local  s, m, p, l, k;

    if Length(arg) = 0  then
        p := [];
        for m  in [1..n+1]  do
            if (m-1) mod set[1] = 0  then
                p[m] := 1;
            else
                p[m] := 0;
            fi;
        od;
        for l  in set{ [2..Length(set)] }  do
            for m  in [l+1..n+1]  do
                p[m] := p[m] + p[m-l];
            od;
        od;
        s := p[n+1];

    elif Length(arg) = 1  then
        k := arg[1];
        if n = 0  and k = 0  then
            s := 1;
        elif n < k  or k = 0  then
            s := 0;
        else
            if not ForAll(set,IsPosInt) then
                Error("NrRestrictedPartitions: Set entries must be positive integers");
            fi;
            s := NrRestrictedPartitionsK(
                        n, set, Length(set), k, [], 1 );
        fi;

    else
        Error("usage: NrRestrictedPartitions( <n>, <set> [, <k>] )");
    fi;

    return s;
end);


#############################################################################
##
#F  IteratorOfPartitions( <n> )
##
##  The partitions of <n> are returned in lexicographic order.
##
##  So the partition $\lambda = [ \lambda_1, \lambda_2, \ldots, \lambda_m ]$
##  has a successor if and only if $m > 1$.
##  If we set $k = \max\{ i; 1 \leq i \leq m-2, \lambda_k > \lambda_{m-1} \}$
##  (or $k = 0$ if the set is empty)
##  and $l = n - 1 - \sum_{i=1}^{k+1} \lambda_i$
##  then the successor of $\lambda$ has the form
##  $\mu = [ \lambda_1, \lambda_2, \ldots, \lambda_k, \lambda_{k+1}+1, 1^l ]$
##  (where the last term is omitted if $l = 0$).
##
##  (Note that $\mu$ is lexicographically larger than $\lambda$,
##  clearly $\mu_i = \lambda_i$ for $i \leq k$ is the minimal choice,
##  $\mu_{k+1}$ must satisfy $\mu_{k+1} > \lambda_{k+1}$ since
##  $\lambda_{k+1} = \lambda_{k+2} = \ldots = \lambda_{m-1} \geq \lambda_m$,
##  and for $i > k+1$, $\mu_i = 1$ is the smallest choice.)
##
BindGlobal( "IsDoneIterator_Partitions", iter -> ( iter!.next = false ) );

BindGlobal( "NextIterator_Partitions", function( iter)
    local part, m, succ, k;

    part:= iter!.next;
    m:= Length( part );
    if m = 1 then
      succ:= false;
    else
      k:= m-2;
      while 0 < k and part[ m-1 ] = part[k] do
        k:= k-1;
      od;
      succ:= part{ [ 1 .. k ] };
      k:= k+1;
      succ[k]:= part[k] + 1;
      Append( succ, 0 * [ 1 .. iter!.n - Sum( succ, 0 ) ] + 1 );
    fi;

    iter!.next:= succ;
    return part;
    end );

BindGlobal( "ShallowCopy_Partitions",
    iter -> rec( n:= iter!.n, next:= ShallowCopy( iter!.next ) ) );

InstallGlobalFunction( "IteratorOfPartitions", function( n )
    if n = 0 then
      return TrivialIterator( [] );
    elif not IsPosInt( n ) then
      Error( "<n> must be a nonnegative integer" );
    fi;
    return IteratorByFunctions( rec(
             IsDoneIterator := IsDoneIterator_Partitions,
             NextIterator   := NextIterator_Partitions,
             ShallowCopy    := ShallowCopy_Partitions,

             n              := n,
             next           := 0 * [ 1 .. n ] + 1 ) );
    end );


#############################################################################
##
#F  IteratorOfPartitionsSet( <set> [, <k> [, <flag> ] ]  )
##
##  If $B_0, B_1, \ldots, B_m$ are subsets forming a partition of
##  $\{1, 2, \ldots, n\}$, then the partition can be described by the
##  restricted growth string $a_1 a_2 \ldots a_n$, where $a_i = j$ if
##  $i \in B_j$. We may assume $a_1 = 0$ and then a restricted growth string
##  satisfies $a_i \leq Max(\{a_1, a_2, \ldots, a_{i-1}\}) + 1$ for
##  $i =2, 3, \ldots, n$. We may increment through restricted growth strings
##  by incrementing $a_i$ for the largest $i$ such that the inequality is not
##  tight, and setting $a_j=0$ for all $j>i$.
##
BindGlobal( "IsDoneIterator_PartitionsSet", iter -> ( iter!.next = false ) );

BindGlobal( "NextIterator_PartitionsSet", function( iter )
      local j, max, part, m, out, i;
      if Length(iter!.s) = 0 then
        iter!.next := false;
        return [];
      fi;
      part := StructuralCopy(iter!.next);
      j := Size(iter!.next);
      # Compute next restricted growth string using a_i \leq Max({a_0 .. a_{i-1}})+1
      while j > 1 do
        max := Maximum(iter!.next{[1 .. j-1]});
        if iter!.next[j] <= max then
          break;
        fi;
        iter!.next[j] := 0;
        j := j-1;
      od;
      if j > 1 then
        iter!.next[j] := iter!.next[j]+1;
      else
        iter!.next := false;
      fi;
      # Convert restricted growth string to partition of set
      m := Maximum(part)+1;
      out := List([1 .. m], t -> []);
      for i in [1 .. Size(part)] do
        Add(out[part[i]+1], iter!.s[i]);
      od;
      return out;
    end );

BindGlobal( "NextIterator_PartitionsSetGivenSize", function( iter )
      local j, max, part, m, out, i;
      if Length(iter!.s) = 0 or Length(iter!.s)<iter!.sz then
        iter!.next := false;
        return [];
      fi;
      part := StructuralCopy(iter!.next);
      while true do
        j := Size(iter!.next);
        # Compute next restricted growth string using a_i \leq Max({a_0 .. a_{i-1}})+1
        while j > 1 do
          # iterate in the same manner, but now we do not exceed sz-1
          max := Minimum(Maximum(iter!.next{[1 .. j-1]}), iter!.sz-2);
          if iter!.next[j] <= max then
            iter!.next[j] := iter!.next[j]+1;
            m := Maximum(iter!.next)+1;
            break;
          else
            iter!.next[j] := 0;
            j := j-1;
          fi;
        od;
        m := Maximum(part)+1;
        # Convert restricted growth string to partition of set
        out := List([1 .. m], t -> []);
        for i in [1 .. Size(part)] do
          Add(out[part[i]+1], iter!.s[i]);
        od;
        # this is the final iteration if in the next iteration we cycle through to the start again
        if ForAll([2 .. Size(iter!.next)], t -> iter!.next[t]=0) then
          iter!.next := false;
          return out;
        fi;
        # If the size of the partition equals sz we return, otherwise it is too small,
        # and we continue to iterate until the next partition of the correct size is found
        if Maximum(iter!.next)+1 = iter!.sz then
          if m = iter!.sz then
            return out;
          else
            part := StructuralCopy(iter!.next);
          fi;
        fi;
      od;
    end );

BindGlobal( "NextIterator_PartitionsSetGivenSizeOrLess", function( iter )
      local j, max, part, m, out, i;
      if Length(iter!.s) = 0 or Length(iter!.s)<iter!.sz then
        iter!.next := false;
        return [];
      fi;
      part := StructuralCopy(iter!.next);
      while true do
        j := Size(iter!.next);
        # Compute next restricted growth string using a_i \leq Max({a_0 .. a_{i-1}})+1
        while j > 1 do
          max := Minimum(Maximum(iter!.next{[1 .. j-1]}), iter!.sz-2);
          if iter!.next[j] <= max then
            iter!.next[j] := iter!.next[j]+1;
            m := Maximum(iter!.next)+1;
            break;
          else
            iter!.next[j] := 0;
            j := j-1;
          fi;
        od;
        m := Maximum(part)+1;
        # Convert restricted growth string to partition of set
        out := List([1 .. m], t -> []);
        for i in [1 .. Size(part)] do
          Add(out[part[i]+1], iter!.s[i]);
        od;
        # this is the final iteration if in the next iteration we cycle through to the start again
        if ForAll([2 .. Size(iter!.next)], t -> iter!.next[t]=0) then
          iter!.next := false;
          return out;
        fi;
        return out;
      od;
    end );

BindGlobal( "ShallowCopy_PartitionsSet",
    iter -> rec( next := ShallowCopy( iter!.next ), s := iter!.s, sz := iter!.sz ) );

InstallGlobalFunction( IteratorOfPartitionsSet , function( s, arg... )
    local k, r;

    if not IsSet(s) then
      Error( "IteratorOfPartitionsSet: <s> must be a set" );
    fi;

    r := rec(
            IsDoneIterator := IsDoneIterator_PartitionsSet,
            NextIterator := NextIterator_PartitionsSet,
            ShallowCopy := ShallowCopy_PartitionsSet,
            s := Immutable(s),
            next := ListWithIdenticalEntries(Size(s), 0),
            sz := fail,
         );

    if Length( arg ) = 1 or Length( arg ) = 2 then
      k := arg[1];
      if not IsInt(k) then
        Error("IteratorOfPartitionsSet: <k> must be an integer");
      fi;
      r.NextIterator := NextIterator_PartitionsSetGivenSize;

      if Length( arg ) = 2 then
        if arg[2] = true then
          r.NextIterator := NextIterator_PartitionsSetGivenSizeOrLess;
          k := Minimum(k, Length(s));
        elif arg[2] <> false then
          Error("IteratorOfPartitionsSet: <flag> must be true or false");
        fi;
      fi;
      if k<0 or (k=0 and s <> []) or (k > Length(s)) then
        r.next:=false;
      fi;
      r.sz := k;
    elif Length( arg ) > 2 then
      Error( "usage: IteratorOfPartitionsSet( <set> [, <k> [, <flag> ] ] )" );
    fi;

    return IteratorByFunctions(r);
  end);


#############################################################################
##
#F  SignPartition( <pi> ) . . . . . . . . . . . . .  signum of partition <pi>
##
InstallGlobalFunction(SignPartition,function(pi)
   return (-1)^(Sum(pi) - Length(pi));
end);


#############################################################################
##
#F  AssociatedPartition( <pi> ) . . . . . .  the associated partition of <pi>
##
##  'AssociatedPartition'  returns the associated partition  of the partition
##  <pi> which is obtained by transposing the corresponding Young diagram.
##
InstallGlobalFunction(AssociatedPartition,function(lambda)
  local res, k, j;
  res := [];
  k := Length(lambda);
  if k=0 then return res;fi; # empty partition
  for j in [1..lambda[1]] do
    if j <= lambda[k] then
      res[j] := k;
    else
      k := k-1;
      while j > lambda[k] do
        k := k-1;
      od;
      res[j] := k;
    fi;
  od;
  return res;
end);


#############################################################################
##
#F  PowerPartition( <pi>, <k> ) . . . . . . . . . . . .  power of a partition
##
##  'PowerPartition'  returns the partition corresponding to the <k>-th power
##  of a permutation with cycle structure <pi>.
##
InstallGlobalFunction(PowerPartition,function(pi, k)

   local res, i, d, part;

   res:= [];
   for part in pi do
      d:= GcdInt(part, k);
      for i in [1..d] do
         Add(res, part/d);
      od;
   od;
   Sort(res);

   return Reversed(res);

end);


#############################################################################
##
#F  PartitionTuples( <n>, <r> ) . . . . . . . . . <r> partitions with sum <n>
##
##  'PartitionTuples'  returns the list of all <r>-tuples of partitions which
##  together form a partition of <n>.
##
InstallGlobalFunction(PartitionTuples,function( n, r )
    local   empty,  pm,  m,  i,  s,  k,  t,  t1,  res;

   empty := rec( tup := List( [1..r], x-> [] ),
                 pos := List( [1..n-1], x-> 1 ) );

   if n = 0 then
      return [empty.tup];
   fi;

   pm := List( [1..n-1], x -> [] );

   for m  in [ 1 .. QuoInt(n,2) ]  do

       # the m-cycle in all possible places.
       for i  in [ 1 .. r ]  do
           s := rec( tup := List( empty.tup, ShallowCopy ),
                     pos := ShallowCopy( empty.pos ) );
           s.tup[i] := [m];
           s.pos[m] := i;
           Add( pm[m], s );
       od;

       # add the m-cycle to everything you know.
       for k  in [ m+1 .. n-m ]  do
           for t  in pm[k-m]  do
               for i  in [ t.pos[m] .. r ]  do
                   t1 := rec( tup := List( t.tup, ShallowCopy ),
                              pos := ShallowCopy( t.pos ) );
                   s := [m];
                   Append( s, t.tup[i] );
                   t1.tup[i] := s;
                   t1.pos[m] := i;
                   Add( pm[k], t1 );
               od;
           od;
       od;
   od;

   # collect.
   res := [];
   for k  in [ 1 .. n-1 ]  do
       for t  in pm[n-k]  do
           for i  in [ t.pos[k] .. r ]  do
               t1 := List( t.tup, ShallowCopy );
               s := [k];
               Append( s, t.tup[i] );
               t1[i] := s;
               Add( res, t1 );
           od;
       od;
   od;
   for i  in [ 1 .. r ]  do
       s := List( empty.tup, ShallowCopy );
       s[i] := [n];
       Add( res, s );
   od;

   return res;

end);

InstallGlobalFunction(NrPartitionTuples, function(n, k)
  local   res,  l,  pp,  r,  a,  pr,  b;
  res := 0;
  for l in [0..k] do
    pp := Partitions(n, l);
    r := Binomial(k, l);
    for a in pp do
      pr := 1;
      for b in a do
        pr := pr * NrPartitions(b);
      od;
      res := res + r * NrArrangements(a, l) * pr;
    od;
  od;
  return res;
end);

#############################################################################
##
#F  Lucas(<P>,<Q>,<k>)  . . . . . . . . . . . . . . value of a lucas sequence
##
##  'Lucas' uses the following relations to compute the result in $O(log(k))$
##  $U_{2k} = U_k V_k,        U_{2k+1} = (P U_{2k} + V_{2k}) / 2$ and
##  $V_{2k} = V_k^2 - 2 Q^k,  V_{2k+1} = ((P^2-4Q) U_{2k} + P V_{2k}) / 2$.
##
InstallGlobalFunction(Lucas,function ( P, Q, k )
    local   l;
    if k = 0  then
        l := [ 0, 2, 1 ];
    elif k < 0  then
        l := Lucas( P, Q, -k );
        l := [ -l[1]/l[3], l[2]/l[3], 1/l[3] ];
    elif k mod 2 = 0  then
        l := Lucas( P, Q, k/2 );
        l := [ l[1]*l[2], l[2]^2-2*l[3], l[3]^2 ];
    else
        l := Lucas( P, Q, k-1 );
        l := [ (P*l[1]+l[2])/2, ((P^2-4*Q)*l[1]+P*l[2])/2, Q*l[3] ];
    fi;
    return l;
end);

##############################################################################
##
#F  LucasMod(P,Q,N,k) - return the reduction modulo N of the k'th terms of
##  the Lucas Sequences U,V associated to x^2+Px+Q.
##
##  Recursive version is a trivial modification of the above function, but
##  the running time is dramatically decreased. The running time of the
##  the function is dominated by the cost of basic arithmetic operations.
##  If reductions mod N are enforced regularly, then these operations are
##  constant cost. If not, then they grow quickly as the Lucas sequence
##  itself grows exponentially.
##
##  See lib/primality.gi for a faster implementation.
##
InstallMethod(LucasMod,
"recursive version, reduce mod N regularly",
[IsInt,IsInt,IsInt,IsInt],
function(P,Q,N,k)
    local   l;
    if k = 0  then
        l := [ 0, 2, 1 ];
    elif k < 0  then
        l := LucasMod( P, Q, N, -k );
        if GcdInt( l[3], N ) <> 1 then return fail; fi;
        l := [ -l[1]/l[3], l[2]/l[3], 1/l[3] ];
    elif k mod 2 = 0  then
        l := LucasMod( P, Q, N, k/2 );
        l := [ l[1]*l[2], l[2]^2-2*l[3], l[3]^2 ];
    else
        l := LucasMod( P, Q, N, k-1 );
        l := [ (P*l[1]+l[2])/2, ((P^2-4*Q)*l[1]+P*l[2])/2, Q*l[3] ];
    fi;
    return l mod N;
end);


#############################################################################
##
#F  Fibonacci( <n> )  . . . . . . . . . . . . value of the Fibonacci sequence
##
##  A recursive  Fibonacci needs $O( Fibonacci(n) ) = O(2^n)$ bit operations.
##  An iterative version performs $n$ additions, the <i>th involving integers
##  with $i$ bits,  so  we  need $\sum_{i=1}^{n}{i} = O(n^2)$ bit operations.
##  The binary recursion of 'Lucas' reduces the number of calls to $log2(n)$.
##  The number of bit operations now is $O(n)$, i.e., the size of the result.
##
InstallGlobalFunction(Fibonacci,function ( n )
    return Lucas( 1, -1, n )[ 1 ];
end);


#############################################################################
##
#F  Bernoulli( <n> )  . . . . . . . . . . . . value of the Bernoulli sequence
##
InstallGlobalFunction(Bernoulli,
    MemoizePosIntFunction(
    function ( n )
        local   brn, bin, j;
        if   n < 0  then
            Error("Bernoulli: <n> must be nonnegative");
        elif n = 0  then
            brn := 1;
        elif n = 1  then
            brn := -1/2;
        elif n mod 2 = 1  then
            brn := 0;
        else
            bin := 1;
            brn := 1;
            for j  in [1..n-1]  do
                bin := (n+2-j)/j * bin;
                brn := brn + bin * Bernoulli(j);
            od;
            brn := - brn / (n+1);
        fi;
        return brn;
    end,
    rec(errorHandler :=
        function ( n )
            if n <> 0 then
                Error("Bernoulli: <n> must be a nonnegative integer");
            fi;
            return 1;
        end
    )
));


InstallGlobalFunction(AllLinearDiophantineSolutions,function(w,count,s)
local g,a,sol,l,r,pos;
  if Length(w)=0 then return [];fi;
  g:=Gcd(w);
  if s mod g<>0 then
    return [];
  fi;
  if Length(w)=1 then return [[s/w[1]]];fi;
  # kill gcd to keep numbers small
  w:=List(w,x->x/g);
  s:=s/g;

  sol:=[];
  l:=0*w; # zero out
  r:=s;
  pos:=1;
  while l[1]>=0 do
    a:=Minimum(count[pos],QuoInt(r,w[pos]));
    l[pos]:=a;
    r:=r-a*w[pos];
    if pos=Length(l) then
      # solution?
      if r=0 then Add(sol,ShallowCopy(l));fi;
      # now go back and decrement prior
      r:=r+l[pos]*w[pos];
      l[pos]:=-1;
      while pos>0 and l[pos]<0 do
        pos:=pos-1;
        if (pos>0 and l[pos]>=0) then
          l[pos]:=l[pos]-1;
          if l[pos]>=0 then
            r:=r+w[pos];
          fi;
        fi;
      od;

      if pos>0 then
        pos:=pos+1; # next value to calc
      fi;

    else
      pos:=pos+1;
    fi;
  od;
  return sol;
end);

# Brute-force algorithms that gives (as indices) all ways how to sum subsets
# of `from` to obtain `to`
InstallGlobalFunction(AllSubsetSummations,function(to, from, arg...)
local limit,erg,nerg,perm,i,e,c,sel,sz,dio,part,d,j,k,kk,ac,lc,nc;
  if Length(arg)>0 then limit:=arg[1];
  else limit:=infinity;fi;
  erg:=[[]];
  to:=ShallowCopy(to);
  perm:=Sortex(to)^-1;
  for i in to do
    nerg:=[];
    for e in erg do
      sel:=Filtered(Difference([1..Length(from)],Union(e)),x->from[x]<=i);

      sz:=Collected(from{sel});
      part:=List(sz,x->Filtered(sel,y->from[y]=x[1]));
      dio:=AllLinearDiophantineSolutions(List(sz,x->x[1]),List(sz,x->x[2]),i);
      c:=[];
      for d in dio do
        ac:=[[]];
        for j in [1..Length(d)] do
          lc:=Combinations(part[j],d[j]);
          nc:=[];
          for k in ac do
            for kk in lc do
              Add(nc,Union(k,kk));
            od;
          od;
          ac:=nc;
        od;
    #Print(Position(erg,e),"/",Length(erg),"d:",d,"->",Length(ac),"\n");
        Append(c,ac);
        if Length(c)>limit then return fail;fi;
      od;

      if Length(nerg)+Length(c)>limit then return fail;fi;
      for j in c do
        Add(nerg,Concatenation(e,[j]));
      od;

    od;
    erg:=nerg;
  od;
  return List(erg,x->Permuted(x,perm));
end);
