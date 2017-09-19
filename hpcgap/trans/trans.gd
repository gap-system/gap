#############################################################################
##
#W  trans.gd          GAP transitive groups library          Alexander Hulpke
##
##
#Y  Copyright (C) 2001, Alexander Hulpke, Colorado State University
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
##
##  This file contains the declarations for the transitive groups library
##

# ensure that the dummy binds from the library are killed
MakeReadWriteGlobal("TransitiveGroupsAvailable");
Unbind(TransitiveGroupsAvailable);
MakeReadWriteGlobal("NrTransitiveGroups");
Unbind(NrTransitiveGroups);
MakeReadWriteGlobal("TransitiveGroup");
Unbind(TransitiveGroup);
MakeReadWriteGlobal("TRANSProperties");
Unbind(TRANSProperties);

#############################################################################
##
#F  TransitiveGroup(<deg>,<nr>)
##
##  <#GAPDoc Label="TransitiveGroup">
##  <ManSection>
##  <Func Name="TransitiveGroup" Arg='deg,nr'/>
##
##  <Description>
##  returns the <A>nr</A>-th transitive  group of degree <A>deg</A>.  Both  <A>deg</A> and
##  <A>nr</A> must be  positive integers. The transitive groups of equal  degree
##  are  sorted with  respect to   their  size, so for  example
##  <C>TransitiveGroup(  <A>deg</A>, 1 )</C> is a  transitive group  of degree and
##  size <A>deg</A>, e.g, the cyclic  group  of size <A>deg</A>,   if <A>deg</A> is a
##  prime.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("TransitiveGroup");

DeclareGlobalFunction("TransitiveGroupsAvailable");

#############################################################################
##
#F  NrTransitiveGroups(<deg>)
##
##  <#GAPDoc Label="NrTransitiveGroups">
##  <ManSection>
##  <Func Name="NrTransitiveGroups" Arg='deg'/>
##
##  <Description>
##  returns the number of transitive groups of degree <A>deg</A> stored in
##  the library of transitive groups.
##  The function returns <K>fail</K> if <A>deg</A> is
##  beyond the range of the library.
##  <P/>
##  <Example><![CDATA[
##  gap> TransitiveGroup(10,22);
##  S(5)[x]2
##  gap> l:=AllTransitiveGroups(NrMovedPoints,12,Size,1440,IsSolvable,false);
##  [ S(6)[x]2, M_10.2(12)=A_6.E_4(12)=[S_6[1/720]{M_10}S_6]2 ]
##  gap> List(l,IsSolvable);
##  [ false, false ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NrTransitiveGroups");

DeclareGlobalVariable( "TRANSCOMBCACHE", "combinations cache" );
DeclareGlobalVariable( "TRANSARRCACHE", "arrangements cache" );

BindGlobal("TRANSREGION", NewLibraryRegion("transitive groups region"));

#############################################################################
##
#E

