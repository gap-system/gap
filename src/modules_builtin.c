/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "modules_builtin.h"

#include "gap.h"
#include "gap_all.h"
#include "gaptime.h"
#include "hookintrprtr.h"
#include "info.h"
#include "intfuncs.h"
#include "iostream.h"
#include "libgap_intern.h"
#include "objccoll.h"
#include "objset.h"
#include "profile.h"
#include "syntaxtree.h"
#include "tracing.h"
#include "vec8bit.h"
#include "vecffe.h"
#include "vecgf2.h"

// clang-format off

/****************************************************************************
**
*V  InitFuncsBuiltinModules . . . . .  list of builtin modules init functions
*/
const InitInfoFunc InitFuncsBuiltinModules[] = {

#ifdef HPCGAP
    // Traversal functionality may be needed during the initialization
    // of some modules, so set it up as early as possible
    InitInfoTraverse,
#endif

    /* global variables                                                    */
    InitInfoGVars,

    /* objects                                                             */
    InitInfoObjects,

    /* profiling and interpreter hooking information */
    InitInfoProfile,
    InitInfoHookIntrprtr,
    InitInfoTracing,

    // reader, interpreter, coder, caller, compiler, ...
    InitInfoIO,
    InitInfoRead,
    InitInfoCalls,
    InitInfoExprs,
    InitInfoStats,
    InitInfoCode,
    InitInfoVars,       /* must come after InitExpr and InitStats */
    InitInfoFuncs,
    InitInfoOpers,
    InitInfoInfo,
    InitInfoIntrprtr,
    InitInfoCompiler,

    /* arithmetic operations                                               */
    InitInfoAriths,

    /* record packages                                                     */
    InitInfoRecords,
    InitInfoPRecord,

    /* internal types                                                      */
    InitInfoInt,
    InitInfoIntFuncs,
    InitInfoRat,
    InitInfoCyc,
    InitInfoFinfield,
    InitInfoPermutat,
    InitInfoTrans,
    InitInfoPPerm,
    InitInfoBool,
    InitInfoMacfloat,

    /* list packages                                                       */
    InitInfoLists,
    InitInfoListOper,
    InitInfoListFunc,
    InitInfoPlist,
    InitInfoSet,
    InitInfoVector,
    InitInfoVecFFE,
    InitInfoBlist,
    InitInfoRange,
    InitInfoString,
    InitInfoGF2Vec,
    InitInfoVec8bit,

    /* free and presented groups                                           */
    InitInfoFreeGroupElements,
    InitInfoCosetTable,
    InitInfoTietze,
    InitInfoPcElements,
    InitInfoCollectors,
    InitInfoPcc,
    InitInfoDeepThought,
    InitInfoDTEvaluation,

    /* algebras                                                            */
    InitInfoSCTable,

    /* save and load workspace, weak pointers                              */
    InitInfoWeakPtr,
    InitInfoSaveLoad,

    /* syntax and parser tools */
    InitInfoSyntaxTree,

    /* input and output                                                    */
    InitInfoStreams,
    InitInfoSysFiles,
    InitInfoIOStream,

    /* main module                                                         */
    InitInfoModules,
    InitInfoGap,
    InitInfoError,
    InitInfoTime,

    // objsets / objmaps
    InitInfoObjSets,

#ifdef HPCGAP
    /* threads                                                             */
    InitInfoThreadAPI,
    InitInfoAObjects,
    InitInfoSerialize,
#else
    // libgap API
    InitInfoLibGapApi,
#endif

    0
};

// clang-format on
