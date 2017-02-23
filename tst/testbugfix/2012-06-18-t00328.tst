# 2012/06/18 (MH)
gap> if LoadPackage("anupq",false) <> fail then
> for i in [1..192] do Q:=Pq( FreeGroup(2) : Prime:=3, ClassBound:=1 ); od; fi;
