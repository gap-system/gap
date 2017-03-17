gap> START_TEST("startendwith.tst");
gap> StartsWith("abc", "a");
true
gap> StartsWith("abc", "abc");
true
gap> StartsWith("", "");
true
gap> StartsWith("abc", "abcd");
false
gap> StartsWith("", "abc");
false
gap> StartsWith("abc", "ab");
true
gap> StartsWith("abc", "");
true
gap> StartsWith([1,2,3], [1,2]);
true
gap> StartsWith([1,2], [1,2,3]);
false
gap> StartsWith("abc", ['a', 'b']);
true
gap> StartsWith("abc", "bc");
false
gap> EndsWith("abc", "c");
true
gap> EndsWith("abc", "abc");
true
gap> EndsWith("", "");
true
gap> EndsWith("abc", "abcd");
false
gap> EndsWith("", "abc");
false
gap> EndsWith("abc", "bc");
true
gap> EndsWith("abc", "");
true
gap> EndsWith([1,2,3], [2,3]);
true
gap> EndsWith([1,2], [1,2,3]);
false
gap> EndsWith("abc", ['b', 'c']);
true
gap> STOP_TEST("startendwith.tst", 290000);
