#############################################################################
##
#W  ghomperm.gi                 GAP library       Akos Seress, Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.ghomperm_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  AddGeneratorsGenimagesExtendSchreierTree( <S>, <newlabs>, <newlims> ) . .
##
InstallGlobalFunction( AddGeneratorsGenimagesExtendSchreierTree,
    function( S, newlabs, newlims )
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
end );

#############################################################################
##
#F  ImageSiftedBaseImage( <S>, <bimg>, <h> )   sift base image and find image
##
InstallGlobalFunction( ImageSiftedBaseImage, function( S, bimg, img, opr )
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
end );

#############################################################################
##
#R  IsCoKernelGensIteratorRep . . . . . . . iterator over cokernel generators
##
DeclareRepresentation( "IsCoKernelGensIteratorRep",
    IsComponentObjectRep,
    [ "level", "pointNo", "genlabelNo", "levelNo", "base", "bimg", "img" ] );

#############################################################################
##
#F  CoKernelGensIterator( <hom> ) . . . . . . . . . . . . .  make this animal
##
InstallGlobalFunction( CoKernelGensIterator, function( hom )
    local   S,  iter;
    
    S := StabChainMutable( hom );
    iter := Objectify
            ( NewType( IteratorsFamily,
                           IsIterator
                       and IsMutable
                       and IsCoKernelGensIteratorRep ),
              rec( level := S,
                 pointNo := 1,
              genlabelNo := 1,
                 levelNo := 1,
                    base := BaseStabChain( S ) ) );
    iter!.img  := S.idimage;
    iter!.bimg := iter!.base;
    return iter;
end );

InstallMethod( IsDoneIterator,
    "for `IsCoKernelGensIteratorRep'",
    true,
    [ IsIterator and IsCoKernelGensIteratorRep ], 0,
    iter -> IsEmpty( iter!.level.genlabels ) );

InstallMethod( NextIterator,
    "for `IsCoKernelGensIteratorRep'",
    true,
    [ IsIterator and IsMutable and IsCoKernelGensIteratorRep ], 0,
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

InstallMethod( ShallowCopy,
    "for `IsCoKernelGensIteratorRep'",
    true,
    [ IsIterator and IsCoKernelGensIteratorRep ], 0,
    function( iter )
    iter:= Objectify( Subtype( TypeObj( iter ), IsMutable ),
                rec( level      := StructuralCopy( iter!.level ),
                     pointNo    := iter!.pointNo,
                     genlabelNo := iter!.genlabelNo,
                     levelNo    := iter!.levelNo,
                     base       := ShallowCopy( iter!.base ),
                     img        := iter!.img ) );
    iter!.bimg:= iter!.base;
#T what is this good for??
    return iter;
    end );


#############################################################################
##
#F  CoKernelGensPermHom( <hom> )  . . . . . . . . generators for the cokernel
##
InstallGlobalFunction( CoKernelGensPermHom, function( hom )
    local   C,  sch;

    C := [  ];
    for sch  in CoKernelGensIterator( hom )  do
      if not (sch=One(sch) or sch in C) then
	Add( C, sch );
      fi;
    od;
    return C;
end );

#############################################################################
##
#M  StabChainMutable( <hom> ) . . . . . . . . . . . . . . for perm group homs
##
InstallOtherMethod( StabChainMutable, "perm mapping by images",  true,
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
            bpt,        # base point
            two,        # power of two
            trivgens,   # trivial generators and their images, must be
            trivimgs,   #   entered into every level of the chain
            i, T;  # loop variables

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
                InsertTrivialStabilizer( stb, SmallestMovedPoint(elm) );
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
  if not CanComputeSizeAnySubgroup(Range(hom)) then
    TryNextMethod();
  fi;
  return NormalClosure( ImagesSource( hom ), SubgroupNC
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
        S := StabChainMutable( hom );
        S := ImageSiftedBaseImage( S, OnTuples( BaseStabChain( S ), elm ),
                       S.idimage, OnRight ) ^ -1;
	if IsPerm(S) then TRIM_PERM(S,LargestMovedPoint(Range(hom))); fi;
	return S;
    fi;
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . for perm group homs
##
#T This method is quite stupid (there is another installation of a similar
#T method in the generic code) and interferes with better code for to Pc group
#T homomorphisms. Disabled. AH
#InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
#        [ IsPermGroupGeneralMappingByImages,
#          IsMultiplicativeElementWithInverse ], 0,
#    function( hom, elm )
#    return ImagesRepresentative( InverseGeneralMapping( hom ), elm );
#end );

#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> ) . . . . . . . . for perm group homs
##
InstallMethod( CompositionMapping2, "group hom. with perm group hom.",
  FamSource1EqFamRange2, [ IsGroupHomomorphism,
          IsPermGroupGeneralMappingByImages and IsGroupHomomorphism ], 0,
    function( hom1, hom2 )
    local   prd,  stb,  levs,  S;

    stb := StructuralCopy( StabChainMutable( hom2 ) );
    levs := [  ];
    S := stb;
    while IsBound( S.stabilizer )  do
        S.idimage := One( Range( hom1 ) );
        if not ForAny( levs, lev -> IsIdenticalObj( lev, S.labelimages ) )  then
            Add( levs, S );
            S.labelimages := List( S.labelimages, g ->
                                   ImagesRepresentative( hom1, g ) );
        fi;
        S.generators  := S.labels     { S.genlabels };
        S.genimages   := S.labelimages{ S.genlabels };
        S.transimages := [  ];
        S.transimages{ S.orbit } := S.labelimages{ S.translabels{ S.orbit } };
        S := S.stabilizer;
    od;
    prd := GroupHomomorphismByImagesNC( Source( hom2 ), Range( hom1 ),
                   stb.generators, stb.genimages );
    SetStabChainMutable( prd, stb );
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
    return ImagesRepresentative( InverseGeneralMapping( hom ), elm );
end );

#############################################################################
##
#F  StabChainPermGroupToPermGroupGeneralMappingByImages( <hom> )  . . . local
##
InstallGlobalFunction( StabChainPermGroupToPermGroupGeneralMappingByImages,
    function( hom )
    local   options,    # options record for stabilizer construction
            n,  
            k,
            i,
            longgens,
            longgroup,
            conperm,
            conperminv,
            op;
    
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
        elif IsBound( StabChainOptions( PreImagesRange( hom ) ).knownBase )
          then
            options.knownBase := StabChainOptions( PreImagesRange( hom ) ).
                                 knownBase;
        elif HasBaseOfGroup( Source( hom ) )  then
            options.knownBase := BaseOfGroup( Source( hom ) );
        elif HasBaseOfGroup( PreImagesRange( hom ) )  then
            options.knownBase := BaseOfGroup( PreImagesRange( hom ) );
        elif IsBound( StabChainOptions( Parent( Source( hom ) ) ).knownBase )
          then
            options.knownBase :=
              StabChainOptions( Parent( Source( hom ) ) ).knownBase;
        elif HasBaseOfGroup( Parent( Source( hom ) ) )  then
            options.knownBase := BaseOfGroup( Parent( Source( hom ) ) );
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
        elif IsBound( StabChainOptions( PreImagesRange( hom ) ).knownBase )
          then
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
            elif IsBound( StabChainOptions( PreImagesRange( hom ) ).
                    knownBase )  then
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
    longgroup :=  GroupByGenerators( longgens, () );
    for op  in [ PreImagesRange, ImagesSource ]  do
        if      HasIsSolvableGroup( op( hom ) )
           and not IsSolvableGroup( op( hom ) )  then
            SetIsSolvableGroup( longgroup, false );
            break;
        fi;
    od;

    MakeStabChainLong( hom, StabChainOp( longgroup, options ),
           [ 1 .. n ], (), conperminv, hom,
           CoKernelOfMultiplicativeGeneralMapping );
    
    if    not HasInverseGeneralMapping( hom )
       or not HasStabChainMutable( InverseGeneralMapping( hom ) )
       or not HasKernelOfMultiplicativeGeneralMapping( hom )  then
        MakeStabChainLong( InverseGeneralMapping( hom ),
                StabChainOp( longgroup, [ n + 1 .. n + k ] ),
                [ n + 1 .. n + k ], conperminv, (), hom,
                KernelOfMultiplicativeGeneralMapping );
    fi;

    return StabChainMutable( hom );
end );

#############################################################################
##
#F  MakeStabChainLong( ... )  . . . . . . . . . . . . . . . . . . . . . local
##
InstallGlobalFunction( MakeStabChainLong,
    function( hom, stb, ran, c1, c2, cohom, cokername )
    local   newlevs,  S,  i,  len,  rest,  trans;
    
    # Construct the stabilizer chain for <hom>.
    S := CopyStabChain( stb );
    SetStabChainMutable( hom, S );
    newlevs := [  ];
    repeat
        len := Length( S.labels );
        if len = 0  or  IsPerm( S.labels[ len ] )  then
            Add( S.labels, rec( labels := [  ], labelimages := [  ] ) );
            len := len + 1;
            for i  in [ 1 .. len - 1 ]  do
                rest := RestrictedPerm( S.labels[ i ], ran );
                Add( S.labels[ len ].labels, rest ^ c1 );
                Add( S.labels[ len ].labelimages,
                     LeftQuotient( rest, S.labels[ i ] ) ^ c2 );
            od;
            Add( newlevs, S.labels );
        fi;
        S.labels{ [ 1 .. len - 1 ] } := S.labels[ len ].labels;
        S.labelimages := S.labels[ len ].labelimages;
        S.generators  := S.labels{ S.genlabels };
        S.genimages   := S.labelimages{ S.genlabels };
        S.idimage     := ();
        if BasePoint( S ) in ran  then
            trans := S.translabels{ S.orbit };
            S.orbit := S.orbit - ran[ 1 ] + 1;
            S.translabels := [  ];
            S.translabels{ S.orbit } := trans;
            S.transversal := [  ];
            S.transversal{ S.orbit } := S.labels{ trans };
            S.transimages := [  ];
            S.transimages{ S.orbit } := S.labelimages{ trans };
            S := S.stabilizer;
            stb := stb.stabilizer;
        else
            RemoveStabChain( S );
	    S.genimages:=[];
            S.labelimages := [  ];
            S := false;
        fi;
    until S = false;
    for S  in newlevs  do
        Unbind( S[ Length( S ) ] );
    od;
    
    # Construct the cokernel.
    if not IsEmpty( stb.genlabels )  then
        if not Tester( cokername )( cohom )  then
            S := EmptyStabChain( [  ], () );
            ConjugateStabChain( stb, S, c2, c2 );
            Setter( cokername )
              ( cohom, GroupStabChain( Range( hom ), S, true ) );
        fi;
    else 
        Setter( cokername )( cohom, TrivialSubgroup( Range( hom ) ) );
    fi;
    
end );

#############################################################################
##
#M  StabChainMutable( <hom> ) . . . . . . . . . . for perm to perm group homs
##
InstallMethod( StabChainMutable, "perm to perm mapping by images",true,
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
InstallMethod( ImagesRepresentative,"Constituent homomorphism",
  FamSourceEqFamElm,
        [ IsConstituentHomomorphism, IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   D;

    D := Enumerator( UnderlyingExternalSet( hom ) );
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
InstallMethod( ImagesSet,"constituent homomorphism", CollFamSourceEqFamElms,
	# this method should *not* be applied if the group to be mapped has
	# no stabilizer chain (for example because it is very big).
        [ IsConstituentHomomorphism, IsPermGroup and HasStabChainMutable], 0,
    function( hom, H )
    local   D,  I;
    
    D := Enumerator( UnderlyingExternalSet( hom ) );
    I := EmptyStabChain( [  ], One( Range( hom ) ) );
    RemoveStabChain( ConjugateStabChain( StabChainOp( H, D ), I,
            hom, hom!.conperm,
            S -> BasePoint( S ) <> false
             and BasePoint( S ) in D ) );
    return GroupStabChain( Range( hom ), I, true );
end );

#############################################################################
##
#M  PreImagesSet( <hom>, <I> )  . . . . . . . . . . . . . . . . for const hom
##
InstallMethod( PreImagesSet, "constituent homomorphism",CollFamRangeEqFamElms,
        [ IsConstituentHomomorphism, IsPermGroup ], 0,
    function( hom, I )
    local   H,          # preimage of <I>, result
            K,          # kernel of <hom>
            S,  T,  name;

    # compute the kernel of <hom>
    K := KernelOfMultiplicativeGeneralMapping( hom );

    # create the preimage group
    H := EmptyStabChain( [  ], One( Source( hom ) ) );
    S := ConjugateStabChain( StabChainMutable( I ), H, x ->
                 PreImagesRepresentative( hom, x ), hom!.conperm ^ -1 );
    T := H;
    while IsBound( T.stabilizer )  do
        AddGeneratorsExtendSchreierTree( T, GeneratorsOfGroup( K ) );
        T := T.stabilizer;
    od;
        
    # append the kernel to the stabilizer chain of <H>
    K := StabChainMutable( K );
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
    "for constituent homomorphism",
    true, [ IsConstituentHomomorphism ], 0,
    function( hom )
    return Stabilizer( Source( hom ), Enumerator( UnderlyingExternalSet( hom ) ),
                   OnTuples );
end );

#############################################################################
##

#M  StabChainMutable( <hom> ) . . . . . . . . . . . . . . . .  for blocks hom
##
InstallMethod( StabChainMutable,
    "for blocks homomorphism",
    true, [ IsBlocksHomomorphism ], 0,
    function( hom )
    local   img;
    
    img := ImageKernelBlocksHomomorphism( hom, Source( hom ) );
    if not HasImagesSource( hom )  then
        SetImagesSource( hom, img );
    fi;
    return StabChainMutable( hom );
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . .  for blocks hom
##
InstallMethod( ImagesRepresentative, "blocks homomorphism", FamSourceEqFamElm,
        [ IsBlocksHomomorphism, IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   img,  D,  i;
    
    D := Enumerator( UnderlyingExternalSet( hom ) );
    
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
InstallGlobalFunction( ImageKernelBlocksHomomorphism, function( hom, H )
    local   D,          # the block system
            I,          # image of <H>, result
            S,          # block stabilizer in <H>
            T,          # corresponding stabilizer in <I>
            full,       # flag: true if <H> is (identical to) the source
            B,          # current block
            i,  j;      # loop variables
    
    D := Enumerator( UnderlyingExternalSet( hom ) );
    S := CopyStabChain( StabChainMutable( H ) );
    full := IsIdenticalObj( H, Source( hom ) );
    if full  then
        SetStabChainMutable( hom, S );
    fi;
    I := EmptyStabChain( [  ], One( Range( hom ) ) );
    T := I;

    # loop over the blocks
    for i  in [ 1 .. Length( D ) ]  do
        B := D[ i ];

        # if <S> does not already stabilize this block
        if     IsBound( B[1] )
           and ForAny( S.generators, gen -> hom!.reps[ B[ 1 ] ^ gen ] <> i )
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
end );

#############################################################################
##
#M  ImagesSet( <hom>, <H> ) . . . . . . . . . . . . . . . . .  for blocks hom
##
InstallMethod( ImagesSet,
    "for blocks homomorphism and perm. group",
    CollFamSourceEqFamElms,
        [ IsBlocksHomomorphism, IsPermGroup ], 0,
    ImageKernelBlocksHomomorphism );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . .  for blocks hom
##
InstallMethod( PreImagesRepresentative, "blocks homomorphism",
        FamRangeEqFamElm,
        [ IsBlocksHomomorphism, IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   D,          # the block system
            pre,        # preimage of <elm>, result
            S,          # stabilizer in chain of <hom>
            B,          # the image block <B>
            b,          # number of image block <B>
            pos;        # position of point hit by preimage
    
    D := Enumerator( UnderlyingExternalSet( hom ) );
    S := StabChainMutable( hom );
    pre := One( Source( hom ) );

    # loop over the blocks and their iterated set stabilizers
    while Length( S.genlabels ) <> 0  do

        # Find the image block <B> of the current block.

	# test if the point is in no block (transitive action)
	# if not we can simply skip this step in the stabilizer chain.
	if IsBound(hom!.reps[S.orbit[1]]) then
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

	fi;

        S := S.stabilizer;
    od;

    # return the preimage
    return pre;
end) ;

#############################################################################
##
#M  PreImagesSet( <hom>, <I> )  . . . . . . . . . . . . . . .  for blocks hom
##
InstallMethod( PreImagesSet, CollFamRangeEqFamElms,
        [ IsBlocksHomomorphism, IsPermGroup ], 0,
    function( hom, I )
    local   H;          # preimage of <I> under <hom>, result
    
    H := PreImageSetStabBlocksHomomorphism( hom, StabChainMutable( I ) );
    return GroupStabChain( Source( hom ), H, true );
end );

#############################################################################
##
#F  PreImageSetStabBlocksHomomorphism( <hom>, <I> ) . . .  recursive function
##
InstallGlobalFunction( PreImageSetStabBlocksHomomorphism, function( hom, I )
    local   H,          # preimage of <I> under <hom>, result
            pnt,        # rep. of the block that is the basepoint <I>
            gen,        # one generator of <I>
            pre;        # a representative of its preimages

    # if <I> is trivial then preimage is the kernel of <hom>
    if IsEmpty( I.genlabels )  then
        H := CopyStabChain( StabChainMutable(
                 KernelOfMultiplicativeGeneralMapping( hom ) ) );

    # else begin with the preimage $H_{block[i]}$ of the stabilizer  $I_{i}$,
    # adding preimages of the generators of  $I$  to those of  $H_{block[i]}$
    # gives us generators for $H$. Because $H_{block[i][1]} \<= H_{block[i]}$
    # the stabilizer chain below $H_{block[i][1]}$ is already complete, so we
    # only have to care about the top level with the basepoint $block[i][1]$.
    else
        pnt := Enumerator( UnderlyingExternalSet( hom ) )[ I.orbit[ 1 ] ][1];
        H := PreImageSetStabBlocksHomomorphism( hom, I.stabilizer );
        ChangeStabChain( H, [ pnt ], false );
        for gen  in I.generators  do
            pre := PreImagesRepresentative( hom, gen );
            if not IsBound( H.translabels[ pnt ^ pre ] )  then
                AddGeneratorsExtendSchreierTree( H, [ pre ] );
            fi;
        od;
    fi;

    # return the preimage
    return H;
end );

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
#F  IsomorphismPermGroup( <G> )
##
InstallMethod( IsomorphismPermGroup,
    "perm groups",
    true,
    [ IsPermGroup ], 0,
    IdentityMapping );


#############################################################################
##
#M  IsConjugatorIsomorphism( <hom> )
##
InstallOtherMethod( IsConjugatorIsomorphism,
    "perm group homomorphism",
    true,
    [ IsGroupGeneralMapping ],
  # There is no filter to test whether a homomorphism goes from a perm group
  # to a perm group. So we have to test explicitly and make this method
  # higher ranking than the default one in `ghom.gi'.
  1,
    function( hom )
    local s, genss, rep,dom,insn,stb,E,bpt,fix,pnt,idom,sliced,
      o,oimgs,i,pi,sto,stbs,stbi, r, sym;

    s:= Source( hom );
    if not IsPermGroup( s ) then
      TryNextMethod();
    elif not ( IsGroupHomomorphism( hom ) and IsBijective( hom ) ) then
      return false;
    fi;
    genss:= GeneratorsOfGroup( s );

    if IsEndoGeneralMapping( hom ) then

  # test in transitive case whether we can realize in S_n
  # we do not yet compute the permutation here because we will still have to
  # test first whether it is in fact an inner automorphism:
  # ConjugatorAutomorphisms are guaranteed to conjugate with an inner
  # element if possible!
  insn:=false;
  dom:=MovedPoints(s);
  if IsTransitive(s,dom) then
    bpt := dom[ 1 ];
    stb:=Stabilizer(s,bpt);
    E:=Image(hom,stb);
    if Number(dom,i->ForAll(GeneratorsOfGroup(E),j->i^j=i))=
       Number(dom,i->ForAll(GeneratorsOfGroup(stb),j->i^j=i)) then
#T why not with NrMovedPoints?
#T why not compare orbit lengths of point stabilizer and its image?
      insn:=true;
    else
      # we cannot realize in S_n
      return false;
    fi;
  else
    # compute the orbits and their image orbits
    o:=Orbits(s,dom);
    oimgs:=[];
    stbs:=[];
    stbi:=[];
    i:=1;
    while i<=Length(o) do
      stb:=Stabilizer(s,o[i][1]);
      sto:=Collected(List(Orbits(stb,o[i]),Length)); # stb orbit lengths
      E:=Image(hom,stb);
      Add(stbs,stb);
      Add(stbi,E);
      pi:=Filtered(o,j->Length(j)=Length(o[i])); # possible images by length
      # possible images by stabilizer orbit lengths
      pi:=Filtered(pi,j->Collected(List(Orbits(E,j),Length))=sto);
      if Length(pi)=0 then
        return false; # image cannot be stabilizer
      elif Length(pi)=1 then
        Add(oimgs,pi[1]);
      else
        # orbit image not unique. We would have to backtrack. For the time
	# being, give up
#T why not inspect other orbits, and hope for a cheap `false' answer?
        i:=Length(o)+10;
      fi;
      i:=i+1;
    od;
    if Length(oimgs)=Length(o) then
      insn:=2; # conjugation in S_n established on multiple orbits
    fi;
  fi;

  # try first to find an element in the group itself
  rep:=RepresentativeAction(s, genss,
         List( genss, i -> ImagesRepresentative( hom, i ) ), OnTuples );

  if rep<>fail then
    # we found the automorphism is in fact inner
    SetIsInnerAutomorphism(hom,true);
  else
    if insn=true then
      hom:=AsGroupGeneralMappingByImages(hom);
      fix := First( dom, p -> ForAll( GeneratorsOfGroup( E ),
		    gen -> p ^ gen = p ) );
      
      # The automorphism <aut> maps <d>_bpt to <e>_fix, so permutes the points.
      # Find an element in <G> with the same action.
      idom := [  ];
      for pnt  in dom  do
	  sliced := [  ];
	  while pnt <> bpt  do
	      Add( sliced, StabChainMutable( hom ).transimages[ pnt ] );
	      pnt := pnt ^ StabChainMutable( hom ).transversal[ pnt ];
	  od;
	  Add( idom, PreImageWord( fix, sliced ) );
      od;
      
      rep:=MappingPermListList( dom, idom );
    elif insn=2 then
      dom:=[];
      idom:=[];
      for i in [1..Length(o)] do
	# compute the images for orbit o[i]
	stb:=stbs[i]; # pnt stabilizer and its image
	E:=stbi[i];
	# base point and image
	bpt:=o[i][1];
	fix:=First(oimgs[i],p->ForAll(GeneratorsOfGroup(E),
		    gen -> p ^ gen = p ) );

	# we could try to use stabilizer chains, but the homomorphism does
	# not necessarily have one which acts in every orbit. So we use the
	# time-homoured transversal
	sliced:=RightTransversal(s,stb);
	for pnt in sliced do
	  Add(dom,bpt^pnt);
	  Add(idom,fix^ImageElm(hom,pnt));
	od;
        
      od;
      rep:=MappingPermListList( dom, idom );
    else
      # we got 
      rep:=RepresentativeAction(OrbitStabilizingParentGroup(s),
            genss,
	    List( genss, i -> ImagesRepresentative( hom, i ) ), OnTuples );
    fi;
  fi;

    else

      r:= Range( hom );
      if not IsPermGroup( r ) then
        return false;
      fi;
      sym:= SymmetricGroup( Union( MovedPoints( s ), MovedPoints( r ) ) );

      # Simply compute a conjugator in the enveloping symmetric group.
      # (Note that all checks whether source and range
      # can fit together under conjugation
      # should better be left to `RepresentativeAction'.)
      rep:= RepresentativeAction( sym, genss, List( genss,
                      i -> ImagesRepresentative( hom, i ) ), OnTuples );

    fi;

    # Return the result.
    if rep <> fail then
      Assert( 1, ForAll( genss, i -> Image( hom, i ) = i^rep ) );
      SetConjugatorOfConjugatorIsomorphism( hom, rep );
      return true;
    else
      return false;
    fi;
end );


#AH: This function should become obsolete soon!
#F  AutomorphismByConjugation( <Omega>, <d>, <e> )
AutomorphismByConjugation := function( Omega, d, e )
local  G,bpt, aut, D1, E1, fix, Imega, sliced, pnt;
    
    Info(InfoWarning,1,"replace AutomorphismByConjugation");
    aut := GroupGeneralMappingByImages( G, G, d, e );
    if not IsTransitive( PreImagesRange( aut ), Omega )  then
        Error( "<d> and <e> must generate transitive subgroups of <G>" );
    elif not IsTransitive( ImagesSource( aut ), Omega )  then
        return fail;
    fi;
    
    bpt := Omega[ 1 ];
    D1 := Stabilizer( PreImagesRange( aut ), bpt );
    E1 := ImagesSet( aut, D1 );
    if NrMovedPoints( E1 ) = Length( Omega )  then
        return fail;
    fi;
    fix := First( Omega, p -> ForAll( GeneratorsOfGroup( E1 ),
                   gen -> p ^ gen = p ) );
    
    # The automorphism <aut> maps <d>_bpt to <e>_fix, so permutes the points.
    # Find an element in <G> with the same action.
    Imega := [  ];
    for pnt  in Omega  do
        sliced := [  ];
        while pnt <> bpt  do
            Add( sliced, StabChainMutable( aut ).transimages[ pnt ] );
            pnt := pnt ^ StabChainMutable( aut ).transversal[ pnt ];
        od;
        Add( Imega, PreImageWord( fix, sliced ) );
    od;
    
    return MappingPermListList( Omega, Imega );
end;


#############################################################################
##
#E

