#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for lattices.
##


#############################################################################
##
#M  ScalarProduct( <v>, <w> ) . . . . . . . . . . . . . . for two row vectors
##
InstallMethod( ScalarProduct,
    "method for two row vectors",
    IsIdenticalObj,
    [ IsRowVector, IsRowVector ],
    function( v, w )
    return v * w;
    end );


#############################################################################
##
#F  StandardScalarProduct( <L>, <x>, <y> )
##
InstallGlobalFunction( StandardScalarProduct, function( L, x, y )
    return x * y;
end );


#############################################################################
##
#M  InverseMatMod( <intmat>, <prime> )
##
##  This method is much faster than the generic method in `matrix.gi'
##
InstallMethod( InverseMatMod,
    "method for a matrix, and an integer",
    [ IsMatrix, IsPosInt ],
    function( intmat, p )

    local i, j, k,              # loop variables
          n,                    # dimension
          intmatq, intmatqinv,  # matrix & inverse modulo p
          x,                    # solution of one iteration
          zline;                # help-line for exchange

    n:= Length( intmat );

    # `intmatq': `intmat' reduced mod `p'
    intmatq := intmat mod p;
    intmatqinv := IdentityMat( n );

    for i in [ 1 .. n ] do
      j := i;
      while j <= n and intmatq[j][i] = 0 do
        j := j + 1;
      od;
      if j > n then

        # matrix is singular modulo that `p'
        return fail;
      else

        # exchange lines `i' and `j'
        if j <> i then
           zline := intmatq[j];
           intmatq[j] := intmatq[i];
           intmatq[i] := zline;
           zline := intmatqinv[j];
           intmatqinv[j] := intmatqinv[i];
           intmatqinv[i] := zline;
        fi;

        # normalize line `i'
        zline:= intmatq[i];
        if zline[i] <> 1 then
          x:= (1/zline[i]) mod p;
          zline[i]:= 1;
          for k in [ i+1 .. n ] do
            if zline[k] <> 0 then
              zline[k]:= (x * zline[k]) mod p;
            fi;
          od;
          zline:= intmatqinv[i];
          for k in [1 .. n] do
            if zline[k] <> 0 then
              zline[k]:= (x * zline[k]) mod p;
            fi;
          od;
        fi;

        # elimination in column `i'
        for j in [ 1 .. n ] do
          if j <> i and intmatq[j][i] <> 0 then
            x:= intmatq[j][i];
            for k in [ 1 .. n ] do
              if intmatqinv[i][k] <> 0 then
                intmatqinv[j][k]:=
                    (intmatqinv[j][k] - x * intmatqinv[i][k] ) mod p;
              fi;
              if intmatq[i][k] <> 0 then
                intmatq[j][k]:=
                     (intmatq[j][k] - x * intmatq[i][k] ) mod p;
              fi;
            od;
          fi;
        od;

      fi;

    od;

    return intmatqinv;
    end );


#############################################################################
##
#F  PadicCoefficients( <A>, <Amodpinv>, <b>, <prime>, <depth> )
##
InstallGlobalFunction( PadicCoefficients,
    function( A, Amodpinv, b, prime, depth )
    local i, n, coeff, step, p2, val;

    n:= Length( b );
    coeff:= [];
    step:= 0;
    p2:= ( prime - 1 ) / 2;
    while PositionNonZero( b ) <= n and step < depth do
      step:= step + 1;
      coeff[ step ]:= ShallowCopy( b * Amodpinv );
      for i in [ 1 .. n ] do
        val:= coeff[ step ][i] mod prime;
        if val > p2 then
          coeff[ step ][i]:= val - prime;
        else
          coeff[ step ][i]:= val;
        fi;
      od;
      b:= ( b - coeff[ step ] * A ) / prime;
    od;
    Add( coeff, b );
    return coeff;
end );


#############################################################################
##
#F  LinearIndependentColumns( <mat> )
##
InstallGlobalFunction( LinearIndependentColumns, function( mat )
    local   m, n,       # dimensions of `mat'
            maxrank,    # maximal possible rank of `mat'
            i, j, k, q,
            row,
            zero,
            val,
            choice;     # list of linear independent columns, result

    # Make a copy to avoid changing the original argument.
    m := Length( mat );
    n := Length( mat[1] );
    maxrank:= m;
    if n < m then
      maxrank:= n;
    fi;
    zero := Zero( mat[1][1] );
    mat := List( mat, ShallowCopy );
    choice:= [];

    # run through all columns of the matrix
    i:= 0;
    for k in [1..n]  do

        # find a nonzero entry in this column
        j := i + 1;
        while j <= m and mat[j][k] = zero  do j := j+1;  od;

        # if there is a nonzero entry
        if j <= m  then

            i:= i+1;

            # Choose this column.
            Add( choice, k );
            if Length( choice ) = maxrank then
              return choice;
            fi;

            # Swap rows `j' and `i'.
            row:= mat[j];
            mat[j]:= mat[i];
            mat[i]:= row;

            # Normalize column `k'.
            val:= row[k];
            for q in [ j .. m ] do
              mat[q][k] := mat[q][k] / val;
            od;
            row[k]:= 1;

            # Clear all entries in row `i'.
            for j in [ k+1 .. n ] do
              if mat[i][j] <> zero  then
                val:= mat[i][j];
                for q in [ i .. m ] do
                  mat[q][j] := mat[q][j] - val * mat[q][k];
                od;
              fi;
            od;

        fi;

    od;

    # Return the list of positions of linear independent columns.
    return choice;
end );


#############################################################################
##
#F  DecompositionInt( <A>, <B>, <depth> )  . . . . . . . . integral solutions
##
##  returns the decomposition matrix <X> with `<X> * <A> = <B>' for <A> and
##  <B> integral matrices.
##
##  For an odd prime $p$, each integer $x$ has a unique representation
##  $x = \sum_{i=0}^{n} x_i p^i$ where  $|x_i| \leq \frac{p-1}{2}$ .
##  Let $x$ be a solution of the equation $xA = b$ where $A$ is a square
##  integral matrix and $b$ an integral vector, $\overline{A} = A \bmod p$
##  and $\overline{b} = b \bmod p$;
##  then $\overline{x} \overline{A} \equiv \overline{b} \bmod p$ for
##  $\overline{x} = x \bmod p$.
##  Assume $\overline{A}$ is regular over the field with $p$ elements; then
##  $\overline{x}$ is uniquely determined mod $p$.
##  Define $x^{\prime} = \frac{x - \overline{x}}{p}$ and
##         $b^{\prime} = \frac{b - \overline{x} A }{p}$.
##  If $y$ is a solution of the equation $x^{\prime} A = b^{\prime}$ we
##  have $( \overline{x} + p y ) A = b$ and thus $x = \overline{x} + p y$
##  is the solution of our problem.
##  Note that the process must terminate if an integral solution $x$ exists,
##  since the $p$--adic series for $y$ has one term less than that for $x$.
##
##  If $A$ is not square, it must have full rank,
##  and $'Length( <A> )' \leq `Length( <A>[1] )'$.
##
InstallGlobalFunction( DecompositionInt, function( A, B, depth )
    local i,       # loop variables
          Aqinv,      # inverse of matrix modulo p
          b,          # vector
          sol,        # solution of one step
          result,     # whole solution
          p,          # prime
          nullv,      # zero-vector
          origA,      # store full argument `A' in case of column choice
          n,          # dimension
          choice,
          coeff;

    # check input parameters
    if   Length( A ) > Length( A[1] ) then
      Error( "<A> must have at least `Length(<A>)' columns" );
    elif not IsMatrix( A ) and ForAll( A, x -> ForAll( x, IsInt ) ) then
      Error( "<A> must be integer matrix" );
    elif not ForAll( B, x -> x = fail or ( ForAll( x, IsInt )
                                  and Length( x ) = Length( A[1] ) ) ) then
      Error( "<B> must be list of integer vectors",
             " of same dimension as in <A>" );
    elif not IsInt( depth ) and depth >= 0 then
      Error( "<depth> (of iterations) must be a nonnegative integer" );
    fi;

    # initialisations
    n      := Length( A );
    depth  := depth + 1;
    result := [];
    p      := 83;
    nullv  := List( [ 1 .. n ], x -> 0 );

    # if `A' is not square choose `n' linear independent columns
    origA:= A;
    if Length( A[1] ) > n then

      choice:= LinearIndependentColumns( A );
      if Length( choice ) < Length( A ) then
        Error( "<A> has not full rank" );
      fi;
      A:= List( A, x -> x{ choice } );

    else
      choice:= [ 1 .. n ];
    fi;

    # compute the inverse `Aqinv' of `A' modulo `p';
    Aqinv:= InverseMatMod( A, p );
    while Aqinv = fail do

      # matrix is singular modulo that `p', choose another one
      p := NextPrimeInt( p );
      Info( InfoZLattice, 1,
            "DecompositionInt: choosing new prime ", p );
      Aqinv:= InverseMatMod( A, p );
    od;

    # compute the p-adic coefficients of the solutions,
    # and form the solutions
    for b in B do

      if b = fail then
        Add( result, fail );
      else
        b:= b{ choice };
        coeff:= PadicCoefficients( A, Aqinv, b, p, depth );
        if coeff[ Length( coeff ) ] = nullv then
          sol := nullv;
          for i in Reversed( [ 1 .. Length( coeff ) - 1 ] ) do
            sol := sol * p + coeff[i];
          od;
          Add( result, ShallowCopy( sol ) );
        else
          Add( result, fail );
        fi;
      fi;

    od;

    # if the argument `A' is not square test if the solutions are correct
    if Length( origA[1] ) > n then
      for i in [ 1 .. Length( result ) ] do
        if result[i] <> fail and result[i] * origA <> B[i] then
          result[i]:= fail;
        fi;
      od;
    fi;

    return result;
end );


#############################################################################
##
#F  IntegralizedMat( <A> )
#F  IntegralizedMat( <A>, <inforec> )
##
InstallGlobalFunction( IntegralizedMat, function( arg )
    local i, A, inforec, tr, f,
          stab,       # Galois stabilizer of `f'
          galaut, repr, aut, conj, pos, row, intA,
          col, introw, nofcyc,
          coeffs;     # coefficients of one column basis

    if Length( arg ) = 0 or Length( arg ) > 2 or not IsMatrix( arg[1] )
       or ( Length( arg ) = 2 and not IsRecord( arg[2] ) ) then
      Error( "usage: IntegralizedMat( <A> ) resp. \n",
             "       IntegralizedMat( <A>, <inforec> )" );
    fi;

    A:= arg[1];
    if Length( arg ) = 2 then

      # just use `inforec' to transform `A'
      inforec:= arg[2];

    else

      # compute transformed matrix `intA' and info record `inforec'
      inforec:= rec( intcols  := [],
                     irratcols:= [],
                     fields   := [] );
      tr:= MutableTransposedMat( A );

      for i in [ 1 .. Length( tr ) ] do

        if IsBound( tr[i] ) then

          if ForAll( tr[i], IsInt ) then
            Add( inforec.intcols, i );
          else

            # compute the field and the coefficients of values;
            # if `tr' contains conjugates of the row, delete them
            f:= FieldByGenerators( tr[i] );
            stab:= GaloisStabilizer( f );
            nofcyc:= Conductor( GeneratorsOfField( f ) );
            galaut:= PrimeResidues( nofcyc );
            SubtractSet( galaut, stab );
            repr:= [];
            while galaut <> [] do
              Add( repr, galaut[1] );
              SubtractSet( galaut,
                           List( stab * galaut[1], x -> x mod nofcyc) );
            od;
            for aut in repr do
              conj:= List( tr[i], x-> GaloisCyc( x, aut ) );
              pos:= Position( tr, conj, 0 );
              if pos <> fail then
                Unbind( tr[ pos ] );
              fi;
            od;
            inforec.fields[i]:= f;
            Add( inforec.irratcols, i );

          fi;
        fi;
      od;
    fi;

    intA:= [];
    for row in A do
      introw:= [];
      coeffs:= row{ inforec.intcols };
      if not ForAll( coeffs, IsInt ) then
        coeffs:= fail;
      fi;
      for col in inforec.irratcols do
        if coeffs <> fail then
          Append( introw, coeffs );
          coeffs:= Coefficients( CanonicalBasis( inforec.fields[ col ] ),
                                 row[ col ] );
        fi;
      od;
      if coeffs = fail then
        introw:= fail;
      else
        Append( introw, coeffs );
      fi;
      Add( intA, introw );
    od;

    return rec( mat:= intA, inforec:= inforec );
end );


#############################################################################
##
#F  Decomposition( <A>, <B>, <depth> ) . . . . . . . . . . integral solutions
#F  Decomposition( <A>, <B>, \"nonnegative\" ) . . . . . . integral solutions
##
##  For a matrix <A> of cyclotomics and a list <B> of cyclotomic vectors,
##  `Decomposition' tries to find integral solutions of the linear equation
##  systems `<x> \* <A> = <B>[i]'.
##
##  <A> must have full rank, i.e., there must be a linear independent set of
##  columns of same length as <A>.
##
##  `Decomposition( <A>, <B>, <depth> )', where <depth> is a nonnegative
##  integer, computes for every `<B>[i]' the initial part
##  $\Sum_{k=0}^{<depth>} x_k p^k$ (all $x_k$ integer vectors with entries
##  bounded by $\pm\frac{p-1}{2}$) of the $p$-adic series of a hypothetical
##  solution. The prime $p$ is 83 first; if the reduction of <A>
##  modulo $p$ is singular, the next prime is chosen automatically.
##
##  A list <X> is returned. If the computed initial part for
##  `<x> \* <A> = <B>[i]' *is* a solution, we have `<X>[i] = <x>', otherwise
##  `<X>[i] = false'.
##
##  `Decomposition( <A>, <B>, \"nonnegative\" )' assumes that the solutions
##  have only nonnegative entries.
##  This is e.g.\ satisfied for the decomposition of ordinary characters into
##  Brauer characters.
##  If the first column of <A> consists of positive integers,
##  the necessary number <depth> of iterations can be computed. In that case
##  the `i'-th entry of the returned list is `false' if there *exists* no
##  nonnegative integral solution of the system `<x> \* <A> = <B>[i]', and it
##  is the solution otherwise.
##
##  *Note* that the result is a list of `false' if <A> has not full rank,
##  even if there might be a unique integral solution for some equation
##  system.
##
InstallMethod( Decomposition, "for a matrix of cyclotomics, a vector and a depth",
        [IsMatrix,IsList,IsObject],
        function( A, B, depth_or_nonnegative )
    local i, intA, intB, newintA, newintB, result, choice, inforec;

    # Check the input parameters.
    if not ( IsInt( depth_or_nonnegative ) and depth_or_nonnegative >= 0 )
       and depth_or_nonnegative <> "nonnegative" then
      Error( "usage: Decomposition( <A>,<B>,<depth> ) for integer <depth>\n",
             "        resp. Decomposition( <A>,<B>,\"nonnegative\" )\n",
             "        ( solution <X> of <X> * <A> = <B> )" );
    elif not ( IsMatrix(A) and IsMatrix(B)
               and Length(B[1]) = Length(A[1]) ) then
      Error( "<A>, <B> must be matrices with same number of columns" );
    fi;

    # Transform `A' to an integer matrix `intA'.
    intA:= IntegralizedMat( A );
    inforec:= intA.inforec;
    intA:= intA.mat;

    # Transform `B' to `intB', choose coefficients compatible.
    intB:= IntegralizedMat( B, inforec ).mat;

    # If `intA' is not square then choose linear independent columns.
    if Length( intA ) < Length( intA[1] ) then
      choice:= LinearIndependentColumns( intA );
      newintA:= List( intA, x -> x{ choice } );
      newintB:= [];
      for i in [ 1 .. Length( intB ) ] do
        if intB[i] = fail then
          newintB[i]:= fail;
        else
          newintB[i]:= intB[i]{ choice };
        fi;
      od;
    elif Length( intA ) = Length( intA[1] ) then
      newintA:= intA;
      newintB:= intB;
    else
      Error( "There must be a subset of columns forming a regular matrix" );
    fi;

    # depth of iteration
    if depth_or_nonnegative = "nonnegative" then
      if not ForAll( newintA, x -> IsInt( x[1] ) and x[1] >= 0 ) then
        Error( "option \"nonnegative\" is allowed only if the first column\n",
               "       of <A> consists of positive integers" );
      fi;

      # The smallest value that has length `c' in the p-adic series is
      # p^c + \Sum_{k=0}^{c-1} -\frac{p-1}{2} p^k = \frac{1}{2}(p^c + 1).
      # So if $'<B>[i][1] / Minimum( newintA[1] )' \< \frac{1}{2}(p^c + 1)$
      # we have `depth' at most `c-1'.

      result:= DecompositionInt( newintA, newintB,
                       LogInt( 2*Int( Maximum( List( B, x->x[1] ) )
                               / Minimum( List( A, x -> x[1]) ) ), 83 ) + 2 );
      for i in [ 1 .. Length( result ) ] do
        if IsList( result[i] ) and Minimum( result[i] ) < 0 then
          result[i]:= fail;
        fi;
      od;
    else
      result:= DecompositionInt( newintA, newintB, depth_or_nonnegative );
    fi;

    # If `A' is not integral or `intA' is not square
    # then test if the result is correct.
    if Length( intA ) < Length( intA[1] )
       or not IsEmpty( inforec.irratcols) then
      for i in [ 1 .. Length( result ) ] do
        if result[i] <> fail and result[i] * A <> B[i] then
          result[i]:= fail;
        fi;
      od;
    fi;

    return result;
end );


#############################################################################
##
#F  LLLReducedBasis( [<L>, ]<vectors>[, <y>][, \"linearcomb\"][, <lllout>] )
##
InstallGlobalFunction( LLLReducedBasis, function( arg )
      local mmue,      # buffer $\mue$
            L,         # the lattice
            y,         # sensitivity $y$ (default $y = \frac{3}{4}$)
            kmax,      # $k_{max}$
            b,         # list $b$ of vectors
            H,         # basechange matrix $H$
            mue,       # matrix $\mue$ of scalar products
            B,         # list $B$ of norms of $b^{\ast}$
            BB,        # buffer $B$
            q,         # buffer $q$ for function `RED'
            i,         # loop variable $i$
            j,         # loop variable $j$
            k,         # loop variable $k$
            l,         # loop variable $l$
            n,         # number of vectors in $b$
            lc,        # boolean: option `linearcomb'?
            lllout,    # record with info about initial part of $b$
            scpr,      # scalar product of lattice `L'
            RED,       # reduction subprocedure; `RED( l )'
                       # means `RED( k, l )' in Cohen's book
            r;         # number of zero vectors found up to now

    RED := function( l )

    # Terminate for $\|\mue_{k,l}\| \leq \frac{1}{2}$.
    if 1 < mue[k][l] * 2 or mue[k][l] * 2 < -1 then

      # Let $q = `Round( mue[k][l] )'$ (is never zero), \ldots
#T Round ?
      q:= Int( mue[k][l] );
      if AbsoluteValue( mue[k][l] - q ) * 2 > 1 then
        q:= q + SignInt( mue[k][l] );
      fi;

      # \ldots and subtract $q b_l$ from $b_k$;
      AddRowVector( b[k], b[l], - q );

      # adjust `mue', \ldots
      mue[k][l]:= mue[k][l] - q;
      for i in [ r+1 .. l-1 ] do
        if mue[l][i] <> 0 then
          mue[k][i]:= mue[k][i] - q * mue[l][i];
        fi;
      od;

      # \ldots and the basechange.
      if lc then
        AddRowVector( H[k], H[l], - q );
      fi;

    fi;
    end;


    # Check the input parameters.
    if   IsLeftModule( arg[1] ) then
      L:= arg[1];
      scpr:= ScalarProduct;
      arg:= arg{ [ 2 .. Length( arg ) ] };
    elif IsList( arg[1] ) then
      # There is no lattice given, take standard scalar product.
      L:= "L";
      scpr:= StandardScalarProduct;
    else
      Error( "usage: LLLReducedBasis( [<L>], <vectors> [,<y>]",
             "[,\"linearcomb\"] )" );
    fi;

    b:= List( arg[1], ShallowCopy );

    # Preset the ``sensitivity'' (value between $\frac{1}{4}$ and $1$).
    if IsBound( arg[2] ) and IsRat( arg[2] ) then
      y:= arg[2];
      if y <= 1/4 or 1 < y then
        Error( "sensitivity `y' must satisfy 1/4 < y <= 1" );
      fi;
    else
      y:= 3/4;
    fi;

    # Get the optional `\"linearcomb\"' parameter
    # and the optional `lllout' record.
    lc     := false;
    lllout := false;

    for i in [ 2 .. Length( arg ) ] do
      if arg[i] = "linearcomb" then
        lc:= true;
      elif IsRecord( arg[i] ) then
        lllout:= arg[i];
      fi;
    od;


    # step 1 (Initialize.)
    n := Length( b );
    r := 0;
    i := 1;
    if lc then
      H:= IdentityMat( n );
    fi;

    if lllout = false or lllout.B = [] then

      k    := 2;
      mue  := [ [] ];
      kmax := 1;

      # Handle the case of leading zero vectors in the input.
      while i <= n and IsZero( b[i] ) do
        i:= i+1;
      od;
      if n < i then

        r:= n;
        k:= n+1;

      elif 1 < i then

        q    := b[i];
        b[i] := b[1];
        b[1] := q;
        if lc then
          q    := H[i];
          H[i] := H[1];
          H[1] := q;
        fi;

      fi;

      if 0 < n then
        B:= [ scpr( L, b[1], b[1] ) ];
      else
        B:= [];
      fi;

      Info( InfoZLattice, 1,
            "LLLReducedBasis called with ", n, " vectors, y = ", y );

    else

      # Note that the first $k_{max}$ vectors are all nonzero.

      mue  := List( lllout.mue, ShallowCopy );
      kmax := Length( mue );
      k    := kmax + 1;
      B    := ShallowCopy( lllout.B );

      Info( InfoZLattice, 1,
            "LLLReducedBasis (incr.) called with ",
            n, " = ", kmax, " + ", n - kmax, " vectors, y = ", y );

    fi;

    while k <= n do

      # step 2 (Incremental Gram-Schmidt)

      # If $k \leq k_{max}$ go to step 3.
      # Otherwise \ldots
      if kmax < k then

        Info( InfoZLattice, 2,
              "LLLReducedBasis: Take ", Ordinal( k ), " vector" );

        # \ldots set $k_{max} \leftarrow k$
        # and for $j = 1, \ldots, k-1$ set
        # $\mue_{k,j} \leftarrow b_k \cdot b_j^{\ast} / B_j$ if
        # $B_j \not= 0$ and $\mue_{k,j} \leftarrow 0$ if $B_j = 0$, \ldots
        kmax:= k;
        mue[k]:= [];
        for j in [ r+1 .. k-1 ] do
          mmue:= scpr( L, b[k], b[j] );
          for i in [ r+1 .. j-1 ] do
            mmue:= mmue - mue[j][i] * mue[k][i];
          od;
          mue[k][j]:= mmue;
        od;

        # (Now `mue[k][j]' contains $\mue_{k,j} B_j$ for all $j$.)
        for j in [ r+1 .. k-1 ] do
          mue[k][j]:= mue[k][j] / B[j];
        od;

        # \ldots then set $b_k^{\ast} \leftarrow
        # b_k - \sum_{j=1}^{k-1} \mue_{k,j} b_j^{\ast}$ and
        # $B_k \leftarrow b_k^{\ast} \cdot b_k^{\ast}$.
        B[k]:= scpr( L, b[k], b[k] );
        for j in [ r+1 .. k-1 ] do
          B[k]:= B[k] - mue[k][j]^2 * B[j];
        od;

      fi;

      # step 3 (Test LLL condition)
      RED( k-1 );
      while B[k] < ( y - mue[k][k-1] * mue[k][k-1] ) * B[k-1] do

        # Execute Sub-algorithm SWAPG$( k )$\:
        # Exchange the vectors $b_k$ and $b_{k-1}$,
        q      := b[k];
        b[k]   := b[k-1];
        b[k-1] := q;

        # $H_k$ and $H_{k-1}$,
        if lc then
          q      := H[k];
          H[k]   := H[k-1];
          H[k-1] := q;
        fi;

        # and if $k > 2$, for all $j$ such that $1 \leq j \leq k-2$
        # exchange $\mue_{k,j}$ with $\mue_{k-1,j}$.
        for j in [ r+1 .. k-2 ] do
          q           := mue[k][j];
          mue[k][j]   := mue[k-1][j];
          mue[k-1][j] := q;
        od;

        # Then set $\mue \leftarrow \mue_{k,k-1}$
        mmue:= mue[k][k-1];

        # and $B \leftarrow B_k + \mue^2 B_{k-1}$.
        BB:= B[k] + mmue^2 * B[k-1];

        # Now, in the case $B = 0$ (i.e. $B_k = \mue = 0$),
        if BB = 0 then

          # exchange $B_k$ and $B_{k-1}$
          B[k]   := B[k-1];
          B[k-1] := 0;

          # and for $i = k+1, k+2, \ldots, k_{max}$
          # exchange $\mue_{i,k}$ and $\mue_{i,k-1}$.
          for i in [ k+1 .. kmax ] do
            q           := mue[i][k];
            mue[i][k]   := mue[i][k-1];
            mue[i][k-1] := q;
          od;

        # In the case $B_k = 0$ and $\mue \not= 0$,
        elif B[k] = 0 and mmue <> 0 then

          # set $B_{k-1} \leftarrow B$,
          B[k-1]:= BB;

          # $\mue_{k,k-1} \leftarrow \frac{1}{\mue}
          mue[k][k-1]:= 1 / mmue;

          # and for $i = k+1, k+2, \ldots, k_{max}$
          # set $\mue_{i,k-1} \leftarrow \mue_{i,k-1} / \mue$.
          for i in [ k+1 .. kmax ] do
            mue[i][k-1]:= mue[i][k-1] / mmue;
          od;

        else

          # Finally, in the case $B_k \not= 0$,
          # set (in this order) $t \leftarrow B_{k-1} / B$,
          q:= B[k-1] / BB;

          # $\mue_{k,k-1} \leftarrow \mue t$,
          mue[k][k-1]:= mmue * q;

          # $B_k \leftarrow B_k t$,
          B[k]:= B[k] * q;

          # $B_{k-1} \leftarrow B$,
          B[k-1]:= BB;

          # then for $i = k+1, k+2, \ldots, k_{max}$ set
          # (in this order) $t \leftarrow \mue_{i,k}$,
          # $\mue_{i,k} \leftarrow \mue_{i,k-1} - \mue t$,
          # $\mue_{i,k-1} \leftarrow t + \mue_{k,k-1} \mue_{i,k}$.
          for i in [ k+1 .. kmax ] do
            q           := mue[i][k];
            mue[i][k]   := mue[i][k-1] - mmue * q;
            mue[i][k-1] := q + mue[k][k-1] * mue[i][k];
          od;

        fi;

        # Terminate the subalgorithm.

        if k > 2 then k:= k-1; fi;

        # Here we have always `k > r' since the loop is entered
        # for `k > r+1' only (because of `B[k-1] \<> 0'),
        # so the only problem might be the case `k = r+1',
        # namely `mue[ r+1 ][r]' is used then; but this is bound
        # provided that the initial list of vectors did not start
        # with zero vectors, and its (perhaps not updated) value
        # does not matter because this would mean just to subtract
        # a multiple of a zero vector.

        RED( k-1 );

      od;

      if B[ r+1 ] = 0 then
        r:= r+1;
        Unbind( b[r] );
      fi;

      for l in [ k-2, k-3 .. r+1 ] do
        RED( l );
      od;
      k:= k+1;

    # step 4 (Finished?)
    # If $k \leq n$ go to step 2.

    od;

    # Otherwise, let $r$ be the number of initial vectors $b_i$
    # which are equal to zero, output $p \leftarrow n - r$,
    # the vectors $b_i$ for $r+1 \leq i \leq n$ (which form an LLL-reduced
    # basis of $L$), the transformation matrix $H \in GL_n(\Z)$
    # and terminate the algorithm.

    # Check whether the last calls of `RED' have produced new zero vectors
    # in `b'; unfortunately this cannot be read off from `B'.
    while r < n and IsZero( b[ r+1 ] ) do
#T if this happens then is `B' outdated???
#T but `B' contains the norms of the orthogonal basis,
#T so this should be impossible!
#T (but if it happens then also `LLLReducedGramMat' should be adjusted!)
Print( "reached special case of increasing r in the last moment\n" );
if B[r+1] <> 0 then
  Print( "strange situation in LLL!\n" );
fi;
      r:= r+1;
    od;

    Info( InfoZLattice, 1,
          "LLLReducedBasis returns basis of length ", n-r );

    mue:= List( [ r+1 .. n ], i -> mue[i]{ [ r+1 .. i-1 ] } );
    MakeImmutable( mue );
    B:= B{ [ r+1 .. n ] };
    MakeImmutable( B );

    if lc then
      return rec( basis          := b{ [ r+1 .. n ] },
                  relations      := H{ [  1  .. r ] },
                  transformation := H{ [ r+1 .. n ] },
                  mue            := mue,
                  B              := B );
    else
      return rec( basis          := b{ [ r+1 .. n ] },
                  mue            := mue,
                  B              := B );
    fi;

end );


#############################################################################
##
#F  LLLReducedGramMat( <G>[, <y>] ) . . . . . . . . . LLL reduced Gram matrix
##
InstallGlobalFunction( LLLReducedGramMat, function( arg )
      local gram,      # the Gram matrix
            mmue,      # buffer $\mue$
            y,         # sensitivity $y$ (default $y = \frac{3}{4}$)
            kmax,      # $k_{max}$
            H,         # basechange matrix $H$
            mue,       # matrix $\mue$ of scalar products
            B,         # list $B$ of norms of $b^{\ast}$
            BB,        # buffer $B$
            q,         # buffer $q$ for function `RED'
            i,         # loop variable $i$
            j,         # loop variable $j$
            k,         # loop variable $k$
            l,         # loop variable $l$
            n,         # length of `gram'
            RED,       # reduction subprocedure; `RED( l )'
                       # means `RED( k, l )' in Cohen's book
            ak,        # buffer vector in Gram-Schmidt procedure
            r;         # number of zero vectors found up to now

    RED := function( l )

    # Terminate for $\|\mue_{k,l}\| \leq \frac{1}{2}$.
    if 1 < mue[k][l] * 2 or mue[k][l] * 2 < -1 then

      # Let $q = `Round( mue[k][l] )'$ (is never zero), \ldots
      q:= Int( mue[k][l] );
      if AbsoluteValue( mue[k][l] - q ) * 2 > 1 then
        q:= q + SignInt( mue[k][l] );
      fi;

      # \ldots adjust the Gram matrix (rows and columns, but only
      # in the lower triangular half), \ldots
      gram[k][k]:= gram[k][k] - q * gram[k][l];
      for i in [ r+1 .. l ] do
        gram[k][i]:= gram[k][i] - q * gram[l][i];
      od;
      for i in [ l+1 .. k ] do
        gram[k][i]:= gram[k][i] - q * gram[i][l];
      od;
      for i in [ k+1 .. n ] do
        gram[i][k]:= gram[i][k] - q * gram[i][l];
#T AddRowVector
      od;

      # \ldots adjust `mue', \ldots
      mue[k][l]:= mue[k][l] - q;
      for i in [ r+1 .. l-1 ] do
        if mue[l][i] <> 0 then
          mue[k][i]:= mue[k][i] - q * mue[l][i];
        fi;
      od;

      # \ldots and the basechange.
      H[k]:= H[k] - q * H[l];

    fi;
    end;


    # Check the input parameters.
    if arg[1] = [] or ( IsList( arg[1] ) and IsList( arg[1][1] ) ) then

      gram:= List( arg[1], ShallowCopy );

      # Preset the ``sensitivity'' (value between $\frac{1}{4}$ and $1$).
      if IsBound( arg[2] ) and IsRat( arg[2] ) then
        y:= arg[2];
        if y <= 1/4 or 1 < y then
          Error( "sensitivity `y' must satisfy 1/4 < y <= 1" );
        fi;
      else
        y:= 3/4;
      fi;

    else
      Error( "usage: LLLReducedGramMat( <gram>[, <y>] )" );
    fi;

    # step 1 (Initialize \ldots
    n    := Length( gram );
    k    := 2;
    kmax := 1;
    mue  := [ [] ];
    r    := 0;
    ak   := [];
    H    := IdentityMat( n );

    Info( InfoZLattice, 1,
          "LLLReducedGramMat called with matrix of length ", n,
          ", y = ", y );

    # \ldots and handle the case of leading zero vectors in the input.)
    i:= 1;
    while i <= n and gram[i][i] = 0 do
      i:= i+1;
    od;
    if i > n then

      r:= n;
      k:= n+1;

    elif i > 1 then

      for j in [ i+1 .. n ] do
        gram[j][1]:= gram[j][i];
        gram[j][i]:= 0;
      od;
      gram[1][1]:= gram[i][i];
      gram[i][i]:= 0;

      q    := H[i];
      H[i] := H[1];
      H[1] := q;

    fi;

    B:= [ gram[1][1] ];

    while k <= n do

      # step 2 (Incremental Gram-Schmidt)

      # If $k \leq k_{max}$ go to step 3.
      if k > kmax then

        Info( InfoZLattice, 2,
              "LLLReducedGramMat: Take ", Ordinal( k ), " vector" );

        # Otherwise \ldots
        kmax:= k;
        B[k]:= gram[k][k];
        mue[k]:= [];
        for j in [ r+1 .. k-1 ] do
          ak[j]:= gram[k][j];
          for i in [ r+1 .. j-1 ] do
            ak[j]:= ak[j] - mue[j][i] * ak[i];
          od;
          mue[k][j]:= ak[j] / B[j];
          B[k]:= B[k] - mue[k][j] * ak[j];
        od;

      fi;

      # step 3 (Test LLL condition)
      RED( k-1 );
      while B[k] < ( y - mue[k][k-1] * mue[k][k-1] ) * B[k-1] do

        # Execute Sub-algorithm SWAPG$( k )$\:
        # Exchange $H_k$ and $H_{k-1}$,
        q      := H[k];
        H[k]   := H[k-1];
        H[k-1] := q;

        # adjust the Gram matrix (rows and columns,
        # but only in the lower triangular half),
        for j in [ r+1 .. k-2 ] do
          q            := gram[k][j];
          gram[k][j]   := gram[k-1][j];
          gram[k-1][j] := q;
        od;
        for j in [ k+1 .. n ] do
          q            := gram[j][k];
          gram[j][k]   := gram[j][k-1];
          gram[j][k-1] := q;
        od;
        q              := gram[k-1][k-1];
        gram[k-1][k-1] := gram[k][k];
        gram[k][k]     := q;

        # and if $k > 2$, for all $j$ such that $1 \leq j \leq k-2$
        # exchange $\mue_{k,j}$ with $\mue_{k-1,j}$.
        for j in [ r+1 .. k-2 ] do
          q           := mue[k][j];
          mue[k][j]   := mue[k-1][j];
          mue[k-1][j] := q;
        od;

        # Then set $\mue \leftarrow \mue_{k,k-1}$
        mmue:= mue[k][k-1];

        # and $B \leftarrow B_k + \mue^2 B_{k-1}$.
        BB:= B[k] + mmue^2 * B[k-1];

        # Now, in the case $B = 0$ (i.e. $B_k = \mue = 0$),
        if BB = 0 then

          # exchange $B_k$ and $B_{k-1}$
          B[k]   := B[k-1];
          B[k-1] := 0;

          # and for $i = k+1, k+2, \ldots, k_{max}$
          # exchange $\mue_{i,k}$ and $\mue_{i,k-1}$.
          for i in [ k+1 .. kmax ] do
            q           := mue[i][k];
            mue[i][k]   := mue[i][k-1];
            mue[i][k-1] := q;
          od;

        # In the case $B_k = 0$ and $\mue \not= 0$,
        elif B[k] = 0 and mmue <> 0 then

          # set $B_{k-1} \leftarrow B$,
          B[k-1]:= BB;

          # $\mue_{k,k-1} \leftarrow \frac{1}{\mue}
          mue[k][k-1]:= 1 / mmue;

          # and for $i = k+1, k+2, \ldots, k_{max}$
          # set $\mue_{i,k-1} \leftarrow \mue_{i,k-1} / \mue$.
          for i in [ k+1 .. kmax ] do
            mue[i][k-1]:= mue[i][k-1] / mmue;
          od;

        else

          # Finally, in the case $B_k \not= 0$,
          # set (in this order) $t \leftarrow B_{k-1} / B$,
          q:= B[k-1] / BB;

          # $\mue_{k,k-1} \leftarrow \mue t$,
          mue[k][k-1]:= mmue * q;

          # $B_k \leftarrow B_k t$,
          B[k]:= B[k] * q;

          # $B_{k-1} \leftarrow B$,
          B[k-1]:= BB;

          # then for $i = k+1, k+2, \ldots, k_{max}$ set
          # (in this order) $t \leftarrow \mue_{i,k}$,
          # $\mue_{i,k} \leftarrow \mue_{i,k-1} - \mue t$,
          # $\mue_{i,k-1} \leftarrow t + \mue_{k,k-1} \mue_{i,k}$.
          for i in [ k+1 .. kmax ] do
            q:= mue[i][k];
            mue[i][k]:= mue[i][k-1] - mmue * q;
            mue[i][k-1]:= q + mue[k][k-1] * mue[i][k];
          od;

        fi;

        # Terminate the subalgorithm.

        if k > 2 then k:= k-1; fi;

        # Here we have always `k > r' since the loop is entered
        # for `k > r+1' only (because of `B[k-1] <> 0'),
        # so the only problem might be the case `k = r+1',
        # namely `mue[ r+1 ][r]' is used then; but this is bound
        # provided that the initial Gram matrix did not start
        # with zero columns, and its (perhaps not updated) value
        # does not matter because this would mean just to subtract
        # a multiple of a zero vector.

        RED( k-1 );

      od;

      if B[ r+1 ] = 0 then
        r:= r+1;
      fi;

      for l in [ k-2, k-3 .. r+1 ] do
        RED( l );
      od;
      k:= k+1;

    # step 4 (Finished?)
    # If $k \leq n$ go to step 2.

    od;

    # Otherwise, let $r$ be the number of initial vectors $b_i$
    # which are equal to zero,
    # take the nonzero rows and columns of the Gram matrix
    # the transformation matrix $H \in GL_n(\Z)$
    # and terminate the algorithm.

    if IsBound( arg[1][1][n] ) then

      # adjust also upper half of the Gram matrix
      gram:= gram{ [ r+1 .. n ] }{ [ r+1 .. n ] };
      for i in [ 2 .. n-r ] do
        for j in [ 1 .. i-1 ] do
          gram[j][i]:= gram[i][j];
        od;
      od;

    else

      # get the triangular matrix
      gram:= gram{ [ r+1 .. n ] };
      for i in [ 1 .. n-r ] do
        gram[i]:= gram[i]{ [ r+1 .. r+i ] };
      od;

    fi;

    Info( InfoZLattice, 1,
          "LLLReducedGramMat returns matrix of length ", n-r );

    mue:= List( [ r+1 .. n ], i -> mue[i]{ [ r+1 .. i-1 ] } );
    MakeImmutable( mue );
    B:= B{ [ r+1 .. n ] };
    MakeImmutable( B );

    return rec( remainder      := gram,
                relations      := H{ [  1  .. r ] },
                transformation := H{ [ r+1 .. n ] },
                mue            := mue,
                B              := B );
end );


#############################################################################
##
#F  ShortestVectors( <mat>, <bound> [, \"positive\" ] )
##
InstallGlobalFunction( ShortestVectors, function( arg )
    local
    # variables
          n,  checkpositiv, a, llg, nullv, m, c, anz, con, b, v,
    # procedures
          srt, vschr;

    # search for shortest vectors
    srt := function( d, dam )
    local i, j, x, k, k1, q;
    if d = 0 then
       if v = nullv then
          con := false;
       else
          anz := anz + 1;
          vschr( dam );
       fi;
    else
       x := 0;
       for j in [d+1..n] do
          x := x + v[j] * llg.mue[j][d];
       od;
       i := - Int( x );
       if AbsInt( -x-i ) * 2 > 1 then
          i := i - SignInt( x );
       fi;
       k := i + x;
       q := ( m + 1/1000 - dam ) / llg.B[d];
       if k * k < q then
          repeat
             i := i + 1;
             k := k + 1;
          until k * k >= q and k > 0;
          i := i - 1;
          k := k - 1;
          while k * k < q and con do
             v[d] := i;
             k1 := llg.B[d] * k * k + dam;
             srt( d-1, k1 );
             i := i - 1;
             k := k - 1;
          od;
       fi;
    fi;
    end;

    # output of vector
    vschr := function( dam )
    local i, j, w, neg;
    c.vectors[anz] := [];
    neg := false;
    for i in [1..n] do
       w := 0;
       for j in [1..n] do
          w := w + v[j] * llg.transformation[j][i];
       od;
       if w < 0 then
          neg := true;
#T better here check testpositiv and return!
       fi;
       c.vectors[anz][i] := w;
    od;
    if checkpositiv and neg then
       Unbind(c.vectors[anz]);
       anz := anz - 1;
    else
       c.norms[anz] := dam;
    fi;
    end;

    # main program
    # check input
    if    not IsBound( arg[1] )
       or not IsList( arg[1] ) or not IsList( arg[1][1] ) then
       Error ( "first argument must be Gram matrix\n",
          "usage: ShortestVectors( <mat>, <integer> [,<\"positive\">] )" );
    elif not IsBound( arg[2] ) or not IsInt( arg[2] ) then
       Error ( "second argument must be integer\n",
          "usage: ShortestVectors( <mat>, <integer> [,<\"positive\">] )");
    elif IsBound( arg[3] ) then
       if IsString( arg[3] ) then
          if arg[3] = "positive" then
             checkpositiv := true;
          else
             checkpositiv := false;
          fi;
       else
          Error ( "third argument must be string\n",
          "usage: ShortestVectors( <mat>, <integer> [,<\"positive\">] )");
       fi;
    else
       checkpositiv := false;
    fi;

    a := arg[1];
    m := arg[2];
    n := Length( a );
    b := List( a, ShallowCopy );
    c     := rec( vectors:= [], norms:= [] );
    v     := ListWithIdenticalEntries( n, 0 );
    nullv := ListWithIdenticalEntries( n, 0 );

    llg:= LLLReducedGramMat( b );
#T here check that the matrix is really regular
#T (empty relations component)

    anz := 0;
    con := true;
    srt( n, 0 );

    Info( InfoZLattice, 2,
          "ShortestVectors: ", Length( c.vectors ), " vectors found" );
    return c;
end );


#############################################################################
##
#F  OrthogonalEmbeddings( <grammat> [, \"positive\" ] [, <integer> ] )
##
InstallGlobalFunction( OrthogonalEmbeddings, function( arg )
    local
    # sonstige prozeduren
          Symmatinv,
    # variablen fuer Embed
          maxdim, M, D, s, phi, mult, m, x, t, x2, sumg, sumh,
          f, invg, sol, solcount, out,
          l, g, i, j, k, n, a, IdMat, chpo,
    # booleans
          checkdim,
    # prozeduren fuer Embed
          comp1, comp2, scp2, multiples, solvevDMtr,
          Dextend, Mextend, inca, rnew,
          deca;

    Symmatinv := function( b )
    # inverts symmetric matrices

    local n, i, j, l, k, c, d, ba, B, kgv1;
    n := Length( b );
    c := List( IdMat, ShallowCopy );
    d := [];
    B := [];
    kgv1 := 1;
    ba := List( IdMat, ShallowCopy );
    for i in [1..n] do
       k := b[i][i];
       for j in [1..i-1] do
          k := k - c[i][j] * c[i][j] * B[j];
       od;
       B[i] := k;
       for j in [i+1..n] do
          k := b[j][i];
          for l in [1..i-1] do
             k := k - c[i][l] * c[j][l] * B[l];
          od;
          if B[i] <> 0 then
             c[j][i] := k / B[i];
          else
             Error ( "matrix not invertible, ", Ordinal( i ),
                     " column is linearly dependent" );
          fi;
       od;
    od;
    if B[n] = 0 then
       Error ( "matrix not invertible, ", Ordinal( i ),
               " column is linearly dependent" );
    fi;
    for i in [1..n-1] do
       for j in [i+1..n] do
          if c[j][i] <> 0 then
             for l in [1..i] do
                ba[j][l] := ba[j][l] - c[j][i] * ba[i][l];
             od;
          fi;
       od;
    od;
    for i in [1..n] do
       for j in [1..i-1] do
          ba[j][i] := ba[i][j];
          ba[i][j] := ba[i][j] / B[i];
       od;
       ba[i][i] := 1/B[i];
    od;
    for i in [1..n] do
       d[i] := [];
       for j in [1..n] do
          if i >= j then
             k := ba[i][j];
             l := i + 1;
          else
             l := j;
             k := 0;
          fi;
          while l <= n do
             k := k + ba[i][l] * ba[l][j];
             l := l + 1;
          od;
          d[i][j] := k;
          kgv1 := Lcm( kgv1, DenominatorRat( k ) );
       od;
    od;
    for i in [1..n] do
       for j in [1..n] do
          d[i][j] := kgv1 * d[i][j];
       od;
    od;
    return rec( inverse := d, enuminator := kgv1 );
    end;

    # program embed

    comp1 := function( a, b )
    local i;
    if ( a[n+1] < b[n+1] ) then
      return false;
    elif ( a[n+1] > b[n+1] ) then
      return true;
    else
      for i in [ 1 .. n ] do
        if AbsInt( a[i] ) > AbsInt( b[i] ) then
          return true;
        elif AbsInt( a[i] ) < AbsInt( b[i] ) then
          return false;
        fi;
      od;
    fi;
    return false;
    end;

    comp2 := function( a, b )
    local i, t;
    t := Length(a)-1;
    if a[t+1] < b[t+1] then
      return true;
    elif a[t+1] > b[t+1] then
      return false;
    else
      for i in [ 1 .. t ] do
        if a[i] < b[i] then
          return false;
        elif a[i] > b[i] then
          return true;
        fi;
      od;
    fi;
    return false;
    end;

    scp2 := function( k, l )
    # uses    x, invg,
    # changes
    local   i, j, sum, sum1;

    sum := 0;
    for i in [1..n] do
       sum1 := 0;
       for j in [1..n] do
          sum1 := sum1 + x[k][j] * invg[j][i];
       od;
       sum := sum + sum1 * x[l][i];
    od;
    return sum;
    end;

    multiples := function( l )
    # uses    m, phi,
    # changes mult, s, k, a, sumh, sumg,
    local   v, r, i, j, brk;

    for j in [1..n] do
       sumh[j] := 0;
    od;
    i := l;
    while i <= t and ( not checkdim or s <= maxdim ) do
       if mult[i] * phi[i][i] < m then
          brk := false;
          repeat
             v := solvevDMtr( i );
             if not IsBound( v[1] ) or not IsList( v[1] ) then
                r := rnew( v, i );
                if r >= 0 then
                   if r > 0 then
                      Dextend( r );
                   fi;
                   Mextend( v, i );
                   a[i] := a[i] + 1;
                else
                   brk := true;
                fi;
             else
                brk := true;
             fi;
          until a[i] * phi[i][i] >= m or ( checkdim and s > maxdim )
                or brk;
          mult[i] := a[i];
          while a[i] > 0 do
             s := s - 1;
             if M[s][Length( M[s] )] = 1 then
                k := k -1;
             fi;
             a[i] := a[i] - 1;
          od;
       fi;
       if mult[i] <> 0 then
          for j in [1..n] do
             sumh[j] := sumh[j] + mult[i] * x2[i][j];
          od;
       fi;
       i := i + 1;
    od;
    end;

    solvevDMtr := function( l )
    #  uses    M, D, phi, f,
    #  changes
    local   M1, M2, i, j, k1, v, sum;

    k1 := 1;
    v := [];
    i := 1;
    while i < s do
       sum := 0;
       M1 := Length( M[i] );
       M2 := M[i][M1];
       for j in [1..M1-1] do
          sum := sum + v[j] * M[i][j];
       od;
       if M2 = 1 then
          v[k1] := -( phi[l][f[i]] + sum ) / D[k1];
          k1 := k1 + 1;
       else
          if DenominatorRat( sum ) <> 1
          or NumeratorRat( sum ) <> -phi[l][f[i]] then
             v[1] := [];
             i := s;
          fi;
       fi;
       i := i + 1;
    od;
    return( v );
    end;

    inca := function( l )
    #  uses    x2,
    #  changes l, a, sumg, sumh,
    local   v, r, brk, i;

    while l <= t and ( not checkdim or s <= maxdim ) do
       brk := false;
       repeat
          v := solvevDMtr( l );
          if not IsBound( v[1] ) or not IsList( v[1] ) then
             r := rnew( v, l );
             if r >= 0 then
                if r > 0 then
                   Dextend( r );
                fi;
                Mextend( v, l );
                a[l] := a[l] + 1;
                for i in [1..n] do
                   sumg[i] := sumg[i] + x2[l][i];
                od;
             else
                brk := true;
             fi;
          else
             brk := true;
          fi;
       until a[l] >= mult[l] or ( checkdim and s > maxdim ) or brk;
       mult[l] := 0;
       l := l + 1;
    od;
    return l;
    end;

    rnew := function( v, l )
    #  uses    phi, m, k, D,
    #  changes v,
    local   sum, i;
    sum := m - phi[l][l];
    for i in [1..k-1] do
       sum := sum - v[i] * D[i] * v[i];
    od;
    if sum >= 0 then
     if sum > 0 then
       v[k] := 1;
     else
       v[k] := 0;
     fi;
    fi;
    return sum;
    end;

    Mextend := function( line, l )
    #  uses    D,
    #  changes M, s, f,
    local   i;
    for i in [1..Length( line )-1] do
       line[i] := line[i] * D[i];
    od;
    M[s] := line;
    f[s] := l;
    s := s + 1;
    end;

    Dextend := function( r )
    #  uses    a,
    #  changes k, D,
    D[k] := r;
    k := k + 1;
    end;

    deca := function( l )
    #  uses    x2, t, M,
    #  changes l, k, s, a, sumg,
    local   i;
if l = 0 then return l; fi;
#   if l <> 1 then
#      l := l - 1;
#      if l = t - 1 then
if l = t then
          while a[l] > 0 do
             s := s -1;
             if M[s][Length( M[s] )] = 1 then
                k := k - 1;
             fi;
             a[l] := a[l] - 1;
             for i in [1..n] do
                sumg[i] := sumg[i] - x2[l][i];
             od;
          od;
#         l := deca( l );
l:= deca( t-1 );
       else
          if a[l] <> 0 then
             s := s - 1;
             if M[s][Length( M[s] )] = 1 then
                k := k - 1;
             fi;
             a[l] := a[l] - 1;
             for i in [1..n] do
                sumg[i] := sumg[i] - x2[l][i];
             od;
             l := l + 1;
          else
#            l := deca( l );
l := deca( l-1 );
          fi;
       fi;
#   fi;
    return l;
    end;

    # check input
    if not IsList( arg[1] ) or not IsList( arg[1][1] ) then
       Error( "first argument must be symmetric Gram matrix\n",
              "usage : Orthog... ( < gram-matrix > \n",
              " [, <\"positive\"> ] [, < integer > ] )" );
    elif Length( arg[1] ) <> Length( arg[1][1] ) then
       Error( "Gram matrix must be quadratic\n",
              "usage : Orthog... ( < gram-matrix >\n",
              " [, <\"positive\"> ] [, < integer > ] )" );
    fi;
    g := List( arg[1], ShallowCopy );
    checkdim := false;
    chpo := "xxx";
    if IsBound( arg[2] ) then
       if IsString( arg[2] ) then
          chpo := arg[2];
       else
          if IsInt( arg[2] ) then
             maxdim := arg[2];
             checkdim := true;
          else
             Error( "second argument must be string or integer\n",
                    "usage : Orthog... ( < gram-matrix >\n",
                    " [, <\"positive\"> ] [, < integer > ] )" );
          fi;
       fi;
    fi;
    if IsBound( arg[3] ) then
       if IsString( arg[3] ) then
          chpo := arg[3];
       else
          if IsInt( arg[3] ) then
             maxdim := arg[3];
             checkdim := true;
          else
             Error( "third argument must be string or integer\n",
                    "usage : Orthog... ( < gram-matrix >\n",
                    " [, <\"positive\"> ] [, < integer > ] )" );
          fi;
       fi;
    fi;
    n := Length( g );
    for i in [1..n] do
       for j in [1..i-1] do
          if g[i][j] <> g[j][i] then
             Error( "matrix not symmetric \n",
                    "usage : Orthog... ( < gram-matrix >\n",
                    " [, <\"positive\"> ] [, < integer > ] )" );
          fi;
       od;
    od;

    # main program
    IdMat := IdentityMat( n );
    invg  := Symmatinv( g );
    m     := invg.enuminator;
    invg  := invg.inverse;
    x     := ShortestVectors( invg, m, chpo );
    t     := Length(x.vectors);
    for i in [1..t] do
       x.vectors[i][n+1] := x.norms[i];
    od;
    x    := x.vectors;
    M    := [];
    M[1] := [];
    D    := [];
    mult := [];
    sol  := [];
    f    := [];
    solcount := 0;
    s        := 1;
    k        := 1;
    l        := 1;
    a        := [];
    for i in [1..t] do
       a[i]      := 0;
       x[i][n+2] := 0;
       mult[i]   := 0;
    od;
    sumg := [];
    sumh := [];
    for i in [1..n] do
       sumg[i] := 0;
       sumh[i] := 0;
    od;
    Sort(x,comp1);
    x2 := [];
    for i in [1..t] do
       x2[i] := [];
       for j in [1..n] do
          x2[i][j]  := x[i][j] * x[i][j];
          x[i][n+2] := x[i][n+2] + x2[i][j];
       od;
    od;
    phi := [];
    for i in [1..t] do
       phi[i] := [];
       for j in [1..i-1] do
          phi[i][j] := scp2( i, j );
       od;
       phi[i][i] := x[i][n+1];
    od;
    repeat
       multiples( l );

       # (former call of `tracecond')
       if ForAll( [ 1 .. n ], i -> g[i][i] - sumg[i] <= sumh[i] ) then
          l := inca( l );
# Here we have l = t+1.
          if s-k = n then
             solcount := solcount + 1;
             Info( InfoZLattice, 2,
                   "OrthogonalEmbeddings: ", solcount, " solutions found" );
             sol[solcount] := [];
             for i in [1..t] do
                sol[solcount][i] := a[i];
             od;
             sol[solcount][t+1]  := s - 1;
          fi;
       fi;
l:= t;
       l := deca( l );
    until l <= 1;
    out := rec( vectors := [], norms := [], solutions := [] );
    for i in [1..t] do
       out.vectors[i] := [];
       out.norms[i]   := x[i][n+1]/m;
       for j in [1..n] do
          out.vectors[i][j] := x[i][j];
       od;
    od;
    Sort( sol, comp2 );
    for i in [1..solcount] do
       out.solutions[i]  := [];
       for j in [1..t] do
          for k in [1..sol[i][j]] do
            Add( out.solutions[i], j );
          od;
       od;
    od;
    return out;
end );


#############################################################################
##
#F  LLLint(<lat>) . . . . . . . . . . . . . . . . . . . .. . integer only LLL
##
InstallGlobalFunction( LLLint, function( arg )
  local lat,b,mu,i,j,k,dim,l,d,dkp,n,r,za,ne,nne,dkm,dkma,mue,muea,muk,mum,
          ca1,ca2,cb1,cb2,tw,sel,s,dkpv,cn,cd;

  lat:=arg[1];
  if Length(arg)>1 then
    cn:=arg[2];
  else
    cn:=3/4;
  fi;
  cd:=DenominatorRat(cn);
  cn:=NumeratorRat(cn);
  b:= List( lat, ShallowCopy );
  mu:=[];
  d:=[1,b[1]*b[1]];
  n:=Length(lat);
  Info( InfoZLattice, 1, "integer LLL in dimension ", n );
  dim:=1;
  k:=2;

  while dim<n do

    # mu[k][j] berechnen (Gram-Schmidt ohne Berechnung der Vektoren selbst)
    mu[k]:=[];
    for j in [1..k-1] do
      za:=d[j]*(b[k]*b[j]);
      ne:=1;
      for i in [1..j-1] do
        nne:=d[i]*d[i+1];
        za:=za*nne-d[j]*mu[k][i]*mu[j][i]*ne;
        ne:=ne*nne;
      od;
      mu[k][j]:=za/ne;
    od;

    # berechne d[k]=\prod B_j

    za:=d[k]*(b[k]*b[k]);
    ne:=1;
    for i in [1..k-1] do
      nne:=d[i]*d[i+1];
      za:=za*nne-d[k]*mu[k][i]*mu[k][i]*ne;
      ne:=ne*nne;
    od;
    d[k+1]:=za/ne;
    if d[k+1]=0 then Error("notbas");fi;

    dim:=dim+1;

    Info( InfoZLattice, 1, "computing vector ", dim );

    while k<=dim do

      #reduce(k-1);

      ne:=d[k];
      za:=mu[k][k-1];
      if za<0 then
        za:=-za;
        s:=-1;
      else
        s:=1;
      fi;
      nne:=ne/2;
      if IsInt(nne) then
        za:=za+nne;
      else
        za:=2*za+ne;
        ne:=ne*2;
      fi;
      r:=s*QuoInt(za,ne);
      if r<>0 then
        b[k]:=b[k]-r*b[k-1];
        for j in [1..k-2] do
          mu[k][j]:=mu[k][j]-r*mu[k-1][j];
        od;
        mu[k][k-1]:=mu[k][k-1]-r*d[k];
      fi;

      mue:=mu[k][k-1];
      dkp:=d[k+1]*d[k-1];
      dkpv:=dkp*4;

      if d[k]*d[k]*cn-mue*mue*cd>dkpv then

        #(2)
        Info( InfoZLattice, 2, "swap ", k-1, " <-> ", k );

        muea:=mue;
        dkm:=d[k];
        dkma:=dkm;

        ca1:=1;
        ca2:=0;
        cb1:=0;
        cb2:=1;

        # iterierter vektor-ggT
        repeat
          dkm:=(dkp+mue*mue)/dkm;
          tw:=ca1;
          ca1:=cb1;
          cb1:=tw;
          tw:=ca2;
          ca2:=cb2;
          cb2:=tw;

          ne:=dkm;
          za:=mue;
          if za<0 then
            za:=-za;
            s:=-1;
          else
            s:=1;
          fi;
          nne:=ne/2;
          if IsInt(nne) then
            za:=za+nne;
          else
            za:=2*za+ne;
            ne:=ne*2;
          fi;
          r:=s*QuoInt(za,ne);

          if r<>0 then
            cb1:=cb1-r*ca1;
            cb2:=cb2-r*ca2;
            mue:=mue-r*dkm;
          fi;
        until dkm*dkm*cn-mue*mue*cd<=dkpv;

        d[k]:=dkm;
        mu[k][k-1]:=mue;

        tw:=ca1*b[k-1]+ca2*b[k];
        b[k]:=cb1*b[k-1]+cb2*b[k];
        b[k-1]:=tw;

        if k>2 then
          sel:=[1..k-2];
          muk:=mu[k]{sel};
          mum:=mu[k-1]{sel};
          tw:=ca1*mum+ca2*muk;
          mu[k]{sel}:=cb1*mum+cb2*muk;
          mu[k-1]{sel}:=tw;
        fi;

        for j in [k+1..dim] do
          za:=ca1*dkma+ca2*muea;
          tw:=(za*mu[j][k-1]+ca2*mu[j][k]*d[k-1])/dkma;
          mu[j][k]:=(((cb1*dkma+cb2*muea)*dkm-mue*za)*mu[j][k-1]+
                     (cb2*dkm-ca2*mue)*d[k-1]*mu[j][k])/dkma/d[k-1];
          mu[j][k-1]:=tw;
        od;

        if k>2 then
          k:=k-1;
        fi;
      else
        for l in [2..k-1] do
          #reduce(k-l);

          ne:=d[k-l+1];
          za:=mu[k][k-l];
          if za<0 then
            za:=-za;
            s:=-1;
          else
            s:=1;
          fi;
          nne:=ne/2;
          if IsInt(nne) then
            za:=za+nne;
          else
            za:=2*za+ne;
            ne:=ne*2;
          fi;
          r:=s*QuoInt(za,ne);
          if r<>0 then
            b[k]:=b[k]-r*b[k-l];
            for j in [1..k-l-1] do
              mu[k][j]:=mu[k][j]-r*mu[k-l][j];
            od;
            mu[k][k-l]:=mu[k][k-l]-r*d[k-l+1];
          fi;
        od;
        k:=k+1;
      fi;
    od;

  od;
  return b;
end );
