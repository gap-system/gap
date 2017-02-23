# 2012/09/14 (SL)
gap> a := BlistList([1,2,3],[1]);;
gap> b := BlistList([1,2,3],[2]);;
gap> c := BlistList([1,2,3],[2,3]);;
gap> MEET_BLIST(a,b);
false
gap> MEET_BLIST(a,c); 
false
gap> MEET_BLIST(b,c);
true
gap> MEET_BLIST(a,a);
true
