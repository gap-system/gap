#############################################################################
##
#W  gprdperm.gi                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
Revision.gprdperm_gi :=
    "@(#)$Id$";

#############################################################################
##
#R  IsDirectProductPermGroup( <G> ) . . . . . . direct product of perm groups
##
IsDirectProductPermGroup := NewRepresentation
    ( "IsDirectProductPermGroup",
      IsProductGroups and IsPermGroup and IsAttributeStoringRep,
      [ "groups", "olds", "news", "perms" ] );

#############################################################################
##
#F  DirectProductPermGroupConstructor( ... )  . .  construct a direct product
##
DirectProductPermGroupConstructor := function( oldgrps, grps,
                                             olds, news, perms, gens )
    local   deg,  grp,  old,  new,  perm,  gen,  D;
    
    if IsEmpty( news )  then
        deg := 0;
    else
        deg := news[ Length( news ) ];  deg := deg[ Length( deg ) ];
    fi;
    
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

    # make the direct product
    D := Objectify( NewKind( FamilyObj( gens ),
                 IsDirectProductPermGroup ),
                 rec() );
    SetGeneratorsOfMagmaWithInverses( D, AsList( gens ) );

    # enter the information that relates to the construction
    D!.groups            := oldgrps;
    D!.olds              := olds;
    D!.news              := news;
    D!.perms             := perms;

    return D;
end;

#############################################################################
##
#M  DirectProduct2( <G>, <H> )  . . . . . . direct product of two perm groups
##
InstallMethod( DirectProduct2,
        "of perm group and perm groups",
        IsIdentical, [ IsPermGroup, IsPermGroup ], 0,
    function( G, H )
    return DirectProductPermGroupConstructor( [  ], [ G, H ],
                   [  ], [  ], [  ], [  ] );
end );

InstallMethod( DirectProduct2,
        "of direct product and another perm group",
        IsIdentical, [ IsDirectProductPermGroup, IsPermGroup ], 0,
    function( D, H )
    return DirectProductPermGroupConstructor( D!.groups, [ H ],
                   D!.olds, D!.news, D!.perms, GeneratorsOfGroup( D ) );
end );

#############################################################################
##
#M  Size( <D> ) . . . . . . . . . . . . . . . . . . . . . . of direct product
##
InstallMethod( Size, true, [ IsDirectProductPermGroup ], 0,
    D -> Size( D!.groups[ 1 ] ) * Size( D!.groups[ 2 ] ) );

#############################################################################
##
#R  IsEmbeddingDirectProductPermGroup( <hom> )  .  embedding of direct factor
##
IsEmbeddingDirectProductPermGroup := NewRepresentation
    ( "IsEmbeddingDirectProductPermGroup",
      IsAttributeStoringRep and
      IsGroupHomomorphism and IsInjective, [ "component" ] );

#############################################################################
##
#M  EmbeddingOp( <D>, <i> ) . . . . . . . . . . . . . . . . .  make embedding
##
InstallMethod( EmbeddingOp, true,
      [ IsProductGroups and IsDirectProductPermGroup,
        IsPosRat and IsInt ], 0,
    function( D, i )
    local   emb;
    
    emb := Objectify( NewKind( GeneralMappingsFamily( PermutationsFamily,
                                                      PermutationsFamily ),
                   IsEmbeddingDirectProductPermGroup ),
                   rec( component := i ) );
    SetRange( emb, D );
    return emb;
end );

#############################################################################
##
#M  Source( <emb> ) . . . . . . . . . . . . . . . . . . . . . .  of embedding
##
InstallMethod( Source, true, [ IsEmbeddingDirectProductPermGroup ], 0,
    emb -> Range( emb )!.groups[ emb!.component ] );

#############################################################################
##
#M  ImagesRepresentative( <emb>, <g> )  . . . . . . . . . . . .  of embedding
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsEmbeddingDirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( emb, g )
    return g ^ Range( emb )!.perms[ emb!.component ];
end );

#############################################################################
##
#M  PreImagesRepresentative( <emb>, <g> ) . . . . . . . . . . .  of embedding
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsEmbeddingDirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( emb, g )
    return RestrictedPerm( g, Range( emb )!.news[ emb!.component ] )
           ^ ( Range( emb )!.perms[ emb!.component ] ^ -1 );
end );

#############################################################################
##
#M  ImagesSource( <emb> ) . . . . . . . . . . . . . . . . . . .  of embedding
##
InstallMethod( ImagesSource, true, [ IsEmbeddingDirectProductPermGroup ], 0,
    function( emb )
    local   D,  I;
    
    D := Range( emb );
    I := SubgroupNC( D, OnTuples
                 ( GeneratorsOfGroup( D!.groups[ emb!.component ] ),
                   D!.perms[ emb!.component ] ) );
    SetIsNormalInParent( I, true );
    return I;
end );

#############################################################################
##
#M  PrintObj( <emb> ) . . . . . . . . . . . . . . . . . . . . print embedding
##
InstallMethod( PrintObj, true, [ IsEmbeddingDirectProductPermGroup ], 0,
    function( emb )
    Print( Ordinal( emb!.component ), " embedding into ", Range( emb ) );
end );

#############################################################################
##
#R  IsProjectionDirectProductPermGroup( <hom> ) projection onto direct factor
##
IsProjectionDirectProductPermGroup := NewRepresentation
    ( "IsProjectionDirectProductPermGroup",
      IsAttributeStoringRep and
      IsGroupHomomorphism and IsSurjective, [ "component" ] );

#############################################################################
##
#M  ProjectionOp( <D>, <i> )  . . . . . . . . . . . . . . . . make projection
##
InstallMethod( ProjectionOp, true,
      [ IsProductGroups and IsDirectProductPermGroup,
        IsPosRat and IsInt ], 0,
    function( D, i )
    local   prj;
    
    prj := Objectify( NewKind( GeneralMappingsFamily( PermutationsFamily,
                                                      PermutationsFamily ),
                   IsProjectionDirectProductPermGroup ),
                   rec( component := i ) );
    SetSource( prj, D );
    return prj;
end );

#############################################################################
##
#M  Range( <prj> )  . . . . . . . . . . . . . . . . . . . . . . of projection
##
InstallMethod( Range, true, [ IsProjectionDirectProductPermGroup ], 0,
    prj -> Source( prj )!.groups[ prj!.component ] );

#############################################################################
##
#M  ImagesRepresentative( <prj>, <g> )  . . . . . . . . . . . . of projection
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsProjectionDirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( prj, g )
    return RestrictedPerm( g, Source( prj )!.news[ prj!.component ] )
           ^ ( Source( prj )!.perms[ prj!.component ] ^ -1 );
end );

#############################################################################
##
#M  PreImagesRepresentative( <prj>, <g> ) . . . . . . . . . . . of projection
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsProjectionDirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( prj, g )
    return g ^ Source( prj )!.perms[ prj!.component ];
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <prj> ) . . . . . . . of projection
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    true, [ IsProjectionDirectProductPermGroup ], 0,
    function( prj )
    local   D,  gens,  i,  K;
    
    D := Source( prj );
    gens := [  ];
    for i  in [ 1 .. Length( D!.groups ) ]  do
        if i <> prj!.component  then
            Append( gens, OnTuples( GeneratorsOfGroup( D!.groups[ i ] ),
                                    D!.perms[ i ] ) );
        fi;
    od;
    K := SubgroupNC( D, gens );
    SetIsNormalInParent( K, true );
    return K;
end );

#############################################################################
##
#M  PrintObj( <prj> ) . . . . . . . . . . . . . . . . . . .  print projection
##
InstallMethod( PrintObj, true, [ IsProjectionDirectProductPermGroup ], 0,
    function( prj )
    Print( Ordinal( prj!.component ), " projection of ", Source( prj ) );
end );

#############################################################################
##

#R  IsSubdirectProductPermGroup( <S> )  . .  subdirect product of perm groups
##
IsSubdirectProductPermGroup := NewRepresentation
    ( "IsSubdirectProductPermGroup",
      IsProductGroups and IsAttributeStoringRep,
      [ "groups", "homomorphisms", "olds", "news", "perms" ] );

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
            gen;        # one generator of <G1> or kernel of <phi2>

    # make the direct product and the embeddings
    D := DirectProduct2( G1, G2 );
    emb1 := EmbeddingOp( G1, D, 1 );
    emb2 := EmbeddingOp( G2, D, 2 );
    
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
    S := Objectify( NewKind( FamilyObj( gens ),
                 IsSubdirectProductPermGroup ),
                 rec() );
    SetGeneratorsOfMagmaWithInverses( S, AsList( gens ) );
    SetParent( S, D );

    # enter the information that relates to the construction
    S!.groups                    := [ G1, G2 ];
    S!.homomorphisms             := [ phi1, phi2 ];

    # transfer info from D needed for Projection
    S!.olds  := D!.olds;
    S!.news  := D!.news;
    S!.perms := D!.perms;

    return S;
end );

#############################################################################
##
#M  Size( <S> ) . . . . . . . . . . . . . . . . . . . .  of subdirect product
##
InstallMethod( Size, true, [ IsSubdirectProductPermGroup ], 0,
    S -> Size( S!.groups[ 1 ] ) * Size( S!.groups[ 2 ] )
         / Size( ImagesSource( S!.homomorphisms[ 1 ] ) ) );

#############################################################################
##
#R  IsProjectionSubdirectProductPermGroup( <hom> )  .  projection onto factor
##
IsProjectionSubdirectProductPermGroup := NewRepresentation
    ( "IsProjectionSubdirectProductPermGroup",
      IsAttributeStoringRep and
      IsGroupHomomorphism and IsSurjective, [ "component" ] );

#############################################################################
##
#M  ProjectionOp( <S>, <i> )  . . . . . . . . . . . . . . . . make projection
##
InstallMethod( ProjectionOp, true,
      [ IsProductGroups and IsSubdirectProductPermGroup,
        IsPosRat and IsInt ], 0,
    function( S, i )
    local   prj;
    
    prj := Objectify( NewKind( GeneralMappingsFamily( PermutationsFamily,
                                                      PermutationsFamily ),
                   IsProjectionSubdirectProductPermGroup ),
                   rec( component := i ) );
    SetSource( prj, S );
    return prj;
end );

#############################################################################
##
#M  Range( <prj> )  . . . . . . . . . . . . . . . . . . . . . . of projection
##
InstallMethod( Range, true, [ IsProjectionSubdirectProductPermGroup ], 0,
    prj -> Source( prj )!.groups[ prj!.component ] );

#############################################################################
##
#M  ImagesRepresentative( <prj>, <g> )  . . . . . . . . . . . . of projection
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsProjectionSubdirectProductPermGroup,
          IsMultiplicativeElementWithInverse ], 0,
    function( prj, g )
    return RestrictedPerm( g, Source( prj )!.news[ prj!.component ] )
           ^ ( Source( prj )!.perms[ prj!.component ] ^ -1 );
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
            phi1, phi2; # homomorphisms of components

    S := Source( prj );
    
    # get the homomorphism
    phi1 := S!.homomorphisms[1];
    phi2 := S!.homomorphisms[2];

    # compute the preimage
    if 1 = prj!.component  then
        elm := img                                    ^ S!.perms[1]
             * PreImagesRepresentative(phi2,img^phi1) ^ S!.perms[2];
    else
        elm := img                                    ^ S!.perms[2]
             * PreImagesRepresentative(phi1,img^phi2) ^ S!.perms[1];
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
    local   D,  i;
    
    D := Source( prj );
    i := 3 - prj!.component;
    return SubgroupNC( D, OnTuples
           ( GeneratorsOfGroup( KernelOfMultiplicativeGeneralMapping(
                                    D!.homomorphisms[ i ] ) ),
             D!.perms[ i ] ) );
end );

#############################################################################
##
#M  PrintObj( <prj> ) . . . . . . . . . . . . . . . . . . .  print projection
##
InstallMethod( PrintObj, true, [ IsProjectionSubdirectProductPermGroup ], 0,
    function( prj )
    Print( Ordinal( prj!.component ), " projection of ", Source( prj ) );
end );

#############################################################################
##
#M  WreathProduct( <G>, <H>, <alpha> )   wreath product of permutation groups
##
InstallMethod( WreathProduct, true,
        [ IsPermGroup, IsGroup, IsGroupHomomorphism ], 0,
    function( G, H, alpha )
    local   grp,        # wreath product of <G> and <H>, result
            gens,       # generators of the wreath product
            gen,        # one generator
            domG,       # domain of operation of <G>
            degG,       # degree of <G>
            I,          # image of <H> under <alpha>
            domI,       # domain of operation of <I>
            degI,       # degree of <I>
            shift,      # permutation permuting the blocks
            rans,       # list of arguments that have '.sCO.random'
            i, k, l;    # loop variables

    # get the domain of operation of <G>
    domG := MovedPoints( Parent( G ) );
    degG := Length( domG );

    # get the degree of the image of <H>
    I := Image( alpha, H );
    if not IsPermGroup( I )  then
        Error( "WreathProduct: image of <alpha> must be perm group" );
    fi;
    domI := MovedPoints( Parent( I ) );
    degI := Length( domI );

    # make the generators of the direct product of <deg> copies of <G>
    gens := [];
    for i  in [1..degI]  do
        shift := MappingPermListList( domG, [(i-1)*degG+1..i*degG] );
        for gen  in GeneratorsOfGroup( G )  do
            Add( gens, gen ^ shift );
        od;
    od;

    # add the generators of <I>
    if degG = 0 then degG := 1; fi;
    for gen  in GeneratorsOfGroup( I )  do
        shift := [];
        for i  in [1..degI]  do
            k := Position( domI, domI[i]^gen );
            for l  in [1..degG]  do
                shift[(i-1)*degG+l] := (k-1)*degG+l;
            od;
        od;
        Add( gens, PermList( shift ) );
    od;

    # make the group generated by those generators
    grp := GroupByGenerators( gens );

    # enter the size
    SetSize( grp, Size( G ) ^ degI * Size( I ) );

    # note random method
    rans := Filtered( [ G, H ], i ->
            IsBound( StabChainOptions( i ).random ) );
    if Length( rans ) > 0 then
        SetStabChainOptions( grp, rec( random :=
            Minimum( List( rans, i -> StabChainOptions( i ).random ) ) ) );
    fi;

    # return the group
    return grp;
end );

#############################################################################
##
#M  WreathProduct( <G>, <H> ) . . . . . wreath product with permutation group
##
InstallOtherMethod( WreathProduct, true, [ IsGroup, IsPermGroup ], 0,
function( G, H )
  return WreathProduct(G,H,IdentityMapping(H));
end);
        
#############################################################################
##
#F  WreathProductProductAction( <G>, <P> )   wreath product in product action
##
WreathProductProductAction := function( arg )
    local  W,  G,  P,  map,  I,  deg,  n,  N,  gens,  gen,  i,  list,
           p,  adic,  q,  Val,  val,  rans;
    
    G := arg[ 1 ];
    P := arg[ 2 ];
    if Length( arg ) = 3  then
        map := arg[ 3 ];
    else
	if IsPermGroup(P) then
	  map := IdentityMapping(P);
	else
	  map := OperationHomomorphism( P, P, OnRight );
        fi;
    fi;
    I := Image( map );
    if not IsPermGroup( I )  then
        Error( "WreathProduct: image of <alpha> must be perm group" );
    fi;
    
    deg := NrMovedPoints( Parent( G ) );
    n   := NrMovedPoints( Parent( I ) );
    N := deg ^ n;
    gens := [  ];
    for gen  in GeneratorsOfGroup( G )  do
        val := 1;
        for i  in [ 1 .. n ]  do
            Val := val * deg;
            list := [  ];
            for p  in [ 0 .. N - 1 ]  do
                q := QuoInt( p mod Val, val ) + 1;
                Add( list, p + ( q ^ gen - q ) * val );
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
                adic[ ( n - i ) ^ gen ] := p mod deg;
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
    W := GroupByGenerators( gens );
    SetSize( W, Size( G ) ^ n * Size( P ) );
    
    # note random method
    rans := Filtered( [ G, P ], i ->
            IsBound( StabChainOptions( i ).random ) );
    if Length( rans ) > 0 then
        SetStabChainOptions( W, rec( random :=
            Minimum( List( rans, i -> StabChainOptions( i ).random ) ) ) );
    fi;

    return W;
end;

#############################################################################

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
