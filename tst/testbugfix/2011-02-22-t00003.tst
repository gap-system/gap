##  Check that a new SpecialPcgs is created for which 
##    LGWeights can be set properly
##    see my mail of 2011/02/22 to gap-dev for details. BH
##
gap> G := PcGroupCode(640919430184532635765016241891519311\
> 98104010779278323886032740084599, 192200);;
gap> ind := InducedPcgsByPcSequence(FamilyPcgs (G), 
> [ G.1*G.2*G.3*G.4^2*G.5^2, G.4^2*G.5^3, G.6, G.7 ]);;
gap> H := GroupOfPcgs (ind);;
gap> pcgs := SpecialPcgs (H);;
gap> syl31 := SylowSystem( H )[3];;
gap> w := LGWeights( SpecialPcgs( syl31 ) );
[ [ 1, 1, 31 ], [ 1, 1, 31 ] ]
