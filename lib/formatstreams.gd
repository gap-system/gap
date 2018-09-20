# Formatted output streams

##  <#GAPDoc Label="OutputTextStreamFormatter">
##  <ManSection>
##  <Oper Name="OutputTextStreamFormatter" Arg='stream, indent'/>
##  <Oper Name="OutputTextStreamFormatter" Arg='stream'/>
##
##  <Description>
##  returns an output stream that outputs received characters to the
##  stream <A>stream</A>, adding indentation by a number of spaces
##  after every newline character.
##
##  The parameter <A>indent</A> specifie s an initial indentation, which defaults
##  to <M>0</M>.
##
##  Printing the character <C>\\&leq;</C> to the stream decreases indentation,
##  printing <C>\\&geq;</C> increases indentation.
##
##  <P/>
##  <Example><![CDATA[
##  gap> output := OutputTextStreamFormatter(StandardOutput);
##  gap> WriteAll(output, "Hello, world\n");
##  Hello, world
##  true
##  gap> WriteAll(output, "\>\>Hello, world\nSecond line\nthird\>\>\nfourth\n");
##    Hello, world
##      Second line
##        third
##          fourth
##          true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
# Output stream wrapping another output stream
DeclareCategory( "IsOutputTextStreamFormatter", IsOutputStream );
DeclareRepresentation( "IsOutputTextStreamFormatterRep",
                       IsOutputTextStreamFormatter and IsPositionalObjectRep,
                       ["stream", "indent"] );

BindGlobal( "OutputTextStreamFormatterType",
            NewType( StreamsFamily,
                     IsOutputTextStream and IsOutputTextStreamFormatterRep ) );

DeclareOperation( "OutputTextStreamFormatter", [ IsOutputStream, IsInt] );
DeclareOperation( "OutputTextStreamFormatter", [ IsOutputStream ] );
DeclareOperation( "SetIndentation", [ IsOutputTextStreamFormatter, IsInt ] );
DeclareOperation( "GetIndentation", [ IsOutputTextStreamFormatter ] );

##  <#GAPDoc Label="OutputTextStreamPrefixer">
##  <ManSection>
##  <Oper Name="OutputTextStreamPrefixer" Arg='stream, prefix'/>
##
##  <Description>
##  returns an output stream that outputs received characters to the
##  stream <A>stream</A>, adding <A>prefix</A> in front of every
##  line.
##
##  <P/>
##  <Example><![CDATA[
##  gap> output := OutputTextStreamPrefixer(StandardOutput, "informational: ");;
##  gap> WriteAll(output, "Hello,\nworld");
##  informational: Hello,
##  informational: worldtrue
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
# Output stream prefixing every line
DeclareCategory( "IsOutputTextStreamPrefixer", IsOutputStream );
DeclareRepresentation( "IsOutputTextStreamPrefixerRep",
                       IsOutputTextStreamPrefixer and IsPositionalObjectRep,
                       ["stream", "prefix"] );

BindGlobal( "OutputTextStreamPrefixerType",
            NewType( StreamsFamily,
                     IsOutputTextStream and IsOutputTextStreamPrefixerRep ) );

DeclareOperation( "OutputTextStreamPrefixer", [ IsOutputStream, IsString] );
