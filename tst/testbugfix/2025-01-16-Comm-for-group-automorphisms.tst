#@local F,x1,x2,x3,x4,A,u,v,hom
# The 'IsBijective' and 'Comm's call below used to trigger coset enumeration.
# See issue https://github.com/gap-system/gap/issues/3898 and also
# https://github.com/gap-system/gap/issues/5910
gap> F:=FreeGroup("x1","x2","x3","x4");;
gap> x1:=F.1;;x2:=F.2;;x3:=F.3;;x4:=F.4;;
gap> A:=GroupHomomorphismByImages(F,F,[x1,x2,x3,x4],[x1,x2,x2*x3^-1*x2,x4]);;
gap> u:=(A*A)^A;;
gap> v:=(A*A)^A;;
gap> IsBijective(u*v);  # used to hang
true
gap> (u*v)(x1);  # verify that computing images works
x1
gap> hom:=Comm(u,v);;  # used to hang
gap> IsGroupHomomorphism(hom);
true
gap> hom(x1);  # verify that computing images works
x1
