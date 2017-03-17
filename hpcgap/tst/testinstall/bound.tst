gap> START_TEST("bound.tst");
gap> S := SymmetricGroup(2);;
gap> IsBound(S!.cheese);
false
gap> IsBound(S!.Size);
true
gap> f := ( -> IsBound(S!.cheese) );; f();
false
gap> f := ( -> IsBound(S!.Size) );; f();
true
gap> r := rec(a := 2, b := fail);;
gap> IsBound(r.a);
true
gap> IsBound(r.b);
true
gap> IsBound(r.c);
false
gap> f := ( -> IsBound(r.a) );; f();
true
gap> f := ( -> IsBound(r.b) );; f();
true
gap> f := ( -> IsBound(r.c) );; f();
false
gap> STOP_TEST("bound.tst", 1);
