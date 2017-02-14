# Check that removing wrong PrintObj method fixes delegations accordingly
# to documented behaviour for PrintObj/ViewObj/Display.
# Reported by TB, fixed by MN on 2012-08-20.
gap> if IsBound(IsXYZ) then MakeReadWriteGlobal("IsXYZ"); Unbind(IsXYZ); fi;
gap> fam := NewFamily("XYZsFamily");;
gap> DeclareCategory("IsXYZ",IsObject);
gap> type := NewType(fam,IsXYZ and IsPositionalObjectRep);;
gap> o := Objectify(type,[]);;
gap> InstallMethod(String,[IsXYZ],function(o) return "XYZ"; end);
gap> o;
XYZ
gap> Print(o,"\n");
XYZ
gap> String(o);
"XYZ"
