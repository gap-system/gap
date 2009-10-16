#############################################################################
##
## AddToInducedPcp( indpcp, gens )
##
AddToInducedPcp := function( indpcp, gens )
    local pcp, rels, todo, n, ind, g, d, h, k, eg, eh, e, id, f, c, i;

    if Length( gens ) = 0 then return indpcp; fi;

    pcp  := Collector( gens[1] );
    rels := RelativeOrders( pcp );
    n    := Length( PcgsOfPcp( pcp ) );
    ind  := List( [1..n], x -> false );
    id   := OneOfPcp( pcp );
    todo := Filtered( gens, x -> x <> id );
    for g in indpcp do ind[Depth(g)] := g; od;
    
    # set counter
    c := n+1;
    i := n;
    while not IsBool( ind[i] ) do
        c := i;
        i := i - 1;
    od;

    while Length( todo ) > 0 and c > 1 do
        g := todo[Length( todo )];
        d := Depth( g );
        f := false;

        # shift g into ind
        while d <= n do
            h := ind[d];
            if not IsBool( h ) then
                eg := LeadingExponent( g );
                eh := LeadingExponent( h );
                e  := Gcdex( eg, eh );
                k  := (g^e.coeff3) * (h^e.coeff4);
                ind[d] := (g^e.coeff1) * (h^e.coeff2);
                if e.coeff1 <> 0 then f := true; fi;
                g := k;
                d := Depth( g );
            else
                ind[d] := g;
                d := n+1;
                f := true;
                if c = d+1 then c := d; fi;
            fi;
        od;

        # add powers and commutators
        g := todo[Length( todo )];
        Unbind( todo[Length(todo)] );

        if f then
            if IsBound( rels[d] ) then
                k := g ^ RelativeOrder( g );
                d := Depth( k );
                if d < c then Add( todo, k ); fi;
            fi;
            for h in ind do
                if not IsBool( h ) then 
                    k := ((h*g)^-1) * (g*h);
                    d := Depth( k );
                    if d < c then Add( todo, k ); fi;
                fi;
            od;
        fi;
    od;
    return Filtered( ind, x -> not IsBool( x ) );
end;

#############################################################################
##
## InducedPcp( gens )
##
InducedPcp := function( gens )
    return AddToInducedPcp( [], gens );
end;

#############################################################################
##
## ReducedPcpElement
##
ReducedPcpElement := function( pcgs, g )
    local dep, d, j, eg, eh, e;

    dep := List( pcgs, Depth );
    d   := Depth( g );
    j   := Position( dep, d );
    while not IsBool( j ) do
        eg := LeadingExponent( g );
        eh := LeadingExponent( pcgs[j] );
        e  := Gcdex( eg, eh );
        if not e.coeff1 = 0 then return g; fi;
        g  := (g^e.coeff3) * (pcgs[j]^e.coeff4);
        d  := Depth( g );
        j  := Position( dep, d );
    od;
    return g;
end;

#############################################################################
##
## CanonicalPcp
##
CanonicalPcp := function( gens )
    local ind, pcp, can, i, e, j, l, d, r;

    if Length( gens ) = 0 then return []; fi;
    ind := InducedPcp( gens );
    pcp := Collector( gens[1] );

    # first norm leading coefficients
    can := List( ind, x -> NormedPcpElement( x ) );

    # reduce entries in matrix
    for i in [1..Length(can)] do
        e := LeadingExponent( can[i] );
        d := Depth( can[i] );
        for j in [1..i-1] do
            l := Exponents( can[j] )[d];
            if l <> 0 then
                r := QuoInt( l, e );
                can[j] := can[j] * can[i]^-r;
            fi;
        od;
    od;
    return can;
end;

#############################################################################
##
## InducedPcpParallel( gens, pre )
##
InducedPcpParallel := function( gens, pre )
    local   pcp,  rels,  n,  id,  ind,  indd,  todo,  tododo,  g,  gg,  
            d,  changed,  h,  hh,  eg,  eh,  e,  k,  kk;

    if Length( gens ) = 0 then return []; fi;

    pcp  := Collector( gens[1] );
    rels := RelativeOrders( pcp );
    n    := Length( PcgsOfPcp( pcp ) );
    id   := OneOfPcp( pcp );
    
    ind  := List( [1..n], x -> false );
    indd := List( [1..n], x -> false );
    
    todo   := ShallowCopy( gens );
    tododo := ShallowCopy( pre );

    while Length( todo ) > 0 do
        g := todo[Length( todo )];   gg := tododo[Length( tododo )];
        d := Depth( g );

#        Print("insert generator ",g,"\n");
        # shift g into ind
        changed := false;
        while d <= n do
#            Print(" at depth ",d,"\n");
            h := ind[d];
            hh := indd[d];
            if not IsBool( h ) then
                eg := LeadingExponent( g );
                eh := LeadingExponent( h );
                e  := Gcdex( eg, eh );
                
                k  := (g^e.coeff3) * (h^e.coeff4);
                ind[d] := (g^e.coeff1) * (h^e.coeff2);
                if e.coeff1 <> 0 then changed := true; fi;
                g := k;
                
                kk  := (gg^e.coeff3) * (hh^e.coeff4);
                indd[d] := (gg^e.coeff1) * (hh^e.coeff2);
                gg := kk;
                
                d := Depth( g );
            else
                ind[d] := g;
                indd[d] := gg;
                changed := true;
                d := n+1;
            fi;
        od;
        
        g := todo[Length( todo )];        Unbind( todo[Length(todo)] );
        gg := tododo[Length( tododo )];   Unbind( tododo[Length(tododo)] ); 
        
        if changed then
            # add powers and commutators
            if IsBound( rels[d] ) then
                k  := g ^ RelativeOrder( g ); kk := gg^ RelativeOrder( g );
                if k <> id or kk <> id then
                    Add( todo, k ); Add( tododo, kk );
                fi;
            fi;
            for h in ind do
                if not IsBool( h ) then 
                    k := ((h*g)^-1) * (g*h);
                    kk := ((h*gg)^-1) * (gg*h);
                    if k <> id or kk <> id then
                        Add( todo, k ); Add( tododo, kk );
                    fi;
                fi;
            od;
        fi;
            
    od;
    
    return [ Filtered( ind, x -> not IsBool( x ) ),
             Filtered( indd, x -> not IsBool( x ) ) ];
end;

NormedPcpElementParallel := function( g, gg )
    local c, r, d, l, e, f;

    c := Collector( g );
    r := RelativeOrders( c );
    d := Depth( g );
    l := LeadingExponent( g );
    if not IsBound( r[d] ) then 
        if l < 0 then 
            return [ g^-1, gg^-1 ];
        else
            return [ g, gg ]; 
        fi;
    fi;

    e := Gcd( r[d], l );
    f := (l/e )^-1 mod (r[d] / e);

    return [ g^f, gg^f ];
end;

#############################################################################
##
## CanonicalPcp
##
CanonicalPcpParallel := function( gens, pre )
    local   can,  cann,  pcp,  i,  pair,  e,  j,  l,  d,  r;

    if Length( gens ) = 0 then return []; fi;
    
    can  := InducedPcpParallel( gens, pre );
    cann := can[2]; 
    can  := can[1];
    pcp  := Collector( gens[1] );

    # first norm leading coefficients
    for i in [1..Length(can)] do
        pair := NormedPcpElementParallel( can[i], cann[i] );
        can[i]  := pair[1];
        cann[i] := pair[2];
    od;

    # reduce entries in matrix
    for i in [1..Length(can)] do
        e := LeadingExponent( can[i] );
        r := Depth( can[i] );
        for j in [1..i-1] do
            l := Exponents( can[j] )[r];
            if l <> 0 then
                d := QuoInt( l, e );
                can[j]  := can[j]  * can[i]^-d;
                cann[j] := cann[j] * cann[i]^-d;
            fi;
        od;
    od;
    return[ can, cann ];
end;

