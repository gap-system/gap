#############################################################################
##
#W  ctblchar.gi                 GAP library                     Thomas Breuer
#W                                                              & Ansgar Kaup
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains those functions which mainly deal with characters.
##
Revision.ctblchar_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  DecompositionMatrixAttr( <modtbl> )
##
InstallMethod( DecompositionMatrixAttr,
    "method for a Brauer table",
    true,
    [ IsBrauerTable ], 0,
    function( modtbl )
    local ordtbl;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    return Decomposition( Irr( modtbl ),
               RestrictedClassFunctions( ordtbl, modtbl, Irr( ordtbl ) ),
               "nonnegative" );
    end );


#############################################################################
##
#F  DecompositionMatrix( <modtbl> )
#F  DecompositionMatrix( <modtbl>, <blocknr> )
##
DecompositionMatrix := function( arg )

    local modtbl,    # Brauer character table, first argument
          ordtbl,    # corresponding ordinary table
          blocknr,   # number of the block, second argument
          block;     # block information

    if    Length( arg ) = 1 and IsBrauerTable( arg[1] ) then

      return DecompositionMatrixAttr( arg[1] );

    elif Length( arg ) = 2 and IsBrauerTable( arg[1] ) then

      modtbl  := arg[1];
      blocknr := arg[2];
      block   := BlocksInfo( modtbl );

      if     IsInt( blocknr ) and IsPosRat( blocknr )
         and blocknr <= Length( block ) then
        block:= block[ blocknr ];
      else
        Error( "<blocknr> must be in the range [ 1 .. ",
               Length( block ), " ]" );
      fi;

      if not IsBound( block.decompositionMatrix ) then

        ordtbl:= OrdinaryCharacterTable( modtbl );
        block.decompositionMatrix:=
           Decomposition( Irr( modtbl ){ block.modchars },
               RestrictedClassFunctions( ordtbl, modtbl,
                   Irr( ordtbl ){ block.ordchars } ),
               "nonnegative" );

      fi;

      return block.decompositionMatrix;

    else
      Error( "usage: DecompositionMatrix( <modmodtbl>[, <blocknr>] )" );
    fi;
end;


#############################################################################
##
#F  LaTeXStringDecompositionMatrix( <modtbl> )
#F  LaTeXStringDecompositionMatrix( <modtbl>, <blocknr> )
##
LaTeXStringDecompositionMatrix := function( arg )

    local modtbl,    # Brauer character table, first argument
          blocknr,   # number of the block, second argument
          decmat,    # decomposition matrix
          block,     # block information on 'modtbl'
          modchars,  # indices of Brauer characters
          ordchars,  # indices of ordinary characters
          phi,       # string used for Brauer characters
          chi,       # string used for ordinary irreducibles
          str,       # string containing the text
          i,         # loop variable
          val;       # one value in the matrix

    # Get and check the arguments.
    if    Length( arg ) = 1 and IsBrauerTable( arg[1] ) then

      modtbl:= arg[1];
      decmat:= DecompositionMatrixAttr( modtbl );
      modchars:= [ 1 .. Length( decmat[1] ) ];
      ordchars:= [ 1 .. Length( decmat ) ];

    elif Length( arg ) = 2 and IsBrauerTable( arg[1] )
                           and IsInt( arg[2] ) then

      modtbl   := arg[1];
      blocknr  := arg[2];
      decmat   := DecompositionMatrix( modtbl, blocknr );
      block    := BlocksInfo( modtbl )[ blocknr ];
      modchars := block.modchars;
      ordchars := block.ordchars;

    else
      Error( "usage: ",
             "LatexStringDecompositionMatrix( <modmodtbl>[, <blocknr>] )" );
    fi;

    phi:= "\\varphi";
    chi:= "\\chi";

    str:= "";

    # head of the array
    Append( str,  "\\[\n" );
    Append( str,  "\\begin{array}{l|" );
    for i in [ 1 .. Length( decmat[1] ) ] do
      Add( str, 'r' );
    od;
    Append( str, "} \\hline\n" );

    # The first line contains the Brauer character numbers.
    for i in modchars do
      Append( str, " & " );
      Append( str, phi );
      Append( str, "_{" );
      Append( str, String( i ) );
      Append( str, "}\n" );
    od;
    Append( str, " \\\\ \\hline\n" );

    # the matrix itself,
    for i in [ 1 .. Length( decmat ) ] do

      # The first column contains the numbers of ordinary irreducibles.
      Append( str, chi );
      Append( str, "_{" );
      Append( str, String( ordchars[i] ) );
      Append( str, "}" );

      for val in decmat[i] do
        Append( str, " & " );
        if val = 0 then
          Append( str, "." );
        else
          Append( str, String( val ) );
        fi;
      od;

      Append( str, " \\\\\n" );

    od;

    Append( str, "\\hline " );

    # tail of the array
    Append( str,  "\\end{array}\n" );
    Append( str,  "\\]\n" );

    # Return the result.
    return str;
end;


###############################################################################
##
#F  FrobeniusCharacterValue( <value>, <p> )
##
##  returns the value of the Frobenius character corresponding to the Brauer
##  character value <value>, where <p> is the characteristic of the field.
##
##  Let $n$ be the conductor of $v$.
##  Let $k$ be the order of $p$ modulo $n$, that is, $GF( p^k )$ is the
##  smallest field of characteristic $p$ containing $n$-th roots of unity.
##  Let $m$ be minimal with $v^{\ast p^m} = v$, that is, $GF( p^m )$ is the
##  smallest field containing the Frobenius character value $\overline{v}$.
##
##  Let $C_k$ and $C_m$ be the Conway polynomials of degrees $k$ and $m$,
##  and $z = X + (C_k)$ in $GF( p^k ) = GF(p)[X] / (C_k)$.
##  Then $\hat{y} = z^{\frac{p^k-1}{p^m-1}}$ may be identified with
##  $y = X + (C_m)$ in $GF( p^m ) = GF(p)[X] / (C_m)$.
##
##  For $v = \sum_{i=1}^n a_i E(n)^i$ a representation of $\overline{v}$ in
##  $GF( p^k )$ is $\sum_{i=1}^n \overline{a_i} z^{\frac{p^k-1}{n} i}$ where
##  $\overline{a_i}$ is the reduction of $a_i$ modulo $p$, viewed as
##  element of $GF(p)$.
##
##  A representation of $\overline{v}$ in $GF( p^m )$ can be found by
##  solving the linear equation system
##  $\overline{v} = \sum_{i=0}^{m-1} c_i \hat{y}^i$ over $GF(p)$, which
##  gives us $\overline{v} = \sum{i=0}^{m-1} c_i y^i$ in $GF( p^m )$.
##
FrobeniusCharacterValue := function( value, p )

    local n,            # conductor of 'value'
          cf,           # canonical basis of 'CF(n)'
          k,            # degree of smallest field containing 'n'-th roots
          m,            # degree of smallest field containing the result
          size,         # 'p^k'
          power,        # '( size - 1 ) / n'
          ffe,          # primitive 'n'-th root in 'GF( size )'
          image,        # image of 'value' under Galois conjugation
          primefield,   # 'GF(p)'
          zero,         # zero of 'primefield'
          conwaypol,    # 'k'-th Conway polynomial in characteristic 'p'
          x,            # indeterminate
          y,
          fieldbase,
          i;

    if IsRat( value ) then
      return ( value mod p ) * Z(p)^0;
    fi;

    n:= NofCyc( value );
    if n mod p = 0 then
      Error( "<value> belongs to a <p>-singular element" );
    fi;

    # Compute the size $p^k$ of the smallest finite field of characteristic
    # 'p' that contains 'n'-th roots of unity.
    k:= OrderMod( p, n );
    size:= p ^ k;

    # The root 'E(n)' is identified with the smallest primitive 'n'-th
    # root in the finite field, that is, the '(size-1) / n'-th power of
    # the chosen root of the field.
    power:= ( size - 1 ) / n;

    if size <= 65536 then

      # Use the internal finite fields of {\GAP}.
      # (Express the Brauer character value in terms of the Zumbroich basis
      # of the underlying cyclotomic field.)
      ffe:= GF( size ).root ^ power;
      cf:= CanonicalBasis( CF( n ) );
      value:= List( Coefficients( cf, value ), y -> y mod p )
              * List( ZumbroichBase( n, 1 ), exp -> ffe ^ exp );

    else

      # Compute the smallest finite field that contains the
      # Frobenius character value.
      # This is the field of order $p^m$ where $m$ is the smallest number
      # such that <value> is fixed by the Galois automorphism that raises
      # roots of unity to the $p^m$-th power.
      m:= 1;
      image:= GaloisCyc( value, p );
      while image <> value do
        m:= m+1;
        image:= GaloisCyc( image, p );
      od;

      if p^m > 65536 then
        Print( "#E  ", value,
               " cannot be expressed using GAP's internal finite fields\n" );
#T !!
        return fail;
      fi;

      # Compute the representation of the Frobenius character value
      # in the field $GF( p^k )$.
      primefield:= GF(p);
      zero:= Zero( primefield );

      if not IsBound( CONWAYPOLYNOMIALS[p][k] ) then
        Info( InfoCharacterTable, 1,
              "Conway polynomial of degree ", k, " for p = ", p,
              " not available" );
        return fail;
      fi;
      conwaypol:= UnivariatePolynomial( primefield,
                      ConwayPol( p, k ) * One( GF( p ) ) );
      x:= Indeterminate( primefield );
      value:= ValuePol( List( COEFFSCYC( value ), y -> y mod p )
                        * One( primefield ),
                        PowerMod( x, power, conwaypol ) ) mod conwaypol;
      value:= CoefficientsOfUnivariatePolynomial( value );
      while Length( value ) < k do
        Add( value, zero );
      od;

      # Compute a $GF(p)$-basis $(\hat{y}^i; 0\leq i\leq m-1)$ of
      # the subfield of $GF( p^k )$ isomorphic with $GF( p^m )$.
      y:= PowerMod( x, (size - 1) / (p^m - 1), conwaypol );

      fieldbase:=[];
      for i in [ 1 .. m ] do

        fieldbase[i]:= CoefficientsOfUnivariatePolynomial(
                           PowerMod( y, i-1, conwaypol ) );
        while Length( fieldbase[i] ) < k do
          Add( fieldbase[i], zero );
        od;

      od;

      value:= ValuePol( SolutionMat( fieldbase, value ), Z(p^m) );

    fi;

    # Return the Frobenius character value.
    return value;
end;


#############################################################################
##
#F  Tensored( <chars1>, <chars2> )
##
##  returns the list of tensor products of <chars1> with <chars2>.
##
Tensored := function( chars1, chars2 )

    local i, j, k, nccl, tensored, single;

    if IsEmpty( chars1 ) then return []; fi;
    nccl:= Length( chars1[1] );

    tensored:= [];
    for i in chars1 do
      for j in chars2 do
        single:= [];
        for k in [ 1 .. nccl ] do single[k]:= i[k] * j[k]; od;
        Add( tensored, single );
      od;
    od;
    return tensored;
end;


#############################################################################
##
#F  Symmetrisations( <tbl>, <characters>, <Sn> )
#F  Symmetrisations( <tbl>, <characters>, <n> )
##
Symmetrisations := function( tbl, characters, Sn )

    local i, j, l, n,
          tbl_powermap,     # computed power maps of 'tbl'
          cyclestruct,
          Sn_classparam,
          symmirreds,
          symmclasses,
          symmorder,
          cycl,
          symmetrisations,
          chi,
          psi,
          powermap,
          prodmatrix,
          single,
          value,
          val;

    if IsInt( Sn ) then
      Sn:= CharacterTable( "Symmetric", Sn );
    elif IsCharacterTable( Sn ) then
      if not HasClassParameters( Sn ) then
        Error( "partitions corresponding to classes must be stored",
               " as 'ClassParameters( <Sn> )'" );
      fi;
    else
      Error( "usage: Symmetrisations( tbl, chars, n ) with integer n or\n",
             "Symmetrisations( tbl, chars, S_n ) with symmetric group S_n" );
    fi;

    tbl_powermap:= ShallowCopy( ComputedPowerMaps( tbl ) );

    cyclestruct:= [];
    Sn_classparam:= ClassParameters( Sn );

    for i in [ 1 .. Length( Sn_classparam ) ] do
      if Length( Sn_classparam[i][2] ) = 1 then
        n:= Sn_classparam[i][2][1];
      fi;
      cyclestruct[i]:= [];
      for j in [ 1 .. Maximum( Sn_classparam[i][2] ) ] do
         cyclestruct[i][j]:= 0;
      od;
      for j in Sn_classparam[i][2] do
        cyclestruct[i][j]:= cyclestruct[i][j] + 1;
      od;
    od;
    symmirreds  := Irr( Sn );
    symmclasses := SizesConjugacyClasses( Sn );
    symmorder   := Size( Sn );

    # Compute necessary power maps.
    for i in [ 1 .. n ] do
      if not IsBound( tbl_powermap[i] ) then
        tbl_powermap[i]:= PowerMap( tbl, i );
      fi;
    od;

    symmetrisations:= [];
    for chi in characters do

      # Symmetrize the k-th character of table ...
      prodmatrix:= [];
      for i in [ 1 .. Length( characters[1] ) ] do
        prodmatrix[i]:= [];
        for j in [ 1 .. Length( symmclasses ) ] do
          value:= symmclasses[j];
          cycl:= cyclestruct[j];
          for l in [ 1 .. Length( cycl ) ] do
            if cycl[l] <> 0 then
              if IsInt( powermap[l][i] ) then
                value:= value * ( chi[ powermap[l][i] ] ^ cycl[l] );
              else
                val:= CompositionMaps( chi, powermap[l][i] );
                if IsInt( val ) then
                  value:= value * ( val ^ cycl[l] );
                else
                  value:= Unknown();
                fi;
              fi;
            fi;
          od;
          prodmatrix[i][j]:= value;
        od;
      od;

      # ... with character psi ...
      for psi in symmirreds do
        single:= [];
        for i in [ 1 .. Length( characters[1] ) ] do

          # ... at class i
          single[i]:= psi * prodmatrix[i] / symmorder;
          if not ( IsCycInt( single[i] ) or IsUnknown( single[i] ) ) then
            single[i]:= Unknown();
            Print( "#E Symmetrisations: value not dividing group order,",
                   " set to ", single[i], "\n" );
          fi;

        od;
        Add( symmetrisations, single );
      od;
    od;

    # Return the symmetrizations.
    return symmetrisations;
end;

Symmetrizations := Symmetrisations;


#############################################################################
##
#F  SymmetricParts( <tbl>, <character>, <n> )
##
SymmetricParts := function( tbl, characters, n )

    local i,
          j,
          k,
          nccl,
          exponents,
          symcentralizers,   # list of symmetrizations, result
          symmetricparts,
          chi,               # loop over 'characters'
          sym,
          exp,
          factor,
          powermap;          # shallow copy of 'tbl.powermap'

    if IsEmpty( characters ) then
      return [];
    fi;

    nccl:= NrConjugacyClasses( tbl );
    exponents:= Partitions( n );
    symcentralizers:= CharacterTable( "Symmetric" )!.centralizers[1];
    symcentralizers:= List( exponents, x -> symcentralizers( n, x ) );

    for i in [ 1 .. Length( exponents ) ] do

      # Transform partitions to exponent vectors.
      # At position $i$ we store the number of cycles of length $i$.
      exp:= [];
      for j in [ 1 .. Maximum( exponents[i] ) ] do exp[j]:= 0; od;
      for j in exponents[i] do exp[j]:= exp[j] + 1; od;
      exponents[i]:= exp;

    od;

    # Compute necessary power maps.
    powermap:= ShallowCopy( ComputedPowerMaps( tbl ) );
    for i in [ 1 .. n ] do
      if not IsBound( powermap[i] ) then
        powermap[i]:= PowerMap( tbl, i );
      fi;
    od;

    symmetricparts:= [];
    for chi in characters do

      Info( InfoCharacterTable, 2,
            "SymmetricParts: chi[.]" );
      sym:= List( chi, x -> 0 );

      # Loop over the conjugacy classes of the symmetric group.
      for j in [ 1 .. Length( symcentralizers ) ] do

        exp:= exponents[j];

        for k in [ 1 .. nccl ] do
          factor:= 1;
          for i in [ 1 .. Length( exp ) ] do
            if IsBound( exp[i] ) then
              factor:= factor * chi[ powermap[i][k] ]^exp[i];
            fi;
          od;
          sym[k]:= sym[k] + factor / symcentralizers[j];
        od;

      od;
      Add( symmetricparts, sym );

    od;

    # Return the symmetrizations.
    return symmetricparts;
end;


#############################################################################
##
#F  AntiSymmetricParts( <tbl>, <character>, <n> )
##
AntiSymmetricParts := function( tbl, characters, n )

    local i,
          j,
          k,
          nccl,
          exponents,
          symcentralizers,
          antisymmetricparts,
          chi,
          sym,
          exp,
          factor,
          powermap;

    if IsEmpty( characters ) then
      return [];
    fi;

    nccl:= NrConjugacyClasses( tbl );
    exponents:= Partitions( n );
    symcentralizers:= CharacterTable( "Symmetric" )!.centralizers[1];
    symcentralizers:= List( exponents, x -> symcentralizers( n, x ) );

    for i in [ 1 .. Length( exponents ) ] do

      # Transform partitions to exponent vectors.
      # At position $i$ we store the number of cycles of length $i$.

      exp:= [];
      for j in [ 1 .. Maximum( exponents[i] ) ] do exp[j]:= 0; od;
      for j in exponents[i] do exp[j]:= exp[j] + 1; od;
      exponents[i]:= exp;

    od;

    # Compute necessary power maps.
    powermap:= ShallowCopy( ComputedPowerMaps( tbl ) );
    for i in [ 1 .. n ] do
      if not IsBound( powermap[i] ) then
        powermap[i]:= PowerMap( tbl, i );
      fi;
    od;

    # Compute the symmetrizations.
    antisymmetricparts:= [];
    for chi in characters do

      Info( InfoCharacterTable, 2,
            "AntiSymmetricParts: chi[.]" );
      sym:= List( chi, x -> 0 );
      for j in [ 1 .. Length( exponents ) ] do

        exp:= exponents[j];

        for k in [ 1 .. nccl ] do
          factor:= 1;
          for i in [ 1 .. Length( exp ) ] do
            if IsBound( exp[i] ) then
              if i mod 2 = 0 and exp[i] mod 2 = 1 then
                factor:= -factor * chi[ powermap[i][k] ]^exp[i];
              else
                factor:=  factor * chi[ powermap[i][k] ]^exp[i];
              fi;
            fi;
          od;
          sym[k]:= sym[k] + factor / symcentralizers[j];
        od;

      od;
      Add( antisymmetricparts, sym );

    od;

    # Return the symmetrizations.
    return antisymmetricparts;
end;


#############################################################################
##
#F  MinusCharacter( <character>, <prime_powermap>, <prime> )
##
##  the (parametrized) character $<character>^{<prime>-}$, defined by
##  $\chi^{p-}(g):= ( \chi(g)^p - \chi(g^p) ) / p$
##
MinusCharacter := function( character, prime_powermap, prime )

    local i, j, minuscharacter, diff, power;

    minuscharacter:= [];
    for i in [ 1 .. Length( character ) ] do
      if IsInt( prime_powermap[i] ) then
        diff:= ( character[i]^prime - character[prime_powermap[i]] ) / prime;
        if IsCycInt( diff ) then
          minuscharacter[i]:= diff;
        else
          minuscharacter[i]:= Unknown();
          Info( InfoCharacterTable, 2,
                "MinusCharacter: value at class ", i,
                " not divisible by ", prime );
        fi;
      else
        minuscharacter[i]:= [];
        power:= character[i] ^ prime;
        for j in prime_powermap[i] do
          diff:= ( power - character[j] ) / prime;
          if IsCycInt( diff ) then
            AddSet( minuscharacter[i], diff );
          else
            Info( InfoCharacterTable, 2,
                  "MinusCharacter: improvement at class ",
                  i, " found because of congruences" );
          fi;
        od;
        if minuscharacter[i] = [] then
          minuscharacter[i]:= Unknown();
          Info( InfoCharacterTable, 2,
                "MinusCharacter: no value possible at class ", i );
        elif Length( minuscharacter[i] ) = 1 then
          minuscharacter[i]:= minuscharacter[i][1];
        fi;
      fi;
    od;
    return minuscharacter;
end;


#############################################################################
##
#F  RefinedSymmetrisations( <tbl>, <chars>, <m>, <func> )
##
##  returns Murnaghan components for orthogonal ('<func>(x,y)=x', see
##  "OrthogonalComponents") or symplectic ('<func>(x,y)=x-y', see
##  "SymplecticComponents") symmetrisations.
##
##  <m> must be an integer in '[ 1 .. 6 ]' in the orthogonal case,
##  and in '[ 1 .. 5 ]' for the symplectic case.
##
##  (Note\:\ It suffices to change 'F2' and 'F4' in order to get the
##  symplectic components from the orthogonal ones.)
##
##  We have (see J.S. Frame, Recursive computation of tensor power
##  components, Bayreuther Mathematische Schriften 10, 153--159)
##
##  component   orthogonal                symplectic
##  M0        = L0                        L0  ( = 1 )
##  M1        = L1                        L1
##  M11       = L11                       L11-L0
##  M2        = L2-L0                     L2
##  M111      = L111                      L111-L1
##  M21       = L21-L1                    L21-L1
##  M3        = L3-L1                     L3
##  M1111     = L1111                     L1111-L11
##  M211      = L211-L11                  L211-L11-L2+L0
##  M22       = L22-L2                    L22-L11
##  M31       = L31-L2-L11+L0             L31-L2
##  M4        = L4-L2                     L4
##  M11111    = L11111                    L11111-L111
##  M2111     = L2111-L111                L2111-L111-L21+L1
##  M221      = L221-L21                  L221-L111-L21+L1
##  M311      = L311-L21-L111+L1          L311-L21-L3+L1
##  M32       = L32-L3-L21+L1             L32-L21
##  M41       = L41-L3-L21+L1             L41-L3
##  M5        = L5-L3                     L5
##  M111111   = L111111                   L111111-L1111
##  M21111    = L21111-L1111              L21111-L1111-L211+L11
##  M2211     = L2211-L211                L2211-L1111-L211-L22+L11+L2
##  M3111     = L3111-L211-L1111+L11      L3111-L211-L31+L11+L2-L0
##  M222      = L222-L22                  L222-L211+L11-L0
##  M321      = L321-L31-L22-L211+L2+L11  L321-L31-L22-L211+L2+L11
##  M33       = L33-L31+L2-L0             L33-L22
##  M411      = L411-L31-L211+L2+L11-L0   L411-L31-L4+L2
##  M42       = L42-L4-L31-L22+L2+L11     L42-L31
##  M51       = L51-L4-L31+L2             L51-L4
##  M6        = L6-L4                     L6
##
RefinedSymmetrisations := function( tbl, chars, m, func )

    local tbl_powermap,           # computed power maps of 'tbl'
          i, classes, components,
          F2, F3, F4, F5, F6,
          M1,
          M2, M11,
          M3, M21, M111,
          M4, M31, M22, M211, M1111,
          M5, M41, M32, M311, M221, M2111, M11111,
          M6, M51, M42, M411, M33, M321, M3111, M222, M2211, M21111, M111111;

    # Compute missing power maps.
    tbl_powermap:= ShallowCopy( ComputedPowerMaps( tbl ) );
    for i in Filtered( [ 2, 3, 5 ], x -> x <= m ) do
      if not IsBound( tbl_powermap[i] ) then
        Info( InfoCharacterTable, 2,
              "RefinedSymmetrisations: computing ", Ordinal(i),
              "power map" );
        tbl_powermap:= PowerMap( tbl, i );
      fi;
    od;

    # Linear characters are not allowed since their symmetrisations need not
    # to be proper characters.
    chars:= Filtered( chars, x -> 1 < x[1] );
    components:= [];
    classes:= [ 1 .. NrConjugacyClasses( tbl ) ];

    for M1 in chars do

      F2 := MinusCharacter( M1, tbl_powermap[2], 2 );

      # orthogonal case: 'M11 = F2'
      # symplectic case: 'M11 = F2 - 1'
      M11:= func( F2, 1 );
      M2 := List( classes, x -> M1[x]^2 - M11[x] - 1 );

      Add( components, M11 );
      Add( components, M2  );

      if m > 2 then

        F3:=    MinusCharacter( M1, tbl_powermap[3], 3 );
        M21:=   F3 - M1;
        M111:=  List( classes, x -> M1[x] * M11[x] - F3[x] );
        M3:=    List( classes, x -> M1[x] * M2[x]  - F3[x] );

        Append( components, [ M21, M111, M3 ] );

        if m > 3 then

          F4:=    MinusCharacter( F2, tbl_powermap[2], 2 );

          # orthogonal case: 'F4 := F4'
          # symplectic case: 'F4 := F4 - M2'
          F4:=    func( F4, M2 );
          M211:=  F4 - M11;
          M31:=   List( classes, x -> M11[x]*M2[x]-F4[x]-M2[x]);
          M22:=   List( classes, x -> M1[x]*M21[x]-F4[x]-M2[x]-M31[x] );
          M1111:= List( classes, x -> M1[x]*M111[x]-F4[x] );
          M4:=    List( classes, x -> M1[x]*M3[x]-M31[x]-M2[x] );

          Append( components, [ M211, M31, M22, M1111, M4 ] );

          if m > 4 then

            F5:= MinusCharacter( M1, tbl_powermap[5], 5 );
            M2111:=  List( classes, x-> F5[x]-M2[x]*F3[x]-M1[x]*M11[x] );
            M311:=   List( classes, x-> M2[x]*M111[x]-M2111[x]-M21[x]
                                               -M111[x] );
            M221:=   List( classes, x-> M1[x]*M211[x]-M2[x]*M111[x] );
            M11111:= List( classes, x-> M1[x]*M1111[x]-M2111[x]-M111[x]);
            M32:=    List( classes, x-> M1[x]*M22[x]-M221[x]-M21[x] );
            M41:=    List( classes, x-> M11[x]*M3[x]-M311[x]-M21[x]
                                               -M3[x] );
            M5:=     List( classes, x-> M1[x]*M4[x]-M41[x]-M3[x] );

            Append( components, [ M2111, M311, M221, M11111, M32, M41, M5 ]);

            if m = 6 then

              F6:= MinusCharacter( F2, tbl_powermap[3], 3 );
              M3111:=   List( classes, x-> M21[x]*M111[x]-F6[x]+F2[x] );
              M411:=    List( classes, x-> M3[x]*M111[x]-M3111[x]-M31[x]
                                              -M211[x] );
              M21111:=  List( classes, x-> M2[x]*M1111[x]-M3111[x]
                                              -M211[x]-M1111[x] );
              M111111:= List( classes, x-> M1[x]*M11111[x]-M21111[x]
                                              -M1111[x] );
              M2211:=   List( classes, x-> M1[x]*M2111[x]-M3111[x]
                                              -M21111[x]-M211[x]-M1111[x] );
              M321:=    List( classes, x-> M1[x]*M311[x]-M3111[x]
                                              -M411[x]-M31[x]-M211[x] );
              M33:=     List( classes, x-> F2[x]*M22[x]-M321[x]-M2211[x]
                                              -M31[x]-M22[x]-M211[x]-F2[x] );
              M51:=     List( classes, x-> F2[x]*M4[x]-M411[x]-M31[x]
                                              -M4[x] );
              M42:=     List( classes, x-> M1[x]*M41[x]-M411[x]-M51[x]
                                              -M31[x]-M4[x] );
              M222:=    List( classes, x-> M2[x]*M22[x]-M321[x]-M42[x]
                                              -M31[x]-M22[x]-M211[x]-M2[x] );
              M6:=      List( classes, x-> M1[x]*M5[x]-M51[x]-M4[x] );

              Append( components, [ M3111, M411, M21111, M111111, M2211,
                                    M321, M33, M51, M42, M222, M6 ] );

            fi;
          fi;
        fi;
      fi;
    od;

    return components;
end;


#############################################################################
##
#F  OrthogonalComponents( <tbl>, <chars>, <m> )
##
OrthogonalComponents := function( tbl, chars, m )
    if     IsCharacterTable( tbl ) and IsList( chars )
       and IsInt( m ) and 1 < m and m < 7 then
      return RefinedSymmetrisations( tbl, chars, m,
                                     function( x, y ) return x; end );
    else
      Error( "usage: OrthogonalComponents( <tbl>, <chars>, <m> ) with ",
             "integer 2 <= m <= 6" );
    fi;
end;


#############################################################################
##
#F  SymplecticComponents( <tbl>, <chars>, <m> )
##
SymplecticComponents := function( tbl, chars, m )
    if     IsCharacterTable( tbl ) and IsList( chars )
       and IsInt( m ) and 1 < m and m < 6 then
      return RefinedSymmetrisations( tbl, chars, m,
                                     function( x, y ) return x-y; end );
    else
      Error( "usage: SymplecticComponents( <tbl>, <chars>, <m> ) with ",
             "integer 2 <= m <= 5" );
    fi;
end;


#############################################################################
##
#F  PrimeBlocks( <tbl>, <prime> )
##
##  Two ordinary irreducible characters $\chi, \psi$ are said to lie in the
##  same block if the images of their central characters $\omega_{\chi},
##  \omega_{\psi}$ under the homomorphism $\ast: R \rightarrow R / M$ are
##  equal.  The central character is defined by
##  $\omega_{\chi}(g) = \chi(g) \|Cl_G(g)\| / \chi(1)$.
##  $R$ denotes the ring of algebraic integers in the complex numbers, $M$ is
##  a maximal ideal in $R$ with $pR \subseteq M$.  Thus $F = R/M$ is a field
##  of characteristics $p$.
##
##  $\chi$ and $\psi$ lie in the same block if and only if there is an integer
##  $n$ with the property $(\omega_{chi}(g) - \omega_{\psi}(g))^n \in pR$
##  (see~\cite{Isaacs}, p. 271).
##
##  Following the proof in~\cite{Isaacs}, a sufficient value for $n$ is
##  $\varphi(\|g\|)$.  The test must be performed only for one class of each
##  Galois family.
##
##  It is sufficient to test $p$-regular classes. (see Feit, p. 150)
##
##  Any character $\chi$ where $p$ does not divide $\|G\| / \chi(1)$
##  (such a character is called defect-zero-character) forms a block of its
##  own.
##
##  If the info level of 'InfoCharacterTable' is at least 2, the defect of
##  the blocks and the height of the characters are printed\:
##
##  For $\|G\| = p^a m$ where $p$ does not divide $m$, the defect of a block
##  is that $d$ where $p^{a-d}$ is the largest power of $p$ that divides all
##  degrees of the characters in the block.
##
##  The height of a $\chi$ is then the largest exponent $h$ where $p^h$
##  divides $\chi(1) / p^{a-d}$.
##
##  'PrimeBlocks' returns a record with fields 'block' and 'defect', both
##  lists, where 'block[i] = j' means that the 'i'--th character lies in the
##  'j'--th block, and 'defect[j]' is the defect of the 'j'--th block.
##
PrimeBlocks := function( tbl, prime )

    local i, j, x,
          characters,
          nccl,
          classes,
          tbl_orders,
          primeblocks,
          blockreps,
          exponents,
          families,
          representatives,
          sameblock,
          central,
          found,
          ppart,
          tbl_irredinfo,
          inverse,
          d,
          gcd,
          filt,
          pos;

    if not ( IsOrdinaryTable( tbl ) and IsPrimeInt( prime ) ) then
      Error( "<tbl> must be an ordinary character table, <prime> a prime" );
    fi;

    characters:= Irr( tbl );
    nccl:= Length( characters[1] );
    classes:= SizesConjugacyClasses( tbl );
    tbl_orders:= OrdersClassRepresentatives( tbl );

    primeblocks:= rec( block:= [], defect:= [] );
    blockreps:= [];
    exponents:= [];
    for i in [ 2 .. nccl ] do exponents[i]:= Phi( tbl_orders[i] ); od;
    families:= GaloisMat( TransposedMat( characters ) ).galoisfams;
    representatives:= Filtered( [ 2 .. nccl ], x -> families[x] <> 0 );
               # only check one representative for each galois family
    ppart:= 1;
    d:= Size( tbl ) / prime;
    while IsInt( d ) do
      ppart:= ppart * prime;
      d:= d / prime;
    od;

    # now 'a' is the exponent of the order of the 'prime' Sylow group of 'tbl'

    sameblock:= function( central1, central2 )
    local i, j, value, coeffs, n;
    for i in representatives do
      value:= central1[i] - central2[i];
      if IsInt( value ) then
        if value mod prime <> 0 then return false; fi;
      elif IsCyc( value ) then
        coeffs:= List( COEFFSCYC( value ), x -> x mod prime );
        value:= 0;
        n:= Length( coeffs );
        for j in [ 1 .. Length( coeffs ) ] do
          value:= value + coeffs[j] * E( n ) ^ ( j - 1 );
        od;
        if not IsCycInt( ( value ^ exponents[i] ) / prime ) then
          return false;
        fi;
      else
        return false;
      fi;
    od;
    return true;
    end;

    for i in [ 1 .. Length( characters ) ] do
      if characters[i][1] mod ppart = 0 then  # defect-0-character
        pos:= Position( characters, characters[i] );
        if pos = i then
          Add( blockreps, characters[i] );
          primeblocks.block[i]:= Length( blockreps );
        else
          primeblocks.block[i]:= primeblocks.block[ pos ];
        fi;
      else
        central:= [];                       # the central character
        for j in [ 2 .. nccl ] do
          central[j]:= classes[j] * characters[i][j] / characters[i][1];
          if not IsCycInt( central[j] ) then
            Error( "central character ", i,
                   " is not an algebraic integer at class ", j );
          fi;
        od;
        j:= 1;
        found:= false;
        while j <= Length( blockreps ) and not found do
          if sameblock( central, blockreps[j] ) then
            primeblocks.block[i]:= j;
            found:= true;
          fi;
          j:= j + 1;
        od;
        if not found then
          Add( blockreps, central );
          primeblocks.block[i]:= Length( blockreps );
        fi;
      fi;
    od;

    tbl_irredinfo:= IrredInfo( tbl );
    for i in [ 1 .. Length( characters ) ] do
      if not IsBound( tbl_irredinfo[i].pblock ) then
        tbl_irredinfo[i].pblock:= [];
      fi;
      tbl_irredinfo[i].pblock[ prime ]:= primeblocks.block[i];
    od;
    Info( InfoCharacterTable, 2,
          "PrimeBlocks: prime blocks for prime ", prime,
          " written to the table" );

    # compute the defects
    inverse:= InverseMap( primeblocks.block );
    for i in inverse do
      if IsInt( i ) then
        Add( primeblocks.defect, 0 );    # defect zero character
        Info( InfoCharacterTable, 2,
              "defect 0: X[", i, "]" );
      else
        d:= ppart;
        for j in i do d:= GcdInt( d, characters[j][1] ); od;
        if d = ppart then
          d:= 0;
        else
          d:= Length( FactorsInt( ppart / d ) );              # the defect
        fi;
        Add( primeblocks.defect, d );

        if 2 <= InfoLevel( InfoCharacterTable ) then

          # print defect and heights
          Print( "#I defect ", d, ";\n" );

          for j in [ 0 .. d ] do
            filt:= Filtered( i, x -> GcdInt( ppart, characters[x][1] )
                                     = ppart / prime^(d-j) );
            if filt <> [] then
              Print( "#I     height ", j, ": X", filt, "\n" );
            fi;
          od;
        fi;

      fi;
    od;

    return primeblocks;
end;


#############################################################################
##
#F  IrreducibleDifferences( <tbl>, <reducibles>, <reducibles2> )
#F  IrreducibleDifferences( <tbl>, <reducibles>, <reducibles2>, <scprmatrix> )
#F  IrreducibleDifferences( <tbl>, <reducibles>, \"triangle\" )
#F  IrreducibleDifferences( <tbl>, <reducibles>, \"triangle\", <scprmatrix> )
##
##  returns the list of irreducible characters which occur as difference
##  of two elements of <reducibles> (if \"triangle\" is specified) or of
##  an element of <reducibles> and an element of <reducibles2>.
##
##  Let 'scpr' be the value of '<tbl>.operations.ScalarProduct'.
##
##  If <scprmatrix> is not specified it will be calculated,
##  otherwise we must have
##  $'<scprmatrix>[i][j] = scpr( <tbl>, <reducibles>[j], <reducibles>[i] )'$
##  resp.
##  $'<scprmatrix>[i][j] = scpr( <tbl>, <reducibles>[j], <reducibles2>[i] )'$.
##
IrreducibleDifferences := function( arg )

    local i, j, x, tbl, reducibles, irreducibledifferences, scprmatrix,
          reducibles2, diff, norms, norms2;

    if not ( Length( arg ) in [ 3, 4 ] and IsOrdinaryTable( arg[1] ) and
             IsList( arg[2] ) and ( IsList( arg[3] ) or IsString( arg[3] ) ) )
       or ( Length( arg ) = 4 and not IsList( arg[4] ) ) then
      Error( "usage: IrreducibleDifferences(tbl,reducibles,\"triangle\")\n",
      "resp.   IrreducibleDifferences(tbl,reducibles,\"triangle\",scprmat)",
      "\n resp.    IrreducibleDifferences(tbl,reducibles,reducibles2)\nresp.",
      "   IrreducibleDifferences(tbl,reducibles,reducibles2,scprmat)" );
    fi;

    tbl:= arg[1];
    reducibles:= arg[2];
    irreducibledifferences:= [];
    if IsString( arg[3] ) then           # "triangle"
      if Length( arg ) = 3 then
        scprmatrix:= MatScalarProducts( tbl, reducibles );
      else
        scprmatrix:= arg[4];
      fi;
      for i in [ 1 .. Length( scprmatrix ) ] do
        for j in [ 1 .. i-1 ] do
          if scprmatrix[i][i] + scprmatrix[j][j] - 2*scprmatrix[i][j] = 1 then
            if reducibles[i][1] > reducibles[j][1] then
              diff:= reducibles[i] - reducibles[j];
              Info( InfoCharacterTable, 2,
                    "IrreducibleDifferences: X[",i, "] - X[",j, "] found" );
            else
              diff:= reducibles[j] - reducibles[i];
              Info( InfoCharacterTable, 2,
                    "IrreducibleDifferences: X[",j, "] - X[",i, "] found" );
            fi;
            AddSet( irreducibledifferences, diff );
          fi;
        od;
      od;
    else                     # not "triangle"
      reducibles2:= arg[3];
      if Length( arg ) = 3 then
        scprmatrix:= MatScalarProducts( tbl, reducibles, reducibles2 );
      else
        scprmatrix:= arg[4];
      fi;
      norms := List( reducibles , x -> ScalarProduct(tbl,x,x) );
      norms2:= List( reducibles2, x -> ScalarProduct(tbl,x,x) );
      for i in [ 1 .. Length( norms ) ] do
        for j in [ 1 .. Length( norms2 ) ] do
          if norms[i] + norms2[j] - 2 * scprmatrix[i][j] = 1 then
            if reducibles[j][1] > reducibles2[i][1] then
              diff:= reducibles[j] - reducibles2[i];
              Info( InfoCharacterTable, 2,
                    "IrreducibleDifferences: X[",j, "] - Y[",i, "] found" );
            else
              diff:= reducibles2[i] - reducibles[j];
              Info( InfoCharacterTable, 2,
                    "IrreducibleDifferences: Y[",i, "] - X[",j, "] found" );
            fi;
            AddSet( irreducibledifferences, diff );
          fi;
        od;
      od;
    fi;
    return irreducibledifferences;
end;


#############################################################################
##
#E  ctblchar.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



