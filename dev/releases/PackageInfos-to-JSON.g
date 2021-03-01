LoadPackage("json");

InstallMethod(_GapToJsonStreamInternal,
[IsOutputStream, IsObject],
function(o, x)
    PrintTo(o, "null");
end);

out := OutputTextUser();
r := rec();
for n in RecNames(GAPInfo.PackagesInfo) do
  # Ensure there is only one version of each package
  x := GAPInfo.PackagesInfo.(n);
  #Assert(0, Length(x) = 1);
  x := x[1];
  # Remove the GAPROOT prefix from the package installation path
  for root in GAPInfo.RootPaths do
    x.InstallationPath := ReplacedString(x.InstallationPath, root, "");
  od;
  # put it all back
  r.(n) := x;
od;
GapToJsonStream(out, r);;
QUIT;
