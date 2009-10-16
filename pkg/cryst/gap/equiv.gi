#############################################################################
##
#A  equiv.gi                  Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##

#############################################################################
##
#F  ConjugatorSpaceGroupsStdSamePG( S1, S2 ) . . . . returns C with S1^C = S2
##
##  S1 and S2 act on the right, are in standard form, 
##  and have the same point group
## 
ConjugatorSpaceGroupsStdSamePG := function( S1, S2 )

    local P, d, M, I, g, i, gen1, t1, gen2, t2, sol, Ngen, 
          orb, img, gen, rep, nn;

    P := PointGroup( S1 );
    d := DimensionOfMatrixGroup( P ); 

    # determine space in which translational parts of generators can
    # be shifted by conjugating the space group with pure translations
    M := List( [1..d], i->[] ); i := 0;
    I := IdentityMat(d);
    for g in GeneratorsOfGroup( P ) do
        g := g - I;
        M{[1..d]}{[1..d]+i*d} := g{[1..d]}{[1..d]};
        i := i+1;
    od;

    gen1 := List( GeneratorsOfGroup( P ), 
            x -> PreImagesRepresentative( PointHomomorphism( S1 ), x ) );
    t1   := Concatenation( List( gen1, x -> x[d+1]{[1..d]} ) );

    gen2 := List( GeneratorsOfGroup( P ), 
             x -> PreImagesRepresentative( PointHomomorphism( S2 ), x ) );
    t2   := Concatenation( List( gen2, x -> x[d+1]{[1..d]} ) );

    sol  := SolveInhomEquationsModZ( M, t1-t2, true )[1];
    if sol <> [] then
        return AugmentedMatrix( IdentityMat( d ), sol[1] );
    fi;

    # if we arrive here, we need the normalizer
#    Print("#I need normalizer\n");
    Ngen := GeneratorsOfGroup( NormalizerPointGroupInGLnZ( P ) );
    Ngen := Filtered( Ngen, x -> not x in P );

    orb := [ GeneratorsOfGroup( P) ];
    rep := [ One( P ) ];
    for gen in orb do
        for g in Ngen do
            img := List( gen, x -> x^g );
            if not img in orb then
                nn   := rep[Position(orb,gen)]*g;
                Add( orb, img );
                Add( rep, nn  );
                gen2 := List( img, x -> PreImagesRepresentative( 
                                        PointHomomorphism( S2 ), x ) );
                t2 := Concatenation( List( gen2, x -> x[d+1]{[1..d]}*nn^-1));
                sol  := SolveInhomEquationsModZ( M, t1-t2, true )[1];
                if sol <> [] then
                    return AugmentedMatrix( nn, sol[1]*nn );
                fi;
            fi;
        od;
    od;
    return fail;
end;

#############################################################################
##
#M  ConjugatorSpaceGroups( S1, S2 ) . . . . . . . . .returns C with S1^C = S2
##
InstallMethod( ConjugatorSpaceGroups, IsIdenticalObj, 
    [ IsAffineCrystGroupOnRight and IsSpaceGroup, 
      IsAffineCrystGroupOnRight and IsSpaceGroup ], 0,
function( S1, S2 )

    local d, C1, C2, C3, C4, c, S1std, S2std, P1std, P2std, S3;

    d := DimensionOfMatrixGroup( S1 ) - 1;    

    # go to standard representation

    # S1^C1 = S1std
    if IsStandardSpaceGroup( S1 ) then
        S1std := S1;
        C1    := IdentityMat( d+1 );
    else
        S1std := StandardAffineCrystGroup( S1 );
        C1    := AugmentedMatrix( InternalBasis( S1 ), 0*[1..d] );
    fi;

    # S2^C2 = S2std
    if IsStandardSpaceGroup( S2 ) then
        S2std := S2;
        C2    := IdentityMat( d+1 );
    else
        S2std := StandardAffineCrystGroup( S2 );
        C2    := AugmentedMatrix( InternalBasis( S2 ), 0*[1..d] );
    fi;    

    P1std := PointGroup( S1std );
    P2std := PointGroup( S2std );

    d := DimensionOfMatrixGroup( P1std );    
    if P1std = P2std then
        C3 := IdentityMat( d+1 );
        S3 := S2std;
    else
        c  := RepresentativeAction( GL(d,Integers), P2std, P1std );
        if c = fail then
            return fail;
        fi;
        C3 := AugmentedMatrix( c, 0*[1..d] );
        S3 := S2std^C3;
    fi;

    C4 := ConjugatorSpaceGroupsStdSamePG( S1std, S3 );
    if C4 = fail then
        return fail;
    else
        return C1^-1 * C4 * C3^-1 * C2;
    fi;
end );
   
#############################################################################
##
#M  ConjugatorSpaceGroups( S1, S2 ) . . . . . . . . .returns C with S1^C = S2
##
InstallMethod( ConjugatorSpaceGroups, IsIdenticalObj, 
    [ IsAffineCrystGroupOnLeft and IsSpaceGroup, 
      IsAffineCrystGroupOnLeft and IsSpaceGroup ], 0,
function( S1, S2 )
    local S1tr, S2tr, C;
    S1tr := TransposedMatrixGroup( S1 );
    S2tr := TransposedMatrixGroup( S2 );
    C    := ConjugatorSpaceGroups( S1tr, S2tr );
    if C = fail then
        return fail;
    else
        return TransposedMat( C );
    fi;
end );


RedispatchOnCondition( ConjugatorSpaceGroups, IsIdenticalObj,
  [IsAffineCrystGroupOnRight,IsAffineCrystGroupOnRight],
  [IsAffineCrystGroupOnRight and IsSpaceGroup,
   IsAffineCrystGroupOnRight and IsSpaceGroup],0);

RedispatchOnCondition( ConjugatorSpaceGroups, IsIdenticalObj,
  [IsAffineCrystGroupOnLeft,IsAffineCrystGroupOnLeft],
  [IsAffineCrystGroupOnLeft and IsSpaceGroup,
   IsAffineCrystGroupOnLeft and IsSpaceGroup],0);

