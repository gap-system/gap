#############################################################################
##
#W  listkind.gi                   GAP library                Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains some list kinds that have to be known very early in
##  the bootstrap stage (therefore they are not in list.gi)
##
Revision.listkind_gi :=
    "@(#)$Id$";


#############################################################################
##

#V  ListsFamily	. . . . . . . . . . . . . . . . . . . . . . . family of lists
##
ListsFamily := NewFamily(  "ListsFamily", IsList );


#############################################################################
##
#K  KIND_LIST_NDENSE_MUTABLE
##
KIND_LIST_NDENSE_MUTABLE := NewKind( ListsFamily,
    IsMutable and IsList and IsInternalRep );


#############################################################################
##
#K  KIND_LIST_NDENSE_IMMUTABLE
##
KIND_LIST_NDENSE_IMMUTABLE := NewKind( ListsFamily,
    IsList and IsInternalRep );


#############################################################################
##
#K  KIND_LIST_DENSE_NHOM_MUTABLE
##
KIND_LIST_DENSE_NHOM_MUTABLE := NewKind( ListsFamily,
    IsMutable and IsList and IsDenseList and IsInternalRep );


#############################################################################
##
#K  KIND_LIST_DENSE_NHOM_IMMUTABLE
##
KIND_LIST_DENSE_NHOM_IMMUTABLE := NewKind( ListsFamily,
    IsList and IsDenseList and IsInternalRep );


#############################################################################
##
#K  KIND_LIST_EMPTY_MUTABLE
##
KIND_LIST_EMPTY_MUTABLE := NewKind( ListsFamily,
    IsMutable and IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsInternalRep );


#############################################################################
##
#K  KIND_LIST_EMPTY_IMMUTABLE
##
KIND_LIST_EMPTY_IMMUTABLE := NewKind( ListsFamily,
    IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsInternalRep );


#############################################################################
##
#F  KIND_LIST_HOM( <family>, <kernel_number> )
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
KIND_LIST_HOM := function ( family, knr )
    local   colls;

    colls := CollectionsFamily( family );

    # T_PLIST_HOM
    if   knr = 1  then
        return NewKind( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsInternalRep );

    # T_PLIST_HOM + IMMUTABLE
    elif knr = 2  then
        return NewKind( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsInternalRep );

    # T_PLIST_HOM_NSORT
    elif knr = 3  then
        return NewKind( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsInternalRep );

    # T_PLIST_HOM_NSORT + IMMUTABLE
    elif knr = 4  then
        return NewKind( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsInternalRep );

    # T_PLIST_HOM_SSORT
    elif knr = 5  then
        return NewKind( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsSSortedList and
                        IsInternalRep );

    # T_PLIST_HOM_SSORT + IMMUTABLE
    elif knr = 6  then
        return NewKind( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsSSortedList and
                        IsInternalRep );

    # T_PLIST_TAB
    elif knr = 7  then
        return NewKind( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and IsInternalRep );

    # T_PLIST_TAB + IMMUTABLE
    elif knr = 8  then
        return NewKind( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and IsInternalRep );

    # T_PLIST_TAB_NSORT
    elif knr = 9  then
        return NewKind( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable
                        and IsInternalRep );

    # T_PLIST_TAB_NSORT + IMMUTABLE
    elif knr = 10  then
        return NewKind( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable
                        and IsInternalRep );

    # T_PLIST_TAB_SSORT
    elif knr = 11  then
        return NewKind( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsSSortedList and IsTable and IsInternalRep );

    # T_PLIST_TAB_SSORT + IMMUTABLE
    elif knr = 12  then
        return NewKind( colls,
                        IsList and IsDenseList and IsHomogeneousList
                        and IsCollection and IsSSortedList and IsTable
                        and IsInternalRep );

    else
        Error("what?");
    fi;
end;


#############################################################################
##
#E  listkind.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
