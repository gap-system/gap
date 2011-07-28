############################################################################
##
##  access.gd                    IRREDSOL                  Burkhard Höfling
##
##  @(#)$Id: obsolete.gd,v 1.2 2011/04/07 07:58:09 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


############################################################################
##
#F  IndicesAbsolutelyIrreducibleSolvableMatrixGroups(<n>, <q>)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("IndicesAbsolutelyIrreducibleSolvableMatrixGroups");


############################################################################
##
#F  AbsolutelyIrreducibleSolvableMatrixGroup(<n>, <q>, <k>)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("AbsolutelyIrreducibleSolvableMatrixGroup");


############################################################################
##
#F  RecognitionAbsolutelyIrreducibleSolvableMatrixGroup(G, wantmat, wantgroup)
##
##  see the IRREDSOL manual
##
DeclareGlobalFunction ("RecognitionAbsolutelyIrreducibleSolvableMatrixGroup");


############################################################################
##
#F  RecognitionAbsolutelyIrreducibleSolvableMatrixGroupNC(G, wantmat, wantgroup)
##
##  see the IRREDSOL manual
##
DeclareGlobalFunction ("RecognitionAbsolutelyIrreducibleSolvableMatrixGroupNC");


############################################################################
##
#A  IdAbsolutelyIrreducibleSolvableMatrixGroup(<G>)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("IdAbsolutelyIrreducibleSolvableMatrixGroup");
   

############################################################################
##
#F  PrimitivePermutationGroupIrreducibleMatrixGroup(<G>)
#F  PrimitivePermutationGroupIrreducibleMatrixGroupNC(<G>)
##
##  see IRREDSOL documentation
##  
DECLAE_IRREDSOL_OBSOLETE ("PrimitivePermutationGroupIrreducibleMatrixGroup", 
    "PrimitivePermGroupIrreducibleMatrixGroup");
DECLAE_IRREDSOL_OBSOLETE ("PrimitivePermutationGroupIrreducibleMatrixGroupNC", 
    "PrimitivePermGroupIrreducibleMatrixGroupNC");
    
############################################################################
##
#F  PrimitiveSolvablePermutationGroup(<n>,<q>,<d>,<k>)
##
##  see IRREDSOL documentation
##  
DECLAE_IRREDSOL_OBSOLETE ("PrimitiveSolvablePermutationGroup", 
    "PrimitiveSolvablePermGroup");

###########################################################################
##
#F  IteratorPrimitiveSolvablePermutationGroups(<arg>)
##
##  see IRREDSOL documentation
##  
DECLAE_IRREDSOL_OBSOLETE ("IteratorPrimitiveSolvablePermutationGroups", 
    "IteratorPrimitiveSolvablePermGroups");

###########################################################################
##
#F  AllPrimitiveSolvablePermutationGroups(<arg>)
##
##  see IRREDSOL documentation
##  
DECLAE_IRREDSOL_OBSOLETE ("AllPrimitiveSolvablePermutationGroups", 
    "AllPrimitiveSolvablePermGroups");


###########################################################################
##
#F  OnePrimitiveSolvablePermutationGroup(<arg>)
##
##  see IRREDSOL documentation
##  
DECLAE_IRREDSOL_OBSOLETE ("OnePrimitiveSolvablePermutationGroup", 
    "OnePrimitiveSolvablePermGroup");



############################################################################
##
#E
##
