#############################################################################
##
#X  group library
##
ReadGrp( "basicpcg.gi" );
ReadGrp( "basicprm.gi" );
ReadGrp( "basicmat.gi" );
ReadGrp( "perf.grp"    );
ReadGrp( "classic.gi" );


#############################################################################
##
#X  Read library of groups of order up to 1000 without 512 and 768
#X  Read identification routine
##
ReadSmall( "smallgrp.g" );
ReadSmall( "idgroup.g" );

#############################################################################
##
#X  Read transitive groups library
##
ReadTrans( "trans.grp" );


#############################################################################
##
#X  Read primitive groups library
##
ReadPrim( "irredsol.grp" );
ReadPrim( "primitiv.gi" );
