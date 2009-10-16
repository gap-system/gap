#############################################################################
##
#W farey.gd                The Congruence package                   Ann Dooms
#W                                                               Eric Jespers
#W                                                        Alexander Konovalov
##
#H $Id: farey.gd,v 1.1 2007/04/27 20:08:38 alexk Exp $
##
#############################################################################


#############################################################################
##
## IsFareySymbol( <fs> )
##
DeclareCategory( "IsFareySymbol", IsObject );


#############################################################################
##
## FareySymbolByData( <gfs>, <labels> )
##
## This constructor creates Farey symbol with the given generalized Farey 
## sequence and list of labels. It also checks conditions from the definition
## of Farey symbol and returns an error if they are not satisfied
##
DeclareOperation( "FareySymbolByData", [ IsList, IsList ] );


#############################################################################
##
## GeneralizedFareySequence( <fs> )
## LabelsOfFareySymbol( <fs> )
##
## The data used to create the Farey symbol are stored as its attributes
##
DeclareAttribute( "GeneralizedFareySequence", IsFareySymbol );
DeclareAttribute( "LabelsOfFareySymbol", IsFareySymbol );


#############################################################################
##
## FareySymbol( <G> )
##
## For a subgroup of a finite index G, this attribute stores the 
## corresponding Farey symbol. The algorithm for its computation must work
## with any matrix group for which the membership test is available
## 
DeclareAttribute( "FareySymbol", IsMatrixGroup );


#############################################################################
#
# GeneratorsByFareySymbol( fs )
#
DeclareGlobalFunction( "GeneratorsByFareySymbol" );


#############################################################################
#
# IndexInPSL2ZByFareySymbol( fs )
#
# By the proposition 7.2 [Kulkarni], for the Farey symbol with underlying
# generalized Farey sequence { infinity, x0, x1, ..., xn, infinity }, the
# index in PSL_2(Z) is given by the formula d = 3*n + e3, where e3 is the 
# number of odd intervals.
#
DeclareGlobalFunction( "IndexInPSL2ZByFareySymbol" );


#############################################################################
##
#E
##
