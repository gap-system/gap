#############################################################################
##
##  socle.gd                         CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: socle.gd,v 1.2 2003/02/11 14:47:39 gap Exp $
##
##  Copyright (C) 2001 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
Revision.socle_gd :=
    "@(#)$Id: socle.gd,v 1.2 2003/02/11 14:47:39 gap Exp $";

#############################################################################
##
#A  SolvableSocle (<G>) 
##
DeclareAttribute ("SolvableSocle", IsGroup);
DeclareSynonym ("AbelianSocle", SolvableSocle);

#############################################################################
##
#A  SocleComponents (<G>) 
##
DeclareAttribute ("SocleComponents", IsGroup);


#############################################################################
##
#A  SolvableSocleComponents (<G>) 
##
DeclareAttribute ("SolvableSocleComponents", IsGroup);
DeclareSynonym ("AbelianSocleComponents", SolvableSocleComponents);


#############################################################################
##
#A  PSocleComponents (<G>) 
##
KeyDependentOperation ("PSocleComponents", IsGroup, IsPosInt, "prime");


#############################################################################
##
#A  PSocle (<G>) 
##
KeyDependentOperation ("PSocle", IsGroup, IsPosInt, "prime");


#############################################################################
##
#A  SolvableMinimalNormalSubgroups (<G>) 
##
DeclareAttribute ("AbelianMinimalNormalSubgroups", IsGroup);


#############################################################################
##
#F  SolvableSocleComponentsBySeries (<G>, <ser>) 
##
##  G must be a finite group and ser must be a G-composition series of ser[i],
##  which must be solvable.
##  SocleComponentsBySeries computes a set [L_1, \ldots, L_r] of minimal
##  G-invariant subgroups of ser such that Soc(G) \cap ser[1] is the direct
##  product of the L_i.
##
DeclareGlobalFunction ("SolvableSocleComponentsBySeries");


#############################################################################
##
#E
##
