#############################################################################
##
#W  list.gd                     GAP library                  Martin Schoenert
#W                                                            & Werner Nickel
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the definition of operations and functions for lists.
##
Revision.list_gd :=
    "@(#)$Id$";

#1
##  While lists can be used to implement collections
##  these two terms should not be confused:
##  Not every collection is a list (the collection does not necessarily
##  permit indexing of its elements and may be infinite) and lists whose
##  elements are in different families do not form a collection.
##  Nevertheless collections and lists behave very similar and there is a
##  category `IsListOrCollection' for which some of the operations for
##  collections are defined so that they are also applicable to lists.


#############################################################################
##
#C  IsList( <obj> ) . . . . . . . . . . . . . . . test if an object is a list
##
##  is the category for proper lists. All lists are in the category
##  `IsListOrCollection'.
##
DeclareCategoryKernel( "IsList",
    IsListOrCollection,
    IS_LIST );


#############################################################################
##
#C  IsConstantTimeAccessList( <list> )
##
##  this category indicates whether the access to all elements of the list
##  will take roughly the same time.
##  This is implied by `IsList and IsInternalRep',
##  so all strings, Boolean lists, ranges, and internal plain lists are
##  in this category.
##
##  But also enumerators can have this representation if they know about
##  constant time access to their elements.
##
DeclareCategory( "IsConstantTimeAccessList",
    IsList );

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

MAX_SIZE_LIST_INTERNAL := 2^28 - 1;


#############################################################################
##
#R  IsEnumerator  . . . . . . . . . . . . . .  representation for enumerators
##
DeclareRepresentation( "IsEnumerator",
    IsComponentObjectRep and IsAttributeStoringRep and IsList,
    [] );


#############################################################################
##
#O  Length( <list> )  . . . . . . . . . . . . . . . . . . .  length of a list
##
##  The length of <list> is the index of the last bound entry in <list>.
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
#O  ConstantTimeAccessList( <list> )
##
##  `ConstantTimeAccessList' returns an immutable list containing the same
##  elements as the list <list> (which may have holes) in the same order.
##  If <list> is already a constant time access list,
##  `ConstantTimeAccessList' returns <list> directly.
##  Otherwise it puts all elements and holes of <list> into a new list and
##  makes that list immutable.
##
DeclareOperation( "ConstantTimeAccessList",
    [ IsList ] );


#############################################################################
##
#O  AsListSortedList( <list> )
##
##  `AsListSortedList' returns an immutable list containing the same elements
##  as the list <list> (which may have holes) in strictly sorted order.
##  If <list> is already  immutable and  strictly sorted,
##  `AsListSortedList' returns <list> directly.
##  Otherwise it makes a deep copy, and makes that copy immutable.
##  `AsListSortedList' is an internal function.
##

#DeclareOperationKernel( "AsListSortedList",
#    [ IsList ],
#    AS_LIST_SORTED_LIST );
#T  1996/10/28 fceller at the moment this is defined as function in kernel.g
AsListSortedList := AS_LIST_SORTED_LIST;


#############################################################################
##
#C  IsDenseList(<obj>)
##
##  A list is dense if it has no holes.

# DeclareCategory("IsDenseList",IsList);
DeclareCategoryKernel( "IsDenseList",
        IsList,
        IS_DENSE_LIST );


#############################################################################
##
#C  IsHomogeneousList(<obj>)
##
##  A homogeneous list is a dense list whose elements lie in the same family.
##  The empty list is homogeneous but not a collection.
##  A nonempty homogeneous list is also a collection.
#T can we guarantee this?
#DeclareCategory("IsHomogeneousList",IsList);
##
DeclareCategoryKernel( "IsHomogeneousList",
        IsDenseList,
        IS_HOMOG_LIST );


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
#P  IsNSortedList(<obj>)
##
DeclarePropertyKernel( "IsNSortedList", IsDenseList, IS_NSORT_LIST );


#############################################################################
##
#P  IsSSortedList(<obj>)
##
##  (short for ``IsStrictlySortedList'')
##  returns whether a list is dense, homogeneous and strictly sorted, that
##  is if $<obj>[i]\lneqq obj>[j]$ whenever $i\< j$. In particular, such
##  lists must be duplicate free.  In strictly sorted
##  lists, the element test can be done by binary search.

#DeclareProperty("IsSSortedList",IsList);
DeclarePropertyKernel( "IsSSortedList", IsHomogeneousList, IS_SSORT_LIST );


#############################################################################
##
#P  IsDuplicateFreeList(<obj>)
##
##  A list is duplicate free if it is dense and does not contain equal
##  entries in different positions.
##
DeclareProperty( "IsDuplicateFreeList", IsDenseList );

InstallTrueMethod( IsDuplicateFreeList, IsSSortedList );


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
#C  IsTable(<obj>)
##
##  A *table* is a list of homogeneous lists of same length which lie in the
##  same family.
##
#DeclareCategory("IsTable",IsHomogeneousList);
DeclareCategoryKernel( "IsTable", IsHomogeneousList, IS_TABLE_LIST );


#############################################################################
##
#O  Position(<list>,<obj>[,<from>]) . . . . . position of an object in a list
##
##  returns the position of the first occurence <obj> in <list> or <fail> if
##  <obj> is not contained in <list>. If a staring index <from> is given, it
##  returns the position of the first occurence starting the search at
##  position <from>.  (Methods for the version without start position <from>
##  must be installed as methods with three arguments, the third being
##  `IsZeroCyc'.)
##
DeclareOperationKernel( "Position", [ IsList, IsObject, IS_INT ], POS_LIST );


#############################################################################
##
#O  PositionCanonical( <list>, <obj> )  . . . position of canonical associate
##
##  returns the position of the canonical associate of <obj> in <list>. The
##  definition of this associate is given implicitly in <list>. For ordinary
##  lists it is defined as the element itself (and `PositionCanonical' thus
##  defaults to `Position') but for objects behaving like lists other
##  ``canonical associates'' can be defined.
##
DeclareOperation( "PositionCanonical", [ IsList, IsObject ]);


#############################################################################
##
#O  PositionNthOccurence(<list>,<obj>,<n>)  pos. of <n>th occurrence of <obj>
##
##  returns the position of the <n>-th occurence of <obj> in <list> and
##  returs `fail' if <obj> does not occur <n> times.
##
DeclareOperation( "PositionNthOccurence", [ IsList, IsObject, IS_INT ] );


#############################################################################
##
#O  PositionSorted( <list>, <elm> ) . .  position of an object in sorted list
#O  PositionSorted( <list>, <elm>, <func> )
##
##  In the first form `PositionSorted' returns the position of the element
##  <elm> in the sorted list <list>.
##  
##  In the second form `PositionSorted' returns the position of the element
##  <elm> in the list <list>, which must be sorted with respect to <func>.
##  <func> must be a function of two arguments that returns `true' if the
##  first argument is less than the second argument and `false' otherwise.
##  
##  `PositionSorted' returns <pos> such  that $<list>[<pos>-1] \< <elm>$ and
##  $<elm> \le <list>[<pos>]$.
##  That means, if <elm> appears once in <list>, its position is returned.
##  If <elm> appears several times in <list>, the position of the first
##  occurrence is returned.
##  If <elm> is not an element of <list>, the index where <elm> must be
##  inserted to keep the list sorted is returned.
##
UNBIND_GLOBAL( "PositionSorted" ); # wes declared "2b defined"
DeclareOperation( "PositionSorted", [ IsHomogeneousList, IsObject ] );


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
##  returns the first position of an element in <list> for which the
##  property tester function <func> returns `true'.
##
DeclareOperation( "PositionProperty", [ IsDenseList, IsFunction ] );


#############################################################################
##
#O  PositionBound(<list>) . . . . . position of first bound element in a list
##
##  returns the first index for which an element is bound in <list>. For the
##  empty list it returns `fail'.
##
DeclareOperation( "PositionBound", [ IsList ] );


#############################################################################
##
#O  Add(<list>,<obj>) . . . . . . . . . . add an element to the end of a list
##
##  Adds the element <obj> to the end of <list>, therby increasing the
##  length of <list> by one.
#DeclareOperation( "Add", [ IsList, IsObject ] );
DeclareOperationKernel( "Add", [ IsList, IsObject ], ADD_LIST );


#############################################################################
##
#O  Append(<list1>,<list2>) . . . . . . . . . . . . . append a list to a list
##
##  Appends <list2> to <list1>, changing <list1> which therefore must be
##  mutable.

# DeclareOperation( "Append", [ IsList and IsMutable, IsList ])
DeclareOperationKernel( "Append", [ IsList and IsMutable, IsList ],
    APPEND_LIST );


#############################################################################
##
#F  Apply( <list>, <func> ) . . . . . . . .  apply a function to list entries
##
##  `Apply' applies <func> to every member of <list> and replaces an entry by
##  the corresponding return value.
##  Warning:  The previous contents of <list> will be lost.
##
DeclareGlobalFunction( "Apply" );


#############################################################################
##
#O  Concatenation(<list1>,<list2>,...)  . . . . . . .  concatenation of lists
##
##  returns a list that consists of the elements of <list1>, followed by the
##  elements of <list2> et cetera.
##
DeclareGlobalFunction( "Concatenation" );


#############################################################################
##
#O  Compacted(<list>) . . . . . . . . . . . . . . .  remove holes from a list
##
##  returns a new list that contains the elements of <list> in the same
##  order but omitting any holes.
##
DeclareOperation( "Compacted", [ IsList ] );


#############################################################################
##
#O  Collected(<list>) . . . . . . . . . . . collect like elements from a list
##
##  returns a new list <new> that contains for each different element <elm>
##  of <list> a list of length two, the first element of this is <elm>
##  itself and the second element is the number of times <elm> appears in
##  <list>. The order of those pairs in new corresponds to the ordering of
##  the elements elm, so that the result is sorted. For all pairs of
##  elements in <list> the order $\<$ must be defined. If this is not the
##  case `Unique' must be used.
##
DeclareOperation( "Collected", [ IsList ] );


#############################################################################
##
#O  Unique(<list>)  . . . . . . . . . .  duplicate free list of list elements
#O  DuplicateFreeList(<list>)
##
##  `Unique' returns a new (mutable) list whose entries are the elements
##  of <list> with
##  duplicates removed. `Unique' only uses the `=' comparison and will not
##  sort the result. Therefore it can be used even if the objects in the
##  list are not in the same family. `DuplicateFreeList' is an alias for
##  `Unique'
##
DeclareOperation( "DuplicateFreeList", [ IsList ] );

DeclareSynonym( "Unique", DuplicateFreeList );


#############################################################################
##
#A  AsDuplicateFreeList(<list>)   . . . .duplicate free list of list elements
##
##  returns the same result as `DuplicateFreeList' ("DuplicateFreeList"),
##  but as an attribute returns an immutable list.
##
DeclareAttribute( "AsDuplicateFreeList", IsList );


#############################################################################
##
#O  Flat(<list>)  . . . . . . . . list of elements of a nested list structure
##
##  returns a list containing all the lements in <list> and (iterated)
##  sublists of <list> in a list of neting level one.
##
DeclareOperation( "Flat", [ IsList ] );


#############################################################################
##
#O  Reversed(<list>)  . . . . . . . . . . . .  reverse the elements in a list
##
##  returns a new list, containing the elements of the dense list <list> in
##  reversed order.
##
DeclareOperation( "Reversed", [ IsDenseList ] );


#############################################################################
##
#F  Lexicographically( <list1>, <list2> )
##
##  Let <list1> and <list2> be two dense lists, but not necessarily
##  collections, such that for all $i$, the entries in both lists at position
##  $i$ can be compared via `\<'.
##  `Lexicographically' returns `true' if <list1> is smaller than <list2>
##  w.r.t.~lexicographical ordering, and `false' otherwise.
##
DeclareGlobalFunction( "Lexicographically" );


#############################################################################
##
#O  Sort(<list>)  . . . . . . . . . . . . . . . . . . . . . . . . sort a list
#O  Sort( <list>, <func> )  . . . . . . . . . . . . . . . . . . . sort a list
##
## sorts the list  <list> in increasing  order.  In
## the first form `Sort' uses the operator `\<' to compare the elements.  In
## the  second  form  `Sort' uses  the  function <func> to compare elements.
## This function must be a function taking two arguments that returns `true'
## if the first is strictly smaller than the second and 'false' otherwise.
##
##  `Sort'  does not return anything, since  it changes  the argument <list>.
##  Use  `ShallowCopy' (see "ShallowCopy") if you  want to keep  <list>.  Use
##  `Reversed'  (see  "Reversed") if you  want to  get a  new  list sorted in
##  decreasing order.
##  
##  It is possible to sort lists that contain multiple elements which compare
##  equal.    It is not  guaranteed  that those  elements keep their relative
##  order, i.e., `Sort' is not stable.
##
DeclareOperation( "Sort", [ IsList and IsMutable ] );


#############################################################################
##
#O  Sortex(<list>) . . . sort a list (stable), return the applied permutation
##
##  sorts the list <list> and  returns the  permutation that must be
##  applied to <list> to obtain the sorted list.
##
DeclareOperation( "Sortex", [ IsHomogeneousList and IsMutable ] );


#############################################################################
##
#F  SortingPerm( <list> )
##
##  `SortingPerm' returns the same as `Sortex( <list> )' but does *not*
##  change the argument.
##    
DeclareGlobalFunction( "SortingPerm" );


#############################################################################
##
#F  PermListList( <lst>, <lst2> ) . . . . what permutation of <lst> is <lst2>
##
##  returns a permutation $p$ of `[ 1 .. Length( list1 ) ]'
##  such that `list1[i^$p$] = list2[i]'.
##  It returns `fail' if there is no such permutation.
##
DeclareGlobalFunction( "PermListList" );


#############################################################################
##
#O  SortParallel(<list>,<list2>)  . . . . . . . .  sort two lists in parallel
#O  SortParallel( <list>, <list2>, <func> ) . . .  sort two lists in parallel
##
##  sorts the list <list1>  in increasing order just as 'Sort'
##  (see "Sort") does.  In  parallel it applies  the same exchanges  that are
##  necessary to sort <list1> to the list <list2>, which must of  course have
##  at least as many elements as <list1> does.
##
UNBIND_GLOBAL( "SortParallel" );
DeclareOperation( "SortParallel",
    [ IsHomogeneousList and IsMutable, IsDenseList and IsMutable ] );


#############################################################################
##
#O  Maximum( <obj>, <obj>... )  . . . . . . . . . . . . .  maximum of objects
##
DeclareGlobalFunction( "Maximum" );

#############################################################################
##
#O  MaximumList( [ <obj>, <obj>... ] )  . . . . . . . . . . . maximum of list
##
##  returns the largest element in the list <list>.
##
DeclareOperation( "MaximumList", [ IsHomogeneousList ] );


#############################################################################
##
#O  Minimum( <obj>, <obj>... )  . . . . . . . . . . . . .  minimum of objects
##
DeclareGlobalFunction( "Minimum" );


#############################################################################
##
#O  MinimumList( [ <list> ] )
##
##  returns the smallest element in the list <list>.
##
DeclareOperation( "MinimumList", [ IsHomogeneousList ] );


#############################################################################
##
#O  Cartesian(<list>,<list>...) . . . . . . . . .  cartesian product of lists
##
DeclareGlobalFunction( "Cartesian" );


#############################################################################
##
#O  Permuted(<list>,<perm>)  . . . . . . . . .  apply a permutation to a list
##
##  returns  a new  list <new> that contains  the elements  of the
##  list  <list>  permuted according  to  the  permutation  <perm>.   That is
##  `<new>[<i> ^ <perm>] = <list>[<i>]'.
##
DeclareOperation( "Permuted", [ IsList, IS_PERM ] );


#############################################################################
##
#F  IteratorList(<list>)
##
##  `IteratorList' returns a new iterator that allows iteration over the
##  elements of <list> (which may have holes) in the same order.
##
DeclareGlobalFunction( "IteratorList" );


#############################################################################
##
#F  First( <C>, <func> )  . . .  find first element in a list with a property
##
##  `First' returns the first element of <C> which fullfills <func>.
##  If no such element is contained in <C>, then `First' returns fail.
##
#O  First( <C>, <func> )
##
##  `FirstOp' is the operation called by `First' if <C> is not
##  an internal list.                             
##
DeclareGlobalFunction( "First" );

DeclareOperation( "FirstOp", [ IsList, IsFunction ] );


#############################################################################
##
#O  Iterated(<C>,<func>)  . . . . . . . . . .  iterate a function over a list
##
##  returns the result of the iterated application of the function <func>,
##  which must take two arguments, to the elements of list. More precisely
##  `Iterated' returns the result of the application
##  <f>(..<f>( <f>( <list>[1], <list>[2] ), <list>[3] ),..,<list>[n] ). 
##
DeclareOperation( "Iterated", [ IsList, IsFunction ] );

#############################################################################
##
#F UnionBlist
##
DeclareGlobalFunction( "UnionBlist" );

#############################################################################
##
#F DifferenceBlist
##
DeclareGlobalFunction("DifferenceBlist");

#############################################################################
##
#F IntersectionBlist
##
DeclareGlobalFunction( "IntersectionBlist" );

#############################################################################
##
#F  ListWithIdenticalEntries( <n>, <obj> )
##
##  is a list of length <n> that has the object <obj> stored at each of the
##  positions from 1 to <n>.
##
DeclareGlobalFunction( "ListWithIdenticalEntries" );


#############################################################################
##
#F  ProductPol( <coeffs_f>, <coeffs_g> )  . . . .  product of two polynomials
##
##  Let <coeffs_f> and <coeffs_g> be coefficients lists of two univariate
##  polynomials $f$ and $g$, respectively.
##  `ProductPol' returns the coefficients list of the product $f g$.
##
##  The coefficient of $x^i$ is assumed to be stored at position $i+1$ in
##  the coefficients lists.
##
DeclareGlobalFunction( "ProductPol" );


#############################################################################
##
#F  ValuePol( <coeffs_f>, <point> ) . . . .  evaluate a polynomial at a point
##
##  Let <coeffs_f> be the coefficients list of a univariate polynomial $f$,
##  and <x> a point.
##  `ValuePol' returns the value $f(<point>)$.
##
##  The coefficient of $x^i$ is assumed to be stored at position $i+1$ in
##  the coefficients list.
##
DeclareGlobalFunction( "ValuePol" );


#############################################################################
##
#E  list.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
