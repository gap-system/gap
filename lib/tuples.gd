#############################################################################
##
#W  tuples.gd                   GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares the operations for tuples
##
##  tuples are immutable finite type-safe lists. 
##
Revision.tuples_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsTuple( <obj> )  . . . . . . . . . . . . . . . . . .  category of tuples
##

DeclareCategory( "IsTuple",
    IsDenseList and IsMultiplicativeElementWithInverse );


#############################################################################
##
#C  IsTupleFamily( <family> ) . . . . . . . . . . category of tuples families
##

DeclareCategoryFamily( "IsTuple" );


#############################################################################
##
#C  IsTupleCollection( <coll> )   . . . . . .  category of tuples collections
##

DeclareCategoryCollections( "IsTuple" );


#############################################################################
##
#O  TuplesFamily ( <famlist> )  . . . . . . . .  family of tuples of elements
##
##
  
DeclareOperation( "TuplesFamily", [ IsCollection ] );


#############################################################################
##
#A  ComponentsOfTuplesFamily( <tuplesfam> ) . . . . . . .  component families 
##
##

DeclareAttribute( "ComponentsOfTuplesFamily", IsTupleFamily );

#############################################################################
##
#V  TUPLES_FAMILIES . . . . . . . . . . .  all tuples families so far created
##
##  `TUPLES_FAMILIES' is a list whose $i$-th component is a weak pointer
##  object containing all currently known $i+1$ component tuples families.
##

DeclareGlobalVariable( "TUPLES_FAMILIES",
    "list, at position i the list of known i+1 component tuples families" );


#############################################################################
##
#O  Tuple ( <objlist> ) . . . . . . . . . . . .  basic tuple making operation
#O  Tuple ( <tuplesfam>, <objlist> )  . . . alternate form if family is known
##
##  methods of this type have to be OtherMethods
##
#O  TupleNC ( <tuplesfam>, <objlist> )  . . .  omits check on object families
##                                             and objlist length  
##

DeclareOperation( "Tuple", [ IsList ]);
DeclareOperation( "TupleNC", [ IsTupleFamily, IsList ]);


#############################################################################
##
#E  tuples.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



