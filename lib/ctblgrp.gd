#############################################################################
##
#W  ctblgrp.gd                   GAP library                 Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C) 1997
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for the Dixon-Schneider algorithm
##
Revision.ctblgrp_gd :=
    "@(#)$Id$";

DeclareGlobalFunction("DxModularValuePol");
DeclareGlobalFunction("DxDegreeCandidates");

#############################################################################
##
#A  DixonRecord(<G>)
##
##  The `DixonRecord' of a group contains information used by the routines
##  to compute the character table via the Dixon-Schneider algorithm like class
##  arrangement and character spaces split obtained so far. Usually
##  this record is passed as argument to all subfunctions to avoid a long
##  argument list. It has a component `.conjugacyClasses' which contains the
##  classes of <G> *ordered as the algorithm needs then*.
##
DeclareAttribute("DixonRecord",IsGroup,"mutable");

#############################################################################
##
#O  DxPreparation(<G>,<D>)
##
##  Creates enttries in the dixon record <D> of the group <G> which are
##  representation dependent, like functions to identify the class of
##  elements.
DeclareOperation("DxPreparation",[IsGroup,IsRecord]);

#############################################################################
##
#F  ClassComparison(<c>,<d>)  . . . . . . . . . . . . compare classes c and d
##
##  Comparison function for conjugacy classes, used by `Sort'.
##  Comparison is based first on the size of the class and then on the
##  order of the representatives. Thus the 1-Class is in the first position,
##  as required. Since sorting is primary by the class sizes,smaller
##  classes are in earlier positions, making the active columns those to
##  smaller classes, thus reducing the work for calculating class matrices.
##  Additionally, galois conjugated classes are kept together, thus increasing
##  the chance,that with one columns of them active to be several active,
##  again reducing computation time.
##
DeclareGlobalFunction( "ClassComparison");

#############################################################################
##
#F  DxIncludeIrreducibles(<D>,<new>,[<newmod>]) . . . . handle (newly?) found
##                                                               irreducibles
##
##  This function takes a list of irreducible characters (each given as a
##  list of values, corresponding to the class arrangement in <D>) <new> and
##  adds these to a partial computed list of
##  irreducibles as maintained by the dixon record <D>. This permits to add
##  characters in interactive use obtained from other sources and to contain the
##  D-S calculation afterwards. If the optional argument <newmod> is given, it
##  must be a list of reduced characters, corresponding to <new>. (Otherwise the
##  function has to reduce the characters itself.
##
DeclareGlobalFunction("DxIncludeIrreducibles");

#############################################################################
##
#F  SplitCharacters(<D>,<list>)   split characters according to the spaces
##
##  this function can be applied to a list of ordinary characters. It splits
##  these according to the character spaces yet known. This can be used
##  interactively to utilize partially computed spaces.
##
DeclareGlobalFunction("SplitCharacters");

#############################################################################
##
#F  OrbitSplit(<D>) . . . . . . . . . . . . . . try to split two-orbit-spaces
##
##  Tries to split two-orbit character spaces.
##
DeclareGlobalFunction("OrbitSplit");

#############################################################################
##
#F  DxSplitDegree(<D>,<space>,<r>)                                    local
##  estimates the number of parts obtained when splitting the character space
##  <space> with matrix number <r>. This estimate is obtained using charcter
##  morphisms.
##
DeclareGlobalFunction("DxSplitDegree");

#############################################################################
##
#F  BestSplittingMatrix(<D>) . number of the matrix,that will yield the best
#F                                                                      split
##  returns the number of the class sum matrix that is assumed to yield the 
##  best (cost/earning ration) split. This matrix then will be the next one
##  computed and used.
##
DeclareGlobalFunction("BestSplittingMatrix");

#############################################################################
##
#F  DixonInit(<G>) . . . . . . . . . . initialize Dixon-Schneider algorithm
##
##  This function does all the initializations for the Dixon-Schneider
##  algorithm. This includes calculation of conjugacy classes, power maps,
##  linear characters and character morphisms. It returns a dixon record of
##  <G>, that can be used when calculating the character table interactively.
##
DeclareGlobalFunction("DixonInit");

#############################################################################
##
#F  DixonSplit(<D>) . .  calculate matrix,split spaces and obtain characters
##
##  This function performs one splitting step in the Dixon-Schneider
##  algorithm. It selects a class, computes the (partial) class sum matrix, uses
##  it to split character spaces and stores all the irreducible characters
##  obtained that way.
##
DeclareGlobalFunction("DixonSplit");

#############################################################################
##
#F  DixontinI(<D>)  . . . . . . . . . . . . . . . .  reverse initialisation
##
##  This function ends a Dixon-Schneider calculation and reverses
##  the old group is returned, characters are sorted according to the
##  class arrangement in the group and components only used internally are
##  unbound from the dixon record. It returns a list of irreducible
##  characters.
##
DeclareGlobalFunction("DixontinI");

#############################################################################
##
#F  IrrDixonSchneider(<G>) . . . . .  character table of finite group G
##
##  Compute the table of the irreducible characters of G,using the
##  Dixon/Schneider method. It calls `DixonInit', `DixonSplit' and
##  `OrbitSplit' (as often as necessary) and returns the list returned by
##  `DixontinI'.
##
DeclareGlobalFunction("IrrDixonSchneider");

#############################################################################
##
#E  ctblgrp.gd
##
