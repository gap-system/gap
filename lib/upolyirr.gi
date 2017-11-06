#############################################################################
##
#W  upolyirr.gi                     GAP Library                 Frank Lübeck
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file  contains methods to compute irreducible univariate polynomials
##

#############################################################################
##
#F  AllMonicPolynomialCoeffsOfDegree( <n>, <q> )  . . . . . all coefficient 
#F  lists of monic polynomials over GF(<q>) of degree <n> 
##  
AllMonicPolynomialCoeffsOfDegree := function(n, q)
local   fq,  one,  res,  a;
  
  fq := AsSortedList(GF(q));
  one := One(GF(q));
  
  res := Tuples(fq, n);
  for a in res do 
    Add(a, one); 
  od;
  
  return res;
end;

#############################################################################
##
#F  AllIrreducibleMonicPolynomialCoeffsOfDegree( <n>, <q> )  . all coefficient
#F  lists of irreducible monic polynomials over GF(<q>) of degree <n> 
##  
#V  IRR_POLS_OVER_GF_CACHE:  a cache for the following function
##  
IRR_POLS_OVER_GF_CACHE := [];
AllIrreducibleMonicPolynomialCoeffsOfDegree := function(n, q)
  local   l,  zero,  i,  r,  p, new, neverdiv;
  if not IsBound(IRR_POLS_OVER_GF_CACHE[q]) then
    IRR_POLS_OVER_GF_CACHE[q] := [];
  fi;
  if IsBound(IRR_POLS_OVER_GF_CACHE[q][n]) then
    return IRR_POLS_OVER_GF_CACHE[q][n];
  fi;
  
  # this is for going around converting coefficients to polynomials 
  # and using the \mod operator for divisibility tests
  # (I found a speedup factor of about 6 in the example n=9, q=3) 
  neverdiv := function(r, p)
    local   lr,  lp,  rr,  pp;
    lr := Length(r[1]);
    lp := Length(p);
    for rr in r do
      pp := ShallowCopy(p);
      ReduceCoeffs(pp, lp, rr, lr);
      ShrinkRowVector(pp);
      if Length(pp)=0 then
        return false;
      fi;
    od;
    return true;
  end;
  
  l := AllMonicPolynomialCoeffsOfDegree(n, q);
  zero := 0*Indeterminate(GF(q));
  for i in [1..Int(n/2)] do
    r := AllIrreducibleMonicPolynomialCoeffsOfDegree(i, q);
    new:= [];
    for p in l do
      if neverdiv(r, p) then
        Add(new, p);
      fi;
    od;
    l := new;
  od;
  
  IRR_POLS_OVER_GF_CACHE[q][n] := Immutable(l);
  return IRR_POLS_OVER_GF_CACHE[q][n];  
end;

#############################################################################
##
#F CompanionMat( <poly>
##
InstallGlobalFunction( CompanionMat, function ( arg )

    local c, l, res, i, F, c1;

    # for the moment allow coefficients as well
    if not IsList( arg[1] ) then
        c := CoefficientsOfLaurentPolynomial( arg[1] );
        if c[2] < 0 then
           Error( "This polynomial does not have a companion matrix" );
        fi;
        F:= DefaultField( c[1] );
        c1:= ListWithIdenticalEntries( c[2], Zero(F) );
        Append( c1, c[1] );
        c:= c1;
    else
        c := arg[1];
        F:= DefaultField( c );    
    fi;
    
    l := Length( c ) - 1;
    if l = 0 then 
       Error( "This polynomial does not have a companion matrix" );
    fi;
    res := NullMat( l, l, F );
    res[1][l] := -c[1];
    for i in [2..l] do
        res[i][i-1] := One( F );
        res[i][l] := -c[i];
    od;
    return res;
end );
 
#############################################################################
##
#F AllIrreducibleMonicPolynomials( <degree>, <field> )
##
InstallGlobalFunction( AllIrreducibleMonicPolynomials, 
function( degree, field )
    local q, coeffs, fam, nr;
    if not IsFinite( field ) then
        Error("field must be finite");
    fi;
    q := Size(field);
    nr := IndeterminateNumberOfLaurentPolynomial( 
          Indeterminate(field,"x"));
    coeffs := AllIrreducibleMonicPolynomialCoeffsOfDegree(degree,q);
    fam := FamilyObj( Zero(field) );
    return List( coeffs, 
	   x -> LaurentPolynomialByCoefficients( fam, x, 0, nr ) );
end );

