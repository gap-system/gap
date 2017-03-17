
if Filename(List(GAPInfo.RootPaths,Directory), 
                                  "gapsync/callpostsync") <> fail then
  Print("\nCalling gapsync/postsync after update . . .\n");
  Exec(Filename(List(GAPInfo.RootPaths,Directory), "gapsync/postsync"));
fi;
