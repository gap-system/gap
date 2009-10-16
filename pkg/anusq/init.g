#############################################################################
##
#W  init.g                   ANUSQ Package                   Alexander Hulpke
##
#H  @(#)$Id: init.g,v 1.2 2002/06/12 19:15:18 gap Exp $
##

##  Announce the package version and test for the existence of the binary

DeclarePackage( "anusq", "0.1",
  function()
  local file;
    # Check that the version no. of GAP is ok.
    if not(IsBound( CompareVersionNumbers ) and 
           CompareVersionNumbers( VERSION, "4.3" )) then
      Info(InfoWarning, 1,
           "Package ``anusq'': Sorry! ANUSQ needs at least GAP 4.2");
      return false;
    fi;
    # Test for existence of the compiled binary
    file := Filename(DirectoriesPackagePrograms("anusq"), "Sq");
    if file = fail then
      Info(InfoWarning, 1,
           "Package ``anusq'': The program `anusq' is not compiled");
    fi;
    return file<>fail;
  end
);

##  Install the documentation
DeclarePackageAutoDocumentation( "anusq", "doc" );

#############################################################################
##
#R  Read the actual code.
##
ReadPkg( "anusq", "gap/sq.g" );

