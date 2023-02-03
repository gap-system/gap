#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file defines some functions that tweak the behaviour of attributes
##


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
#F  DisableAttributeValueStoring( <attr> ) tell the attribute to stop
##                                           storing values
##

InstallGlobalFunction(DisableAttributeValueStoring, function( attr )
    Assert(1,IsOperation(attr));
    Assert(2,Setter(attr) <> false);
    Info(InfoAttributes + InfoWarning, 2, "Disabling value storing for ",NAME_FUNC(attr));
    SET_ATTRIBUTE_STORING( attr, false);
end);

Unbind(CHECK_REPEATED_ATTRIBUTE_SET);
BindGlobal( "CHECK_REPEATED_ATTRIBUTE_SET", function(obj, name, val)
    if InfoLevel(InfoAttributes) >= 3 then
        if not IsBound(obj!.(name)) then
            Info(InfoAttributes, 3, "Attribute ", name, " of ", obj, " is marked as assigned, but it has no value");
        elif obj!.(name) <> val then
            Info(InfoAttributes, 3, "Attribute ", name, " of ", obj, " already set to ", obj!.(name), ", cannot be changed to ", val);
        fi;
    fi;
end );
