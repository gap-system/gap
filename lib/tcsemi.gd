#############################################################################
##
##
#W  tcsemi.gd           GAP library                     Goetz.Pfeiffer@UCG.IE
##
##  Installed in GAP4 by Andrew Solomon for Semigroups instead of Monoids.
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains declarations for Todd-Coxeter procedure for
##  fp semigroups.
##
Revision.tcsemi_gd :=
    "@(#)$Id$";

############################################################################
##
#A  CosetTableOfFpSemigroup(<r>)
##
##  <r> is a right congruence of an fp-semigroup <S>.
##  This attribute is the coset table of FP semigroup 
##  <S> on a right congruence <r>.
##  Given a right congruence <r> we represent <S> as a set of 
##  transformations of the congruence classes of <r>.
##
##
##  The images   of the cosets under the   generators are compiled in  a list
##  <table> such that  <table[i][s]> contains  the image  of  coset <s> under
##  generator <i>.   

DeclareAttribute("CosetTableOfFpSemigroup", IsRightMagmaCongruence);

##  The preimages are  stored in a similar  way  in the list
##  |occur|.  Here |occur[i][s]|  contains the set  of  all cosets  which are
##  mapped to |s| under generator |i|.  There the empty set is represented by
##  0. The  list |occur| is needed  for the sole   purpose of identifying the
##  places in |table| where a coset |t|  occurs if this  needs to be replaced
##  by a coset |s|.
##

SemigroupTCInitialTableSize:= 5000000;

############################################################################
#E
