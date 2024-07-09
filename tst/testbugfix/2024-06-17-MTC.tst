# Fix #5744
gap> f := FreeGroup("a","b");;
gap> g := f / [ f.1*f.1,f.1*f.2*f.1*f.2*f.1*f.2,f.1*f.2*f.2*f.1*f.2^-1 ];;
gap> Size(g);
1
