#############################################################################
##
#W  uctypeB.g             GAP 4 package `ctbllib'      Michael Cla\3en-Houben
##
#H  @(#)$Id: uctypeB.g,v 1.1 2005/05/17 08:51:03 gap Exp $
##
#Y  Copyright (C)  2005,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains Deligne-Lusztig names of $B$ type groups.
##
Revision.( "ctbllib/dlnames/uctypeB_g" ) :=
    "@(#)$Id: uctypeB.g,v 1.1 2005/05/17 08:51:03 gap Exp $";


Append( DeltigLibUnipotentCharacters, [
  rec( isoc := "B", l := 3, q := 3, isot := [ "ad" ], identifier := "O7(3).2",
      labeling := [ rec( label := [ [ 1, 2, 3 ], [ 0, 1 ] ], index := 44 ),
          rec( label := [ [ 1, 2 ], [ 1 ] ], index := 38 ),
          rec( label := [ [ 0, 1, 3 ], [ 1, 2 ] ], index := 54 ),
          rec( label := [ [ 0, 1, 2, 3 ], [ 1, 2, 3 ] ], index := 93 ),
          rec( label := [ [ 1, 3 ], [ 0 ] ], index := 9 ),
          rec( label := [ [ 0, 2 ], [ 2 ] ], index := 20 ),
          rec( label := [ [ 0, 3 ], [ 1 ] ], index := 13 ),
          rec( label := [ [ 0, 1, 2 ], [ 1, 3 ] ], index := 53 ),
          rec( label := [ [ 3 ], [  ] ], index := 1 ),
          rec( label := [ [ 0, 1 ], [ 3 ] ], index := 8 ),
          rec( label := [ [ 0, 1, 3 ], [  ] ], index := 4 ),
          rec( label := [ [ 0, 1, 2, 3 ], [ 1 ] ], index := 35 ) ] ),
  rec( isoc := "B", l := 3, q := 3, isot := [ "sc" ], identifier := "2.O7(3)",
      labelingfrom := "O7(3)" ),
  rec( isoc := "B", l := 3, q := 3, isot := [ "simple" ], identifier := "O7(3)",
      labelingfrom := "O7(3).2" ),
  rec( isoc := "B", l := 3, q := 5, isot := [ "ad" ], identifier := "O7(5).2",
      labeling := [ rec( label := [ [ 1, 2, 3 ], [ 0, 1 ] ], index := 63 ),
          rec( label := [ [ 1, 2 ], [ 1 ] ], index := 42 ),
          rec( label := [ [ 0, 1, 3 ], [ 1, 2 ] ], index := 75 ),
          rec( label := [ [ 0, 1, 2, 3 ], [ 1, 2, 3 ] ], index := 234 ),
          rec( label := [ [ 1, 3 ], [ 0 ] ], index := 9 ),
          rec( label := [ [ 0, 2 ], [ 2 ] ], index := 25 ),
          rec( label := [ [ 0, 3 ], [ 1 ] ], index := 11 ),
          rec( label := [ [ 0, 1, 2 ], [ 1, 3 ] ], index := 74 ),
          rec( label := [ [ 3 ], [  ] ], index := 1 ),
          rec( label := [ [ 0, 1 ], [ 3 ] ], index := 8 ),
          rec( label := [ [ 0, 1, 3 ], [  ] ], index := 6 ),
          rec( label := [ [ 0, 1, 2, 3 ], [ 1 ] ], index := 52 ) ] ),
  rec( isoc := "B", l := 3, q := 5, isot := [ "simple" ], identifier := "O7(5)",
      labelingfrom := "O7(5).2" ) 
] );


#############################################################################
##
#E

