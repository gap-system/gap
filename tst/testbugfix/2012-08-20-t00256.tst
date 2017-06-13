# Check that removing wrong PrintObj method fixes delegations accordingly
# to documented behaviour for PrintObj/ViewObj/Display.
# Reported by TB, fixed by MN on 2012-08-20.
gap> fam := NewFamily("XYZsFamily");;
gap> cat := NewCategory("IsXYZ",IsObject);;
gap> type := NewType(fam,cat and IsPositionalObjectRep);;
gap> o := Objectify(type,[]);;
gap> InstallMethod(String,[cat],function(o) return "XYZ"; end);
gap> o;
XYZ
gap> Print(o,"\n");
XYZ
gap> String(o);
"XYZ"
