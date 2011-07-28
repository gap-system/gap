#############################################################################
##
##  socle.gi                         CRISP                  Burkhard Höfling
##
##  @(#)$Id: socle.gi,v 1.7 2011/05/15 19:18:02 gap Exp $
##
##  Copyright (C) 2001, 2002, 2005 Burkhard Höfling

##
Revision.socle_gi :=
    "@(#)$Id: socle.gi,v 1.7 2011/05/15 19:18:02 gap Exp $";


#############################################################################
##
#F  SolvableSocleComponentsBySeries (<G>, <ser>) 
##
InstallGlobalFunction (SolvableSocleComponentsBySeries, 

   function (G, ser)
	
	  local n, components, L, i;
      
      components := [];
      n := Length (ser);

      for i in [n-1, n-2..1] do
         Info (InfoComplement, 1, "starting step ",i);
         L := ComplementsMaximalUnderAction (G, ser, i, i+1, n, false);
         if L <> fail then
            Add (components, L);
         fi;
      od;
      return components;
   end);


#############################################################################
##
#M  SolvableSocleComponents (<G>) 
##
InstallMethod (SolvableSocleComponents, 
   "for finite groups", true, 
   [IsGroup and IsFinite], 
   0,
   function( G )
      local F;
      F := FittingSubgroup (G);
      if IsTrivial (F) then
         return [];
      else
         return SolvableSocleComponentsBySeries (G, CompositionSeriesUnderAction (G, F));
      fi;
   end);      


#############################################################################
##
#M  SolvableSocleComponents (<G>) 
##
InstallMethod (SolvableSocleComponents, 
   "for solvable group", true, 
   [IsGroup and IsFinite and CanEasilyComputePcgs], 
   0,
   function( G ) 
      if IsTrivial (G) then
         return [];
      else
         return SolvableSocleComponentsBySeries (G, ChiefSeries (G));
      fi;
   end);


#############################################################################
##
#M  SolvableSocleComponents (<G>) 
##
InstallMethod (SolvableSocleComponents, 
   "for solvable group with known Fitting subgroup", true, 
   [IsGroup and CanEasilyComputePcgs and IsFinite and HasFittingSubgroup], 
   0,
   function( G )
      local F;
      F := FittingSubgroup (G);
      if IsTrivial (F) then
         return [];
      else
         return SolvableSocleComponentsBySeries (G, CompositionSeriesUnderAction (G, F));
      fi;
   end);      


#############################################################################
##
#M  SolvableSocleComponents (<G>) 
##
InstallMethod (SolvableSocleComponents,
   "handled by nice monomorphism",
   true,
   [IsGroup and IsHandledByNiceMonomorphism and IsFinite],
   0,
   function( grp)
      local hom;
      hom := NiceMonomorphism (grp);
      return List (SolvableSocleComponents (NiceObject (grp)),
         L -> PreImagesSet (hom, L));
   end);
   
   
#############################################################################
##
#M  SolvableSocleComponents (<G>) 
##
InstallMethod (SolvableSocleComponents,
   "via IsomorphismPcGroup",
   true,
   [IsGroup and IsSolvableGroup and IsFinite],
   0,
   function( grp)
      local hom;
      if CanEasilyComputePcgs (grp) then
         TryNextMethod();
      fi;
      hom := IsomorphismPcGroup (grp);
      return List (SolvableSocleComponents (ImagesSource (hom)),
         L -> PreImagesSet (hom, L));
   end);
   
   
#############################################################################
##
#M  SolvableSocleComponents (<G>) 
##
RedispatchOnCondition (SolvableSocleComponents, true, 
   [IsGroup], 
   [IsFinite], 0);
   

#############################################################################
##
#M  SocleComponents (<G>) 
##
InstallMethod (SocleComponents, 
   "for solvable group", true, 
   [IsGroup and IsSolvableGroup and IsFinite], 0,
   SolvableSocleComponents);
   
   
#############################################################################
##
#M  SocleComponents (<G>) 
##
RedispatchOnCondition (SocleComponents, true, 
   [IsGroup], 
   [IsFinite and IsSolvableGroup], 0);
   
   

#############################################################################
##
#M  SocleComponents (<G>) 
##
InstallMethod (SolvableSocleComponents,
   "via IsomorphismPcGroup",
   true,
   [IsGroup and IsSolvableGroup and IsFinite],
   0,
   function( grp)
      local hom;
      if CanEasilyComputePcgs (grp) then
         TryNextMethod();
      fi;
      hom := IsomorphismPcGroup (grp);
      return List (SocleComponents (ImagesSource (hom)),
         L -> PreImagesSet (hom, L));
   end);
   
   
#############################################################################
##
#M  SocleComponents (<G>) 
##
InstallMethod (SocleComponents,
   "handled by nice monomorphism",
   true,
   [IsGroup and IsHandledByNiceMonomorphism and IsFinite],
   0,
   function( grp)
      local hom;
      hom := NiceMonomorphism (grp);
      return List (SocleComponents (NiceObject (grp)),
         L -> PreImagesSet (hom, L));
   end);
   
   
#############################################################################
##
#M  PSocleComponentsOp (<G>, <p>) 
##
InstallMethod (PSocleComponentsOp, 
   "for finite group", true, 
   [IsGroup and IsFinite, IsPosInt], 
   0,
   function( G, p ) 
      local P;
      P := PCore (G, p);
      if IsTrivial (P) then
         return [];
      else
         return SolvableSocleComponentsBySeries (G, 
            CompositionSeriesUnderAction (G, P));
      fi;
   end);


#############################################################################
##
#M  PSocleComponentsOp (<G>, <p>) 
##
InstallMethod (PSocleComponentsOp, 
   "for finite group with SolvableSocleComponents", true, 
   [IsGroup and IsFinite and HasSolvableSocleComponents, 
      IsPosInt], 
   0,
   function( G, p ) 
      return Filtered (SolvableSocleComponents (G), L -> PrimePGroup (L) = p);
   end);


#############################################################################
##
#M  PSocleComponentsOp (<G>, <p>) 
##
RedispatchOnCondition (PSocleComponentsOp, true, 
   [IsGroup, IsPosInt], 
   [IsFinite, ], 0);
   
   
#############################################################################
##
#M  PSocleComponentsOp (<G>, <p>) 
##
InstallMethod (PSocleComponentsOp,
   "via IsomorphismPcGroup",
   true,
   [IsGroup and IsSolvableGroup and IsFinite, IsPosInt],
   0,
   function( grp, p)
      local hom;
      if CanEasilyComputePcgs (grp) then
         TryNextMethod();
      fi;
      hom := IsomorphismPcGroup (grp);
      return List (PSocleComponentsOp (ImagesSource (hom), p),
         L -> PreImagesSet (hom, L));
   end);
   
   
#############################################################################
##
#M  PSocleComponentsOp (<G>, <p>) 
##
InstallMethod (PSocleComponentsOp,
   "handled by nice monomorphism",
   true,
   [IsGroup and IsHandledByNiceMonomorphism and IsFinite, 
      IsPosInt],
   0,
   function( grp, p )
      local hom;
      hom := NiceMonomorphism (grp);
      return List (PSocleComponentsOp (NiceObject (grp), p),
         L -> PreImagesSet (hom, L));
   end);
   
   
#############################################################################
##
#M  SolvableSocle (<G>) 
##
InstallMethod (SolvableSocle, 
   "for solvable group", true, 
   [IsGroup and CanEasilyComputePcgs and IsFinite], 
   0,
   function( G )

      local i, pcgs, pcgssoc, socdepths, L, x, ser, n;
      
      if IsTrivial (G) then
         return G;
      fi;
      
      pcgs := ParentPcgs (Pcgs (G));
      
      pcgssoc := [];
      socdepths := [];
      
      for L in SocleComponents (G) do
         for x in Pcgs (L) do
            if not AddPcElementToPcSequence (pcgs, pcgssoc, socdepths, x) then
               Error ("Internal error in method for `Socle' for soluble gorups");
            fi;
         od;
      od;
      pcgssoc := InducedPcgsByPcSequenceNC (pcgs, pcgssoc);
      return GroupOfPcgs (pcgssoc);
   end);



#############################################################################
##
#M  SolvableSocle (<G>) 
##
InstallMethod (SolvableSocle, 
   "for finite group", true, 
   [IsGroup and IsFinite], 
   0,
   function( G )

      local S, L;
      
      S := TrivialSubgroup (G);
      for L in SolvableSocleComponents (G) do
         S := ClosureGroup (S, L);
      od;
      return S;
   end);



#############################################################################
##
#M  SolvableSocle (<G>) 
##
InstallMethod (SolvableSocle,
   "handled by nice monomorphism",
   true,
   [IsGroup and IsHandledByNiceMonomorphism and IsFinite],
   0,
   function( grp )
      return PreImagesSet (NiceMonomorphism (grp), SolvableSocle (NiceObject (grp)));
   end);
   
   
#############################################################################
##
#M  SolvableSocle (<G>) 
##
InstallMethod (SolvableSocle,
   "via IsomorphismPcGroup",
   true,
   [IsGroup and IsSolvableGroup and IsFinite],
   0,
   function( grp )
      local hom;
      if CanEasilyComputePcgs (grp) then
         TryNextMethod();
      fi;
      hom := IsomorphismPcGroup (grp);
      return PreImagesSet (hom, SolvableSocle (ImagesSource (hom)));
   end);
   
   
#############################################################################
##
#M  SolvableSocle (<G>) 
##
RedispatchOnCondition (SolvableSocle, true, 
   [IsGroup], 
   [IsFinite], 0);
   
   
#############################################################################
##
#M  Socle (<G>) 
##
InstallMethod (Socle, "for finite soluble group, via SolvableSocle", true,
   [IsGroup and IsSolvableGroup and IsFinite],
   0,
   function( grp )
      return SolvableSocle (grp);
   end);
   
   
#############################################################################
##
#M  Socle (<G>) 
##
RedispatchOnCondition (Socle, true, 
   [IsGroup], 
   [IsFinite and IsSolvableGroup], 0);
   
   
#############################################################################
##
#M  PSocleOp (<G>, <p>) 
##
InstallMethod (PSocleOp, 
   "for pcgs computable group", true, 
   [IsGroup and CanEasilyComputePcgs and IsFinite, IsPosInt], 
   0,
   function( G, p )

      local i, pcgs, pcgssoc, socdepths, L, x, ser, n;
      
      if IsTrivial (G) then
         return G;
      fi;
      
      pcgs := ParentPcgs (Pcgs (G));
      
      pcgssoc := [];
      socdepths := [];
      
      for L in PSocleComponents (G, p) do
         for x in Pcgs (L) do
            if not AddPcElementToPcSequence (pcgs, pcgssoc, socdepths, x) then
               Error ("Internal error in method for `Socle' for soluble gorups");
            fi;
         od;
      od;
      pcgssoc := InducedPcgsByPcSequenceNC (pcgs, pcgssoc);
      return GroupOfPcgs (pcgssoc);
   end);


#############################################################################
##
#M  PSocleOp (<G>, <p>) 
##
InstallMethod (PSocleOp, 
   "for finite group", true, 
   [IsGroup and IsFinite, IsPosInt], 
   0,
   function( G, p )

      local S, L;
      
      S := TrivialSubgroup (G);
      
      for L in PSocleComponents (G, p) do
         S := ClosureGroup (S, L);
      od;
       return S;
   end);


#############################################################################
##
#M  PSocleOp (<G>, <p>) 
##
InstallMethod (PSocleOp,
   "handled by nice monomorphism",
   true,
   [IsGroup and IsHandledByNiceMonomorphism and IsFinite,
      IsPosInt],
   0,
   function( grp, p )
      local hom;
      return PreImagesSet (NiceMonomorphism (grp), PSocle (NiceObject (grp), p));
   end);
   
   
#############################################################################
##
#M  PSocleOp (<G>, <p>) 
##
InstallMethod (PSocleOp,
   "handled by nice monomorphism",
   true,
   [IsGroup and IsSolvableGroup and IsFinite,
      IsPosInt],
   0,
   function( grp, p )
      local hom;
      if CanEasilyComputePcgs (grp) then
         TryNextMethod();
      fi;
      hom := IsomorphismPcGroup (grp);
      return PreImagesSet (hom, PSocle (ImagesSource (hom), p));
   end);
   
   
#############################################################################
##
#M  PSocleOp (<G>, <p>) 
##
RedispatchOnCondition (PSocleOp, true, 
   [IsGroup, IsPosInt], 
   [IsFinite, ], 0);
   
   
#############################################################################
##
#M  AbelianMinimalNormalSubgroups (<G>) 
##

InstallMethod (AbelianMinimalNormalSubgroups, 
	"complements of chief factors, for finite groups",
    true, [IsGroup and CanEasilyComputePcgs and IsFinite], 0,	
	function (G)

    local norms, k;

    norms := AllInvariantSubgroupsWithNProperty (G, G,
       function (U, V, R, data)
          return IsTrivial(R);
       end,
       ReturnFail,
       []);

    # remove trivial subgroup - in the current implementation, this is always
    # the last group in the list, but better check...
    k := Length (norms);
    while not IsTrivial (norms[k]) do
       k := k - 1;
    od;
    Remove (norms, k);
    return norms;
end);


#############################################################################
##
#M  AbelianMinimalNormalSubgroups (<G>) 
##

InstallMethod (AbelianMinimalNormalSubgroups, 
	"complements of chief factors, for finite groups",
    true, [IsGroup and CanEasilyComputePcgs and HasFittingSubgroup and IsFinite], 0,	
	function (G)

    local norms, k;

    norms := AllInvariantSubgroupsWithNProperty (G, FittingSubgroup (G),
       function (U, V, R, data)
          return IsTrivial(R);
       end,
       ReturnFail,
       []);

    # remove trivial subgroup - in the current implementation, this is always
    # the last group in the list, but better check...
    k := Length (norms);
    while not IsTrivial (norms[k]) do
       k := k - 1;
    od;
    Remove (norms, k);
    return norms;
end);


#############################################################################
##
#M  AbelianMinimalNormalSubgroups (<G>) 
##

InstallMethod (AbelianMinimalNormalSubgroups, 
	"complements of chief factors, for finite groups",
    true, [IsGroup and IsFinite], 0,	
	function (G)

    local norms, k;

    norms := AllInvariantSubgroupsWithNProperty (G, FittingSubgroup (G),
       function (U, V, R, data)
          return IsTrivial(R);
       end,
       ReturnFail,
       []);

    # remove trivial subgroup - in the current implementation, this is always
    # the last group in the list, but better check...
    k := Length (norms);
    while not IsTrivial (norms[k]) do
       k := k - 1;
    od;
    Remove (norms, k);
    return norms;
end);


#############################################################################
##
#M  AbelianMinimalNormalSubgroups (<G>) 
##
RedispatchOnCondition (AbelianMinimalNormalSubgroups, true, 
   [IsGroup], 
   [IsFinite], 0);


#############################################################################
##
#M  AbelianMinimalNormalSubgroups (<G>) 
##
InstallMethod (AbelianMinimalNormalSubgroups,
   "handled by nice monomorphism",
   true,
   [IsGroup and IsHandledByNiceMonomorphism and IsFinite],
   0,
   function( grp )
      local hom;
      hom := NiceMonomorphism (grp);
      return List (AbelianMinimalNormalSubgroups (NiceObject (grp)), 
      	N -> PreImagesSet (hom, N));
   end);
   
   
#############################################################################
##
#M  AbelianMinimalNormalSubgroups (<G>) 
##
InstallMethod (AbelianMinimalNormalSubgroups,
   "handled by IsomorphismPcGroup",
   true,
   [IsGroup and IsSolvableGroup and IsFinite],
   0,
   function( grp )
      local hom;
      if CanEasilyComputePcgs (grp) then
         TryNextMethod();
      fi;
      hom := IsomorphismPcGroup (grp);
      return List (AbelianMinimalNormalSubgroups (ImagesSource (hom)), 
      	N -> PreImagesSet (hom, N));
   end);
   
   
#############################################################################
##
#M  MinimalNormalSubgroups (<G>) 
##
InstallMethod (MinimalNormalSubgroups, 
	"for solvable groups: use AbelianMinimalNormalSubgroups",
	true, [IsGroup and IsFinite and IsSolvableGroup], 0,
	AbelianMinimalNormalSubgroups);
	
RedispatchOnCondition (MinimalNormalSubgroups, 
	true, [IsGroup], [IsSolvableGroup], 0);


############################################################################
##
#E
##
