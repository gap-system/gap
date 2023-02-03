#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Etaoin Shrdlu.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file defines all family predicates
##

BIND_GLOBAL( "IsFamFamX", function( F1, F2, F3 )
    return IsIdenticalObj( F1, F2 );
end );

BIND_GLOBAL( "IsFamXFam", function( F1, F2, F3 )
    return IsIdenticalObj( F1, F3 );
end );

BIND_GLOBAL( "IsFamFamXY", function( F1, F2, F3, F4 )
    return IsIdenticalObj( F1, F2 );
end );

BIND_GLOBAL( "IsFamXYFamZ", function( F1, F2, F3, F4, F5 )
    return IsIdenticalObj( F1, F4 );
end );

BIND_GLOBAL( "IsFamXFamY", function( F1, F2, F3, F4 )
    return IsIdenticalObj( F1, F3 );
end );

BIND_GLOBAL( "IsFamFamFam", function( F1, F2, F3 )
    return IsIdenticalObj( F1, F2 )
       and IsIdenticalObj( F2, F3 );
end );

BIND_GLOBAL( "IsFamFamFamX", function( F1, F2, F3, F4 )
    return IsIdenticalObj( F1, F2 )
       and IsIdenticalObj( F1, F3 );
end );


#############################################################################
##
#O  IsElmsColls(<F1>,<F2>) test if a family is the elements family of another
##
BIND_GLOBAL( "IsElmsColls", function ( F1, F2 )
    return HasElementsFamily( F2 )
       and IsIdenticalObj( F1, ElementsFamily(F2) );
end );

BIND_GLOBAL( "IsNotElmsColls", function ( F1, F2 )
    return not HasElementsFamily( F2 )
       or IsNotIdenticalObj( F1, ElementsFamily(F2) );
end );

BIND_GLOBAL( "IsElmsCollColls", function ( F1, F2 )
    return HasElementsFamily( F2 )
       and HasElementsFamily( ElementsFamily( F2 ) )
       and IsIdenticalObj( F1, ElementsFamily( ElementsFamily( F2 ) ) );
end );

BIND_GLOBAL( "IsElmsCollsX", function( F1, F2, F3 )
    return HasElementsFamily( F2 )
       and IsIdenticalObj( F1, ElementsFamily( F2 ) );
end );

BIND_GLOBAL( "IsElmsCollCollsX", function ( F1, F2, F3 )
    return HasElementsFamily( F2 )
       and HasElementsFamily( ElementsFamily( F2 ) )
       and IsIdenticalObj( F1, ElementsFamily( ElementsFamily( F2 ) ) );
end );


#############################################################################
##
#O  IsCollsElms(<F1>,<F2>) test if a family is the elements family of another
##
BIND_GLOBAL( "IsCollsElms", function ( F1, F2 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( ElementsFamily(F1), F2 );
end );

BIND_GLOBAL( "IsCollCollsElms", function ( F1, F2 )
    return HasElementsFamily( F1 )
       and HasElementsFamily( ElementsFamily( F1 ) )
       and IsIdenticalObj( ElementsFamily( ElementsFamily( F1 ) ), F2 );
end );

BIND_GLOBAL( "IsCollCollsElmsElmsX", function ( F1, F2, F3, F4 )
    return HasElementsFamily( F1 )
       and HasElementsFamily( ElementsFamily( F1 ) )
       and IsIdenticalObj( ElementsFamily( ElementsFamily( F1 ) ), F2 )
       and IsIdenticalObj( F2, F3 );
end );


#############################################################################
##
#O  IsCollsElmsElms( <F1>, <F2>, <F3> )
##
BIND_GLOBAL( "IsCollsElmsX", function( F1, F2, F3 )
    return HasElementsFamily(F1)
       and IsIdenticalObj( ElementsFamily(F1), F2 );
end );

BIND_GLOBAL( "IsCollsElmsElms", function( F1, F2, F3 )
    return HasElementsFamily(F1)
       and IsIdenticalObj( ElementsFamily(F1), F2 )
       and IsIdenticalObj( F2, F3 );
end );

BIND_GLOBAL( "IsCollsElmsElmsElms", function( F1, F2, F3, F4 )
    return HasElementsFamily(F1)
       and IsIdenticalObj( ElementsFamily(F1), F2 )
       and IsIdenticalObj( F2, F3 )
       and IsIdenticalObj( F2, F4 );
end );

BIND_GLOBAL( "IsCollsElmsElmsX", function( F1, F2, F3, F4 )
    return HasElementsFamily(F1)
       and IsIdenticalObj( ElementsFamily(F1), F2 )
       and IsIdenticalObj( F2, F3 );
end );

BIND_GLOBAL( "IsCollsElmsXElms", function( F1, F2, F3, F4 )
    return HasElementsFamily(F1)
       and IsIdenticalObj( ElementsFamily(F1), F2 )
       and IsIdenticalObj( F2, F4 );
end );

BIND_GLOBAL( "IsCollCollsElmsElms", function( F1, F2, F3 )
    return HasElementsFamily(F1)
       and HasElementsFamily( ElementsFamily(F1) )
       and IsIdenticalObj( ElementsFamily( ElementsFamily(F1) ), F2 )
       and IsIdenticalObj( F2, F3 );
end );

BIND_GLOBAL( "IsCollsCollsElms", function( F1, F2, F3 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( F1, F2 )
       and IsIdenticalObj( ElementsFamily( F1 ), F3 );
end );

BIND_GLOBAL( "IsCollsCollsElmsX", function( F1, F2, F3, F4 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( F1, F2 )
       and IsIdenticalObj( ElementsFamily( F1 ), F3 );
end );

BIND_GLOBAL( "IsCollsCollsElmsXX", function( F1, F2, F3, F4, F5 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( F1, F2 )
       and IsIdenticalObj( ElementsFamily( F1 ), F3 );
end );

BIND_GLOBAL( "IsCollsElmsColls", function( F1, F2, F3 )
    return IsIdenticalObj(F1, F3)
       and HasElementsFamily(F1)
       and IsIdenticalObj(F2, ElementsFamily(F1));
end );


BIND_GLOBAL( "IsCollsXElms", function( F1, F2, F3 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( F3, ElementsFamily( F1 ) );
end );

BIND_GLOBAL( "IsCollsXElmsX", function( F1, F2, F3, F4 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( F3, ElementsFamily( F1 ) );
end );

BIND_GLOBAL( "IsElmsCollsXX", function( F1, F2, F3, F4)
    return HasElementsFamily( F2 ) and
           IsIdenticalObj(F1, ElementsFamily(F2));
end );

BIND_GLOBAL( "IsCollsElmsXX", function( F1, F2, F3, F4)
    return HasElementsFamily( F1 ) and
           IsIdenticalObj(F2, ElementsFamily(F1));
end );

#############################################################################
##
#F  IsLieFamFam( <LieFam>, <Fam> )  . . . . . . . . . . . .  family predicate
#F  IsFamLieFam( <Fam>, <LieFam> )  . . . . . . . . . . . .  family predicate
#F  IsElmsLieColls( <Fam1>, <Fam2> )  . . . . . . . . . . .  family predicate
#F  IsElmsCollLieColls( <Fam1>, <Fam2> )  . . . . . . . . .  family predicate
##
BIND_GLOBAL( "IsLieFamFam", function( LieFam, Fam )
    return HasLieFamily( Fam ) and IsIdenticalObj( LieFamily( Fam ), LieFam );
end );

BIND_GLOBAL( "IsFamLieFam", function( Fam, LieFam )
    return HasLieFamily( Fam ) and IsIdenticalObj( LieFamily( Fam ), LieFam );
end );

BIND_GLOBAL( "IsElmsLieColls", function( Fam1, Fam2 )
    return     HasCollectionsFamily( Fam1 )
           and HasLieFamily( CollectionsFamily( Fam1 ) )
           and IsIdenticalObj( LieFamily( CollectionsFamily( Fam1 ) ), Fam2 );
end );

BIND_GLOBAL( "IsElmsCollLieColls", function( Fam1, Fam2 )
    return     HasCollectionsFamily( Fam1 )
           and HasLieFamily( CollectionsFamily( Fam1 ) )
           and HasCollectionsFamily( LieFamily( CollectionsFamily( Fam1 ) ) )
           and IsIdenticalObj( CollectionsFamily( LieFamily(
                                CollectionsFamily( Fam1 ) ) ), Fam2 );
end );

BIND_GLOBAL( "IsCollLieCollsElms", function( Fam1, Fam2 )
    return     HasCollectionsFamily( Fam2 )
           and HasLieFamily( CollectionsFamily( Fam2 ) )
           and HasCollectionsFamily( LieFamily( CollectionsFamily( Fam2 ) ) )
           and IsIdenticalObj( CollectionsFamily( LieFamily(
                                CollectionsFamily( Fam2 ) ) ), Fam1 );
end );


#############################################################################
##
#F  IsCoeffsElms( <coeff>, <elm> )
##
BIND_GLOBAL( "IsCoeffsElms", function( F1, F2 )
    return HasCoefficientsFamily(F2)
       and IsIdenticalObj( F1, CoefficientsFamily(F2) );
end );


#############################################################################
##
#F  IsElmsCoeffs( <elm>, <coeff> )
##
BIND_GLOBAL( "IsElmsCoeffs", function( F1, F2 )
    return HasCoefficientsFamily(F1)
       and IsIdenticalObj( CoefficientsFamily(F1), F2 );
end );


#############################################################################
##
##  some usual family predicates for mapping methods
##


#############################################################################
##
#F  FamRangeEqFamElm( <FamMap>, <FamElm> )
##
BIND_GLOBAL( "FamRangeEqFamElm", function( FamMap, FamElm )
    return     HasFamilyRange( FamMap )
           and IsIdenticalObj( FamElm, FamilyRange( FamMap ) );
end );


#############################################################################
##
#F  FamSourceEqFamElm( <FamMap>, <FamElm> )
##
BIND_GLOBAL( "FamSourceEqFamElm", function( FamMap, FamElm )
    return     HasFamilySource( FamMap )
           and IsIdenticalObj( FamElm, FamilySource( FamMap ) );
end );


#############################################################################
##
#F  CollFamRangeEqFamElms( <FamMap>, <FamElms> )
##
BIND_GLOBAL( "CollFamRangeEqFamElms", function( FamMap, FamElms )
    return     HasFamilyRange( FamMap )
           and HasElementsFamily( FamElms )
           and IsIdenticalObj( ElementsFamily( FamElms ),
                            FamilyRange( FamMap ) );
end );


#############################################################################
##
#F  CollFamSourceEqFamElms( <FamMap>, <FamElms> )
##
BIND_GLOBAL( "CollFamSourceEqFamElms", function( FamMap, FamElms )
    return     HasFamilySource( FamMap )
           and HasElementsFamily( FamElms )
           and IsIdenticalObj( ElementsFamily( FamElms ),
                            FamilySource( FamMap ) );
end );


#############################################################################
##
#F  FamElmEqFamRange( <FamElm>, <FamMap> )
##
BIND_GLOBAL( "FamElmEqFamRange", function( FamElm, FamMap )
    return     HasFamilyRange( FamMap )
           and IsIdenticalObj( FamElm, FamilyRange( FamMap ) );
end );


#############################################################################
##
#F  FamElmEqFamSource( <FamElm>, <FamMap> )
##
BIND_GLOBAL( "FamElmEqFamSource", function( FamElm, FamMap )
    return     HasFamilySource( FamMap )
           and IsIdenticalObj( FamElm, FamilySource( FamMap ) );
end );


#############################################################################
##
#F  FamSource2EqFamRange1( <Fam1>, <Fam2> )
##
BIND_GLOBAL( "FamSource2EqFamRange1", function( Fam1, Fam2 )
    return     HasFamilySource( Fam2 )
           and HasFamilyRange(  Fam1 )
           and IsIdenticalObj( FamilyRange( Fam1 ), FamilySource( Fam2 ) );
end );


#############################################################################
##
#F  FamSource1EqFamRange2( <Fam1>, <Fam2> )
##
BIND_GLOBAL( "FamSource1EqFamRange2", function( Fam1, Fam2 )
    return     HasFamilySource( Fam1 )
           and HasFamilyRange(  Fam2 )
           and IsIdenticalObj( FamilyRange( Fam2 ), FamilySource( Fam1 ) );
end );


#############################################################################
##
#F  FamRange1EqFamRange2( <Fam1>, <Fam2> )
##
BIND_GLOBAL( "FamRange1EqFamRange2", function( Fam1, Fam2 )
    return     HasFamilyRange( Fam1 )
           and HasFamilyRange( Fam2 )
           and IsIdenticalObj( FamilyRange( Fam1 ), FamilyRange( Fam2 ) );
end );


#############################################################################
##
#F  FamSource1EqFamSource2( <Fam1>, <Fam2> )
##
BIND_GLOBAL( "FamSource1EqFamSource2", function( Fam1, Fam2 )
    return     HasFamilySource( Fam1 )
           and HasFamilySource( Fam2 )
           and IsIdenticalObj( FamilySource( Fam1 ), FamilySource( Fam2 ) );
end );


#############################################################################
##
#F  FamMapFamSourceFamRange( <FamMap>, <FamElm1>, <FamElm2> )
##
BIND_GLOBAL( "FamMapFamSourceFamRange", function( FamMap, FamElm1, FamElm2 )
    return     HasFamilySource( FamMap )
           and HasFamilyRange(  FamMap )
           and IsIdenticalObj( FamilySource( FamMap ), FamElm1 )
           and IsIdenticalObj( FamilyRange(  FamMap ), FamElm2 );
end );


#############################################################################
##
#F  FamSourceRgtEqFamsLft( <FamLft>, <FamRgt> )
##
BIND_GLOBAL( "FamSourceRgtEqFamsLft", function( FamLft, FamRgt )
    return     HasFamilySource( FamLft )
           and HasFamilyRange(  FamLft )
           and IsIdenticalObj( FamilySource( FamLft ), FamilyRange(  FamLft ) )
           and HasFamilySource( FamRgt )
           and IsIdenticalObj( FamilySource( FamRgt ), FamilyRange(  FamLft ) );
end );


#############################################################################
##
#F  FamSourceNotEqFamElm( <FamMap>, <FamElm> )
##
BIND_GLOBAL( "FamSourceNotEqFamElm", function( FamMap, FamElm )
    return not FamSourceEqFamElm( FamMap, FamElm );
end );


#############################################################################
##
#F  FamRangeNotEqFamElm( <FamMap>, <FamElm> )
##
BIND_GLOBAL( "FamRangeNotEqFamElm", function( FamMap, FamElm )
    return not FamRangeEqFamElm( FamMap, FamElm );
end );


#############################################################################
##
#F  IsMagmaRingsRings( <FamRMelm>, <FamRelm> )  . . . . . .  family predicate
#F  IsMagmaRingsMagmas( <FamRMelm>, <FamMelm> ) . . . . . .  family predicate
#F  IsRingsMagmaRings( <FamRelm>, <FamRMelm> )  . . . . . .  family predicate
#F  IsMagmasMagmaRings( <FamMelm>, <FamRMelm> ) . . . . . .  family predicate
##
BIND_GLOBAL( "IsMagmaRingsRings", function( FamRM, FamR )
    return     IsBound( FamRM!.familyRing )
           and IsIdenticalObj( ElementsFamily( FamRM!.familyRing ), FamR );
end );

BIND_GLOBAL( "IsMagmaRingsMagmas", function( FamRM, FamM )
    return     IsBound( FamRM!.familyMagma )
           and IsIdenticalObj( ElementsFamily( FamRM!.familyMagma ), FamM );
end );

BIND_GLOBAL( "IsRingsMagmaRings", function( FamR, FamRM )
    return     IsBound( FamRM!.familyRing )
           and IsIdenticalObj( ElementsFamily( FamRM!.familyRing ), FamR );
end );

BIND_GLOBAL( "IsMagmasMagmaRings", function( FamM, FamRM )
    return     IsBound( FamRM!.familyMagma )
           and IsIdenticalObj( ElementsFamily( FamRM!.familyMagma ), FamM );
end );

BIND_GLOBAL( "IsMagmaCollsMagmaRingColls", function( FamM, FamRM )
    return     HasElementsFamily( FamM )
           and HasElementsFamily( FamRM )
           and IsBound( ElementsFamily( FamRM )!.familyMagma )
           and IsIdenticalObj( ElementsFamily( FamRM )!.familyMagma, FamM );
end );

BIND_GLOBAL( "IsRingCollsMagmaRingColls", function( FamR, FamRM )
    return     HasElementsFamily( FamR )
           and HasElementsFamily( FamRM )
           and IsBound( ElementsFamily( FamRM )!.familyRing )
           and IsIdenticalObj( ElementsFamily( FamRM )!.familyRing, FamR );
end );
