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
#C  IsListDefault( <obj> )  . . . . . . . . methods for arithmetic operations
##
##  Arithmetic operations with lists, such as the sum or product of
##  *two lists*, cannot be defined for arbitrary lists,
##  because this would cause problems for extensions of the range of objects
##  to be treated in {\GAP}.
##  For example, since we are interested in dealing with *Lie matrices*,
##  the product of two arbitrary matrices cannot be defined as the
##  ordinary matrix product.
##  Also the default method of pointwise addition of lists shall *not* be
##  applicable to Lie matrices, since then it would be legal that the result
##  is any list, not necessarily one that is a Lie matrix.
##
##  The solution is to restrict the scope of the default methods for
##  arithmetic operations to those lists in the category `IsListDefault'.
##  All internally represented lists are in this category, and also all
##  lists in the representations `IsGF2VectorRep' and `IsGF2MatrixRep'.
##
DeclareCategory( "IsListDefault", IsList );
#T this is not really clean ...

InstallTrueMethod( IsListDefault, IsInternalRep and IsList );

#############################################################################
##
#P  IsRectangularTable( <list> )  . . . . table with all rows the same length
##
##  A list lies in `IsRectangularTable' when it is nonempty and its elements
##  are all homogeneous lists of the same family and the same length.
##
##  This filter is a Property, not a Category, because it is not
##  always possible to determine cheaply the length of a row (which
##  might be some sort of Enumerator).  If the rows are plain lists
##  then this property should always be known (the kernel type determination
##  for plain lists handles this). Plain lists without mutable
##  elements will remember their rectangularity once it is determined.
##
DeclareProperty( "IsRectangularTable", IsList );

InstallTrueMethod( IsTable, IsRectangularTable );


#############################################################################
##
#v  ListsFamily	. . . . . . . . . . . . . . . . . . . . . . . family of lists
##
InstallValue( ListsFamily, NewFamily( "ListsFamily", IsList ) );


#############################################################################
##
#V  TYPE_LIST_NDENSE_MUTABLE  . . . . . . . . type of non-dense, mutable list
##
BIND_GLOBAL( "TYPE_LIST_NDENSE_MUTABLE", NewType( ListsFamily,
    IsMutable and IsList and IsPlistRep ) );


#############################################################################
##
#V  TYPE_LIST_NDENSE_IMMUTABLE	. . . . . . type of non-dense, immutable list
##
BIND_GLOBAL( "TYPE_LIST_NDENSE_IMMUTABLE", NewType( ListsFamily,
    IsList and IsPlistRep ) );


#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_MUTABLE  . . . type of dense, non-homo, mutable list
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_MUTABLE", NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsPlistRep ) );


#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_IMMUTABLE  . type of dense, non-homo, immutable list
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_IMMUTABLE", NewType( ListsFamily,
        IsList and IsDenseList and IsPlistRep ) );

#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE  . . . 
##                             type of dense, non-homo, ssorted, mutable list
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_SSORT_MUTABLE", NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsPlistRep and IsSSortedList ) );

#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE  . . . 
##                             type of dense, non-homo, nsorted, mutable list
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_NSORT_MUTABLE", NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsPlistRep ) );


#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE  . 
##                           type of dense, non-homo, ssorted, immutable list
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_SSORT_IMMUTABLE", NewType( ListsFamily,
        IsList and IsDenseList and IsPlistRep and IsSSortedList ) );

#############################################################################
##
#V  TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE  . 
##                           type of dense, non-homo, nsorted, immutable list
##
BIND_GLOBAL( "TYPE_LIST_DENSE_NHOM_NSORT_IMMUTABLE", NewType( ListsFamily,
        IsList and IsDenseList and IsPlistRep ) );

#############################################################################
##
#V  TYPE_LIST_EMPTY_MUTABLE . . . . . . . . . type of the empty, mutable list
##
BIND_GLOBAL( "TYPE_LIST_EMPTY_MUTABLE", NewType( ListsFamily,
    IsMutable and IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsString and IsPlistRep ) );


#############################################################################
##
#V  TYPE_LIST_EMPTY_IMMUTABLE . . . . . . . type of the empty, immutable list
##
BIND_GLOBAL( "TYPE_LIST_EMPTY_IMMUTABLE", NewType( ListsFamily,
    IsList and IsDenseList and IsHomogeneousList
    and IsEmpty and IsString and IsPlistRep ) );


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
##  13: T_PLIST_TAB_RECT
##  14: T_PLIST_TAB_RECT       + IMMUTABLE
##  15: T_PLIST_TAB_RECT_NSORT
##  16: T_PLIST_TAB_RECT_NSORT + IMMUTABLE
##  17: T_PLIST_TAB_RECT_SSORT
##  18: T_PLIST_TAB_RECT_SSORT + IMMUTABLE
##  19: T_PLIST_CYC
##  20: T_PLIST_CYC       + IMMUTABLE
##  21: T_PLIST_CYC_NSORT
##  22: T_PLIST_CYC_NSORT + IMMUTABLE
##  23: T_PLIST_CYC_SSORT
##  24: T_PLIST_CYC_SSORT + IMMUTABLE
##  25: T_PLIST_FFE
##  26: T_PLIST_FFE + IMMUTABLE
##
BIND_GLOBAL( "TYPE_LIST_HOM", function ( family, knr )
    local   colls;

    colls := CollectionsFamily( family );

    # The Cyclotomic types behave just like the corresponding
    # homogenous types

    if knr > 18 then 
        if knr < 25 then
            knr := knr -18;
        # The FFE types behave just like the corresponding
        # homogenous types
        else
            knr := knr -24;
        fi;
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
                        Tester(IsSSortedList) and
                        IsSSortedList and
                        IsPlistRep );

    # T_PLIST_HOM_SSORT + IMMUTABLE
    elif knr = 6  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
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
                        Tester(IsSSortedList) and
                        IsSSortedList and IsTable and IsPlistRep );

    # T_PLIST_TAB_SSORT + IMMUTABLE
    elif knr = 12  then
        return NewType( colls,
                        IsList and IsDenseList and IsHomogeneousList
                        and Tester(IsSSortedList)
                        and IsCollection and IsSSortedList and IsTable
                        and IsPlistRep );

    # T_PLIST_TAB_RECT
    elif knr = 13  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and HasIsRectangularTable and IsRectangularTable and IsPlistRep );

    # T_PLIST_TAB_RECT + IMMUTABLE
    elif knr = 14  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        IsTable and HasIsRectangularTable and IsRectangularTable and IsPlistRep );

    # T_PLIST_TAB_RECT_NSORT
    elif knr = 15  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable and HasIsRectangularTable and IsRectangularTable
                        and IsPlistRep );

    # T_PLIST_TAB_RECT_NSORT + IMMUTABLE
    elif knr = 16  then
        return NewType( colls,
                        IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and IsTable and HasIsRectangularTable and IsRectangularTable
                        and IsPlistRep );

    # T_PLIST_TAB_RECT_SSORT
    elif knr = 17  then
        return NewType( colls,
                        IsMutable and IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                        Tester(IsSSortedList) and
                        IsSSortedList and IsTable and HasIsRectangularTable and IsRectangularTable and IsPlistRep );

    # T_PLIST_TAB_RECT_SSORT + IMMUTABLE
    elif knr = 18  then
        return NewType( colls,
                        IsList and IsDenseList and IsHomogeneousList
                        and Tester(IsSSortedList)
                       and IsCollection and IsSSortedList and IsTable and HasIsRectangularTable 
                       and IsRectangularTable
                        and IsPlistRep );

    else
        Error( "what?  Unknown kernel number ", knr );
    fi;
end );


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
#C  IsRange( <obj> )
##
##  tests if <obj> is a range.
#T shouldn't this better be a property?
##

#DeclareCategory(IsRange,IsCollection and IsDenseList);
DeclareCategoryKernel( "IsRange",
    IsCollection and IsDenseList and IsCyclotomicCollection, IS_RANGE );


#############################################################################
##
#R  IsRangeRep( <obj> )
##
##  For internally represented ranges, there is a special representation
##  which requires only a small amount of memory.
##
DeclareRepresentationKernel( "IsRangeRep",                                   
    IsInternalRep, [], IS_OBJECT, IS_RANGE_REP );


#############################################################################
##
#F  ConvertToRangeRep( <list> )
##
##  For some lists the {\GAP} kernel knows that they are in fact ranges.
##  Those lists are represented internally in a compact way instead of the
##  ordinary way.
##
##  If <list> is a range then `ConvertToRangeRep' changes the representation
##  of <list> to this compact representation.
##
##  This is important since this representation needs only 12 bytes for
##  the entire range while the ordinary representation needs $4 length$
##  bytes.
##
##  Note that a list that is represented in the ordinary way might still be a
##  range.
##  It is just that {\GAP} does not know this.
##  The following rules tell you under which circumstances a range is
##  represented  in the compact way,
##  so you can write your program in such a way that you make best use of
##  this compact representation for ranges.
##
##  Lists created by the syntactic construct
##  `[ <first>, <second>  .. <last> ]' are of course known to be ranges and
##  are represented in the compact way.
##
##  If you call `ConvertToRangeRep' for a list represented the ordinary way
##  that is indeed a range, the representation is changed from the ordinary
##  to the compact representation.
##  A call of `ConvertToRangeRep' for a list that is not a range is
##  ignored.
##
##  If you change a mutable range that is represented in the compact way,
##  by assignment, `Add' or `Append', the range will be converted to the
##  ordinary representation, even if the change is such that the resulting
##  list is still a proper range.
##
##  Suppose you have built a proper range in such a way that it is
##  represented in the ordinary way and that you now want to convert it to
##  the compact representation to save space.
##  Then you should call `ConvertToRangeRep' with that list as an argument.
##  You can think of the call to `ConvertToRangeRep' as a hint to {\GAP}
##  that this list is a proper range.
##
BIND_GLOBAL( "ConvertToRangeRep", function( list )
    IsRange( list );
end );

#N
#N This must change -- a range is NOT is IS_PLIST_REP
#N

#############################################################################
##
#V  TYPE_RANGE_SSORT_MUTABLE  . . . . . . . . . type of sorted, mutable range
##
BIND_GLOBAL( "TYPE_RANGE_SSORT_MUTABLE", 
        NewType(CollectionsFamily(CyclotomicsFamily), 
                IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                Tester(IsSSortedList) and IsRange and IsMutable and
                IsSSortedList
                and IsRangeRep and IsInternalRep));


#############################################################################
##
#V  TYPE_RANGE_NSORT_MUTABLE  . . . . . . . . type of unsorted, mutable range
##
BIND_GLOBAL( "TYPE_RANGE_NSORT_MUTABLE", 
        NewType(CollectionsFamily(CyclotomicsFamily), 
                IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                Tester(IsSSortedList) and IsRange and IsMutable
                and IsRangeRep and IsInternalRep));



#############################################################################
##
#V  TYPE_RANGE_SSORT_IMMUTABLE  . . . . . . . type of sorted, immutable range
##
BIND_GLOBAL( "TYPE_RANGE_SSORT_IMMUTABLE", 
        NewType(CollectionsFamily(CyclotomicsFamily), 
                IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                Tester(IsSSortedList) and IsRange and
                IsSSortedList
                and IsRangeRep and IsInternalRep));


#############################################################################
##
#V  TYPE_RANGE_NSORT_IMMUTABLE  . . . . . . type of unsorted, immutable range
##
BIND_GLOBAL( "TYPE_RANGE_NSORT_IMMUTABLE", 
        NewType(CollectionsFamily(CyclotomicsFamily), 
                IsList and IsDenseList and
                        IsHomogeneousList and IsCollection and
                Tester(IsSSortedList) and IsRange 
                and IsRangeRep and IsInternalRep));




#############################################################################
##
#C  IsBlist(<obj>)
##
##  A boolean list (``blist'') is a list that has no holes and contains only
##  `true' and `false'. If a list is known to be a boolean list by a test
##  with `IsBlist' it is stored in a compact form. See "More about Boolean
##  Lists".
##
DeclareCategoryKernel( "IsBlist", IsHomogeneousList, IS_BLIST );


#############################################################################
##
#R  IsBlistRep( <obj> )
##
DeclareRepresentationKernel( "IsBlistRep",
    IsInternalRep, [], IS_OBJECT, IS_BLIST_REP );


#############################################################################
##
#F  BlistList(<list>,<sub>)
##
##  returns a new boolean list that describes the list <sub> as a sublist of
##  the dense list <list>.
##  That is `BlistList' returns a boolean list <blist> of the same length as
##  <list> such that `<blist>[<i>]' is `true' if `<list>[<i>]' is in
##  <sub> and `false' otherwise.
##
##  <list> need not be a proper set (see~"Sorted Lists and Sets"),
##  even though in this case `BlistList' is most efficient.
##  In particular <list> may contain duplicates.
##  <sub> need not be a proper sublist of <list>,
##  i.e., <sub> may contain elements that are not in <list>.
##  Those elements of course have no influence on the result of `BlistList'.
##
DeclareSynonym( "BlistList", BLIST_LIST );


#############################################################################
##
#O  ListBlist(<list>,<blist>)
##
##  returns the sublist <sub> of the list <list>, which must have no holes,
##  represented  by the boolean  list <blist>, which  must have the same
##  length   as  <list>.   <sub> contains  the  element `<list>[<i>]' if
##  `<blist>[<i>]'     is  `true' and   does    not contain   the element
##  if `<blist>[<i>]'  is `false'.  The  order of  the elements  in <sub> is
##  the same as the order of the corresponding elements in <list>.
##
DeclareSynonym( "ListBlist", LIST_BLIST );


#############################################################################
##
#F  SizeBlist(<blist>)
##
##  returns  the number of  entries of  the boolean  list <blist> that are
##  `true'.   This  is the size  of  the subset represented  by  the boolean
##  list <blist>.
##
DeclareSynonym( "SizeBlist", SIZE_BLIST );


#############################################################################
##
#F  IsSubsetBlist(<blist1>,<blist2>)
##
## returns `true' if  the boolean list  <blist2> is a subset of  the boolean
## list <list1>, which  must have equal  length, and `false' otherwise.
## <blist2> is  a subset of  <blist1>  if `<blist1>[<i>]   =
## <blist1>[<i>] or <blist2>[<i>]' for all <i>.
##
DeclareSynonym( "IsSubsetBlist", IS_SUB_BLIST );


#############################################################################
##
#F  UniteBlist( <blist1>, <blist2> )
##
##  `UniteBlist'   unites the boolean list  <blist1>   with the boolean
##  list <blist2>,   which must  have the  same  length.    This is
##  equivalent  to assigning `<blist1>[<i>] := <blist1>[<i>] or
##  <blist2>[<i>]' for all <i>.  `UniteBlist' returns nothing, it is only
##  called to change <blist1>.
##
DeclareSynonym( "UniteBlist", UNITE_BLIST );


#############################################################################
##
#F  IntersectBlist( <blist1>, <blist2> )
##
##  intersects the  boolean list  <blist1> with the  boolean list <blist2>,
##  which must have the same  length.  This is  equivalent to assigning
##  `<blist1>[<i>]:= <blist1>[<i>] and <blist2>[<i>]' for all <i>.
##  `IntersectBlist' returns nothing, it is only called to change <blist1>.
##
DeclareSynonym( "IntersectBlist", INTER_BLIST );


#############################################################################
##
#F  SubtractBlist( <blist1>, <blist2> )
##
##  subtracts the boolean list <blist2> from the boolean list <blist1>,
##  which must have equal length.   This is equivalent to assigning
##  `<blist1>[<i>] := <blist1>[<i>]  and  not <blist2>[<i>]'  for all
##  <i>.  `SubtractBlist' returns nothing, it is only called to change
##  <blist1>.
##
DeclareSynonym( "SubtractBlist", SUBTR_BLIST );





#############################################################################
##
#E  list.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

