/*
 * Copyright (c) 2003 by Hewlett-Packard Company.  All rights reserved.
 *
 * This file is covered by the GNU general public license, version 2.
 * see COPYING for details.
 */

/* Some basic sanity tests.  These do not test the barrier semantics. */

#undef TA_assert
#define TA_assert(e) \
  if (!(e)) { fprintf(stderr, "Assertion failed %s:%d (barrier: )\n", \
                    __FILE__, __LINE__), exit(1); }

#undef MISSING
#define MISSING(name) \
  printf("Missing: %s\n", #name "")

#if defined(CPPCHECK)
  void list_atomic(void);
  void char_list_atomic(void);
  void short_list_atomic(void);
  void int_list_atomic(void);
  void double_list_atomic(void);
#endif

void test_atomic(void)
{
  AO_t x;
  unsigned char b;
  unsigned short s;
  unsigned int zz;
# if defined(AO_HAVE_test_and_set)
    AO_TS_t z = AO_TS_INITIALIZER;
# endif
# if defined(AO_HAVE_double_compare_and_swap) \
     || defined(AO_HAVE_double_load) \
     || defined(AO_HAVE_double_store)
    static AO_double_t old_w; /* static to avoid misalignment */
    AO_double_t new_w;
# endif
# if defined(AO_HAVE_compare_and_swap_double) \
     || defined(AO_HAVE_compare_double_and_swap_double) \
     || defined(AO_HAVE_double_compare_and_swap)
    static AO_double_t w; /* static to avoid misalignment */
    w.AO_val1 = 0;
    w.AO_val2 = 0;
# endif

# if defined(CPPCHECK)
    list_atomic();
    char_list_atomic();
    short_list_atomic();
    int_list_atomic();
    double_list_atomic();
# endif
# if defined(AO_HAVE_nop)
    AO_nop();
# elif !defined(AO_HAVE_nop) || !defined(AO_HAVE_nop_full) \
       || !defined(AO_HAVE_nop_read) || !defined(AO_HAVE_nop_write)
    MISSING(AO_nop);
# endif
# if defined(AO_HAVE_store)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile AO_t *)&x = 0; /* initialize to avoid false warning */
#   endif
    AO_store(&x, 13);
    TA_assert(x == 13);
# else
#   if !defined(AO_HAVE_store) || !defined(AO_HAVE_store_full) \
       || !defined(AO_HAVE_store_release) \
       || !defined(AO_HAVE_store_release_write) \
       || !defined(AO_HAVE_store_write)
      MISSING(AO_store);
#   endif
    x = 13;
# endif
# if defined(AO_HAVE_load)
    TA_assert(AO_load(&x) == 13);
# elif !defined(AO_HAVE_load) || !defined(AO_HAVE_load_acquire) \
       || !defined(AO_HAVE_load_acquire_read) \
       || !defined(AO_HAVE_load_dd_acquire_read) \
       || !defined(AO_HAVE_load_full) || !defined(AO_HAVE_load_read)
    MISSING(AO_load);
# endif
# if defined(AO_HAVE_test_and_set)
    TA_assert(AO_test_and_set(&z) == AO_TS_CLEAR);
    TA_assert(AO_test_and_set(&z) == AO_TS_SET);
    TA_assert(AO_test_and_set(&z) == AO_TS_SET);
    AO_CLEAR(&z);
# else
    MISSING(AO_test_and_set);
# endif
# if defined(AO_HAVE_fetch_and_add)
    TA_assert(AO_fetch_and_add(&x, 42) == 13);
    TA_assert(AO_fetch_and_add(&x, (AO_t)(-42)) == 55);
# else
    MISSING(AO_fetch_and_add);
# endif
# if defined(AO_HAVE_fetch_and_add1)
    TA_assert(AO_fetch_and_add1(&x) == 13);
# else
    MISSING(AO_fetch_and_add1);
    ++x;
# endif
# if defined(AO_HAVE_fetch_and_sub1)
    TA_assert(AO_fetch_and_sub1(&x) == 14);
# else
    MISSING(AO_fetch_and_sub1);
    --x;
# endif
# if defined(AO_HAVE_short_store)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile short *)&s = 0;
#   endif
    AO_short_store(&s, 13);
# else
#   if !defined(AO_HAVE_short_store) || !defined(AO_HAVE_short_store_full) \
       || !defined(AO_HAVE_short_store_release) \
       || !defined(AO_HAVE_short_store_release_write) \
       || !defined(AO_HAVE_short_store_write)
      MISSING(AO_short_store);
#   endif
    s = 13;
# endif
# if defined(AO_HAVE_short_load)
    TA_assert(AO_short_load(&s) == 13);
# elif !defined(AO_HAVE_short_load) || !defined(AO_HAVE_short_load_acquire) \
       || !defined(AO_HAVE_short_load_acquire_read) \
       || !defined(AO_HAVE_short_load_dd_acquire_read) \
       || !defined(AO_HAVE_short_load_full) \
       || !defined(AO_HAVE_short_load_read)
    MISSING(AO_short_load);
# endif
# if defined(AO_HAVE_short_fetch_and_add)
    TA_assert(AO_short_fetch_and_add(&s, 42) == 13);
    TA_assert(AO_short_fetch_and_add(&s, (unsigned short)-42) == 55);
# else
    MISSING(AO_short_fetch_and_add);
# endif
# if defined(AO_HAVE_short_fetch_and_add1)
    TA_assert(AO_short_fetch_and_add1(&s) == 13);
# else
    MISSING(AO_short_fetch_and_add1);
    ++s;
# endif
# if defined(AO_HAVE_short_fetch_and_sub1)
    TA_assert(AO_short_fetch_and_sub1(&s) == 14);
# else
    MISSING(AO_short_fetch_and_sub1);
    --s;
# endif
  TA_assert(*(volatile short *)&s == 13);
# if defined(AO_HAVE_char_store)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile char *)&b = 0;
#   endif
    AO_char_store(&b, 13);
# else
#   if !defined(AO_HAVE_char_store) || !defined(AO_HAVE_char_store_full) \
       || !defined(AO_HAVE_char_store_release) \
       || !defined(AO_HAVE_char_store_release_write) \
       || !defined(AO_HAVE_char_store_write)
      MISSING(AO_char_store);
#   endif
    b = 13;
# endif
# if defined(AO_HAVE_char_load)
    TA_assert(AO_char_load(&b) == 13);
# elif !defined(AO_HAVE_char_load) || !defined(AO_HAVE_char_load_acquire) \
       || !defined(AO_HAVE_char_load_acquire_read) \
       || !defined(AO_HAVE_char_load_dd_acquire_read) \
       || !defined(AO_HAVE_char_load_full) || !defined(AO_HAVE_char_load_read)
    MISSING(AO_char_load);
# endif
# if defined(AO_HAVE_char_fetch_and_add)
    TA_assert(AO_char_fetch_and_add(&b, 42) == 13);
    TA_assert(AO_char_fetch_and_add(&b, (unsigned char)-42) == 55);
# else
    MISSING(AO_char_fetch_and_add);
# endif
# if defined(AO_HAVE_char_fetch_and_add1)
    TA_assert(AO_char_fetch_and_add1(&b) == 13);
# else
    MISSING(AO_char_fetch_and_add1);
    ++b;
# endif
# if defined(AO_HAVE_char_fetch_and_sub1)
    TA_assert(AO_char_fetch_and_sub1(&b) == 14);
# else
    MISSING(AO_char_fetch_and_sub1);
    --b;
# endif
  TA_assert(*(volatile char *)&b == 13);
# if defined(AO_HAVE_int_store)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile int *)&zz = 0;
#   endif
    AO_int_store(&zz, 13);
# else
#   if !defined(AO_HAVE_int_store) || !defined(AO_HAVE_int_store_full) \
       || !defined(AO_HAVE_int_store_release) \
       || !defined(AO_HAVE_int_store_release_write) \
       || !defined(AO_HAVE_int_store_write)
      MISSING(AO_int_store);
#   endif
    zz = 13;
# endif
# if defined(AO_HAVE_int_load)
    TA_assert(AO_int_load(&zz) == 13);
# elif !defined(AO_HAVE_int_load) || !defined(AO_HAVE_int_load_acquire) \
       || !defined(AO_HAVE_int_load_acquire_read) \
       || !defined(AO_HAVE_int_load_dd_acquire_read) \
       || !defined(AO_HAVE_int_load_full) || !defined(AO_HAVE_int_load_read)
    MISSING(AO_int_load);
# endif
# if defined(AO_HAVE_int_fetch_and_add)
    TA_assert(AO_int_fetch_and_add(&zz, 42) == 13);
    TA_assert(AO_int_fetch_and_add(&zz, (unsigned int)-42) == 55);
# else
    MISSING(AO_int_fetch_and_add);
# endif
# if defined(AO_HAVE_int_fetch_and_add1)
    TA_assert(AO_int_fetch_and_add1(&zz) == 13);
# else
    MISSING(AO_int_fetch_and_add1);
    ++zz;
# endif
# if defined(AO_HAVE_int_fetch_and_sub1)
    TA_assert(AO_int_fetch_and_sub1(&zz) == 14);
# else
    MISSING(AO_int_fetch_and_sub1);
    --zz;
# endif
  TA_assert(*(volatile int *)&zz == 13);
# if defined(AO_HAVE_compare_and_swap)
    TA_assert(!AO_compare_and_swap(&x, 14, 42));
    TA_assert(x == 13);
    TA_assert(AO_compare_and_swap(&x, 13, 42));
    TA_assert(x == 42);
# else
    MISSING(AO_compare_and_swap);
    if (*(volatile AO_t *)&x == 13) x = 42;
# endif
# if defined(AO_HAVE_or)
    AO_or(&x, 66);
    TA_assert(x == 106);
# else
#   if !defined(AO_HAVE_or) || !defined(AO_HAVE_or_acquire) \
       || !defined(AO_HAVE_or_acquire_read) || !defined(AO_HAVE_or_full) \
       || !defined(AO_HAVE_or_read) || !defined(AO_HAVE_or_release) \
       || !defined(AO_HAVE_or_release_write) || !defined(AO_HAVE_or_write)
      MISSING(AO_or);
#   endif
    x |= 66;
# endif
# if defined(AO_HAVE_xor)
    AO_xor(&x, 181);
    TA_assert(x == 223);
# else
#   if !defined(AO_HAVE_xor) || !defined(AO_HAVE_xor_acquire) \
       || !defined(AO_HAVE_xor_acquire_read) || !defined(AO_HAVE_xor_full) \
       || !defined(AO_HAVE_xor_read) || !defined(AO_HAVE_xor_release) \
       || !defined(AO_HAVE_xor_release_write) || !defined(AO_HAVE_xor_write)
      MISSING(AO_xor);
#   endif
    x ^= 181;
# endif
# if defined(AO_HAVE_and)
    AO_and(&x, 57);
    TA_assert(x == 25);
# else
#   if !defined(AO_HAVE_and) || !defined(AO_HAVE_and_acquire) \
       || !defined(AO_HAVE_and_acquire_read) || !defined(AO_HAVE_and_full) \
       || !defined(AO_HAVE_and_read) || !defined(AO_HAVE_and_release) \
       || !defined(AO_HAVE_and_release_write) || !defined(AO_HAVE_and_write)
      MISSING(AO_and);
#   endif
    x &= 57;
# endif
# if defined(AO_HAVE_fetch_compare_and_swap)
    TA_assert(AO_fetch_compare_and_swap(&x, 14, 117) == 25);
    TA_assert(x == 25);
    TA_assert(AO_fetch_compare_and_swap(&x, 25, 117) == 25);
# else
    MISSING(AO_fetch_compare_and_swap);
    if (x == 25) x = 117;
# endif
  TA_assert(x == 117);
# if defined(AO_HAVE_short_compare_and_swap)
    TA_assert(!AO_short_compare_and_swap(&s, 14, 42));
    TA_assert(s == 13);
    TA_assert(AO_short_compare_and_swap(&s, 13, 42));
    TA_assert(s == 42);
# else
    MISSING(AO_short_compare_and_swap);
    if (*(volatile short *)&s == 13) s = 42;
# endif
# if defined(AO_HAVE_short_or)
    AO_short_or(&s, 66);
    TA_assert(s == 106);
# else
#   if !defined(AO_HAVE_short_or) || !defined(AO_HAVE_short_or_acquire) \
       || !defined(AO_HAVE_short_or_acquire_read) \
       || !defined(AO_HAVE_short_or_full) || !defined(AO_HAVE_short_or_read) \
       || !defined(AO_HAVE_short_or_release) \
       || !defined(AO_HAVE_short_or_release_write) \
       || !defined(AO_HAVE_short_or_write)
      MISSING(AO_short_or);
#   endif
    s |= 66;
# endif
# if defined(AO_HAVE_short_xor)
    AO_short_xor(&s, 181);
    TA_assert(s == 223);
# else
#   if !defined(AO_HAVE_short_xor) || !defined(AO_HAVE_short_xor_acquire) \
       || !defined(AO_HAVE_short_xor_acquire_read) \
       || !defined(AO_HAVE_short_xor_full) \
       || !defined(AO_HAVE_short_xor_read) \
       || !defined(AO_HAVE_short_xor_release) \
       || !defined(AO_HAVE_short_xor_release_write) \
       || !defined(AO_HAVE_short_xor_write)
      MISSING(AO_short_xor);
#   endif
    s ^= 181;
# endif
# if defined(AO_HAVE_short_and)
    AO_short_and(&s, 57);
    TA_assert(s == 25);
# else
#   if !defined(AO_HAVE_short_and) || !defined(AO_HAVE_short_and_acquire) \
       || !defined(AO_HAVE_short_and_acquire_read) \
       || !defined(AO_HAVE_short_and_full) \
       || !defined(AO_HAVE_short_and_read) \
       || !defined(AO_HAVE_short_and_release) \
       || !defined(AO_HAVE_short_and_release_write) \
       || !defined(AO_HAVE_short_and_write)
      MISSING(AO_short_and);
#   endif
    s &= 57;
# endif
# if defined(AO_HAVE_short_fetch_compare_and_swap)
    TA_assert(AO_short_fetch_compare_and_swap(&s, 14, 117) == 25);
    TA_assert(s == 25);
    TA_assert(AO_short_fetch_compare_and_swap(&s, 25, 117) == 25);
# else
    MISSING(AO_short_fetch_compare_and_swap);
    if (s == 25) s = 117;
# endif
  TA_assert(s == 117);
# if defined(AO_HAVE_char_compare_and_swap)
    TA_assert(!AO_char_compare_and_swap(&b, 14, 42));
    TA_assert(b == 13);
    TA_assert(AO_char_compare_and_swap(&b, 13, 42));
    TA_assert(b == 42);
# else
    MISSING(AO_char_compare_and_swap);
    if (*(volatile char *)&b == 13) b = 42;
# endif
# if defined(AO_HAVE_char_or)
    AO_char_or(&b, 66);
    TA_assert(b == 106);
# else
#   if !defined(AO_HAVE_char_or) || !defined(AO_HAVE_char_or_acquire) \
       || !defined(AO_HAVE_char_or_acquire_read) \
       || !defined(AO_HAVE_char_or_full) || !defined(AO_HAVE_char_or_read) \
       || !defined(AO_HAVE_char_or_release) \
       || !defined(AO_HAVE_char_or_release_write) \
       || !defined(AO_HAVE_char_or_write)
      MISSING(AO_char_or);
#   endif
    b |= 66;
# endif
# if defined(AO_HAVE_char_xor)
    AO_char_xor(&b, 181);
    TA_assert(b == 223);
# else
#   if !defined(AO_HAVE_char_xor) || !defined(AO_HAVE_char_xor_acquire) \
       || !defined(AO_HAVE_char_xor_acquire_read) \
       || !defined(AO_HAVE_char_xor_full) || !defined(AO_HAVE_char_xor_read) \
       || !defined(AO_HAVE_char_xor_release) \
       || !defined(AO_HAVE_char_xor_release_write) \
       || !defined(AO_HAVE_char_xor_write)
      MISSING(AO_char_xor);
#   endif
    b ^= 181;
# endif
# if defined(AO_HAVE_char_and)
    AO_char_and(&b, 57);
    TA_assert(b == 25);
# else
#   if !defined(AO_HAVE_char_and) || !defined(AO_HAVE_char_and_acquire) \
       || !defined(AO_HAVE_char_and_acquire_read) \
       || !defined(AO_HAVE_char_and_full) || !defined(AO_HAVE_char_and_read) \
       || !defined(AO_HAVE_char_and_release) \
       || !defined(AO_HAVE_char_and_release_write) \
       || !defined(AO_HAVE_char_and_write)
      MISSING(AO_char_and);
#   endif
    b &= 57;
# endif
# if defined(AO_HAVE_char_fetch_compare_and_swap)
    TA_assert(AO_char_fetch_compare_and_swap(&b, 14, 117) == 25);
    TA_assert(b == 25);
    TA_assert(AO_char_fetch_compare_and_swap(&b, 25, 117) == 25);
# else
    MISSING(AO_char_fetch_compare_and_swap);
    if (b == 25) b = 117;
# endif
  TA_assert(b == 117);
# if defined(AO_HAVE_int_compare_and_swap)
    TA_assert(!AO_int_compare_and_swap(&zz, 14, 42));
    TA_assert(zz == 13);
    TA_assert(AO_int_compare_and_swap(&zz, 13, 42));
    TA_assert(zz == 42);
# else
    MISSING(AO_int_compare_and_swap);
    if (*(volatile int *)&zz == 13) zz = 42;
# endif
# if defined(AO_HAVE_int_or)
    AO_int_or(&zz, 66);
    TA_assert(zz == 106);
# else
#   if !defined(AO_HAVE_int_or) || !defined(AO_HAVE_int_or_acquire) \
       || !defined(AO_HAVE_int_or_acquire_read) \
       || !defined(AO_HAVE_int_or_full) || !defined(AO_HAVE_int_or_read) \
       || !defined(AO_HAVE_int_or_release) \
       || !defined(AO_HAVE_int_or_release_write) \
       || !defined(AO_HAVE_int_or_write)
      MISSING(AO_int_or);
#   endif
    zz |= 66;
# endif
# if defined(AO_HAVE_int_xor)
    AO_int_xor(&zz, 181);
    TA_assert(zz == 223);
# else
#   if !defined(AO_HAVE_int_xor) || !defined(AO_HAVE_int_xor_acquire) \
       || !defined(AO_HAVE_int_xor_acquire_read) \
       || !defined(AO_HAVE_int_xor_full) || !defined(AO_HAVE_int_xor_read) \
       || !defined(AO_HAVE_int_xor_release) \
       || !defined(AO_HAVE_int_xor_release_write) \
       || !defined(AO_HAVE_int_xor_write)
      MISSING(AO_int_xor);
#   endif
    zz ^= 181;
# endif
# if defined(AO_HAVE_int_and)
    AO_int_and(&zz, 57);
    TA_assert(zz == 25);
# else
#   if !defined(AO_HAVE_int_and) || !defined(AO_HAVE_int_and_acquire) \
       || !defined(AO_HAVE_int_and_acquire_read) \
       || !defined(AO_HAVE_int_and_full) || !defined(AO_HAVE_int_and_read) \
       || !defined(AO_HAVE_int_and_release) \
       || !defined(AO_HAVE_int_and_release_write) \
       || !defined(AO_HAVE_int_and_write)
      MISSING(AO_int_and);
#   endif
    zz &= 57;
# endif
# if defined(AO_HAVE_int_fetch_compare_and_swap)
    TA_assert(AO_int_fetch_compare_and_swap(&zz, 14, 117) == 25);
    TA_assert(zz == 25);
    TA_assert(AO_int_fetch_compare_and_swap(&zz, 25, 117) == 25);
# else
    MISSING(AO_int_fetch_compare_and_swap);
    if (zz == 25) zz = 117;
# endif
  TA_assert(zz == 117);
# if defined(AO_HAVE_double_load) || defined(AO_HAVE_double_store)
    /* Initialize old_w even for store to workaround MSan warning.      */
    old_w.AO_val1 = 3316;
    old_w.AO_val2 = 2921;
# endif
# if defined(AO_HAVE_double_load)
    new_w = AO_double_load(&old_w);
    TA_assert(new_w.AO_val1 == 3316 && new_w.AO_val2 == 2921);
# elif !defined(AO_HAVE_double_load) \
       || !defined(AO_HAVE_double_load_acquire) \
       || !defined(AO_HAVE_double_load_acquire_read) \
       || !defined(AO_HAVE_double_load_dd_acquire_read) \
       || !defined(AO_HAVE_double_load_full) \
       || !defined(AO_HAVE_double_load_read)
    MISSING(AO_double_load);
# endif
# if defined(AO_HAVE_double_store)
    new_w.AO_val1 = 1375;
    new_w.AO_val2 = 8243;
    AO_double_store(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    AO_double_store(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    new_w.AO_val1 ^= old_w.AO_val1;
    new_w.AO_val2 ^= old_w.AO_val2;
    AO_double_store(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 0 && old_w.AO_val2 == 0);
# elif !defined(AO_HAVE_double_store) \
       || !defined(AO_HAVE_double_store_full) \
       || !defined(AO_HAVE_double_store_release) \
       || !defined(AO_HAVE_double_store_release_write) \
       || !defined(AO_HAVE_double_store_write)
    MISSING(AO_double_store);
# endif
# if defined(AO_HAVE_compare_double_and_swap_double)
    TA_assert(!AO_compare_double_and_swap_double(&w, 17, 42, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_double_and_swap_double(&w, 0, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double(&w, 12, 14, 64, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double(&w, 11, 13, 85, 82));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double(&w, 13, 12, 17, 42));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_double_and_swap_double(&w, 12, 13, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_double_and_swap_double(&w, 17, 42, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_double_and_swap_double);
# endif
# if defined(AO_HAVE_compare_and_swap_double)
    TA_assert(!AO_compare_and_swap_double(&w, 17, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_and_swap_double(&w, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double(&w, 13, 12, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double(&w, 1213, 48, 86));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_and_swap_double(&w, 12, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_and_swap_double(&w, 17, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_and_swap_double);
# endif
# if defined(AO_HAVE_double_compare_and_swap)
    old_w.AO_val1 = 4116;
    old_w.AO_val2 = 2121;
    new_w.AO_val1 = 8537;
    new_w.AO_val2 = 6410;
    TA_assert(!AO_double_compare_and_swap(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_double_compare_and_swap(&w, w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = 29;
    new_w.AO_val1 = 820;
    new_w.AO_val2 = 5917;
    TA_assert(!AO_double_compare_and_swap(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = 11;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 3552;
    new_w.AO_val2 = 1746;
    TA_assert(!AO_double_compare_and_swap(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 8537;
    new_w.AO_val1 = 4116;
    new_w.AO_val2 = 2121;
    TA_assert(!AO_double_compare_and_swap(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 1;
    TA_assert(AO_double_compare_and_swap(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 1 && w.AO_val2 == 2121);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = w.AO_val2;
    new_w.AO_val1--;
    new_w.AO_val2 = 0;
    TA_assert(AO_double_compare_and_swap(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_double_compare_and_swap);
# endif
}
/*
 * Copyright (c) 2003 by Hewlett-Packard Company.  All rights reserved.
 *
 * This file is covered by the GNU general public license, version 2.
 * see COPYING for details.
 */

/* Some basic sanity tests.  These do not test the barrier semantics. */

#undef TA_assert
#define TA_assert(e) \
  if (!(e)) { fprintf(stderr, "Assertion failed %s:%d (barrier: _release)\n", \
                    __FILE__, __LINE__), exit(1); }

#undef MISSING
#define MISSING(name) \
  printf("Missing: %s\n", #name "_release")

#if defined(CPPCHECK)
  void list_atomic_release(void);
  void char_list_atomic_release(void);
  void short_list_atomic_release(void);
  void int_list_atomic_release(void);
  void double_list_atomic_release(void);
#endif

void test_atomic_release(void)
{
  AO_t x;
  unsigned char b;
  unsigned short s;
  unsigned int zz;
# if defined(AO_HAVE_test_and_set_release)
    AO_TS_t z = AO_TS_INITIALIZER;
# endif
# if defined(AO_HAVE_double_compare_and_swap_release) \
     || defined(AO_HAVE_double_load_release) \
     || defined(AO_HAVE_double_store_release)
    static AO_double_t old_w; /* static to avoid misalignment */
    AO_double_t new_w;
# endif
# if defined(AO_HAVE_compare_and_swap_double_release) \
     || defined(AO_HAVE_compare_double_and_swap_double_release) \
     || defined(AO_HAVE_double_compare_and_swap_release)
    static AO_double_t w; /* static to avoid misalignment */
    w.AO_val1 = 0;
    w.AO_val2 = 0;
# endif

# if defined(CPPCHECK)
    list_atomic_release();
    char_list_atomic_release();
    short_list_atomic_release();
    int_list_atomic_release();
    double_list_atomic_release();
# endif
# if defined(AO_HAVE_nop_release)
    AO_nop_release();
# elif !defined(AO_HAVE_nop) || !defined(AO_HAVE_nop_full) \
       || !defined(AO_HAVE_nop_read) || !defined(AO_HAVE_nop_write)
    MISSING(AO_nop);
# endif
# if defined(AO_HAVE_store_release)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile AO_t *)&x = 0; /* initialize to avoid false warning */
#   endif
    AO_store_release(&x, 13);
    TA_assert(x == 13);
# else
#   if !defined(AO_HAVE_store) || !defined(AO_HAVE_store_full) \
       || !defined(AO_HAVE_store_release) \
       || !defined(AO_HAVE_store_release_write) \
       || !defined(AO_HAVE_store_write)
      MISSING(AO_store);
#   endif
    x = 13;
# endif
# if defined(AO_HAVE_load_release)
    TA_assert(AO_load_release(&x) == 13);
# elif !defined(AO_HAVE_load) || !defined(AO_HAVE_load_acquire) \
       || !defined(AO_HAVE_load_acquire_read) \
       || !defined(AO_HAVE_load_dd_acquire_read) \
       || !defined(AO_HAVE_load_full) || !defined(AO_HAVE_load_read)
    MISSING(AO_load);
# endif
# if defined(AO_HAVE_test_and_set_release)
    TA_assert(AO_test_and_set_release(&z) == AO_TS_CLEAR);
    TA_assert(AO_test_and_set_release(&z) == AO_TS_SET);
    TA_assert(AO_test_and_set_release(&z) == AO_TS_SET);
    AO_CLEAR(&z);
# else
    MISSING(AO_test_and_set);
# endif
# if defined(AO_HAVE_fetch_and_add_release)
    TA_assert(AO_fetch_and_add_release(&x, 42) == 13);
    TA_assert(AO_fetch_and_add_release(&x, (AO_t)(-42)) == 55);
# else
    MISSING(AO_fetch_and_add);
# endif
# if defined(AO_HAVE_fetch_and_add1_release)
    TA_assert(AO_fetch_and_add1_release(&x) == 13);
# else
    MISSING(AO_fetch_and_add1);
    ++x;
# endif
# if defined(AO_HAVE_fetch_and_sub1_release)
    TA_assert(AO_fetch_and_sub1_release(&x) == 14);
# else
    MISSING(AO_fetch_and_sub1);
    --x;
# endif
# if defined(AO_HAVE_short_store_release)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile short *)&s = 0;
#   endif
    AO_short_store_release(&s, 13);
# else
#   if !defined(AO_HAVE_short_store) || !defined(AO_HAVE_short_store_full) \
       || !defined(AO_HAVE_short_store_release) \
       || !defined(AO_HAVE_short_store_release_write) \
       || !defined(AO_HAVE_short_store_write)
      MISSING(AO_short_store);
#   endif
    s = 13;
# endif
# if defined(AO_HAVE_short_load_release)
    TA_assert(AO_short_load(&s) == 13);
# elif !defined(AO_HAVE_short_load) || !defined(AO_HAVE_short_load_acquire) \
       || !defined(AO_HAVE_short_load_acquire_read) \
       || !defined(AO_HAVE_short_load_dd_acquire_read) \
       || !defined(AO_HAVE_short_load_full) \
       || !defined(AO_HAVE_short_load_read)
    MISSING(AO_short_load);
# endif
# if defined(AO_HAVE_short_fetch_and_add_release)
    TA_assert(AO_short_fetch_and_add_release(&s, 42) == 13);
    TA_assert(AO_short_fetch_and_add_release(&s, (unsigned short)-42) == 55);
# else
    MISSING(AO_short_fetch_and_add);
# endif
# if defined(AO_HAVE_short_fetch_and_add1_release)
    TA_assert(AO_short_fetch_and_add1_release(&s) == 13);
# else
    MISSING(AO_short_fetch_and_add1);
    ++s;
# endif
# if defined(AO_HAVE_short_fetch_and_sub1_release)
    TA_assert(AO_short_fetch_and_sub1_release(&s) == 14);
# else
    MISSING(AO_short_fetch_and_sub1);
    --s;
# endif
  TA_assert(*(volatile short *)&s == 13);
# if defined(AO_HAVE_char_store_release)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile char *)&b = 0;
#   endif
    AO_char_store_release(&b, 13);
# else
#   if !defined(AO_HAVE_char_store) || !defined(AO_HAVE_char_store_full) \
       || !defined(AO_HAVE_char_store_release) \
       || !defined(AO_HAVE_char_store_release_write) \
       || !defined(AO_HAVE_char_store_write)
      MISSING(AO_char_store);
#   endif
    b = 13;
# endif
# if defined(AO_HAVE_char_load_release)
    TA_assert(AO_char_load(&b) == 13);
# elif !defined(AO_HAVE_char_load) || !defined(AO_HAVE_char_load_acquire) \
       || !defined(AO_HAVE_char_load_acquire_read) \
       || !defined(AO_HAVE_char_load_dd_acquire_read) \
       || !defined(AO_HAVE_char_load_full) || !defined(AO_HAVE_char_load_read)
    MISSING(AO_char_load);
# endif
# if defined(AO_HAVE_char_fetch_and_add_release)
    TA_assert(AO_char_fetch_and_add_release(&b, 42) == 13);
    TA_assert(AO_char_fetch_and_add_release(&b, (unsigned char)-42) == 55);
# else
    MISSING(AO_char_fetch_and_add);
# endif
# if defined(AO_HAVE_char_fetch_and_add1_release)
    TA_assert(AO_char_fetch_and_add1_release(&b) == 13);
# else
    MISSING(AO_char_fetch_and_add1);
    ++b;
# endif
# if defined(AO_HAVE_char_fetch_and_sub1_release)
    TA_assert(AO_char_fetch_and_sub1_release(&b) == 14);
# else
    MISSING(AO_char_fetch_and_sub1);
    --b;
# endif
  TA_assert(*(volatile char *)&b == 13);
# if defined(AO_HAVE_int_store_release)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile int *)&zz = 0;
#   endif
    AO_int_store_release(&zz, 13);
# else
#   if !defined(AO_HAVE_int_store) || !defined(AO_HAVE_int_store_full) \
       || !defined(AO_HAVE_int_store_release) \
       || !defined(AO_HAVE_int_store_release_write) \
       || !defined(AO_HAVE_int_store_write)
      MISSING(AO_int_store);
#   endif
    zz = 13;
# endif
# if defined(AO_HAVE_int_load_release)
    TA_assert(AO_int_load(&zz) == 13);
# elif !defined(AO_HAVE_int_load) || !defined(AO_HAVE_int_load_acquire) \
       || !defined(AO_HAVE_int_load_acquire_read) \
       || !defined(AO_HAVE_int_load_dd_acquire_read) \
       || !defined(AO_HAVE_int_load_full) || !defined(AO_HAVE_int_load_read)
    MISSING(AO_int_load);
# endif
# if defined(AO_HAVE_int_fetch_and_add_release)
    TA_assert(AO_int_fetch_and_add_release(&zz, 42) == 13);
    TA_assert(AO_int_fetch_and_add_release(&zz, (unsigned int)-42) == 55);
# else
    MISSING(AO_int_fetch_and_add);
# endif
# if defined(AO_HAVE_int_fetch_and_add1_release)
    TA_assert(AO_int_fetch_and_add1_release(&zz) == 13);
# else
    MISSING(AO_int_fetch_and_add1);
    ++zz;
# endif
# if defined(AO_HAVE_int_fetch_and_sub1_release)
    TA_assert(AO_int_fetch_and_sub1_release(&zz) == 14);
# else
    MISSING(AO_int_fetch_and_sub1);
    --zz;
# endif
  TA_assert(*(volatile int *)&zz == 13);
# if defined(AO_HAVE_compare_and_swap_release)
    TA_assert(!AO_compare_and_swap_release(&x, 14, 42));
    TA_assert(x == 13);
    TA_assert(AO_compare_and_swap_release(&x, 13, 42));
    TA_assert(x == 42);
# else
    MISSING(AO_compare_and_swap);
    if (*(volatile AO_t *)&x == 13) x = 42;
# endif
# if defined(AO_HAVE_or_release)
    AO_or_release(&x, 66);
    TA_assert(x == 106);
# else
#   if !defined(AO_HAVE_or) || !defined(AO_HAVE_or_acquire) \
       || !defined(AO_HAVE_or_acquire_read) || !defined(AO_HAVE_or_full) \
       || !defined(AO_HAVE_or_read) || !defined(AO_HAVE_or_release) \
       || !defined(AO_HAVE_or_release_write) || !defined(AO_HAVE_or_write)
      MISSING(AO_or);
#   endif
    x |= 66;
# endif
# if defined(AO_HAVE_xor_release)
    AO_xor_release(&x, 181);
    TA_assert(x == 223);
# else
#   if !defined(AO_HAVE_xor) || !defined(AO_HAVE_xor_acquire) \
       || !defined(AO_HAVE_xor_acquire_read) || !defined(AO_HAVE_xor_full) \
       || !defined(AO_HAVE_xor_read) || !defined(AO_HAVE_xor_release) \
       || !defined(AO_HAVE_xor_release_write) || !defined(AO_HAVE_xor_write)
      MISSING(AO_xor);
#   endif
    x ^= 181;
# endif
# if defined(AO_HAVE_and_release)
    AO_and_release(&x, 57);
    TA_assert(x == 25);
# else
#   if !defined(AO_HAVE_and) || !defined(AO_HAVE_and_acquire) \
       || !defined(AO_HAVE_and_acquire_read) || !defined(AO_HAVE_and_full) \
       || !defined(AO_HAVE_and_read) || !defined(AO_HAVE_and_release) \
       || !defined(AO_HAVE_and_release_write) || !defined(AO_HAVE_and_write)
      MISSING(AO_and);
#   endif
    x &= 57;
# endif
# if defined(AO_HAVE_fetch_compare_and_swap_release)
    TA_assert(AO_fetch_compare_and_swap_release(&x, 14, 117) == 25);
    TA_assert(x == 25);
    TA_assert(AO_fetch_compare_and_swap_release(&x, 25, 117) == 25);
# else
    MISSING(AO_fetch_compare_and_swap);
    if (x == 25) x = 117;
# endif
  TA_assert(x == 117);
# if defined(AO_HAVE_short_compare_and_swap_release)
    TA_assert(!AO_short_compare_and_swap_release(&s, 14, 42));
    TA_assert(s == 13);
    TA_assert(AO_short_compare_and_swap_release(&s, 13, 42));
    TA_assert(s == 42);
# else
    MISSING(AO_short_compare_and_swap);
    if (*(volatile short *)&s == 13) s = 42;
# endif
# if defined(AO_HAVE_short_or_release)
    AO_short_or_release(&s, 66);
    TA_assert(s == 106);
# else
#   if !defined(AO_HAVE_short_or) || !defined(AO_HAVE_short_or_acquire) \
       || !defined(AO_HAVE_short_or_acquire_read) \
       || !defined(AO_HAVE_short_or_full) || !defined(AO_HAVE_short_or_read) \
       || !defined(AO_HAVE_short_or_release) \
       || !defined(AO_HAVE_short_or_release_write) \
       || !defined(AO_HAVE_short_or_write)
      MISSING(AO_short_or);
#   endif
    s |= 66;
# endif
# if defined(AO_HAVE_short_xor_release)
    AO_short_xor_release(&s, 181);
    TA_assert(s == 223);
# else
#   if !defined(AO_HAVE_short_xor) || !defined(AO_HAVE_short_xor_acquire) \
       || !defined(AO_HAVE_short_xor_acquire_read) \
       || !defined(AO_HAVE_short_xor_full) \
       || !defined(AO_HAVE_short_xor_read) \
       || !defined(AO_HAVE_short_xor_release) \
       || !defined(AO_HAVE_short_xor_release_write) \
       || !defined(AO_HAVE_short_xor_write)
      MISSING(AO_short_xor);
#   endif
    s ^= 181;
# endif
# if defined(AO_HAVE_short_and_release)
    AO_short_and_release(&s, 57);
    TA_assert(s == 25);
# else
#   if !defined(AO_HAVE_short_and) || !defined(AO_HAVE_short_and_acquire) \
       || !defined(AO_HAVE_short_and_acquire_read) \
       || !defined(AO_HAVE_short_and_full) \
       || !defined(AO_HAVE_short_and_read) \
       || !defined(AO_HAVE_short_and_release) \
       || !defined(AO_HAVE_short_and_release_write) \
       || !defined(AO_HAVE_short_and_write)
      MISSING(AO_short_and);
#   endif
    s &= 57;
# endif
# if defined(AO_HAVE_short_fetch_compare_and_swap_release)
    TA_assert(AO_short_fetch_compare_and_swap_release(&s, 14, 117) == 25);
    TA_assert(s == 25);
    TA_assert(AO_short_fetch_compare_and_swap_release(&s, 25, 117) == 25);
# else
    MISSING(AO_short_fetch_compare_and_swap);
    if (s == 25) s = 117;
# endif
  TA_assert(s == 117);
# if defined(AO_HAVE_char_compare_and_swap_release)
    TA_assert(!AO_char_compare_and_swap_release(&b, 14, 42));
    TA_assert(b == 13);
    TA_assert(AO_char_compare_and_swap_release(&b, 13, 42));
    TA_assert(b == 42);
# else
    MISSING(AO_char_compare_and_swap);
    if (*(volatile char *)&b == 13) b = 42;
# endif
# if defined(AO_HAVE_char_or_release)
    AO_char_or_release(&b, 66);
    TA_assert(b == 106);
# else
#   if !defined(AO_HAVE_char_or) || !defined(AO_HAVE_char_or_acquire) \
       || !defined(AO_HAVE_char_or_acquire_read) \
       || !defined(AO_HAVE_char_or_full) || !defined(AO_HAVE_char_or_read) \
       || !defined(AO_HAVE_char_or_release) \
       || !defined(AO_HAVE_char_or_release_write) \
       || !defined(AO_HAVE_char_or_write)
      MISSING(AO_char_or);
#   endif
    b |= 66;
# endif
# if defined(AO_HAVE_char_xor_release)
    AO_char_xor_release(&b, 181);
    TA_assert(b == 223);
# else
#   if !defined(AO_HAVE_char_xor) || !defined(AO_HAVE_char_xor_acquire) \
       || !defined(AO_HAVE_char_xor_acquire_read) \
       || !defined(AO_HAVE_char_xor_full) || !defined(AO_HAVE_char_xor_read) \
       || !defined(AO_HAVE_char_xor_release) \
       || !defined(AO_HAVE_char_xor_release_write) \
       || !defined(AO_HAVE_char_xor_write)
      MISSING(AO_char_xor);
#   endif
    b ^= 181;
# endif
# if defined(AO_HAVE_char_and_release)
    AO_char_and_release(&b, 57);
    TA_assert(b == 25);
# else
#   if !defined(AO_HAVE_char_and) || !defined(AO_HAVE_char_and_acquire) \
       || !defined(AO_HAVE_char_and_acquire_read) \
       || !defined(AO_HAVE_char_and_full) || !defined(AO_HAVE_char_and_read) \
       || !defined(AO_HAVE_char_and_release) \
       || !defined(AO_HAVE_char_and_release_write) \
       || !defined(AO_HAVE_char_and_write)
      MISSING(AO_char_and);
#   endif
    b &= 57;
# endif
# if defined(AO_HAVE_char_fetch_compare_and_swap_release)
    TA_assert(AO_char_fetch_compare_and_swap_release(&b, 14, 117) == 25);
    TA_assert(b == 25);
    TA_assert(AO_char_fetch_compare_and_swap_release(&b, 25, 117) == 25);
# else
    MISSING(AO_char_fetch_compare_and_swap);
    if (b == 25) b = 117;
# endif
  TA_assert(b == 117);
# if defined(AO_HAVE_int_compare_and_swap_release)
    TA_assert(!AO_int_compare_and_swap_release(&zz, 14, 42));
    TA_assert(zz == 13);
    TA_assert(AO_int_compare_and_swap_release(&zz, 13, 42));
    TA_assert(zz == 42);
# else
    MISSING(AO_int_compare_and_swap);
    if (*(volatile int *)&zz == 13) zz = 42;
# endif
# if defined(AO_HAVE_int_or_release)
    AO_int_or_release(&zz, 66);
    TA_assert(zz == 106);
# else
#   if !defined(AO_HAVE_int_or) || !defined(AO_HAVE_int_or_acquire) \
       || !defined(AO_HAVE_int_or_acquire_read) \
       || !defined(AO_HAVE_int_or_full) || !defined(AO_HAVE_int_or_read) \
       || !defined(AO_HAVE_int_or_release) \
       || !defined(AO_HAVE_int_or_release_write) \
       || !defined(AO_HAVE_int_or_write)
      MISSING(AO_int_or);
#   endif
    zz |= 66;
# endif
# if defined(AO_HAVE_int_xor_release)
    AO_int_xor_release(&zz, 181);
    TA_assert(zz == 223);
# else
#   if !defined(AO_HAVE_int_xor) || !defined(AO_HAVE_int_xor_acquire) \
       || !defined(AO_HAVE_int_xor_acquire_read) \
       || !defined(AO_HAVE_int_xor_full) || !defined(AO_HAVE_int_xor_read) \
       || !defined(AO_HAVE_int_xor_release) \
       || !defined(AO_HAVE_int_xor_release_write) \
       || !defined(AO_HAVE_int_xor_write)
      MISSING(AO_int_xor);
#   endif
    zz ^= 181;
# endif
# if defined(AO_HAVE_int_and_release)
    AO_int_and_release(&zz, 57);
    TA_assert(zz == 25);
# else
#   if !defined(AO_HAVE_int_and) || !defined(AO_HAVE_int_and_acquire) \
       || !defined(AO_HAVE_int_and_acquire_read) \
       || !defined(AO_HAVE_int_and_full) || !defined(AO_HAVE_int_and_read) \
       || !defined(AO_HAVE_int_and_release) \
       || !defined(AO_HAVE_int_and_release_write) \
       || !defined(AO_HAVE_int_and_write)
      MISSING(AO_int_and);
#   endif
    zz &= 57;
# endif
# if defined(AO_HAVE_int_fetch_compare_and_swap_release)
    TA_assert(AO_int_fetch_compare_and_swap_release(&zz, 14, 117) == 25);
    TA_assert(zz == 25);
    TA_assert(AO_int_fetch_compare_and_swap_release(&zz, 25, 117) == 25);
# else
    MISSING(AO_int_fetch_compare_and_swap);
    if (zz == 25) zz = 117;
# endif
  TA_assert(zz == 117);
# if defined(AO_HAVE_double_load_release) || defined(AO_HAVE_double_store_release)
    /* Initialize old_w even for store to workaround MSan warning.      */
    old_w.AO_val1 = 3316;
    old_w.AO_val2 = 2921;
# endif
# if defined(AO_HAVE_double_load_release)
    new_w = AO_double_load_release(&old_w);
    TA_assert(new_w.AO_val1 == 3316 && new_w.AO_val2 == 2921);
# elif !defined(AO_HAVE_double_load) \
       || !defined(AO_HAVE_double_load_acquire) \
       || !defined(AO_HAVE_double_load_acquire_read) \
       || !defined(AO_HAVE_double_load_dd_acquire_read) \
       || !defined(AO_HAVE_double_load_full) \
       || !defined(AO_HAVE_double_load_read)
    MISSING(AO_double_load);
# endif
# if defined(AO_HAVE_double_store_release)
    new_w.AO_val1 = 1375;
    new_w.AO_val2 = 8243;
    AO_double_store_release(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    AO_double_store_release(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    new_w.AO_val1 ^= old_w.AO_val1;
    new_w.AO_val2 ^= old_w.AO_val2;
    AO_double_store_release(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 0 && old_w.AO_val2 == 0);
# elif !defined(AO_HAVE_double_store) \
       || !defined(AO_HAVE_double_store_full) \
       || !defined(AO_HAVE_double_store_release) \
       || !defined(AO_HAVE_double_store_release_write) \
       || !defined(AO_HAVE_double_store_write)
    MISSING(AO_double_store);
# endif
# if defined(AO_HAVE_compare_double_and_swap_double_release)
    TA_assert(!AO_compare_double_and_swap_double_release(&w, 17, 42, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_double_and_swap_double_release(&w, 0, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_release(&w, 12, 14, 64, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_release(&w, 11, 13, 85, 82));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_release(&w, 13, 12, 17, 42));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_double_and_swap_double_release(&w, 12, 13, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_double_and_swap_double_release(&w, 17, 42, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_double_and_swap_double);
# endif
# if defined(AO_HAVE_compare_and_swap_double_release)
    TA_assert(!AO_compare_and_swap_double_release(&w, 17, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_and_swap_double_release(&w, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_release(&w, 13, 12, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_release(&w, 1213, 48, 86));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_and_swap_double_release(&w, 12, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_and_swap_double_release(&w, 17, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_and_swap_double);
# endif
# if defined(AO_HAVE_double_compare_and_swap_release)
    old_w.AO_val1 = 4116;
    old_w.AO_val2 = 2121;
    new_w.AO_val1 = 8537;
    new_w.AO_val2 = 6410;
    TA_assert(!AO_double_compare_and_swap_release(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_double_compare_and_swap_release(&w, w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = 29;
    new_w.AO_val1 = 820;
    new_w.AO_val2 = 5917;
    TA_assert(!AO_double_compare_and_swap_release(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = 11;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 3552;
    new_w.AO_val2 = 1746;
    TA_assert(!AO_double_compare_and_swap_release(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 8537;
    new_w.AO_val1 = 4116;
    new_w.AO_val2 = 2121;
    TA_assert(!AO_double_compare_and_swap_release(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 1;
    TA_assert(AO_double_compare_and_swap_release(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 1 && w.AO_val2 == 2121);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = w.AO_val2;
    new_w.AO_val1--;
    new_w.AO_val2 = 0;
    TA_assert(AO_double_compare_and_swap_release(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_double_compare_and_swap);
# endif
}
/*
 * Copyright (c) 2003 by Hewlett-Packard Company.  All rights reserved.
 *
 * This file is covered by the GNU general public license, version 2.
 * see COPYING for details.
 */

/* Some basic sanity tests.  These do not test the barrier semantics. */

#undef TA_assert
#define TA_assert(e) \
  if (!(e)) { fprintf(stderr, "Assertion failed %s:%d (barrier: _acquire)\n", \
                    __FILE__, __LINE__), exit(1); }

#undef MISSING
#define MISSING(name) \
  printf("Missing: %s\n", #name "_acquire")

#if defined(CPPCHECK)
  void list_atomic_acquire(void);
  void char_list_atomic_acquire(void);
  void short_list_atomic_acquire(void);
  void int_list_atomic_acquire(void);
  void double_list_atomic_acquire(void);
#endif

void test_atomic_acquire(void)
{
  AO_t x;
  unsigned char b;
  unsigned short s;
  unsigned int zz;
# if defined(AO_HAVE_test_and_set_acquire)
    AO_TS_t z = AO_TS_INITIALIZER;
# endif
# if defined(AO_HAVE_double_compare_and_swap_acquire) \
     || defined(AO_HAVE_double_load_acquire) \
     || defined(AO_HAVE_double_store_acquire)
    static AO_double_t old_w; /* static to avoid misalignment */
    AO_double_t new_w;
# endif
# if defined(AO_HAVE_compare_and_swap_double_acquire) \
     || defined(AO_HAVE_compare_double_and_swap_double_acquire) \
     || defined(AO_HAVE_double_compare_and_swap_acquire)
    static AO_double_t w; /* static to avoid misalignment */
    w.AO_val1 = 0;
    w.AO_val2 = 0;
# endif

# if defined(CPPCHECK)
    list_atomic_acquire();
    char_list_atomic_acquire();
    short_list_atomic_acquire();
    int_list_atomic_acquire();
    double_list_atomic_acquire();
# endif
# if defined(AO_HAVE_nop_acquire)
    AO_nop_acquire();
# elif !defined(AO_HAVE_nop) || !defined(AO_HAVE_nop_full) \
       || !defined(AO_HAVE_nop_read) || !defined(AO_HAVE_nop_write)
    MISSING(AO_nop);
# endif
# if defined(AO_HAVE_store_acquire)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile AO_t *)&x = 0; /* initialize to avoid false warning */
#   endif
    AO_store_acquire(&x, 13);
    TA_assert(x == 13);
# else
#   if !defined(AO_HAVE_store) || !defined(AO_HAVE_store_full) \
       || !defined(AO_HAVE_store_release) \
       || !defined(AO_HAVE_store_release_write) \
       || !defined(AO_HAVE_store_write)
      MISSING(AO_store);
#   endif
    x = 13;
# endif
# if defined(AO_HAVE_load_acquire)
    TA_assert(AO_load_acquire(&x) == 13);
# elif !defined(AO_HAVE_load) || !defined(AO_HAVE_load_acquire) \
       || !defined(AO_HAVE_load_acquire_read) \
       || !defined(AO_HAVE_load_dd_acquire_read) \
       || !defined(AO_HAVE_load_full) || !defined(AO_HAVE_load_read)
    MISSING(AO_load);
# endif
# if defined(AO_HAVE_test_and_set_acquire)
    TA_assert(AO_test_and_set_acquire(&z) == AO_TS_CLEAR);
    TA_assert(AO_test_and_set_acquire(&z) == AO_TS_SET);
    TA_assert(AO_test_and_set_acquire(&z) == AO_TS_SET);
    AO_CLEAR(&z);
# else
    MISSING(AO_test_and_set);
# endif
# if defined(AO_HAVE_fetch_and_add_acquire)
    TA_assert(AO_fetch_and_add_acquire(&x, 42) == 13);
    TA_assert(AO_fetch_and_add_acquire(&x, (AO_t)(-42)) == 55);
# else
    MISSING(AO_fetch_and_add);
# endif
# if defined(AO_HAVE_fetch_and_add1_acquire)
    TA_assert(AO_fetch_and_add1_acquire(&x) == 13);
# else
    MISSING(AO_fetch_and_add1);
    ++x;
# endif
# if defined(AO_HAVE_fetch_and_sub1_acquire)
    TA_assert(AO_fetch_and_sub1_acquire(&x) == 14);
# else
    MISSING(AO_fetch_and_sub1);
    --x;
# endif
# if defined(AO_HAVE_short_store_acquire)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile short *)&s = 0;
#   endif
    AO_short_store_acquire(&s, 13);
# else
#   if !defined(AO_HAVE_short_store) || !defined(AO_HAVE_short_store_full) \
       || !defined(AO_HAVE_short_store_release) \
       || !defined(AO_HAVE_short_store_release_write) \
       || !defined(AO_HAVE_short_store_write)
      MISSING(AO_short_store);
#   endif
    s = 13;
# endif
# if defined(AO_HAVE_short_load_acquire)
    TA_assert(AO_short_load(&s) == 13);
# elif !defined(AO_HAVE_short_load) || !defined(AO_HAVE_short_load_acquire) \
       || !defined(AO_HAVE_short_load_acquire_read) \
       || !defined(AO_HAVE_short_load_dd_acquire_read) \
       || !defined(AO_HAVE_short_load_full) \
       || !defined(AO_HAVE_short_load_read)
    MISSING(AO_short_load);
# endif
# if defined(AO_HAVE_short_fetch_and_add_acquire)
    TA_assert(AO_short_fetch_and_add_acquire(&s, 42) == 13);
    TA_assert(AO_short_fetch_and_add_acquire(&s, (unsigned short)-42) == 55);
# else
    MISSING(AO_short_fetch_and_add);
# endif
# if defined(AO_HAVE_short_fetch_and_add1_acquire)
    TA_assert(AO_short_fetch_and_add1_acquire(&s) == 13);
# else
    MISSING(AO_short_fetch_and_add1);
    ++s;
# endif
# if defined(AO_HAVE_short_fetch_and_sub1_acquire)
    TA_assert(AO_short_fetch_and_sub1_acquire(&s) == 14);
# else
    MISSING(AO_short_fetch_and_sub1);
    --s;
# endif
  TA_assert(*(volatile short *)&s == 13);
# if defined(AO_HAVE_char_store_acquire)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile char *)&b = 0;
#   endif
    AO_char_store_acquire(&b, 13);
# else
#   if !defined(AO_HAVE_char_store) || !defined(AO_HAVE_char_store_full) \
       || !defined(AO_HAVE_char_store_release) \
       || !defined(AO_HAVE_char_store_release_write) \
       || !defined(AO_HAVE_char_store_write)
      MISSING(AO_char_store);
#   endif
    b = 13;
# endif
# if defined(AO_HAVE_char_load_acquire)
    TA_assert(AO_char_load(&b) == 13);
# elif !defined(AO_HAVE_char_load) || !defined(AO_HAVE_char_load_acquire) \
       || !defined(AO_HAVE_char_load_acquire_read) \
       || !defined(AO_HAVE_char_load_dd_acquire_read) \
       || !defined(AO_HAVE_char_load_full) || !defined(AO_HAVE_char_load_read)
    MISSING(AO_char_load);
# endif
# if defined(AO_HAVE_char_fetch_and_add_acquire)
    TA_assert(AO_char_fetch_and_add_acquire(&b, 42) == 13);
    TA_assert(AO_char_fetch_and_add_acquire(&b, (unsigned char)-42) == 55);
# else
    MISSING(AO_char_fetch_and_add);
# endif
# if defined(AO_HAVE_char_fetch_and_add1_acquire)
    TA_assert(AO_char_fetch_and_add1_acquire(&b) == 13);
# else
    MISSING(AO_char_fetch_and_add1);
    ++b;
# endif
# if defined(AO_HAVE_char_fetch_and_sub1_acquire)
    TA_assert(AO_char_fetch_and_sub1_acquire(&b) == 14);
# else
    MISSING(AO_char_fetch_and_sub1);
    --b;
# endif
  TA_assert(*(volatile char *)&b == 13);
# if defined(AO_HAVE_int_store_acquire)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile int *)&zz = 0;
#   endif
    AO_int_store_acquire(&zz, 13);
# else
#   if !defined(AO_HAVE_int_store) || !defined(AO_HAVE_int_store_full) \
       || !defined(AO_HAVE_int_store_release) \
       || !defined(AO_HAVE_int_store_release_write) \
       || !defined(AO_HAVE_int_store_write)
      MISSING(AO_int_store);
#   endif
    zz = 13;
# endif
# if defined(AO_HAVE_int_load_acquire)
    TA_assert(AO_int_load(&zz) == 13);
# elif !defined(AO_HAVE_int_load) || !defined(AO_HAVE_int_load_acquire) \
       || !defined(AO_HAVE_int_load_acquire_read) \
       || !defined(AO_HAVE_int_load_dd_acquire_read) \
       || !defined(AO_HAVE_int_load_full) || !defined(AO_HAVE_int_load_read)
    MISSING(AO_int_load);
# endif
# if defined(AO_HAVE_int_fetch_and_add_acquire)
    TA_assert(AO_int_fetch_and_add_acquire(&zz, 42) == 13);
    TA_assert(AO_int_fetch_and_add_acquire(&zz, (unsigned int)-42) == 55);
# else
    MISSING(AO_int_fetch_and_add);
# endif
# if defined(AO_HAVE_int_fetch_and_add1_acquire)
    TA_assert(AO_int_fetch_and_add1_acquire(&zz) == 13);
# else
    MISSING(AO_int_fetch_and_add1);
    ++zz;
# endif
# if defined(AO_HAVE_int_fetch_and_sub1_acquire)
    TA_assert(AO_int_fetch_and_sub1_acquire(&zz) == 14);
# else
    MISSING(AO_int_fetch_and_sub1);
    --zz;
# endif
  TA_assert(*(volatile int *)&zz == 13);
# if defined(AO_HAVE_compare_and_swap_acquire)
    TA_assert(!AO_compare_and_swap_acquire(&x, 14, 42));
    TA_assert(x == 13);
    TA_assert(AO_compare_and_swap_acquire(&x, 13, 42));
    TA_assert(x == 42);
# else
    MISSING(AO_compare_and_swap);
    if (*(volatile AO_t *)&x == 13) x = 42;
# endif
# if defined(AO_HAVE_or_acquire)
    AO_or_acquire(&x, 66);
    TA_assert(x == 106);
# else
#   if !defined(AO_HAVE_or) || !defined(AO_HAVE_or_acquire) \
       || !defined(AO_HAVE_or_acquire_read) || !defined(AO_HAVE_or_full) \
       || !defined(AO_HAVE_or_read) || !defined(AO_HAVE_or_release) \
       || !defined(AO_HAVE_or_release_write) || !defined(AO_HAVE_or_write)
      MISSING(AO_or);
#   endif
    x |= 66;
# endif
# if defined(AO_HAVE_xor_acquire)
    AO_xor_acquire(&x, 181);
    TA_assert(x == 223);
# else
#   if !defined(AO_HAVE_xor) || !defined(AO_HAVE_xor_acquire) \
       || !defined(AO_HAVE_xor_acquire_read) || !defined(AO_HAVE_xor_full) \
       || !defined(AO_HAVE_xor_read) || !defined(AO_HAVE_xor_release) \
       || !defined(AO_HAVE_xor_release_write) || !defined(AO_HAVE_xor_write)
      MISSING(AO_xor);
#   endif
    x ^= 181;
# endif
# if defined(AO_HAVE_and_acquire)
    AO_and_acquire(&x, 57);
    TA_assert(x == 25);
# else
#   if !defined(AO_HAVE_and) || !defined(AO_HAVE_and_acquire) \
       || !defined(AO_HAVE_and_acquire_read) || !defined(AO_HAVE_and_full) \
       || !defined(AO_HAVE_and_read) || !defined(AO_HAVE_and_release) \
       || !defined(AO_HAVE_and_release_write) || !defined(AO_HAVE_and_write)
      MISSING(AO_and);
#   endif
    x &= 57;
# endif
# if defined(AO_HAVE_fetch_compare_and_swap_acquire)
    TA_assert(AO_fetch_compare_and_swap_acquire(&x, 14, 117) == 25);
    TA_assert(x == 25);
    TA_assert(AO_fetch_compare_and_swap_acquire(&x, 25, 117) == 25);
# else
    MISSING(AO_fetch_compare_and_swap);
    if (x == 25) x = 117;
# endif
  TA_assert(x == 117);
# if defined(AO_HAVE_short_compare_and_swap_acquire)
    TA_assert(!AO_short_compare_and_swap_acquire(&s, 14, 42));
    TA_assert(s == 13);
    TA_assert(AO_short_compare_and_swap_acquire(&s, 13, 42));
    TA_assert(s == 42);
# else
    MISSING(AO_short_compare_and_swap);
    if (*(volatile short *)&s == 13) s = 42;
# endif
# if defined(AO_HAVE_short_or_acquire)
    AO_short_or_acquire(&s, 66);
    TA_assert(s == 106);
# else
#   if !defined(AO_HAVE_short_or) || !defined(AO_HAVE_short_or_acquire) \
       || !defined(AO_HAVE_short_or_acquire_read) \
       || !defined(AO_HAVE_short_or_full) || !defined(AO_HAVE_short_or_read) \
       || !defined(AO_HAVE_short_or_release) \
       || !defined(AO_HAVE_short_or_release_write) \
       || !defined(AO_HAVE_short_or_write)
      MISSING(AO_short_or);
#   endif
    s |= 66;
# endif
# if defined(AO_HAVE_short_xor_acquire)
    AO_short_xor_acquire(&s, 181);
    TA_assert(s == 223);
# else
#   if !defined(AO_HAVE_short_xor) || !defined(AO_HAVE_short_xor_acquire) \
       || !defined(AO_HAVE_short_xor_acquire_read) \
       || !defined(AO_HAVE_short_xor_full) \
       || !defined(AO_HAVE_short_xor_read) \
       || !defined(AO_HAVE_short_xor_release) \
       || !defined(AO_HAVE_short_xor_release_write) \
       || !defined(AO_HAVE_short_xor_write)
      MISSING(AO_short_xor);
#   endif
    s ^= 181;
# endif
# if defined(AO_HAVE_short_and_acquire)
    AO_short_and_acquire(&s, 57);
    TA_assert(s == 25);
# else
#   if !defined(AO_HAVE_short_and) || !defined(AO_HAVE_short_and_acquire) \
       || !defined(AO_HAVE_short_and_acquire_read) \
       || !defined(AO_HAVE_short_and_full) \
       || !defined(AO_HAVE_short_and_read) \
       || !defined(AO_HAVE_short_and_release) \
       || !defined(AO_HAVE_short_and_release_write) \
       || !defined(AO_HAVE_short_and_write)
      MISSING(AO_short_and);
#   endif
    s &= 57;
# endif
# if defined(AO_HAVE_short_fetch_compare_and_swap_acquire)
    TA_assert(AO_short_fetch_compare_and_swap_acquire(&s, 14, 117) == 25);
    TA_assert(s == 25);
    TA_assert(AO_short_fetch_compare_and_swap_acquire(&s, 25, 117) == 25);
# else
    MISSING(AO_short_fetch_compare_and_swap);
    if (s == 25) s = 117;
# endif
  TA_assert(s == 117);
# if defined(AO_HAVE_char_compare_and_swap_acquire)
    TA_assert(!AO_char_compare_and_swap_acquire(&b, 14, 42));
    TA_assert(b == 13);
    TA_assert(AO_char_compare_and_swap_acquire(&b, 13, 42));
    TA_assert(b == 42);
# else
    MISSING(AO_char_compare_and_swap);
    if (*(volatile char *)&b == 13) b = 42;
# endif
# if defined(AO_HAVE_char_or_acquire)
    AO_char_or_acquire(&b, 66);
    TA_assert(b == 106);
# else
#   if !defined(AO_HAVE_char_or) || !defined(AO_HAVE_char_or_acquire) \
       || !defined(AO_HAVE_char_or_acquire_read) \
       || !defined(AO_HAVE_char_or_full) || !defined(AO_HAVE_char_or_read) \
       || !defined(AO_HAVE_char_or_release) \
       || !defined(AO_HAVE_char_or_release_write) \
       || !defined(AO_HAVE_char_or_write)
      MISSING(AO_char_or);
#   endif
    b |= 66;
# endif
# if defined(AO_HAVE_char_xor_acquire)
    AO_char_xor_acquire(&b, 181);
    TA_assert(b == 223);
# else
#   if !defined(AO_HAVE_char_xor) || !defined(AO_HAVE_char_xor_acquire) \
       || !defined(AO_HAVE_char_xor_acquire_read) \
       || !defined(AO_HAVE_char_xor_full) || !defined(AO_HAVE_char_xor_read) \
       || !defined(AO_HAVE_char_xor_release) \
       || !defined(AO_HAVE_char_xor_release_write) \
       || !defined(AO_HAVE_char_xor_write)
      MISSING(AO_char_xor);
#   endif
    b ^= 181;
# endif
# if defined(AO_HAVE_char_and_acquire)
    AO_char_and_acquire(&b, 57);
    TA_assert(b == 25);
# else
#   if !defined(AO_HAVE_char_and) || !defined(AO_HAVE_char_and_acquire) \
       || !defined(AO_HAVE_char_and_acquire_read) \
       || !defined(AO_HAVE_char_and_full) || !defined(AO_HAVE_char_and_read) \
       || !defined(AO_HAVE_char_and_release) \
       || !defined(AO_HAVE_char_and_release_write) \
       || !defined(AO_HAVE_char_and_write)
      MISSING(AO_char_and);
#   endif
    b &= 57;
# endif
# if defined(AO_HAVE_char_fetch_compare_and_swap_acquire)
    TA_assert(AO_char_fetch_compare_and_swap_acquire(&b, 14, 117) == 25);
    TA_assert(b == 25);
    TA_assert(AO_char_fetch_compare_and_swap_acquire(&b, 25, 117) == 25);
# else
    MISSING(AO_char_fetch_compare_and_swap);
    if (b == 25) b = 117;
# endif
  TA_assert(b == 117);
# if defined(AO_HAVE_int_compare_and_swap_acquire)
    TA_assert(!AO_int_compare_and_swap_acquire(&zz, 14, 42));
    TA_assert(zz == 13);
    TA_assert(AO_int_compare_and_swap_acquire(&zz, 13, 42));
    TA_assert(zz == 42);
# else
    MISSING(AO_int_compare_and_swap);
    if (*(volatile int *)&zz == 13) zz = 42;
# endif
# if defined(AO_HAVE_int_or_acquire)
    AO_int_or_acquire(&zz, 66);
    TA_assert(zz == 106);
# else
#   if !defined(AO_HAVE_int_or) || !defined(AO_HAVE_int_or_acquire) \
       || !defined(AO_HAVE_int_or_acquire_read) \
       || !defined(AO_HAVE_int_or_full) || !defined(AO_HAVE_int_or_read) \
       || !defined(AO_HAVE_int_or_release) \
       || !defined(AO_HAVE_int_or_release_write) \
       || !defined(AO_HAVE_int_or_write)
      MISSING(AO_int_or);
#   endif
    zz |= 66;
# endif
# if defined(AO_HAVE_int_xor_acquire)
    AO_int_xor_acquire(&zz, 181);
    TA_assert(zz == 223);
# else
#   if !defined(AO_HAVE_int_xor) || !defined(AO_HAVE_int_xor_acquire) \
       || !defined(AO_HAVE_int_xor_acquire_read) \
       || !defined(AO_HAVE_int_xor_full) || !defined(AO_HAVE_int_xor_read) \
       || !defined(AO_HAVE_int_xor_release) \
       || !defined(AO_HAVE_int_xor_release_write) \
       || !defined(AO_HAVE_int_xor_write)
      MISSING(AO_int_xor);
#   endif
    zz ^= 181;
# endif
# if defined(AO_HAVE_int_and_acquire)
    AO_int_and_acquire(&zz, 57);
    TA_assert(zz == 25);
# else
#   if !defined(AO_HAVE_int_and) || !defined(AO_HAVE_int_and_acquire) \
       || !defined(AO_HAVE_int_and_acquire_read) \
       || !defined(AO_HAVE_int_and_full) || !defined(AO_HAVE_int_and_read) \
       || !defined(AO_HAVE_int_and_release) \
       || !defined(AO_HAVE_int_and_release_write) \
       || !defined(AO_HAVE_int_and_write)
      MISSING(AO_int_and);
#   endif
    zz &= 57;
# endif
# if defined(AO_HAVE_int_fetch_compare_and_swap_acquire)
    TA_assert(AO_int_fetch_compare_and_swap_acquire(&zz, 14, 117) == 25);
    TA_assert(zz == 25);
    TA_assert(AO_int_fetch_compare_and_swap_acquire(&zz, 25, 117) == 25);
# else
    MISSING(AO_int_fetch_compare_and_swap);
    if (zz == 25) zz = 117;
# endif
  TA_assert(zz == 117);
# if defined(AO_HAVE_double_load_acquire) || defined(AO_HAVE_double_store_acquire)
    /* Initialize old_w even for store to workaround MSan warning.      */
    old_w.AO_val1 = 3316;
    old_w.AO_val2 = 2921;
# endif
# if defined(AO_HAVE_double_load_acquire)
    new_w = AO_double_load_acquire(&old_w);
    TA_assert(new_w.AO_val1 == 3316 && new_w.AO_val2 == 2921);
# elif !defined(AO_HAVE_double_load) \
       || !defined(AO_HAVE_double_load_acquire) \
       || !defined(AO_HAVE_double_load_acquire_read) \
       || !defined(AO_HAVE_double_load_dd_acquire_read) \
       || !defined(AO_HAVE_double_load_full) \
       || !defined(AO_HAVE_double_load_read)
    MISSING(AO_double_load);
# endif
# if defined(AO_HAVE_double_store_acquire)
    new_w.AO_val1 = 1375;
    new_w.AO_val2 = 8243;
    AO_double_store_acquire(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    AO_double_store_acquire(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    new_w.AO_val1 ^= old_w.AO_val1;
    new_w.AO_val2 ^= old_w.AO_val2;
    AO_double_store_acquire(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 0 && old_w.AO_val2 == 0);
# elif !defined(AO_HAVE_double_store) \
       || !defined(AO_HAVE_double_store_full) \
       || !defined(AO_HAVE_double_store_release) \
       || !defined(AO_HAVE_double_store_release_write) \
       || !defined(AO_HAVE_double_store_write)
    MISSING(AO_double_store);
# endif
# if defined(AO_HAVE_compare_double_and_swap_double_acquire)
    TA_assert(!AO_compare_double_and_swap_double_acquire(&w, 17, 42, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_double_and_swap_double_acquire(&w, 0, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_acquire(&w, 12, 14, 64, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_acquire(&w, 11, 13, 85, 82));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_acquire(&w, 13, 12, 17, 42));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_double_and_swap_double_acquire(&w, 12, 13, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_double_and_swap_double_acquire(&w, 17, 42, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_double_and_swap_double);
# endif
# if defined(AO_HAVE_compare_and_swap_double_acquire)
    TA_assert(!AO_compare_and_swap_double_acquire(&w, 17, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_and_swap_double_acquire(&w, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_acquire(&w, 13, 12, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_acquire(&w, 1213, 48, 86));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_and_swap_double_acquire(&w, 12, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_and_swap_double_acquire(&w, 17, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_and_swap_double);
# endif
# if defined(AO_HAVE_double_compare_and_swap_acquire)
    old_w.AO_val1 = 4116;
    old_w.AO_val2 = 2121;
    new_w.AO_val1 = 8537;
    new_w.AO_val2 = 6410;
    TA_assert(!AO_double_compare_and_swap_acquire(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_double_compare_and_swap_acquire(&w, w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = 29;
    new_w.AO_val1 = 820;
    new_w.AO_val2 = 5917;
    TA_assert(!AO_double_compare_and_swap_acquire(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = 11;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 3552;
    new_w.AO_val2 = 1746;
    TA_assert(!AO_double_compare_and_swap_acquire(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 8537;
    new_w.AO_val1 = 4116;
    new_w.AO_val2 = 2121;
    TA_assert(!AO_double_compare_and_swap_acquire(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 1;
    TA_assert(AO_double_compare_and_swap_acquire(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 1 && w.AO_val2 == 2121);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = w.AO_val2;
    new_w.AO_val1--;
    new_w.AO_val2 = 0;
    TA_assert(AO_double_compare_and_swap_acquire(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_double_compare_and_swap);
# endif
}
/*
 * Copyright (c) 2003 by Hewlett-Packard Company.  All rights reserved.
 *
 * This file is covered by the GNU general public license, version 2.
 * see COPYING for details.
 */

/* Some basic sanity tests.  These do not test the barrier semantics. */

#undef TA_assert
#define TA_assert(e) \
  if (!(e)) { fprintf(stderr, "Assertion failed %s:%d (barrier: _read)\n", \
                    __FILE__, __LINE__), exit(1); }

#undef MISSING
#define MISSING(name) \
  printf("Missing: %s\n", #name "_read")

#if defined(CPPCHECK)
  void list_atomic_read(void);
  void char_list_atomic_read(void);
  void short_list_atomic_read(void);
  void int_list_atomic_read(void);
  void double_list_atomic_read(void);
#endif

void test_atomic_read(void)
{
  AO_t x;
  unsigned char b;
  unsigned short s;
  unsigned int zz;
# if defined(AO_HAVE_test_and_set_read)
    AO_TS_t z = AO_TS_INITIALIZER;
# endif
# if defined(AO_HAVE_double_compare_and_swap_read) \
     || defined(AO_HAVE_double_load_read) \
     || defined(AO_HAVE_double_store_read)
    static AO_double_t old_w; /* static to avoid misalignment */
    AO_double_t new_w;
# endif
# if defined(AO_HAVE_compare_and_swap_double_read) \
     || defined(AO_HAVE_compare_double_and_swap_double_read) \
     || defined(AO_HAVE_double_compare_and_swap_read)
    static AO_double_t w; /* static to avoid misalignment */
    w.AO_val1 = 0;
    w.AO_val2 = 0;
# endif

# if defined(CPPCHECK)
    list_atomic_read();
    char_list_atomic_read();
    short_list_atomic_read();
    int_list_atomic_read();
    double_list_atomic_read();
# endif
# if defined(AO_HAVE_nop_read)
    AO_nop_read();
# elif !defined(AO_HAVE_nop) || !defined(AO_HAVE_nop_full) \
       || !defined(AO_HAVE_nop_read) || !defined(AO_HAVE_nop_write)
    MISSING(AO_nop);
# endif
# if defined(AO_HAVE_store_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile AO_t *)&x = 0; /* initialize to avoid false warning */
#   endif
    AO_store_read(&x, 13);
    TA_assert(x == 13);
# else
#   if !defined(AO_HAVE_store) || !defined(AO_HAVE_store_full) \
       || !defined(AO_HAVE_store_release) \
       || !defined(AO_HAVE_store_release_write) \
       || !defined(AO_HAVE_store_write)
      MISSING(AO_store);
#   endif
    x = 13;
# endif
# if defined(AO_HAVE_load_read)
    TA_assert(AO_load_read(&x) == 13);
# elif !defined(AO_HAVE_load) || !defined(AO_HAVE_load_acquire) \
       || !defined(AO_HAVE_load_acquire_read) \
       || !defined(AO_HAVE_load_dd_acquire_read) \
       || !defined(AO_HAVE_load_full) || !defined(AO_HAVE_load_read)
    MISSING(AO_load);
# endif
# if defined(AO_HAVE_test_and_set_read)
    TA_assert(AO_test_and_set_read(&z) == AO_TS_CLEAR);
    TA_assert(AO_test_and_set_read(&z) == AO_TS_SET);
    TA_assert(AO_test_and_set_read(&z) == AO_TS_SET);
    AO_CLEAR(&z);
# else
    MISSING(AO_test_and_set);
# endif
# if defined(AO_HAVE_fetch_and_add_read)
    TA_assert(AO_fetch_and_add_read(&x, 42) == 13);
    TA_assert(AO_fetch_and_add_read(&x, (AO_t)(-42)) == 55);
# else
    MISSING(AO_fetch_and_add);
# endif
# if defined(AO_HAVE_fetch_and_add1_read)
    TA_assert(AO_fetch_and_add1_read(&x) == 13);
# else
    MISSING(AO_fetch_and_add1);
    ++x;
# endif
# if defined(AO_HAVE_fetch_and_sub1_read)
    TA_assert(AO_fetch_and_sub1_read(&x) == 14);
# else
    MISSING(AO_fetch_and_sub1);
    --x;
# endif
# if defined(AO_HAVE_short_store_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile short *)&s = 0;
#   endif
    AO_short_store_read(&s, 13);
# else
#   if !defined(AO_HAVE_short_store) || !defined(AO_HAVE_short_store_full) \
       || !defined(AO_HAVE_short_store_release) \
       || !defined(AO_HAVE_short_store_release_write) \
       || !defined(AO_HAVE_short_store_write)
      MISSING(AO_short_store);
#   endif
    s = 13;
# endif
# if defined(AO_HAVE_short_load_read)
    TA_assert(AO_short_load(&s) == 13);
# elif !defined(AO_HAVE_short_load) || !defined(AO_HAVE_short_load_acquire) \
       || !defined(AO_HAVE_short_load_acquire_read) \
       || !defined(AO_HAVE_short_load_dd_acquire_read) \
       || !defined(AO_HAVE_short_load_full) \
       || !defined(AO_HAVE_short_load_read)
    MISSING(AO_short_load);
# endif
# if defined(AO_HAVE_short_fetch_and_add_read)
    TA_assert(AO_short_fetch_and_add_read(&s, 42) == 13);
    TA_assert(AO_short_fetch_and_add_read(&s, (unsigned short)-42) == 55);
# else
    MISSING(AO_short_fetch_and_add);
# endif
# if defined(AO_HAVE_short_fetch_and_add1_read)
    TA_assert(AO_short_fetch_and_add1_read(&s) == 13);
# else
    MISSING(AO_short_fetch_and_add1);
    ++s;
# endif
# if defined(AO_HAVE_short_fetch_and_sub1_read)
    TA_assert(AO_short_fetch_and_sub1_read(&s) == 14);
# else
    MISSING(AO_short_fetch_and_sub1);
    --s;
# endif
  TA_assert(*(volatile short *)&s == 13);
# if defined(AO_HAVE_char_store_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile char *)&b = 0;
#   endif
    AO_char_store_read(&b, 13);
# else
#   if !defined(AO_HAVE_char_store) || !defined(AO_HAVE_char_store_full) \
       || !defined(AO_HAVE_char_store_release) \
       || !defined(AO_HAVE_char_store_release_write) \
       || !defined(AO_HAVE_char_store_write)
      MISSING(AO_char_store);
#   endif
    b = 13;
# endif
# if defined(AO_HAVE_char_load_read)
    TA_assert(AO_char_load(&b) == 13);
# elif !defined(AO_HAVE_char_load) || !defined(AO_HAVE_char_load_acquire) \
       || !defined(AO_HAVE_char_load_acquire_read) \
       || !defined(AO_HAVE_char_load_dd_acquire_read) \
       || !defined(AO_HAVE_char_load_full) || !defined(AO_HAVE_char_load_read)
    MISSING(AO_char_load);
# endif
# if defined(AO_HAVE_char_fetch_and_add_read)
    TA_assert(AO_char_fetch_and_add_read(&b, 42) == 13);
    TA_assert(AO_char_fetch_and_add_read(&b, (unsigned char)-42) == 55);
# else
    MISSING(AO_char_fetch_and_add);
# endif
# if defined(AO_HAVE_char_fetch_and_add1_read)
    TA_assert(AO_char_fetch_and_add1_read(&b) == 13);
# else
    MISSING(AO_char_fetch_and_add1);
    ++b;
# endif
# if defined(AO_HAVE_char_fetch_and_sub1_read)
    TA_assert(AO_char_fetch_and_sub1_read(&b) == 14);
# else
    MISSING(AO_char_fetch_and_sub1);
    --b;
# endif
  TA_assert(*(volatile char *)&b == 13);
# if defined(AO_HAVE_int_store_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile int *)&zz = 0;
#   endif
    AO_int_store_read(&zz, 13);
# else
#   if !defined(AO_HAVE_int_store) || !defined(AO_HAVE_int_store_full) \
       || !defined(AO_HAVE_int_store_release) \
       || !defined(AO_HAVE_int_store_release_write) \
       || !defined(AO_HAVE_int_store_write)
      MISSING(AO_int_store);
#   endif
    zz = 13;
# endif
# if defined(AO_HAVE_int_load_read)
    TA_assert(AO_int_load(&zz) == 13);
# elif !defined(AO_HAVE_int_load) || !defined(AO_HAVE_int_load_acquire) \
       || !defined(AO_HAVE_int_load_acquire_read) \
       || !defined(AO_HAVE_int_load_dd_acquire_read) \
       || !defined(AO_HAVE_int_load_full) || !defined(AO_HAVE_int_load_read)
    MISSING(AO_int_load);
# endif
# if defined(AO_HAVE_int_fetch_and_add_read)
    TA_assert(AO_int_fetch_and_add_read(&zz, 42) == 13);
    TA_assert(AO_int_fetch_and_add_read(&zz, (unsigned int)-42) == 55);
# else
    MISSING(AO_int_fetch_and_add);
# endif
# if defined(AO_HAVE_int_fetch_and_add1_read)
    TA_assert(AO_int_fetch_and_add1_read(&zz) == 13);
# else
    MISSING(AO_int_fetch_and_add1);
    ++zz;
# endif
# if defined(AO_HAVE_int_fetch_and_sub1_read)
    TA_assert(AO_int_fetch_and_sub1_read(&zz) == 14);
# else
    MISSING(AO_int_fetch_and_sub1);
    --zz;
# endif
  TA_assert(*(volatile int *)&zz == 13);
# if defined(AO_HAVE_compare_and_swap_read)
    TA_assert(!AO_compare_and_swap_read(&x, 14, 42));
    TA_assert(x == 13);
    TA_assert(AO_compare_and_swap_read(&x, 13, 42));
    TA_assert(x == 42);
# else
    MISSING(AO_compare_and_swap);
    if (*(volatile AO_t *)&x == 13) x = 42;
# endif
# if defined(AO_HAVE_or_read)
    AO_or_read(&x, 66);
    TA_assert(x == 106);
# else
#   if !defined(AO_HAVE_or) || !defined(AO_HAVE_or_acquire) \
       || !defined(AO_HAVE_or_acquire_read) || !defined(AO_HAVE_or_full) \
       || !defined(AO_HAVE_or_read) || !defined(AO_HAVE_or_release) \
       || !defined(AO_HAVE_or_release_write) || !defined(AO_HAVE_or_write)
      MISSING(AO_or);
#   endif
    x |= 66;
# endif
# if defined(AO_HAVE_xor_read)
    AO_xor_read(&x, 181);
    TA_assert(x == 223);
# else
#   if !defined(AO_HAVE_xor) || !defined(AO_HAVE_xor_acquire) \
       || !defined(AO_HAVE_xor_acquire_read) || !defined(AO_HAVE_xor_full) \
       || !defined(AO_HAVE_xor_read) || !defined(AO_HAVE_xor_release) \
       || !defined(AO_HAVE_xor_release_write) || !defined(AO_HAVE_xor_write)
      MISSING(AO_xor);
#   endif
    x ^= 181;
# endif
# if defined(AO_HAVE_and_read)
    AO_and_read(&x, 57);
    TA_assert(x == 25);
# else
#   if !defined(AO_HAVE_and) || !defined(AO_HAVE_and_acquire) \
       || !defined(AO_HAVE_and_acquire_read) || !defined(AO_HAVE_and_full) \
       || !defined(AO_HAVE_and_read) || !defined(AO_HAVE_and_release) \
       || !defined(AO_HAVE_and_release_write) || !defined(AO_HAVE_and_write)
      MISSING(AO_and);
#   endif
    x &= 57;
# endif
# if defined(AO_HAVE_fetch_compare_and_swap_read)
    TA_assert(AO_fetch_compare_and_swap_read(&x, 14, 117) == 25);
    TA_assert(x == 25);
    TA_assert(AO_fetch_compare_and_swap_read(&x, 25, 117) == 25);
# else
    MISSING(AO_fetch_compare_and_swap);
    if (x == 25) x = 117;
# endif
  TA_assert(x == 117);
# if defined(AO_HAVE_short_compare_and_swap_read)
    TA_assert(!AO_short_compare_and_swap_read(&s, 14, 42));
    TA_assert(s == 13);
    TA_assert(AO_short_compare_and_swap_read(&s, 13, 42));
    TA_assert(s == 42);
# else
    MISSING(AO_short_compare_and_swap);
    if (*(volatile short *)&s == 13) s = 42;
# endif
# if defined(AO_HAVE_short_or_read)
    AO_short_or_read(&s, 66);
    TA_assert(s == 106);
# else
#   if !defined(AO_HAVE_short_or) || !defined(AO_HAVE_short_or_acquire) \
       || !defined(AO_HAVE_short_or_acquire_read) \
       || !defined(AO_HAVE_short_or_full) || !defined(AO_HAVE_short_or_read) \
       || !defined(AO_HAVE_short_or_release) \
       || !defined(AO_HAVE_short_or_release_write) \
       || !defined(AO_HAVE_short_or_write)
      MISSING(AO_short_or);
#   endif
    s |= 66;
# endif
# if defined(AO_HAVE_short_xor_read)
    AO_short_xor_read(&s, 181);
    TA_assert(s == 223);
# else
#   if !defined(AO_HAVE_short_xor) || !defined(AO_HAVE_short_xor_acquire) \
       || !defined(AO_HAVE_short_xor_acquire_read) \
       || !defined(AO_HAVE_short_xor_full) \
       || !defined(AO_HAVE_short_xor_read) \
       || !defined(AO_HAVE_short_xor_release) \
       || !defined(AO_HAVE_short_xor_release_write) \
       || !defined(AO_HAVE_short_xor_write)
      MISSING(AO_short_xor);
#   endif
    s ^= 181;
# endif
# if defined(AO_HAVE_short_and_read)
    AO_short_and_read(&s, 57);
    TA_assert(s == 25);
# else
#   if !defined(AO_HAVE_short_and) || !defined(AO_HAVE_short_and_acquire) \
       || !defined(AO_HAVE_short_and_acquire_read) \
       || !defined(AO_HAVE_short_and_full) \
       || !defined(AO_HAVE_short_and_read) \
       || !defined(AO_HAVE_short_and_release) \
       || !defined(AO_HAVE_short_and_release_write) \
       || !defined(AO_HAVE_short_and_write)
      MISSING(AO_short_and);
#   endif
    s &= 57;
# endif
# if defined(AO_HAVE_short_fetch_compare_and_swap_read)
    TA_assert(AO_short_fetch_compare_and_swap_read(&s, 14, 117) == 25);
    TA_assert(s == 25);
    TA_assert(AO_short_fetch_compare_and_swap_read(&s, 25, 117) == 25);
# else
    MISSING(AO_short_fetch_compare_and_swap);
    if (s == 25) s = 117;
# endif
  TA_assert(s == 117);
# if defined(AO_HAVE_char_compare_and_swap_read)
    TA_assert(!AO_char_compare_and_swap_read(&b, 14, 42));
    TA_assert(b == 13);
    TA_assert(AO_char_compare_and_swap_read(&b, 13, 42));
    TA_assert(b == 42);
# else
    MISSING(AO_char_compare_and_swap);
    if (*(volatile char *)&b == 13) b = 42;
# endif
# if defined(AO_HAVE_char_or_read)
    AO_char_or_read(&b, 66);
    TA_assert(b == 106);
# else
#   if !defined(AO_HAVE_char_or) || !defined(AO_HAVE_char_or_acquire) \
       || !defined(AO_HAVE_char_or_acquire_read) \
       || !defined(AO_HAVE_char_or_full) || !defined(AO_HAVE_char_or_read) \
       || !defined(AO_HAVE_char_or_release) \
       || !defined(AO_HAVE_char_or_release_write) \
       || !defined(AO_HAVE_char_or_write)
      MISSING(AO_char_or);
#   endif
    b |= 66;
# endif
# if defined(AO_HAVE_char_xor_read)
    AO_char_xor_read(&b, 181);
    TA_assert(b == 223);
# else
#   if !defined(AO_HAVE_char_xor) || !defined(AO_HAVE_char_xor_acquire) \
       || !defined(AO_HAVE_char_xor_acquire_read) \
       || !defined(AO_HAVE_char_xor_full) || !defined(AO_HAVE_char_xor_read) \
       || !defined(AO_HAVE_char_xor_release) \
       || !defined(AO_HAVE_char_xor_release_write) \
       || !defined(AO_HAVE_char_xor_write)
      MISSING(AO_char_xor);
#   endif
    b ^= 181;
# endif
# if defined(AO_HAVE_char_and_read)
    AO_char_and_read(&b, 57);
    TA_assert(b == 25);
# else
#   if !defined(AO_HAVE_char_and) || !defined(AO_HAVE_char_and_acquire) \
       || !defined(AO_HAVE_char_and_acquire_read) \
       || !defined(AO_HAVE_char_and_full) || !defined(AO_HAVE_char_and_read) \
       || !defined(AO_HAVE_char_and_release) \
       || !defined(AO_HAVE_char_and_release_write) \
       || !defined(AO_HAVE_char_and_write)
      MISSING(AO_char_and);
#   endif
    b &= 57;
# endif
# if defined(AO_HAVE_char_fetch_compare_and_swap_read)
    TA_assert(AO_char_fetch_compare_and_swap_read(&b, 14, 117) == 25);
    TA_assert(b == 25);
    TA_assert(AO_char_fetch_compare_and_swap_read(&b, 25, 117) == 25);
# else
    MISSING(AO_char_fetch_compare_and_swap);
    if (b == 25) b = 117;
# endif
  TA_assert(b == 117);
# if defined(AO_HAVE_int_compare_and_swap_read)
    TA_assert(!AO_int_compare_and_swap_read(&zz, 14, 42));
    TA_assert(zz == 13);
    TA_assert(AO_int_compare_and_swap_read(&zz, 13, 42));
    TA_assert(zz == 42);
# else
    MISSING(AO_int_compare_and_swap);
    if (*(volatile int *)&zz == 13) zz = 42;
# endif
# if defined(AO_HAVE_int_or_read)
    AO_int_or_read(&zz, 66);
    TA_assert(zz == 106);
# else
#   if !defined(AO_HAVE_int_or) || !defined(AO_HAVE_int_or_acquire) \
       || !defined(AO_HAVE_int_or_acquire_read) \
       || !defined(AO_HAVE_int_or_full) || !defined(AO_HAVE_int_or_read) \
       || !defined(AO_HAVE_int_or_release) \
       || !defined(AO_HAVE_int_or_release_write) \
       || !defined(AO_HAVE_int_or_write)
      MISSING(AO_int_or);
#   endif
    zz |= 66;
# endif
# if defined(AO_HAVE_int_xor_read)
    AO_int_xor_read(&zz, 181);
    TA_assert(zz == 223);
# else
#   if !defined(AO_HAVE_int_xor) || !defined(AO_HAVE_int_xor_acquire) \
       || !defined(AO_HAVE_int_xor_acquire_read) \
       || !defined(AO_HAVE_int_xor_full) || !defined(AO_HAVE_int_xor_read) \
       || !defined(AO_HAVE_int_xor_release) \
       || !defined(AO_HAVE_int_xor_release_write) \
       || !defined(AO_HAVE_int_xor_write)
      MISSING(AO_int_xor);
#   endif
    zz ^= 181;
# endif
# if defined(AO_HAVE_int_and_read)
    AO_int_and_read(&zz, 57);
    TA_assert(zz == 25);
# else
#   if !defined(AO_HAVE_int_and) || !defined(AO_HAVE_int_and_acquire) \
       || !defined(AO_HAVE_int_and_acquire_read) \
       || !defined(AO_HAVE_int_and_full) || !defined(AO_HAVE_int_and_read) \
       || !defined(AO_HAVE_int_and_release) \
       || !defined(AO_HAVE_int_and_release_write) \
       || !defined(AO_HAVE_int_and_write)
      MISSING(AO_int_and);
#   endif
    zz &= 57;
# endif
# if defined(AO_HAVE_int_fetch_compare_and_swap_read)
    TA_assert(AO_int_fetch_compare_and_swap_read(&zz, 14, 117) == 25);
    TA_assert(zz == 25);
    TA_assert(AO_int_fetch_compare_and_swap_read(&zz, 25, 117) == 25);
# else
    MISSING(AO_int_fetch_compare_and_swap);
    if (zz == 25) zz = 117;
# endif
  TA_assert(zz == 117);
# if defined(AO_HAVE_double_load_read) || defined(AO_HAVE_double_store_read)
    /* Initialize old_w even for store to workaround MSan warning.      */
    old_w.AO_val1 = 3316;
    old_w.AO_val2 = 2921;
# endif
# if defined(AO_HAVE_double_load_read)
    new_w = AO_double_load_read(&old_w);
    TA_assert(new_w.AO_val1 == 3316 && new_w.AO_val2 == 2921);
# elif !defined(AO_HAVE_double_load) \
       || !defined(AO_HAVE_double_load_acquire) \
       || !defined(AO_HAVE_double_load_acquire_read) \
       || !defined(AO_HAVE_double_load_dd_acquire_read) \
       || !defined(AO_HAVE_double_load_full) \
       || !defined(AO_HAVE_double_load_read)
    MISSING(AO_double_load);
# endif
# if defined(AO_HAVE_double_store_read)
    new_w.AO_val1 = 1375;
    new_w.AO_val2 = 8243;
    AO_double_store_read(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    AO_double_store_read(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    new_w.AO_val1 ^= old_w.AO_val1;
    new_w.AO_val2 ^= old_w.AO_val2;
    AO_double_store_read(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 0 && old_w.AO_val2 == 0);
# elif !defined(AO_HAVE_double_store) \
       || !defined(AO_HAVE_double_store_full) \
       || !defined(AO_HAVE_double_store_release) \
       || !defined(AO_HAVE_double_store_release_write) \
       || !defined(AO_HAVE_double_store_write)
    MISSING(AO_double_store);
# endif
# if defined(AO_HAVE_compare_double_and_swap_double_read)
    TA_assert(!AO_compare_double_and_swap_double_read(&w, 17, 42, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_double_and_swap_double_read(&w, 0, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_read(&w, 12, 14, 64, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_read(&w, 11, 13, 85, 82));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_read(&w, 13, 12, 17, 42));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_double_and_swap_double_read(&w, 12, 13, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_double_and_swap_double_read(&w, 17, 42, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_double_and_swap_double);
# endif
# if defined(AO_HAVE_compare_and_swap_double_read)
    TA_assert(!AO_compare_and_swap_double_read(&w, 17, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_and_swap_double_read(&w, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_read(&w, 13, 12, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_read(&w, 1213, 48, 86));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_and_swap_double_read(&w, 12, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_and_swap_double_read(&w, 17, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_and_swap_double);
# endif
# if defined(AO_HAVE_double_compare_and_swap_read)
    old_w.AO_val1 = 4116;
    old_w.AO_val2 = 2121;
    new_w.AO_val1 = 8537;
    new_w.AO_val2 = 6410;
    TA_assert(!AO_double_compare_and_swap_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_double_compare_and_swap_read(&w, w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = 29;
    new_w.AO_val1 = 820;
    new_w.AO_val2 = 5917;
    TA_assert(!AO_double_compare_and_swap_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = 11;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 3552;
    new_w.AO_val2 = 1746;
    TA_assert(!AO_double_compare_and_swap_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 8537;
    new_w.AO_val1 = 4116;
    new_w.AO_val2 = 2121;
    TA_assert(!AO_double_compare_and_swap_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 1;
    TA_assert(AO_double_compare_and_swap_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 1 && w.AO_val2 == 2121);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = w.AO_val2;
    new_w.AO_val1--;
    new_w.AO_val2 = 0;
    TA_assert(AO_double_compare_and_swap_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_double_compare_and_swap);
# endif
}
/*
 * Copyright (c) 2003 by Hewlett-Packard Company.  All rights reserved.
 *
 * This file is covered by the GNU general public license, version 2.
 * see COPYING for details.
 */

/* Some basic sanity tests.  These do not test the barrier semantics. */

#undef TA_assert
#define TA_assert(e) \
  if (!(e)) { fprintf(stderr, "Assertion failed %s:%d (barrier: _write)\n", \
                    __FILE__, __LINE__), exit(1); }

#undef MISSING
#define MISSING(name) \
  printf("Missing: %s\n", #name "_write")

#if defined(CPPCHECK)
  void list_atomic_write(void);
  void char_list_atomic_write(void);
  void short_list_atomic_write(void);
  void int_list_atomic_write(void);
  void double_list_atomic_write(void);
#endif

void test_atomic_write(void)
{
  AO_t x;
  unsigned char b;
  unsigned short s;
  unsigned int zz;
# if defined(AO_HAVE_test_and_set_write)
    AO_TS_t z = AO_TS_INITIALIZER;
# endif
# if defined(AO_HAVE_double_compare_and_swap_write) \
     || defined(AO_HAVE_double_load_write) \
     || defined(AO_HAVE_double_store_write)
    static AO_double_t old_w; /* static to avoid misalignment */
    AO_double_t new_w;
# endif
# if defined(AO_HAVE_compare_and_swap_double_write) \
     || defined(AO_HAVE_compare_double_and_swap_double_write) \
     || defined(AO_HAVE_double_compare_and_swap_write)
    static AO_double_t w; /* static to avoid misalignment */
    w.AO_val1 = 0;
    w.AO_val2 = 0;
# endif

# if defined(CPPCHECK)
    list_atomic_write();
    char_list_atomic_write();
    short_list_atomic_write();
    int_list_atomic_write();
    double_list_atomic_write();
# endif
# if defined(AO_HAVE_nop_write)
    AO_nop_write();
# elif !defined(AO_HAVE_nop) || !defined(AO_HAVE_nop_full) \
       || !defined(AO_HAVE_nop_read) || !defined(AO_HAVE_nop_write)
    MISSING(AO_nop);
# endif
# if defined(AO_HAVE_store_write)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile AO_t *)&x = 0; /* initialize to avoid false warning */
#   endif
    AO_store_write(&x, 13);
    TA_assert(x == 13);
# else
#   if !defined(AO_HAVE_store) || !defined(AO_HAVE_store_full) \
       || !defined(AO_HAVE_store_release) \
       || !defined(AO_HAVE_store_release_write) \
       || !defined(AO_HAVE_store_write)
      MISSING(AO_store);
#   endif
    x = 13;
# endif
# if defined(AO_HAVE_load_write)
    TA_assert(AO_load_write(&x) == 13);
# elif !defined(AO_HAVE_load) || !defined(AO_HAVE_load_acquire) \
       || !defined(AO_HAVE_load_acquire_read) \
       || !defined(AO_HAVE_load_dd_acquire_read) \
       || !defined(AO_HAVE_load_full) || !defined(AO_HAVE_load_read)
    MISSING(AO_load);
# endif
# if defined(AO_HAVE_test_and_set_write)
    TA_assert(AO_test_and_set_write(&z) == AO_TS_CLEAR);
    TA_assert(AO_test_and_set_write(&z) == AO_TS_SET);
    TA_assert(AO_test_and_set_write(&z) == AO_TS_SET);
    AO_CLEAR(&z);
# else
    MISSING(AO_test_and_set);
# endif
# if defined(AO_HAVE_fetch_and_add_write)
    TA_assert(AO_fetch_and_add_write(&x, 42) == 13);
    TA_assert(AO_fetch_and_add_write(&x, (AO_t)(-42)) == 55);
# else
    MISSING(AO_fetch_and_add);
# endif
# if defined(AO_HAVE_fetch_and_add1_write)
    TA_assert(AO_fetch_and_add1_write(&x) == 13);
# else
    MISSING(AO_fetch_and_add1);
    ++x;
# endif
# if defined(AO_HAVE_fetch_and_sub1_write)
    TA_assert(AO_fetch_and_sub1_write(&x) == 14);
# else
    MISSING(AO_fetch_and_sub1);
    --x;
# endif
# if defined(AO_HAVE_short_store_write)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile short *)&s = 0;
#   endif
    AO_short_store_write(&s, 13);
# else
#   if !defined(AO_HAVE_short_store) || !defined(AO_HAVE_short_store_full) \
       || !defined(AO_HAVE_short_store_release) \
       || !defined(AO_HAVE_short_store_release_write) \
       || !defined(AO_HAVE_short_store_write)
      MISSING(AO_short_store);
#   endif
    s = 13;
# endif
# if defined(AO_HAVE_short_load_write)
    TA_assert(AO_short_load(&s) == 13);
# elif !defined(AO_HAVE_short_load) || !defined(AO_HAVE_short_load_acquire) \
       || !defined(AO_HAVE_short_load_acquire_read) \
       || !defined(AO_HAVE_short_load_dd_acquire_read) \
       || !defined(AO_HAVE_short_load_full) \
       || !defined(AO_HAVE_short_load_read)
    MISSING(AO_short_load);
# endif
# if defined(AO_HAVE_short_fetch_and_add_write)
    TA_assert(AO_short_fetch_and_add_write(&s, 42) == 13);
    TA_assert(AO_short_fetch_and_add_write(&s, (unsigned short)-42) == 55);
# else
    MISSING(AO_short_fetch_and_add);
# endif
# if defined(AO_HAVE_short_fetch_and_add1_write)
    TA_assert(AO_short_fetch_and_add1_write(&s) == 13);
# else
    MISSING(AO_short_fetch_and_add1);
    ++s;
# endif
# if defined(AO_HAVE_short_fetch_and_sub1_write)
    TA_assert(AO_short_fetch_and_sub1_write(&s) == 14);
# else
    MISSING(AO_short_fetch_and_sub1);
    --s;
# endif
  TA_assert(*(volatile short *)&s == 13);
# if defined(AO_HAVE_char_store_write)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile char *)&b = 0;
#   endif
    AO_char_store_write(&b, 13);
# else
#   if !defined(AO_HAVE_char_store) || !defined(AO_HAVE_char_store_full) \
       || !defined(AO_HAVE_char_store_release) \
       || !defined(AO_HAVE_char_store_release_write) \
       || !defined(AO_HAVE_char_store_write)
      MISSING(AO_char_store);
#   endif
    b = 13;
# endif
# if defined(AO_HAVE_char_load_write)
    TA_assert(AO_char_load(&b) == 13);
# elif !defined(AO_HAVE_char_load) || !defined(AO_HAVE_char_load_acquire) \
       || !defined(AO_HAVE_char_load_acquire_read) \
       || !defined(AO_HAVE_char_load_dd_acquire_read) \
       || !defined(AO_HAVE_char_load_full) || !defined(AO_HAVE_char_load_read)
    MISSING(AO_char_load);
# endif
# if defined(AO_HAVE_char_fetch_and_add_write)
    TA_assert(AO_char_fetch_and_add_write(&b, 42) == 13);
    TA_assert(AO_char_fetch_and_add_write(&b, (unsigned char)-42) == 55);
# else
    MISSING(AO_char_fetch_and_add);
# endif
# if defined(AO_HAVE_char_fetch_and_add1_write)
    TA_assert(AO_char_fetch_and_add1_write(&b) == 13);
# else
    MISSING(AO_char_fetch_and_add1);
    ++b;
# endif
# if defined(AO_HAVE_char_fetch_and_sub1_write)
    TA_assert(AO_char_fetch_and_sub1_write(&b) == 14);
# else
    MISSING(AO_char_fetch_and_sub1);
    --b;
# endif
  TA_assert(*(volatile char *)&b == 13);
# if defined(AO_HAVE_int_store_write)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile int *)&zz = 0;
#   endif
    AO_int_store_write(&zz, 13);
# else
#   if !defined(AO_HAVE_int_store) || !defined(AO_HAVE_int_store_full) \
       || !defined(AO_HAVE_int_store_release) \
       || !defined(AO_HAVE_int_store_release_write) \
       || !defined(AO_HAVE_int_store_write)
      MISSING(AO_int_store);
#   endif
    zz = 13;
# endif
# if defined(AO_HAVE_int_load_write)
    TA_assert(AO_int_load(&zz) == 13);
# elif !defined(AO_HAVE_int_load) || !defined(AO_HAVE_int_load_acquire) \
       || !defined(AO_HAVE_int_load_acquire_read) \
       || !defined(AO_HAVE_int_load_dd_acquire_read) \
       || !defined(AO_HAVE_int_load_full) || !defined(AO_HAVE_int_load_read)
    MISSING(AO_int_load);
# endif
# if defined(AO_HAVE_int_fetch_and_add_write)
    TA_assert(AO_int_fetch_and_add_write(&zz, 42) == 13);
    TA_assert(AO_int_fetch_and_add_write(&zz, (unsigned int)-42) == 55);
# else
    MISSING(AO_int_fetch_and_add);
# endif
# if defined(AO_HAVE_int_fetch_and_add1_write)
    TA_assert(AO_int_fetch_and_add1_write(&zz) == 13);
# else
    MISSING(AO_int_fetch_and_add1);
    ++zz;
# endif
# if defined(AO_HAVE_int_fetch_and_sub1_write)
    TA_assert(AO_int_fetch_and_sub1_write(&zz) == 14);
# else
    MISSING(AO_int_fetch_and_sub1);
    --zz;
# endif
  TA_assert(*(volatile int *)&zz == 13);
# if defined(AO_HAVE_compare_and_swap_write)
    TA_assert(!AO_compare_and_swap_write(&x, 14, 42));
    TA_assert(x == 13);
    TA_assert(AO_compare_and_swap_write(&x, 13, 42));
    TA_assert(x == 42);
# else
    MISSING(AO_compare_and_swap);
    if (*(volatile AO_t *)&x == 13) x = 42;
# endif
# if defined(AO_HAVE_or_write)
    AO_or_write(&x, 66);
    TA_assert(x == 106);
# else
#   if !defined(AO_HAVE_or) || !defined(AO_HAVE_or_acquire) \
       || !defined(AO_HAVE_or_acquire_read) || !defined(AO_HAVE_or_full) \
       || !defined(AO_HAVE_or_read) || !defined(AO_HAVE_or_release) \
       || !defined(AO_HAVE_or_release_write) || !defined(AO_HAVE_or_write)
      MISSING(AO_or);
#   endif
    x |= 66;
# endif
# if defined(AO_HAVE_xor_write)
    AO_xor_write(&x, 181);
    TA_assert(x == 223);
# else
#   if !defined(AO_HAVE_xor) || !defined(AO_HAVE_xor_acquire) \
       || !defined(AO_HAVE_xor_acquire_read) || !defined(AO_HAVE_xor_full) \
       || !defined(AO_HAVE_xor_read) || !defined(AO_HAVE_xor_release) \
       || !defined(AO_HAVE_xor_release_write) || !defined(AO_HAVE_xor_write)
      MISSING(AO_xor);
#   endif
    x ^= 181;
# endif
# if defined(AO_HAVE_and_write)
    AO_and_write(&x, 57);
    TA_assert(x == 25);
# else
#   if !defined(AO_HAVE_and) || !defined(AO_HAVE_and_acquire) \
       || !defined(AO_HAVE_and_acquire_read) || !defined(AO_HAVE_and_full) \
       || !defined(AO_HAVE_and_read) || !defined(AO_HAVE_and_release) \
       || !defined(AO_HAVE_and_release_write) || !defined(AO_HAVE_and_write)
      MISSING(AO_and);
#   endif
    x &= 57;
# endif
# if defined(AO_HAVE_fetch_compare_and_swap_write)
    TA_assert(AO_fetch_compare_and_swap_write(&x, 14, 117) == 25);
    TA_assert(x == 25);
    TA_assert(AO_fetch_compare_and_swap_write(&x, 25, 117) == 25);
# else
    MISSING(AO_fetch_compare_and_swap);
    if (x == 25) x = 117;
# endif
  TA_assert(x == 117);
# if defined(AO_HAVE_short_compare_and_swap_write)
    TA_assert(!AO_short_compare_and_swap_write(&s, 14, 42));
    TA_assert(s == 13);
    TA_assert(AO_short_compare_and_swap_write(&s, 13, 42));
    TA_assert(s == 42);
# else
    MISSING(AO_short_compare_and_swap);
    if (*(volatile short *)&s == 13) s = 42;
# endif
# if defined(AO_HAVE_short_or_write)
    AO_short_or_write(&s, 66);
    TA_assert(s == 106);
# else
#   if !defined(AO_HAVE_short_or) || !defined(AO_HAVE_short_or_acquire) \
       || !defined(AO_HAVE_short_or_acquire_read) \
       || !defined(AO_HAVE_short_or_full) || !defined(AO_HAVE_short_or_read) \
       || !defined(AO_HAVE_short_or_release) \
       || !defined(AO_HAVE_short_or_release_write) \
       || !defined(AO_HAVE_short_or_write)
      MISSING(AO_short_or);
#   endif
    s |= 66;
# endif
# if defined(AO_HAVE_short_xor_write)
    AO_short_xor_write(&s, 181);
    TA_assert(s == 223);
# else
#   if !defined(AO_HAVE_short_xor) || !defined(AO_HAVE_short_xor_acquire) \
       || !defined(AO_HAVE_short_xor_acquire_read) \
       || !defined(AO_HAVE_short_xor_full) \
       || !defined(AO_HAVE_short_xor_read) \
       || !defined(AO_HAVE_short_xor_release) \
       || !defined(AO_HAVE_short_xor_release_write) \
       || !defined(AO_HAVE_short_xor_write)
      MISSING(AO_short_xor);
#   endif
    s ^= 181;
# endif
# if defined(AO_HAVE_short_and_write)
    AO_short_and_write(&s, 57);
    TA_assert(s == 25);
# else
#   if !defined(AO_HAVE_short_and) || !defined(AO_HAVE_short_and_acquire) \
       || !defined(AO_HAVE_short_and_acquire_read) \
       || !defined(AO_HAVE_short_and_full) \
       || !defined(AO_HAVE_short_and_read) \
       || !defined(AO_HAVE_short_and_release) \
       || !defined(AO_HAVE_short_and_release_write) \
       || !defined(AO_HAVE_short_and_write)
      MISSING(AO_short_and);
#   endif
    s &= 57;
# endif
# if defined(AO_HAVE_short_fetch_compare_and_swap_write)
    TA_assert(AO_short_fetch_compare_and_swap_write(&s, 14, 117) == 25);
    TA_assert(s == 25);
    TA_assert(AO_short_fetch_compare_and_swap_write(&s, 25, 117) == 25);
# else
    MISSING(AO_short_fetch_compare_and_swap);
    if (s == 25) s = 117;
# endif
  TA_assert(s == 117);
# if defined(AO_HAVE_char_compare_and_swap_write)
    TA_assert(!AO_char_compare_and_swap_write(&b, 14, 42));
    TA_assert(b == 13);
    TA_assert(AO_char_compare_and_swap_write(&b, 13, 42));
    TA_assert(b == 42);
# else
    MISSING(AO_char_compare_and_swap);
    if (*(volatile char *)&b == 13) b = 42;
# endif
# if defined(AO_HAVE_char_or_write)
    AO_char_or_write(&b, 66);
    TA_assert(b == 106);
# else
#   if !defined(AO_HAVE_char_or) || !defined(AO_HAVE_char_or_acquire) \
       || !defined(AO_HAVE_char_or_acquire_read) \
       || !defined(AO_HAVE_char_or_full) || !defined(AO_HAVE_char_or_read) \
       || !defined(AO_HAVE_char_or_release) \
       || !defined(AO_HAVE_char_or_release_write) \
       || !defined(AO_HAVE_char_or_write)
      MISSING(AO_char_or);
#   endif
    b |= 66;
# endif
# if defined(AO_HAVE_char_xor_write)
    AO_char_xor_write(&b, 181);
    TA_assert(b == 223);
# else
#   if !defined(AO_HAVE_char_xor) || !defined(AO_HAVE_char_xor_acquire) \
       || !defined(AO_HAVE_char_xor_acquire_read) \
       || !defined(AO_HAVE_char_xor_full) || !defined(AO_HAVE_char_xor_read) \
       || !defined(AO_HAVE_char_xor_release) \
       || !defined(AO_HAVE_char_xor_release_write) \
       || !defined(AO_HAVE_char_xor_write)
      MISSING(AO_char_xor);
#   endif
    b ^= 181;
# endif
# if defined(AO_HAVE_char_and_write)
    AO_char_and_write(&b, 57);
    TA_assert(b == 25);
# else
#   if !defined(AO_HAVE_char_and) || !defined(AO_HAVE_char_and_acquire) \
       || !defined(AO_HAVE_char_and_acquire_read) \
       || !defined(AO_HAVE_char_and_full) || !defined(AO_HAVE_char_and_read) \
       || !defined(AO_HAVE_char_and_release) \
       || !defined(AO_HAVE_char_and_release_write) \
       || !defined(AO_HAVE_char_and_write)
      MISSING(AO_char_and);
#   endif
    b &= 57;
# endif
# if defined(AO_HAVE_char_fetch_compare_and_swap_write)
    TA_assert(AO_char_fetch_compare_and_swap_write(&b, 14, 117) == 25);
    TA_assert(b == 25);
    TA_assert(AO_char_fetch_compare_and_swap_write(&b, 25, 117) == 25);
# else
    MISSING(AO_char_fetch_compare_and_swap);
    if (b == 25) b = 117;
# endif
  TA_assert(b == 117);
# if defined(AO_HAVE_int_compare_and_swap_write)
    TA_assert(!AO_int_compare_and_swap_write(&zz, 14, 42));
    TA_assert(zz == 13);
    TA_assert(AO_int_compare_and_swap_write(&zz, 13, 42));
    TA_assert(zz == 42);
# else
    MISSING(AO_int_compare_and_swap);
    if (*(volatile int *)&zz == 13) zz = 42;
# endif
# if defined(AO_HAVE_int_or_write)
    AO_int_or_write(&zz, 66);
    TA_assert(zz == 106);
# else
#   if !defined(AO_HAVE_int_or) || !defined(AO_HAVE_int_or_acquire) \
       || !defined(AO_HAVE_int_or_acquire_read) \
       || !defined(AO_HAVE_int_or_full) || !defined(AO_HAVE_int_or_read) \
       || !defined(AO_HAVE_int_or_release) \
       || !defined(AO_HAVE_int_or_release_write) \
       || !defined(AO_HAVE_int_or_write)
      MISSING(AO_int_or);
#   endif
    zz |= 66;
# endif
# if defined(AO_HAVE_int_xor_write)
    AO_int_xor_write(&zz, 181);
    TA_assert(zz == 223);
# else
#   if !defined(AO_HAVE_int_xor) || !defined(AO_HAVE_int_xor_acquire) \
       || !defined(AO_HAVE_int_xor_acquire_read) \
       || !defined(AO_HAVE_int_xor_full) || !defined(AO_HAVE_int_xor_read) \
       || !defined(AO_HAVE_int_xor_release) \
       || !defined(AO_HAVE_int_xor_release_write) \
       || !defined(AO_HAVE_int_xor_write)
      MISSING(AO_int_xor);
#   endif
    zz ^= 181;
# endif
# if defined(AO_HAVE_int_and_write)
    AO_int_and_write(&zz, 57);
    TA_assert(zz == 25);
# else
#   if !defined(AO_HAVE_int_and) || !defined(AO_HAVE_int_and_acquire) \
       || !defined(AO_HAVE_int_and_acquire_read) \
       || !defined(AO_HAVE_int_and_full) || !defined(AO_HAVE_int_and_read) \
       || !defined(AO_HAVE_int_and_release) \
       || !defined(AO_HAVE_int_and_release_write) \
       || !defined(AO_HAVE_int_and_write)
      MISSING(AO_int_and);
#   endif
    zz &= 57;
# endif
# if defined(AO_HAVE_int_fetch_compare_and_swap_write)
    TA_assert(AO_int_fetch_compare_and_swap_write(&zz, 14, 117) == 25);
    TA_assert(zz == 25);
    TA_assert(AO_int_fetch_compare_and_swap_write(&zz, 25, 117) == 25);
# else
    MISSING(AO_int_fetch_compare_and_swap);
    if (zz == 25) zz = 117;
# endif
  TA_assert(zz == 117);
# if defined(AO_HAVE_double_load_write) || defined(AO_HAVE_double_store_write)
    /* Initialize old_w even for store to workaround MSan warning.      */
    old_w.AO_val1 = 3316;
    old_w.AO_val2 = 2921;
# endif
# if defined(AO_HAVE_double_load_write)
    new_w = AO_double_load_write(&old_w);
    TA_assert(new_w.AO_val1 == 3316 && new_w.AO_val2 == 2921);
# elif !defined(AO_HAVE_double_load) \
       || !defined(AO_HAVE_double_load_acquire) \
       || !defined(AO_HAVE_double_load_acquire_read) \
       || !defined(AO_HAVE_double_load_dd_acquire_read) \
       || !defined(AO_HAVE_double_load_full) \
       || !defined(AO_HAVE_double_load_read)
    MISSING(AO_double_load);
# endif
# if defined(AO_HAVE_double_store_write)
    new_w.AO_val1 = 1375;
    new_w.AO_val2 = 8243;
    AO_double_store_write(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    AO_double_store_write(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    new_w.AO_val1 ^= old_w.AO_val1;
    new_w.AO_val2 ^= old_w.AO_val2;
    AO_double_store_write(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 0 && old_w.AO_val2 == 0);
# elif !defined(AO_HAVE_double_store) \
       || !defined(AO_HAVE_double_store_full) \
       || !defined(AO_HAVE_double_store_release) \
       || !defined(AO_HAVE_double_store_release_write) \
       || !defined(AO_HAVE_double_store_write)
    MISSING(AO_double_store);
# endif
# if defined(AO_HAVE_compare_double_and_swap_double_write)
    TA_assert(!AO_compare_double_and_swap_double_write(&w, 17, 42, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_double_and_swap_double_write(&w, 0, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_write(&w, 12, 14, 64, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_write(&w, 11, 13, 85, 82));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_write(&w, 13, 12, 17, 42));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_double_and_swap_double_write(&w, 12, 13, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_double_and_swap_double_write(&w, 17, 42, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_double_and_swap_double);
# endif
# if defined(AO_HAVE_compare_and_swap_double_write)
    TA_assert(!AO_compare_and_swap_double_write(&w, 17, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_and_swap_double_write(&w, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_write(&w, 13, 12, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_write(&w, 1213, 48, 86));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_and_swap_double_write(&w, 12, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_and_swap_double_write(&w, 17, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_and_swap_double);
# endif
# if defined(AO_HAVE_double_compare_and_swap_write)
    old_w.AO_val1 = 4116;
    old_w.AO_val2 = 2121;
    new_w.AO_val1 = 8537;
    new_w.AO_val2 = 6410;
    TA_assert(!AO_double_compare_and_swap_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_double_compare_and_swap_write(&w, w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = 29;
    new_w.AO_val1 = 820;
    new_w.AO_val2 = 5917;
    TA_assert(!AO_double_compare_and_swap_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = 11;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 3552;
    new_w.AO_val2 = 1746;
    TA_assert(!AO_double_compare_and_swap_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 8537;
    new_w.AO_val1 = 4116;
    new_w.AO_val2 = 2121;
    TA_assert(!AO_double_compare_and_swap_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 1;
    TA_assert(AO_double_compare_and_swap_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 1 && w.AO_val2 == 2121);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = w.AO_val2;
    new_w.AO_val1--;
    new_w.AO_val2 = 0;
    TA_assert(AO_double_compare_and_swap_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_double_compare_and_swap);
# endif
}
/*
 * Copyright (c) 2003 by Hewlett-Packard Company.  All rights reserved.
 *
 * This file is covered by the GNU general public license, version 2.
 * see COPYING for details.
 */

/* Some basic sanity tests.  These do not test the barrier semantics. */

#undef TA_assert
#define TA_assert(e) \
  if (!(e)) { fprintf(stderr, "Assertion failed %s:%d (barrier: _full)\n", \
                    __FILE__, __LINE__), exit(1); }

#undef MISSING
#define MISSING(name) \
  printf("Missing: %s\n", #name "_full")

#if defined(CPPCHECK)
  void list_atomic_full(void);
  void char_list_atomic_full(void);
  void short_list_atomic_full(void);
  void int_list_atomic_full(void);
  void double_list_atomic_full(void);
#endif

void test_atomic_full(void)
{
  AO_t x;
  unsigned char b;
  unsigned short s;
  unsigned int zz;
# if defined(AO_HAVE_test_and_set_full)
    AO_TS_t z = AO_TS_INITIALIZER;
# endif
# if defined(AO_HAVE_double_compare_and_swap_full) \
     || defined(AO_HAVE_double_load_full) \
     || defined(AO_HAVE_double_store_full)
    static AO_double_t old_w; /* static to avoid misalignment */
    AO_double_t new_w;
# endif
# if defined(AO_HAVE_compare_and_swap_double_full) \
     || defined(AO_HAVE_compare_double_and_swap_double_full) \
     || defined(AO_HAVE_double_compare_and_swap_full)
    static AO_double_t w; /* static to avoid misalignment */
    w.AO_val1 = 0;
    w.AO_val2 = 0;
# endif

# if defined(CPPCHECK)
    list_atomic_full();
    char_list_atomic_full();
    short_list_atomic_full();
    int_list_atomic_full();
    double_list_atomic_full();
# endif
# if defined(AO_HAVE_nop_full)
    AO_nop_full();
# elif !defined(AO_HAVE_nop) || !defined(AO_HAVE_nop_full) \
       || !defined(AO_HAVE_nop_read) || !defined(AO_HAVE_nop_write)
    MISSING(AO_nop);
# endif
# if defined(AO_HAVE_store_full)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile AO_t *)&x = 0; /* initialize to avoid false warning */
#   endif
    AO_store_full(&x, 13);
    TA_assert(x == 13);
# else
#   if !defined(AO_HAVE_store) || !defined(AO_HAVE_store_full) \
       || !defined(AO_HAVE_store_release) \
       || !defined(AO_HAVE_store_release_write) \
       || !defined(AO_HAVE_store_write)
      MISSING(AO_store);
#   endif
    x = 13;
# endif
# if defined(AO_HAVE_load_full)
    TA_assert(AO_load_full(&x) == 13);
# elif !defined(AO_HAVE_load) || !defined(AO_HAVE_load_acquire) \
       || !defined(AO_HAVE_load_acquire_read) \
       || !defined(AO_HAVE_load_dd_acquire_read) \
       || !defined(AO_HAVE_load_full) || !defined(AO_HAVE_load_read)
    MISSING(AO_load);
# endif
# if defined(AO_HAVE_test_and_set_full)
    TA_assert(AO_test_and_set_full(&z) == AO_TS_CLEAR);
    TA_assert(AO_test_and_set_full(&z) == AO_TS_SET);
    TA_assert(AO_test_and_set_full(&z) == AO_TS_SET);
    AO_CLEAR(&z);
# else
    MISSING(AO_test_and_set);
# endif
# if defined(AO_HAVE_fetch_and_add_full)
    TA_assert(AO_fetch_and_add_full(&x, 42) == 13);
    TA_assert(AO_fetch_and_add_full(&x, (AO_t)(-42)) == 55);
# else
    MISSING(AO_fetch_and_add);
# endif
# if defined(AO_HAVE_fetch_and_add1_full)
    TA_assert(AO_fetch_and_add1_full(&x) == 13);
# else
    MISSING(AO_fetch_and_add1);
    ++x;
# endif
# if defined(AO_HAVE_fetch_and_sub1_full)
    TA_assert(AO_fetch_and_sub1_full(&x) == 14);
# else
    MISSING(AO_fetch_and_sub1);
    --x;
# endif
# if defined(AO_HAVE_short_store_full)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile short *)&s = 0;
#   endif
    AO_short_store_full(&s, 13);
# else
#   if !defined(AO_HAVE_short_store) || !defined(AO_HAVE_short_store_full) \
       || !defined(AO_HAVE_short_store_release) \
       || !defined(AO_HAVE_short_store_release_write) \
       || !defined(AO_HAVE_short_store_write)
      MISSING(AO_short_store);
#   endif
    s = 13;
# endif
# if defined(AO_HAVE_short_load_full)
    TA_assert(AO_short_load(&s) == 13);
# elif !defined(AO_HAVE_short_load) || !defined(AO_HAVE_short_load_acquire) \
       || !defined(AO_HAVE_short_load_acquire_read) \
       || !defined(AO_HAVE_short_load_dd_acquire_read) \
       || !defined(AO_HAVE_short_load_full) \
       || !defined(AO_HAVE_short_load_read)
    MISSING(AO_short_load);
# endif
# if defined(AO_HAVE_short_fetch_and_add_full)
    TA_assert(AO_short_fetch_and_add_full(&s, 42) == 13);
    TA_assert(AO_short_fetch_and_add_full(&s, (unsigned short)-42) == 55);
# else
    MISSING(AO_short_fetch_and_add);
# endif
# if defined(AO_HAVE_short_fetch_and_add1_full)
    TA_assert(AO_short_fetch_and_add1_full(&s) == 13);
# else
    MISSING(AO_short_fetch_and_add1);
    ++s;
# endif
# if defined(AO_HAVE_short_fetch_and_sub1_full)
    TA_assert(AO_short_fetch_and_sub1_full(&s) == 14);
# else
    MISSING(AO_short_fetch_and_sub1);
    --s;
# endif
  TA_assert(*(volatile short *)&s == 13);
# if defined(AO_HAVE_char_store_full)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile char *)&b = 0;
#   endif
    AO_char_store_full(&b, 13);
# else
#   if !defined(AO_HAVE_char_store) || !defined(AO_HAVE_char_store_full) \
       || !defined(AO_HAVE_char_store_release) \
       || !defined(AO_HAVE_char_store_release_write) \
       || !defined(AO_HAVE_char_store_write)
      MISSING(AO_char_store);
#   endif
    b = 13;
# endif
# if defined(AO_HAVE_char_load_full)
    TA_assert(AO_char_load(&b) == 13);
# elif !defined(AO_HAVE_char_load) || !defined(AO_HAVE_char_load_acquire) \
       || !defined(AO_HAVE_char_load_acquire_read) \
       || !defined(AO_HAVE_char_load_dd_acquire_read) \
       || !defined(AO_HAVE_char_load_full) || !defined(AO_HAVE_char_load_read)
    MISSING(AO_char_load);
# endif
# if defined(AO_HAVE_char_fetch_and_add_full)
    TA_assert(AO_char_fetch_and_add_full(&b, 42) == 13);
    TA_assert(AO_char_fetch_and_add_full(&b, (unsigned char)-42) == 55);
# else
    MISSING(AO_char_fetch_and_add);
# endif
# if defined(AO_HAVE_char_fetch_and_add1_full)
    TA_assert(AO_char_fetch_and_add1_full(&b) == 13);
# else
    MISSING(AO_char_fetch_and_add1);
    ++b;
# endif
# if defined(AO_HAVE_char_fetch_and_sub1_full)
    TA_assert(AO_char_fetch_and_sub1_full(&b) == 14);
# else
    MISSING(AO_char_fetch_and_sub1);
    --b;
# endif
  TA_assert(*(volatile char *)&b == 13);
# if defined(AO_HAVE_int_store_full)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile int *)&zz = 0;
#   endif
    AO_int_store_full(&zz, 13);
# else
#   if !defined(AO_HAVE_int_store) || !defined(AO_HAVE_int_store_full) \
       || !defined(AO_HAVE_int_store_release) \
       || !defined(AO_HAVE_int_store_release_write) \
       || !defined(AO_HAVE_int_store_write)
      MISSING(AO_int_store);
#   endif
    zz = 13;
# endif
# if defined(AO_HAVE_int_load_full)
    TA_assert(AO_int_load(&zz) == 13);
# elif !defined(AO_HAVE_int_load) || !defined(AO_HAVE_int_load_acquire) \
       || !defined(AO_HAVE_int_load_acquire_read) \
       || !defined(AO_HAVE_int_load_dd_acquire_read) \
       || !defined(AO_HAVE_int_load_full) || !defined(AO_HAVE_int_load_read)
    MISSING(AO_int_load);
# endif
# if defined(AO_HAVE_int_fetch_and_add_full)
    TA_assert(AO_int_fetch_and_add_full(&zz, 42) == 13);
    TA_assert(AO_int_fetch_and_add_full(&zz, (unsigned int)-42) == 55);
# else
    MISSING(AO_int_fetch_and_add);
# endif
# if defined(AO_HAVE_int_fetch_and_add1_full)
    TA_assert(AO_int_fetch_and_add1_full(&zz) == 13);
# else
    MISSING(AO_int_fetch_and_add1);
    ++zz;
# endif
# if defined(AO_HAVE_int_fetch_and_sub1_full)
    TA_assert(AO_int_fetch_and_sub1_full(&zz) == 14);
# else
    MISSING(AO_int_fetch_and_sub1);
    --zz;
# endif
  TA_assert(*(volatile int *)&zz == 13);
# if defined(AO_HAVE_compare_and_swap_full)
    TA_assert(!AO_compare_and_swap_full(&x, 14, 42));
    TA_assert(x == 13);
    TA_assert(AO_compare_and_swap_full(&x, 13, 42));
    TA_assert(x == 42);
# else
    MISSING(AO_compare_and_swap);
    if (*(volatile AO_t *)&x == 13) x = 42;
# endif
# if defined(AO_HAVE_or_full)
    AO_or_full(&x, 66);
    TA_assert(x == 106);
# else
#   if !defined(AO_HAVE_or) || !defined(AO_HAVE_or_acquire) \
       || !defined(AO_HAVE_or_acquire_read) || !defined(AO_HAVE_or_full) \
       || !defined(AO_HAVE_or_read) || !defined(AO_HAVE_or_release) \
       || !defined(AO_HAVE_or_release_write) || !defined(AO_HAVE_or_write)
      MISSING(AO_or);
#   endif
    x |= 66;
# endif
# if defined(AO_HAVE_xor_full)
    AO_xor_full(&x, 181);
    TA_assert(x == 223);
# else
#   if !defined(AO_HAVE_xor) || !defined(AO_HAVE_xor_acquire) \
       || !defined(AO_HAVE_xor_acquire_read) || !defined(AO_HAVE_xor_full) \
       || !defined(AO_HAVE_xor_read) || !defined(AO_HAVE_xor_release) \
       || !defined(AO_HAVE_xor_release_write) || !defined(AO_HAVE_xor_write)
      MISSING(AO_xor);
#   endif
    x ^= 181;
# endif
# if defined(AO_HAVE_and_full)
    AO_and_full(&x, 57);
    TA_assert(x == 25);
# else
#   if !defined(AO_HAVE_and) || !defined(AO_HAVE_and_acquire) \
       || !defined(AO_HAVE_and_acquire_read) || !defined(AO_HAVE_and_full) \
       || !defined(AO_HAVE_and_read) || !defined(AO_HAVE_and_release) \
       || !defined(AO_HAVE_and_release_write) || !defined(AO_HAVE_and_write)
      MISSING(AO_and);
#   endif
    x &= 57;
# endif
# if defined(AO_HAVE_fetch_compare_and_swap_full)
    TA_assert(AO_fetch_compare_and_swap_full(&x, 14, 117) == 25);
    TA_assert(x == 25);
    TA_assert(AO_fetch_compare_and_swap_full(&x, 25, 117) == 25);
# else
    MISSING(AO_fetch_compare_and_swap);
    if (x == 25) x = 117;
# endif
  TA_assert(x == 117);
# if defined(AO_HAVE_short_compare_and_swap_full)
    TA_assert(!AO_short_compare_and_swap_full(&s, 14, 42));
    TA_assert(s == 13);
    TA_assert(AO_short_compare_and_swap_full(&s, 13, 42));
    TA_assert(s == 42);
# else
    MISSING(AO_short_compare_and_swap);
    if (*(volatile short *)&s == 13) s = 42;
# endif
# if defined(AO_HAVE_short_or_full)
    AO_short_or_full(&s, 66);
    TA_assert(s == 106);
# else
#   if !defined(AO_HAVE_short_or) || !defined(AO_HAVE_short_or_acquire) \
       || !defined(AO_HAVE_short_or_acquire_read) \
       || !defined(AO_HAVE_short_or_full) || !defined(AO_HAVE_short_or_read) \
       || !defined(AO_HAVE_short_or_release) \
       || !defined(AO_HAVE_short_or_release_write) \
       || !defined(AO_HAVE_short_or_write)
      MISSING(AO_short_or);
#   endif
    s |= 66;
# endif
# if defined(AO_HAVE_short_xor_full)
    AO_short_xor_full(&s, 181);
    TA_assert(s == 223);
# else
#   if !defined(AO_HAVE_short_xor) || !defined(AO_HAVE_short_xor_acquire) \
       || !defined(AO_HAVE_short_xor_acquire_read) \
       || !defined(AO_HAVE_short_xor_full) \
       || !defined(AO_HAVE_short_xor_read) \
       || !defined(AO_HAVE_short_xor_release) \
       || !defined(AO_HAVE_short_xor_release_write) \
       || !defined(AO_HAVE_short_xor_write)
      MISSING(AO_short_xor);
#   endif
    s ^= 181;
# endif
# if defined(AO_HAVE_short_and_full)
    AO_short_and_full(&s, 57);
    TA_assert(s == 25);
# else
#   if !defined(AO_HAVE_short_and) || !defined(AO_HAVE_short_and_acquire) \
       || !defined(AO_HAVE_short_and_acquire_read) \
       || !defined(AO_HAVE_short_and_full) \
       || !defined(AO_HAVE_short_and_read) \
       || !defined(AO_HAVE_short_and_release) \
       || !defined(AO_HAVE_short_and_release_write) \
       || !defined(AO_HAVE_short_and_write)
      MISSING(AO_short_and);
#   endif
    s &= 57;
# endif
# if defined(AO_HAVE_short_fetch_compare_and_swap_full)
    TA_assert(AO_short_fetch_compare_and_swap_full(&s, 14, 117) == 25);
    TA_assert(s == 25);
    TA_assert(AO_short_fetch_compare_and_swap_full(&s, 25, 117) == 25);
# else
    MISSING(AO_short_fetch_compare_and_swap);
    if (s == 25) s = 117;
# endif
  TA_assert(s == 117);
# if defined(AO_HAVE_char_compare_and_swap_full)
    TA_assert(!AO_char_compare_and_swap_full(&b, 14, 42));
    TA_assert(b == 13);
    TA_assert(AO_char_compare_and_swap_full(&b, 13, 42));
    TA_assert(b == 42);
# else
    MISSING(AO_char_compare_and_swap);
    if (*(volatile char *)&b == 13) b = 42;
# endif
# if defined(AO_HAVE_char_or_full)
    AO_char_or_full(&b, 66);
    TA_assert(b == 106);
# else
#   if !defined(AO_HAVE_char_or) || !defined(AO_HAVE_char_or_acquire) \
       || !defined(AO_HAVE_char_or_acquire_read) \
       || !defined(AO_HAVE_char_or_full) || !defined(AO_HAVE_char_or_read) \
       || !defined(AO_HAVE_char_or_release) \
       || !defined(AO_HAVE_char_or_release_write) \
       || !defined(AO_HAVE_char_or_write)
      MISSING(AO_char_or);
#   endif
    b |= 66;
# endif
# if defined(AO_HAVE_char_xor_full)
    AO_char_xor_full(&b, 181);
    TA_assert(b == 223);
# else
#   if !defined(AO_HAVE_char_xor) || !defined(AO_HAVE_char_xor_acquire) \
       || !defined(AO_HAVE_char_xor_acquire_read) \
       || !defined(AO_HAVE_char_xor_full) || !defined(AO_HAVE_char_xor_read) \
       || !defined(AO_HAVE_char_xor_release) \
       || !defined(AO_HAVE_char_xor_release_write) \
       || !defined(AO_HAVE_char_xor_write)
      MISSING(AO_char_xor);
#   endif
    b ^= 181;
# endif
# if defined(AO_HAVE_char_and_full)
    AO_char_and_full(&b, 57);
    TA_assert(b == 25);
# else
#   if !defined(AO_HAVE_char_and) || !defined(AO_HAVE_char_and_acquire) \
       || !defined(AO_HAVE_char_and_acquire_read) \
       || !defined(AO_HAVE_char_and_full) || !defined(AO_HAVE_char_and_read) \
       || !defined(AO_HAVE_char_and_release) \
       || !defined(AO_HAVE_char_and_release_write) \
       || !defined(AO_HAVE_char_and_write)
      MISSING(AO_char_and);
#   endif
    b &= 57;
# endif
# if defined(AO_HAVE_char_fetch_compare_and_swap_full)
    TA_assert(AO_char_fetch_compare_and_swap_full(&b, 14, 117) == 25);
    TA_assert(b == 25);
    TA_assert(AO_char_fetch_compare_and_swap_full(&b, 25, 117) == 25);
# else
    MISSING(AO_char_fetch_compare_and_swap);
    if (b == 25) b = 117;
# endif
  TA_assert(b == 117);
# if defined(AO_HAVE_int_compare_and_swap_full)
    TA_assert(!AO_int_compare_and_swap_full(&zz, 14, 42));
    TA_assert(zz == 13);
    TA_assert(AO_int_compare_and_swap_full(&zz, 13, 42));
    TA_assert(zz == 42);
# else
    MISSING(AO_int_compare_and_swap);
    if (*(volatile int *)&zz == 13) zz = 42;
# endif
# if defined(AO_HAVE_int_or_full)
    AO_int_or_full(&zz, 66);
    TA_assert(zz == 106);
# else
#   if !defined(AO_HAVE_int_or) || !defined(AO_HAVE_int_or_acquire) \
       || !defined(AO_HAVE_int_or_acquire_read) \
       || !defined(AO_HAVE_int_or_full) || !defined(AO_HAVE_int_or_read) \
       || !defined(AO_HAVE_int_or_release) \
       || !defined(AO_HAVE_int_or_release_write) \
       || !defined(AO_HAVE_int_or_write)
      MISSING(AO_int_or);
#   endif
    zz |= 66;
# endif
# if defined(AO_HAVE_int_xor_full)
    AO_int_xor_full(&zz, 181);
    TA_assert(zz == 223);
# else
#   if !defined(AO_HAVE_int_xor) || !defined(AO_HAVE_int_xor_acquire) \
       || !defined(AO_HAVE_int_xor_acquire_read) \
       || !defined(AO_HAVE_int_xor_full) || !defined(AO_HAVE_int_xor_read) \
       || !defined(AO_HAVE_int_xor_release) \
       || !defined(AO_HAVE_int_xor_release_write) \
       || !defined(AO_HAVE_int_xor_write)
      MISSING(AO_int_xor);
#   endif
    zz ^= 181;
# endif
# if defined(AO_HAVE_int_and_full)
    AO_int_and_full(&zz, 57);
    TA_assert(zz == 25);
# else
#   if !defined(AO_HAVE_int_and) || !defined(AO_HAVE_int_and_acquire) \
       || !defined(AO_HAVE_int_and_acquire_read) \
       || !defined(AO_HAVE_int_and_full) || !defined(AO_HAVE_int_and_read) \
       || !defined(AO_HAVE_int_and_release) \
       || !defined(AO_HAVE_int_and_release_write) \
       || !defined(AO_HAVE_int_and_write)
      MISSING(AO_int_and);
#   endif
    zz &= 57;
# endif
# if defined(AO_HAVE_int_fetch_compare_and_swap_full)
    TA_assert(AO_int_fetch_compare_and_swap_full(&zz, 14, 117) == 25);
    TA_assert(zz == 25);
    TA_assert(AO_int_fetch_compare_and_swap_full(&zz, 25, 117) == 25);
# else
    MISSING(AO_int_fetch_compare_and_swap);
    if (zz == 25) zz = 117;
# endif
  TA_assert(zz == 117);
# if defined(AO_HAVE_double_load_full) || defined(AO_HAVE_double_store_full)
    /* Initialize old_w even for store to workaround MSan warning.      */
    old_w.AO_val1 = 3316;
    old_w.AO_val2 = 2921;
# endif
# if defined(AO_HAVE_double_load_full)
    new_w = AO_double_load_full(&old_w);
    TA_assert(new_w.AO_val1 == 3316 && new_w.AO_val2 == 2921);
# elif !defined(AO_HAVE_double_load) \
       || !defined(AO_HAVE_double_load_acquire) \
       || !defined(AO_HAVE_double_load_acquire_read) \
       || !defined(AO_HAVE_double_load_dd_acquire_read) \
       || !defined(AO_HAVE_double_load_full) \
       || !defined(AO_HAVE_double_load_read)
    MISSING(AO_double_load);
# endif
# if defined(AO_HAVE_double_store_full)
    new_w.AO_val1 = 1375;
    new_w.AO_val2 = 8243;
    AO_double_store_full(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    AO_double_store_full(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    new_w.AO_val1 ^= old_w.AO_val1;
    new_w.AO_val2 ^= old_w.AO_val2;
    AO_double_store_full(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 0 && old_w.AO_val2 == 0);
# elif !defined(AO_HAVE_double_store) \
       || !defined(AO_HAVE_double_store_full) \
       || !defined(AO_HAVE_double_store_release) \
       || !defined(AO_HAVE_double_store_release_write) \
       || !defined(AO_HAVE_double_store_write)
    MISSING(AO_double_store);
# endif
# if defined(AO_HAVE_compare_double_and_swap_double_full)
    TA_assert(!AO_compare_double_and_swap_double_full(&w, 17, 42, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_double_and_swap_double_full(&w, 0, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_full(&w, 12, 14, 64, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_full(&w, 11, 13, 85, 82));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_full(&w, 13, 12, 17, 42));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_double_and_swap_double_full(&w, 12, 13, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_double_and_swap_double_full(&w, 17, 42, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_double_and_swap_double);
# endif
# if defined(AO_HAVE_compare_and_swap_double_full)
    TA_assert(!AO_compare_and_swap_double_full(&w, 17, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_and_swap_double_full(&w, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_full(&w, 13, 12, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_full(&w, 1213, 48, 86));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_and_swap_double_full(&w, 12, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_and_swap_double_full(&w, 17, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_and_swap_double);
# endif
# if defined(AO_HAVE_double_compare_and_swap_full)
    old_w.AO_val1 = 4116;
    old_w.AO_val2 = 2121;
    new_w.AO_val1 = 8537;
    new_w.AO_val2 = 6410;
    TA_assert(!AO_double_compare_and_swap_full(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_double_compare_and_swap_full(&w, w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = 29;
    new_w.AO_val1 = 820;
    new_w.AO_val2 = 5917;
    TA_assert(!AO_double_compare_and_swap_full(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = 11;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 3552;
    new_w.AO_val2 = 1746;
    TA_assert(!AO_double_compare_and_swap_full(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 8537;
    new_w.AO_val1 = 4116;
    new_w.AO_val2 = 2121;
    TA_assert(!AO_double_compare_and_swap_full(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 1;
    TA_assert(AO_double_compare_and_swap_full(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 1 && w.AO_val2 == 2121);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = w.AO_val2;
    new_w.AO_val1--;
    new_w.AO_val2 = 0;
    TA_assert(AO_double_compare_and_swap_full(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_double_compare_and_swap);
# endif
}
/*
 * Copyright (c) 2003 by Hewlett-Packard Company.  All rights reserved.
 *
 * This file is covered by the GNU general public license, version 2.
 * see COPYING for details.
 */

/* Some basic sanity tests.  These do not test the barrier semantics. */

#undef TA_assert
#define TA_assert(e) \
  if (!(e)) { fprintf(stderr, "Assertion failed %s:%d (barrier: _release_write)\n", \
                    __FILE__, __LINE__), exit(1); }

#undef MISSING
#define MISSING(name) \
  printf("Missing: %s\n", #name "_release_write")

#if defined(CPPCHECK)
  void list_atomic_release_write(void);
  void char_list_atomic_release_write(void);
  void short_list_atomic_release_write(void);
  void int_list_atomic_release_write(void);
  void double_list_atomic_release_write(void);
#endif

void test_atomic_release_write(void)
{
  AO_t x;
  unsigned char b;
  unsigned short s;
  unsigned int zz;
# if defined(AO_HAVE_test_and_set_release_write)
    AO_TS_t z = AO_TS_INITIALIZER;
# endif
# if defined(AO_HAVE_double_compare_and_swap_release_write) \
     || defined(AO_HAVE_double_load_release_write) \
     || defined(AO_HAVE_double_store_release_write)
    static AO_double_t old_w; /* static to avoid misalignment */
    AO_double_t new_w;
# endif
# if defined(AO_HAVE_compare_and_swap_double_release_write) \
     || defined(AO_HAVE_compare_double_and_swap_double_release_write) \
     || defined(AO_HAVE_double_compare_and_swap_release_write)
    static AO_double_t w; /* static to avoid misalignment */
    w.AO_val1 = 0;
    w.AO_val2 = 0;
# endif

# if defined(CPPCHECK)
    list_atomic_release_write();
    char_list_atomic_release_write();
    short_list_atomic_release_write();
    int_list_atomic_release_write();
    double_list_atomic_release_write();
# endif
# if defined(AO_HAVE_nop_release_write)
    AO_nop_release_write();
# elif !defined(AO_HAVE_nop) || !defined(AO_HAVE_nop_full) \
       || !defined(AO_HAVE_nop_read) || !defined(AO_HAVE_nop_write)
    MISSING(AO_nop);
# endif
# if defined(AO_HAVE_store_release_write)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile AO_t *)&x = 0; /* initialize to avoid false warning */
#   endif
    AO_store_release_write(&x, 13);
    TA_assert(x == 13);
# else
#   if !defined(AO_HAVE_store) || !defined(AO_HAVE_store_full) \
       || !defined(AO_HAVE_store_release) \
       || !defined(AO_HAVE_store_release_write) \
       || !defined(AO_HAVE_store_write)
      MISSING(AO_store);
#   endif
    x = 13;
# endif
# if defined(AO_HAVE_load_release_write)
    TA_assert(AO_load_release_write(&x) == 13);
# elif !defined(AO_HAVE_load) || !defined(AO_HAVE_load_acquire) \
       || !defined(AO_HAVE_load_acquire_read) \
       || !defined(AO_HAVE_load_dd_acquire_read) \
       || !defined(AO_HAVE_load_full) || !defined(AO_HAVE_load_read)
    MISSING(AO_load);
# endif
# if defined(AO_HAVE_test_and_set_release_write)
    TA_assert(AO_test_and_set_release_write(&z) == AO_TS_CLEAR);
    TA_assert(AO_test_and_set_release_write(&z) == AO_TS_SET);
    TA_assert(AO_test_and_set_release_write(&z) == AO_TS_SET);
    AO_CLEAR(&z);
# else
    MISSING(AO_test_and_set);
# endif
# if defined(AO_HAVE_fetch_and_add_release_write)
    TA_assert(AO_fetch_and_add_release_write(&x, 42) == 13);
    TA_assert(AO_fetch_and_add_release_write(&x, (AO_t)(-42)) == 55);
# else
    MISSING(AO_fetch_and_add);
# endif
# if defined(AO_HAVE_fetch_and_add1_release_write)
    TA_assert(AO_fetch_and_add1_release_write(&x) == 13);
# else
    MISSING(AO_fetch_and_add1);
    ++x;
# endif
# if defined(AO_HAVE_fetch_and_sub1_release_write)
    TA_assert(AO_fetch_and_sub1_release_write(&x) == 14);
# else
    MISSING(AO_fetch_and_sub1);
    --x;
# endif
# if defined(AO_HAVE_short_store_release_write)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile short *)&s = 0;
#   endif
    AO_short_store_release_write(&s, 13);
# else
#   if !defined(AO_HAVE_short_store) || !defined(AO_HAVE_short_store_full) \
       || !defined(AO_HAVE_short_store_release) \
       || !defined(AO_HAVE_short_store_release_write) \
       || !defined(AO_HAVE_short_store_write)
      MISSING(AO_short_store);
#   endif
    s = 13;
# endif
# if defined(AO_HAVE_short_load_release_write)
    TA_assert(AO_short_load(&s) == 13);
# elif !defined(AO_HAVE_short_load) || !defined(AO_HAVE_short_load_acquire) \
       || !defined(AO_HAVE_short_load_acquire_read) \
       || !defined(AO_HAVE_short_load_dd_acquire_read) \
       || !defined(AO_HAVE_short_load_full) \
       || !defined(AO_HAVE_short_load_read)
    MISSING(AO_short_load);
# endif
# if defined(AO_HAVE_short_fetch_and_add_release_write)
    TA_assert(AO_short_fetch_and_add_release_write(&s, 42) == 13);
    TA_assert(AO_short_fetch_and_add_release_write(&s, (unsigned short)-42) == 55);
# else
    MISSING(AO_short_fetch_and_add);
# endif
# if defined(AO_HAVE_short_fetch_and_add1_release_write)
    TA_assert(AO_short_fetch_and_add1_release_write(&s) == 13);
# else
    MISSING(AO_short_fetch_and_add1);
    ++s;
# endif
# if defined(AO_HAVE_short_fetch_and_sub1_release_write)
    TA_assert(AO_short_fetch_and_sub1_release_write(&s) == 14);
# else
    MISSING(AO_short_fetch_and_sub1);
    --s;
# endif
  TA_assert(*(volatile short *)&s == 13);
# if defined(AO_HAVE_char_store_release_write)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile char *)&b = 0;
#   endif
    AO_char_store_release_write(&b, 13);
# else
#   if !defined(AO_HAVE_char_store) || !defined(AO_HAVE_char_store_full) \
       || !defined(AO_HAVE_char_store_release) \
       || !defined(AO_HAVE_char_store_release_write) \
       || !defined(AO_HAVE_char_store_write)
      MISSING(AO_char_store);
#   endif
    b = 13;
# endif
# if defined(AO_HAVE_char_load_release_write)
    TA_assert(AO_char_load(&b) == 13);
# elif !defined(AO_HAVE_char_load) || !defined(AO_HAVE_char_load_acquire) \
       || !defined(AO_HAVE_char_load_acquire_read) \
       || !defined(AO_HAVE_char_load_dd_acquire_read) \
       || !defined(AO_HAVE_char_load_full) || !defined(AO_HAVE_char_load_read)
    MISSING(AO_char_load);
# endif
# if defined(AO_HAVE_char_fetch_and_add_release_write)
    TA_assert(AO_char_fetch_and_add_release_write(&b, 42) == 13);
    TA_assert(AO_char_fetch_and_add_release_write(&b, (unsigned char)-42) == 55);
# else
    MISSING(AO_char_fetch_and_add);
# endif
# if defined(AO_HAVE_char_fetch_and_add1_release_write)
    TA_assert(AO_char_fetch_and_add1_release_write(&b) == 13);
# else
    MISSING(AO_char_fetch_and_add1);
    ++b;
# endif
# if defined(AO_HAVE_char_fetch_and_sub1_release_write)
    TA_assert(AO_char_fetch_and_sub1_release_write(&b) == 14);
# else
    MISSING(AO_char_fetch_and_sub1);
    --b;
# endif
  TA_assert(*(volatile char *)&b == 13);
# if defined(AO_HAVE_int_store_release_write)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile int *)&zz = 0;
#   endif
    AO_int_store_release_write(&zz, 13);
# else
#   if !defined(AO_HAVE_int_store) || !defined(AO_HAVE_int_store_full) \
       || !defined(AO_HAVE_int_store_release) \
       || !defined(AO_HAVE_int_store_release_write) \
       || !defined(AO_HAVE_int_store_write)
      MISSING(AO_int_store);
#   endif
    zz = 13;
# endif
# if defined(AO_HAVE_int_load_release_write)
    TA_assert(AO_int_load(&zz) == 13);
# elif !defined(AO_HAVE_int_load) || !defined(AO_HAVE_int_load_acquire) \
       || !defined(AO_HAVE_int_load_acquire_read) \
       || !defined(AO_HAVE_int_load_dd_acquire_read) \
       || !defined(AO_HAVE_int_load_full) || !defined(AO_HAVE_int_load_read)
    MISSING(AO_int_load);
# endif
# if defined(AO_HAVE_int_fetch_and_add_release_write)
    TA_assert(AO_int_fetch_and_add_release_write(&zz, 42) == 13);
    TA_assert(AO_int_fetch_and_add_release_write(&zz, (unsigned int)-42) == 55);
# else
    MISSING(AO_int_fetch_and_add);
# endif
# if defined(AO_HAVE_int_fetch_and_add1_release_write)
    TA_assert(AO_int_fetch_and_add1_release_write(&zz) == 13);
# else
    MISSING(AO_int_fetch_and_add1);
    ++zz;
# endif
# if defined(AO_HAVE_int_fetch_and_sub1_release_write)
    TA_assert(AO_int_fetch_and_sub1_release_write(&zz) == 14);
# else
    MISSING(AO_int_fetch_and_sub1);
    --zz;
# endif
  TA_assert(*(volatile int *)&zz == 13);
# if defined(AO_HAVE_compare_and_swap_release_write)
    TA_assert(!AO_compare_and_swap_release_write(&x, 14, 42));
    TA_assert(x == 13);
    TA_assert(AO_compare_and_swap_release_write(&x, 13, 42));
    TA_assert(x == 42);
# else
    MISSING(AO_compare_and_swap);
    if (*(volatile AO_t *)&x == 13) x = 42;
# endif
# if defined(AO_HAVE_or_release_write)
    AO_or_release_write(&x, 66);
    TA_assert(x == 106);
# else
#   if !defined(AO_HAVE_or) || !defined(AO_HAVE_or_acquire) \
       || !defined(AO_HAVE_or_acquire_read) || !defined(AO_HAVE_or_full) \
       || !defined(AO_HAVE_or_read) || !defined(AO_HAVE_or_release) \
       || !defined(AO_HAVE_or_release_write) || !defined(AO_HAVE_or_write)
      MISSING(AO_or);
#   endif
    x |= 66;
# endif
# if defined(AO_HAVE_xor_release_write)
    AO_xor_release_write(&x, 181);
    TA_assert(x == 223);
# else
#   if !defined(AO_HAVE_xor) || !defined(AO_HAVE_xor_acquire) \
       || !defined(AO_HAVE_xor_acquire_read) || !defined(AO_HAVE_xor_full) \
       || !defined(AO_HAVE_xor_read) || !defined(AO_HAVE_xor_release) \
       || !defined(AO_HAVE_xor_release_write) || !defined(AO_HAVE_xor_write)
      MISSING(AO_xor);
#   endif
    x ^= 181;
# endif
# if defined(AO_HAVE_and_release_write)
    AO_and_release_write(&x, 57);
    TA_assert(x == 25);
# else
#   if !defined(AO_HAVE_and) || !defined(AO_HAVE_and_acquire) \
       || !defined(AO_HAVE_and_acquire_read) || !defined(AO_HAVE_and_full) \
       || !defined(AO_HAVE_and_read) || !defined(AO_HAVE_and_release) \
       || !defined(AO_HAVE_and_release_write) || !defined(AO_HAVE_and_write)
      MISSING(AO_and);
#   endif
    x &= 57;
# endif
# if defined(AO_HAVE_fetch_compare_and_swap_release_write)
    TA_assert(AO_fetch_compare_and_swap_release_write(&x, 14, 117) == 25);
    TA_assert(x == 25);
    TA_assert(AO_fetch_compare_and_swap_release_write(&x, 25, 117) == 25);
# else
    MISSING(AO_fetch_compare_and_swap);
    if (x == 25) x = 117;
# endif
  TA_assert(x == 117);
# if defined(AO_HAVE_short_compare_and_swap_release_write)
    TA_assert(!AO_short_compare_and_swap_release_write(&s, 14, 42));
    TA_assert(s == 13);
    TA_assert(AO_short_compare_and_swap_release_write(&s, 13, 42));
    TA_assert(s == 42);
# else
    MISSING(AO_short_compare_and_swap);
    if (*(volatile short *)&s == 13) s = 42;
# endif
# if defined(AO_HAVE_short_or_release_write)
    AO_short_or_release_write(&s, 66);
    TA_assert(s == 106);
# else
#   if !defined(AO_HAVE_short_or) || !defined(AO_HAVE_short_or_acquire) \
       || !defined(AO_HAVE_short_or_acquire_read) \
       || !defined(AO_HAVE_short_or_full) || !defined(AO_HAVE_short_or_read) \
       || !defined(AO_HAVE_short_or_release) \
       || !defined(AO_HAVE_short_or_release_write) \
       || !defined(AO_HAVE_short_or_write)
      MISSING(AO_short_or);
#   endif
    s |= 66;
# endif
# if defined(AO_HAVE_short_xor_release_write)
    AO_short_xor_release_write(&s, 181);
    TA_assert(s == 223);
# else
#   if !defined(AO_HAVE_short_xor) || !defined(AO_HAVE_short_xor_acquire) \
       || !defined(AO_HAVE_short_xor_acquire_read) \
       || !defined(AO_HAVE_short_xor_full) \
       || !defined(AO_HAVE_short_xor_read) \
       || !defined(AO_HAVE_short_xor_release) \
       || !defined(AO_HAVE_short_xor_release_write) \
       || !defined(AO_HAVE_short_xor_write)
      MISSING(AO_short_xor);
#   endif
    s ^= 181;
# endif
# if defined(AO_HAVE_short_and_release_write)
    AO_short_and_release_write(&s, 57);
    TA_assert(s == 25);
# else
#   if !defined(AO_HAVE_short_and) || !defined(AO_HAVE_short_and_acquire) \
       || !defined(AO_HAVE_short_and_acquire_read) \
       || !defined(AO_HAVE_short_and_full) \
       || !defined(AO_HAVE_short_and_read) \
       || !defined(AO_HAVE_short_and_release) \
       || !defined(AO_HAVE_short_and_release_write) \
       || !defined(AO_HAVE_short_and_write)
      MISSING(AO_short_and);
#   endif
    s &= 57;
# endif
# if defined(AO_HAVE_short_fetch_compare_and_swap_release_write)
    TA_assert(AO_short_fetch_compare_and_swap_release_write(&s, 14, 117) == 25);
    TA_assert(s == 25);
    TA_assert(AO_short_fetch_compare_and_swap_release_write(&s, 25, 117) == 25);
# else
    MISSING(AO_short_fetch_compare_and_swap);
    if (s == 25) s = 117;
# endif
  TA_assert(s == 117);
# if defined(AO_HAVE_char_compare_and_swap_release_write)
    TA_assert(!AO_char_compare_and_swap_release_write(&b, 14, 42));
    TA_assert(b == 13);
    TA_assert(AO_char_compare_and_swap_release_write(&b, 13, 42));
    TA_assert(b == 42);
# else
    MISSING(AO_char_compare_and_swap);
    if (*(volatile char *)&b == 13) b = 42;
# endif
# if defined(AO_HAVE_char_or_release_write)
    AO_char_or_release_write(&b, 66);
    TA_assert(b == 106);
# else
#   if !defined(AO_HAVE_char_or) || !defined(AO_HAVE_char_or_acquire) \
       || !defined(AO_HAVE_char_or_acquire_read) \
       || !defined(AO_HAVE_char_or_full) || !defined(AO_HAVE_char_or_read) \
       || !defined(AO_HAVE_char_or_release) \
       || !defined(AO_HAVE_char_or_release_write) \
       || !defined(AO_HAVE_char_or_write)
      MISSING(AO_char_or);
#   endif
    b |= 66;
# endif
# if defined(AO_HAVE_char_xor_release_write)
    AO_char_xor_release_write(&b, 181);
    TA_assert(b == 223);
# else
#   if !defined(AO_HAVE_char_xor) || !defined(AO_HAVE_char_xor_acquire) \
       || !defined(AO_HAVE_char_xor_acquire_read) \
       || !defined(AO_HAVE_char_xor_full) || !defined(AO_HAVE_char_xor_read) \
       || !defined(AO_HAVE_char_xor_release) \
       || !defined(AO_HAVE_char_xor_release_write) \
       || !defined(AO_HAVE_char_xor_write)
      MISSING(AO_char_xor);
#   endif
    b ^= 181;
# endif
# if defined(AO_HAVE_char_and_release_write)
    AO_char_and_release_write(&b, 57);
    TA_assert(b == 25);
# else
#   if !defined(AO_HAVE_char_and) || !defined(AO_HAVE_char_and_acquire) \
       || !defined(AO_HAVE_char_and_acquire_read) \
       || !defined(AO_HAVE_char_and_full) || !defined(AO_HAVE_char_and_read) \
       || !defined(AO_HAVE_char_and_release) \
       || !defined(AO_HAVE_char_and_release_write) \
       || !defined(AO_HAVE_char_and_write)
      MISSING(AO_char_and);
#   endif
    b &= 57;
# endif
# if defined(AO_HAVE_char_fetch_compare_and_swap_release_write)
    TA_assert(AO_char_fetch_compare_and_swap_release_write(&b, 14, 117) == 25);
    TA_assert(b == 25);
    TA_assert(AO_char_fetch_compare_and_swap_release_write(&b, 25, 117) == 25);
# else
    MISSING(AO_char_fetch_compare_and_swap);
    if (b == 25) b = 117;
# endif
  TA_assert(b == 117);
# if defined(AO_HAVE_int_compare_and_swap_release_write)
    TA_assert(!AO_int_compare_and_swap_release_write(&zz, 14, 42));
    TA_assert(zz == 13);
    TA_assert(AO_int_compare_and_swap_release_write(&zz, 13, 42));
    TA_assert(zz == 42);
# else
    MISSING(AO_int_compare_and_swap);
    if (*(volatile int *)&zz == 13) zz = 42;
# endif
# if defined(AO_HAVE_int_or_release_write)
    AO_int_or_release_write(&zz, 66);
    TA_assert(zz == 106);
# else
#   if !defined(AO_HAVE_int_or) || !defined(AO_HAVE_int_or_acquire) \
       || !defined(AO_HAVE_int_or_acquire_read) \
       || !defined(AO_HAVE_int_or_full) || !defined(AO_HAVE_int_or_read) \
       || !defined(AO_HAVE_int_or_release) \
       || !defined(AO_HAVE_int_or_release_write) \
       || !defined(AO_HAVE_int_or_write)
      MISSING(AO_int_or);
#   endif
    zz |= 66;
# endif
# if defined(AO_HAVE_int_xor_release_write)
    AO_int_xor_release_write(&zz, 181);
    TA_assert(zz == 223);
# else
#   if !defined(AO_HAVE_int_xor) || !defined(AO_HAVE_int_xor_acquire) \
       || !defined(AO_HAVE_int_xor_acquire_read) \
       || !defined(AO_HAVE_int_xor_full) || !defined(AO_HAVE_int_xor_read) \
       || !defined(AO_HAVE_int_xor_release) \
       || !defined(AO_HAVE_int_xor_release_write) \
       || !defined(AO_HAVE_int_xor_write)
      MISSING(AO_int_xor);
#   endif
    zz ^= 181;
# endif
# if defined(AO_HAVE_int_and_release_write)
    AO_int_and_release_write(&zz, 57);
    TA_assert(zz == 25);
# else
#   if !defined(AO_HAVE_int_and) || !defined(AO_HAVE_int_and_acquire) \
       || !defined(AO_HAVE_int_and_acquire_read) \
       || !defined(AO_HAVE_int_and_full) || !defined(AO_HAVE_int_and_read) \
       || !defined(AO_HAVE_int_and_release) \
       || !defined(AO_HAVE_int_and_release_write) \
       || !defined(AO_HAVE_int_and_write)
      MISSING(AO_int_and);
#   endif
    zz &= 57;
# endif
# if defined(AO_HAVE_int_fetch_compare_and_swap_release_write)
    TA_assert(AO_int_fetch_compare_and_swap_release_write(&zz, 14, 117) == 25);
    TA_assert(zz == 25);
    TA_assert(AO_int_fetch_compare_and_swap_release_write(&zz, 25, 117) == 25);
# else
    MISSING(AO_int_fetch_compare_and_swap);
    if (zz == 25) zz = 117;
# endif
  TA_assert(zz == 117);
# if defined(AO_HAVE_double_load_release_write) || defined(AO_HAVE_double_store_release_write)
    /* Initialize old_w even for store to workaround MSan warning.      */
    old_w.AO_val1 = 3316;
    old_w.AO_val2 = 2921;
# endif
# if defined(AO_HAVE_double_load_release_write)
    new_w = AO_double_load_release_write(&old_w);
    TA_assert(new_w.AO_val1 == 3316 && new_w.AO_val2 == 2921);
# elif !defined(AO_HAVE_double_load) \
       || !defined(AO_HAVE_double_load_acquire) \
       || !defined(AO_HAVE_double_load_acquire_read) \
       || !defined(AO_HAVE_double_load_dd_acquire_read) \
       || !defined(AO_HAVE_double_load_full) \
       || !defined(AO_HAVE_double_load_read)
    MISSING(AO_double_load);
# endif
# if defined(AO_HAVE_double_store_release_write)
    new_w.AO_val1 = 1375;
    new_w.AO_val2 = 8243;
    AO_double_store_release_write(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    AO_double_store_release_write(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    new_w.AO_val1 ^= old_w.AO_val1;
    new_w.AO_val2 ^= old_w.AO_val2;
    AO_double_store_release_write(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 0 && old_w.AO_val2 == 0);
# elif !defined(AO_HAVE_double_store) \
       || !defined(AO_HAVE_double_store_full) \
       || !defined(AO_HAVE_double_store_release) \
       || !defined(AO_HAVE_double_store_release_write) \
       || !defined(AO_HAVE_double_store_write)
    MISSING(AO_double_store);
# endif
# if defined(AO_HAVE_compare_double_and_swap_double_release_write)
    TA_assert(!AO_compare_double_and_swap_double_release_write(&w, 17, 42, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_double_and_swap_double_release_write(&w, 0, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_release_write(&w, 12, 14, 64, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_release_write(&w, 11, 13, 85, 82));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_release_write(&w, 13, 12, 17, 42));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_double_and_swap_double_release_write(&w, 12, 13, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_double_and_swap_double_release_write(&w, 17, 42, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_double_and_swap_double);
# endif
# if defined(AO_HAVE_compare_and_swap_double_release_write)
    TA_assert(!AO_compare_and_swap_double_release_write(&w, 17, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_and_swap_double_release_write(&w, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_release_write(&w, 13, 12, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_release_write(&w, 1213, 48, 86));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_and_swap_double_release_write(&w, 12, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_and_swap_double_release_write(&w, 17, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_and_swap_double);
# endif
# if defined(AO_HAVE_double_compare_and_swap_release_write)
    old_w.AO_val1 = 4116;
    old_w.AO_val2 = 2121;
    new_w.AO_val1 = 8537;
    new_w.AO_val2 = 6410;
    TA_assert(!AO_double_compare_and_swap_release_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_double_compare_and_swap_release_write(&w, w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = 29;
    new_w.AO_val1 = 820;
    new_w.AO_val2 = 5917;
    TA_assert(!AO_double_compare_and_swap_release_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = 11;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 3552;
    new_w.AO_val2 = 1746;
    TA_assert(!AO_double_compare_and_swap_release_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 8537;
    new_w.AO_val1 = 4116;
    new_w.AO_val2 = 2121;
    TA_assert(!AO_double_compare_and_swap_release_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 1;
    TA_assert(AO_double_compare_and_swap_release_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 1 && w.AO_val2 == 2121);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = w.AO_val2;
    new_w.AO_val1--;
    new_w.AO_val2 = 0;
    TA_assert(AO_double_compare_and_swap_release_write(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_double_compare_and_swap);
# endif
}
/*
 * Copyright (c) 2003 by Hewlett-Packard Company.  All rights reserved.
 *
 * This file is covered by the GNU general public license, version 2.
 * see COPYING for details.
 */

/* Some basic sanity tests.  These do not test the barrier semantics. */

#undef TA_assert
#define TA_assert(e) \
  if (!(e)) { fprintf(stderr, "Assertion failed %s:%d (barrier: _acquire_read)\n", \
                    __FILE__, __LINE__), exit(1); }

#undef MISSING
#define MISSING(name) \
  printf("Missing: %s\n", #name "_acquire_read")

#if defined(CPPCHECK)
  void list_atomic_acquire_read(void);
  void char_list_atomic_acquire_read(void);
  void short_list_atomic_acquire_read(void);
  void int_list_atomic_acquire_read(void);
  void double_list_atomic_acquire_read(void);
#endif

void test_atomic_acquire_read(void)
{
  AO_t x;
  unsigned char b;
  unsigned short s;
  unsigned int zz;
# if defined(AO_HAVE_test_and_set_acquire_read)
    AO_TS_t z = AO_TS_INITIALIZER;
# endif
# if defined(AO_HAVE_double_compare_and_swap_acquire_read) \
     || defined(AO_HAVE_double_load_acquire_read) \
     || defined(AO_HAVE_double_store_acquire_read)
    static AO_double_t old_w; /* static to avoid misalignment */
    AO_double_t new_w;
# endif
# if defined(AO_HAVE_compare_and_swap_double_acquire_read) \
     || defined(AO_HAVE_compare_double_and_swap_double_acquire_read) \
     || defined(AO_HAVE_double_compare_and_swap_acquire_read)
    static AO_double_t w; /* static to avoid misalignment */
    w.AO_val1 = 0;
    w.AO_val2 = 0;
# endif

# if defined(CPPCHECK)
    list_atomic_acquire_read();
    char_list_atomic_acquire_read();
    short_list_atomic_acquire_read();
    int_list_atomic_acquire_read();
    double_list_atomic_acquire_read();
# endif
# if defined(AO_HAVE_nop_acquire_read)
    AO_nop_acquire_read();
# elif !defined(AO_HAVE_nop) || !defined(AO_HAVE_nop_full) \
       || !defined(AO_HAVE_nop_read) || !defined(AO_HAVE_nop_write)
    MISSING(AO_nop);
# endif
# if defined(AO_HAVE_store_acquire_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile AO_t *)&x = 0; /* initialize to avoid false warning */
#   endif
    AO_store_acquire_read(&x, 13);
    TA_assert(x == 13);
# else
#   if !defined(AO_HAVE_store) || !defined(AO_HAVE_store_full) \
       || !defined(AO_HAVE_store_release) \
       || !defined(AO_HAVE_store_release_write) \
       || !defined(AO_HAVE_store_write)
      MISSING(AO_store);
#   endif
    x = 13;
# endif
# if defined(AO_HAVE_load_acquire_read)
    TA_assert(AO_load_acquire_read(&x) == 13);
# elif !defined(AO_HAVE_load) || !defined(AO_HAVE_load_acquire) \
       || !defined(AO_HAVE_load_acquire_read) \
       || !defined(AO_HAVE_load_dd_acquire_read) \
       || !defined(AO_HAVE_load_full) || !defined(AO_HAVE_load_read)
    MISSING(AO_load);
# endif
# if defined(AO_HAVE_test_and_set_acquire_read)
    TA_assert(AO_test_and_set_acquire_read(&z) == AO_TS_CLEAR);
    TA_assert(AO_test_and_set_acquire_read(&z) == AO_TS_SET);
    TA_assert(AO_test_and_set_acquire_read(&z) == AO_TS_SET);
    AO_CLEAR(&z);
# else
    MISSING(AO_test_and_set);
# endif
# if defined(AO_HAVE_fetch_and_add_acquire_read)
    TA_assert(AO_fetch_and_add_acquire_read(&x, 42) == 13);
    TA_assert(AO_fetch_and_add_acquire_read(&x, (AO_t)(-42)) == 55);
# else
    MISSING(AO_fetch_and_add);
# endif
# if defined(AO_HAVE_fetch_and_add1_acquire_read)
    TA_assert(AO_fetch_and_add1_acquire_read(&x) == 13);
# else
    MISSING(AO_fetch_and_add1);
    ++x;
# endif
# if defined(AO_HAVE_fetch_and_sub1_acquire_read)
    TA_assert(AO_fetch_and_sub1_acquire_read(&x) == 14);
# else
    MISSING(AO_fetch_and_sub1);
    --x;
# endif
# if defined(AO_HAVE_short_store_acquire_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile short *)&s = 0;
#   endif
    AO_short_store_acquire_read(&s, 13);
# else
#   if !defined(AO_HAVE_short_store) || !defined(AO_HAVE_short_store_full) \
       || !defined(AO_HAVE_short_store_release) \
       || !defined(AO_HAVE_short_store_release_write) \
       || !defined(AO_HAVE_short_store_write)
      MISSING(AO_short_store);
#   endif
    s = 13;
# endif
# if defined(AO_HAVE_short_load_acquire_read)
    TA_assert(AO_short_load(&s) == 13);
# elif !defined(AO_HAVE_short_load) || !defined(AO_HAVE_short_load_acquire) \
       || !defined(AO_HAVE_short_load_acquire_read) \
       || !defined(AO_HAVE_short_load_dd_acquire_read) \
       || !defined(AO_HAVE_short_load_full) \
       || !defined(AO_HAVE_short_load_read)
    MISSING(AO_short_load);
# endif
# if defined(AO_HAVE_short_fetch_and_add_acquire_read)
    TA_assert(AO_short_fetch_and_add_acquire_read(&s, 42) == 13);
    TA_assert(AO_short_fetch_and_add_acquire_read(&s, (unsigned short)-42) == 55);
# else
    MISSING(AO_short_fetch_and_add);
# endif
# if defined(AO_HAVE_short_fetch_and_add1_acquire_read)
    TA_assert(AO_short_fetch_and_add1_acquire_read(&s) == 13);
# else
    MISSING(AO_short_fetch_and_add1);
    ++s;
# endif
# if defined(AO_HAVE_short_fetch_and_sub1_acquire_read)
    TA_assert(AO_short_fetch_and_sub1_acquire_read(&s) == 14);
# else
    MISSING(AO_short_fetch_and_sub1);
    --s;
# endif
  TA_assert(*(volatile short *)&s == 13);
# if defined(AO_HAVE_char_store_acquire_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile char *)&b = 0;
#   endif
    AO_char_store_acquire_read(&b, 13);
# else
#   if !defined(AO_HAVE_char_store) || !defined(AO_HAVE_char_store_full) \
       || !defined(AO_HAVE_char_store_release) \
       || !defined(AO_HAVE_char_store_release_write) \
       || !defined(AO_HAVE_char_store_write)
      MISSING(AO_char_store);
#   endif
    b = 13;
# endif
# if defined(AO_HAVE_char_load_acquire_read)
    TA_assert(AO_char_load(&b) == 13);
# elif !defined(AO_HAVE_char_load) || !defined(AO_HAVE_char_load_acquire) \
       || !defined(AO_HAVE_char_load_acquire_read) \
       || !defined(AO_HAVE_char_load_dd_acquire_read) \
       || !defined(AO_HAVE_char_load_full) || !defined(AO_HAVE_char_load_read)
    MISSING(AO_char_load);
# endif
# if defined(AO_HAVE_char_fetch_and_add_acquire_read)
    TA_assert(AO_char_fetch_and_add_acquire_read(&b, 42) == 13);
    TA_assert(AO_char_fetch_and_add_acquire_read(&b, (unsigned char)-42) == 55);
# else
    MISSING(AO_char_fetch_and_add);
# endif
# if defined(AO_HAVE_char_fetch_and_add1_acquire_read)
    TA_assert(AO_char_fetch_and_add1_acquire_read(&b) == 13);
# else
    MISSING(AO_char_fetch_and_add1);
    ++b;
# endif
# if defined(AO_HAVE_char_fetch_and_sub1_acquire_read)
    TA_assert(AO_char_fetch_and_sub1_acquire_read(&b) == 14);
# else
    MISSING(AO_char_fetch_and_sub1);
    --b;
# endif
  TA_assert(*(volatile char *)&b == 13);
# if defined(AO_HAVE_int_store_acquire_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile int *)&zz = 0;
#   endif
    AO_int_store_acquire_read(&zz, 13);
# else
#   if !defined(AO_HAVE_int_store) || !defined(AO_HAVE_int_store_full) \
       || !defined(AO_HAVE_int_store_release) \
       || !defined(AO_HAVE_int_store_release_write) \
       || !defined(AO_HAVE_int_store_write)
      MISSING(AO_int_store);
#   endif
    zz = 13;
# endif
# if defined(AO_HAVE_int_load_acquire_read)
    TA_assert(AO_int_load(&zz) == 13);
# elif !defined(AO_HAVE_int_load) || !defined(AO_HAVE_int_load_acquire) \
       || !defined(AO_HAVE_int_load_acquire_read) \
       || !defined(AO_HAVE_int_load_dd_acquire_read) \
       || !defined(AO_HAVE_int_load_full) || !defined(AO_HAVE_int_load_read)
    MISSING(AO_int_load);
# endif
# if defined(AO_HAVE_int_fetch_and_add_acquire_read)
    TA_assert(AO_int_fetch_and_add_acquire_read(&zz, 42) == 13);
    TA_assert(AO_int_fetch_and_add_acquire_read(&zz, (unsigned int)-42) == 55);
# else
    MISSING(AO_int_fetch_and_add);
# endif
# if defined(AO_HAVE_int_fetch_and_add1_acquire_read)
    TA_assert(AO_int_fetch_and_add1_acquire_read(&zz) == 13);
# else
    MISSING(AO_int_fetch_and_add1);
    ++zz;
# endif
# if defined(AO_HAVE_int_fetch_and_sub1_acquire_read)
    TA_assert(AO_int_fetch_and_sub1_acquire_read(&zz) == 14);
# else
    MISSING(AO_int_fetch_and_sub1);
    --zz;
# endif
  TA_assert(*(volatile int *)&zz == 13);
# if defined(AO_HAVE_compare_and_swap_acquire_read)
    TA_assert(!AO_compare_and_swap_acquire_read(&x, 14, 42));
    TA_assert(x == 13);
    TA_assert(AO_compare_and_swap_acquire_read(&x, 13, 42));
    TA_assert(x == 42);
# else
    MISSING(AO_compare_and_swap);
    if (*(volatile AO_t *)&x == 13) x = 42;
# endif
# if defined(AO_HAVE_or_acquire_read)
    AO_or_acquire_read(&x, 66);
    TA_assert(x == 106);
# else
#   if !defined(AO_HAVE_or) || !defined(AO_HAVE_or_acquire) \
       || !defined(AO_HAVE_or_acquire_read) || !defined(AO_HAVE_or_full) \
       || !defined(AO_HAVE_or_read) || !defined(AO_HAVE_or_release) \
       || !defined(AO_HAVE_or_release_write) || !defined(AO_HAVE_or_write)
      MISSING(AO_or);
#   endif
    x |= 66;
# endif
# if defined(AO_HAVE_xor_acquire_read)
    AO_xor_acquire_read(&x, 181);
    TA_assert(x == 223);
# else
#   if !defined(AO_HAVE_xor) || !defined(AO_HAVE_xor_acquire) \
       || !defined(AO_HAVE_xor_acquire_read) || !defined(AO_HAVE_xor_full) \
       || !defined(AO_HAVE_xor_read) || !defined(AO_HAVE_xor_release) \
       || !defined(AO_HAVE_xor_release_write) || !defined(AO_HAVE_xor_write)
      MISSING(AO_xor);
#   endif
    x ^= 181;
# endif
# if defined(AO_HAVE_and_acquire_read)
    AO_and_acquire_read(&x, 57);
    TA_assert(x == 25);
# else
#   if !defined(AO_HAVE_and) || !defined(AO_HAVE_and_acquire) \
       || !defined(AO_HAVE_and_acquire_read) || !defined(AO_HAVE_and_full) \
       || !defined(AO_HAVE_and_read) || !defined(AO_HAVE_and_release) \
       || !defined(AO_HAVE_and_release_write) || !defined(AO_HAVE_and_write)
      MISSING(AO_and);
#   endif
    x &= 57;
# endif
# if defined(AO_HAVE_fetch_compare_and_swap_acquire_read)
    TA_assert(AO_fetch_compare_and_swap_acquire_read(&x, 14, 117) == 25);
    TA_assert(x == 25);
    TA_assert(AO_fetch_compare_and_swap_acquire_read(&x, 25, 117) == 25);
# else
    MISSING(AO_fetch_compare_and_swap);
    if (x == 25) x = 117;
# endif
  TA_assert(x == 117);
# if defined(AO_HAVE_short_compare_and_swap_acquire_read)
    TA_assert(!AO_short_compare_and_swap_acquire_read(&s, 14, 42));
    TA_assert(s == 13);
    TA_assert(AO_short_compare_and_swap_acquire_read(&s, 13, 42));
    TA_assert(s == 42);
# else
    MISSING(AO_short_compare_and_swap);
    if (*(volatile short *)&s == 13) s = 42;
# endif
# if defined(AO_HAVE_short_or_acquire_read)
    AO_short_or_acquire_read(&s, 66);
    TA_assert(s == 106);
# else
#   if !defined(AO_HAVE_short_or) || !defined(AO_HAVE_short_or_acquire) \
       || !defined(AO_HAVE_short_or_acquire_read) \
       || !defined(AO_HAVE_short_or_full) || !defined(AO_HAVE_short_or_read) \
       || !defined(AO_HAVE_short_or_release) \
       || !defined(AO_HAVE_short_or_release_write) \
       || !defined(AO_HAVE_short_or_write)
      MISSING(AO_short_or);
#   endif
    s |= 66;
# endif
# if defined(AO_HAVE_short_xor_acquire_read)
    AO_short_xor_acquire_read(&s, 181);
    TA_assert(s == 223);
# else
#   if !defined(AO_HAVE_short_xor) || !defined(AO_HAVE_short_xor_acquire) \
       || !defined(AO_HAVE_short_xor_acquire_read) \
       || !defined(AO_HAVE_short_xor_full) \
       || !defined(AO_HAVE_short_xor_read) \
       || !defined(AO_HAVE_short_xor_release) \
       || !defined(AO_HAVE_short_xor_release_write) \
       || !defined(AO_HAVE_short_xor_write)
      MISSING(AO_short_xor);
#   endif
    s ^= 181;
# endif
# if defined(AO_HAVE_short_and_acquire_read)
    AO_short_and_acquire_read(&s, 57);
    TA_assert(s == 25);
# else
#   if !defined(AO_HAVE_short_and) || !defined(AO_HAVE_short_and_acquire) \
       || !defined(AO_HAVE_short_and_acquire_read) \
       || !defined(AO_HAVE_short_and_full) \
       || !defined(AO_HAVE_short_and_read) \
       || !defined(AO_HAVE_short_and_release) \
       || !defined(AO_HAVE_short_and_release_write) \
       || !defined(AO_HAVE_short_and_write)
      MISSING(AO_short_and);
#   endif
    s &= 57;
# endif
# if defined(AO_HAVE_short_fetch_compare_and_swap_acquire_read)
    TA_assert(AO_short_fetch_compare_and_swap_acquire_read(&s, 14, 117) == 25);
    TA_assert(s == 25);
    TA_assert(AO_short_fetch_compare_and_swap_acquire_read(&s, 25, 117) == 25);
# else
    MISSING(AO_short_fetch_compare_and_swap);
    if (s == 25) s = 117;
# endif
  TA_assert(s == 117);
# if defined(AO_HAVE_char_compare_and_swap_acquire_read)
    TA_assert(!AO_char_compare_and_swap_acquire_read(&b, 14, 42));
    TA_assert(b == 13);
    TA_assert(AO_char_compare_and_swap_acquire_read(&b, 13, 42));
    TA_assert(b == 42);
# else
    MISSING(AO_char_compare_and_swap);
    if (*(volatile char *)&b == 13) b = 42;
# endif
# if defined(AO_HAVE_char_or_acquire_read)
    AO_char_or_acquire_read(&b, 66);
    TA_assert(b == 106);
# else
#   if !defined(AO_HAVE_char_or) || !defined(AO_HAVE_char_or_acquire) \
       || !defined(AO_HAVE_char_or_acquire_read) \
       || !defined(AO_HAVE_char_or_full) || !defined(AO_HAVE_char_or_read) \
       || !defined(AO_HAVE_char_or_release) \
       || !defined(AO_HAVE_char_or_release_write) \
       || !defined(AO_HAVE_char_or_write)
      MISSING(AO_char_or);
#   endif
    b |= 66;
# endif
# if defined(AO_HAVE_char_xor_acquire_read)
    AO_char_xor_acquire_read(&b, 181);
    TA_assert(b == 223);
# else
#   if !defined(AO_HAVE_char_xor) || !defined(AO_HAVE_char_xor_acquire) \
       || !defined(AO_HAVE_char_xor_acquire_read) \
       || !defined(AO_HAVE_char_xor_full) || !defined(AO_HAVE_char_xor_read) \
       || !defined(AO_HAVE_char_xor_release) \
       || !defined(AO_HAVE_char_xor_release_write) \
       || !defined(AO_HAVE_char_xor_write)
      MISSING(AO_char_xor);
#   endif
    b ^= 181;
# endif
# if defined(AO_HAVE_char_and_acquire_read)
    AO_char_and_acquire_read(&b, 57);
    TA_assert(b == 25);
# else
#   if !defined(AO_HAVE_char_and) || !defined(AO_HAVE_char_and_acquire) \
       || !defined(AO_HAVE_char_and_acquire_read) \
       || !defined(AO_HAVE_char_and_full) || !defined(AO_HAVE_char_and_read) \
       || !defined(AO_HAVE_char_and_release) \
       || !defined(AO_HAVE_char_and_release_write) \
       || !defined(AO_HAVE_char_and_write)
      MISSING(AO_char_and);
#   endif
    b &= 57;
# endif
# if defined(AO_HAVE_char_fetch_compare_and_swap_acquire_read)
    TA_assert(AO_char_fetch_compare_and_swap_acquire_read(&b, 14, 117) == 25);
    TA_assert(b == 25);
    TA_assert(AO_char_fetch_compare_and_swap_acquire_read(&b, 25, 117) == 25);
# else
    MISSING(AO_char_fetch_compare_and_swap);
    if (b == 25) b = 117;
# endif
  TA_assert(b == 117);
# if defined(AO_HAVE_int_compare_and_swap_acquire_read)
    TA_assert(!AO_int_compare_and_swap_acquire_read(&zz, 14, 42));
    TA_assert(zz == 13);
    TA_assert(AO_int_compare_and_swap_acquire_read(&zz, 13, 42));
    TA_assert(zz == 42);
# else
    MISSING(AO_int_compare_and_swap);
    if (*(volatile int *)&zz == 13) zz = 42;
# endif
# if defined(AO_HAVE_int_or_acquire_read)
    AO_int_or_acquire_read(&zz, 66);
    TA_assert(zz == 106);
# else
#   if !defined(AO_HAVE_int_or) || !defined(AO_HAVE_int_or_acquire) \
       || !defined(AO_HAVE_int_or_acquire_read) \
       || !defined(AO_HAVE_int_or_full) || !defined(AO_HAVE_int_or_read) \
       || !defined(AO_HAVE_int_or_release) \
       || !defined(AO_HAVE_int_or_release_write) \
       || !defined(AO_HAVE_int_or_write)
      MISSING(AO_int_or);
#   endif
    zz |= 66;
# endif
# if defined(AO_HAVE_int_xor_acquire_read)
    AO_int_xor_acquire_read(&zz, 181);
    TA_assert(zz == 223);
# else
#   if !defined(AO_HAVE_int_xor) || !defined(AO_HAVE_int_xor_acquire) \
       || !defined(AO_HAVE_int_xor_acquire_read) \
       || !defined(AO_HAVE_int_xor_full) || !defined(AO_HAVE_int_xor_read) \
       || !defined(AO_HAVE_int_xor_release) \
       || !defined(AO_HAVE_int_xor_release_write) \
       || !defined(AO_HAVE_int_xor_write)
      MISSING(AO_int_xor);
#   endif
    zz ^= 181;
# endif
# if defined(AO_HAVE_int_and_acquire_read)
    AO_int_and_acquire_read(&zz, 57);
    TA_assert(zz == 25);
# else
#   if !defined(AO_HAVE_int_and) || !defined(AO_HAVE_int_and_acquire) \
       || !defined(AO_HAVE_int_and_acquire_read) \
       || !defined(AO_HAVE_int_and_full) || !defined(AO_HAVE_int_and_read) \
       || !defined(AO_HAVE_int_and_release) \
       || !defined(AO_HAVE_int_and_release_write) \
       || !defined(AO_HAVE_int_and_write)
      MISSING(AO_int_and);
#   endif
    zz &= 57;
# endif
# if defined(AO_HAVE_int_fetch_compare_and_swap_acquire_read)
    TA_assert(AO_int_fetch_compare_and_swap_acquire_read(&zz, 14, 117) == 25);
    TA_assert(zz == 25);
    TA_assert(AO_int_fetch_compare_and_swap_acquire_read(&zz, 25, 117) == 25);
# else
    MISSING(AO_int_fetch_compare_and_swap);
    if (zz == 25) zz = 117;
# endif
  TA_assert(zz == 117);
# if defined(AO_HAVE_double_load_acquire_read) || defined(AO_HAVE_double_store_acquire_read)
    /* Initialize old_w even for store to workaround MSan warning.      */
    old_w.AO_val1 = 3316;
    old_w.AO_val2 = 2921;
# endif
# if defined(AO_HAVE_double_load_acquire_read)
    new_w = AO_double_load_acquire_read(&old_w);
    TA_assert(new_w.AO_val1 == 3316 && new_w.AO_val2 == 2921);
# elif !defined(AO_HAVE_double_load) \
       || !defined(AO_HAVE_double_load_acquire) \
       || !defined(AO_HAVE_double_load_acquire_read) \
       || !defined(AO_HAVE_double_load_dd_acquire_read) \
       || !defined(AO_HAVE_double_load_full) \
       || !defined(AO_HAVE_double_load_read)
    MISSING(AO_double_load);
# endif
# if defined(AO_HAVE_double_store_acquire_read)
    new_w.AO_val1 = 1375;
    new_w.AO_val2 = 8243;
    AO_double_store_acquire_read(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    AO_double_store_acquire_read(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    new_w.AO_val1 ^= old_w.AO_val1;
    new_w.AO_val2 ^= old_w.AO_val2;
    AO_double_store_acquire_read(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 0 && old_w.AO_val2 == 0);
# elif !defined(AO_HAVE_double_store) \
       || !defined(AO_HAVE_double_store_full) \
       || !defined(AO_HAVE_double_store_release) \
       || !defined(AO_HAVE_double_store_release_write) \
       || !defined(AO_HAVE_double_store_write)
    MISSING(AO_double_store);
# endif
# if defined(AO_HAVE_compare_double_and_swap_double_acquire_read)
    TA_assert(!AO_compare_double_and_swap_double_acquire_read(&w, 17, 42, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_double_and_swap_double_acquire_read(&w, 0, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_acquire_read(&w, 12, 14, 64, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_acquire_read(&w, 11, 13, 85, 82));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_acquire_read(&w, 13, 12, 17, 42));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_double_and_swap_double_acquire_read(&w, 12, 13, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_double_and_swap_double_acquire_read(&w, 17, 42, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_double_and_swap_double);
# endif
# if defined(AO_HAVE_compare_and_swap_double_acquire_read)
    TA_assert(!AO_compare_and_swap_double_acquire_read(&w, 17, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_and_swap_double_acquire_read(&w, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_acquire_read(&w, 13, 12, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_acquire_read(&w, 1213, 48, 86));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_and_swap_double_acquire_read(&w, 12, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_and_swap_double_acquire_read(&w, 17, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_and_swap_double);
# endif
# if defined(AO_HAVE_double_compare_and_swap_acquire_read)
    old_w.AO_val1 = 4116;
    old_w.AO_val2 = 2121;
    new_w.AO_val1 = 8537;
    new_w.AO_val2 = 6410;
    TA_assert(!AO_double_compare_and_swap_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_double_compare_and_swap_acquire_read(&w, w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = 29;
    new_w.AO_val1 = 820;
    new_w.AO_val2 = 5917;
    TA_assert(!AO_double_compare_and_swap_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = 11;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 3552;
    new_w.AO_val2 = 1746;
    TA_assert(!AO_double_compare_and_swap_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 8537;
    new_w.AO_val1 = 4116;
    new_w.AO_val2 = 2121;
    TA_assert(!AO_double_compare_and_swap_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 1;
    TA_assert(AO_double_compare_and_swap_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 1 && w.AO_val2 == 2121);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = w.AO_val2;
    new_w.AO_val1--;
    new_w.AO_val2 = 0;
    TA_assert(AO_double_compare_and_swap_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_double_compare_and_swap);
# endif
}
/*
 * Copyright (c) 2003 by Hewlett-Packard Company.  All rights reserved.
 *
 * This file is covered by the GNU general public license, version 2.
 * see COPYING for details.
 */

/* Some basic sanity tests.  These do not test the barrier semantics. */

#undef TA_assert
#define TA_assert(e) \
  if (!(e)) { fprintf(stderr, "Assertion failed %s:%d (barrier: _dd_acquire_read)\n", \
                    __FILE__, __LINE__), exit(1); }

#undef MISSING
#define MISSING(name) \
  printf("Missing: %s\n", #name "_dd_acquire_read")

#if defined(CPPCHECK)
  void list_atomic_dd_acquire_read(void);
  void char_list_atomic_dd_acquire_read(void);
  void short_list_atomic_dd_acquire_read(void);
  void int_list_atomic_dd_acquire_read(void);
  void double_list_atomic_dd_acquire_read(void);
#endif

void test_atomic_dd_acquire_read(void)
{
  AO_t x;
  unsigned char b;
  unsigned short s;
  unsigned int zz;
# if defined(AO_HAVE_test_and_set_dd_acquire_read)
    AO_TS_t z = AO_TS_INITIALIZER;
# endif
# if defined(AO_HAVE_double_compare_and_swap_dd_acquire_read) \
     || defined(AO_HAVE_double_load_dd_acquire_read) \
     || defined(AO_HAVE_double_store_dd_acquire_read)
    static AO_double_t old_w; /* static to avoid misalignment */
    AO_double_t new_w;
# endif
# if defined(AO_HAVE_compare_and_swap_double_dd_acquire_read) \
     || defined(AO_HAVE_compare_double_and_swap_double_dd_acquire_read) \
     || defined(AO_HAVE_double_compare_and_swap_dd_acquire_read)
    static AO_double_t w; /* static to avoid misalignment */
    w.AO_val1 = 0;
    w.AO_val2 = 0;
# endif

# if defined(CPPCHECK)
    list_atomic_dd_acquire_read();
    char_list_atomic_dd_acquire_read();
    short_list_atomic_dd_acquire_read();
    int_list_atomic_dd_acquire_read();
    double_list_atomic_dd_acquire_read();
# endif
# if defined(AO_HAVE_nop_dd_acquire_read)
    AO_nop_dd_acquire_read();
# elif !defined(AO_HAVE_nop) || !defined(AO_HAVE_nop_full) \
       || !defined(AO_HAVE_nop_read) || !defined(AO_HAVE_nop_write)
    MISSING(AO_nop);
# endif
# if defined(AO_HAVE_store_dd_acquire_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile AO_t *)&x = 0; /* initialize to avoid false warning */
#   endif
    AO_store_dd_acquire_read(&x, 13);
    TA_assert(x == 13);
# else
#   if !defined(AO_HAVE_store) || !defined(AO_HAVE_store_full) \
       || !defined(AO_HAVE_store_release) \
       || !defined(AO_HAVE_store_release_write) \
       || !defined(AO_HAVE_store_write)
      MISSING(AO_store);
#   endif
    x = 13;
# endif
# if defined(AO_HAVE_load_dd_acquire_read)
    TA_assert(AO_load_dd_acquire_read(&x) == 13);
# elif !defined(AO_HAVE_load) || !defined(AO_HAVE_load_acquire) \
       || !defined(AO_HAVE_load_acquire_read) \
       || !defined(AO_HAVE_load_dd_acquire_read) \
       || !defined(AO_HAVE_load_full) || !defined(AO_HAVE_load_read)
    MISSING(AO_load);
# endif
# if defined(AO_HAVE_test_and_set_dd_acquire_read)
    TA_assert(AO_test_and_set_dd_acquire_read(&z) == AO_TS_CLEAR);
    TA_assert(AO_test_and_set_dd_acquire_read(&z) == AO_TS_SET);
    TA_assert(AO_test_and_set_dd_acquire_read(&z) == AO_TS_SET);
    AO_CLEAR(&z);
# else
    MISSING(AO_test_and_set);
# endif
# if defined(AO_HAVE_fetch_and_add_dd_acquire_read)
    TA_assert(AO_fetch_and_add_dd_acquire_read(&x, 42) == 13);
    TA_assert(AO_fetch_and_add_dd_acquire_read(&x, (AO_t)(-42)) == 55);
# else
    MISSING(AO_fetch_and_add);
# endif
# if defined(AO_HAVE_fetch_and_add1_dd_acquire_read)
    TA_assert(AO_fetch_and_add1_dd_acquire_read(&x) == 13);
# else
    MISSING(AO_fetch_and_add1);
    ++x;
# endif
# if defined(AO_HAVE_fetch_and_sub1_dd_acquire_read)
    TA_assert(AO_fetch_and_sub1_dd_acquire_read(&x) == 14);
# else
    MISSING(AO_fetch_and_sub1);
    --x;
# endif
# if defined(AO_HAVE_short_store_dd_acquire_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile short *)&s = 0;
#   endif
    AO_short_store_dd_acquire_read(&s, 13);
# else
#   if !defined(AO_HAVE_short_store) || !defined(AO_HAVE_short_store_full) \
       || !defined(AO_HAVE_short_store_release) \
       || !defined(AO_HAVE_short_store_release_write) \
       || !defined(AO_HAVE_short_store_write)
      MISSING(AO_short_store);
#   endif
    s = 13;
# endif
# if defined(AO_HAVE_short_load_dd_acquire_read)
    TA_assert(AO_short_load(&s) == 13);
# elif !defined(AO_HAVE_short_load) || !defined(AO_HAVE_short_load_acquire) \
       || !defined(AO_HAVE_short_load_acquire_read) \
       || !defined(AO_HAVE_short_load_dd_acquire_read) \
       || !defined(AO_HAVE_short_load_full) \
       || !defined(AO_HAVE_short_load_read)
    MISSING(AO_short_load);
# endif
# if defined(AO_HAVE_short_fetch_and_add_dd_acquire_read)
    TA_assert(AO_short_fetch_and_add_dd_acquire_read(&s, 42) == 13);
    TA_assert(AO_short_fetch_and_add_dd_acquire_read(&s, (unsigned short)-42) == 55);
# else
    MISSING(AO_short_fetch_and_add);
# endif
# if defined(AO_HAVE_short_fetch_and_add1_dd_acquire_read)
    TA_assert(AO_short_fetch_and_add1_dd_acquire_read(&s) == 13);
# else
    MISSING(AO_short_fetch_and_add1);
    ++s;
# endif
# if defined(AO_HAVE_short_fetch_and_sub1_dd_acquire_read)
    TA_assert(AO_short_fetch_and_sub1_dd_acquire_read(&s) == 14);
# else
    MISSING(AO_short_fetch_and_sub1);
    --s;
# endif
  TA_assert(*(volatile short *)&s == 13);
# if defined(AO_HAVE_char_store_dd_acquire_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile char *)&b = 0;
#   endif
    AO_char_store_dd_acquire_read(&b, 13);
# else
#   if !defined(AO_HAVE_char_store) || !defined(AO_HAVE_char_store_full) \
       || !defined(AO_HAVE_char_store_release) \
       || !defined(AO_HAVE_char_store_release_write) \
       || !defined(AO_HAVE_char_store_write)
      MISSING(AO_char_store);
#   endif
    b = 13;
# endif
# if defined(AO_HAVE_char_load_dd_acquire_read)
    TA_assert(AO_char_load(&b) == 13);
# elif !defined(AO_HAVE_char_load) || !defined(AO_HAVE_char_load_acquire) \
       || !defined(AO_HAVE_char_load_acquire_read) \
       || !defined(AO_HAVE_char_load_dd_acquire_read) \
       || !defined(AO_HAVE_char_load_full) || !defined(AO_HAVE_char_load_read)
    MISSING(AO_char_load);
# endif
# if defined(AO_HAVE_char_fetch_and_add_dd_acquire_read)
    TA_assert(AO_char_fetch_and_add_dd_acquire_read(&b, 42) == 13);
    TA_assert(AO_char_fetch_and_add_dd_acquire_read(&b, (unsigned char)-42) == 55);
# else
    MISSING(AO_char_fetch_and_add);
# endif
# if defined(AO_HAVE_char_fetch_and_add1_dd_acquire_read)
    TA_assert(AO_char_fetch_and_add1_dd_acquire_read(&b) == 13);
# else
    MISSING(AO_char_fetch_and_add1);
    ++b;
# endif
# if defined(AO_HAVE_char_fetch_and_sub1_dd_acquire_read)
    TA_assert(AO_char_fetch_and_sub1_dd_acquire_read(&b) == 14);
# else
    MISSING(AO_char_fetch_and_sub1);
    --b;
# endif
  TA_assert(*(volatile char *)&b == 13);
# if defined(AO_HAVE_int_store_dd_acquire_read)
#   if (defined(AO_MEMORY_SANITIZER) || defined(LINT2)) \
       && defined(AO_PREFER_GENERALIZED)
      *(volatile int *)&zz = 0;
#   endif
    AO_int_store_dd_acquire_read(&zz, 13);
# else
#   if !defined(AO_HAVE_int_store) || !defined(AO_HAVE_int_store_full) \
       || !defined(AO_HAVE_int_store_release) \
       || !defined(AO_HAVE_int_store_release_write) \
       || !defined(AO_HAVE_int_store_write)
      MISSING(AO_int_store);
#   endif
    zz = 13;
# endif
# if defined(AO_HAVE_int_load_dd_acquire_read)
    TA_assert(AO_int_load(&zz) == 13);
# elif !defined(AO_HAVE_int_load) || !defined(AO_HAVE_int_load_acquire) \
       || !defined(AO_HAVE_int_load_acquire_read) \
       || !defined(AO_HAVE_int_load_dd_acquire_read) \
       || !defined(AO_HAVE_int_load_full) || !defined(AO_HAVE_int_load_read)
    MISSING(AO_int_load);
# endif
# if defined(AO_HAVE_int_fetch_and_add_dd_acquire_read)
    TA_assert(AO_int_fetch_and_add_dd_acquire_read(&zz, 42) == 13);
    TA_assert(AO_int_fetch_and_add_dd_acquire_read(&zz, (unsigned int)-42) == 55);
# else
    MISSING(AO_int_fetch_and_add);
# endif
# if defined(AO_HAVE_int_fetch_and_add1_dd_acquire_read)
    TA_assert(AO_int_fetch_and_add1_dd_acquire_read(&zz) == 13);
# else
    MISSING(AO_int_fetch_and_add1);
    ++zz;
# endif
# if defined(AO_HAVE_int_fetch_and_sub1_dd_acquire_read)
    TA_assert(AO_int_fetch_and_sub1_dd_acquire_read(&zz) == 14);
# else
    MISSING(AO_int_fetch_and_sub1);
    --zz;
# endif
  TA_assert(*(volatile int *)&zz == 13);
# if defined(AO_HAVE_compare_and_swap_dd_acquire_read)
    TA_assert(!AO_compare_and_swap_dd_acquire_read(&x, 14, 42));
    TA_assert(x == 13);
    TA_assert(AO_compare_and_swap_dd_acquire_read(&x, 13, 42));
    TA_assert(x == 42);
# else
    MISSING(AO_compare_and_swap);
    if (*(volatile AO_t *)&x == 13) x = 42;
# endif
# if defined(AO_HAVE_or_dd_acquire_read)
    AO_or_dd_acquire_read(&x, 66);
    TA_assert(x == 106);
# else
#   if !defined(AO_HAVE_or) || !defined(AO_HAVE_or_acquire) \
       || !defined(AO_HAVE_or_acquire_read) || !defined(AO_HAVE_or_full) \
       || !defined(AO_HAVE_or_read) || !defined(AO_HAVE_or_release) \
       || !defined(AO_HAVE_or_release_write) || !defined(AO_HAVE_or_write)
      MISSING(AO_or);
#   endif
    x |= 66;
# endif
# if defined(AO_HAVE_xor_dd_acquire_read)
    AO_xor_dd_acquire_read(&x, 181);
    TA_assert(x == 223);
# else
#   if !defined(AO_HAVE_xor) || !defined(AO_HAVE_xor_acquire) \
       || !defined(AO_HAVE_xor_acquire_read) || !defined(AO_HAVE_xor_full) \
       || !defined(AO_HAVE_xor_read) || !defined(AO_HAVE_xor_release) \
       || !defined(AO_HAVE_xor_release_write) || !defined(AO_HAVE_xor_write)
      MISSING(AO_xor);
#   endif
    x ^= 181;
# endif
# if defined(AO_HAVE_and_dd_acquire_read)
    AO_and_dd_acquire_read(&x, 57);
    TA_assert(x == 25);
# else
#   if !defined(AO_HAVE_and) || !defined(AO_HAVE_and_acquire) \
       || !defined(AO_HAVE_and_acquire_read) || !defined(AO_HAVE_and_full) \
       || !defined(AO_HAVE_and_read) || !defined(AO_HAVE_and_release) \
       || !defined(AO_HAVE_and_release_write) || !defined(AO_HAVE_and_write)
      MISSING(AO_and);
#   endif
    x &= 57;
# endif
# if defined(AO_HAVE_fetch_compare_and_swap_dd_acquire_read)
    TA_assert(AO_fetch_compare_and_swap_dd_acquire_read(&x, 14, 117) == 25);
    TA_assert(x == 25);
    TA_assert(AO_fetch_compare_and_swap_dd_acquire_read(&x, 25, 117) == 25);
# else
    MISSING(AO_fetch_compare_and_swap);
    if (x == 25) x = 117;
# endif
  TA_assert(x == 117);
# if defined(AO_HAVE_short_compare_and_swap_dd_acquire_read)
    TA_assert(!AO_short_compare_and_swap_dd_acquire_read(&s, 14, 42));
    TA_assert(s == 13);
    TA_assert(AO_short_compare_and_swap_dd_acquire_read(&s, 13, 42));
    TA_assert(s == 42);
# else
    MISSING(AO_short_compare_and_swap);
    if (*(volatile short *)&s == 13) s = 42;
# endif
# if defined(AO_HAVE_short_or_dd_acquire_read)
    AO_short_or_dd_acquire_read(&s, 66);
    TA_assert(s == 106);
# else
#   if !defined(AO_HAVE_short_or) || !defined(AO_HAVE_short_or_acquire) \
       || !defined(AO_HAVE_short_or_acquire_read) \
       || !defined(AO_HAVE_short_or_full) || !defined(AO_HAVE_short_or_read) \
       || !defined(AO_HAVE_short_or_release) \
       || !defined(AO_HAVE_short_or_release_write) \
       || !defined(AO_HAVE_short_or_write)
      MISSING(AO_short_or);
#   endif
    s |= 66;
# endif
# if defined(AO_HAVE_short_xor_dd_acquire_read)
    AO_short_xor_dd_acquire_read(&s, 181);
    TA_assert(s == 223);
# else
#   if !defined(AO_HAVE_short_xor) || !defined(AO_HAVE_short_xor_acquire) \
       || !defined(AO_HAVE_short_xor_acquire_read) \
       || !defined(AO_HAVE_short_xor_full) \
       || !defined(AO_HAVE_short_xor_read) \
       || !defined(AO_HAVE_short_xor_release) \
       || !defined(AO_HAVE_short_xor_release_write) \
       || !defined(AO_HAVE_short_xor_write)
      MISSING(AO_short_xor);
#   endif
    s ^= 181;
# endif
# if defined(AO_HAVE_short_and_dd_acquire_read)
    AO_short_and_dd_acquire_read(&s, 57);
    TA_assert(s == 25);
# else
#   if !defined(AO_HAVE_short_and) || !defined(AO_HAVE_short_and_acquire) \
       || !defined(AO_HAVE_short_and_acquire_read) \
       || !defined(AO_HAVE_short_and_full) \
       || !defined(AO_HAVE_short_and_read) \
       || !defined(AO_HAVE_short_and_release) \
       || !defined(AO_HAVE_short_and_release_write) \
       || !defined(AO_HAVE_short_and_write)
      MISSING(AO_short_and);
#   endif
    s &= 57;
# endif
# if defined(AO_HAVE_short_fetch_compare_and_swap_dd_acquire_read)
    TA_assert(AO_short_fetch_compare_and_swap_dd_acquire_read(&s, 14, 117) == 25);
    TA_assert(s == 25);
    TA_assert(AO_short_fetch_compare_and_swap_dd_acquire_read(&s, 25, 117) == 25);
# else
    MISSING(AO_short_fetch_compare_and_swap);
    if (s == 25) s = 117;
# endif
  TA_assert(s == 117);
# if defined(AO_HAVE_char_compare_and_swap_dd_acquire_read)
    TA_assert(!AO_char_compare_and_swap_dd_acquire_read(&b, 14, 42));
    TA_assert(b == 13);
    TA_assert(AO_char_compare_and_swap_dd_acquire_read(&b, 13, 42));
    TA_assert(b == 42);
# else
    MISSING(AO_char_compare_and_swap);
    if (*(volatile char *)&b == 13) b = 42;
# endif
# if defined(AO_HAVE_char_or_dd_acquire_read)
    AO_char_or_dd_acquire_read(&b, 66);
    TA_assert(b == 106);
# else
#   if !defined(AO_HAVE_char_or) || !defined(AO_HAVE_char_or_acquire) \
       || !defined(AO_HAVE_char_or_acquire_read) \
       || !defined(AO_HAVE_char_or_full) || !defined(AO_HAVE_char_or_read) \
       || !defined(AO_HAVE_char_or_release) \
       || !defined(AO_HAVE_char_or_release_write) \
       || !defined(AO_HAVE_char_or_write)
      MISSING(AO_char_or);
#   endif
    b |= 66;
# endif
# if defined(AO_HAVE_char_xor_dd_acquire_read)
    AO_char_xor_dd_acquire_read(&b, 181);
    TA_assert(b == 223);
# else
#   if !defined(AO_HAVE_char_xor) || !defined(AO_HAVE_char_xor_acquire) \
       || !defined(AO_HAVE_char_xor_acquire_read) \
       || !defined(AO_HAVE_char_xor_full) || !defined(AO_HAVE_char_xor_read) \
       || !defined(AO_HAVE_char_xor_release) \
       || !defined(AO_HAVE_char_xor_release_write) \
       || !defined(AO_HAVE_char_xor_write)
      MISSING(AO_char_xor);
#   endif
    b ^= 181;
# endif
# if defined(AO_HAVE_char_and_dd_acquire_read)
    AO_char_and_dd_acquire_read(&b, 57);
    TA_assert(b == 25);
# else
#   if !defined(AO_HAVE_char_and) || !defined(AO_HAVE_char_and_acquire) \
       || !defined(AO_HAVE_char_and_acquire_read) \
       || !defined(AO_HAVE_char_and_full) || !defined(AO_HAVE_char_and_read) \
       || !defined(AO_HAVE_char_and_release) \
       || !defined(AO_HAVE_char_and_release_write) \
       || !defined(AO_HAVE_char_and_write)
      MISSING(AO_char_and);
#   endif
    b &= 57;
# endif
# if defined(AO_HAVE_char_fetch_compare_and_swap_dd_acquire_read)
    TA_assert(AO_char_fetch_compare_and_swap_dd_acquire_read(&b, 14, 117) == 25);
    TA_assert(b == 25);
    TA_assert(AO_char_fetch_compare_and_swap_dd_acquire_read(&b, 25, 117) == 25);
# else
    MISSING(AO_char_fetch_compare_and_swap);
    if (b == 25) b = 117;
# endif
  TA_assert(b == 117);
# if defined(AO_HAVE_int_compare_and_swap_dd_acquire_read)
    TA_assert(!AO_int_compare_and_swap_dd_acquire_read(&zz, 14, 42));
    TA_assert(zz == 13);
    TA_assert(AO_int_compare_and_swap_dd_acquire_read(&zz, 13, 42));
    TA_assert(zz == 42);
# else
    MISSING(AO_int_compare_and_swap);
    if (*(volatile int *)&zz == 13) zz = 42;
# endif
# if defined(AO_HAVE_int_or_dd_acquire_read)
    AO_int_or_dd_acquire_read(&zz, 66);
    TA_assert(zz == 106);
# else
#   if !defined(AO_HAVE_int_or) || !defined(AO_HAVE_int_or_acquire) \
       || !defined(AO_HAVE_int_or_acquire_read) \
       || !defined(AO_HAVE_int_or_full) || !defined(AO_HAVE_int_or_read) \
       || !defined(AO_HAVE_int_or_release) \
       || !defined(AO_HAVE_int_or_release_write) \
       || !defined(AO_HAVE_int_or_write)
      MISSING(AO_int_or);
#   endif
    zz |= 66;
# endif
# if defined(AO_HAVE_int_xor_dd_acquire_read)
    AO_int_xor_dd_acquire_read(&zz, 181);
    TA_assert(zz == 223);
# else
#   if !defined(AO_HAVE_int_xor) || !defined(AO_HAVE_int_xor_acquire) \
       || !defined(AO_HAVE_int_xor_acquire_read) \
       || !defined(AO_HAVE_int_xor_full) || !defined(AO_HAVE_int_xor_read) \
       || !defined(AO_HAVE_int_xor_release) \
       || !defined(AO_HAVE_int_xor_release_write) \
       || !defined(AO_HAVE_int_xor_write)
      MISSING(AO_int_xor);
#   endif
    zz ^= 181;
# endif
# if defined(AO_HAVE_int_and_dd_acquire_read)
    AO_int_and_dd_acquire_read(&zz, 57);
    TA_assert(zz == 25);
# else
#   if !defined(AO_HAVE_int_and) || !defined(AO_HAVE_int_and_acquire) \
       || !defined(AO_HAVE_int_and_acquire_read) \
       || !defined(AO_HAVE_int_and_full) || !defined(AO_HAVE_int_and_read) \
       || !defined(AO_HAVE_int_and_release) \
       || !defined(AO_HAVE_int_and_release_write) \
       || !defined(AO_HAVE_int_and_write)
      MISSING(AO_int_and);
#   endif
    zz &= 57;
# endif
# if defined(AO_HAVE_int_fetch_compare_and_swap_dd_acquire_read)
    TA_assert(AO_int_fetch_compare_and_swap_dd_acquire_read(&zz, 14, 117) == 25);
    TA_assert(zz == 25);
    TA_assert(AO_int_fetch_compare_and_swap_dd_acquire_read(&zz, 25, 117) == 25);
# else
    MISSING(AO_int_fetch_compare_and_swap);
    if (zz == 25) zz = 117;
# endif
  TA_assert(zz == 117);
# if defined(AO_HAVE_double_load_dd_acquire_read) || defined(AO_HAVE_double_store_dd_acquire_read)
    /* Initialize old_w even for store to workaround MSan warning.      */
    old_w.AO_val1 = 3316;
    old_w.AO_val2 = 2921;
# endif
# if defined(AO_HAVE_double_load_dd_acquire_read)
    new_w = AO_double_load_dd_acquire_read(&old_w);
    TA_assert(new_w.AO_val1 == 3316 && new_w.AO_val2 == 2921);
# elif !defined(AO_HAVE_double_load) \
       || !defined(AO_HAVE_double_load_acquire) \
       || !defined(AO_HAVE_double_load_acquire_read) \
       || !defined(AO_HAVE_double_load_dd_acquire_read) \
       || !defined(AO_HAVE_double_load_full) \
       || !defined(AO_HAVE_double_load_read)
    MISSING(AO_double_load);
# endif
# if defined(AO_HAVE_double_store_dd_acquire_read)
    new_w.AO_val1 = 1375;
    new_w.AO_val2 = 8243;
    AO_double_store_dd_acquire_read(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    AO_double_store_dd_acquire_read(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 1375 && old_w.AO_val2 == 8243);
    new_w.AO_val1 ^= old_w.AO_val1;
    new_w.AO_val2 ^= old_w.AO_val2;
    AO_double_store_dd_acquire_read(&old_w, new_w);
    TA_assert(old_w.AO_val1 == 0 && old_w.AO_val2 == 0);
# elif !defined(AO_HAVE_double_store) \
       || !defined(AO_HAVE_double_store_full) \
       || !defined(AO_HAVE_double_store_release) \
       || !defined(AO_HAVE_double_store_release_write) \
       || !defined(AO_HAVE_double_store_write)
    MISSING(AO_double_store);
# endif
# if defined(AO_HAVE_compare_double_and_swap_double_dd_acquire_read)
    TA_assert(!AO_compare_double_and_swap_double_dd_acquire_read(&w, 17, 42, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_double_and_swap_double_dd_acquire_read(&w, 0, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_dd_acquire_read(&w, 12, 14, 64, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_dd_acquire_read(&w, 11, 13, 85, 82));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_double_and_swap_double_dd_acquire_read(&w, 13, 12, 17, 42));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_double_and_swap_double_dd_acquire_read(&w, 12, 13, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_double_and_swap_double_dd_acquire_read(&w, 17, 42, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_double_and_swap_double);
# endif
# if defined(AO_HAVE_compare_and_swap_double_dd_acquire_read)
    TA_assert(!AO_compare_and_swap_double_dd_acquire_read(&w, 17, 12, 13));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_compare_and_swap_double_dd_acquire_read(&w, 0, 12, 13));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_dd_acquire_read(&w, 13, 12, 33));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(!AO_compare_and_swap_double_dd_acquire_read(&w, 1213, 48, 86));
    TA_assert(w.AO_val1 == 12 && w.AO_val2 == 13);
    TA_assert(AO_compare_and_swap_double_dd_acquire_read(&w, 12, 17, 42));
    TA_assert(w.AO_val1 == 17 && w.AO_val2 == 42);
    TA_assert(AO_compare_and_swap_double_dd_acquire_read(&w, 17, 0, 0));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_compare_and_swap_double);
# endif
# if defined(AO_HAVE_double_compare_and_swap_dd_acquire_read)
    old_w.AO_val1 = 4116;
    old_w.AO_val2 = 2121;
    new_w.AO_val1 = 8537;
    new_w.AO_val2 = 6410;
    TA_assert(!AO_double_compare_and_swap_dd_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
    TA_assert(AO_double_compare_and_swap_dd_acquire_read(&w, w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = 29;
    new_w.AO_val1 = 820;
    new_w.AO_val2 = 5917;
    TA_assert(!AO_double_compare_and_swap_dd_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = 11;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 3552;
    new_w.AO_val2 = 1746;
    TA_assert(!AO_double_compare_and_swap_dd_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 8537;
    new_w.AO_val1 = 4116;
    new_w.AO_val2 = 2121;
    TA_assert(!AO_double_compare_and_swap_dd_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 8537 && w.AO_val2 == 6410);
    old_w.AO_val1 = old_w.AO_val2;
    old_w.AO_val2 = 6410;
    new_w.AO_val1 = 1;
    TA_assert(AO_double_compare_and_swap_dd_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 1 && w.AO_val2 == 2121);
    old_w.AO_val1 = new_w.AO_val1;
    old_w.AO_val2 = w.AO_val2;
    new_w.AO_val1--;
    new_w.AO_val2 = 0;
    TA_assert(AO_double_compare_and_swap_dd_acquire_read(&w, old_w, new_w));
    TA_assert(w.AO_val1 == 0 && w.AO_val2 == 0);
# else
    MISSING(AO_double_compare_and_swap);
# endif
}
