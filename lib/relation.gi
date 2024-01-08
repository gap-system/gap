#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the implementation for binary relations, equivalence
##  relations and equivalence classes on and over sets.
##
##  If the underlying set is the set of n points {1..n} then a special
##  representation is used to represent binary relations over them.
##
##  Maintenance and further development by:
##  Robert Arthur
##  Robert F. Morse
##  Andrew Solomon
##
##

############################################################################
##
##  Table of Contents for relation.gi
##      A. Representations
##         1. Binary Relations (general)
##         2. Binary Relation on points i.e. domain [1..n]
##         3. Equivalence Relations
##         4. Equivalence Class
##
##      B. Constructor functions for binary relations (general)
##         1. Identity relation
##         2. Empty relation
##
##      C. Properties of Binary relations (general case)
##         1. IsReflexive
##         2. IsSymmetric
##         3. IsTransitive
##         4. IsAntisymmetric
##         5. IsPreOrder
##         6. IsPartialOrder
##         7. IsEquivalenceRelation
##
##      D. Closure operations for binary relations (general case)
##         1. Reflexive
##         2. Symmetric
##         3. Transitive
##         4. HasseDiagram
##         5. StronglyConnectedComponents
##
##      E. Constructors for binary relations on points
##         1. BinaryRelationOnPoints (= BinaryRelationByListOfImages)
##         2. Random binary relation on n points
##         3. Identity relation
##         4. Empty relation
##         5. AsBinaryRelationOnPoints
##
##      F. Special attributes for binary relations on points
##         1. Successors (= ImagesListOfBinaryRelation)
##         2. DegreeOfBinaryRelation
##
##      G. Properties of binary relations on points
##         (Same properties as general case only using the specialized
##          representation)
##
##      H. Closure operations for binary relations on points
##         (Same operations as general case only using the specialized
##          representation)
##
##      I. Operations and methods for binary relations on points
##         1. ImagesElm (compatibility with GeneralMapping)
##         2. PreImagesElm (compatibility with GeneralMapping)
##         3. \=, \in, \<
##         4. \* for relations, transformations, and permutation
##         5. Set operations \+, \-  (union, difference)
##         6. \^, POW  for points, sets, zero
##         7. One, InverseOp
##         8. PrintObj
##
##      J. Constructors for equivalence relations (TOCJ)
##         1. EquivalenceRelationByPartition
##         2. EquivalenceRelationByRelation
##         3. EquivalenceRelationByProperty
##         4. EquivalenceRelationByPairs
##
##      K. Attributes operations and methods of equivalence relations
##         1. EquivalenceRelationPartition
##         2. GeneratorsOfEquivalenceRelationPartition
##         3. JoinEquivalenceRelations
##         4. MeetEquivalenceRelations
##         5. \=
##         6. ImagesElm (compatibility with GeneralMapping)
##         7. PreImagesElm (compatibility with GeneralMapping)
##         8. PrintObj
##
##      L. Constructors of equivalence classes
##         1. EquivalenceClassOfElement
##         2. EquivalenceClasses
##
##      M. Operations and methods of equivalence classes
##         1. \=, \in
##         2. PrintObj, Enumerator
##         3. \<
##         4. ImagesRepresentative
##         6. PreImagesRepresentative
##
############################################################################
############################################################################

############################################################################
##
##    Representations TOC-A
##
############################################################################

############################################################################
##
#R  IsBinaryRelationDefaultRep(<obj>)
##
##  Representation for a binary relation on an arbitrary set of elements
##
DeclareRepresentation("IsBinaryRelationDefaultRep",
        IsAttributeStoringRep, []);

############################################################################
##
#R  IsBinaryRelationOnPointsRep(<obj>)
##
##  Special case that the underlying set is the points 1..n
##
DeclareRepresentation("IsBinaryRelationOnPointsRep",
        IsAttributeStoringRep, []);

############################################################################
##
#R  IsEquivalenceRelationDefaultRep(<obj>)
##
##  Representation of generatl equivalence classes
##
DeclareRepresentation("IsEquivalenceRelationDefaultRep",
        IsAttributeStoringRep, []);

#############################################################################
##
#R  IsEquivalenceClassDefaultRep( <M> )
##
##  The default representation for equivalence classes will be to store its
##  underlying relation, and a single canonical element of the class.
##  Representation specific methods are installed here.
##
DeclareRepresentation("IsEquivalenceClassDefaultRep", IsAttributeStoringRep
        and IsComponentObjectRep, rec());

############################################################################
############################################################################

############################################################################
##
##  Special constructors for binary relations
##
############################################################################
InstallGlobalFunction(IdentityBinaryRelation,
    function(d)
        local rel;
        if not IsDomain(d) and not IsPosInt(d) then
            Error("error - requires a domain or positive integer");
        fi;
        if IsDomain(d) then
            rel := IdentityMapping(d);
        else
            rel := BinaryRelationOnPointsNC(List([1..d],i->[i]));
        fi;
        SetIsReflexiveBinaryRelation(rel,true);
        SetIsSymmetricBinaryRelation(rel,true);
        SetIsTransitiveBinaryRelation(rel,true);

        return rel;
    end);

InstallGlobalFunction(EmptyBinaryRelation,
    function(d)
        if not IsDomain(d) and not IsPosInt(d) then
            Error("error - requires a domain or positive integer");
        fi;
        if IsDomain(d) then
            return GeneralMappingByElements(d,d,[]);
        else
            return BinaryRelationOnPointsNC(List([1..d],i->[]));
        fi;
    end);

InstallGlobalFunction(BinaryRelationByElements,
    function(d,elms)
        return GeneralMappingByElements(d,d,elms);
    end);

############################################################################
##
##  Properties of binary relations on arbitrary sets
##
############################################################################

############################################################################
##
#P  IsReflexiveBinaryRelation(<rel>)
##
InstallMethod(IsReflexiveBinaryRelation,
              "reflexive test binary relation", true,
              [IsBinaryRelation], 0,
    function(m)
        local e;

        # test for the one infinite case known to be reflexive
        if HasIsOne(m) and IsOne(m) then
            return true;
        fi;

        # otherwise iterate through the relation's source
        for e in Source(m) do
            if not e in Images(m,e) then
                return false;
            fi;
        od;
        return true;
    end);

############################################################################
##
#P  IsSymmetricBinaryRelation(<rel>)
##
##  Depends on Images and Preimages returning SSorted lists.
##

InstallMethod(IsSymmetricBinaryRelation,
        "symmetric test binary relation", true, [IsBinaryRelation], 0,
    function(m)
        local e,el;

        # test for trivial relation
        if HasIsOne(m) and IsOne(m) then
            return true;
        fi;

        # the only elements needed to be considered are those
        # involved in the underlying relation (which must be finite)
        # the domain itself can be infinite.
        el := Set(Concatenation(
                      List(Enumerator(UnderlyingRelation(m)),x->[x[1],x[2]])));

        for e in el do
            if not PreImages(m,e)=Images(m,e) then
                return false;
            fi;
        od;
        return true;
    end);

############################################################################
##
#P  IsTransitiveBinaryRelation(<rel>)
##
##  Assumes that Images returns a sorted list
##
InstallMethod(IsTransitiveBinaryRelation,
        "transitive test binary relation", true, [IsBinaryRelation], 0,
    function(m)
        local e,el,i,im;

        # test for trivial relation
        if HasIsOne(m) and IsOne(m) then
            return true;
        fi;

        # the only elements needed to be considered are those
        # involved in the underlying relation (which must be finite)
        # the domain itself can be infinite.
        el := Set(Concatenation(
                      List(Enumerator(UnderlyingRelation(m)),x->[x[1],x[2]])));

        for e in el do
            im := Images(m,e);
            for i in im do
                if not IsSubset(im,Images(m,i)) then
                    return false;
                fi;
            od;
        od;
        return true;
    end);

############################################################################
##
#P  IsAntisymmetricBinaryRelation(<rel>)
##
InstallMethod(IsAntisymmetricBinaryRelation,
        "test for Antisymmetry of a binary relation", true,
        [IsBinaryRelation], 0,
    function(rel)
        local e,el,i;

        # test for trivial relation
        if HasIsOne(rel) and IsOne(rel) then
            return true;
        fi;

        # the only elements needed to be considered are those
        # involved in the underlying relation (which must be finite)
        # the domain itself can be infinite.
        el := Set(Concatenation(
                  List(Enumerator(UnderlyingRelation(rel)),x->[x[1],x[2]])));

        for e in el do
            i := IntersectionSet(PreImages(rel,e),Images(rel,e));
            if not IsEmpty(i) and not i=[e] then
                return false;
            fi;
        od;
        return true;

    end);

############################################################################
##
#P  IsPreOrderBinaryRelation(<rel>)
##
InstallMethod(IsPreOrderBinaryRelation,
        "test for whether a binary relation is a preorder", true,
        [IsBinaryRelation], 0,
    function(rel)
        return
            IsTotal(rel) and
            IsReflexiveBinaryRelation(rel) and
            IsTransitiveBinaryRelation(rel);
    end);

############################################################################
##
#P  IsPartialOrderBinaryRelation(<rel>)
##
InstallMethod(IsPartialOrderBinaryRelation,
        "test for whether a binary relation is a partial order", true,
        [IsBinaryRelation], 0,
    function(rel)
        return
            IsTotal(rel) and
            IsReflexiveBinaryRelation(rel) and
            IsTransitiveBinaryRelation(rel) and
            IsAntisymmetricBinaryRelation(rel);
    end);

#############################################################################
##
#P  IsPartialOrderBinaryRelation(<rel>)
##
InstallMethod(IsLatticeOrderBinaryRelation,
        "test for whether a binary relation is a lattice order", true,
        [IsBinaryRelation],0,
function(rel)
  local a,b,  # elements of the relation
        intersection, # intersection of downsets of a and b
        nrel; # new relation defined on the intersection

  # a lattice order is defined on a partial order
  if not IsPartialOrderBinaryRelation(rel) then
    return false;
  fi;

  # checking the existence of a top element (unique maximal)
  if not Number(Source(rel), x->[x]=Images(rel,x)) = 1 then
    return false;
  fi;

  ## checking the existence of a meet for each pair
  for a in Source(rel) do
    for b in Source(rel) do
      # intersecting downsets
      intersection := Intersection(PreImages(rel,b),PreImages(rel,a));
      # new relation on the intersection induced by the original relation
      nrel := PartialOrderByOrderingFunction(
                      Domain(intersection),
                      function(x,y) return y in Images(rel,x);end);
      # if this new order does not have a top, then a meet b does not exist
      if not Number(Source(nrel), x->[x]=Images(nrel,x)) = 1 then
        return false;
      fi;
    od;
  od;
  return true;
end);

############################################################################
##
#P  IsEquivalenceRelation(<rel>)
##
InstallMethod(IsEquivalenceRelation,
        "test for equivalence relation", true,
        [IsBinaryRelation], 0,
    function(rel)
        return
            IsTotal(rel) and
            IsReflexiveBinaryRelation(rel) and
            IsSymmetricBinaryRelation(rel) and
            IsTransitiveBinaryRelation(rel);

    end );

############################################################################
############################################################################

############################################################################
##
##  Closure operations for binary relation on arbitrary sets
##
############################################################################

############################################################################
##
#O  ReflexiveClosureBinaryRelation(<Rel>)
##

##  This will die if the elements set of the underlying relation
##  is not finite. Can install more specific methods for relations over
##  infinite domains where we can do better.
##
InstallMethod(ReflexiveClosureBinaryRelation,
        "for binary relation", true, [IsBinaryRelation], 0,
    function(r)
        local ur,i,d, newrel;

        if HasIsReflexiveBinaryRelation(r) and
                 IsReflexiveBinaryRelation(r) then
            return r;
        fi;

        ur := ShallowCopy(AsSSortedList(UnderlyingRelation(r)));
        for i in Source(r) do
           AddSet(ur,DirectProductElement([i,i]));
        od;

        d := Source(r);

        newrel :=  GeneralMappingByElements(d,d,ur);
            SetIsReflexiveBinaryRelation(newrel, true);

        # ReflexiveClosure preserves Transitivity.
        if HasIsTransitiveBinaryRelation(r) then
            SetIsTransitiveBinaryRelation(newrel,
                IsTransitiveBinaryRelation(r));
        fi;

        # ReflexiveClosure preserves Symmetry.
        if HasIsSymmetricBinaryRelation(r) then
            SetIsSymmetricBinaryRelation(newrel,
                IsSymmetricBinaryRelation(r));
        fi;

        return newrel;

    end );

############################################################################
##
#O  SymmetricClosureBinaryRelation(<Rel>)
##

##  This will die if the elements set of the underlying relation
##  is not finite. Can install more specific methods for relations over
##  infinite domains where we can do better.
##
InstallMethod(SymmetricClosureBinaryRelation,
        "for binary relation", true, [IsBinaryRelation], 0,
    function(r)
        local ur,i,t,d, newrel;

        if HasIsSymmetricBinaryRelation(r) and
                 IsSymmetricBinaryRelation(r) then
            return r;
        fi;

        ur := UnderlyingRelation(r);
        t  := ShallowCopy(AsSSortedList(ur));
        for i in ur do
           AddSet(t,DirectProductElement([i[2],i[1]]));
        od;

        d := Source(r);
        newrel := GeneralMappingByElements(d,d,t);
        SetIsSymmetricBinaryRelation(newrel, true);

        # SymmetricClosure preserves Reflexivity.
        if HasIsReflexiveBinaryRelation(r) then
            SetIsReflexiveBinaryRelation(newrel, IsReflexiveBinaryRelation(r));
        fi;

        return newrel;

    end );

############################################################################
##
#O  TransitiveClosureBinaryRelation(<Rel>)
##
##
##  This is a modified version of the Floyd-Warshall method
##  of solving the all-pairs shortest-paths problem on a directed graph. Its
##  asymptotic runtime is O(n^3) where n is the size of the vertex set. It
##  only assumes there is an arbitrary (but fixed) ordering of the vertex set.
##

##  This will die if the elements set of the underlying relation
##  is not finite. Can install more specific methods for relations over
##  infinite domains where we can do better.
##
InstallMethod(TransitiveClosureBinaryRelation,
        "for binary relation", true,
        [IsBinaryRelation], 0,
    function(r)
        local t,        # a list of sets that provides an adjacency list
                        #   representation of the graph involved
              el,       # those elements involved in the underlying relation
              i,j,      # index variables
              p,        # 2-tuples that make up the closure
              d,        # Domain of the given relation
              newrel;   # New transitive relation

        # if the given relation is already transitive the just return
        if HasIsTransitiveBinaryRelation(r) and
                 IsTransitiveBinaryRelation(r) then
            return r;
        fi;

        # the only elements needed to be considered are those
        # involved in the underlying relation (which must be finite)
        # the domain itself can be infinite.
        el := Set(Concatenation(
                      List(Enumerator(UnderlyingRelation(r)),x->[x[1],x[2]])));

        ## Assumes Images returns a Sorted list -- makes sure t is
        ##     mutable as well as its elements
        t := List(el, i->ShallowCopy(Images(r,i)));

        # if \i in t[j] then everything related to \i
        # should be in t[j].
        for i in [1..Length(el)] do
            for j in [1..Length(el)]  do
                if el[i] in t[j] then
                    UniteSet(t[j],t[i]);
                fi;
            od;
        od;

        # Build the new set of underlying relations for the
        # transitive closure from the adjacency list
        p := [];
        for i in [1..Length(el)] do
            Append(p,List(t[i],x->DirectProductElement([el[i],x])));
        od;

        d := Source(r); ##Assumes source is a domain

        newrel :=  GeneralMappingByElements(d,d,p);
        SetIsTransitiveBinaryRelation(newrel, true);

        # TransitiveClosure preserves Reflexivity.
        if HasIsReflexiveBinaryRelation(r) then
            SetIsReflexiveBinaryRelation(newrel, IsReflexiveBinaryRelation(r));
        fi;

        # TransitiveClosure preserves Symmetry.
        if HasIsSymmetricBinaryRelation(r) then
            SetIsSymmetricBinaryRelation(newrel, IsSymmetricBinaryRelation(r));
        fi;

        return newrel;
    end);

############################################################################
##
#O  HasseDiagramBinaryRelation(<rel>)
##
##  If <rel> is a partial order then return the smallest relation contained
##  in <rel> whose reflexive and transitive closure is equal to <rel>
##
InstallMethod(HasseDiagramBinaryRelation,
        "for binary relation", true,
        [IsBinaryRelation], 0,
    function(rel)

        local i, j,           # iterators
              d,              # elements of underlying domain
              lc,             # pairs (x, covers(x)) for x in d
              tups,           # elements of the hasse diagram relation
              h,              # the resulting hasse diagram

                              # internal functions:
              HDBRMinElts,    #    to find minimal elements
              HDBREltCovers,  #    to find the cover of an element
              HDBRListCovers; #    to find the set of covers

        while not IsPartialOrderBinaryRelation(rel) do
            Error("Relation ",rel," is not a partial order");
        od;

        ## return the minimal elements of a list under rel
        HDBRMinElts := function(list, rel)

            ## x minimal if
            ##  {y in list | y<>x and y in PreImagesElm( rel,x)} is empty
            ##
            return Filtered(list,
              x->IsEmpty(Filtered(list, y-> (y <> x) and
                                              (y in PreImagesElm(rel,x)))));
        end;

        ## return the elements which cover x in rel
        HDBREltCovers :=  function(x, rel)
            local xunder;

            xunder := Filtered(ImagesElm(rel,x), y-> y <> x);
            return HDBRMinElts(xunder,rel);
        end;

        ## for a list, return the set of pairs (x, covers(x))
        HDBRListCovers := function(list,rel)
            return List(list, x->[x, HDBREltCovers(x, rel)]);
        end;

        d := UnderlyingDomainOfBinaryRelation(rel);
        lc := HDBRListCovers(AsList(d), rel);
        tups := [];
        for i in lc do
            for j in i[2] do
                Append(tups, [DirectProductElement([i[1], j])]);
            od;
        od;
        h := GeneralMappingByElements(d,d, tups);
        SetIsHasseDiagram(h, true);
        SetPartialOrderOfHasseDiagram(h,rel);
        return h;
    end);

#############################################################################
##
#F  PartialOrderByOrderingFunction(<dom>,<orderfunc>
##
##  constructs a partial order whose elements are from the domain <dom>
##  and are ordered using the ordering function <orderfunc>.
##
InstallGlobalFunction(PartialOrderByOrderingFunction,
    function(d,of)
        local i,j,        # iterators
              tup,        # set of defining tuples
              po;         # resulting partial order

        ## Check the input
        ##
        if not IsDomain(d) then
            Error("Partial Orders are only constructible over domains");
        fi;

        ## Construct a set of tuples which defines the partial order
        ##
        tup :=[];
        for i in d do
            for j in d do
                if of(i,j) then
                    Add(tup,DirectProductElement([i,j]));
                fi;
            od;
        od;
        po := BinaryRelationByElements(d,tup);

        ## If the relation constructed is not a partial order return fail
        ##
        if not IsReflexiveBinaryRelation(po) or
           not IsTransitiveBinaryRelation(po) or
           not IsAntisymmetricBinaryRelation(po) then
            return fail;
        else
            return po;
        fi;
    end);


############################################################################
##
#O  StronglyConnectedComponents(<R>)
##
##  returns an equivalence relation on the vertices of the relation.
##
InstallMethod(StronglyConnectedComponents, "for general binary relations",
        true, [IsBinaryRelation],0,
    function(rel)
        local r,        # representation of rel as a binary relation on points
              e,        # Equivalence relation representation of the
                        # predecessor subgraph
              s;        # Sorted list of the source of rel

        ## Convert rel to a relation on points
        ##
        r := AsBinaryRelationOnPoints(rel);

        ## Call the kernel function to find the strongly connected
        ## components
        ##
        e := STRONGLY_CONNECTED_COMPONENTS_DIGRAPH(Successors(r));

        ## Eliminate singletons
        e := Filtered(e, i->Length(i)>1);

        s := AsSSortedList(Source(rel));
        return EquivalenceRelationByPartitionNC(Source(rel),
                   List(e, i->s{i}));
    end);

############################################################################
############################################################################

############################################################################
##           #########################################
##           ##                                     ##
##           ##   Binary Relations on Points TOCJ   ##
##           ##                                     ##
##           #########################################
############################################################################

############################################################################
##
##  Properties, Operations, and Methods for binary relations on points
##
############################################################################

############################################################################
##  For compatibility with earlier versions
##
DeclareSynonym("ImagesListOfBinaryRelation",Successors);
DeclareSynonym("BinaryRelationByListOfImages", BinaryRelationOnPoints);
DeclareSynonym("BinaryRelationByListOfImagesNC", BinaryRelationOnPointsNC);

############################################################################
##
##  Constructors for binary relations on points
##
############################################################################

############################################################################
##
#F  BinaryRelationOnPoints( <list> )
#F  BinaryRelationOnPointsNC( <list> )
##
InstallGlobalFunction(BinaryRelationOnPointsNC,
    function( lst )

        local d,     # Degree of relation
              fam,   # Family of relation
              rel;   # binary relation object

        d:= Length(lst);
        fam:= GeneralMappingsFamily(FamilyObj(1), FamilyObj(1));
        rel:= Objectify(NewType(fam, IsBinaryRelation and
                  IsBinaryRelationOnPointsRep and
                      IsNonSPGeneralMapping), rec());

        SetSource(rel, Domain([1..d]));
        SetRange(rel, Domain([1..d]));
        SetSuccessors(rel, List(lst,AsSSortedList));
        SetDegreeOfBinaryRelation(rel,d);

        return rel;
    end);

InstallGlobalFunction(BinaryRelationOnPoints,
    function( lst )

        ## Check to see if the given list is dense
        #
        if not IsDenseList(lst) then
            Error("List, ",lst,",must be dense");
        fi;

        ## Check to see if the list defines a relation on 1..n
        #
        if not ForAll(Flat(lst),x->x in [1..Length(lst)]) then
            Error("List ,", lst,", does not represent a binary relation on 1 .. n");
        fi;

        return BinaryRelationByListOfImagesNC(lst);
    end);

############################################################################
##
#F  AsBinaryRelationOnPoints(<rel>)
#F  AsBinaryRelationOnPoints(<trans>)
#F  AsBinaryRelationOnPoints(<perm>)
##
##  return the relation on n points represented by general relation,
##  transformation or permutation, If <rel> is a binary relation on points
##  then just return <rel>.
##
InstallGlobalFunction(AsBinaryRelationOnPoints,
    function(rel)
        local el;

        if IsTransformation(rel) then
            return BinaryRelationTransformation(rel);
        fi;

        if IsPerm(rel) then
            return AsBinaryRelationOnPoints(AsTransformation(rel));
        fi;

        if IsBinaryRelation(rel) and
               IsBinaryRelationOnPointsRep(rel) then
            return rel;
        fi;

        if IsBinaryRelation(rel) then
            el := AsSSortedList(Source(rel));
            return BinaryRelationOnPoints(
                List(el, i->List(Images(rel,i),j->Position(el,j))));
        fi;
    end);

############################################################################
##
#F  RandomBinaryRelationOnPoints(n)
##
############################################################################
InstallGlobalFunction(RandomBinaryRelationOnPoints,
    function(n)
        if not IsPosInt(n) then
            Error("error, <n> must be a positive integer");
        fi;
        return BinaryRelationOnPointsNC(
            List([1..n],i->List([1..Random(1,n)],j->Random(1,n))));
    end);

############################################################################
##
##  Properties of binary relations on points
##
############################################################################

############################################################################
##
#P  IsReflexiveBinaryRelation(<rel>)
#P  IsSymmetricBinaryRelation(<rel>)
#P  IsTransitiveBinaryRelation(<rel>)
#P  IsAnitsymmetricBinaryRelation(<rel>)
#P  IsPreOrderBinaryRelation(<rel>)
#P  IsPartialOrderBinaryRelation(<rel>)
#P  IsEquivalenceRelation(<rel>)
##
##
InstallMethod(IsReflexiveBinaryRelation, "for binary relations on points",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep],0,
    rel -> ForAll([1..DegreeOfBinaryRelation(rel)],
               i->i in Successors(rel)[i])
    );

InstallMethod(IsSymmetricBinaryRelation, "for binary relations on points",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep],0,
    rel -> ForAll([1..DegreeOfBinaryRelation(rel)],
             i-> ForAll(Successors(rel)[i], j-> i in Successors(rel)[j] ))
    );

InstallMethod(IsTransitiveBinaryRelation, "for binary relations on points",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep],0,
    rel -> ForAll([1..DegreeOfBinaryRelation(rel)], i->
               ForAll(Successors(rel)[i], j->
                   IsSubset(Successors(rel)[i],Successors(rel)[j])))
    );

InstallMethod(IsAntisymmetricBinaryRelation, "for binary relations on points",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep],0,
    rel -> ForAll([1..DegreeOfBinaryRelation(rel)], i->
               ForAll(Successors(rel)[i],
                   j-> j=i or (not j=i and not i in Successors(rel)[j])))
    );

InstallMethod(IsPreOrderBinaryRelation, "for binary relations on points",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep],0,
    rel -> IsReflexiveBinaryRelation(rel) and IsTransitiveBinaryRelation(rel)
    );

InstallMethod(IsPartialOrderBinaryRelation, "for binary relations on points",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep],0,
    rel -> IsPreOrderBinaryRelation(rel) and IsAntisymmetricBinaryRelation(rel)
    );

InstallMethod(IsEquivalenceRelation, "for binary relations on points",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep],0,
    rel -> IsReflexiveBinaryRelation(rel) and IsSymmetricBinaryRelation(rel)
               and IsTransitiveBinaryRelation(rel)
    );

############################################################################
##
##  Closure operations of binary relations on points
##
############################################################################

############################################################################
##
#O  ReflexiveClosureBinaryRelation(<rel>)
#O  SymmetricClosureBinaryRelation(<rel>)
#O  TransitiveClosureBinaryRelation(<rel>)
##
##
InstallMethod(ReflexiveClosureBinaryRelation, "for binary relations on points",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep],0,
    rel -> BinaryRelationOnPointsNC(
        List([1..DegreeOfBinaryRelation(rel)], i->
            Union2(Successors(rel)[i],[i])))
    );

InstallMethod(SymmetricClosureBinaryRelation, "for binary relations on points",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep],0,
    function(rel)
        local suc,     #successors of given relation
              i,j,     #Index variables
              newrel;  #new relation which is the symmetric closure

        suc := List(Successors(rel),ShallowCopy);
        for i in [1..DegreeOfBinaryRelation(rel)] do
            for j in Successors(rel)[i] do
                UniteSet(suc[j],[i]);
            od;
        od;

        newrel := BinaryRelationOnPointsNC(suc);
        if HasIsReflexiveBinaryRelation(rel) then
            SetIsReflexiveBinaryRelation(newrel, IsReflexiveBinaryRelation(rel));
        fi;

        return newrel;
    end);

InstallMethod(TransitiveClosureBinaryRelation, "for binary relations on points",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep],0,
    function(rel)
        local i,j,    #index variables
              suc;    #successors of given relation

        suc := List(Successors(rel),ShallowCopy);

        # if \i in suc[j] then everything related to \i
        # should be in suc[j].
        for i in [1..DegreeOfBinaryRelation(rel)] do
            for j in [1..DegreeOfBinaryRelation(rel)]  do
                if i in suc[j] then
                    UniteSet(suc[j],suc[i]);
                fi;
            od;
        od;
        return BinaryRelationOnPointsNC(suc);
    end);

#############################################################################
##
##  Methods that allow binary relations on points to act and work as
##  IsEndoGeneralMappings but making use of their specialized representations
##
#############################################################################

#############################################################################
##
#M  ImagesElm( <rel>, <n> )
##
##  For binary relations over [1..n] represented as a list of images
##
InstallMethod(ImagesElm,
        "for binary relations over [1..n] with images list",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep, IsPosInt], 0,
    function( rel, n )
        if not n in [1..DegreeOfBinaryRelation(rel)] then
            Error("<n> is not in Domain of ", rel);
        fi;
        return Successors(rel)[n];
    end);

#############################################################################
##
#M  PreImagesElm( <rel>, <n> )
##
##  For binary relations over [1..n] represented as a list of images
##
InstallMethod(PreImagesElm,
        "for binary rels over [1..n] with images list",
        true, [IsBinaryRelation and IsBinaryRelationOnPointsRep, IsPosInt], 0,
    function( rel, n )
        return Filtered([1..DegreeOfBinaryRelation(rel)],
            i->n in Successors(rel)[i]);
    end);

#############################################################################
##
#A  Successors( <rel> )
##
##  Returns the list of images of a binary relation.   If the underlying
##  domain of the relation is not [1..n] then an error is signalled.
##
InstallMethod(Successors, "for a generic relation", true,
        [IsBinaryRelation], 0,
    function(r)
        local eldom;   # Elements of the domain

        eldom:= AsSSortedList(UnderlyingDomainOfBinaryRelation(r));
        if not IsRange(eldom) or eldom[1] <> 1 then
            Error("Operation only makes sense for relations over [1..n]");
        fi;

        return List(eldom, i-> ImagesElm(r,i));
    end);

#############################################################################
##
##  Arithmetic and boolean methods on binary relations on points
##
##  \=  True if successors lists are equal (by construction each image is
##      a set of integers so there is a canonical form to check)
##
##  \in determines whether a tuple [x,y] in rel
##
##  \<  compares successors list
##
#############################################################################

#############################################################################
##
#M  \= ( <rel1>, <rel2> )
##
##  For binary relations on n points
##
InstallMethod( \=, "for binary relss over [1..n] with images list", true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep,
        IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function(rel1, rel2)
        return Successors(rel1) = Successors(rel2);
    end);

#############################################################################
##
#M  \in ( <tup>, <rel> )
##
##  For binary relations on n points
##
InstallMethod( \in, "for binary rels over [1..n] with images list", true,
        [IsList, IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function( tup, rel )
        if Length(tup) <> 2 then
            Error("List ", tup, " must be of length 2");
        fi;
        return tup[2] in Successors(rel)[tup[1]];
    end);

#############################################################################
##
#M  \< ( <rel>, <rel> )
##
##  For binary relations on n points
##
InstallMethod( \<, "for binary rels over [1..n] with images list", true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep,
         IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function( relL, relR )
        return Successors(relL) < Successors(relR);
    end);

#############################################################################
##
#M  \* ( <rel>, <rel> )
#M  \* ( <trans>, <rel> )
#M  \* ( <rel>, <trans> )
#M  \* ( <perm>, <rel> )
#M  \* ( <rel>, <perm> )
#M  \* ( <list>, <rel> )
#M  \* ( <rel>, <list> )
##
##  For binary relations on n points
##
InstallMethod( \*, "for binary relations on points", true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep,
         IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function( relL, relR )

        if DegreeOfBinaryRelation(relL)<>DegreeOfBinaryRelation(relR) then
            Error("The binary relations must have the same degree");
        fi;
        return BinaryRelationOnPoints(
            List([1..DegreeOfBinaryRelation(relL)],i->
                 Union(List(Successors(relL)[i],j->Successors(relR)[j]))));
    end);

InstallOtherMethod( \*, "for transformation and binary relation on points", true,
        [IsTransformation,
         IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function( t, rel )

        if DegreeOfTransformation(t)<>DegreeOfBinaryRelation(rel) then
            Error("Transformation and binary relation must have the same degree");
        fi;
        return BinaryRelationOnPoints(
            List([1..DegreeOfTransformation(t)],i->
                 Successors(rel)[i^t]));
    end);

InstallOtherMethod( \*, "for binary relation on points and transformation", true,
        [IsBinaryRelation and
         IsBinaryRelationOnPointsRep, IsTransformation], 0,
    function( rel, t )
        return rel * BinaryRelationTransformation(t);
    end);

InstallOtherMethod( \*, "for binary relation on points and permutation", true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep, IsPerm], 0,
    function( rel, p )
        return rel * AsTransformation(p,DegreeOfBinaryRelation(rel));
    end);

InstallOtherMethod( \*, "for permutation and binary relation on points", true,
        [IsPerm, IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function( p, rel )
        return AsTransformation(p,DegreeOfBinaryRelation(rel)) * rel;
    end);

InstallOtherMethod( \*, "for binary relation on points and list", true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep, IsListOrCollection], 0,
    function( rel,lst )
        return List(lst, i->rel*i);
    end);

InstallOtherMethod( \*, "for list and binary relation on points", true,
        [IsListOrCollection, IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function( lst, rel )
        return List(lst, i->i*rel);
    end);

#############################################################################
##
#M  \+ ( <rel>, <rel> )      -- Union
#M  \- ( <trans>, <rel> )    -- Difference
##
##  Set operations for binary relations on points
##     Union
##     Difference
##
InstallMethod( \+, "for binary relations on points", true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep,
         IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function( rel1, rel2 )

        if DegreeOfBinaryRelation(rel1) <> DegreeOfBinaryRelation(rel2) then
            Error("the union of two relations on points must have the same degree");
        fi;
        return
            BinaryRelationOnPoints(List([1..DegreeOfBinaryRelation(rel1)],
                i-> Union(Successors(rel1)[i],Successors(rel2)[i])));
    end);

InstallMethod( \-, "for binary relations on points", true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep,
         IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function( rel1, rel2 )

        if DegreeOfBinaryRelation(rel1) <> DegreeOfBinaryRelation(rel2) then
            Error("the difference of two relations on points must have the same degree");
        fi;
        return
            BinaryRelationOnPoints(List([1..DegreeOfBinaryRelation(rel1)],
                i-> Difference(Successors(rel1)[i],Successors(rel2)[i])));
    end);

#############################################################################
##
#M  \^ ( <int>, <rel> )      Images of an integer in domain
#M  \^ ( <trans>, <rel> )    Union of the images of the set
#M  \^ ( <list>, <rel> )     List of images for each element in the list
##
##
#############################################################################
##
#M  \^ ( <int>, <rel> )
##
##  For binary relations on points
##
InstallMethod( \^, "for binary relation on points and a positive int", true,
        [IsPosInt,
         IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function( i, rel )
        return ImagesElm(rel,i);
    end);

#############################################################################
##
#M  \^ ( <set>, <rel> )
##
##  For binary relations on points
##
InstallMethod( POW, "for binary relation on points and a set of integers",true,
        [IsListOrCollection,
         IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function( set, rel )
        return Set(Flat(Successors(rel){set}));
    end);

#############################################################################
##
#M  \^ ( <list>, <rel> )
##
##  For binary relations on points
##
InstallMethod( POW, "for binary relation on points and Zero",true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep, IsZeroCyc], 0,
    function( rel,z )
        return
            BinaryRelationOnPoints(List([1..DegreeOfBinaryRelation(rel)],i->[i]));
    end);

#############################################################################
##
#M  InverseOp( <rel> )
##
##  For binary relations on points
##
InstallMethod( InverseOp, "for binary relation on points and a set of integers",true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    function(rel)
          local d,suc,i,j;
          d := DegreeOfBinaryRelation(rel);
          suc := List([1..d],x->[]);
          for i in [1..d] do
              for j in Successors(rel)[i] do
                  AddSet(suc[j],i);
              od;
          od;
          return BinaryRelationOnPoints(suc);
    end);

#############################################################################
##
#M  One( <rel> )
##
##  For binary relations on points
##
InstallMethod( One, "for binary relation on points and a set of integers",true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
    rel -> BinaryRelationOnPoints(List([1..DegreeOfBinaryRelation(rel)],i->[i]))
    );

#############################################################################
##
#M      PrintObj( <C> )
##
##      Display binary relation on n points.
##
InstallMethod(PrintObj, "for a binary relation on  n points", true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep],0,
    function(rel)
        Print("Binary Relation on ",DegreeOfBinaryRelation(rel)," points");
    end);

############################################################################

############################################################################
##           #####################################
##           ##                                 ##
##           ##   Equivalence Relations  TOCJ   ##
##           ##                                 ##
##           #####################################
############################################################################

############################################################################
##
##   Constructors for Equivalence relations. Many of these construction
##   are actually closure operations e.g. find the smallest equivalence
##   relation containing a given relation.
##
############################################################################

#############################################################################
##
#F  EquivalenceRelationByPartition( <set>, <list> )
##
##
InstallGlobalFunction(EquivalenceRelationByPartition,
    function(X, subsX)
        local fam, rel;

        if not IsDomain(X) then
                Error("Equivalence relations only constructible over domains");
        fi;

        # make sure there are no repetitions
        if not IsSet(AsSortedList(Concatenation(subsX))) then
                Error("Input does not describe a partition");
        fi;

        #check that subsX is contained in X
        if not  (IsSubset(X, AsSortedList(Concatenation(subsX)))) then
                Error("Input does not describe a partition");
        fi;

        fam :=  GeneralMappingsFamily( ElementsFamily(FamilyObj(X)),
                ElementsFamily(FamilyObj(X)) );

        ## Get rid of singletons and possible empty blocks
        subsX := Filtered(subsX, i->Length(i)>1);

        # Create the default type for the elements.
        rel :=  Objectify(NewType(fam,
                IsEquivalenceRelation and IsEquivalenceRelationDefaultRep), rec());
        SetEquivalenceRelationPartition(rel, subsX);
        SetSource(rel, X);
        SetRange(rel, X);

        return rel;
    end);

#############################################################################
##
#F  EquivalenceRelationByPartitionNC( <set>, <list> )
##
##  No checks are performed except empty and singleton blocks are removed from
##  the partition given (if they exist).
##
InstallGlobalFunction(EquivalenceRelationByPartitionNC,
    function(X, subsX)
        local fam, rel;

        fam :=  GeneralMappingsFamily( ElementsFamily(FamilyObj(X)),
                ElementsFamily(FamilyObj(X)) );

        # Create the default type for the elements.
        rel :=  Objectify(NewType(fam,
                IsEquivalenceRelation and IsEquivalenceRelationDefaultRep), rec());

        ## The only assurance is singletons and empty blocks are removed
        ##
        SetEquivalenceRelationPartition(rel, Filtered(subsX, i->Length(i)>1));
        SetSource(rel, X);
        SetRange(rel, X);

        return rel;
    end);

#############################################################################
##
#F  EquivalenceRelationByRelation( <rel> )
##
##  Checks for special cases to improve efficiency otherwise
##  use general attributes and call EquivalenceRelationByPairs
##
InstallGlobalFunction(EquivalenceRelationByRelation,
    function(r)
        local i,j,tups;

        ## Special cases that do not require finding the underlying
        ##     relation i.e. having the mapping methods find
        ##     all tuples using images of elements
        ##
        if IsBinaryRelation(r) and IsBinaryRelationOnPointsRep(r) then
            tups :=[];
            for i in [1..DegreeOfBinaryRelation(r)] do
                for j in Successors(r)[i] do
                   Add(tups, DirectProductElement([i,j]));
                od;
            od;
            return EquivalenceRelationByPairs(
                UnderlyingDomainOfBinaryRelation(r),tups);
        fi;

        if IsTransformation(r) then
            return EquivalenceRelationByRelation(
                BinaryRelationTransformation(r));
        fi;

        ## Need to use general mapping functions and compute underlying
        ##    relation
        ##
        return EquivalenceRelationByPairs(UnderlyingDomainOfBinaryRelation(r),
                   Enumerator(UnderlyingRelation(r)));
    end);

#############################################################################
##
#F  EquivalenceRelationByProperty( <domain>, <property> )
##
##  Create an equivalence relation on <domain> whose only defining
##  data is having the property <property>.
##
InstallGlobalFunction(EquivalenceRelationByProperty,
    function(X, property )
        local fam, rel;

        fam :=  GeneralMappingsFamily( ElementsFamily(FamilyObj(X)),
        ElementsFamily(FamilyObj(X)) );

        # Create the default type for the elements.
        rel :=  Objectify(NewType(fam, IsEquivalenceRelation
            and IsEquivalenceRelationDefaultRep and IsNonSPGeneralMapping), rec());
        SetSource(rel, X);
        SetRange(rel, X);
        Setter(property)(rel, true);

        return rel;
    end);

#############################################################################
##
#F  EquivalenceRelationByPairs( <D>, <pairs> )
#F  EquivalenceRelationByPairsNC( <D>, <pairs> )
##
##  Construct the smallest equivalence relation containing <pairs>
##
##  The closure algorithm uses a variant of Tarjan's set merge method.
##  It runs in nearly linear time, O(n g(n)) where g(n) is a slow growing function
##  (optimally the inverse of Ackerman's function)
##
##  The NC version assumes that <D> is a domain and <pairs> are tuples (or lists
##      of length 2) of the form (a,b) where a<>b
##
InstallGlobalFunction(EquivalenceRelationByPairsNC,
    function(d,pairs)
        local C,       #Set of given pairs of the form (a,b), a<>b
              i,j,     #index variables
              p1,p2,   #indexes to blocks to merge
              forest;  #a list of lists representing a forest
                       #    each tree in the forest have depth one
                       #    (full path compression)

        ##
        ## We are assuming pairs have been sanitized
        ##   all (a,b) a<>b
        ##
        ## Make a mutable copy of pairs
        ##
        if (IsSet(pairs)) or
           (HasIsDuplicateFreeList(pairs) and IsDuplicateFreeList(pairs)) then
            C := List(pairs,ShallowCopy);
        else
            C := DuplicateFreeList(List(pairs,ShallowCopy));
        fi;

        ##
        ## Use Tarjan's merge method to find the equivalence relation
        ##     generated by the pairs (expressed as a set of non-trivial
        ##     blocks determined by the input pairs).

        ## The first pair will be our starting forest.
        ##
        forest := [C[1]];

        ##
        ## Put each pair in its appropriate block and merge blocks
        ##     as necessary
        ##
        for i in C do

            p1 := Length(forest)+1;
            p2 := Length(forest)+1;

            for j in [1..Length(forest)] do
                if p1>Length(forest) and i[1] in forest[j] then
                    p1 := j;
                    if p2 <=Length(forest) then break; fi;
                fi;
                if p2>Length(forest) and i[2] in forest[j] then
                    p2 := j;
                    if p1<=Length(forest) then break; fi;
                fi;
            od;

            ##
            ## For the pair (a,b) if a is in one block and b is in another
            ##     merge the two blocks
            ##
            if p1<=Length(forest) and p2<=Length(forest) and not p1=p2 then
                Append(forest[p1],forest[p2]);
                Unbind(forest[p2]);
                if p2<Length(forest) then
                    forest[p2]:=Remove(forest);
                fi;

            ##
            ##  These cases are if only one of the components
            ##      is in a block
            ##
            elif p1<=Length(forest) and p2>Length(forest) then
                Add(forest[p1],i[2]);
            elif p2<=Length(forest) and p1>Length(forest) then
                Add(forest[p2],i[1]);
            ##
            ## Neither component is in a block
            ##
            ##
            elif p1>Length(forest) and p2>Length(forest) then
                Add(forest,i);
            fi;
        od;

        return EquivalenceRelationByPartitionNC(d,forest);

    end);

InstallGlobalFunction(EquivalenceRelationByPairs,
    function(d,pairs)

        local C,       #Set of given pairs of the form (a,b), a<>b
              i,j,     #index variables
              p1,p2,   #indexes to blocks to merge
              forest;  #a list of lists representing a forest
                       #    each tree in the forest have depth one
                       #    (full path compression)

        ## Parameter checking
        ##     d=domain, elms=list
        ##
        if not IsDomain(d) then
            Error("Equivalence relations only constructible over domains");
        fi;
        if not IsList(pairs) then
            Error("Second parameter must be a list of 2-tuples");
        fi;

        ## If no pairs are given return the diagonal equivalence
        ##
        if IsEmpty(pairs) then
            return EquivalenceRelationByPartitionNC(d,[]);
        fi;

        ## Make sure that all of the pairs are indeed pairs
        if ForAny(pairs,x->not Length(x)=2 ) then
            Error("Usage error, pairs must be tuples of length 2");
        fi;

        ## Make sure that all of the elements in the pairs are in
        ##    the domain
        if ForAny(pairs,x->not x[1] in d or not x[2] in d) then
            Error("One of more element pairs contain elements not in the domain");
        fi;

        ##
        ## Filter out all pairs of the form (a,a).
        ##   If this filtered set is empty return the diagonal
        ##   equivalence
        ## Make a mutable copy of pairs so we don't inadvertently alter
        ##   pairs
        ##
        C := List(Filtered(pairs,x->not x[1]=x[2]), ShallowCopy);

        ##
        ## Return diagonal relation if all pairs are of the form (a,a)
        ##
        if IsEmpty(C) then
            return EquivalenceRelationByPartitionNC(d,[]);
        fi;

        C := Set(C);

        return EquivalenceRelationByPairsNC(d,C);

    end);

#############################################################################
##
#A  EquivalenceRelationPartition(<equiv>)
##
##
InstallMethod( EquivalenceRelationPartition,
        "compute the partition for an arbitrary equiv rel", true,
        [IsEquivalenceRelation], 0,

    function( equiv )
        local part;

        if IsBinaryRelationOnPointsRep(equiv) then
            part := DuplicateFreeList(Successors(equiv));
            return Filtered(part, x->Length(x)>1);
        fi;

        return  EquivalenceRelationPartition(
                    EquivalenceRelationByPairs(Source(equiv),
                    AsList(UnderlyingRelation(equiv))));
    end);

#############################################################################
##
#M  JoinEquivalenceRelations( <equiv1>,<equiv2> )
#M  MeetEquivalenceRelations( <equiv1>,<equiv2> )
##
##  JoinEquivalenceRelations(<equiv1>,<equiv2>) -- form the smallest
##  equivalence relation containing both equivalence relations.
##
##  MeetEquivalenceRelations( <equiv1>,<equiv2> ) -- computes the
##  intersection of the two equivalence relations.
##
InstallMethod( JoinEquivalenceRelations,
        "join of two equivalence relations", true,
        [IsEquivalenceRelation, IsEquivalenceRelation], 0,
    function(er1, er2)
         if Source(er1)<>Source(er2) then
             Error("usage: <equiv1> and <equiv2> must have the same source");
         fi;
         return EquivalenceRelationByPairs(Source(er1),
              Concatenation( GeneratorsOfEquivalenceRelationPartition(er1),
                        GeneratorsOfEquivalenceRelationPartition(er2)) );
    end);

InstallMethod( MeetEquivalenceRelations,
        "meet of two equivalence relations", true,
        [IsEquivalenceRelation, IsEquivalenceRelation], 0,
    function(er1, er2)

        local part1,   # Partition for equivalence relation 1
              part2,   # Partition for equivalence relation 2
              part,    # Intersection of the two partitions
              meet,    # Meet equivalence relation
              i,j;     # index variables

        if Source(er1)<>Source(er2) then
            Error("usage: <equiv1> and <equiv2> must have the same source");
        fi;

        part1 := EquivalenceRelationPartition(er1);
        part2 := EquivalenceRelationPartition(er2);
        part  := [];

        ## Find the intersection of each pair of blocks
        ##
        for i in part1 do
            for j in part2 do
                Add(part, Intersection(i,j));
            od;
        od;

        ## Filter out non-singletons
        ##
        part := Filtered(part, x->Length(x)>1);

        meet := EquivalenceRelationByPairs(Source(er1),[]);
        meet!.EquivalenceRelationPartition := part;

        return meet;

    end);

#############################################################################
##
#A  GeneratorsOfEquivalenceRelationPartition( <equiv> )
##
##
InstallMethod(GeneratorsOfEquivalenceRelationPartition,
        "generators for an equivalence with a partition", true,
        [IsEquivalenceRelation], 0,
    function(equiv)
        local gens, b,j,part;

        part := EquivalenceRelationPartition(equiv);
        gens:=[];

        for b in part do
            for j in [1..Length(b)-1] do
                AddSet(gens,AsSSortedList([b[j],b[j+1]]));
            od;
        od;
        return gens;
    end);

#############################################################################
##
#M  \= for equivalence relations
##
InstallMethod(\=, "for eqivalence relations", IsIdenticalObj,
        [IsEquivalenceRelation, IsEquivalenceRelation], 0,
    function(x, y)

        local p,  ## partition
              f;  ## first partition

        ## Check if sources are equal
        ##
        if Source(x) <> Source(y)  then
            return false;
        fi;

        ## If images of each element is equal we have equal e.r.
        ##
        if HasSuccessors(x) and HasSuccessors(y) then
            return Successors(x)=Successors(y);
        fi;

        ## Look at partitions -- they are not in any canonical
        ##     form.
        ##
        if (HasEquivalenceRelationPartition(x) and
               HasEquivalenceRelationPartition(y)) then

            ## Similar lengths of partitions
            ##
            if Length(EquivalenceRelationPartition(x)) <>
                   Length(EquivalenceRelationPartition(y)) then
                return false;
            fi;

            ## Similar lengths of the partition elements
            ##
            if Set(EquivalenceRelationPartition(x), Length) <>
               Set(EquivalenceRelationPartition(y), Length) then
               return false;
            fi;

            ## OK need to take a deeper look at the partition
            ##

            for p in EquivalenceRelationPartition(x) do
                f := First(EquivalenceRelationPartition(y), i->p[1] in i);
                if f=fail then return false; fi;
                if not Set(f)=Set(p) then return false; fi;
            od;

            return true;

        else
            TryNextMethod();
        fi;
    end);

#############################################################################
##
#M  \in( <T>, <R> )
##
##  Checks whether a 2-tuple is contained in a relation.   Implementation
##  for an equivalence relation stored as a partition.
##
##  This method should be selected over all others since it assumes
##  that the partition information has already been computed.
##  It has been given a +1 rank which WILL NEED TUNING when  the
##  other methods are in.
##
InstallMethod(\in, "for eq relation with partition", true,
        [IsList, IsEquivalenceRelation and HasEquivalenceRelationPartition], 1,
    function(tup, rel)
        local f;   # first block that contains first tuple component

        if Length(tup) <> 2 then
            Error("Left hand side must be of length 2");
        elif FamilyObj(tup) <>
            FamilyObj(UnderlyingDomainOfBinaryRelation(rel)) then
            Error("Left hand side must contain elements of relation's domain");
        fi;

        ## if tuple is of the form (x,x) then it is in relation
        ##
        if tup[1]=tup[2] then
           return true;
        fi;

        ## we must have partition with (x,y) in it for result to be true
        ##
        f := First(EquivalenceRelationPartition(rel), b->tup[1] in b);

        if f=fail then
            return false;         ## no block contains tup[1]
        else
            return tup[2] in f;   ## tup[1] in non-trivial block
        fi;
    end);

#############################################################################
##
#M  ImagesRepresentative( <rel>, <elm> )  . . . for equivalence relations
##
InstallMethod( ImagesRepresentative, "equivalence relations",
        FamSourceEqFamElm, [IsEquivalenceRelation, IsObject], 0,
    function( map, elm )
        return elm;
    end);

#############################################################################
##
#M  PreImagesRepresentative( <rel>, <elm> )  . . . for equivalence relations
##
InstallMethod( PreImagesRepresentative, "equivalence relations",
        FamRangeEqFamElm, [IsEquivalenceRelation, IsObject], 0,
    function( map, elm )
        return elm;
    end);

#############################################################################
##
#M  ImagesElm( <rel>, <elm> )        for equivalence relations with partition
##
InstallMethod( ImagesElm,
        "for equivalence relation with partition and element",
        FamSourceEqFamElm,
        [IsEquivalenceRelation and HasEquivalenceRelationPartition,
         IsObject],0,
    function( rel, elm )
        local p;

        for p in EquivalenceRelationPartition(rel) do
            if elm in p then
                return p;
            fi;
        od;
        ## singleton case
        ##
        return [elm];
    end);

#############################################################################
##
#M  PreImagesElm( <rel>, <elm> )     for equivalence relations with partition
##
InstallMethod( PreImagesElm,
        "equivalence relations with partition and element",
        FamRangeEqFamElm,
        [IsEquivalenceRelation and HasEquivalenceRelationPartition,
         IsObject],0,
    function( rel, elm )
        ## Images and preimages are the same
        ##
        return ImagesElm(rel, elm);
    end);

#############################################################################
##
#M  PrintObj( <eqr> )                                for equivalence relation
##
InstallMethod( PrintObj, "for an equivalence relation", true,
        [ IsEquivalenceRelation ], 0,
    function( map )
        Print( "<equivalence relation on ", Source( map ), " >" );
    end );

#############################################################################
##
#M  EquivalenceClasses( <E> )
##
##  Wraparound function which calls the two-argument method
##
InstallMethod(EquivalenceClasses, "wraparound to call 2-argument version",
        true, [IsEquivalenceRelation], 0,
    e->EquivalenceClasses(e, UnderlyingDomainOfBinaryRelation(e))
    );

#############################################################################
##
#M  EquivalenceClasses( <E>, <C> )
##
##  Returns the list of equivalence classes of the equivalence relation <E> that intersect <C>.
##  This generic method will not terminate for an equivalence over an
##  infinite set.
##
InstallOtherMethod(EquivalenceClasses, "for a generic equivalence relation",
        true, [IsEquivalenceRelation, IsCollection], 0,
    function(E, D)

        local d, classes, iter, elm, p;

        ## If we already have a partition then return the equivalence
        ##     class with first element as represenative
        ##
        classes := [];
        if HasEquivalenceRelationPartition(E) then
            for p in EquivalenceRelationPartition(E) do
                for elm in p do
                    if elm in D then
                        Add(classes, EquivalenceClassOfElementNC(E, elm));
                        break;
                    fi;
                od;
            od;
            ## Get the singletons
            ##
            if Sum(List(EquivalenceRelationPartition(E),Length))<>Size(D) then
                d := Difference(AsSet(D), Concatenation(EquivalenceRelationPartition(E)));
                for p in d do
                    Add(classes, EquivalenceClassOfElementNC(E,p));
                 od;
            fi;
            return classes;
        fi;

        ## We iterate over the underlying domain, and build up the list
        ##     of classes as new ones are found.
        ##
        iter:= Iterator(D);

        classes:= [];
        for elm in iter do
            if ForAll(classes, x->not elm in x) then
                Add(classes, EquivalenceClassOfElementNC(E, elm));
            fi;
        od;
        return classes;
    end);


#############################################################################

############################################################################
##           #####################################
##           ##                                 ##
##           ##   Equivalence Classes    TOCJ   ##
##           ##                                 ##
##           #####################################
############################################################################

#############################################################################
##
#M  EquivalenceClassOfElement( <R>, <rep> )
#M  EquivalenceClassOfElementNC( <R>, <rep> )
##
##  Returns the equivalence class of an element <rep> with respect to an
##  equivalence relation <R>.   No calculation is performed at this stage.
##  We do not always wish to check that <rep> is in the underlying set
##  of <R>, since we may wish to use equivalence relations to perform
##  membership tests (for example when checking membership of a
##  transformation in a monoid, we use Greens relations and classes).
##
InstallMethod(EquivalenceClassOfElementNC, "no check", true,
        [IsEquivalenceRelation, IsObject], 0,
   function(rel, rep)

       local new;

       new:= Objectify(NewType(CollectionsFamily(FamilyObj(rep)),
                 IsEquivalenceClass and IsEquivalenceClassDefaultRep), rec());

       SetEquivalenceClassRelation(new, rel);
       SetRepresentative(new, rep);
       SetParent(new, UnderlyingDomainOfBinaryRelation(rel));
       return new;
   end);

InstallMethod(EquivalenceClassOfElement, "with checking", true,
        [IsEquivalenceRelation, IsObject], 0,
    function(rel, rep)

        if not rep in UnderlyingDomainOfBinaryRelation(rel) then
            Error("Representative must lie in underlying set of the relation");
        fi;

        return EquivalenceClassOfElementNC(rel, rep);
    end);

#############################################################################
##
#M  PrintObj( <C> )
##
##  Display an equivalence class.
##
InstallMethod(PrintObj, "for an eq. class", true,
        [IsEquivalenceClass],0,
    function(c)
        Print("{", Representative(c),"}");
    end);

#############################################################################
##
#M  \in( <x>, <C> )
##
##  Checks whether <x> is contained in the equivalence class <C>
##  If <C> is infinite, this will not necessarily terminate.
##
InstallMethod(\in, "for element and equivalence class", true,
        [IsObject, IsEquivalenceClass], 0,
    function(x, C)
        local  iter;       # iterator of the equivalence class

        # first ensure that <x> is in the right family
        if FamilyObj(x) <>
                ElementsFamily(FamilyObj(Source(EquivalenceClassRelation(C)))) then
             Error("incompatible arguments for \\in");
        fi;

        # now just enumerate the elements of <C> until we come to <x>
        iter := Iterator(C);
        while not IsDoneIterator(iter) do
            if x = NextIterator(iter) then
                return true;
            fi;
        od;
        return false;
    end);

#############################################################################
##
#M  Enumerator( <C> )
##
##  An enumerator for equivalence classes of relations
##  where we know the Partition
##
InstallMethod( Enumerator, "for equivalence classes", true,
        [IsEquivalenceClass], 0,
    function( C )

        local rel,     # relation for which C is a class
              block,   # the block where we find rep
              rep;     # an element of C


              rel := EquivalenceClassRelation(C);
              rep := Representative(C);

        if not HasEquivalenceRelationPartition(rel) then
            # resort to mapping code
            return Enumerator(ImagesElm(rel,rep));
        fi;


        block := First(EquivalenceRelationPartition(rel), x->rep in x);
        # the singleton case - singleton blocks aren't stored
        if block = fail then
            return [rep];
        fi;
        return Enumerator(block);
    end);

#############################################################################
##
#M  \= ( <C1>, <C2> )
##
##  Equality of equivalence classes
##
InstallMethod(\=, "for two equivalence classes",
        IsIdenticalObj, [IsEquivalenceClass, IsEquivalenceClass], 0,
    function(x, y)
        return Representative(x) in y;
    end);

#############################################################################
##
#M  \<( <x1>, <x2> )
##
##  The total order on equivalence classes used for creating sets, etc.
##  Relies on the total order of the underlying set. This is a
##  VERY INEFFICIENT method because it relies on finding the smallest
##  element of an equivalence class. AVOID USING THIS IF POSSIBLE!!
##
##
InstallMethod( \<, "for two equivalence classes", IsIdenticalObj,
        [IsEquivalenceClass, IsEquivalenceClass], 0,
    function( x1, x2 )
        return RepresentativeSmallest(x1) < RepresentativeSmallest(x2);
    end );

InstallMethod(AsPermutation, "for binary relations on points", true,
        [IsBinaryRelation and IsBinaryRelationOnPointsRep], 0,
function(rel)
    if not IsMapping(rel) then
             Error("error, <rel> must be a mapping");
    fi;
    return AsPermutation(Transformation(Flat(Successors(rel))));
end);
