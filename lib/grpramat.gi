#############################################################################
##
#W  grpramat.gi                 GAP Library                     Franz G"ahler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains operations for matrix groups over the rationals
##
Revision.grpramat_gi :=
    "@(#)$Id$";

#############################################################################
##
#M  IsRationalMatrixGroup( G )
##
InstallMethod( IsRationalMatrixGroup, true, [ IsCyclotomicMatrixGroup ], 0,
    G -> ForAll( Flat( GeneratorsOfGroup( G ) ), IsRat ) );

#############################################################################
##
#M  IsIntegralMatrixGroup( G )
##
InstallMethod( IsIntegralMatrixGroup, true, [ IsCyclotomicMatrixGroup ], 0,
    G -> ForAll( Flat( GeneratorsOfGroup( G ) ), IsInt ) );

InstallTrueMethod( IsRationalMatrixGroup, IsIntegralMatrixGroup );

#############################################################################
##
#M  InvariantLattice( G ) . . . . .Invariant lattice of rational matrix group
##
InstallMethod( InvariantLattice, "for rational matrix groups", 
  true, [ IsCyclotomicMatrixGroup ], 0,
 function( G )

    local gen, dim, trn, rnd, tab, den;

    if not IsRationalMatrixGroup( G ) then
      TryNextMethod();
    fi;

    # return fail if no invariant lattice exists
    gen := GeneratorsOfGroup( G );
    if ForAny( gen, x -> not IsInt( TraceMat( x ) ) ) then
         return fail;
    fi;
    if ForAny( gen, x -> AbsInt( DeterminantMat( x ) ) <> 1 ) then
         return fail;
    fi;

    dim := DimensionOfMatrixGroup( G );
    trn := IdentityMat( dim );
    rnd := Random( GeneratorsOfGroup( G ) );

    # refine lattice until it contains its image
    repeat

        # if there are elements with non-integer trace, 
        # we will find one, sooner or later (with probability 1)
        rnd := rnd * Random( gen );
        if not IsInt( TraceMat( rnd ) ) then
            return fail;
        fi;

        tab := List( gen, g -> trn * g * trn^-1 );
        if ForAny( tab, x -> not IsInt( TraceMat( x ) ) ) then
             return fail;
        fi;
        tab := Concatenation( tab ); 
        tab := Filtered( tab, vec -> ForAny( vec, x -> not IsInt( x ) ) );

        if Length( tab ) > 0 then
            den := Lcm( List( Flat( tab ), x -> DenominatorRat( x ) ) );
            tab := Concatenation( den * IdentityMat( dim ), den * tab );
            tab := HermiteNormalFormIntegerMat( tab ) / den;
            trn := tab * trn;
        else
            den := 1;
        fi;         

    until den = 1;

    return trn;

end );


#############################################################################
##
#F  SizeOfMinkowskiKernel( grp ) . . . . . . . . . . . .SizeOfMinkowskiKernel
##
##  Size for group which has only diagonal elements, with +1 or -1 on 
##  the diagonal. This is faster than NiceMethod for Size.
##
SizeOfMinkowskiKernel := function( grp )

    local mat, dim, h, i, j, tmp;

    mat := List( GeneratorsOfGroup( grp ), DiagonalOfMat );
    dim := DimensionOfMatrixGroup( grp );
    h := 1;
    for i in [1..dim] do
        for j in [h..Length(mat)] do
            if mat[j][i] = -1 then
                if IsBound( tmp ) then
                    mat[j] := List( [1..dim], k -> mat[j][k]*tmp[k] );
                else
                    tmp := mat[j];
                    if j > h then
                        mat[j] := mat[h];
                        mat[h] := tmp;
                    fi;
                    h := h+1;
                fi;
            fi;
        od;
        Unbind( tmp );
    od;
    return 2^(h-1);

end;


#############################################################################
##
#M  IsFinite( G ) . . . . . . . . . . . . .IsFinite for rational matrix group
##
#T  This method should evetually be replaced or complemented by the methods
#T  used in GRIM!
InstallMethod( IsFinite, "via Minkowski kernel (short but not too efficient)",
  true, [ IsCyclotomicMatrixGroup ], 0,
function( G )

    local lat, grp, stb, orb, rep, gen, pnt, img, sch, size, dim, basis, i;

    # if not rational, try something else
    if not IsRationalMatrixGroup( G ) then
        TryNextMethod();
    fi;

    # if not integral, choose basis in which it is integral
    if not IsIntegralMatrixGroup( G ) then
        lat := InvariantLattice( G );
        if lat = fail then
             return false;
        fi;
        grp := G^(lat^-1);
    else
        grp := G;
    fi;

    size  := 1;
    dim   := DimensionOfMatrixGroup( grp );
    basis := IdentityMat( dim, GF( 2 ) );
    for i in [1..dim] do
        orb := [ basis[i] ];
        rep := [ One( grp ) ];
        stb := [];       
        for pnt in orb do
            for gen in GeneratorsOfGroup( grp ) do
                img := pnt * gen;
                if not img in orb  then
                    Add( orb, img );
                    Add( rep, rep[ Position( orb, pnt ) ] * gen );
                else
                    sch := rep[ Position( orb, pnt ) ] * gen
                           / rep[ Position( orb, img ) ];
                    if i = dim then
                        if sch <> One( grp ) then
                            if sch * sch <> One( grp ) then
                                return false;
                            fi;
                            if ForAny( stb, x -> x * sch <> sch * x ) then
                                return false;
                            fi;
                        fi;
                    fi;
                    AddSet( stb, sch );
                fi;
            od;
        od;
        grp  := Group( stb, One( grp ) );
        size := size * Length( orb );
    od;
#    SetSize( G, size * Size( grp ) );
    SetSize( G, size * SizeOfMinkowskiKernel( grp ) );
    return true;

end );



# enforce redispatching on finiteness conditions

RedispatchOnCondition(\in,true,
  [IsCyclotomicMatrixGroup,IsMatrix],
  [IsRationalMatrixGroup and IsFinite],0);

RedispatchOnCondition(\=,IsIdenticalObj,
  [IsCyclotomicMatrixGroup,IsCyclotomicMatrixGroup],
  [IsRationalMatrixGroup and IsFinite,IsRationalMatrixGroup and IsFinite],0);

RedispatchOnCondition(IndexOp,IsIdenticalObj,
  [IsCyclotomicMatrixGroup,IsCyclotomicMatrixGroup],
  [IsRationalMatrixGroup and IsFinite,IsRationalMatrixGroup and IsFinite],0);

RedispatchOnCondition(NormalizerOp,IsIdenticalObj,
  [IsCyclotomicMatrixGroup,IsCyclotomicMatrixGroup],
  [IsRationalMatrixGroup and IsFinite,IsRationalMatrixGroup and IsFinite],0);

RedispatchOnCondition(NormalClosureOp,IsIdenticalObj,
  [IsCyclotomicMatrixGroup,IsCyclotomicMatrixGroup],
  [IsRationalMatrixGroup and IsFinite,IsRationalMatrixGroup and IsFinite],0);

RedispatchOnCondition(CentralizerOp,true,
  [IsCyclotomicMatrixGroup,IsObject],
  [IsRationalMatrixGroup and IsFinite],0);

RedispatchOnCondition(ClosureGroup,true,
  [IsCyclotomicMatrixGroup,IsObject],
  [IsRationalMatrixGroup and IsFinite],0);

RedispatchOnCondition(SylowSubgroupOp,true,
  [IsCyclotomicMatrixGroup,IsPosInt],
  [IsRationalMatrixGroup and IsFinite],0);

RedispatchOnCondition(ConjugacyClasses,true,
  [IsCyclotomicMatrixGroup],
  [IsRationalMatrixGroup and IsFinite],0);

RedispatchOnCondition(IsomorphismPermGroup,true,
  [IsCyclotomicMatrixGroup],
  [IsRationalMatrixGroup and IsFinite],0);

RedispatchOnCondition(IsomorphismPcGroup,true,
  [IsCyclotomicMatrixGroup],
  [IsRationalMatrixGroup and IsFinite],0);

RedispatchOnCondition(CompositionSeries,true,[IsCyclotomicMatrixGroup],
    [IsRationalMatrixGroup and IsFinite],0);


#############################################################################
##
#E  grpramat.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
