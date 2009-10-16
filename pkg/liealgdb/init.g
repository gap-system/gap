#############################################################################
##
#W  init.g                liealgdb package                   Csaba Schneider 
##
#H  $Id: 

DeclareAutoPackage( "liealgdb", "2.0.2", 
  function()
    if not CompareVersionNumbers( VERSION, "4.4" ) then
      Info( InfoWarning, 1, "This version of the liealgdb package requires ",
                            "at least GAP 4.4" );
      return fail;
    fi;
    return true;
  end );
  
#general stuff
ReadPackage( "liealgdb", "gap/liealgdb.gd" );

# SLAC:
ReadPackage( "liealgdb", "gap/slac/slac.gd" );

#nilpotent
ReadPackage( "liealgdb", "gap/nilpotent/nilpotent.gd" );
 
#Non-solvable
ReadPackage( "liealgdb", "gap/nonsolv/nonsolv.gd" );





