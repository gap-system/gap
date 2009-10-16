
#############################################################################
##
#F StripElement( B, ad, elm, p )
##
StripElement := function( B, ad, elm, p )
   local a, d, s, m;

   # compute adjoint and set up
   a := AdjointMatrix( B, elm );
   d := Length(ad);

   # 1-st step
   a := [a^p];
   s := NullspaceMat( List( Concatenation(ad, a), Flat ) );
   s := Filtered( s, x -> x[d+1] <> 0 * x[d+1] );
   m := 1;

   # m-th step
   while Length(s) = 0 do
       m := m + 1;
       Add( a, a[Length(a)]^p );
       s := NullspaceMat( List( Concatenation(ad, a), Flat ) );
       s := Filtered( s, x -> x[d+m] <> 0 * x[d+m] );
   od;

   # extract result and return
   s := s[1];
   s := s / s[d+m];
   return rec( power := m,
               expon := p^m,
               coeff := s{[d+1..d+m-1]},
               inner := s{[1..d]} );
end;

#############################################################################
##
#F TranslateVector( vec, bT ) . . . . . for checking purposes
##
TranslateVector := function(vec, bT)
    local res, i;
    res := [];
    for i in [1..Length(vec)] do
        if vec[i] <> 0 * vec[i] then Add( res, bT[i] ); fi;
    od;
    return res;
end;

#############################################################################
##
#F WordByExponents( elm ) . . . . . . . .write exponent vector as normal word
## 
WordByExponent := function( elm )
    local w, i;
    w := [];
    for i in [1..Length(elm)] do
        if elm[i] <> 0 * elm[i] then Add( w, [i, elm[i]] ); fi;
    od;
    return w;
end;

#############################################################################
##
#F ExponentsByWord( wor, dim )  . . . .  write normal word as exponent vector
## 
ExponentsByWord := function( wor, dim )
    local e, w;
    e := List( [1..dim], i -> 0 );
    for w in wor do e[w[1]] := w[2]; od;
    return e;
end;

#############################################################################
##
#F PositionBasis( bT, wor ) . . . . . determine position of normal word in bT
## 
PositionBasis := function( bT, wor )
    local e, h;
    e := ExponentsByWord( wor, Length(bT[1]) );
    h := Position( bT, e );
    if IsBool(h) then Error("basis element is not in basis"); fi;
    return h;
end;

#############################################################################
##
#F MultWords( list ) . . . . . . . . . . . . . . . . . multiply words in list
##
## A word is a list [[i1, e1], [i2, e2], ..., [il, el]] describing the 
## element x_{i1}^{e1} * ... * x_{il}^{el}.
##
## Two words are multiplied by concatenation. This function also check if 
## the multiplied word can be reduced by cancellation; that is, if it 
## contains entries with ij = i(j+1).
##
## It is always assumed that all exponents ej are positive. 
## 
MultWord := function( list )
    local s, w, l, i, v;

    # get first non-trivial entry
    s := PositionNot( list, [] );
    if IsBool(s) then return []; fi;
    w := StructuralCopy(list[s]);
    l := Length(w);

    # add the others
    for i in [s+1..Length(list)] do
        v := StructuralCopy(list[i]);
        while Length(v) > 0 and w[l][1] = v[1][1] do
            w[l][2] := w[l][2] + v[1][2];
            v := v{[2..Length(v)]};
        od;
        if Length(v) > 0 then Append( w, v ); l := Length(w); fi;
    od;
    return w;
end;

#############################################################################
##
#F IsNormalWord( w, tau ) . . . . . . . . . . . . . . check if word is normal
##
IsNormalWord := function( w, tau )
    local h, k;

    # check indices
    h := First( [1..Length(w)-1], i -> w[i][1] > w[i+1][1] );

    # check powers
    k := First( [1..Length(w)], i -> w[i][2] >= tau[w[i][1]] );

    # set up results
    return (IsBool(h) and IsBool(k));
end;

#############################################################################
##
#F TrivialCollection( y, x, bT, fld )
##
TrivialCollection := function( y, x, bT, f )
    local e, v;
    e := ShallowCopy(x); 
    e[y] := e[y]+1;
    e := Position( bT, e );
    v := List( bT, x -> Zero(f) );
    v[e] := One(f);
    return v;
end;

#############################################################################
##
#F Collect( L, B, y, x, sT, bT, vT )
##
## Expresses y*x as linear combination of basis elements in bT * Z(U) 
## and returns coefficient vectors with respect to Z(U).
##
## L is the underlying Lie algebra.
## B is a basis for L.
## y is the number of a basis element in B.
## x is an element of bT.
## sT is the description of powers x^(p^m).
## bT is the special basis of U(L)/Z.
## vT specifies the character (variables/elements)
## 
Collect := function( L, B, y, x, sT, bT, vT )
    local b, f, p, d, tau, fin, tdo, l, w, c, h, k, i, j, lhs, rhs, 
          el, ci, cij, v, u, e, elm, s;

    Info( InfoEnvAlg, 1, "collecting ",y," by ",x);
    
    # extract info
    b := BasisVectors(B);
    f := LeftActingDomain(L);
    p := Characteristic(f);
    d := Length(B);

    # first check whether collection is trivial
    s := PositionNonZero( x );
    if (y < s) or (y <= s and x[s] < sT[s].expon - 1) then 
        return TrivialCollection( y, x, bT, f );
    fi;

    # set up
    fin := List( bT, x -> Zero(f) );
    tdo := [[ One(f), MultWord([[[y, 1]], WordByExponent(x)]) ]];
    l := 1;
 
    # start working (we always have yx = tdo + fin)
    while l > 0 do
        Info( InfoEnvAlg, 1, "  next loop with ",l," entries to do");

        # take last entry of tdo
        c := tdo[l][1];
        w := tdo[l][2];
        Unbind(tdo[l]); l := l-1;
    
        # check for power/conjugation problems
        h := First( [1..Length(w)-1], i -> w[i][1] > w[i+1][1] );
        k := First( [1..Length(w)], i -> w[i][2] >= sT[w[i][1]].expon );
   
        # eliminate conjugation problem
        if IsInt(h) and h < k then 
            Info( InfoEnvAlg, 2, "   conjugation problem");

            # cut element
            if w[h][2] = 1 then 
                lhs := w{[1..h-1]};
            elif w[h][2] > 1 then 
                lhs := w{[1..h]};
                lhs[h][2] := l[h][2]-1;
            fi;
            rhs := w{[h+2..Length(w)]};

            # first summand
            v := [lhs, [w[h+1],w[h]], rhs];
            l := l+1;
            tdo[l] := [c, MultWord(v)];

            # intermediate summands
            el := ShallowCopy( b[w[h][1]] );
            for i in [1..w[h+1][2]-1] do
 
                # express [y,x]_i as linear combination
                el := el * b[w[h+1][1]];
                ci := Coefficients(B, el);
 
                # add summands
                for j in [1..d] do
                    if ci[j] <> 0 * ci[j] then
                        cij := c * ci[j] * Binomial(w[h+1][2],i);
                        if cij <> 0 * cij then 
                            v := [lhs, [[w[h+1][1],w[h+1][2]-i]],[[j,1]],rhs];
                            l := l+1;
                            tdo[l] := [cij, MultWord(v)];
                        fi;
                    fi;
                od;
            od;

            # last summand
            el := el * b[w[h+1][1]];
            ci := Coefficients(B, el);
            for j in [1..d] do
                if ci[j] <> 0 * ci[j] then
                    cij := c * ci[j];
                    v := [lhs, [[j,1]], rhs];
                    l := l+1;
                    tdo[l] := [cij, MultWord(v)];
                fi;
            od;

        # eliminate power problem
        elif IsInt(k) then 
            Info( InfoEnvAlg, 2, "   power problem");

            # cut element
            u := w[k][2] - sT[w[k][1]].expon;
            lhs := w{[1..k-1]};
            rhs := w{[k+1..Length(w)]};
            elm := sT[w[k][1]];
 
            # powers
            for i in [1..elm.power-1] do
                ci := c * elm.coeff[i]; 
                if ci <> 0 * ci then 
                    v := [lhs, [[w[k][1], u+p^i]], rhs];
                    l := l+1;
                    tdo[l] := [ci, Concatenation(v)];
                fi;
            od;
  
            # inner
            for i in [1..Length(B)] do
                ci := c * elm.inner[i]; 
                if ci <> 0 * ci then 
                    if i = w[k][1] then 
                        v := [lhs, [[w[k][1], u+1]], rhs];
                    elif u > 0 then 
                        v := [lhs, [[w[k][1], u]],[[i, 1]], rhs];
                    else
                        v := [lhs, [[i, 1]], rhs];
                    fi;
                    l := l+1;
                    tdo[l] := [ci, MultWord(v)];
                fi;
            od;

            # center
            if vT[w[k][1]] <> 0 * vT[w[k][1]] then 
                ci := c * vT[w[k][1]];
                if u > 0 then 
                    v := [lhs, [[w[k][1],u]], rhs ];
                else
                    v := [lhs, rhs];
                fi;
                l := l+1;
                tdo[l] := [ci, Concatenation(v)];
            fi;

 
        # there is no problem and w is a normal word
        else
            Info( InfoEnvAlg, 2, "   no problem");
            e := PositionBasis( bT, w );
            fin[e] := fin[e] + c;
        fi;
    od;

    Info( InfoEnvAlg, 1, "obtained ",TranslateVector( fin, bT));
    return fin;
end;

#############################################################################
##
#F TrivialCollectionMod( y, x, bT, M, k )
##
TrivialCollectionMod := function( y, x, bT, M, k )
    local e, v;

    # set up
    v := List( bT, x -> MutableCopyMat(M.zero) );

    # if y is an element of F ...
    if y <= k then 
        e := ShallowCopy(x); 
        e[y] := e[y]+1;
        e := Position( bT, e );
        v[e] := MutableCopyMat(M.one);

    # if y is an element of U
    else
        e := Position( bT, x );
        v[e] := M.mats[y-k];
    fi;

    return v;
end;

#############################################################################
##
#F Power/ConjugationProblem
##
ConjugationProblem := function( w, k )
    local i;
    for i in [1..Length(w)-1] do
        if w[i][1] > w[i+1][1] and w[i+1][1] <= k then return i; fi;
    od;
    return false;
end;

PowerProblem := function( w, k, tau )
    local i;
    for i in [1..Length(w)] do
        if w[i][1] <= k and w[i][2] >= tau[w[i][1]] then return i; fi;
    od;
    return false;
end;

#############################################################################
##
#F CutWord
##
CutWord := function( wor, k )
    local s;
    s := PositionProperty( wor, x -> x[1] > k );
    if IsBool(s) then return [wor, []]; fi;
    return [wor{[1..s-1]}, wor{[s..Length(wor)]}];
end;

#############################################################################
##
#F MatrixByWord
##
MatrixByWord := function( M, wor, k )
    local m, w;
    m := MutableCopyMat(M.one);
    for w in wor do m := m * M.mats[w[1]-k]^w[2]; od;
    return m;
end;

#############################################################################
##
#F CollectMod( y, x, B, M, sT, bT, vT )
##
## Expresses y*x as linear combination of basis elements in bT * Z(U) 
## and returns coefficient vectors with respect to Z(U).
##
## L is the underlying Lie algebra.
## B is a basis for L.
## y is the number of a basis element in B.
## x is an element of bT.
## sT is the description of powers x^(p^m).
## bT is the special basis of U(L)/Z.
## vT specifies the character (variables/elements)
## 
CollectMod := function( y, x, B, M, sT, bT, vT )
    local dF, dL, dU, p, b, fin, tdo, tau, l, w, c, h, k, i, j, lhs, rhs, 
          el, ci, cij, v, u, e, elm, s, m;

    Info( InfoEnvAlg, 1, "collecting ",y," by ",x);
    
    # extract info
    dU := Length(M.basis);
    dL := Length(B);
    dF := dL - dU;
    b := BasisVectors(B);
    p := Characteristic(M.field);

    # first check whether collection is trivial
    s := PositionNonZero( x );
    if (x=0*x) or (y < s) or (y <= s and x[s] < sT[s].expon - 1) then 
        return TrivialCollectionMod( y, x, bT, M, dF );
    fi;

    # set up
    tau := List( sT, x -> x.expon );
    fin := List( bT, x -> MutableCopyMat(M.zero) );
    tdo := [[ One(M.field), MultWord([[[y, 1]], WordByExponent(x)]) ]];
    l := 1;
 
    # start working (we always have yx = tdo + fin)
    while l > 0 do
        Info( InfoEnvAlg, 1, "  next loop with ",l," entries to do");

        # take last entry of tdo
        c := tdo[l][1];
        w := tdo[l][2];
        Unbind(tdo[l]); l := l-1;
    
        # check for power/conjugation problems
        h := ConjugationProblem( w, dF );
        k := PowerProblem( w, dF, tau );
   
        # eliminate conjugation problem
        if IsInt(h) and h < k then 
            Info( InfoEnvAlg, 2, "   conjugation problem");

            # cut element
            if w[h][2] = 1 then 
                lhs := w{[1..h-1]};
            elif w[h][2] > 1 then 
                lhs := w{[1..h]};
                lhs[h][2] := lhs[h][2]-1;
            fi;
            rhs := w{[h+2..Length(w)]};

            # first summand
            v := [lhs, [w[h+1],w[h]], rhs];
            l := l+1;
            tdo[l] := [c, MultWord(v)];

            # intermediate summands
            el := ShallowCopy( b[w[h][1]] );
            for i in [1..w[h+1][2]-1] do
 
                # express [y,x]_i as linear combination
                el := el * b[w[h+1][1]];
                ci := Coefficients(B, el);
 
                # add summands
                for j in [1..dL] do
                    if ci[j] <> 0 * ci[j] then
                        cij := c * ci[j] * Binomial(w[h+1][2],i);
                        if cij <> 0 * cij then 
                            v := [lhs, [[w[h+1][1],w[h+1][2]-i]],[[j,1]],rhs];
                            l := l+1;
                            tdo[l] := [cij, MultWord(v)];
                        fi;
                    fi;
                od;
            od;

            # last summand
            el := el * b[w[h+1][1]];
            ci := Coefficients(B, el);
            for j in [1..dL] do
                if ci[j] <> 0 * ci[j] then
                    cij := c * ci[j];
                    v := [lhs, [[j,1]], rhs];
                    l := l+1;
                    tdo[l] := [cij, MultWord(v)];
                fi;
            od;

        # eliminate power problem
        elif IsInt(k) then 
            Info( InfoEnvAlg, 2, "   power problem");

            # cut element
            u := w[k][2] - tau[w[k][1]];
            lhs := w{[1..k-1]};
            rhs := w{[k+1..Length(w)]};
            elm := sT[w[k][1]];
 
            # powers
            for i in [1..elm.power-1] do
                if elm.coeff[i] <> 0 * elm.coeff[i] then
                    v := [lhs, [[w[k][1], u+p^i]], rhs];
                    l := l+1;
                    tdo[l] := [ c*elm.coeff[i], Concatenation(v)];
                fi;
            od;
  
            # inner
            for i in [1..dL] do
                if elm.inner[i] <> 0 * elm.inner[i] then 
                    if i = w[k][1] then 
                        v := [lhs, [[w[k][1], u+1]], rhs];
                    elif u > 0 then 
                        v := [lhs, [[w[k][1], u]],[[i, 1]], rhs];
                    else
                        v := [lhs, [[i, 1]], rhs];
                    fi;
                    l := l+1;
                    tdo[l] := [ c*elm.inner[i], MultWord(v)];
                fi;
            od;

            # center
            if vT[w[k][1]] <> 0 * vT[w[k][1]] then 
                if u > 0 then 
                    v := [lhs, [[w[k][1],u]], rhs ];
                else
                    v := [lhs, rhs];
                fi;
                l := l+1;
                tdo[l] := [ c*vT[w[k][1]], Concatenation(v)];
            fi;

 
        # there is no problem and w is a normal word
        else
            Info( InfoEnvAlg, 2, "   no problem");
            v := CutWord( w, dF ); 
            e := PositionBasis( bT, v[1] );
            m := MatrixByWord( M, v[2], dF );
            fin[e] := fin[e] + c * m;
        fi;
    od;

    Info( InfoEnvAlg, 1, "obtained ",TranslateVector( fin, bT));
    return fin;
end;

