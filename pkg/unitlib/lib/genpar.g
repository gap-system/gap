#############################################################################
##  
#W  genpar.g               The UnitLib package            Alexander Konovalov
#W                                                            Elena Yakimenko
##
#H  $Id: genpar.g,v 1.4 2006/08/18 13:28:04 alexk Exp $
##
#############################################################################


#############################################################################
#
# ParCreatePcNormalizedUnitGroupsLibrary( unitlibsize, listofnumbers )
#
# The function generates library files in parallel mode. To use it,
# you must start ParGAP and then read the present file as in the example:
#
# gap> Read("~/gap4r4/pkg/unitlib/lib/genpar.g"); 
# gap> ParCreatePcNormalizedUnitGroupsLibrary(8, [ 1 .. NrSmallGroups(8) ] );
# Generating library for 5 groups of order 8 ... 
# Generating library for 5 groups of order 8 ... 
# Generating library for 5 groups of order 8 ... 
# master -> 1:  1
# master -> 2:  2
# 2 -> master: true
# master -> 2:  3
# 1 -> master: true
# master -> 1:  4
# 2 -> master: true
# master -> 2:  5
# 1 -> master: true
# 2 -> master: true
# [ true, true, true, true, true ]
# 
# Library files will be stored in the 'unitlib/userdata' directories on 
# appropriate computers, and you need to collect them afterwards.
#
ParInstallTOPCGlobalFunction( "ParCreatePcNormalizedUnitGroupsLibrary",
function( unitlibsize, listofnumbers )
local result;

if not IsPrimePowerInt( unitlibsize ) then
  Error("The first argument is not a power of a prime !!!");
fi;

if not IsSubset( [ 1 .. NrSmallGroups( unitlibsize ) ], listofnumbers ) then
  Error("There are only ", NrSmallGroups(unitlibsize), 
       " groups of order ", unitlibsize, " !!! \n");
fi;

Print( "Generating library for ", Length(listofnumbers), " groups of order ", 
                                  unitlibsize, " ... \n" );

   result := [];
   MasterSlave( TaskInputIterator( listofnumbers ),
		
                n -> SavePcNormalizedUnitGroup( SmallGroup( unitlibsize, n ) ),
                
		function( input, output )
		  AddSet( result, output );
                  return NO_ACTION; 
		end,
                
		Error
              );
   return result;
end );

#############################################################################
##
#E
##