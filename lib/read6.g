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
##
ReadSmall( "smallgrp.g" );


#############################################################################
##
#X  Read transitive groups library
##
ReadTrans( "trans.grp" );
