#############################################################################
##
#W  gprdperm.gi                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.gprdperm_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  DirectProductOfPermGroups( <grps> ) . . . . direct product of perm groups
##
InstallGlobalFunction( DirectProductOfPermGroups, function( grps )
    local   oldgrps,  olds,  news,  perms,  gens,
            deg,  grp,  old,  new,  perm,  gen,  D, info;
    
    oldgrps := [  ];
    olds    := [  ];
    news    := [  ];
    perms   := [  ];
    gens    := [  ];
    deg     := 0;
    
    # loop over the groups
    for grp  in grps  do

        # find old domain, new domain, and conjugating permutation
        old  := MovedPoints( grp );
        new  := [deg+1..deg+Length(old)];
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
    D := Group( gens );
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
#M  Size( <D> ) . . . . . . . . . . . . . . . . . . . . . . of direct product
##
InstallMethod( Size, true, [ IsPermGroup and HasDirectProductInfo ], 0,
    function( D )
    local info;
    info := DirectProductInfo( D );
    return Product( List( info.groups, x -> Size( x ) ) );
end );

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
#M  Embedding( <D>, <i> ) . . . . . . . . . . . . . . . . . .  make embedding
##
InstallMethod( Embedding, true,
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
InstallMethod( Source, true, [ IsEmbeddingDirectProductPermGroup ], 0,
    emb -> DirectProductInfo( Range( emb ) ).groups[ emb!.component ] );

#############################################################################
##
#M  ImagesRepresentative( <emb>, <g> )  . . . . . . . . . . . .  of embedding
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsEmbeddingDirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( emb, g )
    return g ^ DirectProductInfo( Range( emb ) ).perms[ emb!.component ];
end );

#############################################################################
##
#M  PreImagesRepresentative( <emb>, <g> ) . . . . . . . . . . .  of embedding
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsEmbeddingDirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( emb, g )
    local info;
    info := DirectProductInfo( Range( emb ) );
    return RestrictedPerm( g, info.news[ emb!.component ] )
           ^ (info.perms[ emb!.component ] ^ -1);
end );

#############################################################################
##
#M  ImagesSource( <emb> ) . . . . . . . . . . . . . . . . . . .  of embedding
##
InstallMethod( ImagesSource, true, [ IsEmbeddingDirectProductPermGroup ], 0,
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
InstallMethod( Projection, true,
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
InstallMethod( Range, true, [ IsProjectionDirectProductPermGroup ], 0,
    prj -> DirectProductInfo( Source( prj ) ).groups[ prj!.component ] );

#############################################################################
##
#M  ImagesRepresentative( <prj>, <g> )  . . . . . . . . . . . . of projection
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsProjectionDirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( prj, g )
    local info;
    info := DirectProductInfo( Source( prj ) );
    return RestrictedPerm( g, info.news[ prj!.component ] )
           ^ ( info.perms[ prj!.component ] ^ -1 );
end );

#############################################################################
##
#M  PreImagesRepresentative( <prj>, <g> ) . . . . . . . . . . . of projection
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
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


#############################################################################
##
#M  SubdirectProduct( <G1>, <G2>, <phi1>, <phi2> )  . . . . . . . constructor
##
InstallMethod( SubdirectProduct, true,
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
    # over the  generators of $G_1$  and $x_{g_1} \in   G_2$ is abitrary such
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
    S := Group( gens );
    SetParent( S, D );

    Dinfo := DirectProductInfo( D );
    info := rec( groups := [G1, G2],
                 homomorphisms := [phi1, phi2],
                 olds  := Dinfo.olds,
                 news  := Dinfo.news,
                 perms := Dinfo.perms,
                 embeddings := [],
                 projections := [] );
    SetSubdirectProductInfo( S, info );
    return S;
end );

#############################################################################
##
#M  Size( <S> ) . . . . . . . . . . . . . . . . . . . .  of subdirect product
##
InstallMethod( Size, true, [ IsPermGroup and HasSubdirectProductInfo ], 0,
    function( S )
    local info;
    info := SubdirectProductInfo( S );
    return Size( info.groups[ 1 ] ) * Size( info.groups[ 2 ] )
           / Size( ImagesSource( info.homomorphisms[ 1 ] ) );
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
InstallMethod( Projection, true,
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
InstallMethod( Range, true, [ IsProjectionSubdirectProductPermGroup ], 0,
    prj -> SubdirectProductInfo( Source( prj ) ).groups[ prj!.component ] );

#############################################################################
##
#M  ImagesRepresentative( <prj>, <g> )  . . . . . . . . . . . . of projection
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsProjectionSubdirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( prj, g )
    local info;
    info := SubdirectProductInfo( Source( prj ) );
    return RestrictedPerm( g, info.news[ prj!.component ] )
           ^ ( info.perms[ prj!.component ] ^ -1 );
end );

#############################################################################
##
#M  PreImagesRepresentative( <prj>, <g> ) . . . . . . . . . . . of projection
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
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
    true,
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
#M  WreathProduct( <G>, <H> ) . . . . .  wreath product of permutation groups
##
InstallMethod( WreathProduct, true, [ IsObject, IsObject ], 0,
    function( G, H )
    local   alpha,      # operation homomorphism for <H>
            I,          # image of <alpha>
            grp,        # wreath product of <G> and <H>, result
            gens,       # generators of the wreath product
            gen,        # one generator
            domG,       # domain of operation of <G>
            degG,       # degree of <G>
            domI,       # domain of operation of <I>
            degI,       # degree of <I>
            shift,      # permutation permuting the blocks
	    perms,      # component permutating permutations
	    basegens,   # generators of base subgroup
	    hgens,	# complement generators
	    components, # components (points) of base group
            rans,       # list of arguments that have '.sCO.random'
	    info,	# info record
            i, k, l;    # loop variables

    # get the domain of operation of <G> and <H>
    if IsPermGroup( G )  then
        domG := MovedPoints( G );
    elif IsGroupHomomorphism( G )  and  IsPermGroup( Range( G ) )  then
        domG := MovedPoints( Range( G ) );
        G := Image( G );
    else
        Error( "WreathProduct: <G> must be perm group or homomorphism" );
    fi;
    degG := Length( domG );
    if IsPermGroup( H )  then
        domI := MovedPoints( H );
        alpha := IdentityMapping( H );
    elif IsGroupHomomorphism( H )  and  IsPermGroup( Range( H ) )  then
        alpha := H;
        domI := MovedPoints( Range( H ) );
        H := Source( H );
    else
        Error( "WreathProduct: <H> must be perm group or homomorphism" );
    fi;
    I := Image( alpha );
    if IsEmpty( domI )  then
        domI := [ 1 ];
    fi;
    degI := Length( domI );

    # make the generators of the direct product of <deg> copies of <G>
    components:=[];
    gens := [];
    perms:= [];
    for i  in [1..degI]  do
	components[i]:=[(i-1)*degG+1..i*degG];
        shift := MappingPermListList( domG, components[i] );
	Add(perms,shift);
        for gen  in GeneratorsOfGroup( G )  do
            Add( gens, gen ^ shift );
        od;
    od;
    basegens:=ShallowCopy(gens);

    # add the generators of <I>
    hgens:=[];
    if degG = 0 then degG := 1; fi;
    for gen  in GeneratorsOfGroup( I )  do
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
    grp := GroupByGenerators( gens, () );

    # enter the size
    SetSize( grp, Size( G ) ^ degI * Size( I ) );

    # note random method
    rans := Filtered( [ G, H ], i ->
            IsBound( StabChainOptions( i ).random ) );
    if Length( rans ) > 0 then
        SetStabChainOptions( grp, rec( random :=
            Minimum( List( rans, i -> StabChainOptions( i ).random ) ) ) );
    fi;
    info := rec( groups := [G,H],
                 alpha  := alpha,
                 perms  := perms,
		 base   := SubgroupNC(grp,basegens),
		 I      := I,
		 degI   := degI,
		 hgens  := hgens,
		 components := components,
                 embeddings := []);

    SetWreathProductInfo( grp, info );

    # return the group
    return grp;
end );

#############################################################################
##
#M  Embedding( <W>, <i> ) . . . . . . . . . . . . . . . . . .  make embedding
##
InstallMethod( Embedding, true,
  [ IsPermGroup and HasWreathProductInfo,
    IsPosInt ], 0,
function( W, i )
    local   emb, info;
    info := WreathProductInfo( W );
    if IsBound( info.embeddings[i] ) then return info.embeddings[i]; fi;
    
    if i<=info.degI then
      emb := Objectify( NewType( GeneralMappingsFamily( PermutationsFamily,
							PermutationsFamily ),
		     IsEmbeddingWreathProductPermGroup ),
		     rec( component := i ) );
    elif i=info.degI+1 then
      emb:= GroupHomomorphismByImagesNC(info.I,W,GeneratorsOfGroup(info.I),
                                        info.hgens);
      emb:= GroupHomomorphismByImagesNC(info.groups[2],W,
             GeneratorsOfGroup(info.groups[2]),
             List(GeneratorsOfGroup(info.groups[2]),
	          i->ImageElm(emb,ImageElm(info.alpha,i))));
      SetIsInjective(emb,true);
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
InstallMethod( Source, true, [ IsEmbeddingWreathProductPermGroup ], 0,
    emb -> WreathProductInfo( Range( emb ) ).groups[1] );

#############################################################################
##
#M  ImagesRepresentative( <emb>, <g> )  . . . . . . . . . . . .  of embedding
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsEmbeddingWreathProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( emb, g )
    return g ^ WreathProductInfo( Range( emb ) ).perms[ emb!.component ];
end );

#############################################################################
##
#M  PreImagesRepresentative( <emb>, <g> ) . . . . . . . . . . .  of embedding
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsEmbeddingWreathProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( emb, g )
    local info;
    info := WreathProductInfo( Range( emb ) );
    if not g in info.base then
      return fail;
    fi;
    return RestrictedPerm( g, info.news[ emb!.component ] )
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
InstallOtherMethod( Projection, true,
  [ IsPermGroup and HasWreathProductInfo ],0,
function( W )
local  info,proj;
  info := WreathProductInfo( W );
  if IsBound( info.projection ) then return info.projection; fi;
  proj:=OperationHomomorphism(W,info.components,OnSets);
  info.projection:=proj;
  return proj;
end);

        
#############################################################################
##
#F  WreathProductProductAction( <G>, <H> )   wreath product in product action
##
InstallGlobalFunction( WreathProductProductAction, function( G, H )
    local  W,  domG,  domI,  map,  I,  deg,  n,  N,  gens,  gen,  i,  list,
           p,  adic,  q,  Val,  val,  rans;
    
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
    n := Length( domI );

    N := deg ^ n;
    gens := [  ];
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
            Add( gens, PermList( list + 1 ) );
            val := Val;
        od;
    od;
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
        Add( gens, PermList( list + 1 ) );
    od;
    W := GroupByGenerators( gens, () );
    SetSize( W, Size( G ) ^ n * Size( I ) );
    
    # note random method
    rans := Filtered( [ G, H ], i ->
            IsBound( StabChainOptions( i ).random ) );
    if Length( rans ) > 0 then
        SetStabChainOptions( W, rec( random :=
            Minimum( List( rans, i -> StabChainOptions( i ).random ) ) ) );
    fi;

    return W;
end );

#############################################################################
