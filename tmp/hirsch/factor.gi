InstallMethod( IndexOp, true, [IsPcpGroup, IsPcpGroup], 0,
function( H, U )
    local   pcpH,  pcpN,  depN,  rels,  h,  dh,  rh,  jh,  l,  e;

    pcpH := CanonicalPcp( Pcp( H ) );
    pcpN := CanonicalPcp( Pcp( U ) );
    depN := List( pcpN, Depth );
    rels := [];

    # first get generators and relative orders
    for h in pcpH do
        dh := Depth( h );
        rh := RelativeOrder( h );
        jh := Position( depN, dh );
        if IsBool( jh ) then
            Add( rels, rh );
            if not IsInt( rh ) then return rh; fi;
        elif IsInt( rh ) then
            Add( rels, rh / RelativeOrder( pcpN[jh] ) );
        else
            l := LeadingExponent( h );
            e := LeadingExponent( pcpN[jh] );
            Add( rels, e/l );
        fi;
    od;
    return Product( rels );
end );

ExponentsMod := function( k, reps, pcpN )
    local dep, r, h, d, e, j, g, eg, eh, c;

    dep := List( reps, Depth );
    r   := Length( reps );

    h := ReducedPcpElement( pcpN, k );
    d := Depth( h );
    e := List( [1..r], x -> 0 );
    while d <= Maximum( dep ) do
       
       j := Position( dep, d );
       if IsBool( j ) then return fail; fi;
       g := reps[j];

       eg := LeadingExponent( g );
       eh := LeadingExponent( h );
       c := Gcdex( eg, eh );

       if not c.coeff2 = 0 then return fail; fi;
       e[j] := c.coeff1;

       h := (g^c.coeff3) * (h^c.coeff4);
       h := ReducedPcpElement( pcpN, h );
       d := Depth( h );
    od;
    return e;
end;

InstallMethod( FactorGroupNC, true, [IsPcpGroup, IsPcpGroup], 0,
function( H, N )
    local   pcpH,  pcpN,  depN,  pcpF,  rels,  reps,  h,  dh,  rh,  
            jh,  rg,  l,  e,  n,  coll,  i,  g,  w,  j;

    if not IsNormal( H, N ) then return fail; fi;
    if not IsSubgroup( H, N ) then H := ClosureGroup( H, N ); fi;
    
    pcpH := CanonicalPcp( Pcp( H ) );
    pcpN := CanonicalPcp( Pcp( N ) );
    depN := List( pcpN, Depth );
    pcpF := [];
    rels := [];
    reps := [];

    # first get generators and relative orders
    for h in pcpH do
        dh := Depth( h );
        rh := RelativeOrder( h );
        jh := Position( depN, dh );
        if IsBool( jh ) then
            Add( rels, rh );
            Add( reps, ReducedPcpElement( pcpN, h ) );
        elif IsInt( rh ) then
            rg := RelativeOrder( pcpN[jh] );
            if rg <> rh then
                Add( rels, rh / rg );
                Add( reps, ReducedPcpElement( pcpN, h ) );
            fi;
        else
            l := LeadingExponent( h );
            e := LeadingExponent( pcpN[jh] );
            if l <> e then
                Add( rels, e/l );
                Add( reps, ReducedPcpElement( pcpN, h ) );
            fi;
        fi;
    od;

    # write down a presentation
    n := Length( rels );
    coll := FromTheLeftCollector( n );

    for i in [1..n] do
        if IsInt( rels[i] ) then
            SetRelativeOrder( coll, i, rels[i] );
            g := reps[i] ^ rels[i];
            e := ExponentsMod( g, reps, pcpN );
            w := WordByVector( e );
            SetPower( coll, i, w );
        fi;
        for j in [1..i-1] do
            g := Comm( reps[j], reps[i] );
            e := ExponentsMod( g, reps, pcpN );
            w := WordByVector( e );
            SetCommutator( coll, i, j, w );
        od;
    od;
    UpdatePolycyclicCollector( coll );
    return PcpGroupByCollector( coll );
end );
