#############################################################################
##
#W  uctypeD.g             GAP 4 package `ctbllib'      Michael Cla\3en-Houben
##
#H  @(#)$Id: uctypeD.g,v 1.1 2005/05/17 08:51:03 gap Exp $
##
#Y  Copyright (C)  2005,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains Deligne-Lusztig names of $D$ type groups.
##
Revision.( "ctbllib/dlnames/uctypeD_g" ) :=
    "@(#)$Id: uctypeD.g,v 1.1 2005/05/17 08:51:03 gap Exp $";


Append( DeltigLibUnipotentCharacters, [
  rec( isoc := "D", l := 4, q := 2, isot := [ "ad", "sc", "simple" ],
      identifier := "O8+(2)",
      labeling := [ rec( label := [ [ 1, 2 ], [ 1, 2 ] ], index := 31 ),
          rec( label := [ [ 1, 2 ], [ 1, 2 ] ], index := 32 ),
          rec( label := [ [ 0, 1, 3 ], [ 1, 2, 3 ] ], index := 50 ),
          rec( label := [ [ 0, 1, 2, 3 ], [ 1, 2, 3, 4 ] ], index := 51 ),
          rec( label := [ [ 1, 2 ], [ 0, 3 ] ], index := 20 ),
          rec( label := [ [ 0, 2 ], [ 1, 3 ] ], index := 27 ),
          rec( label := [ [ 0, 1, 2 ], [ 1, 2, 4 ] ], index := 33 ),
          rec( label := [ [ 2 ], [ 2 ] ], index := 7 ),
          rec( label := [ [ 2 ], [ 2 ] ], index := 8 ),
          rec( label := [ [ 0, 1 ], [ 2, 3 ] ], index := 14 ),
          rec( label := [ [ 1 ], [ 3 ] ], index := 6 ),
          rec( label := [ [ 0, 1 ], [ 1, 4 ] ], index := 9 ),
          rec( label := [ [ 0 ], [ 4 ] ], index := 1 ),
          rec( label := [ [ 0, 1, 2, 3 ], [  ] ], index := 2 ) ] ),
  rec( isoc := "D", l := 4, q := 3, isot := [ "ad" ],
      identifier := "O8+(3).(2^2)_{111}",
      labeling := [ rec( label := [ [ 1, 2 ], [ 1, 2 ] ], index := 108 ),
          rec( label := [ [ 1, 2 ], [ 1, 2 ] ], index := 112 ),
          rec( label := [ [ 0, 1, 3 ], [ 1, 2, 3 ] ], index := 139 ),
          rec( label := [ [ 0, 1, 2, 3 ], [ 1, 2, 3, 4 ] ], index := 209 ),
          rec( label := [ [ 1, 2 ], [ 0, 3 ] ], index := 42 ),
          rec( label := [ [ 0, 2 ], [ 1, 3 ] ], index := 58 ),
          rec( label := [ [ 0, 1, 2 ], [ 1, 2, 4 ] ], index := 116 ),
          rec( label := [ [ 2 ], [ 2 ] ], index := 15 ),
          rec( label := [ [ 2 ], [ 2 ] ], index := 20 ),
          rec( label := [ [ 0, 1 ], [ 2, 3 ] ], index := 38 ),
          rec( label := [ [ 1 ], [ 3 ] ], index := 12 ),
          rec( label := [ [ 0, 1 ], [ 1, 4 ] ], index := 23 ),
          rec( label := [ [ 0 ], [ 4 ] ], index := 1 ),
          rec( label := [ [ 0, 1, 2, 3 ], [  ] ], index := 28 ) ] ),
  rec( isoc := "D", l := 4, q := 3, isot := [ "simple" ],
      identifier := "O8+(3)",
      labeling := [ rec( label := [ [ 1, 2 ], [ 1, 2 ] ], index := 66 ),
          rec( label := [ [ 1, 2 ], [ 1, 2 ] ], index := 67 ),
          rec( label := [ [ 0, 1, 3 ], [ 1, 2, 3 ] ], index := 82 ),
          rec( label := [ [ 0, 1, 2, 3 ], [ 1, 2, 3, 4 ] ], index := 112 ),
          rec( label := [ [ 1, 2 ], [ 0, 3 ] ], index := 24 ),
          rec( label := [ [ 0, 2 ], [ 1, 3 ] ], index := 36 ),
          rec( label := [ [ 0, 1, 2 ], [ 1, 2, 4 ] ], index := 68 ),
          rec( label := [ [ 2 ], [ 2 ] ], index := 9 ),
          rec( label := [ [ 2 ], [ 2 ] ], index := 10 ),
          rec( label := [ [ 0, 1 ], [ 2, 3 ] ], index := 23 ),
          rec( label := [ [ 1 ], [ 3 ] ], index := 8 ),
          rec( label := [ [ 0, 1 ], [ 1, 4 ] ], index := 11 ),
          rec( label := [ [ 0 ], [ 4 ] ], index := 1 ),
          rec( label := [ [ 0, 1, 2, 3 ], [  ] ], index := 16 ) ] ),
  rec( isoc := "D", l := 5, q := 2, isot := [ "ad", "sc", "simple" ],
      identifier := "O10+(2)",
      labeling := [ rec( label := [ [ 0, 2, 3 ], [ 1, 2, 3 ] ], index := 73
             ),
          rec( label := [ [ 0, 1, 2, 4 ], [ 1, 2, 3, 4 ] ], index := 89 ),
          rec( label := [ [ 0, 1, 2, 3, 4 ], [ 1, 2, 3, 4, 5 ] ],
              index := 93 ),
          rec( label := [ [ 1, 2, 3 ], [ 0, 1, 4 ] ], index := 37 ),
          rec( label := [ [ 1, 2 ], [ 1, 3 ] ], index := 42 ),
          rec( label := [ [ 0, 1, 3 ], [ 1, 2, 4 ] ], index := 46 ),
          rec( label := [ [ 0, 1, 2, 3 ], [ 1, 2, 3, 5 ] ], index := 54 ),
          rec( label := [ [ 0, 2 ], [ 2, 3 ] ], index := 23 ),
          rec( label := [ [ 0, 3 ], [ 1, 3 ] ], index := 22 ),
          rec( label := [ [ 0, 1, 2 ], [ 1, 3, 4 ] ], index := 30 ),
          rec( label := [ [ 1, 2 ], [ 0, 4 ] ], index := 10 ),
          rec( label := [ [ 0, 2 ], [ 1, 4 ] ], index := 14 ),
          rec( label := [ [ 0, 1, 2 ], [ 1, 2, 5 ] ], index := 18 ),
          rec( label := [ [ 2 ], [ 3 ] ], index := 6 ),
          rec( label := [ [ 0, 1 ], [ 2, 4 ] ], index := 8 ),
          rec( label := [ [ 1 ], [ 4 ] ], index := 3 ),
          rec( label := [ [ 0, 1 ], [ 1, 5 ] ], index := 4 ),
          rec( label := [ [ 0 ], [ 5 ] ], index := 1 ),
          rec( label := [ [ 0, 1, 2, 4 ], [  ] ], index := 5 ),
          rec( label := [ [ 0, 1, 2, 3, 4 ], [ 1 ] ], index := 13 ) ] )
] );

#############################################################################
##
#E

