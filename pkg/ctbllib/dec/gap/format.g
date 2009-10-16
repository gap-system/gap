##############################################################################
##
#W  format.g                                                     Thomas Breuer
##
#H  @(#)$Id: format.g,v 1.1 2002/06/27 16:14:19 gap Exp $
##
#Y  Copyright  (C)  2002,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the formatting info for the database of decomposition
##  matrices.
##


##############################################################################
##
#V  DecMatRowsPerPage
#V  DecMatColsPerPage
#V  DecMatInfoWidth
##
##  The decomposition matrices are split into row and column portions,
##  the number of rows per page is (at most) `DecMatRowsPerPage',
##  the number of columns per page is (at most) `DecMatColsPerPage'.
##
##  Also the initial overview of blocks is printed with at most
##  `DecMatRowsPerPage' rows.
##
##  `DecMatInfoWidth' is used to control two-column output of the blocks
##  overview.
##
BindGlobal( "DecMatRowsPerPage", 40 );
BindGlobal( "DecMatColsPerPage", 15 );
BindGlobal( "DecMatInfoWidth", 16 );


##############################################################################
##
#V  DecMatNamesSpecialCases
#V  DecMatNamesSpecialCases2
##
##  These global variables are used only by `DecMatNames'.
##
##  `DecMatNamesSpecialCases' describes maximal cyclic factors of Schur
##  multipliers in those cases where the Schur multiplier itself is not
##  cyclic.
##
##  `DecMatNamesSpecialCases2' describes how to replace the name $m.G.a$
##  obtained by composing the names of existing groups $m.G$ and $G.a$ in
##  those cases where either $m.G.a$ does not exist or is (currently) not
##  available.
##
DecMatNamesSpecialCases := [];
DecMatNamesSpecialCases[1]:=
[  "Sz(8)",  "O8+(2)",  "U6(2)","O8+(3)",  "2E6(2)",     "L3(4)",     "U4(3)"];
DecMatNamesSpecialCases[2]:=
["2.Sz(8)","2.O8+(2)","6.U6(2)","O8+(3)","2.2E6(2)","12_1.L3(4)","12_1.U4(3)"];

DecMatNamesSpecialCases2 := [];
DecMatNamesSpecialCases2[1]:=
[ "2.A14", "2.A14.2", "2.A15.2", "2.A16.2", "2.A17.2", "6.A6.2_3", "2.Sz(8).3",
  "2.L2(25).2_3", "2.L2(49).2_3", "2.L2(81).2_3", "2.L2(81).4_2",
  "12_1.L3(4).3", "12_1.L3(4).6", "2.L4(4)", "2.L4(4).2_1", "2.L4(4).2_2",
  "2.L4(4).2_3", "2F4(8).3", "2.O8+(2).3", "2.O8-(3)", "2.O8-(3).2_1",
  "2.O8-(3).2_2", "2.O8-(3).2_3", "2.2E6(2).3", "12_1.U4(3).2_3",
  "12_1.U4(3).4", "3.U3(8).3_3", "6.U6(2).3" ];
DecMatNamesSpecialCases2[2]:=
[ "A14", "A14.2",   "A15.2",   "A16.2", "A17.2", "3.A6.2_3",   "Sz(8).3",
  "L2(25).2_3", "L2(49).2_3",   "L2(81).2_3",   "L2(81).4_2",
  "3.L3(4).3", "3.L3(4).6",   "L4(4)", "L4(4).2_1",   "L4(4).2_2",
  "L4(4).2_3",       fail, "O8+(2).3",     "O8-(3)",             fail,
  fail,           fail,           "2E6(2).3",   "12_2.U4(3).2_3",
  "4.U4(3).4",    "U3(8).3_3", "3.U6(2).3" ];


##############################################################################
##
#E

