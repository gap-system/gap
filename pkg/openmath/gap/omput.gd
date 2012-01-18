###########################################################################
##
#W  omput.gd                OpenMath Package                 Andrew Solomon
#W                                                         Marco Costantini
#W                                                      Alexander Konovalov
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  Writes a GAP object to an output stream, as an OpenMath object
## 


###########################################################################

DeclareGlobalVariable("OpenMathRealRandomSource");

###########################################################################
##
##  Declarations for OpenMathWriter
##
##  <#GAPDoc Label="IsOpenMathWriter">
##  <ManSection>
##      <Filt Name="IsOpenMathWriter" Type="Category" />
##      <Filt Name="IsOpenMathXMLWriter" Type="Category" />
##      <Filt Name="IsOpenMathBinaryWriter" Type="Category" />
##  <Description>
##  <Ref Filt="IsOpenMathWriter"/>is a category for &OpenMath; writers. 
##  It has two subcategories: <Ref Filt="IsOpenMathXMLWriter"/> and  
##  <Ref Filt="IsOpenMathBinaryWriter"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareCategory( "IsOpenMathWriter", IsObject );
DeclareCategory( "IsOpenMathXMLWriter", IsOpenMathWriter );
DeclareCategory( "IsOpenMathBinaryWriter", IsOpenMathWriter );
OpenMathWritersFamily := NewFamily( "OpenMathWritersFamily" );


###########################################################################
##
##  <#GAPDoc Label="OpenMathBinaryWriter">
##  <ManSection>
##      <Func Name="OpenMathBinaryWriter" Arg="s" />
##  <Description>
##  for a stream <A>s</A>, returns an object in the category 
##  <Ref Filt="OpenMathBinaryWriter"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction ( "OpenMathBinaryWriter" );


###########################################################################
##
##  <#GAPDoc Label="OpenMathXMLWriter">
##  <ManSection>
##      <Func Name="OpenMathXMLWriter" Arg="s" />
##  <Description>
##  for a stream <A>s</A>, returns an object in the category 
##  <Ref Filt="IsOpenMathXMLWriter"/>. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction ( "OpenMathXMLWriter" );

DeclareRepresentation( "IsOpenMathWriterRep", IsPositionalObjectRep, [ ] );
OpenMathBinaryWriterType := NewType( OpenMathWritersFamily, 
                              IsOpenMathWriterRep and IsOpenMathBinaryWriter );
OpenMathXMLWriterType    := NewType( OpenMathWritersFamily, 
                              IsOpenMathWriterRep and IsOpenMathXMLWriter );                                
                            
                               
###########################################################################
##
#F  OMPutObject( <stream>, <obj> )  
#F  OMPutObjectNoOMOBJtags( <stream>, <obj> )  
## 
##  <#GAPDoc Label="OMPutObject">
##  
##  <ManSection>
##      <Func Name="OMPutObject" Arg="stream obj" />
##      <Func Name="OMPutObjectNoOMOBJtags" Arg="stream obj" />
##  <Description>
##  <Ref Func="OMPutObject" /> writes (appends) the XML &OpenMath; 
##  encoding of the &GAP; object <A>obj</A> to output stream <A>stream</A> 
##  (see <Ref BookName="ref" Oper="InputTextFile" />, 
##  <Ref BookName="ref" Oper="OutputTextUser" />, 
##  <Ref BookName="ref" Oper="OutputTextString" />, 
##  <Ref BookName="scscp" Oper="InputOutputTCPStream" Label="for client" />,
##  <Ref BookName="scscp" Oper="InputOutputTCPStream" Label="for server" />).
##  <P/>
##  The second version does the same but without &lt;OMOBJ> 
##  tags, what may be useful for assembling complex &OpenMath; objects.
##  <Example>
##  <![CDATA[
##  gap> g := [[1,2],[1,0]];;
##  gap> t := "";
##  ""
##  gap> s := OutputTextString(t, true);;
##  gap> w:=OpenMathXMLWriter( s );
##  <OpenMath XML writer to OutputTextString(0)>
##  gap> OMPutObject(w, g);
##  gap> CloseStream(s);
##  gap> Print(t);
##  <OMOBJ>
##  	<OMA>
##  		<OMS cd="linalg2" name="matrix"/>
##  		<OMA>
##  			<OMS cd="linalg2" name="matrixrow"/>
##  			<OMI>1</OMI>
##  			<OMI>2</OMI>
##  		</OMA>
##  		<OMA>
##  			<OMS cd="linalg2" name="matrixrow"/>
##  			<OMI>1</OMI>
##  			<OMI>0</OMI>
##  		</OMA>
##  	</OMA>
##  </OMOBJ>
##  ]]>
##  </Example>
##  
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
## 
DeclareGlobalFunction("OMPutObject");
DeclareGlobalFunction("OMPutObjectNoOMOBJtags");

DeclareOperation("OMPutOMOBJ",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutEndOMOBJ", [ IsOpenMathWriter ] );


###########################################################################
##
#O  OMPut(<stream>,<obj> ) 
## 
##
DeclareOperation("OMPut", [IsOpenMathWriter, IsObject ]);


###########################################################################
##
#F  OMPrint( <obj> ) .................   Print <obj> as OpenMath object 
##
##  <#GAPDoc Label="OMPrint">
##  <ManSection>
##      <Func Name="OMPrint" Arg="obj" />
##  <Description>
##  OMPrint writes the default XML &OpenMath; encoding of &GAP; 
##  object <A>obj</A> to the standard output.
##  <P/>
##  One can try it with different &GAP; objects to see if they
##  can be converted to &OpenMath; and learn how their &OpenMath;
##  representation looks like. Here we show the encoding for lists 
##  of integers and rationals:
##  <Example>
##  <![CDATA[
##  gap> OMPrint( [ 1, 1/2 ] );     
##  <OMOBJ>
##  	<OMA>
##  		<OMS cd="list1" name="list"/>
##  		<OMI>1</OMI>
##  		<OMA>
##  			<OMS cd="nums1" name="rational"/>
##  			<OMI>1</OMI>
##  			<OMI>2</OMI>
##  		</OMA>
##  	</OMA>
##  </OMOBJ>
##  ]]>
##  </Example>
##  Strings are encoded using <C>&lt;OMSTR></C> tags:
##  <Example>
##  <![CDATA[
##  gap> OMPrint( "This is a string" );
##  <OMOBJ>
##  	<OMSTR>This is a string</OMSTR>
##  </OMOBJ>
##  ]]>
##  </Example>
##  Cyclotomics may be encoded in different ways dependently on their properties:
##  <Example>
##  <![CDATA[
##  gap> OMPrint( 1-2*E(4) );      
##  <OMOBJ>
##  	<OMA>
##  		<OMS cd="complex1" name="complex_cartesian"/>
##  		<OMI>1</OMI>
##  		<OMI>-2</OMI>
##  	</OMA>
##  </OMOBJ>
##  gap> OMPrint(E(3));       
##  <OMOBJ>
##  	<OMA>
##  		<OMS cd="arith1" name="plus"/>
##  		<OMA>
##  			<OMS cd="arith1" name="times"/>
##  			<OMI>1</OMI>
##  			<OMA>
##  				<OMS cd="algnums" name="NthRootOfUnity"/>
##  				<OMI>3</OMI>
##  				<OMI>1</OMI>
##  			</OMA>
##  		</OMA>
##  	</OMA>
##  </OMOBJ>
##  ]]>
##  </Example>
##  Various encodings may be used for various types of groups:
##  <Example>
##  <![CDATA[
##  gap> OMPrint( Group( (1,2) ) );
##  <OMOBJ>
##  	<OMA>
##  		<OMS cd="permgp1" name="group"/>
##  		<OMS cd="permutation1" name="right_compose"/>
##  		<OMA>
##  			<OMS cd="permut1" name="permutation"/>
##  			<OMI>2</OMI>
##  			<OMI>1</OMI>
##  		</OMA>
##  	</OMA>
##  </OMOBJ>
##  gap> OMPrint( Group( [ [ [ 1, 2 ],[ 0, 1 ] ] ] ) );
##  <OMOBJ>
##  	<OMA>
##  		<OMS cd="group1" name="group_by_generators"/>
##  		<OMA>
##  			<OMS cd="linalg2" name="matrix"/>
##  			<OMA>
##  				<OMS cd="linalg2" name="matrixrow"/>
##  				<OMI>1</OMI>
##  				<OMI>2</OMI>
##  			</OMA>
##  			<OMA>
##  				<OMS cd="linalg2" name="matrixrow"/>
##  				<OMI>0</OMI>
##  				<OMI>1</OMI>
##  			</OMA>
##  		</OMA>
##  	</OMA>
##  </OMOBJ>
##  gap> OMPrint( FreeGroup( 2 ) );                      
##  <OMOBJ>
##  	<OMA>
##  		<OMS cd="fpgroup1" name="free_groupn"/>
##  		<OMI>2</OMI>
##  	</OMA>
##  </OMOBJ>
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OMPrint");


###########################################################################
## 
##  OMString( <obj> ) ........ returns string with <obj> as OpenMath object
##
##  <#GAPDoc Label="OMString">
##  <ManSection>
##      <Func Name="OMString" Arg="obj" />
##  <Description>
##  OMString returns a string with the default XML &OpenMath; 
##  encoding of &GAP; object <A>obj</A>.
##  If used with the <K>noomobj</K> option, then initial and 
##  final &lt;OMOBJ> tags will be omitted.
##  <Example>
##  <![CDATA[
##  gap> OMString(42);
##  "<OMOBJ> <OMI>42</OMI> </OMOBJ>"
##  gap> OMString([1,2]:noomobj);    
##  "<OMA> <OMS cd=\"list1\" name=\"list\"/> <OMI>1</OMI> <OMI>2</OMI> </OMA>"
##  ]]>
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OMString");


###########################################################################
##
#F  OMWriteLine( <stream>, <list> )
##
##  Auxiliary function for OMPut functions.
##  Takes a list of string arguments and outputs them
##  to a single line with the correct indentation.
##
##  Input : List of arguments to print
##  Output: \t ^ OMIndent, arguments
##
DeclareGlobalFunction("OMWriteLine");


###########################################################################
##
#F  OMPutSymbol( <stream>, <cd>, <name> )
##
##  Input : cd, name as strings
##  Output: <OMS cd="<cd>" name="<name>" />
##
DeclareOperation("OMPutSymbol", [ IsOpenMathWriter, IsString, IsString ] );


###########################################################################
##
#F  OMPutForeign( <stream>, <encoding>, <string> )
##
##  Input : encoding and string representing the foreighn object
##
DeclareOperation("OMPutForeign", [ IsOpenMathWriter, IsString, IsString ] );


###########################################################################
##
#F  OMPutVar( <stream>, <name> )
##
##  Input : name as string
##  Output: <OMV name="<name>" />
##
DeclareOperation("OMPutVar", [ IsOpenMathWriter, IsObject ] );


###########################################################################
##
#M  OMPutApplication( <stream>, <cd>, <name>, <list> )
##
##  Input : cd, name as strings, list as a list
##  Output:
##        <OMA>
##                <OMS cd=<cd> name=<name>/>
##                OMPut(<list>[1])
##                OMPut(<list>[2])
##                ...
##        </OMA>
##
DeclareGlobalFunction("OMPutApplication");
DeclareOperation("OMPutOMA",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutOMAWithId", [ IsOpenMathWriter , IsString ] );
DeclareOperation("OMPutEndOMA", [ IsOpenMathWriter ] );


###########################################################################
##
## Tags for attributions and attribution pairs
##
DeclareOperation("OMPutOMATTR",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutEndOMATTR",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutOMATP", [ IsOpenMathWriter ] );
DeclareOperation("OMPutEndOMATP", [ IsOpenMathWriter ] );

###########################################################################
##
#M  OMPutBinding( <stream>, <cd>, <name>, <listbvars>, <object> )
##
##  Input : cd, name, list of bvars, object
##  Output:
##        <OMBIND>
##                <OMS cd=<cd> name=<name>/>
##                OMPut(<list>[1])
##                OMPut(<object)
##                ...
##        </OMBIND>
##
#DeclareGlobalFunction("OMPutBinding");
DeclareOperation("OMPutOMBIND",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutOMBINDWithId", [ IsOpenMathWriter , IsString ] );
DeclareOperation("OMPutEndOMBIND", [ IsOpenMathWriter ] );


###########################################################################
##
## Tags for binding vars
##
DeclareOperation("OMPutOMBVAR",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutEndOMBVAR",    [ IsOpenMathWriter ] );


###########################################################################
##
#M  OMPutError( <stream>, <cd>, <name>, <list> )
##
##  Input : cd, name as strings, list as a list
##  Output:
##        <OME>
##                <OMS cd=<cd> name=<name>/>
##                OMPut(<list>[1])
##                OMPut(<list>[2])
##                ...
##        </OME>
##
DeclareGlobalFunction("OMPutError");
DeclareOperation("OMPutOME",    [ IsOpenMathWriter ] );
DeclareOperation("OMPutEndOME", [ IsOpenMathWriter ] );

DeclareAttribute( "OMReference", IsObject );

DeclareOperation( "OMPutReference", [ IsOpenMathWriter, IsObject ] );


###########################################################################
##
#O  OMPutByteArray( <stream>, <bitlist> ) 
## 
##  Put bitlists into byte arrays
##
DeclareGlobalFunction("OMPutByteArray");


###########################################################################
##
#O  OMPutList(<stream>,<obj> ) 
## 
##  Tries to render this as an OpenMath list
##
DeclareOperation("OMPutList", [ IsOpenMathWriter, IsObject ]);


# Determines the indentation of the next line to be printed.
OMIndent := 0;


###########################################################################
#
# Declarations for OMPlainString objects
#
##  <#GAPDoc Label="OMPlainString">
##  <ManSection>
##      <Func Name="OMPlainString" Arg="string" />
##  <Description>
##  <Ref Func="OMPlainString" /> wraps the string into a &GAP; object of a
##  special kind called an &OpenMath; plain string. Internally such object is
##  represented as a string, but <Ref Func="OMPutObject" /> threat it in a
##  different way: instead of converting it into a &lt;OMSTR> object, an
##  &OpenMath; plain string will be plainly substituted into the output (this
##  explains its name) without decorating it with &lt;OMSTR> tags. 
##  <P/>
##  It is assumed that &OpenMath; plain string contains valid &OpenMath; code;
##  no actual validation is performed during its creation. Such functionality
##  may be useful to compose some &OpenMath; code at the &GAP; level to
##  communicate it to the other system, in particular, to send there symbols
##  which are not supported by &GAP;, for example:
##  <Example>
##  <![CDATA[
##  gap> s:=OMPlainString("<OMS cd=\"nums1\" name=\"pi\"/>");
##  <OMS cd="nums1" name="pi"/>
##  gap> OMPrint(s);                                       
##  <OMOBJ>
##  	<OMS cd="nums1" name="pi"/>
##  </OMOBJ>
##  ]]>
##  </Example>
##  
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsOMPlainString", IsObject );
OMPlainStringsFamily := NewFamily( "OMPlainStringsFamily" );
DeclareGlobalFunction ( "OMPlainString" );
DeclareRepresentation( "IsOMPlainStringRep", IsPositionalObjectRep, [ ] );
OMPlainStringDefaultType := NewType( OMPlainStringsFamily, 
                                IsOMPlainStringRep and IsOMPlainString );                                

###########################################################################
#E
