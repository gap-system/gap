#############################################################################
##
#W  testall.g                   GAP library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

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
TEST_FILES := [
[ "alghom.tst", 57860000 ],
[ "algmat.tst", 2140820000 ],
[ "algsc.tst", 498385000 ],
[ "boolean.tst", 300000 ],
[ "combinat.tst", 39450000 ],
#[ "compat3.tst", 10000 ],
[ "ctbldeco.tst", 75612500 ],
[ "ctblfuns.tst", 612923095 ],
[ "ctblj4.tst", 3000000000 ],
[ "ctbllibr.tst", 200000000000 ],
[ "ctblmoli.tst",495097500 ],
[ "ctblmono.tst", 231440000 ],
[ "ctblpope.tst", 6129230950 ],
[ "ctblsolv.tst", 71667500 ],
[ "cyclotom.tst", 7232500 ],
[ "ffe.tst", 31560000 ],
[ "fldabnum.tst", 71667500 ],
[ "gaussian.tst",1315000 ],
[ "grpconst.tst", 149383970000 ],
[ "grpfree.tst", 2630000 ],
[ "grplatt.tst", 7261430000 ],
[ "grpmat.tst", 102570000 ],
[ "grppc.tst", 82187500 ],
[ "grppcnrm.tst", 2248650000 ],
[ "grpperm.tst", 3718162500 ],
[ "grpprmcs.tst", 21790865000 ],
[ "listgen.tst", 5917500 ],
[ "mapping.tst", 19067500 ],
[ "matblock.tst", 1972500 ],
[ "mgmring.tst", 21697500 ],
[ "modfree.tst", 38792500 ],
[ "morpheus.tst", 656842500 ],
[ "onecohom.tst", 106515000 ],
[ "ratfun.tst", 4602500 ],
[ "relation.tst", 28930000 ],
[ "rwspcgrp.tst", 374775000 ],
[ "rwspcsng.tst", 503645000 ],
[ "semigrp.tst", 88105000 ],
[ "set.tst", 28930000 ],
[ "unknown.tst", 320000 ],
[ "vspchom.tst", 42737500 ],
[ "vspcmali.tst", 51942500 ],
[ "vspcmat.tst", 46682500 ],
[ "vspcrow.tst", 205797500 ],
[ "weakptr.tst", 37477500 ],
[ "xgap.tst", 420142500 ],
[ "zlattice.tst", 10000000 ],
[ "zmodnz.tst", 10520000 ],
[ "hash2.tst", 38260000 ],
[ "quogphom.tst", 2760000 ],
[ "eigen.tst", 1830000 ],
[ "solmxgrp.tst", 800000000 ],
[ "rss.tst", 183000000 ]
];

Sort( TEST_FILES, function(a,b) return a[2] < b[2]; end );


#############################################################################
##
#X  read all test files
##
Print("You should start GAP4 using:  `gap -N -M -A -x 80 -r -m 30m'. The more\n");
Print("GAP4stones you get, the faster your  system is.  The runtime of\n");
Print("the following tests (in general)  increases.  You should expect\n");
Print("about 10000 GAP4stones on a Pentium 5, 133 MHz,  about 28000 on\n");
Print("a Pentium Pro, 200 Mhz.  The `next' time is an approximation of\n");
Print("the running time for the next test.\n");
Print("\n");
Print("Architecture: ", GAP_ARCHITECTURE, "\n");
Print("\n");
Print("test file         GAP4stones     time(msec)\n");
Print("-------------------------------------------\n");

infoRead1 := InfoRead1;  InfoRead1 := Ignore;
infoRead2 := InfoRead2;  InfoRead2 := Ignore;

TestDir := DirectoriesLibrary("tst");

for i  in [ 1 .. Length(TEST_FILES) ]  do
    name := Filename( TestDir, TEST_FILES[i][1] );
    if i < Length(TEST_FILES)  then
        next := TEST_FILES[i+1][2] / 10^4;
    else
        next := 0;
    fi;
    Print("testing: ",name,"\n");
    ReadTest(name);
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

InfoRead1  := infoRead1;
InfoRead2  := infoRead2;
START_TEST := start_TEST;
STOP_TEST  := stop_TEST;


#############################################################################
##
#E  testall.g . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
