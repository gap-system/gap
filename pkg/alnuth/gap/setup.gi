#############################################################################
##
#W setup.gi         Alnuth - ALgebraic NUmber THeory        Andreas Distler
##

#############################################################################
##
#F ChangeGlobalVariable( name, val )
##
InstallGlobalFunction(ChangeGlobalVariable, function(name, val)

    MakeReadWriteGlobal(name);
    UnbindGlobal(name);
    BindGlobal(name, val);

end);

#############################################################################
##
#F SetPariStackSize( size )
##
InstallGlobalFunction( SetPariStackSize, function( size )

    # test input
    while not IsPosInt( size ) do 
        Error("<size>, the amount of memory in MB, must be a positive integer");
    od;

    # set global variable to given value
    ChangeGlobalVariable("AL_STACKSIZE", 
                         Concatenation("-s", String(size), "M"));

end );

#############################################################################
##
#F SetAlnuthExternalExecutable( path )
##
InstallGlobalFunction( SetAlnuthExternalExecutable, function( path )

    # tests wether there is an executable file behind <path>
    while Filename( DirectoriesSystemPrograms( ), path ) = fail and
       not IsExecutableFile( path ) do
        Error( "<path> has to be an executable" );
    od;
    
    if not IsExecutableFile( path ) then
        path := Filename( DirectoriesSystemPrograms( ), path );
        if not IsExecutableFile( path ) then
            Info( InfoWarning, 1, "No permission to execute ", path );
            return fail;
        fi;
    fi;

    if SuitablePariExecutable(path) then
        # set AL_EXECUTABLE
        ChangeGlobalVariable("AL_EXECUTABLE", path);
        return path;
    else
        return fail;
    fi;
end );

#############################################################################
##
#F SuitablePariExecutable( path )
##
InstallGlobalFunction( SuitablePariExecutable, function( path )
    local str, pos, version;

    # try to find out, if it is a suitable version of PARI/GP
    str := "";
    Process( DirectoryCurrent( ), path, InputTextNone( ),
             OutputTextString( str, false ), [ "-f" ] );
    if PositionSublist( str, "PARI" ) = fail then
        Info(InfoWarning, 1, path,
             " does not seem to be an executable for PARI/GP.");
        return false;
    fi;

    pos := PositionSublist( str, "Version " );
    if pos = fail then
        Info(InfoWarning, 1, path,
             " does not seem to be an executable for PARI/GP.");
        return false;
    else
        # go to beginning of version number
        pos := pos + 8;
    fi;

    # check version number, should be 2.5.X, has to be at least 2.3.X 
    version := str{[ pos..pos+PositionProperty(str{[ pos..Length(str) ]},
                                               char-> char = ' ') - 2 ]};
    if not CompareVersionNumbers(version, "2.5") then
        Info( InfoWarning, 1, path,
             " seems to be an executable for PARI/GP Version ",
             version, ", but Alnuth needs PARI/GP Version 2.5 or higher." );
        return false;
    fi;

    return true;
end );


#############################################################################
##
#F PariVersion( )
##
InstallGlobalFunction( PariVersion, function( )
    local str;

    if IsExecutableFile(AL_EXECUTABLE) then
        # use the command line option to obtain version number of PARI/GP
        str := "";
        Process( DirectoryCurrent( ), AL_EXECUTABLE, InputTextNone( ),
                 OutputTextString( str, false ), [ "--version-short" ] );
        Print( str );
    fi;
end );

#############################################################################
##
#F SetAlnuthExternalExecutablePermanently( path )
##
InstallGlobalFunction( SetAlnuthExternalExecutablePermanently, function( path )
    SetAlnuthExternalExecutable( path );
    if not IsWritableFile(Filename(DirectoriesPackageLibrary("alnuth", ""),
                          "defs.g")) then
        Info(InfoWarning, 1, "No write access to file <defs.g>.");
        return AL_EXECUTABLE;
    fi;

    PrintTo(Filename(DirectoriesPackageLibrary("alnuth", ""), "defs.g"),
            "###########################################################",
            "##################\n##\n##  AL_EXECUTABLE\n##\n##  ",
            "Here 'AL_EXECUTABLE', the path to the executable of PARI/GP, ",
            "is set.\n##  Depending on the installation of PARI/GP the entry",
            "may have to be changed.\n##  See '4.3 Adjust the path of the ",
            "executable for PARI/GP' for details.\n##\n",
            "if not IsBound(AL_EXECUTABLE) then\n",
            "    BindGlobal( \"AL_EXECUTABLE\", \"", AL_EXECUTABLE,"\" );\n",
            "fi;\n");

    return AL_EXECUTABLE;
end );

#############################################################################
##
#F RestoreAlnuthExternalExecutablePermanently( )
##
InstallGlobalFunction( RestoreAlnuthExternalExecutablePermanently, function( )
    if not IsWritableFile(Filename(DirectoriesPackageLibrary("alnuth", ""),
                          "defs.g")) then
        Info(InfoWarning, 1, "No write access to file <defs.g>.");
        return fail;
    fi;
    PrintTo(Filename(DirectoriesPackageLibrary("alnuth", ""), "defs.g"),
            "###########################################################",
            "##################\n##\n##  AL_EXECUTABLE\n##\n##  ",
            "Here 'AL_EXECUTABLE', the path to the executable of PARI/GP, ",
            "is set.\n##  Depending on the installation of PARI/GP the entry",
            "may have to be changed.\n##  See '4.3 Adjust the path of the ",
            "executable for PARI/GP' for details.\n##\n",
            "if not IsBound(AL_EXECUTABLE) then\n",
            "    BindGlobal(\"AL_EXECUTABLE\", ",
            "Filename(DirectoriesSystemPrograms(), \"gp\"));\n",
            "fi;\n");
end );

#############################################################################
##
#E