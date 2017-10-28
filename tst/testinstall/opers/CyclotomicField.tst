#############################################################################
##
#W  CyclotomicField.tst      GAP Library                      Chris Jefferson
##
gap> START_TEST("CyclotomicField.tst");
gap> x := List([1..8], CyclotomicField);
[ Rationals, Rationals, CF(3), GaussianRationals, CF(5), CF(3), CF(7), CF(8) ]
gap> y := List([1..8], CyclotomicField);
[ Rationals, Rationals, CF(3), GaussianRationals, CF(5), CF(3), CF(7), CF(8) ]
gap> FlushCaches();
gap> z := List([1..8], CyclotomicField);
[ Rationals, Rationals, CF(3), GaussianRationals, CF(5), CF(3), CF(7), CF(8) ]
gap> List([1..8], i -> IsIdenticalObj(x[i], y[i]));
[ true, true, true, true, true, true, true, true ]
gap> List([1..8], i -> IsIdenticalObj(x[i], z[i]));
[ true, true, false, true, false, false, false, false ]
gap> STOP_TEST( "CyclotomicField.tst", 1);

#############################################################################
##
#E
