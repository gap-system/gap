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
    if STONE_RTIME <> 0  then
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
##  grep -h "STOP_TEST" *.tst | 		\
##    sed -e 's:^gap> STOP_TEST( ":[ ":' | 	\
##    sed -e 's: );: ],:'
##
TEST_FILES := [
[ "algmat.tst", 2275253357 ],
[ "algsc.tst", 867313307 ],
[ "boolean.tst", 10000 ],
[ "combinat.tst", 39450000 ],
[ "ctblmoli.tst", 2250828729 ],
[ "cyclotom.tst", 6575144 ],
[ "ffe.tst", 6757787 ],
[ "fldabnum.tst", 13810000 ],
[ "gaussian.tst", 597720 ],
[ "grpfree.tst", 2390880 ],
[ "grplatt.tst", 16802570813 ],
[ "grpmat.tst", 1170544762 ],
[ "grppc.tst", 17634147 ],
[ "grppcnrm.tst", 4599810668 ],
[ "grpperm.tst", 692757480 ],
[ "listgen.tst", 298860 ],
[ "mapping.tst", 15840238 ],
[ "matblock.tst", 10000 ],
[ "modfree.tst", 28690858 ],
[ "morpheus.tst", 611773707 ],
[ "onecohom.tst", 118948251 ],
[ "rwspcgrp.tst", 807548686 ],
[ "rwspcsng.tst", 1072342703 ],
[ "unknown.tst", 320000 ],
[ "vspchom.tst", 39749178 ],
[ "vspcmali.tst", 51405100 ],
[ "vspcmat.tst", 38554186 ],
[ "vspcrow.tst", 24208100 ],
[ "weakptr.tst", 32576255 ],
[ "zmodnz.tst", 6575053 ],
];

Sort( TEST_FILES, function(a,b) return a[2] < b[2]; end );


#############################################################################
##
#X  read all test files
##
Print("You should  start  GAP4  using:  `gap -N -M -m 16m'.  The  more\n");
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
    ReadTest(name);
    SHOW_STONES(next);
od;

Print("-------------------------------------------\n");
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
