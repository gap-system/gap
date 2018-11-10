#############################################################################
##
#W  files.gi                    GAP Library                      Frank Celler
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the methods for files and directories.
##

Unbind(InfoTempDirectories);

DeclareInfoClass("InfoTempDirectories");
SetInfoLevel(InfoTempDirectories,1);



#############################################################################
##

#R  IsDirectoryRep  . . . . . . . . . . default representation of a directory
##
if IsHPCGAP then
DeclareRepresentation( "IsDirectoryRep", IsReadOnlyPositionalObjectRep, [] );
else
DeclareRepresentation( "IsDirectoryRep", IsPositionalObjectRep, [] );
fi;

#############################################################################
##
#V  DirectoryType . . . . . . . . . . . . . . . . default type of a directory
##
BindGlobal( "DirectoryType", NewType(
    DirectoriesFamily,
    IsDirectory and IsDirectoryRep ) );

#############################################################################
##
#M  Directory( <str> )  . . . . . . . . . . . . create a new directory object
##
InstallMethod( Directory,
    "string",
    [ IsString ],
function( str )
    str := UserHomeExpand(str);
    #
    # ':' or '\\' probably are untranslated MSDOS or MaxOS path
    # separators, but ':' in position 2 may be OK
    #
    if '\\' in str or (':' in str and str[2] <> ':') then
        Error( "<str> must not contain '\\' or ':'" );
    fi;
    if Length( str ) > 0 and str[Length(str)] = '/'  then
        str := Immutable(str);
    else
        str := Immutable( Concatenation( str, "/" ) );
    fi;
    return Objectify( DirectoryType, [str] );
end );

# Make Directory() idempotent, like String() and Int()
InstallOtherMethod( Directory, "directory", [ IsDirectory ], IdFunc );

#############################################################################
##
#M  EQ( <dir1>, <dir2> ) . . . . . . . . . . . equality for directory objects
##  
InstallMethod( EQ,
   "for two directories",
   [ IsDirectory, IsDirectory ],
   function( d1, d2 ) return d1![1] = d2![1]; end );


#############################################################################
##
#M  ViewObj( <directory> )  . . . . . . . . . . . . . view a directory object
##
InstallMethod( ViewObj,
    "default directory rep",
    [ IsDirectoryRep ],
function( obj )
    Print( "dir(\"", obj![1] ,"\")" );
end );


#############################################################################
##
#M  PrintObj( <directory> ) . . . . . . . . . . . .  print a directory object
##
InstallMethod( PrintObj,
    "default directory rep",
    [ IsDirectoryRep ],
function( obj )
    Print( "Directory(\"", obj![1] ,"\")" );
end );


#############################################################################
##

#M  Filename( <directory>, <string> ) . . . . . . . . . . . create a filename
##
InstallMethod( Filename,
    "for a directory and a string",
    [ IsDirectory,
      IsString ],
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
    "for a list and a string",
    [ IsList, IsString ],
function( dirs, name )
    local   dir,  new, newgz;

    for dir  in dirs  do
        new := Filename( dir, name );
        newgz := Concatenation(new,".gz");
        if IsExistingFile(new) = true or IsExistingFile(newgz) = true then
            return new;
        fi;
    od;
    return fail;
end );

#############################################################################
##
#M  ExternalFilename( <directory>, <string> )
#M  ExternalFilename( <directories>, <string> )
##
BindGlobal("MakeExternalFilename",
  function(name)
    local path, prefix;
    if ARCH_IS_WINDOWS() and name <> fail then
        prefix := First( [ "/proc/cygdrive/", "/cygdrive/" ], s -> StartsWith( name, s ) );
        if prefix <> fail then
            path := Concatenation("C:",name{[Length(prefix)+2..Length(name)]});
            path[1] := name[Length(prefix)+1]; # drive name
            return ReplacedString(path,"/","\\");
        else
            return ReplacedString(name,"/","\\");
        fi;
    else
        return name;
    fi;
  end);

InstallMethod( ExternalFilename, "for a directory and a string",
  [ IsDirectory, IsString ],
  function( d, s )
    return MakeExternalFilename(Filename(d,s));
  end );

InstallMethod( ExternalFilename, "for a directory list and a string",
  [ IsList, IsString ],
  function( d, s )
    return MakeExternalFilename(Filename(d,s));
  end );

#############################################################################
##
#F  DirectoryContents(<name>)
## 
InstallGlobalFunction(DirectoryContents, function(dirname)
  local str;
  if IsDirectory(dirname) then
    dirname := dirname![1];
  else
    # to make ~/mydir work
    dirname := UserHomeExpand(dirname);
  fi;
  str := STRING_LIST_DIR(dirname);
  if str = fail then
    Error("Could not open ", dirname, " as directory,\nsee LastSystemError();");
  fi;
  # Why is this file read before string.gd ???
  return SplitStringInternal(str, "", "\000");
end);


#############################################################################
##
#M  Read( <filename> )  . . . . . . . . . . . . . . . . . . .  read in a file
##
READ_INDENT := "";
if IsHPCGAP then
    MakeThreadLocal("READ_INDENT");
fi;

InstallMethod( Read,
    "string",
    [ IsString ],
function ( name )
    local   readIndent,  found;

    name := UserHomeExpand(name);

    readIndent := SHALLOW_COPY_OBJ( READ_INDENT );
    APPEND_LIST_INTR( READ_INDENT, "  " );
    if GAPInfo.CommandLineOptions.D then
    	Print( "#I", READ_INDENT, "Read( \"", name, "\" )\n" );
    fi;
    found := (IsReadableFile(name)=true) and READ(name);
    READ_INDENT := readIndent;
    if GAPInfo.CommandLineOptions.D and
       found and READ_INDENT = ""  then
        Print( "#I  Read( \"", name, "\" ) done\n" );
    fi;
    if not found  then
        Error( "file \"", name, "\" must exist and be readable" );
    fi;
end );


#############################################################################
##
#M  ReadAsFunction( <filename> )  . . . . . . . . . . read a file as function
##
InstallMethod( ReadAsFunction,
    "string",
    [ IsString ],
    name -> READ_AS_FUNC( UserHomeExpand( name ) ) );  


#############################################################################
##
#M  Edit( <filename> )  . . . . . . . . . . . . . . . . .  edit and read file
##

# The editor can be specified at startup time via a user preference.
DeclareUserPreference( rec(
  name:= [ "Editor", "EditorOptions" ],
  description:= [
    "Determines the editor and options (used by GAPs 'Edit' command).  \
Under Mac OS X, the value \"open\" for Editor will work. For further options, \
see the GAP help for 'Edit'.  \
If you want to use the editor defined in your (shell) environment then \
leave the 'Editor' and 'EditorOptions' preferences empty."
    ],
  default:= function()    # copied from GAPInfo.READENVPAGEREDITOR
    local str, sp;
    if IsBound(GAPInfo.KernelInfo.ENVIRONMENT.EDITOR) then
      str := GAPInfo.KernelInfo.ENVIRONMENT.EDITOR;
      sp := SplitStringInternal(str, "", " \n\t\r");
      if Length(sp) > 0 then
        return [ sp[1], sp{[2..Length(sp)]} ];
      fi;
    fi;
    return [ "vi", [] ];
    end,
  check:= function( editor, editoroptions )
    return IsString( editor ) and IsList( editoroptions )
                              and ForAll( editoroptions, IsString );
    end,
  ) );

InstallGlobalFunction( Edit, function( name )
    local   editor,  ret;

    name := UserHomeExpand(name);
    editor := Filename( DirectoriesSystemPrograms(), UserPreference("Editor") );
    if editor = fail  then
        Error( "cannot locate editor `", UserPreference("Editor"),
                          "' (reset via SetUserPreference(\"Editor\", ...))" );
    fi;
    ret := Process( DirectoryCurrent(), editor, InputTextUser(), 
                    OutputTextUser(), Concatenation(
                    UserPreference("EditorOptions"), [ name ]) );
    if ret <> 0  then
        Error( "editor returned ", ret );
    fi;
    Read(name);
end );


# try to find the HOME directory in the environment.
BindGlobal("StringHOMEPath",function()
local env;
  if IsBound(GAPInfo.UserHome) then
    return GAPInfo.UserHome;
  fi;
  env:=GAPInfo.SystemEnvironment;
  if IsRecord(env) then
    env:=env.HOME;
  else
    env:=First(env,x->Length(x)>5 and x{[1..5]}="HOME=");
    env:=env{[6..Length(env)]};
  fi;
  return env;
end);

InstallGlobalFunction(DirectoryHome,function()
local a,h,d;
  if ARCH_IS_WINDOWS() then
    h:=StringHOMEPath();
    d:=List(DirectoryContents(h),LowercaseString);
    a:=First(["My Documents", #en
          "Documents", #en-win8
	      "Eigene Dateien", #de
	      "Documenti", #it
	      "Mes documents", #fr
	      "Mijn documenten", #nl
	      "Meus documentos", #pt
	      "Mis documentos", #es
	      "Mina dokument", #sv
	      "Mine dokumenter", #no
	      "Dokumentumok", #hu
	      "Dokumenty", #cz
	      "Moje dokumenty", #po
	      "Omat tiedostot", #fi
	      "Î¤Î± Î­Î³Î³ÏÎ±Ï†Î¬ Î¼Î¿Ï…", #gr
	      "ÐœÐ¾Ð¸ Ð”Ð¾ÐºÑƒÐ¼ÐµÐ½Ñ‚Ñ‹", #ru
	      ],x->LowercaseString(x) in d);
    if a<>fail then
      if h[Length(h)]<>'/' then
        h := Concatenation(h,"/");
      fi;
      return Directory(Concatenation(h,a));
    else
      return Directory(StringHOMEPath());
    fi;
  else
    return Directory(StringHOMEPath());
  fi;
end);

InstallGlobalFunction(DirectoryDesktop,function()
local a,h,d;
  h:=StringHOMEPath();
  if ARCH_IS_WINDOWS() then
    d:=List(DirectoryContents(h),LowercaseString);
    a:=First(["Desktop",
	      "Bureau", #fr
	      "Bureaublad", #nl
	      "Escritorio", #es
	      "Î•Ï€Î¹Ï†Î¬Î½ÎµÎ¹Î± ÎµÏÎ³Î±ÏƒÎ¯Î±Ï‚", #gr
	     ],x->LowercaseString(x) in d);
    if a<>fail then
      if h[Length(h)]<>'/' then
        h := Concatenation(h,"/");
      fi;
      return Directory(Concatenation(h,a));
    else
      return Directory(StringHOMEPath());
    fi;
  else
    d:=List(DirectoryContents(h),LowercaseString);
    a:=First(["Desktop",
	      "Bureau", #fr
	      "Bureaublad", #nl
	      "Escritorio", #es
	     ],x->LowercaseString(x) in d);
    if a<>fail then
      if h[Length(h)]<>'/' then
        h := Concatenation(h,"/");
      fi;
      return Directory(Concatenation(h,a));
    else
      return Directory(h);
    fi;
  fi;
end);

InstallGlobalFunction(RemoveDirectoryRecursively,
  function(dirname)
    # dirname must be a string
    local Dowork;
    if not(IsDir(dirname) = 'D') then
        Error("dirname must be a directory");
        return fail;
    fi;
    while Length(dirname) > 0 and dirname[Length(dirname)] = '/' do
        Unbind(dirname[Length(dirname)]);
    od;
    if Length(dirname) = 0 then
        Error("dirname must be nonempty");
        return fail;
    fi;
    Dowork := function(pathname)
      # pathname does not end in a / and is known to be a proper directory
      local c,f,fullname,what;
      c := DirectoryContents(pathname);
      for f in c do
          if f <> "." and f <> ".." then
              fullname := Concatenation(pathname,"/",f);
              what := IsDir(fullname);
              if what = 'D' then
                  Dowork(fullname);
              else
                  RemoveFile(fullname);
              fi;
          fi;
      od;
      return RemoveDir(pathname);
    end;
    return Dowork(dirname);
  end );


#############################################################################
##
#E
