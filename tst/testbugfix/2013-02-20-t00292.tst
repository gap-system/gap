# 2013/02/20 (AK)
gap> QuotientMod(4, 2, 6);
fail
gap> QuotientMod(2, 4, 6);
fail
gap> a := ZmodnZObj(2, 6);; b := ZmodnZObj(4, 6);;
gap> a/b;
fail
gap> b/a;
fail
