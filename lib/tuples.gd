#############################################################################
##
#W  tuples.gd                   GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for tuples
##
##  tuples are immutable finite type-safe lists. 
##
Revision.tuples_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsTuple( <obj> ) . . . . . . . . . . . . . . . . . . . category of tuples
##

IsTuple := NewCategory( "IsTuple", IsDenseList );
InstallTrueMethod( IsMultiplicativeElementWithInverse, IsTuple );
InstallTrueMethod( IsMultiplicativeElementWithOne, IsTuple );

#############################################################################
##
#C  IsTuplesFamily( <family> ) . . . . . . . . . category of tuples families
##

IsTuplesFamily := CategoryFamily( "IsTuplesFamily", IsTuple  );


#############################################################################
##
#C  IsTuplesCollection( <coll> )  . . . . . .  category of tuples collections
##

IsTuplesCollection := CategoryCollections( "IsTuplesCollection", IsTuple  );


#############################################################################
##
#O  TuplesFamily ( <famlist> ) . . . . . . . . . family of tuples of elements
##
##
  
TuplesFamily := NewOperation( "TuplesFamily", [ IsCollection ] );


#############################################################################
##
#A  ComponentsOfTuplesFamily( <tuplesfam> ) . . . . . . . .component families 
##
##

ComponentsOfTuplesFamily := NewAttribute( "ComponentsOfTuplesFamily", 
                                    IsTuplesFamily);
SetComponentsOfTuplesFamily := Setter(ComponentsOfTuplesFamily);
HasComponentsOfTuplesFamily := Tester(ComponentsOfTuplesFamily);

#############################################################################
##
#V  TUPLES_FAMILIES . . . . . . . . . . . .all tuples families so far created
##
##  TUPLES_FAMILIES is a list whose ith component is a list of all i+1 
##  component tuples families known so far
##

TUPLES_FAMILIES := [];


##############################################################################
##
#O  Tuple ( <objlist> ) . . . . .. . . . . . . . basic tuple making operation
#O  Tuple ( <tuplesfam>, <objlist> ) . . .  alternate form if family is known
##
##  methods of this kind have to be OtherMethods
##
#O  TupleNC ( <tuplesfam>, <objlist> ) . . . . omits check on object families
##                                             and objlist length  
##

Tuple := NewOperation( "Tuple", [ IsList ]);
TupleNC := NewOperation( "TupleNC", [ IsTuplesFamily, IsList ]);






