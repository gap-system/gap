#############################################################################
##
#W  stbc.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.22  1997/02/26 14:00:33  htheisse
#H  changed algorithm for stab chain with base in solvable groups
#H
#H  Revision 4.21  1997/01/16 10:46:51  fceller
#H  renamed 'NewConstructor' to 'NewOperation',
#H  renamed 'NewOperationFlags1' to 'NewConstructor'
#H
#H  Revision 4.20  1997/01/07 13:35:14  ahulpke
#H  Added the transitive groups data library
#H
#H  Revision 4.19  1997/01/06 16:44:26  ahulpke
#H  Added 'AlternatingGroup'
#H
#H  Revision 4.18  1997/01/06 16:21:03  htheisse
#H  turned `IsSymmetricGroup' from a representation into a property
#H
#H  Revision 4.17  1996/12/19 09:59:15  htheisse
#H  added revision lines
#H
##
Revision.stbc_gd :=
    "@(#)$Id$";

LargestMovedPoint := NewAttribute( "LargestMovedPoint", IsPermGroup );
SetLargestMovedPoint := Setter( LargestMovedPoint );
HasLargestMovedPoint := Tester( LargestMovedPoint );

SmallestMovedPoint := NewAttribute( "SmallestMovedPoint", IsPermGroup );
SetSmallestMovedPoint := Setter( SmallestMovedPoint );
HasSmallestMovedPoint := Tester( SmallestMovedPoint );

MovedPoints := NewAttribute( "MovedPoints", IsPermGroup );
SetMovedPoints := Setter( MovedPoints );
HasMovedPoints := Tester( MovedPoints );

NrMovedPoints := NewAttribute( "NrMovedPoints", IsPermGroup );
SetNrMovedPoints := Setter( NrMovedPoints );
HasNrMovedPoints := Tester( NrMovedPoints );

StrongGenerators := NewAttribute( "StrongGenerators", IsPermGroup );
SetStrongGenerators := Setter( StrongGenerators );
HasStrongGenerators := Tester( StrongGenerators );

Base := NewAttribute( "Base", IsPermGroup );
SetBase := Setter( Base );
HasBase := Tester( Base );

Socle := NewAttribute( "Socle", IsGroup );
SetSocle := Setter( Socle );
HasSocle := Tester( Socle );

#############################################################################
##
#F  StabChain( <G> [, <options ] )  . . . .  stabilizer chain of a perm group
##
##  `StabChainOp' is an operation with  two arguments ( <group>, <record>  ).
##  `StabChainAttr' is an attribute for groups  or homomorphisms. Its default
##  method  for  groups is to  call  `StabChainOp'  with  empty record.  Both
##  operations return *mutable* results.
##
##  `StabChainImmAttr' is    an attribute   with  *immutable*  values,  which
##  dispatches to `StabChainAttr'. `StabChain' is a  function which takes one
##  or  two arguments  and dispatches  to  `StabChainImmAttr' or  `Immutable(
##  StabChainOp( ... ) )', hence it also returns an *immutable* result.
##
StabChain := NewOperationArgs( "StabChain" );
StabChainOp := NewOperation( "StabChain (op)", [ IsGroup, IsRecord ] );
StabChainAttr := NewAttribute( "StabChain (attr)", IsObject, "mutable" );
StabChainImmAttr := NewAttribute( "StabChain (imm attr)", IsObject );
SetStabChain := Setter( StabChainAttr );
HasStabChain := Tester( StabChainAttr );

StabChainOptions := NewAttribute( "StabChainOptions",
    IsPermGroup, "mutable" );
SetStabChainOptions := Setter( StabChainOptions );
HasStabChainOptions := Tester( StabChainOptions );

MinimalStabChain:=NewAttribute("MinimalStabChain",IsPermGroup);
SetMinimalStabChain:=Setter(MinimalStabChain);
HasMinimalStabChain:=Tester(MinimalStabChain);

MembershipTestKnownBase := NewOperation( "MembershipTestKnownBase",
                                   [ IsRecord, IsList, IsList ] );

IsPermOnEnumerator := NewCategory( "IsPermOnEnumerator",
    IsMultiplicativeElementWithInverse and IsPerm );

PermOnEnumerator := NewOperation( "PermOnEnumerator",
    [ IsEnumerator, IsObject ] );

DefaultStabChainOptions := NewOperationArgs( "DefaultStabChainOptions" );
CopyOptionsDefaults := NewOperationArgs( "CopyOptionsDefaults" );
StabChainBaseStrongGenerators := NewOperationArgs( "StabChainBaseStrongGenerators" );
GroupStabChain := NewOperationArgs( "GroupStabChain" );
DepthSchreierTrees := NewOperationArgs( "DepthSchreierTrees" );
AddGeneratorsExtendSchreierTree := NewOperationArgs( "AddGeneratorsExtendSchreierTree" );
StabChainStrong := NewOperationArgs( "StabChainStrong" );
StabChainForcePoint := NewOperationArgs( "StabChainForcePoint" );
StabChainSwap := NewOperationArgs( "StabChainSwap" );
InsertElmList := NewOperationArgs( "InsertElmList" );
RemoveElmList := NewOperationArgs( "RemoveElmList" );
LabsLims := NewOperationArgs( "LabsLims" );
ConjugateStabChain := NewOperationArgs( "ConjugateStabChain" );
ChangeStabChain := NewOperationArgs( "ChangeStabChain" );
ExtendStabChain := NewOperationArgs( "ExtendStabChain" );
ReduceStabChain := NewOperationArgs( "ReduceStabChain" );
EmptyStabChain := NewOperationArgs( "EmptyStabChain" );
InitializeSchreierTree := NewOperationArgs( "InitializeSchreierTree" );
InsertTrivialStabilizer := NewOperationArgs( "InsertTrivialStabilizer" );
RemoveStabChain := NewOperationArgs( "RemoveStabChain" );
BasePoint := NewOperationArgs( "BasePoint" );
IsInBasicOrbit := NewOperationArgs( "IsInBasicOrbit" );
IsFixedStabilizer := NewOperationArgs( "IsFixedStabilizer" );
InverseRepresentative := NewOperationArgs( "InverseRepresentative" );
QuickInverseRepresentative := NewOperationArgs( "QuickInverseRepresentative" );
InverseRepresentativeWord := NewOperationArgs( "InverseRepresentativeWord" );
SiftedPermutation := NewOperationArgs( "SiftedPermutation" );
MinimalElementCosetStabChain := NewOperationArgs( "MinimalElementCosetStabChain" );
BaseStabChain := NewOperationArgs( "BaseStabChain" );
SizeStabChain := NewOperationArgs( "SizeStabChain" );
StrongGeneratorsStabChain := NewOperationArgs( "StrongGeneratorsStabChain" );
IndicesStabChain := NewOperationArgs( "IndicesStabChain" );
ListStabChain := NewOperationArgs( "ListStabChain" );
OrbitStabChain := NewOperationArgs( "OrbitStabChain" );
StabChainRandomPermGroup := NewOperationArgs( "StabChainRandomPermGroup" );
SiftAsWord := NewOperationArgs( "SiftAsWord" );
CosetRepAsWord := NewOperationArgs( "CosetRepAsWord" );
ImageInWord := NewOperationArgs( "ImageInWord" );
InverseAsWord := NewOperationArgs( "InverseAsWord" );
RandomElmAsWord := NewOperationArgs( "RandomElmAsWord" );
SCRMakeStabStrong := NewOperationArgs( "SCRMakeStabStrong" );
SCRStrongGenTest := NewOperationArgs( "SCRStrongGenTest" );
SCRSift := NewOperationArgs( "SCRSift" );
SCRStrongGenTest2 := NewOperationArgs( "SCRStrongGenTest2" );
SCRNotice := NewOperationArgs( "SCRNotice" );
SCRExtend := NewOperationArgs( "SCRExtend" );
SCRSchTree := NewOperationArgs( "SCRSchTree" );
SCRRandomPerm := NewOperationArgs( "SCRRandomPerm" );
SCRRandomString := NewOperationArgs( "SCRRandomString" );
SCRRandomSubproduct := NewOperationArgs( "SCRRandomSubproduct" );
SCRExtendRecord := NewOperationArgs( "SCRExtendRecord" );
SCRRestoredRecord := NewOperationArgs( "SCRRestoredRecord" );
VerifyStabilizer := NewOperationArgs( "VerifyStabilizer" );
VerifySGS := NewOperationArgs( "VerifySGS" );
ExtensionOnBlocks := NewOperationArgs( "ExtensionOnBlocks" );
ClosureRandomPermGroup := NewOperationArgs( "ClosureRandomPermGroup" );

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  12345678.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
