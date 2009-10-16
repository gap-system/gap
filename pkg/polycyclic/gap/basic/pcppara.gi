#############################################################################
##
#W  pcppara.gi                   Polycyc                         Bettina Eick
#W                                                              Werner Nickel
##
## Parallel versions of the non-commuatative gauss algorithm.
##

#############################################################################
##
#F UpdateCounterPara( ind, c )  . . . . . . . . . . . . small help function
##
UpdateCounterPara := function( ind, c )
    local i;
    i := c - 1;
    while i > 0 and not IsBool(ind[i]) and LeadingExponent(ind[i]) = 1 do
        i := i - 1;
    od;
    return i + 1;
end;


#############################################################################
##
#F AddToIgsParallel( <pcs>, <gens>, <ppcs>, <pgens> )
##
## This function adds the elements in <gens> to the induced pcs <pcs>. 
## It acts simultaneously on <pcs> and <ppcs> as well as <gens> and <pgens>.
##
InstallGlobalFunction( AddToIgsParallel, 
function( pcs, gens, ppcs, pgens )
    local coll, rels, n, id, todo, tododo, ind, indd, g, gg, d, h, hh, k, 
          eg, eh, e, changed, c, i, r, sub;

    if Length( gens ) = 0 then return [pcs, ppcs]; fi;

    # get information
    coll := Collector( gens[1] );
    rels := RelativeOrders( coll );
    n    := NumberOfGenerators( coll );
    id   := gens[1]^0;

    # create new list from pcs/ppcs
    ind  := List( [1..n], x -> false );
    indd := List( [1..n], x -> false );
    for i in [1..Length(pcs)] do
        d := Depth( pcs[i] );
        ind[d]  := pcs[i];
        indd[d] := ppcs[i];
    od;

    # set counter
    c := UpdateCounterPara( ind, n+1 );

    # create a to-do list from gens/pgens
    sub   := Filtered( [1..Length(gens)], x -> Depth(gens[x]) < c );
    todo  := gens{sub};
    tododo:= pgens{sub};
    
    # loop over to-do list until it is empty
    while Length( todo ) > 0 and c > 1 do
        g  := todo[Length(todo)];
        gg := tododo[Length(todo)];
        d  := Depth( g );
        Unbind( todo[Length(todo)] );
        Unbind( tododo[Length(tododo)] );

        # shift g into ind
        changed := [];
        while d < c do
            h  := ind[d];
            hh := indd[d];
            if not IsBool( h ) then

                # reduce g with h
                eg := LeadingExponent( g );
                eh := LeadingExponent( h );
                e  := Gcdex( eg, eh );

                # adjust ind[d] by gcd
                ind[d]  := (g^e.coeff1) * (h^e.coeff2);
                indd[d] := (gg^e.coeff1) * (hh^e.coeff2);
                if e.coeff1 <> 0 then Add( changed, d ); fi;

                # adjust g
                g  := (g^e.coeff3) * (h^e.coeff4);
                gg := (gg^e.coeff3) * (hh^e.coeff4);
            else

                # just add g into ind
                ind[d]  := g;
                indd[d] := gg;
                g  := g^0;
                gg := gg^0;
                Add( changed, d );
            fi;
            c := UpdateCounterPara( ind, c );
            d := Depth( g );
        od;

        for d in changed do
            g := ind[d];
            gg := indd[d];
            if d <= Length( rels ) and rels[d] > 0 then
                r := RelativeOrderPcp( g );
                k := g ^ r;
                if Depth(k) < c then  
                    Add( todo, k ); 
                    Add( tododo, gg^r );
                fi;
            fi;
            for i in [1..Length(ind)] do
                if not IsBool( ind[i] ) then
                    k := Comm( g, ind[i] );
                    if Depth(k) < c then  
                        Add( todo, k ); 
                        Add( tododo, Comm( gg, indd[i] ) );
                    fi;
                fi;
            od;
        od;
    od;

    # return resulting list
    return [Filtered( ind, x -> not IsBool( x ) ),
            Filtered( indd, x -> not IsBool( x ) ) ];
end );

#############################################################################
##
## IgsParallel( <gens>, <pre> )
##
InstallGlobalFunction( IgsParallel, function( gens, pre )
    return AddToIgsParallel( [], gens, [], pre );
end );

#############################################################################
##
## CgsParallel( <gens>, <pre> )
##
## parallel version of Cgs. Note: this function performes an
## induced pcs computation as well.
##
InstallGlobalFunction( CgsParallel, function( gens, pre )
    local   can,  cann,  i,  f,  e,  j,  l,  d,  r, s;

    if Length( gens ) = 0 then return []; fi;
    
    can  := IgsParallel( gens, pre );
    cann := can[2]; 
    can  := can[1];

    # first norm leading coefficients
    for i in [1..Length(can)] do
        f := NormingExponent( can[i] );
        can[i]  := can[i]^f;
        cann[i] := cann[i]^f;
    od;

    # reduce entries in matrix
    for i in [1..Length(can)] do
        e := LeadingExponent( can[i] );
        r := Depth( can[i] );
        for j in [1..i-1] do
            l := Exponents( can[j] )[r];
            if l > 0 then
                d := QuoInt( l, e );
                can[j]  := can[j]  * can[i]^-d;
                cann[j] := cann[j] * cann[i]^-d;
            elif l < 0 then
                d := QuoInt( -l, e );
                s := RemInt( -l, e );
                if s = 0 then
                    can[j] := can[j] * can[i]^d;
                    cann[j] := cann[j] * cann[i]^d;
                else
                    can[j] := can[j] * can[i]^(d+1);
                    cann[j] := cann[j] * cann[i]^(d+1);
                fi;

            fi;
        od;
    od;
    return[ can, cann ];
end );
