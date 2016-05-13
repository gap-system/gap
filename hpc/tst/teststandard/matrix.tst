#############################################################################
##
#W  matrix.tst                  GAP Tests                     Robert F. Morse
##  
##
##
#Y  (C) 1998 School Math. and Comp. Sci., University of St Andrews, Scotland
##  
##  Exclude from testinstall.g: why?
##
gap> START_TEST("matrix.tst");
gap> ##
gap> ##
gap> ########################################################################
gap> ##
gap> ## Categories of Matrices
gap> ##
gap> ##
gap> r := Rationals;;
gap> m := RandomMat(10,10,r);;
gap> IsMatrix(m);
true
gap> IsTable(m);
true
gap> IsRectangularTable(m);
true
gap> m := [RandomMat(10,10,r)];;
gap> IsMatrix(m);
false
gap> IsTable(m);
true
gap> m := RandomMat(10,10,r);;
gap> IsOrdinaryMatrix(m);
true
gap> IsLieMatrix(m);
false
gap> #T
gap> #T Make malformed matrices of both types
gap> #T
gap> m := [[1,2,3],[1,2],[1]];;
gap> IsMatrix(m);
true
gap> IsOrdinaryMatrix(m);
true
gap> IsTable(m);
true
gap> IsRectangularTable(m);
false
gap> m := LieObject(m);;
gap> IsMatrix(m);
true
gap> IsLieMatrix(m);
true
gap> IsTable(m);
true
gap> IsRectangularTable(m);
false
gap> ##
gap> m := LieObject(RandomMat(50,50,[-100..100]));;
gap> IsLieMatrix(m);
true
gap> IsOrdinaryMatrix(m);
false
gap> m*m=Zero(m);
true
gap> m1 := LieObject(IdentityMat(50));;
gap> m*m1=m;
false
gap> #T
gap> #T From the manual: A matrix is a list of lists of equal length 
gap> #T whose entries lie in a common ring
gap> #T 
gap> #T But not rings represented as matrices.
gap> #T
gap> m := RandomInvertibleMat(5,GF(3));;
gap> r := Ring(m);;
gap> IsFinite(r);
true
gap> e:=Random(r);;
gap> m1 := [[e,e],[e,e]];;
gap> IsMatrix(m1);
false
gap> IsRingElement(e);
true
gap> nm := NullMat(2,2,r);;
gap> IsMatrix(nm);
false
gap> d := DiagonalMat([e,e]);;
gap> IsMatrix(d);
false
gap> ##
gap> ########################################################################
gap> ##
gap> ## Operators for Matrices
gap> ##
gap> ##
gap> m := RandomInvertibleMat(10,Rationals);;
gap> m1 := RandomInvertibleMat(10,Rationals);;
gap> v := Flat(RandomMat(1,10,Rationals));;
gap> e := 3/23;;
gap> ## 
gap> ## scalar ops
gap> ##
gap> e*m/e=m;
true
gap> (m/e)*e=m;
true
gap> (e/m)=m^-1*e;
true
gap> e+m-e = m;
true
gap> ## list ops
gap> mlst := [m,m1,m,m1];;
gap> e+mlst-e = mlst;
true
gap> e*mlst/e=mlst;
true
gap> #T
gap> #T not sure why this is a syntax error
gap> #T (m^-1*mlst*m){[1,3]} = mlst{[1,3]}; 
gap> #T
gap> m1lst := m^-1*mlst*m;;
gap> m1lst{[1,3]}=mlst{[1,3]};
true
gap> ##  
gap> r := Integers;;
gap> n := Random([5..10]);;
gap> rm := RandomInvertibleMat(n,r);; rmi := rm^-1;;
gap> e*rmi = e/rm;
true
gap> rm*rmi = rm/rm;
true
gap> Comm(rm,IdentityMat(n,r))=IdentityMat(n,r);
true
gap> Comm(rm,rm)=IdentityMat(n,r);
true
gap> Comm(rm,rmi)=One(rm);
true
gap> ## 
gap> ## vector ops
gap> ##
gap> v1 := v*m;;
gap> v1[1]=Sum(List([1..10],x->v[x]*m[x][1]));
true
gap> v1 := m*v{[1..5]};;
gap> v1[1]=Sum(List([1..5],x->m[1][x]*v[x]));
true
gap> rm := RandomInvertibleMat(5,r);; rmi := rm^-1;;
gap> rm*rmi = rmi*rm;
true
gap> v := List([1..5],x->Random(r));;
gap> v*rmi = v/rm;
true
gap> v := List([1..5],x->rmi[1][x]);;
gap> v*rm = [One(rm[1][1]),Zero(rm[1][1]),Zero(rm[1][1]),Zero(rm[1][1]),Zero(rm[1][1])];
true
gap> ##
gap> ## More general ring
gap> ##
gap> r := GroupRing(GF(2), ElementaryAbelianGroup(4));;
gap> m := RandomMat(10,5,r);;
gap> v := Flat(RandomMat(1,10,r));;
gap> e := Random(r);;
gap> ## 
gap> ## scalar ops
gap> ##
gap> m1 := e*m;;
gap> m1[5][5] = e*m[5][5];
true
gap> m1 := e+m;;
gap> m1[3][1] = e+m[3][1];
true
gap> m1 := m+e;;
gap> m1[3][1] = e+m[3][1];
true
gap> m1 := e-m;;
gap> m1[3][1] = e-m[3][1];
true
gap> m1 := m-e;;
gap> m1[3][1] = m[3][1]-e;
true
gap> mlst := [m,m1,m,m1];;
gap> mlst1 := e * mlst;;
gap> e*mlst[1]=mlst1[3];
true
gap> mlst := [m,m1,m,m1];;
gap> mlst1 := e + mlst;;
gap> e+mlst[1]=mlst1[3];
true
gap> ## 
gap> ## vector ops
gap> ##
gap> v1 := v*m;;
gap> v1[1]=Sum(List([1..10],x->v[x]*m[x][1]));
true
gap> v1 := m*v{[1..5]};;
gap> v2 := Sum(List([1..5],x->m[1][x]*v[x]));;
gap> v1[1]=v2;
true
gap> ##
gap> ##
gap> ########################################################################
gap> ##
gap> ## Properties and Attributes of Matrices
gap> ##
gap> #T
gap> #T Dimensions of malformed matrices
gap> #T 
gap> m := [[1,2,3],[2,3]];;
gap> DimensionsMat(m);
fail
gap> m := [[1],[1,2]];;
gap> DimensionsMat(m);
fail
gap> m := [[1,2,3,4],[1,2,3,4]];;
gap> DimensionsMat(m);
[ 2, 4 ]
gap> TransposedMatDestructive(m);;
gap> DimensionsMat(m);
[ 4, 2 ]
gap> ##
gap> m := [[Random(GF(34147))]];;
gap> DefaultFieldOfMatrix(m);
GF(34147)
gap> ##
gap> pr := PolynomialRing(Integers,15);;
gap> v := IndeterminatesOfPolynomialRing(pr);;
gap> d:= DiagonalMat(v);;
gap> Trace(d)=Sum(v);
true
gap> v1 := v*d;;
gap> v2 := List(v,x->x^2);;
gap> v1=v2;
true
gap> ##
gap> n:=5;;
gap> ##base elements for Vandermonde matrix
gap> v := [1/5,1/4,1/3,1/2,1];;  ##Rationals
gap> M := List(v,x->List([0..n-1],y->x^y));; ## build Vandermonde matrix
gap> VD := Product(List(Filtered(Cartesian([1..n],[1..n]),
> x->x[1]<x[2]), x->v[x[2]]-v[x[1]]));;  ## determine analytically determinant
gap> D := Determinant(M);;  ## compute
gap> VD=D;   ## compare
true
gap> D := DeterminantMatDivFree(M);; ## second method for testing
gap> VD=D;
true
gap> n:=5;;
gap> ##base elements for Vandermonde matrix
gap> v := [1,3,5,7,11];;  #integers
gap> M := List(v,x->List([0..n-1],y->x^y));; ## build Vandermonde matrix
gap> VD := Product(List(Filtered(Cartesian([1..n],[1..n]),
> x->x[1]<x[2]), x->v[x[2]]-v[x[1]]));;  ## determine analytically determinant
gap> D := Determinant(M);;  ## compute
gap> VD=D;   ## compare
true
gap> D := DeterminantMatDivFree(M);; ## second method for testing
gap> VD=D;
true
gap> v:=Elements(ZmodnZ(12)){[4..8]};;
gap> M := List(v,x->List([0..n-1],y->x^y));; ## build Vandermonde matrix
gap> VD := Product(List(Filtered(Cartesian([1..n],[1..n]),
> x->x[1]<x[2]), x->v[x[2]]-v[x[1]]));;  ## determine analytically determinant
gap> D := DeterminantMatDivFree(M);; ## can we only use the division free method
gap> VD=D;
true
gap> ##
gap> v:=Elements(GF(97)){[26..50]};;
gap> d:= DiagonalMat(v);;
gap> Product(v)=Determinant(d);
true
gap> Product(v)=DeterminantMatDivFree(d);
true
gap> v:=Elements(GroupRing(GF(2),ElementaryAbelianGroup(8))){[26..50]};;
gap> d:= DiagonalMat(v);;
gap> Product(v)=DeterminantMatDivFree(d);
true
gap> ##
gap> x := Indeterminate(Integers,1);;
gap> hm := [[x,x^0,0*x,0*x], [x^0,x,x^0,0*x], [0*x,x^0,x,x^0], [0*x,0*x,x^0,x]];;
gap> DeterminantMatDivFree(hm);
x_1^4-3*x_1^2+1
gap> ##
gap> ## Simple matrix functions for testing
gap> ##
gap> Minor := function(m,i,j) local m1;
> m1 := TransposedMat(m{Filtered([1..Length(m)],x->x<>i)});
> return TransposedMat(m1{Filtered([1..Length(m1)],x->x<>j)});
> end;;
gap> Cofactor := function(m,i,j) 
> return (-One(m[1][1]))^(i+j)*DeterminantMat(Minor(m,i,j));
> end;;
gap> CofactorDV := function(m,i,j) 
> return (-One(m[1][1]))^(i+j)*DeterminantMatDivFree(Minor(m,i,j));
> end;;
gap> Adjoint := m->
> TransposedMat(List([1..Length(m)], 
> i-> List([1..Length(m[i])], j-> Cofactor(m,i,j))));;
gap> AdjointDV := m->
> TransposedMat(List([1..Length(m)], 
> i-> List([1..Length(m[i])], j-> CofactorDV(m,i,j))));;
gap> ##
gap> ## Adjoint(m)*m = Det(m)*I
gap> m := RandomInvertibleMat(20,GF(2));;
gap> Adjoint(m)*m = DeterminantMat(m)*One(m);
true
gap> AdjointDV(m)*m = DeterminantMatDivFree(m)*One(m); #for testing
true
gap> ##
gap> n:=5;;
gap> VV:=Elements(ZmodnZ(12)){[4..8]};;
gap> MM := List(VV,x->List([0..n-1],y->x^y));; ## build Vandermonde matrix
gap> AdjointDV(MM)*MM = DeterminantMatDivFree(M)*One(M);
true
gap> ##
gap> ########################################################################
gap> ##
gap> ## Matrix Constructions 
gap> ##
gap> ##
gap> m := IdentityMat(40,Rationals);;
gap> v := List([1..40],x->One(Rationals));;
gap> m1 := DiagonalMat(v);;
gap> m=m1;
true
gap> IsMatrix(IdentityMat(0,GF(2)));
true
gap> nm := NullMat(40,40,Rationals);;
gap> nm=m-m;
true
gap> #T 
gap> #T We cannot determine the default field in this case.
gap> #T But can do some reasonabe things with the matrix. 
gap> #T 
gap> pr := PolynomialRing(Integers);;
gap> x := IndeterminatesOfPolynomialRing(pr)[1];;
gap> m := IdentityMat(5,pr);;
gap> v := List([1..5],x->One(pr));;
gap> m1 := DiagonalMat(v);;
gap> m=m1;
true
gap> DefaultFieldOfMatrix(m);
fail
gap> nm := NullMat(5,5,pr);;
gap> nm=m-m;
true
gap> #T
gap> #T EmptyMatrix Naming convention does not follow the 
gap> #T other operations/constructions
gap> #T
gap> em := EmptyMatrix(2);
EmptyMatrix( 2 )
gap> IsMutable(em);
false
gap> em0 := EmptyMatrix(0);
EmptyMatrix( 0 )
gap> em=em0;
true
gap> DimensionsMat(em);
[ 0, 0 ]
gap> em+em=em;
true
gap> em^em=em;
true
gap> []*em =em*[];
true
gap> 3*em=em;
true
gap> #T
gap> #T Can't use the ^ or + operations as stated in the manual:
gap> #T []+em;  gives a no method found
gap> #T []^em;  gives a no method found
gap> #T
gap> #T Must compare as lists
gap> #T
gap> []=em;
true
gap> IsMatrix([]);
false
gap> ##
gap> #T Allows to construct over a ring but not its elements
gap> #T x := Indeterminate(Integers);
gap> #T PermutationMat((),30,x);  no method found
gap> ##  
gap> pr := PolynomialRing(Integers);;
gap> pm := PermutationMat((),30,pr);;
gap> pm = IdentityMat(30,pr);
true
gap> pm = IdentityMat(30,1);
false
gap> pm := PermutationMat((1,2,3),3,pr);;
gap> pm1:= PermutationMat((1,2),3,pr);;
gap> pm*pm1 = PermutationMat((2,3),3,pr);
true
gap> #T
gap> #T According to the manual should return a matrix
gap> #T
gap> IsMatrix(PermutationMat((),0,GF(2)));
false
gap> ##
gap> tm := TransposedMat(pm);;
gap> IsMutable(tm);
false
gap> tm := MutableTransposedMat(pm);;
gap> IsMutable(tm);
true
gap> TransposedMat(IdentityMat(50,Rationals))=IdentityMat(50,Rationals);
true
gap> m := [[1,2,3],[4,5,6],[7,8,9]];;
gap> m1 := TransposedMat(m);;
gap> TransposedMatDestructive(m);;
gap> m=m1;
true
gap> ##
gap> m := [[1,2]];;
gap> m1 := [[5,7],[9,2]];;
gap> kp := KroneckerProduct(m,m1);
[ [ 5, 7, 10, 14 ], [ 9, 2, 18, 4 ] ]
gap> [DimensionsMat(m)[1]*DimensionsMat(m1)[1],
> DimensionsMat(m)[2]*DimensionsMat(m1)[2]] = DimensionsMat(kp);
true
gap> r := GF(269);;
gap> m1 := RandomInvertibleMat(4,r);;
gap> m2 := RandomInvertibleMat(4,r);;
gap> m3 := RandomInvertibleMat(4,r);;
gap> m4 := RandomInvertibleMat(4,r);;
gap> ##
gap> ## associativity, distributive, operation preserving
gap> KroneckerProduct(m1,KroneckerProduct(m2,m3))=
> KroneckerProduct(KroneckerProduct(m1,m2),m3);
true
gap>  KroneckerProduct(m1,m2+m3)=KroneckerProduct(m1,m2)+KroneckerProduct(m1,m3);
true
gap> TransposedMat(KroneckerProduct(m1,m2))=
> KroneckerProduct(TransposedMat(m1),TransposedMat(m2));
true
gap> Inverse(KroneckerProduct(m1,m2))=
> KroneckerProduct(Inverse(m1),Inverse(m2));
true
gap> Trace(KroneckerProduct(m1,m2))= Trace(m1)*Trace(m2);
true
gap> KroneckerProduct(m1*m2,m3*m4)=
> KroneckerProduct(m1,m3)*KroneckerProduct(m2,m4);
true
gap> ## use known relations about eigenvalues 
gap> kb := KroneckerProduct(m1,m3);;
gap> Set(Eigenvalues(r,kb)) = 
> Set(Flat(List(Eigenvalues(r,m1), x->x*Eigenvalues(r,m3))));
true
gap> ##
gap> ## Malformed construction
gap> KroneckerProduct([[1,2],[1,2]],[[5],[9,2,3]]);;
gap> DimensionsMat(last);
fail
gap> ##
gap> rm:=ReflectionMat([1,2,3,4,5,6,7,8,9,10]);;
gap> rm*[1,2,3,4,5,6,7,8,9,10]=[-1,-2,-3,-4,-5,-6,-7,-8,-9,-10];
true
gap> rm*rm*[1,2,3,4,5,6,7,8,9,10]=[1,2,3,4,5,6,7,8,9,10];
true
gap> rm^2=One(rm);
true
gap> rm:=ReflectionMat([1,2,3,4,5,6,7,8,9,10],E(10));;
gap> rm^10=One(rm);
true
gap> pr := PolynomialRing(Integers);;
gap> x := IndeterminatesOfPolynomialRing(pr)[1];;
gap> v := List([0..4],z->x^z);;
gap> rm := ReflectionMat(v,x->-x);;
gap> rm*v=-v;
true
gap> rm^2=One(rm);
true
gap> rm := ReflectionMat(v,x->x,E(3));;
gap> rm^3=One(rm);
true
gap> ##
gap> ########################################################################
gap> ##
gap> ##  Random Matrices
gap> ##
gap> ##
gap> m := RandomMat(10,43,[100,1000]);;
gap> DimensionsMat(m);
[ 10, 43 ]
gap> m := RandomInvertibleMat(10,GF(23));;
gap> One(m)=IdentityMat(10,GF(23));
true
gap> m^-1*m=IdentityMat(10,GF(23));
true
gap> m^0=One(m);
true
gap> #T
gap> #T RandomInvertibleMat fails at *times* for rings since it uses
gap> #T a method that requires multiplicative inverses. 
gap> #T So we get random failures for 
gap> #T gr := GroupRing(Integers, CyclicGroup(10));
gap> #T RandomInvertibleMat(2,gr);
gap> #T 
gap> #T When it does return how does it know it has an inverse? Can't use inverse.
gap> #T
gap> m := RandomUnimodularMat(10);;
gap> AbsInt(Determinant(m))=1;
true
gap> ########################################################################
gap> ##
gap> ## Matrices Representing Linear Equations and the Gaussian Algorithm
gap> ##
gap> ##
gap> ########################################################################
gap> ##
gap> ## Eigenvectors and eigenvalues
gap> ##
gap> ##
gap> ########################################################################
gap> ##
gap> ## Elementary Divisors
gap> ##
gap> ##
gap> ########################################################################
gap> ##
gap> ## Echelonized Matrices 
gap> ##
gap> ##
gap> ########################################################################
gap> ##
gap> ## Matrices as Basis of a Row Space 
gap> ##
gap> ##
gap> ########################################################################
gap> ##
gap> ## Triangular Matrices
gap> ##
gap> ##
gap> ########################################################################
gap> ##
gap> ## Matrices as Linear Mappings
gap> ##
gap> ##
gap> ########################################################################
gap> STOP_TEST( "matrix.tst", 44260000);

#############################################################################
##
#E
