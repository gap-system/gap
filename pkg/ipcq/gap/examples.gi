LC := function( arg )
    local w, i;
    w := Comm( arg[1], arg[2] );
    for i in [3..Length( arg )] do
        w := Comm( w, arg[i] );
    od;
    return w;
end;

RC := function( arg )
    local w, i, l;
    l := Length( arg );
    w := Comm( arg[l-1], arg[l] );
    for i in Reversed( [1..Length( arg )-2] ) do
        w := Comm( arg[i], w );
    od;
    return w;
end;

ScramblePcpGroup := function( G )
    local F, P, pcps;
    pcps := PcpsBySeries( DerivedSeries(G), "snf" );
    Print(List( pcps, RelativeOrdersOfPcp ),"\n");
    F := PcpGroupToFpGroup(G);
    P := PresentationFpGroup(F);
    SimplifyPresentation(P);
    return FpGroupPresentation(P);
end;

FpExamples := function( n, m )
    local F, f, a, b, c, r;

    if n = 2 then
        F := FreeGroup( 2 );
        f := GeneratorsOfGroup(F); a := f[1]; b := f[2];
        if m = 1 then r := [f[2]^f[1]/f[2]^-1, f[1]^2]; fi;
        if m = 2 then r := [f[1]*f[2]*f[1]*f[2]^-1*f[1]^-1*f[2]^-1]; fi;
        if m = 3 then r := [f[1]*f[2]*f[1]*f[2]^-1]; fi;
        if m = 4 then r := [LC( a^2, b, a ), LC( a, b^2, a ), LC( a, b, a^2 ),
                            LC( b, a, b )]; fi;
        if m = 5 then r := [LC( a, b, a ), 
             LC( b^2, a, b^2 )*LC( LC( b, a )^(b^3), LC( b, a )^(b^-4) ),
             LC( b, a)^2 ]; fi;
        if m = 6 then r := [LC( a, b, a ),
             LC( b^2, a, b )*LC( LC( b^5, a )^(b^7), LC( b^-1, a^-3 )^(b^-7)),
             LC( b, a^2 )]; fi;
        if m = 7 then r := [LC( a, b, a ), LC( b, a, b )* LC( LC( b^2, a), 
             LC( b*a*b^2, a )), LC( b, a )^2 ]; fi;
        if m = 8 then r := [LC( a, b, a ), LC( b^2, a, b^2 )]; fi;
        if m = 9 then r := [LC( b, a, a )*LC( b^2, a, LC( b, a*b^2*a ) ), 
             LC( b, a*b^-1*a)]; fi;
        if m = 10 then r := [LC( a, b )^2, LC( a, b, b )*LC( b, a, a ), 
             LC( b^-1, a^2, a*b)]; fi;
        if m = 11 then r := [LC( b, a, b )*LC( b, a, a^-1, b ), 
             LC( b, a, a^2 )]; fi;
        if m = 12 then r := [LC( b, a^3 ), LC( b, a^2, b^2 ), LC( b, a, b^3 ),
             LC( b, a, b^2, a^2 )]; fi;
        if m = 13 then r := [LC( b, a, b ), LC( b, a^5 )]; fi;
        if m = 14 then r := [LC( b, a, b ), LC( b, a, a, a, a )]; fi;
        if m = 15 then r := [LC( b, a^3 ), LC( b, a^2, b^2 ), LC( b, a, b^3 ),
              LC( b, a, b^2, a, b, a ), LC( b, a^2, b, a, b, a ) ]; fi;
        if m = 16 then r := [LC( b, a, a, a ), LC( b, a, a, b ), 
              LC( b, a, b, b )]; fi;
        if m < 1 or m > 16 then return false; fi;

    elif n = 3 then
        F := FreeGroup( 3 );
        f := GeneratorsOfGroup(F); a := f[1]; b := f[2]; c := f[3];
        if m = 1 then r := [f[1]^2,f[2]^2,f[3]^2,(f[1]*f[2])^3,(f[1]*f[3])^2,
                            (f[2]*f[3])^3]; fi;
        if m = 2 then r := [a^2, b^2, c^2, (a*b)^3, (b*c)^3, (a*c)^2]; fi;
        if m = 3 then r := [a*b*c*a*b/c, b*c*a*b*c/a, c*a*b*c*a/b]; fi;
        if m = 4 then r := [a^2/b^2, b^2/c^2, a*b*c*a*b/c]; fi;
        if m = 5 then r := [LC(b,a)/c, LC(c,b), LC(c, a, a, a)]; fi;
        if m < 1 or m > 5 then return false; fi;

    else
        return false;
    fi;
    return F/r;
end;

if ac then 
    AcExample := function( d, n )
        local G;
        G := AlmostCrystallographicPcpGroup( d, n, false );
        return ScramblePcpGroup(G);
    end;
fi;

