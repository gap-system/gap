#############################################################################
##
#W    read.g            The GAP 4 package NQL                    René Hartung
##
#H   @(#)$Id: read.g,v 1.6 2009/07/02 12:53:41 gap Exp $
##

# problem with polycyclic's Igs vs. Cgs
USE_CANONICAL_PCS := true;

BindGlobal( "NQL_TEST_ALL", false);

ReadPackage( NQLPkgName, "gap/misc.gi");
ReadPackage( NQLPkgName, "gap/hnf.gi");
ReadPackage( NQLPkgName, "gap/initqs.gi");
ReadPackage( NQLPkgName, "gap/homs.gi");
ReadPackage( NQLPkgName, "gap/tails.gi");
ReadPackage( NQLPkgName, "gap/consist.gi");
ReadPackage( NQLPkgName, "gap/cover.gi");
ReadPackage( NQLPkgName, "gap/endos.gi");
ReadPackage( NQLPkgName, "gap/buildnew.gi");
ReadPackage( NQLPkgName, "gap/extqs.gi");
ReadPackage( NQLPkgName, "gap/quotsys.gi");
ReadPackage( NQLPkgName, "gap/nq.gi");
ReadPackage( NQLPkgName, "gap/nq_non.gi");
ReadPackage( NQLPkgName, "gap/lpres.gi");
ReadPackage( NQLPkgName, "gap/examples.gi");

# approximating the Schur multiplier
ReadPackage( NQLPkgName, "gap/schumu/schumu.gi" );

# approximating the outer automorphism group
ReadPackage( NQLPkgName, "gap/misc/autseq.gi" );

# parallel version of NQL's nilpotent quotient algorithm
if TestPackageAvailability( "ParGap", "1.1.2" ) <> fail then
  NQLPar_StoreResults := true;
  ReadPackage( NQLPkgName, "gap/pargap/misc.gi" );
  ReadPackage( NQLPkgName, "gap/pargap/consist.gi" );
  ReadPackage( NQLPkgName, "gap/pargap/induce.gi" );
  ReadPackage( NQLPkgName, "gap/pargap/pargap.gi" );
  ReadPackage( NQLPkgName, "gap/pargap/storing.gi" );
fi;
