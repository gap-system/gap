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
        shell := PathSystemProgram( "cmd.exe" );
        cs := "/C";
    else
        shell := PathSystemProgram( "sh" );
        cs := "-c";
    fi;

    # execute in the current directory
    dir := DirectoryCurrent();

    # execute the command
    Process( dir, shell, InputTextUser(), OutputTextUser(), [ cs, cmd ] );

end );


#############################################################################
##
#F  RunProcess( <cmd>[, <arg1>, ...][, <options>] ) . . . . . run a program
##
# The keys accepted in the options record of RunProcess. Rejecting anything
# else keeps the door open for adding e.g. `error` once GAP can capture the
# standard error stream of a child process (see issue #4657).
BindGlobal( "RUN_PROCESS_OPTIONS", MakeImmutable( [ "directory", "input", "output" ] ) );

InstallGlobalFunction( RunProcess, function( arg )
    local opts, key, cmd, args, a, dir, input, output, result;

    # an options record, if given at all, must be the final argument
    if not IsEmpty(arg) and IsRecord(Last(arg)) then
        opts := Remove(arg);
    else
        opts := rec();
    fi;

    for key in RecNames(opts) do
        if not key in RUN_PROCESS_OPTIONS then
            Error("unsupported option '", key, "'");
        fi;
    od;

    if IsEmpty(arg) then
        Error("must specify a command to execute");
    fi;

    cmd := arg[1];
    if not IsString(cmd) then
        Error("<cmd> must be a string");
    fi;

    # arguments are passed to the command verbatim; no shell ever sees them,
    # so there is nothing to quote or escape here
    args := [];
    for a in arg{[ 2 .. Length(arg) ]} do
        if IsInt(a) then
            a := String(a);
        elif IsString(a) then
            a := ShallowCopy(a);
            ConvertToStringRep(a);
        else
            Error("arguments must be strings or integers");
        fi;
        Add(args, a);
    od;

    # resolve the command name via the system PATH, unless it already is a path
    if not '/' in cmd and not (ARCH_IS_WINDOWS() and '\\' in cmd) then
        a := PathSystemProgram( cmd );
        if a = fail and ARCH_IS_WINDOWS() then
            a := PathSystemProgram( Concatenation( cmd, ".exe" ) );
        fi;
        if a = fail then
            Error("could not locate executable for '", cmd, "'");
        fi;
        cmd := a;
    fi;

    dir := DirectoryCurrent();
    if IsBound(opts.directory) then
        dir := opts.directory;
        if not IsDirectory(dir) then
            Error("<options>.directory must be a directory object");
        fi;
    fi;

    # unlike Exec, pass no input at all unless the caller asks for it
    input := InputTextNone();
    if IsBound(opts.input) then
        input := opts.input;
        if not IsInputStream(input) then
            Error("<options>.input must be an input stream");
        fi;
    fi;

    result := rec();

    # unlike Exec, capture the output instead of printing it, unless the
    # caller provides a stream of their own
    if IsBound(opts.output) then
        output := opts.output;
        if not IsOutputStream(output) then
            Error("<options>.output must be an output stream");
        fi;
    else
        result.output := "";
        output := OutputTextString(result.output, false);
    fi;

    result.status := Process( dir, cmd, input, output, args );

    return result;
end );
