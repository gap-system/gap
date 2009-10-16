#############################################################################
####
##
#W  anupqios.gd            ANUPQ package                          Greg Gamble
##
##  This file declares core functions used with streams.
##    
#H  @(#)$Id: anupqios.gd,v 1.2 2002/03/01 14:06:09 gap Exp $
##
#Y  Copyright (C) 2001  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.anupqios_gd :=
    "@(#)$Id: anupqios.gd,v 1.2 2002/03/01 14:06:09 gap Exp $";

#############################################################################
##
#F  PQ_START( <workspace>, <setupfile> ) . . . open a stream for a pq process
##
DeclareGlobalFunction( "PQ_START" );

#############################################################################
##
#F  PqStart(<G>,<workspace> : <options>) . Initiate interactive ANUPQ session
#F  PqStart(<G> : <options>)
#F  PqStart(<workspace> : <options>)
#F  PqStart( : <options>)
##
DeclareGlobalFunction( "PqStart" );

#############################################################################
##
#F  PqQuit( <i> )  . . . . . . . . . . . . . . . . .  User version of PQ_QUIT
#F  PqQuit()
##
DeclareGlobalFunction( "PqQuit" );

#############################################################################
##
#F  PqQuitAll() . . . . . . . . . . . .  Close all interactive ANUPQ sessions
##
DeclareGlobalFunction( "PqQuitAll" );

#############################################################################
##
#F  ANUPQ_IOINDEX . . . . the number identifying an interactive ANUPQ session
##
DeclareGlobalFunction( "ANUPQ_IOINDEX" );

#############################################################################
##
#F  ANUPQ_IOINDEX_ARG_CHK .  Checks ANUPQ_IOINDEX has the right no. of arg'ts
##
DeclareGlobalFunction( "ANUPQ_IOINDEX_ARG_CHK" );

#############################################################################
##
#F  ANUPQDataRecord([<i>]) . . . . . . . returns the data record of a process
##
DeclareGlobalFunction( "ANUPQDataRecord" );

#############################################################################
##
#F  PqProcessIndex( <i> ) . . . . . . . . . . . User version of ANUPQ_IOINDEX
#F  PqProcessIndex()
##
DeclareGlobalFunction( "PqProcessIndex" );

#############################################################################
##
#F  PqProcessIndices() . . . . the list of active interactive ANUPQ processes
##
DeclareGlobalFunction( "PqProcessIndices" );

#############################################################################
##
#F  IsPqProcessAlive( <i> ) . .  checks an interactive ANUPQ process iostream
#F  IsPqProcessAlive()
##
DeclareGlobalFunction( "IsPqProcessAlive" );

#############################################################################
##
#V  PQ_MENUS . . . . . . . . . . . data describing the menus of the pq binary
##
DeclareGlobalVariable( "PQ_MENUS",
  "A record containing data describing the tree of menus of the pq binary"
  );

#############################################################################
##
#F  PQ_MENU( <datarec>, <newmenu> ) . . . . . . change/get menu of pq process
#F  PQ_MENU( <datarec> )
##
DeclareGlobalFunction( "PQ_MENU" );

#############################################################################
##
#F  IS_PQ_PROMPT( <line> ) . . . .  checks whether the line is a prompt of pq
##
DeclareGlobalFunction( "IS_PQ_PROMPT" );

#############################################################################
##
#F  IS_ALL_PQ_LINE( <line> ) . checks whether line is a complete line from pq
##
DeclareGlobalFunction( "IS_ALL_PQ_LINE" );

#############################################################################
##
#F  PQ_READ_ALL_LINE . . read a line from a stream until a sentinel character
##
DeclareGlobalFunction( "PQ_READ_ALL_LINE" );

#############################################################################
##
#F  PQ_READ_NEXT_LINE .  read complete line from stream but never return fail
##
DeclareGlobalFunction( "PQ_READ_NEXT_LINE" );

#############################################################################
##
#F  FLUSH_PQ_STREAM_UNTIL(<stream>,<infoLev>,<infoLevMy>,<readln>,<IsMyLine>)
##  . . .  . . . . . . . . . . . read lines from a stream until a wanted line
##
DeclareGlobalFunction( "FLUSH_PQ_STREAM_UNTIL" );

#############################################################################
##
#V  PQ_ERROR_EXIT_MESSAGES . . . error messages emitted by the pq before exit
##
##  A list of the error messages the `pq' emits just before exiting.
##
DeclareGlobalVariable( "PQ_ERROR_EXIT_MESSAGES",
  "A list of the error messages the pq emits just before exiting" );

#############################################################################
##
#F  FILTER_PQ_STREAM_UNTIL_PROMPT( <datarec> )
##
DeclareGlobalFunction( "FILTER_PQ_STREAM_UNTIL_PROMPT" );

#############################################################################
##
#F  ToPQk( <datarec>, <cmd>, <comment> ) . . . . . . .  writes to a pq stream
##
DeclareGlobalFunction( "ToPQk" );

#############################################################################
##
#F  ToPQ(<datarec>, <cmd>, <comment>) . .  write to pq (& for iostream flush)
##
DeclareGlobalFunction( "ToPQ" );

#############################################################################
##
#F  ToPQ_BOOL( <datarec>, <optval>, <comment> ) . . . .  pass a boolean to pq
##    
DeclareGlobalFunction( "ToPQ_BOOL" );

#############################################################################
##
#F  PqRead( <i> )  . . .  primitive read of a single line from ANUPQ iostream
#F  PqRead()
##
DeclareGlobalFunction( "PqRead" );

#############################################################################
##
#F  PqReadAll( <i> ) . . . . . read all current output from an ANUPQ iostream
#F  PqReadAll()
##
DeclareGlobalFunction( "PqReadAll" );

#############################################################################
##
#F  PqReadUntil( <i>, <IsMyLine> ) .  read from ANUPQ iostream until a cond'n
#F  PqReadUntil( <IsMyLine> )
#F  PqReadUntil( <i>, <IsMyLine>, <Modify> )
#F  PqReadUntil( <IsMyLine>, <Modify> )
##
DeclareGlobalFunction( "PqReadUntil" );

#############################################################################
##
#F  PqWrite( <i>, <string> ) . . . . . . .  primitive write to ANUPQ iostream
#F  PqWrite( <string> )
##
DeclareGlobalFunction( "PqWrite" );

#############################################################################
##
#F  ANUPQ_ARG_CHK( <funcname>, <args> ) . . . . check args of int/non-int fns
##
DeclareGlobalFunction( "ANUPQ_ARG_CHK" );

#############################################################################
##
#F  PQ_COMPLETE_NONINTERACTIVE_FUNC_CALL( <datarec> )
##
DeclareGlobalFunction( "PQ_COMPLETE_NONINTERACTIVE_FUNC_CALL" );

#############################################################################
##
#F  ToPQLog([<filename>]) . . . . . . log or stop logging pq commands to file
##
DeclareGlobalFunction( "ToPQLog" );

#E  anupqios.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here 
