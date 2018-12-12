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
#X  now read profiling functions, help system
##
ReadLib( "profile.g"   );
ReadLib( "newprofile.g");
ReadLib( "methwhy.g"   );

##  the help system
ReadLib( "pager.gi"    );
ReadLib( "helpbase.gi"  );
ReadLib( "helpview.gi"  );
ReadLib( "helpt2t.gi"   );
ReadLib( "helpdef.gi"   );

ReadLib( "reread.g"    );
ReadLib( "package.gi"   );

ReadLib( "string.gi"   ); # since StringFile is needed early

# for dealing with test files and manual examples
ReadLib("test.gd");
ReadLib("test.gi");

ReadLib("galois.gd");
ReadLib("galois.gi");
