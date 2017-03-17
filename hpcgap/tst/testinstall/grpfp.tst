#############################################################################
##
#W  grpfp.tst                   GAP library                     Thomas Breuer
##
##
#Y  Copyright 2005,    Lehrstuhl D für Mathematik,   RWTH Aachen,    Germany
##
##  To be listed in testinstall.g
##
gap> START_TEST("grpfp.tst");
gap> f:= FreeGroup( "a", "b" );;  a := f.1;;  b := f.2;;
gap> c2:= f / [ a*b*a^-2*b*a/b, (b^-1*a^3*b^-1*a^-3)^2*a ];;

# Prescribe just the index.
gap> iter:= LowIndexSubgroupsFpGroupIterator( c2, 11 );;
gap> l:= [];;
gap> while not IsDoneIterator( iter ) do
>      Add( l, NextIterator( iter ) );
>    od;
gap> Print( Collected( List( l, x -> Index( c2, x ) ) ), "\n" );
[ [ 1, 1 ], [ 11, 10 ] ]
gap> Print( Collected( List( LowIndexSubgroupsFpGroup( c2, 11 ),
>                            x -> Index( c2, x ) ) ), "\n" );
[ [ 1, 1 ], [ 11, 10 ] ]

# Prescribe the index and a subgroup.
gap> e:= GQuotients( c2, PSL(2,11) );;
gap> e:= e[1];;
gap> iter:= LowIndexSubgroupsFpGroupIterator( c2, Kernel( e ), 11 );;
gap> l:= [];;
gap> while not IsDoneIterator( iter ) do
>      Add( l, NextIterator( iter ) );
>    od;
gap> Print( Collected( List( l, x -> Index( c2, x ) ) ), "\n" );
[ [ 1, 1 ], [ 11, 2 ] ]
gap> Print( Collected( List( LowIndexSubgroupsFpGroup( c2, Kernel( e ), 11 ),
>                            x -> Index( c2, x ) ) ), "\n" );
[ [ 1, 1 ], [ 11, 2 ] ]

# Prescribe the index and an exclusion list
gap> iter:= LowIndexSubgroupsFpGroupIterator( c2, 11, [ b ] );;
gap> l:= [];;
gap> while not IsDoneIterator( iter ) do
>      Add( l, NextIterator( iter ) );
>    od;
gap> Length( l );
4
gap> Length( LowIndexSubgroupsFpGroup( c2, 11, [ b ] ) );
4
gap> iter:= LowIndexSubgroupsFpGroupIterator( c2, 11, [ a*b ] );;
gap> l:= [];;
gap> while not IsDoneIterator( iter ) do
>      Add( l, NextIterator( iter ) );
>    od;
gap> Length( l );
2
gap> Length( LowIndexSubgroupsFpGroup( c2, 11, [ a*b ] ) );
2
gap> iter:= LowIndexSubgroupsFpGroupIterator( c2, 11, [ b, a*b ] );;
gap> l:= [];;
gap> while not IsDoneIterator( iter ) do
>      Add( l, NextIterator( iter ) );
>    od;
gap> Length( l );
0
gap> Length( LowIndexSubgroupsFpGroup( c2, 11, [ b, a*b ] ) );
0

# Prescribe the index, a subgroup, and an exclusion list
gap> iter:= LowIndexSubgroupsFpGroupIterator( c2, Kernel( e ), 11, [ a ] );;
gap> l:= [];;
gap> while not IsDoneIterator( iter ) do
>      Add( l, NextIterator( iter ) );
>    od;
gap> Length( l );
2
gap> Length( LowIndexSubgroupsFpGroup( c2, Kernel( e ), 11, [ a ] ) );
2

# Work in a subgroup of the whole group, prescribe just the index.
gap> g:= PreImage( e, Stabilizer( Image(e), 1 ) );;
gap> iter:= LowIndexSubgroupsFpGroupIterator( g, 5 );;
gap> l:= [];;
gap> while not IsDoneIterator( iter ) do
>      Add( l, NextIterator( iter ) );
>    od;
gap> Print( Collected( List( l, x -> Index( c2, x ) ) ), "\n" );
[ [ 12, 1 ], [ 24, 7 ], [ 36, 4 ], [ 48, 19 ], [ 60, 6 ] ]
gap> Print( Collected( List( LowIndexSubgroupsFpGroup( g, 5 ),
>                            x -> Index( c2, x ) ) ), "\n" );
[ [ 12, 1 ], [ 24, 7 ], [ 36, 4 ], [ 48, 19 ], [ 60, 6 ] ]

# Work in a subgroup of the whole group, prescribe index and subgroup.
gap> s:= l[25];; Index( g, s );
4
gap> iter:= LowIndexSubgroupsFpGroupIterator( g, s, 5 );;
gap> l:= [];;
gap> while not IsDoneIterator( iter ) do
>      Add( l, NextIterator( iter ) );
>    od;
gap> Print( Collected( List( l, x -> Index( c2, x ) ) ), "\n" );
[ [ 12, 1 ], [ 24, 1 ], [ 48, 1 ] ]
gap> Print( Collected( List( LowIndexSubgroupsFpGroup( g, s, 5 ),
>                            x -> Index( c2, x ) ) ), "\n" );
[ [ 12, 1 ], [ 24, 1 ], [ 48, 1 ] ]
gap> STOP_TEST( "grpfp.tst", 10290000);

#############################################################################
##
#E
