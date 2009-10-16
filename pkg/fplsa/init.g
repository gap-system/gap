#############################################################################
##
#W  init.g                   The FPLSA package                 Vladimir Gerdt
#W                                                           Vladimir Kornyak
##
##  @(#)$Id: init.g,v 1.5 2002/05/03 02:50:15 gap Exp $
##

DeclarePackage( "fplsa", "1.0",
  function()
  local path,file;
    # test for existence of the compiled binary
    path:= DirectoriesPackagePrograms( "fplsa" );
    file:= Filename( path, "fplsa4" );
    if file = fail then
      Info( InfoWarning, 1,
            "Package ``fplsa'': The program `fplsa4' is not compiled" );
    fi;
    return file <> fail;
  end );


DeclarePackageAutoDocumentation( "fplsa", "doc" );

ReadPkg( "fplsa", "gap/fplsa.g" );

#############################################################################
##
#E

