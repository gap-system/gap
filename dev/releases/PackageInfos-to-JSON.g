LoadPackage("json");

InstallMethod(_GapToJsonStreamInternal,
[IsOutputStream, IsObject],
function(o, x)
    PrintTo(o, "null");
end);

out := OutputTextUser();
GapToJsonStream(out, GAPInfo.PackagesInfo);;
QUIT;
