#############################################################################
##
#W  morpheus.gd                GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This  file  contains declarations for Morpheus
##
Revision.morpheus_gd:=
  "@(#)$Id$";

DeclareInfoClass("InfoMorph");

#############################################################################
##
#A  AutomorphismGroup(<obj>)
##
##  returns the full automorphism group of the object <obj>. The
##  automorphisms act on the domain by the caret operator `^'.
##  The automorphism group often stores a ``NiceMonomorphism'' (see
##  "NiceMonomorphism") to a permutation group, obtained by the action on a
##  subset of <obj>.
##
DeclareAttribute("AutomorphismGroup",IsDomain);

#############################################################################
##
#P  IsGroupOfAutomorphisms(<G>)
##
##  indicates whether <G> consists of automorphisms of another group <H>.
##  The group <H> can be obtained from <G> via the attribute
##  `AutomorphismDomain'.
DeclareProperty( "IsGroupOfAutomorphisms", IsGroup );

InstallTrueMethod( IsHandledByNiceMonomorphism,IsGroupOfAutomorphisms );

#############################################################################
##
#A  AutomorphismDomain(<G>)
##
##  If <G> consists of automorphisms of <H>, this attribute returns <H>.
DeclareAttribute( "AutomorphismDomain", IsGroupOfAutomorphisms );

#############################################################################
##
#P  IsAutomorphismGroup(<G>)
##
##  indicates whether <G> is the full automorphism group of another group
##  <H>, this group is given as `AutomorphismDomain' of <G>.
DeclareProperty( "IsAutomorphismGroup", IsGroupOfAutomorphisms );

InstallTrueMethod( IsGroupOfAutomorphisms,IsAutomorphismGroup );

#############################################################################
##
#A  InnerAutomorphismsAutomorphismGroup(<autgroup>)
##
##  For an automorphism group <autgroup> of a group this attribute stores
##  the subgroup of inner automorphisms (automorphisms induced by conjugation)
##  of the original group.
DeclareAttribute("InnerAutomorphismsAutomorphismGroup",IsGroup);

#############################################################################
##
#F  AssignNiceMonomorphismAutomorphismGroup(<autgrp>,<group>)   local
##
##  
##  computes a nice monomorphism for <autgroup> acting on <group> and stores
##  it as `NiceMonomorphism' in <autgrp>.
##
##  If the centre of `AutomorphismDomain' of <autgrp> is trivial, the
##  operation will first try to represent all automorphisms by conjugation
##  (in <group> or a natural parent of <group>).
##
##  If this fails the operation tries to find a small subset of <group> on
##  which the action will be faithful.
##
##  The operation sets the attribute `NiceMonomorphism' and does not return
##  a value.
##
DeclareGlobalFunction("AssignNiceMonomorphismAutomorphismGroup");

#############################################################################
##
#F  NiceMonomorphismAutomGroup(<autgrp>,<elms>,<elmsgens>)
##
##  This function creates a monomorphism for an automorphism group
##  <autgrp> of a group by permuting the group elements in the list <elms>.
##  This list must be chosen to yield a faithful representation. <elmsgens>
##  is a list of generators which are a subset of <elms>. (They can differ
##  from the groups original generators.) It does not yet assign it as
##  `NiceMonomorphism'.
DeclareGlobalFunction("NiceMonomorphismAutomGroup");

#############################################################################
##
#F  MorFroWords(<gens>) . . . . . . create some pseudo-random words in <gens>
##
##  This function takes a generator list <gens> and creates a list of
##  pseudo-random words in them. These words can be used for example to test
##  quickly whether generator mappings extend to a homomorphism. The words
##  are taken from the MeatAxe FRO routine.
##
DeclareGlobalFunction("MorFroWords");

#############################################################################
##
#F  MorRatClasses(<G>) . . . . . . . . . . . local
##
##  yields a list of rational classes as a collection of ordinary classes.
##
DeclareGlobalFunction("MorRatClasses");

#############################################################################
##
#F  MorMaxFusClasses(<l>) . .  maximal possible morphism fusion of classlists
##
##  computes a list of classes (as unions of rational classes) which will be
##  respected by any automorphism. This is used to determine potential
##  automorphism images of elements.
DeclareGlobalFunction("MorMaxFusClasses");


#############################################################################
##
#F  MorClassLoop(<range>,<classes>,<params>,<action>)     class loop
##
##  This function loops over element tuples taken from <classes> and checks
##  these for properties like generating a given group of fulfilling relations.
##  This can be used to find small generating sets or all types of Morphisms.
##  The element tuples are classified only up to up to inner automorphisms as
##  all images can be obtained easily from them by conjugation but usually
##  running through all of them would take too long.
##  
##  <range> is a groups containing the elements.
##  The classes are given in a list <classes> which  is a list of records
##  like the ones returned from `MorMaxFusClasses'.
##  <params> is a record containing optional components:
##  \beginitems
##  `gens'& generators that are to be mapped (for testing morphisms). The length
##  of this list determines the length of element tuples considered.
##  
##  `from'& a preimage group (that contains <gens>)
##  
##  `to'& image group (which might be smaller than `range')
##   
##  `free'& free generators, a list of the same length than the generators `gens'.
##  
##  `rels'& some relations that hold among the generators `gens'. They are given
##  as a list [<word>,<order>] where <word> is a word in the free generators
##  `free'.
##  
##  `dom'& a set of elements on which automorphisms act faithfully (used to do
##  element tests in partial automorphism groups).
##  
##  `aut'& Subgroup of already known automorphisms.
##  \enditems
##  
##  <action> is a number whose bit-representation indicates the requirements
##  which are enforced on the element tuples found:\par\noindent
##  1\quad homomorphism\par\noindent
##  2\quad injective\par\noindent
##  4\quad surjective\par\noindent
##  8\quad find all (otherwise stops after the first find)\par\noindent
##  If the search is for homomorphisms, the function returns homomorphisms
##  obtained by mapping the given generators `gens' instead of element tuples.
##
DeclareGlobalFunction("MorClassLoop");

#############################################################################
##
#F  MorFindGeneratingSystem(<G>,<cl>) . .  local
##
##  tries to find generating system with as few as possible generators
##  which will be taken preferraby from the first classes in <cl>
##
DeclareGlobalFunction("MorFindGeneratingSystem");


#############################################################################
##
#F  Morphium(<G>,<H>,<DoAuto>) . . . . . . . . local
##
##  This function is a frontend to `MorClassLoop' and is used to find
##  isomorphisms between <G> and <H> or the automorphism group of <G> (in which
##  case <G> must equal <H>). The boolean flag <DoAuto> indicates if all
##  automorphisms should be found.
##  The function requires, that both groups are not cyclic!
##
DeclareGlobalFunction("Morphium");

#############################################################################
##
#F  AutomorphismGroupAbelianGroup(<G>)
##
##  computes the automorphism group of an abelian group <G>, using the theorem
##  of Shoda.
##
DeclareGlobalFunction("AutomorphismGroupAbelianGroup");

#############################################################################
##
#F  IsomorphismAbelianGroups(<G>,<H>)
##
##  computes an isomorphism between the abelian groups <G> and <H>
##  if they are isomorphic and returns `fail' otherwise.
##
DeclareGlobalFunction("IsomorphismAbelianGroups");

#############################################################################
##
#F  IsomorphismGroups(<G>,<H>)
##
##  computes an isomorphism between the groups <G> and <H>
##  if they are isomorphic and returns `fail' otherwise.
##
DeclareGlobalFunction("IsomorphismGroups");

#############################################################################
##
#O  GQuotients(<F>,<G>)  . . . . . epimorphisms from F onto G up to conjugacy
##
##  computes all epimorphisms from <F> onto <G> up to automorphisms of <G>.
##  This classifies all factor groups of <F> which are isomorphic to <G>.
##
DeclareOperation("GQuotients",[IsGroup,IsGroup]);

#############################################################################
##
#O  IsomorphicSubgroups(<G>,<H>)  monomorphisms from H onto G up to conjugacy
##
##  computes all monomorphisms from <H> onto <G> up to <G>-conjugacy of the
##  image groups.  This classifies all <G>-classes of subgroups of <G> which
##  are isomorphic to <H>.
##
DeclareOperation("IsomorphicSubgroups",[IsGroup,IsGroup]);

#############################################################################
##
#E  morpheus.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
