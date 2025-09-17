#@local TestGens,m,gensets
gap> START_TEST("stabchain.tst");
gap> TestGens := function(g)
> local m, sc;
> m := SortedList(List(g));
> if Size(m) <> Size(g) or Size(Set(m)) <> Size(m) or
>    Group(m) <> g then Print("0"); fi;
> ChangeStabChain(StabChainMutable(g), [1..10], false);
> if m <> SortedList(List(g)) then Print("1"); fi;
> if m <> SortedList(List(g, x -> x)) then Print("2"); fi;
> ChangeStabChain(StabChainMutable(g), [10,9..1], false);
> if m <> SortedList(List(g)) then Print("3"); fi;
> if m <> SortedList(List(g, x -> x)) then Print("3"); fi;
> ChangeStabChain(StabChainMutable(g), [1,10,11,12,13,14,15,2,3,4,5,6,7,8], false);
> if m <> SortedList(List(g)) then Print("5"); fi;
> if m <> SortedList(List(g, x -> x)) then Print("4"); fi;
> sc := StabChainBaseStrongGenerators([1,10,11,12,13,14,15,2,3,4,5,6,7,8], 
>  StrongGeneratorsStabChain(StabChainMutable(g)), ());
> g := Group(GeneratorsOfGroup(g), ());
> SetStabChainMutable(g, sc);
> if m <> SortedList(List(g)) then Print(g,"6"); fi;
> if m <> SortedList(List(g, x -> x)) then Print(g,"7"); fi;
> return true;
> end;;
gap> TestGens(Group(()));;
gap> # MinimalGeneratingSets of the transitive groups of degrees 2..7, i.e
gap> # a:=Concatenation(List([2..7], x->AllTransitiveGroups(NrMovedPoints, x)));
gap> # gensets:=List(a, MinimalGeneratingSet);
gap> gensets := [ [ (1,2) ], [ (1,2,3) ], [ (2,3), (1,2,3) ], [ (1,2,3,4) ],
>  [ (1,2)(3,4), (1,4)(2,3) ], [ (2,4), (1,2,3,4) ], [ (2,4,3), (1,3)(2,4) ],
>  [ (2,4,3), (1,4,2,3) ], [ (1,2,3,4,5) ], [ (2,5)(3,4), (1,2,3,4,5) ],
>  [ (2,3,5,4), (1,2,3,4,5) ], [ (1,2,3,4,5), (3,4,5) ],
>  [ (1,2,3,4,5), (1,2) ], [ (1,6,5,4,3,2) ],
>  [ (1,3,5)(2,4,6), (1,4)(2,3)(5,6) ], [ (2,6)(3,5), (1,6,5,4,3,2) ],
>  [ (2,5)(3,6), (1,3,5)(2,4,6) ], [ (1,2,3,4,5,6), (1,5,3)(2,4,6) ],
>  [ (1,4)(3,6), (1,6,5,4,3,2) ], [ (2,3)(5,6), (1,3,5)(2,4,6) ],
>  [ (1,3,5)(2,4,6), (1,4)(2,6)(3,5) ], [ (3,5)(4,6), (1,2,3,4,5,6) ],
>  [ (1,2)(3,4,5,6), (1,5,3) ], [ (1,2)(4,5), (1,6,5,4,3,2) ],
>  [ (1,2,3,4,6), (1,4)(5,6) ], [ (1,4)(2,5)(3,6), (1,5,3)(4,6) ],
>  [ (1,2,3,4,6), (1,2)(3,4)(5,6) ], [ (1,2,3,4,5), (4,5,6) ],
>  [ (1,2,3,4,5,6), (1,2) ], [ (1,2,3,4,5,6,7) ],
>  [ (2,7)(3,6)(4,5), (1,2,3,4,5,6,7) ], [ (2,3,5)(4,7,6), (1,2,3,4,5,6,7) ],
>  [ (2,6,5,7,3,4), (1,6,4,2,7,5,3) ], [ (1,2,3,4,5,6,7), (1,2)(3,6) ],
>  [ (1,2,3,4,5,6,7), (5,6,7) ], [ (1,2,3,4,5,6,7), (1,2) ] ];;
gap> ForAll(gensets, x -> TestGens(Group(x)));
true
gap> TestGens(Group((1,2,3),(4,5,6)));;
gap> TestGens(Group((1,2,3)(4,5,6)));;
gap> TestGens(Group((2,4,6),(1,3,5),(1,3)));;
gap> m := StabChainBaseStrongGenerators(
>    [1,3..1999],
>    List([1,3..1999], x -> (x,x+1)),
>    ());;
gap> Log(SizeStabChain(m), 2) = 1000;
true
gap> STOP_TEST("stabchain.tst");
