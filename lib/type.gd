#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
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
#F  TypeOfOperation( <op> )
##
##  Determine the class of the operation <A>op</A>.
##
##  <#GAPDoc Label="TypeOfOperation">
##  <ManSection>
##  <Func Name="TypeOfOperation" Arg='object'/>
##
##  <Description>
##  returns a string from the list <C>[ "Attribute", "Operation", "Property",
##  "Category", "Representation", "Filter", "Setter"]</C> reflecting which
##  type of operation <A>op</A> is.
##  <P/>
##  (see&nbsp;<Ref Sect="Categories"/>, <Ref Sect="Representation"/>,
##  <Ref Sect="Attributes"/>, <Ref Sect="Setter and Tester for Attributes"/>,
##  <Ref Sect="Properties"/>, <Ref Sect="Other Filters"/>)
##
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "TypeOfOperation" );


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
##  returns <K>true</K> if <A>object</A> is a category
##  (see&nbsp;<Ref Sect="Categories"/>), and <K>false</K> otherwise.
##  <P/>
##  Note that &GAP; categories are <E>not</E> categories in the usual mathematical
##  sense.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IsCategory" );

#############################################################################
##
#F  IsRepresentation( <object> )
##
##  Determine whether the passed object is a representation.
##
##  <#GAPDoc Label="IsRepresentation">
##  <ManSection>
##  <Func Name="IsRepresentation" Arg='object'/>
##
##  <Description>
##  returns <K>true</K> if <A>object</A> is a representation
##  (see&nbsp;<Ref Sect="Representation"/>), and <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "IsRepresentation" );


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
##  returns <K>true</K> if <A>object</A> is an attribute
##  (see&nbsp;<Ref Sect="Attributes"/>), and <K>false</K> otherwise.
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
##  returns <K>true</K> if <A>object</A> is a property
##  (see&nbsp;<Ref Sect="Properties"/>), and <K>false</K> otherwise.
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

