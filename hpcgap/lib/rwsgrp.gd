#############################################################################
##
#W  rwsgrp.gd                   GAP Library                      Frank Celler
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This   file contains  the operations  for  groups   defined by  rewriting
##  systems.
##
##  `GroupByRws' tries   to convert a  rewriting system  into  a  group.  The
##  generic  method requires that  the    underlying structure is a    group.
##  Rewriting  system constructors should   set the rewriting system  feature
##  `IsBuiltFromGroup' in this case.
##


#############################################################################
##
#C  IsElementsFamilyByRws .  category of elements family constructed with RWS
##
DeclareCategory(
    "IsElementsFamilyByRws",
    IsFamily );


#############################################################################
##
#O  MultiplicativeElementsWithInversesFamilyByRws( <rws> )  . . . this family
##
##  <ManSection>
##  <Oper Name="MultiplicativeElementsWithInversesFamilyByRws" Arg='rws'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "MultiplicativeElementsWithInversesFamilyByRws",
    [ IsRewritingSystem ] );


#############################################################################
##
#C  IsMultiplicativeElementWithInverseByRws . . .  category of these elements
##
DeclareCategory(
    "IsMultiplicativeElementWithInverseByRws",
    IsMultiplicativeElementWithInverse );


#############################################################################
##
#O  ElementByRws( <fam>, <elm> )  . . . . . . . . . construct such an element
##
##  <ManSection>
##  <Oper Name="ElementByRws" Arg='fam, elm'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "ElementByRws",
    [ IsElementsFamilyByRws, IsObject ] );


#############################################################################
##
#O  GroupByRws( <rws> ) . . . . . . . . . . . .  construct a group from a RWS
##
##  <ManSection>
##  <Oper Name="GroupByRws" Arg='rws'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "GroupByRws",
    [ IsRewritingSystem ] );


#############################################################################
##
#O  GroupByRwsNC( <rws> ) . . . . . . . . . . .  construct a group from a RWS
##
##  <ManSection>
##  <Oper Name="GroupByRwsNC" Arg='rws'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "GroupByRwsNC",
    [ IsRewritingSystem ] );


#############################################################################
##
#E

