#@local fam,cat,type,a
gap> START_TEST("trace.tst");

#
gap> TraceImmediateMethods( "cheese" );
Error, Usage: TraceImmediateMethods( [bool] )

#
gap> fam := NewFamily("MockFamily");;
gap> cat := NewCategory("IsMockObj",
>               IsMultiplicativeElementWithInverse and
>               IsAdditiveElementWithInverse and
>               IsCommutativeElement and
>               IsAssociativeElement and
>               IsAdditivelyCommutativeElement);;
gap> type := NewType(fam, cat and IsAttributeStoringRep);;

#
gap> TraceImmediateMethods(true);

# add immediate method that requires extra filter
gap> InstallImmediateMethod( Size, "for abelian mockobj", cat and IsAbelian, 0, x -> 1 );
gap> a := Objectify(type,rec());;
gap> Size(a);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Size' on 1 arguments
gap> SetIsAbelian(a, true);
#I RunImmediateMethods
#I  immediate: Size: for abelian mockobj at stream:1
gap> Size(a);
1

# add immediate method that requires no extra filter
gap> InstallImmediateMethod( Size, cat, 0, x -> 42 );
gap> a := Objectify(type,rec());;
#I RunImmediateMethods
#I  immediate: Size at stream:1
gap> Size(a);
42
gap> SetIsAbelian(a, true);
#I RunImmediateMethods
gap> Size(a);
42

#
gap> TraceImmediateMethods(false);

#
gap> STOP_TEST("trace.tst", 1);
