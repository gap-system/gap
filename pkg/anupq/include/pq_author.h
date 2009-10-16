/****************************************************************************
**
*A  pq_author.h                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: pq_author.h,v 1.7 2006/01/24 04:50:24 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#define PQ_VERSION "ANU p-Quotient Program Version 1.8"

/* 
###############################################################################
#
#     Australian National University p-Quotient Program 
#
#     Version 1.8
#
#     June 2001 (-v and -G options added and adapted to GAP 4)
#
###############################################################################

This implementation was developed in C by 

Eamonn O'Brien 
Department of Mathematics
University of Auckland
Private Bag 92019, Auckland, New Zealand

E-mail: obrien@math.auckland.ac.nz

WWW http://www.math.auckland.ac.nz/~obrien

###############################################################################
#
# Program content 
# 
###############################################################################

The program provides access to implementations of the following algorithms:

1. A p-quotient algorithm to compute a power-commutator presentation
for a p-group.  The algorithm implemented here is based on that 
described in Havas and Newman (1980) and papers referred to there.
Another description of the algorithm appears in Vaughan-Lee (1990b).
A FORTRAN implementation of this algorithm was programmed by 
Alford & Havas. The basic data structures of that implementation 
are retained.

The current implementation incorporates the following features:

a. collection from the left (see Vaughan-Lee, 1990b); 
   Vaughan-Lee's implementation of this collection 
   algorithm is used in the program;

b. an improved consistency algorithm (see Vaughan-Lee, 1982);

c. new exponent law enforcement and power routines; 

d. closing of relations under the action of automorphisms;

e. some formula evaluation.

For details of these latter improvements, see 
Newman and O'Brien (1996). 

2. A p-group generation algorithm to generate descriptions of p-groups. 
The algorithm implemented here is based on the algorithms described in 
Newman (1977) and O'Brien (1990). A FORTRAN implementation of this 
algorithm was earlier developed by Newman & O'Brien.  

3. A standard presentation algorithm used to compute a canonical 
power-commutator presentation of a p-group. The algorithm 
implemented here is described in O'Brien (1994).

4. An algorithm which can be used to compute the automorphism group of 
a p-group. The algorithm implemented here is described in O'Brien (1995).


###############################################################################
#
#Access via other programs
#
###############################################################################

Access to parts of this program is provided via GAP, Magma, 
and Quotpic. 

This program is supplied as a package within GAP.
The link from GAP 4 to pq is described in the ANUPQ share
package manual; all of the necessary code with documentation 
can be found in the gap directory of this distribution.

###############################################################################
#
#References
#
###############################################################################

George Havas and M.F. Newman (1980), "Application of computers
to questions like those of Burnside", Burnside Groups (Bielefeld, 1977), 
Lecture Notes in Math. 806, pp. 211-230. Springer-Verlag.

M.F. Newman (1977), "Determination of groups of prime-power order", 
Group Theory (Canberra, 1975). Lecture Notes in Math. 573, pp. 73-84. 
Springer-Verlag.

M.F. Newman and E.A. O'Brien (1996), "Application of computers to 
questions like those of Burnside II", Internat. J. Algebra Comput.

E.A. O'Brien (1990), "The p-group generation algorithm",
J. Symbolic Comput. 9, 677-698.

E.A. O'Brien (1994), ``Isomorphism testing for p-groups", 
J. Symbolic Comput. 17, 133-147.

E.A. O'Brien (1995), ``Computing automorphism groups of p-groups", 
Computational Algebra and Number Theory, (Sydney, 1992), pp. 83--90. 
Kluwer Academic Publishers, Dordrecht.

M.R. Vaughan-Lee (1982), "An Aspect of the Nilpotent Quotient Algorithm", 
Computational Group Theory (Durham, 1982), pp. 76-83. Academic Press.

Michael Vaughan-Lee (1990a), The Restricted Burnside Problem,
London Mathematical Society monographs (New Ser.) #5.
Clarendon Press, New York, Oxford.

M.R. Vaughan-Lee (1990b), "Collection from the left", 
J. Symbolic Comput. 9, 725-733.

*/
