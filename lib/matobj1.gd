#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##


############################################################################
##
##  This file together with 'matobj2.gd' formally define the interface to
##  those vector and matrix objects in GAP that are not represented
##  by plain lists.
##  In this file the categories are defined, it is read earlier in the
##  GAP library reading process.
##


#############################################################################
##
##  <#GAPDoc Label="IsVectorObj">
##  <ManSection>
##  <Filt Name="IsVectorObj" Arg='obj' Type="category"/>
##
##  <Description>
##  <P/>
##  The idea behind <E>vector objects</E> is that one wants to deal with
##  objects like coefficient lists of fixed length over a given domain
##  <M>R</M>, say, which can be added and can be multiplied from the left
##  with elements from <M>R</M>.
##  A vector object <M>v</M>, say, is always a copyable object
##  (see <Ref Filt="IsCopyable"/>) in <Ref Filt="IsVector"/>,
##  which knows the values of
##  <Ref Attr="BaseDomain" Label="for a vector object"/>
##  (with value <M>R</M>) and
##  <Ref Attr="Length"/>,
##  where <M>R</M> is a domain (see Chapter <Ref Chap="Domains"/>)
##  that has methods for
##  <Ref Attr="Zero"/>,
##  <Ref Attr="One"/>,
##  <Ref Oper="\in" Label="for a collection"/>,
##  <Ref Attr="Characteristic"/>,
##  <Ref Prop="IsFinite"/>.
##  We say that <M>v</M> is defined over <M>R</M>.
##  Typically, <M>R</M> will be at least a semiring.
##  <P/>
##  For creating new vector objects compatible with <M>v</M>,
##  the constructor <Ref Oper="NewVector"/>
##  requires that also the value of
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/>
##  is known for <M>v</M>.
##  <P/>
##  Further, entry access <M>v[i]</M> is expected to return a &GAP; object,
##  for <M>1 \leq i \leq</M><C> Length</C><M>( v )</M>,
##  and that these entries of <M>v</M> belong to the base domain <M>R</M>.
##  <P/>
##  Note that we do <E>not</E> require that <M>v</M> is a list in the sense
##  of <Ref Filt="IsList"/>,
##  in particular the rules of list arithmetic
##  (see the sections <Ref Sect="Additive Arithmetic for Lists"/>
##  and <Ref Sect="Multiplicative Arithmetic for Lists"/>)
##  need <E>not</E> hold.
##  For example, the sum of two vector objects of different lengths or
##  defined over different base domains is not defined,
##  and a plain list of vector objects is not a matrix.
##  Also unbinding entries of vector objects is not defined.
##  <P/>
##  Scalar multiplication from the left is defined only with elements from
##  <M>R</M>.
##  <P/>
##  The family of <M>v</M> (see <Ref Func="FamilyObj"/>) is the same as
##  the family of its base domain <M>R</M>.
##  However, it is <E>not</E> required that the entries lie in <M>R</M>
##  in the sense of <Ref Oper="\in" Label="for a collection"/>,
##  also values may occur that can be naturally embedded into <M>R</M>.
##  For example, if <M>R</M> is a polynomial ring then some entries
##  in <M>v</M> may be elements of the coefficient ring of <M>R</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsVectorObj", IsVector and IsCopyable );


#############################################################################
##
##  <#GAPDoc Label="IsMatrixObj">
##  <ManSection>
##  <Filt Name="IsMatrixObj" Arg='obj' Type="category"/>
##
##  <Description>
##  The idea behind <E>matrix objects</E> is that one wants to deal with
##  objects like <M>m</M> by <M>n</M> arrays over a given domain
##  <M>R</M>, say, which can be added and multiplied
##  and can be multiplied from the left with elements from <M>R</M>.
##  A matrix object <M>M</M>, say, is always a copyable object
##  (see <Ref Filt="IsCopyable"/>) in <Ref Filt="IsVector"/> and
##  <Ref Filt="IsScalar"/>,
##  which knows the values of
##  <Ref Attr="BaseDomain" Label="for a matrix object"/>
##  (with value <M>R</M>),
##  <Ref Attr="NumberRows" Label="for a matrix object"/>
##  (with value <M>m</M>),
##  <Ref Attr="NumberColumns" Label="for a matrix object"/>
##  (with value <M>n</M>),
##  where <M>R</M> is a domain (see Chapter <Ref Chap="Domains"/>)
##  that has methods for
##  <Ref Attr="Zero"/>,
##  <Ref Attr="One"/>,
##  <Ref Oper="\in" Label="for a collection"/>,
##  <Ref Attr="Characteristic"/>,
##  <Ref Prop="IsFinite"/>.
##  We say that <M>v</M> is defined over <M>R</M>.
##  Typically, <M>R</M> will be at least a semiring.
##  <P/>
##  For creating new matrix objects compatible with <M>M</M>,
##  the constructor <Ref Oper="NewMatrix"/>
##  requires that also the value of
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/>
##  is known for <M>M</M>.
##  <P/>
##  Further, entry access <M>M[i,j]</M> is expected to return a &GAP; object,
##  for <M>1 \leq i \leq m</M> and <M>1 \leq j \leq n</M>,
##  and that these entries of <M>M</M> belong to the base domain <M>R</M>.
##  <P/>
##  Note that we do <E>not</E> require that <M>M</M> is a list in the sense
##  of <Ref Filt="IsList"/>,
##  in particular the rules of list arithmetic
##  (see the sections <Ref Sect="Additive Arithmetic for Lists"/>
##  and <Ref Sect="Multiplicative Arithmetic for Lists"/>)
##  need <E>not</E> hold.
##  For example, accessing <Q>rows</Q> of <M>M</M> via <Ref Oper="\[\]"/>
##  is in general not possible, and the sum of two matrix objects with
##  different numbers of rows or columns is not defined.
##  Also unbinding entries of matrix objects is not defined.
##  <P/>
##  Scalar multiplication from the left is defined only with elements from
##  <M>R</M>.
##  <P/>
##  It is not assumed that the multiplication in <M>R</M> is associative,
##  and we do not define what the <M>k</M>-th power of a matrix object is
##  in this case, for positive integers <M>k</M>.
##  (However, a default powering method is available.)
##  <P/>
##  The filter <Ref Filt="IsMatrixObj"/> alone does <E>not</E> imply that the
##  multiplication is the usual matrix multiplication.
##  This multiplication can be defined via the filter
##  <Ref Filt="IsOrdinaryMatrix"/>;
##  this filter together with the associativity of the base domain
##  also implies the associativity of matrix multiplication.
##  For example,
##  elements of matrix Lie algebras (see <Ref Attr="LieObject"/>)
##  lie in <Ref Filt="IsMatrixObj"/> but not in
##  <Ref Filt="IsOrdinaryMatrix"/>.
##  <P/>
##  The family of <M>M</M> (see <Ref Func="FamilyObj"/>) is the
##  collections family (see <Ref Attr="CollectionsFamily"/>) of its
##  base domain <M>R</M>.
##  However, it is <E>not</E> required that the entries lie in <M>R</M>
##  in the sense of <Ref Oper="\in" Label="for a collection"/>,
##  also values may occur that can be naturally embedded into <M>R</M>.
##  For example, if <M>R</M> is a polynomial ring then some entries
##  in <M>M</M> may be elements of the coefficient ring of <M>R</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsMatrixObj", IsVector and IsScalar and IsCopyable );


#############################################################################
##
##  We want that objects in 'IsMatrix' (which are plain lists of lists)
##  are also in 'IsMatrixObj', in order to be able to install generic methods
##  that cover also the case of 'IsMatrix'.
##  Note that we cannot get this implication already in the declaration of
##  'IsMatrix' because both 'IsVector' and 'IsMatrix' are declared in
##  'lib/arith.gd', and 'IsMatrixObj' --which shall be in the middle-- is
##  declared in 'lib/matobj1.gd'.)
##
#T Do we want that objects in 'IsRowVector' (which are plain lists)
#T are also in 'IsVectorObj'?
#T (For some operations, such as 'WeightOfVector' or 'DistanceOfVectors',
#T this implication would make sense, but in fact the default methods for
#T 'WeightVecFFE' and 'DistanceVecFFE' are installed with requirement
#T 'IsList'.)
##
InstallTrueMethod( IsMatrixObj, IsMatrix );


#############################################################################
##
##  <#GAPDoc Label="IsRowListMatrix">
##  <ManSection>
##  <Filt Name="IsRowListMatrix" Arg='obj' Type="category"/>
##
##  <Description>
##  A <E>row list matrix object</E> is a matrix object
##  (see <Ref Filt="IsMatrixObj"/>) which admits access to their rows,
##  via list access <Ref Oper="\[\]"/>.
##  <P/>
##  All rows are <Ref Filt="IsVectorObj"/> objects in the same
##  representation.
##  Several rows of a row list matrix object can be identical objects,
##  and different row list matrices may share rows.
##  Row access just gives a reference to the row object, without copying
##  the row.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsRowListMatrix", IsMatrixObj );

