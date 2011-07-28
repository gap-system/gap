    ############################################################################
##
##  access.gi                    IRREDSOL                   Burkhard Höfling
##
##  @(#)$Id: access.gi,v 1.8 2011/05/18 16:26:56 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


############################################################################
##
#F  IndicesIrreducibleSolvableMatrixGroups(<n>, <q>, <d>)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IndicesIrreducibleSolvableMatrixGroups, 
    function ( n, q, d )
        
        local data, inds, perm, i, k, l, max;
        
        if not IsPosInt (n) or not IsPosInt (d) or not IsPosInt (q) 
                or not IsPPowerInt (q) then
            Error ("n, q, and d must be positive integers, ",
                "q must be a prime power");
        fi;
        if n mod d <> 0 then
            return [];
        fi;

        LoadAbsolutelyIrreducibleSolvableGroupData (n/d, q^d);

        if d < n then
            data := IRREDSOL_DATA.GROUPS[n/d][q^d];
            inds := Filtered ([1..Length (data)], i -> IsBound (data[i])); 
                # as a last resort, redundant groups can be removed
        else
            inds := [1..Length(IRREDSOL_DATA.GROUPS_DIM1 [q^d])];
            if d > 1 then
                if IRREDSOL_DATA.GROUPS_DIM1 [q^d][1] = 1 then
                    RemoveSet (inds, 1); # rewriting the trivial group over a smaller field yields a reducible group
                fi;
            fi;
        fi;
        perm := IRREDSOL_DATA.GAL_PERM[n/d][q^d]^LogInt (q, SmallestRootInt (q));
        # permutation of a generator of Gal (GF(q^d)/GF(q)) on inds

        if perm <> () then
            i := PositionSorted (inds, SmallestMovedPoint(perm));
            max := LargestMovedPoint(perm);
            while i <= Length (inds) do
                k := inds[i];
                if k > max then 
                    break;
                fi;
                l := k^perm;
                while l <> k do
                    RemoveSet (inds, l);
                    l := l^perm;
                od;
                i := i + 1;
            od;
        fi;
        MakeImmutable (inds);
        return inds;    
    end);


############################################################################
##
#F  PermCanonicalIndexIrreducibleSolvableMatrixGroup(<n>, <q>, <d>, <k>  
##
InstallGlobalFunction (PermCanonicalIndexIrreducibleSolvableMatrixGroup, 
    function ( n, q, d, k )

        local perm, pow, l, orb, min, powmin;
        
        LoadAbsolutelyIrreducibleSolvableGroupData (n/d, q^d);
        
        perm := IRREDSOL_DATA.GAL_PERM[n/d][q^d]^LogInt (q, SmallestRootInt (q));
        
        # permutation of a generator of Gal (GF(q^d)/GF(q)) on parameters
        
        powmin := 0;
        l := k^perm; # check whether k is least in orbit
        pow := 1;
        min := k;
        orb := [k];
        while l <> k do
            Add (orb, l);
            # we have l = k^(perm^pow)
            if l < k then
                powmin := pow;
                min := l;
            fi;
            l := l^perm;
            pow := pow + 1;
        od;
        return rec (perm := perm, pow := powmin, orb := orb, min := min);
    end);
    

############################################################################
##
#F  IrreducibleSolvableMatrixGroup(<n>, <q>, <d>, <k>)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IrreducibleSolvableMatrixGroup, 
    function ( n, q, d, k )
        
        local perm, l, n0, q0, p, o, i, bas, mat, C, c, gddesc, desc, pres, gens, pcgs, grp, hom;
        
        if not IsPosInt (n) or not IsPosInt (d) or not IsPosInt (q) 
                or not IsPPowerInt (q)  or not IsPosInt (k) or not n mod d = 0 then
            Error ("n, q, d, and k must be positive integers, q must be a prime power ",
                "and d must divide n");
        fi;
                
        n0 := n;
        q0 := q;
        n := n0/d;
        q := q0^d;
        p := SmallestRootInt (q0);
        
        LoadAbsolutelyIrreducibleSolvableGroupData (n, q);
        
        if d > 1 then # rewrite as matrix group over subfield

            # switch to larger field


            # compute the permutation of a generator of Gal(GF(q)/GF(q0)) 
            # on the ccls of absolutely irreducible subgroups of GL(n,q)

            perm := IRREDSOL_DATA.GAL_PERM[n][q]^LogInt (q0, p);
                            
            # check if k is a valid paramter, i. e., least in orbit

            l := k^perm; 
            while l <> k do
                if l < k then
                    Error ("inadmissible value for k");    
                fi;
                l := l^perm;
            od;
    
            Info (InfoIrredsol, 3, "Constructing irreducible group with id ", 
                [n0, q0, d, k]);
            
    
            bas := CanonicalBasis (AsVectorSpace (GF(q0), GF(q)));
                      # it is important to use CanonicalBasis here, in order to be sure
                      # that the result is the same when called multiple times
        fi;
        if n = 1 then
            if not IsBound (IRREDSOL_DATA.GROUPS_DIM1[q][k]) then
                Error ("inadmissible value for k");    
            fi;
            o := IRREDSOL_DATA.GROUPS_DIM1[q][k][1];
            
            mat := [[Z(q)^((q-1)/o)]];
            if d > 1 then
                mat := BlownUpMat (bas, mat);
            fi;
            grp := GroupWithGenerators ([mat], IdentityMat(n0, GF(q0)));
            SetSize (grp, o);
            SetIsCyclic (grp, true);
            i := PositionSet (DivisorsInt (LogInt (q, p)), LogInt (q0, p));
            if d = 1 then
                SetMinimalBlockDimensionOfMatrixGroup (grp,  1);
            else
                SetMinimalBlockDimensionOfMatrixGroup (grp, IRREDSOL_DATA.GROUPS_DIM1[q][k][2][i]);
            fi;
                
            if o = 1 then
                hom := IdentityMapping (grp);
            else
                Assert (1, Length (IRREDSOL_DATA.GUARDIANS[1][q]) = 1);
                C := IRREDSOL_DATA.GUARDIANS[1][q][1];
                Assert (1, Length (MinimalGeneratingSet(C)) = 1);
                c := MinimalGeneratingSet(C)[1]^((q-1)/o);
                Assert (1, Order (c) = o);
                hom := GroupHomomorphismByImagesNC (SubgroupNC (C, [c]), grp, [c], [mat]);
                SetIsBijective (hom, true);
            fi;
        else
            if not IsBound (IRREDSOL_DATA.GROUPS[n][q][k]) then
                Error ("inadmissible value for k");    
            fi;
            
            # construct group and isomorphic pc group
            
            desc  := IRREDSOL_DATA.GROUPS[n][q][k];
            gddesc := IRREDSOL_DATA.GUARDIANS[n][q][desc[1]];
            pres := gddesc[3];
            
            pcgs := CanonicalPcgsByNumber (FamilyPcgs (Source (pres)), desc[2]);
            gens := List (pcgs, x -> ImageElm (pres, x));
            if d > 1 then 
                gens := List (gens, x -> BlownUpMat (bas, x));
            fi;
            
            grp := GroupWithGenerators (gens, IdentityMat(n0, GF(q0)));
            SetSize( grp, Product (RelativeOrders (pcgs)) );
            
            hom := GroupHomomorphismByImagesNC (GroupOfPcgs (pcgs), grp, 
                pcgs, gens);
            SetIsBijective (hom, true);
                
            # look up minimal block dimension
            if d = 1 then
                SetMinimalBlockDimensionOfMatrixGroup (grp, gddesc[4]);
            else
                i := PositionSet (DivisorsInt (LogInt (q, p)), LogInt (q0, p));
                SetMinimalBlockDimensionOfMatrixGroup (grp, IRREDSOL_DATA.GROUPS[n][q][k][3][i]);
            fi;
        fi;
        
        SetIdIrreducibleSolvableMatrixGroup (grp, [n0, q0, d, k]);
        SetFieldOfMatrixGroup (grp, GF(q0));
        SetDefaultFieldOfMatrixGroup(grp, GF(q0));
        SetTraceField (grp, GF(q0));            
        SetConjugatingMatTraceField (grp, One(grp));
        SetRepresentationIsomorphism (grp, hom);
        SetIsPrimitiveMatrixGroup (grp, MinimalBlockDimensionOfMatrixGroup(grp) = n);
        SetIsIrreducibleMatrixGroup (grp, true);
        SetIsAbsolutelyIrreducibleMatrixGroup (grp, d = 1);
        SetIsSolvableGroup (grp, true);
        return grp;
    end);
        
        

############################################################################
##
#F  IndicesMaximalAbsolutelyIrreducibleSolvableMatrixGroups(<n>, <q>)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IndicesMaximalAbsolutelyIrreducibleSolvableMatrixGroups,
    function ( n, q )
    
        if not IsPosInt (n) or not IsPPowerInt (q)  then
            Error ("n and q must be positive integers and q must be a prime power");
        fi;
        LoadAbsolutelyIrreducibleSolvableGroupData (n, q);
        if n = 1 then
            return Immutable ([Length (IRREDSOL_DATA.GROUPS_DIM1 [q])]);
        else
            return IRREDSOL_DATA.MAX[n][q];
        fi;
    end);


############################################################################
##
#E
##
