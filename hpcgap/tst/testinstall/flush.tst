gap> START_TEST("flush.tst");
gap> DeclareGlobalVariable("cheesefun");
gap> DeclareGlobalVariable("cheeseval");
gap> cheesefun;
<< cheesefun to be defined>>
gap> cheeseval;
<< cheeseval to be defined>>
gap> InstallFlushableValueFromFunction(cheesefun, {} -> [1] );
gap> InstallFlushableValueFromFunction(cheeseval, {} -> [2] );
gap> cheesefun;
[ 1 ]
gap> cheeseval;
[ 2 ]
gap> cheesefun[2] := 6;;
gap> cheeseval[2] := 5;;
gap> cheesefun;
[ 1, 6 ]
gap> cheeseval;
[ 2, 5 ]
gap> FlushCaches();
gap> STOP_TEST("flush.tst", 1);
