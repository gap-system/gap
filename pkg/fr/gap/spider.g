#############################################################################
##
#W spider.g                                 Laurent Bartholdi + Dzmitry Dudko
##
#H   @(#)$Id: spider.g,v 1.7 2010/10/13 02:16:23 gap Exp $
##
#Y Copyright (C) 2010, Laurent Bartholdi + Dzmitry Dudko
##
#############################################################################
##
##  This file implements a purely symbolical spider algorithm.
##
#############################################################################

BindGlobal("LIFT_MACHINE@", function(machine,image,addresses)
    # lift <machine> by choosing the starting points at <addresses>, which
    # is a list of integers in [1..degree].
    # <image> is such that recursion of <image>[i] contains generator i.
    # returns the isomorphism of the stateset that
    # takes from the old to the new machine.
    local tau, gens, g, h, j, s, c, a;
    
    gens := GeneratorsOfFRMachine(machine);
    tau := [];
    for s in [1..Length(gens)] do
        g := gens[image[s]];
        a := addresses[s];
        h := One(gens[1]);
        repeat
            h := h*Transition(machine,g,a);
            a := Output(machine,g,a);
        until a=addresses[s];
        if not IsConjugate(StateSet(machine),gens[s],h) then
            return fail;
        fi;
        Add(tau,h);
    od;
    return GroupHomomorphismByImages(StateSet(machine),StateSet(machine),tau,gens);
end);

BindGlobal("LIFT_MACHINE_ONE@", function(machine,image,start,j)
    # lift <machine> by choosing the starting points at <addresses>, which
    # is a list of integers in [1..degree].
    # <image> is such that recursion of <image>[i] contains generator i.
    # returns the isomorphism of the stateset that
    # takes from the old to the new machine.
    local tau, gens, g, h, s, c, a;

    gens := GeneratorsOfFRMachine(machine);
    tau := ShallowCopy(gens);
    g := gens[image[j]];
    a := start;
    h := One(gens[1]);
    #Print(start," ",j," ",g,"\n");
    repeat
        h := h*Transition(machine,g,a);
        a := Output(machine,g,a);
        #Print(h,"  ",a,"\n");
    until a=start;
    #Print(start,j,h,"\n\n");
    if not IsConjugate(StateSet(machine),gens[j],h) then
        return fail;
    fi;
    tau[j] := h;
    return GroupHomomorphismByImages(StateSet(machine),StateSet(machine),tau,gens);
end);

BindGlobal("ADMADDRESSES@", function(machine)
    # returns a pair [image,[v1...vm]], with
    # vi = the coordinates in <machine> of a cycle whose product is
    # conjugate to vi, and
    # image[i] = the index of the element with such a cycle.
    # return [fail,fail] if these cannot be found, because e.g. there are
    # two or no cycles whose product is conjugate to the same vi.
    
    local gens, g, j, s, c, image, addresses; 
    image := [];
    addresses := [];
    gens := GeneratorsOfFRMachine(machine);
    for s in [1..Length(gens)] do
        for c in Cycles(PermList(Output(machine,gens[s])),AlphabetOfFRObject(machine)) do
            g := One(gens[1]);
            for j in c do
                g := g*Transition(machine,gens[s],j);
            od;
            if IsOne(g) then continue; fi;
            g := CyclicallyReducedWord(g);
            g := Position(gens,g);
            if g=fail or IsBound(image[g]) then return [fail,fail]; fi;
            image[g] := s;
            addresses[g] := c;
        od;
    od;
    if BoundPositions(image)<>[1..Length(gens)] then
        return [fail,fail];
    fi;
    return [image,addresses];
end);

BindGlobal("COUNTBOOL@", function(w)
    # returns fail if one of the states of a recursion w contains at least 2 equal letters
    local v, i, count;
    i := 1;
    v := ExtRepOfObj(w);
    count := [];
    for i in [2,4..Length(v)] do
        if not IsBound(count[v[i-1]]) then count[v[i-1]] := 0; fi;
        count[v[i-1]] := count[v[i-1]] + AbsInt(v[i]);
        if count[v[i-1]]>2 then return false; fi;
    od;
    return true;
end);

BindGlobal("LEVYCYCLES@", function(machine,image,degree,addingelement)
    #input: machine*tau,image,degree,addingelement
    #returns the binary relation on the postcritical set
    #two points are equivalent if they are not separated by any active state of the machine
    local tau, gens, g, h, s, set, sset, c, a, v, i, j, k, r;   
    gens := GeneratorsOfFRMachine(machine);    
    set := [1..Length(gens)];
    sset := List([1..degree],i->[]);

    for s in [1..Length(gens)] do
        if addingelement=s then continue; fi;
        for c in Cycles(PermList(Output(machine,gens[s])),AlphabetOfFRObject(machine)) do
            for j in [1..Length(c)-1] do
                v := ExtRepOfObj(Transition(machine,gens[s],c[j]));
                v := v{[1,3..Length(v)-1]};
                r := Length(v);
                v := Set(v);
                if Length(v) <> r then return fail; fi;    
                #a recursion from a topological polynomial must satisfy the above condition 

                for i in [c[j]..c[j+1]-1] do
                    SubtractSet(v,sset[i]);                       
                od;
                for i in [1..c[j]] do
                    SubtractSet(sset[i],v);
                od;
                for i in [c[j+1]+1..degree] do
                    SubtractSet(sset[i],v);
                od;
                SubtractSet(set,v);
                sset[c[j+1]] := v;
            od;
        od;
    od;
    if addingelement<>false then 
        RemoveSet(set,addingelement);
        Add(sset,[addingelement]);
    fi;
    Add(sset,set);
    
    if Length(gens)=2 then # special case, map is z^(+-d)
        sset := [];
    fi;
    return EquivalenceRelationByPartition(Domain([1..Length(gens)]),sset);
end);

BindGlobal("PREIMAGE_OF_RELATION@", function(relation, image) 
    # returns pre-"image" of an equivalence relation 
    # two elements are equivalent if and only if their images are equivalent   
   
    local i, j, s, set, sset, m, v;
    sset := Set(Successors(relation));
    m := Sum(sset,Length);
    v := [1..m];
    s := [];
    for set in sset do
       j := [];
       for i in [1..m] do 
         if image[i] in set then Add(j,i); fi; 
       od;
       Add(s,j);
       SubtractSet(v,j);
    od;
    Add(s,v);
    return EquivalenceRelationByPartition(Domain([1..m]),s);
end);

BindGlobal("RENORMALIZATION@", function(machine,ordering,relation)
    # input machine*tau,ordering,relation
    # returns a homeomorphism to a new group that factorizes machine*tau
    # m is the rank of the initial group
    # n = Length(Set(Successors(relation)))  is the rank of a new group
    local gens1, gens2, set, v, i, j, a, b, c, g, h, m ,n, group, tau;
 
    gens1 := GeneratorsOfFRMachine(machine);
    m := Length(gens1); 
    v := Set(Successors(relation));   
    set := List(v,ShallowCopy);
    n := Length(set);
    group := FreeGroup(n);
    gens2 := GeneratorsOfGroup(group);
    tau := List([1..n], i->One(gens1[1]));
    for i in [1..n] do 
        if Length(set[i]) = 1 then 
            tau[i] := gens1[set[i][1]];  
            continue;
        fi;
        v := List([1..Length(set[i])], j->Position(ordering, set[i][j]));
        if v[1]= fail then
            for j in [1..Length(set[i])] do
                tau[i] := tau[i]*gens1[set[i][j]];
            od;
            continue;  
        fi; 
        SortParallel(v,set[i]);
        if v[Length(v)] = fail then return fail; fi; #checking whether v is well defined 
        tau[i] := gens1[set[i][1]];  
        g := One(gens1[1]);
        for j in [2..Length(set[i])] do 
            h := One(gens1[1]); 
            for c in [v[j-1]+1..v[j]-1] do
                h := gens1[ordering[c]] * h;
            od;
            tau[i] := tau[i] * h * gens1[set[i][j]];
            g := g*h; 
        od;
        tau[i] := tau[i] * g^-1;        
    od;
    return GroupHomomorphismByImages(group, StateSet(machine), gens2, tau );
end);

BindGlobal("PREIMAGE_ORDERING@", function(preimageset, ordering, address, degree) 
    # returns the pre-"image" of "ordering" using address
   
    local i, j, s;
    j := List([1..degree],i->[]);
    for s in ordering do
        for i in preimageset[s] do
            Add(j[address[i]],i);
        od;
    od; 
    return j;
end);

BindGlobal("ISSUBCOLLECTION@", function(a,b) 
    # returns false or true
    local i, j;
    if b=[] then return true; fi;
    for i in [1..Length(a)-Length(b)+1] do
        if a{[i..i+Length(b)-1]}=b then return true; fi;
    od;
    return false;
end);

BindGlobal("UNIONORDERING@", function(a, b) 
   # if a=AB, b=BC, then returns ABC
   # returns fail if the result is not an ordering (it means that the result contains two equal elments)
   local i, c;
   c := []; 
   if a=[] then
       Append(c,b);
   fi;
   Append(c,a);
   i := 1;
   while i<=Length(b) and c[Length(c)]<>b[i] do
       i := i+1;
   od; 

   if i=Length(b)+1 then 
       i := 1;
   else
       i := i+1;
   fi; 
   Append(c,b{[i..Length(b)]}); 
   if not IsDuplicateFreeList(c) then return fail; fi; 
   return c;
end);
 

BindGlobal("NEWORDERING@", function(machine, preimageset, ordering, address, degree) 
    #returns a partial ordering around infinity
    # or fail if the old ordering is not compatible with a new one 
    local newordering, gens, set, sset, c, v, k, s, i;
    
    gens := GeneratorsOfFRMachine(machine);    
    set := [];
    newordering := PREIMAGE_ORDERING@(preimageset, ordering, address, degree);
    sset := List([1..degree],i->[]); 
    for s in [1..Length(gens)] do
        for c in Cycles(PermList(Output(machine,gens[s])), AlphabetOfFRObject(machine)) do
            if Length(c)>1 then 
                v := ExtRepOfObj(Transition(machine,gens[s],c[Length(c)]));
                v := v{[1,3..Length(v)-1]};
                if not IsDuplicateFreeList(v) then return fail; fi;
                if ISSUBCOLLECTION@(v, sset[c[Length(c)]]) then 
                     sset[c[Length(c)]] := v; 
                     if not ISSUBCOLLECTION@(sset[c[Length(c)]], newordering[c[1]]) then
                          sset[c[Length(c)]] := UNIONORDERING@( sset[c[Length(c)]], newordering[c[1]]);
                          if sset[c[Length(c)]] = fail then return fail; fi; 
                     fi;  
                fi;
            fi;

        od;
    od;
   if not ISSUBCOLLECTION@(sset[degree], newordering[degree]) then
        sset[degree] := UNIONORDERING@(newordering[degree],sset[degree]);
        if sset[degree] = fail then return fail; fi; 
   fi;
   i := degree;

   while i>0 do
      if not ISSUBCOLLECTION@(set,sset[i]) then 
          set := UNIONORDERING@(set, sset[i]); 
          if set = fail then return fail; fi; 
      fi;
      i := i-1;
   od;

    return set;
end);

BindGlobal("SUPPORTING_ANGLES@", function(machine, image, hyperbolic, addingelement, orbit, preimage, oldaddress, rayperiod, marked)
   # returns a collection [[..],[..]] of supporting rays
   # SUPPORTING_ANGLES@[1] corresponds to the hyperbolic part
   # SUPPORTING_ANGLES@[2] corresponds to the subhyperbolic part
   local index, degree, gens, c, s, suppangles, p, j, k, t, admaddresses, n, i, address;
   suppangles := []; 
   degree := Length(AlphabetOfFRObject(machine));
   n := 0;  
   index := [];
   gens := GeneratorsOfFRMachine(machine);    
   for s in [1..Length(gens)] do
        if addingelement=s then continue; fi;
        for c in Cycles(PermList(Output(machine,gens[s])),AlphabetOfFRObject(machine)) do
            if Length(c) = 1 then continue; fi;
            n := n+1;
            Add(suppangles,[]);
            Add(index,[]);
            for j in c do
                Add(suppangles[n],j -1);
                index[n] := [s,0, false, false];
            od;  
        od;
   od;
   n := 1;  

   while not ForAll([1..Length(suppangles)], i-> index[i][4]) do
      for i in [1..Length(suppangles)] do if not index[i][4] then
          if index[i][3] = false then
              if preimage[index[i][1]]= 0 then  
                  for j in [1..Length(suppangles[i])] do
                      suppangles[i][j] := suppangles[i][j] * degree + (oldaddress[n][index[i][1]] - 1);              
                  od;
                  index[i][1] := image[index[i][1]];
              else 
                         
                  
                  for j in [1..Length(suppangles[i])] do 
                      suppangles[i][j] := suppangles[i][j]/degree^(n);
                  od;        
                  Add(index[i],oldaddress[n][index[i][1]] - 1);
                  Add(index[i],n);
                 
                  index[i][3] := index[i][1];  
                  index[i][1] := image[index[i][1]];
                  if index[i][1] = index[i][3] then index[i][2] := index[i][2]+1; fi;
                  for j in [1..Length(marked)] do
                     if marked[j] in orbit[index[i][1]] then 
                       Add(index[i], rayperiod[j]);
                       Add(index[i], hyperbolic[j]); 
                     fi;
                  od;
                  
              fi;
              
              continue;
          fi;
    
          index[i][5] := index[i][5] * degree + (oldaddress[n][index[i][1]] - 1); 
          index[i][1] := image[index[i][1]]; 

          if index[i][1] = index[i][3] then index[i][2] := index[i][2]+1; fi; 
          if index[i][2] > 0 and index[i][2] mod index[i][7] = 0 then 
              index[i][5] := index[i][5]/(degree^(n+1-index[i][6])-1)/degree^(index[i][6]);
              for j in [1..Length(suppangles[i])] do
                  suppangles[i][j] := suppangles[i][j] + index[i][5];
              od;
              index[i][4] := true;
          fi;

               
      fi; od;     

      n := n+1;
 
   od; 
   s := [[], []];
   for i in [1..Length(suppangles)] do
      if index[i][8]
      then  
        Add(s[1], suppangles[i]);
      else
        Add(s[2], suppangles[i]);
      fi;
   od;

   return s; 
end);

BindGlobal("SPIDERALGORITHM@", function(machine)
    # <machine> is a polynomial FR machine:
    # StateSet(M) is a free group of rank m+1;
    # generator AddingElement(M) is an adding element, and should be ignored.
    # it returns either
    # rec(minimal := true, machine, supportingangles, rayperiod, ordering, niter, transformation)
    # in case the machine admits no obstruction; or
    # rec(minimal := false, machine, submachine, homomorphism, relation, niter, transformation) 
    # describing an obstruction and homomorphism to smaller machine
    # here the equivalence "relation" describes which points coalesce;
    # and submachine is the factorization of machine through homomorphism
    # it returns fail when the machine is not an img-machine of a topological polynomial  
    
    local image, # which point maps to which one
          numcycles, # number of cycles in "image"
          preimage, # either inverse of image, for periodic points, or 0
          preimageset, # preaimge[j] is the set of preimages of j (could be empty)  
          preperiodicity, # distance to periodic cycle
          gens, # generators of free group
          niter, # number of iterations
          extraniter, # number of extra iterations
          m, # number of generators
          degree, #degree   
          suppangles,
          hyperbolic, # whether cycle contains a critical point
          cyclelength, # length of cycle
          orbit, # cycle index of point
          marked, # one marked point per grand cycle
          pass, # 1,2,3 for each cycle
          wobble, # little extra push to give to some markings
          oldmarkrecursion, # previous recursions of marked elements
          ordering, # cyclic order around infinity
          orderindex, #
          tau, # the group automorphism
          tauidentity, #the tauidentity group automorphism
          transformation, # the collection of tau
          addingelement, # adding element, if there is no one, then addingelement = false
          group, # the free group
          address, # where we lift our machine
          markedaddress, # orbit of marked points
          oldaddress, # for calculating supproting rays  
          admaddresses, # admissible addresses for lifting
          rayperiod, # period of the supporting rays landing there
          relation, # relation on the postcritical set describing Levy cycles
          basicrelation, # subhyperbolic points are equivalent, hyperbolic points are not  
          submachine, # the submachine, in case there is an obstruction
          i, j, k, p, t;
    
    # initialise constants
    degree := Length(AlphabetOfFRObject(machine));
    gens := GeneratorsOfFRMachine(machine);
    group := StateSet(machine);
    tauidentity := GroupHomomorphismByImages(group,group,gens,gens);
    hyperbolic := ADMADDRESSES@(machine);
    if hyperbolic = [fail,fail] then return fail; fi;
    image := hyperbolic[1];
    p := hyperbolic[2];
    if image=fail then return -1; fi;
    m := Length(gens);
    orbit := image;
    for i in [1..m] do orbit := image{orbit}; od;
    cyclelength := List(orbit,x->[x]);
    for i in [1..m] do
        cyclelength := Set(cyclelength,o->Union(o,image{o}));
    od;
    numcycles := Size(cyclelength);
    j := Union(cyclelength);
    preimage := List([1..m],i->0); preimage{image{j}} := j;
    preperiodicity := [];
    for i in [1..m] do
        niter := 0;
        k := i; 
        while not k in j do k := image[k]; niter := niter+1; od;
        preperiodicity[i] := niter;
    od;
    preimageset := List([1..m],i->[]);
    for i in [1..m] do 
        Add(preimageset[image[i]],i);
    od;
    hyperbolic := List(cyclelength,o->ForAny(o,i->Length(hyperbolic[2][i])>1));
    orbit := List(orbit,i->First(cyclelength,c->i in c));
    marked := List(cyclelength,Representative);
   
    k:=[[]];
    for i in [1..Length(cyclelength)] do
        if hyperbolic[i] then
            Append(k,List(cyclelength[i],j->[j]));
        else
            Append(k[1],cyclelength[i]);
        fi;
    od;
    basicrelation := EquivalenceRelationByPartition(Domain([1..Length(gens)]),k);
    cyclelength := List(cyclelength,Length);

    # initialise variables
    transformation := [];
    orderindex := [0,0];
    ordering := [];
    niter := 0;
    # marked was already initialised above
    pass := List([1..numcycles],i->1); 
    addingelement := false;
    for i in [1..numcycles] do  # searching for an adding machine 
        if image[marked[i]] = marked[i] and Length(p[marked[i]])=degree then 
           pass[i] := 3;
           addingelement := marked[i]; 
        fi;
    od;
    wobble := List([1..numcycles],i->0);
    oldmarkrecursion := List([1..numcycles],i->[WreathRecursion(machine)([marked[i]])]);
    tau := IdentityMapping(group);
    rayperiod := List([1..numcycles],i->1);
    markedaddress := List([1..m], i-> false);
    oldaddress := [];
    extraniter := 0;
    
    repeat

        # step 1: compute possible addresses
        admaddresses := ADMADDRESSES@(machine)[2];
        if admaddresses=fail then return -1; fi;
        if niter=0 then
            address := List(admaddresses,Minimum);
        fi;

        # step 2: select appropriate lifts
        for i in [1..numcycles] do if hyperbolic[i] then
            j := marked[i];
            if niter < cyclelength[i] then
                address[j] := Minimum(admaddresses[j]);
            else
                k := Intersection(admaddresses[j],[markedaddress[j]+wobble[i]..m]);  
                if k=[] then
                    address[j] := Minimum(admaddresses[j]);
                    wobble[i] := 1;
                else
                    address[j] := Minimum(k); 
                    wobble[i] := 0;
                fi;
            fi;
            markedaddress[j] := address[j];
            marked[i] := preimage[j];
        fi; od;

        # step 3: check addresses
        for j in [1..m] do
            if not address[j] in admaddresses[j] then
                k := Intersection(admaddresses[j],[address[j]+1..m]);
                if k=[] then
                    address[j] := Minimum(admaddresses[j]);
                else
                    address[j] := Minimum(k);
                fi;
                if markedaddress[j]<>false then extraniter := 0; fi;
            fi;
        od;
        Info(InfoFR, 2, "Symbolic spider: selected addresses ", address);

        # step 4: do the lifting
        tau := LIFT_MACHINE@(machine,image,address);
        if tau=fail then return fail; fi;
        Add(oldaddress,List(address,ShallowCopy),1); 
        if Length(oldaddress)>2*m^2 then 
            Remove(oldaddress);
        fi; 
        if tau<>tauidentity then
            Add(transformation,tau);
        fi;
        machine := machine*tau;
        
        # search for Levy cycles 
        if niter mod m = 0 then 
            relation := LEVYCYCLES@(machine,image,degree,addingelement);
            if relation = fail then return fail; fi;
        else  
            p := LEVYCYCLES@(machine,image,degree,addingelement);
            if p = fail then return fail; fi;
            relation := MeetEquivalenceRelations(PREIMAGE_OF_RELATION@(relation, image),p);
            relation := MeetEquivalenceRelations(basicrelation,relation);
        fi;  
    
        # calculation of a partial ordering around infinity 
        ordering := NEWORDERING@(machine, preimageset, ordering, address, degree);
        if ordering = fail then return fail; fi; 
        if (Length(ordering) < m-1) then  
            if (orderindex[1]< Length(ordering)) then 
                orderindex[1] := Length(ordering);
                orderindex[2] := 0; 
            else
                orderindex[2] := orderindex[2]+1; 
            fi; 
        else 
            orderindex[1] := Length(ordering); 
        fi;
        if niter mod m = m-1 and (orderindex[2]>m or orderindex[1]>=m-1) and EquivalenceRelationPartition(relation)<>[] then
            p := RENORMALIZATION@(machine,ordering,relation);  # homomorphism that factorize machine 
            if p=fail then return fail; fi;
            submachine := SubFRMachine(tau^-1*machine,p); # try to factorize tau^-1*machine 
            if submachine <> fail then
                return rec(minimal := false,
                           machine := tau^-1*machine,
                           submachine := submachine,
                           homomorphism := p,
                           relation := relation,
                           niter := niter + 1,
                           transformation := transformation);
            fi;
        fi;

        machine := tau^-1*machine;   
        # reduce to a new basis 
        for i in [1..numcycles] do
            if oldmarkrecursion[i] <> false then 
                if ForAll([1..Length(oldmarkrecursion[i])],
                          t->ForAll([1..Length(oldmarkrecursion[i][t][1])], k->COUNTBOOL@(oldmarkrecursion[i][t][1][k]))) then 
                    for j in [1..Length(oldmarkrecursion[i])] do
                        oldmarkrecursion[i][j][1] := List(oldmarkrecursion[i][j][1],x->x^tau);       
                    od;
                else 
                    oldmarkrecursion[i] := false; 
                fi;  
            fi;
        od;
        niter := niter + 1;

        Info(InfoFR, 2, "Symbolic spider: new machine ", machine); 
        # step 5: adjust pass
        for i in [1..numcycles] do
            if pass[i] = 3 then continue; fi;
            if hyperbolic[i] then
                if niter mod cyclelength[i] <> 0 then continue; fi;
                j := WreathRecursion(machine)(gens[marked[i]]);
                if oldmarkrecursion[i] = false then oldmarkrecursion[i] := [j]; continue; fi; 
                if j=oldmarkrecursion[i][1] then
                    pass[i] := pass[i]+1;
                    wobble[i] := 3-pass[i]; # 1 on pass 2, 0 on pass 1&3
                    oldmarkrecursion[i] := false;
                else
                    oldmarkrecursion[i][1] := j;
                fi;
            else   
                if niter mod cyclelength[i] <> 0 then continue; fi;
                j := WreathRecursion(machine)(gens[marked[i]]);  
                if oldmarkrecursion[i] = false then oldmarkrecursion[i] := [j]; continue; fi; 
                if j in oldmarkrecursion[i] then
                    pass[i] := 3;
                    rayperiod[i] := Position(oldmarkrecursion[i],j);       
                else
                    Add(oldmarkrecursion[i],j,1); 
                    if Length(oldmarkrecursion[i]) > m then Remove(oldmarkrecursion[i]); fi;
                fi;
            fi;
        od;
        if ForAll([1..numcycles],i-> pass[i]=3) then extraniter := extraniter + 1; fi;
        
    until extraniter>m; 

    suppangles := SUPPORTING_ANGLES@(machine, image, hyperbolic,addingelement, orbit, preimage, oldaddress, rayperiod, marked);
    return rec (minimal := true,
                machine := machine,
                supportingangles := suppangles,
                rayperiod := rayperiod,
                ordering := ordering,
                niter := niter,
                transformation := transformation);
end);

# machine := PolynomialIMGMachine(12,[[1/(12^12-1),1/(12^12-1)+1/12,1/(12^12-1)+2/12,1/(12^12-1)+3/12,1/(12^12-1)+4/12,1/(12^12-1)+5/12,1/(12^12-1)+6/12,1/(12^12-1)+7/12,1/(12^12-1)+8/12,1/(12^12-1)+9/12,1/(12^12-1)+10/12,1/(12^12-1)+11/12]],[]);
# group := StateSet(machine);
# T := GroupHomomorphismByImages(group,group,[group.1^(group.2*group.1),group.2^group.1,group.3,group.4,group.5^(group.6*group.5),group.6^group.5,group.7,group.8,group.9,group.10,group.11,group.12,group.13],GeneratorsOfGroup(group));

#E spider.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
