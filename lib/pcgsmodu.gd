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

#O  ModuloPcgsByPcSequenceNC( <home>, <pcs>, <modulo> )
##
ModuloPcgsByPcSequenceNC := NewOperation(
    "ModuloPcgsByPcSequenceNC",
    [ IsPcgs, IsList, IsPcgs ] );


#############################################################################
##
#O  ModuloPcgsByPcSequence( <home>, <pcs>, <modulo> )
##
ModuloPcgsByPcSequence := NewOperation(
    "ModuloPcgsByPcSequence",
    [ IsPcgs, IsList, IsPcgs ] );


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

#E  pcgsmodu.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
