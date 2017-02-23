# 2005/12/22 (Robert F. Morse)
gap> g := Image(IsomorphismFpGroup(SmallGroup(8,3)));;
gap> h := Image(IsomorphismFpGroup(SmallGroup(120,5)));;
gap> fp := FreeProduct(g,h);;
gap> IsFpGroup(fp);
true
gap> emb := Embedding(fp,1);;
gap> IsMapping(emb);
true
gap> dp := DirectProduct(g,h);;
gap> IsFpGroup(dp);
true
gap> IdGroup(dp);
[ 960, 5746 ]
gap> IdGroup(Image(Projection(dp,2)));
[ 120, 5 ]
gap> IdGroup(Image(Embedding(dp,1)));
[ 8, 3 ]
