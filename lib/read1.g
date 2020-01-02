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
#X  first read the very basic stuff that the kernel needs to function at all,
#X  after this file is read an 'ExportToKernelFinished' is done.
##
ReadLib( "hpc/thread1.g" );
ReadLib( "filter.g"    );
ReadLib( "oper.g"      );
ReadLib( "oper1.g"     );
ReadLib( "type.g"      );
ReadLib( "type1.g"     );
ReadLib( "methsel.g"   );
ReadLib( "methsel2.g"  );

ReadLib( "function.g"  );

ReadLib( "cache.gd"    );
ReadLib( "object.gd"   );

ReadLib( "variable.g"  );

ReadLib( "package.gd"   );

ReadLib( "coll.gd"     );
ReadLib( "list.gd"     );
ReadLib( "wpobj.gd"    );
ReadLib( "arith.gd"    );
ReadLib( "ffe.gd"      );
ReadLib( "domain.gd"   );

ReadLib( "string.g"    );
ReadLib( "cyclotom.g"  );
ReadLib( "set.gd"      );

ReadLib( "record.gd"   );

ReadLib( "random.gd"   );

ReadLib( "cache.gi"    );
ReadLib( "coll.gi"     );

ReadLib( "flag.g"      );
ReadLib( "boolean.g"   );
ReadLib( "ffe.g"       );
ReadLib( "arith.gi"    );
ReadLib( "list.g"      );
ReadLib( "wpobj.g"     );
ReadLib( "permutat.g"  );
ReadLib( "trans.g"  );
ReadLib( "pperm.g"  );

ReadLib( "filter.gi"   );
ReadLib( "object.gi"   );
ReadLib( "listcoef.gd" );
ReadLib( "info.gd"     );
ReadLib( "files.gd"    );
ReadLib( "streams.gd"  );
if IsHPCGAP then
  ReadLib( "custom_streams.gd"  );
fi;

ReadLib( "record.gi"   );

ReadLib( "matobj1.gd"   );
ReadLib( "vecmat.gd"   );
ReadLib( "vec8bit.gd"   );
ReadLib( "mat8bit.gd"   );

ReadLib( "global.gd"   );

ReadLib( "info.gi"     );
ReadLib( "global.gi"   );

ReadLib( "options.gd"  );
ReadLib( "options.gi"  );

ReadLib( "attr.gd"     );
ReadLib( "attr.gi"     );

ReadLib( "string.gd"   );

ReadLib( "userpref.g"  );

ReadLib( "cmdledit.g"  );

ReadLib( "objset.g" );

ReadLib( "float.gd"    );
ReadLib( "macfloat.g"  );

if IsHPCGAP then
  ReadLib( "hpc/serialize.g" );
  ReadLib( "hpc/thread.g" );
  ReadLib( "hpc/smallrgn.g"  );
  ReadLib( "hpc/altview.g" );

  if IsBound(GAPInfo.SystemEnvironment.GAP_WORKSTEALING) then
    ReadLib( "hpc/tasks.g" );
  else
    ReadLib( "hpc/queue.g" );
    ReadLib( "hpc/stdtasks.g" );
  fi;

  ReadLib( "hpc/actor.g" );
else
  ReadLib( "hpc/tasks.g" );
fi;

ReadLib( "error.g"   );
ReadLib( "session.g" );
