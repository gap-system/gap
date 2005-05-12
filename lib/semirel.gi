#############################################################################
##
#W  semirel.gi                  GAP library                   Robert F. Morse 
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for Green's equivalence relations on
##  semigroups. 
##
Revision.semirel_gi :=
    "@(#)$Id$";


#############################################################################
#############################################################################
##                                                                         ##
##                        Green's Relations                                ##
##                                                                         ##
#############################################################################
#############################################################################

#############################################################################
##
##  Being a Green's Relation is a property of an equivalence relation. We do
##  not make them categories of equivalence relations -- hence we use
##  the construction methods for equivalence relations.
##
##  Property testers
##
#P  IsGreensRelation( <equiv> )     Common property to all Green's relations 
#P  IsGreensRRelation( <equiv> )    Property of being a Green's R relation
#P  IsGreensLRelation( <equiv> )    Property of being a Green's L relation
#P  IsGreensJRelation( <equiv> )    Property of being a Green's J relation
#P  IsGreensDRelation( <equiv> )    Property of being a Green's D relation
#P  IsGreensHRelation( <equiv> )    Property of being a Green's H relation
##
InstallMethod(IsGreensRelation, "for equivalence relations", true,
        [IsEquivalenceRelation], 0,
    er -> HasIsGreensRelation(er) );

InstallMethod(IsGreensRRelation, "for a Green's equivalence class", true,
        [IsEquivalenceRelation], 0,
    er -> HasIsGreensRRelation(er) and IsGreensRRelation(er) );

InstallMethod(IsGreensLRelation, "for a Green's equivalence class", true,
        [IsEquivalenceRelation], 0,
    er -> HasIsGreensLRelation(er) and IsGreensLRelation(er) );

InstallMethod(IsGreensJRelation, "for a Green's equivalence class", true,
        [IsEquivalenceRelation], 0,
    er -> HasIsGreensJRelation(er) and IsGreensJRelation(er) );

InstallMethod(IsGreensDRelation, "for a Green's equivalence class", true,
        [IsEquivalenceRelation], 0,
    er -> HasIsGreensDRelation(er) and IsGreensDRelation(er) );

InstallMethod(IsGreensHRelation, "for a Green's equivalence class", true,
        [IsEquivalenceRelation], 0,
    er -> HasIsGreensHRelation(er) and IsGreensHRelation(er) );

#############################################################################
##
##           Green's Relations for generic finite semigroups
##
#############################################################################

#############################################################################
##
#P  IsFiniteSemigroupGreensRelation
##
DeclareProperty("IsFiniteSemigroupGreensRelation",IsEquivalenceRelation);


#############################################################################
##
#A  GreensRRelation( <s> ) 
#A  GreensLRelation( <s> ) 
#A  GreensJRelation( <s> ) 
#A  GreensDRelation( <s> ) 
#A  GreensHRelation( <s> ) 
##
##  Computes the Green's R Relation for a finite semigroups whose elements
##  we can enumerate. We find the Cayley Graph (and its dual)
##  and find its strongly connected components.
##
##  Sets the other Green's relations if the semigroup is commutative.
##
##  Representation: The Green's relations are represented as 
##                  Binary relations on points. Each point refers to 
##                  an element in the semigroup in sorted order.
##     
##                  As a Green's relation is from the user point of
##                  view a relation over the semigroup. We have
##                  overloaded all calls to produce semigroup elements
##                  even though the internal representation is on points.
##
##
InstallMethod(GreensRRelation, "for generic finite semigroups", true,
        [IsSemigroup and HasIsFinite and IsFinite],0,
    function(s)
        local cg, sc;

        ## Compute nothing if the semigroup is commutative and
        ##     the GreensLRelation attribute has been set in this
        ##     case the GreensRRelation equal to the GreensLRelation
        ##
        if HasIsCommutative(s) and IsCommutative(s) and 
               HasGreensLRelation(s) then
   
            sc := GreensLRelation(s);

            SetIsGreensRRelation(sc,true);
            SetIsGreensJRelation(sc,true);
            SetIsGreensHRelation(sc,true);
            SetIsGreensDRelation(sc,true);
            SetIsSemigroupCongruence(sc,true);

            SetGreensRRelation(s,sc);
            SetGreensJRelation(s,sc);
            SetGreensHRelation(s,sc);
            SetGreensDRelation(s,sc);

            return sc;
        fi;          

        ## The no check version of BinaryRelationOnPoints 
        ##     insures each image is an ordered set 
        ##
        cg := BinaryRelationOnPointsNC(CayleyGraphSemigroup(s));
        
        ## The Green's R equivalence classes are just the
        ##    Strongly connected components of the Cayley graph.
        ##
        sc := StronglyConnectedComponents(cg);

        SetIsGreensRelation(sc,true);
        SetIsFiniteSemigroupGreensRelation(sc,true);
        SetIsGreensRRelation(sc,true);
        SetAssociatedSemigroup(sc,s);

        SetIsLeftSemigroupCongruence(sc,true);

        ## If the semigroup is commutative set the other attributes
        ##    Green's relations
        ##
        if HasIsCommutative(s) and IsCommutative(s) then 

            SetIsGreensLRelation(sc,true);
            SetIsGreensJRelation(sc,true);
            SetIsGreensHRelation(sc,true);
            SetIsGreensDRelation(sc,true);

            SetIsSemigroupCongruence(sc,true);

            SetGreensLRelation(s,sc);
            SetGreensJRelation(s,sc);
            SetGreensHRelation(s,sc);
            SetGreensDRelation(s,sc);
        fi;

        return sc;
    end);

InstallMethod(GreensLRelation, "for generic finite semigroups", true,
        [IsSemigroup and HasIsFinite and IsFinite],0,
    function(s)
        local cg, sc;

        ## Compute nothing if the semigroup is commutative and
        ##     the GreensLRelation attribute has been set in this
        ##     case the GreensRRelation equal to the GreensLRelation
        ##
        if HasIsCommutative(s) and IsCommutative(s) and 
               HasGreensRRelation(s) then
   
            sc := GreensRRelation(s);

            SetIsGreensLRelation(sc,true);
            SetIsGreensJRelation(sc,true);
            SetIsGreensHRelation(sc,true);
            SetIsGreensDRelation(sc,true);
            SetIsSemigroupCongruence(sc,true);

            SetGreensLRelation(s,sc);
            SetGreensJRelation(s,sc);
            SetGreensHRelation(s,sc);
            SetGreensDRelation(s,sc);

            return sc;
        fi;          

        ## The no check version of BinaryRelationOnPoints 
        ##     insures each image is an ordered set 
        ##
        cg := BinaryRelationOnPointsNC(CayleyGraphDualSemigroup(s));

        sc := StronglyConnectedComponents(cg);
        SetIsGreensRelation(sc,true);
        SetIsFiniteSemigroupGreensRelation(sc,true);
        SetIsGreensLRelation(sc,true);
        SetAssociatedSemigroup(sc,s);

        SetIsRightSemigroupCongruence(sc,true);

        ## If the semigroup is commutative set the other attributes
        ##    Green's relaitons
        ##
        if HasIsCommutative(s) and IsCommutative(s) then

            SetIsGreensLRelation(sc,true);
            SetIsGreensJRelation(sc,true);
            SetIsGreensHRelation(sc,true);
            SetIsGreensDRelation(sc,true);

            SetIsSemigroupCongruence(sc,true);

            SetGreensLRelation(s,sc);
            SetGreensJRelation(s,sc);
            SetGreensHRelation(s,sc);
            SetGreensDRelation(s,sc);
        fi;          

        return sc;
    end);

InstallMethod(GreensJRelation, "for generic finite semigroups", true,
        [IsSemigroup and HasIsFinite and IsFinite],0,
    function(s)
        local j;

        ## Since we are in the finite case compute the Green's D relation
        ##    and set the GreensJRelation property to the returned
        ##    equivalence
        ##
        j := GreensDRelation(s); 
        SetIsGreensJRelation(j,true);
        return j;
    end);

InstallMethod(GreensHRelation, "for generic finite semigroups", true,
        [IsSemigroup and IsFinite],0,
    function(s)
        local m;

        ## Compute nothing if the semigroup is commutative
        ##     Only compute the Greens R relation
        ##     which sets the GreensHRelation attribute
        ##
        if HasIsCommutative(s) and IsCommutative(s) then 
            GreensRRelation(s);
            return GreensHRelation(s);
        fi;
      
        ## Otherwise compute the meet of the GreensR and
        ##    GreensL relations
        ##
        m := MeetEquivalenceRelations(
                 GreensRRelation(s),GreensLRelation(s));

        SetIsGreensRelation(m,true);
        SetIsFiniteSemigroupGreensRelation(m,true);
        SetIsGreensHRelation(m,true);
        SetAssociatedSemigroup(m,s);

        return m;
    end);

InstallMethod(GreensDRelation, "for generic finite semigroups", true,
        [IsSemigroup and IsFinite],0,
    function(s)
        local j;

        ## Compute nothing if the semigroup is commutative
        ##     Only compute the Greens R relation
        ##     which sets the GreensHRelation attribute
        ##
        if HasIsCommutative(s) and IsCommutative(s) then 
            GreensRRelation(s);
            return GreensDRelation(s);
        fi;

        ## Otherwise compute the join of the GreensR and
        ##    GreensL relations
        ##
        j := JoinEquivalenceRelations(
                 GreensRRelation(s),GreensLRelation(s));

        SetIsGreensRelation(j,true);
        SetIsFiniteSemigroupGreensRelation(j,true);
        SetIsGreensJRelation(j,true);
        SetAssociatedSemigroup(j,s);

        return j;
    end);


#############################################################################
##
##  Being a Green's equivalence class is a property of IsEquivalenceClass.
##
##  Property testers
##
#P  IsGreensClass( <equiv-class> )   
#P  IsGreensRClass( <equiv-class> )   
#P  IsGreensLClass( <equiv-class> )   
#P  IsGreensJClass( <equiv-class> )   
#P  IsGreensDClass( <equiv-class> )   
#P  IsGreensHClass( <equiv-class> )   
##
InstallMethod(IsGreensClass, "for equivalence classes", true,
        [IsEquivalenceClass], 0,
    er -> HasIsGreensClass(er) );

InstallMethod(IsGreensLClass, "for a Green's equivalence class", true,
        [IsEquivalenceClass], 0,
    c -> HasIsGreensLClass(c) and IsGreensLClass(c) );

InstallMethod(IsGreensRClass, "for a Green's equivalence class", true,
        [IsEquivalenceClass], 0,
    c -> HasIsGreensRClass(c) and IsGreensRClass(c) );

InstallMethod(IsGreensJClass, "for a Green's equivalence class", true,
        [IsEquivalenceClass], 0,
    c -> HasIsGreensJClass(c) and IsGreensJClass(c) );

InstallMethod(IsGreensHClass, "for a Green's equivalence class", true,
        [IsEquivalenceClass], 0,
    c -> HasIsGreensHClass(c) and IsGreensHClass(c) );

InstallMethod(IsGreensDClass, "for a Green's equivalence class", true,
        [IsEquivalenceClass], 0,
    c -> HasIsGreensDClass(c) and IsGreensDClass(c) );


#############################################################################
##
##  The Green's classes for a given Green's relation are just the images
##  of the Green's relation. 
##
#O  GreensRClasses(<semigroup>)
#O  GreensLClasses(<semigroup>)
#O  GreensJClasses(<semigroup>)
#O  GreensDClasses(<semigroup>)
#O  GreensHClasses(<semigroup>)
##
InstallMethod(GreensRClasses, "for generic finite semigroups", true, 
        [IsSemigroup and HasIsFinite and IsFinite],0,
    function(s)
        local classes,     # list of distinct equivalence classes 
              cl,          # single equivalence class
              i,           # index variable
              reps,        # list of all representative for classes
              singletons;  # list of singletons to be folded into reps

        ## Find all the distinct representatives. These include
        ##    a representative from each partition and the 
        ##    singletons.
        ##
        singletons := Difference(AsSet(Source(GreensRRelation(s))), 
             Flat(EquivalenceRelationPartition(GreensRRelation(s))));
        reps := List(EquivalenceRelationPartition(GreensRRelation(s)),
                    x-> x[1]);
     
        Append(reps, singletons);

        classes :=[];

        ## Create the equivalence class of each representative
        ##   
        for i in reps do 
            cl := GreensRClassOfElement(s,EnumeratorSorted(s)[i] );
            Add(classes,cl);
        od;

        return classes; 
    end);

InstallMethod(GreensLClasses, "for generic finite semigroups", 
        true, [IsSemigroup and HasIsFinite and IsFinite],0,
    function(s)
        local classes,     # list of distinct equivalence classes 
              cl,          # single equivalence class
              i,           # index variable
              reps,        # list of all representative for classes
              singletons;  # list of singletons to be folded into reps

        ## Find all the distinct representative. These include
        ##    a representative from each partition and the 
        ##    singletons.
        ##
        singletons := Difference(AsSet(Source(GreensLRelation(s))), 
             Flat(EquivalenceRelationPartition(GreensLRelation(s))));
        reps := List(EquivalenceRelationPartition(GreensLRelation(s)),
                    x-> x[1]);
     
        Append(reps, singletons);

        classes :=[];

        ## Find the equivalence classes of each representative
        ##
        for i in reps do 
            cl := GreensLClassOfElement(s,EnumeratorSorted(s)[i] );
            Add(classes,cl);
        od;

        return classes; 
    end);

InstallMethod(GreensDClasses, "for generic finite semigroups", true, 
    [IsSemigroup and HasIsFinite and IsFinite],0,
    function(s)
        local classes,     # list of distinct equivalence classes 
              cl,          # single equivalence class
              i,           # index variable
              reps,        # list of all representative for classes
              singletons;  # list of singletons to be folded into reps

        ## Find all the distinct representative. These include
        ##    a representative from each partition and the 
        ##    singletons.
        ##
        singletons := Difference(AsSet(Source(GreensDRelation(s))), 
             Flat(EquivalenceRelationPartition(GreensDRelation(s))));
        reps := List(EquivalenceRelationPartition(GreensDRelation(s)),
                    x-> x[1]);
     
        Append(reps, singletons);

        classes :=[];

        ## Find the equivalence classes of each representative
        ##
        for i in reps do 
            cl := GreensDClassOfElement(s,EnumeratorSorted(s)[i] );
            Add(classes,cl);
        od;

        return classes; 
    end);

InstallMethod(GreensHClasses, "for generic finite semigroups", true, 
    [IsSemigroup and HasIsFinite and IsFinite],0,
    function(s)
        local classes,     # list of distinct equivalence classes 
              cl,          # single equivalence class
              i,           # index variable
              reps,        # list of all representative for classes
              singletons;  # list of singletons to be folded into reps

        ## Find all the distinct representative. These include
        ##    a representative from each partition and the 
        ##    singletons.
        ##
        singletons := Difference(AsSet(Source(GreensHRelation(s))), 
             Flat(EquivalenceRelationPartition(GreensHRelation(s))));
        reps := List(EquivalenceRelationPartition(GreensHRelation(s)),
                    x-> x[1]);
     
        Append(reps, singletons);

        classes :=[];

        ## Find the equivalence classes of each representative
        ##
        for i in reps do 
            cl := GreensHClassOfElement(s,EnumeratorSorted(s)[i] );
            Add(classes,cl);
        od;

        return classes; 
    end);

InstallMethod(GreensJClasses, "for generic finite semigroups", true, 
    [IsSemigroup and HasIsFinite and IsFinite],0,
    function(s)
        local classes,     # list of distinct equivalence classes 
              cl,          # single equivalence class
              i,           # index variable
              reps,        # list of all representative for classes
              singletons;  # list of singletons to be folded into reps

        ## Find all the distinct representative. These include
        ##    a representative from each partition and the 
        ##    singletons.
        ##
        singletons := Difference(AsSet(Source(GreensJRelation(s))), 
             Flat(EquivalenceRelationPartition(GreensJRelation(s))));
        reps := List(EquivalenceRelationPartition(GreensJRelation(s)),
                    x-> x[1]);
     
        Append(reps, singletons);

        classes :=[];

        ## Find the equivalence classes of each representative
        ##
        for i in reps do 
            cl := GreensJClassOfElement(s,EnumeratorSorted(s)[i] );
            Add(classes,cl);
        od;

        return classes; 
    end);

InstallMethod(GreensHClasses, "for an Green's Class", true,
    [IsGreensClass],0,
    function(gc)
        local e,class;

        class :=[];
        for e in Elements(gc) do
            AddSet(class,GreensHClassOfElement(AssociatedSemigroup(gc),e));
        od;
        return class;
    end);

#############################################################################
##
##  The following operations are constructors for Green's class with
##  a given element as a representative. The call is for semigroups
##  and an element in the semigroup. But the underlying object is
##  and equivalence class on points.
##
#O  GreensRClassOfElement(<semigroup>, <representative>)
#O  GreensLClassOfElement(<semigroup>, <representative>)
#O  GreensJClassOfElement(<semigroup>, <representative>)
#O  GreensDClassOfElement(<semigroup>, <representative>)
#O  GreensHClassOfElement(<semigroup>, <representative>)
##
InstallMethod(GreensRClassOfElement, "for a Green's equivalence class", 
        true, [IsSemigroup and HasIsFinite and IsFinite, IsObject], 0,
    function(s,e)
        local ec;

        if not e in s then
            Error("<e> must be an element of the semigroup <s>");
        fi;

        ## Construct the equivalence class using generic methods
        ##    i.e. not Green's class calls BUT the underlying
        ##    set is on points but the representative is the
        ##    element in the semigroup. Hence the NoCheck version
        ##    must be used and its behavior must be that the 
        ##    representative given is not checked to see if it in
        ##    the underlying collection. This allows for all
        ##    calls to "generic" equivalence class methods to be
        ##    used.
        ##
        ec := EquivalenceClassOfElementNC(
                  EquivalenceRelationByPartition(Source(GreensRRelation(s)),
                      EquivalenceRelationPartition(GreensRRelation(s))),
                  e );

        ## Set attributes and properties for class to be a 
        ##     Green's class 
        ## NOTE: The internal representative is for methods on Greens
        ##       classes. 
        ##
        SetAssociatedSemigroup(ec,s);
        SetInternalRepresentative(ec,Position(EnumeratorSorted(s),e));
        SetIsGreensClass(ec,true);
        SetIsGreensRClass(ec,true);
        return ec;       
    end);

InstallMethod(GreensLClassOfElement, "for a Green's equivalence class", 
        true, [IsSemigroup and HasIsFinite and IsFinite, IsObject], 0,
    function(s,e)
        local ec;

        if not e in s then
            Error("<e> must be an element of the semigroup <s>");
        fi;

        ## Construct the equivalence class using generic methods
        ##    i.e. not Green's class calls BUT the underlying
        ##    set is on points but the representative is the
        ##    element in the semigroup. Hence the NoCheck version
        ##    must be used and its behavior must be that the 
        ##    representative given is not checked to see if it in
        ##    the underlying collection. This allows for all
        ##    calls to "generic" equivalence class methods to be
        ##    used.
        ##
        ec := EquivalenceClassOfElementNC(
                  EquivalenceRelationByPartition(Source(GreensLRelation(s)),
                      EquivalenceRelationPartition(GreensLRelation(s))),
                  e );

        ## Set attributes and properties for class to be a 
        ##     Green's class 
        ## NOTE: The internal representative is for methods on Greens
        ##       classes. 
        ##
        SetAssociatedSemigroup(ec,s);
        SetInternalRepresentative(ec,Position(EnumeratorSorted(s),e));
        SetIsGreensClass(ec,true);
        SetIsGreensLClass(ec,true);
        return ec;       
    end);

InstallMethod(GreensJClassOfElement, "for a Green's equivalence class", 
        true, [IsSemigroup and HasIsFinite and IsFinite, IsObject], 0,
    function(s,e)
        local ec;

        if not e in s then
            Error("<e> must be an element of the semigroup <s>");
        fi;

        ## Construct the equivalence class using generic methods
        ##    i.e. not Green's class calls BUT the underlying
        ##    set is on points but the representative is the
        ##    element in the semigroup. Hence the NoCheck version
        ##    must be used and its behavior must be that the 
        ##    representative given is not checked to see if it in
        ##    the underlying collection. This allows for all
        ##    calls to "generic" equivalence class methods to be
        ##    used.
        ##
        ec := EquivalenceClassOfElementNC(
                  EquivalenceRelationByPartition(Source(GreensJRelation(s)),
                      EquivalenceRelationPartition(GreensJRelation(s))),
                  e );

        ## Set attributes and properties for class to be a 
        ##     Green's class 
        ## NOTE: The internal representative is for methods on Greens
        ##       classes. 
        ##
        SetAssociatedSemigroup(ec,s);
        SetInternalRepresentative(ec,Position(EnumeratorSorted(s),e));
        SetIsGreensClass(ec,true);
        SetIsGreensJClass(ec,true);
        return ec;       
    end);

InstallMethod(GreensHClassOfElement, "for a Green's equivalence class", 
        true, [IsSemigroup and HasIsFinite and IsFinite, IsObject], 0,
    function(s,e)
        local ec;

        if not e in s then
            Error("<e> must be an element of the semigroup <s>");
        fi;

        ## Construct the equivalence class using generic methods
        ##    i.e. not Green's class calls BUT the underlying
        ##    set is on points but the representative is the
        ##    element in the semigroup. Hence the NoCheck version
        ##    must be used and its behavior must be that the 
        ##    representative given is not checked to see if it in
        ##    the underlying collection. This allows for all
        ##    calls to "generic" equivalence class methods to be
        ##    used.
        ##
        ec := EquivalenceClassOfElementNC(
                  EquivalenceRelationByPartition(Source(GreensHRelation(s)),
                      EquivalenceRelationPartition(GreensHRelation(s))),
                  e );

        ## Set attributes and properties for class to be a 
        ##     Green's class 
        ## NOTE: The internal representative is for methods on Greens
        ##       classes. 
        ##
        SetAssociatedSemigroup(ec,s);
        SetInternalRepresentative(ec,Position(EnumeratorSorted(s),e));
        SetIsGreensClass(ec,true);
        SetIsGreensHClass(ec,true);

        return ec;       
    end);

InstallMethod(GreensDClassOfElement, "for a Green's equivalence class", 
        true, [IsSemigroup and HasIsFinite and IsFinite, IsObject], 0,
    function(s,e)
        local ec;

        if not e in s then
            Error("<e> must be an element of the semigroup <s>");
        fi;

        ## Construct the equivalence class using generic methods
        ##    i.e. not Green's class calls BUT the underlying
        ##    set is on points but the representative is the
        ##    element in the semigroup. Hence the NoCheck version
        ##    must be used and its behavior must be that the 
        ##    representative given is not checked to see if it in
        ##    the underlying collection. This allows for all
        ##    calls to "generic" equivalence class methods to be
        ##    used.
        ##
        ec := EquivalenceClassOfElementNC(
                  EquivalenceRelationByPartition(Source(GreensDRelation(s)),
                      EquivalenceRelationPartition(GreensDRelation(s))),
                  e );

        ## Set attributes and properties for class to be a 
        ##     Green's class 
        ## NOTE: The internal representative is for methods on Greens
        ##       classes. 
        ##
        SetAssociatedSemigroup(ec,s);
        SetInternalRepresentative(ec,Position(EnumeratorSorted(s),e));
        SetIsGreensClass(ec,true);
        SetIsGreensDClass(ec,true);

        return ec;       
    end);

#############################################################################
##
##  These are specialized versions of these operations for equivalence
##  relations which are also Green's relations. The actual relations
##  are relations on n points whose elements must be "translated" into
##  elements of the semigroup.     
##
##  This provides a consistent user interface working with Equivalence
##  relations that are Green's relations and their classes
##
#O  EquivalenceClassOfElement 
#O  EquivalenceClassOfElementNC 
#O  EquivalenceClasses
##
InstallMethod(EquivalenceClassOfElementNC, "for a Green's relation",
        true, 
        [IsGreensRelation and IsFiniteSemigroupGreensRelation, IsObject],1,

    function(gr,e) 
    
       if HasIsGreensRRelation(gr) then
            return GreensRClassOfElement(AssociatedSemigroup(gr),e);
       elif HasIsGreensLRelation(gr) then
            return GreensLClassOfElement(AssociatedSemigroup(gr),e);
       elif HasIsGreensJRelation(gr) then 
            return GreensJClassOfElement(AssociatedSemigroup(gr),e);
       elif HasIsGreensHRelation(gr) then 
            return GreensHClassOfElement(AssociatedSemigroup(gr),e);
       elif HasIsGreensDRelation(gr) then 
            return GreensDClassOfElement(AssociatedSemigroup(gr),e);
       else
            Error("Equivalence class for greens relation -- shouldn't get here");
       fi;
    end);

InstallMethod(EquivalenceClassOfElement, "for a Green's relation",
        true, [IsGreensRelation, IsObject], 1,
    function(gr,e)
       
       if not e in AssociatedSemigroup(gr) then
           Error("element is not in the source");
       fi;

       return EquivalenceClassOfElementNC(gr,e);
    end);


InstallMethod(EquivalenceClasses, "for a Green's relation", true,
        [IsGreensRelation and IsFiniteSemigroupGreensRelation], 0,
    function(gr)
        local d, classes, p;

        ## If we should already have a partition then return the equivalence
        ##     class with first element as represenative 
        ##
        classes := [];
        if HasEquivalenceRelationPartition(gr) then
            for p in EquivalenceRelationPartition(gr) do
                Add(classes, EquivalenceClassOfElementNC(gr,
                        EnumeratorSorted(AssociatedSemigroup(gr))[p[1]] ));
            od;

            ## Get the singletons
            ##
            if Sum(List(EquivalenceRelationPartition(gr),i->Length(i)))<>
                   Size(Source(gr)) then
                d := Difference(AsSet(Source(gr)), 
                         Flat(EquivalenceRelationPartition(gr)));
                for p in d do
                    Add(classes, EquivalenceClassOfElementNC(gr,
                            EnumeratorSorted(AssociatedSemigroup(gr))[p] ));
                 od;
            fi;
            return classes;
        else
            TryNextMethod();
        fi;
    end);

InstallMethod(\=, "for Green's equivalence classes", true, 
        [IsGreensClass, IsGreensClass], 0,
    function(gcL,gcR)
        if HasInternalRepresentative(gcL) and HasInternalRepresentative(gcR)
                then
            
            return 
                Set(ImagesElm(
                EquivalenceClassRelation(gcL),InternalRepresentative(gcL))) =
                Set(ImagesElm(
                EquivalenceClassRelation(gcR),InternalRepresentative(gcR)));

        fi;
        TryNextMethod();
                
    end);

InstallMethod(\in, "for Green's equivalence classes", true,
        [IsObject, IsGreensClass], 0,
    function(e, gc)
        if e = Representative(gc) then 
            return true; 
        fi;
        return e in AsList(gc);
    end);

InstallMethod(\in, "for Green's relation", true,
        [IsList, IsGreensRelation and IsFiniteSemigroupGreensRelation],0,
    function(l, gr)
        if not Length(l)=2 then
            Error("error: first parameter must be a list of length 2");
        fi;
        
        if not l[1] in AssociatedSemigroup(gr) or 
           not l[2] in AssociatedSemigroup(gr) then
            Error("error: elements in list must be in semigroup");
        fi;

        return l[1] in EquivalenceClassOfElement(gr,l[2]);

    end);

#############################################################################
##
#M  Enumerator(<greens class>)
##
##  Enumerator of a Green's class which returns elements of the semigroup
##  rather than the elements of the class which are sets of points.
##
InstallMethod(Enumerator, "for a Green's equivalence class", true,
        [IsGreensClass], 0,
    function(gc)
        return EnumeratorSorted(AssociatedSemigroup(gc))
            {ImagesElm(EquivalenceClassRelation(gc), 
                InternalRepresentative(gc))};
    end);


#############################################################################
##
#O  IsRegularDClass(<greens class>)
##
##  Returns true if the class contains an idempotent
##
InstallMethod(IsRegularDClass, "for a Green's D class", true,
        [IsGreensDClass],0,
    gc ->ForAny(gc, i->IsIdempotent(i)) );



InstallMethod(IsGreensLessThanOrEqual, "for two Green's equivalence classes",
        true, [IsGreensClass, IsGreensClass],0,
    function(gcL,gcR)
        local a,b;

        a := Representative(gcL);
        b := Representative(gcR);

        if IsGreensRClass(gcL) and IsGreensRClass(gcR) then
            return a in 
                RightMagmaIdealByGenerators(AssociatedSemigroup(gcR),[b]); 
        fi;
        if IsGreensLClass(gcL) and IsGreensLClass(gcR) then
            return a in 
                LeftMagmaIdealByGenerators(AssociatedSemigroup(gcR),[b]); 
        fi;
        if (IsGreensJClass(gcL) and IsGreensJClass(gcR)) or 
           (IsGreensDClass(gcL) and IsGreensDClass(gcR) and 
              IsFinite(AssociatedSemigroup(gcL))) then
            return a in 
                MagmaIdealByGenerators(AssociatedSemigroup(gcR),[b]);
        fi;

            

        Error("Green's classes are not of the same type or not L,R, or J classes");
    end);

InstallMethod(RClassOfHClass, "for a Green's H class", true, [IsGreensHClass],0,
    hc -> GreensRClassOfElement(AssociatedSemigroup(hc), Representative(hc))
    );

InstallMethod(LClassOfHClass, "for a Green's H class", true, [IsGreensHClass],0,
    hc -> GreensLClassOfElement(AssociatedSemigroup(hc), Representative(hc))
    );

#############################################################################
##
#M  IsGroupHClass( <H> )
##
##  returns true if the Greens H-class <H> is a group, which in turn is
##  true if and only if <H>^2 intersects <H>.
##
InstallMethod(IsGroupHClass, "for generic H class", true,
    [IsGreensHClass], 0, h->Representative(h)^2 in h);


############################################################################
##
#M  GroupHClassOfGreensDClass( <Dclass> )
##
##  for a D class <Dclass> of a semigroup,
##  returns a group H class of the D class, or `fail' if there is no
##  group H class.
##
InstallMethod(GroupHClassOfGreensDClass, "for finite H classes", true,
    [IsGreensDClass], 0, 
    function(d)
        local idm, hc;
        if not IsRegularDClass(d) then return fail; fi;

        idm := First(d,IsIdempotent);
        return GreensHClassOfElement(AssociatedSemigroup(d),idm);
       
    end);

#############################################################################
##
#A  EggBoxOfDClass( <D> )
##
InstallMethod(EggBoxOfDClass, "for a Green's D class", true, 
        [IsGreensDClass],0,
    function(d)

        local hc,
              rc,
              lc,
              intersect, ebmatrix, tmp,
              i,j,k;

        rc := []; lc := []; hc := [];

        for i in d do
            Add(rc, GreensRClassOfElement(AssociatedSemigroup(d),i));
            Add(lc, GreensLClassOfElement(AssociatedSemigroup(d),i));
            Add(hc, GreensHClassOfElement(AssociatedSemigroup(d),i));
        od;

        rc := DuplicateFreeList(rc);
        lc := DuplicateFreeList(lc);
        hc := DuplicateFreeList(hc);

        ebmatrix := [];

        for i in rc do
           tmp := [];
           for j in lc do
               intersect := 
                   Intersection(
                       ImagesElm(EquivalenceClassRelation(i), 
                           InternalRepresentative(i)), 
                       ImagesElm(EquivalenceClassRelation(j), 
                           InternalRepresentative(j)) ); 
                Add(tmp,GreensHClassOfElement(AssociatedSemigroup(d),
                    EnumeratorSorted(AssociatedSemigroup(d))[intersect[1]]) );
           od;
           Add(ebmatrix, tmp);
        od;     

        return ebmatrix;
    end);

#############################################################################
##
#F  DisplayEggBoxOfDClass( <D> )
##
##  A "picture" of the D class <D>, as an array of 1s and 0s.
##  A 1 represents a group H class.
##
InstallGlobalFunction(DisplayEggBoxOfDClass, 
    function(d)
        if not IsGreensDClass(d) then
            Error("requires IsGreensDClass");
        fi;

        PrintArray(
            List(EggBoxOfDClass(d), r->List(r,
                function(h)
                   if IsGroupHClass(h) then
                        return 1;
                   else
                        return 0;
                   fi;
                end))
       );
    end);
 

#############################################################################
##
##        Transformation Semigroups
##
#############################################################################

#############################################################################
##
#M  GreensRRelation(<semigroup>)
#M  GreensLRelation(<semigroup>)
#M  GreensJRelation(<semigroup>)
#M  GreensDRelation(<semigroup>)
#M  GreensHRelation(<semigroup>)
##
##  Green's relations for Transformation semigroups
##
##  Currently resort to the finite generic case
##
InstallMethod(GreensRRelation, "for transformation semigroups", true,
        [IsSemigroup and IsTransformationSemigroup],0,
    function(s)
        TryNextMethod();
    end);

InstallMethod(GreensLRelation, "for transformation semigroups", true,
        [IsSemigroup and IsTransformationSemigroup],0,
    function(s)
        TryNextMethod();
    end);

InstallMethod(GreensJRelation, "for transformation semigroups", true,
        [IsSemigroup and IsTransformationSemigroup],0,
    function(s)
        TryNextMethod();
    end);

InstallMethod(GreensDRelation, "for transformation semigroups", true,
        [IsSemigroup and IsTransformationSemigroup],0,
    function(s)
        TryNextMethod();
    end);

InstallMethod(GreensHRelation, "for transformation semigroups", true,
        [IsSemigroup and IsTransformationSemigroup],0,
    function(s)
        TryNextMethod();
    end);


#############################################################################
##
##        Full Transformation Semigroups
##
#############################################################################

#############################################################################
##
#M  GreensRRelation(<semigroup>)
#M  GreensLRelation(<semigroup>)
#M  GreensJRelation(<semigroup>)
#M  GreensDRelation(<semigroup>)
#M  GreensHRelation(<semigroup>)
##
##  Green's relations for Full Transformation semigroups
##
##  Currently resort to the finite generic case
##
InstallMethod(GreensRRelation, "for full transformation semigroups", true,
        [IsSemigroup and IsFullTransformationSemigroup],0,
    function(s)
        TryNextMethod();
    end);

InstallMethod(GreensLRelation, "for full transformation semigroups", true,
        [IsSemigroup and IsFullTransformationSemigroup],0,
    function(s)
        TryNextMethod();
    end);

InstallMethod(GreensJRelation, "for full transformation semigroups", true,
        [IsSemigroup and IsFullTransformationSemigroup],0,
    function(s)
        TryNextMethod();
    end);

InstallMethod(GreensDRelation, "for full transformation semigroups", true,
        [IsSemigroup and IsFullTransformationSemigroup],0,
    function(s)
        TryNextMethod();
    end);

InstallMethod(GreensHRelation, "for full transformation semigroups", true,
        [IsSemigroup and IsFullTransformationSemigroup],0,
    function(s)
        TryNextMethod();
    end);

#############################################################################
##
##        Generic Semigroups -- we do not know their form nor their
##        cardinality.
##
#############################################################################

#############################################################################
##
#M  GreensRRelation(<semigroup>)
#M  GreensLRelation(<semigroup>)
#M  GreensJRelation(<semigroup>)
#M  GreensDRelation(<semigroup>)
#M  GreensHRelation(<semigroup>)
##
##  Green's relations for generic semigroups
##
##
InstallMethod(GreensRRelation, "for generic semigroups", true,
        [IsSemigroup], 0,
    function(s)
        local sc;

        sc := EquivalenceRelationByProperty(s,IsGreensRRelation);
        
        if HasIsCommutative(s) and IsCommutative(s) then
            if HasIsGreensLRelation(s) then
                SetIsSemigroupCongruence(IsGreensLRelation(s),true);
                SetIsGreensRRelation(IsGreensLRelation(s),true);
                return GreensLRelation(s);
            elif HasIsGreensJRelation(s) then
                SetIsSemigroupCongruence(IsGreensJRelation(s),true);
                SetIsGreensRRelation(IsGreensJRelation(s),true);
                return GreensJRelation(s);
            elif HasIsGreensDRelation(s) then
                SetIsSemigroupCongruence(IsGreensDRelation(s),true);
                SetIsGreensRRelation(IsGreensDRelation(s),true);
                return GreensDRelation(s);
            elif HasIsGreensHRelation(s) then
                SetIsSemigroupCongruence(IsGreensHRelation(s),true);
                SetIsGreensRRelation(IsGreensHRelation(s),true);
                return GreensHRelation(s);
            else
                SetIsGreensRelation(sc,true);
                SetAssociatedSemigroup(sc,s);
                SetIsSemigroupCongruence(sc,true);
                return sc;
            fi;    
        fi;
        
        SetIsGreensRelation(sc,true);
        SetIsGreensRRelation(sc,true);  
        SetAssociatedSemigroup(sc,s);
        SetIsLeftSemigroupCongruence(sc,true);

        return sc;
    end);

InstallMethod(GreensLRelation, "for generic semigroups", true,
        [IsSemigroup], 0,
    function(s)
        local sc;
        sc := EquivalenceRelationByProperty(s,IsGreensLRelation);
        
        if HasIsCommutative(s) and IsCommutative(s) then
            if HasIsGreensRRelation(s) then
                SetIsSemigroupCongruence(IsGreensRRelation(s),true);
                SetIsGreensLRelation(IsGreensRRelation(s),true);
                return GreensRRelation(s);
            elif HasIsGreensJRelation(s) then
                SetIsSemigroupCongruence(IsGreensJRelation(s),true);
                SetIsGreensLRelation(IsGreensJRelation(s),true);
                return GreensJRelation(s);
            elif HasIsGreensDRelation(s) then
                SetIsSemigroupCongruence(IsGreensDRelation(s),true);
                SetIsGreensLRelation(IsGreensDRelation(s),true);
                return GreensDRelation(s);
            elif HasIsGreensHRelation(s) then
                SetIsSemigroupCongruence(IsGreensHRelation(s),true);
                SetIsGreensLRelation(IsGreensHRelation(s),true);
                return GreensHRelation(s);
            else
                SetIsGreensRelation(sc,true);
                SetAssociatedSemigroup(sc,s);
                SetIsSemigroupCongruence(sc,true);
                return sc;
            fi;    
        fi;
        
        SetIsGreensRelation(sc,true);
        SetIsGreensLRelation(sc,true);  
        SetAssociatedSemigroup(sc,s);
        SetIsRightSemigroupCongruence(sc,true);
        
        return sc;
    end);

InstallMethod(GreensJRelation, "for generic semigroups", true,
        [IsSemigroup], 0,
    function(s)
        local sc;
        sc := EquivalenceRelationByProperty(s,IsGreensJRelation);
        
        if HasIsCommutative(s) and IsCommutative(s) then
            if HasIsGreensRRelation(s) then
                SetIsSemigroupCongruence(IsGreensRRelation(s),true);
                SetIsGreensJRelation(IsGreensRRelation(s),true);
                return GreensRRelation(s);
            elif HasIsGreensLRelation(s) then
                SetIsSemigroupCongruence(IsGreensLRelation(s),true);
                SetIsGreensJRelation(IsGreensLRelation(s),true);
                return GreensLRelation(s);
            elif HasIsGreensDRelation(s) then
                SetIsSemigroupCongruence(IsGreensDRelation(s),true);
                SetIsGreensJRelation(IsGreensDRelation(s),true);
                return GreensDRelation(s);
            elif HasIsGreensHRelation(s) then
                SetIsSemigroupCongruence(IsGreensHRelation(s),true);
                SetIsGreensJRelation(IsGreensHRelation(s),true);
                return GreensHRelation(s);
            else
                SetIsGreensRelation(sc,true);
                SetAssociatedSemigroup(sc,s);
                SetIsSemigroupCongruence(sc,true);
                return sc;
            fi;    
        fi;
        
        SetIsGreensRelation(sc,true);
        SetIsGreensJRelation(sc,true);  
        SetAssociatedSemigroup(sc,s);

        return sc;
    end);

InstallMethod(GreensDRelation, "for generic semigroups", true,
        [IsSemigroup], 0,
    function(s)
        local sc;
        sc := EquivalenceRelationByProperty(s,IsGreensDRelation);
        
        if HasIsCommutative(s) and IsCommutative(s) then
            if HasIsGreensRRelation(s) then
                SetIsSemigroupCongruence(IsGreensRRelation(s),true);
                SetIsGreensDRelation(IsGreensRRelation(s),true);
                return GreensRRelation(s);
            elif HasIsGreensLRelation(s) then
                SetIsSemigroupCongruence(IsGreensLRelation(s),true);
                SetIsGreensDRelation(IsGreensLRelation(s),true);
                return GreensLRelation(s);
            elif HasIsGreensJRelation(s) then
                SetIsSemigroupCongruence(IsGreensJRelation(s),true);
                SetIsGreensDRelation(IsGreensJRelation(s),true);
                return GreensJRelation(s);
            elif HasIsGreensHRelation(s) then
                SetIsSemigroupCongruence(IsGreensHRelation(s),true);
                SetIsGreensDRelation(IsGreensHRelation(s),true);
                return GreensHRelation(s);
            else
                SetIsGreensRelation(sc,true);
                SetAssociatedSemigroup(sc,s);
                SetIsSemigroupCongruence(sc,true);
                return sc;
            fi;    
        fi;
        
        SetIsGreensRelation(sc,true);
        SetIsGreensDRelation(sc,true);  
        SetAssociatedSemigroup(sc,s);

        return sc;
    end);

InstallMethod(GreensHRelation, "for generic semigroups", true,
        [IsSemigroup], 0,
    function(s)
        local sc;
        sc := EquivalenceRelationByProperty(s,IsGreensHRelation);
        
        if HasIsCommutative(s) and IsCommutative(s) then
            if HasIsGreensRRelation(s) then
                SetIsSemigroupCongruence(IsGreensRRelation(s),true);
                SetIsGreensHRelation(IsGreensRRelation(s),true);
                return GreensRRelation(s);
            elif HasIsGreensLRelation(s) then
                SetIsSemigroupCongruence(IsGreensLRelation(s),true);
                SetIsGreensHRelation(IsGreensLRelation(s),true);
                return GreensLRelation(s);
            elif HasIsGreensJRelation(s) then
                SetIsSemigroupCongruence(IsGreensJRelation(s),true);
                SetIsGreensHRelation(IsGreensJRelation(s),true);
                return GreensJRelation(s);
            elif HasIsGreensDRelation(s) then
                SetIsSemigroupCongruence(IsGreensDRelation(s),true);
                SetIsGreensHRelation(IsGreensDRelation(s),true);
                return GreensDRelation(s);
            else
                SetIsGreensRelation(sc,true);
                SetAssociatedSemigroup(sc,s);
                SetIsSemigroupCongruence(sc,true);
                return sc;
            fi;    
        fi;
        
        
        SetIsGreensRelation(sc,true);
        SetIsGreensHRelation(sc,true);  
        SetAssociatedSemigroup(sc,s);

        return sc;
    end);


##
##
##
InstallMethod(GreensRClassOfElement, "for generic semigroups", true,
        [IsSemigroup,IsObject], 0,
    function(s,e)
        local ec;

        if not e in s then
            Error("<e> must be an element of the semigroup <s>");
        fi;
        
        ec := EquivalenceClassOfElement(GreensRRelation(s),e);
        SetAssociatedSemigroup(ec,s);
        SetIsGreensClass(ec,true);
        SetIsGreensRClass(ec,true);

        return ec;
    end);

InstallMethod(GreensLClassOfElement, "for generic semigroups", true,
        [IsSemigroup,IsObject], 0,
    function(s,e)
        local ec;

        if not e in s then
            Error("<e> must be an element of the semigroup <s>");
        fi;
        
        ec := EquivalenceClassOfElement(GreensLRelation(s),e);
        SetAssociatedSemigroup(ec,s);
        SetIsGreensClass(ec,true);
        SetIsGreensLClass(ec,true);

        return ec;
    end);

InstallMethod(GreensJClassOfElement, "for generic semigroups", true,
        [IsSemigroup ,IsObject], 0,
    function(s,e)
        local ec;

        if not e in s then
            Error("<e> must be an element of the semigroup <s>");
        fi;
        
        ec := EquivalenceClassOfElement(GreensJRelation(s),e);
        SetAssociatedSemigroup(ec,s);
        SetIsGreensClass(ec,true);
        SetIsGreensJClass(ec,true);

        return ec;
    end);

InstallMethod(GreensDClassOfElement, "for generic semigroups", true,
        [IsSemigroup,IsObject], 0,
    function(s,e)
        local ec;

        if not e in s then
            Error("<e> must be an element of the semigroup <s>");
        fi;
        
        ec := EquivalenceClassOfElement(GreensDRelation(s),e);
        SetAssociatedSemigroup(ec,s);
        SetIsGreensClass(ec,true);
        SetIsGreensDClass(ec,true);

        return ec;
    end);

InstallMethod(GreensHClassOfElement, "for generic semigroups", true,
        [IsSemigroup,IsObject], 0,
    function(s,e)
        local ec;

        if not e in s then
            Error("<e> must be an element of the semigroup <s>");
        fi;
        
        ec := EquivalenceClassOfElement(GreensHRelation(s),e);
        SetAssociatedSemigroup(ec,s);
        SetIsGreensClass(ec,true);
        SetIsGreensHClass(ec,true);

        return ec;
    end);

InstallMethod(\in, "for Greens classes and generic semigroups", 
        true,[IsObject,IsGreensClass],0,
    function(e,gc)

        local C;

        ## If the element is the representative of gc return true 
        ##
        if e=Representative(gc) then return true; fi;

        ## If the Green's class elements is known essentially 
        ##    use the list.
        ##
        if HasIsFinite(AssociatedSemigroup(gc)) then 
            return e in Elements(gc);
        fi;
        
        if HasIsGreensRClass(gc) then
            C := GreensRClassOfElement(AssociatedSemigroup(gc),e);
        elif HasIsGreensLClass(gc) then
            C := GreensLClassOfElement(AssociatedSemigroup(gc),e);
        elif HasIsGreensJClass(gc) then
            C := GreensJClassOfElement(AssociatedSemigroup(gc),e);
        elif HasIsGreensHClass(gc) then
            return e in RClassOfHClass(gc) and e in LClassOfHClass(gc);
        elif HasIsGreensDClass(gc) then
            TryNextMethod();                        
        fi;

        return IsGreensLessThanOrEqual(gc, C) and 
               IsGreensLessThanOrEqual(C, gc);
    end);

InstallMethod(\in, "for Greens relations and generic semigroups",
        true,[IsList, IsGreensRelation],0,
    function(l,gr)
         if IsGreensRRelation(gr) then
             return 
                 l[1] in GreensRClassOfElement(AssociatedSemigroup(gr),l[2]);
         elif IsGreensLRelation(gr) then
             return 
                 l[1] in GreensLClassOfElement(AssociatedSemigroup(gr),l[2]);
         elif IsGreensJRelation(gr) then
             return
                 l[1] in GreensJClassOfElement(AssociatedSemigroup(gr),l[2]);
         elif IsGreensDRelation(gr) then
             return
                 l[1] in GreensDClassOfElement(AssociatedSemigroup(gr),l[2]);
         elif IsGreensHRelation(gr) then
             return
                 l[1] in GreensHClassOfElement(AssociatedSemigroup(gr),l[2]);
         else
             Error("error: Shouldn't get here -- must be a RLJDH relation");  
         fi; 
             
    end);
    


#############################################################################
##
##        Free Semigroups
##
#############################################################################

#############################################################################
##
#M  GreensRRelation(<semigroup>)
#M  GreensLRelation(<semigroup>)
#M  GreensJRelation(<semigroup>)
#M  GreensDRelation(<semigroup>)
#M  GreensHRelation(<semigroup>)
##
##  Green's relations for free semigroups
##
##
InstallMethod(GreensRRelation, "for free semigroups", true,
        [IsSemigroup and IsFreeSemigroup], 0,
    function(s)
        Info(InfoWarning,1,
            "Green's relations for infinite semigroups is not supported");
        return fail;
    end);

InstallMethod(GreensLRelation, "for free semigroups", true,
        [IsSemigroup and IsFreeSemigroup], 0,
    function(s)
        Info(InfoWarning,1,
            "Green's relations for infinite semigroups is not supported");
        return fail;
    end);

InstallMethod(GreensJRelation, "for free semigroups", true,
        [IsSemigroup and IsFreeSemigroup], 0,
    function(s)
        Info(InfoWarning,1,
            "Green's relations for infinite semigroups is not supported");
        return fail;
    end);

InstallMethod(GreensDRelation, "for free semigroups", true,
        [IsSemigroup and IsFreeSemigroup], 0,
    function(s)
        Info(InfoWarning,1,
            "Green's relations for infinite semigroups is not supported");
        return fail;
    end);

InstallMethod(GreensHRelation, "for free semigroups", true,
        [IsSemigroup and IsFreeSemigroup], 0,
    function(s)
        Info(InfoWarning,1,
            "Green's relations for infinite semigroups is not supported");
        return fail;
    end);

#############################################################################
##
#M  GreensRRelation(<semigroup>)
#M  GreensLRelation(<semigroup>)
#M  GreensJRelation(<semigroup>)
#M  GreensDRelation(<semigroup>)
#M  GreensHRelation(<semigroup>)
##
##  If none of the methods are applicable then force the issue
##  and try to enumerator the semigroup. If successful then
##  use the generic finite case. 
##
##  This routine might not complete in the very large finite case or
##  infinite case
##
##
RedispatchOnCondition(GreensRRelation,true,[IsSemigroup],[IsFinite],0);
RedispatchOnCondition(GreensLRelation,true,[IsSemigroup],[IsFinite],0);
RedispatchOnCondition(GreensJRelation,true,[IsSemigroup],[IsFinite],0);
RedispatchOnCondition(GreensDRelation,true,[IsSemigroup],[IsFinite],0);
RedispatchOnCondition(GreensHRelation,true,[IsSemigroup],[IsFinite],0);

#############################################################################
##
#E
