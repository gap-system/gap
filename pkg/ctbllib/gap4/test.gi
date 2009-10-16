#############################################################################
##
#W  test.gi             GAP character table library             Thomas Breuer
##
#H  @(#)$Id: test.gi,v 1.34 2007/07/03 07:13:41 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementations of functions to test the data
##  available in the {\GAP} Character Table Library.
##
##  1. General tools for checking character tables
##  2. Check ``construction tables''
##
Revision.( "ctbllib/gap4/test_gi" ) :=
    "@(#)$Id: test.gi,v 1.34 2007/07/03 07:13:41 gap Exp $";


#############################################################################
##
##  1. General tools for checking character tables
##


#############################################################################
##
#F  CTblLibTestMax( )
#F  CTblLibTestMax( <tblname> )
##
InstallGlobalFunction( CTblLibTestMax, function( arg )
    local result, name, parse, sub, tbl, fus;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 1 then
      name:= arg[1];
      parse:= PParseBackwards( arg[1], [ IsChar, "m", IsDigitChar ] );
      if parse <> fail and parse[3] <> 0
                       and ForAny( parse[1], IsAlphaChar ) then
#T and different from 'x'!
        sub:= CharacterTable( name );
        tbl:= CharacterTable( parse[1] );
        if   sub = fail then
          Print( "#I  no character table with name `", name, "'\n" );
          result:= false;
        elif tbl = fail then
          Print( "#I  no character table with name `", parse[1], "'\n" );
          result:= false;
        elif GetFusionMap( sub, tbl ) = fail then
          Print( "#I  no fusion `", name, "' -> `", parse[1],
                 "' stored\n" );
          fus:= CTblLibTestSubgroupFusion( sub, tbl, false );
          if IsRecord( fus ) and GetFusionMap( sub, tbl ) = fail then
            Print( "#I  store the following fusion `", name, "' -> `",
                   Identifier( tbl ), "':\n",
                   LibraryFusion( Identifier( sub ), fus ) );
          fi;
          result:= false;
        fi;
      fi;
      return result;
    elif Length( arg ) = 0 then
      for name in LIBLIST.firstnames do
        result:= CTblLibTestMax( name ) and result;
      od;
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#F  CTblLibTestSylowNormalizers( )
#F  CTblLibTestSylowNormalizers( <tblname> )
##
InstallGlobalFunction( CTblLibTestSylowNormalizers, function( arg )
    local result, name, sub, size, nsg, classes, tbl, sizetbl, orders, fus;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 1 then
      name:= PParseBackwards( arg[1], [ IsChar, "n", IsDigitChar ] );
      if name <> fail and name[3] <> 0 then
        sub:= CharacterTable( arg[1] );
        if sub = fail then
          Print( "#I  no character table with name `", arg[1], "'\n" );
          result:= false;
        elif not IsPrimeInt( name[3] ) then
          Print( "#E  `", name[3], "' is not a prime for `", arg[1], "'\n" );
          result:= false;
        else
          size:= First( Collected( Factors( Size( sub ) ) ),
                        pair -> pair[1] = name[3] );
          size:= size[1]^size[2];

          # Check that the Sylow `p' subgroup is normal.
          nsg:= ClassPositionsOfNormalSubgroups( sub );
          classes:= SizesConjugacyClasses( sub );
          tbl:= CharacterTable( name[1] );
          if tbl = fail then
            Print( "#E  the name `", arg[1], "' is admissible but `",
                   name[1], "' is not\n" );
          else
            sizetbl:= First( Collected( Factors( Size( tbl ) ) ),
                             pair -> pair[1] = name[3] );
            if   ForAll( nsg, l -> Sum( classes{ l } ) <> size ) then
              Print( "#E  `", arg[1], "': Sylow ", name[3],
                     " subgroup is not normal\n" );
              result:= false;
            elif size <> sizetbl[1]^sizetbl[2] then
              Print( "#E  `", arg[1],
                     "': does not have the same Sylow subgroup as `",
                     name[1], "'\n" );
              result:= false;
            fi;

            # If the Sylow `p' subgroup is cyclic then check the order of the
            # normalizer.
            orders:= OrdersClassRepresentatives( tbl );
            if size in orders and
               Size( sub ) <> SizesCentralizers( tbl )[ Position( orders,
                  size ) ] * Phi( size ) / Number( orders, x -> x = size ) then
              Print( "#E  `", arg[1], "': has not the order of the Sylow ",
                     name[3], " subgroup of `", name[1], "'\n" );
              result:= false;
            fi;

            # Check that a reasonable subgroup fusion is stored.
            fus:= CTblLibTestSubgroupFusion( sub, tbl, false );
            if IsRecord( fus ) and GetFusionMap( sub, tbl ) = fail then
              Print( "#I  store the following fusion `", arg[1],
                     "' -> `", Identifier( tbl ), "':\n",
                     LibraryFusion( Identifier( sub ), fus ) );
            fi;
          fi;
        fi;
      fi;
    elif Length( arg ) = 0 then
      for name in LIBLIST.firstnames do
        result:= CTblLibTestSylowNormalizers( name ) and result;
      od;
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#F  CTblLibTestElementCentralizers( )
#F  CTblLibTestElementCentralizers( <tblname> )
##
InstallGlobalFunction( CTblLibTestElementCentralizers, function( arg )
    local result, sub, cen, record, fus, tbl, centralizers, i, name, info,
          cand, orders, cname;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 1 then

      sub:= CharacterTable( arg[1] );
      if sub = fail then
        Print( "#I  no character table with name `", arg[1], "'\n" );
        return false;
      fi;
      cen:= ClassPositionsOfCentre( sub );

      # Deal with the possibility that `sub' is an element centralizer
      # in a bigger table.
      # (We do this only once for each table not for each name.)
      if arg[1] = LowercaseString( Identifier( sub ) ) then
        if 1 < Length( cen ) then
          for record in ComputedClassFusions( sub ) do
            fus:= record.map;
            if Length( ClassPositionsOfKernel( fus ) ) = 1 then
              tbl:= CharacterTable( record.name );
              if tbl <> fail then
                centralizers:= SizesCentralizers( tbl );
                for i in [ 2 .. Length( cen ) ] do
                  if centralizers[ fus[ cen[i] ] ] = Size( sub ) then
                    name:= Concatenation( Identifier( tbl ), "C",
                               ClassNames( tbl )[ fus[ cen[i] ] ] );
                    info:= LibInfoCharacterTable( name );
                    if info = fail then
                      Print( "#I  add the name `", name, "' for `",
                             Identifier( sub ), "'\n" );
                    elif info.firstName <> Identifier( sub ) then
                      Print( "#E  `", name, "' should be a name for `",
                             Identifier( sub ), "' not `", info.firstName,
                             "'\n" );
                      result:= false;
                    fi;
                  fi;
                od;
              fi;
            fi;
          od;
        fi;
      fi;

      # Deal with the case that the name has the form `<grpname>C<nam>'.
      name:= PParseBackwards( arg[1],
                 [ IsChar, "c", IsDigitChar, IsAlphaChar ] );
      if name <> fail and name[3] <> 0 and not IsEmpty( name[4] ) then
        tbl:= CharacterTable( name[1] );
        if tbl = fail then
          Print( "#E  the name `", arg[1], "' is admissible but `",
                 name[1], "' is not\n" );
          return false;
        fi;

        # Check that a reasonable subgroup fusion is stored.
        fus:= CTblLibTestSubgroupFusion( sub, tbl, false );
        if IsRecord( fus ) and GetFusionMap( sub, tbl ) = fail then
          Print( "#I  store the following fusion `", name, "' -> `",
                 Identifier( tbl ), "':\n",
                 LibraryFusion( Identifier( sub ), fus ) );
        fi;

        # Check that there is a class whose centralizer order equals
        # the size of `subtbl', and that the fusion is compatible with
        # the centralizer condition.
        centralizers:= SizesCentralizers( tbl );
        cand:= Filtered( [ 1 .. Length( centralizers ) ],
                   i -> centralizers[i] = Size( sub ) );
        if IsEmpty( cand ) then
          Print( "#E  `", arg[1], "' is not an element centralizer in `",
                 Identifier( tbl ), "'\n" );
          return false;
        fi;

        orders:= OrdersClassRepresentatives( tbl );
        cand:= Filtered( cand, i -> orders[i] = name[3] );
        orders:= OrdersClassRepresentatives( sub );
        cen:= Filtered( cen, i -> orders[i] = name[3] );
        if IsRecord( fus ) then
          cen:= Filtered( cen, i -> fus.map[i] in cand );
        fi;
        if IsEmpty( cen ) then
          Print( "#E  `", arg[1], "' is not the centralizer in `",
                 Identifier( tbl ), "'\n",
                 "#E  of an element of order ", name[3], "\n" );
          return false;
        elif IsRecord( fus ) then
          name:= LowercaseString( Concatenation( String( name[3] ), name[4] ) );
          cname:= List( cen,
                     c -> LowercaseString( ClassNames( tbl )[ fus.map[c] ] ) );
          if not name in cname then
            Print( "#E  `", arg[1], "' is the centralizer in `",
                   Identifier( tbl ), "'\n",
                   "#E  of a class in `", cname, "' not of `", name, "'\n" );
            return false;
          fi;
        fi;
      fi;

    elif Length( arg ) = 0 then
      # Note that it is not sufficient to check the `Identifier' values.
      for name in LIBLIST.allnames do
        result:= CTblLibTestElementCentralizers( name ) and result;
      od;
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#F  CTblLibTestElementNormalizers( )
#F  CTblLibTestElementNormalizers( <tblname> )
##
InstallGlobalFunction( CTblLibTestElementNormalizers, function( arg )
    local result, sub, orders, classes, cen, record, fus, tbl, centralizers,
          orbits, i, j, name, info, cand, cname;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 1 then

      sub:= CharacterTable( arg[1] );
      if sub = fail then
        Print( "#I  no character table with name `", arg[1], "'\n" );
        return false;
      fi;
      orders:= OrdersClassRepresentatives( sub );
      classes:= SizesConjugacyClasses( sub );
      cen:= Filtered( [ 1 .. NrConjugacyClasses( sub ) ],
                i -> orders[i] = Sum( classes{
                     ClassPositionsOfNormalClosure( sub, [ i ] ) } ) );

      # Deal with the possibility that `sub' is an element normalizer
      # in a bigger table.
      # (We do this only once for each table not for each name.)
      if arg[1] = LowercaseString( Identifier( sub ) ) then
        if 1 < Length( cen ) then
          for record in ComputedClassFusions( sub ) do
            fus:= record.map;
            if Length( ClassPositionsOfKernel( fus ) ) = 1 then
              tbl:= CharacterTable( record.name );
              if tbl <> fail then
                centralizers:= SizesCentralizers( tbl );
                orders:= OrdersClassRepresentatives( tbl );
                orbits:= List( [ 1 .. NrConjugacyClasses( tbl ) ],
                               i -> Length( ClassOrbit( tbl, i ) ) );
                for i in [ 2 .. Length( cen ) ] do
                  j:= fus[ cen[i] ];
                  if centralizers[j] * Phi( orders[j] ) / orbits[j]
                     = Size( sub ) then
                    name:= Concatenation( Identifier( tbl ), "N",
                               ClassNames( tbl )[ fus[ cen[i] ] ] );
                    info:= LibInfoCharacterTable( name );
                    if info = fail then
                      Print( "#I  add the name `", name, "' for `",
                             Identifier( sub ), "'\n" );
                    elif info.firstName <> Identifier( sub ) then
                      Print( "#E  `", name, "' should be a name for `",
                         Identifier( sub ), "' not `", info.firstName, "'\n" );
                      result:= false;
                    fi;
                  fi;
                od;
              fi;
            fi;
          od;
        fi;
      fi;

      # Deal with the case that the name has the form `<grpname>N<nam>'.
      name:= PParseBackwards( arg[1],
                 [ IsChar, "n", IsDigitChar, IsAlphaChar ] );
      if name <> fail and name[3] <> 0 and not IsEmpty( name[4] ) then
        tbl:= CharacterTable( name[1] );
        if tbl = fail then
          Print( "#E  the name `", arg[1], "' is admissible but `",
                 name[1], "' is not\n" );
          return false;
        fi;

        # Check that a reasonable subgroup fusion is stored.
        fus:= CTblLibTestSubgroupFusion( sub, tbl, false );
        if IsRecord( fus ) and GetFusionMap( sub, tbl ) = fail then
          Print( "#I  store the following fusion `", name, "' -> `",
                 Identifier( tbl ), "':\n",
                 LibraryFusion( Identifier( sub ), fus ) );
        fi;

        # Check that there is a class whose normalizer order equals
        # the size of `subtbl', and that the fusion is compatible with
        # the normalizer condition.
        centralizers:= SizesCentralizers( tbl );
        orders:= OrdersClassRepresentatives( tbl );
        orbits:= List( [ 1 .. NrConjugacyClasses( tbl ) ],
                       i -> Length( ClassOrbit( tbl, i ) ) );
        cand:= Filtered( [ 1 .. Length( centralizers ) ],
                   i -> centralizers[i] * Phi( orders[i] ) / orbits[i]
                        = Size( sub ) );
        if IsEmpty( cand ) then
          Print( "#E  `", arg[1], "' is not an element normalizer in `",
                 Identifier( tbl ), "'\n" );
          return false;
        fi;

        cand:= Filtered( cand, i -> orders[i] = name[3] );
        orders:= OrdersClassRepresentatives( sub );
        cen:= Filtered( cen, i -> orders[i] = name[3] );
        if IsRecord( fus ) then
          cen:= Filtered( cen, i -> fus.map[i] in cand );
        fi;
        if IsEmpty( cen ) then
          Print( "#E  `", arg[1], "' is not the normalizer in `",
                 Identifier( tbl ), "'\n",
                 "#E  of an element of order ", name[3], "\n" );
          return false;
        elif IsRecord( fus ) then
          name:= LowercaseString( Concatenation( String( name[3] ), name[4] ) );
          cname:= List( cen,
                     c -> LowercaseString( ClassNames( tbl )[ fus.map[c] ] ) );
          if not name in cname then
            Print( "#E  `", arg[1], "' is the centralizer in `",
                   Identifier( tbl ), "'\n",
                   "#E  of a class in `", cname, "' not of `", name, "'\n" );
            return false;
          fi;
        fi;
      fi;

    elif Length( arg ) = 0 then
      # Note that it is not sufficient to check the `Identifier' values.
      for name in LIBLIST.allnames do
        result:= CTblLibTestElementNormalizers( name ) and result;
      od;
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#V  CTblLibHardFusions
##
##  `CTblLibHardFusions' is a list of pairs `[ <subname>, <tblname> ]'
##  where <subname> and <tblname> are `Identifier' values of character
##  tables such that `CTblLibTestSubgroupFusion' shall omit the compatibility
##  check for the class fusion between these tables.
##
InstallValue( CTblLibHardFusions, [] );

Add( CTblLibHardFusions, [ "Co1N3", "Co1" ] );
Add( CTblLibHardFusions, [ "Co1N2", "Co1" ] );
Add( CTblLibHardFusions, [ "Co2N2", "Co2" ] );
Add( CTblLibHardFusions, [ "Fi22N3", "Fi22" ] );
     # computed via factorization through 3^(1+6):2^(3+4):3^2:2
Add( CTblLibHardFusions, [ "M24N2", "M24" ] );
     # computed from the groups, time 227180 msec, incl. tables comput.
     # (25-11-2002)
Add( CTblLibHardFusions, [ "M24N2", "He" ] );
     # computed from the groups, time 12451360 msec, incl. tables comput.
     # (26-11-2002)
Add( CTblLibHardFusions, [ "O8+(3)M14", "O8+(3)" ] );
     # 1 orbit, 648 sol., time 154539590 msec on regulus (22-11-2002)
Add( CTblLibHardFusions, [ "L3(3)", "B" ] );
     # 1 orbit, 36 sol., harmless if one forbids decomposition
Add( CTblLibHardFusions, [ "2^2xF4(2)", "2.2E6(2).2" ] );
Add( CTblLibHardFusions, [ "(3^2:D8xU4(3).2^2).2", "B" ] );


#############################################################################
##
#F  CTblLibTestDecompositions( <sub>, <fuslist>, <tbl> )
##
InstallGlobalFunction( CTblLibTestDecompositions,
    function( sub, fuslist, tbl )
    local bad, p, modtbl, modsub, fus, modfus;

    bad:= [];

    for p in Set( Factors( Size( tbl ) ) ) do
      modtbl:= tbl mod p;
      if modtbl <> fail then
        modsub:= sub mod p;
        if modsub <> fail then
          for fus in fuslist do
            modfus:= CompositionMaps( InverseMap(
                                          GetFusionMap( modtbl, tbl ) ),
                         CompositionMaps( fus,
                             GetFusionMap( modsub, sub ) ) );
            if fail in Decomposition( Irr( modsub ),
                           List( Irr( modtbl ), chi -> chi{ modfus } ),
                           "nonnegative" ) then
              AddSet( bad, fus );
            fi;
          od;
        fi;
      fi;
    od;

    return Difference( fuslist, bad );
    end );
#T improve: check only those fusions that really differ on the
#T p-regular classes -- avoid doing the same test several times!

#T Jon Thackray says: LinearIndependentColumns runs forever in
#T some computation with Ly ...


#############################################################################
##
#F  InitFusionsStatistics( <statfile> )
#F  AmendFusionsStatistics( <statinfo>, <entry> )
#F  FinalizeFusionsStatistics( <statinfo> )
##
##  Create a file with information about all subgroup fusions stored in the
##  {\GAP} Character Table Library.
##  For the fusion from the table with identifier <subtbl> into that with
##  identifier <tbl>, a list entry of the following form is printed.
##
##  `[<subtbl>,<tbl>,<nrfus>,<nrorbs>,<nrcomp>,<nrcorbs>,<normtime>],'
##
##  Here <nrfus> is the number of fusions,
##  <nrorbs> is the number of orbits on the maps under table automorphisms,
##  <nrcomp> is the number of those fusions that are compatible with the
##  Brauer tables available for <subtbl> and <tbl>,
##  <nrcorbs> is the number of orbits on the compatible maps under table
##  automorphisms, and
##  <normtime> is the time needed to compute the fusions,
##  divided by ... (so this value is expected to be more or less independent
##  of the machine used).
##
##  Thus the fusion is unique if <nrfus> is $1$,
##  it is unique up to table automorphisms if <nrorbs> is $1$;
##  otherwise the fusion is ambiguous.
##  If <nrcomp> is smaller than <nrfus> then the Brauer tables impose
##  extra conditions on the fusions, and if <nrcorbs> is smaller than
##  <nrorbs> then the Brauer tables reduce the ambiguity.
##
BindGlobal( "InitFusionsStatistics", function( statfile )
    local time, l, i, j;

    # Measure the time for some typical computations.
    time:= Runtime();
    l:= [];                  
    for i in [ 1 .. 1000 ] do
      for j in [ 1 .. 1000 ] do
        l[j]:= j;
      od;
    od;
    time:= ( Runtime() - time );

    # Create the file.
    PrintTo( statfile, "[\n" );

    return rec( statfile:= statfile, time:= time );
    end );

BindGlobal( "AmendFusionsStatistics", function( statinfo, entry )
    AppendTo( statinfo.statfile, Concatenation( "[\"",
        entry[1],
        "\",\"",
        entry[2],
        "\",",
        String( entry[3] ),
        ",",
        String( entry[4] ),
        ",",
        String( entry[5] ),
        ",",
        String( entry[6] ),
        ",",
        String( Int( entry[7] / statinfo.time ) ),
        "],\n" ) );
    end );

BindGlobal( "FinalizeFusionsStatistics", function( statinfo )
    AppendTo( statinfo.statfile, "\n];\n" );
    end );


#############################################################################
##
#F  CTblLibTestSubgroupFusion( <sub>, <tbl>, <statfile> )
##
InstallGlobalFunction( CTblLibTestSubgroupFusion,
    function( sub, tbl, statfile )
    local fusrec, storedfus, time, fus, filt, fusreps, filtreps, result, bad;
Print( "test subgroup fusion ", sub, " -> ", tbl, "\n" );

    fusrec:= First( ComputedClassFusions( sub ),
                    record -> record.name = Identifier( tbl ) );

    # Shall the test be omitted?
    if [ Identifier( sub ), Identifier( tbl ) ] in CTblLibHardFusions then
      if fusrec = fail then
        Print( "#E  omitting fusion check for ", Identifier( sub ), " -> ",
               Identifier( tbl ), " (no map stored)\n" );
      else
        # At least test the existing map for consistency.
        fus:= PossibleClassFusions( sub, tbl,
                  rec( fusionmap:= fusrec.map ) );
        if IsEmpty( fus ) then
          Print( "#E  stored fusion `", Identifier( sub ), "' -> `",
                 Identifier( tbl ), "' is wrong\n" );
        else
          Print( "#I  omitting fusion check for ", Identifier( sub ), " -> ",
                 Identifier( tbl ), "\n" );
        fi;
      fi;
      return fusrec;
    fi;

    if fusrec = fail then
      fusrec:= rec();
      storedfus:= fail;
    else
      storedfus:= fusrec.map;
    fi;
    time:= Runtime();
    fus:= PossibleClassFusions( sub, tbl );
    time:= Runtime() - time;
    fusreps:= RepresentativesFusions( sub, fus, tbl );
    filt:= CTblLibTestDecompositions( sub, fus, tbl );
    filtreps:= RepresentativesFusions( sub, filt, tbl );

    # Amend the statistics if wanted.
    if IsRecord( statfile ) then
      AmendFusionsStatistics( statfile, [
          Identifier( sub ),
          Identifier( tbl ),
          Length( fus ),
          Length( fusreps ),
          Length( filt ),
          Length( filtreps ),
          time ] );
    fi;

    # Do the tables and fusions fit together?
    if   IsEmpty( fus ) then
      Print( "#E  no fusion `", Identifier( sub ), "' -> `",
             Identifier( tbl ), "' possible\n" );
      result:= false;
    elif storedfus <> fail and not storedfus in fus then
      Print( "#E  stored fusion `", Identifier( sub ), "' -> `",
             Identifier( tbl ), "' is wrong,\n" );
      result:= false;
    elif Length( fus ) = 1 then
      # The fusion is unique.
      if IsEmpty( filt ) then
        Print( "#E  unique fusion `", Identifier( sub ), "' -> `",
             Identifier( tbl ), "' contradicts Brauer tables\n" );
        result:= false;
      else
        if IsBound( fusrec.text )
           and fusrec.text <> "fusion map is unique"
           and ( Length( fusrec.text ) < 21 or
                 fusrec.text{ [ 1 .. 21 ] } <> "fusion map is unique," )
           and ( Length( fusrec.text ) < 22 or
                 fusrec.text{ [ 1 .. 22 ] } <> "fusion map is unique (" )
        then
          Print( "#E  text for stored fusion `", Identifier( sub ),
                 "' -> `", Identifier( tbl ),
                 "' is wrong (map is unique!)\n" );
        fi;
        result:= rec( name := Identifier( tbl ),
                      map  := fus[1],
                      text := "fusion map is unique" );
      fi;
    elif 1 < Length( filtreps ) then
      # The fusion is ambiguous.
      if storedfus = fail then
        Print( "#E  ambiguous fusion `", Identifier( sub ), "' -> `",
               Identifier( tbl ), "', no map stored\n" );
        result:= fail;
      elif not IsBound( fusrec.text ) then
        # The ambiguity of the fusion is not mentioned in the stored fusion.
        Print( "#E  ambiguous fusion `", Identifier( sub ), "' -> `",
               Identifier( tbl ), "', no text stored\n" );
        result:= fail;
      elif     PositionSublist( fusrec.text, "together" ) = fail
           and PositionSublist( fusrec.text, "determined" ) = fail then
        # The ambiguity of the fusion is not mentioned in the stored fusion.
        Print( "#E  ambiguous fusion `", Identifier( sub ), "' -> `",
               Identifier( tbl ),
               "',\n#E  without \"together\" or \"determined\" in text\n" );
        result:= fail;
      else
        result:= fusrec;
      fi;

      # If the ambiguity is caused by the consideration of the Brauer tables
      # then this effect of a generality problem should be mentioned in the
      # text.
      if     Length( fusreps ) = 1
         and not ( IsBound( fusrec.text ) and
                   PositionSublist( fusrec.text, "Brauer" ) <> fail ) then
        Print( "#E  ambiguity in fusion `", Identifier( sub ), "' -> `",
               Identifier( tbl ), "'\n",
               "#E  caused by Brauer tables, this should be mentioned\n" );
        result:= fail;
      fi;
    elif Length( filt ) = Length( fus ) then
      # The fusion is unique up to table automorphisms.
      # (Keep the stored fusion if exists.)
      if IsBound( fusrec.text ) and
         PositionSublist( fusrec.text, "unique up to table " ) = fail then
        Print( "#E  text for stored fusion `", Identifier( sub ),
               "' -> `", Identifier( tbl ),
               "' is wrong (map is unique up to table automorphisms!)\n" );
      fi;
      if storedfus = fail then
        fus:= fus[1];
      else
        fus:= storedfus;
      fi;
      result:= rec( name := Identifier( tbl ),
                    map  := fus,
                    text := "fusion map is unique up to table autom." );
    else
      # The Brauer tables impose additional conditions; together with this,
      # the fusion is unique at least up to table automorphisms.
      if   IsEmpty( filt ) then
        Print( "#E  no fusion `", Identifier( sub ), "' -> `",
               Identifier( tbl ), "' compatible with mod. tables\n" );
        result:= false;
      else
        if storedfus = fail then
          fus:= filt[1];
        elif not storedfus in filt then
          Print( "#E  stored fusion `", Identifier( sub ), "' -> `",
                 Identifier( tbl ), "' not compatible with mod. tables\n" );
          fus:= filt[1];
        else
          fus:= storedfus;
        fi;

        result:= rec( name := Identifier( tbl ),
                      map  := fus );

        if Length( fusreps ) = 1 then
          if Length( filt ) = 1 then
            # The fusion is unique.
            result.text := Concatenation(
                      "fusion map is unique up to table autom.,\n",
                      "unique map that is compatible with Brauer tables" );
          else
            # The fusion is unique up to table automorphisms.
            result.text := Concatenation(
                      "fusion map is unique up to table autom.,\n",
                      "compatible with Brauer tables" );
          fi;
        elif Length( filt ) = 1 then
          result.text:= "fusion map uniquely determined by Brauer tables";
        else
          result.text:=
              "fusion map determined up to table autom. by Brauer tables";
        fi;
#T for all cases, check the status in the `InfoText', perhaps print something!
      fi;
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#F  CTblLibTestFactorFusion( <tbl>, <fact> )
##
InstallGlobalFunction( CTblLibTestFactorFusion, function( tbl, fact )
    local storedfus, quot, classes, kernels, fus, ker, f, trans, map, reps,
          record;

Print( "test factor fusion ", tbl, " -> ", fact, "\n" );
    storedfus:= GetFusionMap( tbl, fact );
    quot:= Size( tbl ) / Size( fact );
    classes:= SizesConjugacyClasses( tbl );
    kernels:= Filtered( ClassPositionsOfNormalSubgroups( tbl ),
                        list -> Sum( classes{ list } ) = quot );

    fus:= [];
    for ker in kernels do
      f:= CharacterTableFactorGroup( tbl, ker );
      trans:= TransformingPermutationsCharacterTables( f, fact );
      if IsRecord( trans ) then
        map:= OnTuples( GetFusionMap( tbl, f ), trans.columns );
        Append( fus, Orbit( trans.group, map, OnTuples ) );
      fi;
    od;

    # Do the tables and fusions fit together?
    if IsEmpty( fus ) then
      Print( "#E  no fusion `", Identifier( tbl ), "' ->> `",
             Identifier( fact ), "' possible\n" );
      return false;
    elif storedfus <> fail and not storedfus in fus then
      Print( "#E  stored fusion `", Identifier( tbl ), "' ->> `",
             Identifier( fact ), "' is wrong\n" );
      return false;
    fi;

    # Is the fusion perhaps unique (with given kernel)?
    if Length( fus ) = 1 then
      return rec( name := Identifier( fact ),
                  map  := fus[1],
                  text := "fusion map is unique" );
    fi;

    # Is the fusion perhaps unique up to table automorphisms
    # (with given kernel, of course)?
    reps:= RepresentativesFusions( Group( () ), fus,
               AutomorphismsOfTable( fact ) );
    if Length( reps ) = 1 then
      return rec( name := Identifier( fact ),
                  map  := fus[1],
                  text := "fusion map is unique up to table autom." );
    fi;

    # Is the ambiguity of the fusion perhaps mentioned in the stored fusion?
    if storedfus = fail then
      Print( "#E  ambiguous fusion `", Identifier( tbl ), "' ->> `",
             Identifier( fact ), "', no map stored\n" );
      return fail;
    fi;
    record:= First( ComputedClassFusions( tbl ),
                    x -> x.name = Identifier( fact ) and x.map = storedfus );
#T more possibilities?
    return record;
    end );


#############################################################################
##
#F  CTblLibTestFusions( <statistics> )
#F  CTblLibTestFusions( <tblname>, <statistics> )
##
InstallGlobalFunction( CTblLibTestFusions, function( arg )
    local result, sub, record, tbl, fus, name;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 2 then
      sub:= CharacterTable( arg[1] );
      if sub = fail then
        Print( "#I  no character table with name `", arg[1], "'\n" );
        result:= false;
      else
        for record in ShallowCopy( ComputedClassFusions( sub ) ) do
          tbl:= CharacterTable( record.name );
          # Do not report a problem if `fail' is returned,
          # since direct products involving `sub' may have been
          # constructed before this test started.
          if tbl <> fail then
            if Size( sub ) <= Size( tbl ) then
              fus:= CTblLibTestSubgroupFusion( sub, tbl, arg[2] );
              if not IsRecord( fus ) then
                result:= false;
              elif record.map <> fus.map then
                Print( "#E  replace the stored fusion `", arg[1], "' -> `",
                       record.name, "' by the following one.\n",
                       LibraryFusion( arg[1], fus ) );
              fi;
            else
              fus:= CTblLibTestFactorFusion( sub, tbl );
              if not IsRecord( fus ) then
                result:= false;
              fi;
            fi;
          fi;
        od;
      fi;
    elif Length( arg ) = 1 then
      for name in LIBLIST.firstnames do
        result:= CTblLibTestFusions( name, arg[1] ) and result;
      od;
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#F  CTblLibTestPowerMaps( )
#F  CTblLibTestPowerMaps( <tblname> )
##
##  First suppose that `CTblLibTestPowerMaps' is called with one
##  argument <tblname>, which is an admissible name of a character table.
##  Then it is checked whether all power maps of prime divisors of the group
##  order are stored on the table, and whether they are correct.
##  (This includes the information about ambiguities of the power maps in the
##  `InfoText' values of the tables.)
##
##  If no argument is given then all standard character table names are
##  checked with the one argument version.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
InstallGlobalFunction( CTblLibTestPowerMaps, function( arg )
    local result, tbl, powermaps, info, p, pow, reps, storedmap, name;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 1 then

      tbl:= CharacterTable( arg[1] );
      if tbl = fail then
        Print( "#I  no character table with name `", arg[1], "'\n" );
        result:= false;
      else
        powermaps:= ComputedPowerMaps( tbl );
        if HasInfoText( tbl ) then
          info:= InfoText( tbl );
        else
          info:= "";
        fi;
        for p in Set( Factors( Size( tbl ) ) ) do

          pow:= PossiblePowerMaps( tbl, p );
          reps:= RepresentativesPowerMaps( pow,
                     MatrixAutomorphisms( Irr( tbl ) ) );
          if not IsBound( powermaps[p] ) then
            Print( "#I  no ", Ordinal( p ), " power map stored on table `",
                   arg[1], "'\n" );
            storedmap:= fail;
          else
            storedmap:= powermaps[p];
          fi;

          if   IsEmpty( pow ) then
            Print( "#E  no ", Ordinal( p ), " power map possible for `",
                   Identifier( tbl ), "'\n" );
            result:= false;
          elif storedmap <> fail and not storedmap in pow then
            Print( "#E  stored ", Ordinal( p ), " power map for `",
                   Identifier( tbl ), "' is wrong\n" );
            result:= false;
          elif Length( reps ) <> 1 then
            if PositionSublist( info, Concatenation( Ordinal( p ),
                   " power map determined" ) ) = fail then
              Print( "#E  ambiguous ", Ordinal( p ), " power map for `",
                     Identifier( tbl ), "'\n" );
              result:= false;
            fi;
          elif Length( pow ) <> 1 then
            if PositionSublist( info, Concatenation( Ordinal( p ),
                   " power map determined only up to matrix automorphism" ) )
                   <> fail then
              Print( "#E  ", Ordinal( p ), " power map for `",
                     Identifier( tbl ), "' is det. only up to mat. aut.\n" );
              result:= false;
            fi;
          elif PositionSublist( info, Concatenation( Ordinal( p ),
                   " power map determined" ) ) <> fail then
            Print( "#E  unnecessary statement about ", Ordinal( p ),
                   " power map for `", Identifier( tbl ), "'\n" );
            result:= false;
          fi;

          if storedmap = fail then
            if   Length( pow ) = 1 then
              Print( "#I  store the following unique ", Ordinal( p ),
                     " power map on `", Identifier( tbl ), "':\n", pow[1],
                     "\n" );
            elif Length( reps ) = 1 then
              Print( "#I  store the following ", Ordinal( p ),
                     " power map on `", Identifier( tbl ), "':\n", reps[1],
                     "\n#I  (unique up to matrix automorphisms)\n" );
            fi;
          fi;

        od;
      fi;

    elif Length( arg ) = 0 then
      for name in LIBLIST.firstnames do
        result:= CTblLibTestPowerMaps( name ) and result;
      od;
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#F  CTblLibTestBlocksInfo( <modtbl> )
##
InstallGlobalFunction( CTblLibTestBlocksInfo, function( modtbl )
    local info, i, record;

    info:= BlocksInfo( modtbl );
    for i in [ 1 .. Length( info ) ] do
      if     IsBound( info[i].decinv )
         and not ForAll( Concatenation( info[i].decinv ), IsInt ) then
        Print( "#E  `", modtbl, "': nonintegral entry in ", Ordinal( i ),
               " `decinv'\n" );
      fi;
      if not ForAll( Concatenation( DecompositionMatrix( modtbl, i ) ),
                     IsInt ) then
        Print( "#E  `", modtbl, "': nonintegral entry in ", Ordinal( i ),
               " dec. mat.\n" );
      fi;
    od;

    return true;
    end );


#############################################################################
##
#F  CTblLibTestTensorDecomposition( <modtbl> )
##
InstallGlobalFunction( CTblLibTestTensorDecomposition, function( modtbl )
    local ibr, i, tens;

    ibr:= IBr( modtbl );
    for i in [ 1 .. Length( ibr ) ] do
      tens:= Set( Tensored( [ ibr[i] ], ibr{ [ 1 .. i ] } ) );
      if not ForAll( Decomposition( ibr, tens, "nonnegative" ), IsList ) then
        Print( "#E  tensor decomp. for ", Identifier( modtbl ),
               " failed for products with X[", i, "]\n" );
        return false;
      fi;
    od;
    if HasInfoText( modtbl ) and
       PositionSublist( InfoText( modtbl ), "TENS" ) = fail then
      Print( "#I  add \"TENS\" to `InfoText' for ", Identifier( modtbl ),
             "\n" );
    fi;

    return true;
    end );


#############################################################################
##
#F  CTblLibTestIndicators( <modtbl> )
##
InstallGlobalFunction( CTblLibTestIndicators, function( modtbl )
    local ind, modind, unknown, irr, result, i, info, decmat, j, chi, odd;

    if not IsBrauerTable( modtbl ) then
      Error( "<modtbl> must be a Brauer table" );
    elif     UnderlyingCharacteristic( modtbl ) = 2
         and not IsBound( ComputedIndicators( modtbl )[2] ) then
      Print( "#I  2nd indicator for `", Identifier( modtbl ),
             "' is not stored\n" );
      return true;
    fi;

    ind:= Indicator( OrdinaryCharacterTable( modtbl ), 2 );
    modind:= Indicator( modtbl, 2 );
    unknown:= Filtered( [ 1 .. Length( modind ) ],
                        i -> IsUnknown( modind[i] ) );
    if not IsEmpty( unknown ) then
      Print( "#I  ", Identifier( modtbl ), ": ", Length( unknown ),
             " unknown indicators\n" );
    fi;

    irr:= Irr( modtbl );

    result:= true;

    for i in [ 1 .. Length( BlocksInfo( modtbl ) ) ] do

      info:= BlocksInfo( modtbl )[i];
      decmat:= DecompositionMatrix( modtbl, i );

      for j in [ 1 .. Length( info.modchars ) ] do

        chi:= irr[ info.modchars[j] ];

        if   ForAny( chi, x -> GaloisCyc( x, -1 ) <> x ) then

          # The indicator of a Brauer character is zero iff it has
          # at least one nonreal value.
          if modind[ info.modchars[j] ] <> 0 then
            Print( "#E  ", Identifier( modtbl ), ": indicator of X[",
                   info.modchars[j], "] (degree ", chi[1],
                   ") must be 0, not ", modind[ info.modchars[j] ], "\n" );
            result:= false;
          fi;

        elif UnderlyingCharacteristic( modtbl ) <> 2 then

          # The indicator is equal to the indicator of an ordinary character
          # that contains it as a constituent, with odd multiplicity.
          odd:= Filtered( [ 1 .. Length( decmat ) ],
                          x -> decmat[x][j] mod 2 <> 0 );
          if IsEmpty( odd ) then
            Print( "#E  ", Identifier( modtbl ),
                   ": no odd constituent for X[", info.modchars[j],
                   "] (degree ", chi[1], ")\n" );
            result:= false;
          else
            odd:= List( odd, x -> ind[ info.ordchars[x] ] );
            if ForAny( odd,
                   x -> x <> 0 and x <> modind[ info.modchars[j] ] ) then
              if 1 < Length( Set( odd ) ) then
                Print( "#E  ", Identifier( modtbl ),
                       ": ind. of odd const. not unique for X[",
                       info.modchars[j], "] (degree ", chi[1], ")\n" );
              else
                Print( "#E  ", Identifier( modtbl ),
                       ": indicator of X[", i.modchars[j],
                       "] (degree ", chi[1], ") must be ", odd[1], ", not ",
                       modind[ info.modchars[j] ], "\n" );
              fi;
              result:= false;
            fi;
          fi;

        else

          # Test that all nontrivial character degrees are even.
          if not ForAll( chi, x -> x = 1 ) and chi[1] mod 2 <> 0 then
            Print( "#E  ", Identifier( modtbl ), ": degree X[",
                   info.modchars[j], "][1] = ", chi[1],
                   " but should be even\n" );
            result:= false;
          fi;

        fi;
      od;
    od;

    # Return the result.
    return result;
    end );


#############################################################################
##
#F  CTblLibTestInfoText()
#F  CTblLibTestInfoText( <tblname> )
##
InstallGlobalFunction( "CTblLibTestInfoText", function( arg )
    local result, name, tbl, info, pos, pos2, int, pos3, groupname, suptbl,
          maxes;

    result:= true;

    if Length( arg ) = 0 then

      for name in LIBLIST.firstnames do
        result:= CTblLibTestInfoText( name ) and result;
      od;

    elif Length( arg ) = 1 and IsString( arg[1] ) then

      tbl:= CharacterTable( arg[1] );
      name:= Identifier( tbl );

      # If there is no `InfoText' value then nothing is to do.
      if not HasInfoText( tbl ) then
        return true;
      fi;
      for info in SplitString( InfoText( tbl ), "\n" ) do

        # Filter out phrases of the form `maximal subgroup of <grpname>'.
        pos:= PositionSublist( info, "maximal subgroup of " );
        if pos <> fail then

          # Get the character table of the overgroup.
          pos3:= PositionSublist( info, ",", pos + 20 );
          if pos3 = fail then
            pos3:= Length( info ) + 1;
          fi;
          groupname:= info{ [ pos + 20 .. pos3 - 1 ] };
          suptbl:= CharacterTable( groupname );
          if   suptbl = fail then
            Print( "#E  InfoText for `", name, "' contains `",
                   info{ [ pos .. pos3 - 1 ] }, "'\n",
                   "#E  but there is no table of `", groupname, "'\n" );
            return false;
          fi;

          # Check whether there is a class fusion into `suptbl'.
          if GetFusionMap( tbl, suptbl ) = fail then
            Print( "#E  missing fusion ", name, " -> ",
                   Identifier( suptbl ), " in spite of `InfoText'\n" );
          fi;

          if 3 < pos and
            info{ [ pos-2 .. pos-1 ] } in [ "st ", "nd ", "rd ", "th " ] then

            # Get the position in the `Maxes' list.
#T there may be several, separated with ` and '!
            pos2:= pos - 3;
            while 0 < pos2 and IsDigitChar( info[ pos2 ] ) do
              pos2:= pos2-1;
            od;
            int:= Int( info{ [ pos2 + 1 .. pos-3 ] } );

            if int = 0 then
              Print( "#E  InfoText for `", name, "' contains `",
                     info{ [ pos2 + 1 .. pos3 - 1 ] }, "'\n" );
            elif not HasMaxes( suptbl ) then
              Print( "#I  InfoText for `", name, "' contains `",
                     info{ [ pos2 + 1 .. pos3 - 1 ] }, "'\n",
                     "#I  but `", groupname, "' has no `Maxes'\n" );
              return false;
            else

              # Get the `Maxes' value of the character table of the overgroup.
              maxes:= Maxes( suptbl );

              # Compare the two values.
              if Length( maxes ) < int or maxes[ int ] <> name then
                Print( "#E  InfoText for `", name, "' contains `",
                       info{ [ pos2 + 1 .. pos3 - 1 ] }, "'\n",
                       "#E  but the position in `Maxes' for `", groupname,
                       "' is `", Position( maxes, name ), "'\n" );
                return false;
              fi;

            fi;

          fi;

        fi;
      od;
    fi;

    return result;
end );


#############################################################################
##
#V  CTblLibHardTableAutomorphisms
##
InstallValue( CTblLibHardTableAutomorphisms, [] );

Add( CTblLibHardTableAutomorphisms, "O8+(3)M14" );
Add( CTblLibHardTableAutomorphisms, "3.U6(2).3" );
Add( CTblLibHardTableAutomorphisms, "3.U6(2).3mod5" );
Add( CTblLibHardTableAutomorphisms, "3.U6(2).3mod7" );
Add( CTblLibHardTableAutomorphisms, "3.U6(2).3mod11" );


#############################################################################
##
#F  CTblLibTestTableAutomorphisms( [<tbl>] )
##
InstallGlobalFunction( CTblLibTestTableAutomorphisms, function( arg )
    local result, tbl, aut, irr, irrset, stored, p, modtbl;

    # Initialize the result.
    result:= true;

    if Length( arg ) = 1 then

      tbl:= arg[1];

      if   LibInfoCharacterTable( Identifier( tbl ) ) = fail then
        # The table may be a Brauer table that can be constructed from the
        # construction info of its ordinary table.
        result:= true;
      elif Identifier( tbl ) in CTblLibHardTableAutomorphisms then
        # The test shall be omitted?
        Print( "#I  omitting table automorphisms check for ",
               Identifier( arg[1] ), "\n" );
        result:= true;
      elif not HasAutomorphismsOfTable( tbl ) then
        aut:= TableAutomorphisms( tbl, Irr( tbl ), "closed" );
        Print( "#I  table automorphisms missing for `", tbl, "', add\n",
               GeneratorsOfGroup( aut ), "\n" );
        result:= false;
      else
        # Check that the stored automorphisms are automorphisms,
        # and that there are not more automorphisms than the stored ones.
        irr:= Irr( tbl );
        irrset:= Set( irr );
        stored:= AutomorphismsOfTable( tbl );
        aut:= Filtered( GeneratorsOfGroup( stored ),
                  gen -> Set( List( irr,
                                chi -> Permuted( chi, gen ) ) ) = irrset );
        aut:= SubgroupNC( stored, aut );
        if aut <> stored then
          Print( "#E  wrong automorphism(s) stored for `", tbl, "'!\n" );
        fi;
        aut:= TableAutomorphisms( tbl, Irr( tbl ), aut );
        if aut <> stored then
          Print( "#E  replace wrong automorphisms for `", tbl, "' by\n",
                 GeneratorsOfGroup( aut ), "\n" );
          result:= false;
        fi;
      fi;

      # Check also the available Brauer tables.
      if IsOrdinaryTable( tbl ) then
        for p in Set( Factors( Size( tbl ) ) ) do
          modtbl:= tbl mod p;
          if IsCharacterTable( modtbl ) then
            result:= CTblLibTestTableAutomorphisms( modtbl ) and result;
          fi;
        od;
      fi;

    elif Length( arg ) = 0 then
      # Test all ordinary tables.
      result:= AllCharacterTableNames( CTblLibTestTableAutomorphisms, false )
                   = [];
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
##  2. Check ``construction tables''
##


#############################################################################
##
#F  CTblLibTestDirectProductConstruction( <tbl> )
##
##  Check that there are at least two factors.
##
BindGlobal( "CTblLibTestDirectProductConstruction", function( tbl )
    local result, info;

    result:= true;
    info:= ConstructionInfoCharacterTable( tbl );
    if Length( info[2] ) < 2 then
      Print( "#E  for `", Identifier( tbl ),
             "', use `ConstructPermuted' not `ConstructDirectProduct'\n" );
      result:= false;
    fi;

    return result;
end );


#############################################################################
##
#F  CTblLibTestGS3Construction( <tbl> )
##
##  Assume that <tbl> is an ordinary character table such that the first
##  entry of `ConstructionInfoCharacterTable( <tbl> )' is `"ConstructGS3"'.
##  `CTblLibTestGS3Construction' checks whether the action on the classes
##  of the index two subgroup is correct, that the construction with
##  `CharacterTableOfTypeGS3' yields the same irreducibles as those of <tbl>,
##  and that the Brauer tables (if available 
##
BindGlobal( "CTblLibTestGS3Construction", function( tbl )
    local result, info, t2, t3, tnames, t, t3fustbl, aut, poss, ts3,
          p, tmodp, t2modp, t3modp, tblmodp, ts3modp, nsg;

    result:= true;
    info:= ConstructionInfoCharacterTable( tbl );
    t2:= CharacterTable( info[2] );
    t3:= CharacterTable( info[3] );

    tnames:= Intersection( NamesOfFusionSources( t2 ),
                           NamesOfFusionSources( t3 ) );
    t:= Filtered( List( tnames, CharacterTable ),
                  ttbl -> 6 * Size( ttbl ) = Size( tbl ) );
    if Length( t ) <> 1 then
      Print( "#E  table of the kernel of S3 not identified\n" );
      return false;
    fi;
    t:= t[1];

    # Get the action of `tbl' on the classes of `t3'.
    t3fustbl:= GetFusionMap( t3, tbl );
    aut:= Product( List( Filtered( InverseMap( t3fustbl ), IsList ),
                         x -> ( x[1], x[2] ) ), () );
    poss:= PossibleActionsForTypeGS3( t, t2, t3 );
    if not aut in poss then
      Print( "#E  for `", Identifier( tbl ),
             "' the action of G.S3 on G.3 is not possible\n" );
      result:= false;
    elif Length( poss ) <> 1 then
      Print( "#I  for `", Identifier( tbl ),
             "' the action of G.S3 on G.3 is not unique\n" );
      result:= false;
    fi;

    # Check that the two constructions (from the tables of subgroups
    # and from the info stored on `tbl') yield the same result.
    ts3:= CharacterTableOfTypeGS3( t, t2, t3, aut, "test" );
    if Irr( ts3.table ) <> Irr( tbl ) then
      Print( "#E  constructed and library table for `",
             Identifier( tbl ), "' sorted incompatibly\n" );
      result:= false;
    fi;

    # Check that also the Brauer tables are available.
    for p in Set( Factors( Size( tbl ) ) ) do
      tmodp:= t mod p;
      t2modp:= t2 mod p;
      t3modp:= t3 mod p;
      if tmodp <> fail and t2modp <> fail and t3modp <> fail then
        tblmodp:= tbl mod p;
        ts3modp:= CharacterTableOfTypeGS3( tmodp, t2modp, t3modp, tbl,
            Concatenation( Identifier( tbl ), "mod", String( p ) ) );
        if tblmodp = fail then
          # Add the table to the library if it has trivial $O_p(G)$.
          nsg:= List( ClassPositionsOfNormalSubgroups( tbl ),
                      x -> Sum( SizesConjugacyClasses( tbl ){ x } ) );
          if not ForAny( nsg, n -> IsPrimePowerInt( n ) and n mod p = 0 ) then
            AutomorphismsOfTable( ts3modp.table );
#T better call a function that performs all checks for new Brauer tables!
            Print( "#I  add the following ", p, "-modular table of `",
                   Identifier( tbl ), "':\n",
                   CTblLibStringBrauer( ts3modp.table) );
          fi;
        elif Irr( ts3modp.table ) <> Irr( tblmodp ) then
          Print( "#E  constructed and library table for `",
                 Identifier( tbl ), "' sorted incompatibly\n" );
          result:= false;
        fi;
      fi;
    od;

    return result;
end );


#############################################################################
##
#V  CTblLibTestConstructionsFunctions
##
InstallValue( CTblLibTestConstructionsFunctions, [
    "ConstructGS3", CTblLibTestGS3Construction,
    "ConstructDirectProduct", CTblLibTestDirectProductConstruction,
] );


#############################################################################
##
#F  CTblLibTestConstructions()
#F  CTblLibTestConstructions( <tblname> )
##
InstallGlobalFunction( CTblLibTestConstructions, function( arg )
    local result, name, tbl, constr, pos;

    result:= true;

    if Length( arg ) = 0 then
      for name in LIBLIST.firstnames do
        result:= CTblLibTestConstructions( name ) and result;
      od;
    elif Length( arg ) = 1 and IsString( arg[1] ) then
      tbl:= CharacterTable( arg[1] );
      if HasConstructionInfoCharacterTable( tbl ) then

        # Apply tests depending on the construction type of the table.
        constr:= ConstructionInfoCharacterTable( tbl );
        if IsList( constr ) then
          pos:= Position( CTblLibTestConstructionsFunctions,
                          ConstructionInfoCharacterTable( tbl )[1] );
          if pos <> fail then
            return CTblLibTestConstructionsFunctions[ pos + 1 ]( tbl );
          fi;
        fi;

      fi;
    fi;

    return result;
end );


#############################################################################
##
#E

