#############################################################################
##  
#W  testlib.g              The UnitLib package            Alexander Konovalov
#W                                                            Elena Yakimenko
##
#H  $Id: testlib.g,v 1.5 2007/03/13 18:18:54 alexk Exp $
##
#############################################################################

#############################################################################
##
##  UNITLIBTestLibrary()
##
##  This is a function to check the completeness of the library
##  (requires a UNIX environment)
##
UNITLIBTestLibrary := function()
local datapath, testresult, size, missing, n, libfile, s;

  datapath := Concatenation(
                GAPInfo.PackagesInfo.("unitlib")[1].InstallationPath, 
	        "/data/" );
  testresult := true;		

  for size in Filtered( [ 2 .. 243 ], IsPrimePowerInt) do

    missing := [];
    Print( NrSmallGroups(size), " group(s) of order ", size, "\n" );

    for n in [ 1 .. NrSmallGroups( size ) ] do

      Print( n, "\r");
      
      if IsPrimeInt( size ) then
        libfile := Concatenation( datapath, "primeord", 
		   "/u", String(size), "_", String(n) );
      else      
        libfile := Concatenation( datapath, String(size), 
		   "/u", String(size), "_", String(n) );
      fi;

      if size=128 then
        libfile := Concatenation( libfile, ".g.gz" );
      elif size=243 then
        libfile := Concatenation( libfile, ".gg" );
      else
        libfile := Concatenation( libfile, ".g" );
      fi;      

      if not IsExistingFile(libfile) then
        Add( missing, n );
	testresult := false;
      fi;
      
      if size=243 then
        s:=Curl( Concatenation( "http://www.cs.st-andrews.ac.uk/~alexk/",
                                "unitlib/data/243/u243_", String(n), ".txt" ) );
	# if we are non online, Curl will return empty string
	if s <> "" then		
	  # if the file is missing on the server, 
	  # we can not perform the next command 
          s:=IntHexString(s);
	fi;
      fi;

    od;

    if Length(missing) > 0 then
      Print( Length(missing), " missing groups for order ", size, " : ", missing, "\n");
    fi;
  od;
  if testresult then
    Print("Test finished successfully !!! \n");
  else
    Print("Test finished with problems !!! \n");
  fi;
end;


#############################################################################
##
#E
##