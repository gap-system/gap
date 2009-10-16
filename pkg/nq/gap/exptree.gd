
DeclareCategory( "IsExprTree", 
        IsMultiplicativeElementWithInverse and IsComponentObjectRep );

ExpTreeFamily := NewFamily( "ExprTreeFamily" );

TYPE_EXPR_TREE := NewType( ExpTreeFamily, IsExprTree and IsMutable );

