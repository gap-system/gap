#############################################################################
##
#W  basicim.gd			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
#H  @(#)$Id: basicim.gd,v 4.3 2002/07/09 09:53:59 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  Allows elements of a group with stabiliser chain to be represented as
##  a word in the strong generators and a basic image.  This allows for
##  more efficient computation in small base groups, provided the words
##  do not get too long.
##
##  Requires: chain
##  Exports: BasicImageGroups
##
Revision.basicim_gd :=
    "@(#)$Id: basicim.gd,v 4.3 2002/07/09 09:53:59 gap Exp $";

#############################################################################
#############################################################################
##
##  Basic image group representation
##
#############################################################################
#############################################################################

DeclareInfoClass( "InfoBasicImage" );

#############################################################################
##
#R  IsBasicImageEltRep
##
##  Representation of an element in terms of a word and base image.
##  We also store pointers to the base and orbit generators.
##  For an orbit generator orb, Image( HomFromFree, orb ) is the 
##  corresponding word of length one.
##
DeclareRepresentation( "IsBasicImageEltRep",
    IsAssociativeElement, 
    [ "Word", "Base", "BaseImage", "OrbitGenerators", "HomFromFree" ] );
DeclareCategoryCollections( "IsBasicImageEltRep" );  
BasicImageEltRepFamily := NewFamily( "BasicImageEltRep", IsBasicImageEltRep );

DeclareSynonym( "IsBasicImageGroup", IsGroup and
    IsBasicImageEltRepCollection );

#############################################################################
##
#F  ConvertToSiftGroup( <G>, <orbitGens>, <homFromFree> )
##
##  The sift group is used to compute elements as words in the orbit
##  generators by shadowed sifting.
##
DeclareGlobalFunction( "ConvertToSiftGroup", 
    [ IsGroup, IsList, IsGroupHomomorphism ] );

#############################################################################
##
#F  BasicImageGroup( <G> )
##
##  Return the basic image representation of the group <G>.
##
DeclareGlobalFunction( "BasicImageGroup", [ IsGroup and HasChainSubgroup ] );

#############################################################################
##
#O  BasicImageGroupElement( <ord>, <base>, <baseImage>, <orbitGenerators>, 
#M	<homFromFree> )
##
##  Construct a basic image group element.
##
DeclareOperation( "BasicImageGroupElement", 
			[ IsWord, IsList, IsList, IsList, IsGroupHomomorphism ] );
#############################################################################
##
#O  BasicImageGroupElement( <G>, <g> )
##
##  Strip <g> and convert it to a basic image group element.
##
DeclareOperation( "BasicImageGroupElement", 
			[ IsBasicImageGroup, IsAssociativeElement ] );
#############################################################################
##
#O  BasicImageGroupElement( <> )
##
##  Construct a basic image group element.
##
DeclareOperation( "BasicImageGroupElement", 
			[ IsGroup and HasChainSubgroup, IsGroupHomomorphism, IsList, IsAssociativeElement ] );


#############################################################################
#############################################################################
##
##  Attributes of basic image groups
##
##  These attributes are set by the function BasicImageGroup.
##  They cannot be computed, so there is no methods for them.
##
#############################################################################
#############################################################################

#############################################################################
##
#A  OrbitGeneratorsOfGroup( <G> )
##
DeclareAttribute( "OrbitGeneratorsOfGroup", IsBasicImageGroup );
#############################################################################
##
#A  BaseOfBasicImageGroup( <G> )
##
DeclareAttribute( "BaseOfBasicImageGroup", IsBasicImageGroup );
#############################################################################
##
#A  FreeGroupOfBasicImageGroup( <G> )
##
DeclareAttribute( "FreeGroupOfBasicImageGroup", IsBasicImageGroup );
#############################################################################
##
#A  SiftGroup( <G> )
##
DeclareAttribute( "SiftGroup", IsBasicImageGroup );
#############################################################################
##
#A  HomFromFreeOfBasicImageGroup( <G> )
##
DeclareAttribute( "HomFromFreeOfBasicImageGroup", IsBasicImageGroup );
#############################################################################
##
#A  FreeGroupOfBasicImageGroup( <G> )
##
DeclareAttribute( "FreeGroupOfBasicImageGroup", IsBasicImageGroup );


#############################################################################
#############################################################################
##
##  Properties of basic image elements
##
#############################################################################
#############################################################################

#############################################################################
##
#O  Word( <elt> )
##
##  The word in the strong generators.
##
DeclareOperation( "Word", [ IsBasicImageEltRep ] );
#############################################################################
##
#O  BaseOfElt( <elt> )
##
DeclareOperation( "BaseOfElt", [ IsBasicImageEltRep ] );
#############################################################################
##
#O  BaseImage( <elt> )
##
DeclareOperation( "BaseImage", [ IsBasicImageEltRep ] );
#############################################################################
##
#O  OrbitGenerators( <elt> )
##
DeclareOperation( "OrbitGenerators", [ IsBasicImageEltRep ] );
#############################################################################
##
#O  HomFromFree( <elt> )
##
DeclareOperation( "HomFromFree", [ IsBasicImageEltRep ] );
#############################################################################
##
#O  FreeGroupOfElt( <elt> )
##
DeclareOperation( "FreeGroupOfElt", [ IsBasicImageEltRep ] );


#############################################################################
#############################################################################
##
##  Conversion to ordinary element
##
#############################################################################
#############################################################################

#############################################################################
##
#A  ConvertBasicImageGroupElement( <sb> )
##
##  Converts a basic image group element to an ordinary element.
##
DeclareAttribute( "ConvertBasicImageGroupElement", IsBasicImageEltRep );


#############################################################################
#############################################################################
##
##  Basic operations
##
#############################################################################
#############################################################################

#############################################################################
##
#O  ONE( <elt> )
##
DeclareOperation( "ONE", [ IsBasicImageEltRep ] );
#############################################################################
##
#A  One( <elt> )
##
DeclareAttribute( "One", IsBasicImageEltRep );
#############################################################################
##
#O  INV( <elt> )
##
DeclareOperation( "INV", [ IsBasicImageEltRep ] );
#############################################################################
##
#A  Inverse( <elt> )
##
DeclareAttribute( "Inverse", IsBasicImageEltRep );
#############################################################################
##
#O  QUO( <elt1>, <elt2> )
##
DeclareOperation( "QUO", [ IsBasicImageEltRep, IsBasicImageEltRep ] );
##DeclareOperation( "POW", [ IsBasicImageEltRep ] );
#############################################################################
##
#O  COMM( <elt1>, <elt2> )
##
DeclareOperation( "COMM", [ IsBasicImageEltRep, IsBasicImageEltRep ] );

#############################################################################
#############################################################################
##
##  Computing presentations
##
##  Basic images can be used to compute a presentation for the group <G>.
##
#############################################################################
#############################################################################

#############################################################################
##
#A  Presentation( <G> )
##
##  Computes a presentation for the group <G>.
##
DeclareAttribute( "Presentation", IsGroup );

#E
