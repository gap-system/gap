/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "gapstate.h"

#ifdef HAVE_NATIVE_TLS

__thread GAPState TLSGAPtate;
__thread ThreadLocalStorage *TLSInstance;

#endif

void InitializeTLS(void)
{
#ifdef HAVE_NATIVE_TLS
    // FIXME: is this the right place to do this?
    TLSInstance = &(TLSGAPtate.tls);
#endif
    memset(ActiveGAPState(), 0, sizeof(GAPState));
}
