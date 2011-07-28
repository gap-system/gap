#############################################################################
##
##  injector.gi                      CRISP                 Burkhard Höfling
##
##  @(#)$Id: injector.gi,v 1.4 2011/05/15 19:17:55 gap Exp $
##
##  Copyright (C) 2000, 2005 Burkhard Höfling
##
Revision.injector_gi :=
    "@(#)$Id: injector.gi,v 1.4 2011/05/15 19:17:55 gap Exp $";


#############################################################################
##
#M  InjectorOp (<grp>, <class>)
##
InstallMethod (InjectorOp, "for pcgs computable groups: use radical", true, 
   [IsGroup and CanEasilyComputePcgs and IsFinite, IsFittingClass], 0,
   function (G, C)
       return InjectorFromRadicalFunction (G, U -> Radical (U, C), true);
   end);
   

#############################################################################
##
#M  InjectorOp (<grp>, <class>
##
InstallMethod (InjectorOp, "injector function is known", true, 
   [IsGroup and IsFinite and IsSolvableGroup, 
      IsFittingClass and HasInjectorFunction], 
   SUM_FLAGS,  # prefer injector function if known
   function (G, C)
      return InjectorFunction(C) (G);
   end);


#############################################################################
##
#M  InjectorOp (<grp>, <class>)
##
InstallMethod (InjectorOp, "for FittingSetRep w/o injector function", 
   function (G, C) return IsIdenticalObj (CollectionsFamily (G), C); end, 
   [IsGroup and IsFinite and IsSolvableGroup, IsFittingSetRep], 0,
   function (G, C)
      if not IsFittingSet (G, C) then
         Error ("<C> must be a Fitting set for <G>");
      fi;
      return InjectorFromRadicalFunction (G, U -> Radical (U, C), false);
   end);
   
   
#############################################################################
##
#M  InjectorOp (<grp>, <class>)
##
InstallMethod (InjectorOp, "for FittingSetRep if injector function is known", 
   function (G, C) 
      return IsIdenticalObj (CollectionsFamily (G), C);
   end, 
   [IsGroup and IsFinite and IsSolvableGroup, 
      IsFittingSetRep and HasInjectorFunction], 
   SUM_FLAGS,  # prefer injector function if known
   function (G, C)
      if not IsFittingSet (G, C) then
         Error ("<C> must be a Fitting set for <G>");
      fi;
      return InjectorFunction(C) (G);
   end);
   

#############################################################################
##
#M  InjectorOp (<grp>, <class>)
##
InstallMethodByNiceMonomorphismForGroupAndClass (InjectorOp, 
   IsFinite and IsSolvableGroup, IsFittingClass);

      
#############################################################################
##
#M  InjectorOp (<grp>, <class>)
##
InstallMethodByIsomorphismPcGroupForGroupAndClass (InjectorOp, 
   IsFinite and IsSolvableGroup, IsFittingClass);

      
#############################################################################
##
#M  InjectorOp (<grp>, <class>)
##
RedispatchOnCondition (InjectorOp, true, 
   [IsGroup, IsClass], [IsFinite and IsSolvableGroup],
   RankFilter (IsGroup) + RankFilter (IsClass));


#############################################################################
##
#F  InjectorFromRadicalFunction (<G>, <radfunc>, <hom>)
##
InstallGlobalFunction (InjectorFromRadicalFunction, 
   function (G, radfunc, hom)
   
      local natQ, I, J, nat, H, N, C, W, i, gens, nilpser;
         
      I := radfunc (G);
      if hom then
         natQ := NaturalHomomorphismByNormalSubgroup (G, I);
         H := Image (natQ);
      else
         H := G;
      fi;
      
      # compute a normal series from I to G with nilpotent factors
      nilpser := [];
      while not IsTrivial (H) do
         Add (nilpser, H);
         H := Residual (H, NilpotentGroups);
      od;
   
      if hom then
         nilpser := Reversed (nilpser);
      else
         nilpser := List (Reversed (nilpser), H -> 
         ClosureGroup (I, H));
      fi;
      
      # treat the nilpotent factors
   
      for i in [2..Length (nilpser)] do
   
         Info (InfoInjector, 1, "starting step ",i-1);
         H := nilpser[i];
   
         # I is an F-injector of H
   
         Info (InfoInjector, 2, "computing normalizer");
   
         if i > 2 then 
            if hom then
               J := ImagesSet (natQ, I);
               nat := NaturalHomomorphismByNormalSubgroup (
                  NormalizerOfPronormalSubgroup (H, J), J);
               N := ImagesSource (nat);
            else
               N := NormalizerOfPronormalSubgroup (H, I);
            fi;
         else # otherwise I is trivial
            N := H;
         fi;
         
         Info (InfoInjector, 3, " normalizer has order ", 
            Size (N));
   
         Info (InfoInjector, 2, "computing Carter subgroup");
         C := NilpotentProjector (N);
         Info (InfoInjector, 3, " carter subgroup has order ", 
            Size (C));
   
         if hom then
            if i > 2 then
               W := PreImagesSet (nat, C);
            else 
               W := C;
            fi;
            W := PreImagesSet (natQ, W);
         else
            W := ClosureGroup (I, C);
         fi;
         Info (InfoInjector, 3, " preimage of carter subgroup has order ", 
            Size (W));
         
         Info (InfoInjector, 2, " computing radical");
   
         # the radical has to be computed in the full group
         I := radfunc (W);
         Info (InfoInjector, 3, " injector has order ", Size (I));
      od;
      return I;
   end);

   
############################################################################
##
#E
##
