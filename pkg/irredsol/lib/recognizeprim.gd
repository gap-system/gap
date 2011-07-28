############################################################################
##
##  recognizeprim.gi              IRREDSOL                  Burkhard Höfling
##
##  @(#)$Id: recognizeprim.gd,v 1.1 2011/05/18 16:40:29 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


############################################################################
##
#F  RecognitionPrimitiveSolvableGroup(<G>)
##
DECLARE_IRREDSOL_FUNCTION ("RecognitionPrimitiveSolvableGroup");
    

###########################################################################
##
#A  IdPrimitiveSolvableGroup(<grp>)
#F  IdPrimitiveSolvableGroupNC(<grp>)
##
##  see IRREDSOL documentation
##  
DeclareAttribute ("IdPrimitiveSolvableGroup", IsGroup);
DECLARE_IRREDSOL_SYNONYMS ("IdPrimitiveSolvableGroup");
DECLARE_IRREDSOL_FUNCTION ("IdPrimitiveSolvableGroupNC");


############################################################################
##
#E
##
