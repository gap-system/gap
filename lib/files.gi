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
    if Length( str ) > 0 and Last(str) = '/'  then
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
    # on Windows, drive letters and backslashes are part of valid paths
    if not ARCH_IS_WINDOWS() and ( '\\' in name or ':' in name ) then
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
        # on native Windows, executables carry an .exe suffix which
        # Cygwin's filesystem layer resolves transparently; here we
        # must probe for it ourselves
        if ARCH_IS_WINDOWS() and IsExistingFile(Concatenation(new, ".exe")) = true then
            return Concatenation(new, ".exe");
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
  if IsDirectory(dirname) then
    dirname := dirname![1];
  else
    # to make ~/mydir work
    dirname := UserHomeExpand(dirname);
  fi;
  return LIST_DIR(dirname);
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
    local readIndent;

    if GAPInfo.CommandLineOptions.D then
        readIndent := SHALLOW_COPY_OBJ( READ_INDENT );
        APPEND_LIST_INTR( READ_INDENT, "  " );
        Print( "#I", READ_INDENT, "Read( \"", name, "\" )\n" );
    fi;

    if not READ(UserHomeExpand(name)) then
        Error( "file \"", name, "\" must exist and be readable" );
    fi;

    if GAPInfo.CommandLineOptions.D then
        READ_INDENT := readIndent;
        if READ_INDENT = "" then
            Print( "#I  Read( \"", name, "\" ) done\n" );
        fi;
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
    "Determines the editor and options (used by &GAP;'s <Ref Func=\"Edit\"/> \
command).  \
Under macOS, the value <C>\"open\"</C> for <C>Editor</C> will work. \
For further options, \
see the &GAP; help for <Ref Func=\"Edit\"/>.  \
If you want to use the editor defined in your (shell) environment then \
leave the <C>Editor</C> and <C>EditorOptions</C> preferences empty."
    ],
  default:= function()    # copied from GAPInfo.READENVPAGEREDITOR
    local str, sp;
    if IsBound(GAPInfo.KernelInfo.ENVIRONMENT.EDITOR) then
      str := GAPInfo.KernelInfo.ENVIRONMENT.EDITOR;
      sp := SplitStringInternal(str, "", CHARS_WHITESPACE);
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
    editor := PathSystemProgram( UserPreference("Editor") );
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
  h:=StringHOMEPath();
  if h = fail then
    return fail;
  elif ARCH_IS_WINDOWS() then
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
      if Last(h)<>'/' then
        h := Concatenation(h,"/");
      fi;
      return Directory(Concatenation(h,a));
    fi;
  fi;
  return Directory(h);
end);

InstallGlobalFunction(DirectoryDesktop,function()
local a,h,d;
  h:=StringHOMEPath();
  if h = fail then
    return fail;
  elif ARCH_IS_WINDOWS() then
    d:=List(DirectoryContents(h),LowercaseString);
    a:=First(["Desktop",
              "Bureau", #fr
              "Bureaublad", #nl
              "Escritorio", #es
              "Î•Ï€Î¹Ï†Î¬Î½ÎµÎ¹Î± ÎµÏÎ³Î±ÏƒÎ¯Î±Ï‚", #gr
             ],x->LowercaseString(x) in d);
    if a<>fail then
      if Last(h)<>'/' then
        h := Concatenation(h,"/");
      fi;
      return Directory(Concatenation(h,a));
    fi;
  else
    d:=List(DirectoryContents(h),LowercaseString);
    a:=First(["Desktop",
              "Bureau", #fr
              "Bureaublad", #nl
              "Escritorio", #es
             ],x->LowercaseString(x) in d);
    if a<>fail then
      if Last(h)<>'/' then
        h := Concatenation(h,"/");
      fi;
      return Directory(Concatenation(h,a));
    fi;
  fi;
  return Directory(h);
end);

InstallGlobalFunction(RemoveDirectoryRecursively,
  function(dirname)
    # dirname must be a string
    local Dowork;
    if not IS_DIR(dirname) then
        Error("dirname must be a directory");
        return fail;
    fi;
    dirname := ShallowCopy(dirname);
    while Length(dirname) > 0 and Last(dirname) = '/' do
        Remove(dirname);
    od;
    if Length(dirname) = 0 then
        Error("dirname must be nonempty");
        return fail;
    fi;
    Dowork := function(pathname)
      # pathname does not end in a / and is known to be a proper directory
      local c,f,fullname;
      c := DirectoryContents(pathname);
      for f in c do
          if f <> "." and f <> ".." then
              fullname := Concatenation(pathname,"/",f);
              if IS_DIR(fullname) then
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

BindGlobal( "GAP_SHA256_HexOfWords",
function(words)
    local res;

    res := Sum([0..7], i -> words[8-i]*2^(32*i));
    res := LowercaseString(HexStringInt(res));
    # HexStringInt drops leading zero digits, but a SHA256 digest is always
    # 256 bits = 64 hex digits, so left-pad with '0' if the top byte(s) were 0.
    if Length(res) < 64 then
        res := Concatenation(ListWithIdenticalEntries(64 - Length(res), '0'), res);
    fi;
    return res;
end);

InstallGlobalFunction( SHA256State, GAP_SHA256_INIT );

InstallMethod( PrintObj, "for a SHA256 state", [ IsSHA256State ],
function(state)
    Print("<SHA256 state>");
end);

InstallGlobalFunction( UpdateSHA256,
function(state, string)
    if not IsSHA256State(state) then
        ErrorNoReturn("<state> must be a SHA256 state");
    elif not IsString(string) then
        ErrorNoReturn("<string> must be a string");
    fi;

    # CopyToStringRep: the kernel converts its argument to a string in place,
    # which would retype a list of characters belonging to the caller.
    GAP_SHA256_UPDATE(state, CopyToStringRep(string));
end);

InstallGlobalFunction( UpdateSHA256File,
function(state, filename, decompress)
    if not IsSHA256State(state) then
        ErrorNoReturn("<state> must be a SHA256 state");
    elif not IsString(filename) then
        ErrorNoReturn("<filename> must be a string");
    elif not decompress in [ true, false ] then
        ErrorNoReturn("<decompress> must be 'true' or 'false'");
    fi;

    return GAP_SHA256_UPDATE_FILE(state, UserHomeExpand(filename), decompress);
end);

InstallGlobalFunction( HexSHA256,
function(str)
    local s, chunk;

    if IsSHA256State(str) then
        return GAP_SHA256_HexOfWords(GAP_SHA256_DIGEST(str));
    fi;

    s := GAP_SHA256_INIT();
    if IsString(str) then
        GAP_SHA256_UPDATE(s, CopyToStringRep(str));
    elif IsInputStream(str) then
        # read in chunks: the stream may deliver more than fits in memory
        repeat
            chunk := ReadAll(str, 65536);
            if IsString(chunk) and Length(chunk) > 0 then
                GAP_SHA256_UPDATE(s, CopyToStringRep(chunk));
            fi;
        until not IsString(chunk) or Length(chunk) = 0;
    else
        ErrorNoReturn("<str> has to be a string, an input stream, or a ",
                      "SHA256 state");
    fi;

    return GAP_SHA256_HexOfWords(GAP_SHA256_DIGEST(s));
end);

InstallGlobalFunction( HexSHA256File,
function(filename, decompress)
    local s;

    s := SHA256State();
    if UpdateSHA256File(s, filename, decompress) = fail then
        return fail;
    fi;
    return HexSHA256(s);
end);
