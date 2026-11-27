# A failing CycList call left the entries preceding the invalid one in the
# kernel's buffer for cyclotomic results. The next power, inverse or Galois
# conjugate was then wrong, and inverting a matrix could crash.
gap> e := E(4);;
gap> CycList( [ 1, fail ] );
Error, CycList: each entry must be a rational (not the value 'fail')
gap> e^3;
-E(4)
gap> CycList( [ 1, fail ] );
Error, CycList: each entry must be a rational (not the value 'fail')
gap> (2*e)^2;
-4
gap> CycList( [ 1, fail ] );
Error, CycList: each entry must be a rational (not the value 'fail')
gap> GaloisCyc( e, -1 );
-E(4)
gap> CycList( [ 1, fail ] );
Error, CycList: each entry must be a rational (not the value 'fail')
gap> 1/e;
-E(4)
gap> CycList( [ 1, fail ] );
Error, CycList: each entry must be a rational (not the value 'fail')
gap> [ [ e, 0 ], [ 0, -e ] ]^-1;
[ [ -E(4), 0 ], [ 0, E(4) ] ]

# CycList did not terminate for the empty list.
gap> CycList( [] );
0
