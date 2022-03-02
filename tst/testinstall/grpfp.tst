#@local a,b,c2,e,f,g,iter,l,s,F,rels,sub,iso,G
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
gap> Collected(AbelianInvariants(Kernel(e)));
[ [ 0, 52 ], [ 2, 1 ], [ 5, 1 ] ]
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

# Tietze simplifications
gap> F:=FreeGroup("a");;
gap> SimplifiedFpGroup(F/[GeneratorsOfGroup(F)[1]]);
<fp group on the generators [  ]>
gap> F:=FreeGroup("a","b","c");;
gap> rels:=ParseRelators(F,"a2,b3,c4,abC");
[ a^2, b^3, c^4, a*b*c^-1 ]
gap> g:=F/rels;;
gap> Size(g);
24
gap> iso:=IsomorphismSimplifiedFpGroup(g);
[ a, b, c ] -> [ c*b^-1, b, c ]
gap> HasSize(Image(iso));
true

# ClosureSubgroupNC will not force a triviality or membership test
# if we do not know anything.
gap> f:=FreeGroup(3);;
gap> g:=f/[f.1*f.2,f.2^2,(f.2*f.3)^7];;
gap> sub:=SubgroupNC(g,[g.1*g.2^3]);;
gap> ClosureSubgroupNC(sub,g.3);;

# homomorphisms on trivial fp group with no generators
gap> F:=FreeGroup(2);;
gap> G:=F/[F.1,F.2];;
gap> F:=GroupHomomorphismByImagesNC(G,G,[],[]);;
gap> ImagesRepresentative(F,G.1);;

#
gap> STOP_TEST( "grpfp.tst", 1);
