#############################################################################
##
#W  grpmat.gd                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
InstallTrueMethod( IsHandledByNiceMonomorphism, IsMatrixGroup and IsFinite );


#############################################################################
##
#M  CanComputeSize( <mat-grp> )
##
InstallTrueMethod(CanComputeSize,IsMatrixGroup and IsFinite);

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
##  Linear group.
DeclareProperty( "IsGeneralLinearGroup", IsGroup );
DeclareSynonymAttr( "IsGL", IsGeneralLinearGroup );


#############################################################################
##
#P  IsNaturalGL( <matgrp> )
##
##  This property tests, whether a matrix group is the General Linear group
##  in the right dimension over the (smallest) ring which contains all
##  entries of its elements.
DeclareProperty( "IsNaturalGL", IsMatrixGroup );
InstallTrueMethod(IsGeneralLinearGroup,IsNaturalGL);

#############################################################################
##
#P  IsSpecialLinearGroup( <grp> )
#P  IsSL(<grp>)
##
##  The Special Linear group is the group of all invertible matrices over a
##  ring. This property tests, whether a group is isomorphic to a Special  
##  Linear group.
DeclareProperty( "IsSpecialLinearGroup", IsGroup );
DeclareSynonymAttr( "IsSL", IsSpecialLinearGroup );


#############################################################################
##
#P  IsNaturalSL( <matgrp> )
##
##  This property tests, whether a matrix group is the Special Linear group
##  in the right dimension over the (smallest) ring which contains all
##  entries of its elements.
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
#A  InvariantBilinearForm(<matgrp>)
##
##  This attribute contains a bilinear form that is invariant under
##  <matgrp>. The form is given by a record with the component `matrix'
##  which is a matrix <m> such that for every generator <g> of
##  <m> the equation $<g>\cdot<m>\cdot<g>^{tr}$ holds.
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
#A  InvariantSesquilinearForm(<matgrp>)
##
##  This attribute contains a sesquilinear form that is invariant under
##  <matgrp>. The form is given by a record with the component `matrix'
##  which is is a matrix <m> such that for every generator <g> of <m> the
##  equation $<g>\cdot<m>\cdot(<g>^{tr})^F$ holds, where $F$ is the
##  `FrobeniusAutomorphism' of the `FieldOfMatrixGroup' of <G>.
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
#E

