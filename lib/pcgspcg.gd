#############################################################################
##
#W  pcgspcg.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations  for polycylic generating systems of pc
##  groups.
##
Revision.pcgspcg_gd :=
    "@(#)$Id$";


#############################################################################
##

#P  IsFamilyPcgs( <pcgs> )
##
IsFamilyPcgs := NewProperty(
    "IsFamilyPcgs",
    IsPcgs );

SetIsFamilyPcgs := Setter(IsFamilyPcgs);
HasIsFamilyPcgs := Tester(IsFamilyPcgs);




#############################################################################
##

#E  pcgspcg.gd	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
