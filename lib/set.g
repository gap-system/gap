#############################################################################
##
#W  set.g                         GAP library                Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains some set functions that have to be known very early in
##  the bootstrap stage (therefore they are not in list.gi)
##
Revision.set_g :=
    "@(#)$Id$";


#############################################################################
##
#F  ListSortedList( <list> )  . . . . . . . . . . . . . . . . . set of <list>
##
##  'ListSortedList' returns a strictly sorted list containing the same
##  elements as the list <list> (which may have holes).
##  'ListSortedList' makes a shallow copy, sorts it, and removes duplicates.
##  'ListSortedList' is an internal function.
##
ListSortedList := LIST_SORTED_LIST;


#############################################################################
##
#F  IsEqualSet( <list1>, <list2> )  . . . .  check if lists are equal as sets
##
##  tests whether <list1> and <list2> are equal *when viewed as sets*, that
##  is if every element of <list1> is contained in <list2> and vice versa.

# DeclareOperation("IsEqualSet",[IsList,IsList]);
IsEqualSet := IS_EQUAL_SET;


#############################################################################
##
#F  IsSubsetSet( <list1>, <list2> ) . check if <list2> is a subset of <list1>
##
##  tests whether every element of <list2> is contained in <list1>.

# DeclareOperation("IsSubsetSet",[IsList,IsList]);
IsSubsetSet := IS_SUBSET_SET;


#############################################################################
##
#F  AddSet( <set>, <obj> )  . . . . . . . . . . . . . . .  add <obj> to <set>
##
##  adds the object <obj> to the set <set>, changing <set> in place. <obj>
##  must be in the same family as the elements of <set>. If <obj> is already
##  contained in <set> then <set> is not changed.

# DeclareOperation("AddSet",[IsList,IsObject]);
AddSet := ADD_SET;


#############################################################################
##
#F  RemoveSet( <set>, <obj> ) . . . . . . . . . . . . remove <obj> from <set>
##
##  removes the object <obj> from the set <set>, changing <set> in place.
##  If <obj> is not contained in <set> then <set> is not changed.

# DeclareOperation("RemoveSet",[IsList,IsObject]);
RemoveSet := REM_SET;


#############################################################################
##
#F  UniteSet( <set>, <list> ) . . . . . . . . . . . . unite <set> with <list>
##
##  Unites the set <set> with <list>, changing <set> in place. This is
##  equivalent to adding all elements of <list> to <set>.

# DeclareOperation("UniteSet",[IsList,IsList]);
UniteSet := UNITE_SET;


#############################################################################
##
#F  IntersectSet( <set>, <list> ) . . . . . . . . intersect <set> with <list>
##
##  Intersects the set <set> with <list>, changing <set> in place. This is
##  equivalent to removing from <set> all elements of <set> that are not
##  contained in <list>.

# DeclareOperation("IntersectSet",[IsList,IsList]);
IntersectSet := INTER_SET;


#############################################################################
##
#F  SubtractSet( <set>, <list> )  . . . . . remove <list> elements from <set>
##
##  subtracts <list> from the set <set>, changing <set> in place. This is
##  equivalent to removing all elements of <list> from <set>.

# DeclareOperation("SubtractSet",[IsList,IsList]);
SubtractSet := SUBTR_SET;


#############################################################################
##
#E  set.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
