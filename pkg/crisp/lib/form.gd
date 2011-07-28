#############################################################################
##
##  form.gd                         CRISP                    Burkhard Höfling
##
##  @(#)$Id: form.gd,v 1.3 2011/05/15 19:17:54 gap Exp $
##
##  Copyright (C) 2000 Burkhard Höfling
##
Revision.form_gd :=
    "@(#)$Id: form.gd,v 1.3 2011/05/15 19:17:54 gap Exp $";


#############################################################################
##
#F  IsOrdinaryFormation (<group class>)
##
DeclareSynonym ("IsOrdinaryFormation", 
   IsGroupClass and ContainsTrivialGroup 
      and IsQuotientClosed and IsResiduallyClosed);


#############################################################################
##
#F  HasIsOrdinaryFormation (<group class>)
##
DeclareSynonym ("HasIsOrdinaryFormation", 
   HasIsGroupClass and HasContainsTrivialGroup 
      and HasIsQuotientClosed and HasIsResiduallyClosed);


#############################################################################
##
#F  SetIsOrdinaryFormation (<group class>)
##
DeclareGlobalFunction ("SetIsOrdinaryFormation");


#############################################################################
##
#O  OrdinaryFormation (<obj>)
##
DeclareOperation ("OrdinaryFormation", [IsObject]);


#############################################################################
##
#O  FormationProduct (<form1>, <form2>)
##
DeclareOperation ("FormationProduct", 
   [IsOrdinaryFormation, IsOrdinaryFormation]);


#############################################################################
##
#F  IsSaturatedFormation (<group class>)
##
DeclareSynonym ("IsSaturatedFormation", IsOrdinaryFormation and IsSaturated);


#############################################################################
##
#F  HasIsSaturatedFormation (<group class>)
##
DeclareSynonym ("HasIsSaturatedFormation", 
   HasIsOrdinaryFormation and HasIsSaturated);


#############################################################################
##
#F  SetIsSaturatedFormation (<group class>)
##
DeclareGlobalFunction ("SetIsSaturatedFormation");


#############################################################################
##
#O  SaturatedFormation (<rec>)
##
DeclareOperation ("SaturatedFormation", [IsObject]);


#############################################################################
##
#F  HasIsFittingFormation(<group class>)
##
DeclareSynonym ("HasIsFittingFormation", 
   HasIsFittingClass and HasIsOrdinaryFormation);


#############################################################################
##
#F  IsFittingFormation(<group class>)
##
DeclareSynonym ("IsFittingFormation", 
   IsFittingClass and IsOrdinaryFormation);


#############################################################################
##
#F  SetIsFittingFormation (<group class>)
##
##  fake setter functions for these "properties"
##
DeclareGlobalFunction ("SetIsFittingFormation");


#############################################################################
##
#O  FittingFormation (<obj>)
##
DeclareOperation ("FittingFormation", [IsObject]);


#############################################################################
##
#O  FittingFormationProduct (<fitform1>, <fitform2>)
##
##  If <fitform1> and <fitform2> are Fitting formations, this returns the
##  class of all groups which are the extension of a group in <fitform1> by
##  a group in <fitform2>. Note that this class coincides both with the 
##  formation product and the Fitting product of the two classes (hence the
##  name). 
##
DeclareOperation ("FittingFormationProduct", 
   [IsFittingFormation, IsFittingFormation]);


#############################################################################
##
#F  IsSaturatedFittingFormation (<group class>)
##
DeclareSynonym ("IsSaturatedFittingFormation", 
   IsFittingFormation and IsSaturated);


#############################################################################
##
#F  HasIsSaturatedFittingFormation (<group class>)
##
DeclareSynonym ("HasIsSaturatedFittingFormation", 
   HasIsFittingFormation and HasIsSaturated);


#############################################################################
##
#F  SetIsSaturatedFittingFormation (<group class>)
##
##  fake setter functions for these "properties"
##
DeclareGlobalFunction ("SetIsSaturatedFittingFormation");


#############################################################################
##
#O  SaturatedFittingFormation (<obj>)
##
DeclareOperation ("SaturatedFittingFormation", [IsObject]);


#############################################################################
##
#A  ResidualFunction (<class>)
##
##  if bound, stores a function for computing the <class>-residual of a given
##  group
##
DeclareAttribute ("ResidualFunction", IsGroupClass);


#############################################################################
##
#A  LocalDefinitionFunction (<class>)
##
##  if bound, stores a function for computing the f(p)-residuals of a given
##  group
##
DeclareAttribute ("LocalDefinitionFunction", IsGroupClass);


############################################################################
##
#E
##
