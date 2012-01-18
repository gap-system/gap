gap> START_TEST("Test 3 of POLENTA package");  
gap> SetInfoLevel( InfoPolenta, 0 );;
gap> SetAssertionLevel( 2 );

gap> POL_Test_AllFunctions_PRMGroup( PolExamples( 5 ) );
The input group is not triangularizable.
The input group is not triangularizable.
gap> POL_Test_AllFunctions_PRMGroup( PolExamples( 6 ) );
The input group is not triangularizable.
The input group is not triangularizable.
gap> POL_Test_AllFunctions_PRMGroup( PolExamples( 7 ) );
The input group is not triangularizable.
The input group is not triangularizable.
gap> POL_Test_AllFunctions_PRMGroup( PolExamples( 8 ) );

gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( -16 ) );

gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 46 ) );
The input group is not triangularizable.
The input group is not triangularizable.
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 47 ) );
The input group is not triangularizable.
The input group is not triangularizable.
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 48 ) );
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 49 ) );
The input group is not triangularizable.
The input group is not triangularizable.
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 50 ) );
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 51 ) );
The input group is not triangularizable.
The input group is not triangularizable.
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 52 ) );
The input group is not triangularizable.
The input group is not triangularizable.
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 53 ) );
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 54 ) );
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 55 ) );
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 56 ) );
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 57 ) );
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 58 ) );
gap> POL_Test_AllFunctions_PRMGroup( POL_PolExamples2( 59 ) );

gap> POL_Test_AllFunctions_PolExamples( 20,31 );
Test of group 20
Test of group 21
The input group is not triangularizable.
The input group is not triangularizable.
Test of group 22
Test of group 23
The input group is not triangularizable.
The input group is not triangularizable.
Test of group 24
The input group is not triangularizable.
The input group is not triangularizable.
Test of group 25
gap> STOP_TEST( "POLENTA3.tst", 100000);   

