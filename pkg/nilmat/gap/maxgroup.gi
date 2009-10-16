#############################################################################
##
#W  maxgroup.gi                     NilMat                       Alla Detinko
#W                                                               Bettina Eick
#W                                                              Dane Flannery
##

##
## This file contains methods to construct a nilpotent maximal absolutely
## irreducible subgroup of GL(n,q).
##

#############################################################################
##
#F MonomialSylow(p,a[,po,t]) . . . . . . . . . . . .construct monomial group
##
## This function constructs a list of generators for a monomial p-subgroup
## of GL(p^a, F) isomorphic to a Sylow p-subgroup of S_(p^a). If 2 arguments
## are given, then F = Q is used, otherwise F = GF(po^t).
##
MonomialSylow := function(arg)
   local s,g,p,a;
   p := arg[1];
   a := arg[2];
   s := SylowSubgroup(SymmetricGroup(p^a),p);
   g := GeneratorsOfGroup(s);
   if Length(arg) = 2 then 
       return List(g, x -> PermutationMat(x,p^a,Rationals));
   else
       return List(g, x -> PermutationMat(x,p^a,GF(arg[3],arg[4])));
   fi;
end;

#############################################################################
##
#F CyclicSylow(m,p)  . . . . . . . . . . . . . . construct cyclic Sylow group
##
## For a given element m of a field and a prime p construct a generator of 
## the Sylow p-subgroup of <m>; if p does not divide |<m>| returns 1. 
##
CyclicSylow := function(m,p) 
   local o, t, o1;
   o := Order(m);
   t := PLength(o,p);    #equals 0 if p does not divide o
   o1 := o/(p^t);
   return m^o1;
end;

#############################################################################
##
#F AbelianSylow(p,a) . . . . . . . . . . . . . . . 
#F TwoSylow(p,a) . . . . . . . . . . . . . . . 
##
## Constructs generators for a Sylow 2-subgroup G of GL(2,q) for 4|q-3. 
## This group has the form G = <A,g> and A is an abelian subgroup of G of 
## index 2.
##
## First construct A, which is isomorphic to the Sylow 2-subgroup of F(i)
## via a regular representation, i.e. an element i of order 4 should be
## represented by the matrix [[0,1],[-1,0]].
##
AbelianSylow := function(po,t) 
   local a,c,r,i,F,F1,B,B1,B2,vec;
   F := GF(po,t);
   F1 := GF(F,2);
   a := PrimitiveRoot(F1);
   c := CyclicSylow(a,2);
   r := Order(c);
   i := c^(r/4); #element of order 4 in GF(F,2);exists as 4|q^2-1
   B := Basis(F1); #canonical basis of F1/F
   B1 := [a^0,i];
   B2 := RelativeBasis(B,B1);#change of canonical basis to B1
   vec := BasisVectors(B2);
   return List(vec, x -> Coefficients(B2,x*c));# this is A=<C> in GL(2,q)
end;

TwoSylow := function(po,t)
   local A,g;
   A := AbelianSylow(po,t);
   g := DiagonalMat([Z(po,t)^0,(-1)*Z(po,t)^0]);
   return [A,g];
end;

#############################################################################
##
#F KroneckerProductLists( L, M )
##
## This function constructs the list of pairwise Kronecker products of the input
## lists L and M.
##
KroneckerProductLists := function(L,M)
   local i,LM;
   LM := [];
   for i in [1..Length(M)] do
      Append( LM, List(L, x -> KroneckerProduct(x, M[i])));
   od;
   return LM;
end;

#############################################################################
##
#F SylowSubgroupGL(p,a,po,t)
##
## Construct generators of the Sylow p-subgroup of GL(p^a,q), p|q-1. Such 
## subgroups are absolutely irreducible.
##
SylowSubgroupGL := function(p,a,po,t)
   local q,c,C,w,S,h,H,K,l,L,n;

   # set up
   q := po^t;
   if not IsInt((q-1)/p) then return fail; fi;
 
   w := Z(q);
   n := p^a;

   #First construct the Sylow subgroup in monomial case
   if p>2 or q mod 4 = 1 then 
       c := CyclicSylow(w,p);
       C := IdentityMat(n,w);
       C[n][n] := c;
       S := MonomialSylow(p,a,po,t);
       Add(S,C);    
       return S; 
   fi;

   # now we have p=2 and q mod 4 = 3, i.e. if we have the non-monomial case
    
   h := TwoSylow(po,t); #primitive 2-Sylow subgroup of GL(2,q);2 generators
   if a=1 then return h;fi;
         
   H := IdentityMat(n,w);
   H[1][1] := h[1][1][1];     
   H[1][2] := h[1][1][2]; 
   H[2][1] := h[1][2][1]; 
   H[2][2] := h[1][2][2]; 
    
   K := IdentityMat(n,w);
   K[1][1] := h[2][1][1];     
   K[1][2] := h[2][1][2]; 
   K[2][1] := h[2][2][1]; 
   K[2][2] := h[2][2][2]; 

   l := MonomialSylow(p,a-1,po,t);
   L := List(l, x -> KroneckerProduct(x,IdentityMat(2,w)));
   Add(L,H);     
   Add(L,K);
   return L;
end;

#########################################################################
##
#F MaximalAbsolutelyIrreducibleNilpotentMatGroup . . . 
##
## This function constructs a nilpotent maximal absolutely irreducible 
## subgroup G of GL(n, q) or returns 'fail' if such subgroups do not exist.
## The group GL(n,q) contains absolutely irreducible nilpotent subgroups 
## if p|q-1 for each prime divisor p of n.
##
## Let n = p1^a1...pk^ak be the prime facorization of n. Then G
## is a Kronecker product of groups G1,...,Gk, where Gi = Hi \cdot F*, 
## Hi is a Sylow pi-subgroup of GL(pi^ai,F). Sylow p-subgroups of GL(p^a,F)
## are absolutely irreducible monomial (recall p|q-1), besides the case
## p=2, 4|q-3 when Sylow 2-subgroups of GL(2,q) are primitive and
## a Sylow 2-subgroups of GL(2^a,q) is imprimitive with 2-dimension
## systems of imprimitivity (a>1).
##
InstallGlobalFunction( MaximalAbsolutelyIrreducibleNilpotentMatGroup,
function(n,po,t)
    local q,w,l1,l2,k,r,H,W,i;

    q := po^t;
    w := Z(q);

    #First construct prime factorization of n.
    l1 := Filtered([2..n],x -> IsPrimeInt(x));
    l2 := Filtered(l1, x -> IsInt(n/x));
    r := List(l2, x -> PLength(n,x));
    k := Length(l2);

    # an easy case
    if not ForAll(l2,x -> IsInt((q-1)/x)) then return fail; fi;

    # construct a list of lists of generators 
    H := List([1..k], x -> SylowSubgroupGL(l2[x], r[x],po,t));
     
    # build up kronecker-products
    W := H[1];
    for i in [2..k] do
        W := KroneckerProductLists(W,H[i]);
    od; 
    Add( W, IdentityMat(n,w)*w );
     
    return Group(W);
end );

  
