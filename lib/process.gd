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
    local   cmd,  shell,  dir,  out;

    if not Length( arg ) in [1,2] then
        return Error( "usage: Exec( <cmd> [, <shell>] )" );
    fi;

    cmd := arg[1];

    ##  Select the shell, bourne shell is the default.
    if Length( arg ) = 1 then
        shell := Filename( DirectoriesSystemPrograms(), "sh" );
    else
        shell := Filename( DirectoriesSystemPrograms(), arg[2] );
    fi;

    ##  Execute in the current directory.
    dir := DirectoryCurrent();

    ##  Output goes to standard out.
    out := OutputTextFile( "*stdout*", false );

    ##  Execute the command.
    Process( dir, shell, InputTextNone(), out, [ "-c", cmd ] );

    ##  Close the output stream.
    CloseStream( out );
end;


#############################################################################
##

#E  process.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
