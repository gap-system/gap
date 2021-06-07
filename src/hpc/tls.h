/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_TLS_H
#define GAP_TLS_H

#include "system.h"

#if !defined(HPCGAP)
#error This header is only meant to be used with HPC-GAP
#endif

// This contains our implementation of thread-local storage (TLS). TLS
// is a feature that is only to varying degrees supported by compilers
// and operating systems. As it is critical for the performance of
// HPC-GAP, we allow the implementation to choose between various
// options.
//
// By default, we use a low-level stack-based approach. Each thread
// stack is allocated on a memory segment whose boundaries are a
// multiple of a fixed power of 2 (see tlsconfig.h). The pages with
// the lowest address in that memory range are reserved for TLS,
// the rest for the stack itself. This allows us to get the base
// address for TLS by taking the stack or frame pointer (or any address
// on the stack) and masking out the lowest bits. This is very fast
// and on many platforms actually faster than global variables.
//
// However, this option only works when GAP is run as an application,
// as it needs to control the creation of threads in order to force
// thread stacks on the required boundaries. When used as a library,
// we need a native implementation. These can be chosen by passing
// the --enable-native-tls option to the configure script.
//
// By default, native TLS support will default to declaring TLS as
// storage type __thread. This is simple, but inefficient on some
// platforms. In particular, Cygwin and macOS require a function call
// to a dynamically loaded library to access __thread storage, which
// furthermore inhibits compiler optimizations.
//
// For these platforms, we use a different approach. As a basic
// alternative, on platforms that support it, we use
// pthread_getspecific() to get the base address of TLS and we
// define pthread_getspecific() as a pure function. This is still
// not faster than __thread by itself, but declaring
// pthread_getspecific() as pure allows compiler optimizations such
// as common subexpression elimination and code hoisting.
//
// As a further improvement, on macOS (and in the future, on Cygwin),
// we use an assembly-based alternative implementation of
// pthread_getspecific(). This assembly code can be treated like
// a normal variable access. In order to check that this is safe,
// we verify both during configuration and at runtime that the
// assembly code for pthread_getspecific() is implemented in a way
// consistent with such code.

#include "hpc/tlsconfig.h"

#include <setjmp.h>

typedef struct Region Region;

typedef struct ThreadLocalStorage
{
  int threadID;
  void *threadLock;
  void *threadSignal;
  void *acquiredMonitor;
  unsigned multiplexRandomSeed;
  Region * currentRegion;
  Region * threadRegion;
  Obj threadObject;
  Obj tlRecords;
  Obj lockStack;
  int lockStackPointer;
  Obj copiedObjs;
  Obj interruptHandlers;
  void *CurrentHashLock;
  int DisableGuards;

  /* From intrprtr.c */
  UInt PeriodicCheckCount;

  /* From read.c */
  jmp_buf threadExit;

  /* Profiling */
  UInt CountActive;
  UInt LocksAcquired;
  UInt LocksContended;
} ThreadLocalStorage;

#ifdef USE_NATIVE_TLS
extern __thread ThreadLocalStorage *TLSInstance;
#endif

#ifdef USE_PTHREAD_TLS

#include <pthread.h>

#ifdef HAVE_FUNC_ATTRIBUTE_PURE
#define PURE_FUNC __attribute__((pure))
#else
#define PURE_FUNC
#endif

#ifdef HAVE_FUNC_ATTRIBUTE_CONSTRUCTOR
#define CONSTRUCTOR_FUNC __attribute__((constructor))
#else
#define CONSTRUCTOR_FUNC
#endif

#ifdef ALLOW_PURE_PTHREAD_GETSPECIFIC
// pthread_getspecific() is not defined as pure by default; redeclaring
// it as such works for gcc/clang and allows the compiler to hoist calls
// to pthread_getspecific() out of loops and perform constant
// subexpression elimination on expressions containing TLS values.
PURE_FUNC void * pthread_getspecific(pthread_key_t);
#endif

#ifdef USE_MACOS_PTHREAD_TLS_ASM
static UInt TLSOffsetCopy;
UInt GetTLSOffset(void);
#else
static pthread_key_t TLSKeyCopy;
pthread_key_t GetTLSKey(void);
#endif

// This constructor function will initialize a static variable to
// address thread-local storage via pthread_getspecific() for each C
// module (TLSOffset or TLSKeyCopy, depending on how thread-local
// storage is being addressed). Making the variable static (instead of
// having it global and initialized once) allows optimizations that a
// global non-static variable would not permit. On some architectures,
// it is also faster to access a static than a global non-static
// variable, avoiding one level of indirection.
//
// Constructor functions are executed upon program start/library load.
#ifdef HAVE_FUNC_ATTRIBUTE_CONSTRUCTOR
#ifdef USE_MACOS_PTHREAD_TLS_ASM
CONSTRUCTOR_FUNC static void InitTLSOffset()
{
    TLSOffsetCopy = GetTLSOffset();
}
#else
CONSTRUCTOR_FUNC static void InitTLSKey()
{
    TLSKeyCopy = GetTLSKey();
}
#endif // USE_MACOS_PTHREAD_TLS_ASM
#endif // HAVE_FUNC_ATTRIBUTE_CONSTRUCTOR
#endif // USE_PTHREAD_TLS

#if defined(VERBOSE_GUARDS)
static inline ThreadLocalStorage * GetTLS(void)
#else
static ALWAYS_INLINE ThreadLocalStorage * GetTLS(void)
#endif
{
#if defined(USE_NATIVE_TLS)
    return TLSInstance;
#elif defined(USE_PTHREAD_TLS)
#ifdef USE_MACOS_PTHREAD_TLS_ASM
    long   offset;
    void * p;
    offset = (long)TLSOffsetCopy;
    // The following inline assembly code is the same as that in
    // pthread_getspecific(). That pthread_getspecific() is actually
    // implemented in that way has been verified in the configure
    // script and resulted in defining USE_MACOS_PTHREAD_TLS_ASM.
    // If that test fails, we fall back to the standard implementation
    // of pthread_getspecific().
    asm("movq %%gs:(%1), %0"
        : "=r"(p)  /* output = %0 */
        : "r"(offset) /* input = %1 */
        : /* clobber = none */);
    return (ThreadLocalStorage *)p;
#else
#ifdef HAVE_FUNC_ATTRIBUTE_CONSTRUCTOR
    return (ThreadLocalStorage *)pthread_getspecific(TLSKeyCopy);
#else
    return (ThreadLocalStorage *)pthread_getspecific(GetTLSKey());
#endif
#endif /* USE_MACOS_PTHREAD_TLS_ASM */
#else
    // use stack mask approach
    void * stack;
#ifdef __GNUC__
    stack = __builtin_frame_address(0);
#else
    int dummy[1];
    stack = dummy;
#endif
    return (ThreadLocalStorage *)(((uintptr_t)stack) & TLS_MASK);
#endif /* USE_NATIVE_TLS, USE_PTHREAD_TLS */
}

// Convenience helper for accessing TLS members
#define TLS(x) GetTLS()->x

void InitializeTLS(void);

#endif // GAP_TLS_H
