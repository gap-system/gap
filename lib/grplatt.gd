#############################################################################
##
#W  grplatt.gd                GAP library                   Martin Sch"onert,
#W                                                          Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This  file  contains declarations for subgroup latices
##
Revision.grplatt_gd:=
  "@(#)$Id$";

#############################################################################
##
#V  InfoLattice                                    Information
##
##  is the information class used by the cyclic extension methods for
##  subgroup lattice calculations.
DeclareInfoClass("InfoLattice");

#############################################################################
##
#R  IsConjugacyClassSubgroupsRep(<obj>)
##
##  This representation indicates conjugacy classes of subgroups. They are
##  external orbits.
DeclareRepresentation("IsConjugacyClassSubgroupsRep",
  IsExternalOrbitByStabilizerRep,[]);

#############################################################################
##
#O  ConjugacyClassSubgroups(<G>,<U>)
##
##  generates the conjugacy class of subgroups of <G> with representative <U>.
##  This class is an external set, so functions like `Representative',
##  `StabilizerOfExternalSet' and `AsList' work for it.
##  It is possible to use the `[]'
##  list access to select elements of the class. *Because of potential other
##  methods installed, the `AsList' command may give a different arrangement
##  of the class elements!*
DeclareOperation("ConjugacyClassSubgroups", [IsGroup,IsGroup]);
#T 1997/01/16 fceller was old 'NewConstructor'

#############################################################################
##
#R  IsLatticeSubgroupsRep(<obj>)
##
##  This representation indicates lattices of subgroups.
DeclareRepresentation("IsLatticeSubgroupsRep",
  IsComponentObjectRep and IsAttributeStoringRep,
  ["group","conjugacyClassesSubgroups"]);

#############################################################################
##
#A  Zuppos(<G>) .  set of generators for cyclic subgroups of prime power size
##
##  The *Zuppos* of a group are the cyclic subgroups of prime power order.
##  (The name ``Zuppo'' derives from the German abbreviation for ``zyklische
##  Untergruppen von Primzahlpotenzordnung''.) This attribute
##  gives generators of all such subgroups of a group <G>. That is all elements
##  of <G> of prime power order up to the equivalence that they generate the
##  same cyclic subgroup.
DeclareAttribute("Zuppos",IsGroup);

#############################################################################
##
#F  LatticeByCyclicExtension(<G>[,<func>])
##  
##  computes the lattice of <G> using the cyclic extension algorithm. If the
##  function <func> is given, the algorithm will discard all subgroups not
##  fulfilling <func> (and will also not extend them), returning a partial
##  lattice. This can be useful to compute only subgroups with certain
##  properties. Note however that this will *not* necessarily yield all
##  subgroups that fulfill <func>, but the subgroups whose subgroups used
##  for the construction also fulfill <func> as well.
DeclareGlobalFunction("LatticeByCyclicExtension");

#############################################################################
##
#A  MaximalSubgroupsLattice(<lat>)
##
##  For a lattice <lat> of subgroups this attribute contains the maximal
##  subgroup relations among the subgroups of the lattice. It is a list,
##  corresponding to the `ConjugacyClassesSubgroups' of the lattice, each entry
##  giving a list of the maximal subgroups of the representative of this class.
##  Every maximal subgroup is indicated by a list of the form [<cls>,<nr>] which
##  means that the <nr>st subgroup in class number <cls> is a maximal subgroup
##  of the representative. The number <nr> corresponds to access via the
##  `[]' operator and *not* necessarily the `AsList' arrangement!
##  See also "MinimalSupergroupsLattice".
DeclareAttribute("MaximalSubgroupsLattice",IsLatticeSubgroupsRep);

#############################################################################
##
#A  MinimalSupergroupsLattice(<lat>)
##
##  For a lattice <lat> of subgroups this attribute contains the minimal
##  supergroup relations among the subgroups of the lattice. It is a list,
##  corresponding to the `ConjugacyClassesSubgroups' of the lattice, each entry
##  giving a list of the minimal supergroups of the representative of this
##  class. Every minimal supergroup is indicated by a list of the
##  form [<cls>,<nr>] which means that the <nr>st subgroup in class number
##  <cls> is a minimal supergroup
##  of the representative. The number <nr> corresponds to access via the
##  `[]' operator and *not* necessarily the `AsList' arrangement!
##  See also "MaximalSubgroupsLattice".
DeclareAttribute("MinimalSupergroupsLattice",IsLatticeSubgroupsRep);

#############################################################################
##
#E  grplatt.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
