#############################################################################
##
#W  relation.gi                  GAP library                   Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the implementation for binary relations on sets.
##
##  Maintenance and further development by:
##  Robert Arthur
##  Robert F. Morse
##  Andrew Solomon
##
##
Revision.relation_gi :=
    "@(#)$Id$";

############################################################################
##
#R  IsBinaryRelationDefaultRep(<obj>)
##
DeclareRepresentation("IsBinaryRelationDefaultRep", 
	IsAttributeStoringRep ,[]);

############################################################################
##
#R  IsEquivalenceRelationDefaultRep(<obj>)
##
DeclareRepresentation("IsEquivalenceRelationDefaultRep", 
	IsAttributeStoringRep ,[]);

############################################################################
##
#M	UnderlyingDomainOfBinaryRelation
##
##	This is simply a synonym for the Source of the relation when
##	considered as a general mapping.
##
DeclareSynonym("UnderlyingDomainOfBinaryRelation",Source);

############################################################################
##
#P  IsReflexiveBinaryRelation(<rel>)                                RFM
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
#P  IsSymmetricBinaryRelation(<rel>)                                RFM
##
##  Depends on Images and Preimages returning SSorted lists.
##

InstallMethod(IsSymmetricBinaryRelation,
              "symmetric test binary relation", true,
              [IsBinaryRelation], 0,
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
#P  IsTransitiveBinaryRelation(<rel>)                                RFM
##
##  Assumes that Images returns a sorted list
##
InstallMethod(IsTransitiveBinaryRelation,
              "transitive test binary relation", true,
              [IsBinaryRelation], 0,
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
#P  IsEquivalanceRelation(<rel>)                                RFM
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
##
#F  ReflexiveClosureBinaryRelation(<Rel>)                              RFM
##

##  This will die if the elements set of the underlying relation
##  is not finite. Can install more specific methods for relations over 
##  infinite domains where we can do better.
##
InstallMethod(ReflexiveClosureBinaryRelation,
		"for binary relation", true,
		[IsBinaryRelation], 0,
    function(r)
        local ur,i,d, newrel;

        # make sure <rel> is a relation
        if not IsBinaryRelation(r) then
                Error("<rel> must be a binary relation");
        fi;

        if HasIsReflexiveBinaryRelation(r) and 
                 IsReflexiveBinaryRelation(r) then
            return r;
        fi;

        ur := ShallowCopy(AsSSortedList(UnderlyingRelation(r)));
        for i in Source(r) do
           AddSet(ur,Tuple([i,i]));
        od;

        d := Source(r);

        newrel :=  GeneralMappingByElements(d,d,ur);
				SetIsReflexiveBinaryRelation(newrel, true);

        # ReflexiveClosure preserves Transitivity.
        if HasIsTransitiveBinaryRelation(r) and 
					IsTransitiveBinaryRelation(r) then
          SetIsTransitiveBinaryRelation(newrel, true);
        fi;
 
        # ReflexiveClosure preserves Symmetry.
        if HasIsSymmetricBinaryRelation(r)  and IsSymmetricBinaryRelation(r) 
					then
          SetIsSymmetricBinaryRelation(newrel, true);
        fi;

	return newrel;

    end );

############################################################################
##
#F  SymmetricClosureBinaryRelation(<Rel>)                              RFM
##

##  This will die if the elements set of the underlying relation
##  is not finite. Can install more specific methods for relations over 
##  infinite domains where we can do better.
##
InstallMethod(SymmetricClosureBinaryRelation,
		"for binary relation", true,
		[IsBinaryRelation], 0,
    function(r)
        local ur,i,t,d, newrel;

        # make sure <rel> is a relation
        if not IsBinaryRelation(r) then
                Error("<rel> must be a binary relation");
        fi;

        if HasIsSymmetricBinaryRelation(r) and 
                 IsSymmetricBinaryRelation(r) then
            return r;
        fi;

        ur := UnderlyingRelation(r);
        t  := ShallowCopy(AsSSortedList(ur));
        for i in ur do
           AddSet(t,Tuple([i[2],i[1]]));
        od;

        d := Source(r);
        newrel := GeneralMappingByElements(d,d,t);
        SetIsSymmetricBinaryRelation(newrel, true);

        # SymmetricClosure preserves Reflexivity.
        if HasIsReflexiveBinaryRelation(r) and IsReflexiveBinaryRelation(r) then
            SetIsReflexiveBinaryRelation(newrel, true);
        fi;

        return newrel;

    end );   

############################################################################
##
#F  TransitiveClosureBinaryRelation(<Rel>)                             RFM
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
                        #   representation of the graph invloved
              el,       # those elements involved in the underlying relation
              i,j,      # index variables
              p,        # 2-tuples that make up the closure 
              d,        # Domain of the given relation
              newrel;   # New transitive relation 

        # make sure <rel> is a relation
        if not IsBinaryRelation(r) then
                Error("<rel> must be a binary relation");
        fi;

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
            Append(p,List(t[i],x->Tuple([el[i],x])));
        od;

        d := Source(r); ##Assumes source is a domain

        newrel :=  GeneralMappingByElements(d,d,p);
        SetIsTransitiveBinaryRelation(newrel, true);

        # TransitiveClosure preserves Reflexivity.
        if HasIsReflexiveBinaryRelation(r) and IsReflexiveBinaryRelation(r) then
            SetIsReflexiveBinaryRelation(newrel, true);
        fi;

        # TransitiveClosure preserves Symmetry.
        if HasIsSymmetricBinaryRelation(r) and IsSymmetricBinaryRelation(r) then
            SetIsSymmetricBinaryRelation(newrel, true);
        fi;

        return newrel;
    end);


############################################################################
##
#F  BinaryRelationByListOfImages( <list> )
#F  BinaryRelationByListOfImagesNC( <list> )
##
InstallGlobalFunction(BinaryRelationByListOfImagesNC,
function( l )

    local n, fam, rel;

    n:= Length(l);
    fam:= GeneralMappingsFamily(FamilyObj(1), FamilyObj(1));
    rel:= Objectify(NewType(fam,
        IsBinaryRelation and IsBinaryRelationDefaultRep and
				IsNonSPGeneralMapping), rec());
    SetSource(rel, Domain([1..n]));
    SetRange(rel, Domain([1..n]));
    SetImagesListOfBinaryRelation(rel, List(l,x->AsSSortedList(x)));
    return rel;
end);

InstallGlobalFunction(BinaryRelationByListOfImages,
function( l )

    local n, flat;

    # Check to see if the given list is dense
    if not IsDenseList(l) then
        Error("List, ",l,",must be dense");              
    fi;
    
    # Check to see if the list defines a relation on 1..n
    n:= Length(l);
    flat:= Flat(l);
    if not ForAll(flat,x->x in [1..n]) then 
        Error("List ,", l,", does not represent a binary relation on 1 .. n");
    fi;

    return BinaryRelationByListOfImagesNC(l);
end);


#############################################################################
##
#M  ImagesElm( <rel>, <n> )
##
##  For binary relations over [1..n] represented as a list of images
##
InstallMethod(ImagesElm, "for binary relations over [1..n] with images list", 
    true, [IsBinaryRelation and HasImagesListOfBinaryRelation, IsPosInt], 0,
function( rel, n )
    return ImagesListOfBinaryRelation(rel)[n];
end);

#############################################################################
##
#M  PreImagesElm( <rel>, <n> )
##
##  For binary relations over [1..n] represented as a list of images
##
InstallMethod(PreImagesElm, "for binary rels over [1..n] with images list", 
    true, [IsBinaryRelation and HasImagesListOfBinaryRelation, IsPosInt], 0,
function( rel, n )
    local i, imslist, preims;

    imslist:= ImagesListOfBinaryRelation(rel);
    preims:= [];
    for i in [1..Length(imslist)] do
        if n in imslist[i] then
            Add(preims, i);
        fi;
    od;
    return preims;
end);

#############################################################################
##
#M  ImagesListOfBinaryRelation( <rel> )
##
##  Returns the list of images of a binary relation.   If the underlying
##  domain of the relation is not [1..n] then an error is signalled.
##
InstallMethod(ImagesListOfBinaryRelation, "for a generic relation", true,
    [IsGeneralMapping], 0,
function(r)
    local dom, eldom, i, ims;

	if not IsEndoGeneralMapping(r) then
		Error(r, " is not a binary relation!");
	fi;

    dom:= UnderlyingDomainOfBinaryRelation(r);
		eldom := AsSSortedList(dom);
    if not IsRange(eldom) or eldom[1] <> 1 then
        Error("Operation only makes sense for relations over [1..n]");
    fi;

    ims:= [];
    # n:= Length(dom);
    for i in eldom do
        Add(ims, ImagesElm(r, i));
    od;
    return ims;
end);

#############################################################################
##
#M  \= ( <rel1>, <rel2> )
##
##  For binary relations over [1..n] represented as a list of images
##
InstallMethod( \=, "for binary relss over [1..n] with images list", true,
    [IsBinaryRelation and HasImagesListOfBinaryRelation,
    IsBinaryRelation and HasImagesListOfBinaryRelation], 0,
function(rel1, rel2)
    return ImagesListOfBinaryRelation(rel1) 
        = ImagesListOfBinaryRelation(rel2);
end);

#############################################################################
##
#M  \in ( <tup>, <rel> )
##
##  For binary relations over [1..n] represented as a list of images
##
InstallMethod( \in, "for binary rels over [1..n] with images list", true,
    [IsList, IsBinaryRelation and HasImagesListOfBinaryRelation], 0,
function( tup, rel )
    if Length(tup) <> 2 then
        Error("List ", tup, " must be of length 2");
    fi;

    return tup[2] in ImagesListOfBinaryRelation(rel)[tup[1]];
end);



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

	# make sure there are no repititions
	if not IsSet(AsSortedList(Concatenation(subsX))) then
		Error("Input does not describe a partition");
	fi;

        #check that subsX is contained in X
	if not  (IsSubset(X, AsSortedList(Concatenation(subsX)))) then
		Error("Input does not describe a partition");
	fi;
	
	fam :=  GeneralMappingsFamily( ElementsFamily(FamilyObj(X)), 
		ElementsFamily(FamilyObj(X)) );


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
##
InstallGlobalFunction(EquivalenceRelationByPartitionNC,
function(X, subsX)
	local fam, rel;

	fam :=  GeneralMappingsFamily( ElementsFamily(FamilyObj(X)), 
		ElementsFamily(FamilyObj(X)) );


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
#F  EquivalenceRelationByRelation( <rel> )                       RFM
##
##  This just calls EquivalenceRelationByPairs 
##
InstallGlobalFunction(EquivalenceRelationByRelation,
r-> EquivalenceRelationByPairs(
        UnderlyingDomainOfBinaryRelation(r),
        Enumerator(UnderlyingRelation(r))) );


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
        rel :=  Objectify(NewType(fam, 
		IsEquivalenceRelation and IsEquivalenceRelationDefaultRep), rec());
	SetSource(rel, X);
	SetRange(rel, X);
	Setter(property)(rel, true);

	return rel;
end);

#############################################################################
##
#F  EquivalenceRelationPartition(<equiv>)
##
##
InstallMethod( EquivalenceRelationPartition, 
    "compute the partition for an arbitrary equiv rel", true,
    [IsEquivalenceRelation], 0,
    
    function( equiv )
        local part;

        if HasEquivalenceRelationPartition(equiv) then
            return equiv!.part;
        fi; 
    
        part := EquivalenceRelationPartition(
                    EquivalenceRelationByPairs(Source(equiv), 
                    AsList(UnderlyingRelation(equiv))));
        Setter(EquivalenceRelationPartition)(equiv, part);
        return part;
    end);


#############################################################################
##
#F  SetEquivalenceRelationPartition(<equiv>, <part>)
##
##  This establishes a canonical form for EquivalenceRelationPartitions
##  so that if two equivalence relations are equal, they have the same 
##  partition. Also results in \< being consistent for equivalence relations.
##

InstallGlobalFunction(SetEquivalenceRelationPartition,
function(equiv, part)
	if not (IsEquivalenceRelation(equiv) and IsList(part)) then
		Error("usage: SetEquivalenceRelationPartition(<rel>, <list>)");
	fi;

	# first, make each part of the partition a  set
	part := List(part,AsSSortedList);

	# now make all of part a set (strictly order the parts, no duplicates)
	part := AsSSortedList(part);

	# now strip out the singletons and empties
	part := AsSSortedList(Filtered(part, x->Length(x) > 1));

	# finally, set the value
	Setter(EquivalenceRelationPartition)(equiv, part);
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
#M  GeneratorsOfEquivalenceRelationPartition( <equiv> )
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
 
    SetGeneratorsOfEquivalenceRelationPartition(equiv,gens);
    return gens;
end);

#############################################################################
##
#M      \=	. .      . . . for equivalence relations 
##
InstallMethod(\=, "for eq relations", IsIdenticalObj,
        [IsEquivalenceRelation, IsEquivalenceRelation], 0,
function(x, y)
	if Source(x) <> Source(y)  then
		return false;
	fi;
	if (HasEquivalenceRelationPartition(x) and 
		HasEquivalenceRelationPartition(y)) then
			return EquivalenceRelationPartition(x) = EquivalenceRelationPartition(y);
	else
		TryNextMethod();
	fi;
end);

#############################################################################
##
#R	IsEquivalenceClassDefaultRep( <M> )
#M	EquivalenceClassRelation( <C> )
##
##	The default representation for equivalence classes will be to store its
##	underlying relation, and a single canonical element of the class.
##	Representation specific methods are installed here.
##
DeclareRepresentation("IsEquivalenceClassDefaultRep", IsAttributeStoringRep
	and IsComponentObjectRep, rec());


#############################################################################
##
#M	EquivalenceClassOfElement( <R>, <rep> )
#M	EquivalenceClassOfElementNC( <R>, <rep> )
##
##	Returns the equivalence class of an element <rep> with respect to an
##	equivalence relation <R>.   No calculation is performed at this stage.
##	We do not always wish to check that <rep> is in the underlying set
##	of <R>, since we may wish to use equivalence relations to perform
##	membership tests (for example when checking membership of a
##	transformation in a monoid, we use Greens relations and classes).
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
#M	PrintObj( <C> )
##
##	Display an equivalence class.
##
InstallMethod(PrintObj, "for an eq. class", true,
	[IsEquivalenceClass],0,
function(c)
	Print("{", Representative(c),"}");
end);

#############################################################################
##
#M	\in( <T>, <R> )
##
##	Checks whether a 2-tuple is contained in a relation.   Implementation
##	for an equivalence relation stored as a partition.
##
##  This method should be selected over all others since it assumes
##  that the partition information has already been computed.
##  It has been given a +1 rank which WILL NEED TUNING when  the 
##  other methods are in.
##
InstallMethod(\in, "for eq relation with partition", true,
	[IsList, IsEquivalenceRelation and HasEquivalenceRelationPartition], 1,
function(tup, rel)

	local part, i;

	if Length(tup) <> 2 then 
		Error("Left hand side must be of length 2");
	elif FamilyObj(tup) <> 
			FamilyObj(UnderlyingDomainOfBinaryRelation(rel)) then
		Error("Left hand side must contain elements of relation's domain");
	fi;

	part:= EquivalenceRelationPartition(rel);
	for i in [1..Length(part)] do
		if tup[1] in part[i] then
			if tup[2] in part[i] then
				return true;
			else
				return false;
			fi;
		fi;
	od;
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

    local
    iter;       # iterator of the equivalence class


    # first ensure that <x> is in the right family
    if FamilyObj(x) <>
        ElementsFamily(FamilyObj(Source(EquivalenceClassRelation(C)))) then
        Error("incompatible arguments for \in");
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
#M  \= ( <C1>, <C2> )
##
##  Equality of equivalence classes
##
InstallMethod(\=, "for two equivalence classes",
IsIdenticalObj,
[IsEquivalenceClass,
IsEquivalenceClass], 0,
function(x, y)
  return Representative(x) in y;
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

	local
            rel,     # relation for which C is a class
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
#M  \<( <x1>, <x2> )
##
##  The total order on equivalence classes used for creating sets, etc.
##  Relies on the total order of the underlying set. This is a 
##  VERY INEFFICIENT method because it relies on finding the smallest
##  element of an equivalence class. AVOID USING THIS IF POSSIBLE!!
##
##
InstallMethod( \<,
    "for two equivalence classes",
    IsIdenticalObj,
    [ IsEquivalenceClass, IsEquivalenceClass ],
    0,
    function( x1, x2 )
			return RepresentativeSmallest(x1) < RepresentativeSmallest(x2);
    end );

#############################################################################
##
#M  EquivalenceClasses( <E> ) 
##
##	Wraparound function which calls the two-argument method
##
InstallMethod(EquivalenceClasses, 
	"wraparound to call 2-argument version", true, [IsEquivalenceRelation], 0,
		e->EquivalenceClasses(e, UnderlyingDomainOfBinaryRelation(e)));

#############################################################################
##
#M  EquivalenceClasses( <E>, <C> )
##
##	Returns the list of equivalence classes of an equivalence relation.
##	This generic method will not terminate for an equivalence over an
##	infinite set.
##
InstallOtherMethod(EquivalenceClasses, "for a generic equivalence relation", 
	true, [IsEquivalenceRelation, IsCollection], 0,
function(E, D)

	local classes, iter, elm;

	# We iterate over the underlying domain, and build up the list
	# of classes as new ones are found.
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
##
#M  ImagesRepresentative( <rel>, <elm> )  . . . for equivalence relations
##
InstallMethod( ImagesRepresentative,
    "equivalence relations",
    FamSourceEqFamElm,
    [ IsEquivalenceRelation, IsObject ], 0,
function( map, elm )
	return elm;
end);



#############################################################################
##
#M  PreImagesRepresentative( <rel>, <elm> )  . . . for equivalence relations
##
InstallMethod( PreImagesRepresentative,
    "equivalence relations",
    FamRangeEqFamElm,
    [ IsEquivalenceRelation, IsObject ], 0,
function( map, elm )
	return elm;
end);

#############################################################################
##
#M  ImagesElm( <rel>, <elm> )  . . . for equivalence relations with partition
##
InstallMethod( ImagesElm,
    "for equivalence relation with partition and element",
    FamSourceEqFamElm,
    [ IsEquivalenceRelation and HasEquivalenceRelationPartition, IsObject ], 0,
function( rel, elm )
	return Enumerator(EquivalenceClassOfElement(rel,elm));
end);


#############################################################################
##
#M  PreImagesElm( <rel>, <elm> )  . . . for equivalence relations
##
InstallMethod( PreImagesElm,
    "equivalence relations",
    FamRangeEqFamElm,
    [ IsEquivalenceRelation, IsObject ], 0,
function( rel, elm )
	return Enumerator(EquivalenceClassOfElement(rel,elm));
end);


#############################################################################
##
#M  PrintObj( <eqr> ) . . . . . . . . . . . . . . . for equivalence relation
##
InstallMethod( PrintObj,
    "for an equivalence relation",
    true,
    [ IsEquivalenceRelation ], 0,
    function( map )
    Print( "<equivalence relation on ", Source( map ), " >" );
    end );


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
            C := List(pairs,x->ShallowCopy(x));
        else
            C := DuplicateFreeList(List(pairs,x->ShallowCopy(x))); 
        fi;

        ##
        ## Use Tarjan's merge method to find the equivalence relation 
        ##     generated by the pairs (expressed as a set of non-trivial 
        ##     blocks determined by the input pairs).
         
        ## The first pair will be our starting forest.
        ##   
        forest := [C[1]];

        ##
        ## Put each pair in it's appropriate block and merge blocks
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
                if not p2=Length(forest) then
                    forest[p2]:=forest[Length(forest)];
                    Unbind(forest[Length(forest)]);
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

        return EquivalenceRelationByPartition(d,forest);

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
            return EquivalenceRelationByPartition(d,[]);      
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
        ## Make a mutable copy of pairs so we don't inadvertantly alter
        ##   pairs 
        ##
        C := List(Filtered(pairs,x->not x[1]=x[2]), y->ShallowCopy(y));

        ##
        ## Return diagonal relation if all pairs are of the form (a,a)
        ##
        if IsEmpty(C) then 
            return EquivalenceRelationByPartition(d,[]); 
        fi;

        C := Set(C);

        return EquivalenceRelationByPairsNC(d,C);

    end);

#############################################################################
##
#E
