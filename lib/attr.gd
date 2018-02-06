#############################################################################
##
#W  attr.gd                     GAP library                      Steve Linton
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group


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
##  This info class (together with <Ref InfoClass="InfoWarning"/> is used
##  for messages about attribute storing  being  disabled  (at  level  2)  or
##  enabled (level 3). It may be  used  in  the  future  for  other  messages
##  concerning changes to attribute behaviour.
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

