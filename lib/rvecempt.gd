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
##  This file contains the implementation of immutable empty row vectors.
##  An empty row vector is an immutable empty list whose family is
##  a collections family.
##  Empty row vectors are different if their families are different,
##  especially the ordinary empty list `[]' is different from every empty
##  row vector.
##
##  The first case where empty row vectors turned out to be necessary was
##  in the representation of elements of a zero dimensional s.c. algebra.
##


#############################################################################
##
#A  EmptyRowVector( <F> )
##
##  is an empty row vector whose family is the collections family of <F>.
##
DeclareAttribute( "EmptyRowVector", IsFamily );
