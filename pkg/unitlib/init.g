#############################################################################
##  
#W  init.g                 The UnitLib package            Alexander Konovalov
#W                                                            Elena Yakimenko
##
#H  $Id: init.g,v 1.3 2009/05/31 20:21:26 alexk Exp $
##
#############################################################################

# read function declarations
ReadPackage("unitlib/lib/unitlib.gd");

# read actual code function(s)
ReadPackage("unitlib/lib/unitlib.g");
ReadPackage("unitlib/lib/buildman.g");

if LoadPackage( "scscp" ) = true then
  if CompareVersionNumbers( GAPInfo.PackagesInfo.("scscp")[1].Version, "1.1.4" ) then
  	ReadPackage("unitlib/lib/parunits.g");
  fi;	
fi;

if not ARCH_IS_UNIX() then
  Print("UnitLib package : libraries of normalized unit groups \n", 
        "of modular group algebras of groups of order 128 and 243 \n",
	"is not available because of non-UNIX operating system !!! \n");
fi;
