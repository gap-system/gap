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
##  uses the Reduced Reidemeister-Schreier method  to compute the abelian
##  invariants  of the normal closure of a subgroup <H> of a finitely
##  presented group <G>.
DeclareGlobalFunction("AbelianInvariantsNormalClosureFpGroupRrs");

############################################################################
##
#F  AbelianInvariantsNormalClosureFpGroup(<G>,<H>)
##
##  is a synonym for `AbelianInvariantsNormalClosureFpGroupRrs'.
AbelianInvariantsNormalClosureFpGroup :=
    AbelianInvariantsNormalClosureFpGroupRrs;


############################################################################
##
#F  AbelianInvariantsSubgroupFpGroupMtc(<G>,<H>)
##
##  uses  the  Modified  Todd-Coxeter method  to compute the  abelian
##  invariants of a  subgroup <H> of a finitely presented group <G>.
DeclareGlobalFunction("AbelianInvariantsSubgroupFpGroupMtc");


#############################################################################
##
#F  AbelianInvariantsSubgroupFpGroupRrs( <G>, <H> )
#F  AbelianInvariantsSubgroupFpGroupRrs( <G>, <table> )
##
##  uses  the  Reduced  Reidemeister- Schreier method  to compute the
##  abelian invariants  of a subgroup <H> of a finitely presented group G.
##
##  Alternatively to a finitely presented group, the subgroup <H>  may be given
##  by its coset table <table> in <G>.
DeclareGlobalFunction("AbelianInvariantsSubgroupFpGroupRrs");

############################################################################
##
#F  AbelianInvariantsSubgroupFpGroup(<G>,<H>)
##
##  is a synonym for `AbelianInvariantsSubgroupFpGroupRrs'.
AbelianInvariantsSubgroupFpGroup := AbelianInvariantsSubgroupFpGroupRrs;


#############################################################################
##
#F  AugmentedCosetTableMtc( <G>, <H>, <type>, <string> )
##
##  `AugmentedCosetTableMtc' applies a Modified Todd-Coxeter coset represent-
##  ative  enumeration  to construct  an augmented coset table  for the given
##  subgroup <H> of <G>. The  subgroup generators  will be  named  <string>1,
##  <string>2, ... .
##
##  Valid types are  1 (for the one generator case),  0 (for the  abelianized
##  case),  and  2 (for the general case).  A type value of  -1 is handled in
##  the same way as the case type = 1,  but the function will just return the
##  index of the given cyclic subgroup, and its exponent `<aug>.exponent'
##  as the only component of the resulting record <aug>.
##
DeclareGlobalFunction("AugmentedCosetTableMtc");


#############################################################################
##
#F  AugmentedCosetTableRrs( <group>, <table>, <type>, <string> )  . . .
##
##  `AugmentedCosetTableRrs' applies the Reduced Reidemeister-Schreier
##  method to construct an  augmented coset table  for the  subgroup of  <G>
##  which is defined by the  given coset table <table>.  The new  subgroup
##  generators  will be named  <string>1, <string>2, ... .
##
DeclareGlobalFunction("AugmentedCosetTableRrs");

#############################################################################
##
#M  CosetTableBySubgroup(<G>,<H>)
## 
##  returns a coset table for the action of <G> on the cosets of <H>. The
##  columns of the table correspond to the `GeneratorsOfGroup(<G>)'.
DeclareGlobalFunction("CosetTableBySubgroup");

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
DeclareCategory( "IsPresentation", IsObject );


############################################################################
##
#V  PresentationsFamily
##
PresentationsFamily := NewFamily( "PresentationsFamily", IsPresentation );


#############################################################################
##
#F  PresentationAugmentedCosetTable( <aug>  [,<print level>] )
##
##  creates a presentation from the given augmented coset table. It assumes
##  that <aug> is an augmented coset table of type 2.
##
DeclareGlobalFunction("PresentationAugmentedCosetTable");


#############################################################################
##
#M  PresentationNormalClosureRrs( <G>, <H> [,<string>] )
##
##  uses  the  Reduced  Reidemeister-Schreier method  to compute a
##  presentation  (i.e. a presentation record)  for the normal closure <N>,
##  say,  of a subgroup <H> of a finitely presented group <G>.  The
##  generators in the  resulting presentation  will be named  <string>1,
##  <string>2, ... , the default string is `"_x"'.
##
DeclareGlobalFunction("PresentationNormalClosureRrs");


#############################################################################
##
#M  PresentationNormalClosure( <G>, <H> [,<string>] )
##
##  is a synonym for `PresentationNormalClosureRrs'.
PresentationNormalClosure := PresentationNormalClosureRrs;


#############################################################################
##
#F  PresentationSubgroupMtc(<G>, <H> [,<string>] [,<print level>] )
##
##  uses the Modified Todd-Coxeter coset representative enumeration method
##  to compute a presentation for a subgroup H of a finitely presented group
##  G. The presentation returned is in generators corresponding to the
##  generators of <H>. The generators in the resulting presentation will be
##  named <string>1, <string>2, ... , the default string is `"_x"'.  The
##  default print level is  1.  If the print level is set to 0,  then the
##  printout of the `DecodeTree' command will be suppressed.
##
DeclareGlobalFunction("PresentationSubgroupMtc");


#############################################################################
##
#F  PresentationSubgroupRrs( <G>, <H> [,<string>] )
#F  PresentationSubgroupRrs( <G>, <table> [,<string>] )
##
##  uses the  Reduced Reidemeister-Schreier method
##  to compute a presentation  for a subgroup <H>
##  of a  finitely  presented  group <G>.  The  generators  in  the  resulting
##  presentation   will be  named   <string>1,  <string>2, ... ,  the default
##  string is `"_x"'.
##
##  Alternatively to a finitely presented group, the subgroup <H>  may be given
##  by its coset table <table>.
##
##  The optional <printlevel> parameter can be used to restrict or to extend
##  the amount of output provided by the `PresentationSubgroupMtc' command.
##  In particular, by specifying the <printlevel> parameter to be 0, you can
##  suppress the output of the `DecodeTree' command which is called by the
##  `PresentationSubgroupMtc' command (see below). The default value of
##  <printlevel> is 1.
##
DeclareGlobalFunction("PresentationSubgroupRrs");


#############################################################################
##
#F  PresentationSubgroup( <word> )
##
##  is a synonym for `PresentationSubgroupRrs'.
PresentationSubgroup := PresentationSubgroupRrs;

#############################################################################
##
#A  PrimaryGeneratorWords( <P> )
##
##  is a presentation of a subgroup is computed this attribute holds words
##  in the groups generators that give the subgroup generators in which the
##  presentation is written.
DeclareAttribute("PrimaryGeneratorWords",IsPresentation);

#############################################################################
##
#F  ReducedRrsWord( <word> )
##
##  freely reduces the given RRS word and returns the result.
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
##  uses  the   Reduced Reidemeister-Schreier method  to compute a matrix of
##  abelianized defining relators for a subgroup <H> of a finitely presented
##  group <G>.
##
##  Alternatively to a finitely presented group, the subgroup <H> may be
##  given by its coset table.
##
DeclareGlobalFunction("RelatorMatrixAbelianizedSubgroupRrs");

#############################################################################
##
#F  RelatorMatrixAbelianizedSubgroup( <G>, <H> )
#F  RelatorMatrixAbelianizedSubgroup( <G>, <table> )
##
##  is a synonym for `RelatorMatrixAbelianizedSubgroupRrs'.
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
DeclareGlobalFunction("RewriteAbelianizedSubgroupRelators");

#############################################################################
##
#F  RewriteSubgroupRelators( <aug>, <prels> )
##
##  is a subroutine  of the  Reduced
##  Reidemeister- Schreier and the  Modified Todd-Coxeter  routines.  It
##  computes  a set of subgroup relators from the coset factor table of an
##  augmented coset table <aug> and the  relators <rels> of the  parent
##  group.  It assumes  that  <aug> is an augmented coset table of type 2.
##
##  It returns the rewritten relators as list of integers
DeclareGlobalFunction("RewriteSubgroupRelators");


#############################################################################
##
#F  SortRelsSortedByStartGen(<relsGen>)
##
##  sorts the relators lists  sorted  by  starting
##  generator to get better  results  of  the  Reduced  Reidemeister-Schreier
##  (this is not needed for the Felsch Todd-Coxeter).
DeclareGlobalFunction("SortRelsSortedByStartGen");


#############################################################################
##
#F  SpanningTree( <table> )
##
##  'SpanningTree'  returns a spanning tree for the given coset table
##  <table>.
##
DeclareGlobalFunction("SpanningTree");


#############################################################################
##
#E  sgpres.gd  . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here
