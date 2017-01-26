# 2013/03/07 (MH)
gap> s:="cba";
"cba"
gap> IsSSortedList(s);
false
gap> IsInt(RNamObj(s));
true
gap> r:=rec(cba := 1);;
gap> IsBound(r.(s));
true
