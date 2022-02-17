/*
 * Copyright (c) 2003-2005 Hewlett-Packard Development Company, L.P.
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

#if (defined(AO_NO_PTHREADS) || defined(__MINGW32__)) \
    && defined(AO_USE_PTHREAD_DEFS)
# include <stdio.h>

  int main(void)
  {
    printf("test skipped\n");
    return 0;
  }

#else

#include "run_parallel.h"

#include "test_atomic_include.h"

#if defined(AO_USE_PTHREAD_DEFS) || defined(AO_PREFER_GENERALIZED)
# define NITERS 100000
#else
# define NITERS 10000000
#endif

void * add1sub1_thr(void * id);
int add1sub1_test(void);
void * acqrel_thr(void *id);
int acqrel_test(void);
void * test_and_set_thr(void * id);
int test_and_set_test(void);

#if defined(AO_HAVE_fetch_and_add1) && defined(AO_HAVE_fetch_and_sub1)

AO_t counter = 0;

void * add1sub1_thr(void * id)
{
  int me = (int)(AO_PTRDIFF_T)id;

  int i;

  for (i = 0; i < NITERS; ++i)
    if ((me & 1) != 0) {
      (void)AO_fetch_and_sub1(&counter);
    } else {
      (void)AO_fetch_and_add1(&counter);
    }
  return 0;
}

int add1sub1_test(void)
{
  return counter == 0;
}

#endif /* defined(AO_HAVE_fetch_and_add1) && defined(AO_HAVE_fetch_and_sub1) */

#if defined(AO_HAVE_store_release_write) && defined(AO_HAVE_load_acquire_read)

/* Invariant: counter1 >= counter2 */
AO_t counter1 = 0;
AO_t counter2 = 0;

void * acqrel_thr(void *id)
{
  int me = (int)(AO_PTRDIFF_T)id;

  int i;

  for (i = 0; i < NITERS; ++i)
    if (me & 1)
      {
        AO_t my_counter1;
        if (me != 1)
          {
            fprintf(stderr, "acqrel test: too many threads\n");
            abort();
          }
        my_counter1 = AO_load(&counter1);
        AO_store(&counter1, my_counter1 + 1);
        AO_store_release_write(&counter2, my_counter1 + 1);
      }
    else
      {
        AO_t my_counter1a, my_counter2a;
        AO_t my_counter1b, my_counter2b;

        my_counter2a = AO_load_acquire_read(&counter2);
        my_counter1a = AO_load(&counter1);
        /* Redo this, to make sure that the second load of counter1 */
        /* is not viewed as a common subexpression.         */
        my_counter2b = AO_load_acquire_read(&counter2);
        my_counter1b = AO_load(&counter1);
        if (my_counter1a < my_counter2a)
          {
            fprintf(stderr, "Saw release store out of order: %lu < %lu\n",
                (unsigned long)my_counter1a, (unsigned long)my_counter2a);
            abort();
          }
        if (my_counter1b < my_counter2b)
          {
            fprintf(stderr,
                "Saw release store out of order (bad CSE?): %lu < %lu\n",
                (unsigned long)my_counter1b, (unsigned long)my_counter2b);
            abort();
          }
      }

  return 0;
}

int acqrel_test(void)
{
  return counter1 == NITERS && counter2 == NITERS;
}

#endif /* AO_HAVE_store_release_write && AO_HAVE_load_acquire_read */

#if defined(AO_HAVE_test_and_set_acquire)

AO_TS_t lock = AO_TS_INITIALIZER;

unsigned long locked_counter;
volatile unsigned long junk = 13;

AO_ATTR_NO_SANITIZE_THREAD
void do_junk(void)
{
  junk *= 17;
  junk *= 19;
}

void * test_and_set_thr(void * id)
{
  unsigned long i;

  for (i = 0; i < NITERS/10; ++i)
    {
      while (AO_test_and_set_acquire(&lock) != AO_TS_CLEAR);
      ++locked_counter;
      if (locked_counter != 1)
        {
          fprintf(stderr, "Test and set failure 1, counter = %ld, id = %d\n",
                  (long)locked_counter, (int)(AO_PTRDIFF_T)id);
          abort();
        }
      locked_counter *= 2;
      locked_counter -= 1;
      locked_counter *= 5;
      locked_counter -= 4;
      if (locked_counter != 1)
        {
          fprintf(stderr, "Test and set failure 2, counter = %ld, id = %d\n",
                  (long)locked_counter, (int)(AO_PTRDIFF_T)id);
          abort();
        }
      --locked_counter;
      AO_CLEAR(&lock);
      /* Spend a bit of time outside the lock. */
      do_junk();
    }
  return 0;
}

int test_and_set_test(void)
{
  return locked_counter == 0;
}

#endif /* defined(AO_HAVE_test_and_set_acquire) */

#if (!defined(_MSC_VER) && !defined(__MINGW32__) && !defined(__BORLANDC__) \
     || defined(AO_USE_NO_SIGNALS) || defined(AO_USE_WIN32_PTHREADS)) \
    && defined(AO_TEST_EMULATION)

# ifdef __cplusplus
    extern "C" {
# endif

  void AO_store_full_emulation(volatile AO_t *addr, AO_t val);
  AO_t AO_fetch_compare_and_swap_emulation(volatile AO_t *addr, AO_t old_val,
                                           AO_t new_val);
# ifdef AO_HAVE_double_t
    int AO_compare_double_and_swap_double_emulation(volatile AO_double_t *,
                                                AO_t old_val1, AO_t old_val2,
                                                AO_t new_val1, AO_t new_val2);
# endif

# ifdef __cplusplus
    } /* extern "C" */
# endif

  void test_atomic_emulation(void)
  {
    AO_t x;
#   ifdef AO_HAVE_double_t
      AO_double_t w; /* double-word alignment not needed */

      w.AO_val1 = 0;
      w.AO_val2 = 0;
      TA_assert(!AO_compare_double_and_swap_double_emulation(&w, 4116, 2121,
                                                             8537, 6410));
      TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
      TA_assert(AO_compare_double_and_swap_double_emulation(&w, 0, 0,
                                                            8537, 6410));
      TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
#   endif
    AO_store_full_emulation(&x, 1314);
    TA_assert(x == 1314);
    TA_assert(AO_fetch_compare_and_swap_emulation(&x, 14, 13117) == 1314);
    TA_assert(x == 1314);
    TA_assert(AO_fetch_compare_and_swap_emulation(&x, 1314, 14117) == 1314);
    TA_assert(x == 14117);
  }

#else
# define test_atomic_emulation() (void)0
#endif /* _MSC_VER && !AO_USE_NO_SIGNALS || !AO_TEST_EMULATION */

int main(void)
{
  test_atomic();
  test_atomic_acquire();
  test_atomic_release();
  test_atomic_read();
  test_atomic_write();
  test_atomic_full();
  test_atomic_release_write();
  test_atomic_acquire_read();
  test_atomic_dd_acquire_read();
# if defined(AO_HAVE_fetch_and_add1) && defined(AO_HAVE_fetch_and_sub1)
    run_parallel(4, add1sub1_thr, add1sub1_test, "add1/sub1");
# endif
# if defined(AO_HAVE_store_release_write) && defined(AO_HAVE_load_acquire_read)
    run_parallel(3, acqrel_thr, acqrel_test,
         "store_release_write/load_acquire_read");
# endif
# if defined(AO_HAVE_test_and_set_acquire)
    run_parallel(5, test_and_set_thr, test_and_set_test,
         "test_and_set");
# endif
  test_atomic_emulation();
  return 0;
}

#endif /* !AO_NO_PTHREADS || !AO_USE_PTHREAD_DEFS */
