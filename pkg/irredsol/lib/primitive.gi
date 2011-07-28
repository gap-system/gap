############################################################################
##
##  primitive.gi                   IRREDSOL                 Burkhard Höfling
##
##  @(#)$Id: primitive.gi,v 1.6 2011/05/18 16:42:35 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


############################################################################
##
#F  PcGroupExtensionByMatrixAction(<pcgs>, <hom>)
##
##  Let <G> be a finite solvable group with pcgs <pcgs>, and let <hom> be a 
##  group hom. $<hom>\colon G \to GL(n, p)$, where $p$ is a prime. Let  $E$ 
##  denote the split
##  extension of $G$ by $V = \F_p$, where <G> acts on <V> via <hom>.
##  This function returns a record with the following components.
##     ext:   the group $E$ as a new pc group
##     V:     the subgroup $V$ of $E$ corresponding to the vector space
##     C:     a complement of $V$ in $E$ isomorphic with $G$
##     embed: a group homomorphism $G \to E$ with image $C$
##     proj:  a group homomorphism $E \to G$ with kernel $V$
##     pcgsV: an induced pcgs of V (wrt. FamilyPcgs(E)) whose elements 
##               correspond to the natural basis elements
##               of the vector space V
##     pcgsC: an induced pcgs of C (wrt. FamilyPcgs(E)) whose elements  
##               correspond to the images of pcgs under embed; 
##               the elements of pcgsC act on pcgsV as the images of pcgs
##               under hom act on the natural basis of V
##  
InstallGlobalFunction (PcGroupExtensionByMatrixAction,
    function (pcgs, hom)
        local p, d, ros, f, coll, exp, mat, i, j, r, E, pcgsC, pcgsV;
        
        p := Size (FieldOfMatrixGroup (Range(hom)));
        d := DegreeOfMatrixGroup (Range(hom));
        if not IsPrimeInt (p) then
            Error ("Range(hom) must be over a prime field ");
        fi;
        
        ros := RelativeOrders (pcgs);
        
        f := FreeGroup (Length (pcgs) + d);
        coll := SingleCollector (f, 
            Concatenation (ros, 
                ListWithIdenticalEntries (d, p)));
                
        # relations for complement - same as for those for G        
        exp := [];    
        exp{[1,3..2*Length(pcgs)-1]} := [1..Length(pcgs)];
        for i in [1..Length (pcgs)] do
            exp{[2,4..2*Length(pcgs)]} := ExponentsOfPcElement (pcgs, pcgs[i]^ros[i]);
            # Print ("power relation ", i,": ", exp, "\n");
            SetPower (coll, i, ObjByExtRep (FamilyObj (f.1), exp));
            for j in [i+1..Length (pcgs)] do
                exp{[2,4..2*Length(pcgs)]} := ExponentsOfPcElement (pcgs, pcgs[j]^pcgs[i]);
                # Print ("conj. relation ", j, "^", i,": ", exp, "\n");
            SetConjugate (coll, j, i, ObjByExtRep (FamilyObj (f.1), exp));
            od;
        od;
        
        # relations for socle
        for j in [1..d] do
            SetPower (coll, j+Length (pcgs), One(f));
        od;
        
        exp := [];
        exp{[1,3..2*d-1]} := 
            [Length(pcgs) + 1..Length (pcgs) + d];
                
        for i in [1..Length (pcgs)] do
            mat := ImageElm (hom, pcgs[i]);
            for j in [1..d] do
                exp{[2,4..2*d]} := List (mat[j], IntFFE);
                # Print ("conj. relation ", j+ Length (pcgs), "^", i,": ", exp, "\n");
                SetConjugate (coll, j + Length (pcgs), i, ObjByExtRep (FamilyObj (f.1), exp));
            od;
        od;
        
        E := GroupByRwsNC (coll);
        SetSize (E, Product (ros) * p^d);
        pcgsV := InducedPcgsByPcSequenceNC (FamilyPcgs (E),
            FamilyPcgs(E){[Length (pcgs) + 1..Length (FamilyPcgs (E))]});

        # the following sets attributes/properties which are defined 
        # in the CRISP packages
        
        pcgsC := InducedPcgsByPcSequenceNC (FamilyPcgs (E),
                FamilyPcgs(E){[1..Length (pcgs)]});

        r := rec (
            E := E, 
            V := GroupOfPcgs (pcgsV), 
            C := GroupOfPcgs (pcgsC),
            pcgsV := pcgsV,
            pcgsC := pcgsC);        
        r.embed := GroupHomomorphismByImagesNC (GroupOfPcgs(pcgs), E, pcgs, pcgsC);
        SetIsInjective (r.embed, true);
        SetImagesSource (r.embed, r.C);
        r.proj := GroupHomomorphismByImagesNC (E, GroupOfPcgs (pcgs), 
            Concatenation (pcgsC, pcgsV), 
            Concatenation (pcgs, ListWithIdenticalEntries (d, OneOfPcgs (pcgs))));
        SetIsSurjective (r.proj, true);
        SetKernelOfMultiplicativeGeneralMapping (r.proj, r.V);
        return r;
    end);

    
############################################################################
##
#F  PrimitivePcGroupIrreducibleMatrixGroup(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (PrimitivePcGroupIrreducibleMatrixGroup,
    function (G)
            
        if not IsMatrixGroup (G) or not IsFinite (FieldOfMatrixGroup (G)) 
                or not IsPrimeInt (Size (FieldOfMatrixGroup (G)))
                or not IsIrreducibleMatrixGroup (G) then
            Error ("G must be an irreducible matrix group over a prime field");
        fi;

        return PrimitivePcGroupIrreducibleMatrixGroupNC (G);
    end);
    
            
############################################################################
##
#F  PrimitivePcGroupIrreducibleMatrixGroupNC(<G>)
##
##  see IRREDSOL documentation
##
##  it is important that the map from Pcgs(Source(RepresentationIsomorphism(G)))
##  
InstallGlobalFunction (PrimitivePcGroupIrreducibleMatrixGroupNC,
    function (G)
        
        local rep, ext;
        
        rep := RepresentationIsomorphism(G);
        ext := PcGroupExtensionByMatrixAction (Pcgs (Source(rep)), rep);
        SetSocle (ext.E, ext.V);
        SetSocleComplement(ext.E, ext.C);
        SetFittingSubgroup (ext.E, ext.V);

        # the following sets attributes/properties which are defined 
        # in the CRISP packages
                
        if IsBoundGlobal ("SetIsPrimitiveSolvable") then
            ValueGlobal ("SetIsPrimitiveSolvable") (ext.E, true);
        fi;
        return ext.E;
        
    end);
    

   

############################################################################
##
#F  PrimitivePcGroup(<n>,<p>,<d>,<k>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (PrimitivePcGroup,
    function (n, p, d, k)
      
        local q, desc, G, mat, bas, hom, ext, o, pcgs, pcgsC, pcgsV, H;
         
        if not IsPosInt (n) or not IsPosInt (d) or not IsPosInt (p) or not IsPrimeInt (p) or n mod d <> 0 then
            Error ("n, p, and d must be positive integers, ",
                "p must be a prime, and d must divide n");
        elif not k in IndicesIrreducibleSolvableMatrixGroups (n, p, d) then
            Error ("k must be in IndicesIrreducibleSolvableMatrixGroups (n, p, d)");
        else    
            n := n /d;
            q := p^d;
            LoadAbsolutelyIrreducibleSolvableGroupData (n, q);
            if n > 1 then
                desc := IRREDSOL_DATA.GROUPS[n][q][k];
            fi;
            if not IsBound (IRREDSOL_DATA.PRIM_GUARDIANS[n]) then
                IRREDSOL_DATA.PRIM_GUARDIANS[n] := [];
            fi;
            if not IsBound (IRREDSOL_DATA.PRIM_GUARDIANS[n][q]) then
                if n = 1 then
                    G := IRREDSOL_DATA.GUARDIANS[1][q][1];
                    mat := [[Z(q)]];
                    hom := GroupHomomorphismByImagesNC (G, Group (mat), 
                        MinimalGeneratingSet(G), [mat]);
                    SetIsBijective (hom, true);
                else
                    hom := IRREDSOL_DATA.GUARDIANS[n][q][desc[1]][3];
                    G := Source (hom);
                fi;
                if d > 1 then
                    bas := CanonicalBasis (AsVectorSpace (GF(p), GF(q)));
                    mat := List (InducedPcgsWrtFamilyPcgs (G), 
                        g -> BlownUpMat (bas, ImageElm (hom, g)));
                    hom := GroupHomomorphismByImagesNC (G, Group (mat), 
                        InducedPcgsWrtFamilyPcgs (G), mat);
                fi;
                    
                IRREDSOL_DATA.PRIM_GUARDIANS[n][q] := 
                    PcGroupExtensionByMatrixAction (InducedPcgsWrtFamilyPcgs (G), hom);

            fi;
            ext := IRREDSOL_DATA.PRIM_GUARDIANS[n][q];
            if n = 1 then
                Assert (1, Length (MinimalGeneratingSet(ext.C)) = 1);
                o := IRREDSOL_DATA.GROUPS_DIM1[q][k][1];
                pcgsC := InducedPcgsByGenerators (FamilyPcgs (ext.E), 
                    [MinimalGeneratingSet(ext.C)[1]^((q-1)/o)]);
            else
                pcgsC := CanonicalPcgsByNumber (ext.pcgsC, desc[2]);
            fi;
            pcgs := InducedPcgsByPcSequenceNC (FamilyPcgs (ext.E), Concatenation (pcgsC, ext.pcgsV));
            H := GroupOfPcgs (pcgs);
            SetIdPrimitiveSolvableGroup (H, [n*d,p,d,k]);
            SetSocle (H, ext.V);
            SetFittingSubgroup (H, ext.V);
            SetSocleComplement(H, GroupOfPcgs (pcgsC));

            # the following sets attributes/properties which are defined 
            # in the CRISP packages
                
            if IsBoundGlobal ("SetIsPrimitiveSolvable") then
                ValueGlobal ("SetIsPrimitiveSolvable") (H, true);
            fi;
            return H;
        fi;
    end);
    
            
############################################################################
##
#F  IrreducibleMatrixGroupPrimitiveSolvableGroup(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (IrreducibleMatrixGroupPrimitiveSolvableGroup,
    function (G)

        local F, p, matgrp, compl;

        if not IsFinite (G) or not IsSolvableGroup (G) then
            Error ("G must be finite and solvable");
            
        # test if primitive - use the CRISP method if it is available     
        elif IsBoundGlobal ("IsPrimitiveSolvable") 
                 and ValueGlobal ("IsPrimitiveSolvable") (G) then
            return IrreducibleMatrixGroupPrimitiveSolvableGroupNC (G);
            
        else # test for primitivity
            F := FittingSubgroup (G);
            
            if not IsPGroup (F)  or not IsAbelian (F) then
                Error ("G must be primitive");
            else
                p := PrimePGroup (F);

                if ForAny (GeneratorsOfGroup (F), x -> x^p <> One(G)) then
                    Error ("G must be primitive");
                else
                    matgrp := IrreducibleMatrixGroupPrimitiveSolvableGroupNC (G);
                    if not IsIrreducibleMatrixGroup (matgrp, GF(p)) then
                        Error ("G must be primitive");
                    else
                        compl := Complementclasses (G, F);
                        if Length (compl) <> 1 then
                            Error ("G must be primitive");
                        fi;
                        SetSocle (G, F);
                        return matgrp;
                    fi;
                fi;
            fi;
        fi;
    end);
    
            
############################################################################
##
#F  IrreducibleMatrixGroupPrimitiveSolvableGroupNC(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (IrreducibleMatrixGroupPrimitiveSolvableGroupNC,
    function (G)
    
        local N, p, F, pcgsN, pcgsGmodN, GmodN, one, mat, mats, g, h, i, H, hom;
        
        N := FittingSubgroup (G);
        
        pcgsN := Pcgs (N);
        p := RelativeOrders (pcgsN)[1];
        F := GF(p);
        one := One (F);
        
        mats := [];
        
        pcgsGmodN := ModuloPcgs (G, N);
        for g in pcgsGmodN do
            mat := [];
            for i in [1..Length (pcgsN)] do
                mat[i] := ExponentsOfPcElement (pcgsN, pcgsN[i]^g)*one;
            od;
            Add (mats, ImmutableMatrix (F, mat));
        od;
        H := Group (mats);
        SetSize (H, Size (G)/Size (N));
        GmodN := PcGroupWithPcgs (pcgsGmodN);
        hom := GroupGeneralMappingByImages (GmodN, H, FamilyPcgs (GmodN), mats);
        SetIsGroupHomomorphism (hom, true);
        SetIsBijective (hom, true);
        SetRepresentationIsomorphism (H, hom);
        return H;
    end);
        

############################################################################
##
#F  DoIteratorPrimitiveSolvableGroups(<convert_func>, <arg_list>)
##
##  generic constructor function for an iterator of all primitive solvable groups
##  which can construct permutation groups or pc groups (or other types of groups),
##  depending on convert_func
##  
InstallGlobalFunction (DoIteratorPrimitiveSolvableGroups, 
    function (convert_func, arg_list)

        local r, iter;
        
        r := CheckAndExtractArguments ([
            [[Degree, NrMovedPoints, LargestMovedPoint], IsPosInt],
            [[Order, Size], IsPosInt]],
            arg_list, 
            "IteratorPrimitivePcGroups");
        if ForAny (r.specialvalues, v -> IsEmpty (v)) then
            return Iterator ([]);
        fi;

        iter := rec(convert_func := convert_func);

        if not IsBound (r.specialvalues[1]) then 
            Error ("IteratorPrimitivePcGroupsIterator: You must specify the degree(s) of the desired primitive groups");
        else
            iter.degs := Filtered (r.specialvalues[1], IsPPowerInt);
        fi;    
        
        iter.degind := 0;
        
        if IsBound (r.specialvalues[2]) then
            iter.orders := r.specialvalues[2];
        else
            iter.orders := fail;
        fi;
        
        iter.iteratormatgrp := Iterator([]);

        iter.IsDoneIterator := function (iterator)

            local d, p, n, orders, o;
            
            if iterator!.degind > Length (iterator!.degs) then
                Error ("isDoneIterator called after it returned true");
            fi;
            
            while IsDoneIterator (iterator!.iteratormatgrp) do
                iterator!.degind := iterator!.degind + 1;
                if iterator!.degind > Length (iterator!.degs) then
                    return true;
                fi;
                d := iterator!.degs[iterator!.degind];
                p := SmallestRootInt (d);
                n := LogInt (d, p);
                if IsAvailableIrreducibleSolvableGroupData (n, p) then                
                    if iterator!.orders <> fail then
                        orders := [];
                        for o in iterator!.orders do
                            if o mod d = 0 then
                                Add (orders, o/d);
                            fi;
                        od;
                        iterator!.iteratormatgrp := IteratorIrreducibleSolvableMatrixGroups(
                            Degree, n, Field, GF(p), Order, orders);
                    else
                        iterator!.iteratormatgrp := IteratorIrreducibleSolvableMatrixGroups(
                            Degree, n, Field, GF(p));

                    fi;
                else
                    Error ("groups of degree ", d, " are beyond the scope of the IRREDSOL library");
                    iterator!.iteratormatgrp := Iterator([]);
                fi;
            od;
            return false;
        end;

        iter.NextIterator := function (iterator)
            
            local G;
            
            G := NextIterator (iterator!.iteratormatgrp);
            return iterator!.convert_func (G);
        end;
        
        iter.ShallowCopy := function (iterator)
            return rec (
                orders := iterator!.orders,
                degs := iterator!.degs,
                degind := iterator!.degind,
                convert_func := iterator!.convert_func,
                iteratormatgrp := ShallowCopy (iterator!.iteratormatgrp),
                IsDoneIterator := iterator!.IsDoneIterator,
                NextIterator := iterator!.NextIterator,
                ShallowCopy := iterator!.ShallowCopy);
        end;
        return IteratorByFunctions (iter);
    end);
    
    
############################################################################
##
#F  IteratorPrimitivePcGroups(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IteratorPrimitivePcGroups,
    function (arg)
        return DoIteratorPrimitiveSolvableGroups (
            PrimitivePcGroupIrreducibleMatrixGroupNC,
            arg);
    end);
    

###########################################################################
##
#F  AllPrimitivePcGroups(<arg>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (AllPrimitivePcGroups,
    function (arg)
    
        local iter, l, G;
        
        iter := CallFuncList (IteratorPrimitivePcGroups, arg);
        
        l := [];
        for G in iter do
            Add (l, G);
        od;
        return l;
    end);


###########################################################################
##
#F  OnePrimitivePcGroup(<arg>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (OnePrimitivePcGroup,
    function (arg)
    
        local iter;
        
        iter := CallFuncList (IteratorPrimitivePcGroups, arg);
        if IsDoneIterator (iter) then
            return fail;
        else 
            return NextIterator (iter);
        fi;
    end);


############################################################################
##
#F  PrimitivePermGroupIrreducibleMatrixGroup(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (PrimitivePermGroupIrreducibleMatrixGroup,
    function (G)
            
        if not IsMatrixGroup (G) or not IsFinite (FieldOfMatrixGroup (G)) 
                or not IsPrimeInt (Size (FieldOfMatrixGroup (G)))
                or not IsIrreducibleMatrixGroup (G) then
            Error ("G must be an irreducible matrix group over a prime field");
        fi;

        return PrimitivePermGroupIrreducibleMatrixGroupNC (G);
    end);
    
            
############################################################################
##
#F  PrimitivePermGroupIrreducibleMatrixGroupNC(<G>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (PrimitivePermGroupIrreducibleMatrixGroupNC, 
    function ( M )
        local  gensc, genss, V, bas, enum, G;
        V := FieldOfMatrixGroup( M ) ^ DimensionOfMatrixGroup( M );
        bas := CanonicalBasis (V);
        enum := EnumeratorByBasis (bas);
        gensc := List (GeneratorsOfGroup (M), x -> Permutation (x, enum));
        genss := List( bas, x -> Permutation( x, enum, \+));
        G := GroupByGenerators(Concatenation (genss, gensc));
        SetSize( G, Size( M ) * Size( V ) );
        SetSocle (G, Subgroup (G, genss));
        SetSocleComplement(G, Subgroup (G, gensc));
         
        # the following sets attributes/properties which are defined 
        # in the CRISP packages

        if IsBoundGlobal ("SetIsPrimitiveSolvable") then
            ValueGlobal ("SetIsPrimitiveSolvable") (G, true);
        fi;
         return G;
    end);


############################################################################
##
#F  PrimitiveSolvablePermGroup(<n>,<p>,<d>,<k>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (PrimitiveSolvablePermGroup,
    function (n, p, d, k)

        local G;
        if not IsPosInt (n) or not IsPosInt (d) or not IsPosInt (p) or not IsPrimeInt (p) then
            Error ("n, p, and d must be positive integers, ",
                "p must be a prime, and d must divide n");
        elif not k in IndicesIrreducibleSolvableMatrixGroups (n, p, d) then
            Error ("k must be in IndicesIrreducibleSolvableMatrixGroups (n, p, d)");
        else
            G := PrimitivePermGroupIrreducibleMatrixGroupNC (
                    IrreducibleSolvableMatrixGroup (n, p, d, k));
            SetIdPrimitiveSolvableGroup (G, [n,p,d,k]);
        fi;
        return G;
     end);
    
            
############################################################################
##
#F  IteratorPrimitiveSolvablePermGroups(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IteratorPrimitiveSolvablePermGroups,
    function (arg)
        return DoIteratorPrimitiveSolvableGroups (
            PrimitivePermGroupIrreducibleMatrixGroupNC,
            arg);
    end);
    

###########################################################################
##
#F  AllPrimitiveSolvablePermGroups(<arg>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (AllPrimitiveSolvablePermGroups,
    function (arg)
    
        local iter, l, G;
        
        iter := CallFuncList (IteratorPrimitiveSolvablePermGroups, arg);
        
        l := [];
        for G in iter do
            Add (l, G);
        od;
        return l;
    end);


###########################################################################
##
#F  OnePrimitiveSolvablePermGroup(<arg>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (OnePrimitiveSolvablePermGroup,
    function (arg)
    
        local iter;
        
        iter := CallFuncList (IteratorPrimitiveSolvablePermGroups, arg);
        if IsDoneIterator (iter) then
            return fail;
        else 
            return NextIterator (iter);
        fi;
    end);


############################################################################
##
#E
##
            
        
        

    
