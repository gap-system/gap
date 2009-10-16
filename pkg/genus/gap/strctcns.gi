#############################################################################
##
#W  strctcns.gi            GAP 4 package `genus'                Thomas Breuer
##
#H  @(#)$Id: strctcns.gi,v 1.3 2001/09/21 16:16:31 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.( "genus/gap/strctcns_gi" ) :=
    "@(#)$Id: strctcns.gi,v 1.3 2001/09/21 16:16:31 gap Exp $";


#############################################################################
##
#F  CardinalityOfHom( <L>, <g>, <tbl> )
##
InstallGlobalFunction( CardinalityOfHom, function( L, g, tbl )
    local r,    # length of `L'
          i,    # loop over `L'
          exp,  # `2 - 2*g - r'
          cls;  # class lengths of `tbl'

    r:= Length( L );

    # Replace numbers by lists if necessary.
    L:= ShallowCopy( L );
    for i in [ 1 .. r ] do
      if IsInt( L[i] ) then
        L[i]:= [ L[i] ];
      fi;
    od;

    # Compute the exponent for the character degrees.
    exp:= 2 - 2*g - r;
    cls:= SizesConjugacyClasses( tbl );

    # Sum over the irreducible characters.
    return Size( tbl )^( 2*g - 1 )
           * Sum( Irr( tbl ), chi -> chi[1]^exp
                            * Product( L, Li -> chi{ Li } * cls{ Li } ), 0 );
    end );


#############################################################################
##
#F  SigmaBar( <tbl>, <classes> )
##
InstallGlobalFunction( SigmaBar, function( tbl, classes )
    return CardinalityOfHom( classes, 0, tbl );
    end );


#############################################################################
##
#F  NormalizedStructureConstant( <tbl>, <list> )
##
InstallGlobalFunction( NormalizedStructureConstant, function( tbl, list )
    return CardinalityOfHom( list, 0, tbl )
           * Length( ClassPositionsOfCentre( tbl ) ) / Size( tbl );
    end );


#############################################################################
##
#F  NongenerationByScottCriterion( <tbl>, <C> )
#F  NongenerationByScottCriterion( <tbl>, <chi>, <C> )
#F  NongenerationByScottCriterion( <chi>, <C> )
##
InstallGlobalFunction( NongenerationByScottCriterion, function( arg )
    local tbl,
          characters,
          C,
          classes,
          chi,
          degree,
          dim,
          i;

    # Get and check the arguments.
    if   Length( arg ) = 3 and IsCharacterTable( arg[1] )
                           and IsList( arg[2] ) and IsList( arg[3] ) then
      tbl:= arg[1];
      characters:= [ ValuesOfClassFunction( arg[2] ) ];
      C:= arg[3];
    elif Length( arg ) = 2 and IsCharacterTable( arg[1] )
                           and IsList( arg[2] ) then
      tbl:= arg[1];
      characters:= List( Irr( tbl ), ValuesOfClassFunction );
      C:= arg[2];
    elif Length( arg ) = 2 and IsClassFunction( arg[1] )
                           and IsList( arg[2] ) then
      tbl:= UnderlyingCharacterTable( arg[1] );
      characters:= [ ValuesOfClassFunction( arg[1] ) ];
      C:= arg[2];
    else
      Error( "usage: NongenerationByScottCriterion( <tbl>[, <chi>], <C> )" );
    fi;
    if not ForAll( C, IsPosInt ) then
      Error( "the entries of <C> must be class positions" );
    fi;

    classes:= SizesConjugacyClasses( tbl );

    for chi in characters do
      degree:= chi[1];
      if IsOrdinaryTable( tbl ) then
        dim:= 2 * ( degree - ( chi * classes ) / Size( tbl ) );
      elif ForAll( chi, x -> x = 1 ) then
        dim:= 0;
      else
#T assume that the character has no trivial constituent!
        dim:= 2 * degree;
      fi;
      for i in C do
        dim:= dim - degree + DimensionFixedSpace( tbl, chi, i ); 
      od;
      if 0 < dim then
        return true;
      fi;
    od;

    return false;
end );


#############################################################################
##
#F  EichlerCharacter( <tbl>, <g0>, <classes> )
##
InstallGlobalFunction( EichlerCharacter, function( tbl, g0, classes )
    local powermap,
          orders,
          centralizers,
          realclasses,
          nccl,
          i,
          numbers,
          FixG,
          normalizers,
          galorblen,
          Fix,
          ord,
          u,
          divs,
          d,
          pow,
          v,
          g,
          size,
          chi,
          val,
          cyc;

    # Compute the coprime power maps.
    powermap:= ComputedPowerMaps( tbl );
    orders:= OrdersClassRepresentatives( tbl );
    centralizers:= SizesCentralizers( tbl );
    for i in [ 2 .. Maximum( orders ) ] do
      if not IsBound( powermap[i] ) then
        powermap[i]:= PowerMap( tbl, i );
      fi;
    od;

    realclasses:= RealClasses( tbl );
    nccl:= NrConjugacyClasses( tbl );

    # Compute $Fix_{X,u}^G(.)$.
    numbers:= ListWithIdenticalEntries( nccl, 0 );
    for i in classes do
      numbers[i]:= numbers[i] + 1;
    od;
    FixG:= List( [ 1 .. nccl ], i -> 0 * [ 1 .. orders[i] ] );

    for i in [ 1 .. nccl ] do
      if numbers[i] <> 0 then

        # $Fix_{X,1}^G(.)$.
        FixG[i][1]:= centralizers[i] / orders[i] * numbers[i];

        # $Fix_{X,u}^G( \sigma^u ) = Fix_{X,1}^G( \sigma )$.
        ord:= orders[i];
        for u in [ 2 .. ord-1 ] do
          if Gcd( u, ord ) = 1 then
            FixG[ powermap[u][i] ][u]:= FixG[i][1];
          fi;
        od;

      fi;
    od;

    # Compute the normalizer orders of cyclic subgroups.
    normalizers:= [];
    for i in [ 2 .. nccl ] do
      normalizers[i]:= centralizers[i]
          * Phi( orders[i] ) / Length( ClassOrbit( tbl, i ) );
    od;
    galorblen:= [];
    for i in [ 2 .. nccl ] do
      galorblen[i]:= Length( ClassOrbit( tbl, i ) );
    od;
#T !!

    # Compute $Fix_{X,u}(.)$.
    Fix:= List( FixG, ShallowCopy );
    for i in [ 2 .. nccl ] do
      divs:= DivisorsInt( orders[i] );
      for d in [ 2 .. Length( divs ) - 1 ] do

        # Add the fixed points with stabilizer generated by an element
        # in class 'i' to the fixed points of the element in the 'd'-th
        # power of class 'i'.
        pow:= PowerMap( tbl, divs[d], i );
        for u in PrimeResidues( orders[i] / divs[d] ) do
          for v in [ 1 .. orders[i] ] do
            if ( v - u ) mod orders[ pow ] = 0
               and Gcd( v, orders[i] ) = 1 then
              Fix[ pow ][u]:= Fix[ pow ][u]
                  + normalizers[ pow ] / normalizers[i] * FixG[i][v]
                     * galorblen[ pow ] / galorblen[i];
#T !!
            fi;
          od;
        od;

      od;
    od;

    # Compute the character degree $g = 1 + |G| ( g_0 - 1 )
    #     + \frac{|G|}{2} \sum_{j=1}^r \left( 1 - \frac{1}{m_j} \right)$.
    g:= 0;
    size:= Size( tbl );
    for i in classes do
      g:= g + size - size / orders[i];
    od;
    g:= 1 + size * ( g0 - 1 ) + g / 2;

    # Compute the values of the character.
    chi:= [ g ];
    for i in [ 2 .. nccl ] do
      if i in realclasses then
        chi[i]:= 1 - Sum( Compacted( Fix[i] ) ) / 2;
      else
        val:= 1;
        if ForAny( Fix[i], x -> x <> 0 ) then
          ord:= orders[i];
          cyc:= E( ord ) / ( 1 - E( ord ) );
          for u in [ 1 .. ord ] do
            if Gcd( u, ord ) = 1 then
              val:= val + Fix[i][u] * GaloisCyc( cyc, u );
            fi;
          od;
        fi;
        chi[i]:= val;
      fi;
    od;

    # Return the character.
    return ClassFunction( tbl, chi );
end );


#############################################################################
##
#E

