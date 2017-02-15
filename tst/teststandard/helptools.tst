# This test checks various auxiliary functions used by the help system.
#
# For the test that systematically checks each manual section, see
# tst/testextra/helpsys.tst
#
gap> START_TEST("helptools.tst");
gap> ForAll(FindMultiSpelledHelpEntries(), i -> 
>    Length( Set( List( HELP_SEARCH_ALTERNATIVES( i[3] ), 
>                       j -> HELP_SEARCH_ALTERNATIVES(j) ) ) ) = 1 );
true
gap> Length(HELP_SEARCH_ALTERNATIVES("AnalyseMetacatalogOfCataloguesOfColourizationLabelingsOfCentreBySolvableNormalisersInNormalizerCentralizersInCentre"));
4096
gap> HELP_SEARCH_ALTERNATIVES("hasismapping");
[ "hasismapping", "ismapping", "setismapping" ]
gap> HELP_SEARCH_ALTERNATIVES("setismapping");
[ "hasismapping", "ismapping", "setismapping" ]
gap> HELP_SEARCH_ALTERNATIVES("ismapping");
[ "ismapping" ]
gap> STOP_TEST( "helptools.tst" );
