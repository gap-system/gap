#############################################################################
##
#W  process.gd                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for process.
##
Revision.process_gd :=
    "@(#)$Id$";


#############################################################################
##
#O  Process( <dir>, <prg>, <in>, <out>, <args> )  . . . . . . start a process
##
Process := NewOperation(
    "Process",
    [ IsDirectory, IsString, IsInputStream, IsOutputStream, IsList ] );


#############################################################################
##

#E  process.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
