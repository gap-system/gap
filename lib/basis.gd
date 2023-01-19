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
##  This file declares the operations for bases of free left modules.
##


#############################################################################
##
##  <#GAPDoc Label="[1]{basis}">
##  In &GAP;, a <E>basis</E> of a free left <M>F</M>-module <M>V</M> is a list of vectors
##  <M>B = [ v_1, v_2, \ldots, v_n ]</M> in <M>V</M> such that <M>V</M> is generated as a
##  left <M>F</M>-module by these vectors and such that <M>B</M> is linearly
##  independent over <M>F</M>.
##  The integer <M>n</M> is the dimension of <M>V</M> (see&nbsp;<Ref Attr="Dimension"/>).
##  In particular, as each basis is a list (see Chapter&nbsp;<Ref Chap="Lists"/>),
##  it has a length (see&nbsp;<Ref Attr="Length"/>), and the <M>i</M>-th vector of <M>B</M> can be
##  accessed as <M>B[i]</M>.
##  <Example><![CDATA[
##  gap> V:= Rationals^3;
##  ( Rationals^3 )
##  gap> B:= Basis( V );
##  CanonicalBasis( ( Rationals^3 ) )
##  gap> Length( B );
##  3
##  gap> B[1];
##  [ 1, 0, 0 ]
##  ]]></Example>
##  <P/>
##  The operations described below make sense only for bases of <E>finite</E>
##  dimensional vector spaces.
##  (In practice this means that the vector spaces must be <E>low</E> dimensional,
##  that is, the dimension should not exceed a few hundred.)
##  <P/>
##  Besides the basic operations for lists
##  (see&nbsp;<Ref Sect="Basic Operations for Lists"/>),
##  the <E>basic operations for bases</E> are <Ref Attr="BasisVectors"/>,
##  <Ref Oper="Coefficients"/>,
##  <Ref Oper="LinearCombination"/>,
##  and <Ref Attr="UnderlyingLeftModule"/>.
##  These and other operations for arbitrary bases are described
##  in&nbsp;<Ref Sect="Operations for Vector Space Bases"/>.
##  <P/>
##  For special kinds of bases, further operations are defined
##  (see&nbsp;<Ref Sect="Operations for Special Kinds of Bases"/>).
##  <P/>
##  &GAP; supports the following three kinds of bases.
##  <P/>
##  <E>Relative bases</E> delegate the work to other bases of the same
##  free left module, via basechange matrices (see&nbsp;<Ref Oper="RelativeBasis"/>).
##  <P/>
##  <E>Bases handled by nice bases</E> delegate the work to bases
##  of isomorphic left modules over the same left acting domain
##  (see&nbsp;<Ref Sect="Vector Spaces Handled By Nice Bases"/>).
##  <P/>
##  Finally, of course there must be bases in &GAP; that really do the work.
##  <P/>
##  For example, in the case of a Gaussian row or matrix space <A>V</A>
##  (see&nbsp;<Ref Sect="Row and Matrix Spaces"/>),
##  <C>Basis( <A>V</A> )</C> is a semi-echelonized basis (see&nbsp;<Ref Prop="IsSemiEchelonized"/>)
##  that uses Gaussian elimination; such a basis is of the third kind.
##  <C>Basis( <A>V</A>, <A>vectors</A> )</C> is either semi-echelonized or a relative basis.
##  Other examples of bases of the third kind are canonical bases of finite
##  fields and of abelian number fields.
##  <P/>
##  Bases handled by nice bases are described
##  in&nbsp;<Ref Sect="Vector Spaces Handled By Nice Bases"/>.
##  Examples are non-Gaussian row and matrix spaces, and subspaces of finite
##  fields and abelian number fields that are themselves not fields.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsBasis( <obj> )
##
##  <#GAPDoc Label="IsBasis">
##  <ManSection>
##  <Filt Name="IsBasis" Arg='obj' Type='Category'/>
##
##  <Description>
##  In &GAP;, a <E>basis</E> of a free left module is an object that knows
##  how to compute coefficients w.r.t.&nbsp;its basis vectors
##  (see&nbsp;<Ref Oper="Coefficients"/>).
##  Bases are constructed by <Ref Attr="Basis"/>.
##  Each basis is an immutable list,
##  the <M>i</M>-th entry being the <M>i</M>-th basis vector.
##  <P/>
##  (See&nbsp;<Ref Sect="Mutable Bases"/> for mutable bases.)
##  <P/>
##  <Example><![CDATA[
##  gap> V:= GF(2)^2;;
##  gap> B:= Basis( V );;
##  gap> IsBasis( B );
##  true
##  gap> IsBasis( [ [ 1, 0 ], [ 0, 1 ] ] );
##  false
##  gap> IsBasis( Basis( Rationals^2, [ [ 1, 0 ], [ 0, 1 ] ] ) );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsBasis", IsHomogeneousList and IsDuplicateFreeList );


#############################################################################
##
#C  IsFiniteBasisDefault( <obj> )
##
##  <ManSection>
##  <Filt Name="IsFiniteBasisDefault" Arg='obj' Type='Category'/>
##
##  <Description>
##  Objects in this category are in <C>IsListDefault</C>, that is, addition and
##  multiplication for them is defined as for internally represented lists,
##  the result presumably being an internally represented list.
##  </Description>
##  </ManSection>
##
DeclareSynonym( "IsFiniteBasisDefault",
    IsBasis and IsCopyable and IsListDefault );


#############################################################################
##
#P  IsCanonicalBasis( <B> )
##
##  <#GAPDoc Label="IsCanonicalBasis">
##  <ManSection>
##  <Prop Name="IsCanonicalBasis" Arg='B'/>
##
##  <Description>
##  If the underlying free left module <M>V</M> of the basis <A>B</A>
##  supports a canonical basis (see&nbsp;<Ref Attr="CanonicalBasis"/>) then
##  <Ref Prop="IsCanonicalBasis"/> returns <K>true</K> if <A>B</A> is equal
##  to the canonical basis of <M>V</M>,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsCanonicalBasis", IsBasis );
InstallTrueMethod( IsBasis, IsCanonicalBasis );


#############################################################################
##
#P  IsCanonicalBasisFullRowModule( <B> )
##
##  <#GAPDoc Label="IsCanonicalBasisFullRowModule">
##  <ManSection>
##  <Prop Name="IsCanonicalBasisFullRowModule" Arg='B'/>
##
##  <Description>
##  <Index Subkey="for row spaces">canonical basis</Index>
##  <Ref Prop="IsCanonicalBasisFullRowModule"/> returns <K>true</K> if
##  <A>B</A> is the canonical basis (see&nbsp;<Ref Prop="IsCanonicalBasis"/>)
##  of a full row module (see&nbsp;<Ref Prop="IsFullRowModule"/>),
##  and <K>false</K> otherwise.
##  <P/>
##  The <E>canonical basis</E> of a Gaussian row space is defined as the
##  unique semi-echelonized (see&nbsp;<Ref Prop="IsSemiEchelonized"/>) basis
##  with the additional property that for <M>j > i</M> the position of the
##  pivot of row <M>j</M> is bigger than the position of the pivot of row
##  <M>i</M>, and that each pivot column contains exactly one nonzero entry.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsCanonicalBasisFullRowModule", IsBasis );

InstallTrueMethod( IsCanonicalBasis, IsCanonicalBasisFullRowModule );

InstallTrueMethod( IsSmallList,
    IsList and IsCanonicalBasisFullRowModule );


#############################################################################
##
#P  IsCanonicalBasisFullMatrixModule( <B> )
##
##  <#GAPDoc Label="IsCanonicalBasisFullMatrixModule">
##  <ManSection>
##  <Prop Name="IsCanonicalBasisFullMatrixModule" Arg='B'/>
##
##  <Description>
##  <Index Subkey="for matrix spaces">canonical basis</Index>
##  <Ref Prop="IsCanonicalBasisFullMatrixModule"/> returns <K>true</K> if
##  <A>B</A> is the canonical basis (see&nbsp;<Ref Prop="IsCanonicalBasis"/>)
##  of a full matrix module (see&nbsp;<Ref Prop="IsFullMatrixModule"/>),
##  and <K>false</K> otherwise.
##  <P/>
##  The <E>canonical basis</E> of a Gaussian matrix space is defined as the
##  unique semi-echelonized (see&nbsp;<Ref Prop="IsSemiEchelonized"/>) basis
##  for which the list of concatenations of the basis vectors forms the
##  canonical basis of the corresponding Gaussian row space.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsCanonicalBasisFullMatrixModule", IsBasis );

InstallTrueMethod( IsCanonicalBasis, IsCanonicalBasisFullMatrixModule );

InstallTrueMethod( IsSmallList,
    IsList and IsCanonicalBasisFullMatrixModule );


#############################################################################
##
#P  IsIntegralBasis( <B> )
##
##  <#GAPDoc Label="IsIntegralBasis">
##  <ManSection>
##  <Prop Name="IsIntegralBasis" Arg='B'/>
##
##  <Description>
##  Let <A>B</A> be an <M>S</M>-basis of a <E>field</E> <M>F</M> for a subfield <M>S</M> of <M>F</M>,
##  and let <M>R</M> and <M>M</M> be the rings of algebraic integers in <M>S</M> and <M>F</M>,
##  respectively.
##  <C>IsIntegralBasis</C> returns <K>true</K> if <A>B</A> is also an <M>R</M>-basis of <M>M</M>,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsIntegralBasis", IsBasis );


#############################################################################
##
#P  IsNormalBasis( <B> )
##
##  <#GAPDoc Label="IsNormalBasis">
##  <ManSection>
##  <Prop Name="IsNormalBasis" Arg='B'/>
##
##  <Description>
##  Let <A>B</A> be an <M>S</M>-basis of a <E>field</E> <M>F</M>
##  for a subfield <M>S</M> of <M>F</M>.
##  <C>IsNormalBasis</C> returns <K>true</K> if <A>B</A> is invariant under
##  the Galois group
##  (see&nbsp;<Ref Attr="GaloisGroup" Label="of field"/>)
##  of the field extension <M>F / S</M>, and <K>false</K> otherwise.
##  <Example><![CDATA[
##  gap> B:= CanonicalBasis( GaussianRationals );
##  CanonicalBasis( GaussianRationals )
##  gap> IsIntegralBasis( B );  IsNormalBasis( B );
##  true
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsNormalBasis", IsBasis );


#############################################################################
##
#P  IsSemiEchelonized( <B> )
##
##  <#GAPDoc Label="IsSemiEchelonized">
##  <ManSection>
##  <Prop Name="IsSemiEchelonized" Arg='B'/>
##
##  <Description>
##  Let <A>B</A> be a basis of a Gaussian row or matrix space <M>V</M>
##  (see&nbsp;<Ref Filt="IsGaussianSpace"/>) over the field <M>F</M>.
##  <P/>
##  If <M>V</M> is a row space then <A>B</A> is semi-echelonized if the matrix formed
##  by its basis vectors has the property that the first nonzero element in
##  each row is the identity of <M>F</M>,
##  and all values exactly below these pivot elements are the zero of <M>F</M>
##  (cf.&nbsp;<Ref Attr="SemiEchelonMat"/>).
##  <P/>
##  If <M>V</M> is a matrix space then <A>B</A> is semi-echelonized if the matrix
##  obtained by replacing each basis vector by the concatenation of its rows
##  is semi-echelonized (see above, cf.&nbsp;<Ref Oper="SemiEchelonMats"/>).
##  <Example><![CDATA[
##  gap> V:= GF(2)^2;;
##  gap> B1:= Basis( V, [ [ 0, 1 ], [ 1, 0 ] ] * Z(2) );;
##  gap> IsSemiEchelonized( B1 );
##  true
##  gap> B2:= Basis( V, [ [ 0, 1 ], [ 1, 1 ] ] * Z(2) );;
##  gap> IsSemiEchelonized( B2 );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSemiEchelonized", IsBasis );


#############################################################################
##
#A  BasisVectors( <B> )
##
##  <#GAPDoc Label="BasisVectors">
##  <ManSection>
##  <Attr Name="BasisVectors" Arg='B'/>
##
##  <Description>
##  For a vector space basis <A>B</A>, <C>BasisVectors</C> returns the list of basis
##  vectors of <A>B</A>.
##  The lists <A>B</A> and <C>BasisVectors( <A>B</A> )</C> are equal; the main purpose of
##  <C>BasisVectors</C> is to provide access to a list of vectors that does <E>not</E>
##  know about an underlying vector space.
##  <Example><![CDATA[
##  gap> V:= VectorSpace( Rationals, [ [ 1, 2, 7 ], [ 1/2, 1/3, 5 ] ] );;
##  gap> B:= Basis( V, [ [ 1, 2, 7 ], [ 0, 1, -9/4 ] ] );;
##  gap> BasisVectors( B );
##  [ [ 1, 2, 7 ], [ 0, 1, -9/4 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "BasisVectors", IsBasis );


#############################################################################
##
#A  EnumeratorByBasis( <B> )
##
##  <#GAPDoc Label="EnumeratorByBasis">
##  <ManSection>
##  <Attr Name="EnumeratorByBasis" Arg='B'/>
##
##  <Description>
##  For a basis <A>B</A> of the free left <M>F</M>-module <M>V</M> of dimension <M>n</M>,
##  <C>EnumeratorByBasis</C> returns an enumerator that loops over the elements of
##  <M>V</M> as linear combinations of the vectors of <A>B</A> with coefficients the
##  row vectors in the full row space (see&nbsp;<Ref Func="FullRowSpace"/>) of dimension <M>n</M>
##  over <M>F</M>, in the succession given by the default enumerator of this row
##  space.
##  <Example><![CDATA[
##  gap> V:= GF(2)^3;;
##  gap> enum:= EnumeratorByBasis( CanonicalBasis( V ) );;
##  gap> Print( enum{ [ 1 .. 4 ] }, "\n" );
##  [ [ 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), 0*Z(2), Z(2)^0 ],
##    [ 0*Z(2), Z(2)^0, 0*Z(2) ], [ 0*Z(2), Z(2)^0, Z(2)^0 ] ]
##  gap> B:= Basis( V, [ [ 1, 1, 1 ], [ 1, 1, 0 ], [ 1, 0, 0 ] ] * Z(2) );;
##  gap> enum:= EnumeratorByBasis( B );;
##  gap> Print( enum{ [ 1 .. 4 ] }, "\n" );
##  [ [ 0*Z(2), 0*Z(2), 0*Z(2) ], [ Z(2)^0, 0*Z(2), 0*Z(2) ],
##    [ Z(2)^0, Z(2)^0, 0*Z(2) ], [ 0*Z(2), Z(2)^0, 0*Z(2) ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "EnumeratorByBasis", IsBasis );


#############################################################################
##
#A  StructureConstantsTable( <B> )
##
##  <#GAPDoc Label="StructureConstantsTable">
##  <ManSection>
##  <Attr Name="StructureConstantsTable" Arg='B'/>
##
##  <Description>
##  Let <A>B</A> be a basis of a free left module <M>R</M>
##  that is also a ring.
##  In this case <Ref Attr="StructureConstantsTable"/> returns
##  a structure constants table <M>T</M> in sparse representation,
##  as used for structure constants algebras
##  (see Section&nbsp;<Ref Sect="Algebras" BookName="tut"/>
##  of the &GAP; User's Tutorial).
##  <P/>
##  If <A>B</A> has length <M>n</M> then <M>T</M> is a list of length
##  <M>n+2</M>.
##  The first <M>n</M> entries of <M>T</M> are lists of length <M>n</M>.
##  <M>T[ n+1 ]</M> is one of <M>1</M>, <M>-1</M>, or <M>0</M>;
##  in the case of <M>1</M> the table is known to be symmetric,
##  in the case of <M>-1</M> it is known to be antisymmetric,
##  and <M>0</M> occurs in all other cases.
##  <M>T[ n+2 ]</M> is the zero element of the coefficient domain.
##  <P/>
##  The coefficients w.r.t.&nbsp;<A>B</A> of the product of the <M>i</M>-th
##  and <M>j</M>-th basis vector of <A>B</A> are stored in <M>T[i][j]</M>
##  as a list of length <M>2</M>;
##  its first entry is the list of positions of nonzero coefficients,
##  the second entry is the list of these coefficients themselves.
##  <P/>
##  The multiplication in an algebra <M>A</M> with vector space basis
##  <A>B</A> with basis vectors <M>[ v_1, \ldots, v_n ]</M>
##  is determined by the so-called structure matrices
##  <M>M_k = [ m_{ijk} ]_{ij}</M>, <M>1 \leq k \leq n</M>.
##  The <M>M_k</M> are defined by <M>v_i v_j = \sum_k m_{ijk} v_k</M>.
##  Let <M>a = [ a_1, \ldots, a_n ]</M> and <M>b = [ b_1, \ldots, b_n ]</M>.
##  Then
##  <Display Mode="M">
##  \left( \sum_i a_i v_i \right) \left( \sum_j b_j v_j \right)
##     = \sum_{{i,j}} a_i b_j \left( v_i v_j \right)
##     = \sum_k \left( \sum_j \left( \sum_i a_i m_{ijk} \right) b_j \right) v_k
##     = \sum_k \left( a M_k b^{tr} \right) v_k.
##  </Display>
##  <P/>
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );;
##  gap> StructureConstantsTable( Basis( A ) );
##  [ [ [ [ 1 ], [ 1 ] ], [ [ 2 ], [ 1 ] ], [ [ 3 ], [ 1 ] ],
##        [ [ 4 ], [ 1 ] ] ],
##    [ [ [ 2 ], [ 1 ] ], [ [ 1 ], [ -1 ] ], [ [ 4 ], [ 1 ] ],
##        [ [ 3 ], [ -1 ] ] ],
##    [ [ [ 3 ], [ 1 ] ], [ [ 4 ], [ -1 ] ], [ [ 1 ], [ -1 ] ],
##        [ [ 2 ], [ 1 ] ] ],
##    [ [ [ 4 ], [ 1 ] ], [ [ 3 ], [ 1 ] ], [ [ 2 ], [ -1 ] ],
##        [ [ 1 ], [ -1 ] ] ], 0, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "StructureConstantsTable", IsBasis );


#############################################################################
##
#A  UnderlyingLeftModule( <B> )
##
##  <#GAPDoc Label="UnderlyingLeftModule">
##  <ManSection>
##  <Attr Name="UnderlyingLeftModule" Arg='B'/>
##
##  <Description>
##  For a basis <A>B</A> of a free left module <M>V</M>,
##  <Ref Attr="UnderlyingLeftModule"/> returns <M>V</M>.
##  <P/>
##  The reason why a basis stores a free left module is that otherwise one
##  would have to store the basis vectors and the coefficient domain
##  separately.
##  Storing the module allows one for example to deal with bases whose basis
##  vectors have not yet been computed yet (see&nbsp;<Ref Attr="Basis"/>);
##  furthermore, in some cases it is convenient to test membership of a
##  vector in the module before computing coefficients w.r.t.&nbsp;a basis.
##  <!-- this happens for example for finite fields and cyclotomic fields-->
##  <Example><![CDATA[
##  gap> B:= Basis( GF(2)^6 );;  UnderlyingLeftModule( B );
##  ( GF(2)^6 )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "UnderlyingLeftModule", IsBasis );


#############################################################################
##
#O  Coefficients( <B>, <v> )  . . . coefficients of <v> w.r. to the basis <B>
##
##  <#GAPDoc Label="Coefficients">
##  <ManSection>
##  <Oper Name="Coefficients" Arg='B, v'/>
##
##  <Description>
##  Let <M>V</M> be the underlying left module of the basis <A>B</A>, and <A>v</A> a vector
##  such that the family of <A>v</A> is the elements family of the family of <M>V</M>.
##  Then <C>Coefficients( <A>B</A>, <A>v</A> )</C> is the list of coefficients of <A>v</A> w.r.t.
##  <A>B</A> if <A>v</A> lies in <M>V</M>, and <K>fail</K> otherwise.
##  <Example><![CDATA[
##  gap> V:= VectorSpace( Rationals, [ [ 1, 2, 7 ], [ 1/2, 1/3, 5 ] ] );;
##  gap> B:= Basis( V, [ [ 1, 2, 7 ], [ 0, 1, -9/4 ] ] );;
##  gap> Coefficients( B, [ 1/2, 1/3, 5 ] );
##  [ 1/2, -2/3 ]
##  gap> Coefficients( B, [ 1, 0, 0 ] );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Coefficients", [ IsBasis, IsVector ] );


#############################################################################
##
#O  LinearCombination( <B>, <coeff> ) . . . .  linear combination w. r.t. <B>
##
##  <#GAPDoc Label="LinearCombination">
##  <ManSection>
##  <Oper Name="LinearCombination" Arg='B, coeff'/>
##
##  <Description>
##  If <A>B</A> is a basis object (see <Ref Filt="IsBasis"/>)
##  or a homogeneous list of length <M>n</M>,
##  and <A>coeff</A> is a row vector of the same length,
##  <Ref Oper="LinearCombination"/> returns the vector
##  <M>\sum_{{i = 1}}^n <A>coeff</A>[i] * <A>B</A>[i]</M>.
##  <P/>
##  Perhaps the most important usage is the case where <A>B</A> forms a
##  basis.
##  <Example><![CDATA[
##  gap> V:= VectorSpace( Rationals, [ [ 1, 2, 7 ], [ 1/2, 1/3, 5 ] ] );;
##  gap> B:= Basis( V, [ [ 1, 2, 7 ], [ 0, 1, -9/4 ] ] );;
##  gap> LinearCombination( B, [ 1/2, -2/3 ] );
##  [ 1/2, 1/3, 5 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LinearCombination",
    [ IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#O  SiftedVector( <B>, <v> ) . . . . . . residuum of <v> w.r.t. the basis <B>
##
##  <#GAPDoc Label="SiftedVector">
##  <ManSection>
##  <Oper Name="SiftedVector" Arg='B, v'/>
##
##  <Description>
##  Let <A>B</A> be a semi-echelonized basis (see&nbsp;<Ref Prop="IsSemiEchelonized"/>) of a
##  Gaussian row or matrix space <M>V</M> (see&nbsp;<Ref Filt="IsGaussianSpace"/>),
##  and <A>v</A> a row vector or matrix, respectively, of the same dimension as
##  the elements in <M>V</M>.
##  <C>SiftedVector</C> returns the <E>residuum</E> of <A>v</A> with respect to <A>B</A>, which
##  is obtained by successively cleaning the pivot positions in <A>v</A> by
##  subtracting multiples of the basis vectors in <A>B</A>.
##  So the result is the zero vector in <M>V</M> if and only if <A>v</A> lies in <M>V</M>.
##  <P/>
##  <A>B</A> may also be a mutable basis (see&nbsp;<Ref Sect="Mutable Bases"/>) of a Gaussian row
##  or matrix space.
##  <Example><![CDATA[
##  gap> V:= VectorSpace( Rationals, [ [ 1, 2, 7 ], [ 1/2, 1/3, 5 ] ] );;
##  gap> B:= Basis( V );;
##  gap> SiftedVector( B, [ 1, 2, 8 ] );
##  [ 0, 0, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "SiftedVector", [ IsBasis, IsVector ] );


#############################################################################
##
#O  IteratorByBasis( <B> )
##
##  <#GAPDoc Label="IteratorByBasis">
##  <ManSection>
##  <Oper Name="IteratorByBasis" Arg='B'/>
##
##  <Description>
##  For a basis <A>B</A> of the free left <M>F</M>-module <M>V</M> of dimension <M>n</M>,
##  <C>IteratorByBasis</C> returns an iterator that loops over the elements of <M>V</M>
##  as linear combinations of the vectors of <A>B</A> with coefficients the row
##  vectors in the full row space (see&nbsp;<Ref Func="FullRowSpace"/>) of dimension <M>n</M> over
##  <M>F</M>, in the succession given by the default enumerator of this row space.
##  <Example><![CDATA[
##  gap> V:= GF(2)^3;;
##  gap> iter:= IteratorByBasis( CanonicalBasis( V ) );;
##  gap> for i in [ 1 .. 4 ] do Print( NextIterator( iter ), "\n" ); od;
##  [ 0*Z(2), 0*Z(2), 0*Z(2) ]
##  [ 0*Z(2), 0*Z(2), Z(2)^0 ]
##  [ 0*Z(2), Z(2)^0, 0*Z(2) ]
##  [ 0*Z(2), Z(2)^0, Z(2)^0 ]
##  gap> B:= Basis( V, [ [ 1, 1, 1 ], [ 1, 1, 0 ], [ 1, 0, 0 ] ] * Z(2) );;
##  gap> iter:= IteratorByBasis( B );;
##  gap> for i in [ 1 .. 4 ] do Print( NextIterator( iter ), "\n" ); od;
##  [ 0*Z(2), 0*Z(2), 0*Z(2) ]
##  [ Z(2)^0, 0*Z(2), 0*Z(2) ]
##  [ Z(2)^0, Z(2)^0, 0*Z(2) ]
##  [ 0*Z(2), Z(2)^0, 0*Z(2) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IteratorByBasis", [ IsBasis ] );


#############################################################################
##
#A  Basis( <V>[, <vectors>] )
#O  BasisNC( <V>, <vectors> )
##
##  <#GAPDoc Label="Basis">
##  <ManSection>
##  <Attr Name="Basis" Arg='V[, vectors]'/>
##  <Oper Name="BasisNC" Arg='V, vectors'/>
##
##  <Description>
##  Called with a free left <M>F</M>-module <A>V</A> as the only argument,
##  <Ref Attr="Basis"/> returns an <M>F</M>-basis of <A>V</A>
##  whose vectors are not further specified.
##  <P/>
##  If additionally a list <A>vectors</A> of vectors in <A>V</A> is given
##  that forms an <M>F</M>-basis of <A>V</A>
##  then <Ref Attr="Basis"/> returns this basis;
##  if <A>vectors</A> is not linearly independent over <M>F</M>
##  or does not generate <A>V</A> as a free left <M>F</M>-module
##  then <K>fail</K> is returned.
##  <P/>
##  <Ref Oper="BasisNC"/> does the same as the two argument version of
##  <Ref Attr="Basis"/>, except that it does not check
##  whether <A>vectors</A> form a basis.
##  <P/>
##  If no basis vectors are prescribed then <Ref Attr="Basis"/> need not
##  compute basis vectors; in this case, the vectors are computed
##  in the first call to <Ref Attr="BasisVectors"/>.
##  <Example><![CDATA[
##  gap> V:= VectorSpace( Rationals, [ [ 1, 2, 7 ], [ 1/2, 1/3, 5 ] ] );;
##  gap> B:= Basis( V );
##  SemiEchelonBasis( <vector space over Rationals, with
##  2 generators>, ... )
##  gap> BasisVectors( B );
##  [ [ 1, 2, 7 ], [ 0, 1, -9/4 ] ]
##  gap> B:= Basis( V, [ [ 1, 2, 7 ], [ 3, 2, 30 ] ] );
##  Basis( <vector space over Rationals, with 2 generators>,
##  [ [ 1, 2, 7 ], [ 3, 2, 30 ] ] )
##  gap> Basis( V, [ [ 1, 2, 3 ] ] );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Basis", IsFreeLeftModule );
DeclareOperation( "Basis", [ IsFreeLeftModule, IsHomogeneousList ] );

DeclareOperation( "BasisNC", [ IsFreeLeftModule, IsHomogeneousList ] );


#############################################################################
##
#A  SemiEchelonBasis( <V>[, <vectors>] )
#O  SemiEchelonBasisNC( <V>, <vectors> )
##
##  <#GAPDoc Label="SemiEchelonBasis">
##  <ManSection>
##  <Attr Name="SemiEchelonBasis" Arg='V[, vectors]'/>
##  <Oper Name="SemiEchelonBasisNC" Arg='V, vectors'/>
##
##  <Description>
##  Let <A>V</A> be a Gaussian row or matrix vector space over the field
##  <M>F</M> (see&nbsp;<Ref Filt="IsGaussianSpace"/>,
##  <Ref Filt="IsRowSpace"/>, <Ref Filt="IsMatrixSpace"/>).
##  <P/>
##  Called with <A>V</A> as the only argument,
##  <Ref Attr="SemiEchelonBasis"/> returns a basis of <A>V</A>
##  that has the property <Ref Prop="IsSemiEchelonized"/>.
##  <P/>
##  If additionally a list <A>vectors</A> of vectors in <A>V</A> is given
##  that forms a semi-echelonized basis of <A>V</A>
##  then <Ref Attr="SemiEchelonBasis"/> returns this basis;
##  if <A>vectors</A> do not form a basis of <A>V</A>
##  then <K>fail</K> is returned.
##  <P/>
##  <Ref Oper="SemiEchelonBasisNC"/> does the same as the two argument
##  version of <Ref Attr="SemiEchelonBasis"/>,
##  except that it is not checked whether <A>vectors</A> form
##  a semi-echelonized basis.
##  <Example><![CDATA[
##  gap> V:= GF(2)^2;;
##  gap> B:= SemiEchelonBasis( V );
##  SemiEchelonBasis( ( GF(2)^2 ), ... )
##  gap> Print( BasisVectors( B ), "\n" );
##  [ [ Z(2)^0, 0*Z(2) ], [ 0*Z(2), Z(2)^0 ] ]
##  gap> B:= SemiEchelonBasis( V, [ [ 1, 1 ], [ 0, 1 ] ] * Z(2) );
##  SemiEchelonBasis( ( GF(2)^2 ), <an immutable 2x2 matrix over GF2> )
##  gap> Print( BasisVectors( B ), "\n" );
##  [ [ Z(2)^0, Z(2)^0 ], [ 0*Z(2), Z(2)^0 ] ]
##  gap> Coefficients( B, [ 0, 1 ] * Z(2) );
##  [ 0*Z(2), Z(2)^0 ]
##  gap> Coefficients( B, [ 1, 0 ] * Z(2) );
##  [ Z(2)^0, Z(2)^0 ]
##  gap> SemiEchelonBasis( V, [ [ 0, 1 ], [ 1, 1 ] ] * Z(2) );
##  fail
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SemiEchelonBasis", IsFreeLeftModule );
DeclareOperation( "SemiEchelonBasis",
    [ IsFreeLeftModule, IsHomogeneousList ] );

DeclareOperation( "SemiEchelonBasisNC",
    [ IsFreeLeftModule, IsHomogeneousList ] );
#T In fact they should be declared for `IsGaussianSpace', or at least for
#T `IsVectorSpace', but the files containing these categories are read later ..
#T (Change this!)


#############################################################################
##
#O  RelativeBasis( <B>, <vectors> )
#O  RelativeBasisNC( <B>, <vectors> )
##
##  <#GAPDoc Label="RelativeBasis">
##  <ManSection>
##  <Oper Name="RelativeBasis" Arg='B, vectors'/>
##  <Oper Name="RelativeBasisNC" Arg='B, vectors'/>
##
##  <Description>
##  A relative basis is a basis of the free left module <A>V</A> that delegates
##  the computation of coefficients etc. to another basis of <A>V</A> via
##  a basechange matrix.
##  <P/>
##  Let <A>B</A> be a basis of the free left module <A>V</A>,
##  and <A>vectors</A> a list of vectors in <A>V</A>.
##  <P/>
##  <Ref Oper="RelativeBasis"/> checks whether <A>vectors</A> form a basis of <A>V</A>,
##  and in this case a basis is returned in which <A>vectors</A> are
##  the basis vectors; otherwise <K>fail</K> is returned.
##  <P/>
##  <Ref Oper="RelativeBasisNC"/> does the same, except that it omits the check.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RelativeBasis", [ IsBasis, IsHomogeneousList ] );
DeclareOperation( "RelativeBasisNC", [ IsBasis, IsHomogeneousList ] );


#############################################################################
##  <#GAPDoc Label="[2]{basis}">
##  There are kinds of free <M>R</M>-modules for which efficient computations
##  are possible because the elements are <Q>nice</Q>,
##  for example subspaces of full row modules or of full matrix modules.
##  In other cases, a <Q>nice</Q> canonical basis is known that allows one
##  to do the necessary computations in the corresponding row module,
##  for example algebras given by structure constants.
##  <P/>
##  In many other situations, one knows at least an isomorphism from the
##  given module <M>V</M> to a <Q>nicer</Q> free left module <M>W</M>,
##  in the sense that for each vector in <M>V</M>,
##  the image in <M>W</M> can easily be computed,
##  and analogously for each vector in <M>W</M>,
##  one can compute the preimage in <M>V</M>.
##  <P/>
##  This allows one to delegate computations w.r.t.&nbsp;a basis <M>B</M>
##  of <M>V</M> to the corresponding basis <M>C</M> of <M>W</M>.
##  We call <M>W</M> the <E>nice free left module</E> of <M>V</M>,
##  and <M>C</M> the <E>nice basis</E> of <M>B</M>.
##  (Note that it may happen that also <M>C</M> delegates questions to a
##  <Q>nicer</Q> basis.)
##  The basis <M>B</M> indicates the intended behaviour by the filter
##  <Ref Filt="IsBasisByNiceBasis"/>,
##  and stores <M>C</M> as value of the attribute <Ref Attr="NiceBasis"/>.
##  <M>V</M> indicates the intended behaviour by the filter
##  <Ref Filt="IsHandledByNiceBasis"/>, and stores <M>W</M> as value
##  of the attribute <Ref Attr="NiceFreeLeftModule"/>.
##  <P/>
##  The bijection between <M>V</M> and <M>W</M> is implemented by the
##  functions <Ref Oper="NiceVector"/> and <Ref Oper="UglyVector"/>;
##  additional data needed to compute images and preimages can be stored
##  as value of <Ref Attr="NiceFreeLeftModuleInfo"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#F  DeclareHandlingByNiceBasis( <name>, <info> )
#F  InstallHandlingByNiceBasis( <name>, <record> )
##
##  <#GAPDoc Label="DeclareHandlingByNiceBasis">
##  <ManSection>
##  <Func Name="DeclareHandlingByNiceBasis" Arg='name, info'/>
##  <Func Name="InstallHandlingByNiceBasis" Arg='name, record'/>
##
##  <Description>
##  These functions are used to implement a new kind of free left modules
##  that shall be handled via the mechanism of nice bases
##  (see&nbsp;<Ref Sect="Vector Spaces Handled By Nice Bases"/>).
##  <P/>
##  <A>name</A> must be a string,
##  a filter <M>f</M> with this name is created which implies
##  <Ref Filt="IsFreeLeftModule"/>, and
##  a logical implication from the join of <M>f</M> with
##  <Ref Filt="IsAttributeStoringRep"/> to
##  <Ref Filt="IsHandledByNiceBasis"/> is installed.
##  <P/>
##  <A>record</A> must be a record with the following components.
##  <List>
##  <Mark><C>detect</C> </Mark>
##  <Item>
##      a function of four arguments <M>R</M>, <M>l</M>, <M>V</M>, and <M>z</M>,
##      where <M>V</M> is a free left module over the ring <M>R</M> with generators
##      the list or collection <M>l</M>, and <M>z</M> is either the zero element of
##      <M>V</M> or <K>false</K> (then <M>l</M> is nonempty);
##      the function returns <K>true</K> if <M>V</M> shall lie in the filter <M>f</M>,
##      and <K>false</K> otherwise;
##      the return value may also be <K>fail</K>, which indicates that <M>V</M> is
##      <E>not</E> to be handled via the mechanism of nice bases at all,
##  </Item>
##  <Mark><C>NiceFreeLeftModuleInfo</C> </Mark>
##  <Item>
##      the <Ref Attr="NiceFreeLeftModuleInfo"/> method for left modules in
##      <M>f</M>,
##  </Item>
##  <Mark><C>NiceVector</C> </Mark>
##  <Item>
##      the <Ref Oper="NiceVector"/> method for left modules <M>V</M> in
##      <M>f</M>;
##      called with <M>V</M> and a vector <M>v \in V</M>, this function returns the
##      nice vector <M>r</M> associated with <M>v</M>, and
##  </Item>
##  <Mark><C>UglyVector</C></Mark>
##  <Item>
##      the <Ref Oper="UglyVector"/> method for left modules <M>V</M> in
##      <M>f</M>;
##      called with <M>V</M> and a vector <M>r</M> in the
##      <Ref Attr="NiceFreeLeftModule"/> value of <M>V</M>,
##      this function returns the vector <M>v \in V</M> to which <M>r</M> is
##      associated.
##  </Item>
##  </List>
##  <P/>
##  The idea is that all one has to do for implementing a new kind of free
##  left modules handled by the mechanism of nice bases is to call
##  <Ref Func="DeclareHandlingByNiceBasis"/> and
##  <Ref Func="InstallHandlingByNiceBasis"/>,
##  which causes the installation of the necessary methods and adds the pair
##  <M>[ f, </M><A>record</A><C>.detect</C><M> ]</M> to the global list
##  <Ref Var="NiceBasisFiltersInfo"/>.
##  The <Ref Oper="LeftModuleByGenerators"/> methods call
##  <Ref Func="CheckForHandlingByNiceBasis"/>, which sets the appropriate filter
##  for the desired left module if applicable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DeclareHandlingByNiceBasis" );
DeclareGlobalFunction( "InstallHandlingByNiceBasis" );


#############################################################################
##
#V  NiceBasisFiltersInfo
##
##  <#GAPDoc Label="NiceBasisFiltersInfo">
##  <ManSection>
##  <Var Name="NiceBasisFiltersInfo"/>
##
##  <Description>
##  An overview of all kinds of vector spaces that are currently handled by
##  nice bases is given by the global list <C>NiceBasisFiltersInfo</C>.
##  Examples of such vector spaces are vector spaces of field elements
##  (but not the fields themselves) and non-Gaussian row and matrix spaces
##  (see&nbsp;<Ref Filt="IsGaussianSpace"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal( "NiceBasisFiltersInfo", [] );


#############################################################################
##
#F  CheckForHandlingByNiceBasis( <R>, <gens>, <M>, <zero> )
##
##  <#GAPDoc Label="CheckForHandlingByNiceBasis">
##  <ManSection>
##  <Func Name="CheckForHandlingByNiceBasis" Arg='R, gens, M, zero'/>
##
##  <Description>
##  Whenever a free left module is constructed for which the filter
##  <C>IsHandledByNiceBasis</C> may be useful,
##  <C>CheckForHandlingByNiceBasis</C> should be called.
##  (This is done in the methods for <C>VectorSpaceByGenerators</C>,
##  <C>AlgebraByGenerators</C>, <C>IdealByGenerators</C> etc.&nbsp;in the &GAP; library.)
##  <P/>
##  The arguments of this function are the coefficient ring <A>R</A>, the list
##  <A>gens</A> of generators, the constructed module <A>M</A> itself, and the zero
##  element <A>zero</A> of <A>M</A>;
##  if <A>gens</A> is nonempty then the <A>zero</A> value may also be <K>false</K>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CheckForHandlingByNiceBasis" );


InstallGlobalFunction( "DeclareHandlingByNiceBasis", function( name, info )
    local entry;
    DeclareFilter( name );
    InstallTrueMethod( IsFreeLeftModule, ValueGlobal( name ) );
    entry := [ ValueGlobal( name ), info ];
    Add( NiceBasisFiltersInfo, entry, 1 );
end );

#############################################################################
##
#F  IsGenericFiniteSpace( <V> )
##
##  <ManSection>
##  <Func Name="IsGenericFiniteSpace" Arg='V'/>
##
##  <Description>
##  If an <M>F</M>-vector space <A>V</A> is in the filter
##  <Ref Filt="IsGenericFiniteSpace"/> then this expresses that <A>V</A>
##  consists of elements in a <E>finite</E> vector space,
##  and that <A>V</A> is handled via the mechanism of nice bases
##  (see&nbsp;<Ref ???="..."/>)
##  in the following way.
##  (This is the generic treatment of finite vector spaces, better methods
##  are installed for various special kinds of finite vector spaces.)
##  Let <M>F</M> be of order <M>q</M>, <M>e_F</M> a list of the elements of
##  <M>F</M>,
##  <M>B = [ b_0, b_1, \ldots, b_k ]</M> be an <M>F</M>-basis of <M>V</M>,
##  and let <M>e_V</M> be a list of elements of <M>V</M> with the property
##  that
##  <M>e_V[ 1 + \sum_{i=0}^k c_i q^i ] = \sum_{i=0}^k e_F[ c_i + 1 ] b_i</M>
##  holds;
##  then the <Ref Func="NiceVector"/> value of
##  <M>e_V[ 1 + \sum_{i=0}^k c_i q^i ]</M> is the row vector
##  <M>[ r_0, r_1, \ldots, r_k ]</M> with <M>r_i = e_F[ c_i + 1 ]</M>,
##  and the <Ref Func="UglyVector"/> value of
##  <M>[ r_0, r_1, \ldots, r_k ]</M> is <M>\sum_{i=0}^k r_i b_i</M>.
##  <P/>
##  The <Ref Func="NiceFreeLeftModuleInfo"/> value of <M>V</M> is a record
##  with the following components.
##  <List>
##  <Mark><C>elements</C>:</Mark>
##  <Item>
##     a <E>strictly sorted</E> list <M>\tilde{e}_V</M> of elements of
##     <M>V</M>,
##  </Item>
##  <Mark><C>numbers</C>:</Mark>
##  <Item>
##     a list <M>l</M> of the positive integers up to <M>q^{k+1}</M>,
##     such that <M>e_V[ l[i] ] = \tilde{e}_V[i]</M> holds for
##     <M>1 \leq i \leq q^{k+1}</M>.
##  </Item>
##  <Mark><C>q</C>:</Mark>
##  <Item>
##     the size of <M>F</M>,
##  </Item>
##  <Mark><C>fieldelements</C>:</Mark>
##  <Item>
##     the list <M>e_F</M>,
##  </Item>
##  <Mark><C>base</C>:</Mark>
##  <Item>
##     the list <M>B</M>.
##  </Item>
##  </List>
##  <!-- use that the nice module is a full row space!-->
##  <!-- (special method for NiceFreeLeftModule?)-->
##  <!--  It is important that all other filters of this kind are installed <E>later</E>-->
##  <!--  because otherwise the generic treatment may be chosen in cases for which-->
##  <!--  a later filter indicates better methods.-->
##  </Description>
##  </ManSection>
##
DeclareHandlingByNiceBasis( "IsGenericFiniteSpace",
    "for finite vector spaces (generic)" );


#############################################################################
##
#F  IsSpaceOfRationalFunctions( <V> )
##
##  <ManSection>
##  <Func Name="IsSpaceOfRationalFunctions" Arg='V'/>
##
##  <Description>
##  If an <M>F</M>-vector space <A>V</A> is in the filter <C>IsSpaceOfRationalFunctions</C>
##  then this expresses that <A>V</A> consists of rational functions,
##  and that <A>V</A> is handled via the mechanism of nice bases in the following
##  way.
##  Let <M>v_1, v_2, \ldots, v_k</M> be vector space generators of <A>V</A>,
##  let <M>d</M> be a polynomial such that all <M>d \cdot v_i</M> are polynomials,
##  and let <M>S</M> be the set of monomials that occur in these polynomials.
##  Then the <C>NiceFreeLeftModuleInfo</C> value of <A>V</A> is a record with the
##  following components.
##  <List>
##  <Mark><C>family</C> </Mark>
##  <Item>
##     the elements family of <A>V</A>,
##  </Item>
##  <Mark><C>monomials</C> </Mark>
##  <Item>
##     the list <M>S</M>,
##  </Item>
##  <Mark><C>denom</C> </Mark>
##  <Item>
##     the polynomial <M>d</M>,
##  </Item>
##  <Mark><C>zerocoeff</C> </Mark>
##  <Item>
##     the zero coefficient of elements in <A>V</A>,
##  </Item>
##  <Mark><C>zerovector</C> </Mark>
##  <Item>
##     the zero row vector in the nice free left module.
##  </Item>
##  </List>
##  The <C>NiceVector</C> value of <M>v \in <A>V</A></M> is defined as the row vector of
##  coefficients of <M>v</M> w.r.t.&nbsp;<M>S</M>.
##  <P/>
##  Finite dimensional free left modules of rational functions
##  are by default handled via the mechanism of nice bases.
##  </Description>
##  </ManSection>
##
DeclareHandlingByNiceBasis( "IsSpaceOfRationalFunctions",
    "for free left modules of rational functions" );


#############################################################################
##
#C  IsBasisByNiceBasis( <B> )
##
##  <#GAPDoc Label="IsBasisByNiceBasis">
##  <ManSection>
##  <Filt Name="IsBasisByNiceBasis" Arg='B' Type='Category'/>
##
##  <Description>
##  This filter indicates that the basis <A>B</A> delegates tasks such as the
##  computation of coefficients (see&nbsp;<Ref Oper="Coefficients"/>) to a basis of an
##  isomorphic <Q>nicer</Q> free left module.
##  <!--  Any object in <C>IsBasisByNiceBasis</C> must be a <E>small</E> list in the sense of-->
##  <!--  <Ref Prop="IsSmallList"/>.-->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsBasisByNiceBasis", IsBasis and IsSmallList );


#############################################################################
##
#A  NiceBasis( <B> )
##
##  <#GAPDoc Label="NiceBasis">
##  <ManSection>
##  <Attr Name="NiceBasis" Arg='B'/>
##
##  <Description>
##  Let <A>B</A> be a basis of a free left module <A>V</A> that is handled via
##  nice bases.
##  If <A>B</A> has no basis vectors stored at the time of the first call to
##  <C>NiceBasis</C> then <C>NiceBasis( <A>B</A> )</C> is obtained as
##  <C>Basis( NiceFreeLeftModule( <A>V</A> ) )</C>.
##  If basis vectors are stored then <C>NiceBasis( <A>B</A> )</C> is the result of the
##  call of <C>Basis</C> with arguments <C>NiceFreeLeftModule( <A>V</A> )</C>
##  and the <C>NiceVector</C> values of the basis vectors of <A>B</A>.
##  <P/>
##  Note that the result is <K>fail</K> if and only if the <Q>basis vectors</Q>
##  stored in <A>B</A> are in fact not basis vectors.
##  <P/>
##  The attributes <C>GeneratorsOfLeftModule</C> of the underlying left modules
##  of <A>B</A> and the result of <C>NiceBasis</C> correspond via <Ref Oper="NiceVector"/> and
##  <Ref Oper="UglyVector"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NiceBasis", IsBasisByNiceBasis );


#############################################################################
##
#O  NiceBasisNC( <B> )
##
##  <ManSection>
##  <Oper Name="NiceBasisNC" Arg='B'/>
##
##  <Description>
##  If the basis <A>B</A> has basis vectors bound then the attribute <C>NiceBasis</C>
##  of <A>B</A> is set to <C>BasisNC( <A>W</A>, <A>nice</A> )</C>
##  where <A>W</A> is the value of <C>NiceFreeLeftModule</C> for the underlying
##  free left module of <A>B</A>.
##  This means that it is <E>not</E> checked whether <A>B</A> really is a basis.
##  </Description>
##  </ManSection>
##
DeclareOperation( "NiceBasisNC", [ IsBasisByNiceBasis ] );


#############################################################################
##
#A  NiceFreeLeftModule( <V> ) . . . . nice free left module isomorphic to <V>
##
##  <#GAPDoc Label="NiceFreeLeftModule">
##  <ManSection>
##  <Attr Name="NiceFreeLeftModule" Arg='V'/>
##
##  <Description>
##  For a free left module <A>V</A> that is handled via the mechanism of nice
##  bases, this attribute stores the associated free left module to which the
##  tasks are delegated.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NiceFreeLeftModule", IsFreeLeftModule );


#############################################################################
##
#A  NiceFreeLeftModuleInfo( <V> )
##
##  <#GAPDoc Label="NiceFreeLeftModuleInfo">
##  <ManSection>
##  <Attr Name="NiceFreeLeftModuleInfo" Arg='V'/>
##
##  <Description>
##  For a free left module <A>V</A> that is handled via the mechanism of nice
##  bases, this operation has to provide the necessary information (if any)
##  for calls of <Ref Oper="NiceVector"/> and <Ref Oper="UglyVector"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NiceFreeLeftModuleInfo",
    IsFreeLeftModule and IsHandledByNiceBasis );


#############################################################################
##
#O  NiceVector( <V>, <v> )
#O  UglyVector( <V>, <r> )
##
##  <#GAPDoc Label="NiceVector">
##  <ManSection>
##  <Oper Name="NiceVector" Arg='V, v'/>
##  <Oper Name="UglyVector" Arg='V, r'/>
##
##  <Description>
##  <Ref Oper="NiceVector"/> and <Ref Oper="UglyVector"/> provide the linear bijection between the
##  free left module <A>V</A> and <C><A>W</A>:= NiceFreeLeftModule( <A>V</A> )</C>.
##  <P/>
##  If <A>v</A> lies in the elements family of the family of <A>V</A> then
##  <C>NiceVector( <A>v</A> )</C> is either <K>fail</K> or an element in the elements family
##  of the family of <A>W</A>.
##  <P/>
##  If <A>r</A> lies in the elements family of the family of <A>W</A> then
##  <C>UglyVector( <A>r</A> )</C> is either <K>fail</K> or an element in the elements family
##  of the family of <A>V</A>.
##  <P/>
##  If <A>v</A> lies in <A>V</A> (which usually <E>cannot</E> be checked without using <A>W</A>)
##  then <C>UglyVector( <A>V</A>, NiceVector( <A>V</A>, <A>v</A> ) ) = <A>v</A></C>.
##  If <A>r</A> lies in <A>W</A> (which usually <E>can</E> be checked)
##  then <C>NiceVector( <A>V</A>, UglyVector( <A>V</A>, <A>r</A> ) ) = <A>r</A></C>.
##  <P/>
##  (This allows one to implement for example a membership test for <A>V</A>
##  using the membership test in <A>W</A>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NiceVector",
    [ IsFreeLeftModule and IsHandledByNiceBasis, IsObject ] );

DeclareOperation( "UglyVector",
    [ IsFreeLeftModule and IsHandledByNiceBasis, IsObject ] );


#############################################################################
##
#F  BasisWithReplacedLeftModule( <B>, <V> )
##
##  <ManSection>
##  <Func Name="BasisWithReplacedLeftModule" Arg='B, V'/>
##
##  <Description>
##  For a basis <A>B</A> and a left module <A>V</A> that is equal to the underlying
##  left module of <A>B</A>,
##  <C>BasisWithReplacedLeftModule</C> returns a basis equal to <A>B</A> except that
##  the underlying left module of this basis is <A>V</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "BasisWithReplacedLeftModule" );
