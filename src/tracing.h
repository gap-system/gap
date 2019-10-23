/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file defines the functions for tracing operations.
*/

#include "objects.h"


void ReportWrappedOperation1(const char *, Obj op);
void ReportWrappedOperation2(const char *, Obj op1, Obj op2);
void InstallOpWrapper(voidfunc, voidfunc);


// These are macros which make it simple to wrap

#define DEFINE_OP_WRAPPER1(Array)                                            \
    static ObjFunc_0ARGS Wrap##Array[LAST_REAL_TNUM + 1];                    \
    Obj                  Wrap##Array##Func(Obj op)                           \
    {                                                                        \
        ReportWrappedOperation1(#Array, op);                                 \
        return Wrap##Array[TNUM_OBJ(op)](op);                                \
    }                                                                        \
    void Array##HookActivate(void)                                           \
    {                                                                        \
        for (int i = 0; i < LAST_REAL_TNUM; ++i) {                           \
            Wrap##Array[i] = Array[i];                                       \
            Array[i] = Wrap##Array##Func;                                    \
        }                                                                    \
    }                                                                        \
                                                                             \
    void Array##HookDeactivate(void)                                         \
    {                                                                        \
        for (int i = 0; i < LAST_REAL_TNUM; ++i) {                           \
            Array[i] = Wrap##Array[i];                                       \
            Wrap##Array[i] = 0;                                              \
        }                                                                    \
    }

#define DEFINE_OP_WRAPPER2(Array)                                            \
    static ObjFunc_1ARGS Wrap##Array[LAST_REAL_TNUM + 1]                     \
                                    [LAST_REAL_TNUM + 1];                    \
    Obj Wrap##Array##Func(Obj op1, Obj op2)                                  \
    {                                                                        \
        ReportWrappedOperation2(#Array, op1, op2);                           \
        return Wrap##Array[TNUM_OBJ(op1)][TNUM_OBJ(op2)](op1, op2);          \
    }                                                                        \
    void Array##HookActivate(void)                                           \
    {                                                                        \
        for (int i = 0; i < LAST_REAL_TNUM; ++i) {                           \
            for (int j = 0; j < LAST_REAL_TNUM; ++j) {                       \
                Wrap##Array[i][j] = Array[i][j];                             \
                Array[i][j] = Wrap##Array##Func;                             \
            }                                                                \
        }                                                                    \
    }                                                                        \
                                                                             \
    void Array##HookDeactivate(void)                                         \
    {                                                                        \
        for (int i = 0; i < LAST_REAL_TNUM; ++i) {                           \
            for (int j = 0; j < LAST_REAL_TNUM; ++j) {                       \
                Array[i][j] = Wrap##Array[i][j];                             \
                Wrap##Array[i][j] = 0;                                       \
            }                                                                \
        }                                                                    \
    }

#define INSTALL_OP_WRAPPER(Array)                                            \
    InstallOpWrapper(Array##HookActivate, Array##HookDeactivate);


/****************************************************************************
**
*F  InitInfoTracing() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoTracing(void);
