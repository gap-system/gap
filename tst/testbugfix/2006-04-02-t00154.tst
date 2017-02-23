# 2006/04/02 (AH)
gap> F:=FreeGroup("x","y","z");;
gap> x:=F.1;;y:=F.2;;z:=F.3;;
gap> rels:=[x^2,y^2,z^4,Comm(z^-2,x),(z*x)^4,Comm(z^-1,y)^2,
> (y*x)^4,(Comm(z,y)*x)^2,(Comm(y,z^-1)*x)^2,(y*z)^6,
> z^-1*y*z^-1*x*z*y*z^-1*x*z*y*z^-1*x*z*y*z*x,y*z*x*z*y*x*y*z^-1*x*y*z^-1*x*y*z*x*y*z^-1*x];;
gap> G:=F/rels;;
gap> x:=G.1;;y:=G.2;;z:=G.3;;
gap> s3:=Subgroup(G,[ z*y*z*y^-1, z^-1*y*z^-1*y^-1, y*z*x*z^-1*y^-1*x^-1,
> z*x*y*z*x^-1*y^-1 ]);;
gap> L:=LowIndexSubgroupsFpGroup(G,s3,4);;
gap> Assert(0,Length(L)=27);
