#############################################################################
##
#W  grpfree.gd                  GAP library                     Werner Nickel
##
#H  $Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  Free groups are treated as   special cases of finitely presented  groups.
##  This  is done by making  the elements (more specifically, the generators)
##  of  a  free group to   have  the property   IsElementOfFpGroup.  See  the
##  function  FreeGroup().    In addition,   elements  of  a free   group are
##  (associative) words, that is they have a normal  form that allows an easy
##  equalitity test.  
##
##  The methods for  testing equality, multiplying,  etc. are the same as for
##  IsAssocWordWithInverse.  However,  these methods   have to   be installed
##  again  for IsElementOfFpGroup in order   to  guarantee that they will  be
##  chosen over methods for elements of a finitely presented group.
##
Revision.grpfree_gd :=
    "$Id$";

#############################################################################
##
#F  IsElementOfFreeGroup  . . . . . . . . . . . . .  elements in a free group
##
IsElementOfFreeGroup := IsAssocWordWithInverse and IsElementOfFpGroup;


#############################################################################
##
#F  FreeGroup( <rank> )
#F  FreeGroup( <rank>, <name> )
#F  FreeGroup( <name1>, <name2>, ... )
#F  FreeGroup( <names> )
##
##  Called in the first form, `FreeGroup' returns a free group on
##  <rank> generators.
##  Called in the second form, `FreeGroup' returns a free group on
##  <rank> generators, printed as `<name>1', `<name>2' etc.
##  Called in the third form, `FreeGroup' returns a free group on
##  as many generators as arguments, printed as <name1>, <name2> etc.
##  Called in the fourth form, `FreeGroup' returns a free group on
##  as many generators as the length of the list <names>, the $i$-th
##  generator being printed as `<names>[$i$]'.
##
DeclareGlobalFunction( "FreeGroup" );

