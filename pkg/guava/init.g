#############################################################################
##
#A  init.g                  GUAVA library                       Reinald Baart
#A                                                         Jasper Cramwinckel
#A                                                            Erik Roijackers
#A                                                                Eric Minkes
#A                                                                 Lea Ruscio
#A                                                               David Joyner
##
#H  @(#)$Id: init.g,v 1.12 2004/12/20 21:26:05 gap Exp $
## added read divisors.gd 11-2004
##

##
##  Announce the package version and test for the existence of the binary.
##
DeclarePackage( "guava", "2.0",
  function()
    local path;

    if not CompareVersionNumbers( VERSION, "4.3" ) then
        Info( InfoWarning, 1,
              "Package ``GUAVA'': requires at least GAP 4.3" );
        return fail;
    fi;

    # Test for existence of the compiled binary
    path := DirectoriesPackagePrograms( "guava" );

    if ForAny( ["desauto", "leonconv", "wtdist"], 
               f -> Filename( path, f ) = fail ) then
        Info( InfoWarning, 1,
              "Package ``GUAVA'': the C code programs are not compiled." );
        Info( InfoWarning, 1,
              "Some GUAVA functions, e.g. `ConstantWeightSubcode', ",
              "will be unavailable. ");
        Info( InfoWarning, 1,
              "See ?Installing GUAVA" );
    fi;

    return true;
  end );

DeclarePackageAutoDocumentation( "GUAVA", "doc", "GUAVA",
                                 "GUAVA Coding Theory Package" );

ReadPkg("guava", "lib/codeword.gd");   
ReadPkg("guava", "lib/divisors.gd"); 
ReadPkg("guava", "lib/codegen.gd"); 
ReadPkg("guava", "lib/matrices.gd");
ReadPkg("guava", "lib/codeman.gd"); 
ReadPkg("guava", "lib/nordrob.gd"); 
ReadPkg("guava", "lib/util.gd"); 
ReadPkg("guava", "lib/util2.gd"); 
ReadPkg("guava", "lib/codeops.gd"); 
ReadPkg("guava", "lib/bounds.gd"); 
ReadPkg("guava", "lib/codefun.gd"); 
ReadPkg("guava", "lib/decoders.gd"); 
ReadPkg("guava", "lib/codecr.gd");
ReadPkg("guava", "lib/codecstr.gd");
ReadPkg("guava", "lib/codemisc.gd");
ReadPkg("guava", "lib/codenorm.gd");
ReadPkg("guava", "lib/tblgener.gd"); 
ReadPkg("guava", "lib/toric.gd"); 

