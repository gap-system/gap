#############################################################################
##
#W  grpramat.gd                 GAP Library                     Franz G"ahler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for matrix groups over the rationals
##
Revision.grpramat_gd :=
    "@(#)$Id$";

#############################################################################
##
#P  IsCyclotomicMatrixGroup( <G> )
##
##  tests whether all matrices in <G> have cyclotomic entries.
IsCyclotomicMatrixGroup := IsCyclotomicCollCollColl and IsMatrixGroup;

#############################################################################
##
#P  IsRationalMatrixGroup( <G> )
##
##  tests whether all matrices in <G> have rational entries.
DeclareProperty("IsRationalMatrixGroup", IsCyclotomicMatrixGroup);

#############################################################################
##
#P  IsIntegerMatrixGroup( <G> )
##
##  tests whether all matrices in <G> have integer entries.
#T  Not `IsIntegralMatrixGroup' to avoid confusion with matrix groups of
#T  integral cyclotomic numbers.  
DeclareProperty("IsIntegerMatrixGroup", IsCyclotomicMatrixGroup);

#############################################################################
##
#P  IsNaturalGLnZ( <G> )
##
##  tests whether <G> is $GL_n(\Z)$ in its natural representation by
##  $n\times n$ integer matrices. (The dimension $n$ will be read off the
##  generating matrices.)
IsNaturalGLnZ := IsNaturalGL and IsIntegerMatrixGroup;

#############################################################################
##
#A  ZClassRepsQClass( G ) . . . . . . . . . . .  Z-class reps in Q-class of G
##
##  The conjugacy class in $GL_n(\Q)$ of the finite integer matrix 
##  group <G> splits into finitely many conjugacy classes in $GL_n(\Z)$.
##  `ZClassRepsQClass( <G> )' returns representative groups for these.
DeclareAttribute( "ZClassRepsQClass", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  NormalizerInGLnZ( G ) . . . . . . . . . . . . . . . . .  NormalizerInGLnZ
##
##  is an attribute used to store the normalizer of <G> in $GL_n(\Z)$,
##  where <G> is an integer matrix group of dimension <n>. This attribute
##  is used by `Normalizer( GL( n, Integers ), G )'. 
DeclareAttribute( "NormalizerInGLnZ", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  CentralizerInGLnZ( G ) . . . . . . . . . . . . . . . . .CentralizerInGLnZ
##
##  is an attribute used to store the centralizer of <G> in $GL_n(\Z)$,
##  where <G> is an integer matrix group of dimension <n>. This attribute
##  is used by `Centralizer( GL( n, Integers ), G )'. 
DeclareAttribute( "CentralizerInGLnZ", IsCyclotomicMatrixGroup );

#############################################################################
##
##  RightAction or LeftAction
##

#1
##  In {\GAP}, matrices by convention act on row vectors from the right,
##  whereas in crystallography the convention is to act on column vectors
##  from the left. The definition of certain algebraic objects important
##  in crystallography implicitly depends on which action is assumed.
##  This holds true in particular for quadratic forms invariant under
##  a matrix group. In a similar way, the representation of affine 
##  crystallographic groups, as they are provided by the share package
##  CrystGap, depends on which action is assumed. Crystallographers
##  are used to the action from the left, whereas the action from the
##  right is the natural one for {\GAP}. For this reason, a number of 
##  functions which are important in crystallography, and whose result 
##  depends on which action is assumed, are provided in two versions, 
##  one for the usual action from the right, and one for the 
##  crystallographic action from the left. 
##
##  For every such function, this fact is explicitly mentioned. 
##  The naming scheme is as follows: If `SomeThing' is such a function, 
##  there will be functions `SomeThingOnRight' and `SomeThingOnLeft', 
##  assuming action from the right and from the left, repectively. 
##  In addition, there is a generic function `SomeThing', which returns 
##  either the result of `SomeThingOnRight' or `SomeThingOnLeft', 
##  depending on the global variable `CrystGroupDefaultAction'.

#############################################################################
##
#V  CrystGroupDefaultAction
##
##  can have either of the two values `RightAction' and `LeftAction'. 
##  The initial value is `RightAction'. For functions which have 
##  variants OnRight and OnLeft, this variable determines which 
##  variant is returned by the generic form. The value of 
##  `CrystGroupDefaultAction' can be changed with with the 
##  function `SetCrystGroupDefaultAction'.
##
DeclareGlobalVariable( "CrystGroupDefaultAction" );

BindGlobal( "LeftAction",  Immutable( "LeftAction"  ) );
BindGlobal( "RightAction", Immutable( "RightAction" ) );

#############################################################################
##
#F  SetCrystGroupDefaultAction( <action> ) . . . . .RightAction or LeftAction
##
##  allows to set the value of the global variable `CrystGroupDefaultAction'.
##  Only the arguments `RightAction' and `LeftAction' are allowed.
##  Initially, the value of `CrystGroupDefaultAction' is `RightAction'
DeclareGlobalFunction( "SetCrystGroupDefaultAction" );

#############################################################################
##
#P  IsBravaisGroup( <G> ) . . . . . . . . . . . . . . . . . . .IsBravaisGroup
##
##  test whether <G> coincides with its Bravais group (see "BravaisGroup").
DeclareProperty( "IsBravaisGroup", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  BravaisGroup( <G> ) . . . . . . . . Bravais group of integer matrix group
##
##  returns the Bravais group of a finite integer matrix group <G>. 
##  If <C> is the cone of positive definite quadratic forms <Q> invariant 
##  under $g \to g*Q*g^{tr}$ for all $g \in G$, then the Bravais group 
##  of <G> is the maximal subgroup of $GL_n(\Z)$ leaving the forms in
##  that same cone invariant. Alternatively, the Bravais group of <G> 
##  can also be defined with respect to the action $g \to g^{tr}*Q*g$
##  on positive definite quadratic forms <Q>. This latter definition 
##  is appropriate for groups <G> acting from the right on row vectors, 
##  whereas the former definition is appropriate for groups acting from 
##  the left on column vectors. Both definitions yield the same 
##  Bravais group.
DeclareAttribute( "BravaisGroup", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  BravaisSubgroups( <G> ) . . . . . . . .Bravais subgroups of Bravais group
##
##  returns the subgroups of the Bravais group of <G>, which are 
##  themselves Bravais groups.
DeclareAttribute( "BravaisSubgroups", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  BravaisSupergroups( <G> ) . . . . . .Bravais supergroups of Bravais group
##
##  returns the subgroups of $GL_n(\Z)$ that contain the Bravais group 
##  of <G> and are Bravais groups themselves.
DeclareAttribute( "BravaisSupergroups", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  NormalizerInGLnZBravaisGroup( <G> ) . norm. of Bravais group of G in GLnZ
##
##  returns the normalizer of the Bravais group of <G> in the 
##  appropriate $GL_n(\Z)$.
DeclareAttribute( "NormalizerInGLnZBravaisGroup", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  InvariantLattice( G )
##
##  returns a matrix <B>, whose rows form a basis of a $\Z$-lattice that 
##  is invariant under the rational matrix group <G> acting from the right. 
##  It returns `fail' if the group is not unimodular. The columns of the
##  inverse of <B> span a $\Z$-lattice invariant under <G> acting from 
##  the left.
DeclareAttribute( "InvariantLattice", IsCyclotomicMatrixGroup );

#############################################################################
##
#E  grpramat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

