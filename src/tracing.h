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

#ifndef GAP_TRACING_H
#define GAP_TRACING_H

#include "objects.h"

// The following functions should not be called directly. They are provided
// so the macros below function correctly
void ReportWrappedOperation1(const char *, Obj op);
void ReportWrappedOperation2(const char *, Obj op1, Obj op2);
void InstallOpWrapper(void (*activate)(void), void (*deactivate)(void));


// Many built-in operators in GAP are implemented as a 1 or 2 dimensional
// array of function pointers, where we set one function for each possible
// TNUM (or pair of TNUMs) which can be given to the operator.

// These macros allow us to wrap these array of function pointers, so every
// time one of the functions in the array is called, an extra function is also
// called, which can be used for tracking which operators are called with
// which arguments. This allows us to track when these operators are used
// without paying a cost when the operators are not being tracked.

// These should be installed using the macros below.

// Firstly the array of function pointers should be passed to
// DEFINE_OP_WRAPPER1/2 at the global scope. Given an array 'Array', these
// macros:
//
// 1) Defines an array 'WrapArray', to store the contents of Array
//    while it is wrapped.
// 2) A function 'WrapArrayFunc'. We fill 'Array' with pointers to this
//    function when wrapping is active, which means ReportWrappedFunction
//    gets called whenever we try to call one of the members of 'Array'.
// 3) ArrayHookActive and ArrayHookDeactive, to turn the wrapping on and off.

// Note that calling DEFINE_OP_WRAPPER1/2 (for 1/2 dimensional arrays
// respectively) only define functions. We must also call INSTALL_OP_WRAPPER
// so tracing.c is informed that 'Array' can be wrapped.


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

#endif
