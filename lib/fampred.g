#############################################################################
##
#W  fampred.g                    GAP library                    Etaoin Shrdlu
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file defines all family predicates
##
Revision.fampred_g :=
    "@(#)$Id$";


#############################################################################
##
#O  IsElmsColls(<F1>,<F2>) test if a family is the elements family of another
##
IsElmsColls := function ( F1, F2 )
    return HasElementsFamily( F2 )
       and IsIdentical( F1, ElementsFamily(F2) );
end;

IsNotElmsColls := function ( F1, F2 )
    return not HasElementsFamily( F2 )
       or IsNotIdentical( F1, ElementsFamily(F2) );
end;

IsElmsCollColls := function ( F1, F2 )
    return HasElementsFamily( F2 )
       and HasElementsFamily( ElementsFamily( F2 ) )
       and IsIdentical( F1, ElementsFamily( ElementsFamily( F2 ) ) );
end;


#############################################################################
##
#O  IsCollsElms(<F1>,<F2>) test if a family is the elements family of another
##
IsCollsElms := function ( F1, F2 )
    return HasElementsFamily( F1 )
       and IsIdentical( ElementsFamily(F1), F2 );
end;

IsCollCollsElms := function ( F1, F2 )
    return HasElementsFamily( F1 )
       and HasElementsFamily( ElementsFamily( F1 ) )
       and IsIdentical( ElementsFamily( ElementsFamily( F1 ) ), F2 );
end;


#############################################################################
##
#O  IsCollsElmsElms( <F1>, <F2>, <F3> )
##
IsCollsElmsElms := function( F1, F2, F3 )
    return HasElementsFamily(F1)
       and IsIdentical( ElementsFamily(F1), F2 )
       and IsIdentical( F2, F3 );
end;

IsCollsElmsElmsElms := function( F1, F2, F3, F4 )
    return HasElementsFamily(F1)
       and IsIdentical( ElementsFamily(F1), F2 )
       and IsIdentical( F2, F3 )
       and IsIdentical( F2, F4 );
end;

IsCollsElmsElmsX := function( F1, F2, F3, F4 )
    return HasElementsFamily(F1)
       and IsIdentical( ElementsFamily(F1), F2 )
       and IsIdentical( F2, F3 );
end;

IsCollCollsElmsElms := function( F1, F2, F3 )
    return HasElementsFamily(F1)
       and HasElementsFamily( ElementsFamily(F1) )
       and IsIdentical( ElementsFamily( ElementsFamily(F1) ), F2 )
       and IsIdentical( F2, F3 );
end;

IsCollsCollsElms := function( F1, F2, F3 )
    return HasElementsFamily( F1 )
       and IsIdentical( F1, F2 )
       and IsIdentical( ElementsFamily( F1 ), F3 );
end;

IsCollsElmsColls := function(a,b,c)
  return IsIdentical(a,c) and HasElementsFamily(a) and
    IsIdentical(b,ElementsFamily(a));
end;


IsCollsXElms := function( F1, F2, F3 )
    return     HasElementsFamily( F1 )
           and IsIdentical( F3, ElementsFamily( F1 ) );
end;


IsFamFamXY := function(a,b,c,d)
  return IsIdentical(a,b);
end;


#############################################################################
##
#F  IsLieFamFam( <LieFam>, <Fam> )  . . . . . . . . . . . .  family predicate
#F  IsFamLieFam( <Fam>, <LieFam> )  . . . . . . . . . . . .  family predicate
#F  IsElmsLieColls( <Fam1>, <Fam2> )  . . . . . . . . . . .  family predicate
#F  IsElmsCollLieColls( <Fam1>, <Fam2> )  . . . . . . . . .  family predicate
##
IsLieFamFam := function( LieFam, Fam )
    return HasLieFamily( Fam ) and IsIdentical( LieFamily( Fam ), LieFam );
end;

IsFamLieFam := function( Fam, LieFam )
    return HasLieFamily( Fam ) and IsIdentical( LieFamily( Fam ), LieFam );
end;

IsElmsLieColls := function( Fam1, Fam2 )
    return     HasCollectionsFamily( Fam1 )
           and HasLieFamily( CollectionsFamily( Fam1 ) )
           and IsIdentical( LieFamily( CollectionsFamily( Fam1 ) ), Fam2 );
end;

IsElmsCollLieColls := function( Fam1, Fam2 )
    return     HasCollectionsFamily( Fam1 )
           and HasLieFamily( CollectionsFamily( Fam1 ) )
           and HasCollectionsFamily( LieFamily( CollectionsFamily( Fam1 ) ) )
           and IsIdentical( CollectionsFamily( LieFamily(
                                CollectionsFamily( Fam1 ) ) ), Fam2 );
end;

IsCollLieCollsElms := function( Fam1, Fam2 )
    return     HasCollectionsFamily( Fam2 )
           and HasLieFamily( CollectionsFamily( Fam2 ) )
           and HasCollectionsFamily( LieFamily( CollectionsFamily( Fam2 ) ) )
           and IsIdentical( CollectionsFamily( LieFamily(
                                CollectionsFamily( Fam2 ) ) ), Fam1 );
end;


#############################################################################
##
#F  IsCoeffsElms( <coeff>, <elm> )
##
IsCoeffsElms := function( F1, F2 )
    return HasCoefficientsFamily(F2)
       and IsIdentical( F1, CoefficientsFamily(F2) );
end;


#############################################################################
##
#F  IsElmsCoeffs( <elm>, <coeff> )
##
IsElmsCoeffs := function( F1, F2 )
    return HasCoefficientsFamily(F1)
       and IsIdentical( CoefficientsFamily(F1), F2 );
end;


#############################################################################
##
##  some usual family predicates for mapping methods
##


#############################################################################
##
#F  FamRangeEqFamElm( <FamMap>, <FamElm> )
##
FamRangeEqFamElm := function( FamMap, FamElm )
    return     HasFamilyRange( FamMap )
           and IsIdentical( FamElm, FamilyRange( FamMap ) );
end;


#############################################################################
##
#F  FamSourceEqFamElm( <FamMap>, <FamElm> )
##
FamSourceEqFamElm := function( FamMap, FamElm )
    return     HasFamilySource( FamMap )
           and IsIdentical( FamElm, FamilySource( FamMap ) );
end;


#############################################################################
##
#F  CollFamRangeEqFamElms( <FamMap>, <FamElms> )
##
CollFamRangeEqFamElms := function( FamMap, FamElms )
    return     HasFamilyRange( FamMap )
           and HasElementsFamily( FamElms )
           and IsIdentical( ElementsFamily( FamElms ),
                            FamilyRange( FamMap ) );
end;


#############################################################################
##
#F  CollFamSourceEqFamElms( <FamMap>, <FamElms> )
##
CollFamSourceEqFamElms := function( FamMap, FamElms )
    return     HasFamilySource( FamMap )
           and HasElementsFamily( FamElms )
           and IsIdentical( ElementsFamily( FamElms ),
                            FamilySource( FamMap ) );
end;


#############################################################################
##
#F  FamElmEqFamRange( <FamElm>, <FamMap> )
##
FamElmEqFamRange := function( FamElm, FamMap )
    return     HasFamilyRange( FamMap )
           and IsIdentical( FamElm, FamilyRange( FamMap ) );
end;


#############################################################################
##
#F  FamElmEqFamSource( <FamElm>, <FamMap> )
##
FamElmEqFamSource := function( FamElm, FamMap )
    return     HasFamilySource( FamMap )
           and IsIdentical( FamElm, FamilySource( FamMap ) );
end;


#############################################################################
##
#F  FamSource2EqFamRange1( <Fam1>, <Fam2> )
##
FamSource2EqFamRange1 := function( Fam1, Fam2 )
    return     HasFamilySource( Fam2 )
           and HasFamilyRange(  Fam1 )
           and IsIdentical( FamilyRange( Fam1 ), FamilySource( Fam2 ) );
end;


#############################################################################
##
#F  FamSource1EqFamRange2( <Fam1>, <Fam2> )
##
FamSource1EqFamRange2 := function( Fam1, Fam2 )
    return     HasFamilySource( Fam1 )
           and HasFamilyRange(  Fam2 )
           and IsIdentical( FamilyRange( Fam2 ), FamilySource( Fam1 ) );
end;


#############################################################################
##
#F  FamRange1EqFamRange2( <Fam1>, <Fam2> )
##
FamRange1EqFamRange2 := function( Fam1, Fam2 )
    return     HasFamilyRange( Fam1 )
           and HasFamilyRange( Fam2 )
           and IsIdentical( FamilyRange( Fam1 ), FamilyRange( Fam2 ) );
end;


#############################################################################
##
#F  FamSource1EqFamSource2( <Fam1>, <Fam2> )
##
FamSource1EqFamSource2 := function( Fam1, Fam2 )
    return     HasFamilySource( Fam1 )
           and HasFamilySource( Fam2 )
           and IsIdentical( FamilySource( Fam1 ), FamilySource( Fam2 ) );
end;


#############################################################################
##
#F  FamMapFamSourceFamRange( <FamMap>, <FamElm1>, <FamElm2> )
##
FamMapFamSourceFamRange := function( FamMap, FamElm1, FamElm2 )
    return     HasFamilySource( FamMap )
           and HasFamilyRange(  FamMap )
           and IsIdentical( FamilySource( FamMap ), FamElm1 )
           and IsIdentical( FamilyRange(  FamMap ), FamElm2 );
end;


#############################################################################
##
#F  FamSourceRgtEqFamsLft( <FamLft>, <FamRgt> )
##
FamSourceRgtEqFamsLft := function( FamLft, FamRgt )
    return     HasFamilySource( FamLft )
           and HasFamilyRange(  FamLft )
           and IsIdentical( FamilySource( FamLft ), FamilyRange(  FamLft ) )
           and HasFamilySource( FamRgt )
           and IsIdentical( FamilySource( FamRgt ), FamilyRange(  FamLft ) );
end;


#############################################################################
##
#F  FamSourceNotEqFamElm( <FamMap>, <FamElm> )
##
FamSourceNotEqFamElm := function( FamMap, FamElm )
    return not FamSourceEqFamElm( FamMap, FamElm );
end;


#############################################################################
##
#F  FamRangeNotEqFamElm( <FamMap>, <FamElm> )
##
FamRangeNotEqFamElm := function( FamMap, FamElm )
    return not FamRangeEqFamElm( FamMap, FamElm );
end;


#############################################################################
##
#F  IsMagmaRingsRings( <FamRM>, <FamR> )  . . . . . . . . .  family predicate
#F  IsRingsMagmaRings( <FamR>, <FamRM> )  . . . . . . . . .  family predicate
#F  IsMagmasMagmaRings( <FamM>, <FamRM> ) . . . . . . . . .  family predicate
##
IsMagmaRingsRings := function( FamRM, FamR )
    return     IsBound( FamRM!.familyRing )
           and IsIdentical( ElementsFamily( FamRM!.familyRing ), FamR );
end;

IsRingsMagmaRings := function( FamR, FamRM )
    return     IsBound( FamRM!.familyRing )
           and IsIdentical( ElementsFamily( FamRM!.familyRing ), FamR );
end;

IsMagmasMagmaRings := function( FamM, FamRM )
    return     IsBound( FamRM!.familyMagma )
           and IsIdentical( ElementsFamily( FamRM!.familyMagma ), FamM );
end;


#############################################################################
##
#E  fampred.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



