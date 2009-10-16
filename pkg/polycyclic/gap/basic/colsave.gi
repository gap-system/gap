#############################################################################
##
#F  StringByFTLCollector . . . . . . . convert an ftl collector into a string
##
InstallMethod( String, 
        "from-the-left collector",
        [ IsFromTheLeftCollectorRep ],

function( coll )
    local   name,  n,  S,  i,  j;

    name := ValueOption( "name" );
    if name = fail then
        name := "ftl";
    fi;

    # Initialise the collector
    n := coll![PC_NUMBER_OF_GENERATORS];
    S := ShallowCopy( name );
    Append( S, " := FromTheLeftCollector( " );
    Append( S, String(n) );
    Append( S, " );\n" );
    
    # install power relations
    for i in [1..n] do
        if IsBound( coll![PC_EXPONENTS][i] ) then
            
            Append( S, "SetRelativeOrder( " );
            Append( S, name );                   Append( S, ", " );
            Append( S, String( i ) );            Append( S, ", " );
            Append( S, String( coll![PC_EXPONENTS][i] ) );
            Append( S, " );\n" );
            
            Append( S, "SetPower( " );
            Append( S, name );                   Append( S, ", " );
            Append( S, String(i) );              Append( S, ", " );
            if IsBound( coll![PC_POWERS][i] ) then
                Append( S, String( coll![PC_POWERS][i] ) );
            else 
                Append( S, "[]" );
            fi;
            Append( S, " );\n" );
        fi;
    od;
    
    # install conjugate relations
    for j in [1..n] do
        for i in [1..j-1] do
            if IsBound(coll![PC_CONJUGATES][j][i]) then
                Append( S, "SetConjugate( " );
                Append( S, name );      Append( S, ", " );
                Append( S, String(j) ); Append( S, ", " );
                Append( S, String(i) ); Append( S, ", " );
                Append( S, String( coll![PC_CONJUGATES][j][i] ) ); 
                Append( S, " );\n" );
            fi;
        od;
    od;
    
    for j in [1..n] do
        for i in [1..j-1] do
            if IsBound(coll![PC_CONJUGATESINVERSE][j][i]) then
                Append( S, "SetConjugate( " );
                Append( S, name );       Append( S, ", " );
                Append( S, String( j) ); Append( S, ", " );
                Append( S, String(-i) ); Append( S, ", " );
                Append( S, String( coll![PC_CONJUGATESINVERSE][j][i] ) );
                Append( S, " );\n" );
            fi;
        od;
    od;
    
    for j in [1..n] do
        for i in [1..j-1] do
            if IsBound(coll![PC_INVERSECONJUGATES][j][i]) then
                Append( S, "SetConjugate( " );
                Append( S, name );       Append( S, ", " );
                Append( S, String(-j) ); Append( S, ", " );
                Append( S, String( i) ); Append( S, ", " );
                Append( S, String( coll![PC_INVERSECONJUGATES][j][i] ) );
                Append( S, " );\n" );
            fi;
        od;
    od;
    
    for j in [1..n] do
        for i in [1..j-1] do
            if IsBound(coll![PC_INVERSECONJUGATESINVERSE][j][i]) then
                Append( S, "SetConjugate( " );
                Append( S, name );       Append( S, ", " );
                Append( S, String(-j) ); Append( S, ", " );
                Append( S, String(-i) ); Append( S, ", " );
                Append( S, String( coll![PC_INVERSECONJUGATESINVERSE][j][i] ) );
                Append( S, " );\n" );
            fi;
        od;
    od;
    
    return S;
end );


#############################################################################
##
#F  PcpUserInfo
##
PcpUserInfo := function()
    local   str,  dir,  date,  out;

    str := "";

    dir := Directory( "./" );
    out := OutputTextString( str, true );
    ##  get user name
    Process( dir, Filename( DirectoriesSystemPrograms(), "whoami" ),
            InputTextNone(), out, [] );
    ##  remove trailing newline character
    str[ Length(str) ] := '@';
    ##  get hostname name
    Process( dir, Filename( DirectoriesSystemPrograms(), "hostname" ),
            InputTextNone(), out, [] );
    ##  remove trailing newline character
    Unbind( str[ Length(str) ] );
    Append( str, ":   " );
    ##  get date
    Process( dir, Filename( DirectoriesSystemPrograms(), "date" ),
            InputTextNone(), out, [] );

    CloseStream( out );
    return str;
end;

#############################################################################
##
#F  FTLCollectorPrintTo( <file>, <name>, <coll> )
##
BindGlobal( "FTLCollectorPrintTo",
function( file, name, coll )

    PrintTo(  file, "##\n##     ", PcpUserInfo(), "##\n" );
    AppendTo( file, String( coll : name := name ) );
    AppendTo( file, "\n\n" );
end );

#############################################################################
##
#F  FTLCollectorAppendTo( <file>, <name>, <coll> )
##
BindGlobal( "FTLCollectorAppendTo",
function( file, name, coll )

    AppendTo( file, "##\n##    ", PcpUserInfo(), "##\n" );
    AppendTo( file, String( coll : name := name ) );
    AppendTo( file, "\n\n" );
end );

