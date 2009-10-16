#############################################################################
##
#W  cohom.gi                     Polycyc                         Bettina Eick
##
##  Defining a module for the cohomology functions.
##

#############################################################################
##
#F WordOfVectorCR( v )
##
WordOfVectorCR := function( v )
    local w, i;
    w := [];
    for i in [1..Length(v)] do
        if v[i] <> 0 then Add( w, [i, v[i]] ); fi;
    od;
    return w;
end;

#############################################################################
##
#F VectorOfWordCR( w, n )
##
VectorOfWordCR := function( w, n )
    local v, t;
    v := List( [1..n], x -> 0 );
    for t in w do v[t[1]] := t[2]; od;
    return v;
end;

#############################################################################
##
#F MappedWordCR( w, gens, invs )
##
MappedWordCR := function( w, gens, invs )
    local e, v;
    e := gens[1]^0;
    for v in w do 
        if v[2] > 0 then 
            e := e * gens[v[1]]^v[2]; 
        elif v[2] < 0 then
            e := e * invs[v[1]]^-v[2]; 
        fi;
    od;
    return e;
end;

#############################################################################
##
#F ExtVectorByRel( A, g, rel )
##
## A is a G-module and this function determines the extension of G by A.
##
ExtVectorByRel := function( A, g, rel )
    local b;

# the following is buggy
#    # check if we can read it off
#    if Depth( A.factor[Length(A.factor)] ) < Depth( A.normal[1] ) and
#       IsList( A.factor!.tail ) and IsList( A.normal!.tail ) then
#        return ExponentsByPcp( A.normal, g );
#    fi;

    # otherwise compute
    b := MappedWordCR( rel, A.factor, List(A.factor, x -> x^-1) );
    return ExponentsByPcp( A.normal, b^-1 * g );
end;

#############################################################################
##
#F AddRelatorsCR( A )
##
AddRelatorsCR := function( A )
    local pcp, rels, n, r, c, e, i, j, a, b;
    
    # if they are known return
    if IsBound( A.relators ) then return; fi;

    # add relators
    pcp  := A.factor;
    rels := RelativeOrdersOfPcp( pcp );
    n    := Length( pcp );

    r := [];
    c := [];
    e := [];
    for i in [1..n] do
        r[i] := [];
        if rels[i] > 0 then
            a := pcp[i]^rels[i];
            r[i][i] := ExponentsByPcp( pcp, a );
            r[i][i] := WordOfVectorCR( r[i][i] );
            Add( c, [i,i] );
            if IsBound( A.normal ) then
                Add( e, ExtVectorByRel( A, a, r[i][i] ) );
            fi;
        fi;
        for j in [1..i-1] do
            a := pcp[i] ^ pcp[j];
            r[i][j] := ExponentsByPcp( pcp, a );
            r[i][j] := WordOfVectorCR( r[i][j] );
            Add( c, [i,j] );
            if IsBound( A.normal ) then
                Add( e, ExtVectorByRel( A, a, r[i][j] ) );
            fi;

            a := pcp[i] ^ (pcp[j]^-1);
            r[i][i+j] := ExponentsByPcp( pcp, a );
            r[i][i+j] := WordOfVectorCR( r[i][i+j] );
            Add( c, [i, i+j] );
            if IsBound( A.normal ) then
                Add( e, ExtVectorByRel( A, a, r[i][i+j] ) );
            fi;
        od;
    od;

    A.enumrels := c;
    A.relators := r;
    if IsBound( A.normal ) and A.char > 0 then 
        A.extension := e * One( A.field ); 
    elif IsBound( A.normal ) then
        A.extension := e;
    fi;
end;
    
#############################################################################
##
#F InvertWord( r )
##
InvertWord := function( r )
    local l, i;
    l := Reversed( r );
    for i in [1..Length(l)] do
        l[i] := ShallowCopy( l[i] );
        l[i][2] := -l[i][2];
    od;
    return l;
end;

#############################################################################
##
#F PowerWord( A, r, e )
##
PowerWord := function( A, r, e )
    local l;
    if Length( r ) = 1 then 
        return [[ r[1][1], e * r[1][2]] ];
    elif e = 1 then 
        return ShallowCopy(r);
    elif e > 0 then 
        return Concatenation( List( [1..e], x -> r ) );
    elif e = -1 then
        return InvertWord( r );
    elif e < 0 then 
        l := InvertWord( r );
        return Concatenation( List( [1..-e], x -> l ) );
    fi;
end;

#############################################################################
##
#F PowerTail( A, r, e )
##
PowerTail := function( A, r, e )
    local t, m, i;

    # catch special case
    if e = 1 then return A.one; fi;

    # derivative of r^e
    if e > 1 then
        m := MappedWordCR( r, A.mats, A.invs );
        t := A.one;
        for i in [1..e-1] do t := t * m + A.one; od;
    elif e < 0 then 
        m := MappedWordCR( InvertWord(r), A.mats, A.invs );
        t := -m;
        for i in [1..-e-1] do t := (t - A.one)*m; od;
    fi;
    return t;
end;

#############################################################################
##
#F AddOperationCR( A )
##
AddOperationCR := function( A )

    # add operation of factor on normal
    if not IsBound( A.mats ) then 
        A.mats := List( A.factor, x -> 
                  List( A.normal, y -> ExponentsByPcp( A.normal, y^x )));
        if A.char > 0 then A.mats := A.mats * One( A.field ); fi;
    fi;

    # add operation of oper on normal
    if IsBound( A.super ) then
        if not IsBound( A.smats ) then 
            A.smats := List( A.super, x -> 
                       List( A.normal, y -> ExponentsByPcp( A.normal, y^x )));
            if A.char > 0 then A.smats := A.smats * One( A.field ); fi;
        fi;
    fi;
end;

#############################################################################
##
#F AddInversesCR( A )
##
## Invert A.mats and A.smats. Additionally check centrality.
##
AddInversesCR := function( A )
    local cent, i;

    cent := true;
    A.invs  := List( A.mats,  x -> A.one );
    for i in [1..Length(A.mats)] do
        if A.mats[i] <> A.one then
            cent := false;
            A.invs[i] := A.mats[i]^-1;
        fi;
    od;
    A.central := cent;
   
    if IsBound( A.super ) then
        A.sinvs := List( A.smats, x -> A.one );
        for i in [1..Length(A.smats)] do
            if A.smats[i] <> A.one then
                A.sinvs[i] := A.smats[i]^-1;
            fi;
        od;
    fi;
end;

#############################################################################
##
#F AddFieldCR( A )
##
AddFieldCR := function( A )
    A.char := RelativeOrdersOfPcp( A.normal )[1];
    A.dim  := Length( A.normal );
    A.one  := IdentityMat( A.dim );
    if A.char > 0 then 
        A.field := GF( A.char ); 
        A.one := A.one * One( A.field );
    fi;
end;

#############################################################################
##
#F CRRecordByMats( G, mats )
##
InstallGlobalFunction( CRRecordByMats, function( G, mats ) 
    local p, cr;

    if Length( mats ) <> Length(Pcp(G)) then 
        Error("wrong input in CRRecord");
    fi;
    if IsInt(mats[1][1][1]) then p := 0;
    else p := Characteristic( Field( mats[1][1][1] ) );
    fi;
    cr :=  rec( factor := Pcp( G ),
                mats   := mats,
                dim    := Length( mats[1] ),
                one    := mats[1]^0,
                char   := p );
    if cr.char > 0 then cr.field := GF( cr.char ); fi;
    AddRelatorsCR( cr );
    AddInversesCR( cr );
    return cr;
end );

#############################################################################
##
#F CRRecordBySubgroup( G, N )
##
CRRecordBySubgroup := function( G, N )
    local A;

    # set up record
    A := rec( group  := G, 
              factor := Pcp( G, N ),
              normal := Pcp( N, "snf" ) );

    AddFieldCR( A );
    AddRelatorsCR( A );
    AddOperationCR( A );
    AddInversesCR( A );
    return A;
end;

#############################################################################
##
#F CRRecordByPcp( G, pcp )  
##
CRRecordByPcp := function( G, pcp )
    local A;

    # set up record
    A := rec( group  := G,
              factor := Pcp( G, GroupOfPcp( pcp ) ),
              normal := pcp );

    AddFieldCR( A );
    AddRelatorsCR( A );
    AddOperationCR( A );
    AddInversesCR( A );
    return A;
end;


#############################################################################
##
#F CRRecordWithAction( G, U, pcp )
##
CRRecordWithAction := function( G, U, pcp )
    local A;

    # set up record
    A := rec( group  := U,
              super  := Pcp( G, U ),
              factor := Pcp( U, GroupOfPcp(pcp) ),
              normal := pcp );

    AddFieldCR( A );
    AddRelatorsCR( A );
    AddOperationCR( A );
    AddInversesCR( A );
    return A;
end;

