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
InstallOtherMethod(GeneralLinearGroupCons,"some generators for GL_n(Z)",
  [IsMatrixGroup,IsPosInt,IsIntegers],
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
InstallMethod( IsFinite,
    "via Minkowski kernel (short but not too efficient)",
    [ IsCyclotomicMatrixGroup ],
    function( G )

    local lat, grp, stb, orb, rep, gen, pnt, img, sch, size, dim, basis, i;

    # if not rational, use the nice monomorphism into a rational matrix group
    if not IsRationalMatrixGroup( G ) then

      size:= Size( Image( NiceMonomorphism( G ) ) );
      SetSize( G, size );
      return IsInt( size );

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
#M  Size( <G> ) . . . . . . . . . . . . . . . . . . for rational matrix group
##
InstallMethod( Size,
    "via Minkowski kernel (short but not too efficient)",
    [ IsCyclotomicMatrixGroup ],
    function( G )
    IsFinite( G );
#T dangerous because it assumes that the above method is used
#T that explicitly sets the `Size' value
    return Size( G );
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

RedispatchOnCondition( CompositionSeries, true,
    [ IsCyclotomicMatrixGroup ],
    [ IsFinite ], 0 );


#############################################################################
##
#E

