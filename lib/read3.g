#############################################################################
##
#X  now read all the definition parts
##
ReadLib( "tuples.gd"   );

ReadLib( "rvecempt.gd" );
ReadLib( "matrix.gd"   );
ReadLib( "matint.gd"   );
ReadLib( "matblock.gd" );

ReadLib( "domain.gd"   );
ReadLib( "extaset.gd"  );
ReadLib( "extlset.gd"  );
ReadLib( "extrset.gd"  );
ReadLib( "extuset.gd"  );

ReadLib( "mapping.gd"  );
ReadLib( "mapphomo.gd" );

ReadLib( "magma.gd"    );
ReadLib( "semigrp.gd"  );
ReadLib( "monoid.gd"   );
ReadLib( "grp.gd"      );

ReadLib( "addmagma.gd" );
ReadLib( "addcoset.gd" );
ReadLib( "ring.gd"     );
ReadLib( "ideal.gd"    );
ReadLib( "module.gd"   );
ReadLib( "basis.gd"    );
ReadLib( "basismut.gd" );
ReadLib( "vspc.gd"     );
ReadLib( "vspchom.gd"  );
ReadLib( "zlattice.gd" );
ReadLib( "algebra.gd"  );
ReadLib( "mgmring.gd"  );
ReadLib( "algfp.gd"    );
ReadLib( "alglie.gd"   );
ReadLib( "algsc.gd"    );
ReadLib( "alghom.gd"   );
ReadLib( "liefam.gd"   );
ReadLib( "integer.gd"  );
ReadLib( "numtheor.gd" );
ReadLib( "string.gd"   );

ReadLib( "ratfun.gd"   );

ReadLib( "field.gd"    );
ReadLib( "zmodnz.gd"   );
ReadLib( "cyclotom.gd" );
ReadLib( "fldabnum.gd" );
ReadLib( "padics.gd"   );
ReadLib( "ringpoly.gd" );
ReadLib( "upoly.gd"    );
ReadLib( "polyrat.gd"  );
ReadLib( "polyconw.gd" );
ReadLib( "algfld.gd"   );

ReadLib( "unknown.gd"  );

ReadLib( "word.gd"     );
ReadLib( "wordass.gd"  );


# files dealing with rewriting systems
ReadLib( "rws.gd"      );
ReadLib( "rwspcclt.gd" );
ReadLib( "rwsgrp.gd"   );
ReadLib( "rwspcgrp.gd" );


# files dealing with polycyclic generating systems
ReadLib( "pcgs.gd"     );
ReadLib( "pcgsind.gd"  );
ReadLib( "pcgspcg.gd"  );
ReadLib( "pcgsmodu.gd" );
ReadLib( "pcgsperm.gd" );
ReadLib( "pcgsspec.gd" );


# files dealing with finite polycyclic groups
ReadLib( "grppc.gd"    );
ReadLib( "grppcnrm.gd" );

ReadLib( "grptbl.gd"   );

ReadLib( "grpperm.gd"  );
ReadLib( "grpprmcs.gd" );
ReadLib( "stbcbckt.gd" );
ReadLib( "ghom.gd"     );
ReadLib( "ghompcgs.gd" );
ReadLib( "gprd.gd"     );
ReadLib( "ghomperm.gd" );
ReadLib( "gpprmsya.gd" );

# family predicates (needed for all 'InstallMethod' and oprt.gd)
ReadLib( "fampred.g"   );

ReadLib( "oprt.gd"     );
ReadLib( "stbc.gd"     );
ReadLib( "clas.gd"     );
ReadLib( "csetgrp.gd"  );
ReadLib( "factgrp.gd"  );
ReadLib( "grpreps.gd" );
ReadLib( "grppcrep.gd" );

ReadLib( "onecohom.gd" );
ReadLib( "grppccom.gd" );

ReadLib( "twocohom.gd" );
ReadLib( "grppcext.gd");
ReadLib( "grppcfp.gd");
ReadLib( "randiso.gd");
ReadLib( "fratfree.gd");
ReadLib( "frattext.gd");

ReadLib( "morpheus.gd" );
ReadLib( "grplatt.gd"  );
ReadLib( "oprtglat.gd" );
ReadLib( "grppclat.gd" );

ReadLib( "grppcaut.gd" );

# files dealing with fp groups
ReadLib( "grpfp.gd"    );
ReadLib( "grpfree.gd"  );
ReadLib( "sgpres.gd" );
ReadLib( "tietze.gd" );


# files dealing with trees and hash tables
ReadLib( "hash.gd"     );


# files needed for deep thought
ReadLib( "dt.g" );


ReadLib( "list.gi"     ); # was too early
ReadLib( "wpobj.gi"    );


# files dealing with nice monomorphism
# grpnice uses some family predicates, so fampred.g must be known
ReadLib( "grpnice.gd"  );


# files dealing with matrix groups (grpffmat.gd needs grpnice.gd)
ReadLib( "grpmat.gd"   );
ReadLib( "grpffmat.gd" );
ReadLib( "grpramat.gd" );

# group library
ReadGrp( "basic.gd"    );
ReadGrp( "perf.gd"     );
