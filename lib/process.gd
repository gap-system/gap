#############################################################################
##
#W  process.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for process.
##
Revision.process_gd :=
    "@(#)$Id$";


#############################################################################
##

#O  Process( <dir>, <prg>, <in>, <out>, <args> )  . . . . . . start a process
##
UNBIND_GLOBAL( "Process" );
DeclareOperation( "Process",
    [ IsDirectory, IsString, IsInputStream, IsOutputStream, IsList ] );


#############################################################################
##
#F  Exec( <str_1>, <str_2>, ..., <str_n> )  . . . . . . . . execute a command
##
##  `Exec' executes the command given by the string obtained from
##  concatenating the strings <str_1>, <str_2>, \ldots, <str_n>
##  after inserting whitespace between them.
##
##  `Exec' calls the more general operation `Process'.
##
DeclareGlobalFunction( "Exec" );


#############################################################################
##

#E  process.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

