#############################################################################
##
#W  frattFree.gi           Cubefree                            Heiko Dietrich
##                                                              
#H   @(#)$Id: frattFree.gi,v 1.2 2007/05/08 07:58:50 gap Exp $
##

##
## These are the functions to construct all Frattini-free groups of
## a given cube-free order up to isomorphism.
##

##############################################################################
##
#F  cf_Th41( p )
##
##  Theorem 4.1 of Flannery and O'Brien (cube-free case).
##
cf_Th41 := function( p )
    local b, div, groups, lv, gr, K, prEl, prElp;

    Info(InfoCF,3,"      Start cf_Th41.");

    groups := [];
    K      := GF(p^2);
    prEl   := PrimitiveElement(K);
    prElp  := prEl^(p+1);

    # compute all possible orders
    div := DivisorsInt(p^2-1);
    div := Filtered(div,x->IsCubeFreeInt(x) and (not x mod p =0)
                           and (not (p-1) mod x = 0) and x>1);

    # generator of singer-cycle
    b := [[0*prElp,prElp^0],[-prEl^(p+1),prEl+prEl^p]];

    # construct groups
    for lv in div do
        gr := Group(b^((p^2-1)/lv));
        SetSize(gr,lv);
        Add(groups,gr);
    od;

    # for technical reasons
    for lv in [1..Size(groups)] do
        groups[lv]!.red := false;
    od;

    return(groups);
end;
    

##############################################################################
##
#F  cf_Th42Red( p )
##
## Theorem 4.2 of Flannery and O'Brien (cube-free case) and the 
## required cube-free reducible subgroups of GL(2,p)
##
cf_Th42Red := function( p )
    local a, temp, h001, h002, groups, Gstrich, Gnsk, w, z0, z1, C2, aMat,
          G1, G2, G, norm, erz1, erz2, reducible, b, M, C, D, d, nat, 
          sub, K, k, g, act, i, IsScalarGS, ppos, makeMat;

    Info(InfoCF,3,"      Start cf_Th42Red.");

    # auxiliary function
    IsScalarGS := function(L) 
    local g;
 
        for g in L do
            if not g[1][1]=g[2][2] then
                 return(1=2);
            fi;
        od;
        return(1=1);
    end;

    makeMat := function(v,p)
    local mat,i;

        mat    := [];
        mat[1] := v{[1..2]};
        mat[2] := v{[3..4]};
        return mat*One(GF(p));
    end;

   
    # the reducible groups 
    # if p<100 then the reducible subgroups are stored
    if p<100 then

        ppos      := Position(Primes,p)-1;
        reducible := List(cf_diagonalMatrices[ppos][1], x->
                                          Group(List(x,y->makeMat(y,p))));
        norm      := List(cf_diagonalMatrices[ppos][2], x->
                                          Group(List(x,y->makeMat(y,p))));
        for i in [1..Size(reducible)] do
            reducible[i]!.red := true;
        od;
        for i in [1..Size(norm)] do
            norm[i]!.red := false;
        od;

    else
        
        Info(InfoCF,4,"            Compute reducible subgroups.");

        # set up
        a   := [[Z(p),0],[0,1]]*One(GF(p));
        b   := [[1,0],[0,Z(p)]]*One(GF(p));
        M   := Group([a,b]);
        C   := CyclicGroup(p-1);
        D   := DirectProduct(C,C);
        d   := Filtered(GeneratorsOfGroup(D),x->Order(x)=p-1);
        sub := SubgroupsSolvableGroup(D);
        sub := Filtered(sub,x->IsCubeFreeInt(Order(x)));
    
        # orbits
        K   := CyclicGroup(2);
        k   := GeneratorsOfGroup(K);
        g   := [GroupHomomorphismByImages(D,D,d,[d[2],d[1]])];
        act := function(pt,elm)return Image(elm,pt);end;
        sub := Orbits(K,sub,k,g,act);

        # extract the subgroups of D(2,p) normal in M(2,p)
        norm := Filtered(sub,x->Size(x)=1);
        norm := List(norm,x->x[1]);
  
        sub  := List(sub,x->x[1]);
   
        # add matrices
        nat := GroupHomomorphismByImagesNC(D,M,d,[a,b]);
        for i in [1..Length(sub)] do
            sub[i]      := Image(nat,sub[i]);
            sub[i]!.red := true;
            SetSize(sub[i],Size(sub[i]));
        od;
    
        norm := Filtered(norm, x->not Order(x) mod 2=0 
                                  and not Order(x) mod p=0);
        norm := List(norm,x->Image(nat,x));
    
        reducible := sub;
 
    fi;
   
    
    # begin of Th 4.2
    groups  := [];
    a       := [[0*Z(p),Z(p)^0],[Z(p)^0,0*Z(p)]];
    Gstrich := norm;
    
    if p mod 4 =1 then

        # groups
        z0   := Z(p)^((p-1)/2);
        z1   := Z(p)^((p-1)/4);
        w    := [[z0,0*Z(p)],[0*Z(p),(z0)^-1]];
        h001 := Group([a,w,[[z0,0*Z(p)],[0*Z(p),z0]]]);
        h002 := Group([a*[[z1,0*Z(p)],[0*Z(p),z1]],w]);
        
        # the list Gnsk of groups if G2' is not scalar
        Gnsk := [Group(a)];
        Add(Gnsk,h001);
        Add(Gnsk,h002);
       
        for G1 in Gstrich do
            erz1 := GeneratorsOfGroup(G1);

            if Order(G1)=1 then
                G := [[[1,0],[0,1]]];
            else
                G := erz1;
            fi;

            if not IsScalarGS(G) then
                for G2 in Gnsk do
                    erz2 := GeneratorsOfGroup(G2);
                    Add(groups,Group(Concatenation(erz1,erz2)));
                od;
            fi; 

        od;
     
    # the case p mod 4 = 3   
    else 
       
        # the list Gnsk of groups if G2' is not scalar
        Gnsk := [Group(a)];
        temp := Group(a,[[-Z(p)^0,0*Z(p)],[0*Z(p),-Z(p)^0]]);
        Add(Gnsk,temp); 
        temp := Group(a*[[Z(p)^0,0*Z(p)],[0*Z(p),-Z(p)^0]]);
        Add(Gnsk,temp); 

        for G1 in Gstrich do
            erz1 := GeneratorsOfGroup(G1);

            if Order(G1)=1 then
                G := [[[1,0],[0,1]]];
            else
                G := erz1;
            fi;
           
            if not IsScalarGS(G) then
                for G2 in Gnsk do
                    erz2 := GeneratorsOfGroup(G2);
                    Add(groups,Group(Concatenation(erz1,erz2)));
                od;
            fi; 

        od;
    fi;
   
   for i in [1..Size(groups)] do
       groups[i]!.red := false;
   od;
   return(Concatenation(reducible,groups));
end;

##############################################################################
##
#F  cf_Th43( p )
##
## Theorem 4.3 of Flannary and O'Brien (cube-free case)
##
cf_Th43 := function(p)
    local b, c, temp, groups, lv, Zent, t, l, div, erz1, el, order, G,
          gr, A, center, k, ord, r, K, prEl, prElp, one, i, m, mat;

    Info(InfoCF,3,"      Start cf_Th43.");
    K      := GF(p^2);
    prEl   := PrimitiveElement( K );
    prElp  := prEl^(p+1);
    one    := One( K );
    groups := [];
    mat    := [[prElp,0*prElp],[0*prElp,prElp]];
    Zent   := Group(mat);
    SetSize(Zent,p-1);
  
    # generator of singer-cycle
    b      := [[0,1],[-(prEl^(p+1)),prEl+prEl^p]]*one;

    # element c with <c,b> = normalizer of singer-cycle
    c      := [[1,0],[prEl+prEl^p,-(prElp^0)]]*one;    

    t      := Collected(FactorsInt(p-1))[1][2];
    l      := (p-1) / (2^t);
    div    := DivisorsInt(p^2-1);

    # compute groups of the form <c,\hat{A}>
    temp := Filtered(div,x-> (not (2*(p-1)) mod x =0) and IsCubeFreeInt(x));
    temp := Filtered(temp,x-> not x mod p =0);
    temp := Filtered(temp,x-> not x mod 4 =0); 
    G    := Group([b,c]);
    SetSize(G,p^2-1);
    
    # set size of groups
    for lv in temp do
        gr := Group(c,b^((p^2-1)/lv));
        SetSize(gr,2*lv);
        Add(groups,gr);
    od;

    # compute groups of the form <cb^(...),\tilde(A)>
    temp := Filtered(div,x-> (not x mod p =0) and (not x mod 4 =0));
    temp := Filtered(temp,x-> (not (p-1) mod x =0) and IsCubeFreeInt(x));
    temp := Filtered(temp,x -> 
                          not x mod 2^(Collected(FactorsInt(p^2-1))[1][2])=0);
    

    for lv in temp do
        el := b^((p^2-1)/lv);
        A  := Group(el);
        SetSize(A,lv);

        Info(InfoCF,4,"            Compute order of intersection.");
        #r := DivisorsInt(lv);
        #r := First(r,x->el^x in Zent);
        r  := DivisorsInt(lv);
        for i in r do
            m := el^i;
            if IsDiagonalMat(m) and m[1][1]=m[2][2] and 
               not First([1..p-1],x->mat[1][1]^x=m[1][1]) = fail then
                r := i;
                break;    
            fi;
        od;  
           
        order := lv/r;
       
        if order mod 4 =2 then
            k    := 1;
            erz1 := c*b^(2^(t-k)*l);
            gr   := Group([erz1,el]);
            SetSize(gr,2*lv);
            Add(groups,gr);     
        fi;
       
    od;

    # for technical reasons
    for lv in [1..Size(groups)] do
       groups[lv]!.red := false;
    od;

    return(groups);
    
end; 


##############################################################################
##
#F  cf_AutGroupsGL2( p )
##
## Returns the cube-free subgroups U of GL(2,p) with p \nmid |U|
## up to conjugacy
##
cf_AutGroupsGL2 := function( p )
    local groups, lv, iso, inv, U, H, list, gen, imag;

    Info(InfoCF,2,"  Start cf_AutGroupsGL2(",p,").");

    # computing the subgroups
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

    # for technical reasons
    iso  := IsomorphismPermGroup(GL(2,p));
    imag := Image(iso);
    inv  := InverseGeneralMapping(iso);
    list := [];
    for U in groups do
        gen := GeneratorsOfGroup(U);
        gen := List(gen,x->Image(iso,x));
        H   := Subgroup(imag,gen);
        SetSize(H,Size(U));
        SetProjections(H,[inv]);
        if U!.red then
            SetSocleDimensions(H,[1,1]);
        else
            SetSocleDimensions(H,[2]);
        fi;
        Add(list,H);
    od; 
    
    return(list);
end;


##############################################################################
##
#F  cf_AutGroupsC( p )
##
## Computes the cube-free subgroups U of Z(GL(2,p))\cong C_{p-1} 
##
cf_AutGroupsC := function( p )
    local b, divs, lv, groups, gr, list, inv, iso, H, U, G, gen, imag;

    Info(InfoCF,2,"  Start cf_AutGroupsC(",p,").");

    # set up
    b      := GeneratorsOfGroup(GL(1,p))[1];
    divs   := DivisorsInt(p-1);
    divs   := Filtered(divs,x->IsCubeFreeInt(x));
    groups := [];

    # computing the subgroups
    for lv in divs do
        gr      := Group(b^((p-1)/lv));
        gr!.red := true;
        Add(groups,gr);
    od;

    # for technical reasons
    iso  := IsomorphismPermGroup(GL(1,p));
    imag := Image(iso);
    inv  := InverseGeneralMapping(iso);
    list := [];
    for U in groups do
        gen := GeneratorsOfGroup(U);
        gen := List(gen,x->Image(iso,x));
        H   := Subgroup(imag,gen);
        SetSize(H,Size(U));
        SetProjections(H,[inv]);
        if U!.red then
            SetSocleDimensions(H,[1,1]);
        else
            SetSocleDimensions(H,[2]);
        fi;
        Add(list,H);
    od; 

    return(list);
end;  
 
##############################################################################
##
#F  cf_FrattFreeSolvGroups( n )
##
## Returns all solvable Frattini-free groups of order n up to isomorphism
##
cf_FrattFreeSolvGroups := function( n )
    local facN, facS, SocOrders, temp, lv, groups, autGrps, s, ord, tempAutGr,
          subDP, socExt, sd, i, all, facNS, possible, pos, autPos;
   
    Info(InfoCF,1,"Compute solvable Frattini-free groups of order ",n,".");

    groups := [];
    facN   := Collected(FactorsInt(n));

    # to store all necessary automorphism groups
    autPos := [];
    for lv in facN do
        Add(autPos,lv[1]);
        if lv[2]=2 then
            Add(autPos,lv[1]^2);
        fi;
    od;
    autGrps := ListWithIdenticalEntries( Length( autPos ), 0 );
    pos     := function(x) return Position( autPos, x); end;

    # compute all socles s with n/|s| divides |Aut(s)|
    SocOrders := Filtered(DivisorsInt(n),x->x>1);
    temp      := [];
    for s in SocOrders do
        facS  := Collected(FactorsInt(s));
        # compute size of Aut(Soc)
        ord   := 1;
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
    
    # if S is is a socle with size s and p|(n/s), then p has to divide the 
    # order of a projection of a direct factor of the socle complement
    # K\leq Aut(S). Hence extract all these possible socle orders:
    temp := [];
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
                possible := false;
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

        if s < n then

            # if not stored before, compute all necessary aut.-groups
            for lv in facS do 

                if lv[2]=1 then
                    if autGrps[pos(lv[1])]=0 then
                        autGrps[pos(lv[1])] := cf_AutGroupsC(lv[1]);
                    fi;
                    temp := Filtered(autGrps[pos(lv[1])],
                                      x-> (n/s) mod Size(x) =0);
                    Add(tempAutGr,temp);
                else
                    if autGrps[pos(lv[1]^2)]=0 then
                        autGrps[pos(lv[1]^2)] := cf_AutGroupsGL2(lv[1]);
                    fi;
                    temp := Filtered(autGrps[pos(lv[1]^2)],
                                       x->(n/s) mod Size(x)=0);
                    Add(tempAutGr,temp);
                fi;

            od;

            # compute all subdirect products of tempAutGr of order n/s
            Info(InfoCF,2,"    Compute socle complements.");
            subDP := SocleComplements(tempAutGr,n/s);
            subDP := Filtered(subDP,x->Size(x)=n/s);
            Info(InfoCF,2,"    Compute extensions by socle.");
            for i in [1..Length( subDP )] do
                subDP[i] := ExtensionBySocle( subDP[i] );
            od;
            groups := Concatenation(groups,subDP);

        # the case s=size
        else 
            lv     := AbelianGroup(FactorsInt(s));
            groups := Concatenation(groups,[rec(code  := CodePcGroup(lv),
                                                order := s,
                                                isFrattiniFree := true,
                                                extdim         := [],
                                                isUnique       := true)]);
        fi;
    od;

    return(groups);
end;


##############################################################################
##
#F  ConstructAllCFFrattiniFreeGroups( n )
##
## Returns all Frattini-free groups of order n up to isomorphism
##
InstallGlobalFunction( ConstructAllCFFrattiniFreeGroups, function( n )
    local nonAb, G, p, cl, A, nSize, solvFF, groups;

    Info(InfoCF,1,"Construct all Frattini-free groups of order ",n,".");

    # check
    if not IsPosInt( n ) or not IsCubeFreeInt( n ) then
        Error("Argument has to be a positive cube-free integer.\n"); 
    fi;

    # catch the case of n = 1 
    if n = 1 then 
        return [TrivialGroup()]; 
    fi; 
 
    # set up
    groups := [];
    cl     := Collected( Factors( n ) ); 

    # determine the possible non-abelian factors PSL(2,p)
    nonAb:=[TrivialGroup()];
    for p in cl do
        if (p[1]>3) and (n mod (p[1]*(p[1]-1)*(p[1]+1) / 2)=0) and
           IsCubeFreeInt(p[1]+1) and IsCubeFreeInt(p[1]-1) then
            
            G := PSL(2,p[1]);
            if Size(G)=n then
                Add(groups,G);
            else
                Add(nonAb,G);
            fi;
        fi;
    od;
    
    # for every non-abelian A compute a solvable complement
    for A in nonAb do
        nSize  := n/Size(A);
        solvFF := List(cf_FrattFreeSolvGroups(nSize),PcGroupCodeRec);
        groups := Concatenation(groups, List(solvFF,x->DirectProduct(A,x)));
    od;

    return(groups);
end);
