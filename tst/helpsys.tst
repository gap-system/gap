#############################################################################
##
#W  helpsys.tst                GAP library                     Frank Lübeck
##
#H  @(#)$Id: helpsys.tst,v 1.7 2011/01/04 20:32:43 alexk Exp $
##
#Y  Copyright (C)  2004,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This produces the text version of each help section which can be reached
##  from GAPs help system.
##
##  Exclude from testinstall.g: why?
##

gap> START_TEST("$Id: helpsys.tst,v 1.7 2011/01/04 20:32:43 alexk Exp $");
gap> NoSelectHelpMatches := true;; # needed only for compatibility with the Browse package
gap> SetHelpViewer("screen");;
#I  Using screen as help viewer.
gap> savepagerprefs:=GAPInfo.UserPreferences.Pager;;
gap> GAPInfo.UserPreferences.Pager:= 0;
0
gap> savepager:=PAGER_EXTERNAL;;
gap> MakeReadWriteGlobal("PAGER_EXTERNAL");
gap> PAGER_EXTERNAL:=function(lines)end;
function( lines ) ... end
gap> HELP(":?");
gap> for i in [1..Length(HELP_LAST.TOPICS)] do HELP(String(i)); od;
gap> PAGER_EXTERNAL:=savepager;;
gap> MakeReadOnlyGlobal("PAGER_EXTERNAL");
gap> GAPInfo.UserPreferences.Pager:=savepagerprefs;;
gap> STOP_TEST( "helpsys.tst", 79318448);


#############################################################################
##
#E

