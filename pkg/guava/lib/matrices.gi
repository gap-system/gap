#############################################################################
##
#A  matrices.gi             GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains functions for generating matrices
##
#H  @(#)$Id: matrices.gi,v 1.6 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/matrices_gi") :=
    "@(#)$Id: matrices.gi,v 1.6 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  KrawtchoukMat( <n> [, <q>] )  . . . . . . .  matrix of Krawtchouk numbers
##
InstallMethod(KrawtchoukMat, "n,q", true, [IsInt, IsInt], 0, 
function(n,q) 
    local res,i,k;
    if not IsPrimePowerInt(q) then 
		Error("q must be a prime power int"); 
	fi;
	res := MutableNullMat(n+1,n+1);
    for k in [0..n] do
        res[1][k+1]:=1;
    od;
    for k in [0..n] do
        res[k+1][1] := Binomial(n,k)*(q-1)^k;
    od;
    for i in [2..n+1] do
        for k in [2..n+1] do
            res[k][i] := res[k][i-1] - (q-1)*res[k-1][i] - res[k-1][i-1];
        od;
    od;
    return res;
end);

InstallOtherMethod(KrawtchoukMat, "n", true, [IsInt], 0, 
function(n) 
	return KrawtchoukMat(n, 2);
end);


#############################################################################
##
#F  GrayMat( <n> [, <F>] )  . . . . . . . . .  matrix of Gray-ordered vectors
##
##  GrayMat(n [, F]) returns a matrix in which rows a(i) have the property
##  d( a(i), a(i+1) ) = 1 and a(1) = 0.
##

InstallMethod(GrayMat, "n,Field", true, [IsInt, IsField], 0, 
function(n, F) 
    local M, result, row, series, column, elem, q, elementnr, line,
          goingup; 
	elem := AsSSortedList(F);
	q := Length(elem);
    M := q^n;
    result := MutableNullMat(M,n);
    for column in [1..n] do
        goingup := true;
        row:=0;
        for series in [1..q^(column-1)] do
            for elementnr in [1..q] do
                for line in [1..q^(n-column)] do
                    row:=row+1;
                    if goingup then
                        result[row][column]:= elem[elementnr];
                    else
                        result[row][column]:= elem[q+1-elementnr];
                    fi;
                od;
            od;
            goingup:= not goingup;
        od;
    od;
    return result;
end);

InstallOtherMethod(GrayMat, "n", true, [IsInt], 0, 
function(n) 
	return GrayMat(n, GF(2));
end); 


#############################################################################
##
#F  SylvesterMat( <n> ) . . . . . . . . . . . . Sylvester matrix of order <n>
##

InstallMethod(SylvesterMat, "order", true, [IsInt], 0, 
function(n) 
    local result, syl;
    if n = 1 then
        return [[1]];
    elif (n mod 2)=0 then
        syl:=SylvesterMat(n/2);
        result:=List(syl, x->Concatenation(x,x));
        Append(result,List(syl,x->Concatenation(x,-x)));
        return result;
    else
        Error("n must be a power of 2");
    fi;
end);


#############################################################################
##
#F  HadamardMat( <n> )  . . . . . . . . . . . .  Hadamard matrix of order <n>
##

InstallMethod(HadamardMat, "order", true, [IsInt], 0, 
function(n) 
    local result, had, i, j;
    if n = 1 then
        return [[1]];
    elif (n=2) or (n=4) or ((n mod 8)=0) then
        had:=HadamardMat(n/2);
        result:=List(had, x->Concatenation(x,x));
        Append(result,List(had,x->Concatenation(x,-x)));
        return result;
    elif IsPrimeInt(n-1) and (n mod 4)=0 then
        result := List(MutableNullMat(n,n)+1, x->ShallowCopy(x));
        for i in [2..n] do
            result[i][i]:=-1;  
            for j in [i+1..n] do
                result[i][j]:=Legendre(j-i,n-1);
                result[j][i]:=-result[i][j];
            od;
        od;
        return result;
    elif (n mod 4)=0 then
        Error("The Hadamard matrix of order ",n," is not yet implemented");
    else
        Error("The Hadamard matrix of order ",n," does not exist");
    fi;
end);


#############################################################################
##
#F  IsLatinSquare( <M> )  . . . . . . .  determines if matrix is latin square
##
##  IsLatinSquare determines if M is a latin square, that is a q*q array whose
##  entries are from a set of q distinct symbols such that each row and each
##  column of the array contains each symbol exactly once
##

InstallMethod(IsLatinSquare, "method for matrix", true, [IsMatrix], 0, 
function(M) 

    local i, j, s, n, isLS, MT;
	n:=Length(M);
	s:=Set(M[1]);
	isLS:= (Length(s) = n and Length(s) = Length(M[1]) );
    i:=2;
    if isLS then
        MT:=TransposedMat(M);
    fi;
    while isLS and i<=n do
        isLS:= (Set(M[i]) = s);
        i:=i+1;
    od;
    i := 1;
    while isLS and i<=n do
        isLS:= (Set(MT[i]) = s);
        i:=i+1;
    od;
    return isLS;
end);

InstallOtherMethod(IsLatinSquare, "generic method, any object", true, 
	[IsObject], 0, 
function(obj) 
	if IsMatrix(obj) then 
		TryNextMethod(); 
	fi;
	return false;
end); 


#############################################################################
##
#F  AreMOLS( <matlist> )  . . . . . . . . .  determines if arguments are MOLS
##
##  AreMOLS(M1, M2, ...) determines if the arguments are mutually orthogonal
##  latin squares.
##

##LR - doesn't handle case where arg is list of one matrix.  Is this a prob? 
InstallGlobalFunction(AreMOLS, 
function(arg) 
    local i, j, s, M, n, q2, first, second, max, fast;
    if Length(arg) = 1 then
        M:=arg[1];
    else
        M:=List([1..Length(arg)],i->arg[i]);
    fi;
    n:=Length(M);
    if ( n >= Length(M[1]) ) or not ForAll(M, i-> IsLatinSquare(i)) then
        return false; #this is right
    fi;
    q2 := Length(M[1])^2;
    max := Maximum(M[1][1]) + 1;
    M := List(M, i -> Flat(i));
    fast := (DefaultField(Flat(M)) = Rationals);
    first := 1;
    repeat
        second := first+1;
        if fast then
            repeat
                s := Set( M[first] * max + M[second] );
                second := second + 1;
            until (Length(s) < q2) or (second > n);
        else
            repeat
                s:=Set([]);
                for i in [1 .. q2] do
                    AddSet(s, [  M[first][i], M[second][i] ]);
                od;
                second := second + 1;
            until (Length(s) < q2) or (second > n);
        fi;
        first:=first + 1;
    until (Length(s) < q2) or (first >= n);
    return Length(s) = q2;
end);


#############################################################################
##
#F  MOLS( <q> [, <n>] ) . . . . . . . . . .  list of <n> MOLS of size <q>*<q>
##
##  MOLS( q [, n]) returns a list of n Mutually Orthogonal Latin
##  Squares of size q * q. If n is omitted, MOLS will return a list
##  of two MOLS. If it is not possible to return n MOLS of size q,
##  MOLS will return a boolean false.
##

InstallMethod(MOLS, "size, number", true, [IsInt, IsInt], 0, 
function(q, n) 
    local facs, res, Merged, Squares, nr, S, ToInt;
	
    ToInt := function(M)
        local res, els, q, i, j;
        q:=Length(M);
        els:=AsSSortedList(GF(q));
        res := MutableNullMat(q,q)+1;
        for i in [1..q] do
            for j in [1..q] do
                while els[res[i][j]] <> M[i][j] do
                    res[i][j]:=res[i][j]+1;
                od;
            od;
        od;
        return res-1;
    end;

    Squares := function(q, n)
        local els, res, i, j, k;
        els:=AsSSortedList(GF(q));
        res:=List([1..n], x-> MutableNullMat(q,q,GF(q)));
        for i in [1..q] do
            for j in [1..q] do
                for k in [1..n] do
                    res[k][i][j] := els[i] + els[k+1] * els[j];
                od;
            od;
        od;
        return List([1..n],x -> ToInt(res[x]));
    end;

    Merged := function(A, B)
        local i, j, q1, q2, res;
        q1:=Length(A);
        q2:=Length(B);
        res:=KroneckerProduct(A,NullMat(q2,q2)+1);
        for i in [1 .. q1*q2] do
            for j in [1 .. q1*q2] do
                res[i][j]:= res[i][j] + q1 *
                            B[((i-1) mod q2)+1][((j-1) mod q2)+1];
            od;
        od;
        return res;
    end;

    if n <= 0 then 
		return false; 
	elif (q < 3) or (q = 6) or (q mod 4) = 2 then
        return false; #this must be so
    elif n <> 2 then
        if (not IsPrimePowerInt(q)) or (n >= q) then
            return false; #this is right
        elif IsPrimeInt(q) then
            return List([1..n],i -> List([0..q-1], y -> List([0..q-1], x -> 
                           (x+i*y) mod q)));
        else
            return Squares(q,n);
        fi;
    else
        res:=[[[0]],[[0]]];
        facs:=Collected(Factors(q));
        for nr in facs do
            if nr[2] = 1 then 
                S:= List([1..2], i -> List([0..nr[1]-1],y ->
                            List([0..nr[1]-1], x -> (x+i*y) mod nr[1])));
            else
                S:=Squares(nr[1]^nr[2],2);
            fi;
            res:=[Merged(res[1],S[1]),Merged(res[2],S[2])];
        od;
        return res;
    fi;
end);

InstallOtherMethod(MOLS, "size", true, [IsInt], 0, 
function(q) 
	return MOLS(q, 2);
end);


#############################################################################
##
#F  VerticalConversionFieldMat( <M> ) . . . . . . .  converts matrix to GF(q)
##
##  VerticalConversionFieldMat (M) converts a matrix over GF(q^m) to a matrix
##  over GF(q) with vertical orientation of the tuples
##

InstallMethod(VerticalConversionFieldMat, "method for matrix and field", true, 
	[IsMatrix, IsField], 0, 
function(M, F)  
    local res, q, Fq, m, n, r, ConvTable, x, temp, i, j, k, zero;
    q := Characteristic(F);  
    Fq := GF(q);
    zero := Zero(Fq);  
    m := Dimension(F);     
    n := Length(M[1]);
    r := Length(M);

    ConvTable := [];
    x := Indeterminate(Fq);
	temp := MinimalPolynomial(Fq, Z(q^m));
    for i in [1.. q^m - 1] do
        ConvTable[i] := VectorCodeword(Codeword(x^(i-1) mod temp, m+1));
    od;

    res := MutableNullMat(r * m, n, Fq);
    for i in [1..r] do
        for j in [1..n] do
            if M[i][j] <> zero then
                temp := ConvTable[LogFFE(M[i][j], Z(q^m)) + 1];
                for k in [1..m] do
                    res[(i-1)*m + k][j] := temp[k];
                od;
            fi;
        od;
    od;
    return res;
end);

InstallOtherMethod(VerticalConversionFieldMat, "method for matrix", true, 
	[IsMatrix], 0, 
function(M) 
	return VerticalConversionFieldMat(M, DefaultField(Flat(M))); 
end); 


#############################################################################
##
#F  HorizontalConversionFieldMat( <M>, <F> )  . . .  converts matrix to GF(q)
##
##  HorizontalConversionFieldMat (M, F) converts a matrix over GF(q^m) to a
##  matrix over GF(q) with horizontal orientation of the tuples
##

InstallMethod(HorizontalConversionFieldMat, "method for matrix and field", 
	true, [IsMatrix, IsField], 0, 
function(M, F) 
    local res, vec, k, n, coord, i, p, q, m, zero, g, Nul, ConvTable,
          x;
    q := Characteristic(F);  
    m := Dimension(F);  
    zero := Zero(F);  
    g := MinimalPolynomial(GF(q), Z(q^m));    
    Nul := List([1..m], i -> zero);
    ConvTable := [];
    x := Indeterminate(GF(q));
    for i in [1..Size(F) - 1] do
        ConvTable[i] := VectorCodeword(Codeword(x^(i-1) mod g, m));
    od;
    res := [];
    n := Length(M[1]);
    k := Length(M);
    for vec in [0..k-1] do
        for i in [1..m] do res[m*vec+i] := []; od;
        for coord in [1..n] do
            if M[vec+1][coord] <> zero then
                p := LogFFE(M[vec+1][coord], Z(q^m));
                for i in [1..m] do
                    if (p+i) mod q^m = 0 then p := p+1; fi;
                    Append(res[m*vec+i], ConvTable[(p + i) mod (q^m)]);
                od;
            else
                for i in [1..m] do
                    Append(res[m*vec+i], Nul);
                od;
            fi;
        od;
    od;
    return res;
end);

InstallOtherMethod(HorizontalConversionFieldMat, "method for matrix", true, 
	[IsMatrix], 0, 
function(M) 
	return HorizontalConversionFieldMat(M, DefaultField(Flat(M))); 
end); 


#############################################################################
##
#F  IsInStandardForm( <M> [, <boolean>] ) . . . . is matrix in standard form?
##
##  IsInStandardForm(M [, identityleft]) determines if M is in standard form;
##  if identityleft = false, the identitymatrix must be at the right side
##  of M; otherwise at the left side.
##

InstallMethod(IsInStandardForm, "method for matrix and boolean", true, 
	[IsMatrix, IsBool], 0, 
function(M, identityleft) 
    local l;
    l := Length(M);
    if identityleft = false then  
        return IdentityMat(l, DefaultField(Flat(M))) =
               M{[1..l]}{[Length(M[1])-l+1..Length(M[1])]};
    else    
        return IdentityMat(l, DefaultField(Flat(M))) = M{[1..l]}{[1..l]};
    fi;
end);

InstallOtherMethod(IsInStandardForm, "method for matrix", true, [IsMatrix], 0, 
function(M) 
	return IsInStandardForm(M, true); 
end); 


#############################################################################
##
#F  PutStandardForm( <M> [, <boolean>] [, <F>] )  .  put <M> in standard form
##
##  PutStandardForm(Mat [, idleft] [, F]) puts matrix Mat in standard form,
##  the size of Mat being (n x m). If idleft is true or is omitted, the
##  the identity matrix is put left, else right. The permutation is returned.
##

InstallMethod(PutStandardForm, "method for matrix, idleft and field", true, 
	[IsMatrix, IsBool, IsField], 0, 
function(Mat, idleft, F) 
    local n, m, row, i, j, h, hp, s, zero, P;
    n := Length(Mat);   # not the word length!
    m := Length(Mat[1]);
    if idleft then 
        return PutStandardForm(Mat,F); 
     else	
        s := m-n;
    fi;
    zero := Zero(F);
    P := ();
    for j in [1..n] do
        if Mat[j][j+s] =zero then
            i := j+1;
            while (i <= n) and (Mat[i][j+s] = zero) do
                i := i + 1;
            od;
            if i <= n then
                row := Mat[j];
                Mat[j] := Mat[i];
                Mat[i] := row;
            else
                h := j+s;
                while Mat[j][h] = zero do
                    h := h + 1;
                    if h > m then h := 1; fi;
                od;
                for i in [1..n] do
                    Mat[i] := Permuted(Mat[i],(j+s,h));  
                od;   
                P := P*(j+s,h);
            fi;
        fi;
        Mat[j] := Mat[j]/Mat[j][j+s];
        for i in [1..n] do
            if i <> j then
                if Mat[i][j+s] <> zero then
                    Mat[i] := Mat[i]-Mat[i][j+s]*Mat[j];
                fi;
            fi;
        od;
    od;
    return P;
end);

##
##Thanks to Frank Luebeck for this code:
##
InstallOtherMethod(PutStandardForm, "method for matrix and Field", true, 
	[IsMatrix, IsField], 0, 
function(mat, F) 
local perm, k, i, j, d ;
 d := Length(mat[1]);
 TriangulizeMat(mat);
 perm := ();
 k := Length(mat[1]);
 for i in [1..Length(mat)] do
   j := PositionNonZero(mat[i]);
   if (j <= d and i <> j) then
     perm := perm * (i,j);
   fi;
 od;
 if perm <> () then
   for i in [1..Length(mat)] do
     mat[i] := Permuted(mat[i], perm);
   od;
 fi;
 return perm;
end); 

InstallOtherMethod(PutStandardForm, "method for matrix and idleft", true, 
	[IsMatrix, IsBool], 0, 
function(M, idleft) 
	return PutStandardForm(M, idleft, DefaultField(Flat(M))); 
end); 

InstallOtherMethod(PutStandardForm, "method for matrix", true, [IsMatrix], 0, 
function(M) 
	return PutStandardForm(M, true, DefaultField(Flat(M))); 
end); 


