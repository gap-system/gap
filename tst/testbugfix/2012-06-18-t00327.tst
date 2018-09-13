# 2012/06/18 (FL)
gap> if TestPackageAvailability("cvec") <> fail and
>       LoadPackage("cvec",false) <> fail then
>   mat := [[Z(2)]]; 
>   ConvertToMatrixRep(mat,2); cmat := CMat(mat); cmat := cmat^1000;
> fi;
