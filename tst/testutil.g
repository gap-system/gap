#############################################################################
##
#W  testutil.g                  GAP Library                     Thomas Breuer
#W                                                               Frank Celler
##
##
#Y  Copyright (C) 2005 The GAP Group
##
##  This file contains utilities for running tests.
##  It is not read with the library when {\GAP} is started.
##

#############################################################################
##
#F  RunStandardTests( <testfiles>[, <renormalize>] )
##
##  Let <testfiles> be a list of pairs consisting of a file name, relative to
##  the `tst' directory of the {\GAP} distribution, and a scaling factor
##  that is proportional to the expected runtime when the file is read with
##  `Test'.
##  `RunStandardTests' applies `Test' to the files listed in <testfiles>,
##  in increasing order of the expected runtime,
##  such that the differences between the actual output and the one that is
##  prescribed in the test files are printed.
##  Additionally, information about the file currently being read and the
##  runtime is printed.
##
##  If a second argument `true' is given, the scaling factors in the
##  processed files are replaced by $10^5$ times the runtime in milliseconds.
##  Of course this runtime depends on the hardware, so this renormalization
##  should be executed on a ``typical'' machine, which should fit to the
##  information in the files `tst/testall.g' and `tst/testinstall.g' and 
##  in the documentation file `doc/ref/install.xml'.
##
BindGlobal( "RunStandardTests", function( arg )
    local testfiles, renormalize, sizescreen, stop_TEST, infoRead1,
          infoRead2, count, totaltime, totalprev, prod, dir, i, name, info,
          time, stone, new, oldcontents, pos, newcontents;

    # Get and check the arguments.
    if Length( arg ) = 0 or Length( arg ) > 2 or not IsList( arg[1] ) then
      Error( "usage: RunStandardTests( <testfiles>[, <renormalize>] )" );
    fi;
    testfiles:= arg[1];
    renormalize:= Length( arg ) = 2 and arg[2] = true;

    # Initialize variables that must be global.
    GAPInfo.TestData:= rec( results:= [] );
    sizescreen:= SizeScreen();

    # Replace the `STOP_TEST' function by one that collects statistical data.
    stop_TEST := STOP_TEST;
    STOP_TEST := function( file, fac )
      Add( GAPInfo.TestData.results,
           [ file, fac, Runtime() - GAPInfo.TestData.START_TIME ] );
    end;

    # Print a header.
    Print( "Architecture: ", GAPInfo.Architecture, "\n\n",
           "test file         GAP4stones     time(msec)\n",
           "-------------------------------------------\n" );

    # Switch off info messages during the tests.
    infoRead1 := InfoRead1;  InfoRead1 := Ignore;
    infoRead2 := InfoRead2;  InfoRead2 := Ignore;

    # Loop over the test files.
    count:= 0;
    totaltime:= 0;
    totalprev:= 0;
    prod:= 1;
    dir:= DirectoriesLibrary( "tst" );
    testfiles:= ShallowCopy( testfiles );
    Sort( testfiles, function( a, b ) return a[2] < b[2]; end );
    for i in [ 1 .. Length( testfiles ) ]  do
      name:= Filename( dir, testfiles[i][1] );
      Print( "testing: ", name, "\n" );
      Test( name );
      if Length( GAPInfo.TestData.results ) < i then
        Print( "#E  Add a `STOP_TEST' command to the file `", name, "'!\n" );
        GAPInfo.TestData.results[i]:= "dummy";
      else
        info:= GAPInfo.TestData.results[i];
        if info[1] <> testfiles[i][1] then
          Print( "#E  Replace `", info[1],
                 "' in the `STOP_TEST' command of `", name, "'!\n" );
        fi;
        time:= info[3];
        if 100 < time and IsPosRat(info[2]) then
          count:= count + 1;
          totaltime:= totaltime + time;
          totalprev:= totalprev + info[2];
          stone := QuoInt( info[2], time );
          prod:= prod * stone;
        else
          stone := 0;
        fi;
        Print( FormattedString( testfiles[i][1], -20 ),
               FormattedString( stone, 8 ),
               FormattedString( time, 15 ) );
        if i < Length( testfiles ) and IsPosRat( testfiles[i+1][2] )
           and totalprev <> 0  then
          Print( "    (next ~ ",
                 Int( totaltime * testfiles[i+1][2] / 10^3 / totalprev ),
                 " sec)" );
        fi;
        Print( "\n" );

        if renormalize then
          new:= 10^5 * time;
          if info[2] = infinity or
             ( info[2] <> 0 and
               ( ( new >= info[2] and new / info[2] < 105/100 ) or
                 ( new <= info[2] and new / info[2] >  95/100 ) ) ) then
            Print( "#I  scaling factor in `", name, "' unchanged\n" );
          else
            oldcontents:= StringFile( name );
            pos:= PositionSublist( oldcontents, "STOP_TEST" );
            newcontents:= oldcontents{ [ 1 .. pos-1 ] };
            Append( newcontents, "STOP_TEST( \"" );
            Append( newcontents, testfiles[i][1] );
            Append( newcontents, "\", " );
            Append( newcontents, String( new ) );
            Append( newcontents, " );" );
            pos:= PositionSublist( oldcontents, ";", pos );
            Append( newcontents,
                    oldcontents{ [ pos + 1 .. Length( oldcontents ) ] } );

            # Save the old file, and print a new file.
            Exec( Concatenation( "mv ", name, " ", name, "~" ) );
            SizeScreen( [ 1000 ] );
            PrintTo( name, newcontents );
            Print( "#I  `", name, "' replaced:\n" );
            SizeScreen( sizescreen );
            Exec( Concatenation( "diff ", name, "~ ", name ) );
          fi;
        fi;
      fi;
    od;

    # Print statistics information.
    Print("-------------------------------------------\n");
    if count = 0 then
      count:= 1;
    fi;
    Print( "total",
           FormattedString( RootInt( prod, count ), 23 ),
           FormattedString( totaltime, 15 ), "\n\n" );

    # Reset the changed globals.
    InfoRead1 := infoRead1;
    InfoRead2 := infoRead2;
    STOP_TEST := stop_TEST;
    GAPInfo.TestData:= rec();
    end );


#############################################################################
##
#F  ExtractManualExamples( <bookname> )
##
##  <bookname> is either ref or tut. 
##  The function should be called EXACTLY from the GAP root directory.
## 
LoadPackage("gapdoc");
ExtractManualExamples:=function( bookname )
local path, main, files, tst, i, s, name, output;
if bookname="tut" then
  files:=[];
elif bookname="ref" then
  Read( "doc/ref/makedocreldata.g" );
  files:= GAPInfo.ManualDataRef.files;
else
  Error( "RunManualsTest : the argument bust be \"ref\" or \"tut\"" );
fi;
path:=Directory( Concatenation( GAPInfo.RootPaths[1], "doc/", bookname ) );
main:="main.xml";
Print("===============================================================\n");
Print("Extracting manual examples from the book '", bookname, "'\n" );
Print("===============================================================\n");
tst:=ManualExamples( path, main, files, "Chapter" );
for i in [ 1 .. Length(tst) ] do 
  Print("Processing '", bookname, "' chapter number ", i, " of ", Length(tst), "\c" );
  if Length( tst[i] ) > 0 then
    s := String(i);
    if Length(s)=1 then 
      # works for <100 chapters
      s:=Concatenation("0",s); 
    fi;
    name := Filename( Directory( Concatenation( "doc/test/", bookname ) ), Concatenation( bookname, s, ".tst" ) );
    output := OutputTextFile( name, false ); # to empty the file first
    SetPrintFormattingStatus( output, false ); # to avoid line breaks
    PrintTo( output, tst[i] );
    CloseStream(output);
    # one superfluous check
    if tst[i] <> StringFile( name ) then
      Error("Saved file does not match original examples string!!!\n");  
    else
      Print(" - OK! \n" );
    fi;
  else
    Print(" - no examples to save! \n" );    
  fi;  
od;
Print("===============================================================\n");
end;


#############################################################################
##
#F  CreateTestinstallFile( )
##
##  replaces the file `tst/testinstall.g' by a file that reflects the current
##  contents of the `tst' directory, that is, all those files in `tst/*.tst'
##  are listed that contain the substring `To be listed in testinstall.g';
##  the scaling factors in the `STOP_TEST' calls in the files are inserted
##  in the list entries.
##
##
BindGlobal( "CreateTestinstallFile", function( )
    local dir, oldfile, oldcontents, pos, newcontents, error, name, file,
          filecontents, stoppos, stonepos;

    dir:= DirectoriesLibrary( "tst" );
    oldfile:= Filename( dir, "testinstall.g" );
    if oldfile = fail then
      Error( "no file `testinstall.g' found" );
    fi;
    oldcontents:= StringFile( oldfile );
    pos:= PositionSublist( oldcontents, "RunStandardTests( [" );
    if pos = fail then
      Print( "#E  no substring `RunStandardTests( [' in `testinstall.g'\n" );
      return false;
    fi;

    newcontents:= oldcontents{ [ 1 .. pos-1 ] };
    Append( newcontents, "RunStandardTests( [\n" );
    error:= false;
    for name in SortedList( DirectoryContents( Filename( dir, "" ) ) ) do
      if 4 < Length( name )
         and name{ [ Length( name ) - 3 .. Length( name ) ] } = ".tst" then
        file:= Filename( dir, name );
        filecontents:= StringFile( file );
        if PositionSublist( filecontents, "To be listed in testinstall.g" )
           <> fail then
          if PositionSublist( filecontents, "START_TEST" ) = fail then
            error:= true;
            Print( "#E  no `START_TEST' in `", file, "'\n" );
          else
            stoppos:= PositionSublist( filecontents, "STOP_TEST" );
            if stoppos = fail then
              error:= true;
              Print( "#E  no `STOP_TEST' in `", file, "'\n" );
            elif filecontents{ [ stoppos+12 .. stoppos+12+Length( name ) ] }
                 <> Concatenation( name, "\"" ) then
              error:= true;
              Print( "#E  corrupted `STOP_TEST' command in `", file, "'\n" );
            else
              stonepos:= PositionSublist( filecontents, ");", stoppos );
              Append( newcontents, "  [" );
              Append( newcontents,
                      filecontents{ [ stoppos+10 .. stonepos-1 ] } );
              Append( newcontents, "],\n" );
            fi;
          fi;
        fi;
      fi;
    od;
    if error then
      return false;
    fi;
    Append( newcontents, "] )" );

    # Append the part behind the list.
    pos:= Position( oldcontents, ';', pos );
    if pos = fail then
      Print( "#E  no semicolon behind the list in `testinstall.g'\n" );
      return false;
    fi;
    Append( newcontents, oldcontents{ [ pos .. Length( oldcontents ) ] } );

    if oldcontents = newcontents then
      Print( "#I  `testinstall.g' unchanged\n" );
    else
      # Save the old file as `testinstall.g~', and print a new `testinstall.g'.
      Exec( Concatenation( "mv ", oldfile, " ", oldfile, "~" ) );
      PrintTo( oldfile, newcontents );
      Print( "#I  `testinstall.g' replaced:\n" );
      Exec( Concatenation( "diff ", oldfile, "~ ", oldfile ) );
    fi;
    return true;
    end );


#############################################################################
##
#F  CreatePackageTestsInput( <scriptfile>, <outfile>, <gap>, <other> )
##
##  writes the file <scriptfile> that starts a new GAP session using the
##  command <gap> (including all command line options) for each test file
##  of a package (given by the component `TestFile' in the record stored in
##  its `PackageInfo.g' file) and reads this file. The output of all tests 
##  is collected in the files <outfile>.<packagename>
##  GAP} is started as <gap> (including all command line options).
##  <other> may be true, false or "auto" to specify whether all available
##  packages are loaded, not loaded or only autoloaded packages. This mode
##  is actually managed in the Makefile, and is passed to this function 
##  just to be printed in the information messages.
##
BindGlobal( "CreatePackageTestsInput", function( scriptfile, outfile, gap, other )
    local result, name, entry, pair, testfile;

    SizeScreen( [ 1000 ] );
    InitializePackagesInfoRecords( false );
    result:= "";
    
    Append( result, "TIMESTAMP=`date -u +_%Y-%m-%d-%H-%M`\n" );

    for name in SortedList(ShallowCopy(RecNames(GAPInfo.PackagesInfo))) do 
      for entry in GAPInfo.PackagesInfo.( name ) do
        if IsBound( entry.InstallationPath ) and IsBound( entry.TestFile ) then
          testfile := Filename( DirectoriesPackageLibrary( name, "" ), entry.TestFile );
          if testfile <> fail then
            Append( result, Concatenation(
                    "echo 'Testing ", name, " ", entry.Version, ", test=", 
		            testfile, ", all packages=", other, "'\n" ) );
            Append( result, Concatenation( "echo ",
                    "'============================OUTPUT START=============================='",
                    " > ", outfile, "$TIMESTAMP.", name, "\n" ) );
            Append( result, Concatenation(
                    "echo 'SetUserPreference(\"UseColorsInTerminal\",false); ",
                    "RunPackageTests( \"", name,
                    "\", \"", entry.Version, "\", \"", entry.TestFile,
                    "\", \"", other, "\" );' | ", gap, 
                    " >> ", outfile, "$TIMESTAMP.", name, "\n" ) );
            Append( result, Concatenation( "echo ",
                    "'============================OUTPUT END================================'",
                    " >> ", outfile, "$TIMESTAMP.", name, "\n" ) );
          else
            Append( result, Concatenation(
                    "echo 'failed to find test files for the ", name, " package'\n") );
          fi;            
        fi;
      od;
    od;

    PrintTo( scriptfile, result );
    end );


#############################################################################
##
#F  RunPackageTests( <pkgname>, <version>, <testfile>, <other> )
##
##  loads the package <pkgname> in version <version>,
##  and reads the file <testfile> (a path relative to the package directory).
##  If <other> is `true' then all other available packages are also loaded.
##
##  The file <testfile> can either be a file that contains `ReadTest'
##  or `Test' statements and therefore must be read with `Read',
##  or it can be a file that itself must be read with `Test';
##  the latter is detected from the occurrence of a substring
##  `"START_TEST"' in the file.
##
BindGlobal( "RunPackageTests", function( pkgname, version, testfile, other )
    local file, PKGTSTHDR, str;

    if LoadPackage( pkgname, Concatenation( "=", version ) ) = fail then
      Print( "#I  RunPackageTests: package `",
             pkgname, "' (version ", version, ") not loadable\n" );
      return;
    fi;
    if other = "true" then
      LoadAllPackages();
    fi;
    PKGTSTHDR := Concatenation( "\"", pkgname, "\", \"", version, "\", \"",
           testfile, "\", ", other );
    Print( "#I  RunPackageTests(", PKGTSTHDR, ");\n" );
    ShowSystemInformation();
    file:= Filename( DirectoriesPackageLibrary( pkgname, "" ), testfile );
    str:= StringFile( file );
    if not IsString( str ) then
      Print( "#I  RunPackageTests: file `", testfile, "' for package `",
             pkgname, "' (version ", version, ") not readable\n" );
      return;
    fi;
    if PositionSublist( str, "gap> START_TEST(" ) = fail then
      if not READ( file ) then
        Print( "#I  RunPackageTests: file `", testfile, "' for package `",
               pkgname, "' (version ", version, ") not readable\n" );
      fi;
    else
      if not Test( file, rec(compareFunction := "uptowhitespace") ) then
        Print( "#I  Errors detected while testing package ", pkgname, " ", version, "\n",
               "#I  using the test file `", testfile, "'\n");
      else
        Print( "#I  No errors detected while testing package ", pkgname, " ", version, "\n",
               "#I  using the test file `", testfile, "'\n");
      fi;
    fi;

    Print( "#I  RunPackageTests(", PKGTSTHDR, "): runtime ", Runtime(), "\n" );
    end );


#############################################################################
##
#F  CreatePackageLoadTestsInput( <scriptfile>, <outfileprefix>, <gap>, 
##                               <autoload>, <onlyneeded> )
##
##  Writes the file <scriptfile> that tests loading each package
##
BindGlobal( "CreatePackageLoadTestsInput", 

	function( scriptfile, outfileprefix, gap, autoload, onlyneeded )

    local mode, smode, PKGLOADTSTOPT, result, name, entry, packagenames;

    SizeScreen( [ 1000 ] );
    InitializePackagesInfoRecords( false );
    result:= "";
    
    mode:="";
    PKGLOADTSTOPT:="";
    if autoload then 
		Append( mode, " with autoloaded" );
	else	
		Append( mode, "                " );
	fi;	
    if onlyneeded then 
		Append( mode, ", only needed" );
		PKGLOADTSTOPT:=":OnlyNeeded";
	fi;	
	smode := NormalizedWhitespace(mode);
	if Length(smode) > 0 and smode[1] <> ' ' then
	  smode:=Concatenation( " ", smode );
    fi;
    
    packagenames := ShallowCopy( RecNames( GAPInfo.PackagesInfo ) );
    Sort( packagenames );
    
    Append( result, "TIMESTAMP=`date -u +_%Y-%m-%d-%H-%M`\n" );
    
    for name in packagenames do
        for entry in GAPInfo.PackagesInfo.( name ) do
            Append( result, "echo '==========================================='\n" );
            Append( result, 
              Concatenation( "echo '%%% Loading ", name, " ", entry.Version, smode, "'\n" ) );
            Append( result, 
              Concatenation( 
                "echo 'SetUserPreference(\"UseColorsInTerminal\",false); ",
                "PKGLOADTSTRES:=LoadPackage(\"", name, "\"", PKGLOADTSTOPT, ");;",
                "Filtered(NamesUserGVars(),x->IsLowerAlphaChar(x[1]) or Length(x)<=3);",
                "if PKGLOADTSTRES=true then PKGLOADTSTRES:=\"### Loaded\"; ",
                "else PKGLOADTSTRES:=\"### Not loaded\"; fi;",
                "Print( PKGLOADTSTRES, \" \",\"", name, "\",\" \",\"", 
                 entry.Version, smode, "\");", 
                "Print([CHAR_INT(10)]);' | ", 
                gap, " > ", outfileprefix, "$TIMESTAMP.", name, " 2>&1 \n" ) );
            Append( result, 
                Concatenation( "cat ", outfileprefix, "$TIMESTAMP.", name, "\n" ) );
         od;
    od;
    Append( result, "echo '==========================================='\n" );
    
    # do not test LoadAllPackages with OnlyNeeded option
    if not onlyneeded then    
        Append( result, Concatenation("echo '\n======OUTPUT START: LoadAllPackages", mode, "'\n" ) );
        Append( result, 
            Concatenation( "echo 'SetUserPreference(\"UseColorsInTerminal\",false); ",
                           "if CompareVersionNumbers( GAPInfo.Version, \"4.5.0\") then ",
                           "SetInfoLevel(InfoPackageLoading,4);",
                           "fi;LoadAllPackages(", PKGLOADTSTOPT, "); ",
                           "Print([CHAR_INT(10)]); ",
                           "Print(\"### all packages loaded                 ", mode, "\"); ' | ",  
                           gap, " > ", outfileprefix, "$TIMESTAMP.all 2>&1 \n" ) );
        Append( result, 
            Concatenation( "cat ", outfileprefix, "$TIMESTAMP.all\n" ) );
        Append( result, 
            Concatenation("echo '\n======OUTPUT END: LoadAllPackages", mode, "'\n" ) );
        Append( result, "echo '==========================================='\n" );
        Append( result, 
            Concatenation("echo '\n======OUTPUT START: LoadAllPackages ",
                          "in the reverse order", mode, "'\n" ) );
        if PKGLOADTSTOPT="" then
      	    PKGLOADTSTOPT:=":reversed";
        else
      	    PKGLOADTSTOPT:=":OnlyNeeded,reversed";
        fi;
        Append( result, 
            Concatenation( "echo 'SetUserPreference(\"UseColorsInTerminal\",false); ",
                           "if CompareVersionNumbers( GAPInfo.Version, \"4.5.0\") then ",
                           "SetInfoLevel(InfoPackageLoading,4);",
                           "fi;LoadAllPackages(", PKGLOADTSTOPT, "); ",
                           "Print([CHAR_INT(10)]); ",
                           "Print(\"### all packages loaded in reverse order", mode, "\"); ' | ", 
                           gap, " > ", outfileprefix, "$TIMESTAMP.all 2>&1 \n" ) );
        Append( result, 
            Concatenation( "cat ", outfileprefix, "$TIMESTAMP.all\n" ) );
        Append( result, 
            Concatenation("echo '\n======OUTPUT END: LoadAllPackages ",
                          "in the reverse order", mode, "'\n" ) );
    fi;         
    
    Append( result, Concatenation( "rm ", outfileprefix, "$TIMESTAMP.*\n" ) );
    PrintTo( scriptfile, result );
    end );
    
    
#############################################################################
##
#F  CreatePackageVarsTestsInput( <scriptfile>, <outfileprefix>, <gap> )
##
##  Writes the file <scriptfile> that calls ShowPackageVariables 
##  for each package in a new GAP session
##
BindGlobal( "CreatePackageVarsTestsInput", 

	function( scriptfile, outfileprefix, gap )

    local result, name, entry, packagenames;

    SizeScreen( [ 1000 ] );
    InitializePackagesInfoRecords( false );
    result:= "";
        
    packagenames := ShallowCopy( RecNames( GAPInfo.PackagesInfo ) );
    Sort( packagenames );
    
    Append( result, "TIMESTAMP=`date -u +_%Y-%m-%d-%H-%M`\n" );
    
    for name in packagenames do
        for entry in GAPInfo.PackagesInfo.( name ) do
            Append( result, "echo '==========================================='\n" );
            Append( result, 
              Concatenation( "echo '### Checking variables in \"", name, "\", ver. ", 
                             entry.Version, "'\n" ) );
            Append( result, 
              Concatenation( 
                "echo 'ShowPackageVariables(\"", name, "\"", ");",
                "Print(\"### Variables checked for \\\"\",\"", name, "\\\"\",\", ver. \",\"", 
                 entry.Version, "\" );", 
                "Print([CHAR_INT(10)]);' | ", 
                gap, " > ", outfileprefix, "$TIMESTAMP.", name, " 2>&1 \n" ) );                
            Append( result, 
                Concatenation( "cat ", outfileprefix, "$TIMESTAMP.", name, "\n" ) );
         od;
    od;
    Append( result, "echo '==========================================='\n" );
    Append( result, Concatenation( "rm ", outfileprefix, "$TIMESTAMP.*\n" ) );
    PrintTo( scriptfile, result );
    end );
    

#############################################################################
##
#F  CreateDevUpdateTestInput( )
#F  RunDevUpdateTests( )
##
##  RunDevUpdateTests() extracts test from dev/Update files and runs them
##  in the current GAP session. CreateDevUpdateTestInput() is an auxiliary
##  function which returns the string with the tests. It may be used to
##  view the tests or print them to a file.
##
BindGlobal( "CreateDevUpdateTestInput",
    function()
    local dirname, file, f, filename, content, alltests, output, nr, line, teststart, testlines;
    dirname:= DirectoriesLibrary( "dev/Updates" );
    if dirname = fail then
      Error("Can not find the 'dev/Updates' directory. Note that it is a part of the\n",
            "development version of GAP and is not included in the GAP distribution\n");
    fi;

    alltests := [ ];
   
    # Exclude hidden files and directories. Sort to ensure the order is not system-dependent
    for file in SortedList( Filtered( DirectoryContents(dirname[1]), f -> f[1] <> '.' ) ) do
    filename := Filename( dirname, file );
    content := SplitString( StringFile( filename ), "\r\n");
    output := [ ];
    nr:=0;
    repeat
        nr := nr+1;
        if nr > Length(content) then
            break;
        fi;
        line := content[nr];
        if Length(line) > 0 then
            if line[1]='!' then
                if LowercaseString( ReplacedString( line, " ","")) = "!testcode" then
                    teststart := nr;
                    testlines := [];
                    repeat
                        nr := nr+1;
                        line := content[nr];
                        if Length(line) > 0 then
                            if line[1]='!' then
                                break;
                            elif not line[1]='%' then
                                Add( testlines, Concatenation(line,"\n") );
                            fi;
                        fi;
                    until false;
                    if Length( testlines ) > 0 then
                        Add(output, Concatenation( "# ", filename, ", line ", String(teststart), "\n") );
                        Append(output, testlines );
                        Add( output, "\n" );
                    fi;
                fi;
            fi;
        fi;
    until false;
    if Length(output) > 0 then 
      Add( output, "#######################\n#END\n");
      Add( alltests, [ filename, Concatenation( output ) ] );
    fi;  
    od;
    return alltests;
end);


BindGlobal( "RunDevUpdateTests",
    function()
    local tests, t, resfile, str;
    tests := CreateDevUpdateTestInput();
    SaveWorkspace("testdevupdate.wsp");    
    for t in tests do
        Print("Checking " , t[1],"\n");
        resfile := "TESTDEVUPDATEOUTPUT";
        FileString( "TESTDEVUPDATE", t[2] );
        Exec( Concatenation(
        "echo 'Test(\"TESTDEVUPDATE\");' | bin/gap.sh -b -r -A -q -L testdevupdate.wsp > ", resfile ));
        str := StringFile(resfile);
        Print(str);
    od;
    RemoveFile("testdevupdate.wsp");
    RemoveFile("TESTDEVUPDATE");
    RemoveFile(resfile);
end);

#############################################################################
##
#E

