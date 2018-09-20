# 2005/08/29 (TB)
gap> x := TestPackageAvailability("ctbllib");;
gap> if x <> fail then
>   x := LoadPackage("ctbllib", "=0.0",false);
> fi;
gap> x;
fail
