gap> START_TEST("SolvableQuotient.tst");

#
gap> f := FreeGroup( "a", "b", "c", "d" );;
gap> fp := f / [ f.1^2, f.2^2, f.3^2, f.4^2, f.1*f.2*f.1*f.2*f.1*f.2,
>  f.2*f.3*f.2*f.3*f.2*f.3*f.2*f.3, f.3*f.4*f.3*f.4*f.3*f.4,
> f.1^-1*f.3^-1*f.1*f.3, f.1^-1*f.4^-1*f.1*f.4,
> f.2^-1*f.4^-1*f.2*f.4 ];;
gap> hom:=EpimorphismSolvableQuotient(fp,300);Size(Image(hom));
[ a, b, c, d ] -> [ f1*f2, f1*f2, f2*f3, f2 ]
12
gap> hom:=EpimorphismSolvableQuotient(fp,[2,3]);Size(Image(hom));
[ a, b, c, d ] -> [ f1*f2*f4, f1*f2*f6*f8, f2*f3, f2 ]
1152
gap> EpimorphismSolvableQuotient(fp,fail);
Error, <primes> must be either an integer, a list of integers, or a list of in\
teger lists

#
gap> SolvableQuotient(fp,300);
rec( image := <pc group of size 12 with 3 generators>, 
  imgs := [ f1*f2, f1*f2, f2*f3, f2 ], source := <fp group on the generators 
    [ a, b, c, d ]> )
gap> SolvableQuotient(fp,[2,3]);
rec( image := <pc group of size 1152 with 9 generators>, 
  imgs := [ f1*f2*f4, f1*f2*f6*f8, f2*f3, f2 ], 
  source := <fp group on the generators [ a, b, c, d ]> )
gap> SolvableQuotient(fp,fail);
Error, <primes> must be either an integer, a list of integers, or a list of in\
teger lists

#
gap> STOP_TEST("SolvableQuotient.tst");
