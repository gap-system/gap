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
AttributeMethodByNiceMonomorphism( Pcgs,
  [ IsGroup ],
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

AttributeMethodByNiceMonomorphismCollElmOther( DepthOfPcElement,
        [ IsPcgs, IsMultiplicativeElementWithInverse, IsPosInt ] );

#############################################################################
##
#M  LeadingExponentOfPcElement( <pcgs>, <g> ) . . . . . via nice monomorphism
##
AttributeMethodByNiceMonomorphismCollElm( LeadingExponentOfPcElement,
        [ IsPcgs, IsMultiplicativeElementWithInverse ] );

#############################################################################
##
#M  ExponentsOfPcElement( <pcgs>, <g>[, <poss>] ) . . . via nice monomorphism
##
AttributeMethodByNiceMonomorphismCollElm( ExponentsOfPcElement,
        [ IsPcgs, IsMultiplicativeElementWithInverse ] );

AttributeMethodByNiceMonomorphismCollElmOther( ExponentsOfPcElement,
        [ IsPcgs, IsMultiplicativeElementWithInverse,
          IsList and IsCyclotomicCollection ] );

AttributeMethodByNiceMonomorphismCollElmOther( ExponentsOfPcElement,
        [ IsPcgs, IsMultiplicativeElementWithInverse,
          IsList and IsEmpty ],
        { pcgs, g, poss } -> [] );

#############################################################################
##
#M  ExponentOfPcElement( <pcgs>, <g>, <pos> ) . . . . . via nice monomorphism
##
AttributeMethodByNiceMonomorphismCollElmOther( ExponentOfPcElement,
        [ IsPcgs, IsMultiplicativeElementWithInverse, IsPosInt ] );
