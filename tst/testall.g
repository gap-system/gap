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
[ "alghom.tst", 58060000 ],
[ "algmat.tst", 880820000 ],
[ "algsc.tst", 408385000 ],
[ "boolean.tst", 3000000 ],
[ "combinat.tst", 30050000 ],
#[ "compat3.tst", 10000 ],
[ "ctblfuns.tst", 28292309 ],
[ "ctblj4.tst", 3000000000 ],
[ "ctblmoli.tst", 350007500 ],
[ "ctblmono.tst", 231440000 ],
[ "ctblsolv.tst", 70667500 ],
[ "cyclotom.tst", 5832500 ],
[ "ffe.tst", 18600000 ],
[ "fldabnum.tst", 87667500 ],
[ "gaussian.tst", 3032500 ],
[ "grpconst.tst", 149383970000 ],
[ "grpfree.tst", 630000 ],
[ "grplatt.tst", 5761430000 ],
[ "grpmat.tst", 102570000 ],
[ "grppc.tst", 82187500 ],
[ "grppcnrm.tst", 1948650000 ],
[ "grpperm.tst", 3218162500 ],
[ "grpprmcs.tst", 18790865000 ],
[ "listgen.tst", 1517500 ],
[ "mapping.tst", 23067500 ],
[ "matblock.tst", 1410500 ],
[ "mgmring.tst", 21697500 ],
[ "modfree.tst", 30792500 ],
[ "morpheus.tst", 546842500 ],
[ "onecohom.tst", 226515000 ],
[ "ratfun.tst", 4602500 ],
[ "relation.tst", 37930000  ],
[ "rwspcgrp.tst", 304775000 ],
[ "rwspcsng.tst", 403645000 ],
[ "semigrp.tst", 74105000 ],
[ "semicong.tst", 1000000000 ],
[ "set.tst", 20930000 ],
[ "unknown.tst", 320000 ],
[ "vspchom.tst", 42737500 ],
[ "vspcmali.tst", 35942500 ],
[ "vspcmat.tst", 33682500 ],
[ "vspcrow.tst", 155797500 ],
[ "weakptr.tst", 24477500 ],
[ "xgap.tst", 310142500 ],
[ "zlattice.tst", 10000000 ],
[ "zmodnz.tst", 10520000 ],
[ "hash2.tst", 19260000 ],
[ "quogphom.tst", 17600000 ],
[ "eigen.tst", 16000000 ],
[ "solmxgrp.tst", 80000000000 ],
[ "rss.tst", 123000000 ]
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
