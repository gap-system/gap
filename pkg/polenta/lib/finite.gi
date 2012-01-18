#############################################################################
##
#W finite.gi               POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## constructive pc-sequences for finite matrix groups
##
#H  @(#)$Id: finite.gi,v 1.7 2011/09/23 13:36:32 gap Exp $
##
#Y 2003
##

#############################################################################
##
#F POL_SuitableOrbitPoints( gens)
##
## gens are some matrices over GF(q)
## we calculate suitable orbit points for a stabilizer chain
## of <gens>, i.e. points with small orbits
##
POL_SuitableOrbitPoints := function( gens )
    local MM,cs,l,i,x,fac,F,n,csR;

    # calculate the module
    F := FieldOfMatrixList( gens );
    MM := GModuleByMats(gens, F);

    # use the meataxe to calculate a decomposition series
    cs := SMTX.BasesCompositionSeries(MM);
    csR := Reversed( cs );

    # build a basis through this series
    n := Length( cs );
    l := [];
    for i in [1..(n-1)] do
        x :=  BaseSteinitzVectors(csR[i],csR[i+1]).factorspace;
        Append( l, x );
        #l:=List([1..(n-1)],
        #x->BaseSteinitzVectors(csR[x],csR[x+1]).factorspace[1]);
    od;
    return l ;
end;

POL_NextOrbitPoint := function( pcgs, h )
    local k,p,i;
    #k := Length( pcgs.suitableOrbitPoints );
    #Print( "pcgs.suitableOrbitPoints", pcgs.suitableOrbitPoints, "\n" );
    p := pcgs.suitableOrbitPoints[1];
    i := 2;
    while pcgs.oper( p, h ) = p do
        p :=  pcgs.suitableOrbitPoints[i];
        i := i+1;
    od;
    #Print( "chosen i is",i,"\n");
    return p;
end;

POL_NextOrbitPoint2 := function( pcgs, h )
    local k,p,i;
    k := Length( pcgs.suitableOrbitPoints );
    #Print( "pcgs.suitableOrbitPoints", pcgs.suitableOrbitPoints, "\n" );
    p := pcgs.suitableOrbitPoints[k];
    i := 1;
    while pcgs.oper( p, h ) = p do
        p :=  pcgs.suitableOrbitPoints[k-i];
        i := i+1;
    od;
    #Print( "chosen i is",i,"\n");
    return p;
end;

POL_NextOrbitPoint3 := function( pcgs, h )
    local k,p,i;
    k := Length( pcgs.suitableOrbitPoints );
    #Print( "pcgs.suitableOrbitPoints", pcgs.suitableOrbitPoints, "\n" );
    p := pcgs.suitableOrbitPoints[k];
    Unbind( pcgs.suitableOrbitPoints[k] );
    return p;
end;


#############################################################################
##
#F ClosureBasePcgs_word(pcgsN, g, gens, lim)
##
## Calculates a constructive pc-sequence for <N,g>^gens
##
## Every arising group element is realized as a record
## containing the real element
## and the word information corresponding to gens
##
InstallGlobalFunction( ClosureBasePcgs_word,function( pcgsN, g, gens, lim )
    local pcgsU,listU,u,u2,c,l,i,comm,tempWord,x,j,a,commElement;

    if lim < 0 then
        # G is not polycyclic
        # Error("Group is not polycyclic !\n");
        return fail;
    fi;

    # check if g is in N
    if MemberTestByBasePcgs( pcgsN, g.groupElement ) then
        return pcgsN;
    fi;

    # start extending U = <listU, pcgsN>
      pcgsU := StructuralCopy( pcgsN );
      Add( pcgsU.gens, g.groupElement );
      # in wordGens we find the information, how to
      # write the elements of gens in terms of gensOfG
      Add( pcgsU.wordGens, g.word );
      i := Position( pcgsU.gens, g.groupElement );
      # as the third argument of the next function call we transmit
      # g as corresponding to pcgsN.gens
      ExtendedBasePcgsMod( pcgsU, g.groupElement, [i,1] );
      listU:=[g];

    # loop over listU
    while Length( listU ) >= 1 do
        u := listU[Length( listU )];
        Unbind(listU[Length( listU )]);

        # consider all conjugates which are not contained in U
          # c := List( gens, x -> u^x );
          c := [];
          for j in [1..Length( gens )] do
              x := gens[j];
              tempWord := [[j,-1]];
              Append( tempWord, u.word );
              Append( tempWord, [[j,1]] );
              a:=rec( groupElement:=u.groupElement^x,
                      word:=tempWord);
              Add(c,a);
          od;
          c := Filtered(c,x -> not
                        MemberTestByBasePcgs(pcgsU,x.groupElement));

        # recurse, if <U,c>/N is not abelian
          l := Length( pcgsN.pcref );
          for i in [1..Length(c)] do
              comm := POL_Comm( g, c[i] );
              pcgsN := ClosureBasePcgs_word(pcgsN,comm,gens,lim-1);
              if pcgsN = fail then return fail; fi;
              for j in [(i+1)..Length(c)] do
                  comm := POL_Comm( c[j], c[i] );
                  pcgsN := ClosureBasePcgs_word(pcgsN,comm,gens,lim-1);
                  if pcgsN = fail then return fail; fi;
              od;
          od;

        # reset U and listU
          #check if pcgsN was modified
          if Length( pcgsN.pcref) > l then
              pcgsU := StructuralCopy(pcgsN);
              for i in [1..Length(listU)] do
                  u2 := listU[i].groupElement;
                  if not MemberTestByBasePcgs(pcgsU,u2) then
                      Add(pcgsU.gens,u2);
                      Add(pcgsU.wordGens,listU[i].word);
                      i := Position(pcgsU.gens,listU[i].groupElement);
                      ExtendedBasePcgsMod(pcgsU,listU[i].groupElement,[i,1]);
                  fi;
              od;
          fi;

         # finally add the conjugates to our list
         for i in [1..Length(c)] do
             Add(listU, c[i]);
             if not MemberTestByBasePcgs( pcgsU,c[i].groupElement) then
                 Add(pcgsU.gens,c[i].groupElement);
                 Add(pcgsU.wordGens,c[i].word);
                 j := Position(pcgsU.gens,c[i].groupElement);
                 ExtendedBasePcgsMod(pcgsU,c[i].groupElement,[j,1]);
             fi;
         od;
   od;
   return pcgsU;
end );

#############################################################################
##
#F POL_Comm( g, h )..................... calculates the Comm for records of
##                                       group elements with word information
##
InstallGlobalFunction( POL_Comm , function( g, h )
    local commElement, tempWord ,comm;
    commElement := Comm( g.groupElement, h.groupElement );
    tempWord := POL_InverseWord(g.word);
    Append(tempWord,POL_InverseWord(h.word));
    Append(tempWord,g.word);
    Append(tempWord,h.word);
    comm := rec(groupElement:=commElement,word:=tempWord);
    return comm;
end );

#############################################################################
##
#F CPCS_finite_word( gensOfG , b)
##
## Returns a constructive polycyclic sequence for G if G is polycyclic
## of derived length at most b and it returns fail if G is not
## polycyclic
##
## Every generator is a record which contains in
## .groupElement the group element and in
## .word the wordinformation corresponding to the gensOfG list
## This feature is important if gensOfG arise as the image under
## the p-congruence homomorphism.
##
##
InstallGlobalFunction( CPCS_finite_word , function( gensOfG , b)
    local c,f,d,pcgsOfN,x,epsilon,h,H,i,n,
          suitableOrbitPoints,pcgsOfN_hilf,j,k;
    Info( InfoPolenta, 5, "determining a constructive pcgs for the finite part...");

    # Setup of N
    f := FieldOfMatrixList( gensOfG );
    d := Length( gensOfG[1] );
    suitableOrbitPoints := POL_SuitableOrbitPoints( gensOfG );
    pcgsOfN := rec( orbit := [], trans := [], trels := [], defns := [],
                 pcref := [],
                 acton := f^d, oper := OnRight, trivl := IsOne,
                 gens:= [], wordGens:=[], gensOfG:=gensOfG,
                 suitableOrbitPoints := suitableOrbitPoints );
    c :=0;
    epsilon := [];
    for k in [1..Length(gensOfG)] do
        epsilon[k] := rec(groupElement:=gensOfG[k],word:=[[k,1]]);
    od;
    # epsilon:=ShallowCopy(gensOfG);
    j := 0;
    while Length(epsilon) > 0 do
         h := epsilon[Length(epsilon)];
         Unbind(epsilon[Length(epsilon)]);
         pcgsOfN := ClosureBasePcgs_word(pcgsOfN,h,gensOfG ,b);
         if pcgsOfN = fail then return fail; fi;
    od;
    Info(InfoPolenta,5,"finished");
    return pcgsOfN;
end );

#############################################################################
##
#F CPCS_FinitePart(gens)........... constructive pc-sequ. for image of <gens>
##                                  under the p-congr. hom.
##
InstallGlobalFunction( CPCS_FinitePart , function(gens )

   local p,d,gens_p,bound_derivedLength,pcgs_I_p;

   #calculate the dimension of the vector space <gens> acting on
   d := Length(gens[1][1]);

   # determine an admissible prime
   p := DetermineAdmissiblePrime(gens);

   # calculate the gens of the group phi_p(<gens>) where phi_p is
   # natural homomorphism in GL(d,p)
   #gens_p := gens*One(GF(p));
   gens_p := InducedByField(gens,GF(p));

   # determine an upper bound for the derived length of G
   # it could be sharper !
   bound_derivedLength :=  d+2;

   # determine a constructive polycyclic sequence for phi_p(<gens>)
   pcgs_I_p := CPCS_finite_word(gens_p,bound_derivedLength);

   return pcgs_I_p;
end );

###########################################################################
##
#F POL_InverseWord(word)
##
##
InstallGlobalFunction( POL_InverseWord , function(word)
    local wordPart,tempWord,pos,exp;
    tempWord := [];
    for wordPart in Reversed(word) do
        Add(tempWord,[wordPart[1],wordPart[2]*-1]);
    od;
    return tempWord;
end );

#############################################################################
##
#F  ExtendedBasePcgsMod( pcgs, g, d ) . . . . . .. . . . . extend a base pcgs
##
##  g normalizes <pcgs> and we compute a new pcgs for <pcgs, g>.
##
InstallGlobalFunction( ExtendedBasePcgsMod , function( pcgs, g, d )
    local h, e, i, o, b, m, c, l, w, j, k;

    # change in place - but unbind not updated information
    Unbind(pcgs.pcgs);
    Unbind(pcgs.rels);

    # set up
    h := g;
    e := ShallowCopy( d );
    i := 0;

    # loop over base and divide off
    while not pcgs.trivl( h ) do
        i := i + 1;
        #Print(" i=",i,"\n");

        # take base point (if necessary, add new base point)
        if i > Length( pcgs.orbit ) then
            #b := SmallOrbitPoint( pcgs, g );
            b := POL_NextOrbitPoint2( pcgs, h);
            Add( pcgs.orbit, [b] );
            Add( pcgs.trans, [] );
            Add( pcgs.defns, [] );
            Add( pcgs.trels, [] );
        else
            b := pcgs.orbit[i][1];
        fi;

        # compute the relative orbit length of h
        m := 1;
        c := pcgs.oper( b, h );
        while not c in pcgs.orbit[i] do
            m := m + 1;
            c := pcgs.oper( c, h );
        od;

        # enlarge pcgs, if necessary
        if m > 1 then
            #Print(" enlarge basic orbit ",i," by ",m," copies \n");
            Add( pcgs.trans[i], h );
            Add( pcgs.defns[i], e );
            Add( pcgs.trels[i], m );
            EnlargeOrbit( pcgs.orbit[i], h, m, pcgs.oper );
            # we save also g to know who was responsible for the entry
            Add( pcgs.pcref, [i, Length(pcgs.trans[i]),g] );
        fi;

        # divide off
        j := Position( pcgs.orbit[i], c );
        if j > 1 then
            w := TransWord( j, pcgs.trels[i] );
            h := h^m * SubsWord( w, pcgs.trans[i] )^-1;
            e := [[e,m], SubsAndInvertDefn( w, pcgs.defns[i] ) ];
        else
            h := h^m;
            e := [e,m];
        fi;
    od;
end );

#############################################################################
##
#F  RelativeOrdersPcgs_finite( pcgs )
##
InstallGlobalFunction( RelativeOrdersPcgs_finite , function( pcgs )
    local t,g,order,i;

    if IsBound( pcgs.relOrders )
        then return pcgs.relOrders;
    fi;
    pcgs.relOrders := [];

    #catch the trivial case
    if Length(pcgs.gens)=0 then
       return pcgs.relOrders;
    fi;

    g := pcgs.pcref[Length(pcgs.pcref)][3];
    order := 1;
    i := 1;
    for t in Reversed( pcgs.pcref ) do
        if t[3]=g then
            order := order*pcgs.trels[t[1]][t[2]];
            pcgs.relOrders[i] := order;
        else
            i := i+1;
            order := 1;
            g := t[3];
            order := order*pcgs.trels[t[1]][t[2]];
            pcgs.relOrders[i] := order;
        fi;
    od;
    return pcgs.relOrders;
end );

#############################################################################
##
#F  ExponentvectorPcgs_finite( pcgs, g )
##
InstallGlobalFunction( ExponentvectorPcgs_finite , function( pcgs, g )
   local exp,h,index,part;
   exp := [];
   h := g;
   for index in Reversed([1..Length(pcgs.gens)]) do
        part := ExponentvectorPartPcgs( pcgs, h , index);
        Add(exp,part);
        h := (pcgs.gens[index]^-part)*h;
   od;
   if not h=h^0 then
       Print("Failure in the Exponent computation !\n");
   fi;
   return exp;
end );

#############################################################################
##
#F  ExponentvectorPartPcgs( pcgs, g , index)
##
##  g = ...* pcgs.gens[index]^ExponentvectorPartPcgs * ...
##
InstallGlobalFunction( ExponentvectorPartPcgs , function( pcgs, g, index )
    local h, e,part, i, o, b, m, c, l, w, j, k;

    # set up
    h  :=  g;
    i := 0;
    e := [0,0];

    # loop over base and divide off
    while not pcgs.trivl( h ) do
        i := i + 1;
        # take base point
        if i > Length( pcgs.orbit ) then
            # Print(g , " is not contained in Pcgs\n");
            return fail;
        else
            b := pcgs.orbit[i][1];
        fi;
        #the relative orbit length of h should be 1
        m := 1;
        c := pcgs.oper( b, h );
        while not c in pcgs.orbit[i] do
            m := m + 1;
            c := pcgs.oper( c, h );
        od;
        if not m =1 then
            # Print(g , " is not contained in Pcgs\n");
            return fail;
        fi;

        # divide off
        j := Position( pcgs.orbit[i], c );
        if j > 1 then
            w := TransWord( j, pcgs.trels[i] );
            h := h^m * SubsWord( w, pcgs.trans[i] )^-1;
            e := [[e,m], SubsAndInvertDefn( w, pcgs.defns[i] ) ];
        fi;
    od;
    part := -ExtractIndexPart(e,index);
    return part;
end );

#############################################################################
##
#F ExtractIndexPart( word, index)
##
InstallGlobalFunction( ExtractIndexPart , function(word, index)
    local x;

    # case: word=Integer
    if word in Integers then
        if word=index then
            return 1;
        else
            return 0;
       fi;
    fi;

    # case: word=[]
    if IsEmpty(word) then
        return 0;
    fi;

    # case: word=[something,Integer]
    if Length(word) >1 then
        if word[2] in Integers then
            return word[2]*ExtractIndexPart(word[1],index);
        fi;
    fi;

    # case [something,something,..]
    x :=  ExtractIndexPart(word[1],index);
    x :=  x+ExtractIndexPart(word{[2..Length(word)]},index);
    return x;
end );

#############################################################################
##
#F  POL_TestExpVector_finite( pcgs, g )
##
InstallGlobalFunction( POL_TestExpVector_finite , function( pcgs, g )
   local exp,h,n,i;
   exp := ExponentvectorPcgs_finite( pcgs, g );
   # calculate the group element related to exp
   h := pcgs.gens[1]^0;
   n := Length(pcgs.gens);
   for i in Reversed([1..n]) do
       h := h*pcgs.gens[i]^exp[n-i+1];
   od;
   return g=h;
end );

#############################################################################
##
#F POL_Test_CPCS_FinitePart(gens)
##
POL_Test_CPCS_FinitePart := function( gens )
    local pcgs, i, g, test;
    pcgs := CPCS_FinitePart(gens);
    if pcgs.gens=[] then return "trivial"; fi;
    for i in [1..10] do
        g := POL_RandomGroupElement( pcgs.gensOfG );
        test := POL_TestExpVector_finite( pcgs, g );
        if not test then
           Error( "Failure in the exponent calculation in CPCS_FinitePart" );
        fi;
        Print(i);
    od;
    Print("\n");
end;

#############################################################################
##
#F POL_SetPcPresentation(pcgs)
##
## pcgs is a constructive pc-sequence, calculated
## by ConstructivePcSequenceFinitePart
## this function calculates a PcPresentation for the group described
## by pcgs
##
InstallGlobalFunction( POL_SetPcPresentation, function(pcgs)
   local genList,ftl,n,ro,i,j,exp,conj,f_i,f_j,r_i,pcSeq;

   # Attention: In pcgs.gens we have the pc-Sequence in inverse order
   # because we  built up  the structure bottom up
   pcSeq := StructuralCopy(Reversed(pcgs.gens));

   # Setup
   n := Length(pcgs.gens);
   ftl := FromTheLeftCollector(n);

   # calculate the relative orders
   ro :=  RelativeOrdersPcgs_finite( pcgs );

   for i in [1..n] do
       SetRelativeOrder(ftl,i,ro[i]);
   od;

   # Set power relations
   for i in [1..n] do
       f_i := pcSeq[i];
       r_i := ro[i];
       exp := ExponentvectorPcgs_finite( pcgs, f_i^r_i );
       genList := Exp2GenList(exp);
       SetPower(ftl,i,genList);
   od;

   # Set the conjugation relations
   for i in [1..n] do
       for j in [1..(i-1)] do
           f_i := pcSeq[i];
           f_j := pcSeq[j];
           conj := (f_j^-1)*f_i*f_j;
           exp := ExponentvectorPcgs_finite( pcgs, conj);
           genList := Exp2GenList(exp);
           SetConjugate(ftl,i,j,genList);
       od;
   od;

   UpdatePolycyclicCollector(ftl);
   return ftl;
end );

#############################################################################
##
#F TestPOL_SetPcPresentation(pcgs)
##
##
TestPOL_SetPcPresentation := function(pcgs)
   local ftl,relations,i;
   ftl := POL_SetPcPresentation(pcgs);
   relations := POL_NormalSubgroupGeneratorsOfK_p(pcgs,pcgs.gensOfG);
   for i in [1..Length(relations)] do
       if relations[i] <> relations[i]^0  then
           Print("Error in TestPOL_SetPcPresentation\n");
       fi;
   od;
end;


#############################################################################
##
#E
