#############################################################################
##
#W  uctype2D.g            GAP 4 package `ctbllib'      Michael Cla\3en-Houben
##
#H  @(#)$Id: uctype2D.g,v 1.1 2005/05/17 08:51:03 gap Exp $
##
#Y  Copyright (C)  2005,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains Deligne-Lusztig names of $^2D$ type groups.
##
Revision.( "ctbllib/dlnames/uctype2D_g" ) :=
    "@(#)$Id: uctype2D.g,v 1.1 2005/05/17 08:51:03 gap Exp $";


Append( DeltigLibUnipotentCharacters, [
  rec( isoc := "2D", l := 4, q := 2, isot := [ "ad", "sc", "simple" ],
      identifier := "O8-(2)",
      labeling := [ rec( label := [ [ 1, 2, 3 ], [ 0 ] ], index := 5 ),
          rec( label := [ [ 0, 2, 3 ], [ 1 ] ], index := 8 ),
          rec( label := [ [ 0, 1, 2, 4 ], [ 1, 2 ] ], index := 19 ),
          rec( label := [ [ 0, 1, 2, 3, 4 ], [ 1, 2, 3 ] ], index := 36 ),
          rec( label := [ [ 1, 3 ], [  ] ], index := 2 ),
          rec( label := [ [ 0, 1, 3 ], [ 2 ] ], index := 9 ),
          rec( label := [ [ 0, 1, 4 ], [ 1 ] ], index := 4 ),
          rec( label := [ [ 0, 1, 2, 3 ], [ 1, 3 ] ], index := 25 ),
          rec( label := [ [ 0, 4 ], [  ] ], index := 1 ),
          rec( label := [ [ 0, 1, 2 ], [ 3 ] ], index := 6 ) ] ),
  rec( isoc := "2D", l := 5, q := 2, isot := [ "ad", "sc", "simple" ],
      identifier := "O10-(2)",
      labeling := [ rec( label := [ [ 1, 2, 3, 4 ], [ 0, 1 ] ], index := 28
             ), rec( label := [ [ 1, 2, 3 ], [ 1 ] ], index := 33 ),
          rec( label := [ [ 0, 1, 3, 4 ], [ 1, 2 ] ], index := 47 ),
          rec( label := [ [ 0, 1, 2, 3, 5 ], [ 1, 2, 3 ] ], index := 75 ),
          rec( label := [ [ 0, 1, 2, 3, 4, 5 ], [ 1, 2, 3, 4 ] ],
              index := 110 ),
          rec( label := [ [ 1, 2, 4 ], [ 0 ] ], index := 9 ),
          rec( label := [ [ 0, 2, 3 ], [ 2 ] ], index := 31 ),
          rec( label := [ [ 0, 2, 4 ], [ 1 ] ], index := 17 ),
          rec( label := [ [ 0, 1, 2, 4 ], [ 1, 3 ] ], index := 56 ),
          rec( label := [ [ 0, 1, 2, 5 ], [ 1, 2 ] ], index := 24 ),
          rec( label := [ [ 0, 1, 2, 3, 4 ], [ 1, 2, 4 ] ], index := 95 ),
          rec( label := [ [ 2, 3 ], [  ] ], index := 7 ),
          rec( label := [ [ 0, 1, 4 ], [ 2 ] ], index := 15 ),
          rec( label := [ [ 0, 1, 2, 3 ], [ 2, 3 ] ], index := 60 ),
          rec( label := [ [ 1, 4 ], [  ] ], index := 2 ),
          rec( label := [ [ 0, 1, 3 ], [ 3 ] ], index := 19 ),
          rec( label := [ [ 0, 1, 5 ], [ 1 ] ], index := 4 ),
          rec( label := [ [ 0, 1, 2, 3 ], [ 1, 4 ] ], index := 40 ),
          rec( label := [ [ 0, 5 ], [  ] ], index := 1 ),
          rec( label := [ [ 0, 1, 2 ], [ 4 ] ], index := 8 ) ] )
] );


#############################################################################
##
#E

