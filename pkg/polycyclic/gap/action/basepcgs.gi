#############################################################################
##
#W  basepcgs.gi                                                  Bettina Eick
##
#W  A base pcgs is a pcgs with attached base and strong generating set.
#W  It is a record consisting of: 
#W    .orbit and .trans and .trels - the base and strong gen set
#W    .acton and .oper  and .trivl - the domain to act on and the action
#W    .pcref                       - the reference to a pcgs
##

#############################################################################
##
#F  BasePcgsByPcSequence( pcs, dom, trv, oper )
##
##  pcs is a sequence of normalizing elements, dom is the domain they act
##  on, trv is a function to decide when an element is trivial, oper is the
##  operation of pcs on dom. (If trv is boolean, then a standard trv function
##  is used.)
##
BasePcgsByPcSequence := function( pcs, dom, trv, oper )
    local pcgs, i;
    if IsBool( trv ) then trv := function( x ) return x = x^0; end; fi;
    pcgs := rec( orbit := [], trans := [], trels := [], defns := [],
                 pcref := [], 
                 acton := dom, oper := oper, trivl := trv );
    for i in Reversed( [1..Length(pcs)] ) do
        ExtendedBasePcgs( pcgs, pcs[i], [i,1] );
    od;
    return pcgs;
end;

#############################################################################
##
#F BasePcgsByPcFFEMatrices( gens )
##
BasePcgsByPcFFEMatrices := function( gens )
    local f, d, pcgs;

    # triviality check
    if Length(gens) = 0 then
        return BasePcgsByPcSequence( gens, false, false, OnRight );
    fi;

    # set up
    f := Field( gens[1][1][1] );
    d := Length( gens[1] );

    # compute pcgs, add preimages and return
    pcgs := BasePcgsByPcSequence( gens, f^d, false, OnRight );
    pcgs.gens := gens;
    return pcgs;
end;

#############################################################################
##
#F BasePcgsByPcIntMatrices( gens, f )
##
BasePcgsByPcIntMatrices := function( gens, f )
    local d, news, pcgs;

    # triviality check
    if Length(gens) = 0 then  
        return BasePcgsByPcSequence( gens, false, false, OnRight );
    fi;
        
    # change field and compute
    d := Length( gens[1] );
    news := InducedByField( gens, f );
    pcgs := BasePcgsByPcSequence( news, f^d, false, OnRight );
    pcgs.gens := gens;
    pcgs.field := f;
    return pcgs;
end;

#############################################################################
##
#F  RelativeOrdersBasePcgs( pcgs )
##
RelativeOrdersBasePcgs := function( pcgs )
    local t;
    if IsBound( pcgs.rels ) then return pcgs.rels; fi;
    pcgs.rels := [];
    for t in Reversed( pcgs.pcref ) do
        Add( pcgs.rels, pcgs.trels[t[1]][t[2]] );
    od;
    return pcgs.rels;
end;

#############################################################################
##
#F  PcSequenceBasePcgs( pcgs )
##
PcSequenceBasePcgs := function( pcgs )
    local t;
    if IsBound( pcgs.pcgs ) then return pcgs.pcgs; fi;
    pcgs.pcgs := [];
    for t in Reversed( pcgs.pcref ) do
        Add( pcgs.pcgs, pcgs.trans[t[1]][t[2]] );
    od;
    return pcgs.pcgs;
end;

#############################################################################
##
#F  DefinitionsBasePcgs( pcgs )
##
DefinitionsBasePcgs := function( pcgs )
    local defn, t;
    defn := [];
    for t in Reversed( pcgs.pcref ) do
        Add( defn, pcgs.defns[t[1]][t[2]] );
    od;
    return defn;
end;

#############################################################################
##
#F  GeneratorsBasePcgs( pcgs )
##
GeneratorsBasePcgs := function( pcgs )
    return pcgs.gens;
end;

#############################################################################
##
#F  SiftByBasePcgs( pcgs, g )
##
SiftByBasePcgs := function( pcgs, g )
    local h, w, i, j;
    h := g;
    for i in [1..Length(pcgs.orbit)] do
        j := Position( pcgs.orbit[i], pcgs.oper( pcgs.orbit[i][1], h ) );
        if IsBool( j ) then return h; fi;
        if j > 1 then
            w := TransWord( j, pcgs.trels[i] );
            h := h * SubsWord( w, pcgs.trans[i] )^-1;
        fi;
    od;
    return h;
end;

#############################################################################
##
#F  SiftExponentsByBasePcgs( pcgs, g )
##
SiftExponentsByBasePcgs := function( pcgs, g )
    local h, w, e, i, j;
    h := g;
    e := List( pcgs.orbit, x -> 0 );
    for i in [1..Length(pcgs.orbit)] do
        if pcgs.trivl( h ) then return e; fi;
        j := Position( pcgs.orbit[i], pcgs.oper( pcgs.orbit[i][1], h ) );
        if IsBool( j ) then return false; fi;
        if j > 1 then
            w := TransWord( j, pcgs.trels[i] );
            h := h * SubsWord( w, pcgs.trans[i] )^-1;
        fi;
        e[i] := j-1;
    od;
    if pcgs.trivl( h ) then return e; fi;
    return false;
end;

#############################################################################
##
#F  BasePcgsElementBySiftExponents( pcgs, exp )
##
BasePcgsElementBySiftExponents := function( pcgs, exp )
    local g, w, i;
    g := pcgs.trans[1][1]^0;
    for i in Reversed( [1..Length(exp)] ) do
        if exp[i] > 0 then
            w := TransWord( exp[i]+1, pcgs.trels[i] );
            g := SubsWord( w, pcgs.trans[i] ) * g;
        fi;
    od;
    return g;
end;

#############################################################################
##
#F  MemberTestByBasePcgs( pcgs, g )
##
MemberTestByBasePcgs := function( pcgs, g )
   return pcgs.trivl( SiftByBasePcgs( pcgs,g ) );
end;

#############################################################################
##
#F  WordByBasePcgs( pcgs, g )
##
WordByBasePcgs := function( pcgs, g )
    local w, h, i, j, t;
    w := List( pcgs.orbit, x -> [] );
    h := g;
    for i in [1..Length(pcgs.orbit)] do
        j := Position( pcgs.orbit[i], pcgs.orbit[i][1] * h );
        if j > 1 then
            t := TransWord( j, pcgs.trels[i] );
            t := List( t, x -> [Position( pcgs.revs, [i,x[1]] ), x[2]] );
            h := h * SubsWord( t, pcgs.pcgs )^-1;
            w[i] := t;
        fi;
    od;
    return Concatenation( Reversed( w ) );
end;

#############################################################################
##
#F  ExponentsByBasePcgs( pcgs, g ) 
##
##  This function gives useful results for abelian groups only.
##
ExponentsByBasePcgs := function( pcgs, g )
    local n, w, e, s;
    n := Length( PcSequenceBasePcgs( pcgs ) );
    w := WordByBasePcgs( pcgs, g );
    e := List( [1..n], x -> 0 );
    for s in w do
        e[s[1]] := e[s[1]] + s[2];
    od;
    return e;
end;

    

