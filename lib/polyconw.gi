#############################################################################
##
#W  polyconw.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the implementation part of functions and data around
##  Conway polynomials.
##
Revision.polyconw_gi :=
    "@(#)$Id$";


###############################################################################
##
#F  PowerModEvalPol( <f>, <g>, <xpownmodf> )
##
InstallGlobalFunction( PowerModEvalPol, function( f, g, xpownmodf )

    local l,    # length of coefficients of 'g'
          res,  # result
          i;    # loop over coefficients of 'g'

    l:= Length( g );
    res:= [ g[l] ];
    for i in [ 1 .. l-1 ] do
      res:= ProductCoeffs( res, xpownmodf );   # 'res:= res \*\ x\^\ n;'
      ReduceCoeffs( res, f );                  # 'res:= res mod f;'
      res[1]:= res[1] + g[l-i];                # 'res:= res + g_{l-i+1};'
      ShrinkCoeffs( res );
    od;
    return res;
end );


############################################################################
##
#V  CONWAYPOLYNOMIALS
##
CONWAYPOLYNOMIALS := [];

CONWAYPOLYNOMIALS[2] := [
    [1],
    [1,1],
    [1,1],
    [1,1],
    [1,0,1],
    [1,1,0,1,1],
    [1,1],
    [1,0,1,1,1],
    [1,0,0,0,1],
    [1,1,1,1,0,1,1],
    [1,0,1],
    [1,1,0,1,0,1,1,1],
    [1,1,0,1,1],
    [1,0,0,1,0,1,0,1],
    [1,0,1,0,1,1],
    [1,0,1,1,0,1],
    [1,0,0,1],
    [1,1,0,0,0,0,0,0,0,0,1,0,1],
    [1,1,1,0,0,1],
    [1,1,0,0,1,1,1,1,0,1,1],
    [1,0,1,0,0,1,1],
    [1,0,0,0,0,1,1,0,1,1,1,1,1],
    [1,0,0,0,0,1],
    [1,0,0,1,0,1,0,1,0,1,1,0,0,1,1,1,1],
    [1,0,1,0,0,0,1,0,1],
    [1,1,0,0,1,0,1,1,1,0,1,0,0,0,1],
    [1,0,1,1,0,1,0,1,0,1,1,0,1],
    [1,0,1,0,0,1,1,1,0,0,0,0,0,1],
    [1,0,1],
    [1,1,1,1,0,1,0,1,0,0,0,1,0,1,0,0,1,1],
    [1,0,0,1],
    [1,0,0,1,1,0,0,1,0,1,0,0,0,0,0,1],
    [1,0,0,1,0,0,1,0,1,0,1,1,1,1],
    [1,1,1,0,1,1,1,1,1,0,0,1,1,0,0,1,1],
    [1,0,1,0,0,1,0,1,0,0,1,1],
    [1,1,0,0,0,1,1,0,1,0,0,0,0,1,1,0,0,1,0,1,1,0,1,1],
    [1,1,1,1,1,1],
    [1,1,1,0,0,1,0,0,1,1,1,0,0,0,1],
    [1,0,1,0,0,1,1,1,0,1,1,1,1,0,0,1],
    ,
    [1,0,0,1],
    ,
    [1,0,0,1,1,0,1],
    ,
    ,
    [1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1,0,0,1,1,0,1],
    [1,0,0,0,0,1],
    ,
    [1,1,1,1,1,0,1,0,1,0,1],
    ];

CONWAYPOLYNOMIALS[3] := [
    [1],
    [2,2],
    [1,2],
    [2,0,0,2],
    [1,2],
    [2,2,1,0,2],
    [1,0,2],
    [2,2,2,0,1,2],
    [1,1,2,2],
    [2,1,0,0,2,2,2],
    [1,0,2],
    [2,0,1,0,1,1,1],
    [1,2],
    [2,0,1,2,0,1,2,1,1,2],
    [1,1,2,0,0,1,0,0,2],
    [2,1,2,2,2,0,2,2],
    [1,2],
    [2,0,2,0,2,1,2,0,2,0,1],
    [1,0,2],
    ,
    [1,2,0,2,0,1,2,0,2,0,2],
    [2,2,0,1,0,1,1,1,2,2,1,2],
    [1,1,0,1],
    ,
    [1,2,1,1,0,2,2],
    [2,1,2,1,0,0,2,2,2,2,2,2,2,1], 
    [1,0,0,0,0,0,0,2],
    [2,0,0,1,2,0,2,0,1,1,1,2,1,1,2],
    [1,0,0,0,2],
    ,
    [1,1,0,1],
    [2,1,0,1,2,1,2,0,0,0,0,2,2],
    ,
    ,
    [1,1,2,0,2,0,0,1,1,1],
    ,
    [1,2,2,1],
    ,
    ,
    ,
    [1,2],
    ,
    [1,1,0,1],
    ,
    ,
    ,
    [1,2,2,0,2],
    ,
    [1,1,0,0,1,1,0,1,1],
    ];

CONWAYPOLYNOMIALS[5] := [
    [3],
    [2,4],
    [3,3],
    [2,4,4],
    [3,4],
    [2,0,1,4,1],
    [3,3],
    [2,4,3,0,1],
    [3,1,0,2],
    [2,1,4,2,3,3],
    [3,3],
    [2,2,3,4,4,0,1,1],
    [3,3,4],
    [2,1,0,3,2,4,4,0,1],
    [3,4,3,3,0,2],
    [2,1,4,4,2,4,4,4,1],
    [3,2,3],
    ,
    [3,2,0,1],
    ,
    ,
    ,
    [3,0,2],
    ,
    [3,4,2,4,0,1,3],
    ,
    ,
    ,
    [3,1,3,1],
    ,
    [3,3],
    ,
    ,
    ,
    ,
    ,
    [3,3,4],
    ,
    ,
    ,
    [3,0,0,4],
    ,
    [3,3],
    ,
    ,
    ,
    [3,0,4,1,4],
    ];

CONWAYPOLYNOMIALS[7] := [
    [4],
    [3,6],
    [4,0,6],
    [3,4,5],
    [4,1],
    [3,6,4,5,1],
    [4,6],
    [3,2,6,4],
    [4,6,0,1,6],
    [3,3,2,1,4,1,1],
    [4,1],
    [3,0,5,0,4,2,3,5,2],
    [4,0,6],
    [3,6,3,0,2,6,0,5],
    [4,2,1,4,6,6,5],
    [3,4,2,6,1,4,3,5,4],
    [4,1],
    ,
    [4,0,5],
    ,
    ,
    ,
    [4,4,4],
    ,
    ,
    ,
    ,
    ,
    [4,6],
    ,
    [4,0,5],
    ,
    ,
    ,
    ,
    ,
    [4,6],
    ,
    ,
    ,
    [4,1,4,1],
    ,
    [4,2,5],
    ,
    ,
    ,
    [4,3,4],
    ];

CONWAYPOLYNOMIALS[11] := [
    [9],
    [2,7],
    [9,2],
    [2,10,8],
    [9,0,10],
    [2,7,6,4,3],
    [9,4],
    [2,7,1,7,7],
    [9,8,9],
    [2,6,6,10,8,7],
    [9,10],
    ,
    [9,7],
    ,
    ,
    ,
    [9,4],
    ,
    [9,2,8],
    ,
    ,
    ,
    [9,1,8],
    ,
    ,
    ,
    ,
    ,
    [9,2],
    ,
    [9,6,7],
    ,
    ,
    ,
    ,
    ,
    [9,4,10],
    ,
    ,
    ,
    [9,6,0,1],
    ,
    [9,9],
    ,
    ,
    ,
    [9,7,8],
    ];

CONWAYPOLYNOMIALS[13] := [
    [11],
    [2,12],
    [11,2],
    [2,12,3],
    [11,4],
    [2,11,11,10],
    [11,3],
    [2,3,2,12,8],
    [11,12,12,8,12],
    [2,1,1,8,5,7],
    [11,3],
    ,
    [11,12],
    ];

CONWAYPOLYNOMIALS[17] := [
    [14],
    [3,16],
    [14,1],
    [3,10,7],
    [14,1],
    [3,3,10,0,2],
    [14,12],
    [3,6,0,12,11],
    [14,8,7],
    [3,12,9,5,6,13],
    [14,5],
    ];

CONWAYPOLYNOMIALS[19] := [
    [17],
    [2,18],
    [17,4],
    [2,11,2],
    [17,5],
    [2,6,17,17],
    [17,6],
    [2,3,10,12,1],
    [17,16,14,11],
    [2,4,3,17,13,18],
    [17,8],
    ];

CONWAYPOLYNOMIALS[23] := [
    [18],
    [5,21],
    [18,2],
    [5,19,3],
    [18,3],
    [5,1,9,9,1],
    [18,21],
    [5,3,5,20,3],
    [18,9,8,3],
    [5,1,6,15,5,17],
    ];

CONWAYPOLYNOMIALS[29] := [
    [27],
    [2,24],
    [27,2],
    [2,15,2],
    [27,3],
    [2,13,17,25,1],
    [27,2],
    [2,23,26,24,3],
    [27,22,22,4],
    ];

CONWAYPOLYNOMIALS[31] := [
    [28],
    [3,29],
    [28,1],
    [3,16,3],
    [28,7],
    [3,8,16,19],
    [28,1],
    [3,24,12,25],
    [28,29,20,4],
    ,
    [28,20],
    ];

CONWAYPOLYNOMIALS[37] := [
    [35],
    [2,33],
    [35,6],
    [2,24,6],
    [35,10],
    [2,30,4,35],
    [35,7],
    [2,1,27,20,7],
    [35,32,20,6],
    ];

CONWAYPOLYNOMIALS := Immutable( CONWAYPOLYNOMIALS );


############################################################################
##
#F  ConwayPol( <p>, <n> ) . . . . . <n>-th Conway polynomial in charact. <p>
##
InstallGlobalFunction( ConwayPol, function( p, n )

    local F,          # 'GF(p)'
          eps,        # $(-1)^n$ in 'F'
          x,          # indeterminate over 'F', as coefficients list
          cpol,       # actual candidate for the Conway polynomial
          nfacs,      # all 'n/d' for prime divisors 'd' of 'n'
          cpols,      # Conway polynomials for 'd' in 'nfacs'
          pp,         # $p^n-1$
          quots,      # list of $(p^n-1)/(p^d-1)$, for $d$ in 'nfacs'
          ppmin,      # list of $(p^n-1)/d$, for prime factors $d$ of $p^n-1$
          found,      # is the actual candidate compatible?
          pow,        # powers of several polynomials
          i,          # loop over 'ppmin'
          xpownmodf,  # power of 'x', modulo 'cpol'
          c,          # loop over 'cpol'
          e;          # 1 or -1, used to compute the next candidate

    # Check the arguments.
    if not ( IsPrimeInt( p ) and IsInt( n ) and n > 0 ) then
      Error( "<p> must be a prime, <n> a positive integer" );
    fi;

    if not IsBound( CONWAYPOLYNOMIALS[p] ) then
      CONWAYPOLYNOMIALS[p]:= [];
    fi;
    if not IsBound( CONWAYPOLYNOMIALS[p][n] ) then

      F:= GF(p);

      if n mod 2 = 1 then
        eps:= - One( F );
      else
        eps:=   One( F );
      fi;

      # polynomial 'x' (as coefficients list)
      x:=[ Zero( F ), One( F ) ];

      # Initialize the smallest polynomial of degree 'n' that is a candidate
      # for being the Conway polynomial.
      # This is 'x^n + (-1)^n \*\ z' for the smallest primitive root 'z'.
      # If the field can be realized in {\GAP} then 'z' is just 'Z(p)'.

      # Note that we enumerate monic polynomials with constant term
      # $(-1)^n \alpha$ where $\alpha$ is the smallest primitive element in
      # $GF(p)$ by the compatibility condition (and by existence of such a
      # polynomial).

      cpol:= List( [ 1 .. n ], y -> Zero( F ) );
      cpol[ n+1 ]:= One( F );
      cpol[1]:= eps * PrimitiveRootMod(p);

      if n > 1 then

        # Compute the list of all 'n / p' for 'p' a prime divisor of 'n'
        nfacs:= List( Set( FactorsInt( n ) ), d -> n / d );

        if nfacs = [ 1 ] then

          # 'n' is a prime, we have to check compatibility only with
          # the degree 1 Conway polynomial.
          # But this condition is satisfied by choice of the constant term
          # of the candidates.
          cpols:= [];

        else

          # Compute the Conway polynomials for all values $<n> / d$
          # where $d$ is a prime divisor of <n>.
          # They are used for checking compatibility.
          cpols:= List( nfacs, d -> ConwayPol( p, d ) * One( F ) );

        fi;

        pp:= p^n-1;

        quots:= List( nfacs, x -> pp / ( p^x -1 ) );
        ppmin:= List( Set( FactorsInt( pp ) ), d -> pp/d );

        found:= false;

        while not found do

          # Test whether 'cpol' is primitive.
          #  $f$ is primitive if and only if
          #  1. $f$ divides $X^{q^n-1} -1$, and
          #  2. $f$ does not divide $X^{(q^n-1)/p} - 1$ for every
          #     prime divisor $p$ of $q^n - 1$.

          pow:= PowerModCoeffs( x, pp, cpol );
          ShrinkCoeffs( pow );
          found:= pow = [ One( F ) ];

          i:= 1;
          while found and ( i <= Length( ppmin ) ) do
            pow:= PowerModCoeffs( x, ppmin[i], cpol );
            ShrinkCoeffs( pow );
            found:= pow <> [ One( F ) ];
            i:= i+1;
          od;

          # Test compatibility with polynomials in 'cpols'.
          i:= 1;
          while found and i <= Length( cpols ) do

            # Compute $'cpols[i]'( x^{\frac{p^n-1}{p^m-1}} ) mod 'cpol'$.
            xpownmodf:= PowerModCoeffs( x, quots[i], cpol );
            pow:= PowerModEvalPol( cpol, cpols[i], xpownmodf );
            ShrinkCoeffs( pow );
            found:= Length( pow ) = 0;
            i:= i+1;

          od;

          if not found then

            # Compute the next candidate according to the chosen ordering.

            # We have $f$ smaller than $g$ for two polynomials $f$, $g$ of
            # degree $n$ with
            # $f = \sum_{i=0}^n (-1)^{n-i} f_i x^i$ and
            # $g = \sum_{i=0}^n (-1)^{n-i} g_i x^i$ if and only if exists
            # $m\leq n$ such that $f_m \< g_m$,
            # and $f_i = g_i$ for all $i > m$.
            # (Note that the thesis of W. Nickel gives a wrong definition.)

            c:= 0;
            e:= eps;
            repeat
              c:= c+1;
              e:= -1*e;
              cpol[c+1]:= cpol[c+1] + e;
            until cpol[c+1] <> Zero( F );

          fi;

        od;

      fi;

      cpol:= List( cpol, IntFFE );
      found:= ShallowCopy( cpol );

      # Subtract 'x^n', strip leading zeroes,
      # and store this polynomial in the global list.
      Unbind( found[ n+1 ] );
      ShrinkCoeffs( found );
      CONWAYPOLYNOMIALS[p][n]:= found;

    else

      # Decode the polynomial stored in the list.
      # (Append necessary zeroes.)
      cpol:= ShallowCopy( CONWAYPOLYNOMIALS[p][n] );
      while Length( cpol ) < n do
        Add( cpol, 0 );
      od;
      Add( cpol, 1 );

    fi;

    # Return the coefficients list.
    return cpol;
end );


############################################################################
##
#F  ConwayPolynomial( <p>, <n> ) .  <n>-th Conway polynomial in charact. <p>
##
InstallGlobalFunction( ConwayPolynomial, function( p, n )
    if not IsPrimeInt( p ) or not IsInt( n ) or not n > 0 then
      Error( "<p> must be a prime, <n> a positive integer" );
    fi;
    return UnivariatePolynomial( Rationals, ConwayPol( p, n ) );
end );


#############################################################################
##
#E  polyconw.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



