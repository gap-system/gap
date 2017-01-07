gap> START_TEST("glzmodmz.tst");

#
gap> SizeOfGLdZmodmZ(2,2);
6
gap> SizeOfGLdZmodmZ(2,4);
96
gap> SizeOfGLdZmodmZ(2,1);
Error, GL(2,Integers mod 1) is not a well-defined group, resp. not supported.


#
gap> G:=GL(4,Integers mod 4);
GL(4,Z/4Z)
gap> H:=SL(4,Integers mod 4);
SL(4,Z/4Z)
gap> K:=Sp(4,Integers mod 4);
Sp(4,Z/4Z)

#
gap> NrMovedPoints(Image(NiceMonomorphism(G : cheap)));;
gap> NrMovedPoints(Image(NiceMonomorphism(H : cheap)));;
gap> NrMovedPoints(Image(NiceMonomorphism(K : cheap)));;

#
gap> IsSubgroup(G,H); IsSubgroup(H,K); IsSubgroup(G,K);
true
true
true

#
gap> Size(G); Size(H); Size(K);
1321205760
660602880
737280

#
gap> STOP_TEST("glzmodmz.tst", 10000);
