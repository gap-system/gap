#############################################################################
##
#W  tuples.gd                   GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for tuples.
##
##  Tuples are immutable finite type-safe lists.
##
Revision.tuples_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsTuple( <obj> )  . . . . . . . . . . . . . . . . . .  category of tuples
##
##  `IsTuple' is a subcategory of the meet of `IsDenseList'
##  (see~"IsDenseList"), `IsMultiplicativeElementWithInverse'
##  (see~"IsMultiplicativeElementWithInverse"),
##  and `IsAdditiveElementWithInverse' (see~"IsAdditiveElementWithInverse"),
#T  and `IsCopyable' (see~"Mutability and Copyability"),
##  where the arithmetic operations (addition, zero, additive inverse,
##  multiplication, powering, one, inverse) are defined componentwise.
##
##  Note that each of these operations will cause an error message if
##  its result for at least one component cannot be formed.
##
#T  For a tuple, `ShallowCopy' returns a mutable plain list with the same
#T  entries.
##  The sum and the product of a tuple and a list in `IsListDefault' is the
##  list of sums and products, respectively.
##  The sum and the product of a tuple and a non-list is the tuple of
##  componentwise sums and products, respectively.
##
DeclareCategory( "IsTuple",
        IsDenseList
    and IsCopyable
    and IsMultiplicativeElementWithInverse
    and IsAdditiveElementWithInverse );


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
DeclareOperation( "TuplesFamily", [ IsCollection ] );


#############################################################################
##
#A  ComponentsOfTuplesFamily( <tuplesfam> ) . . . . . . .  component families
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
DeclareOperation( "Tuple", [ IsList ]);
DeclareOperation( "TupleNC", [ IsTupleFamily, IsList ]);


#############################################################################
##
#E

