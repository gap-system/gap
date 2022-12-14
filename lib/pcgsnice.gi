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
#M  Pcgs( <G> ) . . . . . . . . . . . . . . . . . . . . via nice monomorphism
##
InstallMethod( Pcgs, "via niceomorphism", true,
  [ IsGroup and IsHandledByNiceMonomorphism ], 0,
    function( G )
    local   nice,  npcgs,  pcgs;

    nice := NiceMonomorphism( G );
    npcgs := Pcgs( NiceObject( G ) );
    if npcgs = fail  then
        return fail;
    fi;
    pcgs := List( npcgs, gen -> PreImagesRepresentative( nice, gen ) );
    pcgs := PcgsByPcSequenceNC( ElementsFamily( FamilyObj( G ) ), pcgs );
    if HasIsPrimeOrdersPcgs( npcgs )  and  IsPrimeOrdersPcgs( npcgs )  then
        SetIsPrimeOrdersPcgs( pcgs, true );
    fi;
    SetNiceMonomorphism( pcgs, nice );
    SetNiceObject      ( pcgs, npcgs );
    SetGroupOfPcgs     ( pcgs, G );
    SetOneOfPcgs(pcgs,One(G));
    SetFilterObj       ( pcgs, IsHandledByNiceMonomorphism );
    return pcgs;
end );

#############################################################################
##
#M  DepthOfPcElement( <pcgs>, <g> [ , <from> ] )  . . . via nice monomorphism
##
AttributeMethodByNiceMonomorphismCollElm( DepthOfPcElement,
        [ IsPcgs, IsMultiplicativeElementWithInverse ] );

InstallOtherMethod( DepthOfPcElement, true,
        [ IsPcgs and IsHandledByNiceMonomorphism,
          IsMultiplicativeElementWithInverse,
          IsPosInt ], 0,
    function( pcgs, g, depth )
    return DepthOfPcElement( NiceObject( pcgs ),
                   ImagesRepresentative( NiceMonomorphism( pcgs ), g ),
                   depth );
end );

#############################################################################
##
#M  LeadingExponentOfPcElement( <pcgs>, <g> ) . . . . . via nice monomorphism
##
AttributeMethodByNiceMonomorphismCollElm( LeadingExponentOfPcElement,
        [ IsPcgs, IsMultiplicativeElementWithInverse ] );

#############################################################################
##
#M  ExponentsOfPcElement( <pcgs>, <g> [ , <poss> ] )  . via nice monomorphism
##
AttributeMethodByNiceMonomorphismCollElm( ExponentsOfPcElement,
        [ IsPcgs, IsMultiplicativeElementWithInverse ] );

InstallOtherMethod( ExponentsOfPcElement, true,
        [ IsPcgs and IsHandledByNiceMonomorphism,
          IsMultiplicativeElementWithInverse,
          IsList and IsCyclotomicCollection ], 0,
    function( pcgs, g, poss )
    return ExponentsOfPcElement( NiceObject( pcgs ),
                   ImagesRepresentative( NiceMonomorphism( pcgs ), g ),
                   poss );
end );

InstallOtherMethod( ExponentsOfPcElement, "perm group with 0 positions", true,
        [ IsPcgs and IsHandledByNiceMonomorphism,
          IsMultiplicativeElementWithInverse,
          IsList and IsEmpty ], 0,
    function( pcgs, g, poss )
    return [  ];
end );

#############################################################################
##
#M  ExponentOfPcElement( <pcgs>, <g>, <pos> ) . . . . . via nice monomorphism
##
InstallMethod( ExponentOfPcElement, "via nicoemorphism", true,
        [ IsPcgs and IsHandledByNiceMonomorphism,
          IsMultiplicativeElementWithInverse,
          IsPosInt ], 0,
    function( pcgs, g, pos )
    return ExponentOfPcElement( NiceObject( pcgs ),
                   ImagesRepresentative( NiceMonomorphism( pcgs ), g ),
                   pos );
end );
