#############################################################################
##
#X  now read all the implementation parts
##
ReadLib( "listcoef.gi" );

ReadLib( "rvecempt.gi" );
ReadLib( "matrix.gi"   );
ReadLib( "matint.gi"   );
ReadLib( "matblock.gi" );

ReadLib( "tuples.gi"   );


ReadLib( "domain.gi"   );
ReadLib( "mapping.gi"  );
ReadLib( "mapprep.gi"  );
ReadLib( "mapphomo.gi" );
ReadLib( "relation.gi");

ReadLib( "magma.gi"    );
ReadLib( "mgmideal.gi"    );
ReadLib( "mgmhom.gi");
ReadLib( "mgmadj.gi"    );
ReadLib( "mgmcong.gi");
ReadLib( "semigrp.gi"  );
ReadLib( "semicong.gi"  );
ReadLib( "smgideal.gi"  );
ReadLib( "monoid.gi"   );
ReadLib( "grp.gi"      );

ReadLib( "addmagma.gi" );
ReadLib( "addcoset.gi" );

ReadLib( "ring.gi"     );
ReadLib( "ideal.gi"    );
ReadLib( "mgmring.gi"  );

ReadLib( "module.gi"   );
ReadLib( "modfree.gi"  );
ReadLib( "modulrow.gi" );
ReadLib( "modulmat.gi" );
ReadLib( "basis.gi"    );
ReadLib( "basismut.gi" );
ReadLib( "vspc.gi"     );
ReadLib( "vspcrow.gi"  );
ReadLib( "vspcmat.gi"  );
ReadLib( "vspchom.gi"  );
ReadLib( "zlattice.gi" );

ReadLib( "algebra.gi"  );
ReadLib( "idealalg.gi" );
ReadLib( "alghom.gi"   );
ReadLib( "algfp.gi"    );
ReadLib( "alglie.gi"   );
ReadLib( "algliess.gi" );
ReadLib( "algsc.gi"    );
ReadLib( "algmat.gi"   );
ReadLib( "liefam.gi"   );

ReadLib( "integer.gi"  );
ReadLib( "numtheor.gi" );
ReadLib( "string.gi"   );

ReadLib( "ratfun.gi"   );
ReadLib( "ratfunul.gi" );
ReadLib( "ringpoly.gi" );
ReadLib( "upoly.gi"    );
ReadLib( "upolyirr.gi" );
ReadLib( "polyfinf.gi" );
ReadLib( "polyrat.gi"  );
ReadLib( "polyconw.gi" );
ReadLib( "algfld.gi"   );

ReadLib( "unknown.gi"  );

ReadLib( "field.gi"    );
ReadLib( "fieldfin.gi" );
ReadLib( "zmodnz.gi"   );
ReadLib( "ffe.gi"      );
ReadLib( "rational.gi" );
ReadLib( "gaussian.gi" );
ReadLib( "cyclotom.gi" );
ReadLib( "fldabnum.gi" );
ReadLib( "padics.gi"   );

ReadLib( "vecmat.gi"   );
ReadLib( "vec8bit.gi"  );
ReadLib( "meataxe.gi"  );

ReadLib( "word.gi"     );
ReadLib( "wordass.gi"  );
ReadLib( "wordrep.gi"  );


# files dealing with free magmas, semigroups, monoids, groups
ReadLib( "mgmfree.gi"  );
ReadLib( "smgrpfre.gi" );
ReadLib( "monofree.gi" );
ReadLib( "grpfree.gi"  );


# files dealing with rewriting systems
ReadLib( "rws.gi"      );
ReadLib( "rwspcclt.gi" );
ReadLib( "rwspcsng.gi" );
ReadLib( "rwspccoc.gi" );
ReadLib( "rwsgrp.gi"   );
ReadLib( "rwspcgrp.gi" );
ReadLib( "rwsdt.gi" );

# files dealing with quotient systems
ReadLib( "pquot.gi");

# files dealing with polycyclic generating systems
ReadLib( "pcgs.gi"     );
ReadLib( "pcgsind.gi"  );
ReadLib( "pcgsmodu.gi" );
ReadLib( "pcgspcg.gi"  );
ReadLib( "pcgscomp.gi" );
ReadLib( "pcgsperm.gi" );
ReadLib( "pcgsnice.gi" );
ReadLib( "pcgsspec.gi" );


# files dealing with finite polycyclic groups
ReadLib( "grppc.gi"    );
ReadLib( "grppcint.gi" );
ReadLib( "grppcprp.gi" );
ReadLib( "grppcatr.gi" );
ReadLib( "grppcnrm.gi" );

ReadLib( "grptbl.gi"   );

ReadLib( "ghom.gi"     );
ReadLib( "ghompcgs.gi" );
ReadLib( "gprd.gi"     );
ReadLib( "ghomperm.gi" );
ReadLib( "grpperm.gi"  );
ReadLib( "gpprmsya.gi" );
ReadLib( "gprdperm.gi" );
ReadLib( "gprdpc.gi"   );
ReadLib( "oprt.gi"     );
ReadLib( "oprtperm.gi" );
ReadLib( "oprtpcgs.gi" );
ReadLib( "partitio.gi" );
ReadLib( "stbc.gi"     );
ReadLib( "stbcbckt.gi" );
ReadLib( "stbcrand.gi" );
ReadLib( "clas.gi"     );
ReadLib( "claspcgs.gi" );
ReadLib( "clasperm.gi" );
ReadLib( "clashom.gi"  );
ReadLib( "csetgrp.gi"  );
ReadLib( "csetperm.gi" );
ReadLib( "csetpc.gi"   );
ReadLib( "factgrp.gi"  );
ReadLib( "grpreps.gi" );
ReadLib( "grppcrep.gi" );
ReadLib( "grpprmcs.gi" );

ReadLib( "onecohom.gi" );
ReadLib( "grppccom.gi" );
ReadLib( "grpcompl.gi" );

# files dealing with extensions
ReadLib( "twocohom.gi" );
ReadLib( "grppcext.gi");
ReadLib( "randiso.gi");
ReadLib( "randiso2.gi");
ReadLib( "grppcfp.gi");

# files dealing with nice monomorphism
ReadLib( "grpnice.gi"  );

ReadLib( "morpheus.gi" );
ReadLib( "grplatt.gi"  );
ReadLib( "oprtglat.gi" );
ReadLib( "grppclat.gi" );

ReadLib( "grppcaut.gi" );


# files dealing with matrix groups
ReadLib( "grpmat.gi"   );
ReadLib( "grpffmat.gi" );
ReadLib( "grpramat.gi" );


# files dealing with fp groups
ReadLib( "grpfp.gi"    );
ReadLib( "sgpres.gi" );
ReadLib( "tietze.gi" );


# files dealing with trees and hash tables
ReadLib( "hash.gi"     );

# files dealing with semigroups - second layer
ReadLib( "trans.gi");
ReadLib( "fpsemi.gi");
ReadLib( "kbsemi.gi");
ReadLib( "tcsemi.gi");
ReadLib( "semirel.gi");
ReadLib( "semitran.gi");
ReadLib( "fpcomsmg.gi");
ReadLib( "reesmat.gi");
ReadLib("semiquo.gi");
ReadLib( "inflist.gi"); 

# Robert's test package
ReadLib("monotran.gi");
