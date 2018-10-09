/****************************************************************************
**
*W  julia_gc.c
**
**  This file stores code only required by the Julia garbage collector
**
**  The definitions of methods in this file can be found in gasman.h,
**  where the non-Julia versions of these methods live. See also boehm_gc.c
**  and gasman.c for two other garbage collector implementations.
**/

#include "code.h"
#include "funcs.h"
#include "gapstate.h"
#include "gasman.h"
#include "objects.h"
#include "plist.h"
#include "sysmem.h"
#include "system.h"
#include "vars.h"
#include "fibhash.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "julia.h"
#include "julia_gcext.h"

#define MARK_CACHE_BITS 16
#define MARK_CACHE_SIZE (1 << MARK_CACHE_BITS)

#define MARK_HASH(x) (FibHash((x), MARK_CACHE_BITS))

// #define STAT_MARK_CACHE

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
#ifdef STAT_MARK_CACHE
static UInt MarkCacheHits, MarkCacheAttempts, MarkCacheCollisions;
#endif


TNumInfoBags InfoBags[NUM_TYPES];

UInt SizeAllBags;

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

TNumFreeFuncBags TabFreeFuncBags[NUM_TYPES];

void InitFreeFuncBag(UInt type, TNumFreeFuncBags finalizer_func)
{
    TabFreeFuncBags[type] = finalizer_func;
}

void JFinalizer(jl_value_t * obj)
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

/****************************************************************************
**
**  Treap functionality
**
**  Treaps are probabilistically balanced binary trees. We use them for
**  range queries on pointers for conservative scans. Unlike red-black
**  trees, they're simple to implement, and unlike AVL trees, insertions
**  take an expected O(1) number of mutations to the tree, making them
**  more cache-friendly for an insertion-heavy workload.
**
**  Their downside is that they are probabilistic and that hypothetically,
**  degenerate cases can occur. However, these are very unlikely, and if
**  that turns out to be a problem, we can replace them with alternate
**  balanced trees (B-trees being a likely suitable candidate).
*/

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

typedef struct treap_t {
    struct treap_t *left, *right;
    size_t          prio;
    void *          addr;
    size_t          size;
} treap_t;

static treap_t * treap_free_list;

treap_t * alloc_treap(void)
{
    treap_t * result;
    if (treap_free_list) {
        result = treap_free_list;
        treap_free_list = treap_free_list->right;
    }
    else
        result = malloc(sizeof(treap_t));
    result->left = NULL;
    result->right = NULL;
    result->addr = NULL;
    result->size = 0;
    return result;
}

void free_treap(treap_t * t)
{
    t->right = treap_free_list;
    treap_free_list = t;
}

static inline int test_bigval_range(treap_t * node, void * p)
{
    char * l = node->addr;
    char * r = l + node->size;
    if (lt_ptr(p, l))
        return -1;
    if (!lt_ptr(p, r))
        return 1;
    return 0;
}


#define L(t) ((t)->left)
#define R(t) ((t)->right)

static inline void treap_rot_right(treap_t ** treap)
{
    /*       t                 l       */
    /*     /   \             /   \     */
    /*    l     r    -->    a     t    */
    /*   / \                     / \   */
    /*  a   b                   b   r  */
    treap_t * t = *treap;
    treap_t * l = L(t);
    treap_t * a = L(l);
    treap_t * b = R(l);
    L(l) = a;
    R(l) = t;
    L(t) = b;
    *treap = l;
}

static inline void treap_rot_left(treap_t ** treap)
{
    /*     t                   r       */
    /*   /   \               /   \     */
    /*  l     r    -->      t     b    */
    /*       / \           / \         */
    /*      a   b         l   a        */
    treap_t * t = *treap;
    treap_t * r = R(t);
    treap_t * a = L(r);
    treap_t * b = R(r);
    L(r) = t;
    R(r) = b;
    R(t) = a;
    *treap = r;
}

static void * treap_find(treap_t * treap, void * p)
{
    while (treap) {
        int c = test_bigval_range(treap, p);
        if (c == 0)
            return treap->addr;
        else if (c < 0)
            treap = L(treap);
        else
            treap = R(treap);
    }
    return NULL;
}

static void treap_insert(treap_t ** treap, treap_t * val)
{
    treap_t * t = *treap;
    if (t == NULL) {
        L(val) = NULL;
        R(val) = NULL;
        *treap = val;
    }
    else {
        int c = cmp_ptr(val->addr, t->addr);
        if (c < 0) {
            treap_insert(&L(t), val);
            if (L(t)->prio > t->prio) {
                treap_rot_right(treap);
            }
        }
        else if (c > 0) {
            treap_insert(&R(t), val);
            if (R(t)->prio > t->prio) {
                treap_rot_left(treap);
            }
        }
    }
}

static void treap_delete_node(treap_t ** treap)
{
    for (;;) {
        treap_t * t = *treap;
        if (L(t) == NULL) {
            *treap = R(t);
            free_treap(t);
            break;
        }
        else if (R(t) == NULL) {
            *treap = L(t);
            free_treap(t);
            break;
        }
        else {
            if (L(t)->prio > R(t)->prio) {
                treap_rot_right(treap);
                treap = &R(*treap);
            }
            else {
                treap_rot_left(treap);
                treap = &L(*treap);
            }
        }
    }
}

static int treap_delete(treap_t ** treap, void * addr)
{
    while (*treap != NULL) {
        int c = cmp_ptr(addr, (*treap)->addr);
        if (c == 0) {
            treap_delete_node(treap);
            return 1;
        }
        else if (c < 0) {
            treap = &L(*treap);
        }
        else {
            treap = &R(*treap);
        }
    }
    return 0;
}

static uint64_t xorshift_rng_state = 1;

static uint64_t xorshift_rng(void)
{
    uint64_t x = xorshift_rng_state;
    x = x ^ (x >> 12);
    x = x ^ (x << 25);
    x = x ^ (x >> 27);
    xorshift_rng_state = x;
    return x * (uint64_t)0x2545F4914F6CDD1DUL;
}


static treap_t * bigvals;

void alloc_bigval(void * addr, size_t size)
{
    treap_t * node = alloc_treap();
    node->addr = addr;
    node->size = size;
    node->prio = xorshift_rng();
    treap_insert(&bigvals, node);
}

void free_bigval(void * p)
{
    if (p) {
        treap_delete(&bigvals, p);
    }
}

static jl_module_t *   Module;
static jl_datatype_t * datatype_mptr;
static jl_datatype_t * datatype_bag;
static jl_datatype_t * datatype_largebag;
static Bag *           StackBottomBags;
static UInt            StackAlignBags;
static jl_ptls_t       JuliaTLS, SaveTLS;
static size_t          max_pool_obj_size;
static size_t          bigval_startoffset;
static UInt            YoungRef;


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

static inline int JMark(void * obj)
{
    return jl_gc_mark_queue_obj(JuliaTLS, (jl_value_t *)obj);
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

static void TryMark(void * p)
{
    jl_value_t * p2 = jl_gc_internal_obj_base_ptr(p);
    if (!p2) {
        // It is possible for p to point past the end of
        // the object, so we subtract one word from the
        // address. This is safe, as the object is preceded
        // by a larger header.
        p2 = treap_find(bigvals, (char *)p - 1);
        if (p2) {
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
    }
    else {
        // Prepopulate the mark cache with references we know
        // are valid and in current use.
        if (jl_typeis(p2, datatype_mptr))
            MarkCache[MARK_HASH((UInt)p2)] = (Bag)p2;
    }
    if (p2) {
        JMark(p2);
    }
}

static void TryMarkRange(void * start, void * end)
{
    if (lt_ptr(end, start)) {
        SWAP(void *, start, end);
    }
    char * p = align_ptr(start);
    char * q = (char *)end - sizeof(void *) + StackAlignBags;
    while (lt_ptr(p, q)) {
        TryMark(*(void **)p);
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

void GapRootScanner(int full)
{
    // mark our Julia module (this contains references to our custom data
    // types, which thus also will not be collected prematurely)
    JMark(Module);

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
    TryMarkRange((char *)registers + sizeof(syJmp_buf), StackBottomBags);

    // mark all global objects
    for (Int i = 0; i < GlobalCount; i++) {
        Bag p = *GlobalAddr[i];
        if (IS_BAG_REF(p)) {
            JMark(p);
        }
    }
}

void GapTaskScanner(jl_task_t * task, int root_task)
{
    size_t size;
    int    tid;
    void * stack = jl_task_stack_buffer(task, &size, &tid);
    if (stack && tid < 0) {
        TryMarkRange(stack, (char *)stack + size);
    }
}

static void PreGCHook(int full)
{
    // It is possible for the garbage collector to be invoked from a
    // different thread other than the main thread that is running
    // GAP. So we save the TLS pointer temporarily and restore it
    // afterwards. In the long run, JuliaTLS needs to simply become
    // a thread-local variable.
    SaveTLS = JuliaTLS;
    JuliaTLS = jl_get_ptls_states();
    /* information at the beginning of garbage collections                 */
    SyMsgsBags(full, 0, 0);
    memset(MarkCache, 0, sizeof(MarkCache));
#ifdef STAT_MARK_CACHE
    MarkCacheHits = MarkCacheAttempts = MarkCacheCollisions = 0;
#endif
}

static void PostGCHook(int full)
{
    JuliaTLS = SaveTLS;
    /* information at the end of garbage collections                 */
    UInt totalAlloc = 0;    // FIXME -- is this data even available?
    SyMsgsBags(full, 6, totalAlloc);
#ifdef STAT_MARK_CACHE
    /* printf("\n>>>Attempts: %ld\nHit rate: %lf\nCollision rate: %lf\n",
      (long) MarkCacheAttempts,
      (double) MarkCacheHits/(double)MarkCacheAttempts,
      (double) MarkCacheCollisions/(double)MarkCacheAttempts
      ); */
#endif
}

// the Julia marking function for master pointer objects (i.e., this function
// is called by the Julia GC whenever it marks a GAP master pointer object)
static uintptr_t JMarkMPtr(jl_ptls_t ptls, jl_value_t * obj)
{
    if (!*(void **)obj)
        return 0;
    if (JMark(BAG_HEADER((Bag)obj)))
        return 1;
    return 0;
}

// the Julia marking function for bags (i.e., this function is called by the
// Julia GC whenever it marks a GAP bag object)
static uintptr_t JMarkBag(jl_ptls_t ptls, jl_value_t * obj)
{
    BagHeader * hdr = (BagHeader *)obj;
    Bag         contents = (Bag)(hdr + 1);
    UInt        tnum = hdr->type;
    YoungRef = 0;
    TabMarkFuncBags[tnum]((Bag)&contents);
    return YoungRef;
}

void InitBags(UInt initial_size, Bag * stack_bottom, UInt stack_align)
{
    // HOOK: initialization happens here.
    for (UInt i = 0; i < NUM_TYPES; i++)
        TabMarkFuncBags[i] = MarkAllSubBags;
    // These callbacks need to be set before initialization so
    // that we can track objects allocated during `jl_init()`.
    jl_gc_set_cb_notify_external_alloc(alloc_bigval, 1);
    jl_gc_set_cb_notify_external_free(free_bigval, 1);
    bigval_startoffset = jl_gc_external_obj_hdr_size();
    max_pool_obj_size = jl_gc_max_internal_obj_size();
    jl_gc_enable_conservative_gc_support();
    jl_init();
    JuliaTLS = jl_get_ptls_states();
    // These callbacks potentially require access to the Julia
    // TLS and thus need to be installed after initialization.
    jl_gc_set_cb_root_scanner(GapRootScanner, 1);
    jl_gc_set_cb_task_scanner(GapTaskScanner, 1);
    jl_gc_set_cb_pre_gc(PreGCHook, 1);
    jl_gc_set_cb_post_gc(PostGCHook, 1);
    // jl_gc_enable(0); /// DEBUGGING

    Module = jl_new_module(jl_symbol("ForeignGAP"));
    Module->parent = jl_main_module;
    jl_set_const(jl_main_module, jl_symbol("ForeignGAP"),
                 (jl_value_t *)Module);
    datatype_mptr = jl_new_foreign_type(jl_symbol("MPtr"), Module,
                                        jl_any_type, JMarkMPtr, NULL, 1, 0);
    datatype_bag = jl_new_foreign_type(jl_symbol("Bag"), Module, jl_any_type,
                                       JMarkBag, JFinalizer, 1, 0);
    datatype_largebag =
        jl_new_foreign_type(jl_symbol("LargeBag"), Module, jl_any_type,
                            JMarkBag, JFinalizer, 1, 1);

    // export datatypes to Julia level
    jl_set_const(Module, jl_symbol("MPtr"), (jl_value_t *)datatype_mptr);
    jl_set_const(Module, jl_symbol("Bag"), (jl_value_t *)datatype_bag);
    jl_set_const(Module, jl_symbol("LargeBag"),
                 (jl_value_t *)datatype_largebag);

    GAP_ASSERT(jl_is_datatype(datatype_mptr));
    GAP_ASSERT(jl_is_datatype(datatype_bag));
    GAP_ASSERT(jl_is_datatype(datatype_largebag));
    StackBottomBags = stack_bottom;
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
    UInt old_type = header->type;

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
        Panic("cannot change bag type to one which requires a 'free' callback");


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

    BagHeader * header = AllocateBagMemory(type, alloc_size);

    header->type = type;
    header->flags = 0;
    header->size = size;

    // allocate the new masterpointer
    bag = jl_gc_alloc_typed(JuliaTLS, sizeof(void *), datatype_mptr);
    SET_PTR_BAG(bag, DATA(header));

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
#ifdef STAT_MARK_CACHE
    MarkCacheAttempts++;
#endif
    UInt hash = MARK_HASH((UInt)bag);
    if (MarkCache[hash] != bag) {
        // not in the cache, so verify it explicitly
        if (jl_gc_internal_obj_base_ptr(p) != p) {
            // not a valid object
            return;
        }
#ifdef STAT_MARK_CACHE
        if (MarkCache[hash])
            MarkCacheCollisions++;
#endif
        MarkCache[hash] = bag;
    } else {
#ifdef STAT_MARK_CACHE
        MarkCacheHits++;
#endif
    }
    // The following code is a performance optimization and
    // relies on Julia internals. It is functionally equivalent
    // to:
    //
    //     if (JMark(p)) YoungRef++;
    //
    switch (jl_astaggedvalue(p)->bits.gc) {
    case 0:
        if (JMark(p))
            YoungRef++;
        break;
    case 1:
        YoungRef++;
        break;
    case 2:
        JMark(p);
    case 3:
        break;
    }
}

inline void MarkArrayOfBags(const Bag array[], UInt count)
{
    for (UInt i = 0; i < count; i++) {
        MarkBag(array[i]);
    }
}

void MarkNoSubBags(Bag bag)
{
}

void MarkOneSubBags(Bag bag)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag), 1);
}

void MarkTwoSubBags(Bag bag)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag), 2);
}

void MarkThreeSubBags(Bag bag)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag), 3);
}

void MarkFourSubBags(Bag bag)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag), 4);
}

void MarkAllSubBags(Bag bag)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag), SIZE_BAG(bag) / sizeof(Bag));
}

void MarkAllButFirstSubBags(Bag bag)
{
    MarkArrayOfBags(CONST_PTR_BAG(bag) + 1, SIZE_BAG(bag) / sizeof(Bag) - 1);
}
