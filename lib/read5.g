#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#X  now read all the implementation parts
##

ReadLib( "type.gi"     );

ReadLib( "rvecempt.gi" );
ReadLib( "ratfun1.gi"  );
ReadLib( "matrix.gi"   );
ReadLib( "matint.gi"   );
ReadLib( "matblock.gi" );

ReadLib( "tuples.gi"   );

ReadLib( "domain.gi"   );
ReadLib( "mapping1.gi"  );
ReadLib( "mapping.gi"  );
ReadLib( "mapprep.gi"  );
ReadLib( "mapphomo.gi" );
ReadLib( "relation.gi" );

ReadLib( "magma.gi"    );
ReadLib( "mgmideal.gi" );
ReadLib( "mgmhom.gi"   );
ReadLib( "mgmadj.gi"   );
ReadLib( "mgmcong.gi"  );
ReadLib( "semigrp.gi"  );
ReadLib( "semicong.gi" );
ReadLib( "smgideal.gi" );
ReadLib( "monoid.gi"   );
ReadLib( "grp.gi"      );
ReadLib( "invsgp.gi"   );

ReadLib( "addmagma.gi" );
ReadLib( "addcoset.gi" );

ReadLib( "ring.gi"     );
ReadLib( "ideal.gi"    );

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
ReadLib( "mgmring.gi"  );

ReadLib( "algebra.gi"  );
ReadLib( "idealalg.gi" );
ReadLib( "alghom.gi"   );
ReadLib( "algfp.gi"    );
ReadLib( "alglie.gi"   );
ReadLib( "algliess.gi" );
ReadLib( "algsc.gi"    );
ReadLib( "algmat.gi"   );
ReadLib( "liefam.gi"   );
ReadLib( "algrep.gi"   );
ReadLib( "lierep.gi"   );

ReadLib( "numtheor.gi" );
ReadLib( "dlog.gi" );
ReadLib( "primality.gi");
ReadLib( "contfrac.gi" );
ReadLib( "ringsc.gi"    );
ReadLib( "ringhom.gi"    );

ReadLib( "combinat.gi" );

ReadLib( "ratfun.gi"   );
ReadLib( "ratfunul.gi" );
ReadLib( "ringpoly.gi" );
ReadLib( "upoly.gi"    );
ReadLib( "upolyirr.gi" );
ReadLib( "polyfinf.gi" );
ReadLib( "polyrat.gi"  );
ReadLib( "polyconw.gi" );
ReadLib( "listcoef.gi" );
ReadLib( "algfld.gi"   );
ReadLib( "groebner.gi" );

ReadLib( "unknown.gi"  );

ReadLib( "field.gi"    );
ReadLib( "fieldfin.gi" );
ReadLib( "zmodnz.gi"   );
ReadLib( "zmodnze.gi"  );
ReadLib( "ffe.gi"      );
ReadLib( "ffeconway.gi");
ReadLib( "rational.gi" );
ReadLib( "gaussian.gi" );
ReadLib( "cyclotom.gi" );
ReadLib( "fldabnum.gi" );
ReadLib( "padics.gi"   );

ReadLib( "matobj.gi"   );
ReadLib( "matrobjrowlist.gi"   );
ReadLib( "vecmat.gi"   );
ReadLib( "vec8bit.gi"  );
ReadLib( "mat8bit.gi"  );
ReadLib( "matobjplist.gi" );
ReadLib( "matobjnz.gi" );
ReadLib( "meataxe.gi"  );
ReadLib( "meatauto.gi" );

ReadLib( "word.gi"     );
ReadLib( "wordass.gi"  );
ReadLib( "wordrep.gi"  );
ReadLib( "wordlett.gi" );


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
ReadLib( "nilpquot.gi");
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

# files dealing with trees and hash tables
ReadLib( "bitfields.gi" );
ReadLib( "dict.gi"  );
ReadLib( "dicthf.gi"  );

ReadLib( "grptbl.gi"   );

ReadLib( "ghom.gi"     );
ReadLib( "ghompcgs.gi" );
ReadLib( "gprd.gi"     );
ReadLib( "ghomperm.gi" );
ReadLib( "grpperm.gi"  );
ReadLib( "gpprmsya.gi" );
ReadLib( "gprdperm.gi" );
ReadLib( "gprdpc.gi"   );
ReadLib( "gprdmat.gi" );
ReadLib( "oprt.gi"     );
ReadLib( "oprtperm.gi" );
ReadLib( "oprtpcgs.gi" );
ReadLib( "partitio.gi" );
ReadLib( "stbc.gi"     );
ReadLib( "stbcbckt.gi" );
ReadLib( "stbcrand.gi" );
ReadLib( "clas.gi"     );
ReadLib( "claspcgs.gi" );
ReadLib( "csetgrp.gi"  );
ReadLib( "csetperm.gi" );
ReadLib( "csetpc.gi"   );
ReadLib( "factgrp.gi"  );
ReadLib( "grpreps.gi" );
ReadLib( "grppcrep.gi" );
ReadLib( "grpprmcs.gi" );

ReadLib( "grpnames.gi" );

ReadLib( "onecohom.gi" );
ReadLib( "grppccom.gi" );
ReadLib( "grpcompl.gi" );

# files dealing with extensions
ReadLib( "twocohom.gi" );
ReadLib( "grppcext.gi");
ReadLib( "randiso.gi");
ReadLib( "randiso2.gi");
ReadLib( "grppcfp.gi");

ReadLib( "schur.gi");
ReadLib( "schursym.gi");

# files dealing with nice monomorphism
ReadLib( "grpnice.gi"  );

# fitting free library
ReadLib( "fitfree.gi"  );
ReadLib( "permdeco.gi" );
ReadLib( "clashom.gi"  );
ReadLib( "clasperm.gi" );
ReadLib( "maxsub.gi"   );
ReadLib( "norad.gi"    );

ReadLib( "autsr.gi"    );
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
ReadLib( "grpfp.gi"  );
ReadLib( "gpfpiso.gi");
ReadLib( "sgpres.gi" );
ReadLib( "tietze.gi" );
ReadLib( "ghomfp.gi" );

ReadLib( "addgphom.gi" );

# files dealing with semigroups - second layer
ReadLib( "trans.gi");
ReadLib("pperm.gi");
ReadLib( "fastendo.gi");
ReadLib( "fpsemi.gi");
ReadLib( "fpmon.gi");
ReadLib( "rwssmg.gi");
ReadLib( "kbsemi.gi");
ReadLib( "tcsemi.gi");
ReadLib( "adjoin.gi");
ReadLib( "semirel.gi");
ReadLib( "semitran.gi");
ReadLib( "reesmat.gi");
ReadLib("semiquo.gi");
ReadLib( "semipperm.gi");

# prototyping utilities
ReadLib( "proto.gi");

ReadLib( "orders.gi");

ReadLib( "gasman.gi");

ReadLib("memusage.gi");

ReadLib( "function.gi");

# floateans, now really install all handlers
ReadLib( "float.gi" );
ReadLib( "ieee754.g" );
