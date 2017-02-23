# 2006/10/23 (FL)
gap> s := "";; for i in [0..255] do Add(s, CHAR_INT(i)); od;
gap> fnam := Filename(DirectoryTemporary(), "guck");;
gap> FileString(fnam, s);;
gap> f := InputTextFile(fnam);;
gap> a := [0..255];; if ARCH_IS_WINDOWS() then a[14]:=10; fi;
gap> List([0..255], i-> ReadByte(f)) = a;
true
gap> RemoveFile(fnam);
true
