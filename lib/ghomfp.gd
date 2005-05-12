#############################################################################
##
#W  ghomfp.gd                   GAP library                  Alexander Hulpke
##
#Y  (C) 2000 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
Revision.ghomfp_gd :=
    "@(#)$Id$";

############################################################################
##
#R  IsFromFpGroupGeneralMapping(<map>)
#R  IsFromFpGroupHomomorphism(<map>)
##
##  is the representation of mappings from an fp group.
DeclareCategory( "IsFromFpGroupGeneralMapping", IsGroupGeneralMapping
  # we want all methods for homs from fp groups to be better. This (slight
  # hack) increases the rank of the category of such mappings.
  and NewFilter("Extrarankfilter",10));
DeclareSynonym("IsFromFpGroupHomomorphism",
  IsFromFpGroupGeneralMapping and IsMapping);

############################################################################
##
#R  IsFromFpGroupGeneralMappingByImages(<map>)
#R  IsFromFpGroupHomomorphismByImages(<map>)
##
##  is the representation of mappings from an fp group.
DeclareRepresentation( "IsFromFpGroupGeneralMappingByImages",
      IsFromFpGroupGeneralMapping and IsGroupGeneralMappingByImages, 
      [ "generators", "genimages" ] );
DeclareSynonym("IsFromFpGroupHomomorphismByImages",
  IsFromFpGroupGeneralMappingByImages and IsMapping);

############################################################################
##
#R  IsFromFpGroupStdGensGeneralMappingByImages(<map>)
#R  IsFromFpGroupStdGensHomomorphismByImages(<map>)
##
##  is the representation of mappings from an fp group that give images of
##  the standard generators.
DeclareRepresentation( "IsFromFpGroupStdGensGeneralMappingByImages",
      IsFromFpGroupGeneralMappingByImages, [ "generators", "genimages" ] );
DeclareSynonym("IsFromFpGroupStdGensHomomorphismByImages",
  IsFromFpGroupStdGensGeneralMappingByImages and IsMapping);


############################################################################
##
#R  IsToFpGroupGeneralMappingByImages(<map>)
#R  IsToFpGroupHomomorphismByImages(<map>)
##
DeclareRepresentation( "IsToFpGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
DeclareSynonym("IsToFpGroupHomomorphismByImages",
  IsToFpGroupGeneralMappingByImages and IsMapping);

#############################################################################
##
#A  CosetTableFpHom(<hom>) 
##
##  returns an augmented coset table for an homomorphism from an fp group,
##  corresponding to the !.generators component. The component
##  `.secondaryImages' of this table will give the images of all (primary
##  and secondary) subgroup generators under <hom>.
##
##  As we might want to add further entries to the table, its a mutable
##  attribute.
DeclareAttribute("CosetTableFpHom",IsGeneralMapping,"mutable");

#############################################################################
##
#F  SecondaryImagesAugmentedCosetTable(<aug>,<gens>,<genimages>) 
##
##  returns a list of images of the secondary generators, based on the
##  components `homgens' and `homgenims' in the augmented coset table <aug>.
DeclareGlobalFunction("SecondaryImagesAugmentedCosetTable");

#############################################################################
##
#F  TrySecondaryImages(<aug>) 
##
##  sets a component `secondaryImages' in the augmented coset table (seeded
##  to a ShallowCopy of the primary images) if having all these images
##  wcannot become too memory extensive. (Call this function for augmented
##  coset tables for homomorphisms once -- the other functions make use of
##  the `secondaryImages' component if existing.)
DeclareGlobalFunction("TrySecondaryImages");

#############################################################################
##
#F  KuKGenerators(<G>,<beta>,<alpha>) 
##
##  \atindex{Krasner-Kaloujnine theorem}{@Krasner-Kaloujnine theorem}
##  \index{Wreath product embedding}
##  If <beta> is a homomorphism from <G> in a transitive permutation group,
##  <U> the full preimage of the point stabilizer and
##  and <alpha> a homomorphism defined on (a superset) of <U>, this function
##  returns images of the generators of <G> when mapping to the wreath
##  product $(<U>alpha)\wr(<G>beta)$. (This is the Krasner-Kaloujnine
##  embedding theorem.)
DeclareGlobalFunction("KuKGenerators");

#############################################################################
##
#A  IsomorphismSimplifiedFpGroup( <G> )
##
##  applies Tietze transformations to a copy of the presentation of the
##  given finitely presented group <G> in order to reduce it with respect to
##  the number of generators, the number of relators, and the relator
##  lengths.
##
##  The operation returns an isomorphism with source <G>, range a group
##  <H> isomorphic to <G>, so that the presentation of <H> has been
##  simplified using Tietze transformations.
##
DeclareAttribute("IsomorphismSimplifiedFpGroup",IsSubgroupFpGroup);


#############################################################################
##
#E
##
