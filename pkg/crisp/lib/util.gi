#############################################################################
##
##  util.gi                         CRISP                   Burkhard Höfling
##
##  @(#)$Id: util.gi,v 1.19 2011/05/15 19:18:07 gap Exp $
##
##  Copyright (C) 2000-2003, 2005 Burkhard Höfling
##
Revision.util_gi :=
    "@(#)$Id: util.gi,v 1.19 2011/05/15 19:18:07 gap Exp $";


#############################################################################
##
#M  CentralizesLayer (<list>, <mpcgs>)
##
InstallMethod (CentralizesLayer, "generic method", IsIdenticalObj,
   [IsListOrCollection, IsModuloPcgs], 0,
   function (l, mpcgs)

      local len, i, x, exp, j;
   
      len := Length (mpcgs);
      for i in [1..len] do
         for x in l do
            exp := ExponentsConjugateLayer (mpcgs, mpcgs[i], x);
            if exp[i] <> 1 then
               return false;
            fi;
            for j in [1..len] do
               if exp[j] <> 0 and i <> j then
                  return false;
               fi;
            od;
         od;
      od;
      return true;
   end);


InstallMethod (CentralizesLayer, "for empty list", true,
   [IsListOrCollection and IsEmpty, IsModuloPcgs], 0,
   ReturnTrue);


#############################################################################
##
#M  PrimePowerGensPcSequence (<grp>)
##
InstallMethod (PrimePowerGensPcSequence, 
   "for group which can easily compute a pcgs", true,
   [IsGroup and CanEasilyComputePcgs], 0,
   function (G)
      local pcgs, primes, gens, x, o, qr, r, p, f, pos, len;
         
      primes := [];
      gens := [];
      len := 0;
      pcgs := Pcgs (G);
      
      for x in pcgs do
         o := Order (x);
         p := RelativeOrderOfPcElement (pcgs, x);
         
         # we are looking for the p-part of x
         qr := [o, 0];
         repeat
            r := qr[1];
            qr := QuotientRemainder (Integers, r, p);
         until qr[2] <> 0;
         pos := PositionSorted (primes, p);
         
         if pos <= Length (primes) and primes[pos] = p then
            Add (gens[pos], x^r);
         else #insert a new prime
            Add (primes, p, pos);
            Add (gens, [x^r], pos);
            len := len + 1;
         fi;
      od;
      return rec (primes := primes, generators := gens, pcgs := pcgs);
   end);
   
   
#############################################################################
##
#M  PrimePowerGensPcSequence (<grp>)
##
InstallMethod (PrimePowerGensPcSequence, "for group with special pcgs", true,
   [IsGroup and HasSpecialPcgs], 0,
   function (G)
      local pcgs, primes, gens, x, o, qr, r, p, f, pos, len;
         
      primes := [];
      gens := [];
      len := 0;
      pcgs := SpecialPcgs (G);
      
      # elements already have prime power order
      for x in pcgs do
         p := RelativeOrderOfPcElement (pcgs, x);
         
         pos := PositionSorted (primes, p);
         if pos <= Length (primes) and primes[pos] = p then
            Add (gens[pos], x);
         else #insert a new prime
            Add (primes, p, pos);
            Add (gens, [x], pos);
            len := len + 1;
         fi;
      od;
      return rec (primes := primes, generators := gens, pcgs := pcgs);
   end);
   

############################################################################
##
#M  IsNilpotentGroup
##
InstallMethod (IsNilpotentGroup, "for pcgs computable group", true,
   [IsGroup and IsFinite and CanEasilyComputePcgs], 0,
   function (G)
      local pseq, i, j;
      
      if HasSpecialPcgs (G) then
         TryNextMethod();
      fi;
      
      pseq := PrimePowerGensPcSequence (G);
      for i in [1..Length (pseq.generators)] do
         for j in [i+1..Length (pseq.generators)] do
            if ForAny (pseq.generators[i], x ->
               ForAny (pseq.generators[j], y -> x^y <> x)) then
                  return false;
            fi;
         od;
      od;
      return true;
   end);
   
      
############################################################################
##
#M  NormalGeneratorsOfNilpotentResidual
##
InstallMethod (NormalGeneratorsOfNilpotentResidual, "for pcgs computable group",
   true,
   [IsGroup and IsFinite and CanEasilyComputePcgs], 
   0,
   function (G)
      local pgens, gens, i, j, x, y, c, id;
      id := One(G);
      gens := [];
      pgens := PrimePowerGensPcSequence (G);
      for i in [1..Length (pgens.generators)] do
         for j in [i+1..Length (pgens.generators)] do
            for x in pgens.generators[i] do
               for y in pgens.generators[j] do
                  c := Comm (x, y);
                  if c <> id then
                     Add (gens, c);
                  fi;
               od;
            od;
         od;
      od;
      return gens;
   end);
   

############################################################################
##
#M  NormalGeneratorsOfNilpotentResidual
##
InstallMethod (NormalGeneratorsOfNilpotentResidual, 
   "generic method - use lower central series",
   true,
   [IsGroup], 
   0,
   function (G)
      local lcs;
      lcs := LowerCentralSeries (G);
      return GeneratorsOfGroup (lcs[Length (lcs)]);
   end);

      
###################################################################################
##
#F  CompositionSeriesElAbFactorUnderAction (<act>, <M>, <N>)
##
##  computes a <act>-composition series of the elementary abelian normal section M/N,
##  i.e. a list M = N_0 > N_1 > ... > N_r = N of subgroups of <grp> such that 
##  there is no <grp>-invariant subgroup between N_i and N_{i+1}.
##
InstallGlobalFunction ("CompositionSeriesElAbFactorUnderAction",
   function (act, M, N)

      local m;
      
      m := Pcgs (M) mod InducedPcgs (Pcgs (M), N);
      return List (PcgsCompositionSeriesElAbModuloPcgsUnderAction (act, m),
         s -> SubgroupByPcgs (M, s));
   end);
   

      
###################################################################################
##
#F  PcgsCompositionSeriesElAbModuloPcgsUnderAction (<act>, <sec>)
##
##  computes a series of pcgs representing a <act>-composition series of the elementary 
##  abelian normal section M/N, represented by the modulo pcgs <sec>.
## i.e. a list M = N_0 > N_1 > ... > N_r = N of subgroups of N such that 
##  there is no <grp>-invariant subgroup between N_i and N_{i+1}.
##
InstallGlobalFunction ("PcgsCompositionSeriesElAbModuloPcgsUnderAction",
   function (act, pcgs)

      local ppcgs, bas, bases, mats, p, one, new, ser, b, v, gens, num, 
         y, len, depth, ddepth, pos, dp, t0, t;
      
      num := NumeratorOfModuloPcgs (pcgs);
      
      if Length (pcgs) = 0 then
         return [num];
      elif Length (pcgs) = 1 then
         return [num, DenominatorOfModuloPcgs (pcgs)];
      fi;
      
      ppcgs := ParentPcgs (num);
      p := RelativeOrderOfPcElement (pcgs, pcgs[1]);
         
      if IsGroup (act) then
         act := GeneratorsOfGroup (act);
      fi;
      
      if Length (act) = 0 then
         bases := IdentityMat (Length (pcgs), GF(p));
         bas := List ([1..Length (bases)], i -> bases{[i..Length (bases)]});   
         Add (bas, []);
      else
         one := One(GF(p));
         mats := List (act, a ->
			   List (pcgs, x -> ExponentsOfPcElement (pcgs, x^a)*one));         
         bas := [];
      
         t0 := Runtime();
         bases := MTX.BasesCompositionSeries (GModuleByMats (mats, GF(p)));
         t := Runtime() - t0;
      
         for b in bases do
            new := MutableCopyMat (b);
            TriangulizeMat (new);
            Add (bas, new);
         od;
      fi;
      
      Sort (bas, function (a, b) return Length (a) > Length (b); end);
      
      ser := [];
      
      ddepth := List (DenominatorOfModuloPcgs (pcgs), 
         y -> DepthOfPcElement (ppcgs, y));
         
      for b in bas do
         gens := List (DenominatorOfModuloPcgs (pcgs));
         len := Length (gens);
         depth := ShallowCopy (ddepth);
         
         for v in b do
            y := PcElementByExponentsNC (pcgs, v);
            dp := DepthOfPcElement (ppcgs, y);
            pos := PositionSorted (depth, dp);
            while pos <= len and dp = depth[pos] do
               y := ReducedPcElement (ppcgs, y, gens[pos]);
               dp := DepthOfPcElement (ppcgs, y);
               pos := PositionSorted (depth, dp);
            od;
            Add (gens, y, pos);
            Add (depth, dp, pos);
            len := len + 1;
         od;
         Add (ser, InducedPcgsByPcSequenceNC (ppcgs, gens));
      od;
      return ser;
   end);


###################################################################################
##
#M  ChiefSeries (<grp>)
##
InstallMethod (ChiefSeries, 
   "for pcgs computable group refining PcgsElementaryAbelianSeries",
   true, [IsGroup and CanEasilyComputePcgs], 1,
   function (G)
   
      local gens, pcgs, inds, elabser, i, ser;
      
      pcgs := PcgsElementaryAbelianSeries (G);
      inds := IndicesEANormalSteps (pcgs);
      elabser := List (inds, 
          i -> InducedPcgsByPcSequence (pcgs, pcgs{[i..Length (pcgs)]}));      
      ser := [];
      for i in [1..Length (elabser)-1] do
         Append (ser, 
            PcgsCompositionSeriesElAbModuloPcgsUnderAction (
               pcgs{[1..inds[i]-1]}, elabser[i] mod elabser[i+1]));
         Unbind (ser[Length (ser)]);
      od;
      
      ser := List (ser, p -> SubgroupByPcgs (G, p));
      Add (ser, TrivialSubgroup (G));
      return ser;
   end);
   

###################################################################################
##
#M  CompositionSeriesUnderAction (<act>, <grp>)
##
InstallMethod (CompositionSeriesUnderAction, "for solvable group", 
   true,
   [IsListOrCollection, IsGroup and IsSolvableGroup], 0,
   function (act, G)
   
      local gens, pcgs, inds, elabser, i, ser;
      
      if IsGroup (act) then
         act := ShallowCopy (GeneratorsOfGroup (act));
      fi;
      
      for i in [1..Length (act)] do
          if FamilyObj (act[i]) = FamilyObj (One(G)) then
             act[i] := ConjugatorAutomorphism (G, act[i]);
          fi;
      od;
      
      pcgs := PcgsElementaryAbelianSeries (G);
      if pcgs = fail then
         TryNextMethod();
      fi;

#      InvariantElementaryAbelianSeries with four arguments seems to be buggy
#      elabser := List (InvariantElementaryAbelianSeries (G, act, TrivialSubgroup (G), true),
#         S -> InducedPcgs (pcgs, S));
      elabser := List (InvariantElementaryAbelianSeries (G, act),
         S -> InducedPcgs (pcgs, S));

      ser := [];
      for i in [1..Length (elabser)-1] do
         Append (ser, 
            PcgsCompositionSeriesElAbModuloPcgsUnderAction (
               act, elabser[i] mod elabser[i+1]));
         Unbind (ser[Length (ser)]);
      od;
      
      ser := List (ser, p -> SubgroupByPcgs (G, p));
      Add (ser, TrivialSubgroup (G));
      return ser;
   end);
   

###################################################################################
##
#M  CompositionSeriesUnderAction (<act>, <grp>)
##
RedispatchOnCondition (CompositionSeriesUnderAction,    
   true,
   [IsListOrCollection, IsGroup], 
   [, IsFinite and IsSolvableGroup], # no conditions on first argument
   0);


###################################################################################
##
#F  PcgsElementaryAbelianSeriesFromGenericPcgs
##
InstallGlobalFunction ("PcgsElementaryAbelianSeriesFromGenericPcgs",
   function (pcgs)
   
      local ro, p, new, i, nsteps, j, k,  n, d, 
         npcgs, dpcgs, der, depths, x, m;
      
      if IsPcgsElementaryAbelianSeries (pcgs) then
         return pcgs;
      fi;
      
      ro := RelativeOrders( pcgs );
      
      i := 1;
      nsteps := [1];
      
      while i <= Length (pcgs) do      
      
         p := ro[i];
         n := DepthOfPcElement (pcgs, pcgs[i]^p);
         j := i + 1;
         
         while j < n do
         
            if ro[j] = p then
               d := DepthOfPcElement (pcgs, pcgs[j]^p);
            
               if d < n then
                  n := d;
               fi;
            
               d := Minimum (List ([i..j-1], k ->
                  DepthOfPcElement (pcgs, Comm(pcgs[j], pcgs[k]))));
               
               if d < n then
                  n := d;
               fi;
               
               j := j + 1;

            else
               n := j;
            fi;
         od;
         
         # now find smallest normal subgroup of the series containing 
         # the previously computed group
         j := 1;
         while i < n and j < n do
            k := n;
            while i < n and k <= Length (pcgs) do
               d := DepthOfPcElement (pcgs, Comm(pcgs[k], pcgs[j]));
               if d < n then
                  n := d;
               fi;
               k := k + 1;
            od;
            j := j + 1;
         od;
         
         if n < i then 
            Error ("internal error!");
         elif n = i then # no abelian normal section found - change pcgs
            Info (InfoPcGroup, 2, "changing pcgs");
            npcgs := InducedPcgsByPcSequenceNC (pcgs, pcgs{[i..Length (pcgs)]});
            der := DerivedSubgroup (GroupOfPcgs (npcgs));
            dpcgs := InducedPcgs (pcgs, der);
            m := npcgs mod dpcgs;
            dpcgs := List (dpcgs);
            depths := List (dpcgs, x -> DepthOfPcElement (pcgs, x));
            for x in Reversed (m) do
               AddPcElementToPcSequence (pcgs, dpcgs, depths, x^p);
            od;
            dpcgs := CanonicalPcgs (
               InducedPcgsByPcSequenceNC (pcgs, dpcgs));
            m := npcgs mod dpcgs;
            pcgs := PcgsByPcSequenceNC (FamilyObj (pcgs[1]), 
               Concatenation (pcgs{[1..i-1]}, m, dpcgs));
            ro := Concatenation (ro{[1..i-1]}, RelativeOrders (m), RelativeOrders (dpcgs));
            SetRelativeOrders (pcgs, ro );
            Info (InfoPcGroup, 2, "changing pcgs from ",i," ",pcgs);
            n := n + Length (m);
         else
            Info (InfoPcGroup, 2, "normal step found at ",n);
         fi;
         Add (nsteps, n);
         i := n;
      od;

      SetIsPcgsElementaryAbelianSeries (pcgs, true);
      SetIndicesEANormalSteps (pcgs, nsteps);
      return pcgs;
   end);


###################################################################################
##
#M  PcgsElementaryAbelianSeries
##
InstallMethod (PcgsElementaryAbelianSeries, "CRISP method for pc group", 
   true,
   [IsPcGroup and IsFinite],
   1, # this makes the priority higher than the (slow) library method which uses SpecialPcgs
   function (G)
      local pcgs;
      pcgs := Pcgs (G);
      if not IsPrimeOrdersPcgs (pcgs) then
	     TryNextMethod();
      fi;
      return PcgsElementaryAbelianSeriesFromGenericPcgs (pcgs);
   end);


###################################################################################
##
#M  PcgsElementaryAbelianSeries
##
InstallMethod (PcgsElementaryAbelianSeries, "for pc group with parent group", true,
   [IsPcGroup and IsFinite and HasParent], 
   1, # this makes the priority higher than the (slow) library method which uses SpecialPcgs
   function (G)
      local P, pcgs, ppcgs, depths, pinds, inds, i, j;
      
      P := Parent (G);
      if HasPcgsElementaryAbelianSeries (P) then
         ppcgs := PcgsElementaryAbelianSeries (P);
         pcgs := CanonicalPcgs (InducedPcgs (ppcgs, G));
         # now find an elementary abelian series
         depths := List (pcgs, x -> DepthOfPcElement (ppcgs, x));
         pinds := IndicesEANormalSteps (ppcgs);
         inds := [];
         i := 1;
         for j in [1..Length(depths)] do
            if depths[j] >= pinds[i] then
               Add (inds, j);
               repeat
                  i := i + 1;
               until depths[j] < pinds[i];
            fi;
         od;
         Add (inds, Length (pcgs)+1);
         SetIsPcgsElementaryAbelianSeries (pcgs, true);
         SetIndicesEANormalSteps (pcgs, inds);
         return pcgs;
      else
         TryNextMethod();
      fi;
   end);
   

###################################################################################
##
#M  PcgsElementaryAbelianSeries
##
InstallMethod (PcgsElementaryAbelianSeries, "generic method", true,
   [IsGroup], 0, 
   function (G) 
      if not IsSolvable (G) then
         Error ("The group <G> must be solvable");
      elif IsPrimeOrdersPcgs (Pcgs(G)) then
         return PcgsElementaryAbelianSeriesFromGenericPcgs (Pcgs(G));
      else
         TryNextMethod();
      fi;
   end);


###################################################################################
##
#M  PcgsElementaryAbelianSeries
##
InstallMethod (PcgsElementaryAbelianSeries, "for group with parent group", true,
   [IsGroup and HasParent], 0, 
   function (G)
      local P, pcgs, ppcgs, pinds, depths, inds, i, j;
      
      P := Parent (G);
      if HasPcgsElementaryAbelianSeries (P) then
         ppcgs := PcgsElementaryAbelianSeries (P);
         pcgs := CanonicalPcgs (InducedPcgs (ppcgs, G));

         depths := List (pcgs, x -> DepthOfPcElement (ppcgs, x));
         pinds := IndicesEANormalSteps (ppcgs);
         inds := [];
         i := 1;
         for j in [1..Length(depths)] do
            if depths[j] >= pinds[i] then
               Add (inds, j);
               repeat
                  i := i + 1;
               until depths[j] < pinds[i];
            fi;
         od;
         Add (inds, Length (pcgs)+1);
         SetIsPcgsElementaryAbelianSeries (pcgs, true);
         SetIndicesEANormalSteps (pcgs, inds);
         return pcgs;
      else
         TryNextMethod();
      fi;
   end);

   
#############################################################################
##
#M  SiftedPcElementWrtPcSequence (<pcgs>, <seq>, <depths>, <x>)
##
##  sifts an element x through a list seq of elements resembling a Pcgs,
##  reducing x if it has the same depth as an element in seq
##
InstallMethod (SiftedPcElementWrtPcSequence, "generic method",
   function (fpcgs, fseq, fdepths, fx) return IsIdenticalObj (fpcgs, fseq) and 
      IsIdenticalObj (fseq, CollectionsFamily (fx));
   end,
   [IsPcgs, IsListOrCollection, IsList, IsMultiplicativeElementWithInverse], 0, 
   function (pcgs, seq, depths,  x)

   local d, pos;
      
   d := DepthOfPcElement (pcgs, x);
   pos := PositionSorted (depths, d);
   
   while pos <= Length (depths) and depths[pos] = d do
      x := ReducedPcElement (pcgs, x, seq[pos]);
      d := DepthOfPcElement (pcgs, x);
      pos := PositionSorted (depths, d);
   od;
   
   return x;
end);


#############################################################################
##
#M  SiftedPcElementWrtPcSequence (<pcgs>, <seq>, <depths>, <x>)
##
InstallMethod (SiftedPcElementWrtPcSequence, "method for an empty collection",
   function (a,b,c, d) return 
      IsIdenticalObj (a, CollectionsFamily (d));
   end,
   [IsPcgs, IsListOrCollection and IsEmpty, IsList, IsMultiplicativeElementWithInverse], 
   0, 
   function (pcgs, seq, depths, x)
      return x;
   end);
   
   
#############################################################################
##
#M  AddPcElementToPcSequence (<pcgs>, <seq>, <depths>, <x>)
##
InstallMethod (AddPcElementToPcSequence, "generic method",
   function (fpcgs, fseq, fdepths, fx) return IsIdenticalObj (fpcgs, fseq) and 
      IsIdenticalObj (fseq, CollectionsFamily (fx));
   end,
   [IsPcgs, IsListOrCollection, IsList, IsMultiplicativeElementWithInverse], 0, 
   function (pcgs, seq, depths,  x)

   local d, pos, len;
   
   d := DepthOfPcElement (pcgs, x);
   pos := PositionSorted (depths, d);
   len := Length (depths);
   
   while pos <= len and depths[pos] = d do
      x := ReducedPcElement (pcgs, x, seq[pos]);
      d := DepthOfPcElement (pcgs, x);
      pos := PositionSorted (depths, d);
   od;
   
   if d > Length (pcgs) then
      return false;
   fi;
   
   Add (seq, x, pos);
   Add (depths, d, pos);
   return true;
end);


#############################################################################
##
#M  AddPcElementToPcSequence (<pcgs>, <seq>, <depths>, <x>)
##
InstallMethod (AddPcElementToPcSequence, "method for an empty collection",
   function (a,b,d, c) return 
      IsIdenticalObj (a, CollectionsFamily (c));
   end,
   [IsPcgs, IsListOrCollection and IsEmpty, IsList and IsEmpty, IsMultiplicativeElementWithInverse], 
   0, 
   function (pcgs, seq, depths, x)
      local d;
      d := DepthOfPcElement (pcgs, x);
      if d > Length (pcgs) then
         return false;
      fi;
      depths[1] := d;
      seq[1] := x;
      return true;
   end);
   

############################################################################
##
#E
##
