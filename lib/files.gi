#############################################################################
##
#W  files.gi                    GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the methods for files and directories.
##
Revision.files_gi :=
    "@(#)$Id$";


#############################################################################
##

#R  IsDirectoryRep  . . . . . . . . . . default representation of a directory
##
DeclareRepresentation(
    "IsDirectoryRep",
    IsPositionalObjectRep,
    [] );


#############################################################################
##
#V  DirectoryType . . . . . . . . . . . . . . . . default type of a directory
##
DirectoryType := NewType(
    DirectoriesFamily,
    IsDirectory and IsDirectoryRep );


#############################################################################
##

#M  Directory( <str> )  . . . . . . . . . . .  create a new directpory object
##
InstallMethod( Directory,
    "string",
    true,
    [ IsString ],
    0,
        
function( str )
    #
    # ':' or '\\' probably are untranslated MSDOS or MaxOS path
    # separators, but ':' in position 2 may be OK
    #
    if '\\' in str or (':' in str and str[2] <> ':') then
        Error( "<str> must not contain '\\' or ':'" );
    fi;
    if str[Length(str)] = '/'  then
        str := Immutable(str);
    else
        str := Immutable( Concatenation( str, "/" ) );
    fi;
    return Objectify( DirectoryType, [str] );
end );





#############################################################################
##
#M  ViewObj( <directory> )  . . . . . . . . . . . . . view a directory object
##
InstallMethod( ViewObj,
    "default directory rep",
    true,
    [ IsDirectoryRep ],
    0,
        
function( obj )
    Print( "dir(\"", obj![1] ,"\")" );
end );


#############################################################################
##
#M  PrintObj( <directory> ) . . . . . . . . . . . .  print a directory object
##
InstallMethod( PrintObj,
    "default directory rep",
    true,
    [ IsDirectoryRep ],
    0,
        
function( obj )
    Print( "Directory(\"", obj![1] ,"\")" );
end );


#############################################################################
##

#M  Filename( <directory>, <string> ) . . . . . . . . . . . create a filename
##
InstallOtherMethod( Filename,
    "string",
    true,
    [ IsDirectory,
      IsString ],
    0,

function( dir, name )
    if '\\' in name or ':' in name  then
        Error( "<name> must not contain '\\' or ':'" );
    fi;
    return Immutable( Concatenation( dir![1], name ) );
end );


#############################################################################
##
#M  Filename( <directories>, <string> ) . . . . . . . . search for a filename
##
InstallMethod( Filename, "string", true, [ IsList, IsString ], 0,
function( dirs, name )
    local   dir,  new;

    for dir  in dirs  do
        new := Filename( dir, name );
        if IsExistingFile(new)=true  then
            return new;
        fi;
    od;
    return fail;

end );


#############################################################################
##
#M  Read( <filename> )  . . . . . . . . . . . . . . . . . . .  read in a file
##
READ_INDENT := "";

InstallMethod( Read,
    "string",
    true,
    [ IsString ],
    0,

function ( name )
    local   readIndent,  found;

    readIndent := SHALLOW_COPY_OBJ( READ_INDENT );
    APPEND_LIST_INTR( READ_INDENT, "  " );
    InfoRead1( "#I", READ_INDENT, "Read( \"", name, "\" )\n" );
    found := (IsReadableFile(name)=true) and READ(name);
    READ_INDENT := readIndent;
    if found and READ_INDENT = ""  then
        InfoRead1( "#I  Read( \"", name, "\" ) done\n" );
    fi;
    if not found  then
        Error( "file \"", name, "\" must exist and be readable" );
    fi;
end );


#############################################################################
##
#M  ReadTest( <filename> )  . . . . . . . . . . . . . . . .  read a test file
##
InstallMethod( ReadTest,
    "string",
    true,
    [ IsString ],
    0,
    READ_TEST );


#############################################################################
##
#M  ReadAsFunction( <filename> )  . . . . . . . . . . read a file as function
##
InstallMethod( ReadAsFunction,
    "string",
    true,
    [ IsString ],
    0,
    READ_AS_FUNC );


#############################################################################
##

#M  Edit( <filename> )  . . . . . . . . . . . . . . . . .  edit and read file
##
InstallGlobalFunction( Edit, function( name )
    local   editor,  ret;

    editor := Filename( DirectoriesSystemPrograms(), EDITOR );
    if editor = fail  then
        Error( "cannot locate editor `", EDITOR, "'" );
    fi;
    ret := Process( DirectoryCurrent(), editor, InputTextUser(), 
                    OutputTextUser(), [ name ] );
    if ret <> 0  then
        Error( "editor returned ", ret );
    fi;
    Read(name);
end );


#############################################################################
##
#M  CreateCompletionFiles( <path> ) . . . . . . . create "lib/readX.co" files
##
InstallGlobalFunction( CreateCompletionFiles, function( arg )
    local   path,  input,  i,  com,  read,  j,  crc;

    # get the path to the output
    if 0 = Length(arg)  then
        path := DirectoriesLibrary("")[1];
    elif 1 = Length(arg)  then
        path := Directory(arg[1]);
    fi;
    input := DirectoriesLibrary("");

    # loop over the list of completable files
    for i  in COMPLETABLE_FILES  do

        # convert "read" into "comp"
        com := Filename( path, ReplacedString( i[1], ".g", ".co" ) );
        if com = fail  then
            Error( "cannot create output file" );
        fi;
        Print( "#I  converting \"", i[1], "\" to \"", com, "\"\n" );

        # now find the input file
        read := List( [1 .. Length(i[2]) ], x 
           -> [ i[2][x], Filename( input, i[2][x] ), i[3][x] ] );
        if ForAny( read, x -> x[2] = fail )  then
            Error( "cannot locate input files" );
        fi;

        # create the completion files
        PRINT_TO( com, "#I  file=\"", i[1], "\"\n\n" );
        for j  in read  do

            # create a crc value
            Print( "#I    parsing \"", j[1], "\"\n" );
            crc := GAP_CRC(j[2]);

            # create ranking list
            APPEND_TO( com, "#F  file=\"", j[1], "\" crc=", crc, "\n" );
            APPEND_TO( com, "RANK_FILTER_LIST  := ", j[3], ";\n",
                            "RANK_FILTER_COUNT := 1;\n\n" );

            # create `COM_FILE' header and `if' start
            APPEND_TO( com, "#C  load module, file, or complete\n" );
            APPEND_TO( com, 
              "COM_RESULT := COM_FILE( \"", j[1], "\", ", crc, " );\n",
              "if COM_RESULT = fail  then\n",
              "Error(\"cannot locate file \\\"", j[1], "\\\"\");\n",
              "elif COM_RESULT = 1  then\n",
              ";\n",
              "elif COM_RESULT = 2  then\n",
              ";\n",
              "elif COM_RESULT = 4  then\n",
              "READ_CHANGED_GAP_ROOT(\"",j[1],"\");\n",
              "elif COM_RESULT = 3  then\n"
            );

            # create completion
            MAKE_INIT( com, j[2] );

            APPEND_TO( com,
              "else\n",
              "Error(\"unknown result code \", COM_RESULT );\n",
              "fi;\n\n",
              "#U  unbind temporary variables\n",
              "Unbind(RANK_FILTER_LIST);\n",
              "Unbind(RANK_FILTER_COUNT);\n",
              "Unbind(COM_RESULT);\n",
              "#E  file=\"", j[1], "\"\n\n"
            );
        od;
    od;
end );

#############################################################################
##
#M  CheckCompletionFiles()  . . . . . . . . . . .  check the completion files
##
InstallGlobalFunction( CheckCompletionFiles, function()
    local   dirs,  file,  com,  stream,  next,  pos,  fname,  crc,  
            lfile,  new,  nook;

    dirs := DirectoriesLibrary("");
    nook := [];
    for file  in COMPLETED_FILES  do
        com := ReplacedString( file, ".g", ".co" );
        Print( "#I  checking \"", com, "\"\n" );
        stream := InputTextFile(com);
        while not IsEndOfStream(stream)  do
            next := ReadLine(stream);
            if next <> fail and next[1] = '#'  then
                if next[2] = 'F'  then

                    # extract the filename
                    pos := 4;
                    while next[pos] <> '"'  do
                        pos := pos + 1;
                    od;
                    pos := pos+1;
                    fname := "";
                    while next[pos] <> '"'  do
                        Add( fname, next[pos] );
                        pos := pos + 1;
                    od;

                    # extract the crc value
                    while next[pos] <> '='  do
                        pos := pos + 1;
                    od;
                    crc := Int(next{[pos+1..Length(next)-1]});

                    # recompute crc
                    lfile := Filename( dirs, fname );
                    if lfile = fail  then
                        Print( "#W   file \"", fname, "\" not found\n" );
                        Add( nook, fname );
                    else
                        new := GAP_CRC( lfile );
                        if new <> crc  then
                            Print( "#W   file \"", fname, "\" not OK\n" );
                            Add( nook, fname );
                        else
                            Print( "#I   file \"", fname, "\" OK\n" );
                        fi;
                    fi;
                fi;
            fi;
        od;
        CloseStream(stream);
    od;
    return nook;
end );


#############################################################################
##


#E  files.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here
##
