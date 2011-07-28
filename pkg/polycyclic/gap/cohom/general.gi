#############################################################################
##
#W  general.gi                   Polycyc                         Bettina Eick
##
##  General stuff for cohomology computations.
##

#############################################################################
##
#F CollectedOneCR( A, w ) . . . . . . . . . . . . . . . . . . . . . comb word
##
CollectedOneCR := function( A, w )
    local tail, t, i, j, mat;

    tail := [];
    t    := A.one;

    for i in Reversed( [1..Length(w)] ) do
        if w[i][2] > 0 then
            for j in [1..w[i][2]] do

                # first add tail
                if IsBound( tail[w[i][1]] ) then
                    tail[w[i][1]] := tail[w[i][1]] + t;
                else
                    tail[w[i][1]] := t;
                fi;

                # push next generator
                if not IsBound( A.central) or not A.central then
                    t := A.mats[w[i][1]] * t;
                fi;
            od;
        else
            for j in [1..-w[i][2]] do

                # push next generator
                if not IsBound( A.central) or not A.central then
                    t := A.invs[w[i][1]] * t;
                fi;

                # first add tail
                if IsBound( tail[w[i][1]] ) then
                    tail[w[i][1]] := tail[w[i][1]] - t;
                else
                    tail[w[i][1]] := -t;
                fi;
            od;
        fi;
    od;

    return tail;
end;


#############################################################################
##
#F BinaryPowering( A, m, e ) . . . . . . . . . .compute 1 + m + ... + m^(e-1)
##                                              and     m^e
##
BinaryPowering := function( A, m, e )
    local l, p, i, r, c;

    if IsBound(A.central) and A.central then return [e * A.one, A.one]; fi;

    # set up for binary powers approach
    l := Log( e, 2 );
    p := [m];
    for i in [1..l] do Add( p, p[i]^2 ); od; 
    
    # compute binary powers
    r := ShallowCopy( A.one );
    for i in [1..e-1] do
        c := CoefficientsQadic( i, 2 );
        c := MappedVector( c, p{[1..Length(c)]} );
        r := r + c;
    od;

    # compute final power
    c := CoefficientsQadic( e, 2 );
    c := MappedVector( c, p );
  
    return [r, c];
end;

#############################################################################
##
#F CollectedOneCR( A, w ) . . . . . . . . . . . . . . . . . . . . . comb word
##
CollectedOneCRNew := function( A, w )
    local tail, t, i, j, r;

    tail := [];
    t    := A.one;

    for i in Reversed( [1..Length(w)] ) do
        if w[i][2] > 0 then

            # compute 1 + m + ... + m^(e-1)
            r := BinaryPowering( A, A.mats[w[i][1]], w[i][2] );

            # add derivation to tail
            if IsBound( tail[w[i][1]] ) then
                tail[w[i][1]] := tail[w[i][1]] + r[1] * t;
            else
                tail[w[i][1]] := r[1] * t;
            fi;
 
            # adjust tail
            t := r[2] * t;
        else
    
            # compute l + l^2 + ... + l^e
            r := BinaryPowering( A, A.invs[w[i][1]], -w[i][2] );
            r[1] := A.invs[w[i][1]] * r[1];

            # add derivation to tail
            if IsBound( tail[w[i][1]] ) then
                tail[w[i][1]] := tail[w[i][1]] - r[1] * t;
            else
                tail[w[i][1]] := - r[1] * t;
            fi;

            # adjust tail
            t := r[2] * t;
        fi;
    od;

    if tail <> CollectedOneCR( A, w ) then Error("tails"); fi;

    return tail;
end;

#############################################################################
##
#F CollectedRelatorCR( A, i, j )
##
CollectedRelatorCR := function( A, i, j )
    local a, b, e, taila, tailb;

    # get the word
    e := RelativeOrdersOfPcp( A.factor )[i];
    a := A.relators[i][j];
    if i = j then
        b := [[i,e]];
    elif j < i then
        b := [[i,1], [j,1]];
        a := Concatenation( [[j,1]], a );
    else
        b := [[i,1], [j-i,-1]];
        a := Concatenation( [[j-i,-1]], a );
    fi;

    # create tails
    taila := CollectedOneCR( A, a );
    tailb := CollectedOneCR( A, b );

    return [taila, tailb];
end;

#############################################################################
##
#F AddTailVectorsCR( t1, t2 )
##
AddTailVectorsCR := function( t1, t2 )
    local i;
    for i  in [ 1 .. Length(t2) ]  do
        if IsBound(t2[i])  then
            if IsBound(t1[i])  then
                t1[i] := t1[i] + t2[i];
            else
                t1[i] := t2[i];
            fi;
        fi;
    od;
end;

#############################################################################
##
#F CutVector( vec, l ) . . . . . . . . . . . . . . . . cut vector in l pieces
##
CutVector := function( vec, l )
    local d, new, i;
    if Length( vec ) = 0 then return []; fi;
    d := Length(vec)/l;
    new := [];
    for i in [1..l] do
        Add( new, vec{[d*(i-1)+1..d*i]} );
    od;
    return new;
end;

#############################################################################
##
#F IntVector( vec )
##
IntVector := function( vec )
    local i;
    if Length( vec ) = 0 then return []; fi;
    vec := ShallowCopy( vec );
    for i in [1..Length(vec)] do
        if IsFFE( vec[i] ) then vec[i] := IntFFE( vec[i] ); fi;
    od;
    return vec;
end;

