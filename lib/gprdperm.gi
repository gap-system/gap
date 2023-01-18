#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#F  DirectProductOfPermGroupsWithMovedPoints( <grps>, <pnts> )
##
BindGlobal("DirectProductOfPermGroupsWithMovedPoints",
    function( grps, pnts )
    local   i,  oldgrps,  olds,  news,  perms,  gens,
            deg,  grp,  old,  new,  perm,  gen,  D, info;

    oldgrps := [  ];
    olds    := [  ];
    news    := [  ];
    perms   := [  ];
    gens    := [  ];
    deg     := 0;

    # loop over the groups
    for i in [1..Length(grps)] do

        # find old domain, new domain, and conjugating permutation
        grp  := grps[i];
        old  := Immutable(pnts[i]);
        new  := MakeImmutable([deg+1..deg+Length(old)]);
        perm := MappingPermListList( old, new );
        deg  := deg + Length(old);
        Add( oldgrps, grp );
        Add( olds, old );
        Add( news, new );
        Add( perms, perm );

        # map all the generators of <grp>
        for gen  in GeneratorsOfGroup( grp )  do
            Add( gens, gen ^ perm );
        od;

    od;
    D:= GroupWithGenerators( gens, One( grps[1] ) );
    info := rec( groups := oldgrps,
                 olds   := olds,
                 news   := news,
                 perms  := perms,
                 embeddings := [],
                 projections := [] );

    SetDirectProductInfo( D, info );
    return D;
    end );


#############################################################################
##
#M  DirectProductOp( <grps>, <G> )  . . . . . . direct product of perm groups
##
InstallMethod( DirectProductOp,
    "for a list of permutation groups, and a permutation group",
    IsCollsElms,
    [ IsList and IsPermCollColl, IsPermGroup ], 0,
    function( grps, G )

    # Check the arguments.
    if not ForAll( grps, IsGroup ) then
      TryNextMethod();
    fi;

    return DirectProductOfPermGroupsWithMovedPoints(grps, List(grps, MovedPoints));
    end );


#############################################################################
##
#M  Size( <D> ) . . . . . . . . . . . . . . . . . . . . . . of direct product
##
InstallMethod( Size,
    "for a permutation group that knows to be a direct product",
    true,
    [ IsPermGroup and HasDirectProductInfo ], 0,
    D -> Product( List( DirectProductInfo( D ).groups, Size ) ) );


#############################################################################
##
#R  IsEmbeddingDirectProductPermGroup( <hom> )  .  embedding of direct factor
##
DeclareRepresentation( "IsEmbeddingDirectProductPermGroup",
      IsAttributeStoringRep and
      IsGroupHomomorphism and IsInjective and
      IsSPGeneralMapping, [ "component" ] );

#############################################################################
##
#R  IsEmbeddingWreathProductPermGroup( <hom> )  .  embedding of wreath factor
##
DeclareRepresentation( "IsEmbeddingWreathProductPermGroup",
      IsAttributeStoringRep and
      IsGroupHomomorphism and IsInjective and
      IsSPGeneralMapping, [ "component" ] );

#############################################################################
##
#R  IsEmbeddingImprimitiveWreathProductPermGroup( <hom> )
##
##  special for case of imprimitive wreath product
DeclareRepresentation( "IsEmbeddingImprimitiveWreathProductPermGroup",
      IsEmbeddingWreathProductPermGroup, [ "component" ] );

#############################################################################
##
#R  IsEmbeddingProductActionWreathProductPermGroup( <hom> )
##
##  special for case of product action wreath product
DeclareRepresentation(
  "IsEmbeddingProductActionWreathProductPermGroup",
    IsEmbeddingWreathProductPermGroup
    and IsGroupGeneralMappingByAsGroupGeneralMappingByImages,["component"]);

#############################################################################
##
#M  Embedding( <D>, <i> ) . . . . . . . . . . . . . . . . . .  make embedding
##
InstallMethod( Embedding,"perm direct product", true,
      [ IsPermGroup and HasDirectProductInfo,
        IsPosInt ], 0,
    function( D, i )
    local   emb, info;
    info := DirectProductInfo( D );
    if IsBound( info.embeddings[i] ) then return info.embeddings[i]; fi;

    emb := Objectify( NewType( GeneralMappingsFamily( PermutationsFamily,
                                                      PermutationsFamily ),
                   IsEmbeddingDirectProductPermGroup ),
                   rec( component := i ) );
    SetRange( emb, D );

    info.embeddings[i] := emb;

    return emb;
end );

#############################################################################
##
#M  Source( <emb> ) . . . . . . . . . . . . . . . . . . . . . .  of embedding
##
InstallMethod( Source,"perm direct product embedding", true,
  [ IsEmbeddingDirectProductPermGroup ], 0,
    emb -> DirectProductInfo( Range( emb ) ).groups[ emb!.component ] );

#############################################################################
##
#M  ImagesRepresentative( <emb>, <g> )  . . . . . . . . . . . .  of embedding
##
InstallMethod( ImagesRepresentative,"perm direct product embedding",
  FamSourceEqFamElm, [ IsEmbeddingDirectProductPermGroup,
                       IsMultiplicativeElementWithInverse ], 0,
    function( emb, g )
    return g ^ DirectProductInfo( Range( emb ) ).perms[ emb!.component ];
end );

#############################################################################
##
#M  PreImagesRepresentative( <emb>, <g> ) . . . . . . . . . . .  of embedding
##
InstallMethod( PreImagesRepresentative, "perm direct product embedding",
  FamRangeEqFamElm,
        [ IsEmbeddingDirectProductPermGroup,
          IsMultiplicativeElementWithInverse ],
    function( emb, g )
    local info;
    info := DirectProductInfo( Range( emb ) );
#T Make this more efficient:
#T Creating the restricted permutation could be avoided
#T if there would be an efficient (kernel) function that tests whether
#T a permutation moves points outside a given set.
#T Inverting the mapping permutation in each call could be avoided
#T by storing also the inverse, and the conjugation could be improved.
    if g = RestrictedPermNC( g, info.news[ emb!.component ] ) then
      return g ^ (info.perms[ emb!.component ] ^ -1);
    else
      return fail;
    fi;
end );

#############################################################################
##
#M  ImagesSource( <emb> ) . . . . . . . . . . . . . . . . . . .  of embedding
##
InstallMethod( ImagesSource,"perm direct product embedding", true,
 [ IsEmbeddingDirectProductPermGroup ], 0,
    function( emb )
    local   D,  I, info;

    D := Range( emb );
    info := DirectProductInfo( D );
    I := SubgroupNC( D, OnTuples
                 ( GeneratorsOfGroup( info.groups[ emb!.component ] ),
                   info.perms[ emb!.component ] ) );
    SetIsNormalInParent( I, true );
    return I;
end );


#############################################################################
##
#M  ViewObj( <emb> )  . . . . . . . . . . . . . . . . . . . .  view embedding
##
InstallMethod( ViewObj,
    "for embedding into direct product",
    true,
    [ IsEmbeddingDirectProductPermGroup ], 0,
    function( emb )
    Print( Ordinal( emb!.component ), " embedding into " );
    View( Range( emb ) );
end );


#############################################################################
##
#M  PrintObj( <emb> ) . . . . . . . . . . . . . . . . . . . . print embedding
##
InstallMethod( PrintObj,
    "for embedding into direct product",
    true,
    [ IsEmbeddingDirectProductPermGroup ], 0,
    function( emb )
    Print( "Embedding( ", Range( emb ), ", ", emb!.component, " )" );
end );


#############################################################################
##
#R  IsProjectionDirectProductPermGroup( <hom> ) projection onto direct factor
##
DeclareRepresentation( "IsProjectionDirectProductPermGroup",
      IsAttributeStoringRep and
      IsGroupHomomorphism and IsSurjective and
      IsSPGeneralMapping, [ "component" ] );

#############################################################################
##
#M  Projection( <D>, <i> )  . . . . . . . . . . . . . . . . . make projection
##
InstallMethod( Projection,"perm direct product", true,
      [ IsPermGroup and HasDirectProductInfo,
        IsPosInt ], 0,
    function( D, i )
    local   prj, info;
    info := DirectProductInfo( D );
    if IsBound( info.projections[i] ) then return info.projections[i]; fi;

    prj := Objectify( NewType( GeneralMappingsFamily( PermutationsFamily,
                                                      PermutationsFamily ),
                   IsProjectionDirectProductPermGroup ),
                   rec( component := i ) );
    SetSource( prj, D );
    info.projections[i] := prj;
    return prj;
end );

#############################################################################
##
#M  Range( <prj> )  . . . . . . . . . . . . . . . . . . . . . . of projection
##
InstallMethod( Range, "perm direct product projection",true,
  [ IsProjectionDirectProductPermGroup ], 0,
    prj -> DirectProductInfo( Source( prj ) ).groups[ prj!.component ] );

#############################################################################
##
#M  ImagesRepresentative( <prj>, <g> )  . . . . . . . . . . . . of projection
##
InstallMethod( ImagesRepresentative,"perm direct product projection",
  FamSourceEqFamElm,
        [ IsProjectionDirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( prj, g )
    local info;
    info := DirectProductInfo( Source( prj ) );
    return RestrictedPermNC( g, info.news[ prj!.component ] )
           ^ ( info.perms[ prj!.component ] ^ -1 );
end );

#############################################################################
##
#M  PreImagesRepresentative( <prj>, <g> ) . . . . . . . . . . . of projection
##
InstallMethod( PreImagesRepresentative,"perm direct product projection",
  FamRangeEqFamElm,
        [ IsProjectionDirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( prj, g )
    return g ^ DirectProductInfo( Source( prj ) ).perms[ prj!.component ];
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <prj> ) . . . . . . . of projection
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
  "perm direct product projection",
    true, [ IsProjectionDirectProductPermGroup ], 0,
    function( prj )
    local   D,  gens,  i,  K, info;

    D := Source( prj );
    info := DirectProductInfo( D );
    gens := [  ];
    for i  in [ 1 .. Length( info.groups ) ]  do
        if i <> prj!.component  then
            Append( gens, OnTuples( GeneratorsOfGroup( info.groups[ i ] ),
                                    info.perms[ i ] ) );
        fi;
    od;
    K := SubgroupNC( D, gens );
    SetIsNormalInParent( K, true );
    return K;
end );


#############################################################################
##
#M  ViewObj( <prj> )  . . . . . . . . . . . . . . . . . . . . view projection
##
InstallMethod( ViewObj,
    "for projection from a direct product",
    true,
    [ IsProjectionDirectProductPermGroup ], 0,
    function( prj )
    Print( Ordinal( prj!.component ), " projection of " );
    View( Source( prj ) );
end );


#############################################################################
##
#M  PrintObj( <prj> ) . . . . . . . . . . . . . . . . . . .  print projection
##
InstallMethod( PrintObj,
    "for projection from a direct product",
    true,
    [ IsProjectionDirectProductPermGroup ], 0,
    function( prj )
    Print( "Projection( ", Source( prj ), ", ", prj!.component, " )" );
end );


InstallGlobalFunction(SubdirectDiagonalPerms,function(l,m)
local n,o,p;
  n:=LargestMovedPoint(l);
  o:=LargestMovedPoint(m);
  p:=MappingPermListList([1..o],[n+1..n+o]);
  return List([1..Length(l)],i->l[i]*m[i]^p);
end);


#############################################################################
##
#M  SubdirectProduct( <G1>, <G2>, <phi1>, <phi2> )  . . . . . . . constructor
##
InstallMethod( SubdirectProductOp,"permgroup", true,
  [ IsPermGroup, IsPermGroup, IsGroupHomomorphism, IsGroupHomomorphism ], 0,
    function( G1, G2, phi1, phi2 )
    local   S,          # subdirect product of <G1> and <G2>, result
            gens,       # generators of <S>
            D,          # direct product of <G1> and <G2>
            emb1, emb2, # embeddings of <G1> and <G2> into <D>
            info, Dinfo,# info records
            gen;        # one generator of <G1> or kernel of <phi2>

    # make the direct product and the embeddings
    D := DirectProduct( G1, G2 );
    emb1 := Embedding( D, 1 );
    emb2 := Embedding( D, 2 );

    # the subdirect product is generated by $(g_1,x_{g_1})$ where $g_1$ loops
    # over the  generators of $G_1$  and $x_{g_1} \in   G_2$ is arbitrary such
    # that $g_1^{phi_1} = x_{g_1}^{phi_2}$ and by $(1,k_2)$ where $k_2$ loops
    # over the generators of the kernel of $phi_2$.
    gens := [];
    for gen  in GeneratorsOfGroup( G1 )  do
        Add( gens, gen^emb1 * PreImagesRepresentative(phi2,gen^phi1)^emb2 );
    od;
    for gen in GeneratorsOfGroup(
                   KernelOfMultiplicativeGeneralMapping( phi2 ) )  do
        Add( gens, gen ^ emb2 );
    od;

    # and make the subdirect product
    S := GroupByGenerators( gens );
    SetParent( S, D );

    Dinfo := DirectProductInfo( D );
    info := rec( groups := [G1, G2],
                 homomorphisms := [phi1, phi2],
                 olds  := Dinfo.olds,
                 news  := Dinfo.news,
                 perms := Dinfo.perms,
                 projections := [] );
    SetSubdirectProductInfo( S, info );
    return S;
end );

#############################################################################
##
#R  IsProjectionSubdirectProductPermGroup( <hom> )  .  projection onto factor
##
DeclareRepresentation( "IsProjectionSubdirectProductPermGroup",
      IsAttributeStoringRep and
      IsGroupHomomorphism and IsSurjective and
      IsSPGeneralMapping, [ "component" ] );

#############################################################################
##
#M  Projection( <S>, <i> )  . . . . . . . . . . . . . . . . . make projection
##
InstallMethod( Projection,"perm subdirect product",true,
      [ IsPermGroup and HasSubdirectProductInfo,
        IsPosInt ], 0,
    function( S, i )
    local   prj, info;
    info := SubdirectProductInfo( S );
    if IsBound( info.projections[i] ) then return info.projections[i]; fi;

    prj := Objectify( NewType( GeneralMappingsFamily( PermutationsFamily,
                                                      PermutationsFamily ),
                   IsProjectionSubdirectProductPermGroup ),
                   rec( component := i ) );
    SetSource( prj, S );
    info.projections[i] := prj;
    SetSubdirectProductInfo( S, info );
    return prj;
end );

#############################################################################
##
#M  Range( <prj> )  . . . . . . . . . . . . . . . . . . . . . . of projection
##
InstallMethod( Range,"perm subdirect product projection",
  true, [ IsProjectionSubdirectProductPermGroup ], 0,
    prj -> SubdirectProductInfo( Source( prj ) ).groups[ prj!.component ] );

#############################################################################
##
#M  ImagesRepresentative( <prj>, <g> )  . . . . . . . . . . . . of projection
##
InstallMethod( ImagesRepresentative,"perm subdirect product projection",
  FamSourceEqFamElm,
        [ IsProjectionSubdirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( prj, g )
    local info;
    info := SubdirectProductInfo( Source( prj ) );
    return RestrictedPermNC( g, info.news[ prj!.component ] )
           ^ ( info.perms[ prj!.component ] ^ -1 );
end );

#############################################################################
##
#M  PreImagesRepresentative( <prj>, <g> ) . . . . . . . . . . . of projection
##
InstallMethod( PreImagesRepresentative,"perm subdirect product projection",
  FamRangeEqFamElm,
        [ IsProjectionSubdirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( prj, img )
    local   S,
            elm,        # preimage of <img> under <prj>, result
            info,       # info record
            phi1, phi2; # homomorphisms of components

    S := Source( prj );
    info := SubdirectProductInfo( S );

    # get the homomorphism
    phi1 := info.homomorphisms[1];
    phi2 := info.homomorphisms[2];

    # compute the preimage
    if 1 = prj!.component  then
        elm := img                                    ^ info.perms[1]
             * PreImagesRepresentative(phi2,img^phi1) ^ info.perms[2];
    else
        elm := img                                    ^ info.perms[2]
             * PreImagesRepresentative(phi1,img^phi2) ^ info.perms[1];
    fi;

    # return the preimage
    return elm;
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <prj> ) . . . . . . . of projection
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    "perm subdirect product projection",true,
    [ IsProjectionSubdirectProductPermGroup ], 0,
    function( prj )
    local   D,  i, info;

    D := Source( prj );
    info := SubdirectProductInfo( D );
    i := 3 - prj!.component;
    return SubgroupNC( D, OnTuples
           ( GeneratorsOfGroup( KernelOfMultiplicativeGeneralMapping(
                                    info.homomorphisms[ i ] ) ),
             info.perms[ i ] ) );
end );


#############################################################################
##
#M  ViewObj( <prj> )  . . . . . . . . . . . . . . . . . . . . view projection
##
InstallMethod( ViewObj,
    "for projection from subdirect product",
    true,
    [ IsProjectionSubdirectProductPermGroup ], 0,
    function( prj )
    Print( Ordinal( prj!.component ), " projection of " );
    View( Source( prj ) );
end );


#############################################################################
##
#M  PrintObj( <prj> ) . . . . . . . . . . . . . . . . . . .  print projection
##
InstallMethod( PrintObj,
    "for projection from subdirect product",
    true,
    [ IsProjectionSubdirectProductPermGroup ], 0,
    function( prj )
    Print( "Projection( ", Source( prj ), ", ", prj!.component, " )" );
end );


#############################################################################
##
#M  WreathProductImprimitiveAction( <G>, <H> [,<hom>] )
##
InstallGlobalFunction(WreathProductImprimitiveAction,function( arg )
local   G,H,        # factors
        GP,         # preimage of <G> (if homomorphism)
        Ggens,Igens,# permutation images of generators
        alpha,      # action homomorphism for <H>
        permimpr,   # product is pure permutation groups imprimitive
        I,          # image of <alpha>
        grp,        # wreath product of <G> and <H>, result
        gens,       # generators of the wreath product
        gens1,      # generators of first base part
        gen,        # one generator
        domG,       # domain of operation of <G>
        degG,       # degree of <G>
        domI,       # domain of operation of <I>
        degI,       # degree of <I>
        shift,      # permutation permuting the blocks
        perms,      # component permutating permutations
        basegens,   # generators of base subgroup
        hgens,      # complement generators
        components, # components (points) of base group
        rans,       # list of arguments that have '.sCO.random'
        info,       # info record
        i, k, l;    # loop variables

    G:=arg[1];
    H:=arg[2];
    # get the domain of operation of <G> and <H>
    if IsPermGroup( G )  then
        permimpr:=true;
        domG := MovedPoints( G );
        GP:=G;
        Ggens:=GeneratorsOfGroup(G);
    elif IsGroupHomomorphism( G )  and  IsPermGroup( Range( G ) )  then
        permimpr:=false;
        GP:=Source(G);
        domG := MovedPoints( Range( G ) );
        Ggens:=List(GeneratorsOfGroup(GP),i->ImageElm(G,i));
        G := Image( G );
    else
        Error( "WreathProduct: <G> must be perm group or homomorphism" );
    fi;
    degG := Length( domG );

    if Length(arg)=2 then
        domI := MovedPoints( H );
        I := H;
        alpha := IdentityMapping( H );
        Igens:=GeneratorsOfGroup(H);
    elif IsGroupHomomorphism(arg[3]) and IsPermGroup(Range(arg[3])) then
        permimpr:=false; # also will fail the permutation imprimitive case
        alpha := arg[3];
        I := Image( alpha );
        domI := MovedPoints( Range( alpha) );
        Igens:=List(GeneratorsOfGroup(H),i->ImageElm(alpha,i));
    else
        Error( "WreathProduct: <H> must be perm group or homomorphism" );
    fi;

    if IsEmpty( domI )  then
        domI := [ 1 ];
    fi;
    domI := MakeImmutable(Set(domI));
    degI := Length( domI );

    # make the generators of the direct product of <deg> copies of <G>
    components:=[];
    gens := [];
    perms:= [];

    # force trivial group to act on 1 point
    if degG = 0 then domG := [1]; degG := 1; fi;

    for i  in [1..degI]  do
        components[i]:=[(i-1)*degG+1..i*degG];
        shift := MappingPermListList( domG, components[i] );
        Add(perms,shift);
        for gen  in Ggens  do
            Add( gens, gen ^ shift );
        od;
        if i=1 then gens1:=ShallowCopy(gens);fi;
    od;
    basegens:=ShallowCopy(gens);

    # reduce generator number if it becomes too large -- only first base
    # part
    if Length(basegens)>10 and Length(domI)>1 and IsTransitive(I,domI) then
      gens:=gens1;
    fi;

    # add the generators of <I>
    hgens:=[];
    for gen  in Igens  do
        shift := [];
        for i  in [1..degI]  do
            k := Position( domI, domI[i]^gen );
            for l  in [1..degG]  do
                shift[(i-1)*degG+l] := (k-1)*degG+l;
            od;
        od;
        shift:=PermList(shift);
        Add( gens, shift );
        Add(hgens, shift );
    od;

    # make the group generated by those generators
    grp := GroupWithGenerators( gens, () );  # `gens' arose from `PermList'

    # enter the size
    SetSize( grp, Size( G ) ^ degI * Size( I ) );

    # note random method
    rans := Filtered( [ G, I ], i ->
            IsBound( StabChainOptions( i ).random ) );
    if Length( rans ) > 0 then
        SetStabChainOptions( grp, rec( random :=
            Minimum( List( rans, i -> StabChainOptions( i ).random ) ) ) );
    fi;

    info := rec(
      groups := [GP,H],
      alpha  := alpha,
      perms  := perms,
      base   := SubgroupNC(grp,basegens),
      basegens:=basegens,
      I      := I,
      degI   := degI,
      domI   := domI,
      hgens  := hgens,
      components := components,
      embeddingType := NewType(
                 GeneralMappingsFamily(PermutationsFamily,PermutationsFamily),
                 IsEmbeddingImprimitiveWreathProductPermGroup),
      embeddings := [],
      permimpr:=permimpr);

    SetWreathProductInfo( grp, info );

    # return the group
    return grp;
end);

InstallMethod( WreathProduct,"permgroups: imprimitive",
  true, [ IsPermGroup, IsPermGroup ], 0,
  WreathProductImprimitiveAction);

InstallOtherMethod( WreathProduct,"permgroups and action", true,
 [ IsPermGroup, IsPermGroup, IsSPGeneralMapping ], 0,
  WreathProductImprimitiveAction);

#############################################################################
##
#M  Embedding( <W>, <i> ) . . . . . . . . . . . . . . . . . .  make embedding
##
InstallMethod( Embedding,"perm wreath product", true,
  [ IsPermGroup and HasWreathProductInfo,
    IsPosInt ], 0,
function( W, i )
local   emb, info;
    info := WreathProductInfo( W );
    if IsBound( info.embeddings[i] ) then return info.embeddings[i]; fi;

    if i<=info.degI then
      emb := Objectify( info.embeddingType , rec( component := i ) );
      if IsBound(info.productType) and info.productType=true then
        SetAsGroupGeneralMappingByImages(emb,GroupHomomorphismByImagesNC(
          info.groups[1],W,GeneratorsOfGroup(info.groups[1]),
          info.basegens[i]));
      fi;
    elif i=info.degI+1 then
      if IsBound(info.productType) and info.productType=true then
        emb:= GroupHomomorphismByImagesNC(info.I,W,GeneratorsOfGroup(info.I),
                                          info.hgens);
        emb:= GroupHomomorphismByImagesNC(info.groups[2],W,
              GeneratorsOfGroup(info.groups[2]),
              List(GeneratorsOfGroup(info.groups[2]),
              i->ImageElm(emb,ImageElm(info.alpha,i))));
        SetIsInjective(emb,true);
      else
        emb := Objectify( info.embeddingType , rec( component := i ) );
      fi;
    else
      Error("no embedding <i> defined");
    fi;
    SetRange( emb, W );

    info.embeddings[i] := emb;

    return emb;
end );

#############################################################################
##
#M  Source( <emb> ) . . . . . . . . . . . . . . . . . . . . . .  of embedding
##
InstallMethod( Source,"perm wreath product embedding",
  true, [ IsEmbeddingWreathProductPermGroup ], 0,
    function(emb)
      local info;
      info := WreathProductInfo( Range( emb ) );
      # Embedding into top group
      if emb!.component = info.degI + 1 then
        return info.groups[2];
      # Embedding into a component of the base group
      else
        return info.groups[1];
      fi;
    end);

#############################################################################
##
#M  ImagesRepresentative( <emb>, <g> )  . . . . . . . . . . . .  of embedding
##
InstallMethod( ImagesRepresentative,
  "imprim perm wreath product embedding",FamSourceEqFamElm,
        [ IsEmbeddingImprimitiveWreathProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( emb, g )
    local info, degI, x, shift, domI, degG, i, k, l;
    info := WreathProductInfo(Range(emb));
    degI := info.degI;
    # Embedding into a component of the base group
    if emb!.component <> degI + 1 then
      return g ^ info.perms[emb!.component];
    fi;
    # Embedding into top group
    x := g ^ info.alpha;
    domI := info.domI;
    degG := NrMovedPoints(info.groups[1]);
    # force trivial group to act on 1 point
    if degG = 0 then
      degG := 1;
    fi;
    shift := [];
    for i  in [1 .. degI]  do
      k := Position(domI, domI[i] ^ x);
      if k = fail then
        return fail;
      fi;
      for l  in [1 .. degG]  do
        shift[(i - 1) * degG + l] := (k - 1) * degG + l;
      od;
    od;
    return PermList(shift);
end );

#############################################################################
##
#M  PreImagesRepresentative( <emb>, <g> ) . . . . . . . . . . .  of embedding
##
InstallMethod( PreImagesRepresentative,
  "imprim perm wreath product embedding", FamRangeEqFamElm,
        [ IsEmbeddingImprimitiveWreathProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( emb, g )
    local info;
    info := WreathProductInfo( Range( emb ) );
    # Embedding into top group
    if emb!.component = info.degI + 1 then
      return g ^ Projection(Range(emb));
    fi;
    # Embedding into component of base group
    if not g in info.base then
      return fail;
    fi;
    return RestrictedPermNC( g, info.components[ emb!.component ] )
          ^ (info.perms[ emb!.component ] ^ -1);
end );


#############################################################################
##
#M  ViewObj( <emb> )  . . . . . . . . . . . . . . . . . . . .  view embedding
##
InstallMethod( ViewObj,
    "for embedding into wreath product",
    true,
    [ IsEmbeddingWreathProductPermGroup ], 0,
    function( emb )
    Print( Ordinal( emb!.component ), " embedding into ", Range( emb ) );
end );


#############################################################################
##
#M  PrintObj( <emb> ) . . . . . . . . . . . . . . . . . . . . print embedding
##
InstallMethod( PrintObj,
    "for embedding into wreath product",
    true,
    [ IsEmbeddingWreathProductPermGroup ], 0,
    function( emb )
    Print( "Embedding( ", Range( emb ), ", ", emb!.component, " )" );
end );


#############################################################################
##
#M  Projection( <W> ) . . . . . . . . . . . . . . projection of wreath on top
##
InstallOtherMethod( Projection,"perm wreath product", true,
  [ IsPermGroup and HasWreathProductInfo ],0,
function( W )
local  info, proj, H, degI, degK, constPoints, projFunc;
  info := WreathProductInfo( W );
  if IsBound( info.projection ) then return info.projection; fi;

  # Imprimitive Action, tuple (i, j) corresponds
  # to point i + degK * (j - 1)
  if IsBound(info.permimpr) and info.permimpr=true then
    proj:=ActionHomomorphism(W,info.components,OnSets,"surjective");
  # Primitive Action, tuple (t_1, ..., t_degI) corresponds
  # to point Sum_{i=1}^degI t_i * degK ^ (i - 1)
  elif IsBound(info.productType) and info.productType=true then
    degI := info.degI;
    degK := NrMovedPoints(info.groups[1]);
    # constPoints correspond to [1, 1, ...] and the one-vectors with a 2 in each position,
    # i.e. [2, 1, 1, ...], [1, 2, 1, ...], [1, 1, 2, ...], ...
    constPoints := Concatenation([0], List([0 .. degI - 1], i -> degK ^ i)) + 1;
    projFunc := function(x)
      local imageComponents, i, comp, topImages;
      # Let x = (f_1, ..., f_m; h).
      # imageComponents = [ [1 ^ f_1, 1 ^ f_2, 1 ^ f_3, ...] ^ (1, h)
      #                     [2 ^ f_1, 1 ^ f_2, 1 ^ f_3, ...] ^ (1, h),
      #                     [1 ^ f_1, 2 ^ f_2, 1 ^ f_3, ...] ^ (1, h), ... ]
      # So we just need to check where the bit differs from the first point
      # in order to compute the action of the top element h.
      imageComponents := List(OnTuples(constPoints, x) - 1,
                              p -> CoefficientsQadic(p, degK) + 1);
      # The qadic expansion has no "trailing" zeros. Thus we need to append them.
      # For example if (1, ..., 1) ^ (f_1, ..., f_m) = (1, ..., 1),
      # we have imageComponents[1] = CoefficientsQadic(0, degK) + 1 = [].
      # Note that we append 1's instead of 0's,
      # since we already transformed the result of the qadic expansion
      # from [{0, ..., degK - 1}, ...] to [{1, ..., degK}, ...].
      for i in [1 .. degI + 1] do
        comp := imageComponents[i];
        Append(comp, ListWithIdenticalEntries(degI - Length(comp), 1));
      od;
      # For some reason, the action of the top component is in reverse order,
      # i.e. [ p[m], ..., p[1] ] ^ (1, h) = [ p[m ^ (h ^ -1)], ..., p[1 ^ (h ^ -1)] ]
      topImages := List([0 .. degI - 1], i -> PositionProperty([0 .. degI - 1],
                        j -> imageComponents[1, degI - j] <>
                             imageComponents[degI - i + 1, degI - j]));
      return PermList(topImages);
    end;
    proj := GroupHomomorphismByFunction(W, info.groups[2], projFunc);
  else # weird cases where we use `hom` for the construction of the wreath product
    H:=info.groups[2];
    proj:=List(info.basegens,i->One(H));
    proj:=GroupHomomorphismByImagesNC(W,H,
      Concatenation(info.basegens,info.hgens),
      Concatenation(proj,GeneratorsOfGroup(H)));
  fi;
  SetKernelOfMultiplicativeGeneralMapping(proj,info.base);

  info.projection:=proj;
  return proj;
end);

#############################################################################
##
#M  ListWreathProductElementNC( <G>, <x> )
##
InstallMethod( ListWreathProductElementNC, "perm wreath product", true,
 [ IsPermGroup and HasWreathProductInfo, IsObject, IsBool ], 0,
function(G, x, testDecomposition)
  local info, list, h, hIm, f, degK, i, j, constPoints, imageComponents, comp, restPerm;

  info := WreathProductInfo(G);
  # The top group element
  h := x ^ Projection(G);
  if h = fail then
    return fail;
  fi;
  hIm := ImageElm(Embedding(G, info.degI + 1), h);
  if hIm = fail then
    return fail;
  fi;
  # The product of the base group elements
  f := x * hIm ^ (-1);
  list := EmptyPlist(info!.degI + 1);
  list[info.degI + 1] := h;
  # Imprimitive Action, tuple (i, j) corresponds
  # to point i + degK * (j - 1)
  if IsBound(info.permimpr) and info.permimpr then
    for i in [1 .. info.degI] do
        restPerm := RESTRICTED_PERM(f, info.components[i], testDecomposition);
        if restPerm = fail then
          return fail;
        fi;
        list[i] := restPerm ^ info.perms[i];
    od;
  # Primitive Action, tuple (t_1, ..., t_degI) corresponds
  # to point Sum_{i=1}^degI t_i * degK ^ (i - 1)
  elif IsBound(info.productType) and info.productType then
    degK := NrMovedPoints(info.groups[1]);
    # constPoints correspond to [1, 1, 1, ...], [2, 2, 2, ...], ...
    constPoints := List([0 .. degK - 1], i -> Sum([0 .. info.degI - 1],
                                                  j -> i * degK ^ j)) + 1;
    # imageComponents = [ [1 ^ f_1, 1 ^ f_2, 1 ^ f_3, ...],
    #                     [2 ^ f_1, 2 ^ f_2, 2 ^ f_3, ...], ... ]
    imageComponents := List(OnTuples(constPoints, f) - 1,
                            p -> CoefficientsQadic(p, degK) + 1);
    # The qadic expansion has no "trailing" zeros. Thus we need to append them.
    # For example if (1, ..., 1) ^ (f_1, ..., f_m) = (1, ..., 1),
    # we have imageComponents[1] = CoefficientsQadic(0, degK) + 1 = [].
    # Note that we append 1's instead of 0's,
    # since we already transformed the result of the qadic expansion
    # from [{0, ..., degK - 1}, ...] to [{1, ..., degK}, ...].
    for i in [1 .. degK] do
      comp := imageComponents[i];
      Append(comp, ListWithIdenticalEntries(info.degI - Length(comp), 1));
    od;
    for j in [1 .. info.degI] do
      list[j] := PermList(List([1 .. degK], i -> imageComponents[i,j]));
      if list[j] = fail then
        return fail;
      fi;
    od;
  else
    ErrorNoReturn("Error: cannot determine which action ",
                  "was used for wreath product");
  fi;
  return list;
end);

#############################################################################
##
#M  WreathProductElementListNC(<G>, <list>)
##
InstallMethod( WreathProductElementListNC, "perm wreath product", true,
 [ IsPermGroup and HasWreathProductInfo, IsList ], 0,
function(G, list)
  local info;

  info := WreathProductInfo(G);
  return Product(List([1 .. info.degI + 1], i -> list[i] ^ Embedding(G, i)));
end);

#############################################################################
##
#F  WreathProductProductAction( <G>, <H> )   wreath product in product action
##
InstallGlobalFunction( WreathProductProductAction, function( G, H )
    local  W,  domG,  domI,  map,  I,  deg,  n,  N,  gens,  gen,  i,  list,
           p,  adic,  q,  Val,  val,  rans,basegens,hgens,info,degI;

    # get the domain of operation of <G> and <H>
    if IsPermGroup( G )  then
        domG := MovedPoints( G );
    elif IsGroupHomomorphism( G )  and  IsPermGroup( Range( G ) )  then
        domG := MovedPoints( Range( G ) );
        G := Image( G );
    else
        Error(
      "WreathProductProductAction: <G> must be perm group or homomorphism" );
    fi;
    deg := Length( domG );
    if IsPermGroup( H )  then
        domI := MovedPoints( H );
        map := IdentityMapping( H );
    elif IsGroupHomomorphism( H )  and  IsPermGroup( Range( H ) )  then
        map := H;
        domI := MovedPoints( Range( H ) );
        H := Source( H );
    else
        Error(
      "WreathProductProductAction: <H> must be perm group or homomorphism" );
    fi;
    I := Image( map );
    if IsEmpty( domI )  then
        domI := [ 1 ];
    fi;
    degI := Length( domI );
    n := Length( domI );

    N := deg ^ n;
    gens := [  ];
    basegens:=List([1..n],i->[]);
    for gen  in GeneratorsOfGroup( G )  do
        val := 1;
        for i  in [ 1 .. n ]  do
            Val := val * deg;
            list := [  ];
            for p  in [ 0 .. N - 1 ]  do
                q := QuoInt( p mod Val, val ) + 1;
                Add( list, p +
                     ( Position( domG, domG[ q ] ^ gen ) - q ) * val );
            od;
            q:=PermList( list + 1 );
            Add(gens,q);
            Add(basegens[i],q);
            val := Val;
        od;
    od;
    hgens:=[];
    for gen  in GeneratorsOfGroup( I )  do
        list := [  ];
        for p  in [ 0 .. N - 1 ]  do
            adic := [  ];
            for i  in [ 0 .. n - 1 ]  do
                adic[ Position( domI, domI[ n - i ] ^ gen ) ] := p mod deg;
                p := QuoInt( p, deg );
            od;
            q := 0;
            for i  in adic  do
                q := q * deg + i;
            od;
            Add( list, q );
        od;
        q:=PermList( list + 1 );
        Add(gens,q);
        Add(hgens,q);
    od;
    W := GroupByGenerators( gens, () );  # `gens' arose from `PermList'
    SetSize( W, Size( G ) ^ n * Size( I ) );

    # note random method
    rans := Filtered( [ G, H ], i ->
            IsBound( StabChainOptions( i ).random ) );
    if Length( rans ) > 0 then
        SetStabChainOptions( W, rec( random :=
            Minimum( List( rans, i -> StabChainOptions( i ).random ) ) ) );
    fi;

    info := rec(
      groups := [G,H],
      alpha  := map,
      I      := I,
      degI   := degI,
      productType:=true,
      basegens := basegens,
      base   := SubgroupNC(W,Flat(basegens)),
      hgens  := hgens,
      embeddingType := NewType(
                 GeneralMappingsFamily(PermutationsFamily,PermutationsFamily),
                 IsEmbeddingProductActionWreathProductPermGroup),
      embeddings := []);

    SetWreathProductInfo( W, info );

    return W;
end );

##############################################################################
##
#M  SemidirectProduct                                   for permutation groups

##
##  Use regular action
##  Original version by Derek Holt, 6/9/96, in first GAP3 version of xmod
##
InstallMethod( SemidirectProduct, "generic method for permutation groups",
    [ IsPermGroup, IsGroupHomomorphism, IsPermGroup ],
function( R, map, S )

    local P, genP, genR, genS, L3, perm, r, s, ordS, genno, LS, info, aut;

    # Take the action of R on S  by conjugation.
    LS := AsSSortedList( S );
    genP := [ ];
    genR := GeneratorsOfGroup( R );
    genS := GeneratorsOfGroup( S );
    for r in genR do
        aut:= Image( map, r );
        L3 := List( LS, x -> Position( LS, Image( aut, x ) ) );
        Add( genP, PermList( L3 ) );
    od;
    # Check order of group at this stage, to see if the action is faithful.
    # If not, adjoin the action of R as a permutation group.
    P := Group( genP, () );  # `genP' arose from `PermList'
    if ( Size( P ) <> Size( R ) ) then
        ordS := Size( S );
        genno := 0;
        for r in genR do
            genno := genno + 1;
            genP[ genno ] := genP[ genno ]
                * PermList( Concatenation( [1..ordS], ListPerm( r ) + ordS ) );
        od;
    fi;
    # Take the action of S on S by right multiplication.
    for s in genS do
        L3 := List( LS, x -> Position( LS, x*s ) );
        Add( genP, PermList( L3 ) );
    od;
    P := Group( genP, () );  # `genP' arose from `PermList'
    info := rec( groups := [ R, S ],
                 lenlist := [ 0, Length( genR ), Length( genP ) ],
                 embeddings := [ ],
                 projections := true );
    SetSemidirectProductInfo( P, info );
    return P;
end );

InstallMethod( SemidirectProduct, "Induced permutation automorphisms",
    [ IsPermGroup, IsGroupHomomorphism, IsPermGroup ],
function( U, map, N )
local Ugens,imgs,conj,auc,d,embn,embs,l,u,P,info;
  Ugens:=GeneratorsOfGroup(U);
  imgs:=List(Ugens,x->Image(map,x));
  if ForAll(imgs,IsConjugatorIsomorphism) then
    conj:=List(imgs,ConjugatorOfConjugatorIsomorphism);
    auc:=ClosureGroup(N,conj);
    d:=DirectProduct(U,auc);
    embn:=Embedding(d,2);
    embs:=Embedding(d,1);
    # images of generators of U
    l:=List([1..Length(imgs)],x->Image(embn,conj[x])*Image(embs,Ugens[x]));
    u:=SubgroupNC(d,l);
    if Size(u)=Size(U) then # so the conjugating elements don't generate
                            # something extra
                            # (i.e. the map U->S_N, u->conj.perm. of auto is
                            # a hom.)
      P:=ClosureGroup(Image(embn,N),l);
      embs:=GroupHomomorphismByImagesNC(U,P,Ugens,l);
      info := rec( groups := [ U, N ],
                  embeddings := [embs,RestrictedMapping(embn,N) ],
                  projections := RestrictedMapping(Projection(d,1),P));
      SetSemidirectProductInfo( P, info );
      return P;
    fi;
  fi;
  TryNextMethod();
end);

##############################################################################
##
#M  Embedding                              for permutation semidirect products
##
InstallMethod( Embedding, "generic method for perm semidirect products",
    true, [ IsPermGroup and HasSemidirectProductInfo, IsPosInt ], 0,
function( D, i )
    local  info, G, genG, imgs, hom;

    info := SemidirectProductInfo( D );
    if IsBound( info.embeddings[i] ) then
        return info.embeddings[i];
    fi;
    G := info.groups[i];
    genG := GeneratorsOfGroup( G );
    imgs := GeneratorsOfGroup( D ){[info.lenlist[i]+1 .. info.lenlist[i+1]]};
    hom := GroupHomomorphismByImagesNC( G, D, genG, imgs );
    SetIsInjective( hom, true );
    info.embeddings[i] := hom;
    return hom;
end );

##############################################################################
##
#M  Projection                             for permutation semidirect products
##
InstallOtherMethod( Projection, "generic method for perm semidirect products",
    true, [ IsPermGroup and HasSemidirectProductInfo ], 0,
function( D )
    local  info, genD, G, genG, imgs, hom, ker, list;

    info := SemidirectProductInfo( D );
    if not IsBool( info.projections ) then
        return info.projections;
    fi;
    G := info.groups[1];
    genG := GeneratorsOfGroup( G );
    genD := GeneratorsOfGroup( D );
    list := [ info.lenlist[2]+1 .. info.lenlist[3] ];
    imgs := Concatenation( genG, List( list, j -> One( G ) ) );
    hom := GroupHomomorphismByImagesNC( D, G, genD, imgs );
    SetIsSurjective( hom, true );
    ker := Subgroup( D, genD{ list } );
    SetKernelOfMultiplicativeGeneralMapping( hom, ker );
    info.projections := hom;
    return hom;
end );
