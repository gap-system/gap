#############################################################################
##
#W  init.g                   Sophus package                   Csaba Schneider 
##
#H  $Id: init.g,v 1.11 2006/01/23 14:34:59 gap Exp $

DeclareAutoPackage( "Sophus", "1.22", 
  function()
    if not CompareVersionNumbers( VERSION, "4.3fix4" ) then
      Info( InfoWarning, 1, "This version of the Sophus package requires ",
                            "at least GAP 4.3fix4" );
      return fail;
    fi;
    return true;
  end );

DeclareInfoClass( "LieInfo" );

FIND_MIN_GEN_SET := false;

ReadPackage( "Sophus", "gap/sophus.gd" );  
