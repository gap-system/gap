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
#F  Exec  . . . . . . . . . . . . . . . . . . . . . . . . . execute a command
##
Exec := function( arg )
    local   cmd,  i,  shell,  dir;

    # simply concatenate the arguments
    cmd := arg[1];
    for i  in [ 2 .. Length(arg) ]  do
        Append( cmd, " " );
        Append( cmd, arg[i] );
    od;

    # select the shell, bourne shell is the default
    shell := Filename( DirectoriesSystemPrograms(), "sh" );

    # execute in the current directory
    dir := DirectoryCurrent();

    # execute the command
    Process( dir, shell, InputTextUser(), OutputTextUser(), [ "-c", cmd ] );

end;


#############################################################################
##

#E  process.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
