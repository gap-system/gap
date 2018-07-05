# syntaxtree.gi

InstallGlobalFunction( SyntaxTree,
function(func)
    return Objectify( SyntaxTreeType, rec( tree := SYNTAX_TREE(func) ) );
end);

InstallMethod( ViewString, "for a syntax tree"
               , [ IsSyntaxTree ]
               , t -> "<syntax tree>" );
