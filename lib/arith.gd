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
#C  IsExtAElement( <obj> )
##
##  An *external additive element* is an object that can be added via `+'
##  with other elements (not necessarily in the same family, see~"Families").
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
#C  IsNearAdditiveElement( <obj> )
##
##  A *near-additive element* is an object that can be added via `+'
##  with elements in its family (see~"Families");
##  this addition is not necessarily commutative.
##
DeclareCategory( "IsNearAdditiveElement", IsExtAElement );
DeclareCategoryCollections( "IsNearAdditiveElement" );
DeclareCategoryCollections( "IsNearAdditiveElementCollection" );
DeclareCategoryCollections( "IsNearAdditiveElementCollColl" );
DeclareSynonym( "IsNearAdditiveElementList",
    IsNearAdditiveElementCollection and IsList );
DeclareSynonym( "IsNearAdditiveElementTable",
    IsNearAdditiveElementCollColl   and IsTable );
InstallTrueMethod( IsNearAdditiveElement,
    IsNearAdditiveElementList );
InstallTrueMethod( IsNearAdditiveElementList,
    IsNearAdditiveElementTable );


#############################################################################
##
#C  IsNearAdditiveElementWithZero( <obj> )
##
##  A *near-additive element-with-zero* is an object that can be added
##  via `+' with elements in its family (see~"Families"),
##  and that is an admissible argument for the operation `Zero' (see~"Zero");
##  this addition is not necessarily commutative.
##
DeclareCategory( "IsNearAdditiveElementWithZero", IsNearAdditiveElement );
DeclareCategoryCollections( "IsNearAdditiveElementWithZero" );
DeclareCategoryCollections( "IsNearAdditiveElementWithZeroCollection" );
DeclareCategoryCollections( "IsNearAdditiveElementWithZeroCollColl" );
DeclareSynonym( "IsNearAdditiveElementWithZeroList",
    IsNearAdditiveElementWithZeroCollection and IsList );
DeclareSynonym( "IsNearAdditiveElementWithZeroTable",
    IsNearAdditiveElementWithZeroCollColl   and IsTable );
InstallTrueMethod(
    IsNearAdditiveElementWithZero,
    IsNearAdditiveElementWithZeroList );
InstallTrueMethod(
    IsNearAdditiveElementWithZeroList,
    IsNearAdditiveElementWithZeroTable );


#############################################################################
##
#C  IsNearAdditiveElementWithInverse( <obj> )
##
##  A *near-additive element-with-inverse* is an object that can be
##  added via `+' with elements in its family (see~"Families"),
##  and that is an admissible argument for the operations `Zero' (see~"Zero")
##  and `AdditiveInverse' (see~"AdditiveInverse");
##  this addition is not necessarily commutative.
##
DeclareCategory( "IsNearAdditiveElementWithInverse",
    IsNearAdditiveElementWithZero );
DeclareCategoryCollections( "IsNearAdditiveElementWithInverse" );
DeclareCategoryCollections( "IsNearAdditiveElementWithInverseCollection" );
DeclareCategoryCollections( "IsNearAdditiveElementWithInverseCollColl" );
DeclareSynonym( "IsNearAdditiveElementWithInverseList",
    IsNearAdditiveElementWithInverseCollection and IsList );
DeclareSynonym( "IsNearAdditiveElementWithInverseTable",
    IsNearAdditiveElementWithInverseCollColl   and IsTable );
InstallTrueMethod(
    IsNearAdditiveElementWithInverse,
    IsNearAdditiveElementWithInverseList );
InstallTrueMethod(
    IsNearAdditiveElementWithInverseList,
    IsNearAdditiveElementWithInverseTable );


#############################################################################
##
#C  IsAdditiveElement( <obj> )
##
##  An *additive element* is an object that can be added via `+'
##  with elements in its family (see~"Families");
##  this addition is commutative.
##
DeclareCategory( "IsAdditiveElement", IsNearAdditiveElement );
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
#C  IsAdditiveElementWithZero( <obj> )
##
##  An *additive element-with-zero* is an object that can be added
##  via `+' with elements in its family (see~"Families"),
##  and that is an admissible argument for the operation `Zero' (see~"Zero");
##  this addition is commutative.
##
DeclareSynonym( "IsAdditiveElementWithZero",
    IsNearAdditiveElementWithZero and IsAdditiveElement );
DeclareSynonym( "IsAdditiveElementWithZeroCollection",
        IsNearAdditiveElementWithZeroCollection
    and IsAdditiveElementCollection );
DeclareSynonym( "IsAdditiveElementWithZeroCollColl",
        IsNearAdditiveElementWithZeroCollColl
    and IsAdditiveElementCollColl );
DeclareSynonym( "IsAdditiveElementWithZeroCollCollColl",
        IsNearAdditiveElementWithZeroCollCollColl
    and IsAdditiveElementCollCollColl );

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
#C  IsAdditiveElementWithInverse( <obj> )
##
##  An *additive element-with-inverse* is an object that can be
##  added via `+' with elements in its family (see~"Families"),
##  and that is an admissible argument for the operations `Zero' (see~"Zero")
##  and `AdditiveInverse' (see~"AdditiveInverse");
##  this addition is commutative.
##
DeclareSynonym( "IsAdditiveElementWithInverse",
    IsNearAdditiveElementWithInverse and IsAdditiveElement );
DeclareSynonym( "IsAdditiveElementWithInverseCollection",
        IsNearAdditiveElementWithInverseCollection
    and IsAdditiveElementCollection );
DeclareSynonym( "IsAdditiveElementWithInverseCollColl",
        IsNearAdditiveElementWithInverseCollColl
    and IsAdditiveElementCollColl );
DeclareSynonym( "IsAdditiveElementWithInverseCollCollColl",
        IsNearAdditiveElementWithInverseCollCollColl
    and IsAdditiveElementCollCollColl );

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
#C  IsExtLElement( <obj> )
##
##  An *external left element* is an object that can be multiplied from the
##  left, via `\*', with other elements (not necessarily in the same family,
##  see~"Families").
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
#C  IsExtRElement( <obj> )
##
##  An *external right element* is an object that can be multiplied from the
##  right, via `\*', with other elements (not necessarily in the same family,
##  see~"Families").
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
#C  IsMultiplicativeElement( <obj> )
##
##  A *multiplicative element* is an object that can be multiplied via `\*'
##  with elements in its family (see~"Families").
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
#C  IsMultiplicativeElementWithOne( <obj> )
##
##  A *multiplicative element-with-one* is an object that can be multiplied
##  via `\*' with elements in its family (see~"Families"),
##  and that is an admissible argument for the operation `One' (see~"One").
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
#C  IsMultiplicativeElementWithInverse( <obj> )
##
##  A *multiplicative element-with-inverse* is an object that can be
##  multiplied via `\*' with elements in its family (see~"Families"),
##  and that is an admissible argument for the operations `One' (see~"One")
##  and `Inverse' (see~"Inverse"). (Note the word ``admissible'': an
##  object in this category does not necessarily have an inverse, `Inverse'
##  may return `fail'.)
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
#C  IsVector( <obj> )
##
##  A *vector* is an additive-element-with-inverse that can be multiplied
##  from the left and right with other objects (not necessarily of the same
##  type).
##  Examples are cyclotomics, finite field elements,
##  and of course row vectors (see below).
##
##  Note that not all lists of ring elements are regarded as vectors,
##  for example lists of matrices are not vectors.
##  This is because although the category `IsAdditiveElementWithInverse' is
##  implied by the join of its collections category and `IsList',
##  the family of a list entry may not imply `IsAdditiveElementWithInverse'
##  for all its elements.
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
#C  IsRowVector( <obj> )
##
##  A *row vector* is a vector (see~"IsVector") that is also a
##  homogeneous list.  Typical examples are lists of integers, lists
##  of finite field elements of the same characteristic, lists of
##  polynomials from a common polynomial ring, and matrices.
##
##  The additive operations of the vector must thus be compatible with
##  that for lists, implying that the list entries are the
##  coefficients of the vector with respect to some basis.
##
##  Note that not all row vectors admit a scalar product via `\*';
##  for example, matrices are row vectors but the matrix product is defined
##  in a different way.
##  For the installation of a scalar product of row vectors, the entries of
##  the vector must be ring elements; note that the default method expects
##  the row vectors to lie in `IsRingElementList', and this category may not
##  be implied by `IsRingElement' for all entries of the row vector
##  (see the comment for `IsVector' in~"IsVector").
##
##  Note that methods for special types of row vectors really must be
##  installed with the requirement `IsRowVector',
## since `IsVector' may lead to a rank of the method below
##  that of the default method for row vectors (see file `vecmat.gi').
##
DeclareSynonym( "IsRowVector", IsVector and IsHomogeneousList );


#############################################################################
##
##  Filters Controlling the Arithmetic Behaviour of Lists
#1
##  The arithmetic behaviour of lists is controlled by their types.
##  The following categories and attributes are used for that.
##  
##  Note that we distinguish additive and multiplicative behaviour.
##  For example, Lie matrices have the usual additive behaviour but not the
##  usual multiplicative behaviour.
##


#############################################################################
##
#C  IsGeneralizedRowVector( <list> )  . . . objects that comply with new list
##                                            addition rules
##
##  For a list <list>, the value `true' for `IsGeneralizedRowVector'
##  indicates that the additive arithmetic behaviour of <list> is
##  as defined in~"Additive Arithmetic for Lists",
##  and that the attribute `NestingDepthA' (see~"NestingDepthA")
##  will return a nonzero value when called with <list>.
##
DeclareCategory( "IsGeneralizedRowVector", IsList );


#############################################################################
##
#C  IsMultiplicativeGeneralizedRowVector( <list> )  . . . . 
##          objects that comply with new list multiplication rules
##
##  For a list <list>, the value `true' for
##  `IsMultiplicativeGeneralizedRowVector' indicates that the multiplicative
##  arithmetic behaviour of <list> is as defined
##  in~"Multiplicative Arithmetic for Lists",
##  and that the attribute `NestingDepthM' (see~"NestingDepthM")
##  will return a nonzero value when called with <list>.
##
DeclareCategory( "IsMultiplicativeGeneralizedRowVector",
    IsGeneralizedRowVector );


#############################################################################
##
#A  NestingDepthA( <obj> )
##
##  For a {\GAP} object <obj>,
##  `NestingDepthA' returns the *additive nesting depth* of <obj>.
##  This is defined recursively
##  as the integer $0$ if <obj> is not in `IsGeneralizedRowVector',
##  as the integer $1$ if <obj> is an empty list in `IsGeneralizedRowVector',
##  and as $1$ plus the additive nesting depth of the first bound entry in
##  <obj> otherwise.
##
DeclareAttribute( "NestingDepthA", IsObject );


#############################################################################
##
#A  NestingDepthM( <obj> )
##
##  For a {\GAP} object <obj>,
##  `NestingDepthM' returns the *multiplicative nesting depth* of <obj>.
##  This is defined recursively as the
##  integer $0$ if <obj> is not in `IsMultiplicativeGeneralizedRowVector',
##  as the integer $1$ if <obj> is an empty list in
##  `IsMultiplicativeGeneralizedRowVector',
##  and as $1$ plus the multiplicative nesting depth of the first bound entry
##  in <obj> otherwise.
##
DeclareAttribute( "NestingDepthM", IsObject );


#############################################################################
##
#C  IsNearRingElement( <obj> )
##
##  `IsNearRingElement' is just a synonym for the join of
##  `IsNearAdditiveElementWithInverse' and `IsMultiplicativeElement'.
##
DeclareSynonym( "IsNearRingElement",
        IsNearAdditiveElementWithInverse
    and IsMultiplicativeElement );
DeclareSynonym( "IsNearRingElementCollection",
        IsNearAdditiveElementWithInverseCollection
    and IsMultiplicativeElementCollection );
DeclareSynonym( "IsNearRingElementCollColl",
        IsNearAdditiveElementWithInverseCollColl
    and IsMultiplicativeElementCollColl );
DeclareSynonym( "IsNearRingElementCollCollColl",
        IsNearAdditiveElementWithInverseCollCollColl
    and IsMultiplicativeElementCollCollColl );
DeclareSynonym( "IsNearRingElementList",
        IsNearAdditiveElementWithInverseList
    and IsMultiplicativeElementList );
DeclareSynonym( "IsNearRingElementTable",
        IsNearAdditiveElementWithInverseTable
    and IsMultiplicativeElementTable );
InstallTrueMethod(
    IsNearRingElement,
    IsNearRingElementTable );

DeclareCategoryFamily( "IsNearRingElement" );


#############################################################################
##
#C  IsNearRingElementWithOne( <obj> )
##
##  `IsNearRingElementWithOne' is just a synonym for the join of
##  `IsNearAdditiveElementWithInverse' and `IsMultiplicativeElementWithOne'.
##
DeclareSynonym( "IsNearRingElementWithOne",
        IsNearAdditiveElementWithInverse
    and IsMultiplicativeElementWithOne );
DeclareSynonym( "IsNearRingElementWithOneCollection",
        IsNearAdditiveElementWithInverseCollection
    and IsMultiplicativeElementWithOneCollection );
DeclareSynonym( "IsNearRingElementWithOneCollColl",
        IsNearAdditiveElementWithInverseCollColl
    and IsMultiplicativeElementWithOneCollColl );
DeclareSynonym( "IsNearRingElementWithOneCollCollColl",
        IsNearAdditiveElementWithInverseCollCollColl
    and IsMultiplicativeElementWithOneCollCollColl );
DeclareSynonym( "IsNearRingElementWithOneList",
        IsNearAdditiveElementWithInverseList
    and IsMultiplicativeElementWithOneList );
DeclareSynonym( "IsNearRingElementWithOneTable",
        IsNearAdditiveElementWithInverseTable
    and IsMultiplicativeElementWithOneTable );
InstallTrueMethod(
    IsNearRingElementWithOne,
    IsNearRingElementWithOneTable );


#############################################################################
##
#C  IsNearRingElementWithInverse( <obj> )
##
DeclareSynonym( "IsNearRingElementWithInverse",
        IsNearAdditiveElementWithInverse
    and IsMultiplicativeElementWithInverse );
DeclareSynonym( "IsNearRingElementWithInverseCollection",
        IsNearAdditiveElementWithInverseCollection
    and IsMultiplicativeElementWithInverseCollection );
DeclareSynonym( "IsNearRingElementWithInverseCollColl",
        IsNearAdditiveElementWithInverseCollColl
    and IsMultiplicativeElementWithInverseCollColl );
DeclareSynonym( "IsNearRingElementWithInverseCollCollColl",
        IsNearAdditiveElementWithInverseCollCollColl
    and IsMultiplicativeElementWithInverseCollCollColl );
DeclareSynonym( "IsNearRingElementWithInverseList",
        IsNearAdditiveElementWithInverseList
    and IsMultiplicativeElementWithInverseList );
DeclareSynonym( "IsNearRingElementWithInverseTable",
        IsNearAdditiveElementWithInverseTable
    and IsMultiplicativeElementWithInverseTable );
InstallTrueMethod(
    IsNearRingElementWithInverse,
    IsNearRingElementWithInverseTable );


#############################################################################
##
#C  IsRingElement( <obj> )
##
##  `IsRingElement' is just a synonym for the join of
##  `IsAdditiveElementWithInverse' and `IsMultiplicativeElement'.
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
#C  IsRingElementWithOne( <obj> )
##
##  `IsRingElementWithOne' is just a synonym for the join of
##  `IsAdditiveElementWithInverse' and `IsMultiplicativeElementWithOne'.
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
#C  IsRingElementWithInverse( <obj> )
#C  IsScalar( <obj> )
##
##  `IsRingElementWithInverse' and `IsScalar' are just synonyms for the join
##  of
##  `IsAdditiveElementWithInverse' and `IsMultiplicativeElementWithInverse'.
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

DeclareSynonym( "IsScalar",           IsRingElementWithInverse );
DeclareSynonym( "IsScalarCollection", IsRingElementWithInverseCollection );
DeclareSynonym( "IsScalarCollColl",   IsRingElementWithInverseCollColl );
DeclareSynonym( "IsScalarList",       IsRingElementWithInverseList );
DeclareSynonym( "IsScalarTable",      IsRingElementWithInverseTable );

#############################################################################
##
#C  IsZDFRE( <obj> )
##
##  This category (``is zero divisor free ring element'') indicates elements
##  from a ring which contains no zero divisors. For matrix operations over
##  this ring, a standard Gauss algorithm can be used.
##
DeclareCategory("IsZDFRE",IsRingElementWithInverse);
DeclareCategoryCollections("IsZDFRE");
DeclareCategoryCollections("IsZDFRECollection");


#############################################################################
##
#C  IsMatrix( <obj> )
##
##  A *matrix* is a list of lists of equal length whose entries lie in a
##  common ring.
##
##  Note that matrices may have different multiplications,
##  besides the usual matrix product there is for example the Lie product.
##  So there are categories such as `IsOrdinaryMatrix' and `IsLieMatrix'
##  (see~"IsOrdinaryMatrix", "IsLieMatrix")
##  that describe the matrix multiplication.
##  One can form the product of two matrices only if they support the same
##  multiplication.
#T
#T  In order to avoid that a matrix supports more than one multiplication,
#T  appropriate immediate methods are installed (see~`arith.gi').
##
DeclareSynonym( "IsMatrix", IsRingElementTable );
DeclareCategoryCollections( "IsMatrix" );


#############################################################################
##
#C  IsOrdinaryMatrix( <obj> )
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
#T get rid of this filter!!

InstallTrueMethod( IsOrdinaryMatrix, IsMatrix and IsInternalRep );
InstallTrueMethod( IsGeneralizedRowVector, IsMatrix );
#T get rid of that hack!
InstallTrueMethod( IsMultiplicativeGeneralizedRowVector,
        IsOrdinaryMatrix );


#############################################################################
##
#C  IsLieMatrix( <mat> )
##
##  A *Lie matrix* is a matrix whose multiplication is given by the
##  Lie bracket.
##  (Note that a matrix with ordinary matrix multiplication is in the
##  category `IsOrdinaryMatrix', see~"IsOrdinaryMatrix".)
##
##  Each matrix created by `LieObject' is in the category `IsLieMatrix',
##  and arithmetic operations with objects in `IsLieMatrix' produce
##  again matrices in `IsLieMatrix'.
##
#T  (We do not claim that every object in `IsLieMatrix' is also contained in
#T  `IsLieObject', since the former describes the containment in a certain
#T  family and the latter describes a certain matrix multiplication;
#T  probably this distinction is unnecessary.)
##
DeclareCategory( "IsLieMatrix", IsGeneralizedRowVector and IsMatrix );


#############################################################################
##
#C  IsAssociativeElement( <obj> ) . . . elements belonging to assoc. families
#C  IsAssociativeElementCollection( <obj> )
#C  IsAssociativeElementCollColl( <obj> )
##
##  An element <obj> in the category `IsAssociativeElement' knows
##  that the multiplication of any elements in the family of <obj>
##  is associative.
##  For example, all permutations lie in this category, as well as those
##  ordinary matrices (see~"IsOrdinaryMatrix") whose entries are also in
##  `IsAssociativeElement'.
##
DeclareCategory( "IsAssociativeElement", IsMultiplicativeElement );
DeclareCategoryCollections( "IsAssociativeElement" );
DeclareCategoryCollections( "IsAssociativeElementCollection" );


#############################################################################
##
#M  IsAssociativeElement( <mat> ) . . . . . . . for certain ordinary matrices
##
##  Matrices with associative multiplication
##  and with entries in an associative family
##  are themselves associative elements.
##
InstallTrueMethod( IsAssociativeElement,
    IsOrdinaryMatrix and IsAssociativeElementCollColl );


#############################################################################
##
#C  IsAdditivelyCommutativeElement( <obj> )
#C  IsAdditivelyCommutativeElementCollection( <obj> )
#C  IsAdditivelyCommutativeElementCollColl( <obj> )
#C  IsAdditivelyCommutativeElementFamily( <obj> )
##
##  An element <obj> in the category `IsAdditivelyCommutativeElement' knows
##  that the addition of any elements in the family of <obj>
##  is commutative.
##  For example, each finite field element and each rational number lies in
##  this category.
##
DeclareCategory( "IsAdditivelyCommutativeElement", IsNearAdditiveElement );
DeclareCategoryCollections( "IsAdditivelyCommutativeElement" );
DeclareCategoryCollections( "IsAdditivelyCommutativeElementCollection" );

DeclareCategoryFamily( "IsAdditivelyCommutativeElement" );


#############################################################################
##
#M  IsAdditivelyCommutativeElement( <mat> ) . . . . . .  for certain matrices
##
##  Matrices with entries in an additively commutative family
##  are themselves additively commutative elements.
##
InstallTrueMethod( IsAdditivelyCommutativeElement,
    IsMatrix and IsAdditivelyCommutativeElementCollColl );


#############################################################################
##
#M  IsAdditivelyCommutativeElement( <mat> ) . . . . . for certain row vectors
##
##  Row vectors with entries in an additively commutative family
##  are themselves additively commutative elements.
##
InstallTrueMethod( IsAdditivelyCommutativeElement,
    IsRowVector and IsAdditivelyCommutativeElementCollection );


#############################################################################
##
#C  IsCommutativeElement( <obj> ) . . .  elements belonging to comm. families
#C  IsCommutativeElementCollection( <obj> )
#C  IsCommutativeElementCollColl( <obj> )
##
##  An element <obj> in the category `IsCommutativeElement' knows
##  that the multiplication of any elements in the family of <obj>
##  is commutative.
##  For example, each finite field element and each rational number lies in
##  this category.
##
DeclareCategory( "IsCommutativeElement", IsMultiplicativeElement );
DeclareCategoryCollections( "IsCommutativeElement" );
DeclareCategoryCollections( "IsCommutativeElementCollection" );


#############################################################################
##
#C  IsFiniteOrderElement( <obj> )
#C  IsFiniteOrderElementCollection( <obj> )
#C  IsFiniteOrderElementCollColl( <obj> )
##
##  An element <obj> in the category `IsFiniteOrderElement' knows
##  that it has finite multiplicative order.
##  For example, each finite field element and each permutation lies in
##  this category.
##  However the value may be `false' even if <obj> has finite order,
##  but if this was not known when <obj> was constructed.
##
##  Although it is legal to set this filter for any object with finite order,
##  this is really useful only in the case that all elements of a family are
##  known to have finite order.
##
DeclareCategory( "IsFiniteOrderElement",
    IsMultiplicativeElementWithInverse );
DeclareCategoryCollections( "IsFiniteOrderElement" );
DeclareCategoryCollections( "IsFiniteOrderElementCollection" );


#############################################################################
##
#C  IsJacobianElement( <obj> )  . elements belong. to fam. with Jacobi ident.
#C  IsJacobianElementCollection( <obj> )
#C  IsJacobianElementCollColl( <obj> )
##
##  An element <obj> in the category `IsJacobianElement' knows
##  that the multiplication of any elements in the family $F$ of <obj>
##  satisfies the Jacobi identity, that is,
##  $x \* y \* z + z \* x \* y + y \* z \* x$ is zero
##  for all $x$, $y$, $z$ in $F$.
##
##  For example, each Lie matrix (see~"IsLieMatrix") lies in this category.
##
DeclareCategory( "IsJacobianElement", IsRingElement );
DeclareCategoryCollections( "IsJacobianElement" );
DeclareCategoryCollections( "IsJacobianElementCollection" );


#############################################################################
##
#C  IsZeroSquaredElement( <obj> ) . . . elements belong. to zero squared fam.
#C  IsZeroSquaredElementCollection( <obj> )
#C  IsZeroSquaredElementCollColl( <obj> )
##
##  An element <obj> in the category `IsZeroSquaredElement' knows
##  that `<obj>^2 = Zero( <obj> )'.
##  For example, each Lie matrix (see~"IsLieMatrix") lies in this category.
##
##  Although it is legal to set this filter for any zero squared object,
##  this is really useful only in the case that all elements of a family are
##  known to have square zero.
##
DeclareCategory( "IsZeroSquaredElement", IsRingElement );
DeclareCategoryCollections( "IsZeroSquaredElement" );
DeclareCategoryCollections( "IsZeroSquaredElementCollection" );


#############################################################################
##
#P  IsZero( <elm> ) . . . . . . . . . . . . . . . . . . test for zero element
##
##  is `true' if `<elm> = Zero( <elm> )', and `false' otherwise.
##
DeclareProperty( "IsZero", IsAdditiveElementWithZero );


#############################################################################
##
#P  IsOne( <elm> )  . . . . . . . . . . . . . . . . test for identity element
##
##  is `true' if `<elm> = One( <elm> )', and `false' otherwise.
##
DeclareProperty( "IsOne", IsMultiplicativeElementWithOne );


#############################################################################
##
#A  ZeroImmutable( <obj> )  . .  additive neutral of an element/domain/family
#A  ZeroAttr( <obj> )            synonym of ZeroImmutable
#A  Zero( <obj> )                synonym of ZeroImmutable
#O  ZeroMutable( <obj> )  . . . . . .  mutable additive neutral of an element
#O  ZeroOp( <obj> )              synonym of ZeroMutable
#O  ZeroSameMutability( <obj> )  mutability preserving zero (0*<obj>)
#O  ZeroSM( <obj> )              synonym of ZeroSameMutability
##
##  `ZeroImmutable', `ZeroMutable', and `ZeroSameMutability' all
##  return the additive neutral element of the additive element <obj>.
##
##  They differ only w.r.t. the mutability of the result.
##  `ZeroImmutable' is an attribute and hence returns an immutable result.
##  `ZeroMutable' is guaranteed to return a new *mutable* object whenever
##  a mutable version of the required element exists in {\GAP}
##  (see~"IsCopyable").
##  `ZeroSameMutability' returns a result that is mutable if <obj> is mutable
##  and if a mutable version of the required element exists in {\GAP};
##  for lists, it returns a result of the same immutability level as
##  the argument. For instance, if the argument is a mutable matrix
##  with immutable rows, it returns a similar object.
##
##  `ZeroSameMutability( <obj> )' is equivalent to `0 \* <obj>'.
##
##  `ZeroAttr', `Zero', `ZeroOp' and `ZeroSM' are synonyms as listed above.
##
##  If <obj> is a domain or a family then `Zero' is defined as the zero
##  element of all elements in <obj>,
##  provided that all these elements have the same zero.
##  For example, the family of all cyclotomics has the zero element `0',
##  but a collections family (see~"CollectionsFamily") may contain
##  matrices of all dimensions and then it cannot have a unique zero element.
##  Note that `Zero' is applicable to a domain only if it is an
##  additive magma-with-zero (see~"IsAdditiveMagmaWithZero");
##  use `AdditiveNeutralElement' (see~"AdditiveNeutralElement") otherwise.
##
##  The default method of `Zero' for additive elements calls `ZeroMutable'
##  (note that methods for `ZeroMutable' must *not* delegate to `Zero');
##  so other methods to compute zero elements need to be installed only for
##  `ZeroMutable' and (in the case of copyable objects) `ZeroSameMutability'.
##
##  For domains, `Zero' may call `Representative' (see~"Representative"),
##  but `Representative' is allowed to fetch the zero of a domain <D>
##  only if `HasZero( <D> )' is `true'.
##
DeclareAttribute( "ZeroImmutable", IsAdditiveElementWithZero );
DeclareAttribute( "ZeroImmutable", IsFamily );

DeclareSynonymAttr( "ZeroAttr", ZeroImmutable );
DeclareSynonymAttr( "Zero", ZeroImmutable );

DeclareOperationKernel( "ZeroMutable", [ IsAdditiveElementWithZero ],
    ZERO_MUT );
DeclareSynonym( "ZeroOp", ZeroMutable );

DeclareOperationKernel( "ZeroSameMutability", [ IsAdditiveElementWithZero ],
    ZERO );
DeclareSynonym( "ZeroSM", ZeroSameMutability );


#############################################################################
##
#o  `<elm1>+<elm2>' . . . . . . . . . . . . . . . . . . . sum of two elements
##

#DeclareOperation( "+", [ IsExtAElement, IsExtAElement ] );
DeclareOperationKernel( "+", [ IsExtAElement, IsExtAElement ], SUM );


#############################################################################
##
#A  AdditiveInverseImmutable( <elm> )  . . . . additive inverse of an element
#A  AdditiveInverseAttr( <elm> )  . . . .      additive inverse of an element
#A  AdditiveInverse( <elm> )  . . . .          additive inverse of an element
#O  AdditiveInverseMutable( <elm> )  . mutable additive inverse of an element
#O  AdditiveInverseOp( <elm> )       . mutable additive inverse of an element
#O  AdditiveInverseSameMutability( <elm> )  .  additive inverse of an element
#O  AdditiveInverseSM( <elm> )              .  additive inverse of an element
##
##  `AdditiveInverseImmutable', `AdditiveInverseMutable', and 
##  `AdditiveInverseSameMutability' all return the
##  additive inverse of <elm>.
##
##  They differ only w.r.t. the mutability of the result.
##  `AdditiveInverseImmutable' is an attribute and hence returns an
##  immutable result.  `AdditiveInverseMutable' is guaranteed to
##  return a new *mutable* object whenever a mutable version of the
##  required element exists in {\GAP} (see~"IsCopyable").
##  `AdditiveInverseSameMutability' returns a result that is mutable
##  if <elm> is mutable and if a mutable version of the required
##  element exists in {\GAP};
##  for lists, it returns a result of the same immutability level as
##  the argument. For instance, if the argument is a mutable matrix
##  with immutable rows, it returns a similar object.
##
##  `AdditiveInverseSameMutability( <elm> )' is equivalent to `-<elm>'.
##
##  `AdditiveInverseAttr', `AdditiveInverse', `AdditiveInverseOp'
##  and `AdditiveInverseSM' are synonyms as listed above.
##
##  The default method of `AdditiveInverse' calls `AdditiveInverseMutable'
##  (note that methods for `AdditiveInverseMutable' must *not* delegate to
##  `AdditiveInverse');
##  so other methods to compute additive inverses need to be installed only
##  for `AdditiveInverseMutable' and (in the case of copyable objects)
##  `AdditiveInverseSameMutability'.
##
DeclareAttribute( "AdditiveInverseImmutable", IsAdditiveElementWithInverse );
DeclareSynonymAttr( "AdditiveInverseAttr", AdditiveInverseImmutable );
DeclareSynonymAttr( "AdditiveInverse", AdditiveInverseImmutable );

DeclareOperationKernel( "AdditiveInverseMutable",
    [ IsAdditiveElementWithInverse ], AINV_MUT);
DeclareSynonym( "AdditiveInverseOp", AdditiveInverseMutable);

DeclareOperationKernel( "AdditiveInverseSameMutability", 
    [ IsAdditiveElementWithInverse ], AINV );
DeclareSynonym( "AdditiveInverseSM", AdditiveInverseSameMutability);


#############################################################################
##
#o  `<elm1>-<elm2>' . . . . . . . . . . . . . . .  difference of two elements
##

#DeclareOperation( "-", [ IsExtAElement, IsAdditiveElementWithInverse ] );
DeclareOperationKernel( "-", 
	[ IsExtAElement, IsNearAdditiveElementWithInverse ], DIFF );


#############################################################################
##
#o  `<elm1>*<elm2>' . . . . . . . . . . . . . . . . . product of two elements
##

#DeclareOperation( "*", [ IsExtRElement, IsExtLElement ] );
DeclareOperationKernel( "*", [ IsExtRElement, IsExtLElement ], PROD );


#############################################################################
##
#A  OneImmutable( <obj> )  multiplicative neutral of an element/domain/family
#A  OneAttr( <obj> )
#A  One( <obj> )
#A  Identity( <obj> )
#O  OneMutable( <obj> )  . . . . . . . .  multiplicative neutral of an element
#O  OneOp( <obj> )  
#O  OneSameMutability( <obj> )
#O  OneSM( <obj> )
##
##  `OneImmutable', `OneMutable', and `OneSameMutability' return the
##  multiplicative neutral element of the multiplicative element <obj>.
##
##  They differ only w.r.t. the mutability of the result.
##  `OneImmutable' is an attribute and hence returns an immutable result.
##  `OneMutable' is guaranteed to return a new *mutable* object whenever
##  a mutable version of the required element exists in {\GAP}
##  (see~"IsCopyable").
##  `OneSameMutability' returns a result that is mutable if <obj> is mutable
##  and if a mutable version of the required element exists in {\GAP};
##  for lists, it returns a result of the same immutability level as
##  the argument. For instance, if the argument is a mutable matrix
##  with immutable rows, it returns a similar object.
##
##  If <obj> is a multiplicative element then `OneSameMutability( <obj> )'
##  is equivalent to `<obj>^0'.
##
##  `OneAttr', `One', `Identity', `OneOp', and `OneSM' are synonyms as listed
##  above.
##
##  If <obj> is a domain or a family then `One' is defined as the identity
##  element of all elements in <obj>, 
##  provided that all these elements have the same identity.
##  For example, the family of all cyclotomics has the identity element `1',
##  but a collections family (see~"CollectionsFamily") may contain
##  matrices of all dimensions and then it cannot have a unique identity
##  element.
##  Note that `One' is applicable to a domain only if it is a
##  magma-with-one (see~"IsMagmaWithOne");
##  use `MultiplicativeNeutralElement' (see~"MultiplicativeNeutralElement")
##  otherwise.
##
##  The identity of an object need not be distinct from its zero,
##  so for example a ring consisting of a single element can be regarded as a
##  ring-with-one (see~"Rings").
##  This is particularly useful in the case of finitely presented algebras,
##  where any factor of a free algebra-with-one is again an algebra-with-one,
##  no matter whether or not it is a zero algebra.
##
##  The default method of `One' for multiplicative elements calls
##  `OneMutable' (note that methods for `OneMutable' must *not* delegate to
##  `One');
##  so other methods to compute identity elements need to be installed only
##  for `OneOp' and (in the case of copyable objects) `OneSameMutability'.
##
##  For domains, `One' may call `Representative' (see~"Representative"),
##  but `Representative' is allowed to fetch the identity of a domain <D>
##  only if `HasOne( <D> )' is `true'.
##
DeclareAttribute( "OneImmutable", IsMultiplicativeElementWithOne );
DeclareAttribute( "OneImmutable", IsFamily );

DeclareSynonymAttr( "OneAttr", OneImmutable );
DeclareSynonymAttr( "One", OneImmutable );
DeclareSynonymAttr( "Identity", OneImmutable );

DeclareOperationKernel( "OneMutable", [ IsMultiplicativeElementWithOne ],
    ONE );
DeclareSynonym( "OneOp", OneMutable);

DeclareOperationKernel( "OneSameMutability",
    [ IsMultiplicativeElementWithOne ], ONE_MUT );
DeclareSynonym( "OneSM", OneSameMutability);


#############################################################################
##
#A  InverseImmutable( <elm> )   . . . .  multiplicative inverse of an element
#A  InverseAttr( <elm> )
#A  Inverse( <elm> )
#O  InverseMutable( <elm> )
#O  InverseOp( <elm> )
#O  InverseSameMutability( <elm> )  . .  multiplicative inverse of an element
#O  InverseSM( <elm> )
##
##  `InverseImmutable', `InverseMutable', and `InverseSameMutability'
##  all return the multiplicative inverse of an element <elm>,
##  that is, an element <inv> such that
##  `<elm> * <inv> = <inv> * <elm> = One( <elm> )' holds;
##  if <elm> is not invertible then `fail' (see~"Fail") is returned.
##
##  Note that the above definition implies that a (general) mapping
##  is invertible in the sense of `Inverse' only if its source equals its
##  range (see~"Technical Matters Concerning General Mappings").
##  For a bijective mapping $f$ whose source and range differ,
##  `InverseGeneralMapping' (see~"InverseGeneralMapping") can be used
##  to construct a mapping $g$ with the property
##  that $f `*' g$ is the identity mapping on the source of $f$
##  and $g `*' f$ is the identity mapping on the range of $f$.
##
##  The operations differ only w.r.t. the mutability of the result.
##  `InverseImmutable' is an attribute and hence returns an immutable result.
##  `InverseMutable' is guaranteed to return a new *mutable* object whenever
##  a mutable version of the required element exists in {\GAP}.
##  `InverseSameMutability' returns a result that is mutable if <elm> is
##  mutable and if a mutable version of the required element exists in
##  {\GAP}; for lists, it returns a result of the same immutability level as
##  the argument. For instance, if the argument is a mutable matrix
##  with immutable rows, it returns a similar object.
##
##  `InverseSameMutability( <elm> )' is equivalent to `<elm>^-1'.
##
##  `InverseAttr', `Inverse', `InverseOp' and `InverseSM' are synonyms as
##  listed above.
##
##  The default method of `Inverse' calls `InverseMutable' (note that methods
##  for `InverseMutable' must *not* delegate to `Inverse');
##  other methods to compute inverses need to be installed only for
##  `InverseMutable' and (in the case of copyable objects)
##  `InverseSameMutability'.
##
DeclareAttribute( "InverseImmutable", IsMultiplicativeElementWithInverse );
DeclareSynonymAttr( "InverseAttr", InverseImmutable );
DeclareSynonymAttr( "Inverse", InverseImmutable );

DeclareOperationKernel( "InverseMutable",
    [ IsMultiplicativeElementWithInverse ], INV );
DeclareSynonym( "InverseOp", InverseMutable );

DeclareOperationKernel( "InverseSameMutability",
    [ IsMultiplicativeElementWithInverse ], INV_MUT );
DeclareSynonym( "InverseSM", InverseSameMutability );


#############################################################################
##
#o  `<elm1>/<elm2>' . . . . . . . . . . . . . . . .  quotient of two elements
##

#DeclareOperation( "/",
#    [ IsExtRElement, IsMultiplicativeElementWithInverse ] );
DeclareOperationKernel( "/",
    [ IsExtRElement, IsMultiplicativeElementWithInverse ],
    QUO );


#############################################################################
##
#O  LeftQuotient( <elm1>, <elm2> )  . . . . . . left quotient of two elements
##
##  returns the product `<elm1>^(-1) \* <elm2>'.
##  For some types of objects (for example permutations) this product can be
##  evaluated more efficiently than by first inverting <elm1>
##  and then forming the product with <elm2>.
##

#DeclareOperation( "LeftQuotient",
#    [ IsMultiplicativeElementWithInverse, IsExtLElement ] );
DeclareOperationKernel( "LeftQuotient",
    [ IsMultiplicativeElementWithInverse, IsExtLElement ],
    LQUO );


#############################################################################
##
#o  `<elm1>^<elm2>' . . . . . . . . .  . . . . . . . .  power of two elements
##

#DeclareOperation( "^",
#    [ IsMultiplicativeElement, IsMultiplicativeElement ] );
DeclareOperationKernel( "^",
    [ IsMultiplicativeElement, IsMultiplicativeElement ],
    POW );
#T  How is powering defined for nonassociative multiplication ??


#############################################################################
##
#O  Comm( <elm1>, <elm2> )  . . . . . . . . . . .  commutator of two elements
##
##  returns the *commutator* of <elm1> and <elm2>. The commutator is defined
##  as the product $<elm1>^{-1} \* <elm2>^{-1} \* <elm1> \* <elm2>$.
##

#DeclareOperation( "Comm",
#    [ IsMultiplicativeElementWithInverse,
#      IsMultiplicativeElementWithInverse ] );
DeclareOperationKernel( "Comm",
    [ IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    COMM );


#############################################################################
##
#O  LieBracket( <elm1>, <elm2> )  . . . . . . . . Lie bracket of two elements
##
##  returns the element `<elm1> \* <elm2> - <elm2> \* <elm1>'.
##
DeclareOperation( "LieBracket", [ IsRingElement, IsRingElement ] );


#############################################################################
##
#o  `<elm1> mod <elm2>' . . . . . . . . . . . . . . . modulus of two elements
##

#DeclareOperation( "mod", [ IsObject, IsObject ] );
DeclareOperationKernel( "mod", [ IsObject, IsObject ], MOD );


#############################################################################
##
#A  Int( <elm> )  . . . . . . . . . . . . . . . . . .  integer value of <elm>
##
##  `Int' returns an integer <int> whose meaning depends on the type
##  of <elm>.
##
##  If <elm> is a rational number (see~"Rational Numbers") then <int> is the
##  integer part of the quotient of numerator and denominator of <elm>
##  (see~"QuoInt").
##
##  If <elm> is an element of a finite prime field
##  (see Chapter~"Finite Fields") then <int> is the smallest
##  nonnegative integer such that `<elm> = <int> \* One( <elm> )'.
##
##  If <elm> is a string (see Chapter~"Strings and Characters") consisting of
##  digits `{'0'}', `{'1'}', $\ldots$, `{'9'}'
##  and `{'-'}' (at the first position) then <int> is the integer
##  described by this string.
##  The operation `String' (see~"String") can be used to compute a string for
##  rational integers, in fact for all cyclotomics.
##
##  \beginexample
##  gap> Int( 4/3 );  Int( -2/3 );
##  1
##  0
##  gap> int:= Int( Z(5) );  int * One( Z(5) );
##  2
##  Z(5)
##  gap> Int( "12345" );  Int( "-27" );  Int( "-27/3" );
##  12345
##  -27
##  fail
##  \endexample
##
DeclareAttribute( "Int", IsObject );


#############################################################################
##
#A  Rat( <elm> )  . . . . . . . . . . . . . . . . . . rational value of <elm>
##
##  `Rat' returns a rational number <rat> whose meaning depends on the type
##  of <elm>.
##
##  If <elm> is a string consisting of digits `{'0'}', `{'1'}', $\ldots$,
##  `{'9'}' and `{'-'}' (at the first position), `{'/'}' and the decimal dot
##  `{'.'}' then <rat> is the rational described by this string.
##  The operation `String' (see~"String") can be used to compute a string for
##  rational numbers, in fact for all cyclotomics.
##
##  \beginexample
##  gap> Rat( "1/2" );  Rat( "35/14" );  Rat( "35/-27" );  Rat( "3.14159" );
##  1/2
##  5/2
##  -35/27
##  314159/100000
##  \endexample
##
DeclareAttribute( "Rat", IsObject );


#############################################################################
##
#O  Sqrt( <obj> )
##
##  `Sqrt' returns a square root of <obj>, that is, an object $x$ with the
##  property that $x \cdot x = <obj>$ holds.
##  If such an $x$ is not unique then the choice of $x$ depends on the type
##  of <obj>.
##  For example, `ER' (see~"ER") is the `Sqrt' method for rationals
##  (see~"IsRat").
##
DeclareOperation( "Sqrt", [ IsMultiplicativeElement ] );


#############################################################################
##
#O  Root( <n>, <k> )
#O  Root( <n> )
##
DeclareOperation( "Root", [ IsMultiplicativeElement, IS_INT ] );


#############################################################################
##
#O  Log( <elm>, <base> )
##
DeclareOperation( "Log",
    [ IsMultiplicativeElement, IsMultiplicativeElement ] );


#############################################################################
##
#A  Characteristic( <obj> ) . . .  characteristic of an element/domain/family
##
##  `Characteristic' returns the *characteristic* of <obj>,
##  where <obj> must either be an additive element, a domain or a family.
##
##  For a domain <D>, the characteristic is defined if <D> is closed under
##  addition and has a zero element `<z> = Zero( <D> )' (see~"Zero");
##  in this case, `Characteristic( <D> )' is the smallest positive integer
##  <p> such that `<p> * <x> = <z>' for all elements <x> in <D>,
##  if such an integer exists, and the integer zero `0' otherwise.
##
##  If a family has a characteristic then this means
##  that all domains of elements in this family have this characteristic.
##  In this case, also each element in the family has this characteristic.
##  (Note that also the zero element $z$ of a finite field in characteristic
##  $p$ has characteristic $p$, although $n \* z = z$ for any integer $n$.)
##  
DeclareAttribute( "Characteristic", IsObject );


#############################################################################
##
#A  Order( <elm> )
##
##  is the multiplicative order of <elm>.
##  This is the smallest positive integer <n> such that
##  `<elm>^<n> = One( <elm> )' if such an integer exists. If the order is
##  infinite, `Order' may return the value `infinity', but it also might run
##  into an infinite loop trying to test the order.
##
DeclareAttribute( "Order", IsMultiplicativeElementWithOne );


#############################################################################
##
#A  NormedRowVector( <v> )
##
##  returns a scalar multiple `<w> = <c> \* <v>' of the row vector <v>
##  with the property that the first nonzero entry of <w> is an identity
##  element in the sense of `IsOne'.
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
##  the family <family> is at least a commutative ring-with-one,
##  without zero divisors, and the factorisation of each element into
##  elements of <family> is unique (up to units and ordering).
##
DeclareProperty( "IsUFDFamily", IsFamily );


#############################################################################
##
#R  IsAdditiveElementAsMultiplicativeElementRep( <obj> )
##
DeclareRepresentation("IsAdditiveElementAsMultiplicativeElementRep",
  IsPositionalObjectRep and IsMultiplicativeElement,[]);


#############################################################################
##
#A  AdditiveElementsAsMultiplicativeElementsFamily( <fam> )
##
DeclareAttribute("AdditiveElementsAsMultiplicativeElementsFamily", IsFamily);


#############################################################################
##
#A  AdditiveElementAsMultiplicativeElement( <obj> )
##
##  for an additive element <obj>, this attribute returns a *multiplicative*
##  element, for which multiplication is done via addition of the original
##  element. The original element of such a ``wrapped'' multiplicative
##  element can be obtained as the `UnderlyingElement'.
##
DeclareAttribute("AdditiveElementAsMultiplicativeElement",
  IsAdditiveElement );


#############################################################################
##
#O  UnderlyingElement( <elm> )
##
##  Let <elm> be an object which builds on elements of another domain and
##  just wraps these up to provide another arithmetic.
##
DeclareOperation( "UnderlyingElement", [ IsObject ] );


#############################################################################
##
#P  IsIdempotent( <elt> )
##
##  true iff <elt> is its own square. 
##  (Even if IsZero(<elt>) is also true.)
##
DeclareProperty("IsIdempotent", IsMultiplicativeElement);


#############################################################################
##
#E

