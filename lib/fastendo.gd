#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Contains the declarations for the transformation representation
##  of endomorphisms. Computing with EndoGeneralMappings as transformations
##  makes the arithmetic much faster.
##


############################################################################
##
#A  TransformationRepresentation(<obj>)
##
##  This is the transformation representation of the endo general mapping
##  <obj>. Note, it is still a general mapping, not a transformation,
##  however, composition, equality and \< are all *much* faster.
##
##  Finding the TransformationRepresentation requires a call to
##  EnumeratorSorted for the Source of the mapping (the set on which
##  it acts). This could be very expensive.
##
DeclareAttribute("TransformationRepresentation", IsEndoMapping);
