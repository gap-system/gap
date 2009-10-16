##############################################################################
##
#W  htmltbl.g                                                    Thomas Breuer
##
#H  @(#)$Id: htmltbl.g,v 1.11 2003/10/15 09:20:04 gap Exp $
##
#Y  Copyright  (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the functions used to create the HTML info database
##  about the {\GAP} character table library.
##
##  1. Functions to Access Table Data without Creating Tables
##  2. Configuration Data
##  3. Functions to Access the Data
##  4. Functions to Create the Individual Files
##


##############################################################################
##
##  1. Functions to Access Table Data without Creating Tables
##
BindGlobal( "MyIdFunc", function( arg ); end );

BindGlobal( "TABLE_ACCESS_FUNCTIONS", [
    rec(),
    rec(
         LIBTABLE := rec( LOADSTATUS := rec(), clmelab := [],
                          clmexsp := [] ),
         SET_TABLEFILENAME := MyIdFunc,
         GALOIS := MyIdFunc,
         TENSOR := MyIdFunc,
         EvalChars := MyIdFunc,
         ALF := MyIdFunc,
         ACM := MyIdFunc,
         ARC := MyIdFunc,
         NotifyCharTableName := MyIdFunc,
         ALN := MyIdFunc,
         MBT := MyIdFunc,
         MOT := MyIdFunc,
         ConstructMixed := MyIdFunc,
         ConstructProj := MyIdFunc,
         ConstructDirectProduct := MyIdFunc,
         ConstructSubdirect := MyIdFunc,
         ConstructIsoclinic := MyIdFunc,
         ConstructV4G := MyIdFunc,
         ConstructGS3 := MyIdFunc,
         ConstructPermuted := MyIdFunc,
         ConstructClifford := MyIdFunc,
         ConstructFactor := MyIdFunc
        ) ] );

SaveTableAccessFunctions := function()
    local name;

    if TABLE_ACCESS_FUNCTIONS[1] <> rec() then
      Print( "functions already saved!\n" );
      return;
    fi;

    Print( "#I  before save!\n" );

    for name in RecNames( TABLE_ACCESS_FUNCTIONS[2] ) do
      TABLE_ACCESS_FUNCTIONS[1].( name ):= [ ValueGlobal( name ) ];
      if IsReadOnlyGlobal( name ) then
        Add( TABLE_ACCESS_FUNCTIONS[1].( name ), "readonly" );
        MakeReadWriteGlobal( name );
      fi;
      UnbindGlobal( name );
      ASS_GVAR( name, TABLE_ACCESS_FUNCTIONS[2].( name ) );
    od;
end;

RestoreTableAccessFunctions := function()
    local name;

    if TABLE_ACCESS_FUNCTIONS[1] = rec() then
      Print( "cannot restore without saving!\n" );
      return;
    fi;

    for name in RecNames( TABLE_ACCESS_FUNCTIONS[2] ) do
#     MakeReadWriteGlobal( name );
      UnbindGlobal( name );
      ASS_GVAR( name, TABLE_ACCESS_FUNCTIONS[1].( name )[1] );
      if Length( TABLE_ACCESS_FUNCTIONS[1].( name ) ) = 2 then
        MakeReadOnlyGlobal( name );
      fi;
      Unbind( TABLE_ACCESS_FUNCTIONS[1].( name ) );
    od;

    Print( "#I  after restore!\n" );
end;

CharacterTableInfoByScanningLibraryFiles := function()
    local filenames, result, name;

    # Remember the names of all character table library files.
    filenames:= LIBLIST.files;

    # Initialize the result.
    result:= rec();

    # Change the functions used in the table library files appropriately.
    SaveTableAccessFunctions();
    MOT:= function( arg )
      local record;
      record:= rec( InfoText := arg[2],
                    SizesCentralizers := arg[3],
              #     ComputedPowerMaps := arg[4],
              #     Irr:= arg[5],
              # otherwise GAP explodes ...
                    AutomorphismsOfTable := arg[6] );
      if IsBound( arg[7] ) then
        record.ConstructionInfoCharacterTable:= arg[7];
      fi;
      result.( arg[1] ):= record;
    end;

    ARC:= function( arg )
      if   arg[2] = "maxes" then
        result.( arg[1] ).Maxes:= arg[3];
      fi;
    end;

    # Loop over the library files.
    for name in filenames do

      Print( "#I  processing file ", name, ".tbl\n" );
      ReadTbl( Concatenation( name, ".tbl" ) );

    od;

    # Restore the ordinary table library access.
    RestoreTableAccessFunctions();

    # Return the result.
    return result;
end;


##############################################################################
##
#V  CharacterTableInfo
##
CharacterTableInfo := CharacterTableInfoByScanningLibraryFiles();


CharacterTableInfoRecord := function( name )
    local comp, other, pos;

    if name = "L2(7)" then
      name:= "L3(2)";
    fi;

    # Adjust relative info if necessary.
    comp:= CharacterTableInfo.( name );
    if comp.SizesCentralizers = 0 then

      if IsBound( comp.ConstructionInfoCharacterTable )
         and IsList( comp.ConstructionInfoCharacterTable )
         and comp.ConstructionInfoCharacterTable[1] in
                [ "ConstructDirectProduct", "ConstructIsoclinic" ]
         and Length( comp.ConstructionInfoCharacterTable[2] ) = 1
         and Length( comp.ConstructionInfoCharacterTable[2][1] ) = 1
         and IsString( comp.ConstructionInfoCharacterTable[2][1][1] ) then
        other:= LibInfoCharacterTable(
                    comp.ConstructionInfoCharacterTable[2][1][1] ).firstName;
        if IsBound( CharacterTableInfo.( other ) ) then
          other:= CharacterTableInfo.( other );
          comp.SizesCentralizers:= other.SizesCentralizers;
Print( "transfer from ", comp.ConstructionInfoCharacterTable[2][1],
       " to ", name, "\n" );
        fi;
      fi;
      if comp.SizesCentralizers = 0 then
Print( "hard test for ", name, "\n" );
        other:= CharacterTable( name );
        comp.SizesCentralizers:= SizesCentralizers( other );
#T also for direct products of several tables,
#T get the centralizers as Kronecker products!
#T (be careful about possible class permutations!
      fi;

    fi;

    # Get the fusion info.
    pos:= Position( LIBLIST.firstnames, name );
    if pos = fail then
      Error( "<name> is not valid" );
    fi;
    comp.NamesOfFusionSources:= LIBLIST.fusionsource[ pos ];
    comp.NamesOfFusionDestinations:= LIBLIST.firstnames{
          Filtered( [ 1 .. Length( LIBLIST.firstnames ) ],
              i -> name in LIBLIST.fusionsource[i] ) };

    return comp;
end;


##############################################################################
##
#F  IsNameOfAtlasCharacterTable( <name> )
##
IsNameOfAtlasCharacterTable := function( name )
    if not IsBound( CharacterTableInfo.( name ) ) then
      return false;
    fi;
    name:= CharacterTableInfo.( name );
    if name.InfoText = 0 then
      return false;
    else
      return ForAny( name.InfoText,
        line -> PositionSublist( line, "origin: ATLAS of finite groups" )
                    <> fail );
    fi;
end;


##############################################################################
##
##  2. Configuration Data
##


##############################################################################
##
#V  HTMLGroupInfoFilesGlobals
##
HTMLGroupInfoFileGlobals := rec(
    titlestring := "Character Table Info for a Group",
    commonheading := "GAP Character Table Library"
    );


##############################################################################
##
#V  HTMLViewsGlobals
##
##  \beginitems
##  `documents' &
##      the list of names of those character tables for which a document
##      exists
##  \enditems
##
HTMLViewsGlobals := rec(
    commonheading := "GAP Character Table Library",
#    maxsimplesize := 2^120*3^13*5^5*7^4*11^2*13^2*17^2*19*31^2*41*43*73*127*151*241*331
    maxsimplesize := 10^9,
    documents := Union( Filtered( RecNames( CharacterTableInfo ),
                                  IsNameOfAtlasCharacterTable ),
                        AllCharacterTableNames( IsSimple, true ) )
# (for ATLAS tables, DecMatName works!)
# eventually, here I want to include all nearly simple groups!!
    );


ExistsDocumentForName := function( name )
    return name in HTMLViewsGlobals.documents;
end;


NameWithLink:= function( name )
    local str;

    if name = "L2(7)" then
      name:= "L3(2)";
    fi;
    if not ExistsDocumentForName( name ) then
      return name;
    fi;
#T improve names ??
#T use the translation at least for simple groups
    str:= "";
    Append( str, Concatenation( "<a href=\"../data/", name, ".html\">" ) );
    Append( str, DecMatName( name, "HTML" ) );
    Append( str, "</a>" );
    return str;
end;


##############################################################################
##
##  4. Functions to Create the Individual Files
##


##############################################################################
##
#F  HTMLMaxesInfoTable( <groupname> )
##
##  Let <groupname> be the name of a group for whose character table the
##  character tables of maximal subgroups are contained in the {\GAP}
##  character table library.
##  `HTMLMaxesInfoTable' returns a string describing an HTML table
##  looking similar to the list of maximal subgroups in the
##  {\ATLAS} of Finite Groups.
##
HTMLMaxesInfoTable := function( groupname )
    local tbl, size, matrix, i, max;

    # Get the tables of the maxes.
    tbl:= CharacterTableInfoRecord( groupname );

    if not IsBound( tbl.Maxes ) then
      return "";
    fi;
    size:= tbl.SizesCentralizers[1];

    matrix:= [ [ "Order", "Index", "Name" ] ];

    # Loop over the maxes.
    for i in [ 1 .. Length( tbl.Maxes ) ] do
      max:= CharacterTableInfoRecord( tbl.Maxes[i] );
      Add( matrix, [ String( max.SizesCentralizers[1] ),
                     String( size / max.SizesCentralizers[1] ),
                     NameWithLink( tbl.Maxes[i] ) ] );
    od;

    return HTMLStandardTable( matrix, [ "right", "right", "left" ] );
end;


##############################################################################
##
#F  HTMLSylowNormalizerInfoTable( <groupname> )
##
##  Let <groupname> be the name of a group for whose character table at least
##  one character table of a Sylow normalizer is contained in the {\GAP}
##  character table library.
##  `HTMLSylowNormalizerInfoTable' returns a string describing an HTML table.
##
HTMLSylowNormalizerInfoTable := function( groupname )
    local tbl, known, p, firstname, size, matrix, i, sylno;

    # Get the tables of the known Sylow normalizers.
    tbl:= CharacterTableInfoRecord( groupname );
    known:= [];
    for p in Set( Factors( tbl.SizesCentralizers[1] ) ) do
      firstname:= LibInfoCharacterTable(
          Concatenation( groupname, "N", String( p ) ) );
      if firstname <> fail then
        Add( known, [ p, firstname.firstName ] );
      fi;
    od;
    if IsEmpty( known ) then
      return "";
    fi;

    size:= tbl.SizesCentralizers[1];

    matrix:= [ [ "Prime", "Order", "Index", "Name" ] ];

    # Loop over the known Sylow normalizers.
    for i in [ 1 .. Length( known ) ] do
      sylno:= CharacterTableInfoRecord( known[i][2] );
      Add( matrix, [ String( known[i][1] ),
                     String( sylno.SizesCentralizers[1] ),
                     String( size / sylno.SizesCentralizers[1] ),
                     NameWithLink( known[i][2] ) ] );
    od;
    return HTMLStandardTable( matrix, [ "right", "right", "right", "left" ] );
end;


##############################################################################
##
#F  HTMLFromFusionsInfoTable( <groupname> )
##
##  Let <groupname> be the name of a group whose character table
##  is contained in the {\GAP} character table library.
##  `HTMLFromFusionsInfoTable' returns a string describing an HTML table
##  listing the names of all those tables to which the table of
##  <groupname> stores fusions.
##
HTMLFromFusionsInfoTable := function( groupname )
    local tbl, matrix, name;

    # Get the fusion info.
    tbl:= CharacterTableInfoRecord( groupname );

    if IsEmpty( tbl.NamesOfFusionDestinations ) then
      return "";
    fi;

    matrix:= [ [ "Name" ] ];
#T add a ``Status'' column!
#T (unique, up to t.a., ...)

    # Loop over the fusions.
    for name in tbl.NamesOfFusionDestinations do
      Add( matrix, [ NameWithLink( name ) ] );
    od;

    return HTMLStandardTable( matrix, [ "left" ] );
end;


##############################################################################
##
#F  HTMLToFusionsInfoTable( <groupname> )
##
##  Let <groupname> be the name of a group whose character table
##  is contained in the {\GAP} character table library.
##  `HTMLIntoFusionsInfoTable' returns a string describing an HTML table
##  listing the names of all those tables storing fusions to the
##  table of <groupname>.
##
HTMLToFusionsInfoTable:= function( groupname )
    local tbl, matrix, name;

    # Get the fusion info.
    tbl:= CharacterTableInfoRecord( groupname );

    if IsEmpty( tbl.NamesOfFusionSources ) then
      return "";
    fi;

    matrix:= [ [ "Name" ] ];

    # Loop over the fusions.
    for name in tbl.NamesOfFusionSources do
      Add( matrix, [ NameWithLink( name ) ] );
    od;
    return HTMLStandardTable( matrix, [ "left" ] );
end;


##############################################################################
##
#F  TableDatabaseInfo( <groupname> )
##
##  Let <groupname> the `Identifier' component of a character table $t$
##  in the {\GAP} character table library.
##  `TableDatabaseInfo' returns a list of pairs `[ <descr>, <val> ]'
##  where <descr> is a string describing an attribute of $t$
##  and <val> the corresponding value.
##
##  The return value is used in the function `HTMLCreateGroupInfoFile'.
##
TableDatabaseInfo := function( groupname )
    local list, tbl, order;

    list:= [];

    tbl:= CharacterTableInfoRecord( groupname );

    # The group order shall be displayed as number and in factored form.
    Add( list, [ "Group Order",
                 Concatenation( String( tbl.SizesCentralizers[1] ),
                                " = ",
                                HTMLFactoredNumber( tbl.SizesCentralizers[1] ) ) ] );

    # The number of classes shall be displayed.
    Add( list, [ "Number of Classes",
                 String( Length( tbl.SizesCentralizers ) ) ] );

    # The `InfoText' value shall be displayed.
    if tbl.InfoText <> 0 then
      Add( list, [ "InfoText Value",
                   ReplacedString( Concatenation( tbl.InfoText ),
                       "\n", "\n<br />\n" ) ] );
    fi;
#T if the group is simple, list also the links in the dec.mat. database!

    # If all tables of maxes are available then they shall be displayed.
    if IsBound( tbl.Maxes ) then
      Add( list, [ "Maximal subgroups", HTMLMaxesInfoTable( groupname ) ] );
    fi;

    # If at least one table of a Sylow normalizer is known then
    # a table of corresponding info is displayed.
    order:= tbl.SizesCentralizers[1];
    if ForAny( Set( Factors( order ) ),
           p -> LibInfoCharacterTable( Concatenation( groupname, "N",
                    String( p ) ) ) <> fail ) then
      Add( list, [ "Stored Sylow Normalizers",
                   HTMLSylowNormalizerInfoTable( groupname ) ] );
    fi;

    # The fusions on this table shall be mentioned.
    if not IsEmpty( tbl.NamesOfFusionDestinations ) then
      Add( list, [ "Stored class fusions from this table",
                   HTMLFromFusionsInfoTable( groupname ) ] );
    fi;

    # The fusions to this table shall be mentioned.
    if not IsEmpty( tbl.NamesOfFusionSources ) then
      Add( list, [ "Stored class fusions to this table",
                   HTMLToFusionsInfoTable( groupname ) ] );
    fi;

    # Return the result.
    return list;
end;


##############################################################################
##
#F  HTMLCreateGroupInfoFile( <groupname> )
##
##  `HTMLCreateGroupInfoFile' creates the HTML file with name
##  `<groupname>.html' that displays the info for the {\GAP} character table
##  with `Identifier' value <groupname>.
##  The information returned by `TableDatabaseInfo' is used,
##  each entry being translated into an entry of a HTML definition list.
##
HTMLCreateGroupInfoFile := function( groupname )
    local str, pair;

    # Create the header string.
    str:= HTMLHeader( HTMLGroupInfoFileGlobals.titlestring,
                      HTMLGroupInfoFileGlobals.commonheading,
                      Concatenation( "Character Table Info for ",
                                     DecMatName( groupname, "HTML" ) ) );

    # Get the character table info, and store it in a definition list.
    Append( str, "<dl>\n" );
    for pair in TableDatabaseInfo( groupname ) do

      # Append the info component.
      Append( str, "<dt>\n" );
      Append( str, pair[1] );
      Append( str, ":\n" );
      Append( str, "</dt>\n" );
      Append( str, "<dd>\n<p>\n" );
      Append( str, pair[2] );
      Append( str, "\n</p>\n</dd>\n\n" );

    od;

    Append( str, "</dl>\n" );

    # Append the footer string.
    Append( str, HTMLFooter() );

    # Create the file.
    PrintToIfChanged( Concatenation( "data/", groupname, ".html" ), str );
end;


##############################################################################
##
#V  HTMLCreateView
##
HTMLCreateView := rec();


##############################################################################
##
#F  HTMLCreateView.allbyorder()
##
##  This view lists the names of all character tables in the GAP table library
##  according to their group orders.
##
##  If a document for the character table is available in {\GAP} then the
##  table name appears as a link to the document for this table.
##
HTMLCreateView.allbyorder := function()
    local str, tables, sizes, name, matrix, i;

    # Create the header string.
    str:= HTMLHeader( "All GAP Table Names by Group Order",
                      HTMLGroupInfoFileGlobals.commonheading,
                      "All GAP Table Names by Group Order" );

#T add an explanatory text here!!

    # Compute the list of character table names in the {\GAP} table library,
    # and get the group orders.
    tables:= AllCharacterTableNames();
    sizes:= [];
    for name in tables do
      Add( sizes, CharacterTableInfoRecord( name ).SizesCentralizers[1] );
    od;
    SortParallel( sizes, tables );

    # Loop over the tables, and enter the names into a table.
    matrix:= [];
    for i in [ 1 .. Length( sizes ) ] do
      Add( matrix, [ NameWithLink( tables[i] ),
                     String( sizes[i] ),
                     HTMLFactoredNumber( sizes[i] ) ] );
    od;
    Append( str, HTMLStandardTable( matrix, [ "left", "right", "left" ] ) );

    # Append the footer string.
    Append( str, HTMLFooter() );

    # Create the file.
    PrintToIfChanged( "views/allbyorder.html", str );
end;


##############################################################################
##
#F  HTMLCreateView.simplebyorder()
##
##  This view lists *all* simple groups (not only those whose tables are
##  available in the {\GAP} table library) up to the order
##  `HTMLViewsGlobals.maxsimplesize',
##  together with their group orders and its factored form.
##  (This is similar to the list shown in the ATLAS of Finite Groups on
##  pages~239--242.)
##
##  If a document for the character table is available in {\GAP} then the
##  table name appears as a link to the document for this table.
##
HTMLCreateView.simplebyorder := function()
    local str, sizes, matrix, pair;

    # Create the header string.
    str:= HTMLHeader( "Simple Groups by Group Order",
                      HTMLGroupInfoFileGlobals.commonheading,
                      "Simple Groups by Group Order" );

#T add an explanatory text here!!

    # Compute the list of all simple groups up to the prescribed order.
    sizes:= SizesSimpleGroupsInfo( HTMLViewsGlobals.maxsimplesize );

    # Loop over the orders, and enter the groups into a table.
    matrix:= [];
    for pair in sizes do
      Add( matrix, [ NameWithLink( pair[2] ),
                     String( pair[1] ),
                     HTMLFactoredNumber( pair[1] ) ] );
    od;
    Append( str, HTMLStandardTable( matrix, [ "left", "right", "left" ] ) );

    # Append the footer string.
    Append( str, HTMLFooter() );

    # Create the file.
    PrintToIfChanged( "views/simplebyorder.html", str );
end;


##############################################################################
##
#E

