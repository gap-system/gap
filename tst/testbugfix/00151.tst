# 2006/08/28 (FL)
gap> time1 := 0;;
gap> for j in [1..10] do
> l:=List([1..100000],i->[i]);
> t1:=Runtime(); for i in [1..100000] do a := PositionSorted(l,[i]); od; t2:=Runtime();
> time1 := time1 + (t2-t1);
> od;
gap> time2 := 0;;
gap> for j in [1..10] do
> l := Immutable( List([1..100000],i->[i]) );
> t1:=Runtime(); for i in [1..100000] do a := PositionSorted(l,[i]); od; t2:=Runtime();
> time2 := time2 + (t2-t1);
> od;
gap> if time1 >= 2*time2 then
> Print("Bad timings for bugfix 2006/08/28 (FL): ", time1, " >= 2*", time2, "\n"); 
> fi; # time1 and time2 should be about the same
