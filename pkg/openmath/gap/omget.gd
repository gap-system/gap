#############################################################################
##
#W  omget.gd           OpenMath Package         Andrew Solomon
#W                                                     Marco Costantini
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  Reads an OpenMath object from an input stream and returns
##  a GAP object.
##


#############################################################################
##
#F  OMGetObject( <stream> )
##
##  <#GAPDoc Label="OMGetObject">
##  <ManSection>
##      <Func Name="OMGetObject" Arg="stream" />
##  <Description>
##  <A>stream</A> is an input stream (see 
##  <Ref BookName="ref" Oper="InputTextFile" />, 
##  <Ref BookName="ref" Oper="InputTextUser" />, 
##  <Ref BookName="ref" Oper="InputTextString" />, 
##  <Ref BookName="ref" Oper="InputOutputLocalProcess" />, 
##  <Ref BookName="scscp" Oper="InputOutputTCPStream" Label="for client" />,
##  <Ref BookName="scscp" Oper="InputOutputTCPStream" Label="for server" />)
##  with an &OpenMath; object on it.
##  <Ref Func="OMGetObject" /> takes precisely one object off <A>stream</A> 
##  and returns it as a GAP object.
##  Both XML and binary &OpenMath; encoding are supported: autodetection
##  is used.
##  <P/>
##  This may be used to retrieve objects from a file. In the following
##  example we demonsrate reading the same content in binary and XML
##  formats using the test files supplied with the package (the package
##  autodetects whether binary or XML encoding is used):
##  <Example>
##  <![CDATA[
##  gap> txml:=Filename(DirectoriesPackageLibrary("openmath","tst"),"test3.omt");;   
##  gap> tbin:=Filename(DirectoriesPackageLibrary("openmath","tst"),"test3.bin");;   
##  gap> xstream := InputTextFile( txml );; bstream := InputTextFile( tbin );;   
##  gap> x:=OMGetObject(xstream); y:=OMGetObject(bstream);
##  912873912381273891
##  912873912381273891
##  gap> x:=OMGetObject(xstream); y:=OMGetObject(bstream);
##  E(4)
##  E(4)
##  gap> CloseStream(xstream);CloseStream(bstream);
##  ]]>
##  </Example>
##  To paste an &OpenMath; object directly into standard input
##  execute the following command in GAP:
##  <Log>
##  <![CDATA[
##  gap> s:= InputTextUser();; g := OMGetObject(s); CloseStream(s);
##  gap> 
##  ]]>
##  </Log>
##  <P/> For XML &OpenMath;, this function requires that the &GAP; package 
##  &GAPDoc; is available.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

DeclareGlobalFunction("OMGetObject");

#####################################################################
##
##  The Symbol Record for supported symbols from official OpenMath CDs
##
##  Maps a pair ["cd", "name"] to the corresponding OMgap... function
##  defined above or immediately in the record
##
DeclareGlobalVariable("OMsymRecord");

#############################################################################
#E
