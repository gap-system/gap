#############################################################################
##
#W  clas.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
Revision.clas_gd :=
    "@(#)$Id$";

DeclareInfoClass( "InfoClasses" );

#############################################################################
##
#R  IsExternalOrbitByStabilizerRep  . . . . .  external orbit via transversal
##
DeclareRepresentation( "IsExternalOrbitByStabilizerRep",
    IsExternalOrbit, [  ] );


#############################################################################
##
#R  IsConjugacyClassGroupRep( <obj> )
#R  IsConjugacyClassPermGroupRep( <obj> )
##
##  is a representation of conjugacy classes, a subrepresentation for
##  permutation groups is `IsConjugacyClassPermGroupRep'
##
DeclareRepresentation( "IsConjugacyClassGroupRep",
    IsExternalOrbitByStabilizerRep, [  ] );

DeclareRepresentation( "IsConjugacyClassPermGroupRep",
    IsConjugacyClassGroupRep, [  ] );

#############################################################################
##
#O  ConjugacyClass( <G>, <g> )  . . . . . . . . . conjugacy class constructor
##
##  creates the conjugacy class in $G$ with representative $g$.
##  This class is an external set, so functions such as
##  `Representative' (which returns <g>),
##  `ActingDomain' (which returns <G>),
##  `StabilizerOfExternalSet' (which returns the centralizer of <g>)
##  and `AsList' work for it.
##
##  A conjugacy class is an external orbit ("ExternalOrbit") of group
##  elements with the group acting by conjugation on it. Thus element tests
##  or operation representatives can be computed.  The attribute
##  `Centralizer' gives the centralizer of the representative (which is the
##  same result as `StabilizerOfExternalSet'). (This is a slight abuse of
##  notation: This is *not* the centralizer of the class as a *set* which
##  would be the standard behaviour of `Centralizer'.)
##
DeclareOperation( "ConjugacyClass", [ IsGroup, IsObject ] );


#############################################################################
##
#R  IsRationalClassGroupRep . . . . . . . . . . . . . rational class in group
#R  IsRationalClassPermGroupRep . . . . . . . . rational class in perm. group
##
##  is a representation of rational classes, a subrepresentation for
##  permutation groups is `IsRationalClassPermGroupRep'
##
DeclareRepresentation( "IsRationalClassGroupRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "galoisGroup", "power" ] );

DeclareRepresentation( "IsRationalClassPermGroupRep",
    IsRationalClassGroupRep,
    [ "galoisGroup", "power" ] );


#############################################################################
##
#M  IsFinite( <cl> )  . . . . . . . . . . . . . . . . .  for a rational class
##
InstallTrueMethod( IsFinite, IsRationalClassGroupRep and IsDomain );
#T The `*' in the `Size' method (file `clas.gi') indicates that infinite
#T rational classes are not allowed.


#############################################################################
##
#O  RationalClass( <G>, <g> ) . . . . . . . . . .  rational class constructor
##
##  creates the rational class in $G$ with representative $g$.
##  A rational class consists of all elements that are conjugate to
##  $g$ or to a power $g^i$ where $i$ is coprime to the order of $g$. Thus a
##  rational class can be interpreted as a conjugacy class of cyclic
##  subgroups.  A rational class is an external set ("IsExternalSet") of
##  group elements with the group acting by conjugation on it, but not an
##  external orbit.
##
DeclareOperation( "RationalClass", [ IsGroup, IsObject ] );


#############################################################################
##
#A  GaloisGroup( <ratcl> )
##
##  Suppose that <ratcl> is a rational class of a group <G> with
##  representative <g>.
##  The exponents $i$  for which $<g>^i$ lies  already in the ordinary
##  conjugacy  class of  <g>, form a  subgroup of the *prime residue class
##  group* $P_n$ (see "PrimitiveRootMod"), the so-called *Galois group*  of
##  the rational class. The prime residue class group $P_n$ is obtained in
##  {\GAP}  as `Units( Integers mod <n> )', the  unit group of a residue
##  class ring. The Galois group of a rational class <rcl> is stored in the
##  attribute `GaloisGroup(<rcl>)' as a subgroup of this group.
DeclareAttribute( "GaloisGroup", IsRationalClassGroupRep );


#############################################################################
##
#F  ConjugacyClassesByRandomSearch( <G> )
##
##  computes the classes of the group <G> by random search.
##  This works very efficiently for almost simple groups.
##
##  This function is also accessible via the option `random' to
##  `ConjugacyClass'.
DeclareGlobalFunction( "ConjugacyClassesByRandomSearch" );

#############################################################################
##
#F  ConjugacyClassesByOrbits( <G> )
##
##  computes the classes of the group <G> as orbits of <G> on its elements.
##  This can be quick but unsurprisingly may also take a lot of memory if
##  <G> becomes larger. All the classes will store their element list and
##  thus a membership test will be quick as well.
##
##  This function is also accessible via the option `action' to
##  `ConjugacyClass'.
DeclareGlobalFunction( "ConjugacyClassesByOrbits" );

# This function computes the classes by orbits if the group is small and the
# `noaction' option is not set, otherwise it returns `fail'.
DeclareGlobalFunction( "ConjugacyClassesForSmallGroup" );

DeclareGlobalFunction( "DecomposedRationalClass" );
DeclareGlobalFunction( "GroupByPrimeResidues" );

DeclareGlobalFunction( "ConjugacyClassesTry" );
DeclareGlobalFunction( "RationalClassesTry" );
DeclareGlobalFunction( "RationalClassesInEANS" );

DeclareGlobalFunction( "SubspaceVectorSpaceGroup" );
DeclareGlobalFunction( "CentralStepConjugatingElement" );
DeclareGlobalFunction( "KernelHcommaC" );
DeclareGlobalFunction( "OrderModK" );
DeclareGlobalFunction( "CentralStepRatClPGroup" );
DeclareGlobalFunction( "CentralStepClEANS" );
DeclareGlobalFunction( "CorrectConjugacyClass" );
DeclareGlobalFunction( "GeneralStepClEANS" );

#############################################################################
##
#F  ClassesSolvableGroup(<G>, <mode> [,<opt>])  . . . . .
##
##  computes conjugacy classes and centralizers in solvable groups. <G> is
##  the acting group. <mode> indicates the type of the calculation:
##
##  0 Conjugacy classes
##
##  4 Conjugacy test for the two elements in <opt>`.candidates'
##
##  In mode 0 the function returns a list of records containing components
##  <representative> and <centralizer>. In mode <4> it returns a
##  conjugating element.
##
##  The optional record <opt> may contain the following components that will
##  affect the algorithms behaviour:
##  
##  \beginitems
##  `pcgs'&is a pcgs that will be used for the calculation.
##  The attribute `EANormalSeriesByPcgs' must return an
##  appropriate series of normal subgroups with elementary abelian factors
##  among them. The algorithm will step down this series.
##  In the case of
##  the calculation of rational classes, it must be a pcgs refining a
##  central series.
##
##  `candidates'&is a list of elements for which canonical representatives
##  are to be computed or for which a conjugacy test is performed. They must
##  be given in mode 4. In mode 0 a list of classes corresponding to
##  <candidates> is returned (which may contain duplicates). The
##  <representative>s chosen are canonical with respect to <pcgs>. The
##  records returned also contain components <operator>
##  such that
##  (<candidate> `^' <operator>) =<representative>.
##
##  `consider'&is a function <consider>(<fhome>,<rep>,<cenp>,<K>,<L>). Here
##  <fhome> is a home pcgs for the factor group <F> in which the calculation
##  currently takes place, <rep> is an element of the factor and <cenp> is a
##  pcgs for the centralizer of <rep> modulo <K>. In mode 0, when lifting
##  from <F>/<K> to <F>/<L> (note: for efficiency reasons, <F> can be
##  different from <G> or <L> might be not trivial) this function is called
##  before performing the actual lifting and only those representatives for
##  which it returns `true' are passed to the next level. This permits for
##  example the calculation of only those classes with small centralizers or
##  classes of restricted orders.
##  \enditems
DeclareGlobalFunction( "ClassesSolvableGroup" );

#############################################################################
##
#F  RationalClassesSolvableGroup(<G>, <mode> [,<opt>])  . . . . .
##
##  computes rational classes and centralizers in solvable groups. <G> is
##  the acting group. <mode> indicates the type of the calculation:
##
##  1 Rational classes of a $p$-group (mode 3 is used internally as well)
##
##  In mode 0 the function returns a list of records containing components
##  <representative> and <centralizer>. In mode 1 the records in addition
##  contain the component <galoisGroup>.
##
##  The optional record <opt> may contain the following components that will
##  affect the algorithms behaviour:
##  
##  \beginitems
##  `pcgs'&is a pcgs that will be used for the calculation. In the case of
##  the calculation of rational classes, it must be a pcgs refining a
##  central series. The attribute `CentralNormalSeriesByPcgs' must return an
##  appropriate series of normal subgroups with elementary abelian factors
##  among them. The algorithm will step down this series.
##
##  `candidates'&is a list of elements for which canonical representatives
##  are to be computed or for which a conjugacy test is performed. They must
##  be given in mode 4. In modes 0 and 1 a list of classes corresponding to
##  <candidates> is returned (which may contain duplicates). The
##  <representative>s chosen are canonical with respect to <pcgs>. The
##  records returned also contain components <operator> and (in mode 1)
##  <exponent> such that
##  (<candidate> `^' <operator>) `^' <exponent>=<representative>.
##
##  %`consider'&is a function <consider>(<rep>,<cen>,<K>,<L>). Here <rep> is
##  %an element of <G> and <cen>/<K> is the centralizer of <rep><K> modulo
##  %<K>. In mode 0 when lifting from <G>/<K> to <G>/<L> this function is
##  %called before performing the actual lifting and only those
##  %representatives for which it returns `true' are passed to the next
##  %level. This permits the calculation of only those classes with say small
##  %centralizers or classes of restricted orders.
##  \enditems
DeclareGlobalFunction( "RationalClassesSolvableGroup" );


#############################################################################
##
#F  CentralizerSizeLimitConsiderFunction(<sz>)
##
##  returns a function  (of the form func(<fhome>,<rep>,<cen>,<K>,<L>)
##  )that can be used in `ClassesSolvableGroup' as the <consider> component
##  of the options record. It will restrict the lifting to those classes,
##  for which the size of the centralizer (in the factor) is at most <sz>.

DeclareGlobalFunction( "CentralizerSizeLimitConsiderFunction" );

DeclareGlobalFunction( "CompleteGaloisGroupPElement" );
DeclareGlobalFunction( "RatClasPElmArrangeClasses" );
DeclareGlobalFunction( "SortRationalClasses" );
DeclareGlobalFunction( "FusionRationalClassesPSubgroup" );
DeclareGlobalFunction( "RationalClassesPElements" );
DeclareGlobalFunction( "RationalClassesPermGroup" );


#############################################################################
##
#E

