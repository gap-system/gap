#
# Tests for functions defined in src/plist.c
#
gap> START_TEST("kernel/plist.tst");

# GrowPlist
gap> Append([1,2,3], [1..INTOBJ_MAX]);
Error, GrowPlist: List size too large

# ElmPlist
gap> a := MakeImmutable([,2]);; IsDenseList(a);
false
gap> a[1];
Error, List Element: <list>[1] must have an assigned value
gap> a[2];
2
gap> a[3];
Error, List Element: <list>[3] must have an assigned value

# ElmPlistDense
gap> a := MakeImmutable([1,2]);; IsDenseList(a);
true
gap> a[1];
1
gap> a[2];
2
gap> a[3];
Error, List Element: <list>[3] must have an assigned value

# AssPlistEmpty
gap> TNAM_OBJ([Z(2)]);
"plain list of small finite field elements"
gap> TNAM_OBJ([Z(2),1]);
"dense plain list"
gap> TNAM_OBJ([1,Z(2)]);
"dense plain list"

# ASS_PLIST_DEFAULT
gap> ASS_PLIST_DEFAULT(fail, fail, fail);
Error, List Assignment: <pos> must be a positive small integer (not the value \
'fail')
gap> ASS_PLIST_DEFAULT(fail, 1, fail);
Error, <list> must be a mutable plain list (not the value 'fail')

#
gap> STOP_TEST("kernel/plist.tst", 1);
