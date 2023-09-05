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
#X  now read all the definition parts
##
ReadLib( "type.gd"     );
ReadLib( "tuples.gd"   );
ReadLib( "rvecempt.gd" );

ReadLib( "extaset.gd"  );
ReadLib( "extlset.gd"  );
ReadLib( "extrset.gd"  );
ReadLib( "extuset.gd"  );

ReadLib( "dict.gd"     );
ReadLib( "bitfields.gd" );

ReadLib( "mapping.gd"  );
ReadLib( "mapphomo.gd" );
ReadLib( "relation.gd");

ReadLib( "magma.gd"    );
ReadLib( "mgmideal.gd" );
ReadLib( "mgmhom.gd"   );
ReadLib( "mgmadj.gd"   );
ReadLib( "mgmcong.gd"  );
ReadLib( "semicong.gd" );
ReadLib( "semigrp.gd"  );
ReadLib( "smgideal.gd" );
ReadLib( "monoid.gd"   );
ReadLib( "grp.gd"      );
ReadLib( "invsgp.gd"   );

ReadLib( "addmagma.gd" );
ReadLib( "addcoset.gd" );
ReadLib( "semiring.gd" );
ReadLib( "ring.gd"     );
ReadLib( "matrix.gd"   );
ReadLib( "matint.gd"   );
ReadLib( "matblock.gd" );
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
ReadLib( "algrep.gd"   );
ReadLib( "lierep.gd"   );
ReadLib( "integer.gd"  );
ReadLib( "gaussian.gd"  );
ReadLib( "numtheor.gd" );
ReadLib( "dlog.gd" );
ReadLib( "primality.gd");
ReadLib( "contfrac.gd" );
ReadLib( "ringsc.gd"   );
ReadLib( "ringhom.gd"  );
ReadLib( "combinat.gd" );

ReadLib( "ratfun.gd"   );

# family predicates (needed for all 'InstallMethod' and oprt.gd)
# this references declarations from coll.gd, mapping.gd, liefam.gd
ReadLib( "fampred.g"   );

ReadLib( "list.gi"     );
ReadLib( "set.gi"      );
ReadLib( "wpobj.gi"    );

# random sources
ReadLib("random.gi");

ReadLib( "field.gd"    );
ReadLib( "zmodnz.gd"   );
ReadLib( "zmodnze.gd"  );
ReadLib( "cyclotom.gd" );
ReadLib( "fldabnum.gd" );
ReadLib( "padics.gd"   );
ReadLib( "ringpoly.gd" );
ReadLib( "upoly.gd"    );
ReadLib( "polyfinf.gd" );
ReadLib( "polyrat.gd"  );
ReadLib( "polyconw.gd" );
ReadLib( "algfld.gd"   );
ReadLib( "meataxe.gd"  );

ReadLib( "unknown.gd"  );

ReadLib( "word.gd"     );
ReadLib( "wordass.gd"  );

ReadLib( "matobj2.gd"  );
ReadLib( "matobjplist.gd" );
ReadLib( "matobjnz.gd" );

# files dealing with rewriting systems
ReadLib( "rws.gd"      );
ReadLib( "rwspcclt.gd" );
ReadLib( "rwsgrp.gd"   );
ReadLib( "rwspcgrp.gd" );
ReadLib( "groebner.gd" );


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

ReadLib( "addgphom.gd" );

ReadLib( "grpnames.g"  );
ReadLib( "grpnames.gd" );

# files dealing with quotient computations
ReadLib( "quotsys.gd" );
ReadLib( "pquot.gd" );

ReadLib( "oprt.gd"     );
ReadLib( "partitio.gd" );
ReadLib( "stbc.gd"     );
ReadLib( "clas.gd"     );
ReadLib( "clashom.gd"  );
ReadLib( "permdeco.gd"  );
ReadLib( "csetgrp.gd"  );
ReadLib( "factgrp.gd"  );
ReadLib( "grpreps.gd" );
ReadLib( "grppcrep.gd" );

ReadLib( "onecohom.gd" );
ReadLib( "grppccom.gd" );

ReadLib( "twocohom.gd" );
ReadLib( "grppcext.gd" );
ReadLib( "grppcfp.gd" );
ReadLib( "randiso.gd" );

ReadLib( "schur.gd" );
ReadLib( "schursym.gd" );

ReadLib( "grplatt.gd"  );
ReadLib( "oprtglat.gd" );
ReadLib( "grppclat.gd" );

ReadLib( "grppcaut.gd" );

ReadLib( "straight.gd" );
ReadLib( "memory.gd"  );

# files dealing with fp groups
ReadLib( "grpfp.gd"    );
ReadLib( "grpfree.gd"  );
ReadLib( "sgpres.gd" );
ReadLib( "tietze.gd" );
ReadLib( "ghomfp.gd" );

# files needed for deep thought
ReadLib( "dt.g" );

ReadLib( "integer.gi"  ); # needed for CoefficientsQadic

# files dealing with nice monomorphism
# grpnice uses some family predicates, so fampred.g must be known
ReadLib( "grpnice.gd"  );
ReadLib( "morpheus.gd" );


# files dealing with matrix groups (grpffmat.gd needs grpnice.gd)
ReadLib( "grpmat.gd"   );
ReadLib( "fitfree.gd"  );
ReadLib( "grpffmat.gd" );
ReadLib( "grpramat.gd" );

# group library
ReadGrp( "basic.gd"    );
ReadGrp( "classic.gd"  );
ReadGrp( "perf.gd"     );
ReadGrp( "suzuki.gd"   );
ReadGrp( "ree.gd"   );
ReadGrp( "simple.gd"   );
ReadGrp( "imf.gd"      );
ReadGrp( "glzmodmz.gd" );
ReadGrp( "clasmax.grp" );

ReadLib( "orders.gd"  );

# files dealing with semigroups - second layer
ReadLib( "trans.gd");
ReadLib("pperm.gd");
ReadLib( "fastendo.gd");
ReadLib( "fpsemi.gd");
ReadLib( "fpmon.gd");
ReadLib( "rwssmg.gd");
ReadLib( "kbsemi.gd");
ReadLib( "tcsemi.gd");
ReadLib( "adjoin.gd");
ReadLib( "semirel.gd");
ReadLib( "semitran.gd");
ReadLib( "reesmat.gd");
ReadLib( "semiquo.gd");
ReadLib( "semipperm.gd");

# the help system
ReadLib( "pager.gd"    );
ReadLib( "helpbase.gd" );
ReadLib( "helpview.gd" );
ReadLib( "helpt2t.gd" );
ReadLib( "helpdef.gd" );

# files dealing with character tables, class functions, tables of marks
ReadLib( "ctbl.gd" );
ReadLib( "ctblfuns.gd" );
ReadLib( "ctblmaps.gd" );
ReadLib( "ctblauto.gd" );
ReadLib( "ctbllatt.gd" );
ReadLib( "ctblsymm.gd" );
ReadLib( "ctblsolv.gd" );
ReadLib( "ctblpope.gd" );
ReadLib( "ctblmoli.gd" );
ReadLib( "ctblmono.gd" );
ReadLib( "ctblgrp.gd" );
ReadLib( "tom.gd" );

# prototyping utilities
ReadLib("proto.gd");

ReadLib("gasman.gd");

ReadLib("memusage.gd");
