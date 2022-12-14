#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later


#############################################################################
##
##  <#GAPDoc Label="[1]{attr}">
##  The normal behaviour of attributes (when called with just one argument)
##  is that once a method has been selected and executed, and has returned a
##  value the setter of the attribute is called, to (possibly) store the
##  computed value. In special circumstances, this behaviour can be altered
##  dynamically on an attribute-by-attribute basis, using the functions
##  <Ref Func="DisableAttributeValueStoring"/> and
##  <Ref Func="EnableAttributeValueStoring"/>.
##  <P/>
##  In general, the code in the library assumes, for efficiency, but not for
##  correctness, that attribute values <E>will</E> be stored (in suitable
##  objects), so disabling storing may cause substantial computations to be
##  repeated.
##  <#/GAPDoc>
##

#############################################################################
##
#V  InfoAttributes . . . info class for reporting on attribute tweaking
##
##  <#GAPDoc Label="InfoAttributes">
##  <ManSection>
##  <InfoClass Name="InfoAttributes"/>
##
##  <Description>
##  This info class (together with <Ref InfoClass="InfoWarning"/>) is used
##  for messages about attributes. Messages are shown under the following circumstances:
##  <List>
##    <Item> <Ref Func="EnableAttributeValueStoring"/> is used (level 2).</Item>
##    <Item> <Ref Func="DisableAttributeValueStoring"/> is used (level 3).</Item>
##    <Item> When trying to assign to non-mutable attribute which already is set to a different value (level 3).</Item>
##    <Item> When the test filter for an attribute (i.e., <C>HasFOO</C>) is set, but no value is assigned (level 3).</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass("InfoAttributes");


#############################################################################
##
#F  EnableAttributeValueStoring( <attr> ) tell attr. to resume storing values
##
##  <#GAPDoc Label="EnableAttributeValueStoring">
##  <ManSection>
##  <Func Name="EnableAttributeValueStoring" Arg='attr'/>
##
##  <Description>
##  enables the usual call of <C>Setter( <A>attr</A> )</C> when  a  method  for  <A>attr</A>
##  returns a value. In consequence the  values  may  be  stored.  This  will
##  usually have no effect unless
##  <Ref Func="DisableAttributeValueStoring"/> has
##  previously been used for <A>attr</A>. Note that <A>attr</A> must  be  an  attribute
##  and <E>not</E> a property.
##  <Example><![CDATA[
##  gap> g := Group((1,2,3,4,5),(1,2,3));
##  Group([ (1,2,3,4,5), (1,2,3) ])
##  gap> KnownAttributesOfObject(g);
##  [ "LargestMovedPoint", "GeneratorsOfMagmaWithInverses",
##    "MultiplicativeNeutralElement" ]
##  gap> SetInfoLevel(InfoAttributes,3);
##  gap> DisableAttributeValueStoring(Size);
##  #I  Disabling value storing for Size
##  gap> Size(g);
##  60
##  gap> KnownAttributesOfObject(g);
##  [ "OneImmutable", "LargestMovedPoint", "NrMovedPoints",
##    "MovedPoints", "GeneratorsOfMagmaWithInverses",
##    "MultiplicativeNeutralElement", "StabChainMutable",
##    "StabChainOptions" ]
##  gap> Size(g);
##  60
##  gap> EnableAttributeValueStoring(Size);
##  #I  Enabling value storing for Size
##  gap> Size(g);
##  60
##  gap> KnownAttributesOfObject(g);
##  [ "Size", "OneImmutable", "LargestMovedPoint", "NrMovedPoints",
##    "MovedPoints", "GeneratorsOfMagmaWithInverses",
##    "MultiplicativeNeutralElement", "StabChainMutable",
##    "StabChainOptions" ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("EnableAttributeValueStoring");

#############################################################################
##
#F  DisableAttributeValueStoring( <attr> ) tell attr. to stop storing values
##
##  <#GAPDoc Label="DisableAttributeValueStoring">
##  <ManSection>
##  <Func Name="DisableAttributeValueStoring" Arg='attr'/>
##
##  <Description>
##  disables the usual call of <C>Setter( <A>attr</A> )</C> when a  method  for  <A>attr</A>
##  returns a value. In consequence the values will  never  be  stored.  Note
##  that <A>attr</A> must be an attribute and <E>not</E> a property.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DisableAttributeValueStoring");

