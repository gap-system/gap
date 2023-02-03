#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for process.
##


#############################################################################
##
#M  Process( <dir>, <prg>, <in-none>, <out-none>, <args> )  . . . . none/none
##
InstallMethod( Process,
    [ IsDirectory and IsDirectoryRep,
      IsString,
      IsInputTextNone,
      IsOutputTextNone,
      IsList ],
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
    [ IsDirectory and IsDirectoryRep,
      IsString,
      IsInputTextStream and IsInputTextFileRep,
      IsOutputTextNone,
      IsList ],
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
    [ IsDirectory and IsDirectoryRep,
      IsString,
      IsInputTextNone,
      IsOutputTextStream and IsOutputTextFileRep,
      IsList ],
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
BindGlobal( "EXECUTE_PROCESS_FILE_STREAM", function( dir, prg, input, output, args )

    # get the directory path
    dir := dir![1];

    # convert the args
    args := List( args, String );

    # check path and program
    if not IsDirectoryPath(dir)  then
        Error( "directory <dir> does not exist" );
    fi;
    if IsExecutableFile(prg) <> true then
        Error( "program <prg> does not exist or is not executable" );
    fi;

    # execute the process
    return ExecuteProcess( dir, prg, input![1], output![1], args );

end );


InstallMethod( Process,
    [ IsDirectory and IsDirectoryRep,
      IsString,
      IsInputTextStream and IsInputTextFileRep,
      IsOutputTextStream and IsOutputTextFileRep,
      IsList ],
    EXECUTE_PROCESS_FILE_STREAM );


#############################################################################
##
#M  Process( <dir>, <prg>, <input>, <output>, <args> )  . . . . stream/stream
##

PROCESS_INPUT_TEMPORARY := fail;
PROCESS_OUTPUT_TEMPORARY := fail;

MakeThreadLocal("PROCESS_OUTPUT_TEMPORARY");
MakeThreadLocal("PROCESS_INPUT_TEMPORARY");


InstallMethod( Process,
    [ IsDirectory and IsDirectoryRep,
      IsString,
      IsInputTextStream,
      IsOutputTextStream,
      IsList ],
function( dir, prg, input, output, args )
    local   name_input,  new,  name_output,  res,  new_output, alloutput,allinput;

    # convert input into a file
    if not IsInputTextFileRep(input)  then
        if (IsString(PROCESS_INPUT_TEMPORARY) and
          (IsReadableFile(PROCESS_INPUT_TEMPORARY) or
          IsWritableFile(PROCESS_INPUT_TEMPORARY))) then
          PROCESS_INPUT_TEMPORARY:=fail;
        fi;
        while PROCESS_INPUT_TEMPORARY = fail do
            PROCESS_INPUT_TEMPORARY := TmpName();
        od;
        name_input := PROCESS_INPUT_TEMPORARY;
        new := OutputTextFile( name_input, true );
        allinput := ReadAll(input);
        if allinput= fail then
            allinput := "";
        fi;
        WriteAll( new, allinput );
        CloseStream(new);
        input := InputTextFile( name_input );
    fi;

    # convert output into a file
    if not IsOutputTextFileRep(output)  then
        if (IsString(PROCESS_OUTPUT_TEMPORARY) and
          (IsReadableFile(PROCESS_OUTPUT_TEMPORARY) or
          IsWritableFile(PROCESS_OUTPUT_TEMPORARY))) then
          PROCESS_OUTPUT_TEMPORARY:=fail;
        fi;
        while PROCESS_OUTPUT_TEMPORARY = fail do
            PROCESS_OUTPUT_TEMPORARY := TmpName();
        od;
        name_output := PROCESS_OUTPUT_TEMPORARY;
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
        alloutput := ReadAll(new);
        CloseStream(new);
        RemoveFile(name_output);
        if alloutput <> fail then
            WriteAll( output, alloutput );
        fi;
    fi;

    # return result of process
    return res;

end );


#############################################################################
##
#F  Exec( <str_1>, <str_2>, ..., <str_n> )  . . . . . . . . execute a command
##
InstallGlobalFunction( Exec, function( arg )
    local   cmd,  i,  shell,  cs,  dir;

    # simply concatenate the arguments
    cmd := ShallowCopy( arg[1] );
    if not IsString(cmd) then
      Error("the command ",cmd," is not a name.\n",
      "possibly a binary is missing or has not been compiled.");
    fi;
    for i  in [ 2 .. Length(arg) ]  do
        Append( cmd, " " );
        Append( cmd, arg[i] );
    od;

    # select the shell, bourne shell is the default: sh -c cmd
    if ARCH_IS_WINDOWS() then
        # on Windows, we use the native shell such that behaviour does
        # not depend on whether cygwin is installed or not.
        # cmd.exe is preferable to old-style `command.com'
        shell := Filename( DirectoriesSystemPrograms(), "cmd.exe" );
        cs := "/C";
    else
        shell := Filename( DirectoriesSystemPrograms(), "sh" );
        cs := "-c";
    fi;

    # execute in the current directory
    dir := DirectoryCurrent();

    # execute the command
    Process( dir, shell, InputTextUser(), OutputTextUser(), [ cs, cmd ] );

end );
