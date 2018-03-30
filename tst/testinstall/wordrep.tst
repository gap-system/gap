gap> f := FreeGroup(IsSyllableWordsFamily,4);;
gap> fam := FamilyObj(f.1);
<Family: "FreeGroupElementsFamily">

#
gap> w8:=ObjByExtRep(fam,[1,1]); Is8BitsAssocWord(w8);
f1
true
gap> ExtRepOfObj(w8);
[ 1, 1 ]
gap> w16:=ObjByExtRep(fam,[1,2^10]); Is16BitsAssocWord(w16);
f1^1024
true
gap> ExtRepOfObj(w16);
[ 1, 1024 ]
gap> w32:=ObjByExtRep(fam,[1,2^20]); Is32BitsAssocWord(w32);
f1^1048576
true
gap> ExtRepOfObj(w32);
[ 1, 1048576 ]
gap> winf:=ObjByExtRep(fam,[1,2^40]);; IsInfBitsAssocWord(winf);
true
gap> ExtRepOfObj(winf);
[ 1, 1099511627776 ]

#
# test powering (esp. 8Bits_Power), with various shapes
#

# special case: w * gi^n * w^-1
gap> w:=ObjByExtRep(fam,[1,1, 2,1, 1,-1]); w^0; w^1; w^-1; w^3; w^100;
f1*f2*f1^-1
<identity ...>
f1*f2*f1^-1
f1*f2^-1*f1^-1
f1*f2^3*f1^-1
f1*f2^100*f1^-1
gap> w:=ObjByExtRep(fam,[1,1, 2,2^10, 1,-1]); w^0; w^1; w^-1; w^3; w^100;
f1*f2^1024*f1^-1
<identity ...>
f1*f2^1024*f1^-1
f1*f2^-1024*f1^-1
f1*f2^3072*f1^-1
f1*f2^102400*f1^-1
gap> w:=ObjByExtRep(fam,[1,1, 2,2^10, 1,-1]); w^0; w^1; w^-1; w^3; w^100;
f1*f2^1024*f1^-1
<identity ...>
f1*f2^1024*f1^-1
f1*f2^-1024*f1^-1
f1*f2^3072*f1^-1
f1*f2^102400*f1^-1
gap> w:=ObjByExtRep(fam,[1,1, 2,2^40, 1,-1]);; w^0; w^1;; w^-1;; w^3;; w^100;;
<identity ...>

# special case: w * gj^x * t * gj^y * w^-1, x != -y
gap> w:=ObjByExtRep(fam,[1,1, 2,1, 3,1, 4,-1, 2,2, 1,-1]); w^0; w^1; w^-1; w^3; w^100;
f1*f2*f3*f4^-1*f2^2*f1^-1
<identity ...>
f1*f2*f3*f4^-1*f2^2*f1^-1
f1*f2^-2*f4*f3^-1*f2^-1*f1^-1
f1*(f2*f3*f4^-1*f2^2)^3*f1^-1
f1*(f2*f3*f4^-1*f2^2)^100*f1^-1
gap> w:=ObjByExtRep(fam,[1,1, 2,1, 3,2^10, 4,-1, 2,2, 1,-1]); w^0; w^1; w^-1; w^3; w^100;
f1*f2*f3^1024*f4^-1*f2^2*f1^-1
<identity ...>
f1*f2*f3^1024*f4^-1*f2^2*f1^-1
f1*f2^-2*f4*f3^-1024*f2^-1*f1^-1
f1*(f2*f3^1024*f4^-1*f2^2)^3*f1^-1
f1*(f2*f3^1024*f4^-1*f2^2)^100*f1^-1
gap> w:=ObjByExtRep(fam,[1,1, 2,1, 3,2^20, 4,-1, 2,2, 1,-1]); w^0; w^1; w^-1; w^3;
f1*f2*f3^1048576*f4^-1*f2^2*f1^-1
<identity ...>
f1*f2*f3^1048576*f4^-1*f2^2*f1^-1
f1*f2^-2*f4*f3^-1048576*f2^-1*f1^-1
f1*(f2*f3^1048576*f4^-1*f2^2)^3*f1^-1

# general case: w * t * w^-1
gap> w:=ObjByExtRep(fam,[1,1, 2,1, 3,1, 4,-1]); w^0; w^1; w^-1; w^3; w^100;
f1*f2*f3*f4^-1
<identity ...>
f1*f2*f3*f4^-1
f4*f3^-1*f2^-1*f1^-1
(f1*f2*f3*f4^-1)^3
(f1*f2*f3*f4^-1)^100
gap> w:=ObjByExtRep(fam,[1,1, 2,1, 3,2^10, 4,-1]); w^0; w^1; w^-1; w^3; w^100;
f1*f2*f3^1024*f4^-1
<identity ...>
f1*f2*f3^1024*f4^-1
f4*f3^-1024*f2^-1*f1^-1
(f1*f2*f3^1024*f4^-1)^3
(f1*f2*f3^1024*f4^-1)^100
gap> w:=ObjByExtRep(fam,[1,1, 2,1, 3,2^20, 4,-1]); w^0; w^1; w^-1; w^3;
f1*f2*f3^1048576*f4^-1
<identity ...>
f1*f2*f3^1048576*f4^-1
f4*f3^-1048576*f2^-1*f1^-1
(f1*f2*f3^1048576*f4^-1)^3
