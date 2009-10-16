#############################################################################
##
#W  utils.gi               GAP 4 package `genus'                Thomas Breuer
##
#H  @(#)$Id: utils.gi,v 1.8 2003/10/28 09:19:11 gap Exp $
##
#Y  Copyright (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.( "pkg/genus/utils_gi" ) :=
    "@(#)$Id: utils.gi,v 1.8 2003/10/28 09:19:11 gap Exp $";


#############################################################################
##
#M  IsPairwiseCoprimeList( <list> )
##
InstallMethod( IsPairwiseCoprimeList,
    "for a list of integers",
    [ IsList and IsCyclotomicCollection ],
    function( list )
    local i, j;

    for i in [ 1 .. Length( list ) ] do
      for j in [ 1 .. i-1 ] do
        if GcdInt( list[i], list[j] ) <> 1 then
          return false;
        fi;
      od;
    od;
    return true;
    end );


#############################################################################
##
#F  IsCompatibleAbelianInvariants( <big>, <small> )
##
InstallGlobalFunction( IsCompatibleAbelianInvariants, function( big, small )
    local primes,
          nzeros,      # number of free zero invariants (jokers)
          p,
          newprimes,
          pnzero,      # number of free zero invariants in the loop
          i, j,
          exponents,
          expvector,
          maxexp,
          val;

    Info( InfoSignature, 3,
          "IsCompatibleAbelianInvariants called with", big, ", ", small );

    # Get the prime divisors of the order of the big group.
    primes:= [];
    nzeros:= 0;
    for i in big do
      if i = 0 then
        nzeros:= nzeros + 1;
      elif i <> 1 then
        UniteSet( primes, Factors( i ) );
      fi;
      big:= Filtered( big, x -> x <> 0 );
    od;
    for i in small do
      if i = 0 then
        nzeros:= nzeros - 1;
      fi;
    od;
    if nzeros < 0 then
      Info( InfoSignature, 3,
            "return `false'" );
      return false;
    fi;
    small:= Filtered( small, x -> x <> 0 and x <> 1 );
    newprimes:= [];
    for i in small do
      UniteSet( newprimes, Factors( i ) );
    od;
    newprimes:= Difference( newprimes, primes );
    for p in newprimes do
      if nzeros < Number( small, x -> x mod p = 0 ) then
        Info( InfoSignature, 3,
              "return `false'" );
        return false;
      fi;
    od;

    # Reduce the problem to $p$-groups.
    for p in primes do

      pnzero:= nzeros;

      # Compute the Sylow $p$ subgroups of 'big' and 'small'.
      exponents:= [];
      for i in big do
        j:= 0;
        while i mod p = 0 do
          i:= i / p;
          j:= j + 1;
        od;
        if 0 < j then
          Add( exponents, j );
        fi;
      od;
      maxexp:= Maximum( exponents );
      expvector:= List( [ 1 .. maxexp ], x -> 0 );
      for i in exponents do
        expvector[i]:= expvector[i] + 1;
      od;

      exponents:= [];
      for i in small do
        j:= 0;
        while i mod p = 0 do
          i:= i / p;
          j:= j + 1;
        od;
        if 0 < j then
          Add( exponents, j );
          if maxexp < j then
            pnzero:= pnzero - 1;
          fi;
        fi;
      od;
      if pnzero < 0 then
        Info( InfoSignature, 3,
              "return `false'" );
        return false;
      fi;
      for i in exponents do
        if not IsBound( expvector[i] ) then
          for j in [ maxexp+1 .. i ] do
            expvector[j]:= 0;
          od;
          maxexp:= i;
        fi;
        expvector[i]:= expvector[i] - 1;
      od;
      val:= 0;
      for i in [ maxexp, maxexp-1 .. 1 ] do
        val:= val + expvector[i];
        if val < 0 then
          pnzero:= pnzero + val;
          val:= 0;
          if pnzero < 0 then
            Info( InfoSignature, 3,
                  "return `false'" );
            return false;
          fi;
        fi;
      od;

    od;
    Info( InfoSignature, 3,
          "return `true'" );
    return true;
end );


#############################################################################
##
#M  EigenvalueInfo( <tbl> )
#M  EigenvalueInfo( <tbl>, <class> )
##
InstallMethod( EigenvalueInfo,
    "for a character table",
    [ IsCharacterTable ],
    tbl -> [] );

InstallMethod( EigenvalueInfo,
    "for a character table,and a class position",
    [ IsCharacterTable, IsPosInt ],
    function( tbl, class )
    local info,    # the attribute value for `tbl'
          n,       # element order of `class'
          powers,  # list of power classes
          i;       # loop over powers

    # The global info is stored in the table.
    info:= EigenvalueInfo( tbl );

    if not IsBound( info[ class ] ) then

      # Compute and store necessary power maps.
      n:= OrdersClassRepresentatives( tbl )[ class ];
      powers:= [ class ];
      powers[n]:= 1;
      for i in [ 2 .. n-1 ] do
        powers[i]:= PowerMap( tbl, i, class );
      od;
      info[ class ]:= powers;

    fi;

    # Return the list of power classes.
    return info[ class ];
    end );


#############################################################################
##
#F  DimensionFixedSpace( <tbl>, <chi>, <i> )
##
InstallGlobalFunction( DimensionFixedSpace, function( tbl, chi, i )
    return Sum( chi{ EigenvalueInfo( tbl, i ) } )
           / OrdersClassRepresentatives( tbl )[i];
    end );


#############################################################################
##
#V  SIZES_SIMPLE_GROUPS_INFO
##
InstallValue( SIZES_SIMPLE_GROUPS_INFO, Immutable( rec(

    # information about the linear groups $PSL(n,q)$
    Lnq := rec(
        qexp := n -> n*(n-1)/2,
        qprime := function( n, q )
                    local size, qi, i;
                    size := 1;
                    qi   := q;
                    for i in [ 2 .. n ] do
                      qi   := qi * q;
                      size := size * (qi-1);
                    od;
                    return size / Gcd( q-1, n );
                  end,
        denom := n -> n ),

    # information about the symplectic groups $PSp(n,q)$
    Snq := rec(
        qexp := n -> (n/2)^2,
        qprime := function( n, q )
                    local size, qi, eps, i;
                    size := 1;
                    qi   := 1;
                    for i in [ 1 .. n/2 ] do
                      qi   := qi * q^2;
                      size := size * (qi-1);
                    od;
                    return size / Gcd( q-1, 2 );
                  end,
        denom := n -> 2 ),

    # information about the unitary groups $PSU(n,q)$
    Unq := rec(
        qexp := n -> n*(n-1)/2,
        qprime := function( n, q )
                    local size, qi, eps, i;
                    size := 1;
                    qi   := q;
                    eps  := 1;
                    for i in [ 2 .. n ] do
                      qi   := qi * q;
                      eps  := -eps;
                      size := size * (qi+eps);
                    od;
                    return size / Gcd( q+1, n );
                  end,
        denom := n -> n ),

    # information about the orthogonal groups $P\Omega(n,q)^{\epsilon}$
    Onqevenplus := rec(
        qexp := n -> n/2*(n/2-1),
        qprime := function( n, q )
                    local size, qi, i;
                    size := 1;
                    qi   := 1;
                    for i in [ 1 .. n/2-1 ] do
                      qi   := qi * q^2;
                      size := size * (qi-1);
                    od;
                    return size * ( q^(n/2) - 1 ) / Gcd( q^(n/2)-1, 4 );
                  end,
        denom := n -> 4 ),

    Onqevenminus := rec(
        qexp := n -> n/2*(n/2-1),
        qprime := function( n, q )
                    local size, qi, i;
                    size := 1;
                    qi   := 1;
                    for i in [ 1 .. n/2-1 ] do
                      qi   := qi * q^2;
                      size := size * (qi-1);
                    od;
                    return size * ( q^(n/2) + 1 ) / Gcd( q^(n/2)+1, 4 );
                  end,
        denom := n -> 4 ),

    Onqodd := rec(
        qexp := n -> ((n-1)/2)^2,
        qprime := function( n, q )
                    local size, qi, i;
                    size := 1;
                    qi   := 1;
                    for i in [ 1 .. (n-1)/2 ] do
                      qi   := qi * q^2;
                      size := size * (qi-1);
                    od;
                    return size / Gcd( q-1, 2 );
                  end,
        denom := n -> 2 ),

    # information about the Chevalley groups $G_2(q)$
    G2q := rec(
        qexp:= 6,
        qprime := q -> (q^6-1) * (q^2-1) ),

    # information about the Chevalley groups $F_4(q)$
    F4q := rec(
        qexp := 24,
        qprime := q -> (q^12-1) * (q^8-1) * (q^6-1) * (q^2-1) ),

    # information about the Chevalley groups $E_6(q)$
    E6q := rec(
        qexp := 36,
        qprime := q -> (q^12-1) * (q^9-1) * (q^8-1) * (q^6-1) * (q^5-1)
                       * (q^2-1) / Gcd( q-1, 3 ) ),

    # information about the Chevalley groups $E_7(q)$
    E7q := rec(
        qexp := 63,
        qprime := q -> (q^18-1) * (q^14-1) * (q^12-1) * (q^10-1) * (q^8-1)
                       * (q^6-1) * (q^2-1) / Gcd( q-1, 2 ) ),

    # information about the Chevalley groups $E_8(q)$
    E8q := rec(
        qexp := 120,
        qprime := q -> (q^30-1) * (q^24-1) * (q^20-1) * (q^18-1) * (q^14-1)
                       * (q^12-1) * (q^8-1) * (q^2-1) ),

    # information about the Chevalley groups ${}^2B_2(q)$, $q = 2^{2m+1}$
    2B2q := rec(
        qexp := 2,
        qprime := q -> (q^2+1) * (q-1) ),

    # information about the Chevalley groups ${}^3D_4(q)$
    3D4q := rec(
        qexp := 12,
        qprime := q -> (q^8+q^4+1) * (q^6-1) * (q^2-1) ),

    # information about the Chevalley groups ${}^2G_2(q)$, $q = 3^{2m+1}$
    2G2q := rec(
        qexp := 3,
        qprime := q -> (q^3+1) * (q-1) ),

    # information about the Chevalley groups ${}^2F_4(q)$, $q = 2^{2m+1}$
    2F4q := rec(
        qexp := 12,
        qprime := q -> (q^6+1) * (q^4-1) * (q^3+1) * (q-1) ),

    # information about the Chevalley groups ${}^2E_6(q)$
    2E6q := rec(
        qexp := 36,
        qprime := q -> (q^12-1) * (q^9+1) * (q^8-1) * (q^6-1)
                       * (q^5+1) * (q^2-1) / Gcd( q+1, 3 ) ),

    # information about the sporadic simple groups and the Tits group.
    Spor := [
    [                                                   7920,     "M11" ],
    [                                                  95040,     "M12" ],
    [                                                 175560,      "J1" ],
    [                                                 443520,     "M22" ],
    [                                                 604800,      "J2" ],
    [                                               10200960,     "M23" ],
    [                                               17971200, "2F4(2)'" ],
    [                                               44352000,      "HS" ],
    [                                               50232960,      "J3" ],
    [                                              244823040,     "M24" ],
    [                                              898128000,     "McL" ],
    [                                             4030387200,      "He" ],
    [                                           145926144000,      "Ru" ],
    [                                           448345497600,     "Suz" ],
    [                                           460815505920,      "ON" ],
    [                                           495766656000,     "Co3" ],
    [                                         42305421312000,     "Co2" ],
    [                                         64561751654400,    "Fi22" ],
    [                                        273030912000000,      "HN" ],
    [                                      51765179004000000,      "Ly" ],
    [                                      90745943887872000,      "Th" ],
    [                                    4089470473293004800,    "Fi23" ],
    [                                    4157776806543360000,     "Co1" ],
    [                                   86775571046077562880,      "J4" ],
    [                              1255205709190661721292800,     "F3+" ],
    [                     4154781481226426191177580544000000,       "B" ],
    [ 808017424794512875886459904961710757005754368000000000,       "M" ]
    ] ) ) );


#############################################################################
##
#F  SizesSimpleGroupsInfoCleanedList( <list> )
##
##  Omit the ``small exceptional cases'' where the groups described by the
##  list are not simple, or where we get groups of the same isomorphism type
##  several times in different series.
##
BindGlobal( "SizesSimpleGroupsInfoCleanedList", function( list )
    local i, size;

    i:= 1;
    Sort( list );
    while i <= Length( list ) and list[i][1] <= 25920 do
      size:= list[i][1];
      if    ( size < 60 or size = 72 or size = 720 or size = 12096 )
         or ( size =    60 and list[i][2] <>    "A5" )
         or ( size =   168 and list[i][2] <> "L2(7)" )
         or ( size =   360 and list[i][2] <>    "A6" )
         or ( size = 20160 and list[i][2] =  "L4(2)" )
         or ( size = 25920 and list[i][2] <> "S4(3)" )
      then
        Unbind( list[i] );
      fi;
      i:= i+1;
    od;

    # Compact and sort the list.
    list:= Set( list );
    MakeImmutable( list );
    return list;
end );


#############################################################################
##
#F  SizesSimpleGroupsUntilLimitInfo( <limit> )
##
##  Each series is dealt with separately,
##  the relevant parameters are increased until the limit is reached.
##
BindGlobal( "SizesSimpleGroupsUntilLimitInfo", function( limit )
    local list,
          nextprimepower,
          nextoddprimepower,
          AddType_n_q,
          AddType_q,
          n,
          size,
          pair;

    # Initialize the result list.
    list:= [];

    nextprimepower := function( q )
        repeat q:= q+1; until IsPrimePowerInt( q );
        return q;
    end;

    nextoddprimepower := function( q )
        if q mod 2 = 0 then q:= q - 1; fi;
        repeat q:= q+2; until IsPrimePowerInt( q );
        return q;
    end;

    # Construct the admissible pairs of types $X_n(q)$.
    # (Note that the group orders are monotonous in $n$,
    # and that the product of the group order and a denominator
    # depending only on $n$ is monotonous in $q$.)
    AddType_n_q := function( type, name, sign, startn, stepn, nextq )
        local n, found, q, size, denom;
        type:= SIZES_SIMPLE_GROUPS_INFO.( type );
        n:= startn;
        found:= true;
        while found do

          # Find the possible `q' values for the given `n'.
          found:= false;
          q:= nextq( 1 );
          size:= 1;
          denom:= type.denom( n );
          while size <= limit * denom do
            size:= q^type.qexp( n ) * type.qprime( n, q );
            if size <= limit then
              found:= true;
              Add( list, [ size,
                  Concatenation( name, String(n), sign,
                                 "(", String(q), ")" ) ] );
            fi;
            q:= nextq( q );
          od;

          # Increase `n'.
          n:= n + stepn;

        od;
    end;

    # Note that $U_2(q) \equiv L_2(q)$,
    # and the orthogonal groups of dimension up to $6$ are isomorphic
    # to other classical groups:
    # $O_3(q) \equiv L_2(q)$, $O_4^-(q) \equiv L_2(q^2)$,
    # $O_5(q) \equiv S_4(q)$,
    # $O_6^-(q) \equiv U_4(q)$, and $O_6^+(q) \equiv L_4(q)$.
    # Further note that $O_{2n+1}(2^m) \equiv S_{2n}(2^m)$.
    AddType_n_q( "Lnq",          "L", "",  2, 1, nextprimepower    );
    AddType_n_q( "Unq",          "U", "",  3, 1, nextprimepower    );
    AddType_n_q( "Snq",          "S", "",  4, 2, nextprimepower    );
    AddType_n_q( "Onqodd",       "O", "",  7, 2, nextoddprimepower );
    AddType_n_q( "Onqevenplus",  "O", "+", 8, 2, nextprimepower    );
    AddType_n_q( "Onqevenminus", "O", "-", 8, 2, nextprimepower    );

    # Construct the admissible pairs of types $X(q)$.
    AddType_q := function( type, name, startq, nextq )
        local q, size;
        type:= SIZES_SIMPLE_GROUPS_INFO.( type );
        q:= startq;
        while true do
          size:= q^type.qexp * type.qprime( q );
          if limit < size then
            return;
          fi;
          Add( list, [ size,
              Concatenation( name, "(", String(q), ")" ) ] );
          q:= nextq( q );
        od;
    end;

    AddType_q( "G2q",   "G2",  2, nextprimepower );
    AddType_q( "F4q",   "F4",  2, nextprimepower );
    AddType_q( "E6q",   "E6",  2, nextprimepower );
    AddType_q( "E7q",   "E7",  2, nextprimepower );
    AddType_q( "E8q",   "E8",  2, nextprimepower );
    AddType_q( "2B2q",  "Sz",  8, q -> 4*q       );
    AddType_q( "3D4q", "3D4",  2, nextprimepower );
    AddType_q( "2G2q", "2G2", 27, q -> 9*q       );
    AddType_q( "2F4q", "2F4",  8, q -> 4*q       );
    AddType_q( "2E6q", "2E6",  2, nextprimepower );

    # Add the relevant alternating groups.
    n:= 5;
    size:= 60;
    while size <= limit do
      Add( list, [ size, Concatenation( "A", String(n) ) ] );
      n:= n+1;
      size:= size * n;
    od;

    # Add the relevant sporadic simple groups.
    for pair in SIZES_SIMPLE_GROUPS_INFO.Spor do
      if pair[1] <= limit then
        Add( list, pair );
      fi;
    od;

    # Return the result.
    return SizesSimpleGroupsInfoCleanedList( list );
end );


#############################################################################
##
#F  SizesSimpleGroupsOfNumberInfo( <size> )
##
##  The factorization of the positive integer <size> is used to find the
##  candidates for $q$ (and $n$).
##
BindGlobal( "SizesSimpleGroupsOfNumberInfo", function( size )
    local type, pair, name, pos, n, q, res;

    # Rule out trivial cases.
    if size < 60 or size mod 4 <> 0 then
      res:= [];
    elif size = 20160 then
      res:= [ "A8", "L3(4)" ];
    else

      # Use the available implementation of the classification.
      type:= IsomorphismTypeInfoFiniteSimpleGroup( size );
      if type = fail then

        # There is no nonabelian simple group of this order.
        res:= [];

      elif not IsBound( type.series ) then

        # This happens exactly for the case of two nonisomorphic groups
        # $O_{2n+1}(q)$ and $S_{2n}(q)$, $q$ odd, which have the same order.
        name:= type.name{ [ 50 .. Length( type.name ) ] };
        pos:= Position( name, ',' );
        n:= name{ [ 1 .. pos - 1 ] };
        q:= name{ [ pos + 1 .. Position( name, ')' ) ] };
        res:= [ Concatenation( "O",n,"(",q,")" ),
                Concatenation( "S",String(Int(n)-1),"(",q,")") ];

      elif type.series = "A" then
        res:= [ Concatenation( "A",String(type.parameter) ) ];
      elif type.series = "B" then
        if type.parameter[2] mod 2 = 0 then
          res:= [ Concatenation( "S", String( 2*type.parameter[1] ),
                      "(", String( type.parameter[2] ), ")" ) ];
        elif type.parameter[1] = 2 then
          res:= [ Concatenation( "S4(", String( type.parameter[2] ), ")" ) ];
        else
          res:= [ Concatenation( "O",String(2*type.parameter[1]+1),
                      "(", String( type.parameter[2] ), ")" ) ];
        fi;
      elif type.series = "C" then
        res:= [ Concatenation( "S", String( 2*type.parameter[1] ),
                    "(", String( type.parameter[2] ), ")" ) ];
      elif type.series = "D" then
        res:= [ Concatenation( "O", String( 2*type.parameter[1] ),
                    "+(", String( type.parameter[2] ), ")" ) ];
      elif type.series = "E" then
        res:= [ Concatenation( "E", String( type.parameter[1] ),
                    "(", String( type.parameter[2] ), ")" ) ];
      elif type.series = "F" then
        res:= [ Concatenation( "F4(", String( type.parameter ), ")" ) ];
      elif type.series = "G" then
        res:= [ Concatenation( "G2(", String( type.parameter ), ")" ) ];
      elif type.series = "L" then
        res:= [ Concatenation( "L", String( type.parameter[1] ),
                    "(", String( type.parameter[2] ), ")" ) ];
      elif type.series = "2A" then
        res:= [ Concatenation( "U", String( type.parameter[1] + 1 ),
                    "(", String( type.parameter[2] ), ")" ) ];
      elif type.series = "2B" then
        res:= [ Concatenation( "Sz(", String( type.parameter ), ")" ) ];
      elif type.series = "2D" then
        res:= [ Concatenation( "O", String( 2*type.parameter[1] ),
                    "-(", String( type.parameter[2] ), ")" ) ];
      elif type.series = "3D" then
        res:= [ Concatenation( "3D4(", String( type.parameter ), ")" ) ];
      elif type.series = "2E" then
        res:= [ Concatenation( "2E6(", String( type.parameter ), ")" ) ];
      elif type.series = "2F" then
        if type.parameter = 2 then
          res:= [ "2F4(2)'" ];
        else
          res:= [ Concatenation( "2F4(", String( type.parameter ), ")" ) ];
        fi;
      elif type.series = "2G" then
        res:= [ Concatenation( "2G2(", String( type.parameter ), ")" ) ];
      elif type.series = "Spor" then
        for pair in SIZES_SIMPLE_GROUPS_INFO.Spor do
          if pair[1] = size then
            res:= [ pair[2] ];
          fi;
        od;
      else
        Error( "problem with the classification of FiNaSiG" );
      fi;
    fi;

    # Return the result.
    res:= List( res, name -> [ size, name ] );
    return SizesSimpleGroupsInfoCleanedList( res );
end );


#############################################################################
##
#F  SizesSimpleGroupsOfDivisorsInfo( <multiple> )
##
##  The factorization of the positive integer <multiple> is used to find the
##  candidates for $q$ (and $n$).
##
BindGlobal( "SizesSimpleGroupsOfDivisorsInfo", function( multiple )
    local facts, list, AddType_n_q, AddType_q, n, size, pair;

    # Initialize the list of results.
    list:= [];

    # Rule out trivial cases.
    if multiple < 60 or multiple mod 4 <> 0 then
      return list;
    fi;
    facts:= Collected( FactorsInt( multiple ) );
    if Length( facts ) < 3 then
      return list;
    fi;

    # Construct the admissible pairs of types $X_n(q)$.
    AddType_n_q := function( type, name, sign, startn, stepn, condp )
        local pair, p, pow, q, n, exp, size;
        type:= SIZES_SIMPLE_GROUPS_INFO.( type );
        for pair in facts do
          p:= pair[1];
          if condp( p ) then
            for pow in [ 1 .. pair[2] ] do
              q:= p^pow;
              n:= startn;
              exp:= type.qexp( n );
              while exp * pow <= pair[2] do
                size:= q^exp * type.qprime( n, q );
                if multiple mod size = 0 then
                  Add( list, [ size,
                      Concatenation( name, String(n), sign,
                                     "(", String(q), ")" ) ] );
                fi;
                n:= n + stepn;
                exp:= type.qexp( n );
              od;
            od;
          fi;
        od;
    end;

    AddType_n_q( "Lnq",          "L", "",  2, 1, IsPosInt );
    AddType_n_q( "Unq",          "U", "",  3, 1, IsPosInt );
    AddType_n_q( "Snq",          "S", "",  4, 2, IsPosInt );
    AddType_n_q( "Onqodd",       "O", "",  7, 2, IsOddInt );
    AddType_n_q( "Onqevenplus",  "O", "+", 8, 2, IsPosInt );
    AddType_n_q( "Onqevenminus", "O", "-", 8, 2, IsPosInt );

    # Construct the admissible pairs of types $X(q)$.
    AddType_q := function( type, name, startexp, choice, shift )
        local exp, pair, p, pow, q, size;
        type:= SIZES_SIMPLE_GROUPS_INFO.( type );
        exp:= type.qexp;
        for pair in facts do
          p:= pair[1];
          if choice( p ) then
            for pow in [ startexp .. Int( pair[2] / exp ) ] do
              if ( pow - startexp ) mod shift = 0 then
                q:= p^pow;
                size:= q^exp * type.qprime( q );
                if multiple mod size = 0 then
                  Add( list, [ size,
                      Concatenation( name, "(", String(q), ")" ) ] );
                fi;
              fi;
            od;
          fi;
        od;
    end;

    AddType_q( "G2q",   "G2", 1, ReturnTrue, 1 );
    AddType_q( "F4q",   "F4", 1, ReturnTrue, 1 );
    AddType_q( "E6q",   "E6", 1, ReturnTrue, 1 );
    AddType_q( "E7q",   "E7", 1, ReturnTrue, 1 );
    AddType_q( "E8q",   "E8", 1, ReturnTrue, 1 );
    AddType_q( "3D4q", "3D4", 1, ReturnTrue, 1 );
    AddType_q( "2E6q", "2E6", 1, ReturnTrue, 1 );
    AddType_q( "2B2q",  "Sz", 3, p -> p = 2, 2 );
    AddType_q( "2F4q", "2F4", 3, p -> p = 2, 2 );
    AddType_q( "2G2q", "2G2", 3, p -> p = 3, 2 );

    # Add the relevant alternating groups.
    n:= 5;
    size:= 60;
    while multiple mod size = 0 do
      Add( list, [ size, Concatenation( "A", String(n) ) ] );
      n:= n+1;
      size:= size * n;
    od;

    # Add the relevant sporadic simple groups.
    for pair in SIZES_SIMPLE_GROUPS_INFO.Spor do
      if multiple mod pair[1] = 0 then
        Add( list, pair );
      fi;
    od;

    # Return the result.
    return SizesSimpleGroupsInfoCleanedList( list );
end );


#############################################################################
##
#F  SizesSimpleGroupsInfo( <limit> )
#F  SizesSimpleGroupsInfo( <list> )
#F  SizesSimpleGroupsInfo( <list>, "divides" )
##
InstallGlobalFunction( SizesSimpleGroupsInfo, function( arg )
    if   Length( arg ) = 1 and IsPosInt( arg[1] ) then
      return SizesSimpleGroupsUntilLimitInfo( arg[1] );
    elif Length( arg ) = 1 and IsList( arg[1] )
                           and ForAll( arg[1], IsPosInt ) then
      return Union( List( Set( arg[1] ), SizesSimpleGroupsOfNumberInfo ) );
    elif Length( arg ) = 2 and IsList( arg[1] )
                           and ForAll( arg[1], IsPosInt )
                           and arg[2] = "divides" then
      return Union( List( Set( arg[1] ), SizesSimpleGroupsOfDivisorsInfo ) );
    else
      Error( "usage: SizesSimpleGroupsInfo( <limit> )\n",
             "or SizesSimpleGroupsInfo( <list>[, \"divides\"] )" );
    fi;
end );


#############################################################################
##
#V  ORDERS_SIMPLE
#V  MAX_ORDER_SIMPLE
##
InstallValue( ORDERS_SIMPLE, [] );
InstallValue( MAX_ORDER_SIMPLE, [ 1 ] );


#############################################################################
##
#F  IsSolvableNumber( <n> )
##
InstallGlobalFunction( IsSolvableNumber, function( n )
    if not IsPosInt( n ) then
      Error( "<n> must be a positive integer" );
    elif n mod 4 <> 0 or Length( Set( Factors( n ) ) ) <= 2 then
      return true;
    fi;
    if MAX_ORDER_SIMPLE[1] < n then
      MakeReadWriteGlobal( "ORDERS_SIMPLE" );
      ORDERS_SIMPLE:= SizesSimpleGroupsUntilLimitInfo( n );
      MakeReadOnlyGlobal( "ORDERS_SIMPLE" );
      MAX_ORDER_SIMPLE[1]:= n;
    fi;
    return ForAll( ORDERS_SIMPLE, pair -> n mod pair[1] <> 0 );
    end );


#############################################################################
##
#F  IsAbelianNumber( <n> )
##
##  Let $n = \prod_{i=1}^k p_i^{k_i}$ be a positive integer,
##  with $p_1 < p_2 < \cdots < p_k$ primes.
##  Every group of order $n$ is abelian if and only if
##  \begin{itemize}
##  \item[(a)]
##      $k_i < 3$ for all $i$,
##  \item[(b)]
##      $p_i$ does not divide $(p_j-1)$ for $i < j$, and
##  \item[(c)]
##      $p_i$ does not divide $(p_j+1)$ for $i < j$ with $k_j = 2$.
##  \end{itemize}
##
##  \begin{proof}
##  The ``only if'' part is clear, since there are nonabelian groups of order
##  $p^3$ for each prime, or of order $p q$ for two primes $p < q$ such that
##  $p$ divides $q-1$, or of order $p q^2$ for two primes $p < q$ such that
##  $p$ divides $q+1$, or of order $p q^2$ for two primes $p < q$.
##
##  Conversely,
##  suppose $n$ is the smallest positive integer that satisfies the three
##  conditions but where a nonabelian group $G$ of order $n$ exists.
##  Then $G$ is solvable by the classification of finite simple groups;
##  note that the orders of all finite simple groups except the Suzuki groups
##  are divisible by $2$ and $3$, and the simple Suzuki groups have order
##  divisible by $8$.
##  So we may take a minimal normal subgroup $N$ of $G$.
##  Then $N$ is central in $G$ because
##  ...
##  And $G / N$ is abelian by the minimality of $|G|$.
##  Use Hall subgroups?
##  ...
##  \end{proof}
##  
InstallGlobalFunction( IsAbelianNumber, function( n )
    local facts, prim;

    if not IsPosInt( n ) then
      Error( "<n> must be a positive integer" );
    fi;

    facts:= Collected( FactorsInt( n ) );
    prim:= List( facts, x -> x[1] );
    if ForAny( facts, x -> 2 < x[2] ) then
      return false;
    elif ForAny( [ 1 .. Length( facts ) ],
                 j -> ForAny( [ 1 .. j-1 ],
                              i -> ( prim[j] - 1 ) mod prim[i] = 0 ) ) then
      return false;
    elif ForAny( [ 1 .. Length( facts ) ],
                 j -> facts[j][2] = 2 and ForAny( [ 1 .. j-1 ],
                              i -> ( prim[j] + 1 ) mod prim[i] = 0 ) ) then
      return false;
    fi;
    return true;
    end );


#############################################################################
##
#M  IsDihedralGroup( <G> )
##
InstallMethod( IsDihedralGroup,
    "for a group",
    [ IsGroup ],
    function( G )
    local size, D, gen, x, C, outer, i, j;

    size:= Size( G );
    if size = infinity or size mod 2 = 1 then
      return false;
    elif size = 2 then
      return true;
    fi;

    D:= DerivedSubgroup( G );
    if   not IsCyclic( D ) then
      return false;
    elif size mod 4 = 2 and Index( G, D ) = 2 then
      gen:= MinimalGeneratingSet( D )[1];
      for x in GeneratorsOfGroup( G ) do
        if not x in D then
          return gen * x * gen = x;
        fi;
      od;
    elif size mod 4 = 0 and Index( G, D ) = 4 then
      outer:= [];
      for x in GeneratorsOfGroup( G ) do
        if not x in D then
          C:= ClosureGroup( D, x );
          if   Index( G, C ) <> 2 then
            return false;
          elif not IsCyclic( C ) then
            Add( outer, x );
          else
            gen:= MinimalGeneratingSet( C )[1];
            if IsEmpty( outer ) then
              outer[1]:= First( GeneratorsOfGroup( G ), g -> not g in C );
            fi;
            return Order( outer[1] ) = 2 and gen * outer[1] * gen = outer[1];
          fi;
        fi;
      od;

      # None of the generators was good to generate the cyclic subgroup
      # of index $2$,
      # so the product of two elements in `outer' must do.
      for i in [ 1 .. Length( outer ) ] do
        for j in [ 1 .. i-1 ] do
          x:= outer[i] * outer[j];
          if not x in D then
            C:= ClosureGroup( D, x );
            if   Index( G, C ) <> 2 then
              return false;
            elif IsCyclic( C ) then
              gen:= MinimalGeneratingSet( C )[1];
              return     Order( outer[1] ) = 2
                     and gen * outer[1] * gen = outer[1];
            fi;
          fi;
        od;
      od;

    fi;

    # We did not find the required data.
    return false;
    end );


#############################################################################
##
#M  IsGroupOfGenusZero( <G> )
##
InstallMethod( IsGroupOfGenusZero,
    "for a group",
    [ IsGroup ],
    function( G )
    Assert( 1,     IdGroup( AlternatingGroup( 4 ) ) = [ 12,  3 ]
               and IdGroup(   SymmetricGroup( 4 ) ) = [ 24, 12 ]
               and IdGroup( AlternatingGroup( 5 ) ) = [ 60,  5 ] );
    return  IsFinite( G )
        and (    IsCyclic( G ) or IsDihedralGroup( G )
              or ( Size( G ) in [ 12, 24, 60 ]
                and IdGroup( G ) in [ [ 12, 3 ], [ 24, 12 ], [ 60, 5 ] ] ) );
    end );


#############################################################################
##
#F  IsGroupOfGenusOne( <G> )
##
##  We try to exclude impossible cases without checking generation.
##  The five signatures for genus one are
##  $(1;-)$, $(0;2,2,2,2)$, $(0;3,3,3)$, $(0;2,4,4)$, and $(0;2,3,6)$.
##  The finite factors of the first group are exactly the abelian groups that
##  are noncyclic and can be generated by two elements.
##  The other four groups have the following commutator factor groups:
##  elementary abelian of order $8$ or $9$, $2 \times 4$, and cyclic of order
##  $6$, and the derived subgroup $\Gamma^{\prime} \cong \Gamma(1;-)$ is
##  abelian.
##  So if $K \leq \Gamma$ is the kernel of an epimorphism to $G$ then
##  $G^{\prime}$ is isomorphic with
##  $\Gamma^{\prime}K/K \cong\Gamma^{\prime}/(\Gamma^{\prime}\cap K)$,
##  in particular $G^{\prime}$ is abelian and generated by at most $2$
##  elements.
##
InstallMethod( IsGroupOfGenusOne,
    "for a group",
    [ IsGroup ],
    function( G )
    local der, ind, signatures, sign;

    # Note that we must return `false' for groups of genus zero.
    if IsGroupOfGenusZero( G ) then
      return false;
    fi;

    if IsAbelian( G ) then

      # Abelian groups of genus $1$ are excactly finite factors of the group
      # $\Gamma(1;-)$, i.e., the noncyclic abelian groups that can be
      # generated by two elements,
      # and the elementary abelian group of order $8$.
      Assert( 1, IdGroup( ElementaryAbelianGroup( 8 ) ) = [ 8, 5 ] );
      return    Length( MinimalGeneratingSet( G ) ) = 2
             or ( Size( G ) = 8 and IdGroup( G ) = [ 8, 5 ] );
#T add info statement!

    else

      # The commutator factor group of a group of genus one is a factor of
      # one of the commutator factor groups of the five groups of genus one.
      der:= DerivedSubgroup( G );
      ind:= Index( G, der );
      if    not ind in [ 2, 3, 4, 6, 8, 9 ]
         or not IsAbelian( der )
         or Length( MinimalGeneratingSet( der ) ) > 2 then
        return false;
      fi;

      # Perform a brute force check.
      if   ind = 2 then
        signatures:= List( [ [2,2,2,2], [2,4,4], [2,3,6] ],
                           periods -> Signature( 0, periods ) );
      elif ind = 3 then
        signatures:= List( [ [3,3,3], [2,3,6] ],
                           periods -> Signature( 0, periods ) );
      elif ind in [ 4, 8 ] then
        signatures:= List( [ [2,2,2,2], [2,4,4] ],
                           periods -> Signature( 0, periods ) );
#T factor group for ind = 8 must be el. ab. or 2x4
      elif ind = 6 then
        signatures:= List( [ [2,3,6] ],
                           periods -> Signature( 0, periods ) );
      else
        signatures:= List( [ [3,3,3] ],
                           periods -> Signature( 0, periods ) );
      fi;

      for sign in signatures do
        if not IsEmpty( RepresentativesEpimorphisms( sign, G, rec( single:= true ) ) ) then
#T add info statement which signature occurs!
          return true;
        fi;
      od;
      return false;

    fi;
    end );


#############################################################################
##
#E

