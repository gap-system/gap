#############################################################################
##
#W  gasman.gd                   GAP Library                       Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains declarations of functions that report information from the
##  GASMAN garbage collector
##
Revision.gasman_gd :=
    "@(#)$Id$";

#############################################################################
##
#F  GasmanStatistics( )
##
##  `GasmanStatistics()' returns a record containing some information
##  from the garbage collection mechanism. The record may contain up to
##  two components: `full' and `partial'
##
##  The `full' component will be present if a full garbage collection
##  has taken place since GAP started. It contains information about
##  the most recent full garbage collection. It is a record, with six
##  components: `livebags' contains the number of bags which survived
##  the garbage collection; `livekb' contains the total number of
##  kilobytes occupied by those bags; `deadbags' contains the total
##  number of bags which were reclaimed by that garbage collection and
##  all the partial garbage collections preceeding it, since the
##  previous full garbage collection; `deadkb' contains the total
##  number of kilobytes occupied by those bags; `freekb' reports the
##  total number of kilobytes available in the GAP workspace for new
##  objects and `totalkb' the actual size of the workspace.
##
##  These figures shouold be viewed with some caution. They are
##  stored internally in fixed length integer formats, and `deadkb'
##  and `deadbags' are liable to overflow if there are many partial
##  collections before a full collection. Also, note that `livekb' and
##  `freekb' will not usually add up to `totalkb'. The difference is
##  essentially the space overhead of the memory management system.
##
##  The `partial' component will be present if there has been a
##  partial garbage collection since the last full one. It is also a
##  record with the same six components as `full'. In this case
##  `deadbags' and `deadkb' refer only to the number and total size of
##  the garbage bags reclaimed in this partial garbage collection and
##  `livebags'and `livekb' only to the numbers and total size of the
##  young bags that were considered for garbage collection, and
##  survived.
##

DeclareGlobalFunction("GasmanStatistics");

#############################################################################
##
#F  GasmanMessageStatus( )
#F  SetGasmanMessageStatus( <stat> )
##
##  `GasmanMessageStatus()' returns one of the string \"none\",
##  \"full\" or \"all\", depending on whether the garbage collector is
##  currently set to print messages on no collections, full
##  collections only or all collections. 
##
##  `SetGasmanMessageStatus( <stat> )' sets the garbage collector
##  messaging level. <stat> should be one of the strings \"none\",
##  \"full\" or \"all\".   
##

DeclareGlobalFunction("GasmanMessageStatus");
DeclareGlobalFunction("SetGasmanMessageStatus");

#############################################################################
##
#F GasmanLimits()
##
##  `GasmanLimits()' returns a record with three components: `min' is
##  the minimum workspace size as set by the `-m' command line option
##  in kilobytes. The workspace size will never be reduced below this
##  by the garbage collector. `max' is the maximum workspace size, as
##  set by the '-o' command line option, also in kilobytes. If the
##  workspace would need to grow past this point, GAP will enter a
##  break loop to warn the user. A value of 0 indicates no
##  limit.`kill' is the absolute maximum, set by the `-K' command line
##  option. The workspace will never be allowed to grow past this
##  limit.
  
DeclareGlobalFunction("GasmanLimits");


#############################################################################
##
#E

