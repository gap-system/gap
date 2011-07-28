#############################################################################
##
##  samples.gi                      CRISP                    Burkhard Höfling
##
##  @(#)$Id: samples.gi,v 1.6 2011/05/15 19:18:00 gap Exp $
##
##  Copyright (C) 2000, 2005 Burkhard Höfling
##
Revision.samples_gi :=
    "@(#)$Id: samples.gi,v 1.6 2011/05/15 19:18:00 gap Exp $";


#############################################################################
##  
#V  AllPrimes
##
InstallValue (AllPrimes, Class (x -> IsInt (x) and IsPrimeInt (x)));
SetName (AllPrimes, "<set of all primes>");


#############################################################################
##  
#V  TrivialGroups
##
InstallValue (TrivialGroups, SaturatedFittingFormation ( rec(
   \in := IsTrivial,
   rad := TrivialSubgroup,
   res := G -> G,
   proj := TrivialSubgroup,
   locdef := ReturnFail,
   char := [],
   bound := ReturnTrue
   )));
SetIsSubgroupClosed (TrivialGroups, true);
SetName (TrivialGroups, "<class of all trivial groups>");


#############################################################################
##  
#V  NilpotentGroups
##
InstallValue (NilpotentGroups, SaturatedFittingFormation ( rec(
   \in := IsNilpotentGroup,
   rad := FittingSubgroup,
   res := G -> NormalClosure (G, 
      SubgroupNC (G, NormalGeneratorsOfNilpotentResidual (G))),
   proj := NilpotentProjector,
   locdef := function (G, p) return GeneratorsOfGroup (G); end,
   char := AllPrimes,
   bound := G -> G <> Socle (G)
   )));
SetIsSubgroupClosed (NilpotentGroups, true);
SetName (NilpotentGroups, "<class of all nilpotent groups>");


#############################################################################
##  
#M  NilpotentProjector
##
InstallMethod (NilpotentProjector, "for finite solvable groups", true, 
   [IsFinite and IsGroup and IsSolvableGroup], 0,
   function (G)
      return ProjectorFromExtendedBoundaryFunction (
         G,
         rec (
            dfunc := function (gpcgs, npcgs, p, data)
               if Length (npcgs) > 1 then 
                  return true;
               else
                  return fail;
               fi;
            end,
            cfunc := function (gpcgs, npcgs, p, cent, data)
               return cent > 1;
            end),
         false);
   end);


#############################################################################
##
#M  NilpotentProjector (<grp>)
##
RedispatchOnCondition (NilpotentProjector, true, 
   [IsGroup], [IsFinite and IsSolvableGroup], 0);


#############################################################################
##
#V  SupersolvableGroups
##
InstallValue (SupersolvableGroups, SaturatedFormation ( rec(
   res := SupersolvableResiduum,
   proj := SupersolvableProjector,
   locdef := function (G, p) 
      local gens, res, i, j;
      gens := GeneratorsOfGroup (G);
      res := List (gens, x -> x^(p-1)); 
      for i in [1..Length (gens)] do
         for j in [i+1..Length (gens)] do
            Add (res, Comm(gens[i], gens[j]));
         od;
      od;
      return res;
   end,
   char := AllPrimes,
   bound := G -> not IsPrime (Size (Socle (G)))
   )));
SetIsSubgroupClosed (SupersolvableGroups, true);
SetName (SupersolvableGroups, "<class of all supersolvable groups>");


#############################################################################
##  
#M  SupersolvableProjector (<grp>)
##
InstallMethod (SupersolvableProjector, "for finite solvable groups", true, 
   [IsFinite and IsGroup and IsSolvableGroup], 0,
   function (G)
      return ProjectorFromExtendedBoundaryFunction (
         G,
         rec (
            dfunc := function (gpcgs, npcgs, p, data)
               return Length (npcgs) > 1;
            end),
         false);
   end);


#############################################################################
##
#M  SupersolvableProjector (<grp>)
##
RedispatchOnCondition (SupersolvableProjector, true, 
   [IsGroup], [IsFinite and IsSolvableGroup], 0);


#############################################################################
##
#V  AbelianGroups
##
InstallValue (AbelianGroups, OrdinaryFormation ( rec(
   res := DerivedSubgroup,
   char := AllPrimes
   )));
SetIsSubgroupClosed (AbelianGroups, true);
SetName (AbelianGroups, "<class of all abelian groups>");


#############################################################################
##
#F  AbelianGroupsOfExponent (<exp>)
##
InstallGlobalFunction ("AbelianGroupsOfExponent", function (exp)
   local form;
   if not IsPosInt (exp) then
      Error ("<exp> must be a positive integer");
   fi;
   form := OrdinaryFormation ( rec(
      res := G -> ClosureGroup (DerivedSubgroup (G), 
            List (GeneratorsOfGroup (G), x -> x^exp)),
      char := Set(Factors(exp))
      ));
   SetIsSubgroupClosed (form, true);
   SetName (form, Concatenation (
      "<class of all abelian groups of exponent dividing ",
      String (exp), ">"));
      return form;
end);


#############################################################################
##
#F  PiGroups (<list>)
##
InstallGlobalFunction ("PiGroups", 
   function (pi)
      local class;
      if not IsListOrCollection (pi) then
         Error ("<pi> must be a list or collection or class");
      fi;
      if HasIsEmpty (pi) and IsEmpty (pi) then
         return TrivialGroups; # this also avoids a problem with String
                               # which returns "" for an empty list
      fi;
      class := SaturatedFittingFormation ( rec(
         \in := G -> IsTrivial (G) 
         	or ForAll (Set(Factors (Size(G))), p -> p in pi),
         proj := G -> HallSubgroup (G, Filtered (Set(Factors (Size(G))), p -> p in pi)),
         inj  := G -> HallSubgroup (G, Filtered (Set(Factors (Size(G))), p -> p in pi)),
         locdef := function (G, p) 
            if p in pi then
               return [];
            else
               return fail;
            fi;
         end,
         char := pi,
         bound := G -> not SmallestRootInt (Size(Socle (G))) in pi
         ));
      SetIsSubgroupClosed (class, true);
      
      # the following may cause trouble if there is no String method for pi
      SetName (class, Concatenation (
         "<class of all ",String (pi), "-groups>"));
      return class;
   end);


#############################################################################
##
#F  PGroups (<p>)
##
InstallGlobalFunction ("PGroups", 
   function (p)
      local class;
      if not IsInt (p) or not IsPrimeInt (p) then
         Error ("<p> must be a prime integer");
      fi;
      class := SaturatedFittingFormation ( rec(
         \in := G -> IsTrivial (G) 
         	or SmallestRootInt (Size(G)) = p,
         proj := G -> SylowSubgroup (G, p),
         inj := G -> SylowSubgroup (G, p),
         locdef := function (G, q) 
            if p = q then
               return [];
            else
               return fail;
            fi;
         end,
         char := [p],
         bound := G -> Factors (Size(Socle (G)))[1] <> p
         ));
      SetIsSubgroupClosed (class, true);
      SetName (class, Concatenation (
         "<class of all ",String (p), "-groups"));
      return class;
   end);
  
  
############################################################################
##
#M  HallSubgroupOp (<grp>, <pi>)
##
##  make sure that HallSubgroupOp works for arbitrary solvable groups
##
RedispatchOnCondition(HallSubgroupOp,true,[IsGroup,IsList],
  [IsSolvableGroup and IsFinite,],1);


############################################################################
##
#M  SylowComplementOp (<grp>, <p>)
##
RedispatchOnCondition(SylowComplementOp,true,[IsGroup,IsPosInt],
  [IsSolvableGroup and IsFinite,
  IsPosInt ],1);
  
  
############################################################################
##
#E
##

