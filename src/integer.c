/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file implements the functions handling GMP integers.
**
**  There are three integer types in GAP: 'T_INT', 'T_INTPOS' and 'T_INTNEG'.
**  Each integer has a unique representation, e.g., an integer that can be
**  represented as 'T_INT' is never represented as 'T_INTPOS' or 'T_INTNEG'.
**
**  In the following, let 'N' be the number of bits in an UInt (so 32 or
**  64, depending on the system). 'T_INT' is the type of those integers small
**  enough to fit into N-3 bits. Therefore the value range of this small
**  integers is $-2^{N-4}...2^{N-4}-1$. Only these small integers can be used
**  as index expression into sequences.
**
**  Small integers are represented by an immediate integer handle, containing
**  the value instead of pointing to it, which has the following form:
**
**      +-------+-------+-------+-------+- - - -+-------+-------+-------+
**      | guard | sign  | bit   | bit   |       | bit   | tag   | tag   |
**      | bit   | bit   | N-5   | N-6   |       | 0     |  = 0  |  = 1  |
**      +-------+-------+-------+-------+- - - -+-------+-------+-------+
**
**  Immediate integers handles carry the tag 'T_INT', i.e. the last bit is 1.
**  This distinguishes immediate integers from other handles which point to
**  structures aligned on even boundaries and therefore have last bit zero.
**  (The second bit is reserved as tag to allow extensions of this scheme.)
**  Using immediates as pointers and dereferencing them gives address errors.
**
**  To aid overflow check the most significant two bits must always be equal,
**  that is to say that the sign bit of immediate integers has a guard bit.
**
**  The macros 'INTOBJ_INT' and 'INT_INTOBJ' should be used to convert between
**  a small integer value and its representation as immediate integer handle.
**
**  'T_INTPOS' and 'T_INTNEG' are the types of positive respectively negative
**  integer values that cannot be represented by immediate integers.
**
**  These large integers values are represented as low-level GMP integer
**  objects, that is, in base 2^N. That means that the bag of a large integer
**  has the following form, where the "digits" are also more commonly referred
**  to as "limbs".:
**
**      +-------+-------+-------+-------+- - - -+-------+-------+-------+
**      | digit | digit | digit | digit |       | digit | digit | digit |
**      | 0     | 1     | 2     | 3     |       | <n>-2 | <n>-1 | <n>   |
**      +-------+-------+-------+-------+- - - -+-------+-------+-------+
**
**  The value of this is: $d0 + d1 2^N + d2 (2^N)^2 + ... + d_n (2^N)^n$,
**  respectively the negative of this if the object type is 'T_INTNEG'.
**
**  Each digit resp. limb is stored as a N bit wide unsigned integer.
**
**  Note that we require that all large integers be normalized (that is, they
**  must not contain leading zero limbs) and reduced (they do not fit into a
**  small integer). Internally, a large integer may temporarily not be
**  normalized or not be reduced, but all kernel functions must make sure
**  that they eventually return normalized and reduced values. The function
**  GMP_NORMALIZE and GMP_REDUCE can be used to ensure this.
*/

#include "integer.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "error.h"
#include "intfuncs.h"
#include "io.h"
#include "modules.h"
#include "opers.h"
#include "saveload.h"
#include "stats.h"
#include "stringobj.h"

#include "config.h"


/* TODO: Remove after Ward2 */
#ifndef WARD_ENABLED

#include <gmp.h>

#if GMP_NAIL_BITS != 0
#error Aborting compile: GAP does not support non-zero GMP nail size
#endif
#if !defined(__GNU_MP_RELEASE)
 #if __GMP_MP_RELEASE < 50002
 #error Aborting compile: GAP requires GMP 5.0.2 or newer
 #endif
#endif

GAP_STATIC_ASSERT(GMP_LIMB_BITS == 8 * sizeof(UInt),
                  "GMP_LIMB_BITS != 8 * sizeof(UInt)");
GAP_STATIC_ASSERT(sizeof(mp_limb_t) == sizeof(UInt),
                  "sizeof(mp_limb_t) != sizeof(UInt)");

static Obj ObjInt_UIntInv( UInt i );


/* debugging */
#ifdef GAP_KERNEL_DEBUG
#define DEBUG_GMP 1
#else
#define DEBUG_GMP 0
#endif

#if DEBUG_GMP

#define CHECK_INT(op)  IS_NORMALIZED_AND_REDUCED(op, __func__, __LINE__)
#else
#define CHECK_INT(op)  do { } while(0);
#endif


/* macros to save typing later :)  */
#define VAL_LIMB0(obj)          (*CONST_ADDR_INT(obj))
#define SET_VAL_LIMB0(obj,val)  do { *ADDR_INT(obj) = val; } while(0)
#define IS_INTPOS(obj)          (TNUM_OBJ(obj) == T_INTPOS)
#define IS_INTNEG(obj)          (TNUM_OBJ(obj) == T_INTNEG)

#define SIZE_INT_OR_INTOBJ(obj) (IS_INTOBJ(obj) ? 1 : SIZE_INT(obj))

#define RequireNonzero(funcname, op, argname)                                \
    do {                                                                     \
        if (op == INTOBJ_INT(0)) {                                           \
            RequireArgumentEx(funcname, op, "<" argname ">",                 \
                              "must be a nonzero integer");                  \
        }                                                                    \
    } while (0)


GAP_STATIC_ASSERT( sizeof(mp_limb_t) == sizeof(UInt), "gmp limb size incompatible with GAP word size");


/* This ensures that all memory underlying a bag is actually committed
** to physical memory and can be written to.
** This is a workaround to a bug specific to Cygwin 64-bit and bad
** interaction with GMP, so this is only needed specifically for new
** bags created in this module to hold the outputs of GMP routines.
**
** Thus, any time NewBag is called, it is also necessary to call
** ENSURE_BAG(bag) on the newly created bag if some GMP function will be
** the first place that bag's data is written to.
**
** To give a counter-example, ENSURE_BAG is *not* needed in ObjInt_Int,
** because it just creates a bag to hold a single mp_limb_t, and
** immediately assigns it a value.
**
** The bug this works around is explained more in
** https://github.com/gap-system/gap/issues/3434
*/
static inline void ENSURE_BAG(Bag bag)
{
// Note: This workaround is only required with the original GMP and not with
// MPIR
#if defined(SYS_IS_CYGWIN32) && defined(SYS_IS_64_BIT) &&                    \
    !defined(__MPIR_VERSION)
    memset(PTR_BAG(bag), 0, SIZE_BAG(bag));
#endif
}


/* for fallbacks to library */
static Obj String;
static Obj OneAttr;
static Obj IsIntFilt;


/****************************************************************************
**
*F  TypeInt(<val>) . . . . . . . . . . . . . . . . . . . . .  type of integer
**
**  'TypeInt' returns the type of the integer <val>.
**
**  'TypeInt' is the function in 'TypeObjFuncs' for integers.
*/
static Obj TYPE_INT_SMALL_ZERO;
static Obj TYPE_INT_SMALL_POS;
static Obj TYPE_INT_SMALL_NEG;
static Obj TYPE_INT_LARGE_POS;
static Obj TYPE_INT_LARGE_NEG;

static Obj TypeIntSmall(Obj val)
{
    if ( 0 == INT_INTOBJ(val) ) {
        return TYPE_INT_SMALL_ZERO;
    }
    else if ( 0 < INT_INTOBJ(val) ) {
        return TYPE_INT_SMALL_POS;
    }
    else {
        return TYPE_INT_SMALL_NEG;
    }
}

static Obj TypeIntLargePos(Obj val)
{
    return TYPE_INT_LARGE_POS;
}

static Obj TypeIntLargeNeg(Obj val)
{
    return TYPE_INT_LARGE_NEG;
}


/****************************************************************************
**
*F  FiltIS_INT( <self>, <val> ) . . . . . . . . . . internal function 'IsInt'
**
**  'FiltIS_INT' implements the internal filter 'IsInt'.
**
**  'IsInt( <val> )'
**
**  'IsInt'  returns 'true'  if the  value  <val>  is a small integer or a
**  large int, and 'false' otherwise.
*/
static Obj FiltIS_INT(Obj self, Obj val)
{
  if ( IS_INT(val) ) {
    return True;
  }
  else if ( TNUM_OBJ(val) < FIRST_EXTERNAL_TNUM ) {
    return False;
  }
  else {
    return DoFilter( self, val );
  }
}


/****************************************************************************
**
*F  SaveInt( <op> )
**
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SaveInt(Obj op)
{
    const UInt * ptr = CONST_ADDR_INT(op);
    for (UInt i = 0; i < SIZE_INT(op); i++)
        SaveUInt(*ptr++);
    return;
}
#endif


/****************************************************************************
**
*F  LoadInt( <op> )
**
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadInt(Obj op)
{
    UInt * ptr = ADDR_INT(op);
    for (UInt i = 0; i < SIZE_INT(op); i++)
        *ptr++ = LoadUInt();
    return;
}
#endif


/****************************************************************************
**
**  In order to use the high-level GMP mpz_* functions conveniently while
**  retaining a low overhead, we introduce fake_mpz_t, which can be thought
**  of as a "subclass" of mpz_t, extending it by temporary storage for
**  single limb of data, as well as a reference to a corresponding GAP
**  object.
**
**  For an example on how to correctly use this, see GcdInt.
*/
typedef struct {
  mpz_t v;
  mp_limb_t tmp;
  Obj obj;
} fake_mpz_t[1];


/****************************************************************************
**
*F  NEW_FAKEMPZ( <fake>, <size> )
**
**  Setup a fake mpz_t object for capturing the output of a GMP mpz_ function,
**  with space for up to <size> limbs allocated.
*/
static void NEW_FAKEMPZ( fake_mpz_t fake, UInt size )
{
  fake->v->_mp_alloc = size;
  fake->v->_mp_size = 0;
  if (size == 1) {
    fake->obj = 0;
  }
  else {
    fake->obj = NewBag( T_INTPOS, size * sizeof(mp_limb_t) );
    ENSURE_BAG(fake->obj);
  }
}


/****************************************************************************
**
*F  FAKEMPZ_GMPorINTOBJ( <fake>, <op> )
**
**  Initialize <fake> to reference the content of <op>. For this, <op>
**  must be an integer, either small or large, but this is *not* checked.
**  The calling code is responsible for any verification.
*/
static void FAKEMPZ_GMPorINTOBJ( fake_mpz_t fake, Obj op )
{
  if (IS_INTOBJ(op)) {
    fake->obj = 0;
    fake->v->_mp_alloc = 1;
    const Int i = INT_INTOBJ(op);
    if ( i >= 0 ) {
      fake->tmp = i;
      fake->v->_mp_size = i ? 1 : 0;
    }
    else {
      fake->tmp = -i;
      fake->v->_mp_size = -1;
    }
  }
  else {
    fake->obj = op;
    fake->v->_mp_alloc = SIZE_INT(op);
    fake->v->_mp_size = IS_INTPOS(op) ? SIZE_INT(op) : -SIZE_INT(op);
  }
}


/****************************************************************************
**
*F  GMPorINTOBJ_FAKEMPZ( <fake> )
**
**  This function converts a fake mpz_t into a GAP integer object.
*/
static Obj GMPorINTOBJ_FAKEMPZ( fake_mpz_t fake )
{
  Obj obj = fake->obj;
  if ( fake->v->_mp_size == 0 ) {
    obj = INTOBJ_INT(0);
  }
  else if ( obj != 0 ) {
    if ( fake->v->_mp_size < 0 ) {
      /* Warning: changing the bag type is only correct if the object was
         not yet visible to the outside world. Thus, it is safe to use
         with an fake_mpz_t initialized with NEW_FAKEMPZ, but not with
         one that was setup by FAKEMPZ_GMPorINTOBJ. */
      RetypeBag( obj, T_INTNEG );
    }
    obj = GMP_NORMALIZE( obj );
    obj = GMP_REDUCE( obj );
  }
  else {
    if ( fake->v->_mp_size == 1 )
      obj = ObjInt_UInt( fake->tmp );
    else
      obj = ObjInt_UIntInv( fake->tmp );
  }
  return obj;
}

/****************************************************************************
**
*F  GMPorINTOBJ_MPZ( <fake> )
**
**  This function converts an mpz_t into a GAP integer object.
*/
static Obj GMPorINTOBJ_MPZ( mpz_t v )
{
    return MakeObjInt((const UInt *)v->_mp_d, v->_mp_size);
}


/****************************************************************************
**
**  MPZ_FAKEMPZ( <fake> )
**
**  This converts a fake_mpz_t into an mpz_t. As a side effect, it updates
**  fake->v->_mp_d. This allows us to use SWAP on fake_mpz_t objects, and
**  also protects against garbage collection moving around data.
*/
#define MPZ_FAKEMPZ(fake)   (UPDATE_FAKEMPZ(fake), fake->v)

/* UPDATE_FAKEMPZ is a helper function for the MPZ_FAKEMPZ macro */
static inline void UPDATE_FAKEMPZ( fake_mpz_t fake )
{
  fake->v->_mp_d = fake->obj ? (mp_ptr)ADDR_INT(fake->obj) : &fake->tmp;
}

/* some extra debugging tools for FAKMPZ objects */
#if DEBUG_GMP
#define CHECK_FAKEMPZ(fake) \
    assert( ((fake)->v->_mp_d == ((fake)->obj ? (mp_ptr)ADDR_INT((fake)->obj) : &(fake)->tmp )) \
        &&  (fake->v->_mp_alloc == ((fake)->obj ? SIZE_INT((fake)->obj) : 1 )) )
#else
#define CHECK_FAKEMPZ(fake)  do { } while(0);
#endif


/****************************************************************************
**
*F  GMP_NORMALIZE( <op> ) . . . . . . .  remove leading zeros from a GMP bag
**
**  'GMP_NORMALIZE' removes any leading zeros from a large integer object
**  and returns a small int or resizes the bag if possible.
**
*/
Obj GMP_NORMALIZE(Obj op)
{
    mp_size_t size;
    if (IS_INTOBJ(op)) {
        return op;
    }
    for (size = SIZE_INT(op); size != (mp_size_t)1; size--) {
        if (CONST_ADDR_INT(op)[(size - 1)] != 0) {
            break;
        }
    }
    if (size < SIZE_INT(op)) {
        ResizeBag(op, size * sizeof(mp_limb_t));
    }
    return op;
}

Obj GMP_REDUCE(Obj op)
{
    if (IS_INTOBJ(op)) {
        return op;
    }
    if (SIZE_INT(op) == 1) {
        if ((VAL_LIMB0(op) <= INT_INTOBJ_MAX) ||
            (IS_INTNEG(op) && VAL_LIMB0(op) == -INT_INTOBJ_MIN)) {
            if (IS_INTNEG(op)) {
                return INTOBJ_INT(-(Int)VAL_LIMB0(op));
            }
            else {
                return INTOBJ_INT((Int)VAL_LIMB0(op));
            }
        }
    }
    return op;
}

/****************************************************************************
**
**  This is a helper function for the CHECK_INT macro, which checks that
**  the given integer object <op> is normalized and reduced.
**
*/
#if DEBUG_GMP
static BOOL IS_NORMALIZED_AND_REDUCED(Obj op, const char * func, int line)
{
  mp_size_t size;
  if ( IS_INTOBJ( op ) ) {
    return TRUE;
  }
  if ( !IS_LARGEINT( op ) ) {
    /* ignore non-integers */
    return FALSE;
  }
  for ( size = SIZE_INT(op); size != (mp_size_t)1; size-- ) {
    if ( CONST_ADDR_INT(op)[(size - 1)] != 0 ) {
      break;
    }
  }
  if ( size < SIZE_INT(op) ) {
    Pr("WARNING: non-normalized gmp value (%s:%d)\n",(Int)func,line);
  }
  if ( SIZE_INT(op) == 1) {
    if ( ( VAL_LIMB0(op) <= INT_INTOBJ_MAX ) ||
         ( IS_INTNEG(op) && VAL_LIMB0(op) == -INT_INTOBJ_MIN ) ) {
      if ( IS_INTNEG(op) ) {
        Pr("WARNING: non-reduced negative gmp value (%s:%d)\n",(Int)func,line);
        return FALSE;
      }
      else {
        Pr("WARNING: non-reduced positive gmp value (%s:%d)\n",(Int)func,line);
        return FALSE;
      }
    }
  }
  return TRUE;
}
#endif


/****************************************************************************
**
*F  ObjInt_Int( <cint> ) . . . . . . . . . .  convert c int to integer object
**
**  'ObjInt_Int' takes the C integer <cint> and returns the equivalent
**  GMP obj or int obj, according to the value of <cint>.
**
*/
Obj ObjInt_Int( Int i )
{
  Obj gmp;

  if (INT_INTOBJ_MIN <= i && i <= INT_INTOBJ_MAX) {
    return INTOBJ_INT(i);
  }
  else if (i < 0 ) {
    gmp = NewBag( T_INTNEG, sizeof(mp_limb_t) );
    i = -i;
  }
  else {
    gmp = NewBag( T_INTPOS, sizeof(mp_limb_t) );
  }
  SET_VAL_LIMB0( gmp, i );
  return gmp;
}

Obj ObjInt_UInt( UInt i )
{
  Obj gmp;
  if (i <= INT_INTOBJ_MAX) {
    return INTOBJ_INT(i);
  }
  else {
    gmp = NewBag( T_INTPOS, sizeof(mp_limb_t) );
    SET_VAL_LIMB0( gmp, i );
    return gmp;
  }
}

// initialize to -i
Obj ObjInt_UIntInv( UInt i )
{
  Obj gmp;
  // we need to test INT_INTOBJ_MIN <= -i; to express this with unsigned
  // values, we must avoid all negative terms, which leads to this equivalent
  // check:
  if (i <= -INT_INTOBJ_MIN) {
    return INTOBJ_INT(-i);
  }
  else {
    gmp = NewBag( T_INTNEG, sizeof(mp_limb_t) );
    SET_VAL_LIMB0( gmp, i );
    return gmp;
  }
}


Obj ObjInt_Int8( Int8 i )
{
#ifdef SYS_IS_64_BIT
  return ObjInt_Int(i);
#else
  if (i == (Int4)i) {
    return ObjInt_Int((Int4)i);
  }

  /* we need two limbs to store this integer */
  assert( sizeof(mp_limb_t) == 4 );
  Obj gmp;
  if (i >= 0) {
     gmp = NewBag( T_INTPOS, 2 * sizeof(mp_limb_t) );
  } else {
     gmp = NewBag( T_INTNEG, 2 * sizeof(mp_limb_t) );
     i = -i;
  }

  UInt *ptr = ADDR_INT(gmp);
  ptr[0] = (UInt4)i;
  ptr[1] = ((UInt8)i) >> 32;
  return gmp;
#endif
}

Obj ObjInt_UInt8( UInt8 i )
{
#ifdef SYS_IS_64_BIT
  return ObjInt_UInt(i);
#else
  if (i == (UInt4)i) {
    return ObjInt_UInt((UInt4)i);
  }

  /* we need two limbs to store this integer */
  assert( sizeof(mp_limb_t) == 4 );
  Obj gmp = NewBag( T_INTPOS, 2 * sizeof(mp_limb_t) );
  UInt *ptr = ADDR_INT(gmp);
  ptr[0] = (UInt4)i;
  ptr[1] = ((UInt8)i) >> 32;
  return gmp;
#endif
}

/****************************************************************************
**
** Convert GAP Integers to various C types -- see header file
*/
Int Int_ObjInt(Obj i)
{
    UInt sign = 0;
    if (IS_INTOBJ(i))
        return INT_INTOBJ(i);
    // must be a single limb
    if (TNUM_OBJ(i) == T_INTPOS)
        sign = 0;
    else if (TNUM_OBJ(i) == T_INTNEG)
        sign = 1;
    else
        RequireArgument("Conversion error", i, "must be an integer");
    if (SIZE_BAG(i) != sizeof(mp_limb_t))
        ErrorMayQuit("Conversion error: integer too large", 0, 0);

    // now check if val is small enough to fit in the signed Int type
    // that has a range from -2^N to 2^N-1 so we need to check both ends
    // Since -2^N is the same bit pattern as the UInt 2^N (N is 31 or 63)
    // we can do it as below which avoids some compiler warnings
    UInt val = VAL_LIMB0(i);
#ifdef SYS_IS_64_BIT
    if ((!sign && (val > INT64_MAX)) || (sign && (val > (UInt)INT64_MIN)))
#else
    if ((!sign && (val > INT32_MAX)) || (sign && (val > (UInt)INT32_MIN)))
#endif
        ErrorMayQuit("Conversion error: integer too large", 0, 0);
    return sign ? -(Int)val : (Int)val;
}

UInt UInt_ObjInt(Obj i)
{
    if (IS_NEG_INT(i))
        ErrorMayQuit("Conversion error: cannot convert negative integer to unsigned type", 0, 0);
    if (IS_INTOBJ(i))
        return (UInt)INT_INTOBJ(i);
    if (TNUM_OBJ(i) != T_INTPOS)
        RequireArgument("Conversion error", i, "must be a non-negative integer");

    // must be a single limb
    if (SIZE_INT(i) != 1)
        ErrorMayQuit("Conversion error: integer too large", 0, 0);
    return VAL_LIMB0(i);
}

Int8 Int8_ObjInt(Obj i)
{
#ifdef SYS_IS_64_BIT
    // in this case Int8 is Int
    return Int_ObjInt(i);
#else
    if (IS_INTOBJ(i))
        return (Int8)INT_INTOBJ(i);

    UInt sign = 0;
    if (TNUM_OBJ(i) == T_INTPOS)
        sign = 0;
    else if (TNUM_OBJ(i) == T_INTNEG)
        sign = 1;
    else
        RequireArgument("Conversion error", i, "must be an integer");

    // must be at most two limbs
    if (SIZE_INT(i) > 2)
        ErrorMayQuit("Conversion error: integer too large", 0, 0);
    UInt  vall = VAL_LIMB0(i);
    UInt  valh = (SIZE_INT(i) == 1) ? 0 : CONST_ADDR_INT(i)[1];
    UInt8 val = (UInt8)vall + ((UInt8)valh << 32);
    // now check if val is small enough to fit in the signed Int8 type
    // that has a range from -2^63 to 2^63-1 so we need to check both ends
    // Since -2^63 is the same bit pattern as the UInt8 2^63 we can do it
    // this way which avoids some compiler warnings
    if ((!sign && (val > INT64_MAX)) || (sign && (val > (UInt8)INT64_MIN)))
        ErrorMayQuit("Conversion error: integer too large", 0, 0);
    return sign ? -(Int8)val : (Int8)val;
#endif
}

UInt8 UInt8_ObjInt(Obj i)
{
#ifdef SYS_IS_64_BIT
    // in this case UInt8 is UInt
    return UInt_ObjInt(i);
#else
    if (IS_NEG_INT(i))
        ErrorMayQuit("Conversion error: cannot convert negative integer to unsigned type", 0, 0);
    if (IS_INTOBJ(i))
        return (UInt8)INT_INTOBJ(i);
    if (TNUM_OBJ(i) != T_INTPOS)
        RequireArgument("Conversion error", i, "must be a non-negative integer");
    if (SIZE_INT(i) > 2)
        ErrorMayQuit("Conversion error: integer too large", 0, 0);
    UInt vall = VAL_LIMB0(i);
    UInt valh = (SIZE_INT(i) == 1) ? 0 : CONST_ADDR_INT(i)[1];
    return (UInt8)vall + ((UInt8)valh << 32);
#endif
}


/****************************************************************************
**
*F  MakeObjInt(<limbs>, <size>) . . . . . . . . . create a new integer object
**
*/
Obj MakeObjInt(const UInt * limbs, int size)
{
    Obj obj;
    if (size == 0)
        obj = INTOBJ_INT(0);
    else if (size == 1)
        obj = ObjInt_UInt(limbs[0]);
    else if (size == -1)
        obj = ObjInt_UIntInv(limbs[0]);
    else {
        UInt tnum = (size > 0 ? T_INTPOS : T_INTNEG);
        if (size < 0) size = -size;
        obj = NewBag(tnum, size * sizeof(mp_limb_t));
        memcpy(ADDR_INT(obj), limbs, size * sizeof(mp_limb_t));

        obj = GMP_NORMALIZE(obj);
        obj = GMP_REDUCE(obj);
    }
    return obj;
}


// This function returns an immediate integer, or
// an integer object with exactly one limb, and returns
// its absolute value as an unsigned integer.
static inline UInt AbsOfSmallInt(Obj x)
{
    if (!IS_INTOBJ(x)) {
        GAP_ASSERT(SIZE_INT(x) == 1);
        return VAL_LIMB0(x);
    }
    Int val = INT_INTOBJ(x);
    return val > 0 ? val : -val;
}


/****************************************************************************
**
*F  PrintInt( <op> ) . . . . . . . . . . . . . . . .  print an integer object
**
**  'PrintInt' prints the integer <op> in the usual decimal notation.
*/
void PrintInt ( Obj op )
{
  /* print a small integer                                                 */
  if ( IS_INTOBJ(op) ) {
    Pr("%>%d%<", INT_INTOBJ(op), 0);
  }
  
  /* print a large integer                                                 */
  else if ( SIZE_INT(op) < 1000 ) {
    CHECK_INT(op);

    /* Use GMP to print the integer to a buffer. We are looking at an
       integer with less than 1000 limbs, hence in decimal notation, it
       will take up at most LogInt( 2^(1000 * GMP_LIMB_BITS), 10)
       digits. Since 1000*Log(2)/Log(10) = 301.03, we get the following
       estimate for the buffer size (the overestimate is big enough to
       include space for a sign and a null terminator). */
    Char buf[302 * GMP_LIMB_BITS];
    mpz_t v;
    v->_mp_alloc = SIZE_INT(op);
    v->_mp_size = IS_INTPOS(op) ? v->_mp_alloc : -v->_mp_alloc;
    v->_mp_d = (mp_ptr)ADDR_INT(op);
    mpz_get_str(buf, 10, v);

    /* print the buffer, %> means insert '\' before a linebreak            */
    Pr("%>%s%<",(Int)buf, 0);
  }
  else {
    Obj str = CALL_1ARGS( String, op );
    Pr("%>", 0, 0);
    PrintString1(str);
    Pr("%<", 0, 0);
    /* for a long time Print of large ints did not follow the general idea
     * that Print should produce something that can be read back into GAP:
       Pr("<<an integer too large to be printed>>", 0, 0); */
  }
}


/****************************************************************************
**
*F  StringIntBase( <op>, <base> )
**
** Convert the integer <op> to a string relative to the given base <base>.
** Here, base may range from 2 to 36.
*/
static Obj StringIntBase(Obj op, int base)
{
  int len;
  Obj res;
  fake_mpz_t v;

  GAP_ASSERT(IS_INT(op));
  CHECK_INT(op);
  GAP_ASSERT(2 <= base && base <= 36);

  /* 0 is special */
  if (op == INTOBJ_INT(0)) {
    res = NEW_STRING(1);
    CHARS_STRING(res)[0] = '0';
    return res;
  }

  /* convert integer to fake_mpz_t */
  FAKEMPZ_GMPorINTOBJ(v, op);

  /* allocate the result string */
  len = mpz_sizeinbase( MPZ_FAKEMPZ(v), base ) + 2;
  res = NEW_STRING( len );

  /* ask GMP to perform the actual conversion */
  mpz_get_str( CSTR_STRING( res ), -base, MPZ_FAKEMPZ(v) );

  /* we may have to shrink the string */
  int real_len = strlen( CONST_CSTR_STRING(res) );
  if ( real_len != GET_LEN_STRING(res) ) {
    SET_LEN_STRING(res, real_len);
  }

  return res;
}

/****************************************************************************
**
*F  FuncHexStringInt( <self>, <n> ) . . . . . . . . .  hex string for GAP int
*F  FuncIntHexString( <self>, <string> ) . . . . . .  GAP int from hex string
**
**  The  function  `FuncHexStringInt'  constructs from  a GAP integer  the
**  corresponding string in  hexadecimal notation. It has  a leading '-'
**  for negative numbers and the digits 10..15 are written as A..F.
**
**  The  function `FuncIntHexString'  does  the converse,  but here  the
**  letters a..f are also allowed in <string> instead of A..F.
**
*/
static Obj FuncHexStringInt(Obj self, Obj n)
{
    RequireInt(SELF_NAME, n);
    return StringIntBase(n, 16);
}


/****************************************************************************
**
** This helper function for IntHexString reads <len> bytes in the string
** <p> and parses them as a hexadecimal. The resulting integer is returned.
** This function does not check for overflow, so make sure that len*4 does
** not exceed the number of bits in mp_limb_t.
**/
static mp_limb_t hexstr2int( const UInt1 *p, UInt len )
{
  mp_limb_t n = 0;
  UInt1 a;
  while (len--) {
    a = *p++;
    if (a >= 'a')
      a -= 'a' - 10;
    else if ( a>= 'A')
      a -= 'A' - 10;
    else
      a -= '0';
    if (a > 15)
      ErrorMayQuit("IntHexString: invalid character in hex-string", 0, 0);
    n = (n << 4) + a;
  }
  return n;
}

static Obj FuncIntHexString(Obj self,  Obj str)
{
    RequireStringRep(SELF_NAME, str);
    return IntHexString(str);
}

Obj IntHexString(Obj str)
{
  Obj res;
  Int  i, len, sign, nd;
  mp_limb_t n;
  const UInt1 *p;
  UInt *limbs;

  GAP_ASSERT(IS_STRING_REP(str));

  len = GET_LEN_STRING(str);
  if (len == 0) {
    res = INTOBJ_INT(0);
    return res;
  }
  p = CONST_CHARS_STRING(str);
  if (*p == '-') {
    sign = -1;
    i = 1;
  }
  else {
    sign = 1;
    i = 0;
  }

  while (p[i] == '0' && i < len)
    i++;
  len -= i;

  if (len*4 <= NR_SMALL_INT_BITS) {
    n = hexstr2int( p + i, len );
    res = INTOBJ_INT(sign * n);
    return res;
  }

  else {
    /* Each hex digit corresponds to 4 bits, and each GMP limb has sizeof(UInt)
       bytes, thus 2*sizeof(UInt) hex digits fit into one limb. We use this
       to compute the number of limbs minus 1: */
    nd = (len - 1) / (2*sizeof(UInt));
    res = NewBag( (sign == 1) ? T_INTPOS : T_INTNEG, (nd + 1) * sizeof(mp_limb_t) );

    /* update pointer, in case a garbage collection happened */
    p = CONST_CHARS_STRING(str) + i;
    limbs = ADDR_INT(res);

    /* if len is not divisible by 2*sizeof(UInt), then take care of the extra bytes */
    UInt diff = len - nd * (2*sizeof(UInt));
    if ( diff ) {
        n = hexstr2int( p, diff );
        p += diff;
        len -= diff;
        limbs[nd--] = n;
    }

    /*  */
    while ( len ) {
        n = hexstr2int( p, 2*sizeof(UInt) );
        p += 2*sizeof(UInt);
        len -= 2*sizeof(UInt);
        limbs[nd--] = n;
    }

    res = GMP_NORMALIZE(res);
    res = GMP_REDUCE(res);
    return res;
  }
}


/****************************************************************************
**  
**  Implementation of Log2Int for C integers.
**
**  When available, we try to use GCC builtins. Otherwise, fall back to code
**  based on
**   https://graphics.stanford.edu/~seander/bithacks.html#IntegerLogLookup
**  On a test machine with x86 64bit, the builtins are about 4 times faster
**  than the generic code.
**
*/

static Int CLog2UInt(UInt a)
{
#if SIZEOF_VOID_P == SIZEOF_INT && defined(HAVE___BUILTIN_CLZ)
  return GMP_LIMB_BITS - 1 - __builtin_clz(a);
#elif SIZEOF_VOID_P == SIZEOF_LONG && defined(HAVE___BUILTIN_CLZL)
  return GMP_LIMB_BITS - 1 - __builtin_clzl(a);
#elif SIZEOF_VOID_P == SIZEOF_LONG_LONG && defined(HAVE___BUILTIN_CLZLL)
  return GMP_LIMB_BITS - 1 - __builtin_clzll(a);
#else
    static const char LogTable256[256] = {
       -1, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3,
        4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
        6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
        7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
    };

    Int res = 0;
    UInt b;
    b = a >> 32; if (b) { res+=32; a=b; }
    b = a >> 16; if (b) { res+=16; a=b; }
    b = a >>  8; if (b) { res+= 8; a=b; }
    return res + LogTable256[a];
#endif
}

Int CLog2Int(Int a)
{
  if (a == 0) return -1;
  if (a < 0) a = -a;
  return CLog2UInt(a);
}

/****************************************************************************
**
*F  FuncLog2Int( <self>, <n> ) . . . . . . . . . . . nr of bits of a GAP int
**
**  Given to GAP-Level as "Log2Int".
*/
static Obj FuncLog2Int(Obj self, Obj n)
{
    RequireInt(SELF_NAME, n);

    if (IS_INTOBJ(n)) {
        return INTOBJ_INT(CLog2Int(INT_INTOBJ(n)));
    }

    UInt len = SIZE_INT(n) - 1;
    UInt a = CLog2UInt(CONST_ADDR_INT(n)[len]);

    CHECK_INT(n);

#ifdef SYS_IS_64_BIT
    return INTOBJ_INT(len * GMP_LIMB_BITS + a);
#else
    /* The final result is len * GMP_LIMB_BITS - d, which may not
       fit into an immediate integer (at least on a 32bit system) */
    return SumInt(ProdInt(INTOBJ_INT(len), INTOBJ_INT(GMP_LIMB_BITS)),
                   INTOBJ_INT(a));
#endif
}

/****************************************************************************
**
*F  FuncSTRING_INT( <self>, <n> ) . . . . . .  convert an integer to a string
**
**  `FuncSTRING_INT' returns an immutable string representing the integer <n>
**
*/
static Obj FuncSTRING_INT(Obj self, Obj n)
{
    RequireInt(SELF_NAME, n);
    return StringIntBase(n, 10);
}


Obj IntStringInternal(Obj string, const Char *str)
{
    Obj     val;  // value = <upp> * <pow> + <low>
    Obj     upp;  // upper part
    Int     pow;  // power
    Int     low;  // lower part
    Int     sign; // is the integer negative
    UInt    i;    // loop variable

    // if <string> is given, then we ignore <str>
    if (string)
        str = CONST_CSTR_STRING(string);

    // get the sign, if any
    sign = 1;
    i = 0;
    if (str[i] == '-') {
        sign = -sign;
        i++;
    }

    // collect the digits in groups of 8, for improved performance
    // note that 2^26 < 10^8 < 2^27, so the intermediate
    // values always fit into an immediate integer
    low = 0;
    pow = 1;
    upp = INTOBJ_INT(0);
    while (str[i] != '\0') {
        if (str[i] < '0' || str[i] > '9') {
            return Fail;
        }
        low = 10 * low + str[i] - '0';
        pow = 10 * pow;
        if (pow == 100000000L) {
            upp = ProdInt(upp, INTOBJ_INT(pow));
            upp = SumInt(upp, INTOBJ_INT(sign*low));
            // refresh 'str', in case the arithmetic operations triggered
            // a garbage collection
            if (string)
                str = CONST_CSTR_STRING(string);
            pow = 1;
            low = 0;
        }
        i++;
    }

    // check if 0 char does not mark the end of the string
    if (string && i < GET_LEN_STRING(string))
        return Fail;

    // compose the integer value
    if (upp == INTOBJ_INT(0)) {
        val = INTOBJ_INT(sign * low);
    }
    else if (pow == 1) {
        val = upp;
    }
    else {
        upp = ProdInt(upp, INTOBJ_INT(pow));
        val = SumInt(upp, INTOBJ_INT(sign * low));
    }

    // return the integer value
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
static Obj FuncINT_STRING(Obj self, Obj string)
{
    if( !IS_STRING(string) ) {
        return Fail;
    }

    if( !IS_STRING_REP(string) ) {
        string = CopyToStringRep(string);
    }

    return IntStringInternal(string, 0);
}

/****************************************************************************
**
*F  EqInt( <opL>, <opR> ) . . . . . . . . . .  test if two integers are equal
**
**  'EqInt' returns 1 if the two integer arguments <opL> and <opR> are equal
**  and 0 otherwise.
*/
Int EqInt(Obj opL, Obj opR)
{
    CHECK_INT(opL);
    CHECK_INT(opR);

    // if at least one input is a small int, a naive equality test suffices
    if (IS_INTOBJ(opL) || IS_INTOBJ(opR))
        return opL == opR;

    // compare the sign and size
    // note: at this point we know that opL and opR are proper bags, so
    // we can use TNUM_BAG instead of TNUM_OBJ
    if (TNUM_BAG(opL) != TNUM_BAG(opR) || SIZE_INT(opL) != SIZE_INT(opR))
        return 0;

    return !mpn_cmp((mp_srcptr)CONST_ADDR_INT(opL),
                (mp_srcptr)CONST_ADDR_INT(opR), SIZE_INT(opL));
}

/****************************************************************************
**
*F  LtInt( <opL>, <opR> ) . . . . . . test if an integer is less than another
**
**  'LtInt' returns 1 if the integer <opL> is strictly less than the
**  integer <opR> and 0 otherwise.
*/
Int LtInt(Obj opL, Obj opR)
{
    Int res;

    CHECK_INT(opL);
    CHECK_INT(opR);

    /* compare two small integers */
    if (ARE_INTOBJS(opL, opR))
        return (Int)opL < (Int)opR;

    // a small int is always less than a positive large int,
    // and always more than a negative large int
    if (IS_INTOBJ(opL))
        return IS_INTPOS(opR);
    if (IS_INTOBJ(opR))
        return IS_INTNEG(opL);

    // at this point, both inputs are large integers, and we compare their
    // signs first
    if (TNUM_OBJ(opL) != TNUM_OBJ(opR))
        return IS_INTNEG(opL);

    /* signs are equal; compare sizes and absolute values */
    if (SIZE_INT(opL) < SIZE_INT(opR))
        res = -1;
    else if (SIZE_INT(opL) > SIZE_INT(opR))
        res = +1;
    else
        res = mpn_cmp((mp_srcptr)CONST_ADDR_INT(opL),
                      (mp_srcptr)CONST_ADDR_INT(opR), SIZE_INT(opL));

    /* if both arguments are negative, flip the result */
    if (IS_INTNEG(opL))
        res = -res;

    return res < 0;
}


/****************************************************************************
**
*F  SumOrDiffInt( <opL>, <opR>, <sign> ) . . . .  sum or diff of two integers
**
**  'SumOrDiffInt' returns the sum or difference of the two integer arguments
**  <opL> and <opR>, depending on whether sign is +1 or -1.
**
**  'SumOrDiffInt'  is a little  bit  tricky since  there are  many different
**  cases to handle: each operand can be positive or negative, small or large
**  integer.
*/
static Obj SumOrDiffInt(Obj opL, Obj opR, Int sign)
{
  UInt sizeL, sizeR;
  fake_mpz_t mpzL, mpzR, mpzResult;
  Obj result;

  CHECK_INT(opL);
  CHECK_INT(opR);

  /* handle trivial cases first */
  if (opR == INTOBJ_INT(0))
    return opL;
  if (opL == INTOBJ_INT(0)) {
    if (sign == 1)
      return opR;
    else
      return AInvInt(opR);
  }

  sizeL = SIZE_INT_OR_INTOBJ(opL);
  sizeR = SIZE_INT_OR_INTOBJ(opR);

  NEW_FAKEMPZ( mpzResult, sizeL > sizeR ? sizeL+1 : sizeR+1 );
  FAKEMPZ_GMPorINTOBJ(mpzL, opL);
  FAKEMPZ_GMPorINTOBJ(mpzR, opR);

  /* add or subtract */
  if (sign == 1)
    mpz_add( MPZ_FAKEMPZ(mpzResult), MPZ_FAKEMPZ(mpzL), MPZ_FAKEMPZ(mpzR) );
  else
    mpz_sub( MPZ_FAKEMPZ(mpzResult), MPZ_FAKEMPZ(mpzL), MPZ_FAKEMPZ(mpzR) );

  /* convert result to GAP object and return it */
  CHECK_FAKEMPZ(mpzResult);
  CHECK_FAKEMPZ(mpzL);
  CHECK_FAKEMPZ(mpzR);
  result = GMPorINTOBJ_FAKEMPZ( mpzResult );
  CHECK_INT(result);
  return result;
}


/****************************************************************************
**
*F  SumInt( <opL>, <opR> ) . . . . . . . . . . . . . . .  sum of two integers
**
*/
inline Obj SumInt(Obj opL, Obj opR)
{
    Obj sum;

    if (!ARE_INTOBJS(opL, opR) || !SUM_INTOBJS(sum, opL, opR))
        sum = SumOrDiffInt(opL, opR, +1);

    CHECK_INT(sum);
    return sum;
}


/****************************************************************************
**
*F  DiffInt( <opL>, <opR> ) . . . . . . . . . . .  difference of two integers
**
*/
inline Obj DiffInt(Obj opL, Obj opR)
{
    Obj dif;

    if (!ARE_INTOBJS(opL, opR) || !DIFF_INTOBJS(dif, opL, opR))
        dif = SumOrDiffInt(opL, opR, -1);

    CHECK_INT(dif);
    return dif;
}


/****************************************************************************
**
*F  ZeroInt(<op>)  . . . . . . . . . . . . . . . . . . . . . zero of integers
*/
static Obj ZeroInt(Obj op)
{
    return INTOBJ_INT(0);
}


/****************************************************************************
**
*F  AInvInt( <op> ) . . . . . . . . . . . . .  additive inverse of an integer
*/
Obj AInvInt(Obj op)
{
  Obj inv;

  CHECK_INT(op);

  // handle small integer
  if (IS_INTOBJ(op)) {
    
    // special case (ugh)
    if (op == INTOBJ_MIN) {
      inv = NewBag( T_INTPOS, sizeof(mp_limb_t) );
      SET_VAL_LIMB0( inv, -INT_INTOBJ_MIN );
    }
    
    // general case
    else {
      inv = INTOBJ_INT(-INT_INTOBJ(op));
    }
    
  }

  else {
    if (IS_INTPOS(op)) {
      // special case
      if (SIZE_INT(op) == 1 && VAL_LIMB0(op) == -INT_INTOBJ_MIN) {
        return INTOBJ_MIN;
      }
      else {
        inv = NewBag( T_INTNEG, SIZE_OBJ(op) );
      }
    }
    
    else {
      inv = NewBag( T_INTPOS, SIZE_OBJ(op) );
    }

    memcpy( ADDR_INT(inv), CONST_ADDR_INT(op), SIZE_OBJ(op) );
  }
  
  CHECK_INT(inv);
  return inv;

}

/****************************************************************************
**
*F  AbsInt(<op>) . . . . . . . . . . . . . . . . absolute value of an integer
*/
Obj AbsInt( Obj op )
{
  Obj a;
  if ( IS_INTOBJ(op) ) {
    if ( ((Int)op) > 0 ) /* non-negative? */
      return op;
    else if ( op == INTOBJ_MIN ) {
      a = NewBag( T_INTPOS, sizeof(mp_limb_t) );
      SET_VAL_LIMB0( a, -INT_INTOBJ_MIN );
      return a;
    } else
      return (Obj)( 2 - (Int)op );
  }
  CHECK_INT(op);
  if ( IS_INTPOS(op) ) {
    return op;
  } else if ( IS_INTNEG(op) ) {
    a = NewBag( T_INTPOS, SIZE_OBJ(op) );
    memcpy( ADDR_INT(a), CONST_ADDR_INT(op), SIZE_OBJ(op) );
    return a;
  }
  return Fail;
}

static Obj FuncABS_INT(Obj self, Obj n)
{
    RequireInt(SELF_NAME, n);
    Obj res = AbsInt(n);
    CHECK_INT(res);
    return res;
}

/****************************************************************************
**
*F  SignInt(<op>) . . . . . . . . . . . . . . . . . . . .  sign of an integer
*/
Obj SignInt( Obj op )
{
  if ( IS_INTOBJ(op) ) {
    if ( op == INTOBJ_INT(0) )
      return INTOBJ_INT(0);
    else if ( ((Int)op) > (Int)INTOBJ_INT(0) )
      return INTOBJ_INT(1);
    else
      return INTOBJ_INT(-1);
  }
  CHECK_INT(op);
  if ( IS_INTPOS(op) ) {
    return INTOBJ_INT(1);
  } else if ( IS_INTNEG(op) ) {
    return INTOBJ_INT(-1);
  }
  return Fail;
}

static Obj FuncSIGN_INT(Obj self, Obj n)
{
    RequireInt(SELF_NAME, n);
    Obj res = SignInt(n);
    CHECK_INT(res);
    return res;
}


/****************************************************************************
**
*F  ProdInt( <opL>, <opR> ) . . . . . . . . . . . . . product of two integers
**
**  'ProdInt' returns the product of the two  integer  arguments  <opL>  and
**  <opR>.
*/
Obj ProdInt(Obj opL, Obj opR)
{
  Obj                 prd;            /* handle of the result bag          */
  UInt sizeL, sizeR;
  fake_mpz_t mpzL, mpzR, mpzResult;

  CHECK_INT(opL);
  CHECK_INT(opR);

  /* multiplying two small integers                                        */
  if ( ARE_INTOBJS( opL, opR ) ) {
    
    /* multiply two small integers with a small product                    */
    if ( PROD_INTOBJS( prd, opL, opR ) ) {
      CHECK_INT(prd);
      return prd;
    }
  }

  /* handle trivial cases first */
  if ( opL == INTOBJ_INT(0) || opR == INTOBJ_INT(1) )
    return opL;
  if ( opR == INTOBJ_INT(0) || opL == INTOBJ_INT(1) )
    return opR;
  if ( opR == INTOBJ_INT(-1) )
    return AInvInt( opL );
  if ( opL == INTOBJ_INT(-1) )
    return AInvInt( opR );

  sizeL = SIZE_INT_OR_INTOBJ(opL);
  sizeR = SIZE_INT_OR_INTOBJ(opR);

  NEW_FAKEMPZ( mpzResult, sizeL + sizeR );
  FAKEMPZ_GMPorINTOBJ( mpzL, opL );
  FAKEMPZ_GMPorINTOBJ( mpzR, opR );

  /* multiply */
  mpz_mul( MPZ_FAKEMPZ(mpzResult), MPZ_FAKEMPZ(mpzL), MPZ_FAKEMPZ(mpzR) );
  
  /* convert result to GAP object and return it */
  CHECK_FAKEMPZ(mpzResult);
  CHECK_FAKEMPZ(mpzL);
  CHECK_FAKEMPZ(mpzR);
  prd = GMPorINTOBJ_FAKEMPZ( mpzResult );
  CHECK_INT(prd);
  return prd;
}


/****************************************************************************
**
*F  ProdIntObj(<n>,<op>)  . . . . . . . . product of an integer and an object
*/
static Obj ProdIntObj ( Obj n, Obj op )
{
  Obj                 res = 0;        /* result                            */
  UInt                i, k;           /* loop variables                    */
  mp_limb_t             l;              /* loop variable                     */

  CHECK_INT(n);

  /* if the integer is zero, return the neutral element of the operand     */
  if ( n == INTOBJ_INT(0) ) {
    res = ZERO( op );
  }
  
  /* if the integer is one, return the object if immutable -
     if mutable, add the object to its ZeroSameMutability to
     ensure correct mutability propagation                                 */
  else if ( n == INTOBJ_INT(1) ) {
    if (IS_MUTABLE_OBJ(op))
      res = SUM(ZERO(op),op);
    else
      res = op;
  }
  
  /* if the integer is minus one, return the inverse of the operand        */
  else if ( n == INTOBJ_INT(-1) ) {
    res = AINV( op );
  }
  
  /* if the integer is negative, invert the operand and the integer        */
  else if ( IS_NEG_INT(n) ) {
    res = AINV( op );
    if ( res == Fail ) {
      ErrorMayQuit("Operations: <obj> must have an additive inverse", 0, 0);
    }
    res = PROD( AINV( n ), res );
  }

  /* if the integer is small, compute the product by repeated doubling     */
  /* the loop invariant is <result> = <k>*<res> + <l>*<op>, <l> < <k>      */
  /* <res> = 0 means that <res> is the neutral element                     */
  else if ( IS_INTOBJ(n) && INT_INTOBJ(n) >   1 ) {
    res = 0;
    k = (Int)1 << NR_SMALL_INT_BITS;
    l = INT_INTOBJ(n);
    while ( 0 < k ) {
      res = (res == 0 ? res : SUM( res, res ));
      if ( k <= l ) {
        res = (res == 0 ? op : SUM( res, op ));
        l = l - k;
      }
      k = k / 2;
    }
  }
  
  /* if the integer is large, compute the product by repeated doubling     */
  else if ( IS_INTPOS(n) ) {
    res = 0;
    for ( i = SIZE_INT(n); 0 < i; i-- ) {
      k = 8*sizeof(mp_limb_t);
      l = CONST_ADDR_INT(n)[i-1];
      while ( 0 < k ) {
        res = (res == 0 ? res : SUM( res, res ));
        k--;
        if ( (l >> k) & 1 ) {
          res = (res == 0 ? op : SUM( res, op ));
        }
      }
    }
  }
  
  return res;
}

static Obj FuncPROD_INT_OBJ(Obj self, Obj opL, Obj opR)
{
  return ProdIntObj( opL, opR );
}


/****************************************************************************
**
*F  OneInt(<op>) . . . . . . . . . . . . . . . . . . . . .  one of an integer
*/
static Obj OneInt(Obj op)
{
  return INTOBJ_INT( 1 );
}


/****************************************************************************
**
*F  PowInt( <opL>, <opR> ) . . . . . . . . . . . . . . .  power of an integer
**
**  'PowInt' returns the <opR>-th (an integer) power of the integer <opL>.
*/
Obj PowInt ( Obj opL, Obj opR )
{
  Int                 i;
  Obj                 pow;

  CHECK_INT(opL);
  CHECK_INT(opR);

  if ( opR == INTOBJ_INT(0) ) {
    pow = INTOBJ_INT(1);
  }
  else if ( opL == INTOBJ_INT(0) ) {
    if ( IS_NEG_INT( opR ) ) {
      ErrorMayQuit("Integer operands: <base> must not be zero", 0, 0);
    }
    pow = INTOBJ_INT(0);
  }
  else if ( opL == INTOBJ_INT(1) ) {
    pow = INTOBJ_INT(1);
  }
  else if ( opL == INTOBJ_INT(-1) ) {
    pow = IS_EVEN_INT(opR) ? INTOBJ_INT(1) : INTOBJ_INT(-1);
  }

  /* power with a large exponent */
  else if ( ! IS_INTOBJ(opR) ) {
    ErrorMayQuit("Integer operands: <exponent> is too large", 0, 0);
  }
  
  /* power with a negative exponent */
  else if ( INT_INTOBJ(opR) < 0 ) {
    pow = QUO( INTOBJ_INT(1),
               PowInt( opL, INTOBJ_INT( -INT_INTOBJ(opR)) ) );
  }
  
  /* findme - can we use the gmp function mpz_n_pow_ui? */

  /* power with a small positive exponent, do it by a repeated squaring  */
  else {
    pow = INTOBJ_INT(1);
    i = INT_INTOBJ(opR);
    while ( i != 0 ) {
      if ( i % 2 == 1 )  pow = ProdInt( pow, opL );
      if ( i     >  1 )  opL = ProdInt( opL, opL );
      TakeInterrupt();
      i = i / 2;
    }
  }
  
  /* return the power */
  CHECK_INT(pow);
  return pow;
}


/****************************************************************************
**
*F  PowObjInt(<op>,<n>) . . . . . . . . . . power of an object and an integer
*/
static Obj PowObjInt(Obj op, Obj n)
{
  Obj                 res = 0;        /* result                          */
  UInt                i, k;           /* loop variables                  */
  mp_limb_t             l;              /* loop variable                   */
  
  CHECK_INT(n);

  /* if the integer is zero, return the neutral element of the operand   */
  if ( n == INTOBJ_INT(0) ) {
    return ONE_MUT( op );
  }
  
  /* if the integer is one, return a copy of the operand                 */
  else if ( n == INTOBJ_INT(1) ) {
    res = CopyObj( op, 1 );
  }
  
  /* if the integer is minus one, return the inverse of the operand      */
  else if ( n == INTOBJ_INT(-1) ) {
    res = INV_MUT( op );
  }
  
  /* if the integer is negative, invert the operand and the integer      */
  else if ( IS_NEG_INT(n) ) {
    res = INV_MUT( op );
    if ( res == Fail ) {
      ErrorMayQuit("Operations: <obj> must have an inverse", 0, 0);
    }
    res = POW( res, AINV( n ) );
  }
  
  /* if the integer is small, compute the power by repeated squaring     */
  /* the loop invariant is <result> = <res>^<k> * <op>^<l>, <l> < <k>    */
  /* <res> = 0 means that <res> is the neutral element                   */
  else if ( IS_INTOBJ(n) && INT_INTOBJ(n) >   0 ) {
    res = 0;
    k = (Int)1 << NR_SMALL_INT_BITS;
    l = INT_INTOBJ(n);
    while ( 0 < k ) {
      res = (res == 0 ? res : PROD( res, res ));
      if ( k <= l ) {
        res = (res == 0 ? op : PROD( res, op ));
        l = l - k;
      }
      k = k / 2;
    }
  }
  
  /* if the integer is large, compute the power by repeated squaring     */
  else if ( IS_INTPOS(n) ) {
    res = 0;
    for ( i = SIZE_INT(n); 0 < i; i-- ) {
      k = 8*sizeof(mp_limb_t);
      l = CONST_ADDR_INT(n)[i-1];
      while ( 0 < k ) {
        res = (res == 0 ? res : PROD( res, res ));
        k--;
        if ( (l >> k) & 1 ) {
          res = (res == 0 ? op : PROD( res, op ));
        }
      }
    }
  }

  return res;
}

static Obj FuncPOW_OBJ_INT(Obj self, Obj opL, Obj opR)
{
  return PowObjInt( opL, opR );
}


/****************************************************************************
**
*F  ModInt( <opL>, <opR> ) . .  representative of residue class of an integer
**
**  'ModInt' returns the smallest positive representative of the residue
**  class of the integer <opL> modulo the integer <opR>.
*/
Obj ModInt(Obj opL, Obj opR)
{
  Int                    i;             /* loop count, value for small int */
  Int                    k;             /* loop count, value for small int */
  UInt                   c;             /* product of two digits           */
  Obj                  mod;             /* handle of the remainder bag     */
  Obj                  quo;             /* handle of the quotient bag      */

  CHECK_INT(opL);
  CHECK_INT(opR);

  /* pathological case first                                             */
  RequireNonzero("Integer operations", opR, "divisor");

  /* compute the remainder of two small integers                           */
  if ( ARE_INTOBJS( opL, opR ) ) {
    
    /* get the integer values                                              */
    i = INT_INTOBJ(opL);
    k = INT_INTOBJ(opR);
    
    /* compute the remainder, make sure we divide only positive numbers    */
    i %= k;
    if (i < 0)
        i += k > 0 ? k : -k;
    mod = INTOBJ_INT(i);
  }
  
  /* compute the remainder of a small integer by a large integer           */
  else if ( IS_INTOBJ(opL) ) {
    
    /* the small int -(1<<28) mod the large int (1<<28) is 0               */
    if ( opL == INTOBJ_MIN
         && ( IS_INTPOS(opR) )
         && ( SIZE_INT(opR) == 1 )
         && ( VAL_LIMB0(opR) == -INT_INTOBJ_MIN ) )
      mod = INTOBJ_INT(0);
    
    /* in all other cases the remainder is equal the left operand          */
    else if ( 0 <= INT_INTOBJ(opL) )
      mod = opL;
    else if ( IS_INTPOS(opR) )
      mod = SumOrDiffInt( opL, opR,  1 );
    else
      mod = SumOrDiffInt( opL, opR, -1 );
  }
  
  /* compute the remainder of a large integer by a small integer           */
  else if ( IS_INTOBJ(opR) ) {
    
    /* get the integer value, make positive                                */
    i = INT_INTOBJ(opR);  if ( i < 0 )  i = -i;
    
    /* check whether right operand is a small power of 2                   */
    if ( !(i & (i-1)) ) {
      c = VAL_LIMB0(opL) & (i-1);
    }
    
    /* otherwise use the gmp function to divide                            */
    else {
      c = mpn_mod_1( (mp_srcptr)CONST_ADDR_INT(opL), SIZE_INT(opL), i );
    }
    
    // now c is the absolute value of the actual result. Thus, if the left
    // operand is negative, and c is non-zero, we have to adjust it.
    if (IS_INTPOS(opL) || c == 0)
      mod = INTOBJ_INT( c );
    else
      // even if opR is INT_INTOBJ_MIN, and hence i is INT_INTOBJ_MAX+1, we
      // have 0 <= i-c <= INT_INTOBJ_MAX, so i-c fits into a small integer
      mod = INTOBJ_INT( i - (Int)c );
    
  }
  
  /* compute the remainder of a large integer modulo a large integer       */
  else {

    /* trivial case first                                                  */
    if ( SIZE_INT(opL) < SIZE_INT(opR) ) {
      if ( IS_INTPOS(opL) )
        return opL;
      else if ( IS_INTPOS(opR) )
        mod = SumOrDiffInt( opL, opR,  1 );
      else
        mod = SumOrDiffInt( opL, opR, -1 );
#if DEBUG_GMP
      assert( !IS_NEG_INT(mod) );
#endif
      CHECK_INT(mod);
      return mod;
    }
    
    mod = NewBag( TNUM_OBJ(opL), (SIZE_INT(opL)+1)*sizeof(mp_limb_t) );
    ENSURE_BAG(mod);

    quo = NewBag( T_INTPOS,
                   (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(mp_limb_t) );
    ENSURE_BAG(quo);

    /* and let gmp do the work                                             */
    mpn_tdiv_qr( (mp_ptr)ADDR_INT(quo), (mp_ptr)ADDR_INT(mod), 0,
                 (mp_srcptr)CONST_ADDR_INT(opL), SIZE_INT(opL),
                 (mp_srcptr)CONST_ADDR_INT(opR), SIZE_INT(opR)    );
      
    /* reduce to small integer if possible, otherwise shrink bag           */
    mod = GMP_NORMALIZE( mod );
    mod = GMP_REDUCE( mod );
    
    /* make the representative positive                                    */
    if ( IS_NEG_INT(mod) ) {
      if ( IS_INTPOS(opR) )
        mod = SumOrDiffInt( mod, opR,  1 );
      else
        mod = SumOrDiffInt( mod, opR, -1 );
    }
    
  }
  
#if DEBUG_GMP
  assert( !IS_NEG_INT(mod) );
#endif
  CHECK_INT(mod);
  return mod;
}


/****************************************************************************
**
*F  QuoInt( <opL>, <opR> ) . . . . . . . . . . . . . quotient of two integers
**
**  'QuoInt' returns the integer part of the two integers <opL> and <opR>.
**
**  Note that this routine is not called from 'EvalQuo', the  division of two
**  integers yields a rational and is therefor performed in 'QuoRat'. This
**  operation is however available through the internal function 'Quo'.
*/
Obj QuoInt(Obj opL, Obj opR)
{
  Int                 i;              /* loop count, value for small int   */
  Int                 k;              /* loop count, value for small int   */
  Obj                 quo;            /* handle of the result bag          */
  Obj                 rem;            /* handle of the remainder bag       */

  CHECK_INT(opL);
  CHECK_INT(opR);

  /* pathological case first                                             */
  RequireNonzero("Integer operations", opR, "divisor");

  /* divide two small integers                                             */
  if ( ARE_INTOBJS( opL, opR ) ) {
    
    /* the small int -(1<<28) divided by -1 is the large int (1<<28)       */
    if ( opL == INTOBJ_MIN && opR == INTOBJ_INT(-1) ) {
      quo = NewBag( T_INTPOS, sizeof(mp_limb_t) );
      SET_VAL_LIMB0( quo, -INT_INTOBJ_MIN );
      return quo;
    }
    
    /* get the integer values                                              */
    i = INT_INTOBJ(opL);
    k = INT_INTOBJ(opR);

    // divide, truncated towards zero; this is also what section 6.5.5 of the
    // C99 standard guarantees for integer division
    quo = INTOBJ_INT(i / k);
  }
  
  /* divide a small integer by a large one                                 */
  else if ( IS_INTOBJ(opL) ) {
    
    /* the small int -(1<<28) divided by the large int (1<<28) is -1       */
    if ( opL == INTOBJ_MIN
         && IS_INTPOS(opR) && SIZE_INT(opR) == 1
         && VAL_LIMB0(opR) == -INT_INTOBJ_MIN )
      quo = INTOBJ_INT(-1);
    
    /* in all other cases the quotient is of course zero                   */
    else
      quo = INTOBJ_INT(0);
    
  }
  
  /* divide a large integer by a small integer                             */
  else if ( IS_INTOBJ(opR) ) {
    
    k = INT_INTOBJ(opR);

    /* allocate a bag for the result and set up the pointers               */
    if ( IS_INTNEG(opL) == ( k < 0 ) )
      quo = NewBag( T_INTPOS, SIZE_OBJ(opL) );
    else
      quo = NewBag( T_INTNEG, SIZE_OBJ(opL) );

    ENSURE_BAG(quo);
    
    if ( k < 0 ) k = -k;

    /* use gmp function for dividing by a 1-limb number                    */
    mpn_divrem_1( (mp_ptr)ADDR_INT(quo), 0,
                  (mp_srcptr)CONST_ADDR_INT(opL), SIZE_INT(opL),
                  k );
  }
  
  /* divide a large integer by a large integer                             */
  else {
    
    /* trivial case first                                                  */
    if ( SIZE_INT(opL) < SIZE_INT(opR) )
      return INTOBJ_INT(0);
    
    /* create a new bag for the remainder                                  */
    rem = NewBag( TNUM_OBJ(opL), (SIZE_INT(opL)+1)*sizeof(mp_limb_t) );
    ENSURE_BAG(rem);

    /* allocate a bag for the quotient                                     */
    if ( TNUM_OBJ(opL) == TNUM_OBJ(opR) )
      quo = NewBag( T_INTPOS, 
                    (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(mp_limb_t) );
    else
      quo = NewBag( T_INTNEG,
                    (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(mp_limb_t) );
    ENSURE_BAG(quo);

    mpn_tdiv_qr( (mp_ptr)ADDR_INT(quo), (mp_ptr)ADDR_INT(rem), 0,
                 (mp_srcptr)CONST_ADDR_INT(opL), SIZE_INT(opL),
                 (mp_srcptr)CONST_ADDR_INT(opR), SIZE_INT(opR) );
  }
  
  quo = GMP_NORMALIZE(quo);
  quo = GMP_REDUCE( quo );
  return quo;
}


/****************************************************************************
**
*F  FuncQUO_INT( <self>, <a>, <b> ) . . . . . . .  internal function 'QuoInt'
**
**  'FuncQUO_INT' implements the internal function 'QuoInt'.
**
**  'QuoInt( <a>, <b> )'
**
**  'Quo' returns the  integer part of the quotient  of its integer operands.
**  If <a>  and <b> are  positive 'Quo( <a>,  <b> )' is  the largest positive
**  integer <q>  such that '<q> * <b>  \<= <a>'.  If  <a> or  <b> or both are
**  negative we define 'Abs( Quo(<a>,<b>) ) = Quo( Abs(<a>), Abs(<b>) )'  and
**  'Sign( Quo(<a>,<b>) ) = Sign(<a>) * Sign(<b>)'.  Dividing by 0  causes an
**  error.  'Rem' (see "Rem") can be used to compute the remainder.
*/
static Obj FuncQUO_INT(Obj self, Obj a, Obj b)
{
    RequireInt(SELF_NAME, a);
    RequireInt(SELF_NAME, b);
    return QuoInt(a, b);
}


/****************************************************************************
**
*F  RemInt( <opL>, <opR> ) . . . . . . . . . . . .  remainder of two integers
**
**  'RemInt' returns the remainder of the quotient  of  the  integers  <opL>
**  and <opR>.
**
**  Note that the remainder is different from the value returned by the 'mod'
**  operator which is always positive, while the result of 'RemInt' has
**  the same sign as <opL>.
*/
Obj RemInt(Obj opL, Obj opR)
{
  Int                 i;              /* loop count, value for small int   */
  Int                 k;              /* loop count, value for small int   */
  UInt                c;
  Obj                 rem;            /* handle of the remainder bag       */
  Obj                 quo;            /* handle of the quotient bag        */

  CHECK_INT(opL);
  CHECK_INT(opR);

  /* pathological case first                                             */
  RequireNonzero("Integer operations", opR, "divisor");

  /* compute the remainder of two small integers                           */
  if ( ARE_INTOBJS( opL, opR ) ) {
    
    /* get the integer values                                              */
    i = INT_INTOBJ(opL);
    k = INT_INTOBJ(opR);

    // compute the remainder with sign matching that of the dividend i;
    // this matches the sign of i % k as specified in section 6.5.5 of
    // the C99 standard, which indicates division truncates towards zero,
    // and the invariant i%k == i - (i/k)*k holds
    rem = INTOBJ_INT(i % k);
  }
  
  /* compute the remainder of a small integer by a large integer           */
  else if ( IS_INTOBJ(opL) ) {
    
    /* the small int -(1<<28) rem the large int (1<<28) is 0               */
    if ( opL == INTOBJ_MIN
         && IS_INTPOS(opR) && SIZE_INT(opR) == 1
         && VAL_LIMB0(opR) == -INT_INTOBJ_MIN )
      rem = INTOBJ_INT(0);
    
    /* in all other cases the remainder is equal the left operand          */
    else
      rem = opL;
  }
  
  /* compute the remainder of a large integer by a small integer           */
  else if ( IS_INTOBJ(opR) ) {
    
    /* get the integer value, make positive                                */
    i = INT_INTOBJ(opR);  if ( i < 0 )  i = -i;

    /* check whether right operand is a small power of 2                   */
    if ( !(i & (i-1)) ) {
      c = VAL_LIMB0(opL) & (i-1);
    }
    
    /* otherwise use the gmp function to divide                            */
    else {
      c = mpn_mod_1( (mp_srcptr)CONST_ADDR_INT(opL), SIZE_INT(opL), i );
    }

    // adjust c for the sign of the left operand
    if ( IS_INTPOS(opL) )
      rem = INTOBJ_INT( c );
    else
      rem = INTOBJ_INT( -(Int)c );
    
  }
  
  /* compute the remainder of a large integer modulo a large integer       */
  else {
    
    /* trivial case first                                                  */
    if ( SIZE_INT(opL) < SIZE_INT(opR) )
      return opL;
    
    rem = NewBag( TNUM_OBJ(opL), (SIZE_INT(opL)+1)*sizeof(mp_limb_t) );
    ENSURE_BAG(rem);
    
    quo = NewBag( T_INTPOS,
                  (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(mp_limb_t) );
    ENSURE_BAG(quo);
    
    /* and let gmp do the work                                             */
    mpn_tdiv_qr( (mp_ptr)ADDR_INT(quo),  (mp_ptr)ADDR_INT(rem), 0,
                 (mp_srcptr)CONST_ADDR_INT(opL), SIZE_INT(opL),
                 (mp_srcptr)CONST_ADDR_INT(opR), SIZE_INT(opR)    );
    
    /* reduce to small integer if possible, otherwise shrink bag           */
    rem = GMP_NORMALIZE( rem );
    rem = GMP_REDUCE( rem );
    
  }
  
  CHECK_INT(rem);
  return rem;
}


/****************************************************************************
**
*F  FuncREM_INT( <self>, <a>, <b> )  . . . . . . . internal function 'RemInt'
**
**  'FuncREM_INT' implements the internal function 'RemInt'.
**
**  'RemInt( <a>, <b> )'
**
**  'RemInt' returns the remainder of its two integer operands, i.e., if <k>
**  is not equal to zero 'Rem( <i>, <k> ) = <i> - <k> *  Quo( <i>, <k> )'.
**  Note that the rules given for 'Quo' imply that 'Rem( <i>, <k> )' has the
**  same sign as <i> and its absolute value is strictly less than the
**  absolute value of <k>.  Dividing by 0 causes an error.
*/
static Obj FuncREM_INT(Obj self, Obj a, Obj b)
{
    RequireInt(SELF_NAME, a);
    RequireInt(SELF_NAME, b);
    return RemInt(a, b);
}


/****************************************************************************
**
*F  GcdInt( <opL>, <opR> ) . . . . . . . . . . . . . . .  gcd of two integers
**
**  'GcdInt' returns the gcd of the two integers <opL> and <opR>.
**
**  It is called from 'FuncGCD_INT' and from the rational package.
*/
Obj GcdInt ( Obj opL, Obj opR )
{
  UInt sizeL, sizeR;
  fake_mpz_t mpzL, mpzR, mpzResult;
  Obj result;

  CHECK_INT(opL);
  CHECK_INT(opR);

  if (opL == INTOBJ_INT(0)) return AbsInt(opR);
  if (opR == INTOBJ_INT(0)) return AbsInt(opL);

  sizeL = SIZE_INT_OR_INTOBJ(opL);
  sizeR = SIZE_INT_OR_INTOBJ(opR);

  // for small inputs, run Euclid directly
  if (sizeL == 1 || sizeR == 1) {
    if (sizeR != 1) {
      SWAP(Obj, opL, opR);
    }
    UInt r = AbsOfSmallInt(opR);
    FAKEMPZ_GMPorINTOBJ(mpzL, opL);
    r = mpz_gcd_ui(0, MPZ_FAKEMPZ(mpzL), r);
    CHECK_FAKEMPZ(mpzL);
    return ObjInt_UInt(r);
  }

  NEW_FAKEMPZ( mpzResult, sizeL < sizeR ? sizeL : sizeR );
  FAKEMPZ_GMPorINTOBJ( mpzL, opL );
  FAKEMPZ_GMPorINTOBJ( mpzR, opR );

  /* compute the gcd */
  mpz_gcd( MPZ_FAKEMPZ(mpzResult), MPZ_FAKEMPZ(mpzL), MPZ_FAKEMPZ(mpzR) );

  /* convert result to GAP object and return it */
  CHECK_FAKEMPZ(mpzResult);
  CHECK_FAKEMPZ(mpzL);
  CHECK_FAKEMPZ(mpzR);
  result = GMPorINTOBJ_FAKEMPZ( mpzResult );
  CHECK_INT(result);
  return result;
}


/****************************************************************************
**
*F  FuncGCD_INT(<self>,<a>,<b>)  . . . . . . .  internal function 'GcdInt'
**
**  'FuncGCD_INT' implements the internal function 'GcdInt'.
**
**  'GcdInt( <a>, <b> )'
**
**  'Gcd'  returns the greatest common divisor   of the two  integers <a> and
**  <b>, i.e.,  the  greatest integer that  divides  both <a>  and  <b>.  The
**  greatest common divisor is never negative, even if the arguments are.  We
**  define $gcd( a, 0 ) = gcd( 0, a ) = abs( a )$ and $gcd( 0, 0 ) = 0$.
*/
static Obj FuncGCD_INT(Obj self, Obj a, Obj b)
{
    RequireInt(SELF_NAME, a);
    RequireInt(SELF_NAME, b);
    return GcdInt(a, b);
}

/****************************************************************************
**
*F  LcmInt( <opL>, <opR> )  . . . . . . . . . . . . . . . lcm of two integers
**
**  'LcmInt' returns the lcm of the two integers <opL> and <opR>.
*/
Obj LcmInt(Obj opL, Obj opR)
{
    UInt       sizeL, sizeR;
    fake_mpz_t mpzL, mpzR, mpzResult;
    Obj        result;

    CHECK_INT(opL);
    CHECK_INT(opR);

    if (opL == INTOBJ_INT(0) || opR == INTOBJ_INT(0))
        return INTOBJ_INT(0);

    if (IS_INTOBJ(opL) || IS_INTOBJ(opR)) {
        if (!IS_INTOBJ(opR)) {
            SWAP(Obj, opL, opR);
        }
        Obj gcd = GcdInt(opL, opR);
        opR = QuoInt(opR, gcd);
        return AbsInt(ProdInt(opL, opR));
    }

    sizeL = SIZE_INT_OR_INTOBJ(opL);
    sizeR = SIZE_INT_OR_INTOBJ(opR);

    NEW_FAKEMPZ(mpzResult, sizeL + sizeR);
    FAKEMPZ_GMPorINTOBJ(mpzL, opL);
    FAKEMPZ_GMPorINTOBJ(mpzR, opR);

    /* compute the gcd */
    mpz_lcm(MPZ_FAKEMPZ(mpzResult), MPZ_FAKEMPZ(mpzL), MPZ_FAKEMPZ(mpzR));

    /* convert result to GAP object and return it */
    CHECK_FAKEMPZ(mpzResult);
    CHECK_FAKEMPZ(mpzL);
    CHECK_FAKEMPZ(mpzR);
    result = GMPorINTOBJ_FAKEMPZ(mpzResult);
    CHECK_INT(result);
    return result;
}

static Obj FuncLCM_INT(Obj self, Obj a, Obj b)
{
    RequireInt(SELF_NAME, a);
    RequireInt(SELF_NAME, b);
    return LcmInt(a, b);
}

/****************************************************************************
**
*/
static Obj FuncFACTORIAL_INT(Obj self, Obj n)
{
    RequireNonnegativeSmallInt(SELF_NAME, n);

    mpz_t mpzResult;
    mpz_init(mpzResult);
    mpz_fac_ui(mpzResult, INT_INTOBJ(n));

    // convert mpzResult into a GAP integer object.
    Obj result = GMPorINTOBJ_MPZ(mpzResult);

    // free mpzResult
    mpz_clear(mpzResult);

    return result;
}


/****************************************************************************
**
*/
Obj BinomialInt(Obj n, Obj k)
{
    Int negate_result = 0;

    // deal with k <= 1
    if (k == INTOBJ_INT(0))
        return INTOBJ_INT(1);
    if (k == INTOBJ_INT(1))
        return n;
    if (IS_NEG_INT(k))
        return INTOBJ_INT(0);

    // deal with n < 0
    if (IS_NEG_INT(n)) {
        // use the identity Binomial(n,k) = (-1)^k * Binomial(-n+k-1, k)
        negate_result = IS_ODD_INT(k);
        n = DiffInt(DiffInt(k,n), INTOBJ_INT(1));
    }

    // deal with n <= k
    if (n == k)
        return negate_result ? INTOBJ_INT(-1) : INTOBJ_INT(1);
    if (LtInt(n, k))
        return INTOBJ_INT(0);

    // deal with n-k < k   <=>  n < 2k
    Obj k2 = DiffInt(n, k);
    if (LtInt(k2, k))
        k = k2;

    // From here on, we only support single limb integers for k. Anything else
    // would lead to output too big for storage anyway, at least on a 64 bit
    // system. To be specific, in that case n >= 2k and k >= 2^60. Thus, in
    // the *best* case, we are trying to compute the central binomial
    // coefficient Binomial(2k k) for k = 2^60. This value is approximately
    // (4^k / sqrt(pi*k)); taking the logarithm and dividing by 8 yields that
    // we need about k/4 = 2^58 bytes to store this value. No computer in the
    // foreseeable future will be able to store the result (and much less
    // compute it in a reasonable time).
    //
    // On 32 bit systems, the limit is k = 2^28, and then the central binomial
    // coefficient Binomial(2k,k) takes up about 64 MB, so that would still be
    // feasible. However, GMP does not support computing binomials when k is
    // larger than a single limb, so we'd have to implement this on our own.
    //
    // Since GAP previously was effectively unable to compute such binomial
    // coefficients (unless you were willing to wait for a few days or so), we
    // simply do not implement this on 32bit systems, and instead return Fail,
    // jut as we do on 64 bit. If somebody complains about this, we can still
    // look into implementing this (and in the meantime, tell the user to use
    // the old GAP version of this function).

    if (SIZE_INT_OR_INTOBJ(k) > 1)
        return Fail;

    UInt K = IS_INTOBJ(k) ? INT_INTOBJ(k) : VAL_LIMB0(k);
    mpz_t mpzResult;
    mpz_init( mpzResult );

    if (SIZE_INT_OR_INTOBJ(n) == 1) {
        UInt N = IS_INTOBJ(n) ? INT_INTOBJ(n) : VAL_LIMB0(n);
        mpz_bin_uiui(mpzResult, N, K);
    } else {
        fake_mpz_t mpzN;
        FAKEMPZ_GMPorINTOBJ( mpzN, n );
        mpz_bin_ui(mpzResult, MPZ_FAKEMPZ(mpzN), K);
    }

    // adjust sign of result
    if (negate_result)
        mpzResult->_mp_size = -mpzResult->_mp_size;

    // convert mpzResult into a GAP integer object.
    Obj result = GMPorINTOBJ_MPZ(mpzResult);

    // free mpzResult
    mpz_clear( mpzResult );

    return result;
}

static Obj FuncBINOMIAL_INT(Obj self, Obj n, Obj k)
{
    RequireInt(SELF_NAME, n);
    RequireInt(SELF_NAME, k);
    return BinomialInt(n, k);
}


/****************************************************************************
**
*/
static Obj FuncJACOBI_INT(Obj self, Obj n, Obj m)
{
  fake_mpz_t mpzL, mpzR;
  int result;

  RequireInt(SELF_NAME, n);
  RequireInt(SELF_NAME, m);

  CHECK_INT(n);
  CHECK_INT(m);

  FAKEMPZ_GMPorINTOBJ(mpzL, n);
  FAKEMPZ_GMPorINTOBJ(mpzR, m);

  result = mpz_kronecker( MPZ_FAKEMPZ(mpzL), MPZ_FAKEMPZ(mpzR) );
  CHECK_FAKEMPZ(mpzL);
  CHECK_FAKEMPZ(mpzR);

  return INTOBJ_INT( result );
}


/****************************************************************************
**
*/
static Obj FuncPVALUATION_INT(Obj self, Obj n, Obj p)
{
  fake_mpz_t mpzN, mpzP;
  mpz_t mpzResult;
  int k;

  RequireInt(SELF_NAME, n);
  RequireInt(SELF_NAME, p);

  CHECK_INT(n);
  CHECK_INT(p);

  RequireNonzero(SELF_NAME, p, "p");

  if (SIZE_INT_OR_INTOBJ(n) == 1 && SIZE_INT_OR_INTOBJ(p) == 1) {
    UInt N = AbsOfSmallInt(n);
    UInt P = AbsOfSmallInt(p);
    if (N == 0 || P == 1) return INTOBJ_INT(0);
    k = 0;
    while (N % P == 0) {
      N /= P;
      k++;
    }
    return INTOBJ_INT(k);
  }

  /* For certain values of p, mpz_remove replaces its "dest" argument
     and tries to deallocate the original mpz_t in it. This means
     we cannot use a fake_mpz_t for it. However, we are not really
     interested in it anyway. */
  mpz_init( mpzResult );
  FAKEMPZ_GMPorINTOBJ( mpzN, n );
  FAKEMPZ_GMPorINTOBJ( mpzP, p );

  k = mpz_remove( mpzResult, MPZ_FAKEMPZ(mpzN), MPZ_FAKEMPZ(mpzP) );
  CHECK_FAKEMPZ(mpzN);
  CHECK_FAKEMPZ(mpzP);

  /* throw away mpzResult -- it equals m / p^k */
  mpz_clear( mpzResult );

  return INTOBJ_INT( k );
}


/****************************************************************************
**
*/
static Obj FuncROOT_INT(Obj self, Obj n, Obj k)
{
    fake_mpz_t n_mpz, result_mpz;

    RequireInt(SELF_NAME, n);
    RequireInt(SELF_NAME, k);

    if (!IS_POS_INT(k))
        ErrorMayQuit("Root: <k> must be a positive integer", 0, 0);
    if (IS_NEG_INT(n) && IS_EVEN_INT(k))
        ErrorMayQuit("Root: <n> is negative but <k> is even", 0, 0);

    if (k == INTOBJ_INT(1) || n == INTOBJ_INT(0))
        return n;

    if (!IS_INTOBJ(k)) {
#ifdef SYS_IS_64_BIT
        // if k is not immediate, i.e., k >= 2^60, then the root is 1 unless
        // n >= 2^k >= 2^(2^60), which means storage for n must be at least
        // 2^60 bits, i.e. 2^57 bytes. That's more RAM than anybody has for
        // the near future.
        return IS_NEG_INT(n) ? INTOBJ_INT(-1) : INTOBJ_INT(1);
#else
        // if k is not immediate, i.e., k >= 2^28, then the root is 1 unless
        // n >= 2^k >= 2^(2^28), which means storage for n must be at least
        // 2^28 bits, i.e., 2^25 bytes, or 2^23 words (each 32 bits).
        if (SIZE_INT_OR_INTOBJ(n) < (1 << 23))
            return IS_NEG_INT(n) ? INTOBJ_INT(-1) : INTOBJ_INT(1);
        else
            return Fail;    // return fail so that high level code can handle
                            // this
#endif
    }

    UInt K = INT_INTOBJ(k);
    UInt root_size = 1 + (SIZE_INT_OR_INTOBJ(n) - 1) / K;
    NEW_FAKEMPZ(result_mpz, root_size);
    FAKEMPZ_GMPorINTOBJ(n_mpz, n);

    if (K == 2)
        mpz_sqrt(MPZ_FAKEMPZ(result_mpz), MPZ_FAKEMPZ(n_mpz));
    else
        mpz_root(MPZ_FAKEMPZ(result_mpz), MPZ_FAKEMPZ(n_mpz), K);

    CHECK_FAKEMPZ(result_mpz);
    CHECK_FAKEMPZ(n_mpz);

    return GMPorINTOBJ_FAKEMPZ(result_mpz);
}


/****************************************************************************
**
*/
Obj InverseModInt(Obj base, Obj mod)
{
    fake_mpz_t base_mpz, mod_mpz, result_mpz;
    int        success;

    CHECK_INT(base);
    CHECK_INT(mod);

    if (mod == INTOBJ_INT(1) || mod == INTOBJ_INT(-1))
        return INTOBJ_INT(0);
    if (base == INTOBJ_INT(0) || mod == INTOBJ_INT(0))
        return Fail;

    // handle small inputs separately
    if (IS_INTOBJ(mod)) {

        Int a = INT_INTOBJ(mod);
        if (a < 0)
            a = -a;

        Int b = INT_INTOBJ(ModInt(base, mod));

        Int aL = 0;    // cofactor of a
        Int bL = 1;    // cofactor of b

        // extended Euclidean algorithm
        while (b != 0) {
            Int hdQ = a / b;
            Int c = b;
            Int cL = bL;
            b = a - hdQ * b;
            bL = aL - hdQ * bL;
            a = c;
            aL = cL;
        }
        if (a != 1)
            return Fail;
        return ModInt(INTOBJ_INT(aL), mod);
    }

    NEW_FAKEMPZ(result_mpz, SIZE_INT_OR_INTOBJ(mod) + 1);
    FAKEMPZ_GMPorINTOBJ(base_mpz, base);
    FAKEMPZ_GMPorINTOBJ(mod_mpz, mod);

    success = mpz_invert(MPZ_FAKEMPZ(result_mpz), MPZ_FAKEMPZ(base_mpz),
                         MPZ_FAKEMPZ(mod_mpz));

    if (!success)
        return Fail;

    CHECK_FAKEMPZ(result_mpz);
    CHECK_FAKEMPZ(base_mpz);
    CHECK_FAKEMPZ(mod_mpz);

    return GMPorINTOBJ_FAKEMPZ(result_mpz);
}

/****************************************************************************
**
*/
static Obj FuncINVMODINT(Obj self, Obj base, Obj mod)
{
    RequireInt(SELF_NAME, base);
    RequireInt(SELF_NAME, mod);
    RequireNonzero(SELF_NAME, mod, "mod");
    return InverseModInt(base, mod);
}


/****************************************************************************
**
*/
static Obj FuncPOWERMODINT(Obj self, Obj base, Obj exp, Obj mod)
{
  fake_mpz_t base_mpz, exp_mpz, mod_mpz, result_mpz;

  RequireInt(SELF_NAME, base);
  RequireInt(SELF_NAME, exp);
  RequireInt(SELF_NAME, mod);

  CHECK_INT(base);
  CHECK_INT(exp);
  CHECK_INT(mod);

  RequireNonzero(SELF_NAME, mod, "mod");
  if ( mod == INTOBJ_INT(1) || mod == INTOBJ_INT(-1) )
    return INTOBJ_INT(0);

  if ( IS_NEG_INT(exp) ) {
    base = InverseModInt( base, mod );
    if (base == Fail)
      ErrorMayQuit("PowerModInt: negative <exp> but <base> is not invertible modulo <mod>", 0, 0);
    exp = AInvInt(exp);
  }

  NEW_FAKEMPZ( result_mpz, SIZE_INT_OR_INTOBJ(mod) );
  FAKEMPZ_GMPorINTOBJ( base_mpz, base );
  FAKEMPZ_GMPorINTOBJ( exp_mpz, exp );
  FAKEMPZ_GMPorINTOBJ( mod_mpz, mod );

  mpz_powm( MPZ_FAKEMPZ(result_mpz), MPZ_FAKEMPZ(base_mpz),
            MPZ_FAKEMPZ(exp_mpz), MPZ_FAKEMPZ(mod_mpz) );

  CHECK_FAKEMPZ(result_mpz);
  CHECK_FAKEMPZ(base_mpz);
  CHECK_FAKEMPZ(exp_mpz);
  CHECK_FAKEMPZ(mod_mpz);

  return GMPorINTOBJ_FAKEMPZ( result_mpz );
}


/****************************************************************************
**
*/
static Obj FuncIS_PROBAB_PRIME_INT(Obj self, Obj n, Obj reps)
{
  fake_mpz_t n_mpz;
  Int res;

  RequireInt(SELF_NAME, n);
  UInt r = GetPositiveSmallInt("IsProbablyPrimeInt", reps);

  CHECK_INT(n);

  FAKEMPZ_GMPorINTOBJ( n_mpz, n );

  res = mpz_probab_prime_p(MPZ_FAKEMPZ(n_mpz), r);

  if (res == 2) return True; /* definitely prime */
  if (res == 0) return False; /* definitely not prime */
  return Fail; /* probably prime */
}


/****************************************************************************
**
** * * * * * * * "Mersenne twister" random numbers  * * * * * * * * * * * * *
**
**  Part of this code for fast generation of 32 bit pseudo random numbers
**  with a period of length 2^19937-1 and a 623-dimensional equidistribution
**  is taken from:
**          http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
**  (Also look in Wikipedia for "Mersenne twister".)
*/

/****************************************************************************
**
*F  RandomIntegerMT( <mtstr>, <nrbits> )
**  
**  Returns an integer with at most <nrbits> bits in uniform distribution. 
**  <nrbits> must be a small integer. <mtstr> is a string as returned by 
**  InitRandomMT.
**  
**  Implementation details are a bit tricky to obtain the same random 
**  integers on 32 bit and 64 bit machines (which have different long
**  integer digit lengths and different ranges of small integers).
**  
*/
static Obj FuncRandomIntegerMT(Obj self, Obj mtstr, Obj nrbits)
{
  Obj res;
  Int i, n, q, r, qoff, len;
  UInt4 *mt;
  UInt4 *pt;
  RequireStringRep(SELF_NAME, mtstr);
  if (GET_LEN_STRING(mtstr) < 2500) {
     ErrorMayQuit(
         "RandomIntegerMT: <mtstr> must be a string with at least 2500 characters",
         0, 0);
  }
  RequireNonnegativeSmallInt(SELF_NAME, nrbits);
  n = INT_INTOBJ(nrbits);

  /* small int case */
  if (n <= NR_SMALL_INT_BITS) {
     mt = (UInt4 *)(ADDR_OBJ(mtstr) + 1);
#ifdef SYS_IS_64_BIT
     if (n <= 32) {
       res = INTOBJ_INT((Int)(nextrandMT_int32(mt) & ((UInt4)-1 >> (32-n))));
     }
     else {
       unsigned long  rd;
       rd = nextrandMT_int32(mt);
       rd += (unsigned long) ((UInt4) nextrandMT_int32(mt) & 
                              ((UInt4)-1 >> (64-n))) << 32;
       res = INTOBJ_INT((Int)rd);
     }
#else
     res = INTOBJ_INT((Int)(nextrandMT_int32(mt) & ((UInt4)-1 >> (32-n))));
#endif
  }
  else {
     /* large int case */
     q = n / 32;
     r = n - q * 32;
     /* qoff = number of 32 bit words we need */
     qoff = q + (r==0 ? 0:1);
     /* len = number of limbs we need (limbs currently are either 32 or 64 bit wide) */
     len = (qoff*4 +  sizeof(mp_limb_t) - 1) / sizeof(mp_limb_t);
     res = NewBag( T_INTPOS, len*sizeof(mp_limb_t) );
     pt = (UInt4*) ADDR_INT(res);
     mt = (UInt4 *)(ADDR_OBJ(mtstr) + 1);
     for (i = 0; i < qoff; i++, pt++) {
       *pt = nextrandMT_int32(mt);
     }
     if (r != 0) {
       /* we generated too many random bits -- chop of the extra bits */
       pt = (UInt4*) ADDR_INT(res);
       pt[qoff-1] = pt[qoff-1] & ((UInt4)(-1) >> (32-r));
     }
#if defined(SYS_IS_64_BIT) && defined(WORDS_BIGENDIAN)
     // swap the halves of the 64bit words to match the
     // little endian resp. 32 bit versions of this code
     pt = (UInt4 *)ADDR_INT(res);
     for (i = 0; i < qoff; i += 2, pt += 2) {
       SWAP(UInt4, pt[0], pt[1]);
     }
#endif
     /* shrink bag if necessary */
     res = GMP_NORMALIZE(res);
     /* convert result if small int */
     res = GMP_REDUCE(res);
  }

  return res;
}

/****************************************************************************
**
**  The following functions only exist to enable use to test the conversion
**  functions (Int_ObjInt, ObjInt_Int, etc.) via a regular .tst file.
*/
static Obj FuncINTERNAL_TEST_CONV_INT(Obj self, Obj val)
{
    Int ival = Int_ObjInt(val);
    return ObjInt_Int(ival);
}

static Obj FuncINTERNAL_TEST_CONV_UINT(Obj self, Obj val)
{
    UInt ival = UInt_ObjInt(val);
    return ObjInt_UInt(ival);
}

static Obj FuncINTERNAL_TEST_CONV_UINTINV(Obj self, Obj val)
{
    UInt ival = UInt_ObjInt(val);
    return ObjInt_UIntInv(ival);
}

static Obj FuncINTERNAL_TEST_CONV_INT8(Obj self, Obj val)
{
    Int8 ival = Int8_ObjInt(val);
    return ObjInt_Int8(ival);
}

static Obj FuncINTERNAL_TEST_CONV_UINT8(Obj self, Obj val)
{
    UInt8 ival = UInt8_ObjInt(val);
    return ObjInt_UInt8(ival);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_INT,    "integer" },
  { T_INTPOS, "large positive integer" },
  { T_INTNEG, "large negative integer" },
  { -1, "" }
};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

  GVAR_FILT(IS_INT, "obj", &IsIntFilt),
  { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_2ARGS(QUO_INT, a, b),
    GVAR_FUNC_1ARGS(ABS_INT, n),
    GVAR_FUNC_1ARGS(SIGN_INT, n),
    GVAR_FUNC_2ARGS(REM_INT, a, b),
    GVAR_FUNC_2ARGS(GCD_INT, a, b),
    GVAR_FUNC_2ARGS(LCM_INT, a, b),
    GVAR_FUNC_2ARGS(PROD_INT_OBJ, opL, opR),
    GVAR_FUNC_2ARGS(POW_OBJ_INT, opL, opR),
    GVAR_FUNC_2ARGS(JACOBI_INT, n, m),
    GVAR_FUNC_1ARGS(FACTORIAL_INT, n),
    GVAR_FUNC_2ARGS(BINOMIAL_INT, n, k),
    GVAR_FUNC_2ARGS(PVALUATION_INT, n, p),
    GVAR_FUNC_2ARGS(ROOT_INT, n, k),
    GVAR_FUNC_3ARGS(POWERMODINT, base, exp, mod),
    GVAR_FUNC_2ARGS(IS_PROBAB_PRIME_INT, n, reps),
    GVAR_FUNC_2ARGS(INVMODINT, base, mod),
    GVAR_FUNC_1ARGS(HexStringInt, n),
    GVAR_FUNC_1ARGS(IntHexString, string),
    GVAR_FUNC_1ARGS(Log2Int, n),
    GVAR_FUNC_1ARGS(STRING_INT, n),
    GVAR_FUNC_1ARGS(INT_STRING, string),
    GVAR_FUNC_2ARGS(RandomIntegerMT, mtstr, nrbits),

    GVAR_FUNC_1ARGS(INTERNAL_TEST_CONV_INT, val),
    GVAR_FUNC_1ARGS(INTERNAL_TEST_CONV_UINT, val),
    GVAR_FUNC_1ARGS(INTERNAL_TEST_CONV_UINTINV, val),
    GVAR_FUNC_1ARGS(INTERNAL_TEST_CONV_INT8, val),
    GVAR_FUNC_1ARGS(INTERNAL_TEST_CONV_UINT8, val),

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel ( StructInitInfo * module )
{
  UInt                t1,  t2;

  if (mp_bits_per_limb != GMP_LIMB_BITS) {
    Panic("GMP limb size mismatch");
  }
  if (INTOBJ_MIN != INTOBJ_INT(INT_INTOBJ_MIN)) {
    Panic("INTOBJ_MIN mismatch");
  }
  if (INTOBJ_MAX != INTOBJ_INT(INT_INTOBJ_MAX)) {
    Panic("INTOBJ_MAX mismatch");
  }

  /* init filters and functions                                            */
  InitHdlrFiltsFromTable( GVarFilts );
  InitHdlrFuncsFromTable( GVarFuncs );
  
  // set the bag type names (for error messages and debugging)
  InitBagNamesFromTable( BagNames );

  /* install the marking functions                                         */
  InitMarkFuncBags( T_INTPOS, MarkNoSubBags );
  InitMarkFuncBags( T_INTNEG, MarkNoSubBags );
  
#ifdef GAP_ENABLE_SAVELOAD
  /* Install the saving methods */
  SaveObjFuncs [ T_INTPOS ] = SaveInt;
  SaveObjFuncs [ T_INTNEG ] = SaveInt;
  LoadObjFuncs [ T_INTPOS ] = LoadInt;
  LoadObjFuncs [ T_INTNEG ] = LoadInt;
#endif
  
  /* install the printing functions                                        */
  PrintObjFuncs[ T_INT    ] = PrintInt;
  PrintObjFuncs[ T_INTPOS ] = PrintInt;
  PrintObjFuncs[ T_INTNEG ] = PrintInt;
  
  /* install the comparison methods                                        */
  for ( t1 = T_INT; t1 <= T_INTNEG; t1++ ) {
    for ( t2 = T_INT; t2 <= T_INTNEG; t2++ ) {
      EqFuncs  [ t1 ][ t2 ] = EqInt;
      LtFuncs  [ t1 ][ t2 ] = LtInt;
    }
  }
  
  /* install the unary arithmetic methods                                  */
  for ( t1 = T_INT; t1 <= T_INTNEG; t1++ ) {
    ZeroFuncs[ t1 ] = ZeroInt;
    ZeroMutFuncs[ t1 ] = ZeroInt;
    AInvFuncs[ t1 ] = AInvInt;
    AInvMutFuncs[ t1 ] = AInvInt;
    OneFuncs [ t1 ] = OneInt;
    OneMutFuncs [ t1 ] = OneInt;
  }

    /* install the default power methods                                   */
  for ( t1 = T_INT; t1 <= T_INTNEG; t1++ ) {
    for ( t2 = FIRST_MULT_TNUM; t2 <= LAST_MULT_TNUM; t2++ ) {
      PowFuncs [ t2 ][ t1 ] = PowObjInt;
    }
    for ( t2 = FIRST_PLIST_TNUM; t2 <= LAST_PLIST_TNUM; t2++ ) {
      PowFuncs [ t2 ][ t1 ] = PowObjInt;
    }
    PowFuncs [ T_RANGE_NSORT ][ t1 ] = PowObjInt;
    PowFuncs [ T_RANGE_SSORT ][ t1 ] = PowObjInt;
  }

  /* install the binary arithmetic methods                                 */
  for ( t1 = T_INT; t1 <= T_INTNEG; t1++ ) {
    for ( t2 = T_INT; t2 <= T_INTNEG; t2++ ) {
      EqFuncs  [ t1 ][ t2 ] = EqInt;
      LtFuncs  [ t1 ][ t2 ] = LtInt;
      SumFuncs [ t1 ][ t2 ] = SumInt;
      DiffFuncs[ t1 ][ t2 ] = DiffInt;
      ProdFuncs[ t1 ][ t2 ] = ProdInt;
      PowFuncs [ t1 ][ t2 ] = PowInt;
      ModFuncs [ t1 ][ t2 ] = ModInt;
    }
  }

  /* gvars to import from the library                                      */
  ImportGVarFromLibrary( "TYPE_INT_SMALL_ZERO", &TYPE_INT_SMALL_ZERO );
  ImportGVarFromLibrary( "TYPE_INT_SMALL_POS",  &TYPE_INT_SMALL_POS );
  ImportGVarFromLibrary( "TYPE_INT_SMALL_NEG",  &TYPE_INT_SMALL_NEG );
  ImportGVarFromLibrary( "TYPE_INT_LARGE_POS", &TYPE_INT_LARGE_POS );
  ImportGVarFromLibrary( "TYPE_INT_LARGE_NEG", &TYPE_INT_LARGE_NEG );

  ImportFuncFromLibrary( "String", &String );
  ImportFuncFromLibrary( "One", &OneAttr);

  /* install the type functions                                          */
  TypeObjFuncs[ T_INT    ] = TypeIntSmall;
  TypeObjFuncs[ T_INTPOS ] = TypeIntLargePos;
  TypeObjFuncs[ T_INTNEG ] = TypeIntLargeNeg;

#ifdef HPCGAP
  MakeBagTypePublic( T_INTPOS );
  MakeBagTypePublic( T_INTNEG );
#endif
  
  return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary ( StructInitInfo *    module )
{
  /* init filters and functions                                            */
  InitGVarFiltsFromTable( GVarFilts );
  InitGVarFuncsFromTable( GVarFuncs );
  
  return 0;
}


/****************************************************************************
**
*F  InitInfoInt() . . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "integer",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoInt ( void )
{
  return &module;
}

#endif /* ! WARD_ENABLED */
