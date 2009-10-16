#############################################################################
##
#W  itc.gi                  	XGAP library                   Volkmar Felsch
#W                                                               Ludger Hippe
#W                                                          Joachim Neubueser
##
#Y  Copyright 1999,          Volkmar Felsch,            Aachen,       Germany
##
##  This file contains  the implementations for the  Interactive Todd-Coxeter
##  coset enumeration routines.
##
##  *Note* that the comments may be partially outdated!
##
##  This is Version 1.1 of March 2001
##


#############################################################################
##
##  Declarations of representations:
##


#############################################################################
##
#R  IsItcClassSheet . . . . . . . .  representation for a list of gap classes
##
DeclareRepresentation( "IsItcClassSheet",
  IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
  IsGraphicSheetRep,
  # we inherit those components from the sheet:
  [ "name", "width", "height", "WindowId", "callbackName", "callbackFunc",
    "menus", "gapMenu", "objects", "free", "DefaultsForGraphicObject",
    "filenamePS",
  # now our own components:
    "boxes",
    "class",
    "ctSheet" ],
  IsGraphicSheet );


#############################################################################
##
#R  IsItcCoincSheet  . . . . . . .  representation for a list of coincidences
##
DeclareRepresentation( "IsItcCoincSheet",
  IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
  IsGraphicSheetRep,
  # we inherit those components from the sheet:
  [ "name", "width", "height", "WindowId", "callbackName", "callbackFunc",
    "menus", "gapMenu", "objects", "free", "DefaultsForGraphicObject",
    "filenamePS",
  # now our own components:
    "boxes",
    "ctSheet",
    "repSheets" ],
  IsGraphicSheet );


#############################################################################
##
#R  IsItcCosetTableSheet  . . . . . .  representation for graphic coset table
##
DeclareRepresentation( "IsItcCosetTableSheet",
  IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
  IsGraphicSheetRep,
  # we inherit those components from the sheet:
  [ "name", "width", "height", "WindowId", "callbackName", "callbackFunc",
    "menus", "gapMenu", "objects", "free", "DefaultsForGraphicObject",
    "filenamePS",
  # now our own components:
    "alives",
    "app",
    "app1",
    "backto",
    "clear",
    "coincSwitch",
    "coincs",
    "coiSheet",
    "deducs",
    "defaultLimit",
    "defs",
    "defSheet",
    "digits",
    "digitString1",
    "digitString2",
    "echo",
    "felsch",
    "fgens",
    "fillgaps",
    "fillrows",
    "first",
    "firstCol",
    "firstDef",
    "firstFree",
    "fsgens",
    "gaps",
    "gapsStrategy",
    "genNames",
    "graphicTable",
    "hlt",
    "hltRow",
    "infoLine",
    "invcol",
    "involutory",
    "isActual",
    "lastDef",
    "lastFree",
    "limit",
    "line",
    "mark",
    "markDefs",
    "marked",
    "message",
    "messageText",
    "ncols",
    "ndefs",
    "newtab",
    "next",
    "nlines",
    "normal",
    "nrdel",
    "oldtab",
    "prev",
    "quitt",
    "relColumnNums",
    "rels",
    "relsGen",
    "relSheet",
    "relText",
    "renumbered",
    "repLists",
    "reset",
    "rtSheets",
    "scroll",
    "scrollby",
    "scrollto",
    "settingsSheet",
    "shortCut",
    "shortcut",
    "showcoincs",
    "showdefs",
    "showgaps",
    "showrels",
    "showsubgrp",
    "small",
    "sortdefs",
    "sorted",
    "stSheets",
    "subColumnNums",
    "subgrp",
    "subSheet",
    "subText",
    "table" ],
  IsGraphicSheet );


#############################################################################
##
#R  IsItcDefinitionsSheet . . . . .  representation for a list of definitions
##
DeclareRepresentation( "IsItcDefinitionsSheet",
  IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
  IsGraphicSheetRep,
  # we inherit those components from the sheet:
  [ "name", "width", "height", "WindowId", "callbackName", "callbackFunc",
    "menus", "gapMenu", "objects", "free", "DefaultsForGraphicObject",
    "filenamePS",
  # now our own components:
    "boxes",
    "ctSheet" ],
  IsGraphicSheet );


#############################################################################
##
#R  IsItcGapSheet  . . . . . . .  representation for a list of gap class reps
##
DeclareRepresentation( "IsItcGapSheet",
  IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
  IsGraphicSheetRep,
  # we inherit those components from the sheet:
  [ "name", "width", "height", "WindowId", "callbackName", "callbackFunc",
    "menus", "gapMenu", "objects", "free", "DefaultsForGraphicObject",
    "filenamePS",
  # now our own components:
    "boxes",
    "ctSheet" ],
  IsGraphicSheet );


#############################################################################
##
#R  IsItcRelationTableSheet . . . . . . .  representation for a relator table
##
DeclareRepresentation( "IsItcRelationTableSheet",
  IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
  IsGraphicSheetRep,
  # we inherit those components from the sheet:
  [ "name", "width", "height", "WindowId", "callbackName", "callbackFunc",
    "menus", "gapMenu", "objects", "free", "DefaultsForGraphicObject",
    "filenamePS",
  # now our own components:
    "ctSheet",
    "graphicTable",
    "newtab",
    "number",
    "oldtab",
    "vertical" ],
  IsGraphicSheet );


#############################################################################
##
#R  IsItcRelatorsSheet . . . . . . . . .  representation for a relators sheet
##
DeclareRepresentation( "IsItcRelatorsSheet",
  IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
  IsGraphicSheetRep,
  # we inherit those components from the sheet:
  [ "name", "width", "height", "WindowId", "callbackName", "callbackFunc",
    "menus", "gapMenu", "objects", "free", "DefaultsForGraphicObject",
    "filenamePS",
  # now our own components:
    "boxes",
    "ctSheet" ],
  IsGraphicSheet );


#############################################################################
##
#R  IsItcSubgroupGeneratorsSheet . . representation for a subgroup gens sheet
##
DeclareRepresentation( "IsItcSubgroupGeneratorsSheet",
  IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
  IsGraphicSheetRep,
  # we inherit those components from the sheet:
  [ "name", "width", "height", "WindowId", "callbackName", "callbackFunc",
    "menus", "gapMenu", "objects", "free", "DefaultsForGraphicObject",
    "filenamePS",
  # now our own components:
    "boxes",
    "ctSheet" ],
  IsGraphicSheet );


#############################################################################
##
#R  IsItcSubgroupTableSheet . . representation for a subgroup generator table
##
DeclareRepresentation( "IsItcSubgroupTableSheet",
  IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
  IsGraphicSheetRep,
  # we inherit those components from the sheet:
  [ "name", "width", "height", "WindowId", "callbackName", "callbackFunc",
    "menus", "gapMenu", "objects", "free", "DefaultsForGraphicObject",
    "filenamePS",
  # now our own components:
    "ctSheet",
    "graphicTable",
    "newtab",
    "number",
    "oldtab",
    "vertical" ],
  IsGraphicSheet );


#############################################################################
#
# ItcClassSheetLeftPBDown( <classSheet>, <x>, <y> )
#
# installs the methods for the left pointer button in table of gaps of length
# one.
#
InstallGlobalFunction( ItcClassSheetLeftPBDown, function( classSheet, x, y )

  local class, classSheets, coset, gaps, gen, i, ctSheet, ndefs;

  # get some local variables
  ctSheet := classSheet!.ctSheet;
  gaps := ctSheet!.gaps;
  classSheets := gaps[4];

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  for i in [ 1 .. Length( classSheet!.boxes ) ] do
    if [x,y] in classSheet!.boxes[i] then

      coset := classSheet!.class[i][1];
      gen := classSheet!.class[i][2];

      # echo the command
      if ctSheet!.echo then
        class := Position( classSheets, classSheet );
        Print( ">> CLICK class ", class, " gap [ ", coset, ", ",
          ctSheet!.genNames[gen], " ]\n" );
      fi;

      # get some local variables
      ndefs := ctSheet!.ndefs;

      # define a new coset
      ItcFillCosetTableEntry( ctSheet, coset, gen );

      # check for a fail because of insufficient table size
      if ctSheet!.ndefs > ndefs then

        # save the current state.
        ItcExtractTable( ctSheet );

        # display the coset tables and set all variables
        ItcDisplayCosetTable( ctSheet );

        # update all active relator tables and subgroup generator tables
        ItcUpdateDisplayedLists( ctSheet );
        ItcEnableMenu( ctSheet );

      fi;
      return;

    fi;
  od;
end );


#############################################################################
#
# ItcCoincSheetLeftPBDown( <coiSheet>, <x>, <y> )
#
# installs  the methods  for the  left pointer button  in the list of pending
# coincidences.
#
InstallGlobalFunction( ItcCoincSheetLeftPBDown, function( coiSheet, x, y )

  local boxes, coincs, cos1, cos2, ctSheet, i, length, newtab, oldtab;

  # get some local variables
  ctSheet := coiSheet!.ctSheet;
  boxes := coiSheet!.boxes;
  length := Length( boxes );

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  for i in [ 1 .. length ] do
    if [x,y] in boxes[i] then

      # echo the command
      if ctSheet!.echo then
        coincs := ctSheet!.coincs;
        cos1 := coincs[i][1];
        cos2 := coincs[i][2];
        Print( ">> CLICK coincidence ", cos1, " = ", cos2, "\n" );
      fi;

      # work off the i-th pending coincidence
      ItcHandlePendingCoincidence( ctSheet, i );

      # save the old state as new state
      newtab := ctSheet!.oldtab;
      oldtab := ctSheet!.newtab;
      ctSheet!.newtab := newtab;
      ctSheet!.oldtab := oldtab;

      # make the current state the new state
      ItcExtractTable( ctSheet );

      # display the coset tables and set all variables
      ItcDisplayCosetTable( ctSheet );

      # update all active relator tables and subgroup generator tables
      ItcUpdateDisplayedLists( ctSheet );
      ItcEnableMenu( ctSheet );

      return;
    fi;
  od;

end );


#############################################################################
#
# ItcCoincSheetRightPBDown( <coiSheet>, <x>, <y> )
#
# installs  the methods  for the right pointer button  in the list of pending
# coincidences.
#
InstallGlobalFunction( ItcCoincSheetRightPBDown, function( coiSheet, x, y )

  local boxes, charWidth, coincs, cos1, cos2, ctSheet, distance, height, i,
        length, lineHeight, name, sheet, string, width;

  # get some local variables
  ctSheet := coiSheet!.ctSheet;
  distance := ctSheet!.normal.distance;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;
  boxes := coiSheet!.boxes;
  length := Length( boxes );

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  for i in [ 1 .. length ] do
    if [x,y] in boxes[i] then

      # get some local variables
      coincs := ctSheet!.coincs;
      cos1 := coincs[i][1];
      cos2 := coincs[i][2];

      # echo the command
      if ctSheet!.echo then
        Print( ">> RIGHT CLICK coincidence ", cos1, " = ", cos2, "\n" );
      fi;

      # check if there is already a window for the rep of this coincidence
      if IsBound( coiSheet!.repSheets[i] ) and
      IsAlive( coiSheet!.repSheets[i] ) then

        Close( coiSheet!.repSheets[i] );

      else

        # get the word string to be displayed
        string := String( ItcRepresentativeCoset( ctSheet, cos1 ) *
          ItcRepresentativeCoset( ctSheet, cos2 )^-1 );

        # open a new graphic sheet
        name := Concatenation( "Coinidence ", String( cos1 ), " = ",
          String( cos2 ) );
        width := Maximum( ( Length( string ) + 2 ) * charWidth,
          WidthOfSheetName( name ) );
        height := 3 * distance + lineHeight;
        sheet := GraphicSheet( name, width, height );

        # get the representative of cos1 * cos2^-1 and display it
        sheet!.word := Text( sheet, FONTS.normal, charWidth, lineHeight,
          string );
        sheet!.ctSheet := ctSheet;
        coiSheet!.repSheets[i] := sheet;

      fi;
      return;

    fi;
  od;

end );


#############################################################################
#
# ItcCosetTableSheetLeftPBDown( <ctSheet>, <x>, <y> )
#
# installs the callback for the left pointer button in the window
# 'Interactive Todd-Coxeter'.
#
InstallGlobalFunction( ItcCosetTableSheetLeftPBDown,
  function( ctSheet, x, y )

  local alives, coset, done, firstCol, graphicTable, i, j, line0, ncols,
        newtab, ndefs, ndefs2, nlines, renumbered;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  if [x,y] in ctSheet!.felsch then
    ItcFelsch( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.fillgaps then
    ItcFillGaps( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.fillrows then
    ItcFillRows( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.hlt  then
    ItcHLT( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.showdefs then
    ItcShowDefs( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.showgaps then
    ItcShowGaps( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.showrels then
    ItcShowRels( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.showsubgrp then
    ItcShowSubgrp( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.backto then
    ItcBackTo( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.clear then
    ItcClear( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.reset then
    ItcReset( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.shortcut then
    ItcShortCut( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.sortdefs then
    ItcSortDefinitions( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.scrollto then
    ItcScrollTo( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.scrollby then
    ItcScrollBy( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.showcoincs then
    ItcShowCoincs( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.mark then
    ItcMarkCosets( ctSheet, 0, 0 );

  elif [x,y] in ctSheet!.quitt then
    ItcQuit( ctSheet, 0, 0 );

  else

    # get some local variables
    firstCol := ctSheet!.firstCol;
    graphicTable := ctSheet!.graphicTable;
    newtab := ctSheet!.newtab;
    ndefs := ctSheet!.ndefs;
    ncols := ctSheet!.ncols;
    nlines := ctSheet!.nlines;
    renumbered := ctSheet!.renumbered;
    alives := ctSheet!.alives;
    line0 := renumbered[ctSheet!.first] - 1;
    done := false;

    for i in [ 1 .. nlines ] do
      coset := alives[line0 + i];

      for j in [ 1 .. ncols ] do
        if [x,y] in graphicTable[i][j] and newtab[coset][j] <= 0 then

          # echo the command
          if ctSheet!.echo then
            Print( ">> CLICK coset table entry [ ", coset, ", ",
              ctSheet!.genNames[j], " ]\n" );
          fi;
          done := true;

          # define a new coset in the specified coset table entry
          ItcFillCosetTableEntry( ctSheet, coset, j );

          # check for a fail because of insufficient table size
          if ctSheet!.ndefs > ndefs then

            # save the current state.
            ItcExtractTable( ctSheet );

            # display the coset tables and set all variables
            ItcDisplayCosetTable( ctSheet );

            # update all active relator and subgroup generator tables
            ItcUpdateDisplayedLists( ctSheet );
            ItcEnableMenu( ctSheet );

          fi;
          return;

        fi;
      od;
    od;

    if not done then
      i := 0;
      while i < nlines do
        i := i + 1;
        if [x,y] in firstCol[i] then

          # echo the command
          coset := alives[line0 + i];
          if ctSheet!.echo then
            Print( ">> CLICK coset table row ", coset, "\n" );
          fi;

          # loop over the entries of the row
          j := 0;
          while j < ncols do

            j := j + 1;
            if ctSheet!.table[j][coset] <= 0 then

              # define a new coset
              ndefs2 := ctSheet!.ndefs;
              ItcFillCosetTableEntry( ctSheet, coset, j );

              # check for a fail because of insufficient table size
              if ctSheet!.ndefs = ndefs2 then
                j := ncols;

              else

                # save the current state.
                ItcExtractTable( ctSheet );
                newtab := ctSheet!.newtab;
                renumbered := ctSheet!.renumbered;

                if ctSheet!.renumbered[coset] = 0 then
                  j := ncols;
                fi;

              fi;
            fi;

          od;

          # check for a fail because of insufficient table size
          if ctSheet!.ndefs > ndefs then

            # display the coset tables and set all variables
            ItcDisplayCosetTable( ctSheet );

            # update all active relator and subgroup generator tables
            ItcUpdateDisplayedLists( ctSheet );
            ItcEnableMenu( ctSheet );
          fi;

          i := nlines;
        fi;
      od;
    fi;

  fi;
end );


#############################################################################
#
# ItcCosetTableSheetRightPBDown( <ctSheet>, <x>, <y> )
#
# installs the callback for the right pointer button in the window
# 'Interactive Todd-Coxeter'.
#
InstallGlobalFunction( ItcCosetTableSheetRightPBDown,
  function( ctSheet, x, y )

  local alives, classSheets, coset, firstCol, gaps, graphicTable, i, j, k,
        line0, newtab, nlines, renumbered;

  # get some local variables
  renumbered := ctSheet!.renumbered;
  line0 := renumbered[ctSheet!.first] - 1;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  if [x,y] in ctSheet!.showdefs then
    ctSheet!.markDefs := not ctSheet!.markDefs;
    if ctSheet!.markDefs then
      # mark the definitions in the coset table
      ItcRecolorDefs( ctSheet );
    else
      # recolor all table entries to unmark the definitons
      ItcRecolorTableEntries( ctSheet );
    fi;
    return;
  fi;

  # get some local variables
  firstCol := ctSheet!.firstCol;
  graphicTable := ctSheet!.graphicTable;
  newtab := ctSheet!.newtab;
  nlines := ctSheet!.nlines;
  alives := ctSheet!.alives;

  # run througth the lines in the coset table sheet
  for i in [ 1 .. nlines ] do
    coset := alives[line0 + i];

    # check if the line number has been clicked
    if [x,y] in firstCol[i] then

      # echo the command
      if ctSheet!.echo then
        Print( ">> RIGHT CLICK coset table row ", coset, "\n" );
      fi;

      # display the representative of thecorrespondingcoset and return
      ItcDisplayDefinition( ctSheet, coset );
      return;
    fi;

    # check if a proper entry in the line has been clicked
    for j in [ 1 .. Length( graphicTable[i] ) ] do
      if [x,y] in graphicTable[i][j] then

        # echo the command
        if ctSheet!.echo then
          Print( ">> RIGHT CLICK coset table entry [ ", alives[line0 + i],
            ", ", ctSheet!.genNames[j], " ]\n" );
        fi;

        # check if the entry is a coset number
        if newtab[coset][j] > 0 then

          # display the representative of the corresponding coset
          ItcDisplayDefinition( ctSheet, newtab[coset][j] );

        # check if the entry represents a gap of length 1
        elif newtab[coset][j] < 0 then

          # get the class number of the gap of length 1
          k := ItcNumberClassOfGaps( ctSheet, coset, j );

          # update the correponding class sheet
          gaps := ctSheet!.gaps;
          classSheets := gaps[4];
          if classSheets[k] <> 0 and IsAlive( classSheets[k] ) then
            Close( classSheets[k] );
          fi;
          ItcOpenClassSheet( ctSheet, k );
        fi;

        return;
      fi;
    od;
  od;
end );


#############################################################################
#
# ItcDefinitionsSheetPBDown( <defSheet>, <x>, <y> )
#
# installs the methods  for the left or right pointer button  in the Table of
# Definitions.
#
InstallGlobalFunction( ItcDefinitionsSheetPBDown, function( defSheet, x, y )

  local alives, boxes, coset, ctSheet, def, defs, gen, i, inv, j, length,
        line0, names, newtab, string;

  # get some local variables
  ctSheet := defSheet!.ctSheet;
  boxes := defSheet!.boxes;
  length := Length( boxes );

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  for i in [ 1 .. length ] do
    if [x,y] in boxes[i] then

      # get some local variables
      names := ctSheet!.genNames;
      defs := ctSheet!.defs;
      alives := ctSheet!.alives;
      newtab := ctSheet!.newtab;
      line0 := ctSheet!.renumbered[ctSheet!.first] - 1;
      coset := alives[line0 + i];

      if coset = 1 then
        string := "1 = 1";
      else
        def := defs[coset - 1];
        gen := def[2];
        inv := gen + 1 - 2 * ( ( gen + 1 ) mod 2 );
        j := newtab[coset][inv];
        string := Concatenation( String( coset ), "  =  ", String( j ),
          " * ", names[gen] );
      fi;

      # echo the command
      if ctSheet!.echo then
        Print( ">> RIGHT CLICK definition ", string, "\n" );
      fi;

      # open (or close) a definition sheet and return
      ItcDisplayDefinition( ctSheet, coset );
      return;

    fi;
  od;

end );


#############################################################################
#
# ItcGapSheetLeftPBDown( <gapSheet>, <x>, <y> )
#
# installs the methods for the left pointer button in table of gaps of length
# one.
#
InstallGlobalFunction( ItcGapSheetLeftPBDown, function( gapSheet, x, y )

  local coset, ctSheet, gen, i, ndefs, rep, reps;

  # get some local variables
  ctSheet := gapSheet!.ctSheet;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  for i in [ 1 .. Length( gapSheet!.boxes ) ] do
    if [x,y] in gapSheet!.boxes[i] then

      # echo the command
      if ctSheet!.echo then
        Print( ">> CLICK gaps class ", i, "\n" );
      fi;

      # get some local variables
      reps := ctSheet!.gaps[1];
      rep := reps[i];
      coset := rep[2];
      gen := rep[3];
      ndefs := ctSheet!.ndefs;

      # define a new coset
      ItcFillCosetTableEntry( ctSheet, coset, gen );

      # check for a fail because of insufficient table size
      if ctSheet!.ndefs > ndefs then

        # save the current state.
        ItcExtractTable( ctSheet );

        # display the coset tables and set all variables
        ItcDisplayCosetTable( ctSheet );

        # update all active relator tables and subgroup generator tables
        ItcUpdateDisplayedLists( ctSheet );
        ItcEnableMenu( ctSheet );

      fi;
      return;

    fi;
  od;
end );


#############################################################################
#
# ItcGapSheetRightPBDown( <gapSheet>, <x>, <y> )
#
# installs the methods for the left pointer button in table of gaps of length
# one.
#
InstallGlobalFunction( ItcGapSheetRightPBDown, function( gapSheet, x, y )

  local classSheets, ctSheet, gaps, i;

  # get some local variables
  ctSheet := gapSheet!.ctSheet;
  gaps := ctSheet!.gaps;
  classSheets := gaps[4];

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  for i in [ 1 .. Length( gapSheet!.boxes ) ] do
    if [x,y] in gapSheet!.boxes[i] then

      # echo the command
      if ctSheet!.echo then
        Print( ">> RIGHT CLICK gaps class ", i, "\n" );
      fi;

      if classSheets[i] <> 0 and IsAlive( classSheets[i] ) then
        Close( classSheets[i] );
      else
        ItcOpenClassSheet( ctSheet, i );
      fi;
    fi;
  od;
end );


#############################################################################
#
# ItcRelationTableSheetLeftPBDown( <rtSheet>, <x>, <y> )
#
# installs the methods for the left pointer button in a relation table.
#
InstallGlobalFunction( ItcRelationTableSheetLeftPBDown, function(
  rtSheet, x, y )

  local alives, columns, coset, ctSheet, gen, graphicTable, i, invcol, j,
        length, line0, ndefs, number, table;

  # get some local variables
  ctSheet := rtSheet!.ctSheet;
  table := rtSheet!.newtab;
  number := rtSheet!.number;
  graphicTable := rtSheet!.graphicTable;
  invcol := ctSheet!.invcol;
  alives := ctSheet!.alives;
  line0 := ctSheet!.renumbered[ctSheet!.first] - 1;
  columns := ctSheet!.relColumnNums[number];

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  for i in [ 1 .. Length( graphicTable ) ] do
    if IsBound( graphicTable[i] ) then
      length := Length( graphicTable[i] );
      for j in [ 1 .. length ] do
        if [x,y] in graphicTable[i][j] then
          if j = 1 or j = length then
            # echo the command
            coset := alives[line0 + i];
            if ctSheet!.echo then
              Print( ">> CLICK relation table ", number, " row ", coset,
               "\n" );
            fi;
            # new definitions are not allowed if there are pending
            # coincidences
            if not ctSheet!.coincs = [] then
              Relabel( ctSheet!.messageText,
                "There are pending coincidences" );
              ctSheet!.message := true;
              return;
            fi;
            # fill the row
            ItcFillTrace( ctSheet, coset, columns );
            ItcDisplayCosetTable( ctSheet );
            ItcUpdateDisplayedLists( ctSheet );
            ItcEnableMenu( ctSheet );
            return;

          elif table[i][j] > 0 then
            return;
          elif table[i][j-1] > 0 then
            coset := table[i][j-1];
            gen := columns[j-1];
          elif table[i][j+1] <= 0 then
            Relabel( ctSheet!.messageText, "This command has no effect" );
            ctSheet!.message := true;
            return;
          else
            coset := table[i][j+1];
            gen := invcol[columns[j]];
          fi;

          # echo the command
          if ctSheet!.echo then
            Print( ">> CLICK relation table ", number, " row ",
             alives[line0 + i], " entry [ ", coset, ", ",
             ctSheet!.genNames[gen], " ]\n" );
          fi;

          ndefs := ctSheet!.ndefs;
          ItcFillCosetTableEntry( ctSheet, coset, gen );

          # check for a fail because of insufficient table size
          if ctSheet!.ndefs > ndefs then

            # save the current state.
            ItcExtractTable( ctSheet );

            # display the coset tables and set all variables
            ItcDisplayCosetTable( ctSheet );

            # update all active relator tables and subgroup generator tables
            ItcUpdateDisplayedLists( ctSheet );
            ItcEnableMenu( ctSheet );

          fi;
          return;

        fi;
      od;
    fi;
  od;
end );


#############################################################################
#
# ItcRelatorsSheetLeftPBDown( <relSheet>, <x>, <y> )
#
# installs the methods for the left pointer button in the window 'Relators'.
#
InstallGlobalFunction( ItcRelatorsSheetLeftPBDown, function( relSheet, x, y )

  local boxes, ctSheet, i, rtSheets;

  # get some local variables
  boxes := relSheet!.boxes;
  ctSheet := relSheet!.ctSheet;
  rtSheets := ctSheet!.rtSheets;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  for i in [ 1 .. Length( boxes ) ] do
    if [x,y] in boxes[i] then

      # echo the command
      if ctSheet!.echo then
        Print( ">> CLICK relator ", i, "\n" );
      fi;

      if IsBound( rtSheets[i] ) and IsAlive( rtSheets[i] ) then
        Close( rtSheets[i] );
      else
        ItcDisplayRelationTable( ctSheet, i );
      fi;
    fi;
  od;
end );


#############################################################################
#
# ItcSubgroupGeneratorsSheetLeftPBDown( <subSheet>, <x>, <y> )
#
# installs the methods for the left pointer button in the window 'Subgroup
# gens'.
#
InstallGlobalFunction( ItcSubgroupGeneratorsSheetLeftPBDown,
  function( subSheet, x, y )

  local boxes, ctSheet, i, stSheets;

  # get some local variables
  boxes := subSheet!.boxes;
  ctSheet := subSheet!.ctSheet;
  stSheets := ctSheet!.stSheets;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  for i in [ 1 .. Length( boxes ) ] do
    if [x,y] in boxes[i] then

      # echo the command
      if ctSheet!.echo then
        Print( ">> CLICK subgroup generator ", i, "\n" );
      fi;

      if IsBound( stSheets[i] ) and IsAlive( stSheets[i] ) then
        Close( stSheets[i] );
      else
        ItcDisplaySubgroupTable( ctSheet, i );
      fi;
    fi;
  od;
end );


#############################################################################
#
# ItcSubgroupTableSheetLeftPBDown( <stSheet>, <x>, <y> )
#
# installs the methods for the left pointer button in a subgroup table.
#
InstallGlobalFunction( ItcSubgroupTableSheetLeftPBDown,
  function( stSheet, x, y )

  local alives, columns, coset, ctSheet, gen, graphicTable, i,invcol, j,
        length, ndefs, number, table;

  # get some local variables
  ctSheet := stSheet!.ctSheet;
  table := stSheet!.newtab;
  number := stSheet!.number;
  graphicTable := stSheet!.graphicTable;
  invcol := ctSheet!.invcol;
  alives := ctSheet!.alives;
  columns := ctSheet!.subColumnNums[number];

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  for i in [ 1 .. Length( graphicTable ) ] do
    if IsBound( graphicTable[i] ) then
      length := Length( graphicTable[i] );
      for j in [ 1 .. length ] do
        if [x,y] in graphicTable[i][j] then
          if j = 1 or j = length then
            coset := alives[i];
            if ctSheet!.echo then
              Print( ">> CLICK subgroup table ", number, " row ", coset,
               "\n" );
            fi;
            # new definitions are not allowed if there are pending
            # coincidences
            if not ctSheet!.coincs = [] then
              Relabel( ctSheet!.messageText,
                "There are pending coincidences" );
              ctSheet!.message := true;
              return;
            fi;
            # fill the row
            ItcFillTrace( ctSheet, coset, columns );
            ItcDisplayCosetTable( ctSheet );
            ItcUpdateDisplayedLists( ctSheet );
            ItcEnableMenu( ctSheet );
            return;
          elif table[i][j] > 0 then
            Relabel( ctSheet!.messageText, "This command has no effect" );
            ctSheet!.message := true;
            return;
          elif table[i][j-1] > 0 then
            coset := table[i][j-1];
            gen := columns[j-1];
          elif table[i][j+1] <= 0 then
            return;
          else
            coset := table[i][j+1];
            gen := invcol[columns[j]];
          fi;

          # echo the command
          if ctSheet!.echo then
            Print( ">> CLICK subgroup table ", number, " row ", alives[i],
             " entry [ ", coset, ", ", ctSheet!.genNames[gen], " ]\n" );
          fi;

          ndefs := ctSheet!.ndefs;
          ItcFillCosetTableEntry( ctSheet, coset, gen );

          # check for a fail because of insufficient table size
          if ctSheet!.ndefs > ndefs then

            # save the current state.
            ItcExtractTable( ctSheet );

            # display the coset tables and set all variables
            ItcDisplayCosetTable( ctSheet );

            # update all active relator tables and subgroup generator tables
            ItcUpdateDisplayedLists( ctSheet );
            ItcEnableMenu( ctSheet );

          fi;
          return;

        fi;
      od;
    fi;
  od;
end );


#############################################################################
#
# ItcBackTo( <ctSheet>, <menu>, <entry> )
#
# is called by selecting the menu entry 'back to definition' or by clicking
# on the button 'back to'.
#
InstallGlobalFunction( ItcBackTo, function( ctSheet, menu, entry )

  local coincSwitch, coset, defs, defSheet, echo, first, i, nargs, ndefs,
        query, repLists, showDefs, steps, table;

  # get some local variables
  ndefs := ctSheet!.ndefs;
  if ndefs = 1 then
    return;
  fi;

  # select the number of steps to be canceled and select the definitions to
  # be made
  query := Query( Dialog( "OKcancel", "back to ..." ), String( ndefs - 1 ) );

  # echo the command
  if ctSheet!.echo then
    Print( ">> BACK TO ", query, "\n" );
  fi;

  # return if the query has been canceled
  if query = false then
    return;
  fi;

  # evaluate the query string and check the arguments
  query := ItcQuery( query );
  nargs := Length( query );
  if nargs = 0 or query = [ ndefs ] then
    Relabel( ctSheet!.messageText, "This command has no effect" );
    ctSheet!.message := true;
    return;
  fi;
  steps := query[1];
  if not IsInt( steps ) or steps > ndefs or steps <= -ndefs or nargs > 1
    then
    Relabel( ctSheet!.messageText, "Illegal argument" );
    ctSheet!.message := true;
    return;
  fi;
  if steps < 0 then
    steps := ndefs + steps;
  fi;

  if steps = 1 then

    # clear the coset table
    ItcClearTable( ctSheet );
    ctSheet!.hltRow := 1;
    ctSheet!.marked := [];
    ctSheet!.scroll := 20;

    # display the coset table
    ItcDisplayCosetTable( ctSheet );
    ItcUpdateDisplayedLists( ctSheet );
    ItcEnableMenu( ctSheet );

    return;
  fi;

  # save the current scroll position
  first := ctSheet!.first;

  # save the definitions and clear the table
  defs := ctSheet!.defs{ [ 1 .. steps - 1 ] };
  ndefs := Length( defs );

  # save the coset representative sheets and the definitions table
  repLists := ctSheet!.repLists;
  ctSheet!.repLists := [ [], [] ];
  showDefs := IsBound( ctSheet!.defSheet ) and IsAlive( ctSheet!.defSheet );
  if showDefs then
    defSheet := ctSheet!.defSheet;
    Unbind( ctSheet!.defSheet );
  fi;

  # clear the coset table
  ItcClearTable( ctSheet );
  ctSheet!.hltRow := 1;

  # switch on the automatic handling of coinicidences, if necessary
  coincSwitch := ctSheet!.coincSwitch;
  ctSheet!.coincSwitch := true;

  # reconstruct and extract the table preceding the requested one
  for i in [ 1 .. ndefs - 1 ] do
    ItcFastCosetStepFill( ctSheet, defs[i][1], defs[i][2] );
  od;
  ItcExtractTable( ctSheet );

  # reconstruct the requested table
  i := ndefs;
  ItcCosetStepFill( ctSheet, defs[i][1], defs[i][2] );

  # reset the coincidences switch
  ctSheet!.coincSwitch := coincSwitch;

  # save the current state
  ItcExtractTable( ctSheet );
  ctSheet!.first := first;

  # display the coset tables and set all variables
  ItcDisplayCosetTable( ctSheet );

  # reset the coset representative sheets and the definitions table
  ctSheet!.repLists := repLists;
  if showDefs then
    ctSheet!.defSheet := defSheet;
    ItcDisplayDefinitionsTable( ctSheet );
  fi;

  # update all active relator and subgroup generator tables
  ItcUpdateDisplayedLists( ctSheet );
  ItcEnableMenu( ctSheet );

end );


#############################################################################
#
# ItcChangeDefaultTableSize( <ctSheet>, <menu>, <entry> )
#
InstallGlobalFunction( ItcChangeDefaultTableSize,
  function( ctSheet, menu, entry )

  local defaultLimit, limit, nargs, ndefs, query, settingsSheet, string,
        suggest;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  # find a suitable default value for the query
  defaultLimit := ctSheet!.defaultLimit;
  if defaultLimit = 1000 then
    suggest := 2000;
  else
    suggest := 1000;
  fi;

  # initialize the default coset table size
  query := Query( Dialog( "OKcancel", Concatenation(
    "change default table size from ", String( defaultLimit ), " to" ) ),
    String( suggest ) );

  # echo the command
  if ctSheet!.echo then
    Print( ">> CHANGE DEFAULT TABLE SIZE TO ", query, "\n" );
  fi;

  # return if the query has been canceled
  if query = false then
    return;
  fi;

  # evaluate the query string and check the arguments
  query := ItcQuery( query );
  nargs := Length( query );
  if nargs = 0 then
    defaultLimit := 0;
  else
    defaultLimit := query[1];
    if not IsInt( defaultLimit ) or defaultLimit <= 0 or nargs > 1 then
      Relabel( ctSheet!.messageText, "Illegal argument" );
      ctSheet!.message := true;
      return;
    fi;
  fi;

  # reset the default table size
  ctSheet!.defaultLimit := defaultLimit;

  # get some local variables
  ndefs := ctSheet!.ndefs;

  # if no enumeration has been started yet reinitialize the coset table
  if ndefs = 1 then
    limit := defaultLimit;
    ctSheet!.limit := limit;
    ctSheet!.defs := [];
    ctSheet!.ndefs := 1;
    ctSheet!.renumbered := [1];
    ctSheet!.alives := [ [1], [1], [1] ];
    ItcMakeDigitStrings( ctSheet );
    ctSheet!.oldtab := ListWithIdenticalEntries( limit, 0 );
    ctSheet!.newtab := ListWithIdenticalEntries( limit, 0 );
    ItcInitializeParameters( ctSheet );
    ItcEnableMenu( ctSheet );
  fi;

  # update the sheet of current settings
  if IsBound( ctSheet!.settingsSheet ) and IsAlive( ctSheet!.settingsSheet )
    then
    settingsSheet := ctSheet!.settingsSheet;
    FastUpdate( ctSheet, true );
    string := Concatenation( "default table size ", String( defaultLimit ) );
    Relabel( settingsSheet!.boxes[1], string );
    string := Concatenation( "table size ", String( ctSheet!.limit ) );
    Relabel( settingsSheet!.boxes[2], string );
    FastUpdate( ctSheet, false );
  fi;
end );


#############################################################################
#
# ItcChangeSettings( <ctSheet>, <menu>, <entry> )
#
# changes the settings.
#
InstallGlobalFunction( ItcChangeSettings, function( ctSheet, menu, entry )

  local i, num, settingsSheet, showSettings, strategy, string;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  # get the entry
  num := Position( menu!.entries, entry );
  if num < 3 or num > 10 then
    Error( "illegal arguments" );
  fi;

  showSettings := IsBound( ctSheet!.settingsSheet ) and
    IsAlive( ctSheet!.settingsSheet );

  if num = 3 then

    # entry "coincidence handling off"
    # --------------------------------

    # echo the command
    if ctSheet!.echo then
      Print( ">> COINCIDENCE HANDLING OFF\n" );
    fi;

    # switch off the automatic handling of coincidences
    ctSheet!.coincSwitch := false;

    if showSettings then
      i := 3;
      string := "coincidence handling OFF";
    fi;
    ItcRelabelInfoLine( ctSheet );

  elif num = 4 then

    # entry "coincidence handling on"
    # -------------------------------

    # echo the command
    if ctSheet!.echo then
      Print( ">> COINCIDENCE HANDLING ON\n" );
    fi;

    # if there is a window 'pending coincidenes' close it
    if IsBound( ctSheet!.coiSheet ) and IsAlive( ctSheet!.coiSheet ) then
      ItcCloseSheets( ctSheet!.coiSheet!.repSheets );
      Close( ctSheet!.coiSheet );
    fi;

    # switch on the automatic handling of coincidences
    ctSheet!.coincSwitch := true;

    if showSettings then
      i := 3;
      string := "coincidence handling ON";
    fi;
    ItcRelabelInfoLine( ctSheet );

    # if there are pending coincidences reconstruct the table
    if ctSheet!.coincs <> [] then

      # reconstruct the preceding state
      ItcExtractPrecedingTable( ctSheet );

      # make the current state the new state
      ItcExtractTable( ctSheet );

      # display the coset tables and set all variables
      ItcDisplayCosetTable( ctSheet );

      # update all active relator tables and subgroup generator tables
      ItcUpdateDisplayedLists( ctSheet );
      ItcEnableMenu( ctSheet );
    fi;

  elif num = 5 then

    # entry "echo on"
    # ---------------

    # switch on the echo
    ctSheet!.echo := true;

    # echo the command
    Print( ">> ECHO ON\n" );

    if showSettings then
      i := 4;
      string := "echo ON";
    fi;

  elif num = 6 then

    # entry "echo off"
    # ----------------

    # echo the command
    if ctSheet!.echo then
      Print( ">> ECHO OFF\n" );
    fi;

    # switch off the echo
    ctSheet!.echo := false;

    if showSettings then
      i := 4;
      string := "echo OFF";
    fi;

  else

    # echo the command
    strategy := num - 6;
    if ctSheet!.echo then
      Print( ">> GAPS STRATEGY ", strategy, "\n" );
    fi;

    # set the gaps strategy
    ctSheet!.gapsStrategy := strategy;

    if showSettings then
      i := 5;
      if strategy = 1 then
        string := "gaps strategy 1 (first gap)";
      elif strategy = 2 then
        string := "gaps strategy 2 (first rep of max weight)";
      elif strategy = 3 then
        string := "gaps strategy 3 (last rep of max weight)";
      fi;
    fi;

  fi;

  # update the sheet of current settings
  if showSettings then
    settingsSheet := ctSheet!.settingsSheet;
    FastUpdate( ctSheet, true );
    Relabel( settingsSheet!.boxes[i], string );
    FastUpdate( ctSheet, false );
  fi;

  ItcEnableMenu( ctSheet );
end );


#############################################################################
#
# ItcClassOfGaps( <ctSheet>, <n> )
#
# compute the n-th class of gaps of length 1.
#
InstallGlobalFunction( ItcClassOfGaps, function( ctSheet, n )

  local class, classes, c, cos, entry, gaps, gen, i, involutory, j, length,
        ncols, next, null, rep, reps, table;

  # get the list of all classes of gaps of length 1
  gaps := ItcGaps( ctSheet );
  classes := gaps[2];

  # check if the class is already available
  if classes[n] <> 0 then

    class := classes[n];

  else

    # get some local variables
    involutory := ctSheet!.involutory;
    next := ctSheet!.next;
    table := ctSheet!.table;
    ncols := ctSheet!.ncols;
    null := ncols * Length( table[1] );
    reps := gaps[1];
    rep := reps[n];
    length := rep[1];
    cos := rep[2];
    gen := rep[3];

    # initialize the class
    class := ListWithIdenticalEntries( length, 0 );
    i := 1;
    class[1] := [ cos, gen ];
    if involutory[gen] = 2 then
      gen := gen + 1;
      i := 2;
      class[2] := [ cos, gen ];
    fi;
    rep := ( cos -1 ) * ncols + gen;

    # loop over the coset table and find all gaps of the class
    while cos <> 0 do
      while gen < ncols do
      gen := gen + 1;
        entry := - table[gen][cos];
        if entry > 0 then
          while entry < null and entry <> rep do
            if entry <= 0 then
              Error( "THIS IS A BUG (ITC 01), YOU SHOULD NEVER GET HERE" );
            fi;
            j := ( entry - 1 ) mod ncols + 1;
            c := ( entry - j ) / ncols + 1;
            entry := - table[j][c];
          od;
          if entry = rep then
            # add the gap to the class
            i := i + 1;
            class[i] := [ cos, gen ];
          fi;
        fi;
      od;
      gen := 0;
      cos := next[cos];
    od;
    if i <> length then
       Error( "THIS IS A BUG (ITC 02), YOU SHOULD NEVER GET HERE" );
    fi;

  fi;
  return class;

end );


#############################################################################
#
# ItcClear( <ctSheet>, <menu>, <entry> )
#
#
InstallGlobalFunction( ItcClear, function( ctSheet, menu, entry )

  local i, limit, nsgens, nrels;

  # get some local variables
  nrels := Length( ctSheet!.rels );
  nsgens := Length( ctSheet!.fsgens );

  # echo the command
  if ctSheet!.echo then
    Print( ">> CLEAR\n" );
  fi;

  # reset the table size
  limit := ctSheet!.defaultLimit;
  ctSheet!.limit := limit;

  # reinitialize some auxiliary lists
  ItcMakeDigitStrings( ctSheet );
  ctSheet!.newtab := ListWithIdenticalEntries( limit, 0 );
  ctSheet!.oldtab := ListWithIdenticalEntries( limit, 0 );

  # clear the coset table
  ItcClearTable( ctSheet );

  # close the definitions table
  if IsBound( ctSheet!.defSheet ) and IsAlive( ctSheet!.defSheet ) then
    ItcCloseSheets( ctSheet!.repLists[2] );
    Close( ctSheet!.defSheet );
  fi;

  # close the relator tables
  if IsBound( ctSheet!.rtSheets ) then
    for i in [ 1 .. nrels ] do
      if IsBound( ctSheet!.rtSheets[i] ) and
        IsAlive( ctSheet!.rtSheets[i] ) then
        Close( ctSheet!.rtSheets[i] );
      fi;
    od;
  fi;

  # close the subgroup generator tables
  if IsBound( ctSheet!.stSheets ) then
    if IsBound( ctSheet!.subSheet ) then
      for i in [ 1 .. nsgens ] do
        if IsBound( ctSheet!.stSheets[i] ) and
          IsAlive( ctSheet!.stSheets[i] ) then
          Close( ctSheet!.stSheets[i] );
        fi;
      od;
    fi;
  fi;

  # reinitialize some parameters
  ctSheet!.hltRow := 1;
  ctSheet!.marked := [];
  ctSheet!.scroll := 20;
  ctSheet!.repLists := [ [], [] ];

  # display the coset table
  ItcDisplayCosetTable( ctSheet );
  ItcEnableMenu( ctSheet );

end );


#############################################################################
#
# ItcClearTable( <ctSheet> )
#
InstallGlobalFunction( ItcClearTable, function( ctSheet )

  local def, definitions, fsgens, nsgens, steps;

  # get some local variables
  fsgens := ctSheet!.fsgens;
  nsgens := Length( fsgens );

  # close the gaps of length 1 sheets if there are any
  ItcCloseGapSheets( ctSheet );

  # close the window 'pending coincidenes'
  if IsBound( ctSheet!.coiSheet ) and IsAlive( ctSheet!.coiSheet ) then
    ItcCloseSheets( ctSheet!.coiSheet!.repSheets );
    Close( ctSheet!.coiSheet );
  fi;

  # set back the variables for the coset enumerations
  ctSheet!.sorted := false;
  ctSheet!.markDefs := false;
  ctSheet!.coincs := [];
  ctSheet!.deducs := [];
  ctSheet!.defs := [];
  ctSheet!.ndefs := 1;
  ctSheet!.renumbered := [1];
  ctSheet!.alives := [ [1], [1], [1] ];

  ItcInitializeParameters( ctSheet );
end );


#############################################################################
#
# ItcCloseGapSheets( <ctSheet> )
#
# close the gaps of length 1 sheets if there are any
#
InstallGlobalFunction( ItcCloseGapSheets, function( ctSheet )

  local i, classSheets, gaps, gapSheet, sheet;

  gaps := ctSheet!.gaps;
  if gaps <> 0 then

    classSheets := gaps[4];
    for sheet in classSheets do
      if sheet <> 0 and IsAlive( sheet ) then
         Close( sheet );
      fi;
    od;

    gapSheet := gaps[3];
    if gapSheet <> 0 and IsAlive( gapSheet ) then
      Close( gapSheet );
    fi;

  fi;
end );


#############################################################################
#
# ItcCloseSheets( <list> )
#
# close all sheets in the given list.
#
InstallGlobalFunction( ItcCloseSheets, function( list )

  local sheet;
  for sheet in list do
    if IsAlive( sheet ) then
      Close( sheet );
    fi;
  od;
end );


#############################################################################
#
# ItcCloseTableFelsch( <ctSheet>, <menu>, <entry> )
#
# is called by selecting the menu entry 'close table By Felsch'.
#
InstallGlobalFunction( ItcCloseTableFelsch, function( ctSheet, menu, entry )

  local count, limit, ndefs;

  # if the coset table is already closed return
  if ctSheet!.firstDef = 0 then
    Relabel( ctSheet!.messageText, "The tables are closed" );
    ctSheet!.message := true;
    return;
  fi;

  # new definitions are not allowed if there are pending coincidences
  if not ctSheet!.coincs = [] then
    Relabel( ctSheet!.messageText, "There are pending coincidences" );
    ctSheet!.message := true;
    return;
  fi;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  # echo the command
  if ctSheet!.echo then
    Print( ">> CLOSE Felsch\n" );
  fi;

  # initialize some local variables
  limit := ctSheet!.limit;
  count := 0;

  # do the enumeration.
  while ctSheet!.firstDef <> 0 and ctSheet!.coincs = [] do

    # extend the table is necessary
    ndefs := ctSheet!.ndefs;
    if ndefs = limit then
      ItcExtendTableSize( ctSheet, 0, 0 );
      limit := ctSheet!.limit;
      if ndefs = limit then
        # insufficient table size: display a message and return
        Relabel( ctSheet!.messageText, "Insufficient table size" );
        ctSheet!.message := true;
        return;
      fi;
      count := 0;
    fi;

    count := count + 1;
    ItcFastCosetStepFelsch( ctSheet );
    ItcRelabelInfoLine( ctSheet );

    # check for a fail because of insufficient table size
    if ctSheet!.ndefs = ndefs then
      Error( "THIS IS A BUG (ITC 03), YOU SHOULD NEVER GET HERE" );
    fi;

    # if table has closed reconstruct the last preceding state.
    if ctSheet!.firstDef = 0 and count > 1 or not ctSheet!.coincs = [] then
      ItcExtractPrecedingTable( ctSheet );
    fi;
  od;

  # save the current state.
  ItcExtractTable( ctSheet );

  # display the coset tables and set all variables
  ItcDisplayCosetTable( ctSheet );

  # update all active relator tables and subgroup generator tables
  ItcUpdateDisplayedLists(ctSheet);

  # if there are pending coincidences display them
  if not ctSheet!.coincs = [] then
    ItcDisplayPendingCoincidences( ctSheet );
  fi;

  ItcEnableMenu( ctSheet );

end );


#############################################################################
#
# ItcCloseTableGaps( <ctSheet>, <menu>, <entry> )
#
# is called by selecting the menu entry 'close table using gaps'.
#
InstallGlobalFunction( ItcCloseTableGaps, function( ctSheet, menu, entry )

  local count, first, limit, ndefs, pos, strategy;

  # if the coset table is already closed return
  if ctSheet!.firstDef = 0 then
    Relabel( ctSheet!.messageText, "The tables are closed" );
    ctSheet!.message := true;
    return;
  fi;

  # new definitions are not allowed if there are pending coincidences
  if not ctSheet!.coincs = [] then
    Relabel( ctSheet!.messageText, "There are pending coincidences" );
    ctSheet!.message := true;
    return;
  fi;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  # get the strategy
  pos := Position( menu!.entries, entry );
  if pos < 2 or pos > 5 then
    Error( "illegal arguments" );
  fi;
  strategy := pos - 1;

  # echo the command
  if ctSheet!.echo then
    Print( ">> CLOSE gaps ", strategy, "\n" );
  fi;

  # save the current scroll position
  first := ctSheet!.first;

  # initialize some local variables
  limit := ctSheet!.limit;
  count := 0;

  # do the enumeration.
  while ctSheet!.firstDef <> 0 and ctSheet!.coincs = [] do

    # extend the table is necessary
    ndefs := ctSheet!.ndefs;
    if ndefs = limit then
      ItcExtendTableSize( ctSheet, 0, 0 );
      limit := ctSheet!.limit;
      if ndefs = limit then
        # insufficient table size: display a message and return
        Relabel( ctSheet!.messageText, "Insufficient table size" );
        ctSheet!.message := true;
        return;
      fi;
      count := 0;
    fi;

    # define the next coset
    count := count + 1;
    pos := ItcFirstGapOfLengthOne( ctSheet, strategy );
    if pos = fail then
      ItcFastCosetStepFelsch( ctSheet );
    else
      ItcFastCosetStepFill( ctSheet, pos[1], pos[2] );
    fi;
    ItcRelabelInfoLine( ctSheet );

    # check for a fail because of insufficient table size
    if ctSheet!.ndefs = ndefs then
      Error( "THIS IS A BUG (ITC 04), YOU SHOULD NEVER GET HERE" );
    fi;

    # if table has closed reconstruct the last preceding state.
    if ctSheet!.firstDef = 0 and count > 1 or not ctSheet!.coincs = [] then
      ItcExtractPrecedingTable( ctSheet );
    fi;
  od;
  ctSheet!.first := first;

  # save the current state.
  ItcExtractTable( ctSheet );

  # display the coset tables and set all variables
  ItcDisplayCosetTable( ctSheet );

  # update all active relator tables and subgroup generator tables
  ItcUpdateDisplayedLists(ctSheet);

  # if there are pending coincidences display them
  if not ctSheet!.coincs = [] then
    ItcDisplayPendingCoincidences( ctSheet );
  fi;

  ItcEnableMenu( ctSheet );

end );


#############################################################################
#
# ItcCloseTableHLT( <ctSheet>, <menu>, <entry> )
#
# is called by selecting the menu entry 'close table by HLT'.
#
InstallGlobalFunction( ItcCloseTableHLT, function( ctSheet, menu, entry )

  local coset, first, hlt, i, limit, maxdef, ndefs, nrels, nsgens, overflow,
        relColumnNums, subColumnNums, subgrp;

  # if the coset table is already closed return
  if ctSheet!.firstDef = 0 then
    Relabel( ctSheet!.messageText, "The tables are closed" );
    ctSheet!.message := true;
    return;
  fi;

  # new definitions are not allowed if there are pending coincidences
  if not ctSheet!.coincs = [] then
    Relabel( ctSheet!.messageText, "There are pending coincidences" );
    ctSheet!.message := true;
    return;
  fi;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  # echo the command
  if ctSheet!.echo then
    Print( ">> CLOSE HLT\n" );
  fi;

  # get some local variables
  subColumnNums := ctSheet!.subColumnNums;
  relColumnNums := ctSheet!.relColumnNums;
  subgrp := ctSheet!.subgrp;
  ndefs := ctSheet!.ndefs;
  nrels := Length( ctSheet!.rels );
  nsgens := Length( ctSheet!.fsgens );
  maxdef := 0;
  coset := ctSheet!.hltRow;
  overflow := false;
  hlt := [ coset, maxdef, overflow ];

  # fill the subgroup tables
  if not subgrp = [] then
    if coset <> 1 then
      Error( "THIS IS A BUG (ITC 05), YOU SHOULD NEVER GET HERE" );
    fi;
    i := 0;
    while i < nsgens do
      i := i + 1;
      ItcFillTraceHLT( ctSheet, hlt, subColumnNums[i] );
      overflow := hlt[3];
      if ctSheet!.firstDef = 0 or overflow or not ctSheet!.coincs = [] then
        # break the loop if the tables closed or in case of insufficient
        # table size or if there are pending coincidences
        i := nsgens;
        maxdef := ctSheet!.ndefs;
      fi;
    od;
  fi;

  coset := ctSheet!.hltRow;
  hlt[1] := coset;
  while maxdef <> ctSheet!.ndefs and coset <> 0 do
    ctSheet!.hltRow := coset;

    # fill the corresponding row in each relation table
    i := 0;
    while i < nrels do
      i := i + 1;
      ItcFillTraceHLT( ctSheet, hlt, relColumnNums[i] );
      overflow := hlt[3];
      # break the loops if the tables closed or in case of insufficient table
      # size or if there are pending coincidences
      if ctSheet!.firstDef = 0 or overflow or not ctSheet!.coincs = [] then
        maxdef := ctSheet!.ndefs;
      fi;
      # break the inner loop if the coset is not alive any more
      if ctSheet!.ndefs = maxdef or hlt[1] <> coset then
        i := nrels;
      fi;
    od;
    if hlt[1] = coset then
      coset := ctSheet!.next[coset];
      hlt[1] := coset;
    else
      coset := hlt[1];
    fi;

  od;

  if ctSheet!.ndefs > ndefs and not overflow then

    if ctSheet!.ndefs - ndefs > 1 then
      ItcExtractPrecedingTable( ctSheet );
    fi;

    # save the current state
    ItcExtractTable( ctSheet );

    # display the coset tables and set all variables
    ItcDisplayCosetTable( ctSheet );

    # update all active relator tables and subgroup generator tables
    ItcUpdateDisplayedLists( ctSheet );

    # if there are pending coincidences display them
    if not ctSheet!.coincs = [] then
      ItcDisplayPendingCoincidences( ctSheet );
    fi;

    ItcEnableMenu( ctSheet );
  fi;

end );


#############################################################################
#
# ItcCosetStepFelsch( <ctSheet> )
#
# defines  a  new  coset   (applying  the  Felsch  strategy),   computes  all
# consequences, and displays the resulting tables.
#
InstallGlobalFunction( ItcCosetStepFelsch, function( ctSheet )

  if ctSheet!.firstDef <> 0 then

    # define a new coset
    ItcFastCosetStepFelsch( ctSheet );

    # give some information
    ItcRelabelInfoLine( ctSheet );

  fi;
end );


#############################################################################
#
# ItcCosetStepFill( <ctSheet>, <coset>, <gen> )
#
# defines  a new coset  to fill the given coset table position,  computes all
# consequences, and displays the resulting tables.
#
InstallGlobalFunction( ItcCosetStepFill, function( ctSheet, coset, gen )

  # define the new coset
  ItcFastCosetStepFill( ctSheet, coset, gen );

  # give some information
  ItcRelabelInfoLine( ctSheet );

end );


#############################################################################
#
# ItcDisplayButtons( <ctSheet>, <y> )
#
# display the headers and buttons in the window 'Interactive Todd-Coxeter'.
#
InstallGlobalFunction( ItcDisplayButtons, function( ctSheet, y )

  local bar, blue, charWidth, distance, gap, green, height, infoLine,
       ItcButton, lineHeight, red, width1, width4, width6, white, x, x1, x2,
       x3, x4, x5, x6, y1, y2, y3;

  ItcButton := function( x, y, width, string, color )
    local button;
    # get the four colored bars
    button := Box( ctSheet, x, y, width, bar, color );
    button := Box( ctSheet, x, y + height - bar, width, bar, color );
    button := Box( ctSheet, x, y, bar, height, color );
    button := Box( ctSheet, x + width - bar, y, bar, height, color );
    # get the black inner rectangle
    button := Rectangle( ctSheet, x + bar + 1, y + bar + 1,
      width - 2 * ( bar + 1 ), height - 2 * ( bar + 1 ) );
    # get the black outer rectangle
    button := Rectangle( ctSheet, x - 1, y - 1, width + 2, height + 2 );
    # insert the text string
    x := x + QuoInt( width - Length( string ) * charWidth + 1, 2 );
    y := y + lineHeight - QuoInt( distance - 1, 2 );
    Text( ctSheet, FONTS.normal, x, y, string );
    return button;
  end;

  # get some local variables
  distance := ctSheet!.normal.distance;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;
  gap := ctSheet!.normal.gap;
  if distance < 3 then
    bar := distance - 2;
  else
    bar := distance - 1;
  fi;
  blue := rec( color := COLORS.blue );
  green := rec( color := COLORS.green );
  red := rec( color := COLORS.red );
  white := rec( color := COLORS.white );

  # define size and position of the buttons
  width1 := 10 * charWidth + 2 * distance;
  width4 := 12 * charWidth + 2 * distance;
  width6 := 7 * charWidth + 2 * distance;
  height := lineHeight + 2 * distance;
  x1 := gap;
  x2 := x1 + width1 + gap;
  x3 := x2 + width1 + gap;
  x4 := x3 + width1 + gap;
  x5 := x4 + width4 + gap;
  x6 := x5 + width4 + gap;
  y1 := y + gap;
  y2 := y1 + height + gap;
  y3 := y2 + height + gap;

  # define the buttons in the first column
  ctSheet!.scrollto := ItcButton( x1, y1, width1, "scroll to", blue );
  ctSheet!.scrollby := ItcButton( x1, y2, width1, "scroll by", blue );
  ctSheet!.backto := ItcButton( x1, y3, width1, "back to", green );

  # define the buttons in the second column
  ctSheet!.felsch := ItcButton( x2, y1, width1, "Felsch", green );
  ctSheet!.hlt := ItcButton( x2, y2, width1, "HLT", green );
  ctSheet!.sortdefs := ItcButton( x2, y3, width1, "sort defs", green );

  # define the buttons in the third column
  ctSheet!.fillgaps := ItcButton( x3, y1, width1, "fill gaps", green );
  ctSheet!.fillrows := ItcButton( x3, y2, width1, "fill rows", green );
  ctSheet!.shortcut := ItcButton( x3, y3, width1, "short-cut", green );

  # define the buttons in the fourth column
  ctSheet!.showrels := ItcButton( x4, y1, width4, "show rels", white );
  ctSheet!.showdefs := ItcButton( x4, y2, width4, "show defs", white );
  ctSheet!.showcoincs := ItcButton( x4, y3, width4, "show coincs", white );

  # define the buttons in the fifth column
  ctSheet!.showsubgrp := ItcButton( x5, y1, width4, "show subgrp", white );
  ctSheet!.showgaps := ItcButton( x5, y2, width4, "show gaps", white );
  ctSheet!.mark := ItcButton( x5, y3, width4, "mark cosets", white );

  # define the buttons in the sixth column
  ctSheet!.clear := ItcButton( x6, y1, width6, "clear", red );
  ctSheet!.reset := ItcButton( x6, y2, width6, "reset", red );
  ctSheet!.quitt := ItcButton( x6, y3, width6, "quit", red );

end );


#############################################################################
#
# ItcDisplayCosetTable( <ctSheet> )
#
# displays the coset tables in the window 'Interactive Todd-Coxeter'.
#
InstallGlobalFunction( ItcDisplayCosetTable, function( ctSheet )

  local alives, black, c, charWidth, color, coset, digits, distance, entry,
        first, green, i, j, lastline, line0, line1, lineHeight, marked,
        nalive, ncols, newtab, nlines, ndefs, oldrow, oldtab, px, py, red,
        renumbered, row, str, t, w, y;

  # get some local variables
  ncols := ctSheet!.ncols;
  newtab := ctSheet!.newtab;
  oldtab := ctSheet!.oldtab;
  ndefs := ctSheet!.ndefs;
  marked := ctSheet!.marked;
  renumbered := ctSheet!.renumbered;
  alives := ctSheet!.alives;
  nalive := Length( alives );
  first := ctSheet!.first;
  str := ctSheet!.digitString2;
  black := rec( color := COLORS.black );
  green := rec( color := COLORS.green );
  red := rec( color := COLORS.red );

  # get the character width and some other variables to display the table
  digits := ctSheet!.digits;
  distance := ctSheet!.small.distance;
  lineHeight := ctSheet!.small.lineHeight;
  charWidth := ctSheet!.small.charWidth;
  y := 3 * distance;
  w := ( digits + 2 ) * charWidth;

  # check the first line to be printed for being in range
  while first > ndefs or renumbered[first] = 0 do
    first := first - 1;
  od;
  line1 := Minimum( renumbered[first], nalive );
  if line1 < 1 then
    line1 := 1;
  fi;
  first := alives[line1];
  lastline := Minimum( line1 + 29, nalive );
  line0 := line1 - 1;

  # get the table and delete the old values
  t := Flat( ctSheet!.graphicTable );
  for i in [ 1 .. Length( t ) ] do
    Delete ( t[i] );
  od;
  if IsBound( ctSheet!.line ) then
    Delete( ctSheet!.line );
  fi;

  # delete the first column
  c := Flat( ctSheet!.firstCol );
  for i in [ 1 .. Length( c ) ] do
    Delete( c[i] );
  od;

  # display a vertical line
  nlines := lastline - line1 + 1;
  ctSheet!.line := Line( ctSheet, w + charWidth, y, 0,
    distance + ( nlines + 1 ) * lineHeight );

  # display the numbers in the first column
  FastUpdate( ctSheet, true );
  ctSheet!.firstCol := [];
  px := - charWidth;
  if nalive <> 1 then
    for i in [ line1 .. lastline ] do
      py := y + (i - line0 + 1) * lineHeight;
      ctSheet!.firstCol[i - line0] :=
        Text( ctSheet, FONTS.small, px, py, str[alives[i]+2] );
    od;
  elif ctSheet!.first = 1 then
    py := y + 2 * lineHeight;
    ctSheet!.firstCol[1] := Text( ctSheet, FONTS.small, px, py, str[3] );
  fi;

  # display the numbers
  t := [];
  for i in [ 1 .. nlines ] do
    coset := alives[line0 + i];
    row := newtab[coset];
    oldrow := oldtab[coset];
    t[i] := [];
    px := 0;
    for j in [ 1 .. ncols ] do
      px := px + w;
      py := y + (i + 1) * lineHeight;
      color := black;
      entry := row[j];
      if entry > 0 then
        if entry in marked then
          color := green;
        elif entry <> oldrow[j] then
          color := red;
        fi;
      elif entry < 0 and entry <> oldrow[j] then
        color := red;
      fi;
      t[i][j] := Text( ctSheet, FONTS.small, px, py, str[entry+2], color );
    od;
  od;
  FastUpdate( ctSheet, false );

  # save the table
  ctSheet!.first := first;
  ctSheet!.nlines := nlines;
  ctSheet!.graphicTable := t;

  # recolor the rows which belong to pending cosets
  ItcRecolorPendingCosets( ctSheet );
  # mark definitions in the coset table
  ItcRecolorDefs( ctSheet );

  # update the info line
  ItcRelabelInfoLine( ctSheet );

  ctSheet!.isActual := true;
end );


#############################################################################
#
# ItcDisplayDefinition( <ctSheet>, <coset> )
#
# installs the  methods for the right pointer button in the definitions list.
#
InstallGlobalFunction( ItcDisplayDefinition, function( ctSheet, coset )

  local charWidth, distance, height, length, lineHeight, name, pos, repLists,
        repNums, repSheets, sheet, string, width;

  # get some local variables
  distance := ctSheet!.normal.distance;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;
  repLists := ctSheet!.repLists;
  repNums := repLists[1];
  repSheets := repLists[2];
  length := Length( repNums );

  # check if there is already a sheet for the rep of this definition
  pos := Position( repNums, coset );
  if pos = fail then

    # get the position for the new sheet
    pos := length + 1;
    repNums[pos] := coset;

  else

    # if there is an old sheet close it, remove the entry, and return
    sheet := repSheets[pos];
    if IsAlive( sheet ) then

      Close( sheet );
      if pos < length then
        repNums[pos] := repNums[length];
        repSheets[pos] := repSheets[length];
      fi;
      Unbind( repNums[length] );
      Unbind( repSheets[length] );
      return;
    fi;

  fi;

  # get the word string to be displayed
  string := String( ItcRepresentativeCoset( ctSheet, coset ) );

  # open a new graphic sheet
  name := Concatenation( "Representative of coset ", String( coset ) );
  width := Maximum(  ( Length( string ) + 2 ) * charWidth,
    WidthOfSheetName( name ) );
  height := 3 * distance + lineHeight;
  sheet := GraphicSheet( name, width, height );

  # diosplay the representative
  sheet!.word := Text( sheet, FONTS.normal, charWidth, lineHeight,
    string );

  # save the sheet
  sheet!.ctSheet := ctSheet;
  repSheets[pos] := sheet;

end );


#############################################################################
#
# ItcDisplayDefinitionsTable( <ctSheet> )
#
# opens or updates the definitions table sheet.
#
InstallGlobalFunction( ItcDisplayDefinitionsTable, function( ctSheet )

  local alives, boxes, charWidth, coset, def, defs, defSheet, digits,
        distance, gen, height, i, inv, j, line0, lineHeight, n, name, names,
        newtab, nlines, string, text, width, x, y;

  # get some local variables
  distance := ctSheet!.small.distance;
  lineHeight := ctSheet!.small.lineHeight;
  charWidth := ctSheet!.small.charWidth;
  digits := ctSheet!.digits;
  names := ctSheet!.genNames;
  newtab := ctSheet!.newtab;
  line0 := ctSheet!.renumbered[ctSheet!.first] - 1;
  nlines := ctSheet!.nlines;
  alives := ctSheet!.alives;
  defs := ctSheet!.defs;

  if IsBound( ctSheet!.defSheet ) and IsAlive( ctSheet!.defSheet ) then

    # clear the existing relation table
    defSheet := ctSheet!.defSheet;
    boxes := defSheet!.boxes;
    FastUpdate( defSheet, true );

    # delete the table entries
    for text in boxes do
      Delete( text );
    od;

  else

    # open a new definitions table
    name := "Definitions";
    n := 12 + 2 * digits + Maximum( List( names, x -> Length( x ) ) );
    width := Maximum( n * charWidth, WidthOfSheetName( name ) );
    height := 3 * distance + 30 * lineHeight;
    defSheet := GraphicSheet( name, width, height );
    SetFilterObj( defSheet, IsItcDefinitionsSheet );

    # install callbacks for the pointer buttons
    InstallCallback( defSheet, "LeftPBDown", ItcDefinitionsSheetPBDown );
    InstallCallback( defSheet, "RightPBDown", ItcDefinitionsSheetPBDown );

    # define the components
    defSheet!.ctSheet := ctSheet;
    ctSheet!.defSheet := defSheet;
    FastUpdate( defSheet, true );

  fi;

  # display the definitions
  boxes := [];
  x := 2 * charWidth;
  for i in [ 1 .. nlines ] do
    coset := alives[line0 + i];
    if coset = 1 then
      string := "1 = 1";
    else
      def := defs[coset - 1];
      gen := def[2];
      inv := gen + 1 - 2 * ( ( gen + 1 ) mod 2 );
      j := newtab[coset][inv];
      string := Concatenation( String( coset ), "  =  ", String( j ),
        " * ", names[gen] );
    fi;
    y := i * lineHeight;
    boxes[i] := Text( defSheet, FONTS.small, x, y, string );
  od;
  FastUpdate( defSheet, false );

  # save the updated components
  defSheet!.boxes := boxes;

end );


#############################################################################
#
# ItcDisplayHeaderOfCosetTable( <ctSheet> )
#
# displays the headers of the coset table.
#
InstallGlobalFunction( ItcDisplayHeaderOfCosetTable, function( ctSheet )

  local charWidth, digits, distance, i, lineHeight, names, string, x, y;

  # get some local variables
  distance := ctSheet!.small.distance;
  lineHeight := ctSheet!.small.lineHeight;
  charWidth := ctSheet!.small.charWidth;
  digits := ctSheet!.digits;
  names := ctSheet!.genNames;

  # output a horizontal line
  x := charWidth;
  y := 3 * distance + lineHeight;
  Line( ctSheet, x, y,
    ( Length( names ) + 1 ) * ( digits + 2 ) * charWidth, 0 );

  # output the generators
  x := 0;
  y := distance + lineHeight;
  for i in [ 1 .. Length( names ) ] do
    x := x + ( digits + 2 ) * charWidth;
    if Length( names[i] ) < 5 then
      string := String( names[i], digits + 2 );
    else
      string := String( names[i], digits + 3 );
    fi;
    Text( ctSheet, FONTS.small, x, y, string );
  od;

end );


#############################################################################
#
# ItcDisplayPendingCoincidences( <ctSheet> )
#
# displays pending coincidences.
#
InstallGlobalFunction( ItcDisplayPendingCoincidences, function( ctSheet )

  local boxes, charWidth, coincs, coiSheet, distance, height, i, lineHeight,
        n, name, ncoincs, pair, string, width, x, y;

  # if there is a coincidences sheet, just close it and return
  if IsBound( ctSheet!.coiSheet ) and IsAlive( ctSheet!.coiSheet ) then
    ItcCloseSheets( ctSheet!.coiSheet!.repSheets );
    Close( ctSheet!.coiSheet );
    return;
  fi;

  # just display a message if there are no pending coincidences
  if ctSheet!.coincs = [] then
    Relabel( ctSheet!.messageText, "There are no pending coincidences" );
    ctSheet!.message := true;
    return;
  fi;

  # get some local variables
  distance := ctSheet!.normal.distance;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;

  # open a proper coincidences sheet
  name := "Pending coincidences";
  coincs := ctSheet!.coincs;
  ncoincs := Length( coincs );
  n := 9 + Maximum( List( coincs, pair -> Length( String( pair[1] ) ) +
    Length( String( pair[1] ) ) ) );
  width := Maximum( n * charWidth, WidthOfSheetName( name ) );
  height := 3 * distance + ncoincs * lineHeight;
  coiSheet := GraphicSheet( "Pending coincidences", width, height );
  SetFilterObj( coiSheet, IsItcCoincSheet );

  # install callbacks for the pointer buttons
  InstallCallback( coiSheet, "LeftPBDown", ItcCoincSheetLeftPBDown );
  InstallCallback( coiSheet, "RightPBDown", ItcCoincSheetRightPBDown );

  boxes := [];
  x := 2 * charWidth;
  for i in [ 1 .. ncoincs ] do
    pair := coincs[i];
    y := i * lineHeight;
    string := Concatenation( String( pair[1] ), "  =  ", String( pair[2] ) );
    boxes[i] := Text( coiSheet, FONTS.normal, x, y, string );
  od;

  coiSheet!.ctSheet := ctSheet;
  coiSheet!.boxes := boxes;
  coiSheet!.repSheets := [];

  ctSheet!.coiSheet := coiSheet;
end );


#############################################################################
#
# ItcDisplayRelationTable( <ctSheet>, <i> )
#
# opens or updates the i-th relation table sheet.
#
InstallGlobalFunction( ItcDisplayRelationTable, function( ctSheet, i )

  local alives, black, charWidth, color, cos, distance, entry, genWidth,
        green, height, j, k, length, length1, line0, lineHeight, marked,
        maxcos, ndefs, name, newtab, nlines, oldrow, oldtab, px, py, red,
        rel, rels, row, rtSheet, rtSheets, str, t, tab, text, vertical,
        width, word, x;

  # get some local variables
  rtSheets := ctSheet!.rtSheets;
  rels := ctSheet!.rels;
  ndefs := ctSheet!.ndefs;
  distance := ctSheet!.small.distance;
  lineHeight := ctSheet!.small.lineHeight;
  charWidth := ctSheet!.small.charWidth;
  genWidth := ctSheet!.small.genWidth;
  line0 := ctSheet!.renumbered[ctSheet!.first] - 1;
  nlines := ctSheet!.nlines;
  alives := ctSheet!.alives;
  marked := ctSheet!.marked;
  word := rels[i];
  rel := ctSheet!.relColumnNums[i];
  length := Length( word );
  length1 := length + 1;
  maxcos := alives[Length( alives )];
  str := ctSheet!.digitString1;
  black := rec( color := COLORS.black );
  green := rec( color := COLORS.green );
  red := rec( color := COLORS.red );

  if IsBound( rtSheets[i] ) and IsAlive( rtSheets[i] ) then

    # clear the existing relation table
    rtSheet := rtSheets[i];
    vertical := rtSheet!.vertical;
    t := rtSheet!.graphicTable;
    FastUpdate( rtSheet, true );

    # delete the table entries
    for row in t do
      for text in row do
        Delete( text );
      od;
    od;

    # delete the vertical lines
    for j in [ 1 .. length ] do
      Delete( vertical[j] );
    od;

  else

    # open a new relation table
    name := Concatenation( "Relator ", String( i ), ":  ",
      ctSheet!.relText[i] );
    width := Maximum( charWidth + length1 * genWidth,
      WidthOfSheetName( name ) );
    height := 3 * distance + ( 30 + 1 ) * lineHeight;
    rtSheet := GraphicSheet( name, width, height );
    SetFilterObj( rtSheet, IsItcRelationTableSheet );

    # install callbacks for the pointer buttons
    InstallCallback( rtSheet, "LeftPBDown",
      ItcRelationTableSheetLeftPBDown );

    # display the header of the relation table
    ItcStringRelationTable( ctSheet, rtSheet, word );

    # draw the horizontal line and initialize the list of vertical lines
    Line( rtSheet, 0, lineHeight + distance, rtSheet!.width, 0 );
    vertical := ListWithIdenticalEntries( length, 0 );

    # define the components
    rtSheet!.ctSheet := ctSheet;
    rtSheet!.number := i;
    rtSheet!.vertical := vertical;
    rtSheets[i] := rtSheet;
    FastUpdate( rtSheet, true );

  fi;

  # compute the new and old relation tables
  newtab := ItcRelationTable( ctSheet, ctSheet!.newtab, rel, line0, nlines );
  oldtab := ItcRelationTable( ctSheet, ctSheet!.oldtab, rel, line0, nlines );

  # draw the vertical lines
  for j in [ 1 .. length ] do
    vertical[j] := Line( rtSheet, j * genWidth, lineHeight + distance, 0,
      2 * distance + nlines * lineHeight );
  od;

  # display the table
  if maxcos <= 100 then
    x := 0;
  else
    x := charWidth;
  fi;
  t := [];
  for j in [ 1 .. nlines ] do
    row := newtab[j];
    oldrow := oldtab[j];
    t[j] := [];
    for k in [ 1 .. length1 ] do
      px := x + (k - 1) * genWidth;
      py := distance + (j + 1) * lineHeight;
      color := black;
      entry := row[k];
      if entry > 0 and 1 < k and k < length1 then
        if entry in marked then
          color := green;
        elif entry <> oldrow[k] then
          color := red;
        fi;
      fi;
      t[j][k] := Text( rtSheet, FONTS.small, px, py, str[entry+1], color );
    od;
  od;
  FastUpdate( rtSheet, false );

  # save the updated components
  rtSheet!.newtab := newtab;
  rtSheet!.oldtab := oldtab;
  rtSheet!.graphicTable := t;

end );


#############################################################################
#
# ItcDisplayRelatorsSheet( <relSheet> )
#
# displays the relators in the windows 'Relators'.
#
InstallGlobalFunction( ItcDisplayRelatorsSheet, function( relSheet )

  local boxes, charWidth, ctSheet, i, lineHeight, relText, string, x, y;

  # get some local variables
  ctSheet := relSheet!.ctSheet;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;
  relText := ctSheet!.relText;

  x := 2 * charWidth;
  boxes := [];
  for i in [ 1 .. Length( relText ) ] do
    y := i * lineHeight;
    string := Concatenation( String( i ), ":  ", relText[i] );
    boxes[i] := Text( relSheet, FONTS.normal, x, y, string );
  od;

  relSheet!.boxes := boxes;
end );


#############################################################################
#
# ItcDisplaySubgroupGeneratorsSheet( <subSheet> )
#
# displays the subgroup generators in the windows 'Subgroup gens'.
#
InstallGlobalFunction( ItcDisplaySubgroupGeneratorsSheet,
  function( subSheet )

  local boxes, charWidth, ctSheet, i, lineHeight, string, subText, x, y;

  # get some local variables
  ctSheet := subSheet!.ctSheet;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;
  subText := ctSheet!.subText;

  x := 2 * charWidth;
  boxes := [];
  for i in [ 1 .. Length( subText ) ] do
    y := i * lineHeight;
    string := Concatenation( String( i ), ":  ", subText[i] );
    boxes[i] := Text( subSheet, FONTS.normal, x, y, string );
  od;

  subSheet!.boxes := boxes;
end );


#############################################################################
#
# ItcDisplaySubgroupTable( <ctSheet>, <i> )
#
# opens or updates the i-th subgroup table sheet.
#
InstallGlobalFunction( ItcDisplaySubgroupTable, function( ctSheet, i )

  local alives, black, charWidth, color, cos, digits, distance, entry,
        fsgens, genWidth, green, height, j, length, length1, lineHeight,
        marked, maxalive, name, ndefs, newtab, oldrow, oldtab, px, py, red,
        rel, row, stSheet, stSheets, str, t1, tab, text, vertical, width,
        word, x;

  # get some local variables
  stSheets := ctSheet!.stSheets;
  fsgens := ctSheet!.fsgens;
  ndefs := ctSheet!.ndefs;
  distance := ctSheet!.small.distance;
  lineHeight := ctSheet!.small.lineHeight;
  charWidth := ctSheet!.small.charWidth;
  genWidth := ctSheet!.small.genWidth;
  digits := ctSheet!.digits;
  marked := ctSheet!.marked;
  alives := ctSheet!.alives;
  maxalive := alives[Length( alives )];
  word := fsgens[i];
  rel := ctSheet!.subColumnNums[i];
  length := Length( word );
  length1 := length + 1;
  str := ctSheet!.digitString1;
  black := rec( color := COLORS.black );
  green := rec( color := COLORS.green );
  red := rec( color := COLORS.red );

  if IsBound( stSheets[i] ) and IsAlive( stSheets[i] ) then

    # clear the existing subgroup table
    stSheet := stSheets[i];
    vertical := stSheet!.vertical;
    t1 := stSheet!.graphicTable[1];
    FastUpdate( stSheet, true );

    # delete the table entries
    for text in t1 do
      Delete( text );
    od;

  else

    # open a new subgroup table
    name := Concatenation( "Subgroup gen ", String( i ), ":  ",
      ctSheet!.subText[i] );
    width := Maximum( charWidth + length1 * genWidth,
      WidthOfSheetName( name ) );
    height := 3 * distance + 2 * lineHeight;
    stSheet := GraphicSheet( name, width, height );
    SetFilterObj( stSheet, IsItcSubgroupTableSheet );

    # install callbacks for the pointer buttons
    InstallCallback( stSheet, "LeftPBDown",
      ItcSubgroupTableSheetLeftPBDown );

    # display the header of the subgroup table
    ItcStringRelationTable( ctSheet, stSheet, word );

    # draw the horizontal line and initialize the list of vertical lines
    Line( stSheet, 0, lineHeight + distance, stSheet!.width, 0 );
    vertical := ListWithIdenticalEntries( length, 0 );

    # draw the vertical lines
    for j in [ 1 .. length ] do
      vertical[j] := Line( stSheet, j * genWidth, lineHeight + distance, 0,
        2 * distance + lineHeight );
    od;

    # define the components
    stSheet!.ctSheet := ctSheet;
    stSheet!.number := i;
    stSheet!.vertical := vertical;
    stSheets[i] := stSheet;
    FastUpdate( stSheet, true );

  fi;

  # compute the new and old subgroup tables
  newtab := ItcRelationTable( ctSheet, ctSheet!.newtab, rel, 0, 1 );
  oldtab := ItcRelationTable( ctSheet, ctSheet!.oldtab, rel, 0, 1 );

  # display the table
  if maxalive <= 100 then
    x := 0;
  else
    x := charWidth;
  fi;
  row := newtab[1];
  oldrow := oldtab[1];
  t1 := [];
  for j in [ 1 .. length1 ] do
    px := x + (j - 1) * genWidth;
    py := distance + 2 * lineHeight;
    color := black;
    entry := row[j];
    if entry > 0 and 1 < j and j < length1 then
      if entry in marked then
        color := green;
      elif entry <> oldrow[j] then
        color := red;
      fi;
    fi;
    t1[j] := Text( stSheet, FONTS.small, px, py, str[entry+1], color );
  od;
  FastUpdate( stSheet, false );

  # save the updated components
  stSheet!.newtab := newtab;
  stSheet!.oldtab := oldtab;
  stSheet!.graphicTable := [ t1 ];

end );


#############################################################################
#
# ItcEnableMenu( <ctSheet> )
#
# enables or disables the menu entries.
#
#
InstallGlobalFunction( ItcEnableMenu, function( ctSheet )

  local i, menus;

  # get some local variables
  menus := ctSheet!.menus;

  # always enable the following functions
  # Enable( menus[2],  1, true ); # change default table size
  # Enable( menus[2],  2, true ); # extend table size
  # Enable( menus[2], 10, true ); # show current settings

  # enable or disable the following switch functions
  if ctSheet!.coincSwitch then
    Enable( menus[2], 3, true );  # coincidence handling off
    Enable( menus[2], 4, false ); # coincidence handling on
  else
    Enable( menus[2], 3, false ); # coincidence handling off
    Enable( menus[2], 4, true );  # coincidence handling on
  fi;
  if ctSheet!.echo then
    Enable( menus[2], 6, true );  # echo off
    Enable( menus[2], 5, false ); # echo on
  else
    Enable( menus[2], 6, false ); # echo off
    Enable( menus[2], 5, true );  # echo on
  fi;

  # enable all gaps strategy switches except of the current one
  Enable( menus[2],  7, true );  # gaps strategy 1 (first gap)
  Enable( menus[2],  8, true );  # gaps strategy 2 (first rep of max weight)
  Enable( menus[2],  9, true );  # gaps strategy 3 (last rep of max weight)
  i := ctSheet!.gapsStrategy + 6;
  Enable( menus[2],  i, false ); # current gaps strategy

  # enable the following function if and only if no definitions have been
  # made yet
  if ctSheet!.ndefs = 1 then
    Enable( menus[4], 1, true );  # read definitions from file
  else
    Enable( menus[4], 1, false ); # read definitions from file
  fi;

  # enable the following function if and only if definitions have already
  # been made
  if ctSheet!.ndefs > 1 then
    Enable( menus[4], 2, true );  # write definitions to file
  else
    Enable( menus[4], 2, false ); # write definitions to file
  fi;

  # enable the following function if and only if the coset table is closed
  if ctSheet!.firstDef = 0 then
    Enable( menus[4], 3, true );  # write standardized table to file
  else
    Enable( menus[4], 3, false ); # write standardized table to file
  fi;

  # enable the following function if and only if the coset table is not
  # closed and there are no pending coincidences
  if ctSheet!.firstDef <> 0 and ctSheet!.coincs = [] then
    Enable( menus[3], 1, true );  # close table by Felsch
    Enable( menus[3], 2, true );  # use gaps 1: first gap
    Enable( menus[3], 3, true );  # use gaps 2: first rep of max weight
    Enable( menus[3], 4, true );  # use gaps 3: last rep of max weight
    Enable( menus[3], 5, true );  # close table by HLT with consequences
  else
    Enable( menus[3], 1, false ); # close table by Felsch
    Enable( menus[3], 2, false ); # use gaps 1: first gap
    Enable( menus[3], 3, false ); # use gaps 2: first rep of max weight
    Enable( menus[3], 4, false ); # use gaps 3: last rep of max weight
    Enable( menus[3], 5, false ); # close table by HLT with consequences
  fi;

end );


#############################################################################
#
# ItcExtendTableSize( <ctSheet>, <menu>, <entry> )
#
# extends the table size.
#
InstallGlobalFunction( ItcExtendTableSize, function( ctSheet, menu, entry )

  local diff, g, generator, inverse, i, limit, nargs, ncols, newtab, next,
        null, oldtab, prev, query, range, size, settingsSheet, string, table,
        zeros;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  # get some local variables
  table := ctSheet!.table;
  next := ctSheet!.next;
  prev := ctSheet!.prev;
  limit := ctSheet!.limit;

  # display the current coset table, if not yet done
  if not ctSheet!.isActual then

    # reconstruct the last preceding state
    ItcExtractPrecedingTable( ctSheet );

    # save the current state.
    ItcExtractTable( ctSheet );

    # display the coset tables and set all variables
    ItcDisplayCosetTable( ctSheet );

    # update all active relator and subgroup generator tables
    ItcUpdateDisplayedLists( ctSheet );
    ItcEnableMenu( ctSheet );
  fi;

  # ask the user for his agreement to extend the table size
  query := Query( Dialog( "OKcancel", Concatenation(
    "extend table size from ", String( limit ), " to" ) ),
    String( 2 * limit ) );

  # echo the command
  if ctSheet!.echo then
    Print( ">> EXTEND TABLE SIZE TO ", query, "\n" );
  fi;

  # return if the query has been canceled
  if query = false then
    return;
  fi;

  # evaluate the query string and check the arguments
  query := ItcQuery( query );
  nargs := Length( query );
  if nargs = 0 then
    size := limit;
  else
    size := query[1];
    if not IsInt( size ) or size < limit or nargs > 1 then
      Relabel( ctSheet!.messageText, "Illegal argument" );
      ctSheet!.message := true;
      return;
    elif size = limit then
      Relabel( ctSheet!.messageText, "This command has no effect" );
      ctSheet!.message := true;
      return;
    fi;
  fi;

  # update the local variables
  table := ctSheet!.table;
  newtab := ctSheet!.newtab;
  oldtab := ctSheet!.oldtab;
  next := ctSheet!.next;
  prev := ctSheet!.prev;
  limit := ctSheet!.limit;
  ncols := ctSheet!.ncols;
  null := - ncols * limit;

  # extend the table to <size> rows and update the representatives of classes
  # of gaps of length 1
  diff := size - limit;
  zeros := ListWithIdenticalEntries( diff, 0 );
  diff := diff * ncols;
  range := [ 1 .. limit ];
  for g in table do
    if Length( g ) = limit then
      for i in range do
        if g[i] < null then
          g[i] := g[i] - diff;
        fi;
      od;
      Append( g, zeros );
    fi;
  od;

  # update the link lists
  for i in [ limit + 1 .. size ] do
    next[i] := i + 1;
    prev[i] := i - 1;
  od;
  next[limit] := limit + 1;
  next[size] := 0;

  # update the pointers to the link lists
  if ctSheet!.firstFree = 0 then
    ctSheet!.firstFree := limit + 1;
    next[ctSheet!.lastDef] := limit + 1;
    prev[limit+1] := ctSheet!.lastDef;
  else
    next[limit] := limit + 1;
  fi;
  ctSheet!.lastFree := size;
  ctSheet!.limit := size;

  # update the auxiliary lists
  Append( newtab, zeros );
  Append( oldtab, zeros );
  ItcMakeDigitStrings( ctSheet );

  # update the sheet of current settings
  if IsBound( ctSheet!.settingsSheet ) and IsAlive( ctSheet!.settingsSheet )
    then
    settingsSheet := ctSheet!.settingsSheet;
    FastUpdate( ctSheet, true );
    string := Concatenation( "table size ", String( size ) );
    Relabel( settingsSheet!.boxes[2], string );
    FastUpdate( ctSheet, false );
  fi;
end );


#############################################################################
#
# ItcExtractPrecedingTable( <ctSheet> )
#
# goes back to the preceding state of the enumeration to provide the old
# coset table
#
InstallGlobalFunction( ItcExtractPrecedingTable, function( ctSheet )

  local coincSwitch, defs, i, ndefs;

  # save the definitions and clear the table.
  defs := ctSheet!.defs;
  ItcClearTable( ctSheet );

  # switch on the automatic handling of coinicidences, if necessary
  coincSwitch := ctSheet!.coincSwitch;
  ctSheet!.coincSwitch := true;

  # reconstruct the old table and extract it
  ndefs := Length( defs );
  for i in [ 1 .. ndefs - 1 ] do
    ItcFastCosetStepFill( ctSheet, defs[i][1], defs[i][2] );
  od;
  ItcExtractTable( ctSheet );

  # reset the coincidences switch
  ctSheet!.coincSwitch := coincSwitch;

  # reconstruct the new table.
  i := ndefs;
  ItcCosetStepFill( ctSheet, defs[i][1], defs[i][2] );

end );


#############################################################################
#
# ItcExtractTable( <ctSheet> )
#
# assumes  that one ore more  enumerations  have been performed  and computes
# the current coset table.
#
InstallGlobalFunction( ItcExtractTable, function( ctSheet )

  local alives, coset, entry, i, j, nalive, ncols, newtab, next, ndefs,
        oldtab, renumbered, row, table;

  # get some local variables
  table := ctSheet!.table;
  next := ctSheet!.next;
  ndefs := ctSheet!.ndefs;
  ncols := ctSheet!.ncols;
  nalive := ndefs - ctSheet!.nrdel;

  # save the new state as old state
  newtab := ctSheet!.oldtab;
  oldtab := ctSheet!.newtab;

  # if there are still zeros among the entries of oldtab and newtab needed
  # replace them by zero lists, otherwise initialize oldtab[ndefs] by zeros
  if newtab[ndefs] = 0 then
    i := ndefs;
    while i > 0 and newtab[i] = 0 do
      newtab[i] := ListWithIdenticalEntries( ncols, 0 );
      oldtab[i] := ListWithIdenticalEntries( ncols, 0 );
      i := i - 1;
    od;
  else
    row := oldtab[ndefs];
    for j in [ 1 .. ncols ] do
      row[j] := 0;
    od;
  fi;

  # make the current state the new state
  renumbered := ListWithIdenticalEntries( ndefs, 0 );
  alives := ListWithIdenticalEntries( nalive, 0 );
  coset := 1;
  for i in [ 1 .. nalive ] do
    row := newtab[coset];
    for j in [ 1 .. ncols ] do
      entry := table[j][coset];
      if entry < -1 then
        entry := -1;
      fi;
      row[j] := entry;
    od;
    alives[i] := coset;
    renumbered[coset] := i;
    coset := next[coset];
  od;

  ctSheet!.oldtab := oldtab;
  ctSheet!.newtab := newtab;
  ctSheet!.alives := alives;
  ctSheet!.renumbered := renumbered;

end );


#############################################################################
#
# ItcFastCosetStepFelsch( <ctSheet> )
#
# defines  a new  coset  (applying the  Felsch  strategy)  and  computes  all
# consequences.
#
InstallGlobalFunction( ItcFastCosetStepFelsch, function( ctSheet )

  local app, generator, i, inverse;

  if ctSheet!.firstFree = 0  then
    return;
  fi;

  # find the next free entry in the coset ctSheet!.table
  i := 1;
  while ctSheet!.table[i][ctSheet!.firstDef] > 0 do
    i := i + 1;
  od;
  generator := ctSheet!.table[i];
  inverse := ctSheet!.table[ctSheet!.invcol[i]];
  ctSheet!.ndefs := ctSheet!.ndefs + 1;

  # add the definition to the save list
  Add( ctSheet!.defs, [ ctSheet!.firstDef, i, ctSheet!.firstFree ] );

  # define a new coset
  generator[ctSheet!.firstDef] := ctSheet!.firstFree;
  inverse[ctSheet!.firstFree] := ctSheet!.firstDef;
  ctSheet!.next[ctSheet!.lastDef] := ctSheet!.firstFree;
  ctSheet!.prev[ctSheet!.firstFree] := ctSheet!.lastDef;
  ctSheet!.lastDef := ctSheet!.firstFree;
  ctSheet!.firstFree := ctSheet!.next[ctSheet!.firstFree];
  ctSheet!.next[ctSheet!.lastDef] := 0;

  # set up the deduction queue and run over it until it's empty
  if ctSheet!.coincSwitch then

    # this is the usual method with automatic handling of coincidences
    app := ctSheet!.app;
    app[6] := ctSheet!.firstFree;
    app[7] := ctSheet!.lastFree;
    app[8] := ctSheet!.firstDef;
    app[9] := ctSheet!.lastDef;
    app[10] := i;
    app[11] := ctSheet!.firstDef;
    ctSheet!.nrdel := ctSheet!.nrdel + ItcMakeConsequences( app );
    if app[7] <> ctSheet!.lastFree then
      ctSheet!.next[ctSheet!.lastFree] := 0;
    fi;
    ctSheet!.firstDef := app[8];
    ctSheet!.lastDef := app[9];

  else

    # this is the alternative method without handling of coincidences
    ctSheet!.deducs := [ [ ctSheet!.firstDef, i ] ];
    ItcHandlePendingDeductions( ctSheet );

  fi;
  ItcUpdateFirstDef( ctSheet );

  # close all gap sheets and reinitialize the gap lists
  ItcCloseGapSheets( ctSheet );
  ctSheet!.gaps := 0;

  ctSheet!.isActual := false;

end );


#############################################################################
#
# ItcFastCosetStepFill( <ctSheet>, <coset>, <gen> )
#
# computes   one  step   of  the   coset   enumeration   for  the  definition
# <coset><gen> = <newcoset> with all consequences and coincidences.
#
InstallGlobalFunction( ItcFastCosetStepFill, function( ctSheet, coset, gen )

  local app, generator, inverse;

  if ctSheet!.firstFree = 0  then
    return;
  fi;

  generator := ctSheet!.table[gen];
  inverse := ctSheet!.table[ctSheet!.invcol[gen]];
  ctSheet!.ndefs := ctSheet!.ndefs + 1;

  # add the definition to the save list
  Add( ctSheet!.defs, [ coset, gen, ctSheet!.firstFree ] );

  # define the new coset
  generator[coset] := ctSheet!.firstFree;
  inverse[ctSheet!.firstFree] := coset;
  ctSheet!.next[ctSheet!.lastDef] := ctSheet!.firstFree;
  ctSheet!.prev[ctSheet!.firstFree] := ctSheet!.lastDef;
  ctSheet!.lastDef := ctSheet!.firstFree;
  ctSheet!.firstFree := ctSheet!.next[ctSheet!.firstFree];
  ctSheet!.next[ctSheet!.lastDef] := 0;

  # set up the deduction queue and run over it until it's empty
  if ctSheet!.coincSwitch then

    # this is the usual method with automatic handling of coincidences
    app := ctSheet!.app;
    app[6] := ctSheet!.firstFree;
    app[7] := ctSheet!.lastFree;
    app[8] := ctSheet!.firstDef;
    app[9] := ctSheet!.lastDef;
    app[10] := gen;
    app[11] := coset;
    ctSheet!.nrdel := ctSheet!.nrdel + ItcMakeConsequences( app );
    if app[7] <> ctSheet!.lastFree then
      ctSheet!.next[ctSheet!.lastFree] := 0;
    fi;
    ctSheet!.firstDef := app[8];
    ctSheet!.lastDef := app[9];

  else

    # this is the alternative method without handling of coincidences
    ctSheet!.deducs := [ [ coset, gen ] ];
    ItcHandlePendingDeductions( ctSheet );

  fi;
  ItcUpdateFirstDef( ctSheet );

  # close all gap sheets and reinitialize the gap lists
  ItcCloseGapSheets( ctSheet );
  ctSheet!.gaps := 0;

  ctSheet!.isActual := false;
end );


#############################################################################
#
# ItcFelsch( <ctSheet>, <menu>, <entry> )
#
# is called by selecting the menu entry 'Go On ( Felsch )' or by clicking the
# button 'Felsch'.
#
InstallGlobalFunction( ItcFelsch, function( ctSheet, menu, entry )

  local k, limit, nargs, ndefs, query, steps;

  # there is nothing to do if the coset table is closed
  if ctSheet!.firstDef = 0 then
    Relabel( ctSheet!.messageText, "The tables are closed" );
    ctSheet!.message := true;
    return;
  fi;

  # new definitions are not allowed if there are pending coincidences
  if not ctSheet!.coincs = [] then
    Relabel( ctSheet!.messageText, "There are pending coincidences" );
    ctSheet!.message := true;
    return;
  fi;

  # select number of definitions to be made
  query := Query( Dialog( "OKcancel", "steps ?" ), "1" );

  # echo the command
  if ctSheet!.echo then
    Print( ">> FELSCH ", query, "\n" );
  fi;

  # return if the query has been canceled
  if query = false then
    return;
  fi;

  # evaluate the query string and check the arguments
  query := ItcQuery( query );
  nargs := Length( query );
  if nargs = 0 or query = [ 0 ] then
    Relabel( ctSheet!.messageText, "This command has no effect" );
    ctSheet!.message := true;
    return;
  fi;
  steps := query[1];
  if not IsInt( steps ) or steps < 0 or nargs > 1 then
    Relabel( ctSheet!.messageText, "Illegal argument" );
    ctSheet!.message := true;
    return;
  fi;

  # do the enumeration
  limit := ctSheet!.limit;
  k := 0;
  while k < steps do

    # extend the table is necessary
    ndefs := ctSheet!.ndefs;
    if ndefs = limit then
      ItcExtendTableSize( ctSheet, 0, 0 );
      limit := ctSheet!.limit;
      if ndefs = limit then
        # insufficient table size: display a message and return
        Relabel( ctSheet!.messageText, "Insufficient table size" );
        ctSheet!.message := true;
        return;
      fi;
    fi;

    # define the next coset
    k := k + 1;
    if k = 1 or k < steps then
      ItcFastCosetStepFelsch( ctSheet );
    else
      ItcCosetStepFelsch( ctSheet );
    fi;
    ItcRelabelInfoLine( ctSheet );
    if k < steps then

      # if table has already closed or if there are pending coincidences
      # reconstruct the last preceding state and break the loop
      if ctSheet!.firstDef = 0 or not ctSheet!.coincs = [] then
        ItcExtractPrecedingTable( ctSheet );
        steps := k;

      # if only one more step has to be done save the new state
      elif k = steps - 1 then
        ItcExtractTable( ctSheet );

      fi;
    fi;
  od;

  # save the current state
  ItcExtractTable( ctSheet );

  # display the coset tables and set all variables
  ItcDisplayCosetTable( ctSheet );

  # update all active relator tables and subgroup generator tables
  ItcUpdateDisplayedLists( ctSheet );

  # if there are pending coincidences display them
  if not ctSheet!.coincs = [] then
    ItcDisplayPendingCoincidences( ctSheet );
  fi;

  ItcEnableMenu( ctSheet );

end );


#############################################################################
#
# ItcFillCosetTableEntry( <ctSheet>, <coset>, <gen> )
#
# defines a new coset to fill the so far undefined coste table entry in
# position [ <coset>, <gen> ].
#
InstallGlobalFunction( ItcFillCosetTableEntry,
  function( ctSheet, coset, gen )

  # new definitions are not allowed if there are pending coincidences
  if not ctSheet!.coincs = [] then
    Relabel( ctSheet!.messageText, "There are pending coincidences" );
    ctSheet!.message := true;
    return;
  fi;

  # extend the table if it is necessary
  if ctSheet!.ndefs = ctSheet!.limit then
    ItcExtendTableSize( ctSheet, 0, 0 );
    if ctSheet!.ndefs = ctSheet!.limit then
      # insufficient table size: display a message and return
      Relabel( ctSheet!.messageText, "Insufficient table size" );
      ctSheet!.message := true;
      return;
    fi;
  fi;

  # define the new coset and work off all consequences
  ItcCosetStepFill( ctSheet, coset, gen );

  # if there are pending coincidences display them
  if not ctSheet!.coincs = [] then
    ItcDisplayPendingCoincidences( ctSheet );
  fi;

end );


#############################################################################
#
# ItcFillGaps( <ctSheet>, <menu>, <entry> )
#
# is called  by selecting the menu entry 'Go on ( fill gaps )' or by clicking
# on the button 'fill gaps'.
#
InstallGlobalFunction( ItcFillGaps, function( ctSheet, menu, entry )

  local first, k, limit, nargs, ndefs, pos, query, steps;

  # there is nothing to do if the coset table is closed
  if ctSheet!.firstDef = 0 then
    Relabel( ctSheet!.messageText, "The tables are closed" );
    ctSheet!.message := true;
    return;
  fi;

  # new definitions are not allowed if there are pending coincidences
  if not ctSheet!.coincs = [] then
    Relabel( ctSheet!.messageText, "There are pending coincidences" );
    ctSheet!.message := true;
    return;
  fi;

  # there is nothing to do if there are no gaps of length 1
  pos := ItcFirstGapOfLengthOne( ctSheet, 0 );
  if pos = fail then
    if ctSheet!.echo then
      Print( ">> FILL GAPS\n" );
    fi;
    Relabel( ctSheet!.messageText, "There are no gaps of length 1" );
    ctSheet!.message := true;
    return;
  fi;

  # select number of definitions to be made
  query := Query( Dialog( "OKcancel", "steps ?" ), "1" );

  # echo the command
  if ctSheet!.echo then
    Print( ">> FILL GAPS ", query, "\n" );
  fi;

  # return if the query has been canceled
  if query = false then
    return;
  fi;

  # evaluate the query string and check the arguments
  query := ItcQuery( query );
  nargs := Length( query );
  if nargs = 0 or query = [ 0 ] then
    Relabel( ctSheet!.messageText, "This command has no effect" );
    ctSheet!.message := true;
    return;
  fi;
  steps := query[1];
  if not IsInt( steps ) or steps < 0 or nargs > 1 then
    Relabel( ctSheet!.messageText, "Illegal argument" );
    ctSheet!.message := true;
    return;
  fi;

  # save the current scroll position
  first := ctSheet!.first;

  # do the enumeration
  limit := ctSheet!.limit;
  k := 0;
  while k < steps do

    # extend the table is necessary
    ndefs := ctSheet!.ndefs;
    if ndefs = limit then
      ItcExtendTableSize( ctSheet, 0, 0 );
      limit := ctSheet!.limit;
      if ndefs = limit then
        # insufficient table size: display a message and return
        Relabel( ctSheet!.messageText, "Insufficient table size" );
        ctSheet!.message := true;
        return;
      fi;
    fi;

    # define the next coset
    k := k + 1;
    if k = 1 or k < steps then
      ItcFastCosetStepFill( ctSheet, pos[1], pos[2] );
      ItcRelabelInfoLine( ctSheet );
    else
      ItcCosetStepFill( ctSheet, pos[1], pos[2] );
    fi;
    if k < steps then

      # if there are no gaps of length one left or if there are pending
      # coincidences reconstruct the last preceding state, display an
      # appropriate message, and and break the loop
      pos := ItcFirstGapOfLengthOne( ctSheet, 0 );
      if pos = fail or not ctSheet!.coincs = [] then
        ItcExtractPrecedingTable( ctSheet );
        if not ctSheet!.coincs = [] then
          Relabel( ctSheet!.messageText, "There are pending coincidences" );
        elif ctSheet!.firstDef > 0 then
          Relabel( ctSheet!.messageText,
            "There are no more gaps of length 1" );
        fi;
        ctSheet!.message := true;
        steps := k;

      # if only one more step has to be done save the new state
      elif k = steps - 1 then
        ItcExtractTable( ctSheet );

      fi;
    fi;
  od;

  # save the current state
  ItcExtractTable( ctSheet );
  ctSheet!.first := first;

  # display the coset tables and set all variables
  ItcDisplayCosetTable( ctSheet );

  # update all active relator tables and subgroup generator tables
  ItcUpdateDisplayedLists( ctSheet );

  # if there are pending coincidences display them
  if not ctSheet!.coincs = [] then
    ItcDisplayPendingCoincidences( ctSheet );
  fi;

  ItcEnableMenu( ctSheet );

end );


#############################################################################
#
# ItcFillRows( <ctSheet>, <menu>, <entry> )
#
# is called  by selecting the menu entry 'Go on ( fill rows )' or by clicking
# on the button 'fill rows'.
#
InstallGlobalFunction( ItcFillRows, function( ctSheet, menu, entry )

  local alives, closed, coset, cosets, hlt, i, j, length, maxdef, ndefs,
        nrels, nsgens, num, overflow, pos, position, query, relColumnNums,
        subColumnNums, subgrp;

  # there is nothing to do if the coset table is closed
  if ctSheet!.firstDef = 0 then
    Relabel( ctSheet!.messageText, "The tables are closed" );
    ctSheet!.message := true;
    return;
  fi;

  # new definitions are not allowed if there are pending coincidences
  if not ctSheet!.coincs = [] then
    Relabel( ctSheet!.messageText, "There are pending coincidences" );
    ctSheet!.message := true;
    return;
  fi;

  # get some local variables
  relColumnNums := ctSheet!.relColumnNums;
  subColumnNums := ctSheet!.subColumnNums;
  subgrp := ctSheet!.subgrp;
  ndefs := ctSheet!.ndefs;
  nrels := Length( ctSheet!.rels );
  nsgens := Length( ctSheet!.fsgens );
  alives := ctSheet!.alives;

  # select the coset number specifying the rows to be closed
  if not subgrp = [] then
    query := Query( Dialog( "OKcancel",
      "row numbers? (0 for subgroup tables)" ), "0" );
  else
    # find an appropriate default value
    closed := true;
    i := 0;
    while closed do
      i := i + 1;
      coset := alives[i];
      j := 0;
      while closed and j < nrels do
        j := j + 1;
        closed := ItcIsClosedRow( ctSheet, coset, relColumnNums[j] );
      od;
    od;
    query := Query( Dialog( "OKcancel", "row numbers?" ), String( coset ) );
  fi;

  # echo the command
  if ctSheet!.echo then
    Print( ">> FILL ROWS ", query, "\n" );
  fi;

  # return if the query has been canceled
  if query = false then
    return;
  fi;

  # evaluate the query string and check the arguments
  cosets := ItcQuery( query );
  if cosets = [] then
    Relabel( ctSheet!.messageText, "This command has no effect" );
    ctSheet!.message := true;
    return;
  fi;
  for num in cosets do
    if not IsInt( num ) or num < 0 or ndefs < num then
      Relabel( ctSheet!.messageText, "Illegal argument" );
      ctSheet!.message := true;
      return;
    fi;
  od;

  # initialize the list of arguments for ItcFillTraceHLT
  maxdef := 0;
  overflow := false;
  hlt := [ 1, maxdef, overflow ];

  # loop over the given cosets
  length := Length( cosets );
  i := 0;
  while i < length do
    i := i + 1;
    coset := cosets[i];
    if coset = 0 and not subgrp = [] then

      # fill the subgroup tables
      hlt[1] := 1;
      j := 0;
      while j < nsgens do
        j := j + 1;
        ItcFillTraceHLT( ctSheet, hlt, subColumnNums[j] );
        overflow := hlt[3];
        if overflow or not ctSheet!.coincs = [] then
          # break the loops in case of insufficient table size or if there
          # are pending coincidences
          j := nsgens;
          i := length;
        fi;
      od;

    elif coset > 0 then

      # fill the specified row in each relation table
      hlt[1] := coset;
      j := 0;
      while j < nrels do
        j := j + 1;
        ItcFillTraceHLT( ctSheet, hlt, relColumnNums[j] );
        overflow := hlt[3];
        if overflow or not ctSheet!.coincs = [] then
          # break the loops in case of insufficient table size or if there
          # are pending coincidences
          j := nrels;
          i := length;
        elif hlt[1] <> coset then
          # break the inner loop if the coset is not alive
          j := nrels;
        fi;
      od;

    fi;
  od;

  if ctSheet!.ndefs > ndefs then

    if ctSheet!.ndefs - ndefs > 1 then
      ItcExtractPrecedingTable( ctSheet );
    fi;

    # save the current state
    ItcExtractTable( ctSheet );

    # display the coset tables and set all variables
    ItcDisplayCosetTable( ctSheet );

    # update all active relator tables and subgroup generator tables
    ItcUpdateDisplayedLists( ctSheet );

    # if there are pending coincidences display them
    if not ctSheet!.coincs = [] then
      ItcDisplayPendingCoincidences( ctSheet );
    fi;

    ItcEnableMenu( ctSheet );
  fi;

end );


#############################################################################
#
# ItcFillTrace( <ctSheet>, <coset>, <columns> )
#
# traces the given coset  through the given word  and defines  new cosets  if
# they are necessary to close the trace.
#
InstallGlobalFunction( ItcFillTrace, function( ctSheet, coset, columns )

  local closed, cos, factor, fgens, gen, i, length, ndefs, renumbered, table;

  # get some local variables
  length := Length( columns );
  fgens := ctSheet!.fgens;
  table := ctSheet!.table;
  renumbered := ctSheet!.renumbered;
  closed := false;

  while not closed do

    # scan as long as possible from the left to the right
    closed := true;
    cos := coset;
    i := 1;
    while closed and i < length do
      gen := columns[i];
      if table[gen][cos] > 0 then
        cos := table[gen][cos];
        i := i + 1;
      else
        closed := false;
      fi;
    od;

    # define a new coset if not closed
    if not closed then

      ndefs := ctSheet!.ndefs;
      ItcFillCosetTableEntry( ctSheet, cos, gen );

      # check for a fail because of insufficient table size
      if ctSheet!.ndefs = ndefs then
        # reconstruct the last preceding state.
        ItcExtractPrecedingTable( ctSheet );
        ItcExtractTable( ctSheet );
        ItcDisplayCosetTable( ctSheet );
        ItcUpdateDisplayedLists( ctSheet );
        ItcEnableMenu( ctSheet );
        return;
      fi;

      ItcExtractTable( ctSheet );
      table := ctSheet!.table;
      renumbered := ctSheet!.renumbered;

      if ctSheet!.renumbered[coset] = 0 or not ctSheet!.coincs = [] then
        ItcDisplayCosetTable( ctSheet );
        ItcUpdateDisplayedLists( ctSheet );
        ItcEnableMenu( ctSheet );
        return;
      fi;
      if ctSheet!.renumbered[coset] = 0 or not ctSheet!.coincs = [] then
        return;
      fi;
    fi;

  od;
end );


#############################################################################
#
# ItcFillTraceHLT( <ctSheet>, <hlt>, <columns> )
#
# traces the given coset  through the given word  and defines  new cosets  if
# they are necessary to close the trace.
#
InstallGlobalFunction( ItcFillTraceHLT, function( ctSheet, hlt, columns )

  local closed, cos, coset, factor, fgens, gen, i, length, maxdef, ndefs,
        next, table;

  # get some local variables
  length := Length( columns );
  coset := hlt[1];
  maxdef := hlt[2];
  fgens := ctSheet!.fgens;
  table := ctSheet!.table;
  next := ctSheet!.next;
  closed := false;

  while not closed do

    # check if the coset is still alive
    cos := 1;
    while cos < coset and 0 < cos do
      cos := next[cos];
    od;
    if cos > coset or cos = 0 then
      hlt[1] := cos;
      return;
    fi;

    # scan as long as possible from the left to the right
    closed := true;
    cos := coset;
    i := 1;
    while closed and i < length do
      gen := columns[i];
      if table[gen][cos] > 0 then
        cos := table[gen][cos];
        i := i + 1;
      else
        closed := false;
      fi;
    od;

    # define a new coset if not closed
    if not closed then

      ndefs := ctSheet!.ndefs;
      ItcFillCosetTableEntry( ctSheet, cos, gen );

      # check for a fail because of insufficient table size
      if ctSheet!.ndefs = ndefs then
        # set the overflow switch and return
        hlt[3] := true;
        return;
      fi;

      # return if we have reached the prescribed limit of definitions or
      # if there are pending coincidences
      if ctSheet!.ndefs = maxdef or not ctSheet!.coincs = [] then
        return;
      fi;

      # continue the loop
      table := ctSheet!.table;
    fi;

  od;
end );


#############################################################################
#
# ItcFirstGapOfLengthOne( <ctSheet>, <strategy> )
#
# returns  the position [ coset, gen ] in the coset table  of the 'first' gap
# of length 1, or the value fail, if there are none.
#
InstallGlobalFunction( ItcFirstGapOfLengthOne, function( ctSheet, strategy )

  local coset, gaps, gen, i, nclasses, ncols, pos, reps, table, weight;

  # get the strategy
  if strategy = 0 then
    strategy := ctSheet!.gapsStrategy;
  fi;
  pos := fail;

  if strategy = 1 then

    # strategy 1: first gap ( = first rep )
    # -------------------------------------

    # get some local variables
    table := ctSheet!.table;
    ncols := ctSheet!.ncols;

    # find the first gap of length 1
    coset := ctSheet!.firstDef;
    while coset <> 0 do
      gen := 0;
      while gen < ncols do
        gen := gen + 1;
        if ctSheet!.table[gen][coset] < 0 then
          return [ coset, gen ];
        fi;
      od;
      coset := ctSheet!.next[coset];
    od;

  elif strategy = 2 then

    # strategy 2: first rep of max weight ( = first gap of max weight )
    # -----------------------------------------------------------------

    gaps := ItcGaps( ctSheet );
    reps := gaps[1];
    if reps <> [] then
      pos :=  [ reps[1][2], reps[1][3] ];
    fi;

  elif strategy = 3 then

    # strategy 3: last rep of max weight
    # ----------------------------------

    gaps := ItcGaps( ctSheet );
    reps := gaps[1];
    if reps <> [] then
      nclasses := Length( reps );
      weight := reps[1][1];
      i := 1;
      while i < nclasses and reps[i+1][1] = weight do
        i := i + 1;
      od;
      pos :=  [ reps[i][2], reps[i][3] ];
    fi;

  fi;

  return pos;
end );


#############################################################################
#
# ItcHLT( <ctSheet>, <menu>, <entry> )
#
# is called by clicking the button 'HLT'.
#
InstallGlobalFunction( ItcHLT, function( ctSheet, menu, entry )

  local coset, i, hlt, maxdef, nargs, ndefs, nrels, nsgens, overflow, query,
        relColumnNums, steps, subColumnNums, subgrp;

  # there is nothing to do if the coset table is closed
  if ctSheet!.firstDef = 0 then
    Relabel( ctSheet!.messageText, "The tables are closed" );
    ctSheet!.message := true;
    return;
  fi;

  # new definitions are not allowed if there are pending coincidences
  if not ctSheet!.coincs = [] then
    Relabel( ctSheet!.messageText, "There are pending coincidences" );
    ctSheet!.message := true;
    return;
  fi;

  # select number of definitions to be made
  query := Query( Dialog( "OKcancel", "steps ?" ), "1" );

  # echo the command
  if ctSheet!.echo then
    Print( ">> HLT ", query, "\n" );
  fi;

  # return if the query has been canceled
  if query = false then
    return;
  fi;

  # evaluate the query string and check the arguments
  query := ItcQuery( query );
  nargs := Length( query );
  if nargs = 0 or query = [ 0 ] then
    Relabel( ctSheet!.messageText, "This command has no effect" );
    ctSheet!.message := true;
    return;
  fi;
  steps := query[1];
  if not IsInt( steps ) or steps < 0 or nargs > 1 then
    Relabel( ctSheet!.messageText, "Illegal argument" );
    ctSheet!.message := true;
    return;
  fi;

  # get some local variables
  subColumnNums := ctSheet!.subColumnNums;
  relColumnNums := ctSheet!.relColumnNums;
  subgrp := ctSheet!.subgrp;
  ndefs := ctSheet!.ndefs;
  nrels := Length( ctSheet!.rels );
  nsgens := Length( ctSheet!.fsgens );
  maxdef := ndefs + steps;
  coset := ctSheet!.hltRow;
  overflow := false;
  hlt := [ coset, maxdef, overflow ];

  # fill the subgroup tables
  if not subgrp = [] then
    if coset <> 1 then
      Error( "THIS IS A BUG (ITC 06), YOU SHOULD NEVER GET HERE" );
    fi;
    i := 0;
    while i < nsgens do
      i := i + 1;
      ItcFillTraceHLT( ctSheet, hlt, subColumnNums[i] );
      overflow := hlt[3];
      # break the loop if done or in case of insufficient table size or if
      # there are pending coincidences
      if overflow or not ctSheet!.coincs = [] then
        maxdef := ctSheet!.ndefs;
      fi;
      if ctSheet!.ndefs = maxdef then
        i := nrels;
      fi;
    od;
  fi;

  # check if the table is closed
  # if ctSheet!.firstDef = 0 then
  # fi;

  coset := ctSheet!.hltRow;
  hlt[1] := coset;
  while maxdef <> ctSheet!.ndefs and coset <> 0 do
    ctSheet!.hltRow := coset;

    # fill the corresponding row in each relation table
    i := 0;
    while i < nrels do
      i := i + 1;
      ItcFillTraceHLT( ctSheet, hlt, relColumnNums[i] );
      overflow := hlt[3];
      # break the loops if done or in case of insufficient table size or if
      # there are pending coincidences
      if overflow or not ctSheet!.coincs = [] then
        maxdef := ctSheet!.ndefs;
      fi;
      # break the inner loop if the coset is not alive any more
      if ctSheet!.ndefs = maxdef or hlt[1] <> coset then
        i := nrels;
      fi;
    od;
    if hlt[1] = coset then
      coset := ctSheet!.next[coset];
      hlt[1] := coset;
    else
      coset := hlt[1];
    fi;

  od;

  if ctSheet!.ndefs > ndefs and not overflow then

    if ctSheet!.ndefs - ndefs > 1 then
      ItcExtractPrecedingTable( ctSheet );
    fi;

    # save the current state
    ItcExtractTable( ctSheet );

    # display the coset tables and set all variables
    ItcDisplayCosetTable( ctSheet );

    # update all active relator tables and subgroup generator tables
    ItcUpdateDisplayedLists( ctSheet );

    # if there are pending coincidences display them
    if not ctSheet!.coincs = [] then
      ItcDisplayPendingCoincidences( ctSheet );
    fi;

    ItcEnableMenu( ctSheet );
  fi;

end );


#############################################################################
#
# ItcHandlePendingCoincidence( <ctSheet>, <n> )
#
# handles the the n-th pending coincidence.
#
InstallGlobalFunction( ItcHandlePendingCoincidence, function( ctSheet, n )

  local c1, c2, coincs, cos0, cos1, cos2, ded, deducs, gen, firstDef,
        firstFree, i, i0, involutory, j, JoinClasses, lastDef, lastFree,
        lengthTable, next, null, pair, prev, rep, table;

#============================================================================
#
# JoinClasses( <i1>, <cos1>, <i2>, <cos2> );
#
# This is a GAP version of the (not yet existing) kernel routine JoinClasses.
# It joins the  classes  of gaps of length 1  represented  by the coset table
# entries  table[i][cos1]  and  table[i][cos2]   and  determins  the  positon
# table[i0][cos0] of the common representative rep.
#
JoinClasses := function( i1, cos1, i2, cos2 )

    local cos3, cos4, i3, i4, pos3, pos4, rep3, rep4;

    # get the class rep of gen[cos1];
    i3 := i1;
    cos3 := cos1;
    rep3 := -table[i3][cos3];
    while 0 < rep3 and rep3 < null do
      i3 := ( rep3 - 1 ) mod lengthTable + 1;
      cos3 := ( rep3 - i3 ) / lengthTable + 1;
      rep3 := -table[i3][cos3];
    od;

    # get the class rep of gen[cos2];
    i4 := i2;
    cos4 := cos2;
    rep4 := -table[i4][cos4];
    while 0 < rep4 and rep4 < null do
      i4 := ( rep4 - 1 ) mod lengthTable + 1;
      cos4 := ( rep4 - i4 ) / lengthTable + 1;
      rep4 := -table[i4][cos4];
    od;

    # get the common class representative rep
    if rep3 > null and rep4 > null then
      pos3 := ( cos3 - 1 ) * lengthTable + i3;
      pos4 := ( cos4 - 1 ) * lengthTable + i4;
      if pos3 < pos4 then
        table[i4][cos4] := -pos3;
        i0 := i3;
        cos0 := cos3;
        rep := rep3 + rep4 - null;
        table[i0][cos0] := -rep;
      elif pos4 < pos3 then
        table[i3][cos3] := -pos4;
        i0 := i4;
        cos0 := cos4;
        rep := rep3 + rep4 - null;
        table[i0][cos0] := -rep;
      else
        i0 := i3;
        cos0 := cos3;
        rep := rep3;
      fi;
    else
      table[i1][cos1] := 0;
      table[i2][cos2] := 0;
      if table[i3][cos3] < 0 then
        table[i3][cos3] := 0;
      fi;
      if table[i4][cos4] < 0 then
        table[i4][cos4] := 0;
      fi;
      rep := 0;
    fi;

end;

#============================================================================

  # get the numbers of the involved cosets
  cos1 := ctSheet!.coincs[n][2];
  cos2 := ctSheet!.coincs[n][1];
  if not cos1 < cos2 then
    Error( "THIS IS A BUG (ITC 07), YOU SHOULD NEVER GET HERE" );
  fi;

  # get some local variables
  table := ctSheet!.table;
  next := ctSheet!.next;
  prev := ctSheet!.prev;
  involutory := ctSheet!.involutory;
  firstFree := ctSheet!.firstFree;
  lastFree := ctSheet!.lastFree;
  firstDef := ctSheet!.firstDef;
  lastDef := ctSheet!.lastDef;
  lengthTable := Length( table );
  null := lengthTable * Length( table[1] );

  # replace any occurrence of cos2 in the list of pending coincidences by
  # cos1
  coincs := [];
  for pair in ctSheet!.coincs do
    if pair[1] = cos2 then
      pair[1] := cos1;
    fi;
    if pair[2] = cos2 then
      pair[2] := cos1;
    fi;
    if pair[1] > pair[2] then
      AddSet( coincs, pair );
    elif pair[1] < pair[2] then
      AddSet( coincs, [ pair[2], pair[1] ] );
    fi;
  od;

  # replace any occurrence of cos2 in the list of pending deductions by cos1
  deducs := [];
  for pair in ctSheet!.deducs do
    if pair[1] = cos2 then
      pair[1] := cos1;
    fi;
    AddSet( deducs, pair );
  od;

  # replace any occurrence of cos2 in the coset table by cos1
  for i in [ 1 .. lengthTable ] do
    gen := table[i];
    j := 1;
    while j <> 0 do
      if gen[j] = cos2 then
        gen[j] := cos1;
        if j <> cos2 then
          AddSet( deducs, [ j, i ] );
          if involutory[i] = 2 then
            AddSet( deducs, [ j, i + 1 ] );
          fi;
        fi;
      fi;
      j := next[j];
    od;
  od;

  # remove all non-zero entries from row cos2 in the table
  for i in [ 1 .. lengthTable ] do
    gen := table[i];
    c1 := gen[cos1];
    c2 := gen[cos2];
    if c2 > 0 then

      # if the other entry is empty copy it
      if c1 <= 0 then
        gen[cos1] := c2;
        gen[cos2] := 0;
        Add( deducs, [ cos1, i ] );

      # otherwise check for a coincidence
      elif c1 > c2 then
        AddSet( coincs, [ c1, c2 ] );
      elif c1 < c2 then
        AddSet( coincs, [ c2, c1 ] );
      fi;

    # handle minimal gaps
    elif c2 < 0 then
      c1 := gen[cos1];
      if c1 > 0 then
        # the class will vanish by further coincidences, so replace
        # the current entry c2 by zero
        gen[cos2] := 0;
      elif c1 < 0 then
        # there are two classes, join them and decrease the number
        JoinClasses( i, cos1, i, cos2 );
        if rep > null then
          table[i0][cos0] := 1 - rep;
        fi;
      elif c1 = 0 then
        # make gen[cos1] the representative of a new class of gaps
        c1 := - ( null + involutory[i] );
        gen[cos1] := c1;
        # now join the classes and decrease the number
        JoinClasses( i, cos1, i, cos2 );
        if rep > null then
          table[i0][cos0] := 1 - rep;
        fi;
      fi;

    fi;
  od;

  # if we are removing an important coset update it
  if cos2 = lastDef then
      lastDef := prev[lastDef];
  fi;
  if cos2 = firstDef then
      firstDef := prev[firstDef];
  fi;

  # remove cos2 from the coset list
  next[prev[cos2]] := next[cos2];
  if next[cos2] <> 0 then
      prev[next[cos2]] := prev[cos2];
  fi;

  # move the replaced coset to the free list
  if firstFree = 0 then
      firstFree      := cos2;
      lastFree       := cos2;
  else
      next[lastFree] := cos2;
      lastFree       := cos2;
  fi;
  next[lastFree] := 0;

  ctSheet!.firstFree := firstFree;
  ctSheet!.lastFree := lastFree;
  ctSheet!.firstDef := firstDef;
  ctSheet!.lastDef := lastDef;

  ItcUpdateFirstDef( ctSheet );
  ctSheet!.nrdel := ctSheet!.nrdel + 1;

  ctSheet!.coincs := coincs;
  ctSheet!.deducs := deducs;

  # if there are no pending coincidences left, handle the pending deductions
  if coincs = [] then
    ItcHandlePendingDeductions( ctSheet );
    if ctSheet!.coincs = [] then
      ctSheet!.deducs := [];
    fi;
  fi;

  # if no new coincidences have occurred and if there is a coincidences
  # sheet alive, close it
  if ctSheet!.coincs = [] and IsBound( ctSheet!.coiSheet ) and
    IsAlive( ctSheet!.coiSheet ) then
    ItcCloseSheets( ctSheet!.coiSheet!.repSheets );
    Close( ctSheet!.coiSheet );
  fi;

end );


#############################################################################
#
# ItcGaps( <ctSheet> )
#
# initializes  the  lists  of  gaps  of  length 1  and  picks  up  the  class
# representatives from the coset table.
#
InstallGlobalFunction( ItcGaps, function( ctSheet )

  local classes, classSheets, cos, cos1, entry, gaps, gapSheet, gen, gen1,
        involutory, length, ncols, next, null, rep, reps, table;

  # if the list of gaps of length 1 is already available, just return it
  if not ctSheet!.gaps = 0 then
    return ctSheet!.gaps;
  fi;

  # get some local variables
  table := ctSheet!.table;
  involutory := ctSheet!.involutory;
  next := ctSheet!.next;
  ncols := ctSheet!.ncols;
  null := ncols * ctSheet!.limit;

  # initialize the list of gap class representatives to be built up
  reps := [];

  # now loop over the coset table and pick up the class representatives
  cos := ctSheet!.firstDef;
  while cos <> 0 do
    for gen in [ 1 .. ncols ] do
      entry := table[gen][cos];
      if entry < - null then
        # add a new class to the list
        Add( reps, [ entry + null, cos, gen ] );
      fi;
      # skip the inverse column of an involutory generator
      if involutory[gen] = 2 then
        gen := gen + 1;
      fi;
    od;
    cos := next[cos];
  od;

  # sort the classes by decreasing length
  if reps <> [] then
    Sort( reps );
    for rep in reps do
      rep[1] := - rep[1];
    od;
  fi;

  # save the resulting list of classes, and return it
  length := Length( reps );
  classes := ListWithIdenticalEntries( length, 0 );
  gapSheet := 0;
  classSheets := ListWithIdenticalEntries( length, 0 );
  gaps := [ reps, classes, gapSheet, classSheets ];
  ctSheet!.gaps := gaps;
  return gaps;

end );


#############################################################################
#
# ItcHandlePendingDeductions( <ctSheet> )
#
# handles the pending deductions.
#
InstallGlobalFunction( ItcHandlePendingDeductions, function( ctSheet )

    local c1, c2, coincs, cos, cos0, deducs, gen, firstDef, firstFree, i,
          i0, involutory, j, j1, j2, JoinClasses, lastDef, lastFree, lc,
          lengthTable, lp, next, null, nums, prev, rc, rel, rels, relsGen,
          rep, rp, subgrp, table;

#============================================================================
#
# JoinClasses( <i1>, <cos1>, <i2>, <cos2> );
#
# This is a GAP version of the (not yet existing) kernel routine JoinClasses.
# It joins the  classes  of gaps of length 1  represented  by the coset table
# entries  table[i][cos1]  and  table[i][cos2]   and  determins  the  positon
# table[i0][cos0] of the common representative rep.
#
JoinClasses := function( i1, cos1, i2, cos2 )

    local cos3, cos4, i3, i4, pos3, pos4, rep3, rep4;

    # get the class rep of gen[cos1];
    i3 := i1;
    cos3 := cos1;
    rep3 := -table[i3][cos3];
    while 0 < rep3 and rep3 < null do
      i3 := ( rep3 - 1 ) mod lengthTable + 1;
      cos3 := ( rep3 - i3 ) / lengthTable + 1;
      rep3 := -table[i3][cos3];
    od;

    # get the class rep of gen[cos2];
    i4 := i2;
    cos4 := cos2;
    rep4 := -table[i4][cos4];
    while 0 < rep4 and rep4 < null do
      i4 := ( rep4 - 1 ) mod lengthTable + 1;
      cos4 := ( rep4 - i4 ) / lengthTable + 1;
      rep4 := -table[i4][cos4];
    od;

    # get the common class representative rep
    if rep3 > null and rep4 > null then
      pos3 := ( cos3 - 1 ) * lengthTable + i3;
      pos4 := ( cos4 - 1 ) * lengthTable + i4;
      if pos3 < pos4 then
        table[i4][cos4] := -pos3;
        i0 := i3;
        cos0 := cos3;
        rep := rep3 + rep4 - null;
        table[i0][cos0] := -rep;
      elif pos4 < pos3 then
        table[i3][cos3] := -pos4;
        i0 := i4;
        cos0 := cos4;
        rep := rep3 + rep4 - null;
        table[i0][cos0] := -rep;
      else
        i0 := i3;
        cos0 := cos3;
        rep := rep3;
      fi;
    else
      table[i1][cos1] := 0;
      table[i2][cos2] := 0;
      if table[i3][cos3] < 0 then
        table[i3][cos3] := 0;
      fi;
      if table[i4][cos4] < 0 then
        table[i4][cos4] := 0;
      fi;
      rep := 0;
    fi;

end;

#============================================================================

    # get some local variables
    table := ctSheet!.table;
    next := ctSheet!.next;
    prev := ctSheet!.prev;
    involutory := ctSheet!.involutory;
    relsGen := ctSheet!.relsGen;
    subgrp := ctSheet!.subgrp;
    firstFree := ctSheet!.firstFree;
    lastFree := ctSheet!.lastFree;
    firstDef := ctSheet!.firstDef;
    lastDef := ctSheet!.lastDef;
    coincs := ctSheet!.coincs;
    deducs := ctSheet!.deducs;
    lengthTable := Length( table );
    null := lengthTable * Length( table[1] );

    # while the deduction queue has not been worked off
    j := 0;
    while j < Length( deducs ) do
      j := j + 1;
      cos := deducs[j][1];
      gen := deducs[j][2];

      # skip the deduction, if it got irrelevant by a coincidence
      if table[gen][cos] > 0 or cos = 1 then

        # while there are still subgroup generators apply them
        i := Length( subgrp );
        while 0 < i do
          if IsBound( subgrp[i] ) then
            nums := subgrp[i][1];
            rel  := subgrp[i][2];

            lp := 2;
            lc := 1;
            rp := Length( rel ) - 1;
            rc := 1;

            # scan as long as possible from the right to the left
            while lp < rp and 0 < rel[rp][rc] do
                rc := rel[rp][rc];  rp := rp - 2;
            od;

            # scan as long as possible from the left to the right
            while lp < rp and 0 < rel[lp][lc] do
                lc := rel[lp][lc];  lp := lp + 2;
            od;

            # if a coincidence or deduction has been found, handle it
            if lp = rp + 1 then
              if rel[lp][lc] <> rc then
                if rel[lp][lc] > 0 then
                  if rel[lp][lc] > rc then
                    AddSet( coincs, [ rel[lp][lc], rc ] );
                  else
                    AddSet( coincs, [ rc, rel[lp][lc] ] );
                  fi;
                elif rel[rp][rc] > 0 then
                  if rel[rp][rc] > lc then
                    AddSet( coincs, [ rel[rp][rc], lc ] );
                  else
                    AddSet( coincs, [ lc, rel[rp][rc] ] );
                  fi;
                else
                    rel[lp][lc] := rc;
                    rel[rp][rc] := lc;
                    Add( deducs, [ lc, nums[lp] ] );
                fi;
              fi;

              # remove the completed subgroup generator
              if coincs = [] then
                Unbind( subgrp[i] );
              fi;

            # if a minimal gap has been found, handle it
            elif lp = rp - 1 then
              j1 := nums[lp];
              if involutory[j1] = 2 and j1 mod 2 = 0 then
                j1 := j1 - 1;
              fi;
              c1 := table[j1][lc];
              if c1 = 0 then
                # make table[j1][lc] the representative of a new class of
                # gaps
                table[j1][lc] := - ( null + involutory[j1] );
              fi;
              j2 := nums[rp];
              if involutory[j2] = 2 and j2 mod 2 = 0 then
                j2 := j2 - 1;
              fi;
              c2 := table[j2][rc];
              if c2 = 0 then
                # make table[j2][rc] the representative of a new class of
                # gaps
                table[j2][rc] := - ( null + involutory[j2] );
              fi;
              # join the classes
              JoinClasses( j1, lc, j2, rc );
            fi;
          fi;

          i := i - 1;
        od;

        # apply all relators that start with this generator
        rels := relsGen[gen];
        for i in [ 1 .. Length( rels ) ] do
            nums := rels[i][1];
            rel  := rels[i][2];

            lp := rels[i][3];
            lc := cos;
            rp := lp + rel[1];
            rc := lc;

            # scan as long as possible from the right to the left
            while lp < rp and 0 < rel[rp][rc] do
                rc := rel[rp][rc];  rp := rp - 2;
            od;

            # scan as long as possible from the left to the right
            while lp < rp and 0 < rel[lp][lc] do
                lc := rel[lp][lc];  lp := lp + 2;
            od;

            # if a coincidence or deduction has been found, handle it
            if lp = rp + 1 and rel[lp][lc] <> rc then
                if rel[lp][lc] > 0 then
                  if rel[lp][lc] > rc then
                    AddSet( coincs, [ rel[lp][lc], rc ] );
                  else
                    AddSet( coincs, [ rc, rel[lp][lc] ] );
                  fi;
                elif rel[rp][rc] > 0 then
                  if rel[rp][rc] > lc then
                    AddSet( coincs, [ rel[rp][rc], lc ] );
                  else
                    AddSet( coincs, [ lc, rel[rp][rc] ] );
                  fi;
                else
                    rel[lp][lc] := rc;
                    rel[rp][rc] := lc;
                    Add( deducs, [ lc, nums[lp] ] );
                fi;

            # if a minimal gap has been found, handle it
            elif lp = rp - 1 then
              j1 := nums[lp];
              if involutory[j1] = 2 and j1 mod 2 = 0 then
                j1 := j1 - 1;
              fi;
              c1 := table[j1][lc];
              if c1 = 0 then
                # make table[j1][lc] the representative of a new class of
                # gaps
                table[j1][lc] := - ( null + involutory[j1] );
              fi;
              j2 := nums[rp];
              if involutory[j2] = 2 and j2 mod 2 = 0 then
                j2 := j2 - 1;
              fi;
              c2 := table[j2][rc];
              if c2 = 0 then
                # make table[j2][rc] the representative of a new class of
                # gaps
                table[j2][rc] := - ( null + involutory[j2] );
              fi;
              # join the classes
              JoinClasses( j1, lc, j2, rc );
            fi;
        od;

      fi;
    od;

    ctSheet!.coincs := coincs;
    ctSheet!.deducs := deducs;

    ctSheet!.firstFree := firstFree;
    ctSheet!.lastFree := lastFree;
    ctSheet!.firstDef := firstDef;
    ctSheet!.lastDef := lastDef;

    ItcUpdateFirstDef( ctSheet );

end );


#############################################################################
#
# ItcInitializeInfoLine( <ctSheet>, <heightCosetTable> )
#
# initialize  the message line  and the info line  in the window 'Interactive
# Todd-Coxeter'.
#
InstallGlobalFunction( ItcInitializeInfoLine,
  function( ctSheet, heightCosetTable )

  local charWidth, distance, gap, infoLine, lineHeight, red, x, y;

  # get some local variables
  distance := ctSheet!.normal.distance;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;
  gap := ctSheet!.normal.gap;
  red := rec( color := COLORS.red );

  # initialize the message line
  x := gap;
  y := heightCosetTable + lineHeight;
  ctSheet!.messageText := Text( ctSheet, FONTS.normal, x, y, "", red );
  ctSheet!.message := false;

  # initialize the info line
  y := y + 2 * distance;
  Line( ctSheet, 0, y, ctSheet!.width, 0 );
  infoLine := [];
  infoLine[1] := 3;
  infoLine[2] := 0;
  x := gap;
  y := y + lineHeight;
  infoLine[3] := Text( ctSheet, FONTS.normal, x, y,
    "Defined:       Deleted:       Alive:" );
  infoLine[4] := Text( ctSheet, FONTS.normal, x, y,
    "         1              0            1" );
  infoLine[5] := Text( ctSheet, FONTS.normal, x, y, "", red );
  infoLine[6] := Text( ctSheet, FONTS.normal, x, y, "", red );
  ctSheet!.infoLine := infoLine;
  y := y + 2 * distance;
  Line( ctSheet, 0, y, ctSheet!.width, 0 );

end );


#############################################################################
#
# ItcInitializeParameters( <ctSheet> )
#
# initializes the parameters for the coset enumeration.
#
InstallGlobalFunction( ItcInitializeParameters, function( ctSheet )

  local anz, app, app1, cols, fgens, firstDef, firstFree, found, fsgens, g,
        gen, i, inv, involutory, j, lastDef, lastFree, length, length2,
        limit, ncols, next, nrdel, nums, p, p1, p2, prev, rel, rels, relsGen,
        settingsSheet, string, subgrp, table, triple;

  # get the arguments
  fgens := ctSheet!.fgens;
  ncols := ctSheet!.ncols;
  rels := ctSheet!.rels;
  fsgens := ctSheet!.fsgens;
  limit := ctSheet!.limit;

  # set up the parameters for the coset enumeration
  nrdel := 0;

  # define one coset (1)
  firstDef  := 1;  lastDef  := 1;
  firstFree := 2;  lastFree := limit;

  # make the lists that link together all the cosets
  next := [ 2 .. limit + 1 ];
  prev := [ 0 .. limit - 1 ];
  next[1] := 0;
  next[limit] := 0;
  prev[2] := 0;

  # make the columns for the generators
  table := [];
  involutory := [];
  for gen in fgens do
    g := ListWithIdenticalEntries( limit, 0 );
    inv := 2;
    Add( table, g );
    if not ( gen^2 in rels or gen^-2 in rels ) then
      g := ListWithIdenticalEntries( limit, 0 );
      inv := 1;
    fi;
    Add( table, g );
    Add( involutory, inv );
    Add( involutory, inv );
  od;

  # make the rows for the relators and distribute over relsGen
  relsGen := RelsSortedByStartGen( fgens, rels, table );

  # make the rows for the subgroup generators
  subgrp := [];
  for rel  in fsgens  do
    length := Length( rel );
    length2 := 2 * length;
    nums := [ ]; nums[length2] := 0;
    cols := [ ]; cols[length2] := 0;

    # compute the lists.
    i := 0;  j := 0;
    while i < length do
      i := i + 1;  j := j + 2;
      gen := Subword( rel, i, i );
      p := Position( fgens, gen );
      if p = fail then
        p := Position( fgens, gen^-1 );
        p1 := 2 * p;
        p2 := 2 * p - 1;
      else
        p1 := 2 * p - 1;
        p2 := 2 * p;
      fi;
      nums[j]   := p1;  cols[j]   := table[p1];
      nums[j-1] := p2;  cols[j-1] := table[p2];
    od;
    Add( subgrp, [ nums, cols ] );
  od;

  # make the structure that is passed to 'MakeConsequences'
  app := [ table, next, prev, relsGen, subgrp ];
  # we want gaps of length 1 to be marked in the coset table
  app[12] := involutory;

  # make the structure that is passed to 'ApplyRel'
  app1 := [];

  # fill the associated entries in the first row of the coset table
  for i in [ 1 .. ncols ] do
    if table[i][1] <= 0 then
      app[6] := firstFree;
      app[7] := lastFree;
      app[8] := firstDef;
      app[9] := lastDef;
      app[10] := i;
      app[11] := 1;
      nrdel := nrdel + ItcMakeConsequences( app );
      if app[7] <> lastFree then
        Error( "THIS IS A BUG (ITC 08), YOU SHOULD NEVER GET HERE" );
      fi;
      firstDef := app[8];
      lastDef := app[9];
    fi;
  od;

  # save the table
  ctSheet!.table := table;
  ctSheet!.next := next;
  ctSheet!.prev := prev;
  ctSheet!.subgrp := subgrp;
  ctSheet!.relsGen := relsGen;
  ctSheet!.involutory := involutory;
  ctSheet!.app := app;
  ctSheet!.app1 := app1;
  ctSheet!.firstFree := firstFree;
  ctSheet!.lastFree := lastFree;
  ctSheet!.firstDef := firstDef;
  ctSheet!.lastDef := lastDef;
  ctSheet!.nrdel := nrdel;
  ctSheet!.first := 1;
  ctSheet!.ndefs := 1;
  ctSheet!.gaps := 0;
  ctSheet!.shortCut := 0;

  ItcExtractTable( ctSheet );
  ItcUpdateFirstDef( ctSheet );

  # update the sheet of current settings
  if IsBound( ctSheet!.settingsSheet ) and IsAlive( ctSheet!.settingsSheet )
    then
    settingsSheet := ctSheet!.settingsSheet;
    FastUpdate( ctSheet, true );
    string := Concatenation( "table size ", String( limit ) );
    Relabel( settingsSheet!.boxes[2], string );
    FastUpdate( ctSheet, false );
  fi;

end );


#############################################################################
#
# ItcIsAliveCoset( <ctSheet>, <coset> )
#
# returns 'true' if the given coset number is alive or 'false' else.
#
InstallGlobalFunction( ItcIsAliveCoset, function( ctSheet, coset )

  local alive, def, defs, gen, inv, ndefs, table;

  # get some local variables
  table := ctSheet!.table;
  defs := ctSheet!.defs;
  ndefs := ctSheet!.ndefs;

  # scan as long as possible from the left to the right
  if coset = 1 then
    alive := true;
  elif 1 < coset and coset <= ndefs then
    def := defs[coset-1];
    if def[3] <> coset then
      Error( "THIS IS A BUG (ITC 09), YOU SHOULD NEVER GET HERE" );
    fi;
    gen := def[2];
    inv := gen + 1 - 2 * ( ( gen + 1 ) mod 2 );
    alive := table[inv][coset] > 0;
  else
    alive := false;
  fi;

  return alive;
end );


#############################################################################
#
# ItcIsClosedRow( <ctSheet>, <coset>, <columns> )
#
# traces the given coset  through the given word  and returns  'true'  if the
# trace closes, or 'false' otherwise.
#
InstallGlobalFunction( ItcIsClosedRow, function( ctSheet, coset, columns )

  local closed, cos, gen, i, length, table;

  # get some local variables
  table := ctSheet!.table;
  length := Length( columns );

  # scan as long as possible from the left to the right
  cos := coset;
  i := 0;

  while i < length and cos > 0 do
    i := i + 1;
    gen := columns[i];
    cos := table[gen][cos];
  od;

  closed := cos > 0;
  return closed;
end );


#############################################################################
#
# ItcListColumnNumbers( <ctSheet>, <word> )
#
# returns a list of the numbers of the coset table columns associated to the
# factors of the given word.
#
InstallGlobalFunction( ItcListColumnNumbers, function( ctSheet, word )

    local gen, fgens, i, length, num, nums;

    # get some local variables
    fgens := ctSheet!.fgens;
    length := Length( word);

    # construct the list
    nums := ListWithIdenticalEntries( length, 0 );
    for i in [ 1 .. length ] do
      gen := Subword( word, i, i );
      if gen in fgens then
        num := 2 * Position( fgens, gen ) - 1;
      else
        num := 2 * Position( fgens, gen^-1 );
      fi;
      nums[i] := num;
    od;
    return nums;
end );


#############################################################################
#
# ItcMakeConsequences( <app> )
#
# This is a GAP version of the kernel routine MakeConsequences.
#
# Note that, for the purposes of function ItcInitializeParameters, the GAP
# version differs in one statement from the C-version. The related statement
# is marked in the code below.
#
ItcDedSize := 4096;
ItcDedgen := ListWithIdenticalEntries( ItcDedSize, 0 );
ItcDedcos := ListWithIdenticalEntries( ItcDedSize, 0 );

InstallGlobalFunction( ItcMakeConsequences, function( app )

    local CompressDeductionList, c1, c2, cos, cos0, dedcos, dedfst, dedgen,
          dedlst, dedprint, dedSize, gen, firstDef, firstFree, HandleCoinc,
          i, i0, involutory, j, j1, j2, JoinClasses, lastDef, lastFree, lc,
          lengthTable, lp, minGaps, next, nrdel, null, nums, prev, rc, rel,
          rels, relsGen, rep, rp, subs, table;

#============================================================================
#
# JoinClasses( <i1>, <cos1>, <i2>, <cos2> );
#
# This is a GAP version of the (not yet existing) kernel routine JoinClasses.
# It joins the  classes  of gaps of length 1  represented  by the coset table
# entries  table[i][cos1]  and  table[i][cos2]   and  determins  the  positon
# table[i0][cos0] of the common representative rep.
#
JoinClasses := function( i1, cos1, i2, cos2 )

    local cos3, cos4, i3, i4, pos3, pos4, rep3, rep4;

    # get the class rep of gen[cos1];
    i3 := i1;
    cos3 := cos1;
    rep3 := -table[i3][cos3];
    while 0 < rep3 and rep3 < null do
      i3 := ( rep3 - 1 ) mod lengthTable + 1;
      cos3 := ( rep3 - i3 ) / lengthTable + 1;
      rep3 := -table[i3][cos3];
    od;

    # get the class rep of gen[cos2];
    i4 := i2;
    cos4 := cos2;
    rep4 := -table[i4][cos4];
    while 0 < rep4 and rep4 < null do
      i4 := ( rep4 - 1 ) mod lengthTable + 1;
      cos4 := ( rep4 - i4 ) / lengthTable + 1;
      rep4 := -table[i4][cos4];
    od;

    # get the common class representative rep
    if rep3 > null and rep4 > null then
      pos3 := ( cos3 - 1 ) * lengthTable + i3;
      pos4 := ( cos4 - 1 ) * lengthTable + i4;
      if pos3 < pos4 then
        table[i4][cos4] := -pos3;
        i0 := i3;
        cos0 := cos3;
        rep := rep3 + rep4 - null;
        table[i0][cos0] := -rep;
      elif pos4 < pos3 then
        table[i3][cos3] := -pos4;
        i0 := i4;
        cos0 := cos4;
        rep := rep3 + rep4 - null;
        table[i0][cos0] := -rep;
      else
        i0 := i3;
        cos0 := cos3;
        rep := rep3;
      fi;
    else
      table[i1][cos1] := 0;
      table[i2][cos2] := 0;
      if table[i3][cos3] < 0 then
        table[i3][cos3] := 0;
      fi;
      if table[i4][cos4] < 0 then
        table[i4][cos4] := 0;
      fi;
      rep := 0;
    fi;

end;

#============================================================================
#
# CompressDeductionList( )
#
# This is a GAP version of the kernel routine CompressDeductionList.
#
CompressDeductionList := function( )

    local i, j;

    # run through the lists and compress them
    j := 1;
    for i in [ dedfst .. dedlst ] do
        if table[dedgen[i]][dedcos[i]] > 0
          and j < i then
            dedgen[j] := dedgen[i];
            dedcos[j] := dedcos[i];
            j := j + 1;
        fi;
    od;

    # update the pointers
    dedfst := 1;
    dedlst := j - 1;

    # check if we have at least one free position
    if dedlst = dedSize then
        if dedprint = 0 then
            Print( "#I  WARNING: deductions being discarded\n" );
            dedprint := 1;
        fi;
        dedlst := dedlst - 1;
    fi;
end;

#============================================================================
#
# HandleCoinc( <cos1>, <cos2> )
#
# This is a GAP version of the kernel routine HandleCoinc.
#
HandleCoinc := function( cos1, cos2 )

    local c1, c2, c3, firstCoinc, gen, i, inv, lastCoinc;

    # take the smaller one as new representative
    if cos2 < cos1 then c3 := cos1;  cos1 := cos2;  cos2 := c3;  fi;

    # if we are removing an important coset update it
    if cos2 = lastDef then
        lastDef := prev[lastDef];
    fi;
    if cos2 = firstDef then
        firstDef := prev[firstDef];
    fi;

    # remove <cos2> from the coset list
    next[prev[cos2]] := next[cos2];
    if next[cos2] <> 0 then
        prev[next[cos2]] := prev[cos2];
    fi;

    # put the first coincidence into the list of coincidences
    firstCoinc := cos2;
    lastCoinc := cos2;
    next[lastCoinc] := 0;

    # <cos1> is the representative of <cos2> and its own representative
    prev[cos2] := cos1;

    # while there are coincidences to handle
    while firstCoinc <> 0 do

        # replace <firstCoinc> by its representative in the table
        cos1 := prev[firstCoinc];  cos2 := firstCoinc;
        for i in [ 1 .. lengthTable ] do
            gen := table[i];
            inv := table[i + 2*(i mod 2) - 1];

            # replace <cos2> by <cos1> in the column of <gen>^-1
            c2 := gen[cos2];
            if c2 > 0 then
                c1 := gen[cos1];

                # if the other entry is empty copy it
                if c1 <= 0 then
                    gen[cos1] := c2;
                    gen[cos2] := 0;
                    inv[c2]   := cos1;
                    if dedlst = dedSize then
                        CompressDeductionList( );
                    fi;
                    dedlst := dedlst + 1;
                    dedgen[dedlst] := i;
                    dedcos[dedlst] := cos1;

                # otherwise check for a coincidence
                else
                    inv[c2]   := 0;
                    gen[cos2] := 0;
                    if gen[cos1] <= 0 then
                        gen[cos1] := cos1;
                        if dedlst = dedSize then
                            CompressDeductionList( );
                        fi;
                        dedlst := dedlst + 1;
                        dedgen[dedlst] := i;
                        dedcos[dedlst] := cos1;
                    fi;

                    # find the representative of <c1>
                    while c1 <> 1 and next[prev[c1]] <> c1 do
                        c1 := prev[c1];
                    od;

                    # find the representative of <c2>
                    while c2 <> 1 and next[prev[c2]] <> c2 do
                        c2 := prev[c2];
                    od;

                    # if the representatives differ we got a coincindence
                    if c1 <> c2 then

                        # take the smaller one as new representative
                        if c2 < c1 then  c3 := c1;  c1 := c2;  c2 := c3; fi;

                        # if we are removing an important coset update it
                        if c2 = lastDef then
                            lastDef := prev[lastDef];
                        fi;
                        if c2 = firstDef then
                            firstDef := prev[firstDef];
                        fi;

                        # remove <c2> from the coset list
                        next[prev[c2]] := next[c2];
                        if next[c2] <> 0 then
                            prev[next[c2]] := prev[c2];
                        fi;

                        # append <c2> to the coincidence list
                        next[lastCoinc] := c2;
                        lastCoinc       := c2;
                        next[lastCoinc] := 0;

                        # <c1> is the rep of <c2> and its own rep.
                        prev[c2] := c1;

                    fi;
                fi;

            # handle minimal gaps
            elif minGaps and c2 < 0 then
              c1 := gen[cos1];
              if c1 > 0 then
                # the class will vanish by further coincidences, so replace
                # the current entry c2 by zero
                gen[cos2] := 0;
              elif c1 < 0 then
                # there are two classes, join them and decrease the number
                JoinClasses( i, cos1, i, cos2 );
                if rep > null then
                  table[i0][cos0] := 1 - rep;
                fi;
              elif c1 = 0 then
                # make gen[cos1] the representative of a new class of gaps
                c1 := - ( null + involutory[i] );
                gen[cos1] := c1;
                # now join the classes and decrease the number
                JoinClasses( i, cos1, i, cos2 );
                if rep > null then
                  table[i0][cos0] := 1 - rep;
                fi;
              fi;

            fi;
        od;

        # move the replaced coset to the free list
        if firstFree = 0 then
            firstFree      := firstCoinc;
            lastFree       := firstCoinc;
        else
            next[lastFree] := firstCoinc;
            lastFree       := firstCoinc;
        fi;
        firstCoinc := next[firstCoinc];
        next[lastFree] := 0;

        nrdel := nrdel + 1;
    od;
end;

#============================================================================

    # get the arguments
    table := app[1];
    next := app[2];
    prev := app[3];
    relsGen := app[4];
    subs := app[5];
    firstFree := app[6];
    lastFree := app[7];
    firstDef := app[8];
    lastDef := app[9];
    gen := app[10];
    cos := app[11];
    involutory := app[12];
    dedgen := ItcDedgen;
    dedcos := ItcDedcos;
    dedSize := ItcDedSize;

    # get some local variables
    lengthTable := Length( table );
    minGaps := involutory <> 0;
    if minGaps then
      null := lengthTable * Length( table[1] );
    fi;

    # initialize the number of deleted cosets
    nrdel := 0;

    # initialize the deduction queue
    dedprint := 0;
    dedfst := 1;
    dedlst := 1;
    dedgen[1] := gen;
    dedcos[1] := cos;

    # while the deduction queue is not empty
    while dedfst <= dedlst do

      # skip the deduction, if it got irrelevant by a coincidence
      if table[dedgen[dedfst]][dedcos[dedfst]] > 0
        or minGaps and dedcos[dedfst] = 1 then

        # while there are still subgroup generators apply them
        i := Length( subs );
        while 0 < i do
          if IsBound( subs[i] ) then
            nums := subs[i][1];
            rel  := subs[i][2];

            lp := 2;
            lc := 1;
            rp := Length( rel ) - 1;
            rc := 1;

            # scan as long as possible from the right to the left
            while lp < rp and 0 < rel[rp][rc] do
                rc := rel[rp][rc];  rp := rp - 2;
            od;

            # scan as long as possible from the left to the right
            while lp < rp and 0 < rel[lp][lc] do
                lc := rel[lp][lc];  lp := lp + 2;
            od;

            # if a coincidence or deduction has been found, handle it
            if lp = rp + 1 then
              if rel[lp][lc] <> rc then
                if rel[lp][lc] > 0 then
                    HandleCoinc( rel[lp][lc], rc );
                elif rel[rp][rc] > 0 then
                    HandleCoinc( rel[rp][rc], lc );
                else
                    rel[lp][lc] := rc;
                    rel[rp][rc] := lc;
                    if dedlst = dedSize then
                        CompressDeductionList( );
                    fi;
                    dedlst := dedlst + 1;
                    dedgen[dedlst] := nums[lp];
                    dedcos[dedlst] := lc;
                fi;
              fi;

              # remove the completed subgroup generator
              Unbind( subs[i] );

            # if a minimal gap has been found, handle it
            elif minGaps and lp = rp - 1 then
              j1 := nums[lp];
              if involutory[j1] = 2 and j1 mod 2 = 0 then
                j1 := j1 - 1;
              fi;
              c1 := table[j1][lc];
              if c1 = 0 then
                # make table[j1][lc] the representative of a new class of
                # gaps
                table[j1][lc] := - ( null + involutory[j1] );
              fi;
              j2 := nums[rp];
              if involutory[j2] = 2 and j2 mod 2 = 0 then
                j2 := j2 - 1;
              fi;
              c2 := table[j2][rc];
              if c2 = 0 then
                # make table[j2][rc] the representative of a new class of
                # gaps
                table[j2][rc] := - ( null + involutory[j2] );
              fi;
              # join the classes
              JoinClasses( j1, lc, j2, rc );
            fi;
          fi;

          i := i - 1;
        od;

        # apply all relators that start with this generator
        rels := relsGen[dedgen[dedfst]];
        for i in [ 1 .. Length( rels ) ] do
            nums := rels[i][1];
            rel  := rels[i][2];

            lp := rels[i][3];
            lc := dedcos[dedfst];
            rp := lp + rel[1];
            rc := lc;

            # scan as long as possible from the right to the left
            while lp < rp and 0 < rel[rp][rc] do
                rc := rel[rp][rc];  rp := rp - 2;
            od;

            # scan as long as possible from the left to the right
            while lp < rp and 0 < rel[lp][lc] do
                lc := rel[lp][lc];  lp := lp + 2;
            od;

            # if a coincidence or deduction has been found, handle it
            if lp = rp + 1 and rel[lp][lc] <> rc then
                if rel[lp][lc] > 0 then
                    HandleCoinc( rel[lp][lc], rc );
                elif rel[rp][rc] > 0 then
                    HandleCoinc( rel[rp][rc], lc );
                else
                    rel[lp][lc] := rc;
                    rel[rp][rc] := lc;
                    if dedlst = dedSize then
                        CompressDeductionList( );
                    fi;
                    dedlst := dedlst + 1;
                    dedgen[dedlst] := nums[lp];
                    dedcos[dedlst] := lc;
                fi;

            # if a minimal gap has been found, handle it
            elif minGaps and lp = rp - 1 then
              j1 := nums[lp];
              if involutory[j1] = 2 and j1 mod 2 = 0 then
                j1 := j1 - 1;
              fi;
              c1 := table[j1][lc];
              if c1 = 0 then
                # make table[j1][lc] the representative of a new class of
                # gaps
                table[j1][lc] := - ( null + involutory[j1] );
              fi;
              j2 := nums[rp];
              if involutory[j2] = 2 and j2 mod 2 = 0 then
                j2 := j2 - 1;
              fi;
              c2 := table[j2][rc];
              if c2 = 0 then
                # make table[j2][rc] the representative of a new class of
                # gaps
                table[j2][rc] := - ( null + involutory[j2] );
              fi;
              # join the classes
              JoinClasses( j1, lc, j2, rc );
            fi;
        od;

      fi;
      dedfst := dedfst + 1;

    od;

    app[6] := firstFree;
    app[7] := lastFree;
    app[8] := firstDef;
    app[9] := lastDef;

    return nrdel;
end );


#############################################################################
#
# ItcMakeDigitStrings( <ctSheet> )
#
# constructs the strings for displaying coset numbers.
#
InstallGlobalFunction( ItcMakeDigitStrings, function( ctSheet )

  local digits, digitString1, digitString2, i, limit;

  # get some local variables
  digits := ctSheet!.digits;
  limit := ctSheet!.limit;

  # construct the strings needed to display a relation or subgroup table
  digitString1 := List( [ 1 .. limit + 1 ], i -> String( i - 1, digits ) );
  digitString1[1] := String( " ", digits );

  # construct the strings needed to display the coset table
  digitString2 := List( [ 1 .. limit + 2 ], i -> String( i - 2, digits + 2 )
    );
  digitString2[1] := String( ".", digits + 2 );
  digitString2[2] := String( " ", digits + 2 );

  # save the lists
  ctSheet!.digitString1 := digitString1;
  ctSheet!.digitString2 := digitString2;

end );


#############################################################################
#
# ItcMakeMenu( <ctSheet> )
#
# defines the menus for a coset table sheet.
#
InstallGlobalFunction( ItcMakeMenu, function( ctSheet )

  # define the menu ctSheet!.menus[2]
  Menu( ctSheet, "Settings",
    [ "change default table size",
      "extend table size",
      "coincidence handling off",
      "coincidence handling on",
      "echo on",
      "echo off",
      "gaps strategy 1 (first gap)",
      "gaps strategy 2 (first rep of max weight)",
      "gaps strategy 3 (last rep of max weight)",
      "show current settings" ],
    [ ItcChangeDefaultTableSize,
      ItcExtendTableSize,
      ItcChangeSettings,
      ItcChangeSettings,
      ItcChangeSettings,
      ItcChangeSettings,
      ItcChangeSettings,
      ItcChangeSettings,
      ItcChangeSettings,
      ItcShowSettings ] );

  # define the menu ctSheet!.menus[3]
  Menu( ctSheet, "Close",
    [ "close table by Felsch",
      "use gaps strategy 1 (first gap)",
      "use gaps strategy 2 (first rep of max weight)",
      "use gaps strategy 3 (last rep of max weight)",
      "close table by HLT with consequences" ],
    [ ItcCloseTableFelsch,
      ItcCloseTableGaps,
      ItcCloseTableGaps,
      ItcCloseTableGaps,
      ItcCloseTableHLT ] );

  # define the menu ctSheet!.menus[4]
  Menu( ctSheet, "File",
    [ "read definitions from file",
      "write definitions to file",
      "write standardized table to file" ],
    [ ItcReadDefinitions,
      ItcWriteDefinitions,
      ItcWriteStandardizedTable ] );

end );


#############################################################################
#
# ItcMarkCosets( <ctSheet>, <menu>, <entry> )
#
# is called by selecting the menu entry 'mark cosets'.
#
InstallGlobalFunction( ItcMarkCosets, function( ctSheet, menu, entry )

  local i, marked, num, query;

  # select the numbers of the cosets to be marked
  query := Query( Dialog( "OKcancel", "cosets ?" ) );

  # echo the command
  if ctSheet!.echo then
    Print( ">> MARK COSETS ", query, "\n" );
  fi;

  # return if the query has been canceled
  if query = false then
    return;
  fi;

  # evaluate the query string and check the arguments
  marked := ItcQuery( query );
  for num in marked do
    if not IsInt( num ) or num < 1 then
      Relabel( ctSheet!.messageText, "Illegal coset number" );
      ctSheet!.message := true;
      return;
    fi;
  od;
  marked := Set( marked );

  # there is nothing to do if the specified cosets are just those which have
  # already been marked
  if marked = ctSheet!.marked then
    return;
  fi;

  # otherwise recolor the current table entries
  ctSheet!.marked := marked;
  ItcRecolorTableEntries( ctSheet );

  ItcEnableMenu( ctSheet );
end );


#############################################################################
#
# ItcNumberClassOfGaps( <ctSheet>, <coset>, <gen> )
#
# determine  the number  of the equivalence class  of gaps of length 1  which
# contains the gap in the given coset table position [<coset>,<gen>].
#
InstallGlobalFunction( ItcNumberClassOfGaps, function( ctSheet, coset, gen )

  local cos, entry, gaps, n, ncols, null, rep, reps, table;

  # get some local variables
  table := ctSheet!.table;
  ncols := ctSheet!.ncols;
  null := ncols * Length( table[1] );

  # get the list of all classes of gaps of length 1
  gaps := ItcGaps( ctSheet );
  reps := gaps[1];

  # find the class representative of the given class
  entry := - table[gen][coset];
  while entry < null do
    if entry <= 0 then
      Error( "THIS IS A BUG (ITC 10), YOU SHOULD NEVER GET HERE" );
    fi;
    gen := ( entry - 1 ) mod ncols + 1;
    coset := ( entry - gen ) / ncols + 1;
    entry := - table[gen][coset];
  od;

  # find its position in the list of all class reps
  rep := [ entry - null, coset, gen ];
  n := Position( reps, rep );
  return n;

end );


#############################################################################
#
# ItcOpenClassSheet( <ctSheet>, <k> )
#
# opens a class sheet for the k-th class of gaps of length 1.
#
InstallGlobalFunction( ItcOpenClassSheet, function( ctSheet, k )

  local charWidth, class, classSheets, distance, gaps, height, i, length,
        lineHeight, n, name, names, pair, sheet, string, width, x, y;

  # get some local variables
  distance := ctSheet!.normal.distance;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;
  names := ctSheet!.genNames;
  gaps := ItcGaps( ctSheet );
  classSheets := gaps[4];
  class := ItcClassOfGaps( ctSheet, k );
  length := Length( class );
  name := Concatenation( "Class ", String( k ), " of gaps of length 1" );

  # open a new graphic sheet for the k-th class of gaps of length 1
  n := 10 + Length( String( class[length][1] ) ) +
    Maximum( List( names, x -> Length( x ) ) );
  width := Maximum( n * charWidth, WidthOfSheetName( name ) );
  height := 3 * distance + Length( class ) * lineHeight;
  sheet := GraphicSheet( name, width, height );
  SetFilterObj( sheet, IsItcClassSheet );

  # install callbacks for the pointer buttons
  InstallCallback( sheet, "LeftPBDown", ItcClassSheetLeftPBDown );

  sheet!.boxes := [];
  x := 2 * charWidth;
  for i in [ 1 .. length ] do
    y := i * lineHeight;
    pair := class[i];
    string := Concatenation( "[ ", String( pair[1] ), ", ",
      ctSheet!.genNames[pair[2]], " ]" );
    sheet!.boxes[i] := Text( sheet, FONTS.normal, x, y, string );
  od;
  sheet!.class := class;
  sheet!.ctSheet := ctSheet;
  classSheets[k] := sheet;

end );


#############################################################################
#
# ItcQuery( <query> )
#
# evaluates  the  given  query  reply  and  returns it  in form of a list  of
# integers or strings.
#
InstallGlobalFunction( ItcQuery, function( query )

  local char, i, i1, isInteger, item, items, length;

  length := Length( query );
  items := [];
  i := 0;
  while i < length do
    i := i + 1;
    char := query[i];
    if char <> ',' and char <> ' ' then
      i1 := i;
      isInteger := IsDigitChar( char ) or char = '-';
      while i < length and query[i+1] <> ',' and query[i+1] <> ' ' do
        i := i + 1;
        isInteger := isInteger and IsDigitChar( query[i] );
      od;
      item := query{ [ i1 .. i ] };
      if isInteger then
        item := Int( item );
      fi;
      Add( items, item );
    fi;
  od;

  return items;
end );


#############################################################################
#
# ItcQuit( <ctSheet>, <menu>, <entry> )
#
# is called by selecting the menu entry 'quit coset enumeration' or by
# clicking on the button 'quit'.
#
InstallGlobalFunction( ItcQuit, function( ctSheet, menu, entry )

  local i, nrels, nsgens;

  # echo the command
  if ctSheet!.echo then
    Print( ">> QUIT\n" );
  fi;

  # get some local variables
  nrels := Length( ctSheet!.rels );
  nsgens := Length( ctSheet!.fsgens );

  # close the window 'settings'
  if IsBound( ctSheet!.settingsSheet ) and IsAlive( ctSheet!.settingsSheet )
    then
    Close( ctSheet!.settingsSheet );
  fi;

  # close the window 'Interactive Todd-Coxeter'
  Close( ctSheet );

  # close the window 'gaps of length 1'
  ItcCloseGapSheets( ctSheet );

  # close the window 'definitions'
  if IsBound( ctSheet!.defSheet ) and IsAlive( ctSheet!.defSheet ) then
    ItcCloseSheets( ctSheet!.repLists[2] );
    Close( ctSheet!.defSheet );
  fi;

  # close the window 'Relators'
  if IsBound( ctSheet!.relSheet ) and IsAlive( ctSheet!.relSheet ) then
    Close( ctSheet!.relSheet );

    # close all windows that contain relation tables
    for i in [ 1 .. nrels ] do
      if IsBound( ctSheet!.rtSheets[i] ) and
      IsAlive( ctSheet!.rtSheets[i] ) then
        Close( ctSheet!.rtSheets[i] );
      fi;
    od;
  fi;

  # close the window 'Subgroup gens'
  if IsBound( ctSheet!.subSheet ) and IsAlive( ctSheet!.subSheet ) then
    Close( ctSheet!.subSheet );

    # close all windows that contain subgroup tables
    for i in [ 1 .. nsgens ] do
      if IsBound( ctSheet!.stSheets[i] ) and
      IsAlive( ctSheet!.stSheets[i] ) then
        Close( ctSheet!.stSheets[i] );
      fi;
    od;
  fi;

  # close the window 'pending coincidenes'
  if IsBound( ctSheet!.coiSheet ) and IsAlive( ctSheet!.coiSheet ) then
    ItcCloseSheets( ctSheet!.coiSheet!.repSheets );
    Close( ctSheet!.coiSheet );
  fi;
end );


#############################################################################
#
# ItcReadDefinitions( <ctSheet>, <menu>, <entry> )
#
# reads a  list  of  coset  definitions  from a  file  and  reconstructs  the
# corresponding coset table.
#
InstallGlobalFunction( ItcReadDefinitions, function( ctSheet, menu, entry )

  local defs, filename;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  # get the filename
  filename := Query( Dialog( "Filename", "Choose a filename" ) );

  # echo the command
  if ctSheet!.echo then
    Print( ">> READ DEFINITIONS FROM FILE ", filename, "\n" );
  fi;

  if filename = "" or filename = false then
    return;
  fi;

  # read the file
  defs := ReadAsFunction( filename )();

  # reconstruct the table from the definitions.
  ItcReconstructTable( ctSheet, defs );

  # update all active relator tables and subgroup generator tables
  ItcUpdateDisplayedLists( ctSheet );

end );


#############################################################################
#
# ItcRecolorDefs( <ctSheet> )
#
# recolors definitions in the coset table.
#
InstallGlobalFunction( ItcRecolorDefs, function( ctSheet )

  local column, def, defs, graphicTable, length, line0, renumbered, row;

  # check if the definitions are to be marked
  if not ctSheet!.markDefs then
    return;
  fi;

  # get some local variables
  defs := ctSheet!.defs;
  graphicTable := ctSheet!.graphicTable;
  renumbered := ctSheet!.renumbered;
  line0 := renumbered[ctSheet!.first] - 1;
  length := Length( graphicTable );

  # recolor all definitions in the coset table
  for def in defs do
    if renumbered[def[3]] <> 0 then
      row := renumbered[def[1]] - line0;
      if 0 < row and row <= length then
        column := def[2];
        Recolor( graphicTable[row][column], COLORS.green );
      fi;
    fi;
  od;

end );


#############################################################################
#
# ItcRecolorPendingCosets( <ctSheet> )
#
# recolors  the rows  which  belong to  pending cosets  (i. e.,  which can be
# eliminated by working off a pending coincidence.
#
InstallGlobalFunction( ItcRecolorPendingCosets, function( ctSheet )

  local alives, coincs, cos, first, firstCol, graphicTable, i, j, length,
        line0, marked, nalive, newtab, nlines, pair, renumbered, row;

  # check if there are pending coincidences
  coincs := ctSheet!.coincs;
  if coincs = [] then
    return;
  fi;

  # get some local variables
  newtab := ctSheet!.newtab;
  marked := ctSheet!.marked;
  renumbered := ctSheet!.renumbered;
  alives := ctSheet!.alives;
  nalive := Length( alives );
  first := ctSheet!.first;
  nlines := ctSheet!.nlines;
  line0 := Minimum( renumbered[first], nalive ) - 1;
  firstCol := ctSheet!.firstCol;
  graphicTable := ctSheet!.graphicTable;
  length := Length( graphicTable[1] );

  # loop over the pending coincidences
  for pair in coincs do
    cos := pair[1];
    i := renumbered[cos] - line0;
    if 0 < i and i <= nlines then
      row := newtab[cos];
      Recolor( firstCol[i], COLORS.red );
      for j in [ 1 .. length ] do
        if row[j] in marked then
          Recolor( graphicTable[i][j], COLORS.green );
        else
          Recolor( graphicTable[i][j], COLORS.red );
        fi;
      od;
    fi;
  od;

end );


#############################################################################
#
# ItcRecolorTableEntries( <ctSheet> )
#
# recolors  the entries  in the  coset table,  the  subgroup tables,  and the
# relation tables.
#
InstallGlobalFunction( ItcRecolorTableEntries, function( ctSheet )

  local alives, coset, entry, fsgens, graphicTable, i, j, length, line0,
        marked, newtab, ncols, nlines, nrels, nsgens, oldrow, oldtab, rels,
        row, rtSheet, rtSheets, stSheet, stSheets;

  # get some local variables
  rels := ctSheet!.rels;
  fsgens := ctSheet!.fsgens;
  nrels := Length( rels );
  nsgens := Length( fsgens );
  alives := ctSheet!.alives;
  ncols := ctSheet!.ncols;
  nlines := ctSheet!.nlines;
  marked := ctSheet!.marked;
  rtSheets := ctSheet!.rtSheets;
  stSheets := ctSheet!.stSheets;
  line0 := ctSheet!.renumbered[ctSheet!.first] - 1;

  # recolor the entries in the coset table
  newtab := ctSheet!.newtab;
  oldtab := ctSheet!.oldtab;
  graphicTable := ctSheet!.graphicTable;
  FastUpdate( ctSheet, true );
  for i in [ 1 .. nlines ] do
    coset := alives[line0 + i];
    row := newtab[coset];
    oldrow := oldtab[coset];
    for j in [ 1 .. ncols ] do
      entry := row[j];
      if entry <> 0 then
        if entry > 0 and entry in marked then
          Recolor( graphicTable[i][j], COLORS.green );
        elif entry <> oldrow[j] then
          Recolor( graphicTable[i][j], COLORS.red );
        else
          Recolor( graphicTable[i][j], COLORS.black );
        fi;
      fi;
    od;
  od;
  FastUpdate( ctSheet, false );

  # recolor the coset table rows which belong to pending cosets
  ItcRecolorPendingCosets( ctSheet );
  # mark definitions in the coset table
  ItcRecolorDefs( ctSheet );

  # loop over all relation tables
  for i in [ 1 .. nrels ] do
    if IsBound( rtSheets[i] ) and IsAlive( rtSheets[i] ) then

      # recolor the entries in the relation table
      rtSheet := rtSheets[i];
      length := Length( rels[i] ) + 1;
      newtab := rtSheet!.newtab;
      oldtab := rtSheet!.oldtab;
      graphicTable := rtSheet!.graphicTable;
      FastUpdate( rtSheet, true );
      for i in [ 1 .. nlines ] do
        row := newtab[i];
        oldrow := oldtab[i];
        for j in [ 1 .. length ] do
          entry := row[j];
          if entry > 0 then
            if entry in marked then
              Recolor( graphicTable[i][j], COLORS.green );
            elif entry <> oldrow[j] then
              Recolor( graphicTable[i][j], COLORS.red );
            else
              Recolor( graphicTable[i][j], COLORS.black );
            fi;
          fi;
        od;
      od;
      FastUpdate( rtSheet, false );

    fi;
  od;

  # loop over all subgroup tables
  for i in [ 1 .. nsgens ] do
    if IsBound( stSheets[i] ) and IsAlive( stSheets[i] ) then

      # recolor the entries in the subgroup table
      stSheet := stSheets[i];
      length := Length( fsgens[i] ) + 1;
      newtab := stSheet!.newtab;
      oldtab := stSheet!.oldtab;
      graphicTable := stSheet!.graphicTable;
      FastUpdate( stSheet, true );
      row := newtab[1];
      oldrow := oldtab[1];
      for j in [ 1 .. length ] do
        entry := row[j];
        if entry > 0 then
          if entry in marked then
            Recolor( graphicTable[1][j], COLORS.green );
          elif entry <> oldrow[j] then
            Recolor( graphicTable[1][j], COLORS.red );
          else
            Recolor( graphicTable[1][j], COLORS.black );
          fi;
        fi;
      od;
      FastUpdate( stSheet, false );

    fi;
  od;

end );


#############################################################################
#
# ItcReconstructTable( <ctSheet>, <defs> )
#
# is called by selecting the menu entry 'load definition'.
#
InstallGlobalFunction( ItcReconstructTable, function( ctSheet, defs )

  local closed, coincSwitch, def, i, j, n, nalive, ndefs, nrdef, num, nums,
        table;

  # switch on the automatic handling of coinicidences, if necessary
  coincSwitch := ctSheet!.coincSwitch;
  ctSheet!.coincSwitch := true;

  # get some local variables
  table := ctSheet!.table;

  # do the coset enumeration
  nrdef := Length( defs );
  nums := ListWithIdenticalEntries( nrdef, 0 );
  nums[1] := 1;
  n := 1;

  # start the enumeration.
  closed := false;
  i := 0;
  while i < nrdef and not closed do
    i := i + 1;
    def := defs[i];
    num := nums[def[1]];
    if num <= 0 then
      Error( "undefined coset used in definition" );
    fi;

    # check if the table entry to be defined is already defined
    nums[def[3]] := table[def[2]][num];
    if nums[def[3]] <= 0 then
      n := n + 1;
      ndefs := ctSheet!.ndefs;
      ItcFastCosetStepFill( ctSheet, num, def[2] );
      closed := ctSheet!.firstDef = 0;

      # check for a fail because of insufficient table size
      if ctSheet!.ndefs = ndefs then
        # reconstruct the last preceding state and break loop
        ItcExtractPrecedingTable( ctSheet );
        i := nrdef;

      elif not closed then
        # check if there were coincidences.
        nalive := ctSheet!.ndefs - ctSheet!.nrdel;
        if nalive = n then
          nums[def[3]] := n;
        else
          # update the coset numbers in list nums.
          for j in [ 1 .. i ] do
            def := defs[j];
            num := nums[AbsInt( def[1] )];
            nums[def[3]] := table[def[2]][num];
          od;
          n := nalive;
        fi;
      fi;
    fi;

    # save the state before the last step.
    if i < nrdef then
      if ctSheet!.firstDef = 0 then
        # if table has closed reconstruct the last preceding state.
        ItcExtractPrecedingTable( ctSheet );
      elif i = nrdef - 1 then
        # if only one more step has to be done save the new state.
        ItcExtractTable( ctSheet );
      fi;
    fi;
  od;

  # save the current state.
  ItcExtractTable( ctSheet );

  # display the coset tables and set all variables
  ItcDisplayCosetTable( ctSheet );
  ItcEnableMenu( ctSheet );

  # reset the coincidences switch
  ctSheet!.coincSwitch := coincSwitch;
end );


#############################################################################
#
# ItcReinitializeParameters( <ctSheet> )
#
# reinitializes the parameters for the coset enumeration.
#
InstallGlobalFunction( ItcReinitializeParameters, function( ctSheet )

  local app, cols, g, gen, fgens, fsgens, i, j, length, length2, limit,
        ncols, ndefs, next, nums, p, p1, p2, prev, range, rel, subgrp, table;

  # get the arguments
  limit := ctSheet!.limit;
  table := ctSheet!.table;
  ndefs := ctSheet!.ndefs;
  ncols := ctSheet!.ncols;
  fgens := ctSheet!.fgens;
  fsgens := ctSheet!.fsgens;
  app := ctSheet!.app;

  # clear the table entries.
  next := ctSheet!.next;
  range := [ 1 .. Length( table ) ];
  j := 1;
  while j <> 0 do
    for i in range do
      table[i][j] := 0;
    od;
    j := next[j];
  od;

  # set up the parameters for the coset enumeration
  ctSheet!.nrdel := 0;
  ctSheet!.ndefs := 1;

  # close all gap sheets and reinitialize the gap lists
  ItcCloseGapSheets( ctSheet );
  ctSheet!.gaps := 0;

  # define one coset (1)
  ctSheet!.firstDef := 1; ctSheet!.lastDef := 1;
  ctSheet!.firstFree := 2; ctSheet!.lastFree := limit;

  # make the lists that link together all the cosets
  next := [ 2 .. limit + 1 ];
  prev := [ 0 .. limit - 1 ];
  next[1] := 0;
  next[limit] := 0;
  prev[2] := 0;
  ctSheet!.next := next;
  ctSheet!.prev := prev;

  # make the rows for the subgroup generators
  subgrp := [];
  for rel in fsgens do
    length := Length( rel );
    length2 := 2*length;
    nums := ListWithIdenticalEntries( length2, 0 );
    cols := ListWithIdenticalEntries( length2, 0 );
    i := 0; j := 0;
    while i < length do
      i := i+1; j := j+2;
      gen := Subword( rel, i, i );
      p := Position( fgens, gen );
      if p = fail then
        p := Position( fgens, gen^-1 );
        p1 := 2*p;
        p2 := 2*p-1;
      else
        p1 := 2*p-1;
        p2 := 2*p;
      fi;
      nums[j]   := p1;  cols[j]   := table[p1];
      nums[j-1] := p2;  cols[j-1] := table[p2];
    od;
    Add( subgrp, [ nums, cols ] );
  od;
  ctSheet!.subgrp := subgrp;

  # update the structure that is passed to 'MakeConsequences'
  app[2] := next;
  app[3] := prev;
  app[5] := subgrp;
end );


#############################################################################
#
# ItcRelabelInfoLine( <ctSheet> )
#
# display the Information Line at the bottom of the CosetTable Window.
#
InstallGlobalFunction( ItcRelabelInfoLine, function( ctSheet )

  local alive, blanks, defined, deleted, digits, indispensable, info,
        infoLine, length, nloops, ndefs, nrdel, shortCut, string;

  # get some local variables
  infoLine := ctSheet!.infoLine;
  info := infoLine[2];
  ndefs := ctSheet!.ndefs;
  nrdel := ctSheet!.nrdel;
  digits := 3;
  if ndefs > 999 then
    digits := 4;
    if ndefs > 9999 then
      digits := 5;
    fi;
  fi;

  # update the underlying text if necessary
  FastUpdate( ctSheet, true );
  if digits <> infoLine[1] then
    infoLine[1] := digits;
    info := -1;

    # update the default text
    blanks := String( " ", digits + 4 );
    string := Concatenation( "Defined:", blanks, "Deleted:", blanks,
      "Alive:" );
    Relabel( infoLine[3], string );
  fi;

  # update the general info
  defined := String( ndefs, -digits );
  deleted := String( nrdel, -digits );
  alive := String( ndefs - nrdel );
  string := Concatenation( String( " ", 9 ), defined, String( " ", 12 ),
    deleted, String( " ", 10 ), alive );
  Relabel( infoLine[4], string );

  # update the special info
  blanks := String( " ", 48 );

  if ctSheet!.coincs <> [] then

    # there are pending coincidences
    if info <> 2 then
      string := Concatenation( blanks, "Pending coincidences" );
      if info = 6 or info = 7 then
        Relabel( infoLine[6], "" );
      fi;
      Relabel( infoLine[5], string );
      info := 2;
    fi;

  elif ctSheet!.shortCut <> 0 then

    # the coset table is short-cut
    shortCut := ctSheet!.shortCut;
    nloops := shortCut[1];
    indispensable := shortCut[2];
    if info = 6 or info = 7 then
      Relabel( infoLine[6], "" );
    fi;
    if indispensable = 0 then
      # the short-cut is complete
      if nloops = 1 then
        if info <> 4 then
          string := Concatenation( blanks, "Short-cut (", String( nloops ),
            " loop)" );
          Relabel( infoLine[5], string );
          info := 4;
        fi;
      else
        if info <> 5 then
          string := Concatenation( blanks, "Short-cut (", String( nloops ),
            " loops)" );
          Relabel( infoLine[5], string );
          info := 5;
        fi;
      fi;
    else
      # the short-cut is incomplete
      string := String( nloops );
      length := Length( string );
      string := Concatenation( blanks, string );
      Relabel( infoLine[6], string );
      blanks := String( " ", 49 + length );
      if nloops = 1 then
        if info <> 6 then
          string := Concatenation( blanks, "Short-cut loop" );
          Relabel( infoLine[5], string );
          info := 6;
        fi;
      else
        if info <> 7 or length > Length( String( nloops - 1 ) ) then
          string := Concatenation( blanks, "Short-cut loops" );
          Relabel( infoLine[5], string );
          info := 7;
        fi;
      fi;
    fi;

  elif ctSheet!.firstDef = 0 then

    # the coset table is closed
    if ctSheet!.sorted then

      # the definitions are sorted
      if info <> 8 then
        string := Concatenation( blanks, "Tables sorted" );
        if info = 6 or info = 7 then
          Relabel( infoLine[6], "" );
        fi;
        Relabel( infoLine[5], string );
        info := 8;
      fi;

    else

      # the definitions are not sorted
      if info <> 1 then
        string := Concatenation( blanks, "Tables closed" );
        if info = 6 or info = 7 then
          Relabel( infoLine[6], "" );
        fi;
        Relabel( infoLine[5], string );
        info := 1;
      fi;
    fi;

  elif not ctSheet!.coincSwitch then

    # the coincidence handling is switched off
    if info <> 3 then
      string := Concatenation( blanks, "Coincidence handling OFF" );
      if info = 6 or info = 7 then
        Relabel( infoLine[6], "" );
      fi;
      Relabel( infoLine[5], string );
      info := 3;
    fi;

  else

    # cancel any special info
    if info <> 0 then
      if info = 6 or info = 7 then
        Relabel( infoLine[6], "" );
      fi;
      Relabel( infoLine[5], "" );
      info := 0;
    fi;

  fi;

  FastUpdate( ctSheet, false );
  ctSheet!.infoLine[2] := info;
end );


#############################################################################
#
# ItcRelationTable( <ctSheet>, <costab>, <rel>, <line0>, <nlines> )
#
# computes and returns a (new or old) relation or subgroup table.
#
InstallGlobalFunction( ItcRelationTable,
  function( ctSheet, costab, rel, line0, nlines )

  local alives, cos, gen, invcol, i, j, length, reltab, row;

  # get some local variables
  invcol := ctSheet!.invcol;
  alives := ctSheet!.alives;
  length := Length( rel );

  # initialize the table to be built up
  reltab := ListWithIdenticalEntries( nlines, 0 );

  # compute the table
  for i in [ 1 .. nlines ] do

    # initialize the next row
    cos := alives[line0 + i];
    row := ListWithIdenticalEntries( length + 1, 0 );
    row[1] := cos;
    row[length + 1] := cos;

    # scan as long as possible from the left to the right
    j := 1;
    while j < length and cos > 0 do
      gen := rel[j];
      cos := costab[cos][gen];
      if cos > 0 then
        j := j + 1;
        row[j] := cos;
      fi;
    od;

    # scan as long as possible from the right to the left
    if cos <= 0 then
      j := length;
      cos := row[1];
      while j > 1 and cos > 0 do
        gen := invcol[rel[j]];
        cos := costab[cos][gen];
        if cos > 0 then
          row[j] := cos;
          j := j - 1;
        fi;
      od;
    fi;
    reltab[i] := row;

  od;
  return reltab;

end );


#############################################################################
#
# ItcRepresentativeCoset( <ctSheet>, <coset> )
#
# returns a representative element of the given coset.
#
InstallGlobalFunction( ItcRepresentativeCoset, function( ctSheet, coset )

    local def, defs, fgens, gen, involutory, rep;

    # get some local variables
    fgens := ctSheet!.fgens;
    defs := ctSheet!.defs;
    involutory := ctSheet!.involutory;

    # construct the representative and return it
    rep := fgens[1] * fgens[1]^-1;
    while coset > 1 do
      def := defs[coset-1];
      if def[3] <> coset then
        Error( "THIS IS A BUG (ITC 11), YOU SHOULD NEVER GET HERE" );
      fi;
      gen := def[2];
      if involutory[gen] = 2 and gen mod 2 = 0 then
        gen := gen - 1;
      fi;
      if gen mod 2 = 0 then
        rep := rep * fgens[gen/2];
      else
        rep := rep * fgens[(gen+1)/2]^-1;
      fi;
      coset := def[1];
    od;;
    return rep^-1;
end );


#############################################################################
#
# ItcReset( <ctSheet>, <menu>, <entry> )
#
#
InstallGlobalFunction( ItcReset, function( ctSheet, menu, entry )

  local defaultLimit, settingsSheet, string;

  # echo the command
  if ctSheet!.echo then
    Print( ">> RESET\n" );
  fi;

  # switch off the echo
  ctSheet!.echo := false;

  # switch on the automatic handling of coincidences
  ctSheet!.coincSwitch := true;

  # set the default gaps strategy
  ctSheet!.gapsStrategy := 1;

  # reset the table size
  defaultLimit := 1000;
  ctSheet!.defaultLimit := defaultLimit;

  # update the sheet of current settings
  if IsBound( ctSheet!.settingsSheet ) and IsAlive( ctSheet!.settingsSheet )
    then
    settingsSheet := ctSheet!.settingsSheet;
    FastUpdate( ctSheet, true );
    string := Concatenation( "table size ", String( defaultLimit ) );
    Relabel( settingsSheet!.boxes[2], string );
    string := Concatenation( "default ", string );
    Relabel( settingsSheet!.boxes[1], string );
    Relabel( settingsSheet!.boxes[3], "coincidence handling ON" );
    Relabel( settingsSheet!.boxes[4], "echo OFF" );
    Relabel( settingsSheet!.boxes[5], "gaps strategy 1 (first gap)" );
    FastUpdate( ctSheet, false );
  fi;

  # clear the coset table
  ItcClear( ctSheet, 0, 0 );

end );


#############################################################################
#
# ItcScrollBy( <ctSheet>, <menu>, <entry> )
#
# is called by clicking the button 'scroll by'.
#
InstallGlobalFunction( ItcScrollBy, function( ctSheet, menu, entry )

  local alives, first, line1, lines, marked, nalive, nargs, query,
        renumbered;

  # get some local variables
  renumbered := ctSheet!.renumbered;
  alives := ctSheet!.alives;
  nalive := Length( alives );
  first := ctSheet!.first;
  marked := ctSheet!.marked;

  # get a suitable default value from the last number of lines scrolled by
  line1 := renumbered[first];
  lines := ctSheet!.scroll;
  # change the direction if necessary
  if lines > 0 and line1 = nalive then
    lines := -20;
  fi;
  if lines < 0 and line1 = 1 then
    lines := 20;
  fi;
  # reduce the number if it is out of range
  if lines > 0 then
    lines := Minimum( lines, Maximum( nalive - line1, 0 ) );
  else
    lines := Maximum( lines, 1 - line1 );
  fi;

  # now select the number of lines to be scrolled
  query := Query( Dialog( "OKcancel", "rows to scroll by?" ),
    String( lines ) );

  # echo the command
  if ctSheet!.echo then
    Print( ">> SCROLL BY ", query, "\n" );
  fi;

  # return if the query has been canceled
  if query = false then
    return;
  fi;

  # evaluate the query string and check the arguments
  query := ItcQuery( query );
  nargs := Length( query );
  if nargs = 0 or query = [ 0 ] then
    Relabel( ctSheet!.messageText, "This command has no effect" );
    ctSheet!.message := true;
    return;
  fi;
  lines := query[1];
  if not IsInt( lines ) or nargs > 1 then
    Relabel( ctSheet!.messageText, "Illegal argument" );
    ctSheet!.message := true;
    return;
  fi;

  # reduce the number of lines to be scrolled if it is out of range
  if lines > 0 then
    lines := Minimum( lines, Maximum( nalive - line1, 0 ) );
  else
    lines := Maximum( lines, 1 - line1 );
  fi;
  # save the new scroll number
  ctSheet!.scroll := lines;

  # get the first row to be displayed
  line1 := Maximum( 1, Minimum( nalive, line1 + lines ) );
  ctSheet!.first := alives[line1];

  # display the coset table
  ItcDisplayCosetTable( ctSheet );
  ItcScrollRelationTables( ctSheet );
  ItcEnableMenu( ctSheet );

end );


#############################################################################
#
# ItcScrollRelationTables( <ctSheet> )
#
# scolls the currently open relation and definition tables.
#
InstallGlobalFunction( ItcScrollRelationTables, function( ctSheet )

  local i, nrels, rtSheets;

  # get some local variables
  rtSheets := ctSheet!.rtSheets;
  nrels := Length( ctSheet!.rels );

  # loop over all relation tables
  for i in [ 1 .. nrels ] do
    if IsBound( rtSheets[i] ) and IsAlive( rtSheets[i] ) then
      ItcDisplayRelationTable( ctSheet, i );
    fi;
  od;

  if IsBound( ctSheet!.defSheet ) and IsAlive( ctSheet!.defSheet ) then
    ItcDisplayDefinitionsTable( ctSheet );
  fi;

end );


#############################################################################
#
# ItcScrollTo( <ctSheet>, <menu>, <entry> )
#
# is called by selecting the menu entry 'scroll to' or by clicking on the
# button 'scroll to'.
#
InstallGlobalFunction( ItcScrollTo, function( ctSheet, menu, entry )

  local alives, coset, first, line1, marked, nalive, nargs, ndefs, query,
        renumbered;

  # get some local variables
  ndefs := ctSheet!.ndefs;
  renumbered := ctSheet!.renumbered;
  alives := ctSheet!.alives;
  nalive := Length( alives );
  first := ctSheet!.first;
  marked := ctSheet!.marked;

  # find a suitable default value
  line1 := renumbered[first];
  if nalive - line1 < 30 then
    coset := 1;
  else
    coset := ndefs;
    while renumbered[coset] = 0 do
      coset := coset - 1;
    od;
  fi;

  # select the line to scroll to
  query := Query( Dialog( "OKcancel", "scroll to coset?" ),
    String( coset ) );

  # echo the command
  if ctSheet!.echo then
    Print( ">> SCROLL TO ", query, "\n" );
  fi;

  # return if the query has been canceled
  if query = false then
    return;
  fi;

  # evaluate the query string and check the arguments
  query := ItcQuery( query );
  nargs := Length( query );
  if nargs = 0 then
    coset := 1;
  else
    coset := query[1];
    if not IsInt( coset ) or nargs > 1 then
      Relabel( ctSheet!.messageText, "Illegal argument" );
      ctSheet!.message := true;
      return;
    fi;
  fi;
  coset := Maximum( 1, Minimum( ndefs, coset ) );

  # get the first row to be displayed
  while renumbered[coset] = 0 do
    coset := coset - 1;
  od;
  line1 := Maximum( 1, renumbered[coset] - 14 );
  first := alives[line1];

  # don't do anything if the request is for the current position
  if first = ctSheet!.first then
    return;
  fi;

  # save the new position
  ctSheet!.first := first;

  # display the coset table
  ItcDisplayCosetTable( ctSheet );
  ItcScrollRelationTables( ctSheet );
  ItcEnableMenu( ctSheet );

end );


#############################################################################
#
# ItcShortCut( <ctSheet>, <menu>, <entry> )
#
InstallGlobalFunction( ItcShortCut, function( ctSheet, menu, entry )

  local closed, coincSwitch, cos, nloops, def, defs, gen, i, indispensable,
        j, n, nargs, ndefs, new, newdefs, nrdel, nums, old, query, reps,
        shortCut, sortlist, steps;

  # check if the table is closed.
  if ctSheet!.firstDef <> 0 then
    Relabel( ctSheet!.messageText, "The tables are not closed" );
    ctSheet!.message := true;
    return;
  fi;

  # get some local variables
  defs := ctSheet!.defs;
  ndefs := Length( defs );
  nrdel := ctSheet!.nrdel;
  shortCut := ctSheet!.shortCut;

  # check if the tables are already in short-cut form
  if shortCut <> 0 and shortCut[3] = 0 then
    Relabel( ctSheet!.messageText,
      "The tables are already in short-cut form" );
    ctSheet!.message := true;
    return;
  fi;

  # there is nothing to do if no coincidences have occurred
  if nrdel = 0 then
    ctSheet!.shortCut := [ 0, 0, 0 ];
    ItcRelabelInfoLine( ctSheet );
    return;
  fi;

  # select the number of steps to be done
  query := Query( Dialog( "OKcancel", "number of loops? (optionally)" ) );

  # echo the command
  if ctSheet!.echo then
    Print( ">> SHORT-CUT ", query, "\n" );
  fi;

  # return if the query has been canceled
  if query = false then
    return;
  fi;

  # evaluate the query string and check the arguments
  query := ItcQuery( query );
  nargs := Length( query );
  if nargs = 0 then
    steps := -1;
  else
    steps := query[1];
    if not IsInt( steps ) or nargs > 1 then
      Relabel( ctSheet!.messageText, "Illegal argument" );
      ctSheet!.message := true;
      return;
    fi;
  fi;

  # switch on the automatic handling of coinicidences, if necessary
  coincSwitch := ctSheet!.coincSwitch;
  ctSheet!.coincSwitch := true;

  # check if the short-cut has already been initialized
  if shortCut = 0 then

    # initialize the short-cut
    sortlist := List( [ 1 .. ndefs ], i -> [ 0, i ] );
    indispensable := 0;
    nloops := 0;
    shortCut := [ nloops, indispensable, sortlist, ];

  else

    # get some local variables and initialize some local lists
    nloops := shortCut[1];
    indispensable := shortCut[2];
    sortlist := shortCut[3];

  fi;

  # clear the table
  ItcClearTable( ctSheet );
  # save the short-cut
  ctSheet!.shortCut := shortCut;
  # switch off the handling of gaps of length 1
  ctSheet!.app[12] := 0;

  while steps <> 0 and sortlist[ndefs][1] >= 0 do

    steps := steps - 1;

    # initialize some variables for the step
    nums := [ 1 .. ndefs + 1 ];
    reps := [ 1 .. ndefs + 1 ];

    # mark the last coset and those which are needed to define it to be
    # indispensable.
    i := ndefs;
    while i > 0 do
      indispensable := indispensable + 1;
      sortlist[i][1] := - indispensable;
      def := defs[sortlist[i][2]];
      i := def[1] - 1;
    od;
    Sort( sortlist );

    # initialize the new enumeration.
    ItcReinitializeParameters( ctSheet );
    newdefs := [];
    ctSheet!.defs := newdefs;
    ctSheet!.ndefs := 1;
    ctSheet!.renumbered := [1];
    ctSheet!.alives := [ [1], [1], [1] ];

    # start the enumeration.
    closed := false;
    n := 0;
    i := 0;
    while i < ndefs and not closed do
      i := i + 1;
      def := defs[sortlist[i][2]];
      cos := reps[nums[def[1]]];
      gen := def[2];
      old := def[3];

      # check if the table entry is already defined.
      new := ctSheet!.table[gen][cos];
      if new > 0 then

        # skip the definition as it is redundant
        nums[old] := new;

      else

        # define a new coset and find all consequences
        n := n + 1;
        new := n + 1;
        sortlist[n] := [ sortlist[i][1], n ];
        nums[old] := new;
        # reps[new] := new;
        nrdel := ctSheet!.nrdel;
        ItcFastCosetStepFill( ctSheet, cos, gen );
        closed := ctSheet!.firstDef = 0;

        if not closed then
          # check if there were coincidences.
          if ctSheet!.nrdel > nrdel then
            # update the reference list 'nums'
            for j in [ 1 .. n ] do
              def := newdefs[j];
              old := def[3];
              cos := reps[def[1]];
              gen := def[2];
              new := ctSheet!.table[gen][cos];
              reps[old] := new;
            od;
          fi;
        fi;

      fi;
    od;

    if not closed then
      Error( "table has not closed in short-cut procedure" );
    fi;

    while n < ndefs do
      Unbind( sortlist[ndefs] );
      ndefs := ndefs - 1;
    od;
    nloops := nloops + 1;

    # save and display the current state.
    defs := ctSheet!.defs;
    shortCut[1] := nloops;
    shortCut[2] := indispensable;
    shortCut[3] := sortlist;
    ItcRelabelInfoLine( ctSheet );

  od;

  # clear the table
  ItcClearTable( ctSheet );

  # save the short-cut
  if sortlist[ndefs][1] < 0 then
    shortCut[2] := 0;
    shortCut[3] := 0;
  fi;
  ctSheet!.shortCut := shortCut;

  # do the final coset enumeration
  for i in [ 1 .. ndefs - 1 ] do
    ItcFastCosetStepFill( ctSheet, defs[i][1], defs[i][2] );
  od;
  ItcExtractTable( ctSheet );
  ItcCosetStepFill( ctSheet, defs[ndefs][1], defs[ndefs][2] );
  ItcExtractTable( ctSheet );

  # display the coset table and set all variables
  ItcDisplayCosetTable( ctSheet );
  ItcUpdateDisplayedLists( ctSheet );
  ItcEnableMenu( ctSheet );

  # reset the coincidences switch
  ctSheet!.coincSwitch := coincSwitch;
# Print( "short-cut reduced to ", ctSheet!.ndefs, " DEFS\n" );

end );


#############################################################################
#
# ItcShowCoincs( <ctSheet>, <menu>, <entry> )
#
# displays pending coincidences.
#
InstallGlobalFunction( ItcShowCoincs, function( ctSheet, menu, entry )

  # echo the command
  if ctSheet!.echo then
    Print( ">> SHOW COINCS\n" );
  fi;

  # display the pending coincidences
  ItcDisplayPendingCoincidences( ctSheet );
end );


#############################################################################
#
# ItcShowDefs( <ctSheet>, <menu>, <entry> )
#
InstallGlobalFunction( ItcShowDefs, function( ctSheet, menu, entry )

  # echo the command
  if ctSheet!.echo then
    Print( ">> SHOW DEFS\n" );
  fi;

  # check if there is a definitions sheet
  if IsBound( ctSheet!.defSheet ) and IsAlive( ctSheet!.defSheet ) then

    # just close it
    ItcCloseSheets( ctSheet!.repLists[2] );
    ctSheet!.repLists := [ [], [] ];
    Close( ctSheet!.defSheet );

  else

    # open a new sheet and display the definitions
    ItcDisplayDefinitionsTable( ctSheet );

  fi;
end );


#############################################################################
#
# ItcShowGaps( <ctSheet>, <menu>, <entry> )
#
# computes and displays a list of the current gaps of length one, sorted by
# classes of equivalent ones.
#
InstallGlobalFunction( ItcShowGaps, function( ctSheet, menu, entry )

  local boxes, charWidth, classSheets, distance, gaps, gapSheet, height, i,
        length, lineHeight, n, name, names, rep, reps, string, width, x, y;

  # echo the command
  if ctSheet!.echo then
    Print( ">> SHOW GAPS\n" );
  fi;

  # get some local variables
  distance := ctSheet!.normal.distance;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;
  names := ctSheet!.genNames;
  gaps := ItcGaps( ctSheet );
  reps := gaps[1];
  length := Length( reps );
  gapSheet := gaps[3];
  classSheets := gaps[4];

  # if gaps of length 1 sheets are alive, just close them and return
  if gapSheet <> 0 and IsAlive( gapSheet ) then
    ItcCloseGapSheets( ctSheet );
    return;
  fi;

  if reps = [] then

    # just display a message if there are no gaps of class 1
    Relabel( ctSheet!.messageText, "There are no gaps of length 1" );
    ctSheet!.message := true;

  else

    # open a new graphic sheet for the list of class reps
    name := "Gaps of length 1 (class reps)";
    n := 15 + Length( String( length ) ) +
      Length( String( reps[length][1] ) ) +
      Length( String( reps[length][2] ) ) +
      Maximum( List( names, x -> Length( x ) ) );
    width := Maximum( n * charWidth, WidthOfSheetName( name ) );
    height := 3 * distance + Length( reps ) * lineHeight;
    gapSheet := GraphicSheet( name, width, height );
    SetFilterObj( gapSheet, IsItcGapSheet );

    # install callbacks for the pointer buttons
    InstallCallback( gapSheet, "LeftPBDown", ItcGapSheetLeftPBDown );
    InstallCallback( gapSheet, "RightPBDown", ItcGapSheetRightPBDown );

    boxes := [];
    x := 2 * charWidth;
    for i in [ 1 .. length ] do
      y := i * lineHeight;
      rep := reps[i];
      string := Concatenation( String( i ), ":  ", String( rep[1] ), "  [ ",
        String( rep[2] ), ", ", ctSheet!.genNames[rep[3]], " ]" );
      boxes[i] := Text( gapSheet, FONTS.normal, x, y, string );
    od;
    gapSheet!.ctSheet := ctSheet;
    gapSheet!.boxes := boxes;
    gaps[3] := gapSheet;

  fi;

end );


#############################################################################
#
# ItcShowRels( <ctSheet>, <menu>, <entry> )
#
# reopens a graphic sheet for the relators.
#
InstallGlobalFunction( ItcShowRels, function( ctSheet, menu, entry )

  local charWidth, distance, height, lineHeight, name, n, nrels, relSheet,
        width;

  # echo the command
  if ctSheet!.echo then
    Print( ">> SHOW RELS\n" );
  fi;

  # get some local variables
  nrels := Length( ctSheet!.rels );
  distance := ctSheet!.normal.distance;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;

  # if there is a relators sheet, just close it and return
  if IsBound( ctSheet!.relSheet ) and IsAlive( ctSheet!.relSheet ) then
    Close( ctSheet!.relSheet );
    return;
  fi;

  # if there are no relators, open a default sheet
  if nrels = 0 then
    name := "no relators";
    width := WidthOfSheetName( name );
    relSheet := GraphicSheet( name, width, lineHeight );
    ctSheet!.relSheet := relSheet;

  else

    # open a new graphic sheet for the list of relators
    n := 7 + Length( String( nrels ) ) +
      Maximum( List( ctSheet!.relText, x -> Length( x ) ) );
    width := Maximum( 80, n * charWidth );
    height := 3 * distance + nrels * lineHeight;
    relSheet := GraphicSheet( "Relators", width, height );
    SetFilterObj( relSheet, IsItcRelatorsSheet );

    # install callbacks for the pointer buttons
    InstallCallback( relSheet, "LeftPBDown", ItcRelatorsSheetLeftPBDown );

    # replace the old sheet by the new one
    ctSheet!.relSheet := relSheet;
    relSheet!.ctSheet := ctSheet;

    # display it
    ItcDisplayRelatorsSheet( relSheet );
  fi;
end );


#############################################################################
#
# ItcShowSettings( <ctSheet>, <menu>, <entry> )
#
# displays the settings.
#
InstallGlobalFunction( ItcShowSettings, function( ctSheet, menu, entry )

  local boxes, charWidth, distance, height, i, lineHeight, name,
        settingsSheet, strategy, string, width, x, y;

  # get some local variables
  distance := ctSheet!.normal.distance;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  # echo the command
  if ctSheet!.echo then
    Print( ">> SHOW SETTINGS\n" );
  fi;

  # if there is a sheet of current settings, just close it and return
  if IsBound( ctSheet!.settingsSheet ) and IsAlive( ctSheet!.settingsSheet )
    then
    Close( ctSheet!.settingsSheet );
    ## return;
  fi;

  # if there is no sheet of current settings, open an appropriate sheet
  name := "Current Settings";
  height := 3 * distance + 5 * lineHeight;
  width := Maximum( 43 * charWidth, WidthOfSheetName( name ) );
  settingsSheet := GraphicSheet( name, width, height );

  boxes := [];
  x := charWidth;
  y := 0;

  # (1) default table size
  # ----------------------
  y := y + lineHeight;
  string := Concatenation( "default table size ",
    String( ctSheet!.defaultLimit ) );
  boxes[1] := Text( settingsSheet, FONTS.normal, x, y, string );

  # (2) current table size
  # ----------------------
  y := y + lineHeight;
  string := Concatenation( "table size ", String( ctSheet!.limit ) );
  boxes[2] := Text( settingsSheet, FONTS.normal, x, y, string );

  # (3) automatic coincidence handling
  # ----------------------------------
  y := y + lineHeight;
  if ctSheet!.coincSwitch then
    string := "coincidence handling ON";
  else
    string := "coincidence handling OFF";
  fi;
  boxes[3] := Text( settingsSheet, FONTS.normal, x, y, string );

  # (4) echo
  # --------
  y := y + lineHeight;
  if ctSheet!.echo then
    string := "echo ON";
  else
    string := "echo OFF";
  fi;
  boxes[4] := Text( settingsSheet, FONTS.normal, x, y, string );

  # (5) gaps strategy
  # -----------------
  y := y + lineHeight;
  strategy := ctSheet!.gapsStrategy;
  if strategy = 1 then
    string := "gaps strategy 1 (first gap)";
  elif strategy = 2 then
    string := "gaps strategy 2 (first rep of max weight)";
  elif strategy = 3 then
    string := "gaps strategy 3 (last rep of max weight)";
  elif strategy = 4 then
    string := "gaps strategy 4 (last gap of max weight)";
  fi;
  boxes[5] := Text( settingsSheet, FONTS.normal, x, y, string );

  settingsSheet!.ctSheet := ctSheet;
  settingsSheet!.boxes := boxes;

  ctSheet!.settingsSheet := settingsSheet;
end );


#############################################################################
#
# ItcShowSubgrp( <ctSheet>, <menu>, <entry> )
#
# reopens a graphic sheet for the subgroup generators.
#
InstallGlobalFunction( ItcShowSubgrp, function( ctSheet, menu, entry )

  local charWidth, distance, height, lineHeight, n, name, nsgens, subSheet,
        width;

  # echo the command
  if ctSheet!.echo then
    Print( ">> SHOW SUBGRP\n" );
  fi;

  # get some local variables
  nsgens := Length( ctSheet!.fsgens );
  distance := ctSheet!.normal.distance;
  lineHeight := ctSheet!.normal.lineHeight;
  charWidth := ctSheet!.normal.charWidth;

  # if there is a subgroup generators sheet, just close it and return
  if IsBound( ctSheet!.subSheet ) and IsAlive( ctSheet!.subSheet ) then
    Close( ctSheet!.subSheet );
    return;
  fi;

  # if there are no subgroup generators, open a default sheet
  if nsgens = 0 then
    Relabel( ctSheet!.messageText, "There are no subgroup generators" );
    ctSheet!.message := true;

  else

    # open a new graphic sheet for the list of subgroup gens
    name := "Subgroup gens";
    n := 7 + Length( String( nsgens ) ) +
      Maximum( List( ctSheet!.subText, x -> Length( x ) ) );
    width := Maximum( n * charWidth, WidthOfSheetName( name ) );
    height := 3 * distance + nsgens * lineHeight;
    subSheet := GraphicSheet( name, width, height );
    SetFilterObj( subSheet, IsItcSubgroupGeneratorsSheet );

    # install callbacks for the pointer buttons
    InstallCallback( subSheet, "LeftPBDown",
      ItcSubgroupGeneratorsSheetLeftPBDown );

    # replace the old sheet by the new one
    ctSheet!.subSheet := subSheet;
    subSheet!.ctSheet := ctSheet;

    # display it
    ItcDisplaySubgroupGeneratorsSheet( subSheet );
  fi;
end );


#############################################################################
#
# ItcSortDefinitions( <ctSheet>, <menu>, <entry> )
#
InstallGlobalFunction( ItcSortDefinitions, function( ctSheet, menu, entry )

  local block, closed, coincSwitch, cos, def, defs, gen, i, j, k, m, n,
        ndefs, new, newnum, nrdel, oldnum, sorted;

  # check if the table is closed.
  if ctSheet!.firstDef <> 0 then
    Relabel( ctSheet!.messageText, "The tables are not closed" );
    ctSheet!.message := true;
    return;
  fi;

  # echo the command
  if ctSheet!.echo then
    Print( ">> SORT DEFS\n" );
  fi;

  # get some local variables
  defs := ctSheet!.defs;
  ndefs := Length( defs );
  sorted := ctSheet!.sorted;

  # there is nothing to do if the definitions are already sorted
  if not sorted then
    sorted := IsSSortedList( defs );
  fi;
  if sorted then
    ctSheet!.shortCut := 0;
    ctSheet!.sorted := true;
    ItcRelabelInfoLine( ctSheet );
    return;
  fi;

  # switch on the automatic handling of coinicidences, if necessary
  coincSwitch := ctSheet!.coincSwitch;
  ctSheet!.coincSwitch := true;

  # clear the table
  ItcClearTable( ctSheet );
  # switch off the handling of gaps of length 1
  ctSheet!.app[12] := 0;

  # initialize the sorting process
  while not sorted do

    sorted := true;
    Sort( defs );
    block := ListWithIdenticalEntries( ndefs + 1, 0 );
    newnum := ListWithIdenticalEntries( ndefs + 1, 0 );
    oldnum := ListWithIdenticalEntries( ndefs + 1, 0 );
    j := 0;
    for i in [ 1 .. ndefs ] do
      if defs[i][1] <> j then
        j := defs[i][1];
        block[j] := i;
      fi;
    od;
    newnum[1] := 1;
    oldnum[1] := 1;
    n := 1;
    for j in [ 1 .. ndefs + 1 ] do
      m := oldnum[j];
      i := block[m];
      if i <> 0 then
        while i <= ndefs and defs[i][1] = m do
          k := defs[i][3];
          if newnum[k] <> 0 then
            Error( "THIS IS A BUG (ITC 12), YOU SHOULD NEVER GET HERE" );
          fi;
          n := n + 1;
          newnum[k] := n;
          oldnum[n] := k;
          i := i + 1;
        od;
      fi;
    od;
    if n <> ndefs + 1 then
      Error( "THIS IS A BUG (ITC 13), YOU SHOULD NEVER GET HERE" );
    fi;
    for i in [ 1 .. ndefs ] do
      def := defs[i];
        def[1] := newnum[def[1]];
        def[3] := newnum[def[3]];
    od;
    Sort( defs );

    # initialize the new enumeration.
    ItcReinitializeParameters( ctSheet );
    ctSheet!.defs := [];
    ctSheet!.ndefs := 1;
    ctSheet!.renumbered := [1];
    ctSheet!.alives := [ [1], [1], [1] ];

    # start the enumeration.
    closed := false;
    newnum := [ 1 .. ndefs + 1 ];
    n := 0;
    i := 0;
    while i < ndefs and not closed do
      i := i + 1;
      def := defs[i];
      cos := newnum[def[1]];
      gen := def[2];

      # check if the table entry is already defined.
      new := ctSheet!.table[gen][cos];
      if new > 0 then

        # skip the definition as it is redundant
        newnum[i+1] := new;
        sorted := false;

      else

        # define a new coset and find all consequences
        n := n + 1;
        new := n + 1;
        newnum[i+1] := new;
        nrdel := ctSheet!.nrdel;
        ItcFastCosetStepFill( ctSheet, cos, gen );
        closed := ctSheet!.firstDef = 0;

        if not closed then
          # check if there were coincidences.
          if ctSheet!.nrdel > nrdel then
            # update the reference list 'newnum'
            for j in [ 1 .. i ] do
              def := defs[j];
              cos := newnum[def[1]];
              gen := def[2];
              new := ctSheet!.table[gen][cos];
              newnum[j+1] := new;
            od;
          fi;
        fi;

      fi;
    od;
    ItcRelabelInfoLine( ctSheet );

    defs := ctSheet!.defs;
    ndefs := Length( defs );
    if sorted then
      sorted := IsSSortedList( defs );
    fi;
  od;

  # clear the table
  ItcClearTable( ctSheet );

  # do the final coset enumeration
  for i in [ 1 .. ndefs - 1 ] do
    ItcFastCosetStepFill( ctSheet, defs[i][1], defs[i][2] );
  od;
  ItcExtractTable( ctSheet );
  ItcCosetStepFill( ctSheet, defs[ndefs][1], defs[ndefs][2] );
  ItcExtractTable( ctSheet );

  # mark the coset table to be sorted
  ctSheet!.sorted := true;

  # display the coset table and set all variables
  ItcDisplayCosetTable( ctSheet );
  ItcUpdateDisplayedLists( ctSheet );
  ItcEnableMenu( ctSheet );

  # reset the coincidences switch
  ctSheet!.coincSwitch := coincSwitch;

end );


#############################################################################
#
# ItcString( <ctSheet>, <word> )
#
# converts  the relators  or subgroup generators  into strings for displaying
# them at the top of a relation or subgroup table.
#
InstallGlobalFunction( ItcString, function( ctSheet, word )

  local control, exponent, fgens, gen, i, j, length, names, ngens, string;

  # get some local variables
  names := ctSheet!.genNames;
  fgens := ctSheet!.fgens;
  ngens := Length( fgens );
  length := Length( word );

  string := "";
  i := 1;
  while i <= length do
    exponent := 1;
    control := false;
    while not control and i < length do
      if Subword( word, i, i ) = Subword( word, i+1, i+1 ) then
        exponent := exponent + 1;
        i := i + 1;
      else
        control := true;
      fi;
    od;
    gen := Subword( word, i, i );
    j := 0;
    while j < ngens do
      j := j + 1;
      if gen = fgens[j] then
        string := Concatenation( string, names[2*j - 1] );
        if exponent <> 1 then
          string := Concatenation( string, "^", String( exponent ) );
        fi;
        if i < length then
          string := Concatenation( string, "*" );
        fi;
        j := ngens;
      elif gen = fgens[j]^-1 then
        string := Concatenation( string, names[2*j - 1] );
        if exponent = 1 then
          string := Concatenation( string, "^-1" );
        else
          string := Concatenation( string, "^-", String( exponent ) );
        fi;
        if i < length then
          string := Concatenation( string, "*" );
        fi;
        j := ngens;
      fi;
    od;
    i := i + 1;
  od;
  return string;
end );


#############################################################################
#
# ItcStringRelationTable( <ctSheet>, <rtSheet>, <word> )
#
# converts  the relators  or subgroup generators  into strings for displaying
# them at the top of a relation or subgroup table.
#
InstallGlobalFunction( ItcStringRelationTable,
  function( ctSheet, rtSheet, word )

  local charHeight, charWidth, fgens, gen, genWidth, i, j, name, names,
        ngens, w;

  # get some local variables
  fgens := ctSheet!.fgens;
  names := ctSheet!.genNames;
  charHeight := ctSheet!.small.charHeight;
  charWidth := ctSheet!.small.charWidth;
  genWidth := ctSheet!.small.genWidth;
  ngens := Length( fgens );

  for i in [ 1 .. Length( word ) ] do
    gen := Subword( word, i, i );
    j := 0;
    while j < ngens do
      j := j + 1;
      if gen = fgens[j] then
        name := names[2*j - 1];
        j := ngens;
      elif gen = fgens[j]^-1 then
        name := names[2*j];
        j := ngens;
      fi;
    od;
    w := QuoInt( Length( name ) * charWidth, 2 );
    Text( rtSheet, FONTS.small, i * genWidth - w, charHeight, name );
  od;
end );


#############################################################################
#
# ItcUpdateDisplayedLists( <ctSheet> )
#
# updates the active relator and subgroup generator tables.
#
InstallGlobalFunction( ItcUpdateDisplayedLists, function( ctSheet )

  local coset, i, length, ndefs, nrels, nsgens, nums, repNums, repSheets,
        sheet, sheets;

  # get some local variables
  ndefs := ctSheet!.ndefs;
  nrels := Length( ctSheet!.rels );
  nsgens := Length( ctSheet!.fsgens );

  # update the relator tables
  for i in [ 1 .. nrels ] do
    if IsBound( ctSheet!.rtSheets[i] ) and
      IsAlive( ctSheet!.rtSheets[i] ) then
      ItcDisplayRelationTable( ctSheet, i );
    fi;
  od;

  # update the subgroup generator tables
  if IsBound( ctSheet!.stSheets ) then
    for i in [ 1 .. nsgens ] do
      if IsBound( ctSheet!.stSheets[i] ) and
        IsAlive( ctSheet!.stSheets[i] ) then
        ItcDisplaySubgroupTable( ctSheet, i );
      fi;
    od;
  fi;

  # update the definitions table
  if IsBound( ctSheet!.defSheet ) and IsAlive( ctSheet!.defSheet ) then
    ItcDisplayDefinitionsTable( ctSheet );
  fi;

  # update the coset representative sheets
  repNums := ctSheet!.repLists[1];
  length := Length( repNums );
  if length > 0 then
    repSheets := ctSheet!.repLists[2];
    nums := [];
    sheets := [];
    for i in [ 1 .. length ] do
      sheet := repSheets[i];
      if IsAlive( sheet ) then
        coset := repNums[i];
        if ItcIsAliveCoset( ctSheet, coset ) then
          Add( nums, coset );
          Add( sheets, sheet );
        else
          Close( sheet );
        fi;
      fi;
    od;
    ctSheet!.repLists := [ nums, sheets ];
  fi;
  

  # update the pending coincidences table
  if IsBound( ctSheet!.coiSheet ) and IsAlive( ctSheet!.coiSheet ) then
    ItcCloseSheets( ctSheet!.coiSheet!.repSheets );
    Close( ctSheet!.coiSheet );
    if not ctSheet!.coincSwitch then
      ItcDisplayPendingCoincidences( ctSheet );
    fi;
  fi;

  # # close the gaps of length 1 sheets if there are any
  # ItcCloseGapSheets( ctSheet );

end );


#############################################################################
#
# ItcUpdateFirstDef( <ctSheet> )
#
# updates the value of ctSheet!.firstDef which is defined to be the number of
# the first not yet closed row in the table, if there is any, or zero, else.
#
InstallGlobalFunction( ItcUpdateFirstDef, function( ctSheet )

  local firstDef, i, next, range, table;

  table := ctSheet!.table;
  next := ctSheet!.next;
  firstDef := ctSheet!.firstDef;

  range := [ 1 .. Length( table ) ];
  while firstDef <> 0  do
    for i in range do
      if table[i][firstDef] <= 0 then
        ctSheet!.firstDef := firstDef;
        return;
      fi;
    od;
    firstDef := next[firstDef];
  od;
  ctSheet!.firstDef := firstDef;

end );


#############################################################################
#
# ItcWriteDefinitions( <ctSheet>, <menu>, <entry> )
#
# writes the current definitions to a file.
#
InstallGlobalFunction( ItcWriteDefinitions, function( ctSheet, menu, entry )

  local defs, filename;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  # get the filename
  filename := Query( Dialog( "Filename", "Enter a filename" ) );

  # echo the command
  if ctSheet!.echo then
    Print( ">> WRITE DEFINITIONS TO FILE ", filename, "\n" );
  fi;

  if filename = "" or filename = false then
    return;
  fi;

  # get the list of definitions
  defs := ctSheet!.defs;

  # write it to the specified file
  PrintTo( filename, "local defs;\ndefs :=\n", defs, ";\nreturn defs;\n" );
  ItcEnableMenu( ctSheet );

end );


#############################################################################
#
# ItcWriteStandardizedTable( <ctSheet>, <menu>, <entry> )
#
# gets a copy of the given (closed) coset table,  standardizes it, and writes
# it to a file.
#
InstallGlobalFunction( ItcWriteStandardizedTable,
  function( ctSheet, menu, entry )

  local filename, table;

  # if there is an actual message line, clear it
  if ctSheet!.message then
    Relabel( ctSheet!.messageText, "" );
    ctSheet!.message := false;
  fi;

  # check if the table is closed.
  if ctSheet!.firstDef <> 0 then
    return;
  fi;

  # get the filename
  filename := Query( Dialog( "Filename", "Enter a filename" ) );

  # echo the command
  if ctSheet!.echo then
    Print( ">> WRITE STANDARDIZED TABLE TO FILE ", filename, "\n" );
  fi;

  if filename = "" or filename = false then
    return;
  fi;

  # get a standardized copy of the coset table
  table := StructuralCopy( ctSheet!.table );
  StandardizeTable( table );

  # write it to the specified file
  PrintTo( filename,
    "local table;\ntable :=\n", table, ";\nreturn table;\n" );
  ItcEnableMenu( ctSheet );

end );


#############################################################################
#
# WidthOfSheetName( <name> )
#
# returns the width of the given name of a graphic sheet.
#
# W A R N I N G :
# This function  makes an assumption  about the  font invariants  used by the
# the  underlying  X-Windows installation  to display  the  names of  graphic
# sheets.  It may be necessary to adapt these values appropriately in case of
# a particular installation.
#
InstallGlobalFunction( WidthOfSheetName, function( name )

  local font, width;

  # make an assumtion about the font invariants
  font := [ 11, 2, 7 ];

  # compute the width of the given name and return it
  width := ( Length( name ) + 2 ) * font[3];
  return width;

end );


#############################################################################
##
#F  InteractiveTC( <G>, <H> )
##
##  starts  the  Interactive Todd-Coxeter  coset enumeration  routines  for a
##  finitely presented group <G> and a subgroup <H> of <G>.
##
InstallGlobalFunction( InteractiveTC, function( G, H )

  local a, charHeight, ctSheet, charWidth, defaultLimit, digits, distance,
        fgens, fnames, font, fsgens, gap, gen, genWidth, height,
        heightButtons, heightCosetTable, heightInfoLine, i, invcol, limit,
        lineHeight, name, names, ncols, ngens, normal, nsgens, nrels, rel,
        relColumnNums, rels, relText, sgens, small, subColumnNums, subText,
        width, widthButtons, widthCosetTable, widthInfoLine;

  # check the arguments
  if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
    Error( "<G> must be a finitely presented group" );
  fi;
  if not ( IsSubgroupFpGroup( H ) and G = FamilyObj( H )!.wholeGroup ) then
    Error( "<H> must be a subgroup of <G>" );
  fi;

  # get some local variables
  fgens := FreeGeneratorsOfFpGroup( G );
  fnames := FamilyObj( fgens[1] )!.names;
  rels := RelatorsOfFpGroup( G );
  sgens := GeneratorsOfGroup( H );
  fsgens := List( sgens, UnderlyingElement );
  nrels := Length( rels );
  ngens := Length( fgens );
  nsgens := Length( sgens );
  ncols := 2 * ngens;
  name := "g";

  # check the number of generators
  if ngens > 99 then
    Print( "ITC cannot handle more than 99 generators\n" );
    return;
  fi;

  # initialize the default table size
  defaultLimit := 1000;
  digits := 5;

  # initialize a record with the small font invariants
  charHeight := FontInfo( FONTS.small )[1] + FontInfo( FONTS.small )[2];
  distance := Maximum( 1, QuoInt( 2 * charHeight + 5, 10 ) );
  lineHeight := charHeight + distance;
  charWidth := FontInfo( FONTS.small )[3];
  genWidth := ( digits + 2 ) * charWidth + distance;
  small := rec( );
  small.distance := distance;
  small.charHeight := charHeight;
  small.lineHeight := lineHeight;
  small.charWidth := charWidth;
  small.genWidth := genWidth;

  # initialize a record with the normal font invariants
  charHeight := FontInfo( FONTS.normal )[1] + FontInfo( FONTS.normal )[2];
  distance := Maximum( 1, QuoInt( 2 * charHeight + 5, 10 ) );
  lineHeight := charHeight + distance;
  charWidth := FontInfo( FONTS.normal )[3];
  genWidth := ( digits + 2 ) * charWidth + distance;
  gap := charWidth + Maximum( 1, QuoInt( distance + 1, 2 ) );
  normal := rec( );
  normal.distance := distance;
  normal.charHeight := charHeight;
  normal.lineHeight := lineHeight;
  normal.charWidth := charWidth;
  normal.genWidth := genWidth;
  normal.gap := gap;

  # open a graphic sheet for the coset table
  widthCosetTable := ( ( ncols + 1 ) * ( digits + 2 ) + 2 ) * small.charWidth;
  widthInfoLine := 72 * charWidth; 
  widthButtons := 7 * gap + 12 * distance + 61 * charWidth;
  width := Maximum( widthCosetTable, widthInfoLine, widthButtons );
  heightCosetTable := 3 * small.distance + ( 30 + 1 ) * small.lineHeight;
  heightInfoLine := 4 * distance + 2 * lineHeight;
  heightButtons := 4 * gap + 6 * distance + 3 * lineHeight;
  height := heightCosetTable + heightInfoLine + heightButtons;
  ctSheet := GraphicSheet( "Coset Table", width, height );
  SetFilterObj( ctSheet, IsItcCosetTableSheet );

  # install callbacks for the pointer buttons
  InstallCallback( ctSheet, "LeftPBDown", ItcCosetTableSheetLeftPBDown );
  InstallCallback( ctSheet, "RightPBDown", ItcCosetTableSheetRightPBDown );

  # initialize some other components
  ctSheet!.normal := normal;
  ctSheet!.small := small;
  ctSheet!.digits := digits;
  ctSheet!.gapsStrategy := 1;
  ctSheet!.scroll := 20;
  ctSheet!.markDefs := false;
  ctSheet!.marked := [];
  ctSheet!.shortCut := 0;
  ctSheet!.coincs := [];
  ctSheet!.deducs := [];
  ctSheet!.echo := false;
  ctSheet!.coincSwitch := true;
  ctSheet!.isActual := false;
  ctSheet!.sorted := false;
  ctSheet!.first := 1;
  ctSheet!.firstCol := [];
  ctSheet!.defs := [];
  ctSheet!.ndefs := 1;
  ctSheet!.hltRow := 1;
  ctSheet!.graphicTable := [];
  ctSheet!.rtSheets := [];
  ctSheet!.stSheets := [];
  ctSheet!.repLists := [ [], [] ];

  # set the table size
  limit := defaultLimit;
  ctSheet!.defaultLimit := defaultLimit;
  ctSheet!.limit := limit;

  # initialize some auxiliary lists
  ItcMakeDigitStrings( ctSheet );
  ctSheet!.newtab := ListWithIdenticalEntries( limit, 0 );
  ctSheet!.oldtab := ListWithIdenticalEntries( limit, 0 );

  # set the group and the subgroup
  ctSheet!.fgens := fgens;
  ctSheet!.rels := rels;
  ctSheet!.fsgens := fsgens;
  ctSheet!.ncols := ncols;
  ctSheet!.name := name;
  ctSheet!.gaps := 0;

  # get a list of the inverse column numbers
  invcol := ListWithIdenticalEntries( ncols, 0 );
  for i in [ 1 .. ngens ] do
    invcol[2*i - 1] := 2*i;
    invcol[2*i] := 2*i - 1;
  od;
  ctSheet!.invcol := invcol;

  # get the names of the generators and define shorter ones if necessary
  names := [];
  i := 0;
  while i < ngens do
    i := i + 1;
    name := fnames[i];
    Add( names, name );
    Add( names, Concatenation( name, "^-1" ) );
    if Length( name ) > 3 then
      name := ctSheet!.name;
      names := [];
      i := 0;
      while i < ngens do
        i := i + 1;
        Add( names, Concatenation( name, String( i ) ) );
        Add( names, Concatenation( name, String( i ), "^-1" ) );
      od;
    fi;
  od;
  ctSheet!.genNames := names;

  # get the relators of G
  relText := [];
  relColumnNums := [];
  for rel in rels do
    Add( relText, ItcString( ctSheet, rel ) );
    Add( relColumnNums, ItcListColumnNumbers( ctSheet, rel ) );
  od;
  ctSheet!.relText := relText;
  ctSheet!.relColumnNums := relColumnNums;

  # get the subgroup generators of H
  subColumnNums := [];
  if nsgens <> 0 then
    subText := [];
    for gen in fsgens do
      Add( subText, ItcString( ctSheet, gen ) );
      Add( subColumnNums, ItcListColumnNumbers( ctSheet, gen ) );
    od;
    ctSheet!.subText := subText;
  fi;
  ctSheet!.subColumnNums := subColumnNums;

  # initialize the coset table
  ctSheet!.renumbered := [1];
  ctSheet!.alives := [ [1], [1], [1] ];

  # display the headers and menus
  ItcInitializeInfoLine( ctSheet, heightCosetTable );
  ItcDisplayButtons( ctSheet, heightCosetTable + heightInfoLine );
  ItcDisplayHeaderOfCosetTable( ctSheet );
  ItcMakeMenu( ctSheet );

  # initialize the parameters for the coset enumeration
  ItcInitializeParameters( ctSheet );

  # display the coset table
  ItcDisplayCosetTable( ctSheet );

  ItcEnableMenu( ctSheet );
  return ctSheet;
end );


#############################################################################
##
#F  ItcExample( <name> )
##
InstallGlobalFunction( ItcExample, function( name )
    local file;

    file:= Filename( DirectoriesPackageLibrary( "itc", "examples" ), name );
    if file = fail then
      Print( "#I  no example file with name `", name, "'\n" );
    else
      ReadAsFunction( file )();
    fi;
end );


#############################################################################
##
#E

