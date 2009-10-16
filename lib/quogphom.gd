#############################################################################
##
#W  quogphom.gd			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
#H  @(#)$Id: quogphom.gd,v 4.12 2002/04/15 10:05:13 sal Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
Revision.quogphom_gd :=
    "@(#)$Id: quogphom.gd,v 4.12 2002/04/15 10:05:13 sal Exp $";

#############################################################################
##
##  1. Quotient groups by homomorphisms
#1
##  Given a group homomorphism, the cosets of its kernel correspond to
##  elements in the image.  Our hom coset representation
##  stores the homomorphism and the element in the source group.  The
##  image is an attribute which is computed as necessary.  Two cosets
##  are equal if their images are the same.  Where ever practical a coset
##  is identified with its image.  For example, if the homomorphism maps
##  into a permutation group, the cosets are considered to be permutations.
##  Since cosets can be multiplied, we can use them to form
##  a quotient group.  Any computation in this quotient group will be
##  ``shadowed'' in the source group.
##

##  Requires: chain (for CanonicalElt only)
##  Exports: 
##    	Category IsHomCoset with representations IsHomCosetToPerm,
##    	  IsHomCosetToMatrix, IsHomCosetToFp, IsHomCosetToTuple, 
##     	  IsHomCosetToAdditiveElt, IsHomCosetToObject, 
##  	Category IsHomQuotientGroup with special cases:
##     	  IsQuotientToPermGroup, IsQuotientToMatrixGroup, IsQuotientToFpGroup
##   	  IsHomeCosetToTupleGroup, IsQuotientToAdditiveGroup,
##  	  IsQuotientToXXXGroup implies IsXXXGroup in all cases
##     	  EXCEPT that IsQuotientToAdditiveGroup() does not imply IsAdditiveGroup
##  	Operations HomCoset( homomorphism, srcElt ),
##        HomCosetWithImage( hom, srcElt, imgElt ),
##        IsTrivialHomCoset( hcoset ); (imgElt and all srcElt's triv.)
##        SourceElt(hcoset), ImageElt(hcoset), Homomorphism(hcoset),
##        CanonicalElt(hcoset) 
##      Property IsHomCosetOfXXX, where XXX is representation of SourceElt()
##
##  BUG:  This probably doesn't affect much right now, but:
##        a subgroup of a quotient group will have the same associated
##        homomorphism as the original quotient group.  Hence, the
##        Source(hom) for the original quotient group and the subgroup
##        will be the same.  But clearly if the subgroup is considered as
##        the image of the homomorphism, then it should have a
##        smaller Source()
##        Right now, my code in solvable-mat.gi creates SubgroupNC that
##        forms a new homomorphism with new source when it creates a subgroup.
##        Ideally the GAP code for SubgroupNC() and Group() should be patched
##        to include this, and the whole issue should be handled in a general
##        way.
##
##  ISSUE:  Given group of additive matrices, both
##            IsHomCosetToMatrix and IsHomCosetToAdditiveElt will be true.
##

DeclareInfoClass( "InfoQuotientGroup" );


#############################################################################
#############################################################################
##
##  2. Homomorphism Coset Representation
#2
##  We represent cosets of kernels of homomorphisms.  Each coset stores
##  the homomorphism and the element in the source.  The
##  element in the image is an attribute.  These cosets are
##  treated as if they are in the image, eg. if the image is a permutation
##  group, then the cosets are representations of a permutation.
##  Thus the set of cosets will form a quotient group.
##

#############################################################################
##
#C  IsHomCoset(<obj>)
##
##  `IsHomCoset' has one category for each kind of image (and corresponding
##  representations).
##
DeclareCategory( "IsHomCoset", IsRightCoset and IsAssociativeElement and
   IsMultiplicativeElementWithInverse);
DeclareCategoryCollections( "IsHomCoset" );

# this is now implicit in the above declaration
# InstallTrueMethod( IsMultiplicativeElementWithInverse, IsHomCoset );

# this is duplicate anyhow as M.E.W.Inv. implies M.E.W.One
# InstallTrueMethod( IsMultiplicativeElementWithOne, IsHomCoset );

#############################################################################
##
#M  IsAssociativeElement( <hcoset> )
##
InstallTrueMethod( IsAssociativeElement, IsHomCoset );

#############################################################################
##
#A  HomCosetFamily( <hom> )
##
##  for a homomorphism <hom>, this attribute returns a family for the
##  `HomCoset' elements belonging to this homomorphism.
##
DeclareAttribute("HomCosetFamily",IsGroupHomomorphism);

##
##  We have one representation for each type of image
##
##  AH, 27-jan-00: One should not call `CategoryCollections' on
##  representations. In fact what you want here is a separation of
##  representations and categories.

#############################################################################
##
#C  IsHomCosetToPerm(<obj>)
##
DeclareCategory( "IsHomCosetToPerm",IsHomCoset and IsPerm);
DeclareCategoryCollections( "IsHomCosetToPerm" );  

#############################################################################
##
#R  IsHomCosetToPermRep(<obj>)
##
DeclareRepresentation( "IsHomCosetToPermRep",
  IsHomCosetToPerm and IsComponentObjectRep and IsAttributeStoringRep,
    [ "Homomorphism", "SourceElt" ] );

#############################################################################
##
#C  IsHomCosetToMatrix(<obj>)
##
##  gdc - We need `HomCosetToMatrix' to be in same family as `Matrix',
##        so that {\GAP} allows vector $\*$ for `HomCosetToMatrix'
##        and other algorithms that take elements of the `HomCosetToMatrix'.
##        Unfortunately, I don't know how to set the family correctly
##        for compatibility.
##
DeclareCategory( "IsHomCosetToMatrix", IsHomCoset 
  and IsMatrix and IsRingElementTable and IsOrdinaryMatrix);
DeclareCategoryCollections( "IsHomCosetToMatrix" );  

#############################################################################
##
#R  IsHomCosetToMatrixRep(<obj>)
##
DeclareRepresentation( "IsHomCosetToMatrixRep",
  IsHomCosetToMatrix and IsComponentObjectRep and IsAttributeStoringRep,
    [ "Homomorphism", "SourceElt" ] );

#############################################################################
##
#C  IsHomCosetToFp(<obj>)
##
DeclareCategory( "IsHomCosetToFp",IsHomCoset and IsWordWithInverse);
DeclareCategoryCollections( "IsHomCosetToFp" );  

#############################################################################
##
#R  IsHomCosetToFpRep(<obj>)
##
DeclareRepresentation( "IsHomCosetToFpRep",
  IsHomCosetToFp and IsComponentObjectRep and IsAttributeStoringRep,
    [ "Homomorphism", "SourceElt" ] );

#############################################################################
##
#C  IsHomCosetToTuple(<obj>)
##
DeclareCategory( "IsHomCosetToTuple",IsHomCoset and IsTuple);
DeclareCategoryCollections( "IsHomCosetToTuple" );  

#############################################################################
##
#R  IsHomCosetToTupleRep(<obj>)
##
DeclareRepresentation( "IsHomCosetToTupleRep",
  IsHomCosetToTuple and IsComponentObjectRep and IsAttributeStoringRep,
    [ "Homomorphism", "SourceElt" ] );

#############################################################################
##
#C  IsHomCosetToAdditiveElt(<obj>)
##
##  Here the image is an ADDITIVE group of matrices.
##
DeclareCategory( "IsHomCosetToAdditiveElt",IsHomCosetToMatrix);
DeclareCategoryCollections( "IsHomCosetToAdditiveElt" );  

#############################################################################
##
#R  IsHomCosetToAdditiveEltRep(<obj>)
##
DeclareRepresentation( "IsHomCosetToAdditiveEltRep",
  IsHomCosetToAdditiveElt and IsComponentObjectRep and IsAttributeStoringRep,
    [ "Homomorphism", "SourceElt" ] );

##  gdc - We need HomCosetToMatrix to be in same family as Matrix,
##        so that GAP allows vector * HomCosetToMatrix
##        and other algorithms that take elements of the HomCosetToMatrix
##        Unfortunately, I don't know how to set the family correctly
##        for compatibility.

#############################################################################
##
#R  IsHomCosetToObjectRep(<obj>)
##
##  The generic representation.
##
DeclareRepresentation( "IsHomCosetToObjectRep", # catch-all repn
    IsComponentObjectRep and IsAttributeStoringRep and IsHomCoset and IsObject, 
    [ "Homomorphism", "SourceElt" ] );


##
##  We have one property for each kind of source
##

#############################################################################
##
#P  IsHomCosetOfPerm(<obj>)
##
DeclareProperty( "IsHomCosetOfPerm", IsHomCoset );

#############################################################################
##
#P  IsHomCosetOfMatrix(<obj>)
##
DeclareProperty( "IsHomCosetOfMatrix", IsHomCoset );

#############################################################################
##
#P  IsHomCosetOfAdditiveElt(<obj>)
##
DeclareProperty( "IsHomCosetOfAdditiveElt", IsHomCoset );

#############################################################################
##
#P  IsHomCosetOfFp(<obj>)
##
DeclareProperty( "IsHomCosetOfFp", IsHomCoset );

#############################################################################
##
#P  IsHomCosetOfTuple(<obj>)
##
DeclareProperty( "IsHomCosetOfTuple", IsHomCoset );


#############################################################################
#############################################################################
##
##  Quotient groups
##
#############################################################################
#############################################################################

DeclareSynonym( "IsHomQuotientGroup", IsGroup and
    IsHomCosetCollection );
DeclareSynonym( "IsQuotientToPermGroup", IsGroup and
    IsHomCosetToPermCollection );
DeclareSynonym( "IsQuotientToMatrixGroup", IsGroup and
    IsHomCosetToMatrixCollection );
InstallTrueMethod( IsFFEMatrixGroup, IsQuotientToMatrixGroup );

DeclareSynonym( "IsQuotientToTupleGroup", IsGroup and
    IsHomCosetToTupleCollection );
DeclareSynonym( "IsQuotientToFpGroup", IsGroup and
    IsHomCosetToFpCollection );
DeclareSynonym( "IsQuotientToAdditiveGroup", IsGroup and
    IsHomCosetToAdditiveEltCollection );


#############################################################################
#############################################################################
##
##  Creating hom cosets and quotient groups
##
#############################################################################
#############################################################################

#############################################################################
##
#F  HomCoset( <hom>, <elt> )
##
##  Creates a hom coset.  It is better to use one of the `QuotientGroupBy...'
##  functions.
##
DeclareGlobalFunction( "HomCoset", 
    [ IsGroupHomomorphism, IsAssociativeElement ] );

#############################################################################
##
#F  HomCosetWithImage( <hom>, <srcElt>, <imgElt> )
##
##  Creates a hom coset with given homomorphism <hom>, source element <srcElt>
##  and image element <imgElt>. 
##  It is better to use one of the `QuotientGroupBy...'  functions.
##
DeclareGlobalFunction( "HomCosetWithImage",
    [ IsGroupHomomorphism, IsAssociativeElement, IsAssociativeElement ] );

#############################################################################
##
#A  QuotientGroupHom( <hom> )
##
##  The quotient group associated with the homomorphism <hom>.
##  It is better to use one of the `QuotientGroupBy...'  functions.
##
DeclareAttribute( "QuotientGroupHom", IsGroupHomomorphism );

#############################################################################
##
#F  QuotientGroupByHomomorphism( <hom> )
##
##  The quotient group associated with the homomorphism <hom>.
##
DeclareGlobalFunction( "QuotientGroupByHomomorphism", [ IsGroupHomomorphism ] );

#############################################################################
##
#F  QuotientGroupByImages( <srcGroup>, <rangeGroup>, <srcGens>, <imgGens> )
##
##  creates a quotient group from the homomorphism which takes maps 
##  `<srcGens>[<i>]' in <srcGroup> to `<imgGens>[<i>]' in <rangeGroup>.
##
DeclareGlobalFunction( "QuotientGroupByImages", 
		       [ IsGroup, IsGroup, IsList, IsList ] );

#############################################################################
##
#F  QuotientGroupByImagesNC( <srcGroup>, <rangeGroup>, <srcGens>, <imgGens> )
##
##  Same as `QuotientGroupByImages' (see~"QuotientGroupByImages") but without
##  checking that the homomorphism makes sense.
##
DeclareGlobalFunction( "QuotientGroupByImagesNC", 
		       [ IsGroup, IsGroup, IsList, IsList ] );

#############################################################################
##
##  QuotientSubgroupNC( <M>, <gens> )
##
##  Resets the source group in a subgroup of a quotient group.
##  Not yet implemented.
##
##DeclareGlobalFunction( "QuotientSubgroupNC",
##			[IsHomQuotientGroup, IsList] );


#############################################################################
#############################################################################
##
##  Operations on hom cosets
##
#############################################################################
#############################################################################

#############################################################################
##
#F  IsTrivialHomCoset( <hcoset> )
##
##  Is the source element trivial?
##  Sometimes, `IsOne(<hcoset>) => true', in a quotient group, but we can
##  safely discard such a generator only if its <sourceElt> is also trivial.
##
DeclareGlobalFunction( "IsTrivialHomCoset", [ IsHomCoset ] );

#############################################################################
##
#O  Homomorphism( <hcoset> )
#O  Homomorphism( <Q> )
##
##  The homomorphism of a hom coset <hcoset>, respectively a hom quotient 
##  group <Q>.
##
DeclareOperation( "Homomorphism", [ IsHomCoset ] );
DeclareOperation( "Homomorphism", [ IsHomQuotientGroup ] );

#############################################################################
##
#O  SourceElt( <hcoset> )
##
##  The source element of a hom coset <hcoset>.
##
DeclareOperation( "SourceElt", [ IsHomCoset ] );

#############################################################################
##
#A  ImageElt( <hcoset> )
##
##  The image element of a hom coset <hcoset>.
##
DeclareAttribute( "ImageElt" , IsHomCoset );

#############################################################################
##
#A  CanonicalElt( <hcoset> )
##
##  A canonical element of a hom coset <hcoset>.  Note that SourceElt may be
##  different for non-identical equal cosets.  `CanonicalElt' gives the same 
##  element for different representation of a coset.  This will compute a chain
##  for the range group if one does not already exist.
##
DeclareAttribute( "CanonicalElt", IsHomCoset );

#############################################################################
##
#A  Source( <Q> )
##
##  Source group of a hom quotient group <Q>.
##
DeclareAttribute( "Source", IsHomQuotientGroup );

#############################################################################
##
#A  Range( <Q> )
##
##  Range group of a hom quotient group <Q>.
##
DeclareAttribute( "Range", IsHomQuotientGroup );

#############################################################################
##
#A  ImagesSource( <Q> )
##
##  Image group of a hom quotient group <Q>.
##
DeclareAttribute( "ImagesSource", IsHomQuotientGroup );

#############################################################################
##
#A  Length( <hcoset> )
##
##  Length of a word <hcoset>.
##
DeclareAttribute( "Length", IsWord and IsHomCosetToFp );

#############################################################################
##
#O  POW( <obj>, <hcoset> )
##
##  Image of vector.
##
DeclareOperation( "POW", [ IsVector, IsHomCosetToMatrix ]);

#############################################################################
##
#E  quogphom.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
