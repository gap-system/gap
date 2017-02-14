# 2013/08/08 (AH)
gap> free:=FreeGroup("a","b");
<free group on the generators [ a, b ]>
gap> product:=free/ParseRelators(free,"a2,b3");;
gap> SetIsFinite(product,false);
gap> GrowthFunctionOfGroup(product,12);
[ 1, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128 ]
gap> GrowthFunctionOfGroup(MathieuGroup(12));
[ 1, 5, 19, 70, 255, 903, 3134, 9870, 25511, 38532, 16358, 382 ]
