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

#C  IsElementsFamilyByRws
##
IsElementsFamilyByRws := NewCategory(
    "IsElementsFamilyByRws",
    IsFamily );


#############################################################################
##
#O  MultiplicativeElementsWithInversesFamilyByRws( <rws> )
##
MultiplicativeElementsWithInversesFamilyByRws := NewOperation(
    "MultiplicativeElementsWithInversesFamilyByRws",
    [ IsRewritingSystem ] );


#############################################################################
##


#C  IsMultiplicativeElementWithInverseByRws
##
IsMultiplicativeElementWithInverseByRws := NewCategory(
    "IsMultiplicativeElementWithInverseByRws",
    IsMultiplicativeElementWithInverse );


#############################################################################
##
#O  ElementByRws( <fam>, <elm> )
##
ElementByRws := NewOperation(
    "ElementByRws",
    [ IsElementsFamilyByRws, IsObject ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  UnderlyingElement( <elm> )
##
UnderlyingElement := NewOperation(
    "UnderlyingElement",
    [ IsObject ] );


#############################################################################
##

#O  GroupByRws( <rws> )
##
GroupByRws := NewOperation(
    "GroupByRws",
    [ IsRewritingSystem ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  GroupByRwsNC( <rws> )
##
GroupByRwsNC := NewOperation(
    "GroupByRwsNC",
    [ IsRewritingSystem ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##

#F  InstallGroupByRwsMethod( <rws-prop>, <grp-prop>, <func> )
##
GROUPBYRWS_METHODS := [];

InstallGroupByRwsMethod := function( rws, grp, func )
    Add( GROUPBYRWS_METHODS, [FLAGS_FILTER(rws),FLAGS_FILTER(grp),func] );
end;

RunGroupByRwsMethods := RunMethodsFunction2(GROUPBYRWS_METHODS);


#############################################################################
##

#M  IsFinite
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
