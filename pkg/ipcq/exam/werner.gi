
Werner := [];
Werner[1] := function()
    local F, a, b, r;
    F := FreeGroup( 2 );
    a := F.1; b := F.2;
    r := [LC( b, a, a), LC( a, b, b, b, b, b )];
          #LC( b, a, b, b, b, a, b, b, a, a )]; 
    return F/r;
end;

Werner[2] := function()
    local F, a, b, r;
    F := FreeGroup( 2 );
    a := F.1; b := F.2;
    r := [LC( b, a, a), LC( a, b, b, b, b )];
    return F/r;
end;

Werner[3] := function()
    local F, a, b, c, r;
    F := FreeGroup( 3 );
    a := F.1; b := F.2; c := F.3;
    r := [LC( b, a, a), LC( a, b, b ), LC( c, a ), LC( c, b, b ), 
          LC( b, c, c )];
    return F/r;
end;

Werner[4] := function()
    local F, a, b, c, d, r;
    F := FreeGroup( 4 );
    a := F.1; b := F.2; c := F.3; d := F.4;
    r := [LC( b, a, a), LC( a, b, b ), LC( c, a ), LC( d, a ), LC( c, b, b ), 
          LC( b, c, c, c ), LC( d, b ), LC( d, c, c ), LC( c, b, a, b)];
    return F/r;
end;

Werner[5] := function()
    local F, a, b, c, r;
    F := FreeGroup( 3 );
    a := F.1; b := F.2; c := F.3; 
    r := [LC( b, a, a, a ), LC( a, b, b ), LC( c, a ), LC( c, b, b, b ), 
          LC( c, b, a, b, c )];
    return F/r;
end;

Werner[6] := function()
    local F, a, b, r;
    F := FreeGroup( 2 );
    a := F.1; b := F.2;
    r := [LC(b, a, a, a, a), LC( b, a, b, b, b, b), 
          LC( b, a*b, a*b, a*b, a*b), LC( b, a*b^2, a*b^2, a*b^2, a*b^2 )];
    return F/r;
end;

Werner[7] := function()
    local F, a, b, r;
    F := FreeGroup( 2 );
    a := F.1; b := F.2;
    r := [RC( a, a, a, b), RC( b, b, a, b )];
    return F/r;
end;

Werner[8] := function()
    local F, a, b, r;
    F := FreeGroup( 2 );
    a := F.1; b := F.2;
    r := [RC( a, a, a, b), RC( b, b, a, b), LC( b, a, b, a, a, b )];
    return F/r;
end;

Werner[9] := function()
    local F, a, b, r;
    F := FreeGroup( 2 );
    a := F.1; b := F.2;
    r := [LC(b, a, a, a, a), LC( b, a, b, b, b), 
          LC( b, a*b, a*b, a*b), LC( b, a*b^2, a*b^2, a*b^2), 
          LC( b, a, b, a, a, a ), LC( b, a, a, b, b, b )];
    return F/r;
end;

ExamplesOfWernerNickel := function( i )
    local H, P;
    H := Werner[i]();
    P := PresentationFpGroup(H);
    SimplifyPresentation(P);
    return FpGroupPresentation(P);
end;
