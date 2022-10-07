#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the operations  for polycyclic generating systems of pc
##  groups.
##

#############################################################################
##
#P  IsFamilyPcgs( <pcgs> )
##
##  <#GAPDoc Label="IsFamilyPcgs">
##  <ManSection>
##  <Prop Name="IsFamilyPcgs" Arg='pcgs'/>
##
##  <Description>
##  specifies whether the pcgs is a <Ref Attr="FamilyPcgs"/> of a pc group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFamilyPcgs", IsPcgs,
  30 #familyPcgs is stronger than prime orders and some other properties
     # (cf. rank for `IsParentPcgsFamilyPcgs' in pcgsind.gd)
  );
InstallTrueMethod(IsCanonicalPcgs,IsFamilyPcgs);
InstallTrueMethod(IsParentPcgsFamilyPcgs,IsFamilyPcgs);

#############################################################################
##
#F  DoExponentsConjLayerFampcgs( <p>,<m>,<e>,<c> )
##
##  <ManSection>
##  <Func Name="DoExponentsConjLayerFampcgs" Arg='p,m,e,c'/>
##
##  <Description>
##  this algorithm does not compute any conjugates but only looks them up and
##  adds vectors mod <A>p</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("DoExponentsConjLayerFampcgs");
