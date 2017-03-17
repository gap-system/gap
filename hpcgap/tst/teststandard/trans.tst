#############################################################################
##
#W  trans.tst
#Y  James D. Mitchell
##
#############################################################################
##

#
gap> START_TEST("trans.tst");
gap> display:=UserPreference("TransformationDisplayLimit");;
gap> notation:=UserPreference("NotationForTransformations");;
gap> SetUserPreference("TransformationDisplayLimit", 100);;
gap> SetUserPreference("NotationForTransformations", "input");

# MarkTrans2SubBags
gap> f:=Transformation( [ 2, 2, 4, 2, 8, 5, 10, 10, 4, 3, 9, 9 ] );;
gap> g:=One(f);
IdentityTransformation
gap> ImageSetOfTransformation(g);
[  ]
gap> FlatKernelOfTransformation(g);
[  ]
gap> KernelOfTransformation(g);
[  ]

#provoke garbage collection
gap> RandomTransformation(3000000);; 
gap> KernelOfTransformation(g);
[  ]
gap> FlatKernelOfTransformation(g);
[  ]
gap> ImageSetOfTransformation(g);
[  ]

# MarkTrans4SubBags
gap> f:=RandomTransformation(100000);;
gap> img:=StructuralCopy(ImageListOfTransformation(f));;
gap> imgset:=StructuralCopy(ImageSetOfTransformation(f));;
gap> ker:=StructuralCopy(FlatKernelOfTransformation(f));;

#provoke garbage collection
gap> RandomTransformation(3000000);;                                     
gap> ImageSetOfTransformation(f)=imgset;
true
gap> ImageListOfTransformation(f)=img;   
true
gap> FlatKernelOfTransformation(f)=ker;
true

# AsTransformation, AsPermutation
gap> p:=Random(SymmetricGroup(100));;   
gap> AsTransformation(p, 100);;
gap> p=AsPermutation(last);
true
gap> AsTransformation(p, 100000);;
gap> p=AsPermutation(last);
true
gap> p:=Random(SymmetricGroup(10));;  
gap> q:=Random(SymmetricGroup([11..70000]));;  
gap> p:=p*q*q^-1;;                      
gap> IsPerm4Rep(p);
true
gap> p=AsPermutation(AsTransformation(p, 10));
true
gap> p=AsPermutation(AsTransformation(p, 100000));
true
gap> p=AsPermutation(AsTransformation(p, 11));
true
gap> p=AsPermutation(AsTransformation(p, 12));
true
gap> p:=Random(SymmetricGroup(100));;
gap> AsTransformation(p);;
gap> p=AsPermutation(last);
true
gap> p:=Random(SymmetricGroup(1000000));;
gap> AsTransformation(p);;
gap> p=AsPermutation(last);
true
gap> f:=RandomTransformation(100);;
gap> AsPermutation(f);
fail
gap> f:=RandomTransformation(100000);;
gap> AsPermutation(f);
fail
gap> m:=IndexPeriodOfTransformation(f)[1];;
gap> PermutationOfImage(f^m)=fail;
false
gap> g:=RestrictedTransformation(f^m, ImageSetOfTransformation(f^m));;
gap> g=AsTransformation(PermutationOfImage(f^m), 100000);
true
gap> g:=IdentityTransformation;
IdentityTransformation
gap> IsIdenticalObj(g, AsTransformation(g));
true
gap> p:=Random(SymmetricGroup(10000));;
gap> g:=AsTransformation(p);;
gap> ImageSetOfTransformation(g, 10000)=[1..10000];
true
gap> FlatKernelOfTransformation(g, 10000)=[1..10000];
true
gap> AsPermutation(g)=p;
true
gap> p:=();;
gap> AsTransformation(p);
IdentityTransformation
gap> g:=AsTransformation(p, 10);
IdentityTransformation
gap> KernelOfTransformation(g);
[  ]
gap> FlatKernelOfTransformation(g);
[  ]
gap> img:=ImageSetOfTransformation(g);
[  ]
gap> img[1]:=10;
Error, Lists Assignment: <list> must be a mutable list
gap> FlatKernelOfTransformation(g);
[  ]
gap> ImageSetOfTransformation(g);
[  ]
gap> p:=(1,4,3,8,10,7,2,6)(5,9);;
gap> AsTransformation(p, 8);
Transformation( [ 4, 6, 8, 3, 9, 1, 2, 10, 9, 10 ] )
gap> p:=Random(SymmetricGroup(100000));;
gap> p:=p*p^-1*(1,2,3);
(1,2,3)
gap> g:=AsTransformation(p, 8);
Transformation( [ 2, 3, 1 ] )
gap> AsTransformation(g);
Transformation( [ 2, 3, 1 ] )
gap> g:=AsTransformation(p, 8);
Transformation( [ 2, 3, 1 ] )
gap> ImageSetOfTransformation(g);
[ 1, 2, 3 ]
gap> FlatKernelOfTransformation(g);
[ 1, 2, 3 ]
gap> g:=AsTransformation(p, 1);
Transformation( [ 2, 2 ] )
gap> g:=AsTransformation(p, 2);
Transformation( [ 2, 3, 3 ] )
gap> g:=AsTransformation(p, 8);;
gap> p=AsPermutation(g);
true
gap> g;
Transformation( [ 2, 3, 1 ] )
gap> g:=AsTransformation(g, 3);
Transformation( [ 2, 3, 1 ] )
gap> ImageSetOfTransformation(g);
[ 1, 2, 3 ]
gap> FlatKernelOfTransformation(g);
[ 1, 2, 3 ]
gap> f:=Transformation( [ 4, 12, 7, 9, 1, 2, 9, 1, 11, 3, 12, 7 ] );;
gap> AsTransformation(f, 2);
fail
gap> f:=Transformation( [ 5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6 ] );;
gap> g:=AsTransformation(f, 20);
Transformation( [ 5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6 ] )
gap> f=AsTransformation(g, 12);
true
gap> g;
Transformation( [ 5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6 ] )
gap> ImageSetOfTransformation(g);
[ 1, 2, 3, 5, 6, 9, 10, 11, 12 ]
gap> FlatKernelOfTransformation(g);
[ 1, 1, 2, 3, 3, 3, 4, 5, 6, 7, 8, 9 ]
gap> RankOfTransformation(g);
9
gap> DegreeOfTransformation(g);
12
gap> g:=AsTransformation(f, 65536);
Transformation( [ 5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6 ] )
gap> g:=AsTransformation(f, 65535);
Transformation( [ 5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6 ] )
gap> f=AsTransformation(g, 12);
true
gap> f;
Transformation( [ 5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6 ] )

# TRANS4 to TRANS4 without knowing rank, flat kernel or image set
gap> f:=RandomTransformation(70000) * (70001, 70002);;
gap> g:=AsTransformation(f, 100000);;
gap> DegreeOfTransformation(g);
70002
gap> ForAll([70003..100000], i-> i^g=i);
true
gap> ForAll([1..70002], i-> i^g=i^f);
true
gap> f=AsTransformation(g, 70002);       
true

# TRANS2 to TRANS4 without knowing rank, flat kernel or image set
gap> f:=RandomTransformation(10000);;
gap> g:=AsTransformation(f, 100000);;
gap> ForAll([10001..100000], i-> i^g=i);
true
gap> ForAll([1..10000], i-> i^g=i^f);
true
gap> AsTransformation(g, 10000)=f;
true

# TRANS2 to TRANS2 without knowing rank, flat kernel or image set
gap> f:=RandomTransformation(10000);;
gap> g:=AsTransformation(f, 20000);;
gap> ForAll([10001..20000], i-> i^g=i);
true
gap> ForAll([1..10000], i-> i^g=i^f);
true
gap> AsTransformation(g, 10000)=f;
true
gap> f:=Transformation( [ 12, 10, 11, 7, 11, 6, 12, 8, 8, 3, 11, 11 ] );;
gap> g:=AsTransformation(f, 15);   
Transformation( [ 12, 10, 11, 7, 11, 6, 12, 8, 8, 3, 11, 11 ] )
gap> AsTransformation(g, 12)=f;   
true

# TRANS4 to TRANS4 knowing rank, flat kernel and image set
gap> f:=RandomTransformation(70000);;
gap> RankOfTransformation(f);;
gap> g:=AsTransformation(f, 100000);;
gap> DegreeOfTransformation(g);
70000
gap> f=g; 
true
gap> ImageSetOfTransformation(g)=Set(ImageListOfTransformation(g));
true
gap> FlatKernelOfTransformation(g)=FlatKernelOfTransformation(f);
true
gap> RankOfTransformation(g)=Length(ImageSetOfTransformation(g));
true
gap> ImageSetOfTransformation(g)=ImageSetOfTransformation(f);
true
gap> f=AsTransformation(g, 70000);       
true

# TRANS2 to TRANS4 knowing rank, flat kernel and image set
gap> f:=RandomTransformation(10000);;
gap> RankOfTransformation(f);;
gap> g:=AsTransformation(f, 100000);;
gap> ForAll([10001..100000], i-> i^g=i);
true
gap> ForAll([1..10000], i-> i^g=i^f);
true
gap> ImageSetOfTransformation(g)=Set(ImageListOfTransformation(g));
true
gap> FlatKernelOfTransformation(g)=FlatKernelOfTransformation(f);
true
gap> RankOfTransformation(g)=Length(ImageSetOfTransformation(g));
true
gap> ImageSetOfTransformation(g)=ImageSetOfTransformation(f);
true
gap> f=AsTransformation(g, 10000);       
true

# TRANS2 to TRANS2 knowing rank, flat kernel and image set
gap> f:=RandomTransformation(10000);;
gap> RankOfTransformation(f);;
gap> g:=AsTransformation(f, 20000);;
gap> ForAll([10001..20000], i-> i^g=i);
true
gap> ForAll([1..10000], i-> i^g=i^f);
true
gap> ImageSetOfTransformation(g)=Set(ImageListOfTransformation(g));
true
gap> FlatKernelOfTransformation(g)=FlatKernelOfTransformation(f);
true
gap> RankOfTransformation(g)=Length(ImageSetOfTransformation(g));
true
gap> ImageSetOfTransformation(g)=ImageSetOfTransformation(f);
true
gap> AsTransformation(g, 10000)=f;
true

# One, IsOne, IdentityTransformation
gap> f:=Transformation( [ 11, 9, 10, 6, 7, 7, 10, 7, 10, 9, 7, 4 ] );;
gap> One(f);
IdentityTransformation
gap> IdentityTransformation;
IdentityTransformation
gap> One(f)=IdentityTransformation;
true
gap> f^0;
IdentityTransformation
gap> IsOne(f^0);
true
gap> IsOne(IdentityTransformation);
true
gap> IsOne(One(f));
true
gap> f:=RandomTransformation(70000);;
gap> One(f);
IdentityTransformation
gap> IdentityTransformation;
IdentityTransformation
gap> One(f)=IdentityTransformation;
true
gap> f^0;
IdentityTransformation
gap> IsOne(f^0);
true
gap> IsOne(IdentityTransformation);
true
gap> IsOne(One(f));
true

# KernelOfTransformation 
gap> Length(KernelOfTransformation(f))=RankOfTransformation(f);
true
gap> Union(KernelOfTransformation(f))=[1..DegreeOfTransformation(f)];
true
gap> max:=Maximum(List(KernelOfTransformation(f), Length));;
gap> tmp:=First(KernelOfTransformation(f), x->  
> Length(x)=max);;                   
gap> ForAll(tmp, x-> x^f=tmp[1]^f);
true
gap> Filtered([1..DegreeOfTransformation(f)], x-> x^f=tmp[1]^f)=tmp;
true

# PreImagesOfTransformation
gap> f:=RandomTransformation(10000);;
gap> ker:=KernelOfTransformation(f);;
gap> x:=Random(ker);;
gap> x=PreImagesOfTransformation(f, x[1]^f);
true
gap> i:=Random(ImageListOfTransformation(f));;
gap> First(ker, x-> i in x)=PreImagesOfTransformation(f, i^f);
true
gap> f:=RandomTransformation(100000);;
gap> ker:=KernelOfTransformation(f);;
gap> x:=Random(ker);;
gap> x=PreImagesOfTransformation(f, x[1]^f);
true
gap> i:=Random(ImageListOfTransformation(f));;
gap> First(ker, x-> i in x)=PreImagesOfTransformation(f, i^f);
true
gap> f:=Transformation( [ 2, 2, 4, 2, 8, 5, 10, 10, 4, 3, 9, 9 ] );;
gap> PreImagesOfTransformation(f, 12);
[  ]
gap> g:=One(f);
IdentityTransformation
gap> PreImagesOfTransformation(g, 12);
[ 12 ]

# RestrictedTransformation
gap> f:=Transformation( [ 10, 2, 10, 6, 5, 4, 8, 2, 7, 5 ] );;
gap> RestrictedTransformation(f, [3..7]);
Transformation( [ 1, 2, 10, 6, 5, 4, 8, 8, 9, 10 ] )
gap> f:=RandomTransformation(100000);;
gap> g:=RestrictedTransformation(f, [65535..70000]);;
gap> ForAll([65535..70000], i-> i^f=i^g);
true
gap> g:=RestrictedTransformation(f, [11..DegreeOfTransformation(f)]);;
gap> h:=AsTransformation(g, 10);
IdentityTransformation
gap> IsOne(last);
true
gap> IsTrans2Rep(h);
true

# IS_INJECTIVE_LIST_TRANS
gap> f:=Transformation( [ 9, 3, 2, 3, 1, 8, 2, 7, 8, 3, 12, 10 ] );;
gap> IS_INJECTIVE_LIST_TRANS([1,2,3,6,5], f);
true
gap> IS_INJECTIVE_LIST_TRANS([1..5], f);     
false
gap> f:=RandomTransformation(100000);;
gap> f:=f^IndexPeriodOfTransformation(f)[1];;
gap> IS_INJECTIVE_LIST_TRANS(ImageSetOfTransformation(f), f);
true
gap> f:=RandomTransformation(100000);;
gap> IS_INJECTIVE_LIST_TRANS([1..RankOfTransformation(f)+1], f);   
false
gap> IS_INJECTIVE_LIST_TRANS([1..RankOfTransformation(f)+1],            
> ImageListOfTransformation(f));
false
gap> f:=Transformation( [ 12, 3, 4, 12, 1, 2, 12, 1, 5, 1, 10, 7 ] );;
gap> IS_INJECTIVE_LIST_TRANS([1..3], f);                    
true
gap> IS_INJECTIVE_LIST_TRANS([1..4], f);
false
gap> IS_INJECTIVE_LIST_TRANS([1..4], ImageListOfTransformation(f));
false
gap> IS_INJECTIVE_LIST_TRANS([1..3], ImageListOfTransformation(f));
true
gap> f:=Transformation( [ 11, 9, 3, 8, 10, 11, 6, 1, 8, 8, 4, 11 ] );;
gap> RankOfTransformation(f);
8
gap> IS_INJECTIVE_LIST_TRANS([1..5], f);                           
true
gap> IS_INJECTIVE_LIST_TRANS([1..6], f);
false
gap> f:=RandomTransformation(10000);;
gap> f:=f^IndexPeriodOfTransformation(f)[1];;
gap> IS_INJECTIVE_LIST_TRANS(ImageSetOfTransformation(f), f);
true
gap> f:=Transformation( [ 5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6 ] );;
gap> IS_INJECTIVE_LIST_TRANS([2,3], f);
true
gap> IS_INJECTIVE_LIST_TRANS([2,3, 4, 7], f);
true
gap> IS_INJECTIVE_LIST_TRANS([2,3, 4,5, 7], f);
false
gap> IS_INJECTIVE_LIST_TRANS([65536], f);
true
gap> IS_INJECTIVE_LIST_TRANS([1..65536], f);
false
gap> IS_INJECTIVE_LIST_TRANS([1..65536], ImageListOfTransformation(f));
false
gap> IS_INJECTIVE_LIST_TRANS([65536], ImageListOfTransformation(f));
true

# PERM_LEFT_QUO_TRANS_NC
gap> PermLeftQuoTransformationNC(f, f);
()
gap> f:=RandomTransformation(10);;   
gap> f:=Transformation( [ 3, 8, 1, 9, 9, 4, 10, 5, 10, 6 ] );;
gap> p:=(1,9,10,8)(4,5,6);;
gap> PermLeftQuoTransformation(f*p, f);
(1,8,10,9)(4,6,5)
gap> PermLeftQuoTransformation(f, f*p);   
(1,9,10,8)(4,5,6)
gap> p:=(1,8,4,6,3,10,5);;
gap> PermLeftQuoTransformation(f, f*p);
(1,8,4,6,3,10,5)
gap> PermLeftQuoTransformation(f*p, f);                     
(1,5,10,3,6,4,8)
gap> f:=RandomTransformation(70000);;
gap> p:=Random(SymmetricGroup(ImageSetOfTransformation(f)));;
gap> PermLeftQuoTransformation(f*p, f)=p^-1;
true
gap> PermLeftQuoTransformation(f, f*p)=p;   
true
gap> f:=RandomTransformation(70000);;
gap> p:=Random(SymmetricGroup(ImageSetOfTransformation(f)));;
gap> PermLeftQuoTransformationNC(f, f*p)=p;
true
gap> PermLeftQuoTransformation(f*p, f)=p^-1;                 
true
gap> f:=Transformation( [ 2, 6, 7, 2, 6, 9, 9, 1, 11, 1, 12, 5 ] );;
gap> f*(1,2,3);
Transformation( [ 3, 6, 7, 3, 6, 9, 9, 2, 11, 2, 12, 5 ] )
gap> PermLeftQuoTransformationNC(f, last);
(1,2,3)
gap> g:=f*(1,2,5);
Transformation( [ 5, 6, 7, 5, 6, 9, 9, 2, 11, 2, 12, 1 ] )
gap> PermLeftQuoTransformationNC(f, g);
(1,2,5)
gap> PermLeftQuoTransformationNC(g, f);
(1,5,2)
gap> f:=RandomTransformation(65535);;
gap> g:=f*Random(SymmetricGroup(ImageSetOfTransformation(f)));;
gap> p:=PermLeftQuoTransformationNC(f, g);;
gap> q:=PermLeftQuoTransformationNC(g, f);;
gap> p=q^-1;
true
gap> q=p^-1;
true

# TRANS_IMG_KER_NC              
gap> f:=RandomTransformation(70000);;
gap> g:=TransformationByImageAndKernel(
> ImageSetOfTransformation(f), FlatKernelOfTransformation(f));;
gap> g=TransformationByImageAndKernel(
> ImageSetOfTransformation(g), FlatKernelOfTransformation(g));
true
gap> f:=Transformation( [ 4, 6, 9, 3, 9, 5, 11, 6, 3, 8, 7, 1 ] );;
gap> g:=TransformationByImageAndKernel(ImageSetOfTransformation(f),
> FlatKernelOfTransformation(f));
Transformation( [ 1, 3, 4, 5, 4, 6, 7, 3, 5, 8, 9, 11 ] )
gap> FlatKernelOfTransformation(g)=FlatKernelOfTransformation(f);
true
gap> ImageSetOfTransformation(g)=ImageSetOfTransformation(f);
true
gap> f:=RandomTransformation(70000);;
gap> g:=TransformationByImageAndKernel(ImageSetOfTransformation(f),
> FlatKernelOfTransformation(f));;
gap> ImageSetOfTransformation(g)=ImageSetOfTransformation(f);
true
gap> FlatKernelOfTransformation(g)=FlatKernelOfTransformation(f);
true
gap> f:=Transformation( [ 7, 1, 4, 5, 4, 2, 5, 7, 6, 4, 1, 4 ] );;
gap> g:=TRANS_IMG_KER_NC(ImageSetOfTransformation(f),
> FlatKernelOfTransformation(f));
Transformation( [ 1, 2, 4, 5, 4, 6, 5, 1, 7, 4, 2, 4 ] )
gap> KernelOfTransformation(g)=KernelOfTransformation(f);
true
gap> ImageSetOfTransformation(f)=ImageSetOfTransformation(g);
true
gap> g^2=g;
false

#IDEM_IMG_KER_NC, RIGHT_ONE_TRANS, LEFT_ONE_TRANS, IsIdempotent
gap> f:=RandomTransformation(100000);;
gap> e:=LeftOne(f);;
gap> e*f=f;
true
gap> IsIdempotent(e);
true
gap> e:=RightOne(f);;
gap> f*e=f;
true
gap> IsIdempotent(e);
true
gap> f:=RandomTransformation(100);;
gap> e:=RightOne(f);;
gap> f*e=f;                       
true
gap> IsIdempotent(e);
true
gap> f:=RandomTransformation(100);;
gap> e:=LeftOne(f);;
gap> e*f=f;
true
gap> IsIdempotent(e);
true
gap> p:=Random(SymmetricGroup(100));;
gap> f:=AsTransformation(p, 200);;
gap> Idempotent(ImageSetOfTransformation(f), FlatKernelOfTransformation(f));;
gap> last=f^0;
true
gap> f:=RandomTransformation(100);;
gap> e:=LeftOne(f);;
gap> KernelOfTransformation(e, 100)=KernelOfTransformation(f, 100);
true
gap> f:=RandomTransformation(100000);;
gap> e:=LeftOne(f);;
gap> KernelOfTransformation(e, 100000)=KernelOfTransformation(f, 100000);
true
gap> e:=RightOne(f);;
gap> ImageSetOfTransformation(e, 100000)=ImageSetOfTransformation(f, 100000);
true

# INV_TRANS
gap> ForAll(FullTransformationSemigroup(3), x->
> x*InverseOfTransformation(x)*x=x and
> InverseOfTransformation(x)*x
> *InverseOfTransformation(x)=InverseOfTransformation(x));
true
gap> ForAll(FullTransformationSemigroup(4), x->
> x*InverseOfTransformation(x)*x=x);
true
gap> f:=Transformation( [ 7, 1, 4, 5, 4, 2, 5, 7, 6, 4, 1, 4 ] );;
gap> g:=InverseOfTransformation(f);
Transformation( [ 2, 6, 1, 3, 4, 9, 1, 1, 1, 1, 1, 1 ] )
gap> f*g*f=f;
true
gap> g*f*g=g;
true
gap> f:=RandomTransformation(100000);;
gap> g:=InverseOfTransformation(f);;
gap> g*f*g=g and f*g*f=f;
true

# INV_LIST_TRANS, IsInjectiveListTrans
gap> f:=Transformation( [ 12, 7, 6, 3, 11, 10, 7, 11, 5, 7, 3, 12 ] );;
gap> list:=[1..6];
[ 1 .. 6 ]
gap> IsInjectiveListTrans(list, f);
true
gap> g:=INV_LIST_TRANS(list, f);
Transformation( [ 1, 2, 4, 4, 5, 3, 2, 8, 9, 6, 5, 1 ] )
gap> ForAll(list, i-> ((i)^f)^g=i);
true
gap> f:=RandomTransformation(100000);;
gap> e:=LeftOne(f);;
gap> IsInjectiveListTrans(ImageSetOfTransformation(e), f);
true
gap> g:=INV_LIST_TRANS(ImageSetOfTransformation(e), f);;
gap> ForAll(ImageSetOfTransformation(e), i-> ((i)^f)^g=i);
true
gap> f:=RandomTransformation(100000);;
gap> e:=LeftOne(f);;                   
gap> IsInjectiveListTrans(ImageSetOfTransformation(e), f);
true
gap> g:=INV_LIST_TRANS(ImageSetOfTransformation(e), f);;
gap> ForAll(ImageSetOfTransformation(e), i-> ((i)^f)^g=i);
true
gap> g:=LeftOne(f);;                   
gap> ForAll(ImageSetOfTransformation(e), i-> ((i)^f)^g=i);
false

# IndexPeriodOfTransformation, SmallestIdempotentPower
gap> f:=Transformation( [ 4, 3, 8, 9, 3, 5, 8, 10, 5, 6, 2, 8 ] );;
gap> x:=IndexPeriodOfTransformation(f);
[ 3, 5 ]
gap> f^(x[1]+x[2])=f^x[1];
true
gap> f:=RandomTransformation(100000);;
gap> x:=IndexPeriodOfTransformation(f);;
gap> f^(x[1]+x[2])=f^x[1];
true
gap> f:=RandomTransformation(12000);;
gap> x:=IndexPeriodOfTransformation(f);;
gap> f^(x[1]+x[2])=f^x[1];
true
gap> (f^SmallestIdempotentPower(f))^2=f^SmallestIdempotentPower(f);
true
gap> f:=Transformation( 
> [ 5, 23, 27, 8, 21, 49, 36, 33, 4, 44, 3, 49, 48, 18, 10, 30, 
>  47, 3, 41, 35, 33, 15, 39, 19, 37, 24, 26, 2, 16, 47, 9, 7, 28, 47, 25, 21, 
>  50, 23, 18, 42, 26, 40, 40, 4, 43, 27, 45, 35, 40, 14 ] );;
gap> IndexPeriodOfTransformation(f);
[ 14, 4 ]
gap> f^18=f^14;
true
gap> SmallestIdempotentPower(f);
16
gap> f^32=f^16;
true
gap> ForAny([1..15], x-> f^(2*x)=f^x);
false
gap> f:=RandomTransformation(100000);;
gap> m:=SmallestIdempotentPower(f);;
gap> IsIdempotent(f^m);
true
gap> f:=RandomTransformation(1000);;
gap> m:=SmallestIdempotentPower(f);;
gap> ForAny([1..m-1], i-> IsIdempotent(f^i));
false
gap> IsIdempotent(f^m);
true
gap> f:=
> Transformation( [ 74, 33, 77, 60, 65, 37, 24, 22, 16, 49, 58, 16, 62, 7, 69,
>  38, 97, 44, 56, 5, 3, 74, 89, 28, 95, 94, 56, 6, 38, 58, 45, 63, 32, 32,
>  38, 27, 36, 28, 81, 41, 85, 95, 55, 19, 58, 16, 65, 55, 61, 87, 40, 37, 89,
>  47, 48, 42, 82, 37, 34, 25, 26, 19, 44, 13, 15, 27, 41, 99, 15, 69, 8, 19,
>  85, 8, 96, 8, 69, 97, 31, 22, 71, 39, 91, 13, 76, 53, 37, 78, 27, 91, 46,
>  32, 64, 70, 84, 92, 37, 68, 10, 68 ] );;
gap> IndexPeriodOfTransformation(f);
[ 10, 42 ]
gap> f:=
> Transformation( [ 45, 51, 70, 26, 87, 94, 23, 19, 86, 46, 45, 51, 57, 13, 67,
>  5, 38, 20, 51, 25, 67, 91, 38, 29, 43, 44, 84, 71, 11, 39, 52, 40, 12, 58,
>  1, 83, 9, 27, 1, 25, 86, 83, 15, 38, 86, 61, 43, 16, 55, 16, 96, 46, 46,
>  70, 29, 11, 13, 8, 14, 67, 84, 17, 79, 44, 59, 19, 35, 19, 61, 49, 32, 24,
>  45, 71, 2, 90, 12, 4, 43, 61, 63, 64, 34, 92, 77, 19, 8, 23, 85, 26, 87, 8,
>  76, 18, 48, 33, 8, 7, 38, 39 ] );;
gap> IndexPeriodOfTransformation(f);
[ 13, 4 ]
gap> f:=
> Transformation( [ 14, 24, 70, 1, 50, 72, 13, 64, 65, 68, 54, 20, 69, 32, 88,
>  60, 93, 100, 37, 27, 15, 7, 84, 95, 84, 36, 8, 20, 90, 55, 78, 48, 93, 10,
>  51, 76, 26, 83, 29, 39, 93, 48, 51, 93, 50, 92, 95, 51, 31, 17, 76, 43, 5,
>  19, 94, 11, 70, 84, 22, 95, 5, 44, 44, 6, 7, 56, 4, 57, 94, 100, 86, 30,
>  38, 80, 77, 60, 45, 99, 38, 11, 60, 62, 76, 50, 13, 48, 27, 82, 68, 99, 17,
>  81, 16, 3, 14, 90, 22, 71, 41, 98 ] );;
gap> IndexPeriodOfTransformation(f);
[ 16, 7 ]

# OnKernelAntiAction
gap> f:=Transformation( 
> [ 84, 99, 9, 73, 33, 70, 77, 69, 41, 18, 63, 29, 42, 33, 75, 
>  56, 79, 63, 89, 90, 64, 98, 49, 35, 89, 71, 3, 70, 20, 2, 26, 11, 39, 9, 7, 
>  89, 90, 48, 89, 85, 8, 56, 42, 10, 61, 25, 98, 55, 39, 92, 62, 21, 34, 57, 
>  44, 14, 14, 92, 53, 64, 59, 84, 12, 87, 78, 10, 83, 30, 32, 53, 44, 68, 73, 
>  2, 86, 23, 48, 47, 14, 79, 93, 15, 23, 76, 34, 97, 77, 55, 11, 33, 47, 91, 
>  87, 87, 67, 93, 18, 59, 86 ] );;
gap> g:=
> Transformation( [ 16, 99, 73, 60, 74, 17, 95, 85, 49, 79, 4, 33, 66, 15, 44, 
>   77, 73, 41, 55, 93, 84, 67, 68, 69, 94, 31, 2, 29, 5, 42, 10, 63, 58, 34, 
>   72, 4, 53, 93, 89, 67, 34, 15, 57, 29, 4, 62, 76, 20, 34, 52, 22, 35, 75, 
>   29, 98, 22, 29, 78, 40, 46, 28, 6, 15, 55, 6, 90, 16, 12, 12, 65, 55, 26, 
>   66, 89, 36, 36, 25, 61, 57, 83, 38, 41, 93, 2, 39, 87, 85, 26, 17, 83, 92, 
>   97, 43, 30, 15, 5, 13, 94, 44 ] );;
gap> OnKernelAntiAction(FlatKernelOfTransformation(g), f);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 11, 5, 13, 14, 15, 11, 16, 17, 18, 
  19, 9, 20, 16, 18, 21, 6, 22, 23, 24, 25, 26, 3, 27, 16, 17, 28, 16, 29, 
  30, 14, 11, 31, 32, 19, 19, 33, 26, 34, 35, 36, 9, 37, 37, 11, 11, 34, 38, 
  18, 39, 1, 40, 30, 41, 31, 22, 42, 43, 38, 37, 8, 4, 23, 44, 45, 28, 46, 
  11, 15, 47, 2, 45, 13, 9, 48, 7, 33, 25, 5, 46, 49, 30, 30, 50, 47, 10, 39, 
  44 ]
gap> last=FlatKernelOfTransformation(f*g);
true
gap> f:=RandomTransformation(100000);;
gap> g:=RandomTransformation(100000);;
gap> OnKernelAntiAction(FlatKernelOfTransformation(g), f);;
gap> last=FlatKernelOfTransformation(f*g);
true
gap> f:=RandomTransformation(100000);;
gap> g:=RandomTransformation(100000);;
gap> OnKernelAntiAction(FlatKernelOfTransformation(g), f);;
gap> last=FlatKernelOfTransformation(f*g);
true
gap> OnKernelAntiAction(FlatKernelOfTransformation(g), f*g^3*f*g*f^10);;
gap> last=FlatKernelOfTransformation(f*g^3*f*g*f^10*g);
true

# INV_KER_TRANS
gap> f:=Transformation( [ 9, 5, 3, 5, 10, 3, 1, 9, 6, 7 ] );;
gap> g:=RightOne(f);                                   
Transformation( [ 1, 1, 3, 3, 5, 6, 7, 7 ] )
gap> g:=g*Random(SymmetricGroup(7));;
gap> ker:=FlatKernelOfTransformation(g, DegreeOfTransformation(f));
[ 1, 1, 2, 2, 3, 4, 5, 5, 6, 7 ]
gap> h:=INV_KER_TRANS(ker, f);
Transformation( [ 7, 7, 6, 6, 4, 9, 10, 10, 8, 5 ] )
gap> OnKernelAntiAction(OnKernelAntiAction(ker, f), h)=ker;
true
gap> h*f*g=g;
true
gap> f:=RandomTransformation(1000);;
gap> g:=RightOne(f);;
gap> g:=g*Random(SymmetricGroup(Maximum(ImageSetOfTransformation(g))));;
gap> ker:=FlatKernelOfTransformation(g, DegreeOfTransformation(f));;
gap> h:=INV_KER_TRANS(ker, f);;
gap> OnKernelAntiAction(OnKernelAntiAction(ker, f), h)=ker;
true
gap> h*f*g=g;
true
gap> f:=RandomTransformation(100000);; 
gap> g:=RightOne(f);;                                   
gap> g:=g*Random(SymmetricGroup(Maximum(ImageSetOfTransformation(g))));;
gap> ker:=FlatKernelOfTransformation(g, DegreeOfTransformation(f));;
gap> h:=INV_KER_TRANS(ker, f);;
gap> OnKernelAntiAction(OnKernelAntiAction(ker, f), h)=ker;
true
gap> h*f*g=g;
true

# ComponentsOfTransformation, NrComponentsOfTransformation, and 
# ComponentRepsOfTransformation
gap> f:=RandomTransformation(100000);;
gap> NrComponentsOfTransformation(f)=Length(ComponentsOfTransformation(f));
true
gap> Union(ComponentsOfTransformation(f))=[1..100000];
true
gap> f:=RandomTransformation(100);;
gap> NrComponentsOfTransformation(f)=Length(ComponentsOfTransformation(f));
true
gap> Set(List(ComponentRepsOfTransformation(f), x-> 
> Union(List(x, i-> ComponentTransformationInt(f, i)))))
> = Set(List(ComponentsOfTransformation(f), AsSSortedList));
true
gap> Union(ComponentsOfTransformation(f))=[1..100];   
true
gap> p:=Random(SymmetricGroup(100000));;
gap> f:=AsTransformation(p);;
gap> NrComponentsOfTransformation(f)=Length(ComponentsOfTransformation(f));
true
gap> Union(ComponentsOfTransformation(f))=[1..100000];
true
gap> Sum(Compacted(CycleStructurePerm(AsPermutation(f))))+
> LargestMovedPoint(p)-NrMovedPoints(p)=
> NrComponentsOfTransformation(f);
true

# equality for transformations
gap> f:=Transformation( [ 2, 6, 7, 2, 6, 13, 9, 9, 13, 1, 11, 1, 13, 12 ] );;
gap> g:=Transformation( [ 5, 3, 8, 12, 1, 11, 9, 9, 4, 14, 10, 5, 10, 6 ] );;
gap> f=f;
true
gap> f=g;
false
gap> g=f;
false
gap> f:=RandomTransformation(100000);;
gap> g:=RandomTransformation(100000);;
gap> f=f;
true
gap> f=g;
false
gap> g=f;
false
gap> f=RandomTransformation(15);
false
gap> RandomTransformation(15)=g;
false

# \< for transformations
gap> f:=Transformation( [ 8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9 ] );;
gap> g:=Transformation( [ 3, 7, 3, 4, 10, 9, 4, 7, 1, 5, 3, 1 ] );;
gap> f<g;
false
gap> g<f;
true
gap> g:=RandomTransformation(100000);;
gap> f<g;
true
gap> g<f;
false
gap> f:=RandomTransformation(100000);;
gap> g<f or f<g;
true
gap> f:=Transformation( [ 4, 4, 4, 1 ] );;
gap> ForAll(FullTransformationSemigroup(4), x-> x<f or x>f or x=f);
true

# \* for transformations
gap> f:=Transformation( [ 3, 2, 4, 4 ] );;
gap> g:=Transformation( [ 2, 1, 2, 1 ] );;
gap> f*g;
Transformation( [ 2, 1, 1, 1 ] )
gap> g*f;
Transformation( [ 2, 3, 2, 3 ] )
gap> f*g*f*g*f*g; 
Transformation( [ 2, 1, 1, 1 ] )
gap> f:=RandomTransformation(10000);;
gap> g:=RandomTransformation(10000);;
gap> h:=f*g;;
gap> ForAll([1..10000], i-> (i^f)^g=i^h);
true
gap> f:=RandomTransformation(100000);;
gap> g:=RandomTransformation(10000);;
gap> f*g;;
gap> g:=RandomTransformation(100001);;
gap> f*g;;
gap> g:=RandomTransformation(100000);;
gap> f*g;;
gap> h:=f*g;;
gap> ForAll([1..100000], i-> (i^f)^g=i^h);  
true
gap> 

# \* for IsTrans2Rep and IsPerm2Rep
gap> f:=Transformation( [ 8, 1, 9, 7, 7, 6, 4, 2, 2, 4 ] );;
gap> p:=(1,2)(7,9,6,5,1100);;
gap> f*p;
<transformation on 1100 pts with rank 1097>
gap> ForAll([1..10], i-> (i^f)^p=i^(f*p));  
true
gap> f*(1,7,9,4,6);
Transformation( [ 8, 7, 4, 9, 9, 1, 6, 2, 2, 6 ] )
gap> f*(1,10,7,9,4,6);
Transformation( [ 8, 10, 4, 9, 9, 1, 6, 2, 2, 6 ] )
gap> f*(1,11,7,9,4,6);
Transformation( [ 8, 11, 4, 9, 9, 1, 6, 2, 2, 6, 7 ] )
gap> f*(1,12,7,8);
Transformation( [ 1, 12, 9, 8, 8, 6, 4, 2, 2, 4, 11, 7 ] )
gap> f*(1,9,8,5)(2,7,4,3,6,10);
Transformation( [ 5, 9, 8, 4, 4, 10, 3, 7, 7, 3 ] )
gap> f:=Transformation( [ 5, 5, 2, 10, 10, 10, 1, 12, 11, 9, 3, 6 ] );;
gap> f*(1,2,3);
Transformation( [ 5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6 ] )
gap> p:=(1,4,12,8)(2,16,15,5,7,9,20,14,11,17,10)(3,13,6,19);;
gap> f*p;
Transformation( [ 7, 7, 16, 2, 2, 2, 4, 8, 17, 20, 13, 19, 6, 11, 5, 15, 10,
  18, 3, 14 ] )
gap> p:=(2,7,5,10,3,4,12,11,6)(8,9);;
gap> f*p;
Transformation( [ 10, 10, 7, 3, 3, 3, 1, 11, 6, 8, 4, 2 ] )
gap> p:=(1,2,3);;
gap> g:=f*p;
Transformation( [ 5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6 ] )
gap> DegreeOfTransformation(g);
12
gap> RankOfTransformation(g); RankOfTransformation(f);
9
9
gap> f:=Transformation( [ 8, 1, 9, 7, 7, 6, 4, 2, 2, 4 ] );;
gap> f*(1,10,2,3,6,7)(11,15)(12,17,19,16,20,18);
Transformation( [ 8, 10, 9, 1, 1, 7, 4, 3, 3, 4, 15, 17, 13, 14, 11, 20, 19,
  12, 16, 18 ] )

# \* for IsTrans2Rep and IsPerm4Rep
gap> f:=Transformation( [ 8, 1, 9, 7, 7, 6, 4, 2, 2, 4 ] );;
gap> f*(1,2)(7,9,6,5,1100)*(1,100000)*(1,100000);
<transformation on 1100 pts with rank 1097>
gap> f*((1,2)(7,9,6,5,1100)*(1,100000)*(1,100000));
<transformation on 1100 pts with rank 1097>
gap> last=f*(1,2)(7,9,6,5,1100);
true
gap> f*((1,7,9,4,6)*(1,100000)*(1,100000));
Transformation( [ 8, 7, 4, 9, 9, 1, 6, 2, 2, 6 ] )
gap> f*((1,2)(7,9,6,5,1100)*(1,100000)*(1,100000)); 
<transformation on 1100 pts with rank 1097>
gap> f*((1,10,7,9,4,6)*(1,100000)*(1,100000));
Transformation( [ 8, 10, 4, 9, 9, 1, 6, 2, 2, 6 ] )
gap> f*(1,100000);     
<transformation on 100000 pts with rank 99997>
gap> f*(5,100000);
<transformation on 100000 pts with rank 99997>
gap> f*((1,10,2,3,6,7)(11,15)(12,17,19,16,20,18)*(13,100000));
<transformation on 100000 pts with rank 99997>

# \* for IsTrans4Rep and IsPerm2Rep
gap> f:=RandomTransformation(100000);;                      
gap> f*(1,2,3);;
gap> RankOfTransformation(f)=RankOfTransformation(f*(1,2,3));
true
gap> KernelOfTransformation(f)=KernelOfTransformation(f*(1,2,3));
true
gap> f:=RandomTransformation(100000);;                      
gap> RankOfTransformation(f)=RankOfTransformation(f*(1,2,3));
true
gap> KernelOfTransformation(f)=KernelOfTransformation(f*(1,2,3));
true
gap> p:=Random(SymmetricGroup(65536));;
gap> IsPerm2Rep(p);
true
gap> f*p;;

# \* for IsTrans4Rep and IsPerm4Rep
gap> f:=RandomTransformation(100000);;  
gap> p:=Random(SymmetricGroup(Difference([1..100000],
> ImageSetOfTransformation(f))));;
gap> f*p;;
gap> KernelOfTransformation(f)=KernelOfTransformation(f*p);
true
gap> h:=f*p;;
gap> ForAll([1..100000], i-> (i^f)^p=i^(h));  
true
gap> f:=RandomTransformation(100000);;
gap> p:=Random(SymmetricGroup(200000));;
gap> f*p;;
gap> p:=Random(SymmetricGroup(100000))*       
> Random(SymmetricGroup([100001..200001]));;
gap> f:=RandomTransformation(100000);;
gap> f*p;;
gap> KernelOfTransformation(f, 100000)=KernelOfTransformation(f*p, 100000);
true

# \* for IsPerm2Rep and IsTrans2Rep
gap> f:=Transformation( [ 6, 7, 9, 7, 4, 7, 5, 4, 9, 4 ] );;
gap> p:=(1,4,9,10,3,2,8)(5,7);;
gap> p*f;
Transformation( [ 7, 4, 7, 9, 5, 7, 4, 6, 4, 9 ] )
gap> ImageSetOfTransformation(f)=ImageSetOfTransformation(p*f);
true
gap> ForAll([1..10], i-> (i^p)^f=i^(p*f));  
true
gap> p:=(2,10,5,9,8,4,7,6,3)(11,12);;
gap> p*f;
Transformation( [ 6, 4, 7, 5, 9, 9, 7, 7, 4, 4, 12, 11 ] )
gap> (p*(11,12))*f;
Transformation( [ 6, 4, 7, 5, 9, 9, 7, 7, 4, 4 ] )
gap> last=last2;
false

# \* for IsPerm4Rep and IsTrans2Rep
gap> p:=(1,10,2,8,9,5,6)(3,4)*(1,100000)*(1,100000);;
gap> IsPerm4Rep(p);
true
gap> p*f;
Transformation( [ 4, 4, 7, 9, 7, 6, 5, 9, 4, 7 ] )
gap> ImageSetOfTransformation(f, 10)=ImageSetOfTransformation(p*f, 10);
true
gap> (1,10,2,8,9,5,6)(3,4)*f;
Transformation( [ 4, 4, 7, 9, 7, 6, 5, 9, 4, 7 ] )
gap> p:=Random(SymmetricGroup(100000));;                 
gap> p*f;
<transformation on 100000 pts with rank 99995>

# \* for IsPerm2Rep and IsTrans4Rep
gap> p:=(1,2,3);;
gap> f:=RandomTransformation(100000);;
gap> p*f;;
gap> p:=Random(SymmetricGroup(65536));; 
gap> p*f;;
gap> ()*f=f; 
true
gap> p^-1*(p*f)=f;
true
gap> ImageSetOfTransformation(f)=ImageSetOfTransformation(p*f);
true

# \* for IsPerm4Rep and IsTrans4Rep
gap> p:=Random(SymmetricGroup(99999));;
gap> f:=RandomTransformation(100000);;
gap> p*f;;
gap> p^-1*(p*f)=f;
true
gap> ImageSetOfTransformation(f)=ImageSetOfTransformation(p*f);
true
gap> p:=p*(100001,100002);;
gap> p*f;;
gap> p:=Random(SymmetricGroup(200000));;
gap> p*f;;

# conjugation of IsTrans2Rep by IsPerm2Rep
gap> f:=Transformation( [ 10, 4, 9, 4, 3, 4, 2, 1, 6, 9 ] );;
gap> p:=(1,4,6)(2,8)(3,7,5);;
gap> f^p;
Transformation( [ 6, 4, 7, 10, 8, 6, 9, 6, 1, 9 ] )
gap> f^p=p^-1*f*p;
true
gap> p:=(1,4,3,5)(2,10,8)(7,9)(11,15,12,20,13)(16,19,18,17);;
gap> f^p;
Transformation( [ 5, 4, 3, 8, 7, 3, 6, 7, 10, 3 ] )
gap> f^p=p^-1*f*p;
true
gap> p:=(1,3,6,11,7,10,5,2)(4,8,9);;
gap> f^p;
Transformation( [ 8, 6, 5, 11, 4, 4, 7, 8, 3, 1, 8 ] )

# conjugation of IsTrans2Rep by IsPerm4Rep
gap> f:=Transformation( [ 10, 4, 9, 4, 3, 4, 2, 1, 6, 9 ] );;
gap> p:=(1,4,6)(2,8)(3,7,5)*(1,65537)*(1,65537);;
gap> f^p;
Transformation( [ 6, 4, 7, 10, 8, 6, 9, 6, 1, 9 ] )
gap> f^p=p^-1*f*p;
true
gap> p:=(1,4,3,5)(2,10,8)(7,9)(11,15,12,20,13)(16,19,18,17)*(65536,65537);;
gap> f^p;
Transformation( [ 5, 4, 3, 8, 7, 3, 6, 7, 10, 3 ] )
gap> f^p=p^-1*f*p;
true
gap> p:=Random(SymmetricGroup(65537));;
gap> f ^ p = p^-1 * f * p;
true

# conjugation of IsTrans4Rep by IsPerm2Rep
gap> f:=RandomTransformation(65536);;
gap> p:=(1,4,6)(2,8)(3,7,5);;
gap> f^p=p^-1*f*p;
true

# conjugation of IsTrans4Rep by IsPerm4Rep
gap> f:=RandomTransformation(65537);;
gap> p:=Random(SymmetricGroup(65537));;
gap> f^p=p^-1*f*p;
true
gap> p:=Random(SymmetricGroup(65537))*(65538, 65539);;
gap> f^p=p^-1*f*p;
true
gap> p:=Random(SymmetricGroup(65538));;
gap> f^p;;
gap> f^p=p^-1*f*p;
true

# / for IsTrans2Rep and IsPerm2Rep
gap> f:=Transformation( [ 8, 2, 6, 6, 7, 10, 8, 2, 1, 10 ] );;
gap> p:=(1,10,9,4,6,3,8)(5,7);;
gap> f/p;
Transformation( [ 3, 2, 4, 4, 5, 1, 3, 2, 8, 1 ] )
gap> f/p=f*p^-1;
true
gap> f/();
Transformation( [ 8, 2, 6, 6, 7, 10, 8, 2, 1, 10 ] )
gap> f/()=f;
true
gap> p:=p*(11,12);;                            
gap> f/p;
Transformation( [ 3, 2, 4, 4, 5, 1, 3, 2, 8, 1, 12, 11 ] )
gap> p:=(1,2,3);
(1,2,3)
gap> f/p;
Transformation( [ 8, 1, 6, 6, 7, 10, 8, 1, 3, 10 ] )
gap> f/p=f*p^-1;
true

# / for IsTrans2Rep and IsPerm4Rep
gap> f:=Transformation( [ 8, 2, 6, 6, 7, 10, 8, 2, 1, 10 ] );;
gap> p:=(1,100000)^2;;
gap> f/p;
Transformation( [ 8, 2, 6, 6, 7, 10, 8, 2, 1, 10 ] )
gap> f/p=f*p^-1;
true
gap> p:=(1,10,3,6,4)(2,7,5,8,9)*(1,100000)^2;;
gap> f/p;
Transformation( [ 5, 9, 3, 3, 2, 1, 5, 9, 4, 1 ] )
gap> f/p=f*p^-1;
true
gap> p:=(1,2,3)*(1,100000)^2;;                
gap> f/p;
Transformation( [ 8, 1, 6, 6, 7, 10, 8, 1, 3, 10 ] )
gap> p:=(1,2,3)*(11,12)*(1,100000)^2;;
gap> f/p;
Transformation( [ 8, 1, 6, 6, 7, 10, 8, 1, 3, 10, 12, 11 ] )

# / for IsTrans4Rep and IsPerm2Rep
gap> f:=RandomTransformation(100000);;
gap> p:=Random(SymmetricGroup(65530));;
gap> f/p=f*p^-1;
true
gap> f/()=f;
true

# / for IsTrans4Rep and IsPerm4Rep
gap> f:=RandomTransformation(100000);;
gap> p:=Random(SymmetricGroup(100000));;
gap> f/p=f*p^-1;
true
gap> f/(p*p^-1)=f;
true
gap> p:=p*(100001,100002);;                 
gap> f/p=f*p^-1;
true
gap> p:=Random(SymmetricGroup(70000));;
gap> f/p=f*p^-1;
true

# LQUO for IsPerm2Rep and IsTrans2Rep
gap> f:=Transformation( [ 1, 6, 9, 5, 1, 4, 6, 1, 1, 2 ] );;
gap> p:=(1,2,3);;
gap> LQUO(p, f);
Transformation( [ 9, 1, 6, 5, 1, 4, 6, 1, 1, 2 ] )
gap> LQUO(p, f)=p^-1*f;
true
gap> p:=(1,2,3)*(10,11);
(1,2,3)(10,11)
gap> LQUO(p, f)=p^-1*f; 
true
gap> p:=(1,2,3)*(11,12);
(1,2,3)(11,12)
gap> LQUO(p, f)=p^-1*f;
true
gap> p:=(1,6,7,5,2,9,4,10,3,8);;
gap> LQUO(p, f)=p^-1*f;
true

# LQUO for IsPerm2Rep and IsTrans4Rep
gap> f:=RandomTransformation(100000);;
gap> p:=Random(SymmetricGroup(10000));;
gap> LQUO(p, f)=p^-1*f;
true

# LQUO for IsPerm4Rep and IsTrans2Rep 
gap> f:=Transformation( [ 7, 3, 10, 3, 6, 10, 5, 2, 8, 7 ] );;
gap> p:=(1,9,7,8,6,10,2,5,4,3);;
gap> p:=p*(1,100000)^2;
(1,9,7,8,6,10,2,5,4,3)
gap> IsPerm4Rep(p);             
true
gap> LQUO(p, f)=p^-1*f;
true
gap> p:=Random(SymmetricGroup(100000));;
gap> LQUO(p, f);       
<transformation on 100000 pts with rank 99997>

# LQUO for IsPerm4Rep and IsTrans4Rep
gap> f:=RandomTransformation(100000);;
gap> p:=Random(SymmetricGroup(99999));;
gap> LQUO(p, f)=p^-1*f;
true
gap> p:=Random(SymmetricGroup(100000))*(100001,100002);;
gap> LQUO(p, f)=p^-1*f; 
true
gap> p:=Random(SymmetricGroup(100000));;
gap> LQUO(p, f)=p^-1*f;
true
gap> p:=Random(SymmetricGroup(200000));;
gap> LQUO(p, f)=p^-1*f;
true

# OnSets and OnTuples
gap> f:=Transformation( [ 2, 6, 7, 2, 6, 9, 9, 1, 1, 5 ] );;
gap> OnSets([1..11], f);
[ 1, 2, 5, 6, 7, 9, 11 ]
gap> OnSets([1..10], f);
[ 1, 2, 5, 6, 7, 9 ]
gap> OnTuples([1..10], f);
[ 2, 6, 7, 2, 6, 9, 9, 1, 1, 5 ]
gap> f:=RandomTransformation(100000);;
gap> OnTuples([1..100000], f)=ImageListOfTransformation(f);
true
gap> OnSets([1..100000], f)=ImageSetOfTransformation(f);
true

#
gap> ConstantTransformation(4,1)<IdentityTransformation;
true

# Test for the issue with caching the degree of a transformation in PR #384
gap> x := Transformation([1,1]) ^ (1,2)(3,70000);
Transformation( [ 2, 2 ] )
gap> IsTrans4Rep(x);
true
gap> HASH_FUNC_FOR_TRANS(x, 101);;
gap> x;
Transformation( [ 2, 2 ] )

#
gap> SetUserPreference("TransformationDisplayLimit", display);;
gap> SetUserPreference("NotationForTransformations", notation);;

#
gap> STOP_TEST( "trans.tst", 68040000);
