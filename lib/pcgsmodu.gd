#############################################################################
##
#W  pcgsmodu.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for polycylic generating systems modulo
##  another such system.
##
Revision.pcgsmodu_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsModuloPcgs
##
IsModuloPcgs := NewCategory(
    "IsModuloPcgs",
    IsHomogeneousList and IsDuplicateFreeList 
    and IsMultiplicativeElementWithInverseCollection );


#############################################################################
##

#A  DenominatorOfModuloPcgs( <pcgs> )
##
DenominatorOfModuloPcgs := NewAttribute(
    "DenominatorOfModuloPcgs",
    IsModuloPcgs );

SetDenominatorOfModuloPcgs := Setter(DenominatorOfModuloPcgs);
HasDenominatorOfModuloPcgs := Tester(DenominatorOfModuloPcgs);


#############################################################################
##
#A  NumeratorOfModuloPcgs( <pcgs> )
##
NumeratorOfModuloPcgs := NewAttribute(
    "NumeratorOfModuloPcgs",
    IsModuloPcgs );

SetNumeratorOfModuloPcgs := Setter(NumeratorOfModuloPcgs);
HasNumeratorOfModuloPcgs := Tester(NumeratorOfModuloPcgs);


#############################################################################
##
#A  ModuloParentPcgs( <pcgs> )
##
ModuloParentPcgs := NewAttribute(
    "ModuloParentPcgs",
    IsPcgs );

SetModuloParentPcgs := Setter(ModuloParentPcgs);
HasModuloParentPcgs := Tester(ModuloParentPcgs);


#############################################################################
##

#E  pcgsmodu.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
