#############################################################################
##
#W  dt.g                        GAP library                 Wolfgang Merkwitz
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file initializes Deep Thought.
##
Revision.dt_g :=
  "@(#)$Id$";


dtbound := 1;


#############################################################################
##
#F  mkavec(<pr>) . . . . . . . . . . . . . . . . . . compute the avec for <pr>
##
##  'mkavec' returns the avec for the pc-presentation <pr>.
##
mkavec := function(pr)
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
end;



#############################################################################
##
#F  evaluation(<vector>) . . . . . . . make an evaluation of a formula vector
##
##  'evaluation' returns an integer value for the formula vector <x> which
##  is used for the presort of the formula vectors done by the function
##  'sortiere'.
##
evaluation := function(vector)
    local  i,k;

    k := 0;
    for  i in [5,7..Length(vector)-1]  do
	k := k + vector[i]*vector[i+1]^2;
    od;
    return k;
end;


#############################################################################
##
#F  equal(<vec1>, <vec2>) . . .  . . . . . . . . . test if <vec1> and <vec2> 
##                                                 represent the same monomial
##
##  'equal' returns "true" if <vec1> and <vec2> represent the same monomial,
##   and "false" otherwise.
equal := function(vec1,vec2)
    local  i,j;
  
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
end;




#############################################################################
##
#F  ordne2(<vector>) . . . . . . . . . . . . . . . . . sort a formula vector
##
##  'ordne2' sorts the pairs of integers in the formula vector <vector>
##  representing the binomial coefficients such that 
##  <vector>[5] < <vector>[7] < .. < vector[m-1],  where m is the length
##  of <vector>.  This is done for a easier comparison of formula vectors.
##
ordne2 := function(vector)
    local  i,list1,list2;
    
    list1 := vector{[5,7..Length(vector)-1]};
    list2 := vector{[6,8..Length(vector)]};
    SortParallel(list1,list2);
    for  i in [1..Length(list1)]  do
        vector[ 2*i+3 ] := list1[i];
        vector[ 2*i+4 ] := list2[i];
    od;
end;


#############################################################################
##
#F  fueghinzu(<evlist>,<evlistvec>,<formvec>,<pr>) . . . add a formula vector 
##                                                       to a list
##
##  'fueghinzu' adds the formula vector <formvec> to the list <evlist>,
##  computes the corresponding coefficient vector and adds the latter to
##  the list <evlistvec>.
##
fueghinzu := function(evlist, evlistvec, formvec, pr)
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
end;


#############################################################################
##
#F  dt_add( <mon>, <pols>, <rel> )
##
##  dt_add adds the deep thought monomial <mon> to the list of polynomials
##  <pols>,  such that afterwards <pols> represents a simplified polynomial.
##

dt_add := function(pol, pols, pr)
    local  i,j,k,rel, pos, flag;
    
    ordne2(pol);
    pos := DT_evaluation(pol);
    if  not IsBound( pols[pos] )  then
        pols[pos] := rec( evlist := [], evlistvec := [] );
        fueghinzu( pols[pos].evlist, pols[pos].evlistvec, pol, pr );
        return;
    fi;
    flag := 0;
    for  k in [1..Length( pols[pos].evlist ) ]  do
        if  equal( pol, pols[pos].evlist[k] )  then
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
        fueghinzu(pols[pos].evlist, pols[pos].evlistvec, pol, pr);
    fi;
end;


#############################################################################
##
#F  konvertiere(<reps>, <pr>) . . . . . . . . convert list of formula vectors
##
##  'konvertiere' converts the list of formula vectors into the record
##  described at the top of the function 'mkevlist'.
##
konvertiere := function(sortedpols, n, pr)
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
end;


#############################################################################
##
#F  konvert2(<evlistvec>) . . . . . . . . . . . . convert coefficient vectors
##
##  'konvert2' takes the list of coefficient vectors <evlistvec> and returns
##  a record with the components 'bas' and 'exp'. The component 'bas' 
##  contains for each element of <evlistvec> the list of positions with
##  non-zero entries.  The component 'exp' contains for each element of 'bas' 
##  a list of the corresponding non-zero coefficients.
##
konvert2 := function(evlistvec, pr)
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
end;



#############################################################################
##
#F  CalcOrder( <word>, <dtrws> )
##
##  CalcOrder computes the order of the word <word> in the group determined
##  by the rewriting system <dtrws>
##

CalcOrder := function(word, dtrws)
    local gcd, m, pcp;
    
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
end;


#############################################################################
##
#F  CompleteOrdersOfRws( <dtrws> )
##
##  CompleteOrdersOfRws computes the orders of the generators of the
##  deep thought rewriting system <dtrws>
##

CompleteOrdersOfRws := function(dtrws)
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
end;


#############################################################################
##
#F  redkomprimiere( <list> )
##
##  redkomprimiere removes all empty entries from <list>
##

redkomprimiere := function( list )
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
end;



#############################################################################
##
#F  ReduceCoefficientsOfRws( <dtrws> )
##
##  ReduceCoefficientsOfRws reduces all coefficients of each deep thought
##  polynomial f_l modulo the order of the l-th generator.
##

ReduceCoefficientsOfRws := function(dtrws)
    local  i,j,k,l, pseudoreps;
    
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
            Compress( pseudoreps[i].evlistvec[j] );
            if  Length( pseudoreps[i].evlistvec[j] ) = 0  then
                Unbind( pseudoreps[i].evlistvec[j] );
                Unbind( pseudoreps[i].evlist[j] );
            fi;
        od;
        redkomprimiere( pseudoreps[i].evlistvec );
        redkomprimiere( pseudoreps[i].evlist );
        i := i+1;
    od;
end;


#############################################################################
##
##  GetMax( <tree>, <number>, <pr> )
##  
##  GetMax returns the maximal value for pos(tree) if num(tree) = <number>.  
##

GetMax := function(tree, number, pr)
    local rel, max, position;
    
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
end;


#############################################################################
##
#F  GetNumRight( <tree> )
##  
##  GetNumRight  returns num( right( tree ) ).
##

GetNumRight := function(tree)
    
    if Length(tree) <> 4  then
        return  tree[ 5*(tree[9]+1)+2 ];
    fi;
    if Length(tree[2]) <> 4  then
        return  tree[2][2];
    fi;
    return  tree[2][3];
end;



###########################################################################
##
#F  calcrepsn(<n>, <avec>, <pr>) . . compute the polynomials for word*g_n^(y_n)
##
##  'calcrepsn' returns the polynomials f_1,..,f_m which have to be evaluated
##  when computing word*g_n^(y_n).  Here m denotes the composition length
##  of the nilpotent group G given by the presentation <pr>.  This is done 
##  by first calculating  representatives for all trees that might occur
##  in the collection of word*g_n^(y^n).  Then for each of these 
##  representatives the corresponding monomials (momomials with respect to
##  the base of binomial coefficients) are calculated.  Finally these
##  monomials are stored in a record with the components 'evlist' and
##  'evlistvec'.  The component 'evlist' contains all monomials which occur
##  in one of the polynomials f_k for 1<=k<=m.  The other component contains
##  for each monomial M a record with the components 'bas' and 'exp'.  The
##  component 'bas' is a list of all generator numbers l for which the
##  polynomial M occurs in f_l,  and 'exp' ist the corresponding list of
##  the coefficients of M in the polynomials f_l.
##
##  If g_n is in the center of the group determined by the presentation <pr>
##  then there don't exist any representatives exept for the atoms and 
##  finally 0 will be returned.
##
calcrepsn:=function(n, avec, pr, max)
    
    local i,j,k,l,       #  loop variables
          x,y,z,a,b,c,   #  trees
          reps,          #  list of representatives, later record to return
          pols,
          boundary,      #  boundary for loop
          hilf,
          pos,
          start,
          max1, max2;    #  maximal values for pos(x) and pos(y)   
    reps:=[];
    pols := [];
    #  now for all n <= i <= m compute the representatives for all trees x 
    #  with num(x) = i and store them into the list <reps[i]>.  We may assume 
    #  that the lists <reps[l]> ( n <= l < i ) are complete.
    for i  in [n..Length(pr)]  do
        #  initialize reps[i] to contain representatives for the atoms
        if  i <> n  then
            reps[i] := [ [1,i,0,1,-2] ];
        else
            reps[i] := [ [1,i,0,1,-1] ];
        fi;
    od;
    # now compute the representatives for the non-atoms
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
        #  {g_(avec[l]),..,g_m} is in the center of the the group generated  
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
                                max1 := GetMax(reps[j][x], j, pr);
                                max2 := GetMax(y, k, pr);
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
                                #  contained in pr[j][k].  A description
                                #  of the internal function FindNewReps
                                #  can be found in the file "DT.c".
                                FindNewReps(z, reps, pr, avec[n]-1);
                            fi;
                        od;
                    od;
                fi;
                k := k+1;
            od;
        od;
    od;
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
                                      or  k >= GetNumRight(reps[j][x])  then
                                max1 := GetMax(reps[j][x], j, pr);
                                max2 := GetMax(y, k, pr);
                                if  Length(reps[j][x]) <> 4  then
                                    if  reps[j][x][2] <> j  then
                                        a := ShallowCopy(reps[j][x]);
                                        a[2] := j;
                                    else
                                        a := reps[j][x];
                                    fi;
                                    a[5] := max1;
                                else
                                    if  reps[j][x][3] <> j  then
                                        a := ShallowCopy(reps[j][x]);
                                        a[3] := j;
                                    else
                                        a := reps[j][x];
                                    fi;
                                    a[4] := max1;
                                fi;
                                if  Length(y) <> 4  then
                                    if  y[2] <> k  then
                                        b := ShallowCopy(y);
                                        b[2] := k;
                                    else
                                        b := y;
                                    fi;
                                    b[5] := max2;
                                else
                                    if  y[3] <> k  then
                                        b := ShallowCopy(y);
                                        b[3] := k;
                                    else
                                        b := y;
                                    fi;
                                    b[4] := max2;
                                fi;
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
    for  i in [n..Length(pr)]  do
#        Print(i,"\n");
       for  j in [2..Length(reps[i])]  do
           if  Length(reps[i][j]) = 4  then
               if  reps[i][j][3] = i  then
                   GetPols(reps[i][j], pr, pols);
 #                  if  i = 7  or  i = 8  then
 #                      if  j > 2  then
 #                          if  Length(reps[i][j][1]) = 4   and
 #                              Length(reps[i][j-1][1]) <> 4  then
 #                              Print("    ",reps[i][j][1][3],"    ",
 #                                    reps[i][j][2][2],"\n");
 #                          fi;
 #                      fi;
 #                  fi;
               fi;
           elif  reps[i][j][1] <> 0  then
               if  reps[i][j][2] = i  then
                   UnmarkTree(reps[i][j]);
                   hilf := MakeFormulaVector(reps[i][j], pr);
                   dt_add(hilf, pols, pr);
               fi;
           else
               dt_add(reps[i][j], pols, pr);
           fi;
       od;
       Unbind(reps[i]);
   od;
#   Error();
   pols := konvertiere(pols,n, pr);
   if  pols <> 0  then
      konvert2(pols.evlistvec, pr);
   fi;
   return(pols);
end;


#############################################################################
##
#F  calcreps2( <pr> ) . . . . . . . . . . compute the Deep-Thought-polynomials
##
##  'calcreps2' returns the polynomials which have to be evaluated when
##  computing word*g_n^(y_n) for all 1 <= n <= m where m is the number of
##  generators in the given presentation <pr>.
##
calcreps2 := function(pr, max)
    local  i,reps,avec,max2, max1;
    
    reps := [];
    avec := mkavec(pr);
    if  max >= Length(pr)  then
        max1 := Length(pr);
    else
        max1 := max;
    fi;
    for  i in [dtbound..Length(pr)]  do
        if  i >= max1  then
            max1 := Length(pr);
        fi;
        reps[i] := calcrepsn(i, avec, pr, max1);
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
end;






#############################################################################
##
#E  dt.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
