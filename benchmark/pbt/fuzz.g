#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Randomized correctness test of the partition backtrack entry points in
##  full symmetric groups. For small degrees the results are also compared
##  with brute force over all elements. Usage:
##
##    gap -q -A benchmark/pbt/fuzz.g
##    gap -q -A -c 'degs:=[8..10];; offs:=[0,3];; seeds:=[1..40];;' benchmark/pbt/fuzz.g
##
##  Prints one line per test. A line ending in BAD marks an invalid result,
##  a line "oracle-..." the brute force value for the test of the same name;
##  benchmark/pbt/fuzzcheck.sh summarizes the output.
##

if not IsBound( degs )  then  degs := [ 2 .. 7 ];     fi;
if not IsBound( offs )  then  offs := [ 0, 3 ];       fi;
if not IsBound( seeds )  then  seeds := [ 1 .. 20 ];  fi;

if LoadPackage("transgrp", false) <> true then Print("needs the transgrp package\n"); QUIT; fi;
Out := function(arg) CallFuncList(Print, arg); Print("\n"); end;

RandSub := function(G, dom, kind)
  local n, k, part, gens;
  n := Length(dom);
  if kind = 0 then
    return Group(List([1..Random([1,2])], i -> Random(G)), ());
  elif kind = 1 then
    # moves only part of the domain
    part := dom{[1..Random([1..n])]};
    return Group(List([1..Random([1,2])], i -> Random(SymmetricGroup(part))), ());
  elif kind = 2 and n >= 2 and n <= 30 then
    k := Random([1..NrTransitiveGroups(n)]);
    return TransitiveGroup(n, k)^MappingPermListList([1..n], dom);
  else
    # direct product of two pieces on disjoint subsets
    k := Random([0..n]);
    gens := [];
    if k >= 2 then Add(gens, Random(SymmetricGroup(dom{[1..k]}))); fi;
    if n - k >= 2 then Add(gens, Random(SymmetricGroup(dom{[k+1..n]}))); fi;
    return Group(gens, ());
  fi;
end;;

Check := function(tag, ok, val)
  if ok = false then Out(tag, " BAD"); else Out(tag, " ", val); fi;
end;;

for n in degs do for o in offs do for s in seeds do
  Reset(GlobalMersenneTwister, 100000*n + 1000*o + s);
  Reset(GlobalRandomSource, 100000*n + 1000*o + s);
  dom := [o+1..o+n];
  G := SymmetricGroup(dom);
  T := TrivialSubgroup(G);
  gE := RandSub(G, dom, s mod 4);
  c := Random(G);
  if s mod 3 = 0 then gF := RandSub(G, dom, s mod 4); else gF := gE^c; fi;
  x := Random(G); y := Random(G);
  z := x * (o+n, o+n+1);            # moves a point outside the domain of G
  A := Set(List([1..Random([0..n])], i -> Random(dom)));
  B := Set(List(A, a -> a^Random(G)));
  if s mod 5 = 0 then B := Set(List([1..Length(A)], i -> Random(dom))); fi;
  tag := Concatenation("c ", String(n), " ", String(o), " ", String(s));
  # copies so that no attributes carry over between libraries
  gE := Group(GeneratorsOfGroup(gE), ()); gF := Group(GeneratorsOfGroup(gF), ());

  r := ConjugatorPermGroup(G, gE, gF);
  Check(Concatenation(tag, " conj"), r = fail or (r in G and gE^r = gF), r = fail);
  r := ConjugatorPermGroup(G, gE, gF, gE, gF);
  Check(Concatenation(tag, " conjLR"), r = fail or (r in G and gE^r = gF), r = fail);
  N := NormalizerPermGroup(G, Group(GeneratorsOfGroup(gE), ()));
  Check(Concatenation(tag, " norm"),
        ForAll(GeneratorsOfGroup(N), g -> g in G and gE^g = gE), Size(N));
  C := RepOpElmTuplesPermGroup(false, G, [x], [x], T, T);
  Check(Concatenation(tag, " cent"),
        ForAll(GeneratorsOfGroup(C), g -> x^g = x), Size(C));
  C := RepOpElmTuplesPermGroup(false, G, [x], [x], Group(x, ()), Group(x, ()));
  Check(Concatenation(tag, " centL"),
        ForAll(GeneratorsOfGroup(C), g -> x^g = x), Size(C));
  C := RepOpElmTuplesPermGroup(false, G, [x, y], [x, y], T, T);
  Check(Concatenation(tag, " cent2"),
        ForAll(GeneratorsOfGroup(C), g -> x^g = x and y^g = y), Size(C));
  C := RepOpElmTuplesPermGroup(false, G, [z], [z], T, T);
  Check(Concatenation(tag, " centout"),
        ForAll(GeneratorsOfGroup(C), g -> g in G and z^g = z), Size(C));
  r := RepOpElmTuplesPermGroup(true, G, [x, y], [x^c, y^c], T, T);
  Check(Concatenation(tag, " tup"), r <> fail and x^r = x^c and y^r = y^c, r = fail);
  r := RepOpElmTuplesPermGroup(true, G, [x, y], [x^c, (y*x)^c], T, T);
  Check(Concatenation(tag, " tup2"),
        r = fail or (r in G and x^r = x^c and y^r = (y*x)^c), r = fail);
  r := RepOpElmTuplesPermGroup(true, G, [z], [z^c], T, T);
  Check(Concatenation(tag, " tupout"), r = fail or (r in G and z^r = z^c), r = fail);
  if n <= 8 then   # property searches have no refiners
  S := SubgroupProperty(G, g -> OnSets(A, g) = A);
  Check(Concatenation(tag, " subprop"),
        ForAll(GeneratorsOfGroup(S), g -> OnSets(A, g) = A), Size(S));
  S := SubgroupProperty(G, g -> x^g = x, Group(x, ()));
  Check(Concatenation(tag, " subpropL"),
        ForAll(GeneratorsOfGroup(S), g -> x^g = x), Size(S));
  r := ElementProperty(G, g -> OnSets(A, g) = B);
  Check(Concatenation(tag, " elmprop"), r = fail or OnSets(A, r) = B, r = fail);
  fi;

  if n <= 7 then
    el := AsList(G);
    oracle := [
      [ "conj", ForAll(el, g -> gE^g <> gF) ],
      [ "norm", Number(el, g -> gE^g = gE) ],
      [ "cent", Number(el, g -> x^g = x) ],
      [ "cent2", Number(el, g -> x^g = x and y^g = y) ],
      [ "centout", Number(el, g -> z^g = z) ],
      [ "tup2", ForAll(el, g -> x^g <> x^c or y^g <> (y*x)^c) ],
      [ "tupout", ForAll(el, g -> z^g <> z^c) ],
      [ "subprop", Number(el, g -> OnSets(A, g) = A) ],
      [ "elmprop", ForAll(el, g -> OnSets(A, g) <> B) ] ];
    for k in oracle do
      Out(tag, " oracle-", k[1], " ", k[2]);
    od;
  fi;
od; od; od;
QUIT;
