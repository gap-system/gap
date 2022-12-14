#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Stefan Kohl.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains code for computing (with) continued fraction
##  expansions of real numbers.
##

#############################################################################
##
#F  ContinuedFractionExpansionOfRoot( <P>, <n> )
##
InstallGlobalFunction( ContinuedFractionExpansionOfRoot,

  function ( P, n )

    local  a, ai, Pi, Pi_1, pols, d, x0, step, bincoeff, i, j, k;

    if   not IsUnivariatePolynomial(P)
      or not (IsPosInt(n) or DegreeOfLaurentPolynomial(P) = 2 and n = 0)
      or not ForAll(CoefficientsOfLaurentPolynomial(P)[1],IsInt)
      or LeadingCoefficient(P) < 0
    then
      Error("usage: ContinuedFractionExpansionOfRoot( <P>, <n> ) ",
            "for a polynomial P with integer coefficients and a ",
            "positive integer <n>");
    fi;
    P := CoefficientsOfLaurentPolynomial(P);
    P := Concatenation(ListWithIdenticalEntries(P[2],0),P[1]);
    d := Length(P) - 1;
    bincoeff := List([0..d],n->List([0..d],k->Binomial(n,k)));
    if   ValuePol(P,0) >= 0 then
      Error("the value of <P> at x = 0 has to be negative");
    fi;
    a := []; Pi := ShallowCopy(P); pols := []; i := 1;
    while i <= n or n = 0 do
      if d = 2 and n = 0 then
        Add(pols,Pi);
      fi;
      x0 := 1; step := 1;
      while ValuePol(Pi,x0) < 0 do
        x0   := x0 + step;
        step := 2 * step;
      od;
      step := step/4;
      while step >= 1 do
        if ValuePol(Pi,x0) > 0 then
          x0 := x0 - step;
        else
          x0 := x0 + step;
        fi;
        step := step/2;
      od;
      if ValuePol(Pi,x0) > 0 then
        ai := x0 - 1;
      else
        ai := x0;
      fi;
      a[i] := ai;
      Pi_1 := ShallowCopy(Pi); Pi := ListWithIdenticalEntries(d+1,0);
      for j in [1..d+1] do
        for k in [1..d-j+2] do
          Pi[k] := Pi[k] + Pi_1[d-j+2]*bincoeff[d-j+2][k]*ai^(d+2-j-k);
        od;
      od;
      Pi := -Reversed(Pi);
      if Pi[d+1] = 0 then
        break; # Root is rational.
      fi;
      if d = 2 and n = 0 and Pi in pols then
        break; # One period is done.
      fi;
      i := i + 1;
    od;
    return a;
  end );

#############################################################################
##
#F  ContinuedFractionApproximationOfRoot( <P>, <n> )
##
InstallGlobalFunction( ContinuedFractionApproximationOfRoot,

  function ( P, n )

    local  a, M;

    if   not IsUnivariatePolynomial(P)
      or not (IsPosInt(n) or DegreeOfLaurentPolynomial(P) = 2 and n = 0)
      or not ForAll(CoefficientsOfLaurentPolynomial(P)[1],IsInt)
      or LeadingCoefficient(P) < 0
    then
      Error("usage: ContinuedFractionApproximationOfRoot( <P>, <n> ) ",
            "for a polynomial P with integer coefficients and a ",
            "positive integer <n>");
    fi;
    a := ContinuedFractionExpansionOfRoot(P,n);
    M := Product(a,a_i->[[a_i,1],[1,0]]);
    return M[1][1]/M[2][1];
  end );
