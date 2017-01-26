# 2009/03/13 (FL)
gap> b:=BlistList([1..4],[1,2]);
[ true, true, false, false ]
gap> b{[1,2]} := [false,false];
[ false, false ]
gap> IsBlistRep(b);
true
