#############################################################################
##
#W  init.g                liealgdb package                   Csaba Schneider 
##
#H  $Id: 

DeclareAutoPackage( "algaut", "0.1", 
  function()
    if not CompareVersionNumbers( VERSION, "4.3fix4" ) then
      Info( InfoWarning, 1, "This version of the algaut package requires ",
                            "at least GAP 4.3fix4" );
      return fail;
    fi;
    return true;
  end );
  
ReadPkg( "algaut", "gap/bimodule.gd" );
ReadPkg( "algaut", "gap/bimod.gi" );  
ReadPkg( "algaut", "gap/autgrp.gi" );
ReadPkg( "algaut", "gap/compat.gi" );


