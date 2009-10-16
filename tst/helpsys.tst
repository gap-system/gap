#############################################################################
##
#W  helpsys.tst                GAP library                     Frank Lübeck
##
#H  @(#)$Id: helpsys.tst,v 1.2 2005/05/05 15:04:16 gap Exp $
##
#Y  Copyright (C)  2004,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This produces the text version of each help section which can be reached
##  from GAPs help system.
##
##  Exclude from testall.g: why?
##

gap> START_TEST("$Id: helpsys.tst,v 1.2 2005/05/05 15:04:16 gap Exp $");

gap> SetHelpViewer("screen");;
#I  Using screen as help viewer.
gap> PAGER:=0;
0
gap> savepager:=PAGER_EXTERNAL;;
gap> MakeReadWriteGlobal("PAGER_EXTERNAL");
gap> PAGER_EXTERNAL:=function(lines)end;
function( lines ) ... end
gap> HELP(":?");
gap> for i in [1..Length(HELP_LAST.TOPICS)] do HELP(String(i)); od;
gap> PAGER_EXTERNAL:=savepager;;
gap> STOP_TEST( "helpsys.tst", 79318448);


#############################################################################
##
#E

