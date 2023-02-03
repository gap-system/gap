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
##  This file contains methods for Molien series.
##


#############################################################################
##
#F  StringOfUnivariateRationalPolynomialByCoefficients( <coeffs>, <nam> )
##
#T maybe we need more flexible ways to influence how an object is printed or
#T how its string looks like;
#T in this case, I want to influence how the indeterminate is printed.
##
BindGlobal( "StringOfUnivariateRationalPolynomialByCoefficients",
    function( coeffs, nam )
    local string, i;

    string:= "";
    for i in [ 1 .. Length( coeffs ) ] do
      if coeffs[i] <> 0 then
        if   coeffs[i] > 0 then
          if not IsEmpty( string ) then
            Append( string, "+" );
          fi;
          if coeffs[i] <> 1 then
            Append( string, String( coeffs[i] ) );
            if i <> 1 then
              Append( string, "*" );
            fi;
          elif i = 1 then
            Append( string, "1" );
          fi;
        elif coeffs[i] < 0 then
          if coeffs[i] <> -1 then
            Append( string, String( coeffs[i] ) );
            if i <> 1 then
              Append( string, "*" );
            fi;
          elif i = 1 then
            Append( string, "-1" );
          else
            Append( string, "-" );
          fi;
        fi;
        if i <> 1 then
          Append( string, nam );
        fi;
        if i > 2 then
          Append( string, "^" );
          Append( string, String( i-1 ) );
        fi;

      fi;

    od;

    if IsEmpty( string ) then
      string:= "0";
    fi;
    ConvertToStringRep( string );

    # Return the string.
    return string;
end );


#############################################################################
##
#F  CoefficientTaylorSeries( <numer>, <r>, <k>, <i> )
##
##  We have
##  $$
##     \frac{1}{( 1 - x )^k} =
##        \frac{1}{(k-1)!} \frac{d^{k-1}}{dx^{k-1}} \frac{1}{1-x}
##     \mbox{\rm\ where\ }
##     \frac{1}{1 - x} = \sum_{j=0}^{\infty} x^j .
##  $$
##  Thus we get
##  $$
##     \frac{c_i z^i}{( 1 - z^r )^k} =
##     \sum_{j=0}^{\infty} c_i \frac{(j+k-1)!}{(k-1)! j!} z^{r j + i}.
##  $$
##
##  For $p(z) = \sum_{i=0}^m c_i z^i$ where $m = u r + n$ with $0\leq n \< r$
##  we have
##  $$
##     \frac{p(z)}{( 1 - z^r )^k} =
##        \frac{1}{(k-1)!}\sum_{i=0}^m\sum_{j=0}^{\infty}
##            c_i \frac{(j+k-1)!}{(k-1)! j!} z^{r j + i} .
##  $$
##
##  The coefficient of $z^l$ with $l = g r + v$, $0\leq v \< r$ is
##  $$
##     \sum_{j=0}^{\min\{g,u\}} c_{j r + v}
##                 \prod_{\mu=1}^{k-1} \frac{g-j+\mu}{\mu} .
##  $$
##
InstallGlobalFunction( CoefficientTaylorSeries, function( numer, r, k, l )
    local i, m, u, v, g, coeff, lower, summand, mu;

    m:= Length( numer ) - 1;
    u:= Int( m / r );
    v:= l mod r;
    g:= Int( l / r );

    coeff:= 0;

    # lower bound for the summation
    if g < u then
      lower:= u-g;
    else
      lower:= 0;
    fi;

    for i in [ lower .. u ] do

      if (u-i)*r + v <= m then

        summand:= numer[ (u-i)*r + v + 1 ];
        for mu in [ 1 .. k-1 ] do
          summand:= summand * ( i - u + g + mu ) / mu;
        od;
        coeff:= coeff + summand;

      fi;

    od;

    return coeff;
end );


#############################################################################
##
#F  SummandMolienSeries( <tbl>, <psi>, <chi>, <i> )
##
InstallGlobalFunction( SummandMolienSeries, function( tbl, psi, chi, i )
    local x,          # indeterminate
          numer,      # numerator in summands corresp. to `i'-th class
          a,          # multiplicities of cycl. pol. in the denominator
          ev,         # eigenvalues of `psi' at class `i'
          n,          # element order of class `i'
          e,          # `E(n)'
          div,        # divisors of `n'
          d,          # loop over `div'
          roots,      # exponents of `d'-th prim. roots
          r;          # loop over `roots'

    x:= Indeterminate( Cyclotomics );

    if chi[i] = 0 then
      numer := Zero(x);
      a     := [ 1, 1 ];
    else

      ev := EigenvaluesChar( tbl, psi, i );
      n  := Length( ev );
      e  := E(n);

      # numerator of summands corresponding to `i'-th class
      numer:= chi[i] * e ^ Sum( [ 1 .. n ], j -> j * ev[j] ) * One( x );

      div:= ShallowCopy( DivisorsInt( n ) );
      RemoveSet( div, 1 );
      a:= List( [ 1 .. n ], x -> 0 );
      a[1]:= ev[n];

      for d in div do

        # compute $a_d$, that is, the maximal multiplicity of `ev[k]'
        # for all `k' with $\gcd(n,k) = n / d$.
        roots:= ( n / d ) * PrimeResidues( d );
        a[d]:= Maximum( ev{ roots } );
        for r in roots do
          if a[d] <> ev[r] then
            numer:= numer * ( x - e ^ r ) ^ ( a[d] - ev[r] );
          fi;
        od;

      od;

    fi;

    return rec( numer := numer,
                a     := a );
end );


#############################################################################
##
#F  MolienSeries( <psi> )
#F  MolienSeries( <psi>, <chi> )
#F  MolienSeries( <tbl>, <psi> )
#F  MolienSeries( <tbl>, <psi>, <chi> )
##
InstallGlobalFunction( MolienSeries, function( arg )
    local tbl,          # character table, first argument
          psi,          # character of `tbl', second argument
          chi,          # character of `tbl', optional third argument
          numers,       # list of numerators   of sum of polynomial quotients
          denoms,       # list of denominators of sum of polynomial quotients
          x,            # indeterminate
          tblclasses,   # class lengths of `tbl'
          orders,       # representative orders of `tbl'
          classes,      # list of classes of `tbl' that are not yet used
          sub,          # classes that belong to one cyclic subgroup
          i,            # represenative of `sub'
          n,            # element order of class `i'
          summand,      #
          numer,        # numerator in summands corresp. to `i'-th class
          div,          # divisors of `n'
          a,            # multiplicities of cycl. pol. in the denominator
          d,            # loop over `div'
          r,            # loop over `roots'
          f,            # `CF( n )'
          special,      # parameters of special factor in the denominator
          dd,           # loop over divisors of `d'
          p,            #
          q,            #
          j,            #
          F,            #
          pol,          #
          qr,           #
          num,          #
          pos,          #
          denpos,       #
          repr,         #
          series,       # Molien series, result
          denom,        # smallest common denominator for the summands
          denomstring,  # string of `denom', in factored form
          c,            # coefficients & valuation
          numerstring,  # string of `numer'
          denominfo,    # list of pairs `[ r, k ]' in the denominator
          rkpairs,      # list of pairs of the form `[ r, k ]'
          rr,           # `r' value of the current summand
          kk,           # `k' value of the current summand
          sumnumer,     # numerator of the current summand
          pair,         # loop over `rkpairs'
          min;          # minimum of `kk' and `k' value of the current pair

    # Check and get the arguments.
    if   Length( arg ) = 1 and IsClassFunction( arg[1] ) then
      tbl:= UnderlyingCharacterTable( arg[1] );
      psi:= ValuesOfClassFunction( arg[1] );
      chi:= List( psi, x -> 1 );
    elif Length( arg ) = 2 and IsClassFunction( arg[1] )
                           and IsClassFunction( arg[2] ) then
      tbl:= UnderlyingCharacterTable( arg[1] );
      psi:= ValuesOfClassFunction( arg[1] );
      chi:= ValuesOfClassFunction( arg[2] );
    elif Length( arg ) = 2 and IsOrdinaryTable( arg[1] )
                           and IsHomogeneousList( arg[2] ) then
      tbl:= arg[1];
      psi:= arg[2];
      chi:= List( psi, x -> 1 );
    elif Length( arg ) = 3 and IsOrdinaryTable( arg[1] )
                           and IsList( arg[2] )
                           and IsList( arg[3] ) then
      tbl:= arg[1];
      psi:= arg[2];
      chi:= arg[3];
    else
      Error( "usage: MolienSeries( [<tbl>, ]<psi>[, <chi>] )" );
    fi;

    # Initialize lists of numerators and denominators
    # of summands of the form $p_j(z) / (z^r-1)^k$.
    # In `numers[ <j> ]' the coefficients list of $p_j(z)$ is stored,
    # in `denoms[ <j> ]' the pair `[ r, k ]'.
    # `pol' is an additive polynomial.
    numers:= [];
    denoms:= [];
    x:= Indeterminate( Rationals );
    pol:= Zero( x );

    tblclasses:= SizesConjugacyClasses( tbl );
    classes:= [ 1 .. Length( tblclasses ) ];
    orders:= OrdersClassRepresentatives( tbl );

    # Take the cyclic subgroups of `tbl'.
    while not IsEmpty( classes ) do

      # Compute the next cyclic subgroup,
      # remove the classes of the cyclic subgroup,
      # take a representative.
      sub:= ClassOrbit( tbl, classes[1] );
      SubtractSet( classes, sub );
      i:= sub[1];

      # Compute $v(g) = \frac{\chi(g) \det(D(g))}{\det(z I - D(g))}$
      # for $g$ in class `i'.

      # This is encoded as record with components `numer' and `a'
      # where `a[r]' means the multiplicity of the `r'-th cyclotomic
      # polynomial in the denominator.
      summand:= SummandMolienSeries( tbl, psi, chi, i );

      # Omit summands with zero numerator.
      if not IsZero( summand.numer ) then

        numer:= CoefficientsOfLaurentPolynomial( summand.numer );
        a:= summand.a;

        # Compute the sum over class representatives of the cyclic
        # subgroup containing $g$, i.e., the relative trace of $v(g)$.
        n:= orders[i];
        f:= CF( n );
        numer:= List( ShiftedCoeffs( numer[1], numer[2] ),
                      y -> Trace( f, y ) )
                * ( Length( sub ) / Phi(n) );
        numer:= UnivariatePolynomial( Rationals, numer, 1 );

        # Try to reduce the number of factors in the denominator
        # by forming one factor of the form $(z^r - 1)^k$.
        # But we still want to guarantee that the factors are pairwise
        # coprime, that is, the exponents of all involved cyclotomic
        # polynomials must be equal.

        special:= false;

        if a[1] > 0 then

          # There is such a ``special\'\' factor.

          div:= DivisorsInt( n );
          for d in Reversed( div ) do

            if a[1] <> 0 and ForAll( DivisorsInt(d), y -> a[y] = a[1] ) then

              # The special factor is $( z^d - 1 ) ^ a[d]$.
              special:= [ d, a[d] ];
              for dd in DivisorsInt( d ) do
                a[dd]:= 0;
              od;

            fi;

          od;

        fi;

        # Compute the product of the remaining factors in the denominator.
        F:= One( x );
        for j in [ 1 .. n ] do
          if a[j] <> 0 then
            F:= F * CyclotomicPolynomial( Rationals, j ) ^ a[j];
          fi;
        od;

        if special <> false then

          # Split the summand into two summands, with denominators
          # the special factor `f' resp. the remaining factors `F'.
          f:= ( x ^ special[1] - 1 ) ^ special[2];
          repr:= GcdRepresentation( F, f );

          # Reduce the numerators if possible.
          num:= numer * repr[1];
          if special[1] * special[2]
             < DegreeOfLaurentPolynomial( num ) then
            qr:= QuotientRemainder( num, f );
            pol:= pol + tblclasses[i] * qr[1];
            num:= qr[2];
          fi;

          # Store the summand.
          denpos:= Position( denoms, special, 0 );
          if denpos = fail then
            Add( denoms, special );
            Add( numers, tblclasses[i] * num );
          else
            numers[ denpos ]:= numers[ denpos ] + tblclasses[i] * num;
          fi;

          # The remaining term is `numer \* repr[2] / F'.
          numer:= numer * repr[2];

        fi;

        # Split the quotient into a sum of quotients
        # whose denominators are cyclotomic polynomials.

        # We have $1 / \prod_{i=1}^k f_i = \sum_{i=1}^k p_i / f_i$
        # if the $f_i$ are pairwise coprime,
        # where the polynomials $p_i$ are computed by
        # $r_i \prod_{j>i} f_j + q_i f_i = 1$ for $1 \leq i \leq k-1$,
        # $r_k = 1$, and $p_i = r_i \prod_{j=1}^{i-1} q_j$.

        # In the end we have a sum of quotients with denominator of the
        # form $(z^r-1)^k$.  We store the pair $[ r, k ]$ in the list
        # `denoms', and $(-1)^k$ times the numerator in the list `numers'.

        pos:= 1;
        q:= 1;

        while pos <= n do

          if a[ pos ] <> 0 then

            # $f_i$ is the next factor encoded in `a'.
            f:= CyclotomicPolynomial( Rationals, pos ) ^ a[ pos ];
            F:= F / f;

            # $\prod_{j>i} f_j$ is stored in `F', and $f_i$ is in `f'.

            # at first position $r_i$, at second position $q_i$
            repr:= GcdRepresentation( F, f );

            # The numerator $p_i$.
            p:= q * repr[1];
            q:= q * repr[2];

            # We blow up the denominator $f_i$, and encode the summands.
            dd:= ShallowCopy( DivisorsInt( pos ) );
            RemoveSet( dd, pos );
            for r in dd do
              p:= p * CyclotomicPolynomial( Rationals, r ) ^ a[ pos ];
            od;

            # Reduce the numerators if possible.
            num:= numer * p;
            if DegreeOfLaurentPolynomial( num )
               > pos * a[ pos ] then
              qr:= QuotientRemainder( num, (x^pos - 1)^a[pos] );
              pol:= pol + tblclasses[i] * qr[1];
              num:= qr[2];
            fi;

            # Store the summand.
            denpos:= Position( denoms, [ pos, a[ pos ] ], 0 );
            if denpos = fail then
              Add( denoms, [ pos, a[ pos ] ] );
              Add( numers, tblclasses[i] * num );
            else
              numers[ denpos ]:= numers[ denpos ] + tblclasses[i] * num;
            fi;

          fi;

          pos:= pos + 1;

        od;

      fi;

    od;

    # Now compute the Taylor series for each summand.
    for i in [ 1 .. Length( numers ) ] do
      num:= CoefficientsOfLaurentPolynomial( numers[i] );
      num:= ShiftedCoeffs( num[1], num[2] );
      if IsEmpty( num ) then
        Unbind( numers[i] );
      else
        numers[i]:= rec( numer := num,
                         r     := denoms[i][1],
                         k     := denoms[i][2] );

        # Replace denominators $(z^r - 1)^k$ by $(1 - z^r)^k$.
        if numers[i].k mod 2 = 1 then
          numers[i].numer:= AdditiveInverse( numers[i].numer );
        fi;
      fi;
    od;

    numers:= Compacted( numers );

    # Sort the summands according to descending `r' component,
    # and for the same `r', according to descending `k'.
    Sort( numers, function( x, y )
                    return x.r > y.r or ( x.r = y.r and x.k > y.k );
                  end );

    pol:= CoefficientsOfLaurentPolynomial( pol );
    pol:= ShiftedCoeffs( pol[1], pol[2] );

    # Compute the display string.
    # First translate the sum of fractions into a single fraction.
    numer:= Zero( x );
    denom:= One( x );
    denomstring:= "";
    denominfo:= [];
    rkpairs:= [];

    for summand in numers do

      rr:= summand.r;
      kk:= summand.k;
      sumnumer:= UnivariatePolynomial( Rationals, summand.numer )
                 * denom;
      for pair in rkpairs do
        if kk <> 0 and pair[1] mod rr = 0 then
          min:= Minimum( kk, pair[2] );
          sumnumer:= sumnumer / ( 1 - x^rr )^min;
          kk:= kk - min;
        fi;
      od;
      if kk <> 0 then
        # Blow up the common denominator.
        numer:= numer * ( 1 - x^rr )^kk;
        denom:= denom * ( 1 - x^rr )^kk;
        Add( rkpairs, [ rr, kk ] );
        Append( denomstring, "(1-z" );
        if 1 < rr then
          Add( denomstring, '^' );
          Append( denomstring, String(rr) );
        fi;
        Add( denomstring, ')' );
        if 1 < kk then
          Add( denomstring, '^' );
          Append( denomstring, String(kk) );
        fi;
        Add( denomstring, '*' );
        Append( denominfo, [ rr, kk ] );
      fi;
      numer:= numer + sumnumer;
    od;
    if not IsEmpty( pol ) then
      numer:= numer + denom * UnivariatePolynomial( Rationals, pol );
    fi;
    numer:= numer / Size( tbl );
    if psi[1] mod 2 = 1 then
      numer:= - numer;
    fi;
    denomstring:= denomstring{ [ 1 .. Length(denomstring)-1] };
    ConvertToStringRep( denomstring );

    c:= CoefficientsOfLaurentPolynomial( numer );
    numerstring:= StringOfUnivariateRationalPolynomialByCoefficients(
        Concatenation( ListWithIdenticalEntries( c[2], 0 ), c[1] ), "z" );

    # Compute the series.
    series:= numer / denom;
#T avoid forming this quotient!
    SetIsUnivariateRationalFunction( series, true );

    # Set the info record.
    SetMolienSeriesInfo( series,
                         rec( summands    := numers,
                              size        := Size( tbl ),
                              degree      := psi[1],
                              pol         := pol,
                              numer       := numer,
                              denom       := denom,
                              denominfo   := denominfo,
                              numerstring := numerstring,
                              denomstring := denomstring,
                              ratfun      := series
                             ) );

    # Return the series.
    return series;
end );


#############################################################################
##
#F  MolienSeriesWithGivenDenominator( <molser>, <list> )
##
InstallGlobalFunction( MolienSeriesWithGivenDenominator,
    function( molser, list )
    local info,
          x,
          one,
          denom,
          pair,
          numer,
          c,
          numerstring,
          denomstring,
          rr, kk,
          coeffs,
          series;

    if not HasMolienSeriesInfo( molser ) then
      Error( "MolienSeriesInfo must be known for <molser>" );
    fi;
    info:= MolienSeriesInfo( molser );

    # Compute the numerator that belongs to the desired denominator.
    list:= Collected( list );
    x:= Indeterminate( Rationals );
    one:= One( x );
    denom:= one;
    for pair in list do
      denom:= denom * ( one - x^pair[1] )^pair[2];
    od;
    numer:= denom * info.numer / info.denom;
    if not IsUnivariatePolynomial( numer ) then
      return fail;
    fi;

    # Create the strings for numerator and denominator.
    c:= CoefficientsOfLaurentPolynomial( numer );
    numerstring:= StringOfUnivariateRationalPolynomialByCoefficients(
        Concatenation( ListWithIdenticalEntries( c[2], 0 ), c[1] ), "z" );

    denomstring:= "";
    for pair in Reversed( list ) do
      rr:= pair[1];
      kk:= pair[2];
      Append( denomstring, "(1-z" );
      if 1 < rr then
        Add( denomstring, '^' );
        Append( denomstring, String(rr) );
      fi;
      Add( denomstring, ')' );
      if 1 < kk then
        Add( denomstring, '^' );
        Append( denomstring, String(kk) );
      fi;
      Add( denomstring, '*' );
    od;
    denomstring:= denomstring{ [ 1 .. Length(denomstring)-1] };
    ConvertToStringRep( denomstring );

    # Create the Molien series object (create the rat. function
    # from the given one, without division).
    coeffs:= CoefficientsOfUnivariateRationalFunction( info.ratfun );
    series:= UnivariateRationalFunctionByExtRepNC( FamilyObj( info.ratfun ),
        coeffs[1], coeffs[2], coeffs[3],
        IndeterminateNumberOfUnivariateRationalFunction( info.ratfun ) );
    SetIsUnivariateRationalFunction( series, true );
#T why is this not automatically maintained?
    SetMolienSeriesInfo( series,
                         rec(
                              # We need not adjust these components
                              summands:= info.summands,
                              size:= info.size,
                              degree:= info.degree,
                              pol:= info.pol,

                              # These components are new.
                              ratfun:= series,
                              numer:= numer,
                              denom:= denom,
                              denominfo := Immutable( list ),
                              numerstring := numerstring,
                              denomstring := denomstring ) );

    # Return the new series.
    return series;
end );


#############################################################################
##
#M  ViewObj( <molser> ) . . . . . . . . . . . . . . . . . for a Molien series
#M  PrintObj( <molser> )  . . . . . . . . . . . . . . . . for a Molien series
##
BindGlobal( "ViewMolienSeries", function( molser )
    molser:= MolienSeriesInfo( molser );
    Print( "( ", molser.numerstring, " ) / ( ", molser.denomstring, " )" );
end );

InstallMethod( ViewObj,
    "for a Molien series",
    [ IsRationalFunction and IsUnivariateRationalFunction
      and HasMolienSeriesInfo ],
    ViewMolienSeries );

InstallMethod( PrintObj,
    "for a Molien series",
    [ IsRationalFunction and IsUnivariateRationalFunction
      and HasMolienSeriesInfo ],
    ViewMolienSeries );


#############################################################################
##
#F  ValueMolienSeries( series, i )
##
InstallGlobalFunction( ValueMolienSeries, function( series, i )
    local value;

    series:= MolienSeriesInfo( series );
    value:= Sum( series.summands,
                 s -> CoefficientTaylorSeries( s.numer, s.r, s.k, i ), 0 );
    if i+1 <= Length( series.pol ) then
      value:=value + series.pol[i+1];
    fi;

    # There is a factor $\frac{(-1)^{\psi(1)}}{\|G\|}$.
    if series.degree mod 2 = 1 then
      value:= AdditiveInverse( value );
    fi;

    return value / series.size;
end );
