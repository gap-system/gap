#############################################################################
##
#W  ctblmono.gi                 GAP library                     Thomas Breuer
#W                                                         & Erzsebet Horvath
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the functions dealing with monomiality questions for
##  solvable groups.
##
Revision.ctblmono_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  MinimalNonmonomialGroup( <p>, <factsize> )
##
MinimalNonmonomialGroup := function( p, factsize )

    local K,          # free group
          Kgens,      # free generators of 'K'
          rels,       # relators of 'K'
          name,       # name of 'K'
          t,          # number with suitable multiplicative order
          form,       # matrix of the commutator form
          x,          # indeterminate
          val,        # one entry in 'form'
          i,          # loop
          j,          # loop
          v,          # coefficient vector
          rhs,        # right hand side of a relator when viewed as relation
          q,          # another name for 'factsize'
          2m,         # exponent of size of Frattini factor of group $F$
          m,          # half of '2m'
          facts,      # factors of cylotomic polynomial
          coeff,      # coefficients vector of one factor in 'facts'
          inv,        # inverse of first in 'coeff'
          f,          # 'GF(2)'
          s,          # exponent of centre (minus 1) in dihedral case 
          W,          # part of matrix of an order 2 automorphism
          Winv,       # part of matrix of an order 2 automorphism
          Atr;        # transposed of $A$

    if   factsize = 4 then

      # $K / F(K)$ is cyclic of order 4,
      # $F(K)$ is extraspecial of order $p^3$ and of exponent $p$
      # where $p \equiv -1 \pmod{4}$.

      if not IsPrimeInt( p ) or p < 3 or ( p + 1 ) mod 4 <> 0 then
        Info( InfoMonomial, 1, "<p> must be a prime congruent 1 mod 4" );
        return fail;
      fi;

      K:= FreeGroup( 5 );
      Kgens:= GeneratorsOfGroup( K );
      name:= Concatenation( String(p), "^(1+2):4" );
      rels:= [
                # the relators of the cyclic group
                Kgens[1]^2 / Kgens[2], Kgens[2]^2,
      
                # the relators of the extraspecial group
                Kgens[3]^p, Kgens[4]^p, Kgens[5]^p,
                Kgens[4]^Kgens[3] / ( Kgens[4] * Kgens[5]^-1 ),

                # the action of the cyclic group
                Kgens[3]^Kgens[1] / Kgens[4],
                Kgens[4]^Kgens[1] / Kgens[3]^-1,
                Kgens[3]^Kgens[2] / Kgens[3]^-1,
                Kgens[4]^Kgens[2] / Kgens[4]^-1    ];

    elif factsize = 8 then

      # $K / F(K)$ is quaternion of order 8,
      # $F(K)$ is extraspecial of order $p^3$ and of exponent $p$
      # where $p \equiv 1 \pmod{4}$.

      if not IsPrimeInt( p ) or p < 5 or ( p - 1 ) mod 4 <> 0 then
        Info( InfoMonomial, 1, "<p> must be a prime congruent 1 mod 4" );
        return fail;
      fi;

      # Choose $t$ with $t^2 \equiv -1 \pmod{p}$.
      t:= PrimitiveRootMod( p ) ^ ( (p-1)/4 );
      
      K:= FreeGroup( 6 );
      Kgens:= GeneratorsOfGroup( K );
      name:= Concatenation( String(p), "^(1+2):Q8" );
      rels:= [
               # the relators of the quaternion group
               Kgens[1]^2 / Kgens[3], Kgens[2]^2 / Kgens[3], Kgens[3]^2,
               (Kgens[2]^Kgens[1] ) / ( Kgens[2]^-1 ),
     
               # the relators of the extraspecial group
               Kgens[4]^p, Kgens[5]^p, Kgens[6]^p,
               Kgens[5]^Kgens[4] / ( Kgens[5]*Kgens[6]^-1 ),

               # the action of the quaternion group
               Kgens[4]^Kgens[1] / Kgens[4]^t,
               Kgens[5]^Kgens[1] / Kgens[5]^( (1/t) mod p ),
               Kgens[4]^Kgens[2] / Kgens[5],
               Kgens[5]^Kgens[2] / Kgens[4]^-1,
               Kgens[4]^Kgens[3] / Kgens[4]^-1,
               Kgens[5]^Kgens[3] / Kgens[5]^-1  ];

    elif factsize <> 2 and IsPrimeInt( factsize ) then

      # $K / F(K)$ has order an odd prime $q$.
      # $F(K)$ is extraspecial of order $p^{2m+1}$ and of exponent $p$
      # where $2m$ is the order of $p$ modulo $q$,

      q:= factsize;
      2m:= OrderMod( p, q );

      if 2m = 0 or 2m mod 2 <> 0 then
        Info( InfoMonomial, 1,
              "order of <p> mod <factsize> must be nonzero and even" );
        return fail;
      fi;

      m:= 2m / 2;

      # The 'q'-th cyclotomic polynomial splits over the field with
      # 'p' elements into factors of degree '2*m'.
      facts:= Factors( CyclotomicPolynomial( GF(p), q ) );

      # Take the coefficients i$a_1, a_2, \ldots, a_{2m}, 1$ of a factor.
      coeff:= IntVecFFE(
          - CoefficientsOfUnivariateLaurentPolynomial( facts[1] )[1] );

      # Compute the vector $\epsilon$.
      v:= [];
      v[ 2m-1 ]:= 1;
      for i in [ m .. 2m-2 ] do
        v[i]:= 0;
      od;
      for j in [ m-1, m-2 .. 1 ] do
        v[j]:= coeff[ j+2 ] - coeff[j];
        for i in [ 1 .. m-j-1 ] do
          v[j]:= v[j] + v[ m-i ] * coeff[ m+i+j+1 ];
        od;
        v[j]:= v[j] mod p;
      od;

      # Write down the presentation,
      K:= FreeGroup( 2m+2 );
      Kgens:= GeneratorsOfGroup( K );
      name:= Concatenation( String(p), "^(1+", String( 2m ), "):",
                            String(q) );

      # power relators \ldots
      rels:= [ Kgens[1]^q ];
      if p = 2 then
        for j in [ 2 .. 2m+1 ] do
          Add( rels, Kgens[j]^p / Kgens[2m+2] );
        od;
        Add( rels, Kgens[ 2m+2 ]^p );
      else
        for j in [ 2 .. 2m+2 ] do
          Add( rels, Kgens[j]^p );
        od;
      fi;

      # \ldots action of the automorphism, \ldots
      for j in [ 2 .. 2m ] do
        Add( rels, Kgens[j]^Kgens[1] / Kgens[j+1] );
      od;
      rhs:= One( K );
      for j in [ 1 .. 2m ] do
        rhs:= rhs * Kgens[j+1]^Int( coeff[j] );
      od;

      Add( rels, Kgens[2m+1]^Kgens[1] / rhs );

      # \ldots and commutator relators.
      for i in [ 3 .. 2m+1 ] do
        for j in [ 2 .. i-1 ] do
          Add( rels, Kgens[i]^Kgens[j]
                     / ( Kgens[i] * Kgens[2m+2]^v[ 2m+j-i ] ) );
        od;
      od;

    elif factsize mod 2 = 0 and IsPrimeInt( factsize / 2 ) then

      # $K / F(K)$ is dihedral of order $2 q$ where $q$ is an odd prime.
      # Let $m$ denote the order of 2 mod $q$ (which is odd).
      # $F(K)$ is a central product of an extraspecial group $F$ of order
      # $2^{2m+1}$ (that is purely dihedral) with a cyclic group $C$
      # of order $2^{s+1}$.  Note that in this case the second argument
      # is $s+1$.
      # We have $C = Z(K)$ and $F(K) = C_K( F/Z(F) )$.

      s:= p-1;
      q:= factsize / 2;
      m:= OrderMod( 2, q );

      if m mod 2 = 0 then
        Info( InfoMonomial, 1, "order of 2 mod <factsize>/2 must be odd" );
        return fail;
      fi;

      # The first generator is $t$, the second is $r$,
      # generators 3 to $3+s-1$ are the powers of $t$ that are
      # not contained in $Z(K)$.
      K:= FreeGroup( 2*m + s + 3 );
      Kgens:= GeneratorsOfGroup( K );
      name:= Concatenation( "2^(1+", String( 2*m ), ")" );
      if 0 < s then
        name:= Concatenation( "(", name, "Y", String( 2^(s+1) ), ")" );
      fi;
      name:= Concatenation( name, ":D", String( factsize ) );
 
      rels:= [];

      # $t^2$ is a generator of $Z(K)$.
      if s = 0 then

        # $t$ squares to $z$ or the identity, since for $s = 0$ we have
        # $Z(K) = \langle z \rangle$.
        # Here we choose the identity in order to get Dade\'s example.
        rels[1]:= Kgens[1]^2 / One( K );

      else

        # Describe the cyclic group spanned by $t^2$.
        rels[1]:= Kgens[1]^2 / Kgens[2];
        for i in [ 2 .. s ] do
          rels[i]:= Kgens[i]^2 / Kgens[i+1];
        od;
        rels[ s+1 ]:= Kgens[ s+1 ]^2 / Kgens[ 2*m+s+3 ];

      fi;

      # The $(s+2)$-nd generator is $r$, that of order $q$.
      rels[ s+2 ]:= Kgens[ s+2 ]^q;

      # $t$ inverts $r$.
      rels[ s+3 ]:= Kgens[ s+2 ] ^ Kgens[1] / Kgens[ s+2 ]^-1;

      # The remaining $2m+1$ generators form the extraspecial group $F$.
      for i in [ s+3 .. 2*m+s+3 ] do
        rels[ i+1 ]:= Kgens[ i ]^2;
      od;
      for i in [ 1 .. m ] do
        Add( rels, Kgens[ s+2+m+i ]^Kgens[ s+2+i ]
                   / ( Kgens[ s+2+m+i ] / Kgens[ 2*m+s+3 ] ) );
      od;

      # Describe the actions of $t$ and $r$ on $F$.
      # First we construct the matrices of the linear actions on the
      # Frattini factor of $F$.  (Note that because of even characteristic
      # the sign plays no role here.)
      f:= GF(2);
      facts:= Factors( CyclotomicPolynomial( f, q ) );
      coeff:= CoefficientsOfUnivariateLaurentPolynomial( facts[1] )[1];

      Atr:= NullMat( m, m, f );
      for i in [ 1 .. m-1 ] do
        Atr[i+1][i]:= One( f );
      od;
      for i in [ 1 .. m ] do
        Atr[i][m]:= coeff[i];
      od;

      v:= Zero( f );
      v:= List( Atr, x -> v );
      v[1]:= One( f );
      W:= [ v ];
      for i in [ 2 .. m ] do
        v:= v * Atr;
        W[i]:= v;
      od;

      Winv:= W^-1;

      W     := List( W   , IntVecFFE );
      Winv  := List( Winv, IntVecFFE );
      coeff := IntVecFFE( coeff );

      # The action of $t$ is described by 'W' and its inverse.
      for i in [ s+3 .. s+m+2 ] do
        rhs:= One( K );
        for j in [ 1 .. m ] do
          rhs:= rhs * Kgens[ s+2+m+j ]^W[i-s-2][j];
        od;
        Add( rels, Kgens[i] ^ Kgens[1] / rhs );
      od;
      for i in [ s+m+3 .. s+2*m+2 ] do
        rhs:= One( K );
        for j in [ 1 .. m ] do
          rhs:= rhs * Kgens[ s+2+j ]^Winv[i-s-m-2][j];
        od;
        Add( rels, Kgens[i] ^ Kgens[1] / rhs );
      od;
      
      # The action of $r$ is described by $A$ and its transposed inverse.
      # (first half)
      for i in [ s+3 .. s+m+1 ] do
        Add( rels, Kgens[i] ^ Kgens[s+2] / Kgens[i+1] );
      od;
      rhs:= One( K );
      for j in [ 1 .. m ] do
        rhs:= rhs * Kgens[ s+2+j ]^coeff[j];
      od;
      Add( rels, Kgens[ s+m+2 ] ^ Kgens[s+2] / rhs );

      # (second half)
      for i in [ s+m+3 .. s+2*m+1 ] do
        Add( rels, Kgens[i] ^ Kgens[s+2]
                   / ( Kgens[s+m+3]^coeff[i-s-m-1] * Kgens[i+1] ) );
      od;
      Add( rels, Kgens[ s+2*m+2 ] ^ Kgens[s+2] / Kgens[s+m+3] );

    elif factsize mod 4 = 0 and IsPrimeInt( factsize / 4 ) then

      # $K / F(K)$ is a central extension of the dihedral group of order
      # $2 t$ where $t$ is an odd prime, such that all involutions lift to
      # elements of order 4.  $F(K)$ is an extraspecial $p$-group
      # for an odd prime $p$ with $p \equiv 1 \pmod{4}$.
      # Let $m$ denote the order of $p$ mod $t$, then $F(K)$ is of order
      # $p^{2m+1}$, and $m$ is odd.

      t:= factsize / 4;
      m:= OrderMod( p, t );

      if m mod 2 = 0 or ( p - 1 ) mod 4 <> 0 then
        Info( InfoMonomial, 1,
              "order of <p> mod <t> must be odd, <p> congr. 1 mod 4" );
        return fail;
      fi;

      facts:= Factors( CyclotomicPolynomial( GF(p), t ) );
      coeff:= CoefficientsOfUnivariateLaurentPolynomial( facts[1] )[1];
      inv:= Int( coeff[1]^-1 );
      coeff:= IntVecFFE( coeff );

      # The symplectic form (that will be used to define the
      # commutator form) is derived from the standard symplectic form
      # for the 2-dimensional vector space over $GF(p^{2m})$ by first
      # blowing up to the $2m$ dimensional vector space over $GF(p)$,
      # and then projecting onto $GF(p)$ (that is, the first component).

      # (We need only the lower triangle of the matrix of the form,
      # and this is nonzero only in the lower left square.)

      form:= [];
      for i in [ 1 .. m ] do
        form[i]:= [];
        for j in [ 1 .. m-i+1 ] do
          form[i][j]:= 0;
        od;
      od;
      form[1][1]:= -1;
      x:= Indeterminate( GF(p) );
      for i in [ 2 .. m ] do
        val:= CoefficientsOfUnivariateLaurentPolynomial(
                  x^(i+m-2) mod facts[1] );
        val:= - Int( ShiftedCoeffs( val[1], val[2] )[1] );
        for j in [ i .. m ] do
          form[ m+i-j ][j]:= val;
        od;
      od;

      # Write down the presentation.
      K:= FreeGroup( 2*m + 4 );
      Kgens:= GeneratorsOfGroup( K );
      name:= Concatenation( String(p), "^(1+", String( 2*m), "):2.D",
                            String( factsize/2 ) );

      # power relations,
      rels:= [ Kgens[1]^2 / Kgens[3], Kgens[2]^t / Kgens[3], Kgens[3]^2 ];
      for i in [ 4 .. 2*m+4 ] do
        Add( rels, Kgens[i]^p );
      od;
      
      # action of the Frattini factor,
      # first the order 4 element
      for i in [ 4 .. m+3 ] do
        Add( rels, Kgens[i]^Kgens[1] / Kgens[ i+m ]^-1 );
        Add( rels, Kgens[ i+m ]^Kgens[1] / Kgens[i] );
      od;
      Add( rels, Kgens[2] ^ Kgens[1] / Kgens[2]^-1 );

      # (The element of order $2t$ ...)
      for i in [ 4 .. m+2 ] do
        Add( rels, Kgens[i]^Kgens[2] / Kgens[i+1]^-1 );
      od;
      rhs:= One( K );
      for i in [ 1 .. m ] do
        rhs:= rhs * Kgens[ i+3 ]^coeff[i];
      od;
      Add( rels, Kgens[ m+3 ]^Kgens[2] / rhs );

      rhs:= One( K );
      for i in [ 1 .. m ] do
        rhs:= rhs * Kgens[ m+i+3 ]^( coeff[i+1] * inv );
      od;
      Add( rels, Kgens[ m+4 ]^Kgens[2] / rhs );

      for i in [ 5 .. m+3 ] do
        Add( rels, Kgens[ m+i ]^Kgens[2] / Kgens[ m+i-1 ]^-1 );
      od;

      # (The central involution of the Fitting factor inverts.)
      for i in [ 4 .. m+3 ] do
        Add( rels, Kgens[i]^Kgens[3] / Kgens[i]^-1 );
        Add( rels, Kgens[ i+m ]^Kgens[3] / Kgens[ i+m ]^-1 );
      od;

      # The extraspecial group is defined by the commutator form
      # constructed above.
      for i in [ m+1 .. 2*m ] do
        for j in [ 1 .. m ] do
          Add( rels, Kgens[i+3]^Kgens[j+3]
                     / ( Kgens[i+3] * Kgens[ 2*m + 4 ]^form[i-m][j] ) );
        od;
      od;

    else
      return fail;
    fi;

    K:= PolycyclicFactorGroup( K, rels );
    ConvertToStringRep( name );
    SetName( K, name );
    return K;
end;


#############################################################################
##
#E  ctblmono.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



