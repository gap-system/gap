
/****************************************************************************
**
*W  gap_boehm_gc.h
**
**  This file stores code only required by the boehm garbage collector
**
**  It should NOT be generally included, it is only for use in gasman.c
**
**  The definitions of methods in this file can be found in gasman.c,
**  where the non-boehm versions of these methods live.
**/


#ifndef BOEHM_GC
#error hpc_boehm_gc.h can only be used with the boehm GC collector
#endif

#include <stdlib.h>
#include <stdio.h>
#include <pthread.h>

#define LARGE_GC_SIZE (8192 * sizeof(UInt))
#define TL_GC_SIZE (256 * sizeof(UInt))

#ifndef DISABLE_GC
#include <gc/gc.h>
#include <gc/gc_inline.h>
#include <gc/gc_typed.h>
#include <gc/gc_mark.h>
#endif


#include <src/code.h>                   /* coder */
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/tls.h>                /* thread-local storage */
#ifdef TRACK_CREATOR
/* Need CURR_FUNC and NAME_FUNC() */
#include <src/calls.h>                  /* calls */
#include <src/vars.h>                   /* variables */
#endif

/****************************************************************************
**
*V  DSInfoBags[<type>]  . . . .  . . . . . . . . . .  region info for bags
*/

static char DSInfoBags[NTYPES];

#define DSI_TL 0
#define DSI_PUBLIC 1
#define DSI_PROTECTED 2

void MakeBagTypePublic(int type)
{
    DSInfoBags[type] = DSI_PUBLIC;
}

void MakeBagTypeProtected(int type)
{
    DSInfoBags[type] = DSI_PROTECTED;
}

Bag MakeBagPublic(Bag bag)
{
    MEMBAR_WRITE();
    REGION(bag) = 0;
    return bag;
}

Bag MakeBagReadOnly(Bag bag)
{
    MEMBAR_WRITE();
    REGION(bag) = ReadOnlyRegion;
    return bag;
}

Region *RegionBag(Bag bag)
{
    Region *result = REGION(bag);
    MEMBAR_READ();
    return result;
}

/****************************************************************************
**
*F  InitFinalizerFuncBags(<type>,<finalizer-func>)  . . . . install finalizer
*/

FinalizerFunction TabFinalizerFuncBags [ NTYPES ];

void InitFinalizerFuncBags(
    UInt		type,
    FinalizerFunction   finalizer_func)
{
  TabFinalizerFuncBags[type] = finalizer_func;
}

#ifndef WARD_ENABLED

void StandardFinalizer( void * bagContents, void * data )
{
  Bag bag;
  void *bagContents2;
  bagContents2 = ((char *) bagContents) + HEADER_SIZE * sizeof (Bag *);
  bag = (Bag) &bagContents2;
  TabFinalizerFuncBags[TNUM_BAG(bag)](bag);
}

#endif


#ifdef BOEHM_GC
static GC_descr GCDesc[MAX_GC_PREFIX_DESC+1];
static unsigned GCKind[MAX_GC_PREFIX_DESC+1];
static GC_descr GCMDesc[MAX_GC_PREFIX_DESC+1];
static unsigned GCMKind[MAX_GC_PREFIX_DESC+1];
#endif

#ifdef BOEHM_GC

/*
 * Build memory layout information for Boehm GC.
 *
 * Bitmapped type descriptors have a bit set if the word at the
 * corresponding offset may contain a reference. This is done
 * by first creating a bitmap and then using GC_make_descriptor()
 * to build a descriptor from the bitmap. Memory for a specific
 * type layout can be allocated with GC_malloc_explicitly_typed()
 * and GC_malloc_explicitly_typed_ignore_off_page().
 *
 * We also create a new 'kind' for each collector. Kinds have their
 * own associated free lists and do not require to have type information
 * stored in each bag, thus potentially saving some memory. Allocating
 * memory of a specific kind is done with GC_generic_malloc(). There
 * is no public _ignore_off_page() version for this call, so we use
 * GC_malloc_explicitly_typed_ignore_off_page() instead, given that
 * the overhead is negligible for large objects.
 */

void BuildPrefixGCDescriptor(unsigned prefix_len) {

  if (prefix_len) {
    GC_word bits[1] = {0};
    unsigned i;
    for (i=0; i<prefix_len; i++)
      GC_set_bit(bits, (i + HEADER_SIZE));
    GCDesc[prefix_len] = GC_make_descriptor(bits, prefix_len + HEADER_SIZE);
    GC_set_bit(bits, 0);
    GCMDesc[prefix_len] = GC_make_descriptor(bits, prefix_len + HEADER_SIZE);
  } else {
    GCDesc[prefix_len] = GC_DS_LENGTH;
    GCMDesc[prefix_len] = GC_DS_LENGTH | sizeof(void *);
  }
  GCKind[prefix_len] = GC_new_kind(GC_new_free_list(), GCDesc[prefix_len],
    0, 1);
  GCMKind[prefix_len] = GC_new_kind(GC_new_free_list(), GCMDesc[prefix_len],
    0, 0);
}

#endif

#ifdef BOEHM_GC
static void TLAllocatorInit(void);
#endif

#ifdef BOEHM_GC

#define GRANULE_SIZE (2 * sizeof(UInt))

static unsigned char TLAllocatorSeg[TL_GC_SIZE / GRANULE_SIZE + 1];
static unsigned TLAllocatorSize[TL_GC_SIZE / GRANULE_SIZE];
static UInt TLAllocatorMaxSeg;

static void TLAllocatorInit(void) {
  unsigned stage = 16;
  unsigned inc = 1;
  unsigned i = 0;
  unsigned k = 0;
  unsigned j;
  unsigned max = TL_GC_SIZE / GRANULE_SIZE;
  while (i <= max) {
    if (i == stage) {
      stage *= 2;
      inc *= 2;
    }
    TLAllocatorSize[k] = i * GRANULE_SIZE;
    TLAllocatorSeg[i] = k;
    for (j=1; j<inc; j++) {
      if (i + j <= max)
        TLAllocatorSeg[i+j] = k+1;
    }
    i += inc;
    k ++;
  }
  TLAllocatorMaxSeg = k;
  if (MAX_GC_PREFIX_DESC * sizeof(void *) > sizeof(TLS(FreeList)))
    abort();
}

/****************************************************************************
**
*F  AllocateBagMemory( <gc_type>, <type>, <size> )
**
**  Allocate memory for a new bag.
**
**  'AllocateBagMemory' is an auxiliary routine for the Boehm GC that
**  allocates memory from the appropriate pool. 'gc_type' is -1 if all words
**  in the bag can refer to other bags, 0 if the bag will not contain any
**  references to other bags, and > 0 to indicate a specific memory layout
**  descriptor.
**/
void *AllocateBagMemory(int gc_type, int type, UInt size)
{
    void *result = NULL;
    if (size <= TL_GC_SIZE) {
      UInt alloc_seg, alloc_size;
      alloc_size = (size + GRANULE_SIZE - 1 ) / GRANULE_SIZE;
      alloc_seg = TLAllocatorSeg[alloc_size];
      alloc_size = TLAllocatorSize[alloc_seg];
      if (!TLS(FreeList)[gc_type+1])
        TLS(FreeList)[gc_type+1] =
	  GC_malloc(sizeof(void *) * TLAllocatorMaxSeg);
      if (!(result = TLS(FreeList)[gc_type+1][alloc_seg])) {
        if (gc_type < 0)
	  TLS(FreeList)[0][alloc_seg] = GC_malloc_many(alloc_size);
	else
	  GC_generic_malloc_many(alloc_size, GCMKind[gc_type],
	    &TLS(FreeList)[gc_type+1][alloc_seg]);
	result = TLS(FreeList)[gc_type+1][alloc_seg];
      }
      TLS(FreeList)[gc_type+1][alloc_seg] = *(void **)result;
      memset(result, 0, alloc_size);
    } else {
      if (gc_type >= 0)
        result = GC_generic_malloc(size, GCKind[gc_type]);
      else
        result = GC_malloc(size);
    }
    if (TabFinalizerFuncBags[type])
      GC_register_finalizer_no_order(result, StandardFinalizer,
	NULL, NULL, NULL);
    return result;
}
#endif

void LockFinalizer(void *lock, void *data)
{
  pthread_rwlock_destroy(lock);
}

Region *NewRegion(void)
{
  Region *result;
  pthread_rwlock_t *lock;
  Obj region_obj;
#ifndef DISABLE_GC
  result = GC_malloc(sizeof(Region) + (MAX_THREADS+1)*sizeof(unsigned char));
  lock = GC_malloc_atomic(sizeof(*lock));
  GC_register_finalizer(lock, LockFinalizer, NULL, NULL, NULL);
#else
  result = malloc(sizeof(Region) + (MAX_THREADS+1)*sizeof(unsigned char));
  memset(result, 0, sizeof(Region) + (MAX_THREADS+1)*sizeof(unsigned char));
  lock = malloc(sizeof(*lock));
#endif
  pthread_rwlock_init(lock, NULL);
  region_obj = NewBag(T_REGION, sizeof(Region *));
  MakeBagPublic(region_obj);
  *(Region **)(ADDR_OBJ(region_obj)) = result;
  result->obj = region_obj;
  result->lock = lock;
  return result;
}

void *AllocateMemoryBlock(UInt size) {
  return GC_malloc(size);
}

int TabMarkTypeBags [ NTYPES ];

void InitMarkFuncBags (
    UInt                type,
    TNumMarkFuncBags    mark_func )
{
    int mark_type;
    if (mark_func == MarkNoSubBags)
      mark_type = 0;
    else if (mark_func == MarkAllSubBags)
      mark_type = -1;
    else if (mark_func == MarkOneSubBags)
      mark_type = 1;
    else if (mark_func == MarkTwoSubBags)
      mark_type = 2;
    else if (mark_func == MarkThreeSubBags)
      mark_type = 3;
    else if (mark_func == MarkFourSubBags)
      mark_type = 4;
    else
      mark_type = -1;
    TabMarkTypeBags[type] = mark_type;
}

void            InitBags (
    TNumAllocFuncBags   alloc_func,
    UInt                initial_size,
    TNumStackFuncBags   stack_func,
    Bag *               stack_bottom,
    UInt                stack_align,
    UInt                cache_size,
    UInt                dirty,
    TNumAbortFuncBags   abort_func )
{
    UInt                i;              /* loop variable                   */

    /* install the marking functions                                       */
    for ( i = 0; i < 255; i++ ) {
        TabMarkFuncBags[i] = MarkAllSubBagsDefault;
	TabMarkTypeBags[i] = -1;
    }
#ifndef DISABLE_GC
    if (!getenv("GC_MARKERS")) {
      /* The Boehm GC does not have an API to set the number of
       * markers for the parallel mark and sweep implementation,
       * so we use the documented environment variable GC_MARKERS
       * instead. However, we do not override it if it's already
       * set.
       */
      static char marker_env_str[32];
      unsigned num_markers = 2;
      extern UInt SyNumProcessors;
      extern UInt SyNumGCThreads;
      if (!SyNumGCThreads)
        SyNumGCThreads = SyNumProcessors;
      if (SyNumGCThreads) {
        if (SyNumGCThreads <= MAX_GC_THREADS)
	  num_markers = (unsigned) SyNumProcessors;
	else
	  num_markers = MAX_GC_THREADS;
      }
      sprintf(marker_env_str, "GC_MARKERS=%u", num_markers);
      putenv(marker_env_str);
    }
    GC_set_all_interior_pointers(0);
    GC_init();
    GC_set_free_space_divisor(1);
    TLAllocatorInit();
    GC_register_displacement(0);
    GC_register_displacement(HEADER_SIZE*sizeof(Bag));
    initial_size *= 1024;
    if (GC_get_heap_size() < initial_size)
      GC_expand_hp(initial_size - GC_get_heap_size());
    if (SyStorKill)
      GC_set_max_heap_size(SyStorKill * 1024);
    AddGCRoots();
    CreateMainRegion();
    for (i=0; i<=MAX_GC_PREFIX_DESC; i++) {
      BuildPrefixGCDescriptor(i);
      /* This is necessary to initialize some internal structures
       * in the garbage collector: */
      GC_generic_malloc((HEADER_SIZE + i) * sizeof(UInt), GCMKind[i]);
    }
#endif /* DISABLE_GC */
}

UInt CollectBags (
    UInt                size,
    UInt                full )
{
#ifndef DISABLE_GC
    GC_gcollect();
#endif
    return 1;	
}

void RetypeBagIfWritable( Obj obj, UInt new_type )
{
  if (CheckWriteAccess(obj))
    RetypeBag(obj, new_type);
}

void            RetypeBag (
    Bag                 bag,
    UInt                new_type )
{

    UInt old_type = TNUM_BAG(bag);

    /* change the size-type word                                           */
#ifdef USE_NEWSHAPE
    *(*bag-HEADER_SIZE) &= 0xFFFFFFFFFFFFFF00L;
    *(*bag-HEADER_SIZE) |= new_type;
#else
    *(*bag-HEADER_SIZE) = new_type;
#endif
    {
      int old_gctype, new_gctype;
      UInt size;
      void *new_mem, *old_mem;
      old_gctype = TabMarkTypeBags[old_type];
      new_gctype = TabMarkTypeBags[new_type];
      if (old_gctype != new_gctype) {
        size = SIZE_BAG(bag) + HEADER_SIZE * sizeof(Bag);
	new_mem = AllocateBagMemory(new_gctype, new_type, size);
	old_mem = PTR_BAG(bag);
	old_mem = ((char *) old_mem) - HEADER_SIZE * sizeof(Bag);
	memcpy(new_mem, old_mem, size);
	PTR_BAG(bag) = (void *)(((char *)new_mem) + HEADER_SIZE * sizeof(Bag));
      }
    }
    switch (DSInfoBags[new_type]) {
      case DSI_PUBLIC:
        REGION(bag) = NULL;
        break;
      case DSI_PROTECTED:
        REGION(bag) = ProtectedRegion;
        break;
    }
}

Bag NewBag (
    UInt                type,
    UInt                size )
{
    Bag                 bag;            /* identifier of the new bag       */
    Bag *               dst;            /* destination of the new bag      */
    UInt		alloc_size;

    alloc_size = HEADER_SIZE*sizeof(Bag) + size;
#ifndef DISABLE_GC
#ifndef TRACK_CREATOR
    bag = GC_malloc(2*sizeof(Bag *));
#else
    bag = GC_malloc(4*sizeof(Bag *));
    if (TLS(PtrLVars)) {
      bag[2] = (void *)(CURR_FUNC);
      if (TLS(CurrLVars) != TLS(BottomLVars)) {
        Obj plvars = PARENT_LVARS(TLS(CurrLVars));
        bag[3] = (void *) (FUNC_LVARS(plvars));
      }
    }
#endif
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
    /* While we use the Boehm GC without the "all interior pointers"
     * option, stack references to the interior of an object will
     * still be valid from any reference on the stack. This can lead,
     * for example, to a 1GB string never being freed if there's an
     * integer on the stack that happens to also be a reference to
     * any character inside that string. The garbage collector does
     * this because after compiler optimizations (especially reduction
     * in strength) references to the beginning of an object may be
     * lost.
     *
     * However, this is not generally a risk with GAP objects, because
     * master pointers on the heap will always retain a reference to
     * the start of the object (or, more precisely, to the first byte
     * past the header area). Hence, compiler optimizations pose no
     * actual risk unless the master pointer is destroyed also.
     *
     * To avoid the scenario where large objects do not get deallocated,
     * we therefore use the _ignore_off_page() calls. One caveat here
     * is that these calls do not use thread-local allocation, making
     * them somewhat slower. Hence, we only use them for sufficiently
     * large objects.
     */
    dst = AllocateBagMemory(TabMarkTypeBags[type], type, alloc_size);
#else
    bag = malloc(2*sizeof(Bag *));
    dst = malloc(alloc_size);
    memset(dst, 0, alloc_size);
#endif /* DISABLE_GC */

    /* enter size-type words                                               */
#ifdef USE_NEWSHAPE
    *dst++ = (Bag)(size << 16 | type);
#else
    *dst++ = (Bag)(type);
    *dst++ = (Bag)(size);
#endif


    /* enter link word                                                     */
    *dst++ = bag;

    /* set the masterpointer                                               */
    PTR_BAG(bag) = dst;
    switch (DSInfoBags[type]) {
    case DSI_TL:
      REGION(bag) = CurrentRegion();
      break;
    case DSI_PUBLIC:
      REGION(bag) = NULL;
      break;
    case DSI_PROTECTED:
      REGION(bag) = ProtectedRegion;
      break;
    }

    /* return the identifier of the new bag                                */
    return bag;
}

UInt ResizeBag (
	Bag                 bag,
	UInt                new_size )
{
	UInt                type;           /* type of the bag                 */
	UInt                old_size;       /* old size of the bag             */
	Bag *               dst;            /* destination in copying          */
	Bag *               src;            /* source in copying               */
	UInt                alloc_size;

	/* check the size                                                      */

#ifdef TREMBLE_HEAP
	CollectBags(0,0);
#endif

	/* get type and old size of the bag                                    */
	type     = TNUM_BAG(bag);
	old_size = SIZE_BAG(bag);

#ifdef  COUNT_BAGS
	/* update the statistics                                               */
	InfoBags[type].sizeLive += new_size - old_size;
	InfoBags[type].sizeAll  += new_size - old_size;
#endif
	SizeAllBags             += new_size - old_size;

#ifndef DISABLE_GC
	alloc_size = GC_size(PTR_BAG(bag)-HEADER_SIZE);
	/* An alternative implementation would be to compare
	 * new_size <= alloc_size in the following test in order
	 * to avoid reallocations for alternating contractions
	 * and expansions. However, typed allocation in the Boehm
	 * GC stores layout information in the last word of a memory
	 * block and we may accidentally overwrite this information,
	 * because GC_size() includes that extraneous word when
	 * returning the size of a memory block.
	 *
	 * This is technically a bug in GC_size(), but until and
	 * unless there is an upstream fix, we'll do it the safe
	 * way.
	 */
	if ( new_size <= old_size
			 && HEADER_SIZE*sizeof(Bag) + new_size >= alloc_size * 3/4) {
#else
	if (new_size <= old_size) {
#endif /* DISABLE_GC */

			/* change the size word                                            */
#ifdef USE_NEWSHAPE
		*(*bag-2) = (new_size << 16 | type);
#else
		*(*bag-2) = new_size;
#endif
	}


	/* if the bag is enlarged                                              */
	else {
			alloc_size = HEADER_SIZE*sizeof(Bag) + new_size;
			if (new_size == 0)
					alloc_size++;
#ifndef DISABLE_GC
			dst = AllocateBagMemory(TabMarkTypeBags[type], type, alloc_size);
#else
			dst       = malloc( alloc_size );
			memset(dst, 0, alloc_size);
#endif

			/* leave magic size-type word  for the sweeper, type must be 255   */
#ifdef USE_NEWSHAPE
			*dst++ = (Bag)(new_size << 16 | type);
#else
			/* enter the new size-type word                                    */
			*dst++ = (Bag)type;
			*dst++ = (Bag)new_size;
#endif


			*dst++ = bag;
			/* set the masterpointer                                           */
			src = PTR_BAG(bag);
			PTR_BAG(bag) = dst;

			if (dst != src) {
					memcpy( dst, src, old_size < new_size ? old_size : new_size );
			} else if (new_size < old_size) {
					memset(dst+new_size, 0, old_size - new_size);
			}
	}
	/* return success                                                      */
	return 1;
}


/*****************************************************************************
** The following functions are not required by boehm, so empty implementations
** are provided
**
*/

void            InitMsgsFuncBags (
    TNumMsgsFuncBags    msgs_func )
{ }

void InitGlobalBag (
    Bag *               addr,
    const Char *        cookie )
{ }

void SortGlobals( UInt byWhat )
{ }

Bag * GlobalByCookie(
       const Char * cookie )
{
    return (Bag *) 0;
}

void CallbackForAllBags(
     void (*func)(Bag) )
{ }

void StartRestoringBags( UInt nBags, UInt maxSize)
{ }

Bag NextBagRestoring( UInt size, UInt type)
{ return 0; }

void FinishedRestoringBags( void )
{ }

void            InitCollectFuncBags (
    TNumCollectFuncBags before_func,
    TNumCollectFuncBags after_func )
{ }
