#############################################################################
##
#W  perf.gd               GAP Groups Library                 Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations for the Holt/Plesken library of
##  perfect groups
##
Revision.perf_gd :=
    "@(#)$Id$";

PERFRec:=fail; # indicator that perf0.grp is not loaded
PERFSELECT:=[];
PERFGRP:=[];

#############################################################################
##
#C  IsPerfectLibraryGroup(<G>)  identifier for groups constructed from the
##                              library (used for perm->fp isomorphism)
##
IsPerfectLibraryGroup := NewCategory("IsPerfectLibraryGroup", IsGroup );

#############################################################################
##
#O  PerfGrpConst(<filter>,<descriptor>) 
##
PerfGrpConst := NewConstructor("PerfGrpConst",[IsGroup,IsList]);


#############################################################################
##
#O  PerfGrpLoad(<size>)  force loading of secondary files, return index
##
PerfGrpLoad := NewOperationArgs("PerfGrpLoad");


#############################################################################
##
#A  PerfectIdentification(<G>) . . . . . . . . . . . . id. for perfect groups
##
PerfectIdentification := NewAttribute("PerfectIdentification", IsGroup );
SetPerfectIdentification := Setter(PerfectIdentification);
HasPerfectIdentification := Tester(PerfectIdentification);


#############################################################################
##
#O  SizesPerfectGroups( ) . . . . . . . . . . . . . . . . . . . . . . . . . .
##
SizesPerfectGroups := NewOperationArgs("SizesPerfectGroups");


#############################################################################
##
#O  NumberPerfectGroups( size ) . . . . . . . . . . . . . . . . . . . . . . .
##
NumberPerfectGroups := NewOperationArgs("NumberPerfectGroups");


#############################################################################
##
#O  NumberPerfectLibraryGroups( size )  . . . . . . . . . . . . . . . . . . .
##
NumberPerfectLibraryGroups :=
  NewOperationArgs("NumberPerfectLibraryGroups");


#############################################################################
##
#O  PerfectGroup([<filter>,]<sz>,<nr>)   Access perfect groups library
##
PerfectGroup := NewOperationArgs("PerfectGroup");


#########################################################################
##
#F  DisplayInformationPerfectGroups( <size> ) . . . . . . . . . . . . . . . .
#F  DisplayInformationPerfectGroups( <size>, <n> )  . . . . . . . . . . . . .
#F  DisplayInformationPerfectGroups( [ <size>, <n> ] )  . . . . . . . . . . .
##
##  'DisplayInformationPerfectGroups'  displays  some invariants  of the n-th
##  group of size size from the perfect groups library.
##
##  If no value of n has been specified, the invariants will be displayed for
##  all groups of size size available in the library.
##
DisplayInformationPerfectGroups :=
  NewOperationArgs("DisplayInformationPerfectGroups");


#############################################################################
##
#F  SizeNumbersPerfectGroups( <factor>, ..., <factor> ) . . . . . . . . . . .
##
SizeNumbersPerfectGroups := NewOperationArgs("SizeNumbersPerfectGroups");


#############################################################################
##
#E  perf.gd . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
