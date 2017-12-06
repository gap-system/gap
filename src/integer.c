/****************************************************************************
**
*W  integer.c                   GAP source                     John McDermott
**
**
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file implements the functions handling GMP integers.
**
**  There are three integer types in GAP: 'T_INT', 'T_INTPOS' and 'T_INTNEG'.
**  Each integer has a unique representation, e.g., an integer that can be
**  represented as 'T_INT' is never represented as 'T_INTPOS' or 'T_INTNEG'.
**
**  In the following, let 'N' be the number of bits in an mp_limb_t (so 32 or
**  64, depending on the system). 'T_INT' is the type of those integers small
**  enough to fit into N-3 bits. Therefore the value range of this small
**  integers is $-2^{N-4}...2^{N-4}-1$. Only these small integers can be used as
**  index expression into sequences.
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
**  structures aligned on even boundaries and therefore have last bit zero. (The
**  second bit is reserved as tag to allow extensions of this scheme.) Using
**  immediates as pointers and dereferencing them gives address errors.
**
**  To aid overflow check the most significant two bits must always be equal,
**  that is to say that the sign bit of immediate integers has a guard bit.
**
**  The macros 'INTOBJ_INT' and 'INT_INTOBJ' should be used to convert between a
**  small integer value and its representation as immediate integer handle.
**
**  'T_INTPOS' and 'T_INTNEG' are the types of positive (respectively, negative)
**  integer values that can not be represented by immediate integers.
**
**  This large integers values are represented as low-level GMP integer objects,
**  that is, in base 2^N. That means that the bag of a large integer has the
**  following form:
**
**      +-------+-------+-------+-------+- - - -+-------+-------+-------+
**      | digit | digit | digit | digit |       | digit | digit | digit |
**      | 0     | 1     | 2     | 3     |       | <n>-2 | <n>-1 | <n>   |
**      +-------+-------+-------+-------+- - - -+-------+-------+-------+
**
**  The value of this is: $d0 + d1 2^N + d2 (2^N)^2 + ... + d_n (2^N)^n$,
**  respectively the negative of this if the type of this object is 'T_INTNEG'.
**
**  Each digit is of course stored as a N bit wide unsigned integer.
**
**  Note that we require that all large integers be normalized (that is, they
**  must not contain leading zero limbs) and reduced (they do not fit into a
**  small integer). Internally, it is possible that a large integer temporarily
**  is not normalized or not reduced, but all kernel functions must make sure
**  that they eventually return normalized and reduced values. The function
**  GMP_NORMALIZE and GMP_REDUCE can be used to ensure this.
*/

#include <src/integer.h>

#include <src/ariths.h>
#include <src/bool.h>
#include <src/calls.h>
#include <src/gap.h>
#include <src/intfuncs.h>
#include <src/io.h>
#include <src/opers.h>
#include <src/saveload.h>
#include <src/stats.h>
#include <src/stringobj.h>

#include <stdio.h>


/* TODO: Remove after Ward2 */
#ifndef WARD_ENABLED

// GMP must be included outside of 'extern C'
#ifdef GAP_IN_EXTERN_C
}
#endif
#include <gmp.h>
#ifdef GAP_IN_EXTERN_C
extern "C" {
#endif

#ifdef SYS_IS_64_BIT
#define SaveLimb SaveUInt8
#define LoadLimb LoadUInt8
#else
#define SaveLimb SaveUInt4
#define LoadLimb LoadUInt4
#endif


static Obj ObjInt_UIntInv( UInt i );


/* debugging */
#ifndef DEBUG_GMP
#define DEBUG_GMP 0
#endif

#if defined(__STDC_VERSION__) && (__STDC_VERSION__ >= 199901)
#  define CURRENT_FUNCTION	__func__
#elif defined(_MSC_VER)
#  define CURRENT_FUNCTION __FUNCTION__
#else
#  define CURRENT_FUNCTION "<unknown>"
#endif

#if DEBUG_GMP
#define CHECK_INT(op)  IS_NORMALIZED_AND_REDUCED(op, CURRENT_FUNCTION, __LINE__)
#else
#define CHECK_INT(op)  do { } while(0);
#endif


/* macros to save typing later :)  */
#define VAL_LIMB0(obj)          (*CONST_ADDR_INT(obj))
#define SET_VAL_LIMB0(obj,val)  do { *ADDR_INT(obj) = val; } while(0)
#define IS_INTPOS(obj)          (TNUM_OBJ(obj) == T_INTPOS)
#define IS_INTNEG(obj)          (TNUM_OBJ(obj) == T_INTNEG)

#define SIZE_INT_OR_INTOBJ(obj) (IS_INTOBJ(obj) ? 1 : SIZE_INT(obj))

#define REQUIRE_INT_ARG(funcname, argname, op) \
    if ( !IS_INT(op) ) { \
      ErrorMayQuit( funcname ": <" argname "> must be an integer (not a %s)", \
                         (Int)TNAM_OBJ(op), 0L ); \
    }

GAP_STATIC_ASSERT( sizeof(mp_limb_t) == sizeof(Int), "gmp limb size incompatible with GAP word size");

    
/* for fallbacks to library */
static Obj String;
static Obj OneAttr;
static Obj IsIntFilt;


/****************************************************************************
**
*F  TypeInt(<gmp>)  . . . . . . . . . . . . . . . . . . .  type of integer
**
**  'TypeInt' returns the type of the integer <gmp>.
**
**  'TypeInt' is the function in 'TypeObjFuncs' for integers.
*/
Obj             TYPE_INT_SMALL_ZERO;
Obj             TYPE_INT_SMALL_POS;
Obj             TYPE_INT_SMALL_NEG;
Obj             TYPE_INT_LARGE_POS;
Obj             TYPE_INT_LARGE_NEG;

Obj             TypeIntSmall (
    Obj                 val )
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

Obj TypeIntLargePos ( Obj val )
{
    return TYPE_INT_LARGE_POS;
}

Obj TypeIntLargeNeg ( Obj val )
{
    return TYPE_INT_LARGE_NEG;
}


/****************************************************************************
**
*F  FuncIS_INT( <self>, <val> ) . . . . . . . . . . internal function 'IsInt'
**
**  'FuncIS_INT' implements the internal filter 'IsInt'.
**
**  'IsInt( <val> )'
**
**  'IsInt'  returns 'true'  if the  value  <val>  is a small integer or a
**  large int, and 'false' otherwise.
*/
Obj FuncIS_INT ( Obj self, Obj val )
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
*F  SaveInt( <gmp> )
**
**  
*/
void SaveInt( Obj gmp )
{
  const mp_limb_t *ptr = CONST_ADDR_INT(gmp);
  for (UInt i = 0; i < SIZE_INT(gmp); i++)
    SaveLimb(*ptr++);
  return;
}


/****************************************************************************
**
*F  LoadInt( <gmp> )
**
**
*/
void LoadInt( Obj gmp )
{
  mp_limb_t *ptr = ADDR_INT(gmp);
  for (UInt i = 0; i < SIZE_INT(gmp); i++)
    *ptr++ = LoadLimb();
  return;
}


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
**  Setup a fake mpz_t object for capturing the output of a GMP mpz_* function,
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
  Int size = v->_mp_size;
  Obj obj;
  if ( size == 0 )
    obj = INTOBJ_INT(0);
  else if ( size == 1 )
    obj = ObjInt_UInt( v->_mp_d[0] );
  else if ( size == -1 )
    obj = ObjInt_UIntInv( v->_mp_d[0] );
  else {
    Int sign = size > 0 ? 1 : -1;
    if (size < 0)
      size = -size;
    obj = NewBag(sign == 1 ? T_INTPOS : T_INTNEG, size * sizeof(mp_limb_t));
    memcpy(ADDR_INT(obj), v->_mp_d, size * sizeof(mp_limb_t));

    // FIXME: necessary to normalize and reduce???
    obj = GMP_NORMALIZE( obj );
    obj = GMP_REDUCE( obj );
  }
  return obj;
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
  fake->v->_mp_d = fake->obj ? ADDR_INT(fake->obj) : &fake->tmp;
}

/* some extra debugging tools for FAKMPZ objects */
#if DEBUG_GMP
#define CHECK_FAKEMPZ(fake) \
    assert( ((fake)->v->_mp_d == ((fake)->obj ? ADDR_INT((fake)->obj) : &(fake)->tmp )) \
        &&  (fake->v->_mp_alloc == ((fake)->obj ? SIZE_INT((fake)->obj) : 1 )) )
#else
#define CHECK_FAKEMPZ(fake)  do { } while(0);
#endif


/****************************************************************************
**
*F  GMP_NORMALIZE( <gmp> ) . . . . . . .  remove leading zeros from a GMP bag
**
**  'GMP_NORMALIZE' removes any leading zeros from a <GMP> and returns a
**  small int or resizes the bag if possible.
**  
*/
Obj GMP_NORMALIZE ( Obj gmp )
{
  mp_size_t size;
  if (IS_INTOBJ( gmp )) {
    return gmp;
  }
  for ( size = SIZE_INT(gmp); size != (mp_size_t)1; size-- ) {
    if ( CONST_ADDR_INT(gmp)[(size - 1)] != 0 ) {
      break;
    }
  }
  if ( size < SIZE_INT(gmp) ) {
    ResizeBag( gmp, size*sizeof(mp_limb_t) );
  }
  return gmp;
}

Obj GMP_REDUCE( Obj gmp )
{
  if (IS_INTOBJ( gmp )) {
    return gmp;
  }
  if ( SIZE_INT(gmp) == 1) {
    if ( ( VAL_LIMB0(gmp) < ((1L<<NR_SMALL_INT_BITS)) ) ||
         ( IS_INTNEG(gmp) &&
           ( VAL_LIMB0(gmp) == (1L<<NR_SMALL_INT_BITS) ) ) ) {
      if ( IS_INTNEG(gmp) ) {
        return INTOBJ_INT( -(Int)VAL_LIMB0(gmp) );
      }
      else {
        return INTOBJ_INT(  (Int)VAL_LIMB0(gmp) );
      }
    }
  }
  return gmp;
}

/****************************************************************************
**
**  This is a helper function for the CHECK_INT macro, which checks that
**  the given integer object <op> is normalized and reduced.
**
*/
int IS_NORMALIZED_AND_REDUCED( Obj op, const char *func, int line )
{
  mp_size_t size;
  if ( IS_INTOBJ( op ) ) {
    return 1;
  }
  if ( !IS_LARGEINT( op ) ) {
    /* ignore non-integers */
    return 0;
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
    if ( ( VAL_LIMB0(op) < ((1L<<NR_SMALL_INT_BITS)) ) ||
         ( IS_INTNEG(op) &&
           ( VAL_LIMB0(op) == (1L<<NR_SMALL_INT_BITS) ) ) ) {
      if ( IS_INTNEG(op) ) {
        Pr("WARNING: non-reduced negative gmp value (%s:%d)\n",(Int)func,line);
        return 0;
      }
      else {
        Pr("WARNING: non-reduced positive gmp value (%s:%d)\n",(Int)func,line);
        return 0;
      }
    }
  }
  return 1;
}

  
/****************************************************************************
**
*F  ObjInt_Int( <cint> ) . . . . . . . . . . . convert c int to gmp or intobj
**
**  'ObjInt_Int' takes the C integer <cint> and returns the equivalent
**  GMP obj or int obj, according to the value of <cint>.
**
*/
Obj ObjInt_Int( Int i )
{
  Obj gmp;

  if ( (-(1L<<NR_SMALL_INT_BITS) <= i) && (i < 1L<<NR_SMALL_INT_BITS )) {
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
  UInt bound = 1UL << NR_SMALL_INT_BITS;

  if (i < bound) {
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
  UInt bound = 1UL << NR_SMALL_INT_BITS;

  if (i <= bound) {
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

  mp_limb_t *ptr = ADDR_INT(gmp);
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
  mp_limb_t *ptr = ADDR_INT(gmp);
  ptr[0] = (UInt4)i;
  ptr[1] = ((UInt8)i) >> 32;
  return gmp;
#endif
}

/**************************************************************************
**
** Convert GAP Integers to various C types -- see header file
*/
Int Int_ObjInt(Obj i)
{
    UInt sign = 0;
    if (IS_INTOBJ(i))
        return INT_INTOBJ(i);
    // must be a single limb
    if (TNUM_BAG(i) == T_INTPOS)
        sign = 0;
    else if (TNUM_BAG(i) == T_INTNEG)
        sign = 1;
    else
        ErrorMayQuit("Conversion error, expecting an integer, not a %s",
                     (Int)TNAM_OBJ(i), 0);
    if (SIZE_BAG(i) != sizeof(mp_limb_t))
        ErrorMayQuit("Conversion error, integer too large", 0L, 0L);
    UInt val = ADDR_INT(i)[0];
// now check if val is small enough to fit in the signed Int type
// that has a range from -2^N to 2^N-1 so we need to check both ends
// Since -2^N is the same bit pattern as the UInt 2^N (N is 31 or 63)
// we can do it as below which avoids some compiler warnings
#ifdef SYS_IS_64_BIT
    if ((!sign && (val > INT64_MAX)) || (sign && (val > (UInt)INT64_MIN)))
#else
    if ((!sign && (val > INT32_MAX)) || (sign && (val > (UInt)INT32_MIN)))
#endif
        ErrorMayQuit("Conversion error, integer too large", 0L, 0L);
    return sign ? -(Int)val : (Int)val;
}

UInt UInt_ObjInt(Obj i)
{
    if (IS_NEG_INT(i))
        ErrorMayQuit("Conversion: negative integer into unsigned type", 0, 0);
    if (IS_INTOBJ(i))
        return (UInt)INT_INTOBJ(i);
    if (TNUM_BAG(i) != T_INTPOS)
        ErrorMayQuit("Conversion error, expecting an integer, not a %s",
                     (Int)TNAM_OBJ(i), 0);

    // must be a single limb
    if (SIZE_INT(i) != 1)
        ErrorMayQuit("Conversion error, integer too large", 0L, 0L);
    return ADDR_INT(i)[0];
}

Int8 Int8_ObjInt(Obj i)
{
#ifdef SYS_IS_64_BIT
    // in this case Int8 is Int
    return Int_ObjInt(i);
#else
    UInt sign = 0;
    if (IS_INTOBJ(i))
        return (Int8)INT_INTOBJ(i);
    // must be at most two limbs
    if (TNUM_BAG(i) == T_INTPOS)
        sign = 0;
    else if (TNUM_BAG(i) == T_INTNEG)
        sign = 1;
    else
        ErrorMayQuit("Conversion error, expecting an integer, not a %s",
                     (Int)TNAM_OBJ(i), 0);

    if (SIZE_INT(i) > 2)
        ErrorMayQuit("Conversion error, integer too large", 0L, 0L);
    UInt  vall = ADDR_INT(i)[0];
    UInt  valh = (SIZE_INT(i) == 1) ? 0 : ADDR_INT(i)[1];
    UInt8 val = (UInt8)vall + ((UInt8)valh << 32);
    // now check if val is small enough to fit in the signed Int8 type
    // that has a range from -2^63 to 2^63-1 so we need to check both ends
    // Since -2^63 is the same bit pattern as the UInt8 2^63 we can do it
    // this way which avoids some compiler warnings
    if ((!sign && (val > INT64_MAX)) || (sign && (val > (UInt8)INT64_MIN)))
        ErrorMayQuit("Conversion error, integer too large", 0L, 0L);
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
        ErrorMayQuit("Conversion: negative integer into unsigned type", 0, 0);
    if (IS_INTOBJ(i))
        return (UInt8)INT_INTOBJ(i);
    if (TNUM_BAG(i) != T_INTPOS)
        ErrorMayQuit("Conversion error, expecting an integer, not a %s",
                     (Int)TNAM_OBJ(i), 0);
    if (SIZE_INT(i) > 2)
        ErrorMayQuit("Conversion error, integer too large", 0L, 0L);
    UInt vall = ADDR_INT(i)[0];
    UInt valh = (SIZE_INT(i) == 1) ? 0 : ADDR_INT(i)[1];
    return (UInt8)vall + ((UInt8)valh << 32);
#endif
}

/****************************************************************************
**
*F  PrintInt( <gmp> ) . . . . . . . . . . . . . . . . print a GMP constant
**
**  'PrintInt' prints the GMP integer <gmp> in the usual decimal
**  notation.
**
**  cf PrintInt in integer.c
*/
void PrintInt ( Obj op )
{
  /* print a small integer                                                 */
  if ( IS_INTOBJ(op) ) {
    Pr( "%>%d%<", INT_INTOBJ(op), 0L );
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
    v->_mp_d = ADDR_INT(op);
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
       Pr("<<an integer too large to be printed>>",0L,0L); */
  }
}


/****************************************************************************
**
*F  StringIntBase( <gmp>, <base> )
**
** Convert the integer <gmp> to a string relative to the given base <base>.
** Here, base may range from 2 to 36.
*/
Obj StringIntBase( Obj gmp, int base )
{
  int len;
  Obj res;
  fake_mpz_t v;

  if ( !IS_INT(gmp) ) {
    return Fail;
  }

  CHECK_INT(gmp);

  if ( base < 2 || 36 < base ) {
    return Fail;
  }

  /* 0 is special */
  if ( gmp == INTOBJ_INT(0) ) {
    res = NEW_STRING(1);
    CHARS_STRING(res)[0] = '0';
    return res;
  }

  /* convert integer to fake_mpz_t */
  FAKEMPZ_GMPorINTOBJ( v, gmp );

  /* allocate the result string */
  len = mpz_sizeinbase( MPZ_FAKEMPZ(v), base ) + 2;
  res = NEW_STRING( len );

  /* ask GMP to perform the actual conversion */
  mpz_get_str( CSTR_STRING( res ), -base, MPZ_FAKEMPZ(v) );

  /* we may have to shrink the string */
  int real_len = strlen( CSTR_STRING(res) );
  if ( real_len != GET_LEN_STRING(res) ) {
    SET_LEN_STRING(res, real_len);
  }

  return res;
}

/****************************************************************************
**
*F  FuncHexStringInt( <self>, <gmp> ) . . . . . . . .  hex string for gmp int
*F  FuncIntHexString( <self>, <string> ) . . . . . .  gmp int from hex string
**  
**  The  function  `FuncHexStringInt'  constructs from  a gmp integer  the
**  corresponding string in  hexadecimal notation. It has  a leading '-'
**  for negative numbers and the digits 10..15 are written as A..F.
**  
**  The  function `FuncIntHexString'  does  the converse,  but here  the
**  letters a..f are also allowed in <string> instead of A..F.
**
*/
Obj FuncHexStringInt( Obj self, Obj gmp )
{
  REQUIRE_INT_ARG( "HexStringInt", "op", gmp );
  return StringIntBase( gmp, 16 );
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
      ErrorMayQuit("IntHexString: invalid character in hex-string", 0L, 0L);
    n = (n << 4) + a;
  }
  return n;
}


Obj FuncIntHexString( Obj self,  Obj str )
{
  Obj res;
  Int  i, len, sign, nd;
  mp_limb_t n;
  UInt1 *p;
  mp_limb_t *limbs;

  if (! IsStringConv(str))
    ErrorMayQuit("IntHexString: argument must be string (not a %s)",
                 (Int)TNAM_OBJ(str), 0L);

  len = GET_LEN_STRING(str);
  if (len == 0) {
    res = INTOBJ_INT(0);
    return res;
  }
  p = CHARS_STRING(str);
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
    /* Each hex digit corresponds to to 4 bits, and each GMP limb has INTEGER_UNIT_SIZE
       bytes, thus 2*INTEGER_UNIT_SIZE hex digits fit into one limb. We use this
       to compute the number of limbs minus 1: */
    nd = (len - 1) / (2*INTEGER_UNIT_SIZE);
    res = NewBag( (sign == 1) ? T_INTPOS : T_INTNEG, (nd + 1) * sizeof(mp_limb_t) );

    /* update pointer, in case a garbage collection happened */
    p = CHARS_STRING(str) + i;
    limbs = ADDR_INT(res);

    /* if len is not divisible by 2*INTEGER_UNIT_SIZE, then take care of the extra bytes */
    UInt diff = len - nd * (2*INTEGER_UNIT_SIZE);
    if ( diff ) {
        n = hexstr2int( p, diff );
        p += diff;
        len -= diff;
        limbs[nd--] = n;
    }

    /*  */
    while ( len ) {
        n = hexstr2int( p, 2*INTEGER_UNIT_SIZE );
        p += 2*INTEGER_UNIT_SIZE;
        len -= 2*INTEGER_UNIT_SIZE;
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
**  based on https://graphics.stanford.edu/~seander/bithacks.html#IntegerLogLookup.
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
*F  FuncLog2Int( <self>, <gmp> ) . . . . . . . . . .  nr of bits of a GMP - 1
**  
**  Given to GAP-Level as "Log2Int".
*/
Obj FuncLog2Int( Obj self, Obj integer)
{
  if ( IS_INTOBJ(integer) ) {
    return INTOBJ_INT(CLog2Int(INT_INTOBJ(integer)));
  }

  if ( IS_LARGEINT(integer) ) {
    UInt len = SIZE_INT(integer) - 1;
    UInt a = CLog2UInt( CONST_ADDR_INT(integer)[len] );

    CHECK_INT(integer);

#ifdef SYS_IS_64_BIT
    return INTOBJ_INT(len * GMP_LIMB_BITS + a);
#else
    /* The final result is len * GMP_LIMB_BITS - d, which may not
       fit into an immediate integer (at least on a 32bit system) */
    return SumInt(ProdInt(INTOBJ_INT(len), INTOBJ_INT(GMP_LIMB_BITS)),
                   INTOBJ_INT(a));
#endif
  }
  else {
    ErrorMayQuit("Log2Int: argument must be an integer (not a %s)",
                 (Int)TNAM_OBJ(integer), 0L);
    /* please picky cc                                                     */
    return (Obj) 0L;
  }
}

/****************************************************************************
**
*F  FuncSTRING_INT( <self>, <gmp> ) . . . . . . . . convert a GMP to a string
**
**  `FuncSTRING_INT' returns an immutable string representing the integer
**  <gmp>
**
*/
Obj FuncSTRING_INT( Obj self, Obj integer )
{
  REQUIRE_INT_ARG( "STRING_INT", "op", integer );
  return StringIntBase( integer, 10 );
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
        str = CSTR_STRING(string);

    // get the signs, if any
    sign = 1;
    i = 0;
    while (str[i] == '-') {
        sign = -sign;
        i++;
    }

    // reject empty string (resp. string consisting only of minus signs)
    if (str[i] == '\0')
        return Fail;

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
                str = CSTR_STRING(string);
            pow = 1;
            low = 0;
        }
        i++;
    }

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
Obj FuncINT_STRING ( Obj self, Obj string )
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
*F  EqInt( <gmpL>, <gmpR> ) . . . . . . . . .  test if two integers are equal
**
**  
**  'EqInt' returns 1  if  the two integer   arguments <intL> and  <intR> are
**  equal and 0 otherwise.
*/
Int EqInt ( Obj gmpL, Obj gmpR )
{
  CHECK_INT(gmpL);
  CHECK_INT(gmpR);

  /* compare two small integers */
  if ( ARE_INTOBJS( gmpL, gmpR ) )
    return gmpL == gmpR;

  /* a small int cannot equal a large int */
  if ( IS_INTOBJ(gmpL) != IS_INTOBJ(gmpR) )
    return 0;

  /* compare the sign and size */
  if ( TNUM_OBJ(gmpL) != TNUM_OBJ(gmpR)
       || SIZE_INT(gmpL) != SIZE_INT(gmpR) )
    return 0L;

  if ( mpn_cmp( CONST_ADDR_INT(gmpL), CONST_ADDR_INT(gmpR), SIZE_INT(gmpL) ) == 0 ) 
    return 1L;
  else
    return 0L;
}

/****************************************************************************
**
*F  LtInt( <gmpL>, <gmpR> )  . . . . . . . . . . test whether <gmpL> < <gmpR>
**
*/
Int LtInt ( Obj gmpL, Obj gmpR )
{
  Int res;

  CHECK_INT(gmpL);
  CHECK_INT(gmpR);

  /* compare two small integers */
  if ( ARE_INTOBJS( gmpL, gmpR ) )
    return (Int)gmpL < (Int)gmpR;

  /* a small int is always less than a positive large int */
  if ( IS_INTOBJ(gmpL) != IS_INTOBJ(gmpR) )
    return ( IS_INTOBJ(gmpL) && IS_INTPOS(gmpR) )
        || ( IS_INTNEG(gmpL) && IS_INTOBJ(gmpR) );

  /* compare two large integers */
  if ( TNUM_OBJ(gmpL) != TNUM_OBJ(gmpR) ) /* different signs? */
    return IS_INTNEG(gmpL);

  /* signs are equal; compare sizes and absolute values */
  if ( SIZE_INT(gmpL) < SIZE_INT(gmpR) )
    res = 1;
  else if ( SIZE_INT(gmpL) > SIZE_INT(gmpR) )
    res = 0;
  else
    res = mpn_cmp( CONST_ADDR_INT(gmpL), CONST_ADDR_INT(gmpR), SIZE_INT(gmpL) ) < 0;

  /* if both arguments are negative, flip the result */
  if ( IS_INTNEG(gmpL) )
    res = !res;

  return res;
}


/****************************************************************************
**
*F  SumOrDiffInt( <gmpL>, <gmpR>, <sign> ) . . .  sum or diff of two integers
**
**  'SumOrDiffInt' returns the sum or difference of the two GMP int arguments
**  <gmpL> and <gmpR>, depending on whether sign is +1 or -1. It handles
**  operands of type 'T_INT', 'T_INTPOS' and 'T_INTNEG'.
**
**  'SumOrDiffInt'  is a little  bit  tricky since  there are  many different
**  cases to handle: each operand can be positive or negative, small or large
**  integer.
*/
static Obj SumOrDiffInt ( Obj gmpL, Obj gmpR, Int sign )
{
  UInt sizeL, sizeR;
  fake_mpz_t mpzL, mpzR, mpzResult;
  Obj result;

  CHECK_INT(gmpL);
  CHECK_INT(gmpR);

  /* handle trivial cases first */
  if ( gmpR == INTOBJ_INT(0) )
    return gmpL;
  if ( gmpL == INTOBJ_INT(0) ) {
    if (sign == 1)
      return gmpR;
    else
      return AInvInt(gmpR);
  }

  sizeL = SIZE_INT_OR_INTOBJ(gmpL);
  sizeR = SIZE_INT_OR_INTOBJ(gmpR);

  NEW_FAKEMPZ( mpzResult, sizeL > sizeR ? sizeL+1 : sizeR+1 );
  FAKEMPZ_GMPorINTOBJ( mpzL, gmpL );
  FAKEMPZ_GMPorINTOBJ( mpzR, gmpR );

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
*F  SumInt( <gmpL>, <gmpR> ) . . . . . . . . . . . .  sum of two GMP integers
**
*/
inline Obj SumInt ( Obj gmpL, Obj gmpR )
{
  Obj sum;

  if ( !ARE_INTOBJS(gmpL, gmpR) || !SUM_INTOBJS( sum, gmpL, gmpR) )
    sum = SumOrDiffInt( gmpL, gmpR, +1 );

  CHECK_INT(sum);
  return sum;

}


/****************************************************************************
**
*F  DiffInt( <gmpL>, <gmpR> ) . . . . . . . .  difference of two GMP integers
**
*/
inline Obj DiffInt ( Obj gmpL, Obj gmpR )
{
  Obj dif;
  
  if ( !ARE_INTOBJS(gmpL, gmpR) || !DIFF_INTOBJS( dif, gmpL, gmpR) )
    dif = SumOrDiffInt( gmpL, gmpR, -1 );
  
  CHECK_INT(dif);
  return dif;
}


/****************************************************************************
**
*F  ZeroInt(<gmp>)  . . . . . . . . . . . . . . . . . . . .  zero of integers
*/
Obj ZeroInt ( Obj  op )
{
  return INTOBJ_INT( (Int)0 );
}


/****************************************************************************
**
*F  AInvInt(<gmp>) . . . . . . . . . . . . . . additive inverse of an integer
*/
Obj AInvInt ( Obj gmp )
{
  Obj inv;

  CHECK_INT(gmp);

  /* handle small integer                                                */
  if ( IS_INTOBJ( gmp ) ) {
    
    /* special case (ugh)                                              */
    if ( gmp == INTOBJ_INT( -(1L<<NR_SMALL_INT_BITS) ) ) {
      inv = NewBag( T_INTPOS, sizeof(mp_limb_t) );
      SET_VAL_LIMB0( inv, 1L<<NR_SMALL_INT_BITS );
    }
    
    /* general case                                                    */
    else {
      inv = INTOBJ_INT( - INT_INTOBJ( gmp ) );
    }
    
  }

  else {
    if ( IS_INTPOS(gmp) ) {
      /* special case                                                        */
      if ( ( SIZE_INT(gmp) == 1 ) 
           && ( VAL_LIMB0(gmp) == (1L<<NR_SMALL_INT_BITS) ) ) {
        return INTOBJ_INT( -(Int) (1L<<NR_SMALL_INT_BITS) );
      }
      else {
        inv = NewBag( T_INTNEG, SIZE_OBJ(gmp) );
      }
    }
    
    else {
      inv = NewBag( T_INTPOS, SIZE_OBJ(gmp) );
    }

    memcpy( ADDR_INT(inv), CONST_ADDR_INT(gmp), SIZE_OBJ(gmp) );
  }
  
  /* return the inverse                                                    */
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
    else if ( op == INTOBJ_INT(-(1L << NR_SMALL_INT_BITS)) ) {
      a = NewBag( T_INTPOS, sizeof(mp_limb_t) );
      SET_VAL_LIMB0( a, (1L << NR_SMALL_INT_BITS) );
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

Obj FuncABS_INT(Obj self, Obj op)
{
  Obj res;
  res = AbsInt( op );
  if ( res == Fail ) {
    ErrorMayQuit( "AbsInt: argument must be an integer (not a %s)",
                  (Int)TNAM_OBJ(op), 0L );
  }
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

Obj FuncSIGN_INT(Obj self, Obj op)
{
  Obj res;
  res = SignInt( op );
  if ( res == Fail ) {
    ErrorMayQuit( "SignInt: argument must be an integer (not a %s)",
                  (Int)TNAM_OBJ(op), 0L );
  }
  CHECK_INT(res);
  return res;
}


/****************************************************************************
**
*F  ProdInt( <intL>, <intR> ) . . . . . . . . . . . . product of two integers
**
**  'ProdInt' returns the product of the two  integer  arguments  <intL>  and
**  <intR>.  'ProdInt' handles  operands  of  type  'T_INT',  'T_INTPOS'  and
**  'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**  This case is usually already handled in 'EvalProd' for a better efficiency.
**
**  Is called from the 'EvalProd' binop so both operands are already evaluated.
*/
Obj ProdInt ( Obj gmpL, Obj gmpR )
{
  Obj                 prd;            /* handle of the result bag          */
  UInt sizeL, sizeR;
  fake_mpz_t mpzL, mpzR, mpzResult;

  CHECK_INT(gmpL);
  CHECK_INT(gmpR);

  /* multiplying two small integers                                        */
  if ( ARE_INTOBJS( gmpL, gmpR ) ) {
    
    /* multiply two small integers with a small product                    */
    /* multiply and divide back to check that no overflow occured          */
    if ( PROD_INTOBJS( prd, gmpL, gmpR ) ) {
      CHECK_INT(prd);
      return prd;
    }
  }

  /* handle trivial cases first */
  if ( gmpL == INTOBJ_INT(0) || gmpR == INTOBJ_INT(1) )
    return gmpL;
  if ( gmpR == INTOBJ_INT(0) || gmpL == INTOBJ_INT(1) )
    return gmpR;
  if ( gmpR == INTOBJ_INT(-1) )
    return AInvInt( gmpL );
  if ( gmpL == INTOBJ_INT(-1) )
    return AInvInt( gmpR );

  sizeL = SIZE_INT_OR_INTOBJ(gmpL);
  sizeR = SIZE_INT_OR_INTOBJ(gmpR);
    
  NEW_FAKEMPZ( mpzResult, sizeL + sizeR );
  FAKEMPZ_GMPorINTOBJ( mpzL, gmpL );
  FAKEMPZ_GMPorINTOBJ( mpzR, gmpR );

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
Obj ProdIntObj ( Obj n, Obj op )
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
      return ErrorReturnObj(
                            "Operations: <obj> must have an additive inverse",
                            0L, 0L,
                            "you can supply an inverse <inv> for <obj> via 'return <inv>;'" );
    }
    res = PROD( AINV( n ), res );
  }

  /* if the integer is small, compute the product by repeated doubling     */
  /* the loop invariant is <result> = <k>*<res> + <l>*<op>, <l> < <k>      */
  /* <res> = 0 means that <res> is the neutral element                     */
  else if ( IS_INTOBJ(n) && INT_INTOBJ(n) >   1 ) {
    res = 0;
    k = 1L << (NR_SMALL_INT_BITS+1);
    l = INT_INTOBJ(n);
    while ( 1 < k ) {
      res = (res == 0 ? res : SUM( res, res ));
      k = k / 2;
      if ( k <= l ) {
        res = (res == 0 ? op : SUM( res, op ));
        l = l - k;
      }
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
  
  /* return the result                                                     */
  return res;
}

Obj FuncPROD_INT_OBJ ( Obj self, Obj opL, Obj opR )
{
  return ProdIntObj( opL, opR );
}


/****************************************************************************
**
*F  OneInt(<gmp>) . . . . . . . . . . . . . . . . . . . . . one of an integer
*/
Obj OneInt ( Obj op )
{
  return INTOBJ_INT( 1 );
}


/****************************************************************************
**
*F  PowInt( <intL>, <intR> )  . . . . . . . . . . . . . . power of an integer
**
**  'PowInt' returns the <intR>-th (an integer) power of the integer  <intL>.
**  'PowInt' handles operands of type 'T_INT', 'T_INTPOS' and 'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**  This case is usually already handled in 'EvalPow' for a better  efficiency.
**
**  Is called from the 'EvalPow'  binop so both operands are already evaluated.
*/
Obj PowInt ( Obj gmpL, Obj gmpR )
{
  Int                 i;
  Obj                 pow;

  CHECK_INT(gmpL);
  CHECK_INT(gmpR);

  if ( gmpR == INTOBJ_INT(0) ) {
    pow = INTOBJ_INT(1);
  }
  else if ( gmpL == INTOBJ_INT(0) ) {
    if ( IS_NEG_INT( gmpR ) ) {
      gmpL = ErrorReturnObj(
                            "Integer operands: <base> must not be zero",
                            0L, 0L,
                            "you can replace the integer <base> via 'return <base>;'" );
      return POW( gmpL, gmpR );
    }
    pow = INTOBJ_INT(0);
  }
  else if ( gmpL == INTOBJ_INT(1) ) {
    pow = INTOBJ_INT(1);
  }
  else if ( gmpL == INTOBJ_INT(-1) ) {
    pow = IS_EVEN_INT(gmpR) ? INTOBJ_INT(1) : INTOBJ_INT(-1);
  }

  /* power with a large exponent */
  else if ( ! IS_INTOBJ(gmpR) ) {
    gmpR = ErrorReturnObj(
                          "Integer operands: <exponent> is too large",
                          0L, 0L,
                          "you can replace the integer <exponent> via 'return <exponent>;'" );
    return POW( gmpL, gmpR );
  }
  
  /* power with a negative exponent */
  else if ( INT_INTOBJ(gmpR) < 0 ) {
    pow = QUO( INTOBJ_INT(1),
               PowInt( gmpL, INTOBJ_INT( -INT_INTOBJ(gmpR)) ) );
  }
  
  /* findme - can we use the gmp function mpz_n_pow_ui? */

  /* power with a small positive exponent, do it by a repeated squaring  */
  else {
    pow = INTOBJ_INT(1);
    i = INT_INTOBJ(gmpR);
    while ( i != 0 ) {
      if ( i % 2 == 1 )  pow = ProdInt( pow, gmpL );
      if ( i     >  1 )  gmpL = ProdInt( gmpL, gmpL );
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
Obj             PowObjInt ( Obj op, Obj n )
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
      return ErrorReturnObj(
                            "Operations: <obj> must have an inverse",
                            0L, 0L,
                            "you can supply an inverse <inv> for <obj> via 'return <inv>;'" );
    }
    res = POW( res, AINV( n ) );
  }
  
  /* if the integer is small, compute the power by repeated squaring     */
  /* the loop invariant is <result> = <res>^<k> * <op>^<l>, <l> < <k>    */
  /* <res> = 0 means that <res> is the neutral element                   */
  else if ( IS_INTOBJ(n) && INT_INTOBJ(n) >   0 ) {
    res = 0;
    k = 1L << (NR_SMALL_INT_BITS+1);
    l = INT_INTOBJ(n);
    while ( 1 < k ) {
      res = (res == 0 ? res : PROD( res, res ));
      k = k / 2;
      if ( k <= l ) {
        res = (res == 0 ? op : PROD( res, op ));
        l = l - k;
      }
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

  /* return the result                                                   */
  return res;
}

Obj FuncPOW_OBJ_INT ( Obj self, Obj opL, Obj opR )
{
  return PowObjInt( opL, opR );
}


/****************************************************************************
**
*F  ModInt( <intL>, <intR> )  . representative of residue class of an integer
**
**  'ModInt' returns the smallest positive representant of the residue  class
**  of the  integer  <intL>  modulo  the  integer  <intR>.  'ModInt'  handles
**  operands of type 'T_INT', 'T_INTPOS', 'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**  This case is usually already handled in 'EvalMod' for a better efficiency.
p**
**  Is called from the 'EvalMod'  binop so both operands are already evaluated.
*/
Obj ModInt ( Obj opL, Obj opR )
{
  Int                    i;             /* loop count, value for small int */
  Int                    k;             /* loop count, value for small int */
  UInt                   c;             /* product of two digits           */
  Obj                  mod;             /* handle of the remainder bag     */
  Obj                  quo;             /* handle of the quotient bag      */

  CHECK_INT(opL);
  CHECK_INT(opR);

  /* pathological case first                                             */
  if ( opR == INTOBJ_INT(0) ) {
    opR = ErrorReturnObj(
                         "Integer operations: <divisor> must be nonzero",
                         0L, 0L,
                         "you can replace the integer <divisor> via 'return <divisor>;'" );
    return MOD( opL, opR );
  }

  /* compute the remainder of two small integers                           */
  if ( ARE_INTOBJS( opL, opR ) ) {
    
    /* get the integer values                                              */
    i = INT_INTOBJ(opL);
    k = INT_INTOBJ(opR);
    
    /* compute the remainder, make sure we divide only positive numbers    */
    if (      0 <= i && 0 <= k )  i =       (  i %  k );
    else if ( 0 <= i && k <  0 )  i =       (  i % -k );
    else if ( i < 0  && 0 <= k )  i = ( k - ( -i %  k )) % k;
    else if ( i < 0  && k <  0 )  i = (-k - ( -i % -k )) % -k;
    mod = INTOBJ_INT( i );
    
  }
  
  /* compute the remainder of a small integer by a large integer           */
  else if ( IS_INTOBJ(opL) ) {
    
    /* the small int -(1<<28) mod the large int (1<<28) is 0               */
    if ( opL == INTOBJ_INT(-(Int)(1L<<NR_SMALL_INT_BITS) )
         && ( IS_INTPOS(opR) )
         && ( SIZE_INT(opR) == 1 )
         && ( VAL_LIMB0(opR) == (mp_limb_t)(1L<<NR_SMALL_INT_BITS) ) )
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
    if ( i <= (1L<<NR_SMALL_INT_BITS) && !(i & (i-1)) ) {
      c = VAL_LIMB0(opL) & (i-1);
    }
    
    /* otherwise use the gmp function to divide                            */
    else {
      c = mpn_mod_1( CONST_ADDR_INT(opL), SIZE_INT(opL), (mp_limb_t)i );
    }
    
    /* now c is the result, it has the same sign as the left operand       */
    if ( IS_INTPOS(opL) )
      mod = INTOBJ_INT( c );
    else if ( c == 0 )
      mod = INTOBJ_INT( c );
    else if ( 0 <= INT_INTOBJ(opR) )
      mod = SumOrDiffInt( INTOBJ_INT( -(Int)c ), opR,  1 );
    else
      mod = SumOrDiffInt( INTOBJ_INT( -(Int)c ), opR, -1 );
    
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

    quo = NewBag( T_INTPOS,
                   (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(mp_limb_t) );

    /* and let gmp do the work                                             */
    mpn_tdiv_qr( ADDR_INT(quo), ADDR_INT(mod), 0,
                 CONST_ADDR_INT(opL), SIZE_INT(opL),
                 CONST_ADDR_INT(opR), SIZE_INT(opR)    );
      
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
  
  /* return the result                                                     */
#if DEBUG_GMP
  assert( !IS_NEG_INT(mod) );
#endif
  CHECK_INT(mod);
  return mod;
}


/****************************************************************************
**
*F  QuoInt( <intL>, <intR> )  . . . . . . . . . . . quotient of two integers
**
**  'QuoInt' returns the integer part of the two integers <intL> and  <intR>.
**  'QuoInt' handles operands of type  'T_INT',  'T_INTPOS'  and  'T_INTNEG'.
**
**  It can also be used in the cases that both operands  are  small  integers
**  and the result is a small integer too,  i.e., that  no  overflow  occurs.
**
**  Note that this routine is not called from 'EvalQuo', the  division  of  two
**  integers yields  a  rational  and  is  therefor  performed  in  'QuoRat'.
**  This operation is however available through the internal function 'Quo'.
*/
Obj QuoInt ( Obj opL, Obj opR )
{
  Int                 i;              /* loop count, value for small int   */
  Int                 k;              /* loop count, value for small int   */
  Obj                 quo;            /* handle of the result bag          */
  Obj                 rem;            /* handle of the remainder bag       */

  CHECK_INT(opL);
  CHECK_INT(opR);

  /* pathological case first                                             */
  if ( opR == INTOBJ_INT(0) ) {
    opR = ErrorReturnObj(
                         "Integer operations: <divisor> must be nonzero",
                         0L, 0L,
                         "you can replace the integer <divisor> via 'return <divisor>;'" );
    return QUO( opL, opR );
  }

  /* divide two small integers                                             */
  if ( ARE_INTOBJS( opL, opR ) ) {
    
    /* the small int -(1<<28) divided by -1 is the large int (1<<28)       */
    if ( opL == INTOBJ_INT(-(Int)(1L<<NR_SMALL_INT_BITS)) 
         && opR == INTOBJ_INT(-1) ) {
      quo = NewBag( T_INTPOS, sizeof(mp_limb_t) );
      SET_VAL_LIMB0( quo, 1L<<NR_SMALL_INT_BITS );
      return quo;
    }
    
    /* get the integer values                                              */
    i = INT_INTOBJ(opL);
    k = INT_INTOBJ(opR);
    
    /* divide, make sure we divide only positive numbers                   */
    if (      0 <= i && 0 <= k )  i =    (  i /  k );
    else if ( 0 <= i && k <  0 )  i =  - (  i / -k );
    else if ( i < 0  && 0 <= k )  i =  - ( -i /  k );
    else if ( i < 0  && k <  0 )  i =    ( -i / -k );
    quo = INTOBJ_INT( i );
    
  }
  
  /* divide a small integer by a large one                                 */
  else if ( IS_INTOBJ(opL) ) {
    
    /* the small int -(1<<28) divided by the large int (1<<28) is -1       */
    if ( opL == INTOBJ_INT(-(Int)(1L<<NR_SMALL_INT_BITS))
         && IS_INTPOS(opR) && SIZE_INT(opR) == 1
         && VAL_LIMB0(opR) == 1L<<NR_SMALL_INT_BITS )
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
    
    if ( k < 0 ) k = -k;

    /* use gmp function for dividing by a 1-limb number                    */
    mpn_divrem_1( ADDR_INT(quo), 0,
                  CONST_ADDR_INT(opL), SIZE_INT(opL),
                  k );
  }
  
  /* divide a large integer by a large integer                             */
  else {
    
    /* trivial case first                                                  */
    if ( SIZE_INT(opL) < SIZE_INT(opR) )
      return INTOBJ_INT(0);
    
    /* create a new bag for the remainder                                  */
    rem = NewBag( TNUM_OBJ(opL), (SIZE_INT(opL)+1)*sizeof(mp_limb_t) );

    /* allocate a bag for the quotient                                     */
    if ( TNUM_OBJ(opL) == TNUM_OBJ(opR) )
      quo = NewBag( T_INTPOS, 
                    (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(mp_limb_t) );
    else
      quo = NewBag( T_INTNEG,
                    (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(mp_limb_t) );

    mpn_tdiv_qr( ADDR_INT(quo), ADDR_INT(rem), 0,
                 CONST_ADDR_INT(opL), SIZE_INT(opL),
                 CONST_ADDR_INT(opR), SIZE_INT(opR) );
  }
  
  /* normalize and return the result                                       */
  quo = GMP_NORMALIZE(quo);
  quo = GMP_REDUCE( quo );
  return quo;
}


/****************************************************************************
**
*F  FuncQUO_INT(<self>,<opL>,<opR>) . . . . . . .  internal function 'QuoInt'
**
**  'FuncQUO_INT' implements the internal function 'QuoInt'.
**
**  'QuoInt( <i>, <k> )'
**
**  'Quo' returns the  integer part of the quotient  of its integer operands.
**  If <i>  and <k> are  positive 'Quo( <i>,  <k> )' is  the largest positive
**  integer <q>  such that '<q> * <k>  \<= <i>'.  If  <i> or  <k> or both are
**  negative we define 'Abs( Quo(<i>,<k>) ) = Quo( Abs(<i>), Abs(<k>) )'  and
**  'Sign( Quo(<i>,<k>) ) = Sign(<i>) * Sign(<k>)'.  Dividing by 0  causes an
**  error.  'Rem' (see "Rem") can be used to compute the remainder.
*/
Obj FuncQUO_INT ( Obj self, Obj opL, Obj opR )
{
  REQUIRE_INT_ARG( "QuoInt", "left", opL );
  REQUIRE_INT_ARG( "QuoInt", "right", opR );
  return QuoInt( opL, opR );
}


/****************************************************************************
**
*F  RemInt( <intL>, <intR> )  . . . . . . . . . . . remainder of two integers
**
**  'RemInt' returns the remainder of the quotient  of  the  integers  <intL>
**  and <intR>.  'RemInt' handles operands of type  'T_INT',  'T_INTPOS'  and
**  'T_INTNEG'.
**
**  Note that the remainder is different from the value returned by the 'mod'
**  operator which is always positive.
*/
Obj RemInt ( Obj opL, Obj opR )
{
  Int                 i;              /* loop count, value for small int   */
  Int                 k;              /* loop count, value for small int   */
  UInt                c;              /* product of two digits             */
  Obj                 rem;            /* handle of the remainder bag       */
  Obj                 quo;            /* handle of the quotient bag        */

  CHECK_INT(opL);
  CHECK_INT(opR);

  /* pathological case first                                             */
  if ( opR == INTOBJ_INT(0) ) {
    ErrorMayQuit( "Integer operations: <divisor> must be nonzero", 0L, 0L  );
  }

  /* compute the remainder of two small integers                           */
  if ( ARE_INTOBJS( opL, opR ) ) {
    
    /* get the integer values                                              */
    i = INT_INTOBJ(opL);
    k = INT_INTOBJ(opR);
    
    /* compute the remainder, make sure we divide only positive numbers    */
    if (      0 <= i && 0 <= k )  i =    (  i %  k );
    else if ( 0 <= i && k <  0 )  i =    (  i % -k );
    else if ( i < 0  && 0 <= k )  i =  - ( -i %  k );
    else if ( i < 0  && k <  0 )  i =  - ( -i % -k );
    rem = INTOBJ_INT( i );
    
  }
  
  /* compute the remainder of a small integer by a large integer           */
  else if ( IS_INTOBJ(opL) ) {
    
    /* the small int -(1<<28) rem the large int (1<<28) is 0               */
    if ( opL == INTOBJ_INT(-(Int)(1L<<NR_SMALL_INT_BITS))
         && IS_INTPOS(opR) && SIZE_INT(opR) == 1
         && VAL_LIMB0(opR) == 1L<<NR_SMALL_INT_BITS )
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
    if ( i <= (1L<<NR_SMALL_INT_BITS) && !(i & (i-1)) ) {
      c = VAL_LIMB0(opL) & (i-1);
    }
    
    /* otherwise use the gmp function to divide                            */
    else {
      c = mpn_mod_1( CONST_ADDR_INT(opL), SIZE_INT(opL), i );
    }
    
    /* now c is the result, it has the same sign as the left operand       */
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
    
    quo = NewBag( T_INTPOS,
                  (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(mp_limb_t) );
    
    /* and let gmp do the work                                             */
    mpn_tdiv_qr( ADDR_INT(quo), ADDR_INT(rem), 0,
                 CONST_ADDR_INT(opL), SIZE_INT(opL),
                 CONST_ADDR_INT(opR), SIZE_INT(opR)    );
    
    /* reduce to small integer if possible, otherwise shrink bag           */
    rem = GMP_NORMALIZE( rem );
    rem = GMP_REDUCE( rem );
    
  }
  
  /* return the result                                                     */
  CHECK_INT(rem);
  return rem;
}


/****************************************************************************
**
*F  FuncREM_INT(<self>,<opL>,<opR>)  . . . . . . .  internal function 'RemInt'
**
**  'FuncREM_INT' implements the internal function 'RemInt'.
**
**  'RemInt( <i>, <k> )'
**
**  'Rem' returns the remainder of its two integer operands,  i.e., if <k> is
**  not equal to zero 'Rem( <i>, <k> ) = <i> - <k> *  Quo( <i>, <k> )'.  Note
**  that the rules given  for 'Quo' (see "Quo") imply  that 'Rem( <i>, <k> )'
**  has the same sign as <i> and its absolute value is strictly less than the
**  absolute value of <k>.  Dividing by 0 causes an error.
*/
Obj FuncREM_INT ( Obj self, Obj opL, Obj opR )
{
  REQUIRE_INT_ARG( "RemInt", "left", opL );
  REQUIRE_INT_ARG( "RemInt", "right", opR );
  return RemInt( opL, opR );
}


/****************************************************************************
**
*F  GcdInt( <opL>, <opR> )  . . . . . . . . . . .  gcd of two GMP integers
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
*F  FuncGCD_INT(<self>,<opL>,<opR>)  . . . . . . .  internal function 'GcdInt'
**
**  'FuncGCD_INT' implements the internal function 'GcdInt'.
**
**  'GcdInt( <i>, <k> )'
**
**  'Gcd'  returns the greatest common divisor   of the two  integers <m> and
**  <n>, i.e.,  the  greatest integer that  divides  both <m>  and  <n>.  The
**  greatest common divisor is never negative, even if the arguments are.  We
**  define $gcd( m, 0 ) = gcd( 0, m ) = abs( m )$ and $gcd( 0, 0 ) = 0$.
*/
Obj FuncGCD_INT ( Obj self, Obj opL, Obj opR )
{
  REQUIRE_INT_ARG( "GcdInt", "left", opL );
  REQUIRE_INT_ARG( "GcdInt", "right", opR );
  return GcdInt( opL, opR );
}


/****************************************************************************
**
*/
Obj BinomialInt ( Obj n, Obj k )
{
    Int negate_result = 0;

    if (!IS_INT(n) || !IS_INT(k))
        return Fail;

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


/****************************************************************************
**
*/
Obj FuncBINOMIAL_INT ( Obj self, Obj opN, Obj opK )
{
  REQUIRE_INT_ARG( "BinomialInt", "n", opN );
  REQUIRE_INT_ARG( "BinomialInt", "k", opK );
  return BinomialInt( opN, opK );
}


/****************************************************************************
**
*/
Obj JacobiInt ( Obj opL, Obj opR )
{
  fake_mpz_t mpzL, mpzR;
  int result;

  CHECK_INT(opL);
  CHECK_INT(opR);

  FAKEMPZ_GMPorINTOBJ( mpzL, opL );
  FAKEMPZ_GMPorINTOBJ( mpzR, opR );

  result = mpz_kronecker( MPZ_FAKEMPZ(mpzL), MPZ_FAKEMPZ(mpzR) );
  CHECK_FAKEMPZ(mpzL);
  CHECK_FAKEMPZ(mpzR);

  return INTOBJ_INT( result );
}


/****************************************************************************
**
*/
Obj FuncJACOBI_INT ( Obj self, Obj opL, Obj opR )
{
  REQUIRE_INT_ARG( "JacobiInt", "left", opL );
  REQUIRE_INT_ARG( "JacobiInt", "right", opR );
  return JacobiInt( opL, opR );
}


/****************************************************************************
**
*/
Obj PValuationInt ( Obj n, Obj p )
{
  fake_mpz_t mpzN, mpzP;
  mpz_t mpzResult;
  int k;

  CHECK_INT(n);
  CHECK_INT(p);

  if ( p == INTOBJ_INT(0) )
    ErrorMayQuit( "PValuationInt: <p> must be nonzero", 0L, 0L  );

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
Obj FuncPVALUATION_INT ( Obj self, Obj opL, Obj opR )
{
  REQUIRE_INT_ARG( "PValuationInt", "left", opL );
  REQUIRE_INT_ARG( "PValuationInt", "right", opR );
  return PValuationInt( opL, opR );
}


/****************************************************************************
**
*/
Obj InverseModInt ( Obj base, Obj mod )
{
  fake_mpz_t base_mpz, mod_mpz, result_mpz;
  int success;

  CHECK_INT(base);
  CHECK_INT(mod);

  if ( mod == INTOBJ_INT(0) )
    ErrorMayQuit( "InverseModInt: <mod> must be nonzero", 0L, 0L  );
  if ( mod == INTOBJ_INT(1) || mod == INTOBJ_INT(-1) )
    return INTOBJ_INT(0);
  if ( base == INTOBJ_INT(0) )
    return Fail;

  NEW_FAKEMPZ( result_mpz, SIZE_INT_OR_INTOBJ(mod) + 1 );
  FAKEMPZ_GMPorINTOBJ( base_mpz, base );
  FAKEMPZ_GMPorINTOBJ( mod_mpz, mod );

  success = mpz_invert( MPZ_FAKEMPZ(result_mpz),
                        MPZ_FAKEMPZ(base_mpz),
                        MPZ_FAKEMPZ(mod_mpz) );

  if (!success)
    return Fail;

  CHECK_FAKEMPZ(result_mpz);
  CHECK_FAKEMPZ(base_mpz);
  CHECK_FAKEMPZ(mod_mpz);

  return GMPorINTOBJ_FAKEMPZ( result_mpz );
}

/****************************************************************************
**
*/
Obj FuncINVMODINT ( Obj self, Obj base, Obj mod )
{
  REQUIRE_INT_ARG( "InverseModInt", "base", base );
  REQUIRE_INT_ARG( "InverseModInt", "mod", mod );
  return InverseModInt( base, mod );
}


/****************************************************************************
**
*/
Obj PowerModInt ( Obj base, Obj exp, Obj mod )
{
  fake_mpz_t base_mpz, exp_mpz, mod_mpz, result_mpz;

  CHECK_INT(base);
  CHECK_INT(exp);
  CHECK_INT(mod);

  if ( mod == INTOBJ_INT(0) )
    ErrorMayQuit( "PowerModInt: <mod> must be nonzero", 0L, 0L  );
  if ( mod == INTOBJ_INT(1) || mod == INTOBJ_INT(-1) )
    return INTOBJ_INT(0);

  if ( IS_NEG_INT(exp) ) {
    base = InverseModInt( base, mod );
    if (base == Fail)
      ErrorMayQuit( "PowerModInt: negative <exp> but <base> is not invertible modulo <mod>", 0L, 0L  );
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
Obj FuncPOWERMODINT ( Obj self, Obj base, Obj exp, Obj mod )
{
  REQUIRE_INT_ARG( "PowerModInt", "base", base );
  REQUIRE_INT_ARG( "PowerModInt", "exp", exp );
  REQUIRE_INT_ARG( "PowerModInt", "mod", mod );
  return PowerModInt( base, exp, mod );
}


/****************************************************************************
**
*/
Obj IsProbablyPrimeInt ( Obj n, Int reps )
{
  fake_mpz_t n_mpz;
  Int res;

  if ( reps < 1 )
    ErrorMayQuit( "IsProbablyPrimeInt: <reps> must be positive", 0L, 0L );

  CHECK_INT(n);

  FAKEMPZ_GMPorINTOBJ( n_mpz, n );

  res = mpz_probab_prime_p( MPZ_FAKEMPZ(n_mpz), reps );

  if (res == 2) return True; /* definitely prime */
  if (res == 0) return False; /* definitely not prime */
  return Fail; /* probably prime */
}

/****************************************************************************
**
*/
Obj FuncIS_PROBAB_PRIME_INT ( Obj self, Obj n, Obj reps )
{
  REQUIRE_INT_ARG( "IsProbablyPrimeInt", "n", n );
  REQUIRE_INT_ARG( "IsProbablyPrimeInt", "reps", reps );
  if ( ! IS_INTOBJ(reps) )
    ErrorMayQuit( "IsProbablyPrimeInt: <reps> is too large", 0L, 0L );

  return IsProbablyPrimeInt( n, INT_INTOBJ(reps) );
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
Obj FuncRandomIntegerMT(Obj self, Obj mtstr, Obj nrbits)
{
  Obj res;
  Int i, n, q, r, qoff, len;
  UInt4 *mt, rand;
  UInt4 *pt;
  while (! IsStringConv(mtstr)) {
     mtstr = ErrorReturnObj(
         "<mtstr> must be a string (not a %s)",
         (Int)TNAM_OBJ(mtstr), 0L,
         "you can replace <mtstr> via 'return <mtstr>;'" );
  }
  while ((! IsStringConv(mtstr)) || GET_LEN_STRING(mtstr) < 2500) {
     mtstr = ErrorReturnObj(
         "<mtstr> must be a string with at least 2500 characters",
         0L, 0L,
         "you can replace <mtstr> via 'return <mtstr>;'" );
  }
  while ((! IS_INTOBJ(nrbits)) || INT_INTOBJ(nrbits) < 0) {
     nrbits = ErrorReturnObj(
         "<nrbits> must be a small non-negative integer (not a %s)",
         (Int)TNAM_OBJ(nrbits), 0L,
         "you can replace <mtstr> via 'return <mtstr>;'" );
  }
  n = INT_INTOBJ(nrbits);

  /* small int case */
  if (n <= NR_SMALL_INT_BITS) {
     mt = (UInt4*) CHARS_STRING(mtstr);
#ifdef SYS_IS_64_BIT
     if (n <= 32) {
       res = INTOBJ_INT((Int)(nextrandMT_int32(mt) & ((UInt4) -1L >> (32-n))));
     }
     else {
       unsigned long  rd;
       rd = nextrandMT_int32(mt);
       rd += (unsigned long) ((UInt4) nextrandMT_int32(mt) & 
                              ((UInt4) -1L >> (64-n))) << 32;
       res = INTOBJ_INT((Int)rd);
     }  
#else
     res = INTOBJ_INT((Int)(nextrandMT_int32(mt) & ((UInt4) -1L >> (32-n))));
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
     mt = (UInt4*) CHARS_STRING(mtstr);
     for (i = 0; i < qoff; i++, pt++) {
       rand = (UInt4) nextrandMT_int32(mt);
       *pt = rand;
     }
     if (r != 0) {
       /* we generated too many random bits -- chop of the extra bits */
       pt = (UInt4*) ADDR_INT(res);
       pt[qoff-1] = pt[qoff-1] & ((UInt4)(-1) >> (32-r));
     }
     /* shrink bag if necessary */
     res = GMP_NORMALIZE(res);
     /* convert result if small int */
     res = GMP_REDUCE(res);
  }

  return res;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

  GVAR_FILTER(IS_INT, "obj", &IsIntFilt),
  { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

  GVAR_FUNC(QUO_INT, 2, "gmp1, gmp2"),
  GVAR_FUNC(ABS_INT, 1, "x"),
  GVAR_FUNC(SIGN_INT, 1, "x"),
  GVAR_FUNC(REM_INT, 2, "gmp1, gmp2"),
  GVAR_FUNC(GCD_INT, 2, "gmp1, gmp2"),
  GVAR_FUNC(PROD_INT_OBJ, 2, "gmp, obj"),
  GVAR_FUNC(POW_OBJ_INT, 2, "obj, gmp"),
  GVAR_FUNC(JACOBI_INT, 2, "gmp1, gmp2"),
  GVAR_FUNC(BINOMIAL_INT, 2, "n, k"),
  GVAR_FUNC(PVALUATION_INT, 2, "n, p"),
  GVAR_FUNC(POWERMODINT, 3, "base, exp, mod"),
  GVAR_FUNC(IS_PROBAB_PRIME_INT, 2, "n, reps"),
  GVAR_FUNC(INVMODINT, 2, "base, mod"),
  GVAR_FUNC(HexStringInt, 1, "gmp"),
  GVAR_FUNC(IntHexString, 1, "string"),
  GVAR_FUNC(Log2Int, 1, "gmp"),
  GVAR_FUNC(STRING_INT, 1, "gmp"),
  GVAR_FUNC(INT_STRING, 1, "string"),
  GVAR_FUNC(RandomIntegerMT, 2, "mtstr, nrbits"),
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
    FPUTS_TO_STDERR("Panic, GMP limb size mismatch\n");
    SyExit( 1 ); 
  }

  /* init filters and functions                                            */
  InitHdlrFiltsFromTable( GVarFilts );
  InitHdlrFuncsFromTable( GVarFuncs );
  
  /* install the marking functions                                         */
  InfoBags[         T_INT    ].name = "integer";
#ifdef SYS_IS_64_BIT
  InfoBags[         T_INTPOS ].name = "integer (>= 2^60)";
  InfoBags[         T_INTNEG ].name = "integer (< -2^60)";
#else
  InfoBags[         T_INTPOS ].name = "integer (>= 2^28)";
  InfoBags[         T_INTNEG ].name = "integer (< -2^28)";
#endif
  InitMarkFuncBags( T_INTPOS, MarkNoSubBags );
  InitMarkFuncBags( T_INTNEG, MarkNoSubBags );
  
  /* Install the saving methods */
  SaveObjFuncs [ T_INTPOS ] = SaveInt;
  SaveObjFuncs [ T_INTNEG ] = SaveInt;
  LoadObjFuncs [ T_INTPOS ] = LoadInt;
  LoadObjFuncs [ T_INTNEG ] = LoadInt;
  
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

    /* install the default product and power methods                       */
  for ( t1 = T_INT; t1 <= T_INTNEG; t1++ ) {
    for ( t2 = FIRST_CONSTANT_TNUM;  t2 <= LAST_CONSTANT_TNUM;  t2++ ) {
      ProdFuncs[ t1 ][ t2 ] = ProdIntObj;
      PowFuncs [ t2 ][ t1 ] = PowObjInt;
    }
    for ( t2 = FIRST_RECORD_TNUM;  t2 <= LAST_RECORD_TNUM;  t2++ ) {
      ProdFuncs[ t1 ][ t2 ] = ProdIntObj;
      PowFuncs [ t2 ][ t1 ] = PowObjInt;
    }
    for ( t2 = FIRST_LIST_TNUM;    t2 <= LAST_LIST_TNUM;    t2++ ) {
      ProdFuncs[ t1 ][ t2 ] = ProdIntObj;
      PowFuncs [ t2 ][ t1 ] = PowObjInt;
    }
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

  MakeBagTypePublic( T_INTPOS );
  MakeBagTypePublic( T_INTNEG );
  
  /* return success                                                        */
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
  
  /* return success                                                        */
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
