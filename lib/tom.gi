#############################################################################
##
#W  tom.gi                   GAP library                       Goetz Pfeiffer
#W                                                          & Thomas Merkwitz
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains methods for tables of marks.
##
##
Revision.tom_gi :=
    "@(#)$Id$";

#############################################################################
##
##  1) Methods to construct a table of marks for a given group
##
#############################################################################
##
#M  TableOfMarks( <G> ) .  .  .  .  .  .  .  .   get or make a table of marks
##
##  For a group <G> 'TableOfMarks' dipatches to 'TableOfMarksGroup'.

InstallMethod(TableOfMarks,"method for a group", true, [IsGroup],0,
        TableOfMarksGroup);

#############################################################################
##
#M  TableOfMarksGroup(<G>)  . . . . . . . . make a table of marks for a group
##
##  If the group is cyclic than 'TableOfMarksGroup' constructs the table
##  of marks only from the knowledge about the structure of cyclic groups.
##
##  If the group is solvable 'TableOfMarks' computes the lattice of subgroups
##  first and then the table of marks from the lattice.
##
##  If <G> know its lattice of subgroups then 'TableOfMarksGroup' computes
##  the table of marks from the lattice
##
##  If the group don't know its lattice of subgroup or conjugacy classes of
##  subgroups the table of marks and the conjugacy classes of subgroups are
##  computed at the same time by the cyclic extension method. Only the table
##  of marks is stored because the conjugacy classes of subgroups or the 
##  lattice of subgroups can be easily read off.
##
#F  GeneratorsListTom .  .  .  .  .  .  .  .  .  .  .  .  . create generators
##  
##  'GeneratorsListTom' lists a set of generators for a representative of each
##   conjugacy class of subgroups.
##
##  TableOfMarksByLattice( <G> )
##
##  'TableOfMarksByLattice' calculates the table of marks from the lattice
##  of subgroups of <G>.

InstallMethod(TableOfMarksGroup,"method for a cyclic group",true,
        [IsGroup and IsCyclic],0, 
function(G)
    local n, record, obj, words, subs, marks, classNames, derivedSubgroups,
          name, normalizer, i, j, divs, index, group, nn, list;


    n:=Size(G);

    # construct the table of marks without the group

    # initialize
    divs:= DivisorsInt(n);
    words:= [];
    subs:= [];
    marks:= [];
    classNames:=[];

    # construct each subgroup (each divisor)  
    for i in [1..Length(divs)] do
        classNames[i]:= String(divs[i]);
        CONV_STRING( classNames[i]);
        if i = 1 then
            words[i]:=[[[]]];
        else
            words[i]:= [[[1,n/divs[i]]]];
        fi;
        subs[i]:= [];
        marks[i]:= [];
        index:= n / divs[i];
        for j in [1..i] do
            if divs[i] mod divs[j] = 0 then
                Add(subs[i], j);
                Add(marks[i], index);
            fi;
        od;
    od;

    derivedSubgroups:=List([1..n],x->1);
    normalizer:=List([1..n],x-> n);

    # if the cyclic group has more than one generator the 
    # words have to be changed
    if Length(GeneratorsOfGroup(G)) > 1 then
        nn:=Length(GeneratorsOfGroup(G));
        list:=Flat(List([1..nn],x->[x,1]));
        for i in [2..Length(words)] do
            words[i][1][1][1]:=nn+1;
            words[i][1]:=[list,words[i][1][1]];
        od;
    fi;

    # convert the words into internal representation
    words:=ConvWordsTom(words,Length(GeneratorsOfGroup(G)));

    # add new components
    if HasName(G) then
        name:=Name(G);
    else
        name:=Concatenation("C",String(n));
    fi;

    # make the object
    record:=ConvertToTableOfMarks(TOM([name, subs, marks, 0, 0, normalizer, 
                    derivedSubgroups, G, words]));
    SetClassNamesTom(record,classNames);
    return record;
end);

#compute generators for a representative of each conjugacy class of subgroups
GeneratorsListTom:=function(group)
    local cc, sub, gen, res, pos, grp, elm;

    cc:=ConjugacyClassesSubgroups(group);
    # take the generators 
    sub:= List(cc, x-> GeneratorsOfGroup(Representative(x)));

    # form the generators list 
    gen:= Union(sub);

    # compute the positions
    res:= [];
    for grp in sub do
        pos:= [];
        for elm in grp do
            Add(pos, Position(gen, elm));
        od;
        Add(res, pos);
    od;
    return [gen,res];

end;

InstallGlobalFunction(TableOfMarksByLattice,
function (G)
    local   marks,             # components of the table of marks
            subs,
            normalizers,      
            derivedSubgroups, 
            gens,
            tom,
            mrks,              # marks for one class
            ind,               # index of <I> in <N>
            zuppos,            # generators of prime power order
            classes,           # list of all classes
            classesZups,       # zuppos blist of classes
            I,                 # representative of a class
            Ielms,             # elements of <I>
            Izups,             # zuppos blist of <I>
            N,                 # normalizer of <I>
            D,                 # derived subgroup of <I>,
            Delms,             # elements of <D>,
            Dzups,             # zuppos blist of <D>
            DG,                # derived subgroup of <G>
            DGzups,            # zuppos blist of <DG>
            Jzups,             # zuppos of a conjugate of <I>
            Kzups,             # zuppos of a representative in <classes>
            reps,              # transversal of <N> in <G>
            i,k,l,r;         # loop variables

    # compute the lattice,fetch the classes,zuppos,and representatives
    classes:=ShallowCopy(ConjugacyClassesSubgroups(G));
    # sort the classes
    Sort(classes,function(a,b) return Size(Representative(a)) <
                          Size(Representative(b)); end);
    classesZups:=[];

    # compute a system of generators for the cyclic sgr. of prime power size
    zuppos:=Zuppos(G);

    # initialize the table of marks
    Info(InfoLattice,1,"computing table of marks");
    subs:=List([1..Length(classes)],x->[]);
    marks:=List([1..Length(classes)],x->[]);
    derivedSubgroups:=[];
    normalizers:=[];
    DG:=DerivedSubgroup(G);
    if Size(DG) = Size(G) then   # G perfect
        derivedSubgroups[Length(classes)]:= Length(classes);
    elif Size(DG) = 1 then       # G abelian
        derivedSubgroups[Length(classes)]:= 1;
    else
        DGzups:=BlistList(zuppos,AttributeValueNotSet(AsList,DG));
    fi;
    Unbind(DG);

    # loop over all classes
    for i  in [1..Length(classes)-1]  do

        # take the subgroup <I>
        I:=Representative(classes[i]);

        # compute the zuppos blist of <I>
        Ielms:=AttributeValueNotSet(AsList,I);
        Izups:=BlistList(zuppos,Ielms);
        classesZups[i]:=Izups;

        # compute the normalizer of <I>
        N:=Normalizer(G,I);
        ind:=Size(N)/Size(I);
        if Size(N)=Size(I) then  # <I> selfnormalizing
            normalizers[i]:=i;
        elif Size(N)=Size(G) then # <I> normal
            normalizers[i]:=Length(classes);
        else
            normalizers[i]:=BlistList(zuppos,
	                              AttributeValueNotSet(AsList,N));
        fi;


        # compute the derived subgroup
        D:=AttributeValueNotSet(DerivedSubgroup,I);
        if Size(D) = Size(I) then  # <I> perfect
            derivedSubgroups[i]:=i;
        elif Size(D) = 1 then      # <I> abelian
            derivedSubgroups[i]:=1;
        else
            Delms:=AttributeValueNotSet(AsList,D);
            Dzups:=BlistList(zuppos,Delms);
        fi;

        # compute the right transversal
	# (but don't store it in the parent)
        reps:=RightTransversalOp(G,N);

        # set up the marking list
        mrks   :=ListWithIdenticalEntries(Length(classes),0);
        mrks[1]:=Length(reps) * ind;
        mrks[i]:=1 * ind;

        # loop over the conjugates of <I>
        for r  in [1..Length(reps)]  do

            # compute the zuppos blist of the conjugate
            if reps[r] = One(G) then
                Jzups:=Izups;
            else
                Jzups:=BlistList(zuppos,OnTuples(Ielms,reps[r]));
                if not IsBound(derivedSubgroups[i]) then
                    Dzups:=  BlistList(zuppos,OnTuples(Delms,reps[r]));
                fi;
            fi;

            #look if the conjugate of <I> is the normalizer of a smaller
            #class
            for k in [2..i-1] do
                if normalizers[k]=Jzups then
                    normalizers[k]:=i;
                fi;
            od; 

            # look if it is the derived subgroup of G
            if IsBound(DGzups) and DGzups = Jzups then
                derivedSubgroups[Length(classes)]:=i;
                Unbind(DGzups);
            fi;

            # loop over all other (smaller classes)
            for k  in [2..i-1]  do
                Kzups:=classesZups[k];

                #test if the <K> is the derived subgroup of <J>
                if not IsBound(derivedSubgroups[i]) and Kzups = Dzups then
                    derivedSubgroups[i]:=k;
                    Unbind(Dzups);
                fi;

                # test if the <K> is a subgroup of <J>
                if IsSubsetBlist(Jzups,Kzups)  then
                    mrks[k]:=mrks[k] + ind;
                fi;

            od;

        od;

        # compress this line into the table of marks
        for k  in [1..i]  do
            if mrks[k] <> 0  then
                Add(subs[i],k);
                Add(marks[i],mrks[k]);
            fi;
        od;

        Unbind(Ielms);
        Unbind(Delms);
        Unbind(reps);
        Info(InfoLattice,2,"testing class ",i,", size = ",Size(I),
	     ", length = ",Size(G) / Size(N),", includes ",
	     Length(marks[i])," classes");

    od;

    # handle the whole group
    Info(InfoLattice,2,"testing class ",Length(classes),", size = ",
         Size(G), ", length = ",1,", includes ",
         Length(marks[Length(classes)])," classes");
    subs[Length(classes)]:=[1..Length(classes)] + 0;
    marks[Length(classes)]:=ListWithIdenticalEntries(Length(classes),1);
    normalizers[Length(classes)]:=Length(classes);

    # compute the generators
    gens:=GeneratorsListTom(G);

    # make the object
    tom:=ConvertToTableOfMarks( TOM([ 0,subs,marks,0,0,normalizers,
                 derivedSubgroups,G,0,gens[1],gens[2]]));
    if HasName(G) then
        SetIdentifierOfTom(tom,Name(G));
    fi;

    return tom;
end);

InstallMethod(TableOfMarksGroup,"method for a group with lattice", true,
       [IsGroup and HasLatticeSubgroups],10,TableOfMarksByLattice);

InstallMethod(TableOfMarksGroup,"method for solvable groups",true, 
     [IsSolvableGroup],0, 
function(G)
    LatticeSubgroups(G);
    return TableOfMarksByLattice(G);
end);

InstallMethod(TableOfMarksGroup,"cyclic extension",true,[IsGroup],0,
function(G)
    local   factors,           # factorization of <G>'s size
            zuppos,            # generators of prime power order
            ll,
            zupposPrime,       # corresponding prime
            zupposPower,       # index of power of generator
            nrClasses,         # number of classes
            classesZups,       # zuppos blist of classes
            classesExts,       # extend-by blist of classes
            perfect,           # classes of perfect subgroups of <G>
            perfectNew,        # this class of perfect subgroups is new
            perfectZups,       # zuppos blist of perfect subgroups
            layerb,            # begin of previos layer
            layere,            # end of previous layer
            H,                 # representative of a class
            Hzups,             # zuppos blist of <H>
            Hexts,             # extend blist of <H>
            I,                 # new subgroup found
            Ielms,             # elements of <I>
            Izups,             # zuppos blist of <I>
            N,                 # normalizer of <I>
            Nzups,             # zuppos blist of <N>
            Jzups,             # zuppos of a conjugate of <I>
            Kzups,             # zuppos of a representative in <classes>
            reps,              # transversal of <N> in <G>
            h,i,k,l,r,         # loop variables
            tom,               # table of marks (result)
            marks,             # componets of the table of marks
            subs,              # 
            normalizers,       #
            derivedSubgroups,  #
            groups,            #
            generators,        #
            genszups,          # mark the generators        
            zupposmarks,       # mark the zuppos used 
            gr, pos,           # used to computed generators for the perfect
            # subgroups
            mrks,              # marks for one class
            ind,               # index of <I> in <N>
            D,                 # derived subgroup of <I>,
            Delms,             # elements of <D>,
            Dzups,             # zuppos blist of <D>
            DGzups,            # zuppos blist of <DG>
            order, list, perm; # used to sort the table of marks

    # compute the factorized size of <G>
    factors:=Factors(Size(G));

    # compute a system of generators for the cyclic sgr. of prime power size
    zuppos:=Zuppos(G);
    ll:=Length(zuppos);

    Info(InfoLattice,1,"<G> has ",Length(zuppos)," zuppos");

    # compute the prime corresponding to each zuppo and the index of power
    zupposPrime:=[];
    zupposPower:=[];
    for r  in zuppos  do
        i:=SmallestRootInt(Order(r));
        Add(zupposPrime,i);
        k:=0;
        while k <> false  do
            k:=k + 1;
            if GcdInt(i,k) = 1  then
                l:=Position(zuppos,r^(i*k));
                if l <> fail  then
                    Add(zupposPower,l);
                    k:=false;
                fi;
            fi;
        od;
    od;
    Info(InfoLattice,1,"powers computed");

    # get the perfect subgroups
    perfect:=RepresentativesPerfectSubgroups(G);
    perfect:=Filtered(perfect,i->Size(i)>1 and Size(i)<Size(G));

    perfectZups:=[];
    perfectNew :=[];
    for i  in [1..Length(perfect)]  do
        I:=perfect[i];
        perfectZups[i]:=BlistList(zuppos,AttributeValueNotSet(AsList,I));
        perfectNew[i]:=true;
    od;
    Info(InfoLattice,1,"<G> has ",Length(perfect),
         " representatives of perfect subgroups");


    # initialize the classes list
    nrClasses:=1;
    classesZups:=[BlistList(zuppos,[One(G)])];
    classesExts:=[DifferenceBlist(BlistList(zuppos,zuppos),classesZups[1])];
    zupposmarks:=ListWithIdenticalEntries(Length(zuppos),false);
    layere:=1; 
    layerb:=1;    

    # initialize the table of marks
    Info(InfoLattice,1,"computing table of marks");
    subs:=[[1]];
    marks:=[[Size(G)]];
    normalizers:=[fail];
    derivedSubgroups:=[1];
    genszups:=[[]];

    I:=DerivedSubgroup(G);
    if Size(I) = Size(I) then   # G perfect
        DGzups:=fail;
    elif Size(I) = 1 then       # G abelian
        DGzups:=1;
    else
        DGzups:=BlistList(zuppos,AsList(I));
    fi;
    Unbind(I);   

    # loop over the layers of group (except the group itself)
    for l  in [1..Length(factors)-1]  do
        Info(InfoLattice,1,"doing layer ",l,",",
             "previous layer has ",layere-layerb+1," classes");

        # extend representatives of the classes of the previous layer
        for h  in [layerb..layere]  do

            # get the representative,its zuppos blist and extend-by blist
            H:=Subgroup( Parent(G), zuppos{genszups[h]});
            Hzups:=classesZups[h];
            Hexts:=classesExts[h];

            Info(InfoLattice,2,"extending subgroup ",h,", size = ",Size(H));

            # loop over the zuppos whose <p>-th power lies in <H>
            for i  in [1..Length(zuppos)]  do
                if Hexts[i] and Hzups[zupposPower[i]]  then

                    # make the new subgroup <I>
                    I:=Subgroup(Parent(G),Concatenation(GeneratorsOfGroup(H),
                               [zuppos[i]]));

                    SetSize(I,Size(H) * zupposPrime[i]);

                    # compute the zuppos blist of <I>
                    Ielms:=AttributeValueNotSet(AsList,I);
                    Izups:=BlistList(zuppos,Ielms);

                    # compute the normalizer of <I>
                    N:=Normalizer(G,I);
                    ind:=Size(N) / Size(I);
                    Info(InfoLattice,2,"found new class ",nrClasses+1,
		         ", size = ",Size(I),
                         " length = ",Size(G) / Size(N));

                    # make the new conjugacy class
                    nrClasses:=nrClasses + 1;
                    if l < Length(factors) -1  then
                        classesZups[nrClasses]:=Izups;
                    fi;
                    subs[nrClasses]:=[];
                    marks[nrClasses]:=[];
                    genszups[nrClasses]:=ShallowCopy(genszups[h]);
                    Add(genszups[nrClasses],i);
                    zupposmarks[i]:=true;

                    #store the extend by blist and initialize the normalizer
                    if Size(N)=Size(I) then  # <I> selfnormalizing
                        normalizers[nrClasses]:=nrClasses;
                        if l < Length(factors)-1 then
                            classesExts[nrClasses]:=
                              ListWithIdenticalEntries(ll,false);
                        fi;
                    elif Size(N)=Size(G) then # <I> normal
                        normalizers[nrClasses]:=fail;
                        if l < Length(factors) -1 then
                            classesExts[nrClasses]:=
                              DifferenceBlist(BlistList([1..ll],[1..ll]),
                                                                 Izups);
                        fi;
                    else
                        Nzups:=BlistList(zuppos,AttributeValueNotSet(AsList,N));
                        normalizers[nrClasses]:=ShallowCopy(Nzups);
                        if l < Length(factors) -1 then
                            SubtractBlist(Nzups,Izups);
                            classesExts[nrClasses]:=Nzups;
                        fi;
                    fi;
                    Unbind( Nzups);

                    # compute the derived subgroup
                    D:=AttributeValueNotSet(DerivedSubgroup,I);
                    if Size(D) = Size(I) then  # <I> perfect
                        derivedSubgroups[nrClasses]:=nrClasses;
                    elif Size(D) = 1 then      # <I> abelian
                        derivedSubgroups[nrClasses]:=1;
                    else
                        Delms:=AttributeValueNotSet(AsList,D);
                        Dzups:=BlistList(zuppos,Delms);
                    fi;
                    Unbind(D);

                    # compute the transversal
                    reps:=RightTransversalOp(G,N);

                    # set up the marking list
                    mrks:=ListWithIdenticalEntries(nrClasses,0);
                    mrks[nrClasses]:=1 * ind;

                    # loop over the conjugates of <I>
                    for r  in reps  do

                        # compute the zuppos blist of the conjugate
                        if r = One(G)  then
                            Jzups:=Izups;
                        else
                            Jzups:=BlistList(zuppos,OnTuples(Ielms,r));
                            if not IsBound(derivedSubgroups[nrClasses]) then
                                Dzups:=BlistList(zuppos,OnTuples(Delms,r));
                            fi;
                        fi;

                        # look if the conjugate of <I> is the normalizer of 
                        # a smaller class
                        for k in [2..layere] do
                            if normalizers[k]=Jzups then
                                normalizers[k]:=nrClasses;
                            fi;
                        od; 

                        # look if it is the derived subgroup of G
                        if IsList(DGzups) and DGzups = Jzups then
                            DGzups:=nrClasses;
                        fi;

                        # loop over the already found classes
                        for k  in [1..layere]  do
                            Kzups:=classesZups[k];

                            #test if the <K> is the derived subgroup of <J>
                            if not IsBound(derivedSubgroups[nrClasses]) and 
                               Kzups = Dzups then
                                derivedSubgroups[nrClasses]:=k;
                                Unbind(Dzups);
                                Unbind(Delms);
                            fi;


                            # test if the <K> is a subgroup of <J>
                            if IsSubsetBlist(Jzups,Kzups)  then
                                mrks[k]:=mrks[k] + ind;
                                # don't extend <K> by the elements of <J>
                                if k >= h then
                                    SubtractBlist(classesExts[k],Jzups);
                                fi;
                            fi;

                        od;#for k in [2..layere]

                    od;#for r in reps

                    # compress this line into the table of marks
                    for k  in [1..nrClasses]  do
                        if mrks[k] <> 0  then
                            Add(subs[nrClasses],k);
                            Add(marks[nrClasses],mrks[k]);
                        fi;
                    od;
                    Info(InfoLattice,2,"testing class ",nrClasses,
                         " size = ", Size(I),
                         ", length = ",Size(G) / Size(N),", includes ",
                         Length(marks[nrClasses])," classes");

                    # now we are done with the new class
                    Unbind(Ielms);
                    Unbind(reps);
                    Unbind(I);
                    Unbind(N);
                    Info(InfoLattice,2,"tested inclusions");

                fi; # if Hexts[i] and Hzups[zupposPower[i]]  then ...
            od; # for i  in [1..Length(zuppos)]  do ...

            #remove the stuff we don't need anymore
            classesExts[h]:=false;
            Unbind(H);
        od; # for h  in [layerb..layere]  do ...

        # add the classes of perfect subgroups
        for i  in [1..Length(perfect)]  do
            if    perfectNew[i]
                  and IsPerfectGroup(perfect[i])
                  and Length(Factors(Size(perfect[i]))) = l
                  then

                # make the new subgroup <I>
                I:=perfect[i];

                # compute the zuppos blist of <I>
                Ielms:=AttributeValueNotSet(AsList,I);
                Izups:=BlistList(zuppos,Ielms);

                # compute the normalizer of <I>
                N:=Normalizer(G,I);
                ind:=Size(N) / Size(I);

                Info(InfoLattice,2,"found new class ",nrClasses+1,
                     ", size = ",Size(I),
                     " length = ",Size(G) / Size(N));

                # make the new conjugacy class
                nrClasses:=nrClasses + 1;
                if l < Length(factors) -1 then
                    classesZups[nrClasses]:=Izups;
                fi;
                subs[nrClasses]:=[];
                marks[nrClasses]:=[];
                gr:=TrivialSubgroup(G);
                genszups[nrClasses]:=[];
                k:=0;
                while Size(gr) <> Size(I) do
                    k:=k+1;
                    if  Izups[k] and not zuppos[k] in gr  then
                        gr:=ClosureGroup(gr,zuppos[k]);
                        Add(genszups[nrClasses],k);
                        zupposmarks[k]:=true;
                    fi;
                od;

                #store the extend by blist and initialize the normalizer
                if Size(N)=Size(I) then  # <I> selfnormalizing
                    normalizers[nrClasses]:=nrClasses;
                    if l < Length(factors)-1 then
                        classesExts[nrClasses]:=
                          ListWithIdenticalEntries(ll,false);
                    fi;
                elif Size(N)=Size(G) then # <I> normal
                    normalizers[nrClasses]:=fail;
                    if l < Length(factors) -1 then
                        classesExts[nrClasses]:=
                          DifferenceBlist(BlistList([1..ll],[1..ll]),Izups);
                    fi;
                else
                    Nzups:=BlistList(zuppos,AttributeValueNotSet(AsList,N));
                    normalizers[nrClasses]:=ShallowCopy(Nzups);
                    if l < Length(factors) -1 then
                        SubtractBlist(Nzups,Izups);
                        classesExts[nrClasses]:=Nzups;
                    fi;
                fi;

                # compute the derived subgroup
                derivedSubgroups[nrClasses]:=nrClasses;

                # compute the transversal
                reps:=RightTransversalOp(G,N);

                # set up the marking list
                mrks:=ListWithIdenticalEntries(nrClasses,0);
                mrks[1]:=Length(reps) * ind;
                mrks[nrClasses]:=1 * ind;

                # loop over the conjugates of <I>
                for r  in reps  do

                    # compute the zuppos blist of the conjugate
                    if r = One(G)  then
                        Jzups:=Izups;
                    else
                        Jzups:=BlistList(zuppos,OnTuples(Ielms,r));
                    fi;

                    #look if the conjugate of <I> is the normalizer of a 
                    #smaller class
                    for k in [2..layere] do
                        if normalizers[k]=Jzups then
                            normalizers[k]:=nrClasses;
                        fi;
                    od; 

                    # look if it is the derived subgroup of G
                    if IsList(DGzups) and DGzups = Jzups then
                        DGzups:=nrClasses;
                    fi;


                    # loop over the perfect classes
                    for k  in [i+1..Length(perfect)]  do
                        Kzups:=perfectZups[k];

                        # throw away classes that appear twice in perfect
                        if Jzups = Kzups  then
                            perfectNew[k]:=false;
                            perfectZups[k]:=[];
                        fi;

                    od;

                    # loop over all other (smaller) classes
                    for k  in [2..layere]  do
                        Kzups:=classesZups[k];

                        # test if the <K> is a subgroup of <J>
                        if IsSubsetBlist(Jzups,Kzups)  then
                            mrks[k]:=mrks[k] + ind;
                        fi;

                    od;
                od;

                # compress this line into the table of marks
                for k  in [1..nrClasses]  do
                    if mrks[k] <> 0  then
                        Add(subs[nrClasses],k);
                        Add(marks[nrClasses],mrks[k]);
                    fi;
                od;


                Info(InfoLattice,2,"testing class ",nrClasses,", size = ",
                     Size(I),
                     ", length = ",Size(G) / Size(N),", includes ",
                     Length(marks[nrClasses])," classes");


                # now we are done with the new class
                Unbind(Ielms);
                Unbind(reps);
                Unbind(I);
                Info(InfoLattice,2,"tested equalities");

                # unbind the stuff we dont need any more
                perfectZups[i]:=[];
            fi; 
	    # if IsPerfectGroup(I) and Length(Factors(Size(I))) = layer ...
        od; # for i  in [1..Length(perfect)]  do

        # on to the next layer
        layerb:=layere+1;
        layere:=nrClasses;
    od; # for l  in [1..Length(factors)-1]  do ...
    Unbind(classesZups);

    # add the whole group to the list of classes
    Info(InfoLattice,1,"doing layer ",Length(factors),",",
         " previous layer has ",layere-layerb+1," classes");
    if Size(G)>1  then
        Info(InfoLattice,2,"found whole group, size = ",Size(G),",",
                                                      "length = 1");
        nrClasses:=nrClasses + 1;
        subs[nrClasses]:=[1..nrClasses] + 0;
        marks[nrClasses]:=ListWithIdenticalEntries(nrClasses,1);
        if DGzups = fail then
            derivedSubgroups[nrClasses]:=nrClasses;
        else
            derivedSubgroups[nrClasses]:=DGzups;
        fi;
        normalizers[nrClasses]:=nrClasses;
        Info(InfoLattice,2,"testing class ",nrClasses,", size = ",
             Size(G), ", length = ",1,", includes ",
             Length(marks[nrClasses])," classes");
    fi;

    # set the normalizer for normal subgroups
    for i in [1..nrClasses-1] do
        if normalizers[i] = fail then
            normalizers[i]:=nrClasses;
        fi;
    od;

    #Sort the table of marks
    order:=List(marks,x->Size(G)/x[1]);
    list:=[1..nrClasses];
    Sort(list, function(a,b) return order[a] < order[b] or(order[a] = 
          order[b] and order[normalizers[b]] <order[normalizers[a]]); end);

    perm:=Sortex(list)^-1;
    derivedSubgroups:=List(derivedSubgroups,x->x^perm);
    derivedSubgroups:=Permuted(derivedSubgroups, perm);
    normalizers:=List(normalizers, x-> x^perm);
    normalizers:=Permuted(normalizers, perm);
    subs:=List(subs,x-> List(x, y-> y^perm));
    subs:=Permuted(subs,perm);
    marks:=Permuted(marks, perm);
    for i in [1..Length(marks)] do
        SortParallel(subs[i], marks[i]);
    od;
    genszups:=Permuted(genszups, perm);

    # compute generators for each subgroup
    k:=1;
    pos:=[];  
    for i in [1..Length(zuppos)] do
        if zupposmarks[i] then
            zupposmarks[i]:=k;
            k:=k+1;
            Add(pos,i);
        fi;
    od; 
    generators:=Concatenation(zuppos{pos},GeneratorsOfGroup(G));
    groups:=[];
    for i in [1..nrClasses-1] do
        groups[i]:=zupposmarks{genszups[i]};
    od;
    groups[nrClasses]:=[k..k+Length(GeneratorsOfGroup(G))-1 ];

    # make the object
    tom:=ConvertToTableOfMarks( TOM([ 0,subs,marks,0,0,normalizers,
             derivedSubgroups,G,0,generators,groups]));
    if HasName(G) then
        SetIdentifierOfTom(tom,Name(G));
    fi;

    return tom;
end);

#############################################################################
##
##  2) Other Methods to construct a table of marks
##
#############################################################################
##
#M  TableOfMarks( < matrix > )  .  .  .  .  .  .  .  .  .   converts a matrix
##
InstallOtherMethod(TableOfMarks,"converts a matrix",true,[IsMatrix],0,
function(mat)
    local i, j, subs, marks, normalizer, tom;

    # mat must be lower triangular
    if ForAny([1..Length(mat)], x->SizeBlist(
               List(mat[x]{[x+1..Length(mat)]}, y-> y<> 0)) > 0) then
        Error( "the matrix must be lower triangular\n" );
    fi;

    # all entries must be non negativ, the diagonal and the first row must
    # have positive entries
    if IsInt(Position(DiagonalOfMat, 0)) or IsInt(Position(
               List(mat, x->x[1]), 0)) or Minimum(Flat(mat)) < 0 then
        Error("not a table of marks");
    fi;

    # convert it
    subs:= []; marks:= [];
    for i in [1..Length(mat)] do
        subs[i]:= [];
        marks[i]:= [];
        for j in [1..i] do
            if mat[i][j] > 0 then
                Add(subs[i], j);
                Add(marks[i], mat[i][j]);
            fi;
        od;
    od;

    # make the object
    ConvertToTableOfMarks(TOM([0,subs,marks,0,0,0,0,0,0]));

    # test it
    if not TestTom(tom) then
        Error("not a table of marks");
    fi;

    Print("Attention, not sure if it is a real 'table of marks'\n");
    return tom;

end);

#############################################################################
##
#M  TableOfMarksCyclic( < int > ) .  .  .  .  .  .  .  .  .  .   cyclic group
##
##  'TomCyclic' constructs the table of  marks of the  cyclic group of  order
##  <n>.
##
InstallMethod(TableOfMarksCyclic,true,[IsPosInt],0,
function(n)

    local obj, words, subs, marks, classNames, derivedSubgroups, 
          normalizer, i, j, divs, index, group;

    # initialize 
    divs:= DivisorsInt(n);
    words:= [];
    subs:= [];
    marks:= [];
    classNames:=[];

    # construct each subgroup (for each divisor)
    for i in [1..Length(divs)] do
        classNames[i]:= String(divs[i]);
        CONV_STRING( classNames[i]);
        if i = 1 then
            words[i]:=[[[]]];
        else
            words[i]:= [[[1,n/divs[i]]]];
        fi;
        subs[i]:= [];
        marks[i]:= [];
        index:= n / divs[i];
        for j in [1..i] do
            if divs[i] mod divs[j] = 0 then
                Add(subs[i], j);
                Add(marks[i], index);
            fi;
        od;
    od;

    # convert the words into internal representation
    words:=ConvWordsTom(words,1);

    # additional components
    derivedSubgroups:=ListWithIdenticalEntries(n,1);
    normalizer:=ListWithIdenticalEntries(n,n);
    group:=Group(PermList(Concatenation([2..n],[1])));
    SetSize(group,n);
    SetName(group,Concatenation("C",String(n)));

    # make the object and add attributes
    obj:=ConvertToTableOfMarks(TOM([Name(group),subs,marks,0,0,normalizer,
                 derivedSubgroups,group,words]));
    SetClassNamesTom(obj,classNames);
    SetTableOfMarksGroup(GroupOfTom(obj), obj);

    return obj;
end);

#############################################################################
##
#M TableOfMarksFrobenius( <p>, <q> )  The Table of Marks of Frobenius Groups.
##
##  'TomFrobenius' computes  the table of marks  of a  Frobenius group $p:q$,
##  where $p$ is a prime and $q$ divides $p-1$.
##
InstallMethod(TableOfMarksFrobenius,"tom for a frobenius group",true,
        [IsPosInt, IsPosInt],0,
function( p,q )
    local tom, classNames,marks, subs, normalizers, 
          derivedSubgroups,i, j, n, ind, divs;

    if not IsPrimeInt(p) then
        Error("not yet implemented");
    fi;
    if (p-1) mod q <> 0 then
        Error("not frobenius");
    fi;

    classNames:=[];
    subs:= [];
    marks:= [];
    normalizers:=[];
    derivedSubgroups:=[];
    n:= p*q;
    divs:= DivisorsInt(n);

    for i in [1..Length(divs)] do
        ind:= n/divs[i];
        subs[i]:= [1];
        marks[i]:= [ind];
        if ind mod p = 0 then # d
            classNames[i]:= String(divs[i]);
            CONV_STRING( classNames[i]);
            derivedSubgroups[i]:=1;
            if i = 1 then
                normalizers[i]:= Length(divs);
            else
                normalizers[i]:=Position(divs,q);
            fi;
            for j in [2..i] do
                if marks[j][1] mod ind = 0 then
                    Add(subs[i], j);
                    Add(marks[i], ind/p);
                fi;
            od;
        else # p:d
            classNames[i]:= Concatenation(String(p), ":", String(divs[i]/p));
            CONV_STRING(classNames[i]);
            derivedSubgroups[i]:=Position(divs,p);
            normalizers[i]:=Length(divs);
            for j in [2..i] do
                if marks[j][1] mod ind = 0 then
                    Add(subs[i], j);
                    Add(marks[i], ind);
                fi;
            od;
        fi;
    od;

    # make the object and add attributes
    tom:=ConvertToTableOfMarks( TOM([ 0,subs,marks,0,0,normalizers,
                 derivedSubgroups,0,0]));
    SetIdentifierOfTom(tom,Concatenation("frobenius group( ",
            String(p),", ",String(q)," )"));
    SetClassNamesTom(tom,classNames);

    return tom;
end);

#############################################################################
##
#M  TableOfMarksDihedral( <m> )  .  .  .  .  .  .  .  . dihedral group $D_m$.
##
##  'TomDihedral'  constructs the table  of  marks of the  dihedral  group of
##  order <m>.
##
InstallMethod(TableOfMarksDihedral, "table of marks of a dihedral group",
        true, [IsPosInt], 0,
function( m )

    local i, j, divs, n, name, marks, subs, type, nrs, pt, d, construct, ord,
          tom, nametom;

    n:= m/2;

    if not IsInt(n) then
        Error(" <m> must not be odd ");
    fi;

    divs:= DivisorsInt(m);

    construct:= [[

                  function(i, j)
        if divs[i] mod divs[j] = 0 then
            Add(subs[nrs[i]], nrs[j]);
            Add(marks[nrs[i]], m/divs[i]);
        fi;
    end,

      Ignore,

      function(i, j)
        if divs[i] mod divs[j] = 0 then
            Add(subs[nrs[i]], nrs[j]);
            Add(marks[nrs[i]], m/divs[i]);
        fi;
    end], [

           function(i, j)
        if divs[i] mod divs[j] = 0 and divs[i] > divs[j] then
            Add(subs[nrs[i]], nrs[j]);
            Add(marks[nrs[i]], m/divs[i]);
        fi;
    end,

      function(i, j)
        if divs[i] mod divs[j] = 0 then
            Add(subs[nrs[i]], nrs[j]);
            Add(marks[nrs[i]], 1);
        fi;
    end,

      function(i, j)
        if divs[i] mod divs[j] = 0 then
            Append(subs[nrs[i]], [nrs[j]..nrs[j]+2]);
            Append(marks[nrs[i]], [m/divs[i], 1, 1]);
        fi;
    end], [

           function(i, j)
        if divs[i] mod (2*divs[j]) = 0 then
            Add(subs[nrs[i]], nrs[j]);
            Add(subs[nrs[i]+1], nrs[j]);
            Add(subs[nrs[i]+2], nrs[j]);
            Add(marks[nrs[i]], m/divs[i]);
            Add(marks[nrs[i]+1], m/divs[i]);
            Add(marks[nrs[i]+2], m/divs[i]);
        fi;
    end,

      Ignore,

      function(i, j)
        if divs[i] mod (2*divs[j]) = 0 then
            Add(subs[nrs[i]], nrs[j]);
            Append(subs[nrs[i]+1], [nrs[j], nrs[j]+1]);
            Append(subs[nrs[i]+2], [nrs[j], nrs[j]+2]);
            Add(marks[nrs[i]], m/divs[i]);
            Append(marks[nrs[i]+1], [m/divs[i], 2]);
            Append(marks[nrs[i]+2], [m/divs[i], 2]);
        elif divs[i] mod divs[j] = 0 then
            Add(subs[nrs[i]], nrs[j]);
            Add(subs[nrs[i]+1], nrs[j]+1);
            Add(subs[nrs[i]+2], nrs[j]+2);
            Add(marks[nrs[i]], m/divs[i]);
            Add(marks[nrs[i]+1], 2);
            Add(marks[nrs[i]+2], 2);
        fi;
    end]];

    marks:= [];
    subs:= [];
    name:= [];

    type:= [];
    nrs:= [];  pt:= 1;
    for d in divs do
        Add(nrs, pt);  pt:= pt+1;
        ord:= String(d);
        if n mod d = 0 then
            if d mod 2 = 0 then
                Add(type, 3);  pt:= pt+2;
                Add(name, ord);
                Add(name, Concatenation("D_{", ord, "}a"));
                Add(name, Concatenation("D_{", ord, "}b"));
            else
                Add(type, 1);
                Add(name, ord);
            fi;
        else
            Add(type, 2);
            Add(name, Concatenation("D_{", ord, "}"));
        fi;
    od;

    for i in [1..Length(divs)] do
        subs[nrs[i]]:= [];
        marks[nrs[i]]:= [];
        if type[i] = 3 then
            subs[nrs[i]+1]:= [];  subs[nrs[i]+2]:= [];
            marks[nrs[i]+1]:= [];  marks[nrs[i]+2]:= [];
        fi;
        for j in [1..i] do
            construct[type[i]][type[j]](i, j);
        od;
    od;

    nametom:=Concatenation("dihedral group( ",String(m)," )" );
    tom:=ConvertToTableOfMarks(TOM([nametom, subs,marks,0,0,0,0,0,0]));   
    SetClassNamesTom(tom,name);

    return tom;
end);

#############################################################################
##
##  3) Methods and functions dealing with tables of marks
##
#############################################################################
##
#M  LatticeSubroups( <G> )
##
##  method for a group with table of marks
##  method for a cyclic group
##
##  LatticeSubgroupsByTom( <G> )
##
InstallGlobalFunction(LatticeSubgroupsByTom,
function( G )
    local marks, i, lattice, classes, tom;

    # get the classes
    tom:=TableOfMarksGroup( G );
    classes:= List( [1..Length(OrdersTom( tom))], x-> ConjugacyClassSubgroups
                      (G, RepresentativeTom( tom , x)));
    
    marks:=MarksTom(tom);
    for i in [1..Length(classes)] do
         SetSize(classes[i],marks[i][1]/marks[i][Length(marks[i])]);
    od;

    # create the lattice
    lattice:=Objectify(NewType(FamilyObj(classes),IsLatticeSubgroupsRep),
                       rec());
    lattice!.conjugacyClassesSubgroups:=classes;
    lattice!.group     :=G;

    # return the lattice
    return lattice;
end);

InstallMethod(LatticeSubgroups,"method for a group with table of marks",true,
      [IsGroup and HasTableOfMarksGroup],10,LatticeSubgroupsByTom);

InstallMethod(LatticeSubgroups,"method for a cyclic group",true,
       [IsGroup and IsCyclic],0,
function(G)
     TableOfMarksGroup(G);
     return LatticeSubgroupsByTom(G);
end);

    

#############################################################################
##
#M ViewObj( < tom > ) .  .  .  .  .  .  .  .  .  .  . print a table of marks
#M PrintObj( <tom> )
##
InstallMethod(PrintObj,true,[IsTableOfMarks],0,
function(tom)
Print("< table of marks object >");
end);

InstallMethod(ViewObj,true,[IsTableOfMarks and HasSubsTom],0,
function(tom)
    local size, numberccclasses, numbersubgroups;
    if HasMarksTom(tom) or HasNrSubsTom(tom) then
        numberccclasses:=Length(OrdersTom(tom));
        size:=OrdersTom(tom)[numberccclasses];
        numbersubgroups:=Sum(NrSubsTom(tom)[numberccclasses]);

        Print("TableOfMarks(# group of size ", size,", ");
        Print(numberccclasses," classes, "
            ,numbersubgroups, " subgroups)");
    else 
       TryNextMethod();
    fi;
end);

InstallMethod(ViewObj, true, [IsTableOfMarks and HasIdentifierOfTom],2,
function(tom)
    local size, numberccclasses, numbersubgroups;

    numberccclasses:=Length(OrdersTom(tom));
    size:=OrdersTom(tom)[numberccclasses];
    numbersubgroups:=Sum(NrSubsTom(tom)[numberccclasses]);
    Print("TableOfMarks( \"",IdentifierOfTom(tom),"\" ,# "); 

    Print(numberccclasses," classes, ",numbersubgroups,
          " subgroups)");
end);

InstallMethod(PrintObj,true,[IsTableOfMarks and HasGroupOfTom],1,
function(tom)    
    Print("TableOfMarks( ",GroupOfTom(tom)," )\n");
end);

InstallMethod(PrintObj,true, [IsTableOfMarks and IsLibTomRep],0,
function(tom)
Print("TableOfMarks( \"",IdentifierOfTom(tom),"\" )\n");
end);

#############################################################################
##
#M  Display( < tom > ) .  .  .  .  .  .  .  .  .  .  display a table of marks
#M  Display( < tom>, < options > )
##
##  in the first form the whole table of marks is diplayed
##
##  in the second form a record with several options may be specified:
##  
##  classes: a list of classes. Only these classes are displayed,
##  form:    if one specify "subgroups" here the number of subgroups are 
##           displayed instead of the marks
##           if one specify "supergroups" the number of supergroups are 
##           displayed instead of the marks
##
InstallMethod(Display,"display without options",true, [IsTableOfMarks],0,
              function(tom)  Display(tom,rec()); end );

InstallOtherMethod(Display,"display with options",true,
                   [IsTableOfMarks,IsRecord],0,
function(tom,options)
    local i, j, k, l, pr1, ll, lk, von, bis, pos, llength, pr, vals, subs,
          classes, lc, ci, wt;

    #  default values.
    subs:= SubsTom(tom);
    ll:= Length(subs);
    classes:= [1..ll];
    vals:= MarksTom(tom);

    #  adjust parameters.
    if IsBound(options.classes) and IsList(options.classes) then
        classes:= options.classes;
    fi;
    if IsBound(options.form) then
        if options.form = "supergroups" then
            vals:= ShallowCopy(vals);
            wt:= WeightsTom(tom);
            for i in [1..ll] do
                vals[i]:= vals[i]/wt[i];
            od;
        elif options.form = "subgroups" then
            vals:= NrSubsTom(tom);
        fi;
    fi;

    llength:= SizeScreen()[1];
    von:= 1;
    pr1:= LogInt(ll, 10);

    #  determine column width.
    pr:= List([1..ll], x->0);
    for i in [1..ll] do
        for j in [1..Length(subs[i])] do
            pr[subs[i][j]]:= Maximum(pr[subs[i][j]], LogInt(vals[i][j], 10));
        od;
    od;

    lc:= Length(classes);
    while von <= lc do
        bis:= von;

        #  how many columns on this page?
        lk:= pr1 + 5 + pr[classes[von]];
        while bis < lc and lk+2+pr[classes[bis+1]] <= llength do
            bis:= bis+1;
            lk:= lk+2+pr[classes[bis]];
        od;

        #  loop over rows.
        for i in [von..lc] do
            ci:= classes[i];
            for k in [1 .. pr1-LogInt(ci, 10)] do
                Print(" ");
            od;
            Print(ci, ": ");

            #  loop over columns.
            for j in [von .. Minimum(i, bis)] do
                pos:= Position(subs[ci], classes[j]);
                if pos <> fail and pos > 0 then
                    l:= LogInt(vals[ci][pos], 10)-1;
                else
                    l:= -1;
                fi;
                for k in [1 .. pr[classes[j]] - l] do
                    Print(" ");
                od;
                if pos = fail then
                    Print(".\c");
                else
                    Print(vals[ci][pos], "\c");
                fi;
            od;
            Print("\n");
        od;

        von:= bis+1;
        Print("\n");
    od;

end);

#############################################################################
##
#M  NrSubsTom( <tom> ) . . . . . . . . . . . . . . . . .numbers of subgroups.
##
##  'NrSubs' also has to compute the orders and lengths from the marks.
##
##  'NrSubsTom' returns the list of lists of numbers  of subgroups of the  
##  table of marks <tom>.  They will be computed from the attributes 
##  'MarksTom' and 'SubsTom'.
##
InstallMethod(NrSubsTom,true,[IsTableOfMarks],0,
function(tom)
    local i, j, nrSubs, subs, marks, order, length, index;

    # initialize
    order:= [];
    length:= [];
    nrSubs:= [];
    subs:= SubsTom(tom);
    marks:= MarksTom(tom);

    # compute the numbers row by row
    for i in [1..Length(subs)] do
        index:= marks[i][Position(subs[i], 1)];
        order[i]:= marks[1][1] / index;
        length[i]:= index / marks[i][Position(subs[i], i)];
        nrSubs[i]:= [];

        for j in [1..Length(subs[i])] do
            nrSubs[i][j]:= marks[i][j] * length[subs[i][j]] / index;
            if not IsInt(nrSubs[i][j]) or nrSubs[i][j] < 0 then
                Print("#W  orbit length ",i, ", ",j, ": ", 
                                          nrSubs[i][j], ".\n");
            fi;
        od;

    od;

    # set the additional attributes
    SetLengthsTom(tom,length);
    SetOrdersTom(tom,order);

    return nrSubs;

end);

#############################################################################
##
#M  OrdersTom( < tom > )  .  .  .  .  .    .  .  .  .  .   order of subgroups
##
InstallMethod(OrdersTom,true,[IsTableOfMarks],0,
function(tom)

    NrSubsTom(tom);
    return tom!.OrdersTom;
end);

#############################################################################
##
#M LengthsTom( < tom > )  .  .  .  .  . .  .  length of the conjugacy classes
##
InstallMethod(LengthsTom,true,[IsTableOfMarks],0,
function(tom)
    local nrSubs;
    nrSubs:=NrSubsTom(tom);
    return nrSubs[Length(nrSubs)];
end);

#############################################################################
##
#M  MarksTom( <tom> ) . . . . . . . . . . . . . . . . . . . . . .  the marks.
##
##  'MarksTom' returns the list of lists of marks  of the table of  marks 
##  <tom>. It will be computed from the attributes 'NrSubsTom' and 
##  'OrdersTom'.
##
InstallMethod(MarksTom,true,[IsTableOfMarks],0,
function(tom)
    local i, j, ll, order, length, nrSubs, subs, marks, ord;

    # get the attributes and initialize
    order:=OrdersTom(tom);
    subs:=SubsTom(tom);
    length:=LengthsTom(tom);
    nrSubs:=NrSubsTom(tom);
    ll:=Length(order);
    ord:=order[ll];
    marks:=[[ord]];

    # compute the marks
    for i in [2..ll] do
        marks[i]:= [ord / order[i]];
        for j in [2..Length(subs[i])] do
            marks[i][j]:= nrSubs[i][j] * marks[i][1] / length[subs[i][j]];
            if not IsInt(marks[i][j]) or marks[i][j] < 0 then
                Print("#W  orbit length ", i, ", ", j, ": ", 
                                                   marks[i][j], ".\n");
            fi;
        od;
    od;

    return marks;
end);

#############################################################################
##
#M  NormalizersTom( <tom> ) . . . . . . . . . . . . determine normalizer.
##
##  'NormalizersTom' tries to find the normalizer  of all subgroups <u>.
##  It will return the list of those subgroups which have the  right size
##  and contain  the subgroup <u> and all subgroups which clearly contain
##  <u> as a normal  subgroup. Afterwards it tries to improve the result
##  by using previous results and the attribute 'DerivedSubgroupsTom'
##  if present.
##  If the normalizer is uniquely  determined by these  conditions then 
##  only its address is returned.  The list must never be empty.

InstallMethod( NormalizersTom, " all normalizers", true, [IsTableOfMarks],0,
function(tom)
    local result, subs, order, nrsubs, length, ll, impr, d, der, bool, 
          NormalizerTom, sub, nn, nn1,  sub1, norm;


    # function for one normalizer
    NormalizerTom:=function(tom, sub)
        local nord, subs, order ,nrsubs, length, ll,res, i, nn;

        # get the attributes
        subs:=SubsTom(tom);
        order:=OrdersTom(tom);
        nrsubs:=NrSubsTom(tom);
        length:=LengthsTom(tom);
        ll:= Length(order);

        #  order of normalizer.
        nord:= order[ll] / length[sub];

        #  selfnormalizing.
        if nord = order[sub] then
            return sub;
        fi;
        #  normal.
        if length[sub] = 1 then
            return ll;
        fi;

        res:= [];
        for i in [sub+1..ll] do
            if order[i] = nord then
                Add(res, i);
            fi;
        od;

        #  the normalizer must contain <sub>.
        res:= Filtered(res, x-> (sub in subs[x]));

        if Length(res) = 1 then
            return res[1];
        fi;

        #  the normalizer must contain all subgroups which contain <u>
        #  as a normal subgroup, in particular those where <u> is of index 2
        #  and those which contain only one conjugate of <u>.
        nn:= [];
        for i in [sub+1..Maximum(res)] do
            if sub in subs[i] then
                if order[i] = 2 * order[sub] or
                   nrsubs[i][Position(subs[i], sub)] = 1 then
                    Add(nn, i);
                fi;
            fi;
        od;

        res:= Filtered(res, x-> IsSubset(subs[x], nn));

        #if one of the possible normalizers is abelian then we are done
        if HasComputedDerivedSubgroupsTom(tom) then
            for i in res do 
                if ComputedDerivedSubgroupsTom(tom)[i]=1 then
                    return i;
                fi;
            od;
        fi;

        if Length(res) = 1 then
            return res[1];
        fi;
        return res;
    end;# NormalizerTom

    # begin NormalizersTom 
    # get the attributes
    subs:=SubsTom(tom);
    order:=OrdersTom(tom);
    nrsubs:=NrSubsTom(tom);
    length:=LengthsTom(tom);
    ll:= Length(order);    
    result:=[];

    #loop over the subgroups 
    impr:=[];
    for sub in [1..ll] do
        norm:=NormalizerTom( tom , sub);
        Add(result, norm);
        if IsList( norm ) then
            Add(impr,sub);
        fi;
    od;

    #try to improve the result

    if HasComputedDerivedSubgroupsTom(tom) then
        d:=true;
        der:=DerivedSubgroupsTom(tom);
    fi;

    bool:=true;
    while bool do
        bool:=false;
        for sub in impr do
            #the normalizer must contain the normalizer of all sub-
            #groups which contain only one conjugate of u
            #and the normalizer of all subgroups <v> whose derived subgroup
            #is <u>
            nn:=[];
            for sub1 in [sub+1..ll-1] do
                if sub in subs[sub1]  and IsInt(result[sub1]) then
                    if nrsubs[sub1][Position(subs[sub1],sub)] = 1 then
                        Add(nn,result[sub1]);
                    elif d and der[sub1] = sub then
                        Add(nn,tom.normalizer[sub1]);
                    fi;
                fi;
            od;

            #the normalizer must be contained in the normalizer of all
            #the subgroups <v> of <u>, for which <u> contains only one 
            #conjugate of <v>
            nn1:=[];
            for sub1 in subs[sub] do
                if nrsubs[sub][Position(subs[sub],sub1)] = 1 and
                   IsInt(tom.normalizer[sub1]) then
                    Add(nn1,tom.normalizer[sub1]);
                fi;
            od;
            #the normalizer must be contained in the normalizer of the
            #derived subgroup of <u>
            if d and IsInt(der[sub]) and
               IsInt(result[der[sub]]) then
                Add(nn1, result[der[sub]]);
            fi;

            norm:=Filtered(result[sub],x->IsSubset(
                          subs[x],nn) and ForAll(nn1, y->x in subs[y]) );

            #if there was an improvement, try it again
            if Length(norm) < Length(result[sub]) then
                bool:=true;
            fi;

            if Length(norm)=1 then
                result[sub]:=norm[1];
            else
                result[sub]:=norm;
            fi;
        od;
    od;

    return result;
end);

#############################################################################
##
#M  FusionsTom( <tom> ) 
##  
##  dummy method
InstallMethod(FusionsTom,true,[IsTableOfMarks],0,x->[]);

#############################################################################
##
#M  WeightsTom( < tom> ) .  .  .  .  .  .  .  .  .  .  .  .  .  .  .  weights
##
##  diagonal of the table of marks <tom>
InstallMethod(WeightsTom,true,[IsTableOfMarks],0,
function(tom)
    local i, wgt, subs, marks;

    marks:= MarksTom(tom);
    subs:= SubsTom(tom);

    wgt:= [];
    for i in [1..Length(subs)] do
        wgt[i]:= marks[i][Position(subs[i], i)];
    od;

    return wgt;
end);

#############################################################################
##
#M  ContainedTom( <tom>, <sub1>, <sub2> )
##
##  How many subgroups of class <sub1> lie in one subgroup of class <sub2>?
##
InstallMethod( ContainedTom, true, [IsTableOfMarks, IsPosInt,
        IsPosInt],0,
function(tom,sub1,sub2)

    if sub1 in SubsTom(tom)[sub2] then
        return NrSubsTom(tom)[sub2][Position(SubsTom(tom)[sub2],sub1)] ;
    else
        return 0;
    fi;
    
end);    

#############################################################################
##
#M  ContainingTom( <tom>, <sub1>, <sub2> )
##
##  How many subgroups of class <sub2> contain one subgroup of class <sub1>?
##
InstallMethod( ContainingTom, true, [IsTableOfMarks, IsPosInt,
        IsPosInt],0,
function(tom,sub1,sub2)

    if sub1 in SubsTom(tom)[sub2] then
        return MarksTom(tom)[sub2][Position(SubsTom(tom)[sub2],sub1)]/
               MarksTom(tom)[sub2][Length(MarksTom(tom)[sub2])];
    else
        return 0;
    fi;
    
        
end);

#############################################################################
##
#M  MaximalSubgroupsTom( <tom> )
#M  MaximalSubgroupsTom( <tom>, <sub>)
##
##  In the first form MaximalSubgroupsTom returns the maximal subgroups of
##  the whole group together with the lengths of their conjugagcy classes.
##  In the second form those of the subgroup <sub>.
##
InstallMethod( MaximalSubgroupsTom,true, [IsTableOfMarks],0,
   function(tom) return MaximalSubgroupsTom(tom, Length(SubsTom(tom))); end);
        
InstallOtherMethod( MaximalSubgroupsTom, true, [IsTableOfMarks, 
           IsPosInt], 0,
function(tom, sub)
    local subs1, s, max, subs;

    subs1:=SubsTom(tom);
    subs:= Difference(subs1[sub], [sub]);
    max:= [];

    while subs <> [] do
        s:= Maximum(subs);
        Add(max, Position(subs1[sub], s));
        SubtractSet(subs, subs1[s]);
    od;

    return [subs1[sub]{max}, NrSubsTom(tom)[sub]{max}];

end);

#############################################################################
##
#M  MinimalSupergroupsTom( <tom>, <sub>)
##
##  'MinimalSupergroupsTom' calculates the minaml supergroups of <sub>
##   together with the lengths of their conjugacy classes of subgroups
InstallMethod( MinimalSupergroupsTom, true, [IsTableOfMarks,
        IsPosInt],0,
function(tom, sub)        
    local subs, i, pos, sups, nrSups;

    #  trivial case.
    subs:=SubsTom(tom);
    if sub = Length(subs) then 
        return [[], []]; 
    fi;

    sups:= [];
    nrSups:= [];

    #  here we assume that <tom> is triangular.  
    for i in [sub+1..Length(subs)] do
        pos:= Position(subs[i], sub);
        if pos <> fail and Intersection(sups, subs[i]) = [] then
            Add(sups, i);
            if sub = 1 then
                Add(nrSups, LengthsTom(tom)[i]);
            else
                Add(nrSups, LengthsTom(tom)[i] * NrSubsTom(tom)[i][pos] /
                    LengthsTom(tom)[sub]);
            fi;
        fi;
    od;

    return [sups, nrSups];

end);

#############################################################################
##
#M  MatTom( <tom> ) .  .  .  .  convert compressed table of marks into matrix
##
InstallMethod(MatTom,true,[IsTableOfMarks],0,
function(tom)
    local i, j, subs, marks, ll, res;

    marks:= MarksTom(tom);
    subs:= SubsTom(tom);
    ll:= [1..Length(subs)];

    res:= [];
    for i in ll do
        res[i]:= ListWithIdenticalEntries(Length(ll),0);
        for j in [1..Length(subs[i])] do
            res[i][subs[i][j]]:= marks[i][j];
        od;
    od;

    return res;

end);

#############################################################################
##
#M  DecomposedFixedPointVectorTom( <tom>, <fix> )   . . . .  decompose marks.
##
##  'DecomposedFixedPointVectorTom' takes  a  fix  of fixed  point numbers  
##  and returns the decomposition into rows of the table of marks.
##
InstallMethod(DecomposedFixedPointVectorTom,true,[IsTableOfMarks,IsList],0,
function(tom, fixpointvector)

    local fix, i, j, dec, marks, subs, working, oo;

    # get the attributes
    marks:= MarksTom(tom);
    subs:= SubsTom(tom);
    oo:= marks[1][1];
    fix:=ShallowCopy(fixpointvector);
  
    dec:= ListWithIdenticalEntries(Length(subs),0);
    working:= true;
    i:= Length(fix);
    # here we assume that <tom> is triangular
    while working do
        while i>0 and fix[i] = 0 do
            i:= i-1;
        od;
        if i = 0 then
            working:= false;
        else
            dec[i]:= fix[i]/marks[i][Length(marks[i])];
            for j in [1..Length(subs[i])] do
                fix[subs[i][j]]:= fix[subs[i][j]] - dec[i] * marks[i][j];
            od;
        fi;
    od;
    
    # remove trailing zeros
    i:=Length(dec);
    while i> 0 and dec[i] = 0  do
       i:=i-1;
    od;
           
    return dec{[1..i]};

end);

#############################################################################
##
#M  TestTom( <tom> )  . . . . . . . . . consistency check for table of marks.
##
##  The tensor product of two rows of the table of marks decomposes into
##  rows of  the table of marks with integers as coefficients.
##
TestRow := function(tom, n)

    local i, j, k, a, b, dec, test, marks, subs;

    test:= true;
    marks:= MarksTom(tom);
    subs:= SubsTom(tom);


    a:= [];

    # decompress the nth line of <tom>
    for i in [1..Length(subs[n])] do
        a[subs[n][i]]:= marks[n][i];
    od;


    for i in Reversed([1..n]) do
        # build the tensor product with row <i>
        b:= [];
        for j in [1..Length(subs[i])] do
            k:= subs[i][j];
            if IsBound(a[k]) then
                b[k]:= a[k]*marks[i][j];
            fi;
        od;
        for j in [1..Length(b)] do
            if not IsBound(b[j]) then
                b[j]:= 0;
            fi;
        od;

        # deompose and test the tensor product
        dec:= DecomposedFixedPointVectorTom(tom, b);
        if ForAny(Set(dec), x-> not IsInt(x) or (x < 0)) then
            Info(InfoTom,2, n, ".", i, " = ", dec);
            test:= false;
        fi;
    od;

    return test;

end;

InstallMethod(TestTom,"decomposition test",true,[IsTableOfMarks],0,
function(tom)
    local i, test;

    test:= true;

    for i in [1..Length(SubsTom(tom))] do
        if not TestRow(tom, i) then
            return false;
        fi;
    od;

    return test;

end);

#############################################################################
##
#M  IntersectionsTom( <tom>, <a>, <b> ) . . . . . intersections of subgroups.
##
##  The intersections of two conjugacy classes of subgroups are determined by
##  the decomposition of the tensor product of their lines of marks.
##
InstallMethod(IntersectionsTom,true,[IsTableOfMarks,IsPosInt,
              IsPosInt],0,
function(tom,a,b)
    local i, j, k, h, line, dec, marks, subs;

    # get the attributes and initialize
    marks:= MarksTom(tom);
    subs:= SubsTom(tom);
    h:= [];   line:= [];

    # decompress row <a>
    for i in [1..Length(subs[a])] do
        h[subs[a][i]]:= marks[a][i];
    od;

    # build the tensor product or row <a> and <b>
    for j in [1..Length(subs[b])] do
        k:= subs[b][j];
        if IsBound(h[k]) then
            line[k]:= h[k]*marks[b][j];
        fi;
    od;
    for j in [1..Length(line)] do
        if not IsBound(line[j]) then
            line[j]:= 0;
        fi;
    od;

    # decompose the tensor product
    dec:= DecomposedFixedPointVectorTom(tom, line);

    return Filtered([1..Length(dec)],x->dec[x] <> 0);

end);

#############################################################################
##
#M  IsCyclicTom( <tom>, <sub> ) . . . . . check whether a subgroup is cyclic.
##
##  A subgroup is cyclic if and only if it has exactly one subgroup for
##  each divisor of its order.
##
InstallMethod(IsCyclicTom,true,[IsTableOfMarks,IsPosInt],0,
function(tom, sub)
    return ForAll(NrSubsTom(tom)[sub], x->x = 1);
end);

#############################################################################
##
#M  CyclicExtensionsTom( <tom>, <p> ) . . . . . . . . . .  cyclic extensions.
##
##  According to Dress two columns of a table of  marks mod <p> are equal  if
##  and  only  if  the  corresponding subgroups are  connected by a  chain of
##  normal  extensions  of  order  <p>.   'CyclicExtensionsTom'  returns  the
##  classes of this equivalence relation.
##
##  This  information is  not used by  'NormalizersTom' although it might give
##  additional retrictions in the search of normalizers.
##
InstallOtherMethod(CyclicExtensionsTom,"method for all primes",true,
               [IsTableOfMarks],0,
function(tom)
    local primes;
    primes:=Set(Factors(MarksTom(tom)[1][1]));
    return CyclicExtensionsTom(tom,primes);
end);

InstallOtherMethod(CyclicExtensionsTom, "method for one prime", true,
                    [IsTableOfMarks,IsPosInt],0,
function(tom,p)
     return CyclicExtensionsTom(tom,[p]);
end);

InstallMethod(CyclicExtensionsTom,"method for a list of primes",
                    true,[IsTableOfMarks,IsList],0,
function(tom,list)
     local pos, computed, primes, factors, value;

     if not ForAll(list,  IsPrimeInt) then
          Error("the second argument must be a list of primes");
     fi;
     
     factors:=Set(Factors(MarksTom(tom)[1][1]));
     primes:=Filtered(list,x -> x in factors);
     if primes = [] then
          return List([1..Length(MarksTom(tom))],x->[x]);
     fi;

     computed:=ComputedCyclicExtensionsTom(tom);
     pos:=Position(computed,primes);
     if IsInt(pos) then
         return computed[pos+1];
     fi;

     value:=CyclicExtensionsTomOp(tom,primes);
     Add(computed,primes);
     Add(computed,value);
     
     return value;
end);
     
InstallOtherMethod(CyclicExtensionsTomOp," method for one prime", 
                   true,[IsTableOfMarks,IsPosInt],0,
function(tom, p)
    local i, j, h, ll, done, classes, pos, val, marks, subs;

    # get the attributes and initialize
    marks:= MarksTom(tom);
    subs:= SubsTom(tom);
    ll:= Length(subs);

    pos:= [];
    val:= [];

    #  take marks mod <p> and transpose.
    for i in [1..ll] do
        pos[i]:= [];
        val[i]:= [];
        for j in [1..Length(subs[i])] do
            h:= marks[i][j] mod p;
            if h <> 0 then
                Add(pos[subs[i][j]], i);
                Add(val[subs[i][j]], h);
            fi;
        od;
    od;

    #  form classes
    classes:= [];
    for i in [1..ll] do
        j:= 1;
        done:= false;
        while not done and j < i do
            if pos[i] = pos[j] and val[i] = val[j] then
                Add(classes[j], i);
                done:= true;
            fi;
            j:= j+1;
        od;
        if not done then
            classes[i]:= [i];
        fi;
    od;

    return Set(classes);

end);

InstallMethod(CyclicExtensionsTomOp,"method for a list of primes",
                true,[IsTableOfMarks,IsList],0,
function(tom,primes)
    local p, ext, c, i, comp, classes;

       if Length(primes)  = 1 then
           return CyclicExtensionsTomOp(tom,primes[1]);
       fi;

       classes:= [1..Length(SubsTom(tom))];
       for p in primes do
           ext:= CyclicExtensionsTom(tom, p);
           for c in ext do
               for i in c do
                   classes[i]:= classes[c[1]];
               od;
           od;
       od;

       for i in [1..Length(classes)] do
           classes[i]:= classes[classes[i]];
       od;

       comp:=Set(classes);
       ext:=List(comp,x->Filtered([1..Length(classes)],y->classes[y] = x));
      
       return ext;
end);

#############################################################################
##
#M  IdempotentsTom( <tom> ) . . . . . . . . . . . . . . . . . .  idempotents.
##
##  'IdempotentsTom' returns the list of idempotents of the integral Burnside
##  ring described  by the table of  marks  <tom>.   According to Dress these
##  idempotents correspond to the  classes of perfect subgroups and each such
##  idempotent is the  characteristic function  of  all those subgroups which
##  arise by cyclic extension from the corresponding perfect subgroup.
##
InstallMethod(IdempotentsTom, true, [IsTableOfMarks], 0,
function(tom)

    local dec, subs, value, ext, ll, result,i, idem;

    ext:=CyclicExtensionsTom(tom);
    ll:=Length(SubsTom(tom));
    result:=rec(primidems:=[],fixpointvectors:=[]);
    
    for i in [1..Length(ext)] do
        idem:=ListWithIdenticalEntries(ll,0);
        idem{ext[i]}:=List([1..Length(ext[i])],x->1);
        dec:=DecomposedFixedPointVectorTom(tom,idem);
        subs:=Filtered([1..ll],x->idem[x] = 1);
        value:=ListWithIdenticalEntries(Length(subs),1);
        Add(result.fixpointvectors,rec(subs:=subs,value:=value));
        subs:=Filtered([1..Length(dec)],x->dec[x] <> 0);
        value:=dec{subs};
        Add(result.primidems,rec(subs:=subs,value:=value));
    od;

    return result;
end);

#############################################################################
##
#M  IsAbelianTom( <tom> )
##
##  If the group is known then IsAbelianTom delegates the task to the group.
##  Otherwise a group is abelian if all subgroups are normal and it contains
##  no Q8
##
InstallOtherMethod(IsAbelianTom, true, [IsTableOfMarks], 0,
function(tom)
    local marks, subs, nrSubs, order, result, sub, number, sub1;

    result:=true;
    marks:=MarksTom(tom);
    order:=OrdersTom(tom);
    subs:=SubsTom(tom);
    nrSubs:=NrSubsTom(tom);

    #all subgroups must be normal
    for sub in [1..Length(order)] do
        if tom.marks[sub][1]<>tom.marks[sub][Length(tom.marks[sub])] then
            return false;
        fi;
    od;
    #test the subgroups of order 8
    for sub in [2..Length(order)] do
        if order[sub]=8 then
            #count the number of subgroups of sub
            number:=0;
            for sub1 in subs[sub] do
                number:=number+nrSubs[sub][Position(subs[sub],sub1)];
            od;
            #q8 is determined by its number of subgroups
            if number=6 then 
                return false;
            fi;
        fi; 
    od;
    return result;
end);    

InstallMethod(IsAbelianTom, true, [IsTableOfMarks and 
               HasComputedDerivedSubgroupsTom, IsPosInt], 1000,
function(tom, sub)
    return DerivedSubgroupsTom(tom)[sub] = 1;
end);

InstallMethod(IsAbelianTom, true, [IsTableOfMarks, IsPosInt], 10, 
function(tom, sub)
    local der;
    der:=DerivedSubgroupTom(tom, sub);
    if IsInt(der) then
         return der = 1;
    elif not 1 in der then
       return false;
    else 
        TryNextMethod();
    fi;
end);

InstallMethod(IsAbelianTom, true, [IsTableOfMarks and 
                   HasIsTableOfMarksWithGens, IsPosInt],0,
function(tom, sub)
    return IsAbelian(RepresentativeTom(tom, sub));
end);




#############################################################################
##
#M  FactorGroupTom( <tom>, <nor>) .  .  .  .  .  .  .  .  .  .  .Factor Group
##
##  'FactorGroupTom' returns the table of marks of the factor group G/N, by
##   selecting the appropriate columns and rows
##
InstallMethod( FactorGroupTom, true, [IsTableOfMarks ,IsPosInt],0,
function(tom,nor)
    local marks, subs, sub, pos, pos1, subsf, marksf, facmarks, facsubs, 
          members, hom, facgens, facpos, facnorms, facgroup, elm, result;

    marks:=MarksTom(tom);
    subs:=SubsTom(tom);
    if marks[nor][1]<>marks[nor][Length(marks[nor])] then
        Error("nor is not normal");
    fi;
    facsubs:=[];
    facmarks:=[];
    
    #collect the members of the factorgroup
    members:=[];
    for sub in [nor..Length(marks)] do
        if nor in subs[sub] then
            Add(members,sub);
        fi;
    od;

    #collect the marks of the factorgroup from the marks of the group
    for sub in members do
        pos:=Position(subs[sub],nor);
        subsf:=[1];
        marksf:=[marks[sub][pos]];
        for elm  in [pos+1..Length(subs[sub])] do
            pos1:=Position(members,subs[sub][elm]); 
            if IsInt(pos1) then
                Add(subsf,pos1);
                Add(marksf,marks[sub][elm]);
            fi;
        od;
        Add(facsubs,subsf);
        Add(facmarks,marksf);
    od;

    #  collect some additional information
    facgroup:=0;
    facnorms:=0;
    facgens:=0;
    facpos:=0;

    if HasNormalizersTom(tom) then
       facnorms:=List(NormalizersTom(tom){members}, x->Position(members,x));
    fi;
    
    if HasIsTableOfMarksWithGens(tom) then
       hom:=NaturalHomomorphismByNormalSubgroup(RepresentativeTom(tom),
                            RepresentativeTom(tom,nor));
       facgroup:=ImagesSource(hom);

       #  collect the generators
       subs:=List(members,x->GeneratorsOfGroup(RepresentativeTom(tom,x)));
       subs:=List(subs,x->List(x,y->Image(hom,y)));
       subs:=List(subs,x->Filtered(x,y->y<> One(facgroup)));
       facgens:=Union(subs);
 
       # compute the positions
       facpos:= [];
       for sub in subs do
           pos:= [];
           for elm in sub do
                Add(pos, Position(facgens, elm));
           od;
           Add(facpos, pos);
       od;

   fi;

   # make the table
   result:=ConvertToTableOfMarks(TOM([0, facsubs, facmarks, 0, 0, facnorms,
                    0, facgroup, 0,facgens,facpos]));
   if facgroup <> 0 then
       SetTableOfMarksGroup(GroupOfTom(result),result);
   fi;
   return result;

end); 


#############################################################################
##
#M  IsPerfectTom( <tom> )  
##
##  A finite group is perfect if and only if it has no normal subgroup of 
##  prime  index. This is tested here.
##  
##  If <tom> knows its underlying group the task is delegated to th group.
InstallOtherMethod(IsPerfectTom,true,[IsTableOfMarks],0,
        tom -> IsPerfectTom(tom,Length(SubsTom(tom))));

InstallMethod( IsPerfectTom, true, [IsTableOfMarks and 
            HasComputedDerivedSubgroupsTom, IsPosInt], 0, 
function (tom, sub)
    return DerivedSubgroupsTom(tom)[sub] = sub;
end);

InstallMethod(IsPerfectTom, true, [IsTableOfMarks,IsPosInt],0,
function(tom,sub)
    local ext, pos;
    ext:=CyclicExtensionsTom(tom);
    pos:=PositionProperty(ext,x-> sub in x);
    return sub = Minimum(ext[pos]);
end);


#############################################################################
##
#M  MoebiusTom( <tom> ) . . . . . . . . . . . . . . . . . . moebius function.
##
##  'MoebiusTom' computes the Moebius values both of the subgroup  lattice of
##  the group with tabel of marks <tom> and of the poset of conjugacy classes
##  of subgroups.  It returns a record where the component 'mu'  contains the
##  Moebius  values  of the subgroup lattice  and the component 'nu' contains
##  the Moebius values of the poset.  Moreover  according to a  conjecture of
##  Isaacs et  al. the values on the poset of conjugacy classes  are  derived
##  from  those  of  the subgroup  lattice.   These  theoretical  values  are
##  returned  in the  component  'ex'.  The numbers of those  subgroups where
##  the  theoretical value does not coincide with the actual value are 
##  returned in the component 'hyp'.
##
InstallMethod( MoebiusTom, true, [IsTableOfMarks], 0,
function(tom)
    local i, j, mline, nline, ll, mdec, ndec, expec, done, no, comsec,
          order, subs, nrsubs, length;

    nrsubs:= NrSubsTom(tom);
    subs:= SubsTom(tom);
    length:= LengthsTom(tom);
    order:=OrdersTom(tom);
    mline:= List(subs, x-> 0);
    nline:= List(subs, x-> 0);
    ll:= Length(mline);
    mline[ll]:= 1;
    nline[ll]:= 1;

    # decompose mline with tom
    # decompose nline w.r.t. incidence
    mdec:= [];
    done:= false;
    i:= Length(mline);
    while not done do
        while i>0 and mline[i] = 0 do
            i:= i-1;
        od;
        if i = 0 then
            done:= true;
        else
            mdec[i]:= mline[i];
            for j in [1..Length(subs[i])] do
                mline[subs[i][j]]:= mline[subs[i][j]] - mdec[i]*nrsubs[i][j];
            od;
            mdec[i]:= mdec[i] / length[i];
        fi;
    od;

    ndec:= [];
    done:= false;
    i:= Length(nline);
    while not done do
        while i>0 and nline[i] = 0 do
            i:= i-1;
        od;
        if i = 0 then
            done:= true;
        else
            ndec[i]:= nline[i];
            for j in subs[i] do
                nline[j]:= nline[j] - ndec[i];
            od;
        fi;
    od;

    #  determine intersections  with derived subgroup.
    expec:= [];
    if DerivedSubgroupTom(tom,Length(SubsTom(tom))) <> ll then
        comsec:= [];
        for i in [1..ll] do

            #  there is only one intersection with normal subgroups.
            comsec[i]:= Length(IntersectionsTom(tom, i, 
                                DerivedSubgroupTom(tom)));
        od;
        for i in [1..Length(ndec)] do
            if IsBound(ndec[i]) then
                no:= NormalizersTom( tom )[i];

                #  maybe the normalizer is not unique.
                if IsList(no) then
                    no:= List(no, x-> order[comsec[x]]);
                    no:= Set(no);
                    if Size(no) > 1 then
                        Info( InfoTom,2," Size of normalizer ", i,
                                                    "not unique.\n");
                    else
                        no:= no[1];
                    fi;
                else
                    no:= order[comsec[no]];
                fi;
                expec[i]:= ndec[i] * no / order[comsec[i]];
            fi;
        od;

        #  perfect groups.
    else
        for i in [1..Length(ndec)] do
            if IsBound(ndec[i]) then
                expec[i]:= ndec[i] * order[ll]/order[i]/length[i];
            fi;
        od;
    fi;

    return rec(mu:= mdec, nu:= ndec, ex:= expec,
               hyp:= Filtered([1..Length(expec)], function(x)
        if IsBound(expec[x]) then
            if IsBound(mdec[x]) then
                return expec[x] <> mdec[x];
            else return true; fi;
        else
            if IsBound(mdec[x]) then
                return true;
            else
                return false;
            fi;
        fi; 
    end));

end);

#############################################################################
##
#M  ClassTypesTom( <tom> )  . . . . . . . . . . . . . . . types of subgroups.
##
##  'ClassTypesTom'   distinguishes  isomorphism  types  of  the  classes  of
##  subgroups of the  table of marks <tom> as  far  as this is possible.  Two
##  subgroups  are  clearly  not  isomorphic  if  they have different orders.
##  Moreover isomorphic subgroups must contain  the  same number of subgroups
##  of each type.
##
##  The types are represented by  numbers.   'ClassTypesTom' returns  a  list
##  which contains for each class of subgroups its corresponding number.
##
InstallMethod( ClassTypesTom, true, [IsTableOfMarks], 0,
function(tom)
    local i, j, done, nrsubs, subs, order, type, struct, nrtypes;

    nrsubs:= NrSubsTom(tom);
    subs:= SubsTom(tom);
    order:=OrdersTom(tom);
    type:= [];
    struct:= [];
    nrtypes:= 1;

    for i in [1..Length(subs)] do

        #  determine type
        #  classify according to the number of subgroups
        struct[i]:= [];
        for j in [2..Length(subs[i])-1] do
            if IsBound(struct[i][type[subs[i][j]]]) then
                struct[i][type[subs[i][j]]]:=
                  struct[i][type[subs[i][j]]] + nrsubs[i][j];
            else
                struct[i][type[subs[i][j]]]:= nrsubs[i][j];
            fi;
        od;
        
        # consider the order
        for j in [1..i-1] do
            if order[j] = order[i] and struct[j] = struct[i] then
                type[i]:= type[j];
            fi;
        od;

        if not IsBound(type[i]) then
            type[i]:= nrtypes;
            nrtypes:= nrtypes+1;
        fi;
    od;

    return type;

end);

#############################################################################
##
#F  ClassNamesTom( <tom> )  . . . . . . . . . . . . . . . . . .  class names.
##
##  'ClassNamesTom'  constructs generic names  for  the  conjugacy classes of
##  subgroups of the table of marks <tom>.  Each name consists of three parts
##  and  has the following form, (o)_{t}l, where o indicates the order of the
##  subgroup, t is a number that distinguishes different types  of  subgroups
##  of  the  same  order  and  l is a letter  which distinguishes classes  of
##  subgroups  of the  same  type  and order.   The  type  of a  subgroup  is
##  determined by the numbers its subgroups of other types.  This is slightly
##  weaker than isomorphism.
##
##  The letter is omitted if  there  is only  one  class of subgroups of that
##  order and type and the type is omitted if there is only one class of that
##  order.  Moreover the braces  {}  around the type are  omitted if the type
##  number has  only  one  digit.  Cyclic subgroups will have  no parenthesis
##  around the order and no type number.
InstallMethod(ClassNamesTom, true, [IsTableOfMarks], 0,
function(tom)
    local i, c, classes, type, name, count, ord, alp, la;

    type:= ClassTypesTom(tom);

    #  form classes.
    classes:= List([1..Maximum(type)], x-> rec(elts:= []));
    for i in [1..Length(type)] do
        Add(classes[type[i]].elts, i);
    od;

    #  determine type.
    count:= rec();
    for i in [1..Length(classes)] do
        ord:= String(OrdersTom(tom)[classes[i].elts[1]]);
        if IsBound(count.(ord)) then
            count.(ord).nr:= count.(ord).nr + 1;
            if count.(ord).nr < 10 then
                classes[i].type:=
                  Concatenation("_", String(count.(ord).nr));
            else
                classes[i].type:=
                  Concatenation("_{", String(count.(ord).nr), "}");
            fi;
        else
            count.(ord):= rec(first:= classes[i], nr:= 1);
            classes[i].type:= "_1";
        fi;

        #  cyclic?
        if Set(NrSubsTom(tom)[classes[i].elts[1]]) = [1]
           and IsCyclicTom(tom, classes[i].elts[1]) then
            classes[i].order:= ord;
            classes[i].type:= "";
        else
            classes[i].order:= Concatenation("(", ord, ")");
        fi;

    od;

    #  omit unique types.
    for i in RecNames(count) do
        if count.(i).nr = 1 then
            count.(i).first.type:= "";
        fi;
    od;

    #  construct names.
    name:= [];
    alp:= ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
           "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
    la:= Length(alp);
    for c in classes do
        if Length(c.elts) = 1 then
            name[c.elts[1]]:= Concatenation(c.order, c.type);
        else
            for i in [1..Length(c.elts)] do
                if i <= la then
                    name[c.elts[i]]:= Concatenation(c.order,c.type,alp[i]);
                elif i <= la * (la+1) then
                    name[c.elts[i]]:= Concatenation(c.order, c.type,
                           alp[QuoInt(i-1, la)], alp[((i-1) mod la) +1]);

                else
                    Error("did not expect more than ", la * (la+1),
                          "classes of the same type");

                fi;
            od;
        fi;
    od;
    for c in name do
        CONV_STRING(c);
    od;
    return name;

end);

#############################################################################
##
#M  PermCharsTom( <fus>, <tom> )  . . . . . . . . . . permutation characters.
##  PermCharsTom( <tbl>, <tom> )
##
##  'PermCharsTom' reads the list of permutation characters from the table of
##  marks <tom>.  It therefore has to  know  the fusion map <fus> which sends
##  each conjugacy  class of elements  of the group to the conjugacy class of
##  subgroups that they generate.
##
##  In the first form 'PermCharsTom' uses the list <fus> as fusion map.
##  In the second form 'PermCharsTom' computes the fusion map from the
##  character table <tbl>.
InstallMethod(PermCharsTom,"with given fusion map",true,
              [IsList, IsTableOfMarks],0,
function(fus, tom )
    local pc, i, j, line, marks, subs;

    pc:= [];

    marks:= MarksTom(tom);
    subs:= SubsTom(tom);

    #  for every class of subgroups.
    for i in [1..Length(subs)] do

        #  initialize permutation character.
        line:= List(fus,x->0);

        #  extract the values.
        for j in [1..Length(fus)] do
            if fus[j] in subs[i] then
                line[j]:= marks[i][Position(subs[i], fus[j])];
            fi;
        od;
        pc[i]:= line;
    od;

    return pc;

end);

InstallOtherMethod(PermCharsTom,"FusionMap from Character Table",true,
                   [IsOrdinaryTable, IsTableOfMarks],0,
function(tbl, tom)
    local fus;
    fus:=FusionCharTableTom(tbl,tom);
    if ForAny(fus,IsList) then
         Error("the fusion <fus> map is not uniquely determined!\n");
    fi;
    return List(PermCharsTom(fus, tom), chi -> CharacterByValues(tbl, chi));
end);

#############################################################################
##
#M  FusionCharTableTom( <tbl>, <tom> )  . . . . . . . . . . . element fusion.
##
##  'FusionCharTableTom' determines  the fusion of the  classes  of  elements
##  from  the  character table <tbl> into classes of cyclic subgroups  on the
##  table of marks <tom>.
##
##  Three cases are handled differently.
##  1. The fusion is explicitly stored.  Then nothing has to be done.
##     This happens only if <tbl> and <tom> are both from the {\GAP} library.
##  2. <tbl> has a 'group' component that contains a 'tableOfMarks'
##     component equal to <tom>.  Then the conjugacy classes of the group are
##     used to compute the fusion.
##TM 2. not yet implemented
##  3. There is neither fusion nor group information available.
##     Then only necessary conditions can be checked.
##  

InstallMethod(FusionCharTableTom,true,[IsOrdinaryTable,IsTableOfMarks],0,
function(tbl,tom) 
    local perm, i, j, h, hh, fus, orders, cycs, ll, ind, p, pow, subs,
          marks, powermap;

    # If the fusion is stored on 'tbl' then take it.
    if IsBound( tbl!.tomfusion ) and IsLibTomRep(tom) then
        if IsBound(tom!.sortperm) then
            perm:=tom!.sortperm^-1;
        else
            perm:=();
        fi;
        if HasClassPermutation(tbl) then
            return Permuted( List(tbl!.tomfusion.map,x->x^perm),
                           ClassPermutation(tbl) );
        else
            return List(tbl!.tomfusion.map,x->x^perm);
        fi;
    fi;

#TM if <tbl> known its underlying group then this should be used if possible

    #  get orders of elements.
    orders:= OrdersClassRepresentatives(tbl);

    #  determine cyclic subgroups.
    marks:= MarksTom(tom);
    subs:= SubsTom(tom);
    ll:= Length(subs);
    cycs:= [];
    for i in [1..ll] do
        if OrdersTom(tom)[i] in orders and IsCyclicTom(tom, i) then
            Add(cycs, i);
        fi;
    od;

    #  collect candidates for each class.
    fus:= [];
    for i in [1..Length(orders)] do
        fus[i]:= [];
        for j in cycs do
            if orders[i] = OrdersTom(tom)[j] then
                Add(fus[i], j);
            fi;
        od;
        if Length(fus[i]) = 1 then
            fus[i]:= fus[i][1];
        fi;
    od;

    #  maybe the map is already unique.
    if IsVector(fus) then
        return fus;
    fi;

    #  check centralizers.
    for i in [1..Length(fus)] do
        if IsList(fus[i]) then
            h:= Length(ClassOrbitCharTable(tbl, i))          
                *SizesConjugacyClasses(tbl)[i] / Phi(orders[i]);
            hh:= [];
            for j in fus[i] do
                if LengthsTom(tom)[j] = h then
                    Add(hh, j);
                fi;
            od;
            if Length(hh) = 1 then
                fus[i]:= hh[1];
            else
                fus[i]:= hh;
            fi;
        fi;
    od;

    #  maybe the map is already unique.
    if IsVector(fus) then
        return fus;
    fi;

#T This may break up some symmetries,
#T so it is useful to remove all points from lists
#T that occur as unique images,
#T and to form the difference of images lists and other lists
#T (note that Galois symmetries are not broken!)
    #  check powermap against incidence.
    if HasComputedPowerMaps(tbl) then	
        powermap:=ComputedPowerMaps(tbl);
        for p in [2..Length(powermap)] do
            if IsBound(powermap[p]) and IsPrime(p) then
                pow:= [];
                for i in [1..Length(cycs)] do
                    h:= OrdersTom(tom)[cycs[i]] /
                                GcdInt(OrdersTom(tom)[cycs[i]], p);
                    hh:= [];
                    for j in cycs do
                        if OrdersTom(tom)[j] = h then
                            Add(hh, j);
                        fi;
                    od;
                    hh:= Intersection(hh, subs[cycs[i]]);
                    if Length(hh) = 1 then
                        pow[cycs[i]]:= hh[1];
                    else
                        Error("No unique cyclic subgroup found");
                    fi;
                od;

                CommutativeDiagram(fus, pow, powermap[p], fus);

                #  maybe the map is already unique.
                if IsVector(fus) then
                    return fus;
                fi;

            fi;
        od;

    fi;

#T better:
#T first compute the distr. of classes of tbl in to cyclic
#T subgroups, then we know in advance that we need a *bijection*.
#T Do not call ContainedMaps but a modification that does construct
#T only bijections!
    #  the fusion map must onto 'cycs'.
    fus:= ContainedMaps(fus);
    hh:= [];
    for i in fus do
        if Set(i) = cycs then
            Add(hh, i);
        fi;
    od;
    fus:= hh;

    #  check powermap against incidence.
    if IsBound( powermap ) then	

        for p in [2..Length(powermap)] do
            if IsBound(powermap[p]) then
                pow:= [];
                for i in [1..Length(cycs)] do
                    h:= OrdersTom(tom)[cycs[i]] / 
                               GcdInt(OrdersTom(tom)[cycs[i]], p);
                    hh:= [];
                    for j in cycs do
                        if OrdersTom(tom)[j] = h then
                            Add(hh, j);
                        fi;
                    od;
                    hh:= Intersection(hh, subs[cycs[i]]);
                    if Length(hh) = 1 then
                        pow[cycs[i]]:= hh[1];
                    else
                        Error("No unique cyclic subgroup found");
                    fi;
                od;

                hh:= [];
                for i in fus do
                    if CommutativeDiagram(i, pow, powermap[p], i) <> fail  
                            then
                        Add(hh, i);
                    fi;
                od;
                fus:= hh;

                #  maybe the map is already unique.
                if Length(fus) = 1 then
                    return fus[1];
                fi;

            fi;
        od;

    fi;

    return fus;

end);

#############################################################################
##
#F  TOM( arglist )
#F  ConvertToTableOfMarks( <record> )
##
##

InstallGlobalFunction(TOM,
function(arglist)
    local wordsfam, name, record, i, j, flat, names;

    # make the components
    record:=rec( IdentifierOfTom:=arglist[1],
                 SubsTom:=arglist[2],
                 MarksTom:=arglist[3],
                 NrSubsTom:=arglist[4],
                 OrdersTom:=arglist[5],
                 NormalizersTom:=arglist[6],
                 ComputedDerivedSubgroupsTom:=arglist[7],
                 GroupOfTom:=arglist[8],
                 WordsTom:=arglist[9]);

    if Length(arglist) = 11 then
        record.GeneratorsSubgroupsTom:=[arglist[10],arglist[11]];
    fi;

    if IsList(record.GroupOfTom) then
        record.GroupOfTom:=Group(record.GroupOfTom,record.GroupOfTom[1]^0);
    fi;

    #  remove superfluous things
    for name in RecNames(record) do
        if record.(name) = 0 then
            Unbind(record.(name));
        fi;
    od;
    
    return record;
end);

InstallGlobalFunction(ConvertToTableOfMarks,
function( record)
    local i, names;

    names:=RecNames(record);

    # make the object
    Objectify( NewType( TableOfMarksFamily, IsTableOfMarks and 
            IsAttributeStoringRep),record);

    # set the attributes
    for i in [1,3..Length(TableOfMarksComponents)-1] do
        if TableOfMarksComponents[i] in names then
            Setter(TableOfMarksComponents[i+1])(record,
                    record!.(TableOfMarksComponents[i]));
        fi;
    od;

    return record;
end);

#############################################################################
##
#M  EvaluateWordTom( <genslist>, <wordlist) > )
##
##  'EvaluateWordTom' evaluate the words stored on the table of marks.
##  Each word is in fact a wordlist <wordlist>. The evaluation looks like
##  a little straight line program:
##  First evaluate the first word of <wordlist> using <genslist>.
##  Then evaluate the second word using genslist and the previous result, 
##  then the third using <genslist> and the previous results and so on
##  The last word of <wordlist> gives the result.
##  
InstallGlobalFunction( EvaluateWordTom, 
function(genslist,wordlist)
    local numgens, fam, len, ws, i, result;

    fam:=FamilyObj(wordlist[1]);
    len:=Length(fam!.names);
    ws:=List([1..len],x->ObjByExtRep(fam,[x,1]));
    numgens:=Length(genslist);

    result:=[];
    for i in [1..Length(wordlist)] do
        result[i]:=MappedWord(wordlist[i],ws{[1..numgens+i-1]},
                           Concatenation(genslist,result{[1..i-1]}));
    od;
    return result[Length(result)];
end);

#############################################################################
##
#F  ConvWordsTom( <wordslist>, <numgens>, <fam> )
## 
##
InstallGlobalFunction(ConvWordsTom,
function(arg)
    local i, words, numgens, wordsfam, flat, j, names, result;
    
    words:=arg[1];
 
    # make a new family if necessary
    if Length(arg) = 2 then
        numgens:=arg[2];
        wordsfam:=NewFamily("TomWordsFamily",IsAssocWordWithInverse);
        flat:=Flat(words);
        if flat = [] then
            j:=0;
        else
            j:=MaximumList(flat{[1,3..Length(flat)-1]})-numgens;
        fi;
        names:=Concatenation(List([1..numgens],x->Concatenation("g",
                 String(x))), List([1..j],x->Concatenation("w",String(x))));
        StoreInfoFreeMagma(wordsfam, names, IsAssocWordWithInverse);
    else
        wordsfam:=arg[3];
    fi;
    
    # convert the words into internal representation
    result:=[];
    for i in [1..Length(words)] do
        if IsBound(words[i]) then
            result[i]:=List(words[i],x->List(x,y->ObjByExtRep(wordsfam,y)));
        fi;
    od;
    
    return result;
end);

#############################################################################
##
#M  RepresentativeTom( <tom> )
#M  RepresentativeTom( <tom>, <sub> )
#M  RepresentaitveTomByGroup( <tom>, <sub>, <group> )
#M  RepresentativeTomByGroupNC( <tom>, <sub>, <group> );
##
InstallOtherMethod(RepresentativeTom," underlying group of a table of marks",
          true, [IsTableOfMarks],0,GroupOfTom);

InstallMethod( RepresentativeTom,
                    "representative of a conjugacyclass of subgroups", true,
                  [IsTableOfMarks and HasGeneratorsSubgroupsTom,
                     IsPosInt],0,
function( tom, sub) 
    local gens, group, result;

    if sub = Length(OrdersTom(tom)) then
        return GroupOfTom(tom);
    fi;

    group:=GroupOfTom(tom);
    gens:=GeneratorsSubgroupsTom(tom);
    result:=Subgroup(group, gens[1]{gens[2][sub]});      
    SetSize(result, OrdersTom(tom)[sub]);

    return result;
end);

InstallMethod( RepresentativeTom, 
                    "representative of a conjugacyclass of subgroups", true,
                    [IsTableOfMarks and HasWordsTom, IsPosInt], 0,

function( tom, sub)
    local words, gens, subgroup, group;

    if sub = Length(OrdersTom(tom)) then
        return GroupOfTom(tom);
    fi;

    words:=WordsTom(tom)[sub];
    group:=GroupOfTom(tom);
    gens:=List(words,x->EvaluateWordTom(GeneratorsOfGroup(group),x));
    subgroup:=Subgroup(group,gens);
    SetSize(subgroup,OrdersTom(tom)[sub]);

    return subgroup;
end);


InstallMethod( RepresentativeTomByGroup,true, 
                [IsTableOfMarks and HasWordsTom, IsPosInt, 
                   IsGroup],0,
function(tom,sub,group)
    local gr, iso, words, gns, subgroup;

    # test <group>
    gr:=GroupOfTom(tom);
    iso:= GroupGeneralMappingByImages(gr,group,GeneratorsOfGroup(gr),
                 GeneratorsOfGroup(group));
    if not (IsGroupHomomorphism(iso) and IsBijective(iso)) then
        Print("#E the stored generators and the given ones don't define ",
              "an isomorphism\n");
        return fail;
    fi;

    if sub = Length(OrdersTom(tom)) then
        return group;
    fi;

    words:=WordsTom(tom)[sub];
    gns:=List(words,x->EvaluateWordTom(GeneratorsOfGroup(group),x));
    subgroup:=Subgroup(group, gns);
    SetSize(subgroup,OrdersTom(tom)[sub]);

    return subgroup;
end);


InstallMethod( RepresentativeTomByGroupNC, true,
             [IsTableOfMarks and HasWordsTom, IsPosInt, 
              IsGroup], 0,
function(tom,sub,group)
    local words, gns, subgroup;

    if sub = Length(OrdersTom(tom)) then
        return group;
    fi;

    words:=WordsTom(tom)[sub];
    gns:=List(words,x->EvaluateWordTom(GeneratorsOfGroup(group),x));
    subgroup:=Subgroup(group, gns);
    SetSize(subgroup,OrdersTom(tom)[sub]);

    return subgroup;
end);

#############################################################################
##
#M  SortTom( <tom>, <perm> )  .  .  .  .  .  .  .  .  .  .   .  .   sort tom
##
##
InstallMethod(SortTom,true,[IsTableOfMarks, IsPerm] ,0,
function(tom, perm)
    local i, components;
    
    components:=ListWithIdenticalEntries(Length(TableOfMarksComponents),0);

    if HasIdentifierOfTom(tom) then
        components[1]:=IdentifierOfTom(tom);
    fi;
    components[2]:=Permuted(List(SubsTom(tom),x->List(x,y->y^perm)),perm);
    components[3]:=Permuted(List(MarksTom(tom),ShallowCopy), perm);
    for i in [1..Length(components[2])] do
        SortParallel(components[2][i],components[3][i]);
    od;
    if HasNormalizersTom(tom) then
        components[6]:=List(NormalizersTom(tom),x->x^perm);
        components[6]:=Permuted(components[6],perm);
    fi;
    if HasComputedDerivedSubgroupsTom(tom) then
       components[7]:=List(DerivedSubgroupsTom(tom),x->x^perm);
       components[7]:=Permuted(components[7],perm);
    fi;
    if HasGroupOfTom(tom) then
        components[8]:=GroupOfTom(tom);
    fi;
    if HasWordsTom(tom) then
        components[9]:=Permuted(ShallowCopy(WordsTom(tom)),perm);
    fi;
    if HasGeneratorsSubgroupsTom(tom) then
        components[10]:=GeneratorsSubgroupsTom(tom)[1];
        components[11]:=Permuted(ShallowCopy(GeneratorsSubgroupsTom(tom)[2]),
                                            perm);
    fi;

    return ConvertToTableOfMarks(TOM(components));
end);

#############################################################################
##
#M  EulerianFunctionByTom( <tom>, <s> )
#M  EulerianFunctionByTom( <tom>, <s>, <sub> )
#M  EulerianFunction( <group>, <s> )
##
InstallMethod(EulerianFunctionByTom, true,[IsTableOfMarks, IsPosInt],0,
function( tom, s) 
   return EulerianFunctionByTom( tom , s, Length(SubsTom(tom)));
end);

InstallOtherMethod(EulerianFunctionByTom, true, [IsTableOfMarks,
      IsPosInt, IsPosInt],0,
function( tom, s, sub)
    local subs, orders, nrSubs, eulerian, i;
    
    orders:=OrdersTom(tom);
    subs:=SubsTom(tom);
    nrSubs:=NrSubsTom(tom);
    eulerian:=[1];
    
    #compute the values of the eulerian function recusively for each 
    #subgroup smaller then <sub>
    for i in [2..sub] do
        eulerian[i]:=orders[i]^s - 
                  Sum(List([1..Length(subs[i]) -1], 
                         x-> nrSubs[i][x] * eulerian[subs[i][x]]));
    od;

    return eulerian[sub];
end);

InstallMethod(EulerianFunction, "method for a group with table of marks",
             true, [IsGroup and HasTableOfMarksGroup,
              IsPosInt],10,
function( group, s) 
   return  EulerianFunctionByTom( TableOfMarksGroup(group), s);
end);

#############################################################################
##
#F  DerivedSubgroupsTom( <tom> )
#F  DerivedSubgroupsTomOp( <tom> )
#M  DerivedSubgroupsTomOp( <tom> )
#M  DerivedSubgroupsTomOp( <tom> )
##
##
InstallGlobalFunction(DerivedSubgroupsTom,
function(tom)
    local sub, der, dergr, j, grd;
    
    if HasComputedDerivedSubgroupsTom(tom) then
        return ComputedDerivedSubgroupsTom(tom);
    else
        der:=DerivedSubgroupsTomOp(tom);
        
        # do the rest by hand is possible
        if HasIsTableOfMarksWithGens(tom) then
            for sub in Filtered([1..Length(der)],x->IsList(der[x])) do
                dergr:=DerivedSubgroup(RepresentativeTom(tom,sub));
                der[sub]:=Filtered(der[sub],x->OrdersTom(tom)[x] = 
                                  Size(dergr));
                j:=1;
                while IsList(der[sub]) do
                    grd:=RepresentativeTom(tom,der[sub][j]);
                    if IsPerm(RepresentativeOperation(GroupOfTom(tom),
                               dergr,grd)) then
                        der[sub]:=der[sub][j];
                    fi;
                    j:=j+1;
                od;
            od;
        fi;  
        
        if ForAny(der,IsList) then
            SetComputedDerivedSubgroupsTomMut(tom,der);
        else
            SetComputedDerivedSubgroupsTom(tom,der);
        fi;
        return der;
    fi;
    
end);

InstallMethod(DerivedSubgroupsTomOp,true,[IsTableOfMarks],0,
function(tom)        
    local  sub, result;
    
    result:=ComputedDerivedSubgroupsTomMut(tom);
    for sub in Filtered([1..Length(result)],x-> result[x] = []) do
        DerivedSubgroupTom(tom,sub);
    od;
    
    return ComputedDerivedSubgroupsTomMut(tom);
end);

InstallMethod(ComputedDerivedSubgroupsTomMut,true,[IsTableOfMarks],0,
tom -> List([1..Length(SubsTom(tom))], x-> []));

InstallGlobalFunction(DerivedSubgroupTom,
function(tom,sub)
    local computed,i, der, grd;
    
    if HasComputedDerivedSubgroupsTom(tom) then
        return ComputedDerivedSubgroupsTom(tom)[sub];
    fi;
    
    computed:=ComputedDerivedSubgroupsTomMut(tom);
    if IsInt(computed[sub]) then
        return computed[sub];
    fi;
    computed[sub]:=DerivedSubgroupTomOp(tom,sub);
    
    if sub = Length(SubsTom(tom)) and IsList(computed[sub]) then
        i:=1;
        repeat 
            i:=i+1;
        until IsAbelianTom(FactorGroupTom(tom, computed[sub][i]));
        computed[sub]:=computed[sub][i];    
    fi;


    # do the rest by hand if possible
    if HasIsTableOfMarksWithGens(tom) and IsList(computed[sub]) then    
        der:=DerivedSubgroup(RepresentativeTom(tom,sub));
        computed[sub]:=Filtered(computed[sub],x->OrdersTom(tom)[x] = 
                                                 Size(der));
        i:=1;
        while IsList(computed[sub]) do
            grd:=RepresentativeTom(tom,computed[sub][i]);
            if IsPerm(RepresentativeOperation(GroupOfTom(tom),
                       der,grd)) then
                computed[sub]:=computed[sub][i];
            fi;
            i:=i+1;
        od;
    fi;  
    
    return computed[sub];
end);
  
InstallMethod(DerivedSubgroupTomOp,true, [IsTableOfMarks, IsPosInt], 0,
function(tom,sub)
    local set, primes, normalsubs, minindex, p, nrsubs, ext, pos, extp, 
          extps, sub1, sub2, result, i, j, indexsub1, indexsub2, index, int,
          notnormal, res, factorel, normsub1, norm, res1, oddord, order,
          normext, bool, n, orders, subs, isnormal, grd, der;
    
    
    isnormal:=function(tom,sub1,sub2)
        local sub, result, res;
        result:=false;
        if ContainedTom(tom,sub1,sub2)=1 then
            result:=true;
        else
            if IsInt(NormalizersTom(tom)[sub1]) then
                if NormalizersTom(tom)[sub1]=sub2   then
                    result:=true;
                elif sub2 in subs[NormalizersTom(tom)[sub1]] then     
                    result:=0;
                fi;
            else
                for sub in NormalizersTom(tom)[sub1] do
                    if sub2 in subs[sub] then
                        result:=0;
                    fi;
                od;
            fi;
        fi;
        return result;
    end;         

    result:=ComputedDerivedSubgroupsTomMut(tom)[sub];
    if result <> [] then
        return result;
    fi;    

    # first consider the trivial cases
    if IsCyclicTom(tom,sub)  then
        return 1;
    fi;

    if IsPerfectTom(tom,sub) then
        return sub;
    fi;

    orders:=OrdersTom(tom);
    subs:=SubsTom(tom);

    # find normal subgroups of prime index
    set:=Set(Factors(orders[sub]));
    primes:=[];
    normalsubs:=[];
    minindex:=1;
    for p in set do
        nrsubs:=0;
        ext:=CyclicExtensionsTom(tom,p);
        pos:=PositionProperty(ext,x->sub in x);
        extp:=Filtered(ext[pos],x->x in subs[sub] and orders[x] = 
                      orders[sub]/p);

        extps:=Filtered(ext[pos],x-> x in subs[sub] and orders[x]
                       = orders[sub]/p^2);
        extps:=Filtered(extps,x->isnormal(tom,x,sub) = true);
        Append(normalsubs,extps);
        for sub1 in extp do
            nrsubs:=nrsubs + ContainedTom(tom,sub1,sub);
            Add(primes,p);
            if Length(Intersection(subs[sub1],extps)) = 0 then
                Add(normalsubs,sub1);
            fi;
        od;
        if nrsubs <> 0 then
            nrsubs:=Length(Factors(nrsubs*(p-1)+1));
            minindex:=minindex*p^nrsubs;
        fi;
    od;
    primes:=Set(primes);

    # compute subgroups of sub which are connected by a chain of normal
    # extensions or order in primes
    ext:=CyclicExtensionsTom(tom,primes);
    ext:=ext[PositionProperty(ext,x-> sub in x)];

    # consider intersections of two normal subgroups
    # for each such intersection the derived subgroup must be
    # contained in one of the possible intersections returned by 
    # IntersectionsTom. Additionally there must be an chain of 
    # normal extensions connecting the derived subgroup and the groupext;
    result:=Filtered(subs[normalsubs[1]], x-> x in ext);
    for i in [1..Length(normalsubs)] do
        sub1:=normalsubs[i];
        indexsub1:=orders[sub]/orders[sub1];
        for j in [i..Length(normalsubs)] do
            sub2:=normalsubs[j];
            if sub1<>sub2 or(ContainedTom(tom,sub1,sub)<>1 and 
                       IsPrime(indexsub1)) then
                indexsub2:=orders[sub]/orders[sub2];
                index:=[indexsub1*indexsub2];
                if not (IsPrime(indexsub1) or IsPrime(indexsub2) or 
                        indexsub1<>
                        indexsub2) then
                    Add(index,Factors(indexsub1)[1]^3);
                fi;
                int:=IntersectionsTom(tom,sub1,sub2);
                int:=Filtered(int,x->orders[sub]/orders[x] in index);
                int:=Filtered(int,x-> x in ext);
                int:=List(int,x->subs[x]);

                int:=Flat(int);
                int:=Filtered(int,x-> x in ext);
                result:=Intersection(result,int);
            fi;
        od;
    od;

    if HasIsTableOfMarksWithGens(tom) then
        #  correct size is known
        der:=DerivedSubgroup(RepresentativeTom(tom,sub));
        result:=Filtered(result,x->orders[x]  = Size(der));

    else
        #forget all collected subgroups whose index is too small
        result:=Filtered(result,x->(orders[sub]/orders[x])
                        >=minindex);
    fi;


    # the derived subgroup must be normal
    notnormal:=Filtered(subs[sub],x-> isnormal(tom,x,sub)=false);
    result:=Difference(result,notnormal);


    #sub cannot be abelian if it contains a not-normal subgroup
    if IntersectionSet(notnormal,subs[sub])<>[] then
        RemoveSet(result,1);
    fi;

    if Length(result)=1 then
        return result[1];
    fi;

    # the factor group cannot contain a not normal member
    # if the factor group for one possible solution is cyclic 
    # it must contain the derived subgroup
    res:=[];
    for sub1 in Filtered(result,x->ContainedTom(tom,x,sub) = 1) do
        #inspecting the factorgroup if possible
        #collect the elements of the factorgroup that are not normal
        factorel:=Filtered(subs[sub], x->sub1 in subs[x]
                          and x in notnormal);

        if Length(factorel) >0 then
            Add(res,sub1);
        fi;
    od;
    result:=Difference(result,res);


    if Length(result)=1 then
        return result[1];
    fi;

    # the derivedsubgroup must be normal in every normal extension of sub
    # and the derived subgroup can't be an involution if any normal 
    # extension of sub has a cyclic subgroup of odd order 'n' and no 
    # cyclic subgroup of order '2*n'
    norm:=NormalizersTom(tom)[sub];
    if IsInt(norm) then
        normext:=Filtered(subs[norm],x->sub in subs[x] and 
                         isnormal(tom,sub,x)=true);
        res:=Filtered(result, 
                     x->ForAny(normext, y->isnormal(tom,x,y) = false));
        result:=Difference(result,res);
        if 2 in orders{result} then
            bool:=true;
            for sub1 in normext do
                res:=Filtered(subs[sub1],x->IsCyclicTom(tom,x));
                oddord:=2*Filtered(orders{res},IsOddInt);

                bool:=bool and ForAll(oddord,x->x in orders{res});
            od;

            if not bool then
                result:=Filtered(result, x-> orders[x] <> 2);
            fi;
        fi;
    else
        res:=[];
        for sub1 in result do
            bool:=true;
            for n in norm do
                normext:=Filtered(tom.subs[n],x->sub in tom.subs[x] and
                                 isnormal(tom,sub,x) = true);
                bool:= bool and ForAny(normext,x->
                               isnormal(tom,sub1,x) = false);
            od;
            if bool then
                Add(res,sub1);
            fi;
        od;
        result:=Difference(result,res);
    fi;
    
    if Length(result) = 1 then
        return result[1];
    else 
        return result;
    fi;


end);

#############################################################################
##
#M  IsNilpotentTom( <tom> )
#M  IsNilpotentTom( <tom>, <sub> )
##
InstallOtherMethod(IsNilpotentTom,true,[IsTableOfMarks],0,
tom -> IsNilpotentTom(tom,Length(SubsTom(tom))));

InstallMethod(IsNilpotentTom, true, [IsTableOfMarks,IsPosInt], 0,
function(tom, sub)
    local  factors, primes, exponents, i, pos;
    
    factors:=Factors(OrdersTom(tom)[sub]);
    factors:=Collected(factors);
    primes:=List(factors,x->x[1]);
    exponents:=List(factors,x->x[2]);
    for i in [1..Length(primes)] do
        pos:=Position(OrdersTom(tom){SubsTom(tom)[sub]},primes[i]^exponents[i]);
        if ContainedTom(tom,SubsTom(tom)[sub][pos],sub) > 1 then
            return false;
        fi;
    od;
    return true;
end);

#############################################################################
##
#M  IsSolvableTom( <tom> )
#M  IsSolvableTom( <tom>, <sub> )
##
InstallOtherMethod(IsSolvableTom, true, [IsTableOfMarks], 0,
tom -> IsSolvableTom(tom,Length(SubsTom(tom))));

InstallMethod(IsSolvableTom, true, [IsTableOfMarks, IsPosInt], 0,
function(tom, sub)
    local ext, pos;

    ext:=CyclicExtensionsTom(tom);
    pos:=PositionProperty(ext,x->1 in x);

    return sub in ext[pos];
end);

#############################################################################

#############################################################################
##
#E  tom.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##






  





