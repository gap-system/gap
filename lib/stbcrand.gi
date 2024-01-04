#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Ákos Seress.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file contains  the  functions for  a random Schreier-Sims algorithm
##  with verification.
##

#############################################################################
##
#F  StabChainRandomPermGroup( <gens>, <id>, <opts> )  .  random Schreier-Sims
##
##  The  method  consists of  2  phases:  a  heuristic construction  and
##  either a deterministic or two random checking phases.
##  In the random checking  phases,  we  take random  elements of
##  created set, multiply by  random subproduct of  generators, and sift down
##  by dividing with the  appropriate coset representatives. The stabchain is
##  correct when  all  siftees are  ().    In the first  checking  phase, all
##  computations are carried out with words  in strong generators and siftees
##  are checked by plugging in random points in words; in the second checking
##  phase, permutations are multiplied.
##
##  During the construction, we create new records for stabilizers:
##  S.aux = set of strong generators for S, temporarily created during the
##          construction. On the other hand, S.generators contains a strong
##          generating set for S which would have been created by the
##          deterministic method
##  S.treegen = elements of S.aux used in S.transversal
##  S.treegeninv = inverses of S.treegen; also used in S.transversal,
##                 and they are also elements of S.aux
##  S.treedepth = depth of Schreier tree of S
##  S.diam = sum of treedepths in stabilizer chain of S
##
##  After the  stabilizer chain  is  ready,  the  extra records are  deleted.
##  Transversals are rebuilt using the generators in the .generators records.
##
InstallGlobalFunction( StabChainRandomPermGroup, function( gens, id, options)
    local S,        # stabilizer chain
          degree,   # degree of S
          givenbase,# list of points from which first base points should come
          correct,  # boolean; true if a correct base is given
          size,     # size of <G> as constructed
          order,    # size of G if given in input
          limit,    # upper bound on Size(G) given in input
          orbits,   # list of orbits of G
          orbits2,  # list of orbits of G
          k,        # number of pairs of generators checked
          param,    # list of parameters guiding number of repetitions
                    # in random constructions
          where,    # list indicating which orbit contains points in domain
          basesize, # list; i^th entry = number of base points in orbits[i]
          i,j,
          ready,    # boolean; true if stabilizer chain ready
          warning,  # used at warning if given and computed size differ
          new,      # list of permutations to be added to stab. chain
          result,   # output of checking phase; nontrivial if stabilizer
                    # chain is incorrect
          base,     # ordering of domain from which base points are taken
          missing,  # if a correct base was provided by input, missing
                    # contains those points of it which are not in
                    # constructed base
          T;        # a stabilizer chain containing the usual records

    S:= rec( generators := ShallowCopy( gens ), identity := id );
    if options.random = 1000 then
       #case of deterministic computation with known size
       k := 1;
    else
       k:=First([1..14],x->(3/5)^x<1-options.random/1000);
    fi;

    degree := LargestMovedPoint( S.generators );

    if IsBound( options.knownBase) and
      Length(options.knownBase)<4+LogInt(degree,10)  then
        param:=[k,4,0,0,0,0];
    else
        param:=[QuoInt(k,2),4,QuoInt(k+1,2),4,50,5];
        options:=ShallowCopy(options);
        Unbind(options.knownBase);
    fi;
    if options.random <= 200 then
       param[2] := 2;
       param[4] := 2;
    fi;

    #param[1] = number of pairs of random subproducts from generators in
    #           first checking phase
    #param[2] = (number of random elements from created set)/S.diam
    #           in first checking phase
    #param[3] = number of pairs of random subproducts from generators in
    #           second checking phase
    #param[4] = (number of random elements from created set)/S.diam
    #           in second checking phase
    #param[5] = maximum size of orbits in  which we evaluate words on all
    #           points of orbit
    #param[6] = minimum number of random points from orbit to plug in to check
    #           whether given word is identity on orbit


    # prepare input of construction
    if IsBound(options.base)  then
        givenbase := options.base;
    else
        givenbase := [];
    fi;

    if IsBound(options.size) then
        order := options.size;
        warning := 0;
        limit := 0;
    else
        order := 0;
        if IsBound(options.limit) then
            limit := options.limit;
        else
            limit := 0;
        fi;
    fi;

    if IsBound( options.knownBase )  then
        correct := true;
    else
        correct := false;
    fi;

    if correct then
        # if correct  base was given as input, no need for orbit information
        base:=Concatenation(givenbase,Difference(options.knownBase,givenbase));
        missing := Set(options.knownBase);
        basesize := [];
        where := [];
        orbits := [];
    else
        # create ordering of domain used in choosing base points and
        # compute orbit information
        base:=Concatenation(givenbase,Difference([1..degree],givenbase));
        missing:=[];
        orbits2:=OrbitsPerms(S.generators,[1..degree]);
        #throw away one-element orbits
        orbits:=[];
        j:=0;
        for i in [1..Length(orbits2)] do
            if Length(orbits2[i]) >1 then
               j:=j+1; orbits[j]:= orbits2[i];
            fi;
        od;
        basesize:=[];
        where:=[];
        for i in [1..Length(orbits)] do
            basesize[i]:=0;
            for j in [1..Length(orbits[i])] do
                where[orbits[i][j]]:=i;
            od;
        od;
        # temporary solution to speed up of handling of lots of small orbits
        # until compiler
        if Length(orbits) > degree/40 then
           param[1] := 0;
           param[3] := k;
        fi;
    fi;

    ready:=false;
    new:=S.generators;

    while not ready do
        SCRMakeStabStrong
           (S,new,param,orbits,where,basesize,base,correct,missing,true);
        # last parameter of input is true if function called for original G
        # in recursive calls on stabilizers, it is false
        # reason: on top level,
        #         we do not want to add anything to generating set

        # start checking
        size := 1;  T := S;
        while Length( T.generators ) <> 0  do
            size := size * Length( T.orbit );
            T := T.stabilizer;
        od;
        if size = order  or  size = limit  then
            ready := true;
        elif size < order then
            # we have an incorrect stabilizer chain
            # repeat checking until a new element is discovered
            result := id;
            if options.random = 1000 then
                if correct then
                   result := SCRStrongGenTest(S,[1,10/S.diam,0,0,0,0],orbits,
                                      basesize,base,correct,missing);
                else
                   result := SCRStrongGenTest2(S,[0,0,1,10/S.diam,0,0]);
                fi;
                if result = id then
                   T := SCRRestoredRecord(S);
                   result := VerifySGS(T,missing,correct);
                fi;
                if result = id then
                   Print("Warning, computed and given size differ","\n");
                   ready := true;
                   S := T;
                else
                   if not IsPerm(result) then
                      repeat
                         result := SCRStrongGenTest2(S,[0,0,1,10/S.diam,0,0]);
                      until result <> id;
                   fi;
                   new := [result];
                fi;
            else
               warning := 0;
               if correct then
                 # if correct base was provided, it is enough to check
                 # images of base points to check whether a word is trivial
                 # no need for second checking phase
                 while result = id do
                    warning := warning + 1;
                    if warning > 5 then
                       Print("Warning, computed and given size differ","\n");
                    fi;
                    result := SCRStrongGenTest(S,param,orbits,
                                      basesize,base,correct,missing);
                 od;
               else
                 while result = id do
                    warning := warning + 1;
                    if warning > 5 then
                       Print("Warning, computed and given size differ","\n");
                    fi;
                    result:=SCRStrongGenTest(S,param,orbits,
                                    basesize,base,correct,missing);
                    if result = id then
                        # Print("entering SGT2","\n");
                        result:=SCRStrongGenTest2(S,param);
                    fi;
                 od;
               fi;  # correct or not
               new:=[result];
            fi;   # end of random checking or not, when size is known
        else
            #no information or only upper bound about Size(S)
            if options.random = 1000 then
              if correct then
                   result := SCRStrongGenTest(S,[1,10/S.diam,0,0,0,0],orbits,
                                      basesize,base,correct,missing);
               else
                   result := SCRStrongGenTest2(S,[0,0,1,10/S.diam,0,0]);
               fi;
               if result = id then
                  T := SCRRestoredRecord(S);
                  result := VerifySGS(T,missing,correct);
               fi;
               if result = id then
                  S := T;
                  ready := true;
               else
                  if not IsPerm(result) then
                     repeat
                        result := SCRStrongGenTest2(S,[0,0,1,10/S.diam,0,0]);
                     until result <> id;
                  fi;
                  new := [result];
               fi;
            else
               # Print("entering SGT", "\n");
               result:=SCRStrongGenTest(S,param,orbits,basesize,
                                  base,correct,missing);
               if result <> id then
                  new:=[result];
               elif correct then
                  # no need for second checking phase
                  ready:=true;
               else
                   # Print("entering SGT2","\n");
                   result:=SCRStrongGenTest2(S,param);
                   if result = id then
                      ready:=true;
                   else
                      new:=[result];
                   fi;
               fi;
            fi;   # random checking or not, when size is not known
        fi;   # size known
    od;

    #restore usual record elements
    if not IsBound(S.labels) then
       S := SCRRestoredRecord(S);
    fi;
    return S;
end );


#############################################################################
##
#F  SCRMakeStabStrong( ... )  . . . . . . . . . . . . . . . . . . . . . local
##
##  heuristic stabilizer  chain  construction, with one random  subproduct on
##  each  level,  and one or two  (defined  by mlimit) random cosets  to make
##  Schreier generators
##
InstallGlobalFunction( SCRMakeStabStrong,
    function ( S, new, param, orbits, where, basesize, base,
                                correct, missing, top )
    local   x,m,j,l,      # loop variables
            ran1,         # random permutation
            string,       # random 0-1 string
            w,            # random subproduct of generators
            len,          # number of generators of S
            mlimit,       # number of random elements to be tested
            coset,        # word representing coset of S
            residue,      # first component: remainder of Schreier generator
                          # after factorization; second component > 0
                          # if factorization unsuccessful
            jlimit,       # number of random points to plug into residue[1]
            ran,          # index of random point in an orbit of S
            g,            # permutation to be added to S.stabilizer
            gen,          # permutations used in S.transversal
            inv,          # their inverses
            firstmove;    # first point of base moved by an element of new

    if new <> [] then
        firstmove := First( base, x->ForAny( new, gen->x^gen<>x ) );
        # if necessary add a new stabilizer to the stabchain
        if not IsBound(S.stabilizer) then
            S.orbit                    := [firstmove];
            S.transversal              := [];
            S.transversal[S.orbit[1]]  := S.identity;
            S.generators               := [];
            S.treegen                  := [];
            S.treegeninv               := [];
            S.stabilizer               := rec();
            S.stabilizer.identity      := S.identity;
            S.stabilizer.aux           := [];
            S.stabilizer.generators    := [];
            S.stabilizer.diam          := 0;
            if not correct then
                basesize[where[S.orbit[1]]]
                    := basesize[where[S.orbit[1]]] + 1;
            fi;
            missing := Difference( missing, [ firstmove ] );
        else
            if Position(base,firstmove) < Position(base,S.orbit[1]) then
                S.stabilizer               := ShallowCopy(S);
                S.orbit                    := [firstmove];
                S.transversal              := [];
                S.transversal[S.orbit[1]]  := S.identity;
                S.generators := ShallowCopy(S.stabilizer.generators);
                S.treegen                  := [];
                S.treegeninv               := [];
                if not correct then
                    basesize[where[S.orbit[1]]]
                      := basesize[where[S.orbit[1]]] + 1;
                fi;
                missing := Difference( missing, [ firstmove ] );
            fi;
        fi;

        # on top level, we want to keep the original generators
        if not top or Length(S.generators) = 0  then
          for j in new do
            StretchImportantSLPElement(j);
          od;
          Append(S.generators,new);
        fi;
        #construct orbit of basepoint
        SCRSchTree(S,new);

        #check whether new elements are really new in the system
        while new <> [] do
            g := SCRSift( S, Remove(new) );
            if g <> S.identity then
                SCRMakeStabStrong(S.stabilizer,[g],param,orbits,
                                  where,basesize,base,correct,missing,false);
                S.diam:=S.treedepth+S.stabilizer.diam;
                S.aux:=Concatenation(S.treegen,
                                     S.treegeninv,S.stabilizer.aux);
            fi;
        od;
    fi;

    #check random Schreier generators
    gen := Concatenation(S.treegen,S.treegeninv,[S.identity]);
    inv := Concatenation(S.treegeninv,S.treegen,[S.identity]);
    len := Length(S.aux);
    #in case of more than one generator for S, form a random subproduct
    #otherwise, use the generator
    if len > 1 then
        ran1 := SCRRandomPerm(len);
        string := SCRRandomString(len);
        w := S.identity;
        for x in [1..len] do
            w := w*(S.aux[x^ran1]^string[x]);
        od;
    else
        w:=S.aux[1];
    fi;

    # take random coset(s)
    mlimit:=1;
    m:=0;
    while m < mlimit do
        m := m+1;
        ran := Random(1, Length(S.orbit));
        coset := CosetRepAsWord(S.orbit[1],S.orbit[ran],S.transversal);
        coset := InverseAsWord(coset,gen,inv);
        if w <> S.identity then
            # form Schreier generator and factorize
            Add(coset,w);
            residue := SiftAsWord(S,coset);
            # check whether factorization is successful
            if residue[2] > 0  then
                # factorization is unsuccessful; use remainder for
                # construction in stabilizer
                g := Product(residue[1]);
                SCRMakeStabStrong(S.stabilizer,[g],param,orbits,where,
                                  basesize,base,correct,missing,false);
                S.diam := S.treedepth+S.stabilizer.diam;
                S.aux := Concatenation(S.treegen,S.treegeninv,
                                       S.stabilizer.aux);
                # get out of current loop
                m := 0;
            elif correct then
                # enough to check images of points in given base
                l := 0;
                while l < Length(missing) do
                    l := l+1;
                    if ImageInWord(missing[l],residue[1]) <> missing[l] then
                        # factorization is unsuccessful;
                        # use remainder for construction in stabilizer
                        g := Product(residue[1]);
                        SCRMakeStabStrong(S.stabilizer,[g],param,
                                          orbits,where,basesize,
                                          base,correct,missing,false);
                        S.diam := S.treedepth+S.stabilizer.diam;
                        S.aux := Concatenation(S.treegen,
                                               S.treegeninv,S.stabilizer.aux);
                        # get out of current loop
                        m := 0;
                        l := Length(missing);
                    fi;
                od;
            else
                l:=0;
                while l < Length(orbits) do
                    l:=l+1;
                    if Length(orbits[l]) > param[5] then
                        # in large orbits, plug in random points
                        j:=0;
                        jlimit:=Maximum(param[6],basesize[l]);
                        while j < jlimit do
                            j:=j+1;
                            ran:=Random(1, Length(orbits[l]));
                            if ImageInWord(orbits[l][ran],residue[1])
                              <> orbits[l][ran]
                            then
                                # factorization is unsuccessful;
                                # use remainder for construction in stabilizer
                                g := Product(residue[1]);
                                SCRMakeStabStrong(S.stabilizer,[g],param,
                                                  orbits,where,basesize,
                                                  base,correct,missing,false);
                                S.diam := S.treedepth+S.stabilizer.diam;
                                S.aux := Concatenation(S.treegen,S.treegeninv,
                                                       S.stabilizer.aux);
                                # get out of current loop
                                m := 0;
                                j := jlimit;
                                l := Length(orbits);
                            fi;
                        od; #j loop
                    else
                        # in small orbits, check images of all points
                        j := 0;
                        while j < Length(orbits[l]) do
                            j := j+1;
                            if ImageInWord(orbits[l][j],residue[1])
                              <> orbits[l][j]
                            then
                                # factorization is unsuccessful;
                                # use remainder for construction in stabilizer
                                g := Product(residue[1]);
                                SCRMakeStabStrong(S.stabilizer,[g],param,
                                                  orbits,where,basesize,
                                                  base,correct,missing,false);
                                S.diam := S.treedepth+S.stabilizer.diam;
                                S.aux := Concatenation(S.treegen,S.treegeninv,
                                                       S.stabilizer.aux);
                                # get out of current loop
                                m := 0;
                                j := Length(orbits[l]);
                                l := Length(orbits);
                            fi;
                        od; #j loop
                    fi;
                od; #l loop
            fi;
        fi;
    od; #m loop

end );


#############################################################################
##
#F  SCRStrongGenTest( ... ) . . . . . . . . . . . . . . . . . . . . . . local
##
##  tests whether product of a random element of S and a random subproduct of
##  the strong generators  of S is in S.   Computations are  carried out with
##  words in generators   representing  group  elements; random   points  are
##  plugged in to test whether a word represents  the identity.  If SGS for S
##  not complete, returns a permutation not in S.
##
InstallGlobalFunction( SCRStrongGenTest,
    function ( S, param, orbits, basesize,
                               base, correct, missing)
    local   x,i,k,m,j,l,  # loop variables
            ran1,ran2,    # random permutations
            string,       # random 0-1 string
            w,            # list containing random subproducts of generators
            len,          # number of generators of S
            len2,         # length of short random subproduct
            mlimit,       # number of random elements to be tested
            ranword,      # random element of S as a word in generators
            residue,      # first component: remainder of ranword
                          # after factorization; second component > 0
                          # if factorization unsuccessful
            jlimit,       # number of random points to plug into residue[1]
            ran,          # index of random point in an orbit of S
            g;            # product of residue[1]

    k := 0;
    while k < param[1] do
        k := k+1;
        len := Length(S.aux);
        #in case of large S.aux, form random subproducts
        #otherwise, try all of them
        if len > 2*param[3] then
            ran1 := SCRRandomPerm(len);
            ran2 := SCRRandomPerm(len);
            len2 := Random(1, QuoInt(len,2));
            string := SCRRandomString(len+len2);

            # we form two random subproducts:
            # w[1] in a random ordering of all generators
            # w[2] in a random ordering of a random subset of them
            w:=[];
            w[1] := S.identity;
            for x in [1 .. len] do
                w[1] := w[1]*(S.aux[x^ran1]^string[x]);
            od;
            w[2] := S.identity;
            for x in [1 .. len2] do
                w[2] := w[2]*(S.aux[x^ran2]^string[x+len]);
            od;

        else
            # take next two generators of S (unless only one is left)
            w := [];
            w[1] := S.aux[2*k-1];
            if len > 2*k-1 then
                w[2] := S.aux[2*k];
            else
                w[2] := S.identity;
            fi;
        fi;

        # take random elements of S as words
        m := 0;
        mlimit := param[2]*S.diam;
        while m < mlimit do
            m:=m+1;
            ranword := RandomElmAsWord(S);
            i := 0;
            while i < 2 do
                i := i+1;
                if w[i] <> S.identity then
                    Append(ranword,[w[i]]);
                    residue := SiftAsWord(S,ranword);
                    if residue[2]>0 then
                        # factorization is unsuccessful;
                        # remainder is witness that SGS for S is not complete
                        g := Product(residue[1]);
                        # Print("k=",k," i=",i," m=",m," mlimit=",mlimit,"\n");
                        return g;
                    elif correct then
                        # enough to check whether base points are fixed
                        l:=0;
                        while l < Length(missing) do
                            l:=l+1;
                            if ImageInWord(missing[l],residue[1])
                              <> missing[l]
                            then
                                # remainder is not in S
                                g := Product(residue[1]);
                                return g;
                            fi;
                        od;
                    else
                        # plug in points from each orbit to check whether
                        # action on orbit is trivial
                        l:=0;
                        while l < Length(orbits) do
                            l:=l+1;
                            if Length(orbits[l]) > param[5] then
                                # on large orbits, plug in random points
                                j := 0;
                                jlimit := Maximum(param[6],basesize[l]);
                                while j < jlimit do
                                    j := j+1;
                                    ran := Random(1, Length(orbits[l]));
                                    if ImageInWord(orbits[l][ran],residue[1])
                                      <> orbits[l][ran]
                                    then
                                        #remainder is not in S
                                        g := Product(residue[1]);
                                        return g;
                                    fi;
                                od; #j loop
                            else
                                # on small orbits, plug in all points
                                j := 0;
                                while j < Length(orbits[l]) do
                                    j := j+1;
                                    if ImageInWord( orbits[l][j],residue[1] )
                                      <> orbits[l][j]
                                    then
                                        # remainder is not in S
                                        g:=Product(residue[1]);
                                        return g;
                                    fi;
                                od; #j loop
                            fi;
                        od; #l loop
                    fi;
                fi;
            od; #i loop
        od; #m loop
        if len <= 2*k then
            #finished making Schr. generators with all in S.aux
            k := param[1];
        fi;
    od; #k loop

    return S.identity;
end );


#############################################################################
##
#F  SCRSift( <S>, <g> ) . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  tries to factor g as product of cosetreps in S; returns remainder
##
 SCRSiftOld :=  function ( S, g )
     local stb,   # the stabilizer of S we currently work with
           bpt;   # first point of stb.orbit

     stb := S;
     while IsBound( stb.stabilizer ) do
         bpt := stb.orbit[1];
         if IsBound( stb.transversal[bpt^g] ) then
             while bpt <> bpt^g do
                 g := g*stb.transversal[bpt^g];
             od;
             stb := stb.stabilizer;
         else
             #current g witnesses that input was not in S
             return g;
         fi;
     od;

     return g;
 end;



 InstallGlobalFunction( SCRSift, function(S,g)
     local result;

#     return SCRSiftOld(S, g);

     result :=  SCR_SIFT_HELPER(S, g, Maximum(LargestMovedPoint(g),LargestMovedPoint(S!.generators)));

#     Assert(2,result = SCRSiftOld(S, g));
     return result;
end);



#############################################################################
##
#F  SCRStrongGenTest2( <S>, <param> ) . . . . . . . . . . . . . . . . . local
##
##  tests whether product of a random element of S and a random subproduct of
##  the  strong generators of S is  in S.  Computations  are carried out with
##  complete permutations.
##
InstallGlobalFunction( SCRStrongGenTest2, function ( S, param )
    local   x,i,k,m,      # loop variables
            ran1,ran2,    # random permutations
            string,       # random 0-1 string
            w,            # list containing random subproducts of generators
            len,          # number of generators of S
            len2,         # length of short random subproduct
            mlimit,       # number of random elements to be tested
            ranelement,   # random element of S
            T,  p,
            residue;      # remainder of ranelement after factorization

    k := 0;
    while k < param[3] do
        k := k+1;
        len := Length(S.aux);
        #in case of large S.aux, form random subproducts
        #otherwise, try all of them
        if len > 2*param[3] then
            ran1 := SCRRandomPerm(len);
            ran2 := SCRRandomPerm(len);
            len2 := Random(1, QuoInt(len,2));
            string := SCRRandomString(len+len2);

            # we form two random subproducts:
            # w[1] in a random ordering of all generators
            # w[2] in a random ordering of a random subset of them
            w:=[];
            w[1] := S.identity;
            for x in [1 .. len] do
                w[1] := w[1]*(S.aux[x^ran1]^string[x]);
            od;
            w[2] := S.identity;
            for x in [1 .. len2] do
                w[2] := w[2]*(S.aux[x^ran2]^string[x+len]);
            od;

        else
            # take next two generators of S (unless only one is left)
            w := [];
            w[1] := S.aux[2*k-1];
            if len > 2*k-1 then
                w[2] := S.aux[2*k];
            else
                w[2] := S.identity;
            fi;
        fi;

        # take random elements of S
        m := 0;
        mlimit := param[4]*S.diam;
        while m < mlimit do
            m:=m+1;
            ranelement := S.identity;
            T := S;
            while Length( T.generators ) <> 0  do
                p := Random( T.orbit );
                while p <> T.orbit[ 1 ]  do
                    ranelement := LeftQuotient( T.transversal[ p ],
                                          ranelement );
                    p := p ^ T.transversal[ p ];
                od;
                T := T.stabilizer;
            od;
            i := 0;
            while i < 2 do
                i := i+1;
                if w[i] <> S.identity then
                    # test whether product of ranelement and w[i] in S
                    ranelement := ranelement*w[i];
                    residue := SCRSift(S,ranelement);
                    if residue <> S.identity then
                        return residue;
                    fi;
                fi;
            od; #i loop
        od; #m loop
        if len <= 2*k then
            #finished checking all in S.aux
            k := param[3];
        fi;
    od; #k loop

    return S.identity;
end );


#############################################################################
##
#F  SCRNotice( <orb>, <transversal>, <genlist> )  . . . . . . . . . . . local
##
##  checks whether   orbit  is closed  for  the   action of  permutations  in
##  genlist. If not, returns orbit point and generator witnessing.
##
InstallGlobalFunction( SCRNotice,
    function ( orb, transversal, genlist )
    local flag, #first component of output; true if orb is closed for
                #action of genlist
          i,    #second component of output, index of point in orb moving out
          j ;   #third component, index of permutation in genlist moving orb[i]

    i := 0;
    flag := true;
    while i < Length(orb) and flag  do
        i := i+1;
        j := 0;
        while j < Length(genlist) and flag do
            j := j+1;
            if not IsBound(transversal[orb[i]^genlist[j]])  then
                flag := false;
            fi;
        od;
    od;

    return [flag,i,j];
end );


#############################################################################
##
#F  SCRExtend( <list> ) . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  given a partial Schreier tree of depth d,
##  SCRExtends the partial Schreier tree to depth d+1
##  input, output coded in list of length 5
##
InstallGlobalFunction( SCRExtend, function ( list )
    local orb,          #partial orbit
          transversal,  #partial transversal
          treegen,      #list of generators
          treegeninv,   #inverses of elements of treegen
                        #both treegen, treegeninv are used in transversal
          i, j,         #loop variables
          previous,     #index, showing end of level d-1 in orb
          len;          #length of orb at entering routine

    orb:=list[1];
    transversal:=list[2];
    treegen:=list[3];
    treegeninv:=list[4];
    previous:=list[5];
    len:=Length(orb);

    # for each point on level d, check whether one of the generators or
    # inverses moves it out of orb. If yes, add image to orb
    for i in [previous+1..len] do
        for j in [1..Length(treegen)] do
            if not IsBound(transversal[orb[i]^treegen[j]]) then
                transversal[orb[i]^treegen[j]] := treegeninv[j];
                Add(orb, orb[i]^treegen[j]);
            fi;
            if not IsBound(transversal[orb[i]^treegeninv[j]]) then
                transversal[orb[i]^treegeninv[j]] := treegen[j];
                Add(orb, orb[i]^treegeninv[j]);
            fi;
        od;
    od;

    # return Schreier tree of depth one larger
    return [orb,transversal,treegen,treegeninv,len];

end );


#############################################################################
##
#F  SCRSchTree( <S>, <new> )  . . . . . . . . . . . . . . . . . . . . . local
##
##  creates Schreier tree for the group generated by S.generators \cup new
##
InstallGlobalFunction( SCRSchTree, function ( S, new )
    local l,        #output of notice
          flag,     #first component of output
          i,        #second component of output
          j,        #third component of output
          word,     #list of permutations coding a coset representative
          g,        #the coset representative coded by word
          witness,  #a permutation moving a point out of S.orbit
          list;     #list coding input and output of 'extend'

    l := SCRNotice(S.orbit,S.transversal,new);
    flag := l[1];
    if flag then
        #do nothing; the orbit did not change
        return;
    else
        i := l[2];
        j := l[3];
        witness := new[j];
    fi;

    while not flag do
        word := CosetRepAsWord(S.orbit[1],S.orbit[i],S.transversal);
        g := Product(word);
        #add a new generator to treegen which moves S.orbit[1] out of S.orbit
        Add(S.treegen, g^(-1)*witness);
        Add(S.treegeninv, witness^(-1)*g);

        #recompute Schreier tree to new depth
        S.orbit := [S.orbit[1]];
        S.transversal := [];
        S.transversal[S.orbit[1]] := S.identity;
        S.treedepth := 0;
        list := [S.orbit,S.transversal,S.treegen,S.treegeninv,0];
        flag := false;

        #with k generators, we build only a tree of depth 2k
        while not flag and S.treedepth < 2*Length(S.treegen) do
            list := SCRExtend(list);
            S.orbit := list[1];
            S.transversal := list[2];
            if Length(S.orbit) = list[5] then
                #the tree did not extend; orbit is closed for treegen
                flag := true;
            else
                S.treedepth := S.treedepth + 1;
            fi;
        od;
        #increased S.orbit may not be closed for all generators of S
        l := SCRNotice(S.orbit,S.transversal,S.generators);
        flag := l[1];
        if not flag then
            i := l[2];
            j := l[3];
            witness := S.generators[j];
        fi;
    od;

    #update record components aux, diam
    S.aux := Concatenation(S.treegen,S.treegeninv,S.stabilizer.aux);
    S.diam := S.treedepth+S.stabilizer.diam;

end );


#############################################################################
##
#F  SCRRandomPerm( <d> )  . . . . . . . . . . . . . . . . . . . . . . . local
##
##  constructs random permutation in Sym(d)
##  without creating group record of Sym(d)
##
InstallGlobalFunction( SCRRandomPerm, function ( d )
    local   rnd,        # random permutation, result
            tmp,        # temporary variable for swapping
            i,  k;      # loop variables

    # use Floyd\'s algorithm
    rnd := [ 1 .. d ];
    for i  in [ 1 .. d-1 ]  do
        k := Random( 1, d+1-i );
        tmp := rnd[d+1-i];
        rnd[d+1-i] := rnd[k];
        rnd[k] := tmp;
    od;

    # return the permutation
    return PermList( rnd );
end );


#############################################################################
##
#F  SCRRandomString( <n> )  . . . . . . . . . . . . . . . . . . . . . . local
##
##  constructs random 0-1 string of length n
##  same steps as Random, but uses created random number for 28 bits
##
InstallGlobalFunction( SCRRandomString, function ( n )
    local i, j,     # loop variables
          k,        # number of 28 long substrings
          rnd,      # the random number which would be created by Random
          string,   # the random string constructed
          range;    # Upper value of range used for getting ints

    range := 2^28-1;

    string:=[];
    k:=QuoInt(n-1,28);
    for i in [0..k-1] do
        rnd := Random(0,range);
        # use each bit of rnd
        for j in [1 .. 28] do
            string[28*i+j] := rnd mod 2;
            rnd := QuoInt(rnd,2);
        od;
    od;

    # construct last <= 28 bits  of string
    rnd := Random(0, range);
    for j in [28*k+1 .. n] do
        string[j] := rnd mod 2;
        rnd := QuoInt(rnd,2);
    od;

    return string;
end );

#############################################################################
##
#F  SCRRandomSubproduct( <list>, <id> ) .  random subproduct of perms in list
##
InstallGlobalFunction( SCRRandomSubproduct, function( list, id )
    local string,  # 0-1 string containing the exponents of elements of list
          random,  # the random subproduct
          i;       # loop variable

    string := SCRRandomString(Length(list));
    random := id;
    for i in [1 .. Length(list)] do
        if string[i] = 1 then
            random := random*list[i];
        fi;
    od;

    return random;
end );

#############################################################################
##
#F  SCRExtendRecord( <G> )  . . . . . . . . . . . . . . . . . . . . . . local
##
##  defines record elements used at random stabilizer chain construction
##
InstallGlobalFunction( SCRExtendRecord, function(G)
    local list,       # list of stabilizer subgroups
          len,        # length of list
          i;          # loop variable

    list := ListStabChain(G);
    len := Length(list);
    list[len].diam := 0;
    list[len].aux := [];
    for i in [1 .. len - 1] do
        # list[len - i].real := list[len - i].generators;

        if Length(list[len - i].orbit) = 1 then
            # in this case, SCRSchTree will not do anything;
            # we have to define records treedepth, aux, and diameter
            list[len - i].treedepth := 0;
            list[len - i].aux := list[len - i + 1].aux;
            list[len - i].diam := list[len - i + 1].diam;
        fi;

        list[len - i].orbit := [ list[len - i].orbit[1] ];
        list[len - i].transversal := [];
        list[len - i].transversal[list[len - i].orbit[1]]
            := list[len - i].identity;
        list[len - i].treegen := [];
        list[len - i].treegeninv := [];
        SCRSchTree( list[len - i], list[len - i].generators );

    od;

end );


#############################################################################
##
#F  SCRRestoredRecord( <G> )  . . . . . . . . . . . . . . . . . . . . . local
##
##  restores usual group records after random stabilizer chain construction
##
InstallGlobalFunction( SCRRestoredRecord, function( G )
    local   sgs,  T,  S,  l,  pnt,o,ind;

    S := G;
    sgs := [ S.identity ];
    while IsBound( S.stabilizer )  do
        UniteSet( sgs, S.treegen );
        UniteSet( sgs, S.treegeninv );
        S := S.stabilizer;
    od;
    T := EmptyStabChain( sgs, G.identity );
    sgs := [ 2 .. Length( sgs ) ];
    S := T;
    while IsBound( G.stabilizer )  do
        InsertTrivialStabilizer( S, G.orbit[ 1 ] );
        S.genlabels   := sgs;
        S.generators  := G.generators;
        S.orbit       := G.orbit;
        S.transversal := G.transversal;
        o:=ShallowCopy(S.orbit);
        # check identity of transversal elements first: Most are
        # identical and thus element comparisons are relatively
        # infrequent
        while Length(o)>0 do

          ind:=S.transversal[o[1]];
          ind:=Filtered([1..Length(o)],
                  i->IsIdenticalObj(S.transversal[o[i]],ind));
          for l in sgs do
            if S.transversal[o[1]]=S.labels[l] then
              for pnt in o{ind} do # all these transv. elements are same
                S.translabels[ pnt ] := l;
              od;
            fi;
          od;
          o:=o{Difference([1..Length(o)],ind)}; # the rest
        od;

            #was:
            # (The element comparisons could be expensive)
            #for pnt  in S.orbit  do
            #    if S.transversal[ pnt ] = lab  then
            #        S.translabels[ pnt ] := l;
            #    fi;
            #od;

        sgs := Filtered( sgs, l ->
                       S.orbit[ 1 ] ^ S.labels[ l ] = S.orbit[ 1 ] );
        S := S.stabilizer;
        G := G.stabilizer;
    od;
    return T;
end );

#############################################################################
##
#F  VerifyStabilizer( <S>, <z>, <missing>, <correct> )  . . . .  verification
##
InstallGlobalFunction( VerifyStabilizer, function(S,z,missing,correct)
 #z is an involution, moving first base point
 # correct is boolean telling whether a base is known
 # if yes, missing contains the base points which do not occur in the base of S
 local pt1,            # the first base point
       zinv,           # inverse of z
       pt2,            # pt1^zinv
       flag,           # Boolean; true if z exchanges pt1 and pt2
       stab,           # the stabilizer of pt1 in S
       chain,          # stab after base change, to bring pt2 first
       stabpt2,        # stabilizer of pt2 in chain
       result,         # output, witness perm if something is wrong
       g,              # generator of stabpt2
       where1,         # stores which orbit of stab pts of S.orbit belong to
       orbit1count,    # index running through orbits of stab
       leaders,        # list of orbit representatives of stab
       i, j, l,        # loop variables
       residue,        # result of sifting as word
       where2,         # boolean list to mark orbits of stabpt2 as processed
       k,              # point of an orbit of stab
       gen,            # a generator of stab
       transversal,    # transversal of stab, on all of its orbits
       orb,            # an orbit of stabpt2
       img,            # image of a point at computation of orb
       pnt,            # a point from orb
       w1, w2, w3, w4, # words/permutations coding coset representatives
       w1inv,          # inverse of w1
       schgen;         # Schreier generator

    pt1 := S.orbit[1];
    zinv := z^(-1);
    pt2 := pt1^zinv;
    result := S.identity;
    stab := S.stabilizer;
    if pt2^zinv = pt1 then
       flag := true;
       result := SCRSift(stab, z^2);
    else
       flag := false;
    fi;

    # store which orbit of stab the pts of S.orbit belong to
    # in each orbit, compute transversals from a representative
    where1 := []; # orbits of stab
    leaders := [pt2];
    orbit1count := 1;
    transversal := [];
    transversal[pt2] := S.identity;
    where1[pt2] := 1;
    orb := [pt2];
    j := 1;
    while j <= Length( orb )  do
    for gen  in stab.generators  do
       k := orb[j] / gen;
       if not IsBound( transversal[k] )  then
             transversal[k] := gen;
             Add( orb, k );
             where1[k] := orbit1count;
          fi;
       od;
       j := j + 1;
    od;
    for i in S.orbit do
        if not IsBound(where1[i]) then
           orbit1count := orbit1count + 1;
           Add(leaders, i);
           orb := [i];
           where1[i] := orbit1count;
           transversal[i] := S.identity;
           j := 1;
           while j <= Length( orb )  do
             for gen  in stab.generators  do
                 k := orb[j] / gen;
                 if not IsBound( transversal[k] )  then
                    transversal[k] := gen;
                    Add( orb, k );
                    where1[k] := orbit1count;
                 fi;
             od;
             j := j + 1;
           od;
        fi;
    od;

   # check that conjugates of point stabilizers of stab are subgroups of stab
   chain:=StructuralCopy(stab);
   for j in [1..Length(leaders)] do
       if result = S.identity then
           i := leaders[Length(leaders)+1-j];
           ChangeStabChain( chain, [i], false );
           if i = pt2 then
              w1 := z;
              w1inv := zinv;
           else
              w1 := CosetRepAsWord(pt1, i, S.transversal);
              w1 := Product(w1);
              w1inv := w1^(-1);
           fi;
           for g in chain.stabilizer.generators do
               if result = S.identity then
                  if correct then
                     residue := SiftAsWord(stab, [w1inv,g,w1]);
                     if residue[2] <> 0 then
                        result := Product(residue[1]);
                     else
                        l := 0;
                        while ( l < Length(missing) ) and ( result = S.identity ) do
                           l:=l+1;
                              if ImageInWord(missing[l],residue[1])
                                  <> missing[l]  then
                                  # remainder is not in S
                                  result := Product(residue[1]);
                              fi;
                        od;
                     fi;
                  else
                     result := SCRSift(stab, w1inv*g*w1);
                  fi;
               fi;
           od;
       fi;
   od;

 if result = S.identity then
    stabpt2 := chain.stabilizer;
    # process orbits of stabpt2
    where2:= BlistList( [1..Length(where1)],[] ) ;
    for i in S.orbit do
        if result = S.identity and (not where2[i]) then
           orb := [i];
           where2[i] := true;
           for pnt  in orb  do
               for gen  in stabpt2.generators  do
                   img := pnt^gen;
                   if not where2[img]  then
                      Add( orb, img );
                      where2[img] := true;
                   fi;
               od;
           od;

           # if we hit a new orbit of stabpt2
           # and if z exchanges pt1 and pt2 then
           # mark the orbit
           if flag and not where2[i^z] then
              orb := [i^z];
              where2[i^z] := true;
              for pnt  in orb  do
                 for gen  in stabpt2.generators  do
                    img := pnt^gen;
                    if not where2[img]  then
                       Add( orb, img );
                       where2[img] := true;
                    fi;
                 od;
              od;
           fi;

           # compute Schreier generator either as a word or perm
           # if i is not a fixed point of z,
           # we have to compute a Schreier generator
           w1 := CosetRepAsWord(pt1, leaders[where1[i]], S.transversal);
           w2 := CosetRepAsWord(leaders[where1[i]], i, transversal);
           w3 := CosetRepAsWord(leaders[where1[i^z]], i^z, transversal);
           if where1[i] <> where1[i^z] then
               w4 := CosetRepAsWord(pt1,leaders[where1[i^z]], S.transversal);
           else
               w4 := w1;
           fi;
           schgen := (Product(w1))^(-1)*(Product(w2))^(-1);
           if correct then
               schgen := Concatenation([schgen,z],w3,w4);
           else
               schgen := schgen*z*Product(w3)*Product(w4);
           fi;

           # sift Schreier generator either as a word or perm
           if correct then
              residue := SiftAsWord(stab, schgen);
              if residue[2] <> 0 then
                 result := Product(residue[1]);
              else
                  l := 0;
                  while ( l < Length(missing) ) and ( result = S.identity ) do
                     l:=l+1;
                     if ImageInWord(missing[l],residue[1])
                               <> missing[l]  then
                          # remainder is not in S
                          result := Product(residue[1]);
                     fi;
                  od;
               fi;
           else
              result := SCRSift(stab, schgen);
           fi;
        fi;  # result = S.identity and not where2[i]
     od;
 fi;

 return result;

end );

#############################################################################
##
#F  VerifySGS( <S>, <missing>, <correct> )  . . . . . . . . . .  verification
##
InstallGlobalFunction( VerifySGS, function(S,missing,correct)
 # correct is boolean telling whether a base is known
 # if yes, missing contains the base points which do not occur in the base of S
 local n,         # degree of S
       list,      # list of subgroups in stabchain
       result,    # result of the test
       len,       # length of list
       i,l,       # loop variables
       residue,   # result of sifting as word
       temp,      # subgroup of S we currently work with
       temp2,     # temp, with possible extension on blocks
       gen,       # the generator whose addition we verify
       longer,    # generator list of temp, after gen is added
       gencount,  # counts the generators to be verified
       set,       # set of orbit of temp
       orbit,     # orbit of temp after adding gen
       blks,      # images of block when gen is added
       extension, # list of length 2; first coord. is temp2, extended by
                  # the action on blks, second coord. is newgen
       newgen,    # the extension of gen
       leader,    # first point in orbit of temp2
       block,     # block containing leader
       point,     # another point from block
       pos;       # position of set in blks

 n := LargestMovedPoint(S.generators);
 list := ListStabChain(S);
 len := Length(list);
 result := S.identity;

 # verify the subgroup chain from bottom up
 i := 1;
 while i < len  and  result = S.identity  do
     temp := ShallowCopy(list[len - i + 1]);
     InsertTrivialStabilizer(temp, list[len -i].orbit[1]);
     gencount := 0;

     # add one generator a time
     while (gencount < Length(list[len - i].generators)) and (result= S.identity ) do
         gencount := gencount + 1;
         gen := list[len - i].generators[gencount];
         set := Set( temp.orbit );

         # if adding gen did not change the fundamental orbit, just sift gen
         if set = OnSets(set,gen) then
            if correct then
               residue := SiftAsWord(temp, [gen]);
               if residue[2] <> 0 then
                  result := Product(residue[1]);
               else
                  l := 0;
                  while ( l < Length(missing) ) and ( result = S.identity ) do
                     l:=l+1;
                     if ImageInWord(missing[l],residue[1])
                               <> missing[l]  then
                          # remainder is not in S
                          result := Product(residue[1]);
                     fi;
                  od;
               fi;
            else
               result := SCRSift(temp, gen);
            fi;
         # if the fundamental orbit increased, compute block system
         # obtained when adding gen
         else
            if Length(set) =1 then
                temp2 := temp;
                newgen := gen;
            # otherwise, compute the action on blocks
            else
                longer := Concatenation(temp.generators, [gen]);
                orbit := OrbitPerms( longer, temp.orbit[ 1 ] );
                blks := Blocks( GroupByGenerators( longer ), orbit, set );
                if Length(blks) * Length(set) <> Length(orbit) then
                    result := "false0";
                else
                    pos := Position( blks, set );
                    extension := ExtensionOnBlocks( temp, n, blks, [gen] );
                    temp2 := extension[1];
                    newgen := extension[2][1];
                    InsertTrivialStabilizer(temp2, n + pos);
                fi;
            fi;

            # first generator in first group can be verified easily
            if i=1 and Length(set) =1 then
                result := newgen^(CycleLengthOp(newgen,temp2.orbit[1]));
                AddGeneratorsExtendSchreierTree(temp2, [newgen]);
            elif result = S.identity then
                AddGeneratorsExtendSchreierTree( temp2, [ newgen ] );
                blks := Blocks( GroupByGenerators(temp2.generators),
                                temp2.orbit);
                if Length(blks) > 1 then
                   leader := temp2.orbit[1];
                   block := First(blks, x -> leader in x);
                   point := First(block, x -> x <> leader);
                   newgen := Product(CosetRepAsWord(leader ,point,
                                       temp2.transversal));
                   temp2 := temp2.stabilizer;
                   InsertTrivialStabilizer(temp2, leader);
                   AddGeneratorsExtendSchreierTree(temp2, [newgen]);
                   result := VerifyStabilizer(temp2,newgen,missing,correct);
                   if leader > n then
                      AddGeneratorsExtendSchreierTree(temp,[RestrictedPermNC
                          (newgen, [1..n])]);
                   else
                      temp := temp2;
                   fi;
                   gencount := gencount - 1;
                else
                   result := VerifyStabilizer(temp2,newgen,missing,correct);
                   if temp2.orbit[1] > n then
                      AddGeneratorsExtendSchreierTree(temp,[gen]);
                   fi;
                fi;
                if result <> S.identity and temp2.orbit[1] > n then
                     result := RestrictedPermNC(result, [1..n]);
                fi;

            fi;
        fi;
    od;
    i := i + 1;
 od;

 return result;

end );

#############################################################################
##
#F  ExtensionOnBlocks( <S>, <n>, <blks>, <elms> ) . . . . . . . . . extension
##
InstallGlobalFunction( ExtensionOnBlocks, function( S, n, blks, elms )
    local   where,  j,  k,  hom,  T,  newelms;

      # list which block the elements of the orbit belong to
      where := [];
      for j in [1..Length(blks)] do
          for k in blks[j] do
              where[k] := j;
          od;
      od;

      hom := function( g )
          local  perm,  j;

          perm := [1..n];
          for j in [1..Length(blks)] do
              perm[n+j] := n+where[blks[j][1]^g];
          od;
          perm := PermList(perm);
          return g * perm;
      end;

      T := EmptyStabChain( [  ], S.identity );
      ConjugateStabChain( S, T, hom, S.identity );

      # construct extensions of permutations in elms
      newelms := List( elms, hom );

      return [ T, newelms ];
end );

#############################################################################
##
#F  ClosureRandomPermGroup( <G>, <genlist>, <options> ) make closure randomly
##
InstallGlobalFunction( ClosureRandomPermGroup,
    function( G, genlist, options )
    local  k,          # number of pairs of subproducts of generators in
                       # testing result
           givenbase,  # ordering from which initial base points should
                       # be chosen
           gens,       # generators in genlist that are not in <G>
           g,          # element of gens
           degree,     # degree of closure
           orbits,     # list of orbits of closure
           orbits2,    # list of orbits of closure
           i,j,        # loop variables
           param,       # list of parameters guiding number of repetitions
                        # in random constructions
           where,       # list indicating which orbit contains points in domain
           basesize,    # list; i^th entry = number of base points in orbits[i]
           ready,       # boolean; true if stabilizer chain ready
           new,         # list of permutations to be added to stab. chain
           result,      # output of checking phase; nontrivial if stabilizer
                        # chain is incorrect
           base,        # ordering of domain from which base points are taken
           missing,     # if a correct base was provided by input, missing
                       # contains those points of it which are not in
                       # constructed base
           cnt,        # iteration counter
           correct;     # boolean; true if a correct base is given

# warning:  options.base should be compatible with BaseOfGroup(G)

    gens := Filtered( genlist, gen -> not(IsOne(SCRSift(G,gen))) );
    if Length(gens) > 0  then

        G.identity := One(gens[1]) ;
        if options.random = 1000 then
            #case of deterministic computation with known size
            k := 1;
        else
            k:=First([1..14],x->(3/5)^x<1-options.random/1000);
        fi;
        if IsBound(options.knownBase) then
            param := [k,4,0,0,0,0];
        else
            param := [QuoInt(k,2),4,QuoInt(k+1,2),4,50,5];
        fi;
        if options.random <= 200 then
            param[2] := 2;
            param[4] := 2;
        fi;

#param[1] = number of pairs of random subproducts from generators in
#           first checking phase
#param[2] = (number of random elements from created set)/S.diam
#           in first checking phase
#param[3] = number of pairs of random subproducts from generators in
#           second checking phase
#param[4] = (number of random elements from created set)/S.diam
#           in second checking phase
#param[5] = maximum size of orbits in  which we evaluate words on all
#           points of orbit
#param[6] = minimum number of random points from orbit to plug in to check
#           whether given word is identity on orbit

        degree := LargestMovedPoint( Union( G.generators, gens ) );

        # prepare input of construction
        if IsBound(options.base) then
            givenbase := options.base;
        else
            givenbase := [];
        fi;

        if IsBound(options.knownBase) then
            correct := true;
        else
            correct := false;
        fi;

        if correct then
            # if correct  base was given as input,
            # no need for orbit information
            base := Set( givenbase );
            for i in BaseStabChain(G) do
                if not i in base then
                    Add( givenbase, i );
                fi;
            od;
            base := Concatenation(givenbase,Difference(options.knownBase,
                                                       givenbase));
            missing := Difference(options.knownBase,BaseStabChain(G));
            basesize := [];
            where := [];
            orbits := [];
        else
            # create ordering of domain used in choosing base points and
            # compute orbit information
            base := Set( givenbase );
            for i in BaseStabChain(G) do
                if not i in base then
                    Add( givenbase, i );
                fi;
            od;
            base := Concatenation(givenbase,Difference([1..degree],givenbase));
            missing := [];
            orbits2 := OrbitsPerms( Union( G.generators, gens ), [1..degree] );
            #throw away one-element orbits
            orbits:=[];
            j:=0;
            for i in [1..Length(orbits2)] do
                if Length(orbits2[i]) >1 then
                    j:=j+1; orbits[j]:= orbits2[i];
                fi;
            od;
            basesize:=[];
            where:=[];
            for i in [1..Length(orbits)] do
                basesize[i]:=0;
                for j in [1..Length(orbits[i])] do
                    where[orbits[i][j]]:=i;
                od;
            od;
            # temporary solution to speed up of handling
            # of lots of small orbits until compiler
            if Length(orbits) > degree/40 then
                param[1] := 0;
                param[3] := k;
            fi;
        fi;

        if not IsBound(G.aux) then
            SCRExtendRecord(G);
        fi;
        new := gens;

        #the first call of SCRMakeStabStrong has top:=false
        #in order to add gens to the generating set of G;
        #further calls have top:=true, in order not to add
        #output of SCRStrongGenTest to generating set.
        #remark: adding gens to the generating set of G before
        #calling SCRMakeStabStrong gives a nasty error if first base
        #point changes
        for g in gens do
            if not(IsOne(SCRSift(G,g))) then
                SCRMakeStabStrong (G,[g],param,orbits,
                        where,basesize,base,correct,missing,false);
            fi;
        od;

        cnt:=0;
        ready := false;
        while not ready do
          if    IsBound(options.limit)
            and SizeStabChain(G)=options.limit
          then
              ready := true;
          else
              # we do a little random testing, to ensure heuristically a
              # correct result
              if correct then
                  result := SCRStrongGenTest(G,[1,10/G.diam,0,0,0,0],orbits,
                                      basesize,base,correct,missing);
              else
                  result := SCRStrongGenTest2(G,[0,0,1,10/G.diam,0,0]);
              fi;
              if not(IsPerm(result) and IsOne(result)) then
                  new := [result];
                  ready := false;
              elif options.random = 1000 then
                  G.restored := SCRRestoredRecord(G);
                  result := VerifySGS( G.restored, missing, correct );
                  cnt:=cnt+1;
                  if cnt>99 then
                    # in rare cases this loop iterates for a very long time.
                    # In this case, rather create a new chain, than try to
                    # fix the problematic one
                    #Error("infinite loop?");
                    return StabChainRandomPermGroup(G.generators,G.identity,
                            options);
                  fi;
              elif options.random > 0 then
                  result := SCRStrongGenTest
                          (G,param,orbits,basesize,base,correct,missing);
              fi;
              if not(IsPerm(result) and IsOne(result)) then
                  if not IsPerm(result) then
                     repeat
                         result := SCRStrongGenTest2(G,[0,0,1,10/G.diam,0,0]);
                     until not(IsPerm(result) and IsOne(result));
                  fi;
                  new := [result];
                  ready := false;
              elif correct or options.random = 0 or options.random = 1000 then
                  ready := true;
              else
                  result := SCRStrongGenTest2(G,param);
                  if IsPerm(result) and IsOne(result) then
                      ready := true;
                  else
                      new := [result];
                      ready := false;
                  fi;
              fi;
              if not ready then
                Unbind(G.restored);
                SCRMakeStabStrong (G,new,param,orbits,
                        where,basesize,base,correct,missing,true);
                #Print("D ",SizeStabChain(G),"\n");
              fi;
          fi;
        od;

        if not IsBound(options.temp) or options.temp = false then
             if IsBound( G.restored ) then
                G := G.restored;
             else
                G := SCRRestoredRecord(G);
             fi;
        else
             G.basesize := basesize;
             G.correct := correct;
             G.orbits := orbits;
             G.missing := missing;
             G.base := base;
        fi;

    fi; # if Length(gens) > 0


    # return the closure
    return G;

end );

#############################################################################


