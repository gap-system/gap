############################################################################
# 
# matobj2.gd
#                                                        by Max Neunhöffer
#
##  Copyright (C) 2007  Max Neunhöffer, Lehrstuhl D f. Math., RWTH Aachen
##  This file is free software, see license information at the end.
#
# This file together with matobj1.gd formally define the interface to the 
# new style vectors and matrices in GAP.
# In this file all the operations, attributes and constructors are
# defined. It is read later in the GAP library reading process.
#
############################################################################

# TODO: make sure to document what exactly a new matrix obj implementation has to
# provide, and that we provide default implementations for everything else.


############################################################################
#
# Overview:
#
# <#GAPDoc Label="MatObj_Overview">
# The whole idea of this interface is that vectors and matrices must
# be proper objects with a stored type (i.e. created by Objectify allowing
# inheritance) to benefit from method selection. We therefore refer
# to the new style vectors and matrices as <Q>vector objects</Q> and
# <Q>matrix objects</Q> respectively. 
# <P/>It should be possible to write
# (efficient) code that is independent of the actual representation (in
# the sense of &GAP;'s representation filters) and preserves it.
# <P/>
# This latter requirement makes it necessary to distinguish between
# (at least) two classes of matrices:
# <List>
# <Item><Q>RowList</Q>-Matrices which behave basically like lists of rows,
#       in particular are the rows individual &GAP; objects that can
#       be shared between different matrix objects.</Item>
# <Item><Q>Flat</Q> matrices which behave basically like one &GAP; object
#       that cannot be split up further. In particular a row is only
#       a part of a matrix and no GAP object in itself.</Item>
# </List>
# For various reasons these two classes have to be distinguished
# already with respect to the definition of the operations for them.
# <P/>
# In particular vectors and matrices know their BaseDomain and their
# dimensions. Note that the basic condition is that the elements of
# vectors and matrices must either lie in the BaseDomain or naturally
# embed in the sense that + and * and = automatically work with all elements
# of the base domain (example: integers in polynomials over integers).
# <P/>
# Vectors are equal with respect to "=" if they have the same length
# and the same entries. It is not necessary that they have the same
# BaseDomain. Matrices are equal with respect to "=" if they have the
# same dimensions and the same entries. It is possible that not for all
# pairs of representations methods exist.
# <P/>
# It is not guaranteed that all rows of a matrix have the same vector type!
# It is for example thinkable that a matrix stores some of its rows in a
# sparse representation and some in a dense one!
# However, it is guaranteed that the rows of matrices in the same 
# representation are compatible in the sense that all vector operations
# defined in this interface can be applied to them and that new matrices
# in the same representation as the original matrix can be formed out of
# them.
# <P/>
# Note that there is neither a default mapping from the set of matrix 
# representations to the set of vector representations nor one in the 
# reverse direction! There is nothing like an "associated" vector
# representation to a matrix representation or vice versa.
# <P/>
# The way to write code that preserves the representation basically
# works by using constructing operations that take template objects
# to decide about the actual representation of the new object.
# <P/>
# Vectors do not have to be lists in the sense that they do not have
# to support all list operations. The same holds for matrices. However,
# RowList matrices behave nearly like lists of row vectors that insist
# on being dense and containing only vectors of the same length and
# with the same BaseDomain.
# <P/>
# There are some rules embedded in the comments to the following code.
# They are marked with the word "Rule". FIXME: Collect all rules here.
# <P/>
# <#/GAPDoc>
#
############################################################################


############################################################################
# If some operation has no comment it behaves as expected from
# the old vectors/matrices or as defined elsewhere.
############################################################################



############################################################################
############################################################################
# Attributes for vectors:
############################################################################
############################################################################


############################################################################
# Rule:
# A base domain must be a GAP object that has at least the following
# methods implemented:
#  Zero
#  One
#  \in
#  Characteristic
#  IsFinite
#     if finite:  Size, and possibly DegreeOverPrimeField for fields
# Elements of the base domain must implement +, -, * and /.
# "Automatically" embedded elements may occur in vectors and matrices.
# Example: An integer may occur in a matrix with BaseDomain a polynomial
#          ring over the Rationals.
############################################################################


# The following are guaranteed to be always set or cheaply calculable:
DeclareAttribute( "BaseDomain", IsVectorObj );
# Typically, the base domain will be a ring, it need not be commutative
# nor associative. For non-associative base domains, the behavior of
# powering matrices is undefined.

DeclareAttribute( "Length", IsVectorObj );    # can be zero
# We have to declare this since a row vector is not necessarily
# a list! Correspondingly we have to use InstallOtherMethod
# for those row vector types that are lists.

############################################################################
# Rule:
# Vectors v are always dense in the sense that all entries in the
# range [1..Length(v)] have defined values from BaseDomain(v).
############################################################################


############################################################################
############################################################################
# Operations for vectors:
############################################################################
############################################################################


############################################################################
# Rule:
# Vectors may be mutable or immutable. Of course all operations changing
# a vector are only allowed/implemented for mutable vectors.
############################################################################


############################################################################
# In the following sense vectors behave like lists:
############################################################################

DeclareOperation( "[]", [IsVectorObj,IsPosInt] );
# This is only defined for positions in [1..Length(VECTOR)]. 

DeclareOperation( "[]:=", [IsVectorObj,IsPosInt,IsObject] );
# This is only guaranteed to work for the position in [1..Length(VECTOR)] 
# and only for elements in the BaseDomain(VECTOR)! 
# Behaviour otherwise is undefined (from "unpacking" to Error all is possible)

DeclareOperation( "{}", [IsVectorObj,IsList] );
# Of course the positions must all lie in [1..Length(VECTOR)].
# Returns a vector in the same representation!

##  <#GAPDoc Label="MatObj_PositionNonZero">
##  <ManSection>
##    <Oper Arg="V" Name="PositionNonZero" Label="for vectors"/>
##    <Returns>An integer</Returns>
##    <Description>
##     Returns the index of the first entry in the vector <A>V</A> which is not
##     zero. If all entries are zero, the function
##     returns <C>Length(<A>V</A>) + 1</C>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "PositionNonZero", [IsVectorObj] );

##  <#GAPDoc Label="MatObj_PositionLastNonZero">
##  <ManSection>
##    <Oper Arg="V" Name="PositionLastNonZero"/>
##    <Returns>An integer</Returns>
##    <Description>
##     Returns the index of the last entry in the vector <A>V</A> which is not
##     zero. If all entries are zero, the function
##     returns 0.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "PositionLastNonZero", [IsVectorObj] );

##  <#GAPDoc Label="MatObj_ListOp">
##  <ManSection>
##    <Oper Arg="V[, func]" Name="ListOp" 
##                          Label="for IsVectorObj, IsFunction"/>
##    <Returns>A plain list</Returns>
##    <Description>
##     Applies <A>func</A> to each entry of the vector <A>V</A> and returns
##     the results as a plain list. This allows for calling 
##     <Ref Func="List" Label="for a collection"/> on vectors.
##     If the argument <A>func</A> is not provided, applies 
##     <Ref Func="IdFunc"/> to all entries.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "ListOp", [IsVectorObj] );
DeclareOperation( "ListOp", [IsVectorObj,IsFunction] );
# This is an unpacking operation returning a mutable copy in form of a list.
# It enables the "List" function to work.

##  <#GAPDoc Label="MatObj_UnpackVector">
##  <ManSection>
##    <Oper Arg="V" Name="Unpack" Label="for IsVectorObj"/>
##    <Returns>A plain list</Returns>
##    <Description>
##      Returns a new plain list containing the entries of <A>V</A>.
##      Guarantees to return a new list which can be manipulated without
##      changing <A>V</A>. The entries itself are not copied.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "Unpack", [IsVectorObj] ); 
# It guarantees to copy, that is changing the returned object does
# not change the original object.
# TODO: replace by AsList ?
# TODO: this is already used by the fining package


# "PositionNot" is intentionally left out here because it can rarely
# be implemented much more efficiently than by running through the vector.

# Note that vectors need not behave like lists with respect to the 
# following operations:
#  Add, Remove, IsBound[], Unbind[], \{\}\:\=, Append, Concatenation,
#  Position, First, Filtered, ...
# Note that \{\}\:\= is left out here since it tempts the programmer
# to use constructions like A{[1..3]} := B{[4,5,6]} which produces
# an intermediate object. Use CopySubVector instead!


# The list operations Position and so on seem to be unnecessary for
# vectors and matrices and thus are left out to simplify the interface.
# TODO: actually -- why not allow `Position` anyway? What's the harm?

# Note that since Concatenation is a function using Append, it will
# not work for vectors and it cannot be overloaded!
# Thus we need:

##  <#GAPDoc Label="MatObj_ConcatenationOfVectors">
##  <ManSection>
##    <Func Arg="V1,V2,..." Name="ConcatenationOfVectors" 
##                          Label="for IsVectorObj"/>
##    <Func Arg="Vlist" Name="ConcatenationOfVectors" 
##                      Label="for list of IsVectorObj"/>
##    <Returns>a vector object</Returns>
##    <Description>
##      Returns a new vector containing the entries of <A>V1</A>, 
##      <A>V2</A>, etc. As prototype <A>V1</A> is used.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "ConcatenationOfVectors" );

##  <#GAPDoc Label="MatObj_ExtractSubVector">
##  <ManSection>
##    <Func Arg="V,l" Name="ExtractSubVector" Label="for IsVectorObj,IsList"/>
##    <Returns>a vector object</Returns>
##    <Description>
##      Returns a new vector containing the entries of <A>V</A>
##      at the positions in <A>l</A>.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "ExtractSubVector", [IsVectorObj,IsList] );
# Does the same as slicing v{l} but is here to be similar to
# ExtractSubMatrix.

############################################################################
# Standard operations for all objects:
############################################################################

# The following are implicitly there for all objects, we mention them here
# to have a complete interface description in one place. Of course, vectors
# have to implement those:

# DeclareOperation( "ShallowCopy", [IsVectorObj] );

# DeclareGlobalFunction( "StructuralCopy", [IsVectorObj] );

# DeclareOperation( "ViewObj", [IsVectorObj] );

# DeclareOperation( "PrintObj", [IsVectorObj] );
# This must produce GAP readable input reproducing the representation!

# DeclareAttribute( "String", IsVectorObj );
# DeclareOperation( "String", [IsVectorObj,IsInt] );

# DeclareOperation( "Display", [IsVectorObj] );

# DeclareOperation( "MakeImmutable", [IsVectorObj] );
#  (this is a global function in the GAP library)


############################################################################
# Arithmetical operations for vectors:
############################################################################

# The following binary arithmetical operations are possible for vectors
# over the same BaseDomain with equal length:
#    +, -, <, =
# Note1: It is not guaranteed that sorting is done lexicographically!
# Note2: If sorting is not done lexicographically then the objects
#        in that representation cannot be lists!

# TODO: rename AddRowVector to AddVector; but keep in mind that
# historically there already was AddRowVector, so be careful to not break that

# The following "in place" operations exist with the same restrictions:
DeclareOperation( "AddRowVector", 
  [ IsVectorObj and IsMutable, IsVectorObj ] );

# vec = vec2 * scal
DeclareOperation( "AddRowVector", 
  [ IsVectorObj and IsMutable,  IsVectorObj, IsObject ] );
# vec = scal * vec2
DeclareOperation( "AddRowVector", 
  [ IsVectorObj and IsMutable, IsObject, IsVectorObj ] );

# vec := vec2{[to..from]} * scal
DeclareOperation( "AddRowVector", 
  [ IsVectorObj and IsMutable, IsVectorObj, IsObject, IsPosInt, IsPosInt ] );

# vec := scal * vec2{[to..from]}
DeclareOperation( "AddRowVector", 
  [ IsVectorObj and IsMutable, IsObject, IsVectorObj, IsPosInt, IsPosInt ] );



# TODO: rename MultRowVector to MultVector; but keep in mind that
# historically there already was MultRowVector, so be careful to not break that
DeclareOperation( "MultRowVector",
  [ IsVectorObj and IsMutable, IsObject ] );

#
# Also, make it explicit from which side we multiply
# DeclareOperation( "MultRowVectorFromLeft",
#   [ IsVectorObj and IsMutable, IsObject ] );
# DeclareOperation( "MultRowVectorFromRight",
#   [ IsVectorObj and IsMutable, IsObject ] );
#DeclareSynonym( "MultRowVector", MultRowVectorFromRight );

# do we really need the following? for what? is any code using this right now?
# ( a, pa, b, pb, s ) ->  a{pa} := b{pb} * s;
DeclareOperation( "MultRowVector",
  [ IsVectorObj and IsMutable, IsList, IsVectorObj, IsList, IsObject ] );

# maybe have this:   vec := vec{[from..to]} * scal ?? cvec has it


# The following operations for scalars and vectors are possible for scalars in the BaseDomain
# (and often also for more, e.g. usually the scalar is allowed to be an integer regardless of the
# base domain):
#    *, / (for <vector>/<scalar>, we do not define <scalar>/<vector>)

# The following unary arithmetical operations are possible for vectors, assuming
# they are possible in the base domain (so all of them in fields, but e.g. in
# a proper semiring, there is in general no additive inverse):
#    AdditiveInverseImmutable, AdditiveInverseMutable, 
#    AdditiveInverseSameMutability, ZeroImmutable, ZeroMutable, 
#    ZeroSameMutability, IsZero, Characteristic


# ScalarProduct is already overloaded a lot, so perhaps we don't need to define
# it here, and just expect people to write vec1*vec2.
#
# TODO: document very explicitly that * for vectors does not care whether
# either vector is a row or column vector; it just always is the scalar product.
#
##DeclareOperation( "ScalarProduct", [ IsVectorObj, IsVectorObj ] );
# This is defined for two vectors of equal length, it returns the standard
# scalar product.

############################################################################
# The "representation-preserving" contructor methods:
############################################################################

##  <#GAPDoc Label="MatObj_ZeroVector">
##  <ManSection>
##    <Oper Arg="l,V" Name="ZeroVector" Label="for IsInt,IsVectorObj"/>
##    <Returns>a vector object</Returns>
##    <Description>
##      Returns a new vector of length <A>l</A> in the same representation 
##      as <A>V</A> containing only zeros.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "ZeroVector", [IsInt,IsVectorObj] );
# Returns a new mutable zero vector in the same rep as the given one with
# a possible different length.

DeclareOperation( "ZeroVector", [IsInt,IsMatrixObj] );
# Returns a new mutable zero vector in a rep that is compatible with
# the matrix but of possibly different length.

# Operation to create vector objects.
# The first just delegate to NewVector:
DeclareOperation( "Vector", [IsOperation, IsSemiring,  IsList]);
DeclareOperation( "Vector", [IsOperation, IsSemiring,  IsVectorObj]);

# Here we implement default choices for the representation, depending
# in base domain:
DeclareOperation( "Vector", [IsSemiring,  IsList]);
DeclareOperation( "Vector", [IsSemiring,  IsVectorObj]);

# And here are the variants with example object (as last argument):
DeclareOperation( "Vector", [IsList, IsVectorObj]);
DeclareOperation( "Vector", [IsVectorObj, IsVectorObj]);

# And here guess everything:
DeclareOperation( "Vector", [IsList]);


# Creates a new vector in the same representation but with entries from list.
# The length is given by the length of the first argument.
# It is *not* guaranteed that the list is copied!

# the following is gone again, use CompatibleVector instead:
#DeclareOperation( "Vector", [IsList,IsMatrixObj] );
## Returns a new mutable vector in a rep that is compatible with
## the matrix but of possibly different length given by the first
## argument. It is *not* guaranteed that the list is copied!

##  <#GAPDoc Label="MatObj_ConstructingFilter_Vector">
##  <ManSection>
##    <Oper Arg="V" Name="ConstructingFilter" Label="for IsVectorObj"/>
##    <Returns>a filter</Returns>
##    <Description>
##      Returns a filter <C>f</C> such that if <Ref Oper="NewVector"/> is
##      called with <C>f</C> a vector in the same representation as <A>V</A>
##      is produced.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "ConstructingFilter", [IsVectorObj] );

DeclareConstructor( "NewVector", [IsVectorObj,IsSemiring,IsList] );
# A constructor. The first argument must be a filter indicating the
# representation the vector will be in, the second is the base domain.
# The last argument is guaranteed not to be changed!

DeclareSynonym( "NewRowVector", NewVector );
# FIXME: Declare NewRowVector for backwards compatibility, so that existing
# code which already used it keeps working (most notably, the cvec and fining
# packages). We should eventually remove this synonym.


DeclareConstructor( "NewZeroVector", [IsVectorObj,IsSemiring,IsInt] );
# A similar constructor to construct a zero vector, the last argument
# is the base domain.

DeclareOperation( "ChangedBaseDomain", [IsVectorObj,IsSemiring] );
# Changes the base domain. A copy of the row vector in the first argument is
# created, which comes in a "similar" representation but over the new
# base domain that is given in the second argument.
# example: given a vector over GF(2),  create a new vector over GF(4) with "identical" content
#  so it's kind of a type conversion / coercion
# TODO: better name, e.g. VectorWithChangedBasedDomain
#  or maybe just turn this into a constructor resp. a new constructor special case :
# like
#  DeclareConstructor( "NewVector", [IsVectorObj,IsSemiring,IsVectorObj] );


DeclareGlobalFunction( "MakeVector" );
# A convenience function for users to choose some appropriate representation
# and guess the base domain if not supplied as second argument.
# This is not guaranteed to be efficient and should never be used 
# in library or package code.
# usage: MakeVector( <list> [,<basedomain>] )
# TODO: explain that this is not something you should use a lot;
# instead you should use NewVector, ZeroVector, Vector, ...
# explain a typical use case / scenario for this function..
#  also: do we *really* need it? Max expects we'll find out as we convert the library


############################################################################
# Some things that fit nowhere else:
############################################################################

##  <#GAPDoc Label="MatObj_Randomize_Vectors">
##  <ManSection>
##    <Oper Arg="V" Name="Randomize" Label="for IsVectorObj"/>
##    <Oper Arg="V,Rs" Name="Randomize" Label="for IsVectorObj,IsRandomSources"/>
##    <Description>
##      Replaces every entry in <A>V</A> with a random one from the base
##      domain. If given, the random source <A>Rs</A> is used to compute the
##      random elements. Note that in this case, the random function for the
##      base domain must support the random source argument.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "Randomize", [IsVectorObj and IsMutable] );
DeclareOperation( "Randomize", [IsVectorObj and IsMutable,IsRandomSource] );
# Changes the mutable argument in place, every entry is replaced
# by a random element from BaseDomain.
# The second argument is used to provide "randomness".
# The vector argument is also returned by the function.

# TODO: change this to use InstallMethodWithRandomSource; for this, we'll have
# to change the argument order (a method for the old order, to ensure backwards
# compatibility, could remain).

#############################################################################
##
#O  CopySubVector( <src>, <dst>, <scols>, <dcols> )
##
##  <#GAPDoc Label="CopySubVector">
##  <ManSection>
##  <Oper Name="CopySubVector" Arg='dst, dcols, src, scols'/>
##  <Description>
##  <Returns>nothing</Returns>
##  Does <C><A>dst</A>{<A>dcols</A>} := <A>src</A>{<A>scols</A>}</C>
##  without creating an intermediate object and thus - at least in
##  special cases - much more efficiently. For certain objects like
##  compressed vectors this might be significantly more efficient if 
##  <A>scols</A> and <A>dcols</A> are ranges with increment 1.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
## TODO: link to ExtractSubVector
## 
## TODO: In AddRowVector and MultRowVector, the destination is always the first argument;
##   it would be better if we were consistent...
##
## TODO: Maybe also have a version of this as follows:
##    CopySubVector( dst, dst_from, dst_to,  src, src_form, src_to );
DeclareOperation( "CopySubVector", 
  [IsVectorObj and IsMutable, IsList, IsVectorObj, IsList] );
## TODO: the following declaration is deprecated and only kept for compatibility
DeclareOperation( "CopySubVector", 
  [IsVectorObj,IsVectorObj and IsMutable, IsList,IsList] );

##  <#GAPDoc Label="MatObj_WeightOfVector">
##  <ManSection>
##    <Oper Arg="V" Name="WeightOfVector" Label="for IsVectorObj"/>
##    <Returns>an integer</Returns>
##    <Description>
##      Computes the Hamming weight of the vector <A>V</A>, i.e., the number of 
##      nonzero entries.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "WeightOfVector", [IsVectorObj] );


##  <#GAPDoc Label="MatObj_DistanceOfVectors">
##  <ManSection>
##    <Oper Arg="V1,V2" Name="DistanceOfVectors" 
##                      Label="for IsVectorObj,IsVectorObj"/>
##    <Returns>an integer</Returns>
##    <Description>
##      Computes the Hamming distance of the vectors <A>V1</A> and <A>V2</A>,
##      i.e., the number of entries in which the vectors differ. The vectors
##      must be of equal length.
##    </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareOperation( "DistanceOfVectors", [IsVectorObj, IsVectorObj] );



############################################################################
############################################################################
# Operations for all matrices in IsMatrixObj:
############################################################################
############################################################################


############################################################################
# Attributes of matrices:
############################################################################

# The following are guaranteed to be always set or cheaply calculable:
DeclareAttribute( "BaseDomain", IsMatrixObj );
# Typically, the base domain will be a ring, it need not be commutative
# nor associative. For non-associative base domains, the behavior of
# powering matrices is undefined.

DeclareAttribute( "NumberRows", IsMatrixObj );
DeclareAttribute( "NumberColumns", IsMatrixObj );
DeclareSynonym( "NrRows", NumberRows );
DeclareSynonym( "NrCols", NumberColumns );

# DO NOT declare Length ?!? (or maybe for backwards compatibilty??)
DeclareAttribute( "Length", IsMatrixObj ); # ????
# We have to declare this since matrix objects need not be lists.
# We have to use InstallOtherMethod for those matrix types that are
# lists.

# HACK: this was in the old version of MatrixObj; we want to get rid of it;
# but for now, keep it in to allow us to start GAP
DeclareSynonym( "RowLength", NumberColumns );


# WARNING: the following attributes should not be stored if the matrix is mutable...
DeclareAttribute( "DimensionsMat", IsMatrixObj );
# returns [NrRows(mat),NrCols(mat)]
# for backwards compatibility with existing cod

DeclareAttribute( "RankMat", IsMatrixObj );
DeclareOperation( "RankMatDestructive", [ IsMatrixObj ] );
# TODO: danger: RankMat should not be stored for mutable matrices... 
# 


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


# FIXME: Actually, we should probably not defined these for matrices, only for vectors
# These should probably only be defined for RowListMatrices???
#DeclareOperation( "PositionNonZero", [IsMatrixObj] );
#DeclareOperation( "PositionNonZero", [IsMatrixObj, IsInt] );
#
#DeclareOperation( "PositionLastNonZero", [IsMatrixObj] );
#DeclareOperation( "PositionLastNonZero", [IsMatrixObj, IsInt] );
#
#DeclareOperation( "Position", [IsMatrixObj, IsVectorObj] );
#DeclareOperation( "Position", [IsMatrixObj, IsVectorObj, IsInt] );
#
## This allows for usage of PositionSorted:
#DeclareOperation( "PositionSortedOp", [IsMatrixObj, IsVectorObj] );
#DeclareOperation( "PositionSortedOp", [IsMatrixObj, IsVectorObj,IsFunction]);

# I intentionally left out "PositionNot" here.

# Note that "PositionSet" is a function only for lists. End of story.

# Note that arbitrary matrices need not behave like lists with respect to the 
# following operations:
#  Add, Remove, IsBound, Unbind, \{\}\:\=, Append, Concatenation,
# However, see below for matrices in the subcategory IsRowListMatrix.


############################################################################
# Explicit copying operations:
############################################################################

# The following are already in the library, these declarations should be
# adjusted:
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
##  lists, which mean subset of rows and subset of columns respectively.
##  This does <A>mat</A>{<A>rows</A>}{<A>cols</A>} and returns the result.
##  It preserves the representation of the matrix.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ExtractSubMatrix", [IsMatrixObj,IsList,IsList] );

# TODO: perhaps also add ExtractSubMatrix( mat, row_from, row_to, col_from, col_to ) ???
# probably not needed... one can use ranges + TryNextMethod ...
# but let's look at some places where this function is used

# Creates a fully mutable copy of the matrix.
DeclareOperation( "MutableCopyMat", [IsMatrixObj] );
# so this amounts roughly to  `mat -> List( mat, ShallowCopy )`
# except that it produce an object in the same representation


# TODO: perhaps also add a recursive version of ShallowCopy with a parameter limiting the depth..

# TODO: can we also have a version of ShallowCopy which has a name starting with "Mutable"
# to make it easier to discover??? Like MutableCopyVec (which might just be an alias
# for ShallowCopy).
# Or at least mention ShallowCopy in the MutableCopyMat 



#############################################################################
##
#O  CopySubMatrix( <src>, <dst>, <srows>, <drows>, <scols>, <dcols> )
##
##  <#GAPDoc Label="CopySubMatrix">
##  <ManSection>
##  <Oper Name="CopySubMatrix" Arg='src, dst, srows, drows, scols, dcols'/>
##
##  <Description>
##  <Returns>nothing</Returns>
##  Does <C><A>dst</A>{<A>drows</A>}{<A>dcols</A>} := 
##  <A>src</A>{<A>srows</A>}{<A>scols</A>}</C>
##  without creating an intermediate object and thus - at least in
##  special cases - much more efficiently. For certain objects like
##  compressed vectors this might be significantly more efficient if 
##  <A>scols</A> and <A>dcols</A> are ranges with increment 1.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CopySubMatrix", [IsMatrixObj,IsMatrixObj,
                                    IsList,IsList,IsList,IsList] );

# TODO: order of arguments? dst before src??? perhaps:
#    dst, drows, dcols,  src, srows, scols

############################################################################
# New element access for matrices
############################################################################

DeclareOperation( "MatElm", [IsMatrixObj,IsPosInt,IsPosInt] );
# second and third arguments are row and column index

DeclareOperation( "SetMatElm", [IsMatrixObj,IsPosInt,IsPosInt,IsObject] );
# second and third arguments are row and column index


############################################################################
# Standard operations for all objects:
############################################################################

# The following are implicitly there for all objects, we mention them here
# to have a complete interface description in one place:

# ShallowCopy is missing here since its behaviour depends on the internal
# representation of the matrix objects (e.g. list-of-lists resp. list-of-vectors
#  versus a "flat" matrix, or a shallow matrix, or ...)!

# TODO: for mutable matrices, a difference between StructuralCopy and MutableCopyMat
# occurs if the matrix is a row list, and one row is immutable, another mutable;
# then StructuralCopy will return a new list of vectors, which again contains the
# same (identical) immutable vectors, and mutable copies of the other vectors.
# Whereas with MutableCopyMat, all new rows will be mutable
# DeclareGlobalFunction( "StructuralCopy", [IsMatrixObj] );

# DeclareOperation( "ViewObj", [IsMatrixObj] );

# DeclareOperation( "PrintObj", [IsMatrixObj] );
# This must produce GAP-readable input reproducing the representation.

# DeclareAttribute( "String", IsMatrixObj );
# DeclareOperation( "String", [IsMatrixObj,IsInt] );

# DeclareOperation( "Display", [IsMatrixObj] );

# DeclareOperation( "MakeImmutable", [IsMatrixObj] );
#  (this is a global function in the GAP library)
# Matrices have to implement "PostMakeImmutable" if necessary!


############################################################################
# Arithmetical operations:
############################################################################

# The following binary arithmetical operations are possible for matrices
# over the same BaseDomain with fitting dimensions:
#    +, *, -
# The following are also allowed for different dimensions:
#    <, =
# Note1: It is not guaranteed that sorting is done lexicographically!
# Note2: If sorting is not done lexicographically then the objects
#        in that representation cannot be lists!

# For non-empty square matrices we have:
#    ^ integer
# (this is only well-defined over associative base domains, 
#  do not use it over non-associative base domains.
# // The behavior of ^ on non-associative base domains is undefined.

# The following unary arithmetical operations are possible for matrices:
#    AdditiveInverseImmutable, AdditiveInverseMutable, 
#    AdditiveInverseSameMutability, ZeroImmutable, ZeroMutable, 
#    ZeroSameMutability, IsZero, Characteristic

# The following unary arithmetical operations are possible for non-empty
# square matrices (inversion returns fail if not invertible):
#    OneMutable, OneImmutable, OneSameMutability,
#    InverseMutable, InverseImmutable, InverseSameMutability, IsOne,

# Problem: How about inverses of integer matrices that exist as
# elements of rationals matrix?
# TODO: how to deal with this? If you have e.g. the integer matrix [[2]],
#  then our generic inversion code produces the inverse [[1/2]] -- but that
# is not defined over the base domain (the integers).
#
# So perhaps the default method for inversion has to be careful...
# there is no problem over fields.
# For non-commutative or non-assoc domains, we don't provid a default.
# For commutative rings, we could compute the determinant alongside 
# the inverse ("almost" for free), and then only need to check that
# the determinant is a unit in the base domain
# But be careful regarding zero divisors -- so perhaps use a different
#  default method for non-fields, which avoids division
# 
# Also, we can have other methods for e.g. subdomains of the cyclotomics.
#


DeclareOperation( "TraceMat", [IsMatrixObj] );
# The sum of the diagonal entries. Error for a non-square matrix.


#DeclareOperation( "DeterminantMat", [IsMatrixObj] );
# TODO: this only makes sense over commutative domains;
# be careful regarding default implementation (base domain = field vs.
#  base domain = any commutative ring, possibly with zero divisors)


############################################################################
# Rule:
# Operations not sensibly defined return fail and do not trigger an error:
# In particular this holds for:
# One for non-square matrices.
# Inverse for non-square matrices
# Inverse for square, non-invertible matrices.

# FIXME: what is the rationale for the above? OK, inverting a square matrix:
#   it is non-trivial to decide if the matrix is invertible, so it might be
#   useful to be able to just try and invert it, and do something else if that "fail"s
#   But it is cheap to verify that a matrix is non-square, so why not error for that?
#   Same for One, ...

#
# An exception are properties:
# IsOne for non-square matrices returns false.
#
# To detect errors more easily:
# Matrix/vector and matrix/matrix product run into errors if not defined
# mathematically (like for example a 1x2 - matrix times itself.
############################################################################

############################################################################
# The "representation-preserving" contructor methods:
############################################################################

DeclareOperation( "ZeroMatrix", [IsInt,IsInt,IsMatrixObj] );
DeclareOperation( "ZeroMatrix", [IsSemiring, IsInt,IsInt] );  # warning: NullMat has ring arg last
DeclareOperation( "ZeroMatrix", [IsOperation, IsSemiring, IsInt,IsInt] );
# Returns a new fully mutable zero matrix in the same rep as the given one with
# possibly different dimensions. First argument is number of rows, second
# is number of columns.

DeclareConstructor( "NewZeroMatrix", [IsMatrixObj,IsSemiring,IsInt,IsInt]);
# constructor -> first argument must be a filter, like e.g. IsPlistMatrixRep
#
# Returns a new fully mutable zero matrix over the base domain in the
# 2nd argument. The integers are the number of rows and columns.

DeclareOperation( "IdentityMatrix", [IsInt,IsMatrixObj] );
DeclareOperation( "IdentityMatrix", [IsSemiring, IsInt] );  # warning: IdentityMat has ring arg last
DeclareOperation( "IdentityMatrix", [IsOperation, IsSemiring, IsInt] );
# Returns a new mutable identity matrix in the same rep as the given one with
# possibly different dimensions.

DeclareConstructor( "NewIdentityMatrix", [IsMatrixObj,IsSemiring,IsInt]);
# Returns a new fully mutable identity matrix over the base domain in the
# 2nd argument. The integer is the number of rows and columns.

# TODO: perhaps imitate what we do for e.g. group constructors, and allow
# user to omit the filter; in that case, try to choose a "good" default
# representation ????

# TODO: perhaps add DiagonalMatrix?

# TODO: convert (New)IdentityMatrix and (New)ZeroMatrix to be more similar to Matrix()


DeclareOperation( "CompanionMatrix", [IsUnivariatePolynomial,IsMatrixObj] );
# Returns the companion matrix of the first argument in the representation
# of the second argument. Uses row-convention. The polynomial must be
# monic and its coefficients must lie in the BaseDomain of the matrix.

DeclareConstructor( "NewCompanionMatrix", 
  [IsMatrixObj, IsUnivariatePolynomial, IsSemiring] );
# The constructor variant of <Ref Oper="CompanionMatrix"/>.
# TODO: get rid of NewCompanionMatrix, at least for now -- if somebody *REALLY*
# needs it, we can still reconsider... Instead allow this:
# DeclareOperation( "CompanionMatrix", [IsFilter, IsUnivariatePolynomial, IsSemiring] );
# which roughly does this:
#   InstallMethod( CompanionMatrix, ...
#     function(filt, f, R)
#       n := Degree(f);
#       mat := NewZeroMatrix(filt, R, n, n);
#       ... set entries of mat ...
#     end);



# The following are already declared in the library:
# Eventually here will be the right place to do this.

# variant with new filter + base domain (dispatches to NewMatrix)
DeclareOperation( "Matrix", [IsOperation, IsSemiring,  IsList, IsInt]);
DeclareOperation( "Matrix", [IsOperation, IsSemiring,  IsList]);
DeclareOperation( "Matrix", [IsOperation, IsSemiring,  IsMatrixObj]);

# variant with new base domain -> "guesses" good rep, then dispatches to NewMatrix
DeclareOperation( "Matrix", [IsSemiring,    IsList, IsInt]);
DeclareOperation( "Matrix", [IsSemiring,    IsList]);
DeclareOperation( "Matrix", [IsSemiring,    IsMatrixObj]);

# the following two operations use DefaultFieldOfMatrix to "guess" the base domain
DeclareOperation( "Matrix", [IsList, IsInt]);
DeclareAttribute( "Matrix", IsList, "mutable"); # HACK: because there already is an attribute Matrix

# variant with example object at end (input is first)
DeclareOperation( "Matrix", [IsList, IsInt, IsMatrixObj]);
DeclareOperation( "Matrix", [IsList,        IsMatrixObj]);  # <- no need to overload this one
DeclareOperation( "Matrix", [IsMatrixObj,   IsMatrixObj]);

# perhaps also (or instead?) have this:
#DeclareOperation( "MatrixWithRows", [IsList (of vectors),IsMatrixObj]); ??
#DeclareOperation( "MatrixWithColumns", [IsList (of vectors),IsMatrixObj]); ??



DeclareConstructor( "NewMatrix", [IsMatrixObj, IsSemiring, IsInt, IsList] );
# Constructs a new fully mutable matrix. The first argument has to be a filter
# indicating the representation, the second the base domain, the third
# the row length. The last argument can be:
#  - a plain list of vector objects of correct length
#  - a plain list of plain lists of correct length
#  - a flat plain list with rows*cols entries in row major order
#    (FoldList turns a flat list into a list of lists)
# where the corresponding entries must be in or compatible with the base domain.
# If the last argument already contains vector objects, they are copied.
# The last argument is guaranteed not to be changed!

# TODO: what does "flat" above mean???
# TODO: from an old comment on Matrix / NewMatrix, wrt to the last argument
# The outer list is guaranteed to be copied, however, the entries of that
# list (the rows) need not be copied.
# TODO: Isn't it inconsistent to copy the rows if they are vector objects, but otherwise not? Also: matobjplist.gi uses NewVector, which copies its list-argument

# FIXME: why is IsInt,IsList reversed compared to Matrix(), where it is IsList,IsInt




# given a matrix <m>, produce a filter such that  NewMatrix called with this filter
# will produce a matrix in the same representation as <m>
DeclareOperation( "ConstructingFilter", [IsMatrixObj] );

# TODO: what does this do?
# Implementation: given an n x m matrix <m>, create a new zero vector <v> of
# length n (= NrRows) in a representation "compatible" with that of <m>, i.e.
# there "should be" a fast action  <v>*<m>
# FIXME: is this really useful? Compare to, say, `ExtractRow(mat,1)` etc. ???
DeclareOperation( "CompatibleVector", [IsMatrixObj] );

DeclareOperation( "ChangedBaseDomain", [IsMatrixObj,IsSemiring] );
# Changes the base domain. A copy of the matrix in the first argument is
# created, which comes in a "similar" representation but over the new
# base domain that is given in the second argument.
# TODO: better name, e.g. MatrixWithChangedBasedDomain
#  or maybe just turn this into a constructor resp. a new constructor special case :
# like
#  DeclareConstructor( "NewMatrix", [IsMatrixObj,IsSemiring,IsMatrixObj] );




# usage: MakeVector( <list> [,<basedomain>] )
# A convenience function for users to choose some appropriate representation
# and guess the base domain if not supplied as second argument.
# This is not guaranteed to be efficient and should never be used
# in library or package code.
# It is mainly useful to help migrate existing code incrementally to use
# the new MatrixObj interface.


# TODO: how useful are all these constructors in practice? 
# Ideally we should try to limit their number, focusing on a few useful ones..
#  best to see what actual code needs


############################################################################
# Some things that fit nowhere else:
############################################################################

DeclareOperation( "Randomize", [IsMatrixObj and IsMutable] );
DeclareOperation( "Randomize", [IsMatrixObj and IsMutable,IsRandomSource] );
# Changes the mutable argument in place, every entry is replaced
# by a random element from BaseDomain.
# The second version will come when we have random sources.

# TODO: only keep the first operation and suggest using InstallMethodWithRandomSource


DeclareAttribute( "TransposedMatImmutable", IsMatrixObj );
DeclareOperation( "TransposedMatMutable", [IsMatrixObj] );
# TODO: one problem with DeclareAttribute: it only really makes sense if the
#  matrix is immutable; but we have no way of declaring this; so it is very
#  easy to end up having a mutable, attribute storing matrix, which stores
#  its transpose "by accident", and then gets modified later on
#


DeclareOperation( "IsDiagonalMat", [IsMatrixObj] );
DeclareOperation( "IsUpperTriangularMat", [IsMatrixObj] );
DeclareOperation( "IsLowerTriangularMat", [IsMatrixObj] );
# TODO: if we allow attributes, we might just as well do the above to be
# declared as properties, so that this information is stored; but once
# again, we would only want to allow this for immutable matrix objects.
# ...

# TODO: what about the following (and also note the names...):
#   - IsScalarMat, IsSquareMat, ... ?

# TODO: Why do we call them RankMat, IsDiagonalMat, etc.
#  and not RankMatrix, IsDiagonalMatrix, etc. ?
#  in contrast to Matrix(), NewMatrix(), ExtractSubMatrix(), ...
#
# One reasons is backwards compatibility of course, but this could
# also be achieved with synonyms.
# Another argument for "Mat" is brevity, but is that really so important/useful
#   versus "clarity"
# Still, we could unify these names, always using "Matrix".
#
# Of course we could also introduce a rule when to use "Matrix" and when to use "Mat",
# but this rule will invariably be ignored or forgotten and inconsistency will 
# occur.
#
# So new plan: Always use "Matrix", but provide "Mat" aliases for
# backwards compatibility (if the operation already exists with that name),
# and perhaps (????) for "convenience"
#

DeclareOperation( "KroneckerProduct", [IsMatrixObj,IsMatrixObj] );
# The result is fully mutable.

# FIXME: what is the purpose of Unfold and Fold?
# Maybe remove them, and wait if somebody asks for / needs this

DeclareOperation( "Unfold", [IsMatrixObj, IsVectorObj] );
# Concatenates all rows of a matrix to one single vector in the same
# representation as the given template vector. Usually this must
# be compatible with the representation of the matrix given.
DeclareOperation( "Fold", [IsVectorObj, IsPosInt, IsMatrixObj] );
# Cuts the row vector into pieces of length the second argument
# and forms a matrix out of the pieces in the same representation 
# as the third argument. The length of the vector must be a multiple
# of the second argument.

# The following unwraps a matrix to a list of lists:
DeclareOperation( "Unpack", [IsRowListMatrix] );
# It guarantees to copy, that is changing the returned object does
# not change the original object.
# TODO: this is already used by the fining package


############################################################################
############################################################################
# Operations for RowList-matrices:
############################################################################
############################################################################


############################################################################
# List operations with some restrictions:
############################################################################

# TODO: what is this good for? Theory: it would probably help when migrating
# existing code to MatrixObj, as you could change your lists-of-list matrices
# to MatrixObjs, and then incrementally adapt your code to *not* use the 
# following operations.
#
# In that case, we should make it very clear that using these functions is
# discouraged....

# TODO: let's see if this is really useful when e.g. adapting the library.
# If not, then we might not even need `IsRowListMatrix`

DeclareOperation( "[]:=", [IsRowListMatrix,IsPosInt,IsObject] );
# Only guaranteed to work for the position in [1..Length(VECTOR)] and only
# for elements in a suitable vector type.
# Behaviour otherwise is undefined (from "unpacking" to Error all is possible)

DeclareOperation( "{}", [IsRowListMatrix,IsList] );
# Produces *not* a list of rows but a matrix in the same rep as the input!

DeclareOperation( "Add", [IsRowListMatrix,IsVectorObj] );
DeclareOperation( "Add", [IsRowListMatrix,IsVectorObj,IsPosInt] );

DeclareOperation( "Remove", [IsRowListMatrix] );
DeclareOperation( "Remove", [IsRowListMatrix,IsPosInt] );

DeclareOperation( "IsBound[]", [IsRowListMatrix,IsPosInt] );
DeclareOperation( "Unbind[]", [IsRowListMatrix,IsPosInt] );  
# Only works for last row to preserve denseness.

DeclareOperation( "{}:=", [IsRowListMatrix,IsList,IsRowListMatrix] );
# This is only guaranteed to work if the result is dense and the matrices
# are compatible. For efficiency reasons the third argument must be a
# matrix and cannot be a list of vectors.

DeclareOperation( "Append", [IsRowListMatrix,IsRowListMatrix] ); 
# Again only for compatible matrices
# ==> Concatenation works then automatically!

# Implicitly there, creates a new matrix sharing the same rows:
# DeclareOperation( "ShallowCopy", [IsRowListMatrix] );

# The following unwraps a matrix to a list of vectors:
DeclareOperation( "ListOp", [IsRowListMatrix] );
DeclareOperation( "ListOp", [IsRowListMatrix, IsFunction] );


############################################################################
# Rule:
# This all means that objects in IsRowListMatrix behave like lists that
# insist on being dense and having only IsVectorObjs over the right
# BaseDomain and with the right length as entries. However, formally
# they do not have to lie in the filter IsList.
############################################################################



############################################################################
# Arithmetic involving vectors and matrices:
############################################################################

# DeclareOperation( "*", [IsVectorObj, IsMatrixObj] );
# DeclareOperation( "*", [IsMatrixObj, IsVectorObj] );

# TODO: the following does the same as "*", but is useful 
# as convenience for Orbit-ish operations.
# We otherwise discourage its use in "naked" code -- use * instead
# DeclareOperation( "^", [IsVectorObj, IsMatrixObj] );



############################################################################
# Further candidates for the interface:
############################################################################

# AsList
# AddCoeffs



# while we are at it also make the naming of following more uniform ???

#   TriangulizeIntegerMat
#   TriangulizedIntegerMat(Transform)
#   HermiteNormalFormIntegerMat(Transform)
#   SmithNormalFormIntegerMat(Transform)
# and contrast them to these:
#   BaseIntMat
#   BaseIntersectionIntMats
#   ComplementIntMat
#   DeterminantIntMat
#   DiagonalizeIntMat
#   NormalFormIntMat
#   NullspaceIntMat
#   SolutionIntMat
#   SolutionNullspaceIntMat

