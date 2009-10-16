#############################################################################
##  
#W  genlib.g               The UnitLib package            Alexander Konovalov
#W                                                            Elena Yakimenko
##
#H  $Id: genlib.g,v 1.3 2006/08/18 13:28:04 alexk Exp $
##
#############################################################################

# The following maintenance operations should be performed 
# for library files in the current directory
#
# To compress the library, use e.g. the following:
# gap> for i in [1..NrSmallGroups(256)] do
# >      filename := Concatenation( "u256_", String(i), ".g" );
# >      Exec( "gzip ", filename );
# >    od;
# gap>
#
# To uncompress the library, use e.g. the following:
# gap> for i in [1..NrSmallGroups(243)] do
# >      filename := Concatenation( "u243_", String(i), ".g.gz" );
# >      Exec( "gunzip ", filename );
# >    od;
# gap>
#
# To extract hexadecimal strings from the library do e.g. the following:
# for i in [1..NrSmallGroups(243)] do                                                
#   filein := Concatenation( "u243_", String(i), ".g" );                 
#   codestring:=ReadAsFunction(filein)()[1];
#   fileout := Concatenation( "u243_", String(i), ".txt" );  
#   output := OutputTextFile( fileout, false );                                               
#   SetPrintFormattingStatus( output, false );                                                
#   PrintTo( output, codestring );                                                          
#   CloseStream( output );          
# od; 		  
#
# To prepare locally stored files for groups or order 243:
# for i in [1..NrSmallGroups(243)] do                                                
#   filein := Concatenation( "u243_", String(i), ".g" );                 
#   codestring:=ReadAsFunction(filein)();
#   Unbind(codestring[1]);
#   fileout := Concatenation( "u243_", String(i), ".gg" );  
#   output := OutputTextFile( fileout, false );                                               
#   SetPrintFormattingStatus( output, false );                                                
#   PrintTo( output, "return ", codestring, ";" );
#   CloseStream( output );          
# od; 		  



#############################################################################
#
# CreatePcNormalizedUnitGroupsLibrary( n, n1 )
#
# The function creates library files for groups of prime-power order n,
# starting from SmallGroup( n, n1 ) 
#
CreatePcNormalizedUnitGroupsLibrary := function( n, n1 )
local i, G;
if not IsPrimePowerInt( n ) then
  Error("Size is not a power of a prime !!! \n");
fi;
if n1 > NrSmallGroups(n) then
  Error("There are only ", NrSmallGroups(n), " groups of order ", n, " !!! \n");
fi;
Print( "Generating library for ", NrSmallGroups( n ), " groups ... \n" );
for i in [ n1 .. NrSmallGroups( n ) ] do
  Print( i, "\r" );
  G := SmallGroup( n, i );
  SavePcNormalizedUnitGroup( G );
od;
Print( "\n" );
end;


#############################################################################
##
#E
##