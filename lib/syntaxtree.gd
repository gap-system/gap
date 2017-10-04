#

DeclareCategory("IsSyntaxTree", IsObject);
BindGlobal("SyntaxTreeType", NewType( NewFamily( "SyntaxTreeFamily" )
                                    , IsSyntaxTree and IsComponentObjectRep ) );

DeclareCategory("IsGAPCompiler", IsObject);
BindGlobal("GAPCompilerType", NewType( NewFamily("GAPCompilerFamily")
                                     , IsGAPCompiler and IsComponentObjectRep ) );

##  <#GAPDoc Label="SyntaxTree">
##  <ManSection>
##  <Func Name="SyntaxTree" Arg='f'/>
##
##  <Description>
##  Takes a GAP function <A>f</A> and returns its syntax tree.
##
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

DeclareGlobalFunction("SyntaxTree");

##  <#GAPDoc Label="CleanupCompiler">
##  <ManSection>
##  <Func Name="CleanupCompiler" Arg='tree'/>
##
##  <Description>
##  This compiler takes a syntax tree <A>tree</A> and
##  combines the different variants of
##   <C>T_PROCCALL</C>
##   <C>T_FUNCCALL</C>
##   <C>T_SEQ_STAT</C>
##   <C>T_IF</C>,
##   <C>T_FOR</C>,
##   <C>T_WHILE</C>,
##   <C>T_REPEAT</C>
##
##  Performing this transformation makes writing more complicated
##  transformations easier.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("CleanupCompiler");


##  <#GAPDoc Label="PrintCompiler">
##  <ManSection>
##  <Func Name="PrintCompiler" Arg='tree'/>
##
##  <Description>
##  This compiler takes a syntax tree <A>tree</A> and
##  pretty prints it.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("PrettyPrintCompiler");


