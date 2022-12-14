#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#F  Partition( <list> ) . . . . . . . . . . . . . . . . partition constructor
##
DeclareGlobalFunction("Partition");

#############################################################################
##
#F  PartitionSortedPoints( <list> )
##
DeclareGlobalFunction("PartitionSortedPoints");


#############################################################################
##
#F  IsPartition( <P> )  . . . . . . . . . . . . test if object is a partition
##
DeclareGlobalFunction( "IsPartition" );
#T state this in the definition of a partition!


#############################################################################
##
#F  NumberCells( <P> )  . . . . . . . . . . . . . . . . . . . number of cells
##
DeclareGlobalFunction( "NumberCells" );


#############################################################################
##
#F  Cell( <P>, <m> )  . . . . . . . . . . . . . . . . . . . . .  cell as list
##
DeclareGlobalFunction( "Cell" );


#############################################################################
#F  Cells( <Pi> ) . . . . . . . . . . . . . . . . . partition as list of sets
##
DeclareGlobalFunction( "Cells" );

#############################################################################
##
#F  CellNoPoint( <part>,<pnt> )
##
##  Number of cell that contains <pnt>.
##
DeclareGlobalFunction("CellNoPoint");

#############################################################################
##
#F  PointInCellNo( <part>,<pnt>,<no> )
##
##  Is <pnt> in cell <no> of <part>?
##
DeclareGlobalFunction("PointInCellNo");

#############################################################################
##
#F  CellNoPoints( <part>,<pntlst> )
##
##  Numbers of cell that contains <pntlst>.
##
DeclareGlobalFunction("CellNoPoints");


#############################################################################
##
#F  Fixcells( <P> ) . . . . . . . . . . . . . . . . . . . .  fixcells as list
##
##  Returns a list of the points along in their  cell, ordered as these cells
##  are ordered
##
DeclareGlobalFunction( "Fixcells" );


#############################################################################
##
#F  SplitCell( <P>, <i>, <Q>, <j>, <g>, <out> ) . . . . . . . .  split a cell
##
##  Splits <P>[ <i> ],  by taking out all  the points that are also contained
##  in <Q>[ <j> ]  ^ g. The  new cell is appended to  <P> unless it would  be
##  empty. If the old cell would remain empty, nothing is changed either.
##
##  Returns the length of the new cell, or `false' if nothing was changed.
##
##  Shortcuts of  the  splitting algorithm:  If  the last  argument  <out> is
##  `true', at least one point will  move out. If <out> is  a number, at most
##  <out> points will move out.
##
DeclareGlobalFunction( "SplitCell" );


#############################################################################
##
#F  IsolatePoint( <P>, <a> )  . . . . . . . . . . . . . . . . isolate a point
##
##  Takes point <a> out of its cell in <P>, putting it into a new cell, which
##  is appended to <P>. However, does nothing, if <a> was already isolated.
##
##  Returns the  number of the cell   from <a> was  taken out,  or `false' if
##  nothing was changed.
##
DeclareGlobalFunction( "IsolatePoint" );

#############################################################################
##
#F  UndoRefinement( <P> ) . . . . . . . . . . . . . . . . . undo a refinement
##
##  Undoes the  effect of   the  last  cell-splitting actually performed   by
##  `SplitCell' or `IsolatePoint'. (This means that  if the last call of such
##  a function had no effect, `UndoRefinement' looks at the second-last etc.)
##  This fuses the last cell of <P> with an earlier cell.
##
##  Returns  the number of the  cell with which  the  last cell was fused, or
##  `false'   if the last  cell starts   at  `<P>.points[1]', because then it
##  cannot have been split off.
##
##  May behave undefined if there was no splitting before.
##
DeclareGlobalFunction( "UndoRefinement" );


#############################################################################
##
#F  FixpointCellNo( <P>, <i> )  . . . . . . . . .  fixpoint from cell no. <i>
##
##  Returns the first point of <P>[ <i> ] (should be a one-point cell).
##
DeclareGlobalFunction( "FixpointCellNo" );


#############################################################################
##
#F  FixcellPoint( <P>, <old> )  . . . . . . . . . . . . . . . . . . . . local
##
##  Returns a random cell number which is not yet contained  in <old> and has
##  length 1.
##
##  Adds this cell number to <old>.
##
DeclareGlobalFunction( "FixcellPoint" );


#############################################################################
##
#F  FixcellsCell( <P>, <Q>, <old> )  . . . . . . . . . . . local
##
##  Returns [ <K>, <I>  ] such that  for j=1,...|K|=|I|,  all points  in cell
##  <P>[  <I>[j] ] have value  <K>[j] in <Q.cellno> (i.e.,
##  lie   in cell <K>[j]  of the partition <Q>.
##  Returns `false' if <K> and <I> are empty.
##
DeclareGlobalFunction( "FixcellsCell" );


#############################################################################
##
#F  TrivialPartition( <Omega> ) . . . . . . . . . one-cell partition of a set
##
DeclareGlobalFunction( "TrivialPartition" );


#############################################################################
##
#F  OrbitsPartition( <G>, <Omega> ) partition determined by the orbits of <G>
##
DeclareGlobalFunction( "OrbitsPartition" );


#############################################################################
##
#F  SmallestPrimeDivisor( <size> )  . . . . . . . . .  smallest prime divisor
##
DeclareGlobalFunction( "SmallestPrimeDivisor" );


#############################################################################
##
#F  CollectedPartition( <P>, <size> ) . orbits on cells under group of <size>
##
##  Returns a  partition into unions of cells  of <P> of equal length, sorted
##  by  this length. However,  if there are $n$ cells  of equal length, which
##  cannot be fused under the action of a group of  order <size> (because $n$
##  < SmallestPrimeDivisor(  <size>  )), leaves   these $n$  cells   unfused.
##  (<size> = 1 suppresses this extra feature.)
##
DeclareGlobalFunction( "CollectedPartition" );
