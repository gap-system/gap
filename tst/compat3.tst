#############################################################################
##
#W  compat3.tst                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1998,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id$");

# Read the library files `compat3a.g', `compat3b.g', `compat3c.g'.
gap> ReadLib( "compat3c.g" );

# Check the behaviour of ordinary domains w.r.t. component access.
gap> g:= Group( (1,2,3,4), (1,2) );
Group([ (1,2,3,4), (1,2) ])

gap> IsBound( g.size );
false
gap> g.size;
24
gap> IsBound( g.size );
true
gap> IsBound( g.isAbelian );
false
gap> g.operations.IsAbelian( g );
false
gap> IsBound( g.isAbelian );
true

gap> IsBound( g.derivedSubgroup );
false
gap> der:= Subgroup( g, [ (1,2,3), (1,2)(3,4) ] );;
gap> SetName( der, "der" );
gap> g.derivedSubgroup:= der;;
gap> IsBound( g.derivedSubgroup );
true
gap> g.derivedSubgroup;
der

gap> IsBound( g.private );
false
gap> g.private:= [ 1 .. 100 ];;
gap> IsBound( g.private );
true
gap> g.private;
[ 1 .. 100 ]
gap> Compat3Info( g );
rec(
  private := [ 1 .. 100 ] )

gap> # Check the behaviour of new objects represented by records with
gap> # operations record.
gap> # The objects used here implement complex numbers with rational real
gap> # and imaginary part, stored in the components `re' and `im'.
gap> CompOps := OperationsRecord( "CompOps" );;
HasCompOps := NewProperty( "HasCompOps", IsObject );
gap> CompOps;
CompOps
gap> CompOps.Print := function( c )
>     Print( "C( ", c.re, " + ", c.im, "*I )" );
> end;;
# If the following method installation matches the requirements
# of the operation `PRINT_OBJ' then `InstallMethod' should be used.
# It might be useful to replace the rank `SUM_FLAGS' by `0'.
InstallOtherMethod( PRINT_OBJ,
    "for object with `CompOps' as first argument",
    true,
    [ HasCompOps ], SUM_FLAGS,
    CompOps.Print );

gap> CompOps.\= := function( l, r )
>     return l.re = r.re and l.im = r.im;
> end;;
# If the following method installation matches the requirements
# of the operation `EQ' then `InstallMethod' should be used.
# It might be useful to replace the rank `SUM_FLAGS' by `0'.
InstallOtherMethod( EQ,
    "for object with `CompOps' as first argument",
    true,
    [ HasCompOps, IsObject ], SUM_FLAGS,
    CompOps.\= );

# For binary infix operators, a second method is installed
# for the case that the object with `CompOps' is the right operand;
# since this case has priority on GAP 3, the method is
# installed with higher rank `SUM_FLAGS + 1'.
InstallOtherMethod( EQ
    "for object with `CompOps' as second argument",
    true,
    [ IsObject, HasCompOps ], SUM_FLAGS + 1,
    CompOps.\= );

gap> CompOps.\< := function( l, r )
>     return l.re < r.re or ( l.re = r.re and l.im < r.im );
> end;;
gap> CompOps.\+ := function( l, r )
>     return rec( re:= l.re + r.re, im:= l.im + r.im, operations:= CompOps );
> end;;
# If the following method installation matches the requirements
# of the operation `SUM' then `InstallMethod' should be used.
# It might be useful to replace the rank `SUM_FLAGS' by `0'.
InstallOtherMethod( SUM,
    "for object with `CompOps' as first argument",
    true,
    [ HasCompOps, IsObject ], SUM_FLAGS,
    CompOps.\+ );

# For binary infix operators, a second method is installed
# for the case that the object with `CompOps' is the right operand;
# since this case has priority on GAP 3, the method is
# installed with higher rank `SUM_FLAGS + 1'.
InstallOtherMethod( SUM
    "for object with `CompOps' as second argument",
    true,
    [ IsObject, HasCompOps ], SUM_FLAGS + 1,
    CompOps.\+ );

gap> CompOps.\- := function( l, r )
>     return rec( re:= l.re - r.re, im:= l.im - r.im, operations:= CompOps );
> end;;
# If the following method installation matches the requirements
# of the operation `DIFF' then `InstallMethod' should be used.
# It might be useful to replace the rank `SUM_FLAGS' by `0'.
InstallOtherMethod( DIFF,
    "for object with `CompOps' as first argument",
    true,
    [ HasCompOps, IsObject ], SUM_FLAGS,
    CompOps.\- );

# For binary infix operators, a second method is installed
# for the case that the object with `CompOps' is the right operand;
# since this case has priority on GAP 3, the method is
# installed with higher rank `SUM_FLAGS + 1'.
InstallOtherMethod( DIFF
    "for object with `CompOps' as second argument",
    true,
    [ IsObject, HasCompOps ], SUM_FLAGS + 1,
    CompOps.\- );

gap> CompOps.\* := function( l, r )
>     if IsList( l ) then
>       return List( l, x -> x * r );
>     elif IsList( r ) then
>       return List( r, x -> l * x );
>     elif IsRat( l ) then
>       return rec( re:= l * r.re,
>                   im:= l * r.im,
>                   operations:= CompOps );
>     elif IsRat( r ) then
>       return rec( re:= l.re * r,
>                   im:= l.im * r,
>                   operations:= CompOps );
>     else
>       return rec( re:= l.re * r.re - l.im * r.im,
>                   im:= l.im * r.re + l.re * r.im,
>                   operations:= CompOps );
>     fi;
> end;;
# If the following method installation matches the requirements
# of the operation `PROD' then `InstallMethod' should be used.
# It might be useful to replace the rank `SUM_FLAGS' by `0'.
InstallOtherMethod( PROD,
    "for object with `CompOps' as first argument",
    true,
    [ HasCompOps, IsObject ], SUM_FLAGS,
    CompOps.\* );

# For binary infix operators, a second method is installed
# for the case that the object with `CompOps' is the right operand;
# since this case has priority on GAP 3, the method is
# installed with higher rank `SUM_FLAGS + 1'.
InstallOtherMethod( PROD
    "for object with `CompOps' as second argument",
    true,
    [ IsObject, HasCompOps ], SUM_FLAGS + 1,
    CompOps.\* );

gap> Comp:= function( re, im )
>     return rec( re:= re, im:= im, operations:= CompOps );
> end;;

gap> e:= Comp( 1, 0 );
C( 1 + 0*I )
gap> i:= Comp( 0, 1 );
C( 0 + 1*I )
gap> z:= 0 * e;
C( 0 + 0*I )

gap> 7*e + 5*i = 5*i + 7*e;
true
gap> m1:= [ [ i, z ], [ z, -i ] ];
[ [ C( 0 + 1*I ), C( 0 + 0*I ) ], [ C( 0 + 0*I ), C( 0 + -1*I ) ] ]
gap> m2:= [ [ z, e ], [ e, z ] ];
[ [ C( 0 + 0*I ), C( 1 + 0*I ) ], [ C( 1 + 0*I ), C( 0 + 0*I ) ] ]
gap> m1 * m2;
[ [ C( 0 + 0*I ), C( 0 + 1*I ) ], [ C( 0 + -1*I ), C( 0 + 0*I ) ] ]
gap> m1 + m2;
[ [ C( 0 + 1*I ), C( 1 + 0*I ) ], [ C( 1 + 0*I ), C( 0 + -1*I ) ] ]
gap> m1^4 = m2^2;
true
gap> ( m1 + m2 )^2;
[ [ C( 0 + 0*I ), C( 0 + 0*I ) ], [ C( 0 + 0*I ), C( 0 + 0*I ) ] ]


#T The following would *not* work, for various reasons.
#T OrderMat( m1 ); OrderMat( m2 );
#T It is impossible to compute the order because of a call of `RankMat'
#T in the default method, which calls `Inverse'.

#T Size( Group( m1, m2 ) );
#T It is impossible to form groups of matrices over the `Comp' objects,
#T already `FieldOfMatrixGroup' complains.
#T Anyhow, also {\GAP}~3 did not admit all meaningful elements with
#T multiplication as group elements.


# Check the behaviour of domains with new operations records.
gap> MyOps:= OperationsRecord( "MyOps", PermGroupOps );
HasMyOps := NewProperty( "HasMyOps", IsObject );
MyOps
gap> MyOps.IsFinite:= function( G )
>     Print( "always finite!\n" );
>     return true;
> end;;
# If the following method installation matches the requirements
# of the operation `IsFinite' then `InstallMethod' should be used.
# It might be useful to replace the rank `SUM_FLAGS' by `0'.
InstallOtherMethod( IsFinite,
    "for object with `MyOps' as first argument",
    true,
    [ HasMyOps ], SUM_FLAGS,
    MyOps.IsFinite );

gap> MyOps.Size:= function( G )
>     Print( "my method for `Size':\n" );
>     return Size( Group( G.generators, G.identity ) );
> end;;
# If the following method installation matches the requirements
# of the operation `Size' then `InstallMethod' should be used.
# It might be useful to replace the rank `SUM_FLAGS' by `0'.
InstallOtherMethod( Size,
    "for object with `MyOps' as first argument",
    true,
    [ HasMyOps ], SUM_FLAGS,
    MyOps.Size );

gap> MyOps.IsSubset:= function( G, H )
>     Print( "my method for `IsSubset':\n" );
>     if IsGroup( G ) and IsGroup( H ) then
>       return IsSubset( Group( G.generators, G.identity ),
>                        Group( H.generators, H.identity ) );
>     elif G.operations = MyOps then
>       return IsSubset( Group( G.generators, G.identity ), H );
>     else
>       return IsSubset( G, Group( H.generators, H.identity ) );
>     fi;
> end;;
# If the following method installation matches the requirements
# of the operation `IsSubset' then `InstallMethod' should be used.
# It might be useful to replace the rank `SUM_FLAGS' by `0'.
InstallOtherMethod( IsSubset,
    "for object with `MyOps' as first argument",
    true,
    [ HasMyOps, IsObject ], SUM_FLAGS,
    MyOps.IsSubset );

gap> MyOps.SylowSubgroup:= function( G, p )
>     Print( "my method for `SylowSubgroup':\n" );
>     return SylowSubgroup( Group( G.generators, G.identity ), p );
> end;
function ( G, p ) ... end

gap> g:= Group( (1,2,3,4), (1,2) );
Group([ (1,2,3,4), (1,2) ])
gap> g.operations:= MyOps;
MyOps

gap> IsFinite( g );
true
gap> g.operations.IsFinite( g );
always finite!
true
gap> g.isFinite;
true

gap> Size( g );
my method for `Size':
24
gap> g.operations.Size( g );
my method for `Size':
24
gap> g.size;
24

gap> h:= DerivedSubgroup( g );
my method for `IsSubset':
my method for `IsSubset':
Group([ (1,3,2), (2,4,3) ])
gap> IsSubset( g, h );
true
gap> g.operations.IsSubset( g, h );
my method for `IsSubset':
true
gap> h.operations.IsSubset( g, h );
true

gap> SylowSubgroup( g, 2 );
Group([ (3,4), (1,2), (1,3)(2,4) ])
gap> g.operations.SylowSubgroup( g, 2 );
my method for `SylowSubgroup':
Group([ (2,3), (1,4), (1,2)(3,4) ])

gap> STOP_TEST( "compat3.tst", 10000 );


#############################################################################
##
#E  compat3.tst . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

