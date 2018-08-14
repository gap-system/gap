############################################################################
# 
# matobj1.gd
#                                                        by Max Neunhöffer
#
##  Copyright (C) 2007  Max Neunhöffer, Lehrstuhl D f. Math., RWTH Aachen
##  This file is free software, see license information at the end.
#
# This file together with matobj2.gd formally define the interface to the
# new style vectors and matrices in GAP.
# In this file the categories are defined, it is read earlier in the
# GAP library reading process.
#
############################################################################


############################################################################
############################################################################
# Categories for vectors and matrices:
############################################################################
############################################################################


DeclareCategory( "IsVectorObj", IsVector and IsCopyable );
# All the arithmetical filters come from IsVector.
# Vectors are no longer necessarily lists, since they do not promise all
# list operations. Of course, in specific implementations the objects
# may still be lists. But beware: Some matrix representations might
# rely on the fact that vectors cannot change their length!
# The family of an object in IsVectorObj is the same as the family of
# the base domain.

DeclareSynonym( "IsRowVectorObj", IsVectorObj );
# FIXME: Declare IsRowVectorObj for backwards compatibility, so that existing
# code which already used it keeps working (most notably, the cvec package).
# We should eventually remove this synonym.


# There are one main category for matrices and one subcategory:

DeclareCategory( "IsMatrixObj", IsVector and IsScalar and IsCopyable );
# All the arithmetical filters come from IsVector and IsScalar.
# In particular, matrices are in "IsMultiplicativeElement" which defines
# powering with a positive integer by the (kernel) method for POW_OBJ_INT.
# Note that this is at least strange for non-associative base domains.
# The filter 'IsMatrixObj' for an object does *not* imply that the
# multiplication for this object is the usual matrix multiplication,
# one can specify this multiplication via the filter 'IsOrdinaryMatrix'.
# Also the associativity of the multiplication of matrices does not follow
# from 'IsMatrixObj' and the associativity of the base domain,
# one needs also 'IsOrdinaryMatrix' for this implication.
# Note that elements of matrix Lie algebras lie in 'IsMatrixObj' but not in
# 'IsOrdinaryMatrix'.
# Matrices are no longer necessarily lists, since they do not promise all list
# operations! Of course, in specific implementations the objects may
# still be lists.
# The family of an object in IsMatrixObj is the collections family of
# the family of its base domain.

InstallTrueMethod( IsMatrixObj, IsMatrix );
# We want that those matrices that are plain lists of plain lists
# are also in 'IsMatrixObj', in order to be able to install a method for
# all representations of matrices with the same requirements.
# (With the current distribution of declarations to files,
# we cannot put the implication into the declaration of 'IsMatrix':
# Both 'IsVector' and 'IsMatrix' are declared in 'lib/arith.gd',
# and 'IsMatrixObj' --which shall be in the middle-- is declared in
# 'lib/matobj1.gd'.)

DeclareCategory( "IsRowListMatrix", IsMatrixObj );
# The category of matrices behaving like lists of rows which are GAP objects.
# Different matrices in this category can share rows and the same row can
# occur more than once in a matrix. Row access just gives a reference
# to the row object.

