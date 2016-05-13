#############################################################################
##
#W  pcgspcg.gd                  GAP Library                      Frank Celler
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations  for polycylic generating systems of pc
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


#############################################################################
##  
#E

