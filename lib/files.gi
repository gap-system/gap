Filename := function( dirs, name )

    for dir  in dirs  do
        new := Filename( dir, name );
        if IsExistingFile(new)  then
            return new;
        fi;
    od;
    return fail;

end;


Filename := function( dir, name )
    return Concatenation( dir!.dirname, name );
end;


DIRS_SYSTEM_PROGRAMS := Immutable( List(
    DIRECTORIES_SYSTEM_PROGRAMS. 
    x -> Directory(x) ) );


DirectoriesSystemPrograms := function()
    return DIRS_SYSTEM_PROGRAMS;
end;


DIR_CURRENT := Directory("./");


DirectoryCurrent := function()
    return DIR_CURRENT;
end;


DirectoriesPackagePrograms := function( name )
    arch := GAP_ARCHITECTURE;
    dirs := [];
    for dir  in GAP_ROOT_PATHS  do
        path := Concatenation( dir, "pkg/", name, "bin/", arch, "/" );
        Add( dirs, Directory(path) );
    od;
    return dirs;
end;


DirectoriesLibrary := function( arg )
    local   name,  dirs,  dir,  path;

    if 0 = Length(arg)  then
        name := "lib";
    elif 1 = Length(arg)  then
        name := arg[1];
    else
        Error( "DirectoriesLibrary( [<name>] )" );
    fi;

    dirs := [];
    for dir  in GAP_ROOT_PATHS  do
        path := Concatenation( dir, name );
        Add( dirs, Directory(path) );
    od;

    return dirs;
end;


Directory := function( str )
    return Objectify( IsDirectory and IsDirectoryRep,
                      rec( dirname := Immutable(str) ) );
end;




