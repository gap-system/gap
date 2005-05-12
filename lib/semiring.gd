#############################################################################
##
#W  semiring.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for semirings.
##
Revision.semiring_gd :=
    "@(#)$Id$";


#############################################################################
##
#P  IsLDistributive( <C> )
##
##  is `true' if the relation $a * ( b + c ) = ( a * b ) + ( a * c )$
##  holds for all elements $a$, $b$, $c$ in the collection <C>,
##  and `false' otherwise.
##
DeclareProperty( "IsLDistributive", IsRingElementCollection );

InstallSubsetMaintenance( IsLDistributive,
    IsRingElementCollection and IsLDistributive,
    IsRingElementCollection );

InstallFactorMaintenance( IsLDistributive,
    IsRingElementCollection and IsLDistributive,
    IsObject,
    IsRingElementCollection );


#############################################################################
##
#P  IsRDistributive( <C> )
##
##  is `true' if the relation $( a + b ) * c = ( a * c ) + ( b * c )$
##  holds for all elements $a$, $b$, $c$ in the collection <C>,
##  and `false' otherwise.
##
DeclareProperty( "IsRDistributive", IsRingElementCollection );

InstallSubsetMaintenance( IsRDistributive,
    IsRingElementCollection and IsRDistributive,
    IsRingElementCollection );

InstallFactorMaintenance( IsRDistributive,
    IsRingElementCollection and IsRDistributive,
    IsObject,
    IsRingElementCollection );


#############################################################################
##
#P  IsDistributive( <C> )
##
##  is `true' if the collection <C> is both left and right distributive,
##  and `false' otherwise.
##
DeclareSynonymAttr( "IsDistributive", IsLDistributive and IsRDistributive );


#############################################################################
##
#P  IsSemiring( <S> )
##
##  A *semiring* in {\GAP} is an additive magma (see~"IsAdditiveMagma")
##  that is also a magma (see~"IsMagma"),
##  such that addition `+' and multiplication `\*' are distributive.
##
##  The multiplication need *not* be associative (see~"IsAssociative").
##  For example, a Lie algebra (see~"Lie Algebras") is regarded as a
##  semiring in {\GAP}.
##  A semiring need not have an identity and a zero element,
##  see~"IsSemiringWithOne" and "IsSemiringWithZero".
##
DeclareSynonymAttr( "IsSemiring",
    IsAdditiveMagma and IsMagma and IsDistributive );


#############################################################################
##
#P  IsSemiringWithOne( <S> )
##
##  A *semiring-with-one* in {\GAP} is a semiring (see~"IsSemiring")
##  that is also a magma-with-one (see~"IsMagmaWithOne").
##
##  Note that a semiring-with-one need not contain a zero element
##  (see~"IsSemiringWithZero").
##
DeclareSynonymAttr( "IsSemiringWithOne",
    IsAdditiveMagma and IsMagmaWithOne and IsDistributive );


#############################################################################
##
#P  IsSemiringWithZero( <S> )
##
##  A *semiring-with-zero* in {\GAP} is a semiring (see~"IsSemiring")
##  that is also an additive magma-with-zero (see~"IsAdditiveMagmaWithZero").
##
##  Note that a semiring-with-zero need not contain an identity element
##  (see~"IsSemiringWithOne").
##
DeclareSynonymAttr( "IsSemiringWithZero",
    IsAdditiveMagmaWithZero and IsMagma and IsDistributive );


#############################################################################
##
#P  IsSemiringWithOneAndZero( <S> )
##
DeclareSynonymAttr( "IsSemiringWithOneAndZero",
    IsAdditiveMagmaWithZero and IsMagmaWithOne and IsDistributive );


#############################################################################
##
#A  GeneratorsOfSemiring( <S> )
##
##  `GeneratorsOfSemiring' returns a list of elements such that
##  the semiring <S> is the closure of these elements
##  under addition and multiplication.
##
DeclareAttribute( "GeneratorsOfSemiring", IsSemiring );


#############################################################################
##
#A  GeneratorsOfSemiringWithOne( <S> )
##
##  `GeneratorsOfSemiringWithOne' returns a list of elements such that
##  the semiring <R> is the closure of these elements
##  under addition, multiplication, and taking the identity element
##  `One( <S> )'.
##
##  <S> itself need *not* be known to be a semiring-with-one.
##
DeclareAttribute( "GeneratorsOfSemiringWithOne", IsSemiringWithOne );


#############################################################################
##
#A  GeneratorsOfSemiringWithZero( <S> )
##
##  `GeneratorsOfSemiringWithZero' returns a list of elements such that
##  the semiring <S> is the closure of these elements
##  under addition, multiplication, and taking the zero element
##  `Zero( <S> )'.
##
##  <S> itself need *not* be known to be a semiring-with-zero.
##
DeclareAttribute( "GeneratorsOfSemiringWithZero", IsSemiringWithZero );


#############################################################################
##
#A  GeneratorsOfSemiringWithOneAndZero( <S> )
##
DeclareAttribute( "GeneratorsOfSemiringWithOneAndZero",
    IsSemiringWithOneAndZero );


#############################################################################
##
#A  AsSemiring( <C> )
##
##  If the elements in the collection <C> form a semiring
##  then `AsSemiring' returns this semiring,
##  otherwise `fail' is returned.
##
DeclareAttribute( "AsSemiring", IsRingElementCollection );


#############################################################################
##
#A  AsSemiringWithOne( <C> )
##
##  If the elements in the collection <C> form a semiring-with-one
##  then `AsSemiringWithOne' returns this semiring-with-one,
##  otherwise `fail' is returned.
##
DeclareAttribute( "AsSemiringWithOne", IsRingElementCollection );


#############################################################################
##
#A  AsSemiringWithZero( <C> )
##
##  If the elements in the collection <C> form a semiring-with-zero
##  then `AsSemiringWithZero' returns this semiring-with-zero,
##  otherwise `fail' is returned.
##
DeclareAttribute( "AsSemiringWithZero", IsRingElementCollection );


#############################################################################
##
#A  AsSemiringWithOneAndZero( <C> )
##
##  If the elements in the collection <C> form a semiring-with-one-and-zero
##  then `AsSemiringWithOneAndZero' returns this semiring-with-one-and-zero,
##  otherwise `fail' is returned.
##
DeclareAttribute( "AsSemiringWithOneAndZero", IsRingElementCollection );


#############################################################################
##
#O  ClosureSemiring( <S>, <s> )
#O  ClosureSemiring( <S>, <T> )
##
##  For a semiring <S> and either an element <s> of its elements family
##  or a semiring <T>,
##  `ClosureSemiring' returns the semiring generated by both arguments.
##
DeclareOperation( "ClosureSemiring", [ IsSemiring, IsObject ] );


#############################################################################
##
#O  SemiringByGenerators( <C> ) . . .  semiring gener. by elements in a coll.
##
##  `SemiringByGenerators' returns the semiring generated by the elements
##  in the collection <C>,
##  i.~e., the closure of <C> under addition and multiplication.
##
DeclareOperation( "SemiringByGenerators", [ IsCollection ] );


#############################################################################
##
#O  SemiringWithOneByGenerators( <C> )
##
##  `SemiringWithOneByGenerators' returns the semiring-with-one generated by
##  the elements in the collection <C>, i.~e., the closure of <C> under
##  addition, multiplication, and taking the identity of an element.
##
DeclareOperation( "SemiringWithOneByGenerators", [ IsCollection ] );


#############################################################################
##
#O  SemiringWithZeroByGenerators( <C> )
##
DeclareOperation( "SemiringWithZeroByGenerators", [ IsCollection ] );


#############################################################################
##
#O  SemiringWithOneAndZeroByGenerators( <C> )
##
DeclareOperation( "SemiringWithOneAndZeroByGenerators", [ IsCollection ] );


#############################################################################
##
#F  Semiring( <r> ,<s>, ... )  . . . . . . semiring generated by a collection
#F  Semiring( <C> )  . . . . . . . . . . . semiring generated by a collection
##
##  In the first form `Semiring' returns the smallest semiring that
##  contains all the elements <r>, <s>... etc.
##  In the second form `Semiring' returns the smallest semiring that
##  contains all the elements in the collection <C>.
##  If any element is not an element of a semiring or if the elements lie in
##  no common semiring an error is raised.
##
DeclareGlobalFunction( "Semiring" );


#############################################################################
##
#F  SemiringWithOne( <r>, <s>, ... )
#F  SemiringWithOne( <C> )
##
##  In the first form `SemiringWithOne' returns the smallest
##  semiring-with-one that contains all the elements <r>, <s>... etc.
##  In the second form `SemiringWithOne' returns the smallest
##  semiring-with-one that contains all the elements in the collection <C>.
##  If any element is not an element of a semiring or if the elements lie in
##  no common semiring an error is raised.
##
DeclareGlobalFunction( "SemiringWithOne" );


#############################################################################
##
#F  SemiringWithZero( <r>, <s>, ... )
#F  SemiringWithZero( <C> )
##
DeclareGlobalFunction( "SemiringWithZero" );


#############################################################################
##
#F  SemiringWithOneAndZero( <r>, <s>, ... )
#F  SemiringWithOneAndZero( <C> )
##
DeclareGlobalFunction( "SemiringWithOneAndZero" );


#############################################################################
##
#F  Subsemiring( <S>, <gens> )
#F  SubsemiringNC( <S>, <gens> )
##
DeclareGlobalFunction( "Subsemiring" );
DeclareGlobalFunction( "SubsemiringNC" );


#############################################################################
##
#F  SubsemiringWithOne( <S>, <gens> )
#F  SubsemiringWithOneNC( <S>, <gens> )
##
DeclareGlobalFunction( "SubsemiringWithOne" );
DeclareGlobalFunction( "SubsemiringWithOneNC" );


#############################################################################
##
#F  SubsemiringWithZero( <S>, <gens> )
#F  SubsemiringWithZeroNC( <S>, <gens> )
##
DeclareGlobalFunction( "SubsemiringWithZero" );
DeclareGlobalFunction( "SubsemiringWithZeroNC" );


#############################################################################
##
#F  SubsemiringWithOneAndZero( <S>, <gens> )
#F  SubsemiringWithOneAndZeroNC( <S>, <gens> )
##
DeclareGlobalFunction( "SubsemiringWithOneAndZero" );
DeclareGlobalFunction( "SubsemiringWithOneAndZeroNC" );


#############################################################################
##
#A  CentralIdempotentsOfSemiring( <S> )
##
##  For a semiring <S>, this function returns
##  a list of central primitive idempotents such that their sum is
##  the identity element of <S>.
##  Therefore <S> is required to have an identity.
##
DeclareAttribute( "CentralIdempotentsOfSemiring", IsSemiring );


#############################################################################
##
#E

