#@local myOp, myC, xxx, obj, myUprankFilt
#@exec myFilt:= NewFilter("myFilt", 0);;
#@exec myAltFilt:= NewFilter("myAltFilt", 0);;
gap> START_TEST("method-rankfns.tst");

##
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

##
gap> xxx:= 1;;
gap> RECALCULATE_ALL_METHOD_RANKS();
gap> RankFilter( myFilt );
0
gap> RankFilter( myAltFilt );
0
gap> InstallMethod( myOp, "method3", [ "myFilt" ], [ [ "myAltFilt" ] ],
>                   x -> 3 );
gap> obj:= Objectify( TYPE_KERNEL_OBJECT, rec() );;
gap> SetFilterObj( obj, myFilt );
gap> myOp( obj );
2
gap> myUprankFilt:= NewFilter( "myUprankFilt", 2 );;
gap> RankFilter( myUprankFilt );
2
gap> InstallTrueMethod( myUprankFilt, myFilt );
gap> RankFilter( myFilt );
2
gap> myOp( obj );
2
gap> InstallTrueMethod( myUprankFilt, myAltFilt );
gap> RankFilter( myAltFilt );
2
gap> myOp( obj );
3

##
gap> Unbind(myOp);
gap> Unbind(myC);
gap> STOP_TEST("method-rankfns.tst");
