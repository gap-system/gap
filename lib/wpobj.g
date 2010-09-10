#############################################################################
##
#W  wpobj.g                        GAP library                Steve Linton
##
#H  @(#)$Id: wpobj.g,v 4.6 2010/02/23 15:13:37 gap Exp $
##
#Y  Copyright (C)  1997,  
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the weak pointer type that might have to be known very
##  early in the bootstrap stage (therefore they are not in wpobj.gi)
##
Revision.wpobj_g :=
    "@(#)$Id: wpobj.g,v 4.6 2010/02/23 15:13:37 gap Exp $";

#############################################################################
##
#V  TYPE_WPOBJ  . . . . . . . . . . . . . . . . . . . . type of all wp object
##
TYPE_WPOBJ := NewType( ListsFamily,
    IsWeakPointerObject and IsInternalRep and IsSmallList and IsMutable );


#############################################################################
##
#E
##

