# 2014/08/11 (AH)
gap> eij:=function(i,j)
> local I;
> I:=Z(2)*IdentityMat(5);
> I[i][j]:=Z(2);
> return I;
> end;;
gap> G2:=Group([eij(1,2),eij(2,3),eij(3,4),eij(4,5),eij(2,1),eij(4,3)]);;
gap> Length(NormalSubgroups(G2));
16
