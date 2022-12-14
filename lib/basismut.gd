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
##  This file declares the categories and operations for mutable bases.
##  <#GAPDoc Label="[1]{basismut}">
##  It is useful to have a <E>mutable basis</E> of a free module when successively
##  closures with new vectors are formed, since one does not want to create
##  a new module and a corresponding basis for each step.
##  <P/>
##  Note that the situation here is different from the situation with
##  stabilizer chains, which are (mutable or immutable) records that do not
##  need to know about the groups they describe,
##  whereas each (immutable) basis stores the underlying left module
##  (see&nbsp;<Ref Attr="UnderlyingLeftModule"/>).
##  <P/>
##  So immutable bases and mutable bases are different categories of objects.
##  The only thing they have in common is that one can ask both for
##  their basis vectors and for the coefficients of a given vector.
##  <P/>
##  Since <C>Immutable</C> produces an immutable copy of any &GAP; object,
##  it would in principle be possible to construct a mutable basis that
##  is in fact immutable.
##  In the sequel, we will deal only with mutable bases that are in fact
##  <E>mutable</E> &GAP; objects,
##  hence these objects are unable to store attribute values.
##  <P/>
##  Basic operations for immutable bases are
##  <Ref Oper="NrBasisVectors"/>, <Ref Oper="IsContainedInSpan"/>,
##  <Ref Oper="CloseMutableBasis"/>,
##  <Ref Oper="ImmutableBasis"/>,
##  <Ref Oper="Coefficients"/>, and <Ref Attr="BasisVectors"/>.
##  <Ref Oper="ShallowCopy"/> for a mutable basis returns a mutable
##  plain list containing the current basis vectors.
##  <!-- Also <Ref Attr="LeftActingDomain"/> (or the analogy for it) should be a basic-->
##  <!-- operation; up to now, apparently one can avoid it,-->
##  <!-- but conceptually it should be available!-->
##  <P/>
##  Since mutable bases do not admit arbitrary changes of their lists of
##  basis vectors, a mutable basis is <E>not</E> a list.
##  It is, however, a collection, more precisely its family (see&nbsp;<Ref Sect="Families"/>)
##  equals the family of its collection of basis vectors.
##  <P/>
##  Mutable bases can be constructed with <C>MutableBasis</C>.
##  <P/>
##  Similar to the situation with bases (cf.&nbsp;<Ref Sect="Bases of Vector Spaces"/>),
##  &GAP; supports the following three kinds of mutable bases.
##  <P/>
##  The <E>generic method</E> of <C>MutableBasis</C> returns a mutable basis that
##  simply stores an immutable basis;
##  clearly one wants to avoid this whenever possible with reasonable effort.
##  <P/>
##  There are mutable bases that store a mutable basis for a nicer module.
##  <!--  This works if we have access to the mechanism of computing nice vectors,-->
##  <!--  and requires the construction with-->
##  <!--  <C>MutableBasisViaNiceMutableBasisMethod2</C> or-->
##  <!--  <C>MutableBasisViaNiceMutableBasisMethod3</C>!-->
##  Note that this is meaningful only if the mechanism of computing nice and
##  ugly vectors (see&nbsp;<Ref Sect="Vector Spaces Handled By Nice Bases"/>) is invariant
##  under closures of the basis;
##  this is the case for example if the vectors are matrices, Lie objects,
##  or elements of structure constants algebras.
##  <P/>
##  There are mutable bases that use special information to perform their
##  tasks; examples are mutable bases of Gaussian row and matrix spaces.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsMutableBasis( <MB> )
##
##  <#GAPDoc Label="IsMutableBasis">
##  <ManSection>
##  <Filt Name="IsMutableBasis" Arg='MB' Type='Category'/>
##
##  <Description>
##  Every mutable basis lies in the category <C>IsMutableBasis</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsMutableBasis", IsObject );


#############################################################################
##
#O  MutableBasis( <R>, <vectors>[, <zero>] )
##
##  <#GAPDoc Label="MutableBasis">
##  <ManSection>
##  <Oper Name="MutableBasis" Arg='R, vectors[, zero]'/>
##
##  <Description>
##  <C>MutableBasis</C> returns a mutable basis for the <A>R</A>-free module generated
##  by the vectors in the list <A>vectors</A>.
##  The optional argument <A>zero</A> is the zero vector of the module;
##  it must be given if <A>vectors</A> is empty.
##  <P/>
##  <E>Note</E> that <A>vectors</A> will in general <E>not</E> be the basis vectors of the
##  mutable basis!
##  <!-- provide <C>AddBasisVector</C> to achieve this?-->
##  <Example><![CDATA[
##  gap> MB:= MutableBasis( Rationals, [ [ 1, 2, 3 ], [ 0, 1, 0 ] ] );
##  <mutable basis over Rationals, 2 vectors>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MutableBasis", [ IsRing, IsCollection ] );


#############################################################################
##
#F  MutableBasisViaNiceMutableBasisMethod2( <R>, <vectors> )
#F  MutableBasisViaNiceMutableBasisMethod3( <R>, <vectors>, <zero> )
##
##  <ManSection>
##  <Func Name="MutableBasisViaNiceMutableBasisMethod2" Arg='R, vectors'/>
##  <Func Name="MutableBasisViaNiceMutableBasisMethod3" Arg='R, vectors, zero'/>
##
##  <Description>
##  Let <M>M</M> be the <A>R</A>-free left module generated by the vectors in the list
##  <A>vectors</A>, and assume that <M>M</M> is handled via nice bases.
##  <C>MutableBasisViaNiceMutableBasisMethod?</C> returns a mutable basis for <M>M</M>.
##  The optional argument <A>zero</A> is the zero vector of the module.
##  <P/>
##  <E>Note</E> that <M>M</M> is stored, and that it is used in calls to <C>NiceVector</C>
##  and <C>UglyVector</C>, and for accessing <A>R</A>.
##  (See the remark in the beginning of the file.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "MutableBasisViaNiceMutableBasisMethod2" );

DeclareGlobalFunction( "MutableBasisViaNiceMutableBasisMethod3" );


#############################################################################
##
#O  NrBasisVectors( <MB> )
##
##  <#GAPDoc Label="NrBasisVectors">
##  <ManSection>
##  <Oper Name="NrBasisVectors" Arg='MB'/>
##
##  <Description>
##  For a mutable basis <A>MB</A>, <C>NrBasisVectors</C> returns the current number of
##  basis vectors of <A>MB</A>.
##  Note that this operation is <E>not</E> an attribute, as it makes no sense to
##  store the value.
##  <C>NrBasisVectors</C> is used mainly as an equivalent of <C>Dimension</C> for the
##  underlying left module in the case of immutable bases.
##  <Example><![CDATA[
##  gap> MB:= MutableBasis( Rationals, [ [ 1, 1], [ 2, 2 ] ] );;
##  gap> NrBasisVectors( MB );
##  1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "NrBasisVectors", [ IsMutableBasis ] );


#############################################################################
##
#O  ImmutableBasis( <MB>[, <V>] )
##
##  <#GAPDoc Label="ImmutableBasis">
##  <ManSection>
##  <Oper Name="ImmutableBasis" Arg='MB[, V]'/>
##
##  <Description>
##  <Ref Oper="ImmutableBasis"/> returns the immutable basis <M>B</M>
##  with the same basis vectors as in the mutable basis <A>MB</A>.
##  <P/>
##  If the second argument <A>V</A> is present then <A>V</A> is the value of
##  <Ref Attr="UnderlyingLeftModule"/> for <M>B</M>.
##  The second variant is used mainly for the case that one knows the module
##  for the desired basis in advance, and if it has a nicer structure than
##  the module known to <A>MB</A>, for example if it is an algebra.
##  <!--  This happens for example if one constructs a basis of an ideal using-->
##  <!--  iterated closures of a mutable basis, and the final basis <M>B</M> shall-->
##  <!--  have the initial ideal as underlying module.-->
##  <Example><![CDATA[
##  gap> MB:= MutableBasis( Rationals, [ [ 1, 1 ], [ 2, 2 ] ] );;
##  gap> B:= ImmutableBasis( MB );
##  SemiEchelonBasis( <vector space of dimension 1 over Rationals>,
##  [ [ 1, 1 ] ] )
##  gap> UnderlyingLeftModule( B );
##  <vector space of dimension 1 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ImmutableBasis", [ IsMutableBasis ] );

DeclareOperation( "ImmutableBasis", [ IsMutableBasis, IsFreeLeftModule ] );


#############################################################################
##
#O  CloseMutableBasis( <MB>, <v> )
##
##  <#GAPDoc Label="CloseMutableBasis">
##  <ManSection>
##  <Oper Name="CloseMutableBasis" Arg='MB, v'/>
##
##  <Description>
##  For a mutable basis <A>MB</A> over the coefficient ring <M>R</M>
##  and a vector <A>v</A>, <Ref Oper="CloseMutableBasis"/> changes <A>MB</A>
##  such that afterwards it describes the <M>R</M>-span of the former
##  basis vectors together with <A>v</A>.
##  <P/>
##  <E>Note</E> that if <A>v</A> enlarges the dimension then this does in general <E>not</E>
##  mean that <A>v</A> is simply added to the basis vectors of <A>MB</A>.
##  Usually a linear combination of <A>v</A> and the other basis vectors is added,
##  and also the old basis vectors may be modified, for example in order to
##  keep the list of basis vectors echelonized
##  (see&nbsp;<Ref Prop="IsSemiEchelonized"/>).
##  <P/>
##  <Ref Oper="CloseMutableBasis"/> returns <K>false</K> if <A>v</A> was
##  already in the <M>R</M>-span described by <A>MB</A>,
##  and <K>true</K> if <A>MB</A> got extended.
##  <Example><![CDATA[
##  gap> MB:= MutableBasis( Rationals, [ [ 1, 1, 3 ], [ 2, 2, 1 ] ] );
##  <mutable basis over Rationals, 2 vectors>
##  gap> IsContainedInSpan( MB, [ 1, 0, 0 ] );
##  false
##  gap> CloseMutableBasis( MB, [ 1, 0, 0 ] );
##  true
##  gap> MB;
##  <mutable basis over Rationals, 3 vectors>
##  gap> IsContainedInSpan( MB, [ 1, 0, 0 ] );
##  true
##  gap> CloseMutableBasis( MB, [ 1, 0, 0 ] );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CloseMutableBasis",
    [ IsMutableBasis and IsMutable, IsVector ] );


#############################################################################
##
#O  IsContainedInSpan( <MB>, <v> )
##
##  <#GAPDoc Label="IsContainedInSpan">
##  <ManSection>
##  <Oper Name="IsContainedInSpan" Arg='MB, v'/>
##
##  <Description>
##  For a mutable basis <A>MB</A> over the coefficient ring <M>R</M>
##  and a vector <A>v</A>, <C>IsContainedInSpan</C> returns <K>true</K> is <A>v</A> lies in the
##  <M>R</M>-span of the current basis vectors of <A>MB</A>,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsContainedInSpan", [ IsMutableBasis, IsVector ] );
