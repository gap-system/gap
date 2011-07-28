#if TestPackageAvailability( "EDIM", "1.2.3" ) <> fail then 
#  RequirePackage( "EDIM" );
#  Read("edim.gi");
#fi;
#Display("check for n <> m...");

TimeToString := x -> x;

Read("misc.gi");;
Read("gauss.gi");
Read("echelon.gi");
Read("example.gi");
Read("snf.gi");
Read("msnf.gi");
Read("hensel.gi");
Read("solve.gi");
Read("homcyc.gi");
Read("block.gi");
Read("pabel.gi");
Read("checks.gi");
Read("rtimes.gi");
