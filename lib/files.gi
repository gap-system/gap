#############################################################################
##
#W  files.gi                    GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for files and directories.
##
Revision.files_gi :=
    "@(#)$Id$";


#############################################################################
##

#R  IsDirectoryRep  . . . . . . . . . . default representation of a directory
##
IsDirectoryRep := NewRepresentation(
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
    if '\\' in str or ':' in str  then
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
#M  PrintObj( <directory> ) . . . . . . . . . . . .  print a directory object
##
InstallMethod( PrintObj,
    "default directory rep",
    true,
    [ IsDirectoryRep ],
    0,
        
function( obj )
    Print( "dir(\"", obj![1] ,"\")" );
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
InstallMethod( Filename,
    "string",
    true,
    [ IsList,
      IsString ],
    0,

function( dirs, name )
    local   dir,  new;

    for dir  in dirs  do
        new := Filename( dir, name );
        if IsExistingFile(new)  then
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
    found := IsReadableFile(name) and READ(name);
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

#E  files.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here
##
