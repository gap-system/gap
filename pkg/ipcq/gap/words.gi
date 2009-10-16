#############################################################################
##
#W  words.gi                     ipcq package                    Bettina Eick
##
#W  This file contains helper functions to deal with `symbolic tails'.
#W  A tail is a list t1, ..., tl and each ti is a word in the group
#W  algebra ZP. Each such word is represented by a list of the type
#W  [[a1, g1], ..., [an, gn]] which denotes a1*g1 + ... + an*gn where
#W  ai in Z and gi in P. In this case the elements gi are represented
#W  by elements from P. 
#W
#W  Further, an element from P can also be represented as glist or as
#W  exponentvector. These two representations are used by the symbolic 
#W  collector and this file contains methods to compute with them.
#W

#############################################################################
##
#F GlistOfVector( v )
##
GlistOfVector := function( v )
    local w, i;
    w := [];
    for i in [1..Length(v)] do
        if v[i] <> 0 then Add( w, [i, v[i]] ); fi;
    od;
    return w;
end;

#############################################################################
##
#F VectorOfGlist( v, n )
##
VectorOfGlist := function( glist, n )
    local e, w;
    e := List( [1..n], x -> 0 );
    for w in glist do e[w[1]] := w[2]; od;
    return e;
end;

#############################################################################
##
#F Glist( v )
##
Glist := function( v )
    return rec( word := GlistOfVector( v.word ), 
                tail := StructuralCopy( v.tail ) );
end;

#############################################################################
##
#F InvertGlist( r )
##
InvertGlist := function( r )
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
#F PowerGlist( r, e )
##
PowerGlist := function( r, e )
    local l;
    if Length( r ) = 1 then
        return [[ r[1][1], e * r[1][2]] ];
    elif e = 1 then
        return ShallowCopy(r);
    elif e > 0 then
        return Concatenation( List( [1..e], x -> r ) );
    elif e = -1 then
        return InvertGlist( r );
    elif e < 0 then
        l := InvertGlist( r );
        return Concatenation( List( [1..-e], x -> l ) );
    fi;
end;

#############################################################################
##
#F AddWords( w1, w2 )
##
AddWords := function( w1, w2 )
    local j, i, w;
    for j in [1..Length(w2)] do
        i := PositionProperty( w1, x -> x[2] = w2[j][2] );
        if not IsBool( i ) then 
            w1[i][1] := w1[i][1] + w2[j][1];
        else
            w1[Length(w1)+1] := w2[j];
        fi;
    od;
end;

#############################################################################
##
#F AddMats( w1, w2 )
##
AddMats := function( w1, w2 )
    local i, j, d;
    d := Length( w1 );
    for i in [1..d] do
        for j in [1..d] do
            w1[i][j] := w1[i][j] + w2[i][j];
        od;
    od;
end;

#############################################################################
##
#F AddTails( t1, t2, flag ) . . . . . . . . . . . . . . . . . . . . . t1 + t2
##
AddTails := function( t1, t2, flag )
    local i;
    
    if not flag then
        for i  in [ 1 .. Length(t2) ]  do
            if IsBound(t2[i])  then
                if IsBound(t1[i])  then
                    AddMats( t1[i], t2[i] );
                else
                    t1[i] := t2[i];
                fi;
            fi;
        od;
    else
        for i  in [ 1 .. Length(t2) ]  do
            if IsBound(t2[i])  then
                if IsBound(t1[i])  then
                    AddWords( t1[i], t2[i] );
                else
                    t1[i] := t2[i];
                fi;
            fi;
        od;
    fi;
end;

#############################################################################
##
#F MultTail( M, t, h, ) . . . . . . . . . . . . . . . . . . . . . . . t * h
##
MultTail := function( M, t, h )
    local i, j;

    if IsBound( M.central ) then return; fi;

    if not M.word then
        for i  in [ 1 .. Length(t) ]  do
            if IsBound(t[i])  then
                t[i] := t[i] * h;
            fi;
        od;
    else
        for i  in [ 1 .. Length(t) ]  do
            if IsBound(t[i])  then
                for j in [1..Length(t[i])] do
                    t[i][j][2] := t[i][j][2] * h;
                od;
            fi;
        od;
    fi;
end;

#############################################################################
##
#F SubtractWords( w1, w2 )
##
SubtractWords := function( w1, w2 )
    local j, i, w;
    for j in [1..Length(w2)] do
        i := PositionProperty( w1, x -> x[2] = w2[j][2] );
        if not IsBool( i ) then
            w1[i][1] := w1[i][1] - w2[j][1];
        else
            w1[Length(w1)+1] := [-w2[j][1], w2[j][2]];
        fi;
    od;
end;

#############################################################################
##
#F SubtractTails( t1, t2, flag ). . . . . . . . . . . . . . . . . . . t1 - t2
##
SubtractTails := function( t1, t2, flag )
    local i;

    if not flag then
        for i  in [ 1 .. Length(t2) ]  do
            if IsBound(t2[i])  then
                if not IsBound(t1[i]) then t1[i] := 0; fi;
                t1[i] := t1[i] - t2[i];
            fi;
        od;
    else
        for i  in [ 1 .. Length(t2) ]  do
            if IsBound(t2[i])  then
                if not IsBound(t1[i])  then t1[i] := []; fi;
                SubtractWords( t1[i], t2[i] );
            fi;
        od;
    fi;
end;

#############################################################################
##
#F MappedPcpWord( pcpelm, gens, invs )
##
MappedPcpWord := function( w, gens, invs )
    local a, e, i;
    a := gens[1]^0;
    e := Exponents( w );
    for i in [1..Length(e)] do
        if e[i] < 0 then
            a := a * invs[i]^-e[i]; 
        elif e[i] > 0 then
            a := a * gens[i]^e[i]; 
        fi;
    od;
    return a;
end;

#############################################################################
##
#F AddDerivationTail( M, tail, s, m, w ) 
##
AddDerivationTail := function( M, tail, s, m, w )
    local t, a, i;

    # w should not be 0
    if w = 0 then return fail; fi;

    # the central case
    if IsBound( M.central ) and not M.word then 
        t := w * M.gens[1]^0;
        if IsBound( tail[s] ) then 
            tail[s] := tail[s] + t;
        else
            tail[s] := t;
        fi;
        return tail;
    fi;

    # the central case
    if IsBound( M.central ) and M.word then
        t := [[w, M.gens[1]^0]];
        if IsBound( tail[s] ) then
            AddWords( tail[s], t );
        else
            tail[s] := t;
        fi;
        return tail;
    fi;

    # the matrix case
    if not M.word then 
        if w < 0 then m := m^-1; fi;
        m := MappedPcpWord( m, M.gens, M.invs ); 
        if w < 0 then a := -m; else a := m^0; fi;
        t := a;
        for i in [1..AbsInt(w)-1] do
            a := a * m;
            t := t + a;
        od;
        if IsBound( tail[s] ) then 
            tail[s] := tail[s] + t;
        else
            tail[s] := t;
        fi;
        return tail;
    fi;
    
    # the word case
    if M.word then 
        if w < 0 then m := m^-1; fi;
        if w < 0 then 
            a := [-1 * One(M.field), m]; 
        else 
            a := [1 * One(M.field), m^0]; 
        fi;
        t := [ShallowCopy(a)];
        for i in [1..AbsInt(w)-1] do
            a[2] := a[2] * m;
            AddWords( t, [a] );
            #t[i+1] := ShallowCopy( a );
        od;
        if IsBound( tail[s] ) then
            AddWords( tail[s], t );
        else
            tail[s] := t;
        fi;
        return tail;
    fi;
end;
