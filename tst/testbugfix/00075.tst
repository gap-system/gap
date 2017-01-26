# 2005/05/18 (TB)
gap> t:= Runtime();;
gap> CayleyGraphSemigroup( Monoid( Transformation([2,3,4,5,6,1,7]),
>      Transformation([6,5,4,3,2,1,7]), Transformation([1,2,3,4,6,7,7]) ) );;
gap> if Runtime() - t > 5000 then
>      Print( "#E  efficiency problem with enumerators of semigroups!\n" );
> fi;
