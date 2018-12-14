# test for fpgroup homs on mixed generators (fixing #3100)
gap> f := FreeGroup(18);;
gap> q := f / [ f.1*f.3*f.7, f.2*f.6*f.8, f.4*f.18*f.14, f.5*f.13*f.9, f.10*f.12*f.16,
> f.11*f.15*f.17, f.1*f.6, f.2*f.7, f.3*f.18, f.4*f.13, f.5*f.8, f.9*f.12, f.10*f.15, f.11*f.16,
> f.14*f.17 ];;
gap> src := [ q.3^-1*q.2^-1, q.2, q.3, q.4, q.5, q.2*q.3, q.7, q.8, q.9, q.10, q.11, q.12, q.13,
> q.14, q.15, q.16, q.17, q.18 ];;
gap> dst := [ q.16, q.10, q.12, q.13, q.14, q.11, q.15, q.17, q.18, q.1, q.2, q.3, q.4, q.5, q.6,
> q.7, q.8, q.9 ];;
gap> hom := GroupHomomorphismByImages(q,q,src,dst);;
gap> inv := GroupHomomorphismByImages(q,q,dst,src);;
gap> IsMapping(hom);
true
gap> IsMapping(inv);
true
