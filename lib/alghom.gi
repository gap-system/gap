#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for algebra(-with-one) general mappings.
##
##  There are two default representations of such general mappings,
##  one by generators and images (see the file `vspchom.gi'),
##  the other as (linear) operation homomorphism
##
##  1. methods for algebra general mappings given by images
##  2. methods for operation algebra homomorphisms
##  3. methods for natural homomorphisms from algebras
##  4. methods for isomorphisms to matrix algebras
##  5. methods for isomorphisms to f.p. algebras
##


#############################################################################
##
##  1. methods for algebra general mappings given by images
##


#############################################################################
##
#R  IsAlgebraGeneralMappingByImagesDefaultRep
##
##  is a default representation of algebra general mappings between two
##  algebras $A$ and $B$ where $F$ is equal to the left acting
##  domain of $A$ and of $B$.
##
##  Algebra generators of $A$ and $B$ images are stored in the attribute
##  `MappingGeneratorsImages'.
##
##  The general mapping is defined as the closure of the relation that joins
##  the $i$-th generator of $A$ and the $i$-th generator of $B$
##  w.r.t. linearity and multiplication.
##
##  It is handled using the attribute `AsLinearGeneralMappingByImages'.
##
DeclareRepresentation( "IsAlgebraGeneralMappingByImagesDefaultRep",
    IsAlgebraGeneralMapping and IsAdditiveElementWithInverse
    and IsAttributeStoringRep, [] );

DeclareRepresentation( "IsPolynomialRingDefaultGeneratorMapping",
    IsAlgebraGeneralMappingByImagesDefaultRep,[]);


#############################################################################
##
#M  AlgebraGeneralMappingByImages( <S>, <R>, <gens>, <imgs> )
##
InstallMethod( AlgebraGeneralMappingByImages,
    "for two FLMLORs and two homogeneous lists",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ],
    function( S, R, gens, imgs )

    local map,        # general mapping from <S> to <R>, result
          filter,
          i,basic;

    # Handle the case that `gens' is a basis or empty.
    # We can form a left module general mapping directly.
    if IsBasis( gens ) or IsEmpty( gens ) then

      map:= LeftModuleGeneralMappingByImages( S, R, gens, imgs );
      SetIsAlgebraGeneralMapping( map, true );
      return map;

    fi;

    # Check the arguments.
    if   Length( gens ) <> Length( imgs )  then
      Error( "<gens> and <imgs> must have the same length" );
    elif not IsSubset( S, gens ) then
      Error( "<gens> must lie in <S>" );
    elif not IsSubset( R, imgs ) then
      Error( "<imgs> must lie in <R>" );
    elif LeftActingDomain( S ) <> LeftActingDomain( R ) then
      Error( "<S> and <R> must have same left acting domain" );
    fi;

    # type setting
    filter:=IsSPGeneralMapping
            and IsAlgebraGeneralMapping
            and IsAlgebraGeneralMappingByImagesDefaultRep;

    #special case: test whether polynomial ring is mapped via 1 and free
    #generators
    if IsPolynomialRing(S) then
      basic:=ForAll(imgs,x->ForAll(imgs,y->x*y=y*x));
      for i in [1..Length(gens)] do
        if IsOne(gens[i]) then
          if not IsOne(imgs[i]) then basic:=false;fi;
        elif not gens[i] in IndeterminatesOfPolynomialRing(S) then
          basic:=false;
        fi;
      od;
      if basic=true then
        filter:=filter and IsPolynomialRingDefaultGeneratorMapping;
      fi;
    fi;

    # Make the general mapping.
    map:= Objectify( TypeOfDefaultGeneralMapping( S, R,filter),
                     rec(
#                          generators := gens,
#                          genimages  := imgs
                         ) );

    SetMappingGeneratorsImages(map,[Immutable(gens),Immutable(imgs)]);
    # return the general mapping
    return map;
    end );


#############################################################################
##
#M  AlgebraHomomorphismByImagesNC( <S>, <R>, <gens>, <imgs> )
##
InstallMethod( AlgebraHomomorphismByImagesNC,
    "for two FLMLORs and two homogeneous lists",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ],
    function( S, R, gens, imgs )
    local map;        # homomorphism from <source> to <range>, result
    map:= AlgebraGeneralMappingByImages( S, R, gens, imgs );
    SetIsSingleValued( map, true );
    SetIsTotal( map, true );
    return map;
    end );


#############################################################################
##
#M  AlgebraWithOneGeneralMappingByImages( <S>, <R>, <gens>, <imgs> )
##
InstallMethod( AlgebraWithOneGeneralMappingByImages,
    "for two FLMLORs and two homogeneous lists",
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ],
    function( S, R, gens, imgs )
    local map;        # homomorphism from <source> to <range>, result
    gens:= Concatenation( gens, [ One( S ) ] );
    imgs:= Concatenation( imgs, [ One( R ) ] );
    map:= AlgebraGeneralMappingByImages( S, R, gens, imgs );
    SetRespectsOne( map, true );
    return map;
    end );


#############################################################################
##
#M  AlgebraWithOneHomomorphismByImagesNC( <S>, <R>, <gens>, <imgs> )
##
InstallMethod( AlgebraWithOneHomomorphismByImagesNC,
    "for two FLMLORs and two homogeneous lists",
    true,
    [ IsFLMLOR, IsFLMLOR, IsHomogeneousList, IsHomogeneousList ], 0,
    function( S, R, gens, imgs )
    local map;        # homomorphism from <source> to <range>, result
    gens:= Concatenation( gens, [ One( S ) ] );
    imgs:= Concatenation( imgs, [ One( R ) ] );
    map:= AlgebraHomomorphismByImagesNC( S, R, gens, imgs );
    SetRespectsOne( map, true );
    return map;
    end );


#############################################################################
##
#F  AlgebraHomomorphismByImages( <S>, <R>, <gens>, <imgs> )
##
InstallGlobalFunction( AlgebraHomomorphismByImages,
    function( S, R, gens, imgs )
    local hom;
    hom:= AlgebraGeneralMappingByImages( S, R, gens, imgs );
    if IsMapping( hom ) then
      return AlgebraHomomorphismByImagesNC( S, R, gens, imgs );
    else
      return fail;
    fi;
end );


#############################################################################
##
#F  AlgebraWithOneHomomorphismByImages( <S>, <R>, <gens>, <imgs> )
##
InstallGlobalFunction( AlgebraWithOneHomomorphismByImages,
    function( S, R, gens, imgs )
    local hom;
    hom:= AlgebraWithOneGeneralMappingByImages( S, R, gens, imgs );
    if IsMapping( hom ) then
      return AlgebraWithOneHomomorphismByImagesNC( S, R, gens, imgs );
    else
      return fail;
    fi;
end );


#############################################################################
##
#M  AlgebraHomomorphismByFunction( <A>, <B>, <f> )
#M  AlgebraWithOneHomomorphismByFunction( <A>, <B>, <f> )
##
InstallMethod( AlgebraHomomorphismByFunction,
    "for two algebras and a function",
    true,
    [ IsAlgebra, IsAlgebra, IsFunction ],
    function( A, B, f )
    return Objectify( TypeOfDefaultGeneralMapping( A, B,
        IsSPMappingByFunctionRep and IsAlgebraHomomorphism ), rec(fun:=f) );
    end);

InstallMethod(AlgebraWithOneHomomorphismByFunction,
    "for two algebras and a function",
    true,
    [ IsAlgebraWithOne, IsAlgebraWithOne, IsFunction ],
    function( A, B, f )
    return Objectify( TypeOfDefaultGeneralMapping( A, B,
        IsSPMappingByFunctionRep and IsAlgebraWithOneHomomorphism ),
        rec(fun:=f) );
    end);

#############################################################################
##
#M  ViewObj( <map> )  . . . . . . . . . . . . . . . . .  for algebra g.m.b.i.
##
InstallMethod( ViewObj, "for an algebra g.m.b.i", true,
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep ], 0,
function( map )
local mapi;
  mapi:=MappingGeneratorsImages(map);
  View(mapi[1]);
  Print(" -> ");
  View(mapi[2]);
end );


#############################################################################
##
#M  PrintObj( <map> ) . . . . . . . . . . . . . . . . .  for algebra g.m.b.i.
##
InstallMethod( PrintObj, "for an algebra-with-one hom. b.i", true,
    [     IsMapping and RespectsOne
      and IsAlgebraGeneralMappingByImagesDefaultRep ], 0,
function( map )
local mapi;
  mapi:=MappingGeneratorsImages(map);
  Print( "AlgebraWithOneHomomorphismByImages( ",
          Source( map ), ", ", Range( map ), ", ",
          mapi[1], ", ", mapi[2], " )" );
end );

InstallMethod( PrintObj, "for an algebra hom. b.i.", true,
    [     IsMapping
      and IsAlgebraGeneralMappingByImagesDefaultRep ], 0,
function( map )
local mapi;
  mapi:=MappingGeneratorsImages(map);
  Print( "AlgebraHomomorphismByImages( ",
          Source( map ), ", ", Range( map ), ", ",
          mapi[1], ", ", mapi[2], " )" );
end );

InstallMethod( PrintObj, "for an algebra-with-one g.m.b.i", true,
    [     IsGeneralMapping and RespectsOne
      and IsAlgebraGeneralMappingByImagesDefaultRep ], 0,
function( map )
local mapi;
  mapi:=MappingGeneratorsImages(map);
  Print( "AlgebraWithOneGeneralMappingByImages( ",
          Source( map ), ", ", Range( map ), ", ",
          mapi[1], ", ", mapi[2], " )" );
end );

InstallMethod( PrintObj, "for an algebra g.m.b.i", true,
    [     IsGeneralMapping
      and IsAlgebraGeneralMappingByImagesDefaultRep ], 0,
function( map )
local mapi;
  mapi:=MappingGeneratorsImages(map);
  Print( "AlgebraGeneralMappingByImages( ",
          Source( map ), ", ", Range( map ), ", ",
          mapi[1], ", ", mapi[2], " )" );
end );


#############################################################################
##
#M  AsLeftModuleGeneralMappingByImages( <alg_gen_map> )
##
##  If necessary then we compute a basis of the preimage,
##  and images of its basis vectors.
##
##  Note that we must prescribe also the products of basis vectors and
##  their images if <alg_gen_map> is not known to be a mapping.
##
InstallMethod( AsLeftModuleGeneralMappingByImages,
    "for an algebra general mapping by images",
    [     IsAlgebraGeneralMapping
      and IsAlgebraGeneralMappingByImagesDefaultRep ],
    function( alg_gen_map )

    local origgenerators,  # list of algebra generators of the preimage
          origgenimages,   # list of images of `origgenerators'
          generators,      # list of left module generators of the preimage
          genimages,       # list of images of `generators'
          A,               # source of the general mapping
          left,            # is it necessary to multiply also from the left?
                           # (not if `A' is associative or a Lie algebra)
          maxdim,          # upper bound on the dimension
          MB,              # mutable basis of the preimage
          dim,             # dimension of the actual left module
          len,             # number of algebra generators
          i, j,            # loop variables
          gen,             # loop over generators
          prod,            #
          result;          #

    A:=MappingGeneratorsImages(alg_gen_map);
    origgenerators := A[1];
    origgenimages  := A[2];

    if IsBasis( origgenerators ) then

      generators := origgenerators;
      genimages  := origgenimages;

    else

      generators := ShallowCopy( origgenerators );
      genimages  := ShallowCopy( origgenimages );

      A:= Source( alg_gen_map );

      left:= not (    ( HasIsAssociative( A ) and IsAssociative( A ) )
                   or ( HasIsLieAlgebra( A ) and IsLieAlgebra( A ) ) );

      if HasDimension( A ) then
        maxdim:= Dimension( A );
      else
        maxdim:= infinity;
      fi;

      # $A_1$
      MB:= MutableBasis( LeftActingDomain( A ), generators,
                                     Zero( A ) );
      dim:= 0;
      len:= Length( origgenerators );

      while dim < NrBasisVectors( MB ) and NrBasisVectors( MB ) < maxdim do

        # `MB' is a mutable basis of $A_i$.
        dim:= NrBasisVectors( MB );

        # Compute $\bigcup_{g \in S} ( A_i g \cup A_i g )$.
        for i in [ 1 .. len ] do
          gen:= origgenerators[i];
          for j in [ 1 .. Length( generators ) ] do
            prod:= generators[j] * gen;
            if not IsContainedInSpan( MB, prod ) then
              Add( generators, prod );
              Add( genimages, genimages[j] * origgenimages[i] );
              CloseMutableBasis( MB, prod );
            fi;
          od;
        od;

        if left then

          # Compute $\bigcup_{g \in S} ( A_i g \cup g A_i )$.
          for i in [ 1 .. len ] do
            gen:= origgenerators[i];
            for j in [ 1 .. Length( generators ) ] do
              prod:= gen * generators[j];
              if not IsContainedInSpan( MB, prod ) then
                Add( generators, prod );
                Add( genimages, origgenimages[i] * genimages[j] );
                CloseMutableBasis( MB, prod );
              fi;
            od;
          od;

        fi;

      od;

    fi;

    # If it is not known whether alg_gen_map is single valued, we need to
    # perform some extra work.
    if not (HasIsSingleValued( alg_gen_map ) and IsSingleValued( alg_gen_map )) then
      # TODO: This code below is far from optimal. Indeed, it would suffice to
      # loop over a basis; and we don't need to record all generator / image
      # pairs we obtain below, but rather only those that are not linearly
      # dependent on the already known pairs.
      len := Length( generators );
      for i in [ 1 .. len ] do
        for j in [ 1 .. len ] do
          Add( generators, generators[i] * generators[j] );
          Add( genimages, genimages[i] * genimages[j] );
        od;
      od;
    fi;

    # Construct the left module (general) mapping.
    result := LeftModuleGeneralMappingByImages( A, Range( alg_gen_map ),
               generators, genimages );

    # Transfer properties of alg_gen_map to result (in particular whether this is
    # a homomorphism).
    if HasIsSingleValued( alg_gen_map ) then
      SetIsSingleValued( result, IsSingleValued( alg_gen_map ) );
    fi;
    if HasIsTotal( alg_gen_map ) then
      SetIsTotal( result, IsTotal( alg_gen_map ) );
    fi;

    return result;
    end );


#############################################################################
##
#M  ImagesSource( <map> ) . . . . . . . . . . . . . . .  for algebra g.m.b.i.
##
InstallMethod( ImagesSource,
    "for an algebra g.m.b.i.",
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep ],
    function( map )
    local asmap;
    if     HasAsLeftModuleGeneralMappingByImages( map ) then
      asmap:= AsLeftModuleGeneralMappingByImages( map );
      if     IsLinearGeneralMappingByImagesDefaultRep( asmap )
         and IsBound( asmap!.basisimage ) then
        return SubFLMLORNC( Range( map ),
                            asmap!.basisimage, "basis" );
      fi;
    fi;
    return SubFLMLORNC( Range( map ), MappingGeneratorsImages(map)[2] );
    end );


#############################################################################
##
#M  PreImagesRange( <map> ) . . . . . . . . . . . . . .  for algebra g.m.b.i.
##
InstallMethod( PreImagesRange,
    "for an algebra g.m.b.i.",
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep ],
    function( map )
    local asmap;
    if     HasAsLeftModuleGeneralMappingByImages( map ) then
      asmap:= AsLeftModuleGeneralMappingByImages( map );
      if     IsLinearGeneralMappingByImagesDefaultRep( asmap )
         and IsBound( asmap!.basispreimage ) then
        return SubFLMLORNC( Source( map ),
                            asmap!.basispreimage, "basis" );
      fi;
    fi;
    return SubFLMLORNC( Source( map ), MappingGeneratorsImages(map)[1]);
    end );


#############################################################################
##
#M  CoKernelOfAdditiveGeneralMapping( <map> ) . . . . .  for algebra g.m.b.i.
##
InstallMethod( CoKernelOfAdditiveGeneralMapping,
    "for algebra g.m.b.i.",
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep ],
    function( map )
    local asmap, genimages, coker;

    asmap:= AsLeftModuleGeneralMappingByImages( map );

    if not IsBound( asmap!.corelations ) then
      MakeImagesInfoLinearGeneralMappingByImages( asmap );
    fi;
    genimages:= MappingGeneratorsImages(asmap)[2];
    coker:= SubFLMLORNC( Range( map ),
               List( asmap!.corelations,
                     r -> LinearCombination( genimages, r ) ) );
    SetCoKernelOfAdditiveGeneralMapping( asmap, coker );

    return coker;
    end );


#############################################################################
##
#M  IsSingleValued( <map> ) . . . . . . . . . . . . . .  for algebra g.m.b.i.
##
InstallMethod( IsSingleValued,
    "for algebra g.m.b.i.",
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep ],
function(map)
local S;
  S:=Source(map);

  # rewriting to left modules is not feasible for infinite dimensional
  # domains
  if not IsFiniteDimensional(S) then
    TryNextMethod();
  fi;
  return IsSingleValued( AsLeftModuleGeneralMappingByImages( map ) );
end);

#############################################################################
##
#M  IsSingleValued( <map> ) . . . . . . . . . . . . . .  for algebra g.m.b.i.
##
InstallTrueMethod( IsSingleValued, IsGeneralMapping and
  IsPolynomialRingDefaultGeneratorMapping );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <map> ) . . . . . .  for algebra g.m.b.i.
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "for algebra g.m.b.i.",
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep ],
    function( map )
    local asmap, generators, ker;

    asmap:= AsLeftModuleGeneralMappingByImages( map );

    if not IsBound( asmap!.relations ) then
      MakePreImagesInfoLinearGeneralMappingByImages( asmap );
    fi;
    generators:= MappingGeneratorsImages(asmap)[1];
    ker:= SubFLMLORNC( Source( map ),
               List( asmap!.relations,
                     r -> LinearCombination( generators, r ) ) );
    SetKernelOfAdditiveGeneralMapping( asmap, ker );

    if HasIsTotal( map ) and IsTotal( map ) then
      SetIsTwoSidedIdealInParent( ker, true );
    fi;

    return ker;
    end );


#############################################################################
##
#M  IsInjective( <map> )  . . . . . . . . . . . . . . .  for algebra g.m.b.i.
##
InstallMethod( IsInjective,
    "for algebra g.m.b.i.",
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep ],
    map -> IsInjective( AsLeftModuleGeneralMappingByImages( map ) ) );


#############################################################################
##
#M  ImagesRepresentative( <map>, <elm> )  . . . . . . .  for algebra g.m.b.i.
##
InstallMethod( ImagesRepresentative,
    "for algebra g.m.b.i., and element",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep,
      IsObject ],
    function( map, elm )
    return ImagesRepresentative( AsLeftModuleGeneralMappingByImages( map ),
                                 elm );
    end );


#############################################################################
##
#M  PreImagesRepresentative( <map>, <elm> ) . . . . . .  for algebra g.m.b.i.
##
InstallMethod( PreImagesRepresentative,
    "for algebra g.m.b.i., and element",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep,
      IsObject ],
    function( map, elm )
    return PreImagesRepresentative( AsLeftModuleGeneralMappingByImages(map),
                                    elm );
    end );

InstallMethod( PreImagesRepresentative,
    "for algebra g.m.b.i. knowing inverse, and element",
    FamRangeEqFamElm,
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep
      and HasInverseGeneralMapping,
      IsObject ],
    function( map, elm )
    return ImagesRepresentative( InverseGeneralMapping(map), elm );
    end );


#############################################################################
##
#M  \*( <c>, <map> )  . . . . . . . . . . . . for scalar and algebra g.m.b.i.
##
InstallMethod( \*,
    "for scalar and algebra g.m.b.i.",
    [ IsMultiplicativeElement,
      IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep ],
    function( scalar, map )
    return scalar * AsLeftModuleGeneralMappingByImages( map );
    end );


#############################################################################
##
#M  AdditiveInverseOp( <map> )  . . . . . . . . . . . .  for algebra g.m.b.i.
##
InstallMethod( AdditiveInverseOp,
    "for algebra g.m.b.i.",
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep ],
    map -> AdditiveInverse( AsLeftModuleGeneralMappingByImages( map ) ) );


#############################################################################
##
#M  CompositionMapping2( <map2>, map1> )  for lin. mapping & algebra g.m.b.i.
##
InstallMethod( CompositionMapping2,
    "for left module hom. and algebra g.m.b.i.",
    FamSource1EqFamRange2,
    [ IsLeftModuleHomomorphism,
          IsAlgebraGeneralMapping
      and IsAlgebraGeneralMappingByImagesDefaultRep ],
    function( map2, map1 )

    # Composition of two algebra homomorphisms is handled by another method.
    if     HasRespectsMultiplication( map2 )
       and HasRespectsMultiplication( map2 ) then
      TryNextMethod();
    fi;

    return CompositionMapping( map2,
                               AsLeftModuleGeneralMappingByImages( map1 ) );
    end );


#############################################################################
##
#M  CompositionMapping2( <map2>, map1> )  for algebra hom. & algebra g.m.b.i.
##
InstallMethod( CompositionMapping2,
    "for left module hom. and algebra g.m.b.i.",
    FamSource1EqFamRange2,
    [ IsAlgebraHomomorphism,
          IsAlgebraGeneralMapping
      and IsAlgebraGeneralMappingByImagesDefaultRep ],
    function( map2, map1 )
    local comp,        # composition of <map2> and <map1>, result
          gens,
          genimages,
          mapi1,mapi2;

    mapi1:=MappingGeneratorsImages(map1);
    mapi2:=MappingGeneratorsImages(map2);
    # Compute images for the generators of `map1'.
    if     IsAlgebraGeneralMappingByImagesDefaultRep( map2 )
       and mapi1[2]=mapi2[1] then

      gens      := mapi1[1];
      genimages := mapi2[2];

    else

      gens:= mapi1[1];
      genimages:= List( mapi1[2],
                        v -> ImagesRepresentative( map2, v ) );

    fi;

    # Construct the linear general mapping.
    comp:= AlgebraGeneralMappingByImages(
               Source( map1 ), Range( map2 ), gens, genimages );

    # Maintain info.
    if     HasRespectsOne( map1 ) and HasRespectsOne( map2 )
       and RespectsOne( map1 ) and RespectsOne( map2 ) then
      SetRespectsOne( comp, true );
    fi;
    if     HasAsLeftModuleGeneralMappingByImages( map1 )
       and HasAsLeftModuleGeneralMappingByImages( map2 ) then
      SetAsLeftModuleGeneralMappingByImages( comp,
          CompositionMapping( AsLeftModuleGeneralMappingByImages( map2 ),
                              AsLeftModuleGeneralMappingByImages( map1 ) ) );
    fi;

    # Return the composition.
    return comp;
    end );


#############################################################################
##
#M  \+( <map1>, map2> ) . . . . . . . . . . . . . . . .  for algebra g.m.b.i.
##
##  The sum of an algebra general mapping and a left module general mapping
##  is in general only a left module general mapping.
##  So we delegate to the methods for left module general mappings.
##
InstallOtherMethod( \+,
    "for an algebra g.m.b.i. and general mapping",
    IsIdenticalObj,
    [ IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep,
      IsGeneralMapping ],
    function( map1, map2 )
    return AsLeftModuleGeneralMappingByImages( map1 ) + map2;
    end );

InstallOtherMethod( \+,
    "for general mapping and algebra g.m.b.i.",
    IsIdenticalObj,
    [ IsGeneralMapping,
      IsGeneralMapping and IsAlgebraGeneralMappingByImagesDefaultRep ],
    function( map1, map2 )
    return map1 + AsLeftModuleGeneralMappingByImages( map2 );
    end );


#############################################################################
##
##  2. methods for operation algebra homomorphisms
##


#############################################################################
##
#R  IsOperationAlgebraHomomorphismDefaultRep
##
##  is a default representation of operation homomorphisms to matrix FLMLORs.
##  It assumes that a basis of the operation domain is known.
##  (For operation homomorphisms from f.~p. algebras to matrix algebras,
##  see `IsAlgebraHomomorphismFromFpRep'.)
##
##  Defining components are
##
##  `basis'
##      basis of the domain on that the source acts
##
##  `operation'
##      the function via that the source acts
##
##  Images can be computed by the action, w.r.t. the basis `basisImage'.
##  Preimages can be computed using the components
##
##  `basisImage'
##      basis of the image
##
##  `preimagesBasisImage'
##      list of preimages of the basis vectors of `basisImage'.
##
##  These components are computed as soon as they are needed.
##
##  Note that we cannot use the attribute `AsLinearGeneralMappingByImages'
##  because the source may be infinite dimensional, i.e., we cannot write
##  down the left module general mapping.
##
DeclareRepresentation( "IsOperationAlgebraHomomorphismDefaultRep",
    IsAlgebraHomomorphism and IsAdditiveElementWithInverse
    and IsAttributeStoringRep,
    [ "basis", "operation",
      "basisImage", "preimagesBasisImage" ] );


#############################################################################
##
#M  ViewObj( <ophom> )  . . . . . . . . for an operation algebra homomorphism
##
InstallMethod( ViewObj,
    "for an operation algebra homomorphism",
    [ IsOperationAlgebraHomomorphismDefaultRep ],
    function( ophom )
    Print( "<op. hom. ", Source( ophom ), " -> matrices of dim. ",
           Length( BasisVectors( ophom!.basis ) ), ">" );
    end );


#############################################################################
##
#M  PrintObj( <ophom> ) . . . . . . . . for an operation algebra homomorphism
##
InstallMethod( PrintObj,
    "for an operation algebra homomorphism",
    [ IsOperationAlgebraHomomorphismDefaultRep ],
    function( ophom )
    if ophom!.operation = OnRight then
      Print( "OperationAlgebraHomomorphism( ",
             Source( ophom ), ", ", ophom!.basis, " )" );
    else
      Print( "OperationAlgebraHomomorphism( ",
             Source( ophom ), ", ", ophom!.basis, ", ",
             ophom!.operation, " )" );
    fi;
    end );


#############################################################################
##
#F  InducedLinearAction( <basis>, <elm>, <opr> )
##
InstallGlobalFunction( InducedLinearAction, function( basis, elm, opr )
    return List( BasisVectors( basis ),
                 x -> Coefficients( basis, opr( x, elm ) ) );
end );


#############################################################################
##
#M  MakePreImagesInfoOperationAlgebraHomomorphism( <ophom> )
##
InstallMethod( MakePreImagesInfoOperationAlgebraHomomorphism,
    "for an operation algebra homomorphism",
    [ IsOperationAlgebraHomomorphismDefaultRep ],
    function( ophom )

    local A,               # source of the general mapping
          F,               # left acting domain
          origgenerators,  # list of algebra generators of the preimage
          origgenimages,   # list of images of `origgenerators'
          I,               # image of the mapping
          genimages,       # list of left module generators of the image
          preimages,       # list of preimages of `genimages'
          maxdim,          # upper bound on the dimension
          MB,              # mutable basis of the image
          dim,             # dimension of the actual left module
          len,             # number of algebra generators
          i, j,            # loop variables
          gen,             # loop over generators
          prod;            #

    A:= Source( ophom );
    F:= LeftActingDomain( A );
    dim:= Length( BasisVectors( ophom!.basis ) );

    if IsRingWithOne( A ) then
      origgenerators:= GeneratorsOfAlgebraWithOne( A );
      origgenimages:= List( origgenerators,
          a -> InducedLinearAction( ophom!.basis, a, ophom!.operation ) );
      if IsEmpty( origgenimages ) then
        I:= FLMLORWithOneByGenerators( F, origgenimages,
                                       Immutable( NullMat( F, dim, dim ) ) );
      else
        I:= FLMLORWithOneByGenerators( F, origgenimages );
      fi;
    else
      origgenerators:= GeneratorsOfAlgebra( A );
      origgenimages:= List( origgenerators,
          a -> InducedLinearAction( ophom!.basis, a, ophom!.operation ) );
      if IsEmpty( origgenimages ) then
        I:= FLMLORByGenerators( F, origgenimages,
                                   Immutable( NullMat( F, dim, dim ) ) );
      else
        I:= FLMLORByGenerators( F, origgenimages );
      fi;
    fi;

    preimages := [ One( A ) ];
    genimages := [ InducedLinearAction( ophom!.basis, One( A ),
                                        ophom!.operation ) ];
    maxdim:= dim^2;

    # $A_1$
    MB:= MutableBasis( F, genimages, Zero( I ) );
    dim:= 0;
    len:= Length( origgenimages );

    while dim < NrBasisVectors( MB ) and NrBasisVectors( MB ) < maxdim do

      # `MB' is a mutable basis of $A_i$.
      dim:= NrBasisVectors( MB );

      # Compute $\bigcup_{g \in S} ( A_i g \cup A_i g )$.
      for i in [ 1 .. len ] do
        gen:= origgenimages[i];
        for j in [ 1 .. Length( genimages ) ] do
          prod:= genimages[j] * gen;
          if not IsContainedInSpan( MB, prod ) then
            Add( genimages, prod );
            Add( preimages, preimages[j] * origgenerators[i] );
            CloseMutableBasis( MB, prod );
          fi;
        od;
      od;

    od;

    # Set the desired components.
    ophom!.basisImage:= BasisNC( I, genimages );
    ophom!.preimagesBasisImage:= Immutable( preimages );
end );


#############################################################################
##
#M  ImagesRepresentative( <ophom>, <elm> )  . . . . . . . . for op. alg. hom.
##
InstallMethod( ImagesRepresentative,
    "for an operation algebra homomorphism, and an element",
    FamSourceEqFamElm,
    [ IsOperationAlgebraHomomorphismDefaultRep, IsRingElement ],
    function( ophom, elm )
    return InducedLinearAction( ophom!.basis, elm, ophom!.operation );
    end );


#############################################################################
##
#M  PreImagesRepresentative( <ophom>, <mat> )
##
BindGlobal( "PreImagesRepresentativeOperationAlgebraHomomorphism", function( ophom, mat )
    if not IsBound( ophom!.basisImage ) then
      MakePreImagesInfoOperationAlgebraHomomorphism( ophom );
    fi;
    mat:= Coefficients( ophom!.basisImage, mat );
    if mat <> fail then
      mat:= LinearCombination( ophom!.preimagesBasisImage, mat );
    fi;
    return mat;
end );

InstallMethod( PreImagesRepresentative,
    "for an operation algebra homomorphism, and an element",
    FamRangeEqFamElm,
    [ IsOperationAlgebraHomomorphismDefaultRep, IsMatrix ],
    PreImagesRepresentativeOperationAlgebraHomomorphism );


#############################################################################
##
#R  IsAlgebraHomomorphismFromFpRep
##
##  is a representation of operation homomorphisms from f.~p. FLMLORs
##  to matrix FLMLORs.
##  Contrary to `IsOperationAlgebraHomomorphismDefaultRep', no basis of the
##  source is needed, computing images is done via `MappedExpression'.
##
##  Defining components are
##
##  `Agenerators'
##      generators of the f.~p. algebra
##
##  `Agenimages'
##      images of `Agenerators'
##
##  Preimages can be computed using the components
##
##  `basisImage'
##      basis of the image
##
##  `preimagesBasisImage'
##      list of preimages of the basis vectors of `basisImage'.
##
##  (This works analogously to `IsOperationAlgebraHomomorphismDefaultRep'.)
##  These components are computed as soon as they are needed.
##
##  Note that also here, we cannot use the attribute
##  `AsLinearGeneralMappingByImages'.
##
DeclareRepresentation( "IsAlgebraHomomorphismFromFpRep",
    IsAlgebraHomomorphism and IsAdditiveElementWithInverse
    and IsAttributeStoringRep,
    [ "Agenerators", "Agenimages",
      "basisImage", "preimagesBasisImage" ] );


#############################################################################
##
#M  ViewObj( <ophom> )  . . . . . . . . for an algebra homomorphism from f.p.
##
InstallMethod( ViewObj,
    "for an alg. hom. from f. p. algebra",
    [ IsAlgebraHomomorphismFromFpRep ],
    function( ophom )
    Print( "<op. hom. ", Source( ophom ), " -> matrices of dim. ",
           Length( ophom!.Agenimages[1] ), ">" );
    end );


#############################################################################
##
#M  PrintObj( <hom> ) . . . . . . . . . for an algebra homomorphism from f.p.
##
InstallMethod( PrintObj,
    "for an alg. hom. from f. p. algebra",
    [ IsAlgebraHomomorphismFromFpRep ],
    function( hom )
    Print( "AlgebraHomomorphismByImages( ",
           Source( hom ), ", ", Range( hom ), ", ",
           hom!.Agenerators, ", ", hom!.Agenimages, " )" );
    end );
#T this does not admit to recover the homomorphism from the printed data;
#T in fact we have no function to  construct such a homomorphism ...


#############################################################################
##
#M  MakePreImagesInfoOperationAlgebraHomomorphism( <ophom> )
##
InstallMethod( MakePreImagesInfoOperationAlgebraHomomorphism,
    "for an alg. hom. from f. p. algebra",
    [ IsAlgebraHomomorphismFromFpRep ],
    function( ophom )

    local A,               # source of the general mapping
          F,               # left acting domain
          I,               # image of the homomorphism
          origgenerators,  # list of algebra generators of the preimage
          origgenimages,   # list of images of `origgenerators'
          genimages,       # list of left module generators of the image
          preimages,       # list of preimages of `genimages'
          maxdim,          # upper bound on the dimension
          MB,              # mutable basis of the image
          dim,             # dimension of the actual left module
          len,             # number of algebra generators
          i, j,            # loop variables
          gen,             # loop over generators
          prod;            #

    A:= Source( ophom );
    F:= LeftActingDomain( A );
    I:= ImagesSource( ophom );

    origgenerators := ophom!.Agenerators;
    origgenimages  := ophom!.Agenimages;

    dim:= Length( origgenimages[1] );
    if dim = 0 then
      ophom!.basisImage:= BasisNC( I, [] );
      ophom!.preimagesBasisImage:= Immutable( [] );
      return;
    fi;

    maxdim:= dim^2;
    preimages := [ One( A ) ];
    genimages := [ One( origgenimages[1] ) ];

    # $A_1$
    MB:= MutableBasis( F, genimages, Zero( I ) );
    dim:= 0;
    len:= Length( origgenimages );

    while dim < NrBasisVectors( MB ) and NrBasisVectors( MB ) < maxdim do

      # `MB' is a mutable basis of $A_i$.
      dim:= NrBasisVectors( MB );

      # Compute $\bigcup_{g \in S} ( A_i g \cup A_i g )$.
      for i in [ 1 .. len ] do
        gen:= origgenimages[i];
        for j in [ 1 .. Length( genimages ) ] do
          prod:= genimages[j] * gen;
          if not IsContainedInSpan( MB, prod ) then
            Add( genimages, prod );
            Add( preimages, preimages[j] * origgenerators[i] );
            CloseMutableBasis( MB, prod );
          fi;
        od;
      od;

    od;

    # Set the desired components.
    ophom!.basisImage:= BasisNC( I, genimages );
    ophom!.preimagesBasisImage:= Immutable( preimages );
    end );


#############################################################################
##
#M  ImagesRepresentative( <ophom>, <elm> )  . . . . . . . . for op. alg. hom.
##
InstallMethod( ImagesRepresentative,
    "for an alg. hom. from f. p. algebra, and an element",
    FamSourceEqFamElm,
    [ IsAlgebraHomomorphismFromFpRep, IsRingElement ],
    function( ophom, elm )
    return MappedExpression( elm, ophom!.Agenerators, ophom!.Agenimages );
    end );


#############################################################################
##
#M  PreImagesRepresentative( <ophom>, <mat> )
##
InstallMethod( PreImagesRepresentative,
    "for an alg. hom. from f. p. algebra, and an element",
    FamRangeEqFamElm,
    [ IsAlgebraHomomorphismFromFpRep, IsMatrix ],
    PreImagesRepresentativeOperationAlgebraHomomorphism );


#############################################################################
##
#M  OperationAlgebraHomomorphism( <A>, <basis>, <opr> )
##
InstallMethod( OperationAlgebraHomomorphism,
    "for a FLMLOR, a basis, and a function",
    [ IsFLMLOR, IsBasis, IsFunction ],
    function( A, basis, opr )

    local ophom, image;

    # Make the general mapping.
    ophom:= Objectify( NewType( GeneralMappingsFamily(
                                  ElementsFamily( FamilyObj( A ) ),
                                  CollectionsFamily( FamilyObj(
                                      LeftActingDomain( A ) ) ) ),
                                  IsSPGeneralMapping
                              and IsAlgebraHomomorphism
                              and IsOperationAlgebraHomomorphismDefaultRep ),
                     rec(
                          operation := opr,
                          basis     := basis
                         ) );
    SetSource( ophom, A );

    # Handle the case that the basis is empty.
    if IsEmpty( basis ) then

      image                      := NullAlgebra( LeftActingDomain( A ) );
      ophom!.basisImage          := Basis( image );
      ophom!.preimagesBasisImage := Immutable( [ Zero( A ) ] );

      SetRange( ophom, image );
      SetKernelOfAdditiveGeneralMapping( ophom, A );
      SetIsSurjective( ophom, true );

    fi;

    # Return the operation homomorphism.
    return ophom;
    end );


#############################################################################
##
#M  OperationAlgebraHomomorphism( <A>, <C> )
##
##  Add the default argument `OnRight'.
##
InstallOtherMethod( OperationAlgebraHomomorphism,
    "for a FLMLOR and a collection (add `OnRight' argument)",
    [ IsFLMLOR, IsCollection ],
    function( A, C )
    return OperationAlgebraHomomorphism( A, C, OnRight );
    end );


#############################################################################
##
#M  OperationAlgebraHomomorphism( <A>, <V>, <opr> )
##
##  For a finite dimensional free left module <V> with known generators,
##  we assume that a basis can be computed.
##
InstallOtherMethod( OperationAlgebraHomomorphism,
    "for a FLMLOR, a free left module with known generators, and a function",
    [ IsFLMLOR,
      IsFreeLeftModule and IsFiniteDimensional and HasGeneratorsOfLeftModule,
      IsFunction ],
    function( A, V, opr )
    return OperationAlgebraHomomorphism( A, Basis( V ), opr );
    end );


#############################################################################
##
#M  Range( <ophom> )  . . . . . . . . . .  for operation algebra homomorphism
##
##  An operation algebra homomorphism that does not know its range cannot be
##  forced to be surjective; so we may choose a full matrix FLMLOR.
##
InstallMethod( Range,
    "for operation algebra homomorphism (set full matrix FLMLOR)",
    [ IsOperationAlgebraHomomorphismDefaultRep ],
    ophom -> FullMatrixFLMLOR( LeftActingDomain( Source( ophom ) ),
                               Length( BasisVectors( ophom!.basis ) ) ) );


#############################################################################
##
#M  KernelOfAdditiveGeneralMapping( <ophom> ) . .  for operation algebra hom.
##
##  For a finite dimensional acting algebra, we compute a basis of the kernel
##  by solving a linear equation system.
##
InstallMethod( KernelOfAdditiveGeneralMapping,
    "for operation algebra hom. with fin. dim. source",
    [ IsMapping and IsOperationAlgebraHomomorphismDefaultRep ],
    function( ophom )
    local A,         # source of the homomorphism
          BA,        # basis of `A'
          BV,        # basis of the module
          opr,       # operation of `A' on the vectors
          nullsp;    # coefficients vectors of a basis of the kernel

    A:= Source( ophom );

    if IsTrivial( A ) then
      return A;
    elif not IsFiniteDimensional( A ) then
      TryNextMethod();
    fi;

    BA:= Basis( A );
    BV:= ophom!.basis;
    opr:= ophom!.operation;

    nullsp:= NullspaceMat( List( BA,
                 a -> Concatenation( List( BV,
                          v -> Coefficients( BV, opr( v, a ) ) ) ) ) );
    nullsp:= SubFLMLORNC( A,
                 List( nullsp, v -> LinearCombination( BA, v ) ), "basis" );
    SetIsTwoSidedIdealInParent( nullsp, true );

    return nullsp;
    end );


#############################################################################
##
#M  RepresentativeLinearOperation( <A>, <v>, <w>, <opr> )
##
##  Let <A> be a finite dimensional algebra over the ring $R$,
##  <v> and <w> either elements in <A> or tuples of elements in <A>,
##  and <opr> equal to `OnRight' or `OnTuples', respectively.
##  We compute an element of <A> that maps <v> to <w>.
##
##  We compute the coefficients $a_i$ in the equation system
##  $\sum_{i=1}^n a_i <opr>( <v>, b_i ) = <w>$,
##  where $(b_1, b_2, \ldots, b_n)$ is a basis of <A>.
##
##  For a tuple $(v_1, \ldots, v_k)$ of vectors we simply replace $v b_i$ by
##  the concatenation of the $v_j b_i$ for all $j$, and replace $w$ by the
##  concatenation $(w_1, \ldots, w_k)$, and solve this system.
##
##  (There are also methods for matrix algebras acting on row vectors via
##  `OnRight' or `OnTuples'.)
##
InstallMethod( RepresentativeLinearOperation,
    "for a FLMLOR, two elements in it, and `OnRight'",
    IsCollsElmsElmsX,
    [ IsFLMLOR, IsVector, IsVector, IsFunction ],
    function( A, v, w, opr )

    local B, vectors, a;

    if not ( v in A and w in A and opr = OnRight ) then
      TryNextMethod();
    fi;

    if IsTrivial( A ) then
      if IsZero( w ) then
        return Zero( A );
      else
        return fail;
      fi;
    fi;

    B:= Basis( A );
    vectors:= BasisVectors( B );

    # Compute the matrix of the equation system,
    # the coefficient vector $a$, \ldots
    a:= SolutionMat( List( vectors, x -> Coefficients( B, v * x ) ),
                     Coefficients( B, w ) );
    if a = fail then
      return fail;
    fi;

    # \ldots and the representative.
    return LinearCombination( B, a );
    end );


InstallOtherMethod( RepresentativeLinearOperation,
    "for a FLMLOR, two tuples of elements in it, and `OnTuples'",
    IsFamFamFamX,
    [ IsFLMLOR, IsHomogeneousList, IsHomogeneousList, IsFunction ],
    function( A, vs, ws, opr )

    local B, vectors, a;

    if not (     Length( vs ) = Length( ws )
             and IsSubset( A, vs ) and IsSubset( A, ws )
             and opr = OnTuples ) then
      TryNextMethod();
    fi;

    if IsTrivial( A ) then
      if ForAll( ws, IsZero ) then
        return Zero( A );
      else
        return fail;
      fi;
    fi;

    B:= Basis( A );
    vectors:= BasisVectors( B );

    # Compute the matrix of the equation system,
    # the coefficient vector $a$, \ldots
    a:= SolutionMat( List( vectors,
                           x -> Concatenation( List( vs,
                                    v -> Coefficients( B, v * x ) ) ) ),
                     Concatenation( List( ws,
                                    w -> Coefficients( B, w ) ) ) );
    if a = fail then
      return fail;
    fi;

    # \ldots and the representative.
    return LinearCombination( B, a );
    end );


#############################################################################
##
##  3. methods for natural homomorphisms from algebras
##
#M  NaturalHomomorphismByIdeal( <A>, <I> )  . . . . . map onto factor algebra
##
##  <#GAPDoc Label="NaturalHomomorphismByIdeal_algebras">
##  <ManSection>
##  <Meth Name="NaturalHomomorphismByIdeal" Arg='A, I'
##   Label="for an algebra and an ideal"/>
##
##  <Description>
##  For an algebra <A>A</A> and an ideal <A>I</A> in <A>A</A>,
##  the return value of <Ref Oper="NaturalHomomorphismByIdeal"/>
##  is a homomorphism of algebras, in particular the range of this mapping
##  is also an algebra.
##  <P/>
##  <Example><![CDATA[
##  gap> L:= FullMatrixLieAlgebra( Rationals, 3 );;
##  gap> C:= LieCentre( L );
##  <two-sided ideal in <Lie algebra of dimension 9 over Rationals>,
##    (dimension 1)>
##  gap> hom:= NaturalHomomorphismByIdeal( L, C );
##  <linear mapping by matrix, <Lie algebra of dimension
##  9 over Rationals> -> <Lie algebra of dimension 8 over Rationals>>
##  gap> ImagesSource( hom );
##  <Lie algebra of dimension 8 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#M  NaturalHomomorphismByIdeal( <A>, <triv> ) . . . . . . onto trivial FLMLOR
##
##  Return the identity mapping.
##
InstallMethod( NaturalHomomorphismByIdeal,
    "for FLMLOR and trivial FLMLOR",
    IsIdenticalObj,
    [ IsFLMLOR, IsFLMLOR and IsTrivial ], SUM_FLAGS,
    function( A, I )
    return IdentityMapping( A );
    end );


#############################################################################
##
#M  NaturalHomomorphismByIdeal( <A>, <I> )  . . . . for two fin. dim. FLMLORs
##
##  We return a left module m.b.m. from <A> onto the factor `<A>/<I>'.
##  The image is a s.c. algebra if <I> is nontrivial,
##  and otherwise the identity mapping of <A>.
##
InstallMethod( NaturalHomomorphismByIdeal,
    "for two finite dimensional FLMLORs",
    IsIdenticalObj,
    [ IsFLMLOR, IsFLMLOR ],
    function( A, I )

    local F,         # left acting domain of `A'
          zero,      # zero of `F'
          Ivectors,  # basis vectors of a basis of `I'
          mb,        # mutable basis of `I'
          compl,     # basis vectors of a complement of `I' in `A'
          gen,       # loop over a basis of `A'
          B,         # basis of `A', through `I'
          k,         # length of `Ivectors'
          n,         # length of `compl'
          T,         # s.c. table of a basis of the image
          i, j,      # loop variables
          coeff,     # coefficients of a product
          pos,       # relevant positions
          img,       # image of the homomorphism
          canbas,    # canonical basis of the image
          Bimgs,     # images of the vectors of `B' under the hom.
          nathom;    # the homomorphism, result

    # Check that the FLMLORs are finite dimensional.
    if not IsFiniteDimensional( A ) or not IsFiniteDimensional( I ) then
      TryNextMethod();
    fi;

    # If `A' is equal to `I', return a zero mapping.
    if not IsIdeal( A, I ) then
      Error( "<I> must be an ideal in <A>" );
    elif Dimension( A ) = Dimension( I ) then
      return ZeroMapping( A, NullAlgebra( LeftActingDomain( A ) ) );
    fi;

    # If `I' is trivial, return the identity mapping.
    if IsTrivial( I ) then
      return IdentityMapping( A );
    fi;

    # If the left acting domains are different, adjust them.
    F:= LeftActingDomain( A );
    if F <> LeftActingDomain( I ) then
      F:= Intersection2( A, LeftActingDomain( I ) );
      A:= AsFLMLOR( F, A );
      I:= AsFLMLOR( F, I );
    fi;

    # Compute a basis of `A' through a basis of `I'.
    Ivectors:= BasisVectors( Basis( I ) );
    mb:= MutableBasis( F, Ivectors );
    compl:= [];
    for gen in BasisVectors( Basis( A ) ) do
      if not IsContainedInSpan( mb, gen ) then
        Add( compl, gen );
        CloseMutableBasis( mb, gen );
      fi;
    od;
    B:= BasisNC( A, Concatenation( Ivectors, compl ) );

    # Compute the structure constants of the quotient algebra.
    zero:= Zero( F );
    k:= Length( Ivectors );
    n:= Length( compl );
    if   HasIsCommutative( A ) and IsCommutative( A ) then
      T:= EmptySCTable( n, Zero( F ), "symmetric" );
    elif HasIsAnticommutative( A ) and IsAnticommutative( A ) then
      T:= EmptySCTable( n, Zero( F ), "antisymmetric" );
    else
      T:= EmptySCTable( n, Zero( F ) );
    fi;
    for i in [ 1 .. n ] do
      for j in [ 1 .. n ] do
        coeff:= Coefficients( B, compl[i] * compl[j] ){ [ k+1 .. k+n ] };
        pos:= Filtered( [ 1 .. n ], i -> coeff[i] <> zero );
        if not IsEmpty( pos ) then
          T[i][j]:= Immutable( [ pos, coeff{ pos } ] );
        fi;
      od;
    od;
#T use (anti)symm. here!!!

    # Compute the linear mapping by images.
    img:= AlgebraByStructureConstants( F, T );
    canbas:= CanonicalBasis( img );
    zero:= zero * [ 1 .. n ];
    Bimgs:= Concatenation( List( [ 1 .. k ], v -> zero ),
                           Immutable( IdentityMat( n, F ) ) );

    nathom:= LeftModuleHomomorphismByMatrix( B, Bimgs, canbas );
#T take a special representation for nat. hom.s,
#T (just compute coefficients, and then choose a subset ...)
    SetIsAlgebraWithOneHomomorphism( nathom, true );
    SetIsInjective( nathom, false );
    SetIsSurjective( nathom, true );

    # Enter the preimages info.
    nathom!.basisimage:= canbas;
    nathom!.preimagesbasisimage:= Immutable( compl );
#T relations are not needed if the kernel is known ?

    SetKernelOfAdditiveGeneralMapping( nathom, I );

    # Run the implications for the factor.
    UseFactorRelation( A, I, img );

    return nathom;
    end );


#############################################################################
##
##  4. methods for isomorphisms to matrix algebras
##


#############################################################################
##
#M  IsomorphismMatrixFLMLOR( <A> )  . . . . . . for a fin. dim. assoc. FLMLOR
##
##  A FLMLOR with a multiplicative neutral element acts faithfully on itself
##  via right multiplication.
##  So we get for an $n$ dimensional algebra a representation with matrices
##  of dimension $n \times n$.
##
InstallMethod( IsomorphismMatrixFLMLOR,
    "for a finite dimensional associative FLMLOR with identity",
    [ IsFLMLOR ],
    function( A )

    local B,     # basis of `A'
          F,     # left acting domain of `A'
          I,     # image of the isomorphism
          map,   # isomorphism, result
          gens,  # algebra generators of `A'
          imgs,  # images of `gens' under the action from the right
          dim;   # dimension of `A'

    if    IsSubalgebraFpAlgebra( A )   # avoid to call `IsFiniteDimensional'
                                       # in this case
       or not IsFiniteDimensional( A )
       or not IsAssociative( A )
       or MultiplicativeNeutralElement( A ) = fail then
      TryNextMethod();
    fi;

    B:= Basis( A );
    F:= LeftActingDomain( A );

    if IsEmpty( B ) then

      # Handle the case that `A' is trivial.
      I:= NullAlgebra( F );
      map:= LeftModuleHomomorphismByImagesNC( A, I, B, Basis( I ) );
      SetRespectsMultiplication( map, true );

    else

      if IsRingWithOne( A ) then
        gens:= GeneratorsOfAlgebraWithOne( A );
      else
        gens:= GeneratorsOfAlgebra( A );
      fi;
      imgs:= List( gens, a -> InducedLinearAction( B, a, OnRight ) );
      if IsEmpty( imgs ) then
        dim:= Dimension( A );
        imgs[1]:= Immutable( NullMat( F, dim, dim ) );
      fi;
      I:= FLMLORByGenerators( F, imgs );
      UseIsomorphismRelation( A, I );

      # Make an operation algebra homomorphism.
      map:= Objectify( NewType( GeneralMappingsFamily(
                                    ElementsFamily( FamilyObj( A ) ),
                                    ElementsFamily( FamilyObj( imgs ) ) ),
                                  IsSPGeneralMapping
                              and IsAlgebraHomomorphism
                              and IsOperationAlgebraHomomorphismDefaultRep ),
                       rec(
                            operation := OnRight,
                            basis     := B
                           ) );
      SetSource( map, A );
      SetRange( map, I );

    fi;

    SetIsSurjective( map, true );
    SetIsInjective( map, true );

    return map;
    end );


#############################################################################
##
##  5. methods for isomorphisms to f.p. algebras
##


#############################################################################
##
#M  IsomorphismFpFLMLOR( <A> )  . . . . . . . . for a fin. dim. assoc. FLMLOR
##
##  Construct the free (associative) algebra $F$ on generators of <A>,
##  and factor out the two-sided ideal $I$ spanned by the structure relators
##  w.r.t. a basis of <A>.
##  Then clearly the kernel of the homomorphism from $F$ to <A> contains $I$,
##  on the other hand any expression in the kernel can be reduced to a sum
##  of generators modulo the structure relators of <A>, and this must be
##  trivial since the images of generators were assumed to be linearly
##  independent.
##
##  We write down all relations to reduce words of length two to
##  linear combinations of the generators.
##  So it makes no difference whether the f.p. algebra is constructed
##  from a free algebra or from a free associative algebra.
##  But if <A> knows to be associative then we take a free associative
##  algebra.
##
InstallMethod( IsomorphismFpFLMLOR,
    "for a finite dimensional FLMLOR-with-one",
    [ IsFLMLORWithOne ],
    function( A )

    local Agens,           # list of algebra generators of `A'
          F,               # free (associative) algebra
          Fgens,           # list of images of `Agens'
          generators,      # list of left module generators of the preimage
          genimages,       # list of images of `generators'
          left,            # is it necessary to multiply also from the left?
          maxdim,          # upper bound on the dimension
          MB,              # mutable basis of the preimage
          dim,             # dimension of the actual left module
          len,             # number of algebra generators
          i, j,            # loop variables
          gen,             # loop over generators
          prod,            #
          rels,            # relators list
          rel,             # one relator
          coeff,           # coefficients of product of basis vectors
          k,               # loop over `coeff'
          B,               # basis of `A'
          Fp,              # f.p. algebra
          Fam,             # elements family of the family of `Fp'
          map;             # the isomorphism, result

    if not IsFiniteDimensional( A ) then
      TryNextMethod();
    fi;

    Agens:= GeneratorsOfAlgebraWithOne( A );

    if HasIsAssociative( A ) and IsAssociative( A ) then
      F:= FreeAssociativeAlgebraWithOne( LeftActingDomain( A ),
              Length( Agens ) );
      left:= false;
    else
      F:= FreeAlgebraWithOne( LeftActingDomain( A ), Length( Agens ) );
      left:= true;
    fi;

    Fgens:= GeneratorsOfAlgebraWithOne( F );

    generators := ShallowCopy( Agens );
    genimages  := ShallowCopy( Fgens );

    if HasDimension( A ) then
      maxdim:= Dimension( A );
    else
      maxdim:= infinity;
    fi;

    # $A_1$
    MB:= MutableBasis( LeftActingDomain( A ), generators,
                                   Zero( A ) );
    dim:= 0;
    len:= Length( Agens );

    while dim < NrBasisVectors( MB ) and NrBasisVectors( MB ) < maxdim do

      # `MB' is a mutable basis of $A_i$.
      dim:= NrBasisVectors( MB );

      # Compute $\bigcup_{g \in S} ( A_i g \cup A_i g )$.
      for i in [ 1 .. len ] do
        gen:= Agens[i];
        for j in [ 1 .. Length( generators ) ] do
          prod:= generators[j] * gen;
          if not IsContainedInSpan( MB, prod ) then
            Add( generators, prod );
            Add( genimages, genimages[j] * Fgens[i] );
            CloseMutableBasis( MB, prod );
          fi;
        od;
      od;

      if left then

        # Compute $\bigcup_{g \in S} ( A_i g \cup g A_i )$.
        for i in [ 1 .. len ] do
          gen:= Agens[i];
          for j in [ 1 .. Length( generators ) ] do
            prod:= gen * generators[j];
            if not IsContainedInSpan( MB, prod ) then
              Add( generators, prod );
              Add( genimages, Fgens[i] * genimages[j] );
              CloseMutableBasis( MB, prod );
            fi;
          od;
        od;

      fi;

    od;

    B:= BasisNC( A, generators );
    dim:= Length( generators );

    # Construct the relators given by the multiplication table.
    rels:= [];
    for i in [ 1 .. dim ] do
      for j in [ 1 .. dim ] do
        coeff:= Coefficients( B, generators[i] * generators[j] );
        rel:= genimages[i] * genimages[j];
        for k in [ 1 .. dim ] do
          rel:= rel - coeff[k] * genimages[k];
        od;
        if not IsZero( rel ) then
          Add( rels, rel );
        fi;
      od;
    od;

    # Remove duplicate relators.
    rels:= Set( rels );

    # Construct the f.p. algebra.
    Fp:= FactorFreeAlgebraByRelators( F, rels );
    Fam:= ElementsFamily( FamilyObj( Fp ) );

    # Set useful information.
    UseIsomorphismRelation( A, Fp );

    # Map the elements of the free algebra into the f.p. algebra.
    Fgens:= List( Fgens, a -> ElementOfFpAlgebra( Fam, a ) );
    genimages:= List( genimages, a -> ElementOfFpAlgebra( Fam, a ) );

    # Set the info to compute with a basis of the f.p. algebra.
    SetNiceAlgebraMonomorphism( Fp,
        Objectify( NewType( GeneralMappingsFamily(
                              ElementsFamily( FamilyObj( Fp ) ),
                              ElementsFamily( FamilyObj( A ) ) ),
                                IsSPGeneralMapping
                            and IsAlgebraHomomorphism
                            and IsAlgebraHomomorphismFromFpRep ),
           rec( Agenerators         := Fgens,
                Agenimages          := Agens,
                basisImage          := B,
                preimagesBasisImage := genimages ) ) );

    # We know left module generators of the f.p. algebra,
    # and we know the isomorphic nice free left module.
    # (Note that in general, `NiceAlgebraMonomorphism' is valid also for
    # subalgebras.)
    SetGeneratorsOfLeftModule( Fp, genimages );
    SetNiceFreeLeftModule( Fp, UnderlyingLeftModule( B ) );

    # Construct the isomorphism.
    map:= AlgebraWithOneHomomorphismByImagesNC( A, Fp, B, genimages );
    SetIsSurjective( map, true );
    SetIsInjective( map, true );

    # Return the isomorphism.
    return map;
    end );
#T special representation to improve computing preimages?
#T (the element in the nice module is first computed, then decomposed
#T and composed again; one can avoid the last two steps)


#############################################################################
##
#M  IsomorphismFpFLMLOR( <A> )  . . . . . . . . . . . . . . . for f.p. FLMLOR
##
##  Return the identity mapping.
##
InstallMethod( IsomorphismFpFLMLOR,
    "for f.p. FLMLOR (return the identity mapping)",
    [ IsSubalgebraFpAlgebra ], SUM_FLAGS,
    IdentityMapping );


#############################################################################
##
#M  IsomorphismSCFLMLOR( <A> )  . . . . . . . . . . . . . . . .  for a FLMLOR
##
InstallMethod( IsomorphismSCFLMLOR,
    "for a finite dimensional FLMLOR (delegate to the method for a basis)",
    [ IsFLMLOR ],
    A -> IsomorphismSCFLMLOR( Basis( A ) ) );


#############################################################################
##
#M  IsomorphismSCFLMLOR( <B> )  . . . . . . . . . . . for a basis of a FLMLOR
##
InstallMethod( IsomorphismSCFLMLOR,
    "for a basis (of a finite dimensional FLMLOR)",
    [ IsBasis ],
    function( B )

    local A,               # underlying FLMLOR of `B'
          T,               # structure constants table w.r.t. `B'
          I,               # s.c. FLMLOR, image of the isomorphism
          map;             # isomorphism from `A' to `I', result

    A:= UnderlyingLeftModule( B );
    if not IsFLMLOR( A ) then
      Error( "<A> must be a FLMLOR" );
    fi;

    # Construct the image.
    T:= StructureConstantsTable( B );
    I:= AlgebraByStructureConstants( LeftActingDomain( A ), T );
    UseIsomorphismRelation( A, I );

    # Construct the isomorphism.
    map:= LeftModuleHomomorphismByImagesNC( A, I, B, CanonicalBasis( I ) );
    SetIsBijective( map, true );
    SetIsAlgebraHomomorphism( map, true );
    if IsFLMLORWithOne( A ) then
      SetRespectsOne( map, true );
    fi;

    # Return the result.
    return map;
    end );


#############################################################################
##
#M  IsomorphismSCFLMLOR( <A> )  . . . . . . . . . . . . . . . for s.c. FLMLOR
##
##  Return the identity mapping.
##
InstallMethod( IsomorphismSCFLMLOR,
    "for s.c. FLMLOR (return the identity mapping)",
    [ IsFLMLOR and IsSCAlgebraObjCollection ], SUM_FLAGS,
    IdentityMapping );
