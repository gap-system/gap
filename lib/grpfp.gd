#############################################################################
##
#W  grpfp.gd                    GAP library                    Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for finitely presented groups
##  (fp groups).
##
Revision.grpfp_gd :=
    "@(#)$Id$";


#############################################################################
##
#V  CosetTableDefaultLimit
##
##  This is the default number of cosets with which a coset tables is
##  initialized.
CosetTableDefaultLimit := 1000;


#############################################################################
##
#V  CosetTableDefaultMaxLimit
##
##  This is the default limit for the number of cosets in a coset
##  enumeration. If this number of cosets is reached, {\GAP} will issue an
##  error message and prompt the user to either continue the calculation or
##  to stop it. the default value is 64000.
CosetTableDefaultMaxLimit := 64000;


#############################################################################
##
#V  InfoFpGroup
##
DeclareInfoClass( "InfoFpGroup" );


#############################################################################
##
#C  IsSubgroupFpGroup
##
DeclareCategory( "IsSubgroupFpGroup", IsGroup );


#############################################################################
##
#C  IsElementOfFpGroup
##
DeclareCategory( "IsElementOfFpGroup",
    IsMultiplicativeElementWithInverse and IsAssociativeElement );

#############################################################################
##
#F  IsFpGroup(<G>)
##
##  is a synonym for `IsSubgroupFpGroup and IsGroupOfFamily'.
DeclareSynonym( "IsFpGroup", IsSubgroupFpGroup and IsGroupOfFamily );

#############################################################################
##
#C  IsElementOfFpGroupCollection
##
DeclareCategoryCollections( "IsElementOfFpGroup" );


#############################################################################
##
#M  IsSubgroupFpGroup
##
InstallTrueMethod( IsSubgroupFpGroup,
    IsGroup and IsElementOfFpGroupCollection );


#############################################################################
##
#C  IsElementOfFpGroupFamily
##
DeclareCategoryFamily( "IsElementOfFpGroup" );


#############################################################################
##
#A  FpElmComparisonMethod(<fam>)
##
##  If <fam> is the elements family of a finitely presented group this
##  attribute returns a function `smaller(<left>,<right>)' that will be used
##  to compare elements in <fam>.
DeclareAttribute( "FpElmComparisonMethod",IsElementOfFpGroupFamily);

#############################################################################
##
#O  ElementOfFpGroup( <fam>, <word> )
##
##  If <fam> is the elements family of a finitely presented group and <word>
##  is a word in the free generators underlying this finitely presented
##  group, this operation creates the element with the representative <word>
##  in the free group.
DeclareOperation( "ElementOfFpGroup",
    [ IsElementOfFpGroupFamily, IsAssocWordWithInverse ] );


############################################################################
##
#f  CosetTableFpGroup
##
#T DeclareGlobalFunction("CosetTableFpGroup");
#T up to now no function was installed

#############################################################################
##
#F  CosetTableFromGensAndRels( <fgens>, <grels>, <fsgens> )
##
##  performs a Felsch strategy Todd-Coxeter coset enumeration. <fgens> must
##  be a set of free generators and <grels> a set of relators in these
##  generators. <fsgens> are subgroup generators expressed as words in these
##  generators. The function returns a coset table with respect to <fgens>.
DeclareGlobalFunction("CosetTableFromGensAndRels");


############################################################################
##
#F  IsFromFpGroupStdGensGeneralMappingByImages . . . Mapping from Fp group,
##                                    just mapping the standard generators
##
DeclareRepresentation( "IsFromFpGroupStdGensGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
IsFromFpGroupStdGensHomomorphismByImages :=
  IsFromFpGroupStdGensGeneralMappingByImages and IsMapping;


############################################################################
##
#F  IsToFpGroupGeneralMappingByImages
##
DeclareRepresentation( "IsToFpGroupGeneralMappingByImages",
      IsGroupGeneralMappingByImages,
      [ "generators", "genimages" ] );
IsToFpGroupHomomorphismByImages := IsToFpGroupGeneralMappingByImages
                               and IsMapping;


############################################################################
##
#F  LowIndexSubgroupsFpGroup(<G>,<H>,<index>[,<excluded>])
##
##  returns a  list  of  representatives  of  the
##  conjugacy classes of  subgroups of the finitely presented  group <G> that
##  contain the subgroup <H> of <H> and that have index less than or equal to
##  <index>.
##  
##  If the   optional argument  <excluded>  has  been specified, then   it is
##  expected  to   be a list    of words  in   the  generators  of  <G>,  and
##  `LowIndexSubgroupsFpGroup' returns only  those subgroups of index at most
##  <index> that contain <H>,  but do not contain any conjugate of any of the
##  group elements defined by these words.
##
##  The function  `LowIndexSubgroupsFpGroup' finds the requested subgroups
##  by systematically  running through a tree of  all potential  coset
##  tables of <G>  of length at most <index> (where it  skips all branches
##  of that tree for which  it knows in advance  that they cannot  provide
##  new classes of such subgroups). The time required to do this  depends,
##  of course, on the presentation of <G>, but  in general it will  grow
##  exponentially with the value of <index>.  So you should be careful with
##  the choice of <index>.
DeclareGlobalFunction("LowIndexSubgroupsFpGroup");


############################################################################
##
#F  MostFrequentGeneratorFpGroup
##
DeclareGlobalFunction("MostFrequentGeneratorFpGroup");


#############################################################################
##
#A  FreeGeneratorsOfFpGroup( <F> )
##
##  returns the underlying free generators corresponding to the generators
##  of the finitely presented group <F>.
DeclareAttribute( "FreeGeneratorsOfFpGroup",
     IsSubgroupFpGroup and IsGroupOfFamily  );

############################################################################
##
#A  RelatorsOfFpGroup(<F>)
##
##  returns relators for the finitely presented group <F> as  words in the
##  `FreeGeneratorsOfFpGroup(<F>)'.
DeclareAttribute("RelatorsOfFpGroup",IsSubgroupFpGroup and IsGroupOfFamily);

#############################################################################
##
#A  FreeGroupOfFpGroup( <F> )
##
##  returns the underlying free froup for the finitely presented group <F>.
##  This is the group generated by the `FreeGeneratorsOfFpGroup(<F>)'.
DeclareAttribute("FreeGroupOfFpGroup",IsSubgroupFpGroup and IsGroupOfFamily);

#############################################################################
##
#A  IndicesInvolutaryGenerators( <F> )
##
##  returns the indiced of those generators of the finitely presented group
##  <F> which are known to be involutions. This knowledge can be used to
##  improve the coset enumeration.
DeclareAttribute("IndicesInvolutaryGenerators",
  IsSubgroupFpGroup and IsGroupOfFamily);

############################################################################
##
#F  RelatorRepresentatives(<rels>)
##
##  returns a set of  relators,  that  contains for each relator in the list
##  <rels> its minimal cyclical  permutation (which is automatically
##  cyclically reduced).
DeclareGlobalFunction("RelatorRepresentatives");


#############################################################################
##
#F  RelsSortedByStartGen( <gens>, <rels>, <table> )
##
##  is a  subroutine of the  Felsch Todd-Coxeter and the  Reduced
##  Reidemeister-Schreier  routines. It returns a list which for each
##  generator or  inverse generator in <gens> contains a list  of all
##  cyclically reduced relators,  starting  with that element,  which can be
##  obtained by conjugating or inverting the given relators <rels>.  The
##  relators are represented as lists of the coset table columns from the
##  table <table> corresponding to the generators and, in addition, as lists
##  of the respective column numbers.
##
DeclareGlobalFunction("RelsSortedByStartGen");


#############################################################################
##
#F  SubgroupGeneratorsCosetTable(<freegens>,<fprels>,<table>)
##
##  determinates subgroup generators for the subgroup given by the coset
##  table <table> from the free generators <freegens>,
##  the  relators <fprels> (as words in <freegens>).
##  It returns words in <freegens>.
##
DeclareGlobalFunction( "SubgroupGeneratorsCosetTable" );


#############################################################################
##
#E  grpfp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

