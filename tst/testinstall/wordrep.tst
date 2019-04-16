#
gap> START_TEST("wordrep.tst");

#
gap> f := FreeGroup(IsSyllableWordsFamily,4);;
gap> fam := FamilyObj(f.1);
<Family: "FreeGroupElementsFamily">

#
gap> w8:=ObjByExtRep(fam,[1,1,2,-10,1,4]); Is8BitsAssocWord(w8);
f1*f2^-10*f1^4
true
gap> ExtRepOfObj(w8);
[ 1, 1, 2, -10, 1, 4 ]
gap> w16:=ObjByExtRep(fam,[1,2^10,2,-10,1,4]); Is16BitsAssocWord(w16);
f1^1024*f2^-10*f1^4
true
gap> ExtRepOfObj(w16);
[ 1, 1024, 2, -10, 1, 4 ]
gap> w32:=ObjByExtRep(fam,[1,2^20,2,-10,1,4]); Is32BitsAssocWord(w32);
f1^1048576*f2^-10*f1^4
true
gap> ExtRepOfObj(w32);
[ 1, 1048576, 2, -10, 1, 4 ]
gap> winf:=ObjByExtRep(fam,[1,2^40,2,-10,1,4]);; IsInfBitsAssocWord(winf);
true
gap> ExtRepOfObj(winf);
[ 1, 1099511627776, 2, -10, 1, 4 ]

#
# ExponentSums
#

#
gap> ExponentSums(w8);
[ 5, -10, 0, 0 ]
gap> ExponentSums(w8, 3, 4);
[ 0, 0 ]
gap> ExponentSums(w8, 4, 1);
[  ]
gap> ExponentSums(w8, 0, 1);
Error, NBits_ExponentSums3: <start> must be a positive small integer (not the \
integer 0)
gap> ExponentSums(w8, 1, 0);
Error, NBits_ExponentSums3: <end> must be a positive small integer (not the in\
teger 0)

#
gap> ExponentSums(w16);
[ 1028, -10, 0, 0 ]
gap> ExponentSums(w16, 3, 4);
[ 0, 0 ]
gap> ExponentSums(w16, 4, 1);
[  ]
gap> ExponentSums(w16, 0, 1);
Error, NBits_ExponentSums3: <start> must be a positive small integer (not the \
integer 0)
gap> ExponentSums(w16, 1, 0);
Error, NBits_ExponentSums3: <end> must be a positive small integer (not the in\
teger 0)

#
gap> ExponentSums(w32);
[ 1048580, -10, 0, 0 ]
gap> ExponentSums(w32, 3, 4);
[ 0, 0 ]
gap> ExponentSums(w32, 4, 1);
[  ]
gap> ExponentSums(w32, 0, 1);
Error, NBits_ExponentSums3: <start> must be a positive small integer (not the \
integer 0)
gap> ExponentSums(w32, 1, 0);
Error, NBits_ExponentSums3: <end> must be a positive small integer (not the in\
teger 0)

#
gap> ExponentSums(winf);
[ 1099511627780, -10, 0, 0 ]
gap> ExponentSums(winf, 3, 4);
[ 0, 0 ]
gap> ExponentSums(winf, 4, 1);
[  ]
gap> ExponentSums(winf, 0, 1);
Error, <from> must be a positive integer
gap> ExponentSums(winf, 1, 0);
Error, <to> must be a positive integer

#
# syllables
#

#
gap> words := [w8, w16, w32, winf];;
gap> ForAll(words, w -> GeneratorSyllable(w, 2) = 2);
true
gap> ForAll(words, w -> ExponentSyllable(w, 2) = -10);
true

#
gap> 8Bits_ExponentSyllable(w8, 4);
Error, <pos> must be an integer between 1 and 3
gap> 16Bits_ExponentSyllable(w16, 4);
Error, <pos> must be an integer between 1 and 3
gap> 32Bits_ExponentSyllable(w32, 4);
Error, <pos> must be an integer between 1 and 3

#
gap> 8Bits_GeneratorSyllable(w8, 4);
Error, <pos> must be an integer between 1 and 3
gap> 16Bits_GeneratorSyllable(w16, 4);
Error, <pos> must be an integer between 1 and 3
gap> 32Bits_GeneratorSyllable(w32, 4);
Error, <pos> must be an integer between 1 and 3

#
# test powering (esp. 8Bits_Power), with various shapes
#

# special case: w * gi^n * w^-1
gap> u8:=ObjByExtRep(fam,[1,1, 2,1, 1,-1]); u8^0; u8^1; u8^-1; u8^3; u8^-3; u8^100;
f1*f2*f1^-1
<identity ...>
f1*f2*f1^-1
f1*f2^-1*f1^-1
f1*f2^3*f1^-1
f1*f2^-3*f1^-1
f1*f2^100*f1^-1
gap> u16:=ObjByExtRep(fam,[1,1, 2,2^10, 1,-1]); u16^0; u16^1; u16^-1; u16^3; u16^-3; u16^100;
f1*f2^1024*f1^-1
<identity ...>
f1*f2^1024*f1^-1
f1*f2^-1024*f1^-1
f1*f2^3072*f1^-1
f1*f2^-3072*f1^-1
f1*f2^102400*f1^-1
gap> u32:=ObjByExtRep(fam,[1,1, 2,2^20, 1,-1]); ExtRepOfObj(u32);
f1*f2^1048576*f1^-1
[ 1, 1, 2, 1048576, 1, -1 ]
gap> ExtRepOfObj(u32^0);
[  ]
gap> ExtRepOfObj(u32^1);
[ 1, 1, 2, 1048576, 1, -1 ]
gap> ExtRepOfObj(u32^-1);
[ 1, 1, 2, -1048576, 1, -1 ]
gap> ExtRepOfObj(u32^3);
[ 1, 1, 2, 3145728, 1, -1 ]
gap> ExtRepOfObj(u32^-3);
[ 1, 1, 2, -3145728, 1, -1 ]
gap> u32^100;;
gap> uinf:=ObjByExtRep(fam,[1,1, 2,2^40, 1,-1]);; ExtRepOfObj(uinf);
[ 1, 1, 2, 1099511627776, 1, -1 ]
gap> ExtRepOfObj(uinf^0);
[  ]
gap> ExtRepOfObj(uinf^1);
[ 1, 1, 2, 1099511627776, 1, -1 ]
gap> ExtRepOfObj(uinf^-1);
[ 1, 1, 2, -1099511627776, 1, -1 ]
gap> ExtRepOfObj(uinf^3);
[ 1, 1, 2, 3298534883328, 1, -1 ]
gap> ExtRepOfObj(uinf^-3);
[ 1, 1, 2, -3298534883328, 1, -1 ]
gap> uinf^100;;

# special case: w * gj^x * t * gj^y * w^-1, x != -y
gap> v8:=ObjByExtRep(fam,[1,1, 2,1, 3,1, 4,-1, 2,2, 1,-1]); v8^0; v8^1; v8^-1; v8^3; v8^-3; v8^100;
f1*f2*f3*f4^-1*f2^2*f1^-1
<identity ...>
f1*f2*f3*f4^-1*f2^2*f1^-1
f1*f2^-2*f4*f3^-1*f2^-1*f1^-1
f1*(f2*f3*f4^-1*f2^2)^3*f1^-1
f1*(f2^-2*f4*f3^-1*f2^-1)^3*f1^-1
f1*(f2*f3*f4^-1*f2^2)^100*f1^-1
gap> v16:=ObjByExtRep(fam,[1,1, 2,1, 3,2^10, 4,-1, 2,2, 1,-1]); v16^0; v16^1; v16^-1; v16^3; v16^-3; v16^100;;
f1*f2*f3^1024*f4^-1*f2^2*f1^-1
<identity ...>
f1*f2*f3^1024*f4^-1*f2^2*f1^-1
f1*f2^-2*f4*f3^-1024*f2^-1*f1^-1
f1*(f2*f3^1024*f4^-1*f2^2)^3*f1^-1
f1*(f2^-2*f4*f3^-1024*f2^-1)^3*f1^-1
gap> v32:=ObjByExtRep(fam,[1,1, 2,1, 3,2^20, 4,-1, 2,2, 1,-1]);; ExtRepOfObj(v32);
[ 1, 1, 2, 1, 3, 1048576, 4, -1, 2, 2, 1, -1 ]
gap> ExtRepOfObj(v32^0);
[  ]
gap> ExtRepOfObj(v32^-1);
[ 1, 1, 2, -2, 4, 1, 3, -1048576, 2, -1, 1, -1 ]
gap> ExtRepOfObj(v32^3);
[ 1, 1, 2, 1, 3, 1048576, 4, -1, 2, 3, 3, 1048576, 4, -1, 2, 3, 3, 1048576, 
  4, -1, 2, 2, 1, -1 ]
gap> ExtRepOfObj(v32^-3);
[ 1, 1, 2, -2, 4, 1, 3, -1048576, 2, -3, 4, 1, 3, -1048576, 2, -3, 4, 1, 3, 
  -1048576, 2, -1, 1, -1 ]
gap> v32^100;;

# general case: w * t * w^-1
gap> x8:=ObjByExtRep(fam,[1,1, 2,1, 3,1, 4,-1]); x8^0; x8^1; x8^-1; x8^3; x8^-3; x8^100;
f1*f2*f3*f4^-1
<identity ...>
f1*f2*f3*f4^-1
f4*f3^-1*f2^-1*f1^-1
(f1*f2*f3*f4^-1)^3
(f4*f3^-1*f2^-1*f1^-1)^3
(f1*f2*f3*f4^-1)^100
gap> x16:=ObjByExtRep(fam,[1,1, 2,1, 3,2^10, 4,-1]); x16^0; x16^1; x16^-1; x16^3; x16^-3;
f1*f2*f3^1024*f4^-1
<identity ...>
f1*f2*f3^1024*f4^-1
f4*f3^-1024*f2^-1*f1^-1
(f1*f2*f3^1024*f4^-1)^3
(f4*f3^-1024*f2^-1*f1^-1)^3
gap> ExtRepOfObj(x16^100) = Concatenation(ListWithIdenticalEntries(100, ExtRepOfObj(x16)));
true
gap> x32:=ObjByExtRep(fam,[1,1, 2,1, 3,2^20, 4,-1]);;
gap> ExtRepOfObj(x32);
[ 1, 1, 2, 1, 3, 1048576, 4, -1 ]
gap> for i in [0,1,-1,3,-3] do Print(ExtRepOfObj(x32^i),"\n"); od;
[  ]
[ 1, 1, 2, 1, 3, 1048576, 4, -1 ]
[ 4, 1, 3, -1048576, 2, -1, 1, -1 ]
[ 1, 1, 2, 1, 3, 1048576, 4, -1, 1, 1, 2, 1, 3, 1048576, 4, -1, 1, 1, 2, 1, 
  3, 1048576, 4, -1 ]
[ 4, 1, 3, -1048576, 2, -1, 1, -1, 4, 1, 3, -1048576, 2, -1, 1, -1, 4, 1, 3, 
  -1048576, 2, -1, 1, -1 ]

#
# test overflow checks when powering
#

#
gap> a8:=ObjByExtRep(fam,[1,1]);; Is8BitsAssocWord(a8);
true
gap> 8Bits_Power(a8,2^10);
"TRY_NEXT_METHOD"
gap> p16:=a8^(2^10);; ExtRepOfObj(p16);
[ 1, 1024 ]
gap> Is16BitsAssocWord(p16);
true

#
gap> a16:=ObjByExtRep(fam,[1,2^10]);; Is16BitsAssocWord(a16);
true
gap> 16Bits_Power(a16,2^10);
"TRY_NEXT_METHOD"
gap> p32:=a16^(2^10);; ExtRepOfObj(p32);
[ 1, 1048576 ]
gap> Is32BitsAssocWord(p32);
true

#
gap> a32:=ObjByExtRep(fam,[1,2^26]);; Is32BitsAssocWord(a32);
true
gap> 32Bits_Power(a32,2^10);
"TRY_NEXT_METHOD"
gap> pinf:=a32^(2^10);; ExtRepOfObj(pinf);
[ 1, 68719476736 ]
gap> IsInfBitsAssocWord(pinf);
true

#
# quotients
#
gap> words8 := [u8,v8,w8,x8,a8];; ForAll(words8, Is8BitsAssocWord);
true
gap> words16 := [u16,v16,w16,x16,a16,p16];; ForAll(words16, Is16BitsAssocWord);
true
gap> words32 := [u32,v32,w32,x32,a32,p32];; ForAll(words32, Is32BitsAssocWord);
true

#
gap> SetX(words8, words8, {a,b} -> (a/b) * b = a);
[ true ]
gap> SetX(words16, words16, {a,b} -> (a/b) * b = a);
[ true ]
gap> SetX(words32, words32, {a,b} -> (a/b) * b = a);
[ true ]

#
gap> STOP_TEST("wordrep.tst", 1);
