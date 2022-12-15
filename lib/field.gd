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
##  This file declares the operations for division rings.
##


#############################################################################
##
##  <#GAPDoc Label="[1]{field}">
##  <Index>fields</Index>
##  <Index>division rings</Index>
##  A <E>division ring</E> is a ring (see Chapter&nbsp;<Ref Chap="Rings"/>)
##  in which every non-zero element has an inverse.
##  The most important class of division rings are the commutative ones,
##  which are called <E>fields</E>.
##  <P/>
##  &GAP; supports finite fields
##  (see Chapter&nbsp;<Ref Chap="Finite Fields"/>) and
##  abelian number fields
##  (see Chapter&nbsp;<Ref Chap="Abelian Number Fields"/>),
##  in particular the field of rationals
##  (see Chapter&nbsp;<Ref Chap="Rational Numbers"/>).
##  <P/>
##  This chapter describes the general &GAP; functions for fields and
##  division rings.
##  <P/>
##  If a field <A>F</A> is a subfield of a commutative ring <A>C</A>,
##  <A>C</A> can be considered as a vector space over the (left) acting
##  domain <A>F</A> (see Chapter&nbsp;<Ref Chap="Vector Spaces"/>).
##  In this situation, we call <A>F</A> the <E>field of definition</E> of
##  <A>C</A>.
##  <P/>
##  Each field in &GAP; is represented as a vector space over a subfield
##  (see&nbsp;<Ref Filt="IsField"/>), thus each field is in fact a
##  field extension in a natural way,
##  which is used by functions such as
##  <Ref Attr="Norm"/> and <Ref Attr="Trace" Label="for a field element"/>
##  (see&nbsp;<Ref Sect="Galois Action"/>).
##  <#/GAPDoc>
##


#T Note that the families of a division ring and of its left acting domain
#T may be different!!


#############################################################################
##
#P  IsField( <D> )
##
##  <#GAPDoc Label="IsField">
##  <ManSection>
##  <Filt Name="IsField" Arg='D'/>
##
##  <Description>
##  A <E>field</E> is a commutative division ring
##  (see&nbsp;<Ref Filt="IsDivisionRing"/>
##  and&nbsp;<Ref Prop="IsCommutative"/>).
##  <Example><![CDATA[
##  gap> IsField( GaloisField(16) );           # the field with 16 elements
##  true
##  gap> IsField( Rationals );                 # the field of rationals
##  true
##  gap> q:= QuaternionAlgebra( Rationals );;  # noncommutative division ring
##  gap> IsField( q );  IsDivisionRing( q );
##  false
##  true
##  gap> mat:= [ [ 1 ] ];;  a:= Algebra( Rationals, [ mat ] );;
##  gap> IsDivisionRing( a );   # algebra not constructed as a division ring
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsField", IsDivisionRing and IsCommutative );

InstallTrueMethod( IsCommutative, IsDivisionRing and IsFinite );


#############################################################################
##
#A  PrimeField( <D> )
##
##  <#GAPDoc Label="PrimeField">
##  <ManSection>
##  <Attr Name="PrimeField" Arg='D'/>
##
##  <Description>
##  The <E>prime field</E> of a division ring <A>D</A> is the smallest field
##  which is contained in <A>D</A>.
##  For example, the prime field of any field in characteristic zero
##  is isomorphic to the field of rational numbers.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PrimeField", IsDivisionRing );


#############################################################################
##
#P  IsPrimeField( <D> )
##
##  <#GAPDoc Label="IsPrimeField">
##  <ManSection>
##  <Prop Name="IsPrimeField" Arg='D'/>
##
##  <Description>
##  A division ring is a prime field if it is equal to its prime field
##  (see&nbsp;<Ref Attr="PrimeField"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsPrimeField", IsDivisionRing );
InstallTrueMethod( IsField, IsPrimeField );

InstallIsomorphismMaintenance( IsPrimeField, IsField, IsField );


#############################################################################
##
#A  DefiningPolynomial( <F> )
##
##  <#GAPDoc Label="DefiningPolynomial">
##  <ManSection>
##  <Attr Name="DefiningPolynomial" Arg='F'/>
##
##  <Description>
##  is the defining polynomial of the field <A>F</A> as a field extension
##  over the left acting domain of <A>F</A>.
##  A root of the defining polynomial can be computed with
##  <Ref Attr="RootOfDefiningPolynomial"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DefiningPolynomial", IsField );


#############################################################################
##
#A  DegreeOverPrimeField( <F> )
##
##  <#GAPDoc Label="DegreeOverPrimeField">
##  <ManSection>
##  <Attr Name="DegreeOverPrimeField" Arg='F'/>
##
##  <Description>
##  is the degree of the field <A>F</A> over its prime field
##  (see&nbsp;<Ref Attr="PrimeField"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DegreeOverPrimeField", IsDivisionRing );

InstallIsomorphismMaintenance( DegreeOverPrimeField,
    IsDivisionRing, IsDivisionRing );


#############################################################################
##
#A  GeneratorsOfDivisionRing( <D> )
##
##  <#GAPDoc Label="GeneratorsOfDivisionRing">
##  <ManSection>
##  <Attr Name="GeneratorsOfDivisionRing" Arg='D'/>
##
##  <Description>
##  generators with respect to addition, multiplication, and taking inverses
##  (the identity cannot be omitted ...)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfDivisionRing", IsDivisionRing );


#############################################################################
##
#A  GeneratorsOfField( <F> )
##
##  <#GAPDoc Label="GeneratorsOfField">
##  <ManSection>
##  <Attr Name="GeneratorsOfField" Arg='F'/>
##
##  <Description>
##  generators with respect to addition, multiplication, and taking
##  inverses.
##  This attribute is the same as <Ref Attr="GeneratorsOfDivisionRing"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "GeneratorsOfField", GeneratorsOfDivisionRing );


#############################################################################
##
#A  NormalBase( <F>[, <elm>] )
##
##  <#GAPDoc Label="NormalBase">
##  <ManSection>
##  <Attr Name="NormalBase" Arg='F[, elm]'/>
##
##  <Description>
##  Let <A>F</A> be a field that is a Galois extension of its subfield
##  <C>LeftActingDomain( <A>F</A> )</C>.
##  Then <Ref Attr="NormalBase"/> returns a list of elements in <A>F</A>
##  that form a normal basis of <A>F</A>, that is,
##  a vector space basis that is closed under the action of the Galois group
##  (see&nbsp;<Ref Attr="GaloisGroup" Label="of field"/>) of <A>F</A>.
##  <P/>
##  If a second argument <A>elm</A> is given,
##  it is used as a hint for the algorithm to find a normal basis with the
##  algorithm described in&nbsp;<Cite Key="Art68"/>.
##  <Example><![CDATA[
##  gap> NormalBase( CF(5) );
##  [ -E(5), -E(5)^2, -E(5)^3, -E(5)^4 ]
##  gap> NormalBase( CF(4) );
##  [ 1/2-1/2*E(4), 1/2+1/2*E(4) ]
##  gap> NormalBase( GF(3^6) );
##  [ Z(3^6)^2, Z(3^6)^6, Z(3^6)^18, Z(3^6)^54, Z(3^6)^162, Z(3^6)^486 ]
##  gap> NormalBase( GF( GF(8), 2 ) );
##  [ Z(2^6), Z(2^6)^8 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NormalBase", IsField );
DeclareOperation( "NormalBase", [ IsField, IsScalar ] );


#############################################################################
##
#A  PrimitiveElement( <D> )
##
##  <#GAPDoc Label="PrimitiveElement">
##  <ManSection>
##  <Attr Name="PrimitiveElement" Arg='D'/>
##
##  <Description>
##  is an element of <A>D</A> that generates <A>D</A> as a division ring
##  together with the left acting domain.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PrimitiveElement", IsDivisionRing );


#############################################################################
##
#A  PrimitiveRoot( <F> )
##
##  <#GAPDoc Label="PrimitiveRoot">
##  <ManSection>
##  <Attr Name="PrimitiveRoot" Arg='F'/>
##
##  <Description>
##  A <E>primitive root</E> of a finite field is a generator of its
##  multiplicative group.
##  A primitive root is always a primitive element
##  (see&nbsp;<Ref Attr="PrimitiveElement"/>),
##  the converse is in general not true.
##  <!-- % For example, <C>Z(9)^2</C> is a primitive element for <C>GF(9)</C> but not a -->
##  <!-- % primitive root. -->
##  <Example><![CDATA[
##  gap> f:= GF( 3^5 );
##  GF(3^5)
##  gap> PrimitiveRoot( f );
##  Z(3^5)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PrimitiveRoot", IsField and IsFinite );


#############################################################################
##
#A  RootOfDefiningPolynomial( <F> )
##
##  <#GAPDoc Label="RootOfDefiningPolynomial">
##  <ManSection>
##  <Attr Name="RootOfDefiningPolynomial" Arg='F'/>
##
##  <Description>
##  is a root in the field <A>F</A> of its defining polynomial as a field
##  extension over the left acting domain of <A>F</A>.
##  The defining polynomial can be computed with
##  <Ref Attr="DefiningPolynomial"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RootOfDefiningPolynomial", IsField );


#############################################################################
##
#O  AsDivisionRing( [<F>, ]<C> )
#O  AsField( [<F>, ]<C> )
##
##  <#GAPDoc Label="AsDivisionRing">
##  <ManSection>
##  <Oper Name="AsDivisionRing" Arg='[F, ]C'/>
##  <Oper Name="AsField" Arg='[F, ]C'/>
##
##  <Description>
##  If the collection <A>C</A> can be regarded as a division ring then
##  <C>AsDivisionRing( <A>C</A> )</C> is the division ring that consists of
##  the elements of <A>C</A>, viewed as a vector space over its prime field;
##  otherwise <K>fail</K> is returned.
##  <P/>
##  In the second form, if <A>F</A> is a division ring contained in <A>C</A>
##  then the returned division ring is viewed as a vector space over
##  <A>F</A>.
##  <P/>
##  <Ref Oper="AsField"/> is just a synonym for <Ref Oper="AsDivisionRing"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AsDivisionRing", [ IsCollection ] );
DeclareOperation( "AsDivisionRing", [ IsDivisionRing, IsCollection ] );

DeclareSynonym( "AsField", AsDivisionRing );


#############################################################################
##
#O  ClosureDivisionRing( <D>, <obj> )
##
##  <ManSection>
##  <Oper Name="ClosureDivisionRing" Arg='D, obj'/>
##
##  <Description>
##  <Ref Func="ClosureDivisionRing"/> returns the division ring generated by
##  the elements of the division ring <A>D</A> and <A>obj</A>,
##  which can be either an element or a collection of elements,
##  in particular another division ring.
##  The left acting domain of the result equals that of <A>D</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "ClosureDivisionRing", [ IsDivisionRing, IsObject ] );

DeclareSynonym( "ClosureField", ClosureDivisionRing );


#############################################################################
##
#A  Subfields( <F> )
##
##  <#GAPDoc Label="Subfields">
##  <ManSection>
##  <Attr Name="Subfields" Arg='F'/>
##
##  <Description>
##  is the set of all subfields of the field <A>F</A>.
##  <!-- or shall we allow to ask, e.g., for subfields of quaternion algebras?-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Subfields", IsField );


#############################################################################
##
#O  FieldExtension( <F>, <poly> )
##
##  <#GAPDoc Label="FieldExtension">
##  <ManSection>
##  <Oper Name="FieldExtension" Arg='F, poly'/>
##
##  <Description>
##  is the field obtained on adjoining a root of the irreducible polynomial
##  <A>poly</A> to the field <A>F</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "FieldExtension", [ IsField, IsUnivariatePolynomial ] );


#############################################################################
##
##  <#GAPDoc Label="[2]{field}">
##  Let <M>L > K</M> be a field extension of finite degree.
##  Then to each element <M>\alpha \in L</M>, we can associate a
##  <M>K</M>-linear mapping <M>\varphi_{\alpha}</M> on <M>L</M>,
##  and for a fixed <M>K</M>-basis of <M>L</M>,
##  we can associate to <M>\alpha</M> the matrix <M>M_{\alpha}</M>
##  (over <M>K</M>) of this mapping.
##  <P/>
##  The <E>norm</E> of <M>\alpha</M> is defined as the determinant of
##  <M>M_{\alpha}</M>,
##  the <E>trace</E> of <M>\alpha</M> is defined as the trace of
##  <M>M_{\alpha}</M>,
##  the <E>minimal polynomial</E> <M>\mu_{\alpha}</M> and the
##  <E>trace polynomial</E> <M>\chi_{\alpha}</M> of <M>\alpha</M>
##  are defined as the minimal polynomial
##  (see&nbsp;<Ref Sect="MinimalPolynomial" Label="over a field"/>)
##  and the characteristic polynomial
##  (see&nbsp;<Ref Attr="CharacteristicPolynomial"/> and
##  <Ref Oper="TracePolynomial"/>) of <M>M_{\alpha}</M>.
##  (Note that <M>\mu_{\alpha}</M> depends only on <M>K</M> whereas
##  <M>\chi_{\alpha}</M> depends on both <M>L</M> and <M>K</M>.)
##  <P/>
##  Thus norm and trace of <M>\alpha</M> are elements of <M>K</M>,
##  and <M>\mu_{\alpha}</M> and <M>\chi_{\alpha}</M> are polynomials over
##  <M>K</M>, <M>\chi_{\alpha}</M> being a power of <M>\mu_{\alpha}</M>,
##  and the degree of <M>\chi_{\alpha}</M> equals the degree of the field
##  extension <M>L > K</M>.
##  <P/>
##  The <E>conjugates</E> of <M>\alpha</M> in <M>L</M> are those roots of
##  <M>\chi_{\alpha}</M> (with multiplicity) that lie in <M>L</M>;
##  note that if only <M>L</M> is given, there is in general no way to access
##  the roots outside <M>L</M>.
##  <P/>
##  Analogously, the <E>Galois group</E> of the extension <M>L > K</M> is
##  defined as the group of all those field automorphisms of <M>L</M> that
##  fix <M>K</M> pointwise.
##  <P/>
##  If <M>L > K</M> is a Galois extension then the conjugates of
##  <M>\alpha</M> are all roots of <M>\chi_{\alpha}</M> (with multiplicity),
##  the set of conjugates equals the roots of <M>\mu_{\alpha}</M>,
##  the norm of <M>\alpha</M> equals the product and the trace of
##  <M>\alpha</M> equals the sum of the conjugates of <M>\alpha</M>,
##  and the Galois group in the sense of the above definition equals
##  the usual Galois group,
##  <P/>
##  Note that <C>MinimalPolynomial( <A>F</A>, <A>z</A> )</C> is a polynomial
##  <E>over</E> <A>F</A>,
##  whereas <C>Norm( <A>F</A>, <A>z</A> )</C> is the norm of the element
##  <A>z</A> <E>in</E> <A>F</A>
##  w.r.t.&nbsp;the field extension
##  <C><A>F</A> &gt; LeftActingDomain( <A>F</A> )</C>.
##  <#/GAPDoc>
##


#############################################################################
##
##  <#GAPDoc Label="[3]{field}">
##  The default methods for field elements are as follows.
##  <Ref Oper="MinimalPolynomial"/> solves a system of linear equations,
##  <Ref Oper="TracePolynomial"/> computes the appropriate power of the
##  minimal
##  polynomial,
##  <Ref Attr="Norm"/> and <Ref Attr="Trace" Label="for a field element"/>
##  values are obtained as coefficients of the characteristic polynomial,
##  and <Ref Attr="Conjugates"/> uses the factorization of the
##  characteristic polynomial.
##  <P/>
##  For elements in finite fields and cyclotomic fields, one wants to do the
##  computations in a different way since the field extensions in question
##  are Galois extensions, and the Galois groups are well-known in these
##  cases.
##  More general,
##  if a field is in the category
##  <C>IsFieldControlledByGaloisGroup</C> then
##  the default methods are the following.
##  <Ref Attr="Conjugates"/> returns the sorted list of images
##  (with multiplicity) of the element under the Galois group,
##  <Ref Attr="Norm"/> computes the product of the conjugates,
##  <Ref Attr="Trace" Label="for a field element"/> computes the sum of the
##  conjugates,
##  <Ref Oper="TracePolynomial"/> and <Ref Oper="MinimalPolynomial"/> compute
##  the product of linear factors <M>x - c</M> with <M>c</M> ranging over the
##  conjugates and the set of conjugates, respectively.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsFieldControlledByGaloisGroup( <obj> )
##
##  <ManSection>
##  <Filt Name="IsFieldControlledByGaloisGroup" Arg='obj' Type='Category'/>
##
##  <Description>
##  (The meaning is explained above.)
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsFieldControlledByGaloisGroup", IsField );


#############################################################################
##
#M  IsFieldControlledByGaloisGroup( <finfield> )
##
##  For finite fields and abelian number fields
##  (independent of the representation of their elements),
##  we know the Galois group and have a method for `Conjugates' that does
##  not use `MinimalPolynomial'.
##  Currently fields created with `AlgebraicExtension' do not support this
##  approach, so we do not install the implication from
##  `IsField and IsFinite'.
##
InstallTrueMethod( IsFieldControlledByGaloisGroup,
    IsField and IsFFECollection );


#############################################################################
##
#A  Conjugates( [<L>, [<K>, ]]<z> ) . . . . . . conjugates of a field element
##
##  <#GAPDoc Label="Conjugates">
##  <ManSection>
##  <Attr Name="Conjugates" Arg='[L, [K, ]]z'/>
##
##  <Description>
##  <Ref Attr="Conjugates"/> returns the list of <E>conjugates</E>
##  of the field element <A>z</A>.
##  If two fields <A>L</A> and <A>K</A> are given then the conjugates are
##  computed w.r.t.&nbsp;the field extension <A>L</A><M> > </M><A>K</A>,
##  if only one field <A>L</A> is given then
##  <C>LeftActingDomain( <A>L</A> )</C> is taken as default for the subfield
##  <A>K</A>,
##  and if no field is given then <C>DefaultField( <A>z</A> )</C> is taken
##  as default for <A>L</A>.
##  <P/>
##  The result list will contain duplicates if <A>z</A> lies in a
##  proper subfield of <A>L</A>, or of the default field of <A>z</A>,
##  respectively.
##  The result list need not be sorted.
##  <P/>
##  <Example><![CDATA[
##  gap> Norm( E(8) );  Norm( CF(8), E(8) );
##  1
##  1
##  gap> Norm( CF(8), CF(4), E(8) );
##  -E(4)
##  gap> Norm( AsField( CF(4), CF(8) ), E(8) );
##  -E(4)
##  gap> Trace( E(8) );  Trace( CF(8), CF(8), E(8) );
##  0
##  E(8)
##  gap> Conjugates( CF(8), E(8) );
##  [ E(8), E(8)^3, -E(8), -E(8)^3 ]
##  gap> Conjugates( CF(8), CF(4), E(8) );
##  [ E(8), -E(8) ]
##  gap> Conjugates( CF(16), E(8) );
##  [ E(8), E(8)^3, -E(8), -E(8)^3, E(8), E(8)^3, -E(8), -E(8)^3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Conjugates", IsScalar );
DeclareOperation( "Conjugates", [ IsField, IsField, IsScalar ] );
DeclareOperation( "Conjugates", [ IsField, IsScalar ] );


#############################################################################
##
#A  Norm( [<L>, [<K>, ]]<z> )  . . . . . . . . . . .  norm of a field element
##
##  <#GAPDoc Label="Norm">
##  <ManSection>
##  <Attr Name="Norm" Arg='[L, [K, ]]z'/>
##
##  <Description>
##  <Ref Attr="Norm"/> returns the norm of the field element <A>z</A>.
##  If two fields <A>L</A> and <A>K</A> are given then the norm is computed
##  w.r.t.&nbsp;the field extension <A>L</A><M> > </M><A>K</A>,
##  if only one field <A>L</A> is given then
##  <C>LeftActingDomain( <A>L</A> )</C> is taken as
##  default for the subfield <A>K</A>,
##  and if no field is given then <C>DefaultField( <A>z</A> )</C> is taken
##  as default for <A>L</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Norm", IsScalar );
DeclareOperation( "Norm", [ IsField, IsScalar ] );
DeclareOperation( "Norm", [ IsField, IsField, IsScalar ] );


#############################################################################
##
#A  Trace( [<L>, [<K>, ]]<z> )  . . . . . . . . . .  trace of a field element
#A  Trace( <mat> )  . . . . . . . . . . . . . . . . . . . . trace of a matrix
##
##  <#GAPDoc Label="Trace">
##  <ManSection>
##  <Heading>Traces of field elements and matrices</Heading>
##  <Attr Name="Trace" Arg='[L, [K, ]]z' Label="for a field element"/>
##  <Attr Name="Trace" Arg='mat' Label="for a matrix"/>
##
##  <Description>
##  <Ref Attr="Trace" Label="for a field element"/> returns the trace of the
##  field element <A>z</A>.
##  If two fields <A>L</A> and <A>K</A> are given then the trace is computed
##  w.r.t.&nbsp;the field extension <M><A>L</A> > <A>K</A></M>,
##  if only one field <A>L</A> is given then
##  <C>LeftActingDomain( <A>L</A> )</C> is taken as
##  default for the subfield <A>K</A>,
##  and if no field is given then <C>DefaultField( <A>z</A> )</C> is taken
##  as default for <A>L</A>.
##  <P/>
##  The <E>trace of a matrix</E> is the sum of its diagonal entries.
##  Note that this is <E>not</E> compatible with the definition of
##  <Ref Attr="Trace" Label="for a field element"/> for field elements,
##  so the one-argument version is not suitable when matrices shall be
##  regarded as field elements.
##  <!-- forbid <C>Trace</C> as short form for <C>TraceMat</C>?-->
##  <!-- crossref. to <C>TraceMat</C>?-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Trace", IsScalar );
DeclareAttribute( "Trace", IsMatrix );
DeclareOperation( "Trace", [ IsField, IsScalar ] );
DeclareOperation( "Trace", [ IsField, IsField, IsScalar ] );


#############################################################################
##
#O  TracePolynomial( <L>, <K>, <z>[, <inum>] )
##
##  <#GAPDoc Label="TracePolynomial">
##  <ManSection>
##  <Oper Name="TracePolynomial" Arg='L, K, z[, inum]'/>
##
##  <Description>
##  <Index Subkey="for field elements">characteristic polynomial</Index>
##  returns the polynomial that is the product of <M>(X - c)</M>
##  where <M>c</M> runs over the conjugates of <A>z</A>
##  in the field extension <A>L</A> over <A>K</A>.
##  The polynomial is returned as a univariate polynomial over <A>K</A>
##  in the indeterminate number <A>inum</A> (defaulting to 1).
##  <P/>
##  This polynomial is sometimes also called the
##  <E>characteristic polynomial</E> of <A>z</A> w.r.t.&nbsp;the field
##  extension <M><A>L</A> > <A>K</A></M>.
##  Therefore methods are installed for
##  <Ref Attr="CharacteristicPolynomial"/>
##  that call <Ref Oper="TracePolynomial"/> in the case of field extensions.
##  <P/>
##  <Example><![CDATA[
##  gap> TracePolynomial( CF(8), Rationals, E(8) );
##  x_1^4+1
##  gap> TracePolynomial( CF(16), Rationals, E(8) );
##  x_1^8+2*x_1^4+1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "TracePolynomial", [ IsField, IsField, IsScalar ] );
DeclareOperation( "TracePolynomial",
    [ IsField, IsField, IsScalar, IsPosInt ] );


#############################################################################
##
#A  GaloisGroup( <F> )
##
##  <#GAPDoc Label="GaloisGroup:field">
##  <ManSection>
##  <Attr Name="GaloisGroup" Arg='F' Label="of field"/>
##
##  <Description>
##  The <E>Galois group</E> of a field <A>F</A> is the group of all
##  field automorphisms of <A>F</A> that fix the subfield
##  <M>K = </M><C>LeftActingDomain( <A>F</A> )</C> pointwise.
##  <P/>
##  Note that the field extension <M><A>F</A> > K</M> need <E>not</E> be
##  a Galois extension.
##  <Example><![CDATA[
##  gap> g:= GaloisGroup( AsField( GF(2^2), GF(2^12) ) );;
##  gap> Size( g );  IsCyclic( g );
##  6
##  true
##  gap> h:= GaloisGroup( CF(60) );;
##  gap> Size( h );  IsAbelian( h );
##  16
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GaloisGroup", IsField );


#############################################################################
##
#A  ComplexConjugate( <z> )
#A  RealPart( <z> )
#A  ImaginaryPart( <z> )
##
##  <#GAPDoc Label="ComplexConjugate">
##  <ManSection>
##  <Attr Name="ComplexConjugate" Arg='z'/>
##  <Attr Name="RealPart" Arg='z'/>
##  <Attr Name="ImaginaryPart" Arg='z'/>
##
##  <Description>
##  For a cyclotomic number <A>z</A>,
##  <Ref Attr="ComplexConjugate"/> returns
##  <C>GaloisCyc( <A>z</A>, -1 )</C>,
##  see&nbsp;<Ref Oper="GaloisCyc" Label="for a cyclotomic"/>.
##  For a quaternion <M><A>z</A> = c_1 e + c_2 i + c_3 j + c_4 k</M>,
##  <Ref Attr="ComplexConjugate"/> returns
##  <M>c_1 e - c_2 i - c_3 j - c_4 k</M>,
##  see&nbsp;<Ref Filt="IsQuaternion"/>.
##  <P/>
##  When <Ref Attr="ComplexConjugate"/> is called with a list then the result
##  is the list of return values of <Ref Attr="ComplexConjugate"/>
##  for the list entries in the corresponding positions.
##  <P/>
##  When <Ref Attr="ComplexConjugate"/> is defined for an object <A>z</A>
##  then <Ref Attr="RealPart"/> and <Ref Attr="ImaginaryPart"/> return
##  <C>(<A>z</A> + ComplexConjugate( <A>z</A> )) / 2</C> and
##  <C>(<A>z</A> - ComplexConjugate( <A>z</A> )) / 2 i</C>, respectively,
##  where <C>i</C> denotes the corresponding imaginary unit.
##  <P/>
##  <Example><![CDATA[
##  gap> GaloisCyc( E(5) + E(5)^4, 2 );
##  E(5)^2+E(5)^3
##  gap> GaloisCyc( E(5), -1 );           # the complex conjugate
##  E(5)^4
##  gap> GaloisCyc( E(5) + E(5)^4, -1 );  # this value is real
##  E(5)+E(5)^4
##  gap> GaloisCyc( E(15) + E(15)^4, 3 );
##  E(5)+E(5)^4
##  gap> ComplexConjugate( E(7) );
##  E(7)^6
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ComplexConjugate", IsScalar );
DeclareAttribute( "ComplexConjugate", IsList );
DeclareAttribute( "RealPart", IsScalar );
DeclareAttribute( "RealPart", IsList );
DeclareAttribute( "ImaginaryPart", IsScalar );
DeclareAttribute( "ImaginaryPart", IsList );


#############################################################################
##
#O  DivisionRingByGenerators( [<F>, ]<gens> ) . . . . div. ring by generators
##
##  <#GAPDoc Label="DivisionRingByGenerators">
##  <ManSection>
##  <Oper Name="DivisionRingByGenerators" Arg='[F, ]gens'/>
##  <Oper Name="FieldByGenerators" Arg='[F, ]gens'/>
##
##  <Description>
##  Called with a field <A>F</A> and a list <A>gens</A> of scalars,
##  <Ref Oper="DivisionRingByGenerators"/> returns the division ring over
##  <A>F</A> generated by <A>gens</A>.
##  The unary version returns the division ring as vector space over
##  <C>FieldOverItselfByGenerators( <A>gens</A> )</C>.
##  <P/>
##  <Ref Oper="FieldByGenerators"/> is just a synonym for
##  <Ref Oper="DivisionRingByGenerators"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DivisionRingByGenerators",
        [ IsDivisionRing, IsCollection ] );

DeclareSynonym( "FieldByGenerators", DivisionRingByGenerators );


#############################################################################
##
#O  FieldOverItselfByGenerators( [ <z>, ... ] )
##
##  <#GAPDoc Label="FieldOverItselfByGenerators">
##  <ManSection>
##  <Oper Name="FieldOverItselfByGenerators" Arg='[ z, ... ]'/>
##
##  <Description>
##  This  operation is  needed for  the  call of
##  <Ref Func="Field" Label="for several generators"/> or
##  <Ref Oper="FieldByGenerators"/> without explicitly given subfield,
##  in order to construct a left acting domain for such a field.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "FieldOverItselfByGenerators", [ IsCollection ] );


#############################################################################
##
#O  DefaultFieldByGenerators( [ <z>, ... ] )  . . default field by generators
##
##  <#GAPDoc Label="DefaultFieldByGenerators">
##  <ManSection>
##  <Oper Name="DefaultFieldByGenerators" Arg='[ z, ... ]'/>
##
##  <Description>
##  returns the default field containing the elements <A>z</A>, <M>\ldots</M>.
##  This field may be bigger than the smallest field containing these
##  elements.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DefaultFieldByGenerators", [ IsCollection ] );


#############################################################################
##
#F  Field( <z>, ... ) . . . . . . . . . field generated by a list of elements
#F  Field( [<F>, ]<list> )
##
##  <#GAPDoc Label="Field">
##  <ManSection>
##  <Func Name="Field" Arg='z, ...' Label="for several generators"/>
##  <Func Name="Field" Arg='[F, ]list'
##   Label="for (a field and) a list of generators"/>
##
##  <Description>
##  <Ref Func="Field" Label="for several generators"/> returns the smallest
##  field <M>K</M> that contains all the elements <M><A>z</A>, \ldots</M>,
##  or the smallest field <M>K</M> that contains all elements in the list
##  <A>list</A>.
##  If no subfield <A>F</A> is given, <M>K</M> is constructed as a field over
##  itself, i.e. the left acting domain of <M>K</M> is <M>K</M>.
##  Called with a field <A>F</A> and a list <A>list</A>,
##  <Ref Func="Field" Label="for (a field and) a list of generators"/>
##  constructs the field generated by <A>F</A> and the elements in
##  <A>list</A>, as a vector space over <A>F</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Field" );
#T why not `DivisionRing', and `Field' as a (more or less) synonym?


#############################################################################
##
#F  DefaultField( <z>, ... )  . . . . . default field containing a collection
#F  DefaultField( <list> )
##
##  <#GAPDoc Label="DefaultField">
##  <ManSection>
##  <Func Name="DefaultField" Arg='z, ...' Label="for several generators"/>
##  <Func Name="DefaultField" Arg='list' Label="for a list of generators"/>
##
##  <Description>
##  <Ref Func="DefaultField" Label="for several generators"/> returns a field
##  <M>K</M> that contains all the elements <M><A>z</A>, \ldots</M>,
##  or a field <M>K</M> that contains all elements in the list <A>list</A>.
##  <P/>
##  This field need not be the smallest field in which the elements lie,
##  cf.&nbsp;<Ref Func="Field" Label="for several generators"/>.
##  For example, for elements from cyclotomic fields
##  <Ref Func="DefaultField" Label="for several generators"/> returns
##  the smallest cyclotomic field in which the elements lie,
##  but the elements may lie in a smaller number field
##  which is not a cyclotomic field.
##  <Example><![CDATA[
##  gap> Field( Z(4) );  Field( [ Z(4), Z(8) ] );  # finite fields
##  GF(2^2)
##  GF(2^6)
##  gap> Field( E(9) );  Field( CF(4), [ E(9) ] ); # abelian number fields
##  CF(9)
##  AsField( GaussianRationals, CF(36) )
##  gap> f1:= Field( EB(5) );  f2:= DefaultField( EB(5) );
##  NF(5,[ 1, 4 ])
##  CF(5)
##  gap> f1 = f2;  IsSubset( f2, f1 );
##  false
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DefaultField" );


#############################################################################
##
#F  Subfield( <F>, <gens> ) . . . . . . . subfield of <F> generated by <gens>
#F  SubfieldNC( <F>, <gens> )
##
##  <#GAPDoc Label="Subfield">
##  <ManSection>
##  <Func Name="Subfield" Arg='F, gens'/>
##  <Func Name="SubfieldNC" Arg='F, gens'/>
##
##  <Description>
##  Constructs the subfield of <A>F</A> generated by <A>gens</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Subfield" );
DeclareGlobalFunction( "SubfieldNC" );


#############################################################################
##
#A  FrobeniusAutomorphism( <F> )  .  Frobenius automorphism of a finite field
##
##  <#GAPDoc Label="FrobeniusAutomorphism">
##  <ManSection>
##  <Attr Name="FrobeniusAutomorphism" Arg='F'/>
##
##  <Description>
##  <Index Subkey="Frobenius, field">homomorphisms</Index>
##  <Index Subkey="Frobenius">field homomorphisms</Index>
##  <Index Key="CompositionMapping" Subkey="for Frobenius automorphisms">
##  <C>CompositionMapping</C></Index>
##  returns the Frobenius automorphism of the finite field <A>F</A>
##  as a field homomorphism (see&nbsp;<Ref Sect="Ring Homomorphisms"/>).
##  <P/>
##  <Index>Frobenius automorphism</Index>
##  The <E>Frobenius automorphism</E> <M>f</M> of a finite field <M>F</M> of
##  characteristic <M>p</M> is the function that takes each element <M>z</M>
##  of <M>F</M> to its <M>p</M>-th power.
##  Each field automorphism of <M>F</M> is a power of <M>f</M>.
##  Thus <M>f</M> is a generator for the Galois group of <M>F</M> relative to
##  the prime field of <M>F</M>,
##  and an appropriate power of <M>f</M> is a generator of the Galois group
##  of <M>F</M> over a subfield
##  (see&nbsp;<Ref Attr="GaloisGroup" Label="of field"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> f := GF(16);
##  GF(2^4)
##  gap> x := FrobeniusAutomorphism( f );
##  FrobeniusAutomorphism( GF(2^4) )
##  gap> Z(16) ^ x;
##  Z(2^4)^2
##  gap> x^2;
##  FrobeniusAutomorphism( GF(2^4) )^2
##  ]]></Example>
##  <P/>
##  <Index Key="Image" Subkey="for Frobenius automorphisms"><C>Image</C>
##  </Index>
##  The image of an element <M>z</M> under the <M>i</M>-th power of <M>f</M>
##  is computed as the <M>p^i</M>-th power of <M>z</M>.
##  The product of the <M>i</M>-th power and the <M>j</M>-th power of
##  <M>f</M> is the <M>k</M>-th power of <M>f</M>, where <M>k</M> is
##  <M>i j \bmod </M> <C>Size(<A>F</A>)</C><M>-1</M>.
##  The zeroth power of <M>f</M> is <C>IdentityMapping( <A>F</A> )</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "FrobeniusAutomorphism", IsField );


#############################################################################
##
#F  IsFieldElementsSpace( <V> )
##
##  <ManSection>
##  <Func Name="IsFieldElementsSpace" Arg='V'/>
##
##  <Description>
##  If an <M>F</M>-vector space <A>V</A> is in the filter <C>IsFieldElementsSpace</C> then
##  this expresses that <A>V</A> consists of elements in a field, and that <A>V</A> is
##  handled via the mechanism of nice bases (see&nbsp;<Ref ???="..."/>) in the following way.
##  Let <M>K</M> be the default field generated by the vector space generators of
##  <A>V</A>.
##  Then the <C>NiceFreeLeftModuleInfo</C> value of <A>V</A> is an <M>F</M>-basis <M>B</M> of <M>K</M>,
##  and the <C>NiceVector</C> value of <M>v \in <A>V</A></M> is defined as
##  <C>Coefficients</C><M>( B, v )</M>.
##  <P/>
##  So it is assumed that methods for computing a basis for the
##  <M>F</M>-vector space <M>K</M> are known;
##  for example, one can compute a Lenstra basis (see&nbsp;<Ref ???="..."/>) if <M>K</M> is an
##  abelian number field,
##  and take successive powers of a primitive root if <M>K</M> is a finite field
##  (see&nbsp;<Ref ???="..."/>).
##  </Description>
##  </ManSection>
##
DeclareHandlingByNiceBasis( "IsFieldElementsSpace",
    "for free left modules of field elements" );


#############################################################################
##
#O  NthRoot( <F>, <a>, <n> )
##
##  <ManSection>
##  <Oper Name="NthRoot" Arg='F, a, n'/>
##
##  <Description>
##  returns one <A>n</A>th root of <A>a</A> if such a root exists in <A>F</A>
##  and returns <K>fail</K> otherwise.
##  </Description>
##  </ManSection>
##
DeclareOperation( "NthRoot", [ IsField, IsScalar, IsPosInt ] );
