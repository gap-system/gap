# MTX.DegreeSplittingField on a module no test has been run on
gap> m:=GModuleByMats([[[0,1],[-1,0]]*Z(3)^0],GF(3));;
gap> MTX.DegreeSplittingField(m);
2
gap> MTX.IsAbsolutelyIrreducible(m);
false
