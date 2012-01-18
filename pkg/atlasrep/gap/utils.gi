#############################################################################
##
#W  utils.gi             GAP 4 package AtlasRep                 Thomas Breuer
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementations of utility functions for the
##  ATLAS of Group Representations.
##


#T remove this as soon as GAP 4.4 need not be supported anymore!
AGR.IsAlmostSimpleCharacterTable:= function( ordtbl )
    local nsg, orbs;

    nsg:= ClassPositionsOfMinimalNormalSubgroups( ordtbl );
    if Length( nsg ) <> 1 then
      return false;
    fi;
    orbs:= SizesConjugacyClasses( ordtbl ){ nsg[1] };
    nsg:= Sum( orbs );
    return     ( not IsPrimeInt( nsg ) )
           and IsomorphismTypeInfoFiniteSimpleGroup( nsg ) <> fail;
    end;


#############################################################################
##
#V  AtlasClassNamesOffsetInfo
##
##  The component `ordinary' is used for cases where the outer automorphism
##  group is not of prime order, and so the ordering of cosets is important
##  for constructing the names.
##
##  The component `special' is used for cases where one table of a subgroup
##  is used more than once.
##  Each entry is a list of length three, with first entry the `Identifier'
##  of the table in question, second entry the list of `Identifier' values of
##  the tables that cover the classes of the table in question, and third
##  entry the list of corresponding class fusions (those stored on the tables
##  can be omitted here).
##
InstallValue( AtlasClassNamesOffsetInfo, rec(
    ordinary:= [
    [ "A6", "A6.2_1", "A6.2_2", "A6.2_3" ],
    [ "L2(16)", "L2(16).2", "L2(16).4" ],
    [ "L2(25)", "L2(25).2_1", "L2(25).2_2", "L2(25).2_3" ],
    [ "L2(27)", "L2(27).2", "L2(27).3", "L2(27).6" ],
    [ "L2(49)", "L2(49).2_1", "L2(49).2_2", "L2(49).2_3" ],
    [ "L2(81)", "L2(81).2_1", "L2(81).4_1", "L2(81).4_2", "L2(81).2_2",
      "L2(81).2_3" ],
    [ "L3(4)", "L3(4).2_1", "L3(4).3", "L3(4).6", "L3(4).2_2", "L3(4).2_3" ],
    [ "L3(7)", "L3(7).3", "L3(7).2" ],
    [ "L3(8)", "L3(8).2", "L3(8).3", "L3(8).6" ],
    [ "L3(9)", "L3(9).2_1", "L3(9).2_2", "L3(9).2_3" ],
    [ "L4(3)", "L4(3).2_1", "L4(3).2_2", "L4(3).2_3" ],
    [ "O8-(3)", "O8-(3).2_1", "O8-(3).2_2", "O8-(3).2_3" ],
    [ "O8+(2)", "O8+(2).3", "O8+(2).2" ],
    [ "O8+(3)", "O8+(3).2_1", "O8+(3).3", "O8+(3).2_2", "O8+(3).4" ],
    [ "S4(4)", "S4(4).2", "S4(4).4" ],
    [ "2E6(2)", "2E6(2).2", "2E6(2).3" ],
    [ "U3(4)", "U3(4).2", "U3(4).4" ],
    [ "U3(5)", "U3(5).3", "U3(5).2" ],
    [ "U3(8)", "U3(8).3_1", "U3(8).3_2", "U3(8).3_3", "U3(8).2", "U3(8).6" ],
    [ "U3(9)", "U3(9).2", "U3(9).4" ],
    [ "U3(11)", "U3(11).3", "U3(11).2" ],
    [ "U4(3)", "U4(3).2_1", "U4(3).4", "U4(3).2_2", "U4(3).2_3" ],
    [ "U6(2)", "U6(2).3", "U6(2).2" ],
    ],
    special:= [
    [ "O8+(3).(2^2)_{111}",
      [ "O8+(3)", "O8+(3).2_1", "O8+(3).2_1", "O8+(3).2_1" ],
      [,,[1,3,4,2,5,6,8,9,7,8,10,10,11,12,13,15,16,14,17,19,20,18,22,23,21,
      24,26,27,25,26,29,30,28,29,32,33,31,34,34,35,35,36,37,38,39,41,42,40,
      41,43,43,44,44,46,47,45,49,50,48,52,53,51,52,54,55,55,57,58,56,57,59,
      60,62,63,61,65,66,64,65,68,69,67,68,71,72,70,122,123,124,125,126,127,
      128,129,129,130,130,131,131,132,133,134,136,135,137,139,138,140,142,
      141,143,144,145,145,146,147,148,149,149,150,151,152,152,153,155,154,
      157,156,158,158,159,160,161,162,164,163,165,165,166,166,169,170,167,
      168],[1,4,2,3,5,6,9,7,8,9,10,10,11,12,13,16,14,15,17,20,18,19,23,21,22,
      24,27,25,26,27,30,28,29,30,33,31,32,34,34,35,35,36,37,38,39,42,40,41,
      42,43,43,44,44,47,45,46,50,48,49,53,51,52,53,54,55,55,58,56,57,58,59,
      60,63,61,62,66,64,65,66,69,67,68,69,72,70,71,171,172,173,174,175,176,
      177,178,178,179,179,180,180,181,182,183,184,185,186,187,188,189,190,
      191,192,193,194,194,195,196,197,198,198,199,200,201,201,202,203,204,
      205,206,207,207,208,209,210,211,212,213,214,214,215,215,216,217,218,
      219]] ],
    [ "O8+(3).D8",
      [ "O8+(3)", "O8+(3).2_1", "O8+(3).2_1", "O8+(3).2_2", "O8+(3).4" ],
      [,,[1,3,2,3,4,5,7,6,7,7,8,8,9,10,11,13,12,13,14,16,15,16,18,17,18,19,
      21,20,21,21,23,22,23,23,25,24,25,26,26,27,27,28,29,30,31,33,32,33,33,
      34,34,35,35,37,36,37,39,38,39,41,40,41,41,42,43,43,45,44,45,45,46,47,
      49,48,49,51,50,51,51,53,52,53,53,55,54,55,97,98,99,100,101,102,103,104,
      104,105,105,106,106,107,108,109,110,111,112,113,114,115,116,117,118,
      119,120,120,121,122,123,124,124,125,126,127,127,128,129,130,131,132,
      133,133,134,135,136,137,138,139,140,140,141,141,142,143,144,145]] ],
    [ "U4(3).(2^2)_{122}",
      [ "U4(3)", "U4(3).2_1", "U4(3).2_2", "U4(3).2_2" ],
      [,,,[1,2,3,5,4,6,7,8,9,10,12,11,13,14,16,16,15,17,46,47,48,49,50,50,51,
      52,53,54,55,56,57,58,59,59]] ],
    [ "U4(3).(2^2)_{133}",
      [ "U4(3)", "U4(3).2_1", "U4(3).2_3", "U4(3).2_3" ],
      [,,,[1,2,3,4,5,6,7,8,9,10,11,12,13,13,14,36,37,38,39,40,41,42,43,44,44]
      ] ],
    ] ) );


#############################################################################
##
#F  AtlasClassNames( <tbl> )
##
InstallGlobalFunction( AtlasClassNames, function( tbl )
    local ordtbl, names, n, fact, factnames, map, i, j, name, pos,
          solvres, simplename, F, Finv, info, tbls, classes, tblname,
          subtbl, derclasses, subF, size,
          gens,
          fus,
          filt,
          special,
          subtblfustbl,
          Fproxies,
          inv,
          proxies,
          orb,
          imgs,
          img,
          count,
          k,
          alpha,    # alphabet
          lalpha,   # length of the alphabet
          orders,   # list of representative orders
          innernames,
          number,   # at position <i> the current number of
                    # classes of order <i>
          suborders,
          depname,
          dashes,
          subnames,
          relevant,
          intermed,       # loop over intermediate tables
          tblfusF;

    if not IsCharacterTable( tbl ) then

      Error( "<tbl> must be a character table" );

    elif IsBrauerTable( tbl ) then

      # Derive the class names from the names of the ordinary table.
      ordtbl:= OrdinaryCharacterTable( tbl );
      names:= AtlasClassNames( ordtbl );
      if names = fail then
        return fail;
      fi;
      return names{ GetFusionMap( tbl, ordtbl ) };

    elif IsSimpleCharacterTable( tbl ) then

      # For tables of simple groups, `ClassNames' is good enough.
      return ClassNames( tbl, "Atlas" );

    fi;

    # For not almost simple tables,
    # derive the class names from the names for the almost simple factor.
    n:= ClassPositionsOfFittingSubgroup( tbl );

    if Length( n ) <> 1 then
      fus:= First( ComputedClassFusions( tbl ),
                   r -> ClassPositionsOfKernel( r.map ) = n );
      if fus = fail then
        return fail;
      fi;
      fact:= CharacterTable( fus.name );
      factnames:= AtlasClassNames( fact );
      if factnames = fail then
        Info( InfoAtlasRep, 2,
              Identifier( tbl ),
              " is not a downward extension of an almost simple table" );
        return fail;
      fi;

      map:= InverseMap( GetFusionMap( tbl, fact ) );
      names:= [];
      for i in [ 1 .. Length( map ) ] do
        if IsInt( map[i] ) then
          names[ map[i] ]:= Concatenation( factnames[i], "_0" );
        # Add( names, Concatenation( factnames[i], "_0" ) );
        else
          for j in [ 0 .. Length( map[i] )-1 ] do
            names[ map[i][ j+1 ] ]:= Concatenation( factnames[i], "_",
                                         String( j ) );
          od;
        # Append( names, List( [ 0 .. Length( map[i] )-1 ],
        #     j -> Concatenation( factnames[i], "_", String( j ) ) ) );
        fi;
      od;
      return names;
    elif not AGR.IsAlmostSimpleCharacterTable( tbl ) then
      Info( InfoAtlasRep, 2,
            Identifier( tbl ), " is not an almost simple table" );
      return fail;
    fi;

    # Now `tbl' is almost simple and not simple.
    # Find out which nonabelian simple group is involved,
    # and which upward extension is given.
    # (We use the `Identifier' value of `tbl';
    # note that this function makes sense only for library tables.)
    name:= Identifier( tbl );
    pos:= Position( name, '.' );
    if pos = fail then
      Info( InfoAtlasRep, 2,
            "strange name `", name, "'" );
      return fail;
    fi;

    # Get the table of the solvable residuum.
    solvres:= CharacterTable( name{ [ 1 .. pos-1 ] } );
    if solvres = fail then
      Info( InfoAtlasRep, 2,
            "the identifier `", name,
            "' does not fit to an almost simple group" );
      return fail;
    fi;

    simplename:= Identifier( solvres );
    F:= tbl / ClassPositionsOfSolvableResiduum( tbl );
    Finv:= InverseMap( GetFusionMap( tbl, F ) );

    # We use the global variable `AtlasClassNamesOffsetInfo'.
    info:= First( AtlasClassNamesOffsetInfo.ordinary,
                  x -> x[1] = simplename );

    # Compute the tables of all cyclic upward extensions of `solvres'
    # that are contained in `tbl',
    # and store the positions of the corresponding relevant classes in `tbl'.
    # Tables that are *not* involved in `tbl' but whose class names force
    # offsets for the class names of `tbl' are also stored,
    tbls:= [ solvres ];
    classes:= [ [ Finv[1], true ] ];

    if IsPrimeInt( Size( tbl ) / Size( solvres ) ) then

      # Here `AtlasClassNamesOffsetInfo' may be missing.
      if info = fail then
        Info( InfoCharacterTable, 2,
              "AtlasClassNames: ",
              "no info by `AtlasClassNamesOffsetInfo' available" );
      else

        tblname:= ShallowCopy( Identifier( tbl ) );
        while tblname[ Length( tblname ) ] = '\'' do
          Unbind( tblname[ Length( tblname ) ] );
        od;
        pos:= Position( info, tblname );
        for i in [ 2 .. pos-1 ] do

          subtbl:= CharacterTable( info[i] );
          derclasses:= ClassPositionsOfDerivedSubgroup( subtbl );
          subF:= subtbl / derclasses;

          # The classes are *not* involved in `tbl',
          # store the positions of the classes in generator cosets!
          size:= Size( subF );
          gens:= Filtered( [ 1 .. size ],
                     i -> OrdersClassRepresentatives( subF )[i] = size );
          fus:= GetFusionMap( subtbl, subF );
          filt:= Filtered( [ 1 .. NrConjugacyClasses( subtbl ) ],
                           i -> fus[i] in gens );

          Add( tbls, subtbl );
          Add( classes, [ filt, false ] );

        od;

      fi;
      special:= fail;

      # Add `tbl' itself.
      Add( tbls, tbl );
      Add( classes,
           [ Difference( [ 1 .. NrConjugacyClasses( tbl ) ], Finv[1] ),
             true ] );

    elif Size( solvres ) <> Size( tbl ) then

      # Here we definitely need `AtlasClassNamesOffsetInfo'.
      if info = fail then
        Error( "not enough information about <tbl>" );
      fi;

      # More information is needed if a table occurs more than once.
      special:= First( AtlasClassNamesOffsetInfo.special,
                       list -> list[1] = Identifier( tbl ) );
      if special <> fail then
        special:= ShallowCopy( special );
        special[4]:= [];
        info:= special[2];
      fi;

      # Test which intermediate tables are needed.
      # These are exactly the ones having a fusion into `tbl'.
      # The others are taken with `false' in `classes'.
      for i in [ 2 .. Length( info ) ] do

        subtbl:= CharacterTable( info[i] );
        derclasses:= ClassPositionsOfDerivedSubgroup( subtbl );
        subF:= subtbl / derclasses;

        if special = fail or not IsBound( special[3][i] ) then
          subtblfustbl:= GetFusionMap( subtbl, tbl );
        else
          subtblfustbl:= special[3][i];
        fi;

        if subtblfustbl = fail then

          # The classes are *not* involved in `tbl',
          # or `subtbl' is equal to `tbl'.
          # Store the positions of the classes in generator cosets!
          size:= Size( subF );
          gens:= Filtered( [ 1 .. size ],
                     i -> OrdersClassRepresentatives( subF )[i] = size );
          fus:= GetFusionMap( subtbl, subF );
          filt:= Filtered( [ 1 .. NrConjugacyClasses( subtbl ) ],
                           i -> fus[i] in gens );

          if Identifier( tbl ) = info[i] then
            Add( tbls, tbl );
            Add( classes, [ filt, true ] );
          else
            Add( tbls, subtbl );
            Add( classes, [ filt, false ] );
          fi;

        elif Set( subtblfustbl{ derclasses } ) <> Finv[1] then
          Error( "strange fusion ", Identifier( subtbl ),
                 " -> ", Identifier( tbl ) );
        else

          # The table is needed.
          # Store the positions in `tbl' of the classes in generator cosets!
          size:= Size( subF );
          gens:= Filtered( [ 1 .. size ],
                     i -> OrdersClassRepresentatives( subF )[i] = size );
          fus:= GetFusionMap( subtbl, subF );
          filt:= Filtered( [ 1 .. NrConjugacyClasses( subtbl ) ],
                           i -> fus[i] in gens );

          Add( tbls, subtbl );
          Add( classes, [ Set( subtblfustbl{ filt } ), true ] );

        fi;

      od;

      # Check whether all necessary tables are available.
      if Union( List( Filtered( classes, x -> x[2] = true ), y -> y[1] ) )
             <> [ 1 .. NrConjugacyClasses( tbl ) ] then
        Info( InfoAtlasRep, 2,
              "AtlasClassNames: ",
              "not all necessary tables are available for ",
              Identifier( tbl ) );
        return fail;
      fi;

    fi;

    # Define a function that creates class names in ATLAS style.
    alpha:= List( "ABCDEFGHIJKLMNOPQRSTUVWXYZ", x -> [ x ] );
    for i in alpha do
      ConvertToStringRep( i );
    od;
    lalpha:= Length( alpha );
    name:= function( n )
      local m;
      if n <= lalpha then
        return alpha[n];
      else
        m:= (n-1) mod lalpha + 1;
        n:= ( n - m ) / lalpha;
        return Concatenation( alpha[m], String( n ) );
      fi;
    end;

    # Initialize the list of class names
    # and the counter for the names already constructed.
    names:= [];
    number:= [];

    # Loop over the tables.
    for pos in [ 1 .. Length( tbls ) ] do

      subtbl:= tbls[ pos ];
      relevant:= classes[ pos ][1];

      if special <> fail and IsBound( special[3][ pos ] ) then
        fus:= special[3][ pos ];
        subnames:= special[4][ Position( special[2], special[2][ pos ] ) ];
        for i in [ 1 .. Length( subnames ) ] do
          if not IsBound( subnames[i] ) then
            subnames[i]:= "?";
          fi;
        od;
        subnames:= Concatenation( [ 1 .. Maximum( Filtered(
            [ 1 .. Length( fus ) ], x -> fus[x] in relevant ) )
            - Length( subnames ) ], subnames );
        dashes:= Number( [ 1 .. pos-1 ],
                         x -> special[2][x] = special[2][ pos ] );
        dashes:= ListWithIdenticalEntries( dashes, '\'' );
        subnames:= List( subnames, ShallowCopy );
        for i in [ 1 .. Length( subnames ) ] do
          Append( subnames[i], dashes );
        od;

      else

        if classes[ pos ][2] then
          if Size( subtbl ) = Size( tbl ) then
            fus:= [ 1 .. NrConjugacyClasses( tbl ) ];
          elif special <> fail and IsBound( special[3][ pos ] ) then
            fus:= special[3][ pos ];
          else
            fus:= GetFusionMap( subtbl, tbl );
            if fus = fail then
              for intermed in tbls do
                if     GetFusionMap( subtbl, intermed ) <> fail
                   and GetFusionMap( intermed, tbl ) <> fail then
                  fus:= CompositionMaps( GetFusionMap( intermed, tbl ),
                                         GetFusionMap( subtbl, intermed ) );
                  break;
                fi;
              od;
            fi;
          fi;
        else
          fus:= fail;
        fi;

        # Choose proxy classes in the factor group,
        # that is, one generator class for each cyclic subgroup.
        F:= subtbl / ClassPositionsOfDerivedSubgroup( subtbl );
        Fproxies:= [];
        for i in [ 1 .. NrConjugacyClasses( F ) ] do
          if not IsBound( Fproxies[i] ) then
            for j in ClassOrbit( F, i ) do
              Fproxies[j]:= i;
            od;
          fi;
        od;

        # Transfer the proxy classes to `subtbl'.
        tblfusF:= GetFusionMap( subtbl, F );
        proxies:= [];
        for i in [ 1 .. Length( tblfusF ) ] do
          if not IsBound( proxies[i] ) then
            orb:= ClassOrbit( subtbl, i );
            imgs:= tblfusF{ orb };
            for j in [ 1 .. Length( orb ) ] do

              # Classes mapping to a proxy class in `F' are proxies also
              # in `subtbl'.
              # For the other classes,
              # we make use of the convention that in GAP tables
              # (of upward extensions of simple groups),
              # the follower classes come immediately after their proxies.
              k:= j;
              while Fproxies[ imgs[k] ] <> imgs[k] do
                k:= k-1;
              od;
              proxies[ orb[j] ]:= orb[k];

            od;
          fi;
        od;

        # Compute the non-order parts of the names w.r.t. the subgroup.
        subnames:= [];
        suborders:= OrdersClassRepresentatives( subtbl );
        for i in [ 1 .. NrConjugacyClasses( subtbl ) ] do
          if ( fus <> fail and fus[i] in relevant ) then
            if proxies[i] = i then
              if not IsBound( number[ suborders[i] ] ) then
                number[ suborders[i] ]:= 1;
              fi;
              subnames[i]:= name( number[ suborders[i] ] );
              number[ suborders[i] ]:= number[ suborders[i] ] + 1;
            else
              depname:= ShallowCopy( subnames[ proxies[i] ] );
              while ForAny( [ 1 .. i-1 ], x -> IsBound( subnames[x] )
                         and subnames[x] = depname
                         and suborders[x] = suborders[i] ) do
                Add( depname, '\'' );
              od;
              subnames[i]:= depname;
            fi;
          fi;
        od;

        if special <> fail then
          special[4][ pos ]:= subnames;
        fi;

      fi;

      # For tables that are not needed,
      # just compute the class names for all outer generator classes
      if fus = fail then
        for i in classes[ pos ][1] do
          if Fproxies[ tblfusF[i] ] = tblfusF[i] then
            if not IsBound( number[ suborders[i] ] ) then
              number[ suborders[i] ]:= 1;
            fi;
            name( number[ suborders[i] ] );
            number[ suborders[i] ]:= number[ suborders[i] ] + 1;
          fi;
        od;
      fi;

      # Compute the dashes that are forced by the table name.
      dashes:= "";
      if pos <> 1 then
        i:= Length( Identifier( subtbl ) );
        while Identifier( subtbl )[i] = '\'' do
          Add( dashes, '\'' );
          i:= i-1;
        od;
      fi;

      # If the table is needed then form orbit concatenations of these names.
      if fus <> fail then
        orders:= OrdersClassRepresentatives( tbl );
        inv:= InverseMap( fus );
        for i in relevant do
          if IsInt( inv[i] ) then
            orb:= [ subnames[ inv[i] ] ];
          else
            orb:= List( inv[i], x -> subnames[x] );
            if     ForAny( orb, x -> '\'' in x )
               and not ForAll( orb, x -> '\'' in x ) then
              orb:= Filtered( orb, x -> not '\'' in x );
            fi;
          fi;
          orb:= List( orb, x -> Concatenation( x, dashes ) );
          names[i]:= Concatenation( String( orders[i] ),
                         Concatenation( orb ) );
        od;
      fi;

    od;

    # Return the list of classnames.
    return names;
end );


#############################################################################
##
#F  AtlasCharacterNames( <tbl> )
##
InstallGlobalFunction( AtlasCharacterNames, function( tbl )
    local alpha, i, lalpha, name, ordtbl, names, degrees, chi, pos;

    if not IsCharacterTable( tbl ) then
      Error( "<tbl> must be a character table" );
    fi;

    # Define a function that creates character names in ATLAS style.
    alpha:= List( "abcdefghijlkmnopqrstuvwxyz", x -> [ x ] );
    for i in alpha do
      ConvertToStringRep( i );
    od;
    lalpha:= Length( alpha );
    name:= function( n )
      local m;
      if n <= lalpha then
        return alpha[n];
      else
        m:= (n-1) mod lalpha + 1;
        n:= ( n - m ) / lalpha;
        return Concatenation( alpha[m], String( n ) );
      fi;
    end;

    if UnderlyingCharacteristic( tbl ) = 0 then
      ordtbl:= tbl;
    else
      ordtbl:= OrdinaryCharacterTable( tbl );
    fi;

    if IsSimpleCharacterTable( ordtbl ) then

      # For tables of simple groups, use the degrees.
      names:= [];
      degrees:= [ [], [] ];
      for chi in Irr( tbl ) do
        pos:= Position( degrees[1], chi[1] );
        if pos = fail then
          Add( degrees[1], chi[1] );
          Add( degrees[2], 1 );
          Add( names, Concatenation( String( chi[1] ), name( 1 ) ) );
        else
          degrees[2][ pos ]:= degrees[2][ pos ] + 1;
          Add( names,
               Concatenation( String( chi[1] ), name( degrees[2][ pos ] ) ) );
        fi;
      od;
      return names;

    else

      Info( InfoAtlasRep, 2,
            "AtlasCharacterNames: ",
            "not available for ", Identifier( tbl ) );
      return fail;

    fi;
end );


#############################################################################
##
#F  StringOfAtlasProgramCycToCcls( <prgstring>, <tbl>, <mode> )
##
InstallGlobalFunction( StringOfAtlasProgramCycToCcls,
    function( prgstring, tbl, mode )
    local classnames, labels, numbers, prgline, line, string, pos, nrlabels,
          inputline, inline, nccl, result, i, dashedclassnames, orders,
          primes, known, unchanged, p, map, img, pp, orb, k, j, e, namline,
          resline;

    # Check the input.
    if not ( IsString( prgstring ) and IsOrdinaryTable( tbl ) ) then
      Error("usage: StringOfAtlasProgramCycToCcls(<prgstring>,<tbl>,<mode>)");
    fi;

    # Fetch the `echo' lines starting with `Classes'.
    # They serve as inputs for the result program.

    # Compute the classnames.
    classnames:= AtlasClassNames( tbl );

    # Determine the labels that occur.
    # `labels' is a list of labels that occur in `echo' lines of the
    # given script (class names, without dashes).
    # `numbers' is a list of labels that occur in `oup' lines of the
    # given script (numbers or classnames, with dashes).
    labels:= [];
    numbers:= [];
    for prgline in SplitString( prgstring, "\n" ) do

      # Ignore lines that are neither `echo' nor `oup' statements.
      if   5 < Length( prgline ) and prgline{ [ 1 .. 4 ] } = "echo" then
        line:= SplitString( prgline, "", "\" " );
        if   "classes" in line then
          Append( labels,
              line{ [ Position( line, "classes" )+1 .. Length( line ) ] } );
        elif "Classes" in line then
          Append( labels,
              line{ [ Position( line, "Classes" )+1 .. Length( line ) ] } );
        elif not "Here" in line then
          Append( labels,
              line{ [ Position( line, "echo" )+1 .. Length( line ) ] } );
        fi;
      elif  4 < Length( prgline ) and prgline{ [ 1 .. 3 ] } = "oup" then
        line:= SplitString( prgline, "", "\" \n" );
        Append( numbers, line{ [ 3 .. Length( line ) ] } );
      fi;

    od;

    # Construct the list of class representatives from the labels.
    if   IsEmpty( labels ) then
      Info( InfoCMeatAxe, 1,
            "no class names specified as outputs" );
      return fail;
    elif not ForAll( labels, str -> str in classnames ) then
      Info( InfoCMeatAxe, 1,
            "labels `",
            Filtered( labels, str -> not str in classnames ),
            "' aren't class names" );
      return fail;
    fi;
    string:= "";

    # Write down the line(s) specifying the input list.
    pos:= 1;
    nrlabels:= Length( labels );
    while pos <= nrlabels do
      inputline:= "";
      inline:= 0;
      while pos <= nrlabels and
            Length( inputline ) + Length( numbers[ pos ] ) <= 71 do
        Add( inputline, ' ' );
        Append( inputline, numbers[ pos ] );
        pos:= pos + 1;
        inline:= inline + 1;
      od;
      Append( string, "inp " );
      Append( string, String( inline ) );
      Append( string, inputline );
      Add( string, '\n' );
    od;

    # The program shall return conjugacy class representatives.
    nccl:= Length( classnames );
    result:= [];
    for i in [ 1 .. nccl ] do
      if classnames[i] in labels then
        result[i]:= true;
      fi;
    od;

    # The inputs are numbers or class names,
    # and depending on `mode', the outputs are numbers or class names.
    if   mode = "names" then
      # Dashes in the labels must be escaped with backslashes.
      # (Note that names in `echo' lines must *not* be escaped.)
      numbers:= Concatenation( numbers,
                    List( Filtered( classnames, x -> not x in labels ),
                          str -> ReplacedString( str, "'", "\\'" ) ) );
    elif ForAll( numbers, x -> Int( x ) <> fail ) then
      # The inputs are numbers, and the outputs shall be numbers.
      numbers:= Concatenation( numbers,
                    Difference( List( [ 1 .. nccl ], String ), numbers ) );
    elif IsSubset( classnames, numbers ) and numbers = labels then
      # The inputs are class names (with dashes escaped),
      # and the outputs shall be numbers,
      dashedclassnames:= List( classnames,
                               str -> ReplacedString( str, "'", "\\'" ) );
      numbers:= Concatenation( numbers,
                    List( Difference( [ 1 .. nccl ],
                              List( numbers,
                                    x -> Position( dashedclassnames, x ) ) ),
                          String ) );
    else
      Error( "all in <numbers> must be numbers or in <classnames>" );
    fi;
    labels:= Concatenation( labels,
                 Filtered( classnames, x -> not x in labels ) );

    # Use power maps to fill missing entries.
    orders:= OrdersClassRepresentatives( tbl );
    primes:= Set( Factors( Size( tbl ) ) );
    known:= Filtered( [ 1 .. nccl ], x -> IsBound( result[x] ) );
    SortParallel( - orders{ known }, known );
    repeat
      unchanged:= true;
      for p in primes do
        map:= PowerMap( tbl, p );
        for i in known do
          img:= map[i];
          pp:= p mod orders[i];
          if pp = 0 then
            pp:= p;
          fi;
          if not img in known then
            Append( string, "pwr " );
            Append( string, String( pp ) );
            Append( string, " " );
            Append( string, numbers[ Position( labels, classnames[i] ) ] );
            Append( string, " " );
            Append( string, numbers[ Position( labels,
                                               classnames[ img ] ) ] );
            Append( string, "\n" );
            result[ img ]:= true;
            Add( known, img );
            unchanged:= false;
          fi;
        od;
      od;
    until unchanged;

    # Use Galois conjugacy to fill missing entries.
    for i in Difference( [ 1 .. nccl ], known ) do
      if not IsBound( result[i] ) then
        orb:= ClassOrbit( tbl, i );
        k:= First( orb, x -> x in known );
        if k = fail then
          Info( InfoCMeatAxe, 1,
                "at least Galois orbit representatives of classes in\n",
                "#I  `", classnames{ orb }, "' are missing" );
          return fail;
        fi;
        for j in orb do

          e:= 1;
          while not IsBound( result[j] ) do

            # Find a *small* power that maps k to j.
            e:= e+1;
            if orders[k] mod e <> 0 then
              if PowerMap( tbl, e, k ) = j then
                Append( string, "pwr " );
                Append( string, String( e ) );
                Append( string, " " );
                Append( string, numbers[ Position( labels,
                                         classnames[k] ) ] );
                Append( string, " " );
                Append( string, numbers[ Position( labels,
                                                   classnames[j] ) ] );
                Append( string, "\n" );
                result[j]:= true;
              fi;
            fi;

          od;

        od;
      fi;
    od;

    # Write the `echo' and `oup' statements.
    # (Split the output specifications into lines if necessary.)
    i:= 1;
    namline:= "";
    resline:= "";
    inline:= 0;
    while i <= nccl do
      if    60 < Length( namline ) + Length( classnames[i] )
         or 60 < Length( resline ) + Length( numbers[ Position( labels,
                                         classnames[i] ) ] ) then
        Append( string,
            Concatenation( "echo \"Classes", namline, "\"\n" ) );
        Append( string,
            Concatenation( "oup ", String( inline ), resline, "\n" ) );
        namline:= "";
        resline:= "";
        inline:= 0;
      fi;
      Add( namline, ' ' );
      Append( namline, classnames[i] );
      Add( resline, ' ' );
      Append( resline, numbers[ Position( labels, classnames[i] ) ] );
      inline:= inline + 1;
      i:= i + 1;
    od;
    if inline <> 0 then
      Append( string,
          Concatenation( "echo \"Classes", namline, "\"\n" ) );
      Append( string,
          Concatenation( "oup ", String( inline ), resline, "\n" ) );
    fi;

    # Return the string.
    return string;
end );


#############################################################################
##
#F  CurrentDateTimeString( [<options>] )
##
InstallGlobalFunction( CurrentDateTimeString, function( arg )
    local options, name, str, out;

    if Length( arg ) = 0 then
      options:= [ "-u", "+%s" ];
    elif Length( arg ) = 1 then
      options:= arg[1];
    fi;

    name:= Filename( DirectoriesSystemPrograms(), "date" );
    if name = fail then
      return "unknown";
    fi;

    str:= "";
    out:= OutputTextString( str, true );
    Process( DirectoryCurrent(), name, InputTextNone(), out, options );
    CloseStream( out );

    # Strip the trailing newline character.
    Unbind( str[ Length( str ) ] );

    # In the default case, transform to a format that is compatible with
    # `StringDate' and `StringTime'.
    if Length( arg ) = 0 then
      str:= Int( str );
      str:= Concatenation( StringDate( Int( str / 86400 ) ),
                           ", ",
                           StringTime( 1000 * ( str mod 86400 ) ),
                           " UTC" );
    fi;

    return str;
end );


#############################################################################
##
#F  SendMail( <sendto>, <copyto>, <subject>, <text> )
##
InstallGlobalFunction( SendMail, function( sendto, copyto, subject, text )
    local sendmail, inp;

    sendto:= JoinStringsWithSeparator( sendto, "," );
    copyto:= JoinStringsWithSeparator( copyto, "," );
    sendmail:= Filename( DirectoriesSystemPrograms(), "mail" );
    inp:= InputTextString( text );

    return Process( DirectoryCurrent(), sendmail, inp, OutputTextNone(),
                    [ "-s", subject, "-c", copyto, sendto ] );
end  );


#############################################################################
##
#F  ParseBackwards( <string>, <format> )
##
InstallGlobalFunction( "ParseBackwards", function( string, format )
    local result, pos, j, pos2;

    # Scan the string backwards.
    result:= [];
    pos:= Length( string );
    for j in Reversed( format ) do
      if IsString( j ) then
        pos2:= pos - Length( j );
        if pos2 < 0 or string{ [ pos2+1 .. pos ] } <> j then
          return fail;
        fi;
      else
        pos2:= pos;
        while 0 < pos2 and j( string[ pos2 ] ) do
          pos2:= pos2-1;
        od;
      fi;
      if j = IsDigitChar then
        Add( result, Int( string{ [ pos2+1 .. pos ] } ) );
      else
        Add( result, string{ [ pos2+1 .. pos ] } );
      fi;
      pos:= pos2;
    od;
    if 0 < pos then
      return fail;
    fi;

    return Reversed( result );
    end );


#############################################################################
##
#F  ParseBackwardsWithPrefix( <string>, <format> )
##
InstallGlobalFunction( "ParseBackwardsWithPrefix", function( string, format )
    local prefixes, len, flen, fstr, fstrlen, result;

    # Remove string prefixes.
    prefixes:= [];
    len:= Length( string );
    flen:= Length( format );
    while 0 < flen and IsString( format[1] ) do
      fstr:= format[1];
      fstrlen:= Length( fstr );
      if len < fstrlen or string{ [ 1 .. fstrlen ] } <> fstr then
        return fail;
      fi;
      Add( prefixes, fstr );
      string:= string{ [ fstrlen + 1 .. len ] };
      format:= format{ [ 2 .. flen ] };
      len:= len - fstrlen;
      flen:= flen-1;
    od;

    # Parse the remaining string backwards.
    result:= ParseBackwards( string, format );
    if result = fail then
      return fail;
    fi;

    Append( prefixes, result );
    return prefixes;
end );


#############################################################################
##
#F  ParseForwards( <string>, <format> )
##
InstallGlobalFunction( "ParseForwards", function( string, format )
    local result, pos, j, pos2, len;

    result:= [];
    pos:= 0;
    for j in format do
      len:= Length( string );
      if IsString( j ) then
        pos2:= pos + Length( j );
        if len < pos2 or string{ [ pos+1 .. pos2 ] } <> j then
          return fail;
        fi;
      else
        pos2:= pos + 1;
        while pos2 <= len and j( string[ pos2 ] ) do
          pos2:= pos2 + 1;
        od;
        pos2:= pos2 - 1;
      fi;
      if j = IsDigitChar then
        Add( result, Int( string{ [ pos+1 .. pos2 ] } ) );
      else
        Add( result, string{ [ pos+1 .. pos2 ] } );
      fi;
      pos:= pos2;
    od;
    if pos <> len then
      return fail;
    fi;

    return result;
end );


#############################################################################
##
#F  ParseForwardsWithSuffix( <string>, <format> )
##
InstallGlobalFunction( "ParseForwardsWithSuffix", function( string, format )
    local suffixes, len, flen, fstr, fstrlen, result;

    # Remove string suffixes.
    suffixes:= [];
    len:= Length( string );
    flen:= Length( format );
    while 0 < flen and IsString( format[ flen ] ) do
      fstr:= format[ flen ];
      fstrlen:= Length( fstr );
      if len < fstrlen or string{ [ len-fstrlen+1 .. len ] } <> fstr then
        return fail;
      fi;
      suffixes:= Concatenation( [ fstr ], suffixes );
      len:= len - fstrlen;
      flen:= flen-1;
      string:= string{ [ 1 .. len ] };
      format:= format{ [ 1 .. flen ] };
    od;

    # Parse the remaining string forwards.
    result:= ParseForwards( string, format );
    if result = fail then
      return fail;
    fi;

    Append( result, suffixes );
    return result;
end );


#############################################################################
##
#F  IntegratedStraightLineProgramExt( <listofprogs> )
##
##  The idea is to concatenate the lists of lines of the programs in the list
##  <listofprogs> after shifting the positions they refer to.
##  If a program overwrites some of the original generators then we first
##  copy the generators.
##
BindGlobal( "IntegratedStraightLineProgramExt",
    function( listofprogs )
    local n,          # number of inputs of all in `listofprogs'
          lines,      # list of lines of the result program
          results,    # results line of the result program
          nextoffset, # maximal position used up to now
          prog,       # loop over `listofprogs'
          proglines,  # list of lines of `prog'
          offset,     # maximal position used before the current program
          shiftgens,  # use a copy of the original generators
          i, line,    # loop over `proglines'
          newline,    # line with shifted source positions
          j;          # loop over the odd positions in `newline'

    # Check the input.
    if    not IsDenseList( listofprogs )
       or IsEmpty( listofprogs )
       or not ForAll( listofprogs, IsStraightLineProgram ) then
      Error( "<listofprogs> must be a nonempty list ",
             "of straight line programs" );
    fi;
    n:= NrInputsOfStraightLineProgram( listofprogs[1] );
    if not ForAll( listofprogs,
                   prog -> NrInputsOfStraightLineProgram( prog ) = n ) then
      Error( "all in <listofprogs> must have the same number of inputs" );
    fi;

    # Initialize the list of lines, the results line, and the offset.
    lines:= [];
    results:= [];
    nextoffset:= n;

    # Loop over the programs, and add the results to `results'.
    for prog in listofprogs do

      proglines:= LinesOfStraightLineProgram( prog );
      if IsEmpty( proglines ) then
        Error( "each in <listofprogs> must return a single element" );
      fi;

      # Set the positions used up to here.
      offset:= nextoffset;

      # If necessary protect the original generators from being replaced,
      # and work with a shifted copy.
      shiftgens:= false;
      if ForAny( proglines, line ->     Length( line ) = 2
                                    and IsList( line[1] )
                                    and line[2] in [ 1 .. n ] ) then
        Append( lines, List( [ 1 .. n ], i -> [ [ i, 1 ], i + offset ] ) );
        nextoffset:= offset + n;
        shiftgens:= true;
      else
        offset:= offset - n;
      fi;

      # Loop over the program.
      for i in [ 1 .. Length( proglines ) ] do

        line:= proglines[i];

        if   not IsEmpty( line ) and IsInt( line[1] ) then

          # The line describes a word to be appended.
          # (Increase the positions by `offset'.)
          newline:= ShallowCopy( line );
          for j in [ 1, 3 .. Length( newline )-1 ] do
            if shiftgens or n < newline[j] then
              newline[j]:= newline[j] + offset;
            fi;
          od;
          if i = Length( proglines ) then
            Add( results, newline );
          else
            Add( lines, newline );
            nextoffset:= nextoffset + 1;
          fi;

        elif 2 = Length( line ) and IsInt( line[2] ) then

          # The line describes a word that shall replace.
          # (Increase the positions and the destination by `offset'.)
          newline:= ShallowCopy( line[1] );
          for j in [ 1, 3 .. Length( newline )-1 ] do
            if shiftgens or n < newline[j] then
              newline[j]:= newline[j] + offset;
            fi;
          od;
          if i = Length( proglines ) then
            Add( results, newline );
          else
            newline:= [ newline, line[2] + offset ];
            Add( lines, newline );
            if nextoffset < newline[2] then
              nextoffset:= newline[2];
            fi;
          fi;

        else

          # The line describes a list of words to be returned.
          line:= List( line, ShallowCopy );
          for newline in line do
            for j in [ 1, 3 .. Length( newline )-1 ] do
              if shiftgens or n < newline[j] then
                newline[j]:= newline[j] + offset;
              fi;
            od;
          od;
          Append( results, line );

        fi;

      od;

    od;

    # Add the results line.
    Add( lines, results );

    # Construct and return the new program.
    return StraightLineProgramNC( lines, n );
    end );


#############################################################################
##
#F  AGR.CompareAsNumbersAndNonnumbers( <nam1>, <nam2> )
##
##  This function is available as `BrowseData.CompareAsNumbersAndNonnumbers'
##  if the Browse package is available.
##  But we must deal also with the case that this package is not available.
##
AGR.CompareAsNumbersAndNonnumbers:= function( nam1, nam2 )
    local len1, len2, len, digit, comparenumber, i;

    # Essentially the code does the following, just more efficiently.
    # return BrowseData.SplitStringIntoNumbersAndNonnumbers( nam1 ) <
    #        BrowseData.SplitStringIntoNumbersAndNonnumbers( nam2 );

    len1:= Length( nam1 );
    len2:= Length( nam2 );
    len:= len1;
    if len2 < len then
      len:= len2;
    fi;
    digit:= false;
    comparenumber:= 0;
    for i in [ 1 .. len ] do
      if nam1[i] in DIGITS then
        if nam2[i] in DIGITS then
          digit:= true;
          if comparenumber = 0 then
            # first digit of a number, or previous digits were equal
            if nam1[i] < nam2[i] then
              comparenumber:= 1;
            elif nam1[i] <> nam2[i] then
              comparenumber:= -1;
            fi;
          fi;
        else
          # if digit then the current number in `nam2' is shorter,
          # so `nam2' is smaller;
          # if not digit then a number starts in `nam1' but not in `nam2',
          # so `nam1' is smaller
          return not digit;
        fi;
      elif nam2[i] in DIGITS then
        # if digit then the current number in `nam1' is shorter,
        # so `nam1' is smaller;
        # if not digit then a number starts in `nam2' but not in `nam1',
        # so `nam2' is smaller
        return digit;
      else
        # both characters are non-digits
        if digit then
          # first evaluate the current numbers (which have the same length)
          if comparenumber = 1 then
            # nam1 is smaller
            return true;
          elif comparenumber = -1 then
            # nam2 is smaller
            return false;
          fi;
          digit:= false;
        fi;
        # now compare the non-digits
        if nam1[i] <> nam2[i] then
          return nam1[i] < nam2[i];
        fi;
      fi;
    od;

    if digit then
      # The suffix of the shorter string is a number.
      # If the longer string continues with a digit then it is larger,
      # otherwise the first digits of the number decide.
      if len < len1 and nam1[ len+1 ] in DIGITS then
        # nam2 is smaller
        return false;
      elif len < len2 and nam2[ len+1 ] in DIGITS then
        # nam1 is smaller
        return true;
      elif comparenumber = 1 then
        # nam1 is smaller
        return true;
      elif comparenumber = -1 then
        # nam2 is smaller
        return false;
      fi;
    fi;

    # Now the longer string is larger.
    return len1 < len2;
    end;


#############################################################################
##
#E

