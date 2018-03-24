gap> START_TEST("gprdmat.tst");

#
# MatDirectProduct
#
gap> G:=GL(3,2);;
gap> H:=GL(2,3);;

# Inputs must be defined in same characteristic
gap> MatDirectProduct(G, H);
"TRY_NEXT_METHOD"

#
# one factor
#
gap> H := MatDirectProduct(G);;
gap> G = H;
true
gap> pi := Projection(H,1);;
gap> iota := Embedding(H,1);;
gap> IdentityMapping(G) = iota * pi;
true
gap> IdentityMapping(H) = pi * iota;
true

#
# two factors
#
gap> G1 := GL(3,2);;
gap> G2 := GL(2,4);;
gap> H := MatDirectProduct(G1, G2);;
gap> Size(G1) * Size(G2) = Size(H);
true

#
gap> pi1 := Projection(H,1);;
gap> pi2 := Projection(H,2);;
gap> iota1 := Embedding(H,1);;
gap> iota2 := Embedding(H,2);;
gap> IdentityMapping(G1) = iota1 * pi1;
true
gap> IdentityMapping(G2) = iota2 * pi2;
true
gap> Size(Image(iota1 * pi2));
1
gap> Size(Image(iota2 * pi1));
1

#
gap> ForAll(G1, g -> PreImagesRepresentative(iota1, ImagesRepresentative(iota1, g)) = g);
true
gap> ForAll(G2, g -> PreImagesRepresentative(iota2, ImagesRepresentative(iota2, g)) = g);
true
gap> Size(Images(pi1,KernelOfMultiplicativeGeneralMapping(pi1)));
1
gap> Size(Images(pi2,KernelOfMultiplicativeGeneralMapping(pi1)));
180
gap> Size(Images(pi1,KernelOfMultiplicativeGeneralMapping(pi2)));
168
gap> Size(Images(pi2,KernelOfMultiplicativeGeneralMapping(pi2)));
1

#
# MatWreathProduct
#
gap> G:=SL(2,2);;
gap> H:=MatWreathProduct(G, Group( (1,2,3) ));
<matrix group of size 648 with 3 generators>
gap> Size(H) = Size(G)^3 * 3;
true
gap> iota1 := Embedding(H,1);;
gap> iota2 := Embedding(H,2);;
gap> iota3 := Embedding(H,3);;

#
# TensorWreathProduct
#
gap> G:=SL(2,2);;
gap> H:=TensorWreathProduct(G, Group( (1,2,3) ));;
gap> Size(H);
648

#
gap> STOP_TEST("gprdmat.tst", 1);
