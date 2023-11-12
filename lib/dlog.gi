#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Lübeck.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods related to discrete logarithms.
##  The code was copied from the StandardFF package.
##


#############################################################################
##
#F  DLogShanks( <base>, <x>, <r> )
##
##  Let <base> be a multiplicative element of order <r>.
##  Return an integer l such that <x> = <base>^l holds,
##  or 'fail' if no such l exists.
##
InstallGlobalFunction( DLogShanks, function(base, x, r)
  local rr, baby, ord, giant, t, pos, i, j;
  rr := RootInt(r, 2);
  baby := [One(base)];
  if x = baby[1] then
    return 0;
  fi;
  for i in [1..rr-1] do
    baby[i+1] := baby[i]*base;
    if x = baby[i+1] then
      return i;
    fi;
  od;
  giant := baby[rr]*base;
  ord := [0..rr-1];
  SortParallel(baby, ord);
  t := x;
  for j in [1..QuoInt(r, rr)+1] do
    t := t*giant;
    pos := PositionSet(baby, t);
    if IsInt(pos) then
      return (ord[pos] - j * rr) mod r;
    fi;
  od;
  return fail;
end );


#############################################################################
##
#F  DLog( <base>, <x>[, <m>] )
##
##  recursive method, <m> can be the order m of <base> or its factorization
##  Let r be the largest prime factor of m, then we use
##     <base>^e = <x> with e = a + b*r where 0 <= a < r and
##     0 <= b < m/r,
##  and compute a with DLogShanks and b by recursion.
##
InstallGlobalFunction( DLog, function(base, x, m...)
  local r, mm, mp, a, b;
  if Length(m) = 0 then
    m := Order(base);
  else
    m := m[1];
  fi;
  if not IsList(m) then
    m := Factors(m);
  fi;
  if Length(m) = 1 then
    return DLogShanks(base, x, m[1]);
  fi;
  r := m[Length(m)];
  mm := m{[1..Length(m)-1]};
  mp := Product(mm);
  a := DLogShanks(base^mp, x^mp, r);
  if a = fail then
    return fail;
  fi;
  b := DLog(base^r, x/(base^a), mm);
  if b = fail then
    return fail;
  fi;
  return a + b*r;
end );


#############################################################################
##
##  used as method for LogFFE
##
BindGlobal( "DoDLog", function(x, base)
  local ob, o, e;
  ob := Order(base);
  o := Order(x);
  if ob mod o <> 0 then
    return fail;
  fi;
  if ob <> o then
    e := ob/o;
    base := base^e;
  else
    e := 1;
  fi;
  return DLog(base, x, o) * e;
end );
