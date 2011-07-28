#############################################################################
##
#W  ngens.tst                 GAP4 Package `RCWA'                 Stefan Kohl
##
#############################################################################

gap> START_TEST( "ngens.tst" );
gap> RCWADoThingsToBeDoneBeforeTest();
gap> nu  := ClassShift(0,1);;
gap> t   := ClassReflection(0,1);;
gap> tau := ClassTransposition(0,2,1,2);;
gap> a   := RcwaMapping([[3,0,2],[3,1,4],[3,0,2],[3,-1,4]]);;
gap> k := Random(Difference([-20..20],[0]));;
gap> p := Minimum(Difference(Primes,Set(Factors(AbsInt(2*k)))));;
gap> Comm(Comm(ClassShift(1,2)^k,ClassShift(1,p)),ClassShift(1,2*p))
>  = ClassShift(1,2*p) * ClassShift(p+1,2*p)^-1;
true
gap> (ClassShift(1,3)*ClassShift(2,3))^(a^-1) = ClassShift(1,2)^2;
true
gap> theta := ClassTransposition(0,6,1,6) * ClassTransposition(0,6,3,6);;
gap> gamma1 := RcwaMapping([[1,0,2],[-3,9,2],[3,4,2],[3,-7,2]]);;
gap> (ClassShift(1,2)^2)^gamma1 * Comm(ClassShift(1,2)^2,ClassShift(0,3))
>    = theta;
true
gap> gamma2 :=  ClassShift(4,6) * ClassShift(0,6)^-1 * ClassShift(2,6)^-1
>             * ClassTransposition(0,6,1,6) * ClassTransposition(0,6,4,6)
>             * ClassTransposition(3,6,5,6);;
gap> (theta * theta^ClassTransposition(2,6,3,6))^gamma2
>    = ClassTransposition(1,3,2,3);
true
gap> upsilon := ClassShift(1,2)^2;;
gap> gamma3 := ClassTransposition(1,3,2,3) * ClassTransposition(0,6,3,6) *
>              ClassTransposition(2,3,0,6) * a^-1;;
gap> gamma4 := ClassTransposition(1,3,3,6) * a^-1;;
gap> upsilon^(a^(nu^3)) * upsilon^(a^nu) * upsilon^(a^(nu^-1))
> * (upsilon*upsilon^tau)^-1 = nu^2;
true
gap> ClassTransposition(1,3,2,3)^gamma3 * ClassTransposition(1,3,2,3)^gamma4
>  = tau;
true
gap> Comm(ClassShift(1,2),ClassShift(1,3))^
>    Comm(ClassShift(0,2),ClassShift(0,3))
>  * Comm(ClassShift(0,2),ClassShift(2,3)) = ClassTransposition(1,3,2,3);
true
gap> RCWADoThingsToBeDoneAfterTest();
gap> STOP_TEST( "ngens.tst", 15000000 );

#############################################################################
##
#E  ngens.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here