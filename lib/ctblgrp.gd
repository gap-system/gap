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

InfoCharTable:=NewInfoClass("InfoCharTable");
SetInfoLevel(InfoCharTable,3);

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
#E  ctblgrp.gd
##
