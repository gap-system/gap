#############################################################################
##
#W  ctbllatt.gd                 GAP library                       Ansgar Kaup
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration of functions that mainly deal with
##  lattices in the context of character tables.
##
Revision.ctbllatt_gd :=
    "@(#)$Id$";


#############################################################################
##  \Section{LLL}%
##  \index{LLL algorithm!for characters}%
##  \index{short vectors spanning a lattice}%
##  \index{lattice base reduction}
##  
#F  'LLL( <tbl>, <characters> [, <y>] [, \"sort\"] [, \"linearcomb\"] )'
##
##  calls the LLL algorithm (see "LLLReducedBasis") in the case of lattices
##  spanned by (virtual) characters <characters> of the character table <tbl>
##  (see "ScalarProduct").  By finding shorter vectors in the lattice spanned
##  by <characters>, i.e.  virtual characters of smaller norm, in some cases
##  'LLL' is able to find irreducible characters.
##  
##  'LLL' returns a record with at least components 'irreducibles' (the list
##  of found irreducible characters), 'remainders' (a list of reducible
##  virtual characters), and 'norms' (the list of norms of 'remainders').
##  'irreducibles' together with 'remainders' span the same lattice as
##  <characters>.
##  
##  There are some optional parameters\:
##  
##  <y>:\\ controls the sensitivity of the algorithm; the value of <y> must
##         be between $1/4$ and 1, the default value is $3/4$.
##  
##  '\"sort\"':\\
##         'LLL' sorts <characters> and the 'remainders' component of the
##         result according to the degrees.
##  
##  '\"linearcomb\"':\\ The returned record contains components 'irreddecomp'
##         and 'reddecomp' which are decomposition matrices of 'irreducibles'
##         and 'remainders', with respect to <characters>.
##  
##  |    gap> s4:= CharTable( "Symmetric", 4 );;
##      gap> chars:= [ [ 8, 0, 0, -1, 0 ], [ 6, 0, 2, 0, 2 ],
##      >     [ 12, 0, -4, 0, 0 ], [ 6, 0, -2, 0, 0 ], [ 24, 0, 0, 0, 0 ],
##      >     [ 12, 0, 4, 0, 0 ], [ 6, 0, 2, 0, -2 ], [ 12, -2, 0, 0, 0 ],
##      >     [ 8, 0, 0, 2, 0 ], [ 12, 2, 0, 0, 0 ], [ 1, 1, 1, 1, 1 ] ];;
##      gap> LLL( s4, chars );
##      rec(
##        irreducibles :=
##         [ [ 2, 0, 2, -1, 0 ], [ 1, 1, 1, 1, 1 ], [ 3, 1, -1, 0, -1 ], 
##            [ 3, -1, -1, 0, 1 ], [ 1, -1, 1, 1, -1 ] ],
##        remainders := [  ],
##        norms := [  ] )|
##  
LLL := NewOperationArgs( "LLL" );


#############################################################################
##
#F  Extract( <tbl>, <reducibles>, <gram-matrix> [, <missing> ] )
##
Extract := NewOperationArgs( "Extract" );


#############################################################################
##
#F  Decreased( <tbl>, <chars>, <decompmat>, [ <choice> ] )
##
Decreased := NewOperationArgs( "Decreased" );


#############################################################################
##
#F  OrthogonalEmbeddingsSpecialDimension( <tbl>, <reducibles>, <grammat>,
#F                                        [, \"positive\" ], <integer> )
##
OrthogonalEmbeddingsSpecialDimension := NewOperationArgs(
    "OrthogonalEmbeddingsSpecialDimension" );


#############################################################################
##
#F  DnLattice( <tbl>, <g1>, <y1> )
##
DnLattice := NewOperationArgs( "DnLattice" );


#############################################################################
##
#F  DnLatticeIterative( <tbl>, <red> )
##
DnLatticeIterative := NewOperationArgs( "DnLatticeIterative" );


#############################################################################
##
#E  ctbllatt.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



