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
    if HasElementsFamily( FamMap ) then
      FamMap:= ElementsFamily( FamMap );
      if HasComponentsOfTuplesFamily( FamMap ) then
        return IsIdentical( FamElm, ComponentsOfTuplesFamily( FamMap )[2] );
      fi;
    fi;
    return false;
end;


#############################################################################
##
#F  FamSourceEqFamElm( <FamMap>, <FamElm> )
##
FamSourceEqFamElm := function( FamMap, FamElm )
    if HasElementsFamily( FamMap ) then
      FamMap:= ElementsFamily( FamMap );
      if HasComponentsOfTuplesFamily( FamMap ) then
        return IsIdentical( FamElm, ComponentsOfTuplesFamily( FamMap )[1] );
      fi;
    fi;
    return false;
end;


#############################################################################
##
#F  CollFamRangeEqFamElms( <FamMap>, <FamElms> )
##
CollFamRangeEqFamElms := function( FamMap, FamElms )
    if HasElementsFamily( FamMap ) and HasElementsFamily( FamElms ) then
      FamMap:= ElementsFamily( FamMap );
      if HasComponentsOfTuplesFamily( FamMap ) then
        return IsIdentical( ElementsFamily( FamElms ),
                            ComponentsOfTuplesFamily( FamMap )[2] );
      fi;
    fi;
    return false;
end;


#############################################################################
##
#F  CollFamSourceEqFamElms( <FamMap>, <FamElms> )
##
CollFamSourceEqFamElms := function( FamMap, FamElms )
    if HasElementsFamily( FamMap ) and HasElementsFamily( FamElms ) then
      FamMap:= ElementsFamily( FamMap );
      if HasComponentsOfTuplesFamily( FamMap ) then
        return IsIdentical( ElementsFamily( FamElms ),
                            ComponentsOfTuplesFamily( FamMap )[1] );
      fi;
    fi;
    return false;
end;


#############################################################################
##
#F  FamElmEqFamSource( <FamElm>, <FamMap> )
##
FamElmEqFamSource := function( FamElm, FamMap )
    if HasElementsFamily( FamMap ) then
      FamMap:= ElementsFamily( FamMap );
      if HasComponentsOfTuplesFamily( FamMap ) then
        return IsIdentical( FamElm, ComponentsOfTuplesFamily( FamMap )[1] );
      fi;
    fi;
    return false;
end;


#############################################################################
##
#F  FamElmEqFamRange( <FamElm>, <FamMap> )
##
FamElmEqFamRange := function( FamElm, FamMap )
    if HasElementsFamily( FamMap ) then
      FamMap:= ElementsFamily( FamMap );
      if HasComponentsOfTuplesFamily( FamMap ) then
        return IsIdentical( FamElm, ComponentsOfTuplesFamily( FamMap )[2] );
      fi;
    fi;
    return false;
end;


#############################################################################
##
#F  FamSource2EqFamRange1( <Fam1>, <Fam2> )
##
FamSource2EqFamRange1 := function( Fam1, Fam2 )
    if HasElementsFamily( Fam1 ) and HasElementsFamily( Fam2 ) then
      Fam1:= ElementsFamily( Fam1 );
      Fam2:= ElementsFamily( Fam2 );
      if     HasComponentsOfTuplesFamily( Fam1 )
         and HasComponentsOfTuplesFamily( Fam2 ) then
        return IsIdentical( ComponentsOfTuplesFamily( Fam2 )[1],
                            ComponentsOfTuplesFamily( Fam1 )[2] );
      fi;
    fi;
    return false;
end;


#############################################################################
##
#F  FamSource1EqFamRange2( <Fam1>, <Fam2> )
##
FamSource1EqFamRange2 := function( Fam1, Fam2 )
    if HasElementsFamily( Fam1 ) and HasElementsFamily( Fam2 ) then
      Fam1:= ElementsFamily( Fam1 );
      Fam2:= ElementsFamily( Fam2 );
      if     HasComponentsOfTuplesFamily( Fam1 )
         and HasComponentsOfTuplesFamily( Fam2 ) then
        return IsIdentical( ComponentsOfTuplesFamily( Fam1 )[1],
                            ComponentsOfTuplesFamily( Fam2 )[2] );
      fi;
    fi;
    return false;
end;


#############################################################################
##
#F  FamRange1EqFamRange2( <Fam1>, <Fam2> )
##
FamRange1EqFamRange2 := function( Fam1, Fam2 )
    if HasElementsFamily( Fam1 ) and HasElementsFamily( Fam2 ) then
      Fam1:= ElementsFamily( Fam1 );
      Fam2:= ElementsFamily( Fam2 );
      if     HasComponentsOfTuplesFamily( Fam1 )
         and HasComponentsOfTuplesFamily( Fam2 ) then
        return IsIdentical( ComponentsOfTuplesFamily( Fam1 )[2],
                            ComponentsOfTuplesFamily( Fam2 )[2] );
      fi;
    fi;
    return false;
end;


#############################################################################
##
#F  FamSource1EqFamSource2( <Fam1>, <Fam2> )
##
FamSource1EqFamSource2 := function( Fam1, Fam2 )
    if HasElementsFamily( Fam1 ) and HasElementsFamily( Fam2 ) then
      Fam1:= ElementsFamily( Fam1 );
      Fam2:= ElementsFamily( Fam2 );
      if     HasComponentsOfTuplesFamily( Fam1 )
         and HasComponentsOfTuplesFamily( Fam2 ) then
        return IsIdentical( ComponentsOfTuplesFamily( Fam1 )[1],
                            ComponentsOfTuplesFamily( Fam2 )[1] );
      fi;
    fi;
    return false;
end;


#############################################################################
##
#F  FamMapFamSourceFamRange( <FamMap>, <FamElm1>, <FamElm2> )
##
FamMapFamSourceFamRange := function( FamMap, FamElm1, FamElm2 )
    if HasElementsFamily( FamMap ) then
      FamMap:= ElementsFamily( FamMap );
      if HasComponentsOfTuplesFamily( FamMap ) then
        return IsIdentical( ComponentsOfTuplesFamily( FamMap )[1], FamElm1 )
           and IsIdentical( ComponentsOfTuplesFamily( FamMap )[2], FamElm2 );
      fi;
    fi;
    return false;
end;


#############################################################################
##
#F  FamSourceRgtEqFamsLft( <FamLft>, <FamRgt> )
##
FamSourceRgtEqFamsLft := function( FamLft, FamRgt )
    if HasElementsFamily( FamLft ) then
      FamLft:= ElementsFamily( FamLft );
      if HasComponentsOfTuplesFamily( FamLft ) then
        FamLft:= ComponentsOfTuplesFamily( FamLft );
        if     IsIdentical( FamLft[1], FamLft[2] )
           and HasElementsFamily( FamRgt ) then
          FamRgt:= ElementsFamily( FamRgt );
          if HasComponentsOfTuplesFamily( FamRgt ) then
            return IsIdentical( ComponentsOfTuplesFamily( FamRgt )[1],
                                    FamLft[2] );
          fi;
        fi;
      fi;
    fi;
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
#E  fampred.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



