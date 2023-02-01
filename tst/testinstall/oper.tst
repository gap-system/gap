#@local newop
gap> START_TEST( "oper.tst" );

#
gap> newop:= NewKeyBasedOperation( "newop", [ IsOperation, IsInt ] );;
gap> newop( IsList, 1 );
Error, no default installed for key based operation <oper>
gap> InstallKeyBasedMethod( newop,
>        { oper, n } -> n );
gap> InstallKeyBasedMethod( newop,
>        { oper, n } -> n );
Error, <key> has already been set in <dict>
gap> InstallKeyBasedMethod( newop, IsGroup,
>        { oper, n } -> 2*n );
gap> InstallKeyBasedMethod( newop, IsGroup,
>        { oper, n } -> 2*n );
Error, <key> has already been set in <dict>
gap> InstallKeyBasedMethod( newop, IsMagma,
>        { oper, n } -> 3*n );
gap> InstallKeyBasedMethod( newop, IsInt,
>        { oper, n } -> 4*n );
gap> newop( IsList );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `newop' on 1 arguments
gap> newop( IsList, 1, 2 );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `newop' on 3 arguments
gap> newop( IsList, 1 );
1
gap> newop( IsGroup, 1 );
2
gap> newop( IsMagma, 1 );
3
gap> newop( IsInt, 1 );
4

#
gap> STOP_TEST( "oper.tst" );
