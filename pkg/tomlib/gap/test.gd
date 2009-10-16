#############################################################################
##
#W  test.gd             GAP library of tables of marks          Thomas Breuer
##
#H  @(#)$Id: test.gd,v 1.6 2003/10/09 16:30:04 gap Exp $
##
#Y  Copyright (C)  2003,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration of functions to test the data
##  available in the {\GAP} Library of Tables of Marks.
##
Revision.( "tomlib/gap/test_gd" ) :=
    "@(#)$Id: test.gd,v 1.6 2003/10/09 16:30:04 gap Exp $";


#############################################################################
##
#F  TomLibTestStraightLineProgramsAndDerivedSubgroups( )
#F  TomLibTestStraightLineProgramsAndDerivedSubgroups( <tomname> )
##
##  Check that each table of marks has valid straight line programs,
##  and if yes, that the derived subgroups stored in the table are correct.
##
DeclareGlobalFunction( "TomLibTestStraightLineProgramsAndDerivedSubgroups" );


#############################################################################
##
#V  TomLibHardFusionsTblToTom
##
##  `TomLibHardFusionsTblToTom' is a list of `Identifier' values of character
##  tables from the {\GAP} Character Table Library such that 
##  `TomLibTestFusionTblToTom' shall omit the compatibility check for the 
##  class fusion from this table to its table of marks.
##
DeclareGlobalVariable( "TomLibHardFusionsTblToTom" );


#############################################################################
##
#F  TomLibTestFusionTblToTom( <tbl>, <tom> )
##
#T  analogous to CTblLibTestSubgroupFusion!!
##
DeclareGlobalFunction( "TomLibTestFusionTblToTom" );


#############################################################################
##
#F  TomLibTestCharacterTable( )
#F  TomLibTestCharacterTable( <tomname> )
##
##  First suppose that `TomLibTestCharacterTable' is called with one
##  argument <tomname>.
##  Then it is checked whether a character table for the group exists 
##  in the {\GAP} Character Table Library.
##
##  If no argument is given then all admissible names of tables of marks are
##  checked with the one argument version.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
DeclareGlobalFunction( "TomLibTestCharacterTable" );


#############################################################################
##
#F  TomLibTestFusions( )
#F  TomLibTestFusions( <tomname> )
##
##  First suppose that `TomLibTestFusions' is called with one
##  argument <tomname>.
##  Then it is checked whether the stored fusions from the table of marks
##  with name <tomname> into other tables of marks are reliable,
##  and whether they are compatible with the corresponding fusions between
##  the character tables (w.r.t. the stored fusions from character table to
##  table of marks).
##
##  If no argument is given then all admissible names of tables of marks are
##  checked with the one argument version.
##
##  In all cases, the return value is `false' if an error occurred,
##  and `true' otherwise.
##
DeclareGlobalFunction( "TomLibTestFusions" );


#############################################################################
##
#E

