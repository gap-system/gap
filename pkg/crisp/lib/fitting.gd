#############################################################################
##
##  fitting.gd                      CRISP                    Burkhard Höfling
##
##  @(#)$Id: fitting.gd,v 1.3 2011/05/15 19:17:53 gap Exp $
##
##  Copyright (C) 2000 Burkhard Höfling
##
Revision.fitting_gd :=
    "@(#)$Id: fitting.gd,v 1.3 2011/05/15 19:17:53 gap Exp $";


#############################################################################
##
#F  IsFittingClass (<group class>) 
##
DeclareSynonym ("IsFittingClass", 
   ContainsTrivialGroup and IsGroupClass and IsNormalSubgroupClosed 
   and IsNormalProductClosed);


#############################################################################
##
#F  HasIsFittingClass (<group class>) 
##
DeclareSynonym ("HasIsFittingClass", 
   HasContainsTrivialGroup and HasIsGroupClass and HasIsNormalSubgroupClosed 
   and HasIsNormalProductClosed);


#############################################################################
##
#F  SetIsFittingClass (<group class>)
##
DeclareGlobalFunction ("SetIsFittingClass");


#############################################################################
##
#O  FittingClass (<obj>)
##
DeclareOperation ("FittingClass", [IsObject]);


#############################################################################
##
#O  FittingProduct (<fit1>, <fit2>)
##
DeclareOperation ("FittingProduct", [IsFittingClass, IsFittingClass]);


#############################################################################
##
#O  FittingSet (<grp>, <obj>)
##
DeclareOperation ("FittingSet", [IsGroup, IsObject]);


#############################################################################
##
#O  IsFittingSet (<grp>, <obj>)
##
##  decides if the subgroups of <grp> contained in <obj> form a 
##  Fitting set of <grp>
##
DeclareOperation ("IsFittingSet", [IsGroup, IsObject]);


#############################################################################
##
#O  ImageFittingSet (<hom>, <fitset>)
##
##  constructs a Fitting set of Image (hom) from the Fitting set
##  <fitset> of PreImage (hom).
##
DeclareOperation ("ImageFittingSet", [IsGeneralMapping, IsClass]);


#############################################################################
##
#O  PreImageFittingSet (<hom>, <fitset>)
##
##  constructs a Fitting set of PreImage (hom) from the Fitting set
##  <fitset> of Image (hom).
##
DeclareOperation ("PreImageFittingSet", [IsGeneralMapping, IsClass]);


#############################################################################
##
#A  InjectorFunction (<class>)
##
##  if bound, stores a function for computing a <class>-injector of a given
##  group
##
DeclareAttribute ("InjectorFunction", IsClass);


#############################################################################
##
#A  RadicalFunction (<class>)
##
##  if bound, stores a function for computing the <class>-radical of a given
##  group
##
DeclareAttribute ("RadicalFunction", IsClass);


############################################################################
##
#E
##
