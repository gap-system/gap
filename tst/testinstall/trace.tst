gap> START_TEST("trace.tst");
gap> g:= Group( (1,2,3), (1,2) );;
gap> TraceImmediateMethods( );
gap> g:= Group( (1,2,3), (1,2) );;
#I  immediate: Size
#I  immediate: IsCyclic
#I  immediate: IsCommutative
#I  immediate: IsTrivial
gap> UntraceImmediateMethods();
gap> g:= Group( (1,2,3), (1,2) );;
gap> TraceImmediateMethods( true );
gap> g:= Group( (1,2,3), (1,2) );;
#I  immediate: Size
#I  immediate: IsCyclic
#I  immediate: IsCommutative
#I  immediate: IsTrivial
gap> TraceImmediateMethods( false );
gap> g:= Group( (1,2,3), (1,2) );;
gap> TraceImmediateMethods( "cheese" );
Error, Usage: TraceImmediateMethods( [bool] )
gap> STOP_TEST("trace.tst", 1);
