############################################################################
##
##  recognize.gi                 IRREDSOL                 Burkhard Hoefling
##
##  @(#)$Id: recognize.gi,v 1.8 2005/12/21 17:24:15 gap Exp $
##
##  Copyright (C) 2003-2005 by Burkhard Hoefling, 
##  Institut fuer Geometrie, Algebra und Diskrete Mathematik
##  Technische Universitaet Braunschweig, Germany
##


############################################################################
##
#F  IsAvailableIdIrreducibleSolvableMatrixGroup(<G>)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IsAvailableIdIrreducibleSolvableMatrixGroup,
   function (G)
      return IsMatrixGroup(G) and IsFinite (FieldOfMatrixGroup(G))
         and IsSolvable (G)  and IsIrreducibleMatrixGroup (G)
         and IsAvailableIrreducibleSolvableGroupData (
            DegreeOfMatrixGroup (G), Size (TraceField(G)));
   end);


############################################################################
##
#F  IsAvailableIdAbsolutelyIrreducibleSolvableMatrixGroup(<G>)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IsAvailableIdAbsolutelyIrreducibleSolvableMatrixGroup,
   function (G)
      return IsMatrixGroup(G) and IsFinite (FieldOfMatrixGroup(G))
         and IsSolvable (G) and IsAbsolutelyIrreducibleMatrixGroup (G)
         and IsAvailableAbsolutelyIrreducibleSolvableGroupData (
            DegreeOfMatrixGroup (G), Size (TraceField(G)));
   end);


############################################################################
##
#M  FingerprintMatrixGroup(<G>)
##  
InstallMethod (FingerprintMatrixGroup, "for irreducible FFE matrix group", true,
   [IsMatrixGroup and CategoryCollections (IsFFECollColl)], 0,
   function (G)

   local ids, counts, cl, id, pos, rep, i, g, q;
   
   q := Size (TraceField (G));
   rep := RepresentationIsomorphism (G);
   ids := [];
   for cl in ConjugacyClasses(Source (rep)) do
      g := Representative (cl);
      if g <> g^0 then
         id := [Size (cl), Order (g), 
            NumberOfFFPolynomial (CharacteristicPolynomial (ImageElm (rep, g), 1), 
               q), 1];
         pos := PositionSorted (ids, id);
         if not IsBound (ids[pos]) or ids[pos]{[1,2,3]} <> id{[1,2,3]} then
            ids{[pos+1..Length (ids)+1]} := ids{[pos..Length (ids)]};
            ids[pos] := id;
         else
            ids[pos][4] := ids[pos][4] + 1;
         fi;
      fi;
   od;
   return ids;
end);


############################################################################
##
#F  ConjugatingMatIrreducibleOrFail(G, H, F)
##
##  G and H must be irreducible matrix groups over the finite field F
##
##  computes a matrix x such that G^x = H or returns fail if no such x exists
##
InstallGlobalFunction(ConjugatingMatIrreducibleOrFail,
   function (G, H, F)

      local repG, repH, gensG, iso, gensH, autH, moduleG, orb, modules, i, x, a, gens, module;
      
      repG := RepresentationIsomorphism (G);
      repH := RepresentationIsomorphism (H);
      
      gensG := SmallGeneratingSet (Source (repG));
      iso := IsomorphismGroups (Source (repG), Source (repH));
      if iso = fail then
         return fail;
      fi;
      
      gensH := List (gensG, g -> ImageElm (iso, g));
      
      autH := AutomorphismGroup (Source (repH));
      
      moduleG := GModuleByMats (List (gensG, h -> ImageElm (repG, h)), F);
      if not MTX.IsIrreducible (moduleG) then
         Error ("G must be irreducible over F");
      fi;

      orb := [gensH];
      modules := [GModuleByMats (List (gensH, h -> ImageElm (repH, h)), F)];
      if not MTX.IsIrreducible (modules[1]) then
         Error ("panic: image should be irreducible");
      fi;
      
      x := MTX.Isomorphism (moduleG, modules[1]);
      if x <> fail then 
         Info (InfoIrredsol, 1, "conjugating matrix found");
         return x;
      fi;
      
      i := 1;
      while i <= Length (orb) do
         for a in GeneratorsOfGroup (autH) do
            gens := List (orb[i], h -> ImageElm (a, h));
            module := GModuleByMats (List (gens, h -> ImageElm (repH, h)), F);
            if not MTX.IsIrreducible (module) then
               Error ("panic: image should be irreducible");
            fi;
            x := MTX.Isomorphism (moduleG, module);
            if x <> fail then 
               Info (InfoIrredsol, 1, "conjugating matrix found");
               return x;
            fi;
            if ForAll (modules, m -> MTX.Isomorphism (m, module) = fail ) then
               Add (orb, gens);
               Add (modules, module);
            fi;
         od;
         i := i + 1;
      od;
      Info (InfoIrredsol, 1, "group are not conjugate");
      return fail;
   end);


############################################################################
##
#F  ConjugatingMatImprimitiveOrFail(G, H, d, F)
##
##  G and H must be irreducible matrix groups over the finite field F
##  H must be block monomial with block dimension d
##
##  computes a matrix x such that G^x = H or returns fail if no such x exists
##
##  The function works best if d is small. Irreducibility is only requried 
##  if ConjugatingMatIrreducibleOrFail is used
##
InstallGlobalFunction (ConjugatingMatImprimitiveOrFail, function (G, H, d, F)

# H must have minimal block dimension d and must be a block monomial group for that block size

   local n, systemsG, W, hom, r, basis, orb, posbasis, act, i, blocks, 
      permW, permH, sys, permG, gensG, C, Cinv, mat;
   
   n := DegreeOfMatrixGroup (H);
   systemsG := ImprimitivitySystems (G);

   if d = n then
      if Size (G) mod 1024 <> 0 and Size(G) < 100000 then
         return ConjugatingMatIrreducibleOrFail (G, H, F);
      fi;
      hom := NiceMonomorphism (GL(n, Size(F)));
      r := RepresentativeAction (ImagesSource (hom), 
            ImagesSet (hom, G), ImagesSet (hom, H));
      if r <> fail then
         Info (InfoIrredsol, 1, " conjugating matrix found");
         return PreImagesRepresentative (hom, r);
      else
         Info (InfoIrredsol, 1, "groups are not conjugate");
         return fail;
      fi;
   else
      W := WreathProductOfMatrixGroup (GL (d, Size (F)), SymmetricGroup (n/d));
      basis := IdentityMat (n, F);
      orb := Orbit (W, basis[1], OnRight);
      posbasis := List (basis, b -> Position (orb, b));
      Assert (1, not fail in posbasis);
      permW := Group (List (GeneratorsOfGroup (W), g -> Permutation (g, orb, OnRight)));
         
      blocks := [];
      for i in [0,d..n-d] do
         Add (blocks, basis{[i+1..i+d]});
      od;
      act := TransitiveIdentification (Action (H, blocks, OnSubspacesByCanonicalBasis));
         
      permH := Group (List (GeneratorsOfGroup (H), g -> Permutation (g, orb, OnRight)));
      Assert (1, IsSubgroup (permW, permH));
   
      for sys in systemsG do
         if Length (sys.bases[1]) = d 
               and TransitiveIdentification (
                  Action (G, sys.bases, OnSubspacesByCanonicalBasis)) = act then            
            C := Concatenation (sys.bases);
            Cinv := C^-1;
            gensG := List (GeneratorsOfGroup (G), B -> C*B*Cinv);
            permG := Group (List (gensG, g->Permutation (g, orb, OnRight)));
            Assert (1, IsSubgroup (permW, permG));
            r := RepresentativeAction (permW, permG, permH);
            if r <> fail then
               # compute the corresponding matrix
               mat := List (posbasis, k -> orb[k^r]);
               r := Cinv * mat;
               Info (InfoIrredsol, 1, " conjugating matrix found");
               return r;
            fi;
         fi;
      od;
      Info (InfoIrredsol, 1, "groups are not conjugate");
      return fail;
   fi;
end);


############################################################################
##
#F  RecognitionAISMatrixGroup(G, inds, wantmat, wantgroup)
##
##  version of RecognitionIrreducibleSolvableMatrixGroupNC which 
##  only works for absolutely irreducible groups G. This version
##  allows to prescribe a set of absolutely irreducible subgroups
##  to which G is compared. This set is described as a subset <inds> of 
##  IndicesAbsolutelyIrreducibleSolvableMatrixGroups (n, q), where n is the
##  degree of G and q is the order of the trace field of G. if inds is fail,
##  all groups in the IRREDSOL library are considered.
##
##  WARNING: The result may be wrong if G is not among the groups
##  described by <inds>.
##
InstallGlobalFunction (RecognitionAISMatrixGroup,
   function (G, inds, wantmat, wantgroup)
   
      local allinds, n, q, order, info, fppos, fpinfo, elminds, pos, t, tinv, 
         F, H, systems, rep, i, x;
      
      F := TraceField (G);
      n := DegreeOfMatrixGroup (G);
      q := Size (F);
      order := Size (G);
      
      info := rec (); # set up the answer
      
      allinds := inds = fail;
      
      inds := SelectionIrreducibleSolvableMatrixGroups (
         n, q, 1, inds, [order], fail, fail);

      Info (InfoIrredsol, 1, Length (inds), 
               " groups of order ", order, " to compare");            
         
      if Length (inds) = 0 then
         Error ("panic: no group of order ", order, " in the IRREDSOL library");
      elif Length (inds) > 1 then 
         # cut down candidate grops by looking at fingerprints
         if not TryLoadAbsolutelyIrreducibleSolvableGroupFingerprintIndex (n, q) then
            fppos := fail;
         else
            fppos := PositionSet (IRREDSOL_DATA.FP_INDEX[n][q][1], order);
            
            if fppos <> fail then # fingerprint info available
               LoadAbsolutelyIrreducibleSolvableGroupFingerprintData (
                  n, q, IRREDSOL_DATA.FP_INDEX[n][q][2][fppos]);
               
               fpinfo := IRREDSOL_DATA.FP[n][q][fppos];      # fingerprint info

               Info (InfoIrredsol, 1, "computing fingerprint of group");
               
               # which distingushing elements are in G?
               
               elminds := Filtered ([1..Length (fpinfo[1])], i -> 
                  fpinfo[1][i] in FingerprintMatrixGroup (G));
               
               # find relevant info in database

               pos := PositionSet (fpinfo[2], elminds);
               
               if pos = fail then
                  Error ("panic: fingerprint not found in database");
               fi;
               
               if allinds then
                  if not IsSubset (inds, fpinfo[3][pos]) then
                     Error ("panic: fingerprint indices do not match the IRREDSOL library indices");
                  fi;
                  inds := fpinfo[3][pos];
               else
                  inds := Intersection (inds, fpinfo[3][pos]);
               fi;
               
               Info (InfoIrredsol, 1, Length (inds), 
                  " groups in the library have the same fingerprint");            
            fi;
         fi;
      fi;

      if Length (inds) > 1 or wantmat then 
         # rewrite G over smaller field if necc.
         
         Info (InfoIrredsol, 1, "rewriting group over its trace field");
         
         t := ConjugatingMatTraceField (G);
         if t <> One(G) then
            tinv := t^-1;
            H := GroupWithGenerators (List (GeneratorsOfGroup (G), g -> tinv * g * t));
            Assert (1, FieldOfMatrixGroup (H) = F);
            SetFieldOfMatrixGroup (H, F);
            SetTraceField (H, F);
            rep := RepresentationIsomorphism (G);
            SetRepresentationIsomorphism (H, 
                  GroupHomomorphismByFunction (Source (rep), H, 
                     g -> tinv * ImageElm (rep, g)*t, h -> PreImagesRepresentative (rep, t*h*tinv)));
            G := H;
            
            # we need the imprimitivity systems of G later anyway, so we can rule out groups
            # with different minimal block dimensions as well
            
            if Length (inds) > 1 then
               Info (InfoIrredsol, 1, "computing imprimitivity systems of group");
               systems := ImprimitivitySystems (G);
               inds := SelectionIrreducibleSolvableMatrixGroups (
                  DegreeOfMatrixGroup (G), Size (F), 1, inds, [Order(G)], 
                  [MinimalBlockDimensionOfMatrixGroup (G)], fail);
            fi;
            Info (InfoIrredsol, 1, Length (inds), 
               " groups also have the same minimal block dimension");            
         fi;
         
         # find possible groups in the library
                  
         for i in [1..Length(inds)-1] do 
            H := IrreducibleSolvableMatrixGroup (DegreeOfMatrixGroup (G), Size (F), 1, inds[i]);

            if fppos = fail then # compare fingerprints now
               Info (InfoIrredsol, 1, "comparing fingerprints");            
               if FingerprintMatrixGroup (G) <> FingerprintMatrixGroup (H) then
                  Info (InfoIrredsol, 1, "fingerprint different from id ", 
                     IdIrreducibleSolvableMatrixGroup (H));
                  continue;
               fi;
            fi;

            x := ConjugatingMatImprimitiveOrFail (G, H, 
               MinimalBlockDimensionOfMatrixGroup (G), F);
               
            if x = fail then
               Info (InfoIrredsol, 1, "group does not have id ", IdIrreducibleSolvableMatrixGroup (H));
            else
               Assert (1, G^x = H);
               info.id := [DegreeOfMatrixGroup (G), Size (F), 1, inds[i]];
               if wantgroup then
                  info.group := H;
               fi;
               if wantmat then
                  info.mat := t*x;
               fi;
               Info (InfoIrredsol, 1, "group id is ", info.id);
               return info;
            fi;
         od;
      fi;
      
      # we are down to the last group - this must be it
      
      i := inds[Length (inds)];
      info.id := [DegreeOfMatrixGroup (G), Size (F), 1, i];
      Info (InfoIrredsol, 1, "group id is ", info.id);
      if not wantgroup and not wantmat then
         return info;
      fi;
      H := IrreducibleSolvableMatrixGroup (DegreeOfMatrixGroup (G), Size (F), 1, i);
      if wantgroup then
         info.group := H;
      fi;
      if wantmat then
         x := ConjugatingMatImprimitiveOrFail (G, H, 
            MinimalBlockDimensionOfMatrixGroup (G), F);
         if x = fail then
            Error ("panic: group not found in database");
         fi;
         info.mat := t*x;
      fi;
      return info;
      
   end);


   
############################################################################
##
#F  RecognitionIrreducibleSolvableMatrixGroup(G, wantmat, wantgroup)
##
##  Let G be an irreducible solvable matrix group over a finite field. 
##  This function identifies a conjugate H of G group in the library. 
##
##  It returns a record which has the following entries:
##  id:                contains the id of H (and thus of G), 
##                     cf. IdIrreducibleSolvableMatrixGroup
##  mat: (optional)    a matrix x such that G^x = H
##  group: (optional)  the group H
##
##  The entries mat and group are only present if the booleans wantmat and/or
##  wantgroup are true, respectively.
##
##  Currently, wantmat may only be true if G is absolutely irreducible.
##
##  Note that in most cases, the function will be much slower if wantmat
##  is set to true.  
##
InstallGlobalFunction (RecognitionIrreducibleSolvableMatrixGroup, 
   function (G, wantmat, wantgroup)
   
      local info;
      
      # test if G is solvable
   
      if not IsMatrixGroup (G) or not IsFinite (FieldOfMatrixGroup (G)) or not IsSolvableGroup (G) then
         Error ("G must be a solvable matrix group over a finite field");
      fi;

      if not IsBool (wantmat) or not IsBool (wantgroup) then
         Error ("wantmat and wantgroup must be `true' or `false'");
      fi;
      info := RecognitionIrreducibleSolvableMatrixGroupNC (G, wantmat, wantgroup);
      if info = fail then
         Error ("This group is not within the scope of the IRREDSOL library");
      fi;
      return info;
   end);

   
############################################################################
##
#F  RecognitionIrreducibleSolvableMatrixGroupNC(G, wantmat, wantgroup)
##
##  version of RecognitionIrreducibleSolvableMatrixGroup which does not check
##  its arguments and returns fail if G is not within the scope of the 
##  IRREDSOL library
##
InstallGlobalFunction (RecognitionIrreducibleSolvableMatrixGroupNC, 
   function (G, wantmat, wantgroup)

      local moduleG, module, info, newinfo, conjinfo, gens, perm_pow, basis, 
         gensG, repG, repH, H, d, e, q, gal;
      
      # reduce to the absolutely irreducible case
      
      repG := RepresentationIsomorphism (G);
      gensG := List (GeneratorsOfGroup (Source(repG)), x -> ImageElm (repG, x));
      moduleG := GModuleByMats (gensG, FieldOfMatrixGroup (G));
      
      if not MTX.IsIrreducible (moduleG) then
         Error ("G must be irreducible over FieldOfMatrixGroup (G)");
      elif MTX.IsAbsolutelyIrreducible (moduleG) then
         Info (InfoIrredsol, 1, "group is absolutely irreducible");
         info := RecognitionAISMatrixGroup (G, fail, wantmat, wantgroup);
         if info = fail then
            return fail;
         else
            newinfo := rec (id := [DegreeOfMatrixGroup (G), Size (TraceField(G)), 1, info.id[4]]);
            if wantgroup then
               newinfo.group := info.group;
            fi;
            if wantmat then
               newinfo.mat := info.mat;
            fi;
         fi;
      else
         Info (InfoIrredsol, 1, "reducing to the absolutely irreducible case");
         module := GModuleByMats (gensG, GF(Characteristic (G)^MTX.DegreeSplittingField (moduleG)));
         repeat
            basis := MTX.ProperSubmoduleBasis (module);
            module := MTX.InducedActionSubmodule (module, basis);
         until MTX.IsIrreducible (module);
         Assert (1, MTX.IsAbsolutelyIrreducible (module));
         
         # construct absolutely irreducible group
         
         H := Group (MTX.Generators (module));
         SetIsAbsolutelyIrreducibleMatrixGroup (H, true);
         SetIsIrreducibleMatrixGroup (H, true);
         SetIsSolvableGroup (H, true);
         SetSize (H, Size (G));
         e := LogInt (Size (TraceField (H)), Characteristic (H));
         d := DegreeOfMatrixGroup (G)/MTX.Dimension (module);
         Assert (1, e mod d = 0);
         
         # construct representation isomorphism for H
         
         repH := GroupGeneralMappingByImages (Source (repG), H, 
               GeneratorsOfGroup (Source(repG)),
               MTX.Generators (module));
         SetIsGroupHomomorphism (repH, true);
         SetIsBijective (repH, true);
         SetRepresentationIsomorphism (H, repH);
         
         # recognize absolutely irreducible component
         
         info := RecognitionAISMatrixGroup (H, fail, wantmat, false);
         if info = fail then 
            return fail;
         fi;
         
         # translate results back
         
         q := Characteristic(H)^(e/d);
         SetTraceField (G, GF(q));
         Assert (1, q^d = info.id[2]);
         perm_pow := PermCanonicalIndexIrreducibleSolvableMatrixGroup (
               DegreeOfMatrixGroup (G), q, d, info.id[4]);

         newinfo := rec (
            id := [DegreeOfMatrixGroup (G), q, d, info.id[4]^(perm_pow.perm^perm_pow.pow)]);
         if wantgroup then
            newinfo.group := CallFuncList (IrreducibleSolvableMatrixGroup, newinfo.id);
         fi;

         if wantmat then
            Info (InfoIrredsol, 1, "determining conjugating matrix");
            # raising to gal-th power is the galois automorphism which maps H to a conjugate of
            # the absolutely irreducible group which is used to construct the irreducible group
            # we want to find
            gal := q^perm_pow.pow; 
            if gal = 1 then
                gens := List (MTX.Generators(module), mat -> mat^info.mat);
               Info (InfoIrredsol, 1, "already got right Galois conjugate");
            else
               # construct Galois conjugate of module
               
               Info (InfoIrredsol, 1, "computing and recognizing Galois conjugate");
               
               module := GModuleByMats (
                  List (MTX.Generators (module), mat -> List (mat, row -> List (row, x -> x^gal))),
                  MTX.Dimension (module), MTX.Field(module));
                  
               H := Group (MTX.Generators (module));
               SetIsAbsolutelyIrreducibleMatrixGroup (H, true);
               SetIsIrreducibleMatrixGroup (H, true);
               SetIsSolvableGroup (H, true);
               SetSize (H, Size (G));
               
               # construct representation isomorphism for H
               
               repH := GroupGeneralMappingByImages (Source (repG), H, 
                     GeneratorsOfGroup (Source(repG)),
                     MTX.Generators (module));
               SetIsGroupHomomorphism (repH, true);
               SetIsBijective (repH, true);
               SetRepresentationIsomorphism (H, repH);
               
               # recognize absolutely irreducible component
                           
               conjinfo := RecognitionAISMatrixGroup (H, [perm_pow.min], true, false);
               if conjinfo = fail then 
                  Error ("panic: internal error, Galois conjugate isn't in the library");
               elif conjinfo.id <> [info.id[1], info.id[2], 1, perm_pow.min] then
                  Error ("panic: internal error, didn't find correct Galois conjugate");
               fi;
               gens := List (MTX.Generators (module), mat -> mat^conjinfo.mat);
            fi;
             
            basis := CanonicalBasis (AsVectorSpace (GF(q), GF(q^d)));
                 # it is important to use CanonicalBasis here, in order to be sure
                 # that the result is the same as during the construction of
                 # the corresponding irreducible group
            
            # now construct a module over GF(q)
             module := GModuleByMats (
                List (gens, mat -> BlownUpMat (basis, mat)),
                MTX.Dimension (moduleG),
                MTX.Field (moduleG));
             
             newinfo.mat := MTX.Isomorphism (moduleG, module);
               if newinfo.mat = fail then
                  Error ("panic: no conjugating mat found");
               fi;                          
         fi;

      fi;
      Info (InfoIrredsol, 1, "irreducible group id is", newinfo.id);
      return newinfo;
   end);


############################################################################
##
#M  IdIrreducibleSolvableMatrixGroup(<G>)
##
##  see the IRREDSOL manual
##  
InstallMethod (IdIrreducibleSolvableMatrixGroup, 
   "for irreducible solvable matrix group over finite field", true,
   [IsMatrixGroup and CategoryCollections (IsFFECollColl) 
      and IsIrreducibleMatrixGroup and IsSolvableGroup], 0,

   function (G)
      
      local info;
      
      info := RecognitionIrreducibleSolvableMatrixGroupNC (G, false, false);
      if info = fail then
         Error ("group is beyond the scope of the IRREDSOL library");
      else
         return info.id;
      fi;
   end);
   
   
RedispatchOnCondition(IdIrreducibleSolvableMatrixGroup, true,
   [IsMatrixGroup and CategoryCollections (IsFFECollColl)],
   [IsIrreducibleMatrixGroup and IsSolvableGroup], 0);


############################################################################
##
#V  IRREDSOL_DATA.MS_GROUP_INDEX
##
##  translation table for Mark Short's irredsol library
##
IRREDSOL_DATA.MS_GROUP_INDEX :=
[ , 
  [ , [ [ 2, 1 ], [ 1, 1 ] ], [ [ 2, 1 ], [ 1, 1 ], [ 1, 5 ], [ 2, 2 ], [ 1, 
              4 ], [ 1, 3 ], [ 1, 2 ] ],, 
      [ [ 2, 1 ], [ 1, 11 ], [ 2, 2 ], [ 1, 5 ], [ 1, 4 ], [ 2, 3 ], 
          [ 1, 8 ], [ 1, 9 ], [ 2, 4 ], [ 1, 3 ], [ 1, 2 ], [ 1, 10 ], 
          [ 1, 7 ], [ 2, 5 ], [ 1, 14 ], [ 1, 1 ], [ 1, 6 ], [ 1, 13 ], 
          [ 1, 12 ] ],, 
      [ [ 2, 1 ], [ 1, 7 ], [ 1, 10 ], [ 1, 18 ], [ 2, 2 ], [ 1, 8 ], 
          [ 1, 6 ], [ 2, 3 ], [ 1, 14 ], [ 2, 4 ], [ 1, 16 ], [ 1, 4 ], 
          [ 1, 9 ], [ 1, 5 ], [ 2, 5 ], [ 1, 17 ], [ 1, 21 ], [ 1, 22 ], 
          [ 1, 13 ], [ 1, 3 ], [ 1, 2 ], [ 1, 15 ], [ 2, 6 ], [ 1, 12 ], 
          [ 1, 23 ], [ 1, 1 ], [ 1, 20 ], [ 1, 11 ], [ 1, 19 ] ],,,, 
      [ [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 1, 21 ], [ 1, 10 ], [ 2, 4 ], 
          [ 1, 26 ], [ 1, 6 ], [ 2, 5 ], [ 1, 20 ], [ 1, 17 ], [ 2, 6 ], 
          [ 1, 25 ], [ 1, 5 ], [ 1, 7 ], [ 2, 7 ], [ 1, 14 ], [ 2, 8 ], 
          [ 1, 16 ], [ 1, 29 ], [ 2, 9 ], [ 1, 22 ], [ 1, 9 ], [ 1, 8 ], 
          [ 1, 24 ], [ 2, 10 ], [ 1, 13 ], [ 1, 30 ], [ 1, 4 ], [ 1, 18 ], 
          [ 1, 19 ], [ 2, 11 ], [ 1, 23 ], [ 1, 2 ], [ 1, 3 ], [ 1, 12 ], 
          [ 2, 12 ], [ 1, 15 ], [ 1, 28 ], [ 1, 1 ], [ 1, 11 ], [ 1, 27 ] ],, 
      [ [ 1, 26 ], [ 2, 1 ], [ 1, 21 ], [ 1, 23 ], [ 2, 2 ], [ 1, 25 ], 
          [ 1, 27 ], [ 2, 3 ], [ 1, 43 ], [ 1, 18 ], [ 1, 29 ], [ 1, 11 ], 
          [ 2, 4 ], [ 1, 14 ], [ 1, 20 ], [ 1, 22 ], [ 1, 13 ], [ 1, 19 ], 
          [ 1, 30 ], [ 2, 5 ], [ 1, 51 ], [ 1, 50 ], [ 2, 6 ], [ 1, 40 ], 
          [ 1, 38 ], [ 1, 32 ], [ 1, 8 ], [ 1, 9 ], [ 2, 7 ], [ 1, 44 ], 
          [ 1, 17 ], [ 1, 28 ], [ 1, 15 ], [ 1, 12 ], [ 1, 49 ], [ 1, 48 ], 
          [ 2, 8 ], [ 1, 36 ], [ 1, 42 ], [ 1, 5 ], [ 1, 10 ], [ 1, 7 ], 
          [ 1, 6 ], [ 1, 47 ], [ 1, 39 ], [ 1, 35 ], [ 2, 9 ], [ 1, 31 ], 
          [ 1, 16 ], [ 1, 52 ], [ 1, 37 ], [ 1, 3 ], [ 1, 2 ], [ 1, 46 ], 
          [ 2, 10 ], [ 1, 34 ], [ 1, 41 ], [ 1, 1 ], [ 1, 45 ], [ 1, 33 ], 
          [ 1, 24 ], [ 1, 4 ] ] ], 
  [ , [ [ 3, 1 ], [ 1, 1 ] ], [ [ 1, 5 ], [ 3, 1 ], [ 1, 4 ], [ 1, 3 ], 
          [ 1, 2 ], [ 3, 2 ], [ 1, 7 ], [ 1, 1 ], [ 1, 6 ] ],, 
      [ [ 1, 12 ], [ 1, 15 ], [ 1, 16 ], [ 1, 6 ], [ 3, 1 ], [ 1, 3 ], 
          [ 1, 10 ], [ 1, 11 ], [ 1, 9 ], [ 3, 2 ], [ 1, 19 ], [ 1, 4 ], 
          [ 1, 5 ], [ 1, 14 ], [ 1, 13 ], [ 3, 3 ], [ 1, 18 ], [ 1, 8 ], 
          [ 1, 2 ], [ 1, 7 ], [ 1, 17 ], [ 1, 1 ] ] ], 
  [ , [ [ 4, 1 ], [ 2, 3 ], [ 4, 2 ], [ 2, 1 ], [ 1, 5 ], [ 2, 2 ], [ 1, 2 ], 
          [ 1, 3 ], [ 1, 4 ], [ 1, 1 ] ], 
      [ [ 4, 1 ], [ 2, 20 ], [ 4, 2 ], [ 2, 11 ], [ 2, 9 ], [ 2, 8 ], 
          [ 4, 3 ], [ 2, 12 ], [ 2, 16 ], [ 2, 17 ], [ 4, 4 ], [ 1, 73 ], 
          [ 1, 11 ], [ 1, 10 ], [ 2, 4 ], [ 1, 9 ], [ 1, 12 ], [ 1, 34 ], 
          [ 1, 32 ], [ 2, 7 ], [ 2, 6 ], [ 1, 33 ], [ 2, 5 ], [ 2, 10 ], 
          [ 4, 5 ], [ 1, 71 ], [ 2, 18 ], [ 2, 15 ], [ 1, 72 ], [ 2, 24 ], 
          [ 2, 23 ], [ 1, 13 ], [ 1, 14 ], [ 1, 7 ], [ 1, 6 ], [ 2, 3 ], 
          [ 1, 36 ], [ 1, 41 ], [ 2, 2 ], [ 1, 27 ], [ 1, 42 ], [ 1, 26 ], 
          [ 1, 35 ], [ 2, 19 ], [ 2, 14 ], [ 1, 69 ], [ 4, 6 ], [ 1, 70 ], 
          [ 1, 5 ], [ 1, 49 ], [ 1, 38 ], [ 1, 37 ], [ 2, 22 ], [ 2, 25 ], 
          [ 1, 57 ], [ 1, 65 ], [ 2, 26 ], [ 1, 8 ], [ 1, 28 ], [ 1, 39 ], 
          [ 1, 30 ], [ 1, 40 ], [ 1, 29 ], [ 1, 44 ], [ 1, 43 ], [ 1, 21 ], 
          [ 2, 1 ], [ 1, 67 ], [ 1, 68 ], [ 2, 13 ], [ 1, 76 ], [ 1, 3 ], 
          [ 1, 4 ], [ 1, 2 ], [ 1, 31 ], [ 1, 59 ], [ 1, 63 ], [ 1, 64 ], 
          [ 1, 62 ], [ 2, 21 ], [ 1, 61 ], [ 1, 19 ], [ 1, 45 ], [ 1, 24 ], 
          [ 1, 48 ], [ 1, 46 ], [ 1, 47 ], [ 1, 58 ], [ 1, 66 ], [ 1, 75 ], 
          [ 1, 1 ], [ 1, 22 ], [ 1, 23 ], [ 1, 60 ], [ 1, 25 ], [ 1, 54 ], 
          [ 1, 55 ], [ 1, 56 ], [ 1, 74 ], [ 1, 20 ], [ 1, 18 ], [ 1, 52 ], 
          [ 1, 51 ], [ 1, 53 ], [ 1, 17 ], [ 1, 16 ], [ 1, 50 ], [ 1, 15 ] ] ]
    , 
  [ , [ [ 5, 1 ], [ 1, 1 ] ], [ [ 5, 1 ], [ 5, 2 ], [ 1, 11 ], [ 1, 4 ], [ 1, 
              12 ], [ 5, 3 ], [ 1, 3 ], [ 1, 5 ], [ 1, 6 ], [ 5, 4 ], 
          [ 1, 7 ], [ 1, 2 ], [ 1, 8 ], [ 1, 10 ], [ 1, 1 ], [ 1, 9 ] ] ], 
  [ , [ [ 6, 1 ], [ 3, 2 ], [ 3, 4 ], [ 6, 2 ], [ 2, 4 ], [ 2, 3 ], 
          [ 1, 15 ], [ 3, 5 ], [ 2, 5 ], [ 1, 9 ], [ 1, 10 ], [ 6, 3 ], 
          [ 2, 7 ], [ 2, 8 ], [ 2, 2 ], [ 3, 1 ], [ 1, 11 ], [ 2, 11 ], 
          [ 1, 16 ], [ 3, 3 ], [ 2, 1 ], [ 1, 6 ], [ 1, 7 ], [ 2, 6 ], 
          [ 2, 12 ], [ 1, 21 ], [ 1, 20 ], [ 1, 14 ], [ 1, 13 ], [ 1, 8 ], 
          [ 1, 5 ], [ 1, 17 ], [ 1, 19 ], [ 1, 3 ], [ 1, 4 ], [ 1, 2 ], 
          [ 2, 10 ], [ 1, 12 ], [ 1, 1 ], [ 1, 18 ] ] ], 
  [ , [ [ 7, 1 ], [ 1, 1 ] ] ] ];

MakeImmutable (IRREDSOL_DATA.MS_GROUP_INDEX);


############################################################################
##
#F  IdIrreducibleSolvableMatrixGroupIndexMS(<n>, <p>, <k>)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IdIrreducibleSolvableMatrixGroupIndexMS,
   function (n, p, k)
      if IsInt (n) and n > 1 and IsPosInt (p) and IsPrimeInt (p) 
            and IsPosInt (k) then
         if IsBound (IRREDSOL_DATA.MS_GROUP_INDEX[n]) then
            if IsBound (IRREDSOL_DATA.MS_GROUP_INDEX[n][p]) then
               if IsBound (IRREDSOL_DATA.MS_GROUP_INDEX[n][p][k]) then
                  return Concatenation ([n, p], IRREDSOL_DATA.MS_GROUP_INDEX[n][p][k]);
               else
                  Error ("k is out of range");
               fi;
            else
               Error ("p is out of range");
            fi;
         else
            Error ("n is out of range");
         fi;   
      else
         Error ("n, p, k must be integers, n > 1, and p must be a prime");
      fi;
   end);


############################################################################
##
#F  IndexMSIdIrreducibleSolvableMatrixGroup(<n>, <q>, <d>, <k>)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IndexMSIdIrreducibleSolvableMatrixGroup,
   function (n, p, d, k)
      local pos;
      
      if IsInt (n) and n > 1 and IsPosInt (p) and IsPrimeInt (p) 
            and IsPosInt (k) and IsPosInt (d) and n mod d = 0 then
         if IsBound (IRREDSOL_DATA.MS_GROUP_INDEX[n]) then
            if IsBound (IRREDSOL_DATA.MS_GROUP_INDEX[n][p]) then
               pos := Position (IRREDSOL_DATA.MS_GROUP_INDEX[n][p], [d, k]);            
               if pos <> fail then
                  return [n, p, pos];
               else
                  Error ("inadmissible value for k");
               fi;
            else
               Error ("p is out of range");
            fi;
         else
            Error ("n is out of range");
         fi;   
      else
         Error ("n, p, d, k must be integers, n > 1, p must be a prime, and d must divide n");
      fi;
   end);


############################################################################
##
#E
##
