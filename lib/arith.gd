#############################################################################
##
#W  arith.gd                    GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations of the arithmetic operations, and the
##  declarations of the categories for elements that allow those operations.
##
##  This file contains the definitions of categories for elements in families
##  that allow certain arithmetical operations,
##  and the definition of properties, attributes, and operations for these
##  elements.
##
##  Note that the arithmetical operations are usually only partial functions.
##  This  means that  a  multiplicative  element is  simply an  element whose
##  family allows a multiplication of *some* of its  elements.  It does *not*
##  mean that the the product of *any* two elements in the family is defined,
##
Revision.arith_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsExtAElement(<obj>)
##
DeclareCategory( "IsExtAElement", IsObject );
DeclareCategoryCollections( "IsExtAElement" );
DeclareCategoryCollections( "IsExtAElementCollection" );
DeclareSynonym( "IsExtAElementList",
    IsExtAElementCollection and IsList );
DeclareSynonym( "IsExtAElementTable",
    IsExtAElementCollColl   and IsTable );
InstallTrueMethod( IsExtAElement,
    IsExtAElementCollection );


#############################################################################
##
#C  IsAdditiveElement(<obj>)
##
DeclareCategory( "IsAdditiveElement", IsExtAElement );
DeclareCategoryCollections( "IsAdditiveElement" );
DeclareCategoryCollections( "IsAdditiveElementCollection" );
DeclareCategoryCollections( "IsAdditiveElementCollColl" );
DeclareSynonym( "IsAdditiveElementList",
    IsAdditiveElementCollection and IsList );
DeclareSynonym( "IsAdditiveElementTable",
    IsAdditiveElementCollColl   and IsTable );
InstallTrueMethod( IsAdditiveElement,
    IsAdditiveElementList );
InstallTrueMethod( IsAdditiveElementList,
    IsAdditiveElementTable );


#############################################################################
##
#C  IsAdditiveElementWithZero(<obj>)
##
DeclareCategory( "IsAdditiveElementWithZero", IsAdditiveElement );
DeclareCategoryCollections( "IsAdditiveElementWithZero" );
DeclareCategoryCollections( "IsAdditiveElementWithZeroCollection" );
DeclareCategoryCollections( "IsAdditiveElementWithZeroCollColl" );
DeclareSynonym( "IsAdditiveElementWithZeroList",
    IsAdditiveElementWithZeroCollection and IsList );
DeclareSynonym( "IsAdditiveElementWithZeroTable",
    IsAdditiveElementWithZeroCollColl   and IsTable );
InstallTrueMethod(
    IsAdditiveElementWithZero,
    IsAdditiveElementWithZeroList );
InstallTrueMethod(
    IsAdditiveElementWithZeroList,
    IsAdditiveElementWithZeroTable );


#############################################################################
##
#C  IsAdditiveElementWithInverse(<obj>)
##
DeclareCategory( "IsAdditiveElementWithInverse", IsAdditiveElementWithZero );
DeclareCategoryCollections( "IsAdditiveElementWithInverse" );
DeclareCategoryCollections( "IsAdditiveElementWithInverseCollection" );
DeclareCategoryCollections( "IsAdditiveElementWithInverseCollColl" );
DeclareSynonym( "IsAdditiveElementWithInverseList",
    IsAdditiveElementWithInverseCollection and IsList );
DeclareSynonym( "IsAdditiveElementWithInverseTable",
    IsAdditiveElementWithInverseCollColl   and IsTable );
InstallTrueMethod(
    IsAdditiveElementWithInverse,
    IsAdditiveElementWithInverseList );
InstallTrueMethod(
    IsAdditiveElementWithInverseList,
    IsAdditiveElementWithInverseTable );


#############################################################################
##
#C  IsExtLElement(<obj>)
##
DeclareCategory( "IsExtLElement", IsObject );
DeclareCategoryCollections( "IsExtLElement" );
DeclareCategoryCollections( "IsExtLElementCollection" );
DeclareSynonym( "IsExtLElementList",
    IsExtLElementCollection and IsList );
DeclareSynonym( "IsExtLElementTable",
    IsExtLElementCollColl   and IsTable );
InstallTrueMethod(
    IsExtLElement,
    IsExtLElementCollection );


#############################################################################
##
#C  IsExtRElement(<obj>)
##
DeclareCategory( "IsExtRElement", IsObject );
DeclareCategoryCollections( "IsExtRElement" );
DeclareCategoryCollections( "IsExtRElementCollection" );
DeclareSynonym( "IsExtRElementList",
    IsExtRElementCollection and IsList );
DeclareSynonym( "IsExtRElementTable",
    IsExtRElementCollColl   and IsTable );
InstallTrueMethod(
    IsExtRElement,
    IsExtRElementCollection );


#############################################################################
##
#C  IsMultiplicativeElement(<obj>)
##
DeclareCategory( "IsMultiplicativeElement",
        IsExtLElement and IsExtRElement );
DeclareCategoryCollections( "IsMultiplicativeElement" );
DeclareCategoryCollections( "IsMultiplicativeElementCollection" );
DeclareCategoryCollections( "IsMultiplicativeElementCollColl" );
DeclareSynonym( "IsMultiplicativeElementList",
    IsMultiplicativeElementCollection and IsList );
DeclareSynonym( "IsMultiplicativeElementTable",
    IsMultiplicativeElementCollColl   and IsTable );


#############################################################################
##
#C  IsMultiplicativeElementWithOne(<obj>)
##
DeclareCategory( "IsMultiplicativeElementWithOne",
        IsMultiplicativeElement );
DeclareCategoryCollections( "IsMultiplicativeElementWithOne" );
DeclareCategoryCollections( "IsMultiplicativeElementWithOneCollection" );
DeclareCategoryCollections( "IsMultiplicativeElementWithOneCollColl" );
DeclareSynonym( "IsMultiplicativeElementWithOneList",
    IsMultiplicativeElementWithOneCollection and IsList );
DeclareSynonym( "IsMultiplicativeElementWithOneTable",
    IsMultiplicativeElementWithOneCollColl   and IsTable );


#############################################################################
##
#C  IsMultiplicativeElementWithInverse(<obj>)
##
DeclareCategory( "IsMultiplicativeElementWithInverse",
        IsMultiplicativeElementWithOne );
DeclareCategoryCollections( "IsMultiplicativeElementWithInverse" );
DeclareCategoryCollections( "IsMultiplicativeElementWithInverseCollection" );
DeclareCategoryCollections( "IsMultiplicativeElementWithInverseCollColl" );
DeclareSynonym( "IsMultiplicativeElementWithInverseList",
    IsMultiplicativeElementWithInverseCollection and IsList );
DeclareSynonym( "IsMultiplicativeElementWithInverseTable",
    IsMultiplicativeElementWithInverseCollColl   and IsTable );


#############################################################################
##
#C  IsVector(<obj>)
##
##  A *vector* is an additive-element-with-inverse that can e multiplied from
##  the left and right with other objects (not necessarily of the same type).
##  Examples are cyclotomics, finite field elements,
##  and of course row vectors (see below).
##
##  Note that not all lists of ring elements are regarded as vectors, for
##  example lists of matrices are not vectors.
##  This is because although the category `IsAdditiveElementWithInverse' is
##  implied by the join of its collections category and `IsList', the family
##  of each list entry may may not imply `IsAdditiveElementWithInverse' for
##  all its elements.
##
DeclareSynonym( "IsVector",
        IsAdditiveElementWithInverse
    and IsExtLElement
    and IsExtRElement );
DeclareSynonym( "IsVectorCollection",
        IsAdditiveElementWithInverseCollection
    and IsExtLElementCollection
    and IsExtRElementCollection );
DeclareSynonym( "IsVectorCollColl",
        IsAdditiveElementWithInverseCollColl
    and IsExtLElementCollColl
    and IsExtRElementCollColl );
DeclareSynonym( "IsVectorList",
        IsAdditiveElementWithInverseList
    and IsExtLElementList
    and IsExtRElementList );
DeclareSynonym( "IsVectorTable",
        IsAdditiveElementWithInverseTable
    and IsExtLElementTable
    and IsExtRElementTable );


#############################################################################
##
#C  IsRowVector(<obj>)
##
##  Note that methods for row vectors must be installed with the requirement
##  `IsRowVector', since `IsVector' may lead to a rank of the method below
##  that of the default method for row vectors (see file `vecmat.gi').
##
##  Note that not all row vectors admit a scalar product via `\*';
##  for example, matrices are row vectors but the matrix product is defined
##  in a different way.
##  For the installation of a scalar product of row vectors, the entries of
##  the vector must be ring elements; note that the default method expects
##  the row vectors to lie in `IsRingElementList', and this category may not
##  be implied by `IsRingElement' for all entries of the row vector
##  (see the comment for `IsVector').
##
DeclareSynonym( "IsRowVector", IsVector and IsHomogeneousList );


#############################################################################
##
#C  IsRingElement(<obj>)
##
DeclareSynonym( "IsRingElement",
        IsAdditiveElementWithInverse
    and IsMultiplicativeElement );
DeclareSynonym( "IsRingElementCollection",
        IsAdditiveElementWithInverseCollection
    and IsMultiplicativeElementCollection );
DeclareSynonym( "IsRingElementCollColl",
        IsAdditiveElementWithInverseCollColl
    and IsMultiplicativeElementCollColl );
DeclareSynonym( "IsRingElementCollCollColl",
        IsAdditiveElementWithInverseCollCollColl
    and IsMultiplicativeElementCollCollColl );
DeclareSynonym( "IsRingElementList",
        IsAdditiveElementWithInverseList
    and IsMultiplicativeElementList );
DeclareSynonym( "IsRingElementTable",
        IsAdditiveElementWithInverseTable
    and IsMultiplicativeElementTable );
InstallTrueMethod(
    IsRingElement,
    IsRingElementTable );

DeclareCategoryFamily( "IsRingElement" );


#############################################################################
##
#C  IsRingElementWithOne(<obj>)
##
DeclareSynonym( "IsRingElementWithOne",
        IsAdditiveElementWithInverse
    and IsMultiplicativeElementWithOne );
DeclareSynonym( "IsRingElementWithOneCollection",
        IsAdditiveElementWithInverseCollection
    and IsMultiplicativeElementWithOneCollection );
DeclareSynonym( "IsRingElementWithOneCollColl",
        IsAdditiveElementWithInverseCollColl
    and IsMultiplicativeElementWithOneCollColl );
DeclareSynonym( "IsRingElementWithOneCollCollColl",
        IsAdditiveElementWithInverseCollCollColl
    and IsMultiplicativeElementWithOneCollCollColl );
DeclareSynonym( "IsRingElementWithOneList",
        IsAdditiveElementWithInverseList
    and IsMultiplicativeElementWithOneList );
DeclareSynonym( "IsRingElementWithOneTable",
        IsAdditiveElementWithInverseTable
    and IsMultiplicativeElementWithOneTable );
InstallTrueMethod(
    IsRingElementWithOne,
    IsRingElementWithOneTable );


#############################################################################
##
#C  IsRingElementWithInverse(<obj>)
##
DeclareSynonym( "IsRingElementWithInverse",
        IsAdditiveElementWithInverse
    and IsMultiplicativeElementWithInverse );
DeclareSynonym( "IsRingElementWithInverseCollection",
        IsAdditiveElementWithInverseCollection
    and IsMultiplicativeElementWithInverseCollection );
DeclareSynonym( "IsRingElementWithInverseCollColl",
        IsAdditiveElementWithInverseCollColl
    and IsMultiplicativeElementWithInverseCollColl );
DeclareSynonym( "IsRingElementWithInverseCollCollColl",
        IsAdditiveElementWithInverseCollCollColl
    and IsMultiplicativeElementWithInverseCollCollColl );
DeclareSynonym( "IsRingElementWithInverseList",
        IsAdditiveElementWithInverseList
    and IsMultiplicativeElementWithInverseList );
DeclareSynonym( "IsRingElementWithInverseTable",
        IsAdditiveElementWithInverseTable
    and IsMultiplicativeElementWithInverseTable );
InstallTrueMethod(
    IsRingElementWithInverse,
    IsRingElementWithInverseTable );


#############################################################################
##
#C  IsScalar(<obj>)
##
DeclareSynonym( "IsScalar",           IsRingElementWithInverse );
DeclareSynonym( "IsScalarCollection", IsRingElementWithInverseCollection );
DeclareSynonym( "IsScalarCollColl",   IsRingElementWithInverseCollColl );
DeclareSynonym( "IsScalarList",       IsRingElementWithInverseList );
DeclareSynonym( "IsScalarTable",      IsRingElementWithInverseTable );


#############################################################################
##
#C  IsMatrix(<obj>)
##
##  A *matrix* is a list of lists of equal length whose entries lie in a
##  common ring.
##
##  Note that matrices may have different multiplications,
##  besides the usual matrix product there is the Lie product.
##  So there are categories such as `IsOrdinaryMatrix' and `IsLieMatrix'
##  that describe the matrix product.
##  One can form the product of two matrices only if they support the same
##  multiplication.
##
##  In order to avoid that a matrix supports more than one multiplication,
##  appropriate immediate methods are installed (see~`arith.gi').
##
DeclareSynonym( "IsMatrix", IsRingElementTable );
DeclareCategoryCollections( "IsMatrix" );


#############################################################################
##
#C  IsOrdinaryMatrix(<obj>)
##
##  An *ordinary matrix* is a matrix whose multiplication is the ordinary
##  matrix multiplication.
##
##  Each matrix in internal representation is in the category
##  `IsOrdinaryMatrix',
##  and arithmetic operations with objects in `IsOrdinaryMatrix' produce
##  again matrices in `IsOrdinaryMatrix'.
##
##  Note that we want that Lie matrices shall be matrices that behave in the
##  same way as ordinary matrices, except that they have a different
##  multiplication.
##  So we must distinguish the different matrix multiplications,
##  in order to be able to describe the applicability of multiplication,
##  and also in order to form a matrix of the appropriate type as the
##  sum, difference etc.~of two matrices which have the same multiplication.
##
DeclareCategory( "IsOrdinaryMatrix", IsMatrix );
DeclareCategoryCollections( "IsOrdinaryMatrix" );

InstallTrueMethod( IsOrdinaryMatrix, IsMatrix and IsInternalRep );


#############################################################################
##
#C  IsLieMatrix( <mat> )
##
##  A *Lie matrix* is a matrix whose multiplication is given by the
##  Lie bracket.
##  (Note that a matrix with ordinary matrix multiplication is in the
##  category `IsOrdinaryMatrix'.)
##
##  Each matrix created by `LieObject' is in the category `IsLieMatrix',
##  and arithmetic operations with objects in `IsLieMatrix' produce
##  again matrices in `IsLieMatrix'.
##
##  (We do not claim that every object in `IsLieMatrix' is also contained in
##  `IsLieObject', since the former describes the containment in a certain
##  family and the latter describes a certain matrix multiplication;
##  probably this distinction is unnecessary.)
##
DeclareCategory( "IsLieMatrix", IsMatrix );


#############################################################################
##
#C  IsAssociativeElement(<obj>)
##                     category of elements belonging to associative families
##
DeclareCategory( "IsAssociativeElement", IsMultiplicativeElement );
DeclareCategoryCollections( "IsAssociativeElement" );
DeclareCategoryCollections( "IsAssociativeElementCollection" );


#############################################################################
##
#M  IsAssociativeElement( <mat> ) . .  for matrices that are internal objects
##
##  Matrices in internal representation and with entries in an associative
##  family are themselves associative elements.
##
InstallTrueMethod( IsAssociativeElement,
    IsMatrix and IsInternalRep and IsAssociativeElementCollColl );


#############################################################################
##
#C  IsCommutativeElement(<obj>)
##                     category of elements belonging to commutative families
##
DeclareCategory( "IsCommutativeElement", IsMultiplicativeElement );
DeclareCategoryCollections( "IsCommutativeElement" );


#############################################################################
##
#C  IsFiniteOrderElement(<obj>)
##                      category of elements with finite multiplicative order
##
DeclareCategory( "IsFiniteOrderElement",
        IsMultiplicativeElementWithInverse );
DeclareCategoryCollections( "IsFiniteOrderElement" );


#############################################################################
##
#C  IsJacobianElement(<obj>)
##            category of elements belonging to families with Jacobi identity
##
##  The Jacobi identity for a family $F$ means that
##  $x * y * z + z * x * y + y * z * x$ is equal to zero for all $x$, $y$,
##  $z$ in $F$.
##
DeclareCategory( "IsJacobianElement", IsRingElement );
DeclareCategoryCollections( "IsJacobianElement" );


#############################################################################
##
#C  IsZeroSquaredElement(<obj>)
##                    category of elements belonging to zero squared families
##
DeclareCategory( "IsZeroSquaredElement", IsRingElement );
DeclareCategoryCollections( "IsZeroSquaredElement" );


#############################################################################
##
#P  IsZero(<elm>) . . . . . . . . . . . . . . . . . . . test for zero element
##
DeclareProperty( "IsZero", IsAdditiveElementWithZero );


#############################################################################
##
#P  IsOne(<elm>)  . . . . . . . . . . . . . . . . . . .  test for one element
##
DeclareProperty( "IsOne", IsMultiplicativeElementWithOne );



#############################################################################
##
#A  Zero(<obj>) . . . . . . . .  additive neutral of an element/domain/family
##
##  'Zero'  returns the additive neutral  element of <obj>, which must either
##  be an additive element, a domain, or a family.
##
##  For an element  'Zero(<elm>)' is equivalent to  '0|*|<elm>'.  If a domain
##  or a family has a zero, then all its elements must have the same zero (so
##  a  collections family, which contains  matrices of  all dimensions cannot
##  have a zero).
##
##  'Zero' may call 'Representative', but 'Representative' is allowed to
##  fetch the zero of a domain <D> only if 'HasZero( <D>) ' is 'true'.
##
DeclareAttributeKernel( "Zero", IsAdditiveElementWithZero, ZERO );


#############################################################################
##
#o  '<elm1>+<elm2>' . . . . . . . . . . . . . . . . . . . sum of two elements
##
DeclareOperationKernel( "+", [ IsExtAElement, IsExtAElement ], SUM );


#############################################################################
##
#A  AdditiveInverse(<elm>)  . . . . . . . . .  additive inverse of an element
##
DeclareAttributeKernel( "AdditiveInverse", IsAdditiveElementWithInverse,
    AINV );


#############################################################################
##
#o  '<elm1>-<elm2>' . . . . . . . . . . . . . . .  difference of two elements
##
DeclareOperationKernel( "-", [ IsExtAElement, IsAdditiveElementWithInverse ],
    DIFF );


#############################################################################
##
#o  '<elm1>*<elm2>' . . . . . . . . . . . . . . . . . product of two elements
##
DeclareOperationKernel( "*", [ IsExtRElement, IsExtLElement ], PROD );


#############################################################################
##
#A  One(<obj>)  . . . . .  multiplicative neutral of an element/domain/family
##
##  `One' returns  the  multiplicative neutral  element of <obj>,  which must
##  either be a multiplicative element, a domain, or a family.
##
##  For an element `One(<elm>)' is equivalent to `<elm>|^|0'.
##  If a domain or a family has a one, then all its elements (even a zero if
##  the domain or family has one) must have the same one (so a collections
##  family, which contains matrices of all dimensions, cannot have a one).
##
##  The one of an object need not be distinct from its zero,
##  so a ring consisting of a single element can be regarded as a
##  ring-with-one.
##  This is especially useful in the case of finitely presented algebras,
##  where a factor of a free algebra-with-one is again an algebra-with-one,
##  no matter whether or not it is a zero algebra.
##
##  `One' may call `Representative', but `Representative' is allowed to
##  fetch the one of a domain <D> only if `HasOne( <D>)' is `true'.
##
DeclareAttributeKernel( "One", IsMultiplicativeElementWithOne, ONE );

DeclareSynonymAttr( "Identity", One );


#############################################################################
##
#A  Inverse(<elm>)  . . . . . . . . . .  multiplicative inverse of an element
##
##  `Inverse' returns the multiplicative inverse of an element <elm>,
##  that is, an element <inv> such that
##  `<elm> * <inv> = <inv> * <elm> = One( <elm> )' holds.
##
#T  Note the somewhat strange behaviour for mappings whose source and range
#T  differ!
#T  (perhaps introduce `InverseMapping'?)
##
DeclareAttributeKernel( "Inverse", IsMultiplicativeElementWithInverse,
    INV );


#############################################################################
##
#o  '<elm1>/<elm2>' . . . . . . . . . . . . . . . .  quotient of two elements
##
DeclareOperationKernel( "/",
    [ IsExtRElement, IsMultiplicativeElementWithInverse ],
    QUO );


#############################################################################
##
#O  LeftQuotient(<elm1>,<elm2>) . . . . . . . . left quotient of two elements
##
DeclareOperationKernel( "LeftQuotient",
    [ IsMultiplicativeElementWithInverse, IsExtLElement ],
    LQUO );


#############################################################################
##
#o  '<elm1>^<elm2>' . . . . . . . . .  . . . . . . . .  power of two elements
##
DeclareOperationKernel( "^",
    [ IsMultiplicativeElement, IsMultiplicativeElement ],
    POW );
#T  How is powering defined for nonassociative multiplication ??


#############################################################################
##
#O  Comm(<elm1>,<elm2>) . . . . . . . . . . . . .  commutator of two elements
##
DeclareOperationKernel( "Comm",
    [ IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    COMM );


#############################################################################
##
#O  LieBracket(<elm1>,<elm2>) . . . . . . . . . . lie bracket of two elements
##
DeclareOperation( "LieBracket", [ IsRingElement, IsRingElement ] );


#############################################################################
##
#o  '<elm1> mod <elm2>' . . . . . . . . . . . . . . . modulus of two elements
##
DeclareOperationKernel( "mod", [ IsObject, IsObject ], MOD );


#############################################################################
##
#A  Int( <elm> )  . . . . . . . . . . . . . . . . . .  integer value of <elm>
##
DeclareAttribute( "Int", IsScalar );


#############################################################################
##
#A  Rat( <elm> )  . . . . . . . . . . . . . . . . . . rational value of <elm>
##
DeclareAttribute( "Rat", IsScalar );


#############################################################################
##
#O  Root( <n>, <k> )
#O  Root( <n> )
##
DeclareOperation( "Root", [ IsMultiplicativeElement, IS_INT ] );


#############################################################################
##
#O  Log(<elm>,<base>)
##
DeclareOperation( "Log",
    [ IsMultiplicativeElement, IsMultiplicativeElement ] );


#############################################################################
##
#A  Characteristic(<obj>) . . . .  characteristic of an element/domain/family
##
##  'Characteristic' returns  the characteristic of  <obj>, which must either
##  be an additive element, a domain or a family.
##
##  If a domain or a family has a characteristic,  then all its elements must
##  have the same characteristic.
##
DeclareAttribute( "Characteristic", IsObject );


#############################################################################
##
#A  Order(<elm>)
##
DeclareAttribute( "Order", IsMultiplicativeElementWithOne );


#############################################################################
##
#A  NormedRowVector( <v> )
##
DeclareAttribute( "NormedRowVector", IsRowVector and IsScalarCollection );


#############################################################################
##

#P  IsCommutativeFamily
##
DeclareProperty( "IsCommutativeFamily", IsFamily );


#############################################################################
##
#P  IsSkewFieldFamily
##
DeclareProperty( "IsSkewFieldFamily", IsFamily );


#############################################################################
##
#P  IsUFDFamily( <family> )
##
##  the   <family>  is    at  least a    commutative  ring-with-one,  without
##  zero-divisors and  the    factorisations of elements into     elements of
##  <family> is unique (upto units and ordering)
##
DeclareProperty( "IsUFDFamily", IsFamily );


#############################################################################
##
#E  arith.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

