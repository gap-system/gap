#############################################################################
##
#W  listtype.gi                   GAP library                Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains some list types that have to be known very early in
##  the bootstrap stage (therefore they are not in list.gi)
##
Revision.listtype_gi :=
    "@(#)$Id$";


#############################################################################
##

#V  ListsFamily	. . . . . . . . . . . . . . . . . . . . . . . family of lists
##
ListsFamily := NewFamily(  "ListsFamily", IsList );


#############################################################################
##
#K  TYPE_LIST_NDENSE_MUTABLE
##
TYPE_LIST_NDENSE_MUTABLE := NewType( ListsFamily,
    IsMutable and IsList and IsInternalRep );


#############################################################################
##
#K  TYPE_LIST_NDENSE_IMMUTABLE
##
TYPE_LIST_NDENSE_IMMUTABLE := NewType( ListsFamily,
    IsList and IsInternalRep );


#############################################################################
##
#K  TYPE_LIST_DENSE_NHOM_MUTABLE
##
TYPE_LIST_DENSE_NHOM_MUTABLE := NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsInternalRep );


#############################################################################
##
#K  TYPE_LIST_DENSE_NHOM_IMMUTABLE
##
TYPE_LIST_DENSE_NHOM_IMMUTABLE := NewType( ListsFamily,
    IsList and IsDenseList and IsInternalRep );


#############################################################################
##
#K  TYPE_LIST_EMPTY_MUTABLE
##
TYPE_LIST_EMPTY_MUTABLE := NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsInternalRep );


#############################################################################
##
#K  TYPE_LIST_EMPTY_IMMUTABLE
##
TYPE_LIST_EMPTY_IMMUTABLE := NewType( ListsFamily,
    IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsInternalRep );


#############################################################################
##
#F  TYPE_LIST_HOM( <family>, <kernel_number> )
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
        Error("what?");
    fi;
end;


#############################################################################
##
#E  listtype.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
