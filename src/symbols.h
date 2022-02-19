/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_SYMBOLS_H
#define GAP_SYMBOLS_H

#include "common.h"

#ifdef HPCGAP
#include <pthread.h>
#endif

// some auxiliary typedefs for SymbolTable
typedef struct SymbolTable SymbolTable;
typedef Obj (*SymbolIdToNameFunc)(UInt id);
typedef void (*NewSymbolFunc)(SymbolTable * symtab, UInt id, Obj name);

// A SymbolTable maps strings to unique monotonously increasing
// integer ids.
struct SymbolTable {
    // number of symbols, stored as an object so it can be saved
    // in workspaces
    Obj count;

    // hashtable: a plist containing integers
    Obj table;

    // a function which maps symbol ids back to names
    SymbolIdToNameFunc nameFunc;

    // a function which is called whenever a new symbol is
    // added to the table
    NewSymbolFunc newSymbolFunc;

#ifdef HPCGAP
    pthread_rwlock_t lock;
    void *           lockOwner;
    UInt             lockDepth;
#endif
};

// Initialize kernel part of a SymbolTable (to be called from InitKernel)
void InitSymbolTableKernel(SymbolTable *      symtab,
                           const char *       cookieCount,
                           const char *       cookieTable,
                           SymbolIdToNameFunc nameFunc,
                           NewSymbolFunc      newSymbolFunc);

// Initialize library part of a SymbolTable (to be called from InitLibrary)
void InitSymbolTableLibrary(SymbolTable * symtab, UInt initialSize);

// Return the number of symbols contained in a SymbolTable (thread safe)
int LengthSymbolTable(SymbolTable * symtab);

// Return a unique id for the symbol <name> in <symtab>. If the entry
// is not yet in the table, it is added, and <symtab->newSymbolFunc> is
// invoked.
UInt LookupSymbol(SymbolTable * symtab, const char * name);


#ifdef HPCGAP
void LockSymbolTableForReading(SymbolTable * symtab);
void LockSymbolTableForWriting(SymbolTable * symtab);
void UnlockSymbolTable(SymbolTable * symtab);
#endif


#endif    // GAP_SYMBOLS_H
