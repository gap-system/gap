gap> START_TEST("method-rankfns.tst");
gap> myOp := NewOperation("myOp",[IsObject]);;
gap> myC := NewConstructor("myC",[IsObject]);;
gap> xxx := 1;;
gap> InstallMethod(myOp,"method1",[IsObject],x->1);
gap> InstallMethod(myOp,"method2",[IsObject],{}->xxx,x->2);
gap> InstallMethod(myC,"cons1",[IsObject],x->1);
gap> InstallMethod(myC,"cons2",[IsObject],{}->xxx,x->2);
gap> myOp(3);
2
gap> myC(IsObject);
2
gap> xxx := -1;;
gap> RECALCULATE_ALL_METHOD_RANKS();
gap> myOp(3);
1
gap> myC(IsObject);
1
gap> Unbind(myOp);
gap> Unbind(myC);
gap> STOP_TEST("method-rankfns.tst");
