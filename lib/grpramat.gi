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

InstallTrueMethod( IsRationalMatrixGroup, IsIntegerMatrixGroup );

#############################################################################
##
#M  IsIntegerMatrixGroup( G )
##
InstallMethod( IsIntegerMatrixGroup, true, [ IsCyclotomicMatrixGroup ], 0,
    function( G )
    local gen;
    gen := GeneratorsOfGroup( G );
    return ForAll( Flat( gen ), IsInt ) and
           ForAll( gen, g -> AbsInt( DeterminantMat( g ) ) = 1 ); 
    end
);

#############################################################################
##
#M  GeneralLinearGroupCons(IsMatrixGroup,n,Integers)
##
InstallOtherMethod(GeneralLinearGroupCons,"some generators for GL_n(Z)",true,
  [IsMatrixGroup,IsPosInt,IsIntegers],0,
function(fil,n,ints)
local gens,mat,G;
  # permutations
  gens:=List(GeneratorsOfGroup(SymmetricGroup(n)),i->PermutationMat(i,n));
  # sign swapper
  mat:= IdentityMat(n,1);
  mat[1][1]:=-1;
  Add(gens,mat);
  # elementary addition
  mat:= IdentityMat(n,1);
  mat[1][2]:=1;
  Add(gens,mat);
  gens:=List(gens,Immutable);
  G:= GroupByGenerators( gens, IdentityMat( n, 1 ) );
  Setter(IsNaturalGLnZ)(G,true);
  SetName(G,Concatenation("GL(",String(n),",Integers)"));
  SetSize(G,infinity);
  SetIsFinite(G,false);
  return G;
end);

#############################################################################
##
#M  Normalizer( GLnZ, G ) . . . . . . . . . . . . . . . . .Normalizer in GLnZ
##
InstallMethod( NormalizerOp, IsIdenticalObj,
    [ IsNaturalGLnZ, IsCyclotomicMatrixGroup ], 0, 
function( GLnZ, G )
    return NormalizerInGLnZ( G );
end );

#############################################################################
##
#M  Centralizer( GLnZ, G ) . . . . . . . . . . . . . . . .Centralizer in GLnZ
##
InstallMethod( CentralizerOp, IsIdenticalObj,
    [ IsNaturalGLnZ, IsCyclotomicMatrixGroup ], 0, 
function( GLnZ, G )
    return CentralizerInGLnZ( G );
end );

#############################################################################
##
#M  CrystGroupDefaultAction . . . . . . . . . . . . . . RightAction initially
##
InstallValue( CrystGroupDefaultAction, RightAction );

#############################################################################
##
#M  SetCrystGroupDefaultAction( <action> ) . . . . .RightAction or LeftAction
##
InstallGlobalFunction( SetCrystGroupDefaultAction, function( action )
   if   action = LeftAction then
       MakeReadWriteGlobal( "CrystGroupDefaultAction" );
       CrystGroupDefaultAction := LeftAction;
       MakeReadOnlyGlobal( "CrystGroupDefaultAction" );
   elif action = RightAction then
       MakeReadWriteGlobal( "CrystGroupDefaultAction" );
       CrystGroupDefaultAction := RightAction;
       MakeReadOnlyGlobal( "CrystGroupDefaultAction" );
   else
       Error( "action must be either LeftAction or RightAction" );
   fi;
end );

#############################################################################
##
#M  IsBravaisGroup( <G> ) . . . . . . . . . . . . . . . . . . .IsBravaisGroup
##
InstallMethod( IsBravaisGroup, 
    true, [ IsCyclotomicMatrixGroup ], 0,
function( G )
    return G = BravaisGroup( G );
end );

#############################################################################
##
#M  InvariantLattice( G ) . . . . .invariant lattice of rational matrix group
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
    trn := Immutable( IdentityMat( dim ) );
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
#T This can never happen since `gen' is not changed, the traces have been
#T checked already, and they are invariant under conjugation.
        fi;
        tab := Concatenation( tab ); 
        tab := Filtered( tab, vec -> ForAny( vec, x -> not IsInt( x ) ) );

        if Length( tab ) > 0 then
            den := Lcm( List( Flat( tab ), x -> DenominatorRat( x ) ) );
            tab := Concatenation( den * Immutable( IdentityMat( dim ) ),
                       den * tab );
            tab := HermiteNormalFormIntegerMat( tab ) / den;
            trn := tab{[1..dim]} * trn;
        else
            den := 1;
        fi;         

    until den = 1;

    return trn;

end );

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
    if not IsIntegerMatrixGroup( G ) then
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
    basis := Immutable( IdentityMat( dim, GF( 2 ) ) );
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
        grp  := GroupByGenerators( stb, One( grp ) );
        size := size * Length( orb );
    od;

    # if we arrive here, the group is finite
    SetIsFinite( grp, true );
    SetSize( G, size * Size( grp ) );
    return true;

end );

#############################################################################
##
#M  Size( G ) . . . . . . . . . . . . . . . . .Size for rational matrix group
##
InstallMethod( Size, "via Minkowski kernel (short but not too efficient)",
  true, [ IsCyclotomicMatrixGroup ], 0,
function( G )
  if not IsRationalMatrixGroup( G ) then
     TryNextMethod();
  else
     IsFinite( G );
     return Size( G );
  fi;
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
