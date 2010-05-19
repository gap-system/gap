#############################################################################
##
#W  synchronize.g                GAP library                  Reimer Behrends
##
#H  @(#)$Id: synchronize.g,v 4.50 2010/04/10 14:20:00 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This is a minimal file to provide type information for the new types
##  provided by synchronization primitives.
##

Revision.synchronize_g :=
  "@(#)$Id: synchronize.g,v 4.50 2010/04/10 14:20:00 gap Exp $";


SynchronizationFamily := NewFamily("SynchronizationFamily", IsObject);

TYPE_CHANNEL := NewType(SynchronizationFamily, IsObject);
TYPE_BARRIER := NewType(SynchronizationFamily, IsObject);
TYPE_SYNCVAR := NewType(SynchronizationFamily, IsObject);
