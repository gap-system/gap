#############################################################################
##
#W  list.g                        GAP library                Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains some  list types and functions that  have to be  known
##  very early in the bootstrap stage (therefore they are not in list.gi)
##
Revision.list_g :=
    "@(#)$Id$";


#############################################################################
##

#R  IsPlistRep  . . . . . . . . . . . . . . . . representation of plain lists
##
DeclareRepresentationKernel( "IsPlistRep",
    IsInternalRep, [], IS_OBJECT, IS_PLIST_REP );


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
    IsMutable and IsList and IsPlistRep );


#############################################################################
##
#V  TYPE_LIST_NDENSE_IMMUTABLE	. . . . . . type of non-dense, immutable list
##
TYPE_LIST_NDENSE_IMMUTABLE := NewType( ListsFamily,
    IsList and IsPlistRep );


#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_MUTABLE  . . . type of dense, non-homo, mutable list
##
TYPE_LIST_DENSE_NHOM_MUTABLE := NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsPlistRep );


#############################################################################
##
##V  TYPE_LIST_DENSE_NHOM_IMMUTABLE  . type of dense, non-homo, immutable list
##
TYPE_LIST_DENSE_NHOM_IMMUTABLE := NewType( ListsFamily,
    IsList and IsDenseList and IsPlistRep );


#############################################################################
##
#V  TYPE_LIST_EMPTY_MUTABLE . . . . . . . . . type of the empty, mutable list
##
TYPE_LIST_EMPTY_MUTABLE := NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsPlistRep );


#############################################################################
##
#V  TYPE_LIST_EMPTY_IMMUTABLE . . . . . . . type of the empty, immutable list
##
TYPE_LIST_EMPTY_IMMUTABLE := NewType( ListsFamily,
    IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsPlistRep );


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
##  13: T_PLIST_CYC
##  14: T_PLIST_CYC       + IMMUTABLE
##  15: T_PLIST_CYC_NSORT
##  16: T_PLIST_CYC_NSORT + IMMUTABLE
##  17: T_PLIST_CYC_SSORT
##  18: T_PLIST_CYC_SSORT + IMMUTABLE
##
TYPE_LIST_HOM := function ( family, knr )
    local   colls;

    colls := CollectionsFamily( family );
    
    # The Cyclotomic types behave just like the corresponding
    # homogenous types
    
    if knr > 12 then
        knr := knr -12;
    fi;
    
    # T_PLIST_HOM
    if   knr = 1  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsPlistRep );

    # T_PLIST_HOM + IMMUTABLE
    elif knr = 2  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsPlistRep );

    # T_PLIST_HOM_NSORT
    elif knr = 3  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsPlistRep );

    # T_PLIST_HOM_NSORT + IMMUTABLE
    elif knr = 4  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsPlistRep );

    # T_PLIST_HOM_SSORT
    elif knr = 5  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsSSortedList and
                        IsPlistRep );

    # T_PLIST_HOM_SSORT + IMMUTABLE
    elif knr = 6  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsSSortedList and
                        IsPlistRep );

    # T_PLIST_TAB
    elif knr = 7  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and IsPlistRep );

    # T_PLIST_TAB + IMMUTABLE
    elif knr = 8  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and IsPlistRep );

    # T_PLIST_TAB_NSORT
    elif knr = 9  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable
                        and IsPlistRep );

    # T_PLIST_TAB_NSORT + IMMUTABLE
    elif knr = 10  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable
                        and IsPlistRep );

    # T_PLIST_TAB_SSORT
    elif knr = 11  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsSSortedList and IsTable and IsPlistRep );

    # T_PLIST_TAB_SSORT + IMMUTABLE
    elif knr = 12  then
        return NewType( colls,
                        IsList and IsDenseList and IsHomogeneousList
                        and IsCollection and IsSSortedList and IsTable
                        and IsPlistRep );

    else
        Error( "what?  Unknown kernel number ", knr );
    fi;
end;


#############################################################################
##
#M  ASS_LIST( <plist>, <pos>, <obj> ) . . . . . . . . . .  default assignment
##
InstallMethod( ASS_LIST,
    "for plain list and external objects",
    true,
    [ IsMutable and IsList and IsPlistRep,
      IsPosInt,
      IsObject ],
    0,
    ASS_PLIST_DEFAULT );


#############################################################################
##
#C  IsRange . . . . . . . . . . . . . . . . . . . . . . .  category of ranges
##
##  ranges are a special representation for dense duplicate free lists of
##  integers in arithmetic progression. If a list of integers is in
##  arithmetic progression, `IsRange' will automatically change its
##  representation to `IsRange'.
#T NO !!
#T this will change!!

#DeclareCategory(IsRange,IsCollection and IsDenseList);
DeclareCategoryKernel( "IsRange",
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
DeclareCategoryKernel( "IsBlist",
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
PositionNot := POSITION_NOT;


#############################################################################
##

#E  list.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
