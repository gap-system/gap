##  bug 17 for fix 5 (example taken from `vspcmat.tst')
gap> w:= LeftModuleByGenerators( GF(9),
> [ [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ],
> [ [ Z(27), Z(3) ], [ Z(3), Z(3) ] ],
> [ [ 0*Z(3), Z(3) ], [ Z(3), Z(3) ] ] ] );;
gap> w = AsVectorSpace( GF(3), w );
true
