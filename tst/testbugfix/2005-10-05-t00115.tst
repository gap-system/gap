# 2005/10/05 (SL and MN)
gap> p := PermList(Concatenation([2..10000],[1]));;
gap> for i in [1..1000000] do a := p^0; od; time1 := time;;
gap> for i in [1..1000000] do a := OneOp(p); od; time2 := time;;
gap> if time1 <= 3 * time2 then Print("Fix worked\n"); fi;
Fix worked
