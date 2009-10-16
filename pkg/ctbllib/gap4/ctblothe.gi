#############################################################################
##
#W  ctblothe.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id: ctblothe.gi,v 1.2 2003/10/16 08:28:04 gap Exp $
##
#Y  Copyright 1990-1992,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of functions for interfaces to
##  other data formats of character tables.
##
##  1. interface to {\sf CAS}
##  2. interface to {\sf MOC}
##  3. interface to {\GAP}~3
##  4. interface to the Cambridge format
##
Revision.ctblothe_gi :=
    "@(#)$Id: ctblothe.gi,v 1.2 2003/10/16 08:28:04 gap Exp $";


#############################################################################
##
##  1. interface to {\sf CAS}
##


#############################################################################
##
#F  CASString( <tbl> )
##
InstallGlobalFunction( CASString, function( tbl )
    local ll,                 # line length
          CAS,                # the string, result
          i, j,               # loop variables
          convertcyclotom,    # local function, string of cyclotomic
          convertrow,         # local function, convert a whole list
          column,
          param,              # list of class parameters
          fus,                # loop over fusions
          tbl_irredinfo;

    ll:= SizeScreen()[1];

    if HasIdentifier( tbl ) then                        # name
      CAS:= Concatenation( "'", Identifier( tbl ), "'\n" );
    else
      CAS:= "'NN'\n";
    fi;
    Append( CAS, "00/00/00. 00.00.00.\n" );             # date
    if HasSizesCentralizers( tbl ) then                 # nccl, cvw, ctw
      Append( CAS, "(" );
      Append( CAS, String( Length( SizesCentralizers( tbl ) ) ) );
      Append( CAS, "," );
      Append( CAS, String( Length( SizesCentralizers( tbl ) ) ) );
      Append( CAS, ",0," );
    else
      Append( CAS, "(0,0,0," );
    fi;

    if HasIrr( tbl ) then
      Append( CAS, String( Length( Irr( tbl ) ) ) );    # max
      Append( CAS, "," );
      if Length( Irr( tbl ) ) = Length( Set( Irr( tbl ) ) ) then
        Append( CAS, "-1," );                           # link
      else
        Append( CAS, "0," );                            # link
      fi;
    fi;
    Append( CAS, "0)\n" );                              # tilt
    if HasInfoText( tbl ) then                          # text
      Append( CAS, "text:\n(#" );
      Append( CAS, InfoText( tbl ) );
      Append( CAS, "#),\n" );
    fi;

    convertcyclotom:= function( cyc )
    local i, str, coeffs;
    coeffs:= COEFFS_CYC( cyc );
    str:= Concatenation( "\n<w", String( Length( coeffs ) ), "," );
    if coeffs[1] <> 0 then
      Append( str, String( coeffs[1] ) );
    fi;
    i:= 2;
    while i <= Length( coeffs ) do
      if Length( str ) + Length( String( coeffs[i] ) )
                       + Length( String( i-1 ) ) + 4 >= ll then
        Append( CAS, str );
        Append( CAS, "\n" );
        str:= "";
      fi;
      if coeffs[i] < 0 then
        Append( str, "-" );
        if coeffs[i] <> -1 then
          Append( str, String( -coeffs[i] ) );
        fi;
        Append( str, "w" );
        Append( str, String( i-1 ) );
      elif coeffs[i] > 0 then
        Append( str, "+" );
        if coeffs[i] <> 1 then
          Append( str, String( coeffs[i] ) );
        fi;
        Append( str, "w" );
        Append( str, String( i-1 ) );
      fi;
      i:= i+1;
    od;
    Append( CAS, str );
    Append( CAS, "\n>\n" );
    end;

    convertrow:= function( list )
    local i, str;
    if IsCycInt( list[1] ) and not IsInt( list[1] ) then
      convertcyclotom( list[1] );
      str:= "";
    elif IsUnknown( list[1] ) or IsList( list[1] ) then
      str:= "?";
    else
      str:= ShallowCopy( String( list[1] ) );
    fi;
    i:= 2;
    while i <= Length( list ) do
      if IsCycInt( list[i] ) and not IsInt( list[i] ) then
        Append( CAS, str );
        Append( CAS, "," );
        convertcyclotom( list[i] );
        str:= "";
      elif IsUnknown( list[i] ) or IsList( list[i] ) then
        if Length( str ) + 4 < ll then
          Append( str, ",?" );
        else
          Append( CAS, str );
          Append( CAS, ",?\n" );
          str:= "";
        fi;
      else
        if Length(str) + Length( String(list[i]) ) + 5 < ll then
          Append( str, "," );
          Append( str, String( list[i] ) );
        else
          Append( CAS, str );
          Append( CAS, ",\n" );
          str:= String( list[i] );
        fi;
      fi;
      i:= i+1;
    od;
    Append( CAS, str );
    Append( CAS, "\n" );
    end;

    Append( CAS, "order=" );                            # order
    Append( CAS, String( Size( tbl ) ) );
    if HasSizesCentralizers( tbl ) then                 # centralizers
      Append( CAS, ",\ncentralizers:(\n" );
      convertrow( SizesCentralizers( tbl ) );
      Append( CAS, ")" );
    fi;
    if HasOrdersClassRepresentatives( tbl ) then        # orders
      Append( CAS, ",\nreps:(\n" );
      convertrow( OrdersClassRepresentatives( tbl ) );
      Append( CAS, ")" );
    fi;
    if HasComputedPowerMaps( tbl ) then                 # power maps
      for i in [ 1 .. Length( ComputedPowerMaps( tbl ) ) ] do
        if IsBound( ComputedPowerMaps( tbl )[i] ) then
          Append( CAS, ",\npowermap:" );
          Append( CAS, String(i) );
          Append( CAS, "(\n" );
          convertrow( ComputedPowerMaps( tbl )[i] );
          Append( CAS, ")" );
        fi;
      od;
    fi;
    if HasClassParameters( tbl )                        # classtext
       and ForAll( ClassParameters( tbl ),              # (partitions only)
                   x ->     IsList( x ) and Length( x ) = 2
                        and x[1] = 1 and IsList( x[2] )
                        and ForAll( x[2], IsPosInt ) ) then
      Append( CAS, ",\nclasstext:'part'\n($[" );
      param:= ClassParameters( tbl );
      convertrow( param[1][2] );
      Append( CAS, "]$" );
      for i in [ 2 .. Length( param ) ] do
        Append( CAS, "\n,$[" );
        convertrow( param[i][2] );
        Append( CAS, "]$" );
      od;
      Append( CAS, ")" );
    fi;
    if HasComputedClassFusions( tbl ) then              # fusions
      for fus in ComputedClassFusions( tbl ) do
        if IsBound( fus.type ) then
          if fus.type = "normal" then
            Append( CAS, ",\nnormal subgroup " );
          elif fus.type = "factor" then
            Append( CAS, ",\nfactor " );
          else
            Append( CAS, ",\n" );
          fi;
        else
          Append( CAS, ",\n" );
        fi;
        Append( CAS, "fusion:'" );
        Append( CAS, fus.name );
        Append( CAS, "'(\n" );
        convertrow( fus.map );
        Append( CAS, ")" );
      od;
    fi;
    if HasIrr( tbl ) then                              # irreducibles
      Append( CAS, ",\ncharacters:" );
      for i in Irr( tbl ) do
        Append( CAS, "\n(" );
        convertrow( i );
        Append( CAS, ",0:0)" );
      od;
    fi;
    if HasComputedPrimeBlockss( tbl ) then             # blocks
      for i in [ 2 .. Length( ComputedPrimeBlockss( tbl ) ) ] do
        if IsBound( ComputedPrimeBlockss( tbl )[i] ) then
          Append( CAS, ",\nblocks:" );
          Append( CAS, String( i ) );
          Append( CAS, "(\n" );
          convertrow( ComputedPrimeBlockss( tbl )[i] );
          Append( CAS, ")" );
        fi;
      od;
    fi;
    if HasComputedIndicators( tbl ) then               # indicators
      for i in [ 2 .. Length( ComputedIndicators( tbl ) ) ] do
        if IsBound( ComputedIndicators( tbl )[i] ) then
          Append( CAS, ",\nindicator:" );
          Append( CAS, String( i ) );
          Append( CAS, "(\n" );
          convertrow( ComputedIndicators( tbl )[i] );
          Append( CAS, ")" );
        fi;
      od;
    fi;
    if 27 < ll then
      Append( CAS, ";\n/// converted from GAP" );
    else
      Append( CAS, ";\n///" );
    fi;
    return CAS;
end );


#############################################################################
##
##  2. interface to {\sf MOC}
##


#############################################################################
##
#F  MOCFieldInfo( <F> )
##
##  For a number field <F>, `MOCFieldInfo' returns a record with components
##  \beginitems
##  `nofcyc' &
##      the conductor of <F>,
##
##  `repres' &
##      a list of orbit representatives forming the Parker base of <F>,
##
##  `stabil' &
##      a smallest generating system of the stabilizer, and
##
##  `ParkerBasis' &
##      the Parker basis of <F>.
##  \enditems
##
BindGlobal( "MOCFieldInfo", function( F )
    local i, j, n, orbits, stab, cycs, coeffs, base, repres, rank, max, pos,
          sub, sub2, stabil, elm, numbers, orb, orders, gens;

    if F = Rationals then
      return rec(
                  nofcyc      := 1,
                  repres      := [ 0 ],
                  stabil      := [],
                  ParkerBasis := Basis( Rationals )
                 );
    fi;

    n:= Conductor( F );

    # representatives of orbits under the action of `GaloisStabilizer( F )'
    # on `[ 0 .. n-1 ]'
    numbers:= [ 0 .. n-1 ];
    orbits:= [];
    stab:= GaloisStabilizer( F );
    while not IsEmpty( numbers ) do
      orb:= Set( List( numbers[1] * stab, x -> x mod n ) );
      Add( orbits, orb );
      SubtractSet( numbers, orb );
    od;

    # orbit sums under the corresponding action on `n'--th roots of unity
    cycs:= List( orbits, x -> Sum( x, y -> E(n)^y, 0 ) );
    coeffs:= List( cycs, x -> CoeffsCyc( x, n ) );

    # Compute the Parker basis.
    gens:= [ 1 ];
    base:= [ coeffs[1] ];
    repres:= [ 0 ];
    rank:= 1;

# better 'while' !!

    for i in [ 1 .. Length( coeffs ) ] do
      if RankMat( Union( base, [ coeffs[i] ] ) ) > rank then
        rank:= rank + 1;
        Add( gens, cycs[i] );
        Add( base, coeffs[i] );
        Add( repres, orbits[i][1] );
      else

# throw away !!

        Unbind( cycs[i] );
        Unbind( coeffs[i] );
        Unbind( orbits[i] );
      fi;
    od;

    # compute small generating system for the stabilizer:
    # Start with the empty generating system.
    # Add the smallest number of maximal multiplicative order to
    # the generating system, remove all points in the new group.
    # Proceed until one has a generating system for the stabilizer.
    orders:= List( stab, x -> OrderMod( x, n ) );
    orders[1]:= 0;
    max:= Maximum( orders );
    stabil:= [];
    sub:= [ 1 ];
    while max <> 0 do
      pos:= Position( orders, max );
      elm:= stab[ pos ];
      AddSet( stabil, elm );
      sub2:= sub;
      for i in [ 1 .. max-1 ] do
        sub2:= Union( sub2, List( sub, x -> ( x * elm^i ) mod n ) );
      od;
      sub:= sub2;
      for j in sub do
        orders[ Position( stab, j ) ]:= 0;
      od;
      max:= Maximum( orders );
    od;

    return rec(
                nofcyc      := n,
                repres      := repres,
                stabil      := stabil,
                ParkerBasis := Basis( F, gens )
               );
    end );


#############################################################################
##
#F  MAKElb11( <listofns> )
##
InstallGlobalFunction( MAKElb11, function( listofns )
    local n, f, k, j, fields, info, num, stabs;

    # 12 entries per row
    num:= 12;

    for n in listofns do

      if n > 2 and n mod 4 <> 2 then

        fields:= Filtered( Subfields( CF(n) ), x -> Conductor( x ) = n );
        fields:= List( fields, MOCFieldInfo );
        stabs:=  List( fields,
                       x -> Concatenation( [ x.nofcyc, Length( x.repres ),
                                           Length(x.stabil) ], x.stabil ) );
        fields:= List( fields,
                       x -> Concatenation( [ x.nofcyc, Length( x.repres ) ],
                                           x.repres, [ Length( x.stabil ) ],
                                           x.stabil ) );

        # sort fields according to degree and stabilizer generators
        fields:= Permuted( fields, Sortex( stabs ) );
        for f in fields do
          for k in [ 0 .. QuoInt( Length( f ), num ) - 1 ] do
            for j in [ 1 .. num ] do
              Print( String( f[ k*num + j ], 4 ) );
            od;
            Print( "\n " );
          od;
          for j in [ num * QuoInt( Length(f), num ) + 1 .. Length(f) ] do
            Print( String( f[j], 4 ) );
          od;
          Print( "\n" );
        od;

      fi;

    od;
end );


#############################################################################
##
#F  MOCPowerInfo( <listofbases>, <galoisfams>, <powermap>, <prime> )
##
##  For a list <listofbases> of number field bases as produced in
##  `MOCTable' (see~"MOCTable"),
##  the information of labels `30220' and `30230' is computed.
##  This is a sequence
##  $$
##  x_{1,1} x_{1,2} \ldots x_{1,m_1} 0 x_{2,1} x_{2,2} \ldots x_{2,m_2}
##  0 \ldots 0 x_{n,1} x_{n,2} \ldots x_{n,m_n} 0
##  $$
##  with the followong meaning.
##  Let $[ a_1, a_2, \ldots, a_n ]$ be a character in {\MOC} format.
##  The value of the character obtained on indirection by the <prime>-th
##  power map at position $i$ is
##  $$
##  x_{i,1} a_{x_{i,2}} + x_{i,3} a_{x_{i,4}} + \ldots
##  + x_{i,m_i-1} a_{x_{i,m_i}} \ .
##  $$
##
##  The information is computed as follows.
##
##  If $g$ and $g^{<prime>}$ generate the same cyclic group then write the
##  <prime>-th conjugates of the base vectors $v_1, \ldots, v_k$ as
##  $\tilde{v_i} = \sum_{j=1}^{k} c_{ij} v_j$.
##  The $j$-th coefficient of the <prime>-th conjugate of
##  $\sum_{i=1}^{k} a_i v_i$ is then $\sum_{i=1}^{k} a_i c_{ij}$.
##
##  If $g$ and $g^{<prime>}$ generate different cyclic groups then write the
##  base vectors $w_1, \ldots, w_{k^{\prime}}$ in terms of the $v_i$ as
##  $w_i = \sum_{j=1}^{k} c_{ij} v_j$.
##  The $v_j$-coefficient of the indirection of
##  $\sum_{i=1}^{k^{\prime}} a_i w_i$ is then
##  $\sum_{i=1}^{k^{\prime}} a_i c_{ij}$.
##
##  For $<prime> = -1$ (complex conjugation) we have of course
##  $k = k^{\prime}$ and $w_i = \overline{v_i}$.
##  In this case the parameter <powermap> may have any value.
##  Otherwise <powermap> must be the `ComputedPowerMaps' value of the
##  underlying character table;
##  for any Galois automorphism of a cyclic subgroup,
##  it must contain a map covering this automorphism.
##
##  <galoisfams> is a list that describes the Galois conjugacy;
##  its format is equal to that of the `galoisfams' component in
##  records returned by `GaloisMat'.
##
##  `MOCPowerInfo' returns a list containing the information for <prime>,
##  the part of class `i' is stored in a list at position `i'.
##
##  *Note* that `listofbases' refers to all classes, not only
##  representatives of cyclic subgroups;
##  non-leader classes of Galois families must have value 0.
##
BindGlobal( "MOCPowerInfo",
    function( listofbases, galoisfams, powermap, prime )
    local i, j, k, c, n, f, power, im, oldim, imf, pp, entry;

    power:= [];
    i:= 1;
    while i <= Length( listofbases ) do

      if (     IsBasis( listofbases[i] )
           and UnderlyingLeftModule( listofbases[i] ) = Rationals )
         or listofbases[i] = 1 then

        # rational class
        if prime = -1 then
          Add( power, [ 1, i, 0 ] );
        else

          # `prime'-th power of class `i' (of course rational)
          Add( power, [ 1, powermap[ prime ][i], 0 ] );

        fi;

      elif listofbases[i] <> 0 then

        # the field basis
        f:= listofbases[i];

        if prime = -1 then

          # the coefficient matrix
          c:= List( BasisVectors( f ),
                    x -> Coefficients( f, GaloisCyc( x, -1 ) ) );
          im:= i;

        else

          # the image class and field
          oldim:= powermap[ prime ][i];
          if galoisfams[ oldim ] = 1 then
            im:= oldim;
          else
            im:= 1;
            while not IsList( galoisfams[ im ] ) or
                  not oldim in galoisfams[ im ][1] do
              im:= im+1;
            od;
          fi;

          if listofbases[ im ] = 1 then
#T does this happen?

            # maps to rational class `im'
            c:= [ Coefficients( f, 1 ) ];

          elif im = i then

            # just Galois conjugacy
            c:= List( BasisVectors( f ),
                      x -> Coefficients( f, GaloisCyc(x,prime) ) );

          else

            # compute embedding of the image field
            imf:= listofbases[ im ];
            pp:= false;
            for j in [ 2 .. Length( powermap ) ] do
              if IsBound( powermap[j] ) and powermap[j][ im ] = oldim then
                pp:= j;
              fi;
            od;
            if pp = false then
              Error( "MOCPowerInfo cannot compute Galois autom. for ", im,
                     " -> ", oldim, " from power map" );
            fi;

            c:= List( BasisVectors( imf ),
                      x -> Coefficients( f, GaloisCyc(x,pp) ) );

          fi;

        fi;

        # the power info for column `i' of the {\MOC} table,
        # and all other columns in the same cyclic subgroup
        entry:= [];
        n:= Length( c );
        for j in [ 1 .. Length( c[1] ) ] do
          for k in [ 1 .. n ] do
            if c[k][j] <> 0 then
              Append( entry, [ c[k][j], im + k - 1 ] );
#T this assumes that Galois families are subsequent!
            fi;
          od;
          Add( entry, 0 );
        od;
        Add( power, entry );

      fi;
      i:= i+1;
    od;
    return power;
end );


#############################################################################
##
#F  ScanMOC( <list> )
##
InstallGlobalFunction( ScanMOC, function( list )
    local digits, positive, negative, specials,
          admissible,
          number,
          pos, result,
          scannumber2,     # scan a number in {\MOC}~2 format
          scannumber3,     # scan a number in {\MOC}~3 format
          label, component;

    # Check the argument.
    if not IsList( list ) then
      Error( "argument must be a list" );
    fi;

    # Define some constants used for {\MOC}~3 format.
    digits:= "0123456789";
    positive:= "abcdefghij";
    negative:= "klmnopqrs";
    specials:= "tuvwyz";

    # Remove characters that are nonadmissible, for example line breaks.
    admissible:= Union( digits, positive, negative, specials );
    list:= Filtered( list, char -> char in admissible );

    # local functions: scan a number of {\MOC}~2 or {\MOC}~3 format
    scannumber2:= function()
    number:= 0;
    while list[ pos ] < 10000 do

      # number is not complete
      number:= 10000 * number + list[ pos ];
      pos:= pos + 1;
    od;
    if list[ pos ] < 20000 then
      number:= 10000 * number + list[ pos ] - 10000;
    else
      number:= - ( 10000 * number + list[ pos ] - 20000 );
    fi;
    pos:= pos + 1;
    return number;
    end;

    scannumber3:= function()
    number:= 0;
    while list[ pos ] in digits do

      # number is not complete
      number:=  10000 * number
               + 1000 * Position( digits, list[ pos   ] )
               +  100 * Position( digits, list[ pos+1 ] )
               +   10 * Position( digits, list[ pos+2 ] )
               +        Position( digits, list[ pos+3 ] )
               - 1111;
      pos:= pos + 4;
    od;

    # end of number or small number
    if list[ pos ] in positive then

      # small positive number
      if number <> 0 then
        Error( "corrupted input" );
      fi;
      number:=   10000 * number
               + Position( positive, list[ pos ] )
               - 1;

    elif list[ pos ] in negative then

      # small negative number
      if number <> 0 then
        Error( "corrupted input" );
      fi;
      number:=   10000 * number
               - Position( negative, list[ pos ] );

    elif   list[ pos ] = 't' then
      number:=   10000 * number
               + 10 * Position( digits, list[ pos+1 ] )
               +      Position( digits, list[ pos+2 ] )
               - 11;
      pos:= pos + 2;
    elif list[ pos ] = 'u' then
      number:=   10000 * number
               - 10 * Position( digits, list[ pos+1 ] )
               -      Position( digits, list[ pos+2 ] )
               + 11;
      pos:= pos + 2;
    elif list[ pos ] = 'v' then
      number:=   10000 * number
               + 1000 * Position( digits, list[ pos+1 ] )
               +  100 * Position( digits, list[ pos+2 ] )
               +   10 * Position( digits, list[ pos+3 ] )
               +        Position( digits, list[ pos+4 ] )
               - 1111;
      pos:= pos + 4;
    elif list[ pos ] = 'w' then
      number:= - 10000 * number
               - 1000 * Position( digits, list[ pos+1 ] )
               -  100 * Position( digits, list[ pos+2 ] )
               -   10 * Position( digits, list[ pos+3 ] )
               -        Position( digits, list[ pos+4 ] )
               + 1111;
      pos:= pos + 4;
    fi;
    pos:= pos + 1;
    return number;
    end;

    # convert <list>
    result:= rec();
    pos:= 1;

    if IsInt( list[1] ) then

      # {\MOC}~2 format
      if list[1] = 30100 then pos:= 2; fi;
      while pos <= Length( list ) and list[ pos ] <> 31000 do
        label:= list[ pos ];
        pos:= pos + 1;
        component:= [];
        while pos <= Length( list ) and list[ pos ] < 30000 do
          Add( component, scannumber2() );
        od;
        result.( label ):= component;
      od;

    else

      # {\MOC}~3 format
      if list{ [ 1 .. 4 ] } = "y100" then
        pos:= 5;
      fi;

      while pos <= Length( list ) and list[ pos ] <> 'z' do

        # label of form `yABC'
        label:= list{ [ pos .. pos+3 ] };
        pos:= pos + 4;
        component:= [];
        while pos <= Length( list ) and not list[ pos ] in "yz" do
          Add( component, scannumber3() );
        od;
        result.( label ):= component;
      od;
    fi;

    return result;
end );


#############################################################################
##
#F  MOCChars( <tbl>, <gapchars> )
##
InstallGlobalFunction( MOCChars, function( tbl, gapchars )
    local i, result, chi, MOCchi;

    # take the MOC format (if necessary, construct the MOC format table first)
    if IsCharacterTable( tbl ) then
      tbl:= MOCTable( tbl );
    fi;

    # translate the characters
    result:= [];
    for chi in gapchars do
      MOCchi:= [];
      for i in [ 1 .. Length( tbl.fieldbases ) ] do
        if UnderlyingLeftModule( tbl.fieldbases[i] ) = Rationals then
          Add( MOCchi, chi[ tbl.repcycsub[i] ] );
        else
          Append( MOCchi, Coefficients( tbl.fieldbases[i],
                                        chi[ tbl.repcycsub[i] ] ) );
        fi;
      od;
      Add( result, MOCchi );
    od;
    return result;
end );


#############################################################################
##
#F  GAPChars( <tbl>, <mocchars> )
##
InstallGlobalFunction( GAPChars, function( tbl, mocchars )
    local i, j, val, result, chi, GAPchi, map, pos, numb, nccl;

    # take the {\MOC} format table (if necessary, construct it first)
    if IsCharacterTable( tbl ) then
      tbl:= MOCTable( tbl );
    fi;

    # `map[i]' is the list of columns of the {\MOC} table that belong to
    # the `i'-th cyclic subgroup of the {\MOC} table
    map:= [];
    pos:= 0;
    for i in [ 1 .. Length( tbl.fieldbases ) ] do
      Add( map, pos + [ 1 .. Length( BasisVectors( tbl.fieldbases[i] ) ) ] );
      pos:= pos + Length( BasisVectors( tbl.fieldbases[i] ) );
    od;

    result:= [];

    # if `mocchars' is not a list of lists, divide it into pieces of length
    # `nccl'
    if not IsList( mocchars[1] ) then
      nccl:= NrConjugacyClasses( tbl.GAPtbl );
      mocchars:= List( [ 1 .. Length( mocchars ) / nccl ],
                       i -> mocchars{ [ (i-1)*nccl+1 .. i*nccl ] } );
    fi;

    for chi in mocchars do
      GAPchi:= [];
      # loop over classes of the {\GAP} table
      for i in [ 1 .. Length( tbl.galconjinfo ) / 2 ] do

        # the number of the cyclic subgroup in the MOC table
        numb:= tbl.galconjinfo[ 2*i - 1 ];
        if UnderlyingLeftModule( tbl.fieldbases[ numb ] ) = Rationals then

          # rational class
          GAPchi[i]:= chi[ map[ tbl.galconjinfo[ 2*i-1 ] ][1] ];

        elif tbl.galconjinfo[ 2*i ] = 1 then

          # representative of cyclic subgroup, not rational
          GAPchi[i]:= chi{ map[ numb ] }
                      * BasisVectors( tbl.fieldbases[ numb ] );

        else

          # irrational class, no representative:
          # conjugate the value on the representative class
          GAPchi[i]:=
             GaloisCyc( GAPchi[ ( Position( tbl.galconjinfo, numb ) + 1 ) / 2 ],
                        tbl.galconjinfo[ 2*i ] );

        fi;
      od;
      Add( result, GAPchi );
    od;
    return result;
end );


#############################################################################
##
#F  MOCTable0( <gaptbl> )
##
##  {\MOC}~3 format table of ordinary {\GAP} table <gaptbl>
##
BindGlobal( "MOCTable0", function( gaptbl )
    local i, j, k, d, n, p, result, trans, gal, extendedfields, entry,
          gaptbl_orders, vectors, prod, pow, im, cl, basis, struct, rep,
          aut, primes;

    # initialize the record
    result:= rec( identifier := Concatenation( "MOCTable(",
                                               Identifier( gaptbl ), ")" ),
                  prime  := 0,
                  fields := [],
                  GAPtbl := gaptbl );

    # 1. Compute necessary information to encode the irrational columns.
    #
    #    Each family of $n$ Galois conjugate classes is replaced by $n$
    #    integral columns, the Parker basis of each number field
    #    is stored in the component `fieldbases' of the result.
    #
    trans:= TransposedMat( Irr( gaptbl ) );
    gal:= GaloisMat( trans ).galoisfams;

    result.cycsubgps:= [];
    result.repcycsub:= [];
    result.galconjinfo:= [];
    for i in [ 1 .. Length( gal ) ] do
      if gal[i] = 1 then
        Add( result.repcycsub, i );
        result.cycsubgps[i]:= Length( result.repcycsub );
        Append( result.galconjinfo, [ Length( result.repcycsub ), 1 ] );
      elif gal[i] <> 0 then
        Add( result.repcycsub, i );
        n:= Length( result.repcycsub );
        for k in gal[i][1] do
          result.cycsubgps[k]:= n;
        od;
        Append( result.galconjinfo, [ Length( result.repcycsub ), 1 ] );
      else
        rep:= result.repcycsub[ result.cycsubgps[i] ];
        aut:= gal[ rep ][2][ Position( gal[ rep ][1], i ) ]
                 mod Conductor( trans[i] );
        Append( result.galconjinfo, [ result.cycsubgps[i], aut ] );
      fi;
    od;

    gaptbl_orders:= OrdersClassRepresentatives( gaptbl );

    # centralizer orders and element orders
    # (for representatives of cyclic subgroups only)
    result.centralizers:= SizesCentralizers( gaptbl ){ result.repcycsub };
    result.orders:= OrdersClassRepresentatives( gaptbl ){ result.repcycsub };

    # the fields (for cyclic subgroups only)
    result.fieldbases:= List( result.repcycsub,
                        i -> MOCFieldInfo( Field( trans[i] ) ).ParkerBasis );

    # fields for all classes (used by `MOCPowerInfo')
    extendedfields:= List( [ 1 .. Length( gal ) ], x -> 0 );
    for i in [ 1 .. Length( result.repcycsub ) ] do
      extendedfields[ result.repcycsub[i] ]:= result.fieldbases[i];
    od;

    # `30170' power maps:
    # for each cyclic subgroup (except the trivial one) and each prime
    # divisor of the representative order store four values, the number
    # of the subgroup, the power, the number of the cyclic subgroup
    # containing the image, and the power to which the representative
    # must be raised to give the image class.
    # (This is used only to construct the `30230' power map/embedding
    # information.)
    # In `result.30170' only a list of lists (one for each cyclic subgroup)
    # of all these values is stored, it will not be used by {\GAP}.
    #
    result.30170:= [ [] ];
    for i in [ 2 .. Length( result.repcycsub ) ] do

      entry:= [];
      for d in Set( FactorsInt( gaptbl_orders[ result.repcycsub[i] ] ) ) do

        # cyclic subgroup `i' to power `d'
        Add( entry, i );
        Add( entry, d );
        pow:= PowerMap( gaptbl, d )[ result.repcycsub[i] ];

        if gal[ pow ] = 1 then

          # rational class
          Add( entry, Position( result.repcycsub, pow ) );
          Add( entry, 1 );

        else

          # get the representative `im'
          im:= result.repcycsub[ result.cycsubgps[ pow ] ];
          cl:= Position( gal[ im ][1], pow );

          # the image is class `im' to power `gal[ im ][2][cl]'
          Add( entry, Position( result.repcycsub, im ) );
          Add( entry, gal[ im ][2][cl]
                              mod gaptbl_orders[ result.repcycsub[i] ] );

        fi;

      od;

      Add( result.30170, entry );

    od;

    # tensor product information, used to compute the coefficients of
    # the Parker base for tensor products of characters.
    result.tensinfo:= [];
    for basis in result.fieldbases do
      if UnderlyingLeftModule( basis ) = Rationals then
        Add( result.tensinfo, [ 1 ] );
      else
        vectors:= BasisVectors( basis );
        n:= Length( vectors );

        # Compute structure constants.
        struct:= List( vectors, x -> [] );
        for i in [ 1 .. n ] do
          for k in [ 1 .. n ] do
            struct[k][i]:= [];
          od;
          for j in [ 1 .. n ] do
            prod:= Coefficients( basis, vectors[i] * vectors[j] );
            for k in [ 1 .. n ] do
              struct[k][i][j]:= prod[k];
            od;
          od;
        od;

        entry:= [ n ];
        for i in [ 1 .. n ] do
          for j in [ 1 .. n ] do
            for k in [ 1 .. n ] do
              if struct[i][j][k] <> 0 then
                Append( entry, [ struct[i][j][k], j, k ] );
              fi;
            od;
          od;
          Add( entry, 0 );
        od;
        Add( result.tensinfo, entry );
      fi;
    od;

    # `30220' inverse map (to compute complex conjugate characters)
    result.invmap:= MOCPowerInfo( extendedfields, gal, 0, -1 );

    # `30230' power map (field embeddings for $p$-th symmetrizations,
    # where $p$ is a prime not larger than the maximal element order);
    # note that the necessary power maps must be stored on `gaptbl'
    result.powerinfo:= [];
    primes:= Filtered( [ 2 .. Maximum( gaptbl_orders ) ], IsPrimeInt );
    for p in primes do
      PowerMap( gaptbl, p );
    od;
    for p in primes do
      result.powerinfo[p]:= MOCPowerInfo( extendedfields, gal,
                                          ComputedPowerMaps( gaptbl ), p );
    od;

    # `30900': here all irreducible characters
    result.30900:= MOCChars( result, Irr( gaptbl ) );

    return result;
end );


#############################################################################
##
#F  MOCTableP( <gaptbl>, <basicset> )
##
##  {\MOC}~3 format table of {\GAP} Brauer table <gaptbl>,
##  with basic set of ordinary irreducibles at positions in
##  `Irr( OrdinaryCharacterTable( <gaptbl> ) )' given in the list <basicset>
##
BindGlobal( "MOCTableP", function( gaptbl, basicset )
    local i, j, p, result, fusion, mocfusion, images, ordinary, fld, pblock,
          invpblock, ppart, ord, degrees, defect, deg, charfusion, pos,
          repcycsub, ncharsperblock, restricted, invcharfusion, inf, mapp,
          gaptbl_classes;

    # check the arguments
    if not ( IsBrauerTable( gaptbl ) and IsList( basicset ) ) then
      Error( "<gaptbl> must be a Brauer character table,",
             " <basicset> must be a list" );
    fi;

    # transfer information from ordinary {\MOC} table to `result'
    ordinary:= MOCTable0( OrdinaryCharacterTable( gaptbl ) );
    fusion:= GetFusionMap( gaptbl, OrdinaryCharacterTable( gaptbl ) );
    images:= Set( ordinary.cycsubgps{ fusion } );

    # initialize the record
    result:= rec( identifier := Concatenation( "MOCTable(",
                                               Identifier( gaptbl ), ")" ),
                  prime  := UnderlyingCharacteristic( gaptbl ),
                  fields := [],
                  ordinary:= ordinary,
                  GAPtbl := gaptbl );

    result.cycsubgps:= List( fusion,
                   x -> Position( images, ordinary.cycsubgps[x] ) );
    repcycsub:= ProjectionMap( result.cycsubgps );
    result.repcycsub:= repcycsub;

    mocfusion:= CompositionMaps( ordinary.cycsubgps, fusion );

    # fusion map to restrict characters from `ordinary' to `result'
    charfusion:= [];
    pos:= 1;
    for i in [ 1 .. Length( result.cycsubgps ) ] do
      Add( charfusion, pos );
      pos:= pos + 1;
      while pos <= NrConjugacyClasses( result.ordinary.GAPtbl ) and
            OrdersClassRepresentatives( result.ordinary.GAPtbl )[ pos ]
                mod result.prime = 0 do
        pos:= pos + 1;
      od;
    od;

    result.fusions:= [ rec( name:= ordinary.identifier, map:= charfusion ) ];
    invcharfusion:= InverseMap( charfusion );

    result.galconjinfo:= [];
    for i in fusion do
      Append( result.galconjinfo,
              [ Position( images, ordinary.galconjinfo[ 2*i-1 ] ),
                ordinary.galconjinfo[ 2*i ] ] );
    od;

    for fld in [ "centralizers", "orders", "fieldbases", "30170",
                 "tensinfo", "invmap" ] do
      result.( fld ):= List( result.repcycsub,
                             i -> ordinary.( fld )[ mocfusion[i] ] );
    od;

    mapp:= InverseMap( CompositionMaps( ordinary.cycsubgps,
               CompositionMaps( charfusion,
                   InverseMap( result.cycsubgps ) ) ) );
    for i in [ 2 .. Length( result.30170 ) ] do
      for j in 2 * [ 1 .. Length( result.30170[i] ) / 2 ] - 1 do
        result.30170[i][j]:= mapp[ result.30170[i][j] ];
      od;
    od;


    result.powerinfo:= [];
    for p in Filtered( [ 2 .. Maximum( ordinary.orders ) ], IsPrimeInt ) do

      inf:= List( result.repcycsub,
                  i -> ordinary.powerinfo[p][ mocfusion[i] ] );
      for i in [ 1 .. Length( inf ) ] do
        pos:= 2;
        while pos < Length( inf[i] ) do
          while inf[i][ pos + 1 ] <> 0 do
            inf[i][ pos ]:= invcharfusion[ inf[i][ pos ] ];
            pos:= pos + 2;
          od;
          inf[i][ pos ]:= invcharfusion[ inf[i][ pos ] ];
          pos:= pos + 3;
        od;
      od;
      result.powerinfo[p]:= inf;

    od;

    # `30310' number of $p$-blocks
    pblock:= PrimeBlocks( OrdinaryCharacterTable( gaptbl ),
                          result.prime ).block;
    invpblock:= InverseMap( pblock );
    for i in [ 1 .. Length( invpblock ) ] do
      if IsInt( invpblock[i] ) then
        invpblock[i]:= [ invpblock[i] ];
      fi;
    od;
    result.30310:= Maximum( pblock );

    # `30320' defect, numbers of ordinary and modular characters per block
    result.30320:= [ ];
    ppart:= 0;
    ord:= Size( gaptbl );
    while ord mod result.prime = 0 do
      ppart:= ppart + 1;
      ord:= ord / result.prime;
    od;

    for i in [ 1 .. Length( invpblock ) ] do
      defect:= result.prime ^ ppart;
      for j in invpblock[i] do
        deg:= Irr( OrdinaryCharacterTable( gaptbl ) )[j][1];
        while deg mod defect <> 0 do
          defect:= defect / result.prime;
        od;
      od;
      restricted:= List( Irr( OrdinaryCharacterTable( gaptbl )
                         ){ invpblock[i] },
                         x -> x{ fusion } );

      # Form the scalar product on $p$-regular classes.
      gaptbl_classes:= SizesConjugacyClasses( gaptbl );
      ncharsperblock:= Sum( restricted,
          y -> Sum( [ 1 .. Length( gaptbl_classes ) ],
                    i -> gaptbl_classes[i] * y[i]
                             * GaloisCyc( y[i], -1 ) ) ) / Size( gaptbl );

      Add( result.30320,
           [ ppart - Length( FactorsInt( defect ) ),
             Length( invpblock[i] ),
             ncharsperblock ] );
    od;

    # `30350' distribution of ordinary irreducibles to blocks
    #         (irreducible character number `i' has number `i')
    result.30350:= List( invpblock, ShallowCopy);

    # `30360' distribution of basic set characters to blocks:
    result.30360:= List( invpblock,
                         x -> List( Intersection( x, basicset ),
                                    y -> Position( basicset, y ) ) );

    # `30370' positions of basic set characters in irreducibles (per block)
    result.30370:= List( invpblock, x -> Intersection( x, basicset ) );

    # `30550' decomposition of ordinary irreducibles in basic set
    basicset:= Irr( ordinary.GAPtbl ){ basicset };
    basicset:= MOCChars( result, List( basicset, x -> x{ fusion } ) );
    result.30550:= DecompositionInt( basicset,
                          List( ordinary.30900, x -> x{ charfusion } ), 30 );

    # `30900' basic set of restricted ordinary irreducibles,
    result.30900:= basicset;

    return result;
end );


#############################################################################
##
#F  MOCTable( <ordtbl> )
#F  MOCTable( <modtbl>, <basicset> )
##
InstallGlobalFunction( MOCTable, function( arg )
    if Length( arg ) = 1 and IsOrdinaryTable( arg[1] ) then
      return MOCTable0( arg[1] );
    elif Length( arg ) = 2 and IsBrauerTable( arg[1] )
                           and IsList( arg[2] ) then
      return MOCTableP( arg[1], arg[2] );
    else
      Error( "usage: MOCTable( <ordtbl> ) resp.",
                   " MOCTable( <modtbl>, <basicset> )" );
    fi;
end );


#############################################################################
##
#F  MOCString( <moctbl>[, <chars>] )
##
InstallGlobalFunction( MOCString, function( arg )
    local str,                     # result string
          i, j, d, p,              # loop variables
          tbl,                     # first argument
          ncol, free,              # number of columns for printing
          lettP, lettN, digit,     # lists of letters for encoding
          Pr, PrintNumber,         # local functions for printing
          trans, gal,
          repcycsub,
          ord,                     # corresponding ordinary table
          fus, invfus,             # transfer between ord. and modular table
          restr,                   # restricted ordinary irreducibles
          basicset, BS,            # numbers in basic set, basic set itself
          aut, gallist, fields,
          F,
          pow, im, cl,
          info, chi,
          dec;

    # 1. Preliminaries:
    #    initialisations, local functions needed for encoding and printing
    str:= "";

    # number of columns for printing
    ncol:= 80;
    free:= ncol;

    # encode numbers in `[ -9 .. 9 ]' as letters
    lettP:= "abcdefghij";
    lettN:= "klmnopqrs";
    digit:= "0123456789";

    # local function `Pr':
    # Append `string' in lines of length `ncol'
    Pr:= function( string )
    local len;
    len:= Length( string );
    if len <= free then
      Append( str, string );
      free:= free - len;
    else
      if 0 < free then
        Append( str, string{ [ 1 .. free ] } );
        string:= string{ [ free+1 .. len ] };
      fi;
      Append( str, "\n" );
      for i in [ 1 .. Int( ( len - free ) / ncol ) ] do
        Append( str, string{ [ 1 .. ncol ] }, "\n" );
        string:= string{ [ ncol+1 .. Length( string ) ] };
      od;
      free:= ncol - Length( string );
      if free <> ncol then
        Append( str, string );
      fi;
    fi;
    end;

    # local function `PrintNumber': print {\MOC3} code of number `number'
    PrintNumber:= function( number )
    local i, sumber, sumber1, sumber2, len, rest;
    sumber:= String( AbsInt( number ) );
    len:= Length( sumber );
    if len > 4 then

      # long number, fill with leading zeros
      rest:= len mod 4;
      if rest = 0 then
        rest:= 4;
      fi;
      for i in [ 1 .. 4-rest ] do
        sumber:= Concatenation( "0", sumber );
        len:= len+1;
      od;

      sumber1:= sumber{ [ 1 .. len - 4 ] };
      sumber2:= sumber{ [ len - 3 .. len ] };

      # code of last digits is always `vABCD' or `wABCD'
      if number >= 0 then
        sumber:= Concatenation( sumber1, "v", sumber2 );
      else
        sumber:= Concatenation( sumber1, "w", sumber2 );
      fi;

    else

      # short numbers (up to 9999), encode the last digits
      if len = 1 then
        if number >= 0 then
          sumber:= [ lettP[ Position( digit, sumber[1] )     ] ];
        else
          sumber:= [ lettN[ Position( digit, sumber[1] ) - 1 ] ];
        fi;
      elif len = 2 then
        if number >= 0 then
          sumber:= Concatenation( "t", sumber );
        else
          sumber:= Concatenation( "u", sumber );
        fi;
      elif len = 3 then
        if number >= 0 then
          sumber:= Concatenation( "v0", sumber );
        else
          sumber:= Concatenation( "w0", sumber );
        fi;
      else
        if number >= 0 then
          sumber:= Concatenation( "v", sumber );
        else
          sumber:= Concatenation( "w", sumber );
        fi;
      fi;
    fi;

    # print the code in lines of length `ncol'
    Pr( sumber );
    end;

    if Length( arg ) = 1 and IsMatrix( arg[1] ) then

      # number of columns
      Pr( "y110" );
      PrintNumber( Length( arg[1] ) );
      PrintNumber( Length( arg[1] ) );

      # matrix entries under label `30900'
      Pr( "y900" );
      for i in arg[1] do
        for j in i do
          PrintNumber( j );
        od;
      od;

      Pr( "z" );

    elif not ( Length( arg ) in [ 1, 2 ] and IsRecord( arg[1] ) and
             ( Length( arg ) = 1 or IsList( arg[2] ) ) ) then
      Error( "usage: MOCString( <moctbl>[, <chars>] )" );
    else

      tbl:= arg[1];

      # `30100' start of the table
      Pr( "y100" );

      # `30105' characteristic of the field
      Pr( "y105" );
      PrintNumber( tbl.prime );

      # `30110' number of p-regular classes and of cyclic subgroups
      Pr( "y110" );
      PrintNumber( Length( SizesCentralizers( tbl.GAPtbl ) ) );
      PrintNumber( Length( tbl.centralizers ) );

      # `30130' centralizer orders
      Pr( "y130" );
      for i in tbl.centralizers do PrintNumber( i ); od;

      # `30140' representative orders of cyclic subgroups
      Pr( "y140" );
      for i in tbl.orders do PrintNumber( i ); od;

      # `30150' field information
      Pr( "y150" );

      # loop over cyclic subgroups
      for i in tbl.fieldbases do
        if UnderlyingLeftModule( i ) = Rationals then
          PrintNumber( 1 );
        else
          F:= MOCFieldInfo( UnderlyingLeftModule( i ) );
          PrintNumber( F.nofcyc );           # $\Q(e_N)$ is the conductor
          PrintNumber( Length( F.repres ) ); # degree of the field
          for j in F.repres do
            PrintNumber( j );                # representatives of the orbits
          od;
          PrintNumber( Length( F.stabil ) ); # no. of generators for stabilizer
          for j in F.stabil do
            PrintNumber( j );                # generators for stabilizer
          od;
        fi;
      od;

      # `30160' galconjinfo of classes:
      Pr( "y160" );
      for i in tbl.galconjinfo do PrintNumber( i ); od;

      # `30170' power maps
      Pr( "y170" );
      for i in Flat( tbl.30170 ) do PrintNumber( i ); od;

      # `30210' tensor product information
      Pr( "y210" );
      for i in Flat( tbl.tensinfo ) do PrintNumber( i ); od;

      # `30220' inverse map (to compute complex conjugate characters)
      Pr( "y220" );
      for i in Flat( tbl.invmap ) do PrintNumber( i ); od;

      # `30230' power map (field embeddings for $p$-th symmetrizations,
      # where $p$ is a prime not larger than the maximal element order);
      # note that the necessary power maps must be stored on `tbl'
      Pr( "y230" );
      for p in [ 1 .. Length( tbl.powerinfo ) - 1 ] do
        if IsBound( tbl.powerinfo[p] ) then
          PrintNumber( p );
          for j in Flat( tbl.powerinfo[p] ) do PrintNumber( j ); od;
          Pr( "y050" );
        fi;
      od;
      # no `30050' at the end!
      p:= Length( tbl.powerinfo );
      PrintNumber( p );
      for j in Flat( tbl.powerinfo[p] ) do PrintNumber( j ); od;

      # `30310' number of p-blocks
      if IsBound( tbl.30310 ) then
        Pr( "y310" );
        PrintNumber( tbl.30310 );
      fi;

      # `30320' defect, number of ordinary and modular characters per block
      if IsBound( tbl.30320 ) then
        Pr( "y320" );
        for i in tbl.30320 do
          PrintNumber( i[1] );
          PrintNumber( i[2] );
          PrintNumber( i[3] );
          Pr( "y050" );
        od;
      fi;

      # `30350' relative numbers of ordinary characters per block
      if IsBound( tbl.30350 ) then
        Pr( "y350" );
        for i in tbl.30350 do
          for j in i do PrintNumber( j ); od;
          Pr( "y050" );
        od;
      fi;

      # `30360' distribution of basic set characters to blocks:
      #         relative numbers in the basic set
      if IsBound( tbl.30360 ) then
        Pr( "y360" );
        for i in tbl.30360 do
          for j in i do PrintNumber( j ); od;
          Pr( "y050" );
        od;
      fi;

      # `30370' relative numbers of basic set characters (blockwise)
      if IsBound( tbl.30370 ) then
        Pr( "y370" );
        for i in tbl.30370 do
          for j in i do PrintNumber( j ); od;
          Pr( "y050" );
        od;
      fi;

      # `30500' matrices of scalar products of Brauer characters with PS
      #         (per block)
      if IsBound( tbl.30500 ) then
        Pr( "y700" );
        for i in tbl.30700 do
          for j in Concatenation( i ) do PrintNumber( j ); od;
          Pr( "y050" );
        od;
      fi;

      # `30510' absolute numbers of `30500' characters
      if IsBound( tbl.30510 ) then
        Pr( "y510" );
        for i in tbl.30510 do PrintNumber( i ); od;
      fi;

      # `30550' decomposition of ordinary characters into basic set
      if IsBound( tbl.30550 ) then
        Pr( "y550" );
        for i in Concatenation( tbl.30550 ) do
          PrintNumber( i );
        od;
      fi;

      # `30590' ??
      # `30690' ??

      # `30700' matrices of scalar products of PS with BS (per block)
      if IsBound( tbl.30700 ) then
        Pr( "y700" );
        for i in tbl.30700 do
          for j in Concatenation( i ) do PrintNumber( j ); od;
          Pr( "y050" );
        od;
      fi;

      # `30710'
      if IsBound( tbl.30710 ) then
        Pr( "y710" );
        for i in tbl.30710 do PrintNumber( i ); od;
      fi;

      # `30900' basic set of restricted ordinary irreducibles,
      #         or characters in <chars>
      Pr( "y900" );
      if Length( arg ) = 2 then

        # case `MOCString( <tbl>, <chars> )'
        for chi in arg[2] do
          for i in chi do PrintNumber( i ); od;
        od;

      elif IsBound( tbl.30900 ) then

        # case `MOCString( <tbl> )'
        for i in Concatenation( tbl.30900 ) do PrintNumber( i ); od;

      fi;

      # `31000' end of table
      Pr( "z\n" );

    fi;

    # Return the result.
    return str;
end );


#############################################################################
##
##  3. interface to {\GAP}~3
##


#############################################################################
##
#V  GAP3CharacterTableData
##
##  The pair `[ "group", "UnderlyingGroup" ]' is not contained in the list
##  because {\GAP}~4 expects that together with the group, conjugacy classes
##  are stored compatibly with the ordering of columns in the table;
##  in {\GAP}~3, conjugacy classes were not supported as a part of character
##  tables.
##
InstallValue( GAP3CharacterTableData, [
    [ "automorphisms", "AutomorphismsOfTable" ],
    [ "centralizers", "SizesCentralizers" ],
    [ "classes", "SizesConjugacyClasses" ],
    [ "fusions", "ComputedClassFusions" ],
    [ "fusionsources", "NamesOfFusionSources" ],
    [ "identifier", "Identifier" ],
    [ "irreducibles", "Irr" ],
    [ "name", "Name" ],
    [ "orders", "OrdersClassRepresentatives" ],
    [ "permutation", "ClassPermutation" ],
    [ "powermap", "ComputedPowerMaps" ],
    [ "size", "Size" ],
    [ "text", "InfoText" ],
    ] );


#############################################################################
##
#F  GAP3CharacterTableScan( <string> )
##
InstallGlobalFunction( GAP3CharacterTableScan, function( string )
    local gap3table, gap4table, pair;

    # Remove the substring `\\\n', which may split component names.
    string:= ReplacedString( string, "\\\n", "" );

    # Remove the variable name `CharTableOps', which {\GAP}~4 does not know.
    string:= ReplacedString( string, "CharTableOps", "0" );

    # Get the {\GAP}~3 record encoded by the string.
    gap3table:= EvalString( string );

    # Fill the {\GAP}~4 record.
    gap4table:= rec( UnderlyingCharacteristic:= 0 );
    for pair in GAP3CharacterTableData do
      if IsBound( gap3table.( pair[1] ) ) then
        gap4table.( pair[2] ):= gap3table.( pair[1] );
      fi;
    od;

    return ConvertToCharacterTable( gap4table );
    end );


#############################################################################
##
#F  GAP3CharacterTableString( <tbl> )
##
InstallGlobalFunction( GAP3CharacterTableString, function( tbl )
    local str, pair, val;

    str:= "rec(\n";
    for pair in GAP3CharacterTableData do
      if Tester( ValueGlobal( pair[2] ) )( tbl ) then
        val:= ValueGlobal( pair[2] )( tbl );
        Append( str, pair[1] );
        Append( str, " := " );
        if pair[1] in [ "name", "text", "identifier" ] then
          Append( str, "\"" );
          Append( str, String( val ) );
          Append( str, "\"" );
        elif pair[1] = "irreducibles" then
          Append( str, "[\n" );
          Append( str, JoinStringsWithSeparator(
              List( val, chi -> String( ValuesOfClassFunction( chi ) ) ),
              ",\n" ) );
          Append( str, "\n]" );
        elif pair[1] = "automorphisms" then
          # There is no `String' method for groups.
          Append( str, "Group( " );
          Append( str, String( GeneratorsOfGroup( val ) ) );
          Append( str, ", () )" );
        else
#T what about "cliffordTable"?
#T (special function `PrintCliffordTable' in GAP 3)
          Append( str, String( val ) );
        fi;
        Append( str, ",\n" );
      fi;
    od;
    Append( str, "operations := CharTableOps )\n" );

    return str;
    end );


#############################################################################
##
##  4. interface to the Cambridge format
##


#############################################################################
##
#F  CambridgeMaps( <tbl> )
##
InstallGlobalFunction( CambridgeMaps, function( tbl )
    local orders,      # representative orders of `tbl'
          classnames,  # (relative) class names in {\ATLAS} format
          letters,     # non-order parts of `classnames'
          galois,      # info about algebraic conjugacy
          inverse,     # positions of inverse classes
          power,       # {\ATLAS} line for the power map
          prime,       # {\ATLAS} line for the p' parts
          i,           # loop variable
          family,      # one family of algebraic conjugates
          j,           # loop variable
          aut,         # one relative class name
          div,         # help variable for p' parts
          gcd,         # help variable for p' parts
          po;          # help variable for p' parts

    # Compute the list of class names in {\ATLAS} format.
    # Note that the relative names for non-leading classes in a family of
    # algebraically conjugate classes are chosen only if the classes of the
    # family are consecutive.
    orders:= OrdersClassRepresentatives( tbl );
    classnames:= ShallowCopy( ClassNames( tbl, "ATLAS" ) );
    letters:= List( classnames,
        x -> x{ [ PositionProperty( x, IsAlphaChar ) .. Length( x ) ] } );
    galois:= GaloisMat( TransposedMat( Irr( tbl ) ) ).galoisfams;
    inverse:= InverseClasses( tbl );
    power:= [""];
    prime:= [""];
    for i in [ 2 .. Length( galois ) ] do

      # 1. Adjust class names for consecutive families of alg. conjugates.
      if IsList( galois[i] ) then
        family:= galois[i][1];
        if family = [ family[1] .. family[ Length( family ) ] ] then
          for j in [ 2 .. Length( galois[i][1] ) ] do
            aut:= galois[i][2][j] mod orders[i];
            if galois[i][1][j] = inverse[i] then
              aut:= "*";                            # `**'
            elif Length( galois[i][1] ) = 2 then
              aut:= "";                             # `*'
            elif 2 * aut > orders[i] then
              aut:= String( orders[i] - aut );      # `**k' or `*k'(if real)
              if inverse[i] <> i then
                aut:= Concatenation( "*", aut );  # not real
              fi;
            else
              aut:= String( aut );                  # `*k'
            fi;
            classnames[ galois[i][1][j] ]:=
               Concatenation( letters[ galois[i][1][j] ], "*", aut );
          od;
        fi;
      fi;

      # 2. Deal with the lines for power maps and p' part.
      power[i]:= "";
      prime[i]:= "";
      for j in Set( Factors( orders[i] ) ) do

        div:= orders[i];
        while div mod j = 0 do
          div:= div / j;
        od;
        gcd:= Gcdex( div, orders[i] / div );
        po:= orders[i] / div * gcd.coeff2;
        if po <= 0 then
          po:= po + orders[i];
        fi;

        Append( power[i], letters[ PowerMap( tbl, j, i ) ] );
        Append( prime[i], letters[ PowerMap( tbl, po, i ) ] );

      od;

    od;

    # Return the result.
    return rec( power := power,
                prime := prime,
                names := classnames );
end );


#############################################################################
##
#E

