# Test bad slices in blists
gap> l := List([true,true,true]);
[ true, true, true ]
gap> IsBlist(l);
true
gap> l{[1..1]};
[ true ]
gap> l{[1..2]};
[ true, true ]
gap> l{[1..3]};
[ true, true, true ]
gap> l{[1..4]};
Error, List Elements: <list>[4] must have an assigned value
gap> l{[1..5]};
Error, List Elements: <list>[5] must have an assigned value
gap> l{[1..15]};
Error, List Elements: <list>[15] must have an assigned value
