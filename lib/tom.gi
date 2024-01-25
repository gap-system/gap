#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Götz Pfeiffer, Thomas Merkwitz.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for tables of marks.
##
##  1. Tables of Marks
##  2. More about Tables of Marks
##  3. Table of Marks Objects in {\GAP}
##  4. Constructing Tables of Marks
##  5. Printing Tables of Marks
##  6. Sorting Tables of Marks
##  7. Technical Details about Tables of Marks
##  8. Attributes of Tables of Marks
##  9. Properties of Tables of Marks
##  10. Other Operations for Tables of Marks
##  11. Accessing Subgroups via Tables of Marks
##  12. The Interface between Tables of Marks and Character Tables
##  13. Generic Construction of Tables of Marks
##


#############################################################################
##
##  4. Constructing Tables of Marks
##


#############################################################################
##
#F  GeneratorsListTom( <G>, <classes> ) . . . . . . . . . . create generators
##
##  `GeneratorsListTom' lists a set of generators for a representative
##  of each conjugacy class of subgroups.
##
BindGlobal( "GeneratorsListTom", function( G, classes )
    local sub, gen, res;

    # take the generators
    sub:= List( classes, x -> GeneratorsOfGroup( Representative( x ) ) );

    # form the generators list
    gen:= Union( sub );

    # compute the positions
    res:= List( sub, grp -> List( grp, elm -> Position( gen, elm ) ) );
    return [ gen, res ];
    end );


#############################################################################
##
#M  TableOfMarks( <G> ) . . . . . . . . compute the table of marks of a group
##
InstallMethod( TableOfMarks,
    "for a cyclic group",
    [ IsGroup and IsCyclic ],
    function( G )
    local n, c, tom, gens, gen, subs, marks, classNames,
          name, i, j, divs, index;

    n:= Size( G );

    # construct the table of marks without the group

    # initialize
    divs:= DivisorsInt( n );
    c:= Length( divs );
    subs:= [];
    marks:= [];
    classNames:=[];

    # Compute generators for each subgroup.
    gens:= GeneratorsOfGroup( G );
    if 1 < Length( gens ) then
      gens:= MinimalGeneratingSet( G );
    fi;
    if 0 < Length( gens ) then
      gen:= gens[1];
    else
      gen:= One( G );
    fi;
    gens:= [ List( divs, d -> gen^(n/d) ),
             List( [ 1 .. c ], i -> [ i ] ) ];

    # construct each subgroup (each divisor)
    for i in [ 1 .. c ] do

      classNames[i]:= String( divs[i] );
      ConvertToStringRep( classNames[i] );

      index:= n / divs[i];
      subs[i]:= [];
      marks[i]:= [];
      for j in [1..i] do
        if divs[i] mod divs[j] = 0 then
          Add( subs[i], j );
          Add( marks[i], index );
        fi;
      od;

    od;

    # add new components
    if HasName( G ) then
      name:= Name( G );
    else
      name:= Concatenation( "C", String( n ) );
    fi;

    # make the object
    tom:= rec( Identifier                := name,
               SubsTom                   := subs,
               MarksTom                  := marks,
               NormalizersTom            := List( [ 1 .. c ], x -> c ),
               DerivedSubgroupsTomUnique := List( [ 1 .. c ], x -> 1 ),
               UnderlyingGroup           := G,
               GeneratorsSubgroupsTom    := gens );

    tom:= ConvertToTableOfMarks( tom );
    SetClassNamesTom( tom, classNames );
    return tom;
    end );


#############################################################################
##
#F  TableOfMarksByLattice( <G> )
##
InstallGlobalFunction( TableOfMarksByLattice, function( G )
    local marks,             # components of the table of marks
          subs,
          normalizers,
          derivedSubgroups,
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
          i,k,r;           # loop variables

#T Is this necessary at all?
    LatticeSubgroups( G );

    # compute the lattice,fetch the classes,zuppos,and representatives
    classes:= ShallowCopy( ConjugacyClassesSubgroups( G ) );

    # sort the classes
    SortBy(classes,a->Size(Representative(a)));
    classesZups:=[];

    # compute a system of generators for the cyclic sgr. of prime power size
    zuppos:=Zuppos(G);

    # initialize the table of marks
    Info(InfoLattice,1,"computing table of marks");
    subs:=List([1..Length(classes)],x->[]);
    marks:=List([1..Length(classes)],x->[]);
    derivedSubgroups:=[];
    normalizers:=[];
    DG:= DerivedSubgroup( G );
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
      D:= AttributeValueNotSet( DerivedSubgroup, I );
      if Size(D) = Size(I) then  # <I> perfect
        derivedSubgroups[i]:=i;
      elif Size(D) = 1 then      # <I> abelian
        derivedSubgroups[i]:=1;
      else
        Delms:=AttributeValueNotSet(AsList,D);
        Dzups:=BlistList(zuppos,Delms);
      fi;

      # compute the right transversal (but don't store it)
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
      Info( InfoLattice, 2,
            "testing class ",i,", size = ",Size(I),
            ", length = ",Size(G) / Size(N),", includes ",
            Length(marks[i])," classes");

    od;

    # Handle the whole group.
    Info( InfoLattice,2,"testing class ",Length(classes),", size = ",
          Size(G), ", length = ",1,", includes ",
          Length(marks[Length(classes)])," classes");
    subs[Length(classes)]:=[1..Length(classes)] + 0;
    marks[Length(classes)]:=ListWithIdenticalEntries(Length(classes),1);
    normalizers[Length(classes)]:=Length(classes);

    # Make the object.
    tom:= rec( SubsTom                   := subs,
               MarksTom                  := marks,
               NormalizersTom            := normalizers,
               DerivedSubgroupsTomUnique := derivedSubgroups,
               UnderlyingGroup           := G,
               GeneratorsSubgroupsTom    := GeneratorsListTom( G, classes ) );
    ConvertToTableOfMarks( tom );
    if HasName( G ) then
      SetIdentifier( tom, Name( G ) );
    fi;

    return tom;
end );


InstallMethod( TableOfMarks,
    "for a group with lattice",
    [ IsGroup and HasLatticeSubgroups ], 10,
    TableOfMarksByLattice );

InstallMethod( TableOfMarks,
    "for solvable groups (call `LatticeSubgroups' and use the lattice)",
    [ IsSolvableGroup ],
    TableOfMarksByLattice );

InstallMethod( TableOfMarks,
    "cyclic extension method",
    [ IsGroup ],
    function( G )
    local factors,           # factorization of <G>'s size
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
          layerb,            # begin of previous layer
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
          marks,             # components of the table of marks
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
    for r in zuppos do
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

    I:= DerivedSubgroup( G );
    if Size( I ) = Size( G ) then   # G perfect
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
            I:=SubgroupNC(Parent(G),Concatenation(GeneratorsOfGroup(H),
                         [zuppos[i]]));

            SetSize(I,Size(H) * zupposPrime[i]);

            # compute the zuppos blist of <I>
            Ielms:=AttributeValueNotSet(AsList,I);
            Izups:=BlistList(zuppos,Ielms);

            # compute the normalizer of <I>
            N:= Normalizer(G,I);
            ind:=Size(N) / Size(I);
            Info( InfoLattice, 2,
                  "found new class ", nrClasses + 1,
                  ", size = ", Size(I),
                  ", length = ", Size(G) / Size(N) );

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
                DifferenceBlist(BlistList([1..ll],[1..ll]), Izups);
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
            D:= AttributeValueNotSet( DerivedSubgroup, I );
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
          N:= Normalizer(G,I);
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

    # Make the object.
    tom:= rec( SubsTom                   := subs,
               MarksTom                  := marks,
               NormalizersTom            := normalizers,
               DerivedSubgroupsTomUnique := derivedSubgroups,
               UnderlyingGroup           := G,
               GeneratorsSubgroupsTom    := [ generators, groups ] );
    ConvertToTableOfMarks( tom );
    if HasName( G ) then
      SetIdentifier( tom, Name( G ) );
    fi;

    return tom;
end );


#############################################################################
##
#M  TableOfMarks( <mat> )  . . . . . . . . table of marks defined by a matrix
##
InstallMethod( TableOfMarks,
    "for a matrix or a lower triangular matrix",
    [ IsTable ],
    function( mat )
    local i, j, val, subs, marks, tom;

    # Check the argument.
    if not (     ForAll( mat, IsHomogeneousList )
             and ForAll( [ 1 .. Length( mat ) ],
                         i -> Length( mat[i] ) >= i ) ) then
      TryNextMethod();
    fi;

    # Setup `SubsTom' and `MarksTom' values.
    subs:= [];
    marks:= [];
    for i in [ 1 .. Length( mat ) ] do

      if   mat[i][1] <= 0 then
        Info( InfoTom, 1, "first column must have positive entries" );
        return fail;
      elif mat[i][i] = 0 then
        Info( InfoTom, 1, "diagonal entries must be nonzero" );
        return fail;
      fi;
      for j in [ i+1 .. Length( mat[i] ) ] do
        if mat[i][j] <> 0 then
          Info( InfoTom, 1, "the matrix must be lower triangular" );
          return fail;
        fi;
      od;

      subs[i]:= [];
      marks[i]:= [];

      for j in [ 1 .. i ] do
        val:= mat[i][j];
        if   val < 0 then
          Info( InfoTom, 1, "all entries must be nonnegative integers" );
          return fail;
        elif 0 < val then
          Add( subs[i], j );
          Add( marks[i], mat[i][j] );
        fi;
      od;

    od;

    # Make the object.
    tom:= rec( SubsTom  := subs,
               MarksTom := marks );
    ConvertToTableOfMarks( tom );

    # Test it.
    if not IsInternallyConsistent( tom ) then
      return fail;
    fi;

    # Return it.
    return tom;
    end );


#############################################################################
##
#F  TableOfMarksFromLibrary( <name> )
##
##  The `TableOfMarks' method for a string calls `TableOfMarksFromLibrary'.
##  If the library of tables of marks is not available then we bind this
##  to a dummy function that signals an error.
##
if not IsBoundGlobal( "TableOfMarksFromLibrary" ) then
  BindGlobal( "TableOfMarksFromLibrary", function( arg )
      Error( "sorry, the GAP Tables Of Marks Library is not installed" );
      end );
fi;


#############################################################################
##
#M  TableOfMarks( <name> )  . . . . . . . . . . library table with given name
##
InstallMethod( TableOfMarks,
    "for a string (dispatch to `TableOfMarksFromLibrary')",
    [ IsString ],
    str -> TableOfMarksFromLibrary( str ) );


#############################################################################
##
#M  LatticeSubroups( <G> )
##
##  method for a group with table of marks
##  method for a cyclic group
##
##  LatticeSubgroupsByTom( <G> )
##
InstallGlobalFunction( LatticeSubgroupsByTom, function( G )
    local marks, i, lattice, classes, tom;

    # Get the classes.
    tom:= TableOfMarks( G );
    classes:= List( [1..Length(OrdersTom( tom))], x-> ConjugacyClassSubgroups
                      (G, RepresentativeTom( tom, x)));

    marks:=MarksTom(tom);
    for i in [1..Length(classes)] do
         SetSize(classes[i],marks[i][1]/marks[i][Length(marks[i])]);
    od;

    # Create the lattice.
    lattice:=Objectify(NewType(FamilyObj(classes),IsLatticeSubgroupsRep),
                       rec());
    lattice!.conjugacyClassesSubgroups:=classes;
    lattice!.group     :=G;

    # Return the lattice.
    return lattice;
    end );

InstallMethod( LatticeSubgroups,
    "for a group with table of marks",
    [ IsGroup and HasTableOfMarks ], 10,
    LatticeSubgroupsByTom );

InstallMethod( LatticeSubgroups,
    "for a cyclic group",
    [ IsGroup and IsCyclic ],
    LatticeSubgroupsByTom );


#############################################################################
##
##  5. Printing Tables of Marks
##


#############################################################################
##
#M  ViewObj( <tom> ) . . . . . . . . . . . . . . . . . print a table of marks
##
InstallMethod( ViewObj,
    [ IsTableOfMarks ],
    function( tom )
    Print( "TableOfMarks( " );
    if   HasIdentifier( tom ) then
      Print( "\"", Identifier( tom ), "\"" );
    elif HasUnderlyingGroup( tom ) then
      ViewObj( UnderlyingGroup( tom ) );
    elif HasMarksTom( tom ) then
      Print( "<", Length( MarksTom( tom ) ), " classes>" );
    else
      Print( "<nothing useful known>" );
    fi;
    Print( " )" );
    end );


#############################################################################
##
#M  PrintObj( <tom> )
##
InstallMethod( PrintObj,
    [ IsTableOfMarks ],
    function( tom )
    Print( "TableOfMarks( " );
    if   HasIdentifier( tom ) then
      Print( "\"", Identifier( tom ), "\"" );
    elif HasUnderlyingGroup( tom ) then
      PrintObj( UnderlyingGroup( tom ) );
    elif HasMarksTom( tom ) then
      Print( "<", Length( MarksTom( tom ) ), " classes>" );
    else
      Print( "<nothing useful known>" );
    fi;
    Print( " )" );
    end );


#############################################################################
##
#M  Display( <tom>[, <options>] )  . . . . . . . . . display a table of marks
##
InstallMethod( Display,
    "for a table of marks (add empty options record)",
    [ IsTableOfMarks ],
    function( tom )
    Display( tom, rec() );
    end );

InstallOtherMethod( Display,
    "for a table of marks and an options record",
    [ IsTableOfMarks, IsRecord ],
    function( tom, options )
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
    end );


#############################################################################
##
##  6. Sorting Tables of Marks
##


#############################################################################
##
#M  SortedTom( <tom>, <perm> )  . . . . . . . . . . . . sorted table of marks
##
InstallMethod( SortedTom,
    [ IsTableOfMarks, IsPerm ],
    function( tom, perm )
    local i, components;

    components:= rec();

    if HasIdentifier( tom ) then
      components.Identifier:= Identifier( tom );
    fi;
    components.SubsTom:= Permuted( List( SubsTom( tom ),
                                   x -> ShallowCopy( OnTuples( x, perm ) ) ),
                                   perm);
    components.MarksTom:= Permuted( List( MarksTom( tom ), ShallowCopy ),
                                    perm );
    for i in [ 1 .. Length( components.SubsTom ) ] do
      SortParallel( components.SubsTom[i], components.MarksTom[i] );
    od;
    if HasNormalizersTom( tom ) then
      components.NormalizersTom:=
          Permuted( OnTuples( NormalizersTom( tom ), perm ), perm );
    fi;
    if HasDerivedSubgroupsTomUnique( tom ) then
       components.DerivedSubgroupsTomUnique:=
           Permuted( OnTuples( DerivedSubgroupsTomUnique( tom ), perm ),
                     perm );
    fi;
    if HasUnderlyingGroup( tom ) then
      components.UnderlyingGroup:= UnderlyingGroup( tom );
    fi;
    if HasStraightLineProgramsTom( tom ) then
      components.StraightLineProgramsTom:=
          Permuted( StraightLineProgramsTom( tom ), perm );
    fi;
    if HasGeneratorsSubgroupsTom(tom) then
      components.GeneratorsSubgroupsTom:=
          [ GeneratorsSubgroupsTom( tom )[1],
            Permuted( GeneratorsSubgroupsTom( tom )[2], perm ) ];
    fi;

    ConvertToTableOfMarks( components );

    if HasPermutationTom( tom ) then
      SetPermutationTom( components, PermutationTom( tom ) * perm );
    else
      SetPermutationTom( components, perm );
    fi;

    return components;
    end );


#############################################################################
##
##  7. Technical Details about Tables of Marks
##


#############################################################################
##
#F  ConvertToTableOfMarks( <record> )
##
InstallGlobalFunction( ConvertToTableOfMarks, function( record )
    local i, names;
    names:= RecNames( record );

    # Make the object.
    Objectify( NewType( TableOfMarksFamily,
                        IsTableOfMarks and IsAttributeStoringRep ),
               record );

    # Set the attributes values.
    for i in [ 1, 3 .. Length( TableOfMarksComponents )-1 ] do
      if TableOfMarksComponents[i] in names then
        Setter( TableOfMarksComponents[i+1] )( record,
                record!.( TableOfMarksComponents[i] ) );
      fi;
    od;

    return record;
    end );


#############################################################################
##
##  8. Attributes of Tables of Marks
##


#############################################################################
##
#M  MarksTom( <tom> ) . . . . . . . . . . . . . . . . . . . . . . . the marks
##
InstallMethod( MarksTom,
    "for a table of marks with known `NrSubsTom' and `OrdersTom'",
    [ IsTableOfMarks and HasNrSubsTom and HasOrdersTom ],
    function( tom )
    local i, j, ll, order, length, nrSubs, subs, marks, ord;

    # get the attributes and initialize
    order:=OrdersTom(tom);
    subs:=SubsTom(tom);
    length:=LengthsTom(tom);
    nrSubs:=NrSubsTom(tom);
    ll:=Length(order);
    ord:=order[ll];
    marks:=[[ord]];

    # Compute the marks.
    for i in [ 2 .. ll ] do
      marks[i]:= [ ord / order[i] ];
      for j in [ 2 .. Length( subs[i] ) ] do
        marks[i][j]:= nrSubs[i][j] * marks[i][1] / length[ subs[i][j] ];
        if not IsInt( marks[i][j] ) or marks[i][j] < 0 then
          Info( InfoTom, 1,
                "orbit length ", i, ", ", j, ": ", marks[i][j] );
        fi;
      od;
    od;

    return marks;
    end );


#############################################################################
##
#M  NrSubsTom( <tom> ) . . . . . . . . . . . . . . . . . numbers of subgroups
##
InstallMethod( NrSubsTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local i, j, nrSubs, subs, marks, length, index;

    # initialize
    length:= [];
    nrSubs:= [];
    subs:= SubsTom( tom );
    marks:= MarksTom( tom );

    # compute the numbers row by row
    for i in [ 1 .. Length( subs ) ] do
      index:= marks[i][Position(subs[i], 1)];
      length[i]:= index / marks[i][Position(subs[i], i)];
      nrSubs[i]:= [];

      for j in [1..Length(subs[i])] do
        nrSubs[i][j]:= marks[i][j] * length[subs[i][j]] / index;
        if not IsInt( nrSubs[i][j] ) or nrSubs[i][j] < 0 then
          Info( InfoTom, 1,
                "orbit length ", i, ", ", j, ": ", nrSubs[i][j] );
        fi;
      od;

    od;

    return nrSubs;
    end );


#############################################################################
##
#M  OrdersTom( <tom> )  . . . . . . . . . . . . . . . . . orders of subgroups
##
InstallMethod( OrdersTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local subs, marks;
    subs:= SubsTom( tom );
    marks:= MarksTom( tom );
    return List( [ 1 .. Length( subs ) ],
                 i -> marks[1][1] / marks[i][ Position( subs[i], 1 ) ] );
    end );


#############################################################################
##
#M  LengthsTom( <tom> )  . . . . . . . . . .  length of the conjugacy classes
##
InstallMethod( LengthsTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local nrSubs;
    nrSubs:= NrSubsTom( tom );
    return nrSubs[ Length( nrSubs ) ];
    end );


#############################################################################
##
#M  ClassTypesTom( <tom> )  . . . . . . . . . . . . . . .  types of subgroups
##
InstallMethod( ClassTypesTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local i, j, nrsubs, subs, order, type, struct, nrtypes;

    nrsubs:= NrSubsTom(tom);
    subs:= SubsTom(tom);
    order:=OrdersTom(tom);
    type:= [];
    struct:= [];
    nrtypes:= 1;

    for i in [1..Length(subs)] do

      # determine type
      # classify according to the number of subgroups
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
    end );


#############################################################################
##
#F  ClassNamesTom( <tom> )  . . . . . . . . . . . . . . . . . . . class names
##
InstallMethod( ClassNamesTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
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
      ConvertToStringRep( c );
    od;

    return name;
    end );


#############################################################################
##
#M  FusionsTom( <tom> )
##
InstallMethod( FusionsTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    x -> [] );


#############################################################################
##
#M  IdempotentsTom( <tom> ) . . . . . . . . . . . . . . . . . . . idempotents
##
InstallMethod( IdempotentsTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local i, c, classes, p, ext, marks;

    marks:= MarksTom( tom );
    classes:= [ 1 .. Length( marks ) ];

    for p in PrimeDivisors( marks[1][1] ) do
      ext:= CyclicExtensionsTom( tom, p );
      for c in ext do
        for i in c do
          classes[i]:= classes[ c[1] ];
        od;
      od;
    od;

    for i in [ 1 .. Length( classes ) ] do
      classes[i]:= classes[ classes[i] ];
    od;

    return classes;
    end );


#############################################################################
##
#M  IdempotentsTomInfo( <tom> ) . . . . . . . . . . . . . . . . . idempotents
##
InstallMethod( IdempotentsTomInfo,
    "for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local ext, ll, result, class, idem;

    ext:= CyclicExtensionsTom( tom );
    ll:= Length( SubsTom( tom ) );
    result:= rec( primidems       := [],
                  fixpointvectors := [] );

    for class in ext do

      idem:= ListWithIdenticalEntries( ll, 0 );
      idem{ class }:= List( class, x -> 1 );
      Add( result.fixpointvectors, idem );
      Add( result.primidems, DecomposedFixedPointVector( tom, idem ) );

    od;

    return result;
    end );


#############################################################################
##
#M  MatTom( <tom> ) . . . . . . convert compressed table of marks into matrix
##
InstallMethod( MatTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local i, j, subs, marks, ll, res;

    marks:= MarksTom( tom );
    subs:= SubsTom( tom );
    ll:= [ 1 .. Length( subs ) ];

    res:= [];
    for i in ll do
      res[i]:= ListWithIdenticalEntries( Length( ll ), 0 );
      for j in [ 1 .. Length( subs[i] ) ] do
        res[i][ subs[i][j] ]:= marks[i][j];
      od;
    od;

    return res;
    end );


#############################################################################
##
#M  MoebiusTom( <tom> ) . . . . . . . . . . . . . . . . . .  Moebius function
##
InstallMethod( MoebiusTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local i, j, mline, nline, ll, mdec, ndec, expec, done, no, comsec,
          order, subs, nrsubs, length, der, result;

    nrsubs:= NrSubsTom(tom);
    subs:= SubsTom(tom);
    length:= LengthsTom(tom);
    order:=OrdersTom(tom);
    mline:= List(subs, x-> 0);
    nline:= List(subs, x-> 0);
    ll:= Length( subs );
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

    result:= rec( mu := mdec,
                  nu := ndec );

    # Determine intersections with the derived subgroup of the whole group
    # if this can be uniquely determined.
    der:= DerivedSubgroupTom( tom, ll );
    if IsInt( der ) then

      expec:= [];
      if der <> ll then
        comsec:= [];
        for i in [ 1 .. ll ] do

          # There is only one intersection with normal subgroups.
          comsec[i]:= Number( IntersectionsTom( tom, i, der ), x -> x <> 0 );

        od;
        for i in [ 1 .. Length( ndec ) ] do
          if IsBound( ndec[i] ) then
            no:= NormalizersTom( tom )[i];

            #  maybe the normalizer is not unique.
            if IsList( no ) then
              no:= List( no, x -> order[ comsec[x] ] );
              no:= Set( no );
              if Size( no ) > 1 then
                Info( InfoTom, 2,
                      "Size of normalizer ", i, " not unique." );
              else
                no:= no[1];
              fi;
            else
              no:= order[ comsec[ no ] ];
            fi;
            expec[i]:= ndec[i] * no / order[ comsec[i] ];
          fi;
        od;

      else

        # The group is perfect.
        for i in [ 1 .. Length( ndec ) ] do
          if IsBound( ndec[i] ) then
            expec[i]:= ndec[i] * order[ ll ] / order[i] / length[i];
          fi;
        od;

      fi;

      result.ex:= expec;
      result.hyp:= Filtered( [ 1 .. Length( expec ) ],
                             function( x )
                               if IsBound( expec[x] ) then
                                 return    ( not IsBound( mdec[x] ) )
                                        or expec[x] <> mdec[x];
                               else
                                 return IsBound( mdec[x] );
                               fi;
                             end );

    fi;

    return result;
    end );


#############################################################################
##
#M  WeightsTom( <tom> ) . . . . . . . . . . . . . . . . . . . . . . . weights
##
InstallMethod( WeightsTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local subs, marks;

    marks:= MarksTom(tom);
    subs:= SubsTom(tom);

    return List( [ 1 .. Length( subs ) ],
                 i -> marks[i][ Position( subs[i], i ) ] );
    end );


#############################################################################
##
##  9. Properties of Tables of Marks
##


#############################################################################
##
#M  IsAbelianTom( <tom>[, <sub>] )
##
##  If the group of <tom> is known then `IsAbelianTom' delegates the task
##  to the group.
##  Otherwise it is used that a group is abelian if and only if all subgroups
##  are normal and the group contains no quaternion group of order $8$.
##
InstallMethod( IsAbelianTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local marks, subs, nrSubs, order, result, sub, number, sub1;

    result:=true;
    marks:=MarksTom(tom);
    order:=OrdersTom(tom);
    subs:=SubsTom(tom);
    nrSubs:=NrSubsTom(tom);

    # All subgroups must be normal.
    for sub in [ 1 .. Length( order ) ] do
      if marks[ sub ][1] <> marks[ sub ][ Length( marks[ sub ] ) ] then
        return false;
      fi;
    od;

    # Test the subgroups of order $8$.
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
    end );

InstallMethod( IsAbelianTom,
    "for a table of marks and a positive integer",
    [ IsTableOfMarks, IsPosInt ], 10,
    function( tom, sub )
    sub:= DerivedSubgroupTom( tom, sub );
    if IsInt( sub ) then
      return sub = 1;
    elif not 1 in sub then
      return false;
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( IsAbelianTom,
    "for a table of marks with known der. subgroups, and a positive integer",
    [ IsTableOfMarks and HasDerivedSubgroupsTomUnique, IsPosInt ], 1000,
    function( tom, sub )
    return DerivedSubgroupsTomUnique( tom )[ sub ] = 1;
    end );

InstallMethod( IsAbelianTom,
    "for a table of marks with generators, and a positive integer",
    [ IsTableOfMarks and IsTableOfMarksWithGens, IsPosInt ],
    function( tom, sub )
    return IsAbelian( RepresentativeTom( tom, sub ) );
    end );


#############################################################################
##
#M  IsCyclicTom( <tom>[, <sub>] ) . . . .  check whether a subgroup is cyclic
##
##  A subgroup is cyclic if and only if the sum of the corresponding row of
##  the inverse table of marks is nonzero (see Kerber, S. 125).
##  Thus we only have to decompose the corresponding idempotent.
##
InstallMethod( IsCyclicTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    tom -> IsCyclicTom( tom, Length( SubsTom( tom ) ) ) );

InstallMethod( IsCyclicTom,
    "for a table of marks and a positive integer",
    [ IsTableOfMarks, IsPosInt ],
    function( tom, sub )
    local mline;

    mline:= 0 * [ 1 .. sub ];
    mline[ sub ]:= 1;

    # Decompose mline w.r.t. tom, and determine whether the sum is nonzero.
    return Sum( DecomposedFixedPointVector( tom, mline ), 0 ) <> 0;
    end );


#############################################################################
##
#M  IsNilpotentTom( <tom>[, <sub>] )
##
InstallMethod( IsNilpotentTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    tom -> IsNilpotentTom( tom, Length( SubsTom( tom ) ) ) );

InstallMethod( IsNilpotentTom,
    "for a table of marks and a positive integer",
    [ IsTableOfMarks, IsPosInt ],
    function( tom, sub )
    local  factors, primes, exponents, i, pos;

    factors:=Factors(OrdersTom(tom)[sub]);
    factors:=Collected(factors);
    primes:=List(factors,x->x[1]);
    exponents:=List(factors,x->x[2]);
    for i in [1..Length(primes)] do
      pos:= Position( OrdersTom( tom ){ SubsTom( tom )[ sub ] },
                      primes[i]^exponents[i] );
      if ContainedTom(tom,SubsTom(tom)[sub][pos],sub) > 1 then
        return false;
      fi;
    od;
    return true;
    end );


#############################################################################
##
#M  IsPerfectTom( <tom>[, <sub>] )
##
##  A finite group is perfect if and only if it has no normal subgroup of
##  prime index.
##  This is tested here.
##
##  If <tom> knows its underlying group the task is delegated to th group.
##
InstallMethod( IsPerfectTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    tom -> IsPerfectTom( tom, Length( SubsTom( tom ) ) ) );

InstallMethod( IsPerfectTom,
    "for a table of marks with known der. subgroups, and a positive integer",
    [ IsTableOfMarks and HasDerivedSubgroupsTomUnique, IsPosInt ],
    function( tom, sub )
    return DerivedSubgroupsTomUnique( tom )[ sub ] = sub;
    end );

InstallMethod( IsPerfectTom,
    "for a table of marks and a positive integer",
    [ IsTableOfMarks, IsPosInt ],
    function( tom, sub )
    local ext, pos;
    ext:=CyclicExtensionsTom(tom);
    pos:=PositionProperty(ext,x-> sub in x);
    return sub = Minimum(ext[pos]);
    end );


#############################################################################
##
#M  IsSolvableTom( <tom>[, <sub>] )
##
InstallMethod( IsSolvableTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    tom -> IsSolvableTom( tom, Length( SubsTom( tom ) ) ) );

InstallMethod( IsSolvableTom,
    "for a table of marks and a positive integer",
    [ IsTableOfMarks, IsPosInt ],
    function( tom, sub )
    local ext, pos;

    ext:= CyclicExtensionsTom( tom );
    pos:= PositionProperty( ext, x -> 1 in x );

    return sub in ext[ pos ];
    end );


#############################################################################
##
##  10. Other Operations for Tables of Marks
##


#############################################################################
##
#M  IsInternallyConsistent( <tom> ) . .  consistency check for table of marks
##
##  The tensor product of two rows of the table of marks decomposes into
##  rows of the table of marks with integer coefficients.
##
BindGlobal( "TestRow", function( tom, n )
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
      dec:= DecomposedFixedPointVector(tom, b);
      if ForAny(Set(dec), x-> not IsInt(x) or (x < 0)) then
        Info(InfoTom,2, n, ".", i, " = ", dec);
        test:= false;
      fi;
    od;

    return test;
end );

InstallMethod( IsInternallyConsistent,
    "for a table of marks, decomposition test",
    [ IsTableOfMarks ],
    function( tom )
    local test, g, i;

    test:= true;

    # Check that the underlying group has the right order.
    if HasUnderlyingGroup( tom ) then
      g:= UnderlyingGroup( tom );
      if Size( g ) <> Size( Group( GeneratorsOfGroup( g ), One( g ) ) ) then
        return false;
      fi;
    fi;

    for i in [ 1 .. Length( SubsTom( tom ) ) ] do
      if not TestRow( tom, i ) then
        return false;
      fi;
    od;

    return test;
    end );


#############################################################################
##
#M  DerivedSubgroupTom( <tom>, <sub> )
##
InstallMethod( DerivedSubgroupTom,
    "for a table of marks, and a positive integer",
    [ IsTableOfMarks, IsPosInt ],
    function( tom, sub )
    local set, primes, normalsubs, minindex, p, nrsubs, ext, pos, extp,
          extps, sub1, sub2, result, i, j, indexsub1, indexsub2, index, int,
          notnormal, res, factorel, norm, oddord,
          normext, bool, n, orders, subs, isnormal, grd, der, poss;

    # Check whether the derived subgroup has been computed already.
    if HasDerivedSubgroupsTomUnique( tom ) then
      return DerivedSubgroupsTomUnique( tom )[ sub ];
    fi;

    # Perhaps this is not the first time one has asked for this value.
    poss:= DerivedSubgroupsTomPossible( tom );
    if IsBound( poss[ sub ] ) then
      return poss[ sub ];
    fi;

    # First consider the trivial cases.
    if IsCyclicTom( tom, sub ) then
      result:= 1;
    elif IsPerfectTom( tom, sub ) then
      result:= sub;
    else

      # Compute the possibilities.
      isnormal:=function(tom,sub1,sub2)
          local sub, result;
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

      orders:=OrdersTom(tom);
      subs:=SubsTom(tom);

      # find normal subgroups of prime index
      set:=PrimeDivisors(orders[sub]);
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
      # `IntersectionsTom'.
      # Additionally there must be a chain of
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
                  int:= Filtered( [ 1 .. Length( int ) ], x -> int[x] <> 0 );
                  int:=Filtered(int,x->orders[sub]/orders[x] in index);
                  int:=Filtered(int,x-> x in ext);
                  int:=List(int,x->subs[x]);

                  int:=Flat(int);
                  int:=Filtered(int,x-> x in ext);
                  result:=Intersection(result,int);
              fi;
          od;
      od;

      if IsTableOfMarksWithGens(tom) then
          # correct size is known
          der:=DerivedSubgroup(RepresentativeTom(tom,sub));
          result:=Filtered(result,x->orders[x]  = Size(der));

      else
          # forget all collected subgroups whose index is too small
          result:=Filtered(result,x->(orders[sub]/orders[x])
                          >=minindex);
      fi;

      # the derived subgroup must be normal
      notnormal:=Filtered(subs[sub],x-> isnormal(tom,x,sub)=false);
      result:=Difference(result,notnormal);

      # sub cannot be abelian if it contains a not-normal subgroup
      if IntersectionSet( notnormal, subs[ sub ] ) <> [] then
        RemoveSet( result, 1 );
      fi;

      if Length( result ) = 1 then
        result:= result[1];
      else

        # the factor group cannot contain a not normal member
        # if the factor group for one possible solution is cyclic
        # it must contain the derived subgroup
        res:=[];
        for sub1 in Filtered(result,x->ContainedTom(tom,x,sub) = 1) do
            #inspecting the factor group if possible
            #collect the elements of the factor group that are not normal
            factorel:=Filtered(subs[sub], x->sub1 in subs[x]
                              and x in notnormal);

            if Length(factorel) >0 then
                Add(res,sub1);
            fi;
        od;
        result:=Difference(result,res);

        if Length( result ) = 1 then
          result:= result[1];
        else

          # the derived subgroup must be normal in every normal extension of sub
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
                      normext:=Filtered(subs[n],x->sub in subs[x] and
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

          if Length( result ) = 1 then
            result:= result[1];
          fi;


        fi;

      fi;

    fi;

    # Finally, deal with the special case of the whole group.
    if sub = Length( SubsTom( tom ) ) and IsList( result ) then
      i:= 1;
      repeat
        i:= i+1;
      until IsAbelianTom( FactorGroupTom( tom, result[i] ) );
      result:= result[i];
    fi;

    # Do the rest by hand if possible.
    if IsTableOfMarksWithGens( tom ) and IsList( result ) then
      der:= DerivedSubgroup( RepresentativeTom( tom, sub ) );
      result:= Filtered( result, x -> OrdersTom( tom )[x] = Size( der ) );
      for i in [ 1 .. Length( result ) ] do
        grd:= RepresentativeTom( tom, result[i] );
        if IsConjugate( UnderlyingGroup( tom ), der, grd ) then
          result:= result[i];
          break;
        fi;
      od;
    fi;

    # Store the result.
    poss[ sub ]:= result;

    # Are all derived subgroups known and uniquely determined?
    if     IsInt( result )
       and IsDenseList( poss )
       and Length( poss ) = Length( SubsTom( tom ) )
       and ForAll( poss, IsInt ) then
      SetDerivedSubgroupsTomUnique( tom, poss );
    fi;

    return result;
    end );


#############################################################################
##
#F  DerivedSubgroupsTom( <tom> )
##
InstallGlobalFunction( DerivedSubgroupsTom,
    tom -> List( [ 1 .. Length( SubsTom( tom ) ) ],
                 sub -> DerivedSubgroupTom( tom, sub ) ) );


#############################################################################
##
#M  DerivedSubgroupsTomPossible( <tom> )
##
InstallMethod( DerivedSubgroupsTomPossible,
    "for a table of marks (initialize with empty list)",
    [ IsTableOfMarks ],
    tom -> [] );


#############################################################################
##
#M  NormalizerTom( <tom>, <sub> )  . . . . . . . . . determine one normalizer
##
InstallMethod( NormalizerTom,
    "for a table of marks, and a positive integer",
    [ IsTableOfMarks, IsPosInt ],
    function( tom, sub )
    local nord, subs, order, nrsubs, length, ll, res, i, nn;

    # If normalizers are stored already then fetch the value.
    if HasNormalizersTom( tom ) then
      return NormalizersTom( tom )[ sub ];
    fi;

    # Get the attributes.
    subs:= SubsTom( tom );
    order:= OrdersTom( tom );
    nrsubs:= NrSubsTom( tom );
    length:= LengthsTom( tom );
    ll:= Length( order );

    # order of normalizer.
    nord:= order[ll] / length[ sub ];

    # self-normalizing.
    if nord = order[ sub ] then
      return sub;
    fi;

    # normal.
    if length[ sub ] = 1 then
      return ll;
    fi;

    # Compute candidates of the right order.
    res:= [];
    for i in [ sub+1 .. ll ] do
      if order[i] = nord then
        Add( res, i );
      fi;
    od;

    # The normalizer of $U$ must contain $U$.
    res:= Filtered( res, x -> sub in subs[x] );
    if Length( res ) = 1 then
      return res[1];
    fi;

    # The normalizer of $U$ must contain all subgroups containing $U$
    # as a normal subgroup, in particular those where $U$ is of index 2
    # and those containing only one conjugate of $U$.
    nn:= [];
    for i in [ sub+1 .. Maximum( res ) ] do
      if sub in subs[i] then
        if    order[i] = 2 * order[ sub ]
           or nrsubs[i][ Position( subs[i], sub ) ] = 1 then
          Add( nn, i );
        fi;
      fi;
    od;
    res:= Filtered( res, x -> IsSubset( subs[x], nn ) );

    # If one of the possible normalizers is abelian then we are done.
    if HasDerivedSubgroupsTomUnique( tom ) then
      for i in res do
        if DerivedSubgroupsTomUnique( tom )[i] = 1 then
          return i;
        fi;
      od;
    fi;
    if Length( res ) = 1 then
      return res[1];
    fi;

    # If `tom' knows its group then do the rest by hand.
    if IsTableOfMarksWithGens( tom ) and IsList( res ) then
      nn:= Normalizer( UnderlyingGroup( tom ),
                       RepresentativeTom( tom, sub ) );
      for i in res do
        if IsConjugate( UnderlyingGroup( tom ), nn,
                        RepresentativeTom( tom, i ) ) then
          return i;
        fi;
      od;
    else
      return res;
    fi;
    end );


#############################################################################
##
#M  NormalizersTom( <tom> ) . . . . . . . . . . . . . .  determine normalizer
##
InstallMethod( NormalizersTom,
    "all normalizers of a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local result, subs, order, nrsubs, ll, impr, d, der, bool,
          NormalizerTom, sub, nn, nn1,  sub1, norm;

    # Get the attributes.
    subs:= SubsTom( tom );
    order:= OrdersTom( tom );
    nrsubs:= NrSubsTom( tom );
    ll:= Length( order );
    result:= [];

    # Loop over the subgroups.
    impr:= [];
    for sub in [ 1 .. ll ] do
      norm:= NormalizerTom( tom, sub );
      Add( result, norm );
      if IsList( norm ) then
        Add( impr, sub );
      fi;
    od;

    # Try to improve the result.
    if HasDerivedSubgroupsTomUnique( tom ) then
      d:= true;
      der:= DerivedSubgroupsTomUnique( tom );
    fi;

    bool:= true;
    while bool do
      bool:= false;
      for sub in impr do
        # the normalizer must contain the normalizer of all sub-
        # groups which contain only one conjugate of u
        # and the normalizer of all subgroups <v> whose derived subgroup
        # is <u>
        nn:=[];
        for sub1 in [ sub+1 .. ll-1 ] do
          if sub in subs[ sub1 ] and IsInt( result[ sub1 ] ) then
            if nrsubs[ sub1 ][ Position( subs[ sub1 ], sub ) ] = 1 then
              Add( nn, result[ sub1 ] );
            elif d and der[ sub1 ] = sub then
              Add( nn, result[ sub1 ] );
            fi;
          fi;
        od;

        # The normalizer must be contained in the normalizer of all
        # those subgroups <v> of <u> for which <u> contains only one
        # conjugate of <v>.
        nn1:= [];
        for sub1 in subs[sub] do
          if     nrsubs[ sub ][ Position( subs[ sub ], sub1 ) ] = 1
             and IsInt( result[ sub1 ] ) then
            Add( nn1, result[ sub1 ] );
          fi;
        od;

        # The normalizer must be contained in the normalizer of the
        # derived subgroup of <u>.
        if d and IsInt( der[ sub ] )
             and IsInt( result[ der[ sub ] ] ) then
          Add( nn1, result[ der[ sub ] ] );
        fi;

        norm:= Filtered( result[ sub ],
                         x ->     IsSubset( subs[x], nn )
                              and ForAll( nn1, y -> x in subs[y] ) );

        # If there was an improvement then try it again.
        if Length( norm ) < Length( result[ sub ] ) then
          bool:= true;
        fi;

        if Length( norm ) = 1 then
          norm:= norm[1];
        fi;

        result[ sub ]:= norm;

      od;
    od;

    return result;
    end );


#############################################################################
##
#M  ContainedTom( <tom>, <sub1>, <sub2> )
##
##  How many subgroups of class <sub1> lie in one subgroup of class <sub2>?
##
InstallMethod( ContainedTom,
    [ IsTableOfMarks, IsPosInt, IsPosInt ],
    function( tom, sub1, sub2 )

    if sub1 in SubsTom( tom )[ sub2 ] then
      return NrSubsTom( tom )[ sub2 ][ Position( SubsTom( tom )[ sub2 ],
                                                 sub1 ) ] ;
    else
      return 0;
    fi;
    end );


#############################################################################
##
#M  ContainingTom( <tom>, <sub1>, <sub2> )
##
##  How many subgroups of class <sub2> contain one subgroup of class <sub1>?
##
InstallMethod( ContainingTom,
    [ IsTableOfMarks, IsPosInt, IsPosInt ],
    function( tom, sub1, sub2 )

    if sub1 in SubsTom( tom )[ sub2 ] then
      return MarksTom( tom )[ sub2 ][ Position( SubsTom( tom )[ sub2 ],
                                                sub1 ) ] /
             MarksTom( tom )[ sub2 ][ Length( MarksTom( tom )[ sub2 ] ) ];
    else
      return 0;
    fi;
    end );


#############################################################################
##
#M  CyclicExtensionsTom( <tom> )
#M  CyclicExtensionsTom( <tom>, <p> )
#M  CyclicExtensionsTom( <tom>, <list> )
##
InstallMethod( CyclicExtensionsTom,
    "for a table of marks (classes for all prime div. of the group order)",
    [ IsTableOfMarks ],
    tom -> CyclicExtensionsTom( tom, PrimeDivisors(MarksTom(tom)[1][1]) ) );

InstallMethod( CyclicExtensionsTom,
    "for a table of marks, and a prime",
    [ IsTableOfMarks, IsPosInt ],
    function( tom, p )
    return CyclicExtensionsTom( tom, [ p ] );
    end );

InstallMethod( CyclicExtensionsTom,
    "for a table of marks, and a list (of primes)",
    [ IsTableOfMarks, IsList ],
    function( tom, list )
    local pos, computed, primes, factors, value;

    if not ForAll( list, IsPrimeInt ) then
      Error( "the second argument must be a list of primes" );
    fi;

    factors:= PrimeDivisors( MarksTom( tom )[1][1] );
    primes:= Filtered( list, x -> x in factors);
    if primes = [] then
      return List( [ 1 .. Length( MarksTom( tom ) ) ], x -> [ x ] );
    fi;

    computed:= ComputedCyclicExtensionsTom( tom );
    pos:= Position( computed, primes );
    if IsInt( pos ) then
      return computed[ pos+1 ];
    fi;

    value:= CyclicExtensionsTomOp( tom, primes );
    Add( computed, primes );
    Add( computed, value );

    return value;
    end );


#############################################################################
##
#M  ComputedCyclicExtensionsTom( <tom> )
##
InstallMethod( ComputedCyclicExtensionsTom,
    [ IsTableOfMarks ],
    x -> [] );


#############################################################################
##
#M  CyclicExtensionsTomOp( <tom>, <p> )
#M  CyclicExtensionsTomOp( <tom>, <list> )
##
InstallMethod( CyclicExtensionsTomOp,
    "for one prime",
    [ IsTableOfMarks, IsPosInt ],
    function( tom, p )
    local i, j, h, ll, done, classes, pos, val, marks, subs;

    # get the attributes and initialize
    marks:= MarksTom( tom );
    subs:= SubsTom( tom );
    ll:= Length( subs );

    pos:= [];
    val:= [];

    #  take marks mod <p> and transpose.
    for i in [ 1 .. ll ] do
      pos[i]:= [];
      val[i]:= [];
      for j in [ 1 .. Length( subs[i] ) ] do
        h:= marks[i][j] mod p;
        if h <> 0 then
          Add( pos[ subs[i][j] ], i );
          Add( val[ subs[i][j] ], h );
        fi;
      od;
    od;

    #  form classes
    classes:= [];
    for i in [ 1 .. ll ] do
      j:= 1;
      done:= false;
      while not done and j < i do
        if pos[i] = pos[j] and val[i] = val[j] then
          Add( classes[j], i );
          done:= true;
        fi;
        j:= j+1;
      od;
      if not done then
        classes[i]:= [ i ];
      fi;
    od;

    return Set( classes );
    end );

InstallMethod( CyclicExtensionsTomOp,
    "for a table of marks, and a list (of primes)",
    [ IsTableOfMarks, IsList ],
    function( tom, primes )
    local p, ext, c, i, comp, classes;

    if Length( primes ) = 1 then
      return CyclicExtensionsTomOp( tom, primes[1] );
    fi;

    classes:= [ 1 .. Length( SubsTom( tom ) ) ];
    for p in primes do
      ext:= CyclicExtensionsTom( tom, p );
      for c in ext do
        for i in c do
          classes[i]:= classes[ c[1] ];
        od;
      od;
    od;

    for i in [ 1 .. Length( classes ) ] do
      classes[i]:= classes[ classes[i] ];
    od;

    comp:= Set( classes );
    ext:= List( comp, x -> Filtered( [ 1 .. Length( classes ) ],
                                     y -> classes[y] = x ) );

    return ext;
    end );


#############################################################################
##
#M  DecomposedFixedPointVector( <tom>, <fix> )  . . . . . . . decompose marks
##
InstallMethod( DecomposedFixedPointVector,
    [ IsTableOfMarks, IsList ],
    function( tom, fixpointvector )
    local fix, i, j, dec, marks, subs, working;

    # get the attributes
    marks:= MarksTom(tom);
    subs:= SubsTom(tom);
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
    end );


#############################################################################
##
#M  EulerianFunctionByTom( <tom>, <s> )
#M  EulerianFunctionByTom( <tom>, <s>, <sub> )
##
InstallMethod( EulerianFunctionByTom,
    [ IsTableOfMarks, IsPosInt ],
    function( tom, s )
    return EulerianFunctionByTom( tom, s, Length( SubsTom( tom ) ) );
    end );

InstallMethod( EulerianFunctionByTom,
    [ IsTableOfMarks, IsPosInt, IsPosInt ],
    function( tom, s, sub )
    local subs, orders, nrSubs, eulerian, i;

    orders:=OrdersTom(tom);
    subs:=SubsTom(tom);
    nrSubs:=NrSubsTom(tom);
    eulerian:=[1];

    # compute the values of the Eulerian function recursively for each
    # subgroup smaller than <sub>
    for i in [ 2 .. sub ] do
      eulerian[i]:= orders[i]^s - Sum( List( [ 1 .. Length( subs[i] ) -1 ],
                       x -> nrSubs[i][x] * eulerian[ subs[i][x] ] ) );
    od;

    return eulerian[ sub ];
    end );


#############################################################################
##
#M  EulerianFunction( <G>, <s> )
##
InstallMethod( EulerianFunction,
    "for a group with table of marks",
    [ IsGroup and HasTableOfMarks, IsPosInt ], 10,
    function( G, s )
    return EulerianFunctionByTom( TableOfMarks( G ), s );
    end );


#############################################################################
##
#M  EulerianFunction( <G>, <s> )
##
InstallMethod( EulerianFunction,
    "for a group, compute table of marks",
    [ IsGroup, IsPosInt ],
    {} -> -RankFilter (IsGroup)-RankFilter (IsPosInt), # rank 0
    function( G, s )
        if not HasTableOfMarks( G ) then
          Info( InfoWarning, 1, "EulerianFunction computes ",
                "the table of marks. This may be slow." );
        fi;
        return EulerianFunctionByTom( TableOfMarks( G ), s );
    end );


#############################################################################
##
#M  IntersectionsTom( <tom>, <a>, <b> ) . . . . .  intersections of subgroups
##
InstallMethod( IntersectionsTom,
    [ IsTableOfMarks, IsPosInt, IsPosInt ],
    function(tom,a,b)
    local i, j, k, h, line, marks, subs;

    # get the attributes and initialize
    marks:= MarksTom(tom);
    subs:= SubsTom(tom);
    h:= [];
    line:= [];

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
    return DecomposedFixedPointVector( tom, line );
    end );


#############################################################################
##
#M  FactorGroupTom( <tom>, <nor> ) . . . . . . table of marks of factor group
##
InstallMethod( FactorGroupTom,
    "for a table of marks, and a positive integer",
    [ IsTableOfMarks, IsPosInt ],
    function( tom, nor )
    local marks, subs, sub, pos, pos1, subsf, marksf, facmarks, facsubs,
          members, hom, facgens, facpos, facgroup, elm, result;

    marks:= MarksTom( tom );
    subs:= SubsTom( tom );
    if marks[ nor ][1] <> marks[ nor ][ Length( marks[nor] ) ] then
      Error( "<nor>-th class of subgroups not normal" );
    fi;
    facsubs:= [];
    facmarks:= [];

    # Collect the members of the factor group.
    members:= [];
    for sub in [ nor .. Length( marks ) ] do
      if nor in subs[ sub ] then
        Add( members, sub );
      fi;
    od;

    # Collect the marks of the factor group from the marks of the group.
    for sub in members do
      pos:= Position( subs[sub], nor );
      subsf:= [1];
      marksf:= [ marks[sub][pos] ];
      for elm in [ pos+1 .. Length( subs[ sub ] ) ] do
        pos1:= Position( members, subs[ sub ][ elm ] );
        if IsInt( pos1 ) then
          Add( subsf, pos1 );
          Add( marksf, marks[ sub ][ elm ] );
        fi;
      od;
      Add( facsubs, subsf );
      Add( facmarks, marksf );
    od;

    # Make the object.
    result:= rec( SubsTom  := facsubs,
                  MarksTom := facmarks );

    if HasNormalizersTom(tom) then
      result.NormalizersTom:= List( NormalizersTom( tom ){ members },
                                    x -> Position( members, x ) );
    fi;

    if IsTableOfMarksWithGens( tom ) then

      hom:= NaturalHomomorphismByNormalSubgroupNC( UnderlyingGroup( tom ),
                RepresentativeTom( tom, nor ) );
      facgroup:= ImagesSource( hom );

      #  collect the generators
      subs:= List( members,
                   x -> GeneratorsOfGroup( RepresentativeTom( tom, x ) ) );
      subs:= List( subs, x -> List( x, y -> Image( hom, y ) ) );
      subs:= List( subs, x -> Filtered( x, y -> y <> One( facgroup ) ) );
      facgens:= Union( subs );

      # compute the positions
      facpos:= [];
      for sub in subs do
        pos:= [];
        for elm in sub do
          Add( pos, Position( facgens, elm ) );
        od;
        Add( facpos, pos );
      od;

      result.UnderlyingGroup:= facgroup;
      SetTableOfMarks( facgroup, result );
      result.GeneratorsSubgroupsTom:= [ facgens, facpos ];

    fi;

    ConvertToTableOfMarks( result );
    return result;
    end );


#############################################################################
##
#M  MaximalSubgroupsTom( <tom> )
#M  MaximalSubgroupsTom( <tom>, <sub>)
##
##  Note that we assume that the table of marks has lower triangular shape.
##
InstallMethod( MaximalSubgroupsTom,
    "for a table of marks",
    [ IsTableOfMarks ],
    tom -> MaximalSubgroupsTom( tom, Length( SubsTom( tom ) ) ) );

InstallMethod( MaximalSubgroupsTom,
    "for a table of marks, and a positive integer",
    [ IsTableOfMarks, IsPosInt ],
    function( tom, sub )
    local subs1, s, max, subs;

    subs1:= SubsTom( tom );
    subs:= Difference( subs1[ sub ], [ sub ] );
    max:= [];

    while subs <> [] do
      s:= Maximum( subs );
      Add( max, Position( subs1[ sub ], s ) );
      SubtractSet( subs, subs1[s] );
    od;

    return [ subs1[ sub ]{ max }, NrSubsTom( tom )[ sub ]{ max } ];
    end );


#############################################################################
##
#M  MinimalSupergroupsTom( <tom>, <sub>)
##
InstallMethod( MinimalSupergroupsTom,
    "for a table of marks",
    [ IsTableOfMarks, IsPosInt ],
    function( tom, sub )
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

    return [ sups, nrSups ];
    end );


#############################################################################
##
##  11. Accessing Subgroups via Tables of Marks
##


#############################################################################
##
#M  GeneratorsSubgroupsTom( <tom> )
##
InstallMethod( GeneratorsSubgroupsTom,
    "default method for a table of marks",
    [ IsTableOfMarks ],
    function( tom )
    local sub, gen, pos;

    sub:= List( [ 1 .. Length( OrdersTom( tom ) ) ],
                x -> GeneratorsOfGroup( RepresentativeTom( tom, x ) ) );

    # Form the generators list.
    gen:= Union( sub );

    # Compute the positions.
    pos:= List( sub, l -> List( l, elm -> Position( gen, elm ) ) );

    return [ gen, pos ];
    end );



#############################################################################
##
#M  RepresentativeTom( <tom>, <sub> )
##
InstallMethod( RepresentativeTom,
    "for a table of marks with stored `GeneratorsSubgroupsTom' value",
    [ IsTableOfMarks and HasGeneratorsSubgroupsTom, IsPosInt ],
    function( tom, sub )
    local gens, result;

    if sub = Length( OrdersTom( tom ) ) then
      return UnderlyingGroup( tom );
    fi;

    gens:= GeneratorsSubgroupsTom( tom );
    result:= SubgroupNC( UnderlyingGroup( tom ), gens[1]{ gens[2][ sub ] } );
    SetSize( result, OrdersTom( tom )[ sub ] );

    return result;
    end );

InstallMethod( RepresentativeTom,
    "for a table of marks with stored `StraightLineProgramsTom' value",
    [ IsTableOfMarks and HasStraightLineProgramsTom, IsPosInt ],
    function( tom, sub )
    local gens, subgroup, group;

    if sub = Length( OrdersTom( tom ) ) then
      return UnderlyingGroup( tom );
    fi;

    group:= UnderlyingGroup( tom );
    gens:= StraightLineProgramsTom( tom )[ sub ];
    if IsStraightLineProgram( gens ) then
      gens:= ResultOfStraightLineProgram( gens, GeneratorsOfGroup( group ) );
    else
      gens:= List( gens, x -> ResultOfStraightLineProgram(
                                  x, GeneratorsOfGroup( group ) ) );
    fi;
    subgroup:= SubgroupNC( group, gens );
    SetSize( subgroup, OrdersTom( tom )[ sub ] );

    return subgroup;
    end );


#############################################################################
##
#M  RepresentativeTomByGenerators( <tom>, <sub>, <gens> )
#M  RepresentativeTomByGeneratorsNC( <tom>, <sub>, <gens> )
##
InstallMethod( RepresentativeTomByGenerators,
    [ IsTableOfMarks and HasStraightLineProgramsTom,
      IsPosInt, IsHomogeneousList ],
    function( tom, sub, gens )
    local gr, iso;

    # test <group>
    gr:= UnderlyingGroup( tom );
    iso:= GroupGeneralMappingByImagesNC( gr, GroupByGenerators( gens ),
                                       GeneratorsOfGroup( gr ), gens );
    if not ( IsGroupHomomorphism( iso ) and IsBijective( iso ) ) then
      Info( InfoWarning, 1,
            "the stored generators and the given ones don't define ",
            "an isomorphism" );
      return fail;
    fi;

    return RepresentativeTomByGeneratorsNC( tom, sub, gens );
    end );

InstallMethod( RepresentativeTomByGeneratorsNC,
    [ IsTableOfMarks and HasStraightLineProgramsTom,
      IsPosInt, IsHomogeneousList ],
    function( tom, sub, gens )
    local prog;
    prog:= StraightLineProgramsTom( tom )[ sub ];
    if IsList( prog ) then
      if IsEmpty( prog ) then
        gens:= TrivialSubgroup( UnderlyingGroup( tom ) );
      else
        gens:= GroupByGenerators( List( prog,
                   x -> ResultOfStraightLineProgram( x, gens ) ) );
      fi;
    else
      gens:= ResultOfStraightLineProgram( prog, gens );
      if IsEmpty( gens ) then
        gens:= TrivialSubgroup( UnderlyingGroup( tom ) );
      else
        gens:= GroupByGenerators( gens );
      fi;
    fi;
    SetSize( gens, OrdersTom( tom )[ sub ] );
    return gens;
    end );


#############################################################################
##
##  12. The Interface between Tables of Marks and Character Tables
##


#############################################################################
##
#M  PossibleFusionsCharTableTom( <tbl>, <tom> )   . . . . . .  element fusion
##
InstallMethod( PossibleFusionsCharTableTom,
    "for ordinary character table and table of marks",
    [ IsOrdinaryTable, IsTableOfMarks ],
    function( tbl, tom )
    return PossibleFusionsCharTableTom( tbl, tom, rec() );
    end );


#############################################################################
##
#M  PossibleFusionsCharTableTom( <tbl>, <tom>, <options> )  .  element fusion
##
InstallMethod( PossibleFusionsCharTableTom,
    "for ordinary character table, table of marks, and record",
    [ IsOrdinaryTable, IsTableOfMarks, IsRecord ],
    function( tbl, tom, options )
    local quick,
          approxfus,
          fus,
          ccl,
          G,
          orderstbl,
          orderstom,
          i,
          u,
          flag,
          j, h, hh,
          cycstom,
          cycstbl,
          cycfus,
          classes,
          len,
          ord,
          orb,
          p,
          pow,
          subs,
          ambig,
          ambigim,
          uniques,
          uniquim,
          auttbl,
          stab,
          clean,
          transfer,
          powertbl,
          powertom,
          invcycfus,
          proj,
          invcycstom,
          parameters,
          allfus;

    # Evaluate the optional parameters.
    quick:= IsBound( options.quick ) and options.quick = true;
    if IsBound( options.fusionmap ) then
      approxfus:= options.fusionmap;
    else
      approxfus:= [];
    fi;

    # If `tbl' stores a group whose table of marks is `tom'
    # then use the conjugacy classes of the group.
    if HasUnderlyingGroup( tbl ) and HasUnderlyingGroup( tom )
       and UnderlyingGroup( tbl ) = UnderlyingGroup( tom )
       and TableOfMarks( UnderlyingGroup( tom ) ) = tom then

      Info( InfoTom, 1,
            "computing fusion <tbl> -> <tom> using the stored group" );
      fus:= [];
      ccl:= ConjugacyClasses( tbl );
      G:= UnderlyingGroup( tom );
      orderstom:= OrdersTom( tom );
      for i in [ 1 .. Length( ccl ) ] do
        u:= Group( Representative( ccl[i] ) );
        fus[i]:= First( [ 1 .. Length( orderstom ) ],
                     j -> orderstom[j] = Size( u ) and
                          IsCyclicTom( tom, j ) and
                          IsConjugate( G, u, RepresentativeTom( tom, j ) ) );
        if IsBound( approxfus[i] ) and
           ( ( IsInt( approxfus[i] ) and fus[i] <> approxfus[i] ) or
             ( IsList( approxfus[i] ) and not ( fus[i] in approxfus[i] ) ) ) then
          Info( InfoTom, 1,
                "contradiction to prescribed fusion <tbl> -> <tom>" );
          return [];
        fi;
      od;
      if HasPermutationTom( tom ) then
        fus:= OnTuples( fus, PermutationTom( tom ) );
      fi;
      return [ fus ];

    fi;

    # Use necessary conditions.
    Info( InfoTom, 1,
          "computing fusion(s) <tbl> -> <tom> using nec. conditions" );

    # Get orders of elements.
    orderstbl:= OrdersClassRepresentatives( tbl );

    # Determine cyclic subgroups of the table of marks.
    subs:= SubsTom( tom );
    cycstom:= Filtered( [ 1 .. Length( subs ) ],
                        i -> IsCyclicTom( tom, i ) );

    # Determine cyclic subgroups of the character table.
    # The possible fusions will be determined from this list into the
    # table of marks.
    # In the end, the possible fusions will be composed with the fusion
    # of conjugacy classes into the cyclic subgroups.
    cycstbl:= [];
    cycfus:= [];
    classes:= [ 1 .. NrConjugacyClasses( tbl ) ];
    len:= 0;
    while not IsEmpty( classes ) do
      orb:= ClassOrbit( tbl, classes[1] );
      len:= len + 1;
      cycstbl[ len ]:= orb;
      for i in orb do
        cycfus[i]:= len;
      od;
      SubtractSet( classes, orb );
    od;

    # First check of compatibility.
    if len <> Length( cycstom ) then
      Info( InfoTom, 1,
            "PossibleFusionsCharTableTom: incompat. no. of cyc. subgroups" );
      return [];
    fi;

    # Collect candidates for each class.
    Info( InfoTom, 1,
          "PossibleFusionsCharTableTom: checking element orders" );
    orderstbl:= List( cycstbl, orbit -> orderstbl[ orbit[1] ] );
    orderstom:= OrdersTom( tom );
    fus:= [];
    for i in [ 1 .. Length( orderstbl ) ] do
      fus[i]:= Filtered( cycstom, j -> orderstbl[i] = orderstom[j] );
      if IsEmpty( fus[i] ) then
        Info( InfoTom, 1,
              "PossibleFusionsCharTableTom: incompat. element orders",
              " at class ", i );
        return [];
      elif Length( fus[i] ) = 1 then
        fus[i]:= fus[i][1];
      fi;
    od;

    # Use `approxfus'.
    flag:= MeetMaps( fus, approxfus );
    if flag <> true then
      Info( InfoTom, 2,
            "PossibleFusionsCharTableTom: possible maps incompatible with ",
            "<approxfus> at class ", flag );
      return [];
    fi;

    # Maybe the map is already unique.
    if quick and IsRowVector( fus ) then
      return [ CompositionMaps( fus, cycfus ) ];
    fi;

    # Check centralizers.
    Info( InfoTom, 1,
          "PossibleFusionsCharTableTom: checking centr. orders" );
    for i in [ 1 .. Length( fus ) ] do
      if ( not quick ) or IsList( fus[i] ) then
        h:= Length( cycstbl[i] )
              * SizesConjugacyClasses( tbl )[ cycstbl[i][1] ]
              / Phi( orderstbl[i] );
        if IsList( fus[i] ) then
          hh:= Filtered( fus[i], j -> LengthsTom( tom )[j] = h );
        elif LengthsTom( tom )[ fus[i] ] = h then
          hh:= [ fus[i] ];
        else
          hh:= [];
        fi;
        if IsEmpty( hh ) then
          Info( InfoTom, 1,
                "PossibleFusionsCharTableTom: incompat. element orders" );
          return [];
        elif Length( hh ) = 1 then
          fus[i]:= hh[1];
        else
          fus[i]:= hh;
        fi;
      fi;
    od;

    # We are looking for a bijection of cyclic subgroups,
    # so unique images must not occur in lists of possible images.
    # A sort of converse is that an image that occurs only in *one*
    # list of possibilities is the unique image from that list.
    uniques:= Filtered( [ 1 .. Length( fus ) ], i -> IsInt( fus[i] ) );
    uniquim:= SSortedList( fus{ uniques } );
    ambig:= Difference( [ 1 .. Length( fus ) ], uniques );
    ambigim:= Difference( cycstom, uniquim );

    clean:= function( fus, uniques, uniquim, ambig, ambigim )
      local newunique, i, diff, numb, pos;

      repeat

        newunique:= [];

        # Remove unique images from lists of possible images.
        for i in ambig do
          if IsInt( fus[i] ) then
            Add( newunique, i );
          else
            diff:= Difference( fus[i], uniquim );
            if IsEmpty( diff ) then
              return false;
            elif Length( diff ) = 1 then
              fus[i]:= diff[1];
              AddSet( newunique, i );
              AddSet( uniquim, fus[i] );
            elif diff <> fus[i] then
              fus[i]:= diff;
            fi;
          fi;
        od;

        if not IsEmpty( newunique ) then
          SubtractSet( ambig, newunique );
          UniteSet( uniques, newunique );
          UniteSet( uniquim, fus{ newunique } );
          SubtractSet( ambigim, fus{ newunique } );
        fi;

        # Check whether ambiguous images occur only once.
        for i in ambigim do
          numb:= Number( ambig, j -> IsList( fus[j] ) and i in fus[j] );
          if   numb = 0 then
            return false;
          elif numb = 1 then
            pos:= First( ambig, j -> IsList( fus[j] ) and i in fus[j] );
            fus[ pos ]:= i;
            AddSet( newunique, pos );
            AddSet( uniquim, i );
          fi;
        od;

        if not IsEmpty( newunique ) then
          SubtractSet( ambig, newunique );
          UniteSet( uniques, newunique );
          UniteSet( uniquim, fus{ newunique } );
          SubtractSet( ambigim, fus{ newunique } );
        fi;

      until IsEmpty( newunique );

      return true;
    end;

    # Maybe the map is already unique.
    if not clean( fus, uniques, uniquim, ambig, ambigim ) then
      Info( InfoTom, 1,
            "PossibleFusionsCharTableTom: incompatibility in consequences" );
      return [];
    elif quick and IsEmpty( ambig ) then
      return [ CompositionMaps( fus, cycfus ) ];
    fi;

    # Check power maps against incidence.
    Info( InfoTom, 1,
          "PossibleFusionsCharTableTom: checking power maps" );
    powertbl:= ShallowCopy( ComputedPowerMaps( tbl ) );
    powertom:= [];
    invcycfus:= InverseMap( cycfus );
    for p in [ 2 .. Length( powertbl ) ] do
      if IsBound( powertbl[p] ) and IsPrimeInt( p )
                                and Size( tbl ) mod p = 0 then

        # Rewrite the `p'-th power map of `tbl'.
        powertbl[p]:= CompositionMaps( cycfus,
                          CompositionMaps( powertbl[p], invcycfus ) );

        # Construct the `p'-th power map of cyclic subgroups of `tom'.
        pow:= [];
        for i in [ 1 .. Length( cycstom ) ] do
          ord:= orderstom[ cycstom[i] ];
          if ord mod p = 0 then
            h:= ord / p;
            hh:= Filtered( subs[ cycstom[i] ], j -> orderstom[j] = h );
            Assert( 1, Length( hh ) = 1 );
            pow[ cycstom[i] ]:= hh[1];
          else
            pow[ cycstom[i] ]:= cycstom[i];
          fi;
        od;
        powertom[p]:= pow;

        transfer:= TransferDiagram( powertbl[p], fus, pow );
        if   transfer = fail then

          Info( InfoTom, 1,
                "PossibleFusionsCharTableTom: incompatible power maps" );
          return [];

        elif not IsEmpty( transfer.impbetween ) then

          # Maybe the map is already unique.
          if not clean( fus, uniques, uniquim, ambig, ambigim ) then
            Info( InfoTom, 1,
                  "PossibleFusionsCharTableTom: incompat. in consequences" );
            return [];
          elif quick and IsRowVector( fus ) then
            return [ CompositionMaps( fus, cycfus ) ];
          fi;

        fi;

      fi;
    od;

    # Break symmetries where possible with the character table.
    Info( InfoTom, 1,
          "PossibleFusionsCharTableTom: checking automorphisms of <tbl>" );
    auttbl:= Action( AutomorphismsOfTable( tbl ), cycstbl, OnSets );
    stab:= auttbl;
    for i in ShallowCopy( ambig ) do
      if IsList( fus[i] ) then
        orb:= Set( Orbit( stab, i ) );
        if     1 < Length( orb )
           and ForAll( orb, x -> fus[x] = fus[i] )
           and ForAll( ambig, x -> ( x in orb )
                          or IsEmpty( Intersection( fus[x], fus[i] ) ) ) then

          fus[i]:= fus[i][1];
          stab:= Stabilizer( stab, i );
          if not clean( fus, uniques, uniquim, ambig, ambigim ) then
            Info( InfoTom, 1,
                  "PossibleFusionsCharTableTom: incompat. in consequences" );
            return [];
          elif IsTrivial( stab ) then
            break;
          fi;

        fi;
      fi;
    od;

    # Maybe the map is already unique.
    if quick and IsRowVector( fus ) then
      Info( InfoTom, 1,
            "PossibleFusionsCharTableTom: ",
            "map is unique up to table autom." );
      return List( OrbitFusions( auttbl, fus, Group( () ) ),
                   map -> CompositionMaps( map, cycfus ) );
    fi;

    # Check power maps again.
    Info( InfoTom, 1,
          "PossibleFusionsCharTableTom: checking power maps again" );
    for p in [ 2 .. Length( powertom ) ] do
      if IsBound( powertom[p] ) then

        transfer:= TransferDiagram( powertbl[p], fus, powertom[p] );
        if   transfer = fail then
          Info( InfoTom, 1,
                "PossibleFusionsCharTableTom: incompatible power maps" );
          return [];
        elif not IsEmpty( transfer.impbetween ) then

          # Maybe the map is already unique.
          if not clean( fus, uniques, uniquim, ambig, ambigim ) then
            Info( InfoTom, 1,
                  "PossibleFusionsCharTableTom: incompat. in consequences" );
            return [];
          elif quick and IsRowVector( fus ) then
            Info( InfoTom, 1,
                  "PossibleFusionsCharTableTom: ",
                  "map is unique up to table autom." );
            return List( OrbitFusions( auttbl, fus, Group( () ) ),
                         map -> CompositionMaps( map, cycfus ) );
          fi;

        fi;

      fi;
    od;

    # Start a backtrack search.
    Info( InfoTom, 1,
          "PossibleFusionsCharTableTom: starting a backtrack search" );

    proj:= ProjectionMap( cycfus );
    invcycstom:= InverseMap( cycstom );
    for i in [ 1 .. Length( powertom ) ] do
      if IsBound( powertom[i] ) then
        powertom[i]:= CompositionMaps( invcycstom,
                          CompositionMaps( powertom[i], cycstom ) );
      fi;
    od;
    parameters:= rec(
        maxlen:= 10,
        contained:= function( tbl, chars, paracharacter )
            return List( ContainedPossibleCharacters( tbl, chars,
                             CompositionMaps( paracharacter, cycfus ) ),
                         x -> x{ proj } );
            end,
        minamb:= 1,
        maxamb:= infinity,
        quick:= quick,
        testdec:= function( tbl, subchars, restricted )
            return NonnegIntScalarProducts( tbl, subchars,
                       CompositionMaps( restricted, cycfus ) );
            end,
        powermaps:= powertom,
        subpowermaps:= powertbl );

    fus:= FusionsAllowedByRestrictions( tbl, tom, Irr( tbl ),
              PermCharsTom( cycstom, tom ),
              CompositionMaps( invcycstom, fus ),
              parameters );
    fus:= List( fus, map -> cycstom{ map{ cycfus } } );

    if IsEmpty( fus ) then
      Info( InfoTom, 1,
            "PossibleFusionsCharTableTom: no solution" );
      return fus;
    fi;

    # Apply table automorphisms in order to get all possible fusions.
    auttbl:= AutomorphismsOfTable( tbl );
    allfus:= Concatenation( List( fus,
                 ffus -> OrbitFusions( auttbl, ffus, Group( () ) ) ) );
    fus:= RepresentativesFusions( auttbl, fus, Group( () ) );
    if Length( allfus ) = 1 then
      Info( InfoTom, 1,
            "PossibleFusionsCharTableTom: fusion map is unique" );
    elif Length( fus ) = 1 then
      Info( InfoTom, 1,
            "PossibleFusionsCharTableTom: ",
            "fusion map is unique up to table autom." );
    else
      Info( InfoTom, 1,
            "PossibleFusionsCharTableTom: ",
            Length( fus ), " orbits under table autom." );
    fi;

    return allfus;
    end );


#############################################################################
##
#M  FusionCharTableTom( <tbl>, <tom> )  . . . . . . . . . . .  element fusion
##
##  The case of a fusion between a library character table
##  and a library table of marks is dealt with in a method installed in the
##  file `pkg/tomlib/gap/tmadmin.tmi'.
##
InstallMethod( FusionCharTableTom,
    "for ordinary character table and table of marks",
    [ IsOrdinaryTable, IsTableOfMarks ],
    function( tbl, tom )
    local fus;

    fus:= PossibleFusionsCharTableTom( tbl, tom );
    if Length( fus ) = 1 then
      return fus[1];
    else
      Info( InfoTom, 1, "fusion is not unique, possibilities are ", fus );
      return fail;
    fi;
    end );


#############################################################################
##
#M  PermCharsTom( <fus>, <tom> )  . . . . . .  extract permutation characters
#M  PermCharsTom( <tbl>, <tom> )  . . . . . .  extract permutation characters
##
InstallMethod( PermCharsTom,
    "for explicit fusion map and table of marks",
    [ IsList, IsTableOfMarks ],
    function( fus, tom )
    local pc, i, j, line, marks, subs;

    pc:= [];

    marks:= MarksTom( tom );
    subs:= SubsTom( tom );

    # Loop over the classes of subgroups.
    for i in [ 1 .. Length( subs ) ] do

      # Initialize the permutation character.
      line:= List( fus, x -> 0 );

      # Extract the values.
      for j in [ 1 .. Length( fus ) ] do
        if fus[j] in subs[i] then
          line[j]:= marks[i][ Position( subs[i], fus[j] ) ];
        fi;
      od;
      pc[i]:= line;

    od;

    return pc;
    end );

InstallMethod( PermCharsTom,
    "for character table and table of marks",
    [ IsOrdinaryTable, IsTableOfMarks ],
    function( tbl, tom )
    local fus;

    fus:= FusionCharTableTom( tbl, tom );
    if fus = fail then
      Info( InfoTom, 1,
            "the fusion map <fus> map is not uniquely determined!" );
      return fail;
    fi;
    return List( PermCharsTom( fus, tom ), chi -> Character( tbl, chi ) );
    end );


#############################################################################
##
##  13. Generic Construction of Tables of Marks
##


#############################################################################
##
#M  TableOfMarksCyclic( <n> ) . . . . . . .  table of marks of a cyclic group
##
InstallMethod( TableOfMarksCyclic,
    "for a positive integer",
    [ IsPosInt ],
    function( n )
    local obj, progs, subs, marks, classNames, i, j, divs, index, group;

    # Initialize, \ldots
    divs:= DivisorsInt(n);
    progs:= [];
    subs:= [];
    marks:= [];
    classNames:=[];

    # \ldots construct generators for each subgroup (divisor), \ldots
    for i in [ 1 .. Length( divs ) ] do
      classNames[i]:= String( divs[i] );
      ConvertToStringRep( classNames[i] );
      if i = 1 then
        progs[i]:= StraightLineProgram( [ [] ] );
      else
        progs[i]:= StraightLineProgram( [ [ [ 1, n/divs[i] ] ] ] );
      fi;
      subs[i]:= [];
      marks[i]:= [];
      index:= n / divs[i];
      for j in [ 1 .. i ] do
        if divs[i] mod divs[j] = 0 then
          Add( subs[i], j );
          Add( marks[i], index );
        fi;
      od;
    od;

    # \ldots add additional components, \ldots
    group:= CyclicGroup( n );
    SetSize(group,n);
    SetName(group,Concatenation("C",String(n)));

    # \ldots and finally create the object and add attribute values.
    obj:= rec( Identifier                := Name( group ),
               SubsTom                   := subs,
               MarksTom                  := marks,
               NormalizersTom            := ListWithIdenticalEntries(n,n),
               DerivedSubgroupsTomUnique := ListWithIdenticalEntries(n,1),
               UnderlyingGroup           := group,
               StraightLineProgramsTom   := progs,
               ClassNamesTom             := classNames );
    ConvertToTableOfMarks( obj );
    SetTableOfMarks( group, obj );

    # Return the result.
    return obj;
    end );


#############################################################################
##
#M  TableOfMarksDihedral( <m> )  . table of marks of the dihedral group $D_m$
##
InstallMethod( TableOfMarksDihedral,
    "for a positive integer",
    [ IsPosInt ],
    function( m )
    local i, j, divs, n, name, marks, subs, type, nrs, pt, d, construct, ord,
          tom;

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
    end ] ];

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

    # Make the object.
    tom:= rec( Identifier      := Concatenation( "dihedral group( ",
                                                 String( m ), " )" ),
               SubsTom         := subs,
               MarksTom        := marks,
               ClassNamesTom   := name );
    ConvertToTableOfMarks( tom );

    return tom;
    end );


#############################################################################
##
#M  TableOfMarksFrobenius( <p>, <q> ) . .  table of marks of Frobenius groups
##
InstallMethod( TableOfMarksFrobenius,
    "tom of a Frobenius group",
    [ IsPosInt, IsPosInt ],
    function( p, q )
    local tom, classNames,marks, subs, normalizers,
          derivedSubgroups,i, j, n, ind, divs;

    if not IsPrimeInt( p ) then
      Error( "not yet implemented" );
    elif (p-1) mod q <> 0 then
      Error( "not Frobenius" );
    fi;

    classNames:= [];
    subs:= [];
    marks:= [];
    normalizers:= [];
    derivedSubgroups:= [];
    n:= p*q;
    divs:= DivisorsInt( n );

    for i in [ 1 .. Length( divs ) ] do
      ind:= n / divs[i];
      subs[i]:= [ 1 ];
      marks[i]:= [ ind ];
      if ind mod p = 0 then
        # d
        classNames[i]:= String( divs[i] );
        ConvertToStringRep( classNames[i] );
        derivedSubgroups[i]:= 1;
        if i = 1 then
          normalizers[i]:= Length( divs );
        else
          normalizers[i]:= Position( divs, q );
        fi;
        for j in [ 2 .. i ] do
          if marks[j][1] mod ind = 0 then
            Add( subs[i], j );
            Add( marks[i], ind/p );
          fi;
        od;
      else
        # p:d
        classNames[i]:= Concatenation( String(p), ":", String( divs[i]/p ) );
        ConvertToStringRep( classNames[i] );
        derivedSubgroups[i]:= Position( divs, p );
        normalizers[i]:= Length( divs );
        for j in [ 2 .. i ] do
          if marks[j][1] mod ind = 0 then
            Add( subs[i], j );
            Add( marks[i], ind );
          fi;
        od;
      fi;
    od;

    # Make the object and add attributes.
    tom:= rec( Identifier                :=
                   Concatenation( "Frobenius group( ",
                                  String( p ), ", ", String( q ), " )" ),
               SubsTom                   := subs,
               MarksTom                  := marks,
               NormalizersTom            := normalizers,
               DerivedSubgroupsTomUnique := derivedSubgroups,
               ClassNamesTom             := classNames );
    ConvertToTableOfMarks( tom );

    return tom;
    end );
