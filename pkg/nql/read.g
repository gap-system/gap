#############################################################################
##
#W    read.g            The GAP 4 package NQL                    René Hartung
##
#H   @(#)$Id: read.g,v 1.7 2010/03/17 13:09:28 gap Exp $
##

# problem with polycyclic's Igs vs. Cgs
USE_CANONICAL_PCS := true;

BindGlobal( "NQL_TEST_ALL", false);

# coset enumeration for (finite index) subgroups of LpGroups
NQL_TCSTART := 2;
if TestPackageAvailability( "ACE", "5.0" ) <> fail then
  NQL_CosetEnumerator := function( h )
    local f, rels, gens;

    f    := FreeGeneratorsOfFpGroup( Parent( h ) );
    rels := RelatorsOfFpGroup( Parent( h ) );
    gens := List( GeneratorsOfGroup( h ), UnderlyingElement );
    return( ACECosetTable( f, rels, gens : silent, hard, max := 10^8, Wo := 10^8 ) );
    end;
else
  NQL_CosetEnumerator := CosetTableInWholeGroup;
fi;


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
ReadPackage( NQLPkgName, "gap/subgrps.gi" );
ReadPackage( NQLPkgName, "gap/examples.gi");

# approximating the Schur multiplier
ReadPackage( NQLPkgName, "gap/schumu/schumu.gi" );

# approximating the outer automorphism group
if TestPackageAvailability( "AutPGrp", "1.4" ) <> fail then 
  ReadPackage( NQLPkgName, "gap/misc/autseq.gi" );
fi;

# parallel version of NQL's nilpotent quotient algorithm
if TestPackageAvailability( "ParGap", "1.1.2" ) <> fail then
  NQLPar_StoreResults := true;
  ReadPackage( NQLPkgName, "gap/pargap/misc.gi" );
  ReadPackage( NQLPkgName, "gap/pargap/consist.gi" );
  ReadPackage( NQLPkgName, "gap/pargap/induce.gi" );
  ReadPackage( NQLPkgName, "gap/pargap/pargap.gi" );
  ReadPackage( NQLPkgName, "gap/pargap/storing.gi" );
fi;

