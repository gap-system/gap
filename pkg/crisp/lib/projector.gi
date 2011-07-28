#############################################################################
##
##  projector.gi                     CRISP                  Burkhard Höfling
##
##  @(#)$Id: projector.gi,v 1.9 2011/05/15 19:17:57 gap Exp $
##
##  Copyright (C) 2000-2003, 2005, 2011 Burkhard Höfling
##
Revision.projector_gi :=
    "@(#)$Id: projector.gi,v 1.9 2011/05/15 19:17:57 gap Exp $";


#############################################################################
##
#M  CoveringSubgroupOp (<grp>, <class>)
##
InstallMethod (CoveringSubgroupOp, "for Schunck classes: return projector",
   true, 
   [IsGroup, IsSchunckClass], 0,
   function (G, C)
      return Projector (G, C);
 end);


#############################################################################
##
#M  ProjectorOp (<grp>, <class>)
##
InstallMethod (ProjectorOp, "if ProjectorFunction is known", true, 
   [IsGroup, IsSchunckClass and HasProjectorFunction], 
   SUM_FLAGS, # highly preferable
   function (G, C)
      return ProjectorFunction(C) (G);
 end);


#############################################################################
##
#M  ProjectorOp (<grp>, <class>)
##
InstallMethod (ProjectorOp, "compute from LocalDefinitionFunction", true, 
   [IsGroup and IsFinite and CanEasilyComputePcgs, 
      IsSaturatedFormation and HasLocalDefinitionFunction], 
   RankFilter (HasBoundaryFunction), # prefer to method using boundary func
   function (G, C)
      return ProjectorFromExtendedBoundaryFunction (
         G, 
         rec (
            char := Characteristic (C),
            class := C,
            dfunc := DFUNC_FROM_CHARACTERISTIC,
            cfunc := CFUNC_FROM_CHARACTERISTIC,
            kfunc := KFUNC_FROM_LOCAL_DEFINITION, 
            lfunc := function (G, p, data)
               return LocalDefinitionFunction (data.class) (G, p);
            end),            
         false); # we want a projector, not a membership test
   end);


#############################################################################
##
#M  ProjectorOp (<grp>, <class>)
##
InstallMethod (ProjectorOp, "compute from boundary", true, 
   [IsGroup and IsFinite and CanEasilyComputePcgs, 
      IsSchunckClass and HasBoundaryFunction], 
   RankFilter (HasMemberFunction),
   function (G, C)
      return ProjectorFromExtendedBoundaryFunction (
         G, 
         rec (
            cfunc := CFUNC_FROM_CHARACTERISTIC_SCHUNCK,
            char := Characteristic (C),
            class := C,
            bfunc := BFUNC_FROM_TEST_FUNC,
            test := function (G, data) 
               return BoundaryFunction (data.class) (G);
            end),
         false); # we want a projector, not a membership test
   end);


#############################################################################
##
#M  ProjectorOp (<grp>, <class>)
##
InstallMethod (ProjectorOp, "use MemberFunction", true, 
   [IsGroup and IsFinite and CanEasilyComputePcgs, 
      IsSchunckClass and HasMemberFunction], 
   0,
   function (G, C)
      return ProjectorFromExtendedBoundaryFunction (
         G, 
         rec (
            dfunc := DFUNC_FROM_MEMBER_FUNCTION,
            memberf := MemberFunction (C)),
        false); # we want a projector, not a membership test
   end);


#############################################################################
##
#M  ProjectorOp (<grp>, <class>)
##
InstallMethod (ProjectorOp, "use only membership test", true, 
   [IsGroup and IsFinite and CanEasilyComputePcgs, 
      IsSchunckClass], 
   0,
   function (G, C)
      return ProjectorFromExtendedBoundaryFunction (
         G, 
         rec (
            class := C,
            char := Characteristic (C),
            cfunc := CFUNC_FROM_CHARACTERISTIC_SCHUNCK,
            bfunc := BFUNC_FROM_TEST_FUNC,
            test := function (G, data)
               return not G in data.class;
            end),
        false); # we want a projector, not a membership test
   end);


#############################################################################
##
#M  ProjectorOp (<grp>, <class>)
##
InstallMethod (ProjectorOp, "for intersection of group classes", true, 
   [IsGroup and IsFinite and CanEasilyComputePcgs, 
      IsSchunckClass and IsClassByIntersectionRep], 
   0,
   function (G, C)
      local D, data;
      data := rec (locform := [],
         schunck := [],
         others := [],
         char := Characteristic (C),
         cfunc := CFUNC_FROM_CHARACTERISTIC_SCHUNCK);
      
      for D in C!.intersected do
         if HasIsSchunckClass (D) and IsSchunckClass (D) then
            if HasLocalDefinitionFunction (D) then
               Add (data.locform, D);   
            elif HasBoundaryFunction (D) then
               Add (data.schunck, D);
            else
               Add (data.others, D);
            fi;
         else
            Add (data.others, D);
         fi;
      od;
      
      if not IsEmpty (data.locform) then
         data.kfunc := KFUNC_FROM_LOCAL_DEFINITION;
         data.lfunc := function (G, p, data)
            local gens, new;
               gens := [];
               # compute generators of residual of intersection
               # (this is the join of the generators of the
               # residuals of the individual classes
               for D in data.locform do
                  new := LocalDefinitionFunction (D)(G, p);
                  if new = fail then
                     return fail; # empty local definition
                  fi;
                  if IsGroup (new) then
                     new := GeneratorsOfGroup (new);
                  fi;
                  new := Union (gens, new);
               od;
            return gens;
         end;
      fi;
      
      if not IsEmpty (data.others) or not IsEmpty (data.schunck) then
         data.bfunc := BFUNC_FROM_TEST_FUNC;
         data.test := function (G, dat)  
               return ForAny (data.schunck, H -> BoundaryFunction (H)(G))
                  or ForAny (data.others, H -> not G in H);
            end;
      fi;
      
      return ProjectorFromExtendedBoundaryFunction (
         G, data, false); # we want a projector, not a membership test
   end);


#############################################################################
##
#M  ProjectorOp (<grp>, <class>)
##
InstallMethod (ProjectorOp, 
   "for intersection of group classes which is a local formation", true, 
   [IsGroup and IsFinite and CanEasilyComputePcgs, 
      IsSaturatedFormation and IsClassByIntersectionRep], 
   0,
   function (G, C)
      local D, data;
      data := rec (locform := [],
         schunck := [],
         others := [],
         char := Characteristic (C),
         dfunc := DFUNC_FROM_CHARACTERISTIC,
         cfunc := CFUNC_FROM_CHARACTERISTIC);
      
      for D in C!.intersected do
         if HasIsSchunckClass (D) and IsSchunckClass (D) then
            if HasLocalDefinitionFunction (D) then
               Add (data.locform, D);   
            elif HasBoundaryFunction (D) then
               Add (data.schunck, D);
            else
               Add (data.others, D);
            fi;
         else
            Add (data.others, D);
         fi;
      od;
      
      if not IsEmpty (data.locform) then
         data.kfunc := KFUNC_FROM_LOCAL_DEFINITION;
         data.lfunc := function (G, p, data)
            local gens, new;
               gens := [];
               # compute generators of residual of intersection
               # (this is the join of the generators of the
               # residuals of the individual classes
               for D in data.locform do
                  new := LocalDefinitionFunction (D)(G, p);
                  if new = fail then
                     return fail; # empty local definition
                  fi;
                  if IsGroup (new) then
                     new := GeneratorsOfGroup (new);
                  fi;
                  gens := Union (gens, new);
               od;
            return gens;
         end;
      fi;
      
      if not IsEmpty (data.others) or not IsEmpty (data.schunck) then
         data.bfunc := BFUNC_FROM_TEST_FUNC;
         data.test := function (G, dat)  
               return ForAny (data.schunck, H -> BoundaryFunction (H)(G))
                  or ForAny (data.others, H -> not G in H);
            end;
      fi;
      
      return ProjectorFromExtendedBoundaryFunction (
         G, data, false); # we want a projector, not a membership test
   end);


#############################################################################
##
#M  ProjectorOp (<grp>, <class>)
##
InstallMethodByNiceMonomorphismForGroupAndClass (ProjectorOp, 
   IsFinite and IsSolvableGroup, IsSchunckClass);
   
   
#############################################################################
##
#M  ProjectorOp (<grp>, <class>)
##
InstallMethodByIsomorphismPcGroupForGroupAndClass (ProjectorOp, 
   IsFinite and IsSolvableGroup, IsSchunckClass);
   
   
#############################################################################
##
#M  ProjectorOp (<grp>, <class>)
##
RedispatchOnCondition (ProjectorOp, true, 
   [IsGroup, IsGroupClass], [IsFinite and IsSolvableGroup],
   RankFilter (IsGroup) + RankFilter (IsGroupClass));


###################################################################################
##
#F  BFUNC_FROM_TEST_FUNC_FAC (<upcgs>, <cpcgs>, <kpcgs>, <npcgs>, <p>, 
##     <centind>, <data>)
##
InstallGlobalFunction(BFUNC_FROM_TEST_FUNC_FAC, 
   function (upcgs, cpcgs, kpcgs, npcgs, p, centind, data)
      local H, N, cent, x, nat, F, hom;
   
      H := GroupOfPcgs (upcgs);
      hom := NaturalHomomorphismByNormalSubgroupNC (H,
         GroupOfPcgs (DenominatorOfModuloPcgs (npcgs)));
         
      # compute centralizer of npcgs in the group generated by cpcgs
      # in factor group
      N := ImagesSet (hom, GroupOfPcgs (NumeratorOfModuloPcgs (npcgs)));
      cent := Centralizer (ImagesSet (hom, GroupOfPcgs (cpcgs)), N);
         
      # now compute primitive image
      nat := NaturalHomomorphismByNormalSubgroupNC (ImagesSource (hom), cent);
      F := ImagesSource (nat);
      SetIsPrimitiveSolvableGroup (F, true);
      SetSocle (F, ImagesSet (nat, N));
      SetSocleComplement (F, 
         ImagesSet (nat, ImagesSet (hom, GroupOfPcgs (cpcgs))));
      return data.test (F, data);
   end);


###################################################################################
##
#F  BFUNC_FROM_TEST_FUNC_MOD (<upcgs>, <cpcgs>, <kpcgs>, <npcgs>, <p>, 
##     <centind>, <data>)
##
InstallGlobalFunction(BFUNC_FROM_TEST_FUNC_MOD, 
   function (upcgs, cpcgs, kpcgs, npcgs, p, centind, data)
      local H, cent, x, nat, F;
   
      H := GroupOfPcgs (upcgs);
       cent := GroupOfPcgs (cpcgs);
      for x in npcgs do
         cent := CentralizerModulo (cent, 
            GroupOfPcgs (DenominatorOfModuloPcgs (npcgs)), 
            x);
      od;
      
      # compute H/C_<cpcgs>(npcgs), which will be the primitive factor group
      # which either lies in the Schunck class or its boudnary
      
      nat := NaturalHomomorphismByNormalSubgroupNC (H, cent);
      F := ImagesSource (nat);
      SetIsPrimitiveSolvableGroup (F, true);
      SetSocle (F, ImagesSet (nat, GroupOfPcgs (npcgs)));
      SetSocleComplement (F, ImagesSet (nat, GroupOfPcgs (cpcgs)));
      return data.test (F, data);
   end);


###################################################################################
##
#F  KFUNC_FROM_LOCAL_DEFINITION (<upcgs>, <kpcgs>, <npcgs>, <p>, <centind>, <data>)
##
InstallGlobalFunction (KFUNC_FROM_LOCAL_DEFINITION,
   function (upcgs, kpcgs, npcgs, p, cent, data)
      local ldef;
      ldef := data.lfunc (GroupOfPcgs (upcgs), p, data);
      if ldef = fail then 
         return true; # empty local def - in boundary
      elif IsGroup (ldef) then
         ldef := GeneratorsOfGroup (ldef);
      fi;
      return not CentralizesLayer (ldef, npcgs);
   end);
   

###################################################################################
##
#F  DFUNC_FROM_CHARACTERISTIC (<upcgs>, <npcgs>, <p>, <data>)
##
##  this only works if groups in C only have prime divisors in the characteristic
##
InstallGlobalFunction (DFUNC_FROM_CHARACTERISTIC, 
   function (upcgs, npcgs, p, data) 
      if p in data.char then
         return fail;
      else 
         return true; 
      fi;
   end);


###################################################################################
##
#F  DFUNC_FROM_MEMBER_FUNCTION (<upcgs>, <npcgs>, <p>, <data>)
##
##  use a membership function to test if the factor group is in the class
##
InstallGlobalFunction (DFUNC_FROM_MEMBER_FUNCTION, 
   function (upcgs, npcgs, p, data) 
      return not data.memberf (
      	GroupOfPcgs (upcgs)/GroupOfPcgs (DenominatorOfModuloPcgs(npcgs)));
   end);


###################################################################################
##
#F  CFUNC_FROM_CHARACTERISTIC (<upcgs>, <npcgs>, <p>, <centind>, <data>)
##
InstallGlobalFunction (CFUNC_FROM_CHARACTERISTIC, 
   function (upcgs, npcgs, p, centind, data) 
      if centind = 1 then # p in Characteristic has been tested by DFUNC...
         return false; # the primitive group is cyclic of order p
      else
         return fail;
      fi;
   end);


###################################################################################
##
#F  CFUNC_FROM_CHARACTERISTIC_SCHUNCK (<upcgs>, <npcgs>, <p>, <centind>, <data>)
##
InstallGlobalFunction (CFUNC_FROM_CHARACTERISTIC_SCHUNCK, 
   function (upcgs, npcgs, p, centind, data) 
      if centind = 1 and p in data.char then
         return false; # the primitive group is cyclic of order p
      else
         return fail;
      fi;
   end);


###################################################################################
##
#M  ProjectorFromExtendedBoundaryFunction (<grp>, <rec>, <inonly>) 
##
InstallMethod (ProjectorFromExtendedBoundaryFunction, "for pc group",
   [IsPcGroup and IsFinite, IsRecord, IsBool], 0,
   function (grp, r, inonly)
      local pcgs, re;

      if not IsBound (r.dfunc) then
         r.dfunc := ReturnFail;
      fi;
      if not IsBound (r.cfunc) then
         r.cfunc := ReturnFail;
      fi;
      if not IsBound (r.kfunc) then
         r.kfunc := ReturnFail;
      fi;
      if not IsBound (r.bfunc) then
         r.bfunc := ReturnFail;
      fi;

      pcgs := PcgsElementaryAbelianSeries (grp);
      re := PROJECTOR_FROM_BOUNDARY (
         pcgs, r, inonly, true, true);
      if inonly then
         return re;
      else
         return GroupOfPcgs (re);
      fi;
   end);
   
   
###################################################################################
##
#M  ProjectorFromExtendedBoundaryFunction (<grp>, <rec>, <inonly>) 
##
InstallMethod (ProjectorFromExtendedBoundaryFunction, "for solvable groups",
   [IsGroup and IsFinite and IsSolvableGroup, IsRecord, IsBool], 0,
   function (grp, r, inonly)
      local pcgs, re;
      if not IsBound (r.dfunc) then
         r.dfunc := ReturnFail;
      fi;
      if not IsBound (r.cfunc) then
         r.cfunc := ReturnFail;
      fi;
      if not IsBound (r.kfunc) then
         r.kfunc := ReturnFail;
      fi;
      if not IsBound (r.bfunc) then
         r.bfunc := ReturnFail;
      fi;

      pcgs := PcgsElementaryAbelianSeries (grp);
      re := PROJECTOR_FROM_BOUNDARY (
         pcgs, r, inonly, false, false);
      if inonly then
         return re;
      else
         return GroupOfPcgs (re);
      fi;
   end);
   
   
###################################################################################
##
#M  ProjectorFromExtendedBoundaryFunction (<grp>, <rec>, <inonly>) 
##
RedispatchOnCondition (ProjectorFromExtendedBoundaryFunction, 
   true,
   [IsGroup, IsRecord, IsBool], 
   [IsGroup and IsSolvableGroup],
   RankFilter (IsGroup) + RankFilter (IsRecord) + RankFilter (IsBool));
   

###################################################################################
##
#F  PROJECTOR_FROM_BOUNDARY (<gpcgs>, <data>, <inonly>, <hom>, <conv>)
##  
InstallGlobalFunction ("PROJECTOR_FROM_BOUNDARY", 
   function (pcgs, data, inonly, hom, conv)

   local 
      ppcgs,      # pcgs wrt to which all computations are carried out
      grp,        # group in which all computations are carried out
      opcgs,      # image of ppcgs
      elabpcgs,   # elementary abelian series derived from pcgs
      fac,        # images mod el. ab. series
      inds,       # indices of pcgs exhibiting an elementary abelian series
      upcgs,      # pcgs of a projector
      userinds,   # indices of an el. ab. series of upcgs,
                  # as obtained by intersecting with elabpcgs
      diff,       # difference between composition length of projector
                  # of upcgs mod elabpcgs[i+1] and upcgs mod elabpcgs[i]
      userp,      # prime exponents of el ab series of upcgs
      i, j,       # loop variables
      mpcgs,      # modulo pcgs representing a factor of the series in elabpcgs
      ser,        # upcgs-composition series of mpcgs
      npcgs,      # modulo pcgs representing a composition factor of ser
      centind,    # all elements of upcgs {[centind..Length(upcgs)]} centralise npcgs
      centpcgs,   # upcgs {[centind..Length(upcgs)]}
      p,          # exponent of mpcgs and npcgs
       cpcgs,      # pcgs of a complement of npcgs in upcgs
       kpcgs,      # pcgs of a normal complement of npcgs in a suitable normal subgroup
                   # of upcgs
       id,         # a suitable identity matrix
       bool;       # result returned by the boundary function, or false if no complement
           
   if Length (pcgs) = 0 then
      if inonly then
         return true;
      else
         return pcgs;
      fi;
   fi;
   
   if not IsPcgsElementaryAbelianSeries (pcgs) then
      Error ("pcgs must refine an elementary abelian series");
   fi;
   
   inds := IndicesEANormalSteps (pcgs);
   
   if conv or hom then
      grp := PcGroupWithPcgs (pcgs);
   else
      grp := GroupOfPcgs (pcgs);
   fi;
   
   if hom then 
      # compute factor groups modulo subgroups in el. ab. series of pcgs
      fac := [];
      fac[Length (inds)] := grp;
      for j in [Length(inds)-1, Length (inds)-2..2] do
         ppcgs := FamilyPcgs (fac[j+1]);
         fac[j] := PcGroupWithPcgs (
            ppcgs mod InducedPcgsByPcSequenceNC (ppcgs, ppcgs{[inds[j]..Length (ppcgs)]}));
      od;
   else
      if conv then
         ppcgs := FamilyPcgs (grp);
      else
         ppcgs := pcgs;
      fi;
      elabpcgs := List (inds, 
         i -> InducedPcgsByPcSequenceNC (pcgs, pcgs{[i, i+1..Length (pcgs)]}));
      upcgs := pcgs; # set up the projector
      ppcgs := pcgs;
   fi;
   userinds := [1];
   userp := [];
   
   # treat the layers of the elementary abelian series obtained from pcgs
   for j in [1,2..Length (inds) - 1] do
      Info(InfoProjector, 1, "starting step ",j, " of ",Length (inds) - 1);
      
      if hom then
         # translate results from factor group
         grp := fac[j+1];
         ppcgs := FamilyPcgs (grp);
         mpcgs := InducedPcgsByPcSequenceNC (ppcgs, ppcgs{[inds[j]..Length (ppcgs)]});
         if j = 1 then
            upcgs := ppcgs; # projector is whole group
         else
            opcgs := FamilyPcgs (fac[j]);
            upcgs := InducedPcgsByPcSequenceNC (ppcgs,
               Concatenation ( List (upcgs, x -> 
                  PcElementByExponentsNC (ppcgs, [1..inds[j]-1], ExponentsOfPcElement (opcgs, x))),
                  mpcgs));
         fi;
      else
         mpcgs := elabpcgs[j] mod elabpcgs[j+1]; 
      fi;
      
      # we assume that upcgs mod elabpcgs[j] represents a projector
      # of pcgs mod elabpcgs[j]
            
      p := RelativeOrderOfPcElement (ppcgs, mpcgs[1]); # exp. of mpcgs
      
      ser := PcgsCompositionSeriesElAbModuloPcgsUnderAction (
         upcgs{[1,2..userinds[Length(userinds)]-1]}, mpcgs);
         
      Info(InfoProjector, 2, Length (ser)-1, " composition factors");
      
      diff := 0; # assume that the composition length remains the same
      
      # now find a projector of upcgs mod elabpcgs[j+1] - this
      # will be a projector of pcgs mod elabpcgs[j+1] as well
      
      for i in [1..Length (ser) - 1] do
      
         # We want to replace upcgs mod ser[i+1] by one of its
         # projectors. There are two possibilities
         # between which dfunc, cfunc, kfunc, bfunc try to decide:
         # if upcgs mod ser[i+1] is in the Schunck class,
         # it is itself a projector. In this case, we have bool=false
         # eventually. Otherwise the projectors are the maximal subgroups 
         # complementing ser[i] mod ser[i+1] (bool = true).
         # If we want to decide membership 
         # only, we can return false as soon as we know that
         # the projector is a proper subgroup, i.e., as soon as bool
         # becomes true.
         

         npcgs := ser[i] mod ser[i+1];
         
         # try if we can decide with only minimal information
         # for instance by testing if p is in the characteristic of a
         # saturated formation
         
         bool := data.dfunc (upcgs, npcgs, p, data);
         Info (InfoProjector, 3, "dfunc returns ", bool);

         if inonly and bool = true then
            return false; # factor group in boundary 
         fi;
         
         if bool <> false then 
            # if dfunc returns false, we know that upcgs mod ser[i+1] is the projector
            # Otherwise we look for a complement of npcgs = ser[i] mod ser[i+1]
            
            Info(InfoProjector, 2, "complementing factor of size ",p,"^",Length (npcgs));
            centind := Length (userinds);
            
            # find the largest term centpcgs in the el. ab. series 
            # of upcgs centralising npcgs
            
            while centind > 1 and 
               (p = userp[centind-1] or 
                  CentralizesLayer (upcgs{[userinds[centind-1]..userinds[centind]-1]}, npcgs)) do
                     centind := centind - 1;
            od;
                        
            Info (InfoProjector, 3, "centralizing level: ",userinds[centind]);
            
            centpcgs := InducedPcgsByPcSequenceNC (ppcgs, 
                     upcgs{[userinds[centind]..Length (upcgs)]});
            
            # if we haven't reached a decision yet, try with additional information
            # for instance if npcgs is central, we can use the characteristic of the
            # Schunck class
            
            if bool = fail then
               bool := data.cfunc (upcgs, npcgs, p, userinds[centind], data);
               Info (InfoProjector, 3, "cfunc returns ", bool);
               if inonly and bool = true then
                  return false;
               fi;
            fi;
            
            if bool <> false then
               # now find upcgs-invariant complement of npcgs in centpcgs 
               # note that any complement of npcgs in upcgs intersects
               # centpcgs in such a complement, and any upcgs-invariant
               # complement arises in that way (see crisp.dvi)
            
               if centind = Length (userinds) and i = 1 and diff = 0 then 
                  # centind = Length (userinds) means that ser[1] = centpcgs, so that
                  # the complement is trivial
                  kpcgs := ser[i+1];
                  Info(InfoProjector, 3, "trivial normal complement");
               else
                  kpcgs := PcgsComplementsOfCentralModuloPcgsUnderActionNC (
                     List (upcgs{[1,2..userinds[centind]-1]}, 
                        x -> InnerAutomorphismNC (grp, x)), 
                     ppcgs, centpcgs mod ser[i], npcgs, ser[i+1], false);
                  if Length (kpcgs) = 0 then # no complement exists
                     kpcgs := fail;
                     bool := false;
                     Assert (1, p in userp, 
                        "coprime situation but no complement");
                     Info(InfoProjector, 3, "no normal complement found");
                  else
                     Info(InfoProjector, 3, Length (kpcgs)," normal complement(s) found");
                     kpcgs := kpcgs[1]; # we only want one normal complement
                     Assert (1, IsSubgroup (GroupOfPcgs (kpcgs), GroupOfPcgs (ser[i+1])),
                        " complement is not a subgroup");
                     Assert (1, GroupOfPcgs (SumPcgs (ppcgs, kpcgs, ser[i]))
                        = GroupOfPcgs (InducedPcgsByPcSequenceNC (ppcgs, 
                           upcgs{[userinds[centind]..Length (upcgs)]})),
                        "wrong join for normal complement");
                     Assert (1, GroupOfPcgs (NormalIntersectionPcgs (ppcgs, kpcgs, ser[i]))
                        = GroupOfPcgs (ser[i+1]),
                        "wrong intersection for normal complement");
                  fi;
               fi;
               if bool = fail then
                  # we have more information (kpcgs) at hand, so 
                  # try to decide again
                  bool := data.kfunc (upcgs, kpcgs, npcgs, p, 
                     userinds[centind], data);
                  Info (InfoProjector, 3, "kfunc returns ", bool);
                  
                  if inonly and bool = true then
                     return false; # not in Schunck class
                  fi;
               fi;
            fi;
            
            if bool <> false then
               # at this point, we either know whether upcgs mod ser[i+1]
               # is in the Schunck class (bool = false/true), or we have
               # an upcgs-invariant subgroup of centpcgs complementing
               # npcgs
               
               # now find a complement of npcgs in upcgs
               if centind = 1 then 
                  # npcgs is central, so kpcgs is a complement
                  cpcgs := kpcgs;
                  Info(InfoProjector, 3, "central socle");
               else
                  Assert (1, userp[centind-1] <> p, Error ("wrong prime ", p));
                  Info(InfoProjector, 3, "noncentral socle - computing complement");
                  # compute a complement of npcgs from the normal complement
                  # obtained before
                  cpcgs := PcgsComplementOfChiefFactor (ppcgs,
                     upcgs{[1..userinds[centind]-1]}, 
                        userinds[centind-1], centpcgs mod kpcgs, kpcgs);
                  Assert (1, Length (npcgs) + Length (cpcgs) = Length (upcgs),
                     Error("cpcgs does not complement"));
               fi;
      
               if bool = fail then
                  # now we have all information at hand - do the final test
                  Info (InfoProjector, 3, "testing group of size ", 
                     Product (RelativeOrders(upcgs)) / 
                     Product (RelativeOrders (ser[i+1])),
                     " size of socle: ",
                     Product (RelativeOrders (npcgs)),
                     " size of complement: ",
                     Product (RelativeOrders(cpcgs)) / 
                     Product (RelativeOrders (ser[i+1])));
                     
                  bool := data.bfunc (upcgs, cpcgs, kpcgs, npcgs, p, 
                     userinds[centind], data);
                  Info (InfoProjector, 3, "bfunc returns ", bool);
                     
                  if bool = fail then
                     Error ("bfunc must not return fail");
                  fi;
                  
                  if inonly and bool = true then
                     return false;
                  fi;
                  
               fi;
            fi;
         fi;
         
         if bool then # cpcgs mod ser[i+1] is a projector
            upcgs := cpcgs; 
            # note that npcgs centralises ser and that cpcgs together with npcgs
            # generate the same group as upcgs, so that ser is also a
            # cpcgs-composition series of mpcgs
         else
            diff := diff + Length (npcgs); # adjust composition length
         fi;
      od;
      if diff > 0 then # update the elementary abelian series of upcgs
         Add (userp, p);
         Add (userinds, userinds[Length (userinds)]+diff);
      fi;
   od;
   if inonly then # group equals projector, so it belongs to the Schunck class
      return true;
   fi;
   
   if hom or conv then # translate result back to previous pcgs
      upcgs := InducedPcgsByPcSequenceNC (pcgs,
         List (upcgs, x -> 
            PcElementByExponentsNC (pcgs, ExponentsOfPcElement (ppcgs, x))));
   fi;
   return upcgs;
end);


############################################################################
##
#E
##
