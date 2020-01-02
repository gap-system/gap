#
gap> SetAssertionLevel(fail);
Error, SetAssertionLevel: <level> must be a non-negative small integer (not th\
e value 'fail')

# test InstallAttributeMethodByGroupGeneralMappingByImages indirectly
gap> G:=SymmetricGroup(3);;
gap> act:=MultiActionsHomomorphism(G, [ 1, 3 ], [ OnPoints, OnPoints ]);;
gap> hom:=AsGroupGeneralMappingByImages(act);;
gap> SetIsInjective(act, false); # FALSE information! the map really is bijective
gap> IsInjective(hom); # check if the FALSE information propagated as desired
false

#
gap> BIND_GLOBAL("BIND_GLOBAL", fail);
Error, BIND_GLOBAL: variable `BIND_GLOBAL' must be unbound

#
gap> PrintObj(PrintObj); Print("\n");
<Operation "PrintObj">

#
gap> MagmaHomomorphismByFunctionNC(fail,fail,fail);
Error, Usage: MagmaHomomorphismByFunctionNC(<Magma>,<Magma>,<fn>)
gap> MagmaIsomorphismByFunctionsNC(fail, fail, fail, fail);
Error, Usage: MagmaIsomorphismByFunctionsNC(<Magma>,<Magma>,<fn>,<inv>)

#
gap> ContinuedFractionExpansionOfRoot(fail,fail);
Error, usage: ContinuedFractionExpansionOfRoot( <P>, <n> ) for a polynomial P \
with integer coefficients and a positive integer <n>
gap> ContinuedFractionApproximationOfRoot(fail,fail);
Error, usage: ContinuedFractionApproximationOfRoot( <P>, <n> ) for a polynomia\
l P with integer coefficients and a positive integer <n>

#
gap> LeftNormedComm([]);
Error, <list> must be a non-empty list
gap> LeftNormedComm(fail);
Error, <list> must be a non-empty list
gap> LeftNormedComm([ (1,2) ]);
(1,2)
gap> LeftNormedComm([ (1,2), (2,3) ]);
(1,2,3)
gap> LeftNormedComm([ (1,2), (2,3), (3,4) ]);
(1,3,4)
gap> LeftNormedComm([ (1,2), (2,3), (3,4), (4,5) ]);
(1,4,5)
gap> LeftNormedComm([ (1,2), (2,3), (3,4), (4,5), (5,6) ]);
(1,5,6)
