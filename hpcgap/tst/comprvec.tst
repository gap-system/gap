#############################################################################
##
#W  comprvec.tst               GAP Library                Alexander Konovalov
##
##  Testing conversion to compressed vector representation
##
##  To be listed in testinstall.g
##
gap> START_TEST("comprvec.tst");
gap> z:=[Z(2),Z(2),0*Z(2)];
[ Z(2)^0, Z(2)^0, 0*Z(2) ]
gap> z1:=COPY_GF2VEC(z);
<a GF2 vector of length 3>
gap> z2:=COPY_GF2VEC(z1);
<a GF2 vector of length 3>
gap> IsIdenticalObj(z1,z2);
false
gap> z1=z2;
true
gap> NewRowVector(IsGF2VectorRep,GF(2),[Z(2),Z(2)]);
<a GF2 vector of length 2>
gap> CopyToVectorRep(z,2);
<a GF2 vector of length 3>
gap> z:=[Z(3),Z(3),0*Z(3),Z(3)^2];
[ Z(3), Z(3), 0*Z(3), Z(3)^0 ]
gap> Is8BitVectorRep(z);
false
gap> z1:=COPY_VEC8BIT(z,3);
[ Z(3), Z(3), 0*Z(3), Z(3)^0 ]
gap> Is8BitVectorRep(z1);
true
gap> z2:=COPY_VEC8BIT(z1,3);
[ Z(3), Z(3), 0*Z(3), Z(3)^0 ]
gap> IsIdenticalObj(z1,z2);
false
gap> z1=z2;
true
gap> z=z1;
true
gap> z:=[Z(3),Z(3),0*Z(3),Z(3)^2];
[ Z(3), Z(3), 0*Z(3), Z(3)^0 ]
gap> Is8BitVectorRep(z);
false
gap> z1:=CopyToVectorRep(z,3);
[ Z(3), Z(3), 0*Z(3), Z(3)^0 ]
gap> Is8BitVectorRep(z1);
true
gap> z=z1;
true
gap> IsIdenticalObj(z,z1);
false
gap> v := [Z(2)^0,Z(2),Z(2),0*Z(2)];
[ Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2) ]
gap> RepresentationsOfObject(v);
[ "IsPlistRep", "IsInternalRep" ]
gap> w:=CopyToVectorRep(v,2);
<a GF2 vector of length 4>
gap> RepresentationsOfObject(w);
[ "IsDataObjectRep", "IsGF2VectorRep" ]
gap> u:=CopyToVectorRep(w,4);
[ Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2) ]
gap> RepresentationsOfObject(u);
[ "IsDataObjectRep", "Is8BitVectorRep" ]
gap> t:=CopyToVectorRep(v,4);
[ Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2) ]
gap> RepresentationsOfObject(t);
[ "IsDataObjectRep", "Is8BitVectorRep" ]
gap> F:=GF(2^17);;
gap> v:=Filtered(F,x -> x in GF(256));
[ 0z, z0 ]
gap> IS_VECFFE(v);
false
gap> IsFFECollection(v);
true
gap> z:=CopyToVectorRep(v,2);
<a GF2 vector of length 2>
gap> z1:=CopyToVectorRep(v,4);
[ 0*Z(2), Z(2)^0 ]
gap> z2:=CopyToVectorRep(v,256);
[ 0*Z(2), Z(2)^0 ]
gap> z=z1;
true
gap> z1=z2;
true
gap> List([z,z1,z2],x -> IsIdenticalObj(v,x));
[ false, false, false ]
gap> F:=GF(41^3);;
gap> v:=Filtered(F,x -> x in GF(41));;
gap> IS_VECFFE(v);
false
gap> IsFFECollection(v);
true
gap> z:=CopyToVectorRep(v,41); 
< mutable compressed vector length 41 over GF(41) >
gap> z=v;                      
true
gap> IsIdenticalObj(z,v);   
false
gap> STOP_TEST( "comprvec.tst", 1 );

#############################################################################
##
#E
