#############################################################################
##
#W  matrstab.gi             AutPGrp package                      Bettina Eick
##
#H  @(#)$Id: matrstab.gi,v 1.3 2009/03/09 07:26:55 gap Exp $
##
Revision.("autpgrp/gap/matrstab_gi") :=
    "@(#)$Id: matrstab.gi,v 1.3 2009/03/09 07:26:55 gap Exp $";

#############################################################################
##
#F LabelOfBasis( base, info ) . . . . . . . . . . . . . . . . . label to basis
##
LabelOfBasis := function( base, info )
    local pt, j, i;

    # compute pt
    pt := List( [1..info.l], x -> 0 );
    for j in [1..info.l] do
        for i in [1..info.d] do
            if base[j][i] <> Zero( info.field ) then 
                pt[j] := pt[j] + IntFFE( base[j][i] ) * info.power[i];
            fi;
        od;
    od;

    # create label
    return pt;
end;

#############################################################################
##
#F CoeffsInt( int, d, power )
##
CoeffsInt := function( int, d, power)
   local i, exp;
   i   := d;
   exp := List( power, y -> 0 );
   while int <> 0 do
      exp[i] := QuoInt (int, power[i]);
      int    := RemInt (int, power[i]);
      i      := i - 1;
   od;
   return exp;
end;

#############################################################################
##
#F BasisOfLabel( lab, info ) . . . . . . . . . . . . . . . . . basis of label
##
BasisOfLabel := function ( lab, info )
   return List( [1..info.l], x -> CoeffsInt( lab[x], info.d, info.power ) );
end;

#############################################################################
##
#F OnLabel( lab, mat, info ) . . . . . . . . . . . . . . . .operation on label
##
OnLabel := function( lab, mat, info )
    local v, w;
    v := BasisOfLabel( lab, info );
    w := v * mat;
    TriangulizeMat( w );
    return LabelOfBasis( w, info );
end;

#############################################################################
##
#F OnBasis( base, mat, info ) . . . . . . . . . . . . . . .operation on basis
##
OnBasis := function( base, mat, info )
    base := base * mat;
    if not IsMutable(base) then
      base:=ShallowCopy(base);
    fi;
    TriangulizeMat( base );
    return base;
end;

#############################################################################
##
#F InducedActionByHom( hom, mat )
##
InducedActionByHom := function( hom, mat )
    local ind, baseI, baseS, b, e, f, g;

    # catch special case for efficiency
    if mat = 1 then return mat; fi;

    # otherwise compute
    ind := [];
    baseI := Basis( ImagesSource( hom ) );
    baseS := Basis( Source( hom ) );
    for b in baseI do
        e := PreImagesRepresentative( hom, b );
        f := e * mat;
        g := ImagesRepresentative( hom, f );
        Add( ind, Coefficients( baseI, g ) );
    od;

    # again catch a special case for efficiency
    if ind = ind^0 then return 1; fi;
    ind := Immutable(ind);
    ConvertToMatrixRep( ind );
    return ind;
end;

#############################################################################
##
#F ActionOnDual( mat )
##
ActionOnDual := function( mat )
    local new;
    if mat = 1 then return 1; fi;
    new := TransposedMat( mat )^-1;
    new:=Immutable(new);
    ConvertToMatrixRep( new );
    return new;
end;

#############################################################################
##
#F PGMatrixOrbitStabilizer( A, V, W, R )
##
PGMatrixOrbitStabilizer := function( A, V, W, R )
    local VS, WS, RS, hom, pt, glMats, agMats, lab, info, l, d, oper;

    # set up factor space
    VS := VectorSpace( A.field, V, "basis" );
    WS := VectorSpace( A.field, W, Zero(VS), "basis" );
    RS := VectorSpace( A.field, R, "basis" );
    hom := NaturalHomomorphismBySubspaceOntoFullRowSpace( VS, WS );
    pt  := ShallowCopy( Basis( ImagesSet( hom, RS ) ) ); 
    TriangulizeMat( pt );

    # set up action 
    glMats := List( A.glAutos, x -> InducedActionByHom( hom, x!.mat ) );
    agMats := List( A.agAutos, x -> InducedActionByHom( hom, x!.mat ) );
    
    # check if the dual is better
    if Length(pt) > Length(pt[1])/2 then
        pt := VectorSpace( A.field, pt, "basis" );
        pt := OrthogonalSpaceInFullRowSpace( pt );
        pt := ShallowCopy( Basis( pt ) );
        TriangulizeMat( pt );
        glMats := List( glMats, x -> ActionOnDual( x ) );
        agMats := List( agMats, x -> ActionOnDual( x ) );
    fi;

    # use labels - if desired
    if USE_LABEL then
        d := Length( pt[1] );
        l := Length( pt );
        info := rec( power := List( [1..d], x -> A.prime^(x-1) ),
                     field := A.field,
                     l     := l,
                     d     := d );
        lab := LabelOfBasis( pt, info );
        PGHybridOrbitStabilizer( A, glMats, agMats, lab, OnLabel, info );
    else
        pt := Immutable( pt );
        ConvertToMatrixRep( pt );
        PGHybridOrbitStabilizer( A, glMats, agMats, pt, OnBasis, rec() );
    fi;
end;

#############################################################################
##
#F CheckStab(A, pt)
##
CheckAgStab := function( A, pt )
    local g, s, c;
    for g in A.agAutos do
        for s in pt do
            c := SolutionMat(pt, s*g!.mat);
            if IsBool(c) then return false; fi;
        od;
    od;
    return true;
end;

CheckGlStab := function( A, pt )
    local g, s, c;
    for g in A.glAutos do
        for s in pt do
            c := SolutionMat(pt, s*g!.mat);
            if IsBool(c) then return false; fi;
        od;
    od;
    return true;
end;

#############################################################################
##
#F PGOrbitStabilizerBySeries( A, baseU, chop )
##
PGOrbitStabilizerBySeries := function( A, baseU, chop )
    local s, U, T, i, S, R, j, V, W, B;

    s := Length(chop);
    U := baseU;

    # loop upwards over series
    T := [];
    for i in [1..s-1] do
        S := ShallowCopy(T);
        T := SumIntersectionMat( U, chop[i+1] )[2];
        if Length( S ) < Length( T ) then 
 
            # loop downwards over series
            R := chop[i+1];
            for j in Reversed( [1..i] ) do
                V := ShallowCopy( R );
                R := SumMat( T, chop[j] );
                if Length( R ) < Length( V ) then
                    W := SumMat( S, chop[j] );
                    if Length( R ) > Length( W ) then
                        PGMatrixOrbitStabilizer( A, V, W, R );
                        if CHECK then 
                            if not CheckAgStab(A, R) then 
                                Error("ag stab wrong ");
                            fi;
                            if not CheckGlStab(A, R) then 
                                Error("gl stab wrong ");
                            fi;
                        fi;
                    else
                        Info( InfoAutGrp, 4, "    skip trivial factor");
                    fi;
                fi;
            od;
        fi;
    od;
end;

