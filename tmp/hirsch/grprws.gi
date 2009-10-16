PcpGroupByCollector := function( coll )
    local n, l, e, f, G, rels;

    n := coll![ PC_NUMBER_OF_GENERATORS ];
    l := IdentityMat( n );
    e := List( [1..n], x -> PcpElementByExponentsNC( coll, l[x] ) );
    f := PcpElementByExponentsNC( coll, 0*l[1] );
    G := Group( e, f );

    # set size
    rels := coll![ PC_EXPONENTS ];
    if not ForAll( [1..n], x -> IsBound( rels[x] ) ) then
        SetSize( G, infinity );
    else
        SetSize( G, Product( rels ) );
    fi;

    # set pcp
    SetPcp( G, e );

    # return 
    return G;
end;

InstallMethod( Pcp, true, [IsPcpGroup], 0,
function( G ) return InducedPcp( GeneratorsOfGroup(G) ); end );

InstallMethod( \in, true, [IsMultiplicativeElementWithInverse,
                           IsGroup and IsPcpGroup], 0,
function( g, G ) return ReducedPcpElement( Pcp(G), g ) = One(G); end );

InstallMethod( Size, true, [ IsPcpGroup ], 0,
function( G )
    local l, o, e, r;
    l := Pcp( G );
    o := 1;
    for e in l do
        r := RelativeOrder( e );
        if r = infinity then return infinity; fi;
        o := o * r;
    od;
    return o;
end );

PrintPcpPresentation := function( G )
    local gens, rels, i, r, g, h, c, j;

    gens := Pcp( G );
    if Length(gens) = 0 then return; fi;
    rels := RelativeOrders( Collector( gens[1] ) );

    for i in [1..Length(gens)] do
        if not IsBound( rels[i] ) then
            Print("index ",i," is infinite \n");
        else
            r := rels[i];
            g := gens[i];
            Print("g",i,"^",r," = ", g^r,"\n");
        fi;
    od;

    for i in [1..Length(gens)] do
        for j in [1..i-1] do
            g := gens[i];
            h := gens[j];
            c := Comm( h, g );
            Print("[ g",j,", g",i," ] = ", c,"\n");
        od;
    od;
end;

HirschLength := function( G )
    local pcp, rel, d, r;
    pcp := Pcp( G );
    rel := List( pcp, RelativeOrder );
    d   := 0;
    for r in rel do
        if not IsInt( r ) then d := d + 1; fi;
    od;
    return d;
end;

InstallMethod( ClosureGroup, true, [IsPcpGroup, IsPcpGroup], 0,
function( G, H )
    local gens;
    gens := Concatenation( GeneratorsOfGroup(G), GeneratorsOfGroup(H) );
    return Subgroup( Parent(G), gens );
end );
 
InstallMethod( IsNilpotentGroup, true, [IsPcpGroup], 0,
function( G )
    local l, U, V, F, n;

    l := HirschLength(G); 
    U := ShallowCopy( G );
    repeat 

        # if we arrive at the trivial group
        V := CommutatorSubgroup( G, U );
        if Size( V ) = 1 then 
            Print("arrived at bottom\n");
            return true; 
        fi;

        # if the lower central series has terminated
        if U = V then 
            Print("series terminated \n");
            return false; 
        fi;

        # if the Hirsch length is not eaten up
        F := U / V;
        n := HirschLength(F);
        Print("got another ",n," to the hirsch length \n");
        if n = 0 and l <> 0  then return false; fi;
        l := l - n;
         
        # iterate
        U := ShallowCopy( V );
    until false;
end );

#############################################################################
##
#F  StringByPcpPres  . . . . . . . . . . . . . convert Pcp pres into a string
##
StringByPcpPres := function( name, pcp )
    local   n,  S,  i,  j;
    
    # Initialise the pc pres
    n := pcp![PC_NUMBER_OF_GENERATORS];
    S := ShallowCopy( name );
    Append( S, " := FromTheLeftCollector( " );
    Append( S, String(n) );
    Append( S, " );\n" );
    
    # install power relations
    for i in [1..n] do
        if IsBound( pcp![PC_EXPONENTS][i] ) then
            
            Append( S, "SetRelativeOrder( " );
            Append( S, name );                   Append( S, ", " );
            Append( S, String( i ) );            Append( S, ", " );
            Append( S, String( pcp![PC_EXPONENTS][i] ) );
            Append( S, " );\n" );
            
            Append( S, "SetPower( " );
            Append( S, name );                   Append( S, ", " );
            Append( S, String(i) );              Append( S, ", " );
            if IsBound( pcp![PC_POWERS][i] ) then
                Append( S, String( pcp![PC_POWERS][i] ) );
            else 
                Append( S, "[]" );
            fi;
            Append( S, " );\n" );
        fi;
    od;
    
    # install conjugate relations
    for j in [1..n] do
        for i in [1..j-1] do
            if IsBound(pcp![PC_CONJUGATES][j][i]) then
                Append( S, "SetConjugate( " );
                Append( S, name );      Append( S, ", " );
                Append( S, String(j) ); Append( S, ", " );
                Append( S, String(i) ); Append( S, ", " );
                Append( S, String( pcp![PC_CONJUGATES][j][i] ) ); 
                Append( S, " );\n" );
            fi;
        od;
    od;
    
    for j in [1..n] do
        for i in [1..j-1] do
            if IsBound(pcp![PC_CONJUGATESINVERSE][j][i]) then
                Append( S, "SetConjugate( " );
                Append( S, name );       Append( S, ", " );
                Append( S, String( j) ); Append( S, ", " );
                Append( S, String(-i) ); Append( S, ", " );
                Append( S, String( pcp![PC_CONJUGATESINVERSE][j][i] ) );
                Append( S, " );\n" );
            fi;
        od;
    od;
    
    for j in [1..n] do
        for i in [1..j-1] do
            if IsBound(pcp![PC_INVERSECONJUGATES][j][i]) then
                Append( S, "SetConjugate( " );
                Append( S, name );       Append( S, ", " );
                Append( S, String(-j) ); Append( S, ", " );
                Append( S, String( i) ); Append( S, ", " );
                Append( S, String( pcp![PC_INVERSECONJUGATES][j][i] ) );
                Append( S, " );\n" );
            fi;
        od;
    od;
    
    for j in [1..n] do
        for i in [1..j-1] do
            if IsBound(pcp![PC_INVERSECONJUGATESINVERSE][j][i]) then
                Append( S, "SetConjugate( " );
                Append( S, name );       Append( S, ", " );
                Append( S, String(-j) ); Append( S, ", " );
                Append( S, String(-i) ); Append( S, ", " );
                Append( S, String( pcp![PC_INVERSECONJUGATESINVERSE][j][i] ) );
                Append( S, " );\n" );
            fi;
        od;
    od;
    
    return S;
end;


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

PcpPresPrintTo := function( file, name, pcp )
    
    PrintTo(  file, "##\n##     ", PcpUserInfo(), "##\n" );
    AppendTo( file, StringByPcpPres( name, pcp ) );
    AppendTo( file, "\n\n" );
end;

PcpPresAppendTo :=  function( file, name, pcp )
  
    AppendTo( file, "##\n##    ", PcpUserInfo(), "##\n" );
    AppendTo( file, StringByPcpPres( name, pcp ) );
    AppendTo( file, "\n\n" );
end;

PcpGroupPrintTo := function( file, name, group )
    
    PcpPresPrintTo( file, name, Collector(One(group)) );
    AppendTo( file, name, " := PcpGroupByCollector( ", name, " );\n\n" );

end;    

PcpGroupAppendTo := function( file, name, group )
    
    PcpPresAppendTo( file, name, Collector(One(group)) );
    AppendTo( file, name, " := PcpGroupByCollector( ", name, " );\n\n" );
    
end;