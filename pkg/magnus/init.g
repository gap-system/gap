#############################################################################
##
#W    init.g               share package 'example'              Werner Nickel
##
##    @(#)$Id: init.g,v 1.1 2000/04/14 09:19:27 sal Exp $
##

# announce the package version and test for the existence of the binary
DeclarePackage("magnus","0.1",
  function()
  local path,file;
    # test for existence of the compiled binary
    path:=DirectoriesPackagePrograms("example");
    file:=Filename(path,"hello");
    if file=fail then
      Info(InfoWarning,1,
        "Package ``example'': The program `hello' is not compiled");
    fi;
    return file<>fail;
  end);

# install the documentation
DeclarePackageAutoDocumentation( "example", "doc" );

