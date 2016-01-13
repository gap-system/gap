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
#F  ExtractManualExamples( <bookname> )
##
##  <bookname> is either ref or tut. 
##  The function should be called EXACTLY from the GAP root directory.
## 
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
                    "ReadGapRoot( \"tst/testutil.g\" ); ",
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
##  The file <testfile> can either be a file that contains 
##  `Test' statements and therefore must be read with `Read',
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
#F  CheckOutputDelegations
##
##  A method to output an object may only delegate to another operation
##  which appears further right in the following list: Display, ViewObj,
##  PrintObj, DisplayString, ViewString, PrintString, String.
##
##  This function parses the code of all installed methods for these
##  operations and checks whether this rule is followed, and shortlists
##  methods that require further inspection. Since it may still report
##  some cases where it is safe to call a predecessor of an operations
##  for a subobject of the original object, the check cannot be fully
##  automated.
##
BindGlobal( "CheckOutputDelegations",
function()
local rules, name, f, str, ots, met, pos, nargs, r, i,
      report, line, m, n, illegal_delegations, checklist;

rules := [ "Display", "ViewObj", "PrintObj", "DisplayString",
           "ViewString", "PrintString", "String" ];

for name in rules do

  pos:=Position( rules, name );
  report:=[];

  for nargs in [1..2] do
    f:=METHODS_OPERATION( EvalString(name), nargs );
    for m in [1..Length(f)/(4+nargs)] do
      met := f[(m-1)*(4+nargs)+2+nargs];
      str := "";
      ots := OutputTextString(str,true);;
      PrintTo( ots, met );
      CloseStream(ots);
      illegal_delegations:=[];
      checklist:=rules{[1..pos-1]};
      for r in checklist do
        n := POSITION_SUBSTRING(str, r, 0);
        if n <> fail then
          if Length(str) >= n + Length(r) then
            if not str[n + Length(r)] in LETTERS then
              Add( illegal_delegations, r );
            fi;
          fi;
        fi;
      od;
      if Length(illegal_delegations) > 0 then
        Add( report, [ FILENAME_FUNC( met ), STARTLINE_FUNC( met ),
                       f[(m-1)*(4+nargs)+4+nargs], illegal_delegations, met ] );
      fi;
    od;
  od;

  if Length(report) > 0 then
    Print("\nDetected incorrect delegations for ", name, "\n");
    for line in report do
      Print("---------------------------------------------------------------\n");
      Print( line[3], "\n", " delegates to ", line[4], "\n",
             "Filename: ", line[1], ", line : ", line[2], "\n", line[5], "\n");
    od;
    Print("---------------------------------------------------------------\n");
  else
    Print("All delegations correct for ", name, "\n");
  fi;

od;
end);

#############################################################################
##
#E
