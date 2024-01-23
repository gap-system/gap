#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick, Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#F  DirectProduct( <arg> )
##
InstallGlobalFunction( DirectProduct, function( arg )
local d, prop;
  if Length( arg ) = 0 then
    Error( "<arg> must be nonempty" );
  elif Length( arg ) = 1 and IsList( arg[1] ) then
    if IsEmpty( arg[1] ) then
      Error( "<arg>[1] must be nonempty" );
    fi;
    arg:= arg[1];
  fi;
  d:=DirectProductOp( arg, arg[1] );

  # test/set a few properties and attributes from factors

  for prop in [IsFinite, IsNilpotentGroup, IsAbelian, IsSolvableGroup, IsBand,
               IsInverseSemigroup, IsRegularSemigroup, IsIdempotentGenerated,
               IsLeftZeroSemigroup, IsRightZeroSemigroup, IsZeroSemigroup] do
    if ForAny(arg, x -> Tester(prop)(x) and not prop(x)) then
      Setter(prop)(d, false);
    elif ForAll(arg, x -> Tester(prop)(x) and prop(x)) then
      Setter(prop)(d, true);
    fi;
  od;

  if ForAll(arg,HasSize) then
    if   ForAll(arg,IsFinite)
    then SetSize(d,Product(List(arg,Size)));
    else SetSize(d,infinity); fi;
  fi;
  return d;
end );


#############################################################################
##
#M  DirectProductOp( <list>, <G> )
##
InstallMethod( DirectProductOp,
    "for a list (of groups), and a group",
    [ IsList, IsGroup ],
    function( list, gp )

    local ids, tup, first, i, G, gens, g, new, D;

    # Check the arguments.
    if IsEmpty( list ) then
      Error( "<list> must be nonempty" );
    elif ForAny( list, G -> not IsGroup( G ) ) then
      TryNextMethod();
    fi;

    ids := List( list, One );
    tup := [];
    first := [1];
    for i in [1..Length( list )] do
        G    := list[i];
        gens := GeneratorsOfGroup( G );
        for g in gens do
            new := ShallowCopy( ids );
            new[i] := g;
            new := DirectProductElement( new );
            Add( tup, new );
        od;
        Add( first, Length( tup )+1 );
    od;

    D := GroupByGenerators( tup, DirectProductElement( ids ) );

    SetDirectProductInfo( D, rec( groups := list,
                                  first  := first,
                                  embeddings := [],
                                  projections := [] ) );

    if ForAll( list, CanEasilyComputeWithIndependentGensAbelianGroup ) then
      SetFilterObj( D, CanEasilyComputeWithIndependentGensAbelianGroup );
    fi;

    return D;
    end );


#############################################################################
##
#M  \in( <dpelm>, <G> )
##
InstallMethod( \in,"generic direct product", IsElmsColls,
    [ IsDirectProductElement, IsGroup and HasDirectProductInfo ],
function( g, G )
    local n, info;
    n := Length( g );
    info := DirectProductInfo( G );
    return ForAll( [1..n], x -> g[x] in info.groups[x] );
end );


#############################################################################
##
#A Embedding
##
InstallMethod( Embedding, "group direct product and integer",
    [ IsGroup and HasDirectProductInfo, IsPosInt ],
    function( D, i )
    local info, G, imgs, hom, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.embeddings[i] ) then
        return info.embeddings[i];
    fi;

    info.onelist:=List(info.groups,One);
    # compute embedding
    G := info.groups[i];
    gens := GeneratorsOfGroup( G );
    imgs := GeneratorsOfGroup( D ){[info.first[i] .. info.first[i+1]-1]};
    if Length(imgs)>0 and IsDirectProductElement(imgs[1]) then
      # the direct product is represented by direct product elements.
      # The easiest way to compute the embedding is to construct
      # direct product elements.
      hom:=GroupHomomorphismByFunction(G,D,function(elm)
               local l;
               l:=ShallowCopy(info.onelist);
               l[i]:=elm;
               return DirectProductElement(l);
             end);
    else
      hom  := GroupHomomorphismByImagesNC( G, D, gens, imgs );
    fi;
    SetIsInjective( hom, true );

    # store information
    info.embeddings[i] := hom;
    return hom;
end );

#############################################################################
##
#A  Projection
##
InstallMethod( Projection, "group direct product and integer",
    [ IsGroup and HasDirectProductInfo, IsPosInt ],
    function( D, i )
    local info, G, imgs, hom, N, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.projections[i] ) then
        return info.projections[i];
    fi;

    # compute projection
    G    := info.groups[i];
    gens := GeneratorsOfGroup( D );
    imgs := Concatenation(
               List( [1..info.first[i]-1], x -> One( G ) ),
               GeneratorsOfGroup( G ),
               List( [info.first[i+1]..Length(gens)], x -> One(G)));
    if Length(gens)>0 and IsDirectProductElement(gens[1]) then
      # The direct product is represented by direct product elements.
      # The easiest way to compute the projection is to take elements apart.
      hom:=GroupHomomorphismByFunction( D, G, elm -> elm[i] );
    else
      hom := GroupHomomorphismByImagesNC( D, G, gens, imgs );
    fi;
    N := SubgroupNC( D, gens{Concatenation( [1..info.first[i]-1],
                           [info.first[i+1]..Length(gens)])});
    SetIsSurjective( hom, true );
    SetKernelOfMultiplicativeGeneralMapping( hom, N );

    # store information
    info.projections[i] := hom;
    return hom;
end );

#############################################################################
##
#M  Size( <D> )
##
InstallMethod( Size, "group direct product",
  [IsGroup and HasDirectProductInfo],
function( D )
    return Product( List( DirectProductInfo( D ).groups, Size ) );
end );

#############################################################################
##
#M  IsSolvableGroup( <D> )
##
InstallMethod( IsSolvableGroup, "for direct products",
               [IsGroup and HasDirectProductInfo],
function( D )
    return ForAll( DirectProductInfo( D ).groups, IsSolvableGroup );
end );

#############################################################################
##
#M  IsNilpotentGroup( <D> )
##
InstallMethod( IsNilpotentGroup, "for direct products",
               [IsGroup and HasDirectProductInfo], 30,
function( D )
    return ForAll( DirectProductInfo( D ).groups, IsNilpotentGroup );
end );

#############################################################################
##
#M  IsAbelian( <D> )
##
InstallMethod( IsAbelian, "for direct products",
               [IsGroup and HasDirectProductInfo],
function( D )
    return ForAll( DirectProductInfo( D ).groups, IsAbelian );
end );

#############################################################################
##
#M  IsPGroup( <D> )
##
InstallMethod( IsPGroup, "for direct products",
               [IsGroup and HasDirectProductInfo],
function( D )
    local list, G, p;

    list := DirectProductInfo( D ).groups;

    if ForAll(list, IsPGroup) then
        p := fail;
        for G in list do
            if not IsTrivial (G) then
                if p = fail then
                    p := PrimePGroup (G);
                elif p <> PrimePGroup (G) then
                    p := false;
                    break;
                fi;
            fi;
        od;
        if p <> false then
            SetPrimePGroup (D, p);
            return true;
        fi;
    fi;
    return false;
end );


#############################################################################
##
#M  PrimePGroup( <D> )
##
InstallMethod( PrimePGroup, "for direct products",
               [IsPGroup and HasDirectProductInfo],
function( D )
    local groups, p, H;
    groups := DirectProductInfo(D).groups;
    Assert(1, ForAll(groups, IsPGroup));
    H := First(groups, G -> PrimePGroup(G) <> fail);
    if H = fail then
      SetIsTrivial(D, true);
      return fail;
    fi;
    p := PrimePGroup(H);
    Assert(1, ForAll(groups, G -> PrimePGroup(G) in [fail, p]));
    return p;
end );

#############################################################################
##
#F AbelianInvariants( <D > )
##
InstallMethod( AbelianInvariants, "for direct products",
               [IsGroup and HasDirectProductInfo],
function( D )
    local info, ai;
    info := DirectProductInfo( D );
    ai := Concatenation( List( info.groups, AbelianInvariants ) );
    Sort(ai);
    return ai;
end );

#############################################################################
##
#A  IndependentGeneratorsOfAbelianGroup( <D> )
##
InstallMethod( IndependentGeneratorsOfAbelianGroup, "for direct products",
               [IsGroup and HasDirectProductInfo and IsAbelian],
function(D)
    local info, ai, gens, i, phi;
    info := DirectProductInfo( D );
    ai := Concatenation( List( info.groups, AbelianInvariants ) );
    gens := [];
    for i in [ 1..Length(info.groups) ] do
        phi := Embedding( D, i );
        Append( gens, List( IndependentGeneratorsOfAbelianGroup( info.groups[i] ),
                                g -> ImageElm( phi, g ) ) );
    od;
    SortParallel(ai, gens);
    return gens;
end );

#############################################################################
##
#O  IndependentGeneratorExponents( <D>, <g> )
##
InstallMethod( IndependentGeneratorExponents, "for direct products",
               IsCollsElms,
               [IsGroup and HasDirectProductInfo and IsAbelian,
                IsMultiplicativeElementWithInverse and IsDirectProductElement],
function(D,g)
    local info, ai, exps, i, phi;
    info := DirectProductInfo( D );
    ai := Concatenation( List( info.groups, AbelianInvariants ) );
    exps := [];
    for i in [ 1..Length(info.groups) ] do
        phi := Projection( D, i );
        Append( exps, IndependentGeneratorExponents(info.groups[i], ImageElm( phi, g )) );
    od;
    SortParallel(ai, exps);
    return exps;
end);


#############################################################################
##
#R  IsPcgsDirectProductRep
##
DeclareRepresentation ("IsPcgsDirectProductRep", IsPcgsDefaultRep, ["pcgs","len"]);

#############################################################################
##
#M  Pcgs( <D> )
#M  PcgsElementaryAbelianSeries( <D> )
#M  PcgsCentralSeries( <D> )
##
InstallGlobalFunction (PcgsDirectProduct,
    function( D, pcgsop, indsop, filter )
        local info, pcs, i, pcgs, rels, indices, inds, offset, one, new, g, attl;
        if not IsDirectProductElement( One( D ) ) then TryNextMethod(); fi;
        info := DirectProductInfo( D );
        pcs := [];
        rels := [];
        pcgs := [];
        indices := [];
        one := List( info.groups, One );
        offset := 0;
        for i in [1..Length(info.groups)] do
            pcgs[i] := pcgsop ( info.groups[i] );
            if indsop <> fail then
                inds := indsop (pcgs[i]) + offset;
                Append (indices, inds{[1..Length(inds)-1]});
            fi;
            for g in pcgs[i] do
                new := ShallowCopy( one );
                new[i] := g;
                Add( pcs, DirectProductElement( new ) );
            od;
            Append( rels, RelativeOrders( pcgs[i] ) );
            offset := offset + Length (pcgs[i]);
        od;
        attl := [RelativeOrders, rels, GroupOfPcgs, D, One, One(D)];
        if indsop <> fail then
            Add (indices, offset + 1);
            Append (attl, [indsop, indices, filter, true]);
        fi;
        pcs := PcgsByPcSequenceCons(
            IsPcgsDefaultRep,
            IsPcgs and IsPcgsDirectProductRep,
            ElementsFamily(FamilyObj( D ) ),
            pcs,
            attl );
        pcs!.pcgs := pcgs;
        return pcs;
    end
);


InstallMethod( Pcgs, "for direct products", true,
               [IsGroup and HasDirectProductInfo],
               {} -> Maximum(
                RankFilter(IsPcGroup),
                RankFilter(IsPermGroup and IsSolvableGroup)
                ),# this is better than these two common alternatives
        D -> PcgsDirectProduct (D, Pcgs, fail, fail));

InstallMethod( PcgsElementaryAbelianSeries, "for direct products", true,
               [IsGroup and HasDirectProductInfo],
               {} -> Maximum(
                RankFilter(IsPcGroup),
                RankFilter(IsPermGroup and IsSolvableGroup)
                ),# this is better than these two common alternatives
        D -> PcgsDirectProduct (D,
                PcgsElementaryAbelianSeries,
                IndicesEANormalSteps,
                IsPcgsElementaryAbelianSeries)
);

InstallMethod( PcgsCentralSeries, "for direct products", true,
               [IsGroup and HasDirectProductInfo],
               {} -> Maximum(
                RankFilter(IsPcGroup),
                RankFilter(IsPermGroup and IsSolvableGroup)
                ),# this is better than these two common alternatives
        D -> PcgsDirectProduct (D,
                PcgsCentralSeries,
                IndicesCentralNormalSteps,
                IsPcgsCentralSeries)
);

InstallMethod( PcgsChiefSeries, "for direct products", true,
               [IsGroup and HasDirectProductInfo],
               {} -> Maximum(
                RankFilter(IsPcGroup),
                RankFilter(IsPermGroup and IsSolvableGroup)
                ),# this is better than these two common alternatives
        D -> PcgsDirectProduct (D, PcgsChiefSeries, IndicesChiefNormalSteps, IsPcgsChiefSeries)
);

InstallMethod( PcgsPCentralSeriesPGroup, "for direct products", true,
               [IsGroup and HasDirectProductInfo],
               {} -> Maximum(
                RankFilter(IsPcGroup),
                RankFilter(IsPermGroup and IsSolvableGroup)
                ),# this is better than these two common alternatives
        D -> PcgsDirectProduct (D,
                PcgsCentralSeries,
                IndicesPCentralNormalStepsPGroup,
                IsPcgsPCentralSeriesPGroup)
);

#############################################################################
##
#M  ExponentsOfPcElement( <pcgs>, <g> )
##
InstallMethod (ExponentsOfPcElement, "for pcgs of direct product", IsCollsElms,
    [IsPcgs and IsPcgsDirectProductRep, IsDirectProductElement], 0,

    function (pcgs, g)
        local exp, i;

        if Length (pcgs!.pcgs) <> Length (g) then
            TryNextMethod ();
        fi;
        exp := [];
        for i in [1..Length (g)] do
            Append (exp, ExponentsOfPcElement (pcgs!.pcgs[i], g[i]));
        od;
        return exp;
    end
);


#############################################################################
##
#M  DepthOfPcElement( <pcgs>, <g> )
##
InstallMethod (DepthOfPcElement, "for pcgs of direct product", IsCollsElms,
    [IsPcgs and IsPcgsDirectProductRep, IsDirectProductElement], 0,

    function (pcgs, g)
        local i, d, prevdepth;

        if Length (pcgs!.pcgs) <> Length (g) then
            TryNextMethod ();
        fi;
        prevdepth := 0;
        for i in [1..Length (g)] do
            d := DepthOfPcElement (pcgs!.pcgs[i], g[i]);
            if d <= Length (pcgs!.pcgs[i]) then
                return d + prevdepth;
            fi;
            prevdepth := prevdepth + Length (pcgs!.pcgs[i]);
        od;
        return prevdepth + 1;
    end
);


#############################################################################
##
## subdirect product stuff
##

InstallGlobalFunction(SubdirectProduct,function(G,H,ghom,hhom)
local iso;
  if Image(ghom,G)<>Image(hhom,H) then
    # are they isomorphic?
    iso:=IsomorphismGroups(Image(ghom,G),Image(hhom,H));
    if iso=fail then
      Error("the image groups are nonisomorphic");
    else
      Info(InfoWarning,1,
        "The image groups are inequal. Computed an isomorphism between them.");
      ghom:=ghom*iso;
    fi;
  fi;

  # the ...Op is installed for `IsGroupHomomorphism'. So we have to enforce
  # the filter to be set.
  if not IsGroupHomomorphism(ghom) or not IsGroupHomomorphism(hhom) then
    Error("mappings are not homomorphisms");
  fi;
  return SubdirectProductOp(G,H,ghom,hhom);
end);

#############################################################################
##
#M  SubdirectProduct( <G1>, <G2>, <phi1>, <phi2> )
##

RedispatchOnCondition(SubdirectProductOp, "check mappings", true,
        [IsGroup, IsGroup, IsGeneralMapping, IsGeneralMapping],
        [IsObject, IsObject, IsGroupHomomorphism, IsGroupHomomorphism],
        10);

InstallMethod( SubdirectProductOp,"groups", true,
  [ IsGroup, IsGroup, IsGroupHomomorphism, IsGroupHomomorphism ], 0,
function( G, H, gh, hh )
local gc,hc,S,info;
  # try to enforce a common representation
  if not (IsFinite(G) and IsFinite(H)) then
    TryNextMethod();
  fi;
  if IsSolvableGroup(G) and IsSolvableGroup(H) and
    not (IsPcGroup(G) and IsPcGroup(H)) then
    # enforce pc groups
    gc:=IsomorphismPcGroup(G);
    hc:=IsomorphismPcGroup(H);
  elif not (IsPermGroup(G) and IsPermGroup(H)) then
    # enforce perm groups
    gc:=IsomorphismPermGroup(G);
    hc:=IsomorphismPermGroup(H);
  else
    TryNextMethod();
  fi;
  gh:=InverseGeneralMapping(gc)*gh;
  hh:=InverseGeneralMapping(hc)*hh;
  # the ...Op is installed for `IsGroupHomomorphism'. So we have to enforce
  # the filter to be set.
  if not IsGroupHomomorphism(gh) or not IsGroupHomomorphism(hh) then
    Error("mappings are not homomorphisms");
  fi;
  S:=SubdirectProductOp(Image(gc,G),Image(hc,H),gh,hh);
  info:=rec(groups:=[G,H],
            homomorphisms:=[gh,hh],
            projections:=[Projection(S,1)*InverseGeneralMapping(gc),
                          Projection(S,2)*InverseGeneralMapping(hc)]);
  S:=Group(GeneratorsOfGroup(S),One(S));
  SetSubdirectProductInfo(S,info);
  return S;
end);

#############################################################################
##
#M  Projection( <S>, <i> )  . . . . . . . . . . . . . . . . . make projection
##
InstallMethod( Projection,"pc subdirect product", true,
      [ IsGroup and HasSubdirectProductInfo, IsPosInt ], 0,
function( S, i )
local info;
  if not i in [1,2] then
    Error("only 2 embeddings");
  fi;
  info := SubdirectProductInfo( S );
  if not IsBound(info.projections[i]) then
    TryNextMethod();
  fi;
  return info.projections[i];
end);

#############################################################################
##
#M  Size( <S> ) . . . . . . . . . . . . . . . . . . . .  of subdirect product
##
InstallMethod( Size,"subdirect product", true,
  [ IsGroup and HasSubdirectProductInfo ], 0,
    function( S )
    local info;
    info := SubdirectProductInfo( S );
    return Size( info.groups[ 1 ] ) * Size( info.groups[ 2 ] )
           / Size( ImagesSource( info.homomorphisms[ 1 ] ) );
end );



#
# functions for finding all SDP's
#

#############################################################################
##
#F InnerSubdirectProducts2( D, U, V ) . . . . . . . . . .up to conjugacy in D
##
InstallGlobalFunction(InnerSubdirectProducts2,function( D, U, V )
    local normsU, normsV, div, fac, Syl, NormU, orb, NormV, pairs, i, j,
          homU, homV, iso, subdir, gensU, gensV, N, UN, M, VM, Aut, gamma,
          P, NormUN, autU, n, alpha, NormVM, autV, reps, rep, gens, r, g, h,
          S, pair, imgs;

    # compute necessary normal subgroups in U and V
    if IsAbelian( U ) and IsAbelian( V ) then
        normsU := List( ConjugacyClassesSubgroups( U ), Representative );
        normsV := List( ConjugacyClassesSubgroups( V ), Representative );
    elif IsAbelian( U ) then
        normsU := List( ConjugacyClassesSubgroups( U ), Representative );
        normsV := NormalSubgroupsAbove( V, DerivedSubgroup(V),[]);
    elif IsAbelian( V ) then
        normsU := NormalSubgroupsAbove( U, DerivedSubgroup(U),[]);
        normsV := List( ConjugacyClassesSubgroups( V ), Representative );
    else
        div  := PrimeDivisors( Gcd( Size( U ), Size( V ) ) );

        # in U
        fac  := PrimeDivisors( Size( U ) );
        fac  := Filtered( fac, x -> not x in div );
        Syl  := List( fac, x -> GeneratorsOfGroup( SylowSubgroup( U, x ) ) );
        Syl  := Concatenation( Syl );
        Syl  := NormalClosure( U, Subgroup( U, Syl ) );
        normsU := NormalSubgroupsAbove( U, Syl, [] );

        # in V
        fac  := PrimeDivisors( Size( V ) );
        fac  := Filtered( fac, x -> not x in div );
        Syl  := List( fac, x -> GeneratorsOfGroup( SylowSubgroup( V, x ) ) );
        Syl  := Concatenation( Syl );
        Syl  := NormalClosure( V, Subgroup( V, Syl ) );
        normsV := NormalSubgroupsAbove( V, Syl, [] );
    fi;

    # compute orbits on normal subgroups in U
    NormU  := Normalizer( D, U );
    orb    := OrbitsDomain( NormU, normsU, OnPoints );
    normsU := List( orb, x -> x[1] );

    # compute orbits on normal subgroups in V
    NormV  := Normalizer( D, V );
    orb    := OrbitsDomain( NormV, normsV, OnPoints );
    normsV := List( orb, x -> x[1] );

    # find isomorphic pairs of factors
    pairs := [];
    for i in [1..Length(normsU)] do
        for j in [1..Length(normsV)] do
            if Index( U, normsU[i] ) = Index( V, normsV[j] ) then
                homU := NaturalHomomorphismByNormalSubgroup( U, normsU[i] );
                homV := NaturalHomomorphismByNormalSubgroup( V, normsV[j] );
                iso := IsomorphismGroups( Image( homU ), Image( homV ) );
                if not IsBool( iso ) then
                    Add( pairs, [ homU, homV, iso] );
                fi;
            fi;
        od;
    od;

    # loop over pairs
    subdir := [];
    gensU  := GeneratorsOfGroup( U );
    gensV  := GeneratorsOfGroup( V );
    for pair in pairs do

        N := KernelOfMultiplicativeGeneralMapping( pair[1] );
        UN := Image( pair[1] );
        M := KernelOfMultiplicativeGeneralMapping( pair[2] );
        VM := Image( pair[2] );
        iso := pair[3];

        # calculate Aut( U / N )
        Aut := AutomorphismGroup( UN );
        gamma := IsomorphismPermGroup( Aut );
        P := Image( gamma );

        # calculate induced autos in G
        NormUN := Normalizer( NormU, N );
        autU   := [];
        for n in GeneratorsOfGroup( NormUN ) do
            gens := List( gensU, x -> Image( pair[1], x ) );
            imgs := List( gensU, x -> Image( pair[1], x^n ) );
            if gens <> imgs then
                alpha := GroupHomomorphismByImagesNC( UN, UN, gens, imgs );
                SetFilterObj( alpha, IsMultiplicativeElementWithInverse );
                Add( autU, Image( gamma, alpha ) );
            fi;
        od;
        autU := SubgroupNC( P, autU );

        # calculate induced autos in H
        NormVM := Normalizer( NormV, M );
        autV   := [];
        for n in GeneratorsOfGroup( NormVM ) do
            gens := List( gensV, x -> Image( pair[2], x ) );
            imgs := List( gensV, x -> Image( pair[2], x^n ) );
            if gens <> imgs then
                alpha := GroupHomomorphismByImagesNC( VM, VM, gens, imgs );
                alpha := iso * alpha * InverseGeneralMapping( iso );
                SetFilterObj( alpha, IsMultiplicativeElementWithInverse );
                Add( autV, Image( gamma, alpha ) );
            fi;
        od;
        autV := SubgroupNC( P, autV );

        # and obtain double coset reps
        reps := List( DoubleCosets( P, autU, autV ), Representative );
        reps := List( reps, x -> PreImagesRepresentative( gamma, x ) );

        # loop over automorphisms
        for rep in reps do

            # compute corresponding group
            gens := Concatenation( GeneratorsOfGroup( N ),
                                   GeneratorsOfGroup( M ) );
            for r in GeneratorsOfGroup( UN ) do
                g := PreImagesRepresentative( pair[1], r );
                h := Image( iso, Image( rep, r ) );
                h := PreImagesRepresentative( pair[2], h );
                Add( gens, g * h );
            od;
            S := SubgroupNC( D, gens );
            SetSize( S, Size( N ) * Size( M ) * Size( UN ) );
            Add( subdir, S );
        od;
    od;

    # return
    return subdir;
end);

#############################################################################
##
#F InnerSubdirectProducts( D, list ) . . . . . . .iterated subdirect products
##
InstallGlobalFunction(InnerSubdirectProducts,function( P, list )
    local subdir, i, U, tmp, S, new;
    subdir := [list[1]];
    for i in [2..Length(list)] do
        U := list[i];
        tmp := [];
        for S in subdir do
            new := InnerSubdirectProducts2( P, S, U );
            Append( tmp, new );
        od;
        subdir := tmp;
    od;
    return subdir;
end);

#############################################################################
##
#F SubdirectProducts( S, T ) . . . . . . . . . . . up to conjugacy in parents
##
InstallGlobalFunction(SubdirectProducts,function( S, T )
    local G, H, D, emb1, emb2, U, V, subdir, info, i;

    # go over to direct product
    G := Parent( S );
    H := Parent( T );
    D := DirectProduct( G, H );

    # create embeddings
    emb1  := Embedding( D, 1 );
    emb2  := Embedding( D, 2 );

    # compute subdirect products
    U := Image( emb1, S );
    V := Image( emb2, T );

    subdir := InnerSubdirectProducts2( D, U, V );

    # create info
    info := rec( groups := [S, T],
                 projections := [Projection( D, 1 ), Projection( D, 2 )] );

    for i in [1..Length( subdir )] do
        SetSubdirectProductInfo( subdir[i], info );
    od;

    return subdir;
end);

#
# wreath products: generic code
#

InstallOtherMethod( WreathProduct,"generic groups, no perm", true,
 [ IsGroup, IsGroup ], 0,
function(G,H)
  if IsPermGroup(H) then TryNextMethod();fi;
  Error("WreathProduct requires permgroup or group and permrep");
end);

InstallMethod( WreathProduct,"generic groups with perm", true,
 [ IsGroup, IsPermGroup ], 0,
function(G,H)
  return WreathProduct(G,H,IdentityMapping(H));
end);

InstallMethod( StandardWreathProduct,"generic groups", true,
 [ IsGroup, IsGroup ], 0,
function(G,H)
local iso;
  iso:=ActionHomomorphism(H,AsSSortedList(H),OnRight,"surjective");
  return WreathProduct(G,H,iso);
end);

#############################################################################
##
#M  WreathProduct(<G>,<H>,<alpha>)
##
InstallOtherMethod( WreathProduct,"generic groups with permhom", true,
 [ IsGroup, IsGroup, IsSPGeneralMapping ], 0,
function(G,H,alpha)
local I,n,fam,typ,gens,hgens,id,i,e,info,W,p,dom;
  I:=Image(alpha,H);

  # avoid sparse first points.
  dom:=MovedPoints(I);
  if Length(dom)=0 then
    dom:=[1];
    n:=1;
  elif Maximum(dom)>Length(dom) then
    alpha:=alpha*ActionHomomorphism(I,dom);
    I:=Image(alpha,H);
    n:=LargestMovedPoint(I);
  else
    n:=LargestMovedPoint(I);
  fi;

  fam:=NewFamily("WreathProductElemFamily",IsWreathProductElement);
  typ:=NewType(fam,IsWreathProductElementDefaultRep);
  fam!.defaultType:=typ;
  info:=rec(groups:=[G,H],
            family:=fam,
            I:=I,
            degI:=n,
            alpha:=alpha,
            embeddings:=[]);
  fam!.info:=info;
  if CanEasilyCompareElements(One(G)) then
    SetCanEasilyCompareElements(fam,true);
  fi;
  if CanEasilySortElements(One(G)) then
    SetCanEasilySortElements(fam,true);
  fi;

  gens:=[];
  id:=ListWithIdenticalEntries(n,One(G));
  Add(id,One(I));
  info.identvec:=ShallowCopy(id);

  for p in List(Orbits(I,[1..n]),i->i[1]) do
    for i in GeneratorsOfGroup(G) do
      e:=ShallowCopy(id);
      e[p]:=i;
      Add(gens,Objectify(typ,e));
    od;
  od;

  info.basegens:=ShallowCopy(gens);
  hgens:=[];
  for i in GeneratorsOfGroup(H) do
    e:=ShallowCopy(id);
    e[n+1]:=Image(alpha,i);
    Add(hgens,Objectify(typ,e));
  od;
  Append(gens,hgens);
  info.hgens:=hgens;
  SetOne(fam,Objectify(typ,id));
  W:=Group(gens,One(fam));
  SetWreathProductInfo(W,info);
  SetIsWholeFamily(W,true);
  if HasSize(G) then
    if IsFinite(G) then
      SetSize(W,Size(G)^n*Size(I));
    else
      SetSize(W,infinity);
    fi;
  fi;
  if HasIsFinite(G) then
    SetIsFinite(W,IsFinite(G));
  fi;
  return W;

end);

#############################################################################
##
#M  ListWreathProductElement(<G>, <x>[, <testMembership>])
##
InstallGlobalFunction( ListWreathProductElement,
function(G, x, testDecomposition...)
  if Length(testDecomposition) = 0 then
    testDecomposition := true;
  elif Length(testDecomposition) = 1 then
    testDecomposition := testDecomposition[1];
  elif Length(testDecomposition) > 1 then
    ErrorNoReturn("too many arguments");
  fi;
  if not HasWreathProductInfo(G) then
    ErrorNoReturn("usage: <G> must be a wreath product");
  fi;
  return ListWreathProductElementNC(G, x, testDecomposition);
end);

InstallMethod( ListWreathProductElementNC, "generic wreath product", true,
 [ HasWreathProductInfo, IsWreathProductElement, IsBool ], 0,
function(G, x, testDecomposition)
  local info, list, i;
  info := WreathProductInfo(G);
  list := EmptyPlist(info!.degI + 1);
  for i in [1 .. info!.degI + 1] do
    list[i] := StructuralCopy(x![i]);
  od;
  return list;
end);

#############################################################################
##
#M  WreathProductElementList(<G>, <list>)
##
InstallGlobalFunction( WreathProductElementList,
function(G, list)
  local info, i;

  if not HasWreathProductInfo(G) then
    ErrorNoReturn("usage: <G> must be a wreath product");
  fi;
  info := WreathProductInfo(G);
  if Length(list) <> info.degI + 1 then
    ErrorNoReturn("usage: <list> must have ",
                  "length 1 + <WreathProductInfo(G).degI>");
  fi;
  for i in [1 .. info.degI] do
    if not list[i] in info.groups[1] then
      ErrorNoReturn("usage: <list{[1 .. Length(list) - 1]}> must contain ",
                    "elements of <WreathProductInfo(G).groups[1]>");
    fi;
  od;
  if not list[info.degI + 1] in info.groups[2] then
    ErrorNoReturn("usage: <list[Length(list)]> must be ",
                  "an element of <WreathProductInfo(G).groups[2]>");
  fi;
  return WreathProductElementListNC(G, list);
end);

InstallMethod( WreathProductElementListNC, "generic wreath product", true,
 [ HasWreathProductInfo, IsList ], 0,
function(G, list)
  return Objectify(FamilyObj(One(G))!.defaultType, StructuralCopy(list));
end);

#############################################################################
##
#M  PrintObj(<x>)
##
InstallMethod(PrintObj,"wreath elements",true,[IsWreathProductElement],0,
function(x)
local i,info;
  info:=FamilyObj(x)!.info;
  Print("WreathProductElement(");
  for i in [1..info!.degI] do
    Print(x![i],",");
  od;
  Print(x![info!.degI+1],")");
end);

#############################################################################
##
#M  OneOp(<x>)
##
InstallMethod(OneOp,"wreath elements",true,[IsWreathProductElement],0,
  x->One(FamilyObj(x)));

#############################################################################
##
#M  InverseOp(<x>)
##
InstallMethod(InverseOp,"wreath elements",true,
  [IsWreathProductElement],0,
function(x)
local l,p,i,info,fam;
  fam:=FamilyObj(x);
  info:=fam!.info;
  l:=[];
  p:=x![info!.degI+1]^-1;
  for i in [1..info!.degI] do
    l[i]:=x![i^p]^-1;
  od;
  l[info!.degI+1]:=p;
  return Objectify(fam!.defaultType,l);
end);

#############################################################################
##
#M  \*(<x>,<y>)
##
InstallMethod(\*,"wreath elements",IsIdenticalObj,
  [IsWreathProductElement,IsWreathProductElement],0,
function(x,y)
local l,p,i,j,info,fam;
  fam:=FamilyObj(x);
  info:=fam!.info;
  l:=[];
  p:=x![info!.degI+1];
  for i in [1..info!.degI] do
    j:=i^p;
    l[i]:=x![i]*y![j];
  od;
  i:=info!.degI+1;
  l[i]:=p*y![i];
  return Objectify(fam!.defaultType,l);
end);

#############################################################################
##
#M  \=(<x>,<y>)
##
InstallMethod(\=,"wreath elements",IsIdenticalObj,
  [IsWreathProductElement,IsWreathProductElement],0,
function(x,y)
local i,info;
  info:=FamilyObj(x)!.info;
  for i in [1..info!.degI+1] do
    if x![i]<>y![i] then
      return false;
    fi;
  od;
  return true;
end);

#############################################################################
##
#M  \<(<x>,<y>)
##
InstallMethod(\<,"wreath elements",IsIdenticalObj,
  [IsWreathProductElement,IsWreathProductElement],0,
function(x,y)
local i,info;
  info:=FamilyObj(x)!.info;
  for i in [1..info!.degI+1] do
    if x![i]>y![i] then
      return false;
    elif x![i]<y![i] then
      return true;
    fi;
  od;
  return false;
end);

#############################################################################
##
#M  Embedding( <W>, <i> )
##
InstallMethod( Embedding,"generic wreath product", true,
  [ IsGroup and HasWreathProductInfo and IsWreathProductElementCollection,
    IsPosInt ], 0,
function(G,n)
local info,map,U,mapfun,P;
  info:=WreathProductInfo(G);
  if n<1 or n-1>info.degI then
    Error("wrong index");
  else
    if not IsBound(info.embeddings[n]) then
      mapfun:=function(elm)
              local a;
                a:=ShallowCopy(info.identvec);
                if n>info.degI then
                  elm:=Image(info.alpha,elm);
                fi;
                a[n]:=elm;
                return Objectify(info.family!.defaultType,a);
              end;
      if n<=info.degI then
        P:=info.groups[1];
        U:=SubgroupNC(G,List(GeneratorsOfGroup(P),mapfun));
      else
        P:=info.groups[2];
        U:=SubgroupNC(G,info.hgens);
      fi;
      map:=GroupHomomorphismByFunction(P,U,mapfun,
        function(elm)
          elm:=elm![n];
          if n>info.degI then
            elm:=PreImagesRepresentative(info.alpha,elm);
          fi;
          return elm;
        end);
      info.embeddings[n]:=map;
    fi;
    return info.embeddings[n];
  fi;
end);

#############################################################################
##
#M  Projection( <W> )
##
InstallOtherMethod( Projection,"generic wreath product", true,
  [ IsGroup and HasWreathProductInfo and IsWreathProductElementCollection],0,
function(G)
local info,map,np;
  info:=WreathProductInfo(G);
  if not IsBound(info.projection) then
    np:=info.degI+1;

    map:=GroupHomomorphismByFunction(G,info.groups[2],
      function(elm)
        return PreImagesRepresentative(info.alpha,elm![np]);
      end,
      false, # not bijective
      function(elm)
            local a;
              a:=ShallowCopy(info.identvec);
              elm:=Image(info.alpha,elm);
              a[np]:=elm;
              return Objectify(info.family!.defaultType,a);
            end);
    info.projection:=map;
  fi;
  return info.projection;
end);

#############################################################################
##
#M  \in(<G>,<elm>
##
InstallMethod( \in,"generic wreath product", IsCollsElms,
  [ IsGroup and HasWreathProductInfo and IsWreathProductElementCollection
    and IsWholeFamily, IsWreathProductElement ], 0, ReturnTrue);

#
# semidirect product
#

##############################################################################
##
#M  SemidirectProduct
##
InstallOtherMethod( SemidirectProduct, "automorphisms group with group", true,
  [ IsGroup, IsObject ], 0,
function( G, N )
  return SemidirectProduct(G,IdentityMapping(G),N);
end);

InstallMethod( SemidirectProduct,"different representations",true,
    [ IsGroup, IsGroupHomomorphism, IsGroup and IsFinite],
    # don't be higher than specific perm/pc methods
    {} -> RankFilter(IsGroup) - RankFilter(IsGroup and IsFinite),
function( G, aut, N )
local giso,niso,P,gens,a,Go,No,i;
  # We will compute a faithful perm. or pc representation,
  # but we cannot assume that the finiteness of 'G' is known in advance.
  if not IsFinite( G ) then
    TryNextMethod();
  fi;
  Go:=G;
  No:=N;
  if IsSolvableGroup(N) and IsSolvableGroup(G) then
    giso:=IsomorphismPcGroup(G);
    niso:=IsomorphismPcGroup(N);
  else
    giso:=IsomorphismPermGroup(G);
    niso:=IsomorphismPermGroup(N);
  fi;
  G:=Image(giso,G);
  N:=Image(niso,N);
  gens:=[];
  for i in GeneratorsOfGroup(G) do
    i:=Image(aut,PreImagesRepresentative(giso,i));
    i:=InducedAutomorphism(niso,i);
    Add(gens,i);
  od;
  a:=Group(gens,IdentityMapping(N));
  if IsFinite(N) then
    SetIsGroupOfAutomorphismsFiniteGroup(a,true);
  else
    SetIsGroupOfAutomorphisms(a,true);
  fi;
  a:=GroupHomomorphismByImagesNC(G,a,GeneratorsOfGroup(G),gens);
  P:=SemidirectProduct(G,a,N);
  # trick the embeddings and projections (dirty tricks)
  i:=rec(groups:=[Go,No],
         embeddings:=[giso*Embedding(P,1),niso*Embedding(P,2)],
         projections:=Projection(P)*InverseGeneralMapping(giso));
  P:=Group(GeneratorsOfGroup(P),One(P));
  SetSemidirectProductInfo(P,i);
  return P;
end );

# semidirect product as finitely presented

BindGlobal( "SemidirectFp", function( G, aut, N )
local Go,No,giso,niso,FG,GP,FN,NP,F,GI,NI,rels,i,j,P;
  Go:=G;
  No:=N;
  if not IsFpGroup(G) then
    giso:=IsomorphismFpGroup(G);
  else
    giso:=IdentityMapping(G);
  fi;
  if not IsFpGroup(N) then
    niso:=IsomorphismFpGroup(N);
  else
    niso:=IdentityMapping(N);
  fi;
  G:=Image(giso,G);
  N:=Image(niso,N);

  FG:=FreeGeneratorsOfFpGroup(G);
  GP:=List(GeneratorsOfGroup(G),x->PreImagesRepresentative(giso,x));
  FN:=FreeGeneratorsOfFpGroup(N);
  NP:=List(GeneratorsOfGroup(N),x->PreImagesRepresentative(niso,x));

  F:=FreeGroup(List(Concatenation(FG,FN),String));
  GI:=GeneratorsOfGroup(F){[1..Length(FG)]};
  NI:=GeneratorsOfGroup(F){[Length(FG)+1..Length(GeneratorsOfGroup(F))]};

  rels:=[];
  for i in RelatorsOfFpGroup(G) do
    Add(rels,MappedWord(i,FG,GI));
  od;
  for i in RelatorsOfFpGroup(N) do
    Add(rels,MappedWord(i,FN,NI));
  od;
  for i in [1..Length(FG)] do
    for j in [1..Length(FN)] do
      Add(rels,NI[j]^GI[i]/(
        MappedWord(UnderlyingElement(Image(niso,Image(Image(aut,GP[i]),NP[j]))),FN,NI)  ));
    od;
  od;
  P:=F/rels;
  GI:=GeneratorsOfGroup(P){[1..Length(FG)]};
  NI:=GeneratorsOfGroup(P){[Length(FG)+1..Length(GeneratorsOfGroup(P))]};
  # set the embeddings and projections
  i:=rec(groups:=[Go,No],
         embeddings:=[GroupHomomorphismByImagesNC(Go,P,GP,GI),
                      GroupHomomorphismByImagesNC(No,P,NP,NI)],
         projections:=GroupHomomorphismByImagesNC(P,Go,
                        Concatenation(GI,NI),
                        Concatenation(GP,List(NI,x->One(Go))))  );
  SetSemidirectProductInfo(P,i);
  return P;
end );

InstallMethod( SemidirectProduct,"fp with group",true,
    [ IsSubgroupFpGroup, IsGroupHomomorphism, IsGroup ], 0, SemidirectFp);

InstallMethod( SemidirectProduct,"group with fp",true,
    [ IsGroup, IsGroupHomomorphism, IsSubgroupFpGroup ], 0, SemidirectFp);


#############################################################################
##
#A Embedding/Projection
##
InstallMethod( Embedding,"of semidirect product and integer",true,
    [ IsGroup and HasSemidirectProductInfo, IsPosInt ], 0,
function( P, i )
local info;

  info := SemidirectProductInfo( P );
  if IsBound( info.embeddings[i] ) then
    return info.embeddings[i];
  else
    TryNextMethod();
  fi;
end);

InstallOtherMethod( Projection,"of semidirect product", true,
    [ IsGroup and HasSemidirectProductInfo ], 0,
function( P )
local info;
  info := SemidirectProductInfo( P );
  if not IsBool( info.projections ) then
    return info.projections;
  else
    TryNextMethod();
  fi;
end);

##############################################################################
##
#M  SemidirectProduct: with vector space
##
InstallOtherMethod( SemidirectProduct, "group with vector space: affine", true,
  [ IsGroup, IsGroupHomomorphism, IsFullRowModule and IsVectorSpace ], 0,
function( G, map, V )
local pm,F,d,b,s,t,pos,i,j,img,m,P,info,Go,bnt,N,pcgs,auts,mapi,ag,phi,imgs;
  # construction assumes faithful action. AH
  if Size(KernelOfMultiplicativeGeneralMapping(map))<>1 then
    # not faithful -- cannot simply build as matrices
    N:=ElementaryAbelianGroup(Size(V));
    pcgs:=Pcgs(N);
    auts:=[];
    mapi:=MappingGeneratorsImages(map);
    for i in mapi[2] do
      imgs:=List(i,x->PcElementByExponents(pcgs,x));
      Add(auts,GroupHomomorphismByImagesNC(N,N,pcgs,imgs));
    od;
    ag:=Group(auts,IdentityMapping(N));
    SetIsGroupOfAutomorphismsFiniteGroup(ag,true);
    phi:=GroupHomomorphismByImages(G,ag,mapi[1],auts);
    s:=SemidirectProduct(G,phi,N);
    return s;
  fi;
  G:=Image(map,G);
  F:=LeftActingDomain(V);
  d:=DimensionOfVectors(V);
  # if G is a permgroup, take permutation matrices
  Go:=G;
  if IsPermGroup(G) then
    m:=List(GeneratorsOfGroup(G),i->PermutationMat(i,d,F));
    s:=Group(m);
    pm:=GroupHomomorphismByImagesNC(G,s,GeneratorsOfGroup(G),m);
    map:=map*pm;
    G:=s;
  fi;

  if not IsMatrixGroup(G) or d<>DimensionOfMatrixGroup(G) or not
    IsSubset(F,FieldOfMatrixGroup(G)) then
    Error("the matrices do not fit with the field");
  fi;
  b:=BasisVectors(Basis(V));
  # spin up a basis
  s:=[];
  pos:=1;
  t:=[];
  while Length(s)<Length(b) do
    # skip basis vectors that give nothing new
    while Length(s)>0 and RankMat(s)=RankMat(Concatenation(s,[b[pos]])) do
      pos:=pos+1;
    od;
    Add(s,b[pos]);
    Add(t,b[pos]); # those vectors need own affine matrices
    # spin the new vector
    i:=Length(s);
    while i<=Length(s) and Length(s)<Length(b) do
      for j in GeneratorsOfGroup(G) do
        img:=s[i]*j;
        if RankMat(s)<RankMat(Concatenation(s,[img])) then
          # new dimension
          Add(s,img);
        fi;
      od;
      i:=i+1;
    od;
  od;

  # do we need to take extra vectors to extend the field?
  if FieldOfMatrixGroup(G)<>F then
    b:=BasisVectors(Basis(Field(FieldOfMatrixGroup(G),GeneratorsOfField(F))));
    s:=[];
    for i in t do
      for j in b do
        Add(s,i*j);
      od;
    od;
    t:=s;
  fi;

  m:=[];
  # build affine matrices from group generators
  for i in GeneratorsOfGroup(G) do
    b:=IdentityMat(d+1,F);
    b{[1..d]}{[1..d]}:=i;
    Add(m,ImmutableMatrix(F,b));
  od;
  # and from basis vectors
  bnt:=[];
  for i in t do
    b:=IdentityMat(d+1,F);
    b[d+1]{[1..d]}:=i;
    b:=ImmutableMatrix(F,b);
    Add(m,b);
    Add(bnt,b);
  od;

  P:=Group(m,One(m[1]));
  SetSize(P,Size(G)*Size(V));
  info:=rec(group:=Go,
            vectorspace:=V,
            normalsub:=bnt,
            lenlist:=[0,Length(GeneratorsOfGroup(G))],
            embeddings:=[],
            field:=F,
            dimension:=d,
            projections:=true);
  SetSemidirectProductInfo( P, info );

  return P;
end);

##############################################################################
##
#M  Embedding
##
InstallMethod( Embedding, "vectorspace semidirect products",
    true, [ IsGroup and HasSemidirectProductInfo, IsPosInt ], 0,
function( S, i )
    local  info, G, genG, imgs, hom,j,k,m,n,d,v,w;

    info := SemidirectProductInfo( S );
    if not IsBound(info.vectorspace) then
      # it's not a vectorspace product
      TryNextMethod();
    fi;

    if IsBound( info.embeddings[i] ) then
      return info.embeddings[i];
    fi;
    if i=1 then
      G := info.group;
      genG := GeneratorsOfGroup( G );
      imgs := GeneratorsOfGroup( S ){[info.lenlist[i]+1 .. info.lenlist[i+1]]};
      hom := GroupHomomorphismByImages( G, S, genG, imgs );
    elif i=2 then
      d:=info.dimension;

      # image of vectorspace
      n:=[];
      v:=BasisVectors(Basis(info.vectorspace));
      w:=[];
      for j in BasisVectors(Basis(info.field)) do
        for k in v do
          Add(w,j*k);
        od;
      od;

      for j in w do
        m:=IdentityMat(d+1,info.field);
        m[d+1]{[1..d]}:=j;
        Add(n,ImmutableMatrix(info.field,m));
      od;
      n:=SubgroupNC(S,n);
      hom:=MappingByFunction(info.vectorspace,n,function(v)
        local m;
        m:=IdentityMat(d+1,info.field);
        m[d+1]{[1..d]}:=v;
        return ImmutableMatrix(info.field,m);
      end,
      function(a)
        if not a in n then
          Error("not in image");
        fi;
        return a[d+1]{[1..d]};
      end);
      SetImagesSource(hom,n);
    else
      Error("wrong index");
    fi;

    SetIsInjective( hom, true );
    info.embeddings[i] := hom;
    return hom;
end );

#############################################################################
##
#F  FreeProduct( arg )                                       Robert F, Morse
##
##
InstallGlobalFunction( FreeProduct,
function( arg )

    ## Check to see that the proper argument number is given
    ##
    if Length( arg ) = 0 then
        Error( "<arg> must be nonempty" );
    elif Length( arg ) = 1 and IsList( arg[1] ) then
        if IsEmpty( arg[1] ) then
            Error( "<arg>[1] must be nonempty" );
        fi;
        arg:= arg[1];
    fi;

    ## Delegate the construction to FreeProductOp
    ##
    return FreeProductOp(arg,arg[1]);

    end
);

############################################################################
##
#O  FreeProductOp( list, group )                            Robert F. Morse
##
InstallMethod( FreeProductOp,
    "for a list (of groups), and a group",
    true,
    [ IsList, IsGroup ], 0,
    function( list, gp )

    local fpisolist,    # list of isomorphism from each group to an fp group
          genindlist,   # Ranges into the free generators of the free
                        # product
          gennum,       # total number of free generators
          gens,         # slice of generators of the free group of the free
                        # product associated with a base group
          fpgens,       # fp generators of a base group
          r,            # relations index
          g,            # particular base group either as given or its fp
                        # representation
          ggens,        # generators of base group g
          i,            # index of generator range
          embeddings,   # monomorphisms of base groups into free product
          hom,          # holds a monomorphism
          F,            # free group of free product
          FP,           # free product
          rels, # free product relators
          nam   # names
    ;

    ## Check the arguments.
    ##
    if IsEmpty( list ) then
        Error( "<list> must be nonempty" );
    elif ForAny( list, G -> not IsGroup( G ) ) then
       TryNextMethod();
    fi;

    ## Create isomorphisms from the given group list to an
    ## isomorphic finitely presented group.
    ##
    fpisolist   := List(list,IsomorphismFpGroup);

    ## Create a list if indices for the generators of the free product
    ##
    genindlist  := List(fpisolist, x->Length(GeneratorsOfGroup(Image(x))));
    gennum      := Sum(genindlist);

    ## Compute the accummalive sums which are the indices into
    ## the free group. Add a zero for convenience.
    ##
    genindlist  := List([1..Length(genindlist)],i->genindlist{[1..i]});
    genindlist  := List(genindlist, Sum);
    genindlist  := Concatenation([0], genindlist);


    ## Create the free group of the free product
    ##
    nam:=List(Concatenation(List(fpisolist,x->GeneratorsOfGroup(Range(x)))),
           String);
    if Length(Set(nam))=gennum then
      F:=FreeGroup(nam);
    else
      F := FreeGroup(gennum);
    fi;

    ## Create the relations for the for free product
    ##
    rels := [];

    ## for each range of generators in the free group of the free product
    ## create the relations of the for ith base group.
    ##
    for i in [1..Length(genindlist)-1] do

         ## get the generator range for this group in the free group
         ## of the free product
         gens := List([genindlist[i]+1..genindlist[i+1]],x->F.(x));

         ## Fp representation of a base group of the free product
         ## and its free generators
         g    := Image(fpisolist[i]);
         fpgens := GeneratorsOfGroup(FreeGroupOfFpGroup(g));

         ## Map the relations of the base group into words in the
         ## free group of the free product
         for r in RelatorsOfFpGroup(g) do
             Add(rels, MappedWord(r, fpgens, gens));
         od;
    od;

    ## Create the free product.
    FP := F/rels;

    ## Create all the embeddings into the free product since we have
    ## all the needed information
    ##
    embeddings :=[];

    for i in [1..Length(genindlist)-1] do

         ## get the generator range for this group in the free product
         gens := List([genindlist[i]+1..genindlist[i+1]],x->FP.(x));

         ## get the ith base group as given and the generators in
         ## g of the FP image -- which may not be the same as
         ## the generators of g
         g    := list[i];
         ggens := List(GeneratorsOfGroup(Image(fpisolist[i])),
                      x->PreImage(fpisolist[i],x));

         hom := GroupHomomorphismByImagesNC(g,FP,ggens,gens);
         SetIsInjective(hom,true);

         Add(embeddings,hom);

    od;

    ## Save the embedding information for possible use later.
    SetFreeProductInfo( FP,
        rec( groups := list,
             embeddings := embeddings ) );

    return FP;

    end
);

#############################################################################
##
#M  Embedding (for free product)                             Robert F. Morse
##
InstallMethod( Embedding, "free products",
    true, [ IsGroup and HasFreeProductInfo, IsPosInt ], 0,
    function( G, i )
        if i > Length(FreeProductInfo(G).embeddings) then
            Error("Base group with index ",i, " does not exist");
        else
            return FreeProductInfo(G).embeddings[i];
        fi;
    end
);
