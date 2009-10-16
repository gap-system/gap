#############################################################################
##
#W  examples.gi                     NilMat                       Alla Detinko
#W                                                               Bettina Eick
#W                                                              Dane Flannery
##

##
## This file contains methods to construct examples of some interesting nilpotent 
## matrix groups over Q and over finite fields.
##


#############################################################################
##
#F MonomialNilpotentMatGroup( n )
##
## This function constructs Kronecker products of all MonomialSylow(pi,ai), 
## where n = p1^a1...pr^ar is factorization of n.
##
InstallGlobalFunction( MonomialNilpotentMatGroup, function(n)
   local l1,l2,k,r,H,W,i,j;
   
   # First construct prime factorization of n.
   l1 := Filtered([2..n],x -> IsPrimeInt(x)); #list of primes <=n
   l2 := Filtered(l1, x -> IsInt(n/x)); #list of prime x dividing n
   r := List(l2, x -> PLength(n,x)); #max powers of x in n
   k := Length(l2);

   if k=1 then return Group(MonomialSylow(l2[1],r[1]));fi;
    
   H :=[]; #list of lists of generators
   for i in [1..k] do 
       H[i] := MonomialSylow(l2[i],r[i]);
   od;
 
   W := H[1];
   for j in [2..k] do
       W := KroneckerProductLists(W,H[j]);
   od; 
        
   return Group(W);
end );

#############################################################################
##
#F ReducibleNilpotentMatGroupRN( m, k [,l] )  . .a nilpotent mat group over Q
##
## NilpotentReducibleMatGroupRN constructs a nilpotent subgroup of GL(n, Q) 
## for n = mk which is reducible, but not completely reducible (and is not
## represented in the block upper triangular form). If a third arguement is
## given, then the entries in the initial matrices are choosen from [1..l],
## otherwise l=1 is taken. The constructed group is a Kronecker product of a 
## subgroup of UT(m,Q) and MonomialNilpotent(k). 
##
ReducibleNilpotentMatGroupRN := function(arg)
   local m, k, e, L, M, i;
     
   # catch arguments
   m := arg[1];
   k := arg[2];
   e := IdentityMat(m, Rationals);

   # an easy case 
   if m = 1 then return MonomialNilpotentMatGroup(k); fi;
   
   # a list of matrices of UT(m,Q). 
   L := [];
   for i in [1..(m-1)] do
      L[i] := ShallowCopy(e);
      if IsBound(arg[3]) then 
          L[i][i][m] := Random([1..arg[3]]);
      else
          L[i][i][m] := 1;
      fi;
   od;

   # monomial subgroups
   M := GeneratorsOfGroup(MonomialNilpotentMatGroup(k));

   # Kronecker products
   return Group(KroneckerProductLists(L,M));
end;
  
#############################################################################
##
#F ReducibleNilpotentMatGroupFF( m,k,p,l )  . .a nilpotent mat group over FF
##
## Constructs a nilpotent subgroup of GL(n, q) 
## for n = mk and q = p^l which is reducible, but not completely reducible 
## (and is not represented in the block upper triangular form). 
##
## The group is a Kronecker product of a subgroup of UT(m,q) and a 
## NilpotentMaxAbsIrreducible(k,po,l); it is supposed that (k,po,l) are 
## such that the latter exists.
##
ReducibleNilpotentMatGroupFF := function(m,k,po,l)
   local U, q, w, e, L, i;

   U := MaximalAbsolutelyIrreducibleNilpotentMatGroup(k,po,l);
   if U = fail then return fail;fi;
   if m = 1 then return U; fi;

   q := po^l;
   w := Z(q);
   e := IdentityMat(m, w);
   L := [];

   # a list of matrices of UT(m,w).
   for i in [1..(m-1)] do
      L[i] := ShallowCopy(e);
      L[i][i][m] := w;
   od;

   return Group(KroneckerProductLists(L,GeneratorsOfGroup(U)));
end;

#############################################################################
##
#F ReducibleNilpotentMatGroup( m,k,[p,l] ) 
##
InstallGlobalFunction(ReducibleNilpotentMatGroup, function(arg)
    if Length(arg) = 4 then 
        return ReducibleNilpotentMatGroupFF(arg[1],arg[2],arg[3],arg[4]);
    elif Length(arg) = 3 then
        return ReducibleNilpotentMatGroupRN(arg[1],arg[2],arg[3]);
    else
        return ReducibleNilpotentMatGroupRN(arg[1],arg[2]);
    fi;
end );
      
