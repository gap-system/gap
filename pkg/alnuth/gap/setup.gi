#############################################################################
##
#W  setup.gi            Alnuth -  Kant interface            Andreas Distler
##
##  An installation of a suitable version of either PARI/GP or KANT/KASH is
##  necessary to use most of the functionality in Alnuth.
##  Normally if you managed to install either of the two programs you should
##  have no need to use any of the functions here.
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
            Info( InfoWarning, 1, "No rights to execute ", path );
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
    local str, pos, libstr;

    # try to find out, if it is a suitable version of PARI/GP
    str := "";
    Process( DirectoryCurrent( ), path, InputTextNone( ),
             OutputTextString( str, false ), [ "-f" ] );
    if PositionSublist( str, "PARI" ) = fail then
        Info(InfoAlnuth, 1, 
             "<path> does not seem to be an executable for PARI/GP");
        return false;
    fi;

    # check version number, must be at least 2.3.X
    pos := PositionSublist( str, "Version " );
    if pos = fail then
        Info(InfoAlnuth, 1,
             "<path> does not seem to be an executable for PARI/GP");
        return false;
    fi;
    if Int([str[pos+8]]) < 2 or Int([str[pos+10]]) < 3 then
        Info(InfoAlnuth, 1, 
             "<path> seems to be an executable for PARI/GP Version ",
             str{[pos+8..pos+12]},
             ", but Alnuth needs PARI/GP Version 2.3 or higher");
        return false;
    fi;

    return true;
end );

#############################################################################
##
#F SetAlnuthExternalExecutablePermanently( path )
##
InstallGlobalFunction( SetAlnuthExternalExecutablePermanently, function( path )
    SetAlnuthExternalExecutable( path );
    PrintTo(Filename(DirectoriesPackageLibrary("alnuth", ""), "defs.g"),
            "###########################################################",
            "##################\n##\n##  AL_EXECUTABLE\n##\n##  ",
            "Here 'AL_EXECUTABLE', the path to the executable of PARI/GP, ",
            "is set.\n##  Depending on the installation of PARI/GP the entry",
            "may have to be changed.\n##  See '4.3 Adjust the path of the ",
            "executable for PARI/GP' for details.\n##\n",
            "if not IsBound(AL_EXECUTABLE) then\n",
            "    BindGlobal( \"AL_EXECUTABLE\", \"", AL_EXECUTABLE,"\" );\n",
            "fi;");

    return AL_EXECUTABLE;
end );

#############################################################################
##
#F RestoreAlnuthExternalExecutablePermanently( )
##
InstallGlobalFunction( RestoreAlnuthExternalExecutablePermanently, function( )
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
            "fi;");
end );

#############################################################################
##
#E