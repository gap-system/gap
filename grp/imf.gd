#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Volkmar Felsch.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains  the declarations of operations for the GAP library of
##  irreducible maximal finite integral matrix groups.
##


#############################################################################
##
#V  InfoImf
##
##  is the info class for the imf functions
##  (see~"Info Functions").
##
DeclareInfoClass( "InfoImf" );


#############################################################################
##
##  Some global variables.
##


#############################################################################
##
#F  IsImfMatrixGroup( <G> )
##
DeclareFilter( "IsImfMatrixGroup" );


#############################################################################
##
#A  ImfRecord( <G> )
##
DeclareAttribute( "ImfRecord", IsGroup, "mutable" );


#############################################################################
##
##  list of global variables not thought for the user
##

#############################################################################
##
#F  BaseShortVectors( <orbit> ) . . . . . . . . . . . . . . . . . . . . . . .
##
##  'BaseShortVectors' expects as argument an  orbit of short vectors  under
##  some  imf  matrix  group  of  dimension  dim,  say.  This  orbit  can  be
##  considered  as  a set of generatos  of a  dim-dimensional  Q-vectorspace.
##  'BaseShortVectors' determines a subset B of <orbit> which is a base
##  of that vectorspace, and it returns a list of two lists containing
##
##  - a list of the position numbers with respect to <orbit> of the  elements
##    of the base B and
##  - the base change matrix B^-1.
##
##  Both will be needed by the function 'ImfPermutationToMatrix'.
##
DeclareGlobalFunction( "BaseShortVectors" );


#############################################################################
##
#F  DisplayImfInvariants( <dim>, <q> )  . . . . . . . . . . . . . . . . . . .
#F  DisplayImfInvariants( <dim>, <q>, <z> ) . . . . . . . . . . . . . . . . .
##
##  'DisplayImfInvariants'  displays some Z-class invariants of the specified
##  classes  of  irreducible maximal finite  integral matrix groups  in  some
##  easily readable format.
##
##  The default value of z is 1. If any of the arguments is zero, the routine
##  loops over all legal values of the respective parameter.
##
DeclareGlobalFunction( "DisplayImfInvariants" );


#############################################################################
##
#F  DisplayImfReps( <dim>, <q>, <z> ) . . . . . . . . . . . . . . . . . . . .
##
##  'DisplayImfReps'  is a subroutine of the  'DisplayImfInvariants' command.
##  It displays  some  Z-class invariants  of the  zth Z-classes  in the  qth
##  Q-class  of the  irreducible  maximal finite  integral matrix  groups  of
##  dimension dim.
##
##  If an argument  z = 0  has been specified,  then all classes in the given
##  Q-class will be displayed,  otherwise just the  zth Z-class is displayed.
##
##  This subroutine is considered to be an internal one.  Hence the arguments
##  are not checked for being in range.  Moreover, it is assumed that the imf
##  main list IMFList has already been loaded.
##
DeclareGlobalFunction( "DisplayImfReps" );


#############################################################################
##
#F  ImfInvariants( <dim>, <q> ) . . . . . . . . . . . . . . . . . . . . . . .
#F  ImfInvariants( <dim>, <q>, <z> )  . . . . . . . . . . . . . . . . . . . .
##
##  'ImfInvariants' returns a record of Z-class invariants of the zth Z-class
##  in the  qth Q-class of  irreducible maximal finite integral matrix groups
##  of dimension dim. The default value of z is 1.
##
##  Assume that  G  is a representative group of the specified Z-class.  Then
##  the resulting record contains the following components:
##
##  size                     group size of G,
##  isSolvable               true, if G is solvable,
##  isomorphismType          isomorphism type of G,
##  elementaryDivisors       elementary divisors of G,
##  minimalNorm              norm of the short vectors associated to G,
##  sizesOrbitsShortVectors  a list  of the  sizes  of the  orbits  of  short
##                           vectors associated to G,
##  maximalQClass            Q-class  number  of  corresponding  rational  imf
##                           class (only if it is different from q).
##
##  If a value z > 1 has been specified  for a dimension for which no Z-class
##  representatives are available,  the function will display  an appropriate
##  message and return the value 'false'.
##
DeclareGlobalFunction( "ImfInvariants" );


#############################################################################
##
#F  IMFLoad( <dim> ) . . . . . . . . load a secondary file of the imf library
##
##  'IMFLoad' loads the imf main list and,  if dim > 0,  the list of matrices
##  containing  the  Gram  matrices  and  the  lists  of  generators  for the
##  irreducible maximal finite  integral matrix groups  of  dimension  <dim>.
##  Nothing is done if the required lists have already been loaded.
##
##  'IMFLoad'  finds the files in the directory specified by 'GRPNAME'.  This
##  variable is set in the init file 'LIBNAME/\"init.g\"'.
##
##  The given dimension is not checked to be in range.
##
DeclareGlobalFunction( "IMFLoad" );


#############################################################################
##
#F  ImfMatrixGroup( <dim>, <q> )  . . . . . . . . . . . . . . . . . . . . . .
#F  ImfMatrixGroup( <dim>, <q>, <z> ) . . . . . . . . . . . . . . . . . . . .
##
##  'ImfMatrixGroup' returns the representative of the zth Z-class in the qth
##  Q-class of the  irreducible  maximal  finite  integral  matrix groups  of
##  dimension dim. The default value of z is 1.
##
##  If a value z > 1 has been specified  for a dimension for which no Z-class
##  representatives are available,  the function will display  an appropriate
##  message and return the value 'false'.
##
DeclareGlobalFunction( "ImfMatrixGroup" );


#############################################################################
##
#F  ImfNumberQClasses( <dim> )  . . . . . . . . . . . . . . . . . . . . . . .
##
##  'ImfNumberQClasses'   returns  the  number  of   available  Q-classes  of
##  irreducible maximal finite subgroups of dimension dim,  i. e., the number
##  of Q-classes of irreducible maximal finite subgroups of GL(dim,Z), if dim
##  is at most 11  or  a prime,  or  the number of  Q-classes of  irreducible
##  maximal finite subgroups of GL(dim,Q), else.
##
DeclareGlobalFunction( "ImfNumberQClasses" );


#############################################################################
##
#F  ImfNumberQQClasses( <dim> ) . . . . . . . . . . . . . . . . . . . . . . .
##
##  'ImfNumberQQClasses'  returns  the  number of  Q-classes  of  irreducible
##  maximal finite subgroups of GL(dim,Q).
##
DeclareGlobalFunction( "ImfNumberQQClasses" );


#############################################################################
##
#F  ImfNumberZClasses( <dim>, <q> ) . . . . . . . . . . . . . . . . . . . . .
##
##  'ImfNumberZClasses' returns the number of available class representatives
##  in the  qth  Q-class of irreducible maximal finite integral matrix groups
##  of dimension dim,  i. e., the number of Z-classes in that Q-class, if dim
##  is at most 11 or a prime, or just the value 1, else.
##
DeclareGlobalFunction( "ImfNumberZClasses" );


#############################################################################
##
#F  ImfPositionNumber( [ <dim>, <q> ] ) . . . . . . . . . . . . . . . . . . .
#F  ImfPositionNumber( [ <dim>, <q>, <z> ] )  . . . . . . . . . . . . . . . .
##
##  'ImfPositionNumber'  loads the imf main list  if it is not yet available.
##  Then it checks the given arguments and returns the position number of the
##  specified  Z-class representative  within the list of all representatives
##  of dimension dim  which is still  in the  original order  as submitted to
##  us by LehrstuhL B. The default value of z is 1.
##
DeclareGlobalFunction( "ImfPositionNumber" );


#############################################################################
##
#F  OrbitShortVectors( <gens>, <rep> )  . . . . . . . . . . . . . . . . . . .
##
##  'OrbitShortVectors'  is a subroutine of the  'PermGroupImfGroup' command.
##  It returns  the orbit of the  short vector  <rep>  under the matrix group
##  generators given in list <gens>.
##
DeclareGlobalFunction( "OrbitShortVectors" );


#############################################################################
##
#F  IsomorphismPermGroupImfGroup( <M> ) . . . . . . . . . . . . . . . . . . .
#F  IsomorphismPermGroupImfGroup( <M>, <n> )  . . . . . . . . . . . . . . . .
##
##  'IsomorphismPermGroupImfGroup'  returns  an  isomorphism  from  the given
##  irreducible maximal finite integral matrix group  to the permutation grou
##  induced by the action of M  on its nth orbit on the set of short vectors.
##  The default value of n is 1.
##
DeclareGlobalFunction( "IsomorphismPermGroupImfGroup" );
