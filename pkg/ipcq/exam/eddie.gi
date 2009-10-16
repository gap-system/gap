
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

ExamplesOfEddieLo := function( i )
local r, F, f, a, b, c;
r := List( [1..15], x -> false );
if i <= 12 or i = 14 then
    F := FreeGroup(2);
    f := GeneratorsOfGroup(F);
    a := f[1]; b := f[2];
    r[1] := [LC( a^2, b, a ), 
             LC( a, b^2, a ), 
             LC( a, b, a^2 ), 
             LC( b, a, b )];
    r[2] := [LC( a, b, a ),
             LC( b^2, a, b^2 )*LC( LC( b, a )^(b^3), LC( b, a )^(b^-4) ),
             LC( b, a)^2 ];
    r[3] := [LC( a, b, a ), 
             LC( b^2, a, b )*LC( LC( b^5, a )^(b^7), LC( b^-1, a^-3 )^(b^-7)), 
             LC( b, a^2 )];
    r[4] := [LC( a, b, a ), 
             LC( b, a, b )* LC( LC( b^2, a), LC( b*a*b^2, a )),
             LC( b, a )^2 ];
    r[5] := [LC( a, b, a ), LC( b^2, a, b^2 )];
    r[6] := [LC( b, a, a )*LC( b^2, a, LC( b, a*b^2*a ) ), LC( b, a*b^-1*a)];
    r[7] := [LC( a, b )^2, LC( a, b, b )*LC( b, a, a ), LC( b^-1, a^2, a*b)];
    r[8] := [LC( b, a, b )*LC( b, a, a^-1, b ), LC( b, a, a^2 )];
    r[9] := [LC( b, a^3 ), LC( b, a^2, b^2 ), LC( b, a, b^3 ), 
             LC( b, a, b^2, a^2 )];
    r[10] := [LC( b, a, b ), LC( b, a^5 )];
    r[11] := [LC( b, a, b ), LC( b, a, a, a, a )];
    r[12] := [LC( b, a^3 ), LC( b, a^2, b^2 ), LC( b, a, b^3 ), 
              LC( b, a, b^2, a, b, a ), LC( b, a^2, b, a, b, a ) ];
    r[14] := [LC( b, a, a, a ), LC( b, a, a, b ), LC( b, a, b, b )];
else
    F := FreeGroup(3);
    f := GeneratorsOfGroup(F);
    a := f[1]; b := f[2]; c := f[3];
    r[13] := [a^2, b^2, c^2, (a*b)^3, (b*c)^3, (a*c)^2];
    r[15] := [a*b*c*a*b/c, b*c*a*b*c/a, c*a*b*c*a/b];
    r[16] := [a^2/b^2, b^2/c^2, a*b*c*a*b/c];
    r[17] := [LC(b,a)/c, LC(c,b), LC(c, a, a, a)];
fi;
    return F/r[i];
end;

