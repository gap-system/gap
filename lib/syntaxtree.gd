## syntaxtree.gd

DeclareCategory("IsSyntaxTree", IsObject);
BindGlobal("SyntaxTreeType", NewType( NewFamily( "SyntaxTreeFamily" )
                                    , IsSyntaxTree and IsComponentObjectRep ) );

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
