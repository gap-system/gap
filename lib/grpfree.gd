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
##  In addition,   elements  of  a free   group are
##  (associative) words, that is they have a normal  form that allows an easy
##  equalitity test.  
##
Revision.grpfree_gd :=
    "$Id$";


#############################################################################
##
#F  IsElementOfFreeGroup  . . . . . . . . . . . . .  elements in a free group
##
DeclareSynonym( "IsElementOfFreeGroup", IsAssocWordWithInverse );
DeclareSynonym( "IsElementOfFreeGroupFamily",IsAssocWordWithInverseFamily );


#############################################################################
##
#F  FreeGroup( [<wfilt>,]<rank> )
#F  FreeGroup( [<wfilt>,]<rank>, <name> )
#F  FreeGroup( [<wfilt>,]<name1>, <name2>, ... )
#F  FreeGroup( [<wfilt>,]<names> )
#F  FreeGroup( [<wfilt>,]infinity, <name>, <init> )
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
##  Called in the fifth form, `FreeGroup' returns a free group on
##  infinitely many generators, where the first generators are printed
##  by the names in the list <init>, and the other generators by <name>
##  and an appended number.
##
##  If the extra argument <wfilt> is given, it must be either
##  `IsSyllableWordsFamily' or `IsLetterWordsFamily' or
##  `IsWLetterWordsFamily' or `IsBLetterWordsFamily'. The filter then
##  specifies the representation used for the elements of the free group
##  (see~"Representations for Associative Words"). If no such filter is
##  given, a letter representation is used.
##
DeclareGlobalFunction( "FreeGroup" );


#############################################################################
##
#E  grpfree.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

