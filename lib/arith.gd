#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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
##  mean that the product of *any* two elements in the family is defined,
##


#############################################################################
##
#C  IsExtAElement( <obj> )
##
##  <#GAPDoc Label="IsExtAElement">
##  <ManSection>
##  <Filt Name="IsExtAElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  An <E>external additive element</E> is an object that can be added via
##  <C>+</C> with other elements
##  (not necessarily in the same family, see&nbsp;<Ref Sect="Families"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsNearAdditiveElement">
##  <ManSection>
##  <Filt Name="IsNearAdditiveElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>near-additive element</E> is an object that can be added via
##  <C>+</C> with elements in its family (see&nbsp;<Ref Sect="Families"/>);
##  this addition is not necessarily commutative.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsNearAdditiveElementWithZero">
##  <ManSection>
##  <Filt Name="IsNearAdditiveElementWithZero" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>near-additive element-with-zero</E> is an object that can be added
##  via <C>+</C> with elements in its family
##  (see&nbsp;<Ref Sect="Families"/>),
##  and that is an admissible argument for the operation <Ref Attr="Zero"/>;
##  this addition is not necessarily commutative.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsNearAdditiveElementWithInverse">
##  <ManSection>
##  <Filt Name="IsNearAdditiveElementWithInverse" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>near-additive element-with-inverse</E> is an object that can be
##  added via <C>+</C> with elements in its family
##  (see&nbsp;<Ref Sect="Families"/>),
##  and that is an admissible argument for the operations <Ref Attr="Zero"/>
##  and <Ref Attr="AdditiveInverse"/>;
##  this addition is not necessarily commutative.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsAdditiveElement">
##  <ManSection>
##  <Filt Name="IsAdditiveElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  An <E>additive element</E> is an object that can be added via <C>+</C>
##  with elements in its family (see&nbsp;<Ref Sect="Families"/>);
##  this addition is commutative.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsAdditiveElementWithZero">
##  <ManSection>
##  <Filt Name="IsAdditiveElementWithZero" Arg='obj' Type='Category'/>
##
##  <Description>
##  An <E>additive element-with-zero</E> is an object that can be added
##  via <C>+</C> with elements in its family
##  (see&nbsp;<Ref Sect="Families"/>),
##  and that is an admissible argument for the operation <Ref Attr="Zero"/>;
##  this addition is commutative.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsAdditiveElementWithInverse">
##  <ManSection>
##  <Filt Name="IsAdditiveElementWithInverse" Arg='obj' Type='Category'/>
##
##  <Description>
##  An <E>additive element-with-inverse</E> is an object that can be
##  added via <C>+</C> with elements in its family
##  (see&nbsp;<Ref Sect="Families"/>),
##  and that is an admissible argument for the operations <Ref Attr="Zero"/>
##  and <Ref Attr="AdditiveInverse"/>;
##  this addition is commutative.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsExtLElement">
##  <ManSection>
##  <Filt Name="IsExtLElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  An <E>external left element</E> is an object that can be multiplied
##  from the left, via <C>*</C>, with other elements
##  (not necessarily in the same family, see&nbsp;<Ref Sect="Families"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsExtRElement">
##  <ManSection>
##  <Filt Name="IsExtRElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  An <E>external right element</E> is an object that can be multiplied
##  from the right, via <C>*</C>, with other elements
##  (not necessarily in the same family, see&nbsp;<Ref Sect="Families"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsMultiplicativeElement">
##  <ManSection>
##  <Filt Name="IsMultiplicativeElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>multiplicative element</E> is an object that can be multiplied via
##  <C>*</C> with elements in its family (see&nbsp;<Ref Sect="Families"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsMultiplicativeElementWithOne">
##  <ManSection>
##  <Filt Name="IsMultiplicativeElementWithOne" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>multiplicative element-with-one</E> is an object that can be
##  multiplied via <C>*</C> with elements in its family
##  (see&nbsp;<Ref Sect="Families"/>),
##  and that is an admissible argument for the operation <Ref Attr="One"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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

##  <#GAPDoc Label="IsMultiplicativeElementWithZero">
##  <ManSection>
##  <Filt Name="IsMultiplicativeElementWithZero" Arg='elt' Type='Category'/>
##  <Returns><K>true</K> or <K>false</K>.</Returns>
##  <Description>
##  This is the category of elements in a family which can be the operands of
##  <C>*</C> (multiplication) and the operation
##  <Ref Oper="MultiplicativeZeroOp"/>.
##  <Example><![CDATA[
##  gap> S:=Semigroup(Transformation( [ 1, 1, 1 ] ));;
##  gap> M:=MagmaWithZeroAdjoined(S);
##  <<commutative transformation semigroup of degree 3 with 1 generator>
##    with 0 adjoined>
##  gap> x:=Representative(M);
##  <semigroup with 0 adjoined elt: Transformation( [ 1, 1, 1 ] )>
##  gap> IsMultiplicativeElementWithZero(x);
##  true
##  gap> MultiplicativeZeroOp(x);
##  <semigroup with 0 adjoined elt: 0>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

DeclareCategory("IsMultiplicativeElementWithZero",IsMultiplicativeElement);
DeclareCategoryCollections("IsMultiplicativeElementWithZero");

#############################################################################
##
#C  IsMultiplicativeElementWithInverse( <obj> )
##
##  <#GAPDoc Label="IsMultiplicativeElementWithInverse">
##  <ManSection>
##  <Filt Name="IsMultiplicativeElementWithInverse" Arg='obj'
##   Type='Category'/>
##
##  <Description>
##  A <E>multiplicative element-with-inverse</E> is an object that can be
##  multiplied via <C>*</C> with elements in its family
##  (see&nbsp;<Ref Sect="Families"/>),
##  and that is an admissible argument for the operations <Ref Attr="One"/>
##  and <Ref Attr="Inverse"/>. (Note the word <Q>admissible</Q>: an
##  object in this category does not necessarily have an inverse,
##  <Ref Attr="Inverse"/> may return <K>fail</K>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsVector">
##  <ManSection>
##  <Filt Name="IsVector" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>vector</E> is an additive-element-with-inverse that can be
##  multiplied from the left and right with other objects
##  (not necessarily of the same type).
##  Examples are cyclotomics, finite field elements,
##  and of course row vectors (see below).
##  <P/>
##  Note that not all lists of ring elements are regarded as vectors,
##  for example lists of matrices are not vectors.
##  This is because although the category
##  <Ref Filt="IsAdditiveElementWithInverse"/> is
##  implied by the meet of its collections category and <Ref Filt="IsList"/>,
##  the family of a list entry may not imply
##  <Ref Filt="IsAdditiveElementWithInverse"/> for all its elements.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
#F  IsOddAdditiveNestingDepthFamily( <Fam> )
#F  IsOddAdditiveNestingDepthObject( <Fam> )
##
##  <ManSection>
##  <Filt Name="IsOddAdditiveNestingDepthFamily" Arg='Fam'/>
##  <Filt Name="IsOddAdditiveNestingDepthObject" Arg='Fam'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareFilter( "IsOddAdditiveNestingDepthFamily" );
DeclareFilter( "IsOddAdditiveNestingDepthObject" );


#############################################################################
##
#C  IsRowVector( <obj> )
##
##  <#GAPDoc Label="IsRowVector">
##  <ManSection>
##  <Filt Name="IsRowVector" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>row vector</E> is a vector (see&nbsp;<Ref Filt="IsVector"/>)
##  that is also a homogeneous list of odd additive nesting depth
##  (see&nbsp;<Ref Sect="Filters Controlling the Arithmetic Behaviour of Lists"/>).
##  Typical examples are lists of integers and rationals,
##  lists of finite field elements of the same characteristic,
##  and lists of polynomials from a common polynomial ring.
##  Note that matrices are <E>not</E> regarded as row vectors, because they have
##  even additive nesting depth.
##  <P/>
##  The additive operations of the vector must thus be compatible with
##  that for lists, implying that the list entries are the
##  coefficients of the vector with respect to some basis.
##  <P/>
##  Note that not all row vectors admit a multiplication via <C>*</C>
##  (which is to be understood as a scalar product);
##  for example, class functions are row vectors but the product of two
##  class functions is defined in a different way.
##  For the installation of a scalar product of row vectors, the entries of
##  the vector must be ring elements; note that the default method expects
##  the row vectors to lie in <C>IsRingElementList</C>,
##  and this category may not be implied by <Ref Filt="IsRingElement"/>
##  for all entries of the row vector
##  (see the comment in <Ref Filt="IsVector"/>).
##  <P/>
##  Note that methods for special types of row vectors really must be
##  installed with the requirement <Ref Filt="IsRowVector"/>,
##  since <Ref Filt="IsVector"/> may lead to a rank of the method below
##  that of the default method for row vectors (see file <F>lib/vecmat.gi</F>).
##  <P/>
##  <Example><![CDATA[
##  gap> IsRowVector([1,2,3]);
##  true
##  ]]></Example>
##  <P/>
##  Because row vectors are just a special case of lists, all operations
##  and functions for lists are applicable to row vectors as well (see
##  Chapter&nbsp;<Ref Chap="Lists"/>).
##  This especially includes accessing elements of a row vector
##  (see <Ref Sect="List Elements"/>), changing elements of a mutable row
##  vector (see <Ref Sect="List Assignment"/>),
##  and comparing row vectors (see <Ref Sect="Comparisons of Lists"/>).
##  <P/>
##  Note that, unless your algorithms specifically require you to be able
##  to change entries of your vectors, it is generally better and faster
##  to work with immutable row vectors.
##  See Section&nbsp;<Ref Sect="Mutability and Copyability"/> for more
##  details.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsRowVector",
    IsVector and IsHomogeneousList and IsOddAdditiveNestingDepthObject );


#############################################################################
##
##  Filters Controlling the Arithmetic Behaviour of Lists
##  <#GAPDoc Label="[1]{arith}">
##  The arithmetic behaviour of lists is controlled by their types.
##  The following categories and attributes are used for that.
##  <P/>
##  Note that we distinguish additive and multiplicative behaviour.
##  For example, Lie matrices have the usual additive behaviour but not the
##  usual multiplicative behaviour.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsGeneralizedRowVector( <list> )  . . . objects that comply with new list
##                                            addition rules
##
##  <#GAPDoc Label="IsGeneralizedRowVector">
##  <ManSection>
##  <Filt Name="IsGeneralizedRowVector" Arg='list' Type='Category'/>
##
##  <Description>
##  For a list <A>list</A>, the value <K>true</K> for
##  <Ref Filt="IsGeneralizedRowVector"/>
##  indicates that the additive arithmetic behaviour of <A>list</A> is
##  as defined in <Ref Sect="Additive Arithmetic for Lists"/>,
##  and that the attribute <Ref Attr="NestingDepthA"/>
##  will return a nonzero value when called with <A>list</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> IsList( "abc" ); IsGeneralizedRowVector( "abc" );
##  true
##  false
##  gap> liemat:= LieObject( [ [ 1, 2 ], [ 3, 4 ] ] );
##  LieObject( [ [ 1, 2 ], [ 3, 4 ] ] )
##  gap> IsGeneralizedRowVector( liemat );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsGeneralizedRowVector",
    IsList and IsAdditiveElementWithInverse );


#############################################################################
##
#C  IsMultiplicativeGeneralizedRowVector( <list> )  . . . .
##          objects that comply with new list multiplication rules
##
##  <#GAPDoc Label="IsMultiplicativeGeneralizedRowVector">
##  <ManSection>
##  <Filt Name="IsMultiplicativeGeneralizedRowVector" Arg='list'
##   Type='Category'/>
##
##  <Description>
##  For a list <A>list</A>, the value <K>true</K> for
##  <Ref Filt="IsMultiplicativeGeneralizedRowVector"/> indicates that the
##  multiplicative arithmetic behaviour of <A>list</A> is as defined
##  in <Ref Sect="Multiplicative Arithmetic for Lists"/>,
##  and that the attribute <Ref Attr="NestingDepthM"/>
##  will return a nonzero value when called with <A>list</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> IsMultiplicativeGeneralizedRowVector( liemat );
##  false
##  gap> bas:= CanonicalBasis( FullRowSpace( Rationals, 3 ) );
##  CanonicalBasis( ( Rationals^3 ) )
##  gap> IsMultiplicativeGeneralizedRowVector( bas );
##  true
##  ]]></Example>
##  <P/>
##  Note that the filters <Ref Filt="IsGeneralizedRowVector"/>,
##  <Ref Filt="IsMultiplicativeGeneralizedRowVector"/>
##  do <E>not</E> enable default methods for addition or multiplication
##  (cf.&nbsp;<Ref Filt="IsListDefault"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsMultiplicativeGeneralizedRowVector",
    IsGeneralizedRowVector );


#############################################################################
##
#A  NestingDepthA( <obj> )
##
##  <#GAPDoc Label="NestingDepthA">
##  <ManSection>
##  <Attr Name="NestingDepthA" Arg='obj'/>
##
##  <Description>
##  For a &GAP; object <A>obj</A>,
##  <Ref Attr="NestingDepthA"/> returns the <E>additive nesting depth</E>
##  of <A>obj</A>.
##  This is defined recursively
##  as the integer <M>0</M> if <A>obj</A> is not in
##  <Ref Filt="IsGeneralizedRowVector"/>,
##  as the integer <M>1</M> if <A>obj</A> is an empty list in
##  <Ref Filt="IsGeneralizedRowVector"/>,
##  and as <M>1</M> plus the additive nesting depth of the first bound entry
##  in <A>obj</A> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NestingDepthA", IsObject );


#############################################################################
##
#A  NestingDepthM( <obj> )
##
##  <#GAPDoc Label="NestingDepthM">
##  <ManSection>
##  <Attr Name="NestingDepthM" Arg='obj'/>
##
##  <Description>
##  For a &GAP; object <A>obj</A>,
##  <Ref Attr="NestingDepthM"/> returns the
##  <E>multiplicative nesting depth</E> of <A>obj</A>.
##  This is defined recursively as the
##  integer <M>0</M> if <A>obj</A> is not in
##  <Ref Filt="IsMultiplicativeGeneralizedRowVector"/>,
##  as the integer <M>1</M> if <A>obj</A> is an empty list in
##  <Ref Filt="IsMultiplicativeGeneralizedRowVector"/>,
##  and as <M>1</M> plus the multiplicative nesting depth of the first bound
##  entry in <A>obj</A> otherwise.
##  <Example><![CDATA[
##  gap> NestingDepthA( v );  NestingDepthM( v );
##  1
##  1
##  gap> NestingDepthA( m );  NestingDepthM( m );
##  2
##  2
##  gap> NestingDepthA( liemat );  NestingDepthM( liemat );
##  2
##  0
##  gap> l1:= [ [ 1, 2 ], 3 ];;  l2:= [ 1, [ 2, 3 ] ];;
##  gap> NestingDepthA( l1 );  NestingDepthM( l1 );
##  2
##  2
##  gap> NestingDepthA( l2 );  NestingDepthM( l2 );
##  1
##  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NestingDepthM", IsObject );


#############################################################################
##
#C  IsNearRingElement( <obj> )
##
##  <#GAPDoc Label="IsNearRingElement">
##  <ManSection>
##  <Filt Name="IsNearRingElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsNearRingElement"/> is just a synonym for the meet of
##  <Ref Filt="IsNearAdditiveElementWithInverse"/> and
##  <Ref Filt="IsMultiplicativeElement"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsNearRingElementWithOne">
##  <ManSection>
##  <Filt Name="IsNearRingElementWithOne" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsNearRingElementWithOne"/> is just a synonym for the meet of
##  <Ref Filt="IsNearAdditiveElementWithInverse"/> and
##  <Ref Filt="IsMultiplicativeElementWithOne"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsNearRingElementWithInverse">
##  <ManSection>
##  <Filt Name="IsNearRingElementWithInverse" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsNearRingElementWithInverse"/> is just a synonym for the meet of
##  <Ref Filt="IsNearAdditiveElementWithInverse"/> and
##  <Ref Filt="IsMultiplicativeElementWithInverse"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsRingElement">
##  <ManSection>
##  <Filt Name="IsRingElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsRingElement"/> is just a synonym for the meet of
##  <Ref Filt="IsAdditiveElementWithInverse"/> and
##  <Ref Filt="IsMultiplicativeElement"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsRingElementWithOne">
##  <ManSection>
##  <Filt Name="IsRingElementWithOne" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsRingElementWithOne"/> is just a synonym for the meet of
##  <Ref Filt="IsAdditiveElementWithInverse"/> and
##  <Ref Filt="IsMultiplicativeElementWithOne"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsRingElementWithInverse">
##  <ManSection>
##  <Filt Name="IsRingElementWithInverse" Arg='obj' Type='Category'/>
##  <Filt Name="IsScalar" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsRingElementWithInverse"/> and <Ref Filt="IsScalar"/>
##  are just synonyms for the meet of
##  <Ref Filt="IsAdditiveElementWithInverse"/> and
##  <Ref Filt="IsMultiplicativeElementWithInverse"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <ManSection>
##  <Filt Name="IsZDFRE" Arg='obj' Type='Category'/>
##
##  <Description>
##  This category (<Q>is zero divisor free ring element</Q>) indicates elements
##  from a ring which contains no zero divisors. For matrix operations over
##  this ring, a standard Gauss algorithm can be used.
##  </Description>
##  </ManSection>
##
DeclareCategory("IsZDFRE",IsRingElementWithInverse);
DeclareCategoryCollections("IsZDFRE");
DeclareCategoryCollections("IsZDFRECollection");


#############################################################################
##
#C  IsMatrix( <obj> )
##
##  <#GAPDoc Label="IsMatrix">
##  <ManSection>
##  <Filt Name="IsMatrix" Arg='obj' Type='Category'/>
##
##  <Description>
##  By convention <E>matrix</E> is a list of lists of equal length whose
##  entries lie in a common ring.
##  <P/>
##  For technical reasons laid out at the top of Chapter <Ref Chap="Matrices"/>,
##  the filter <Ref Filt="IsMatrix"/> is a synonym for a table of ring elements,
##  (see <Ref Filt="IsTable"/> and <Ref Filt="IsRingElement"/>). This means that
##  <Ref Filt="IsMatrix"/> returns <K>true</K> for tables such as
##  <C>[[1,2],[3]]</C>.
##  If necessary, <Ref Prop="IsRectangularTable"/> can be used to test whether
##  an object is a list of homogeneous lists of equal lengths manually.
##  <P/>
##  Note that matrices may have different multiplications,
##  besides the usual matrix product there is for example the Lie product.
##  So there are categories such as
##  <Ref Filt="IsOrdinaryMatrix"/> and <Ref Filt="IsLieMatrix"/>
##  that describe the matrix multiplication.
##  One can form the product of two matrices only if they support the same
##  multiplication.
##  <P/>
##  <Example><![CDATA[
##  gap> mat:=[[1,2,3],[4,5,6],[7,8,9]];
##  [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 7, 8, 9 ] ]
##  gap> IsMatrix(mat);
##  true
##  gap> mat:=[[1,2],[3]];
##  [ [ 1, 2 ], [ 3 ] ]
##  gap> IsMatrix(mat);
##  true
##  gap> IsRectangularTable(mat);
##  false
##  ]]></Example>
##  <P/>
##  Note that the empty list <C>[]</C> and more complex
##  <Q>empty</Q> structures such as <C>[[]]</C> are <E>not</E> matrices,
##  although special methods allow them be used in place of matrices in some
##  situations. See <Ref Func="EmptyMatrix"/> below.
##  <P/>
##  <Example><![CDATA[
##  gap> [[0]]*[[]];
##  [ [  ] ]
##  gap> IsMatrix([[]]);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
#T
#T  In order to avoid that a matrix supports more than one multiplication,
#T  appropriate immediate methods are installed (see~arith.gi).
##
DeclareSynonym( "IsMatrix", IsRingElementTable );
DeclareCategoryCollections( "IsMatrix" );


#############################################################################
##
#C  IsOrdinaryMatrix( <obj> )
##
##  <#GAPDoc Label="IsOrdinaryMatrix">
##  <ManSection>
##  <Filt Name="IsOrdinaryMatrix" Arg='obj' Type='Category'/>
##
##  <Description>
##  An <E>ordinary matrix</E> is a matrix whose multiplication is the ordinary
##  matrix multiplication.
##  <P/>
##  Each matrix in internal representation is in the category
##  <Ref Filt="IsOrdinaryMatrix"/>,
##  and arithmetic operations with objects in <Ref Filt="IsOrdinaryMatrix"/>
##  produce again matrices in <Ref Filt="IsOrdinaryMatrix"/>.
##  <P/>
##  Note that we want that Lie matrices shall be matrices that behave in the
##  same way as ordinary matrices, except that they have a different
##  multiplication.
##  So we must distinguish the different matrix multiplications,
##  in order to be able to describe the applicability of multiplication,
##  and also in order to form a matrix of the appropriate type as the
##  sum, difference etc.&nbsp;of two matrices
##  which have the same multiplication.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsLieMatrix">
##  <ManSection>
##  <Filt Name="IsLieMatrix" Arg='mat' Type='Category'/>
##
##  <Description>
##  A <E>Lie matrix</E> is a matrix whose multiplication is given by the
##  Lie bracket.
##  (Note that a matrix with ordinary matrix multiplication is in the
##  category <Ref Filt="IsOrdinaryMatrix"/>.)
##  <P/>
##  Each matrix created by <Ref Attr="LieObject"/> is in the category
##  <Ref Filt="IsLieMatrix"/>,
##  and arithmetic operations with objects in <Ref Filt="IsLieMatrix"/>
##  produce again matrices in <Ref Filt="IsLieMatrix"/>.
##  <!--  We do not claim that every object in <Ref Func="IsLieMatrix"/>
##        is also contained in <Ref Func="IsLieObject"/>,
##        since the former describes the containment in a certain
##        family and the latter describes a certain matrix multiplication;
##        probably this distinction is unnecessary.  -->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsLieMatrix", IsGeneralizedRowVector and IsMatrix );


#############################################################################
##
#C  IsAssociativeElement( <obj> ) . . . elements belonging to assoc. families
#C  IsAssociativeElementCollection( <obj> )
#C  IsAssociativeElementCollColl( <obj> )
##
##  <#GAPDoc Label="IsAssociativeElement">
##  <ManSection>
##  <Filt Name="IsAssociativeElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsAssociativeElementCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsAssociativeElementCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  An element <A>obj</A> in the category <Ref Filt="IsAssociativeElement"/>
##  knows that the multiplication of any elements in the family of <A>obj</A>
##  is associative.
##  For example, all permutations lie in this category, as well as those
##  ordinary matrices (see&nbsp;<Ref Filt="IsOrdinaryMatrix"/>)
##  whose entries are also in <Ref Filt="IsAssociativeElement"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsAdditivelyCommutativeElement">
##  <ManSection>
##  <Filt Name="IsAdditivelyCommutativeElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsAdditivelyCommutativeElementCollection" Arg='obj'
##   Type='Category'/>
##  <Filt Name="IsAdditivelyCommutativeElementCollColl" Arg='obj'
##   Type='Category'/>
##  <Filt Name="IsAdditivelyCommutativeElementFamily" Arg='obj'
##   Type='Category'/>
##
##  <Description>
##  An element <A>obj</A> in the category
##  <Ref Filt="IsAdditivelyCommutativeElement"/> knows
##  that the addition of any elements in the family of <A>obj</A>
##  is commutative.
##  For example, each finite field element and each rational number lies in
##  this category.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsAdditivelyCommutativeElement", IsAdditiveElement );
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
##  <#GAPDoc Label="IsCommutativeElement">
##  <ManSection>
##  <Filt Name="IsCommutativeElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsCommutativeElementCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsCommutativeElementCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  An element <A>obj</A> in the category <Ref Filt="IsCommutativeElement"/>
##  knows that the multiplication of any elements in the family of <A>obj</A>
##  is commutative.
##  For example, each finite field element and each rational number lies in
##  this category.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsFiniteOrderElement">
##  <ManSection>
##  <Filt Name="IsFiniteOrderElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsFiniteOrderElementCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsFiniteOrderElementCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  An element <A>obj</A> in the category <Ref Filt="IsFiniteOrderElement"/>
##  knows that it has finite multiplicative order.
##  For example, each finite field element and each permutation lies in
##  this category.
##  However the value may be <K>false</K> even if <A>obj</A> has finite
##  order, but if this was not known when <A>obj</A> was constructed.
##  <P/>
##  Although it is legal to set this filter for any object with finite order,
##  this is really useful only in the case that all elements of a family are
##  known to have finite order.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsJacobianElement">
##  <ManSection>
##  <Filt Name="IsJacobianElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsJacobianElementCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsJacobianElementCollColl" Arg='obj' Type='Category'/>
##  <Filt Name="IsRestrictedJacobianElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsRestrictedJacobianElementCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsRestrictedJacobianElementCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  An element <A>obj</A> in the category <Ref Filt="IsJacobianElement"/>
##  knows that the multiplication of any elements in the family <M>F</M>
##  of <A>obj</A> satisfies the Jacobi identity, that is,
##  <M>x * y * z + z * x * y + y * z * x</M> is zero
##  for all <M>x</M>, <M>y</M>, <M>z</M> in <M>F</M>.
##  <P/>
##  For example, each Lie matrix (see&nbsp;<Ref Filt="IsLieMatrix"/>)
##  lies in this category.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsJacobianElement", IsRingElement );
DeclareCategoryCollections( "IsJacobianElement" );
DeclareCategoryCollections( "IsJacobianElementCollection" );

DeclareCategory( "IsRestrictedJacobianElement", IsJacobianElement );
DeclareCategoryCollections( "IsRestrictedJacobianElement" );
DeclareCategoryCollections( "IsRestrictedJacobianElementCollection" );

#############################################################################
##
#C  IsZeroSquaredElement( <obj> ) . . . elements belong. to zero squared fam.
#C  IsZeroSquaredElementCollection( <obj> )
#C  IsZeroSquaredElementCollColl( <obj> )
##
##  <#GAPDoc Label="IsZeroSquaredElement">
##  <ManSection>
##  <Filt Name="IsZeroSquaredElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsZeroSquaredElementCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsZeroSquaredElementCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  An element <A>obj</A> in the category <Ref Filt="IsZeroSquaredElement"/>
##  knows that <C><A>obj</A>^2 = Zero( <A>obj</A> )</C>.
##  For example, each Lie matrix (see&nbsp;<Ref Filt="IsLieMatrix"/>)
##  lies in this category.
##  <P/>
##  Although it is legal to set this filter for any zero squared object,
##  this is really useful only in the case that all elements of a family are
##  known to have square zero.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsZeroSquaredElement", IsRingElement );
DeclareCategoryCollections( "IsZeroSquaredElement" );
DeclareCategoryCollections( "IsZeroSquaredElementCollection" );


#############################################################################
##
#P  IsZero( <elm> ) . . . . . . . . . . . . . . . . . . test for zero element
##
##  <#GAPDoc Label="IsZero">
##  <ManSection>
##  <Prop Name="IsZero" Arg='elm'/>
##
##  <Description>
##  is <K>true</K> if <C><A>elm</A> = Zero( <A>elm</A> )</C>,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsZero", IsAdditiveElementWithZero );


#############################################################################
##
#P  IsOne( <elm> )  . . . . . . . . . . . . . . . . test for identity element
##
##  <#GAPDoc Label="IsOne">
##  <ManSection>
##  <Prop Name="IsOne" Arg='elm'/>
##
##  <Description>
##  is <K>true</K> if <C><A>elm</A> = One( <A>elm</A> )</C>,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsOne", IsMultiplicativeElementWithOne );


#############################################################################
##
#A  ZeroImmutable( <obj> )  . .  additive neutral of an element/domain/family
#A  Zero( <obj> )                synonym of ZeroImmutable
#O  ZeroMutable( <obj> )  . . . . . .  mutable additive neutral of an element
#O  ZeroOp( <obj> )              synonym of ZeroMutable
#O  ZeroSameMutability( <obj> )  mutability preserving zero (0*<obj>)
##
##  <#GAPDoc Label="ZeroImmutable">
##  <ManSection>
##  <Attr Name="ZeroImmutable" Arg='obj'/>
##  <Attr Name="Zero" Arg='obj'/>
##  <Oper Name="ZeroMutable" Arg='obj'/>
##  <Oper Name="ZeroOp" Arg='obj'/>
##  <Oper Name="ZeroSameMutability" Arg='obj'/>
##
##  <Description>
##  <Ref Attr="ZeroImmutable"/>, <Ref Oper="ZeroMutable"/>,
##  and <Ref Oper="ZeroSameMutability"/> all
##  return the additive neutral element of the additive element <A>obj</A>.
##  <P/>
##  They differ only w.r.t. the mutability of the result.
##  <Ref Attr="ZeroImmutable"/> is an attribute and hence returns an
##  immutable result.
##  <Ref Oper="ZeroMutable"/> is guaranteed to return a new <E>mutable</E>
##  object whenever a mutable version of the required element exists in &GAP;
##  (see&nbsp;<Ref Filt="IsCopyable"/>).
##  <Ref Oper="ZeroSameMutability"/> returns a result that is mutable if
##  <A>obj</A> is mutable and if a mutable version of the required element
##  exists in &GAP;;
##  for lists, it returns a result of the same immutability level as
##  the argument. For instance, if the argument is a mutable matrix
##  with immutable rows, it returns a similar object.
##  <P/>
##  <C>ZeroSameMutability( <A>obj</A> )</C> is equivalent to
##  <C>0 * <A>obj</A></C>.
##  <P/>
##  <Ref Attr="Zero"/> is a synonym of <Ref Attr="ZeroImmutable"/>.
##  <Ref Oper="ZeroOp"/> is a synonym of <Ref Oper="ZeroMutable"/>.
##  <P/>
##  If <A>obj</A> is a domain or a family then <Ref Attr="Zero"/> is defined
##  as the zero element of all elements in <A>obj</A>,
##  provided that all these elements have the same zero.
##  For example, the family of all cyclotomics has the zero element <C>0</C>,
##  but a collections family (see&nbsp;<Ref Attr="CollectionsFamily"/>) may
##  contain matrices of all dimensions and then it cannot have a unique
##  zero element.
##  Note that <Ref Attr="Zero"/> is applicable to a domain only if it is an
##  additive magma-with-zero
##  (see&nbsp;<Ref Filt="IsAdditiveMagmaWithZero"/>);
##  use <Ref Attr="AdditiveNeutralElement"/> otherwise.
##  <P/>
##  The default method of <Ref Attr="Zero"/> for additive elements calls
##  <Ref Oper="ZeroMutable"/>
##  (note that methods for <Ref Oper="ZeroMutable"/> must <E>not</E> delegate
##  to <Ref Attr="Zero"/>);
##  so other methods to compute zero elements need to be installed only for
##  <Ref Oper="ZeroMutable"/> and (in the case of copyable objects)
##  <Ref Oper="ZeroSameMutability"/>.
##  <P/>
##  For domains, <Ref Attr="Zero"/> may call <Ref Attr="Representative"/>,
##  but <Ref Attr="Representative"/> is allowed to fetch the zero of a domain
##  <A>D</A> only if <C>HasZero( <A>D</A> )</C> is <K>true</K>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ZeroImmutable", IsAdditiveElementWithZero );
DeclareAttribute( "ZeroImmutable", IsFamily );

DeclareSynonymAttr( "Zero", ZeroImmutable );

DeclareOperationKernel( "ZeroMutable", [ IsAdditiveElementWithZero ],
    ZERO_MUT );
DeclareSynonym( "ZeroOp", ZeroMutable );

DeclareOperationKernel( "ZeroSameMutability", [ IsAdditiveElementWithZero ],
    ZERO_SAMEMUT );


#############################################################################
##
#O  `<elm1>+<elm2>' . . . . . . . . . . . . . . . . . . . sum of two elements
##
DeclareOperationKernel( "+", [ IsExtAElement, IsExtAElement ], SUM );


#############################################################################
##
#A  AdditiveInverseImmutable( <elm> )  . . . . additive inverse of an element
#A  AdditiveInverse( <elm> )  . . . .          additive inverse of an element
#O  AdditiveInverseMutable( <elm> )  . mutable additive inverse of an element
#O  AdditiveInverseOp( <elm> )       . mutable additive inverse of an element
#O  AdditiveInverseSameMutability( <elm> )  .  additive inverse of an element
##
##  <#GAPDoc Label="AdditiveInverseImmutable">
##  <ManSection>
##  <Attr Name="AdditiveInverseImmutable" Arg='elm'/>
##  <Attr Name="AdditiveInverse" Arg='elm'/>
##  <Oper Name="AdditiveInverseMutable" Arg='elm'/>
##  <Oper Name="AdditiveInverseOp" Arg='elm'/>
##  <Oper Name="AdditiveInverseSameMutability" Arg='elm'/>
##
##  <Description>
##  <Ref Attr="AdditiveInverseImmutable"/>,
##  <Ref Oper="AdditiveInverseMutable"/>, and
##  <Ref Oper="AdditiveInverseSameMutability"/> all return the
##  additive inverse of <A>elm</A>.
##  <P/>
##  They differ only w.r.t. the mutability of the result.
##  <Ref Attr="AdditiveInverseImmutable"/> is an attribute and hence returns
##  an immutable result.
##  <Ref Oper="AdditiveInverseMutable"/> is guaranteed to return a new
##  <E>mutable</E> object whenever a mutable version of the required element
##  exists in &GAP; (see&nbsp;<Ref Filt="IsCopyable"/>).
##  <Ref Oper="AdditiveInverseSameMutability"/> returns a result that is
##  mutable if <A>elm</A> is mutable and if a mutable version of the required
##  element exists in &GAP;;
##  for lists, it returns a result of the same immutability level as
##  the argument. For instance, if the argument is a mutable matrix
##  with immutable rows, it returns a similar object.
##  <P/>
##  <C>AdditiveInverseSameMutability( <A>elm</A> )</C> is equivalent to
##  <C>-<A>elm</A></C>.
##  <P/>
##  <Ref Attr="AdditiveInverse"/> is a synonym of
##  <Ref Attr="AdditiveInverseImmutable"/>.
##  <Ref Oper="AdditiveInverseOp"/> is a synonym of
##  <Ref Oper="AdditiveInverseMutable"/>.
##  <P/>
##  The default method of <Ref Attr="AdditiveInverse"/> calls
##  <Ref Oper="AdditiveInverseMutable"/>
##  (note that methods for <Ref Oper="AdditiveInverseMutable"/>
##  must <E>not</E> delegate to <Ref Attr="AdditiveInverse"/>);
##  so other methods to compute additive inverses need to be installed only
##  for <Ref Oper="AdditiveInverseMutable"/> and (in the case of copyable
##  objects) <Ref Oper="AdditiveInverseSameMutability"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AdditiveInverseImmutable", IsAdditiveElementWithInverse );
DeclareSynonymAttr( "AdditiveInverse", AdditiveInverseImmutable );

DeclareOperationKernel( "AdditiveInverseMutable",
    [ IsAdditiveElementWithInverse ], AINV_MUT);
DeclareSynonym( "AdditiveInverseOp", AdditiveInverseMutable);

DeclareOperationKernel( "AdditiveInverseSameMutability",
    [ IsAdditiveElementWithInverse ], AINV_SAMEMUT );


#############################################################################
##
#O  `<elm1>-<elm2>' . . . . . . . . . . . . . . .  difference of two elements
##
DeclareOperationKernel( "-",
        [ IsExtAElement, IsNearAdditiveElementWithInverse ], DIFF );


#############################################################################
##
#O  `<elm1>*<elm2>' . . . . . . . . . . . . . . . . . product of two elements
##
DeclareOperationKernel( "*", [ IsExtRElement, IsExtLElement ], PROD );


#############################################################################
##
#A  OneImmutable( <obj> )  multiplicative neutral of an element/domain/family
#A  One( <obj> )
#A  Identity( <obj> )
#O  OneMutable( <obj> )  . . . . . . . .  multiplicative neutral of an element
#O  OneOp( <obj> )
#O  OneSameMutability( <obj> )
##
##  <#GAPDoc Label="OneImmutable">
##  <ManSection>
##  <Attr Name="OneImmutable" Arg='obj'/>
##  <Attr Name="One" Arg='obj'/>
##  <Attr Name="Identity" Arg='obj'/>
##  <Oper Name="OneMutable" Arg='obj'/>
##  <Oper Name="OneOp" Arg='obj'/>
##  <Oper Name="OneSameMutability" Arg='obj'/>
##
##  <Description>
##  <Ref Attr="OneImmutable"/>, <Ref Oper="OneMutable"/>,
##  and <Ref Oper="OneSameMutability"/> return the multiplicative neutral
##  element of the multiplicative element <A>obj</A>.
##  <P/>
##  They differ only w.r.t. the mutability of the result.
##  <Ref Attr="OneImmutable"/> is an attribute and hence returns an immutable
##  result.
##  <Ref Oper="OneMutable"/> is guaranteed to return a new <E>mutable</E>
##  object whenever a mutable version of the required element exists in &GAP;
##  (see&nbsp;<Ref Filt="IsCopyable"/>).
##  <Ref Oper="OneSameMutability"/> returns a result that is mutable if
##  <A>obj</A> is mutable
##  and if a mutable version of the required element exists in &GAP;;
##  for lists, it returns a result of the same immutability level as
##  the argument. For instance, if the argument is a mutable matrix
##  with immutable rows, it returns a similar object.
##  <P/>
##  If <A>obj</A> is a multiplicative element then
##  <C>OneSameMutability( <A>obj</A> )</C>
##  is equivalent to <C><A>obj</A>^0</C>.
##  <P/>
##  <Ref Attr="One"/> and <Ref Attr="Identity"/> are
##  synonyms of <C>OneImmutable</C>.
##  <Ref Oper="OneOp"/> is a synonym of <Ref Oper="OneMutable"/>.
##  <P/>
##  If <A>obj</A> is a domain or a family then <Ref Attr="One"/> is defined
##  as the identity element of all elements in <A>obj</A>,
##  provided that all these elements have the same identity.
##  For example, the family of all cyclotomics has the identity element
##  <C>1</C>,
##  but a collections family (see&nbsp;<Ref Attr="CollectionsFamily"/>)
##  may contain matrices of all dimensions and then it cannot have a unique
##  identity element.
##  Note that <Ref Attr="One"/> is applicable to a domain only if it is a
##  magma-with-one (see&nbsp;<Ref Filt="IsMagmaWithOne"/>);
##  use <Ref Attr="MultiplicativeNeutralElement"/> otherwise.
##  <P/>
##  The identity of an object need not be distinct from its zero,
##  so for example a ring consisting of a single element can be regarded as a
##  ring-with-one (see&nbsp;<Ref Chap="Rings"/>).
##  This is particularly useful in the case of finitely presented algebras,
##  where any factor of a free algebra-with-one is again an algebra-with-one,
##  no matter whether or not it is a zero algebra.
##  <P/>
##  The default method of <Ref Attr="One"/> for multiplicative elements calls
##  <Ref Oper="OneMutable"/> (note that methods for <Ref Oper="OneMutable"/>
##  must <E>not</E> delegate to <Ref Attr="One"/>);
##  so other methods to compute identity elements need to be installed only
##  for <Ref Oper="OneOp"/> and (in the case of copyable objects)
##  <Ref Oper="OneSameMutability"/>.
##  <P/>
##  For domains, <Ref Attr="One"/> may call <Ref Attr="Representative"/>,
##  but <Ref Attr="Representative"/> is allowed to fetch the identity of a
##  domain <A>D</A> only if <C>HasOne( <A>D</A> )</C> is <K>true</K>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "OneImmutable", IsMultiplicativeElementWithOne );
DeclareAttribute( "OneImmutable", IsFamily );

DeclareSynonymAttr( "One", OneImmutable );
DeclareSynonymAttr( "Identity", OneImmutable );

DeclareOperationKernel( "OneMutable", [ IsMultiplicativeElementWithOne ],
    ONE );
DeclareSynonym( "OneOp", OneMutable);

DeclareOperationKernel( "OneSameMutability",
    [ IsMultiplicativeElementWithOne ], ONE_SAMEMUT );


#############################################################################
##
#A  InverseImmutable( <elm> )   . . . .  multiplicative inverse of an element
#A  Inverse( <elm> )
#O  InverseMutable( <elm> )
#O  InverseOp( <elm> )
#O  InverseSameMutability( <elm> )  . .  multiplicative inverse of an element
##
##  <#GAPDoc Label="InverseImmutable">
##  <ManSection>
##  <Attr Name="InverseImmutable" Arg='elm'/>
##  <Attr Name="Inverse" Arg='elm'/>
##  <Oper Name="InverseMutable" Arg='elm'/>
##  <Oper Name="InverseOp" Arg='elm'/>
##  <Oper Name="InverseSameMutability" Arg='elm'/>
##
##  <Description>
##  <Ref Attr="InverseImmutable"/>, <Ref Oper="InverseMutable"/>, and
##  <Ref Oper="InverseSameMutability"/>
##  all return the multiplicative inverse of an element <A>elm</A>,
##  that is, an element <A>inv</A> such that
##  <C><A>elm</A> * <A>inv</A> = <A>inv</A> * <A>elm</A>
##   = One( <A>elm</A> )</C> holds;
##  if <A>elm</A> is not invertible then <K>fail</K>
##  (see&nbsp;<Ref Sect="Fail"/>) is returned.
##  <P/>
##  Note that the above definition implies that a (general) mapping
##  is invertible in the sense of <Ref Attr="Inverse"/> only if its source
##  equals its range
##  (see&nbsp;<Ref Sect="Technical Matters Concerning General Mappings"/>).
##  For a bijective mapping <M>f</M> whose source and range differ,
##  <Ref Attr="InverseGeneralMapping"/> can be used
##  to construct a mapping <M>g</M> with the property
##  that <M>f</M> <C>*</C> <M>g</M> is the identity mapping on the source of
##  <M>f</M> and <M>g</M> <C>*</C> <M>f</M> is the identity mapping on the
##  range of <M>f</M>.
##  <P/>
##  The operations differ only w.r.t. the mutability of the result.
##  <Ref Attr="InverseImmutable"/> is an attribute and hence returns an
##  immutable result.
##  <Ref Oper="InverseMutable"/> is guaranteed to return a new <E>mutable</E>
##  object whenever a mutable version of the required element exists in &GAP;.
##  <Ref Oper="InverseSameMutability"/> returns a result that is mutable if
##  <A>elm</A> is mutable and if a mutable version of the required element
##  exists in &GAP;;
##  for lists, it returns a result of the same immutability level as
##  the argument. For instance, if the argument is a mutable matrix
##  with immutable rows, it returns a similar object.
##  <P/>
##  <C>InverseSameMutability( <A>elm</A> )</C> is equivalent to
##  <C><A>elm</A>^-1</C>.
##  <P/>
##  <Ref Attr="Inverse"/> is a synonym of <Ref Attr="InverseImmutable"/>.
##  <Ref Oper="InverseOp"/> is a synonym of <Ref Oper="InverseMutable"/>.
##  <P/>
##  The default method of <Ref Attr="InverseImmutable"/> calls
##  <Ref Oper="InverseMutable"/> (note that methods
##  for <Ref Oper="InverseMutable"/> must <E>not</E> delegate to
##  <Ref Attr="InverseImmutable"/>);
##  other methods to compute inverses need to be installed only for
##  <Ref Oper="InverseMutable"/> and (in the case of copyable objects)
##  <Ref Oper="InverseSameMutability"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InverseImmutable", IsMultiplicativeElementWithInverse );
DeclareSynonymAttr( "Inverse", InverseImmutable );

DeclareOperationKernel( "InverseMutable",
    [ IsMultiplicativeElementWithInverse ], INV );
DeclareSynonym( "InverseOp", InverseMutable );

DeclareOperationKernel( "InverseSameMutability",
    [ IsMultiplicativeElementWithInverse ], INV_SAMEMUT );


#############################################################################
##
#O  `<elm1>/<elm2>' . . . . . . . . . . . . . . . .  quotient of two elements
##
DeclareOperationKernel( "/",
    [ IsExtRElement, IsMultiplicativeElementWithInverse ],
    QUO );


#############################################################################
##
#O  LeftQuotient( <elm1>, <elm2> )  . . . . . . left quotient of two elements
##
##  <#GAPDoc Label="LeftQuotient">
##  <ManSection>
##  <Oper Name="LeftQuotient" Arg='elm1, elm2'/>
##
##  <Description>
##  returns the product <C><A>elm1</A>^(-1) * <A>elm2</A></C>.
##  For some types of objects (for example permutations) this product can be
##  evaluated more efficiently than by first inverting <A>elm1</A>
##  and then forming the product with <A>elm2</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "LeftQuotient",
    [ IsMultiplicativeElementWithInverse, IsExtLElement ],
    LQUO );


#############################################################################
##
#O  `<elm1>^<elm2>' . . . . . . . . .  . . . . . . . .  power of two elements
##
DeclareOperationKernel( "^",
    [ IsMultiplicativeElement, IsMultiplicativeElement ],
    POW );
#T  How is powering defined for nonassociative multiplication ??


#############################################################################
##
#O  Comm( <elm1>, <elm2> )  . . . . . . . . . . .  commutator of two elements
##
##  <#GAPDoc Label="Comm">
##  <ManSection>
##  <Oper Name="Comm" Arg='elm1, elm2'/>
##
##  <Description>
##  returns the <E>commutator</E> of <A>elm1</A> and <A>elm2</A>.
##  The commutator is defined as the product
##  <M><A>elm1</A>^{{-1}} * <A>elm2</A>^{{-1}} * <A>elm1</A> * <A>elm2</A></M>.
##  <P/>
##  <Example><![CDATA[
##  gap> a:= (1,3)(4,6);; b:= (1,6,5,4,3,2);;
##  gap> Comm( a, b );
##  (1,5,3)(2,6,4)
##  gap> LeftQuotient( a, b );
##  (1,2)(3,6)(4,5)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "Comm",
    [ IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    COMM );


#############################################################################
##
#O  LieBracket( <elm1>, <elm2> )  . . . . . . . . Lie bracket of two elements
##
##  <#GAPDoc Label="LieBracket">
##  <ManSection>
##  <Oper Name="LieBracket" Arg='elm1, elm2'/>
##
##  <Description>
##  returns the element
##  <C><A>elm1</A> * <A>elm2</A> - <A>elm2</A> * <A>elm1</A></C>.
##  <P/>
##  The addition <Ref Oper="\+"/> is assumed to be associative
##  but <E>not</E> assumed to be commutative
##  (see&nbsp;<Ref Prop="IsAdditivelyCommutative"/>).
##  The multiplication <Ref Oper="\*"/> is <E>not</E> assumed to be
##  commutative or associative
##  (see&nbsp;<Ref Prop="IsCommutative"/>, <Ref Prop="IsAssociative"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LieBracket", [ IsRingElement, IsRingElement ] );


#############################################################################
##
#O  `<elm1> mod <elm2>' . . . . . . . . . . . . . . . modulus of two elements
##
DeclareOperationKernel( "mod", [ IsObject, IsObject ], MOD );


#############################################################################
##
#A  Int( <elm> )  . . . . . . . . . . . . . . . . . .  integer value of <elm>
##
##  <#GAPDoc Label="Int">
##  <ManSection>
##  <Attr Name="Int" Arg='elm'/>
##
##  <Description>
##  <Ref Attr="Int"/> returns an integer <C>int</C> whose meaning depends
##  on the type of <A>elm</A>. For example:
##  <P/>
##  If <A>elm</A> is a rational number
##  (see Chapter&nbsp;<Ref Chap="Rational Numbers"/>) then <C>int</C> is the
##  integer part of the quotient of numerator and denominator of <A>elm</A>
##  (see&nbsp;<Ref Func="QuoInt"/>).
##  <P/>
##  If <A>elm</A> is an element of a finite prime field
##  (see Chapter&nbsp;<Ref Chap="Finite Fields"/>) then <C>int</C> is the
##  smallest nonnegative integer such that
##  <C><A>elm</A> = int * One( <A>elm</A> )</C>.
##  <P/>
##  If <A>elm</A> is a string
##  (see Chapter&nbsp;<Ref Chap="Strings and Characters"/>) consisting entirely
##  of decimal digits <C>'0'</C>, <C>'1'</C>, <M>\ldots</M>, <C>'9'</C>,
##  and optionally a sign <C>'-'</C> (at the first position), then <C>int</C> is the integer
##  described by this string. For all other strings, <C>fail</C> is returned.
##  See <Ref Attr="Int" Label="for strings"/>.
##  <P/>
##  The operation <Ref Attr="String"/> can be used to compute a string for
##  rational integers, in fact for all cyclotomics.
##  <P/>
##  <Example><![CDATA[
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
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Int", IsObject );


#############################################################################
##
#A  Rat( <elm> )  . . . . . . . . . . . . . . . . . . rational value of <elm>
##
##  <#GAPDoc Label="Rat">
##  <ManSection>
##  <Attr Name="Rat" Arg='elm'/>
##
##  <Description>
##  <Ref Attr="Rat"/> returns a rational number <A>rat</A> whose meaning
##  depends on the type of <A>elm</A>.
##  <P/>
##  If <A>elm</A> is a string consisting of digits <C>'0'</C>, <C>'1'</C>,
##  <M>\ldots</M>, <C>'9'</C> and <C>'-'</C> (at the first position),
##  <C>'/'</C> and the decimal dot <C>'.'</C> then <A>rat</A> is the rational
##  described by this string.
##  If <A>elm</A> is a rational number, then <C>Rat</C> returns <A>elm</A>.
##  The operation <Ref Attr="String"/> can be used to compute a string for
##  rational numbers, in fact for all cyclotomics.
##  <P/>
##  <Example><![CDATA[
##  gap> Rat( "1/2" );  Rat( "35/14" );  Rat( "35/-27" );  Rat( "3.14159" );
##  1/2
##  5/2
##  -35/27
##  314159/100000
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Rat", IsObject );


#############################################################################
##
#O  Sqrt( <obj> )
##
##  <#GAPDoc Label="Sqrt">
##  <ManSection>
##  <Oper Name="Sqrt" Arg='obj'/>
##
##  <Description>
##  <Ref Oper="Sqrt"/> returns a square root of <A>obj</A>, that is,
##  an object <M>x</M> with the property that <M>x \cdot x = <A>obj</A></M>
##  holds.
##  If such an <M>x</M> is not unique then the choice of <M>x</M> depends
##  on the type of <A>obj</A>.
##  For example, <Ref Func="ER"/> is the <Ref Oper="Sqrt"/> method for
##  rationals (see&nbsp;<Ref Filt="IsRat"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Sqrt", [ IsMultiplicativeElement ] );


#############################################################################
##
#O  Root( <n>, <k> )
#O  Root( <n> )
##
##  <ManSection>
##  <Oper Name="Root" Arg='n, k'/>
##  <Oper Name="Root" Arg='n'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "Root", [ IsMultiplicativeElement, IS_INT ] );


#############################################################################
##
#O  Log( <elm>, <base> )
##
##  <ManSection>
##  <Oper Name="Log" Arg='elm, base'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "Log",
    [ IsMultiplicativeElement, IsMultiplicativeElement ] );


#############################################################################
##
#A  Characteristic( <obj> ) . . .  characteristic of an element/domain/family
##
##  <#GAPDoc Label="Characteristic">
##  <ManSection>
##  <Attr Name="Characteristic" Arg='obj'/>
##
##  <Description>
##  <Ref Attr="Characteristic"/> returns the <E>characteristic</E> of
##  <A>obj</A>.
##  <P/>
##  If <A>obj</A> is a family, all of whose elements lie in
##  <Ref Filt="IsAdditiveElementWithZero"/> then its characteristic
##  is the least positive integer <M>n</M>, if any, such that
##  <C>IsZero(n*x)</C> is <K>true</K> for all <C>x</C> in the
##  family <A>obj</A>, otherwise it is <M>0</M>.
##  <P/>
##  If <A>obj</A> is a collections family of a family <M>g</M> which
##  has a characteristic, then the characteristic of <A>obj</A> is
##  the same as the characteristic of <M>g</M>.
##  <P/>
##  For other families <A>obj</A> the characteristic is not defined
##  and <K>fail</K> will be returned.
##  <P/>
##  For any object <A>obj</A> which is in the filter
##  <Ref Filt="IsAdditiveElementWithZero"/> or in the filter
##  <Ref Filt="IsAdditiveMagmaWithZero"/> the characteristic of
##  <A>obj</A> is the same as the characteristic of its family
##  if that is defined and undefined otherwise.
##  <P/>
##  For all other objects <A>obj</A> the characteristic is undefined
##  and may return <K>fail</K> or a <Q>no method found</Q> error.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Characteristic", IsObject );


#############################################################################
##
#A  Order( <elm> )
##
##  <#GAPDoc Label="Order">
##  <ManSection>
##  <Attr Name="Order" Arg='elm'/>
##
##  <Description>
##  is the multiplicative order of <A>elm</A>.
##  This is the smallest positive integer <M>n</M> such that
##  <A>elm</A> <C>^</C> <M>n</M> <C>= One( <A>elm</A> )</C>
##  if such an integer exists. If the order is
##  infinite, <Ref Attr="Order"/> may return the value <Ref Var="infinity"/>,
##  but it also might run into an infinite loop trying to test the order.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Order", IsMultiplicativeElementWithOne );


#############################################################################
##
#A  NormedRowVector( <v> )
##
##  <#GAPDoc Label="NormedRowVector">
##  <ManSection>
##  <Attr Name="NormedRowVector" Arg='v'/>
##
##  <Description>
##  returns a scalar multiple <C><A>w</A> = <A>c</A> * <A>v</A></C>
##  of the row vector <A>v</A>
##  with the property that the first nonzero entry of <A>w</A> is an identity
##  element in the sense of <Ref Prop="IsOne"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> NormedRowVector( [ 5, 2, 3 ] );
##  [ 1, 2/5, 3/5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <ManSection>
##  <Prop Name="IsSkewFieldFamily" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsSkewFieldFamily", IsFamily );


#############################################################################
##
#P  IsUFDFamily( <family> )
##
##  <ManSection>
##  <Prop Name="IsUFDFamily" Arg='family'/>
##
##  <Description>
##  the family <A>family</A> is at least a commutative ring-with-one,
##  without zero divisors, and the factorisation of each element into
##  elements of <A>family</A> is unique (up to units and ordering).
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsUFDFamily", IsFamily );


#############################################################################
##
#R  IsAdditiveElementAsMultiplicativeElementRep( <obj> )
##
##  <ManSection>
##  <Filt Name="IsAdditiveElementAsMultiplicativeElementRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation("IsAdditiveElementAsMultiplicativeElementRep",
  IsPositionalObjectRep and IsMultiplicativeElement);


#############################################################################
##
#A  AdditiveElementsAsMultiplicativeElementsFamily( <fam> )
##
##  <ManSection>
##  <Attr Name="AdditiveElementsAsMultiplicativeElementsFamily" Arg='fam'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute("AdditiveElementsAsMultiplicativeElementsFamily", IsFamily);


#############################################################################
##
#A  AdditiveElementAsMultiplicativeElement( <obj> )
##
##  <ManSection>
##  <Attr Name="AdditiveElementAsMultiplicativeElement" Arg='obj'/>
##
##  <Description>
##  for an additive element <A>obj</A>, this attribute returns a <E>multiplicative</E>
##  element, for which multiplication is done via addition of the original
##  element. The original element of such a <Q>wrapped</Q> multiplicative
##  element can be obtained as the <C>UnderlyingElement</C>.
##  </Description>
##  </ManSection>
##
DeclareAttribute("AdditiveElementAsMultiplicativeElement",
  IsAdditiveElement );


#############################################################################
##
#O  UnderlyingElement( <elm> )
##
##  <ManSection>
##  <Oper Name="UnderlyingElement" Arg='elm'/>
##
##  <Description>
##  Let <A>elm</A> be an object which builds on elements of another domain and
##  just wraps these up to provide another arithmetic.
##  </Description>
##  </ManSection>
##
DeclareOperation( "UnderlyingElement", [ IsObject ] );


#############################################################################
##
#P  IsIdempotent( <elt> )
##
##  <#GAPDoc Label="IsIdempotent">
##  <ManSection>
##  <Prop Name="IsIdempotent" Arg='elt'/>
##
##  <Description>
##  returns <K>true</K> iff <A>elt</A> is its own square.
##  (Even if <Ref Prop="IsZero"/> returns <K>true</K> for <A>elt</A>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsIdempotent", IsMultiplicativeElement);
