#############################################################################
##
#W  list.g                        GAP library                Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains some  list types and functions that  have to be  known
##  very early in the bootstrap stage (therefore they are not in list.gi)
##
Revision.list_g :=
    "@(#)$Id$";


#############################################################################
##

#V  ListsFamily	. . . . . . . . . . . . . . . . . . . . . . . family of lists
##
ListsFamily := NewFamily(  "ListsFamily", IsList );


#############################################################################
##
#V  TYPE_LIST_NDENSE_MUTABLE  . . . . . . . . type of non-dense, mutable list
##
TYPE_LIST_NDENSE_MUTABLE := NewType( ListsFamily,
    IsMutable and IsList and IsInternalRep );


#############################################################################
##
#V  TYPE_LIST_NDENSE_IMMUTABLE	. . . . . . type of non-dense, immutable list
##
TYPE_LIST_NDENSE_IMMUTABLE := NewType( ListsFamily,
    IsList and IsInternalRep );


#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_MUTABLE  . . . type of dense, non-homo, mutable list
##
TYPE_LIST_DENSE_NHOM_MUTABLE := NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsInternalRep );


#############################################################################
##V  TYPE_LIST_DENSE_NHOM_IMMUTABLE  . type of dense, non-homo, immutable list
##
TYPE_LIST_DENSE_NHOM_IMMUTABLE := NewType( ListsFamily,
    IsList and IsDenseList and IsInternalRep );


#############################################################################
##
#V  TYPE_LIST_EMPTY_MUTABLE . . . . . . . . . type of the empty, mutable list
##
TYPE_LIST_EMPTY_MUTABLE := NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsInternalRep );


#############################################################################
##
#V  TYPE_LIST_EMPTY_IMMUTABLE . . . . . . . type of the empty, immutable list
##
TYPE_LIST_EMPTY_IMMUTABLE := NewType( ListsFamily,
    IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsInternalRep );


#############################################################################
##
#F  TYPE_LIST_HOM( <family>, <kernel_number> )	. . return the type of a list
##
##  For <kernel_number> see "objects.h" and "plist.c":
##
##   1: T_PLIST_HOM
##   2: T_PLIST_HOM       + IMMUTABLE
##   3: T_PLIST_HOM_NSORT
##   4: T_PLIST_HOM_NSORT + IMMUTABLE
##   5: T_PLIST_HOM_SSORT
##   6: T_PLIST_HOM_SSORT + IMMUTABLE
##   7: T_PLIST_TAB
##   8: T_PLIST_TAB       + IMMUTABLE
##   9: T_PLIST_TAB_NSORT
##  10: T_PLIST_TAB_NSORT + IMMUTABLE
##  11: T_PLIST_TAB_SSORT
##  12: T_PLIST_TAB_SSORT + IMMUTABLE
##
TYPE_LIST_HOM := function ( family, knr )
    local   colls;

    colls := CollectionsFamily( family );

    # T_PLIST_HOM
    if   knr = 1  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsInternalRep );

    # T_PLIST_HOM + IMMUTABLE
    elif knr = 2  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsInternalRep );

    # T_PLIST_HOM_NSORT
    elif knr = 3  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsInternalRep );

    # T_PLIST_HOM_NSORT + IMMUTABLE
    elif knr = 4  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsInternalRep );

    # T_PLIST_HOM_SSORT
    elif knr = 5  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsSSortedList and
                        IsInternalRep );

    # T_PLIST_HOM_SSORT + IMMUTABLE
    elif knr = 6  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsSSortedList and
                        IsInternalRep );

    # T_PLIST_TAB
    elif knr = 7  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and IsInternalRep );

    # T_PLIST_TAB + IMMUTABLE
    elif knr = 8  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and IsInternalRep );

    # T_PLIST_TAB_NSORT
    elif knr = 9  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable
                        and IsInternalRep );

    # T_PLIST_TAB_NSORT + IMMUTABLE
    elif knr = 10  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable
                        and IsInternalRep );

    # T_PLIST_TAB_SSORT
    elif knr = 11  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsSSortedList and IsTable and IsInternalRep );

    # T_PLIST_TAB_SSORT + IMMUTABLE
    elif knr = 12  then
        return NewType( colls,
                        IsList and IsDenseList and IsHomogeneousList
                        and IsCollection and IsSSortedList and IsTable
                        and IsInternalRep );

    else
        Error( "what?  Unknown kernel number ", knr );
    fi;
end;


#############################################################################
##

#C  IsRange . . . . . . . . . . . . . . . . . . . . . . .  category of ranges
##
IsRange := NewCategoryKernel(
    "IsRange",
    IsCollection and IsDenseList,
    IS_RANGE );


#############################################################################
##
#V  TYPE_RANGE_SSORT_MUTABLE  . . . . . . . . . type of sorted, mutable range
##
TYPE_RANGE_SSORT_MUTABLE := Subtype(
                            TYPE_LIST_HOM( CyclotomicsFamily, 4 ),
                            IsRange and IsMutable );


#############################################################################
##
#V  TYPE_RANGE_NSORT_MUTABLE  . . . . . . . . type of unsorted, mutable range
##
TYPE_RANGE_NSORT_MUTABLE := Subtype(
                            TYPE_LIST_HOM( CyclotomicsFamily, 2 ),
                            IsRange and IsMutable );


#############################################################################
##
#V  TYPE_RANGE_SSORT_IMMUTABLE  . . . . . . . type of sorted, immutable range
##
TYPE_RANGE_SSORT_IMMUTABLE := Subtype(
                              TYPE_LIST_HOM( CyclotomicsFamily, 4 ),
                              IsRange );


#############################################################################
##
#V  TYPE_RANGE_NSORT_IMMUTABLE  . . . . . . type of unsorted, immutable range
##
TYPE_RANGE_NSORT_IMMUTABLE := Subtype(
                              TYPE_LIST_HOM( CyclotomicsFamily, 2 ),
                              IsRange );


#############################################################################
##

#C  IsBlist . . . . . . . . . . . . . . . . . . . . category of boolean lists
##
IsBlist := NewCategoryKernel(
    "IsBlist",
    IsHomogeneousList,
    IS_BLIST );


#############################################################################
##
#F  BlistList( <list>, <sub> )  . . . . . . . . . boolean list from a sublist
##
BlistList := BLIST_LIST;


#############################################################################
##
#F  ListBlist( <list>, <blist> )  . . . . . . .  sublist from a list by blist
##
ListBlist := LIST_BLIST;


#############################################################################
##
#F  SizeBlist( <blist> )  . . . . . . . . . . . . . . . . . . number of trues
##
SizeBlist               := SIZE_BLIST;


#############################################################################
##
#F  IsSubsetBlist( <blist1>, <blist2> ) . .  <blist2> and <blist1> = <blist2>
##
IsSubsetBlist := IS_SUB_BLIST;


#############################################################################
##
#F  UniteBlist( <blist1>, <blist2> )  . . .  <blist1> := <blist1> or <blist2>
##
UniteBlist := UNITE_BLIST;


#############################################################################
##
#F  IntersectBlist( <blist1>, <blist2> )  . <blist1> := <blist1> and <blist2>
##
IntersectBlist := INTER_BLIST;


#############################################################################
##
#F  SubtractBlist( <blist1>, <blist2> ) <blist1> := <blist1> and not <blist2>
##
SubtractBlist := SUBTR_BLIST;


#############################################################################
##
#F  ConvertToVectorRep( <list> )  . . . . . . . . convert to internal vectors
##
ConvertToVectorRep := Ignore;


#############################################################################
##
#F  PositionNot( <list>, <val> [,<from-minus-one>] )  . . . .  find not <val>
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


#############################################################################
##

#E  list.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
