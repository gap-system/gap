#############################################################################
##
#W  monotran.gi           GAP library                    Robert Arthur
##
#H  @(#)$Id: monotran.gi,v 1.4 1999/04/29 10:25:30 roberta Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the implementation of transformation monoid algorithms.
##
##  The theory behind these algorithms is developed in 
##  
##  [LPRR1] S. A.   Linton, G.  Pfeiffer, E.  F.  Robertson, and N.   Ruskuc,
##  Groups  and actions in  transformation semigroups,  to appear  in Math Z.
##  (1997).
##
##  The algorithms themselves are described in
##
##  [LPRR2] S. A.   Linton, G.  Pfeiffer, E.  F.  Robertson, and N.   Ruskuc,
##  Computing transformation semigroups, (1996), in preparation.
##
Revision.monotran_gi :=
    "@(#)$Id: monotran.gi,v 1.4 1999/04/29 10:25:30 roberta Exp $";

#############################################################################
##
#M  Size( <monoid> )  . . . . . . . . . . . . Size of a transformation monoid
##
InstallMethod(Size, "Size of a transformation monoid", true,
    [IsTransformationSemigroup],0,
function(S)

    # Trigger the tructure calculations.
    GreensRClasses(S);

    # Calculate the size.
    return List(OrbitClassesTransSemi(S), Size)
            * List(RCRepsTransSemi(S), Length);

end);

#############################################################################
##
#M  <x> in <M>  . . . . . . . . . . . . . . . . . . . . . . . membership test
##
##  A transformation <x> lies in a transformation monoid <M> if it has the
##  same degree as <M> and if it is contained in one of the R classes of <M>.
##
InstallMethod(\in, "trans in monoid", true,
    [IsTransformation, IsTransformationSemigroup], 0,
function(x, M)

    local i, j, k, pos, R, ker;

    # check degree
    if DegreeOfTransformation(x) <> DegreeOfTransformationSemigroup(M) then
        return false;
    fi;

    # unfold monoid, if necessary
    GreensRClasses(M);

    # check image
    k:= RankOfTransformation(x);
    pos:= Position(ImagesTransSemi(M)[k], ImageSetOfTransformation(x));
    if pos = fail then
        return false;
    fi;

    # locate representing R class.
    j:= ImagePosTransSemi(M)[k][pos];
    R:= OrbitClassesTransSemi(M)[j];

    # check kernels
    ker:= KernelOfTransformation(x);
    for i in [1..Length(KernelsTransSemi(M)[j])] do
        if KernelsTransSemi(M)[j][i] = ker then
            if LTransTransSemi(M)[j][i] * x in R then
                return true;
            fi;
        fi;
    od;

    return false;
end);


#############################################################################
##
#M  AsSSortedList( <M> )  . . . . . . . . . . . . . . . . . . . . .  elements
##
InstallMethod(AsSSortedList, "elements of transformation monoid", true,
  [IsTransformationSemigroup],0,
    M-> AsSSortedList(Concatenation(List(GreensRClasses(M), AsSSortedList))));

#############################################################################
##
#F  TransPermLeftQuoTrans( <t1>, <t2> )
##
##  For two transformations, <t1> and <t2> with the same kernel
##  and image, this returns the permutation induced by <t1>^-1 * <t2> on the
##  set Image( <t1> )
##  Note (roberta) I do not quite see exactly why we do things this way,
##  but shall keep it here pending discussion
##
BindGlobal("TransPermLeftQuoTrans", function(l, r)
    local n, alpha, perm;

    # construct cross section of kernel.
    n:= Length(ImageListOfTransformation(l));    alpha:= [];
    alpha{ImageListOfTransformation(l)}:= [1..n];    # (!)
    alpha:= Set(alpha);

    # calculate induced permutation (!!)
    perm:= [1..n];
    perm{ImageListOfTransformation(l){alpha}}:= 
            ImageListOfTransformation(r){alpha};

    # return the permutation.
    return PermList(perm);
end);



#############################################################################
##
#M  GenSchutzenbergerGroup( <R> )  . . . . . . . . . . . . unfold an r class
##
InstallMethod(GenSchutzenbergerGroup, "for an R class", true,
    [IsGreensRClass and IsTransformationCollection], 0,
function(R)
    local img, orbit, i, j, back, rep, s, pnt, new, a, n, set, sets,
        perms, gens;

    # determine the starting point
    rep:= Representative(R); img:= ImageSetOfTransformation(rep);

    # form the weak (but graded) orbit
    orbit:= [img];    sets:= [img];    n:= Size(img);    i:= 0;    back:= [[]];
    gens:= GeneratorsOfSemigroup(Parent(R));
    
    for pnt in orbit do

        # keep track of 'pnt'
        i:= i+1;

        # loop over the generators.
        for s in gens do
            new:= OnTuples(pnt, s);    set:= Set(new);

            # discard points of lower grading
            if Size(set) = n then

                j:= Position(sets, set);

                # install new point if necessary.
                if j = fail then
                    Add(orbit, new);    Add(sets, set);    Add(back, []);
                    j:= Length(orbit);
                fi;

                # remember predecessor.
                AddSet(back[j], i);

            fi;
        od;
    od;

    # form the transitive closure.
    n:= Length(orbit);
    for j in [1..n] do
        for i in [1..n] do
            if j in back[i] then
                UniteSet(back[i], back[j]);
            fi;
        od;
    od;

    # select strong orbit of point 1.
    AddSet(back[1], 1);
    orbit:= orbit{back[1]};    sets:= sets{back[1]};

    # find multipliers
    # Note (roberta) I am not sure about these - we are using permutations
    # for this, though strictly speaking they should be partial bijections.
    perms:= [];
    for pnt in orbit do
        Add(perms, MappingPermListList(pnt, img));
    od;

    # determine Schutz grp.
    new:= [];
    for i in [1..Length(sets)] do
        pnt:= sets[i];
        for s in gens do
            j:= Position(sets, OnSets(pnt, s));
            if j <> fail then
                Add(new, TransPermLeftQuoTrans(rep, rep/perms[i] * 
                    (s*perms[j])));
            fi;
        od;
    od;

    # install the attributes.
    if not HasSchutzImages(R) then
        SetSchutzImages(R, sets);
    fi;
    if not HasSchutzRMults(R) then
        SetSchutzRMults(R, perms);
    fi;

    # return the group.
    return Group(Set(new), ());
end);

#############################################################################
##
#M  Size( <rclass> )  . . . . . . . . . . . . . . . . . . . . . . . . .  size
##
##  We find the size of the schutzenberger group by group means, and then
##  use this to calculate the size of the RClass.
##
InstallMethod(Size, "for rclasses of trans semigrps", true,
    [IsGreensRClass and IsTransformationCollection], 0,
function(R)

    local schutz;

    schutz:= GenSchutzenbergerGroup(R);    # Will set attributes.
    return Size(schutz) * Length(SchutzImages(R));

end);

#############################################################################
##
#M  AsSSortedList( <rclass> )  . . . . . . . . . . . . . . .  set of elements
##
InstallMethod( AsSSortedList, "for r class of trans. semigrps", true,
    [IsGreensRClass and IsTransformationCollection], 0,
function(R)

    local m, x, elts, grp;

    grp:= GenSchutzenbergerGroup(R);    # Will set attributes.
    x:= Representative(R);

    elts:= [];
    for m in SchutzRMults(R) do
        Append(elts, x * (AsSSortedList(grp) * m^-1));
    od;

    return AsSSortedList(elts);
end);

#############################################################################
##
#M  <trans> in <rclass> . . . . . . . . . . . . . . . . . . . . . . inclusion
##
InstallMethod(\in, "transformation in rclass", true,
    [IsTransformation, IsGreensRClass and IsTransformationCollection], 0,
function(x, R)

    local i, rep, grp;

# some preliminary checks

    rep:= Representative(R);
    if RankOfTransformation(x) <> RankOfTransformation(rep) or
            KernelOfTransformation(x) <> KernelOfTransformation(rep) then
        return false;
    fi;

    grp:= GenSchutzenbergerGroup(R);

    i:= Position(SchutzImages(R), ImageSetOfTransformation(x));
    if i = fail then
        return false;
    fi;

    return TransPermLeftQuoTrans(rep, x * SchutzRMults(R)[i]) in grp;
end);

#############################################################################
##
#M  GreensRClasses( <S> )
##
##  Returns the list of equivalence classes of Green's R relation over a
##  transformation monoid <S>.
##
##  The algorithm given in [LPRR2] works for transformation *monoids*.
##  However, given a semigroup without identity, we can adjoin the identity
##  transformation, run through the algorithm, and return all but the
##  (singleton) group R class.
##
##  This is essentially an orbit algorithm - starting with the identity,
##  we repeatedly multiply on the left, and test elements for membership
##  in a list of r classes so far.   However, due to [LPRR2], we speed
##  up calculation by only calculating the generalised Schutzenberger group
##  for r classes whose list of image sets has not been considered before.
##
InstallMethod(GreensRClasses,
    "for greens r relation over a transformation semigroup", true,
    [IsTransformationSemigroup], 0,
function( S )

    local   R,			# The R Relation
			M,          # If IsMonoid(S) then S, otherwise Monoid(S).
            rClasses,   # A list of R classes with distinct images.
            lTrans,     # Given an R class R with image I \in images, this 
                        # is a list which provides a translation x such that
                        # x.R \in rClass.
            rReps,      # List of representatives for *all* r classes found
                        # so far, grouped by rClasses.
            images,     # A list of distinct images found in the sg, listed
                        # first by rank.
            class,      # A pointer which takes us from images->rClasses
            n,          # DegreeOfSemigroup(S).
            one,        # One(M).
            gens,       # GeneratorsOfMonoid(M).
            orb,        # orbit of elements
            x,          # current orbit element
            img,        # ImageOfTransformation(x)
            s,          # current generator
            rcl,        # current r class
            k,          # RankOfTransformation(x)
            i,          # loop counter
            j,          # loop counter
            pos,        # Position pointer
            ker,        # Kernel of current element
            kernels,    # list of kernels for each element of images
            new;        # boolean - do we have a new R class?

	R:= GreensRRelation(S);

    # initialise
    n:= DegreeOfTransformationSemigroup(S);

    # do we have an identity?
#    if IsTransformationMonoid(S) then
#        M:= AsMonoid(S);
#    else
#        M:= MonoidByGenerators(GeneratorsOfSemigroup(S));
#    fi;

#    one:= One(M);
#    gens:= GeneratorsOfMonoid(M);
    gens:= GeneratorsOfSemigroup(S);
    one:= One(gens[1]);
    images:= List([1..n], x->[]);    # one "box" for each possible rank.
    class:= List([1..n], x->[]);     # ditto
    rClasses:= [];  lTrans:= [];  rReps:= [];  kernels:= [];
#    orb:= [one];
	orb:= ShallowCopy(GeneratorsOfSemigroup(S));

    #loop over the orbit
    for x in orb do

        # locate the image
        img:= ImageSetOfTransformation(x);  k:= Size(img);
        j:= Position(images[k], img);

        # if fail, we have a new image - create new element of rClasses
        if j = fail then
            rcl:= EquivalenceClassOfElementNC(R, x);
            Size(rcl);    # calculate and store all necessary attributes
            Add(rClasses, rcl);
            Add(lTrans, [one]);        # r\in rClasses, so no trans necessary.
            Add(rReps, [x]);
            Add(kernels, [KernelOfTransformation(x)]);
            Append(images[k], SchutzImages(rcl));
            j:= Length(rClasses);

            # all elements with image in r's list of accessible images
            # should now point to r.
            Append(class[k], List(SchutzImages(rcl), x->j));

            # install descendants in queue for orbit alg.
            for s in gens do
                Add(orb, s*x);
            od;
        else        # We have already found this image.

            pos:= class[k][j];
            rcl:= rClasses[pos];    # find the canonical rclass with required
                                    # images.

            # Adjust the transformation such that img x = img Rep(rcl).
            # C should get rid of 'Position' call here!
            x:= x * SchutzRMults(rcl)[Position(SchutzImages(rcl), img)];

            # run through all known r classes with given images to see
            # whether this is a new class
            ker:= KernelOfTransformation(x); new:= true;
            for i in [1..Length(kernels[pos])] do
                if new and ker = kernels[pos][i] 
                        and lTrans[pos][i] * x in rcl  then
                    new:= false;
                fi;
            od;

            if new then        # we indeed do have a new class.

                # remember representative.
                Add(rReps[pos], x);

                # construct new lTrans (!)
                Add(lTrans[pos], Transformation(List([1..n],
                    i->Position(ImageListOfTransformation(x),
                    i^Representative(rcl)))));

                Add(kernels[pos], ker);

                # install descendants in the queue
                for s in gens do
                    Add(orb, s*x);
                od;
            fi;
        fi;
    od;

    # If this is not a monoid, then we wish to discard all information
    # about rank n classes.   We must be careful to maintain all pointers...

#    if not IsTransformationMonoid(S) then
#        images[n]:= [];
#        class[n]:= [];

#        for i in [1..Length(class)] do
#            for j in class[i] do
#                class[i][j]:= class[i][j] - 1;
#            od;
#        od;

#        i:= Length(rClasses);
#        SetImagesTransSemi(S, images);
#        SetImagePosTransSemi(S, class);
#        SetKernelsTransSemi(S, kernels{[1..i-1]});
#        SetRCRepsTransSemi(S, rReps{[1..i-1]});
#        SetLTransTransSemi(S, lTrans{[1..i-1]});
#        SetOrbitClassesTransSemi(S, rClasses{[1..i-1]});

        # Unfold the rReps, and return list of classes

#        orb:= [];
#        for j in [1..i-1] do
#            for class in rReps[j] do
#                class:= EquivalenceClassOfElementNC(R, class);
#                SetGenSchutzenbergerGroup(class, 
#                    GenSchutzenbergerGroup(rClasses[j]));
#                SetSchutzImages(class, SchutzImages(rClasses[j]));
#                SetSchutzRMults(class, SchutzRMults(rClasses[j]));
#                Add(orb, class);
#            od;
#        od;
#        return orb;
#    fi;

    # We actually do have a monoid, so we can return it.
    SetImagesTransSemi(S, images);
    SetImagePosTransSemi(S,class);
    SetKernelsTransSemi(S, kernels);
    SetRCRepsTransSemi(S, rReps);
    SetLTransTransSemi(S, lTrans);
    SetOrbitClassesTransSemi(S, rClasses);

    # Unfold the rReps, and return list of classes

    orb:= [];
    for j in [1..Length(rClasses)] do
        for class in rReps[j] do
            class:= EquivalenceClassOfElementNC(R, class);
            SetGenSchutzenbergerGroup(class, 
                GenSchutzenbergerGroup(rClasses[j]));
            SetSchutzImages(class, SchutzImages(rClasses[j]));
            SetSchutzRMults(class, SchutzRMults(rClasses[j]));
            Add(orb, class);
        od;
    od;
    return orb;
end);

#############################################################################
##
#M  GreensHClasses <rclass> )
##
##  Enumerates the H classes of a particular R class
##
InstallMethod(GreensHClasses, "hclasses of rclass", true,
    [IsGreensRClass and IsTransformationCollection], 0,
function(R)

    local H, S, D, x, c, d, m, classes, new;

	H:= GreensHRelation(Parent(R));

    # initialise
    classes:= [];
    x:= Representative(R);
	D:= EquivalenceClassOfElementNC(GreensDRelation(S), x);
	Size(D);		# calculate structural information

	for c in SchutzRCosets( D ) do
		for m in SchutzRMults(R) do
			d:= c/m;
			new:= EquivalenceClassOfElementNC(GreensHRelation(S), x*d);
			Add(classes, new);
		od;
	od;

	return classes;
end);

############################################################################
############################################################################
##                                                                        ##
##                        LClass Operations                               ##
##                                                                        ##
############################################################################
############################################################################


#############################################################################
##
#M  SchutzenbergerGroup( <lclass> ) . . . . . . . . . . . .  unfold an lclass
##
InstallMethod(GenSchutzenbergerGroup, "for lclass of trans semi", true,
    [IsGreensLClass and IsTransformationCollection], 0,
function(L)

    local ker, orbit, i, j, back, s, pnt, new, a, n, set, sets, relts,
    gens, img, rep, newker, OnTuplesOfSetsAntiAction;

	#########################################################################
    ##
    #F  OnTuplesOfSetsAntiAction( <tup>, <s> )  . . . . anti action
    ##
    OnTuplesOfSetsAntiAction:= function(tup, s)

        return List(tup, x->Union(List(AsSet(x), 
            y->PreimagesOfTransformation(s, y))));
    end;
    #########################################################################
    ##
    ##  FUNCTION PROPER
    ##
    #########################################################################

    # determine starting point
    rep:= Representative(L);  
    ker:= ShallowCopy(EquivalenceRelationPartition(
        KernelOfTransformation(rep)));

    # form the (weak, but graded) orbit
    orbit:= [ker];  sets:= [ker]; n:= Size(ker); i:= 0; back:= [[]];
    gens:= GeneratorsOfSemigroup(Parent(L));

    # we need the singleton kernel classes to be present:
    n:= DegreeOfTransformation(rep);
    set:= Union(ker);
    for j in [1..n] do
        if not j in set then
            AddSet(ker, [j]);
        fi;
    od;

    n:= Size(ker);
    gens:= GeneratorsOfSemigroup(Parent(L));

    for pnt in orbit do

        # keep track of position of 'pnt'
        i:= i+1;

        # loop over generators
        for s in gens do
            new:= OnTuplesOfSetsAntiAction(pnt, s);
            set:= AsSet(new);

            # discard points of lower grading
            if not [] in set then

                j:= Position(sets, set);
                
                # install new point if necessary
                if j = fail then
                    Add(orbit, new); Add(sets, set); Add(back, []);
                    j:= Length(orbit);
                fi;

                # remember predecessor
                AddSet(back[j], i);
            fi;
        od;
    od;

    # form the transitive closure
    n:= Length(orbit);
    for j in [1..n] do
        for i in [1..n] do
            if j in back[i] then
                UniteSet(back[i], back[j]);
            fi;
        od;
    od;

    # select strong orbit of point 1.
    AddSet(back[1], 1);
    orbit:= orbit{back[1]}; sets:= sets{back[1]};

    # find multipliers
    relts:= [];
    for pnt in orbit do
        new:= [];
        for i in [1..Length(ker)] do
            new{ker[i]}:= List(ker[i], x->pnt[i]);
        od;
        Add(relts, BinaryRelationByListOfImages(new));
    od;

    # determine Schutz group.
    new:= [];
    for i in [1..Length(sets)] do
        pnt:= sets[i];
        for s in gens do
#            Error("Break code");
            newker:= OnTuplesOfSetsAntiAction(pnt, s);
            newker:= Set(Filtered(newker, x -> x <> []));
            j:= Position(sets, newker);
            if j <> fail then
                Add(new, TransPermLeftQuoTrans(rep,
                    TransformationRelation(relts[j] * 
                        (s * TransformationRelation(
                            InverseGeneralMapping(relts[i]) * rep)))));
            fi;
        od;
    od;

    SetSchutzKernels(L, sets);
    SetSchutzLMults(L, relts);

    # return the group
    return Group(Set(new), ());
end);

#############################################################################
##
#M  Size( <lclass> )  . . . . . . . . . . . . . . . . . . . . . . . . .  size
##
InstallMethod(Size, "size of lclass", true,
    [IsGreensLClass and IsTransformationCollection], 0,
function(L)
    local s;

    s:= Size(GenSchutzenbergerGroup(L));
    return s * Length(SchutzKernels(L));
end);


#############################################################################
##
#M  AsSSortedList( <lclass> ) . . . . . . . . . . . . . . . . . . .  elements
##
InstallMethod(AsSSortedList, "elements of lclass", true,
    [IsGreensLClass and IsTransformationCollection], 0,
function(L)

    local m, x, elts, grp;

    grp:= GenSchutzenbergerGroup(L);
    x:= Representative(L);

    elts:= [];
    for m in SchutzLMults(L) do
        Append(elts, TransformationRelation(InverseGeneralMapping(m) * x)
            * AsSSortedList(grp));
    od;

    return AsSSortedList(elts);

end);

#############################################################################
##
#M  <x> in <lclass> . . . . . . . . . . . . . . . . . . . . . membership test
##
InstallMethod(\in,"trans in lclass", true, 
    [IsTransformation, IsGreensLClass and IsTransformationCollection], 0,
function(x, L)

    local i, j, n, set, rep, grp, ker;

    rep:= Representative(L);
    if RankOfTransformation(x) <> RankOfTransformation(rep) or
        ImageSetOfTransformation(x) <> ImageSetOfTransformation(rep) then
        return false;
    fi;

    grp:= GenSchutzenbergerGroup(L);

    ker:= ShallowCopy(EquivalenceRelationPartition(KernelOfTransformation(x)));
    n:= DegreeOfTransformation(rep);
    set:= Union(ker);
    for j in [1..n] do
        if not j in set then
            AddSet(ker, [j]);
        fi;
    od;

    i:= Position(SchutzKernels(L), ker);
    if i = fail then
        return false;
    fi;

    return TransPermLeftQuoTrans(rep, TransformationRelation(
        SchutzLMults(L)[i] * x)) in grp;

end);

#############################################################################
##
#M  GreensLClasses( <S> )
##
##  Calculates the LClasses of a transformation semigroup <S>.   Actually
##  loops over all D classes, and enumerates L classes within each D class.
##
InstallMethod(GreensLClasses, "for lclasses of semigroup", true,
    [IsTransformationSemigroup], 0,

function( S )

    local L, classes, D;

	L:= GreensLRelation(S);

    classes:= [];
    for D in GreensDClasses(S) do
        Append(classes, GreensLClasses(D));
    od;

    return classes;

end);

#############################################################################
##
#M  GreensHClasses( <L> )
##
##  calculates the H classes contained within an L class
##
InstallMethod(GreensHClasses, "for hclasses of an l class", true,
    [IsGreensLClass and IsTransformationCollection], 0,
function(L)

    local H, S, D, x, l, c, d, classes, new, grp, sch, cos;

	H:= GreensHRelation(Parent(L));

    # initialize
    classes:= [];  S:= Parent(L); x:= Representative(L);
    D:= EquivalenceClassOfElementNC(GreensDRelation(S), x);
    Size(D);    # unfold data structure

    grp:= GenSchutzenbergerGroup(L);
    sch:= AsSubgroup(grp, GenSchutzenbergerGroup(
        EquivalenceClassOfElementNC(H, x)));
    cos:= List(RightCosets(grp, sch), x->Representative(x)^-1);

    # loop over R class reps.
    for l in SchutzLMults(L) do
        d:= TransformationRelation(InverseGeneralMapping(l)*x);

        # loop over cosets.
        for c in cos do
            new:= EquivalenceClassOfElementNC(H, d*c);
            SetGenSchutzenbergerGroup(new, sch);
            Add(classes, new);
        od;
    od;

    return classes;
end);


############################################################################
############################################################################
##                                                                        ##
##                        HClass Operations                               ##
##                                                                        ##
############################################################################
############################################################################

#############################################################################
##
#M  SchutzenbergerGroup( <hclass> ) . . . . . . . . . .  schutzenberger group
##
InstallMethod(GenSchutzenbergerGroup,"for hclass", true,
    [IsGreensHClass and IsTransformationCollection], 0,
function(H)

    local S, x;
    S:= Parent(H); x:= Representative(H);
    SetRClassOfHClass(H, EquivalenceClassOfElementNC(
        GreensRRelation(S), x));
    SetLClassOfHClass(H, EquivalenceClassOfElementNC(
        GreensLRelation(S), x));
    return Intersection(GenSchutzenbergerGroup(LClassOfHClass(H)),
        GenSchutzenbergerGroup(RClassOfHClass(H)));
end);

#############################################################################
##
#M  <x> in <hclass> . . . . . . . . . . . . . . . . . . . . . membership test
##
InstallMethod(\in,"trans in hclass",true,
    [IsTransformation, IsGreensHClass and IsTransformationCollection], 0,
function(x, H)

    local rep, img, grp;

    rep:= Representative(H);

    if RankOfTransformation(x) <> RankOfTransformation(rep) or
        ImageSetOfTransformation(x) <> ImageSetOfTransformation(rep) or
        KernelOfTransformation(x) <> KernelOfTransformation(rep) then

        return false;
    fi;

    return TransPermLeftQuoTrans(rep, x) in GenSchutzenbergerGroup(H);
end);

############################################################################
############################################################################
##                                                                        ##
##                        DClass Operations                               ##
##                                                                        ##
############################################################################
############################################################################

#############################################################################
##
#M  SchutzenbergerGroup( <dclass> ) . . . . . . . . . .  schutzenberger group
##
##  This unfolds a D class.   It determines, for the given representative 'x'
##  its H class, L class and R class, and stores them in relevant attributes.
##
##  Additionally, the attribute 'rCosets' contains a right traversal of the
##  small group in the right group.
##
InstallMethod(GenSchutzenbergerGroup,"Schutz group of D class", true,
    [IsGreensDClass and IsTransformationCollection], 0,
function(D)

    local x, S, rGrp, grp, H, R, L;

    x:= Representative(D); S:= Parent(D);
    H:= EquivalenceClassOfElementNC(GreensHRelation(S), x);
    R:= RClassOfHClass(H);
    L:= LClassOfHClass(H);

    grp:= GenSchutzenbergerGroup(H);
    rGrp:= GenSchutzenbergerGroup(R);
    GenSchutzenbergerGroup(L);

    SetSchutzRCosets(D, List(RightCosets(rGrp, AsSubgroup(rGrp, grp)),
        Representative));
    SetSchutzRClassInDClass(D, R);
    SetSchutzLClassInDClass(D, L);

    return grp;
end);

#############################################################################
##
#M  Size( <dclass> )  . . . . . . . . . . . . . . . . . . . .  size of dclass
##
InstallMethod(Size,"of dclass", true,
    [IsGreensDClass and IsTransformationCollection], 0,
function(D)
    local S, rep, R, L;

    S:= Parent(D);
    rep:= Representative(D);
    R:= EquivalenceClassOfElementNC(GreensRRelation(S), rep);
    L:= EquivalenceClassOfElementNC(GreensLRelation(S), rep);

    return Size(GenSchutzenbergerGroup(D))^-1 * Size(R) * Size(L);
end);

#############################################################################
##
#M  AsSSortedList( <dclass> ) . . . . . . . . . . . . . . . . . . .  elements
##
InstallMethod(AsSSortedList,"elements of dclass",true,
    [IsGreensDClass and IsTransformationCollection], 0,
function(D)

    local c, e, m, elts, L;

    L:= EquivalenceClassOfElementNC(GreensLRelation(Parent(D)),
        Representative(D));

    GenSchutzenbergerGroup(D);

    elts:= [];
    for c in SchutzRCosets(D) do
        for m in SchutzRMults(SchutzRClassInDClass(D)) do
            for e in AsSSortedList(L) do
                Add(elts, e * c / m);
            od;
        od;
    od;

    return AsSSortedList(elts);

end);

#############################################################################
##
#M  <x> in <dclass> . . . . . . . . . . . . . . . . . . . . . membership test
##
InstallMethod(\in, "trans in dclass", true,
    [IsTransformation, IsGreensDClass and IsTransformationCollection], 0,
function(x, D)

    local i, c, rep, ker, flat, img, grp, quo, R, L;

    rep:= Representative(D);
    if RankOfTransformation(x) <> RankOfTransformation(rep) then
        return false;
    fi;

    GenSchutzenbergerGroup(D);
    R:= SchutzRClassInDClass(D);
    L:= SchutzLClassInDClass(D);

    img:= ImageSetOfTransformation(x); i:= Position(SchutzImages(R), img);
    if i = fail then
        return false;
    fi;

    x:= x * SchutzRMults(R)[i];
    img:= ImageSetOfTransformation(x);

    ker:= ShallowCopy(EquivalenceRelationPartition(
		KernelOfTransformation(x))); 
	flat:= Flat(ker);
	for i in [1..DegreeOfTransformation(rep)] do
		if not i in flat then
			AddSet(ker, [i]);
		fi;
	od;
	i:= Position(SchutzKernels(L), ker);
    if i = fail then
        return false;
    fi;
    x:= TransformationRelation(SchutzLMults(L)[i] * x);


    grp:= GenSchutzenbergerGroup(L);
    quo:= TransPermLeftQuoTrans(rep, x);
    for c in SchutzRCosets(D) do
        if quo/c in grp then
            return true;
        fi;
    od;

    return false;
end);

#############################################################################
##
#M  GreensDClasses( <S> )
##
InstallMethod(GreensDClasses, "for transformation semigroup", true,
    [IsTransformationSemigroup], 0,
function( S )

    local D, classes, m, reps, d;

	D:= GreensDRelation(S);

    # start with R classes
    GreensRClasses(S);

    # split big classes into D classes
    classes:= [];
    for reps in RCRepsTransSemi(S) do
        repeat
            d:= EquivalenceClassOfElementNC(D, reps[1]);
            Add(classes, d);
            reps:= Filtered(reps, x->not x in d);
        until reps= [];
    od;

    return classes;
end);



#############################################################################
##
#M  GreensRClasses <D> )
##
InstallMethod(GreensRClasses, "rclasses of dclass", true,
    [IsGreensDClass and IsTransformationCollection], 0,
function ( D )

    local R, S, x, l, c, d, classes, new, grp, sch, cos;

	R:= GreensRRelation(Parent(D));

    classes:= [];
    S:= Parent(D);
    x:= Representative(D);

    Size(D);

    grp:= GenSchutzenbergerGroup(SchutzLClassInDClass(D));
    sch:= AsSubgroup(grp, GenSchutzenbergerGroup(
        EquivalenceClassOfElementNC(GreensHRelation(S), x)));
    cos:= List(RightCosets(grp, sch), x->Representative(x)^1);
    grp:= GenSchutzenbergerGroup(SchutzRClassInDClass(D));

    for l in SchutzLMults(SchutzLClassInDClass(D)) do
        d:= TransformationRelation(InverseGeneralMapping(l) * x);

        # loop over cosets
        for c in cos do
            new:= EquivalenceClassOfElementNC(GreensRRelation(S), d*c);
            SetSchutzImages(new, SchutzImages(SchutzRClassInDClass(D)));
            SetSchutzRMults(new, SchutzRMults(SchutzRClassInDClass(D)));
            Add(classes, new);
        od;
    od;

    return classes;

end);


#############################################################################
##
#M  GreensLClasses( <D> )
##
InstallMethod(GreensLClasses, "for lclasses in dclass", true,
    [IsGreensDClass and IsTransformationCollection], 0,
function( D )

    local L, S, x, c, d, m, classes, new, gens, l;

	L:= GreensLRelation(Parent(D));

    classes:= [];
    S:= Parent(D);
    x:= Representative(D);

    Size(D);
    l:= SchutzLClassInDClass(D);
    gens:= GeneratorsOfGroup(GenSchutzenbergerGroup(l));
    for c in SchutzRCosets(D) do

        for m in SchutzRMults(SchutzRClassInDClass(D)) do
            d:= c/m;
            new:= EquivalenceClassOfElementNC(L, x*d);
            SetSchutzKernels(new, SchutzKernels(l));
            SetSchutzLMults(new, SchutzLMults(l));
            SetGenSchutzenbergerGroup(new, Group(List(gens, x->x^d), ()));
            Add(classes, new);
        od;
    od;

    return classes;

end);

#############################################################################
##
#M  GreensHClasses( <D> )
##
InstallMethod(GreensHClasses, "for h classes in d class", true,
    [IsGreensDClass and IsTransformationCollection], 0,
function(D)

    local S, classes;

    S:= Parent(D);
    return Concatenation(List(GreensLClasses(D), x->GreensHClasses(x)));

end);

#############################################################################
##
#E