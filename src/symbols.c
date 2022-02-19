/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "symbols.h"

#include "error.h"
#include "plist.h"
#include "stringobj.h"
#include "sysstr.h"

#ifdef HPCGAP
#include "hpc/tls.h"
#include "hpc/thread.h"
#endif

#include <stdlib.h>


void InitSymbolTableKernel(SymbolTable *      symtab,
                           const char *       cookieCount,
                           const char *       cookieTable,
                           SymbolIdToNameFunc nameFunc,
                           NewSymbolFunc      newSymbolFunc)
{
    GAP_ASSERT(symtab);
    GAP_ASSERT(cookieCount);
    GAP_ASSERT(cookieTable);
    GAP_ASSERT(nameFunc);
    GAP_ASSERT(newSymbolFunc);

    symtab->count = INTOBJ_INT(0);
    symtab->table = 0;
    symtab->nameFunc = nameFunc;
    symtab->newSymbolFunc = newSymbolFunc;

#ifdef HPCGAP
    pthread_rwlock_init(&symtab->lock, NULL);
    symtab->lockOwner = 0;
    symtab->lockDepth = 0;
#endif

    InitGlobalBag(&symtab->count, cookieCount);
    InitGlobalBag(&symtab->table, cookieTable);
}

void InitSymbolTableLibrary(SymbolTable * symtab, UInt initialSize)
{
    GAP_ASSERT(symtab);

    symtab->table = NEW_PLIST(T_PLIST, initialSize);
    SET_LEN_PLIST(symtab->table, initialSize);
#ifdef HPCGAP
    MakeBagPublic(symtab->table);
#endif
}

#ifdef HPCGAP
void LockSymbolTableForReading(SymbolTable * symtab)
{
    if (PreThreadCreation)
        return;

    if (symtab->lockOwner == GetTLS()) {
        symtab->lockDepth++;
        return;
    }

    pthread_rwlock_rdlock(&symtab->lock);
}

void LockSymbolTableForWriting(SymbolTable * symtab)
{
    if (PreThreadCreation)
        return;

    if (symtab->lockOwner == GetTLS()) {
        symtab->lockDepth++;
        return;
    }

    pthread_rwlock_wrlock(&symtab->lock);

    symtab->lockOwner = GetTLS();
    symtab->lockDepth = 1;
}

void UnlockSymbolTable(SymbolTable * symtab)
{
    if (PreThreadCreation)
        return;

    if (symtab->lockOwner == GetTLS()) {
        symtab->lockDepth--;
        if (symtab->lockDepth != 0)
            return;
        symtab->lockOwner = NULL;
    }

    pthread_rwlock_unlock(&symtab->lock);
}
#endif

int LengthSymbolTable(SymbolTable * symtab)
{
#ifdef HPCGAP
    LockSymbolTableForReading(symtab);
#endif
    int count = INT_INTOBJ(symtab->count);
#ifdef HPCGAP
    UnlockSymbolTable(symtab);
#endif
    return count;
}

static inline UInt HashString(const Char * name)
{
    UInt hash = 0;
    while (*name) {
        hash = 65599 * hash + *name++;
    }
    return hash;
}

UInt LookupSymbol(SymbolTable * symtab, const char * name)
{
    Obj  id;            // symbol id (as imm intobj)
    UInt pos;           // hash position
    Char namx[1024];    // temporary copy of <name>
    Obj  string;        // temporary string object <name>
    Obj  table;         // temporary copy of <symtab->table>
    UInt i;             // loop variable
    UInt sizeTable;

    if (strlen(name) > 1023) {
        // Note: We can't pass 'name' here, as it might get moved by garbage
        // collection
        ErrorQuit("Symbol names must consist of at most 1023 characters", 0,
                  0);
    }

    // start looking in the table at the following hash position
    const UInt hash = HashString(name);

#ifdef HPCGAP
    LockSymbolTableForReading(symtab);    // try a read lock first
#endif

    // look through the table until we find a free slot or the global
    sizeTable = LEN_PLIST(symtab->table);
    pos = (hash % sizeTable) + 1;
    while (
        (id = ELM_PLIST(symtab->table, pos)) != 0 &&
        strcmp(CONST_CSTR_STRING(symtab->nameFunc(INT_INTOBJ(id))), name)) {
        pos = (pos % sizeTable) + 1;
    }
    if (id != 0) {
#ifdef HPCGAP
        UnlockSymbolTable(symtab);
#endif
        return INT_INTOBJ(id);
    }
#ifdef HPCGAP
    if (!PreThreadCreation) {
        // switch to a write lock
        UnlockSymbolTable(symtab);
        LockSymbolTableForWriting(symtab);
        // when we switched to a write lock, another thread might have
        // modified the symbol table; so repeat the lookup
        sizeTable = LEN_PLIST(symtab->table);
        pos = (hash % sizeTable) + 1;
        while ((id = ELM_PLIST(symtab->table, pos)) != 0 &&
               strcmp(CONST_CSTR_STRING(symtab->nameFunc(INT_INTOBJ(id))),
                      name)) {
            pos = (pos % sizeTable) + 1;
        }
        if (id != 0) {
            UnlockSymbolTable(symtab);
            return INT_INTOBJ(id);
        }
    }
#endif

    // if we did not find the global variable, make a new one and enter it
    // (copy the name first, to avoid a stale pointer in case of a GC)
    strxcpy(namx, name, sizeof(namx));
    string = MakeImmString(namx);

    // store the id
    GAP_ASSERT(id == 0);
    symtab->count = id = INTOBJ_INT(INT_INTOBJ(symtab->count) + 1);
    SET_ELM_PLIST(symtab->table, pos, id);

    // notify about the new entry
    symtab->newSymbolFunc(symtab, INT_INTOBJ(id), string);

    // if the table is too crowded, make a larger one, rehash the names
    if (sizeTable < 3 * INT_INTOBJ(id) / 2) {
        table = symtab->table;
        sizeTable = 2 * sizeTable + 1;
        symtab->table = NEW_PLIST(T_PLIST, sizeTable);
        SET_LEN_PLIST(symtab->table, sizeTable);
#ifdef HPCGAP
        // The list is briefly non-public, but this is safe, because
        // the mutex protects it from being accessed by other threads.
        MakeBagPublic(symtab->table);
#endif
        for (i = 1; i <= (sizeTable - 1) / 2; i++) {
            Obj id2 = ELM_PLIST(table, i);
            if (id2 == 0)
                continue;
            string = symtab->nameFunc(INT_INTOBJ(id2));
            pos = HashString(CONST_CSTR_STRING(string));
            pos = (pos % sizeTable) + 1;
            while (ELM_PLIST(symtab->table, pos) != 0) {
                pos = (pos % sizeTable) + 1;
            }
            SET_ELM_PLIST(symtab->table, pos, id2);
        }
    }
#ifdef HPCGAP
    UnlockSymbolTable(symtab);
#endif

    // return the symbol id
    return INT_INTOBJ(id);
}
