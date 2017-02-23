# 2006/03/03 (FL)
gap> s := "";; str := OutputTextString(s, false);;
gap> for i in [0..255] do WriteByte(str, i); od;
gap> CloseStream(str);
gap> s = List([0..255], CHAR_INT);
true
