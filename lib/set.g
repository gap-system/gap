#############################################################################
##
#W  set.g                         GAP library                Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
IsEqualSet := IS_EQUAL_SET;


#############################################################################
##
#F  IsSubsetSet( <list1>, <list2> ) . check if <list2> is a subset of <list1>
##
IsSubsetSet := IS_SUBSET_SET;


#############################################################################
##
#F  AddSet( <set>, <obj> )  . . . . . . . . . . . . . . .  add <obj> to <set>
##
AddSet := ADD_SET;


#############################################################################
##
#F  RemoveSet( <set>, <obj> ) . . . . . . . . . . . . remove <obj> from <set>
##
RemoveSet := REM_SET;


#############################################################################
##
#F  UniteSet( <set>, <list> ) . . . . . . . . . . . . unite <set> with <list>
##
UniteSet := UNITE_SET;


#############################################################################
##
#F  IntersectSet( <set>, <list> ) . . . . . . . . intersect <set> with <list>
##
IntersectSet := INTER_SET;


#############################################################################
##
#F  SubtractSet( <set>, <list> )  . . . . . remove <list> elements from <set>
##
SubtractSet := SUBTR_SET;


#############################################################################
##

#E  set.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
