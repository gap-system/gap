#############################################################################
##
#W  clas.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
Revision.clas_gd :=
    "@(#)$Id$";

InfoClasses := NewInfoClass( "InfoClasses" );

#############################################################################
##
#R  IsExternalOrbitByStabilizerRep  . . . . .  external orbit via transversal
##
IsExternalOrbitByStabilizerRep := NewRepresentation
    ( "IsExternalOrbitByStabilizerRep", IsExternalOrbit, [  ] );

#############################################################################
##
#R  IsExternalOrbitByStabilizerEnumerator . . . . . . . . enumerator for such
##
IsExternalOrbitByStabilizerEnumerator := NewRepresentation
    ( "IsExternalOrbitByStabilizerEnumerator",
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
IsConjugacyClassGroupRep := NewRepresentation( "IsConjugacyClassGroupRep",
    IsExternalOrbitByStabilizerRep, [  ] );

IsConjugacyClassPermGroupRep := NewRepresentation
    ( "IsConjugacyClassPermGroupRep", IsConjugacyClassGroupRep, [  ] );

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
ConjugacyClass := NewOperation( "ConjugacyClass", [ IsGroup, IsObject ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#R  IsRationalClassGroupRep . . . . . . . . . . . . . rational class in group
##
##  Rational classes have the representation `IsRationalClassGroupRep', a
##  subrepresentation is `IsRationalClassPermGroupRep' for permutation
##  groups.
IsRationalClassGroupRep := NewRepresentation( "IsRationalClassGroupRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "galoisGroup", "power" ] );

IsRationalClassPermGroupRep := NewRepresentation
    ( "IsRationalClassPermGroupRep", IsRationalClassGroupRep,
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
##  rational class can be interpreted as a conjugacy class of cyclic subgroups.
##  A rational class is an external set ("IsExternalSet") of group elements with
##  the group acting by conjugation on it but not an external orbit.
##
##  The exponents $i$  for which $<g>^i$
##  lies  already in the ordinary  conjugacy  class of  <g>, form a  subgroup
##  of the *prime residue class group* $P_n$ (see "where"), the so-called 
##  *Galois group*  of the rational class. The prime residue class group $P_n$ 
##  is obtained in {\GAP}  as `Units( Integers mod <n> )', the  unit group
##  of a residue  class ring. The Galois group of a rational class <rcl>
##  is stored in the attribute `GaloisGroup( <rcl>)' as a subgroup of this
##  group.
#T Is the next true? should it be that way?
##  There is an exeception for the class of the identity element, because the
##  residue class ring `Integers mod 1' has  no units. Since the Galois group
##  of the identity is trivial, it is  simply represented as `Units( Integers
##  mod 2 )'.
RationalClass := NewOperation( "RationalClass", [ IsGroup, IsObject ] );
#T 1997/01/16 fceller was old 'NewConstructor'

DecomposedRationalClass := NewOperationArgs( "DecomposedRationalClass" );
GroupByPrimeResidues := NewOperationArgs( "GroupByPrimeResidues" );
ConjugacyClassesByRandomSearch :=
  NewOperationArgs( "ConjugacyClassesByRandomSearch" );
ConjugacyClassesTry := NewOperationArgs( "ConjugacyClassesTry" );
RationalClassesTry := NewOperationArgs( "RationalClassesTry" );
RationalClassesInEANS := NewOperationArgs( "RationalClassesInEANS" );

SubspaceVectorSpaceGroup := NewOperationArgs( "SubspaceVectorSpaceGroup" );
CentralStepConjugatingElement := NewOperationArgs( "CentralStepConjugatingElement" );
KernelHcommaC := NewOperationArgs( "KernelHcommaC" );
OrderModK := NewOperationArgs( "OrderModK" );
CentralStepRatClPGroup := NewOperationArgs( "CentralStepRatClPGroup" );
CentralStepClEANS := NewOperationArgs( "CentralStepClEANS" );
CorrectConjugacyClass := NewOperationArgs( "CorrectConjugacyClass" );
GeneralStepClEANS := NewOperationArgs( "GeneralStepClEANS" );
ClassesSolvableGroup := NewOperationArgs( "ClassesSolvableGroup" );

CompleteGaloisGroupPElement := NewOperationArgs( "CompleteGaloisGroupPElement" );
RatClasPElmArrangeClasses := NewOperationArgs( "RatClasPElmArrangeClasses" );
SortRationalClasses := NewOperationArgs( "SortRationalClasses" );
FusionRationalClassesPSubgroup := NewOperationArgs( "FusionRationalClassesPSubgroup" );
RationalClassesPElements := NewOperationArgs( "RationalClassesPElements" );
RationalClassesPermGroup := NewOperationArgs( "RationalClassesPermGroup" );

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  clas.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
