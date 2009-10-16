#############################################################################
##
#W    init.g               GAP 4 package NQL                     Rene Hartung  
##
#H   @(#)$Id: init.g,v 1.5 2009/07/02 12:53:41 gap Exp $
##

############################################################################
## 
## Put the name of the package into a single variable. This makes it 
## easier to change it to something else if necessary.
##
NQLPkgName:="NQL";

############################################################################
##
##    Declare the package and test for the existence of the package 
##    polycyclic.
##
DeclarePackage( NQLPkgName , "0.0",
  function()
    
    if TestPackageAvailability( "polycyclic", "1.0" ) = fail then
      Info( InfoWarning, 1, 
           "Loading the NQL package: package polycyclic must be available" );
      return fail;
    fi;

    return true;
end );

# install the documentation
DeclarePackageDocumentation( NQLPkgName, "doc", "NQL", 
        "Computation of nilpotent quotients" );


############################################################################
## 
#D Require other packages (polycyclic)
##
if IsList( TestPackageAvailability( "polycyclic", "1.0" ) ) then
    HideGlobalVariables( "BANNER" );
    BANNER := false;
    LoadPackage( "polycyclic" );
    UnhideGlobalVariables( "BANNER" );
fi;

############################################################################
##
#D Read .gd files
##
ReadPkg( NQLPkgName, "gap/lpres.gd");
ReadPkg( NQLPkgName, "gap/hnf.gd");
ReadPkg( NQLPkgName, "gap/initqs.gd");
ReadPkg( NQLPkgName, "gap/homs.gd");
ReadPkg( NQLPkgName, "gap/tails.gd");
ReadPkg( NQLPkgName, "gap/consist.gd");
ReadPkg( NQLPkgName, "gap/cover.gd");
ReadPkg( NQLPkgName, "gap/endos.gd");
ReadPkg( NQLPkgName, "gap/buildnew.gd");
ReadPkg( NQLPkgName, "gap/extqs.gd");
ReadPkg( NQLPkgName, "gap/misc.gd");
ReadPkg( NQLPkgName, "gap/quotsys.gd");
ReadPkg( NQLPkgName, "gap/nq.gd");
ReadPkg( NQLPkgName, "gap/nq_non.gd");
ReadPkg( NQLPkgName, "gap/examples.gd");

# approximating the Schur multiplier
ReadPkg( NQLPkgName, "gap/schumu/schumu.gd" );

# approximating the outer automorphism group
ReadPkg( NQLPkgName, "gap/misc/autseq.gd" );

# parallel version of NQL's nilpotent quotient algorithm
if TestPackageAvailability( "ParGap", "1.1.2" ) <> fail then
  ReadPkg( NQLPkgName, "gap/pargap/pargap.gd" );
fi;
