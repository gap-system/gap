#############################################################################
##
#W  clas.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.9  1997/01/16 10:46:18  fceller
#H  renamed 'NewConstructor' to 'NewOperation',
#H  renamed 'NewOperationFlags1' to 'NewConstructor'
#H
#H  Revision 4.8  1997/01/11 13:02:40  htheisse
#H  fixed an error in `CentralStepRatClPGroup'; cleaned up the code
#H
#H  Revision 4.7  1997/01/10 08:45:31  htheisse
#H  added conjugacy class functions for perm groups and pcgs groups
#H
#H  Revision 4.6  1996/12/19 09:58:51  htheisse
#H  added revision lines
#H
#H  Revision 4.5  1996/12/17 13:49:45  htheisse
#H  improved enumerator for rational classes
#H
#H  Revision 4.4  1996/10/31 12:23:06  htheisse
#H  changed representation of conjugacy classes to `ExternalOrbitByStabilizer'
#H
#H  Revision 4.3  1996/10/11 07:04:27  htheisse
#H  added operation `RightTransversal'
#H
#H  Revision 4.2  1996/10/09 13:31:29  htheisse
#H  made conjugacy class functions work (at least for M24)
#H
#H  Revision 4.1  1996/10/09 11:37:56  htheisse
#H  made first steps towards computation of conjugacy classes
#H
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
##
IsConjugacyClassGroupRep := NewRepresentation( "IsConjugacyClassGroupRep",
    IsExternalOrbitByStabilizerRep, [  ] );

IsConjugacyClassPermGroupRep := NewRepresentation
    ( "IsConjugacyClassPermGroupRep", IsConjugacyClassGroupRep, [  ] );

#############################################################################
##
#C  ConjugacyClass( <G>, <g> )  . . . . . . . . . conjugacy class constructor
##
ConjugacyClass := NewOperation( "ConjugacyClass", [ IsGroup, IsObject ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#R  IsRationalClassGroupRep . . . . . . . . . . . . . rational class in group
##
IsRationalClassGroupRep := NewRepresentation( "IsRationalClassGroupRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsExternalSet,
    [ "galoisGroup", "power" ] );

IsRationalClassPermGroupRep := NewRepresentation
    ( "IsRationalClassPermGroupRep", IsRationalClassGroupRep,
    [ "galoisGroup", "power" ] );

#############################################################################
##
#C  RationalClass( <G>, <g> ) . . . . . . . . . .  rational class constructor
##
RationalClass := NewOperation( "RationalClass", [ IsGroup, IsObject ] );
#T 1997/01/16 fceller was old 'NewConstructor'

DecomposedRationalClass := NewOperationArgs( "DecomposedRationalClass" );
PermResidueClass := NewOperationArgs( "PermResidueClass" );
PrimeResidueClassGroup := NewOperationArgs( "PrimeResidueClassGroup" );
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
ConstructList := NewOperationArgs( "ConstructList" );
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
