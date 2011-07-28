#############################################################################
##
##  radical.gi                      CRISP                    Burkhard Höfling
##
##  @(#)$Id: radical.gi,v 1.7 2011/05/15 19:17:58 gap Exp $
##
##  Copyright (C) 2000, 2002, 2005 Burkhard Höfling
##
Revision.radical_gi :=
    "@(#)$Id: radical.gi,v 1.7 2011/05/15 19:17:58 gap Exp $";


#############################################################################
##
#F  InvariantSubgroupsCA (act, ser, avoid, cover, pretest, test, data) 
##
##  computes the G-invariant normal subgroups N of ser[1] such that 
##  ser[cover] equals the intersection of N and ser[avoid], N contains 
##  ser[cover] properly, and N belongs to the class described by the functions
##  pretest and test. pretest and test are the functions described in the 
##  manual (see "OneInvariantSubgroupMaxWrtNProperty").
##
InstallGlobalFunction (InvariantSubgroupsCA,
   function (act, ser, avoid, cover, pretest, test, data)

      local j, CC, L, newser, norms, bool, newnorms;
      
      if avoid = 1 then
         return [];
      fi;
      
      norms := InvariantSubgroupsCA (act, ser, avoid-1, cover, 
         pretest, test, data);
      
      bool := pretest (ser[avoid-1], ser[avoid], ser[cover], data);
      if bool <> false then
         if avoid = cover then
            CC := [ser[avoid-1]];
         else
            CC := ComplementsMaximalUnderAction (act, ser, avoid-1,
                  avoid, cover, true);
            Info (InfoLattice, 1, Length (CC), " complements found");
         fi;
         if Length (CC) > 0 then 
            newser := ShallowCopy (ser);
            for L in CC do
               if bool = true or test(L, ser[cover], data) then 
                  # L belongs to class
                  newser[cover-1] := L;
                  for j in [avoid+1..cover-1] do
                     # ake ser a chief series through L
                     newser[j-1] := ClosureGroup (ser[j], L); 
                  od;
                  Add (norms, L);
                  if avoid > 2 then
                     Append (norms, 
                        InvariantSubgroupsCA (act, 
                           newser, avoid-1, cover-1, 
                           pretest, test, data));
                  fi;
               fi;
            od;
         fi;
      fi;
      return norms;
   end);


#############################################################################
##
#O  AllInvariantSubgroupsWithNProperty 
#O                         (<act>, <G>, <pretest>, <test>, <data>) 
##
InstallMethod (AllInvariantSubgroupsWithNProperty, 
   "for solvable group", true, 
   [IsListOrCollection, IsGroup and IsSolvableGroup and IsFinite, 
      IsFunction, IsFunction, IsObject], 
   0,
   function( act, G, pretest, test, data)

      local ser, norms;
      
      if IsTrivial (G) then
         return [G];
      fi;
      
      ser := CompositionSeriesUnderAction (act, G);
      norms := InvariantSubgroupsCA (act, ser, 
            Length (ser), Length (ser), pretest, test, data);
      Add (norms, TrivialSubgroup (G));
      return norms;
   end);


#############################################################################
##
#M  AllInvariantSubgroupsWithNProperty
##
RedispatchOnCondition (AllInvariantSubgroupsWithNProperty, true, 
   [IsListOrCollection, IsGroup, IsFunction, IsFunction, IsObject], 
   [, IsFinite and IsSolvableGroup], # no conditions on other arguments
   0);
   
   
#############################################################################
##
#M  OneInvariantSubgroupMaxWrtNProperty (
#M              <act>, <G>, <pretest>, <test>, <data>) 
##
InstallMethod (OneInvariantSubgroupMaxWrtNProperty, 
   "for solvable group", true, 
   [IsListOrCollection, IsGroup and IsSolvableGroup and IsFinite, 
      IsFunction, IsFunction, IsObject], 
   0,
   function (act, G, pretest, test, data)

      local n, ser, i, j, CC, R, rpos, bool;
      
      if IsTrivial (G) then
         return G;
      fi;

      ser := ShallowCopy (CompositionSeriesUnderAction (act, G));
      n := Length (ser);

      for rpos in [n-1, n-2..1] do
         Info (InfoComplement, 1, "starting step ",n-rpos, " (testing ser)");
         bool := pretest(ser[rpos], ser[rpos+1], ser[rpos+1], data);
         if bool = fail then
            bool := test (ser[rpos], ser[rpos+1], data);
         fi;
         if not bool then
            break;
         fi;
      od;
         
      if bool then # G has passed test
         return G;
      fi;
      
      rpos := rpos + 1;
      
      for i in [rpos-2,rpos-3..1] do
         # ser[rpos] is the property-radical of ser[i+1]
         Info (InfoComplement, 1, "starting step ",n-i+1);
         bool := pretest (ser[i], ser[i+1], ser[rpos], data);
         if bool <> false then
            Info (InfoComplement, 3, "Complementing");
            CC := ComplementsMaximalUnderAction (act, ser, i, i+1, rpos, bool <> true);
   
            Info (InfoComplement, 3, Length (CC), "complements found, ",
               " (bool = ",bool, ")");
            if bool = true then
               if CC = fail then
                  CC := [];
               else
                  CC := [CC];
               fi;
            fi;
            for R in CC do
               if bool = true or test (R, ser[rpos], data) then  # R is the property-radical of i
                  Info (InfoComplement, 3, "modifying series...\n");
                  for j in [i+2..rpos-1] do
                     ser[j-1] := ClosureGroup(ser[j], R); #make ser a chief series through L
                  od;
                  rpos := rpos - 1;
                  ser[rpos] := R;
                  break; # no need to check other groups
               fi;
            od;
         fi;
      od;
      return ser[rpos];
   end);


#############################################################################
##
#M  OneInvariantSubgroupMaxWrtNProperty
##
RedispatchOnCondition (OneInvariantSubgroupMaxWrtNProperty, true, 
   [IsListOrCollection, IsGroup, IsFunction, IsFunction, IsObject], 
   [, IsFinite and IsSolvableGroup], # no conditions on other arguments
   0);
   
   
#############################################################################
##
#M  AllNormalSubgroupsWithNProperty
##
InstallMethod (AllNormalSubgroupsWithNProperty, 
	"via AllInvariantSubgroupsWithNProperty", true,
	[IsGroup, IsFunction, IsFunction, IsObject], 0,
	function (G, pretest, test, data)
		return AllInvariantSubgroupsWithNProperty (G, G, pretest, test, data);
	end);
	
	
#############################################################################
##
#M  OneNormalSubgroupMaxWrtNProperty
##
InstallMethod (OneNormalSubgroupMaxWrtNProperty, 
	"via OneInvariantSubgroupMaxWrtNProperty", true,
	[IsGroup, IsFunction, IsFunction, IsObject], 0,
	function (G, pretest, test, data)
		return OneInvariantSubgroupMaxWrtNProperty (G, G, pretest, test, data);
	end);
	
	
#############################################################################
##
#M  RadicalOp
##
InstallMethod (RadicalOp, "if only in is known", true, 
   [IsGroup and IsFinite and CanEasilyComputePcgs, IsFittingClass], 0,
   function (G, C)
      return OneInvariantSubgroupMaxWrtNProperty (G, G, 
         function (U, V, R, class)
            if SmallestRootInt (Index (U, V)) in Characteristic (class) then
               return fail; # cannot decide
            else
               return false; # never in C
            fi;
         end,
         function (S, R, class)
            return S in class;
         end,
         C);
   end);
 
 
#############################################################################
##
#M  RadicalOp
##
InstallMethod (RadicalOp, "if injector is known", true, 
   [IsGroup and IsFinite and IsSolvableGroup, IsFittingClass and HasInjectorFunction], 2,
   function (G, C)
      return Core (G, Injector (G, C));
   end);
 
 
#############################################################################
##
#M  RadicalOp
##
InstallMethod (RadicalOp, "if radical function is known", true, 
   [IsGroup and IsFinite and IsSolvableGroup, IsFittingClass and HasRadicalFunction], 
   SUM_FLAGS, # high preference
   function (G, C)
      return RadicalFunction (C) (G);
 end);


#############################################################################
##
#M  RadicalOp
##
InstallMethod (RadicalOp, "for Fitting product", true, 
   [IsGroup and IsFinite and IsSolvableGroup, IsFittingProductRep], 0,
   function (G, C)
      local nat;
      nat := NaturalHomomorphismByNormalSubgroup (G, Radical (G, C!.bot));
      return PreImagesSet (nat, Radical (ImagesSource (nat), C!.top));
 end);


#############################################################################
##
#M  RadicalOp
##
InstallMethod (RadicalOp, "for intersection of classes", true, 
   [IsGroup and IsFinite and IsSolvableGroup, IsFittingClass and IsClassByIntersectionRep], 
   function (G, C)
      local D, R, l;
      R := G;
      l := [];
      for D in C!.intersected do
         if HasRadicalFunction (D) then
            R := RadicalFunction (D)(R);
         else
            Add (l, D);
         fi;
      od;
      if Length (l) > 0 then
         # compute a normal subgroup of R which is maximal with respect 
         # to belonging to all classes in l. Since every normal subgroup
         # of the C-Residual of G belongs to l, the C-residual of G 
         # contains the group returned by OneNormalSubgroupMaxWrtNProperty,
         # even though the intersection of the classes in l need not itself
         # be a Fitting class.
         return OneInvariantSubgroupMaxWrtNProperty (G, R, 
            function (U, V, T, data)
               local p;
               p := Factors (Index (U, V))[1];
               if ForAll (data, D -> p in Characteristic (D)) then
                  return fail; # cannot decide
               else
                  return false; # never in 
               fi;
            end,
            function (S, T, data)
               return ForAll (data, D -> S in D);
            end,
            l);
      else
         return R;
      fi;
    end);


#############################################################################
##
#M  RadicalOp
##
InstallMethodByNiceMonomorphismForGroupAndClass (RadicalOp, 
   IsFinite and IsSolvableGroup, IsFittingClass);
   
   
#############################################################################
##
#M  RadicalOp
##
InstallMethodByIsomorphismPcGroupForGroupAndClass (RadicalOp, 
   IsFinite and IsSolvableGroup, IsFittingClass);
   
   
#############################################################################
##
#M  RadicalOp
##
InstallMethod (RadicalOp, "generic method for FittingSetRep", 
   function (G, C) 
      return IsIdenticalObj (CollectionsFamily (G), C); 
   end, 
   [IsGroup and IsFinite and IsSolvableGroup, IsFittingSetRep], 
   0,
   function (G, C)
      if not IsFittingSet (G, C) then
         Error ("<C> must be a Fitting set for <G>");
      fi;
      return OneInvariantSubgroupMaxWrtNProperty (G, G, 
         ReturnFail,
         function (S, R, data)
            return S in data;
         end,
         C);
   end);
   

#############################################################################
##
#M  RadicalOp
##
InstallMethod (RadicalOp, "for FittingSetRep with injector function", 
   function (G, C) 
      return IsIdenticalObj (CollectionsFamily (G), C); 
   end, 
   [IsGroup and IsFinite and IsSolvableGroup, 
      IsFittingSetRep and HasInjectorFunction], 
   0,
   function (G, C)
      if not IsFittingSet (G, C) then
         Error ("<C> must be a Fitting set for <G>");
      fi;
      return Core (G, Injector (G, C));
   end);
   

#############################################################################
##
#M  RadicalOp
##
InstallMethod (RadicalOp, "for FittingSetRep with radical function", 
   function (G, C) 
      return IsIdenticalObj (CollectionsFamily (G), C); 
   end, 
   [IsGroup and IsFinite and IsSolvableGroup, 
      IsFittingSetRep and HasRadicalFunction], 
   SUM_FLAGS, # highly preferable
   function (G, C)
      if not IsFittingSet (G, C) then
         Error ("<C> must be a Fitting set for <G>");
      fi;
      return RadicalFunction (C) (G);
   end);


#############################################################################
##
#M  RadicalOp
##
RedispatchOnCondition (RadicalOp, true, 
   [IsGroup, IsClass], [IsFinite and IsSolvableGroup],
   RankFilter (IsGroup) + RankFilter (IsClass));
   

############################################################################
##
#E
##
