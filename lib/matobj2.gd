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
##  In this file all the operations, attributes and constructors are defined.
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
##  An abstract matrix should be thought of as represented by
##  a matrix object; it can be detected from the filter
##  <Ref Filt="IsMatrixObj"/>, whereas the filter <Ref Filt="IsMatrix"/>
##  denotes matrices represented by lists of lists.
##  We regard the objects in <Ref Filt="IsMatrix"/> as special cases of
##  objects in <Ref Filt="IsMatrixObj"/>.)
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
##  <#/GAPDoc>
##


#############################################################################
##
#A  BaseDomain( <vector> )
#A  BaseDomain( <matrix> )
##
##  <#GAPDoc Label="BaseDomain">
##  <ManSection>
##  <Heading>BaseDomain</Heading>
##  <Attr Name="BaseDomain" Arg='vector' Label="for a vector object"/>
##  <Attr Name="BaseDomain" Arg='matrix' Label="for a matrix object"/>
##
##  <Description>
##  The vector object <A>vector</A> or matrix object <A>matrix</A>,
##  respectively, is defined over the domain given by its
##  <Ref Attr="BaseDomain" Label="for a vector object"/> value.
##  <P/>
##  Note that not all entries of the object necessarily lie in
##  its base domain with respect to
##  <Ref Oper="\in" Label="for a collection"/>, see Section
##  <Ref Sect="Concepts and Rules for Vector and Matrix Objects"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "BaseDomain", IsVectorObj );
DeclareAttribute( "BaseDomain", IsMatrixObj );


#############################################################################
##
#A  NumberRows( <M> )
#A  NrRows( <M> )
#A  NumberColumns( <M> )
#A  NrCols( <M> )
##
##  <#GAPDoc Label="NumberRowsNumberColumns">
##  <ManSection>
##  <Heading>NumberRows and NumberColumns</Heading>
##  <Attr Name="NumberRows" Arg='M' Label="for a matrix object"/>
##  <Attr Name="NrRows" Arg='M' Label="for a matrix object"/>
##  <Attr Name="NumberColumns" Arg='M' Label="for a matrix object"/>
##  <Attr Name="NrCols" Arg='M' Label="for a matrix object"/>
##
##  <Description>
##  For a matrix object <A>M</A>,
##  <Ref Attr="NumberRows" Label="for a matrix object"/> and
##  <Ref Attr="NumberColumns" Label="for a matrix object"/> store the
##  number of rows and columns of <A>M</A>, respectively.
##  <P/>
##  <Ref Attr="NrRows" Label="for a matrix object"/> and
##  <Ref Attr="NrCols" Label="for a matrix object"/> are synonyms of
##  <Ref Attr="NumberRows" Label="for a matrix object"/> and
##  <Ref Attr="NumberColumns" Label="for a matrix object"/>, respectively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NumberRows", IsMatrixObj );
DeclareSynonymAttr( "NrRows", NumberRows );

DeclareAttribute( "NumberColumns", IsMatrixObj );
DeclareSynonymAttr( "NrCols", NumberColumns );


#############################################################################
##
#A  OneOfBaseDomain( <v> )
#A  OneOfBaseDomain( <M> )
#A  ZeroOfBaseDomain( <v> )
#A  ZeroOfBaseDomain( <M> )
##
##  <#GAPDoc Label="OneOfBaseDomain">
##  <ManSection>
##  <Heading>OneOfBaseDomain and ZeroOfBaseDomain</Heading>
##  <Attr Name="OneOfBaseDomain" Arg='v' Label="for a vector object"/>
##  <Attr Name="OneOfBaseDomain" Arg='M' Label="for a matrix object"/>
##  <Attr Name="ZeroOfBaseDomain" Arg='v' Label="for a vector object"/>
##  <Attr Name="ZeroOfBaseDomain" Arg='M' Label="for a matrix object"/>
##
##  <Description>
##  These attributes return the identity element and the zero element
##  of the <Ref Attr="BaseDomain" Label="for a vector object"/> value
##  of the vector object <A>v</A> or the matrix object <A>M</A>,
##  respectively.
##  <P/>
##  If <A>v</A> or <A>M</A>, respectively, is a plain list
##  (see <Ref Filt="IsPlistRep"/>) then computing its
##  <Ref Attr="BaseDomain" Label="for a vector object"/> value can be
##  regarded as expensive,
##  whereas calling <Ref Attr="OneOfBaseDomain" Label="for a vector object"/>
##  or <Ref Attr="ZeroOfBaseDomain" Label="for a vector object"/>
##  can be regarded as cheap.
##  If <A>v</A> or <A>M</A>, respectively, is not a plain list then
##  one can also call <Ref Attr="BaseDomain" Label="for a vector object"/>
##  first, without loss of performance.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "OneOfBaseDomain", IsVectorObj );
DeclareAttribute( "OneOfBaseDomain", IsMatrixObj );

DeclareAttribute( "ZeroOfBaseDomain", IsVectorObj );
DeclareAttribute( "ZeroOfBaseDomain", IsMatrixObj );


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
##  <Ref Constr="NewVector"/> or <Ref Constr="NewMatrix"/>, respectively,
##  is called with <C>f</C> then a vector object or a matrix object,
##  respectively, in the same representation as the argument is produced.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ConstructingFilter", IsVectorObj );
DeclareAttribute( "ConstructingFilter", IsMatrixObj );


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
DeclareAttribute( "CompatibleVectorFilter", IsMatrixObj );


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
##  <A>v</A><C>{</C><A>list</A><C>}</C> returns a vector object in the same
##  representation as <A>v</A>
##  (see <Ref Attr="ConstructingFilter" Label="for a vector object"/>)
##  that contains the <A>list</A><M>[ k ]</M>-th entry of <A>v</A> at
##  position <M>k</M>.
##  <P/>
##  It is not specified what happens if <A>i</A> is larger than the length
##  of <A>v</A>,
##  or if <A>obj</A> is not in the base domain of <A>v</A>,
##  or if <A>list</A> contains entries not in the allowed range.
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
DeclareOperation( "Unpack", [ IsVectorObj ] );
DeclareOperation( "Unpack", [ IsMatrixObj ] );


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
##  <Oper Name="AddVector" Arg='dst, src[, from, to]'
##   Label="for two vector objects"/>
##  <Oper Name="AddVector" Arg='dst, mul, src[, from, to]'
##   Label="for a vector object"/>
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
#O  MultVector( <vec>, <mul>[, <from>, <to>] )
#O  MultVectorLeft( <vec>, <mul>[, <from>, <to>] )
#O  MultVectorRight( <vec>, <mul>[, <from>, <to>] )
##
##  <#GAPDoc Label="MatObj_MultVectorLeft">
##  <ManSection>
##  <Oper Name="MultVector" Arg='vec, mul[, from, to]'
##   Label="for a vector object"/>
##  <Oper Name="MultVectorLeft" Arg='vec, mul[, from, to]'
##   Label="for a vector object"/>
##  <Oper Name="MultVectorRight" Arg='vec, mul[, from, to]'
##   Label="for a vector object"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  These operations multiply <A>mul</A> with <A>vec</A> in-place
##  where <Ref Oper="MultVectorLeft" Label="for a vector object"/>
##  multiplies with <A>mul</A> from the left
##  and <Ref Oper="MultVectorRight" Label="for a vector object"/>
##  does so from the right.
##  <P/>
##  Note that <Ref Oper="MultVector" Label="for a vector object"/>
##  is just a synonym for
##  <Ref Oper="MultVectorLeft" Label="for a vector object"/>.
##  <P/>
##  If the optional parameters <A>from</A> and <A>to</A> are given then
##  only the index range <C>[<A>from</A>..<A>to</A>]</C> is guaranteed to be
##  affected. Other indices <E>may</E> be affected, if it is more convenient
##  to do so.
##  This can be helpful if entries of <A>vec</A> are known to be zero.
##  <P/>
##  If <A>from</A> is bigger than <A>to</A>, the operation does nothing.
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
#O  ZeroVector( <len>, <v> )
#O  ZeroVector( <len>, <M> )
##
##  <#GAPDoc Label="VectorObj_ZeroVector">
##  <ManSection>
##  <Heading>ZeroVector</Heading>
##  <Oper Name="ZeroVector" Arg="l,v" Label="for length and vector object"/>
##  <Oper Name="ZeroVector" Arg="l,M" Label="for length and matrix object"/>
##
##  <Returns>a vector object</Returns>
##  <Description>
##  For a vector object <A>v</A> and a nonnegative integer <A>l</A>,
##  this operation returns a new mutable vector object of length <A>l</A>
##  in the same representation as <A>v</A> containing only zeros.
##  <P/>
##  For a matrix object <A>M</A> and a nonnegative integer <A>l</A>,
##  this operation returns a new mutable zero vector object of length
##  <A>l</A> in the representation given by the
##  <Ref Attr="CompatibleVectorFilter" Label="for a matrix object"/> value
##  of <A>M</A>, provided that such a representation exists.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ZeroVector", [ IsInt, IsVectorObj ] );
DeclareOperation( "ZeroVector", [ IsInt, IsMatrixObj ] );


#############################################################################
##
#O  Vector( <filt>, <R>, <list> )
#O  Vector( <filt>, <R>, <vec> )
#O  Vector( <R>, <list> )
#O  Vector( <R>, <vec> )
#O  Vector( <list>, <vec> )
#O  Vector( <vec1>, <vec2> )
##
##  <#GAPDoc Label="Vector">
##  <ManSection>
##  <Heading>Vector</Heading>
##  <Oper Name="Vector" Arg='filt,R,list'
##   Label="for filter, base domain, and list"/>
##  <Oper Name="Vector" Arg='filt,R,vec'
##   Label="for filter, base domain, and vector object"/>
##  <Oper Name="Vector" Arg='R,list'
##   Label="for base domain and list"/>
##  <Oper Name="Vector" Arg='R,vec'
##   Label="for base domain and vector object"/>
##  <Oper Name="Vector" Arg='list,vec'
##   Label="for a list and a vector object"/>
##  <Oper Name="Vector" Arg='vec1,vec2'
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
##  <A>vec</A>, respectively.
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
##  It is <E>not</E> guaranteed that the given list of entries is copied.
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
##  <Constr Name="NewVector" Arg='filt,R,list'/>
##  <Constr Name="NewZeroVector" Arg='filt,R,n'/>
##
##  <Description>
##  For a filter <A>filt</A>, a semiring <A>R</A>, and a list <A>list</A>
##  of elements that belong to <A>R</A>,
##  <Ref Constr="NewVector"/> returns a mutable vector object which has
##  the <Ref Attr="ConstructingFilter" Label="for a vector object"/>
##  <A>filt</A>,
##  the <Ref Attr="BaseDomain" Label="for a vector object"/> <A>R</A>,
##  and the entries in <A>list</A>.
##  The list <A>list</A> is guaranteed not to be changed by this operation.
##  <P/>
##  Similarly, <Ref Constr="NewZeroVector"/> returns a mutable vector object
##  of length <A>n</A> which has <A>filt</A> and <A>R</A> as
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> and
##  <Ref Attr="BaseDomain" Label="for a vector object"/> values,
##  and contains the zero of <A>R</A> in each position.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareConstructor( "NewVector", [ IsVectorObj, IsSemiring, IsList ] );

DeclareConstructor( "NewZeroVector", [ IsVectorObj, IsSemiring, IsInt ] );


#############################################################################
##
#O  NewMatrix( <filt>, <R>, <ncols>, <list> )
#O  NewZeroMatrix( <filt>, <R>, <m>, <n> )
#O  NewIdentityMatrix( <filt>, <R>, <n> )
##
##  <#GAPDoc Label="NewMatrix">
##  <ManSection>
##  <Heading>NewMatrix, NewZeroMatrix, NewIdentityMatrix</Heading>
##  <Constr Name="NewMatrix" Arg='filt,R,ncols,list'/>
##  <Constr Name="NewZeroMatrix" Arg='filt,R,m,n'/>
##  <Constr Name="NewIdentityMatrix" Arg='filt,R,n'/>
##
##  <Description>
##  For a filter <A>filt</A>, a semiring <A>R</A>,
##  a positive integer <A>ncols</A>, and a list <A>list</A>,
##  <Ref Constr="NewMatrix"/> returns a mutable matrix object which has
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
##  Similarly, <Ref Constr="NewZeroMatrix"/> returns a mutable zero matrix
##  object with <A>m</A> rows and <A>n</A> columns
##  which has <A>filt</A> and <A>R</A> as
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> and
##  <Ref Attr="BaseDomain" Label="for a vector object"/> values.
##  <P/>
##  Similarly, <Ref Constr="NewIdentityMatrix"/> returns a mutable identity
##  matrix object with <A>m</A> rows and <A>n</A> columns
##  which has <A>filt</A> and <A>R</A> as
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> and
##  <Ref Attr="BaseDomain" Label="for a vector object"/> values,
##  and contains the identity element of <A>R</A> in the diagonal
##  and the zero of <A>R</A> in each off-diagonal position.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareConstructor( "NewMatrix", [ IsMatrixObj, IsSemiring, IsInt, IsList] );

DeclareConstructor( "NewZeroMatrix",
    [ IsMatrixObj, IsSemiring, IsInt, IsInt ] );

DeclareConstructor( "NewIdentityMatrix",
    [ IsMatrixObj, IsSemiring, IsInt ] );


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
DeclareOperation( "ChangedBaseDomain", [ IsVectorObj, IsSemiring ] );
DeclareOperation( "ChangedBaseDomain", [ IsMatrixObj, IsSemiring ] );


############################################################################
##
##  <ManSection>
##  <Func Name="MakeVector" Arg='list[,R]'/>
##
##  <Description>
##  This is a convenience function for creating a vector object defined over
##  the base domain <A>R</A> from the dense list <A>list</A> of intended
##  entries.
##  If <A>R</A> is not given then a guess is made, based on the possible
##  <Ref Attr="ConstructingFilter" Label="for a vector object"/> values
##  known to the function.
##  <P/>
##  This is not guaranteed to be efficient.
##  In library or package code, one should better use
##  <Ref Oper="NewVector"/> or <Ref Oper="Vector"/>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "MakeVector" );


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
DeclareOperation( "Randomize", [ IsMatrixObj and IsMutable ] );
DeclareOperation( "Randomize", [ IsRandomSource, IsMatrixObj and IsMutable ] );


#############################################################################
##
#O  CopySubVector( <dst>, <dcols>, <src>, <scols> )
##
##  <#GAPDoc Label="CopySubVector">
##  <ManSection>
##  <Oper Name="CopySubVector" Arg='dst, dcols, src, scols'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For two vector objects <A>dst</A> and <A>src</A>,
##  such that <A>dst</A> is mutable,
##  and two lists <A>dcols</A> and <A>scols</A> of positions,
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
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CopySubVector",
    [ IsVectorObj and IsMutable, IsList, IsVectorObj, IsList ] );


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
#O  ExtractSubMatrix( <mat>, <rows>, <cols> )
##
##  <#GAPDoc Label="ExtractSubMatrix">
##  <ManSection>
##  <Oper Name="ExtractSubMatrix" Arg='mat, rows, cols'/>
##
##  <Description>
##  Creates a fully mutable copy of the submatrix described by the two
##  lists, which mean subsets of row and column positions, respectively.
##  This does <A>mat</A>{<A>rows</A>}{<A>cols</A>} and returns the result.
##  It preserves the representation of the matrix.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExtractSubMatrix", [ IsMatrixObj, IsList, IsList ] );


#############################################################################
##
#O  MutableCopyMatrix( <mat> )
##
##  <#GAPDoc Label="MutableCopyMatrix">
##  <ManSection>
##  <Oper Name="MutableCopyMatrix" Arg='mat' Label="for a matrix object"/>
##
##  <Description>
##  For a matrix object <A>mat</A>, this operation returns a fully mutable
##  copy of <A>mat</A>, with the same
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> values,
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "MutableCopyMatrix", [ IsMatrixObj ] );


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
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CopySubMatrix",
    [ IsMatrixObj, IsMatrixObj, IsList, IsList, IsList, IsList ] );


#############################################################################
##
#O  MatElm( <mat>, <row>, <col> )  . . . . . .  select an entry from a matrix
#O  <mat>[ <row>, <col> ]  . . . . . . . . . .  select an entry from a matrix
##
##  <#GAPDoc Label="MatObj_MatElm">
##  <ManSection>
##  <Oper Name="MatElm" Arg='mat, row, col'/>
##
##  <Returns>an entry of the matrix object</Returns>
##
##  <Description>
##  For a matrix object <A>mat</A>, this operation returns the entry in
##  row <A>row</A> and column <A>col</A>.
##  <P/>
##  Also the syntax <A>mat</A><C>[ </C><A>row</A><C>, </C><A>col</A><C> ]</C>
##  is supported.
##  <P/>
##  Note that this is <E>not</E> equivalent to
##  <A>mat</A><C>[ </C><A>row</A><C> ][ </C><A>col</A><C> ]</C>,
##  which would first try to access <A>mat</A><C>[ </C><A>row</A><C> ]</C>,
##  and this is in general not possible.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "MatElm", [ IsMatrixObj, IS_INT, IS_INT ], ELM_MAT );
DeclareSynonym( "[,]", ELM_MAT );


#############################################################################
##
#O  SetMatElm( <mat>, <row>, <col>, <obj> )  . . . . set an entry in a matrix
#O  <mat>[ <row>, <col> ]:= <obj>  . . . . . . . . . set an entry in a matrix
##
##  <#GAPDoc Label="MatObj_SetMatElm">
##  <ManSection>
##  <Oper Name="SetMatElm" Arg='mat, row, col, obj'/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For a mutable matrix object <A>mat</A>, this operation assigns the object
##  <A>obj</A> to the position in row <A>row</A> and column <A>col</A>,
##  provided that <A>obj</A> is compatible with the
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> value of <A>mat</A>.
##  <P/>
##  Also the syntax
##  <A>mat</A><C>[ </C><A>row</A><C>, </C><A>col</A><C> ]:= </C><A>obj</A>
##  is supported.
##  <P/>
##  Note that this is <E>not</E> equivalent to
##  <A>mat</A><C>[ </C><A>row</A><C> ][ </C><A>col</A><C> ]:= </C><A>obj</A>,
##  which would first try to access <A>mat</A><C>[ </C><A>row</A><C> ]</C>,
##  and this is in general not possible.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperationKernel( "SetMatElm", [ IsMatrixObj, IsInt, IsInt, IsObject ],
    ASS_MAT );
#T We want to require also 'IsMutable' for the first argument,
#T but some package may have installed methods without this requirement.
#T Note that if we declare the operation twice, once with requirement
#T 'IsMutable' and once without, each method installation will show
#T a complaint that it matches more than one declaration.
DeclareSynonym( "[,]:=", ASS_MAT );


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
##  and <A>n</A>, this operation returns a new fully mutable matrix object
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
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ZeroMatrix", [ IsInt, IsInt, IsMatrixObj ] );
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
##  this operation returns a new fully mutable identity matrix object
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
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IdentityMatrix", [ IsInt, IsMatrixObj ] );
DeclareOperation( "IdentityMatrix", [ IsSemiring, IsInt ] );
DeclareOperation( "IdentityMatrix", [ IsOperation, IsSemiring, IsInt ] );


#############################################################################
##
#O  CompanionMatrix( <pol>, <M> )
#O  CompanionMatrix( <filt>, <pol>, <R> )
##
##  <#GAPDoc Label="MatObj_CompanionMatrix">
##  <ManSection>
##  <Heading>CompanionMatrix</Heading>
##  <Oper Name="CompanionMatrix" Arg='pol, M'
##   Label="for polynomial and matrix object"/>
##  <Oper Name="CompanionMatrix" Arg='filt, pol, R'
##   Label="for filter, polynomial, and semiring"/>
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
##  We use row convention, that is, the negatives of the coefficients of
##  <A>pol</A> appear in the last row of the result.
##  <P/>
##  If a filter <A>filt</A> and a semiring <A>R</A> are given then the
##  companion matrix is returned as a matrix object with
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> value
##  <A>filt</A> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> value <A>R</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  (The variant with filter and semiring is used as a simpler alternative
##  to a possible constructor 'NewCompanionMatrix'.)
##
DeclareOperation( "CompanionMatrix",
    [ IsUnivariatePolynomial, IsMatrixObj ] );
DeclareOperation( "CompanionMatrix",
    [ IsOperation, IsUnivariatePolynomial, IsSemiring ] );


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
##  Here <A>list</A> can be either a list of plain list that describe the
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
##  It is guaranteed that the given list <A>list</A> is copied in the sense
##  of <Ref Oper="ShallowCopy"/>.
##  If <A>list</A> is a nested list then it is <E>not</E> guaranteed
##  that also the entries of <A>list</A> are copied.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Matrix", [ IsOperation, IsSemiring, IsList, IsInt ] );
DeclareOperation( "Matrix", [ IsOperation, IsSemiring, IsList ] );
DeclareOperation( "Matrix", [ IsOperation, IsSemiring, IsMatrixObj ] );
DeclareOperation( "Matrix", [ IsSemiring, IsList, IsInt ] );
DeclareOperation( "Matrix", [ IsSemiring, IsList ] );
DeclareOperation( "Matrix", [ IsSemiring, IsMatrixObj ] );
DeclareOperation( "Matrix", [ IsList, IsInt, IsMatrixObj ] );
DeclareOperation( "Matrix", [ IsList, IsMatrixObj ] );
DeclareOperation( "Matrix", [ IsMatrixObj, IsMatrixObj ] );
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
##  this operation returns a zero vector object <M>v</M> of length <M>m</M>
##  and in the representation given by the
##  <Ref Attr="CompatibleVectorFilter" Label="for a matrix object"/> value
##  of <A>M</A> (provided that such a representation exists).
##  <P/>
##  The idea is that there should be an efficient way to multiply <M>v</M>
##  and <A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CompatibleVector", [ IsMatrixObj ] );


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
DeclareAttribute( "RowsOfMatrix", IsMatrixObj );


#############################################################################
##
##  Operations for Row List Matrix Objects
##


############################################################################
##
#O  <mat>[ <pos> ]<vec>
##
##  <#GAPDoc Label="RowListMatObj_[]">
##  <ManSection>
##  <Heading>List Access for a Row List Matrix</Heading>
##  <Oper Name="\[\]" Arg='mat, pos' Label="for a row list matrix"/>
##
##  <Returns>a vector object</Returns>
##
##  <Description>
##  If <A>mat</A> is a row list matrix and if <A>pos</A> is a
##  positive integer not larger than the number of rows of <A>mat</A>,
##  this operation returns the <A>pos</A>-th row of <A>mat</A>.
##  <P/>
##  It is not specified what happens if <A>pos</A> is larger.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "[]", [ IsRowListMatrix, IsPosInt ] );


############################################################################
##
#O  <mat>[ <pos> ]:= <vec>
##
##  <#GAPDoc Label="RowListMatObj_[]_ASS">
##  <ManSection>
##  <Heading>List Assignment for a Row List Matrix</Heading>
##  <Oper Name="\[\]\:\=" Arg='mat, pos, vec'
##   Label="for a row list matrix and a vector object"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  If <A>mat</A> is a row list matrix, <A>vec</A> is a vector object
##  that can occur as a row in <A>rowlistmat</A>
##  (that is, <A>vec</A> has the same base domain, the right length,
##  and the right vector representation),
##  and if <A>pos</A> is a positive integer not larger than
##  the number of rows of <A>mat</A> plus 1,
##  this operation sets <A>vec</A> as the <A>pos</A>-th row of
##  <A>mat</A>.
##  <P/>
##  In all other situations, it is not specified what happens.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "[]:=", [ IsRowListMatrix, IsPosInt, IsVectorObj ] );


#############################################################################
##
#O  <mat>{ <poss> }
##
##  <#GAPDoc Label="RowListMatObj_{}">
##  <ManSection>
##  <Heading>Sublist Access for a Row List Matrix</Heading>
##  <Oper Name="\{\}" Arg='mat, poss' Label="for a row list matrix"/>
##
##  <Returns>a row list matrix</Returns>
##
##  <Description>
##  For a row list matrix <A>mat</A> and a list <A>poss</A> of positions,
##  <A>mat</A><C>{ </C><A>poss</A><C> }</C> returns a new mutable
##  row list matrix with the same representation as <A>mat</A>,
##  whose rows are identical to the rows at the positions
##  in the list <A>poss</A> in <A>mat</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "{}", [IsRowListMatrix,IsList] );


#############################################################################
##
#O  <mat>{ <poss> }:= <mat2>
##
##  <#GAPDoc Label="RowListMatObj_{}_ASS">
##  <ManSection>
##  <Heading>Sublist Assignment for a Row List Matrix</Heading>
##  <Oper Name="\{\}\:\=" Arg='mat, poss, mat2' Label="for row list matrices"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For a mutable row list matrix <A>mat</A>, a list <A>poss</A> of
##  positions, and a row list matrix <A>mat2</A> of the same vector type
##  and with the same base domain,
##  <A>mat</A><C>{ </C><A>poss</A><C> }:= </C><A>mat2</A> assigns the rows
##  of <A>mat2</A> to the positions <A>poss</A> in the list of rows of
##  <A>mat</A>.
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
#O  IsBound\[\]( <mat>, <pos> )
##
##  <#GAPDoc Label="RowListMatObj_IsBound">
##  <ManSection>
##  <Oper Name="IsBound\[\]" Arg='mat, pos' Label="for a row list matrix"/>
##
##  <Returns><K>true</K> or <K>false</K></Returns>
##
##  <Description>
##  For a row list matrix <A>mat</A> and a positive integer <A>pos</A>,
##  <C>IsBound( </C><A>mat</A><C>[ </C><A>pos</A><C> ] )</C> returns
##  <K>true</K> if <A>pos</A> is at most the number of rows of <A>mat</A>,
##  and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsBound[]", [ IsRowListMatrix, IsPosInt ] );


#############################################################################
##
#O  Unbind\[\]( <mat>, <pos> )
##
##  <#GAPDoc Label="RowListMatObj_Unbind">
##  <ManSection>
##  <Oper Name="Unbind\[\]" Arg='mat, pos' Label="for a row list matrix"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For a mutable row list matrix <A>mat</A> with <A>pos</A> rows,
##  <C>Unbind( </C><A>mat</A><C>[ </C><A>pos</A><C> ] )</C> removes the last
##  row.
##  It is not specified what happens if <A>pos</A> has another value.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Unbind[]", [ IsRowListMatrix, IsPosInt ] );


#############################################################################
##
#O  Add( <mat>, <vec>[, <pos>] )
##
##  <#GAPDoc Label="RowListMatObj_Add">
##  <ManSection>
##  <Oper Name="Add" Arg='mat, vec[, pos]'
##   Label="for a row list matrix and a vector object"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For a mutable row list matrix <A>mat</A> and a vector object <A>vec</A>
##  that is compatible with the rows of <A>mat</A>,
##  the two argument version adds <A>vec</A> at the end of the list of rows
##  of <A>mat</A>.
##  <P/>
##  If a positive integer <A>pos</A> is given then <A>vec</A> is added in
##  position <A>pos</A>, and all later rows are shifted up by one position.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Add", [ IsRowListMatrix, IsVectorObj ] );
DeclareOperation( "Add", [ IsRowListMatrix, IsVectorObj, IsPosInt ] );


#############################################################################
##
#O  Remove( <mat>[, <pos>] )
##
##  <#GAPDoc Label="RowListMatObj_Remove">
##  <ManSection>
##  <Oper Name="Remove" Arg='mat[, pos]' Label="for a row list matrix"/>
##
##  <Returns>a vector object if the removed row exists,
##   otherwise nothing</Returns>
##
##  <Description>
##  For a mutable row list matrix <A>mat</A>,
##  this operation removes the <A>pos</A>-th row and shifts the later rows
##  down by one position.
##  The default for <A>pos</A> is the number of rows of <A>mat</A>.
##  <P/>
##  If the <A>pos</A>-th row existed in <A>mat</A> then it is returned,
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
##  <Oper Name="Append" Arg='mat1, mat2' Label="for two row list matrices"/>
##
##  <Returns>nothing</Returns>
##
##  <Description>
##  For two row list matrices <A>mat1</A>, <A>mat2</A>
##  such that <A>mat1</A> is mutable and such that the
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> values are equal,
##  this operation appends the rows of <A>mat2</A> to the
##  rows of <A>mat1</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Append", [ IsRowListMatrix, IsRowListMatrix ] );


#############################################################################
##
#O  ShallowCopy( <mat> )
##
##  <#GAPDoc Label="RowListMatObj_ShallowCopy">
##  <ManSection>
##  <Oper Name="ShallowCopy" Arg='mat' Label="for a row list matrix"/>
##
##  <Returns>a matrix object</Returns>
##
##  <Description>
##  For a row list matrix <A>mat</A>,
##  this operation returns a new mutable matrix with the same
##  <Ref Attr="ConstructingFilter" Label="for a matrix object"/> and
##  <Ref Attr="BaseDomain" Label="for a matrix object"/> values as <A>mat</A>,
##  which shares its rows with <A>mat</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##


#############################################################################
##
#O  ListOp( <mat>[ <func> ] )
##
##  <#GAPDoc Label="RowListMatObj_ListOp">
##  <ManSection>
##  <Oper Name="ListOp" Arg='mat[, func]' Label="for a row list matrix"/>
##
##  <Returns>a plain list</Returns>
##
##  <Description>
##  For a row list matrix <A>mat</A>,
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
DeclareProperty( "IsEmptyMatrix", IsMatrixObj );


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

DeclareOperation( "[]", [IsMatrixObj,IsPosInt] );  # <mat>, <pos>
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
DeclareAttribute( "DimensionsMat", IsMatrixObj );


#############################################################################
##
#A  Length( <matobj> )
#A  RowLength( <matobj> )
##
##  They had been used in older versions.
##
DeclareAttribute( "Length", IsMatrixObj );
DeclareSynonymAttr( "RowLength", NumberColumns );


#############################################################################
##
#O  NewCompanionMatrix( ... )
##
##  Once there was the idea to introduce a constructor 'NewCompanionMatrix',
##  and it is used in several library files, perhaps also in packages.
##  As a simpler replacement, there is now a method for the operation
##  'CompanionMatrix' which admits a filter as its first argument.
##  We should use 'CompanionMatrix' instead of 'NewCompanionMatrix'.
##
DeclareConstructor( "NewCompanionMatrix",
    [ IsMatrixObj, IsUnivariatePolynomial, IsSemiring ] );


#############################################################################
##
#O  NewRowVector( ... )
##
DeclareSynonym( "NewRowVector", NewVector );


#############################################################################
##
#O  CopySubVector( ... )
##
DeclareOperation( "CopySubVector",
    [ IsVectorObj, IsVectorObj and IsMutable, IsList, IsList ] );


#############################################################################
##
#O  Randomize( ... )
##
##  for backwards compatibility with the cvec package
##
DeclareOperation( "Randomize", [ IsVectorObj and IsMutable, IsRandomSource ] );
DeclareOperation( "Randomize", [ IsMatrixObj and IsMutable, IsRandomSource ] );


#############################################################################
##
#O  <matobj>[ <i>, <j> ]
#O  <matobj>[ <i>, <j> ]:= <obj>
##
DeclareOperation( "[]", [ IsMatrixObj, IsPosInt, IsPosInt ] );
DeclareOperation( "[]:=", [ IsMatrixObj, IsPosInt, IsPosInt, IsObject ] );


#############################################################################
##
##  Open items:
##
##  - renaming issues:
##    - There are functions 'RankMat', 'IsDiagonalMat', etc.
##      We should consistently introduce the corresponding names
##      'RankMatrix', 'IsDiagonalMatrix', etc. as main names,
##      and keep the 'Mat' names as synonyms,
##      and also keep these old names as documented if applicable.
##
##    - There are functions 'BaseIntMat', 'TriangulizeIntegerMat', etc.
##      Introduce the corresponding names 'BaseIntegerMatrix',
##      'TriangulizeIntegerMatrix', etc. as main names, keep the
##      'IntMat' or 'IntegerMat' names as synonyms,
##      and also keep the old names as documented if applicable.
##
##  - There is a problem with the operation 'Matrix'.
##    An *attribute* with this name is declared for certain semigroups,
##    in 'lib/reesmat.gd'.
##    In 'lib/matobj2.gd', 'Matrix' is declared as a *mutable attribute*
##    for lists; if it would not be declared as such then GAP's standard
##    machinery would cause that 'Matrix( <list> )' returns an *immutable*
##    value, which is not acceptable.
##    The declaration as a mutable attribute in 'lib/matobj2.gd' works
##    because this file is read before 'lib/reesmat.gd',
##    but the consequence is that the attribute values in the semigroup
##    context are also mutable (try the manual example for 'Matrix');
##    this is a bug.
##    (One could turn any attribute into a mutable one, by adding a
##    corresponding declaration early enough.)
##
##  - Just remove some downrankings of methods?
##    (There are comments in the code that this should be possible
##    from GAP 4.10 on.)
##
##  - The entry for "unbind a list entry" in the Reference Manual is
##    syntactically wrong, it is shown as 'Unbind( list[, n] )',
##    which means that 'n' is an optional argument.
##    The problem is that GAPDoc interprets 'Arg="list[n]"' this way,
##    and inserts the comma.
##
##  - Document 'PostMakeImmutable',
##    then mention that matrix objects may have to install methods for it.
##
##  - Do we really want to force 'IsCopyable' for all vector and matrix
##    objects?
##    One could think of an implementation where the objects are pointers
##    to data files which are just readable.
##    In such a situation, it is confusing that the object claims to be
##    copyable but 'ShallowCopy' or 'MutableCopyMatrix' will not work.
##
##  - Should 'IsRowVector' imply 'IsVectorObj',
##    in analogy to the implication from 'IsMatrix' to 'IsMatrixObj'?
##    On the one hand, there are only few operations involving row vectors
##    where this question is relevant.
##    On the other hand, the description of these operations becomes easier
##    if this implication holds (see 'RowsOfMatrix').
##
##  - Should more list like operations be documented for vector objects?
##    For example 'Position' and 'PositionProperty' would be candidates;
##    a comment in an earlier version of the interface states that they
##    are left out to simplify the interface.
##
##  - For the various constructors, perhaps imitate what we do
##    for e.g. group constructors:
##    Admit to omit the filter,
##    and try to choose a "good" default representation?
##
##  - Replace 'ChangedBaseDomain' (which is defined for both vector and
##    matrix objects) by 'VectorWithChangedBaseDomain',
##    'MatrixWithChangedBasedDomain'?
##
##  - The function 'MakeVector' is left undocumented for the moment.
##    Note that 'Vector' also supports variants for the 'MakeVector'
##    situation, and the strategies of the two are not compatible,
##    which may lead to confusion:
##    'MakeVector' knows a set of possible 'ConstructingFilter' values,
##    whereas 'Vector' asks 'DefaultScalarDomainOfMatrixList' and
##    'DefaultVectorRepForBaseDomain'.
##    Does this make sense?
##
##  - Is the ordering of arguments sensible and consistent?
##    (For example,
##    better define 'CopySubMatrix( dst, drows, dcols,  src, srows, scols )',
##    and unify the argument order in 'NewMatrix( filt, R, ncols, list )'
##    and 'Matrix( filt, R, list, ncols )'?
##    And what about 'NullMat'/'ZeroMatrix' and
##    'IdentityMat'/'IdentityMatrix'?)
##
##  - Are the operations for vector and matrix objects consistent?
##    For example, there are variants 'ZeroMatrix( [filt, ]R, m, n )'
##    but no variants 'ZeroVector( [filt, ]R, l )'.
##
##  - How is 'WeightOfVector' related to 'WeightVecFFE', 'DistanceVecFFE'?
##    Should just 'WeightOfVector' be documented?
##
##  - Would it be sensible to have a recursive version of 'ShallowCopy',
##    with an optional argument that limits the depth?
##    (Note that 'StructuralCopy' is not an operation.)
##    'MutableCopyMatrix' (which is defined and used in 'lib/matrix.g*'
##    but is not documented) could then be replaced by a depth 2 call
##    of that operation.
##    On the other hand, the name 'MutableCopyMatrix' is quite suggestive,
##    perhaps 'MutableCopyVector' would be a better name for 'ShallowCopy'.
##
##  - We state explicitly that we do not specify the behaviour if the
##    base domains or dimensions or representation types do not fit.
##    This is because of efficiency reasons.
##    On the other hand, we could suggest to signal an error (with a useful
##    error message if possible) except in the following cases:
##    - Properties such as 'IsOne' can return 'false' if a problem occurs
##      (such as a non-square matrix).
##    - 'Inverse' for a not invertible matrix should return 'fail',
##      according to the general documentation of 'Inverse'.
##    (Note that 'fail' results make sense only if one can rely on them
##    --for *all* matrix object representations, and this is something which
##    we do not want to guarentee.)
##
##  - We have to define what shall happen if the result of an operation
##    is a vector or matrix object but cannot get the same base domain
##    the input(s).
##    I think this happens only for
##    - the division of a vector/matrix by a scalar,
##      where some entry of the result is not in the base domain, and
##    - the inversion of a matrix that is not invertible over the base domain.
##    (Are there other dangerous operations?)
##    In such situations, we can either signal an error
##    or create a vector/matrix object over a different base domain,
##    for example by delegating to 'Vector( <list> )' or 'Matrix( <list> )',
##    respectively.
##    Once we decide what we want, this must be documented,
##    and the available methods have to be adjusted.
##

