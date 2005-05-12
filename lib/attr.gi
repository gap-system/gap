#############################################################################
##
#W  attr.gi                     GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file defines some functions that tweak the behaviour of attributes
##
Revision.attr_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  EnableAttributeValueStoring( <attr> ) tell the attribute to resume 
##                                           storing values
##

InstallGlobalFunction(EnableAttributeValueStoring,  function( attr )
    Assert(1,IsOperation(attr));
    Assert(2,Setter(attr) <> false);
    Info(InfoAttributes + InfoWarning, 3, "Enabling value storing for ",NAME_FUNC(attr));
    SET_ATTRIBUTE_STORING( attr, true);
end);

#############################################################################
##
#F  DisableAttributeValueStoring( <attr> ) tell the attribute to resume 
##                                           storing values
##

InstallGlobalFunction(DisableAttributeValueStoring, function( attr )
    Assert(1,IsOperation(attr));
    Assert(2,Setter(attr) <> false);
    Info(InfoAttributes + InfoWarning, 2, "Disabling value storing for ",NAME_FUNC(attr));
    SET_ATTRIBUTE_STORING( attr, false);
end);
