#2016/2/4 (AH)
gap> N := AlternatingGroup(6);; H := AutomorphismGroup(N);;
gap> G := SemidirectProduct(H, N);;
gap> Size(Image(Embedding(G, 1)))=Size(H);
true
