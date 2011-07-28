#############################################################################
##
##  socle.gd                         CRISP                   Burkhard Höfling
##
##  @(#)$Id: socle.gd,v 1.3 2011/05/15 19:18:01 gap Exp $
##
##  Copyright (C) 2001, 2002 Burkhard Höfling
##
Revision.socle_gd :=
    "@(#)$Id: socle.gd,v 1.3 2011/05/15 19:18:01 gap Exp $";

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
