#############################################################################
##
#W  ctblsolv.gd                 GAP library                     Thomas Breuer 
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declaration of operations for computing
##  characters of solvable groups.
##
Revision.ctblsolv_gd :=
    "@(#)$Id$";


#############################################################################
##
#A  BaumClausenInfo( <G> )  . . . . .  info about irreducible representations
##
##  returns a record with components
##
##  `pcgs'
##       each representation is encoded as a list, the entries encode images
##       of the elements in `pcgs',
##
##  `kernel'
##       the normal subgroup such that the result describes the irreducible
##       representations of the corresponding factor group only
##       (so *all* irreducible nonlinear representations are described if
##       and only if this subgroup is trivial),
##
##  `exponent'
##       the roots of unity in the representations are encoded as exponents
##       of a primitive `exponent'-th root,
##
##  `lin'
##       the list that encodes all linear representations of <G>,
##       each representation is encoded as a list of exponents,
##
##  `nonlin'
##       a list of nonlinear irreducible representations,
##       each a list of monomial matrices,
##
##  Monomial matrices are encoded as records with components
##  `perm' (the permutation part) and `diag' (the nonzero entries).
##  E. g., the matrix `rec( perm := [ 3, 1, 2 ], diag := [ 1, 2, 3 ] )'
##  stands for
##  [ . , . , 1 ]     [ e^1 ,  .  ,  .  ]   [  .  ,  .  , e^3 ]
##  [ 1 , . , . ]  *  [  .  , e^2 ,  .  ] = [ e^1 ,  .  ,  .  ] ,
##  [ . , 1 , . ]     [  .  ,  .  , e^3 ]   [  .  , e^2 ,  .  ]
##  where `e' is the value of `exponent' in the result record.
##
##  The algorithm of Baum and Clausen guarantees to compute all
##  irreducible representations for abelian by supersolvable groups;
##  if the supersolvable residuum of <G> is not abelian then this
##  implementation computes the irreducible representations of the factor
##  group of <G> by the derived subgroup of the supersolvable residuum.
##
##  For this purpose, a composition series
##  $\<> \< G_{lg} \< G_{lg-1} \< \ldots \< G_1 = <G>$
##  of <G> is used, where the maximal abelian and all nonabelian composition
##  subgroups are normal in <G>.
##  Iteratively the representations of $G_i$ are constructed from those of
##  $G_{i+1}$.
##
##  Let $[ g_1, g_2, \ldots, g_{lg} ]$ be a pcgs of <G>, and
##  $G_i = \< G_{i+1}, g_i >$.
##  The list `indices' holds the sizes of the composition factors, i.e.,
##  $`indices[i]' = [ G_i \colon G_{i+1} ]$.
##
##  The iteration is an application of the theorem of Clifford.
##  An irreducible representation of $G_{i+1}$ has either
##  $p = [ G_i \colon G_{i+1} ]$ extensions to $G_i$,
##  or the induced representation is irreducible in $G_i$.
##
##  In the case of extensions, a representing matrix for the canonical
##  generator $g_i$ is constructed.
##  The induction can be performed directly, afterwards the induced
##  representation is modified such that the restriction to $G_{i+1}$
##  decomposes into the direct sum of its constituents as block diagonal
##  decomposition, and the matrix for $g_i$ is constructed.
##
##  So the construction guarantees that the restriction of a
##  representation of $G_i$ to $G_{i+1}$ decomposes (physically) into a
##  direct sum of irreducible representations of $G_{i+1}$.
##  Moreover, two constituents are equivalent if and only if they are equal.
##
DeclareAttribute( "BaumClausenInfo", IsGroup );


#############################################################################
##
#F  IrreducibleRepresentations( <G>)
##
##  This function returns a record with components
##  `representations'
##       a list of group homomorphism from the group <G> to
##       matrix groups over a suitable cyclotomic field,
##
##  `kernel'
##       a normal subgroup $N$ of `G' such that the `representations'
##       component contains exactly the different absolutely irreducible
##       representations of `G' whose kernel contains $N$.
##  
DeclareAttribute( "IrreducibleRepresentations",
    IsGroup );


#############################################################################
##
#F  IrrBaumClausen( <G> ) . . . .  irred. characters of a supersolvable group
##
##  `IrrBaumClausen' returns a record with components
##
##  `irreducibles'
##       the irreducible characters of the factor group of <G> by the
##       derived subgroup of its supersolvable residuum,
##
##  `complete'
##       is `true' if the component `irreducibles' contains all irreducibles
##       of <G>, and `false' otherwise.
##
##  The absolutely irreducible characters of the group <G> in characteristic
##  zero are computed using the algorithm by Baum and Clausen,
##  see ...
##
DeclareAttribute( "IrrBaumClausen", IsGroup );


#############################################################################
##
#F  InducedRepresentationImagesRepresentative( <rep>, <H>, <R>, <g> )
##
##  Let $<rep>_H$ denote the restriction of the group homomorphism <rep> to
##  the group <H>, and $\phi$ the induced representation of $<rep>_H$ to $G$,
##  where <R> is a transversal of <H> in $G$.
##  `InducedRepresentationImagesRepresentative' returns the image of the
##  element <g> of $G$ under $\phi$.
##
DeclareGlobalFunction(
    "InducedRepresentationImagesRepresentative" );


#############################################################################
##
#F  InducedRepresentation( <rep>, <G> ) . . . . induced matrix representation
#F  InducedRepresentation( <rep>, <G>, <R> )
#F  InducedRepresentation( <rep>, <G>, <R>, <H> )
##
##  Let <rep> be a matrix representation of the group $H$, which is a
##  subgroup of the group <G>.
##  `InducedRepresentation' returns the induced matrix representation of <G>.
##
##  The optional third argument <R> is a right transversal of $H$ in <G>.
##  If the fourth optional argument <H> is given then it must be a subgroup
##  of the source of <rep>, and the induced representation of the restriction
##  of <rep> to <H> is computed.
##
DeclareGlobalFunction( "InducedRepresentation" );


#############################################################################
##              
#E  ctblsolv.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



