#############################################################################
##
#W  ctblgrp.gd                   GAP library                 Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C) 1997
##
##  This file contains the declarations for the Dixon-Schneider algorithm
##
Revision.ctblgrp_gd :=
    "@(#)$Id$";

DxModularValuePol:=NewOperationArgs("DxModularValuePol");
DxDegreeCandidates:=NewOperationArgs("DxDegreeCandidates");

#############################################################################
##
#A  DixonRecord(<G>)
##
DixonRecord := NewAttribute("DixonRecord",IsGroup,"mutable");

#############################################################################
##
#M  DxPreparation(<G>)
##
DxPreparation := NewOperation("DxPreparation",[IsGroup,IsRecord]);

#############################################################################
##
#F  ClassComparison(<c>,<d>)  . . . . . . . . . . . . compare classes c and d
##
ClassComparison := NewOperationArgs( "ClassComparison ");

#############################################################################
##
#F  RootsOfPol(<pol>) . . . . . . . . . . . . . . . . . roots of a polynomial
##
RootsOfPol := NewOperationArgs("RootsOfPol");

#############################################################################
##
#F  DxIncludeIrreducibles(<D>,<new>,[<newmod>]) . . . . handle (newly?) found
#F                                                               irreducibles
##
DxIncludeIrreducibles := NewOperationArgs("DxIncludeIrreducibles");

#############################################################################
##
#F  SplitCharacters(<D>,<list>)   split characters according to the spaces
#F   this function can be applied to ordinary characters. It splits them
#F   according to the character spaces yet known. This can be used
#F   interactively to utilize partially computed spaces
##
SplitCharacters := NewOperationArgs("SplitCharacters");

#############################################################################
##
#F  OrbitSplit(<D>) . . . . . . . . . . . . . . try to split two-orbit-spaces
##
OrbitSplit := NewOperationArgs("OrbitSplit");

#############################################################################
##
#F  SplitDegree(<D>,<space>,<r>)  estimate number of parts when splitting
##                space with matrix number r,according to charactermorphisms
##
SplitDegree := NewOperationArgs("SplitDegree");

#############################################################################
##
#F  BestSplittingMatrix(<D>) . number of the matrix,that will yield the best
#F                                                                      split
##
BestSplittingMatrix := NewOperationArgs("BestSplittingMatrix");

#############################################################################
##
#F  DixonInit(<G>) . . . . . . . . . . initialize Dixon-Schneider algorithm
##
##
DixonInit := NewOperationArgs("DixonInit");

#############################################################################
##
#F  DixonSplit(<D>) . .  calculate matrix,split spaces and obtain characters
##
DixonSplit := NewOperationArgs("DixonSplit");

#############################################################################
##
#F  DixontinI(<D>)  . . . . . . . . . . . . . . . .  reverse initialisation
##
DixontinI := NewOperationArgs("DixontinI");

#############################################################################
##
#F  IrrDixonSchneider(<G>) . . . . .  character table of finite group G
##
##  Compute the table of the irreducible characters of G,using the
##  Dixon/Schneider method.
##
IrrDixonSchneider := NewOperationArgs("IrrDixonSchneider");

#############################################################################
##
#E  ctblgrp.gd
##
