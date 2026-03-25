func := function ( )
    Error( "oops" );
end;

func := SYNTAX_TREE_CODE( SYNTAX_TREE( func ) );

func( );
