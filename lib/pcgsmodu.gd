#############################################################################
##
#W  pcgsmodu.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for polycylic generating systems modulo
##  another such system.
##
Revision.pcgsmodu_gd :=
    "@(#)$Id$";


#############################################################################
##
#O  ModuloPcgsByPcSequenceNC( <home>, <pcs>, <modulo> )
##
DeclareOperation(
    "ModuloPcgsByPcSequenceNC",
    [ IsPcgs, IsList, IsPcgs ] );


#############################################################################
##
#O  ModuloPcgsByPcSequence( <home>, <pcs>, <modulo> )
##
DeclareOperation(
    "ModuloPcgsByPcSequence",
    [ IsPcgs, IsList, IsPcgs ] );

#############################################################################
##
#O  ModuloPcgs( <G>, <N> )
##
##  returns a pcgs for <G> modulo <N> (in elements of <G>).
##  <N> must be a normal subgroup of <G> but not necessarily solvable.
##  If $<G>/<N>$ is not solvable, it returns `fail'.
DeclareOperation( "ModuloPcgs", [ IsGroup, IsGroup ] );


#############################################################################
##
#A  ModuloParentPcgs( <pcgs> )
##
DeclareAttribute(
    "ModuloParentPcgs",
    IsPcgs );



#############################################################################
##
#A  DenominatorOfModuloPcgs( <pcgs> )
##
##  returns a generating set for the denominator of the modulo pcgs <pcgs>. If
##  <pcgs> was created using the `mod' operator it returns the pcgs modulo
##  which <pcgs> was taken.
DeclareAttribute( "DenominatorOfModuloPcgs", IsModuloPcgs );



#############################################################################
##
#A  NumeratorOfModuloPcgs( <pcgs> )
##
##  returns a generating set for the numerator of the modulo pcgs <pcgs>. If
##  <pcgs> was created using the `mod' operator it returns the pcgs which
##  was taken modulo.
DeclareAttribute( "NumeratorOfModuloPcgs", IsModuloPcgs );


#############################################################################
##
#E  pcgsmodu.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
