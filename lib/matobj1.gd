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


# There are one main category for matrices and two disjoint sub-categories:

DeclareCategory( "IsMatrixObj", IsVector and IsScalar and IsCopyable );
# All the arithmetical filters come from IsVector and IsScalar.
# In particular, matrices are in "IsMultiplicativeElement" which defines
# powering with a positive integer by the (kernel) method for POW_OBJ_INT.
# Note that this is at least strange for non-associative base domains.
# Matrices are no longer necessarily lists, since they do not promise all list
# operations! Of course, in specific implementations the objects may
# still be lists.
# The family of an object in IsMatrixObj is the collections family of
# the family of its base domain.

InstallTrueMethod(IsAssociativeElement,
	 IsMatrixObj and IsAssociativeElementCollColl);

DeclareCategory( "IsRowListMatrix", IsMatrixObj );
# The category of matrices behaving like lists of rows which are GAP objects.
# Different matrices in this category can share rows and the same row can
# occur more than once in a matrix. Row access just gives a reference
# to the row object.

DeclareCategory( "IsFlatMatrix", IsMatrixObj );
# The category of "flatly" stored matrices. They behave as if all their rows
# were in one single chunk of memory, such that rows are not individual
# GAP objects. Writing row access and slicing always copies.
# Note that read-accessing the i-th row of a flat matrix twice can
# yield two non-identical objects!
