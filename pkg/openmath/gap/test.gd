#######################################################################
##
#W  test.gd          GAP OpenMath Package                Andrew Solomon
#W                                                     Marco Costantini
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  testing function
##


#######################################################################
##
#F  OMTestXML( <obj> )
##
##  <#GAPDoc Label="OMTestXML">
##  <ManSection>
##  <Func Name="OMTestXML" Arg="obj" />
##  <Func Name="OMTest"    Arg="obj" />
##  <Description>
##  Converts <A>obj</A> to XML &OpenMath; and back. Returns true if and 
##  only if <A>obj</A> is unchanged (as a &GAP; object) by this operation. 
##  The &OpenMath; standard does not stipulate that converting to and from 
##  &OpenMath; should be the identity function so this is a useful 
##  diagnostic tool. 
##  <Example>
##  <![CDATA[
##  gap> OMTestXML([[1..10],[1/2,2+E(4)],ZmodnZObj(2,6),(1,2),true,"string"]);     
##  true
##  ]]>
##  </Example>
##  <Ref Func="OMTest"/> is a synonym to <Ref Func="OMTestXML"/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OMTestXML");
DeclareSynonym( "OMTest", OMTestXML );


#######################################################################
##
#F  OMTestBinary( <obj> )
##
##  Similar to OMTestXML, but uses binary OpenMath representation.
##
##  <#GAPDoc Label="OMTestBinary">
##  <ManSection>
##  <Func Name="OMTestBinary" Arg="obj" />
##  <Description>
##  Converts <A>obj</A> to binary &OpenMath; and back. Returns true if and 
##  only if <A>obj</A> is unchanged (as a &GAP; object) by this operation. 
##  The &OpenMath; standard does not stipulate that converting to and from 
##  &OpenMath; should be the identity function so this is a useful 
##  diagnostic tool. 
##  <Example>
##  <![CDATA[
##  gap> OMTestBinary([[1..10],[1/2,2+E(4)],ZmodnZObj(2,6),(1,2),true,"string"]);     
##  true
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("OMTestBinary");


#############################################################################
#E
