gap> START_TEST("nq.tst");
gap> 
gap> ################################################
gap> #
gap> ################################################
gap> G := FreeGroup( 2 );;
gap> H := NilpotentQuotient( G, 10 );;
gap> ForAll( RelativeOrders(Collector(H)), IsZero );
true
gap> List( LowerCentralSeries( H ), HirschLength );
[ 226, 224, 223, 221, 218, 212, 203, 185, 155, 99, 0 ]
gap> 
gap> ################################################
gap> #
gap> ################################################
gap> G := FreeGroup( 3 );;
gap> H := NilpotentQuotient( G, 7 );;
gap> ForAll( RelativeOrders(Collector(H)), IsZero );
true
gap> List( LowerCentralSeries( H ), HirschLength );
[ 508, 505, 502, 494, 476, 428, 312, 0 ]
gap> 
gap> # Helper function
gap> AbelianInvariantsAlongLowerCentralSeries := function (H)
>   local lcs, i;
>   lcs := LowerCentralSeries( H );;
>   for i in [1..Length(lcs)-1] do
>     Print( AbelianInvariants( lcs[i] / lcs[i+1] ), "\n" );
>   od;
> end;;
gap> 
gap> 
gap> ################################################
gap> # examples/G1
gap> ################################################
gap> 
gap> G := FreeGroup( 2 );;
gap> G := G / [ LeftNormedComm([ G.2, G.1, G.1 ]),
>            LeftNormedComm([ G.1, G.2, G.2, G.2, G.2, G.2 ]),
>            LeftNormedComm([ G.2, G.1, G.2, G.2, G.2, G.1, G.2, G.2, G.1, G.1 ]) ];;
gap> H := NilpotentQuotient( G, 11 );
Pcp-group with orders [ 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 2, 0, 0, 2, 2, 0, 5, 2, 
  2, 2, 3, 0, 5, 5, 2, 2, 2, 2, 3, 0, 5, 5, 2, 2, 2, 2, 2, 2, 3, 0, 0, 5, 5, 
  5 ]
gap> AbelianInvariantsAlongLowerCentralSeries( H );
[ 0, 0 ]
[ 0 ]
[ 0 ]
[ 0 ]
[ 0, 0 ]
[ 0 ]
[ 0, 0 ]
[ 0, 2, 5 ]
[ 0, 2, 2, 3, 5, 5 ]
[ 0, 2, 2, 2, 3, 5, 5 ]
[ 0, 0, 2, 2, 2, 2, 3, 5, 5, 5 ]
gap> 
gap> 
gap> 
gap> ################################################
gap> # examples/G2
gap> ################################################
gap> 
gap> G := FreeGroup( 2 );;
gap> G := G / [ LeftNormedComm([ G.2, G.1, G.1 ]),
>            LeftNormedComm([ G.1, G.2, G.2, G.2, G.2 ]) ];;
gap> H := NilpotentQuotient( G );
Pcp-group with orders [ 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2 ]
gap> AbelianInvariantsAlongLowerCentralSeries( H );
[ 0, 0 ]
[ 0 ]
[ 0 ]
[ 0 ]
[ 0 ]
[ 2 ]
[ 2, 2 ]
[ 2, 2 ]
[ 2, 2 ]
[ 2 ]
gap> 
gap> ################################################
gap> # examples/G3
gap> ################################################
gap> G := FreeGroup( 3 );;
gap> G := G / [ LeftNormedComm([ G.2, G.1, G.1 ]),
>            LeftNormedComm([ G.1, G.2, G.2 ]),
>            LeftNormedComm([ G.3, G.1 ]),
>            LeftNormedComm([ G.3, G.2, G.2 ]),
>            LeftNormedComm([ G.2, G.3, G.3 ]) ];;
gap> H := NilpotentQuotient( G, 15 );
Pcp-group with orders [ 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 
  2 ]
gap> AbelianInvariantsAlongLowerCentralSeries( H );
[ 0, 0, 0 ]
[ 0, 0 ]
[ 0 ]
[ 2 ]
[ 2, 2 ]
[ 2 ]
[ 2 ]
[ 2 ]
[ 2 ]
[ 2 ]
[ 2 ]
[ 2 ]
[ 2 ]
[ 2 ]
[ 2 ]
gap> 
gap> ################################################
gap> # example/G4
gap> ################################################
gap> G := FreeGroup( 4 );;
gap> G := G / [ LeftNormedComm([ G.2, G.1, G.1 ]),
>            LeftNormedComm([ G.1, G.2, G.2 ]),
>            LeftNormedComm([ G.3, G.1 ]),
>            LeftNormedComm([ G.4, G.1 ]),
>            LeftNormedComm([ G.3, G.2, G.2 ]),
>            LeftNormedComm([ G.2, G.3, G.3, G.3 ]),
>            LeftNormedComm([ G.4, G.2 ]),
>            LeftNormedComm([ G.4, G.3, G.3 ]),
>            LeftNormedComm([ G.3, G.4, G.4 ]),
>            LeftNormedComm([ G.3, G.2, G.1, G.2 ]),
>            ];;
gap> H := NilpotentQuotient( G, 8 );
Pcp-group with orders [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 3, 0, 2, 
  2, 3, 3, 0, 6, 2, 2, 2, 3, 3, 6, 2, 3, 6, 2, 2, 2, 2, 3, 3, 3, 2, 2, 3, 3, 
  6, 2 ]
gap> AbelianInvariantsAlongLowerCentralSeries( H );
[ 0, 0, 0, 0 ]
[ 0, 0, 0 ]
[ 0, 0, 0 ]
[ 0, 0, 0 ]
[ 0, 0, 2, 3 ]
[ 0, 2, 2, 2, 3, 3, 3 ]
[ 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3 ]
[ 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3 ]
gap> 
gap> ################################################
gap> # examples/G5
gap> ################################################
gap> G := FreeGroup( 3 );;
gap> G := G / [ LeftNormedComm([ G.2, G.1, G.1, G.1 ]),
>            LeftNormedComm([ G.1, G.2, G.2 ]),
>            LeftNormedComm([ G.3, G.1 ]),
>            LeftNormedComm([ G.3, G.2, G.2, G.2 ]),
>            LeftNormedComm([ G.2, G.3, G.3 ]),
>            LeftNormedComm([ G.3, G.2, G.1, G.2, G.3 ]),
>            ];;
gap> H := NilpotentQuotient( G, 10 );
Pcp-group with orders [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 2, 0, 3, 3, 2, 2, 
  0, 0, 3, 3, 3, 2, 2, 2, 2, 0, 0, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 0, 3, 3, 3, 
  3, 3, 3, 3, 2, 2, 2, 5, 0, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 5, 3, 3, 3, 
  3, 3, 3, 3, 3, 3, 3, 3, 3 ]
gap> AbelianInvariantsAlongLowerCentralSeries( H );
[ 0, 0, 0 ]
[ 0, 0 ]
[ 0, 0, 0 ]
[ 0, 0 ]
[ 0, 0, 3 ]
[ 0, 0, 3, 3 ]
[ 0, 0, 2, 2, 3, 3, 3, 3 ]
[ 0, 2, 2, 2, 2, 3, 3, 3, 3, 9 ]
[ 0, 2, 2, 3, 3, 3, 3, 3, 3, 3, 5, 9 ]
[ 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5, 9, 9 ]
gap> 
gap> STOP_TEST( "nq.tst", 10000000);
