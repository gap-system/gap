# Temporary hack to make sure that the record components in the JSON file are
# sorted, to increase stability in the output between GAP versions.
# Remove once https://github.com/gap-packages/json/pull/24 is merged+released.
InstallMethod(RecNames, [IsRecord and IsInternalRep], x -> AsSSortedList(REC_NAMES(x)));

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
