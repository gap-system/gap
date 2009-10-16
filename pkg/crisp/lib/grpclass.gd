#############################################################################
##
##  grpclass.gd                      CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: grpclass.gd,v 1.2 2000/10/11 13:24:30 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
Revision.grpclass_gd :=
    "@(#)$Id: grpclass.gd,v 1.2 2000/10/11 13:24:30 gap Exp $";


#############################################################################
##
#P  IsGroupClass (<class>)
##
##  A class is a group classes if it consists of groups and is closed
##  under group isomorphisms
##
DeclareProperty ("IsGroupClass", IsClass);


#############################################################################
##
#M  IsGroupClass (<class>)
##
InstallTrueMethod (IsGroupClass, IsEmpty and IsClass);


#############################################################################
##
#O  GroupClass (<obj>)
##
##  creates a group class from an object
##
DeclareOperation ("GroupClass", [IsObject]);


#############################################################################
##
#O  GroupClass (<list>, <func>)
##
##  creates a group class from a list of groups and an isomorphism function
##
DeclareOperation ("GroupClass", 
   [IsList and IsMultiplicativeElementWithInverseCollColl,
      IsFunction]);


#############################################################################
##
#P  ContainsTrivialGroup (<group class>)
##
DeclareProperty ("ContainsTrivialGroup", IsGroupClass);


#############################################################################
##
#P  IsSubgroupClosed (<group class>)
#P  IsNormalSubgroupClosed (<group class>)
#P  IsQuotientClosed (<group class>)
#P  IsResiduallyClosed (<group class>)
#P  IsNormalProductClosed (<group class>)
#P  IsDirectProductClosed (<group class>)
#P  IsSchunckClass (<group class>)
#P  IsSaturated (<group class>)
##
##  primitive closure properties of group classes
##
DeclareProperty ("IsSubgroupClosed", IsGroupClass);
DeclareProperty ("IsNormalSubgroupClosed", IsGroupClass);
DeclareProperty ("IsQuotientClosed", IsGroupClass);
DeclareProperty ("IsResiduallyClosed", IsGroupClass);
DeclareProperty ("IsNormalProductClosed", IsGroupClass);
DeclareProperty ("IsDirectProductClosed", IsGroupClass);
DeclareProperty ("IsSchunckClass", IsGroupClass);
DeclareProperty ("IsSaturated", IsGroupClass);


#############################################################################
##
#M  IsNormalSubgroupClosed (<class>)
##
InstallTrueMethod (IsNormalSubgroupClosed, IsSubgroupClosed);


#############################################################################
##
#M  IsDirectProductClosed (<class>)
##
InstallTrueMethod (IsDirectProductClosed, IsResiduallyClosed);


#############################################################################
##
#M  IsDirectProductClosed (<class>)
##
InstallTrueMethod (IsDirectProductClosed, IsNormalProductClosed);


#############################################################################
##
#M  ContainsTrivialGroup (<class>)
##
InstallTrueMethod (ContainsTrivialGroup, IsSchunckClass);


#############################################################################
##
#M  IsDirectProductClosed (<class>)
##
InstallTrueMethod (IsDirectProductClosed, IsSchunckClass);


#############################################################################
##
#M  IsQuotientClosed (<class>)
##
InstallTrueMethod (IsQuotientClosed, IsSchunckClass);


#############################################################################
##
#M  IsSaturated (<class>)
##
InstallTrueMethod (IsSaturated, IsSchunckClass);


#############################################################################
##
#M  IsSchunckClass (<class>)
##
InstallTrueMethod (IsSchunckClass, 
   ContainsTrivialGroup and IsQuotientClosed and IsResiduallyClosed and IsSaturated);


#############################################################################
##
#M  IsResiduallyClosed (<class>)
##
InstallTrueMethod (IsResiduallyClosed, 
   IsDirectProductClosed and IsSubgroupClosed);


#############################################################################
##
#F  DEFAULT_ISO_FUNC (<grp1>, <grp2>)
##
##  default function used to test if two groups are isomorphic
##
DeclareGlobalFunction ("DEFAULT_ISO_FUNC");


#############################################################################
##
#E
##
