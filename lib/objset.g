#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

BindGlobal("ObjSetFamily", NewFamily("ObjSetFamily", IsObject));
DeclareFilter("IsObjSet", IsObject and IsInternalRep);
DeclareFilter("IsObjMap", IsObject and IsInternalRep);

BindGlobal("TYPE_OBJSET", NewType(ObjSetFamily, IsObjSet));
BindGlobal("TYPE_OBJMAP", NewType(ObjSetFamily, IsObjMap));
