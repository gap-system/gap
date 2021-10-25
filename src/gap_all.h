/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This header includes most of the other GAP headers, and is meant to be
**  included by GAP kernel extensions.
*/

#ifndef GAP_ALL_H
#define GAP_ALL_H

#ifdef __cplusplus
extern "C" {
#endif

#include "ariths.h"
#include "blister.h"
#include "bool.h"
#include "calls.h"
#include "code.h"
#include "collectors.h"
#include "common.h"
#include "compiler.h"
#include "costab.h"
#include "cyclotom.h"
#include "dt.h"
#include "dteval.h"
#include "error.h"
#include "exprs.h"
#include "finfield.h"
#include "funcs.h"
#include "gap.h"
#include "gapstate.h"
#include "gaptime.h"
#include "gasman.h"
#include "gvars.h"
#include "info.h"
#include "integer.h"
#include "intrprtr.h"
#include "io.h"
#include "iostream.h"
#include "listfunc.h"
#include "listoper.h"
#include "lists.h"
#include "macfloat.h"
#include "modules.h"
#include "objcftl.h"
#include "objects.h"
#include "objfgelm.h"
#include "objpcgel.h"
#include "opers.h"
#include "permutat.h"
#include "plist.h"
#include "pperm.h"
#include "precord.h"
#include "range.h"
#include "rational.h"
#include "read.h"
#include "records.h"
#include "saveload.h"
#include "scanner.h"
#include "sctable.h"
#include "set.h"
#include "stats.h"
#include "streams.h"
#include "stringobj.h"
#include "sysfiles.h"
#include "tietze.h"
#include "trans.h"
#include "trycatch.h"
#include "vars.h"
#include "vector.h"
#include "version.h"
#include "weakptr.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#include "hpc/guards.h"
#include "hpc/serialize.h"
#include "hpc/threadapi.h"
#include "hpc/traverse.h"
#endif

#ifdef __cplusplus
} // extern "C"
#endif

#endif // GAP_ALL_H
