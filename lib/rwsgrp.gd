#############################################################################
##
#W  rwsgrp.gd                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This   file contains  the operations  for  groups   defined by  rewriting
##  systems.
##
##  'GroupByRws' tries   to convert a  rewriting system  into  a  group.  The
##  generic  method requires that  the    underlying structure is a    group.
##  Rewriting  system constructors should   set the rewriting system  feature
##  'IsBuiltFromGroup' in this case.
##
Revision.rwsgrp_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsElementsFamilyByRws .  category of elements family constructed with RWS
##
IsElementsFamilyByRws := NewCategory(
    "IsElementsFamilyByRws",
    IsFamily );


#############################################################################
##
#O  MultiplicativeElementsWithInversesFamilyByRws( <rws> )  . . . this family
##
MultiplicativeElementsWithInversesFamilyByRws := NewOperation(
    "MultiplicativeElementsWithInversesFamilyByRws",
    [ IsRewritingSystem ] );


#############################################################################
##


#C  IsMultiplicativeElementWithInverseByRws . . .  category of these elements
##
IsMultiplicativeElementWithInverseByRws := NewCategory(
    "IsMultiplicativeElementWithInverseByRws",
    IsMultiplicativeElementWithInverse );


#############################################################################
##
#O  ElementByRws( <fam>, <elm> )  . . . . . . . . . construct such an element
##
ElementByRws := NewOperation(
    "ElementByRws",
    [ IsElementsFamilyByRws, IsObject ] );


#############################################################################
##
#O  UnderlyingElement( <elm> )
##
UnderlyingElement := NewOperation(
    "UnderlyingElement",
    [ IsObject ] );


#############################################################################
##

#F  InstallGroupByRwsMethod( <rws>, <grp>, <func> ) . . . transfer properties
##
GROUPBYRWS_METHODS      := [];
InstallGroupByRwsMethod := InstallMethodsFunction2(GROUPBYRWS_METHODS);
RunGroupByRwsMethods    := RunMethodsFunction2(GROUPBYRWS_METHODS);


#############################################################################
##

#O  GroupByRws( <rws> ) . . . . . . . . . . . .  construct a group from a RWS
##
GroupByRws := NewOperation(
    "GroupByRws",
    [ IsRewritingSystem ] );


#############################################################################
##
#O  GroupByRwsNC( <rws> ) . . . . . . . . . . .  construct a group from a RWS
##
GroupByRwsNC := NewOperation(
    "GroupByRwsNC",
    [ IsRewritingSystem ] );


#############################################################################
##
#M  IsFinite  . . . . . . . . . . . . . .  a finite RWS yields a finite group
##
InstallGroupByRwsMethod(
    IsFinite,
    IsObject,

function( rws, grp )
    SetIsFinite( grp, true );
end );


#############################################################################
##

#E  rwsgrp.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
