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
DeclareProperty( "IsNaturalAlternatingGroup", IsPermGroup );


#############################################################################
##
#P  IsAlternatingGroup( <group> )
##
##  Such a group is a group isomorphic to a natural alternating group.
##
DeclareProperty( "IsAlternatingGroup", IsGroup );


#############################################################################
##
#M  IsAlternatingGroup( <nat-alt-grp> )
##
InstallTrueMethod( IsAlternatingGroup, IsNaturalAlternatingGroup );


#############################################################################
##
#P  IsNaturalSymmetricGroup( <group> )
##
##  A group is a natural symmetric group if it is  a permutation group acting
##  as symmetric group on its moved points.
##
DeclareProperty( "IsNaturalSymmetricGroup", IsPermGroup );


#############################################################################
##
#P  IsSymmetricGroup( <group> )
##
##  is `true' if the group <group> is isomorphic to a natural symmetric group.
##
DeclareProperty( "IsSymmetricGroup", IsGroup );


#############################################################################
##
#M  IsSymmetricGroup( <nat-sym-grp> )
##
InstallTrueMethod( IsSymmetricGroup, IsNaturalSymmetricGroup );


#############################################################################
##
#A  SymmetricParentGroup( <grp> )
##
##  For a permutation group <grp> this function returns the symmetric group
##  that moves the same points as <grp> does.
##
DeclareAttribute("SymmetricParentGroup",IsPermGroup);

#############################################################################
##
#A  OrbitStabilizingParentGroup( <grp> )
##
##  returns the subgroup of `SymmetricParentGroup(<grp>)' which stabilizes
##  the orbits of <grp> setwise. (So it is a direct product of wreath
##  products of symmetric groups.) It is a natural supergroup for the
##  normalizer.
##
DeclareAttribute("OrbitStabilizingParentGroup",IsPermGroup);


#############################################################################
##
#E

