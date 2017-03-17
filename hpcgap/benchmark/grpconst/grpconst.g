LoadPackage( "grpconst" );

has_errors:=false;

ConstructAndTestAllGroups := function( size )
local grps;
grps := ConstructAllGroups( size );
if Length( grps ) <> NumberSmallGroups( size ) then
	Print( "wrong number of groups of size ", size, "\n" );
	has_errors:=true;
fi;
if Set( List( grps, IdGroup ) ) <>
	List( [ 1 .. NumberSmallGroups( size ) ], x -> [ size, x ] ) then
        Print( "wrong ids for the groups of size ", size, "\n" );
        has_errors:=true;
fi;
end;

