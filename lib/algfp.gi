#############################################################################
##
#W  algfp.gi                   GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for finitely presented algebras.
##  So far, there are not many.
##
Revision.algfp_gi :=
    "@(#)$Id$";

IsPackedAlgebraElmDefaultRep := NewRepresentation(
    "IsPackedAlgebraElmDefaultRep",
    IsPositionalObjectRep and IsRingElement, [ 1 ] );

InstallMethod(ElementOfFpAlgebra,
  "for family of fp. alg. elements and ring element",true,
  [IsFamilyOfFpAlgebraElements,IsRingElement],0,
function(fam,elm)
    return Objectify( fam!.defaultKind, [ Immutable( elm ) ] );
end );


#############################################################################
##
#M  FactorFreeAlgebraByRelators(<F>,<rels>) . . .  factor of free algebra
##
FactorFreeAlgebraByRelators := function( F, rels )
local A, fam,gens;

    # Create a new family.
    fam := NewFamily( "FamilyElementsFpAlgebra", IsElementOfFpAlgebra );

    # Create the default kind for the elements.
    fam!.defaultKind := NewKind( fam, IsPackedAlgebraElmDefaultRep );

    fam!.freeAlgebra := F;
    fam!.relators := Immutable( rels );
    fam!.familyRing := FamilyObj(LeftActingDomain(F));

    # Create the algebra.
    A := Objectify(
        NewKind( CollectionsFamily( fam ),
            IsSubalgebraFpAlgebra and IsWholeFamily and IsAttributeStoringRep ),
        rec() );

    SetLeftActingDomain(A,LeftActingDomain(F));
    gens:=List(GeneratorsOfAlgebra(F),i->ElementOfFpAlgebra(fam,i));
    SetZero(A,ElementOfFpAlgebra(fam,Zero(F)));
    SetGeneratorsOfAlgebra(A,gens);
    UseFactorRelation(F,rels,A);
    return A;
end;


#############################################################################
##
#M  \/( <F>, <rels> )  . . . . . . . for free algebra and list of relators
##
InstallOtherMethod( \/,
    "method for free algebra and relators",
    IsIdentical, [ IsFreeMagmaRing, IsCollection ], 0,
    FactorFreeAlgebraByRelators );

InstallOtherMethod( \/,
    "method for free algebra and empty list",
    IsIdentical, [ IsFreeMagmaRing, IsEmpty ], 0,
    FactorFreeAlgebraByRelators );

#############################################################################
##
#M  Print(<fp alg elm>)
##
InstallMethod(PrintObj,"fp algebra elements",true,
  [IsPackedAlgebraElmDefaultRep],0,
function(e)
  Print("[",e![1],"]");
end);


#############################################################################
##
#M  \+(<fp alg elm>,<fp alg elm>)
##
InstallMethod(\+,"fp algebra elements",IsIdentical,
  [IsPackedAlgebraElmDefaultRep,IsPackedAlgebraElmDefaultRep],0,
function(a,b)
  return ElementOfFpAlgebra(FamilyObj(a),a![1]+b![1]);
end);

#############################################################################
##
#M  \-(<fp alg elm>,<fp alg elm>)
##
InstallMethod(\-,"fp algebra elements",IsIdentical,
  [IsPackedAlgebraElmDefaultRep,IsPackedAlgebraElmDefaultRep],0,
function(a,b)
  return ElementOfFpAlgebra(FamilyObj(a),a![1]-b![1]);
end);

#############################################################################
##
#M  AdditiveInverse(<fp alg elm>)
##
InstallMethod(AdditiveInverse,"fp algebra elements",true,
  [IsPackedAlgebraElmDefaultRep],0,
function(a)
  return ElementOfFpAlgebra(FamilyObj(a),AdditiveInverse(a![1]));
end);

#############################################################################
##
#M  \*(<fp alg elm>,<fp alg elm>)
##
InstallMethod(\*,"fp algebra elements",IsIdentical,
  [IsPackedAlgebraElmDefaultRep,IsPackedAlgebraElmDefaultRep],0,
function(a,b)
  return ElementOfFpAlgebra(FamilyObj(a),a![1]*b![1]);
end);

#############################################################################
##
#M  \*(<ring el>,<fp alg elm>)
##
InstallMethod(\*,"ring el *fp algebra el",IsRingsMagmaRings,
  [IsRingElement,IsPackedAlgebraElmDefaultRep],0,
function(a,b)
  return ElementOfFpAlgebra(FamilyObj(b),a*b![1]);
end);

#############################################################################
##
#M  \*(<fp alg elm>,<ring el>)
##
InstallMethod(\*,"fp algebra el*ring el",IsMagmaRingsRings,
  [IsPackedAlgebraElmDefaultRep,IsRingElement],0,
function(a,b)
  return ElementOfFpAlgebra(FamilyObj(a),a![1]*b);
end);

#AH  Embedding can only be defined reasonably if a 'One' is present
#AH  (The factor may collaps).

#############################################################################
##
#E  algfp.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

