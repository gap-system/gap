#############################################################################
##
#W  gpprmsya.gd                   GAP Library                    Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for symmetric and alternating
##  permutation groups
##
Revision.gpprmsya_gd :=
    "@(#)$Id$";


#############################################################################
##
#P  IsNaturalAlternatingGroup( <group> )
##
##  A   group is a  natural  alternating group if  it is  a permutation group
##  acting as alternating group on its moved points.
##
DeclareProperty(
    "IsNaturalAlternatingGroup",
    IsPermGroup );



#############################################################################
##
#P  IsAlternatingGroup( <group> )
##
##  Such a group is a group isomorphic to a natural alterning group.
##
DeclareProperty(
    "IsAlternatingGroup",
    IsGroup );



#############################################################################
##
#M  IsAlternatingGroup( <nat-alt-grp> )
##
InstallTrueMethod(
    IsAlternatingGroup,
    IsNaturalAlternatingGroup );


#############################################################################
##
#P  IsNaturalSymmetricGroup( <group> )
##
##  A group is a natural symmetric group if it is  a permutation group acting
##  as symmetric group on its moved points.
##
DeclareProperty(
    "IsNaturalSymmetricGroup",
    IsPermGroup );



#############################################################################
##
#P  IsSymmetricGroup( <group> )
##
##  Such a group is a group isomorphic to a natural symmetric group.
##
DeclareProperty(
    "IsSymmetricGroup",
    IsGroup );



#############################################################################
##
#M  IsSymmetricGroup( <nat-sym-grp> )
##
InstallTrueMethod(
    IsSymmetricGroup,
    IsNaturalSymmetricGroup );


#############################################################################
##
#E  gpprmsya.gd  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
