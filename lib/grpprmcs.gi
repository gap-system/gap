#############################################################################
##
#W  grpprmcs.gi                 GAP library                       Akos Seress
##
#H  @(#)$Id$
##
##  The first part of this file is a semi-automatic translation from
##  GAP-3.4/lib/permcser.g.
##
Revision.grpprmcs_gi :=
    "@(#)$Id$";

CSPG_attrs := [
[ RNamObj( "generators" ),      GeneratorsOfGroup ],
[ RNamObj( "identity" ),        One               ],
[ RNamObj( "stabChain" ),       StabChainAttr     ],
[ RNamObj( "size" ),            Size              ],
[ RNamObj( "derivedSubgroup" ), DerivedSubgroup   ],
[ RNamObj( "isNilpotent" ),     IsNilpotentGroup  ]
];

CSPG_comps := [  ];
for attr  in [ "orbit", "transversal", "stabilizer" ]  do
    Add( CSPG_comps, [ RNamObj( attr ), attr ] );
od;

InstallMethod( \., true, [ IsPermGroup, IsPosRat and IsInt ], 0,
    function( G, rnam )
    local   attr;
    
    if rnam = CSPG_attrs[ 1 ][ 1 ]  then
        if HasStabChain( G )  then  return StabChainAttr( G ).generators;
                              else  return GeneratorsOfGroup( G );        fi;
    fi;
    for attr  in CSPG_attrs  do
        if rnam = attr[ 1 ]  then
            return attr[ 2 ]( G );
        fi;
    od;
    for attr  in CSPG_comps  do
        if rnam = attr[ 1 ]  then
            return StabChainAttr( G ).( attr[ 2 ] );
        fi;
    od;
    TryNextMethod();
end );

InstallMethod( IsBound\., true, [ IsPermGroup, IsPosRat and IsInt ], 0,
    function( G, rnam )
    local   attr;
    
    for attr  in CSPG_attrs  do
        if rnam = attr[ 1 ]  then
            return Tester( attr[ 2 ] )( G );
        fi;
    od;
    TryNextMethod();
end );

InstallMethod( \.\:\=, true, [ IsPermGroup, IsPosRat and IsInt, IsObject ], 0,
    function( G, rnam, val )
    local   attr;
    
    for attr  in CSPG_attrs  do
        if rnam = attr[ 1 ]  then
            Setter( attr[ 2 ] )( G, val );
            return;
        fi;
    od;
    TryNextMethod();
end );

#############################################################################
##
#F  GInverses( <G> )  . . . . . . . . . . . . . . . . . . . . . . . . . local
##
GInverses := function( G )
    local   S,  inverses,  i;
    
    S := StabChainAttr( G );
    S.generators := S.labels{ S.genlabels };
    inverses := [  ];
    for i  in [ 1 .. Length( S.generators ) ]  do
        inverses[ i ] := S.generators[ i ] ^ -1;
    od;
    return inverses;
end;
    
#############################################################################
##

#F  DisplayCompositionSeries( <S> ) . . . . . . . . . . . .  display function
##
DisplayCompositionSeries := function( S )
    local   f,  i;
    
    # ok, we accept groups too
    if IsGroup( S )  then
        S := CompositionSeries( S );
    fi;

    # display the composition series
    Print( GroupString( S[1], "G" ), "\n" );
    for i  in [2..Length(S)]  do
        f := Image( NaturalHomomorphismByNormalSubgroupInParent( S[ i ] ) );
        Print( " | ",IsomorphismTypeFiniteSimpleGroup(f),"\n");
        if i < Length(S)  then
            Print( GroupString( S[i], "S" ), "\n" );
        else
            Print( GroupString( S[i], "1" ), "\n" );
        fi;
    od;
end;

#############################################################################
##
#M  CompositionSeries( <G> )  . . . . composition series of permutation group
##
##  'CompositionSeriesPermGroup' returns the composition series of <G>  as  a
##  list.
##
##  The subgroups in this list have a slightly modified 'FactorGroup' method,
##  which notices if you compute the factor group of one subgroup by the next
##  and return the factor group as a  primitive  permutation  group  in  this
##  case (which is also computed by the function below).  The  factor  groups
##  remember the natural homomorphism since the images of the  generators  of
##  the subgroup are known and the natural  homomorphism can thus be  written
##  as 'GroupHomomorphismByImages'.
##
##  The program works for  permutation  groups  of  degree  < 2^20 = 1048576.
##  For higher degrees  'IsSimple'  and  'CasesCSPG'  must  be  extended with
##  longer lists of primitive  groups  from  extensions  in  Kantor's  tables
##  (see JSC. 12(1991), pp. 517-526).  It may also be  neccessary  to  modify
##  'FindNormalCSPG'.
##
##  A general reference for the algorithm is:
##  Beals-Seress, 24th Symp. on Theory of Computing 1992.
##
InstallMethod( CompositionSeries, true, [ IsPermGroup ], 0,
    function( Gr )
    local   pcgs,
            normals,    # first component of output; normals[i] contains
                        # generators for i^th subgroup in comp. series
            factors,    # second component of output; factors[i] contains
                        # the action of generators in normals[i]
            factorsize, # third component of output; factorsize[i] is the
                        # size of the i^th factor group
            homlist,    # list of homomorphisms applied to input group
            auxiliary,  # if auxiliary[j] is bounded, it contains
                        # a subg. which must be added to kernel of homlist[j]
            index,      # variable recording how many elements of normals are
                        # computed
            workgroup,  # the subnormal factor group we currently work with
            lastpt,     # degree of workgroup
            tchom,      # transitive constituent homomorphism applied to
                        # intransitive workgroup
            bhom,       # block homomorphism applied to imprimitive workgroup
            bl,         # block system in workgroup
            D,          # derived subgroup of workgroup
            top,        # index of D in workgroup
            g,          # element in a generator list
            lenhomlist, # length of homlist
            i, s,  t,   #
            fac,        # factor group as permutation group
            list;       # output of CompositionSeries
    
    # Solvable groups first.
    pcgs := Pcgs( Gr );
    if pcgs <> fail  then
        list := ShallowCopy( PcSeries( pcgs ) );
        s := list[ 1 ];
        for i  in [ 2 .. Length( list ) ]  do
            t := AsSubgroup( s, list[ i ] );
            fac := CyclicGroup( IsPermGroup,
                           RelativeOrders( pcgs )[ i - 1 ] );
            Setter( NaturalHomomorphismByNormalSubgroupInParent )( t,
                    GroupHomomorphismByImages( s, fac,
                    pcgs{ [ i - 1 .. Length( pcgs ) ] },
                    Concatenation( GeneratorsOfGroup( fac ),
                    List( [ i .. Length( pcgs ) ], k -> One( fac ) ) ) ) );
            list[ i ] := t;
            s := t;
        od;
        return list;
    fi;
        
    # initialize output and work arrays
    normals := [];
    factors := [];
    factorsize := [];
    auxiliary := [];
    homlist := [];
    index := 1;
    workgroup := Gr;

    # workgroup is always a factor group of the input Gr such that a
    # composition series for Gr/workgroup is already computed.
    # Try to get a factor group of workgroup
    while (Size(workgroup) > 1) or (Length(homlist) > 0) do
        if Size(workgroup) > 1  then
            lastpt := LargestMovedPoint(workgroup);

            # if workgroup is not transitive
            if Length(workgroup.orbit) < lastpt   then
                tchom := OperationHomomorphism(workgroup,workgroup.orbit);
                Add(homlist,tchom);
                workgroup := Image(tchom,workgroup);
            else
                bl := MaximalBlocks(workgroup,[1..lastpt]);

                # if workgroup is not primitive
                if Length(bl) > 1  then
                    bhom := OperationHomomorphism(workgroup,bl,OnSets);
                    workgroup := Image(bhom,workgroup);
                    Add(homlist,bhom);
                else
                    D := DerivedSubgroup(workgroup);
                    top := Size(workgroup)/Size(D);

                    # if workgroup is not perfect
                    if top > 1  then

                        # fill up workgroup/D by cyclic factors
                        index := NonPerfectCSPG(homlist,normals,factors,
                                 auxiliary,factorsize,top,index,D,workgroup);
                        workgroup := D;

                    # otherwise chop off simple factor group from top of
                    # workgroup
                    else
                        workgroup := PerfectCSPG(homlist,normals,factors,
                                       auxiliary,factorsize,index,workgroup);
                        index := index+1;
                    fi;  # nonperfect-perfect

                fi;  # primitive-imprimitive

            fi;  # transitive-intransitive

        # if the workgroup was trivial
        else
            lenhomlist := Length(homlist);
            workgroup := KernelOfMultiplicativeGeneralMapping(
                             homlist[lenhomlist] );

            # if auxiliary[lenhmlist] is bounded, it is faster to augment it
            # by generators of the kernel of 'homlist[lenhomlist]'
            if IsBound(auxiliary[lenhomlist])  then
                workgroup := auxiliary[lenhomlist];
                workgroup := ClosureGroup( workgroup, GeneratorsOfGroup(
                                KernelOfMultiplicativeGeneralMapping(
                                    homlist[lenhomlist] ) ) );
            fi;
            Unbind(auxiliary[lenhomlist]);
            Unbind(homlist[lenhomlist]);

        fi; # workgroup is nontrivial-trivial
    od;

    # loop over the subgroups
    s := Subgroup( Gr, normals[1] );
    SetSize( s, Size( Gr ) );
    list := [ s ];
    for i  in [2..Length(normals)]  do
        t := Subgroup( s, normals[i] );
        SetSize( t, Size( s ) / factorsize[i-1] );
        fac := GroupByGenerators( factors[i-1] );
        SetSize( fac, factorsize[i-1] );
        SetIsSimpleGroup( fac, true );
        Setter( NaturalHomomorphismByNormalSubgroupInParent )( t,
                GroupHomomorphismByImages( s, fac,
                        normals[i-1], factors[i-1] ) );
        Add( list, t );
        s := t;
    od;
    t := TrivialSubgroup( s );
    if Size( s ) / factorsize[Length(normals)] <> 1  then
        Error("this shouldn't happen");
    fi;
    fac := GroupByGenerators( factors[Length(normals)] );
    SetSize( fac, factorsize[Length(normals)] );
    SetIsSimpleGroup( fac, true );
    Setter( NaturalHomomorphismByNormalSubgroupInParent )( t,
            GroupHomomorphismByImages( s, fac,
                    normals[Length(normals)], factors[Length(normals)] ) );
    Add( list, t );
        
    # return output
    return list;
end );


#############################################################################
##
#F  NonPerfectCSPG()  . . . . . . . .  non perfect case of composition series
##
##  When <workgroup> is not perfect, it fills up the factor group of the
##  commutator subgroup with cyclic factors.
##  Output is the first index in normals which remains undefined
##
NonPerfectCSPG := function( homlist, normals, factors, auxiliary,
                            factorsize, top, index, D, workgroup )
    local   listlength,   # number of cyclic factors to add to factors
            indexup,      # loop variable for adding the cyclic factors
            oldworkup,    # loop subgroups between
            workup,       # workgroup and derived subgrp
            order,        # index of oldworkup in workup
            orderlist,    # prime factors of order
            g, p,         # generators of workup, oldworkup
            h,            # a power of g
            i, j;         # loop variables

    # number of primes in factor <workgroup> / <derived subgroup>
    listlength := Length(FactorsInt(top));
    indexup := index+listlength;
    oldworkup := D;

    # starting with the derived subgroup, add generators g of workgroup
    # each addition produces a cyclic factor group on top of previous;
    # appropriate powers of g will divide the cyclic factor group into
    # factors of prime length
    for g in workgroup.generators do
        if not (g in oldworkup)  then
            # check for error in random computation of derived subgroup
            if ForAny ( oldworkup.generators, x->not(x^g in oldworkup) ) then
               Error("this shouldn't happen");
            fi;
            workup := ClosureGroup(oldworkup, g);
            order := Size(workup)/Size(oldworkup);
            orderlist := FactorsInt(order);
            for i in [1..Length(orderlist)] do

                # h is the power of g which adds prime length factors
                h := g^Product([i+1..Length(orderlist)],x->orderlist[x]);

                # construct entries in factors, normals
                factors[indexup -1] := [];
                normals[indexup -1] := [];
                for p in oldworkup.generators do

                    # p acts trivially in factor group
                    Add(factors[indexup -1],());

                    # preimage of p is a generator in normals
                    Add(normals[indexup -1],PullbackCSPG(p,homlist));

                od;

                # workgroup is a factor group of original input;
                # kernel of homomorphism must be added to gens in normals
                PullbackKernelCSPG(homlist,normals,factors,
                                   auxiliary,indexup-1);

                # add preimage of h to generator list
                Add(normals[indexup-1],PullbackCSPG(h,homlist));

                # add a prime length cycle to factor group action
                Add(factors[indexup-1],
                           PermList(Concatenation([2..orderlist[i]],[1])));
                # size of factor group is a prime

                factorsize[indexup-1] := orderlist[i];
                indexup := indexup -1;

            od;
            oldworkup := workup;
        fi;
    od;

    return index+listlength;
end;


#############################################################################
##
#F  PerfectCSPG() . . . . . . . . . . . .  prefect case of composition series
##
##  Computes maximal normal subgroup of perfect primitive group K and adds
##  its factor group to factors.
##  Output is the maximal normal subgroup NN. In case NN=1 (i.e. K simple),
##  the kernel of homomorphism which produced K is returned
##
PerfectCSPG := function( homlist, normals, factors, auxiliary,
                         factorsize, index, K )
    local   whichcase,  # var indicating to which case of the O'Nan-Scott
                        # theorem K belongs. When Size(K) and degree do not
                        # determine the case without ambiguity, whichcase
                        # has value as in case of unique nonregular
                        # minimal normal subgroup
            N,          # normal subgroup of K
            prime,      # prime dividing order of degree of K
            stab1,      # stabilizer of first base point in K
            stab2,      # stabilizer of first two base points in K
            kerelement, # element of normal subgroup
            word,       # random element of stab1 as word
            x,y,        # first two base points of K
            i,j,        # loop variables
            H,          # normalizer, and then centralizer of stab2
            L,          # set of moved points of stab2
            op,         # operation of H on N
            tchom,      # restriction of H to L
            g,          # generator of subgroups
            lenhomlist, # length of homlist
            kernel,     # output
            ready;      # boolean variable indicating whether normal subgroup
                        # was found

    while not IsSimpleGroup(K)  do
        whichcase := CasesCSPG(K);

        # becomes true if we find proper normal subgroup by first method
        ready := false;

        # whichcase[1] is true in nonregular minimal normal subgroup case
        if whichcase[1]=1  then
            N := FindNormalCSPG(K, whichcase);

            # check size of result to terminate fast in ambiguous cases
            if 1 < Size(N)  and Size(N) < Size(K)  then
                # K is a factor group with N in the kernel
                K := NinKernelCSPG(K,N,homlist,auxiliary);
                K.derivedSubgroup := K;
                ready := true;
            fi;

       fi;

        # apply regular normal subgroup with nontrivial centralizer method
        if not (ready)  then
            stab2 := Stabilizer(K,[K.orbit[1],K.stabilizer.orbit[1]],
                             OnTuples);
            if IsTrivial(stab2) then 
               # a perfect Frobenius group must have SL(2,5) as 
               # one-point stabilizer; 1/120 chance to hit socle
               prime := FactorsInt(whichcase[2])[1]; 
               stab1 := Stabilizer(K, K.orbit[1]);
               i := 0;
               y := K.stabilizer.orbit[1];
               repeat 
                  i := i+1;
                  x := K.orbit[1];
                  word := CosetRepAsWord(y,stab1.orbit[i],stab1.transversal);
                  Add(word, K.transversal[K.orbit[2]]);
                  for j in [1..prime] do
                      x := ImageInWord(x, word);
                  od;
               until x = K.orbit[1];
               kerelement := Product(word);
               N := NormalClosure(K, Subgroup(K,[kerelement]));
            else
               H := NormalizerStabCSPG(K);
               stab2 := Stabilizer(K,[K.orbit[1],K.stabilizer.orbit[1]],
                                OnTuples);
               if whichcase[1] = 2 then 
                  H := CentralizerNormalCSPG( H, stab2 );
               else
                  L := Orbit(H,H.orbit[1]);
                  tchom := OperationHomomorphism(H,L);
                  op := Image( tchom );
                  H := PreImages(tchom,PCore(op,FactorsInt(whichcase[2])[1])); 
                  H := Centre(H);
                  H.isNilpotent := true;
              fi;
              N := FindRegularNormalCSPG(K,H,whichcase);
           fi;
           K := NinKernelCSPG(K,N,homlist,auxiliary);
           K.derivedSubgroup := K;
        fi;

    od;

    # add next entry to the CompositionSeries output lists
    factors[index] := [];
    normals[index] := [];
    factorsize[index] := Size(K);
    for g in K.generators do
        Add(factors[index],g); # store generators for image
        Add(normals[index],PullbackCSPG(g,homlist));
    od;

    # add generators for kernel to normals
    PullbackKernelCSPG(homlist,normals,factors,auxiliary,index);
    lenhomlist := Length(homlist);

    # determine output of routine
    if lenhomlist > 0  then
        kernel := KernelOfMultiplicativeGeneralMapping(homlist[lenhomlist]);
        if IsBound(auxiliary[lenhomlist])  then
            kernel := auxiliary[lenhomlist]; # faster to add this way
            kernel := ClosureGroup( kernel,
                KernelOfMultiplicativeGeneralMapping(homlist[lenhomlist]) );
        fi;
        Unbind(homlist[lenhomlist]);
        Unbind(auxiliary[lenhomlist]);

    # case when we found last factor of original group
    else
        kernel := Group(());
    fi;

    return kernel;
end;


#############################################################################
##
#F  CasesCSPG() . . . . . . . . . . . . determine case of O'Nan Scott theorem
##
##  Input: primitive, perfect, nonsimple group G.
##  CasesCSPG determines whether there is a normal subgroup with
##  nontrivial centralizer (output[1] := 2 or 3) or decomposes the
##  degree of G into the form output[2]^output[3], output[1] := 1 (case
##  of nonregular minimal normal subgroup).
##  There are some ambiguous cases, (e.g. degree=2^15) when Size(G)
##  and degree do not determine which case G belongs to. In these cases,
##  the output is as in case of nonregular minimal normal subgroup.
##  This computation duplicates some of what is done in IsSimple.
##
CasesCSPG := function(G)
    local   degree,     # degree of G
            g,          # order of G
            primes,     # list of primes in prime decomposition of degree
            output,     # output of routine
            n,m,o,p,i,  # loop variables
            tab1,       # table of orders of primitive groups
            tab2,       # table of orders of perfect transitive groups
            base;       # prime occuring in order of outer automorphism
                        # group of some group in tab1

    g := Size(G);
    degree := LargestMovedPoint(G);
    output := [];

    # case of two regular normal subgroups
    if Size(G)=degree^2  then
        output[1] := 2;
        output[2] := degree;
        return output;
    fi;

    # degree is not prime power
    primes := FactorsInt(degree);
    if primes[1] < primes[Length(primes)] then
        output[1] := 1;
        # only case when index of primitive group in socle is not 2*prime
        if Length(primes)=15  then
            output[2] := 12;
            output[3] := 5;
        else
            output[2] := primes[1]*primes[Length(primes)];
            output[3] := Length(primes)/2;
        fi;
        return output;

    # in case of prime power degree, we have to determine the possible
    # orders of G with nonabelian socle. See IsSimple for identification
    # of groups in tab1,tab2
    else
        tab1 := [ ,,,,[60],,[168,2520],[168,20160],[504,181440],,
                  [660,7920,19958400],,[5616,3113510400]];
        tab2 := [ ,,,,[60],[60,360],[168,2520],[168,8168,20160]];
        for n in [5,7,8,9,11,13] do
            for m in [5..8] do
                for o in [1..Length(tab1[n])] do
                    for p in [1..Length(tab2[m])] do
                        if tab1[n][o]=504  then
                            base := 3;
                        else
                            base := 2;
                        fi;
                        if degree=n^m
                          and g mod (tab1[n][o]^m*tab2[m][p]) = 0
                          and (tab1[n][o]^m*tab2[m][p]*base^m) mod g = 0
                        then
                            output[1] := 1;
                            output[2] := n;
                            output[3] := m;
                            return output;
                        fi;
                    od;
                od;
            od;
        od;

        # if the order of G did not satisfy any of the nonabelian socle
        # possibilities, output the abelian socle message
        output[1] := 3;
        output[2] := degree;
        return output;

    fi;

end;


#############################################################################
##
#F  FindNormalCSPG()  . . . . . . . . . . . . . find a proper normal subgroup
##
##  given perfect, primitive G with unique nonregular minimal normal
##  subgroup, the routine returns a proper normal subgroup of G
##
FindNormalCSPG := function ( G, whichcase )
    local   n,          # degree of G
            i,          # loop variable
            stabgroup,  # stabilizer subgroup of first point
            orbits,     # list of orbits of stabgroup
            where,      # index of shortest orbit in orbits
            len,        # length of shortest orbit
            tchom,      # trans. constituent homom. of stabgroup
                        # to shortest orbit
            bl,         # blocks in action of stabgroup on shortest orbit
            bhom,       # block homomorphism for the action on bl
            K,          # homomorph image of stabgroup at tchom, bhom
            kernel,     # kernel of bhom
            N;          # output; normal subgroup of G

    # whichcase[1]=1 if G has no normal subgroup with nontrivial
    # centralizer or we cannot determine this fact from Size(G)
    n := LargestMovedPoint(G);
    stabgroup := Stabilizer(G,G.orbit[1],OnPoints);
    orbits := Orbits(stabgroup,[1..n]);

    # find shortest orbit of stabgroup
    len := n; where := 1;
    for i in [1..Length(orbits)] do
        if (1<Length(orbits[i])) and (Length(orbits[i])< len)  then
            where := i;
            len := Length(orbits[i]);
        fi;
    od;

    # check arith. conditions in order to terminate fast in ambiguous cases
    if len mod whichcase[3] = 0 and len <= whichcase[3]*(whichcase[2]-1) then

        # take action of stabgroup on shortest orbit
        tchom := OperationHomomorphism(stabgroup,orbits[where]);
        K := Image(tchom,stabgroup);
        bl := MaximalBlocks(K,[1..len]);

        # take action on blocks
        if Length(bl) > 1  then
            bhom := OperationHomomorphism(K,bl,OnSets);
            K := Image(bhom,K);
            kernel := KernelOfMultiplicativeGeneralMapping(
                          CompositionMapping(bhom,tchom));
            N := NormalClosure(G,kernel);

            # another check for ambiguous cases
            if Size(N) < Size(G) then
                return N;
            fi;

        fi;
    fi;

    # in ambiguous case, return trivial subgroup
    N := Subgroup(Parent(G),[()]);
    return N;
end;


#############################################################################
##
#F  FindRegularNormalCSPG()  . . . . . . . . . . find a proper normal subgroup
##
##  given perfect, primitive G with regular minimal normal
##  subgroup(s), the routine returns one
##
FindRegularNormalCSPG := function ( G, H, whichcase )

    local core,         # p-core of H
          cosetrep,     # a cosetrep of H.stabilizer
          candidates,   # list of perms; one element is in regular normal sbgrp
          ready,        # boolean to exit loop
          i,            # loop variable
          N,            # regular normal subgroup, output
          chain;

    # case of abelian normal subgroup
    if whichcase[1] <> 2 then 
       core := PCore( H, FactorsInt(whichcase[2])[1] );
       chain := StabChainOp(core, rec(base := Base(G), reduced := false) );
       cosetrep := chain.transversal[chain.orbit[2]];
       candidates := AsList(Stabilizer(core,Base(G)[1]))*cosetrep;
       ready := false;
       i:= 0;
       while not ready do
          i := i+1;
          N := NormalClosure(G, Subgroup(G, [candidates[i]]) );
          if Size(N) = whichcase[2] then
             ready := true;
          fi;
       od;

     # case of two simple regular normal subgroups
     else
       chain := StabChainOp(H, rec(base := Base(G), reduced := false) );
       cosetrep := chain.transversal[chain.orbit[2]];
       candidates := cosetrep*AsList(Stabilizer(H,Base(G)[1]));
       ready := false;
       i:= 0;
       while not ready do
          i := i+1;
          N := NormalClosure(G, Subgroup(G, [candidates[i]]) );
          if Size(N) = whichcase[2] then
             ready := true;
          fi;
       od;
     fi;

     return N;
end;    

#############################################################################
##
#F  NinKernelCSPG() . . . . . find homomorphism that contains N in the kernel
##
##  Given a normal subgroup N of G, creates a subgroup H such that the
##  homomorphism to the action on cosets of H contains N in the kernel.
##  Actually, only the image of a subgroup is computed, and we store
##  N in auxiliary to remember that N should be added to kernel of
##  homomorphism.
##  Output is the image at homomorphism
##
NinKernelCSPG := function ( G, N, homlist, auxiliary )
    local   i,j,        # loop variables
            base,       # base of G
            stab,       # stabilizer of first two base points
            H,HOld,     # subgroups of G
            G1,H1,      # stabilizer chains of G, HOld
            g,          # loop variable: generator of subgroups of G
            block,      # set of cosets of G1[i]; G1[i] is represented on
                        # images of block
            newrep,     # blocks of imprimitivity in
            oldnewrep,  # the representation of G1[i]
            bhom,       # block hom. and
            tchom;      # transisitive const. hom. applied to G1[i]

    j := Length(homlist)+1;
    auxiliary[j] := N;

    # find smallest subgroup of G in stabilizer chain which, together with N,
    # generates G
    base := Base(G);
    G1 := ListStabChain( StabChainAttr( G ) );
    i := Length(base)+1;
    # first try the stabilizer of first two points
    if Size(N) = LargestMovedPoint(G) then 
       stab := AsSubgroup(Parent(G),Stabilizer(G,[base[1],base[2]],OnTuples));
       H := ClosureGroup
             ( stab, N.generators, rec(size:=Size(N)*Size(stab)) ); 
    else 
       H := ClosureGroup( N, G1[3].generators );
    fi;
    if Size(H) < Size(G) then 
       HOld := H; 
       i := 2;
    else
    # if did not work, start from bottom of stabilizer chain
       H := N;
       repeat
           HOld := H;
           i := i-1;
           H := ClosureGroup( H, G1[i].generators );
       until Size(H) = Size(G);
    fi;

    # represent G1[i] on cosets of H1[i] := G1[i+1]N \cap G1[i]
    H1 := ListStabChain( StabChainOp( HOld, rec( base := base,
                                              reduced := false ) ) );

    # G1[i] will be represented on images of block
    block := Set( H1[i].orbit );
    G := Stabilizer(G,List([1 .. i-1], x->base[x]),OnTuples);

    # now G is the previous G1[i]
    # find primitive action on images of block
    newrep := MaximalBlocks( G, G.orbit, block );
    if Length(newrep) > 1 then
        bhom := OperationHomomorphism(G,newrep,OnSets);
        Add(homlist,bhom);
        G := Image(bhom,G);
    else
        tchom:=OperationHomomorphism(G,G.orbit);
        Add(homlist,tchom);
        G := Image(tchom,G);
    fi;

    return G;
end;


#############################################################################
##
#F  RegularNinKernelCSPG()  . . . .  action of G on H and on maximal subgroup
##
##  H is transitive and contains the stabilizer of the first two
##  base points; we want to find the action of G on cosets of H, and
##  then the action of G on cosets of a maximal subgroup K containing H
##  reference: Beals-Seress Lemma 4.3.
##
RegularNinKernelCSPG := function ( G, H, homlist )
    local   i,j,k,      # loop variables
            base,       # base of G
            G1,H1,      # stabilizer chain of G,H
            x,y,        # first two base points of G
            stabgroup,  # stabilizer of x in G
            Ginverses,  # list of inverses of generators of G
            hgens,      # list of generators of H
            Hinverses,  # list of inverses of generators of H
            stabgens,   # list of generators of stabgroup
            stabinverses, # list of inverses of generators of stabgroup
            block,      # orbit of y in H_x
            orbits,     # images of block in G_x=stabgroup
            a,          # cardinality of orbits
            b,          # cardinality of block
            reprlist,   # for z in stabgroup.orbit, reprlist[z] tells which
                        # element of orbits z belongs to
            reps,       # for representatives z of sets in orbits, reps
                        # contains the cosetrep carrying z to y in stabgroup
                        # (as a word in generators of stabgroup)
            inversereps,# the inverses of words in reps
                        # (as words in stabinverses)
            images,     # list containing the images of generators of G,
                        # acting on cosets of H (there are $a$ cosets,
                        # represented by the elements of orbits)
            v,          # point of permutation domain
            tau,        # the cosetrep of H carrying v to x
                        # (as a word in H.gen's)
            tauinverse, # the inverse of tau (as a word in Hinverses)
            word,       # list of permutations coding a cosetrep of H
            K,          # the factor group of G generated by images
            newrep,     # block system from cosets of K
            c,          # cardinality of newrep
            d,          # size of one block
            newimages,  # list containing the action of generators of G, on
                        # newrep
            hom;        # the homomorphism G->K

    base := Base(G);
    G1 := ListStabChain( StabChainAttr( G ) );
    H1 := ListStabChain( StabChainOp( H, rec( base := base,
                                           reduced := false ) ) );
    block := Set( H1[2].orbit );
    stabgroup := Stabilizer(G,G.orbit[1],OnPoints);
    x := G.orbit[1];
    y := stabgroup.orbit[1];
    orbits := Orbit(stabgroup,block,OnSets);
    a := Length(orbits);
    b := Length(block);
    reprlist := [];
    for i in [1..a] do
        for k in [1..b] do
            reprlist[orbits[i][k]] := i;
        od;
    od;

    Ginverses := GInverses( G );
    Hinverses := GInverses( H );
    hgens := ShallowCopy(H.generators);
    Add(hgens,());
    Add(Hinverses,());

    stabinverses := GInverses( stabgroup );
    stabgens := ShallowCopy(stabgroup.generators);
    Add(stabgens,());
    Add(stabinverses,());

    reps := []; inversereps := [];
    for i in [1..a] do
        reps[i] := CosetRepAsWord(y,orbits[i][1],stabgroup.transversal);
        inversereps[i] := InverseAsWord(reps[i],stabgens,stabinverses);
    od;

    # construct action of G-generators on cosets of H. Each coset of H has a
    # representative in orbits; to find the image of an H coset
    # at multiplication by G.generators[i], take element of H coset such that
    # the product with G.generators[i] fixes x. Then the image of the coset
    # can be read from the position in orbits (cf. Lemma 4.3)
    images := [];
    for i in [1..Length(G.generators)] do
        images[i] := [];
        for j in [1..a] do
            v := ImageInWord(x^Ginverses[i],reps[j]);
            tau := CosetRepAsWord(x,v,H.transversal);
            tauinverse := InverseAsWord(tau,hgens,Hinverses);
            word := Concatenation(tauinverse,inversereps[j],
                                  [G.generators[i]]);
            images[i][j] := reprlist[ImageInWord(y,word)];
        od;
        images[i] := PermList(images[i]);
    od;
    K := GroupByGenerators(images,());

    # check whether new representation is primitive. If not, construct action
    # on maximal block system
    newrep := MaximalBlocks(K,[1..a]);
    if Length(newrep) > 1  then
        c := Length(newrep);
        d := Length(newrep[1]);
        reprlist := [];
        for i in [1..c] do
            for k in [1..d] do
                reprlist[newrep[i][k]] := i;
            od;
        od;
        newimages := [];
        for i in [1..Length(G.generators)] do
            newimages[i] := [];
            for k in [1..c] do
                newimages[i][k] := reprlist[newrep[k][1]^images[i]];
            od;
            newimages[i] := PermList(newimages[i]);
        od;
        K := GroupByGenerators(newimages,());
        hom := GroupHomomorphismByImages(G,K,G.generators,newimages);
    else
        hom := GroupHomomorphismByImages(G,K,G.generators,images);
    fi;
    j := Length(homlist)+1;
    homlist[j] := hom;
    K := Image(homlist[j],G);
    K.derivedSubgroup := K;

    return K;
end;


#############################################################################
##
#F  NormalizerStabCSPG()  . . . . . . . . .  normalizer of 2 point stabilizer
##
##  given primitive, perfect group which has regular normal subgroup
##  with nontrivial centralizer, the output is N_G(G_{xy})
##
NormalizerStabCSPG := function(G)
    local   n,          # degree of G
            stabgroup,  # stabilizer group of G
            orbits,     # orbits of stabgroup
            len,        # minimal length of stabgroup orbits
            where,      # index of minimal length orbit
            i,          # loop variable
            base,       # base of G
            stabgroup2, # stabilizer of first two base points in G
            x,y,        # first two base points
            normalizer, # output group N_G(G_{xy})
            L,          # fixed points of stabgroup2
            yL,         # intersection of L and y-orbit in stabgroup
            orbity,     # orbit of y in normalizer_x;
                        # eventually, orbity must be yL
            orbitx,     # orbit of x in normalizer;
                        # eventually, orbitx must be L
            u,v,        # points in permutation domain
            tau,sigma,p,# cosetreps of G, stabgroup
            Ltau;       # image of L under tau

    n := LargestMovedPoint(G);
    stabgroup := Stabilizer(G,G.orbit[1],OnPoints);

    # If necessary, make base change to achieve that second base point is
    # in smallest orbit of stabilizer.
    orbits := Orbits(stabgroup,[1..n]);
    len := n; where := 1;
    for i in [1..Length(orbits)] do
        if (1<Length(orbits[i])) and (Length(orbits[i])< len)  then
            where := i;
            len := Length(orbits[i]);
        fi;
    od;
    if Length(stabgroup.orbit) > len  then
        SetStabChain( G, StabChainOp(G,[G.orbit[1],orbits[where][1]]) );
        stabgroup := Stabilizer(G,G.orbit[1],OnPoints);
    fi;
    base := Base(G);
    x := G.orbit[1];
    y := stabgroup.orbit[1];
    stabgroup2 := Stabilizer(stabgroup,y,OnPoints);

    # compute normalizer. Method: Beals-Seress, Lemma 7.1
    L := Difference([1..n],MovedPoints(stabgroup2));
    yL := Intersection(L,stabgroup.orbit);

    # initialize normalizer to G_{xy}
    normalizer := rec( generators := ShallowCopy(stabgroup2.generators) );
    orbity := OrbitPerms(normalizer.generators,y);
    while Length(orbity) < Length(yL) do
        v := Difference(yL,orbity)[1];
        p := Product(CosetRepAsWord(y,v,stabgroup.transversal));
        Add(normalizer.generators,p);
        orbity := OrbitPerms(normalizer.generators,y);
    od;
    normalizer.stabChain2 := EmptyStabChain( [  ], (), y );
    AddGeneratorsExtendSchreierTree(normalizer.stabChain2,normalizer.generators);
    normalizer.stabChain2.stabilizer:=stabgroup2.stabChain;

    orbitx := OrbitPerms(normalizer.generators,x);
    while Length(orbitx) < Length(L) do
        v := Difference(L,orbitx)[1];
        tau := Product(CosetRepAsWord(x,v,G.transversal));
        Ltau := OnSets(L,tau);
        u := Intersection(Ltau,stabgroup.orbit)[1];
        sigma := Product(CosetRepAsWord(y,u,stabgroup.transversal));
        Add(normalizer.generators,tau*sigma);
        orbitx := OrbitPerms(normalizer.generators,x);
    od;
    normalizer.stabChain := EmptyStabChain( [  ], (), x );
    AddGeneratorsExtendSchreierTree(normalizer.stabChain,normalizer.generators);
    normalizer.stabChain.stabilizer:=normalizer.stabChain2;

    normalizer := GroupStabChain( Parent( G ), normalizer.stabChain, true );
    return normalizer;
end;


#############################################################################
##
#F  TransStabCSPG() . . . embed a 2 point stabilizer in a transitive subgroup
##
##  given a subgroup H of G which contains G_{xy}, the stabilizer of the
##  first two points in G, and a theoretical guarantee that there is a
##  proper transitive subgroup K containing H, the routine finds such K
##
TransStabCSPG := function(G,H)
    local   n,          # degree of G
            x,y,        # first two points of the base of G
            stabgroup,  # stabilizer of x in G
            hstabgroup, # stabilizer of x in H
            u,v,        # indices of points in G.orbit, stabgroup.orbit
            g,          # list of permutations whose product is
                        # (semi)random element of G
            notinH,     # boolean; true if g is not in H
            word,       # list of permutations whose product is
                        # (semi)random element of <H,g>
            len,        # length of word
            hword,      # list of permutations giving random element of H
            tau,sigma,  # lists of permutations whose
            tau1,sigma1,# products are coset representatives
            i,j,k,      # loop variables
            K;          # K=<H,g>

    #Print(Size(G),",",Size(H));
    n := LargestMovedPoint(G);
    x := G.orbit[1];
    stabgroup := Stabilizer(G,x,OnPoints);
    y := stabgroup.orbit[1];
    hstabgroup := Stabilizer(H,x,OnPoints);
    ExtendStabChain(StabChainAttr(H),Base(G));
    ExtendStabChain(StabChainAttr(hstabgroup),Base(stabgroup));

    # try to embed H into bigger subgroups; stop when result is transitive
    repeat
        # Print("brum");

        # first, take random element of G\H
        repeat
            v := Random([1..Length(G.orbit)]);
            g := CosetRepAsWord(x,G.orbit[v],G.transversal);
            u := Random([1..Length(stabgroup.orbit)]);
            Append(g,CosetRepAsWord(y,stabgroup.orbit[u],
                                      stabgroup.transversal));
            notinH := false;
            v := ImageInWord(x,g);
            if not IsBound(H.transversal[v])  then
                notinH := true;
            else
                u := ImageInWord(y,g);
                u := ImageInWord(u,CosetRepAsWord(x,v,H.transversal));
                if not IsBound(hstabgroup.transversal[u])  then
                    notinH := true;
                fi;
            fi;
        until  notinH;

        for i in [1..n] do

            # construct semirandom element of <H,g>
            word := [];
            for j in [1..5] do
                len := Length(word); 
                for k in [1..Length(g)] do
                    word[len+k] := g[k];
                od;
                len := Length(word); 
                hword := RandomElmAsWord(H);
                for k in [1..Length(hword)] do
                    word[len+k] := hword[k];
                od;
            od;

            # check whether word is in H;
            # if not, then let g=cosetrep of word in G_{xy}
            v := ImageInWord(x,word);
            tau := CosetRepAsWord(x,v,H.transversal);
            if tau = []  then
                tau1 := CosetRepAsWord(x,v,G.transversal);
                u := ImageInWord(y,word);
                u := ImageInWord(u,tau1);
                sigma1 := CosetRepAsWord(y,u,stabgroup.transversal);
                g := Concatenation(tau1,sigma1);
            else
                u := ImageInWord(y,word);
                u := ImageInWord(u,tau);
                sigma := CosetRepAsWord(y,u,hstabgroup.transversal);
                if sigma = []  then
                    tau1 := CosetRepAsWord(x,v,G.transversal);
                    u := ImageInWord(y,word);
                    u := ImageInWord(u,tau1);
                    sigma1 := CosetRepAsWord(y,u,stabgroup.transversal);
                    g := Concatenation(tau1,sigma1);
                fi;
            fi;
        od;

        # check whether H,g generate a proper subgroup of G
        K := ClosureGroup(H,Product(g));
        if 1 < Size(G)/Size(K)  then
            H := K;
            #Print(Size(H));
            hstabgroup := Stabilizer(H,x,OnPoints);
            ExtendStabChain(StabChainAttr(hstabgroup),Base(stabgroup));
            ExtendStabChain(StabChainAttr(H),Base(G));
        fi;

    until Length(H.orbit) = n;

    return H;
end;


#############################################################################
##
#F  PullbackKernelCSPG()  . . . . . . . . . . . . . . . pull back the kernels
##
PullbackKernelCSPG := function( homlist, normals, factors, auxiliary, index )
    local   lenhomlist, # length of homlist
            i, j,       # loop variables
            gens,       # list of generators in kernels
                        # of homomorphisms in homlist
            g;          # a member of gens

    # for each kernel, compute preimages of the kernel generators in the
    # input group add these to generators of the current subnormal subgroup
    # in the composition series
    lenhomlist := Length(homlist);
    for i in [1..lenhomlist] do
       if IsBound(auxiliary[i])  then
           gens := Union( GeneratorsOfGroup(
                       KernelOfMultiplicativeGeneralMapping(homlist[i]) ),
                         auxiliary[i].generators);
       else
           gens := GeneratorsOfGroup( KernelOfMultiplicativeGeneralMapping(
                                          homlist[i] ) );
       fi;
       for g in gens do
           for j in [1..i-1] do
               g := PreImagesRepresentative(homlist[i-j],g);
           od;
           Add(normals[index],g);
           Add(factors[index],());
       od;
    od;
end;


#############################################################################
##
#F  PullbackCSPG()  . . . . . . . . . . . . . . . . . . . . . . . . pull back
##
PullbackCSPG := function(p,homlist)
    local   i,          # loop variable
            lenhomlist; # length of homlist

    # compute a preimage of the permutation p in the input group
    lenhomlist := Length(homlist);
    for i in [1..lenhomlist] do
        p := PreImagesRepresentative(homlist[lenhomlist+1-i],p);
    od;
    return p;
end;


#############################################################################
##
#F  CosetRepAsWord()  . . . . . . . . .  write a coset representative as word
##
##  returns the cosetrep carrying y to the base point x as a word in the
##  generators. If y is not in the orbit of x, returns []
##
CosetRepAsWord := function(x,y,transversal)
    local   word,       # list of permutations
            point;      # element of permutation domain

    word := [];
    if IsBound(transversal[y])  then
        point := y;
        repeat
            word[Length(word)+1] := transversal[point];
            point := point^transversal[point];
        until point = x;
    fi;
    return word;
end;


#############################################################################
##
#F  ImageInWord() . . .  image of a point under a permutation written as word
##
##  computes the image of x when the list of permutations word is applied
##
ImageInWord := function(x,word)
    local   i,          # loop variable
            value;      # element of permutation domain

    value := x;
    for i in [1..Length(word)] do
        value := value^word[i];
    od;
    return value;
end;


#############################################################################
##
#F  SiftAsWord()  . . . . . . . . . . . . shift a permutation written as word
##
##  given a list of permutations perm, the routine computes the residue
##  at the sifting of perm through the SGS of G
##  the output is a list of length 2: the first component is the siftee,
##  as a word, the second component is 0 if perm in G, and i if the siftee
##  on the i^th level could not be computed.
##
SiftAsWord := function(G,perm)
    local   i,          # loop variable
            y,          # element of permutation domain
            word,       # the list collecting the siftee of perm
            len,        # length of word
            coset,      # word representing a coset in a stabilizer
            index,      # the level where the siftee cannot be computed
            stb;        #the stabilizer group we currently work with

    # perm must be a list of permutations itself!
    stb := G;
    word := perm;
    index := 0;
    while IsBound(stb.stabilizer) do 
       index:=index+1;
       y:=ImageInWord(stb.orbit[1],word);
       if IsBound(stb.transversal[y]) then 
          coset :=  CosetRepAsWord(stb.orbit[1],y,stb.transversal);
          len := Length(word); 
          for i in [1..Length(coset)] do
              word[len+i] := coset[i];
          od; 
          stb:=stb.stabilizer;
       else 
          return([word,index]);
       fi;
    od;

    index := 0;
    return [word,index];
end;


#############################################################################
##
#F  InverseAsWord() . . . . . . . . . .  invert a permutation written as word
##
##  given a list of permutations "list", the inverses of these permutations
##  in inverselist, and a list of permutations "word" with elements from
##  list, returns the inverse of word as a list of inverses from inverselist
##
InverseAsWord := function(word,list,inverselist)
    local   i,          # loop variable
            inverse;    # the inverse of word

    inverse := [];
    for i in [1..Length(word)] do
        inverse[i] := inverselist[Position(list,word[Length(word)+1-i])];
    od;
    return inverse;
end;


#############################################################################
##
#F  RandomElmAsWord() . . . . . . . . . . . .  random element written as word
##
##  given an SGS for G, returns a uniformly distributed random element of G
##  as a word in the strong generators
##
RandomElmAsWord := function(G)
    local  i,       # loop variable 
           word,    # the random element
           len,     # length of word
           stb,     # the stabilizer group we currently work with
           v,       # index of random element of stb.orbit
           coset;   # word representing a coset 
    word:=[];
    stb:=G;
    while IsBound(stb.stabilizer) do 
       v := Random([1..Length(stb.orbit)]);
       coset := CosetRepAsWord(stb.orbit[1],stb.orbit[v],stb.transversal);
       len := Length(word);
       for i in [1..Length(coset)] do
           word[len+i] := coset[i];
       od;
       stb:=stb.stabilizer;
    od;
    return  word;

end;

#############################################################################
##

#M  PCore() . . . . . . . . . . . . . . . . . . p core of a permutation group
##
##  O_p(G), the p-core of G, is the maximal normal p-subgroup
##  Output of routine: the subgroup O_p(workgroup)
##  reference: Luks-Seress
##
InstallMethod( PCoreOp, true, [ IsPermGroup, IsPosRat and IsInt ], 0,
    function(workgroup,p)
    local   n,          # degree of workgroup
            G,          # a factor group of workgroup
            list,       # the record workgroup.compositionSeries
            normals,    # gens for the subgroups in the composition series
            factorsize, # the sizes of factor groups in composition series
            index,      # loop variable running through the indices of
                        # subgroups in the composition series
            pri,primes, # list of primes in the factorization of numbers
            ppart,      # p-part of Size(G)
            homlist,    # list of homomorphisms applied to workgroup
            lenhomlist, # length of homlist
            K, N,       # subnormal subgroups of G from composition series
            g,          # generator of K
            C,          # centralizer of N in K
            D,          # the p-part of C
            order,      # order of a generator of C
            H,          # first solvable, then also
                        # abelian normal p-subgroup of G
            series,     # the derived series of H; H becomes abelian when it
                        # is redefined as last nontrivial term of series
            actionlist, # record of G action on transitive
                        # constituent pieces of H
            i, j,       # loop variables
            image,      # list of images of generators of G
                        # acting on pieces of H
            GG,         # the image of G at this action
            hom,        # the homomorphism from G to GG
            pgenlist;   # list of generators for the p-core

    # handle trivial cases
    pri := FactorsInt(p);
    if Length(pri) > 1  then
        return TrivialSubgroup(workgroup);
    fi;
    if IsTrivial(workgroup)  then
        return TrivialSubgroup(workgroup);
    fi;
    if Size(workgroup) mod p <> 0 then
       # p does not divide Size(workgroup) 
       return TrivialSubgroup(workgroup);
    fi;

    #handle nilpotent case directly 
    if IsNilpotentGroup( workgroup ) then 
           # compute the p-part of generators of workgroup
           primes := Collected( Factors( Size(workgroup) ) );
           ppart := p^primes[PositionProperty( primes, x->x[1]=p )][2];
           pgenlist := [];
           for g in workgroup.generators do
               Add( pgenlist, g^( Size(workgroup)/( ppart ) ) );
           od;
           return Subgroup( workgroup, pgenlist );
    fi;

    n := LargestMovedPoint(workgroup);
    G := workgroup;
    list := CompositionSeries(G);
    # normals := Copy(list[1]);
    # factorsize := list[3];
    normals := List([1..Length(list)-1],i->ShallowCopy(list[i].generators));
    factorsize := List([1..Length(list)-1],i->Size(list[i])/Size(list[i+1]));
    Add(normals, [()]);
    homlist := [];
    index := Length(factorsize);

    # try to find smallest subgroup in composition series with nontrivial
    # p-core. The normal closure of this p-core is a solvable normal
    # p-subgroup of G; taking commutator subgroups, find abelian normal
    # p-subgroup of G.
    # represent G acting on transitive constituent pieces of abelian normal
    # p-subgroup; kernel is abelian p-group. Take image at this action, and
    # repeat
    while index > 0 do
        if factorsize[index] <> p  then
            index := index-1;
        else
            N := Subgroup(Parent(G),normals[index+1]);

            # define K := SubGroup(Parent(G),normals[index]);
            # N has trivial p-core; check whether K has nontrivial one
            # K=N is possible when we work in homomorphic images of original
            if ForAll(normals[index], x -> x in N)  then
                index := index-1;
            else
                K := ClosureGroup( N,normals[index],
                                          rec( size:=p*Size(N) ) );
                C := CentralizerNormalCSPG(K,N);
                # O_p(K) is cyclic or trivial; it must show up in C
                # C is always abelian; check whether it has p-part
                D := [];
                for i in [1..Length(C.generators)] do
                    order := OrderPerm(C.generators[i]);
                    if order mod p = 0  then
                        D[i] := C.generators[i]^(order/p);
                    else
                        D[i] := ();
                    fi;
                od;

                # redefine C as the p-core of C
                C := Subgroup(Parent(K),D);
                if IsTrivial(C)  then
                    index := index-1;
                else
                    H := NormalClosure(G,C);
                    series := DerivedSeriesOfGroup(H);
                    H := series[Length(series)-1];

                    # at that moment, H is abelian normal in G
                    # define new action of G with H in the kernel
                    actionlist := ActionAbelianCSPG(H,n);

                    image := [];
                    for i in [1..Length(G.generators)] do
                        image[i] :=
                              ImageOnAbelianCSPG(G.generators[i],actionlist);
                    od;

                    # take homomorphic image of G
                    GG := GroupByGenerators(image,());
                    hom:=GroupHomomorphismByImages(G,GG,G.generators,image);
                    Add(homlist,hom);
                    #force makemapping
                    KernelOfMultiplicativeGeneralMapping( hom );
                    # find new action of subgroups in composition series
                    for i in [1..index] do
                        for j in [1..Length(normals[i])] do
                            normals[i][j] :=
#                                ImageOnAbelianCSPG(normals[i][j],actionlist);
                            Image(hom,normals[i][j]);
                        od;
                    od;

                    G := GG;
                    index := index-1;

                fi;         # IsTrivial(C)

            fi;             # K = N

        fi;                 # factorsize[index] <> p

    od;

    # create output;
    # the p-core is the kernel of homomorphisms applied to workgroup
    lenhomlist := Length(homlist);
    if lenhomlist = 0  then
        pgenlist := [()];
    else
        pgenlist := [];
        for i in [1..lenhomlist] do
            for g in GeneratorsOfGroup( KernelOfMultiplicativeGeneralMapping(
                                            homlist[i] ) ) do
                for j in [1..i-1] do
                    g := PreImagesRepresentative(homlist[i-j],g);
                od;
                Add(pgenlist,g);
            od;
        od;
    fi;
    return Subgroup(workgroup,pgenlist);
end );


#############################################################################
##
#M  RadicalGroup()  . . . . . . . . . . . . .  radical of a permutation group
##
##  the radical is the maximal solvable normal subgroup
##  output of routine: the subgroup radical of workgroup
##  reference: Luks-Seress
##
InstallMethod( RadicalGroup, true, [ IsPermGroup ], 0,
    function(workgroup)
    local   n,          # degree of workgroup
            G,          # a factor group of workgroup
            list,       # the record workgroup.compositionSeries
            normals,    # gens for the subgroups in the composition series
            factorsize, # the sizes of factor groups in composition series
            index,      # loop variable running through the indices of
                        # subgroups in the composition series
            primes,     # list of primes in the factorization of numbers
            homlist,    # list of homomorphisms applied to workgroup
            lenhomlist, # length of homlist
            K, N,       # subnormal subgroups of G from composition series
            g,          # generator of K
            C,          # centralizer of N in K
            H,          # first solvable,
                        # then also abelian normal subgroup of G
            series,     # the derived series of H; H becomes abelian when it
                        # is redefined as last nontrivial term of series
            actionlist, # record of G action on transitive
                        # constituent pieces of H
            i, j,       # loop variables
            image,      # list of images of generators of G
                        # acting on pieces of H
            GG,         # the image of G at this action
            hom,        # the homomorphism from G to GG
            solvable;   # list of generators for the radical

    if IsTrivial(workgroup)  then
        return TrivialSubgroup(workgroup);
    fi;

    if IsSolvableGroup(workgroup) then 
        return workgroup;
    fi;

    n := LargestMovedPoint(workgroup);
    G := workgroup;
    list := CompositionSeries(G);
    # normals := Copy(list[1]);
    # factorsize := list[3];
    normals := List([1..Length(list)-1],i->ShallowCopy(list[i].generators));
    factorsize := List([1..Length(list)-1],i->Size(list[i])/Size(list[i+1]));
    Add(normals, [()]);
    homlist := [];
    index := Length(factorsize);

    # try to find smallest subgroup in composition series with nontrivial
    # radical. The normal closure of this radical is a solvable normal
    # subgroup of G; taking commutator subgroups, find abelian normal
    # subgroup of G.
    # represent G acting on transitive constituent pieces of abelian normal
    # subgroup; kernel is abelian normal.
    # Take image at this action, and repeat
    while index > 0 do
        primes := FactorsInt(factorsize[index]);

        # if the factor group is not cyclic, no chance for nontrivial radical
        if Length(primes) > 1  then
            index := index-1;
        else
            N := Subgroup(Parent(G),normals[index+1]);

            # define K := SubGroup(Parent(G),normals[index]);
            # N has trivial radical; check whether K has nontrivial one
            # K=N is possible when we work in homomorphic images of original
            if ForAll(normals[index], x -> x in N)  then
                index := index-1;
            else
                K := ClosureGroup( N,normals[index],
                                     rec( size:=factorsize[index]*Size(N) ) );
                C := CentralizerNormalCSPG(K,N);

                # radical of K is cyclic or trivial; it has to show up in C
                if IsTrivial(C)  then
                    index := index-1;
                else
                    H := NormalClosure(G,C);
                    series := DerivedSeriesOfGroup(H);
                    H := series[Length(series)-1];

                    # at that moment, H is abelian normal in G
                    # define new action of G with H in the kernel
                    actionlist := ActionAbelianCSPG(H,n);

                    image := [];
                    for i in [1..Length(G.generators)] do
                        image[i] :=
                              ImageOnAbelianCSPG(G.generators[i],actionlist);
                    od;

                    # take homomorphic image of G
                    GG := GroupByGenerators(image,());
                    hom := GroupHomomorphismByImages(G,GG,
                                                     G.generators,image);
                    Add(homlist,hom);
                    #force makemapping
                    KernelOfMultiplicativeGeneralMapping( hom );
                    # find new action of subgroups in composition series
                    for i in [1..index] do
                        for j in [1..Length(normals[i])] do
                            normals[i][j] :=
#                                ImageOnAbelianCSPG(normals[i][j],actionlist);
                            Image(hom,normals[i][j]);
                        od;
                    od;
                    G := GG;
                    index := index-1;

                fi;         # IsTrivial(C)

            fi;             # K = N

        fi;                 # Length(primes)>1

    od;

    # create output;
    # the radical is the kernel of homomorphisms applied to workgroup
    lenhomlist := Length(homlist);
    if lenhomlist = 0  then
        solvable := [()];
    else
        solvable := [];
        for i in [1..lenhomlist] do
            for g in GeneratorsOfGroup( KernelOfMultiplicativeGeneralMapping(
                                            homlist[i] ) ) do
                for j in [1..i-1] do
                    g := PreImagesRepresentative(homlist[i-j],g);
                od;
                Add(solvable,g);
            od;
        od;
    fi;

    return Subgroup(workgroup,solvable);
end );


#############################################################################
##
#M  Centre()  . . . . . . . . . . . . . . . . . center of a permutation group
##
##  constructs the center of G.
##  Reference: Beals-Seress, 24th Symp. on Theory of Computing 1992, sect. 9
##
InstallMethod( Centre, true, [ IsPermGroup ], 0,
    function(G)
    local   n,          # degree of G
            orbits,     # list of orbits of G
            list,       # ordering of permutation domain
                        # such that G orbits are consecutive
            base,       # lexicographically smallest (in list) base of G
            i,j,        # loop variables
            reps,       # array recording which orbit of G the points in
                        # perm. domain belong to
            domain,     # union of G orbits which contain base points
            significant,# indices of orbits in "orbits" that belong to domain
            max,        # loop variable, used at definition of significant
            len,        # length of domain
            tchom,      # trans. const. homom, restricting G to domain
            GG,         # the image of tchom
            orbit,      # an orbit of GG
            tchom2,     # trans. const. homom, restricting GG to orbit
            GGG,        # the image of GG at tchom2
            hgens,      # list of generators for the direct product of
                        # centralizers of GG in Sym(orbit), for orbits of GG
            order,      # order of Group(hgens,())
            centr,      # the centralizer of GG in Sym(orbit)
            inverse2,   # inverse of the conjugating permutation of tchom2
            g,          # generator of centr
            image,      # generator of centr, as it acts on domain
            cent;       # center of GG

    if IsTrivial(G)  then
       return TrivialSubgroup(G);
    fi;

    base := Base(G);
    n := Maximum( Maximum( base ), LargestMovedPoint(G) );
    orbits := Orbits(G,[1..n]);
    # orbits := List( orbits, Set );

    # handle case of transitive G directly
    if Length(orbits) = 1  then
        centr := CentralizerTransSymmCSPG(G);
        if Length(centr.generators) = 0 then 
           return TrivialSubgroup(Parent(G));
        else
           order := Size(centr);
           cent := IntersectionNormalClosurePermGroup(G,centr,order*Size(G));
           return cent;
        fi;
    fi;

    # for intransitive G, find which orbit contains which 
    # points of permutation domain
    reps := [];
    for i in [1..Length(orbits)] do
        for j in [1..Length(orbits[i])] do
            reps[orbits[i][j]] := i;
        od;
    od;

    # take union of significant orbits which contain base points
    max := reps[base[1]];
    significant := [max];
    domain := ShallowCopy(orbits[max]);
    for i in [2..Length(base)] do
        if not (reps[base[i]] in significant)  then
            max := reps[base[i]];
            Append(domain,orbits[max]);
            Add(significant,max);
        fi;
    od;
    len := Length(domain);

    # restrict G to significant orbits
    if n = len then
       GG := G;
    else
       tchom := OperationHomomorphism(G,domain);
       GG := Image(tchom,G);
    fi;

    # handle case of transitive GG directly
    if Length(significant) = 1  then
        centr := CentralizerTransSymmCSPG(GG);
        if Length(centr.generators) = 0 then 
           return TrivialSubgroup(Parent(G));
        else
           order := centr.size;
           cent := IntersectionNormalClosurePermGroup(GG,centr,order*Size(GG));
           return PreImages(tchom,cent);
        fi;
    fi;

    # case of intransitive GG
    # for each orbit of GG, construct generators of centralizer of GG in
    # Sym(orbit).  hgens is a list of generators for the direct product of
    # these centralizers.
    # the group generated by hgens contains the center of GG
    hgens := [];
    order := 1;
    for i in significant do
        if n = len then
           orbit := orbits[i]; 
        else
           orbit := OnTuples(orbits[i],tchom!.conperm);
        fi;
        tchom2 := OperationHomomorphism(GG,orbit);
        GGG := Image(tchom2,GG);
        SetStabChain( GG, StabChainOp( GG, [ orbit[1] ] ) );
        GGG!.stabFxdPnts:=[ orbit[1]^tchom2!.conperm, 
            OnTuples( Difference(orbit, MovedPointsPerms
                ( GG.stabilizer.generators ) ), tchom2!.conperm ) ];
        centr := CentralizerTransSymmCSPG(GGG);
        if Length(centr.generators) > 0 then
           order := order * centr.size;
           inverse2 := tchom2!.conperm^(-1);
           for g in centr.generators do
               Add(hgens,g^inverse2);
           od;
        fi;
    od;

    if order = 1 then 
        return TrivialSubgroup(Parent(G));
    else
        cent := IntersectionNormalClosurePermGroup
                 ( GG, GroupByGenerators(hgens,()), order*Size(GG) );
    fi;
    if n = len then 
        return cent;
    else 
        return PreImages(tchom,cent);
    fi;
end );




#############################################################################
##

#F  CentralizerNormalCSPG() . . . . . . . .  centralizer of a normal subgroup
##
##  computes the centralizer of a NORMAL subgroup N in G.
##  Reference: Luks-Seress
##
CentralizerNormalCSPG := function(G,N)
    local   n,          # degree of G
            orbits,     # list of orbits of G
            list,       # ordering of permutation domain
                        # such that G orbits are consecutive
            base,       # lexicographically smallest (in list) base of G
            i,j,        # loop variables
            reps,       # array recording which orbit of G the points in
                        # perm. domain belong to
            domain,     # union of G orbits which contain base points
            significant,# indices of orbits in "orbits" that belong to domain
            max,        # loop variable, used at definition of significant
            len,        # length of domain
            tchom,      # trans. const. homom, restricting G to domain
            GG,         # the image of G at tchom
            NN,         # the image of N at tchom
            orbit,      # an orbit of GG
            tchom2,     # trans. const. homom, restricting GG to orbit
            GGG,        # the image of GG at tchom2
            NNN,        # the image of NN at tchom2
            hgens,      # list of generators for the direct product of
                        # centralizers of NN in GG restricted to Sym(orbit),
                        # for orbits of GG
            order,      # order of Group(hgens,())
            centrnorm,  # centralizer of NN in GG restricted to Sym(orbit)
            inverse2,   # inverse of the conjugating permutation of tchom2
            g,          # loop variable for generators
            image,      # generator of centrnorm, as it acts on domain
            central;    # centralizer of NN in GG

    if IsTrivial(N)  then
        return G;
    fi;

    n := LargestMovedPoint(G);
    orbits := Orbits(G,[1..n]);
    #orbits := List( orbits, Set );

    # handle case of transitive G directly
    if Length(orbits) = 1  then
        centrnorm := CentralizerNormalTransCSPG(G,N);
        return centrnorm;
    fi;

    # for intransitive G, find which orbit contains which 
    #points of permutation domain
    reps := [];
    for i in [1..Length(orbits)] do
        for j in [1..Length(orbits[i])] do
            reps[orbits[i][j]] := i;
        od;
    od;
    #list := Concatenation(orbits);
    #MakeStabChain(G,list);

    # take union of significant orbits which contain base points
    base := Base(G);
    max := reps[base[1]];
    significant := [max];
    domain := ShallowCopy(orbits[max]);
    for i in [2..Length(base)] do
        if not (reps[base[i]] in significant)  then
            max := reps[base[i]];
            Append(domain,orbits[max]);
            Add(significant,max);
        fi;
    od;
    len := Length(domain);

    # restrict G,N to significant orbits
    if n = len then
       GG := G; 
       NN := N;
    else 
       tchom := OperationHomomorphism(G,domain);
       GG := Image(tchom,G);
       NN := Image(tchom,N);
    fi;

    # handle case of transitive GG directly
    if Length(significant) = 1  then
        centrnorm := CentralizerNormalTransCSPG(GG,NN);
        return PreImages(tchom,centrnorm);
    fi;

    # case of intransitive GG
    # for each GG orbit, compute the centralizer of NN in GG, restricted to
    # the orbit. hgens contains generators for the direct product of these
    # centralizers; the group generated by hgens contains the centralizer of
    # NN in GG
    hgens := [];
    order := 1;
    for i in significant do
        if n = len then 
            orbit := orbits[i];
        else 
            orbit := OnTuples(orbits[i],tchom!.conperm);
        fi;
        # restrict GG, NN to orbit
        tchom2 := OperationHomomorphism(GG,orbit);
        GGG := Image(tchom2,GG);
        NNN := Image(tchom2,NN);

        # compute centralizer of NNN in GGG
        centrnorm := CentralizerNormalTransCSPG(GGG,NNN);
        inverse2 := tchom2!.conperm^(-1);
        order := order * Size(centrnorm);

        # determine how the centralizer acts on domain
        for g in centrnorm.generators do
            Add(hgens,g^inverse2);
        od;
    od;

    if order = 1 then 
       return TrivialSubgroup( Parent(G) );
    else
       central := IntersectionNormalClosurePermGroup
                    ( GG, GroupByGenerators(hgens,()), order*Size(GG) );
    fi;

    if n = len then
       return central;
    else 
       return PreImages(tchom,central);
    fi;
end;


#############################################################################
##
#F  CentralizerNormalTransCSPG()  . . . centralizer of normal in transitive G
##
##  computes C_G(N) with G transitive, N normal in G
##  reference: Luks-Seress
##
CentralizerNormalTransCSPG := function(G,N)
    local   n,          # degree of G
            x,          # the first base point of G
            stabgroup,  # stabilizer of x in N
            U,          # an orbit of centralizer of N in S_n
            orbits,     # list of orbits of centralizer of N is S_n
            bhom,       # block homomorphism from G to action on orbits
            GG,         # the kernel of bhom
            Ginverses,  # list of inverses of generators of G
            Ninverses,  # list of inverses of generators of N
            norbits,    # list of orbits of N
            orbitlength,# the length of the N orbits
                        # (all are of the same size)
            reprlist,   # list recording which orbit of N contains a point of
                        # permutation domain
            positionlist,
                        # list recording the position of a point within its
                        # N orbit
            positiongenlist,
                        # list of length orbitlength; i^th entry records
                        # the position of the generator in N.generators
                        # which occurs in N.transversal at N.orbit[i]
            len,        # number of N orbits intersecting U
            diff,       # loop variable denoting a subset of U
                        # used at creation of N orbits which intersect U
            new,        # an orbit of N intersecting U
            i,j,k,m,    # loop variables
            y,u,s,      # points of permutation domain
            set,        # loop variable denoting subset of [1..n], used at
                        # creation of covering of [1..n] by orbits of N
            newlen,     # loop variable counting the total length of N orbits
                        # at the covering of [1..n]
            word,       # a coset representative of G or N, as a word
            tchom,      # transitive constituent homomorphism restricting
                        # N to N.orbit
            inverse,    # the inverse of tchom.conperm
            centr,      # the centralizer of N in Sym(N.orbit)
            hom,        # homomorphism of GG whose kernel is C_G(N)
            images,     # list of images of generators of GG at hom
            top,bottom,g,
                        # permutations used at the creation of images
            K;          # image of GG at hom

    if IsTrivial(N)  then
        return G;
    fi;

    x := G.orbit[1];
    SetStabChain( N, StabChainOp(N,[x]) );

    # handle transitive N directly
    if Length(N.orbit) = Length(G.orbit) then
        centr := CentralizerTransSymmCSPG(N);
        if Size(centr) > 1 then
        return IntersectionNormalClosurePermGroup(G,centr,centr.size*Size(G));
        else
           return Subgroup(Parent(G), []);
        fi;
    fi;

    n := LargestMovedPoint(G);
    stabgroup := Stabilizer(N,x,OnPoints);
    U := Difference([1..n],MovedPoints(stabgroup));
    if Length(U) = 1 then 
        return Subgroup(Parent(G),[()]);
    fi;
    orbits:=Blocks(G,[1..n],U);

    # orbits contains the orbits of the centralizer of N in S_n;
    # so C_G(N) must fix setwise the elements of orbits
    bhom := OperationHomomorphism(G,orbits,OnSets);
    GG := KernelOfMultiplicativeGeneralMapping( bhom );
    if IsTrivial(GG)  then
        return Subgroup(Parent(G),[()]);
    fi;

    Ginverses := GInverses( G );
    Ninverses := GInverses( N );

    # we partition [1..n] into the orbits of N, and compute the
    # identification between equivalent orbits (equivalent in the sense
    # that the centralizer of N in S_n exchanges them). After that, we
    # conjugate the union of equivalent orbits to cover [1..n]
    norbits := [N.orbit];
    orbitlength := Length(N.orbit);
    positionlist := [];
    reprlist := [];
    positiongenlist := [];
    for i in [1..orbitlength] do
        positionlist[N.orbit[i]] := i;
        reprlist[N.orbit[i]] := 1;
        positiongenlist[i]:=Position(N.generators,N.transversal[N.orbit[i]]);
    od;
    diff := Difference(U,norbits[1]);
    len := 1;

    # create the orbits of N equivalent to the first one
    while diff <> [] do
        len := len+1;
        y := diff[1];
        new := [y];
        positionlist[y] := 1;
        reprlist[y] := len;
        for i in [2..orbitlength] do
            u := N.orbit[i]^N.generators[positiongenlist[i]];
            new[i] := new[positionlist[u]]^Ninverses[positiongenlist[i]];
            positionlist[new[i]] := i;
            reprlist[new[i]] := len;
        od;
        Add(norbits,new);
        diff := Difference(diff,new);
    od;

    # if the domain is not covered, create further orbits of N
    if len*orbitlength < n  then
        set := Difference([1..n],Union(norbits));
        for k in [2..n/(len*orbitlength)] do
            newlen := (k-1)*len;
            y := set[1];
            word := CosetRepAsWord(x,y,G.transversal);
            word := InverseAsWord(word,G.generators,Ginverses);
            for i in [1..len] do
                norbits[newlen+i] := [];
                for j in [1..orbitlength] do
                    norbits[newlen+i][j] := ImageInWord(norbits[i][j],word);
                    positionlist[norbits[newlen+i][j]] := j;
                    reprlist[norbits[newlen+i][j]] := newlen+i;
                od;
                set := Difference(set,norbits[newlen+i]);
            od;
        od;
    fi;

    # compute centralizer of N in first orbit; centralizer in other orbits
    # is obtained from identification between orbits
    tchom := OperationHomomorphism(N,N.orbit);
    inverse := tchom!.conperm^(-1);
    centr := CentralizerTransSymmCSPG(Image(tchom,N));

    # compute transversal of centr
    centr.stabChain := EmptyStabChain( [  ], (), x^tchom!.conperm );
    AddGeneratorsExtendSchreierTree(centr.stabChain,centr.generators);

    # compute images at homomorphism of GG, g -> g c_g^{-1} (cf. Luks-Seress)
    # the kernel of this homomorphism is C_G(N)
    images := [];
    for i in [1..Length(GG.generators)] do
        images[i] := [];

        # top is the permutation in the wreath product which pulls back g to
        # orbits of N
        top := [];
        for j in [1..Length(norbits)] do
            k := reprlist[norbits[j][1]^GG.generators[i]];
            for m in [1..orbitlength] do
                top[norbits[k][m]] := norbits[j][m];
            od;
        od;
        top := PermList(top);
        g := GG.generators[i]*top;

        # pull back each leading point in norbits by centralizer of N
        bottom := [];
        for j in [1..Length(norbits)] do
            k := positionlist[norbits[j][1]^g];
            word := CosetRepAsWord(x^tchom!.conperm,N.orbit[k]^tchom!.conperm,
                                 centr.transversal);
            for m in [1..orbitlength] do
                s := (ImageInWord(N.orbit[m]^tchom!.conperm,word))^inverse;
                bottom[norbits[j][m]] := norbits[j][positionlist[s]];
            od;
         od;
         bottom := PermList(bottom);
         images[i] := g*bottom;
    od;

    K := GroupByGenerators(images,());
    hom := GroupHomomorphismByImages(GG,K,GG.generators,images);
    return KernelOfMultiplicativeGeneralMapping( hom );
end;


#############################################################################
##
#F  CentralizerTransSymmCSPG()  . . . . .  centralizer of transitive G in S_n
##
##  computes the centralizer of a transitive group G in S_n
##
CentralizerTransSymmCSPG := function(G)
    local   n,          # the degree of G
            stabgroup,  # subgroup of G stabilizing first base point
            x,          # the first base point
            L,          # the set of fixed points of stabgroup
            orbitx,     # the orbit of x in the centralizer;
                        # eventually, orbitx=L
            y,          # a point in L
            z,          # loop variable running through permutation domain
            i,          # loop variable
            h,          # a coset representative of G, written as word in the
                        # generators
            gens,       # list of generators for the centralizer
            gen,        # an element of gens
            Ggens,      # generators of G
            Ginverses,  # list of inverses for the generators of G
            H;          # output group
    if IsTrivial(G)  then
        return Subgroup(Parent(G),[()]);
    fi;
    
    if IsBound(G!.stabFxdPnts) then 
       x := G!.stabFxdPnts[1];
       L := G!.stabFxdPnts[2];
       n := LargestMovedPoint(G);
       if not IsBound(G.stabChain.orbit) or G.stabChain.orbit[1] <> x then
          G.stabChain := EmptyStabChain( [  ], (), x );
          AddGeneratorsExtendSchreierTree(G.stabChain,G.generators);
       fi;
    else 
       n := LargestMovedPoint(G);
       x := G.orbit[1];
       stabgroup := GroupByGenerators(G.stabilizer.generators,());
       L := Difference([1..n],MovedPoints(stabgroup));
    fi;

    Ginverses := GInverses( G );
    Ggens := ShallowCopy(G.generators);
    Add(Ggens,());
    Add(Ginverses,());

    # the centralizer of G is semiregular, acting transitively on L
    orbitx := [x];
    gens := [];
    while Length(orbitx) < Length(L) do

        # construct element of centralizer which carries x to new point in L
        gen := [];
        y := Difference(L,orbitx)[1];
        for z in [1..n] do
            h := CosetRepAsWord(x,z,G.transversal);
            h := InverseAsWord(h,Ggens,Ginverses);
            gen[z] := ImageInWord(y,h);
        od;
        Add(gens,PermList(gen));
        orbitx := OrbitPerms(gens,x);
    od;

    H := SubgroupNC( G, gens );
    H.size := Length(L);
    return H; 
end;


#############################################################################
##
#F  IntersectionNormalClosurePermGroup(<G>,<H>[,order]) . . . intersection of
#F                                   normal closure of <H> under <G> with <G>
##
##  computes $H^G \cap G$ as subgroup of Parent(G)
##
IntersectionNormalClosurePermGroup := function(arg)
    local   G,H,        # the groups to be handled
            n,          # maximum of degrees of G,H
            i,j,        # loop variables
            conperm,    # perm exchanging first and second n points
            extended,   # action of generators of G,H on 2n points
            newgens,    # set of extended generators
            options,    # options record for stabilizer computation
            group;      # the group generated by newgens
                        # stabilizing the second n points, we get H^G \cap G

    G := arg[1]; 
    H := arg[2];

    if IsTrivial(G) or IsTrivial(H)  then
        return TrivialSubgroup( Parent(G) );
    fi;

    n := Maximum(LargestMovedPoint(G),
                 LargestMovedPoint(H));
    newgens := [];
    conperm := PermList( Concatenation( [n+1 .. 2*n] , [1 .. n] ) );
    # extend the generators of G acting on [n+1..2n] exactly as on [1..n]
    for i in [1..Length(G.generators)] do
        newgens[i] := G.generators[i] * (G.generators[i] ^ conperm);
    od;

    # from the generators of H, create permutations which act on [n+1..2n]
    # as the original generator on [1..n] and which act trivially on [1..n]
    for i in [1..Length(H.generators)] do
        Add( newgens, H.generators[i]^conperm );
    od;

    group := GroupByGenerators(newgens,());

    # create options record for stabilizer chain computation
    options := rec( base := [n+1..2*n] );
    #if size of group is part of input, use it
    if Length(arg) = 3 then 
       options.size := arg[3];
       # if H is normalized by G and G,H already have stabilizer chains
       # then compute base for group
       #if ( IsBound(G.size) or IsBound(G.stabChain) ) and 
       #   ( IsBound(H.size) or IsBound(H.stabChain) )  then
       #   if Size(G) * Size(H) = arg[3] then
       #      options.knownBase := 
       #      Concatenation( List( Base(H), x -> n + x ), Base(G) ) ;
       #   fi;
       #fi;
    fi;
    StabChain(group,options);
    group := Stabilizer(group,[n+1 .. 2*n],OnTuples);
    return AsSubgroup( Parent(G),group);
end;


#############################################################################
##
#F  ActionAbelianCSPG() . . . . . . . . . action of abelian permutation group
##
##  given an abelian subgroup H of S_n, the routine codes the action of
##  H on its orbits. The output is an array of length 7, describing this
##  action; the components of this array are described at the local variable
##  section
ActionAbelianCSPG := function(H,n)
    local   i,j,k,      # loop variables
            orbits,     # list of orbits of H; 6th element of output
            action,     # list; the i^th element contains a list of
                        # generators for the action of H on i^th orbit
            inverse,    # inverse[i][k] is the inverse of action[i][k]
                        # 1st element of output
            C,          # C[i] is the group generated by action[i]
                        # 2nd element of output
            positionlist,
                        # for i in [1..n], positionlist[i] gives the position
                        # of i in its H orbit. 3rd element of output
            reprlist,   # for i in [1..n], reprlist[i] gives the position of
                        # the H orbit of i in orbits. 4th element of output
            cpositiongenlist,
                        # cpositionlength[i][k] gives the position in
                        # action[i] of the C[i] generator which occurs in
                        # C[i].transversal[k]. 5th element of output
            cumulativelength;
                        # cumulativelength[i] is the sum of lengths of first
                        # i-1 elements of orbits. 7th element of output

    orbits := Orbits(H,[1..n]);
    cumulativelength := [0];
    for i in [1..Length(orbits)-1] do
        cumulativelength[i+1] := cumulativelength[i]+Length(orbits[i]);
    od;

    positionlist := [];
    reprlist := [];
    for i in [1..Length(orbits)] do
        for j in [1..Length(orbits[i])] do
            positionlist[orbits[i][j]] := j;
            reprlist[orbits[i][j]] := i;
        od;
    od;

    # action[i][k] is the action of H.generators[k] on the i^th orbit of H,
    # viewed as a permutation on [1..Length(orbits[i])]
    action := [];
    inverse := [];
    for i in [1..Length(orbits)] do
        action[i] := [];
        inverse[i] := [];
        for k in [1..Length(H.generators)] do
            action[i][k] := [];
            for j in [1..Length(orbits[i])] do
                action[i][k][j]:=positionlist[orbits[i][j]^H.generators[k]];
            od;
            action[i][k] := PermList(action[i][k]);
            inverse[i][k] := action[i][k]^(-1);
        od;
    od;

    C := [];
    cpositiongenlist := [];
    for i in [1..Length(orbits)] do
        cpositiongenlist[i] := [];
        C[i] := GroupByGenerators(action[i],());

        # create transversal of C[i]
        C[i].stabChain := EmptyStabChain( [  ], (), 1 );
        Add(action[i],());
        Add(inverse[i],());
        AddGeneratorsExtendSchreierTree(C[i].stabChain,C[i].generators);

        # determine position of generators occuring in transversal
        for j in [1..Length(C[i].orbit)] do
            cpositiongenlist[i][j]:=Position(action[i],C[i].transversal[j]);
        od;
    od;

    return [inverse,C,positionlist,reprlist,
            cpositiongenlist,orbits,cumulativelength];
end;


#############################################################################
##
#F  ImageOnAbelianCSPG()  . image of normalizing element on orbits of abelian
##
##  given the action of an abelian group H encoded in actionlist by the
##  subroutine ActionAbelianCSPG, and a permutation g normalizing H,
##  this subroutine computes the conjugation action of g on the transitive
##  constituent pieces of H
##
ImageOnAbelianCSPG := function(g,actionlist)
    local   i,s,        # loop variables
            orbits,     # list of orbits of H
      # let action denote the list with the i^th element containing a list of
      # generators for the action of H on i^th orbit
            inverse,    # inverse[i][k] is the inverse of action[i][k]
            C,          # C[i] is the group generated by action[i]
            positionlist,
                        # for i in [1..n], positionlist[i] gives the position
                        # of i in its H orbit
            reprlist,   # for i in [1..n], reprlist[i] gives the position of
                        # the H orbit of i in orbits
            cpositiongenlist,
                        # cpositionlength[i][k] gives the position in
                        # action[i] of the C[i] generator which occurs in
                        # C[i].transversal[k]
            cumulativelength,
                        # cumulativelength[i] is the sum of lengths of first
                        # i-1 elements of orbits
            j,          # index of H-orbit in orbits which is the image of
                        # the i^th H-orbit
            x,          # position of element of i^th orbit which is mapped
                        # by g to first element of j^th orbit
            inv,        # the inverse of g
            gimage,     # output of the routine; conjugation action of g
            image,t;    # see explanation in body of routine

    inv := g^(-1);
    gimage := [];
    inverse := actionlist[1];
    C := actionlist[2];
    positionlist := actionlist[3];
    reprlist := actionlist[4];
    cpositiongenlist := actionlist[5];
    orbits := actionlist[6];
    cumulativelength := actionlist[7];

    # the transitive constituent pieces of H are regarded as a list of
    # length n; the (unique) piece carrying the first point of i^th orbit
    # to k^th point of i^th orbit is in the position cumulativelength[i]+k.
    # gimage will contain the conjugation action of g on the elements of
    # this list
    for i in [1..Length(orbits)] do

        # determine which orbit contains the images of pieces from i^th orbit
        j := reprlist[orbits[i][1]^g];

        # for each piece h from i^th orbit, we have to determine the image of
        # orbits[j][1] at the permutation g^(-1)*h*g
        # from regularity of action on orbits, this image determines the
        # conjugate first, compute the images of orbits[j][1] in g^(-1)*h,
        # and store the result in the array image. Then determine the
        # g-image of the result and store it in gimage.
        # This way, elements in "image" can be used more times,
        # and the running time is linear (no hidden log factors).
        x := positionlist[orbits[j][1]^inv];
        image := [x];
        gimage[cumulativelength[i]+1] := cumulativelength[j]+1;
        for s in [2..Length(C[i].orbit)] do

            # t is the predecessor in Schreier tree of C[i].orbit[s]
            t := C[i].orbit[s]^C[i].transversal[C[i].orbit[s]];
            image[C[i].orbit[s]] :=
                     image[t]^inverse[i][cpositiongenlist[i][C[i].orbit[s]]];
            gimage[cumulativelength[i]+C[i].orbit[s]] :=
                     cumulativelength[j]
                    +positionlist[orbits[i][image[C[i].orbit[s]]]^g];
        od;
    od;

    gimage := PermList(gimage);
    return gimage;
end;

#############################################################################
##
#F  ChiefSeriesPermGroup(<G>[,<through>])
##
ChiefSeriesPermGroup := function(arg)
local G,nser,U,i,j,k,cs,n,o,mat,mats,row,p,one,m,c,v,ser,gens,r,dim,im,
      through;
  G:=arg[1];
  if Length(arg)>1 then
    through:=arg[2];
  else
    through:=[];
  fi;
  nser:=[G];
  U:=G;
  while Size(U)>1 do
    # get maximal normal subgroup
    cs:=CompositionSeries(U);
    cs:=cs[2];

    if Length(through)>0 then
      if Size(U)=Size(through[1]) then
        through:=through{[2..Length(through)]};
      fi;
      if Length(through)>0 and not IsSubgroup(cs,through[1]) then
	# enforce way through
	Info(InfoGroup,1,"force");
	n:=NaturalHomomorphismByNormalSubgroup(U,through[1]);
	cs:=CompositionSeries(Image(n));
	cs:=cs[2];
	cs:=PreImage(n,cs);
      fi;
    fi;

    if IsNormal(G,cs) then
      # step is normal
      Add(nser,cs);
      n:=cs;
    else
      o:=GroupOnSubgroupsOrbit(G,cs);
      Info(InfoGroup,1,"orblen=",Length(o));
      n:=Intersection(o);
      #n:=o[1];
      #for i in o{[2..Length(o)]} do
        #n:=IntersectionNormalClosurePermGroup(n,i);
      #od;
      if HasAbelianFactorGroup(U,cs) then
        # abelian case, utilize MeatAxe to chop

	p:=Index(U,cs);
	one:=One(GF(p));

	# first get series
	v:=n;
	ser:=[n];
	gens:=[];
	while Size(v)<Size(U) do
	  repeat
	    r:=Random(U);
	  until not r in v;
	  Add(gens,r);
	  v:=ClosureGroup(v,r);
	  Add(ser,v);
	od;

	dim:=Length(gens);
	ser:=Reversed(ser);
	gens:=Reversed(gens);

	# now construct matrices for operation
	mats:=[];
	for i in GeneratorsOfGroup(G) do
	  mat:=[];
	  for j in gens do
	    im:=j^i;
	    row:=[];
	    for k in [1..dim] do
	      if not im in ser[k+1] then
	        # test power which does
		# Ug^l=U im
	        r:=First([1..p],l->im/gens[k]^l in ser[k+1]);
		Add(row,r);
		im:=im/gens[k]^r;
	      else
		Add(row,0);
	      fi;
	    od;
	    row:=row*one;
	    Add(mat,row);
	  od;
	  Add(mats,mat);
	od;

	m:=GModuleByMats(mats,GF(p));
	r:=MTX.BasesCompositionSeries(m);
	v:=[];
	for i in r do
	  im:=n;
	  for j in i do
	    im:=ClosureGroup(im,Product([1..dim],k->gens[k]^IntFFE(j[k])));
	  od;
	  # only intermediates
	  if Size(im)<Size(U) then
	    Add(v,im);
	  fi;
	od;
	v:=Reversed(v); # MTX sorts already
	#Sort(v,function(a,b) return Size(a)>Size(b);end);
        Info(InfoGroup,2,"i:",List(v,Size));

	#note the intermediates
	nser:=Concatenation(nser,v);

      else
        # nonabelian, as transitive operation on the components no proper
	# intermediate normal subgroup possible
	Add(nser,n);
      fi;
    fi;
    Info(InfoGroup,1,"Step ",Index(U,n));
    U:=n;
  od;
  return nser;
end;

#############################################################################
##
#M  ChiefSeries
##
InstallMethod(ChiefSeries,"perm group",true,[IsPermGroup],0,
  ChiefSeriesPermGroup);

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  grpprmcs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
