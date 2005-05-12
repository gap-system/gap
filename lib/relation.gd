#############################################################################
##
#W  relation.gd                  GAP library                   Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for binary relations on sets.
##
##  Maintenance and further development by:
##  Robert Arthur
##  Robert F. Morse
##  Andrew Solomon
##
Revision.relation_gd :=
    "@(#)$Id$";


#############################################################################
#1 
##  \index{binary relation}
##  \atindex{IsBinaryRelation!same as IsEndoGeneralMapping}%
##  {@\noexpand`IsBinaryRelation'!same as \noexpand`IsEndoGeneralMapping'}
##  \atindex{IsEndoGeneralMapping!same as IsBinaryRelation}%
##  {@\noexpand`IsEndoGeneralMapping'!same as \noexpand`IsBinaryRelation'}
##  A *binary relation* <R> on a set <X> is a subset of $X \times X$. 
##  A binary relation can also be thought of as a (general) mapping
##  from <X> to itself or as a directed graph where each edge 
##  represents a tuple of <R>. 
##
##  In {\GAP}, a relation is conceptually represented as  a  general  mapping
##  from <X> to itself. The category `IsBinaryRelation' is the  same  as  the
##  category `IsEndoGeneralMapping' (see~"IsEndoGeneralMapping").  Attributes
##  and properties of relations in {\GAP} are supported  for  relations,  via
##  considering relations as a subset of $X\times X$, or as a directed graph;
##  examples include finding the strongly connected components of a relation,
##  via `StronglyConnectedComponents' (see~"StronglyConnectedComponents"), or
##  enumerating the tuples of the relation.
##

##  The hierarchy of concepts around binary relations on a set are:
##
##  IsGeneralMapping > 
## 
##  IsEndoGeneralMapping [ = IsBinaryRelation] >
##
##  [IsEquivalenceRelation] 
##
##
#############################################################################

#############################################################################
##
## General Binary Relations
##
#############################################################################

#############################################################################
##
#C  IsBinaryRelation( <R> )
##
##  is   exactly   the   same   category   as   (i.e.    a    synonym    for)
##  `IsEndoGeneralMapping' (see~"IsEndoGeneralMapping").
##
DeclareSynonym("IsBinaryRelation",IsEndoGeneralMapping);

#############################################################################
##
#F  BinaryRelationOnPoints( <list> )
#F  BinaryRelationOnPointsNC( <list> )
##
##  Given a list of <n> lists, each containing elements from 
##  the set $\{1,\dots,n\}$,
##  this function constructs a binary relation such that $1$ is related
##  to <list>`[1]', $2$ to <list>`[2]' and so on.
##  The first version checks whether the list supplied is valid. The
##  the `NC' version skips this check.
##
DeclareGlobalFunction("BinaryRelationOnPoints");
DeclareGlobalFunction("BinaryRelationOnPointsNC");

#############################################################################
##
#F  RandomBinaryRelationOnPoints( <degree> )
##
##  creates a relation on points with degree <degree>.
##  
DeclareGlobalFunction("RandomBinaryRelationOnPoints");

#############################################################################
##
#F  IdentityBinaryRelation( <degree> )
#F  IdentityBinaryRelation( <domain> )
##
##  is the binary relation which consists of diagonal tuples i.e.  tuples  of
##  the form $(x,x)$. In the first form if a  positive  integer  <degree>  is
##  given then the domain is  the  integers  $\{1,\dots,<degree>\}$.  In  the
##  second form, the tuples are from the domain <domain>.
##
DeclareGlobalFunction("IdentityBinaryRelation");

#############################################################################
##
#F  BinaryRelationByElements(<domain>,<elms>)
##
##  is  the  binary  relation  on  <domain>  and  with  underlying   relation
##  consisting of the tuples collection <elms>. This construction is  similar
##  to `GeneralMappingByElements' (see~"GeneralMappingByElements") where  the
##  source and range are the same set.
##
DeclareGlobalFunction("BinaryRelationByElements");

#############################################################################
##
#F  EmptyBinaryRelation( <degree> )
#F  EmptyBinaryRelation( <domain> )
##
##  is the relation with <R> empty. In the first form  of  the  command  with
##  <degree> an integer, the domain is the points $\{1,\dots, <degree>\}$. In
##  the second form, the domain is that given by the argument <domain>.
##
DeclareGlobalFunction("EmptyBinaryRelation");

#############################################################################
##
#F  AsBinaryRelationOnPoints( <trans> )
#F  AsBinaryRelationOnPoints( <perm> )
#F  AsBinaryRelationOnPoints( <rel> )
##
##  return the relation on points  represented  by  general  relation  <rel>,
##  transformation <trans> or permutation  <perm>.  If  <rel>  is  already  a
##  binary relation on points then <rel> is returned.
##
##  Transformations and permutations are special general endomorphic 
##  mappings and have a natural representation as a binary relation on
##  points. 
##  
##  In the last form, an isomorphic relation on points is constructed
##  where the points are indices of the elements of the underlying domain
##  in sorted order.
##
DeclareGlobalFunction("AsBinaryRelationOnPoints");

###############################################################################
##
#A  Successors( <R> )
##
##  returns the list of images of a binary relation <R>.  If  the  underlying
##  domain of the relation is not `[1..<n>]' for some positive  integer  <n>,
##  then an error is signalled.
##
##  The returned value of `Successors' is a list of lists where the lists are
##  ordered as the elements according to the sorted order of  the  underlying
##  set of <R>. Each list consists of the images of the element  whose  index
##  is the same as the list with the underlying set in sorted order.
##
##  The `Successors' of a relation is the adjacency list representation
##  of the relation. 
##
DeclareAttribute("Successors", IsBinaryRelation);

###############################################################################
#A  DegreeOfBinaryRelation(<R>)
##
##  returns the size of the underlying domain of  the  binary  relation  <R>.
##  This is most natural when working with a binary relation on points.
##
DeclareAttribute("DegreeOfBinaryRelation", IsBinaryRelation);

############################################################################
##
#A  UnderlyingDomainOfBinaryRelation(<R>)
##
##  is a synonym for the `Source' (see~"Source") of the relation <R> when
##  considered as a general mapping.
##
DeclareSynonym("UnderlyingDomainOfBinaryRelation",Source);

#############################################################################
##
##  Properties of binary relations.  
##
#############################################################################

#############################################################################
##
#P  IsReflexiveBinaryRelation(<R>)
##  
##  returns `true' if the binary relation <R> is reflexive, and `false'
##  otherwise.
##
##  \index{reflexive relation}
##  A binary relation <R> (as tuples) on a set <X> is *reflexive* if
##  for all $x\in X$, $(x,x)\in R$. Alternatively, <R> as a mapping
##  is reflexive if for all $x\in X$, $x$ is an element of the image set
##  $R(x)$.   
##
##  A reflexive binary relation is necessarily a total endomorphic 
##  mapping (tested via `IsTotal'; see~"IsTotal").
##
DeclareProperty("IsReflexiveBinaryRelation", IsBinaryRelation);

#############################################################################
##
#P  IsSymmetricBinaryRelation(<R>)
##
##  returns `true' if the binary relation <R> is symmetric, and `false'
##  otherwise.
##
##  \index{symmetric relation}
##  A binary relation <R> (as tuples) on a set <X> is *symmetric* if
##  $(x,y)\in R$ then $(y,x)\in R$. Alternatively, <R> as a mapping
##  is symmetric if for all $x\in X$, the preimage set of $x$ under $R$ equals
##  the image set $R(x)$.
##
DeclareProperty("IsSymmetricBinaryRelation", IsBinaryRelation);

#############################################################################
##
#P  IsTransitiveBinaryRelation(<R>)
##
##  returns `true' if the binary relation <R> is transitive, and `false'
##  otherwise.
##
##  \index{transitive relation}
##  A binary relation <R> (as tuples) on a set <X> is *transitive* if
##  $(x,y), (y,z)\in R$ then $(x,z)\in R$. Alternatively, <R> as a mapping
##  is transitive if for all $x\in X$, the image set $R(R(x))$ of the image 
##  set $R(x)$ of $x$ is a subset of $R(x)$.
##   
DeclareProperty("IsTransitiveBinaryRelation", IsBinaryRelation);

#############################################################################
##
#P  IsAntisymmetricBinaryRelation(<rel>)
##
##  returns `true' if the binary relation <rel> is antisymmetric, and `false'
##  otherwise.
##
##  \index{antisymmetric relation}
##  A binary relation <R> (as tuples) on a set <X> is *antisymmetric* if
##  $(x,y), (y,x)\in R$ implies $x = y$. Alternatively, <R> as a mapping
##  is antisymmetric if for all $x\in X$, the intersection of the
##  preimage set of $x$ under $R$ and
##  the image set $R(x)$ is $\{x\}$.
##
DeclareProperty("IsAntisymmetricBinaryRelation",IsBinaryRelation);

#############################################################################
##
#P  IsPreOrderBinaryRelation(<rel>)
##
##  returns `true' if the binary relation <rel> is a preorder, and `false'
##  otherwise.
##
##  \index{preorder}
##  A *preorder* is a binary relation that is both reflexive and transitive.
##
DeclareProperty("IsPreOrderBinaryRelation",IsBinaryRelation);

#############################################################################
##
#P  IsPartialOrderBinaryRelation(<rel>)
##
##  returns `true' if the binary relation  <rel>  is  a  partial  order,  and
##  `false' otherwise.
##
##  \index{partial order}
##  A *partial order* is a preorder which is also antisymmetric.
##
DeclareProperty("IsPartialOrderBinaryRelation",IsBinaryRelation);
##
InstallTrueMethod(IsPreOrderBinaryRelation, IsReflexiveBinaryRelation and 
    IsTransitiveBinaryRelation);
InstallTrueMethod(IsPartialOrderBinaryRelation, IsPreOrderBinaryRelation and
    IsAntisymmetricBinaryRelation);
InstallTrueMethod(IsTotal, IsReflexiveBinaryRelation);

#############################################################################
##
#P  IsLatticeOrderBinaryRelation(<rel>)
##
##  return 'true' if the binary relation is a lattice order, and false
##  otherwise.
##
##  \index{lattice order}
##  A *lattice order* is a partial order in which each pair of elements
##  has a greatest lower bound and a least upper bound.
##
DeclareProperty("IsLatticeOrderBinaryRelation",IsBinaryRelation);
##
InstallTrueMethod(IsPartialOrderBinaryRelation, IsLatticeOrderBinaryRelation);

############################################################################
##
## Equivalence Relations
##
#############################################################################

#############################################################################
##
#P  IsEquivalenceRelation( <R> )
##
##  returns `true' if the binary relation <R> is an equivalence relation, and
##  `false' otherwise.
##
##  \index{equivalence relation}
##  Recall, that a relation <R> on the set <X> is an  *equivalence  relation*
##  if it is symmetric, transitive, and reflexive.
##
DeclareProperty("IsEquivalenceRelation", IsBinaryRelation); 

InstallTrueMethod(IsBinaryRelation, IsEquivalenceRelation);
InstallTrueMethod(IsReflexiveBinaryRelation, IsEquivalenceRelation);
InstallTrueMethod(IsTransitiveBinaryRelation, IsEquivalenceRelation);
InstallTrueMethod(IsSymmetricBinaryRelation, IsEquivalenceRelation);
InstallTrueMethod(IsEquivalenceRelation, 
    IsReflexiveBinaryRelation and 
    IsTransitiveBinaryRelation and IsSymmetricBinaryRelation);

#############################################################################
##
##  Closure operations for binary relations.
##
#############################################################################

#############################################################################
##
#O  ReflexiveClosureBinaryRelation( <R> )                      
##
##  is the smallest binary relation containing the binary relation <R>  which
##  is  reflexive.  This  closure  inherents  the  properties  symmetric  and
##  transitive from <R>. E.g. if <R> is symmetric then its reflexive  closure
##  is also.
##
DeclareOperation("ReflexiveClosureBinaryRelation", [IsBinaryRelation]);

#############################################################################
##
#O  SymmetricClosureBinaryRelation( <R> )
##
##  is the smallest binary relation containing the binary relation <R>  which
##  is  symmetric.  This  closure  inherents  the  properties  reflexive  and
##  transitive from <R>. E.g. if <R> is reflexive then its symmetric  closure
##  is also.
##
DeclareOperation("SymmetricClosureBinaryRelation", [IsBinaryRelation]);

#############################################################################
##
#O  TransitiveClosureBinaryRelation( <rel> )
##
##  is the smallest binary relation containing the binary relation <R>  which
##  is  transitive.  This  closure  inerents  the  properties  reflexive  and
##  symmetric from <R>. E.g. if <R> is symmetric then its transitive  closure
##  is also.
##
##  `TransitiveClosureBinaryRelation' is a modified version of the 
##  Floyd-Warshall method of solving the all-pairs shortest-paths problem 
##  on a directed graph. Its asymptotic runtime is $O(n^3)$ where n is 
##  the size of the vertex set. It only assumes there is an arbitrary 
##  (but fixed) ordering of the vertex set. 
##
DeclareOperation("TransitiveClosureBinaryRelation", [IsBinaryRelation]);

#############################################################################
##
#O  HasseDiagramBinaryRelation(<partial-order>)
##
##  is the smallest relation contained in the partial  order  <partial-order>
##  whose reflexive and transitive closure is equal to <partial-order>.
##
DeclareOperation("HasseDiagramBinaryRelation", [IsBinaryRelation]);

#############################################################################
##
#P  IsHasseDiagram(<rel>)
##
##  returns `true' if the binary relation <rel>  is  a  Hasse  Diagram  of  a
##  partial  order,  i.e.  was  computed   via   `HasseDiagramBinaryRelation'
##  (see~"HasseDiagramBinaryRelation").
##
DeclareProperty("IsHasseDiagram", IsBinaryRelation);

#############################################################################
##
#A  PartialOrderOfHasseDiagram(<HD>)
##
##  is the partial order associated with the Hasse Diagram <HD> 
##  i.e. the partial order generated by the reflexive and 
##  transitive closure of <HD>. 
##
DeclareAttribute("PartialOrderOfHasseDiagram",IsBinaryRelation);

#############################################################################
##
#F  PartialOrderByOrderingFunction(<dom>, <orderfunc>)
##
##  constructs a partial order whose elements are from the domain <dom>
##  and are ordered using the ordering function <orderfunc>. The ordering
##  function must be a binary function returning a boolean value. If the 
##  ordering function does not describe a partial order then `fail' is
##  returned.
##
DeclareGlobalFunction("PartialOrderByOrderingFunction");

#############################################################################
##
#O  StronglyConnectedComponents(<R>)
##
##  returns an equivalence relation on the vertices of  the  binary  relation
##  <R>.
##
DeclareOperation("StronglyConnectedComponents", [IsBinaryRelation]);

#############################################################################
##
##  Special definitions for exponentiation with sets, lists, and Zero
##
DeclareOperation("POW", [IsListOrCollection, IsBinaryRelation]);
DeclareOperation("\+", [IsBinaryRelation, IsBinaryRelation]);
DeclareOperation("\-", [IsBinaryRelation, IsBinaryRelation]);

#############################################################################
##
#A  EquivalenceRelationPartition(<equiv>)
##
##  returns a list of lists of elements 
##  of the underlying set of the equivalence relation <equiv>.
##  The lists are precisely the nonsingleton equivalence classes of the
##  equivalence.
##  This allows us to describe ``small'' equivalences on infinite sets.
##
DeclareAttribute("EquivalenceRelationPartition", IsEquivalenceRelation);

#############################################################################
##
#A  GeneratorsOfEquivalenceRelationPartition(<equiv>)
##  
##  is a set of generating pairs for the equivalence relation  <equiv>.  This
##  set is not unique. The equivalence <equiv> is  the  smallest  equivalence
##  relation over the underlying set <X> which contains the generating pairs.
##
DeclareAttribute("GeneratorsOfEquivalenceRelationPartition",
    IsEquivalenceRelation);

#############################################################################
##
#F  EquivalenceRelationByPartition( <domain>, <list> )
#F  EquivalenceRelationByPartitionNC( <domain>, <list> )
##
##  constructs the equivalence relation over the set <domain>
##  which induces the partition represented by <list>. 
##  This representation includes only the non-trivial blocks 
##  (or equivalent classes). <list> is a list of lists,
##  each of these lists contain elements of <domain> and are 
##  pairwise mutually exclusive.
##
##  The list of lists do not need to be in any order nor do the 
##  elements in the blocks (see `EquivalenceRelationPartition').
##  a list of elements of <domain>
##  The partition <list> is a 
##  list of lists, each of these is a list of elements of <domain>
##  that makes up a block (or equivalent class). The 
##  <domain> is the domain over which the relation is defined, and 
##  <list> is a list of lists, each of these is a list of elements
##  of <domain> which are related to each other.
##  <list> need only contain the nontrivial blocks 
##  and singletons will be ignored. The NC version will not check
##  to see if the lists are pairwise mutually exclusive or that
##  they contain only elements of the domain.
## 
DeclareGlobalFunction("EquivalenceRelationByPartition");
DeclareGlobalFunction("EquivalenceRelationByPartitionNC");

#############################################################################
##
#F  EquivalenceRelationByProperty( <domain>, <property> )
##
##  creates an equivalence relation on <domain> whose only defining
##  datum is that of having the property <property>.
## 
DeclareGlobalFunction("EquivalenceRelationByProperty");

#############################################################################
##
#F  EquivalenceRelationByRelation( <rel> )
##
##  returns the smallest equivalence 
##  relation containing the binary relation <rel>.
##
DeclareGlobalFunction("EquivalenceRelationByRelation");

#############################################################################
##
##  Some other creation functions which might be useful in the future
##
##  EquivalenceRelationByFunction( <X>, <function> )
##
##  EquivalenceRelationByFunction - the function goes from 
##  $X  \times X \rightarrow $ {<true>, <false>}.

#############################################################################
##
#O  JoinEquivalenceRelations( <equiv1>,<equiv2> )
#O  MeetEquivalenceRelations( <equiv1>,<equiv2> )
##
##  `JoinEquivalenceRelations(<equiv1>,<equiv2>)' returns the smallest
##  equivalence relation containing both the equivalence relations
##  <equiv1> and <equiv2>.
##
##  `MeetEquivalenceRelations( <equiv1>,<equiv2> )' returns the 
##  intersection of the two equivalence relations <equiv1> and <equiv2>.
##
DeclareOperation("JoinEquivalenceRelations", 
    [IsEquivalenceRelation,IsEquivalenceRelation]);
DeclareOperation("MeetEquivalenceRelations", 
    [IsEquivalenceRelation,IsEquivalenceRelation]);

#############################################################################
##
#C  IsEquivalenceClass( <O> ) 
##
##  returns `true' if the object <O> is an equivalence class, and `false'
##  otherwise.
##
##  \index{equivalence class}
##  An *equivalence class* is a collection of elements which are mutually
##  related to each other in the associated equivalence relation. Note,
##  this is a special category of object and not just a list of elements.
##
DeclareCategory("IsEquivalenceClass",IsDomain and IsDuplicateFreeCollection); 

#############################################################################
##
#A  EquivalenceClassRelation(<C>) 
##
##  returns the equivalence relation of which <C> is a class.
##
DeclareAttribute("EquivalenceClassRelation", IsEquivalenceClass);

#############################################################################
##
#A  EquivalenceClasses(<rel>) 
##
##  returns a list of all equivalence classes of the equivalence relation <rel>.
##  Note that it is possible for different methods to yield the list
##  in different orders, so that for two equivalence relations
##  $c1$ and $c2$ we may have $c1 = c2$ without having
##  $`EquivalenceClasses'( c1 ) = `EquivalenceClasses'( c2 )$.
##
DeclareAttribute("EquivalenceClasses", IsEquivalenceRelation);

#############################################################################
##
#O  EquivalenceClassOfElement(<rel>,<elt>)
#O  EquivalenceClassOfElementNC(<rel>,<elt>)
##
##  return the equivalence class of <elt> in the binary relation <rel>,
##  where <elt> is an element (i.e. a pair) of the domain of <rel>. 
##  In the second form, it is not checked that <elt> is in the domain 
##  over which <rel> is defined.
##
DeclareOperation("EquivalenceClassOfElement", 
    [IsEquivalenceRelation, IsObject]);

DeclareOperation("EquivalenceClassOfElementNC", 
    [IsEquivalenceRelation, IsObject]);

#############################################################################
##
#F  EquivalenceRelationByPairs( <D>, <elms> )
#F  EquivalenceRelationByPairsNC( <D>, <elms> )
##
##  return the smallest equivalence relation
##  on the domain <D> such that every pair in <elms>
##  is in the relation.
##
##  In the second form, it is not checked that <elms> are in the domain <D>.
##
DeclareGlobalFunction("EquivalenceRelationByPairs");
DeclareGlobalFunction("EquivalenceRelationByPairsNC");

#############################################################################
#E
##
