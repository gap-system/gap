#############################################################################
##
#W  fampred.g                    GAP library                    Etaoin Shrdlu
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file defines all family predicates
##

IsFamFamX := function( F1, F2, F3 )
    return IsIdenticalObj( F1, F2 );
end;

IsFamXFam := function( F1, F2, F3 )
    return IsIdenticalObj( F1, F3 );
end;

IsFamFamXY := function( F1, F2, F3, F4 )
    return IsIdenticalObj( F1, F2 );
end;

IsFamXYFamZ := function( F1, F2, F3, F4, F5 )
    return IsIdenticalObj( F1, F4 );
end;

IsFamXFamY := function( F1, F2, F3, F4 )
    return IsIdenticalObj( F1, F3 );
end;

IsFamFamFam := function( F1, F2, F3 )
    return IsIdenticalObj( F1, F2 )
       and IsIdenticalObj( F2, F3 );
end;

IsFamFamFamX := function( F1, F2, F3, F4 )
    return IsIdenticalObj( F1, F2 )
       and IsIdenticalObj( F1, F3 );
end;


#############################################################################
##
#O  IsElmsColls(<F1>,<F2>) test if a family is the elements family of another
##
IsElmsColls := function ( F1, F2 )
    return HasElementsFamily( F2 )
       and IsIdenticalObj( F1, ElementsFamily(F2) );
end;

IsNotElmsColls := function ( F1, F2 )
    return not HasElementsFamily( F2 )
       or IsNotIdenticalObj( F1, ElementsFamily(F2) );
end;

IsElmsCollColls := function ( F1, F2 )
    return HasElementsFamily( F2 )
       and HasElementsFamily( ElementsFamily( F2 ) )
       and IsIdenticalObj( F1, ElementsFamily( ElementsFamily( F2 ) ) );
end;

IsElmsCollsX := function( F1, F2, F3 )
    return HasElementsFamily( F2 )
       and IsIdenticalObj( F1, ElementsFamily( F2 ) );
end;

IsElmsCollCollsX := function ( F1, F2, F3 )
    return HasElementsFamily( F2 )
       and HasElementsFamily( ElementsFamily( F2 ) )
       and IsIdenticalObj( F1, ElementsFamily( ElementsFamily( F2 ) ) );
end;


#############################################################################
##
#O  IsCollsElms(<F1>,<F2>) test if a family is the elements family of another
##
IsCollsElms := function ( F1, F2 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( ElementsFamily(F1), F2 );
end;

IsCollCollsElms := function ( F1, F2 )
    return HasElementsFamily( F1 )
       and HasElementsFamily( ElementsFamily( F1 ) )
       and IsIdenticalObj( ElementsFamily( ElementsFamily( F1 ) ), F2 );
end;

IsCollCollsElmsElmsX := function ( F1, F2, F3, F4 )
    return HasElementsFamily( F1 )
       and HasElementsFamily( ElementsFamily( F1 ) )
       and IsIdenticalObj( ElementsFamily( ElementsFamily( F1 ) ), F2 )
       and IsIdenticalObj( F2, F3 );
end;


#############################################################################
##
#O  IsCollsElmsElms( <F1>, <F2>, <F3> )
##
IsCollsElmsX := function( F1, F2, F3 )
    return HasElementsFamily(F1)
       and IsIdenticalObj( ElementsFamily(F1), F2 );
end;

IsCollsElmsElms := function( F1, F2, F3 )
    return HasElementsFamily(F1)
       and IsIdenticalObj( ElementsFamily(F1), F2 )
       and IsIdenticalObj( F2, F3 );
end;

IsCollsElmsElmsElms := function( F1, F2, F3, F4 )
    return HasElementsFamily(F1)
       and IsIdenticalObj( ElementsFamily(F1), F2 )
       and IsIdenticalObj( F2, F3 )
       and IsIdenticalObj( F2, F4 );
end;

IsCollsElmsElmsX := function( F1, F2, F3, F4 )
    return HasElementsFamily(F1)
       and IsIdenticalObj( ElementsFamily(F1), F2 )
       and IsIdenticalObj( F2, F3 );
end;

IsCollsElmsXElms := function( F1, F2, F3, F4 )
    return HasElementsFamily(F1)
       and IsIdenticalObj( ElementsFamily(F1), F2 )
       and IsIdenticalObj( F2, F4 );
end;

IsCollCollsElmsElms := function( F1, F2, F3 )
    return HasElementsFamily(F1)
       and HasElementsFamily( ElementsFamily(F1) )
       and IsIdenticalObj( ElementsFamily( ElementsFamily(F1) ), F2 )
       and IsIdenticalObj( F2, F3 );
end;

IsCollsCollsElms := function( F1, F2, F3 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( F1, F2 )
       and IsIdenticalObj( ElementsFamily( F1 ), F3 );
end;

IsCollsCollsElmsX := function( F1, F2, F3, F4 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( F1, F2 )
       and IsIdenticalObj( ElementsFamily( F1 ), F3 );
end;

IsCollsCollsElmsXX := function( F1, F2, F3, F4, F5 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( F1, F2 )
       and IsIdenticalObj( ElementsFamily( F1 ), F3 );
end;

IsCollsElmsColls := function( F1, F2, F3 )
    return IsIdenticalObj(F1, F3)
       and HasElementsFamily(F1)
       and IsIdenticalObj(F2, ElementsFamily(F1));
end;


IsCollsXElms := function( F1, F2, F3 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( F3, ElementsFamily( F1 ) );
end;

IsCollsXElmsX := function( F1, F2, F3, F4 )
    return HasElementsFamily( F1 )
       and IsIdenticalObj( F3, ElementsFamily( F1 ) );
end;

IsElmsCollsXX := function( F1, F2, F3, F4)
    return HasElementsFamily( F2 ) and 
           IsIdenticalObj(F1, ElementsFamily(F2));
end;

IsCollsElmsXX := function( F1, F2, F3, F4)
    return HasElementsFamily( F1 ) and 
           IsIdenticalObj(F2, ElementsFamily(F1));
end;

#############################################################################
##
#F  IsLieFamFam( <LieFam>, <Fam> )  . . . . . . . . . . . .  family predicate
#F  IsFamLieFam( <Fam>, <LieFam> )  . . . . . . . . . . . .  family predicate
#F  IsElmsLieColls( <Fam1>, <Fam2> )  . . . . . . . . . . .  family predicate
#F  IsElmsCollLieColls( <Fam1>, <Fam2> )  . . . . . . . . .  family predicate
##
IsLieFamFam := function( LieFam, Fam )
    return HasLieFamily( Fam ) and IsIdenticalObj( LieFamily( Fam ), LieFam );
end;

IsFamLieFam := function( Fam, LieFam )
    return HasLieFamily( Fam ) and IsIdenticalObj( LieFamily( Fam ), LieFam );
end;

IsElmsLieColls := function( Fam1, Fam2 )
    return     HasCollectionsFamily( Fam1 )
           and HasLieFamily( CollectionsFamily( Fam1 ) )
           and IsIdenticalObj( LieFamily( CollectionsFamily( Fam1 ) ), Fam2 );
end;

IsElmsCollLieColls := function( Fam1, Fam2 )
    return     HasCollectionsFamily( Fam1 )
           and HasLieFamily( CollectionsFamily( Fam1 ) )
           and HasCollectionsFamily( LieFamily( CollectionsFamily( Fam1 ) ) )
           and IsIdenticalObj( CollectionsFamily( LieFamily(
                                CollectionsFamily( Fam1 ) ) ), Fam2 );
end;

IsCollLieCollsElms := function( Fam1, Fam2 )
    return     HasCollectionsFamily( Fam2 )
           and HasLieFamily( CollectionsFamily( Fam2 ) )
           and HasCollectionsFamily( LieFamily( CollectionsFamily( Fam2 ) ) )
           and IsIdenticalObj( CollectionsFamily( LieFamily(
                                CollectionsFamily( Fam2 ) ) ), Fam1 );
end;


#############################################################################
##
#F  IsCoeffsElms( <coeff>, <elm> )
##
IsCoeffsElms := function( F1, F2 )
    return HasCoefficientsFamily(F2)
       and IsIdenticalObj( F1, CoefficientsFamily(F2) );
end;


#############################################################################
##
#F  IsElmsCoeffs( <elm>, <coeff> )
##
IsElmsCoeffs := function( F1, F2 )
    return HasCoefficientsFamily(F1)
       and IsIdenticalObj( CoefficientsFamily(F1), F2 );
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
           and IsIdenticalObj( FamElm, FamilyRange( FamMap ) );
end;


#############################################################################
##
#F  FamSourceEqFamElm( <FamMap>, <FamElm> )
##
FamSourceEqFamElm := function( FamMap, FamElm )
    return     HasFamilySource( FamMap )
           and IsIdenticalObj( FamElm, FamilySource( FamMap ) );
end;


#############################################################################
##
#F  CollFamRangeEqFamElms( <FamMap>, <FamElms> )
##
CollFamRangeEqFamElms := function( FamMap, FamElms )
    return     HasFamilyRange( FamMap )
           and HasElementsFamily( FamElms )
           and IsIdenticalObj( ElementsFamily( FamElms ),
                            FamilyRange( FamMap ) );
end;


#############################################################################
##
#F  CollFamSourceEqFamElms( <FamMap>, <FamElms> )
##
CollFamSourceEqFamElms := function( FamMap, FamElms )
    return     HasFamilySource( FamMap )
           and HasElementsFamily( FamElms )
           and IsIdenticalObj( ElementsFamily( FamElms ),
                            FamilySource( FamMap ) );
end;


#############################################################################
##
#F  FamElmEqFamRange( <FamElm>, <FamMap> )
##
FamElmEqFamRange := function( FamElm, FamMap )
    return     HasFamilyRange( FamMap )
           and IsIdenticalObj( FamElm, FamilyRange( FamMap ) );
end;


#############################################################################
##
#F  FamElmEqFamSource( <FamElm>, <FamMap> )
##
FamElmEqFamSource := function( FamElm, FamMap )
    return     HasFamilySource( FamMap )
           and IsIdenticalObj( FamElm, FamilySource( FamMap ) );
end;


#############################################################################
##
#F  FamSource2EqFamRange1( <Fam1>, <Fam2> )
##
FamSource2EqFamRange1 := function( Fam1, Fam2 )
    return     HasFamilySource( Fam2 )
           and HasFamilyRange(  Fam1 )
           and IsIdenticalObj( FamilyRange( Fam1 ), FamilySource( Fam2 ) );
end;


#############################################################################
##
#F  FamSource1EqFamRange2( <Fam1>, <Fam2> )
##
FamSource1EqFamRange2 := function( Fam1, Fam2 )
    return     HasFamilySource( Fam1 )
           and HasFamilyRange(  Fam2 )
           and IsIdenticalObj( FamilyRange( Fam2 ), FamilySource( Fam1 ) );
end;


#############################################################################
##
#F  FamRange1EqFamRange2( <Fam1>, <Fam2> )
##
FamRange1EqFamRange2 := function( Fam1, Fam2 )
    return     HasFamilyRange( Fam1 )
           and HasFamilyRange( Fam2 )
           and IsIdenticalObj( FamilyRange( Fam1 ), FamilyRange( Fam2 ) );
end;


#############################################################################
##
#F  FamSource1EqFamSource2( <Fam1>, <Fam2> )
##
FamSource1EqFamSource2 := function( Fam1, Fam2 )
    return     HasFamilySource( Fam1 )
           and HasFamilySource( Fam2 )
           and IsIdenticalObj( FamilySource( Fam1 ), FamilySource( Fam2 ) );
end;


#############################################################################
##
#F  FamMapFamSourceFamRange( <FamMap>, <FamElm1>, <FamElm2> )
##
FamMapFamSourceFamRange := function( FamMap, FamElm1, FamElm2 )
    return     HasFamilySource( FamMap )
           and HasFamilyRange(  FamMap )
           and IsIdenticalObj( FamilySource( FamMap ), FamElm1 )
           and IsIdenticalObj( FamilyRange(  FamMap ), FamElm2 );
end;


#############################################################################
##
#F  FamSourceRgtEqFamsLft( <FamLft>, <FamRgt> )
##
FamSourceRgtEqFamsLft := function( FamLft, FamRgt )
    return     HasFamilySource( FamLft )
           and HasFamilyRange(  FamLft )
           and IsIdenticalObj( FamilySource( FamLft ), FamilyRange(  FamLft ) )
           and HasFamilySource( FamRgt )
           and IsIdenticalObj( FamilySource( FamRgt ), FamilyRange(  FamLft ) );
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
#F  IsMagmaRingsRings( <FamRMelm>, <FamRelm> )  . . . . . .  family predicate
#F  IsMagmaRingsMagmas( <FamRMelm>, <FamMelm> ) . . . . . .  family predicate
#F  IsRingsMagmaRings( <FamRelm>, <FamRMelm> )  . . . . . .  family predicate
#F  IsMagmasMagmaRings( <FamMelm>, <FamRMelm> ) . . . . . .  family predicate
##
IsMagmaRingsRings := function( FamRM, FamR )
    return     IsBound( FamRM!.familyRing )
           and IsIdenticalObj( ElementsFamily( FamRM!.familyRing ), FamR );
end;

IsMagmaRingsMagmas := function( FamRM, FamM )
    return     IsBound( FamRM!.familyMagma )
           and IsIdenticalObj( ElementsFamily( FamRM!.familyMagma ), FamM );
end;

IsRingsMagmaRings := function( FamR, FamRM )
    return     IsBound( FamRM!.familyRing )
           and IsIdenticalObj( ElementsFamily( FamRM!.familyRing ), FamR );
end;

IsMagmasMagmaRings := function( FamM, FamRM )
    return     IsBound( FamRM!.familyMagma )
           and IsIdenticalObj( ElementsFamily( FamRM!.familyMagma ), FamM );
end;

IsMagmaCollsMagmaRingColls := function( FamM, FamRM )
    return     HasElementsFamily( FamM )
           and HasElementsFamily( FamRM )
           and IsBound( ElementsFamily( FamRM )!.familyMagma )
           and IsIdenticalObj( ElementsFamily( FamRM )!.familyMagma, FamM );
end;

IsRingCollsMagmaRingColls := function( FamR, FamRM )
    return     HasElementsFamily( FamR )
           and HasElementsFamily( FamRM )
           and IsBound( ElementsFamily( FamRM )!.familyRing )
           and IsIdenticalObj( ElementsFamily( FamRM )!.familyRing, FamR );
end;


#############################################################################
##
#E  fampred.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
