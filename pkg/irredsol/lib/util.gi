############################################################################
##
##  util.gi                      IRREDSOL                 Burkhard Hoefling
##
##  @(#)$Id: util.gi,v 1.3 2005/07/06 10:05:11 gap Exp $
##
##  Copyright (C) 2003-2005 by Burkhard Hoefling, 
##  Institut fuer Geometrie, Algebra und Diskrete Mathematik
##  Technische Universitaet Braunschweig, Germany
##


############################################################################
##
#I  TestFlag(<n>, <i>)
##
##  tests if the i-th bit is set in binary representation the nonnegative 
##  integer n
##  
InstallGlobalFunction (TestFlag,
   function (n, i)
      return QuoInt (n, 2^i) mod 2 = 1;
   end);
   

############################################################################
##
#F  NumberOfFFPolynomial(<p>, <q>)
##
##  computes a number characterising the polynomial p.
##  The polynomial p wmust be over GF(q)
##  
InstallGlobalFunction (NumberOfFFPolynomial, function (p, q)

   local cf, z, sum, c;
   
   cf := CoefficientsOfUnivariatePolynomial (p);
   z := Z(q);
   sum := 0;
   for c in cf do
      if c = 0*z then
         sum := sum * q;
      else 
         sum := sum * q + LogFFE (c, z) + 1;
      fi;
   od;
   return sum;
end);


############################################################################
##
#F  FFMatrixByNumber(n, d, q)
##
##  computes a d x d matrix over GF(q) represented by the integer n
##  
InstallGlobalFunction (FFMatrixByNumber,
   function (n, d, q)
   
      local z, m, i, j, k;
      
      z := Z(q);
      m := NullMat (d,d, GF(q));
   
      for i in [d, d-1..1] do
         for j in [d, d-1..1] do
            k := RemInt (n, q);
            n := QuoInt (n, q);
            if k > 0 then
               m[i][j] := z^(k-1);
            fi;
         od;
      od;
      ConvertToMatrixRep (m, q);
      return m;
   end);
   
   
############################################################################
##
#F  CanonicalPcgsByNumber(<pcgs>, <n>)
##
##  computes the canonical pcgs wrt. pcgs represented by the integer n
##  
InstallGlobalFunction (CanonicalPcgsByNumber,
   function (pcgs, n)
   
      local gens, cpcgs;
      
      gens := List (ExponentsCanonicalPcgsByNumber (RelativeOrders (pcgs), n), 
         exp -> PcElementByExponents (pcgs, exp));
      cpcgs := InducedPcgsByPcSequenceNC (pcgs, gens);
      SetIsCanonicalPcgs (cpcgs, true);
      return cpcgs;
   end);


############################################################################
##
#F  OrderGroupByCanonicalPcgsByNumber(<pcgs>, <n>)
##
##  computes Order (Group (CanonicalPcgsByNumber(<pcgs>, <n>))) without 
##  actually constructing the canonical pcgs or the group
##  
InstallGlobalFunction (OrderGroupByCanonicalPcgsByNumber,
   function (pcgs, n)
   
      local ros, order, j;
      
      order := 1;
      ros := RelativeOrders (pcgs);
      n := RemInt (n, 2^Length (ros));
      for j in [1..Length(ros)] do
         if RemInt (n, 2) > 0 then
            order := order * ros[j];
         fi;
         n := QuoInt (n, 2);
      od;
      return order;
   end);


############################################################################
##
#F  ExponentsCanonicalPcgsByNumber(<pcgs>, <n>)
##
##  computes the list of exponent vectors (relative to exp) of the 
##  elements of CanonicalPcgsByNumber(<pcgs>, <n>)) without actually
##  constructing the canonical pcgs itself
##  
InstallGlobalFunction (ExponentsCanonicalPcgsByNumber,
   function (ros, n)
   
      local depths, len, d, exps, exp, j, cpcgs;
      depths := [];
      len := Length(ros);
      for j in [1..len] do
         d := RemInt (n, 2);
         n := QuoInt (n, 2);
         if d > 0 then
            Add (depths, j);
         fi;
      od;
   
      exps := [];
      for d in depths do
         exp := ListWithIdenticalEntries (len, 0);
         exp[d] := 1;
         for j in [d+1..len] do
            if not j in depths then
               exp[j] := RemInt (n, ros[j]);
               n := QuoInt (n, ros[j]);
            fi;
         od;
         Add (exps, exp);
      od;
      
      return exps;
   end);


############################################################################
##
#F  IsMatGroupOverFieldFam(famG, famF)
##
##  tests whether famG is the collections family of matrices over the field
##  whose family is famF
##  
InstallGlobalFunction (IsMatGroupOverFieldFam, function (famG, famF)
   return CollectionsFamily (CollectionsFamily (famF)) = famG;
end);


############################################################################
##
#V  IRREDSOL_DATA.PRIME_POWERS
##
##  cache of proper prime powers, preset to all prime powers <= 65535
##  
IRREDSOL_DATA.PRIME_POWERS := [ 
  4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 9, 
  27, 81, 243, 729, 2187, 6561, 19683, 59049, 25, 125, 625, 3125, 15625, 49, 
  343, 2401, 16807, 121, 1331, 14641, 169, 2197, 28561, 289, 4913, 361, 6859, 
  529, 12167, 841, 24389, 961, 29791, 1369, 50653, 1681, 1849, 2209, 2809, 
  3481, 3721, 4489, 5041, 5329, 6241, 6889, 7921, 9409, 10201, 10609, 11449, 
  11881, 12769, 16129, 17161, 18769, 19321, 22201, 22801, 24649, 26569, 
  27889, 29929, 32041, 32761, 36481, 37249, 38809, 39601, 44521, 49729, 
  51529, 52441, 54289, 57121, 58081, 63001 ];


############################################################################
##
#F  IsPPowerInt(q)
##
##  tests whether q is a prime power, caching new prime powers
##  
InstallGlobalFunction (IsPPowerInt, 
   function (q)
      if IsPrimeInt (q) then
         return true;
      elif q in IRREDSOL_DATA.PRIME_POWERS then
         return true;
      elif IsPrimePowerInt(q) then
         AddSet (IRREDSOL_DATA.PRIME_POWERS, q);
         return true;
      else
         return false;
      fi;
   end);


############################################################################
##
#E
##
