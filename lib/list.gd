#############################################################################
##
#W  list.gd                     GAP library                  Martin Schoenert
#W                                                            & Werner Nickel
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the definition of operations and functions for lists.
##
Revision.list_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsList( <obj> ) . . . . . . . . . . . . . . . test if an object is a list
##
##  tests whether <obj> is a list.
##
DeclareCategoryKernel( "IsList", IsListOrCollection, IS_LIST );


#############################################################################
##
#V  ListsFamily . . . . . . . . . . . . . . . . . . . . . . . family of lists
##
BIND_GLOBAL( "ListsFamily", NewFamily( "ListsFamily", IsList ) );


#############################################################################
##
#R  IsPlistRep  . . . . . . . . . . . . . . . . representation of plain lists
##
DeclareRepresentationKernel( "IsPlistRep",
    IsInternalRep, [], IS_OBJECT, IS_PLIST_REP );


#############################################################################
##
#C  IsConstantTimeAccessList( <list> )
##
##  This category indicates whether the access to each element of the list
##  <list> will take roughly the same time.
##  This is implied for example by `IsList and IsInternalRep',
##  so all strings, Boolean lists, ranges, and internally represented plain
##  lists are in this category.
##
##  But also other enumerators (see~"Enumerators") can lie in this category
##  if they guarantee constant time access to their elements.
##
DeclareCategory( "IsConstantTimeAccessList", IsList );

InstallTrueMethod( IsConstantTimeAccessList, IsList and IsInternalRep );


#############################################################################
##
#P  IsSmallList . . . . . . . . . . . . . . .  lists of length at most $2^28$
#V  MAX_SIZE_LIST_INTERNAL
##
##  We need this property to describe for which lists the default methods for
##  comparison, assignment, addition etc. are applicable.
##  Note that these methods call `LEN_LIST', and for that the list must be
##  small.
##  Of course every internally represented list is small,
##  and every empty list is small.
##
DeclareProperty( "IsSmallList", IsList );

InstallTrueMethod( IsSmallList, IsList and IsInternalRep );
InstallTrueMethod( IsFinite, IsList and IsSmallList );
InstallTrueMethod( IsSmallList, IsList and IsEmpty );

BIND_GLOBAL( "MAX_SIZE_LIST_INTERNAL", 2^(8*GAPInfo.BytesPerVariable-4) - 1 );


#############################################################################
##
#A  Length( <list> )  . . . . . . . . . . . . . . . . . . .  length of a list
##
##  returns the *length* of the list <list>, which is defined to be the index
##  of the last bound entry in <list>.
##
DeclareAttributeKernel( "Length", IsList, LENGTH );


#############################################################################
##
#o  IsBound( <list>[<pos>] )  . . . . . . . . test for an element from a list
##
DeclareOperationKernel( "IsBound[]",
    [ IsList, IS_INT ],
    ISB_LIST );


#############################################################################
##
#o  <list>[<pos>] . . . . . . . . . . . . . . . select an element from a list
##
DeclareOperationKernel( "[]",
    [ IsList, IS_INT ],
    ELM_LIST );


#############################################################################
##
#o  <list>{<poss>}  . . . . . . . . . . . . . . . select elements from a list
##
DeclareOperationKernel( "{}",
    [ IsList, IsList ],
    ELMS_LIST );


#############################################################################
##
#o  Elm0List( <list>, <pos> )
##
DeclareOperationKernel( "Elm0List",
    [ IsList, IS_INT ],
    ELM0_LIST );


#############################################################################
##
#O  Unbind( <list>[<pos>] )
##

#DeclareOperation("Unbind")
DeclareOperationKernel( "Unbind[]",
    [ IsList and IsMutable, IS_INT ],
    UNB_LIST );


#############################################################################
##
#o  <list>[<pos>] := <obj>
##
DeclareOperationKernel( "[]:=",
    [ IsList and IsMutable, IS_INT, IsObject ],
    ASS_LIST );


#############################################################################
##
#o  <list>{<poss>} := <objs>
##
DeclareOperationKernel( "{}:=",
    [ IsList and IsMutable, IsList, IsList ],
    ASSS_LIST );


#############################################################################
##
#A  ConstantTimeAccessList( <list> )
##
##  `ConstantTimeAccessList' returns an immutable list containing the same
##  elements as the list <list> (which may have holes) in the same order.
##  If <list> is already a constant time access list,
##  `ConstantTimeAccessList' returns an immutable copy of <list> directly.
##  Otherwise it puts all elements and holes of <list> into a new list and
##  makes that list immutable.
##
DeclareAttribute( "ConstantTimeAccessList", IsList );


#############################################################################
##
#F  AsSSortedListList( <list> )
##
##  `AsSSortedListList' returns an immutable list containing the same elements
##  as the *internally represented* list <list> (which may have holes)
##  in strictly sorted order.
##  If <list> is already  immutable and  strictly sorted,
##  `AsSSortedListList' returns <list> directly.
##  Otherwise it makes a deep copy, and makes that copy immutable.
##  `AsSSortedListList' is an internal function.
##

#DeclareOperationKernel( "AsSSortedListList",
#    [ IsList ],
#    AS_LIST_SORTED_LIST );
#T  1996/10/28 fceller at the moment this is defined as function in kernel.g
DeclareSynonym( "AsSSortedListList", AS_LIST_SORTED_LIST );

#############################################################################
##
#A  AsPlist( <l> )
##
##  `AsList' returns a list in the repreentation `IsPlistRep' that is equal
##  to the list <l>. It is used before calling kernel functions to sort
##  plists.
DeclareOperation( "AsPlist", [IsListOrCollection] );


#############################################################################
##
#C  IsDenseList( <obj> )
##
##  A list is *dense* if it has no holes, i.e., contains an element at every
##  position up to the length.
##  It is absolutely legal to have lists with holes.
##  They are created by leaving the entry between the commas empty.
##  Holes at the end of a list are ignored.
##  Lists with holes are sometimes convenient when the list represents
##  a mapping from a finite, but not consecutive,
##  subset of the positive integers.

# DeclareCategory("IsDenseList",IsList);
DeclareCategoryKernel( "IsDenseList", IsList, IS_DENSE_LIST );

InstallTrueMethod( IsDenseList, IsList and IsEmpty );


#############################################################################
##
#C  IsHomogeneousList( <obj> )
##
##  returns `true' if <obj> is a list  and  it  is  homogeneous,  or  `false'
##  otherwise.
##
##  A *homogeneous* list is a dense list whose elements lie in the same
##  family (see~"Families").
##  The empty list is homogeneous but not a collection (see~"Collections"),
##  a nonempty homogeneous list is also a collection.
#T can we guarantee this?
##

#DeclareCategory("IsHomogeneousList",IsList);
DeclareCategoryKernel( "IsHomogeneousList", IsDenseList, IS_HOMOG_LIST );


#############################################################################
##
#M  IsHomogeneousList( <coll_and_list> )  . . for a collection that is a list
#M  IsHomogeneousList( <empty> )  . . . . . . . . . . . . . for an empty list
##
InstallTrueMethod( IsHomogeneousList, IsList and IsCollection );

InstallTrueMethod( IsHomogeneousList, IsList and IsEmpty );


#############################################################################
##
#M  IsFinite( <homoglist> )
##
InstallTrueMethod( IsFinite, IsHomogeneousList and IsInternalRep );


#############################################################################
##
#P  IsSortedList( <obj> )
##
##  returns `true' if <obj> is a list and it is sorted, or `false' otherwise.
##
##  \index{sorted list}
##  A list <list> is *sorted* if it is dense (see~"IsDenseList")
##  and satisfies the relation $<list>[i] \leq <list>[j]$ whenever $i \< j$.
##  Note that a sorted list is not necessarily duplicate free
##  (see~"IsDuplicateFree" and "IsSSortedList").
##
##  Many sorted lists are in fact homogeneous (see~"IsHomogeneousList"),
##  but also non-homogeneous lists may be sorted
##  (see~"Comparison Operations for Elements").
##
DeclareProperty( "IsSortedList", IsList);


#############################################################################
##
#P  IsSSortedList( <obj> )
#P  IsSet( <obj> )
##
##  returns `true' if <obj> is a list and it is strictly sorted,  or  `false'
##  otherwise. `IsSSortedList' is short  for  ``is  strictly  sorted  list'';
##  `IsSet' is just a synonym for `IsSSortedList'.
##
##  \index{strictly sorted list}
##  A list <list> is *strictly sorted* if it is sorted (see~"IsSortedList")
##  and satisfies the relation $<list>[i] \lneqq <list>[j]$ whenever $i\< j$.
##  In particular, such lists are duplicate free (see~"IsDuplicateFree").
##
##  In sorted lists, membership test and computing of positions can be done
##  by binary search, see~"Sorted Lists and Sets".
#T This should belong to `IsSortedList' not to `IsSSortedList'
#T (but see the comment below)!
##
##  (Currently there is little special treatment of lists that are sorted
##  but not strictly sorted.
##  In particular, internally represented lists will *not* store that they
##  are sorted but not strictly sorted.)
##

#DeclareProperty( "IsSSortedList", IsList);
DeclarePropertyKernel( "IsSSortedList", IsList, IS_SSORT_LIST );
DeclareSynonym( "IsSet", IsSSortedList );

InstallTrueMethod( IsSortedList, IsSSortedList );
InstallTrueMethod( IsSSortedList, IsList and IsEmpty );


#T #############################################################################
#T ##
#T #p  IsNSortedList( <list> )
#T ##
#T ##  returns `true' if the list <list> is not sorted (see~"IsSortedList").
#T ##
#T DeclarePropertyKernel( "IsNSortedList", IsDenseList, IS_NSORT_LIST );
#T (is currently not really supported)


#############################################################################
##
#P  IsDuplicateFree( <obj> )
#P  IsDuplicateFreeList( <obj> )
##
##  `IsDuplicateFree(<obj>);' returns `true' if  <obj>  is  both  a  list  or
##  collection, and it is duplicate free; otherwise it returns `false'.
##  `IsDuplicateFreeList' is a synonym for `IsDuplicateFree and IsList'.
##
##  \index{duplicate free}
##  A list is *duplicate free* if it is dense and does not contain equal
##  entries in different positions.
##  Every domain (see~"Domains") is duplicate free.
##
DeclareProperty( "IsDuplicateFree", IsListOrCollection );

DeclareSynonymAttr( "IsDuplicateFreeList", IsDuplicateFree and IsList );

InstallTrueMethod( IsDuplicateFree, IsList and IsSSortedList );


#############################################################################
##
#P  IsPositionsList(<obj>)
##
#T  1996/09/01 M.Schoenert should inherit from `IsHomogeneousList'
#T  but the empty list is a positions list but not homogeneous
##
DeclarePropertyKernel( "IsPositionsList", IsDenseList, IS_POSS_LIST );


#############################################################################
##
#C  IsTable( <obj> )
##
##  A *table* is a nonempty list of homogeneous lists which lie in the same
##  family.
##  Typical examples of tables are matrices (see~"Matrices").
##

#DeclareCategory("IsTable",IsHomogeneousList);
DeclareCategoryKernel( "IsTable", IsHomogeneousList and IsCollection,
    IS_TABLE_LIST );


#############################################################################
##
#O  Position( <list>, <obj>[, <from>] ) . . . position of an object in a list
##
##  returns the position of the first occurrence <obj> in <list>,
##  or <fail> if <obj> is not contained in <list>.
##  If a starting index <from> is given, it
##  returns the position of the first occurrence starting the search *after*
##  position <from>.
##
##  Each call to the two argument version is translated into a call of the
##  three argument version, with third argument the integer zero `0'.
##  (Methods for the two argument version must be installed as methods for
##  the version with three arguments, the third being described by
##  `IsZeroCyc'.)
##
DeclareOperationKernel( "Position", [ IsList, IsObject ], POS_LIST );
DeclareOperation( "Position", [ IsList, IsObject, IS_INT ] );


#############################################################################
##
#F  Positions( <list>, <obj> ) . . . . . . . positions of an object in a list
#O  PositionsOp( <list>, <obj> ) . . . . . . . . . . . . underlying operation
##
##  returns the positions of *all* occurrences of <obj> in <list>.
##
DeclareGlobalFunction( "Positions" );
DeclareOperation( "PositionsOp", [ IsList, IsObject ] );


#############################################################################
##
#O  PositionCanonical( <list>, <obj> )  . . . position of canonical associate
##
##  returns the position of the canonical associate of <obj> in <list>.
##  The definition of this associate depends on <list>.
##  For internally represented lists it is defined as the element itself
##  (and `PositionCanonical' thus defaults to `Position', see~"Position"),
##  but for example for certain enumerators (see~"Enumerators") other
##  canonical associates can be defined.
##
##  For example `RightTransversal' defines the canonical associate to be the
##  element in the transversal defining the same coset of a subgroup in a
##  group.
##
DeclareOperation( "PositionCanonical", [ IsList, IsObject ]);


#############################################################################
##
#O  PositionNthOccurrence(<list>,<obj>,<n>) pos. of <n>th occurrence of <obj>
##
##  returns the position of the <n>-th occurrence of <obj> in <list> and
##  returns `fail' if <obj> does not occur <n> times.
##
DeclareOperation( "PositionNthOccurrence", [ IsList, IsObject, IS_INT ] );


#############################################################################
##
#F  PositionSorted( <list>, <elm> ) . .  position of an object in sorted list
#F  PositionSorted( <list>, <elm>, <func> )
##
##  In the first form `PositionSorted' returns the position of the element
##  <elm> in the sorted list <list>.
##
##  In the second form `PositionSorted' returns the position of the element
##  <elm> in the list <list>, which must be sorted with respect to <func>.
##  <func> must be a function of two arguments that returns `true' if the
##  first argument is less than the second argument and `false' otherwise.
##
##  `PositionSorted' returns <pos> such that $<list>[<pos>-1] \< <elm>$ and
##  $<elm> \le <list>[<pos>]$.
##  That means, if <elm> appears once in <list>, its position is returned.
##  If <elm> appears several times in <list>, the position of the first
##  occurrence is returned.
##  If <elm> is not an element of <list>, the index where <elm> must be
##  inserted to keep the list sorted is returned.
##
##  `PositionSorted' uses binary search, whereas `Position' can in general
##  use only linear search, see the remark at the beginning
##  of~"Sorted Lists and Sets".
##  For sorting lists, see~"Sorting Lists",
##  for testing whether a list is sorted, see~"IsSortedList" and
##  "IsSSortedList".
##
##  Specialized functions for certain kinds of lists must be installed 
##  as methods for the operation `PositionSortedOp'.
##  
# we catch plain lists by a function to avoid method selection
DeclareGlobalFunction( "PositionSorted" );
DeclareOperation( "PositionSortedOp", [ IsList, IsObject ] );
DeclareOperation( "PositionSortedOp", [ IsList, IsObject, IsFunction ] );
#T originally was
#T DeclareOperation( "PositionSorted", [ IsHomogeneousList, IsObject ] );
#T note the problem with inhomogeneous lists that may be sorted
#T (although they cannot store this and claim that they are not sorted)


#############################################################################
##
#F  PositionSet( <list>, <obj> )
#F  PositionSet( <list>, <obj>, <func> )
##
##  `PositionSet' is a slight variation of `PositionSorted'.
##  The only difference to `PositionSorted' is that `PositionSet' returns
##  `fail' if <obj> is not in <list>.
##
DeclareGlobalFunction( "PositionSet" );


#############################################################################
##
#O  PositionProperty(<list>,<func>) .  position of an element with a property
##
##  returns the first position of an element in the list <list> for which the
##  property tester function <func> returns `true'.
##
DeclareOperation( "PositionProperty", [ IsDenseList, IsFunction ] );


#############################################################################
##
#O  PositionBound( <list> ) . . . . position of first bound element in a list
##
##  returns the first index for which an element is bound in the list <list>.
##  For the empty list it returns `fail'.
##
DeclareOperation( "PositionBound", [ IsList ] );


#############################################################################
##
#O  PositionSublist( <list>, <sub> )
#O  PositionSublist( <list>, <sub>, <from> )
##
##  returns the smallest index in the list <list> at which a sublist equal to
##  <sub> starts.
##  If <sub> does not occur the operation returns `fail'.
##  The second version starts searching *after* position <from>.
##
##  To determine whether <sub> matches <list> at a  particular position, use 
##  `IsMatchingSublist' instead (see "IsMatchingSublist").
##
DeclareOperation( "PositionSublist", [ IsList,IsList,IS_INT ] );

#############################################################################
##
#O  PositionFirstComponent(<list>,<obj>)
##
##  returns the index <i> in <list> such that $<list>[<i>][1]=<obj>$ or the 
##  place where such an entry should be added (cf PositionSorted).
## 
DeclareOperation("PositionFirstComponent",[IsList,IsObject]);


#############################################################################
##
#O  IsMatchingSublist( <list>, <sub> )
#O  IsMatchingSublist( <list>, <sub>, <at> )
##
##  returns `true' if <sub> matches a sublist of <list> from position 1 (or
##  position <at>, in the case of the second version), or `false', otherwise. 
##  If <sub> is empty `true' is returned. If <list> is empty but <sub> is
##  non-empty `false' is returned.
##
##  If you actually want to know whether there is an <at> for which
##  `IsMatchingSublist( <list>, <sub>, <at> )' is true, use a construction
##  like `PositionSublist( <list>, <sub> ) <> fail' instead 
##  (see "PositionSublist"); it's more efficient.
##
DeclareOperation( "IsMatchingSublist", [ IsList,IsList,IS_INT ] );

#############################################################################
##
#F  IsQuickPositionList( <list> )
##
##  This filter indicates that a position test in <list> is quicker than
##  about 5 or 6 element comparisons for ``smaller''. If this is the case it
##  can be beneficial to use `Position' in <list> and a bit list than
##  ordered lists to represent subsets  of <list>.
##
DeclareFilter( "IsQuickPositionList" );

#############################################################################
##
#O  Add( <list>, <obj> )  . . . . . . . . add an element to the end of a list
#O  Add( <list>, <obj>, <pos> ) . . . . . . add an element anywhere in a list
##
##  adds the element <obj> to the mutable list <list>. The two argument version 
##  adds <obj> at the end of <list>,
##  i.e., it is equivalent to the assignment
##  `<list>[ Length(<list>) + 1 ] := <obj>', see~"list element!assignment".
##  
##  The three argument version adds <obj> in position <pos>, moving all later
##  elements of the list (if any) up by one position. Any holes at or after
##  position <pos> are also moved up by one position, and new holes are created
##  before <pos> if they are needed.
## 
##  Nothing is returned by `Add', the function is only called for its side
##  effect.

#DeclareOperation( "Add", [ IsList, IsObject ] );
DeclareOperationKernel( "Add", [ IsList and IsMutable, IsObject ], ADD_LIST );
DeclareOperation( "Add", [ IsList and IsMutable, IsObject,  IS_INT ]);

#############################################################################
##
#O  Remove( <list> ) . . . . . . . . remove an element from the end of a list
#O  Remove( <list>, <pos> ) . remove an element from position <pos> of a list
##
##  removes an element from <list>. The one argument form removes the last 
##  element. The two argument form removes the element in position <pos>,
##  moving all subsequent elements down one position. Any holes  after
##  position <pos> are also moved down by one position.
##
##  Remove( <list> ) always returns the removed element. In this case <list>
##  must be non-empty. Remove( <list>, <pos> )
##  returns the old value of <list>[<pos>] if it was bound, and nothing if it
##  was not. Note that accessing or assigning the return value of this form of
##  the Remove operation is only safe when you *know* that there will be a 
##  value, otherwise it will cause an error.
##

DeclareOperation( "Remove", [IsList and IsMutable]);
DeclareOperation( "Remove", [IsList and IsMutable, IS_INT]);

#############################################################################
##
#O  Append( <list1>, <list2> )  . . . . . . . . . . . append a list to a list
##
##  adds the elements of the list <list2> to the end of the mutable list
##  <list1>, see~"sublist!assignment".
##  <list2> may contain holes, in which case the corresponding entries in
##  <list1> will be left unbound.
##  `Append' returns nothing, it is only called for its side effect.
##
##  Note that `Append' changes its first argument, while `Concatenation'
##  (see~"Concatenation") creates a new list and leaves its arguments
##  unchanged.

# DeclareOperation( "Append", [ IsList and IsMutable, IsList ])
DeclareOperationKernel( "Append", [ IsList and IsMutable, IsList ],
    APPEND_LIST );


#############################################################################
##
#F  Apply( <list>, <func> ) . . . . . . . .  apply a function to list entries
##
##  `Apply' applies the function <func> to every element of the dense and
##  mutable list <list>,
##  and replaces each element entry by the corresponding return value.
##
##  `Apply' changes its argument.
##  The nondestructive counterpart of `Apply' is `List' (see~"List").
##
DeclareGlobalFunction( "Apply" );


#############################################################################
##
#F  Concatenation( <list1>, <list2>, ... )  . . . . .  concatenation of lists
#F  Concatenation( <list> ) . . . . . . . . . . . . .  concatenation of lists
##
##  In the first form `Concatenation' returns the concatenation of the lists
##  <list1>, <list2>, etc.
##  The *concatenation* is the list that begins with the elements of <list1>,
##  followed by the elements of <list2>, and so on.
##  Each list may also contain holes, in which case the concatenation also
##  contains holes at the corresponding positions.
##
##  In the second form <list> must be a dense list of lists <list1>, <list2>,
##  etc., and `Concatenation' returns the concatenation of those lists.
##
##  The result is a new mutable list, that is not identical to any other
##  list.
##  The elements of that list however are identical to the corresponding
##  elements of <list1>, <list2>, etc. (see~"Identical Lists").
##
##  Note that `Concatenation' creates a new list and leaves its arguments
##  unchanged, while `Append' (see~"Append") changes its first argument.
##  For computing the union of proper sets, `Union' can be used,
##  see~"Union" and "Sorted Lists and Sets".
##
DeclareGlobalFunction( "Concatenation" );


#############################################################################
##
#O  Compacted( <list> ) . . . . . . . . . . . . . .  remove holes from a list
##
##  returns a new mutable list that contains the elements of <list>
##  in the same order but omitting the holes.
##
DeclareOperation( "Compacted", [ IsList ] );


#############################################################################
##
#O  Collected( <list> ) . . . . . . . . . . collect like elements from a list
##
##  returns a new list <new> that contains for each element <elm> of the list
##  <list> a list of length two, the first element of this is <elm>
##  itself and the second element is the number of times <elm> appears in
##  <list>.
##  The order of those pairs in <new> corresponds to the ordering of
##  the elements elm, so that the result is sorted.
##
##  For all pairs of elements in <list> the comparison via `\<' must be
##  defined.
##
DeclareOperation( "Collected", [ IsList ] );


#############################################################################
##
#O  DuplicateFreeList( <list> ) . . . .  duplicate free list of list elements
#O  Unique( <list> )
##
##  returns a new mutable list whose entries are the elements of the list
##  <list> with duplicates removed.
##  `DuplicateFreeList' only uses the `=' comparison and will not sort the
##  result.
##  Therefore `DuplicateFreeList' can be used even if the elements of <list>
##  do not lie in the same family.
##  `Unique' is an alias for `DuplicateFreeList'.
##
DeclareOperation( "DuplicateFreeList", [ IsList ] );

DeclareSynonym( "Unique", DuplicateFreeList );


#############################################################################
##
#A  AsDuplicateFreeList( <list> ) . . .  duplicate free list of list elements
##
##  returns the same result as `DuplicateFreeList' (see~"DuplicateFreeList"),
##  except that the result is immutable.
##
DeclareAttribute( "AsDuplicateFreeList", IsList );


#############################################################################
##
#O  DifferenceLists(<list1>,<list2>)  . list without elements in another list
##
##  This operation accepts two lists <list1> and <list2> and returns a list
##  containing the elements in <list1> that do not lie in <list2>.  The
##  elements of the resulting list are in the same order as they are in
##  <list1>.  The result of this operation is the same as that of the
##  operation `Difference' (see~"Difference") except that the first argument
##  is not treated as a proper set,
##  and therefore the result need not be sorted.
##
##  What about duplicates?
##  This definition is not satisfactory!!!
##
DeclareOperation( "DifferenceLists", [IsList, IsList] );


#############################################################################
##
#O  Flat( <list> )  . . . . . . . list of elements of a nested list structure
##
##  returns the list of all elements that are contained in the list <list>
##  or its sublists.
##  That is, `Flat' first makes a new empty list <new>.
##  Then it loops over the elements <elm> of <list>.
##  If <elm> is not a list it is added to <new>,
##  otherwise `Flat' appends `Flat( <elm> )' to <new>.
##
DeclareOperation( "Flat", [ IsList ] );


#############################################################################
##
#F  Reversed( <list> )  . . . . . . . . . . .  reverse the elements in a list
##
##  returns a new mutable list, containing the elements of the dense list
##  <list> in reversed order.
##
##  The argument list is unchanged.
##  The result list is a new list, that is not identical to any other list.
##  The elements of that list however are identical to the corresponding
##  elements of the argument list (see~"Identical Lists").
##
##  `Reversed' implements a special case of list assignment, which can also
##  be formulated in terms of the `{}' operator (see~"List Assignment").
##
DeclareGlobalFunction( "Reversed", [ IsDenseList ] );


#############################################################################
##
#O  ReversedOp( <list> )  . . . . . . . . . .  reverse the elements in a list
##
##  `ReversedOp' is the operation called by `Reversed' if <list> is not
##  an internal list.
##  (Note that it would not make sense to turn this into an attribute
##  because the result shall be mutable.)
##
DeclareOperation( "ReversedOp", [ IsDenseList ] );


#############################################################################
##
#F  IsLexicographicallyLess( <list1>, <list2> )
##
##  Let <list1> and <list2> be two dense lists, but not necessarily
##  homogeneous (see~"IsDenseList", "IsHomogeneousList"),
##  such that for each $i$, the entries in both lists at position $i$ can be
##  compared via `\<'.
##  `IsLexicographicallyLess' returns `true' if <list1> is smaller than
##  <list2> w.r.t.~lexicographical ordering, and `false' otherwise.
##
DeclareGlobalFunction( "IsLexicographicallyLess" );


#############################################################################
##
#O  Sort( <list> )  . . . . . . . . . . . . . . . . . . . . . . . sort a list
#O  Sort( <list>, <func> )  . . . . . . . . . . . . . . . . . . . sort a list
##
##  sorts the list <list> in increasing order.
##  In the first form `Sort' uses the operator `\<' to compare the elements.
##  (If the list is not homogeneous it is the users responsibility to ensure
##  that `\<' is defined for all element pairs, see~"Comparison Operations
##  for Elements")
##  In the second form `Sort' uses the function <func> to compare elements.
##  <func> must be a function taking two arguments that returns `true'
##  if the first is regarded as strictly smaller than the second,
##  and `false' otherwise.
##
##  `Sort' does not return anything, it just changes the argument <list>.
##  Use  `ShallowCopy' (see "ShallowCopy") if you  want to keep  <list>.  Use
##  `Reversed'  (see  "Reversed") if you  want to  get a  new  list sorted in
##  decreasing order.
##
##  It is possible to sort lists that contain multiple elements which compare
##  equal.    It is not  guaranteed  that those  elements keep their relative
##  order, i.e., `Sort' is not stable.
##
DeclareOperation( "Sort", [ IsList and IsMutable ] );
DeclareOperation( "Sort", [ IsList and IsMutable, IsFunction ] );


#############################################################################
##
#O  Sortex( <list> ) . . sort a list (stable), return the applied permutation
##
##  sorts the list <list> via the operator`\<' and returns a permutation
##  that can be applied to <list> to obtain the sorted list.
##  (If the list is not homogeneous it is the user's responsibility to ensure
##  that `\<' is defined for all element pairs,
##  see~"Comparison Operations for Elements")
##
##  `Permuted' (see~"Permuted") allows you to rearrange a list according to
##  a given permutation.
##
DeclareOperation( "Sortex", [ IsList and IsMutable ] );


#############################################################################
##
#A  SortingPerm( <list> )
##
##  `SortingPerm' returns the same as `Sortex( <list> )' (see~"Sortex")
##  but does *not* change the argument.
##
DeclareAttribute( "SortingPerm", IsList );


#############################################################################
##
#F  PermListList( <list1>, <list2> ) . what permutation of <list1> is <list2>
##
##  returns a permutation $p$ of `[ 1 .. Length( <list1> ) ]'
##  such that `<list1>[i^$p$] = <list2>[i]'.
##  It returns `fail' if there is no such permutation.
##
DeclareGlobalFunction( "PermListList" );


#############################################################################
##
#O  SortParallel(<list>,<list2>)  . . . . . . . .  sort two lists in parallel
#O  SortParallel( <list>, <list2>, <func> ) . . .  sort two lists in parallel
##
##  sorts the list <list1> in increasing order just as `Sort' (see~"Sort")
##  does.  In  parallel it applies  the same exchanges  that are
##  necessary to sort <list1> to the list <list2>, which must of  course have
##  at least as many elements as <list1> does.
##
DeclareOperation( "SortParallel",
    [ IsDenseList and IsMutable, IsDenseList and IsMutable ] );
DeclareOperation( "SortParallel",
    [ IsDenseList and IsMutable, IsDenseList and IsMutable, IsFunction ] );


#############################################################################
##
#F  Maximum( <obj1>, <obj2> ... ) . . . . . . . . . . . .  maximum of objects
#F  Maximum( <list> )
##
##  In the first form `Maximum' returns the *maximum* of its arguments,
##  i.e., one argument <obj> for which $<obj> \ge <obj1>$, $<obj> \ge <obj2>$
##  etc.
##  In the second form `Maximum' takes a homogeneous list <list> and returns
##  the maximum of the elements in this list.
##
DeclareGlobalFunction( "Maximum" );


#############################################################################
##
#F  Minimum( <obj1>, <obj2> ... ) . . . . . . . . . . . .  minimum of objects
#F  Minimum( <list> )
##
##  In the first form `Minimum' returns the *minimum* of its arguments,
##  i.e., one argument <obj> for which $<obj> \le <obj1>$, $<obj> \le <obj2>$
##  etc.
##  In the second form `Minimum' takes a homogeneous list <list> and returns
##  the minimum of the elements in this list.
##
##  Note that for both `Maximum' and `Minimum' the comparison of the objects
##  <obj1>, <obj2> etc.~must be defined;
##  for that, usually they must lie in the same family (see~"Families").
##
DeclareGlobalFunction( "Minimum" );


#############################################################################
##
#O  MaximumList( <list> )  . . . . . . . . . . . . . . . .  maximum of a list
#O  MinimumList( <list> )  . . . . . . . . . . . . . . . .  minimum of a list
##
##  return the maximum resp.~the minimum of the elements in the list <list>.
##  They are the operations called by `Maximum' resp.~`Minimum'.
##  Methods can be installed for special kinds of lists.
##  For example, there are special methods to compute the maximum resp.~the
##  minimum of a range (see~"Ranges").
##
DeclareOperation( "MaximumList", [ IsList ] );

DeclareOperation( "MinimumList", [ IsList ] );


#############################################################################
##
#F  Cartesian( <list1>, <list2> ... ) . . . . . .  cartesian product of lists
#F  Cartesian( <list> )
##
##  In the first form `Cartesian' returns the cartesian product of the lists
##  <list1>, <list2>, etc.
##
##  In the second form <list> must be a list of lists <list1>, <list2>, etc.,
##  and `Cartesian' returns the cartesian product of those lists.
##
##  The *cartesian product* is a list <cart> of lists <tup>,
##  such that the first element of <tup> is an element of <list1>,
##  the second element of <tup> is an element of <list2>, and so on.
##  The total number of elements in <cart> is the product of the lengths
##  of the argument lists.
##  In particular <cart> is empty if and only if at least one of the argument
##  lists is empty.
##  Also <cart> contains duplicates if and only if no argument list is empty
##  and at least one contains duplicates.
##
##  The last index runs fastest.
##  That means that the first element <tup1> of <cart> contains the first
##  element from <list1>,  from <list2> and so on.
##  The second element <tup2> of <cart> contains the first element from
##  <list1>, the first from <list2>, an so on, but the last element of <tup2>
##  is the second element of the last argument list.
##  This implies that <cart> is a proper set if and only if all argument
##  lists are proper sets (see~"Sorted Lists and Sets").
##
##  The function `Tuples' (see~"Tuples") computes the  <k>-fold cartesian
##  product of a list.
##
DeclareGlobalFunction( "Cartesian" );


#############################################################################
##
#O  Permuted(<list>,<perm>)  . . . . . . . . .  apply a permutation to a list
##
##  returns a new list <new> that contains the elements of the
##  list <list> permuted according to the permutation <perm>.
##  That is `<new>[<i> ^ <perm>] = <list>[<i>]'.
##
##  `Sortex' (see~"Sortex") allows you to compute a permutation that must
##  be applied to a list in order to get the sorted list.
##
DeclareOperation( "Permuted", [ IsList, IS_PERM ] );


#############################################################################
##
#F  IteratorList( <list> )
##
##  `IteratorList' returns a new iterator that allows iteration over the
##  elements of the list <list> (which may have holes) in the same order.
##
##  If <list> is mutable then it is in principle possible to change <list>
##  after the call of `IteratorList'.
##  In this case all changes concerning positions that have not yet been
##  reached in the iteration will also affect the iterator.
##  For example, if <list> is enlarged then the iterator will iterate also
##  over the new elements at the end of the changed list.
##
##  *Note* that changes of <list> will also affect all shallow copies of
##  <list>.
##
DeclareGlobalFunction( "IteratorList" );


#############################################################################
##
#F  First( <list>, <func> ) . .  find first element in a list with a property
##
##  `First' returns the first element of the list <list> for which the unary
##  function <func> returns `true'.
##  <list> may contain holes.
##  <func> must return either `true' or `false' for each element of <list>,
##  otherwise an error is signalled.
##  If <func> returns `false' for all elements of <list> then `First'
##  returns `fail'.
##
##  `PositionProperty' (see~"PositionProperty") allows you to find the
##  position of the first element in a list that satisfies a certain
##  property.
##
DeclareGlobalFunction( "First" );


#############################################################################
##
#O  FirstOp( <list>, <func> )
##
##  `FirstOp' is the operation called by `First' if <list> is not
##  an internally represented list.
##
DeclareOperation( "FirstOp", [ IsListOrCollection, IsFunction ] );


#############################################################################
##
#O  Iterated( <list>, <func> )  . . . . . . .  iterate a function over a list
##
##  returns the result of the iterated application of the function <func>,
##  which must take two arguments, to the elements of the list <list>.
##  More precisely `Iterated' returns the result of the following
##  application,
##  $<f>(\cdots <f>( <f>( <list>[1], <list>[2] ), <list>[3] ), \ldots,
##  <list>[<n>] )$.
##
DeclareOperation( "Iterated", [ IsList, IsFunction ] );

#############################################################################
##
#F  ListN( <list1>, <list2>, ..., <listn>, <f> )
##
##  Applies the <n>-argument function <func> to the lists.
##  That is, `ListN' returns the list whose <i>th entry is
##  $<f>(<list1>[<i>], <list2>[<i>], \ldots, <listn>[<i>])$.
##
DeclareGlobalFunction( "ListN" );


#############################################################################
##
#F  UnionBlist(<blist1>,<blist2>[,...])
#F  UnionBlist(<list>)
##
##  In the  first form `UnionBlist'  returns the union  of the  boolean
##  lists <blist1>, <blist2>, etc., which must have equal length.  The
##  *union* is a new boolean list such that `<union>[<i>] = <blist1>[<i>] or
##  <blist2>[<i>] or ...'.
##
##  The second form takes the union of all blists (which
##  as for the first form must have equal length) in the list <list>.
DeclareGlobalFunction( "UnionBlist" );


#############################################################################
##
#F  DifferenceBlist(<blist1>,<blist2>)
##
##  returns the  asymmetric  set  difference (exclusive or) of the   two
##  boolean  lists <blist1> and <blist2>, which  must have equal length.
##  The *asymmetric set difference* is a new boolean list such that
##  `<union>[<i>] = <blist1>[<i>] and not <blist2>[<i>]'.
DeclareGlobalFunction("DifferenceBlist");


#############################################################################
##
#F  IntersectionBlist(<blist1>,<blist2>[,...])
#F  IntersectionBlist(<list>)
##
##  In the first  form `IntersectionBlist'  returns  the intersection  of
##  the boolean  lists <blist1>, <blist2>,  etc., which  must  have equal
##  length.  The  *intersection*  is a  new blist such  that
##  `<inter>[<i>] = <blist1>[<i>] and <blist2>[<i>] and ...'.
##
##  In  the  second form <list>   must be a  list of  boolean lists
##  <blist1>, <blist2>, etc., which   must have equal  length,  and
##  `IntersectionBlist' returns the intersection of those boolean lists.
DeclareGlobalFunction( "IntersectionBlist" );


#############################################################################
##
#F  ListWithIdenticalEntries( <n>, <obj> )
##
##  is a list <list> of length <n> that has the object <obj> stored at each
##  of the positions from 1 to <n>.
##  Note that all elements of <lists> are identical, see~"Identical Lists".
##
DeclareGlobalFunction( "ListWithIdenticalEntries" );


#############################################################################
##
#F  PlainListCopy( <list> ) . . . . . . . .  make a plain list copy of a list
##
##  This is intended for use in certain rare situations, such as before
##  Objectifying. Normally, `ConstantAccessTimeList' should be enough.
##
DeclareGlobalFunction("PlainListCopy");


#############################################################################
##
#O  PlainListCopyOp( <list> ) . . . . . . . .return a plain version of a list
##
##  This Operation returns a list equal to its argument, in a plain list
##  representation. This may be the argument converted in place, or
##  may be new. It is only intended to be called by `PlainListCopy'.
##
DeclareOperation("PlainListCopyOp", [IsSmallList]);


#############################################################################
##
#O  PositionNot( <list>, <val>[, <from-minus-one>] )  . . . .  find not <val>
##
##  For a list <list> and an object <val>, `PositionNot' returns the smallest
##  nonnegative integer $n$ such that $<list>[n]$ is either unbound or
##  not equal to <val>.
##  If a nonnegative integer is given as optional argument <from-minus-one>
##  then the first position larger than <from-minus-one> with this property
##  is returned.
##
DeclareOperation( "PositionNot", [ IsList, IsObject ] );
DeclareOperation( "PositionNot", [ IsList, IsObject, IS_INT ] );


#############################################################################
##
#O  PositionNonZero( <vec> ) . . . . . . . . Position of first non-zero entry
##
##  For a row vector <vec>, `PositionNonZero' returns the position of the
##  first non-zero element of <vec>, or `Length(<vec>)+1' if all entries of
##  <vec> are zero.
##
##  `PositionNonZero' implements a special case of `PositionNot'
##  (see~"PositionNot").
##  Namely, the element to be avoided is the zero element,
##  and the list must be (at least) homogeneous
##  because otherwise the zero element cannot be specified implicitly.
##
DeclareOperation( "PositionNonZero", [ IsHomogeneousList ] );
#T In principle, this could become an attribute ...


#############################################################################
##
#P  IsDuplicateFreeCollection
##
##  Needs to be after DeclareSynonym is declared

DeclareSynonym("IsDuplicateFreeCollection", IsCollection and IsDuplicateFree);

#############################################################################
##
#F  HexStringBlist(<b>)
##
##  takes a binary list and returns a hex string representing this blist.
DeclareGlobalFunction("HexStringBlist");


#############################################################################
##
#F  HexStringBlistEncode(<b>)
##
##  works like `HexStringBlist', but uses `s<xx>' (<xx> is a hex number up to
##  255) to indicate skips of zeroes.
DeclareGlobalFunction("HexStringBlistEncode");


#############################################################################
##
#F  BlistStringDecode(<s>,[<l>])
##
##  takes a string as produced by `HexStringBlist' and
##  `HexStringBlistEncode' and returns a binary list. If a length <l> is
##  given the list is filed with `false' or trimmed to obtain this length,
##  otherwise the list has the length as given by the string (this might
##  leave out or add some trailing `false' values.
DeclareGlobalFunction("BlistStringDecode");

#############################################################################
##
#E

