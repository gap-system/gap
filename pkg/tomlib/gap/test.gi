#############################################################################
##
#W  test.gi             GAP library of tables of marks          Thomas Breuer
##
#H  @(#)$Id: test.gi,v 1.10 2009/03/18 10:08:32 gap Exp $
##
#Y  Copyright (C)  2003,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the implementation of functions to test the data
##  available in the {\GAP} Library of Tables of Marks.
##
Revision.( "tomlib/gap/test_gi" ) :=
    "@(#)$Id: test.gi,v 1.10 2009/03/18 10:08:32 gap Exp $";


#############################################################################
##
#F  TomLibTestStraightLineProgramsAndDerivedSubgroups( )
#F  TomLibTestStraightLineProgramsAndDerivedSubgroups( <tomname> )
##  
##  Check that each table of marks has valid straight line programs,
##  and if yes, that the derived subgroups stored in the table are correct.
##
InstallGlobalFunction( TomLibTestStraightLineProgramsAndDerivedSubgroups,
    function( arg )
    local result, tomname, tom, slp, bad, good, stored, computed, G, H, i,
          string, stream;

    result:= true;

    if   Length( arg ) = 0 then
      for tomname in AllLibTomNames() do
        result:= TomLibTestStraightLineProgramsAndDerivedSubgroups( tomname )
                 and result;
      od;
    elif Length( arg ) = 1 and IsString( arg[1] ) then
      tomname:= arg[1];
      tom:= TableOfMarks( tomname );
      if tom = fail then
        Print( "#E  table of marks for `", tomname, "' is not available\n" );
        result:= false;
      elif not HasStraightLineProgramsTom( tom ) then 
        Print( "#E  no s.l.p.s for table of marks of `", tomname, "'\n" );
        result:= false;
      else
        slp:= StraightLineProgramsTom( tom );
        bad:= Filtered( [ 1 .. Length( slp ) ],
                  i -> not ( IsStraightLineProgram( slp[i] ) or
                       ( IsList( slp[i] ) and ForAll( slp[i],
                                               IsStraightLineProgram ) ) ) );
        if not IsEmpty( bad ) then
          Print( "#E  corrupted s.l.p.s for table of marks of `", tomname,
                 ":'\n",
                 "#E  ", bad, "\n" );
          result:= false;
        fi;
        good:= Difference( [ 1 .. Length( slp ) ], bad );
        G:= UnderlyingGroup( tom );
        for i in [ 1 .. Length( good ) ] do
          H:= RepresentativeTom( tom, good[i] );
          if Size( Subgroup( G, GeneratorsOfGroup( H ) ) )
             <> OrdersTom( tom )[ good[i] ] then
            Print( "#E  `", tomname, "': wrong size for representative ",
                   good[i], "\n" );
            result:= false;
          fi;
          bad:= Filtered( [ 1 .. i-1 ],
             j -> IsConjugate( G, H, RepresentativeTom( tom, good[j] ) ) );
          if not IsEmpty( bad ) then
            Print( "#E  `", tomname, "': representative ", good[i],
                   " is conjugate to represenatives in ", bad, "\n" );
            result:= false;
          fi;
        od;
      fi;

      if not HasDerivedSubgroupsTomUnique( tom ) then
        Print( "#E  no derived subgroups for table of marks of `", tomname,
               "'\n" );
        result:= false;
      else
        stored:= DerivedSubgroupsTomUnique( tom );
        ResetFilterObj( tom, DerivedSubgroupsTomUnique );
        computed:= DerivedSubgroupsTom( tom );
        G:= UnderlyingGroup( tom );
        for i in [ 1 .. Length( computed ) ] do
          if not ( IsInt( computed[i] ) and
                   IsConjugate( G, RepresentativeTom( tom, computed[i] ),
                       DerivedSubgroup( RepresentativeTom( tom, i ) ) ) ) then
            Print( "#E  `", tomname, "': computation of ", Ordinal( i ),
                   " derived subgroup failed\n" );
            result:= false;
          fi;
        od;
        if stored = computed then
          SetDerivedSubgroupsTomUnique( tom, stored );
        elif result <> false then
          string:= "";
          stream:= OutputTextString( string, true );
          SetPrintFormattingStatus( stream, true );
          BlanklessPrintTo( stream, computed, 78, 0, true );
          CloseStream( stream );
          Print( "#E  wrong derived subgroups for table of marks of `",
                 tomname, "'\n",
                 "#E  replace them by\n", string, "\n" );
          result:= false;
        fi;
      fi;
    else
      Error( "usage: TomLibTestStraightLineProgramsAndDerivedSubgroups( ",
             "[<tomname>] )" );
    fi;

    return result;
    end );


#############################################################################
##
#V  TomLibHardFusionsTblToTom
##
##  (Currently hard cases do not occur.)
##
InstallValue( TomLibHardFusionsTblToTom, [] );


#############################################################################
##
#F  TomLibTestFusionTblToTom( <tbl>, <tom>[, <condition>] )
##
InstallGlobalFunction( TomLibTestFusionTblToTom, function( arg )
    local tbl, tom, condition, fusrec, storedfus, fus, fusreps, tblmaxes,
          primperm, tommaxes, compat, result;

    tbl:= arg[1];
    tom:= arg[2];
    if Length( arg ) = 3 then
      condition:= arg[3];
    else
      condition:= ReturnTrue;
    fi;

    if HasFusionToTom( tbl ) then
      fusrec:= FusionToTom( tbl );
      if fusrec.name <> Identifier( tom ) then
        Print( "#E  `FusionToTom' value of `", Identifier( tbl ),
               "' should equal `Identifier' value `", Identifier( tom ),
               "'\n" );
      fi;
    else
      fusrec:= fail;
    fi;

    # Shall the test be omitted?
    if Identifier( tbl ) in TomLibHardFusionsTblToTom then
      if fusrec = fail then
        Print( "#E  omitting check for fusion tbl to tom ",
               Identifier( tbl ), " -> ", Identifier( tom ),
               " (no map stored)\n" );
      else
        # At least test the existing map for consistency.
        fus:= PossibleFusionsCharTableTom( tbl, tom,
                  rec( fusionmap:= fusrec.map ) );
        if IsEmpty( fus ) then
          Print( "#E  stored fusion tbl to tom `", Identifier( tbl ),
                 "' -> `", Identifier( tom ), "' is wrong\n" );
        else
          Print( "#I  omitting check for fusion tbl to tom ",
                 Identifier( tbl ), " -> ", Identifier( tom ), "\n" );
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
    fus:= Filtered( PossibleFusionsCharTableTom( tbl, tom ), condition );

    # If the `Maxes' value of `tbl' is known then choose a fusion
    # that is compatible with the primitive perm. characters if possible.
    compat:= fus;
    if HasMaxes( tbl ) then
      tblmaxes:= List( Maxes( tbl ), CharacterTable );
      primperm:= List( tblmaxes, t -> TrivialCharacter( t )^tbl );
      tommaxes:= MaximalSubgroupsTom( tom )[1];
      compat:= Filtered( fus,
          map -> primperm = PermCharsTom( map, tom ){ tommaxes } );
    fi;

    # (We do *not* use automorphisms of `tom' because
    # the ambiguities can be resolved using the group stored in `tom'.)
    fusreps:= RepresentativesFusions( AutomorphismsOfTable( tbl ), compat,
                  Group( () ) );

    # Do the tables and fusions fit together?
    if   IsEmpty( fus ) then
      Print( "#E  no fusion tbl to tom `", Identifier( tbl ), "' -> `",
             Identifier( tom ), "' possible\n" );
      result:= false;
    elif storedfus <> fail and not storedfus in fus then
      Print( "#E  stored fusion tbl to tom `", Identifier( tbl ), "' -> `",
             Identifier( tom ), "' is wrong" );
      if not IsIdenticalObj( condition, ReturnTrue ) then
        Print( " (w.r.t. addit. condition)" );
      fi;
      Print( "\n" );
      result:= false;
    elif IsEmpty( compat ) then
      Print( "#E  no fusion tbl to tom `", Identifier( tbl ), "' -> `",
             Identifier( tom ), "' compatible with `Maxes'\n" );
      result:= false;
    elif Length( fus ) = 1 then
      # The fusion is unique.
      if IsBound( fusrec.text )
         and fusrec.text <> "fusion map is unique"
         and ( Length( fusrec.text ) < 21 or
               fusrec.text{ [ 1 .. 21 ] } <> "fusion map is unique," ) then
        Print( "#E  text for stored fusion tbl to tom `", Identifier( tbl ),
               "' -> `", Identifier( tom ),
               "' is wrong (map is unique!)\n" );
      fi;
      result:= rec( name := Identifier( tom ),
                    map  := fus[1],
                    text := "fusion map is unique" );
    elif 1 < Length( fusreps ) then
      # The fusion is ambiguous.
      if storedfus = fail then
        Print( "#E  ambiguous fusion tbl to tom `", Identifier( tbl ),
               "' -> `", Identifier( tom ), "', no map stored\n" );
        result:= fail;
      elif not IsBound( fusrec.text ) then
        # The ambiguity of the fusion is not mentioned in the stored fusion.
        Print( "#E  ambiguous fusion tbl to tom `", Identifier( tbl ),
               "' -> `", Identifier( tom ), "', no text stored\n" );
        result:= fail;
      elif     PositionSublist( fusrec.text, "together" ) = fail
           and PositionSublist( fusrec.text, "determined" ) = fail then
        # The ambiguity of the fusion is not mentioned in the stored fusion.
        Print( "#E  ambiguous fusion tbl to tom `", Identifier( tbl ),
               "' -> `", Identifier( tom ),
               "',\nwithout \"together\" or \"determined\" in text\n" );
        result:= fail;
      else
        # The fusion is ambiguous, and this is mentioned in the stored fusion.
        result:= fusrec;
      fi;
    else
      # The fusion is unique up to table automorphisms.
      # Choose a compatible representative,
      # besides that keep the stored fusion if exists.
      if IsBound( fusrec.text ) and
         PositionSublist( fusrec.text, "unique up to table " ) = fail then
        Print( "#E  text for stored fusion tbl to tom `", Identifier( tbl ),
               "' -> `", Identifier( tom ),
               "' is wrong (map is unique up to table automorphisms!)\n" );
      fi;
      result:= rec( name := Identifier( tom ),
                    text := "fusion map is unique up to table autom." );
      if   storedfus = fail then
        result.map:= compat[1];
        if Length( compat ) < Length( fusreps ) then
          Append( result.text, ", compatible with `Maxes'" );
        fi;
      elif not storedfus in compat then
        result.map:= compat[1];
        Append( result.text, ", compatible with `Maxes'" );
        Print( "#E  stored fusion tbl to tom `", Identifier( tbl ),
               "' -> `", Identifier( tom ),
               "' is incompatible with `Maxes',\n",
               "#E  replace it by the following:\n",
               LibraryFusionTblToTom( tbl, result ), "\n" );
      else
        result.map:= storedfus;
      fi;
    fi;

    # Return the result.
    return result;
    end );


#############################################################################
##
#F  TomLibTestCharacterTable( )
#F  TomLibTestCharacterTable( <tomname> )
##
##  First suppose that `TomLibTestCharacterTable' is called with one
##  argument <tomname>.
##  Then it is checked whether a character table for the group exists
##  in the {\GAP} Character Table Library.
##
##  If no argument is given then all admissible names of tables of marks are
##  checked with the one argument version.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
InstallGlobalFunction( TomLibTestCharacterTable, function( arg )
    local result, tomname, tom, tblname, G, tblfustom, cand, tbl, tommaxes,
          tblmaxes, orders;

    result:= true;

    if Length( arg ) = 0 then
      for tomname in AllLibTomNames() do
        result:= TomLibTestCharacterTable( tomname ) and result;
      od;
    elif Length( arg ) = 1 then
      tomname:= arg[1];
      tom:= TableOfMarks( tomname );
      if tom = fail then
        Print( "#E  table of marks for `", tomname, "' is not available\n" );
        result:= false;
      else
        tblname:= NameOfLibraryCharacterTable( tomname );
        if tblname = fail then
          # Check whether the table library contains the table.
          result:= false;
          G:= UnderlyingGroup( tom );
          cand:= AllCharacterTableNames( Size, Size( G ),
                   NrConjugacyClasses, NrConjugacyClasses( G ) );
#T introduce fingerprints, data library objects, ...
          tblname:= First( cand, name ->
            TransformingPermutationsCharacterTables( CharacterTable( name ),
                CharacterTable( G ) ) <> fail );
          if tblname = fail then
            Print( "#I  no character table corresp. to `", tomname, "',\n",
                   "#I  (fusions to ",
                   List( NotifiedFusionsOfLibTom( tom ), pair -> pair[1] ),
                   " stored)\n" );
          else
            Print( "#I  add the following line to `",
                   LibInfoCharacterTable( tblname ).fileName, "':\n",
                   "ARC(\"", tblname, "\",\"tomidentifier\",\"", tomname,
                   "\");\n" );
          fi;
        fi;
        if tblname <> fail then

          tbl:= CharacterTable( tblname );

          # Check existence & compatibility of a stored fusion.
          tblfustom:= TomLibTestFusionTblToTom( tbl, tom );
          if IsRecord( tblfustom ) and not HasFusionToTom( tbl ) then
            Print( "#I  store the following tomfusion `",
                   Identifier( tbl ), "' -> `", Identifier( tom ), "':\n",
                   LibraryFusionTblToTom( tbl, tblfustom ), "\n" );
          fi;

          # Compare the compatibility of the maximal subgroup info.
          tommaxes:= MaximalSubgroupsTom( tom )[1];
          if HasMaxes( tbl ) then
            tblmaxes:= List( Maxes( tbl ), CharacterTable );
            orders:= OrdersTom( tom ){ tommaxes };
            if Length( orders ) <> Length( tblmaxes ) then
              Print( "#E  table of marks for `", tomname, "' has ",
                     Length( tommaxes ), " maxes\n",
                     "#E  but the character table has ",
                     Length( tblmaxes ), "\n" );
              result:= false;
            elif orders <> List( tblmaxes, Size ) then
              Print( "#E  table of marks for `", tomname,
                     "' has maxes of orders\n",
                     "#E  ", orders, "\n",
                     "#E  but the character table has ",
                     List( tblmaxes, Size ), "\n" );
            elif List( tblmaxes, t -> TrivialCharacter( t )^tbl )
                 <> PermCharsTom( tbl, tom ){ tommaxes } then
              Print( "#E  incompatible prim. perm. chars. for ",
                     "table of marks for `", tomname, "'\n" );
            fi;
          elif IsSubset( List( NotifiedFusionsToLibTom( tomname ),
                               x -> x[2] ),
                         tommaxes ) then
            Print( "#I  add `maxes' for character table `", tblname,
                   "',\n#I  for the table of marks these are\n#I  ",
                   List( Filtered( NotifiedFusionsToLibTom( tomname ),
                                   x -> x[2] in tommaxes ),
                         x -> x[1] ), "\n" );
          fi;

        fi;

        # Test also whether for all fusions to the table of marks,
        # there is a corresponding fusion to the character table.
#T Note that here we have a conceptual problem:
#T `CharacterTable' returns ``the'' character table of `tom',
#T but from the viewpoint of the fusions, there may be several tables
#T in the library!

      fi;
    else
      Error( "usage: TomLibTestCharacterTable( [<tomname>] )" );
    fi;

    return result;
    end );


#############################################################################
##
#F  TomLibTestFusions( )
#F  TomLibTestFusions( <tomname> )
##
##  First suppose that `TomLibTestFusions' is called with one
##  argument <tomname>.
##  Then it is checked whether the stored fusions from the table of marks
##  with name <tomname> into other tables of marks are reliable,
##  and whether they are compatible with the corresponding fusions between
##  the character tables (w.r.t. the stored fusions from character table to
##  table of marks).
##
##  If no argument is given then all admissible names of tables of marks are
##  checked with the one argument version.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
InstallGlobalFunction( TomLibTestFusions, function( arg )
    local result, tomname, tom, pair, supertom, tomfus, marks, subs, badrows,
          i, row, j, rest, tblname, tbl, supertblname, supertbl, tblfus,
          tblfustom, supertblfussupertom, composition, dec, r, altern;

    result:= true;

    if Length( arg ) = 0 then
      for tomname in AllLibTomNames() do
        result:= TomLibTestFusions( tomname ) and result;
      od;
    elif Length( arg ) = 1 then
      tomname:= arg[1];
      tom:= TableOfMarks( tomname );
      if tom = fail then
        Print( "#E  table of marks for `", tomname, "' is not available\n" );
        result:= false;
      else
        for pair in FusionsOfLibTom( tom ) do
          supertom:= TableOfMarks( pair[1] );
          if supertom = fail then
            Print( "#E  table of marks for `", pair[1],
                   "' is not available\n" );
            result:= false;
          else

            # Test the fusion map between the tables of marks.
            # (The restriction of each row of `supertom' via the fusion
            # must decompose into rows of `tom', with nonnegative integral
            # coefficients.)
            tomfus:= ShallowCopy( pair[2] );
            marks:= MarksTom( supertom );
            subs:= SubsTom( supertom );

            badrows:= [];
            for i in [ 1 .. Length( subs ) ] do

              # Unpack the `i'-th row.
              row:= 0 * [ 1 .. Maximum( subs[i] ) ];
              for j in [ 1 .. Length( subs[i] ) ] do
                row[ subs[i][j] ]:= marks[i][j];
              od;

              # Compute the restriction.
              rest:= 0 * tomfus;
              for j in [ 1 .. Length( tomfus ) ] do
                if IsBound( row[ tomfus[j] ] ) then
                  rest[j]:= row[ tomfus[j] ];
                fi;
              od;

              # Decompose the restriction.
              dec:= DecomposedFixedPointVector( tom, rest );
              if ForAny( dec, x -> not IsInt( x ) or ( x < 0 ) ) then
                Add( badrows, i );
              fi;
            od;
            if not IsEmpty( badrows ) then
              Print( "#E  restricted rows ", badrows, " of `", pair[1],
                     "' do not decompose in `", tomname, "'\n" );
            fi;
#T there are currently no library functions for dealing with fusions
#T between tables of marks;
#T see the ``private functions'' by G"otz and Thomas?
#T (Note that usually the fusions have been used to construct the tables
#T of marks, not the fusions were computed from the tables.)

            # Check the compatibility with the fusion of char. tables.
            tblname:= NameOfLibraryCharacterTable( tomname );
            supertblname:= NameOfLibraryCharacterTable( pair[1] );
            if tblname <> fail and supertblname <> fail then

              tbl:= CharacterTable( tblname );
              supertbl:= CharacterTable( supertblname );

              # Check the consistency.
              # (Note that several fusions may be available between two
              # tables of marks, but character tables do not support this.)
              tblfus:= Filtered( ComputedClassFusions( tbl ),
                                 x -> x.name = supertblname );
              if IsEmpty( tblfus ) then
                Print( "#I  character table fusion `", Identifier( tbl ),
                       "' -> `", Identifier( supertbl ), "' missing\n" );
                tblfus:= CTblLibTestSubgroupFusion( tbl, supertbl, false );
                if IsRecord( tblfus ) then
                  Print( "#I  store the following one:\n",
                         LibraryFusion( Identifier( tbl ), tblfus ) );
                  tblfus:= [ tblfus ];
                else
                  tblfus:= [];
                fi;
              fi;

              tblfustom:= TomLibTestFusionTblToTom( tbl, tom );
              supertblfussupertom:= TomLibTestFusionTblToTom( supertbl,
                                        supertom );

              for r in tblfus do
                if not IsBound( r.specification ) or
                   r.specification = Concatenation( "tom:",
                        String( tomfus[ Length( tomfus ) ] ) ) then
                  if     IsRecord( tblfustom )
                     and IsRecord( supertblfussupertom )
                     and CompositionMaps( tomfus, tblfustom.map ) <>
                       CompositionMaps( supertblfussupertom.map, r.map ) then
                    Print( "#E  fusion `", Identifier( tom ), "' -> `",
                           Identifier( supertom ),
                           "' incompatible with char. tables\n" );
                    altern:= Filtered( NotifiedFusionsOfLibTom( tom ),
                                 p -> p[1] = pair[1]
                                    and p[2] <> tomfus[ Length( tomfus ) ] );
                    if not IsEmpty( altern ) then
                      Print( "#E  (try `tom:<n>' specif. for <n> in ",
                             List( altern, x -> x[2] ), ")\n" );
                    fi;
                    composition:= map -> CompositionMaps( tomfus,
                        tblfustom.map ) = CompositionMaps( map, r.map );
                    supertblfussupertom:= TomLibTestFusionTblToTom( supertbl,
                                              supertom, composition );
#T problem: loop over tblfus, but possible error prints for each member!
                    result:= false;
                  fi;
                fi;
              od;

              # Add the fusion to `tom' if necessary.
              if IsRecord( tblfustom ) and not HasFusionToTom( tbl ) then
                Print( "#I  store the following tomfusion `",
                       Identifier( tbl ), "' -> `", Identifier( tom ), "':\n",
                       LibraryFusionTblToTom( tbl, tblfustom ), "\n" );
              fi;

              # Add the fusion to `supertom' if necessary.
              if IsRecord( supertblfussupertom ) and
                 not HasFusionToTom( supertbl ) then
                Print( "#I  store the following tomfusion `",
                       Identifier( supertbl ),
                       "' -> `", Identifier( supertom ), "':\n",
                       LibraryFusionTblToTom( supertbl,
                           supertblfussupertom ), "\n" );
              fi;

            fi;
          fi;
        od;
      fi;
    fi;

    return result;
    end );


#############################################################################
##
#E

