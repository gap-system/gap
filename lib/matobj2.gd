#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##


#############################################################################
##
##  This file together with 'matobj1.gd' formally define the interface to
##  those vector and matrix objects in GAP that are not represented
##  by plain lists.
##  In this file all the operations and attributes are defined.
##  It is read later in the GAP library reading process.
##


#############################################################################
##
##  <#GAPDoc Label="MatObj_Overview">
##
##  Traditionally, vectors and matrices in &GAP; have been represented by
##  (lists of) lists, see the chapters
##  <Ref Chap="Row Vectors"/> and <Ref Chap="Matrices"/>.
##  More precisely, the term <Q>vector</Q>
##  (corresponding to the filter <Ref Filt="IsVector"/>)
##  is used in the abstract sense of an <Q>element of a vector space</Q>,
##  the term <Q>row vector</Q> (corresponding to <Ref Filt="IsRowVector"/>)
##  is used to denote a <Q>coordinate vector</Q> which is represented by
##  a &GAP; list (see <Ref Filt="IsList"/>),
##  and the term <Q>matrix</Q> is used to denote a list of lists, with
##  additional properties (see <Ref Filt="IsMatrix"/>).
##  <P/>
##  Unfortunately, such lists (objects in <Ref Filt="IsPlistRep"/>)
##  cannot store their type,
##  and so it is impossible to use the advantages of &GAP;'s method selection
##  on them.
##  This situation is unsustainable in the long run
##  since more special representations (compressed, sparse, etc.)
##  have already been and even more will be implemented.
##  Here we describe a programming interface to vectors and matrices,
##  which solves this problem,
##  <P/>
##  The idea of this interface is that &GAP; should be able to
##  represent vectors and matrices by objects that store their type,
##  in order to benefit from method selection.
##  These objects are created by <Ref Func="Objectify"/>,
##  we therefore refer to the them as <Q>vector objects</Q> and
##  <Q>matrix objects</Q> respectively.
##  <P/>
##  (Of course the terminology is somewhat confusing:
##  An <Q>abstract matrix</Q> in &GAP; can be represented either by a list of
##  lists or by a matrix object.
##  It can be detected from the filter <Ref Filt="IsMatrixOrMatrixObj"/>;
##  this is the union of the filters <Ref Filt="IsMatrix"/>
##  &ndash;which denotes those matrices that are represented by lists of
##  lists&ndash;
##  and the filter <Ref Filt="IsMatrixObj"/>
##  &ndash;which defines <Q>proper</Q> matrix objects in the above sense.
##  In particular, we do <E>not</E> regard the objects in
##  <Ref Filt="IsMatrix"/> as special cases of objects in
##  <Ref Filt="IsMatrixObj"/>, or vice versa.
##  Thus one can install specific methods for all three situations:
##  just for <Q>proper</Q> matrix objects, just for matrices represented
##  by lists of lists, or for both kinds of matrices.
##  For example, a &GAP; package may decide to accept only <Q>proper</Q>
##  matrix objects as arguments of its functions, or it may try to support
##  also objects in <Ref Filt="IsMatrix"/> as far as this is possible.)
##  <P/>
##  We want to be able to write (efficient) code that is independent of the
##  actual representation (in the sense of &GAP;'s representation filters,
##  see Section <Ref Sect="Representation"/>)
##  and preserves it.
##  <P/>
##  This latter requirement makes it necessary to distinguish between
##  different representations of matrices:
##  <Q>Row list</Q> matrices (see <Ref Filt="IsRowListMatrix"/>
##  behave basically like lists of rows,
##  in particular the rows are individual &GAP; objects that can
##  be shared between different matrix objects.
##  One can think of other representations of matrices,
##  such as matrices whose subobjects represent columns,
##  or <Q>flat</Q> matrices which do not have subobjects like rows or
##  columns at all.
##  The different kinds of matrices have to be distinguished
##  already with respect to the definition of the operations for them.
##  <P/>
##  In particular vector and matrix objects know their base domain
##  (see <Ref Attr="BaseDomain" Label="for a vector object"/>)
##  and their dimensions.
##  The basic condition is that the entries of vector and matrix objects
##  must either lie in the base domain or naturally embed in the sense that
##  addition and multiplication automatically work with elements of the
##  base domain;
##  for example, a matrix object over a polynomial ring may also contain
##  entries from the coefficient ring.
##  <P/>
##  Vector and matrix objects may be mutable or immutable.
##  Of course all operations changing an object are only allowed/implemented
##  for mutable variants.
##  <P/>
##  Vector objects are equal with respect to <Ref Oper="\="/>
##  if they have the same length and the same entries.
##  It is not necessary that they have the same base domain.
##  Matrices are equal with respect to <Ref Oper="\="/>
##  if they have the same dimensions and the same entries.
##  <P/>
##  For a row list matrix object, it is not guaranteed that all its rows
##  have the same vector type.
##  It is for example thinkable that a matrix object stores some of its rows
##  in a sparse representation and some in a dense one.
##  However, it is guaranteed that the rows of two matrices in the same
##  representation are compatible in the sense that all vector operations
##  defined in this interface can be applied to them and that new matrices
##  in the same representation as the original matrix can be formed out of
##  them.
##  <P/>
##  Note that there is neither a default mapping from the set of
##  matrix object representations to the set of vector representations
##  nor one in the reverse direction.
##  There is in general no <Q>associated</Q> vector object representation
##  to a matrix object representation or vice versa.
##  (However,
##  <Ref Attr="CompatibleVectorFilter" Label="for a matrix object"/>
##  may describe a vector object representation that is compatible with a
##  given matrix object.)
##  <P/>
##  The recommended way to write code that preserves the representation
##  basically works by using constructing operations that take template
##  objects to decide about the intended representation for the new object.
##  <P/>
##  Vector and matrix objects do not have to be &GAP; lists in the sense of
##  <Ref Filt="IsList"/>.
##  Note that objects not in the filter <Ref Filt="IsList"/> need not
##  support all list operations, and their behaviour is not prescribed by the
##  rules for lists, e.g., behaviour w.r.t. arithmetic operations.
##  However, row list matrices behave nearly like lists of row vectors
##  that insist on being dense and containing only vectors of the same
##  length and with the same base domain.
##  <P/>
##  Vector and matrix objects are not likely to benefit from &GAP;'s
##  immediate methods (see section <Ref Sect="Immediate Methods"/>).
##  Therefore it may be useful to set the filter
##  <Ref Filt="IsNoImmediateMethodsObject"/> in the definition of new kinds
##  of vector and matrix objects.
##  <P/>
##  For information on how to implement new <Ref Filt="IsMatrixObj"/> and
##  <Ref Filt="IsVectorObj"/> representations see Section
##  <Ref Sect="Implementing New Vector and Matrix Objects Types"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#A  Length( <v> )
##
##  <#GAPDoc Label="Length_IsVectorObj">
##  <ManSection>
##  <Attr Name="Length" Arg='v' Label="for a vector object"/>
##
##  <Description>
##  returns the length of the vector object <A>v</A>,
##  which is defined to be the number of entries of <A>v</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Length", IsVectorObj );


#############################################################################
##
#A  ConstructingFilter( <v> )
#A  ConstructingFilter( <M> )
##
##  <#GAPDoc Label="ConstructingFilter">
##  <ManSection>
##  <Heading>ConstructingFilter</Heading>
##  <Attr Name="ConstructingFilter" Arg="v" Label="for a vector object"/>
##  <Attr Name="ConstructingFilter" Arg="M" Label="for a matrix object"/>
##
##  <Returns>a filter</Returns>
##  <Description>
##  Called with a vector object <A>v</A> or a matrix object <A>M</A>,
##  respectively,
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> returns
##  a filter <C>f</C> such that when
##  <Ref Oper="NewVector"/> or <Ref Oper="NewMatrix"/>, respectively,
##  is called with <C>f</C> then a vector object or a matrix object,
##  respectively, in the same representation as the argument is produced.
##  <P/>
##  If the <Ref Attr="ConstructingFilter" Label="for a vector object"/>
##  value of <A>v</A> or <A>M</A> implies <Ref Filt="IsCopyable"/> then
##  mutable versions of <A>v</A> or <A>M</A> can be created,
##  otherwise all vector or matrix objects with this filter are immutable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ConstructingFilter", IsVecOrMatObj );


#############################################################################
##
#A  CompatibleVectorFilter( <M> )
##
##  <#GAPDoc Label="CompatibleVectorFilter">
##  <ManSection>
##  <Heading>CompatibleVectorFilter</Heading>
##  <Attr Name="CompatibleVectorFilter" Arg="M" Label="for a matrix object"/>
##
##  <Returns>a filter</Returns>
##  <Description>
##  Called with a matrix object <A>M</A>,
##  <Ref Attr="CompatibleVectorFilter" Label="for a matrix object"/> returns
##  either a filter <C>f</C> such that vector objects with
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> value
##  <C>f</C> are compatible in the sense that <A>M</A> can be multiplied with
##  these vector objects, of <K>fail</K> if no such filter is known.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CompatibleVectorFilter", IsMatrixOrMatrixObj );


#############################################################################
##
##  List Like Operations for Vector Objects
##


#############################################################################
##
#O  \[\]( <v>, <i> )
#O  \[\]\:\=( <v>, <i>, <obj> )
#O  \{\}( <v>, <list> )
##
##  <#GAPDoc Label="ElementAccessVectorObj">
##  <ManSection>
##  <Heading>Element Access and Assignment for Vector Objects</Heading>
##
##  <Oper Name="\[\]" Arg="v,i" Label="for a vector object and an integer"/>
##  <Oper Name="\[\]\:\=" Arg="v,i,obj"
##   Label="for a vector object and an integer"/>
##  <Oper Name="\{\}" Arg="v,list" Label="for a vector object and a list"/>
##
##  <Description>
##  For a vector object <A>v</A> and a positive integer <A>i</A> that is
##  not larger than the length of <A>v</A>
##  (see <Ref Attr="Length" Label="for a vector object"/>),
##  <A>v</A><C>[</C><A>i</A><C>]</C> is the entry at position <A>i</A>.
##  <P/>
##  If <A>v</A> is mutable, <A>i</A> is as above, and <A>obj</A> is an object
##  from the base domain of <A>v</A> then
##  <A>v</A><C>[</C><A>i</A><C>]:= </C><A>obj</A> assigns <A>obj</A> to the
##  <A>i</A>-th position of <A>v</A>.
##  <P/>
##  If <A>list</A> is a list of positive integers that are not larger than
##  the length of <A>v</A> then
##  <A>v</A><C>{</C><A>list</A><C>}</C> returns a new mutable vector object
##  in the same representation as <A>v</A>
##  (see <Ref Attr="ConstructingFilter" Label="for a vector object"/>)
##  that contains the <A>list</A><M>[ k ]</M>-th entry of <A>v</A> at
##  position <M>k</M>.
##  <P/>
##  If the global option <C>check</C> is set to <K>false</K> then
##  <Ref Oper="\[\]\:\=" Label="for a vector object and an integer"/>
##  need not perform consistency checks.
##  <P/>
##  Note that the sublist assignment operation <Ref Oper="\{\}\:\="/>
##  is left out here since it tempts the programmer to use constructions like
##  <C>v{ [ 1 .. 3 ] }:= w{ [ 4 .. 6 ] }</C>
##  which produces an unnecessary intermediate object;
##  one should use <Ref Oper="CopySubVector"/> instead.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "[]", [ IsVectorObj, IsPosInt ] );

DeclareOperation( "[]:=", [ IsVectorObj, IsPosInt, IsObject ] );

DeclareOperation( "{}", [ IsVectorObj, IsList ] );


#############################################################################
##
##  <#GAPDoc Label="MatObj_PositionNonZero">
##  <ManSection>
##  <Oper Name="PositionNonZero" Arg="v" Label="for a vector object"/>
##
##  <Returns>An integer</Returns>
##  <Description>
##  Returns the index of the first entry in the vector object <A>v</A>
##  that is not zero.
##  If all entries are zero,
##  the function returns <C>Length(<A>v</A>) + 1</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PositionNonZero", [ IsVectorObj ] );


#############################################################################
##
##  <#GAPDoc Label="MatObj_PositionLastNonZero">
##  <ManSection>
##  <Oper Name="PositionLastNonZero" Arg="v"
##   Label="for a vector object"/>
##
##  <Returns>An integer</Returns>
##  <Description>
##  Returns the index of the last entry in the vector object <A>v</A>
##  that is not zero.
##  If all entries are zero, the function returns <M>0</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PositionLastNonZero", [ IsVectorObj ] );


#############################################################################
##
#O  ListOp( <v>[, <func>] )
##
##  <#GAPDoc Label="MatObj_ListOp">
##  <ManSection>
##  <Oper Name="ListOp" Arg="v[, func]"
##   Label="for vector object and function"/>
##
##  <Returns>A plain list</Returns>
##  <Description>
##  Applies the function <A>func</A> to each entry of the vector object
##  <A>v</A> and returns the results as a mutable plain list.
##  This allows for calling <Ref Func="List" Label="for a collection"/>
##  on vector objects.
##  <P/>
##  If the argument <A>func</A> is not given,
##  applies  <Ref Func="IdFunc"/> to all entries.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ListOp", [ IsVectorObj ] );
DeclareOperation( "ListOp", [ IsVectorObj, IsFunction ] );


#############################################################################
##
#O  Unpack( <v> )
#O  Unpack( <M> )
##
##  <#GAPDoc Label="Unpack">
##  <ManSection>
##  <Heading>Unpack</Heading>
##  <Oper Name="Unpack" Arg="v" Label="for a vector object"/>
##  <Oper Name="Unpack" Arg="M" Label="for a matrix object"/>
##
##  <Returns>A plain list</Returns>
##  <Description>
##  Returns a new mutable plain list (see <Ref Filt="IsPlistRep"/>)
##  containing the entries of the vector object <A>v</A> or the matrix object
##  <A>M</A>, respectively.
##  In the case of a matrix object,
##  the result is a plain list of plain lists.
##  <P/>
##  Changing the result does not change <A>v</A> or <A>M</A>, respectively.
##  The entries themselves are not copied.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Note that 'AsList' would not be suitable in the case of vector objects
##  because its result would be immutable.
##
DeclareOperation( "Unpack", [ IsVecOrMatObj ] );
#DeclareOperation( "Unpack", [ IsVectorObj ] );
#DeclareOperation( "Unpack", [ IsMatrixOrMatrixObj ] );


#############################################################################
##
##  <#GAPDoc Label="MatObj_ConcatenationOfVectors">
##  <ManSection>
##  <Heading>ConcatenationOfVectors</Heading>
##  <Func Name="ConcatenationOfVectors" Arg="v1,v2,..."
##   Label="for arbitrary many vector objects"/>
##  <Func Name="ConcatenationOfVectors" Arg="vlist"
##   Label="for a list of vector objects"/>
##
##  <Returns>a vector object</Returns>
##
##  <Description>
##  Returns a new mutable vector object in the representation of <A>v1</A>
##  or the first entry of the nonempty list <A>vlist</A> of vector objects,
##  respectively,
##  such that the entries are the concatenation of the given vector objects.
##  <P/>
##  (Note that <Ref Func="Concatenation" Label="for several lists"/>
##  is a function for which no methods can be installed.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConcatenationOfVectors" );


#############################################################################
##
##  <#GAPDoc Label="MatObj_ExtractSubVector">
##  <ManSection>
##  <Oper Name="ExtractSubVector" Arg="v,l"/>
##
##  <Returns>a vector object</Returns>
##
##  <Description>
##  Returns a new mutable vector object of the same vector representation
##  as <A>v</A>, containing the entries of <A>v</A> at the positions in
##  the list <A>l</A>.
##  <P/>
##  This is the same as <A>v</A><C>{</C><A>l</A><C>}</C>,
##  the name <Ref Oper="ExtractSubVector"/> was introduced in analogy to
##  <Ref Oper="ExtractSubMatrix"/>, for which no equivalent syntax using
##  curly brackets is available.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExtractSubVector", [ IsVectorObj, IsList ] );


#############################################################################
##
##  Arithmetical operations for vector objects
##


#############################################################################
##
#O  AddVector( <dst>, <src>[, <mul>[, <from>, <to>]] )
#O  AddVector( <dst>, <mul>, <src>[, <from>, <to>] )
##
##  <#GAPDoc Label="MatObj_AddVector">
##  <ManSection>
##  <Oper Name="AddVector" Arg='dst, src[, mul[, from, to]]'
##   Label="for two vector objects"/>
##  <Oper Name="AddVector" Arg='dst, mul, src[, from, to]'
##   Label="for two vector objects and a scalar"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  Called with two vector objects <A>dst</A> and <A>src</A>,
##  this function replaces the entries of <A>dst</A> in-place
##  by the entries of the sum <A>dst</A><C> + </C><A>src</A>.
##  <P/>
##  If a scalar <A>mul</A> is given as the third or second argument,
##  respectively, then the entries of <A>dst</A> get replaced by those of
##  <A>dst</A><C> + </C><A>src</A><C> * </C><A>mul</A> or
##  <A>dst</A><C> + </C><A>mul</A><C> * </C><A>src</A>, respectively.
##  <P/>
##  If the optional parameters <A>from</A> and <A>to</A> are given then
##  only the index range <C>[<A>from</A>..<A>to</A>]</C> is guaranteed to be
##  affected.
##  Other indices <E>may</E> be affected, if it is more convenient to do so.
##  This can be helpful if entries of <A>src</A> are known to be zero.
##  <P/>
##  If <A>from</A> is bigger than <A>to</A>, the operation does nothing.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AddVector",
  [ IsVectorObj and IsMutable, IsVectorObj ] );
DeclareOperation( "AddVector",
  [ IsVectorObj and IsMutable,  IsVectorObj, IsObject ] );
DeclareOperation( "AddVector",
  [ IsVectorObj and IsMutable, IsObject, IsVectorObj ] );
DeclareOperation( "AddVector",
  [ IsVectorObj and IsMutable, IsVectorObj, IsObject, IsPosInt, IsPosInt ] );
DeclareOperation( "AddVector",
  [ IsVectorObj and IsMutable, IsObject, IsVectorObj, IsPosInt, IsPosInt ] );


#############################################################################
##
#O  MultVector( <v>, <mul>[, <from>, <to>] )
#O  MultVectorLeft( <v>, <mul>[, <from>, <to>] )
#O  MultVectorRight( <v>, <mul>[, <from>, <to>] )
##
##  <#GAPDoc Label="MatObj_MultVectorLeft">
##  <ManSection>
##  <Oper Name="MultVector" Arg='v, mul[, from, to]'
##   Label="for a vector object"/>
##  <Oper Name="MultVectorLeft" Arg='v, mul[, from, to]'
##   Label="for a vector object"/>
##  <Oper Name="MultVectorRight" Arg='v, mul[, from, to]'
##   Label="for a vector object"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  These operations multiply <A>v</A> by <A>mul</A> in-place
##  where <Ref Oper="MultVectorLeft" Label="for a vector object"/>
##  multiplies with <A>mul</A> from the left
##  and <Ref Oper="MultVectorRight" Label="for a vector object"/>
##  does so from the right.
##  <P/>
##  Note that <Ref Oper="MultVector" Label="for a vector object"/>
##  is just a synonym for
##  <Ref Oper="MultVectorLeft" Label="for a vector object"/>.
##  This was chosen because vectors in &GAP; are by default row vectors
##  and scalar multiplication is usually written as
##  <M>a \cdot v = a \cdot [v_1, ..., v_n] = [a \cdot v_1, ..., a \cdot v_n]</M>
##  with scalars being applied from the left.
##  <P/>
##  If the optional parameters <A>from</A> and <A>to</A> are given then
##  only the index range <C>[<A>from</A>..<A>to</A>]</C> is guaranteed to be
##  affected. Other indices <E>may</E> be affected, if it is more convenient
##  to do so.
##  This can be helpful if entries of <A>v</A> are known to be zero.
##  If <A>from</A> is bigger than <A>to</A>, the operation does nothing.
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MultVectorLeft",
  [ IsVectorObj and IsMutable, IsObject ] );
DeclareOperation( "MultVectorLeft",
  [ IsVectorObj and IsMutable, IsObject, IsInt, IsInt ] );

DeclareOperation( "MultVectorRight",
  [ IsVectorObj and IsMutable, IsObject ] );
DeclareOperation( "MultVectorRight",
  [ IsVectorObj and IsMutable, IsObject, IsInt, IsInt ] );


# This is defined for two vectors of equal length,
# it returns the standard scalar product.
# (The documentation is in the section about arithm. operations.)
DeclareOperation( "ScalarProduct", [ IsVectorObj, IsVectorObj ] );


#############################################################################
##
#O  ZeroVector( <filt>, <R>, <len> )
#O  ZeroVector( <R>, <len> )
#O  ZeroVector( <len>, <v> )
#O  ZeroVector( <len>, <M> )
##
##  <#GAPDoc Label="VectorObj_ZeroVector">
##  <ManSection>
##  <Heading>ZeroVector</Heading>
##  <Oper Name="ZeroVector" Arg="filt,R,len" Label="for filter, base domain and length"/>
##  <Oper Name="ZeroVector" Arg="R,len" Label="for base domain and length"/>
##  <Oper Name="ZeroVector" Arg="len,v" Label="for length and vector object"/>
##  <Oper Name="ZeroVector" Arg="len,M" Label="for length and matrix object"/>
##
##  <Returns>a vector object</Returns>
##  <Description>
##  For a filter <A>filt</A>, a semiring <A>R</A> and a nonnegative integer <A>len</A>,
##  this operation returns a new vector object of length <A>len</A> over <A>R</A>
##  in the representation <A>filt</A> containing only zeros.
##  <P/>
##  If only <A>R</A> and <A>len</A> are given,
##  then &GAP; guesses a suitable representation.
##  <P/>
##  For a vector object <A>v</A> and a nonnegative integer <A>len</A>,
##  this operation returns a new vector object of length <A>len</A>
##  in the same representation as <A>v</A> containing only zeros.
##  <P/>
##  For a matrix object <A>M</A> and a nonnegative integer <A>len</A>,
##  this operation returns a new zero vector object of length
##  <A>len</A> in the representation given by the
##  <Ref Attr="CompatibleVectorFilter" Label="for a matrix object"/> value
##  of <A>M</A>, provided that such a representation exists.
##  <P/>
##  If the <Ref Attr="ConstructingFilter" Label="for a vector object"/>
##  value of the result implies <Ref Filt="IsCopyable"/> then the result is
##  mutable.
##  <P/>
##  Default methods for
##  <Ref Oper="ZeroVector" Label="for filter, base domain and length"/>
##  delegate to <Ref Oper="NewZeroVector"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ZeroVector", [ IsOperation, IsSemiring, IsInt ] );
DeclareOperation( "ZeroVector", [ IsSemiring, IsInt ] );
DeclareOperation( "ZeroVector", [ IsInt, IsVecOrMatObj ] );
#DeclareOperation( "ZeroVector", [ IsInt, IsVectorObj ] );
#DeclareOperation( "ZeroVector", [ IsInt, IsMatrixOrMatrixObj ] );


#############################################################################
##
#O  Vector( <filt>, <R>, <list> )
#O  Vector( <filt>, <R>, <v> )
#O  Vector( <R>, <list> )
#O  Vector( <R>, <v> )
#O  Vector( <list>, <v> )
#O  Vector( <v1>, <v2> )
##
##  <#GAPDoc Label="Vector">
##  <ManSection>
##  <Heading>Vector</Heading>
##  <Oper Name="Vector" Arg='filt,R,list'
##   Label="for filter, base domain, and list"/>
##  <Oper Name="Vector" Arg='filt,R,v'
##   Label="for filter, base domain, and vector object"/>
##  <Oper Name="Vector" Arg='R,list'
##   Label="for base domain and list"/>
##  <Oper Name="Vector" Arg='R,v'
##   Label="for base domain and vector object"/>
##  <Oper Name="Vector" Arg='list,v'
##   Label="for a list and a vector object"/>
##  <Oper Name="Vector" Arg='v1,v2'
##   Label="for two vector objects"/>
##  <Oper Name="Vector" Arg='list'
##   Label="for a list"/>
##
##  <Returns>a vector object</Returns>
##  <Description>
##  If a filter <A>filt</A> is given as the first argument then
##  a vector object is returned that has
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/>
##  value <A>filt</A>, is defined over the base domain <A>R</A>,
##  and has the entries given by the list <A>list</A> or the vector object
##  <A>v</A>, respectively.
##  <P/>
##  If a semiring <A>R</A> is given as the first argument then
##  a vector object is returned whose
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/>
##  value is guessed from <A>R</A>, again with base domain <A>R</A>
##  and entries given by the last argument.
##  <P/>
##  In the remaining cases with two arguments,
##  the first argument is a list or a vector object
##  that defines the entries of the result,
##  and the second argument is a vector object whose
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> and
##  <Ref Attr="BaseDomain" Label="for a vector object"/> are taken for the
##  result.
##  <P/>
##  If only a list <A>list</A> is given then both the
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> and the
##  <Ref Attr="BaseDomain" Label="for a vector object"/> are guessed from
##  this list.
##  <P/>
##  The variant <C>Vector( </C><A>v1</A><C>, </C><A>v2</A><C> )</C>
##  is supported also for the case that <A>v2</A> is a row vector but not
##  a vector object.
##  In this situation, the result is a row vector that is equal to
##  <A>v1</A> and whose internal representation fits to that of <A>v2</A>.
##  <P/>
##  If the global option <C>check</C> is set to <K>false</K> then
##  <Ref Oper="Vector" Label="for filter, base domain, and list"/>
##  need not perform consistency checks.
##  <P/>
##  If the <Ref Attr="ConstructingFilter" Label="for a vector object"/>
##  value of the result implies <Ref Filt="IsCopyable"/> then the result is
##  mutable if and only if the argument that determines the entries of the
##  result (<A>list</A>, <A>v</A>, <A>v1</A>) is mutable.
##  <P/>
##  In the case of a mutable result, it is <E>not</E> guaranteed that
##  the given list of entries is copied.
##  <P/>
##  Default methods for
##  <Ref Oper="Vector" Label="for filter, base domain, and list"/>
##  delegate to <Ref Oper="NewVector"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Vector", [ IsOperation, IsSemiring, IsList ] );
DeclareOperation( "Vector", [ IsOperation, IsSemiring, IsVectorObj ] );
DeclareOperation( "Vector", [ IsSemiring, IsList ] );
DeclareOperation( "Vector", [ IsSemiring, IsVectorObj ] );
DeclareOperation( "Vector", [ IsList, IsVectorObj ] );
DeclareOperation( "Vector", [ IsVectorObj, IsVectorObj ] );
DeclareOperation( "Vector", [ IsList ] );


#############################################################################
##
#O  NewVector( <filt>, <R>, <list> )
#O  NewZeroVector( <filt>, <R>, <n> )
##
##  <#GAPDoc Label="NewVector">
##  <ManSection>
##  <Heading>NewVector and NewZeroVector</Heading>
##  <Oper Name="NewVector" Arg='filt,R,list'/>
##  <Oper Name="NewZeroVector" Arg='filt,R,n'/>
##
##  <Description>
##  For a filter <A>filt</A>, a semiring <A>R</A>, and a list <A>list</A>
##  of elements that belong to <A>R</A>,
##  <Ref Oper="NewVector"/> returns a vector object which has
##  the <Ref Attr="ConstructingFilter" Label="for a vector object"/>
##  <A>filt</A>,
##  the <Ref Attr="BaseDomain" Label="for a vector object"/> <A>R</A>,
##  and the entries in <A>list</A>.
##  The list <A>list</A> is guaranteed not to be changed by this operation.
##  <P/>
##  If the global option <C>check</C> is set to <K>false</K> then
##  <Ref Oper="NewVector"/> need not perform consistency checks.
##  <P/>
##  Similarly, <Ref Oper="NewZeroVector"/> returns a vector object
##  of length <A>n</A> which has <A>filt</A> and <A>R</A> as
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> and
##  <Ref Attr="BaseDomain" Label="for a vector object"/> values,
##  and contains the zero of <A>R</A> in each position.
##  <P/>
##  The returned object is mutable if and only if <A>filt</A> implies
##  <Ref Filt="IsCopyable"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareTagBasedOperation( "NewVector", [ IsOperation, IsSemiring, IsList ] );

DeclareTagBasedOperation( "NewZeroVector",
    [ IsOperation, IsSemiring, IsInt ] );


#############################################################################
##
#O  NewMatrix( <filt>, <R>, <ncols>, <list> )
#O  NewZeroMatrix( <filt>, <R>, <m>, <n> )
#O  NewIdentityMatrix( <filt>, <R>, <n> )
##
##  <#GAPDoc Label="NewMatrix">
##  <ManSection>
##  <Heading>NewMatrix, NewZeroMatrix, NewIdentityMatrix</Heading>
##  <Oper Name="NewMatrix" Arg='filt,R,ncols,list'/>
##  <Oper Name="NewZeroMatrix" Arg='filt,R,m,n'/>
##  <Oper Name="NewIdentityMatrix" Arg='filt,R,n'/>
##
##  <Description>
##  For a filter <A>filt</A>, a semiring <A>R</A>,
##  a positive integer <A>ncols</A>, and a list <A>list</A>,
##  <Ref Oper="NewMatrix"/> returns a matrix object which has
##  the <Ref Attr="ConstructingFilter" Label="for a vector object"/>
##  <A>filt</A>,
##  the <Ref Attr="BaseDomain" Label="for a matrix object"/> <A>R</A>,
##  <A>n</A> columns
##  (see <Ref Attr="NumberColumns" Label="for a matrix object"/>),
##  and the entries described by <A>list</A>,
##  which can be either a plain list of vector objects of length <A>ncols</A>
##  or a plain list of plain lists of length <A>ncols</A>
##  or a plain list of length a multiple of <A>ncols</A> containing the
##  entries in row major order.
##  The list <A>list</A> is guaranteed not to be changed by this operation.
##  <P/>
##  The corresponding entries must be in or compatible with <A>R</A>.
##  If <A>list</A> already contains vector objects, they are copied.
##  <P/>
##  If the global option <C>check</C> is set to <K>false</K> then
##  <Ref Oper="NewMatrix"/> need not perform consistency checks.
##  <P/>
##  Similarly, <Ref Oper="NewZeroMatrix"/> returns a zero matrix
##  object with <A>m</A> rows and <A>n</A> columns
##  which has <A>filt</A> and <A>R</A> as
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> and
##  <Ref Attr="BaseDomain" Label="for a vector object"/> values.
##  <P/>
##  Similarly, <Ref Oper="NewIdentityMatrix"/> returns an identity
##  matrix object with <A>n</A> rows and columns
##  which has <A>filt</A> and <A>R</A> as
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> and
##  <Ref Attr="BaseDomain" Label="for a vector object"/> values,
##  and contains the identity element of <A>R</A> in the diagonal
##  and the zero of <A>R</A> in each off-diagonal position.
##  <P/>
##  The returned object is mutable if and only if <A>filt</A> implies
##  <Ref Filt="IsCopyable"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareTagBasedOperation( "NewMatrix",
    [ IsOperation, IsSemiring, IsInt, IsList] );

DeclareTagBasedOperation( "NewZeroMatrix",
    [ IsOperation, IsSemiring, IsInt, IsInt ] );

DeclareTagBasedOperation( "NewIdentityMatrix",
    [ IsOperation, IsSemiring, IsInt ] );


#############################################################################
##
#O  ChangedBaseDomain( <v>, <R> )
#O  ChangedBaseDomain( <M>, <R> )
##
##  <#GAPDoc Label="ChangedBaseDomain">
##  <ManSection>
##  <Heading>ChangedBaseDomain</Heading>
##  <Oper Name="ChangedBaseDomain" Arg='v,R' Label="for a vector object"/>
##  <Oper Name="ChangedBaseDomain" Arg='M,R' Label="for a matrix object"/>
##
##  <Description>
##  For a vector object <A>v</A> (a matrix object <A>M</A>)
##  and a semiring <A>R</A>,
##  <Ref Oper="ChangedBaseDomain" Label="for a vector object"/> returns
##  a new vector object (matrix object)
##  with <Ref Attr="BaseDomain" Label="for a vector object"/> value <A>R</A>,
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> value
##  equal to that of <A>v</A> (<A>M</A>),
##  and the same entries as <A>v</A> (<A>M</A>).
##  <P/>
##  The result is mutable if and only if <A>v</A> (<A>M</A>) is mutable.
##  <P/>
##  For example, one can create a vector defined over <C>GF(4)</C>
##  from a vector defined over <C>GF(2)</C> with this operation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ChangedBaseDomain", [ IsVecOrMatObj, IsSemiring ] );
#DeclareOperation( "ChangedBaseDomain", [ IsVectorObj, IsSemiring ] );
#DeclareOperation( "ChangedBaseDomain", [ IsMatrixOrMatrixObj, IsSemiring ] );


############################################################################
##
#O  Randomize( [Rs, ]v )
#O  Randomize( [Rs, ]M )
##
##  <#GAPDoc Label="Randomize">
##  <ManSection>
##  <Heading>Randomize</Heading>
##  <Oper Name="Randomize" Arg="[Rs,]v" Label="for a vector object"/>
##  <Oper Name="Randomize" Arg="[Rs,]M" Label="for a matrix object"/>
##  <Description>
##  Replaces every entry in the mutable vector object <A>v</A>
##  or matrix object <A>M</A>, respectively, with
##  a random one from the base domain of <A>v</A> or <A>M</A>,
##  respectively, and returns the argument.
##  <P/>
##  If given, the random source <A>Rs</A> is used to compute the
##  random elements.
##  Note that in this case,
##  a <Ref Oper="Random" Label="for random source and collection"/>
##  method must be available that takes a random source as its first
##  argument and the base domain as its second argument.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Randomize", [ IsVectorObj and IsMutable ] );
DeclareOperation( "Randomize", [ IsRandomSource, IsVectorObj and IsMutable ] );
DeclareOperation( "Randomize", [ IsMatrixOrMatrixObj and IsMutable ] );
DeclareOperation( "Randomize", [ IsRandomSource, IsMatrixOrMatrixObj and IsMutable ] );


#############################################################################
##
#O  CopySubVector( <src>, <dst>, <scols>, <dcols> )
##
##  <#GAPDoc Label="CopySubVector">
##  <ManSection>
##  <Oper Name="CopySubVector" Arg='src, dst, scols, dcols'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For two vector objects <A>src</A> and <A>dst</A>,
##  such that <A>dst</A> is mutable,
##  and two lists <A>scols</A> and <A>dcols</A> of positions,
##  <Ref Oper="CopySubVector"/> assigns the entries
##  <A>src</A><C>{ </C><A>scols</A><C> }</C>
##  (see <Ref Oper="ExtractSubVector"/>)
##  to the positions <A>dcols</A> in <A>dst</A>,
##  but without creating an intermediate object and thus
##  &ndash;at least in special cases&ndash;
##  much more efficiently.
##  <P/>
##  For certain objects like compressed vectors this might be significantly
##  more efficient if <A>scols</A> and <A>dcols</A> are ranges
##  with increment 1.
##  <P/>
##  If the global option <C>check</C> is set to <K>false</K> then
##  <Ref Oper="CopySubVector"/> need not perform consistency checks.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CopySubVector",
    [ IsVectorObj, IsVectorObj and IsMutable, IsList, IsList ] );



#############################################################################
##
##  <#GAPDoc Label="MatObj_WeightOfVector">
##  <ManSection>
##  <Oper Name="WeightOfVector" Arg="v" Label="for a vector object"/>
##  <Returns>an integer</Returns>
##  <Description>
##  returns the Hamming weight of the vector object <A>v</A>,
##  i.e., the number of nonzero entries in <A>v</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "WeightOfVector", [ IsVectorObj ] );


#############################################################################
##
##  <#GAPDoc Label="MatObj_DistanceOfVectors">
##  <ManSection>
##  <Oper Name="DistanceOfVectors" Arg="v1,v2"
##   Label="for two vector objects"/>
##  <Returns>an integer</Returns>
##  <Description>
##  returns the Hamming distance of the vector objects <A>v1</A> and
##  <A>v2</A>, i.e., the number of entries in which the vectors differ.
##  The vectors must have equal length.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DistanceOfVectors", [ IsVectorObj, IsVectorObj ] );


#############################################################################
##
#O  ExtractSubMatrix( <M>, <rows>, <cols> )
##
##  <#GAPDoc Label="ExtractSubMatrix">
##  <ManSection>
##  <Oper Name="ExtractSubMatrix" Arg='M, rows, cols'/>
##
##  <Description>
##  Creates a copy of the submatrix described by the two
##  lists, which mean subsets of row and column positions, respectively.
##  This does <A>M</A>{<A>rows</A>}{<A>cols</A>} and returns the result.
##  It preserves the representation of the matrix.
##  <P/>
##  If the <Ref Attr="ConstructingFilter" Label="for a matrix object"/>
##  value of the result implies <Ref Filt="IsCopyable"/> then the result is
##  fully mutable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExtractSubMatrix", [ IsMatrixOrMatrixObj, IsList, IsList ] );


#############################################################################
##
#O  MutableCopyMatrix( <M> )
##
##  <#GAPDoc Label="MutableCopyMatrix">
##  <ManSection>
##  <Oper Name="MutableCopyMatrix" Arg='M' Label="for a matrix object"/>
##
##  <Description>
##  For a matrix object <A>M</A>, this operation returns a fully mutable
##  copy of <A>M</A>, with the same
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> values,
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MutableCopyMatrix", [ IsMatrixOrMatrixObj ] );


#############################################################################
##
#O  CopySubMatrix( <src>, <dst>, <srows>, <drows>, <scols>, <dcols> )
##
##  <#GAPDoc Label="CopySubMatrix">
##  <ManSection>
##  <Oper Name="CopySubMatrix" Arg='src, dst, srows, drows, scols, dcols'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  Does <C><A>dst</A>{<A>drows</A>}{<A>dcols</A>} :=
##  <A>src</A>{<A>srows</A>}{<A>scols</A>}</C>
##  without creating an intermediate object and thus
##  &ndash;at least in special cases&ndash;
##  much more efficiently.
##  For certain objects like compressed vectors this might be
##  significantly more efficient if <A>scols</A> and <A>dcols</A> are
##  ranges with increment 1.
##  <P/>
##  If the global option <C>check</C> is set to <K>false</K> then
##  <Ref Oper="CopySubMatrix"/> need not perform consistency checks.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CopySubMatrix",
    [ IsMatrixOrMatrixObj, IsMatrixOrMatrixObj, IsList, IsList, IsList, IsList ] );


#############################################################################
##
#O  MatElm( <M>, <row>, <col> )  . . . . . .  select an entry from a matrix
#O  <M>[ <row>, <col> ]  . . . . . . . . . .  select an entry from a matrix
##
##  <#GAPDoc Label="MatObj_MatElm">
##  <ManSection>
##  <Oper Name="MatElm" Arg='M, row, col'/>
##
##  <Returns>an entry of the matrix object</Returns>
##
##  <Description>
##  For a matrix object <A>M</A>, this operation returns the entry in
##  row <A>row</A> and column <A>col</A>.
##  <P/>
##  Also the syntax <A>M</A><C>[ </C><A>row</A><C>, </C><A>col</A><C> ]</C>
##  is supported.
##  <P/>
##  Note that this is <E>not</E> equivalent to
##  <A>M</A><C>[ </C><A>row</A><C> ][ </C><A>col</A><C> ]</C>,
##  which would first try to access <A>M</A><C>[ </C><A>row</A><C> ]</C>,
##  and this is in general not possible.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "[,]", [ IsMatrixOrMatrixObj, IS_INT, IS_INT ], ELM_MAT );
DeclareSynonym( "MatElm", ELM_MAT );


#############################################################################
##
#O  SetMatElm( <M>, <row>, <col>, <obj> )  . . . . set an entry in a matrix
#O  <M>[ <row>, <col> ]:= <obj>  . . . . . . . . . set an entry in a matrix
##
##  <#GAPDoc Label="MatObj_SetMatElm">
##  <ManSection>
##  <Oper Name="SetMatElm" Arg='M, row, col, obj'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For a mutable matrix object <A>M</A>, this operation assigns the object
##  <A>obj</A> to the position in row <A>row</A> and column <A>col</A>,
##  provided that <A>obj</A> is compatible with the
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> value of <A>M</A>.
##  <P/>
##  Also the syntax
##  <A>M</A><C>[ </C><A>row</A><C>, </C><A>col</A><C> ]:= </C><A>obj</A>
##  is supported.
##  <P/>
##  Note that this is <E>not</E> equivalent to
##  <A>M</A><C>[ </C><A>row</A><C> ][ </C><A>col</A><C> ]:= </C><A>obj</A>,
##  which would first try to access <A>M</A><C>[ </C><A>row</A><C> ]</C>,
##  and this is in general not possible.
##  <P/>
##  If the global option <C>check</C> is set to <K>false</K> then
##  <Ref Oper="SetMatElm"/> need not perform consistency checks.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "[,]:=", [ IsMatrixOrMatrixObj, IsInt, IsInt, IsObject ],
    ASS_MAT );
#T We want to require also 'IsMutable' for the first argument,
#T but some package may have installed methods without this requirement.
#T Note that if we declare the operation twice, once with requirement
#T 'IsMutable' and once without, each method installation will show
#T a complaint that it matches more than one declaration.
DeclareSynonym( "SetMatElm", ASS_MAT );


#############################################################################
##
#O  ZeroMatrix( <m>, <n>, <M> )
#O  ZeroMatrix( <R>, <m>, <n> )
#O  ZeroMatrix( <filt>, <R>, <m>, <n> )
##
##  <#GAPDoc Label="MatObj_ZeroMatrix">
##  <ManSection>
##  <Heading>ZeroMatrix</Heading>
##  <Oper Name="ZeroMatrix" Arg="m, n, M"
##   Label="for dimensions and matrix object"/>
##  <Oper Name="ZeroMatrix" Arg="R, m, n"
##   Label="for base domain and dimensions"/>
##  <Oper Name="ZeroMatrix" Arg="filt, R, m, n"
##   Label="for filter, base domain, and dimensions"/>
##
##  <Returns>a matrix object</Returns>
##  <Description>
##  For a matrix object <A>M</A> and two nonnegative integers <A>m</A>
##  and <A>n</A>, this operation returns a new matrix object
##  with <A>m</A> rows and <A>n</A> columns
##  in the same representation and over the same base domain as <A>M</A>
##  containing only zeros.
##  <P/>
##  If a semiring <A>R</A> and two nonnegative integers <A>m</A> and
##  <A>n</A> are given,
##  the representation of the result is guessed from <A>R</A>.
##  <P/>
##  If a filter <A>filt</A> and a semiring <A>R</A> are  given as the first
##  and second argument, they are taken as the values of
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> of the result.
##  <P/>
##  If the <Ref Attr="ConstructingFilter" Label="for a matrix object"/>
##  value of the result implies <Ref Filt="IsCopyable"/> then the result is
##  fully mutable.
##  <P/>
##  Default methods for
##  <Ref Oper="ZeroMatrix" Label="for dimensions and matrix object"/>
##  delegate to <Ref Oper="NewZeroMatrix"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ZeroMatrix", [ IsInt, IsInt, IsMatrixOrMatrixObj ] );
DeclareOperation( "ZeroMatrix", [ IsSemiring, IsInt, IsInt ] );
DeclareOperation( "ZeroMatrix", [ IsOperation, IsSemiring, IsInt, IsInt ] );


#############################################################################
##
#O  IdentityMatrix( <n>, <M> )
#O  IdentityMatrix( <R>, <n> )
#O  IdentityMatrix( <filt>, <R>, <n> )
##
##  <#GAPDoc Label="MatObj_IdentityMatrix">
##  <ManSection>
##  <Heading>IdentityMatrix</Heading>
##  <Oper Name="IdentityMatrix" Arg="n, M"
##   Label="for dimension and matrix object"/>
##  <Oper Name="IdentityMatrix" Arg="R, n"
##   Label="for base domain and dimension"/>
##  <Oper Name="IdentityMatrix" Arg="filt, R, n"
##   Label="for filter, base domain, and dimension"/>
##
##  <Returns>a matrix object</Returns>
##  <Description>
##  For a matrix object <A>M</A> and a nonnegative integer <A>n</A>,
##  this operation returns a new identity matrix object
##  with <A>n</A> rows and columns
##  in the same representation and over the same base domain as <A>M</A>.
##  <P/>
##  If a semiring <A>R</A> and a nonnegative integer <A>n</A> is given,
##  the representation of the result is guessed from <A>R</A>.
##  <P/>
##  If a filter <A>filt</A> and a semiring <A>R</A> are  given as the first
##  and second argument, they are taken as the values of
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> of the result.
##  <P/>
##  If the <Ref Attr="ConstructingFilter" Label="for a matrix object"/>
##  value of the result implies <Ref Filt="IsCopyable"/> then the result is
##  fully mutable.
##  <P/>
##  Default methods for
##  <Ref Oper="IdentityMatrix" Label="for dimension and matrix object"/>
##  delegate to <Ref Oper="NewIdentityMatrix"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IdentityMatrix", [ IsInt, IsMatrixOrMatrixObj ] );
DeclareOperation( "IdentityMatrix", [ IsSemiring, IsInt ] );
DeclareOperation( "IdentityMatrix", [ IsOperation, IsSemiring, IsInt ] );


#############################################################################
##
#O  CompanionMatrix( <pol>, <M> )
#O  CompanionMatrix( [<filt>, ]<pol>, <R> )
##
##  <#GAPDoc Label="MatObj_CompanionMatrix">
##  <ManSection>
##  <Heading>CompanionMatrix</Heading>
##  <Oper Name="CompanionMatrix" Arg='pol, M'
##   Label="for polynomial and matrix object"/>
##  <Oper Name="CompanionMatrix" Arg='filt, pol, R'
##   Label="for filter, polynomial, and semiring"/>
##  <Oper Name="CompanionMatrix" Arg='pol, R'
##   Label="for polynomial and semiring"/>
##
##  <Returns>a matrix object</Returns>
##  <Description>
##  For a monic, univariate polynomial <A>pol</A> whose coefficients lie in
##  the base domain of the matrix object <A>M</A>,
##  <Ref Oper="CompanionMatrix" Label="for polynomial and matrix object"/>
##  returns the companion matrix of <A>pol</A>,
##  as a matrix object with the same
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> values as <A>M</A>.
##  <P/>
##  We use column convention, that is, the negatives of the coefficients of
##  <A>pol</A> appear in the last column of the result.
##  <P/>
##  If a filter <A>filt</A> and a semiring <A>R</A> are given then the
##  companion matrix is returned as a matrix object with
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> value
##  <A>filt</A> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> value <A>R</A>.
##  <P/>
##  If only <A>pol</A> and a semiring <A>R</A> are given,
##  the representation of the result is guessed from <A>R</A>.
##  <P/>
##  If the <Ref Attr="ConstructingFilter" Label="for a matrix object"/>
##  value of the result implies <Ref Filt="IsCopyable"/> then the result is
##  fully mutable.
##  <P/>
##  <Example><![CDATA[
##  gap> x:= X( GF(5) );;  pol:= x^3 + x^2 + 2*x + 3;;
##  gap> M:= CompanionMatrix( IsPlistMatrixRep, pol, GF(25) );;
##  gap> Display( M );
##  <3x3-matrix over GF(5^2):
##  [[ 0*Z(5), 0*Z(5), Z(5) ]
##   [ Z(5)^0, 0*Z(5), Z(5)^3 ]
##   [ 0*Z(5), Z(5)^0, Z(5)^2 ]
##  ]>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CompanionMatrix",
    [ IsUnivariatePolynomial, IsMatrixOrMatrixObj ] );
DeclareOperation( "CompanionMatrix",
    [ IsOperation, IsUnivariatePolynomial, IsSemiring ] );
DeclareOperation( "CompanionMatrix",
    [ IsUnivariatePolynomial, IsSemiring ] );


#############################################################################
##
#O  Matrix( <filt>, <R>, <list>, <ncols> )
#O  Matrix( <filt>, <R>, <list> )
#O  Matrix( <filt>, <R>, <M> )
#O  Matrix( <R>, <list>, <ncols> )
#O  Matrix( <R>, <list> )
#O  Matrix( <R>, <M> )
#O  Matrix( <list>, <ncols>, <M> )
#O  Matrix( <list>, <M> )
#O  Matrix( <M1>, <M2> )
#O  Matrix( <list>, <ncols> )
#O  Matrix( <list> )
##
##  <#GAPDoc Label="MatObj_Matrix">
##  <ManSection>
##  <Heading>Matrix</Heading>
##  <Oper Name="Matrix" Arg='filt,R,list,ncols'
##   Label="for filter, base domain, list, ncols"/>
##  <Oper Name="Matrix" Arg='filt,R,list'
##   Label="for filter, base domain, and list"/>
##  <Oper Name="Matrix" Arg='filt,R,M'
##   Label="for filter, base domain, and matrix object"/>
##  <Oper Name="Matrix" Arg='R,list,ncols'
##   Label="for base domain, list, ncols"/>
##  <Oper Name="Matrix" Arg='R,list'
##   Label="for base domain and list"/>
##  <Oper Name="Matrix" Arg='R,M'
##   Label="for base domain and matrix object"/>
##  <Oper Name="Matrix" Arg='list,ncols,M'
##   Label="for a list, ncols, and a matrix object"/>
##  <Oper Name="Matrix" Arg='list,M'
##   Label="for a list and a matrix object"/>
##  <Oper Name="Matrix" Arg='M1,M2'
##   Label="for two matrix objects"/>
##  <Oper Name="Matrix" Arg='list,ncols'
##   Label="for a list and ncols"/>
##  <Oper Name="Matrix" Arg='list'
##   Label="for a list"/>
##
##  <Returns>a matrix object</Returns>
##  <Description>
##  If a filter <A>filt</A> is given as the first argument then
##  a matrix object is returned that has
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/>
##  value <A>filt</A>, is defined over the base domain <A>R</A>,
##  and has the entries given by the list <A>list</A> or the matrix object
##  <A>M</A>, respectively.
##  Here <A>list</A> can be either a list of plain lists that describe the
##  entries of the rows, or a flat list of the entries in row major order,
##  where <A>ncols</A> defines the number of columns.
##  <P/>
##  If a semiring <A>R</A> is given as the first argument then
##  a matrix object is returned whose
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/>
##  value is guessed from <A>R</A>, again with base domain <A>R</A>
##  and entries given by the last argument.
##  <P/>
##  In those remaining cases where the last argument is a matrix object,
##  the first argument is a list or a matrix object
##  that defines (together with <A>ncols</A> if applicable) the entries of
##  the result, and the
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> of the last argument
##  are taken for the result.
##  <P/>
##  Finally, if only a list <A>list</A> and perhaps <A>ncols</A> is given
##  then both the
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and the
##  <Ref Attr="BaseDomain" Label="for a vector object"/> are guessed from
##  the list.
##  <P/>
##  If the global option <C>check</C> is set to <K>false</K> then
##  <Ref Oper="Matrix" Label="for filter, base domain, list, ncols"/>
##  need not perform consistency checks.
##  <P/>
##  If the <Ref Attr="ConstructingFilter" Label="for a matrix object"/>
##  value of the result implies <Ref Filt="IsCopyable"/> then the result is
##  mutable if and only if the argument that determines the entries of the
##  result (<A>list</A>, <A>M</A>, <A>M1</A>) is mutable.
##  <P/>
##  In the case of a mutable result, it is guaranteed that the given list
##  <A>list</A> is copied in the sense of <Ref Oper="ShallowCopy"/>,
##  and if <A>list</A> is a nested list then it is <E>not</E> guaranteed
##  that also the entries of <A>list</A> are copied.
##  <P/>
##  Default methods for
##  <Ref Oper="Matrix" Label="for filter, base domain, list, ncols"/>
##  delegate to <Ref Oper="NewMatrix"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Matrix", [ IsOperation, IsSemiring, IsList, IsInt ] );
DeclareOperation( "Matrix", [ IsOperation, IsSemiring, IsList ] );
DeclareOperation( "Matrix", [ IsOperation, IsSemiring, IsMatrixOrMatrixObj ] );
DeclareOperation( "Matrix", [ IsSemiring, IsList, IsInt ] );
DeclareOperation( "Matrix", [ IsSemiring, IsList ] );
DeclareOperation( "Matrix", [ IsSemiring, IsMatrixOrMatrixObj ] );
DeclareOperation( "Matrix", [ IsList, IsInt, IsMatrixOrMatrixObj ] );
DeclareOperation( "Matrix", [ IsList, IsMatrixOrMatrixObj ] );
DeclareOperation( "Matrix", [ IsMatrixOrMatrixObj, IsMatrixOrMatrixObj ] );
DeclareOperation( "Matrix", [ IsList, IsInt ] );
DeclareOperation( "Matrix", [ IsList ]);


############################################################################
##
#A  CompatibleVector( <M> )
##
##  <#GAPDoc Label="CompatibleVector">
##  <ManSection>
##  <Oper Name="CompatibleVector" Arg='M' Label="for a matrix object"/>
##
##  <Returns>a vector object</Returns>
##
##  <Description>
##  Called with a matrix object <A>M</A> with <M>m</M> rows,
##  this operation returns a mutable zero vector object <M>v</M> of length
##  <M>m</M> and in the representation given by the
##  <Ref Attr="CompatibleVectorFilter" Label="for a matrix object"/> value
##  of <A>M</A> (provided that such a representation exists).
##  <P/>
##  The idea is that there should be an efficient way to
##  form the product <M>v</M><A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CompatibleVector", [ IsMatrixOrMatrixObj ] );


############################################################################
##
#A  RowsOfMatrix( <M> )
##
##  <#GAPDoc Label="RowsOfMatrix">
##  <ManSection>
##  <Attr Name="RowsOfMatrix" Arg='M' Label="for a matrix object"/>
##
##  <Returns>a plain list</Returns>
##
##  <Description>
##  Called with a matrix object <A>M</A>, this operation
##  returns a plain list of objects in the representation given by the
##  <Ref Attr="CompatibleVectorFilter" Label="for a matrix object"/> value
##  of <A>M</A> (provided that such a representation exists),
##  where the <M>i</M>-th entry describes the <M>i</M>-th row of the input.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  This function is used for creating an isomorphic permutation group
##  of a matrix group that consists of matrix objects.
##  <!-- If 'NicomorphismOfGeneralMatrixGroup' would be documented then
##  one could insert a reference to it. -->
##
##  We assume that the matrix knows how to create suitable vector objects;
##  entering a template vector as the second argument is not an option
##  in this situation.
##
DeclareAttribute( "RowsOfMatrix", IsMatrixOrMatrixObj );


#############################################################################
##
#F  DefaultVectorRepForBaseDomain( <D> )
#F  DefaultMatrixRepForBaseDomain( <D> )
##
##  currently undocumented
##
DeclareGlobalFunction( "DefaultVectorRepForBaseDomain" );
DeclareGlobalFunction( "DefaultMatrixRepForBaseDomain" );


#############################################################################
##
##  Operations for Row List Matrix Objects
##


############################################################################
##
#O  <M>[ <pos> ]<v>
##
##  <#GAPDoc Label="RowListMatObj_[]">
##  <ManSection>
##  <Heading>List Access for a Row List Matrix</Heading>
##  <Oper Name="\[\]" Arg='M, pos' Label="for a row list matrix"/>
##
##  <Returns>a vector object</Returns>
##
##  <Description>
##  If <A>M</A> is a row list matrix and if <A>pos</A> is a
##  positive integer not larger than the number of rows of <A>M</A>,
##  this operation returns the <A>pos</A>-th row of <A>M</A>.
##  <P/>
##  It is not specified what happens if <A>pos</A> is larger.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "[]", [ IsRowListMatrix, IsPosInt ] );


############################################################################
##
#O  <M>[ <pos> ]:= <v>
##
##  <#GAPDoc Label="RowListMatObj_[]_ASS">
##  <ManSection>
##  <Heading>List Assignment for a Row List Matrix</Heading>
##  <Oper Name="\[\]\:\=" Arg='M, pos, v'
##   Label="for a row list matrix and a vector object"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  If <A>M</A> is a row list matrix, <A>v</A> is a vector object
##  that can occur as a row in <A>M</A>
##  (that is, <A>v</A> has the same base domain, the right length,
##  and the right vector representation),
##  and if <A>pos</A> is a positive integer not larger than
##  the number of rows of <A>M</A> plus 1,
##  this operation sets <A>v</A> as the <A>pos</A>-th row of
##  <A>M</A>.
##  <P/>
##  In all other situations, it is not specified what happens.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "[]:=", [ IsRowListMatrix, IsPosInt, IsVectorObj ] );


#############################################################################
##
#O  <M>{ <pos> }
##
##  <#GAPDoc Label="RowListMatObj_{}">
##  <ManSection>
##  <Heading>Sublist Access for a Row List Matrix</Heading>
##  <Oper Name="\{\}" Arg='M, poss' Label="for a row list matrix"/>
##
##  <Returns>a row list matrix</Returns>
##
##  <Description>
##  For a row list matrix <A>M</A> and a list <A>poss</A> of positions,
##  <A>M</A><C>{ </C><A>poss</A><C> }</C> returns a new mutable
##  row list matrix with the same representation as <A>M</A>,
##  whose rows are identical to the rows at the positions
##  in the list <A>poss</A> in <A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "{}", [IsRowListMatrix,IsList] );


#############################################################################
##
#O  <M>{ <poss> }:= <M2>
##
##  <#GAPDoc Label="RowListMatObj_{}_ASS">
##  <ManSection>
##  <Heading>Sublist Assignment for a Row List Matrix</Heading>
##  <Oper Name="\{\}\:\=" Arg='M, poss, M2' Label="for row list matrices"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For a mutable row list matrix <A>M</A>, a list <A>poss</A> of
##  positions, and a row list matrix <A>M2</A> of the same vector type
##  and with the same base domain,
##  <A>M</A><C>{ </C><A>poss</A><C> }:= </C><A>M2</A> assigns the rows
##  of <A>M2</A> to the positions <A>poss</A> in the list of rows of
##  <A>M</A>.
##  <P/>
##  It is not specified what happens if the resulting range of row positions
##  is not dense.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "{}:=", [IsRowListMatrix,IsList,IsRowListMatrix] );


#############################################################################
##
#O  IsBound\[\]( <M>, <pos> )
##
##  <#GAPDoc Label="RowListMatObj_IsBound">
##  <ManSection>
##  <Oper Name="IsBound\[\]" Arg='M, pos' Label="for a row list matrix"/>
##
##  <Returns><K>true</K> or <K>false</K></Returns>
##
##  <Description>
##  For a row list matrix <A>M</A> and a positive integer <A>pos</A>,
##  <C>IsBound( </C><A>M</A><C>[ </C><A>pos</A><C> ] )</C> returns
##  <K>true</K> if <A>pos</A> is at most the number of rows of <A>M</A>,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsBound[]", [ IsRowListMatrix, IsPosInt ] );


#############################################################################
##
#O  Unbind\[\]( <M>, <pos> )
##
##  <#GAPDoc Label="RowListMatObj_Unbind">
##  <ManSection>
##  <Oper Name="Unbind\[\]" Arg='M, pos' Label="for a row list matrix"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For a mutable row list matrix <A>M</A> with <A>pos</A> rows,
##  <C>Unbind( </C><A>M</A><C>[ </C><A>pos</A><C> ] )</C> removes the last
##  row.
##  It is not specified what happens if <A>pos</A> has another value.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Unbind[]", [ IsRowListMatrix, IsPosInt ] );


#############################################################################
##
#O  Add( <M>, <v>[, <pos>] )
##
##  <#GAPDoc Label="RowListMatObj_Add">
##  <ManSection>
##  <Oper Name="Add" Arg='M, v[, pos]'
##   Label="for a row list matrix and a vector object"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For a mutable row list matrix <A>M</A> and a vector object <A>v</A>
##  that is compatible with the rows of <A>M</A>,
##  the two argument version adds <A>v</A> at the end of the list of rows
##  of <A>M</A>.
##  <P/>
##  If a positive integer <A>pos</A> is given then <A>v</A> is added in
##  position <A>pos</A>, and all later rows are shifted up by one position.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Add", [ IsRowListMatrix, IsVectorObj ] );
DeclareOperation( "Add", [ IsRowListMatrix, IsVectorObj, IsPosInt ] );


#############################################################################
##
#O  Remove( <M>[, <pos>] )
##
##  <#GAPDoc Label="RowListMatObj_Remove">
##  <ManSection>
##  <Oper Name="Remove" Arg='M[, pos]' Label="for a row list matrix"/>
##
##  <Returns>a vector object if the removed row exists,
##   otherwise nothing</Returns>
##
##  <Description>
##  For a mutable row list matrix <A>M</A>,
##  this operation removes the <A>pos</A>-th row and shifts the later rows
##  down by one position.
##  The default for <A>pos</A> is the number of rows of <A>M</A>.
##  <P/>
##  If the <A>pos</A>-th row existed in <A>M</A> then it is returned,
##  otherwise nothing is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Remove", [ IsRowListMatrix ] );
DeclareOperation( "Remove", [ IsRowListMatrix, IsPosInt ] );


#############################################################################
##
#O  Append( <rowlistmat1>, <rowlistmat2> )
##
##  <#GAPDoc Label="RowListMatObj_Append">
##  <ManSection>
##  <Oper Name="Append" Arg='M1, M2' Label="for two row list matrices"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For two row list matrices <A>M1</A>, <A>M2</A>
##  such that <A>M1</A> is mutable and such that the
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> values are equal,
##  this operation appends the rows of <A>M2</A> to the
##  rows of <A>M1</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Append", [ IsRowListMatrix, IsRowListMatrix ] );


#############################################################################
##
#O  ShallowCopy( <M> )
##
##  <#GAPDoc Label="RowListMatObj_ShallowCopy">
##  <ManSection>
##  <Oper Name="ShallowCopy" Arg='M' Label="for a row list matrix"/>
##
##  <Returns>a matrix object</Returns>
##
##  <Description>
##  For a row list matrix <A>M</A>,
##  this operation returns a new mutable matrix with the same
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> values as <A>M</A>,
##  which shares its rows with <A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#O  ListOp( <M>[ <func> ] )
##
##  <#GAPDoc Label="RowListMatObj_ListOp">
##  <ManSection>
##  <Oper Name="ListOp" Arg='M[, func]' Label="for a row list matrix"/>
##
##  <Returns>a plain list</Returns>
##
##  <Description>
##  For a row list matrix <A>M</A>,
##  the variant with one argument returns the plain list
##  (see <Ref Filt="IsPlistRep"/>) of its rows,
##  and the variant with two arguments returns the plain list of values
##  of these rows under the function <A>func</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ListOp", [ IsRowListMatrix ] );
DeclareOperation( "ListOp", [ IsRowListMatrix, IsFunction ] );


#############################################################################
##
##  IsEmptyMatrix( <matobj> )
##
##  <#GAPDoc Label="MatObj_IsEmptyMatrix">
##  <ManSection>
##    <Prop Name="IsEmptyMatrix" Arg='M' Label="for a matrix object"/>
##    <Returns>A boolean</Returns>
##    <Description>
##      Is <K>true</K> if the matrix object <A>M</A> either has zero columns
##      or zero rows, and <K>false</K> otherwise.
##      In other words, a matrix object is empty if it has no entries.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsEmptyMatrix", IsMatrixOrMatrixObj );


#############################################################################
##
##  TODO:
##
##  Do we REALLY want to support and document the following feature?
##  If yes then it is intended as permanent,
##  although it contradicts the intended use of matrix objects.
##
##  Is this a feature with a generic solution,
##  such that the implementors of new kinds of matrix objects need not
##  care about it?
##  If not then it will be very annoying to be forced to support something
##  which will not be used at all as long as the code is used as intended.
##  (In particular, the documentation claims on the one hand that it is not
##  compulsory to provide a compatible vector object representation for one's
##  matrix object implementation, but the ``row access'' will force one to
##  provide one.)

############################################################################
# In the following sense matrices behave like lists:
############################################################################

DeclareOperation( "[]", [IsMatrixOrMatrixObj,IsPosInt] );  # <mat>, <pos>
# This is guaranteed to return a vector object that has the property
# that changing it changes <pos>th row (?) of the matrix <mat>!
# A matrix which is not a row-lists internally has to create an intermediate object that refers to some
# row within it to allow the old GAP syntax M[i][j] for read and write
# access to work. Note that this will never be particularly efficient
# for matrices which are not row-lists. Efficient code will have to use MatElm and
# SetMatElm instead.

# TODO:   ... resp. it will use use M[i,j]
# TODO: provide a default method which creates a proxy object for the given row
# and translates accesses to it to corresponding MatElm / SetMatElm calls;
#  creating such a proxy object prints an InfoWarning;
# but for the method for plist matrices, no warning is shown, as it is efficient
# anyway

# TODO: maybe also add GetRow(mat, i) and GetColumn(mat, i) ???
#  these return IsVectorObj objects.
# these again must be objects which are "linked" to the original matrix, as above...
# TODO: perhaps also have ExtractRow(mat, i) and ExtractColumn(mat, i)


#############################################################################
##
##  Backwards compatibility
##
##  We have to declare the operations/synonyms because otherwise
##  the method installations in some packages may not work.
##  We should remove them as soon as they are not used anymore.
##

#############################################################################
##
#C  IsRowVectorObj( <obj> )
##
##  Existing code which uses this name (most notably, the cvec package)
##  should be supported for some time.
##
DeclareSynonym( "IsRowVectorObj", IsVectorObj );


#############################################################################
##
#A  DimensionsMat( <matobj> )
##
##  only for backwards compatibility with existing code:
##  <matobj> -> [ NrRows( <matobj> ), NrCols( <matobj> ) ]
##
DeclareAttribute( "DimensionsMat", IsMatrixOrMatrixObj );


#############################################################################
##
#A  Length( <matobj> )
#A  RowLength( <matobj> )
##
##  They had been used in older versions.
##
DeclareAttribute( "Length", IsMatrixOrMatrixObj );
DeclareSynonymAttr( "RowLength", NumberColumns );


#############################################################################
##
#O  NewCompanionMatrix( <filt>, <pol>, <R> )
##
##  This operation is intended for the installation of tag based methods for
##  'CompanionMatrix', such that 'CompanionMatrix' admits method dispatch
##  based on <filt>.
##
##  (Currently 'NewCompanionMatrix' is undocumented.
##  Perhaps we can simply declare 'CompanionMatrix' itself as a tag based
##  operation for the given requirement.
##  This would work also for `DiagonalMatrix`, `RandomMatrix`,
##  `ReflectionMatrix`, etc.
##  We could even get rid of `NewMatrix`, `NewZeroMatrix`,
##  `NewIdentityMatrix`, by declaring `Matrix`, `ZeroMatrix`,
##  `IdentityMatrix` as tag based operations for the requirements in
##  question, except that the ordering of the arguments for the four
##  argument versions of `NewMatrix` and `Matrix` does not fit.)
##
DeclareTagBasedOperation( "NewCompanionMatrix",
    [ IsOperation, IsUnivariatePolynomial, IsSemiring ] );


#############################################################################
##
#O  NewRowVector( ... )
##
DeclareSynonym( "NewRowVector", NewVector );


#############################################################################
##
#O  Randomize( ... )
##
##  for backwards compatibility with the cvec package
##
DeclareOperation( "Randomize", [ IsVectorObj and IsMutable, IsRandomSource ] );
DeclareOperation( "Randomize", [ IsMatrixOrMatrixObj and IsMutable, IsRandomSource ] );


#############################################################################
##
#O  <matobj>[ <i>, <j> ]
#O  <matobj>[ <i>, <j> ]:= <obj>
##
DeclareOperation( "[]", [ IsMatrixOrMatrixObj, IsPosInt, IsPosInt ] );
DeclareOperation( "[]:=", [ IsMatrixOrMatrixObj, IsPosInt, IsPosInt, IsObject ] );


############################################################################
# Elementary matrix operations
############################################################################
#
############################################################################
##
##  <#GAPDoc Label="MultMatrixRow">
##  <ManSection>
##  <Oper Name="MultMatrixRowLeft" Arg='mat,i,elm'/>
##  <Oper Name="MultMatrixRow" Arg='mat,i,elm'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  <P/>
##  Multiplies the <A>i</A>-th row of the mutable matrix <A>mat</A> with the scalar
##  <A>elm</A> from the left in-place.
##  <P/>
##  <Ref Oper="MultMatrixRow"/> is a synonym of <Ref Oper="MultMatrixRowLeft"/>. This was chosen
##  because linear combinations of rows of matrices are usually written as
##  <M> v \cdot A = [v_1, ... ,v_n] \cdot A</M> which multiplies scalars from the left.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MultMatrixRowLeft", [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsObject ] );
DeclareSynonym( "MultMatrixRow", MultMatrixRowLeft);

############################################################################
##
##  <#GAPDoc Label="MultMatrixRowRight">
##  <ManSection>
##  <Oper Name="MultMatrixRowRight" Arg='M,i,elm'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  <P/>
##  Multiplies the <A>i</A>-th row of the mutable matrix <A>M</A> with the scalar
##  <A>elm</A> from the right in-place.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MultMatrixRowRight", [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsObject ]);

############################################################################
##
##  <#GAPDoc Label="MultMatrixColumn">
##  <ManSection>
##  <Oper Name="MultMatrixColumnRight" Arg='M,i,elm'/>
##  <Oper Name="MultMatrixColumn" Arg='M,i,elm'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  <P/>
##  Multiplies the <A>i</A>-th column of the mutable matrix <A>M</A> with the scalar
##  <A>elm</A> from the right in-place.
##  <P/>
##  <Ref Oper="MultMatrixColumn"/> is a synonym of <Ref Oper="MultMatrixColumnRight"/>. This was
##  chosen because linear combinations of columns of matrices are usually written as
##  <M>A \cdot v^T = A \cdot [v_1, ... ,v_n]^T</M> which multiplies scalars from the right.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MultMatrixColumnRight", [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsObject ] );
DeclareSynonym( "MultMatrixColumn",  MultMatrixColumnRight);

############################################################################
##
##  <#GAPDoc Label="MultMatrixColumnLeft">
##  <ManSection>
##  <Oper Name="MultMatrixColumnLeft" Arg='M,i,elm'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  <P/>
##  Multiplies the <A>i</A>-th column of the mutable matrix <A>M</A> with the scalar
##  <A>elm</A> from the left in-place.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MultMatrixColumnLeft", [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsObject ] );

############################################################################
##
##  <#GAPDoc Label="AddMatrixRows">
##  <ManSection>
##  <Oper Name="AddMatrixRowsLeft" Arg='M,i,j,elm'/>
##  <Oper Name="AddMatrixRows" Arg='M,i,j,elm'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  <P/>
##  Adds the product of <A>elm</A> with the <A>j</A>-th row of the mutable matrix <A>M</A> to its <A>i</A>-th
##  row in-place. The <A>j</A>-th row is multiplied with <A>elm</A> from the left.
##  <P/>
##  <Ref Oper="AddMatrixRows"/> is a synonym of <Ref Oper="AddMatrixRowsLeft"/>. This was chosen
##  because linear combinations of rows of matrices are usually written as
##  <M> v \cdot A = [v_1, ... ,v_n] \cdot A</M> which multiplies scalars from the left.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AddMatrixRowsLeft", [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt, IsObject ] );
DeclareSynonym( "AddMatrixRows", AddMatrixRowsLeft);

############################################################################
##
##  <#GAPDoc Label="AddMatrixRowsRight">
##  <ManSection>
##  <Oper Name="AddMatrixRowsRight" Arg='M,i,j,elm'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  <P/>
##  Adds the product of <A>elm</A> with the <A>j</A>-th row of the mutable matrix <A>M</A> to its <A>i</A>-th
##  row in-place. The <A>j</A>-th row is multiplied with <A>elm</A> from the right.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AddMatrixRowsRight", [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt, IsObject ] );

############################################################################
##
##  <#GAPDoc Label="AddMatrixColumns">
##  <ManSection>
##  <Oper Name="AddMatrixColumnsRight" Arg='M,i,j,elm'/>
##  <Oper Name="AddMatrixColumns" Arg='M,i,j,elm'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  <P/>
##  Adds the product of <A>elm</A> with the <A>j</A>-th column of the mutable matrix <A>M</A> to its <A>i</A>-th
##  column in-place. The <A>j</A>-th column is multiplied with <A>elm</A> from the right.
##  <P/>
##  <Ref Oper="AddMatrixColumns"/> is a synonym of <Ref Oper="AddMatrixColumnsRight"/>. This was
##  chosen because linear combinations of columns of matrices are usually written as
##  <M>A \cdot v^T = A \cdot [v_1, ... ,v_n]^T</M> which multiplies scalars from the right.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AddMatrixColumnsRight", [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt, IsObject ] );
DeclareSynonym( "AddMatrixColumns", AddMatrixColumnsRight);

############################################################################
##
##  <#GAPDoc Label="AddMatrixColumnsLeft">
##  <ManSection>
##  <Oper Name="AddMatrixColumnsLeft" Arg='M,i,j,elm'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  <P/>
##  Adds the product of <A>elm</A> with the <A>j</A>-th column of the mutable matrix <A>M</A> to its <A>i</A>-th
##  column in-place. The <A>j</A>-th column is multiplied with <A>elm</A> from the left.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AddMatrixColumnsLeft", [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt, IsObject ] );

############################################################################
##
##  <#GAPDoc Label="SwapMatrixRows">
##  <ManSection>
##  <Oper Name="SwapMatrixRows" Arg='M,i,j'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  <P/>
##  Swaps the <A>i</A>-th row and <A>j</A>-th row of a mutable matrix <A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "SwapMatrixRows", [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt ], SWAP_MAT_ROWS );

############################################################################
##
##  <#GAPDoc Label="SwapMatrixColumns">
##  <ManSection>
##  <Oper Name="SwapMatrixColumns" Arg='M,i,j'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  <P/>
##  Swaps the <A>i</A>-th column and <A>j</A>-th column of a mutable matrix <A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "SwapMatrixColumns", [ IsMatrixOrMatrixObj and IsMutable, IsInt, IsInt ], SWAP_MAT_COLS );
