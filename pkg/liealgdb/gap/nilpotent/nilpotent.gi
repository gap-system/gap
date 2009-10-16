#############################################################################
##
#W  nilpotent.gi       Small nilpotent Lie algebras        Csaba Schneider 
##
#W  This file contains some functions to access the classifications 
#W  of small-dimensional nilpotent Lie algebras over small fields.
##
#H  $Id: nilpotent.gi,v 1.8 2007/08/28 20:07:31 gap Exp $

InstallMethod( NrNilpotentLieAlgebras, 
        "for a finite field and a positive integer",
        true,
        [ IsField and IsFinite,  IsPosInt ], 
        0,
        function( F, dim )
    
    if dim = 1 then
        return 1;
    elif dim = 2 then
        return 1;
    elif dim = 3 then
        return 2;
    elif dim = 4 then
        return 3;
    elif dim = 5 then
        return 9;
    elif dim = 6 and Characteristic( F ) > 2 then
        return 34;
    elif dim = 6 and Size( F ) = 2 then
        return 36;
    elif dim = 7 and Size( F ) = 2 then
        return 202;
    elif dim = 7 and Size( F ) = 3 then
        return 199;
    elif dim = 7 and Size( F ) = 5 then
        return 211;
    elif dim = 8 and Size( F ) = 2 then
        return 1831;
    elif dim = 9 and Size( F ) = 2 then
        return 27073;
    else
        Error( "The number of nilpotent Lie algebras is not known for these parameters" );
    fi;
    
end );
         
#############################################################################
##
#F  AllNilpotentLieAlgebras( F, dim )
##

 
InstallMethod( AllNilpotentLieAlgebras, 
        "for a finite field and a positive integer",
        true,
        [ IsField and IsFinite,  IsPosInt ], 
        0,
        function( F, dim )
    local parlist, no, p, R, fam;
    
    
    if dim = 1 then 
        parlist := [[1,1]];
    elif dim = 2 then
        parlist := [[2,1]];
    elif dim = 3 then 
        parlist := [[3,1],[3,2]];
    elif dim = 4 then 
        parlist := [[4,1],[4,2],[4,3]];
    elif dim = 5 then
        parlist := List( [1..9], x-> [5,x] );
    elif dim = 6 and Characteristic( F ) > 2 then
        parlist:= [ ];
        p:= PrimitiveRoot( F );
        for no in [1..26] do
            if no in [19,21,22,24] then
                Add( parlist, [6,no,0] );
                Add( parlist, [6,no,One(F)] );
                Add( parlist, [6,no,p] );            
            else
                Add( parlist, [6,no] );
            fi;
        od;
    elif [ Size( F ), dim ] = [ 2, 6 ] then
        parlist := _liealgdb_nilpotent_d6f2;
    elif [Size( F ), dim ] = [ 2, 7 ] then
        parlist := _liealgdb_nilpotent_d7f2;
    elif [Size( F ), dim ] = [ 2, 8 ] then
        parlist := _liealgdb_nilpotent_d8f2;
    elif [Size( F ), dim ] = [ 2, 9 ] then 
        parlist := _liealgdb_nilpotent_d9f2;
    elif [Size( F ), dim ] = [ 3, 7 ] then
        parlist := _liealgdb_nilpotent_d7f3;
    elif [Size( F ), dim ] = [ 5, 7 ] then
        parlist := _liealgdb_nilpotent_d7f5;
    else
        Error( "The list of nilpotent Lie algebras is not available for these parameters." );
    fi;
    
    R := rec( field := F,
              dim := dim,
              type := "Nilpotent",
              parlist := parlist );
    fam := NewFamily( IsLieAlgDBCollection_Nilpotent );
    R := Objectify( NewType( fam, IsLieAlgDBCollection_Nilpotent ), R );
    
    return R;
end );

ReadStringToNilpotentLieAlgebra := function( string, p, dim )
    local digits, d, sum, i, coeffs, no_coeffs, T, pos, a, b, scentry, r, q, L;
    
    digits := ['0','1','2','3','4','5','6','7','8','9',
               'a','b','c','d','e','f','g','h','i','j',
               'k','l','m','n','o','p','q','r','s','t',
               'u','v','w','x','y','z','A','B','C','D',
               'E','F','G','H','I','J','K','L','M','N',
               'O','P','Q','R','S','T','U','V','W','X',
               'Y','Z'];
    
    d := 62^(Length( string ) - 1 );
    sum := 0;
    for i in string do
        sum := sum + (Position( digits, i )-1)*d;
        d := d/62;
    od;
    
    #Print( "number is ", sum, "\n" );
    
    d := 1;
    while d*p <= sum do
        d := d*p;
    od;
    
    coeffs := [];
    
    repeat
        q := QuoInt( sum, d );
        r := sum - q*d;
        Add( coeffs, q );
        sum := sum - q*d;
        d := d/p;
    until d = 1/p;
    
    no_coeffs := Sum( Combinations( [1..dim], 2 ), x->(dim-x[2]));
    coeffs := Concatenation( List( [1..no_coeffs-Length( coeffs )], 
                      x->0 ), coeffs );
    
    #Print( "Coeff list is: ", coeffs, "\n" );
    
    T := EmptySCTable( dim, Zero( GF( p )), "antisymmetric" );
    
    pos := 1;
    
    for a in Reversed([1..dim-1]) do
        for b in Reversed([a+1..dim]) do
            scentry := [];
            for i in Reversed( [b+1..dim] ) do
                Append( scentry, [One(GF(p))*coeffs[pos], i] );
                pos := pos + 1;
            od;
            SetEntrySCTable( T, b, a, scentry );
            #Print( b, " ", a, ": ", scentry, "\n" );
        od;
    od;
    
    L := LieAlgebraByStructureConstants( GF(p), T );
    L!.arg := string;
    Setter( IsLieNilpotent )( L, true );
    return L;
end;

    
InstallMethod(  Enumerator,
        "method for LieAlgDBCollections",
        [ IsLieAlgDBCollection_Nilpotent ],
        function( R )
    
    return EnumeratorByFunctions( NewFamily( 
                   CategoryCollections( IsLieAlgebra )), 
                   rec( 
                        ElementNumber := function( e, n )
        local par;
        par := R!.parlist[n];	   
	    
        if IsString( par ) then
            return ReadStringToNilpotentLieAlgebra( par, Size( R!.field ),
                           R!.dim );
        else
            return NilpotentLieAlgebra( R!.field, par );
        fi;
    end, 
      NumberElement := function( e, x )
        return Position( R!.parlist, x!.arg );
    end,
      Length := function( x ) return Length( R!.parlist ); end ));
  end );
