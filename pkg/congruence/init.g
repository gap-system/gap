#############################################################################
##
#W init.g                  The Congruence package                   Ann Dooms
#W                                                               Eric Jespers
#W                                                        Alexander Konovalov
#W                                                             Helena Verrill
##
#H $Id: init.g,v 1.2 2007/04/29 17:51:34 alexk Exp $
##
#############################################################################

# read Congruence declarations
ReadPackage( "congruence/lib/cong.gd" );
ReadPackage( "congruence/lib/farey.gd" );

# read the other part of code
ReadPackage( "congruence/lib/cong.g" );
ReadPackage( "congruence/lib/buildman.g" );
ReadPackage( "congruence/lib/factor.g" );

# set the default InfoLevel
SetInfoLevel( InfoCongruence, 1 );