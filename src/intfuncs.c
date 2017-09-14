/****************************************************************************
**
*W  infuncs.c                   GAP source                   Martin Schönert
**                                                           & Alice Niemeyer
**                                                           & Werner  Nickel
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
** This file contains integer related functions which are independent of the
** large integer representation in use. See gmpints.c for other things.
*/


#include <src/system.h>                 /* Ints, UInts */


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */

#include <src/ariths.h>                 /* basic arithmetic */

#include <src/bool.h>                   /* booleans */

#include <src/intfuncs.h>               /* integers */

#include <src/gmpints.h>

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/stringobj.h>              /* strings */

#include <src/saveload.h>               /* saving and loading */

#include <src/code.h>                   /* coder */


#include <stdio.h>


/****************************************************************************
**
*F  FuncSIZE_OBJ(<self>,<obj>)
**
**  'SIZE_OBJ( <obj> )' returns the size of a nonimmediate object. It can be
**  used to debug memory use.
*/
Obj             FuncSIZE_OBJ (
    Obj                 self,
    Obj                 a)
{
  return INTOBJ_INT(SIZE_OBJ(a));
}


/****************************************************************************
**
** * * * * * * * "Mersenne twister" random numbers  * * * * * * * * * * * * *
**
**  Part of this code for fast generation of 32 bit pseudo random numbers with
**  a period of length 2^19937-1 and a 623-dimensional equidistribution is
**  taken from:
**          http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
**  (Also look in Wikipedia for "Mersenne twister".)
**  We use the file mt19937ar.c, version 2002/1/26.
*/

/****************************************************************************
**
*F  InitRandomMT( <initstr> )
**
**  Returns a string that can be used as data structure of a new MT random
**  number generator. <initstr> can be an arbitrary string as seed.
*/
#define MATRIX_A 0x9908b0dfUL   /* constant vector a */
#define UPPER_MASK 0x80000000UL /* most significant w-r bits */
#define LOWER_MASK 0x7fffffffUL /* least significant r bits */

void initGRMT(UInt4 *mt, UInt4 s)
{
    UInt4 mti;
    mt[0]= s & 0xffffffffUL;
    for (mti=1; mti<624; mti++) {
        mt[mti] =
	    (1812433253UL * (mt[mti-1] ^ (mt[mti-1] >> 30)) + mti);
        mt[mti] &= 0xffffffffUL;
    }
    /* store mti as last entry of mt[] */
    mt[624] = mti;
}

/* to read a seed string independently of endianness */
static inline UInt4 uint4frombytes(UChar *s)
{
  UInt4 res;
  res = s[3]; res <<= 8;
  res += s[2]; res <<= 8;
  res += s[1]; res <<= 8;
  res += s[0];
  return res;
}

Obj FuncInitRandomMT( Obj self, Obj initstr)
{
  Obj str;
  UChar *init_key;
  UInt4 *mt, key_length, i, j, k, N=624;

  /* check the seed, given as string */
  while (! IsStringConv(initstr)) {
     initstr = ErrorReturnObj(
         "<initstr> must be a string, not a %s)",
         (Int)TNAM_OBJ(initstr), 0L,
         "you can replace <initstr> via 'return <initstr>;'" );
  }

  /* store array of 624 UInt4 and one UInt4 as counter "mti" and an
     endianness marker */
  str = NEW_STRING(4*626);
  SET_LEN_STRING(str, 4*626);
  mt = (UInt4*) CHARS_STRING(str);
  /* here the counter mti is set to 624 */
  initGRMT(mt, 19650218UL);
  i=1; j=0;
  /* Do not set these up until all garbage collection is done   */
  init_key = CHARS_STRING(initstr);
  key_length = GET_LEN_STRING(initstr) / 4;
  k = (N>key_length ? N : key_length);
  for (; k; k--) {
      mt[i] = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1664525UL))
        + uint4frombytes(init_key+4*j) + j;
      mt[i] &= 0xffffffffUL;
      i++; j++;
      if (i>=N) { mt[0] = mt[N-1]; i=1; }
      if (j>=key_length) j=0;
  }
  for (k=N-1; k; k--) {
      mt[i] = (mt[i] ^ ((mt[i-1] ^ (mt[i-1] >> 30)) * 1566083941UL)) - i;
      mt[i] &= 0xffffffffUL;
      i++;
      if (i>=N) { mt[0] = mt[N-1]; i=1; }
  }
  mt[0] = 0x80000000UL;
  /* gives string "1234" in little endian as marker */
  mt[625] = 875770417UL;
  return str;
}


/*  internal, generates a random number on [0,0xffffffff]-interval
**  argument <mt> is pointer to a string generated by InitRandomMT
**  (the first 4*624 bytes are the random numbers, the last 4 bytes contain
**  a counter)
*/
UInt4 nextrandMT_int32(UInt4* mt)
{
    UInt4 mti, y, N=624, M=397;
    static UInt4 mag01[2]={0x0UL, MATRIX_A};

    mti = mt[624];
    if (mti >= N) {
        int kk;

        for (kk=0;kk<N-M;kk++) {
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+M] ^ (y >> 1) ^ mag01[y & 0x1UL];
        }
        for (;kk<N-1;kk++) {
            y = (mt[kk]&UPPER_MASK)|(mt[kk+1]&LOWER_MASK);
            mt[kk] = mt[kk+(M-N)] ^ (y >> 1) ^ mag01[y & 0x1UL];
        }
        y = (mt[N-1]&UPPER_MASK)|(mt[0]&LOWER_MASK);
        mt[N-1] = mt[M-1] ^ (y >> 1) ^ mag01[y & 0x1UL];

        mti = 0;
    }

    y = mt[mti++];
    mt[624] = mti;

    /* Tempering */
    y ^= (y >> 11);
    y ^= (y << 7) & 0x9d2c5680UL;
    y ^= (y << 15) & 0xefc60000UL;
    y ^= (y >> 18);

    return y;
}

/****************************************************************************
**
*F  FuncHASHKEY_BAG(<self>,<obj>,<seed>,<offset>,<maxlen>)
**
**  'FuncHASHKEY_BAG' implements the internal function 'HASHKEY_BAG'.
**
**  'HASHKEY_BAG( <obj>, <seed>, <offset>, <maxlen> )'
**
**  takes a non-immediate object and a small integer <seed> and computes a
**  hash value for the contents of the bag from these. (For this to be
**  usable in algorithms, we need that objects of this kind are stored uniquely
**  internally.
**  The offset and the maximum number of bytes to process both count in
**  bytes. The values passed to these parameters might depend on the word 
**  length of the computer.
**  A <maxlen> value of -1 indicates infinity.
*/


//-----------------------------------------------------------------------------
// MurmurHash3 was written by Austin Appleby, and is placed in the public
// domain. The author hereby disclaims copyright to this source code.

// Note - The x86 and x64 versions do _not_ produce the same results, as the
// algorithms are optimized for their respective platforms. You can still
// compile and run any of them on any platform, but your performance with the
// non-native version will be less than optimal.

//-----------------------------------------------------------------------------
// MurmurHash3 was written by Austin Appleby, and is placed in the public
// domain. The author hereby disclaims copyright to this source code.

/* Minor modifications to get it to compile in C rather than C++ and 
integrate with GAP  SL*/


#define FORCE_INLINE static inline

#ifndef SYS_IS_64_BIT

//-----------------------------------------------------------------------------
// Platform-specific functions and macros

static inline uint32_t rotl32 ( uint32_t x, int8_t r )
{
  return (x << r) | (x >> (32 - r));
}
#define ROTL32(x,y)     rotl32(x,y)

//-----------------------------------------------------------------------------
// Block read - if your platform needs to do endian-swapping or can only
// handle aligned reads, do the conversion here

FORCE_INLINE uint32_t getblock4 ( const uint32_t * p, int i )
{
  return p[i];
}

//-----------------------------------------------------------------------------
// Finalization mix - force all bits of a hash block to avalanche

FORCE_INLINE uint32_t fmix4 ( uint32_t h )
{
  h ^= h >> 16;
  h *= 0x85ebca6b;
  h ^= h >> 13;
  h *= 0xc2b2ae35;
  h ^= h >> 16;

  return h;
}

//-----------------------------------------------------------------------------

void MurmurHash3_x86_32 ( const void * key, int len,
                          UInt4 seed, void * out )
{
  const uint8_t * data = (const uint8_t*)key;
  const int nblocks = len / 4;

  uint32_t h1 = seed;

  uint32_t c1 = 0xcc9e2d51;
  uint32_t c2 = 0x1b873593;

  //----------
  // body

  const uint32_t * blocks = (const uint32_t *)(data + nblocks*4);

  int i;
  for(i = -nblocks; i; i++)
  {
    uint32_t k1 = getblock4(blocks,i);

    k1 *= c1;
    k1 = ROTL32(k1,15);
    k1 *= c2;
    
    h1 ^= k1;
    h1 = ROTL32(h1,13); 
    h1 = h1*5+0xe6546b64;
  }

  //----------
  // tail

  const uint8_t * tail = (const uint8_t*)(data + nblocks*4);

  uint32_t k1 = 0;

  switch(len & 3)
  {
  case 3: k1 ^= tail[2] << 16;
  case 2: k1 ^= tail[1] << 8;
  case 1: k1 ^= tail[0];
          k1 *= c1; k1 = ROTL32(k1,16); k1 *= c2; h1 ^= k1;
  };

  //----------
  // finalization

  h1 ^= len;

  h1 = fmix4(h1);

  *(uint32_t*)out = h1;
} 

#else

//-----------------------------------------------------------------------------
// Platform-specific functions and macros

static inline uint64_t rotl64 ( uint64_t x, int8_t r )
{
  return (x << r) | (x >> (64 - r));
}

#define ROTL64(x,y)     rotl64(x,y)


#define BIG_CONSTANT(x) (x##LLU)


//-----------------------------------------------------------------------------
// Block read - if your platform needs to do endian-swapping or can only
// handle aligned reads, do the conversion here

FORCE_INLINE uint64_t getblock8 ( const uint64_t * p, int i )
{
  return p[i];
}

//-----------------------------------------------------------------------------
// Finalization mix - force all bits of a hash block to avalanche

FORCE_INLINE uint64_t fmix8 ( uint64_t k )
{
  k ^= k >> 33;
  k *= BIG_CONSTANT(0xff51afd7ed558ccd);
  k ^= k >> 33;
  k *= BIG_CONSTANT(0xc4ceb9fe1a85ec53);
  k ^= k >> 33;

  return k;
}

void MurmurHash3_x64_128 ( const void * key, const int len,
                           const UInt4 seed, void * out )
{
  const uint8_t * data = (const uint8_t*)key;
  const int nblocks = len / 16;

  uint64_t h1 = seed;
  uint64_t h2 = seed;

  uint64_t c1 = BIG_CONSTANT(0x87c37b91114253d5);
  uint64_t c2 = BIG_CONSTANT(0x4cf5ad432745937f);

  //----------
  // body

  const uint64_t * blocks = (const uint64_t *)(data);

  int i;
  for(i = 0; i < nblocks; i++)
  {
    uint64_t k1 = getblock8(blocks,i*2+0);
    uint64_t k2 = getblock8(blocks,i*2+1);

    k1 *= c1; k1  = ROTL64(k1,31); k1 *= c2; h1 ^= k1;

    h1 = ROTL64(h1,27); h1 += h2; h1 = h1*5+0x52dce729;

    k2 *= c2; k2  = ROTL64(k2,33); k2 *= c1; h2 ^= k2;

    h2 = ROTL64(h2,31); h2 += h1; h2 = h2*5+0x38495ab5;
  }

  //----------
  // tail

  const uint8_t * tail = (const uint8_t*)(data + nblocks*16);

  uint64_t k1 = 0;
  uint64_t k2 = 0;

  switch(len & 15)
  {
  case 15: k2 ^= (uint64_t)(tail[14]) << 48;
  case 14: k2 ^= (uint64_t)(tail[13]) << 40;
  case 13: k2 ^= (uint64_t)(tail[12]) << 32;
  case 12: k2 ^= (uint64_t)(tail[11]) << 24;
  case 11: k2 ^= (uint64_t)(tail[10]) << 16;
  case 10: k2 ^= (uint64_t)(tail[ 9]) << 8;
  case  9: k2 ^= (uint64_t)(tail[ 8]) << 0;
           k2 *= c2; k2  = ROTL64(k2,33); k2 *= c1; h2 ^= k2;

  case  8: k1 ^= (uint64_t)(tail[ 7]) << 56;
  case  7: k1 ^= (uint64_t)(tail[ 6]) << 48;
  case  6: k1 ^= (uint64_t)(tail[ 5]) << 40;
  case  5: k1 ^= (uint64_t)(tail[ 4]) << 32;
  case  4: k1 ^= (uint64_t)(tail[ 3]) << 24;
  case  3: k1 ^= (uint64_t)(tail[ 2]) << 16;
  case  2: k1 ^= (uint64_t)(tail[ 1]) << 8;
  case  1: k1 ^= (uint64_t)(tail[ 0]) << 0;
           k1 *= c1; k1  = ROTL64(k1,31); k1 *= c2; h1 ^= k1;
  };

  //----------
  // finalization

  h1 ^= len; h2 ^= len;

  h1 += h2;
  h2 += h1;

  h1 = fmix8(h1);
  h2 = fmix8(h2);

  h1 += h2;
  h2 += h1;

  ((uint64_t*)out)[0] = h1;
  ((uint64_t*)out)[1] = h2;
}
#endif

Obj FuncHASHKEY_BAG(Obj self, Obj obj, Obj opSeed, Obj opOffset, Obj opMaxLen)
{
  Int n;
  Int offs;

  if ( IS_INTOBJ(obj) )
    return obj;

  if ( IS_FFE(obj) ) {
    /* We must be careful here, as different FFEs can represent equal
       values (e.g. 0*Z(2^2) and 0*Z(2) compare as equal). Thus, we cannot
       simply use the bit pattern of obj to compute a hash, as a well-defined
       hash function must satisfy the implication
          obj1 = obj2 => HASH(obj1) = HASH(obj2)
       There are different ways to do this for FFEs, with different trade-offs.
       Instead of making an arbitrary choice here, let's just refuse to
       compute a hash here, and require the caller to provide a custom hash
       function tailored to their needs.
     */
    ErrorMayQuit("HASHKEY_BAG: <obj> must not be an FFE", 0, 0);
  }

  /* check the arguments                                                 */
  while ( !IS_INTOBJ(opSeed) ) {
      opSeed = ErrorReturnObj(
	  "HASHKEY_BAG: <seed> must be a small integer (not a %s)",
	  (Int)TNAM_OBJ(opSeed), 0L,
	  "you can replace <seed> via 'return <seed>;'" );
  }
  
  do {
    offs = -1;

    while ( !IS_INTOBJ(opOffset)  ) {
      opOffset = ErrorReturnObj(
       "HASHKEY_BAG: <offset> must be a small integer (not a %s)",
       (Int)TNAM_OBJ(opOffset), 0L,
       "you can replace <offset> via 'return <offset>;'" );      
    }
    offs = INT_INTOBJ(opOffset);
    if ( offs < 0 || offs > SIZE_OBJ(obj)) {
      opOffset = ErrorReturnObj(
        "HashKeyBag: <offset> must be non-negative and less than the bag size",
        0L, 0L,
        "you can replace <offset> via 'return <offset>;'" );      
      offs = -1; 
    }
  } while (offs < 0);

  while ( !IS_INTOBJ(opMaxLen) ) {
      opMaxLen = ErrorReturnObj(
        "HASHKEY_BAG: <maxlen> must be a small integer (not a %s)",
        (Int)TNAM_OBJ(opMaxLen), 0L,
        "you can replace <maxlen> via 'return <maxlen>;'" );
  }

  n=SIZE_OBJ(obj)-offs;

  /* maximal number of bytes to read */
  Int maxlen=INT_INTOBJ(opMaxLen);
  if ((n>maxlen)&&(maxlen!=-1)) {n=maxlen;}; 
  
  return INTOBJ_INT(HASHKEY_BAG_NC( obj, (UInt4)INT_INTOBJ(opSeed), offs, (int) n));
}

Int HASHKEY_MEM_NC(const void * ptr, UInt4 seed, Int read)
{
#ifdef SYS_IS_64_BIT
    UInt8 hashout[2];
    MurmurHash3_x64_128(ptr, read, seed, (void *)hashout);
    return hashout[0] % (1UL << 60);
#else
    UInt4 hashout;
    MurmurHash3_x86_32(ptr, read, seed, (void *)&hashout);
    return hashout % (1UL << 28);
#endif
}

Int HASHKEY_BAG_NC(Obj obj, UInt4 seed, Int skip, int read)
{
    return HASHKEY_MEM_NC((const UChar *)CONST_ADDR_OBJ(obj) + skip, seed,
                          read);
}

Int HASHKEY_WHOLE_BAG_NC(Obj obj, UInt4 seed)
{
    return HASHKEY_BAG_NC(obj, seed, 0, SIZE_OBJ(obj));
}

Obj IntStringInternal( Obj string )
{
        Obj                 val;            /* value = <upp> * <pow> + <low>   */
        Obj                 upp;            /* upper part                      */
        Int                 pow;            /* power                           */
        Int                 low;            /* lower part                      */
        Int                 sign;           /* is the integer negative         */
        UInt                i;              /* loop variable                   */
        UChar *             str;            /* temp pointer                    */
        
        /* get the signs, if any                                                */
        str = CHARS_STRING(string);
        sign = 1;
        i = 0;
        while ( str[i] == '-' ) {
            sign = - sign;
            i++;
        }

        /* collect the digits in groups of 8                                   */
        low = 0;
        pow = 1;
        upp = INTOBJ_INT(0);
        do {
            if( str[i] < '0' || str[i] > '9') {
                return Fail;
            }
            low = 10 * low + str[i] - '0';
            pow = 10 * pow;
            if ( pow == 100000000L ) {
                upp = PROD(upp, INTOBJ_INT(pow) );
                upp = SUM(upp, INTOBJ_INT(sign*low) );
                // Regrab, in case garbage collection occurred.
                str = CHARS_STRING(string);
                pow = 1;
                low = 0;
            }
            i++;
        } while ( str[i] != '\0' );

        /* compose the integer value                                           */
        val = 0;
        if ( upp == INTOBJ_INT(0) ) {
            val = INTOBJ_INT(sign*low);
        }
        else if ( pow == 1 ) {
            val = upp;
        }
        else {
            upp =  PROD( upp, INTOBJ_INT(pow) );
            val = SUM( upp , INTOBJ_INT(sign*low) );
        }

        /* push the integer value                                              */
        return val;
}

/****************************************************************************
**
*F  FuncINT_STRING( <self>, <string> ) . . . .  convert a string to an integer
**
**  `FuncINT_STRING' returns an integer representing the string, or
**  fail if the string is not a valid integer.
**
*/
Obj FuncINT_STRING ( Obj self, Obj string )
{
    if( !IS_STRING(string) ) {
        return Fail;
    }

    if( !IS_STRING_REP(string) ) {
        string = CopyToStringRep(string);
    }

    return IntStringInternal(string);
}

/****************************************************************************
**
*F SmallInt Bitfield operations
*
* The goal here it to set up a division of the usable bits in a small
* integer into fields which can be accessed very quickly from GAP
* level and quickly and conveniently from C. The purpose is to allow
* implementation of data structures that divide up the bits within a
* word without having to make them entirely opaque to the GAP level or
* ridiculously slow
*
* The API is defined in lib/bitfields.gd and works by providing the
* user with a collection of functions to get and set fields and
* assemble an entire word.
*
* These functions are constructed here and have special handlers. The
* information the handlers need about the size and position of the
* bitfields are stored in some of the fields of the function header
* which are not normally used for kernel functions. Specifically, we
* use the NLOC_FUNC and FEXS_FUNC fields, which we alias as
* MASK_BITFIELD_FUNC and OFFSET_BITFIELD_FUNC.
*
* For fields of size 1 we also offer Boolean setters and getters which
* accept and return True for 1 and False for 0. This makes for much
* nicer code on the GAP side.
*
*/


static inline UInt MASK_BITFIELD_FUNC(Obj func)
{
  return NLOC_FUNC(func);
}

static inline void SET_MASK_BITFIELD_FUNC(Obj func, UInt mask)
{
  SET_NLOC_FUNC(func, mask);
}

static inline UInt OFFSET_BITFIELD_FUNC(Obj func)
{
  GAP_ASSERT(IS_INTOBJ(FEXS_FUNC(func)));
  return INT_INTOBJ(FEXS_FUNC(func));
}

static inline void SET_OFFFSET_BITFIELD_FUNC(Obj func, UInt offset)
{
  return SET_FEXS_FUNC(func, INTOBJ_INT(offset));		    
}

static Obj DoFieldGetter(Obj self, Obj data)
{
    UInt mask = MASK_BITFIELD_FUNC(self);
    UInt offset = OFFSET_BITFIELD_FUNC(self);
    if (!IS_INTOBJ(data))
        ErrorMayQuit("Field getter: argument must be small integer", 0, 0);
    UInt x = INT_INTOBJ(data);
    return INTOBJ_INT((x & mask) >> offset);
}

static Obj DoFieldSetter(Obj self, Obj data, Obj val)
{
    UInt mask = MASK_BITFIELD_FUNC(self);
    UInt offset = OFFSET_BITFIELD_FUNC(self);
    if (!ARE_INTOBJS(data, val))
        ErrorMayQuit("Field Setter: both arguments must be small integers", 0,
                     0);
    UInt x = INT_INTOBJ(data);
    UInt y = INT_INTOBJ(val);
    return INTOBJ_INT((x & ~mask) | (y << offset));
}

static Obj DoBooleanFieldGetter(Obj self, Obj data)
{
  UInt mask = MASK_BITFIELD_FUNC(self);
    if (!IS_INTOBJ(data))
        ErrorMayQuit("Boolean Field getter: argument must be small integer", 0, 0);
    UInt x = INT_INTOBJ(data);
    return (x & mask) ? True : False;
}

static Obj DoBooleanFieldSetter(Obj self, Obj data, Obj val)
{
    UInt mask = MASK_BITFIELD_FUNC(self);
    if (!IS_INTOBJ(data))
        ErrorMayQuit("Boolean Field Setter: data must be small integer", 0,
                     0);
    UInt x = INT_INTOBJ(data);
    if (val == True)
        x |= mask;
    else if (val == False)
        x &= ~mask;
    else
        ErrorMayQuit("Boolean Field Setter: value must be true or false", 0,
                     0);
    return INTOBJ_INT(x);
}


static Obj FuncBUILD_BITFIELDS(Obj self, Obj args)
{
    GAP_ASSERT(IS_PLIST(args));
    GAP_ASSERT(LEN_PLIST(args) >= 1 && ELM_PLIST(args, 1));
    Obj widths = ELM_PLIST(args, 1);
    if (!IS_LIST(widths))
        ErrorMayQuit("Fields builder: first argument must be list of widths",
                     0, 0);
    UInt nfields = LEN_LIST(widths);
    if (LEN_PLIST(args) != nfields + 1)
        ErrorMayQuit(
            "Fields builder: number of values must match number of widths", 0,
            0);
    UInt x = 0;
    UInt i;
    for (i = nfields; i > 0; i--) {
        GAP_ASSERT(ISB_LIST(widths, i));
        Obj y = ELM_LIST(widths, i);
        x <<= INT_INTOBJ(y);
        GAP_ASSERT(ELM_PLIST(args, i + 1));
        Obj z = ELM_PLIST(args, i + 1);
        if (!IS_INTOBJ(z))
            ErrorMayQuit("Fields builder: values must be small integers", 0,
                         0);
        GAP_ASSERT(INT_INTOBJ(z) < (1 << INT_INTOBJ(y)));
        x |= INT_INTOBJ(z);
    }
    return INTOBJ_INT(x);
}


Obj FuncMAKE_BITFIELDS(Obj self, Obj widths)
{
    if (!IS_LIST(widths))
        ErrorMayQuit("MAKE_BITFIELDS: widths must be a list", 0, 0);
    UInt nfields = LEN_LIST(widths);
    UInt starts[nfields + 1];
    starts[0] = 0;
    for (UInt i = 1; i <= nfields; i++) {
        Obj o = ELM_LIST(widths, i);
        if (!IS_INTOBJ(o))
            ErrorMayQuit("MAKE_BITFIELDS: widths must be small integers", 0,
                         0);
        UInt width = INT_INTOBJ(o);
        starts[i] = starts[i - 1] + width;
    }
    if (starts[nfields] > 8 * sizeof(UInt))
        ErrorMayQuit("MAKE_BITFIELDS: total widths too large", 0, 0);

    Obj  setters = NEW_PLIST(T_PLIST_DENSE + IMMUTABLE, nfields);
    Obj  getters = NEW_PLIST(T_PLIST_DENSE + IMMUTABLE, nfields);
    Obj  bsetters = NEW_PLIST(T_PLIST + IMMUTABLE, nfields);
    UInt bslen = 0;
    Obj  bgetters = NEW_PLIST(T_PLIST + IMMUTABLE, nfields);
    for (UInt i = 1; i <= nfields; i++) {
        UInt mask = (1L << starts[i]) - (1L << starts[i - 1]);
        Obj s = NewFunctionC("<field setter>", 2, "data, val", DoFieldSetter);
        SET_MASK_BITFIELD_FUNC(s, mask);
        SET_OFFFSET_BITFIELD_FUNC(s, starts[i - 1]);
        SET_ELM_PLIST(setters, i, s);
        CHANGED_BAG(setters);
        Obj g = NewFunctionC("<field getter>", 1, "data", DoFieldGetter);
        SET_MASK_BITFIELD_FUNC(g, mask);
        SET_OFFFSET_BITFIELD_FUNC(g, starts[i - 1]);
        SET_ELM_PLIST(getters, i, g);
        CHANGED_BAG(getters);
        if (starts[i] - starts[i - 1] == 1) {
            s = NewFunctionC("<boolean field setter>", 2, "data, val",
                             DoBooleanFieldSetter);
            SET_MASK_BITFIELD_FUNC(s, mask);
            SET_OFFFSET_BITFIELD_FUNC(s, starts[i - 1]);
            SET_ELM_PLIST(bsetters, i, s);
            CHANGED_BAG(bsetters);
            bslen = i;
            g = NewFunctionC("<boolean field getter>", 1, "data",
                             DoBooleanFieldGetter);
            SET_MASK_BITFIELD_FUNC(g, mask);
            SET_OFFFSET_BITFIELD_FUNC(g, starts[i - 1]);
            SET_ELM_PLIST(bgetters, i, g);
            CHANGED_BAG(bgetters);
        }
    }

    SET_LEN_PLIST(setters, nfields);
    SET_LEN_PLIST(getters, nfields);
    SET_LEN_PLIST(bsetters, bslen);
    SET_LEN_PLIST(bgetters, bslen);

    Obj ms = NEW_PREC(5);
    AssPRec(ms, RNamName("widths"), CopyObj(widths, 0));
    AssPRec(ms, RNamName("getters"), getters);
    AssPRec(ms, RNamName("setters"), setters);
    if (bslen > 0) {
        AssPRec(ms, RNamName("booleanGetters"), bgetters);
        AssPRec(ms, RNamName("booleanSetters"), bsetters);
    }
    SortPRecRNam(ms, 0);
    RetypeBag(ms, T_PREC + IMMUTABLE);
    return ms;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {


    GVAR_FUNC(HASHKEY_BAG, 4, "obj, int,int,int"),
    GVAR_FUNC(SIZE_OBJ, 1, "obj"),
    GVAR_FUNC(InitRandomMT, 1, "initstr"),
    GVAR_FUNC(INT_STRING, 1, "string"),
    GVAR_FUNC(MAKE_BITFIELDS, -1, "widths"),
    GVAR_FUNC(BUILD_BITFIELDS, -2, "widths..."),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{

    InitHandlerFunc(DoFieldSetter, "field-setter");
    InitHandlerFunc(DoFieldGetter, "field-getter");
    InitHandlerFunc(DoBooleanFieldSetter, "boolean-field-setter");
    InitHandlerFunc(DoBooleanFieldGetter, "boolean-field-getter");

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoIntFuncs() . . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "intfuncs",                          /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoIntFuncs ( void )
{
    return &module;
}
