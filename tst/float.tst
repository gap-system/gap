#############################################################################
##
#W  float.tst                   GAP Tests                         Stefan Kohl
##
#H  @(#)$Id: float.tst,v 1.2 2009/09/24 15:47:35 alexk Exp $
##

gap> START_TEST("$Id: float.tst,v 1.2 2009/09/24 15:47:35 alexk Exp $");

gap> if VERSION = "4.dev" then Float := MACFLOAT_STRING; fi;
gap> Int(Float("2")/Float("3"));
0
gap> Int(Float("237")/Float("3"));
79
gap> Int(Float("239")/Float("3"));
79
gap> Rat(Float("355")/Float("113"));
355/113
gap> Rat(Float("0"));
0
gap> Rat(Float("-1")/Float("2"));
-1/2
gap> Int(Float("-1")/Float("2"));
-1
gap> Int(Float("-1")/Float("3"));
-1
gap> Int(Float("-4")/Float("3"));
-2
gap> 2-Float("-2")/Float("3")*3/2+1;
4
gap> IsFloat(last);
true
gap> IsInt(Int(Float("-1")/Float("3")));
true
gap> r:=Rat("2.7182818");; r:=Rat(Float(String(NumeratorRat(r)))/Float(String(DenominatorRat(r))));
2721/1001
gap> Float(String(NumeratorRat(r)))/Float(String(DenominatorRat(r)));
2.71828
gap> AbsoluteValue(Float("1")/Float("2"));
0.5
gap> AbsoluteValue(Float("-1")/Float("2"));
0.5
gap> AbsoluteValue(-Float("1")/Float("2"));
0.5
gap> AbsoluteValue(-Float("0"));
0
gap> Float("-1")/Float("2") < 1/4;
true
gap> Float("-1")/Float("2") > -2/3;
true
gap> # Float([[1/2,0],[-1,5/7]]);
[ [ 0.5, 0 ], [ -1, 0.714286 ] ]
gap> STOP_TEST( "float.tst", 1000000 );

#############################################################################
##
#E  float.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here