#############################################################################
##
#W  test.gd             GAP character table library             Thomas Breuer
##
#H  @(#)$Id: test.gd,v 1.15 2004/08/31 10:37:57 gap Exp $
##
#Y  Copyright (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration of functions to test the data
##  available in the {\GAP} Character Table Library.
##
Revision.( "ctbllib/gap4/test_gd" ) :=
    "@(#)$Id: test.gd,v 1.15 2004/08/31 10:37:57 gap Exp $";


#############################################################################
##
#F  CTblLibTestMax( )
#F  CTblLibTestMax( <tblname> )
##
##  First suppose that `CTblLibTestMax' is called with one
##  argument <tblname>,
##  which is an admissible name of the form `<grpname>M<p>'.
##  Then it is checked whether a fusion from the table with name <tblname>
##  into the table with name <grpname> is stored.
##
##  If no argument is given then all admissible character table names are
##  checked with the one argument version.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
DeclareGlobalFunction( "CTblLibTestMax" );


#############################################################################
##
#F  CTblLibTestSylowNormalizers( )
#F  CTblLibTestSylowNormalizers( <tblname> )
##
##  First suppose that `CTblLibTestSylowNormalizers' is called with one
##  argument <tblname>,
##  which is an admissible name of the form `<grpname>N<p>'.
##  Then it is checked whether the Sylow <p> subgroup of the table with name
##  <tblname> is a nontrivial normal subgroup, and whether the order of the
##  Sylow <p> subgroup coincides with that in the table for <grpname>.
##  If the Sylow <p> subgroup is cyclic then it is additionally checked
##  whether the order of the group of <tblname> equals the order of the
##  Sylow <p> normalizer.
##
##  If no argument is given then all admissible character table names are
##  checked with the one argument version.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
DeclareGlobalFunction( "CTblLibTestSylowNormalizers" );


#############################################################################
##
#F  CTblLibTestElementCentralizers( )
#F  CTblLibTestElementCentralizers( <tblname> )
##
##  First suppose that `CTblLibTestElementCentralizers' is called with one
##  argument <tblname>,
##  which is an admissible name of the form `<grpname>C<nam>',
##  where <nam> is a classname of the table with the name <grpname>.
##  Then it is checked whether a reasonable subgroup fusion from the table
##  with the name <tblname> to the table with the name <grpname> is stored,
##  and whether <tblname> can describe the full centralizer of the class
##  <nam> in the table with the name <grpname>.
##  Independent of the structure of <tblname>, it is checked for all subgroup
##  fusions from the character table with name <tblname> into other tables
##  whether the subgroup table is the full centralizer of an element in the
##  supergroup table, and if yes whether this table has an admissible name
##  that expresses this.
##
##  If no argument is given then all admissible character table names are
##  checked with the one argument version.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
DeclareGlobalFunction( "CTblLibTestElementCentralizers" );


#############################################################################
##
#F  CTblLibTestElementNormalizers( )
#F  CTblLibTestElementNormalizers( <tblname> )
##
##  First suppose that `CTblLibTestElementNormalizers' is called with one
##  argument <tblname>,
##  which is an admissible name of the form `<grpname>N<nam>',
##  where <nam> is a classname of the table with the name <grpname>.
##  Then it is checked whether a reasonable subgroup fusion from the table
##  with the name <tblname> to the table with the name <grpname> is stored,
##  and whether <tblname> can describe the full normalizer of the class
##  <nam> in the table with the name <grpname>.
##  Independent of the structure of <tblname>, it is checked for all subgroup
##  fusions from the character table with name <tblname> into other tables
##  whether the subgroup table is the full normalizer of an element in the
##  supergroup table, and if yes whether this table has an admissible name
##  that expresses this.
##
##  If no argument is given then all admissible character table names are
##  checked with the one argument version.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
DeclareGlobalFunction( "CTblLibTestElementNormalizers" );


#############################################################################
##
#V  CTblLibHardFusions
##
##  `CTblLibHardFusions' is a list of pairs `[ <subname>, <tblname> ]'
##  where <subname> and <tblname> are `Identifier' values of character
##  tables such that `CTblLibTestSubgroupFusion' shall omit the compatibility
##  check for the class fusion between these tables.
##
DeclareGlobalVariable( "CTblLibHardFusions" );


#############################################################################
##
#F  CTblLibTestDecompositions( <sub>, <fuslist>, <tbl> )
##
##  Let <sub> and <tbl> be ordinary character tables, and <fuslist> a list of
##  possible class fusions from <sub> to <tbl>.
##
##  `CTblLibTestDecompositions' returns the set of all those entries in
##  <fuslist> such that for all available $p$-modular Brauer tables of <sub>
##  and <tbl>, the $p$-modular Brauer characters of <tbl> decompose into
##  $p$-modular Brauer characters of <sub>.
##
DeclareGlobalFunction( "CTblLibTestDecompositions" );


#############################################################################
##
#F  CTblLibTestSubgroupFusion( <sub>, <tbl> )
#F  CTblLibTestSubgroupFusion( <sub>, <tbl>, <statistics> )
##
##  If no class fusion from <sub> to <tbl> is possible or if the possible
##  class fusions contradict the stored fusion then `false' is returned.
##  If a fusion is stored and is compatible with the possible fusions,
##  and the fusion is not unique up to table automorphisms and if the stored
##  fusion has no `text' component then `fail' is returned.
##  Otherwise the fusion record is returned.
##
##  If the pair of identifiers of <sub> and <tbl> occurs in the global list
##  `CTblLibHardFusions' amd if a fusion is stored then the fusion record is
##  returned without tests, and a message is printed.
##
##  If <statistics> is a list then statistics information bout the fusion is
##  added to it, otherwise <statistics> is ignored.
##
DeclareGlobalFunction( "CTblLibTestSubgroupFusion" );


#############################################################################
##
#F  CTblLibTestFactorFusion( <tbl>, <fact> )
##
##  If no class fusion from <tbl> onto <fact> is possible or if the possible
##  factor fusions contradict the stored fusion then `false' is returned.
##  If a fusion is stored and is compatible with the possible fusions,
##  and the fusion is not unique up to table automorphisms and if the stored
##  fusion has no `text' component then `fail' is returned.
##  Otherwise the fusion record is returned.
##
DeclareGlobalFunction( "CTblLibTestFactorFusion" );


#############################################################################
##
#F  CTblLibTestFusions( <statistics> )
#F  CTblLibTestFusions( <tblname>, <statistics> )
##
##  First suppose that `CTblLibTestFusions' is called with two
##  arguments <tblname>, which is an admissible name of a character table,
##  and <statistics>, which may be any object.
##  Then it is checked whether the subgroup and factor fusions stored on the
##  table can be correct; for subgroup fusions, this means that the target
##  table exists, that the stored fusion map is among the possible class
##  fusions computed with `PossibleClassFusions'
##  (see~"ref:PossibleClassFusions" in the {\GAP} Reference Manual),
##  that a `text' component is stored whenever the fusion map is not unique
##  up to table automorphisms, and that stored `text' components are
##  compatible with the possible class fusions.
##
##  If <statistics> is a list then for all subgroup fusions that are
##  recomputed, statistics information is added to <statistics>.
##
##  If only one argument <statistics> is given then all standard character
##  table names are checked with the two argument version, where <statistics>
##  is the second argument in each call.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
DeclareGlobalFunction( "CTblLibTestFusions" );


#############################################################################
##
#F  CTblLibTestPowerMaps( )
#F  CTblLibTestPowerMaps( <tblname> )
##
##  First suppose that `CTblLibTestPowerMaps' is called with one
##  argument <tblname>, which is an admissible name of a character table.
##  Then it is checked whether all power maps of prime divisors of the group
##  order are stored on the table, and whether they are correct.
##  (This includes the information about uniqueness of the power maps.)
##
##  If no argument is given then all standard character table names are
##  checked with the one argument version.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
DeclareGlobalFunction( "CTblLibTestPowerMaps" );


#############################################################################
##
#F  CTblLibTestBlocksInfo( <modtbl> )
##
DeclareGlobalFunction( "CTblLibTestBlocksInfo" );


#############################################################################
##
#F  CTblLibTestTensorDecomposition( <modtbl> )
##
##  to be used only if new Brauer tables are added!
##
DeclareGlobalFunction( "CTblLibTestTensorDecomposition" );


#############################################################################
##
#F  CTblLibTestIndicators( <modtbl> )
##
##  Test if the $2$nd indicators of the Brauer table <modtbl> are correct.
##  (In odd characteristic the indicator can be computed, in characteristic
##  two we can perform consistency checks.)
##
DeclareGlobalFunction( "CTblLibTestIndicators" );


#############################################################################
##
#F  CTblLibTestInfoText()
#F  CTblLibTestInfoText( <tblname> )
##
##  Currently it is not recommended to use the `InfoText' (see~"ref:InfoText"
##  in the {\GAP} Reference Manual) value of character tables
##  programmatically.
##  However, one can rely on the following structure of the `InfoText' value
##  of tables in the {\GAP} Character Table Library.
##
##  The value is a string that consists of `\\n' separated lines.
##
##  If a line of the form ``maximal subgroup of <grpname>,'' occurs,
##  where <grpname> is the name of a character table,
##  then a class fusion from the table in question to that with name
##  <grpname> is stored;
##  the terminating comma can be missing if the line is the last of the
##  `InfoText' value.
##  If a line of the form ``<n>th maximal subgroup of <grpname>,'' occurs
##  then the table with name <grpname> has a `Maxes' value (see~"ref:Maxes"
##  in the {\GAP} Reference Manual) in which the given character table is
##  referenced in position <n>.
#T  <n>st, <n>nd, <n>rd !!
#T  <n>th and <m>th ??
#T  ...<n>th maximal subgroup of ... group <grpname>... ??
##
DeclareGlobalFunction( "CTblLibTestInfoText" );


#############################################################################
##
#V  CTblLibHardTableAutomorphisms
##
##  `CTblLibHardTableAutomorphisms' is a list of `Identifier' values of
##  (ordinary or Brauer) character tables such that
##  `CTblLibTestTableAutomorphisms' shall omit the check for these tables.
##
DeclareGlobalVariable( "CTblLibHardTableAutomorphisms" );


#############################################################################
##
#F  CTblLibTestTableAutomorphisms( [<tbl>] )
##
##  First suppose that `CTblLibTestTableAutomorphisms' is called with one
##  argument <tbl>, which is an ordinary or Brauer character table.
##  Then it is checked whether the table automorphisms are stored on the
##  table, and whether they are correct.
##
##  If no argument is given then all ordinary character tables and their
##  Brauer tables are checked with the one argument version.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
DeclareGlobalFunction( "CTblLibTestTableAutomorphisms" );


#############################################################################
##
#V  CTblLibTestConstructionsFunctions
##
DeclareGlobalVariable( "CTblLibTestConstructionsFunctions" );


#############################################################################
##
#F  CTblLibTestConstructions()
#F  CTblLibTestConstructions( <tblname> )
##
DeclareGlobalFunction( "CTblLibTestConstructions" );


#T test mapping to tomlib:
#T do all table names and tom names exist?

#############################################################################
##
#E

