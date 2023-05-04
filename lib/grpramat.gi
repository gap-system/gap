#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Franz Gähler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains operations for matrix groups over the rationals
##

#############################################################################
##
#M  IsRationalMatrixGroup( G )
##
InstallMethod( IsRationalMatrixGroup, [ IsCyclotomicMatrixGroup ],
    G -> ForAll( Flat( GeneratorsOfGroup( G ) ), IsRat ) );

InstallTrueMethod( IsRationalMatrixGroup, IsIntegerMatrixGroup );

#############################################################################
##
#M  IsIntegerMatrixGroup( G )
##
InstallMethod( IsIntegerMatrixGroup, [ IsCyclotomicMatrixGroup ],
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
InstallMethod( GeneralLinearGroupCons,
    "some generators for GL_n(Z)",
    [ IsMatrixGroup, IsPosInt, IsIntegers ],
function(fil,n,ints)
local gens,mat,G;
  # permutations
  gens:=List(GeneratorsOfGroup(SymmetricGroup(n)),i->PermutationMat(i,n));
  # sign swapper
  mat:= IdentityMat(n,1);
  mat[1,1]:=-1;
  Add(gens,mat);
  # elementary addition
  if n>1 then
    mat:= IdentityMat(n,1);
    mat[1,2]:=1;
    Add(gens,mat);
  fi;
  gens:=List(gens,Immutable);
  G:= GroupByGenerators( gens, IdentityMat( n, 1 ) );
  Setter(IsNaturalGLnZ)(G,true);
  SetName(G,Concatenation("GL(",String(n),",Integers)"));
  if n>1 then
    SetSize(G,infinity);
    SetIsFinite(G,false);
  else
    SetIsFinite(G,true);
    SetSize(G,2);
    SetNiceMonomorphism(G,DoSparseLinearActionOnFaithfulSubset(G, OnRight, false));
  fi;
  return G;
end);

#############################################################################
##
#M  SpecialLinearGroupCons(IsMatrixGroup,n,Integers)
##
InstallMethod(SpecialLinearGroupCons,"some generators for SL_n(Z)",
  [IsMatrixGroup,IsPosInt,IsIntegers],
function(fil,n,ints)
local gens,mat,G;
  # permutations
  gens:=List(GeneratorsOfGroup(AlternatingGroup(n)),i->PermutationMat(i,n));
  if n>1 then
    mat:= IdentityMat(n,1);
    mat{[1..2]}{[1..2]}:=[[0,1],[-1,0]];
    Add(gens,mat);
    # elementary addition
    mat:= IdentityMat(n,1);
    mat[1,2]:=1;
    Add(gens,mat);
  fi;
  gens:=List(gens,Immutable);
  G:= GroupByGenerators( gens, IdentityMat( n, 1 ) );
  Setter(IsNaturalSLnZ)(G,true);
  SetName(G,Concatenation("SL(",String(n),",Integers)"));
  if n>1 then
    SetSize(G,infinity);
    SetIsFinite(G,false);
  else
    SetIsFinite(G,true);
    SetSize(G,1);
    SetNiceMonomorphism(G,DoSparseLinearActionOnFaithfulSubset(G, OnRight, false));
  fi;
  return G;
end);

#############################################################################
##
#M  \in( <g>, GL( <n>, Integers ) )
##
InstallMethod( \in,
               "for matrix and GL(n,Z)", IsElmsColls,
               [ IsMatrix, IsNaturalGLnZ ],

  function ( g, GLnZ )
    return DimensionsMat(g) = DimensionsMat(One(GLnZ))
       and ForAll(Flat(g),IsInt) and DeterminantMat(g) in [-1,1];
  end );

#############################################################################
##
#M  \in( <g>, SL( <n>, Integers ) )
##
InstallMethod( \in,
               "for matrix and SL(n,Z)", IsElmsColls,
               [ IsMatrix, IsNaturalSLnZ ],

  function ( g, SLnZ )
    return DimensionsMat(g) = DimensionsMat(One(SLnZ))
       and ForAll(Flat(g),IsInt) and DeterminantMat(g) = 1;
  end );

#############################################################################
##
#M  Normalizer( GLnZ, G ) . . . . . . . . . . . . . . . . .Normalizer in GLnZ
##
InstallMethod( NormalizerOp, IsIdenticalObj,
    [ IsNaturalGLnZ, IsCyclotomicMatrixGroup ],
function( GLnZ, G )
    return NormalizerInGLnZ( G );
end );

#############################################################################
##
#M  Centralizer( GLnZ, G ) . . . . . . . . . . . . . . . .Centralizer in GLnZ
##
InstallMethod( CentralizerOp, IsIdenticalObj,
    [ IsNaturalGLnZ, IsCyclotomicMatrixGroup ],
function( GLnZ, G )
    return CentralizerInGLnZ( G );
end );

#############################################################################
##
#M  CrystGroupDefaultAction . . . . . . . . . . . . . . RightAction initially
##
BindGlobal( "CrystGroupDefaultAction", RightAction );

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
    [ IsCyclotomicMatrixGroup ],
function( G )
    return G = BravaisGroup( G );
end );

#############################################################################
##
#M  InvariantLattice( G ) . . . . .invariant lattice of rational matrix group
##
InstallMethod( InvariantLattice, "for rational matrix groups",
    [ IsCyclotomicMatrixGroup ],
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
#M  IsFinite( G ) . . . . . . . . . . .  IsFinite for cyclotomic matrix group
##
InstallMethod( IsFinite,
    "cyclotomic matrix group",
    [ IsCyclotomicMatrixGroup ],
function( G )

    local lat, ilat, grp, mat;

    # if not rational, use the nice monomorphism into a rational matrix group
    if not IsRationalMatrixGroup( G ) then
        # the following does not use NiceObject(G) as the only method for
        # that currently requires IsHandledByNiceMonomorphism
        return IsFinite( Image( NiceMonomorphism( G ), G ) );
    fi;

    # if not integer, choose basis in which it is integer
    if not IsIntegerMatrixGroup( G ) then
        lat := InvariantLattice( G );
        if lat = fail then
            return false;
        fi;
        ilat := lat^-1;
        grp := G^(ilat);
        IsFinite( grp );
        # IsFinite may have set the size, so we save it
        if HasSize( grp ) then
            SetSize( G, Size( grp ) );
        fi;
        # IsFinite may have set an invariant quadratic form
        if HasInvariantQuadraticForm( grp ) then
            mat := InvariantQuadraticForm( grp ).matrix;
            mat := ilat * mat * TransposedMat( ilat );
            SetInvariantQuadraticForm( G, rec( matrix := mat ) );
        fi;
        return IsFinite( grp );
    else
        return IsFinite( G );  # now G knows it is integer
    fi;

end );

#############################################################################
##
#M  IsFinite( G ) . . . . . . . . . . . . . IsFinite for integer matrix group
##
#T  This method should evetually be replaced or complemented by the methods
#T  used in GRIM!
InstallMethod( IsFinite,
    "via Minkowski kernel (short but not too efficient)",
    [ IsIntegerMatrixGroup ],
function( G )

    local grp, size, dim, basis, gens, gensp, orb, rep, stb, img, sch, i,
          pnt, gen, tmp;

    grp   := G;
    size  := 1;
    dim   := DimensionOfMatrixGroup( grp );
    basis := Immutable( IdentityMat( dim, GF( 2 ) ) );
    for i in [1..dim] do
        orb   := [ basis[i] ];
        gens  := GeneratorsOfGroup( grp );
        gensp := List(gens,i->ImmutableMatrix(2,i*Z(2),true));
        rep   := [ One( grp ) ];
        stb   := [];
        for pnt in orb do
            for gen in [1..Length(gens)] do
                img := pnt * gensp[gen];
                if not img in orb  then
                    Add( orb, img );
                    tmp := rep[ Position( orb, pnt ) ] * gens[gen];
                    # simple test for infinite order
                    # Order() would be too expensive to do on all elements
                    if AbsInt( TraceMat( tmp ) ) > dim then
                        return false;
                    fi;
                    Add( rep, tmp );
                else
                    sch := rep[ Position( orb, pnt ) ] * gens[gen]
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
                    else
                        # simple test for infinite order
                        # Order() would be too expensive to do on all elements
                        if AbsInt( TraceMat( sch ) ) > dim then
                            return false;
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
#M  Size( <G> ) . . . . .  for cyclotomic matrix group not known to be finite
##
InstallMethod( Size,
    "cyclotomic matrix group not known to be finite",
    [ IsCyclotomicMatrixGroup ],
    function( G )
    if IsFinite( G ) then
        return Size( G );  # now G knows it is finite
    else
        return infinity;
    fi;
    end );


#############################################################################
##
#M  NiceMonomorphism( <G> ) . . . . . . . . . . for a cyclotomic matrix group
##
##  For a *nonrational* cyclotomic matrix group, the nice monomorphism is
##  defined as an isomorphism to a rational matrix group.
##
##  Note that a stored nice monomorphism does *not* imply that the group is
##  handled by the nice monomorphism; as for matrix groups in general,
##  we want to set `IsHandledByNiceMonomorphism' only for *finite* matrix
##  groups.
##
InstallMethod( NiceMonomorphism,
    "for a (nonrational) cyclotomic matrix group",
    [ IsCyclotomicMatrixGroup ],
    function( G )
    if IsRationalMatrixGroup( G ) then
      TryNextMethod();
    else
      return BlowUpIsomorphism( G, Basis( FieldOfMatrixGroup( G ) ) );
    fi;
    end );


#############################################################################
##
#M  IsHandledByNiceMonomorphism( <G> )  . . . . for a cyclotomic matrix group
##
##  A matrix group shall be handled via nice monomorphism if and only if it
##  is finite.
##  We install the method here because for cyclotomic matrix groups,
##  we can decide finiteness.
##
##  (Note that nice monomorphisms may be used also for infinite groups,
##  for example for non-rational matrix groups over the cyclotomics.)
##
InstallMethod( IsHandledByNiceMonomorphism,
    "for a cyclotomic matrix group",
    [ IsCyclotomicMatrixGroup ],
    IsFinite );


#############################################################################
##
#M  IsomorphismPermGroup( <G> ) . . . . . . . . . . for rational matrix group
##
##  The only difference to the method installed for matrix groups is that
##  finiteness of (finitely generated) matrix groups over the cyclotomics can
##  be decided and hence no warning need to be issued.
##
InstallMethod( IsomorphismPermGroup,
    "cyclotomic matrix group",
    [ IsCyclotomicMatrixGroup ], 10,
    function( G )
    if HasNiceMonomorphism(G) and IsPermGroup(Range(NiceMonomorphism(G))) then
      return RestrictedMapping(NiceMonomorphism(G),G);
    elif not IsFinite(G) then
      Error("Cannot compute permutation representation of infinite group");
    else
      return NicomorphismOfGeneralMatrixGroup(G,false,false);
    fi;
    end);


#############################################################################
##
##  *Finite* matrix groups lie in the filter `IsHandledByNiceMonomorphism'.
##  In order to make the corresponding methods for the operations involved in
##  the following `RedispatchOnCondition' calls applicable for finite
##  matrix groups over the cyclotomics,
##  we force a finiteness check as ``last resort''.
##
RedispatchOnCondition( \in, true,
    [ IsMatrix, IsCyclotomicMatrixGroup ],
    [ IsObject, IsFinite ], 0 );

RedispatchOnCondition( \=, IsIdenticalObj,
    [ IsCyclotomicMatrixGroup, IsCyclotomicMatrixGroup ],
    [ IsFinite, IsFinite ], 0 );

RedispatchOnCondition( IndexOp, IsIdenticalObj,
    [ IsCyclotomicMatrixGroup, IsCyclotomicMatrixGroup ],
    [ IsFinite, IsFinite ], 0 );

RedispatchOnCondition( IndexNC, IsIdenticalObj,
    [ IsCyclotomicMatrixGroup, IsCyclotomicMatrixGroup ],
    [ IsFinite, IsFinite ], 0 );

RedispatchOnCondition( NormalizerOp, IsIdenticalObj,
    [ IsCyclotomicMatrixGroup, IsCyclotomicMatrixGroup ],
    [ IsFinite, IsFinite ], 0 );

RedispatchOnCondition( NormalClosureOp, IsIdenticalObj,
    [ IsCyclotomicMatrixGroup, IsCyclotomicMatrixGroup ],
    [ IsFinite, IsFinite ], 0 );

RedispatchOnCondition( CentralizerOp, true,
    [ IsCyclotomicMatrixGroup, IsObject ],
    [ IsFinite ], 0 );

RedispatchOnCondition( ClosureGroup, true,
    [ IsCyclotomicMatrixGroup, IsObject ],
    [ IsFinite ], 0 );

RedispatchOnCondition( SylowSubgroupOp, true,
    [ IsCyclotomicMatrixGroup, IsPosInt ],
    [ IsFinite ], 0 );

RedispatchOnCondition( ConjugacyClasses, true,
    [ IsCyclotomicMatrixGroup ],
    [ IsFinite ], 0 );

#T as we have installed a method for this situation,
#T no fallback is needed
# RedispatchOnCondition( IsomorphismPermGroup, true,
#     [ IsCyclotomicMatrixGroup ],
#     [ IsFinite ], 0 );

RedispatchOnCondition( IsomorphismPcGroup, true,
    [ IsCyclotomicMatrixGroup ],
    [ IsFinite ], 0 );

# Note that there is a unary method with requirement 'IsGroup'
# that calls the two-argument variant.
RedispatchOnCondition( IsomorphismFpGroup, true,
    [ IsCyclotomicMatrixGroup, IsString ],
    [ IsFinite, IsObject ], 0 );

RedispatchOnCondition( CompositionSeries, true,
    [ IsCyclotomicMatrixGroup ],
    [ IsFinite ], 0 );

RedispatchOnCondition( NiceMonomorphism, true,
    [ IsCyclotomicMatrixGroup ],
    [ IsFinite ], 0 );
