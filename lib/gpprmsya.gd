#############################################################################
##
#W  gpprmsya.gd                   GAP Library                    Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
IsNaturalAlternatingGroup := NewProperty(
    "IsNaturalAlternatingGroup",
    IsPermGroup );

SetIsNaturalAlternatingGroup := Setter(IsNaturalAlternatingGroup);
HasIsNaturalAlternatingGroup := Tester(IsNaturalAlternatingGroup);


#############################################################################
##
#P  IsAlternatingGroup( <group> )
##
##  Such a group is a group isomorphic to a natural alterning group.
##
IsAlternatingGroup := NewProperty(
    "IsAlternatingGroup",
    IsGroup );

SetIsAlternatingGroup := Setter(IsAlternatingGroup);
HasIsAlternatingGroup := Tester(IsAlternatingGroup);


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
IsNaturalSymmetricGroup := NewProperty(
    "IsNaturalSymmetricGroup",
    IsPermGroup );

SetIsNaturalSymmetricGroup := Setter(IsNaturalSymmetricGroup);
HasIsNaturalSymmetricGroup := Tester(IsNaturalSymmetricGroup);


#############################################################################
##
#P  IsSymmetricGroup( <group> )
##
##  Such a group is a group isomorphic to a natural symmetric group.
##
IsSymmetricGroup := NewProperty(
    "IsSymmetricGroup",
    IsGroup );

SetIsSymmetricGroup := Setter(IsSymmetricGroup);
HasIsSymmetricGroup := Tester(IsSymmetricGroup);


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
