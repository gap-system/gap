#############################################################################
##
#W  clas.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
#R  IsExternalOrbitByStabilizerEnumerator . . . . . . . . enumerator for such
##
DeclareRepresentation ( "IsExternalOrbitByStabilizerEnumerator",
      IsDomainEnumerator and IsComponentObjectRep and IsAttributeStoringRep,
      [ "rightTransversal" ] );

#############################################################################
##
#R  IsConjugacyClassGroupRep  . . . . . . . . . . .  conjugacy class in group
#R  IsConjugacyClassPermGroupRep  . . . . . . . . .  conjugacy class in group
##
##  Conjugacy classes have the representation `IsConjugacyClassGroupRep', a
##  subrepresentation is `IsConjugacyClassPermGroupRep' for permutation
##  groups.
DeclareRepresentation( "IsConjugacyClassGroupRep",
    IsExternalOrbitByStabilizerRep, [  ] );

DeclareRepresentation( "IsConjugacyClassPermGroupRep",
    IsConjugacyClassGroupRep, [  ] );

#############################################################################
##
#C  ConjugacyClass( <G>, <g> )  . . . . . . . . . conjugacy class constructor
##
##  creates the conjugacy class in $G$ with representative $g$.
##  A conjugacy class is an
##  external orbit ("ExternalOrbit") of group elements with the group acting
##  by conjugation on it. Thus element tests or operation representatives can be
##  computed.  The attribute `Centralizer' gives the centralizer of
##  the representative which is the same result as `StabilizerOfExternalSet'.
DeclareOperation( "ConjugacyClass", [ IsGroup, IsObject ] );


#############################################################################
##
#R  IsRationalClassGroupRep . . . . . . . . . . . . . rational class in group
##
##  Rational classes have the representation `IsRationalClassGroupRep', a
##  subrepresentation is `IsRationalClassPermGroupRep' for permutation
##  groups.
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
#T The '*' in the 'Size' method (file `clas.gi') indicates that infinite
#T rational classes are not allowed.


#############################################################################
##
#C  RationalClass( <G>, <g> ) . . . . . . . . . .  rational class constructor
##
##  creates the rational class in $G$ with representative $g$.
##  A rational class consists of elements that are conjugate to
##  $g$ or to a power $g^i$ where $i$ is coprime to the order of $g$. Thus a
##  rational class can be interpreted as a conjugacy class of cyclic
##  subgroups.  A rational class is an external set ("IsExternalSet") of
##  group elements with the group acting by conjugation on it but not an
##  external orbit.
##
##  The exponents $i$  for which $<g>^i$ lies  already in the ordinary
##  conjugacy  class of  <g>, form a  subgroup of the *prime residue class
##  group* $P_n$ (see "PrimitiveRootMod"), the so-called *Galois group*  of
##  the rational class. The prime residue class group $P_n$ is obtained in
##  {\GAP}  as `Units( Integers mod <n> )', the  unit group of a residue
##  class ring. The Galois group of a rational class <rcl> is stored in the
##  attribute `GaloisGroup( <rcl>)' as a subgroup of this group.
DeclareOperation( "RationalClass", [ IsGroup, IsObject ] );

DeclareGlobalFunction( "DecomposedRationalClass" );
DeclareGlobalFunction( "GroupByPrimeResidues" );
DeclareGlobalFunction( "ConjugacyClassesByRandomSearch" );
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
##  1 Rational classes of a $p$-group (mode 3 is used internally as well)
##
##  4 Conjugacy test for the two elements in <opt>`.candidates'
##
##  In mode 0 the function returns a list of records containing components
##  <representative> and <centralizer>. In mode 1 the records in addition
##  contain the component <galoisGroup>. In mode <4> it returns a
##  conjugating element.
##
##  The optional record <opt> may contain the following components that will
##  affect the algorithms behavior:
##  
##  \beginitems
##  `pcgs'&is a Pcgs that will be used for the calculation. In the case of
##  the calculation of rational classes, it must be a pcgs refining a
##  central series. The attribute `NormalSeriesByPcgs' must return an
##  appropriate series of normal subgroups with elementary abelian factors
##  among them. The algorithm will step down this series. By default an
##  `ElementaryAbelianSeries' is used for modes 0 and 4 and a
##  `CentralSeries' for mode 1.
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
##  `consider'&is a function <consider>(<rep>,<cen>,<K>,<L>). Here <rep> is
##  an element of <G> and <cen>/<K> is the centralizer of <rep><K> modulo
##  <K>. In mode 0 when lifting from <G>/<K> to <G>/<L> this function is
##  called before performing the actual lifting and only those
##  representatives for which it returns `true' are passed to the next
##  level. This permits to calculate only classes with say small
##  centralizers or classes of restricted orders.
##  \enditems
DeclareGlobalFunction( "ClassesSolvableGroup" );


#############################################################################
##
#F  CentralizerSizeLimitConsiderFunction(<sz>)
##
##  returns a function <consider>(<rep>,<cen>,<K>,<L>) that can be used in
##  `ClassesSolvableGroup' as the <consider> component of the options record
##  to limit the lifting to centralizers of size at most <sz>.
DeclareGlobalFunction( "CentralizerSizeLimitConsiderFunction" );

DeclareGlobalFunction( "CompleteGaloisGroupPElement" );
DeclareGlobalFunction( "RatClasPElmArrangeClasses" );
DeclareGlobalFunction( "SortRationalClasses" );
DeclareGlobalFunction( "FusionRationalClassesPSubgroup" );
DeclareGlobalFunction( "RationalClassesPElements" );
DeclareGlobalFunction( "RationalClassesPermGroup" );


#############################################################################
##
#E  clas.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
