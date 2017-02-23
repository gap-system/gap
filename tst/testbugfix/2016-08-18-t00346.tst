# 2016/8/18 (AH)
gap> src := FreeGroup(3);;
gap> src := src / [src.3*src.1];;
gap> SetReducedMultiplication(src);
gap> f1:=src.1;;f2:=src.2;;f3:=src.3;;
gap> gens := [ f1, f2, f2^-1*f3*f2 ];;
gap> fp := IsomorphismFpGroupByGeneratorsNC(src,gens,"F");;
gap> dst := Image(fp);;wrd:=RelatorsOfFpGroup(dst)[1];;
gap> m:=MappedWord(wrd,GeneratorsOfGroup(FreeGroupOfFpGroup(dst)),gens);       
<identity ...>
