#############################################################################
##
#W  rest.gd                     GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares various odds and ends.
##
Revision.rest_gd :=
    "@(#)$Id$";


# Flags
FlagsFamily := NewFamily( "FlagsFamily", IsObject );
KIND_FLAGS  := NewKind(    FlagsFamily,  IsInternalRep );


# Functions

FunctionsFamily         := NewFamily(  "FunctionsFamily", IsFunction );
KIND_FUNCTION           := NewKind(     FunctionsFamily,
                            IsFunction and IsInternalRep );

# Integers, Rationals, and Cyclotomics

IsCyclotomic            := NewCategory( "IsCyclotomic",
    IsScalar and IsAssociativeElement and IsCommutativeElement );

IsCyclotomicsCollection := CategoryCollections(
    "IsCyclotomicsCollection", IsCyclotomic );
IsCyclotomicsCollColl   := CategoryCollections(
    "IsCyclotomicsCollColl", IsCyclotomicsCollection );

IsCyc                   := NewCategoryKernel( "IsCyc", IsCyclotomic,
                            IS_CYC );

IsRat                   := NewCategoryKernel( "IsRat", IsCyc, IS_RAT );

IsInt                   := NewCategoryKernel( "IsInt", IsRat, IS_INT );

IsPosRat                := NewCategory( "IsPosRat",      IsRat );
IsNegRat                := NewCategory( "IsNegRat",      IsRat );
IsZeroCyc               := NewCategory( "IsZeroCyc",     IsInt );

IsCycInt                := IS_CYC_INT;
COEFFSCYC               := COEFFS_CYC;
NofCyc                  := NewOperationKernel( "NofCyc", [ IsCyc ],
                            N_OF_CYC );
GaloisCyc               := NewOperationKernel( "GaloisCyc",
                            [ IsCyc, IsInt ], GALOIS_CYC );

NumeratorRat            := NUMERATOR_RAT;
DenominatorRat          := DENOMINATOR_RAT;

QuoInt                  := QUO_INT;
RemInt                  := REM_INT;
GcdInt                  := GCD_INT;


# Permutations
IsPerm                  := NewCategoryKernel( "IsPerm",
                            IsMultiplicativeElementWithInverse and
                            IsAssociativeElement and
                            IsFiniteOrderElement,
                            IS_PERM );

IsPermCollection        := CategoryCollections(
    "IsPermCollection", IsPerm );

SmallestMovedPointPerm := NewAttribute( "SmallestMovedPointPerm", IsPerm );
LargestMovedPointPerm := NewAttribute( "LargestMovedPointPerm", IsPerm );

# Booleans
IsBool                  := NewCategoryKernel( "IsBool", IsObject, IS_BOOL );
fail                    := FAIL;


# Characters
IsChar                  := NewCategory( "IsChar", IS_OBJECT );
#N  1996/08/23  M.Schoenert this is a hack because 'IsString' is a category
Add( CATEGORIES_COLLECTIONS, [ IsChar, IS_STRING ] );

# Records
IsRecord := NewCategoryKernel(
    "IsRecord",
    IsObject,
    IS_REC );

\.                      := NewOperationKernel( "ELM_REC",
                            [ IsObject, IsObject ], ELM_REC );
IsBound\.               := NewOperationKernel( "ISB_REC",
                            [ IsObject, IsObject ], ISB_REC );
\.\:\=                  := NewOperationKernel( "ASS_REC",
                            [ IsObject, IsObject, IsObject ], ASS_REC );
Unbind\.                := NewOperationKernel( "UNB_REC",
                            [ IsObject, IsObject ], UNB_REC );
RecNames                := REC_NAMES;


# Lists
IsString := NewCategoryKernel( 
    "IsString",
    IsDenseList,
    IS_STRING_CONV );

ConvertToStringRep      := CONV_STRING;

IsRange := NewCategoryKernel(
    "IsRange",
    IsCollection and IsDenseList,
    IS_RANGE );


#############################################################################
##

#F  ListSortedList(<list>)
##
##  'ListSortedList' returns a sorted list, containing the same elements as
##  the list <list> (which may have holes).
##  If <list> is already sorted, 'ListSortedList' returns <list> directly.
##  Otherwise it makes a shallow copy, sorts it, and removes duplicates.
##  'ListSortedList' is an internal function.
##
ListSortedList          := LIST_SORTED_LIST;

IsEqualSet              := IS_EQUAL_SET;
IsSubsetSet             := IS_SUBSET_SET;
AddSet                  := ADD_SET;
RemoveSet               := REM_SET;
UniteSet                := UNITE_SET;
IntersectSet            := INTER_SET;
SubtractSet             := SUBTR_SET;

IsBlist := NewCategoryKernel(
    "IsBlist",
    IsHomogeneousList,
    IS_BLIST );

BlistList               := BLIST_LIST;
ListBlist               := LIST_BLIST;
SizeBlist               := SIZE_BLIST;
IsSubsetBlist           := IS_SUB_BLIST;
UniteBlist              := UNITE_BLIST;
IntersectBlist          := INTER_BLIST;
SubtractBlist           := SUBTR_BLIST;

# Row Vectors
ConvertToVectorRep      := Ignore;

SCTableEntry            := SC_TABLE_ENTRY;
SCTableProduct          := SC_TABLE_PRODUCT;


#############################################################################
##
#F  PositionNot( <list>, <val> )
#F  PositionNot( <list>, <val>, <from-minus-one> )
##
PositionNot := function( arg )
    local i;

    if Length(arg) = 2  then
        for i  in [ 1 .. Length(arg[1]) ]  do
            if arg[1][i] <> arg[2] then
                return i;
            fi;
        od;
        return Length(arg[1]) + 1;

    elif Length(arg) = 3 then
        for i  in [ arg[3]+1 .. Length(arg[1]) ]  do
            if arg[1][i] <> arg[2] then
                return i;
            fi;
        od;
        return Length(arg[1]) + 1;

    else
      Error( "usage: PositionNot( <list>, <val>[, <from>] )" );
    fi;

end;


# Other
ReturnTrue  := RETURN_TRUE;
ReturnFalse := RETURN_FALSE;
ReturnFail  := RETURN_FAIL;
IdFunc      := ID_FUNC;


#############################################################################
##

#E  rest.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



