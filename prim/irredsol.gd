#############################################################################
##
#W  irredsol.gd                 GAP group library                  Mark Short
#W                                                           Burkhard Hofling
##
#H  @(#)$Id$
##
#Y  Copyright (C) 1993, Murdoch University, Perth, Australia
##
##  This file contains the  functions and  data for the  irreducible solvable
##  matrix group library.  It  contains  exactly one member  for each of  the
##  372  conjugacy  classes of  irreducible  solvable subgroups of  $GL(n,p)$
##  where $1 < n$, $p$ is a prime, and $p^n < 256$.  
##
##  By well-known  theory, this data also  doubles as a  library of primitive
##  solvable permutation groups of non-prime degree $<256$. 
##
##  This file contains the data  from Mark Short's thesis,  plus  two  groups 
##  missing from that list, subsequently discovered by Alexander Hulpke.
##
Revision.irredsol_gd :=
    "@(#)$Id$";

#############################################################################
##
#V  IrredSolJSGens[]  . . . . . . . . . . . . . . . generators for the groups
##
##  'IrredSolJSGens[<n>][<p>][<k>]' is a generating set for the <k>-th
##  JS-maximal of GL(<n>,<p>).
##  This generating set is polycyclic, i.e. forms an AG-system for the group.
##  A JS-maximal is a maximal irreducible solvable subgroup of GL(<n>,<p>)
##  (for a few exceptional small values of n and p this group isn't maximal).
##  Every group in the library is generated with reference to the generating
##  set of one of these JS-maximals, called its guardian (a group may be a
##  subgroup of several JS-maximals but it only has one guardian).
##
DeclareGlobalVariable("IrredSolJSGens");

#############################################################################
##
#V  IrredSolGroupList[] . . . . . . . . . . . . . . description of the groups
##
##  'IrredSolGroupList[<n>][<p>][<i>] is a list containing the information
##  about the <i>-th group from GL(<n>,<p>).
##  The groups are ordered with respect to the following criteria:
##      1. Increasing size
##      2. Increasing guardian number
##  If two groups have the same size and guardian, they are in no particular
##  order.
##
##  The list 'IrredSolGroupList[<n>][<p>][<i>] contains the following info:
##  Position: [1]:   the size of the group
##            [2]:   0 if group is linearly primitive,
##                   otherwise its minimal block size
##            [3]:   the absolute value is the number of the group's guardian,
##                   i.e. its position in 'IrredSolJSGens[<n>][<p>]',
##                   it's negative iff it equals its guardian
##            [4..]: the group's generators in normal form
##                   (with respect to its guardian's AG-system)
##
DeclareGlobalVariable ("IrredSolGroupList");


#############################################################################
##
#F  IrreducibleSolvableGroup( <n>, <p>, <i> )
##
##  This function is obsolete, because for $<n> = 2$, $<p> = 13$, 
##  two groups were missing from the
##  underlying database. It has been replaced by the function
##  `IrreducibleSolvableGroupMS' (see
##  "IrreducibleSolvableGroupMS"). Please note that the latter
##  function does not guarantee any ordering of the groups in the database.
##  However, for values of <n>, <p>, and <i> admissible to
##  `IrreducibleSolvableGroup',
##  `IrreducibleSolvableGroupMS' returns a representative of the
##  same conjugacy class of subgroups of <GL(n,p)> as
##  `IrreducibleSolvableGroup' did before. 
##
DeclareGlobalFunction("IrreducibleSolvableGroup");

#############################################################################
##
#F  IrreducibleSolvableGroupMS( <n>, <p>, <i> )
##
##  This function returns a representative of the <i>-th conjugacy class of
##  irreducible solvable subgroup of <GL(n,p)>, where <n> is an
##  integer $> 1$, <p> is a prime, and $<p>^{<n>} \< 256$.
## 
##  The numbering of the representatives should be 
##  considered arbitrary. However, it is guaranteed that the <i>-th 
##  group on this list will lie in the same conjugacy class in all future
##  versions of {\GAP}, unless two (or more) groups on the list are discovered
##  to be duplicates, in which case `IrreducibleSolvableMatrixGroup' will
##  return `fail' for all but one of the duplicates. 
##
##  For values of <n>, <p>, and <i> admissible to  `IrreducibleSolvableGroup',
##  `IrreducibleSolvableMatrixGroup' returns a representative of the same
##  conjugacy class of subgroups of <GL(n,p)> as `IrreducibleSolvableGroup'.
##  Note that it currently adds two more groups (missing from the
##  original list by Mark Short) for $<n> = 2$, $<p> = 13$. 
##
DeclareGlobalFunction("IrreducibleSolvableGroupMS");

#############################################################################
##
#F  NumberIrreducibleSolvableGroups( <n>, <p> )
##
##  This function returns the number of conjugacy classes of 
##  irreducible solvable subgroup of 
##  <GL(n,p)>. 
##
DeclareGlobalFunction("NumberIrreducibleSolvableGroups");
DeclareSynonym("NrIrreducibleSolvableGroups",NumberIrreducibleSolvableGroups);

#############################################################################
##
#F  AllIrreducibleSolvableGroups( <func_1>, <val_1>, <func_2>, <val_2>, ...)
##
##  This function returns a list  of conjugacy class representatives <G> of
##  matrix groups over a prime field such that $<func_i>(G) = <val_i>$ or
##  $<func_i>(G) \in <val_i>$. The following possibilities for <func_i> 
##  are particularly efficient, because the values can be read off the
##  information in the data base: `DegreeOfMatrixGroup' (or
##  `Dimension' or `DimensionOfMatrixGroup') for the linear  degree,
##  `Characteristic' for the field characteristic, `Size',
##  `IsPrimitiveMatrixGroup' (or `IsLinearlyPrimitive'), and
##  `MinimalBlockDimension'.
##
DeclareGlobalFunction("AllIrreducibleSolvableGroups");

#############################################################################
##
#F  OneIrreducibleSolvableGroup( <func1>, <val1>, <func2>, <val2>, ...)
##
##  This function returns one solvable subgroup <G> of a
##  matrix group over a prime field such that $<func_i>(G) = <val_i>$ or
##  $<func_i>(G) \in <val_i>$ for all <i>. The following possibilities
##  for <func_i>
##  are particularly efficient, because the values can be read off the
##  information in the data base: `DegreeOfMatrixGroup' (or
##  `Dimension' or `DimensionOfMatrixGroup') for the linear  degree,
##  `Characteristic' for the field characteristic, `Size',
##  `IsPrimitiveMatrixGroup' (or `IsLinearlyPrimitive'), and
##  `MinimalBlockDimension'.
##
DeclareGlobalFunction("OneIrreducibleSolvableGroup");

#############################################################################
##
#V  DegreeOfMatrixGroup(<G>)
##
##  This function returns the dimension of the underlying vector space,
##  same as `DimensionOfMatrixGroup'
##
DeclareSynonymAttr ("DegreeOfMatrixGroup", DimensionOfMatrixGroup);

#############################################################################
##
#A  MinimalBlockDimension(<G>)
##
##  The minimum integer <n> such that the matrix group has an imprimitivity
##  system consisting of <n>-dimensional subspaces of the underlying vector
##  space over `FieldOfMatrixGroup(G)'
##
DeclareAttribute("MinimalBlockDimension", IsMatrixGroup);

#############################################################################
##
#P  IsPrimitiveMatrixGroup(<G>)
##
##  `true' if <G> is primitive over `FieldOfMatrixGroup(G)' 
##
DeclareProperty("IsPrimitiveMatrixGroup", IsMatrixGroup);
DeclareSynonymAttr ("IsLinearlyPrimitive", IsPrimitiveMatrixGroup);

#############################################################################
##
#E
##








