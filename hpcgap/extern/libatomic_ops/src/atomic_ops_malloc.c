/*
 * Copyright (c) 2005 Hewlett-Packard Development Company, L.P.
 *
 * This file may be redistributed and/or modified under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 2, or (at your option) any later version.
 *
 * It is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License in the
 * file COPYING for more details.
 */

#if defined(HAVE_CONFIG_H)
# include "config.h"
#endif

#ifdef DONT_USE_MMAP /* for testing */
# undef HAVE_MMAP
#endif

#define AO_REQUIRE_CAS
#include "atomic_ops_malloc.h"

#include <string.h>     /* for ffs, which is assumed reentrant. */
#include <stdlib.h>
#include <assert.h>

#ifdef AO_TRACE_MALLOC
# include <stdio.h>
# include <pthread.h>
#endif

#if defined(AO_ADDRESS_SANITIZER) && !defined(AO_NO_MALLOC_POISON)
  /* #include "sanitizer/asan_interface.h" */
  void __asan_poison_memory_region(void *, size_t);
  void __asan_unpoison_memory_region(void *, size_t);
# define ASAN_POISON_MEMORY_REGION(addr, size) \
                __asan_poison_memory_region(addr, size)
# define ASAN_UNPOISON_MEMORY_REGION(addr, size) \
                __asan_unpoison_memory_region(addr, size)
#else
# define ASAN_POISON_MEMORY_REGION(addr, size) (void)0
# define ASAN_UNPOISON_MEMORY_REGION(addr, size) (void)0
#endif /* !AO_ADDRESS_SANITIZER */

#if (defined(_WIN32_WCE) || defined(__MINGW32CE__)) && !defined(AO_HAVE_abort)
# define abort() _exit(-1) /* there is no abort() in WinCE */
#endif

/*
 * We round up each allocation request to the next power of two
 * minus one word.
 * We keep one stack of free objects for each size.  Each object
 * has an initial word (offset -sizeof(AO_t) from the visible pointer)
 * which contains either
 *      The binary log of the object size in bytes (small objects)
 *      The object size (a multiple of CHUNK_SIZE) for large objects.
 * The second case only arises if mmap-based allocation is supported.
 * We align the user-visible part of each object on a GRANULARITY
 * byte boundary.  That means that the actual (hidden) start of
 * the object starts a word before this boundary.
 */

#ifndef LOG_MAX_SIZE
# define LOG_MAX_SIZE 16
        /* We assume that 2**LOG_MAX_SIZE is a multiple of page size. */
#endif

#ifndef ALIGNMENT
# define ALIGNMENT 16
        /* Assumed to be at least sizeof(AO_t).         */
#endif

#define CHUNK_SIZE (1 << LOG_MAX_SIZE)

#ifndef AO_INITIAL_HEAP_SIZE
#  define AO_INITIAL_HEAP_SIZE (2*(LOG_MAX_SIZE+1)*CHUNK_SIZE)
#endif

char AO_initial_heap[AO_INITIAL_HEAP_SIZE];

static volatile AO_t initial_heap_ptr = (AO_t)AO_initial_heap;

#if defined(HAVE_MMAP)

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>

#if defined(MAP_ANONYMOUS) || defined(MAP_ANON)
# define USE_MMAP_ANON
#endif

#ifdef USE_MMAP_FIXED
# define GC_MMAP_FLAGS (MAP_FIXED | MAP_PRIVATE)
        /* Seems to yield better performance on Solaris 2, but can      */
        /* be unreliable if something is already mapped at the address. */
#else
# define GC_MMAP_FLAGS MAP_PRIVATE
#endif

#ifdef USE_MMAP_ANON
# if defined(CPPCHECK)
#   define OPT_MAP_ANON 0x20 /* taken from linux */
# elif defined(MAP_ANONYMOUS)
#   define OPT_MAP_ANON MAP_ANONYMOUS
# else
#   define OPT_MAP_ANON MAP_ANON
# endif
#else
# include <unistd.h> /* for close() */
# define OPT_MAP_ANON 0
#endif

static volatile AO_t mmap_enabled = 0;

void
AO_malloc_enable_mmap(void)
{
# if defined(__sun)
    AO_store_release(&mmap_enabled, 1);
            /* Workaround for Sun CC */
# else
    AO_store(&mmap_enabled, 1);
# endif
}

static char *get_mmaped(size_t sz)
{
  char * result;
# ifdef USE_MMAP_ANON
#   define zero_fd -1
# else
    int zero_fd;
# endif

  assert(!(sz & (CHUNK_SIZE - 1)));
  if (!mmap_enabled)
    return 0;

# ifndef USE_MMAP_ANON
    zero_fd = open("/dev/zero", O_RDONLY);
    if (zero_fd == -1)
      return 0;
# endif
  result = (char *)mmap(0, sz, PROT_READ | PROT_WRITE,
                        GC_MMAP_FLAGS | OPT_MAP_ANON,
                        zero_fd, 0 /* offset */);
# ifndef USE_MMAP_ANON
    close(zero_fd);
# endif
  if (AO_EXPECT_FALSE(result == MAP_FAILED))
    result = NULL;
  return result;
}

#ifndef SIZE_MAX
# include <limits.h>
#endif
#if defined(SIZE_MAX) && !defined(CPPCHECK)
# define AO_SIZE_MAX ((size_t)SIZE_MAX)
            /* Extra cast to workaround some buggy SIZE_MAX definitions. */
#else
# define AO_SIZE_MAX (~(size_t)0)
#endif

/* Saturated addition of size_t values.  Used to avoid value wrap       */
/* around on overflow.  The arguments should have no side effects.      */
#define SIZET_SAT_ADD(a, b) \
    (AO_EXPECT_FALSE((a) >= AO_SIZE_MAX - (b)) ? AO_SIZE_MAX : (a) + (b))

/* Allocate an object of size (incl. header) of size > CHUNK_SIZE.      */
/* sz includes space for an AO_t-sized header.                          */
static char *
AO_malloc_large(size_t sz)
{
  char *result;
  /* The header will force us to waste ALIGNMENT bytes, incl. header.   */
  /* Round to multiple of CHUNK_SIZE.                                   */
  sz = SIZET_SAT_ADD(sz, ALIGNMENT + CHUNK_SIZE - 1) & ~(CHUNK_SIZE - 1);
  assert(sz > LOG_MAX_SIZE);
  result = get_mmaped(sz);
  if (AO_EXPECT_FALSE(NULL == result))
    return NULL;
  result += ALIGNMENT;
  ((AO_t *)result)[-1] = (AO_t)sz;
  return result;
}

static void
AO_free_large(char * p)
{
  AO_t sz = ((AO_t *)p)[-1];
  if (munmap(p - ALIGNMENT, (size_t)sz) != 0)
    abort();  /* Programmer error.  Not really async-signal-safe, but ... */
}


#else /*  No MMAP */

void
AO_malloc_enable_mmap(void)
{
}

#define get_mmaped(sz) ((char*)0)
#define AO_malloc_large(sz) ((char*)0)
#define AO_free_large(p) abort()
                /* Programmer error.  Not really async-signal-safe, but ... */

#endif /* No MMAP */

static char *
get_chunk(void)
{
  char *my_chunk_ptr;

  for (;;) {
    char *initial_ptr = (char *)AO_load(&initial_heap_ptr);

    my_chunk_ptr = (char *)(((AO_t)initial_ptr + (ALIGNMENT - 1))
                            & ~(ALIGNMENT - 1));
    if (initial_ptr != my_chunk_ptr)
      {
        /* Align correctly.  If this fails, someone else did it for us. */
        (void)AO_compare_and_swap_acquire(&initial_heap_ptr,
                                    (AO_t)initial_ptr, (AO_t)my_chunk_ptr);
      }

    if (AO_EXPECT_FALSE((AO_t)my_chunk_ptr
            > (AO_t)(AO_initial_heap + AO_INITIAL_HEAP_SIZE - CHUNK_SIZE))) {
      /* We failed.  The initial heap is used up.       */
      my_chunk_ptr = get_mmaped(CHUNK_SIZE);
#     if !defined(CPPCHECK)
        assert(((AO_t)my_chunk_ptr & (ALIGNMENT-1)) == 0);
#     endif
      break;
    }
    if (AO_compare_and_swap(&initial_heap_ptr, (AO_t)my_chunk_ptr,
                            (AO_t)(my_chunk_ptr + CHUNK_SIZE))) {
      break;
    }
  }
  return my_chunk_ptr;
}

/* Object free lists.  Ith entry corresponds to objects         */
/* of total size 2**i bytes.                                    */
AO_stack_t AO_free_list[LOG_MAX_SIZE+1];

/* Break up the chunk, and add it to the object free list for   */
/* the given size.  We have exclusive access to chunk.          */
static void add_chunk_as(void * chunk, unsigned log_sz)
{
  size_t ofs, limit;
  size_t sz = (size_t)1 << log_sz;

  assert (CHUNK_SIZE >= sz);
  limit = (size_t)CHUNK_SIZE - sz;
  for (ofs = ALIGNMENT - sizeof(AO_t); ofs <= limit; ofs += sz) {
    ASAN_POISON_MEMORY_REGION((char *)chunk + ofs + sizeof(AO_t),
                              sz - sizeof(AO_t));
    AO_stack_push(&AO_free_list[log_sz], (AO_t *)((char *)chunk + ofs));
  }
}

static const unsigned char msbs[16] = {
  0, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4
};

/* Return the position of the most significant set bit in the   */
/* argument.                                                    */
/* We follow the conventions of ffs(), i.e. the least           */
/* significant bit is number one.                               */
static unsigned msb(size_t s)
{
  unsigned result = 0;
  if ((s & 0xff) != s) {
#   if (__SIZEOF_SIZE_T__ == 8) && !defined(CPPCHECK)
      unsigned v = (unsigned)(s >> 32);
      if (AO_EXPECT_FALSE(v != 0))
        {
          s = v;
          result += 32;
        }
#   elif __SIZEOF_SIZE_T__ == 4
      /* No op. */
#   else
      unsigned v;
      /* The following is a tricky code ought to be equivalent to       */
      /* "(v = s >> 32) != 0" but suppresses warnings on 32-bit arch's. */
#     define SIZEOF_SIZE_T_GT_4 (sizeof(size_t) > 4)
      if (SIZEOF_SIZE_T_GT_4
          && (v = (unsigned)(s >> (SIZEOF_SIZE_T_GT_4 ? 32 : 0))) != 0)
        {
          s = v;
          result += 32;
        }
#   endif /* !defined(__SIZEOF_SIZE_T__) */
    if (AO_EXPECT_FALSE((s >> 16) != 0))
      {
        s >>= 16;
        result += 16;
      }
    if ((s >> 8) != 0)
      {
        s >>= 8;
        result += 8;
      }
  }
  if (s > 15)
    {
      s >>= 4;
      result += 4;
    }
  result += msbs[s];
  return result;
}

void *
AO_malloc(size_t sz)
{
  AO_t *result;
  unsigned log_sz;

  if (AO_EXPECT_FALSE(sz > CHUNK_SIZE - sizeof(AO_t)))
    return AO_malloc_large(sz);
  log_sz = msb(sz + (sizeof(AO_t) - 1));
  assert(log_sz <= LOG_MAX_SIZE);
  assert(((size_t)1 << log_sz) >= sz + sizeof(AO_t));
  result = AO_stack_pop(AO_free_list+log_sz);
  while (AO_EXPECT_FALSE(NULL == result)) {
    void * chunk = get_chunk();

    if (AO_EXPECT_FALSE(NULL == chunk))
      return NULL;
    add_chunk_as(chunk, log_sz);
    result = AO_stack_pop(AO_free_list+log_sz);
  }
  *result = log_sz;
# ifdef AO_TRACE_MALLOC
    fprintf(stderr, "%p: AO_malloc(%lu) = %p\n",
            (void *)pthread_self(), (unsigned long)sz, (void *)(result + 1));
# endif
  ASAN_UNPOISON_MEMORY_REGION(result + 1, sz);
  return result + 1;
}

void
AO_free(void *p)
{
  AO_t *base;
  int log_sz;

  if (AO_EXPECT_FALSE(NULL == p))
    return;

  base = (AO_t *)p - 1;
  log_sz = (int)(*base);
# ifdef AO_TRACE_MALLOC
    fprintf(stderr, "%p: AO_free(%p sz:%lu)\n", (void *)pthread_self(), p,
            log_sz > LOG_MAX_SIZE ? (unsigned)log_sz : 1UL << log_sz);
# endif
  if (AO_EXPECT_FALSE(log_sz > LOG_MAX_SIZE)) {
    AO_free_large((char *)p);
  } else {
    ASAN_POISON_MEMORY_REGION(base + 1, ((size_t)1 << log_sz) - sizeof(AO_t));
    AO_stack_push(AO_free_list + log_sz, base);
  }
}
