func := function ( )
    return CURRENT_STATEMENT_LOCATION(GetCurrentLVars());
end;

func( );

func := SYNTAX_TREE_CODE( SYNTAX_TREE( func ) );

func( );
