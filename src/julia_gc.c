/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file stores code only required by the Julia garbage collector
**
**  The definitions of methods in this file can be found in gasman.h,
**  where the non-Julia versions of these methods live. See also boehm_gc.c
**  and gasman.c for two other garbage collector implementations.
**/

#include "julia_gc.h"

#include "fibhash.h"
#include "funcs.h"
#include "gap.h"
#include "gapstate.h"
#include "gasman.h"
#include "objects.h"
#include "plist.h"
#include "sysmem.h"
#include "system.h"
#include "vars.h"

#include "bags.inc"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <julia.h>
#include <julia_gcext.h>


/****************************************************************************
**
**  Various options controlling special features of the Julia GC code follow
*/

// if SCAN_STACK_FOR_MPTRS_ONLY is defined, stack scanning will only
// look for references to master pointers, but not bags themselves. This
// should be safe, as GASMAN uses the same mechanism. It is also faster
// and avoids certain complicated issues that can lead to crashes, and
// is therefore the default. The option to scan for all pointers remains
// available for the time being and should be considered to be
// deprecated.
#define SCAN_STACK_FOR_MPTRS_ONLY

// if REQUIRE_PRECISE_MARKING is defined, we assume that all marking
// functions are precise, i.e., they only invoke MarkBag on valid bags,
// immediate objects or NULL pointers, but not on any other random data
// #define REQUIRE_PRECISE_MARKING

// if COLLECT_MARK_CACHE_STATS is defined, we track some statistics about the
// usage of the MarkCache
// #define COLLECT_MARK_CACHE_STATS

// if MARKING_STRESS_TEST is defined, we stress test the TryMark code
// #define MARKING_STRESS_TEST

// if VALIDATE_MARKING is defined, the program is aborted if we ever
// encounter a reference during marking that does not meet additional
// validation criteria. These tests are compararively expensive and
// should not be enabled by default.
// #define VALIDATE_MARKING


// Comparing pointers in C without triggering undefined behavior
// can be difficult. As the GC already assumes that the memory
// range goes from 0 to 2^k-1 (region tables), we simply convert
// to uintptr_t and compare those.

static inline int cmp_ptr(void * p, void * q)
{
    uintptr_t paddr = (uintptr_t)p;
    uintptr_t qaddr = (uintptr_t)q;
    if (paddr < qaddr)
        return -1;
    else if (paddr > qaddr)
        return 1;
    else
        return 0;
}

static inline int lt_ptr(void * a, void * b)
{
    return (uintptr_t)a < (uintptr_t)b;
}

#if 0
static inline int gt_ptr(void * a, void * b)
{
    return (uintptr_t)a > (uintptr_t)b;
}

static inline void *max_ptr(void *a, void *b)
{
    if ((uintptr_t) a > (uintptr_t) b)
        return a;
    else
        return b;
}

static inline void *min_ptr(void *a, void *b)
{
    if ((uintptr_t) a < (uintptr_t) b)
        return a;
    else
        return b;
}
#endif

/* align pointer to full word if mis-aligned */
static inline void * align_ptr(void * p)
{
    uintptr_t u = (uintptr_t)p;
    u &= ~(sizeof(p) - 1);
    return (void *)u;
}

#ifndef REQUIRE_PRECISE_MARKING

#define MARK_CACHE_BITS 16
#define MARK_CACHE_SIZE (1 << MARK_CACHE_BITS)

#define MARK_HASH(x) (FibHash((x), MARK_CACHE_BITS))

// The MarkCache exists to speed up the conservative tracing of
// objects. While its performance benefit is minimal with the current
// API functionality, it can significantly reduce overhead if a slower
// conservative mechanism is used. It should be disabled for precise
// object tracing, however. The cache does not affect conservative
// *stack* tracing at all, only conservative tracing of objects.
//
// It functions by remembering valid object references in a (lossy)
// hash table. If we find an object reference in that table, we no
// longer need to verify that it is accurate, which is a potentially
// expensive call to the Julia runtime.

static Bag MarkCache[MARK_CACHE_SIZE];
#ifdef COLLECT_MARK_CACHE_STATS
static UInt MarkCacheHits, MarkCacheAttempts, MarkCacheCollisions;
#endif

#endif

static inline Bag * DATA(BagHeader * bag)
{
    return (Bag *)(((char *)bag) + sizeof(BagHeader));
}


static TNumExtraMarkFuncBags ExtraMarkFuncBags;

void SetExtraMarkFuncBags(TNumExtraMarkFuncBags func)
{
    ExtraMarkFuncBags = func;
}


/****************************************************************************
**
*F  InitFreeFuncBag(<type>,<free-func>)
*/

static TNumFreeFuncBags TabFreeFuncBags[NUM_TYPES];

void InitFreeFuncBag(UInt type, TNumFreeFuncBags finalizer_func)
{
    TabFreeFuncBags[type] = finalizer_func;
}

static void JFinalizer(jl_value_t * obj)
{
    BagHeader * hdr = (BagHeader *)obj;
    Bag         contents = (Bag)(hdr + 1);
    UInt        tnum = hdr->type;

    // if a bag needing a finalizer is retyped to a new tnum which no longer
    // needs one, it may happen that JFinalize is called even though
    // TabFreeFuncBags[tnum] is NULL
    if (TabFreeFuncBags[tnum])
        TabFreeFuncBags[tnum]((Bag)&contents);
}

static jl_module_t *   Module;
static jl_datatype_t * datatype_mptr;
static jl_datatype_t * datatype_bag;
static jl_datatype_t * datatype_largebag;
static UInt            StackAlignBags;
static Bag *           GapStackBottom;
static jl_ptls_t       JuliaTLS, SaveTLS;
static size_t          max_pool_obj_size;
static UInt            YoungRef;
static int             FullGC;

#if !defined(SCAN_STACK_FOR_MPTRS_ONLY)
typedef struct {
    void * addr;
    size_t size;
} MemBlock;

static inline int CmpMemBlock(MemBlock m1, MemBlock m2)
{
    char * l1 = (char *)m1.addr;
    char * r1 = l1 + m1.size;
    char * l2 = (char *)m2.addr;
    char * r2 = l2 + m2.size;
    if (lt_ptr(r1, l1))
        return -1;
    if (!lt_ptr(l2, r2))
        return 1;
    return 0;
}

#define ELEM_TYPE MemBlock
#define COMPARE CmpMemBlock

#include "baltree.h"

static size_t         bigval_startoffset;
static MemBlockTree * bigvals;

void alloc_bigval(void * addr, size_t size)
{
    MemBlock mem = { addr, size };
    MemBlockTreeInsert(bigvals, mem);
}

void free_bigval(void * addr)
{
    MemBlock mem = { addr, 0 };
    MemBlockTreeRemove(bigvals, mem);
}
#endif

typedef void * Ptr;

#define ELEM_TYPE Ptr
#define COMPARE cmp_ptr

#include "dynarray.h"

#ifndef NR_GLOBAL_BAGS
#define NR_GLOBAL_BAGS 20000L
#endif

static Bag *        GlobalAddr[NR_GLOBAL_BAGS];
static const Char * GlobalCookie[NR_GLOBAL_BAGS];
static Int          GlobalCount;


/****************************************************************************
**
*F  AllocateBagMemory( <type>, <size> )
**
**  Allocate memory for a new bag.
**/
static void * AllocateBagMemory(UInt type, UInt size)
{
    // HOOK: return `size` bytes memory of TNUM `type`.
    void * result;
    if (size <= max_pool_obj_size) {
        result = (void *)jl_gc_alloc_typed(JuliaTLS, size, datatype_bag);
    }
    else {
        result = (void *)jl_gc_alloc_typed(JuliaTLS, size, datatype_largebag);
    }
    memset(result, 0, size);
    if (TabFreeFuncBags[type])
        jl_gc_schedule_foreign_sweepfunc(JuliaTLS, (jl_value_t *)result);
    return result;
}

TNumMarkFuncBags TabMarkFuncBags[NUM_TYPES];

void InitMarkFuncBags(UInt type, TNumMarkFuncBags mark_func)
{
    // HOOK: set mark function for type `type`.
    TabMarkFuncBags[type] = mark_func;
}

static inline int JMarkTyped(void * obj, jl_datatype_t * ty)
{
    // only traverse objects internally used by GAP
    if (!jl_typeis(obj, ty))
        return 0;
    return jl_gc_mark_queue_obj(JuliaTLS, (jl_value_t *)obj);
}

static inline int JMark(void * obj)
{
#ifdef VALIDATE_MARKING
    // Validate that `obj` is still allocated and not on a
    // free list already. We verify this by checking that the
    // type is a pool object of type `jl_datatype_type`.
    jl_value_t * ty = jl_typeof(obj);
    if (jl_gc_internal_obj_base_ptr(ty) != ty)
        abort();
    if (!jl_typeis(ty, jl_datatype_type))
        abort();
#endif
    return jl_gc_mark_queue_obj(JuliaTLS, (jl_value_t *)obj);
}

void MarkJuliaObjSafe(void * obj)
{
    if (!obj)
        return;
    // Validate that `obj` is still allocated and not on a
    // free list already. We verify this by checking that the
    // type is a pool object of type `jl_datatype_type`.
    jl_value_t * ty = jl_typeof(obj);
    if (jl_gc_internal_obj_base_ptr(ty) != ty)
        return;
    if (!jl_typeis(ty, jl_datatype_type))
        return;
    if (jl_gc_mark_queue_obj(JuliaTLS, (jl_value_t *)obj))
        YoungRef++;
}


void MarkJuliaObj(void * obj)
{
    if (!obj)
        return;
    if (JMark(obj))
        YoungRef++;
}


// Overview of conservative stack scanning
//
// A key aspect of conservative marking is that (1) we need to determine
// whether a machine word is a pointer to a live object and (2) if it points
// to the interior of the object, to determine its base address.
//
// For Julia's internal objects, we call back to Julia to find out the
// necessary information. For external objects that we allocate ourselves in
// `alloc_bigval()`, we use balanced binary trees (treaps) to determine that
// information. Each node in such a tree contains an (address, size) pair
// and we use the usual binary tree search to figure out whether there is a
// node with an address range containing that address and, if so, returns
// the `address` part of the pair.
//
// While at the C level, we will generally always have a reference to the
// masterpointer, the presence of optimizing compilers, multiple threads, or
// Julia tasks (= coroutines) means that we cannot necessarily rely on this
// information; also, the `NewBag()` implementation may trigger a GC after
// allocating the bag contents, but before allocating the master pointer.
//
// As a consequence, we play it safe and assume that any word anywhere on
// the stack (including Julia task stacks) that points to a master pointer
// or the contents of a bag (including a location after the start of the
// bag) indicates a valid reference that needs to be marked.
//
// One additional concern is that Julia may opportunistically free a subset
// of unreachable objects. Thus, with conservative stack scanning, it is
// possible for a pointer to resurrect a previously unreachable object,
// from which freed objects are then marked. Hence, we add additional checks
// when traversing GAP master pointer and bag objects that this happens
// only for live objects.

static void TryMark(void * p)
{
    jl_value_t * p2 = jl_gc_internal_obj_base_ptr(p);
    if (!p2) {
#if !defined(SCAN_STACK_FOR_MPTRS_ONLY)
        // It is possible for p to point past the end of
        // the object, so we subtract one word from the
        // address. This is safe, as the object is preceded
        // by a larger header.
        MemBlock   tmp = { (char *)p - 1, 0 };
        MemBlock * found = MemBlockTreeFind(bigvals, tmp);
        if (found) {
            p2 = (jl_value_t *)found->addr;
            // It is possible for types to not be valid objects.
            // Objects with such types are not normally made visible
            // to the mark loop, so we need to avoid marking them
            // during conservative stack scanning.
            // While jl_gc_internal_obj_base_ptr(p) already eliminates this
            // case, it can still happen for bigval_t objects, so
            // we run an explicit check that the type is a valid
            // object for these.
            p2 = (jl_value_t *)((char *)p2 + bigval_startoffset);
            jl_taggedvalue_t * hdr = jl_astaggedvalue(p2);
            if (hdr->type != jl_gc_internal_obj_base_ptr(hdr->type))
                return;
        }
#endif
    }
    else {
        // Prepopulate the mark cache with references we know
        // are valid and in current use.
#ifndef REQUIRE_PRECISE_MARKING
        if (jl_typeis(p2, datatype_mptr))
            MarkCache[MARK_HASH((UInt)p2)] = (Bag)p2;
#endif
    }
    if (p2) {
#ifdef SCAN_STACK_FOR_MPTRS_ONLY
        if (jl_typeis(p2, datatype_mptr))
            JMark(p2);
#else
        void * ty = jl_typeof(p2);
        if (ty != datatype_mptr && ty != datatype_bag &&
            ty != datatype_largebag && ty != jl_weakref_type)
            return;
        JMark(p2);
#endif
    }
}

static void FindLiveRangeReverse(PtrArray * arr, void * start, void * end)
{
    if (lt_ptr(end, start)) {
        SWAP(void *, start, end);
    }
    char * p = (char *)(align_ptr(start));
    char * q = (char *)end - sizeof(void *);
    while (!lt_ptr(q, p)) {
        void * addr = *(void **)q;
        if (addr && jl_gc_internal_obj_base_ptr(addr) == addr &&
            jl_typeis(addr, datatype_mptr)) {
            PtrArrayAdd(arr, addr);
        }
        q -= StackAlignBags;
    }
}

typedef struct {
    jl_task_t * task;
    PtrArray *  stack;
} TaskInfo;

static int CmpTaskInfo(TaskInfo i1, TaskInfo i2)
{
    return cmp_ptr(i1.task, i2.task);
}

static void MarkFromList(PtrArray * arr)
{
    for (Int i = 0; i < arr->len; i++) {
        JMark(arr->items[i]);
    }
}

#define ELEM_TYPE TaskInfo
#define COMPARE CmpTaskInfo

#include "baltree.h"

static TaskInfoTree * task_stacks = NULL;

static void SafeScanTaskStack(PtrArray * stack, void * start, void * end)
{
    volatile jl_jmp_buf * old_safe_restore =
        (volatile jl_jmp_buf *)JuliaTLS->safe_restore;
    jl_jmp_buf exc_buf;
    if (!jl_setjmp(exc_buf, 0)) {
        // The bottom of the stack may be protected with
        // guard pages; accessing these results in segmentation
        // faults. Julia catches those segmentation faults and
        // longjmps to JuliaTLS->safe_restore; we use this
        // mechamism to abort stack scanning when a protected
        // page is hit. For this to work, we must scan the stack
        // from top to bottom, so we see any guard pages last.
        JuliaTLS->safe_restore = &exc_buf;
        FindLiveRangeReverse(stack, start, end);
    }
    JuliaTLS->safe_restore = (jl_jmp_buf *)old_safe_restore;
}

static void
ScanTaskStack(int rescan, jl_task_t * task, void * start, void * end)
{
    if (!task_stacks) {
        task_stacks = TaskInfoTreeMake();
    }
    TaskInfo   tmp = { task, NULL };
    TaskInfo * taskinfo = TaskInfoTreeFind(task_stacks, tmp);
    PtrArray * stack;
    if (taskinfo != NULL) {
        stack = taskinfo->stack;
        if (rescan)
            PtrArraySetLen(stack, 0);
    }
    else {
        tmp.stack = PtrArrayMake(1024);
        stack = tmp.stack;
        TaskInfoTreeInsert(task_stacks, tmp);
    }
    if (rescan) {
        SafeScanTaskStack(stack, start, end);
        // Remove duplicates
        if (stack->len > 0) {
            PtrArraySort(stack);
            Int p = 0;
            for (Int i = 1; i < stack->len; i++) {
                if (stack->items[i] != stack->items[p]) {
                    p++;
                    stack->items[p] = stack->items[i];
                }
            }
            PtrArraySetLen(stack, p + 1);
        }
    }
    MarkFromList(stack);
}

static void TryMarkRange(void * start, void * end)
{
    if (lt_ptr(end, start)) {
        SWAP(void *, start, end);
    }
    char * p = (char *)align_ptr(start);
    char * q = (char *)end - sizeof(void *) + StackAlignBags;
    while (lt_ptr(p, q)) {
        void * addr = *(void **)p;
        if (addr) {
            TryMark(addr);
#ifdef MARKING_STRESS_TEST
            for (int j = 0; j < 1000; ++j) {
                UInt val = (UInt)addr + rand() - rand();
                TryMark((void *)val);
            }
#endif
        }
        p += StackAlignBags;
    }
}

int IsGapObj(void * p)
{
    return jl_typeis(p, datatype_mptr);
}

void CHANGED_BAG(Bag bag)
{
    jl_gc_wb_back(BAG_HEADER(bag));
}

static void GapRootScanner(int full)
{
    // Mark our Julia module (this contains references to our custom data
    // types, which thus also will not be collected prematurely).
    // We call jl_gc_mark_queue_obj() directly here, because we know that
    // Module is a valid Julia object at this point, so further checks
    // in JMark() can be skipped.
    jl_gc_mark_queue_obj(JuliaTLS, (jl_value_t *)Module);
    jl_task_t * task = JuliaTLS->current_task;
    size_t      size;
    int         tid;
    // We figure out the end of the stack from the current task. While
    // `stack_bottom` is passed to InitBags(), we cannot use that if
    // current_task != root_task.
    char * stackend = (char *)jl_task_stack_buffer(task, &size, &tid);
    stackend += size;
    // The following test overrides the stackend if the following two
    // conditions hold:
    //
    // 1. GAP is not being used as a library, but is the main program
    //    and in charge of the main() function.
    // 2. The stack of the current task is that of the main task of the
    //    main thread.
    //
    // The reason is that if Julia is being initialized from GAP, it
    // cannot always reliably find the top of the stack for that task,
    // so we have to fall back to GAP for that.
    if (!IsUsingLibGap() && JuliaTLS->tid == 0 &&
        JuliaTLS->root_task == task) {
        stackend = (char *)GapStackBottom;
    }

    // allow installing a custom marking function. This is used for
    // integrating GAP (possibly linked as a shared library) with other code
    // bases which use their own form of garbage collection. For example,
    // with Python (for SageMath).
    if (ExtraMarkFuncBags)
        (*ExtraMarkFuncBags)();

    // scan the stack for further object references, and mark them
    syJmp_buf registers;
    sySetjmp(registers);
    TryMarkRange(registers, (char *)registers + sizeof(syJmp_buf));
    TryMarkRange((char *)registers + sizeof(syJmp_buf), stackend);

    // mark all global objects
    for (Int i = 0; i < GlobalCount; i++) {
        Bag p = *GlobalAddr[i];
        if (IS_BAG_REF(p)) {
            JMark(p);
        }
    }
}

static void GapTaskScanner(jl_task_t * task, int root_task)
{
    size_t size;
    int    tid;
    char * stack = (char *)jl_task_stack_buffer(task, &size, &tid);
    // If it is the current task, it has been scanned by GapRootScanner()
    // already.
    if (task == JuliaTLS->current_task)
        return;
    int rescan = 1;
    if (!FullGC) {
        // This is a temp hack to work around a problem with the
        // generational GC. Basically, task stacks are treated as roots
        // and are therefore being scanned regardless of whether they
        // are old or new, which can be expensive in the conservative
        // case. In order to avoid that, we're manually checking whether
        // the old flag is set for a task.
        //
        // This works specifically for task stacks as the current task
        // is being scanned regardless and a write barrier will flip the
        // age bit back to new if tasks are being switched.
        jl_taggedvalue_t * tag = jl_astaggedvalue(task);
        if (tag->bits.gc & 2)
            rescan = 0;
    }
    if (stack && tid < 0) {
        if (task->copy_stack) {
            // We know which part of the task stack is actually used,
            // so we shorten the range we have to scan.
            stack = stack + size - task->copy_stack;
            size = task->copy_stack;
        }
        ScanTaskStack(rescan, task, stack, stack + size);
    }
}

static void PreGCHook(int full)
{
    // It is possible for the garbage collector to be invoked from a
    // different thread other than the main thread that is running
    // GAP. So we save the TLS pointer temporarily and restore it
    // afterwards. In the long run, JuliaTLS needs to simply become
    // a thread-local variable.
    FullGC = full;
    SaveTLS = JuliaTLS;
    JuliaTLS = jl_get_ptls_states();
    // This is the same code as in VarsBeforeCollectBags() for GASMAN.
    // It is necessary because ASS_LVAR() and related functionality
    // does not call CHANGED_BAG() for performance reasons. CHANGED_BAG()
    // is only called when the current lvars bag is being changed. Thus,
    // we have to add a write barrier at the start of the GC, too.
    if (STATE(CurrLVars))
        CHANGED_BAG(STATE(CurrLVars));
    /* information at the beginning of garbage collections                 */
    SyMsgsBags(full, 0, 0);
#ifndef REQUIRE_PRECISE_MARKING
    memset(MarkCache, 0, sizeof(MarkCache));
#ifdef COLLECT_MARK_CACHE_STATS
    MarkCacheHits = MarkCacheAttempts = MarkCacheCollisions = 0;
#endif
#endif
}

static void PostGCHook(int full)
{
    JuliaTLS = SaveTLS;
    /* information at the end of garbage collections                 */
    UInt totalAlloc = 0;    // FIXME -- is this data even available?
    SyMsgsBags(full, 6, totalAlloc);
#ifdef COLLECT_MARK_CACHE_STATS
    /* printf("\n>>>Attempts: %ld\nHit rate: %lf\nCollision rate: %lf\n",
      (long) MarkCacheAttempts,
      (double) MarkCacheHits/(double)MarkCacheAttempts,
      (double) MarkCacheCollisions/(double)MarkCacheAttempts
      ); */
#endif
}

// the Julia marking function for master pointer objects (i.e., this function
// is called by the Julia GC whenever it marks a GAP master pointer object)
static uintptr_t MPtrMarkFunc(jl_ptls_t ptls, jl_value_t * obj)
{
    if (!*(void **)obj)
        return 0;
    void * header = BAG_HEADER((Bag)obj);
    // The following check ensures that the master pointer does
    // indeed reference a bag that has not yet been freed. See
    // the comments on conservative stack scanning for an in-depth
    // explanation.
    void * ty = jl_typeof(header);
    if (ty != datatype_bag && ty != datatype_largebag)
        return 0;
    if (JMark(header))
        return 1;
    return 0;
}

// the Julia marking function for bags (i.e., this function is called by the
// Julia GC whenever it marks a GAP bag object)
static uintptr_t BagMarkFunc(jl_ptls_t ptls, jl_value_t * obj)
{
    BagHeader * hdr = (BagHeader *)obj;
    Bag         contents = (Bag)(hdr + 1);
    UInt        tnum = hdr->type;
    YoungRef = 0;
    TabMarkFuncBags[tnum]((Bag)&contents);
    return YoungRef;
}

//
// This function is called from GAP.jl to set the super type our custom Julia
// types to GAP.GapObj
//
void GAP_register_GapObj(jl_datatype_t * gapobj_type)
{
    if (!gapobj_type || !jl_is_datatype(gapobj_type)) {
        Panic("GAP_register_GapObj: GapObj is not a datatype");
    }

    // DO THE GREAT MAGIC HACK (yes we are bad citizens :/) and
    // change the super type of ForeignGAP.MPtr to GapObj
    datatype_mptr->super = gapobj_type;
    jl_gc_wb(datatype_mptr, datatype_mptr->super);
}

void InitBags(UInt initial_size, Bag * stack_bottom, UInt stack_align)
{
    // HOOK: initialization happens here.
    GapStackBottom = stack_bottom;
    for (UInt i = 0; i < NUM_TYPES; i++) {
        TabMarkFuncBags[i] = MarkAllSubBags;
    }
    // These callbacks need to be set before initialization so
    // that we can track objects allocated during `jl_init()`.
#if !defined(SCAN_STACK_FOR_MPTRS_ONLY)
    bigvals = MemBlockTreeMake();
    jl_gc_set_cb_notify_external_alloc(alloc_bigval, 1);
    jl_gc_set_cb_notify_external_free(free_bigval, 1);
    bigval_startoffset = jl_gc_external_obj_hdr_size();
#endif
    max_pool_obj_size = jl_gc_max_internal_obj_size();
    jl_gc_enable_conservative_gc_support();
    jl_init();

    Module = jl_new_module(jl_symbol("ForeignGAP"));
    Module->parent = jl_main_module;

    // If we were loaded from GAP.jl, then try to retrieve GapObj from it.
    // We do this by extracting it from the relevant instances of the GAP.jl
    // module, which we get from the global variable `__JULIAGAPMODULE` if
    // present.
    //
    // Newer versions of GAP.jl do not need this mechanism and instead call
    // GAP_register_GapObj.
    jl_module_t *   parent_module;
    jl_datatype_t * gapobj_type;

    parent_module = (jl_module_t *)jl_get_global(
        jl_main_module, jl_symbol("__JULIAGAPMODULE"));
    if (parent_module) {
        if (!jl_is_module(parent_module)) {
            Panic("__JULIAGAPMODULE is set in julia main module, but does "
                  "not point to a module");
        }

        // retrieve GapObj abstract julia type
        gapobj_type =
            (jl_datatype_t *)jl_get_global(parent_module, jl_symbol("GapObj"));
        if (!gapobj_type) {
            Panic("GapObj type is not bound in GAP module");
        }
        if (!jl_is_datatype(gapobj_type)) {
            Panic("GapObj in the GAP module is not a datatype");
        }
    }
    else {
        gapobj_type = jl_any_type;
    }

    JuliaTLS = jl_get_ptls_states();
    // These callbacks potentially require access to the Julia
    // TLS and thus need to be installed after initialization.
    jl_gc_set_cb_root_scanner(GapRootScanner, 1);
    jl_gc_set_cb_task_scanner(GapTaskScanner, 1);
    jl_gc_set_cb_pre_gc(PreGCHook, 1);
    jl_gc_set_cb_post_gc(PostGCHook, 1);
    // jl_gc_enable(0); /// DEBUGGING


    jl_set_const(jl_main_module, jl_symbol("ForeignGAP"),
                 (jl_value_t *)Module);
    datatype_mptr = jl_new_foreign_type(
        jl_symbol("MPtr"), Module, gapobj_type, MPtrMarkFunc, NULL, 1, 0);
    datatype_bag = jl_new_foreign_type(jl_symbol("Bag"), Module, jl_any_type,
                                       BagMarkFunc, JFinalizer, 1, 0);
    datatype_largebag =
        jl_new_foreign_type(jl_symbol("LargeBag"), Module, jl_any_type,
                            BagMarkFunc, JFinalizer, 1, 1);

    // export datatypes to Julia level
    jl_set_const(Module, jl_symbol("MPtr"), (jl_value_t *)datatype_mptr);
    jl_set_const(Module, jl_symbol("Bag"), (jl_value_t *)datatype_bag);
    jl_set_const(Module, jl_symbol("LargeBag"),
                 (jl_value_t *)datatype_largebag);

    GAP_ASSERT(jl_is_datatype(datatype_mptr));
    GAP_ASSERT(jl_is_datatype(datatype_bag));
    GAP_ASSERT(jl_is_datatype(datatype_largebag));
    StackAlignBags = stack_align;
}

UInt CollectBags(UInt size, UInt full)
{
    // HOOK: perform a garbage collection
    jl_gc_collect(full);
    return 1;
}

void RetypeBag(Bag bag, UInt new_type)
{
    BagHeader * header = BAG_HEADER(bag);
    UInt        old_type = header->type;

#ifdef COUNT_BAGS
    /* update the statistics      */
    {
        UInt size;

        size = header->size;
        InfoBags[old_type].nrLive -= 1;
        InfoBags[new_type].nrLive += 1;
        InfoBags[old_type].nrAll -= 1;
        InfoBags[new_type].nrAll += 1;
        InfoBags[old_type].sizeLive -= size;
        InfoBags[new_type].sizeLive += size;
        InfoBags[old_type].sizeAll -= size;
        InfoBags[new_type].sizeAll += size;
    }
#endif

    if (!TabFreeFuncBags[old_type] && TabFreeFuncBags[new_type]) {
        // Retyping a bag can change whether a finalizer needs to be run for
        // it or not, depending on whether TabFreeFuncBags[tnum] is NULL or
        // not. While JFinalizer checks for this, there is a deeper problem:
        // jl_gc_schedule_foreign_sweepfunc is not idempotent, and we must not
        // call it more than once for any given bag. But this could happen if
        // a bag changed its tnum multiple times between one needing and one
        // not needing a finalizer. To avoid this, we only allow changing from
        // needing a finalizer to not needing one, but not the other way
        // around.
        //
        // The alternative would be to write code which tracks whether
        // jl_gc_schedule_foreign_sweepfunc was already called for an object
        // (e.g. by using an object flag). But right now no GAP code needs to
        // do this, and changing the type of an object to a completely
        // different type is something better to be avoided anyway. So instead
        // of supporting a feature nobody uses right now, we error out and
        // wait to see if somebody complains.
        Panic("cannot change bag type to one requiring a 'free' callback");
    }
    header->type = new_type;
}

Bag NewBag(UInt type, UInt size)
{
    Bag  bag; /* identifier of the new bag       */
    UInt alloc_size;

    alloc_size = sizeof(BagHeader) + size;

    SizeAllBags += size;

    /* If the size of an object is zero (such as an empty permutation),
     * and the header size is a multiple of twice the word size of the
     * architecture, then the master pointer will actually point past
     * the allocated area. Because this would result in the object
     * being freed prematurely, we will allocate at least one extra
     * byte so that the master pointer actually points to within an
     * allocated memory area.
     */
    if (size == 0)
        alloc_size++;

#if defined(SCAN_STACK_FOR_MPTRS_ONLY)
    bag = jl_gc_alloc_typed(JuliaTLS, sizeof(void *), datatype_mptr);
    SET_PTR_BAG(bag, 0);
#endif

    BagHeader * header = AllocateBagMemory(type, alloc_size);

    header->type = type;
    header->flags = 0;
    header->size = size;


#if !defined(SCAN_STACK_FOR_MPTRS_ONLY)
    // allocate the new masterpointer
    bag = jl_gc_alloc_typed(JuliaTLS, sizeof(void *), datatype_mptr);
    SET_PTR_BAG(bag, DATA(header));
#else
    // change the masterpointer to reference the new bag memory
    SET_PTR_BAG(bag, DATA(header));
    jl_gc_wb_back((void *)bag);
#endif

    // return the identifier of the new bag
    return bag;
}

UInt ResizeBag(Bag bag, UInt new_size)
{
    BagHeader * header = BAG_HEADER(bag);
    UInt        old_size = header->size;

#ifdef COUNT_BAGS
    // update the statistics
    InfoBags[header->type].sizeLive += new_size - old_size;
    InfoBags[header->type].sizeAll += new_size - old_size;
#endif

    // if the bag is enlarged
    if (new_size > old_size) {
        SizeAllBags += new_size;
        UInt alloc_size = sizeof(BagHeader) + new_size;
        // if size is zero, increment by 1; see NewBag for an explanation
        if (new_size == 0)
            alloc_size++;

        // allocate new bag
        header = AllocateBagMemory(header->type, alloc_size);

        // copy bag header and data, and update size
        memcpy(header, BAG_HEADER(bag), sizeof(BagHeader) + old_size);

        // update the master pointer
        SET_PTR_BAG(bag, DATA(header));
        jl_gc_wb_back((void *)bag);
    }

    // update the size
    header->size = new_size;

    // return success
    return 1;
}

void InitGlobalBag(Bag * addr, const Char * cookie)
{
    // HOOK: Register global root.
    GAP_ASSERT(GlobalCount < NR_GLOBAL_BAGS);
    GlobalAddr[GlobalCount] = addr;
    GlobalCookie[GlobalCount] = cookie;
    GlobalCount++;
}

void SwapMasterPoint(Bag bag1, Bag bag2)
{
    Obj * ptr1 = PTR_BAG(bag1);
    Obj * ptr2 = PTR_BAG(bag2);
    SET_PTR_BAG(bag1, ptr2);
    SET_PTR_BAG(bag2, ptr1);

    jl_gc_wb((void *)bag1, BAG_HEADER(bag1));
    jl_gc_wb((void *)bag2, BAG_HEADER(bag2));
}

// HOOK: mark functions

inline void MarkBag(Bag bag)
{
    if (!IS_BAG_REF(bag))
        return;

    jl_value_t * p = (jl_value_t *)bag;
#ifndef REQUIRE_PRECISE_MARKING
#ifdef COLLECT_MARK_CACHE_STATS
    MarkCacheAttempts++;
#endif
    UInt hash = MARK_HASH((UInt)bag);
    if (MarkCache[hash] != bag) {
        // not in the cache, so verify it explicitly
        if (jl_gc_internal_obj_base_ptr(p) != p) {
            // not a valid object
            return;
        }
#ifdef COLLECT_MARK_CACHE_STATS
        if (MarkCache[hash])
            MarkCacheCollisions++;
#endif
        MarkCache[hash] = bag;
    }
    else {
#ifdef COLLECT_MARK_CACHE_STATS
        MarkCacheHits++;
#endif
    }
#endif
    // The following code is a performance optimization and
    // relies on Julia internals. It is functionally equivalent
    // to:
    //
    //     if (JMarkTyped(p, datatype_mptr)) YoungRef++;
    //
    switch (jl_astaggedvalue(p)->bits.gc) {
    case 0:
        if (JMarkTyped(p, datatype_mptr))
            YoungRef++;
        break;
    case 1:
        YoungRef++;
        break;
    case 2:
        JMarkTyped(p, datatype_mptr);
        break;
    case 3:
        break;
    }
}

void MarkJuliaWeakRef(void * p)
{
    // If `jl_nothing` gets passed in as an argument, it will not
    // be marked. This is harmless, because `jl_nothing` will always
    // be live regardless.
    if (JMarkTyped(p, jl_weakref_type))
        YoungRef++;
}
