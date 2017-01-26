# 2005/08/11 (TB)
gap> DeclareGlobalVariable( "TestVariable" );
gap> InstallFlushableValue( TestVariable, rec() );
gap> MakeReadWriteGlobal( "TestVariable" );  UnbindGlobal( "TestVariable" );
