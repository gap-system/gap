#############################################################################
##
#W  process.gi                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for process.
##
Revision.process_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  Process( <dir>, <prg>, <in-none>, <out-none>, <args> )  . . . . none/none
##
InstallMethod( Process,
    true,
    [ IsDirectory and IsDirectoryRep,
      IsString,
      IsInputTextNone,
      IsOutputTextNone,
      IsList ],
    0,

function( dir, prg, input, output, args )

    # get the directory path
    dir := dir![1];

    # convert the args
    args := List( args, String );

    # check path and program
    if not IsDirectoryPath(dir)  then
        Error( "directory <dir> does not exist" );
    fi;
    if not IsExecutableFile(prg)  then
        Error( "program <prg> does not exist" );
    fi;

    # execute the process
    return ExecuteProcess( dir, prg, -1, -1, args );

end );


#############################################################################
##
#M  Process( <dir>, <prg>, <in-text>, <out-none>, <args> )  . . . . file/none
##
InstallMethod( Process,
    true,
    [ IsDirectory and IsDirectoryRep,
      IsString,
      IsInputTextStream and IsInputTextFileRep,
      IsOutputTextNone,
      IsList ],
    0,

function( dir, prg, input, output, args )

    # get the directory path
    dir := dir![1];

    # convert the args
    args := List( args, String );

    # check path and program
    if not IsDirectoryPath(dir)  then
        Error( "directory <dir> does not exist" );
    fi;
    if not IsExecutableFile(prg)  then
        Error( "program <prg> does not exist" );
    fi;

    # execute the process
    return ExecuteProcess( dir, prg, input![1], -1, args );

end );


#############################################################################
##
#M  Process( <dir>, <prg>, <in-none>, <out-text>, <args> )  . . . . none/file
##
InstallMethod( Process,
    true,
    [ IsDirectory and IsDirectoryRep,
      IsString,
      IsInputTextNone,
      IsOutputTextStream and IsOutputTextFileRep,
      IsList ],
    0,

function( dir, prg, input, output, args )

    # get the directory path
    dir := dir![1];

    # convert the args
    args := List( args, String );

    # check path and program
    if not IsDirectoryPath(dir)  then
        Error( "directory <dir> does not exist" );
    fi;
    if not IsExecutableFile(prg)  then
        Error( "program <prg> does not exist" );
    fi;

    # execute the process
    return ExecuteProcess( dir, prg, -1, output![1], args );

end );


#############################################################################
##
#M  Process( <dir>, <prg>, <in-text>, <out-text>, <args> )  . . . . file/file
##
EXECUTE_PROCESS_FILE_STREAM := function( dir, prg, input, output, args )

    # get the directory path
    dir := dir![1];

    # convert the args
    args := List( args, String );

    # check path and program
    if not IsDirectoryPath(dir)  then
        Error( "directory <dir> does not exist" );
    fi;
    if not IsExecutableFile(prg)  then
        Error( "program <prg> does not exist" );
    fi;

    # execute the process
    return ExecuteProcess( dir, prg, input![1], output![1], args );

end;


InstallMethod( Process,
    true,
    [ IsDirectory and IsDirectoryRep,
      IsString,
      IsInputTextStream and IsInputTextFileRep,
      IsOutputTextStream and IsOutputTextFileRep,
      IsList ],
    0,
    EXECUTE_PROCESS_FILE_STREAM );


#############################################################################
##
#M  Process( <dir>, <prg>, <input>, <output>, <args> )  . . . . stream/stream
##
InstallMethod( Process,
    true,
    [ IsDirectory and IsDirectoryRep,
      IsString,
      IsInputTextStream,
      IsOutputTextStream,
      IsList ],
    0,

function( dir, prg, input, output, args )
    local   name_input,  new,  name_output,  res,  new_output,  tmp;

    # convert input into a file
    if not IsInputTextFileRep(input)  then
        name_input := TmpName();
        new := OutputTextFile( name_input, true );
        tmp := ReadAll(input);
        if tmp <> fail  then WriteAll( new, tmp );  fi;
        CloseStream(new);
        input := InputTextFile( name_input );
    fi;

    # convert output into a file
    if not IsOutputTextFileRep(output)  then
        name_output := TmpName();
        new_output  := OutputTextFile( name_output, true );
    else
        new_output  := output;
    fi;

    # call the process
    res := EXECUTE_PROCESS_FILE_STREAM( dir, prg, input, new_output, args );

    # remove temporary file
    if IsBound(name_input)  then
        CloseStream(input);
        RemoveFile(name_input);
    fi;

    if IsBound(name_output)  then
        CloseStream(new_output);
        new := InputTextFile(name_output);
        tmp := ReadAll(new);
        if tmp <> fail  then WriteAll( output, tmp );  fi;
        CloseStream(new);
        RemoveFile(name_output);
    fi;

    # return result of process
    return res;

end );


#############################################################################
##

#E  process.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
