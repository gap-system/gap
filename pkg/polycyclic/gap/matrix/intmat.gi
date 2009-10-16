############################################################################
##
#W  intmat.gi                    Polycyc                       Werner Nickel
##
##  invert an integer matrix using p-adic approx.
##

#############################################################################
##
##  The following functions invert an integer matrix by computing successive
##  approximations p-addically for a given prime p.
##

##
##  Convert a matrix over GF(p) to an integer matrix with entries in
##  the range [(1-p)/2,..,(p-1)/2].
##
IntMatSym := function( M )
    local i, j, p, IM;
    
    p := Characteristic( M[1][1] );
    IM := List( M, IntVecFFE );
    for i in [1..Length(M)] do 
        for j in [1..Length(M[i])] do
            if 2 * IM[i][j] + 1 > p then
                IM[i][j] := IM[i][j] - p;
            fi;
        od;
    od;
    return IM;
end;

##
##  Compute the inverse of an integer matrix by p-adic approximations.
##
InverseMatModular := function( T, p )
    
    local   e,       #  identity of GF(p)
            Tp,      #  inverse modulo p
            Tr,      #  the remainder term
            Ti,      #  the inverse mod p^k
            k,       #  iteration variable
            N,       #  the null matrix
            t;       #  
    
    e  := One( GF(p) );
    N  := NullMat( Length(T), Length(T), Integers );
    Tp := (e*T)^-1;
    
    Tr := IdentityMat( Length(T), Integers );
    Ti := N;
    k  := 0;
    while Tr <> N do         # loop invariant: T * Ti + p^k * Tr = I

        t  := IntMatSym( Tp * (e*Tr) );
        Ti := Ti + p^k * t;
        Tr := (Tr - T * t) / p;
        k := k+1;
    od;
    
    return Ti;
end;

InverseIntMat := M -> InverseMatModular( M, 251 );

