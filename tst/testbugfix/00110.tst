# 2005/08/11 (TB)
gap> DeclareOperation( "TestOperation", [ IsGroup, IsGroup ] );
gap> InstallMethod( TestOperation, [ "IsGroup and IsAbelian", "IsGroup" ],
>        function( G, H ) return true; end );
gap> MakeReadWriteGlobal( "TestOperation" );  UnbindGlobal( "TestOperation" );
