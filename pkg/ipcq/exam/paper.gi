
##
## These are Eddies examples
##

Table1 := function( i )
    local r, F, f, a, b, c;
    r := List( [1..12], x -> false );
    F := FreeGroup(2);
    f := GeneratorsOfGroup(F);
    a := f[1]; b := f[2];
    r[1] := [LC( a^2, b, a ), LC( a, b^2, a ), LC( a, b, a^2 ), LC( b, a, b )];
    r[2] := [LC( a, b, a ), LC( b^2, a, b^2 ), LC( b, a)^2,
             LC( LC( b, a )^(b^3), LC( b, a )^(b^-4) ) ];
    r[3] := [LC( a, b, a ), LC( b^2, a, b ), 
             LC( LC( b^5, a )^(b^7), LC( b^-1, a^-3 )^(b^-7) ), LC( b, a^2 )];
    r[4] := [LC( a, b, a ), LC( b, a, b ), LC( LC( b^2, a), LC( b*a*b^2, a )),
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
    return F/r[i];
end;

##
## These are AcGroups on 2 generators
##

Table2 := function( i )
    local r, F, f, a, b, c;
    if i in [1,2] then 
        r := List( [1,2], x -> false );
        F := FreeGroup(2);
        f := GeneratorsOfGroup(F);
        a := f[1]; b := f[2];
        r[1] := [a^2, b*a*b^-1*a*b^-1*a*b^2*a*b^-1*a*b^-1*a*b,
                 a*b^-1*a*b^-1*a*b*a*b*a*b^-1*a*b*a*b*a*b^-1];
        r[2] := [ b^-1*a*b*a^-1*b*a*b^-1*a^-1, a*b^-1*a^-2*b*a^-1*b^-1*a^2*b, 
                  b^-1*a^-2*b*a^2*b*a^-2*b^-1*a^2 ];
        return F/r[i];
    else
        i := i - 2;
        r := List( [1,2,3], x -> false );
        F := FreeGroup(3);
        f := GeneratorsOfGroup(F);
        a := f[1]; b := f[2]; c := f[3];
        r[1] := [ a^2, a*c*a*c^-1, b*c*b^-1*c^-1*b*c^-1*b^-1*c, 
                  b*c*b^-1*c^-2*b^-1*c*b, b*c*b^-1*a*b*c^-1*b^-1*a, 
                  b^-1*c^-1*a*b*c*a*b*c^-1*a*b^-1*c*a ];
        r[2] := [ a^2, a*c*a*c, b^-1*c*b*c^-1, b^-1*a*b*c*a*b*a*c*b^-1*a ];
        return F/r[i];
    fi;
end;
