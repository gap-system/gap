#@local newop
gap> START_TEST( "oper.tst" );

#
gap> newop:= NewTagBasedOperation( "newop", [ IsOperation, IsInt ] );;
gap> newop( IsList, 1 );
Error, no default installed for tag based operation <oper>
gap> InstallTagBasedMethod( newop,
>        { oper, n } -> n );
gap> InstallTagBasedMethod( newop,
>        { oper, n } -> n );
Error, <tag> has already been set in <dict>
gap> InstallTagBasedMethod( newop, IsGroup,
>        { oper, n } -> 2*n );
gap> InstallTagBasedMethod( newop, IsGroup,
>        { oper, n } -> 2*n );
Error, <tag> has already been set in <dict>
gap> InstallTagBasedMethod( newop, IsMagma,
>        { oper, n } -> 3*n );
gap> InstallTagBasedMethod( newop, IsInt,
>        { oper, n } -> 4*n );
gap> newop( IsList );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `newop' on 1 argument
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
