############################################################################
##
##  loading.gi                    IRREDSOL                  Burkhard Höfling
##
##  @(#)$Id: loading.gi,v 1.7 2011/05/18 16:34:45 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##

    
############################################################################
##
#F  IsAvailableAbsolutelyIrreducibleSolvableGroupData(<n>, <q>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (IsAvailableAbsolutelyIrreducibleSolvableGroupData,
    function (n, q)
    
        if not IsPosInt (n) or not IsPosInt (q) or not IsPPowerInt (q)  then
            Error ("n and q must be positive integers and q must be a prime power");
        fi;
        return TryLoadAbsolutelyIrreducibleSolvableGroupData (n, q);
    end);
    
    
############################################################################
##
#F  TryLoadAbsolutelyIrreducibleSolvableGroupData(<n>, <q>)
##
InstallGlobalFunction (TryLoadAbsolutelyIrreducibleSolvableGroupData,
    function (n, q)
    
        local filename, pathname, dirs, dir, inds, desc, guardianData, guardianDesc, data, 
            i, j, p, d, e, orders, divs, t, info, q0, m, G, H, hom, inv,
            pos, gdPos, maxes, cpcgscode, pcgs;
        
        if not IsPosInt (n) or not IsPosInt (q) or not IsPPowerInt (q)  then
            Error ("n and q must be positive integers and q must be a prime power");
        fi;
        
        if not IsBound (IRREDSOL_DATA.GAL_PERM[n]) then
            IRREDSOL_DATA.GAL_PERM[n] := [];
        fi;
        if not IsBound (IRREDSOL_DATA.GUARDIANS[n]) then
            IRREDSOL_DATA.GUARDIANS[n] := [];
        fi;
         
        if n = 1 then
            if not IsBound (IRREDSOL_DATA.GROUPS_DIM1[q]) then
                Info (InfoIrredsol, 2, "Computing irreducible solvable group data for ",
                  "GL(", n, ", ", q, ")");
                p := SmallestRootInt (q);
                e := LogInt (q, p);
                orders := ShallowCopy (DivisorsInt (q-1));
                # remove groups which are over a proper subfield
                if e > 1 then
                  for d in Set (Factors (e)) do
                     SubtractSet (orders, DivisorsInt (p^(e/d) - 1));
                  od;
                fi;
      
                if p < q then
                  divs := Reversed (Difference (DivisorsInt (e), [1]));
                  info := List (orders, o -> [o, []]);
                  for j in [1..Length (divs)] do
                     d := divs[j];
                     q0 := p^(e/d);

                     for i in info do
                        
                        for t in DivisorsInt (GcdInt (i[1], d)) do
                            m := d/t;
                            if (q0^m -1) mod (i[1]/t) = 0 then
                              i[2][j] := m;
                            fi;
                        od;
                     od;
                  od;
                else
                  info := List (orders, o -> [o]);
                fi;
                
                IRREDSOL_DATA.GUARDIANS[1][q] := [CyclicGroup (IsPcGroup, q-1)];
                IRREDSOL_DATA.GROUPS_DIM1[q] := info;
                IRREDSOL_DATA.GAL_PERM[1][q] := ();
            fi;
            return true;
        fi;
        
       if not IsBound (IRREDSOL_DATA.GROUPS[n]) then
            IRREDSOL_DATA.GROUPS[n] := [];
        fi;
        if not IsBound (IRREDSOL_DATA.MAX[n]) then
            IRREDSOL_DATA.MAX[n] := [];
        fi;
        if not IsBound (IRREDSOL_DATA.GROUPS_LOADED[n]) then
            IRREDSOL_DATA.GROUPS_LOADED[n] := [];
        fi;
        
        if not IsBound (IRREDSOL_DATA.GUARDIANS[n][q]) or not IsBound (IRREDSOL_DATA.GROUPS[n][q]) 
                or not IsBound (IRREDSOL_DATA.MAX[n][q]) or not IsBound (IRREDSOL_DATA.GAL_PERM[n][q]) 
                or not IsBound (IRREDSOL_DATA.GROUPS_LOADED[n][q]) then
            
            Unbind (IRREDSOL_DATA.GROUPS_LOADED[n][q]); # if anything fails during loading
                # we won't have inconsistencies
            
            pathname := Concatenation ("data/gl_", String (n), "_",String (q),".grp");
            
            Info (InfoIrredsol, 2, "Reading data file ", pathname);
            if not ReadPackage ("irredsol", pathname) then
                return false;
            fi;
            
            if not IsBound (IRREDSOL_DATA.GUARDIANS[n][q]) or not IsBound (IRREDSOL_DATA.GROUPS[n][q]) 
                    or not IsBound (IRREDSOL_DATA.GAL_PERM[n][q]) then
                Error ("Panic: reading data file didn't define required data");
            fi;
            
            # convert guardian data
            
            guardianData := IRREDSOL_DATA.GUARDIANS[n][q];
            maxes := [];
            
            for gdPos in [1..Length (guardianData)]  do
                guardianDesc := guardianData[gdPos];
                guardianDesc[1] := List (guardianDesc[1], m -> FFMatrixByNumber (m, n, q));

                G := PcGroupCode (guardianDesc[3], guardianDesc[2]);
                H := Group (guardianDesc[1]);
                SetSize (H, Size (G));
                hom := GroupHomomorphismByImagesNC (G, H, FamilyPcgs (G), guardianDesc[1]);
                SetIsBijective (hom, true);
                guardianDesc[3] := hom;
                if TestFlag (guardianDesc[5], 0) then
                    cpcgscode := 2^Length (FamilyPcgs(G)) - 1;
                    pos := PositionProperty (IRREDSOL_DATA.GROUPS[n][q], 
                        desc -> desc[2] = cpcgscode and desc[1] = gdPos);
                    if pos = fail then
                        Error ("panic: did not find guardian in list of groups");
                    fi;
                    AddSet (maxes, pos);
                fi;
            od;    
            
            # compupte group orders
            
            data := IRREDSOL_DATA.GROUPS[n][q];
            for d in data do
                pcgs := FamilyPcgs (Source(guardianData[d[1]][3])); # get pcgs of guardian
                d[4] := OrderGroupByCanonicalPcgsByNumber (pcgs, d[2]);
            od;
            
            IRREDSOL_DATA.GUARDIANS[n][q] := guardianData; # now attach converted data
            IRREDSOL_DATA.MAX[n][q] := maxes;
            MakeImmutable (IRREDSOL_DATA.GUARDIANS[n][q]);
            MakeImmutable (IRREDSOL_DATA.GROUPS[n][q]);
            MakeImmutable (IRREDSOL_DATA.MAX[n][q]);
            IRREDSOL_DATA.GROUPS_LOADED[n][q] := true;
            Info (InfoIrredsol, 2, "irreducible solvable group data for GL(", n, ", ", q, ") loaded");
        fi;
        return true;
    end);
    

###########################################################################
##
#F  LoadAbsolutelyIrreducibleSolvableGroupData(<n>, <q>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (LoadAbsolutelyIrreducibleSolvableGroupData,
    function (n, q)
    
        if not IsPosInt (n) or not IsPosInt (q) or not IsPPowerInt (q)  then
            Error ("n and q must be positive integers and q must be a prime power");
        fi;
        
        if not TryLoadAbsolutelyIrreducibleSolvableGroupData (n, q) then
            Error ("Panic: missing data file for GL(",n,", ", q, ")");
        fi;
    end);
    

############################################################################
##
#F  LoadedAbsolutelyIrreducibleSolvableGroupData()
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (LoadedAbsolutelyIrreducibleSolvableGroupData,
    function ()
    
        local n, p, data, fields;
        
        data := [];
        for n in [1..Length (IRREDSOL_DATA.GROUPS)] do
            if IsBound (IRREDSOL_DATA.GROUPS[n]) then
                fields := [];
                for p in [1..Length (IRREDSOL_DATA.GROUPS[n])] do
                    if IsBound (IRREDSOL_DATA.GROUPS[n][p]) then
                        Add (fields, p);
                    fi;
                od;
                if not IsEmpty (fields) then
                    Add (data, [n, fields]);
                fi;
            fi;
        od;
        return data;
    end);
                        

############################################################################
##
#F  UnloadAbsolutelyIrreducibleSolvableGroupData([<n>[, <q>]])
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (UnloadAbsolutelyIrreducibleSolvableGroupData,
    function (arg)
    
        local UnbindIfBound;
        
        UnbindIfBound := function (arg)
            local data, i;
            
            data := arg[1];
            i := 2;
            while i < Length (arg)  do
                if not IsBound (data[arg[i]]) then
                    return false;
                fi;
                data := data[arg[i]];
                i := i + 1;
            od;
            if IsBound (data[arg[i]]) then
                Unbind (data[arg[i]]);
                return true;
            else
                return false;
            fi;
        end;
        
        if Length (arg) = 0 then
            IRREDSOL_DATA.GUARDIANS := [];
            IRREDSOL_DATA.GROUPS := [];
            IRREDSOL_DATA.GROUPS_LOADED := [];
            IRREDSOL_DATA.GAL_PERM := [];
            IRREDSOL_DATA.MAX := [];
            IRREDSOL_DATA.GROUPS_DIM1 := [];
            IRREDSOL_DATA.PRIM_GUARDIANS := [];
        elif IsPosInt (arg[1]) and Length (arg) = 1 then
            UnbindIfBound (IRREDSOL_DATA.GAL_PERM, arg[1]);
            UnbindIfBound (IRREDSOL_DATA.GUARDIANS, arg[1]);
            UnbindIfBound (IRREDSOL_DATA.PRIM_GUARDIANS, arg[1]);
            if arg[1] = 1 then
                UnbindGlobal ("IRREDSOL_DATA.GROUPS_DIM1");
                BindGlobal ("IRREDSOL_DATA.GROUPS_DIM1", []);
            else
                UnbindIfBound (IRREDSOL_DATA.GROUPS, arg[1]);
                UnbindIfBound (IRREDSOL_DATA.MAX, arg[1]);
            fi;
        elif Length (arg) = 2 and IsPosInt (arg[1]) and IsPPowerInt (arg[2]) then
            UnbindIfBound (IRREDSOL_DATA.GUARDIANS, arg[1], arg[2]);
            UnbindIfBound (IRREDSOL_DATA.PRIM_GUARDIANS, arg[1], arg[2]);
            UnbindIfBound (IRREDSOL_DATA.GAL_PERM, arg[1], arg[2]);
            if arg[1] = 1 then
                UnbindIfBound (IRREDSOL_DATA.GROUPS_DIM1, arg[2]);
            else
                UnbindIfBound (IRREDSOL_DATA.GROUPS, arg[1], arg[2]);
                UnbindIfBound (IRREDSOL_DATA.MAX, arg[1], arg[2]);
            fi;
        else
            Error ("Usage: `UnloadAbsolutelyIrreducibleSolvableGroupData ( [n [, q]] )'");
        fi;
    end);


############################################################################
##
#F  IsAvailableIrreducibleSolvableGroupData(<n>, <q>)
##
##  see IRREDSOL documentation
##  
InstallGlobalFunction (IsAvailableIrreducibleSolvableGroupData,
    function (n, q)
    
        local d;
        
        if not IsPosInt (n) or not IsPosInt (q) or not IsPPowerInt (q)  then
            Error ("n and q must be positive integers and q must be a prime power");
        fi;
        for d in DivisorsInt(n) do
            if not IsAvailableAbsolutelyIrreducibleSolvableGroupData (n/d, q^d) then
                return false;
            fi;
        od;
        return true;
    end);
    
    
############################################################################
##
#E
##

