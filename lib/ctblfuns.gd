#############################################################################
##
#W  ctblfuns.gd                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the definition of categories of class functions,
##  and the corresponding properties, attributes, and operations.
##
Revision.ctblfuns_gd :=
    "@(#)$Id$";

#T TODO:

#T AsClassFunction( <tbl>, <psi> )
#T (regard as class function of factor group or of a downward extension)


#############################################################################
##
#C  IsClassFunction( <obj> )
##
##  A *class function* in characteristic $p$ of a finite group $G$ is a map
##  from the set of $p$-regular elements in $G$ to the cyclotomics that is
##  constant on conjugacy classes of $G$.
##
##  There are (at least) two reasons why class functions in {\GAP} are *not*
##  implemented as (general) mappings.
##  First, we want to distinguish class functions in different
##  characteristics, for example to be able to define the Frobenius character
##  of a given Brauer character; 
##  viewed as mappings, the trivial characters in all characteristics coprime
##  to the order of $G$ are equal.
##  Second, the product of two class functions shall be again a class
##  function, whereas the product of general mappings is defined as
##  composition.
##
##  Each class function is a ring element.
##  (Note that we want to form, e.g., groups of linear characters.)
##  The product of two class functions of the same group in the same
##  characteristic is again a class function;
##  in this respect, class functions behave differently from their
##  values lists.
##
##  Each class function is an immutable list.
##  Note that the product of class functions is different from the product
##  of lists, so class functions do not behave exactly as their values lists.
##
##  Each class function knows its underlying character table.
##
##  Two class functions are equal if they have the same underlying
##  character table and the same class function values.
##
IsClassFunction := NewCategory( "IsClassFunction",
    IsRingElementWithOne and IsCommutativeElement and IsAssociativeElement
        and IsHomogeneousList );


#############################################################################
##
#C  IsClassFunctionWithGroup( <obj> )
##
##  A class function that knows about an underlying group can be asked for
##  its kernel or centre or inertia subgroups or ...
##
##  Note that the class function knows the underlying group only via its
##  character table.
##  
IsClassFunctionWithGroup := NewCategory( "IsClassFunctionWithGroup",
    IsClassFunction );


#############################################################################
##
#C  IsClassFunctionCollection( <obj> )
##
IsClassFunctionCollection := CategoryCollections( IsClassFunction );


#############################################################################
##
#C  IsClassFunctionWithGroupCollection( <obj> )
##
IsClassFunctionWithGroupCollection := CategoryCollections(
    IsClassFunctionWithGroup );


#############################################################################
##
#C  IsClassFunctionFamily( <obj> )
##
IsClassFunctionsFamily := CategoryFamily( IsClassFunction );


#############################################################################
##
#R  IsClassFunctionsSpaceRep( <V> )
##
##  Free left modules of class functions are handled by associating to a
##  class function the row vector given by its values.
##
##  If the nice free left module has been computed then
##  free left modules of class functions contain the components
##
##  'elementsunderlying' : \\
##       the underlying character table of the elements,
##
IsClassFunctionsSpaceRep := NewRepresentation( "IsClassFunctionsSpaceRep",
    IsAttributeStoringRep and IsHandledByNiceBasis,
    [ "elementsunderlying" ] );


#############################################################################
##
#M  IsClassFunctionsSpaceRep
##
InstallTrueMethod( IsClassFunctionsSpaceRep,
    IsFreeLeftModule and IsClassFunctionCollection );


#############################################################################
##
#A  ClassFunctionsFamily( <tbl> )
##
##  is the family of all class functions of the character table <tbl>.
##
ClassFunctionsFamily := NewAttribute( "ClassFunctionsFamily",
    IsNearlyCharacterTable );
SetClassFunctionsFamily := Setter( ClassFunctionsFamily );
HasClassFunctionsFamily := Tester( ClassFunctionsFamily );


#############################################################################
##
#A  UnderlyingCharacterTable( <psi> )
##
##  The family of class functions stores the value in the component
##  'underlyingCharacterTable'.
##  (This belongs to the defining data of the class function <psi>.)
##
UnderlyingCharacterTable := NewAttribute( "UnderlyingCharacterTable",
    IsClassFunction );
SetUnderlyingCharacterTable := Setter( UnderlyingCharacterTable );
HasUnderlyingCharacterTable := Tester( UnderlyingCharacterTable );


#############################################################################
##
#A  ValuesOfClassFunction( <psi> ) . . . . . . . . . . . . . . list of values
##
##  is the list of values of the class function <psi>, the $i$-th entry
##  being the value on the $i$-th conjugacy class of the underlying group
##  resp. character table.
##
##  This belongs to the defining data of the class function <psi>.
##
ValuesOfClassFunction := NewAttribute( "ValuesOfClassFunction",
    IsClassFunction );
SetValuesOfClassFunction := Setter( ValuesOfClassFunction );
HasValuesOfClassFunction := Tester( ValuesOfClassFunction );


#############################################################################
##
#P  IsVirtualCharacter( <chi> )
##
##  A virtual character is a class function that can be written as the
##  difference of proper characters.
##
IsVirtualCharacter := NewProperty( "IsVirtualCharacter", IsClassFunction );
SetIsVirtualCharacter := Setter( IsVirtualCharacter );
HasIsVirtualCharacter := Tester( IsVirtualCharacter );


#############################################################################
##
#P  IsCharacter( <chi> )
##
IsCharacter := NewProperty( "IsCharacter", IsClassFunction );
SetIsCharacter := Setter( IsCharacter );
HasIsCharacter := Tester( IsCharacter );


#############################################################################
##
#M  IsVirtualCharacter( <chi> ) . . . . . . . . . . . . . . . for a character
##
InstallTrueMethod( IsVirtualCharacter, IsCharacter );


#############################################################################
##
#A  CentreOfCharacter( <psi> )
##
##  is the centre of the character <psi>,
##  as a subgroup of the underlying group of <psi>.
##
CentreOfCharacter := NewAttribute( "CentreOfCharacter",
    IsClassFunctionWithGroup and IsCharacter );
SetCentreOfCharacter := Setter( CentreOfCharacter );
HasCentreOfCharacter := Tester( CentreOfCharacter );


#############################################################################
##
#O  CentreChar( <psi> )
##
##  is the list of positions of classes forming the centre of the character
##  <chi> of the ordinary character table <tbl>.
##
CentreChar := NewOperation( "CentreChar",
    [ IsClassFunction and IsCharacter ] );


#############################################################################
##
#A  ConstituentsOfCharacter( <psi> )
##
##  is the set of irreducible characters that occur in the decomposition of
##  the (virtual) character <psi> with nonzero coefficient.
##
ConstituentsOfCharacter := NewAttribute( "ConstituentsOfCharacter",
    IsClassFunction );
SetConstituentsOfCharacter := Setter( ConstituentsOfCharacter );
HasConstituentsOfCharacter := Tester( ConstituentsOfCharacter );


#############################################################################
##
#A  DegreeOfCharacter( <psi> )
##
##  is the value of the character <psi> on the identity element.
##
DegreeOfCharacter := NewAttribute( "DegreeOfCharacter",
    IsClassFunction and IsCharacter );
SetDegreeOfCharacter := Setter( DegreeOfCharacter );
HasDegreeOfCharacter := Tester( DegreeOfCharacter );


#############################################################################
##
#A  InertiaSubgroupInParent( <psi> )
##
##  Let $H$ be the underlying group of the character <chi>, and $G$ the
##  parent of $H$.
##  Then 'InertiaSubgroupInParent( <chi> )' is the inertia subgroup of <chi>
##  in the normalizer of $H$ in $G$.
##
InertiaSubgroupInParent := NewAttribute( "InertiaSubgroupInParent",
    IsClassFunctionWithGroup and IsCharacter );
SetInertiaSubgroupInParent := Setter( InertiaSubgroupInParent );
HasInertiaSubgroupInParent := Tester( InertiaSubgroupInParent );


#############################################################################
##
#O  InertiaSubgroup( <H>, <psi> )
##
InertiaSubgroup := NewOperation( "InertiaSubgroup",
    [ IsGroup, IsClassFunctionWithGroup and IsCharacter ] );


#############################################################################
##
#A  KernelOfCharacter( <psi> )
##
##  is the kernel of any representation of the underlying group of the
##  character <psi> affording the character <psi>.
##
KernelOfCharacter := NewAttribute( "KernelOfCharacter",
    IsClassFunctionWithGroup and IsCharacter );
SetKernelOfCharacter := Setter( KernelOfCharacter );
HasKernelOfCharacter := Tester( KernelOfCharacter );


#############################################################################
##
#A  KernelChar( <psi> )
##
##  is the list of positions of those conjugacy classes that form the kernel
##  of the character <psi>, that is, those positions with character value
##  equal to the character degree.
##
KernelChar := NewAttribute( "KernelChar", IsClassFunction and IsCharacter );
SetKernelChar := Setter( KernelChar );
HasKernelChar := Tester( KernelChar );


#############################################################################
##
#A  TrivialCharacter( <tbl> )
#A  TrivialCharacter( <G> )
##
##  is the trivial character of the group <G> resp. its character table
##  <tbl>.
##
TrivialCharacter := NewAttribute( "TrivialCharacter",
    IsNearlyCharacterTable );
SetTrivialCharacter := Setter( TrivialCharacter );
HasTrivialCharacter := Tester( TrivialCharacter );


#############################################################################
##
#A  NaturalCharacter( <G> )
##
##  If <G> is a permutation group then 'NaturalCharacter' returns the
##  character of the natural permutation representation of <G> on the set of
##  moved points.
##
##  If <G> is a matrix group in characteristic zero then 'NaturalCharacter'
##  returns the character of the natural matrix representation of <G>.
##
NaturalCharacter := NewAttribute( "NaturalCharacter", IsGroup );
SetNaturalCharacter := Setter( NaturalCharacter );
HasNaturalCharacter := Tester( NaturalCharacter );


#############################################################################
##
#O  PermutationCharacter( <G>, <U> )
##
##  is the permutation character of the operation of the group <G> on the
##  cosets of its subgroup <U>.
##  The $i$-th position contains the  value of the permutation character on
##  the $i$-th conjugacy class of <G> (see "ConjugacyClasses").
##  
##  The value of the *permutation character* of <U> in <G> on a class $c$ of
##  <G> is the number of right cosets invariant under the action of an
##  element of $c$.
##
##  To compute the permutation character of a *transitive permutation group*
##  <G> on the cosets of a point stabilizer <U>, 'NaturalCharacter( <G> )'
##  can be used instead of 'PermutationCharacter( <G>, <U> )'.
##
PermutationCharacter := NewOperation( "PermutationCharacter",
    [ IsGroup, IsGroup ] );


#############################################################################
##
#O  ClassFunctionByValues( <tbl>, <values> )
##
##  Note that the characteristic of the class function is determined by
##  <tbl>.
##
ClassFunctionByValues := NewOperation( "ClassFunctionByValues",
    [ IsNearlyCharacterTable, IsHomogeneousList ] );


#############################################################################
##
#O  VirtualCharacterByValues( <tbl>, <values> )
##
VirtualCharacterByValues := NewOperation( "VirtualCharacterByValues",
    [ IsNearlyCharacterTable, IsHomogeneousList ] );


#############################################################################
##
#O  CharacterByValues( <tbl>, <values> )
##
CharacterByValues := NewOperation( "CharacterByValues",
    [ IsNearlyCharacterTable, IsHomogeneousList ] );


#############################################################################
##
#F  ClassFunctionSameType( <tbl>, <chi>, <values> )
##
##  is the class function $\psi$ of the table <tbl>
##  (esp. of same characteristic as <tbl>) with values list <values>.
##
##  If <chi> is a virtual character then $\psi$ is a virtual character,
##  if <chi> is a character then $\psi$ is a character.
##
##  (<chi> need *not* be a class function of <tbl>.)
##
ClassFunctionSameType := NewOperationArgs( "ClassFunctionSameType" );


#############################################################################
##
#A  CentralCharacter( <psi> )
##
CentralCharacter := NewAttribute( "CentralCharacter",
    IsClassFunction and IsCharacter );


#############################################################################
##
#O  CentralChar( <tbl>, <psi> )
##
##  is the list of values of the central character corresp. to the character
##  <chi> of the ordinary character table <tbl>.
##
CentralChar := NewOperation( "CentralChar",
    [ IsNearlyCharacterTable, IsCharacter ] );


#############################################################################
##
#A  DeterminantOfCharacter( <psi> )
##
DeterminantOfCharacter := NewAttribute( "DeterminantOfCharacter",
    IsClassFunction and IsCharacter );


##############################################################################
##
#O  DeterminantChar( <tbl>, <chi> )
##
##  is the list of values of the determinant of the character <chi>
##  of the ordinary character table <tbl>.
##  This is defined to be the character obtained on taking the determinant of
##  representing matrices of a representation affording <chi>.
##
DeterminantChar := NewOperation( "DeterminantChar",
    [ IsNearlyCharacterTable, IsVirtualCharacter ] );


#############################################################################
##
#O  EigenvaluesChar( <tbl>, <char>, <class> )
##
##  Let $M$ be a matrix of a representation affording the character <char>,
##  for a group element in the <class>-th conjugacy class of <tbl>.
##
##  'EigenvaluesChar( <tbl>, <char>, <class> )' is the list of length
##  '$n$ = orders[ <class> ]' where at position 'k' the multiplicity
##  of 'E(n)^k = $e^{\frac{2\pi i k}{n}$' as eigenvalue of $M$ is stored.
##
##  We have '<char>[ <class> ] = List( [ 1 .. <n> ], k -> E(n)^k )
##                               * EigenvaluesChar( <tbl>, <char>, <class> ).
##
EigenvaluesChar := NewOperation( "EigenvaluesChar",
    [ IsNearlyCharacterTable, IsCharacter, IsInt and IsPosRat ] );


#############################################################################
##
#O  RestrictedClassFunction( <chi>, <H> )
#O  RestrictedClassFunction( <chi>, <tbl> )
##
##  is the restriction of the $G$-class function <chi> to the subgroup
##  or downward extension <H> of $G$. 
##
RestrictedClassFunction := NewOperation( "RestrictedClassFunction",
    [ IsClassFunction, IsGroup ] );


InflatedClassFunction := RestrictedClassFunction;


#############################################################################
##
#O  RestrictedClassFunctions( <chars>, <H> )
#O  RestrictedClassFunctions( <chars>, <tbl> )
##
##  is the restrictions of the $G$-class functions <chars> to the
##  subgroup or downward extension <H> of $G$. 
##
#O  RestrictedClassFunctions( <tbl>, <subtbl>, <chars> )
#O  RestrictedClassFunctions( <tbl>, <subtbl>, <chars>, <specification> )
#O  RestrictedClassFunctions( <chars>, <fusionmap> )
##
##  is the list of indirections of <chars> from <tbl> to <subtbl> by a fusion
##  map.  This map can either be entered directly as <fusionmap>, or it must
##  be stored on the table <subtbl>; in the latter case the value of the
##  'specification' field may be specified.
##
RestrictedClassFunctions := NewOperation( "RestrictedClassFunctions",
    [ IsClassFunctionCollection, IsGroup ] );


InflatedClassFunctions := RestrictedClassFunctions;


#############################################################################
##
#O  InducedClassFunction( <chi>, <G> )
#O  InducedClassFunction( <chi>, <tbl> )
##
##  is the class function obtained on induction of <chi> to <G>.
##
InducedClassFunction := NewOperation( "InducedClassFunction",
    [ IsClassFunction, IsGroup ] );


#############################################################################
##
#O  InducedClassFunctions( <chars>, <G> )
#O  InducedClassFunctions( <chars>, <tbl> )
##
##  is the list of class function obtained on induction of the class
##  functions in the list <chars> to <G>.
##
#O  InducedClassFunctions( <subtbl>, <tbl>, <chars> )
#O  InducedClassFunctions( <subtbl>, <tbl>, <chars>, <specification> )
#O  InducedClassFunctions( <subtbl>, <tbl>, <chars>, <fusionmap> )
##
##  induces <chars> from <subtbl> to <tbl>.
##  The fusion map can either be entered directly as <fusionmap>,
##  or it must be stored on the table <subtbl>;
##  in the latter case the value of the 'specification' field may be
##  specified.
##
##  Note that <specification> must not be a list!
##
InducedClassFunctions := NewOperation( "InducedClassFunctions",
    [ IsClassFunctionCollection, IsGroup ] );


#############################################################################
##
#O  ReducedClassFunctions( <ordtbl>, <constituents>, <reducibles> )
#O  ReducedClassFunctions( <ordtbl>, <reducibles> )
##
##  is a record with components 'remainders' and 'irreducibles', both lists
##
##  Let 'rems' be the set of nonzero characters obtained from <reducibles>
##  by subtraction of
##  $\sum_{j}
##   \frac{'ScalarProduct( <ordtbl>, <reducibles>[i], <constituents>[j]}
##        {'ScalarProduct( <ordtbl>, <constituents>[j], <constituents>[j]}
##            \cdot <constituents>[j]$
##  from '<reducibles>[i]'.
##
##  Let 'irrs' be the list of irreducible characters in 'rems'.
##
##  We reduce 'rems' with 'irrs' and all found irreducibles until no new
##  irreducibles are found.
##  Then 'irreducibles' is the set of all found irreducible characters,
##  'remainders' is the set of all nonzero remainders.
##
##  The class functions in <constituents> and <reducibles> are assumed to
##  be virtual characters.
##
#T why not to allow a projection into the orthogonal space of <constituents>?
#T (<constituents> would have to be irreducibles then)
##  
ReducedClassFunctions := NewOperation( "ReducedClassFunctions",
    [ IsOrdinaryTable, IsHomogeneousList, IsHomogeneousList ] );

Reduced:= ReducedClassFunctions;
#T compatibility with GAP-3


#############################################################################
##
#O  ReducedCharacters( <ordtbl>, <constituents>, <reducibles> )
##
##  like 'Reduced', but <constituents> and <reducibles> are known to be
##  proper characters of <ordtbl>, so only those scalar products must be
##  formed where the degree of the constituent is not bigger than the
##  degree of the reducibles character.
##
ReducedCharacters := NewOperation( "ReducedOrdinary",
    [ IsOrdinaryTable, IsHomogeneousList, IsHomogeneousList ] );

ReducedOrdinary:= ReducedCharacters;
#T compatibility with GAP-3


#############################################################################
##
##  auxiliary operations
##

#############################################################################
##
#A  GlobalPartitionOfClasses( <G> )
##
##  Let <n> be the number of conjugacy classes of the group <G>.
##  'GlobalPartitionOfClasses( <G> )' is a partition of the set
##  '[ 1 .. <n> ]' that is respected by every table automorphism of the
##  character table of <G>.
##  (*Note* that also fixed points occur)
##
##  This is useful for the computation of table automorphisms.
##
##  Since group automorphisms induce table automorphisms, the partition is
##  also respected by the permutation group that occurs in the computation
##  of inertia groups and conjugate class functions.
##
##  If the group of table automorphisms is already known then its orbits
##  form the finest possible global partition.
##
##  Otherwise the subsets in the partition are the sets of classes with
##  same centralizer order and same element order, and if the character table
##  is known the same number of $p$-th root classes for all $p$ for that the
##  power maps are stored.
##
GlobalPartitionOfClasses := NewAttribute( "GlobalPartitionOfClasses",
    IsGroup );


#############################################################################
##
#O  CorrespondingPermutation(   <G>, <g> )
#O  CorrespondingPermutation( <chi>, <g> )
##
##  If the first argument is a group then the permutation of conjugacy
##  classes is returned that is induced by the group element <g>.
##
##  If the first argument is a class function <chi> then the returned
##  permutation will at least yield the same conjugate class function as
##  the permutation induced by <g>, that is, the images are not computed
##  for orbits on that <chi> is constant.
#T for 'g' in 'H' is the identity or not?
##
CorrespondingPermutation := NewOperation( "CorrespondingPermutation",
    [ IsGroup, IsMultiplicativeElementWithInverse ] );


#############################################################################
##
#A  PermClassesHomomorphism( <G> )
##
##  returns the group homomorphism mapping each element of the normalizer of
##  <G> in its parent to the induced permutation of the conjugacy classes of
##  <G>.
##
PermClassesHomomorphism := NewAttribute( "PermClassesHomomorphism",
    IsGroup );
#T SetIsParentDependent( PermClassesHomomorphism, true );


##############################################################################
##
#A  NormalSubgroupClassesInfo( <G> )
##
##  Many computations for group characters of a group $G$ involve computations
##  in normal subgroups or factor groups of $G$.
##
##  In some cases the character table of $G$ is sufficient, a question about a
##  normal subgroup $N$ can be answered if one knows the conjugacy classes
##  that form $N$, e.g., the question whether a character of $G$ restricts
##  irreducibly to $N$.  But other questions require the computation of $N$ or
##  even more information, like the character table of $N$.
##
##  In order to do these computations only once, one stores in the group a
##  record with components to store normal subgroups, the corresponding lists
##  of conjugacy classes, and (if necessary) the factor groups, namely
##
##  'nsg': \\        list of normal subgroups of $G$, may be incomplete,
##
##  'nsgclasses': \\ at position $i$ the list of positions of conjugacy
##                   classes forming the $i$-th entry of the 'nsg' component,
##
##  'nsgfactors': \\ at position $i$ (if bound) the factor group
##                   modulo the $i$-th entry of the 'nsg' component.
##
##  The functions
##
##     'NormalSubgroupClasses',
##     'FactorGroupNormalSubgroupClasses', and
##     'ClassesOfNormalSubgroup'
##
##  use these components, and they are the only functions that do this.
##
##  So if you need information about a normal subgroup for that you know the
##  conjugacy classes, you should get it using 'NormalSubgroupClasses'.  If
##  the normal subgroup was already used it is just returned, with all the
##  knowledge it contains.  Otherwise the normal subgroup is added to the
##  lists, and will be available for the next call.
##
##  For example, if you are dealing with kernels of characters using the
##  'KernelOfCharacter' function you make use of this feature
##  because 'KernelOfCharacter' calls 'NormalSubgroupClasses'.
##
NormalSubgroupClassesInfo := NewAttribute(
    "NormalSubgroupClassesInfo", IsGroup, "mutable" );
SetNormalSubgroupClassesInfo := Setter( NormalSubgroupClassesInfo );
HasNormalSubgroupClassesInfo := Tester( NormalSubgroupClassesInfo );


##############################################################################
##
#F  ClassesOfNormalSubgroup( <G>, <N> )
##
##  is the list of positions of conjugacy classes of the group <G> that
##  are contained in the normal subgroup <N> of <G>.
##
ClassesOfNormalSubgroup := NewOperationArgs( "ClassesOfNormalSubgroup" );


##############################################################################
##
#F  NormalSubgroupClasses( <G>, <classes> )
##
##  returns the normal subgroup of the group <G> that consists of the
##  conjugacy classes whose positions are in the list <classes>.
##
##  If 'NormalSubgroupClassesInfo( <G> ).nsg' does not yet contain
##  the required normal subgroup,
##  and if 'NormalSubgroupClassesInfo( <G> ).normalSubgroups' is bound then
##  the result will be identical to the group in
##  'NormalSubgroupClassesInfo( <G> ).normalSubgroups'.
##
NormalSubgroupClasses := NewOperationArgs( "NormalSubgroupClasses" );


##############################################################################
##
#F  FactorGroupNormalSubgroupClasses( <G>, <classes> )
##
##  is the factor group of the group <G> modulo the normal subgroup of
##  <G> that consists of the conjugacy classes whose positions are in the
##  list <classes>.
##
FactorGroupNormalSubgroupClasses := NewOperationArgs(
    "FactorGroupNormalSubgroupClasses" );


#############################################################################
##
#O  MatScalarProducts( <tbl>, <characters1>, <characters2> )
#O  MatScalarProducts( <tbl>, <characters> )
##
##  The first form returns the matrix of scalar products:
##
##  $'MatScalarProducts( <tbl>, <characters1>, <characters2> )[i][j]' =
##  'ScalarProduct( <tbl>, <characters1>[j], <characters2>[i] )'$,
##
##  the second form returns a lower triangular matrix of scalar products:
##
##  $'MatScalarProducts( <tbl>, <characters> )[i][j]' =
##  'ScalarProduct( <tbl>, <characters>[j], <characters>[i] )'$ for
##  $ j \leq i $.
##  
MatScalarProducts := NewOperationArgs( "MatScalarProducts" );


##############################################################################
##
#F  OrbitChar( <chi>, <linear> )
##
##  is the orbit of the character values list <chi> under the action of
##  Galois automorphisms and multiplication with the linear characters in
##  the list <linear>.
##
##  It is assumed that <linear> is closed under Galois automorphisms and
##  tensoring.
##  (This means that we can first form the orbit under Galois action, and
##  then apply the linear characters to all Galois conjugates.)
##
OrbitChar := NewOperationArgs( "OrbitChar" );


##############################################################################
##
#F  OrbitsCharacters( <irr> )
##
##  is a list of orbits of the characters <irr> under the action of
##  Galois automorphisms and multiplication with linear characters.
##
OrbitsCharacters := NewOperationArgs( "OrbitsCharacters" );


##############################################################################
##
#F  OrbitRepresentativesCharacters( <irr> )
##
##  is a list of representatives of the orbits of the characters <irr>
##  under the action of Galois automorphisms and multiplication with linear
##  characters.
##
OrbitRepresentativesCharacters := NewOperationArgs(
    "OrbitRepresentativesCharacters" );


#############################################################################
##
#E  ctblfuns.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



