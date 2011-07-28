############################################################################
##
##  iterators.gi                   IRREDSOL                 Burkhard Höfling
##
##  @(#)$Id: iterators.gi,v 1.7 2011/04/07 07:58:09 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


############################################################################
##
#F  SelectionIrreducibleSolvableMatrixGroups(n, q, d, indices, orders, blockdims, max)
##
##  selects the subset of <indices> corresponding to those irreducible 
##  matrix gropus whose orders are in <orders>, whose minimal block dims are in 
##  <blockdims>. if max is true and d = 1, only the maximal solvable groups are returned,
##  if max is false, the non-maximal ones are returned. 
##  To ignore one of the parameters orders, blockdims, max, set it to fail
##  If <indices> is fail, all groups are considered.
##  
InstallGlobalFunction (SelectionIrreducibleSolvableMatrixGroups,
    function (n0, q0, d, indices, orders, blockdims, max)
    
        local n, q, p, descs, gddescs, i;
        
        n := n0/d;
        q := q0^d;
        
        # info comes from GL(n, q)
        
        
        LoadAbsolutelyIrreducibleSolvableGroupData (n, q);
        
        if indices = fail then
            indices := IndicesIrreducibleSolvableMatrixGroups (n0, q0, d);
        else 
            indices := Intersection (indices, IndicesIrreducibleSolvableMatrixGroups (n0, q0, d));
        fi;
        
        if n = 1 then # from groups of degree 1 - defer to orders

            descs := IRREDSOL_DATA.GROUPS_DIM1 [q];
		 
            
		 # evaluate max
        
            if max <> fail then
                if d > 1 then
                    Error ("maximality information not available for groups which are not absolutely irreducible");
                fi;
            
			if max then
			    if Length(descs) in indices then
				  indices := [Length(descs)];
			    else
			        RemoveSet (indices, Length (descs));
                    fi;
			fi;
            fi;
            
          
		 # now look at orders
            if orders <> fail then
                indices := Filtered (indices, i -> descs[i][1] in orders);
            fi;
		 
            # block dims
            
            if blockdims <> fail then
                if d = 1 then
                    if not 1 in blockdims then
                        indices := [];
                    fi;
                else
                    p := SmallestRootInt (q0);
                    i := PositionSet (DivisorsInt (LogInt (q, p)), LogInt (q0, p));
                    indices := Filtered (indices, k -> descs[k][2][i] in blockdims);
                fi;
            fi;
            
        else # n > 1
        
            # evluate max
            
            if max <> fail then
                if max then
                    indices := Intersection (indices, IRREDSOL_DATA.MAX[n][q]);
                else
                    indices := Difference (indices, IRREDSOL_DATA.MAX[n][q]);
                fi;
            fi;
                
            descs := IRREDSOL_DATA.GROUPS[n][q];
            gddescs := IRREDSOL_DATA.GUARDIANS[n][q];
            
            if orders <> fail then
                indices := Filtered (indices, i -> descs[i][4] in orders);
            fi;
            
            if blockdims <> fail then
                if d = 1 then
                    indices := Filtered (indices, i -> gddescs[descs[i][1]][4] in blockdims);
                else
                    p := SmallestRootInt (q0);
                    i := PositionSet (DivisorsInt (LogInt (q, p)), LogInt (q0, p));
                    indices := Filtered (indices, k -> descs[k][3][i] in blockdims);
                fi;
            fi;
        fi;
        
        MakeImmutable (indices);
        return indices;
    end);


############################################################################
##
#F  OrdersAbsolutelyIrreducibleSolvableMatrixGroups(n, q, blockdims, max)
##
##  returns a set. Each entry is a pair [order, count] describing how many
##  groups of that order are in the data base whose minimal block dims are in <blockdims>
##  if max is true, only the maximal solvable groups are counted, if max is
##  false, the non-maximal ones are returned. 
##  To ignore one of the parameters blockdims, max, set it to fail
##  
InstallGlobalFunction (OrdersAbsolutelyIrreducibleSolvableMatrixGroups,
    function (n, q, blockdims, max)
    
        local orders, descs, guardianDescs, desc, guardianDesc, grpinds, i, j, grp, o;
    
        LoadAbsolutelyIrreducibleSolvableGroupData (n,q);
        
        if n = 1 then
            if blockdims <> fail and not 1 in blockdims then
                return [];
            fi;
            if max = true then
                return [[IRREDSOL_DATA.GROUPS_DIM1 [q][Length (IRREDSOL_DATA.GROUPS_DIM1 [q])][1],1]];
            else
                orders :=  List (IRREDSOL_DATA.GROUPS_DIM1 [q], d -> [d[1],1]);
                if max = false then
                    Unbind (orders[Length (orders)]);
                fi;
                return orders;
            fi;
        fi;
        
        descs := IRREDSOL_DATA.GROUPS[n][q];
        guardianDescs := IRREDSOL_DATA.GUARDIANS[n][q];
        if max = true then
            grpinds := IRREDSOL_DATA.MAX[n][q];
        elif max = false then
            grpinds := Difference ([1..Length (descs)], IRREDSOL_DATA.MAX[n][q]);
        else
            grpinds := [1..Length (descs)];
        fi;
        
        orders := [];

        for i in grpinds do
            desc := descs[i]; # description of group
            guardianDesc := guardianDescs[desc[1]]; # and corresponding guardian
            grp := Source (guardianDesc[3]); # pc group isomorphic with guardian
            if (blockdims = fail or guardianDesc[4] in blockdims) then
                o := OrderGroupByCanonicalPcgsByNumber (FamilyPcgs (grp), desc[2]);
                j := PositionSorted (orders, [o,1], function (a, b) return a[1] < b[1]; end);
                if IsBound (orders[j]) and orders[j][1] = o then
                    orders[j][2] := orders[j][2] + 1;
                else
                    Add (orders, [o,1], j);
                fi;
            fi;
        od;
        return orders;
    end);


############################################################################
##
#F  CheckAndExtractArguments(specialfuncs, checks, argl, caller)
##
##  This function tests whether argl is a list of even length in which the 
##  entries at odd positions are functions.
##  For special functions in this list (each entry in specialfuncs is a list of synonyms
##  of such functions) it tests whether the following entry in argl satisfies the 
##  function in checks corresponding to specailfunc, and that each specialfunc
##  only occurs once (including synonyms).
##
##  The function returns a record with entries specialvalues, functions, and values.
##  if specialvalues[i] is bound, it was the entry following a function in 
##  specialfuncs[i]. The functions at odd positions in argl but not in specialfuncs 
##  are returned in the record entry functions,
##  the following entries in argl are in the record entry values.
##
InstallGlobalFunction (CheckAndExtractArguments,
    function (specialfuncs, argl, caller)
    
        local funcs, vals, specialvals, i, f, j;
        
        if Length (argl) mod 2 <> 0 then
            Error ("number of arguments of `", caller, "' must be even");
        fi;
        funcs := [];
        vals := [];
        specialvals := [];
        for i in [1,3..Length (argl)-1] do
            f := argl[i];
            if not IsFunction (f) then
                Error (i, "-th argument in function `", caller, "' must be a function");
            fi;
            if IsHomogeneousList (argl[i+1]) then
                argl[i+1] := Set (argl[i+1]);
            elif IsList (argl[i+1]) then
                argl[i+1] := ShallowCopy (argl[i+1]);
            else
                argl[i+1] := [argl[i+1]];
            fi;
            j := PositionProperty (specialfuncs, funclist -> f in funclist[1]);
            if j = fail then
                Add (funcs, f);
                Add (vals, argl[i+1]);
            elif IsBound (specialvals[j]) then
                Error ("there may be only one occurrence of ", f, " in `", caller, "'");
            else
                if not ForAll (argl[i+1], x -> specialfuncs[j][2](x)) then
                    Error ("inadmissible value for argument ", i+1, " in `", caller, "'");
                fi;
                specialvals[j] := argl[i+1];
            fi;
        od;
        return rec (specialvalues := specialvals, functions := funcs, values := vals);
    end);


############################################################################
##
#F  IteratorIrreducibleSolvableMatrixGroups(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (IteratorIrreducibleSolvableMatrixGroups,
    function (arg)
    
        local r, p, q, k, iter, primes;
    
        r := CheckAndExtractArguments ([
                [[Degree, DegreeOfMatrixGroup, Dimension, DimensionOfMatrixGroup], IsPosInt],
                [[Characteristic, CharacteristicOfField], p -> IsPosInt (p) and IsPrimeInt (p)],
                [[Field, FieldOfMatrixGroup, TraceField], F -> IsField (F) and IsFinite (F)],
                [[Order, Size], IsPosInt],
                [[MinimalBlockDimension, MinimalBlockDimensionOfMatrixGroup], IsPosInt],
                 [[IsPrimitive, IsPrimitiveMatrixGroup, IsLinearlyPrimitive], x -> x in [true, false]],
                [[IsMaximalAbsolutelyIrreducibleSolvableMatrixGroup], x -> x in [true, false]],
                [[IsAbsolutelyIrreducibleMatrixGroup, IsAbsolutelyIrreducible], x -> x in [true, false]],
                [[SplittingField], F -> IsField (F) and IsFinite (F)]
            ], 
            arg, 
            "IteratorIrreducibleSolvableMatrixGroups");
        
        if ForAny (r.specialvalues, v -> IsEmpty (v)) then
            return Iterator ([]);
        fi;

        if not IsBound (r.specialvalues[1]) then 
            Error ("IteratorIrreducibleSolvableMatrixGroups: You must specify the degree(s) of the desired matrix groups");
        fi;
        
        if not IsBound (r.specialvalues[3]) then 
            Error ("IteratorIrreducibleSolvableMatrixGroups: You must specify the field(s) of the desired matrix groups");
        fi;
        
        # set up data for the iterator record
        
        iter := rec ();
        if Length (r.functions) > 0 then
            iter.testfuncs := r.functions;
            iter.testvals := r.values;
        else
            iter.testfuncs := fail;
        fi;
        
        iter.dims := r.specialvalues[1];
        
        if IsBound (r.specialvalues[2]) then # if field characteristic is given
            iter.qs := Filtered (r.specialvalues[3], field -> SmallestRootInt (Size(field)) in r.specialvalues[2]);
        else
            iter.qs := List (r.specialvalues[3], Size);
        fi;
        
        if IsBound (r.specialvalues[4]) then
            iter.orders := r.specialvalues[4];
        else
            iter.orders := fail;
        fi;
        
        if IsBound (r.specialvalues[5]) then
            iter.blockdims := r.specialvalues[5];
        else
            iter.blockdims := fail;
        fi;
        
        if IsBound (r.specialvalues[6]) then
            if Length (r.specialvalues[6]) = 1 then
                iter.primitive := r.specialvalues[6][1];
            else
                Info (InfoWarning, 2, "IteratorIrreducibleSolvableMatrixGroups: `IsPrimitiveMatrixGroup' is redundant - will be ignored");
                iter.primitive := fail;
            fi;
        else
            iter.primitive := fail;
        fi;
        
        if IsBound (r.specialvalues[7]) then
            if Length (r.specialvalues[7]) > 1 then
                Info (InfoWarning, 2, "IteratorIrreducibleSolvableMatrixGroups: `IsMaximalAbsolutelyIrreducibleSolvableMatrixGroup' is redundant");
                iter.max := fail;
            else
                iter.max := r.specialvalues[7][1];
            fi;
        else
            iter.max := fail;
        fi;
        
        if IsBound (r.specialvalues[8]) then
            if Length (r.specialvalues[8]) > 1 then
                Info (InfoWarning, 2, "IteratorIrreducibleSolvableMatrixGroups: `IsAbsolutelyIrreducibleSolvableMatrixGroup' is redundant");
                iter.absirred := fail;
            else 
                iter.absirred := r.specialvalues[8][1];
                if iter.max = true and iter.absirred = false then
                    Info (InfoWarning, 2, "IteratorIrreducibleSolvableMatrixGroups: values of `IsMaximalAbsolutelyIrreducibleSolvableMatrixGroup' ",
                        "and `IsAbsolutelyIrreducibleSolvableMatrixGroup' contradict each other");
                    return Iterator([]);
                fi;
            fi;
        else
            iter.absirred := fail;
        fi;
        
        if IsBound (r.specialvalues[9]) then
            iter.split := List (r.specialvalues[9], Size);
        else
            iter.split := fail;
        fi;
        
        if iter.max = true then
            iter.absirred := true;
        fi;
        
        # set up start position in iterator, always points to data of next group to read
        # if pos is outside indices, then the next value for d, dim and/or q has to be loaded
        # we mark both iter.d and iter.indices as empty, so that they will be reloaded
        # during the first call to IsDoneIterator
        
        iter.qi := 1;
        iter.dimi := 0;        # this gets incremented during the first call of IsDoneIterator
                                    # which will also load the data for iter.d and iter.indices
        iter.d := [];
        iter.di := 1;          # mark iter.d as empty 
        iter.pos := 1;
        iter.indices := [];  # mark iter.indices as empty
        
        # add iterator methods
        
        iter.IsDoneIterator := function (iterator)
        
            # In order for IsDoneIterator to work in this case, we actually have to look
            # for a new group. If we find a group, it is stored for NextIterator
    
            local blockdims, dim, divs, d, q, min, max, G, H, gensH, repH, gensG, repG;
            
            # as a safety measure, make sure that IsDoneIterator can be called 
            # after it has returned `true'
            
            if iterator!.qi > Length (iterator!.qs) then
                return true;
            fi;

            # find next group

            while not IsBound (iterator!.nextGroup) do
                while iterator!.pos > Length (iterator!.indices) do

                    iterator!.di := iterator!.di + 1;
                    while iterator!.di > Length (iterator!.d) do
                                            
                        # next dimension
                        iterator!.dimi := iterator!.dimi + 1;
    
                        if iterator!.dimi > Length (iterator!.dims) then
                            iterator!.dimi := 1;
                            iterator!.qi := iterator!.qi + 1;
                            if iterator!.qi > Length (iterator!.qs) then
                                return true;
                            fi;
                        fi;
                        
                        Info (InfoIrredsol, 1, "searching subgroups of GL(", iterator!.dims[iterator!.dimi], ", ",
                            iterator!.qs[iterator!.qi], ")");
                            
                        # we have a new dimension, store its divisors
                        iterator!.divsdim := DivisorsInt (iterator!.dims[iterator!.dimi]);
                                            
                        # set up degrees of splitting field for the construction of groups which are not absolutely irreducible

                        iterator!.di := 1;
                        if iterator!.absirred = true then
                            if iterator!.split = fail or iterator!.qs[iterator!.qi] in iterator!.split then
                                iterator!.d := [1];
                            else
                                iterator!.d := [];
                            fi;
                        else
                            if iterator!.split = fail then
                                iterator!.d := ShallowCopy (iterator!.divsdim);
                            else
                                q := iterator!.qs[iterator!.qi];
                                iterator!.d := Filtered (iterator!.divsdim, t -> q^t in iterator!.split);
                            fi;
                            if iterator!.absirred = false then
                                RemoveSet (iterator!.d, 1);
                            fi;
                        fi;        
                    od;
                    
                    dim := iterator!.dims[iterator!.dimi];                        
                    q := iterator!.qs[iterator!.qi];                    
                    
                    # get relevant indices for new values of n, q, and d
                    
                    d := iterator!.d[iterator!.di];
                    
                    # merge information about block dims and primitivity
                                        
                    if iterator!.primitive = true then
                        if iterator!.blockdims = fail or dim in iterator!.blockdims then
                            blockdims := [dim];
                        else
                            continue;
                        fi;
                    else
                        if iterator!.blockdims = fail then
                            blockdims := ShallowCopy (iterator!.divsdim);
                        else
                            blockdims := Intersection (iterator!.divsdim, iterator!.blockdims);
                        fi;
                        if iterator!.primitive = false then 
                            RemoveSet (blockdims, dim);
                        fi;
                    fi;
                    
                    if d = 1 then #absolutely irreducible case
                        max := iterator!.max;
                    elif iterator!.max = true then
                        Error ("internal error: iterator!.max is true but trying to construct groups which are not abs. irred");
                    else
                        max := fail;
                    fi;
                        
                        
                    Info (InfoIrredsol, 2, "searching subgroups of GL(", dim, ", ", q, ")", 
                            " with splitting field GF(",q, "^",d,"), orders: ", iterator!.orders, 
                            " and block dims ", blockdims, " max = ", max);
                            
                    if IsAvailableAbsolutelyIrreducibleSolvableGroupData (dim/d, q^d) then
                        iterator!.indices := SelectionIrreducibleSolvableMatrixGroups (
                            dim, q, d, fail, iterator!.orders, blockdims, max);
                    else
                        Error ("group data for GL(", dim/d, ", ",q^d,") is not available. Type \'return;\' to skip these subgroups.");
                        iterator!.indices :=  [];
                    fi;
                    iterator!.pos := 1;
                od;
                G := IrreducibleSolvableMatrixGroup (
                    iterator!.dims[iterator!.dimi], 
                    iterator!.qs[iterator!.qi],    
                    iterator!.d[iterator!.di], 
                    iterator!.indices[iterator!.pos]);
                iterator!.pos := iterator!.pos + 1;
                
                if iterator!.testfuncs = fail or ForAll ([1..Length (iterator!.testfuncs)], i -> iterator!.testfuncs[i](G) in iterator!.testvals[i]) then
                    iterator!.nextGroup := G;
                fi;
            od;
            return false;
        end;
        iter.NextIterator := function (iterator)        
        
            local G;
        
            if IsDoneIterator (iterator) then
                Error ("iterator already at its end");
            else
                G := iterator!.nextGroup;
                Unbind (iterator!.nextGroup);
                return G;
            fi;
        end;
        iter.ShallowCopy := function (iterator)
    
                local r;
        
                # we need not copy lists in iterator, since these are never changed in place
                # and are not documented
        
                r := rec (
                    IsDoneIterator := iterator!.IsDoneIterator,
                    NextIterator := iterator!.NextIterator,
                    ShallowCopy := iterator!.ShallowCopy,
                    dims := iterator!.dims,
                    dimi := iterator!.dimi,
                    qs := iterator!.qs,
                    qi := iterator!.qi,
                    indices := iterator!.indices,
                    pos := iterator!.pos,
                    d := iterator!.d,
                    di := iterator!.di,
                    split := iterator!.split,
                    orders := iterator!.orders,
                    max := iterator!.max,
                    primitive := iterator!.primitive,
                    blockdims := iterator!.blockdims,
                    absirred := iterator!.absirred,
                    testfuncs := iterator!.testfuncs,
                    testvals := iterator!.testvals);
                    
                if IsBound (iterator!.nextGroup) then
                    r.nextGroup := iterator!.nextGroup;
                fi;
                if IsBound (iterator!.divsdim) then
                    r.divsdim := iterator!.divsdim;
                fi;
                
                return     r;
            end;
        return IteratorByFunctions (iter);
    end);
    

############################################################################
##
#F  OneIrreducibleSolvableMatrixGroup(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (OneIrreducibleSolvableMatrixGroup,
    function (arg)
    
        local iter;
        
        iter := CallFuncList (IteratorIrreducibleSolvableMatrixGroups, arg);
        if IsDoneIterator (iter) then
            return fail;
        else 
            return NextIterator (iter);
        fi;
    end);
    
    
############################################################################
##
#F  AllIrreducibleSolvableMatrixGroups(<func_1>, <val_1>, ...)
##
##  see the IRREDSOL manual
##  
InstallGlobalFunction (AllIrreducibleSolvableMatrixGroups,
    function (arg)
    
        local iter, l, G;
        
        iter := CallFuncList (IteratorIrreducibleSolvableMatrixGroups, arg);
        
        l := [];
        for G in iter do
            Add (l, G);
        od;
        return l;
    end);
        

############################################################################
##
#E
##  

