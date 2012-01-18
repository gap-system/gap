#############################################################################
##
#W finite.gd               POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## constructive pc-sequences for finite matrix groups
##
#H  @(#)$Id: finite.gd,v 1.4 2011/09/23 13:36:32 gap Exp $
##
#Y 2003
##

#############################################################################
##
#F ClosureBasePcgs_word(pcgsN, g, gens, lim)
##
## Calculates a conPCS for <N,g>^gens
##
## Every arising group element is realized as a record
## containing the real element
## and the wordinformation corresponding to gens
##
DeclareGlobalFunction( "ClosureBasePcgs_word" );

#############################################################################
##
#F POL_Comm( g, h )..................... calculates the Comm for records of
##                                       group elements with word information
##
DeclareGlobalFunction( "POL_Comm" );

#############################################################################
##
#F CPCS_finite_word( gensOfG , b)
##
## Returns a constructive polycyclic sequence for G if G is polycyclic
## of derived length at most b and it returns fail if G is not
## polycyclic
##
## Every generator is a record which contains in
## .groupElement the group element and in
## .word the wordinformation corresponding to the gensOfG list
## This feature is important if gensOfG arise as the image under
## the p-congruence homomorphism.
##
##
DeclareGlobalFunction( "CPCS_finite_word" );

#############################################################################
##
#F CPCS_FinitePart(gens)........... constructive pc-sequ. for image of <gens>
##                                  under the p-congr. hom.
##
DeclareGlobalFunction( "CPCS_FinitePart" );

#############################################################################
##
#F POL_InverseWord(word)
##
##
DeclareGlobalFunction( "POL_InverseWord" );

#############################################################################
##
#F  ExtendedBasePcgsMod( pcgs, g, d ) . . . . . .. . . . . extend a base pcgs
##
##  g normalizes <pcgs> and we compute a new pcgs for <pcgs, g>.
##
DeclareGlobalFunction( "ExtendedBasePcgsMod" );

#############################################################################
##
#F  RelativeOrdersPcgs_finite( pcgs )
##
DeclareGlobalFunction( "RelativeOrdersPcgs_finite" );

#############################################################################
##
#F  ExponentvectorPcgs_finite( pcgs, g )
##
DeclareGlobalFunction( "ExponentvectorPcgs_finite" );

#############################################################################
##
#F  ExponentvectorPartPcgs( pcgs, g , index)
##
##  g = ...* pcgs.gens[index]^ExponentvectorPartPcgs * ...
##
DeclareGlobalFunction( "ExponentvectorPartPcgs" );

#############################################################################
##
#F ExtractIndexPart( word, index)
##
DeclareGlobalFunction( "ExtractIndexPart" );

#############################################################################
##
#F POL_SetPcPresentation(pcgs)
##
## pcgs is a constructive pc-sequence, calculated
## by ConstructivePcSequenceFinitePart
## this function calculates a PcPresentation for the Group described
## by pcgs
##
DeclareGlobalFunction( "POL_SetPcPresentation" );

#############################################################################
##
#F  POL_TestExpVector_finite( pcgs, g )
##
DeclareGlobalFunction( "POL_TestExpVector_finite" );

#############################################################################
##
#E
