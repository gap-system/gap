#############################################################################
##
#W  ghom.gi                  GAP library                       Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.ghom_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  <a> = <b> . . . . . . . . . . . . . . . . . . . . . . . . . .  via images
##
InstallMethod( \=, IsIdentical, [ IsGroupGeneralMapping,
        IsGroupGeneralMapping ], 0,
    function( a, b )
    return AsGroupGeneralMappingByImages( a ) =
           AsGroupGeneralMappingByImages( b );
end );

#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> ) . . . . . . . . . . . .  via images
##
InstallMethod( CompositionMapping2, "using `AsGroupGeneralMappingByImages'",
        FamSource1EqFamRange2,
        [ IsGroupHomomorphism, IsGroupGeneralMapping ], 0,
    function( hom1, hom2 )
    if not KnowsHowToDecompose(Source(hom2)) then
      TryNextMethod();
    fi;
    hom2 := AsGroupGeneralMappingByImages( hom2 );
    return GroupGeneralMappingByImages( Source( hom2 ), Range( hom1 ),
           hom2!.generators, List( hom2!.genimages, img ->
                   ImagesRepresentative( hom1, img ) ) );
end );

InstallMethod( CompositionMapping2, "using `AsGroupGeneralMappingByImages'",
        FamSource1EqFamRange2,
        [ IsGroupHomomorphism, IsGroupHomomorphism ], 0,
    function( hom1, hom2 )
    if not KnowsHowToDecompose(Source(hom2)) then
      TryNextMethod();
    fi;
    hom2 := AsGroupGeneralMappingByImages( hom2 );
    return GroupHomomorphismByImages( Source( hom2 ), Range( hom1 ),
           hom2!.generators, List( hom2!.genimages, img ->
                   ImagesRepresentative( hom1, img ) ) );
end );

#############################################################################
##
#M  InverseGeneralMapping( <hom> )  . . . . . . . . . . . . . . .  via images
##
InstallMethod( InverseGeneralMapping, true,
        [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages ], 0,
    hom -> InverseGeneralMapping( AsGroupGeneralMappingByImages( hom ) ) );

InstallOtherMethod( SetInverseGeneralMapping, true,
        [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages and
          HasAsGroupGeneralMappingByImages,
          IsGeneralMapping ], SUM_FLAGS,
    function( hom, inv )
    SetInverseGeneralMapping( AsGroupGeneralMappingByImages( hom ), inv );
    TryNextMethod();
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . .  via images
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
    [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages,
      IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    return ImagesRepresentative( AsGroupGeneralMappingByImages( hom ), elm );
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . .  via images
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
    [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages,
      IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    return PreImagesRepresentative( AsGroupGeneralMappingByImages( hom ),
                   elm );
end );

#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . .  via images
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping, true,
        [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages ], 0,
    hom -> CoKernelOfMultiplicativeGeneralMapping(
               AsGroupGeneralMappingByImages( hom ) ) );

InstallMethod( SetCoKernelOfMultiplicativeGeneralMapping, true,
        [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages and
          HasAsGroupGeneralMappingByImages,
          IsGroup ], SUM_FLAGS,
    function( hom, K )
    SetCoKernelOfMultiplicativeGeneralMapping(
        AsGroupGeneralMappingByImages( hom ), K );
    TryNextMethod();
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . .  via images
##
InstallMethod( KernelOfMultiplicativeGeneralMapping, true,
        [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages ], 0,
    hom -> KernelOfMultiplicativeGeneralMapping(
               AsGroupGeneralMappingByImages( hom ) ) );

InstallMethod( SetKernelOfMultiplicativeGeneralMapping, true,
        [ IsGroupGeneralMappingByAsGroupGeneralMappingByImages and
          HasAsGroupGeneralMappingByImages,
          IsGroup ], SUM_FLAGS,
    function( hom, K )
    SetKernelOfMultiplicativeGeneralMapping(
        AsGroupGeneralMappingByImages( hom ), K );
    TryNextMethod();
end );

#############################################################################
##

#M  GroupGeneralMappingByImages( <G>, <H>, <gens>, <imgs> ) . . . . make GHBI
##
InstallMethod( GroupGeneralMappingByImages, true,
    [ IsGroup, IsGroup, IsList, IsList ], 0,
    function( G, H, gens, imgs )
    local   filter,  hom;
    
    hom := rec( generators := gens, genimages := imgs );
    filter := IsGroupGeneralMappingByImages;
    if IsPcgs( gens )  then
        filter := filter and IsGroupGeneralMappingByPcgs;
        hom.pcgs := gens;
        if IsModuloPcgs( gens )  then
            hom.generators := Concatenation( gens,
                  DenominatorOfModuloPcgs( gens ) );
            hom.genimages := Concatenation( imgs, List
                ( DenominatorOfModuloPcgs( gens ), x -> One( H ) ) );
        elif IsModuloPcgsPermGroupRep( gens )  then
            hom.generators := Concatenation( gens,
                  GeneratorsOfGroup( gens!.denominator ) );
            hom.genimages := Concatenation( imgs, List
                ( GeneratorsOfGroup( gens!.denominator ), x -> One( H ) ) );
        fi;
    fi;
    if IsPermGroup( G )  then
        filter := filter and IsPermGroupGeneralMappingByImages;
    fi;
    if IsPermGroup( H )  then
        filter := filter and IsToPermGroupGeneralMappingByImages;
    fi;
    Objectify( NewKind( GeneralMappingsFamily
            ( ElementsFamily( FamilyObj( G ) ),
              ElementsFamily( FamilyObj( H ) ) ), filter ), hom );
    SetSource( hom, G );
    SetRange ( hom, H );
    return hom;
end );

InstallMethod( GroupHomomorphismByImages, true,
    [ IsGroup, IsGroup, IsList, IsList ], 0,
    function( G, H, gens, imgs )
    local   hom;

    hom := GroupGeneralMappingByImages( G, H, gens, imgs );
    SetFilterObj( hom, IsMapping );
    SetPreImagesRange( hom, G );
    return hom;
end );


#############################################################################
##
#M  AsGroupGeneralMappingByImages( <map> )  . . . . .  for group homomorphism
##
InstallMethod( AsGroupGeneralMappingByImages,
    "method for a group homomorphism",
    true,
    [ IsGroupHomomorphism ], 0,
    function( map )
    local gens;
    gens:= GeneratorsOfGroup( PreImagesRange( map ) );
    return GroupHomomorphismByImages( Source( map ), Range( map ),
               gens, List( gens, g -> ImagesRepresentative( map, g ) ) );
    end );

InstallMethod( AsGroupGeneralMappingByImages, true,
    [ IsGroupGeneralMapping ], 0,
    function( map )
    local gens, cok;
    gens:= GeneratorsOfGroup( PreImagesRange( map ) );
    cok := GeneratorsOfGroup( CoKernelOfMultiplicativeGeneralMapping( map ) );
    return GroupGeneralMappingByImages( Source( map ), Range( map ),
           Concatenation( gens, List( cok, g -> One( Source( map ) ) ) ),
           Concatenation( List( gens, g -> ImagesRepresentative( map, g ) ),
                   cok ) );
    end );
    
#############################################################################
##
#M  AsGroupGeneralMappingByImages( <hom> )  . . . . . . . . . . . .  for GHBI
##
InstallMethod( AsGroupGeneralMappingByImages, true,
        [ IsGroupGeneralMappingByImages ], SUM_FLAGS, hom -> hom );

#############################################################################
##
#M  <hom1> = <hom2> . . . . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( \=, IsIdentical, [ IsGroupHomomorphism and
        IsGroupGeneralMappingByImages, IsGroupHomomorphism ], 1,
    function( hom1, hom2 )
    local   i;
    
    if    Source( hom1 ) <> Source( hom2 )
       or Range ( hom1 ) <> Range ( hom2 )  then
        return false;
    elif     IsGroupGeneralMappingByImages( hom2 )
         and Length( hom2!.generators ) < Length( hom1!.generators )  then
        return hom2 = hom1;
    fi;
    for i  in [ 1 .. Length( hom1!.generators ) ]  do
        if ImagesRepresentative( hom2, hom1!.generators[ i ] )
           <> hom1!.genimages[ i ]  then
            return false;
        fi;
    od;
    return true;
end );
InstallMethod( \=, IsIdentical, [ IsGroupHomomorphism,
        IsGroupHomomorphism and IsGroupGeneralMappingByImages ], 0,
    function( hom1, hom2 )
    return hom2 = hom1;
end );

#############################################################################
##
#M  ImagesSource( <hom> ) . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( ImagesSource, true, [ IsGroupGeneralMappingByImages ], 0,
    hom -> SubgroupNC( Range( hom ), hom!.genimages ) );

#############################################################################
##
#M  PreImagesRange( <hom> ) . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( PreImagesRange, true, [ IsGroupGeneralMappingByImages ], 0,
    hom -> SubgroupNC( Source( hom ), hom!.generators ) );

#############################################################################
##
#M  InverseGeneralMapping( <hom> )  . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( InverseGeneralMapping,
    true, [ IsGroupGeneralMappingByImages ], 0,
    function( hom )
    return GroupGeneralMappingByImages( Range( hom ),   Source( hom ),
                                        hom!.genimages, hom!.generators );
end );

InstallMethod( InverseGeneralMapping, true,
        [ IsGroupGeneralMappingByImages and IsBijective ], 0,
    function( hom )
    hom := GroupHomomorphismByImages( Range( hom ),   Source( hom ),
                                      hom!.genimages, hom!.generators );
    SetIsBijective( hom, true );
    return hom;
end );


#############################################################################
##
#F  MakeMapping( <hom> )  . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
MakeMapping := function( hom )
    local   elms,       # elements of subgroup of '<hom>.source'
            elmr,       # representatives of <elms> in '<hom>.elements'
            imgs,       # elements of subgroup of '<hom>.range'
            imgr,       # representatives of <imgs> in '<hom>.images'
            rep,        # one new element of <elmr> or <imgr>
            i, j, k;    # loop variables

    # if necessary compute the mapping with a Dimino algorithm
    if not IsBound( hom!.elements )  then
        hom!.elements := [ One( Source( hom ) ) ];
        hom!.images   := [ One( Range ( hom ) ) ];
        for i  in [ 1 .. Length( hom!.generators ) ]  do
            elms := ShallowCopy( hom!.elements );
            elmr := [ One( Source( hom ) ) ];
            imgs := ShallowCopy( hom!.images );
            imgr := [ One( Range( hom ) ) ];
            j := 1;
            while j <= Length( elmr )  do
                for k  in [ 1 .. i ]  do
                    rep := elmr[j] * hom!.generators[k];
                    if not rep in hom!.elements  then
                        Append( hom!.elements, elms * rep );
                        Add( elmr, rep );
                        rep := imgr[j] * hom!.genimages[k];
                        Append( hom!.images, imgs * rep );
                        Add( imgr, rep );
                    fi;
                od;
                j := j + 1;
            od;
            SortParallel( hom!.elements, hom!.images );
            IsSSortedList( hom!.elements );  # give a hint that this is a set
        od;
    fi;
end;

#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . .  for GHBI
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    true, [ IsGroupGeneralMappingByImages ], 0,
    function( hom )
    local   C,          # co kernel of <hom>, result
            gen,        # one generator of <C>
            i, k;       # loop variables

    # make sure we have the mapping
    if not IsBound( hom!.elements )  then
        MakeMapping( hom );
    fi;

    # start with the trivial co kernel
    C := TrivialSubgroup( Range( hom ) );

    # for each element of the source and each generator of the source
    for i  in [ 1 .. Length( hom!.elements ) ]  do
        for k  in [ 1 .. Length( hom!.generators ) ]  do

            # the co kernel must contain the corresponding Schreier generator
            gen := hom!.images[i] * hom!.genimages[k]
                 / hom!.images[ Position( hom!.elements,
                                         hom!.elements[i]*hom!.generators[k])];
            C := ClosureGroup( C, gen );

        od;
    od;

    # return the co kernel
    return C;
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . . .  for GHBI
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    true, [ IsGroupGeneralMappingByImages ], 0,
    hom -> CoKernelOfMultiplicativeGeneralMapping(
               InverseGeneralMapping( hom ) ) );

#############################################################################
##
#M  IsInjective( <hom> )  . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( IsInjective, true, [ IsGroupGeneralMappingByImages ], 0,
    hom -> IsSingleValued( InverseGeneralMapping( hom ) ) );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . . .  for GHBI
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsGroupGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   p;
    if not IsBound( hom!.elements )  then
        MakeMapping( hom );
    fi;
    p := Position( hom!.elements, elm );
    if p <> fail  then  return hom!.images[ p ];
                  else  return fail;             fi;
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . . .  for GHBI
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsGroupGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    if IsBound( hom!.images )  and elm in hom!.images  then
        return hom!.elements[ Position( hom!.images, elm ) ];
    else
        return ImagesRepresentative( InverseGeneralMapping( hom ), elm );
    fi;
end );

#############################################################################
##
#M  PrintObj( <hom> ) . . . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( PrintObj, true, [ IsGroupGeneralMappingByImages ], 0,
    function( hom )
    Print( hom!.generators, " -> ", hom!.genimages );
end );

#############################################################################
##

#M  InnerAutomorphism( <G>, <g> ) . . . . . . . . . . . .  inner automorphism
##
InstallMethod( InnerAutomorphism, IsCollsElms,
        [ IsGroup, IsMultiplicativeElementWithInverse ], 0,
    function( G, g )
    local   fam,  inn;
    
    fam := ElementsFamily( FamilyObj( G ) );
    inn := Objectify( NewKind( GeneralMappingsFamily( fam, fam ),
                   IsInnerAutomorphismRep ),
                   rec( conjugator := g ) );
    SetSource( inn, G );
    SetRange ( inn, G );
    return inn;
end );

#############################################################################
##
#M  AsGroupGeneralMappingByImages( <inn> )  . . . . .  for inner automorphism
##
InstallMethod( AsGroupGeneralMappingByImages, true,
        [ IsInnerAutomorphismRep ], 0,
    function( inn )
    local   G,  gens;
    
    G := Source( inn );
    gens := GeneratorsOfGroup( G );
    inn := GroupGeneralMappingByImages( G, G, gens,
                   OnTuples( gens, inn!.conjugator ) );
    SetIsBijective( inn, true );
    return inn;
end );

#############################################################################
##
#M  InverseGeneralMapping( <inn> )  . . . . . . . . .  for inner automorphism
##
InstallMethod( InverseGeneralMapping, true, [ IsInnerAutomorphismRep ], 0,
    function( inn )
    return InnerAutomorphism( Source( inn ), inn!.conjugator ^ -1 );
end );

#############################################################################
##
#M  CompositionMapping2( <inn1>, <inn2> ) . . . . . . for inner automorphisms
##
InstallMethod( CompositionMapping2, "<inn1>, <inn2>", IsIdentical,
        [ IsInnerAutomorphismRep, IsInnerAutomorphismRep ], 0,
    function( inn1, inn2 )
    if not IsIdentical( Source( inn1 ), Source( inn2 ) )  then
        TryNextMethod();
    fi;
    return InnerAutomorphism( Source( inn1 ),
                   inn2!.conjugator * inn1!.conjugator );
end );

#############################################################################
##
#M  ImagesRepresentative( <inn>, <g> )  . . . . . . .  for inner automorphism
##
InstallMethod( ImagesRepresentative, "<inn>, <g>", FamSourceEqFamElm,
        [ IsInnerAutomorphismRep, IsMultiplicativeElementWithInverse ], 0,
    function( inn, g )
    return g ^ inn!.conjugator;
end );

#############################################################################
##
#M  ImagesSet( <inn>, <U> ) . . . . . . . . . . . . .  for inner automorphism
##
InstallMethod( ImagesSet, CollFamSourceEqFamElms,
        [ IsInnerAutomorphismRep, IsGroup ], 0,
    function( inn, U )
    return U ^ inn!.conjugator;
end );

#############################################################################
##
#M  PreImagesRepresentative( <inn>, <g> ) . . . . . .  for inner automorphism
##
InstallMethod( PreImagesRepresentative, "<inn>, <g>", FamRangeEqFamElm,
        [ IsInnerAutomorphismRep, IsMultiplicativeElementWithInverse ], 0,
    function( inn, g )
    return g ^ ( inn!.conjugator ^ -1 );
end );

#############################################################################
##
#M  PreImagesSet( <inn>, <U> )  . . . . . . . . . . .  for inner automorphism
##
InstallMethod( PreImagesSet, CollFamRangeEqFamElms,
        [ IsInnerAutomorphismRep, IsGroup ], 0,
    function( inn, U )
    return U ^ ( inn!.conjugator ^ -1 );
end );

#############################################################################
##
#M  PrintObj( <inn> ) . . . . . . . . . . . . . . . .  for inner automorphism
##
InstallMethod( PrintObj, true, [ IsInnerAutomorphismRep ], 0,
    function( inn )
    Print( "^", inn!.conjugator );
end );

#############################################################################
##

#F  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) check whether N \unlhd G?
##
InstallMethod( NaturalHomomorphismByNormalSubgroup, IsIdentical,
        [ IsGroup, IsGroup and IsTrivial ], SUM_FLAGS,
    function( G, T )
    return IdentityMapping( G );
end );

InstallInParentMethod( NaturalHomomorphismByNormalSubgroupInParent,
        IsGroup, NaturalHomomorphismByNormalSubgroup );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . .  if given by pcgs
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsGroupGeneralMappingByPcgs, IsMultiplicativeElementWithInverse ],
        100,  # to override methods for `IsPerm( <elm> )'
    function( hom, elm )
    local   exp;
    
    exp := ExponentsOfPcElement( hom!.pcgs, elm );
    return WordVector( hom!.genimages, One( Range( hom ) ), exp );
end );


#############################################################################
##
#F  GroupIsomorphismByFunctions( <G>, <H>, <I>, <P> ) . . . . . . . for Frank
##
GroupIsomorphismByFunctions := function( G, H, I, P )
    local   hom;
    
    hom := MappingByFunction( G, H, I, P );
    Setter( IsGroupHomomorphism )( hom, true );
    return hom;
end;

#############################################################################
##
#F  IsomorphismPermGroup( <G> )
##
InstallMethod(IsomorphismPermGroup,"right regular",true,[IsGroup],0,
function(G)
  return OperationHomomorphism(G,G,OnRight);
end);

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  ghom.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

