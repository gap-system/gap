#############################################################################
##
#W  sgpres.gd                  GAP library                     Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for finitely presented groups
##  (fp groups).
##
Revision.sgpres_gd :=
    "@(#)$Id$";


############################################################################
##
#F  AbelianInvariantsNormalClosureFpGroupRrs(<G>,<H>)
##
##  uses the Reduced Reidemeister-Schreier method to compute the abelian
##  invariants of the normal closure of a subgroup <H> of a finitely
##  presented group <G>.
##
DeclareGlobalFunction("AbelianInvariantsNormalClosureFpGroupRrs");

############################################################################
##
#F  AbelianInvariantsNormalClosureFpGroup(<G>,<H>)
##
##  is a synonym for `AbelianInvariantsNormalClosureFpGroupRrs(<G>,<H>)'.
##
AbelianInvariantsNormalClosureFpGroup :=
    AbelianInvariantsNormalClosureFpGroupRrs;


############################################################################
##
#F  AbelianInvariantsSubgroupFpGroupMtc(<G>,<H>)
##
##  uses the Modified Todd-Coxeter method to compute the abelian
##  invariants of a subgroup <H> of a finitely presented group <G>.
##
DeclareGlobalFunction("AbelianInvariantsSubgroupFpGroupMtc");


#############################################################################
##
#F  AbelianInvariantsSubgroupFpGroupRrs( <G>, <H> )
#F  AbelianInvariantsSubgroupFpGroupRrs( <G>, <table> )
##
##  uses the Reduced Reidemeister-Schreier method to compute the abelian
##  invariants of a subgroup <H> of a finitely presented group <G>.
##
##  Alternatively to the subgroup <H>, its coset table <table> in <G> may be
##  given as second argument.
##
DeclareGlobalFunction("AbelianInvariantsSubgroupFpGroupRrs");


############################################################################
##
#F  AbelianInvariantsSubgroupFpGroup(<G>,<H>)
##
##  is a synonym for `AbelianInvariantsSubgroupFpGroupRrs(<G>,<H>)'.
##
AbelianInvariantsSubgroupFpGroup := AbelianInvariantsSubgroupFpGroupRrs;


#############################################################################
##
#O  AugmentedCosetTableInWholeGroup(< H > [,<gens>])
##
##  For a subgroup <H> of a finitely presented group, this function returns
##  an augmented coset table. If a generator set <gens> is given, it is
##  guaranteed that <gens> will be a subset of the primary and secondary
##  subgroup generators of this coset table.
##
##  It is mutable so we are permitted to add further entries. However
##  existing entries may not be changed. Any entries added however should
##  correspond to the subgroup only and not to an homomorphism.
##
DeclareGlobalFunction( "AugmentedCosetTableInWholeGroup" );

##  values for table types
BindGlobal("TABLE_TYPE_RRS",1);
BindGlobal("TABLE_TYPE_MTC",2);


#############################################################################
##
#A  AugmentedCosetTableMtcInWholeGroup(< H >)
##
##  For a subgroup <H> of a finitely presented group, this attribute
##  contains an augmented coset table for <H>. It is guaranteed that the
##  primary subgroup generators for this coset table will correspond to the
##  `GeneratorsOfGroup(<H>)'.
##
##  It is mutable so we are permitted to add further entries, however
##  existing entries may not be changed. Any entries added however should
##  correspond to the subgroup only and not to an homomorphism.
##
DeclareAttribute("AugmentedCosetTableMtcInWholeGroup",IsGroup,"mutable");


#############################################################################
##
#A  AugmentedCosetTableRrsInWholeGroup(< H >)
##
##  For a subgroup <H> of a finitely presented group, this attribute
##  contains an augmented coset table for <H>. The corresponding generator
##  set for <H> is not specified by this operation.
##
##  It is mutable so we are permitted to add further entries, however
##  existing entries may not be changed. Any entries added however should
##  correspond to the subgroup only and not to an homomorphism.
##
DeclareAttribute("AugmentedCosetTableRrsInWholeGroup",IsGroup,"mutable");


#############################################################################
##
#A  AugmentedCosetTableNormalClosureInWholeGroup(< H >)
##
##  For a subgroup <H> of a finitely presented group, this attribute
##  contains an augmented coset table of the normal closure of <H> in its
##  whole group.
##
##  It is mutable so we are permitted to add further entries.
##
DeclareAttribute( "AugmentedCosetTableNormalClosureInWholeGroup",
    IsGroup, "mutable" );


#############################################################################
##
#F  AugmentedCosetTableMtc( <G>, <H>, <type>, <string> )
##
##  is an internal function used by the subgroup presentation functions
##  described in "Subgroup Presentations". It applies a Modified Todd-Coxeter
##  coset representative enumeration to construct an augmented coset table
##  (see "Subgroup presentations") for the given subgroup <H> of <G>. The
##  subgroup generators will be named <string>1, <string>2, ... .
##
##  The function accepts the options `max' and `silent' as described for the
##  function `CosetTableFromGensAndRels' (see~"CosetTableFromGensAndRels").
##
DeclareGlobalFunction("AugmentedCosetTableMtc");


#############################################################################
##
#F  AugmentedCosetTableRrs( <G>, <table>, <type>, <string> )  . . . . .
##
##  is an internal function used by the subgroup presentation functions
##  described in "Subgroup Presentations". It
##  applies the Reduced Reidemeister-Schreier
##  method to construct an  augmented coset table  for the  subgroup of  <G>
##  which is defined by the  given coset table <table>.  The new  subgroup
##  generators  will be named  <string>1, <string>2, ... .
##
DeclareGlobalFunction("AugmentedCosetTableRrs");


#############################################################################
##
#O  AugmentedCosetTableNormalClosure( <G>, <H> )
##
##  returns the augmented coset table  of the finitely presented group <G> on
##  the cosets of the normal closure of the subgroup <H>.
##
DeclareOperation( "AugmentedCosetTableNormalClosure", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  CosetTableBySubgroup(<G>,<H>)
## 
##  returns a coset table for the action of <G> on the cosets of <H>. The
##  columns of the table correspond to the `GeneratorsOfGroup(<G>)'.
##
DeclareOperation("CosetTableBySubgroup",[IsGroup,IsGroup]);


#############################################################################
##
#F  CanonicalRelator( <rel> )
##
##  returns the  canonical  representative  of the  given relator <rel>.
##
DeclareGlobalFunction("CanonicalRelator");


#############################################################################
##
#F  CheckCosetTableFpGroup( <G>, <table> )
##
##  checks whether <table> is a legal coset table of the finitely presented
##  group <G>.
##
DeclareGlobalFunction("CheckCosetTableFpGroup");


############################################################################
##
#F  IsStandardized(<table>)
##
DeclareGlobalFunction("IsStandardized");


############################################################################
##
#C  IsPresentation( <obj> )
##
DeclareCategory( "IsPresentation", IsCopyable );


############################################################################
##
#V  PresentationsFamily
##
PresentationsFamily := NewFamily( "PresentationsFamily", IsPresentation );


#############################################################################
##
#F  PresentationAugmentedCosetTable(<aug>,<string>,[,<pl> [,<img>]] )
##
##  creates a presentation from the given augmented coset table. It assumes
##  that <aug> is an augmented coset table of type 2.
##  The generators will be named <string>1,
##  <string>2, ... .
##  The optional argument <pl> set the printlevel for the presentation.
##
##  `PresentationAugmentedCosetTable' will call `TzHandleLength1Or2Relators'
##  on the resulting presentation. this might eliminate generators and thus
##  makes it impossible to relate the presentation to the coset table. To
##  avoid this problem, if the optional argument <img> is set to `true',
##  `TzInitGeneratorImages' will be called, *before* starting this
##  elimination, thus preserving a way to connect the coset table with the
##  presentation.
##
DeclareGlobalFunction("PresentationAugmentedCosetTable");


#############################################################################
##
#F  PresentationNormalClosureRrs( <G>, <H> [,<string>] )
##
##  uses the Reduced Reidemeister-Schreier method to compute a presentation
##  <P>, say, for the normal closure of a subgroup <H> of a finitely
##  presented group <G>. The generators in the resulting presentation will
##  be named <string>1, <string>2, ... , the default string is `\"_x\"'.
##  You may access the <i>-th of these generators by <P>!.<i>. 
##
DeclareGlobalFunction("PresentationNormalClosureRrs");


#############################################################################
##
#F  PresentationNormalClosure(<G>,<H>[,<string>])
##
##  is a synonym for `PresentationNormalClosureRrs(<G>,<H>[,<string>])'.
##
PresentationNormalClosure := PresentationNormalClosureRrs;


#############################################################################
##
#F  PresentationSubgroupMtc(<G>, <H> [,<string>] [,<print level>] )
##
##  uses the Modified Todd-Coxeter coset representative enumeration method
##  to compute a presentation <P>, say, for a subgroup <H> of a finitely
##  presented group <G>. The presentation returned is in generators
##  corresponding to the generators of <H>. The generators in the resulting
##  presentation will be named <string>1, <string>2, ... , the default string
##  is `\"_x\"'. You may access the <i>-th of these generators by <P>!.<i>.
##
##  The default print level is 1. If the print level is set to 0, then the
##  printout of the implicitly called function `DecodeTree' will be
##  suppressed.
##
DeclareGlobalFunction("PresentationSubgroupMtc");


#############################################################################
##
#F  PresentationSubgroupRrs( <G>, <H> [,<string>] )
#F  PresentationSubgroupRrs( <G>, <table> [,<string>] )
##
##  uses the  Reduced Reidemeister-Schreier method to compute a presentation
##  <P>, say, for a subgroup <H> of a finitely presented group <G>. The
##  generators in the resulting presentation will be named <string>1,
##  <string>2, ... , the default string is `\"_x\"'.
##  You may access the <i>-th of these generators by <P>!.<i>.
##
##  Alternatively to the subgroup <H>, its coset table <table> in <G> may be
##  given as second argument.
##
DeclareGlobalFunction("PresentationSubgroupRrs");


#############################################################################
##
#F  PresentationSubgroup(<G>,<H>[,<string>])
##
##  is a synonym for `PresentationSubgroupRrs(<G>,<H>[,<string>])'.
##
PresentationSubgroup := PresentationSubgroupRrs;

#############################################################################
##
#A  PrimaryGeneratorWords( <P> )
##
##  is an attribute of the presentation <P> which holds a list of words in
##  the associated group generators (of the underlying free group) which
##  express the primary subgroup generators of <P>.
##
DeclareAttribute("PrimaryGeneratorWords",IsPresentation);

#############################################################################
##
#F  ReducedRrsWord( <word> )
##
##  freely reduces the given RRS word and returns the result.
##
DeclareGlobalFunction("ReducedRrsWord");


#############################################################################
##
#F  RelatorMatrixAbelianizedNormalClosureRrs( <G>, <H> )
##
##  uses the Reduced Reidemeister-Schreier method  to compute a matrix of
##  abelianized defining relators for the  normal  closure of a subgroup <H>
##  of a  finitely presented  group <G>.
##
DeclareGlobalFunction("RelatorMatrixAbelianizedNormalClosureRrs");


#############################################################################
##
#F  RelatorMatrixAbelianizedSubgroupMtc( <G>, <H> )
##
##  uses  the  Modified  Todd-Coxeter coset representative enumeration
##  method  to compute  a matrix of abelianized defining relators for a
##  subgroup <H> of a finitely presented group <G>.
##
DeclareGlobalFunction("RelatorMatrixAbelianizedSubgroupMtc");


#############################################################################
##
#F  RelatorMatrixAbelianizedSubgroupRrs( <G>, <H> )
#F  RelatorMatrixAbelianizedSubgroupRrs( <G>, <table> )
##
##  uses the Reduced Reidemeister-Schreier method to compute a matrix of
##  abelianized defining relators for a subgroup <H> of a finitely presented
##  group <G>.
##
##  Alternatively to the subgroup <H>, its coset table <table> in <G> may be
##  given as second argument.
##
DeclareGlobalFunction("RelatorMatrixAbelianizedSubgroupRrs");

#############################################################################
##
#F  RelatorMatrixAbelianizedSubgroup(<G>,<H>)
#F  RelatorMatrixAbelianizedSubgroup(<G>,<table>)
##
##  is a synonym for `RelatorMatrixAbelianizedSubgroupRrs(<G>,<H>)' or
##  `RelatorMatrixAbelianizedSubgroupRrs(<G>,<table>)', respectively.
##
RelatorMatrixAbelianizedSubgroup := RelatorMatrixAbelianizedSubgroupRrs;


#############################################################################
##
#F  RenumberTree( <augmented coset table> )
##
##  is  a  subroutine  of  the  Reduced Reidemeister-Schreier
##  routines.  It renumbers the generators  such that the  primary generators
##  precede the secondary ones.
##
DeclareGlobalFunction("RenumberTree");


#############################################################################
##
#F  RewriteAbelianizedSubgroupRelators( <aug>,<prels> )
##
##  is  a  subroutine  of  the  Reduced
##  Reidemeister-Schreier and the Modified Todd-Coxeter routines. It computes
##  a set of subgroup relators  from the  coset factor table  of an augmented
##  coset table <aug> of type 0 and the relators <prels> of the parent group.
##
##  It returns the rewritten relators as list of integers
##
DeclareGlobalFunction("RewriteAbelianizedSubgroupRelators");

#############################################################################
##
#F  RewriteSubgroupRelators( <aug>, <prels> )
##
##  is a subroutine  of the  Reduced
##  Reidemeister-Schreier and the  Modified Todd-Coxeter  routines.  It
##  computes  a set of subgroup relators from the coset factor table of an
##  augmented coset table <aug> and the  relators <prels> of the  parent
##  group.  It assumes  that  <aug> is an augmented coset table of type 2.
##
##  It returns the rewritten relators as list of integers
##
DeclareGlobalFunction("RewriteSubgroupRelators");


#############################################################################
##
#F  SortRelsSortedByStartGen(<relsGen>)
##
##  sorts the relators lists  sorted  by  starting
##  generator to get better  results  of  the  Reduced  Reidemeister-Schreier
##  (this is not needed for the Felsch Todd-Coxeter).
##
DeclareGlobalFunction("SortRelsSortedByStartGen");


#############################################################################
##
#F  SpanningTree( <table> )
##
##  `SpanningTree'  returns a spanning tree for the given coset table
##  <table>.
##
DeclareGlobalFunction("SpanningTree");

#############################################################################
##
#F  RewriteWord( <aug>, <word> )
##
##  RewriteWord rewrites <word> (which must be a word in the full group with
##  respect to which the augmented coset table <aug> is given) in the
##  subgroup generators given by the augmented coset table <aug>. It returns
##  a Tietze-type word (i.e.~a list of integers), referring to the primary
##  and secondary generators of <aug>.
##
##  If <word> is not contained in the subgroup, `fail' is returned.
##
DeclareGlobalFunction("RewriteWord");

#############################################################################
##
#F  DecodedTreeEntry(<tree>,<imgs>,<nr>) 
##
##  returns tree element <nr>, when mapping the first elements of <tree>
##  onto <imgs>. (Conventions for trees are as with augmented coset tables.)
DeclareGlobalFunction("DecodedTreeEntry");

#############################################################################
##
#F  GeneratorTranslationAugmentedCosetTable(<aug>) 
##
##  decode all the secondary generators as words in the primary generators,
##  using the `.subgroupGenerators' and creating their subset
##  `.primarySubgroupGenerators'.
DeclareGlobalFunction("GeneratorTranslationAugmentedCosetTable");

#############################################################################
##
#F  SecondaryGeneratorWordsAugmentedCosetTable(<aug>) 
##
##  returns words in the (underlying free) groups generators for the coset
##  table's secondary generators.
DeclareGlobalFunction("SecondaryGeneratorWordsAugmentedCosetTable");

#############################################################################
##
#F  CopiedAugmentedCosetTable(<aug>) 
##
##  returns a new augmented coset table, equal to the old one. The
##  components of this new table are immutable, but new components may be
##  added.
##  (This function is needed to have different homomorphisms share the same
##  augmented coset table data.)
DeclareGlobalFunction("CopiedAugmentedCosetTable");


#############################################################################
##
#E  sgpres.gd  . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here
