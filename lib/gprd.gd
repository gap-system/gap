#############################################################################
##
#W  gprd.gd                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.gprd_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  DirectProduct( <G>{, <H>} )
#O  DirectProductOp( <list>, <expl> )
##
##  These functions construct the direct product of the groups given as
##  arguments.
##  `DirectProduct' takes an arbitrary positive number of arguments
##  and calls the operation `DirectProductOp', which takes exactly two
##  arguments, namely a nonempty list of groups and one of these groups.
##  (This somewhat strange syntax allows the method selection to choose
##  a reasonable method for special cases, e.g., if all groups are
##  permutation groups or pc groups.)
##
DeclareGlobalFunction( "DirectProduct" );
DeclareOperation( "DirectProductOp", [ IsList, IsGroup ] );


#############################################################################
##
#O  SubdirectProduct(<G> ,<H>, <Ghom>, <Hhom> )
##
##  constructs the subdirect product of <G> and <H> with respect to the
##  epimorphisms <Ghom> from <G> onto a group <A> and <Hhom> from <H> onto
##  the same group <A>.
DeclareGlobalFunction("SubdirectProduct");
DeclareOperation( "SubdirectProductOp",
    [ IsGroup, IsGroup, IsGroupHomomorphism, IsGroupHomomorphism ] );

#############################################################################
##
#O  SemidirectProduct(<G>, <alpha>, <N> )
#O  SemidirectProduct(<autgp>, <N> )
##
##  constructs the semidirect product of <N> with <G> acting via <alpha>.
##  <alpha> must be a homomorphism from <G> into a group of automorphisms of
##  <N>.
##
##  If <N> is a group, <alpha> must be a homomorphism from <G> into a group
##  of automorphisms of <N>.
##
##  If <N> is a full row space over a field <F>, <alpha> must be a
##  homomorphism from <G> into a matrix group of the right dimension over a
##  subfield of <F>, or into a permutation group (in this case permutation
##  matrices are taken).
##
##  In the second variant, <autgp> must be a group of automorphism of <N>,
##  it is a shorthand for
##  `SemidirectProduct(<autgp>,IdentityMapping(<autgp>),<N>)'.
DeclareOperation( "SemidirectProduct",
    [ IsGroup, IsGroupHomomorphism, IsObject ] );


#############################################################################
##
#O  WreathProduct(<G>, <P> )
#O  WreathProduct(<G>, <H> [,<hom>] )
##
##  constructs the wreath product of the group <G> with the permutation
##  group <P> (acting on its `MovedPoints').
##
##  The second usage constructs the
##  wreath product of the group <G> with the image of the group <H> under
##  <hom> where <hom> must be a homomorphism from <H> into a permutation
##  group. (If <hom> is not given, and <P> is not a permutation group the
##  result of `IsomorphismPermGroup(P)'  -- whose degree may be dependent on
##  the method and thus is not well-defined! -- is taken for <hom>).
DeclareOperation( "WreathProduct", [ IsObject, IsObject ] );

#############################################################################
##
#F  WreathProductImprimitiveAction(<G>, <H> )
##
##  for two permutation groups <G> and <H> this function constructs the
##  wreath product of <G> and <H> in the imprimitive action. If <G> acts on
##  $l$ points and <H> on $m$ points this action will be on $l\cdot m$
##  points, it will be imprimitive with $m$ blocks of size $l$ each.
##
##  The operations `Embedding' and `Projection' operate on this product as
##  described for general wreath products.
DeclareGlobalFunction( "WreathProductImprimitiveAction" );

#############################################################################
##
#F  WreathProductProductAction(<G>, <H> )
##
##  for two permutation groups <G> and <H> this function constructs the
##  wreath product in product action.  If <G> acts on $l$ points and <H> on
##  $m$ points this action will be on $l^m$ points.
##
##  The operations `Embedding' and `Projection' operate on this product as
##  described for general wreath products.
DeclareGlobalFunction( "WreathProductProductAction" );

DeclareGlobalFunction( "InnerSubdirectProducts" );
DeclareGlobalFunction( "InnerSubdirectProducts2" );
DeclareGlobalFunction( "SubdirectProducts" );

#############################################################################
##
#A  DirectProductInfo( <G> )
##
DeclareAttribute( "DirectProductInfo", IsGroup, "mutable" );

#############################################################################
##
#A  SubdirectProductInfo( <G> )
##
DeclareAttribute( "SubdirectProductInfo", IsGroup, "mutable" );

#############################################################################
##
#A  SemidirectProductInfo( <G> )
##
DeclareAttribute( "SemidirectProductInfo", IsGroup, "mutable" );

#############################################################################
##
#A  WreathProductInfo( <G> )
##
DeclareAttribute( "WreathProductInfo", IsGroup, "mutable" );

#############################################################################
##
#F  SubdirProdPcGroups( <G>,<gi>,<H>,<hi> )
##
##  Let <G> and <H> be two pc groups which are both projections of a
##  subdirect product with generator images <gi> and <hi>. the function
##  returns a list <l> with <l>[1] a new pc group and <l>[2] a corresponding
##  generator images list.
##
##  No parameter checking is done.
##  (This function is used in a variant of the SQ.)
DeclareGlobalFunction( "SubdirProdPcGroups" );

#############################################################################
##
#C  IsWreathProductElement
#C  IsWreathProductElementCollection
##
##  categories for elements of generic wreath products: elements are stored
##  as list of base components and permutation.
DeclareCategory("IsWreathProductElement",
  IsMultiplicativeElementWithInverse and IsAssociativeElement);
DeclareCategoryCollections("IsWreathProductElement");

InstallTrueMethod(IsGeneratorsOfMagmaWithInverses,
  IsWreathProductElementCollection);

DeclareRepresentation("IsWreathProductElementDefaultRep",
  IsWreathProductElement and IsPositionalObjectRep,[]);


#############################################################################
##
#E

