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

STOP_TEST := function( file, fac )
    local   time;

    STONE_FILE  := file;
    STONE_RTIME := Runtime() - START_TIME;
    STONE_STONE := QuoInt( fac, STONE_RTIME );
    STONE_SUM   := STONE_SUM + STONE_RTIME;
    STONE_FSUM  := STONE_FSUM + fac;
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
    if 0 < next  then
        Print( "    (next ~ ", Int(STONE_SUM*next*10/STONE_FSUM),
               " sec)\n" );
    else
        Print("\n");
    fi;
end;


#############################################################################
##
#X  read all test files
##
TestDir := DirectoriesLibrary("tst");

Print("You should start GAP4 using: `gap -N -M -m 16m'. The more \n");
Print("GAP4stones you get, the faster your system is.  The runtime of\n");
Print("the following tests (in general) increases.  You should expect\n");
Print("about 10000 GAP4stones on a Pentium 5, 133 MHz, about 22000 on\n");
Print("a Pentium Pro, 200 Mhz.  The `next' time is an approximation of\n");
Print("the running time for the next test.\n");
Print("\n");
Print("Architecture: ", GAP_ARCHITECTURE, "\n");
Print("\n");
Print("test file         GAP4stones     time(msec)\n");
Print("-------------------------------------------\n");

infoRead1 := InfoRead1;  InfoRead1 := Ignore;
infoRead2 := InfoRead2;  InfoRead2 := Ignore;

ReadTest( Filename( TestDir, "unknown.tst"  ) );  SHOW_STONES(64);
ReadTest( Filename( TestDir, "boolean.tst"  ) );  SHOW_STONES(64);
ReadTest( Filename( TestDir, "listgen.tst"  ) );  SHOW_STONES(89);
ReadTest( Filename( TestDir, "gaussian.tst" ) );  SHOW_STONES(218);
ReadTest( Filename( TestDir, "grpfree.tst"  ) );  SHOW_STONES(481);
ReadTest( Filename( TestDir, "ffe.tst"      ) );  SHOW_STONES(485);
ReadTest( Filename( TestDir, "cyclotom.tst" ) );  SHOW_STONES(787);
ReadTest( Filename( TestDir, "zmodnz.tst"   ) );  SHOW_STONES(986);
ReadTest( Filename( TestDir, "mapping.tst"  ) );  SHOW_STONES(1381);
ReadTest( Filename( TestDir, "fldabnum.tst" ) );  SHOW_STONES(2475);
ReadTest( Filename( TestDir, "vspcrow.tst"  ) );  SHOW_STONES(2307);
ReadTest( Filename( TestDir, "modfree.tst"  ) );  SHOW_STONES(3556);
ReadTest( Filename( TestDir, "vspcmat.tst"  ) );  SHOW_STONES(3781);
ReadTest( Filename( TestDir, "vspchom.tst"  ) );  SHOW_STONES(3800);
ReadTest( Filename( TestDir, "combinat.tst" ) );  SHOW_STONES(4356);
ReadTest( Filename( TestDir, "vspcmali.tst" ) );  SHOW_STONES(4636);
ReadTest( Filename( TestDir, "grppc.tst"    ) );  SHOW_STONES(11221);
ReadTest( Filename( TestDir, "onecohom.tst" ) );  SHOW_STONES(19983);
ReadTest( Filename( TestDir, "grpmat.tst"   ) );  SHOW_STONES(57375);
ReadTest( Filename( TestDir, "rwspcgrp.tst" ) );  SHOW_STONES(74980);
ReadTest( Filename( TestDir, "morpheus.tst" ) );  SHOW_STONES(73524);
ReadTest( Filename( TestDir, "algsc.tst"    ) );  SHOW_STONES(78191);
ReadTest( Filename( TestDir, "rwspcsng.tst" ) );  SHOW_STONES(133191);
ReadTest( Filename( TestDir, "ctblmoli.tst" ) );  SHOW_STONES(201017);
ReadTest( Filename( TestDir, "algmat.tst"   ) );  SHOW_STONES(410353);
ReadTest( Filename( TestDir, "grppcnrm.tst" ) );  SHOW_STONES(1481624);
ReadTest( Filename( TestDir, "grplatt.tst"  ) );  SHOW_STONES(0);

Print("-------------------------------------------\n");
Print( FormattedString("total",-16), "    ",
       FormattedString(QuoInt(STONE_FSUM,STONE_SUM),8), "       ",
       FormattedString(STONE_RTIME,8), "\n" );
Print("\n");

InfoRead1  := infoRead1;
InfoRead2  := infoRead2;
START_TEST := start_TEST;
STOP_TEST  := STOP_TEST;
