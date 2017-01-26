# 2007/08/08 (SL)
gap> l := [1,2,3];;
gap> for i in [2] do Print(IsBound(l[10^20]),"\n"); od;
false
