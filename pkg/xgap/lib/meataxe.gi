#############################################################################
##
#W  meataxe.gi                 	XGAP library                  Max Neunhoeffer
##
#H  @(#)$Id: meataxe.gi,v 1.3 1999/05/26 16:59:22 gap Exp $
##
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##  This file contains code for MeatAxe posets
##
Revision.pkg_xgap_lib_meataxe_gi :=
    "@(#)$Id: meataxe.gi,v 1.3 1999/05/26 16:59:22 gap Exp $";


#############################################################################
##
#M  GraphicMeatAxeLattice(<name>, <width>, <height>)  . creates graphic poset
##
##  creates a new graphic MeatAxe lattice which is a specialization of a
##  graphic poset. Those posets have a new filter for method selection.
##
InstallMethod( GraphicMeatAxeLattice,
    "for a string, and two integers",
    true,
    [ IsString,
      IsInt,
      IsInt ],
    0,

function( name, width, height )
  local P;

  P := GraphicPoset(name,width,height);
  SetFilterObj(P,IsMeatAxeLattice);
  return P;
end);


#############################################################################
##
#M  CompareLevels(<poset>,<levelparam1>,<levelparam2>)  . . . . . . . . . . . 
##  . . . . . . . . . . . . . . . . . . . . . . . .  compares two levelparams
##
##  Compare two level parameters. -1 means that <levelparam1> is "higher", 
##  1 means that <levelparam2> is "higher", 0 means that they are equal. 
##  fail means that they are not comparable. This method is for the case 
##  if level parameters are integers and lower values mean lower levels 
##  like in the case of MeatAxe lattices of Michael Ringe.
##
InstallMethod( CompareLevels,
    "for a graphic MeatAxe lattice, and two integers",
    true,
    [ IsGraphicPosetRep and IsMeatAxeLattice, IsInt, IsInt ],
    1,   # to make it better than the ilatgrp-Method!

function( poset, l1, l2 )
  if l1 < l2 then
    return 1;
  elif l1 > l2 then
    return -1;
  else
    return 0;
  fi;
end);

