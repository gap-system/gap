gap> START_TEST( "nanoseconds.tst" );
gap> t := NanosecondsSinceEpoch();;
gap> f := function(t)
> local t2;
> if t <> fail then
> t2 := NanosecondsSinceEpoch();
> return IsPosInt(t2 - t);
> fi;
> end;;
gap> f(t);
true
gap> STOP_TEST( "nanoseconds.tst", 1 );

