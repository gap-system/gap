#############################################################################
##
#W  set.gd                        GAP library                Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains some functions for proper sets.

#1
##  The following functions, if not explicitly stated differently,
##  take two arguments, <set> and <obj>, where <set> must be a proper set,
##  otherwise an error is signalled;
##  If the second argument <obj> is a list that is not a proper set then
##  `Set' (see~"Set") is silently applied to it first (see~"Set").
##
Revision.set_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  SSortedListList( <list> ) . . . . . . . . . . . . . . . . . set of <list>
##
##  `SSortedListList' returns a mutable, strictly sorted list
##  containing the same elements as the *internally represented* list <list>
##  (which may have holes).
##  `SSortedListList' makes a shallow copy, sorts it, and removes duplicates.
##  `SSortedListList' is an internal function.
##
DeclareSynonym( "SSortedListList", LIST_SORTED_LIST );


#############################################################################
##
#O  IsEqualSet( <list1>, <list2> )  . . . .  check if lists are equal as sets
##
##  tests whether <list1> and <list2> are equal *when viewed as sets*, that
##  is if every element of <list1> is an element of <list2> and vice versa.
##  Either argument of `IsEqualSet' may also be a list that is not a proper
##  set, in which case `Set' (see~"Set") is applied to it first.
##
##  If both lists are proper sets then they are of course equal if and only
##  if they are also equal as lists.
##  Thus `IsEqualSet( <list1>, <list2> )' is equivalent to
##  `Set( <list1>  ) = Set( <list2> )' (see~"Set"),
##  but the former is more efficient.
##
DeclareOperation( "IsEqualSet", [ IsList, IsList ] );


#############################################################################
##
#O  IsSubsetSet( <list1>, <list2> ) . check if <list2> is a subset of <list1>
##
##  tests whether every element of <list2> is contained in <list1>.
##  Either argument of `IsSubsetSet' may also be a list that is not a proper
##  set, in which case `Set' (see~"Set") is applied to it first.
##
DeclareOperation( "IsSubsetSet", [ IsList, IsList ] );


#############################################################################
##
#O  AddSet( <set>, <obj> )  . . . . . . . . . . . . . . .  add <obj> to <set>
##
##  adds the element <obj> to the proper set <set>.
##  If <obj> is already contained in <set> then <set> is not changed.
##  Otherwise <obj> is inserted at the correct position such that <set> is
##  again a proper set afterwards.
##
##  Note that <obj> must be in the same family as each element of <set>.
##
DeclareOperation( "AddSet", [ IsList and IsMutable, IsObject ] );


#############################################################################
##
#O  RemoveSet( <set>, <obj> ) . . . . . . . . . . . . remove <obj> from <set>
##
##  removes the element <obj> from the proper set <set>.
##  If <obj> is not contained in <set> then <set> is not changed.
##  If <obj> is an element of <set> it is removed and all the following
##  elements in the list are moved one position forward.
##
DeclareOperation( "RemoveSet", [ IsList and IsMutable, IsObject ] );


#############################################################################
##
#O  UniteSet( <set>, <list> ) . . . . . . . . . . . . unite <set> with <list>
##
##  unites the proper set <set> with <list>.
##  This is equivalent to adding all elements of <list> to <set>
##  (see~"AddSet").
##
DeclareOperation( "UniteSet", [ IsList and IsMutable, IsList ] );


#############################################################################
##
#O  IntersectSet( <set>, <list> ) . . . . . . . . intersect <set> with <list>
##
##  intersects the proper set <set> with <list>.
##  This is equivalent to removing from <set> all elements of <set> that are
##  not contained in <list>.
##
DeclareOperation( "IntersectSet", [ IsList and IsMutable, IsList ] );


#############################################################################
##
#O  SubtractSet( <set>, <list> )  . . . . . remove <list> elements from <set>
##
##  subtracts <list> from the proper set <set>.
##  This is equivalent to removing from <set> all elements of <list>.
##
DeclareOperation( "SubtractSet", [ IsList and IsMutable, IsList ] );


#############################################################################
##
#E
##

