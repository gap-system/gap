#############################################################################
##
#W  helpsys.tst                GAP library                     Frank Lübeck
##
##
#Y  Copyright (C)  2004,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This produces the text version of each help section which can be reached
##  from GAPs help system.
##
##  Exclude from testinstall.g: why?
##

gap> START_TEST("helpsys.tst");
gap> SetUserPreference("Browse", "SelectHelpMatches", false); # needed only for compatibility with the Browse package
gap> SetHelpViewer("screen");;
gap> savepagerprefs:=UserPreference("Pager");;
gap> SetUserPreference("Pager",0);
gap> savepager:=PAGER_EXTERNAL;;
gap> MakeReadWriteGlobal("PAGER_EXTERNAL");
gap> PAGER_EXTERNAL:=function(lines)end;
function( lines ) ... end
gap> HELP(":?");
gap> for i in [1..Length(HELP_LAST.TOPICS)] do HELP(String(i)); od;
gap> PAGER_EXTERNAL:=savepager;;
gap> MakeReadOnlyGlobal("PAGER_EXTERNAL");
gap> SetUserPreference("Pager",savepagerprefs);
gap> ForAll(FindMultiSpelledHelpEntries(), i -> 
>    Length( Set( List( SuggestedSpellings( i[3] ), 
>                       j -> SuggestedSpellings(j) ) ) ) = 1 );
true
gap> Length(SuggestedSpellings("AnalyseMetacatalogOfCataloguesOfColourizationLabelingsOfCentreBySolvableNormalisersInNormalizerCentralizersInCentre"));
4096
gap> STOP_TEST( "helpsys.tst", 1);


#############################################################################
##
#E

