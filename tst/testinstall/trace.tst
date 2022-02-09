#@local fam,cat,type,a,testTrace
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
gap> testTrace := function(f)
> TraceInternalMethods();
> f();
> UntraceInternalMethods();
> return GetTraceInternalMethodsCounts();
> end;;
gap> testTrace({} -> [1,2]+[3,4]);
rec( Sum := rec( ("dense plain list") := rec( ("dense plain list") := 1 ), 
      integer := rec( integer := 2 ) ) )
gap> testTrace({} -> 2^(3,4,5));
rec( Pow := rec( integer := rec( ("permutation (small)") := 1 ) ) )
gap> testTrace({} -> [4,3] - [2,3]);
rec( AInvSameMut := rec( ("dense plain list") := 1, integer := 2 ), 
  Diff := rec( ("dense plain list") := rec( ("dense plain list") := 1 ) ), 
  Sum := rec( ("dense plain list") := rec( ("dense plain list") := 1 ), 
      integer := rec( integer := 2 ) ) )
gap> testTrace({} -> Inverse(3));
rec( Inv := rec( integer := 1 ) )
gap> testTrace({} -> Inverse(PartialPerm([1,2,3])));
rec( Inv := rec( ("partial perm (small)") := 1 ) )
gap> testTrace({} -> AdditiveInverse(2/3));
rec( AInvMut := rec( rational := 1 ), 
  Quo := rec( integer := rec( integer := 1 ) ) )
gap> testTrace({} -> AdditiveInverse([2,3,4]));
rec( AInvMut := rec( integer := 3, ("plain list of cyclotomics") := 1 ) )
gap> testTrace({} -> Inverse([[1,0],[0,1]]));
rec( AInvSameMut := rec( integer := 4 ), 
  Inv := rec( ("dense plain list") := 1, integer := 2 ), 
  Mod := rec( integer := rec( integer := 1 ) ), One := rec( integer := 1 ), 
  Prod := rec( integer := rec( integer := 8 ) ), 
  ZeroSameMut := rec( integer := 1 ) )
gap> testTrace({} -> 55/2 mod 7);
rec( Mod := rec( rational := rec( integer := 1 ) ), 
  Quo := rec( integer := rec( integer := 1 ) ) )
gap> testTrace({} -> Comm(Transformation([1,2,3]), Transformation([3,2,1])));
rec( 
  Comm := 
    rec( ("transformation (small)") := rec( ("transformation (small)") := 1 ) 
     ), Inv := rec( ("transformation (small)") := 1 ), 
  InvSameMut := rec( ("transformation (small)") := 1 ), 
  LQuo := 
    rec( ("transformation (small)") := rec( ("transformation (small)") := 1 ) 
     ), 
  Prod := 
    rec( ("transformation (small)") := rec( ("transformation (small)") := 3 ) 
     ) )
gap> testTrace({} -> OneMutable(1/2));
rec( One := rec( rational := 1 ), 
  Quo := rec( integer := rec( integer := 1 ) ) )
gap> testTrace({} -> OneMutable([[1,2],[3,4]]));
rec( Mod := rec( integer := rec( integer := 1 ) ), 
  One := rec( ("dense plain list") := 1, integer := 1 ), 
  ZeroSameMut := rec( integer := 1 ) )
gap> testTrace({} -> ZeroMutable(1/2));
rec( Quo := rec( integer := rec( integer := 1 ) ), 
  ZeroMut := rec( rational := 1 ) )
gap> testTrace({} -> ZeroMutable([[1,2],[3,4]]));
rec( ZeroMut := rec( ("dense plain list") := 3, integer := 4 ) )
gap> testTrace({} -> LeftQuotient(4,2));
rec( InvSameMut := rec( integer := 1 ), 
  LQuo := rec( integer := rec( integer := 1 ) ), 
  Prod := rec( rational := rec( integer := 1 ) ) )
gap> STOP_TEST("trace.tst", 1);
