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

#############################################################################
##
#M  ElementOfFpAlgebra( <Fam>, <elm> )  . . . .  for family of f.p. alg.elms.
##
InstallMethod(ElementOfFpAlgebra,
  "for family of fp. alg. elements and ring element",true,
  [IsFamilyOfFpAlgebraElements,IsRingElement],0,
function(fam,elm)
    return Objectify( fam!.defaultKind, [ Immutable( elm ) ] );
end );


#############################################################################
##
#M  ElementOfFpAlgebra( <Fam>, <elm> )  . .  for family with nice normal form
##
InstallMethod( ElementOfFpAlgebra,
    "method for fp. alg. elms. family with normal form, and ring element",
    true,
    [ IsFamilyOfFpAlgebraElements and HasNiceNormalFormByExtRepFunction,
      IsRingElement ], 0,
    function( Fam, elm )
    return NiceNormalFormByExtRepFunction( Fam )( Fam, ExtRepOfObj( elm ) );
    end );


#############################################################################
##
#M  ExtRepOfObj( <elm> )  . . . . . . . . . . . . .  for f.p. algebra element
##
##  The external representation of elements in an f.p. algebra is defined as
##  a list of length 2, the first entry being the zero coefficient,
##  the second being a zipped list containing the external representations
##  of the monomials and their coefficients.
##
InstallMethod( ExtRepOfObj,
    "method for f.p. algebra element",
    true,
    [ IsElementOfFpAlgebra and IsPackedAlgebraElmDefaultRep ], 0,
    elm -> ExtRepOfObj( elm![1] ) );


#############################################################################
##
#M  ObjByExtRep( <Fam>, <descr> ) . for f.p. alg. elms. fam. with normal form
##
InstallMethod( ObjByExtRep,
    "method for family of f.p. algebra elements with normal form",
    true,
    [ IsFamilyOfFpAlgebraElements and HasNiceNormalFormByExtRepFunction,
      IsList ], 0,
    function( Fam, descr )
    return NiceNormalFormByExtRepFunction( Fam )( Fam, descr );
    end );


#############################################################################
##
#M  \=( <x>, <y> )  . . . . . . . .  for two normalized f.p. algebra elements
##
InstallMethod( \=,
    "method for two normalized f.p. algebra elements",
    IsIdentical,
    [ IsElementOfFpAlgebra and IsNormalForm,
      IsElementOfFpAlgebra and IsNormalForm ], 0,
    function( x, y )
    return ExtRepOfObj( x ) = ExtRepOfObj( y );
    end );

#T missing: \<, \= method to look for normal form in the family


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
    SetZero( fam, ElementOfFpAlgebra( fam, Zero( F ) ) );
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
#M  Zero( <fp alg elm>)
##
InstallMethod( Zero,
    "method for an f.p. algebra element",
    true,
    [ IsElementOfFpAlgebra and IsPackedAlgebraElmDefaultRep ], 0,
    elm -> ElementOfFpAlgebra( FamilyObj( elm ), Zero( elm![1] ) ) );


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

