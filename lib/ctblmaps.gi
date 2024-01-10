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
##  This file contains those functions that are used to construct maps,
##  (mostly fusion maps and power maps).
##
##  1. Maps Concerning Character Tables
##  2. Power Maps
##  3. Class Fusions between Character Tables
##  4. Utilities for Parametrized Maps
##  5. Subroutines for the Construction of Power Maps
##  6. Subroutines for the Construction of Class Fusions
##

#T UpdateMap: assertions for returned `true' in the library occurrences


#############################################################################
##
##  2. Power Maps
##


#############################################################################
##
#M  PowerMap( <tbl>, <n> )  . . . . . . . . . for character table and integer
#M  PowerMap( <tbl>, <n>, <class> )
##
InstallMethod( PowerMap,
    "for a character table, and an integer",
    [ IsNearlyCharacterTable, IsInt ],
    function( tbl, n )
    local known, erg,i,e,ord,a,p;

    ord:=OrdersClassRepresentatives(tbl);

    if IsPosInt( n ) and IsSmallIntRep( n ) then
      known:= ComputedPowerMaps( tbl );

      # compute the <n>-th power map
      if not IsBound( known[n] ) then
        if ForAll(Filtered([1..n-1],IsPrimeInt),x->IsBound(known[x])) then
          # do not exceed element order, we can fill these out easier
          erg:= PowerMapOp( tbl, n:onlyuptoorder );
          for i in [1..Length(erg)] do
            if erg[i]=0 then
              e:=n mod ord[i];
              a:=i;
              while e>1 do
                p:=SmallestPrimeDivisor(e);
                e:=e/p;
                a:=known[p][a];
              od;
              erg[i]:=a;
            fi;

          od;
        else
          erg:= PowerMapOp( tbl, n );
        fi;
        known[n]:= MakeImmutable( erg );
      fi;

      # return the <p>-th power map
      return known[n];
    else
      return PowerMapOp( tbl, n );
    fi;
    end );

InstallMethod( PowerMap,
    "for a character table, and two integers",
    [ IsNearlyCharacterTable, IsInt, IsInt ],
    function( tbl, n, class )
    local known;

    if IsPosInt( n ) and IsSmallIntRep( n ) then
      known:= ComputedPowerMaps( tbl );
      if IsBound( known[n] ) then
        return known[n][ class ];
      fi;
    fi;
    return PowerMapOp( tbl, n, class );
    end );


#############################################################################
##
#M  PowerMapOp( <ordtbl>, <n> ) . . . . . .  for ord. table, and pos. integer
##
InstallMethod( PowerMapOp,
    "for ordinary table with group, and positive integer",
    [ IsOrdinaryTable and HasUnderlyingGroup, IsPosInt ],
    function( tbl, n )
    local G, map, p;

    if n = 1 then

      map:= [ 1 .. NrConjugacyClasses( tbl ) ];

    elif IsPrimeInt( n ) then

      G:= UnderlyingGroup( tbl );
      map:= PowerMapOfGroup( G, n, ConjugacyClasses( tbl ) );

    else

      map:= [ 1 .. NrConjugacyClasses( tbl ) ];
      for p in Factors( n ) do
        map:= map{ PowerMap( tbl, p ) };
      od;

    fi;
    return map;
    end );


#############################################################################
##
#M  PowerMapOp( <ordtbl>, <n> ) . . . . . .  for ord. table, and pos. integer
##
InstallMethod( PowerMapOp,
    "for ordinary table, and positive integer",
    [ IsOrdinaryTable, IsPosInt ],
    function( tbl, n )
    local i, powermap, nth_powermap, pmap;

    nth_powermap:= [ 1 .. NrConjugacyClasses( tbl ) ];
    if n = 1 then
      return nth_powermap;
    elif HasUnderlyingGroup( tbl ) then
      TryNextMethod();
    fi;

    powermap:= ComputedPowerMaps( tbl );

    for i in Factors( n ) do
      if IsSmallIntRep( i ) and IsBound( powermap[i] ) then
        nth_powermap:= nth_powermap{ powermap[i] };
      else

        # Compute the missing power map.
        pmap:= PossiblePowerMaps( tbl, i, rec( quick := true ) );
        if Length( pmap ) <> 1 then
          return fail;
        elif IsSmallIntRep( i ) then
          powermap[i]:= MakeImmutable( pmap[1] );
        fi;
        nth_powermap:= nth_powermap{ pmap[1] };
      fi;
    od;

    # Return the map;
    return nth_powermap;
    end );


#############################################################################
##
#M  PowerMapOp( <ordtbl>, <n>, <class> )
##
InstallOtherMethod( PowerMapOp,
    "for ordinary table, integer, positive integer",
    [ IsOrdinaryTable, IsInt, IsPosInt ],
    function( tbl, n, class )
    local i, powermap, image;

    powermap:= ComputedPowerMaps( tbl );
    if n = 1 then
      return class;
    elif 0 < n and IsSmallIntRep( n ) and IsBound( powermap[n] ) then
      return powermap[n][ class ];
    fi;

    n:= n mod OrdersClassRepresentatives( tbl )[ class ];
    if n = 0 then
      return 1;
    elif n = 1 then
      return class;
    elif IsSmallIntRep( n ) and IsBound( powermap[n] ) then
      return powermap[n][ class ];
    fi;

    image:= class;
    for i in Factors(Integers, n ) do
      # Here we use that `i' is a small integer.
      if not IsBound( powermap[i] ) then

        # Compute the missing power map.
        powermap[i]:= MakeImmutable( PowerMap( tbl, i ) );
#T if the group is available, better ask it directly?
#T (careful: No maps are stored by the three-argument call,
#T this may slow down the computation if many calls are done ...)

      fi;
      image:= powermap[i][ image ];
    od;
    return image;
    end );


#############################################################################
##
#M  PowerMapOp( <tbl>, <n> )
##
InstallMethod( PowerMapOp,
    "for character table and negative integer",
    [ IsCharacterTable, IsInt and IsNegRat ],
    function( tbl, n )
    return PowerMap( tbl, -n ){ InverseClasses( tbl ) };
    end );


#############################################################################
##
#M  PowerMapOp( <tbl>, <zero> )
##
InstallMethod( PowerMapOp,
    "for character table and zero",
    [ IsCharacterTable, IsZeroCyc ],
    function( tbl, zero )
    return ListWithIdenticalEntries( NrConjugacyClasses( tbl ), 1 );
    end );


#############################################################################
##
#M  PowerMapOp( <modtbl>, <n> )
##
InstallMethod( PowerMapOp,
    "for Brauer table and integer",
    [ IsBrauerTable, IsInt ],
    function( tbl, n )
    local fus, ordtbl;

    ordtbl:= OrdinaryCharacterTable( tbl );
    fus:= GetFusionMap( tbl, ordtbl );
    return InverseMap( fus ){ PowerMap( ordtbl, n ){ fus } };
    end );


#############################################################################
##
#M  PowerMapOp( <modtbl>, <n>, <class> )
##
InstallOtherMethod( PowerMapOp,
    "for Brauer table, integer, positive integer",
    [ IsBrauerTable, IsInt, IsPosInt ],
    function( tbl, n, class )
    local fus, ordtbl;

    if 0 < n and IsBound( ComputedPowerMaps( tbl )[n] ) then
      return ComputedPowerMaps( tbl )[n][ class ];
    fi;
    ordtbl:= OrdinaryCharacterTable( tbl );
    fus:= GetFusionMap( tbl, ordtbl );
    return Position( fus, PowerMap( ordtbl, n, fus[ class ] ) );
    end );


#############################################################################
##
#M  ComputedPowerMaps( <tbl> )  . . . . . . . .  for a nearly character table
##
InstallMethod( ComputedPowerMaps,
    "for a nearly character table",
    [ IsNearlyCharacterTable ],
    tbl -> [] );


#############################################################################
##
#M  PossiblePowerMaps( <ordtbl>, <prime> )
##
InstallMethod( PossiblePowerMaps,
    "for an ordinary character table and a prime (add empty options record)",
    [ IsOrdinaryTable, IsPosInt ],
    function( ordtbl, prime )
    return PossiblePowerMaps( ordtbl, prime, rec() );
    end );


#############################################################################
##
#M  PossiblePowerMaps( <ordtbl>, <prime>, <parameters> )
##
InstallMethod( PossiblePowerMaps,
    "for an ordinary character table, a prime, and a record",
    [ IsOrdinaryTable, IsPosInt, IsRecord ],
    function( ordtbl, prime, arec )
    local chars,          # list of characters to be used
          decompose,      # boolean: is decomposition of characters allowed?
          useorders,      # boolean: use element orders information?
          approxpowermap, # known approximation of the power map
          quick,          # boolean: immediately return if the map is unique?
          maxamb,         # entry in parameters record
          minamb,         # entry in parameters record
          maxlen,         # entry in parameters record
          powermap,       # parametrized map of possibilities
          ok,             # intermediate result of `MeetMaps'
          poss,           # list of possible maps
          rat,            # rationalized characters
          pow;            # loop over possibilities found up to now

    # Check the arguments.
    if not IsPrimeInt( prime ) then
      Error( "<prime> must be a prime" );
    fi;

    # Evaluate the parameters.
    if IsBound( arec.chars ) then
      chars:= arec.chars;
      decompose:= false;
    elif HasIrr( ordtbl ) then
      chars:= Irr( ordtbl );
      decompose:= true;
    else
      chars:= [];
      decompose:= false;
    fi;

    # Override `decompose' if it is explicitly set.
    if IsBound( arec.decompose ) then
      decompose:= arec.decompose;
    fi;

    if IsBound( arec.useorders ) then
      useorders:= arec.useorders;
    else
      useorders:= true;
    fi;

    if IsBound( arec.powermap ) then
      approxpowermap:= arec.powermap;
    else
      approxpowermap:= [];
    fi;

    quick:= IsBound( arec.quick ) and ( arec.quick = true );

    if IsBound( arec.parameters ) then
      maxamb:= arec.parameters.maxamb;
      minamb:= arec.parameters.minamb;
      maxlen:= arec.parameters.maxlen;
    else
      maxamb:= 100000;
      minamb:= 10000;
      maxlen:= 10;
    fi;

    # Initialize the parametrized map.
    powermap:= InitPowerMap( ordtbl, prime, useorders );
    if powermap = fail then
      Info( InfoCharacterTable, 2,
            "PossiblePowerMaps: no initialization possible" );
      return [];
    fi;

    # Use the known approximation `approxpowermap',
    # and check the other local conditions.
    ok:= MeetMaps( powermap, approxpowermap );
    if   ok <> true then
      Info( InfoCharacterTable, 2,
            "PossiblePowerMaps: incompatibility with ",
                      "<approxpowermap> at class ", ok );
      return [];
    elif not Congruences( ordtbl, chars, powermap, prime, quick ) then
      Info( InfoCharacterTable, 2,
            "PossiblePowerMaps: errors in Congruences" );
      return [];
    elif not ConsiderKernels( ordtbl, chars, powermap, prime, quick ) then
      Info( InfoCharacterTable, 2,
            "PossiblePowerMaps: errors in ConsiderKernels" );
      return [];
    elif not ConsiderSmallerPowerMaps( ordtbl, powermap, prime, quick ) then
      Info( InfoCharacterTable, 2,
            "PossiblePowerMaps: errors in ConsiderSmallerPowerMaps" );
      return [];
    fi;

    Info( InfoCharacterTable, 2,
          "PossiblePowerMaps: ", Ordinal( prime ),
          " power map initialized; congruences, kernels and\n",
          "#I    maps for smaller primes considered,\n",
          "#I    ", IndeterminatenessInfo( powermap ) );
    if quick then
      Info( InfoCharacterTable, 2,
            "  (\"quick\" option specified)" );
    fi;

    if quick and ForAll( powermap, IsInt ) then
      return [ powermap ];
    fi;

    # Now use restricted characters.
    # If decomposition of characters is allowed then
    # use decompositions of minus-characters of `chars' into `chars'.

    if decompose then

      if Indeterminateness( powermap ) < minamb then

        Info( InfoCharacterTable, 2,
              "PossiblePowerMaps: indeterminateness too small for test",
              " of decomposability" );
        poss:= [ powermap ];

      else

        Info( InfoCharacterTable, 2,
              "PossiblePowerMaps: now test decomposability of rational ",
              "minus-characters" );
        rat:= RationalizedMat( chars );

        poss:= PowerMapsAllowedBySymmetrizations( ordtbl, rat, rat, powermap,
                             prime, rec( maxlen    := maxlen,
                                         contained := ContainedCharacters,
                                         minamb    := minamb,
                                         maxamb    := infinity,
                                         quick     := quick ) );

        Info( InfoCharacterTable, 2,
              "PossiblePowerMaps: decomposability tested,\n",
              "#I    ", Length( poss ),
              " solution(s) with indeterminateness\n",
              List( poss, Indeterminateness ) );

        if quick and Length( poss ) = 1 and ForAll( poss[1], IsInt ) then
          return [ poss[1] ];
        fi;

      fi;

    else

      Info( InfoCharacterTable, 2,
            "PossiblePowerMaps: no test of decomposability allowed" );
      poss:= [ powermap ];

    fi;

    # Check the scalar products of minus-characters of `chars' with `chars'.
    Info( InfoCharacterTable, 2,
          "PossiblePowerMaps: test scalar products",
          " of minus-characters" );

    powermap:= [];
    for pow in poss do
      Append( powermap,
              PowerMapsAllowedBySymmetrizations( ordtbl, chars, chars, pow,
                       prime, rec( maxlen:= maxlen,
                                   contained:= ContainedPossibleCharacters,
                                   minamb:= 1,
                                   maxamb:= maxamb,
                                   quick:= quick ) ) );
    od;

    # Give a final message about the result.
    if 2 <= InfoLevel( InfoCharacterTable ) then
      if ForAny( powermap, x -> ForAny( x, IsList ) ) then
        Info( InfoCharacterTable, 2,
              "PossiblePowerMaps: ", Length(powermap),
              " parametrized solution(s),\n",
              "#I    no further improvement was possible with given",
              " characters\n",
              "#I    and maximal checked ambiguity of ", maxamb );
      else
        Info( InfoCharacterTable, 2,
              "PossiblePowerMaps: ", Length( powermap ), " solution(s)" );
      fi;
    fi;

    # Return the result.
    return powermap;
    end );


#############################################################################
##
#M  PossiblePowerMaps( <modtbl>, <prime> )
##
InstallOtherMethod( PossiblePowerMaps,
    "for a Brauer character table and a prime",
    [ IsBrauerTable, IsPosInt ],
    function( modtbl, prime )
    local ordtbl, poss, fus, inv;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    if IsBound( ComputedPowerMaps( ordtbl )[ prime ] ) then
      poss:= [ ComputedPowerMaps( ordtbl )[ prime ] ];
    else
      poss:= PossiblePowerMaps( ordtbl, prime, rec() );
    fi;
    fus:= GetFusionMap( modtbl, ordtbl );
    inv:= InverseMap( fus );
    return Set( poss,
             x -> CompositionMaps( inv, CompositionMaps( x, fus ) ) );
    end );


#############################################################################
##
#M  PossiblePowerMaps( <modtbl>, <prime>, <parameters> )
##
InstallMethod( PossiblePowerMaps,
    "for a Brauer character table, a prime, and a record",
    [ IsBrauerTable, IsPosInt, IsRecord ],
    function( modtbl, prime, arec )
    local ordtbl, poss, fus, inv, quick, decompose;
    ordtbl:= OrdinaryCharacterTable( modtbl );
    if IsBound( ComputedPowerMaps( ordtbl )[ prime ] ) then
      poss:= [ ComputedPowerMaps( ordtbl )[ prime ] ];
    else
      quick:= IsBound( arec.quick ) and ( arec.quick = true );
      decompose:= IsBound( arec.decompose ) and ( arec.decompose = true );
      if IsBound( arec.parameters ) then
        poss:= PossiblePowerMaps( ordtbl, prime,
               rec( quick      := quick,
                    decompose  := decompose,
                    parameters := rec( maxamb:= arec.parameters.maxamb,
                                       minamb:= arec.parameters.minamb,
                                       maxlen:= arec.parameters.maxlen ) ) );
      else
        poss:= PossiblePowerMaps( ordtbl, prime,
               rec( quick      := quick,
                    decompose  := decompose ) );
      fi;
    fi;
    fus:= GetFusionMap( modtbl, ordtbl );
    inv:= InverseMap( fus );
    return Set( poss,
             x -> CompositionMaps( inv, CompositionMaps( x, fus ) ) );
    end );


#############################################################################
##
#F  ElementOrdersPowerMap( <powermap> )
##
InstallGlobalFunction( ElementOrdersPowerMap, function( powermap )
    local i, primes, elementorders, nccl, bound, newbound, map, pos;

    if IsEmpty( powermap ) then
      Error( "<powermap> must be nonempty" );
    fi;

    primes:= Filtered( [ 1 .. Length( powermap ) ],
                       x -> IsBound( powermap[x] ) );
    nccl:= Length( powermap[ primes[1] ] );

    if 2 <= InfoLevel( InfoCharacterTable ) then
      for i in primes do
        if ForAny( powermap[i], IsList ) then
          Print( "#I  ElementOrdersPowerMap: ", Ordinal( i ),
                 " power map not unique at classes\n",
                 "#I  ", Filtered( [ 1 .. nccl ],
                                  x -> IsList( powermap[i][x] ) ),
                 " (ignoring these entries)\n" );
        fi;
      od;
    fi;

    elementorders:= [ 1 ];
    bound:= [ 1 ];

    while bound <> [] do
      newbound:= [];
      for i in primes do
        map:= powermap[i];
        for pos in [ 1 .. nccl ] do
          if IsInt( map[ pos ] ) and map[ pos ] in bound
             and IsBound( elementorders[ map[ pos ] ] )
             and not IsBound( elementorders[ pos ] ) then
            elementorders[ pos ]:= i * elementorders[ map[ pos ] ];
            AddSet( newbound, pos );
          fi;
        od;
      od;
      bound:= newbound;
    od;
    for i in [ 1 .. nccl ] do
      if not IsBound( elementorders[i] ) then
        elementorders[i]:= Unknown();
      fi;
    od;
    if     2 <= InfoLevel( InfoCharacterTable )
       and ForAny( elementorders, IsUnknown ) then
      Print( "#I  ElementOrdersPowerMap: element orders not determined for",
             " classes in\n",
             "#I  ", Filtered( [ 1 .. nccl ],
                              x -> IsUnknown( elementorders[x] ) ), "\n" );
    fi;
    return elementorders;
end );


#############################################################################
##
#F  PowerMapByComposition( <tbl>, <n> ) . .  for char. table and pos. integer
##
InstallGlobalFunction( PowerMapByComposition, function( tbl, n )

    local powermap, nth_powermap, i;

    if not IsInt( n ) then
      Error( "<n> must be an integer" );
    fi;
    powermap:= ComputedPowerMaps( tbl );

    if IsPosInt( n ) then
      nth_powermap:= [ 1 .. NrConjugacyClasses( tbl ) ];
    else
      nth_powermap:= InverseClasses( tbl );
      n:= -n;
    fi;

    for i in Factors( n ) do
      if not IsBound( powermap[i] ) then
        return fail;
      fi;
      nth_powermap:= nth_powermap{ powermap[i] };
    od;

    # Return the map;
    return nth_powermap;
end );


#############################################################################
##
#F  OrbitPowerMaps( <powermap>, <matautomorphisms> )
##
InstallGlobalFunction( OrbitPowerMaps, function( powermap, matautomorphisms )

    local nccl, orb, gen, image;

    nccl:= Length( powermap );
    orb:= [ powermap ];
    for powermap in orb do
      for gen in GeneratorsOfGroup( matautomorphisms ) do
        image:= List( [ 1 .. nccl ], x -> powermap[ x^gen ] / gen );
        if not image in orb then Add( orb, image ); fi;
      od;
    od;
    return orb;
end );


#############################################################################
##
#F  RepresentativesPowerMaps( <listofpowermaps>, <matautomorphisms> )
##
##  returns a list of representatives of powermaps in the list
##  <listofpowermaps> under the action of the maximal admissible subgroup
##  of the matrix automorphisms <matautomorphisms> of the considered
##  character matrix.
##  The matrix automorphisms must be a permutation group.
##
InstallGlobalFunction( RepresentativesPowerMaps,
    function( listofpowermaps, matautomorphisms )

    local nccl, stable, gens, orbits, orbit;

    if IsEmpty( listofpowermaps ) then
      return [];
    fi;
    listofpowermaps:= Set( listofpowermaps );

    # Find the subgroup of the table automorphism group that acts on
    # <listofpowermaps>.

    nccl:= Length( listofpowermaps[1] );
    gens:= GeneratorsOfGroup( matautomorphisms );
    stable:= Filtered( gens,
              x -> ForAll( listofpowermaps,
              y -> List( [ 1..nccl ], z -> y[z^x]/x ) in listofpowermaps ) );
    if stable <> gens then
      Info( InfoCharacterTable, 2,
            "RepresentativesPowerMaps: Not all table automorphisms\n",
            "#I    do act; computing the admissible subgroup." );
      matautomorphisms:= SubgroupProperty( matautomorphisms,
          ( x -> ForAll( listofpowermaps,
              y -> List( [ 1..nccl ], z -> y[z^x]/x ) in listofpowermaps ) ),
              GroupByGenerators( stable, () ) );
    fi;

    # Distribute the maps to orbits.

    orbits:= [];
    while not IsEmpty( listofpowermaps ) do
      orbit:= OrbitPowerMaps( listofpowermaps[1], matautomorphisms );
      Add( orbits, orbit );
      SubtractSet( listofpowermaps, orbit );
    od;

    Info( InfoCharacterTable, 2,
          "RepresentativesPowerMaps: ", Length( orbits ),
          " orbit(s) of length(s) ", List( orbits, Length ) );

    # Choose representatives, and return them.
    return List( orbits, x -> x[1] );
end );


#############################################################################
##
##  3. Class Fusions between Character Tables
##


#############################################################################
##
#M  FusionConjugacyClasses( <tbl1>, <tbl2> )  . . . . .  for character tables
#M  FusionConjugacyClasses( <H>, <G> )  . . . . . . . . . . . . .  for groups
#M  FusionConjugacyClasses( <hom> ) . . . . . . . .  for a group homomorphism
#M  FusionConjugacyClasses( <hom>, <tbl1>, <tbl2> )  for a group homomorphism
##
##  We do not store class fusions in groups,
##  the groups delegate to their ordinary character tables.
##
InstallMethod( FusionConjugacyClasses,
    "for two groups",
    IsIdenticalObj,
    [ IsGroup, IsGroup ],
    function( H, G )
    local tbl1, tbl2, fus;

    tbl1:= OrdinaryCharacterTable( H );
    tbl2:= OrdinaryCharacterTable( G );
    fus:= FusionConjugacyClasses( tbl1, tbl2 );

    # Redirect the fusion.
    if fus <> fail then
      fus:= IdentificationOfConjugacyClasses( tbl2 ){
                fus{ InverseMap( IdentificationOfConjugacyClasses(
                    tbl1 ) ) } };
    fi;
    return fus;
    end );

InstallMethod( FusionConjugacyClasses,
    "for a group homomorphism",
    [ IsGeneralMapping ],
    FusionConjugacyClassesOp );

InstallMethod( FusionConjugacyClasses,
    "for a group homomorphism, and two nearly character tables",
    [ IsGeneralMapping, IsNearlyCharacterTable, IsNearlyCharacterTable ],
    FusionConjugacyClassesOp );

InstallMethod( FusionConjugacyClasses,
    "for two nearly character tables",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ],
    function( tbl1, tbl2 )
    local fus;

    # Check whether the fusion map is stored already.
    fus:= GetFusionMap( tbl1, tbl2 );

    # If not then call the operation.
    if fus = fail then
      fus:= FusionConjugacyClassesOp( tbl1, tbl2 );
      if fus <> fail then
        StoreFusion( tbl1, fus, tbl2 );
      fi;
    fi;

    # Return the fusion map.
    return fus;
    end );


#############################################################################
##
#M  FusionConjugacyClassesOp( <hom> )
##
InstallMethod( FusionConjugacyClassesOp,
    "for a group homomorphism",
    [ IsGeneralMapping ],
    function( hom )
    local Sclasses, Rclasses, nccl, fusion, i, image, j;

    Sclasses:= ConjugacyClasses( PreImagesRange( hom ) );
    Rclasses:= ConjugacyClasses( ImagesSource( hom ) );
    nccl:= Length( Rclasses );

    fusion:= [];
#T use more invariants/class identification!
    for i in [ 1 .. Length( Sclasses ) ] do
      image:= ImagesRepresentative( hom, Representative( Sclasses[i] ) );
      for j in [ 1 .. nccl ] do
        if image in Rclasses[j] then
          fusion[i]:= j;
          break;
        fi;
      od;
    od;

    if Number( fusion ) <> Length( Sclasses ) then
      Info( InfoCharacterTable, 1,
            "class fusion must be defined for all in `Sclasses'" );
      fusion:= fail;
    fi;

    return fusion;
    end );


#############################################################################
##
#M  FusionConjugacyClassesOp( <hom>, <tbl1>, <tbl2> )
##
InstallMethod( FusionConjugacyClassesOp,
    "for a group homomorphism, and two character tables",
    [ IsGeneralMapping, IsOrdinaryTable, IsOrdinaryTable ],
    function( hom, tbl1, tbl2 )
    local Sclasses, Rclasses, nccl, fusion, i, image, j;

    Sclasses:= ConjugacyClasses( tbl1 );
    Rclasses:= ConjugacyClasses( tbl2 );
    nccl:= Length( Rclasses );

    fusion:= [];
#T use more invariants/class identification!
    for i in [ 1 .. Length( Sclasses ) ] do
      image:= ImagesRepresentative( hom, Representative( Sclasses[i] ) );
      for j in [ 1 .. nccl ] do
        if image in Rclasses[j] then
          fusion[i]:= j;
          break;
        fi;
      od;
    od;

    if Number( fusion ) <> Length( Sclasses ) then
      Info( InfoCharacterTable, 1,
            "class fusion must be defined for all in `Sclasses'" );
      fusion:= fail;
    fi;

    return fusion;
    end );


#############################################################################
##
#M  FusionConjugacyClassesOp( <tbl1>, <tbl2> )
##
InstallMethod( FusionConjugacyClassesOp,
    "for two ordinary tables with groups",
    [ IsOrdinaryTable and HasUnderlyingGroup,
      IsOrdinaryTable and HasUnderlyingGroup ],
    function( tbl1, tbl2 )
    local i, k, t, p,  # loop and help variables
          Sclasses,    # conjugacy classes of S
          Rclasses,    # conjugacy classes of R
          fusion,      # the fusion map
          orders;      # list of orders of representatives

    Sclasses:= ConjugacyClasses( tbl1 );
    Rclasses:= ConjugacyClasses( tbl2 );

    # Check that no factor fusion is tried.
    if FamilyObj( Sclasses ) <> FamilyObj( Rclasses ) then
      Error( "group of <tbl1> must be a subgroup of that of <tbl2>" );
    fi;

    fusion:= [];
    orders:= OrdersClassRepresentatives( tbl2 );
#T use more invariants/class identification!
    for i in [ 1 .. Length( Sclasses ) ] do
      k:= Representative( Sclasses[i] );
      t:= Order( k );
      for p in [ 1 .. Length( orders ) ] do
        if t = orders[p] and k in Rclasses[p] then
          fusion[i]:= p;
          break;
        fi;
      od;
    od;

    if Number( fusion ) <> Length( Sclasses ) then
      Info( InfoCharacterTable, 1,
            "class fusion must be defined for all in `Sclasses'" );
      fusion:= fail;
    fi;

    return fusion;
    end );

InstallMethod( FusionConjugacyClassesOp,
    "for two ordinary tables",
    [ IsOrdinaryTable, IsOrdinaryTable ],
    function( tbl1, tbl2 )
    local fusion;

    if   Size( tbl2 ) < Size( tbl1 ) then

      Error( "cannot compute factor fusion from tables" );
#T (at least try, sometimes it is unique ...)

    elif Size( tbl2 ) = Size( tbl1 ) then

      # find a transforming permutation
      fusion:= TransformingPermutationsCharacterTables( tbl1, tbl2 );
      if   fusion = fail then
        return fail;
      elif 1 < Size( fusion.group ) then
        Info( InfoCharacterTable, 1,
              "fusion is not unique" );
        fusion:= fail;

      fi;
      if fusion.columns = () then
        fusion:= [];
      else
        fusion:= OnTuples( [ 1 .. LargestMovedPoint( fusion.columns ) ],
                           fusion.columns );
      fi;

      Append( fusion,
              [ Length( fusion ) + 1 .. NrConjugacyClasses( tbl1 ) ] );

    else

      # find a subgroup fusion
      fusion:= PossibleClassFusions( tbl1, tbl2 );
      if   IsEmpty( fusion ) then
        return fail;
      elif 1 < Length( fusion ) then

        # If both tables know a group then we may use them.
        if HasUnderlyingGroup( tbl1 ) and HasUnderlyingGroup( tbl2 ) then
          TryNextMethod();
        else
          Info( InfoCharacterTable, 1,
                "fusion is not stored and not uniquely determined" );
          return fail;
        fi;

      fi;
      fusion:= fusion[1];

    fi;

    Assert( 2, Number( fusion ) = NrConjugacyClasses( tbl1 ),
            "fusion must be defined for all positions in `Sclasses'" );

    return fusion;
    end );

InstallMethod( FusionConjugacyClassesOp,
    "for two Brauer tables",
    [ IsBrauerTable, IsBrauerTable ],
    function( tbl1, tbl2 )
    local fus, ord1, ord2;

    ord1:= OrdinaryCharacterTable( tbl1 );
    ord2:= OrdinaryCharacterTable( tbl2 );

    if HasUnderlyingGroup( ord1 ) and HasUnderlyingGroup( ord2 ) then

      # If the tables know their groups then compute the unique fusion.
      fus:= FusionConjugacyClasses( ord1, ord2 );
      if fus = fail then
        return fail;
      else
        return InverseMap( GetFusionMap( tbl2, ord2 ) ){
                   fus{ GetFusionMap( tbl1, ord1 ) } };
      fi;

    else

      # Try to find a unique restriction of the possible class fusions.
      fus:= PossibleClassFusions( ord1, ord2 );
      if IsEmpty( fus ) then
        return fail;
      else

        fus:= Set( fus, map -> InverseMap(
                                         GetFusionMap( tbl2, ord2 ) ){
                                     map{ GetFusionMap( tbl1, ord1 ) } } );
        if 1 < Length( fus ) then
          Info( InfoCharacterTable, 1,
                "fusion is not stored and not uniquely determined" );
          return fail;
        fi;
        return fus[1];

      fi;

    fi;
    end );


#############################################################################
##
#M  ComputedClassFusions( <tbl> )
##
##  We do *not* store class fusions in groups,
##  `FusionConjugacyClasses' must store the fusion if the character tables
##  of both groups are known already.
##
InstallMethod( ComputedClassFusions,
    "for a nearly character table",
    [ IsNearlyCharacterTable ],
    tbl -> [] );


#############################################################################
##
#F  GetFusionMap( <source>, <destin>[, <specification>] )
##
InstallGlobalFunction( GetFusionMap, function( arg )
    local source,
          destin,
          specification,
          name,
          fus,
          ordsource,
          orddestin;

    # Check the arguments.
    if not ( 2 <= Length( arg ) and IsNearlyCharacterTable( arg[1] )
                                and IsNearlyCharacterTable( arg[2] ) ) then
      Error( "first two arguments must be nearly character tables" );
    elif 3 < Length( arg ) then
      Error( "usage: GetFusionMap( <source>, <destin>[, <specification>" );
    fi;

    source := arg[1];
    destin := arg[2];

    if Length( arg ) = 3 then
      specification:= arg[3];
    fi;

    # First check whether `source' knows a fusion to `destin' .
    name:= Identifier( destin );
    for fus in ComputedClassFusions( source ) do
      if fus.name = name then
        if IsBound( specification ) then
          if     IsBound( fus.specification )
             and fus.specification = specification then
            if HasClassPermutation( destin ) then
              return OnTuples( fus.map, ClassPermutation( destin ) );
            else
              return ShallowCopy( fus.map );
            fi;
          fi;
        else
          if IsBound( fus.specification ) then
            Info( InfoCharacterTable, 1,
                  "GetFusionMap: Used fusion has specification ",
                  fus.specification );
          fi;
          if HasClassPermutation( destin ) then
            return OnTuples( fus.map, ClassPermutation( destin ) );
          else
            return ShallowCopy( fus.map );
          fi;
        fi;
      fi;
    od;

    # Now check whether the tables are Brauer tables
    # whose ordinary tables know more.
    # (If `destin' is the ordinary table of `source' then
    # the fusion has been found already.)
    # Note that `specification' makes no sense here.
    if IsBrauerTable( source ) and IsBrauerTable( destin ) then
      ordsource:= OrdinaryCharacterTable( source );
      orddestin:= OrdinaryCharacterTable( destin );
      fus:= GetFusionMap( ordsource, orddestin );
      if fus <> fail then
        fus:= InverseMap( GetFusionMap( destin, orddestin ) ){ fus{
                              GetFusionMap( source, ordsource ) } };
        StoreFusion( source, fus, destin );
        return fus;
      fi;
    fi;

    # No fusion map was found.
    return fail;
end );


#############################################################################
##
#F  StoreFusion( <source>, <fusion>, <destination> )
#F  StoreFusion( <source>, <fusionmap>, <destination> )
##
InstallGlobalFunction( StoreFusion, function( source, fusion, destination )
    local fus;

    # (compatibility with GAP 3)
    if IsList( destination ) or IsRecord( destination ) then
      StoreFusion( source, destination, fusion );
      return;
    fi;

    # Check the arguments.
    if IsList( fusion ) and ForAll( fusion, IsPosInt ) then
      fusion:= rec( name := Identifier( destination ),
                    map  := Immutable( fusion ) );
    elif IsRecord( fusion ) and IsBound( fusion.map )
                            and ForAll( fusion.map, IsPosInt ) then
      if     IsBound( fusion.name )
         and fusion.name <> Identifier( destination ) then
        Error( "identifier of <destination> must be equal to <fusion>.name" );
      fi;
      fusion      := ShallowCopy( fusion );
      fusion.map  := Immutable( fusion.map );
      fusion.name := Identifier( destination );
    else
      Error( "<fusion> must be a list of pos. integers",
             " or a record containing at least <fusion>.map" );
    fi;

    # Adjust the map to the stored permutation.
    if HasClassPermutation( destination ) then
      fusion.map:= MakeImmutable( OnTuples( fusion.map,
                       Inverse( ClassPermutation( destination ) ) ) );
    fi;

    # Check that different stored fusions into the same table
    # have different specifications.
    for fus in ComputedClassFusions( source ) do
      if fus.name = fusion.name then

        # Do nothing if a known fusion is to be stored.
        if fus.map = fusion.map then
          return;
        fi;

        # Signal an error if two different fusions to the same
        # destination are to be stored, without distinguishing them.
        if    not IsBound( fusion.specification )
           or (     IsBound( fus.specification )
                and fusion.specification = fus.specification ) then
          Error( "fusion to <destination> already stored on <source>;\n",
             " to store another one, assign a different specification",
             " to the new fusion record <fusion>" );
        fi;

      fi;
    od;

    # The fusion is new, add it.
    Add( ComputedClassFusions( source ), Immutable( fusion ) );
    source:= Identifier( source );
    if not source in NamesOfFusionSources( destination ) then
      Add( NamesOfFusionSources( destination ), source );
    fi;
end );


#############################################################################
##
#M  NamesOfFusionSources( <tbl> ) . . . . . . .  for a nearly character table
##
InstallMethod( NamesOfFusionSources,
    "for a nearly character table",
    [ IsNearlyCharacterTable ],
    tbl -> [] );


#############################################################################
##
#F  PossibleClassFusions( <subtbl>, <tbl> )
##
InstallMethod( PossibleClassFusions,
    "for two ordinary character tables",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable ],
    function( subtbl, tbl )
    return PossibleClassFusions( subtbl, tbl,
               rec(
                    quick      := false,
                    parameters := rec(
                                       approxfus:= [],
                                       maxamb:= 200000,
                                       minamb:= 10000,
                                       maxlen:= 10
                                                        ) ) );
         end );


#############################################################################
##
#F  PossibleClassFusions( <subtbl>, <tbl>, <parameters> )
##
#T improvement:
#T use linear characters of subtbl for indirection, without decomposing
##
InstallMethod( PossibleClassFusions,
    "for two ordinary character tables, and a parameters record",
    [ IsNearlyCharacterTable, IsNearlyCharacterTable, IsRecord ],
    function( subtbl, tbl, parameters )
#T support option `no branch' ??
    local maycomputeattributessub,
#T document this parameter!
          subchars,            # known characters of the subgroup
          chars,               # known characters of the supergroup
          decompose,           # decomposition into `chars' allowed?
          quick,               # stop in case of a unique solution
          verify,              # check s.c. also in case of only one orbit
          maxamb,              # parameter, omit characters of higher indet.
          minamb,              # parameter, omit characters of lower indet.
          maxlen,              # parameter, branch only up to this number
          approxfus,           # known part of the fusion
          permchar,            # perm. char. of `subtbl' in `tbl'
          fus,                 # parametrized map repres. the fusions
          flag,                # result of `MeetMaps'
          subtbl_powermap,     # known power maps of `subtbl'
          tbl_powermap,        # known power maps of `tbl'
          p,                   # position in `subtbl_powermap'
          taut,                # table automorphisms of `tbl', or `false'
          grp,                 # admissible subgroup of automorphisms
          imp,                 # list of improvements
          poss,                # list of possible fusions
          subgroupfusions,
          subtaut;

    # May `subtbl' be asked for nonstored attribute values?
    # (Currently `Irr' and `AutomorphismsOfTable' are used.)
    if IsBound( parameters.maycomputeattributessub ) then
      maycomputeattributessub:= parameters.maycomputeattributessub;
    else
      maycomputeattributessub:= IsCharacterTable;
    fi;

    # available characters of `subtbl'
    if IsBound( parameters.subchars ) then
      subchars:= parameters.subchars;
      decompose:= false;
    elif HasIrr( subtbl ) or maycomputeattributessub( subtbl ) then
      subchars:= Irr( subtbl );
      decompose:= true;
#T possibility to have subchars and incomplete tables ???
    else
      subchars:= [];
      decompose:= false;
    fi;

    # available characters of `tbl'
    if IsBound( parameters.chars ) then
      chars:= parameters.chars;
    elif HasIrr( tbl ) or IsOrdinaryTable( tbl ) then
      chars:= Irr( tbl );
    else
      chars:= [];
    fi;

    # parameters `quick' and `verify'
    quick:= IsBound( parameters.quick ) and parameters.quick = true;
    verify:= IsBound( parameters.verify ) and parameters.verify = true;

    # Is `decompose' explicitly allowed or forbidden?
    if IsBound( parameters.decompose ) then
      decompose:= parameters.decompose = true;
    fi;

    if     IsBound( parameters.parameters )
       and IsRecord( parameters.parameters ) then
      maxamb:= parameters.parameters.maxamb;
      minamb:= parameters.parameters.minamb;
      maxlen:= parameters.parameters.maxlen;
    else
      maxamb:= 200000;
      minamb:= 10000;
      maxlen:= 10;
    fi;

    if IsBound( parameters.fusionmap ) then
      approxfus:= parameters.fusionmap;
    else
      approxfus:= [];
    fi;

    if IsBound( parameters.permchar ) then
      permchar:= parameters.permchar;
      if Length( permchar ) <> NrConjugacyClasses( tbl ) then
        Error( "length of <permchar> must be the no. of classes of <tbl>" );
      fi;
    else
      permchar:= [];
    fi;
    # (end of the inspection of the parameters)

    # Initialize the fusion.
    fus:= InitFusion( subtbl, tbl );
    if fus = fail then
      Info( InfoCharacterTable, 2,
            "PossibleClassFusions: no initialisation possible" );
      return [];
    fi;
    Info( InfoCharacterTable, 2,
          "PossibleClassFusions: fusion initialized" );

    # Use `approxfus'.
    flag:= MeetMaps( fus, approxfus );
    if flag <> true then
      Info( InfoCharacterTable, 2,
            "PossibleClassFusions: possible maps not compatible with ",
            "<approxfus> at class ", flag );
      return [];
    fi;

    # Use the permutation character for the first time.
    if not IsEmpty( permchar ) then
      if not CheckPermChar( subtbl, tbl, fus, permchar ) then
        Info( InfoCharacterTable, 2,
              "PossibleClassFusions: fusion inconsistent with perm.char." );
        return [];
      fi;
      Info( InfoCharacterTable, 2,
            "PossibleClassFusions: permutation character checked");
    fi;

    # Check consistency of fusion and power maps.
    # (If necessary then compute power maps of `subtbl' that are available
    # in `tbl'.)
    subtbl_powermap := ComputedPowerMaps( subtbl );
    tbl_powermap    := ComputedPowerMaps( tbl );
    if IsOrdinaryTable( subtbl ) and HasIrr( subtbl ) then
      for p in [ 1 .. Length( tbl_powermap ) ] do
        if IsBound( tbl_powermap[p] )
           and not IsBound( subtbl_powermap[p] ) then
          PowerMap( subtbl, p );
        fi;
      od;
    fi;
    if not TestConsistencyMaps( subtbl_powermap, fus, tbl_powermap ) then
      Info( InfoCharacterTable, 2,
            "PossibleClassFusions: inconsistency of fusion and power maps" );
      return [];
    fi;
    Info( InfoCharacterTable, 2,
          "PossibleClassFusions: consistency with power maps checked,\n",
          "#I    ", IndeterminatenessInfo( fus ) );

    # May we return?
    if quick and ForAll( fus, IsInt ) then return [ fus ]; fi;

    # Consider table automorphisms of the supergroup.
    if   HasAutomorphismsOfTable( tbl ) or IsCharacterTable( tbl ) then
      taut:= AutomorphismsOfTable( tbl );
    else
      taut:= false;
      Info( InfoCharacterTable, 2,
            "PossibleClassFusions: no table automorphisms stored" );
    fi;

    if taut <> false then
      imp:= ConsiderTableAutomorphisms( fus, taut );
      if IsEmpty( imp ) then
        Info( InfoCharacterTable, 2,
              "PossibleClassFusions: table automorphisms checked, ",
              "no improvements" );
      else
        Info( InfoCharacterTable, 2,
              "PossibleClassFusions: table automorphisms checked, ",
              "improvements at classes\n",
              "#I   ", imp );
        if not TestConsistencyMaps( ComputedPowerMaps( subtbl ),
                                    fus,
                                    ComputedPowerMaps( tbl ),
                                    imp ) then
          Info( InfoCharacterTable, 2,
                "PossibleClassFusions: inconsistency of fusion ",
                "and power maps" );
          return [];
        fi;
        Info( InfoCharacterTable, 2,
              "PossibleClassFusions: consistency with power maps ",
              "checked again,\n",
              "#I    ", IndeterminatenessInfo( fus ) );
      fi;
    fi;

    # Use the permutation character for the second time.
    if not IsEmpty( permchar ) then
      if not CheckPermChar( subtbl, tbl, fus, permchar ) then
        Info( InfoCharacterTable, 2,
              "PossibleClassFusions: inconsistency of fusion and permchar" );
        return [];
      fi;
      Info( InfoCharacterTable, 2,
            "PossibleClassFusions: permutation character checked again");
    fi;

    if quick and ForAll( fus, IsInt ) then return [ fus ]; fi;

    # Now use restricted characters.
    # If `decompose' is `true', use decompositions of
    # indirections of <chars> into <subchars>;
    # otherwise only check the scalar products with <subchars>.

    if decompose then

      if Indeterminateness( fus ) < minamb then
        Info( InfoCharacterTable, 2,
              "PossibleClassFusions: indeterminateness too small for test\n",
              "#I    of decomposability" );
        poss:= [ fus ];
      elif IsEmpty( chars ) then
        Info( InfoCharacterTable, 2,
              "PossibleClassFusions: no characters given for test ",
              "of decomposability" );
        poss:= [ fus ];
      else
        Info( InfoCharacterTable, 2,
              "PossibleClassFusions: now test decomposability of",
              " rational restrictions" );
        poss:= FusionsAllowedByRestrictions( subtbl, tbl,
                      RationalizedMat( subchars ),
                      RationalizedMat( chars ), fus,
                      rec( maxlen    := maxlen,
                           contained := ContainedCharacters,
                           minamb    := minamb,
                           maxamb    := infinity,
                           quick     := quick ) );

        poss:= Filtered( poss, x ->
                  TestConsistencyMaps( subtbl_powermap, x, tbl_powermap ) );
#T dangerous if power maps are not unique!

        # Use the permutation character for the third time.
        if not IsEmpty( permchar ) then
          poss:= Filtered( poss, x -> CheckPermChar(subtbl,tbl,x,permchar) );
        fi;

        Info( InfoCharacterTable, 2,
              "PossibleClassFusions: decomposability tested,\n",
              "#I    ", Length( poss ),
              " solution(s) with indeterminateness\n",
              "#I    ", List( poss, Indeterminateness ) );

      fi;

    else

      Info( InfoCharacterTable, 2,
            "PossibleClassFusions: no test of decomposability" );
      poss:= [ fus ];

    fi;

    Info( InfoCharacterTable, 2,
          "PossibleClassFusions: test scalar products of restrictions" );

    subgroupfusions:= [];
    for fus in poss do
      Append( subgroupfusions,
              FusionsAllowedByRestrictions( subtbl, tbl, subchars, chars,
                        fus, rec( maxlen:= maxlen,
                                  contained:= ContainedPossibleCharacters,
                                  minamb:= 1,
                                  maxamb:= maxamb,
                                  quick:= quick ) ) );
    od;

    # Check the consistency with power maps again.
    subgroupfusions:= Filtered( subgroupfusions, x ->
                  TestConsistencyMaps( subtbl_powermap, x, tbl_powermap ) );
#T dangerous if power maps are not unique!
    if Length( subgroupfusions ) = 0 then
      return subgroupfusions;
    elif quick and Length( subgroupfusions ) = 1
               and ForAll( subgroupfusions[1], IsInt ) then
      return subgroupfusions;
    fi;

    subtaut:= GroupByGenerators( [], () );
    if 1 < Length( subgroupfusions ) then
      if    HasAutomorphismsOfTable( subtbl )
         or maycomputeattributessub( subtbl ) then
        subtaut:= AutomorphismsOfTable( subtbl );
      fi;
      subgroupfusions:= RepresentativesFusions( subtaut, subgroupfusions,
                            Group( () ) );
    fi;

    if verify or 1 < Length( subgroupfusions ) then

      # Use the structure constants criterion.
      # (Since table automorphisms preserve structure constants,
      # it is sufficient to check representatives only.)
      Info( InfoCharacterTable, 2,
            "PossibleClassFusions: test structure constants" );
      subgroupfusions:=
          ConsiderStructureConstants( subtbl, tbl, subgroupfusions, quick );

    fi;

    # Make orbits under the admissible subgroup of `taut'
    # to get the whole set of all subgroup fusions,
    # where admissible means that if there was an approximation `fusionmap'
    # in the argument record, this map must be respected;
    # if the permutation character `permchar' was entered then it must be
    # respected, too.

    if taut <> false then
      if IsEmpty( permchar ) then
        grp:= taut;
      else

        # Use the permutation character for the fourth time.
        grp:= SubgroupProperty( taut,
                  x -> ForAll( [1 .. Length( permchar ) ],
                               y -> permchar[y] = permchar[y^x] ) );
      fi;
      subgroupfusions:= Set( Concatenation( List( subgroupfusions,
          x -> OrbitFusions( subtaut, x, grp ) ) ) );
    fi;

    if not IsEmpty( approxfus ) then
      subgroupfusions:= Filtered( subgroupfusions,
          x -> ForAll( [ 1 .. Length( approxfus ) ],
                 y -> not IsBound( approxfus[y] )
                       or ( IsInt(approxfus[y]) and x[y] = approxfus[y] )
                       or ( IsList(approxfus[y]) and IsInt( x[y] )
                            and x[y] in approxfus[y] )
                       or ( IsList(approxfus[y]) and IsList( x[y] )
                            and IsSubset( approxfus[y], x[y] ) )));
    fi;

    # Print some messages about the orbit distribution.
    if 2 <= InfoLevel( InfoCharacterTable ) then

      # If possible make orbits under the groups of table automorphisms.
      if     1 < Length( subgroupfusions )
         and ForAll( subgroupfusions, x -> ForAll( x, IsInt ) ) then

        if taut = false then
          taut:= GroupByGenerators( [], () );
        fi;
        RepresentativesFusions( subtaut, subgroupfusions, taut );

      fi;

      # Print the messages.
      if ForAny( subgroupfusions, x -> ForAny( x, IsList ) ) then
        Print( "#I  PossibleClassFusions: ", Length( subgroupfusions ),
               " parametrized solution" );
        if Length( subgroupfusions ) = 1 then
          Print( ",\n" );
        else
          Print( "s,\n" );
        fi;
        Print( "#I    no further improvement was possible with",
               " given characters\n",
               "#I    and maximal checked ambiguity of ", maxamb, "\n" );
      else
        Print( "#I  PossibleClassFusions: ", Length( subgroupfusions ),
               " solution" );
        if Length( subgroupfusions ) = 1 then
          Print( "\n" );
        else
          Print( "s\n" );
        fi;
      fi;

    fi;

    # Return the list of possibilities.
    return subgroupfusions;
    end );


#############################################################################
##
#F  PossibleClassFusions( <submodtbl>, <modtbl> )
##
InstallMethod( PossibleClassFusions,
    "for two Brauer tables",
    [ IsBrauerTable, IsBrauerTable ],
    function( submodtbl, modtbl )
    local ordsub, ordtbl, fus, invGfus, Hfus;

    ordsub:= OrdinaryCharacterTable( submodtbl );
    ordtbl:= OrdinaryCharacterTable( modtbl );
    fus:= PossibleClassFusions( ordsub, ordtbl );

    if not IsEmpty( fus ) then
      invGfus:= InverseMap( GetFusionMap( modtbl, ordtbl ) );
      Hfus:= GetFusionMap( submodtbl, ordsub );
      fus:= Set( List( fus ),
                 map -> CompositionMaps( invGfus,
                            CompositionMaps( map, Hfus ) ) );
    fi;

    return fus;
    end );


#############################################################################
##
#F  OrbitFusions( <subtblautomorphisms>, <fusionmap>, <tblautomorphisms> )
##
InstallGlobalFunction( OrbitFusions,
    function( subtblautomorphisms, fusionmap, tblautomorphisms )
    local i, orb, gen, image;

    orb:= [ fusionmap ];
    subtblautomorphisms:= GeneratorsOfGroup( subtblautomorphisms );
    tblautomorphisms:= GeneratorsOfGroup( tblautomorphisms );
    for fusionmap in orb do
      for gen in subtblautomorphisms do
        image:= Permuted( fusionmap, gen );
        if not image in orb then
          Add( orb, image );
        fi;
      od;
    od;
    for fusionmap in orb do
      for gen in tblautomorphisms do
        image:= [];
        for i in fusionmap do
          if IsInt( i ) then
            Add( image, i^gen );
          else
            Add( image, Set( OnTuples( i, gen ) ) );
          fi;
        od;
        if not image in orb then
          Add( orb, image );
        fi;
      od;
    od;
#T is slow if the orbit is long;
#T better use `Orbit', but with which group?
    return orb;
end );


#############################################################################
##
#F  RepresentativesFusions( <subtblautomorphisms>, <listoffusionmaps>,
#F                          <tblautomorphisms> )
#F  RepresentativesFusions( <subtbl>, <listoffusionmaps>, <tbl> )
##
InstallGlobalFunction( RepresentativesFusions,
    function( subtblautomorphisms, listoffusionmaps, tblautomorphisms )
    local stable, gens, orbits, orbit;

    if IsEmpty( listoffusionmaps ) then
      return [];
    fi;
    listoffusionmaps:= Set( listoffusionmaps );
    if IsNearlyCharacterTable( subtblautomorphisms ) then

      if    HasAutomorphismsOfTable( subtblautomorphisms )
         or IsCharacterTable( subtblautomorphisms ) then
        subtblautomorphisms:= AutomorphismsOfTable( subtblautomorphisms );
      else
        subtblautomorphisms:= GroupByGenerators( [], () );
        Info( InfoCharacterTable, 2,
              "RepresentativesFusions: no subtable automorphisms stored" );
      fi;

    fi;

    if IsNearlyCharacterTable( tblautomorphisms ) then

      if    HasAutomorphismsOfTable( tblautomorphisms )
         or IsCharacterTable( tblautomorphisms ) then
        tblautomorphisms:= AutomorphismsOfTable( tblautomorphisms );
      else
        tblautomorphisms:= GroupByGenerators( [], () );
        Info( InfoCharacterTable, 2,
              "RepresentativesFusions: no table automorphisms stored" );
      fi;

    fi;

    # Find the subgroups of all those table automorphisms that act on
    # <listoffusionmaps>.
    gens:= GeneratorsOfGroup( subtblautomorphisms );
    stable:= Filtered( gens,
                 x -> ForAll( listoffusionmaps,
                              y -> Permuted( y, x ) in listoffusionmaps ) );
    if stable <> gens then
      Info( InfoCharacterTable, 2,
            "RepresentativesFusions: Not all table automorphisms of the\n",
            "#I    subgroup table act; computing the admiss. subgroup." );
      subtblautomorphisms:= SubgroupProperty( subtblautomorphisms,
             ( x -> ForAll( listoffusionmaps,
                            y -> Permuted( y, x ) in listoffusionmaps ) ),
             GroupByGenerators( stable, () ) );
    fi;

    gens:= GeneratorsOfGroup( tblautomorphisms );
    stable:= Filtered( gens,
                 x -> ForAll( listoffusionmaps,
                              y -> List( y, z->z^x ) in listoffusionmaps ) );
    if stable <> gens then
      Info( InfoCharacterTable, 2,
            "RepresentativesFusions: Not all table automorphisms of the\n",
            "#I    supergroup table act; computing the admiss. subgroup." );
      tblautomorphisms:= SubgroupProperty( tblautomorphisms,
             ( x -> ForAll( listoffusionmaps,
                            y -> List( y, z -> z^x ) in listoffusionmaps ) ),
             GroupByGenerators( stable, () ) );
    fi;

    # Distribute the maps to orbits.
    orbits:= [];
    while not IsEmpty( listoffusionmaps ) do
      orbit:= OrbitFusions( subtblautomorphisms, listoffusionmaps[1],
                            tblautomorphisms );
      Add( orbits, orbit );
      SubtractSet( listoffusionmaps, orbit );
    od;

    Info( InfoCharacterTable, 2,
          "RepresentativesFusions: ", Length( orbits ),
          " orbit(s) of length(s) ", List( orbits, Length ) );

    # Choose representatives, and return them.
    return List( orbits, x -> x[1] );
end );


#############################################################################
##
##  4. Utilities for Parametrized Maps
##


#############################################################################
##
#F  CompositionMaps( <paramap2>, <paramap1>[, <class>] )
##
InstallGlobalFunction( CompositionMaps, function( arg )
    local i, j, map1, map2, class, result, newelement;

    if Length(arg) = 2 and IsList(arg[1]) and IsList(arg[2]) then

      map2:= arg[1];
      map1:= arg[2];
      result:= [];
      for i in [ 1 .. Length( map1 ) ] do
        if IsBound( map1[i] ) then
          result[i]:= CompositionMaps( map2, map1, i );
        fi;
      od;

    elif Length( arg ) = 3
         and IsList( arg[1] ) and IsList( arg[2] ) and IsInt( arg[3] ) then

      map2:= arg[1];
      map1:= arg[2];
      class:= arg[3];
      if IsInt( map1[ class ] ) then
        result:= map2[ map1[ class ] ];
        if IsList( result ) and Length( result ) = 1 then
          result:= result[1];
        fi;
      else
        result:= [];
        for j in map1[ class ] do
          newelement:= map2[j];
          if IsList( newelement ) and not IsString( newelement ) then
            UniteSet( result, newelement );
          else
            AddSet( result, newelement );
          fi;
        od;
        if Length( result ) = 1 then result:= result[1]; fi;
      fi;

    else
      Error(" usage: CompositionMaps( <map2>, <map1>[, <class>] )" );
    fi;

    return result;
end );


#############################################################################
##
#F  InverseMap( <paramap> )  . . . . . . . . .  Inverse of a parametrized map
##
InstallGlobalFunction( InverseMap, function( paramap )
    local i, inversemap, im;
    inversemap:= [];
    for i in [ 1 .. Length( paramap ) ] do
      if IsList( paramap[i] ) then
        for im in paramap[i] do
          if IsBound( inversemap[ im ] ) then
            AddSet( inversemap[ im ], i );
          else
            inversemap[ im ]:= [ i ];
          fi;
        od;
      else
        if IsBound( inversemap[ paramap[i] ] ) then
          AddSet( inversemap[ paramap[i] ], i );
        else
          inversemap[ paramap[i] ]:= [ i ];
        fi;
      fi;
    od;
    for i in [ 1 .. Length( inversemap ) ] do
      if IsBound( inversemap[i] ) and Length( inversemap[i] ) = 1 then
        inversemap[i]:= inversemap[i][1];
      fi;
    od;
    return inversemap;
end );


#############################################################################
##
#F  ProjectionMap( <fusionmap> ) . . projection corresponding to a fusion map
##
InstallGlobalFunction( ProjectionMap, function( fusionmap )
    local i, projection;
    projection:= [];
    for i in Reversed( [ 1 .. Length( fusionmap ) ] ) do
      projection[ fusionmap[i] ]:= i;
    od;
    return projection;
end );


#############################################################################
##
#F  Indirected( <character>, <paramap> )
##
InstallGlobalFunction( Indirected, function( character, paramap )
    local i, imagelist, indirected;
    indirected:= [];
    for i in [ 1 .. Length( paramap ) ] do
      if IsInt( paramap[i] ) then
        indirected[i]:= character[ paramap[i] ];
      else
        imagelist:= Set( character{ paramap[i] } );
        if Length( imagelist ) = 1 then
          indirected[i]:= imagelist[1];
        else
          indirected[i]:= Unknown();
        fi;
      fi;
    od;
    return indirected;
end );


#############################################################################
##
#F  Parametrized( <list> )
##
InstallGlobalFunction( Parametrized, function( list )
    local i, j, parametrized;
    if list = [] then return []; fi;
    parametrized:= [];
    for i in [ 1 .. Length( list[1] ) ] do
      if ( IsList( list[1][i] ) and not IsString( list[1][i] ) )
         or list[1][i] = [] then
        parametrized[i]:= list[1][i];
      else
        parametrized[i]:= [ list[1][i] ];
      fi;
    od;
    for i in [ 2 .. Length( list ) ] do
      for j in [ 1 .. Length( list[i] ) ] do
        if ( IsList( list[i][j] ) and not IsString( list[i][j] ) )
           or list[i][j] = [] then
          UniteSet( parametrized[j], list[i][j] );
        else
          AddSet( parametrized[j], list[i][j] );
        fi;
      od;
    od;
    for i in [ 1 .. Length( list[1] ) ] do
      if Length( parametrized[i] ) = 1 then
        parametrized[i]:= parametrized[i][1];
      fi;
    od;
    return parametrized;
end );


#############################################################################
##
#F  ContainedMaps( <paramap> )
##
InstallGlobalFunction( ContainedMaps, function( paramap )
    local i, j, containedmaps, copy;
    i:= 1;
    while i <= Length( paramap ) and
          ( not IsList( paramap[i] ) or IsString( paramap[i] ) ) do
      i:= i+1;
    od;
    if i > Length( paramap ) then
      return [ StructuralCopy( paramap ) ];
    else
      containedmaps:= [];
      copy:= ShallowCopy( paramap );
      for j in paramap[i] do
        copy[i]:= j;
        Append( containedmaps, ContainedMaps( copy ) );
      od;
      return containedmaps;
    fi;
end );


#############################################################################
##
#F  UpdateMap( <char>, <paramap>, <indirected> )
##
InstallGlobalFunction( UpdateMap, function( char, paramap, indirected )
    local i, j, value, fus;

    for i in [ 1 .. Length( paramap ) ] do
      if IsInt( paramap[i] ) then
        if indirected[i] <> char[ paramap[i] ] then
          Info( InfoCharacterTable, 2,
                "UpdateMap: inconsistency at class ", i );
          return false;
        fi;
      else
        value:= indirected[i];
        if not IsList( value ) then value:= [ value ]; fi;
        fus:= [];
        for j in paramap[i] do
          if char[j] in value then Add( fus, j ); fi;
        od;
        if fus = [] then
          Info( InfoCharacterTable, 2,
                "UpdateMap: inconsistency at class ", i );
          return false;
        else
          if Length( fus ) = 1 then fus:= fus[1]; fi;
          paramap[i]:= fus;
        fi;
      fi;
    od;
    return true;
end );


#############################################################################
##
#F  MeetMaps( <map1>, <map2> )
##
InstallGlobalFunction( MeetMaps, function( map1, map2 )
    local i;      # loop over the classes

    for i in [ 1 .. Maximum( Length( map1 ), Length( map2 ) ) ] do
      if IsBound( map1[i] ) then
        if IsBound( map2[i] ) then

          # This is the only case where we have to work.
          if IsInt( map1[i] ) then
            if IsInt( map2[i] ) then
              if map1[i] <> map2[i] then
                return i;
              fi;
            elif not map1[i] in map2[i] then
              return i;
            fi;
          elif IsInt( map2[i] ) then
            if map2[i] in map1[i] then
              map1[i]:= map2[i];
            else
              return i;
            fi;
          else
            map1[i]:= Intersection( map1[i], map2[i] );
            if map1[i] = [] then
              return i;
            elif Length( map1[i] ) = 1 then
              map1[i]:= map1[i][1];
            fi;
          fi;

        fi;
      elif IsBound( map2[i] ) then
        map1[i]:= map2[i];
      fi;
    od;
    return true;
end );


#############################################################################
##
#F  ImproveMaps( <map2>, <map1>, <composition>, <class> )
##
InstallGlobalFunction( ImproveMaps,
    function( map2, map1, composition, class )
    local j, map1_i, newvalue;

    map1_i:= map1[ class ];
    if IsInt( map1_i ) then

      # case 1: map2[ map1_i ] must be a set,
      #         try to improve map2 at that position
      if composition <> map2[ map1_i ] then
        if Length( composition ) = 1 then
          map2[ map1_i ]:= composition[1];
        else
          map2[ map1_i ]:= composition;
        fi;

        # map2[ map1_i ] was improved
        return map1_i;
      fi;
    else

      # case 2: try to improve map1[ class ]
      newvalue:= [];
      for j in map1_i do
        if ( IsInt( map2[j] ) and map2[j] in composition ) or
           (     IsList( map2[j] )
             and Intersection2( map2[j], composition ) <> [] ) then
          AddSet( newvalue, j );
        fi;
      od;
      if newvalue <> map1_i then
        if Length( newvalue ) = 1 then
          map1[ class ]:= newvalue[1];
        else
          map1[ class ]:= newvalue;
        fi;
        return -1;                  # map1 was improved
      fi;
    fi;
    return 0;                       # no improvement
end );


#############################################################################
##
#F  CommutativeDiagram( <paramap1>, <paramap2>, <paramap3>, <paramap4>[,
#F                      <improvements>] )
##
##    i ---------> map1[i]
##    |              |
##    |              v
##    |          map2[ map1[i] ]
##    v
##  map3[i] ---> map4[ map3[i] ]
##
InstallGlobalFunction( CommutativeDiagram, function( arg )
    local i, paramap1, paramap2, paramap3, paramap4, imp1, imp2, imp4,
          globalimp1, globalimp2, globalimp3, globalimp4, newimp1, newimp2,
          newimp4, map2_map1, map4_map3, composition, imp;

    if not ( Length(arg) in [ 4, 5 ] and IsList(arg[1]) and IsList(arg[2])
             and IsList( arg[3] ) and IsList( arg[4] ) )
       or ( Length( arg ) = 5 and not IsRecord( arg[5] ) ) then
      Error("usage: CommutativeDiagram(<pmap1>,<pmap2>,<pmap3>,<pmap4>)\n",
          "resp. CommutativeDiagram(<pmap1>,<pmap2>,<pmap3>,<pmap4>,<imp>)");
    fi;

    paramap1:= arg[1];
    paramap2:= arg[2];
    paramap3:= arg[3];
    paramap4:= arg[4];
    if Length( arg ) = 5 then
      imp1:= Union( arg[5].imp1, arg[5].imp3 );
      imp2:= arg[5].imp2;
      imp4:= arg[5].imp4;
    else
      imp1:= List( [ 1 .. Length( paramap1 ) ] );
      imp2:= [];
      imp4:= [];
    fi;
    globalimp1:= [];
    globalimp2:= [];
    globalimp3:= [];
    globalimp4:= [];
    while imp1 <> [] or imp2 <> [] or imp4 <> [] do
      newimp1:= [];
      newimp2:= [];
      newimp4:= [];
      for i in [ 1 .. Length( paramap1 ) ] do
        if i in imp1
           or ( IsList(paramap1[i]) and Intersection2(paramap1[i],imp2)<>[] )
           or ( IsList(paramap3[i]) and Intersection2(paramap3[i],imp4)<>[] )
           or ( IsInt( paramap1[i] ) and paramap1[i] in imp2 )
           or ( IsInt( paramap3[i] ) and paramap3[i] in imp4 ) then
          map2_map1:= CompositionMaps( paramap2, paramap1, i );
          map4_map3:= CompositionMaps( paramap4, paramap3, i );

          if IsInt( map2_map1 ) then map2_map1:= [ map2_map1 ]; fi;
          if IsInt( map4_map3 ) then map4_map3:= [ map4_map3 ]; fi;

          composition:= Intersection2( map2_map1, map4_map3 );
          if composition = [] then
            Info( InfoCharacterTable, 2,
                  "CommutativeDiagram: inconsistency at class", i );
            return fail;
          fi;
          if composition <> map2_map1 then
            imp:= ImproveMaps( paramap2, paramap1, composition, i );
            if imp = -1 then
              AddSet( newimp1, i );
              AddSet( globalimp1, i );
            elif imp <> 0 then
              AddSet( newimp2, imp );
              AddSet( globalimp2, imp );
            fi;
          fi;
          if composition <> map4_map3 then
            imp:= ImproveMaps( paramap4, paramap3, composition, i );
            if imp = -1 then
              AddSet( newimp1, i );
              AddSet( globalimp3, i );
            elif imp <> 0 then
              AddSet( newimp4, imp );
              AddSet( globalimp4, imp );
            fi;
          fi;
        fi;
      od;
      imp1:= newimp1;
      imp2:= newimp2;
      imp4:= newimp4;
    od;
    return rec(
                imp1:= globalimp1,
                imp2:= globalimp2,
                imp3:= globalimp3,
                imp4:= globalimp4
                                  );
end );


#############################################################################
##
#F  CheckFixedPoints( <inside1>, <between>, <inside2> )
##
InstallGlobalFunction( CheckFixedPoints,
    function( inside1, between, inside2 )
    local i, improvements, errors, image;

    improvements:= [];
    errors:= [];
    for i in [ 1 .. Length( inside1 ) ] do

      # Loop over the fixed points of `inside1'.
      if inside1[i] = i then
        if IsInt( between[i] ) then
          if inside2[ between[i] ] <> between[i] then
            if IsInt( inside2[ between[i] ] )
               or not between[i] in inside2[ between[i] ] then
              Add( errors, i );
            else
              inside2[ between[i] ]:= between[i];
              Add( improvements, i );
            fi;
          fi;
        else
          image:= Filtered( between[i], j -> inside2[j] = j
                      or ( IsList( inside2[j] ) and j in inside2[j] ) );
          if IsEmpty( image ) then
            AddSet( errors, i );
          elif image <> between[i] then
            if Length( image ) = 1 then
              image:= image[1];
            fi;
            between[i]:= image;
            AddSet( improvements, i );
          fi;
        fi;
      fi;

    od;

    if IsEmpty( errors ) then
      if improvements <> [] then
        Info( InfoCharacterTable, 2,
              "CheckFixedPoints: improvements at classes ", improvements );
      fi;
      return improvements;
    else
      Info( InfoCharacterTable, 2,
            "CheckFixedPoints: no image possible for classes ", errors );
      return fail;
    fi;
end );


#############################################################################
##
#F  TransferDiagram( <inside1>, <between>, <inside2>[, <improvements>] )
##
##     i   -----> between[i]
##     |            |
##     |            v
##     |         inside2[ between[i] ]
##     v
##  inside1[i] ----> between[ inside1[i] ]
##
InstallGlobalFunction( TransferDiagram, function( arg )
    local i, inside1, between, inside2, imp1, impb, imp2, globalimp1,
          globalimpb, globalimp2, newimp1, newimpb, newimp2, bet_ins1,
          ins2_bet, composition, imp, check;

    if fail in arg then
      Info( InfoCharacterTable, 2,
            "TransferDiagram: `fail' among the arguments" );
      return fail;
    fi;
    if not ( Length(arg) in [ 3, 4 ] and IsList(arg[1]) and IsList(arg[2])
             and IsList( arg[3] ) )
       or ( Length( arg ) = 4 and not IsRecord( arg[4] ) ) then
      Error("usage: TransferDiagram(<inside1>,<between>,<inside2>) resp.\n",
            "       TransferDiagram(<inside1>,<between>,<inside2>,<imp> )" );
    fi;
    inside1:= arg[1];
    between:= arg[2];
    inside2:= arg[3];
    if Length( arg ) = 4 then
      imp1:= arg[4].impinside1;
      impb:= arg[4].impbetween;
      imp2:= arg[4].impinside2;
    else
      imp1:= List( [ 1 .. Length( inside1 ) ] );
      impb:= [];
      imp2:= [];
    fi;
    globalimp1:= [];
    globalimpb:= [];
    globalimp2:= [];
    while imp1 <> [] or impb <> [] or imp2 <> [] do
      newimp1:= [];
      newimpb:= [];
      newimp2:= [];
      for i in [ 1 .. Length( inside1 ) ] do
        if i in imp1 or i in impb
           or ( IsList( inside1[i] ) and Intersection(inside1[i],impb)<>[] )
           or ( IsList( between[i] ) and Intersection(between[i],imp2)<>[] )
           or ( IsInt( inside1[i] ) and inside1[i] in impb )
           or ( IsInt( between[i] ) and between[i] in imp2 ) then
          bet_ins1:= CompositionMaps( between, inside1, i );
          ins2_bet:= CompositionMaps( inside2, between, i );
          if IsInt( bet_ins1 ) then bet_ins1:= [ bet_ins1 ]; fi;
          if IsInt( ins2_bet ) then ins2_bet:= [ ins2_bet ]; fi;
          composition:= Intersection( bet_ins1, ins2_bet );
          if composition = [] then
            Info( InfoCharacterTable, 2,
                  "TransferDiagram: inconsistency at class ", i );
            return fail;
          fi;
          if composition <> bet_ins1 then
            imp:= ImproveMaps( between, inside1, composition, i );
            if imp = -1 then
              AddSet( newimp1, i );
              AddSet( globalimp1, i );
            elif imp <> 0 then
              AddSet( newimpb, imp );
              AddSet( globalimpb, imp );
            fi;
          fi;
          if composition <> ins2_bet then
            imp:= ImproveMaps( inside2, between, composition, i );
            if imp = -1 then
              AddSet( newimpb, i );
              AddSet( globalimpb, i );
            elif imp <> 0 then
              AddSet( newimp2, imp );
              AddSet( globalimp2, imp );
            fi;
          fi;
        fi;
      od;
      imp1:= newimp1;
      impb:= newimpb;
      imp2:= newimp2;
    od;
    check:= CheckFixedPoints( inside1, between, inside2 );
    if check = fail then
      return fail;
    elif check <> [] then
      check:= TransferDiagram( inside1, between, inside2,
                               rec( impinside1:= [], impbetween:= check,
                                    impinside2:= [] ) );
      return rec( impinside1:= Union( check.impinside1, globalimp1 ),
                  impbetween:= Union( check.impbetween, globalimpb ),
                  impinside2:= Union( check.impinside2, globalimp2 ) );
    else
      return rec( impinside1:= globalimp1, impbetween:= globalimpb,
                  impinside2:= globalimp2 );
    fi;
end );


#############################################################################
##
#F  TestConsistencyMaps( <powermap1>, <fusionmap>, <powermap2> )
#F  TestConsistencyMaps( <powermap1>, <fusionmap>, <powermap2>, <fus_imp> )
##
InstallGlobalFunction( TestConsistencyMaps, function( arg )
    local i, j, x, powermap1, powermap2, pos, fusionmap, imp,
          fus_improvements, tr;

    if not ( Length(arg) in [ 3, 4 ] and IsList(arg[1]) and IsList(arg[2])
             and IsList( arg[3] ) )
       or ( Length( arg ) = 4 and not IsList( arg[4] ) ) then
      Error("usage: TestConsistencyMaps(<powmap1>,<fusmap>,<powmap2>)",
            " resp.\n    ",
            "TestConsistencyMaps(<powmap1>,<fusmap>,<powmap2>,<fus_imp>)");
    fi;
    powermap1:= [];
    powermap2:= [];
    pos:= [];
    for i in [ 1 .. Length( arg[1] ) ] do
      if IsBound( arg[1][i] ) and IsBound( arg[3][i] ) then
        Add( powermap1, arg[1][i] );
        Add( powermap2, arg[3][i] );
        Add( pos, i );
      fi;
    od;
    fusionmap:= arg[2];
    if Length( arg ) = 4 then
      imp:= arg[4];
    else
      imp:= [ 1 .. Length( fusionmap ) ];
    fi;
    fus_improvements:= List( [ 1 .. Length( powermap1 ) ], x -> imp );
    if fus_improvements = [] then return true; fi;     # no common powermaps
    i:= 1;
    while fus_improvements[i] <> [] do
      tr:= TransferDiagram( powermap1[i], fusionmap, powermap2[i],
                     rec( impinside1:= [],
                          impbetween:= fus_improvements[i],
                          impinside2:= [] ) );
      # (We are only interested in improvements of the fusionmap which may
      #  have occurred.)

      if tr = fail then
        Info( InfoCharacterTable, 2,
              "TestConsistencyMaps: inconsistency in ", Ordinal( pos[i] ),
              " power map" );
        return false;
      fi;
      for j in [ 1 .. Length( fus_improvements ) ] do
        fus_improvements[j]:= Union( fus_improvements[j], tr.impbetween );
      od;
      fus_improvements[i]:= [];
      i:= ( i mod Length( fus_improvements ) ) + 1;
    od;
    return true;
end );


#############################################################################
##
#F  Indeterminateness( <paramap> ) . . . . the indeterminateness of a paramap
##
InstallGlobalFunction( Indeterminateness, function( paramap )
    local prod, i;
    prod:= 1;
    for i in paramap do
      if IsList( i ) then
        prod:= prod * Length( i );
      fi;
    od;
    return prod;
end );


#############################################################################
##
#F  IndeterminatenessInfo( <paramap> )
##
##  local function used in `Info' calls in computations of possible class
##  fusions and possible power maps
##
InstallGlobalFunction( IndeterminatenessInfo, function( paramap )
    paramap:= Indeterminateness( paramap );
    if paramap < 10^10 then
      return Concatenation( "the current indeterminateness is ",
                            String( paramap ), "." );
    else
      return Concatenation( "the current indeterminateness is about 10^",
                            String( LogInt( paramap, 10 ) ), "." );
    fi;
end );


#############################################################################
##
#F  PrintAmbiguity( <list>, <paramap> ) . . . .  ambiguity of characters with
#F                                                       respect to a paramap
##
InstallGlobalFunction( PrintAmbiguity, function( list, paramap )
    local i, composition;
    for i in [ 1 .. Length( list ) ] do
      composition:= CompositionMaps( list[i], paramap );
      Print( i, " ", Indeterminateness( composition ), " ",
             Filtered( [ 1 .. Length( composition ) ],
                       x -> IsList( composition[x] ) ),
             "\n" );
    od;
end );


#############################################################################
##
#F  ContainedSpecialVectors( <tbl>, <chars>, <paracharacter>, <func> )
##
InstallGlobalFunction( ContainedSpecialVectors,
    function( tbl, chars, paracharacter, func )
    local i, j, x, classes, unknown, images, number, index, direction,
          pos, oldvalue, newvalue, norm, sum, possibilities, order;

    classes:= SizesConjugacyClasses( tbl );
    order:= Size( tbl );
    paracharacter:= ShallowCopy( paracharacter );
    unknown:= [];
    images:= [];
    number:= [];
    index:= [];
    direction:= [];
    pos:= 1;
    for i in [ 1 .. Length( paracharacter ) ] do
      if IsList( paracharacter[i] ) then
        unknown[pos]:= i;
        images[pos]:= paracharacter[i];
        number[pos]:= Length( paracharacter[i]);
        index[pos]:= 1;
        direction[pos]:= 1;               # 1 means up, -1 means down
        paracharacter[i]:= paracharacter[i][1];
        pos:= pos + 1;
      fi;
    od;
    sum:= classes * paracharacter;
    norm:= classes * List( paracharacter, x -> x * GaloisCyc( x, -1 ) );
    possibilities:= [];
    if IsInt( sum / order ) and IsInt( norm / order)
       and func( tbl, chars, paracharacter ) then
      possibilities[1]:= ShallowCopy( paracharacter );
    fi;
    i:= 1;
    while true do
      i:= 1;
      while i <= Length( unknown ) and
         ( ( index[i] = number[i] and direction[i] = 1 ) or
              ( index[i] = 1 and direction[i] = -1 ) ) do
        direction[i]:= - direction[i];
        i:= i+1;
      od;
      if Length( unknown ) < i then             # we are through
        return possibilities;
      else                                      # update at position i
        oldvalue:= images[i][ index[i] ];
        index[i]:= index[i] + direction[i];
        newvalue:= images[i][ index[i] ];
        sum:= sum + classes[ unknown[i] ] * ( newvalue - oldvalue );
        norm:= norm + classes[ unknown[i] ]
                * (   newvalue * GaloisCyc( newvalue, -1 )
                    - oldvalue * GaloisCyc( oldvalue, -1 ) );
        if IsInt( sum / order ) and IsInt( norm / order ) then
          for j in [ 1 .. Length( unknown ) ] do
            paracharacter[ unknown[j] ]:= images[j][ index[j] ];
          od;
          if func( tbl, chars, paracharacter ) then
            Add( possibilities, ShallowCopy( paracharacter ) );
          fi;
        fi;
      fi;
    od;
end );


#############################################################################
##
#F  IntScalarProducts( <tbl>, <chars>, <candidate> )
##
InstallGlobalFunction( IntScalarProducts, function( tbl, chars, candidate )
    local classes, order, weighted, i, char;

    classes:= SizesConjugacyClasses( tbl );
    order:= Size( tbl );
    weighted:= [];
    for i in [ 1 .. Length( candidate ) ] do
      weighted[i]:= classes[i] * candidate[i];
    od;
    for char in List( chars, ValuesOfClassFunction ) do
      if not IsInt( ( weighted * char ) / order ) then
        return false;
      fi;
    od;
    return true;
end );


#############################################################################
##
#F  NonnegIntScalarProducts( <tbl>, <chars>, <candidate> )
##
InstallGlobalFunction( NonnegIntScalarProducts,
    function( tbl, chars, candidate )
    local classes, order, weighted, i, char, sc;

    classes:= SizesConjugacyClasses( tbl );
    order:= Size( tbl );
    weighted:= [];
    for i in [ 1 .. Length( candidate ) ] do
      weighted[i]:= classes[i] * candidate[i];
    od;
    for char in List( chars, ValuesOfClassFunction ) do
      sc:= ( weighted * char ) / order;
      if ( not IsInt( sc ) ) or IsNegRat( sc ) then
        return false;
      fi;
    od;
    return true;
end );


#############################################################################
##
#F  ContainedPossibleVirtualCharacters( <tbl>, <chars>, <paracharacter> )
##
InstallGlobalFunction( ContainedPossibleVirtualCharacters,
    function( tbl, chars, paracharacter )
    return ContainedSpecialVectors( tbl, chars, paracharacter,
                                    IntScalarProducts );
end );


#############################################################################
##
#F  ContainedPossibleCharacters( <tbl>, <chars>, <paracharacter> )
##
InstallGlobalFunction( ContainedPossibleCharacters,
    function( tbl, chars, paracharacter )
    return ContainedSpecialVectors( tbl, chars, paracharacter,
                                    NonnegIntScalarProducts );
end );


#############################################################################
##
#F  StepModGauss( <matrix>, <moduls>, <nonzerocol>, <col> )
##
##  performs Gaussian elimination for column <col> of the matrix <matrix>,
##  where the entries of column `i' are taken modulo `<moduls>[i]',
##  and only those columns `i' with `<nonzerocol>[i] = true' (may) have
##  nonzero entries.
##
##  Afterwards the only row containing a nonzero entry in column <col> will
##  be the first row of <matrix>, and again Gaussian elimination is done
##  for that row and the row $\delta_{<'col'>}$;
##  if there is a row with nonzero entry in column <col> then this row is
##  returned, otherwise `fail' is returned.
##
BindGlobal( "StepModGauss",
    function( matrix, moduls, nonzerocol, col )
    local i, k, z, a, b, c, d, val, stepmodgauss;

    if IsEmpty( matrix ) then
      return fail;
    fi;
    matrix[1][col]:= matrix[1][col] mod moduls[col];
    for i in [ 2 .. Length( matrix ) ] do
      matrix[i][col]:= matrix[i][col] mod moduls[col];
      if matrix[i][col] <> 0 then
        # eliminate
        z:= Gcdex( matrix[1][ col ], matrix[i][col] );
        a:= z.coeff1; b:= z.coeff2; c:= z.coeff3; d:= z.coeff4;
        for k in [ 1 .. Length( nonzerocol ) ] do
          if nonzerocol[k] then
            val:= matrix[1][k];
            matrix[1][k]:= ( a * val + b * matrix[i][k] ) mod moduls[k];
            matrix[i][k]:= ( c * val + d * matrix[i][k] ) mod moduls[k];
          fi;
        od;
      fi;
    od;
    if matrix[1][col] = 0 then
      # col has only zero entries
      return fail;
    fi;
    z:= Gcdex( matrix[1][col], moduls[col] );
    a:= z.coeff1; b:= z.coeff2; c:= z.coeff3;
    stepmodgauss:= [];
    for i in [ 1 .. Length( nonzerocol ) ] do
      if nonzerocol[i] then
        stepmodgauss[i]:= ( a * matrix[1][i] ) mod moduls[i];
        matrix[1][i]:= ( c * matrix[1][i] ) mod moduls[i];
      else
        stepmodgauss[i]:= 0;
      fi;
    od;
    stepmodgauss[col]:= z.gcd;
    matrix[1][col]:= 0;
    return stepmodgauss;
end );


#############################################################################
##
#F  ModGauss( <matrix>, <moduls> )
##
##  <matrix> is transformed to an upper triangular matrix generating the same
##  lattice modulo that generated by
##  $\{<moduls>[i] \cdot \delta_i; 1 \leq i \leq \|<moduls>\|\}$.
##
##  <matrix> is changed, the triangular matrix is returned.
##
BindGlobal( "ModGauss", function( matrix, moduls )
    local i, modgauss, nonzerocol, row;

    modgauss:= [];
    nonzerocol:= List( moduls, ReturnTrue );
    for i in [ 1 .. Length( matrix[1] ) ] do
      row:= StepModGauss( matrix, moduls, nonzerocol, i );
      if row <> fail then
        Add( modgauss, row );
      fi;
      nonzerocol[i]:= false;
    od;
    return modgauss;
end );


#############################################################################
##
#F  ContainedDecomposables( <constituents>, <moduls>, <parachar>, <func> )
##
InstallGlobalFunction( ContainedDecomposables,
    function( constituents, moduls, parachar, func )
    local i, x, matrix, fusion, newmoduls, candidate,
          nonzerocol,
          possibilities,   # global list of all $\chi$
                           # that satisfy $'func'( \chi )$
          images,
          uniques,
          nccl, min_anzahl, min_class, erase_uniques, impossible,
          evaluate, remain, ncha, pos, fusionperm, newimages, oldrows,
          newmatrix, step, erster, descendclass, j, row, oldimages;

    # Step 1: Check and improve the input (identify equal columns).

    if IsList( parachar[1] ) then
      # (necessary if no class is unique)
      min_anzahl:= Length( parachar[1] );
      min_class:= 1;
    fi;
    matrix:= CollapsedMat( constituents, [ ] );
    fusion:= matrix.fusion;
    matrix:= matrix.mat;
    newmoduls:= [];
    for i in [ 1 .. Length( fusion ) ] do
      if IsBound( newmoduls[ fusion[i] ] ) then
        newmoduls[ fusion[i] ]:= Maximum( newmoduls[ fusion[i] ],
                                          moduls[i] );
      else
        newmoduls[ fusion[i] ]:= moduls[i];
      fi;
    od;
    moduls:= newmoduls;
    nccl:= Length( moduls );
    candidate:= [];
    nonzerocol:= [];
    for i in [ 1 .. nccl ] do
      candidate[i]:= 0;
      nonzerocol[i]:= true;
    od;
    possibilities:= [];
    images:= [];
    uniques:= [];
    for i in [ 1 .. Length( fusion ) ] do
      if IsInt( parachar[i] ) then
        if ( IsBound( images[ fusion[i] ] ) ) then
          if IsInt( images[ fusion[i] ] ) and
             parachar[i] <> images[ fusion[i] ] then
            return [];
          elif IsList( images[ fusion[i] ] ) then
            if not parachar[i] in images[ fusion[i] ] then
              return [];
            else
              images[ fusion[i] ]:= parachar[i];
              AddSet( uniques, fusion[i] );
            fi;
          fi;
        else
          images[ fusion[i] ]:= parachar[i];
          AddSet( uniques, fusion[i] );
        fi;
      else            # IsList( parachar[i] )
        if not IsBound( images[ fusion[i] ] ) then
          images[ fusion[i] ]:= parachar[i];
        elif IsInt( images[ fusion[i] ] ) then
          if not images[ fusion[i] ] in parachar[i] then
            return [];
          fi;
        else          # IsList
          images[ fusion[i] ]:=
                      Intersection2( parachar[i], images[ fusion[i] ] );
#T IntersectSet !
          if IsEmpty( images[ fusion[i] ] ) then
            return [];
          elif Length( images[fusion[i]] ) = 1 then
            images[ fusion[i] ]:= images[ fusion[i] ][1];
            AddSet( uniques, fusion[i] );
          fi;
        fi;
      fi;
    od;

    # Step 2: first elimination before backtrack

    erase_uniques:= function( uniques, nonzerocol, candidate, images )

      # eliminate all columns in `uniques', adjust `nonzerocol',
      # then look if other columns become unique or if a contradiction
      # occurs;
      # also look at which column the least number of values is left

      local i, j, abgespalten, col, row, quot, val, ggt, a, b, k, u,
            firstallowed, step, gencharacter, newvalues;

      abgespalten:= [];
      while not IsEmpty( uniques ) do
        for col in uniques do
          candidate[col]:= ( candidate[col] + images[col] ) mod moduls[col];
          row:= StepModGauss( matrix, moduls, nonzerocol, col );
          if row <> fail then
            abgespalten[ Length( abgespalten ) + 1 ]:= row;
#T Add !
            if candidate[ col ] mod row[ col ] <> 0 then
              impossible:= true;
              return abgespalten;
            fi;
            quot:= candidate[col] / row[col];
            for j in [ 1 .. nccl ] do
              if nonzerocol[j] then
                candidate[j]:= ( candidate[j] - quot * row[j] )
                               mod moduls[j];
              fi;
            od;
          elif candidate[ col ] <> 0 then
            impossible:= true;
            return abgespalten;
          fi;
          nonzerocol[ col ]:= false;
        od;

        min_anzahl:= infinity;
        uniques:= [];
        for i in [ 1 .. nccl ] do
          if nonzerocol[i] then
            val:= moduls[i];
            for j in [ 1 .. Length( matrix ) ] do
              # zero column iff val = moduls[i]
              val:= GcdInt( val, matrix[j][i] );
            od;

      # update lists of image

            newvalues:= [];
            for j in images[i] do
              if ( candidate[i] + j ) mod val = 0 then
                AddSet( newvalues, j );
              fi;
            od;
            if IsEmpty( newvalues ) then             # contradiction
              impossible:= true;
              return abgespalten;
            elif Length( newvalues ) = 1 then        # unique
              images[i]:= newvalues[1];
              AddSet( uniques, i );
            else
              images[i]:= newvalues;
              if Length( newvalues ) < min_anzahl then
                min_anzahl:= Length( newvalues );
                min_class:= i;
              fi;
            fi;
          fi;
        od;
      od;
      if min_anzahl = infinity then
        gencharacter:= images{ fusion };
        if func( gencharacter ) then
          Add( possibilities, gencharacter );
        fi;
        impossible:= true;
      else
        impossible:= false;
      fi;
      return abgespalten;
      # impossible = true: calling function will return from backtrack
      # impossible = false: then min_class < infinity, and images[min_class]
      #                     contains the info for descending at min_class
    end;

    erase_uniques( uniques, nonzerocol, candidate, images );
    if impossible then
      return possibilities;
    fi;

    # Step 3: Collapse the matrix.

    remain:= Filtered( [ 1 .. nccl ], x -> nonzerocol[x] );
    for i in [ 1 .. Length( matrix ) ] do
      matrix[i]:= matrix[i]{ remain };
    od;
    candidate  := candidate{ remain };
    nonzerocol := nonzerocol{ remain };
    moduls     := moduls{ remain };
    matrix     := ModGauss( matrix, moduls );

    ncha:= Length( matrix );
    pos:= 1;
    fusionperm:= [];
    newimages:= [];
    for i in remain do
      fusionperm[ i ]:= pos;
      if IsBound( images[i] ) then
        newimages[ pos ]:= images[i];
      fi;
      pos:= pos + 1;
    od;
    min_class:= fusionperm[ min_class ];
    for i in Difference( [ 1 .. nccl ], remain ) do
      fusionperm[i]:= pos;
      newimages[ pos ]:= images[i];
      pos:= pos + 1;
    od;
    images:= newimages;
    fusion:= CompositionMaps( fusionperm, fusion );
    nccl:= Length( nonzerocol );

    # Step 4: Backtrack

    evaluate:= function( candidate, nonzerocol, uniques, images )

      local i, j, col, val, row, quot, abgespalten, step, erster,
            descendclass, oldimages;

      abgespalten:= erase_uniques( [ uniques ],
                                   nonzerocol,
                                   candidate,
                                   images );
      if impossible then
        return abgespalten;
      fi;
      descendclass:= min_class;
      oldimages:= images[ descendclass ];
      for i in [ 1 .. min_anzahl ] do
        images[ descendclass ]:= oldimages[i];
        oldrows:= evaluate( ShallowCopy( candidate ),
                            ShallowCopy( nonzerocol ),
                            descendclass,
                            ShallowCopy( images ) );
        Append( matrix, oldrows );
        if Length( matrix ) > ( 3 * ncha ) / 2 then
          newmatrix:= [];
          # matrix:= ModGauss( matrix, moduls );
          for j in [ 1 .. Length( matrix[1] ) ] do
            if nonzerocol[j] then
              row:= StepModGauss( matrix, moduls, nonzerocol, j );
              if row <> fail then
                Add( newmatrix, row );
              fi;
            fi;
          od;
          matrix:= newmatrix;
        fi;
      od;
      return abgespalten;
    end;

    descendclass:= min_class;
    oldimages:= images[ descendclass ];
    for i in [ 1 .. min_anzahl ] do
      images[ descendclass ]:= oldimages[i];
      oldrows:= evaluate( ShallowCopy( candidate ),
                          ShallowCopy( nonzerocol ),
                          descendclass,
                          ShallowCopy( images ) );
      Append( matrix, oldrows );
      if Length( matrix ) > ( 3 * ncha ) / 2 then
        newmatrix:= [];
        # matrix:= ModGauss( matrix, moduls );
        for j in [ 1 .. Length( matrix[1] ) ] do
          if nonzerocol[j] then
            row:= StepModGauss( matrix, moduls, nonzerocol, j );
            if row <> fail then
              Add( newmatrix, row );
            fi;
          fi;
        od;
        matrix:= newmatrix;
      fi;
    od;
    return possibilities;
end );


#############################################################################
##
#F  ContainedCharacters( <tbl>, <constituents>, <parachar> )
##
InstallGlobalFunction( ContainedCharacters,
    function( tbl, constituents, parachar )
    local degree;
    degree:= parachar[1];
    if IsInt( degree ) then
      constituents:= Filtered( constituents, chi -> chi[1] <= degree );
    fi;
    return ContainedDecomposables(
               constituents,
               SizesCentralizers( tbl ),
               parachar,
               chi -> NonnegIntScalarProducts( tbl, constituents, chi ) );
end );


#############################################################################
##
##  5. Subroutines for the Construction of Power Maps
##


#############################################################################
##
#F  InitPowerMap( <tbl>, <prime>[, <useorders>] )
##
InstallGlobalFunction( InitPowerMap, function( arg )
    local tbl, prime, useorders,
          i, j, k,        # loop variables
          powermap,       # power map for prime `prime', result
          centralizers,   # centralizer orders of `tbl'
          nccl,           # number of conjugacy classes of `tbl'
          orders,         # representative orders of `tbl' (if bound)
          sameord;        # contains at position <i> the list of those
                          # classes that (may) have representative order <i>

    tbl:= arg[1];
    prime:= arg[2];
    if IsBound( arg[3] ) then
      useorders:= arg[3];
    else
      useorders:= true;
    fi;
    powermap:= [];
    centralizers:= SizesCentralizers( tbl );
    nccl:= Length( centralizers );

    if useorders and ( IsCharacterTable( tbl )
                       or HasOrdersClassRepresentatives( tbl ) ) then

      # Both element orders and centralizer orders are available.
      # Construct the list `sameord'.
      orders:= OrdersClassRepresentatives( tbl );
      sameord:= [];

      for i in [ 1 .. Length( orders ) ] do
        if IsInt( orders[i] ) then
          if IsBound( sameord[ orders[i] ] ) then
            AddSet( sameord[ orders[i] ], i );
          else
            sameord[ orders[i] ]:= [ i ];
          fi;
        else
          # parametrized orders
          for j in orders[i] do
            if IsBound( sameord[j] ) then
              AddSet( sameord[j], i );
            else
              sameord[j]:= [ i ];
            fi;
          od;
        fi;
      od;

      for i in [ 1 .. nccl ] do

        powermap[i]:= [];

        if IsInt( orders[i] ) then

          if orders[i] mod prime = 0 then

            # maps to a class with representative order that is smaller
            # by a factor `prime'
            for j in sameord[ orders[i] / prime ] do
              if centralizers[j] mod centralizers[i] = 0 then
                AddSet( powermap[i], j );
              fi;
            od;

          elif prime mod orders[i] = 1 then

            # necessarily fixed class
            powermap[i][1]:= i;

          else

            # maps to a class of same order
            for j in sameord[ orders[i] ] do
              if centralizers[j] = centralizers[i] then
                AddSet( powermap[i], j );
              fi;
            od;

          fi;

        else

          # representative order is not uniquely determined
          for j in orders[i] do

            if j mod prime = 0 then

              # maps to a class with representative order that is smaller
              # by a factor `prime'
              if IsBound( sameord[ j / prime ] ) then
                for k in sameord[ j / prime ] do
                  if centralizers[k] mod centralizers[i] = 0 then
                    AddSet( powermap[i], k );
                  fi;
                od;
              fi;

            elif prime mod j = 1 then

              # necessarily fixed class
              AddSet( powermap[i], i );

            else

              # maps to a class of same order
              for k in sameord[j] do
                if centralizers[k] = centralizers[i] then
                  AddSet( powermap[i], k );
                fi;
              od;

            fi;
          od;

          if Gcd( orders[i] ) mod prime = 0 then

            # necessarily the representative order of the image is smaller
            RemoveSet( powermap[i], i );

          fi;
        fi;
      od;

    else

      # Just centralizer orders are known.
      for i in [ 1 .. nccl ] do
        powermap[i]:= [];
        for j in [ 1 .. nccl ] do
          if centralizers[j] mod centralizers[i] = 0 then
            AddSet( powermap[i], j );
          fi;
        od;
      od;

    fi;

    # Check whether a map is possible, and replace image lists of length 1
    # by their entry.
    for i in [ 1 .. nccl ] do
      if   Length( powermap[i] ) = 0 then
        Info( InfoCharacterTable, 2,
              "InitPowerMap: no image possible for classes\n",
              "#I  ", Filtered( [ 1 .. nccl ], x -> powermap[x] = [] ) );
        return fail;
      elif Length( powermap[i] ) = 1 then
        powermap[i]:= powermap[i][1];
      fi;
    od;

    # If the representative orders are not uniquely determined,
    # and the centre is not trivial, the image of class 1 is not uniquely
    # determined by the check of centralizer orders.
    if ( IsInt( powermap[1] ) and powermap[1] <> 1 ) or
       ( IsList( powermap[1] ) and not 1 in powermap[1] ) then
      Info( InfoCharacterTable, 2,
            "InitPowerMap: class 1 cannot contain the identity" );
      return fail;
    fi;
    powermap[1]:= 1;

    return powermap;
end );


#############################################################################
##
#F  Congruences( <tbl>, <chars>, <prime_powermap>, <prime>, <quick> )
##
InstallGlobalFunction( Congruences, function( arg )
#T more restrictive implementation!
    local i, j,
          tbl,       # character table, first argument
          chars,     # list of characters, second argument
          powermap,  #
          prime,     #
          nccl,
          omega,
          hasorders,
          orders,
          images,
          newimage,
          cand_image,
          ok,
          char,
          errors;    # list of classes for that no images are possible

    # Check the arguments.
    if not ( Length( arg ) in [ 4, 5 ] and IsNearlyCharacterTable( arg[1] )
             and IsList(arg[2]) and IsList(arg[3]) and IsPrimeInt(arg[4]) )
       or ( Length( arg ) = 5
             and arg[5] <> "quick" and not IsBool( arg[5] ) ) then
      Error("usage: Congruences(tbl,chars,powermap,prime,\"quick\")\n",
            " resp. Congruences(tbl,chars,powermap,prime)" );
    fi;

    # Get the arguments.
    tbl:= arg[1];
    chars:= arg[2];
    powermap:= arg[3];
    prime:= arg[4];

    nccl:= Length( powermap );
    omega:= [ 1 .. nccl ];
    if Length( arg ) = 5 and ( arg[5] = "quick" or arg[5] = true ) then
      # "quick": only consider ambiguous classes
      for i in [ 1 .. nccl ] do
        if IsInt( powermap[i] ) or Length( powermap[i] ) <= 1 then
          RemoveSet( omega, i );
        fi;
      od;
    fi;

    # Are element orders available?
    hasorders:= false;
    if IsCharacterTable( tbl ) or HasOrdersClassRepresentatives( tbl ) then
      hasorders:= true;
      orders:= OrdersClassRepresentatives( tbl );
    fi;

    for i in omega do
      if IsInt( powermap[i] ) then
        images:= [ powermap[i] ];
      else
        images:= powermap[i];
      fi;
      newimage:= [];
      for cand_image in images do
        j:= 1;
        ok:= true;
        while ok and j <= Length( chars ) do   # loop over characters
          char:= chars[j];
          if     not IsUnknown( char[ cand_image ] )
             and not IsUnknown( char[i] ) then
            if char[1] = 1 then
              if char[i]^prime <> char[ cand_image ] then
                ok:= false;
              fi;
            elif IsInt( char[i] ) then
              if not IsCycInt( ( char[ cand_image ] - char[i] ) / prime ) then
                ok:= false;
              fi;
            elif IsCyc( char[i] ) then
              if hasorders
                 and ( ( IsInt( orders[i] ) and orders[i] mod prime <> 0 )
                     or ( IsList( orders[i] ) and ForAll( orders[i],
                                       x -> x mod prime <> 0 ) ) ) then
                if char[ cand_image ] <> GaloisCyc( char[i], prime ) then
                  ok:= false;
                fi;
              elif not IsCycInt( ( char[ cand_image ]
                                 - GaloisCyc(char[i],prime) ) / prime ) then
                ok:= false;
              fi;
            fi;
          fi;
          j:= j+1;
        od;
        if ok then
          AddSet( newimage, cand_image );
        fi;
      od;
      powermap[i]:= newimage;
    od;

    # Replace lists of length 1 by their entries,
    # look for empty lists.
    errors:= [];
    for i in omega do
      if   IsEmpty( powermap[i] ) then
        Add( errors, i );
      elif Length( powermap[i] ) = 1 then
        powermap[i]:= powermap[i][1];
      fi;
    od;
    if not IsEmpty( errors ) then
      Info( InfoCharacterTable, 1,
            "Congruences(.,.,.,", prime,
            "): no image possible for classes ", errors );
      return false;
    fi;
    return true;
end );


#############################################################################
##
#F  ConsiderKernels( <tbl>, <chars>, <prime_powermap>, <prime>, <quick> )
##
InstallGlobalFunction( ConsiderKernels, function( arg )
#T more restrictive implementation!
    local i,
          tbl,
          tbl_size,
          chars,
          prime_powermap,
          prime,
          nccl,
          omega,
          kernels,
          chi,
          kernel,
          suborder;

    if not ( Length( arg ) in [ 4, 5 ] and IsOrdinaryTable( arg[1] ) and
             IsList( arg[2] ) and IsList( arg[3] ) and IsPrimeInt( arg[4] ) )
       or ( Length( arg ) = 5
             and arg[5] <> "quick" and not IsBool( arg[5] ) ) then
      Error("usage: ConsiderKernels( tbl, chars, prime_powermap, prime )\n",
           "resp. ConsiderKernels(tbl,chars,prime_powermap,prime,\"quick\")");
    fi;

    tbl:= arg[1];
    tbl_size:= Size( tbl );
    chars:= arg[2];
    prime_powermap:= arg[3];
    prime:= arg[4];
    nccl:= Length( prime_powermap );
    omega:= Set( [ 1 .. nccl ] );
    kernels:= [];
    for chi in chars do
      AddSet( kernels, ClassPositionsOfKernel( chi ) );
    od;
    RemoveSet( kernels, omega );
    RemoveSet( kernels, [ 1 ] );

    if Length( arg ) = 5 and ( arg[5] = "quick" or arg[5] = true ) then
      # "quick": only consider ambiguous classes
      omega:= [];
      for i in [ 1 .. nccl ] do
        if IsList(prime_powermap[i]) and Length( prime_powermap[i] ) > 1 then
          AddSet( omega, i );
        fi;
      od;
    fi;
    for kernel in kernels do
      suborder:= Sum( SizesConjugacyClasses( tbl ){ kernel }, 0 );
      if tbl_size mod suborder <> 0 then
        Info( InfoCharacterTable, 2,
              "ConsiderKernels: kernel of character is not a", " subgroup" );
        return false;
      fi;
      for i in Intersection( omega, kernel ) do
        if IsList( prime_powermap[i] ) then
          prime_powermap[i]:= Intersection( prime_powermap[i], kernel );
        else
          prime_powermap[i]:= Intersection( [ prime_powermap[i] ], kernel );
        fi;
        if Length( prime_powermap[i] ) = 1 then
          prime_powermap[i]:= prime_powermap[i][1];
        fi;
      od;
      if ( tbl_size / suborder ) mod prime <> 0 then
        for i in Difference( omega, kernel ) do
          if IsList( prime_powermap[i] ) then
            prime_powermap[i]:= Difference( prime_powermap[i], kernel );
          else
            prime_powermap[i]:= Difference( [ prime_powermap[i] ], kernel );
          fi;
          if Length( prime_powermap[i] ) = 1 then
            prime_powermap[i]:= prime_powermap[i][1];
          fi;
        od;
      elif ( tbl_size / suborder ) = prime then
        for i in Difference( omega, kernel ) do
          if IsList( prime_powermap[i] ) then
            prime_powermap[i]:= Intersection( prime_powermap[i], kernel );
          else
            prime_powermap[i]:= Intersection( [ prime_powermap[i] ], kernel );
          fi;
          if Length( prime_powermap[i] ) = 1 then
            prime_powermap[i]:= prime_powermap[i][1];
          fi;
        od;
      fi;
    od;
    if ForAny( prime_powermap, x -> x = [] ) then
      Info( InfoCharacterTable, 2,
            "ConsiderKernels: no images left for classes ",
                      Filtered( [ 1 .. Length( prime_powermap ) ],
                                x -> prime_powermap[x] = [] ) );
      return false;
    fi;
    return true;
end );


#############################################################################
##
#F  ConsiderSmallerPowerMaps( <tbl>, <prime_powermap>, <prime>, <quick> )
##
InstallGlobalFunction( ConsiderSmallerPowerMaps, function( arg )
#T more restrictive implementation!
    local i, j,            # loop variables
          tbl,             # character table
          tbl_orders,      #
          tbl_powermap,    #
          prime_powermap,  # 2nd argument
          prime,           # 3rd argument
          omega,           # list of classes to be tested
          factors,         # factors modulo representative order
          image,           # possible images after testing
          old,             # possible images before testing
          errors;          # list of classes where no image is possible

    # check the arguments
    if not ( Length( arg ) in [ 3, 4 ] and IsNearlyCharacterTable( arg[1] )
             and IsList( arg[2] ) and IsPrimeInt( arg[3] ) )
       or ( Length( arg ) = 4
             and arg[4] <> "quick" and not IsBool( arg[4] ) ) then
      Error( "usage: ",
        "ConsiderSmallerPowerMaps(<tbl>,<prime_powermap>,<prime>) resp.\n",
        "ConsiderSmallerPowerMaps(<tbl>,<prime_powermap>,<prime>,\"quick\")");
    fi;

    tbl:= arg[1];
    if not (    IsCharacterTable( tbl )
             or HasOrdersClassRepresentatives( tbl ) ) then
      Info( InfoCharacterTable, 2,
            "ConsiderSmallerPowerMaps: no element orders bound, no test" );
      return true;
    fi;
    tbl_orders:= OrdersClassRepresentatives( tbl);
    tbl_powermap:= ComputedPowerMaps( tbl);
    prime_powermap:= arg[2];
    prime:= arg[3];

    # `omega' will be a list of classes to be tested
    omega:= [];

    if Length( arg ) = 4 and ( arg[4] = "quick" or arg[4] = true ) then

      # `quick' option: only test classes with ambiguities
      for i in [ 1 .. Length( prime_powermap ) ] do
        if IsList( prime_powermap[i] ) and prime > tbl_orders[i] then
          Add( omega, i );
        fi;
      od;

    else

      # test all classes where reduction modulo representative orders
      # can yield conditions
      for i in [ 1 .. Length( prime_powermap ) ] do
        if prime > tbl_orders[i] then Add( omega, i ); fi;
      od;

    fi;

    # list of classes where no image is possible
    errors:= [];

    for i in omega do

      factors:= Factors(Integers, prime mod tbl_orders[i] );
      if factors = [ 1 ] or factors = [ 0 ] then factors:= []; fi;

      if ForAll( Set( factors ), x -> IsBound( tbl_powermap[x] ) ) then

        # compute image under composition of power maps for smaller primes
        image:= [ i ];
        for j in factors do
          image:= [ CompositionMaps( tbl_powermap[j], image, 1 ) ];
        od;
        image:= image[1];

        # `old': possible images before testing
        if IsInt( prime_powermap[i] ) then
          old:= [ prime_powermap[i] ];
        else
          old:= prime_powermap[i];
        fi;

        # compare old and new possibilities of images
        if IsInt( image ) then
          if image in old then
            prime_powermap[i]:= image;
          else
            Add( errors, i );
            prime_powermap[i]:= [];
          fi;
        else
          image:= Intersection2( image, old );
          if image = [] then
            Add( errors, i );
            prime_powermap[i]:= [];
          elif old <> image then
            if Length( image ) = 1 then image:= image[1]; fi;
            prime_powermap[i]:= image;
          fi;
        fi;

      fi;

    od;

    if Length( errors ) <> 0 then
      Info( InfoCharacterTable, 2,
            "ConsiderSmallerPowerMaps: no image possible for classes ",
            errors );
      return false;
    fi;

    return true;
end );


#############################################################################
##
#F  MinusCharacter( <character>, <prime_powermap>, <prime> )
##
InstallGlobalFunction( MinusCharacter,
    function( character, prime_powermap, prime )
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
end );


#############################################################################
##
#F  PowerMapsAllowedBySymmetrizations( <tbl>, <subchars>, <chars>, <pow>,
#F                                     <prime>, <parameters> )
##
InstallGlobalFunction( PowerMapsAllowedBySymmetrizations,
    function( tbl, subchars, chars, pow, prime, parameters )
    local i, j, x, indeterminateness, numbofposs, lastimproved, minus, indet,
          poss, param, remain, possibilities, improvemap, allowedmaps, rat,
          powerchars, maxlen, contained, minamb, maxamb, quick;

    if IsEmpty( chars ) then
      return [ pow ];
    fi;

    chars:= Set( chars );

    # but maybe there are characters with equal restrictions ...

    # record `parameters':
    if not IsRecord( parameters ) then
      Error( "<parameters> must be a record with components `maxlen',\n",
             "`contained', `minamb', `maxamb', and `quick'" );
    fi;

    maxlen:= parameters.maxlen;
    contained:= parameters.contained;
    minamb:= parameters.minamb;
    maxamb:= parameters.maxamb;
    quick:= parameters.quick;

    if quick and Indeterminateness( pow ) < minamb then # immediately return
      Info( InfoCharacterTable, 2,
            "PowerMapsAllowedBySymmetrizations: ",
            " indeterminateness of the map\n",
            "#I    is smaller than the parameter value",
            " `minamb'; returned" );
      return [ pow ];
    fi;

    # step 1: check all in <chars>; if one has too big indeterminateness
    #         and contains irrational entries, append its rationalized
    #         character to <chars>.
    indeterminateness:= []; # at pos. i the indeterminateness of character i
    numbofposs:= [];        # at pos. `i' the number of allowed restrictions
                            # for `<chars>[i]'
    lastimproved:= 0;       # last char which led to an improvement of `pow';
                            # every run through the list may stop at this char
    powerchars:= [];        # at position `i' the <prime>-th power of
                            # `<chars>[i]'
    i:= 1;
    while i <= Length( chars ) do
      powerchars[i]:= List( chars[i], x -> x ^ prime );
      minus:= MinusCharacter( chars[i], pow, prime );
      indet:= Indeterminateness( minus );
      indeterminateness[i]:= indet;
      if indet = 1 then
        if not quick
           and not NonnegIntScalarProducts( tbl, subchars, minus ) then
          return [];
        fi;
      elif indet < minamb then
        indeterminateness[i]:= 1;
      elif indet <= maxamb then
        poss:= contained( tbl, subchars, minus );
        if poss = [] then return []; fi;
        numbofposs[i]:= Length( poss );
        param:= Parametrized( poss );
        if param <> minus then  # improvement found
          UpdateMap( chars[i], pow, List( [ 1 .. Length( powerchars[i] ) ],
                             x-> powerchars[i][x] - prime * param[x] ) );
          lastimproved:= i;
          indeterminateness[i]:= Indeterminateness(
                                        CompositionMaps( chars[i], pow ) );
        fi;
      else
        numbofposs[i]:= infinity;
        if ForAny( chars[i], x -> IsCyc(x) and not IsRat(x) ) then

          # maybe the indeterminateness of the rationalized character is
          # smaller but not 1
          rat:= RationalizedMat( [ chars[i] ] )[1];
          if not rat in chars then Add( chars, rat ); fi;
        fi;
      fi;
      i:= i + 1;
    od;
    if lastimproved > 0 then
      indeterminateness[ lastimproved ]:=
            Indeterminateness( CompositionMaps( chars[lastimproved], pow ) );
    fi;

    # step 2: (local function `improvemap')
    #         loop over characters until no improvement is possible without a
    #         branch; update `indeterminateness' and `numbofposs';
    #         first character to test is at position `first'; at least run up
    #         to character $'lastimproved' - 1$, update `lastimproved' if an
    #         improvement occurs; return `false' in the case of an
    #         inconsistency, `true' otherwise.
    improvemap:= function( chars, pow, first, lastimproved,
                           indeterminateness, numbofposs, powerchars )
    local i, x, poss;
    i:= first;
    while i <> lastimproved do
      if indeterminateness[i] <> 1 then
        minus:= MinusCharacter( chars[i], pow, prime );
        indet:= Indeterminateness( minus );
        if indet < indeterminateness[i] then

          # only test those chars which now have smaller indeterminateness
          indeterminateness[i]:= indet;
          if indet = 1 then
            if not quick
               and not NonnegIntScalarProducts( tbl, subchars, minus ) then
              return false;
            fi;
          elif indet < minamb then
            indeterminateness[i]:= 1;
          elif indet <= maxamb then
            poss:= contained( tbl, subchars, minus );
            if poss = [] then return false; fi;
            numbofposs[i]:= Length( poss );
            param:= Parametrized( poss );
            if param <> minus then  # improvement found
              UpdateMap( chars[i], pow,
                         List( [ 1 .. Length( param ) ],
                               x -> powerchars[i][x] - prime * param[x] ) );
              lastimproved:= i;
              indeterminateness[i]:= Indeterminateness(
                                        CompositionMaps( chars[i], pow ) );
            fi;
          fi;
        fi;
      fi;
      if lastimproved = 0 then lastimproved:= i; fi;
      i:= i mod Length( chars ) + 1;
    od;
    indeterminateness[ lastimproved ]:=
            Indeterminateness( CompositionMaps( chars[lastimproved], pow ) );
    return true;
    end;

    # step 3: recursion; (local function `allowedmaps')
    #         a) delete all characters which now have indeterminateness 1;
    #            their minus-characters (with respect to every powermap that
    #            will be found ) have nonnegative scalar products with
    #            <subchars>.
    #         b) branch according to a significant character or class
    #         c) for each possibility call `improvemap' and then the recursion

    allowedmaps:= function( chars, pow, indeterminateness, numbofposs,
                            powerchars )
    local i, j, class, possibilities, poss, newpow, newindet,
          newnumbofposs, copy;
    remain:= Filtered( [ 1 .. Length(chars) ], i->indeterminateness[i] > 1 );
    chars:=             chars{ remain };
    indeterminateness:= indeterminateness{ remain };
    numbofposs:=        numbofposs{ remain };
    powerchars:=        powerchars{ remain };

    if IsEmpty( chars ) then
      Info( InfoCharacterTable, 2,
            "PowerMapsAllowedBySymmetrizations: no character",
            " with indeterminateness\n",
            "#I    between ", minamb, " and ", maxamb, " significant now" );
      return [ pow ];
    fi;
    possibilities:= [];
    if Minimum( numbofposs ) < maxlen then
      # branch according to a significant character
      # with minimal number of possible restrictions
      i:= Position( numbofposs, Minimum( numbofposs ) );
      Info( InfoCharacterTable, 2,
            "PowerMapsAllowedBySymmetrizations: branch at character\n",
            "#I     ", CharacterString( chars[i], "" ),
            " (", numbofposs[i], " calls)" );
      poss:= contained( tbl, subchars,
                        MinusCharacter( chars[i], pow, prime ) );
      for j in poss do
        newpow:= List( pow, ShallowCopy );
        UpdateMap( chars[i], newpow, powerchars[i] - prime * j );
        newindet:= List( indeterminateness, ShallowCopy );
        newnumbofposs:= List( numbofposs, ShallowCopy );
#T really this way to replace 'Copy' ?
        if improvemap( chars, newpow, i, 0, newindet, newnumbofposs,
                       powerchars ) then
          Append( possibilities,
                  allowedmaps( chars, newpow, newindet, newnumbofposs,
                               ShallowCopy( powerchars ) ) );
        fi;
      od;
      Info( InfoCharacterTable, 2,
            "PowerMapsAllowedBySymmetrizations: return from",
            " branch at character\n",
            "#I     ", CharacterString( chars[i], "" ),
            " (", numbofposs[i], " calls)" );
    else

      # branch according to a significant class in a
      # character with minimal nontrivial indet.
      i:= Position( indeterminateness, Minimum( indeterminateness ) );
                             # always nontrivial indet.!
      minus:= MinusCharacter( chars[i], pow, prime );
      class:= 1;
      while not IsList( minus[ class ] ) do class:= class + 1; od;

      Info( InfoCharacterTable, 2,
            "PowerMapsAllowedBySymmetrizations: ",
            "branch at class ",
            class, " (", Length( pow[ class ] ), " calls)" );

      # too many calls!!
      # (only those were necessary which are different for minus)

      for j in pow[ class ] do
        newpow:= List( pow, ShallowCopy );
        newpow[ class ]:= j;
        copy:= ShallowCopy( ComputedPowerMaps( tbl ) );
        Unbind( copy[ prime ] );
        if TestConsistencyMaps( copy, newpow, copy ) then
          newindet:= List( indeterminateness, ShallowCopy );
          newnumbofposs:= List( numbofposs, ShallowCopy );
#T really?
          if improvemap( chars, newpow, i, 0, newindet, newnumbofposs,
                         powerchars ) then
            Append( possibilities,
                    allowedmaps( chars, newpow, newindet, newnumbofposs,
                                 ShallowCopy( powerchars ) ) );
          fi;
        fi;
      od;

      Info( InfoCharacterTable, 2,
            "PowerMapsAllowedBySymmetrizations: return from branch at class ",
            class );

    fi;
    return possibilities;
    end;

    # start of the recursion:

    if lastimproved <> 0 then              # after step 1
      if not improvemap( chars, pow, 1, lastimproved, indeterminateness,
                         numbofposs, powerchars ) then
        return [];
      fi;
    fi;
    return allowedmaps( chars, pow, indeterminateness, numbofposs,
                        powerchars );
end );


#############################################################################
##
##  6. Subroutines for the Construction of Class Fusions
##


#############################################################################
##
#F  InitFusion( <subtbl>, <tbl> )
##
InstallGlobalFunction( InitFusion, function( subtbl, tbl )
    local subcentralizers,
          subclasses,
          subsize,
          centralizers,
          classes,
          initfusion,
          upper,
          i, j,
          orders,
          suborders,
          sameord,
          elm,
          choice;

    # Check the arguments.
    if not ( IsNearlyCharacterTable( subtbl ) and
             IsNearlyCharacterTable( tbl ) ) then
      Error( "<subtbl>, <tbl> must be nearly character tables" );
    fi;

    subcentralizers:= SizesCentralizers( subtbl );
    subclasses:= SizesConjugacyClasses( subtbl );
    subsize:= Size( subtbl );
    centralizers:= SizesCentralizers( tbl );
    classes:= SizesConjugacyClasses( tbl );

    initfusion:= [];
    upper:= [ 1 ]; # upper[i]: upper bound for the number of elements
                   # fusing in class i

    for i in [ 2 .. Length( centralizers ) ] do
      upper[i]:= Minimum( subsize, classes[i] );
    od;

    if     ( IsCharacterTable( subtbl )
             or HasOrdersClassRepresentatives( subtbl ) )
       and ( IsCharacterTable( tbl )
             or HasOrdersClassRepresentatives( tbl ) ) then

      # Element orders are available.
      orders   := OrdersClassRepresentatives( tbl );
      suborders:= OrdersClassRepresentatives( subtbl );
      sameord:= [];
      for i in [ 1 .. Length( orders ) ] do
        if IsInt( orders[i] ) then
          if IsBound( sameord[ orders[i] ] ) then
            AddSet( sameord[ orders[i] ], i );
          else
            sameord[ orders[i] ]:= [ i ];
          fi;
        else                 # para-orders
          for j in orders[i] do
            if IsBound( sameord[j] ) then
              AddSet( sameord[j], i );
            else
              sameord[j]:= [ i ];
            fi;
          od;
        fi;
      od;

      for i in [ 1 .. Length( suborders) ] do
        initfusion[i]:= [];
        if IsInt( suborders[i] ) then
          if not IsBound( sameord[ suborders[i] ] ) then
            Info( InfoCharacterTable, 2,
                  "InitFusion: no fusion possible because of ",
                  "representative orders" );
            return fail;
          fi;
          for j in sameord[ suborders[i] ] do
            if centralizers[j] mod subcentralizers[i] = 0 and
                                    upper[j] >= subclasses[i] then
              AddSet( initfusion[i], j );
            fi;
          od;
        else                 # para-orders
          choice:= Filtered( suborders[i], x -> IsBound( sameord[x] ) );
          if choice = [] then
            Info( InfoCharacterTable, 2,
                  "InitFusion: no fusion possible because of ",
                  "representative orders" );
            return fail;
          fi;
          for elm in choice do
            for j in sameord[ elm ] do
              if centralizers[j] mod subcentralizers[i] = 0 then
                AddSet( initfusion[i], j );
              fi;
            od;
          od;
        fi;
        if IsEmpty( initfusion[i] ) then
          Info( InfoCharacterTable, 2,
                "InitFusion: no images possible for class ", i );
          return fail;
        fi;
      od;

    else

      # Just centralizer orders are known.
      for i in [ 1 .. Length( subcentralizers ) ] do
        initfusion[i]:= [];
        for j in [ 1 .. Length( centralizers ) ] do
          if centralizers[j] mod subcentralizers[i] = 0 and
                                    upper[j] >= subclasses[i] then
            AddSet( initfusion[i], j );
          fi;
        od;
        if IsEmpty( initfusion[i] ) then
          Info( InfoCharacterTable, 2,
                "InitFusion: no images possible for class ", i );
          return fail;
        fi;
      od;

    fi;

    # step 2: replace sets with exactly one element by that element
    for i in [ 1 .. Length( initfusion ) ] do
      if Length( initfusion[i] ) = 1 then
        initfusion[i]:= initfusion[i][1];
      fi;
    od;

    return initfusion;
end );


#############################################################################
##
#F  CheckPermChar( <subtbl>, <tbl>, <fusionmap>, <permchar> )
##
##  An upper bound for the number of elements fusing into each class is
##  $`upper[i]'= `Size( <subtbl> ) \cdot
##               `<permchar>[i]' / `SizesCentralizers( <tbl> )[i]'$.
##
##  We first subtract from that the number of all elements which {\em must}
##  fuse into that class:
##  $`upper[i]':= `upper[i]' -
##     \sum_{`fusionmap[i]'=`i'} `SizesConjugacyClasses( <subtbl> )[i]'$.
##
##  After that, we delete all those possible images `j' in `initfusion[i]'
##  which do not satisfy
##  $`SizesConjugacyClasses( <subtbl> )[i]' \leq `upper[j]'$
##  (local function `deletetoolarge').
##
##  At last, if there is a class `j' with
##  $`upper[j]' =
##   \sum_{`j' \in `initfusion[i]'}' SizesConjugacyClasses( <subtbl> )[i]'$,
##  then `j' must be the image for all `i' with `j' in `initfusion[i]'
##  (local function `takealliffits').
##
InstallGlobalFunction( CheckPermChar,
    function( subtbl, tbl, fusionmap, permchar )
    local centralizers,
          subsize,
          classes,
          subclasses,
          i,
          upper,
          deletetoolarge,
          takealliffits,
          totest,
          improved;

    centralizers:= SizesCentralizers( tbl );
    subsize:= Size( subtbl );
    classes:= SizesConjugacyClasses( tbl );
    subclasses:= SizesConjugacyClasses( subtbl );

    upper:= [];

    if permchar = [] then

      # just check upper bounds
      for i in [ 1 .. Length( centralizers ) ] do
        upper[i]:= Minimum( subsize, classes[i] );
      od;
    else

      # number of elements that fuse in each class
      for i in [ 1 .. Length( centralizers ) ] do
        upper[i]:= permchar[i] * subsize / centralizers[i];
      od;
    fi;

    # subtract elements where the image is unique
    for i in [ 1 .. Length( fusionmap ) ] do
      if IsInt( fusionmap[i] ) then
        upper[ fusionmap[i] ]:= upper[ fusionmap[i] ] - subclasses[i];
      fi;
    od;
    if Minimum( upper ) < 0 then
      Info( InfoCharacterTable, 2,
            "CheckPermChar: too many preimages for classes in ",
            Filtered( [ 1 .. Length( upper ) ],
                      x-> upper[x] < 0 ) );
      return false;
    fi;

    # Only those classes are allowed images which are not too big
    # also after diminishing upper:
    # `deletetoolarge( <totest> )' excludes all those possible images `x' in
    # sets `fusionmap[i]' which are contained in the list <totest> and
    # which are larger than `upper[x]'.
    # (returns `i' in case of an inconsistency at class `i', otherwise the
    # list of classes `x' where `upper[x]' was diminished)
    #
    deletetoolarge:= function( totest )
      local i, improved, delete;

      if IsEmpty( totest ) then
        return [];
      fi;
      improved:= [];
      for i in [ 1 .. Length( fusionmap ) ] do
        if IsList( fusionmap[i] )
           and Intersection( fusionmap[i], totest ) <> [] then
          fusionmap[i]:= Filtered( fusionmap[i],
                                   x -> ( subclasses[i] <= upper[x] ) );
          if fusionmap[i] = [] then
            return i;
          elif Length( fusionmap[i] ) = 1 then
            fusionmap[i]:= fusionmap[i][1];
            AddSet( improved, fusionmap[i] );
            upper[ fusionmap[i] ]:= upper[fusionmap[i]] - subclasses[i];
          fi;
        fi;
      od;
      delete:= deletetoolarge( improved );
      if IsInt( delete ) then
        return delete;
      else
        return Union( improved, delete );
      fi;
    end;

    # Check if there are classes into which more elements must fuse
    # than known up to now; if all possible preimages are
    # necessary to satisfy the permutation character, improve `fusionmap'.
    # `takealliffits( <totest> )' sets `fusionmap[i]' to `x' if `x' is in
    # the list `totest' and if all possible preimages of `x' are necessary
    # to give `upper[x]'.
    # (returns `i' in case of an inconsistency at class `i', otherwise the
    # list of classes `x' where `upper[x]' was diminished)
    #
    takealliffits:= function( totest )
      local i, j, preimages, sum, improved, take;
      if totest = [] then return []; fi;
      improved:= [];
      for i in Filtered( totest, x -> upper[x] > 0 ) do
        preimages:= [];
        for j in [ 1 .. Length( fusionmap ) ] do
          if IsList( fusionmap[j] ) and i in fusionmap[j] then
            Add( preimages, j );
          fi;
        od;
        sum:= Sum( List( preimages, x -> subclasses[x] ) );
        if sum = upper[i] then

          # take them all
          for j in preimages do fusionmap[j]:= i; od;
          upper[i]:= 0;
          Add( improved, i );
        elif sum < upper[i] then
          return i;
        fi;
      od;
      take:= takealliffits( improved );
      if IsInt( take ) then
        return take;
      else
        return Union( improved, take );
      fi;
    end;

    # Improve until no new improvement can be found!
    totest:= [ 1 .. Length( permchar ) ];
    while totest <> [] do
      improved:= deletetoolarge( totest );
      if IsInt( improved ) then
        Info( InfoCharacterTable, 2,
              "CheckPermChar: no image possible for class ", improved );
        return false;
      fi;
      totest:= takealliffits( Union( improved, totest ) );
      if IsInt( totest ) then
        Info( InfoCharacterTable, 2,
              "CheckPermChar: not enough preimages for class ", totest );
        return false;
      fi;
    od;
    return true;
end );


#############################################################################
##
#F  ConsiderTableAutomorphisms( <parafus>, <grp> )
##
InstallGlobalFunction( ConsiderTableAutomorphisms,
    function( parafus, grp )
    local i,
          support,
          images,
          gens,
          notstable,
          orbits,
          isunion,
          image,
          orb,
          im,
          found;

    # step 1: Compute the subgroup of <grp> that acts on all images
    #         under <parafus>; if <parafus> contains all possible subgroup
    #         fusions, this is the whole group of table automorphisms of the
    #         supergroup table.

    if IsTrivial( grp ) then
      return [];
    fi;
    gens:= GeneratorsOfGroup( grp );
    notstable:= Filtered( Set( Filtered( parafus, IsInt ) ),
                          x -> ForAny( gens, y -> x^y <> x ) );
    if not IsEmpty( notstable ) then
      Info( InfoCharacterTable, 2,
            "ConsiderTableAutomorphisms: not all generators fix",
            " uniquely\n",
            "#I    determined images; computing admissible subgroup" );
      grp:= Stabilizer( grp, notstable, OnTuples );
    fi;

    images:= Set( Filtered( parafus, IsList ) );
    support:= LargestMovedPoint( grp );
    orbits:= List( OrbitsDomain( grp, [ 1 .. support ] ), Set );
                              # sets because entries of parafus are sets

    isunion:= function( image )
    while not IsEmpty( image ) do
      if image[1] > support then
        return true;
      fi;
      orb:= First( orbits, x -> image[1] in x );
      if not IsSubset( image, orb ) then
        return false;
      fi;
      image:= Difference( image, orb );
    od;
    return true;
    end;

    notstable:= Filtered( images, x -> not isunion(x) );
    if not IsEmpty( notstable ) then
      Info( InfoCharacterTable, 2,
            "ConsiderTableAutomorphisms: not all generators act;\n",
            "#I    computing admissible subgroup" );
      for i in notstable do
        grp:= Stabilizer( grp, i, OnSets );
      od;

    fi;

    # step 2: If possible, find a class where the image {\em is} a nontrivial
    #         orbit under <grp>, i.e. no other points are
    #         possible. Then replace the image by the first point of the
    #         orbit, and replace <grp> by the stabilizer of
    #         the new image in <grp>.

    found:= [];
    i:= 1;
    while i <= Length( parafus ) and not IsTrivial( grp ) do
      if IsList( parafus[i] ) and parafus[i] in orbits then
        Add( found, i );
        parafus[i]:= parafus[i][1];
        grp:= Stabilizer( grp, parafus[i], OnPoints );
        if not IsTrivial( grp ) then
          support:= LargestMovedPoint( grp );
          orbits:= List( OrbitsDomain( grp, [ 1 .. support ] ), Set );

          # Compute orbits of the smaller group; sets because entries
          # of parafus are sets

        fi;
      fi;
      i:= i + 1;
    od;

    # step 3: If `grp' is not trivial, find classes where the image
    #         {\em contains} a nontrivial orbit under `grp'.

    i:= 1;
    while i <= Length( parafus ) and not IsTrivial( grp ) do
      gens:= GeneratorsOfGroup( grp );
      if IsList( parafus[i] ) and ForAny( gens,
                                  x -> ForAny( parafus[i], y->y^x<>y ) ) then
        Add( found, i );
        image:= [];
        while not IsEmpty( parafus[i] ) do

          # now it is necessary to consider orbits of the smaller group,
          # since improvements in step 2 and 3 may affect the action
          # on the images.

          Add( image, parafus[i][1] );
          parafus[i]:= Difference( parafus[i], Orbit( grp, parafus[i][1] ) );
        od;
        for im in image do
          if not IsTrivial( grp ) then
            grp:= Stabilizer( grp, im, OnPoints );
          fi;
        od;
        parafus[i]:= image;
      fi;
      i:= i+1;
    od;
    return found;
end );


#############################################################################
##
#F  FusionsAllowedByRestrictions( <subtbl>, <tbl>, <subchars>, <chars>,
#F                                <fus>, <parameters> )
##
InstallGlobalFunction( FusionsAllowedByRestrictions,
    function( subtbl, tbl, subchars, chars, fus, parameters )
    local i, indeterminateness, numbofposs, lastimproved, restricted,
          indet, rat, poss, param, remain, possibilities, improvefusion,
          allowedfusions, maxlen, contained, minamb, maxamb, quick,
          testdec, subpowermaps, powermaps;

    if IsEmpty( chars ) then
      return [ fus ];
    fi;
    chars:= Set( chars );

#T but maybe there are characters with equal restrictions ...

    # record <parameters>:
    if not IsRecord( parameters ) then
      Error( "<parameters> must be a record with components `maxlen',\n",
             "`contained', `minamb', `maxamb' and `quick'" );
    fi;

    maxlen:= parameters.maxlen;
    contained:= parameters.contained;
    minamb:= parameters.minamb;
    maxamb:= parameters.maxamb;
    quick:= parameters.quick;
    if IsBound( parameters.testdec ) then
      testdec:= parameters.testdec;
    else
      testdec:= NonnegIntScalarProducts;
    fi;
    if IsBound( parameters.subpowermaps ) then
      subpowermaps:= parameters.subpowermaps;
    else
      subpowermaps:= ComputedPowerMaps( subtbl );
    fi;
    if IsBound( parameters.powermaps ) then
      powermaps:= parameters.powermaps;
    else
      powermaps:= ComputedPowerMaps( tbl );
    fi;

    # May we return immediately?
    if quick and Indeterminateness( fus ) < minamb then
      Info( InfoCharacterTable + InfoTom, 2,
            "FusionsAllowedByRestrictions: indeterminateness of the map\n",
            "#I    is smaller than the parameter value `minamb'; returned" );
      return [ fus ];
    fi;

    # step 1: check all in <chars>; if one has too big indeterminateness
    #         and contains irrational entries, append its rationalized char
    #         <chars>.
    indeterminateness:= []; # at position i the indeterminateness of char i
    numbofposs:= [];        # at position `i' the number of allowed
                            # restrictions for `<chars>[i]'
    lastimproved:= 0;       # last char which led to an improvement of `fus';
                            # every run through the list may stop at this char
    i:= 1;
    while i <= Length( chars ) do
      restricted:= CompositionMaps( chars[i], fus );
      indet:= Indeterminateness( restricted );
      indeterminateness[i]:= indet;
      if indet = 1 then
        if not quick
           and not testdec( subtbl, subchars, restricted ) then
          return [];
        fi;
      elif indet < minamb then
        indeterminateness[i]:= 1;
      elif indet <= maxamb then
        poss:= contained( subtbl, subchars, restricted );
        if IsEmpty( poss ) then
          return [];
        fi;
        numbofposs[i]:= Length( poss );
        param:= Parametrized( poss );
        if param <> restricted then  # improvement found
          UpdateMap( chars[i], fus, param );
          lastimproved:= i;
#T call of TestConsistencyMaps ? ( with respect to improved classes )
          indeterminateness[i]:= Indeterminateness(
                                        CompositionMaps( chars[i], fus ) );
        fi;
      else
        numbofposs[i]:= infinity;
        if ForAny( chars[i], x -> IsCyc(x) and not IsRat(x) ) then

          # maybe the indeterminateness of the rationalized
          # character is smaller but not 1
          rat:= RationalizedMat( [ chars[i] ] )[1];
          AddSet( chars, rat );
        fi;
      fi;
      i:= i + 1;
    od;

    # step 2: (local function `improvefusion')
    #         loop over chars until no improvement is possible without a
    #         branch; update `indeterminateness' and `numbofposs';
    #         first character to test is at position `first'; at least run
    #         up to character $'lastimproved' - 1$; update `lastimproved' if
    #         an improvement occurs;
    #         return `false' in the case of an inconsistency, `true'
    #         otherwise.

    #         Note:
    #         `subtbl', `subchars' and `maxlen' are global
    #         variables for this function, also (but not necessary) global are
    #         `restricted', `indet' and `param'.

    improvefusion:=
         function(chars,fus,first,lastimproved,indeterminateness,numbofposs)
    local i, poss;
    i:= first;
    while i <> lastimproved do
      if indeterminateness[i] <> 1 then
        restricted:= CompositionMaps( chars[i], fus );
        indet:= Indeterminateness( restricted );
        if indet < indeterminateness[i] then

          # only test those characters which now have smaller
          # indeterminateness
          indeterminateness[i]:= indet;
          if indet = 1 then
            if not quick and
               not testdec( subtbl, subchars, restricted ) then
              return false;
            fi;
          elif indet < minamb then
            indeterminateness[i]:= 1;
          elif indet <= maxamb then
            poss:= contained( subtbl, subchars, restricted );
            if IsEmpty( poss ) then
              return false;
            fi;
            numbofposs[i]:= Length( poss );
            param:= Parametrized( poss );
            if param <> restricted then

              # improvement found
              Info( InfoCharacterTable + InfoTom, 2,
                    "FusionsAllowedByRestrictions: improvement found ",
                    "at character ", i );
              UpdateMap( chars[i], fus, param );
              lastimproved:= i;
#T call of TestConsistencyMaps ? ( with respect to improved classes )
#T (only for locally valid power maps!!)
              indeterminateness[i]:= Indeterminateness(
                                        CompositionMaps( chars[i], fus ) );
            fi;
          fi;
        fi;
      fi;
      if lastimproved = 0 then lastimproved:= i; fi;
      i:= i mod Length( chars ) + 1;
    od;
    return true;
    end;

    # step 3: recursion; (local function `allowedfusions')
    #         a) delete all characters which now have indeterminateness 1;
    #            their restrictions (with respect to every fusion that will be
    #            found ) have nonnegative scalar products with <subchars>.
    #         b) branch according to a significant character or class
    #         c) for each possibility call `improvefusion' and then the
    #            recursion

    allowedfusions:= function( subpowermap, powermap, chars, fus,
                               indeterminateness, numbofposs )
    local i, j, class, possibilities, poss, newfus, newpow, newsubpow,
          newindet, newnumbofposs;
    remain:= Filtered( [ 1..Length( chars ) ], i->indeterminateness[i] > 1 );
    chars             := chars{ remain };
    indeterminateness := indeterminateness{ remain };
    numbofposs        := numbofposs{ remain };

    if IsEmpty( chars ) then
      Info( InfoCharacterTable + InfoTom, 2,
            "FusionsAllowedByRestrictions: no character with indet.\n",
            "#I    between ", minamb, " and ", maxamb, " significant now" );
      return [ fus ];
    fi;
    possibilities:= [];
    if Minimum( numbofposs ) < maxlen then

      # branch according to a significant character
      # with minimal number of possible restrictions
      i:= Position( numbofposs, Minimum( numbofposs ) );
      Info( InfoCharacterTable + InfoTom, 2,
            "FusionsAllowedByRestrictions: branch at character\n",
            "#I     ", CharacterString( chars[i], "" ),
            " (", numbofposs[i], " calls)" );
      poss:= contained( subtbl, subchars,
                        CompositionMaps( chars[i], fus ) );
      for j in poss do
        newfus:= List( fus, ShallowCopy );
        newpow:= StructuralCopy( powermap );
        newsubpow:= StructuralCopy( subpowermap );
        UpdateMap( chars[i], newfus, j );
        if TestConsistencyMaps( newsubpow, newfus, newpow ) then
          newindet:= ShallowCopy( indeterminateness );
          newnumbofposs:= ShallowCopy( numbofposs );
          if improvefusion(chars,newfus,i,0,newindet,newnumbofposs) then
            Append( possibilities,
                    allowedfusions( newsubpow, newpow, chars,
                                    newfus, newindet, newnumbofposs ) );
          fi;
        fi;
      od;

      Info( InfoCharacterTable + InfoTom, 2,
            "FusionsAllowedByRestrictions: return from branch at",
            " character\n",
            "#I     ", CharacterString( chars[i], "" ),
            " (", numbofposs[i], " calls)" );

    else

      # branch according to a significant class in a
      # character with minimal nontrivial indet.
      i:= Position( indeterminateness, Minimum( indeterminateness ) );
      restricted:= CompositionMaps( chars[i], fus );
      class:= 1;
      while not IsList( restricted[ class ] ) do class:= class + 1; od;
      Info( InfoCharacterTable + InfoTom, 2,
            "FusionsAllowedByRestrictions: branch at class ",
            class, "\n#I     (", Length( fus[ class ] ),
            " calls)" );
      for j in fus[ class ] do
        newfus:= List( fus, ShallowCopy );
        newfus[ class ]:= j;
        newpow:= StructuralCopy( powermap );
        newsubpow:= StructuralCopy( subpowermap );
        if TestConsistencyMaps( subpowermap, newfus, newpow ) then
          newindet:= ShallowCopy( indeterminateness );
          newnumbofposs:= ShallowCopy( numbofposs );
          if improvefusion(chars,newfus,i,0,newindet,newnumbofposs) then
            Append( possibilities,
                    allowedfusions( newsubpow, newpow, chars,
                                    newfus, newindet, newnumbofposs ) );
          fi;
        fi;
      od;
      Info( InfoCharacterTable + InfoTom, 2,
            "FusionsAllowedByRestrictions: return from branch at class ",
            class );
    fi;
    return possibilities;
    end;

    # begin of the recursion:
    if lastimproved <> 0 then
      if not improvefusion( chars, fus, 1, lastimproved, indeterminateness,
                            numbofposs ) then
        return [];
      fi;
    fi;
    return allowedfusions( subpowermaps,
                           powermaps,
                           chars,
                           fus,
                           indeterminateness,
                           numbofposs );
end );


#############################################################################
##
#F  ConsiderStructureConstants( <subtbl>, <tbl>, <fusions>, <quick> )
##
##  Note that because of
##  $a_{ij\overline{k}} = a_{ji\overline{k}} = a_{ik\overline{j}}$,
##  we may assume $i \leq j \leq k$.
##
#T avoid computing the same s.c. in the supergroup several times; cache?
##
InstallGlobalFunction( ConsiderStructureConstants,
    function( subtbl, tbl, fusions, quick )
    local inv, parm, nccl, i, j, k, kk, subsc, sc, trpl;

    # We do nothing if the irreducibles are not yet known.
    if not HasIrr( subtbl ) or not HasIrr( tbl ) then
      return fusions;
    fi;

    # Check the condition for all possible fusions.
    inv:= InverseClasses( subtbl );
    parm:= Parametrized( fusions );
    nccl:= Length( parm );
    for i in [ 1 .. nccl ] do
      for j in [ i .. nccl ] do
        for k in [ j .. nccl ] do
          kk:= inv[k];
          if IsInt( parm[i] ) and IsInt( parm[j] ) and IsInt( parm[kk] ) then
            # Check this triple only if `quick = false'.
            if not quick then
              subsc:= ClassMultiplicationCoefficient( subtbl, i, j, kk );
              sc:= ClassMultiplicationCoefficient( tbl, parm[i], parm[j],
                       parm[kk] );
              if sc < subsc then
                Info( InfoCharacterTable, 2,
                      "ConsiderStructureConstants: contradiction for ",
                      [ i, j, kk ] );
                return [];
              fi;
            fi;
          else
            # The possible fusions differ on this triple.
            subsc:= ClassMultiplicationCoefficient( subtbl, i, j, kk );
            for trpl in Set( fusions, x -> x{ [ i, j, kk ] } ) do
              sc:= ClassMultiplicationCoefficient( tbl, trpl[1], trpl[2],
                       trpl[3] );
              if sc < subsc then
                fusions:= Filtered( fusions,
                                    x -> x{ [ i, j, kk ] } <> trpl );
                if Length( fusions ) = 0 then
                  Info( InfoCharacterTable, 2,
                        "ConsiderStructureConstants: contradiction for ",
                        [ i, j, kk ] );
                  return fusions;
                fi;
                Info( InfoCharacterTable, 2,
                      "ConsiderStructureConstants: improvement for ",
                      [ i, j, kk ] );
                parm:= Parametrized( fusions );
              fi;
            od;
          fi;
        od;
      od;
    od;

    # Return the maps that satisfy the condition.
    return fusions;
end );
