
DeclareCategory( "IsExprTree", 
        IsMultiplicativeElementWithInverse and IsComponentObjectRep );

BindGlobal("ExpTreeFamily", NewFamily( "ExprTreeFamily" ));

BindGlobal("TYPE_EXPR_TREE", NewType( ExpTreeFamily, IsExprTree and IsMutable ));

