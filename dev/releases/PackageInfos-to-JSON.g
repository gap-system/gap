LoadPackage("json");

InstallMethod(_GapToJsonStreamInternal,
[IsOutputStream, IsObject],
function(o, x)
    PrintTo(o, "null");
end);

out := OutputTextUser();
r := rec();
for n in RecNames(GAPInfo.PackagesInfo) do
  x := GAPInfo.PackagesInfo.(n);
  Assert(0, Length(x) = 1);
  x := x[1];
  Unbind(x.InstallationPath);
  r.(n) := x;
od;
GapToJsonStream(out, r);;
QUIT;
