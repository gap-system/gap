#@local A,Fam7,Fam8,Famp,G,R,enum,l,len,m,m2,m3,m4,one,p
#@local rings,x,z0,z1,z2,z3,i,a,b,y
gap> START_TEST("polyrat.tst");

#
gap> ApproximateRoot(2,2);
779770732423810/551381172667677
gap> ApproximateRoot(2,2)^2-2;
-183963906236558/304021197572382638000680576329
gap> ApproximateRoot(2,2,20);
61816429438630776653272737/43710816444795547405901687
gap> ApproximateRoot(2,2);
779770732423810/551381172667677

#
gap> STOP_TEST( "polyrat.tst", 1);
