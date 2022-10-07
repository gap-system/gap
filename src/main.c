/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "common.h"

#ifdef HPCGAP
#include "hpc/thread.h"
#endif

#include "config.h"

extern int realmain(int argc, char *argv[]);

int main(int argc, char *argv[])
{
    InstallBacktraceHandlers();

#ifdef HPCGAP
    RunThreadedMain(realmain, argc, argv);
    return 0;
#else
    return realmain(argc, argv);
#endif
}
