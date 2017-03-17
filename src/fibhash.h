#ifndef GAP_FIBHASH_H
#define GAP_FIBHASH_H

#include <src/config.h>

#if !defined(SIZEOF_VOID_P) && !defined(USE_PRECOMPILED)
#error Require SIZEOF_VOID_P to be defined
#endif

#if SIZEOF_VOID_P == 4
#define FIB_HASH_MULT 0x9e3779b9UL
#else
#define FIB_HASH_MULT 0x9e3779b97f4a7c13UL
#endif

#define FIB_HASH_BITS (SIZEOF_VOID_P * 8)

static inline UInt FibHash(UInt word, unsigned bits)
{
  return (word * FIB_HASH_MULT) >>
    (FIB_HASH_BITS - bits);
}

#endif // GAP_FIBHASH_H
