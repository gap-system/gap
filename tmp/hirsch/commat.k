#############################################################################
##
#W  commat.k               KANT Experimental                               WN
##
##  The functions in this file find commuting integer matrices as
##  elements of the group of fundamental units in the ring of algebraic
##  integers of an extension of Q.  The extension is specified by an
##  irreducible polynomial in Z[x].
##
CommutingMatrices := function( pol )
    local   O,  units,  mats,  u;
    
    O := Order( pol );
    
    units := OrderUnitsFund( O );
    
    mats := [];
    for u in units do
        Add( mats, MatToColList( EltRepMat( u )[2] ) );
    od;
    
    return mats;
end;
        

StoreCommutingMatrices := function( file, pol )
    local   mats;
    
    mats := CommutingMatrices( pol );
    
    PrintTo( file, "" );
    AppendTo( file, "##  The following matrices are a basis of the\n" );
    AppendTo( file, "##  fundamental units of the order defined by the\n" );
    AppendTo( file, "##  polynomials ", pol, "\n\n" );
    AppendTo( file, "Matrices := ", mats, ";\n" );
end;


HasNontrivialH2 := function( pol )
    local   M,  I,  i;

    M := CommutingMatrices( pol );
    I := MatId( Z, 3 );
    
    Print( "##    ", Length(M), "\n" );
           
    for i in [1..Length(M)] do
        M[i] := Mat( Z, M[i] ) - I;
    od;
    
    M := Concatenation( M );
    
    return Sum( MatSmith( Mat( Z, M ) )[2] );
end;