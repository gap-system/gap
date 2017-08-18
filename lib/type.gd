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

#############################################################################
##
#F  IsCategory( <object> )
##
##  Determine whether the passed object is a category.
##
##  <#GAPDoc Label="IsCategory">
##  <ManSection>
##  <Func Name="IsCategory" Arg='object'/>
##
##  <Description>
##  returns <C>true</C> if <A>object</A> is a category, and <C>false</C> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IsCategory" );


#############################################################################
##
#F  IsAttribute( <object> )
##
##  Determine whether the passed object is an attribute.
##
##  <#GAPDoc Label="IsAttribute">
##  <ManSection>
##  <Func Name="IsAttribute" Arg='object'/>
##
##  <Description>
##  returns <C>true</C> if <A>object</A> is an attribute, and <C>false</C> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IsAttribute" );


#############################################################################
##
#F  IsProperty( <object> )
##
##  Determine whether the passed object is a property.
##
##  <#GAPDoc Label="IsProperty">
##  <ManSection>
##  <Func Name="IsProperty" Arg='object'/>
##
##  <Description>
##  returns <C>true</C> if <A>object</A> is a property, and <C>false</C> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IsProperty" );


#############################################################################
##
#F  CategoryByName( <name> )
##
##  Find a category given its name.
##
##  <#GAPDoc Label="CategoryByName">
##  <ManSection>
##  <Func Name="CategoryByName" Arg='name'/>
##
##  <Description>
##  returns the category with name <A>name</A> if it is found, or fail otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "CategoryByName" );


#############################################################################
##
#F  LocationOfDeclaration( <object> )
##
##  Find the location of the declaration of <object>.
##
##  <#GAPDoc Label="LocationOfDeclaration">
##  <ManSection>
##  <Func Name="LocationofDeclaration" Arg='object'/>
##
##  <Description>
##  returns the location of the declaration of <A>object</A> if it is known.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "LocationOfDeclaration" );
