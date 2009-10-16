#############################################################################
##
#W  signatur.gi            GAP 4 package `genus'                Thomas Breuer
##
#H  @(#)$Id: signatur.gi,v 1.6 2002/05/24 15:06:47 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementations concerning signatures.
##
##  1. Definition of Signatures
##  2. Creating Signatures
##  3. Operations for Signatures
##  4. Computing Admissible Signatures for Fixed Genus of a Surface Kernel
##
Revision.( "pkg/genus/signatur_gi" ) :=
    "@(#)$Id: signatur.gi,v 1.6 2002/05/24 15:06:47 gap Exp $";


#############################################################################
##
##  1. Definition of Signatures
##


#############################################################################
##
#M  String( <sign> )
##
InstallMethod( String,
    "for a signature",
    [ IsCompactSignature ],
    function( sign )
    local str, periods, mi;
    str:= Concatenation( "(", String( GenusOfSignature( sign ) ), ";" );
    periods:= PeriodsOfSignature( sign );
    if IsEmpty( periods ) then
      Append( str, "-)" );
    else
      for mi in periods do
        Append( str, String( mi ) );
        Add( str, ',' );
      od;
      str[ Length( str ) ]:= ')';
    fi;
    return str;
    end );


#############################################################################
##
#M  PrintObj( <sign> )
##
InstallMethod( PrintObj,
    "for a signature",
    [ IsCompactSignature ],
    function( sign )
    Print( "Signature( ", GenusOfSignature( sign ), ", ",
                          PeriodsOfSignature( sign ), " )" );
    end );


#############################################################################
##
#M  ViewObj( <sign> )
##
InstallMethod( ViewObj,
    "for a signature",
    [ IsCompactSignature ],
    function( sign )
    Print( String( sign ) );
    end );


#############################################################################
##
#M  \=( <sign1>, <sign2> )
##
InstallMethod( \=,
    "for two signatures",
    [ IsCompactSignature, IsCompactSignature ],
    function( sign1, sign2 )
    return     GenusOfSignature( sign1 ) = GenusOfSignature( sign2 )
           and PeriodsOfSignature( sign1 ) = PeriodsOfSignature( sign2 );
    end );


#############################################################################
##
#M  \<( <sign1>, <sign2> )
##
InstallMethod( \<,
    "for two signatures",
    [ IsCompactSignature, IsCompactSignature ],
    function( sign1, sign2 )
    local g1, g2;
    g1:= GenusOfSignature( sign1 );
    g2:= GenusOfSignature( sign2 );
    return    g1 < g2
           or ( g1 = g2 and PeriodsOfSignature( sign1 ) < PeriodsOfSignature( sign2 ) );
    end );


#############################################################################
##
##  2. Creating Signatures 
##


#############################################################################
##
#M  Signature( <genus>, <periods> )
##
InstallMethod( Signature,
    "for genus and periods",
    [ IsInt, IsHomogeneousList ],
    function( g, periods )

    local d, sign;

    # Check and normalize the arguments.
    if IsNegInt( g ) then
      Error( "<g> must be nonnegative" );
    elif not ForAll( periods, IsPosInt ) then
      Error( "<periods> must consist of positive integers" );
    elif not IsSortedList( periods ) or 1 in periods then
      periods:= Filtered( periods, mi -> 1 < mi );
      Sort( periods );
    fi;
    if g = 0 then
      if   Length( periods ) = 1 then
        periods:= [];
      elif Length( periods ) = 2 and periods[1] <> periods[2] then
        d:= Gcd( Integers, periods[1], periods[2] );
        periods:= [ d, d ];
      fi;
    fi;

    # Create and return the object.
    sign:= rec();
    ObjectifyWithAttributes( sign, DefaultTypeOfSignature,
                             GenusOfSignature, g,
                             PeriodsOfSignature, periods );
    return sign;
    end );


#############################################################################
##
#M  SignatureOfEichlerCharacter( [<tbl>, ]<chi> )
##
InstallMethod( SignatureOfEichlerCharacter,
    "for a character",
    [ IsClassFunction ],
    chi -> SignatureOfEichlerCharacter( UnderlyingCharacterTable( chi ),
                                        ValuesOfClassFunction( chi ) ) );

InstallMethod( SignatureOfEichlerCharacter,
    "for an ordinary character table, and a character values list",
    [ IsOrdinaryTable, IsHomogeneousList ],
    function( tbl, chi )

    local fams,        # Galois families info
          repcycsub,   # positions of representatives of cyclic subgroups
          fusion,
          inverse,
          i, j,        # loop variables
          powermap,
          p,
          r_chi,
          r_chi_G,
          orders,
          positions,
          centralizers,
          normsizes,
          n,
          d,
          ii,
          periods,
          sign;        # the signature, result

    # Compute representatives of cyclic subgroups.
    fams:= GaloisMat( TransposedMat( Irr( tbl ) ) ).galoisfams;
    repcycsub:= [];
    fusion:= [];
    inverse:= [];
    for i in [ 1 .. Length( fams ) ] do
      if fams[i] = 1 then
        Add( repcycsub, i );
        fusion[i]:= Length( repcycsub );
        inverse[ fusion[i] ]:= [ i ];
      elif IsList( fams[i] ) then
        Add( repcycsub, i );
        for j in fams[i][1] do
          fusion[j]:= Length( repcycsub );
        od;
        inverse[ Length( repcycsub ) ]:= fams[i][1];
      fi;
    od;
#T GAP function of its own?

    # Rewrite the power maps as maps on the positions of `repcycsub'.
    powermap:= [];
    for p in Set( Factors( Size( tbl ) ) ) do
      powermap[p]:= CompositionMaps( fusion,
          CompositionMaps( PowerMap( tbl, p ), inverse ) );
    od;

    # Compute the vector of $r_{\chi}$.
    r_chi:= List( repcycsub, i -> 2 - chi[i] - GaloisCyc( chi[i], -1 ) );

    # Compute the vector of $r_{\chi}^G$ by subtractions
    # according to decreasing element orders.
    r_chi_G:= ShallowCopy( r_chi );
    orders:= OrdersClassRepresentatives( tbl ){ repcycsub };
    positions:= [ 1 .. Length( orders ) ];
    SortParallel( ShallowCopy( orders ), positions );

    centralizers:= SizesCentralizers( tbl );
    normsizes:= List( [ 1 .. Length( repcycsub ) ],
                      i -> centralizers[ repcycsub[i] ]
                           * Phi( orders[i] ) / Length( inverse[i] ) );

    for i in Reversed( positions ) do
      n:= orders[i];
      for d in DivisorsInt( n ) do
        if d <> 1 then
          ii:= i;
          for p in Factors( d ) do
            ii:= powermap[p][ii];
          od;
          r_chi_G[ ii ]:= r_chi_G[ ii ]
              - normsizes[ ii ] / normsizes[i] * r_chi_G[i];
        fi;
      od;
    od;

    # Compute the vector $l_{\chi}^G$.
    r_chi_G[1]:= 0;
    for i in [ 2 .. Length( r_chi_G ) ] do
      r_chi_G[i]:= r_chi_G[i] * orders[i] / normsizes[i];
    od;

    # Check whether the character `chi' has a well-defined signature.
    if not ForAll( r_chi_G, x -> IsInt( x ) and 0 <= x ) then
      return fail;
    fi;

    # Compute the periods.
    periods:= [];
    for i in [ 2 .. Length( r_chi_G ) ] do
      for j in [ 1 .. r_chi_G[i] ] do
        Add( periods, orders[i] );
      od;
    od;

    # Construct and return the signature.
    return Signature( chi * SizesConjugacyClasses( tbl ), sign );
    end );


#############################################################################
##
##  3. Operations for Signatures
##


#############################################################################
##
#M  Curvature( <sign> )
##
InstallMethod( Curvature,
    "for a signature",
    [ IsCompactSignature ],
    function( sign )
    local kappa, mi;
    kappa:= 2 - 2 * GenusOfSignature( sign );
    for mi in PeriodsOfSignature( sign ) do
      kappa:= kappa + 1 - 1/mi;
    od;
    return kappa;
    end );


#############################################################################
##
#F  GenusOfSurfaceKernel( <sign>, <n> )
##
InstallGlobalFunction( GenusOfSurfaceKernel, function( sign, n )
    local g, i;
    g:= n * ( GenusOfSignature( sign ) - 1 ) + 1;
    for i in PeriodsOfSignature( sign ) do
      g:= g + n/2 * ( 1 - 1/i );
    od;
    return g;
end );


#############################################################################
##
#F  GroupOrderOfSurfaceKernelFactor( <sign>, <g> )
##
InstallGlobalFunction( GroupOrderOfSurfaceKernelFactor, function( sign, g )
    local n, i;
    n:= GenusOfSignature( sign ) - 1;
    for i in PeriodsOfSignature( sign ) do
      n:= n + 1/2 * ( 1 - 1/i );
    od;
    return ( g - 1 ) / n;
end );


#############################################################################
##
#M  AbelianInvariants( <sign> )
##
InstallMethod( AbelianInvariants,
    "for a signature",
    [ IsCompactSignature ],
    function( sign )

    local periods,
          invariants,
          p,
          pparts,
          i,
          ppart,
          period;

    periods:= ShallowCopy( PeriodsOfSignature( sign ) );
    invariants:= ListWithIdenticalEntries( 2 * GenusOfSignature( sign ), 0 );

    while not IsEmpty( periods ) do
      p:= Factors( periods[1] )[1];
      pparts:= [];
      for i in [ 1 .. Length( periods ) ] do
        ppart:= 1;
        period:= periods[i];
        while period mod p = 0 do
          ppart:= ppart * p;
          period:= period / p;
        od;
        if ppart <> 1 then
          Add( pparts, ppart );
          periods[i]:= period;
        fi;
      od;
      Sort( pparts );
      Append( invariants, pparts{ [ 1 .. Length( pparts )-1 ] } );
      periods:= Filtered( periods, x -> x <> 1 );
    od;

    return AbelianInvariantsOfList( invariants );
    end );


#############################################################################
##
#M  IsPerfectSignature( <sign> )
##
InstallMethod( IsPerfectSignature,
    "for a compact signature",
    [ IsCompactSignature ],
    sign ->     GenusOfSignature( sign ) = 0
            and IsPairwiseCoprimeList( PeriodsOfSignature( sign ) ) );


#############################################################################
##
#F  IsCyclicSignature( <sign>, <n> )
##
##  Consider $\Gamma = \Gamma(g; m_1, m_2, \ldots, m_r)$,
##  and let $M$ be the l.c.m. of the $m_i$.
##  Then $\Gamma$ has a cyclic surface kernel factor of order $n$
##  if and only if the following four conditions hold.
##  \beginlist 
##  \item{(i)} 
##      $M$ is the l.c.m. of
##      $(m_1, m_2, \ldots, m_{i-1}, m_{i+1}, \ldots, m_r)$ for all $i$,
##  \item{(ii)}
##      $M$ divides $n$, and if $g = 0$, we have $M = n$,
##  \item{(iii)} 
##      $r \not= 1$, and if $g_0 = 0$, we have $r \geq 3$,
##  \item{(iv)}
##      if $M$ is even then the number of $i$ with $m_i$ divisible by the
##      maximum power of $2$ dividing $M$ is even.
##  \endlist
##
InstallGlobalFunction( IsCyclicSignature, function( sign, n )
    local g,
          r,
          m,
          M,
          i,
          x,
          2pow,
          even;

    g:= GenusOfSignature( sign );
    m:= PeriodsOfSignature( sign );
    r:= Length( m );

    # condition (iii)
    if r = 1 or ( g = 0 and r < 3 ) then
      return false;
    fi;

    # condition (ii)
    if r = 0 then
      M:= 1;
    else
      M:= Lcm( m );
    fi;
    if n mod M <> 0 or ( g = 0 and n <> M ) then
      return false;
    fi;

    # condition (i)
    m:= ShallowCopy( m );
    for i in [ 1 .. Length( m ) ] do
      x:= m[i];
      m[i]:= 1;
      if Lcm( m ) mod x <> 0 then
        return false;
      fi;
      m[i]:= x;
    od;

    # condition (iv)
    if M mod 2 = 0 then
      2pow:= 1;
      while M mod 2 = 0 do
        2pow:= 2pow * 2;
        M:= M / 2;
      od;
      even:= 0;
      for i in m do
        if i mod 2pow = 0 then
          even:= even + 1;
        fi;
      od;
      if even mod 2 = 1 then
        return false;
      fi;
    fi;

    return true;
end );


#############################################################################
##
#F  InvariantsOfAbelianSurfaceKernelFactors( <sign>, <m> )
##
##  Let $M$ be the l.c.m. of the $m_i$.
##  The following conditions are necessary and sufficient for an abelian
##  surface kernel factor $A$ of $\Gamma = \Gamma(g; m_1, m_2, \ldots, m_r)$.
##  \beginlist
##  \item{(o)}
##      There is an epimorphism from $\Gamma$ onto $A$,
##  \item{(i)}
##      $M$ is the l.c.m. of
##      $(m_1, m_2, \ldots, m_{i-1}, m_{i+1}, \ldots, m_r)$ for all $i$,
##  \item{(ii)}
##      $M$ divides the exponent $\exp(A)$ of $A$,
##      and if $g_0 = 0$, $M = \exp(A)$,
##  \item{(iii)}
##      $r \not= 1$, and if $g_0 = 0$, we have $r \geq 3$,
##  \item{(iv)}
##      if $M$ is even and only one of the abelian invariants of $A$ is
##      divisible by the maximum power of $2$ dividing $M$,
##      the number of periods $m_i$ divisible by the maximum power
##      of $2$ dividing $M$ is even.
##  \endlist
##
InstallGlobalFunction( InvariantsOfAbelianSurfaceKernelFactors,
    function( sign, m )

    local g0,            # orbit genus of `sign'
          r,             # no. of periods
          invariants,    # list of invariants, result
          periods,       # periods of `sign'
          M,             # l.c.m. of the periods
          i,             # loop variable
          mi,            # loop over the periods
          facts,         # collected list of prime factors of `m'
          pair,          # loop over `facts'
          p,             # one prime factor
          exp,           # multiplicity of `p'
          Mppart,        #
          pperiods,      #
          pp,            #
          biginv,        #
          pinvariants,   #
          tuple,         #
          tup;           #

    if m = 1 then
      return [ [ ] ];
    fi;

#T use also global bound 4g+4 for an abelian group?
#T (then g must be computed)
    g0:= GenusOfSignature( sign );
    periods:= PeriodsOfSignature( sign );
    r:= Length( periods );

    # Check condition (iii).
    if r = 1 or ( g0 = 0 and r < 3 ) then
      return [];
    fi;

    if r = 0 then
      M:= 1;
    else
      M:= Lcm( periods );
    fi;

    # Check a weak form of condition (ii).
    if m mod M <> 0 then
      return [];
    fi;

    # Check condition (i).
    periods:= ShallowCopy( periods );
    for i in [ 1 .. r ] do
      mi:= periods[i];
      periods[i]:= 1;
      if Lcm( periods ) <> M then
        return [];
      fi;
      periods[i]:= mi;
    od;

    invariants:= [];

    # Loop over the possible choices of abelian invariants of groups
    # of order `m'.
    # For each prime divisor $p$ of `m',
    # we compute the possible abelian invariants of the $p$-part.
    facts:= Collected( Factors( m ) );
    for pair in facts do

      p:= pair[1];
      exp:= pair[2];

      Mppart:= 0;
      while M mod p = 0 do
        Mppart:= Mppart + 1;
        M:= M / p;
      od;

      # Compute the `p'-parts of the periods.
      pperiods:= [];
      for mi in periods do
        pp:= 1;
        while mi mod p = 0 do
          mi:= mi / p;
          pp:= pp * p;
        od;
        if pp <> 1 then
          Add( pperiods, pp );
        fi;
      od;

      # Compute the `p'-abelian invariants of $\Gamma$.
      Sort( pperiods );
      if g0 = 0 then
        biginv:= ShallowCopy( pperiods );
      else
        biginv:= Concatenation( 0 * [ 1 .. 2*g0 ], pperiods );
      fi;
      if not IsEmpty( pperiods ) then
        Unbind( biginv[ Length( biginv ) ] );
      fi;

      pinvariants:= [];

      for tuple in Partitions( exp ) do

        # Check conditions (ii) and (iv).
        # (Note that the entries of a partition are non-increasing.)
        if     Mppart <= tuple[1]
           and ( g0 > 0 or Mppart = tuple[1] )
           and (    p <> 2
                 or 1 < Number( tuple, x -> Mppart <= x )
                 or ( Number( pperiods, mi -> mi = p^Mppart ) mod 2 = 0 ) )
        then
#T better!

          tup:= List( tuple, x -> p^x );
          if IsCompatibleAbelianInvariants( biginv, tup ) then
            Add( pinvariants, tup );
          fi;

        fi;

      od;

      if IsEmpty( pinvariants ) then
        return pinvariants;
      fi;
      Add( invariants, pinvariants );

    od;

    invariants:= List( Cartesian( invariants ), Concatenation );
    for i in invariants do
      Sort( i );
    od;
    Sort( invariants );

    # Return the result.
    return invariants;
end );


#############################################################################
##
#F  IsAbelianSignature( <sign>, <m> )
##
InstallGlobalFunction( IsAbelianSignature, function( sign, m )
    return not IsEmpty( InvariantsOfAbelianSurfaceKernelFactors( sign, m ) );
end );


#############################################################################
##
#F  SignaturesOfPrimeIndex( <sign>, <p> )
##
##  We use the general theorem (see the Appendix of ~\cite{Sah69})
##  that for a normal subgroup $H$ of index $d$ in a group $\Gamma$ with
##  signature $(g; m_1, m_2, \ldots, m_r)$,
##  where the order of the elliptic generator $c_i$ modulo $H$ is $t_i$,
##  the orbit genus of $H$ is equal to
##  $1 + d (g-1) + \frac{d}{2} \sum_{i=1}^r (1-1/t_i)$,
##  and the periods of $H$ are
##  $f_{ij} = m_i/t_i$, $1 \leq j \leq p/t_i$, $1 \leq i \leq r$,
##  where $f_{ij} = 1$ are omitted.
##
##  In this special case, we have $t_i = p$ if and only if $c_i$ lies outside
##  $H$, and $t_i = 1$ otherwise.
##
InstallGlobalFunction( SignaturesOfPrimeIndex, function( sign, p )

    local g,
          periods,
          coprime,
          multipl,
          values,
          per,
          pos,
          len,
          signatures,
          tuple,
          i,
          sum,
          new,
          newg,
          j;

    g:= GenusOfSignature( sign );
    periods:= PeriodsOfSignature( sign );

    # Periods that are coprime to <p> lie in the kernel of the
    # epimorphism.
    # They occur in the signatures of the index <p> subgroups,
    # each with multiplicity <p>.
    # Each period that is divisible by <p> lies either in the
    # kernel or outside.
    coprime:= [];
    multipl:= [];
    values:= [];
    for per in periods do
      if per mod p <> 0 then
        Add( coprime, per );
      else
        pos:= Position( values, per );
        if pos = fail then
          Add( values, per );
          Add( multipl, 1 );
        else
          multipl[ pos ]:= multipl[ pos ] + 1;
        fi;
      fi;
    od;
    coprime:= Concatenation( List( [ 1 .. p ], i -> coprime ) );
    len:= Length( values );

    # Loop over all vectors of length `len'
    # with entries bounded by `multipl',
    # and interpret the number in each column as number of periods
    # not lying in the kernel.
    # If `g = 0' then take only those vectors with at least two periods
    # outside the kernel.
    # If `p = 2' then take only those vectors where this number is even.
    signatures:= [];
    tuple:= ListWithIdenticalEntries( len, 0 );
    while true do
      i:= 1;
      while i <= len and tuple[i] = multipl[i] do
        tuple[i]:= 0;
        i:= i+1;
      od;
      if len < i then

        # All vectors have been inspected.
        Sort( signatures );
        return signatures;

      fi;
      tuple[i]:= tuple[i] + 1;
      sum:= Sum( tuple, 0 );
      if ( 0 < g or 2 <= sum ) and ( p <> 2 or sum mod 2 = 0 ) then

        # Set up the list of periods.
        new:= ShallowCopy( coprime );
        for i in [ 1 .. Length( tuple ) ] do
          if values[i] <> p then
            for j in [ 1 .. tuple[i] ] do
              Add( new, values[i] / p );
            od;
          fi;
          Append( new, ListWithIdenticalEntries(
                           p * ( multipl[i] - tuple[i] ), values[i] ) );
        od;
        Sort( new );

        # Compute the orbit genus.
        newg:= 1 + (g-1) * p + sum * (p-1) / 2;

        # Create the signature.
        Add( signatures, Signature( newg, new ) );

      fi;
    od;
end );


#############################################################################
##
##  m. Computing Admissible Signatures for Fixed Genus of a Surface Kernel
##


#############################################################################
##
#V  PRE_SIGNATURES
#V  CYC_SIGNATURES
#V  ADM_SIGNATURES
#V  CYCLIC_ORDERS
#V  CYCLIC_PERIODS
##
InstallFlushableValue( PRE_SIGNATURES, [] );
InstallFlushableValue( CYC_SIGNATURES, [] );
InstallFlushableValue( ADM_SIGNATURES, [] );
InstallFlushableValue( CYCLIC_ORDERS, [] );
InstallFlushableValue( CYCLIC_PERIODS, [] );


#############################################################################
##
#F  PreSignatures( <g>, <g0>, <n> )
##
InstallGlobalFunction( PreSignatures, function( g, g0, n )
    local posssign, # list of signatures, result
          ram,      # ramification of the covering
          ks,
          coeffs,
          poss,
          sign,
          i, j;

    if ( 84*(g-1) < n ) or ( n + (g-1) < n * g0 ) then
      return [];
    elif not IsBound( PRE_SIGNATURES[g] ) then
      PRE_SIGNATURES[g]:= [];
    fi;
    if not IsBound( PRE_SIGNATURES[g][ g0+1 ] ) then
      PRE_SIGNATURES[g][ g0+1 ]:= [];
    fi;
    if IsBound( PRE_SIGNATURES[g][ g0+1 ][n] ) then
      return PRE_SIGNATURES[g][ g0+1 ][n];
    fi;

    # Compute the signatures recursively,
    # where the contribution of the first `pos - 1' divisors
    # to the ramification is known,
    # and `left' is the sum to be distributed to the remaining divisors.
    poss:= function( values, pos, left )
      local k, bound;

      if left = 0 then

        # The ramification is distributed.
        # Construct and store the signature.
        sign:= [];
        for i in [ 1 .. Length( ks ) ] do
          for j in [ 1 .. values[i] ] do
            Add( sign, ks[i] );
          od;
        od;
        Add( posssign, Signature( g0, sign ) );

      elif pos <= Length( ks ) then

        # Loop over the possible multiplicities of the `pos'-th divisor.
        bound:= Int( left / coeffs[ pos ] );
        values:= ShallowCopy( values );
        left:= left + coeffs[ pos ];
        for k in [ 0 .. bound ] do
          values[ pos ]:= k;
          left:= left - coeffs[ pos ];
          poss( values, pos+1, left );
        od;

      fi;
    end;

    # According to the Riemann-Hurwitz relation, the
    # ramification of the covering is $(2g-2) - n(2g_0-2)$.
    ram:= 2*g - 2 - n*(2*g0-2);

    # The ramification is a sum of terms of the form $n ( 1 - 1/k )$,
    # where $k$ is a divisor of $n$, $k \not= 1$.
    ks:= ShallowCopy( DivisorsInt( n ) );
    RemoveSet( ks, 1 );
    coeffs:= List( ks, k -> n*(k-1)/k );

    # Call the recursion.
    posssign:= [];
    poss( List( ks, x -> 0 ), 1, ram );

    # Store the signatures.
    MakeImmutable( posssign );
    PRE_SIGNATURES[g][ g0+1 ][n]:= posssign;

    return posssign;
end );


#############################################################################
##
#F  CyclicSignatures( <g>, <g0>, <n> )
#F  CyclicSignatures( <g>, <g0> )
#F  CyclicSignatures( <g> )
##
InstallGlobalFunction( CyclicSignatures, function( arg )
    local g,
          g0,
          n,
          cycsign;  # list of signatures, result

    # Get and check the arguments.
    if   Length( arg ) = 3 and IsInt( arg[1] ) and 2 <= arg[1]
                           and IsInt( arg[2] ) and 0 <= arg[2]
                           and IsPosInt( arg[3] ) then
      g  := arg[1];
      g0 := arg[2];
      n  := arg[3];
    elif Length( arg ) = 2 and IsInt( arg[1] ) and 2 <= arg[1]
                           and IsInt( arg[2] ) and 0 <= arg[2] then
      g  := arg[1];
      g0 := arg[2];
      n  := "all";
    elif Length( arg ) = 1 and IsInt( arg[1] ) and 2 <= arg[1] then
      g  := arg[1];
      g0 := "all";
      n  := "all";
    else
      Error( "usage: CyclicSignatures( <g>[, <g0>[, <n>]] )" );
    fi;

    cycsign:= [];

    if   g0 = "all" and n = "all" then

      for g0 in [ 0 .. g ] do
        Add( cycsign, CyclicSignatures( g, g0, "all" ) );
      od;

    elif n = "all" then

      # If the signatures have been stored already, just return them.
      if not IsBound( CYC_SIGNATURES[g] ) then
        CYC_SIGNATURES[g]:= [];
      elif IsBound( CYC_SIGNATURES[g][ g0+1 ] ) then
        return CYC_SIGNATURES[g][ g0+1 ];
      fi;
#T this assumes that values are not stored for single n!

      # The element order in an automorphism group of a Riemann surface
      # of genus $g$ is at most $4 g + 2$.
      for n in [ 2 .. 4*g+2 ] do
        cycsign[n]:= CyclicSignatures( g, g0, n );
      od;

      # Store the signatures.
      CYC_SIGNATURES[g][ g0+1 ]:= cycsign;

    else

      # If the signatures have been stored already, just return them.
      if IsBound( CYC_SIGNATURES[g] ) and IsBound( CYC_SIGNATURES[g][ g0+1 ] )
         and IsBound( CYC_SIGNATURES[g][ g0+1 ][n] ) then
        return CYC_SIGNATURES[g][ g0+1 ][n];
      fi;
#T do not store (see above ...)

      # Apply Harvey's criterion.
      cycsign:= Filtered( PreSignatures( g, g0, n ),
                          sign -> IsCyclicSignature( sign, n ) );

    fi;

    return cycsign;
end );


#############################################################################
##
#F  CyclicOrders( <g> )
##
InstallGlobalFunction( CyclicOrders, function( g )
    local orders,    # list of orders, result
          periods,   # candidates for orders to test
          g0,        # loop over the orbit genus
          ord;       # loop over `periods'

    if not IsInt( g ) or g < 2 then
      Error( "<g> must be an integer >= 2" );
    fi;

    if not IsBound( CYCLIC_ORDERS[g] ) then
      orders:= [];
      periods:= [ 2 .. 4*g+2 ];
      for g0 in [ 0 .. g ] do
        UniteSet( orders, Filtered( periods, ord -> 
          not IsEmpty( CyclicSignatures( g, g0, ord ) ) ) );
        SubtractSet( periods, orders );
      od;
      MakeImmutable( orders );
      CYCLIC_ORDERS[g]:= orders;
    fi;
    return CYCLIC_ORDERS[g];
end );


#############################################################################
##
#F  CyclicPeriods( <g> )
##
##  These periods can be computed by `CyclicSignatures'.
##  Note that a period, if it occurs at all, must occur as period in a
##  signature of a cyclic automorphism group.
##
InstallGlobalFunction( CyclicPeriods, function( g )
    local periods,   # list of periods, result
          g0,        # loop over the orbit genus
          ord,       # loop over possible orders
          sign;      # loop over signatures

    if not IsInt( g ) or g < 2 then
      Error( "<g> must be an integer >= 2" );
    fi;

    if not IsBound( CYCLIC_PERIODS[g] ) then
      periods:= [];
      for g0 in [ 0 .. g ] do
        for ord in [ 2 .. 4*g+2 ] do
          for sign in CyclicSignatures( g, g0, ord ) do
             UniteSet( periods, PeriodsOfSignature( sign ) );
          od;
        od;
      od;
      MakeImmutable( periods );
      CYCLIC_PERIODS[g]:= periods;
    fi;
    return CYCLIC_PERIODS[g];
end );


#############################################################################
##
#F  IsSignatureOnlyForAbelianGroup( <periods>, <n> )
##
InstallGlobalFunction( IsSignatureOnlyForAbelianGroup, function( periods, n )
    local facts;

    if n in periods then
      return true;
    fi;

    facts:= Factors( n );
    if ( Length( facts ) = 1 ) or
       ( Length( facts ) = 2 and facts[1] = facts[2] ) or
       ( Length( facts ) = 2 and facts[1] < facts[2]
                             and ( facts[2] - 1 ) mod facts[1] <> 0 ) or
       ( Length( facts ) = 3 and facts[1] = facts[2] and facts[2] < facts[3]
                             and ( facts[3] - 1 ) mod facts[1] <> 0 ) then
      return true;
    fi;
#T change this: use `IsAbelianNumber' etc.

    return false;
end );


#############################################################################
##
#F  TestAdmissibleSignature( <sign>, <n> )
##
##  Let $<sign> = (g_0; m_1, m_2, \ldots, m_r)$ be a signature,
##  $\Gamma$ a group with signature <sign>,
##  and $g$ the orbit genus of a torsion-free normal subgroup of index <n> in
##  $\Gamma$.
##  (For example, <sign> can be computed by
##  `PreSignatures( $g, g_0$, <n> )'.)
##
##  If at least one of the following situations occurs then the signature is
##  not admissible,
##  and the value of the component `isAdmissibleSignature' is `false',
##  otherwise it is `true'.
##  \beginlist
##  \item{1.}
##      One of the periods $m_i$ does not divide <n>.
##  \item{2.}
##      <sign> is not the signature of an abelian group of order <n>
##      (as computed by `IsAbelianSignature') but
##      one of the periods $m_i$ is equal to <n> or
##      every group of order <n> is abelian
##      (see~"IsSignatureOnlyForAbelianGroup").
##  \item{3.}
##      $<n> \equiv 2 \pmod{4}$ and $g_0 = 0$ but there are no even periods.
##  \item{4.}
##      $<n> = 2 m_i$ for an $i$ and at most one of the *other* periods is
##      even.
##  \item{5.}
##      Not all periods $m_i$ or not all prime divisors of <n> occur as
##      orders of automorphisms of compact Riemann surfaces of genus <g>.
##      (These orders can be computed using `CyclicSignatures',
##      see~"CyclicSignatures".)
##  \item{6.}
##      Not all periods $m_i$ are among the *periods* of signatures
##      for cyclic automorphism groups of order $m_i$.
##  \item{7.}
##      The signature is of the form $(g; pk)$ for a prime $p$,
##      and $<n> = p^2 k$.
##  \item{8.}
##      <sign> is a perfect signature (see~"IsPerfectSignature")
##      but only *nonsolvable* groups of order <n> are possible
##      (see~"IsSolvableNumber").
##  \item{9.}
##      Let $g_0 = 0$, $p$ be a prime that does not divide the index $i$ of
##      the largest subgroup of $\Gamma$ with cyclic factor group.
##      Suppose $p$ divides <n> exactly once or such that one of the $m_i$
##      is divisible by the $p$-part of <n>.
##      Let $s = \gcd( p-1, <n>, i )$.
##      Then <sign> is admissible only for *nonsolvable* groups of
##      order <n> if one of the following conditions holds.
##      (a) $s = 1$,
##      (b) $r - 2$ of the $m_i$ are coprime to $p s$,
##      (c) $s = 2$, all $m_i$ are coprime to $p$,
##          and $r - 3$ of the $m_i$ are coprime to $p s$.
##  \item{10.}
##      If <sign> is admissible and $\Gamma$ has a *solvable* factor group
##      of order <n> then there is a prime divisor $p$ of
##      $\gcd( <n>, [ \Gamma\colon\Gamma^{\prime} ] )$
##      and a subgroup $H$ of index $p$ in $\Gamma$ whose signature is
##      admissible for a *solvable* factor group of order $<n>/p$.
##  \item{11.}
##      Let $m$ be the index of the derived subgroup of a Fuchsian group
##      $\Gamma$ with signature <sign>.
##      Assume that $\gcd( m, <n> )$ is a power of the prime $p$,
##      and that $p$ does not divide $q-1$ for any prime power $q$ dividing
##      <n>.
##      If $\Gamma$ has a *solvable* factor group of order <m> then <m> is
##      a power of $p$.
##  \item{12.}
##      All groups of order <n> are solvable, the commutator factor group of
##      $\Gamma$ has prime order $p$, and the $p$-part of <n> is $p^2$.
##  \item{13.}
##      All groups of order <n> are solvable but <sign> is admissible only
##      for nonsolvable groups.
##  \item{14.}
##      No *perfect* group of order <n> exists, $<g0> = 0$,
##      and for all prime factors $p$ of <n>,
##      no signature of a normal subgroup of index $p$ in the group of <sign>
##      is admissible for a surface kernel factor of order $<n>/p$.
##      (Here the classification of small perfect groups by Holt and Plesken
##      is used, see~\cite{HP??}.)
##  \endlist
##
#T  mention *positive* answer for abelian signature
##
InstallGlobalFunction( TestAdmissibleSignature, function( sign, n )
    local g,         #
          g0,        #
          r,         # no. of periods of `sign'
          periods,   #
          test,      # result record
          cycord,    # 
          bad,       #
          index,     #
          pair,      #
          gcd,       #
          s, p,      #
          abinv,     #
          good;      #

#T case n = 1 checked?
#T check whether sign, n, g fit together!
    g:= GenusOfSurfaceKernel( sign, n );
    g0:= GenusOfSignature( sign );
    periods:= PeriodsOfSignature( sign );
    r:= Length( periods );

    # Initialize the result record.
    test:= rec(
                comment               := "no criterion found",
                isAdmissibleSignature := true,
                solvable              := true
               );

    if   ForAny( periods, mi -> n mod mi <> 0 ) then

      # Criterion 1.  All periods must divide `n'.
      test.comment               := "not all periods divide the group order";
      test.isAdmissibleSignature := false;
      test.solvable              := false;

    elif IsAbelianSignature( sign, n ) then

      # Abelian signatures are clearly admissible.
      # No further tests are needed.
      test.comment              := "abelian signature";
      return test;

    elif IsSignatureOnlyForAbelianGroup( periods, n ) then

      # Now the group must be nonabelian.
      test.comment               := "nonabelian signature for abelian group";
      test.isAdmissibleSignature := false;
      test.solvable              := false;

    elif     n mod 4 = 2
         and g0 = 0
         and ForAll( periods, mi -> mi mod 2 = 1 ) then

      # If $n \equiv 2 \pmod{4}$, $g_0 = 0$, and all periods are odd,
      # the candidate does not describe epimorphisms.
      test.comment               := Concatenation(
          "no even period for n = ", String( n ), ", (n mod 4 = 2)" );
      test.isAdmissibleSignature := false;
      test.solvable              := false;

    elif     g0 = 0
         and n/2 in periods
         and Number( periods, mi -> mi mod 2 = 0 ) <= 2 - (n/2 mod 2) then

      # The group $G$ has a cyclic normal subgroup of index 2,
      # but at most one generator in the candidate tuple lies outside.
      test.comment               := "cyclic normal subgroup of index 2";
      test.isAdmissibleSignature := false;
      test.solvable              := false;

    elif      Length( periods ) = 1
         and IsPrimeInt( n / periods[1] )
         and periods[1]^2 mod n = 0 then

      # The group $G$ is nonabelian and has a cyclic subgroup of order $m_1$
      # which is contained in $G^{\prime}$ and has prime index $p$ in $G$;
      # so this subgroup is itself the commutator subgroup, but is has a
      # characteristic subgroup of index $p$.  Contradiction.
      test.comment               := "commutator outside derived subgroup";
      test.isAdmissibleSignature := false;
      test.solvable              := false;

    else

      # Check that all prime divisors of `n' are automorphism orders.
      # (Note that not all prime divisors must be admissible periods;
      # the smallest counterexample is a group of order 7 in genus 8.)
      cycord:= CyclicOrders( g );
      bad:= Difference( Set( Factors( n ) ), cycord );
      if not IsEmpty( bad ) then

        test.comment              := Concatenation(
            "not admissible prime divisors ", String( bad ) );
        test.isAdmissibleSignature := false;
        test.solvable              := false;

      else

        # Check that all periods are periods of cyclic automorphism groups.
        bad:= Difference( periods, CyclicPeriods( g ) );
        if not IsEmpty( bad ) then

          test.comment               := Concatenation(
              "not admissible periods ", String( bad ) );
          test.isAdmissibleSignature := false;
          test.solvable              := false;

        fi;

      fi;

    fi;

    # Now perform the checks that may forbid *solvable* groups of order `n'.

    if test.solvable and g0 = 0 then

      if   IsPairwiseCoprimeList( periods ) then

        # The signature allows only perfect factors.
        # Note that all primes that divide the periods do also
        # divide `n' by construction of the signatures,
        # so we need not consider the gcd.
        test.comment              := "perfect signature";
        test.solvable             := false;

      else

        # Compute the order of the largest cyclic factor group of
        # $\Gamma$.
        # (Note that there may be several subgroups of this index with
        # cyclic factor group.)

        abinv:= AbelianInvariants( sign );
        index:= Lcm( abinv );
        gcd:= Gcd( index, n );

        for pair in Collected( Factors( n ) ) do
          if     index mod pair[1] <> 0
             and (    pair[2] = 1
                   or ForAny( periods,
                              m -> m mod pair[1]^pair[2] = 0 ) ) then

            s:= Gcd( gcd, pair[1] - 1 );

            if s = 1 then

              test.comment := Concatenation(
                  "no factor ", String( pair[1] ),
                  " (case (a))" );
              test.solvable := false;

            elif Number( periods,
                         mi -> Gcd( mi, s*pair[1] ) = 1 ) >= r-2 then

              test.comment := Concatenation(
                  "no factor ", String( pair[1] ), ":", String( s ),
                  " (case (b))" );
              test.solvable := false;

            elif     s = 2
                 and ForAll( periods,
                             mi -> Gcd( mi, pair[1] ) = 1 )
                 and Number( periods,
                             mi -> Gcd( mi, s*pair[1] ) = 1 ) >= r-3 then

              test.comment := Concatenation(
                  "no factor ", String( pair[1] ), ":", String( s ),
                  " (case (c))" );
              test.solvable := false;

            fi;

          fi;

        od;

      fi;

      if test.solvable then

        good:= Filtered( Set( Factors( gcd ) ),
                   p -> ForAny( SignaturesOfPrimeIndex( sign, p ),
                                sign -> TestAdmissibleSignature(
                                            sign, n/p ).solvable ) );

        if Length( good ) = 0 then

          test.comment  := "no solv. admiss. sign. for poss. comm. subgps.";
          test.solvable := false;

        fi;

      fi;

      if test.solvable then

        index:= Product( abinv );
        s:= Gcd( index, n );
        s:= Product( Filtered( Factors( s ), x -> x in good ) );
#T better!

        if   IsPrime( s ) and Number( Factors( n ), x -> x = s ) = 2 then

          test.comment := Concatenation(
              String( s ), " divides ex. twice" );
          if index <> s then
            Append( test.comment, " (gcd used)" );
          fi;
          test.solvable := false;

        elif IsPrimePowerInt( s ) and not IsPrimePowerInt( n ) then

          # The derived subgroup of $G$ is a $p$-group.
          p:= Factors( s )[1];
          if ForAll( Collected( Factors( n ) ),
                     pair ->    s mod pair[1] = 0
                             or pair[2] < OrderMod( pair[1], p ) ) then

            # No irreducible action of the commutator factor group
            # on the next layer is possible.
            test.comment := Concatenation(
                "no irreducible action of cyclic ", String( s ) );
            if index <> s then
              Append( test.comment, " (gcd used)" );
            fi;
            test.solvable := false;

          fi;

        fi;

      fi;

    fi;

    # If only nonsolvable groups of order <n> are possible then check
    # whether all groups of order <n> are solvable.
    if test.solvable = false and test.isAdmissibleSignature = true then

      if IsSolvableNumber( n ) then
        test.isAdmissibleSignature:= false;
        Append( test.comment, ", only solvable groups of this order" );
      fi;

    fi;

    # If no *perfect* groups of order <n> exist then it is checked whether
    # there is a prime $p$ such that a signature of a group of index $p$
    # is admissible for a group of order <n>/$p$.
    # (Here the classification of small perfect groups by Holt and Plesken
    # is used.)
    if     g0 = 0 and test.isAdmissibleSignature = true
       and n < 61440 and NumberPerfectGroups( n ) = 0 then

      abinv:= AbelianInvariants( sign );
      if Length( abinv ) = 0 then

        test.isAdmissibleSignature:= false;
        test.solvable:= false;
        test.comment:= Concatenation( "no perfect gp. of this order, ",
                                      "perfect signature" );

      elif ForAll( Set( Factors( Lcm( abinv ) ) ),
             p -> ForAll( SignaturesOfPrimeIndex( sign, p ),
                      sign -> not TestAdmissibleSignature(
                                sign, n/p ).isAdmissibleSignature ) ) then

        test.isAdmissibleSignature:= false;
        test.solvable:= false;
        test.comment:= Concatenation( "no perfect gp. of this order, ",
                                      "no adm. sign. of prime index" );

      fi;
    fi;


    # There are no more criteria to exclude the signature.
    ConvertToStringRep( test.comment );
    return test;
end );


#############################################################################
##
#F  IsAdmissibleSignature( <sign>, <n> )
##
InstallGlobalFunction( IsAdmissibleSignature, function( sign, n )
    sign:= TestAdmissibleSignature( sign, n );
    Info( InfoSignature, 3,
          sign.comment );
    return sign.isAdmissibleSignature;
end );


#############################################################################
##
#F  AdmissibleSignatures( <g>, <g0>, <n> )
#F  AdmissibleSignatures( <g>, <g0> )
#F  AdmissibleSignatures( <g> )
##
##  is a list of all signatures as computed with `PreSignatures'
##  that satisfy the conditions of `IsAdmissibleSignature'.
##
InstallGlobalFunction( AdmissibleSignatures, function( arg )
    local g,
          gg,
          g0,
          n,
          nn,
          bad,     # set of impossible prime divisors
          result2,
          result;  # list of signatures, result

    # Get and check the arguments.
    if   Length( arg ) = 3 and IsInt( arg[1] ) and 2 <= arg[1]
                           and IsInt( arg[2] ) and 0 <= arg[2]
                           and IsPosInt( arg[3] ) then
      g  := arg[1];
      gg := [ arg[2] ];
      nn := [ arg[3] ];
    elif Length( arg ) = 2 and IsInt( arg[1] ) and 2 <= arg[1]
                           and IsInt( arg[2] ) and 0 <= arg[2] then
      g  := arg[1];
      gg := [ arg[2] ];
      nn := [ 1 .. 84*(g-1) ];
    elif Length( arg ) = 1 and IsInt( arg[1] ) and 2 <= arg[1] then
      g  := arg[1];
      gg := [ 0 .. g ];
      nn := [ 1 .. 84*(g-1) ];
    else
      Error( "usage: AdmissibleSignatures( <g>[, <g0>[, <n>]] )" );
    fi;

    # The values may be stored alreay, or contained in the database.
    if not IsBound( ADM_SIGNATURES[g] ) then
      if g <= MAXGENUS then
        LoadGenusData( g );
      else
        ADM_SIGNATURES[g]:= [];
      fi;
    fi;

    # Loop over the possible values for `g0'.
    result:= [];
    for g0 in gg do

      # Reduce the choices for `n' to meaningful values.
      if   g0 = 0 then
        nn:= Intersection( nn, [ 1 .. 84*(g-1) ] );
      elif g0 = 1 then
        nn:= Intersection( nn, [ 1 ..  4*(g-1) ] );
      else
        nn:= Intersection( nn, [ 1 ..    (g-1) ] );
      fi;

      # Bind the entry for the lookup.
      if not IsBound( ADM_SIGNATURES[g][ g0+1 ] ) then
        ADM_SIGNATURES[g][ g0+1 ]:= [];
      fi;

      # Loop over the possible group orders.
      for n in nn do

        if not IsBound( ADM_SIGNATURES[g][ g0+1 ][n] ) then

          # As a shortcut to avoid unnecessary calls of `PreSignatures',
          # compute the admissible periods of signatures.
          # They must divide `n',
          # and there must be an automorphism of this order.
          if n = 1 then
            bad:= [];
          else
            bad:= Difference( Factors( n ), CyclicPeriods( g ) );
#T compute just once the cyclic periods!
          fi;

          # Check that all prime divisors of `n' are admissible.
          if IsEmpty( bad ) then

            # Compute candidates by `PreSignatures',
#T rename to CombinatorialSignatures?
            # and check necessary conditions.
            result2:= Filtered( PreSignatures( g, g0, n ),
                          sign -> IsAdmissibleSignature( sign, n ) );

          else
            Info( InfoSignature, 3,
                  "exclude <n> = ", n, " because of prime divisors in ", bad );
            result2:= [];
          fi;

          # Store the signatures.
          ADM_SIGNATURES[g][ g0+1 ][n]:= result2;

        fi;

        Append( result, ADM_SIGNATURES[g][ g0+1 ][n] );

      od;

    od;

    # Return the result.
    return result;
end );


#############################################################################
##
#E

