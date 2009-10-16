##############################################################################
##
#A  exptree.gi                Oktober 2002                       Werner Nickel
##
##  This file contains an implementation of simple arithmetic expression that
##  that avoid expanding an expression into a string of symbols.
##

ExpTreeNodeTypes := 
  rec( \*       := 1,
       \/       := 2,
       \^       := 3,
       \=       := 4,
       Comm     := 5,
       Conj     := 6,
       Variable := 7,
       Integer  := 8
       );   

NewNode := function( node )

    return Objectify( TYPE_EXPR_TREE, node );
end;

NewLeaf := function( name )

    return NewNode( rec( type := ExpTreeNodeTypes.Variable,
                         left  := ~,
                         right := ~,
                         name := name ) );
end;

#############################################################################
##
#F  ExpressionTrees . . . . . . . . . . .  create leaves for expression trees
##
##  The function can be called in two different ways:
## 
##  The first argument is a positive integer:  This is the number of
##  expression symbols to be created.  It can be followed by a strings as an
##  optional second argument specifying the prefix for the names of the
##  sysmbols. 
##
##  All arguments are strings: These are interpreted as the name of the
##  expression symbols to be created.
##
ExpressionTrees := function( arg )
    local   prefix,  m,  symbols;
    
    prefix := "x";
    if Length(arg) = 1 and IsInt( arg[1] ) then
        m := arg[1];
        symbols := List( [1..m], i->Concatenation( prefix, String(i) ) );
    elif Length(arg) = 2 and IsInt( arg[1] ) and IsString(arg[2]) then
        m := arg[1];
        prefix := arg[2];
        symbols := List( [1..m], i->Concatenation( prefix, String(i) ) );
    elif ForAll( arg, IsString ) then
        symbols := arg;
    else
        Error( "Usage: ExpressionTrees( <n>[, <prefix>] | <symbols> )" );
    fi;

    return List( symbols, NewLeaf );
end;

NewIntegerLeaf := function( n )

    return NewNode( rec( type  := ExpTreeNodeTypes.Integer,
                         left  := ~,
                         right := ~,
                         value := n ) );
end;

InstallMethod( \*,   [IsExprTree, IsExprTree], function( l, r )
    return NewNode( rec( type := ExpTreeNodeTypes.\*,
                   left  := l,
                   right := r ) );
end );

InstallMethod( \/,   [IsExprTree, IsExprTree], function( l, r )
    return NewNode( rec( type := ExpTreeNodeTypes.\/,
                   left  := l,
                   right := r ) );
end );

InstallMethod( \^,   [IsExprTree, IsExprTree], function( l, r )
    return NewNode( rec( type := ExpTreeNodeTypes.\^,
                   left  := l,
                   right := r ) );
end );

InstallMethod( \^,   [IsExprTree, IsInt], function( l, r )
    return NewNode( rec( type := ExpTreeNodeTypes.\^,
                   left  := l,
                   right := NewIntegerLeaf( r ) ) );
end );

InstallMethod( \=,   [IsExprTree, IsExprTree], function( l, r )
    return NewNode( rec( type := ExpTreeNodeTypes.\=,
                   left  := l,
                   right := r ) );
end );

InstallMethod( Comm, [IsExprTree, IsExprTree], function( l, r )

    return NewNode( rec( type := ExpTreeNodeTypes.Comm,
                   left  := l,
                   right := r ) );
end );

InstallMethod( \<, [IsExprTree, IsExprTree], function( l, r )

    if l!.type = ExpTreeNodeTypes.Variable and
       r!.type = ExpTreeNodeTypes.Variable then
        return l!.name < r!.name;
    fi;

    return fail;
end );







ExpTreePrintFunctions := [];
ExpTreePrintingLeftNormed := false;

ExpTreePrintFunctions[ ExpTreeNodeTypes.\* ] := function( stream, t )
    
    PrintTo( stream, String( t!.left ) );
    PrintTo( stream, "*" );
    PrintTo( stream, String( t!.right ) );
end;

ExpTreePrintFunctions[ ExpTreeNodeTypes.\/ ] := function( stream, t )

    PrintTo( stream, String( t!.left ) );
    PrintTo( stream, "/" );
    if t!.right!.type = ExpTreeNodeTypes.\* then 
        PrintTo( stream, "(", String( t!.right ), ")" );
    else
        PrintTo( stream, String( t!.right ) );
    fi;
end;

ExpTreePrintFunctions[ ExpTreeNodeTypes.\^ ] := function( stream, t )

    if t!.left!.type in [ExpTreeNodeTypes.\*, 
               ExpTreeNodeTypes.\/, ExpTreeNodeTypes.\^] then 
        PrintTo( stream, "(", String( t!.left ), ")" );
    else
        PrintTo( stream, String( t!.left ) );
    fi;
    PrintTo( stream, "^" );
    if t!.right!.type in [ExpTreeNodeTypes.\*, 
               ExpTreeNodeTypes.\/, ExpTreeNodeTypes.\^] then 
        PrintTo( stream, "(", String( t!.right ), ")" );
    else
        PrintTo( stream, String( t!.right ) );
    fi;
end;

ExpTreePrintFunctions[ ExpTreeNodeTypes.Comm ] := function( stream, t )
    local   saveFlag;
    
    if not ExpTreePrintingLeftNormed then
        if NqGapOutput then
            PrintTo( stream, "Comm( " );
        else
            PrintTo( stream, "[ " );
        fi;
    fi;

    saveFlag := ExpTreePrintingLeftNormed;
#    ExpTreePrintingLeftNormed := true;
    PrintTo( stream, String( t!.left ) );
    ExpTreePrintingLeftNormed := saveFlag;

    PrintTo( stream, ", " );
    PrintTo( stream, String( t!.right ) );

    if not ExpTreePrintingLeftNormed then
        if NqGapOutput then
            PrintTo( stream, " )" );
        else
            PrintTo( stream, " ]" );
        fi;
    fi;
end;

ExpTreePrintFunctions[ ExpTreeNodeTypes.Conj ] := function( stream, t )
    
    if t!.left!.type in [ExpTreeNodeTypes.\*, 
               ExpTreeNodeTypes.\/, ExpTreeNodeTypes.\^ ] then 
        PrintTo( stream, "(", String( t!.left ), ")" );
    else
        PrintTo( stream, String( t!.left ) );
    fi;
    PrintTo( stream, "^" );
    if t!.right!.type in [ExpTreeNodeTypes.\*, 
               ExpTreeNodeTypes.\/, ExpTreeNodeTypes.\^ ] then 
        PrintTo( stream, "(", String( t!.right ), ")" );
    else
        PrintTo( stream, String( t!.right ) );
    fi;

end;

ExpTreePrintFunctions[ ExpTreeNodeTypes.\= ] := function( stream, t )
    
    PrintTo( stream, String( t!.left ) );
    PrintTo( stream, "=" );
    PrintTo( stream, String( t!.right ) );
end;

ExpTreePrintFunctions[ ExpTreeNodeTypes.Integer ] := function( stream, t )
    
    PrintTo( stream, String( t!.value ) );
end;

ExpTreePrintFunctions[ ExpTreeNodeTypes.Variable ] := function( stream, t )
    
    PrintTo( stream, String( t!.name ) );
end;

InstallMethod( PrintObj, [IsExprTree], function( t )
    local   save;

    save := NqGapOutput;
    NqGapOutput := true;
    Print( String( t ) );
    NqGapOutput := save;

end );

InstallMethod( Display, [IsExprTree], Print );

InstallMethod( ViewObj, [IsExprTree], Print );

InstallMethod( String, [IsExprTree], function( t )
    local   string,  stream;

    string := [];
    stream := OutputTextString( string, false );
    ExpTreePrintFunctions[ t!.type ]( stream, t );

    return string;
end );






ExpTreeEvalFunctions := [];

EvalExpTree := function( t )
    
    return ExpTreeEvalFunctions[ t!.type ]( t!.left, t!.right );
end;

ExpTreeEvalFunctions[ ExpTreeNodeTypes.\* ] := function( t1, t2 )
  
    return EvalExpTree( t1 ) * EvalExpTree( t2 );
end;

ExpTreeEvalFunctions[ ExpTreeNodeTypes.\/ ] := function( t1, t2 )
  
    return EvalExpTree( t1 ) / EvalExpTree( t2 );
end;

ExpTreeEvalFunctions[ ExpTreeNodeTypes.\^ ] := function( t1, t2 )
  
    return EvalExpTree( t1 ) ^ EvalExpTree( t2 );
end;

ExpTreeEvalFunctions[ ExpTreeNodeTypes.Comm ] := function( t1, t2 )
  
    return Comm( EvalExpTree( t1 ), EvalExpTree( t2 ) );
end;

ExpTreeEvalFunctions[ ExpTreeNodeTypes.Conj ] := function( t1, t2 )
  
    return EvalExpTree( t1 ) ^ EvalExpTree( t2 );
end;

ExpTreeEvalFunctions[ ExpTreeNodeTypes.\= ] := function( t1, t2 )
  
    return EvalExpTree( t1 ) / EvalExpTree( t2 );
end;

ExpTreeEvalFunctions[ ExpTreeNodeTypes.Variable ] := function( t1, t2 )
  
    return t1!.value;
end;

ExpTreeEvalFunctions[ ExpTreeNodeTypes.Integer ] := function( t1, t2 )
  
    return t1!.value;
end;

EvaluateExpTree := function( t, leaves, values )
    
    local i, result;
    
    for i in [1..Length(leaves)] do leaves[i]!.value := values[i]; od;
    result := EvalExpTree( t );
    for i in [1..Length(leaves)] do Unbind( leaves[i]!.value ); od;
    
    return result;
end;



VariablesOfExpTree := function( t )
     
    if t!.type = ExpTreeNodeTypes.Variable then
        return [ t ];
    elif t!.type = ExpTreeNodeTypes.Integer then
        return [];
    else
        return Union( VariablesOfExpTree( t!.left ),
                      VariablesOfExpTree( t!.right ) );
    fi;
end;

DepthOfExpTree := function( t )
    
    if t!.type = ExpTreeNodeTypes.Variable then
        return 0;
    elif t!.type = ExpTreeNodeTypes.Integer then
        return 0;
    else
        return 1 + Maximum( DepthOfExpTree( t!.left ),
                            DepthOfExpTree( t!.right ) );
    fi;
end;
    
FpGroupExpTree := function( p )
    local   F,  gens,  rels;

    F := FreeGroup( Length( p.generators ) );
    
    gens := GeneratorsOfGroup( F );
    rels := List( p.relations, r->EvaluateExpTree( r, p.generators, gens ) );

    return F / rels;
end;
    
