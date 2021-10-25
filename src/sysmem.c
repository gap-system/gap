/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file implements functions and variables related to memory management,
**  for use by GASMAN.
**
*/

#include "sysmem.h"

#include "gaptime.h"
#include "stats.h"
#include "sysfiles.h"
#include "sysopt.h"

#include "config.h"

#ifdef GAP_MEM_CHECK
#include <fcntl.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#ifdef HAVE_MADVISE
#include <sys/mman.h>
#endif

#ifdef HAVE_VM_ALLOCATE
#include <mach/mach.h>
#endif


Int SyStorMax;
SyStorEnum SyStorOverrun;
Int SyStorKill;
Int SyStorMin;

UInt SyAllocPool;

UInt SyMsgsFlagBags;


/****************************************************************************
**
*F * * * * * * * * * * * * * * gasman interface * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  SyMsgsBags( <full>, <phase>, <nr> ) . . . . . . . display Gasman messages
**
**  'SyMsgsBags' is the function that is used by Gasman to  display  messages
**  during garbage collections.
*/

Int SyGasmanNumbers[2][9];

void SyMsgsBags (
    UInt                full,
    UInt                phase,
    Int                 nr )
{
    Char                cmd [3];        /* command string buffer           */
    Char                str [32];       /* string buffer                   */
    Char                ch;             /* leading character               */
    UInt                i;              /* loop variable                   */
    Int                 copynr;         /* copy of <nr>                    */
    UInt                shifted;        /* non-zero if nr > 10^6 and so
                                           has to be shifted down          */
    static UInt         tstart = 0;

    /* remember the numbers */
    if (phase > 0)
      {
        SyGasmanNumbers[full][phase] = nr;
        
        /* in a full GC clear the partial numbers */
        if (full)
          SyGasmanNumbers[0][phase] = 0;
      }
    else
      {
        SyGasmanNumbers[full][0]++;
        tstart = SyTime();
      }
    if (phase == 6) 
      {
        UInt x = SyTime() - tstart;
        SyGasmanNumbers[full][7] = x;
        SyGasmanNumbers[full][8] += x;
      }

    /* convert <nr> into a string with leading blanks                      */
    copynr = nr;
    ch = '0';  str[7] = '\0';
    shifted = (nr >= ((phase % 2) ? 10000000 : 1000000)) ? 1 : 0;
    if (shifted)
      {
        nr /= 1024;
      }
    if ((phase % 2) == 1 && shifted && nr > 1000000)
      {
        shifted++;
        nr /= 1024;
      }
      
    for ( i = ((phase % 2) == 1 && shifted) ? 6 : 7 ;
          i != 0; i-- ) {
        if      ( 0 < nr ) { str[i-1] = '0' + ( nr) % 10;  ch = ' '; }
        else if ( nr < 0 ) { str[i-1] = '0' + (-nr) % 10;  ch = '-'; }
        else               { str[i-1] = ch;                ch = ' '; }
        nr = nr / 10;
    }
    nr = copynr;

    if ((phase % 2) == 1 && shifted == 1)
      str[6] = 'K';
    if ((phase % 2) == 1 && shifted == 2)
      str[6] = 'M';

    

    /* ordinary full garbage collection messages                           */
    if ( 1 <= SyMsgsFlagBags && full ) {
        if ( phase == 0 ) { SyFputs( "#G  FULL ", 3 );                     }
        if ( phase == 1 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 2 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb live  " : "kb live  ", 3 ); }
        if ( phase == 3 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 4 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb dead  " : "kb dead  ", 3 ); }
        if ( phase == 5 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 6 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb free\n" : "kb free\n", 3 ); }
    }

    /* ordinary partial garbage collection messages                        */
    if ( 2 <= SyMsgsFlagBags && ! full ) {
        if ( phase == 0 ) { SyFputs( "#G  PART ", 3 );                     }
        if ( phase == 1 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 2 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb+live  ":"kb+live  ", 3 ); }
        if ( phase == 3 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 4 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb+dead  ":"kb+dead  ", 3 ); }
        if ( phase == 5 ) { SyFputs( str, 3 );  SyFputs( "/",         3 ); }
        if ( phase == 6 ) { SyFputs( str, 3 );  SyFputs( shifted ? "mb free\n":"kb free\n", 3 ); }
    }
    /* package (window) mode full garbage collection messages              */
    if ( phase != 0 ) {
      cmd[0] = '@';
      cmd[1] = ( full ? '0' : ' ' ) + phase;
      cmd[2] = '\0';
      i = 0;
      for ( ; 0 < nr; nr /=10 )
        str[i++] = '0' + (nr % 10);
      str[i++] = '+';
      str[i++] = '\0';
      syWinPut( 1, cmd, str );
    }
}


/****************************************************************************
**
*f  SyAllocBags( <size>, <need> )
**
**  For UNIX, 'SyAllocBags' calls 'sbrk', which will work on most systems.
**
**  Note that   it may  happen that  another   function   has  called  'sbrk'
**  between  two calls to  'SyAllocBags',  so that the  next  allocation will
**  not be immediately adjacent to the last one.   In this case 'SyAllocBags'
**  returns the area to the operating system,  and either returns 0 if <need>
**  was 0 or aborts GAP if <need> was 1.  'SyAllocBags' will refuse to extend
**  the workspace beyond 'SyStorMax' or to reduce it below 'SyStorMin'.
*/

static UInt pagesize = 4096;   /* Will be initialised if SyAllocPool > 0 */

static inline UInt SyRoundUpToPagesize(UInt x)
{
    UInt r;
    r = x % pagesize;
    return r == 0 ? x : x - r + pagesize;
}

static void *   POOL = NULL;
static UInt *** syWorkspace = NULL;
static UInt     syWorksize = 0;

static inline UInt *** EndOfWorkspace(void)
{
    return syWorkspace + syWorksize * (1024 / sizeof(UInt **));
}

#ifdef GAP_MEM_CHECK

/***************************************************************
 *  GAP_MEM_CHECK
 *
 * The following code is used by GAP_MEM_CHECK support, which is
 * documented in gasman.c
 */

#if !defined(HAVE_MADVISE) || !defined(SYS_IS_64_BIT)
#error GAP_MEM_CHECK requires MADVISE and 64-bit OS
#endif

void SyMAdviseFree(void)
{
}


enum { membufcount = 64 };
static void * membufs[membufcount];
static UInt   membufSize;

UInt GetMembufCount(void)
{
    return membufcount;
}

void * GetMembuf(UInt i)
{
    return membufs[i];
}

UInt GetMembufSize(void)
{
    return membufSize;
}

static int order_pointers(const void * a, const void * b)
{
    void * const * pa = a;
    void * const * pb = b;
    if (*pa < *pb) {
        return -1;
    }
    else if (*pa > *pb) {
        return 1;
    }
    else {
        return 0;
    }
}

static void * SyAnonMMap(size_t size)
{
    size = SyRoundUpToPagesize(size);
    membufSize = size;

    char filename[100] = {0};
    snprintf(filename, sizeof(filename), "/dev/shm/gapmem.%d", getpid());
    int fd = open(filename, O_RDWR | O_CREAT | O_EXCL, 0600);
    unlink(filename);

    if (fd < 0) {
        Panic("Fatal error setting up multiheap");
    }

    if (ftruncate(fd, size) < 0) {
        Panic("Fatal error setting up multiheap!");
    }

    for (int i = 0; i < membufcount; ++i) {
        membufs[i] =
            mmap(NULL, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
        if (membufs[i] == MAP_FAILED) {
            Panic("Fatal error setting up multiheap!!");
        }
    }

    // Sort the membufs, so membufs[0] is the first in memory.
    // We will always refer to the copy of the master pointers in
    // membufs[0].
    qsort(membufs, membufcount, sizeof(void *), order_pointers);
    return membufs[0];
}

int SyTryToIncreasePool(void)
{
    return -1;
}

#elif defined(HAVE_MADVISE)

#ifndef MAP_ANONYMOUS
#define MAP_ANONYMOUS MAP_ANON
#endif

#ifdef SYS_IS_CYGWIN32
#define GAP_MMAP_FLAGS MAP_PRIVATE|MAP_ANONYMOUS|MAP_NORESERVE
#else
#define GAP_MMAP_FLAGS MAP_PRIVATE|MAP_ANONYMOUS
#endif

static void *SyMMapStart = NULL;   /* Start of mmap'ed region for POOL */
static void *SyMMapEnd;            /* End of mmap'ed region for POOL */
static void *SyMMapAdvised;        /* We have already advised about non-usage
                                      up to here. */

void SyMAdviseFree(void)
{
    size_t size;
    void *from;
    if (!SyMMapStart) 
        return;
    from = EndOfWorkspace();
    from = (void *)SyRoundUpToPagesize((UInt) from);
    if (from > SyMMapAdvised) {
        SyMMapAdvised = from;
        return;
    }
    if (from < SyMMapStart || from >= SyMMapEnd || from >= SyMMapAdvised)
        return;
    size = (char *)SyMMapAdvised - (char *)from;
#if defined(MADV_FREE)
    madvise(from, size, MADV_FREE);
#elif defined(MADV_DONTNEED)
    madvise(from, size, MADV_DONTNEED);
#endif
    SyMMapAdvised = from;
    /* On Darwin, MADV_FREE and MADV_DONTNEED will not actually update
     * a process's resident memory until those pages are explicitly
     * unmapped or needed elsewhere.
     *
     * The following code accomplishes this, but is not portable and
     * potentially not safe, since the POSIX standard does not make
     * any sufficiently strong promises with regard to the use of
     * MAP_FIXED.
     *
     * We probably don't want to do this and just live with pages
     * remaining with a process until reused even if that appears to
     * inflate the resident set size.
     *
     * Maybe we do want to do this until it breaks to avoid questions
     * by users...
     */
#if !defined(NO_DIRTY_OSX_MMAP_TRICK) && defined(__APPLE__)
    if (mmap(from, size, PROT_NONE,
            MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED, -1, 0) != from) {
        Panic("OS X trick to free pages did not work!");
    }
    if (mmap(from, size, PROT_READ|PROT_WRITE,
            MAP_PRIVATE|MAP_ANONYMOUS|MAP_FIXED, -1, 0) != from) {
        Panic("OS X trick to free pages did not work!!");
    }
#endif
}

static void * SyAnonMMap(size_t size)
{
    void *result;
    size = SyRoundUpToPagesize(size);
#ifdef SYS_IS_64_BIT
    /* The following is at 16 Terabyte: */
    result = mmap((void *) (16L*1024*1024*1024*1024), size,
                  PROT_READ|PROT_WRITE, GAP_MMAP_FLAGS, -1, 0);
    if (result == MAP_FAILED) {
        result = mmap(NULL, size, PROT_READ|PROT_WRITE,
            GAP_MMAP_FLAGS, -1, 0);
    }
#else
    result = mmap(NULL, size, PROT_READ|PROT_WRITE,
        GAP_MMAP_FLAGS, -1, 0);
#endif
    if (result == MAP_FAILED)
        result = NULL;
    SyMMapStart = result;
    SyMMapEnd = (char *)result + size;
    SyMMapAdvised = (char *)result + size;
    return result;
}

static int SyTryToIncreasePool(void)
/* This tries to increase the pool size by a factor of 3/2, if this
 * worked, then 0 is returned, otherwise -1. */
{
    void *result;
    size_t size;
    size_t newchunk;

    size = (Int) SyMMapEnd - (Int) SyMMapStart;
    newchunk = SyRoundUpToPagesize(size/2);
    result = mmap(SyMMapEnd, newchunk, PROT_READ|PROT_WRITE,
                  GAP_MMAP_FLAGS, -1, 0);
    if (result == MAP_FAILED) return -1;
    if (result != SyMMapEnd) {
        munmap(result,newchunk);
        return -1;
    }
    /* We actually got an extension! */
    SyMMapEnd = (void *)((char *)SyMMapEnd + newchunk);
    SyAllocPool += newchunk;
    return 0;
}

#else

void SyMAdviseFree(void)
{
    /* do nothing */
}

static int SyTryToIncreasePool(void)
{
    return -1;   /* Refuse */
}

#endif // defined(GAP_MEM_CHECK)


static void SyInitialAllocPool(void)
{
#ifdef HAVE_SYSCONF
#ifdef _SC_PAGESIZE
   pagesize = sysconf(_SC_PAGESIZE);
#endif
#endif
   /* Otherwise we take the default of 4k as pagesize. */

   do {
       /* Always round up to pagesize: */
       SyAllocPool = SyRoundUpToPagesize(SyAllocPool);
#ifdef HAVE_MADVISE
       POOL = SyAnonMMap(SyAllocPool+pagesize);   /* For alignment */
#else
       POOL = calloc(SyAllocPool+pagesize,1);   /* For alignment */
#endif
       if (POOL != NULL) {
           /* fprintf(stderr,"Pool size is %lx.\n",SyAllocPool); */
           break;
       }
       SyAllocPool = SyAllocPool / 2;
       if (SyDebugLoading) fputs("gap: halving pool size.\n", stderr);
       if (SyAllocPool < 16*1024*1024) {
           Panic("cannot allocate initial memory");
       }
   } while (1);   /* Is left by break */

   /* ensure alignment of start address */
   syWorkspace = (UInt***)(SyRoundUpToPagesize((UInt) POOL));
   /* Now both syWorkspace and SyAllocPool are aligned to pagesize */
}

#define INVALID_PTR ((UInt***)-1)

static UInt *** SyAllocBagsFromPool(Int size)
{
    GAP_ASSERT(size > 0);

    // get the storage, but only if we stay within the bounds
    while ((syWorksize + size) * 1024 > SyAllocPool) {
        if (SyTryToIncreasePool())
            return INVALID_PTR;
    }
    UInt *** ret = EndOfWorkspace();
    syWorksize += size;
    return ret;
}

static Int SyFreeBagsFromPool(Int size)
{
    GAP_ASSERT(size > 0);

    if (POOL == NULL)
        return 0; // nothing to deallocate -> signal failure

    if (SyStorMin <= syWorksize - size) {
        syWorksize -= size;
        return 1;
    }
    return 0;
}


#if defined(HAVE_SBRK) && !defined(HAVE_VM_ALLOCATE) /* prefer `vm_allocate' over `sbrk' */

static UInt *** SyAllocBagHelper(Int size)
{
    UInt *** ret = (UInt ***)sbrk(size*1024);
    if (ret == INVALID_PTR)
        return INVALID_PTR;
    if (ret != EndOfWorkspace()) {
        sbrk(-size*1024);
        return INVALID_PTR;
    }
    memset(ret, 0, 1024*size);
    return ret;
}

static UInt *** SyAllocBags_(UInt size)
{
    GAP_ASSERT(SyAllocPool == 0);
    UInt *** ret = INVALID_PTR;

    /* force alignment on first call                                       */
    if (syWorkspace == 0) {
        UInt align = (UInt)sbrk(0) % sizeof(UInt);
        if (align != 0)
            syWorkspace = (UInt***)sbrk(sizeof(UInt) - align);
        syWorkspace = (UInt***)sbrk( 0 );
    }

    // get the storage
#ifndef SYS_IS_64_BIT
    UInt adjust = 0;
    // on 32bit systems, call sbrk with at most 1 GB at a time,
    // to avoid integer overflow
    while (size >= 1024*1024) {
        ret = SyAllocBagHelper(1024);
        if (ret == INVALID_PTR)
            break;
        size -= 1024*1024;
        syWorksize += 1024*1024;
        adjust++;
    }
    // try to allocate the rest, if any
    if (size < 1024*1024)
        ret = SyAllocBagHelper(size);
    if (ret != INVALID_PTR) {
        while (adjust--)
            ret = (UInt ***)(((Char *)ret) - 1024 * 1024 * 1024);
    }
#else
    // allocate all at once
    ret = SyAllocBagHelper(size);
#endif

    if (ret != INVALID_PTR) {
        // update the size info
        syWorksize += size;
    }

    return ret;
}

static UInt *** SyFreeBags_(UInt size)
{
    GAP_ASSERT(SyAllocPool == 0);
    UInt *** ret = INVALID_PTR;

    /* force alignment on first call                                       */
    if (syWorkspace == 0) {
        UInt align = (UInt)sbrk(0) % sizeof(UInt);
        if (align != 0)
            syWorkspace = (UInt***)sbrk(sizeof(UInt) - align);
        syWorkspace = (UInt***)sbrk( 0 );
    }

    if (syWorksize >= size && syWorksize - size >= SyStorMin) {
#ifndef SYS_IS_64_BIT
        while (size >= 1024*1024) {
            ret = (UInt ***)sbrk(-1024*1024*1024);
            if (ret == INVALID_PTR)
                break;
            size -= 1024*1024;
            syWorksize -= 1024*1024;
        }
#endif
        ret = (UInt ***)sbrk(-size*1024);
        if (ret != INVALID_PTR) {
            syWorksize -= size;
            if (syWorksize == 0) {
                syWorkspace = (UInt ***)0;
            }
        }
    }

    return ret;
}

#endif


/****************************************************************************
**
*f  SyAllocBags( <size>, <need> )
**
**  Under MACH virtual memory managment functions are used instead of 'sbrk'.
*/
#ifdef HAVE_VM_ALLOCATE

static vm_address_t syBase;

static UInt *** SyAllocBags_(UInt size)
{
    GAP_ASSERT(SyAllocPool == 0);
    UInt *** ret = INVALID_PTR;

    /* check that <size> is divisible by <vm_page_size>                    */
    if ( size*1024 % vm_page_size != 0 ) {
        Panic("memory block size is not a multiple of vm_page_size");
    }

    /* allocate memory anywhere on first call                              */
    else if ( 0 < size && syBase == 0 ) {
        GAP_ASSERT(syWorksize == 0);
        if ( vm_allocate(mach_task_self(),&syBase,size*1024,TRUE) == KERN_SUCCESS ) {
            ret = (UInt***) syBase;
        }
    }

    /* get more memory from system                                         */
    else {
        vm_address_t adr;
        adr = (vm_address_t)( (char*) syBase + syWorksize*1024 );
        if ( vm_allocate(mach_task_self(),&adr,size*1024,FALSE) == KERN_SUCCESS ) {
            ret = (UInt***) ( (char*) syBase + syWorksize*1024 );
        }
    }

    if (ret != INVALID_PTR) {
        // update the size info
        syWorksize += size;
    }

    return ret;
}

static UInt *** SyFreeBags_(UInt size)
{
    GAP_ASSERT(SyAllocPool == 0);
    UInt *** ret = INVALID_PTR;

    /* check that <size> is divisible by <vm_page_size>                    */
    if ( size*1024 % vm_page_size != 0 ) {
        Panic("memory block size is not a multiple of vm_page_size");
    }

    /* check that we don't try to shrink uninitialized memory                */
    else if ( syBase == 0 ) {
        Panic("trying to shrink uninitialized vm memory");
    }

    /* don't shrink memory but mark it as deactivated                      */
    else if (syWorksize >= size && syWorksize - size >= SyStorMin) {
        vm_address_t adr;
        adr = (vm_address_t)( (char*) syBase + (syWorksize-size)*1024 );
        if ( vm_deallocate(mach_task_self(),adr,size*1024) == KERN_SUCCESS ) {
            ret = (UInt***)( (char*) syBase + syWorksize*1024 );

            syWorksize -= size;
            if (syWorksize == 0) {
                syWorkspace = (UInt ***)0;
            }
        }
    }

    return ret;
}

#endif


UInt *** SyAllocBags(Int size, UInt need)
{
    GAP_ASSERT(size > 0);

    UInt *** ret = INVALID_PTR;

    /* first check if we would get above SyStorKill, if yes exit! */
    if (SyStorKill != 0 && SyStorKill < syWorksize + size) {
        if (need) {
            Panic("will not extend workspace above -K limit!");
        }
        return 0;
    }
    else if (SyAllocPool > 0) {
        // initialize allocation pool if necessary; this aborts if it fails
        if (POOL == NULL)
            SyInitialAllocPool();
        ret = SyAllocBagsFromPool(size);
    }
    else {
#if defined(HAVE_SBRK) || defined(HAVE_VM_ALLOCATE)
        ret = SyAllocBags_(size);
#else
        Panic("running without allocation pool not supported on this architecture");
#endif
    }

    // handle allocation failures
    if (ret == INVALID_PTR) {
        if (need) {
            Panic("cannot extend the workspace any more!");
        }
        return (UInt***)0;
    }

    // set the overrun flag if we became larger than SyStorMax
    if (SyStorMax != 0 && syWorksize > SyStorMax) {
        SyStorOverrun = SY_STOR_OVERRUN_TO_REPORT;
        SyStorMax = syWorksize * 2; // new maximum
        InterruptExecStat();        // interrupt at the next possible point
    }

    return ret;
}


Int SyFreeBags(Int size)
{
    GAP_ASSERT(size > 0);

    if (SyAllocPool > 0) {
        return SyFreeBagsFromPool(size);
    }
    else {
#if defined(HAVE_SBRK) || defined(HAVE_VM_ALLOCATE)
        return SyFreeBags_(size) != INVALID_PTR;
#else
        Panic("running without allocation pool not supported on this architecture");
#endif
    }
}


void SyFreeAllBags(void)
{
    // for now, do nothing
}
