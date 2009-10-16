#############################################################################
##
#W  cmeataxe.gi        GAP share package 'cmeataxe'             Thomas Breuer
##
#H  @(#)$Id: cmeataxe.gi,v 1.1 2000/04/19 09:06:30 gap Exp $
##
#Y  Copyright (C)  2000,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.( "cmeataxe/gap/cmeataxe_gi" ) :=
    "@(#)$Id: cmeataxe.gi,v 1.1 2000/04/19 09:06:30 gap Exp $";


############################################################################
##
#V  MeatAxe
##
InstallValue( MeatAxe,
    rec(
                gennames := [],
                alpha    := "abcdefghijklmnopqrstuvwxyz",
                maxnr    := 0
               ) );


#############################################################################
##
#F  CMeatAxeProcess( <dir>, <prog>, <output>, <options> )
##
InstallGlobalFunction( CMeatAxeProcess,
    function( dir, prog, output, options )
    local progname, proc;

    progname:= Filename( DirectoriesPackagePrograms( "cmeataxe" ), prog );
    if progname = fail then
      Error( "no executable for `", prog, "'" );
    fi;
    Info( InfoCMeatAxe, 2, "calling the C-MeatAxe program `", prog, "'" );
    proc:= Process( dir, progname, InputTextNone(), output, options );
    if proc <> 0 then                                                        
      Error( "process for the C-MeatAxe program `", prog,
             "' did not succeed" );
    fi;
    end );


#############################################################################
##
#F  CMeatAxeMaketab( <q> )
##
InstallGlobalFunction( CMeatAxeMaketab, function( q )

    local name;

    if 256 < q then
      Error( "<q> must be at most 256" );
    fi;

    name:= String( q );
    while Length( name ) < 3 do
      name:= Concatenation( "0", name );
    od;
    name:= Concatenation( "p", name );
    Append( name, ".zzz" );

    if not IsExistingFile( Filename( CMeatAxeDirectoryCurrent(), name ) ) then
      Info( InfoCMeatAxe, 1,
            "calling `maketab' for field of size ", q );
      CMeatAxeProcess( CMeatAxeDirectoryCurrent(), "maketab",
                       OutputTextNone(), [ "-Q", String( q ) ] );
    fi;
    end );


#############################################################################
##
#F  CMeatAxeSetDirectory( <dir> )
##
InstallGlobalFunction( CMeatAxeSetDirectory, function( dir )
    if not IsDirectory( dir ) then
      Error( "<dir> must be a directory object" );
    fi;
    Info( InfoCMeatAxe, 1,
          "current C-MeatAxe directory set to `", dir, "'" );
    MeatAxe.CurrentDirectory:= dir;
    end );


#############################################################################
##
#F  CMeatAxeDirectoryCurrent()
##
InstallGlobalFunction( CMeatAxeDirectoryCurrent, function()
    return MeatAxe.CurrentDirectory;
    end );


#############################################################################
##
#F  CMeatAxeNewFilename()
##
InstallGlobalFunction( CMeatAxeNewFilename, function()
    MeatAxe.maxnr:= MeatAxe.maxnr + 1;
    return Filename( MeatAxe.DirectoryCurrent, 
                     WordAlp( MeatAxe.alpha, MeatAxe.maxnr ) );
    end );


#############################################################################
##
#E

