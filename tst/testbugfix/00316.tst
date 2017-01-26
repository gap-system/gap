#2016/04/14 (Chris Jefferson)
gap> a := "abc";
"abc"
gap> b := "def";
"def"
gap> IsSortedList(a);
true
gap> IsSortedList(b);
true
gap> c := Concatenation(b,a);
"defabc"
gap> HasIsSortedList(c);
false
gap> IsSortedList(c);
false
