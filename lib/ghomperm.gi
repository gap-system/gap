#############################################################################
##
#W  ghomperm.gi                 GAP library            UPol, ASer, MSch, HThe
##
#H  @(#)$Id$
##
Revision.ghomperm_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  AddGeneratorsGenimagesExtendSchreierTree( <S>, <newlabs>, <newlims> ) . .
##
AddGeneratorsGenimagesExtendSchreierTree := function( S, newlabs, newlims )
    local   old,        # genlabels before extension
            len,        # initial length of the orbit of <S>
            img,        # image during orbit algorithm
            i,  j;      # loop variables
    
    # Put in the new labels and labelimages.
    old := ShallowCopy( S.genlabels );
    UniteSet( S.genlabels, Length( S.labels ) + [ 1 .. Length( newlabs ) ] );
    Append( S.labels,      newlabs );  Append( S.generators,  newlabs );
    Append( S.labelimages, newlims );  Append( S.genimages,   newlims );
                          
    # Extend the orbit and the transversal with the new labels.
    len := Length( S.orbit );
    i := 1;
    while i <= Length( S.orbit )  do
        for j  in S.genlabels  do
            
            # Use new labels for old points, all labels for new points.
            if i > len  or  not j in old  then
                img := S.orbit[ i ] / S.labels[ j ];
                if not IsBound( S.translabels[ img ] )  then
                    S.translabels[ img ] := j;
                    S.transversal[ img ] := S.labels[ j ];
                    S.transimages[ img ] := S.labelimages[ j ];
                    
                    Add( S.orbit, img );
                fi;
            fi;
            
        od;
        i := i + 1;
    od;
end;

#############################################################################
##
#F  ImageSiftedBaseImage( <S>, <bimg>, <h> )   sift base image and find image
##
ImageSiftedBaseImage := function( S, bimg, img, opr )
    local   base;
    
    base := BaseStabChain( S );
    while bimg <> base  do
        while bimg[ 1 ] <> base[ 1 ]  do
            img  := opr     ( img,  S.transimages[ bimg[ 1 ] ] );
            bimg := OnTuples( bimg, S.transversal[ bimg[ 1 ] ] );
        od;
        S := S.stabilizer;
        base := base{ [ 2 .. Length( base ) ] };
        bimg := bimg{ [ 2 .. Length( bimg ) ] };
    od;
    return img;
end;

#############################################################################
##
#R  IsCoKernelGensIterator( <hom> ) . . . . iterator over cokernel generators
##
IsCoKernelGensIterator := NewRepresentation
    ( "IsCoKernelGensIterator", IsIterator and IsComponentObjectRep,
      [ "level", "pointNo", "genlabelNo", "levelNo", "base", "bimg", "img" ] );

#############################################################################
##
#F  CoKernelGensIterator( <hom> ) . . . . . . . . . . . . .  make this animal
##
CoKernelGensIterator := function( hom )
    local   S,  iter;
    
    S := StabChainAttr( hom );
    iter := Objectify
            ( NewKind( IteratorsFamily, IsCoKernelGensIterator ),
              rec( level := S,
                 pointNo := 1,
              genlabelNo := 1,
                 levelNo := 1,
                    base := BaseStabChain( S ) ) );
    iter!.img  := S.idimage;
    iter!.bimg := iter!.base;
    return iter;
end;

InstallMethod( IsDoneIterator, true,
        [ IsIterator and IsCoKernelGensIterator ], 0,
    iter -> IsEmpty( iter!.level.genlabels ) );

InstallMethod( NextIterator, true,
        [ IsIterator and IsCoKernelGensIterator ], 0,
    function( iter )
    local   gen,  stb,  bimg,  rep,  pnt,  img,  j,  k;
    
    # Make the current cokernel generator.
    stb := iter!.level;
    k := stb.genlabels[ iter!.genlabelNo ];
    gen := ImageSiftedBaseImage( stb,
                   OnTuples( iter!.bimg, stb.labels[ k ] ),
                   iter!.img * stb.labelimages[ k ], OnRight );
    
    # Move on the iterator: Next generator.
    iter!.genlabelNo := iter!.genlabelNo + 1;
    if iter!.genlabelNo > Length( stb.genlabels )  then
        iter!.genlabelNo := 1;
        
        # Next basic orbit point.
        iter!.pointNo := iter!.pointNo + 1;

        if iter!.pointNo > Length( stb.orbit )  then
            iter!.pointNo := 1;
            
            # Next level of the stabilizer chain.
            iter!.levelNo := iter!.levelNo + 1;
            iter!.level := stb.stabilizer;
            stb := iter!.level;
            
            # Return prematurely if the iterator is done.
            if IsEmpty( stb.genlabels )  then
                return gen;
            fi;
            
        fi;
        pnt := stb.orbit[ iter!.pointNo ];
        rep := [  ];
        img := stb.idimage;
        while pnt <> stb.orbit[ 1 ]  do
            Add( rep, stb.transversal[ pnt ] );
            img := LeftQuotient( stb.transimages[ pnt ], img );
            pnt := pnt ^ stb.transversal[ pnt ];
        od;
        bimg := iter!.base{ [ iter!.levelNo .. Length( iter!.base ) ] };
        for k  in Reversed( [ 1 .. Length( rep ) ] )  do
            for j  in [ 1 .. Length( bimg ) ]  do
                bimg[ j ] := bimg[ j ] / rep[ k ];
            od;
        od;
        iter!.img  := img;
        iter!.bimg := bimg;
        
    fi;
    
    return gen;
end );

#############################################################################
##
#F  CoKernelGensPermHom( <hom> )  . . . . . . . . generators for the cokernel
##
CoKernelGensPermHom := function( hom )
    local   C,  sch;

    C := [  ];
    for sch  in CoKernelGensIterator( hom )  do
        if not sch in C  then
            Add( C, sch );
        fi;
    od;
    return Difference( C, [ StabChainAttr( hom ).idimage ] );
end;

#############################################################################
##

#M  StabChainAttr( <hom> )  . . . . . . . . . . . . . . . for perm group homs
##
InstallOtherMethod( StabChainAttr, true,
        [ IsPermGroupGeneralMappingByImages ], 0,
    function( hom )
    local   S,
            rnd,        # list of random elements of '<hom>.source'
            rne,        # list of the images of the elements in <rnd>
            rni,        # index of the next random element to consider
            elm,        # one element in '<hom>.source'
            img,        # its image
            size,       # size of the stabilizer chain constructed so far
            stb,        # stabilizer in '<hom>.source'
            orb,        # orbit
            len,        # length of the orbit before extension
            bpt,        # base point
            two,        # power of two
            trivgens,   # trivial generators and their images, must be
            trivimgs,   #   entered into every level of the chain
            i,  j,  T;  # loop variables

    # start with the generators as random elements
    two := 16;
    rnd := ShallowCopy( hom!.generators );
    for i  in [Length(rnd)..two]  do
        Add( rnd, One( Source( hom ) ) );
    od;
    rne := ShallowCopy( hom!.genimages );
    for i  in [Length(rne)..two]  do
        Add( rne, One( Range( hom ) ) );
    od;
    rni := 1;

    # initialize the top level
    bpt := SmallestMovedPoint( Source( hom ) );
    if bpt = infinity  then
        bpt := 1;
    fi;
    S := EmptyStabChain( [  ], One( Source( hom ) ),
                         [  ], One( Range( hom ) ) );
    InsertTrivialStabilizer( S, bpt );
    
    # Extend  orbit and transversal. Store  images of the  identity for other
    # levels.
    AddGeneratorsGenimagesExtendSchreierTree( S,
            hom!.generators, hom!.genimages );
    trivgens := [  ];  trivimgs := [  ];
    for i  in [ 1 .. Length( hom!.generators ) ]  do
        if hom!.generators[ i ] = One( Source( hom ) )  then
            Add( trivgens, hom!.generators[ i ] );
            Add( trivimgs, hom!.genimages [ i ] );
        fi;
    od;

    # get the size of the stabilizer chain
    size := Length( S.orbit );

    # create new elements until we have reached the size
    while size <> Size( PreImagesRange( hom ) )  do

        # make a new element from the generators
        elm := rnd[rni];
        img := rne[rni];
        i := Random( [ 1 .. Length( hom!.generators ) ] );
        rnd[rni] := rnd[rni] * hom!.generators[i];
        rne[rni] := rne[rni] * hom!.genimages[i];
        rni := rni mod two + 1;

        # divide the element through the stabilizer chain
        stb := S;
        bpt := BasePoint( stb );
        while     bpt <> false
              and elm <> stb.identity
              and Length( stb.genlabels ) <> 0  do
            i := bpt ^ elm;
            if IsBound( stb.translabels[ i ] )  then
                while i <> bpt  do
                    img := img * stb.transimages[ i ];
                    elm := elm * stb.transversal[ i ];
                    i := bpt ^ elm;
                od;
                stb := stb.stabilizer;
                bpt := BasePoint( stb );
            else
                bpt := false;
            fi;
        od;

        # if the element was not in the stabilizer chain
        if elm <> One( Source( hom ) )  then

            # if this stabilizer is trivial add an new level
            if not IsBound( stb.stabilizer )  then
                InsertTrivialStabilizer( stb, SmallestMovedPointPerm(elm) );
                AddGeneratorsGenimagesExtendSchreierTree( stb,
                        trivgens, trivimgs );
            fi;

            # extend the Schreier trees above level `stb'
            T := S;
            repeat
                T := T.stabilizer;
                size := size / Length( T.orbit );
                AddGeneratorsGenimagesExtendSchreierTree( T, [elm], [img] );
                size := size * Length( T.orbit );
            until T.orbit[ 1 ] = stb.orbit[ 1 ];

        fi;

    od;
    
    return S;
end );

#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <hom> ) . . . for perm group homs
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    true, [ IsPermGroupGeneralMappingByImages ], 0,
    function( hom )
    return NormalClosure( Image( hom ), SubgroupNC
                   ( Range( hom ), CoKernelGensPermHom( hom ) ) );
end );

#############################################################################
##
#M  IsSingleValued( <hom> ) . . . . . . . . . . . . . . . for perm group homs
##
InstallMethod( IsSingleValued, true,
        [ IsPermGroupGeneralMappingByImages ], 0,
    function( hom )
    local   sch;
    
    for sch in CoKernelGensIterator( hom )  do
        if sch <> One( sch )  then
            return false;
        fi;
    od;
    return true;
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . for perm group homs
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsPermGroupGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   S;
    
    if not ( HasIsTotal( hom ) and IsTotal( hom ) )
       and not elm in PreImagesRange( hom )  then
        return fail;
    else
        S := StabChainAttr( hom );
        return ImageSiftedBaseImage( S, OnTuples( BaseStabChain( S ), elm ),
                       S.idimage, OnRight ) ^ -1;
    fi;
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . for perm group homs
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsPermGroupGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    return ImagesRepresentative( Inverse( hom ), elm );
end );

#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> ) . . . . . . . . for perm group homs
##
InstallMethod( CompositionMapping2, FamSource1EqFamRange2,
        [ IsGroupHomomorphism,
          IsPermGroupGeneralMappingByImages and IsGroupHomomorphism ], 0,
    function( hom1, hom2 )
    local   prd,  stb;

    stb := EmptyStabChain( [  ], One( Range( hom1 ) ) );
    ConjugateStabChain( StabChainAttr( hom2 ), stb, hom1, () );
    prd := GroupHomomorphismByImages( Source( hom2 ), Range( hom1 ),
                   stb.labels{ [ 2 .. Length( stb.labels ) ] },
                   stb.labelimages{ [ 2 .. Length( stb.labels ) ] } );
    SetStabChain( prd, stb );
    return prd;
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . .  for perm group range
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsToPermGroupGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    return ImagesRepresentative( Inverse( hom ), elm );
end );

#############################################################################
##

#F  StabChainPermGroupToPermGroupGeneralMappingByImages( <hom> )  . . . local
##
StabChainPermGroupToPermGroupGeneralMappingByImages := function( hom )
    local   options,    # options record for stabilizer construction
            n,  
            k,
            i,
            longgens,
            longgroup,
            conperm,
            conperminv;
    
    if IsTrivial( PreImagesRange( hom ) )
       then n := 0;
       else n := LargestMovedPoint( PreImagesRange( hom ) );  fi;
    if IsTrivial( ImagesSource( hom ) )
       then k := 0;
       else k := LargestMovedPoint( ImagesSource( hom ) );  fi;
    
    # collect info for options
    options := rec();
    
    # random or deterministic
    if   IsBound( StabChainOptions( Parent( Source( hom ) ) ).random )  then
        options.randomSource :=
          StabChainOptions( Parent( Source( hom ) ) ).random;
    elif IsBound( StabChainOptions( Source( hom ) ).random )  then
        options.randomSource := StabChainOptions( Source( hom ) ).random;
    elif IsBound( StabChainOptions( PreImagesRange( hom ) ).random )  then
        options.randomSource := StabChainOptions( PreImagesRange( hom ) ).random;
    else
        options.randomSource := DefaultStabChainOptions.random;
    fi;
    if   IsBound( StabChainOptions( Parent( Range( hom ) ) ).random )  then
        options.randomRange :=
          StabChainOptions( Parent( Range( hom ) ) ).random;
    elif IsBound( StabChainOptions( Range( hom ) ).random )  then
        options.randomRange := StabChainOptions( Range( hom ) ).random;
    elif IsBound( StabChainOptions( ImagesSource( hom ) ).random )  then
        options.randomRange := StabChainOptions( ImagesSource( hom ) ).random;
    else
        options.randomRange := DefaultStabChainOptions.random;
    fi;
    options.random := Minimum(options.randomSource,options.randomRange);

    # if IsMapping, try to extract info from source
    if Tester( IsMapping )( hom )  and  IsMapping( hom )  then
        if   HasSize( Source( hom ) )  then
            options.size := Size( Source( hom ) );
        elif HasSize( PreImagesRange( hom ) )  then
            options.size := Size( PreImagesRange( hom ) );
        fi;
        if not IsBound( options.size )
           and HasSize( Parent( Source( hom ) ) )  then
            options.limit := Size( Parent( Source( hom ) ) );
        fi;
        if   IsBound( StabChainOptions( Source( hom ) ).knownBase )  then
            options.knownBase := StabChainOptions( Source( hom ) ).knownBase;
        elif IsBound( StabChainOptions( PreImagesRange( hom ) ).knownBase )  then
            options.knownBase := StabChainOptions( PreImagesRange( hom ) ).knownBase;
        elif HasBase( Source( hom ) )  then
            options.knownBase := Base( Source( hom ) );
        elif HasBase( PreImagesRange( hom ) )  then
            options.knownBase := Base( PreImagesRange( hom ) );
        elif IsBound( StabChainOptions( Parent( Source( hom ) ) ).knownBase )
          then
            options.knownBase :=
              StabChainOptions( Parent( Source( hom ) ) ).knownBase;
        elif HasBase( Parent( Source( hom ) ) )  then
            options.knownBase := Base( Parent( Source( hom ) ) );
        fi;

    # if not IsMapping, settle for less
    else
        if   HasSize( Source( hom ) )  then
            options.limitSource := Size( Source( hom ) );
        elif HasSize( PreImagesRange( hom ) )  then
            options.limitSource := Size( PreImagesRange( hom ) );
        elif HasSize( Parent( Source( hom ) ) )  then
            options.limitSource := Size( Parent( Source( hom ) ) );
        fi;
        if   IsBound( StabChainOptions( Source( hom ) ).knownBase )  then
            options.knownBaseSource :=
              StabChainOptions( Source( hom ) ).knownBase;
        elif IsBound( StabChainOptions( PreImagesRange( hom ) ).knownBase )  then
            options.knownBaseSource :=
              StabChainOptions( PreImagesRange( hom ) ).knownBase;
        elif IsBound( StabChainOptions( Parent( Source( hom ) ) ).knownBase )
          then
            options.knownBaseSource :=
                StabChainOptions( Parent( Source( hom ) ) ).knownBase;
        fi;

        # if we have info about source, try to collect info about range
        if IsBound( options.limitSource ) then 
            if   HasSize( Range( hom ) )  then
                options.limitRange := Size( Range( hom ) );
            elif HasSize( ImagesSource( hom ) )  then
                options.limitRange := Size( ImagesSource( hom ) );
            elif HasSize( Parent( Range( hom ) ) )  then
                options.limitRange := Size( Parent( Range( hom ) ) );
            fi;
            if IsBound( options.limitRange ) then 
                options.limit := options.limitSource * options.limitRange;
            fi;
        fi;
        if IsBound( options.knownBaseRange ) then 
            if   IsBound( StabChainOptions( Range( hom ) ).knownBase )  then
                options.knownBaseRange :=
                  StabChainOptions( Range( hom ) ).knownBase;
            elif IsBound( StabChainOptions( PreImagesRange( hom ) ).knownBase )  then
                options.knownBaseRange :=
                  StabChainOptions( PreImagesRange( hom ) ).knownBase;
            elif IsBound( StabChainOptions( Parent( Range( hom ) ) )
                    .knownBase )
              then
                options.knownBaseRange :=
                    StabChainOptions( Parent( Range( hom ) ) ).knownBase;
            fi;
            if IsBound( options.knownBaseRange ) then 
                options.knownBase := Union( options.knownBaseSource,
                                            options.knownBaseRange + n );
            fi;
        fi;

    fi; # if IsMapping

    options.base := [1..n];

    # create concatenation of perms in hom.generators, hom.genimages
    longgens := [];
    conperm := MappingPermListList([1..k],[n+1..n+k]);
    conperminv := conperm^(-1);
    for i in [1..Length(hom!.generators)] do
        longgens[i] := hom!.generators[i] * (hom!.genimages[i] ^ conperm); 
    od;
    longgroup :=  Group(longgens,());
    MakeStabChainLong( hom, StabChainOp( longgroup, options ),
           [ 1 .. n ], (), conperminv, hom,
           CoKernelOfMultiplicativeGeneralMapping );
    
    if    not HasInverse( hom )
       or not HasStabChain( Inverse( hom ) )
       or not HasKernelOfMultiplicativeGeneralMapping( hom )  then
        MakeStabChainLong( Inverse( hom ),
                StabChainOp( longgroup, [ n + 1 .. n + k ] ),
                [ n + 1 .. n + k ], conperminv, (), hom,
                KernelOfMultiplicativeGeneralMapping );
    fi;
    
    return StabChainAttr( hom );
end;

#############################################################################
##
#F  MakeStabChainLong( ... )  . . . . . . . . . . . . . . . . . . . . . local
##
MakeStabChainLong := function( hom, stb, ran, c1, c2, cohom, cokername )
    local   newlevs,  S,  i,  len,  rest,  p;
    
    # Construct the stabilizer chain for <hom>.
    S := DeepCopy( stb );
    SetStabChain( hom, S );
    newlevs := [  ];
    repeat
        len := Length( stb.labels );
        if len = 0  or  IsPerm( stb.labels[ len ] )  then
            Add( stb.labels, rec( labels := [  ], labelimages := [  ] ) );
            len := len + 1;
            for i  in [ 1 .. len - 1 ]  do
                rest := RestrictedPerm( stb.labels[ i ], ran );
                Add( stb.labels[ len ].labels, rest ^ c1 );
                Add( stb.labels[ len ].labelimages,
                     LeftQuotient( rest, stb.labels[ i ] ) ^ c2 );
            od;
            Add( newlevs, stb.labels );
        fi;
        S.labels      := stb.labels[ len ].labels;
        S.labelimages := stb.labels[ len ].labelimages;
        S.generators  := S.labels{ S.genlabels };
        S.genimages   := S.labelimages{ S.genlabels };
        S.idimage     := ();
        if BasePoint( stb ) in ran  then
            S.orbit := stb.orbit - ran[ 1 ] + 1;
            S.translabels := [  ];
            S.translabels{ S.orbit } := stb.translabels{ stb.orbit };
            S.transversal := [  ];
            S.transimages := [  ];
            S.transversal[ S.orbit[ 1 ] ] := S.identity;
            S.transimages[ S.orbit[ 1 ] ] := S.idimage;
            for i  in [ 2 .. Length( S.orbit ) ]  do
                p := S.orbit[ i ];
                S.transversal[ p ] := S.labels     [ S.translabels[ p ] ];
                S.transimages[ p ] := S.labelimages[ S.translabels[ p ] ];
            od;
            S := S.stabilizer;
            stb := stb.stabilizer;
        else
            RemoveStabChain( S );
            S.labelimages := [  ];
            S := false;
        fi;
    until S = false;
    for S  in newlevs  do
        Unbind( S[ Length( S ) ] );
    od;
    
    # Construct the cokernel.
    if Length( stb.genlabels ) <> 0  then
        if not Tester( cokername )( cohom )  then
            S := EmptyStabChain( [  ], () );
            ConjugateStabChain( stb, S, c2, c2 );
            Setter( cokername )
              ( cohom, GroupStabChain( Range( hom ), S, true ) );
        fi;
    else 
        Setter( cokername )( cohom, TrivialSubgroup( Range( hom ) ) );
    fi;
    
end;

#############################################################################
##
#M  StabChainAttr( <hom> )  . . . . . . . . . . . for perm to perm group homs
##
InstallMethod( StabChainAttr, true,
        [ IsPermGroupGeneralMappingByImages and
          IsToPermGroupGeneralMappingByImages ], 0,
        StabChainPermGroupToPermGroupGeneralMappingByImages );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping(<hom>) . for perm to perm group homs
##
InstallMethod( KernelOfMultiplicativeGeneralMapping, true,
        [ IsPermGroupGeneralMappingByImages and
          IsToPermGroupGeneralMappingByImages ], 0,
    function( hom )
    StabChainPermGroupToPermGroupGeneralMappingByImages( hom );
    return KernelOfMultiplicativeGeneralMapping( hom );
end );

#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping(<hom>) for perm to perm group homs
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping, true,
        [ IsPermGroupGeneralMappingByImages and
          IsToPermGroupGeneralMappingByImages ], 0,
    function( hom )
    StabChainPermGroupToPermGroupGeneralMappingByImages( hom );
    return CoKernelOfMultiplicativeGeneralMapping( hom );
end );

#############################################################################
##

#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . for const hom
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsConstituentHomomorphism, IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   D;

    D := Enumerator( hom!.externalSet );
    if Length( D ) = 0  then
        return ();
    else 
        return PermList( OnTuples( [ 1 .. Length( D ) ],
                       elm ^ hom!.conperm ) );
    fi;
end );

#############################################################################
##
#M  ImagesSet( <hom>, <H> ) . . . . . . . . . . . . . . . . . . for const hom
##
InstallMethod( ImagesSet, CollFamSourceEqFamElms,
        [ IsConstituentHomomorphism, IsPermGroup ], 0,
    function( hom, H )
    local   D,  I;
    
    D := Enumerator( hom!.externalSet );
    I := EmptyStabChain( [  ], One( Range( hom ) ) );
    RemoveStabChain( ConjugateStabChain( StabChainOp( H, D ), I,
            hom, hom!.conperm,
            S -> BasePoint( S ) <> false
             and BasePoint( S ) in D ) );
    return GroupStabChain( Range( hom ), I, true );
end );

InstallMethod( ImagesSource, true, [ IsConstituentHomomorphism ], 0,
    hom -> ImagesSet( hom, Source( hom ) ) );

#############################################################################
##
#M  PreImagesSet( <hom>, <I> )  . . . . . . . . . . . . . . . . for const hom
##
InstallMethod( PreImagesSet, CollFamRangeEqFamElms,
        [ IsConstituentHomomorphism, IsPermGroup ], 0,
    function( hom, I )
    local   H,          # preimage of <I>, result
            K,          # kernel of <hom>
            S,  T,  name;

    # compute the kernel of <hom>
    K := KernelOfMultiplicativeGeneralMapping( hom );

    # create the preimage group
    H := EmptyStabChain( [  ], One( Source( hom ) ) );
    S := ConjugateStabChain( StabChainAttr( I ), H, x ->
                 PreImagesRepresentative( hom, x ), hom!.conperm ^ -1 );
    T := H;
    while IsBound( T.stabilizer )  do
        AddGeneratorsExtendSchreierTree( T, GeneratorsOfGroup( K ) );
        T := T.stabilizer;
    od;
        
    # append the kernel to the stabilizer chain of <H>
    K := StabChainAttr( K );
    for name  in RecNames( K )  do
        S.( name ) := K.( name );
    od;
    
    return GroupStabChain( Source( hom ), H, true );
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . for const hom
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    true, [ IsConstituentHomomorphism ], 0,
    function( hom )
    return Stabilizer( Source( hom ), Enumerator( hom!.externalSet ),
                   OnTuples );
end );

#############################################################################
##

#M  StabChainAttr( <hom> )  . . . . . . . . . . . . . . . . .  for blocks hom
##
InstallMethod( StabChainAttr, true, [ IsBlocksHomomorphism ], 0,
    function( hom )
    local   img;
    
    img := ImageKernelBlocksHomomorphism( hom, Source( hom ) );
    if not HasImagesSource( hom )  then
        SetImagesSource( hom, img );
    fi;
    return StabChainAttr( hom );
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . .  for blocks hom
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsBlocksHomomorphism, IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   img,  D,  i;
    
    D := Enumerator( hom!.externalSet );
    
    # make the image permutation as a list
    img := [  ];
    for i  in [ 1 .. Length( D ) ]  do
        img[ i ] := hom!.reps[ D[ i ][ 1 ] ^ elm ];
    od;

    # return the image as a permutation
    return PermList( img );
end );

#############################################################################
##
#F  ImageKernelBlocksHomomorphism( <hom>, <H> ) . . . . . .  image and kernel
##
ImageKernelBlocksHomomorphism := function( hom, H )
    local   D,          # the block system
            I,          # image of <H>, result
            S,          # block stabilizer in <H>
            T,          # corresponding stabilizer in <I>
            full,       # flag: true if <H> is (identical to) the source
            B,          # current block
            i,  j;      # loop variables
    
    D := Enumerator( hom!.externalSet );
    S := DeepCopy( StabChainAttr( H ) );
    full := IsIdentical( H, Source( hom ) );
    if full  then
        SetStabChain( hom, S );
    fi;
    I := EmptyStabChain( [  ], One( Range( hom ) ) );
    T := I;

    # loop over the blocks
    for i  in [ 1 .. Length( D ) ]  do
        B := D[ i ];

        # if <S> does not already stabilize this block
        if ForAny( S.generators, gen -> hom!.reps[ B[ 1 ] ^ gen ] <> i )
           then
            ChangeStabChain( S, [ B[ 1 ] ] );

            # Make the next level of <T> and go down to `<T>.stabilizer'.
            T := ConjugateStabChain( S, T, hom, hom!.reps,
                         S -> BasePoint( S ) = B[ 1 ] );

            # Make <S> the stabilizer of the block <B>.
            InsertTrivialStabilizer( S.stabilizer, B[ 1 ] );
            j := 1;
            while                                j < Length( B )
                  and Length( S.stabilizer.orbit ) < Length( B )  do
                j := j + 1;
                if IsBound( S.translabels[ B[ j ] ] )  then
                    AddGeneratorsExtendSchreierTree( S.stabilizer,
                            [ InverseRepresentative( S, B[ j ] ) ] );
                fi;
            od;
            S := S.stabilizer;
                    
        fi;
    od;

    # if <H> is the full group this also gives us the kernel
    if full  and  not HasKernelOfMultiplicativeGeneralMapping( hom )  then
        SetKernelOfMultiplicativeGeneralMapping( hom,
            GroupStabChain( Source( hom ), S, true ) );
    fi;
    
    return GroupStabChain( Range( hom ), I, true );
end;

#############################################################################
##
#M  ImagesSet( <hom>, <H> ) . . . . . . . . . . . . . . . . .  for blocks hom
##
InstallMethod( ImagesSet, CollFamSourceEqFamElms,
        [ IsBlocksHomomorphism, IsPermGroup ], 0,
    ImageKernelBlocksHomomorphism );

InstallMethod( ImagesSource, true, [ IsBlocksHomomorphism ], 0,
    hom -> ImagesSet( hom, Source( hom ) ) );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . .  for blocks hom
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsBlocksHomomorphism, IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   D,          # the block system
            pre,        # preimage of <elm>, result
            S,          # stabilizer in chain of <hom>
            B,          # the image block <B>
            b,          # number of image block <B>
            pos;        # position of point hit by preimage
    
    D := Enumerator( hom!.externalSet );
    S := StabChainAttr( hom );
    pre := One( Source( hom ) );

    # loop over the blocks and their iterated set stabilizers
    while Length( S.genlabels ) <> 0  do

        # Find the image block <B> of the current block.
        b := hom!.reps[ S.orbit[ 1 ] ] ^ elm;
        if b > Length( D )  then
            return fail;
        fi;
        B := D[ b ];
        
        # Find a point in <B> that can be hit by the preimage.
        pos := PositionProperty( B, pnt ->
                       IsBound( S.translabels[ pnt/pre ] ) );
        if pos = fail  then
            return fail;
        else
            pre := LeftQuotient( InverseRepresentative( S, B[ pos ] / pre ),
                           pre );
        fi;
        
        S := S.stabilizer;
    od;

    # return the preimage
    return pre;
end );

#############################################################################
##
#M  PreImagesSet( <hom>, <I> )  . . . . . . . . . . . . . . .  for blocks hom
##
InstallMethod( PreImagesSet, CollFamRangeEqFamElms,
        [ IsBlocksHomomorphism, IsPermGroup ], 0,
    function( hom, I )
    local   H;          # preimage of <I> under <hom>, result
    
    H := PreImageSetStabBlocksHomomorphism( hom, StabChainAttr( I ) );
    return GroupStabChain( Source( hom ), H, true );
end );

#############################################################################
##
#F  PreImageSetStabBlocksHomomorphism( <hom>, <I> ) . . .  recursive function
##
PreImageSetStabBlocksHomomorphism := function( hom, I )
    local   H,          # preimage of <I> under <hom>, result
            pnt,        # rep. of the block that is the basepoint <I>
            l,          # one genlabel of <I>
            pre;        # a representative of its preimages

    # if <I> is trivial then preimage is the kernel of <hom>
    if Length( I.genlabels ) = 0  then
        H := DeepCopy( StabChainAttr(
                 KernelOfMultiplicativeGeneralMapping( hom ) ) );

    # else begin with the preimage $H_{block[i]}$ of the stabilizer  $I_{i}$,
    # adding preimages of the generators of  $I$  to those of  $H_{block[i]}$
    # gives us generators for $H$. Because $H_{block[i][1]} \<= H_{block[i]}$
    # the stabilizer chain below $H_{block[i][1]}$ is already complete, so we
    # only have to care about the top level with the basepoint $block[i][1]$.
    else
        pnt := Enumerator( hom!.externalSet )[ I.orbit[ 1 ] ][ 1 ];
        H := PreImageSetStabBlocksHomomorphism( hom, I.stabilizer );
        ChangeStabChain( H, [ pnt ], false );
        for l  in I.genlabels  do
            pre := PreImagesRepresentative( hom, I.labels[ l ] );
            if not IsBound( H.transversal[ pnt ^ pre ] )  then
                AddGeneratorsExtendSchreierTree( H, [ pre ] );
            fi;
        od;
    fi;

    # return the preimage
    return H;
end;

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . .  for blocks hom
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    true,
    [ IsBlocksHomomorphism ], 0,
    function( hom )
    local   img;
    
    img := ImageKernelBlocksHomomorphism( hom, Source( hom ) );
    if not HasImagesSource( hom )  then
        SetImagesSource( hom, img );
    fi;
    return KernelOfMultiplicativeGeneralMapping( hom );
end );

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  ghomperm.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

