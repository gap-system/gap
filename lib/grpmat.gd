#############################################################################
##
#W  grpmat.gd                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations for matrix groups.
##
Revision.grpmat_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsMatrixGroup(<grp>)
##
DeclareSynonym( "IsMatrixGroup", IsRingElementCollCollColl and IsGroup );

#############################################################################
##
#M  IsHandledByNiceMonomorphism( <mat-grp> )
##
##  For finite matrix groups, there is a default method for
##  `NiceMonomorphism' based on the action on vectors from the right.
##
InstallTrueMethod( IsHandledByNiceMonomorphism, IsMatrixGroup and IsFinite );


#############################################################################
##
#M  CanComputeSize( <mat-grp> )
##
InstallTrueMethod(CanComputeSize,IsMatrixGroup and IsFinite);

#############################################################################
##
##  Operations of Matrix Groups
#1
##  The basic operations for groups are described in Chapter~"Group
##  Actions",
##  special actions for *matrix* groups mentioned there are `OnLines',
##  `OnRight', and `OnSubspacesByCanonicalBasis'.
#T what about acting directly on subspace objects via `OnRight'?
##
##  For subtleties concerning multiplication from the left or from the
##  right,
##  see~"Acting OnRight and OnLeft".
##


#############################################################################
##
#F  ProjectiveActionHomomorphismMatrixGroup(<G>)
##
##  returns an action homomorphism for a faithful projective action of <G>
##  on the underlying vector space. (Note: The action is not necessarily on
##  the full space, if a smaller subset can be found on which the action is
##  faithful.)
DeclareGlobalFunction("ProjectiveActionHomomorphismMatrixGroup");

#############################################################################
##
#A  DefaultFieldOfMatrixGroup( <mat-grp> )
##
##  Is a field containing all the matrix entries. It is not guaranteed to be
##  the smallest field with this property.
##
DeclareAttribute(
    "DefaultFieldOfMatrixGroup",
    IsMatrixGroup );

InstallSubsetMaintenance( DefaultFieldOfMatrixGroup,
        IsMatrixGroup and HasDefaultFieldOfMatrixGroup, IsMatrixGroup );

#############################################################################
##
#A  DimensionOfMatrixGroup( <mat-grp> )
##
##  The dimension of the matrix group.
##
DeclareAttribute(
    "DimensionOfMatrixGroup",
    IsMatrixGroup );


InstallSubsetMaintenance( DimensionOfMatrixGroup,
        IsMatrixGroup and HasDimensionOfMatrixGroup, IsMatrixGroup );


#############################################################################
##
#A  FieldOfMatrixGroup( <matgrp> )
##
##  The smallest  field containing all the  matrix entries of all elements
##  of the matrix group <matgrp>.  As the calculation of this can be hard,
##  this should only be used if  one *really*   needs     the
##  smallest   field,  use `DefaultFieldOfMatrixGroup' to get (for example)
##  the characteristic.
##
DeclareAttribute(
    "FieldOfMatrixGroup",
    IsMatrixGroup );


#############################################################################
##
#A  TransposedMatrixGroup( <matgrp> ) . . . . . . transpose of a matrix group
##
##  returns the transpose of the matrix group <matgrp>. The transpose of
##  the transpose of <matgrp> is identical to <matgrp>. 
## 
DeclareAttribute( "TransposedMatrixGroup", IsMatrixGroup );

#############################################################################
##
#F  NaturalActedSpace( [<G>, ]<acts>, <veclist> )
##
##  returns the space in which the action of <G> via the matrix list <acts>,
##  acting on the orbits of the vectors in <veclist> takes place. This
##  function is used for example by orbit calculations to obtain a suitable
##  domain for hashing.
## 
DeclareGlobalFunction("NaturalActedSpace");

#############################################################################
##
#P  IsGeneralLinearGroup( <grp> )
#P  IsGL(<grp>)
##
##  The General Linear group is the group of all invertible matrices over a
##  ring. This property tests, whether a group is isomorphic to a General
##  Linear group. (Note that currently only a few trivial methods are
##  available for this operation. We hope to improve this in the future.)
DeclareProperty( "IsGeneralLinearGroup", IsGroup );
DeclareSynonymAttr( "IsGL", IsGeneralLinearGroup );


#############################################################################
##
#P  IsNaturalGL( <matgrp> )
##
##  This property tests, whether a matrix group is the General Linear group
##  in the right dimension over the (smallest) ring which contains all
##  entries of its elements. (Currently, only a trivial test that computes
##  the order of the group is available.)
DeclareProperty( "IsNaturalGL", IsMatrixGroup );
InstallTrueMethod(IsGeneralLinearGroup,IsNaturalGL);

#############################################################################
##
#P  IsSpecialLinearGroup( <grp> )
#P  IsSL(<grp>)
##
##  The Special Linear group is the group of all invertible matrices over a
##  ring, whose determinant is equal to 1. This property tests, wether a
##  group is isomorphic to a Special Linear group. (Note that currently 
##  only a few trivial methods are available for this operation. We hope 
##  to improve this in the future.)
DeclareProperty( "IsSpecialLinearGroup", IsGroup );
DeclareSynonymAttr( "IsSL", IsSpecialLinearGroup );


#############################################################################
##
#P  IsNaturalSL( <matgrp> )
##
##  This property tests, whether a matrix group is the Special Linear group
##  in the right dimension over the (smallest) ring which contains all
##  entries of its elements. (Currently, only a trivial test that computes
##  the order of the group is available.)
DeclareProperty( "IsNaturalSL", IsMatrixGroup );
InstallTrueMethod(IsSpecialLinearGroup,IsNaturalSL);

#############################################################################
##
#P  IsSubgroupSL( <matgrp> )
##
##  This property tests, whether a matrix group is a subgroup of the Special
##  Linear group in the right dimension over the (smallest) ring which
##  contains all entries of its elements.
DeclareProperty( "IsSubgroupSL", IsMatrixGroup );
InstallTrueMethod(IsSubgroupSL,IsNaturalSL);


#############################################################################
##
#A  InvariantBilinearForm( <matgrp> )
##
##  This attribute describes a bilinear form that is invariant under the
##  matrix group <matgrp>.
##  The form is given by a record with the component `matrix'
##  which is a matrix <m> such that for every generator <g> of <matgrp>
##  the equation $<g> \cdot <m> \cdot <g>^{tr} = <m>$ holds.
##
DeclareAttribute( "InvariantBilinearForm", IsMatrixGroup );


#############################################################################
##
#P  IsFullSubgroupGLorSLRespectingBilinearForm(<matgrp>)
##
##  This property tests, whether a matrix group <matgrp> is the full
##  subgroup of GL or SL (the property `IsSubgroupSL' determines which it
##  is) respecting the `InvariantBilinearForm' of <matgrp>.
DeclareProperty( "IsFullSubgroupGLorSLRespectingBilinearForm", IsMatrixGroup );


#############################################################################
##
#A  InvariantSesquilinearForm( <matgrp> )
##
##  This attribute describes a sesquilinear form that is invariant under the
##  matrix group <matgrp> over the field $F$ with $q^2$ elements, say.
##  The form is given by a record with the component `matrix'
##  which is is a matrix <m> such that for every generator <g> of <matgrp>
##  the equation $<g> \cdot <m> \cdot (<g>^{tr})^f$ holds,
##  where $f$ is the automorphism of $F$ that raises each element to the
##  $q$-th power.
##  ($f$ can be obtained as a power of `FrobeniusAutomorphism( <F> )',
##  see~"FrobeniusAutomorphism".)
##
DeclareAttribute( "InvariantSesquilinearForm", IsMatrixGroup );


#############################################################################
##
#P  IsFullSubgroupGLorSLRespectingSesquilinearForm(<matgrp>)
##
##  This property tests, whether a matrix group <matgrp> is the full
##  subgroup of GL or SL (the property `IsSubgroupSL' determines which it
##  is) respecting the `InvariantSesquilinearForm' of <matgrp>.
DeclareProperty( "IsFullSubgroupGLorSLRespectingSesquilinearForm",
  IsMatrixGroup );


#############################################################################
##
#A  InvariantQuadraticForm( <matgrp> )
##
##  For a matrix group <matgrp>, `InvariantQuadraticForm' returns a record
##  containing at least the component `matrix' whose value is a matrix $Q$.
##  The quadratic form $q$ on the natural vector space $V$ on which <matgrp>
##  acts is given by $q(v) = v Q v^{tr}$, and the invariance under <matgrp>
##  is given by the equation $q(v) = q(v M)$ for all $v\in V$ and $M$ in
##  <matgrp>.
##  (Note that the invariance of $q$ does *not* imply that the matrix $Q$
##  is invariant under <matgrp>.)
##
##  $q$ is defined relative to an invariant symmetric bilinear form $f$
##  (see~"InvariantBilinearForm"), via the equation
##  $q(\lambda x + \mu y) = \lambda^2 q(x) + \lambda\mu f(x,y) + \mu^2 q(y)$
##  (see Chapter~3.4 in~\cite{CCN85}).
##  If $f$ is represented by the matrix $F$ then this implies
##  $F = Q + Q^{tr}$.
##  In characteristic different from $2$, we have $q(x) = f(x,x)/2$,
##  so $Q$ can be chosen as the strictly upper triangular part of $F$
##  plus half of the diagonal part of $F$.
##  In characteristic $2$, $F$ does not determine $Q$ but still $Q$ can be
##  chosen as an upper (or lower) triangular matrix.
##
##  Whenever the `InvariantQuadraticForm' value is set in a matrix group
##  then also the `InvariantBilinearForm' value can be accessed,
##  and the two values are compatible in the above sense.
#T So wouldn't it be natural to store the inv. bilinear form in the
#T record of the invariant quadratic form?
##
DeclareAttribute( "InvariantQuadraticForm", IsMatrixGroup );


#############################################################################
##
#P  IsFullSubgroupGLorSLRespectingQuadraticForm( <matgrp> )
##
##  This property tests, whether the matrix group <matgrp> is the full
##  subgroup of GL or SL (the property `IsSubgroupSL' determines which it
##  is) respecting the `InvariantQuadraticForm' value of <matgrp>.
##
DeclareProperty( "IsFullSubgroupGLorSLRespectingQuadraticForm",
    IsMatrixGroup );

#############################################################################
##
#F  AffineActionByMatrixGroup( <M> )
##
##  takes a group <M> of $n \times n$ matrices over the finite field $F$
##  and returns an affine permutation group $F^n {:} <M>$
##  for the natural action of <M> on the vector space $F^n$.
##  The labelling of the points of the resulting group is not guaranteed.
##
DeclareGlobalFunction( "AffineActionByMatrixGroup" );


#############################################################################
##
#F  BlowUpIsomorphism( <matgrp>, <B> )
##
##  For a matrix group <matgrp> and a basis <B> of a field extension $L / K$,
##  say, such that the entries of all matrices in <matgrp> lie in $L$,
##  `BlowUpIsomorphism' returns the isomorphism with source <matgrp>
##  that is defined by mapping the matrix $A$ to $`BlownUpMat'( A, <B> )$,
##  see~"BlownUpMat".
##
DeclareGlobalFunction( "BlowUpIsomorphism" );


#############################################################################
##
#E

