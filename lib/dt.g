#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Wolfgang Merkwitz.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file initializes Deep Thought.
##
##  Deep Thought deals with trees.  A tree < tree > is a concatenation of
##  several nodes where each node is a 5-tuple of immediate integers.  If
##  < tree > is an atom it contains only one node,  thus it is itself a
##  5-tuple. If < tree > is not an atom we obtain its list representation by
##
##  < tree >  :=  topnode(<tree>) concat left(<tree>) concat right(<tree>) .
##
##  Let us denote the i-th node of <tree> by (<tree>, i)  and the tree rooted
##  at (<tree>, i) by tree(<tree>, i).  Let <a> be tree(<tree>, i)
##  The first entry of (<tree>, i) is pos(a),
##  and the second entry is num(a). The third entry of (<tree>, i) gives a
##  mark.(<tree>, i)[3] = 1  means that (<tree>, i) is marked,
##  (<tree>, i)[3] = 0 means that (<tree>, i) is not marked. The fourth entry
##  of (<tree>, i) contains the number of nodes of tree(<tree>, i).  The
##  fifth entry of (<tree>, i) finally contains a boundary for
##  pos( tree(<tree>, i) ).  (<tree>, i)[5] <= 0 means that
##  pos( tree(<tree>, i) ) is unbounded.  If tree(<tree>, i) is an atom we
##  already know that pos( tree(<tree>, i) ) is unbound.  Thus we then can
##  use the fifth component of (<tree>, i) to store the side.  In this case
##  (<tree>, i)[5] = -1 means  that tree(<tree>, i) is an atom from the
##  right hand word, and (<tree>, i)[5] = -2 means that tree(<tree>, i) is
##  an atom from the left hand word.
##
##  A second important data structure deep thought deals with is a deep
##  thought monomial. A deep thought monomial g_<tree> is a product of
##  binomial coefficients with a coefficient c. Deep thought monomials
##  are represented in this implementation by formula
##  vectors,  which are lists of integers.  The first entry of a formula
##  vector is 0,  to distinguish formula vectors from trees.  The second
##  entry is the coefficient c,  and the third and fourth entries are
##  num( left(tree) ) and num( right(tree) ).  The remaining part of the
##  formula vector is a concatenation of pairs of integers.  A pair (i, j)
##  with i > 0 represents binomial(x_i, j).  A pair (0, j) represents
##  binomial(y_gen, j) when word*gen^power is calculated.
##
##  Finally deep thought has to deal with pseudo-representatives. A
##  pseudo-representative <a> is stored in list of length 4. The first entry
##  stores left( <a> ),  the second entry contains right( <a> ),  the third
##  entry contains num( <a> ) and the last entry finally gives a boundary
##  for pos( <b> ) for all trees <b> which are represented by <a>.
##




#############################################################################
##
#F  Dt_Mkavec(<pr>)
##
##  'Dt_Mkavec' returns the avec for the pc-presentation <pr>.
##
BindGlobal( "Dt_Mkavec", function(pr)
    local  i,j,vec;

    vec := [];
    vec[Length(pr)] := 1;
    for  i in [Length(pr)-1,Length(pr)-2..1]  do
        j := Length(pr);
        while  j >= 1  do
            if  j = vec[i+1]  then
                vec[i] := j;
                j := 0;
            else
                j := j-1;
                if  j < i  and  IsBound(pr[i][j])  then
                    vec[i] := j+1;
                    j := 0;
                fi;
                if  j > i  and  IsBound(pr[j][i])  then
                    vec[i] := j+1;
                    j := 0;
                fi;
            fi;
        od;
    od;
    for  i in [1..Length(pr)]  do
        if  vec[i] < i+1  then
            vec[i] := i+1;
        fi;
    od;
    return vec;
end );



#############################################################################
##
#F  Dt_IsEqualMonomial(<vec1>, <vec2>) . . . . . .  test if <vec1> and <vec2>
##                                                represent the same monomial
##
##  'Dt_IsEqualMonomial' returns "true" if <vec1> and <vec2> represent the
##  same  monomial, and "false" otherwise.
BindGlobal( "Dt_IsEqualMonomial", function(vec1,vec2)
    local  i;

    if  Length(vec1) <> Length(vec2)  then
        return false;
    fi;
    #  Since the first four entries of a formula vector doesn't contain
    #  any information about the monomial it represents,  it suffices to
    #  compare the remaining entries.
    for  i in [5..Length(vec1)]  do
        if  not vec1[i] = vec2[i]  then
            return false;
        fi;
    od;
    return true;
end );




#############################################################################
##
#F  Dt_Sort2(<vector>) . . . . . . . . . . . . . . . .  sort a formula vector
##
##  'Dt_Sort2' sorts the pairs of integers in the formula vector <vector>
##  representing the binomial coefficients such that
##  <vector>[5] < <vector>[7] < .. < vector[m-1],  where m is the length
##  of <vector>.  This is done for a easier comparison of formula vectors.
##
BindGlobal( "Dt_Sort2", function(vector)
    local  i,list1,list2;

    list1 := vector{[5,7..Length(vector)-1]};
    list2 := vector{[6,8..Length(vector)]};
    SortParallel(list1,list2);
    for  i in [1..Length(list1)]  do
        vector[ 2*i+3 ] := list1[i];
        vector[ 2*i+4 ] := list2[i];
    od;
end );


#############################################################################
##
#F  Dt_AddVecToList(<evlist>,<evlistvec>,<formvec>,<pr>)
##
##  'Dt_AddVecToList' adds the formula vector <formvec> to the list <evlist>,
##  computes the corresponding coefficient vector and adds the latter to
##  the list <evlistvec>.
##
BindGlobal( "Dt_AddVecToList", function(evlist, evlistvec, formvec, pr)
    local    i,j,k;

    Add(evlist, formvec);
    k := [];
    for  i in [1..Length(pr)]  do
        k[i] := 0;
    od;
    j := pr[ formvec[3] ][ formvec[4] ];
    #  the coefficient that the monomial represented by <formvec> has
    #  in each polynomial f_l is obtained by multiplying <formvec>[2]
    #  with the exponent which the group generator g_l has in the
    #  in the word representing the commutator of g_(formvec[3]) and
    #  g_(formvec[4]) in the presentation <pr>.
    for  i in [3,5..Length(j)-1]  do
        k[ j[i] ] := formvec[2]*j[i+1];
    od;
    Add(evlistvec, k);
end );


#############################################################################
##
#F  Dt_add( <pol>, <pols>, <pr> )
##
##  'Dt_add' adds the deep thought monomial <pol> to the list of polynomials
##  <pols>,  such that afterwards <pols> represents a simplified polynomial.
##
BindGlobal( "Dt_add", function(pol, pols, pr)
    local  j,k,rel, pos, flag;

    # first sort the deep thought monomial <pol> to compare it with the
    # monomials contained in <pols>.
    Dt_Sort2(pol);
    # then look which component of <pols> contains <pol> in case that
    # <pol> is contained in <pols>.
    pos := DT_evaluation(pol);
    if  not IsBound( pols[pos] )  then
        # create the component <pols>[<pos>] and add <pol> to it
        pols[pos] := rec( evlist := [], evlistvec := [] );
        Dt_AddVecToList( pols[pos].evlist, pols[pos].evlistvec, pol, pr );
        return;
    fi;
    flag := 0;
    for  k in [1..Length( pols[pos].evlist ) ]  do
        # look for <pol> in <pols>[<pos>] and if <pol> is contained in
        # <pols>[<pos>] then adjust the corresponding coefficient vector.
        if  Dt_IsEqualMonomial( pol, pols[pos].evlist[k] )  then
            rel := pr[ pol[3] ][ pol[4] ];
            for  j in [3,5..Length(rel)-1]  do
                pols[pos].evlistvec[k][ rel[j] ] :=
                  pols[pos].evlistvec[k][ rel[j] ] + pol[2]*rel[j+1];
            od;
            flag := 1;
            break;
        fi;
    od;
    if  flag = 0  then
        # <pol> is not contained in <pols>[<pos>] so add it to <pols>[<pos>]
        Dt_AddVecToList(pols[pos].evlist, pols[pos].evlistvec, pol, pr);
    fi;
end );


#############################################################################
##
#F  Dt_Convert(<sortedpols>)
##
##  'Dt_Convert' converts the list of formula vectors <sortedpols>. Before
##  applying <Dt_Convert> <sortedpols> is a list of records with the
##  components <evlist> and <evlistvec> where <evlist> contains deep thought
##  monomials and <evlistvec> contains the corresponding coefficient vectors.
##  <Dt_Convert> merges the <evlist>-components of the records contained
##  in <sortedpols> into one component <evlist> and the <evlistvec>-components
##  into one component <evlistvec>.
##
BindGlobal( "Dt_Convert", function(sortedpols)
    local  k,res;

    if  Length(sortedpols) = 0  then
        return  0;
    fi;
    res := rec(evlist := [],
               evlistvec :=[]);
    for  k in sortedpols  do
        Append(res.evlist, k.evlist);
        Append(res.evlistvec, k.evlistvec);
    od;
    return res;
end );


#############################################################################
##
#F  Dt_ConvertCoeffVecs(<evlistvec>)
##
##  'Dt_ConvertCoeffVecs' converts the coefficient vectors in the list
##  <evlistvec>. Before applying <Dt_ConvertCoeffVecs>, an entry
##  <evlistvec>[i][j] = k means that the deep thought monomial <evlist>[i]
##  occurs in the polynomial f_j with coefficient k. After applying
##  <Dt_ConvertCoeffVecs> a pair [j, k] occurring in <evlistvec>[i] means that
##  <evlist>[i] occurs in f_j with coefficient k.
##
BindGlobal( "Dt_ConvertCoeffVecs", function(evlistvec)
    local i,j,res;

    for  i in [1..Length(evlistvec)]  do
        res := [];
        for  j in [1..Length(evlistvec[i])]  do
            if  evlistvec[i][j] <> 0  then
                Append(res, [j, evlistvec[i][j] ]);
            fi;
        od;
        evlistvec[i] := res;
    od;
end );



#############################################################################
##
#F  CalcOrder( <word>, <dtrws> )
##
##  CalcOrder computes the order of the word <word> in the group determined
##  by the rewriting system <dtrws>
##
DeclareGlobalName( "CalcOrder" );
BindGlobal( "CalcOrder", function(word, dtrws)
    local gcd, m;

    if  Length(word) = 0  then
        return 1;
    fi;
    if  not IsBound(dtrws![PC_EXPONENTS][ word[1] ])  then
        return 0;
    fi;
    gcd := Gcd(dtrws![PC_EXPONENTS][ word[1] ], word[2]);
    m := QuoInt( dtrws![PC_EXPONENTS][ word[1] ], gcd);
    gcd := DTPower(word, m, dtrws);
    return  m*CalcOrder(gcd, dtrws);
end );


#############################################################################
##
#F  CompleteOrdersOfRws( <dtrws> )
##
##  CompleteOrdersOfRws computes the orders of the generators of the
##  deep thought rewriting system <dtrws>
##
BindGlobal( "CompleteOrdersOfRws", function(dtrws)
    local  i,j;

    dtrws![PC_ORDERS] := [];
    for  i in [dtrws![PC_NUMBER_OF_GENERATORS],dtrws![PC_NUMBER_OF_GENERATORS]-1..1]
         do
        # Print("determining order of generator ",i,"\n");
        if  not IsBound( dtrws![PC_EXPONENTS][i] )  then
            j := 0;
        elif  not IsBound( dtrws![PC_POWERS][i] )  then
            j := dtrws![PC_EXPONENTS][i];
        else
            j := dtrws![PC_EXPONENTS][i]*CalcOrder(dtrws![PC_POWERS][i], dtrws);
        fi;
        if  j <> 0  then
            dtrws![PC_ORDERS][i] := j;
        fi;
    od;
end );


#############################################################################
##
#F  Dt_RemoveHoles( <list> )
##
##  Dt_RemoveHoles removes all empty entries from <list>
##  It is similar to Compacted(), but works in-place
##
BindGlobal( "Dt_RemoveHoles", function( list )
    local  skip, i;

    skip := 0;
    i := 1;
    while  i <= Length(list)  do
        while  not IsBound(list[i])  do
            skip := skip + 1;
            i := i+1;
        od;
        list[i-skip] := list[i];
        i := i+1;
    od;
    for  i in  [Length(list)-skip+1..Length(list)]  do
        Unbind(list[i]);
    od;
end );



#############################################################################
##
#F  ReduceCoefficientsOfRws( <dtrws> )
##
##  ReduceCoefficientsOfRws reduces all coefficients of each deep thought
##  polynomial f_l modulo the order of the l-th generator.
##
BindGlobal( "ReduceCoefficientsOfRws", function(dtrws)
    local  i,j,k, pseudoreps;

    pseudoreps := dtrws![PC_DEEP_THOUGHT_POLS];
    i := 1;
    while  IsRecord(pseudoreps[i])  do
        for  j in [1..Length(pseudoreps[i].evlistvec)]  do
            for  k in [2,4..Length(pseudoreps[i].evlistvec[j])]  do
                if  IsBound( dtrws![PC_ORDERS][ pseudoreps[i].evlistvec[j][k-1] ] )
                    and  (pseudoreps[i].evlistvec[j][k] > 0  or
                          pseudoreps[i].evlistvec[j][k] <
                          -dtrws![PC_ORDERS][ pseudoreps[i].evlistvec[j][k-1] ]/2)
                    then
                    pseudoreps[i].evlistvec[j][k] :=
                      pseudoreps[i].evlistvec[j][k] mod
                      dtrws![PC_ORDERS][ pseudoreps[i].evlistvec[j][k-1] ];
                fi;
            od;
            DTCompress( pseudoreps[i].evlistvec[j] );
            if  Length( pseudoreps[i].evlistvec[j] ) = 0  then
                Unbind( pseudoreps[i].evlistvec[j] );
                Unbind( pseudoreps[i].evlist[j] );
            fi;
        od;
        Dt_RemoveHoles( pseudoreps[i].evlistvec );
        Dt_RemoveHoles( pseudoreps[i].evlist );
        i := i+1;
    od;
end );


#############################################################################
##
##  Dt_GetMax( <tree>, <number>, <pr> )
##
##  Dt_GetMax returns the maximal value for pos(tree) if num(tree) = <number>.
##
BindGlobal( "Dt_GetMax", function(tree, number, pr)
    local rel, position;

    if  Length(tree) = 5  then
        return tree[5];
    else
        if  Length(tree) = 4  then
            if  Length(tree[1]) = 4  then
                if  Length(tree[2]) = 4  then
                    rel := pr[ tree[1][3] ][ tree[2][3] ];
                else
                    rel := pr[ tree[1][3] ][ tree[2][2] ];
                fi;
            else
                if  Length(tree[2]) = 4  then
                    rel := pr[ tree[1][2] ][ tree[2][3] ];
                else
                    rel := pr[ tree[1][2] ][ tree[2][2] ];
                fi;
            fi;
        else
            rel := pr[ tree[7] ][ tree[ 5*(tree[9]+1)+2 ] ];
        fi;
        position := Position(rel, number) + 1;
        if  rel[position] < 0  or  rel[position] > 100  then
            return 0;
        else
            return rel[position];
        fi;
    fi;
end );


#############################################################################
##
#F  Dt_GetNumRight( <tree> )
##
##  Dt_GetNumRight  returns num( right( tree ) ).
##
BindGlobal( "Dt_GetNumRight", function(tree)

    if Length(tree) <> 4  then
        return  tree[ 5*(tree[9]+1)+2 ];
    fi;
    if Length(tree[2]) <> 4  then
        return  tree[2][2];
    fi;
    return  tree[2][3];
end );



###########################################################################
##
#F  Calcrepsn(<n>, <avec>, <pr>, <max>)
##
##  'Calcrepsn' returns the polynomials f_{n1},...,f_{nm} which have to be
##  evaluated when computing word*g_n^(y_n).  Here m denotes the composition
##  length of the nilpotent group G given by the presentation <pr>.  This is
##  done  by first calculating a complete system of <n>-pseudo-representatives
##  for the presentation <pr> with boundary <max>. Then this system is used
##  to get the required polynomials
##
##  If g_n is in the center of the group determined by the presentation <pr>
##  then there don't exist any representatives except for the atoms and
##  finally 0 will be returned.
##
BindGlobal( "Calcrepsn", function(n, avec, pr, max)

    local i,j,k,l,       #  loop variables
          x,y,z,a,b,c,   #  trees
          reps,          #  list of pseudo-representatives
          pols,          #  stores the deep thought polynomials
          boundary,      #  boundary for loop
          hilf,
          pos,
          start,
          max1, max2;    #  maximal values for pos(x) and pos(y)
    reps := [];
    pols := [];

    for i  in [n..Length(pr)]  do
        #  initialize reps[i] to contain representatives for the atoms
        if  i <> n  then
            reps[i] := [ [1,i,0,1,-2] ];
        else
            reps[i] := [ [1,i,0,1,-1] ];
        fi;
    od;
    #  first compute the pseudo-representatives which are also representatives
    for  i in [n..max]  do
        if  i < avec[n]  then
            boundary := i-1;
        else
            boundary := avec[n]-1;
        fi;
        #  to get the representatives of the non-atoms loop over j and k
        #  and determine the representatives for all trees <z> with
        #  num(<z>) = i,  num( left(<z>) ) = j,  num( right(<z>) ) = k
        #  Since for all 1 <= l <= m the group generated by
        #  {g_(avec[l]),..,g_m} is in the center of the group generated
        #  by {g_l,..,g_m} it suffices to loop over all
        #  j <= min(i-1, avec[n]-1). Also it is sufficient only to loop over
        #  k while avec[k] is bigger than j.
        for j in [n+1..boundary] do
            k := n;
            while  k <= j-1  and  avec[k] > j  do
                if  IsBound(pr[j][k])  and  pr[j][k][3] = i  then
                    if  k = n  then
                        start := 1;
                    else
                        start := 2;
                    fi;
                    for x in [start..Length(reps[j])] do
                        for y in reps[k] do
                            if Length(reps[j][x]) = 5
                               or  k >= reps[j][x][ 5*(reps[j][x][9]+1)+2 ]
                               then
                                max1 := Dt_GetMax(reps[j][x], j, pr);
                                max2 := Dt_GetMax(y, k, pr);
                                z := [1,i,0, reps[j][x][4]+y[4]+1, 0];
                                Append(z,reps[j][x]);
                                Append(z,y);
                                z[7] := j;
                                z[10] := max1;
                                z[ 5*(z[9]+1)+2 ] := k;
                                z[ 5*(z[9]+1)+5 ] := max2;
                                UnmarkTree(z);
                                #  now get all representatives <z'> with
                                #  left(<z'>) = left(<z>)  ( = <x> ) and
                                #  right(<z'>)=right(<z>) ( = <y> ) and
                                #  num(<z'>) = o where o is an integer
                                #  contained in pr[j][k].
                                FindNewReps(z, reps, pr, avec[n]-1);
                            fi;
                        od;
                    od;
                fi;
                k := k+1;
            od;
        od;
    od;
    #  now get the "real" pseudo-representatives
    for  i in [max+1..Length(pr)]  do
        if  i < avec[n]  then
            boundary := i-1;
        else
            boundary := avec[n]-1;
        fi;
        for j in [n+1..boundary] do
            k := n;
            while  k <= j-1  and  avec[k] > j  do
                if  IsBound(pr[j][k])  and  pr[j][k][3] = i  then
                    if  k = n  then
                        start := 1;
                    else
                        start := 2;
                    fi;
                    for x in [start..Length(reps[j])]  do
                        for y in reps[k]  do
                            if Length(reps[j][x]) = 5
                               or  k >= Dt_GetNumRight(reps[j][x])  then
                                # since reps[j] and reps[k] may contain
                                # pseudo-representatives which are trees
                                # as well as "real" pseudo-representatives
                                # it is necessary to take several cases into
                                # consideration.
                                max1 := Dt_GetMax(reps[j][x], j, pr);
                                max2 := Dt_GetMax(y, k, pr);
                                if  Length(reps[j][x]) <> 4  then
                                    if  reps[j][x][2] <> j  then
                                        # we have to ensure that
                                        # num( <reps>[j][x] ) = j when we
                                        # construct a new pseudo-representative
                                        # out of it.
                                        a := ShallowCopy(reps[j][x]);
                                        a[2] := j;
                                    else
                                        a := reps[j][x];
                                    fi;
                                    a[5] := max1;
                                else
                                    if  reps[j][x][3] <> j  then
                                        # we have to ensure that
                                        # num( <reps>[j][x] ) = j when we
                                        # construct a new pseudo-representative
                                        # out of it.
                                        a := ShallowCopy(reps[j][x]);
                                        a[3] := j;
                                    else
                                        a := reps[j][x];
                                    fi;
                                    a[4] := max1;
                                fi;
                                if  Length(y) <> 4  then
                                    if  y[2] <> k  then
                                        # we have to ensure that num(<y>) = k
                                        # when we construct a new
                                        # pseudo-representative out of it.
                                        b := ShallowCopy(y);
                                        b[2] := k;
                                    else
                                        b := y;
                                    fi;
                                    b[5] := max2;
                                else
                                    if  y[3] <> k  then
                                        # we have to ensure that num(<y>) = k
                                        # when we construct a new
                                        # pseudo-representative out of it.
                                        b := ShallowCopy(y);
                                        b[3] := k;
                                    else
                                        b := y;
                                    fi;
                                    b[4] := max2;
                                fi;
                                # now finally construct the
                                # pseudo-representative and add it to
                                # reps
                                z := [a, b, i, 0];
                                if  i >= avec[n]  then
                                    Add(reps[i], z);
                                else
                                    l := 3;
                                    while  l <= Length(pr[j][k])  and
                                      pr[j][k][l] < avec[n]  do
                                        Add(reps[ pr[j][k][l] ], z);
                                        l := l+2;
                                    od;
                                fi;
                            fi;
                        od;
                    od;
                fi;
                k := k+1;
            od;
        od;
    od;
    # now use the pseudo-representatives to get the desired polynomials
    for  i in [n..Length(pr)]  do
        for  j in [2..Length(reps[i])]  do
            # the first case: reps[i][j] is a "real" pseudo-representative
            if  Length(reps[i][j]) = 4  then
                if  reps[i][j][3] = i  then
                    GetPols(reps[i][j], pr, pols);
                fi;
            # the second case: reps[i][j] is a tree
            elif  reps[i][j][1] <> 0  then
                if  reps[i][j][2] = i  then
                    UnmarkTree(reps[i][j]);
                    hilf := MakeFormulaVector(reps[i][j], pr);
                    Dt_add(hilf, pols, pr);
                fi;
            # the third case: reps[i][j] is a deep thought monomial
            else
                Dt_add(reps[i][j], pols, pr);
            fi;
       od;
       Unbind(reps[i]);
   od;
   # finally convert the polynomials to the final state
   pols := Dt_Convert(pols);
   if  pols <> 0  then
      Dt_ConvertCoeffVecs(pols.evlistvec);
   fi;
   return pols;
end );


#############################################################################
##
#F  Calcreps2( <pr> ) . . . . . . . . . . compute the Deep-Thought-polynomials
##
##  'Calcreps2' returns the polynomials which have to be evaluated when
##  computing word*g_n^(y_n) for all <dtbound> <= n <= m where m is the
##  number of generators in the given presentation <pr>.
##
BindGlobal( "Calcreps2", function(pr, max, dtbound)
    local  i,reps,avec,max2, max1;

    reps := [];
    avec := Dt_Mkavec(pr);
    if  max >= Length(pr)  then
        max1 := Length(pr);
    else
        max1 := max;
    fi;
    for  i in [dtbound..Length(pr)]  do
        if  i >= max1  then
            max1 := Length(pr);
        fi;
        reps[i] := Calcrepsn(i, avec, pr, max1);
    od;
    max2 := 1;
    for  i in [1..Length(reps)]  do
        if  IsRecord(reps[i])  then
            max2 := i;
        fi;
    od;
    for  i in [1..max2]  do
        if  not IsRecord(reps[i])  then
            reps[i] := 1;
        fi;
    od;
    return reps;
end );
