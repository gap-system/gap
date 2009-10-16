#############################################################################
##
#W    read.g                 The Nilmat package                  Bettina Eick
##
##    @(#)$Id: read.g,v 1.1 2007/05/23 12:49:43 gap Exp $
##

#############################################################################
##
#R  Two files of the library need recent bugfixes to work correctly with the
#R  package. This can be removed after the next release/update of GAP.
##
#ReadPackage( "nilmat", "etc/ffe.gi" );        # bugfixes in lib
#ReadPackage( "nilmat", "etc/ffeconway.gi" );  # bugfixes in lib

#############################################################################
##
#R  Read the installed files.
##
ReadPackage( "nilmat", "gap/nilpotency.gi" ); # test nilpotency (FF/Q)
ReadPackage( "nilmat", "gap/finiteness.gi" ); # IsFinite and Size (FF/Q)
ReadPackage( "nilmat", "gap/sylow.gi" );      # Sylow subgroups (FF)
ReadPackage( "nilmat", "gap/maxgroup.gi" );   # maximal abs irr groups (FF)
ReadPackage( "nilmat", "gap/examples.gi" );   # nilpotent red groups (FF/Q)
ReadPackage( "nilmat", "gap/primitive.gi" );  # library of primitive groups
