#############################################################################
##
#W  ghompcgs.gi                 GAP library                      Bettina Eick
##
Revision.ghompcgs_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  GroupHomomorphismByImages( <G>, <H>, <gens>, <imgs> )
##
##  Add NC later
##
InstallMethod( GroupHomomorphismByImages, 
    "generic method for pc homs",
    true, 
    [ IsPcGroup, IsPcGroup, IsList, IsList ],
    0,

function( G, H, gens, imgs )
    local pcgs, U, hom, filter;

    pcgs  := CanonicalPcgsByGeneratorsWithImages( Pcgs(G), gens, imgs );
    U     := Subgroup( H, pcgs[2] );

    filter := IsPcGroupHomomorphismByImages and 
              IsToPcGroupHomomorphismByImages;

    hom := Objectify( 
           NewKind( 
           GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                                  ElementsFamily( FamilyObj( H ) ) ),
           filter ),
           rec( generators       := gens, 
                genimages        := imgs, 
                sourcePcgs       := pcgs[1],
                sourcePcgsImages := pcgs[2] ) );

    SetSource        ( hom, G );
    SetPreImagesRange( hom, G );

    SetRange           ( hom, H );
    SetImagesSource    ( hom, U );
    SetCoKernelOfMultiplicativeGeneralMapping ( hom, TrivialSubgroup( H ) );

    return hom;
end );


InstallMethod( GroupHomomorphismByImages, 
    "generic method for pc homs",
    true, 
    [ IsPcGroup, IsGroup, IsList, IsList ],
    0,

function( G, H, gens, imgs )
    local pcgs, U, hom, filter;

    pcgs  := CanonicalPcgsByGeneratorsWithImages( Pcgs(G), gens, imgs );
    U     := Subgroup( H, pcgs[2] );

    filter := IsPcGroupHomomorphismByImages;

    hom := Objectify( 
           NewKind( 
           GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                                  ElementsFamily( FamilyObj( H ) ) ),
           filter ),
           rec( generators       := gens, 
                genimages        := imgs, 
                sourcePcgs       := pcgs[1],
                sourcePcgsImages := pcgs[2] ) );

    SetSource        ( hom, G );
    SetPreImagesRange( hom, G );

    SetRange           ( hom, H );
    SetImagesSource    ( hom, U );
    SetCoKernelOfMultiplicativeGeneralMapping ( hom, TrivialSubgroup( H ) );

    return hom;
end );

#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> )
##
InstallMethod( CompositionMapping2,
               "method for hom2 from pc group",
               true,
               [ IsGroupHomomorphism, IsPcGroupHomomorphismByImages ],
               0,

function( hom1, hom2 )
    local hom, gens, pcgs, imgs, pcgsimgs, H, U, filter, G;

    gens := hom2!.generators;
    pcgs := hom2!.sourcePcgs;

    imgs := List( hom2!.genimages, 
                  x -> ImagesRepresentative( hom1, x ) );
    pcgsimgs := List( hom2!.sourcePcgsImages, 
                      x -> ImagesRepresentative( hom1, x ) );

    G := Source( hom2 );
    H := Range( hom1 );
    U := Subgroup( H, pcgsimgs );

    if IsPcGroup( H ) then
        filter := IsPcGroupHomomorphismByImages and 
                  IsToPcGroupHomomorphismByImages;
    else
        filter := IsPcGroupHomomorphismByImages;
    fi;

    hom := Objectify( 
           NewKind( 
           GeneralMappingsFamily( ElementsFamily( FamilyObj( G ) ),
                                  ElementsFamily( FamilyObj( H ) ) ),
           filter ),
           rec( generators       := gens,
                genimages        := imgs,
                sourcePcgs       := pcgs,
                sourcePcgsImages := pcgsimgs ) );

    SetSource        ( hom, G );
    SetPreImagesRange( hom, G );

    SetRange           ( hom, H );
    SetImagesSource    ( hom, U );
    SetCoKernelOfMultiplicativeGeneralMapping( hom, TrivialSubgroup( H ) );

    return hom;
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . .  via images
##
InstallMethod( ImagesRepresentative, 
               "method for homs from pc group",
               true,
               [ IsPcGroupHomomorphismByImages, IsObject ],
               0,

function( hom, elm )
    local exp, img, i;
    exp  := ExponentsOfPcElement( hom!.sourcePcgs, elm );
    img  := Identity( Range( hom ) );
    for i in [1..Length(hom!.sourcePcgsImages)] do
        img := img * hom!.sourcePcgsImages[i]^exp[i];
    od;
    return img;
end );

#############################################################################
##
#F  InversePcgs( <hom> )
##
InversePcgs := function( hom )
    local pcgs, new,
          idR, idD, gensInv, imgsInv, gensKer, gens, imgs, i, u, v, 
          uw, tmp, vw, j;

    # if it is known then return
    if IsBound( hom!.rangePcgs ) then return; fi;

    # if it is from an pc group
    if IsBound( hom!.sourcePcgs ) then

        idR := Identity( Range( hom ) );
        idD := Identity( Source( hom ) );

        # Compute kernel and image, this is a Zassenhaus-algorithm.
        gensInv := [];
        imgsInv := [];
        gensKer := [];
        gens := hom!.sourcePcgs;
        imgs := hom!.sourcePcgsImages;
        pcgs := Pcgs( Image( hom ) );
        for i  in Reversed( [ 1 .. Length( imgs ) ] )  do
            u  := imgs[ i ];
            v  := gens[ i ];
            uw := DepthOfPcElement( pcgs, u );
            while u <> idR and IsBound( gensInv[ uw ] )  do
                tmp := LeadingExponentOfPcElement( pcgs, u )
                        /  LeadingExponentOfPcElement( pcgs, gensInv[ uw ] )
                       mod RelativeOrderOfPcElement( pcgs, u );
                u := gensInv[ uw ] ^ -tmp * u;
                v := imgsInv[ uw ] ^ -tmp * v;
                uw := DepthOfPcElement( pcgs, u );
            od;
            if u = idR  then
                vw := DepthOfPcElement( gens, v );
                while v <> idD and IsBound( gensKer[ vw ] )  do
                    v  := ReducedPcElement( gens, v, gensKer[ vw ] );
                    vw := DepthOfPcElement( gens, v );
                od;
                if v <> idD  then
                    gensKer[ vw ] := v;
                fi;
            else
                gensInv[ uw ] := u;
                imgsInv[ uw ] := v;
            fi;
        od;

        # Now  we  have  image  and  kernel
        gensInv := Compacted( gensInv );
        gensKer := Compacted( gensKer );
        imgsInv := Compacted( imgsInv );

        # normalize
        for i  in [ 1 .. Length( gensInv ) ]  do
            tmp :=  1 / LeadingExponentOfPcElement( pcgs, gensInv[ i ] )
                    mod RelativeOrderOfPcElement( pcgs, gensInv[ i ] );
            gensInv[ i ] := gensInv[ i ] ^ tmp;
            imgsInv[ i ] := imgsInv[ i ] ^ tmp;
        od;
        for i  in [ 1 .. Length( gensInv ) - 1 ]  do
            for j  in [ i + 1 .. Length( gensInv ) ]  do
                uw := DepthOfPcElement( pcgs, gensInv[ j ] );
                tmp := ExponentOfPcElement( pcgs, gensInv[ i ], uw );
                if tmp <> 0  then
                    gensInv[i] := gensInv[i] / gensInv[j] ^ tmp;
                    imgsInv[i] := imgsInv[i] / imgsInv[j] ^ tmp;
                fi;
            od;
        od;
      
        # add it
        hom!.rangePcgs := InducedPcgsByPcSequenceNC( pcgs, gensInv ); 
        hom!.rangePcgsPreimages := imgsInv;
        
        # we have the kernel also
        SetKernelOfMultiplicativeGeneralMapping( hom, SubgroupNC(Source(hom),
                                                          gensKer ) );
  
        # and return
        return;
    fi;
    
    # otherwise we have to do some work
    pcgs := Pcgs( Image( hom ) );
    new  := CanonicalPcgsByGeneratorsWithImages( pcgs, hom!.genimages,
                                                       hom!.generators );
    hom!.rangePcgs := new[1];
    hom!.rangePcgsPreimages := new[2];
end;

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . .  via images
##
InstallMethod( KernelOfMultiplicativeGeneralMapping, 
               "method for homs into pc group",
               true,
               [ IsPcGroupHomomorphismByImages ],
               0,

function( hom )
    local idR, idS, pcgs, gens, gensKer, i, u, v, uw, tmp, kernel, j; 

    idR := Identity( Range( hom ) );
    idS := Identity( Source( hom ) );

    gens := hom!.sourcePcgs;
    pcgs := hom!.sourcePcgsImages;

    # Compute kernel 
    gensKer := [];
    for i  in Reversed( [ 1 .. Length( pcgs ) ] )  do
        u  := pcgs[ i ];
        v  := gens[ i ];
        uw := DepthOfPcElement( gens, v );
        while u <> idR do
            tmp := LeadingExponentOfPcElement( gens, v )
                    /  LeadingExponentOfPcElement( gens, gens[uw] )
                   mod RelativeOrderOfPcElement( gens, v );
            u := pcgs[ uw ] ^ -tmp * u;
            v := gens[ uw ] ^ -tmp * v;
            uw := DepthOfPcElement( gens, v );
        od;
        if v <> idS then
            AddSet( gensKer, v );
        fi;
    od;

    # add the kernel
    kernel := SubgroupNC( Source( hom ), gensKer );
    SetKernelOfMultiplicativeGeneralMapping( hom, kernel );

    # Return.
    return kernel;
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . .  via images
##
InstallMethod( PreImagesRepresentative, 
               "method for pcgs hom", 
               true,
               [ IsToPcGroupHomomorphismByImages, IsObject ],
               0,

function( hom, elm )
    local  pcgsR, exp, imgs, pre, i;  

    # precompute pcgs
    InversePcgs( hom );

    pcgsR := hom!.rangePcgs;
    exp := ExponentsOfPcElement( pcgsR, elm );
    imgs := hom!.rangePcgsPreimages;
    pre := Identity( Source( hom ) );
    for i in [1..Length(exp)] do
        pre := pre * imgs[i]^exp[i];
    od;
    return pre;
end); 

#############################################################################
##

#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) . . . . . . for pc groups
##
InstallMethod( NaturalHomomorphismByNormalSubgroup, IsIdentical,
        [ IsPcGroup, IsPcGroup ], 0,
    function( G, N )
    local   pcgsG,  pcgsN,  pcgsK,  pcgsF,  F,  hom;
    
    pcgsG := Pcgs( G );  pcgsN := Pcgs( N );
    if IsInducedPcgs( pcgsN )  then
        if ParentPcgs( pcgsN ) = pcgsG  then
            pcgsK := pcgsN;
        elif     IsInducedPcgs( pcgsG )
             and ParentPcgs( pcgsN ) = ParentPcgs( pcgsG )  then
            pcgsK := NormalIntersectionPcgs( ParentPcgs( pcgsG ),
                             pcgsN, pcgsG );
        fi;
    fi;
    if not IsBound( pcgsK )  then
        pcgsK := InducedPcgsByGenerators( pcgsG, GeneratorsOfGroup( N ) );
    fi;
    pcgsF := pcgsG mod pcgsK;
    F := GroupByPcgs( pcgsF );
    hom := Objectify( NewKind( GeneralMappingsFamily
                   ( ElementsFamily( FamilyObj( G ) ),
                     ElementsFamily( FamilyObj( F ) ) ),
                   IsNaturalHomomorphismPcGroupRep ),
                   rec( pcgsSource := pcgsF,
                        pcgsRange  := Pcgs( F ) ) );
    SetSource( hom, G );
    SetRange ( hom, F );
    SetKernelOfMultiplicativeGeneralMapping( hom, GroupOfPcgs( pcgsK ) );
    return hom;
end );

InstallMethod( PrintObj, true, [ IsNaturalHomomorphismPcGroupRep ], 0,
    function( hom )
    Print( Source( hom ), " -> ", Range( hom ) );
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . via depth map
##
InstallMethod( ImagesRepresentative, FamSourceEqFamElm,
        [ IsNaturalHomomorphismPcGroupRep,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   exp;
    
    exp := ExponentsOfPcElement( hom!.pcgsSource, elm );
    return PcElementByExponents( hom!.pcgsRange, exp );
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . . . via depth map
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsNaturalHomomorphismPcGroupRep,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   exp;
    
    exp := ExponentsOfPcElement( hom!.pcgsRange, elm );
    return PcElementByExponents( hom!.pcgsSource, exp );
end );

#############################################################################
##
#M  <hom1> = <hom2> . . . . . . . . . . . . . . . . . . . . . . . .  for GHBI
##
InstallMethod( \=, IsIdentical, 
               [ IsPcGroupHomomorphismByImages, 
                 IsPcGroupHomomorphismByImages ], 1,
    function( hom1, hom2 )
    if    Source( hom1 ) <> Source( hom2 )
       or Range ( hom1 ) <> Range ( hom2 )  then
        return false;
    fi;
    return hom1!.sourcePcgsImages = hom2!.sourcePcgsImages;
end );

#############################################################################
##
#M  PrintObj( )
##
InstallMethod( PrintObj,
    "method for a PcGroupHomomorphisms",
    true,
    [ IsPcGroupHomomorphismByImages ], 0,
    function( map )
    Print(map!.sourcePcgs, " -> ", map!.sourcePcgsImages );
    end );

#############################################################################
##

#E  ghompcgs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
