#############################################################################
##
#W  type.gd                     GAP library
##
##
#Y  Copyright (C) 2016 The GAP Group
##
##  This file declares some additional functionality relating to types and
##  families.
##

#############################################################################
##
#O  FiltersType( <type> )
#O  FiltersObj( <type> )
##
##  list of filters of a type
##
##  <#GAPDoc Label="FiltersType">
##  <ManSection>
##  <Oper Name="FiltersType" Arg='type'/>
##  <Oper Name="FiltersObj" Arg='object'/>
##
##  <Description>
##  returns a list of the filters in the type <A>type</A>, or in the
##  type of the object <A>object</A> respectively.
##  <Example><![CDATA[
##  gap> FiltersObj(fail);
##  [ <Category "IsBool">, <Representation "IsInternalRep"> ]
##  gap> FiltersType(TypeOfTypes);
##  [ <Representation "IsPositionalObjectRep">, <Category "IsType">, <Representation "IsTypeDefaultRep"> ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "FiltersType", [ IsType ] );
DeclareOperation( "FiltersObj", [ IsObject ] );
