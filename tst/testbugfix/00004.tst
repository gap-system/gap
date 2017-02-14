##  Check to see if the strongly connected component (Error 3) fix has been
##     installed
##
gap> M := Monoid([Transformation( [ 2, 3, 4, 5, 5 ] ),
> Transformation( [ 3, 1, 4, 5, 5 ] ),
> Transformation( [ 2, 1, 4, 3, 5 ] ) ]);;
gap> Size(GreensLClasses(M)[2])=2;
true
