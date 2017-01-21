/****************************************************************************
**
*W  gmpints.c                   GAP source                     John McDermott
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
**  GAP stores integers in three formats:
**  1. Integers between -2^NR_SMALL_INT_BITS and 2^NR_SMALL_INT_BITS-1
**     are stored as As "immediate" or "small" integers, aka as "INTOBJ"
**     objects. These have the pseudo-tnum T_INT.
**     TODO: document details, or point to a place where these are documented.
**  2. Integers n >= 2^NR_SMALL_INT_BITS are stored as T_INTPOS objects.
**     The content of such an object corresponds to a GMP sequence of "limbs"
**     corresponding to n.
**  3. Integers n < 2^NR_SMALL_INT_BITS are stored as T_INTNEG objects.
**     The content of such an object corresponds to a GMP sequence of "limbs"
**     corresponding to -n.
**
**  Note that we require that all "large" integers are normalized (that is,
**  they contain no redundant leading zero limbs) and reduced (that is,
**  they do not fit into a small integer). Internally, it is possible that
**  temporarily a large integers is not normalized or not reduced, but all
**  functions below must make sure that they eventually return normalized
**  and reduced values. The function GMP_NORMALIZE and GMP_REDUCE can be
**  used to ensure this.
*/
#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */

#include        "ariths.h"              /* basic arithmetic                */

#include        "bool.h"                /* booleans                        */

#include        "gap.h"                 /* error handling, initialisation  */
#include        "code.h"                /* needed by stats.h */
#include        "stats.h"               /* for TakeInterrupt               */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "stringobj.h"              /* strings                         */

#include        "saveload.h"            /* saving and loading              */

#include        "intfuncs.h"

#include <stdio.h>

#ifdef HAVE_MATH_H
#include <math.h>
#endif

#include <stdlib.h>

#include <assert.h>
#include <string.h>
#include <ctype.h>


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

#include        "gmpints.h"             /* GMP integers                    */

#ifdef SYS_IS_64_BIT
#define SaveLimb SaveUInt8
#define LoadLimb LoadUInt8
#else
#define SaveLimb SaveUInt4
#define LoadLimb LoadUInt4
#endif


static Obj ObjInt_UIntInv( UInt i );


/* macro for swapping two variables of a given type. Poor man's C++ macro. */
#define SWAP(T, a, b)          do { T SWAP_TMP = a; a = b; b = SWAP_TMP; } while (0)

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
#define VAL_LIMB0(obj)          (*ADDR_INT(obj))
#define SET_VAL_LIMB0(obj,val)  do { *ADDR_INT(obj) = val; } while(0)
#define IS_INTPOS(obj)          (TNUM_OBJ(obj) == T_INTPOS)
#define IS_INTNEG(obj)          (TNUM_OBJ(obj) == T_INTNEG)
#define IS_LARGEINT(obj)        (IS_INTPOS(obj) || IS_INTNEG(obj))

#define IS_NEGATIVE(obj)        (IS_INTOBJ(obj) ? ((Int)obj < 0) : IS_INTNEG(obj))
#define IS_ODD(obj)             (IS_INTOBJ(obj) ? ((Int)obj & 4) : (VAL_LIMB0(obj) & 1))
#define IS_EVEN(obj)            (!IS_ODD(obj))

#define SIZE_INT_OR_INTOBJ(obj) (IS_INTOBJ(obj) ? 1 : SIZE_INT(obj))


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
**  'IsInt'  returns 'true'  if the  value  <val>  is an small integer or a
**  large int, and 'false' otherwise.
*/
Obj FuncIS_INT ( Obj self, Obj val )
{
  if (    TNUM_OBJ(val) == T_INT 
       || TNUM_OBJ(val) == T_INTPOS
       || TNUM_OBJ(val) == T_INTNEG ) {
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
  TypLimb *ptr;
  UInt i;
  ptr = ADDR_INT(gmp);
  for (i = 0; i < SIZE_INT(gmp); i++)
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
  TypLimb *ptr;
  UInt i;
  ptr = ADDR_INT(gmp);
  for (i = 0; i < SIZE_INT(gmp); i++)
    *ptr++ = LoadLimb();
  return;
}


/****************************************************************************
**
*F  NEW_INTPOS( <gmp> )
**
**  Take an T_INTPOS or T_INTNEG and create a new T_INTPOS with identical
**  content. Useful to duplicate integers, or take the absolute value.
*/
static inline Obj NEW_INTPOS( Obj gmp )
{
  Obj new;

  new = NewBag( T_INTPOS, SIZE_OBJ(gmp) );
  memcpy( ADDR_INT(new), ADDR_INT(gmp), SIZE_OBJ(gmp) );

  return new;
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
    fake->obj = NewBag( T_INTPOS, size * sizeof(TypLimb) );
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
    return INTOBJ_INT(0);
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
  TypGMPSize size;
  if (IS_INTOBJ( gmp )) {
    return gmp;
  }
  for ( size = SIZE_INT(gmp); size != (TypGMPSize)1; size-- ) {
    if ( ADDR_INT(gmp)[(size - 1)] != 0 ) {
      break;
    }
  }
  if ( size < SIZE_INT(gmp) ) {
    ResizeBag( gmp, size*sizeof(TypLimb) );
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
  TypGMPSize size;
  if ( IS_INTOBJ( op ) ) {
    return 1;
  }
  if ( !IS_LARGEINT( op ) ) {
    /* ignore non-integers */
    return 0;
  }
  for ( size = SIZE_INT(op); size != (TypGMPSize)1; size-- ) {
    if ( ADDR_INT(op)[(size - 1)] != 0 ) {
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
*F  GMP_INTOBJ(<gmp>) . . . . . . . . . . . . . . . . . . . .  convert intobj to gmp
**
*/
Obj GMP_INTOBJ( Obj i )
{
  Obj gmp;
  Int   j;

  if ( !IS_INTOBJ(i) ) {
    return Fail;
  }
  else {
    j = INT_INTOBJ( i );
    if ( j < 0 ) {
      gmp = NewBag( T_INTNEG, sizeof(TypLimb) );
      j = -j;
    }
    else {
      gmp = NewBag( T_INTPOS, sizeof(TypLimb) );
    }
  }
  memcpy( ADDR_INT(gmp), &j, sizeof(Int) );
  return gmp;
}

  
/****************************************************************************
**
*F  GMPorINTOBJ_INT( <cint> ) . . . . . . . .  convert c int to gmp or intobj
**
**  'GMPorINTOBJ_INT' takes the C integer <cint> and returns the equivalent
**  GMP obj or int obj, according to the value of <cint>.
**
*/
Obj GMPorINTOBJ_INT( Int i )
{
  Obj gmp;

  if ( (-(1L<<NR_SMALL_INT_BITS) <= i) && (i < 1L<<NR_SMALL_INT_BITS )) {
    return INTOBJ_INT(i);
  }
  else if (i < 0 ) {
    gmp = NewBag( T_INTNEG, sizeof(TypLimb) );
    i = -i;
  }
  else {
    gmp = NewBag( T_INTPOS, sizeof(TypLimb) );
  }
  SET_VAL_LIMB0( gmp, i );
  return gmp;
}

Obj ObjInt_Int( Int i )
{
  return GMPorINTOBJ_INT( i );
}

Obj ObjInt_UInt( UInt i )
{
  Obj gmp;
  UInt bound = 1UL << NR_SMALL_INT_BITS;

  if (i < bound) {
    return INTOBJ_INT(i);
  }
  else {
    gmp = NewBag( T_INTPOS, sizeof(TypLimb) );
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
    gmp = NewBag( T_INTNEG, sizeof(TypLimb) );
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
  assert( sizeof(TypLimb) == 4 );
  Obj gmp;
  if (i >= 0) {
     gmp = NewBag( T_INTPOS, 2 * sizeof(TypLimb) );
  } else {
     gmp = NewBag( T_INTNEG, 2 * sizeof(TypLimb) );
     i = -i;
  }

  TypLimb *ptr = ADDR_INT(gmp);
  ptr[0] = (UInt4)i;
  ptr[1] = ((UInt8)i) >> 32;
  return gmp;
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
  Char buf[20000];
  UInt signlength;
  Obj str;
  /* print a small integer                                                 */
  if ( IS_INTOBJ(op) ) {
    Pr( "%>%d%<", INT_INTOBJ(op), 0L );
  }
  
  /* print a large integer                                                 */
  else if ( SIZE_INT(op) < 1000 ) {
    CHECK_INT(op);

    /* use gmp func to print int to buffer                                 */
    if (!IS_INTPOS(op)) {
      buf[0] ='-';
      signlength = 1;
    } else {
      signlength = 0;
    }
    gmp_snprintf((char *)(buf+signlength),20000-signlength,
                 "%Nd", ADDR_INT(op),
                 (TypGMPSize)SIZE_INT(op));

    /* print the buffer, %> means insert '\' before a linebreak            */
    Pr("%>%s%<",(Int)buf, 0);
  }
  else {
    str = CALL_1ARGS( String, op );
    Pr("%>%s%<",(Int)(CHARS_STRING(str)), 0);
    /* for a long time Print of large ints did not follow the general idea
     * that Print should produce something that can be read back into GAP:
       Pr("<<an integer too large to be printed>>",0L,0L); */
  }
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
Obj FuncHexStringInt( Obj self, Obj integer )
{
  size_t alloc_size, str_size;
  Int i, j, n; /* len */
  UInt nf;
  /* TypLimb d, f; */
  UInt1 *p, a, *s;
  Obj res = 0;
  
  CHECK_INT(integer);

  /* immediate integers */
  if (IS_INTOBJ(integer)) {
    n = INT_INTOBJ(integer);
    /* 0 is special */
    if (n == 0) {
      res = NEW_STRING(1);
      CHARS_STRING(res)[0] = '0';
      return res;
    }
    
    /* else we create a string big enough for any immediate integer        */
    res = NEW_STRING(2 * INTEGER_UNIT_SIZE + 1);
    p = CHARS_STRING(res);
    /* handle sign */
    if (n<0) {
      p[0] = '-';
      n = -n;
      p++;
    }
    else 
      SET_LEN_STRING(res, GET_LEN_STRING(res)-1);
    /* collect digits, skipping leading zeros                              */
    j = 0;
    nf = ((UInt)15) << (4*(2*INTEGER_UNIT_SIZE-1));
    for (i = 2*INTEGER_UNIT_SIZE; i; i-- ) {
      a = ((UInt)n & nf) >> (4*(i-1));
      if (j==0 && a==0) SET_LEN_STRING(res, GET_LEN_STRING(res)-1);
      else if (a<10) p[j++] = a + '0';
      else p[j++] = a - 10 + 'A';
      nf = nf >> 4;
    }
    /* final null character                                                */
    p[j] = 0;
  }

  else if ( IS_LARGEINT(integer) ) {
    alloc_size = SIZE_INT(integer)*sizeof(TypLimb)*2+1;
    alloc_size += IS_INTNEG(integer);

    res = NEW_STRING( alloc_size );
    s = CHARS_STRING( res );

    if ( IS_INTNEG(integer) )
      *s++ = '-';

    str_size = mpn_get_str( s, 16, ADDR_INT(integer), SIZE_INT(integer) );
    assert ( str_size <= alloc_size - ( IS_INTNEG(integer) ) );

    for (j = 0; j < str_size-1; j++)
      if (s[j] != 0)
        break;
    

    for ( i = 0; i < str_size-j; i++ )
      s[i] = "0123456789ABCDEF"[s[i+j]];

    assert ( str_size - j == 1 || *s != '0' );

    /* findme  - this fails: */
    /*    assert ( strlen( CSTR_STRING(res) ) == alloc_size ); */
    /* adjust length in case of trailing \0 characters */
    /* [Is there a way to get it right from the beginning? FL] */
    /*     while (s[alloc_size-1] == '\0') 
           alloc_size--; */
    SET_LEN_STRING(res, str_size-j + (IS_INTNEG(integer)));
    /*  assert ( strlen( CSTR_STRING(res) ) == GET_LEN_STRING(res) ); */
  }
  else {
    ErrorMayQuit("HexStringInt: argument must be an integer (not a %s)",
                 (Int)TNAM_OBJ(integer), 0L);
  }

  return res;
}


Obj FuncIntHexString( Obj self,  Obj str )
{
  Obj res;
  Int  i, j, len, sign, nd;
  UInt n;
  UInt1 *p, a;
  UChar c;
  
  if (! IsStringConv(str))
    ErrorMayQuit("IntHexString: argument must be string (not a %s)",
                 (Int)TNAM_OBJ(str), 0L);

  len = GET_LEN_STRING(str);
  if (len == 0) {
    res = INTOBJ_INT(0);
    return res;
  }
  if (*(CHARS_STRING(str)) == '-') {
    sign = -1;
    i = 1;
  }
  else {
    sign = 1;
    i = 0;
  }

  while ((CHARS_STRING(str))[i] == '0' && i < len)
    i++;
    

  if ((len-i)*4 <= NR_SMALL_INT_BITS) {
    n = 0;
    p = CHARS_STRING(str);
    for (; i<len; i++) {
      a = p[i];
      if (a>='a') 
        a -= 'a' - 10;
      else if (a>='A') 
        a -= 'A' - 10;
      else 
        a -= '0';
      if (a > 15)
        ErrorMayQuit("IntHexString: non-valid character in hex-string",
                     0L, 0L);
      n = (n << 4) + a;
    }
    res = INTOBJ_INT(sign * n);
    return res;
  }

  else {
    nd = (len-i)/INTEGER_UNIT_SIZE;
    if (nd * INTEGER_UNIT_SIZE < (len-i)) nd++;
    /*   nd += ((3*nd) % 4); */
    if (sign == 1)
      res = NewBag( T_INTPOS, nd*sizeof(TypLimb) );
    else
      res = NewBag( T_INTNEG, nd*sizeof(TypLimb) );

    p = CHARS_STRING(str)+i;

    /* findme */
    /* the following destroys the supplied string - document this          */
    for (j=0;j<len-i;j++){
      c=p[j];
      if (IsDigit(c))
        p[j] = c - '0';
      else if (islower((unsigned int)c))
        p[j] = c - 'a' + 10;
      else if (isupper((unsigned int)c))
        p[j] = c - 'A' + 10;
      else
        ErrorMayQuit("IntHexString: non-valid character in hex-string",
                       0L, 0L);
      if (p[j] >= 16)
        ErrorMayQuit("IntHexString: non-valid character in hex-string",
                     0L, 0L);
    }

    mpn_set_str(ADDR_INT(res),p,len-i,16);
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
#if SIZEOF_VOID_P == SIZEOF_INT && HAVE___BUILTIN_CLZ
  return GMP_LIMB_BITS - 1 - __builtin_clz(a);
#elif SIZEOF_VOID_P == SIZEOF_LONG && HAVE___BUILTIN_CLZL
  return GMP_LIMB_BITS - 1 - __builtin_clzl(a);
#elif SIZEOF_VOID_P == SIZEOF_LONG_LONG && HAVE___BUILTIN_CLZLL
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
    UInt a = CLog2UInt( ADDR_INT(integer)[len] );

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
  Int   x;
  Obj str;
  Int len;
  Int   i;
  Char  c;
  Int neg;

  CHECK_INT(integer);

  /* handle a small integer                                                */
  if ( IS_INTOBJ(integer) ) {
    x = INT_INTOBJ(integer);
    str = NEW_STRING( (NR_SMALL_INT_BITS+5)/3 );
    RetypeBag(str, T_STRING+IMMUTABLE);
    len = 0;
    /* Case of zero                                                        */
    if (x == 0)
      {
        CHARS_STRING(str)[0] = '0';
        CHARS_STRING(str)[1] = '\0';
        ResizeBag(str, SIZEBAG_STRINGLEN(1));
        SET_LEN_STRING(str, 1);
        
        return str;
      }
    /* Negative numbers                                                    */
    if (x < 0)
      {
        CHARS_STRING(str)[len++] = '-';
        x = -x;
        neg = 1;
      }
    else
      neg = 0;

    /* Now the main case                                                   */
    while (x != 0)
      {
        CHARS_STRING(str)[len++] = '0'+ x % 10;
        x /= 10;
      }
    CHARS_STRING(str)[len] = '\0';
    
    /* finally, reverse the digits in place                                */
    for (i = neg; i < (neg+len)/2; i++)
      {
        c = CHARS_STRING(str)[neg+len-1-i];
        CHARS_STRING(str)[neg+len-1-i] = CHARS_STRING(str)[i];
        CHARS_STRING(str)[i] = c;
      }
    
    ResizeBag(str, SIZEBAG_STRINGLEN(len));
    SET_LEN_STRING(str, len);
    return str;
  }

  /* handle a large integer                                                */
  else if ( SIZE_INT(integer) < 1000 ) {

    /* findme - enough space for a 1000 limb gmp int on a 64 bit machine     */
    /* change when 128 bit comes along!                                      */
    Char buf[20000];

    if ( IS_INTNEG(integer) ) {
    len = gmp_snprintf( buf, sizeof(buf)-1, "-%Ni", ADDR_INT(integer),
          (TypGMPSize)SIZE_INT(integer) );
    }
    else {
    len = gmp_snprintf( buf, sizeof(buf)-1,  "%Ni", ADDR_INT(integer),
          (TypGMPSize)SIZE_INT(integer) );
    }

    assert(len < sizeof(buf));
    C_NEW_STRING( str, (TypGMPSize)len, buf );

    return str;

  }

  else {

      /* Very large integer, fall back on the GAP function                 */
      return CALL_1ARGS( String, integer);
  }
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

  if ( mpn_cmp( ADDR_INT(gmpL), ADDR_INT(gmpR), SIZE_INT(gmpL) ) == 0 ) 
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
    res = mpn_cmp( ADDR_INT(gmpL), ADDR_INT(gmpR), SIZE_INT(gmpL) ) < 0;

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
Obj SumInt ( Obj gmpL, Obj gmpR )
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
Obj DiffInt ( Obj gmpL, Obj gmpR )
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
      inv = NewBag( T_INTPOS, sizeof(TypLimb) );
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

    memcpy( ADDR_INT(inv), ADDR_INT(gmp), SIZE_OBJ(gmp) );
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
      a = NewBag( T_INTPOS, sizeof(TypLimb) );
      SET_VAL_LIMB0( a, (1L << NR_SMALL_INT_BITS) );
      return a;
    } else
      return (Obj)( 2 - (Int)op );
  }
  CHECK_INT(op);
  if ( IS_INTPOS(op) ) {
    return op;
  } else if ( IS_INTNEG(op) ) {
    return NEW_INTPOS(op);
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
  TypLimb             l;              /* loop variable                     */

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
  else if ( IS_NEGATIVE(n) ) {
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
  else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) >   1 ) {
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
  else if ( TNUM_OBJ(n) == T_INTPOS ) {
    res = 0;
    for ( i = SIZE_INT(n); 0 < i; i-- ) {
      k = 8*sizeof(TypLimb);
      l = ADDR_INT(n)[i-1];
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
    if ( IS_NEGATIVE( gmpR ) ) {
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
    pow = IS_EVEN(gmpR) ? INTOBJ_INT(1) : INTOBJ_INT(-1);
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
  TypLimb             l;              /* loop variable                   */
  
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
  else if ( IS_NEGATIVE(n) ) {
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
  else if ( TNUM_OBJ(n) == T_INT && INT_INTOBJ(n) >   0 ) {
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
  else if ( TNUM_OBJ(n) == T_INTPOS ) {
    res = 0;
    for ( i = SIZE_INT(n); 0 < i; i-- ) {
      k = 8*sizeof(TypLimb);
      l = ADDR_INT(n)[i-1];
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
         && ( TNUM_OBJ(opR) == T_INTPOS )
         && ( SIZE_INT(opR) == 1 )
         && ( VAL_LIMB0(opR) == (TypLimb)(1L<<NR_SMALL_INT_BITS) ) )
      mod = INTOBJ_INT(0);
    
    /* in all other cases the remainder is equal the left operand          */
    else if ( 0 <= INT_INTOBJ(opL) )
      mod = opL;
    else if ( TNUM_OBJ(opR) == T_INTPOS )
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
      c = mpn_mod_1( ADDR_INT(opL), SIZE_INT(opL), (TypLimb)i );
    }
    
    /* now c is the result, it has the same sign as the left operand       */
    if ( TNUM_OBJ(opL) == T_INTPOS )
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
      if ( TNUM_OBJ(opL) == T_INTPOS )
        return opL;
      else if ( TNUM_OBJ(opR) == T_INTPOS )
        mod = SumOrDiffInt( opL, opR,  1 );
      else
        mod = SumOrDiffInt( opL, opR, -1 );
      if ( IS_INTNEG(mod) ) mod = NEW_INTPOS(mod);
      CHECK_INT(mod);
      return mod;
    }
    
    mod = NewBag( TNUM_OBJ(opL), (SIZE_INT(opL)+1)*sizeof(TypLimb) );

    quo = NewBag( T_INTPOS,
                   (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(TypLimb) );

    /* and let gmp do the work                                             */
    mpn_tdiv_qr( ADDR_INT(quo), ADDR_INT(mod), 0,
                 ADDR_INT(opL), SIZE_INT(opL),
                 ADDR_INT(opR), SIZE_INT(opR)    );
      
    /* reduce to small integer if possible, otherwise shrink bag           */
    mod = GMP_NORMALIZE( mod );
    mod = GMP_REDUCE( mod );
    
    /* make the representative positive                                    */
    if ( (TNUM_OBJ(mod) == T_INT && INT_INTOBJ(mod) < 0)
         || TNUM_OBJ(mod) == T_INTNEG ) {
      if ( TNUM_OBJ(opR) == T_INTPOS )
        mod = SumOrDiffInt( mod, opR,  1 );
      else
        mod = SumOrDiffInt( mod, opR, -1 );
    }
    
  }
  
  /* return the result                                                     */
#if DEBUG_GMP
  assert( !IS_NEGATIVE(mod) );
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
      quo = NewBag( T_INTPOS, sizeof(TypLimb) );
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
         && TNUM_OBJ(opR) == T_INTPOS && SIZE_INT(opR) == 1
         && VAL_LIMB0(opR) == 1L<<NR_SMALL_INT_BITS )
      quo = INTOBJ_INT(-1);
    
    /* in all other cases the quotient is of course zero                   */
    else
      quo = INTOBJ_INT(0);
    
  }
  
  /* divide a large integer by a small integer                             */
  else if ( IS_INTOBJ(opR) ) {
    
    /* allocate a bag for the result and set up the pointers               */
    if ( (TNUM_OBJ(opL)==T_INTPOS && 0 < INT_INTOBJ(opR))
         || (TNUM_OBJ(opL)==T_INTNEG && INT_INTOBJ(opR) < 0) )
      quo = NewBag( T_INTPOS, SIZE_OBJ(opL) );
    else
      quo = NewBag( T_INTNEG, SIZE_OBJ(opL) );
    
    opR = GMP_INTOBJ( opR );

    /* use gmp function for dividing by a 1-limb number                    */
    mpn_divrem_1( ADDR_INT(quo), 0,
                  ADDR_INT(opL), SIZE_INT(opL),
                  VAL_LIMB0(opR) );
  }
  
  /* divide a large integer by a large integer                             */
  else {
    
    /* trivial case first                                                  */
    if ( SIZE_INT(opL) < SIZE_INT(opR) )
      return INTOBJ_INT(0);
    
    /* create a new bag for the remainder                                  */
    rem = NewBag( TNUM_OBJ(opL), (SIZE_INT(opL)+1)*sizeof(TypLimb) );

    /* allocate a bag for the quotient                                     */
    if ( TNUM_OBJ(opL) == TNUM_OBJ(opR) )
      quo = NewBag( T_INTPOS, 
                    (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(TypLimb) );
    else
      quo = NewBag( T_INTNEG,
                    (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(TypLimb) );

    mpn_tdiv_qr( ADDR_INT(quo), ADDR_INT(rem), 0,
                 ADDR_INT(opL), SIZE_INT(opL),
                 ADDR_INT(opR), SIZE_INT(opR) );
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
  /* check the arguments                                                   */
  while ( TNUM_OBJ(opL) != T_INT
          && TNUM_OBJ(opL) != T_INTPOS
          && TNUM_OBJ(opL) != T_INTNEG ) {
    opL = ErrorReturnObj(
                         "QuoInt: <left> must be an integer (not a %s)",
                         (Int)TNAM_OBJ(opL), 0L,
                         "you can replace <left> via 'return <left>;'" );
  }
  while ( TNUM_OBJ(opR) != T_INT
          && TNUM_OBJ(opR) != T_INTPOS
          && TNUM_OBJ(opR) != T_INTNEG ) {
    opR = ErrorReturnObj(
                         "QuoInt: <right> must be an integer (not a %s)",
                         (Int)TNAM_OBJ(opR), 0L,
                         "you can replace <right> via 'return <right>;'" );
  }
  
  /* return the quotient                                                   */
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
    opR = ErrorReturnObj(
                         "Integer operations: <divisor> must be nonzero",
                         0L, 0L,
                         "you can replace the integer <divisor> via 'return <divisor>;'" );
    return QUO( opL, opR );
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
         && TNUM_OBJ(opR) == T_INTPOS && SIZE_INT(opR) == 1
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
      c = mpn_mod_1( ADDR_INT(opL), SIZE_INT(opL), i );
    }
    
    /* now c is the result, it has the same sign as the left operand       */
    if ( TNUM_OBJ(opL) == T_INTPOS )
      rem = INTOBJ_INT( c );
    else
      rem = INTOBJ_INT( -(Int)c );
    
  }
  
  /* compute the remainder of a large integer modulo a large integer       */
  else {
    
    /* trivial case first                                                  */
    if ( SIZE_INT(opL) < SIZE_INT(opR) )
      return opL;
    
    rem = NewBag( TNUM_OBJ(opL), (SIZE_INT(opL)+1)*sizeof(TypLimb) );
    
    quo = NewBag( T_INTPOS,
                  (SIZE_INT(opL)-SIZE_INT(opR)+1)*sizeof(TypLimb) );
    
    /* and let gmp do the work                                             */
    mpn_tdiv_qr( ADDR_INT(quo), ADDR_INT(rem), 0,
                 ADDR_INT(opL), SIZE_INT(opL),
                 ADDR_INT(opR), SIZE_INT(opR)    );
    
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
  /* check the arguments                                                   */
  while ( TNUM_OBJ(opL) != T_INT
          && TNUM_OBJ(opL) != T_INTPOS
          && TNUM_OBJ(opL) != T_INTNEG ) {
    opL = ErrorReturnObj(
                         "RemInt: <left> must be an integer (not a %s)",
                         (Int)TNAM_OBJ(opL), 0L,
                         "you can replace <left> via 'return <left>;'" );
  }
  while ( TNUM_OBJ(opR) != T_INT
          && TNUM_OBJ(opR) != T_INTPOS
          && TNUM_OBJ(opR) != T_INTNEG ) {
    opR = ErrorReturnObj(
                         "RemInt: <right> must be an integer (not a %s)",
                         (Int)TNAM_OBJ(opR), 0L,
                         "you can replace <right> via 'return <right>;'" );
  }

  /* return the remainder                                                  */
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
  /* check the arguments                                                   */
  while ( TNUM_OBJ(opL) != T_INT
          && TNUM_OBJ(opL) != T_INTPOS
          && TNUM_OBJ(opL) != T_INTNEG ) {
    opL = ErrorReturnObj(
                         "GcdInt: <left> must be an integer (not a %s)",
                         (Int)TNAM_OBJ(opL), 0L,
                         "you can replace <left> via 'return <left>;'" );
  }
  while ( TNUM_OBJ(opR) != T_INT
          && TNUM_OBJ(opR) != T_INTPOS
          && TNUM_OBJ(opR) != T_INTNEG ) {
    opR = ErrorReturnObj(
                         "GcdInt: <right> must be an integer (not a %s)",
                         (Int)TNAM_OBJ(opR), 0L,
                         "you can replace <right> via 'return <right>;'" );
  }
  
  /* return the gcd                                                        */
  return GcdInt( opL, opR );
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
     len = (qoff*4 +  sizeof(TypLimb) - 1) / sizeof(TypLimb);
     res = NewBag( T_INTPOS, len*sizeof(TypLimb) );
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

  { "IS_INT", "obj", &IsIntFilt,
    FuncIS_INT, "src/gmpints.c:IS_INT" },

  { 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

  { "QUO_INT", 2, "gmp1, gmp2",
    FuncQUO_INT, "src/gmpints.c:QUO_INT" },

  { "ABS_INT", 1, "x",
    FuncABS_INT, "src/gmpints.c:ABS_INT" },

  { "SIGN_INT", 1, "x",
    FuncSIGN_INT, "src/gmpints.c:SIGN_INT" },

  { "REM_INT", 2, "gmp1, gmp2",
    FuncREM_INT, "src/gmpints.c:REM_INT" },

  { "GCD_INT", 2, "gmp1, gmp2",
    FuncGCD_INT, "src/gmpints.c:GCD_INT" },
  
  { "PROD_INT_OBJ", 2, "gmp, obj",
    FuncPROD_INT_OBJ, "src/gmpints.c:PROD_INT_OBJ" },
  
  { "POW_OBJ_INT", 2, "obj, gmp",
    FuncPOW_OBJ_INT, "src/gmpints.c:POW_OBJ_INT" },
  
  { "HexStringInt", 1, "gmp",
    FuncHexStringInt, "src/gmpints.c:HexStringInt" },
  
  { "IntHexString", 1, "string",
    FuncIntHexString, "src/gmpints.c:IntHexString" },
  
  { "Log2Int", 1, "gmp",
    FuncLog2Int, "src/gmpints.c:Log2Int" },

  { "STRING_INT", 1, "gmp",
    FuncSTRING_INT, "src/gmpints.c:STRING_INT" },
  
  { "RandomIntegerMT", 2, "mtstr, nrbits",
    FuncRandomIntegerMT, "src/gmpints.c:RandomIntegerMT" },
  
  
  { 0 }

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
  MODULE_BUILTIN,                        /* type                           */
  "gmpints",                             /* name                           */
  0,                                     /* revision entry of c file       */
  0,                                     /* revision entry of h file       */
  0,                                     /* version                        */
  0,                                     /* crc                            */
  InitKernel,                            /* initKernel                     */
  InitLibrary,                           /* initLibrary                    */
  0,                                     /* checkInit                      */
  0,                                     /* preSave                        */
  0,                                     /* postSave                       */
  0                                      /* postRestore                    */
};

StructInitInfo * InitInfoInt ( void )
{
  return &module;
}

#endif /* ! WARD_ENABLED */

/****************************************************************************
**
*E  gmpints.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
