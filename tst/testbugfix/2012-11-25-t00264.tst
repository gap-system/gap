# 2012/11/25 (AK)
# Fix of a bug that was reproducible in GAP 4.5.6 with FGA 1.1.1
# (20/05/26):  gap> Image(iso,PreImagesRepresentative(iso,f.1));
# cannot be made to work because the code for the NC version is in a package
gap> f := FreeGroup(2);
<free group on the generators [ f1, f2 ]>
gap> iso:=GroupHomomorphismByImagesNC(f,f,[f.1*f.2,f.1*f.2^2],[f.2^2*f.1,f.2*f.1]); 
[ f1*f2, f1*f2^2 ] -> [ f2^2*f1, f2*f1 ]
gap> SetIsSurjective(iso,true);
gap> Image(iso,PreImagesRepresentativeNC(iso,f.1));
f1
