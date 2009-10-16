DeclarePackage("monoid","1.0",
  function()
  local path,file;
    # test for existence of the compiled binary
    #path:=DirectoriesPackagePrograms("example");
    #file:=Filename(path,"hello");
    #if file=fail then
      #Info(InfoWarning,1,
        #"Package ``example'': The program `hello' is not compiled");
    #fi;
    #return file<>fail;
	return true;
  end);


