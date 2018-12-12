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
#X  now read the basic methods
##
ReadLib( "process.gd"  );

ReadLib( "files.gi"    );
ReadLib( "streams.gi"  );
if IsHPCGAP then
  ReadLib( "custom_streams.gi"  );
fi;
ReadLib( "process.gi"  );

