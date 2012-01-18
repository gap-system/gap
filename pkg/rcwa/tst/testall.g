#############################################################################
##
#W  testall.g                GAP4 Package `RCWA'                 Frank Celler
##                                                                Stefan Kohl
##
##  This file contains the code to run the test suite of the RCWA package. It
##  is an adaptation of the file running the test suite of the GAP Library.
##
#############################################################################

#############################################################################
##
#F  START_TEST( <id> )  . . . . . . . . . . . . . . . . . . . start test file
##
start_TEST := START_TEST;

START_TIME := 0;
STONE_NAME := "";

START_TEST := function( name )
    FlushCaches();
    RANDOM_SEED(1);
    GASMAN("collect");
    START_TIME := Runtime();
    STONE_NAME := name;
end;

#############################################################################
##
#F  STOP_TEST( <file>, <fac> )  . . . . . . . . . . . . . . .  stop test file
##
stop_TEST := STOP_TEST;

STONE_RTIME := 0;
STONE_STONE := 0;
STONE_FILE  := 0;
STONE_SUM   := 0;
STONE_FSUM  := 0;
STONE_PROD  := 1;
STONE_COUNT := 0;

STOP_TEST := function( file, fac )
    local   time;

    STONE_FILE  := file;
    STONE_RTIME := Runtime() - START_TIME;
    if STONE_RTIME > 500  then
        STONE_STONE := QuoInt( fac, STONE_RTIME );
        STONE_SUM   := STONE_SUM + STONE_RTIME;
        STONE_FSUM  := STONE_FSUM + fac;
        STONE_PROD  := STONE_PROD*STONE_STONE;
        STONE_COUNT := STONE_COUNT + 1;
    else
        STONE_STONE := 0;
    fi;
end;

#############################################################################
##
#F  SHOW_STONES( <next> ) . . . . . . . . . . . . . . . . .  show GAP4 stones
##
STONE_ALL := [];

SHOW_STONES := function( next )
    Print( FormattedString(STONE_FILE,-16), "    ",
           FormattedString(STONE_STONE,8), "       ",
           FormattedString(STONE_RTIME,8) );
    Add( STONE_ALL, STONE_STONE );
    if 0 < next and STONE_FSUM <> 0  then
        Print( "    (next ~ ", Int(STONE_SUM*next*10/STONE_FSUM),
               " sec)\n" );
    else
        Print("\n");
    fi;
end;

#############################################################################
##
#F  TEST_FILES  . . . . . . . . . . . . . . . . . . . . .  list of test files
##
##  the following list contains the filename and  the scaling factor given to
##  `STOP_TEST' at the end of the test file.  The file  names are relative to
##  the test directory.
##
##  The list can be produced using:
##
##  grep -h "STOP_TEST" *.tst | sed -e 's:^gap> STOP_TEST( ":[ ":' | \
##  sed -e 's: );: ],:'
##
TEST_FILES := [ [ "other.tst",       4000000 ],
                [ "ngens.tst",      15000000 ],
                [ "monoids.tst",   150000000 ],
                [ "semiloc.tst",   400000000 ],
                [ "cscrct.tst",   1700000000 ],
                [ "rcwa_ct.tst",  1900000000 ],
                [ "modular.tst",  2300000000 ],
                [ "zxz.tst",      2300000000 ],
                [ "integral.tst", 8000000000 ] ];

Sort( TEST_FILES, function(a,b) return a[2] < b[2]; end );

#############################################################################
##
#X  Read all test files.
##
oldSizeScreen := SizeScreen();
SizeScreen([80,]);

Print("This is the test suite of the RCWA package.\n\n");
Print(FormatParagraph(Concatenation(
  "The tests compare the correct and the actual output of a larger ",
  "number of GAP commands, and show any differences. ")),"\n");
Print(FormatParagraph(Concatenation(
  "Please note that the test suite is a tool for developing. ",
  "The tests are deliberately very volatile to allow to spot possible ",
  "problems of any kind also in other packages or in the GAP Library. ",
  "For this reason you may see below reports of differences ",
  "which simply reflect improved methods in other packages or in the ",
  "GAP Library or which are caused by changes of the way certain ",
  "objects are printed, and which are therefore harmless. However ",
  "if the correct and the actual output look different mathematically ",
  "or if you see error messages or if GAP crashes, then something ",
  "went wrong. Also, reports about significantly increased runtimes ",
  "as well as runtimes which are much longer than predicted may ",
  "indicate a problem.")),"\n");
Print(FormatParagraph(Concatenation(
  "The runtime of the following tests (in general) increases. ",
  "The `next' time is an approximation of the running time for ",
  "the next test. The more GAP4stones you get, the faster your system ",
  "is. Since RCWA caches some data, subsequent runs of the test suite ",
  "within the same GAP session will usually be faster than ",
  "the first run.")),"\n");
Print("Architecture: ", GAP_ARCHITECTURE, "\n");
Print("\n");
Print("test file         GAP4stones     time(msec)\n");
Print("-------------------------------------------\n");

infoRead1 := InfoRead1;  InfoRead1 := Ignore;
infoRead2 := InfoRead2;  InfoRead2 := Ignore;

TestDirStr := Concatenation(PackageInfo("rcwa")[1].InstallationPath,"/tst/");
TestDir    := [ Directory(TestDirStr) ];

for i in [ 1 .. Length(TEST_FILES) ] do
    name := Filename( TestDir, TEST_FILES[i][1] );
    if i < Length(TEST_FILES)  then
        next := TEST_FILES[i+1][2] / 10^4;
    else
        next := 0;
    fi;
    Print("testing: ",name,"\n");
    ReadTestCompareRuntimes(name,Concatenation(TestDirStr,"timings/"));
    SHOW_STONES(next);
od;

Print("-------------------------------------------\n");
if STONE_COUNT=0 then
  STONE_COUNT:=1;
fi;
Print( FormattedString("total",-16), "    ",
       FormattedString(RootInt(STONE_PROD,STONE_COUNT),8), "       ",
       FormattedString(STONE_SUM,8), "\n" );
Print("\n");

SizeScreen(oldSizeScreen);

InfoRead1  := infoRead1;
InfoRead2  := infoRead2;
START_TEST := start_TEST;
STOP_TEST  := stop_TEST;

#############################################################################
##
#E  testall.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here