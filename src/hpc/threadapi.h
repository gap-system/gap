/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_THREADAPI_H
#define GAP_THREADAPI_H

#include "objects.h"

#include "gvars.h"

#include <pthread.h>

#if !defined(HPCGAP)
#error This header is only meant to be used with HPC-GAP
#endif


enum ThreadObjectStatus {
    THREAD_TERMINATED   = 1,
    THREAD_JOINED       = 2,
};

// Memory layout of T_THREAD bags.
typedef struct ThreadObject {
    void *tls;
    UInt id;
    UInt status;
} ThreadObject;

Obj NewThreadObject(UInt id);

void InitSignals(void);

extern GVarDescriptor LastInaccessibleGVar;

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoThreadAPI() . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoThreadAPI(void);

#endif // GAP_THREADAPI_H
