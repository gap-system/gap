############################################################################
##
##  recognize.gi                      IRREDSOL                         Burkhard Höfling
##
##  @(#)$Id: recognize.gi,v 1.12 2011/05/18 16:39:14 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
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

    local ids, len, cl, id, pos, rep, i, g, q;
    
    q := Size (TraceField (G));
    rep := RepresentationIsomorphism (G);
    ids := [];
    len := 0;
    for cl in AttributeValueNotSet (ConjugacyClasses, Source (rep)) do
        g := Representative (cl);
        if g <> g^0 then
            id := [Size (cl), Order (g), 
                NumberOfFFPolynomial (CharacteristicPolynomial (ImageElm (rep, g), 1), 
                    q), 1];
            pos := PositionSorted (ids, id);
            if pos > len then
                ids[pos] := id;
                len := len + 1;
            elif ids[pos]{[1,2,3]} <> id{[1,2,3]} then
                CopyListEntries( ids, pos, 1, ids, pos + 1, 1, len - pos + 1 );
                ids[pos] := id;
                len := len + 1;
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
##  computes a record x such that G^x.mat = H and x.iso is an isomorphism
##  from the source of RepresentationIsomorphism (G) to the source of 
##  RepresentationIsomorphism (H). If no such matrix exists, the 
##  function returns fail.
##  this works like the GAP function Morphium but only looks for linear
##  isomorphisms. 
##
InstallGlobalFunction(ConjugatingMatIrreducibleOrFail, function (G, H, F)
    
    local q, isoG, preG, isoH, preH, ccl, cl, ids, id, gens, genspos, imglist, g, i, j, k, len, 
        cost, weight, mingens, mincost, mingenspos, totalcost, pos, d, ind, imgs, hom, count,
        sizes, D, projG, projH, homG, homH, group, S, occ, cpH,
        imglistrep, moduleG, moduleH, dirr, mat;
    
    q := Size (F);
    isoG := RepresentationIsomorphism(G);
    preG := Source (isoG);
    isoH := RepresentationIsomorphism(H);
    preH := Source (isoH);
    ccl := ConjugacyClasses (preG);
    ids := [];
    occ := [];
    len := 0;
    for i in [1..Length (ccl)] do
        cl := ccl[i];
        id := [Size (cl), Order (Representative (cl)), 
            NumberOfFFPolynomial (CharacteristicPolynomial (ImageElm (isoG, Representative (cl))), q)];
        pos := PositionSorted (ids, id);
        if pos > len then
            ids[pos] := id;
            occ[pos] := [i];
            len := len + 1;
        elif ids[pos] <> id then
            CopyListEntries( ids, pos, 1, ids, pos + 1, 1, len - pos + 1 );
            CopyListEntries( occ, pos, 1, occ, pos + 1, 1, len - pos + 1 );
            ids[pos] := id;
            occ[pos] := [i];
            len := len + 1;
        else
            Add (occ[pos], i);
        fi;
    od;
    
    cost := [];
    for i in [2..Length (ids)] do
        cost[i] := ids[i][1]*Length (occ[i]);
    od;
    
    
    gens := ShallowCopy (MinimalGeneratingSet (preG));
    Info (InfoMorph, 1, "MinimalGeneratingSet has ", Length (gens), " generators");
    
    mincost := 1;
    mingenspos := [];
    
    for i in [1..Length (gens)] do
        g := gens[i];
        id := [Size (ConjugacyClass (preG, g)), Order(g), 
            NumberOfFFPolynomial (CharacteristicPolynomial (ImageElm (isoG, g)), q)];
        pos := PositionSorted (ids, id);
        mincost := mincost * cost[pos];
        Add (mingenspos, pos);
    od;
    mingens := gens;

    Info (InfoMorph, 1, "ConjugatingMatIrreducibleOrFail: cost of minimal generating system is ", mincost);
    
    # try to find better generators
    
    if mincost > 100*Size(preG) then 
        weight := [0];
        for i in [2..Length (ids)] do
            weight[i] := weight[i-1] + QuoInt (Size(preG), cost[i]);
        od;
            
        for i in [1..7*Length (MinimalGeneratingSet(preG))] do
            gens := [];
            S := TrivialSubgroup (preG);
            totalcost := 1;
            genspos := [];
            repeat
                if Random ([1..10]) = 1 then
                    g := Random (preG);
                    id := [Size (ConjugacyClass (preG, g)), Order(g), 
                        NumberOfFFPolynomial (CharacteristicPolynomial (ImageElm (isoG, g)), q)];
                    pos := PositionSorted (ids, id);
                else
                    k := Random (0, weight[Length (weight)]);
                    pos := PositionSorted (weight, k);
                    g := Random (ccl[Random (occ[pos])]);
                fi;
                if not g in S then
                    totalcost := totalcost * cost[pos];
                    Add (gens, g);
                    Add (genspos, pos);
                    S := ClosureGroup (S, g);
                    #remove for redundant generators - we need not check g
                    j := 1;
                    repeat
                        while j < Length (gens) and Size (Subgroup (S, gens{Difference ([1..Length (gens)], [j])})) < Size (S) do
                            j := j + 1;
                        od;
                        if j < Length (gens) then
                            totalcost := totalcost/cost[genspos[j]];
                            Remove (gens, j);
                            Remove (genspos, j);
                        fi;
                    until j >= Length (gens);
                    if totalcost > mincost then
                        break;
                    fi;
                fi;
            until Size (S) = Size(preG);
            
            if totalcost < mincost then
                mingens := gens;
                mincost := totalcost;
                mingenspos := genspos;
                Info (InfoMorph, 2, "ConjugatingMatIrreducibleOrFail: found better generating system of cost ", mincost, " after ", i, " steps");
            else
                Info (InfoMorph, 3, "ConjugatingMatIrreducibleOrFail: found generating system of cost ", totalcost);
            fi;
        od;
    fi;
    
    Info (InfoMorph, 1, "ConjugatingMatIrreducibleOrFail: using generating system of cost ", mincost);
    
    ccl := ConjugacyClasses(preH);

    # compute set of possible generator images
    
    imglist := [];
    cpH := [];
    
    SortParallel (mingenspos, mingens, function (i, j) return cost[i] > cost[j]; end);
    
    for i in [1..Length (mingens)] do
        id := ids[mingenspos[i]];
        imglist[i] := [];
        count := Length (occ[mingenspos[i]]);
        for j in [1..Length (ccl)] do
            cl := ccl[j];
            if Size (cl) = id[1] and Order (Representative(cl)) = id[2] then
                if not IsBound (cpH[j]) then
                    cpH[j] := NumberOfFFPolynomial (CharacteristicPolynomial (ImageElm (isoH, Representative(cl))), q);
                fi;
                if cpH[j] = id[3] then
                    if i = 1 then
                        Add (imglist[i], Representative(cl));
                    else
                        Append (imglist[i], AttributeValueNotSet (AsList, cl));
                    fi;
                    count := count - 1;
                    # we assume that repG and repH have the same fingerprint, so that we know how many classes to expect
                    # if this fails, it doesn't matter if we miss some possible images, since the groups 
                    # will be nonisomorphic anyway
                    if count = 0 then 
                        break; 
                    fi;
                fi;
            fi;
        od;
        if count > 0 then
            Info (InfoMorph, 2, "ConjugatingMatIrreducibleOrFail: conjugacy clases don't match - groups cannot be conjugate");
            
            Error("Breakpoint");
            return fail;
        fi;
        Assert (0, i = 1 or Length (imglist[i]) = cost[mingenspos[i]]);
    od;
    
    
    Info (InfoMorph, 2, "image lists have lengths ", List (imglist, Length));
    

    gens := List (mingens, g -> ImageElm (isoG, g));
    
    dirr := Length (mingens) + 1;
    moduleG := List ([1..Length (mingens)], d -> GModuleByMats (gens{[1..d]}, GF(q)));
    repeat
        dirr := dirr - 1;
    until dirr = 0 or not MTX.IsIrreducible (moduleG[dirr]);
    
    dirr := dirr + 1;
    
    if dirr > Length (mingens) then
        Error ("repG must be irreducible");
    fi;
    imglistrep := List ([1..Length (mingens)], 
        d -> List (imglist[d], g -> ImageElm (isoH, g)));
    
    sizes := List ([1..Length (mingens)], d -> Size (Group (mingens{[1..d]})));

    D := DirectProduct (preG, preH);
    homG := Embedding (D, 1);
    homH := Embedding (D, 2);
    projG := Projection (D, 1);
    projH := Projection (D, 2);
    
    gens := List (mingens, g -> ImageElm(homG, g));
    
    for i in [1..Length (gens)] do
        imglist[i] := List (imglist[i], h -> ImageElm(homH, h));
    od;

    # do a backtrack search through the possible images
    d := 1;
    ind := [0];
    imgs := [];
    group := [];
    count := 0;
    repeat
        count := count + 1;
        ind[d] := ind[d] + 1;
        if count mod 1000 = 0 then
            Info (InfoMorph, 2, "ConjugatingMatIrreducibleOrFail: count = ", count, " trying indices: ", ind{[1..d]});
        else
            Info (InfoMorph, 3, "ConjugatingMatIrreducibleOrFail: count = ", count, " trying indices: ", ind{[1..d]});
        fi;
            
        imgs[d] := imglist[d][ind[d]];
        if d = 1 then
            group[d] := Group (gens[d]*imgs[d]);
        else
            group[d] := ClosureGroup (group[d-1], gens[d]*imgs[d]);
        fi;
        if d = 1 or Size (group[d]) = sizes[d] and Size (ImagesSet (projH, group[d])) = sizes[d] then 
        
            # map from gens to imgs is an isomorphism
            
            if d >= dirr then
                moduleH := GModuleByMats (List ([1..d], i -> imglistrep[i][ind[i]]), GF(q));
                mat := MTX.Isomorphism (moduleG[d], moduleH);
            else
                mat := true;
            fi;
            if mat <> fail then
                if d < Length (gens) then
                    d := d + 1;
                    ind[d] := 0;
                else
                    hom := GroupGeneralMappingByImages (preG, preH, 
                        List (gens, g -> ImageElm (projG, g)), 
                        List (imgs, h -> ImageElm (projH, h)));
                    if not IsGroupHomomorphism (hom) or not IsBijective (hom) then
                        Error ("hom is not an isomophism");
                    fi;
                    Info (InfoMorph, 1, "ConjugatingMatIrreducibleOrFail: found after ", count, " attempts");
                    Info (InfoMorph, 2, "ConjugatingMatIrreducibleOrFail: found indices ", ind);
                    return rec (mat := mat, iso := hom);
                fi;
            else
                Info (InfoMorph, 3, "step: ", ind{[1..d]}, " linearity fails");
            fi;
        fi;
        while d > 0 and ind[d] = Length (imglist[d]) do
            d := d - 1;
        od;
    until d = 0;
    Info (InfoMorph, 1, "ConjugatingMatIrreducibleOrFail:: reps cannot be conjugate,  ", count, " attempts");
        
    return fail;
end);


############################################################################
##
#F  ConjugatingMatImprimitiveOrFail(G, H, d, F)
##
##  G and H must be irreducible matrix groups over the finite field F
##  H must be block monomial with block dimension d
##
##  computes record x with a single component x.mat such that G^x.mat = H 
##  or returns fail if no such x.mat exists
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

    if Minimum (List (systemsG, sys -> Length (sys.bases[1]))) <> d then
        Info (InfoIrredsol, 1, "different minimal block dimension - groups are not conjugate");
        return fail;
    fi;
    
    if d = n then
        if Size(G) < 100000 then
            return ConjugatingMatIrreducibleOrFail (G, H, F);
        fi;
        hom := NiceMonomorphism (GL(n, Size(F)));
        r := RepresentativeAction (ImagesSource (hom), 
                ImagesSet (hom, G), ImagesSet (hom, H));
        if r <> fail then
            Info (InfoIrredsol, 1, " conjugating matrix found");
            return rec ( mat := PreImagesRepresentative (hom, r));
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
                    return rec (mat := r);
                fi;
            fi;
        od;
        Info (InfoIrredsol, 1, "groups are not conjugate");
        return fail;
    fi;
end);


############################################################################
##
#F  RecognitionAISMatrixGroup(G, inds, wantmat, wantgroup, wantiso)
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
    function (G, inds, wantmat, wantgroup, wantiso)
    
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
                    
                    fpinfo := IRREDSOL_DATA.FP[n][q][fppos];        # fingerprint info

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

        if Length (inds) > 1 or wantmat or wantiso then 
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

                if wantiso then
                     x := ConjugatingMatIrreducibleOrFail (G, H, F);
                else
                     x := ConjugatingMatImprimitiveOrFail (G, H, 
                          MinimalBlockDimensionOfMatrixGroup (G), F);
                fi;
                if x = fail then
                    Info (InfoIrredsol, 1, "group does not have id ", IdIrreducibleSolvableMatrixGroup (H));
                else
                    Assert (1, G^(x.mat) = H);
                    info.id := [DegreeOfMatrixGroup (G), Size (F), 1, inds[i]];
                    if wantgroup then
                        info.group := H;
                    fi;
                    if wantmat then
                        info.mat := t*x.mat;
                    fi;
                    if wantiso then
                        info.iso := x.iso;
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
        if wantmat or wantiso then
            if wantiso then
                x := ConjugatingMatIrreducibleOrFail (G, H, F);
            else
                x := ConjugatingMatImprimitiveOrFail (G, H, 
                          MinimalBlockDimensionOfMatrixGroup (G), F);
            fi;
            if x = fail then
                Error ("panic: group not found in database");
            fi;
            if wantmat then
                info.mat := t*x.mat;
            fi;
            if wantiso then
                info.iso := x.iso;
            fi;
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
##  id:                     contains the id of H (and thus of G), 
##                            cf. IdIrreducibleSolvableMatrixGroup
##  mat: (optional)     a matrix x such that G^x = H
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
    function (arg)
    
        local G, wantmat, wantgroup, wantiso, info;
        
        if Length (arg) < 2 or Length (arg) > 4 then
          Error ("RecognitionIrreducibleSolvableMatrixGroup (G [, wantmat [, wantgroup [,wantiso]]])");
        fi;
        
        # test if G is solvable
        
        G := arg[1];
        if not IsMatrixGroup (G) or not IsFinite (FieldOfMatrixGroup (G)) 
                or not IsSolvableGroup (G) then
            Error ("G must be a solvable matrix group over a finite field");
        fi;

        wantmat := arg[2];
        if Length (arg) = 2 then
            wantgroup := false;
        else
            wantgroup := arg[3];
            if Length (arg) = 3 then
                wantiso := false;
            else
                wantiso := arg[4];
            fi;
        fi;
        if not IsBool (wantmat) or not IsBool (wantgroup) or not IsBool (wantiso) then
            Error ("wantmat, wantgroup and wantiso must be booleans");
        fi;
        info := RecognitionIrreducibleSolvableMatrixGroupNC (G, 
            wantmat, wantgroup, wantiso);
        if info = fail then
            Error ("This group is not within the scope of the IRREDSOL library");
        fi;
        return info;
    end);

    
############################################################################
##
#F  RecognitionIrreducibleSolvableMatrixGroupNC(G, wantmat, wantgroup, wantiso)
##
##  version of RecognitionIrreducibleSolvableMatrixGroup which does not check
##  its arguments and returns fail if G is not within the scope of the 
##  IRREDSOL library
##
InstallGlobalFunction (RecognitionIrreducibleSolvableMatrixGroupNC, 
    function (G, wantmat, wantgroup, wantiso)

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
            info := RecognitionAISMatrixGroup (G, fail, wantmat, wantgroup, wantiso);
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
                if wantiso then
                    newinfo.iso := info.iso;
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
            
            info := RecognitionAISMatrixGroup (H, fail, wantmat, false, wantiso);
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
                # raising to gal-th power is the field automorphism which maps H to a conjugate of
                # the absolutely irreducible group which is used to construct the irreducible group
                # we want to find
                gal := q^perm_pow.pow; 
                if gal = 1 then
                     gens := List (MTX.Generators(module), mat -> mat^info.mat);
                     Info (InfoIrredsol, 1, "already got right Galois conjugate");
                     if wantiso then
                        if Source (RepresentationIsomorphism (newinfo.group)) <> Range (info.iso) then
                            Error ("sources of isomorphisms don't match");
                        fi;
                        newinfo.iso := info.iso;
                    fi;
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
                                    
                    conjinfo := RecognitionAISMatrixGroup (H, [perm_pow.min], true, false, wantiso);
                    if conjinfo = fail then 
                        Error ("panic: internal error, Galois conjugate isn't in the library");
                    elif conjinfo.id <> [info.id[1], info.id[2], 1, perm_pow.min] then
                        Error ("panic: internal error, didn't find correct Galois conjugate");
                    fi;
                    gens := List (MTX.Generators (module), mat -> mat^conjinfo.mat);
                    if wantiso then
                        if Source (RepresentationIsomorphism (newinfo.group)) <> Range (conjinfo.iso) then
                            Error ("sources of isomorphisms don't match");
                        fi;
                        newinfo.iso := conjinfo.iso;
                    fi;
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
    [IsFFEMatrixGroup 
        and IsIrreducibleMatrixGroup and IsSolvableGroup], 0,

    function (G)
        
        local info;
        
        info := RecognitionIrreducibleSolvableMatrixGroupNC (G, false, false, false);
        if info = fail then
            Error ("group is beyond the scope of the IRREDSOL library");
        else
            return info.id;
        fi;
    end);
    
    
RedispatchOnCondition(IdIrreducibleSolvableMatrixGroup, true,
    [IsFFEMatrixGroup],
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
