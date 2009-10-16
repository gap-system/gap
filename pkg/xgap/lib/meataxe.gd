#############################################################################
##
#W  meataxe.gd                 	XGAP library                  Max Neunhoeffer
##
#H  @(#)$Id: meataxe.gd,v 1.1 1998/12/18 17:02:15 gap Exp $
##
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##  This file contains declarations for meataxe posets
##
Revision.pkg_xgap_lib_meataxe_gd :=
    "@(#)$Id: meataxe.gd,v 1.1 1998/12/18 17:02:15 gap Exp $";


## a new filter:

DeclareFilter("IsMeatAxeLattice");

#############################################################################
##
##  Constructors:
##
#############################################################################

#############################################################################
##
#O  GraphicMeatAxeLattice(<name>, <width>, <height>)  . creates graphic poset
##
##  creates a new graphic meataxe lattice which is a specialization of a
##  graphic poset. Those posets have a new filter for method selection.
##
if IsBound(GraphicMeatAxeLattice) then if not IsOperation(GraphicMeatAxeLattice) then
  Error("Identifier GraphicMeatAxeLattice already in use!"); fi;
else
  DeclareOperation("GraphicMeatAxeLattice",[IsString, IsInt, IsInt]);
fi;


