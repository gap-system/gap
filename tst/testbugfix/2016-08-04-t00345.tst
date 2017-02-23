#2016/8/4 (AH, Reported by D. Savchuk)
gap> r1:=PolynomialRing(GF(2),3);
GF(2)[x_1,x_2,x_3]
gap> x_1:=r1.1;;x_2:=r1.2;;x_3:=r1.3;;
gap> I:=Ideal(r1,[x_1^2-x_2,x_2^2-x_1,x_1*x_2-x_3]);;
gap> Size(r1/I);
16
gap> r1:=PolynomialRing(GF(2),4);;
gap> x_1:=r1.1;;x_2:=r1.2;;x_3:=r1.3;;x_4:=r1.4;;
gap> rels:=[x_1^2+x_2,x_1*x_2+x_3,x_1*x_3+x_4, x_1*x_4+x_1,x_2^2+x_4,
>   x_2*x_3+x_1,x_2*x_4+x_2,x_3^2+x_2,x_3*x_4+x_3,x_4^2+x_4];;
gap> Size(r1/Ideal(r1,rels));
32
