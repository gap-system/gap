#############################################################################
##
#W  liesct.gi                Sophus package                  Csaba Schneider 
##
##  Computing the with structure constants table of a nilpotent Lie 
##  algebra. This is needed to obtain a sct of a quotient of a nilpotent
##  Lie algebra efficiently.
##
#H  $Id: liesct.gi,v 1.1 2004/02/27 09:19:11 gap Exp $


######################################################################
## 
#F Compact2Coeffs( <comp>, <dim>, <zero> )
##
## Transforms compact form to list of coefficients
##

Compact2Coeffs := function( comp, dim, zero )
    local i, coeffs;
    
    coeffs := List( [1..dim], x->zero );
    
    for i in [1..Length( comp[1] )] do
        coeffs[comp[1][i]] := comp[2][i];
    od;
    
    return coeffs;
end;



######################################################################
## 
#F Coeff2Compact( <coeffs> )
##
## Transforms list of coefficients to compact form
##

Coeff2Compact := function( coeffs )
    local i, comp, zero;
    
    zero := 0*coeffs[1];
    comp := [[],[]];
    
    for i in [1..Length(coeffs)] do
        if coeffs[i] <> zero then
            Add( comp[1], i ); Add( comp[2], coeffs[i] );
        fi;
    od;
    
    return comp;
end;



######################################################################
## 
#F Coeffs2SCTableForm( <coeffs> )
##
## Transforms list of coefficients to the format required by SCTable
##

Coeffs2SCTableForm := function( coeffs )
    local i, sctf, zero;
    
    sctf := [];
    zero := 0*coeffs[1];
    
    for i in [1..Length(coeffs)] do
        if coeffs[i] <> zero then
            Append( sctf, [coeffs[i],i] );
        fi;
    od;
    
    return sctf;
end;



######################################################################
## 
#F Coeffs2SCTableForm( <form> )
##
## Transforms native SCTableFormat to the format required by SCTable
##

NativeSCTableForm2SCTableForm := function( form )
    local i, new;
    
    new := [];
    
    for i in [1..Length( form[1] )] do
        Append( new, [form[2][i],form[1][i]] );
    od;
    
    return new;
end;



######################################################################
## 
#F SumSCT( <a>, <b> )
## 
## Computes the sum of two SCTable elements.
##

SumSCT := function( a, b )
    local length, posa, posb, sum, zero;
    
    if a = [[],[]] then
        return b;
    elif b = [[],[]] then 
        return a;
    elif a = [[],[]] then 
        return [[],[]]; 
    fi;
    
    zero := 0*a[2][1];
    
    length := Length( a[1] ) - Length( b[1] );
    posa := 1;
    posb := 1;
    
    sum := [[],[]];
    
    while posa + posb <= Length( a[1] ) + Length( b[1] ) + 1 do
        if posb > Length( b[1] ) then 
            Add( sum[1], a[1][posa] ); Add( sum[2], a[2][posa] );
            posa := posa + 1;
        elif posa > Length( a[1] ) or b[1][posb] < a[1][posa] then
            Add( sum[1], b[1][posb] ); Add( sum[2], b[2][posb] );
            posb := posb + 1;
        elif a[1][posa] < b[1][posb] then
            Add( sum[1], a[1][posa] ); Add( sum[2], a[2][posa] );
            posa := posa + 1;
        elif b[1][posb] < a[1][posa] then
            Add( sum[1], b[1][posb] ); Add( sum[2], b[2][posb] );
            posb := posb + 1;
        else
            if a[2][posa]+b[2][posb] <> zero then
                Add( sum[1], a[1][posa] ); Add( sum[2], a[2][posa]+b[2][posb] );
            fi;
            posa := posa + 1; posb := posb + 1;
        fi;
    od;
    
    Info( LieInfo, 2, "Sum: ", a, "+", b, "=", sum );
    
    return sum;
end;



######################################################################
## 
#F ProductSCT( <T>, <a>, <b> )
## 
## Computes the product of two SCTable elements.
##

ProductSCT := function( T, a, b )
    local dim, zero, prod, i, j, c;
    
    dim := Length( T ) - 2;
    zero := T[Length( T )];
    b := [[b],[zero^0]];
    
    prod := [[],[]];
    
    for i in [1..Length( a[1] )] do
        for j in [1..Length( b[1] )] do
            if T[a[1][i]][b[1][j]] <> [[],[]] then
                c := ShallowCopy( T[a[1][i]][b[1][j]] ); 
                c[2] := List( c[2], x->x*a[2][i]*b[2][j] );
                prod := SumSCT( prod,  c );
            fi;;
        od;
    od;
    
    return prod;
end;



######################################################################
## 
#F LieQuotientTable( <T>, <A>, <offset> )
## 
## Eliminates some ideal from a SCT. Does it more quickly than usual
## GAP functions.
##

LieQuotientTable := function( T, A, offset )
    local new_T, dim, newdim, heads, newbasis, prodcoeffs, 
          u, v, prod, i, line, zero, c, row;
    
       
    dim := Length( T[1] );
    newdim := dim - Length( A );
    zero := T[dim+2];
    
    new_T := EmptySCTable( newdim, T[dim+2], "antisymmetric" );
    
    heads := List( A, x->PositionNonZero( x )+offset );
    newbasis := [1..dim]; SubtractSet( newbasis, heads );
    
    
    for u in newbasis do
        for v in newbasis{[Position( newbasis, u )+1..newdim]} do
            prod := [ShallowCopy( T[u][v][1] ), ShallowCopy( T[u][v][2] )];
            for i in Intersection( prod[1], heads )  do
                row := A[Position( heads, i )];
                c := Coeff2Compact( row );
                RemoveElmList( c[1], 1 );
                RemoveElmList( c[2], 1 );
                c[1] := c[1] + offset;
                c[2] := -prod[2][Position( prod[1], i )]*c[2];
                RemoveElmList( prod[2], Position( prod[1], i ));
                RemoveElmList( prod[1], Position( prod[1], i)); 
                prod := SumSCT( prod, c );
            od;
            prod := NativeSCTableForm2SCTableForm( prod );
            for i in [1..Length( prod )/2] do
                prod[2*i] := Position( newbasis, prod[2*i] );
            od;
            SetEntrySCTable( new_T, Position( newbasis, u ), 
                    Position( newbasis, v ),  prod );
        od;
    od;
    
    return new_T;
end;

                    









