#############################################################################
##
#W  allCubeFree.gi                Cubefree                    Heiko Dietrich
##                                                             
#H   @(#)$Id: allCubeFree.gi,v 1.2 2007/05/08 07:58:50 gap Exp $
##


##
## Difference to NumberCFGroups:
##
## These are the functions of the modified algorithm where the automorphism 
## groups AutGroupsGL2 and AutGroupsC are stored globally. This reduces
## runtime when constructing the solvable Frattini-free groups.
## Further, the number of the Frattini-free groups are stored for later 
## computations.
## The output format of AutGroupsGL2 and AutGroupsC has changed.
##

# to store globally 
cf_atGrps := [];

##############################################################################
##
#F  cf_AllAutGroupsGL2( p )
##
## Modified Version of AutGrpsGL2
##
cf_AllAutGroupsGL2 := function( p )
    local groups, lv, iso, inv, U, H, list, gen, imag, temp, new;

    Info(InfoCF,2,"    Start cf_AllAutGroupsGL2(",p,").");

    #computating of the subgroups
    if p>2 then
        groups := Concatenation(cf_Th42Red(p),cf_Th43(p),cf_Th41(p));
    else
       groups  := [];
       lv      := Group([[Z(2),0*Z(2)],[0*Z(2),Z(2)]]);
       lv!.red := true;
       Add(groups,lv);
       lv      := Group([[Z(2),Z(2)],[Z(2),Z(2)*0]]);
       lv!.red := false;
       Add(groups,lv);
    fi;

    #for technical reasons
    iso  := IsomorphismPermGroup(GL(2,p));
    imag := Image(iso);
    inv  := InverseGeneralMapping(iso);
    
    list := [GeneratorsOfGroup(imag),[inv]];
    new  := [];
    for U in groups do
        gen := GeneratorsOfGroup(U);
        gen := List(gen,x->Image(iso,x));
        if U!.red then
            temp := [gen,Size(U),[1,1]];
        else
            temp := [gen,Size(U),[2]];
        fi;
        Add(new,temp);  
    od; 
    Add(list,new);    
  
    #Output has the form
    #list:=[Generators(Imag),[inv], [ [gen,size,socleDim], ...] ]

    return(list);

end;


##############################################################################
##
#F  cf_AllAutGroupsC( p )
##
cf_AllAutGroupsC := function( p )
    local b, divs, lv, groups, gr, list, inv, iso, H, U, G, gen, imag,
          temp, new;

    Info(InfoCF,2,"    Start cf_AllAutGroupsC(",p,").");

    b      := GeneratorsOfGroup(GL(1,p))[1];
    divs   := DivisorsInt(p-1);
    divs   := Filtered(divs,x->IsCubeFreeInt(x));
    groups := [];

    for lv in divs do
        gr      := Group(b^((p-1)/lv));
        gr!.red := true;
        SetSize(gr,lv);
        Add(groups,gr);
    od;

    iso  := IsomorphismPermGroup(GL(1,p));
    imag := Image(iso);
    inv  := InverseGeneralMapping(iso);
    list := [GeneratorsOfGroup(imag),[inv]];
    new  := [];
    for U in groups do
        gen := GeneratorsOfGroup(U);
        gen := List(gen,x->Image(iso,x));
        if U!.red then
            temp := [gen,Size(U),[1,1]];
        else
            temp := [gen,Size(U),[2]];
        fi;
        Add(new,temp);  
    od; 
    Add(list,new);
 
    #Output has the form:
    #list:=[genImag,[inv], [ [gen,size,socleDim], ...] ]

    return(list);
end;  
 
##############################################################################
##
#F  cf_AllFrattFreeSolvGroups( n, middle )
##
## Modified version of FrattFreeSolvGroups
##
cf_AllFrattFreeSolvGroups := function( n, middle )
    local facN, facS, SocOrders, temp, lv, groups,s,ord,tempAutGr, H, new,
          subDP, socExt, sd, i, all, facNS, possible, imag, inv, L, lv2;

    Info(InfoCF,1,"Compute Frattini-free solvable groups of order ",n,").");

    groups := [];
    facN   := Collected(FactorsInt(n));

    # compute all socles s with n/|s| divides |Aut(s)|
    SocOrders := Filtered(DivisorsInt(n), x -> x>1 );
    temp := [];
    for s in SocOrders do
        facS := Collected(FactorsInt(s));
        # compute order(Aut(Soc))
        ord := 1;
        for lv in facS do
            if lv[2]=1 then
                ord := ord*(lv[1]-1);
            else
                ord := ord*(lv[1]*(lv[1]-1)^2*(lv[1]+1));
            fi;
        od;
        if ord mod (n/s) = 0 then
            Add(temp,s);
        fi;
    od;
    SocOrders := temp;

    # if p|(n/s) then p has to divide the order of a projection from the
    # socle complement K\leq Aut(socle) in a direct factor. Extract these
    # orders s:
    temp:=[];
    for s in SocOrders do
        possible := true;
        facS     := Collected(FactorsInt(s));
        facNS    := Collected(FactorsInt(n/s));
        ord      := 2;
        for lv in facS do
            if lv[2]=1 then
                ord := ord*(lv[1]-1);
            else
                ord := ord*(lv[1]^2-1);
            fi;
        od;
        for lv in facNS do
            if not ord mod lv[1] = 0 then
                possible:=false;
            fi;
        od;
        if possible then
            Add(temp,s);
        fi;
    od;
    SocOrders := temp;

    # for every socle compute a list of complements 
    for s in SocOrders do
        tempAutGr := [];
        facS      := Collected(FactorsInt(s));

        # if not stored before, compute all necessary aut.-groups
        for lv in facS do
            if lv[2]=1 then
                if cf_atGrps[lv[1]]=0 then
                    lv2 := cf_AllAutGroupsC(lv[1]);
                    # store globally
                    if lv[1]<middle then
                        cf_atGrps[lv[1]] := lv2;   
                    fi;
                else
                    lv2 := cf_atGrps[lv[1]];
                fi;
                L := lv2;

                # reconstruct the groups
                imag := Group(L[1]);
                inv  := L[2];
                temp := Filtered(L[3],x-> (n/s) mod x[2] =0);
                new  := [];;
                for i in temp do
                    H := Subgroup(imag,i[1]);
                    SetSize(H,i[2]);
                    SetProjections(H,inv);
                    SetSocleDimensions(H,i[3]);
                    Add(new,H);
                od;
                Add(tempAutGr,new);

            else
                if cf_atGrps[lv[1]^2]=0 then
                    lv2 := cf_AllAutGroupsGL2(lv[1]);
                    # store globally
                    if lv[1]^2<middle then
                        cf_atGrps[lv[1]^2] := lv2;  
                    fi;
                else
                    lv2 := cf_atGrps[lv[1]^2];
                fi;
                L := lv2;

                # reconstruct the groups
                imag := Group(L[1]);
                inv  := L[2];
                temp := Filtered(L[3],x-> (n/s) mod x[2] =0);
                new  := [];
                for i in temp do
                    H := Subgroup(imag,i[1]);
                    SetSize(H,i[2]);
                    SetProjections(H,inv);
                    SetSocleDimensions(H,i[3]);
                    Add(new,H);
                od;
                Add(tempAutGr,new);
            fi;
        od;

        #compute all subdirect product of tempAutGr of order n/s
        Info(InfoCF,2,"    Compute socle complements.");
        subDP := SocleComplements(tempAutGr,n/s);
        subDP := Filtered(subDP,x->Size(x)=n/s);
        Info(InfoCF,2,"    Compute extensions by socles.");
        for i in [1..Length( subDP )] do
            subDP[i] := ExtensionBySocle( subDP[i] );
        od;
        groups := Concatenation(groups,subDP);
       
    od;

    return(groups);
end;

############################################################################# 
## 
#F  CountAllCFGroupsUpTo( arg ) 
## 
InstallGlobalFunction(CountAllCFGroupsUpTo, function( arg ) 
    local cl, free, ext, t, pr, ffOrd, lv, nonAb, p, A, nSize, facNSize,
          groups, arg1, arg2, SolvFrattFree, numbers, temp, size, tm, t1, t2, 
          t3, lv2, middle, i, bound, smallGrp, numberGroups; 
    

    # check
    if Size(arg)=1 then 
        bound    := arg[1];
        smallGrp := true;
    elif Size(arg)=2 then
        bound    := arg[1];
        smallGrp := arg[2];
    else
        Error("Wrong input format: Either arg='size' or arg='size,bool'.\n");
    fi;
    if not IsPosInt(bound) then
        Error("First argument has to be a positiv integer.");
    fi;
    if not IsBool(smallGrp) then
        Error("Second argument has to be Boolean.\n");
    fi;

    Info(InfoCF,1,"Count all cubefree groups up to ",bound,".");

    # to store the number of all cube-free solvable Frattini-free groups
    SolvFrattFree := [1];
    
    # the upper bound of primes for which the automorphism groups are stored
    if bound mod 2 = 0 then
        middle := bound/2;
    else
        middle := (bound+1)/2;
    fi;

    # to store all computed automorphism groups of GL(2,p) and GL(1,p)
    cf_atGrps := ListWithIdenticalEntries( bound, 0 );
    
    #to store the number of computed groups
    numbers   := [1];

    for size in Filtered([2..bound],IsCubeFreeInt) do    
 
        Info(InfoCF,2,"    Count groups of order ",size,".");        

        # if size is squarefree
        # then groups of order size are solvable and Frattini-free
        if IsSquareFreeInt(size) then
            
            lv2 :=  NumberSmallGroups(size);
            if size<middle +1 then
                SolvFrattFree[size] := lv2;
            fi;
            numbers[size] := lv2;
            
        else
        
            if smallGrp and size<50001 then
                numberGroups := NumberSmallGroups(size);
            else
                # determine the possible non-abelian factors PSL(2,p)
                cl     := List(Collected( Factors( size ) ),x->x[1]); 
                cl     := Filtered(cl, x->IsCubeFreeInt(x+1) and
                                      IsCubeFreeInt(x-1) and x>3);
                cl     := List(cl,x-> x*(x+1)*(x-1)/2);
                cl     := Filtered(cl, x-> size mod x = 0);
                nonAb  := Concatenation([1],cl);

                numberGroups := 0;

                # for every non-abelian factor count the number of solvable
                # complements
                for A in nonAb do
               
                    nSize := size/A;
                    pr := Product(List(Collected(FactorsInt(nSize)),x->x[1]));

                    #determine the possible orders of frattini-factors
                    ffOrd  := Filtered(DivisorsInt(nSize),x-> x mod pr =0);
                    free   := 0;

                    #if not stored before, compute solvable FF groups
                    for lv in ffOrd do
                        if IsBound(SolvFrattFree[lv]) then
                            free := free + SolvFrattFree[lv];
                        else
                            if smallGrp and lv<50001 then
			        if IsOddInt(lv) then
                                    tm := Size(Filtered(
                                       [1..NumberSmallGroups(lv)],
                                        x->FrattinifactorSize(SmallGroup(lv,x))
                                        =lv));
                                else
                                    tm := Size(Filtered(
                                       [1..NumberSmallGroups(lv)],
                                        x->FrattinifactorSize(SmallGroup(lv,x))
                                        =lv and IsSolvable(SmallGroup(lv,x))));
                                fi;
                            else
                                tm := Size(cf_AllFrattFreeSolvGroups(
                                           lv,middle));
                            fi;
                            SolvFrattFree[lv] := tm;
                            free := free + tm;
                        fi;
                   
                    od;
   
                    numberGroups := numberGroups + free;
                od;
            fi;

            numbers[size] := numberGroups;
        fi;
    od;

    cf_atGrps := [];
    return numbers; 
end ); 
