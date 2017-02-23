# 2013/08/21 (MH)
gap> IsStringRep("");
true
gap> RepresentationsOfObject("");
[ "IsStringRep", "IsInternalRep" ]
gap> DeclareOperation("TestOp",[IsStringRep]);
gap> InstallMethod(TestOp,[IsStringRep], function(x) Print("Your string: '",x,"'\n"); end);
gap> TestOp("");
Your string: ''
gap> PositionSublist("xyz", "");
1
