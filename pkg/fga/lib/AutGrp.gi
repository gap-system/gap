#############################################################################
##
#W  AutGrp.gi                FGA package                    Christian Sievers
##
##  Methods for automorphism groups of free groups
##
#H  @(#)$Id: AutGrp.gi,v 1.4 2005/05/03 14:47:10 gap Exp $
##
#Y  2003 - 2005
##
Revision.("fga/lib/AutGrp_gi") :=
    "@(#)$Id: AutGrp.gi,v 1.4 2005/05/03 14:47:10 gap Exp $";


#############################################################################
##
#M  AutomorphismGroup( <group> )
##
InstallMethod( AutomorphismGroup,
    "for free groups",
    [ CanComputeWithInverseAutomaton ],
    function( G )
    local n, aut;

    n := RankOfFreeGroup( G );

    if n = 0 then

        aut := AsGroup( [ IdentityMapping ( G ) ] );

    elif n = 1 then

        aut := Group( FreeGroupAutomorphismsGeneratorO( G ) );
        SetSize( aut, 2 );

    elif n = 2 then

        aut := Group( FreeGroupAutomorphismsGeneratorO( G ),
                      FreeGroupAutomorphismsGeneratorP( G ), 
                      FreeGroupAutomorphismsGeneratorU( G ) );

    elif n = 3 then

        aut := Group( FreeGroupAutomorphismsGeneratorS( G ),
                      FreeGroupAutomorphismsGeneratorT( G ),
                      FreeGroupAutomorphismsGeneratorU( G ) );

    elif IsEvenInt( n ) then

        aut := Group( FreeGroupAutomorphismsGeneratorQ( G ),
                      FreeGroupAutomorphismsGeneratorR( G ) );

    else  #  n > 3, odd

        aut := Group( FreeGroupAutomorphismsGeneratorS( G ),
                      FreeGroupAutomorphismsGeneratorR( G ) );

    fi;

    SetIsFinite( aut, n <= 1 );
    SetFilterObj( aut, IsAutomorphismGroupOfFreeGroup );

    return aut;

    end );


#############################################################################
##
#M  IsomorphismFpGroup( <group> )
##
##  returns an isomorphism from an automorphism group of a free group
##  to a finitely presented group.
##
##  The presentation follows Bernhard Neumann (see ../doc/manual.bib)
##  Numbers in the comments refer to the equation numbers in that paper.
##
InstallMethod( IsomorphismFpGroup,
    "for automorphism groups of free groups",
    [ IsAutomorphismGroupOfFreeGroup ],
    function( aut )

    local n, f, fp, O, P, U, S, T, Q, R, rels, moreRels,
                    o, p, u, s, t, q, r, iso, isoinv;

    n := RankOfFreeGroup( AutomorphismDomain ( aut ));

    if n = 0 then

        fp := FreeGroup( 0 );

        iso := aut -> One( fp );

    elif n = 1 then

        f := FreeGroup( "O" );
        O := f.1;
        rels := [ O^2 ];  # 6a
        fp := f / rels;

        o := fp.1;
        iso := aut -> o ^ (Order(aut) - 1);

    elif n = 2 then

        f := FreeGroup( "O", "P", "U" );
        O := f.1;  P := f.2;  U := f.3;
        rels := [ P^2                # 5a
                , O^2                # 6a
                , (O*P)^4            # 8a
                , Comm( U, O*U*O )   # 7e
                , (P*O*P*U)^2        # 7i
                , (U*P*O)^3          # 8b
                ];
        fp := f / rels;

        o := fp.1;  p := fp.2;  u := fp.3;
        iso := FGA_CurryAutToPQOU( p, p, o, u); # Q=P

    elif n = 3 then

        f := FreeGroup( "S", "T", "U" );
        S := f.1;  T := f.2;  U := f.3;
        rels := [ (S^5*T^-1)^2                     # 19a
                , T^-1*S*T^2*S^8*T^-1*S*T^2*S^-4   # 19b
                , (S^4*T^-1*S*T^-1)^2              # 19c
                , T^4                              # 19d
                , Comm( U, S^2*T^-1*S*T^-1*S^2 )   # 19e
                , Comm( U, S^-2*T^-1*S*T^-1*U*S^-2*T^-1*S*T^-1) # 19f
        # wrong:  Comm( U, S^2*T^-1*S*T*S*T^-1*U*T*S^-1*T^-1*S^-1*T*S^2 ) # 19g
                , Comm( U, S^-2*T^-1*S*T*S*T^-1*U*
                              T*S^-1*T^-1*S^-1*T*S^2 ) # 19g corrected
                , Comm( U, T^-1*S*T^2*U*T^-1*S*T^2 )   # 19h
                , S^-2*T^-1*S*T^2*S^2*U*S^2*T^-1*S*T^2*S^2*
                  U*S^-2*U*S^2*U^-1*S^-2*U^-1               # 19i
                , (S^-2*T^-1*S*T*U)^2              # 19j
                , (U*T)^3                          # 19k
                ];
        fp := f / rels;

        s := fp.1;  t := fp.2;  u := fp.3;
        iso := FGA_CurryAutToPQOU( t*s^3*(s*t^-1)^2  # 16c
                                 , s^4               # 16a
                                 , s^3*(s*t^-1)^2    # 16b
                                 , u
                                 );

    elif IsEvenInt(n) then

        f := FreeGroup( "Q", "R" );
        Q := f.1;  R := f.2;
        rels := [ (R^3*(Q*R^3)^(n-1))^2            # 22a
                , (Q*R^3)^(2*(n-1))                # 22d
                , Q^n                              # 22e
                , Comm( (Q*R^3)^(n-1),
                        Q^-1*R^3*(Q*R^3)^(n-1)*Q ) # 22f
                , Comm( Q^-2*R^4*Q^2*R^-3,
                        Q*R^-3*Q^-1*R^-3*Q )       # 22h
                , Comm( R^4, (Q*R^3)^(n-1) )       # 22j
                , Comm( R^4, Q^-2*R^4*Q^2 )        # 22k
                , Comm( Q^-2*R^4*Q^2*R^-3,
                        (Q*R^3)^(n-1)*Q^-2*R^4*Q^2*R^-3*(Q*R^3)^(n-1) )  # 22l
                , Comm( Q^-2*R^4*Q^2*R^-3,
                        R^-3*Q^-1*Q^-2*R^4*Q^2*R^-3*Q*R^3 )  # 22m
                , Comm( Q^-2*R^4*Q^2*R^-3,
                        R^-3*Q^-1*R^-3*(Q*R^3)^n*Q^-2*R^4*
                          Q^2*R^-3*(Q*R^3)^-n*R^3*Q*R^3   )  # 22n
                , (Q*R^3)^-n*Q^-2*R^4*Q^2*R^-3*(Q*R^3)^n*
                    Q^-3*R^4*Q^2*R^-3*Q^-1*R^4*Q^2*R^-3*
                    Q^-1*R^3*Q^-2*R^-4*Q^3*R^3*Q^-2*R^-4*Q^2 # 22o
                , (R^3*(Q*R^3)^(n-1)*Q^-2*R^4*Q^2)^2         # 22p
                , R^12                                       # 22q
                ];
        # finally the relations 22c:
        moreRels := List( [ 2 .. n/2 ],
                          i -> Comm( R^3*(Q*R^3)^(n-1),
                                     Q^-i*R^3*(Q*R^3)^(n-1)*Q^i ) );
        fp := f / Concatenation(rels, moreRels);

        q := fp.1;  r := fp.2;
        iso := FGA_CurryAutToPQOU( r^3*(q*r^3)^(n-1)   # 21b
                                 , q
                                 , (q*r^3)^(n-1)       # 21a
                                 , q^-2*r^4*q^2*r^-3   # 21c
                                 );

    else  #  n > 3, odd

        f := FreeGroup( "S", "R" );
        S := f.1;  R := f.2;
        rels := [ (R^3*S^n*(S*R^-3)^(n-1))^2                 # 25a
                , (S^(n+1)*R^3*S^n*(S*R^-3)^(n-1))^(n-1)*
                    S^((-n)*(n-1))                           # 25b
                , ((S^n)*(S*R^-3)^(n-1))^2                   # 25d
                , Comm( S^n*(S*R^-3)^(n-1),
                        S^-(n+1)*R^3*S^n*
                          (S*R^-3)^(n-1)*S^(n+1) )           # 25e
                , Comm( S^-2*R^4*S^2*R^3,
                        S*R^-3*S^(n-1)*R^-3*S )              # 25f
                , Comm( R^4, S^n*(S*R^-3)^(n-1) )            # 25g
                , Comm( R^4, S^-2*R^4*S^2 )                  # 25h
                , Comm( S^-2*R^4*S^2*R^-3,
                        S^n*(S*R^-3)^(n-1)*S^-2*R^4*S^2*
                          R^-3*S^n*(S*R^-3)^(n-1)         )  # 25i
                , Comm( S^-2*R^4*S^2*R^-3,
                        R^-3*S^-(n+1)*S^-2*R^4*S^2*
                          R^-3*S^(n+1)*R^3                )  # 25j
# wrong:        , Comm( S^-2*R^4*S^2*R^-3,
#                       R^-3*S^-1*R^-3*S*R^3*S^n*
#                         (S*R^-3)^(n-1)*S^-2*R^4*S^2*R^3*
#                         (S*R^-3)^(n-1)*S^n*R^-3*S^-1*
#                         R^3*S*R^3                       )  # 25k
                , Comm( S^-2*R^4*S^2*R^-3,
                        R^-3*S^-1*R^-3*S*R^3*S^n*
                          (S*R^-3)^(n-1)*S^-2*R^4*S^2*R^-3*
                          (S*R^-3)^(n-1)*S^n*R^-3*S^-1*
                          R^3*S*R^3                       )  # 25k corrected

                , R^3*(S*R^-3)^(n-1)*S^-3*R^4*S^2*R^-3*S*
                    R^3*(S*R^-3)^(n-1)*S^(n-3)*R^4*S^2*R^-3*
                    S^(n-1)*R^4*S^2*R^-3*S^(n-1)*R^3*S^-2*
                    R^-4*S^(n+3)*R^3*S^-2*R^-4*S^2           # 25l
                , (R^3*(S*R^-3)^(n-1)*S^(n-2)*R^4*S^2)^2     # 25m
                , R^12                                       # 22q
                ] ;
        # and finally the relations 25c:
        moreRels := List( [ 2 .. (n-1)/2 ],
                          i -> Comm( R^3*S^n*(S*R^-3)^(n-1),
                                     S^(-i*(n+1))*R^3*S^n*
                                     (S*R^-3)^(n-1)*S^(i*(n+1)) ) );
        fp := f / Concatenation( rels, moreRels );

        s := fp.1;  r := fp.2;
        iso := FGA_CurryAutToPQOU( r^3*s^n*(s*r^-3)^(n-1)              # 24c
                                 , s^(n+1)                             # 24a
                                 , s^n*(s*r^-3)^(n-1)                  # 24b
                                 , s^(-2*(n+1))*r^4*s^(2*(n+1))*r^-3   # 24d
                                 );

    fi;

    isoinv := GroupHomomorphismByImagesNC( fp, aut,
                                           GeneratorsOfGroup( fp ),
                                           GeneratorsOfGroup( aut ) );

    return GroupHomomorphismByFunction( aut, fp, iso,
                                        x -> x ^ isoinv );

    end );


#############################################################################
##
#F  FreeGroupEndomorphismByImages( <group>, <images> )
##
##  returns the endomorphism of <group> that maps the generators of <group>
##  to <images>.
##
InstallGlobalFunction( FreeGroupEndomorphismByImages,
    function(g,l)
    return GroupHomomorphismByImages(g,g,FreeGeneratorsOfGroup(g),l);
    end );


#############################################################################
##
#F  FreeGroupAutomorphismsGeneratorO( <group> )
#F  FreeGroupAutomorphismsGeneratorP( <group> )
#F  FreeGroupAutomorphismsGeneratorU( <group> )
#F  FreeGroupAutomorphismsGeneratorS( <group> )
#F  FreeGroupAutomorphismsGeneratorT( <group> )
#F  FreeGroupAutomorphismsGeneratorQ( <group> )
#F  FreeGroupAutomorphismsGeneratorR( <group> )
##
##  These functions return the automorphism of <group> which maps the
##  generators [<x1>, <x2>, ..., <xn>] to
##  O : [<x1>^-1 , <x2>,       ..., <xn>   ]        (n>=1)
##  P : [<x2>    , <x1>, <x3>, ..., <xn>   ]        (n>=2)
##  U : [<x1><x2>, <x2>, <x3>, ..., <xn>   ]        (n>=2)
##  S : [<x2>^-1, <x3>^-1, ..., <xn>^-1, <x1>^-1 ]  (n>=1)
##  T : [<x2>    , <x1>^-1, <x3>, ..., <xn>]        (n>=2)
##  Q : [<x2>, <x3>, ..., <xn>, <x1> ]              (n>=2)
##  R : [<x2>^-1, <x1>, <x3>, <x4>, ..., 
##       <x{n-2}>, <xn><x{n-1}>^-1, <x{n-1}>^-1]    (n>=4)
##
InstallGlobalFunction( FreeGroupAutomorphismsGeneratorO,
    function( g )
    local imgs;
    FGA_CheckRank( g, 1 );
    imgs := ShallowCopy( FreeGeneratorsOfGroup( g ) );
    imgs[1] := imgs[1]^-1;
    return FreeGroupEndomorphismByImages( g, imgs );
    end );

InstallGlobalFunction( FreeGroupAutomorphismsGeneratorP,
    function( g )
    local imgs;
    FGA_CheckRank( g, 2 );
    imgs := ShallowCopy( FreeGeneratorsOfGroup( g ) );
    imgs{[1,2]} := [ imgs[2], imgs[1] ];
    return FreeGroupEndomorphismByImages( g, imgs );
    end );

InstallGlobalFunction( FreeGroupAutomorphismsGeneratorU,
    function( g )
    local imgs;
    imgs := ShallowCopy( FreeGeneratorsOfGroup( g ) );
    FGA_CheckRank( g, 2 );
    imgs[1] := imgs[1] * imgs[2];
    return FreeGroupEndomorphismByImages( g, imgs );
    end );

InstallGlobalFunction( FreeGroupAutomorphismsGeneratorS,
    function( g )
    local imgs;
    FGA_CheckRank( g, 1 );
    imgs := FreeGeneratorsOfGroup(g){[2..Rank(g)]};
    Add( imgs, FreeGeneratorsOfGroup(g)[1] );
    return FreeGroupEndomorphismByImages( g, List(imgs, g -> g^-1) );
    end );

InstallGlobalFunction( FreeGroupAutomorphismsGeneratorT,
    function( g )
    local imgs;
    FGA_CheckRank( g, 2 );
    imgs := ShallowCopy( FreeGeneratorsOfGroup( g ) );
    imgs{[1..2]} := [ imgs[2], imgs[1]^-1 ];
    return FreeGroupEndomorphismByImages( g, imgs );
    end );

InstallGlobalFunction( FreeGroupAutomorphismsGeneratorQ,
    function( g )
    local imgs;
    FGA_CheckRank( g, 2 ); # we could allow 1
    imgs := FreeGeneratorsOfGroup(g){[2..Rank(g)]};
    Add( imgs, FreeGeneratorsOfGroup(g)[1] );
    return FreeGroupEndomorphismByImages( g, imgs );
    end );

InstallGlobalFunction( FreeGroupAutomorphismsGeneratorR,
    function( g )
    local imgs, n;
    FGA_CheckRank( g, 4 );
    n := RankOfFreeGroup( g );
    imgs := ShallowCopy( FreeGeneratorsOfGroup( g ) );
    imgs{[1,2,n-1,n]} := [ imgs[2]^-1,           imgs[1],
                           imgs[n]*imgs[n-1]^-1, imgs[n-1]^-1 ];
    return FreeGroupEndomorphismByImages( g, imgs );
    end );

#############################################################################
##
#F FGA_CheckRank( <group>, <minrank> )
##
## Checks whether <group> has rank at least <minrank>, and signals an
## error otherwise (helper function for FreeGroupAutomorphismsGenerator*)
##
InstallGlobalFunction( FGA_CheckRank,
    function( g, r )
    if RankOfFreeGroup( g ) < r then
        Error( "the rank of the group should be at least ", r );
    fi;
    return; 
    end );

#############################################################################
##
#E
