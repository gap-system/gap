#############################################################################
##
#W  orders.gi           COMMSEMI library              Isabel Araujo
##
#H  @(#)$Id: orders.gi,v 1.2 2000/06/01 15:43:59 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file has some predefined vector orderings
##
Revision.orders_gi:=
    "@(#)$Id: orders.gi,v 1.2 2000/06/01 15:43:59 gap Exp $";


############################################################################
##
##  IsVectorLexicographicLessThanOrEqual
##
##  Lexicographic order on N^n
##  returns true if u is less than or equal to v wrt the lexicographic order
##
##  Now, u <= v with respect to the lexicographic order iff
##  the last non-zero coordinate of u-v is negative
##  (see Rosales & Garcia, p.54)
##
BindGlobal("IsVectorLexicographicLessThanOrEqual", 
function(u,v)
  local i,n;
   
  n := Length(v);
  for i in [1..n] do
    if u[n-i+1]-v[n-i+1]<>0 then
      return u[n-i+1]<v[n-i+1];
    fi;
  od;
    
  return true;
end);

############################################################################
##
##  IsVectorReverseLexicographicLessThanOrEqual
##
##  Reverse lexicographic order on N^n
##  returns true if u is less than or equal to v wrt the lexicographic order
##
##  Now, u <= v with respect to the lexicographic order iff
##  the last non-zero coordinate of u-v is negative
##  (see Rosales & Garcia, p.55)
##
BindGlobal("IsVectorReverseLexicographicLessThanOrEqual",
function(u,v)
  local i,n;
  
  n := Length(u);
  for i in [1..Length(v)] do
    if u[n-i+1]-v[n-i+1]<>0 then
      return u[n-i+1]<v[n-i+1];
    fi;
  od;
    
  return true;
end);

############################################################################
##
##  IsVectorTotalOrderLessThanOrEqual
##
##  Total order on N^n (or shortlex)
##  returns true if u is less than or equal to v wrt the total order
##
##  Now, u <= v with respect to total order iff
##   u_1+u_2+...+u_n < v_1+v_2+...+v_n
##  or
##   u_1+u_2+...+u_n = v_1+v_2+...+v_n and u<=v wrt lexicographic order
##  (see Rosales & Garcia, p.55)
## 
BindGlobal("IsVectorTotalOrderLessThanOrEqual",
function(u,v)
  local sum;                # sum of entries of u minus sum of entries of v 

  sum :=Sum(u-v);

  if sum<>0 then 
    return sum<0;
  fi;

  return IsVectorLexicographicLessThanOrEqual(u,v);

end); 

############################################################################
##
##  IsVectorPrimeOrderLessThanOrEqual
##
##  Prime order on N^n (for small values of n)
##  returns true if u is less than or equal to v wrt the prime order
##  returns fail if n>168 (gap only has a list of the first 168 primes)
##
##  Now, u <= v with respect to the prime order iff
##   p_1^{u_1}p_2^{u_2}...p^n^{u_n} <= p_1^{v_1}...p_n^{v_n}
##  (see Rosales & Garcia, p.55)
##  
BindGlobal("IsVectorPrimeOrderLessThanOrEqual",
function(u,v)
  local n;
 
  n := Length(u); 
  return  Product(List([1..n],i->Primes[i]^u[i]))<=
          Product(List([1..n],i->Primes[i]^v[i]));

end);

############################################################################
##
##  IsVectorDivLessThanOrEqual
##
##  Divisibility order on N^n 
##  this function compares two n-tuples with respect to the 
##  divisibility ordering
##  returns true if each entry of u is less then or equal to the 
##  correspondent entry of v; false if each entry of u is greater then 
##  the correspondent entry of v; fail otherwise 
##  (ie, the words are not comparable) 
##
BindGlobal("IsVectorDivLessThanOrEqual",
function(u,v)

  return ForAll([1..Length(v)], i-> u[i]<=v[i]); 

end); 

