#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares the operations for sparse lists
##



#############################################################################
##
#O  SparseStructureOfList( <list> )
##
##  This operation returns a sparse structure of <list>
##  The return value is a length three list, of which the first
##  position may or may not be bound. If bound, it is the default
##  value, if not bound, the default is to be unbound. The default value
##  must by immutable
##
##  The second entry is a dense duplicate-free list of integers
##  between  1 and Length(<list>) inclusive, representing the
##  positions where non-default entries may appear.
##
##  The third entry is a list not longer than the second entry, giving
##  the values that appear in the positions given in the second
##  entry. Holes in this list represent holes in the original list.
##
##  The second and third entries may be mutable (to avoid copying in
##  time-critical code) but should not be changed.
##

DeclareOperation( "SparseStructureOfList", [IsList]);

#############################################################################
##
#F  IsSparseList( <l> )
##
##  A sparse list is a list for which the sparse structure and corresponding
##  sparse methods should be used.
##
##  The filter is ranked up so that sparse list methods will beat
##  competing methods for finite, homogeneous, etc. lists, which is
##  usually right
##

DeclareFilter( "IsSparseList", IsList, 20 );

#############################################################################
##
#F  SparseListBySortedList  ( <poss>, <vals>, <len>, <default> )
#F  SparseListBySortedListNC( <poss>, <vals>, <len>, <default> )
##
##  These two functions can be used to create homogeneous sparse
##  lists, in a representation where the positions are stored as a
##  sorted list and the values as a corresponding list. These lists
##  must be dense.
##
##  The NC version refrains from both checking and copying its arguments
##  The non-NC version makes a shallow copy of <poss> and <vals>
##

DeclareGlobalFunction( "SparseListBySortedList");
DeclareGlobalFunction( "SparseListBySortedListNC");

#############################################################################
##
#P IsSparseRowVector( <sl> )
##
##  A sparse list is a sparse row vector if it is dense and its default value
##  is a common Zero of all its non-default values
##

DeclareProperty( "IsSparseRowVector", IsSparseList);
InstallTrueMethod( IsRowVector, IsSparseRowVector );
InstallTrueMethod( IsHomogeneousList, IsSparseRowVector );
InstallTrueMethod( IsCollection, IsSparseRowVector );

#############################################################################
##
#F  SparseVectorBySortedList  ( <poss>, <vals>, <len>[, <zero>] )
#F  SparseVectorBySortedListNC( <poss>, <vals>, <len>[, <zero>])
##
##  These two functions can be used to create sparse row vectors using
##  the SparseListBySortedList representation, but knowing a priori
##  that they are sparse row vectors. The optional <zero> argument is
##  needed only when <poss> and <vals> are empty.
##
##  The NC version refrains from both checking and copying its arguments
##  The non-NC version makes a shallow copy of <poss> and <vals>
##

DeclareGlobalFunction( "SparseVectorBySortedList");
DeclareGlobalFunction( "SparseVectorBySortedListNC");
