#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */
#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */

#include <src/ariths.h>                 /* basic arithmetic */
#include <src/finfield.h>               /* finite fields and ff elements */

#include <src/bool.h>                   /* booleans */
#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/listoper.h>               /* lists operations */
#include <src/plist.h>                  /* plain lists */
#include <src/range.h>                  /* ranges */
#include <src/blister.h>                /* boolean lists */
#include <src/stringobj.h>              /* strings */

#include <src/vector.h>                 /* vectors */
#include <src/listoper.h>               /* default list ops */

#include <src/vec8bit.h>                /* GFQ vectors */

#include <src/saveload.h>               /* saving and loading */
#include <src/opers.h>
#include <src/gmpints.h>                /* integer functions needed for NUMBER_ */

#include <src/vecgf2.h>              /* needed for the conversion to
             GF(2^n) n>1) */

#include <src/code.h>                   /* for TakeInterrupt */
#include <src/stats.h> 

#include <src/hpc/aobjects.h>           /* atomic objects */
#include <src/hpc/thread.h>
#include <src/hpc/tls.h>

#ifndef DEBUG
#ifndef NDEBUG
#define NDEBUG 1
#endif
#endif

#include <assert.h>
#include <stdio.h>

/****************************************************************************
**
**
*H  There is a representations of GFQ vectors with entries packed into
**  bytes, called IsVec8BitRep, which inherits from IsDataObjectRep
**  The 1st 4 bytes  stores the actual vector length (in field elements)
**  as a C integer. The 2nd component stores the field size as a C integer
**  The data bytes begin at the 3rd component.
**  
**  In addition, this file defines format and access for the fieldinfo
**  objects which contain the meat-axe tables for the arithmetics.
**
**  There is a special representation for matrices, all of whose rows
**  are immutable packed GFQ vectors over the same q, which is a positional
**  representation Is8BitMatrixRep. Some special methods for such matrices 
**  are included here.
** 
*/



/****************************************************************************
**
*F  IS_VEC8BIT_REP( <obj> )  . . . . . . check that <obj> is in 8bit GFQ vector rep
**
** #define IS_VEC8BIT_REP(obj) \
**  (TNUM_OBJ(obj)==T_DATOBJ && True == DoFilter(IsVec8bitRep,obj))
*/
Obj IsVec8bitRep;




/****************************************************************************
**
*F  LEN_VEC8BIT( <vec> ) . . . . .. . . . . . . .length of an 8 bit GF vector
**
**  'LEN_VEC8BIT' returns the logical length of the 8bit GFQ vector <list>,
**  as a C integer.
**
**  Note that 'LEN_VEC8BIT' is a macro, so do not call it with  arguments that
**  have side effects.
*/
#define LEN_VEC8BIT(list)         ((Int)(ADDR_OBJ(list)[1]))

/****************************************************************************
**
*F  SET_LEN_VEC8BIT( <vec>, <len> )  . . . . set length of an 8 bit GF vector
**
**  'SET_LEN_VEC8BIT' sets the logical length of the 8bit GFQ vector <vec>,
**  to the C integer <len>.
**
*/
#define SET_LEN_VEC8BIT(list,len)         ((ADDR_OBJ(list)[1] = (Obj)(len)))

/****************************************************************************
**
*F  FIELD_VEC8BIT( <vec> ) . . . .. . . . . .field size of an 8 bit GF vector
**
**  'FIELD_VEC8BIT' returns the field size Q of the 8bit GFQ vector <list>,
**  as a C integer.
**
**  Note that 'FIELD_VEC8BIT' is a macro, so do not call it with  arguments
**  that have side effects.
*/

#define FIELD_VEC8BIT(list)         ((Int)(ADDR_OBJ(list)[2]))

/****************************************************************************
**
*F  SET_FIELD_VEC8BIT( <vec>, <q> )  . . set field size of an 8 bit GF vector
**
**  'SET_FIELD_VEC8BIT' sets the field size of the 8bit GFQ vector <vec>,
**  to the C integer <q>.
**
*/
#define SET_FIELD_VEC8BIT(list,q)         ((ADDR_OBJ(list)[2] = (Obj)(q)))


/****************************************************************************
**
*F  BYTES_VEC8BIT( <list> ) . . . . . . . . . first byte of a 8bit GFQ vector
**
**  returns a pointer to the start of the data of the 8bit GFQ vector
*/
#define BYTES_VEC8BIT(list)             ((UInt1*)(ADDR_OBJ(list)+3))


/****************************************************************************
**
*V  FieldInfo8Bit . .  . . . . . . . . .plain list (length 256) of field info
**
**  This list caches the field info used for the fast arithmetic
*/

static Obj FieldInfo8Bit;


/****************************************************************************
**
*F  Q_FIELDINFO_8BIT( <obj> )       . . . access to fields in structure
*F  P_FIELDINFO_8BIT( <obj> )
*F  ELS_BYTE_FIELDINFO_8BIT( <obj> )
*F  SETELT_FIELDINFO_8BIT( <obj> )
*F  GETELT_FIELDINFO_8BIT( <obj> )
*F  SCALMUL_FIELDINFO_8BIT( <obj> )
*F  ADD_FIELDINFO_8BIT( <obj> )
*F  SET_XXX_FIELDINFO_8BIOT( <obj>, <xxx> ) . . .setters needed by ANSI
**                                         needed for scalar but not pointers
**
**  For machines with alignment restrictions. it's important to put all
**  the word-sized data BEFORE all the byte-sized data (especially FFE_FELT...
**  which may have odd length
**
**  Note ADD has to be last, because it is not there in characteristic 2
*/

#define Q_FIELDINFO_8BIT( info ) ((UInt)(ADDR_OBJ(info)[1]))
#define SET_Q_FIELDINFO_8BIT( info, q ) (ADDR_OBJ(info)[1] = (Obj)(q))
#define P_FIELDINFO_8BIT( info ) ((UInt)(ADDR_OBJ(info)[2]))
#define SET_P_FIELDINFO_8BIT( info, p ) (ADDR_OBJ(info)[2] = (Obj)(p))
#define D_FIELDINFO_8BIT( info ) ((UInt)(ADDR_OBJ(info)[3]))
#define SET_D_FIELDINFO_8BIT( info, d ) (ADDR_OBJ(info)[3] = (Obj)(d))
#define ELS_BYTE_FIELDINFO_8BIT( info ) ((UInt)(ADDR_OBJ(info)[4]))
#define SET_ELS_BYTE_FIELDINFO_8BIT( info, e ) (ADDR_OBJ(info)[4] = (Obj)(e))
#define FFE_FELT_FIELDINFO_8BIT( info ) (ADDR_OBJ(info)+5)
#define GAPSEQ_FELT_FIELDINFO_8BIT( info ) (ADDR_OBJ(info)+5+Q_FIELDINFO_8BIT(info))
#define FELT_FFE_FIELDINFO_8BIT( info ) ((UInt1*)(GAPSEQ_FELT_FIELDINFO_8BIT(info)+Q_FIELDINFO_8BIT(info)))
#define SETELT_FIELDINFO_8BIT( info ) (FELT_FFE_FIELDINFO_8BIT( info ) + Q_FIELDINFO_8BIT(info))
#define GETELT_FIELDINFO_8BIT( info ) \
     (SETELT_FIELDINFO_8BIT(info) + \
      256*Q_FIELDINFO_8BIT(info)*ELS_BYTE_FIELDINFO_8BIT(info))
#define SCALAR_FIELDINFO_8BIT( info ) \
     (GETELT_FIELDINFO_8BIT(info)+256*ELS_BYTE_FIELDINFO_8BIT(info))
#define INNER_FIELDINFO_8BIT( info ) \
     (SCALAR_FIELDINFO_8BIT( info ) + 256*Q_FIELDINFO_8BIT(info))
#define PMULL_FIELDINFO_8BIT( info ) \
     (INNER_FIELDINFO_8BIT( info ) + 256*256)
#define PMULU_FIELDINFO_8BIT( info ) \
     (PMULL_FIELDINFO_8BIT( info ) + 256*256)
#define ADD_FIELDINFO_8BIT( info ) \
     (PMULU_FIELDINFO_8BIT( info ) + ((ELS_BYTE_FIELDINFO_8BIT(info) == 1) ? 0 : 256*256))





/****************************************************************************
**

*F * * * * * * * * * * * imported library variables * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  TypeVec8Bit( <q>, <mut> ) . . .  . . .type of a  vector object
**
*/
Obj TYPES_VEC8BIT;
Obj TYPE_VEC8BIT;
Obj TYPE_VEC8BIT_LOCKED;

Obj TypeVec8Bit( UInt q, UInt mut)
{
  UInt col = mut ? 1 : 2;
  Obj type;
#ifdef HPCGAP
  type = ELM0_LIST(ELM_PLIST(TYPES_VEC8BIT, col),q);
#else
  type = ELM_PLIST(ELM_PLIST(TYPES_VEC8BIT, col),q);
#endif
  if (type == 0)
    return CALL_2ARGS(TYPE_VEC8BIT, INTOBJ_INT(q), mut ? True: False);
  else
    return type;
}

Obj TypeVec8BitLocked( UInt q, UInt mut)
{
  UInt col = mut ? 3 : 4;
  Obj type;
#ifdef HPCGAP
  type = ELM0_LIST(ELM_PLIST(TYPES_VEC8BIT, col),q);
#else
  type = ELM_PLIST(ELM_PLIST(TYPES_VEC8BIT, col),q);
#endif
  if (type == 0)
    return CALL_2ARGS(TYPE_VEC8BIT_LOCKED, INTOBJ_INT(q), mut ? True : False);
  else
    return type;
}

/****************************************************************************
**
*F  TypeMat8Bit( <q>, <mut> ) . . .  . . .type of a  matrix object
**
*/
Obj TYPES_MAT8BIT;
Obj TYPE_MAT8BIT;

Obj TypeMat8Bit( UInt q, UInt mut)
{
  UInt col = mut ? 1 : 2;
  Obj type;
#ifdef HPCGAP
  type = ELM0_LIST(ELM0_LIST(TYPES_MAT8BIT, col),q);
#else
  type = ELM_PLIST(ELM_PLIST(TYPES_MAT8BIT, col),q);
#endif
  if (type == 0)
    return CALL_2ARGS(TYPE_MAT8BIT, INTOBJ_INT(q), mut ? True: False);
  else
    return type;
}


/****************************************************************************
**
*V  TYPE_FIELDINFO_8BIT
**
**  A type of data object with essentially no GAP visible semantics at all
**  
*/

Obj TYPE_FIELDINFO_8BIT;


#define SIZE_VEC8BIT(len,elts) (3*sizeof(UInt)+((len)+(elts)-1)/(elts))

/****************************************************************************
**                    
*V  GetFieldInfo( <q> ) . .make or recover the meataxe table for a field
**                         always call this, as the tables are lost by
**                         save/restore. It's very cheap if the table already
**                         exists
**
*/


static const UInt1 GF4Lookup[] =  {0,2,1,3};
static const UInt1 GF8Lookup[] =  {0, 4, 2, 1, 6, 3, 7, 5};

static const UInt1 GF16Lookup[] = {0, 8, 4, 2, 1, 12, 6, 3, 13, 10, 5,
14, 7, 15, 11, 9};

static const UInt1 GF32Lookup[] = {0, 16, 8, 4, 2, 1, 20, 10, 5, 22,
11, 17, 28, 14, 7, 23, 31, 27, 25, 24, 12, 6, 3, 21, 30, 15, 19, 29,
26, 13, 18, 9};

static const UInt1 GF64Lookup[] = { 0, 32, 16, 8, 4, 2, 1, 54, 27, 59,
43, 35, 39, 37, 36, 18, 9, 50, 25, 58, 29, 56, 28, 14, 7, 53, 44, 22,
11, 51, 47, 33, 38, 19, 63, 41, 34, 17, 62, 31, 57, 42, 21, 60, 30,
15, 49, 46, 23, 61, 40, 20, 10, 5, 52, 26, 13, 48, 24, 12, 6, 3, 55,
45 };

static const UInt1 GF128Lookup[] = { 0, 64, 32, 16, 8, 4, 2, 1, 96,
48, 24, 12, 6, 3, 97, 80, 40, 20, 10, 5, 98, 49, 120, 60, 30, 15, 103,
83, 73, 68, 34, 17, 104, 52, 26, 13, 102, 51, 121, 92, 46, 23, 107,
85, 74, 37, 114, 57, 124, 62, 31, 111, 87, 75, 69, 66, 33, 112, 56,
28, 14, 7, 99, 81, 72, 36, 18, 9, 100, 50, 25, 108, 54, 27, 109, 86,
43, 117, 90, 45, 118, 59, 125, 94, 47, 119, 91, 77, 70, 35, 113, 88,
44, 22, 11, 101, 82, 41, 116, 58, 29, 110, 55, 123, 93, 78, 39, 115,
89, 76, 38, 19, 105, 84, 42, 21, 106, 53, 122, 61, 126, 63, 127, 95,
79, 71, 67, 65 };

static const UInt1 GF256Lookup[] = { 0, 128, 64, 32, 16, 8, 4, 2, 1,
184, 92, 46, 23, 179, 225, 200, 100, 50, 25, 180, 90, 45, 174, 87,
147, 241, 192, 96, 48, 24, 12, 6, 3, 185, 228, 114, 57, 164, 82, 41,
172, 86, 43, 173, 238, 119, 131, 249, 196, 98, 49, 160, 80, 40, 20,
10, 5, 186, 93, 150, 75, 157, 246, 123, 133, 250, 125, 134, 67, 153,
244, 122, 61, 166, 83, 145, 240, 120, 60, 30, 15, 191, 231, 203, 221,
214, 107, 141, 254, 127, 135, 251, 197, 218, 109, 142, 71, 155, 245,
194, 97, 136, 68, 34, 17, 176, 88, 44, 22, 11, 189, 230, 115, 129,
248, 124, 62, 31, 183, 227, 201, 220, 110, 55, 163, 233, 204, 102, 51,
161, 232, 116, 58, 29, 182, 91, 149, 242, 121, 132, 66, 33, 168, 84,
42, 21, 178, 89, 148, 74, 37, 170, 85, 146, 73, 156, 78, 39, 171, 237,
206, 103, 139, 253, 198, 99, 137, 252, 126, 63, 167, 235, 205, 222,
111, 143, 255, 199, 219, 213, 210, 105, 140, 70, 35, 169, 236, 118,
59, 165, 234, 117, 130, 65, 152, 76, 38, 19, 177, 224, 112, 56, 28,
14, 7, 187, 229, 202, 101, 138, 69, 154, 77, 158, 79, 159, 247, 195,
217, 212, 106, 53, 162, 81, 144, 72, 36, 18, 9, 188, 94, 47, 175, 239,
207, 223, 215, 211, 209, 208, 104, 52, 26, 13, 190, 95, 151, 243, 193,
216, 108, 54, 27, 181, 226, 113};

static const UInt1 PbyQ[] = { 0, 1, 2, 3, 2, 5, 0, 7, 2, 3, 0, 11, 0,
13, 0, 0, 2, 17, 0, 19, 0, 0, 0, 23, 0, 5, 0, 3, 0, 29, 0, 31, 2, 0,
0, 0, 0, 37, 0, 0, 0, 41, 0, 43, 0, 0, 0, 47, 0, 7, 0, 0, 0, 53, 0, 0,
0, 0, 0, 59, 0, 61, 0, 0, 2, 0, 0, 67, 0, 0, 0, 71, 0, 73, 0, 0, 0, 0,
0, 79, 0, 3, 0, 83, 0, 0, 0, 0, 0, 89, 0, 0, 0, 0, 0, 0, 0, 97, 0, 0,
0, 101, 0, 103, 0, 0, 0, 107, 0, 109, 0, 0, 0, 113, 0, 0, 0, 0, 0, 0,
0, 11, 0, 0, 0, 5, 0, 127, 2, 0, 0, 131, 0, 0, 0, 0, 0, 137, 0, 139,
0, 0, 0, 0, 0, 0, 0, 0, 0, 149, 0, 151, 0, 0, 0, 0, 0, 157, 0, 0, 0,
0, 0, 163, 0, 0, 0, 167, 0, 13, 0, 0, 0, 173, 0, 0, 0, 0, 0, 179, 0,
181, 0, 0, 0, 0, 0, 0, 0, 0, 0, 191, 0, 193, 0, 0, 0, 197, 0, 199, 0,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 211, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
223, 0, 0, 0, 227, 0, 229, 0, 0, 0, 233, 0, 0, 0, 0, 0, 239, 0, 241,
0, 3, 0, 0, 0, 0, 0, 0, 0, 251, 0, 0, 0, 0, 2 };

static const UInt1 DbyQ[] = { 0, 1, 1, 1, 2, 1, 0, 1, 3, 2, 0, 1, 0,
1, 0, 0, 4, 1, 0, 1, 0, 0, 0, 1, 0, 2, 0, 3, 0, 1, 0, 1, 5, 0, 0, 0,
0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0,
1, 0, 1, 0, 0, 6, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 4,
0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0,
0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 3, 0, 1,
7, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0,
1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 2, 0, 0, 0, 1,
0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0,
1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0,
0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0,
5, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 8};



static const UInt1 * Char2Lookup[9] = {
  0L, 0L,
  GF4Lookup,
  GF8Lookup,
  GF16Lookup,
  GF32Lookup,
  GF64Lookup,
  GF128Lookup,
  GF256Lookup};


void MakeFieldInfo8Bit( UInt q)
{
    FF   gfq;     /* the field */
    UInt p;     /* characteristic */
    UInt d;     /* degree */
    UInt i, j, k, l;  /* loop variables */
    UInt e;     /* number of elements per byte */
    UInt size;      /* data structure size */
    UInt pows[7];     /* table of powers of q for packing
           and unpacking bytes */
    Obj info;     /* The table being constructed */
    FFV mult;     /* multiplier for scalar product */
    FFV prod;     /* used in scalar product */
    UInt val;                     /* used to build up some answers */
    UInt val0;
    UInt elt, el1, el2;           /* used to build up some answers */
    FFV *succ;
    UInt1* setelt_info; /* Cache a value, mainly to get around a bug in xcode 5.0 */
    UInt1* getelt_info; /* ditto */
    Int iej_cache;      /* ditto */


    p = (UInt)PbyQ[q];
    d = (UInt)DbyQ[q];
    gfq = FiniteField(p, d);
    e = 0;
    for (i = 1; i <= 256; i *= q)
        pows[e++] = i;
    pows[e] = i;    /* simplifies things to have one more */
    e--;

    size = sizeof(Obj) +   /* type */
          sizeof(Obj) +   /* q */
          sizeof(Obj) +   /* p */
          sizeof(Obj) +   /* d */
          sizeof(Obj) +   /* els per byte */
          q * sizeof(Obj) +           /* position in GAP < order  by number */
          q * sizeof(Obj) +           /* numbering from FFV */
          q * sizeof(Obj) + /* immediate FFE by number */
          256 * q * e + /* set element lookup */
          256 * e +   /* get element lookup */
          256 * q +   /* scalar multiply */
          2 * 256 * 256 + /* inner product, 1 lot of polynomial multiply data */
          ((e == 1) ? 0 : (256 * 256)) + /* the other lot of polynomial data */
          ((p == 2) ? 0 : (256 * 256)); /* add byte */

    info = NewBag(T_DATOBJ, size);
    SetTypeDatObj(info, TYPE_FIELDINFO_8BIT);

    succ = SUCC_FF(gfq);

    /* from here to the end, no garbage collections should happen */
    SET_Q_FIELDINFO_8BIT(info, q);
    SET_P_FIELDINFO_8BIT(info, p);
    SET_D_FIELDINFO_8BIT(info, d);
    SET_ELS_BYTE_FIELDINFO_8BIT(info, e);

    /* conversion tables FFV to/from our numbering
       we assume that 0 and 1 are always the zero and one
       of the field. In char 2, we assume that xor corresponds
       to addition, otherwise, the order doesn't matter */

    if (p != 2)
        for (i = 0; i < q; i++)
            FELT_FFE_FIELDINFO_8BIT(info)[i] = (UInt1)i;
    else
        for (i = 0; i < q; i++)
            FELT_FFE_FIELDINFO_8BIT(info)[i] = Char2Lookup[d][i];

    /* simply invert the permutation to get the other one */
    for (i = 0; i < q; i++) {
        j = FELT_FFE_FIELDINFO_8BIT(info)[i];
        FFE_FELT_FIELDINFO_8BIT(info)[j] = NEW_FFE(gfq, i);
    }

    /* Now we need to store the position in Elements(GF(q)) of each field element
       for the sake of NumberFFVector

       The rules for < between finite field elements make this a bit
       complex for non-prime fields */

    /* deal with zero and one */
    GAPSEQ_FELT_FIELDINFO_8BIT(info)[0] = INTOBJ_INT(0);
    GAPSEQ_FELT_FIELDINFO_8BIT(info)[FELT_FFE_FIELDINFO_8BIT(info)[1]] = INTOBJ_INT(1);

    if (q != 2) {
        if (d == 1)
            for (i = 2; i < q; i++)
                GAPSEQ_FELT_FIELDINFO_8BIT(info)[i] = INTOBJ_INT(i);
        else {
            /* run through subfields, filling in entry for all the new elements
               of each field in turn */
            UInt q1 = 1;
            UInt pos = 2;
            for (i = 1; i <= d; i++) {
                q1 *= p;
                if (d % i == 0) {
                    for (j = 2; j < q1; j++) {
                        UInt place = FELT_FFE_FIELDINFO_8BIT(info)[1 + (j - 1) * (q - 1) / (q1 - 1)];
                        if (GAPSEQ_FELT_FIELDINFO_8BIT(info)[place] == 0) {
                            GAPSEQ_FELT_FIELDINFO_8BIT(info)[place] = INTOBJ_INT(pos);
                            pos++;
                        }
                    }
                }
            }
        }
    }

    setelt_info = SETELT_FIELDINFO_8BIT(info);
    getelt_info = GETELT_FIELDINFO_8BIT(info);

    /* entry setting table SETELT...[(i*e+j)*256 +k] is the result
       of overwriting the jth element with i in the byte k */
    for (i = 0; i < q; i++)
        for (j = 0; j < e; j++)
        {
            iej_cache = (i * e + j) * 256;
            for (k = 0; k < 256; k++)
                setelt_info[iej_cache + k] = (UInt1)
                        ((k / pows[j + 1]) * pows[j + 1] + i*pows[j] + (k % pows[j]));
        }

    /* entry access GETELT...[i*256+j] recovers the ith entry from the
       byte j */
    for (i = 0; i < e; i++)
        for (j = 0; j < 256; j++)
            getelt_info[i * 256 + j] = (UInt1)(j / pows[i]) % q;

    /* scalar * vector multiply SCALAR...[i*256+j] is the scalar
       product of the byte j with the felt i */
    for (i = 0; i < q; i++) {
        mult = VAL_FFE(FFE_FELT_FIELDINFO_8BIT(info)[i]);
        for (j = 0; j < 256; j++) {
            val = 0;
            for (k  = 0; k < e; k++) {
                elt = VAL_FFE(FFE_FELT_FIELDINFO_8BIT(info)
                              [getelt_info[k * 256 + j]]);
                prod = PROD_FFV(elt, mult, succ);
                val += pows[k] * FELT_FFE_FIELDINFO_8BIT(info)[prod];
            }
            SCALAR_FIELDINFO_8BIT(info)[i * 256 + j] = val;
        }
    }

    /* inner product INNER...[i+256*j] is a byte whose LS entry is the contribution
       to the inner product of bytes i and j */

    for (i = 0; i < 256; i++)
        for (j = i; j < 256; j++) {
            val = 0;
            for (k = 0; k < e; k++) {
                el1 = VAL_FFE(FFE_FELT_FIELDINFO_8BIT(info)
                              [getelt_info[k * 256 + i]]);
                el2 = VAL_FFE(FFE_FELT_FIELDINFO_8BIT(info)
                              [getelt_info[k * 256 + j]]);
                elt = PROD_FFV(el1, el2, succ);
                val = SUM_FFV(val, elt, succ);
            }
            val = setelt_info[256 * e * FELT_FFE_FIELDINFO_8BIT(info)[val]];
            INNER_FIELDINFO_8BIT(info)[i + 256 * j] = val;
            INNER_FIELDINFO_8BIT(info)[j + 256 * i] = val;
        }

    /* PMULL and PMULU are the lower and upper bytes of the product
       of single-byte polynomials */
    for (i = 0; i < 256; i++)
        for (j = i; j < 256; j++) {
            val0 = 0;
            for (k = 0; k < e; k++) {
                val = 0;
                for (l = 0; l <= k; l++) {
                    el1 = VAL_FFE(FFE_FELT_FIELDINFO_8BIT(info)
                                  [getelt_info[l * 256 + i]]);
                    el2 = VAL_FFE(FFE_FELT_FIELDINFO_8BIT(info)
                                  [getelt_info[(k - l) * 256 + j]]);
                    elt = PROD_FFV(el1, el2, succ);
                    val = SUM_FFV(val, elt, succ);
                }
                val0 += pows[k] * FELT_FFE_FIELDINFO_8BIT(info)[val];
            }
            PMULL_FIELDINFO_8BIT(info)[i + 256 * j] = val0;
            PMULL_FIELDINFO_8BIT(info)[j + 256 * i] = val0;

            /* if there is just one entry per byte then we don't need the upper half */
            if (ELS_BYTE_FIELDINFO_8BIT(info) > 1) {
                val0 = 0;
                for (k = e; k < 2 * e - 1; k++) {
                    val = 0;
                    for (l = k - e + 1; l < e; l++) {
                        el1 = VAL_FFE(FFE_FELT_FIELDINFO_8BIT(info)
                                      [getelt_info[l * 256 + i]]);
                        el2 = VAL_FFE(FFE_FELT_FIELDINFO_8BIT(info)
                                      [getelt_info[(k - l) * 256 + j]]);
                        elt = PROD_FFV(el1, el2, succ);
                        val = SUM_FFV(val, elt, succ);
                    }
                    val0 += pows[k - e] * FELT_FFE_FIELDINFO_8BIT(info)[val];
                }
                PMULU_FIELDINFO_8BIT(info)[i + 256 * j] = val0;
                PMULU_FIELDINFO_8BIT(info)[j + 256 * i] = val0;
            }
        }


    /* In odd characteristic, we need the addition table
       ADD...[i*256+j] is the vector sum of bytes i and j */
    if (p != 2) {
        for (i = 0; i < 256; i++)
            for (j = i; j < 256; j++) {
                val = 0;
                for (k = 0; k < e; k++) {
                    el1 = VAL_FFE(FFE_FELT_FIELDINFO_8BIT(info)
                                  [getelt_info[k * 256 + i]]);
                    el2 = VAL_FFE(FFE_FELT_FIELDINFO_8BIT(info)
                                  [getelt_info[k * 256 + j]]);
                    val += pows[k] *
                           FELT_FFE_FIELDINFO_8BIT(info)[SUM_FFV(el1, el2, succ)];
                }
                ADD_FIELDINFO_8BIT(info)[i + 256 * j] = val;
                ADD_FIELDINFO_8BIT(info)[j + 256 * i] = val;
            }
    }


    MakeBagReadOnly(info);
    /* remember the result */
#ifdef HPCGAP
    ATOMIC_SET_ELM_PLIST_ONCE(FieldInfo8Bit, q, info);
#else
    SET_ELM_PLIST(FieldInfo8Bit, q, info);
#endif
    CHANGED_BAG(FieldInfo8Bit);
}
     
Obj GetFieldInfo8Bit( UInt q)
{
    Obj info;
    assert(2 < q && q <= 256);
#ifdef HPCGAP
    info = ATOMIC_ELM_PLIST(FieldInfo8Bit, q);
    if (info == 0) {
        MakeFieldInfo8Bit(q);
        info = ATOMIC_ELM_PLIST(FieldInfo8Bit, q);
    }
#else
    info = ELM_PLIST(FieldInfo8Bit, q);
    if (info == 0) {
        MakeFieldInfo8Bit(q);
        info = ELM_PLIST(FieldInfo8Bit, q);
    }
#endif
    return info;
}
  

/****************************************************************************
**
*F  RewriteVec8Bit( <vec>, <q> ) . . . . . . . . . . rewrite <vec> over GF(q)
**
** <vec> should be an 8 bit vector over a smaller field of the same
** characteristic 
*/

static Obj IsLockedRepresentationVector;

void RewriteVec8Bit( Obj vec, UInt q)
{
    UInt q1 = FIELD_VEC8BIT(vec);
    Obj info, info1;
    UInt len;
    UInt els, els1;
    /*UInt mut = IS_MUTABLE_OBJ(vec); */
    UInt mult;

    UInt1 *gettab1, *ptr1, byte1;
    UInt1 *settab, *ptr, byte;
    UInt1 * convtab;
    Obj *convtab1;
    FFV val;

    Int i;

    if (q1 == q)
        return;
    assert(q > q1);

    if (DoFilter(IsLockedRepresentationVector, vec) == True) {
        ErrorMayQuit("You cannot convert a locked vector compressed over GF(%i) to GF(%i)",
        q1, q);
        return;
    }

    /* extract the required info */
    len = LEN_VEC8BIT(vec);
    info = GetFieldInfo8Bit(q);
    info1 = GetFieldInfo8Bit(q1);
    assert(P_FIELDINFO_8BIT(info) == P_FIELDINFO_8BIT(info1));
    assert(!(D_FIELDINFO_8BIT(info) % D_FIELDINFO_8BIT(info1)));
    els = ELS_BYTE_FIELDINFO_8BIT(info);
    els1 = ELS_BYTE_FIELDINFO_8BIT(info1);

    if (len == 0) {
        SET_FIELD_VEC8BIT(vec, q);
        return;
    }

    /* enlarge the bag */
    ResizeBag(vec, SIZE_VEC8BIT(len, els));

    gettab1 = GETELT_FIELDINFO_8BIT(info1);
    convtab1 = FFE_FELT_FIELDINFO_8BIT(info1);
    settab = SETELT_FIELDINFO_8BIT(info);
    convtab = FELT_FFE_FIELDINFO_8BIT(info);
    ptr1 = BYTES_VEC8BIT(vec) + (len - 1) / els1;
    byte1 = *ptr1;
    ptr = BYTES_VEC8BIT(vec) + (len - 1) / els;
    byte = 0;
    i = len - 1;

    assert(((q - 1) % (q1 - 1)) == 0);
    mult = (q - 1) / (q1 - 1);
    while (i >= 0) {
        val = VAL_FFE(convtab1[ gettab1[byte1 + 256 * (i % els1)]]);
        if (val != 0)
            val = 1 + (val - 1) * mult;
        byte = settab[ byte + 256 * (i % els + els * convtab[ val ])];
        if (0 == i % els) {
            *ptr-- = byte;
            byte = 0;
        }
        if (0 == i % els1)
            byte1 = *--ptr1;
        i--;
    }
    SET_FIELD_VEC8BIT(vec, q);
}

/****************************************************************************
**
*F  RewriteGF2Vec( <vec>, <q> ) . . . . . . . . . . rewrite <vec> over GF(q)
**
** <vec> should be a GF2 vector and q a larger power of 2
**
** This function uses the interface in vecgf2.h
*/

void RewriteGF2Vec( Obj vec, UInt q )
{
    Obj info;
    UInt len;
    UInt els;
    UInt mut = IS_MUTABLE_OBJ(vec);
    UInt *ptr1;
    UInt block;
    UInt1 *settab, *ptr, byte;
    UInt1 *convtab;
    UInt1 zero, one;
    Int i;
    Obj type;

    assert(q % 2 == 0);

    if (DoFilter(IsLockedRepresentationVector, vec) == True) {
        ErrorMayQuit("You cannot convert a locked vector compressed over GF(2) to GF(%i)",
        q, 0);
        return;
    }

    /* extract the required info */
    len = LEN_GF2VEC(vec);
    info = GetFieldInfo8Bit(q);
    els = ELS_BYTE_FIELDINFO_8BIT(info);

    /* enlarge the bag */
    ResizeBag(vec, SIZE_VEC8BIT(len, els));

    settab = SETELT_FIELDINFO_8BIT(info);
    convtab = FELT_FFE_FIELDINFO_8BIT(info);
    zero = convtab[0];
    one = convtab[1];
    ptr1 = BLOCKS_GF2VEC(vec) + NUMBER_BLOCKS_GF2VEC(vec) - 1;
    block = *ptr1;
    ptr = BYTES_VEC8BIT(vec) + (len - 1) / els;
    byte = 0;
    i = len - 1;

    while (i >= 0) {
        byte = settab[ byte + 256 * (i % els + els * ((block & MASK_POS_GF2VEC(i + 1)) ? one : zero))];
        if (0 == i % els) {
            *ptr-- = byte;
            byte = 0;
        }
        if (0 == i % BIPEB)
            block = *--ptr1;
        i--;
    }
    SET_FIELD_VEC8BIT(vec, q);
    SET_LEN_VEC8BIT(vec, len);
    type = TypeVec8Bit(q, mut);
    SET_TYPE_POSOBJ(vec, type);
}


/****************************************************************************
**
*F  ConvVec8Bit( <list>, <q> )  . . .  convert a list into 8bit vector object
*/

void ConvVec8Bit (
    Obj                 list,
    UInt                q)
{
    Int                 len;            /* logical length of the vector    */
    Int                 i;              /* loop variable                   */
    UInt                p;  /* char */
    UInt                d;  /* degree */
    FF                  f;  /* field */
    /* Obj                 x;  / an element */
    Obj                 info; /* field info object */
    UInt                elts; /* elements per byte */
    UInt1 *             settab; /* element setting table */
    UInt1 *             convtab; /* FFE -> FELT conversion table */
    Obj                 firstthree[3]; /* the first three entries
          may get clobbered my the early bytes */
    UInt                e;  /* loop variable */
    UInt1               byte; /* byte under construction */
    UInt1*              ptr;  /* place to put byte */
    Obj                elt;
    UInt               val;
    UInt               nsize;
    Obj                type;

    if (q > 256)
        ErrorQuit("Field size %d is too much for 8 bits\n",
        q, 0L);
    if (q == 2)
        ErrorQuit("GF2 has its own representation\n", 0L, 0L);

    /* already in the correct representation                               */
    if (IS_VEC8BIT_REP(list)) {
        if (FIELD_VEC8BIT(list) == q)
            return;
        else if (FIELD_VEC8BIT(list) < q) {
            RewriteVec8Bit(list, q);
            return;
        }
        /* remaining case is list is written over too large a field
           pass through to the generic code */

    } else if (IS_GF2VEC_REP(list)) {
        RewriteGF2Vec(list, q);
        return;
    }

    len = LEN_LIST(list);

    /* OK, so now we know which field we want, set up data */
    info = GetFieldInfo8Bit(q);
    p = P_FIELDINFO_8BIT(info);
    d = D_FIELDINFO_8BIT(info);
    f = FiniteField(p, d);

    elts = ELS_BYTE_FIELDINFO_8BIT(info);

    /* We may need to resize first, as small lists get BIGGER
       in this process */
    nsize = SIZE_VEC8BIT(len, elts);
    if (nsize > SIZE_OBJ(list))
        ResizeBag(list, nsize);


    /* writing the first byte may clobber the third list entry
       before we have read it, so we take a copy */
    firstthree[0] = ELM0_LIST(list, 1);
    firstthree[1] = ELM0_LIST(list, 2);
    firstthree[2] = ELM0_LIST(list, 3);

    /* main loop -- e is the element within byte */
    e = 0;
    byte = 0;
    ptr = BYTES_VEC8BIT(list);
    for (i = 1;  i <= len;  i++) {
        elt = (i <= 3) ? firstthree[i - 1] : ELM_LIST(list, i);
        assert(CHAR_FF(FLD_FFE(elt)) == p);
        assert(d % DegreeFFE(elt) == 0);
        val = VAL_FFE(elt);
        if (val != 0 && FLD_FFE(elt) != f) {
            val = 1 + (val - 1) * (q - 1) / (SIZE_FF(FLD_FFE(elt)) - 1);
        }
        /* Must get these afresh after every list access, just in case this is
         a virtual list whose accesses might cause a garbage collection */
        settab = SETELT_FIELDINFO_8BIT(info);
        convtab = FELT_FFE_FIELDINFO_8BIT(info);
        byte = settab[(e + elts * convtab[val]) * 256 + byte];
        if (++e == elts || i == len) {
            *ptr++ = byte;
            byte = 0;
            e = 0;
        }
    }

    /* it can happen that the few bytes after the end of the data are
       not zero, because they had data in them in the old version of the list
       In most cases this doesn't matter, but in characteristic 2, we must
       clear up to the end of the word, so that AddCoeffs behaves correctly.
    SL -- lets do this in all characteristics, it can never hurt */

    while ((ptr - BYTES_VEC8BIT(list)) % sizeof(UInt))
        *ptr++ = 0;

    /* retype and resize bag */
    if (nsize != SIZE_OBJ(list))
        ResizeBag(list, nsize);
    SET_LEN_VEC8BIT(list, len);
    SET_FIELD_VEC8BIT(list, q);
    type = TypeVec8Bit(q, HAS_FILT_LIST(list, FN_IS_MUTABLE));
    SetTypeDatObj(list, type);
    RetypeBag(list, T_DATOBJ);
}

/****************************************************************************
**
*F  LcmDegree( <d>, <d1> )
**
*/

UInt LcmDegree( UInt d, UInt d1)
{
    UInt x, y, g;
    x = d;
    y = d1;
    while (x != 0 && y != 0) {
        if (x <= y)
            y = y % x;
        else
            x = x % y;
    }
    if (x == 0)
        g = y;
    else
        g = x;
    return (d*d1) / g;
}

/****************************************************************************
**
*F  FuncCONV_VEC8BIT( <self>, <list> ) . . . . . convert into 8bit vector rep
*/
Obj FuncCONV_VEC8BIT (
    Obj                 self,
    Obj                 list,
    Obj                 q)
{
    if (!IS_INTOBJ(q)) {
        ErrorMayQuit("CONV_VEC8BIT: q must be a small integer (3--256) not a %s",
        (Int)TNAM_OBJ(q), 0);
    }

    ConvVec8Bit(list, INT_INTOBJ(q));

    /* return nothing                                                      */
    return 0;
}

/****************************************************************************
**
*F  NewVec8Bit( <list>, <q> )  . . .  convert a list into 8bit vector object
**
**  This is a non-destructive counterpart of ConvVec8Bit
*/

Obj NewVec8Bit (
    Obj                 list,
    UInt                q)
{
    Int                 len;            /* logical length of the vector    */
    Int                 i;              /* loop variable                   */
    UInt                p;	/* char */
    UInt                d;	/* degree */
    FF                  f;	/* field */
 /* Obj                 x;	/ an element */
    Obj                 info;	/* field info object */
    UInt                elts;	/* elements per byte */
    UInt1 *             settab;	/* element setting table */
    UInt1 *             convtab; /* FFE -> FELT conversion table */
    UInt                e;	/* loop varibale */
    UInt1               byte;	/* byte under construction */
    UInt1*              ptr;	/* place to put byte */
    Obj                 elt;
    UInt                val;
    UInt                nsize;
    Obj                 type;
    Obj                 res;            /* resulting 8bit vector object     */

        
    if (q > 256)
      ErrorQuit("Field size %d is too much for 8 bits\n", q, 0L);
    if (q == 2)
      ErrorQuit("GF2 has its own representation\n", 0L, 0L);

    /* already in the correct representation                               */
    if ( IS_VEC8BIT_REP(list) )
      {
	if( FIELD_VEC8BIT(list) == q ) 
	  {
	    res = CopyVec8Bit(list,1); 
        if (!IS_MUTABLE_OBJ(list))
          /* index 0 is for immutable vectors */   
	  SetTypeDatObj( res, TypeVec8Bit( q, 0 ) );
        return res;
      }
	else if ( FIELD_VEC8BIT(list) < q )
	  {
	    /* rewriting to a larger field */   
        res = CopyVec8Bit(list,1);
        RewriteVec8Bit(res,q);
        /* TODO: rework RewriteVec8Bit and avoid calling CopyVec8Bit */
        if (!IS_MUTABLE_OBJ(list))
          SetTypeDatObj( res, TypeVec8Bit( q, 0 ) );
	    return res;
	  }
	/* remaining case is list is written over too large a field
	   pass through to the generic code */

    }
    else if ( IS_GF2VEC_REP(list) )
      {
        res = ShallowCopyVecGF2(list);  
        RewriteGF2Vec(res, q);
        /* TODO: rework RewriteGF2Vec and avoid calling ShallowCopyVecGF2 */
        if (!IS_MUTABLE_OBJ(list))
          SetTypeDatObj( res, TypeVec8Bit( q, 0 ) );
	    return res;
      }
    
    /* OK, so now we know which field we want, set up data */
    info = GetFieldInfo8Bit(q);
    p = P_FIELDINFO_8BIT(info);
    d = D_FIELDINFO_8BIT(info);
    f = FiniteField(p,d);

    /* determine the size and create a new bag */    
    len = LEN_LIST(list);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    nsize = SIZE_VEC8BIT(len,elts);
    res = NewBag( T_DATOBJ, nsize );
    
    /* main loop -- e is the element within byte */
    e = 0;
    byte = 0;
    ptr = BYTES_VEC8BIT(res);
    for ( i = 1;  i <= len;  i++ ) {
      elt = ELM_LIST(list,i);
      assert(CHAR_FF(FLD_FFE(elt)) == p);
      assert( d % DegreeFFE(elt) == 0);
      val = VAL_FFE(elt);
      if (val != 0 && FLD_FFE(elt) != f)
	{
	  val = 1+(val-1)*(q-1)/(SIZE_FF(FLD_FFE(elt))-1);
	}
      /* Must get these afresh after every list access, just in case this is
       a virtual list whose accesses might cause a garbage collection */
      settab = SETELT_FIELDINFO_8BIT(info);
      convtab = FELT_FFE_FIELDINFO_8BIT(info);
      byte = settab[(e + elts*convtab[val])*256 + byte];
      if (++e == elts || i == len)
	{
	  *ptr++ = byte;
	  byte = 0;
	  e = 0;
	}
    }
    
    /* retype bag */
    SET_LEN_VEC8BIT( res, len );
    SET_FIELD_VEC8BIT( res, q );
    type = TypeVec8Bit( q, HAS_FILT_LIST( list, FN_IS_MUTABLE) );
    SetTypeDatObj( res, type );
    
    return res;
}

/****************************************************************************
**
*F  FuncCOPY_VEC8BIT( <self>, <list> ) . . . . . convert into 8bit vector rep
**
**  This is a non-destructive counterpart of FuncCOPY_GF2VEC
*/
Obj FuncCOPY_VEC8BIT (
    Obj                 self,
    Obj                 list,
    Obj                 q)
{
  if (!IS_INTOBJ(q))
    {
      ErrorMayQuit("CONV_VEC8BIT: q must be a small integer (3--256) not a %s",
		   (Int)TNAM_OBJ(q), 0);
    }
    
  list = NewVec8Bit(list, INT_INTOBJ(q));
  
  return list;
}

/****************************************************************************
**
*F  PlainVec8Bit( <list> ) . . . convert an 8bit vector into an ordinary list
**
**  'PlainVec8Bit' converts the  vector <list> to a plain list.
*/
    
void PlainVec8Bit (
    Obj                 list )
{
    Int                 len;            /* length of <list>                */
    UInt                i;              /* loop variable                   */
    Obj                 first;          /* first entry                     */
    Obj                 second = 0;
    UInt                q;
    UInt                elts;
    Obj                 info;
    UInt1              *gettab;
    UInt                tnum;

    /* resize the list and retype it, in this order                        */
    if (True == DoFilter(IsLockedRepresentationVector, list)) {
        ErrorMayQuit("Attempt to convert locked compressed vector to plain list", 0, 0);
        return;
    }

    len = LEN_VEC8BIT(list);
    q = FIELD_VEC8BIT(list);
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);


    if (len == 0)
        tnum = T_PLIST_EMPTY;
    else
        tnum = T_PLIST_FFE;
    if (!IS_MUTABLE_OBJ(list))
        tnum += IMMUTABLE;
    RetypeBag(list, tnum);

    GROW_PLIST(list, (UInt)len);
    SET_LEN_PLIST(list, len);

    if (len != 0) {
        gettab = GETELT_FIELDINFO_8BIT(info);
        /* keep the first two entries
           because setting the third destroys them  */

        first = FFE_FELT_FIELDINFO_8BIT(info)[gettab[BYTES_VEC8BIT(list)[0]]];
        if (len > 1)
            second =
            FFE_FELT_FIELDINFO_8BIT(info)
            [gettab[256 * (1 % elts) + BYTES_VEC8BIT(list)[1 / elts]]];

        /* replace the bits by FF elts as the case may be        */
        /* this must of course be done from the end of the list backwards      */
        for (i = len;  2 < i;  i--)
            SET_ELM_PLIST(list, i,
            FFE_FELT_FIELDINFO_8BIT(info)
            [gettab[256 * ((i - 1) % elts) +
            BYTES_VEC8BIT(list)[(i - 1) / elts]]]);
        if (len > 1)
            SET_ELM_PLIST(list, 2, second);
        SET_ELM_PLIST(list, 1, first);
    }
    /* Null out any entries after the end of valid data */
    for (i = len + 1; i < (SIZE_BAG(list) + sizeof(Obj) - 1) / sizeof(Obj); i++)
        SET_ELM_PLIST(list, i, (Obj) 0);

    CHANGED_BAG(list);
}

/****************************************************************************
**
*F  FuncPLAIN_VEC8BIT( <self>, <list> ) . . .  convert back into ordinary list
*/
Obj FuncPLAIN_VEC8BIT (
    Obj                 self,
    Obj                 list )
{
    /* check whether <list> is an 8bit vector                                */
    while (! IS_VEC8BIT_REP(list)) {
        list = ErrorReturnObj(
            "CONV_BLIST: <list> must be an 8bit vector (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can replace <list> via 'return <list>;'");
    }
    if (DoFilter(IsLockedRepresentationVector, list) == True) {
        ErrorMayQuit("You cannot convert a locked vector compressed over GF(%i) to a plain list",
        FIELD_VEC8BIT(list) , 0);
        return 0;
    }
    PlainVec8Bit(list);

    /* return nothing                                                      */
    return 0;
}


/****************************************************************************
**
*F * * * * * * * * * * * * arithmetic operations  * * * * * * * * * * * * * *
*/

#define NUMBLOCKS_VEC8BIT(len,elts) \
        (((len) + sizeof(UInt)*(elts)-1)/(sizeof(UInt)*(elts)))

#define BLOCKS_VEC8BIT(vec) ((UInt *)BYTES_VEC8BIT(vec))     


/****************************************************************************
**
*F  CopyVec8Bit( <list>, <mut> ) .copying function
**
*/


Obj CopyVec8Bit( Obj list, UInt mut )
{
    Obj copy;
    UInt size;
    UInt q;
    Obj type;

    size = SIZE_BAG(list);
    copy = NewBag(T_DATOBJ, size);
    q = FIELD_VEC8BIT(list);
    type = TypeVec8Bit(q, mut);
    SetTypeDatObj(copy, type);
    CHANGED_BAG(copy);
    SET_LEN_VEC8BIT(copy, LEN_VEC8BIT(list));
    SET_FIELD_VEC8BIT(copy, q);
    memcpy(BYTES_VEC8BIT(copy), BYTES_VEC8BIT(list), size - 3 * sizeof(UInt));
    return copy;
}



/****************************************************************************
**
*F  AddVec8BitVec8BitInner( <sum>, <vl>, <vr>, <start>, <stop> )
**
**  This is the real vector add routine. Others are all calls to this
**  one.
**  Addition is done from THE BLOCK containing <start> to the one
**  containing <stop> INCLUSIVE. The remainder of <sum> is unchanged.
**  <sum> may be the same vector as <vl> or
**  <vr>. <vl> and <vr> must be over the same field and <sum> must be
**  initialized as a vector over this field of length at least <stop>.
**
*/

void  AddVec8BitVec8BitInner( Obj sum,
  Obj vl,
  Obj vr,
  UInt start,
  UInt stop )
{
    Obj info;
    UInt p;
    UInt elts;

    /* Maybe there's nothing to do */
    if (!stop)
        return;
    info = GetFieldInfo8Bit(FIELD_VEC8BIT(sum));
    assert(Q_FIELDINFO_8BIT(info) == FIELD_VEC8BIT(vl));
    assert(Q_FIELDINFO_8BIT(info) == FIELD_VEC8BIT(vr));
    assert(LEN_VEC8BIT(sum) >= stop);
    assert(LEN_VEC8BIT(vl) >= stop);
    assert(LEN_VEC8BIT(vr) >= stop);
    p = P_FIELDINFO_8BIT(info);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    /* Convert from 1 based to zero based addressing */
    start --;
    stop --;
    if (p == 2) {
        UInt *ptrL2;
        UInt *ptrR2;
        UInt *ptrS2;
        UInt *endS2;
        ptrL2 = BLOCKS_VEC8BIT(vl) + start / (sizeof(UInt) * elts);
        ptrR2 = BLOCKS_VEC8BIT(vr) + start / (sizeof(UInt) * elts);
        ptrS2 = BLOCKS_VEC8BIT(sum) + start / (sizeof(UInt) * elts);
        endS2 = BLOCKS_VEC8BIT(sum) + stop / (sizeof(UInt) * elts) + 1;
        if (sum == vl) {
            while (ptrL2 < endS2) {
                *ptrL2 ^= *ptrR2;
                ptrL2++;
                ptrR2++;
            }
        } else if (sum == vr) {
            while (ptrR2 < endS2) {
                *ptrR2 ^=  *ptrL2;
                ptrL2++;
                ptrR2++;
            }

        } else
            while (ptrS2 < endS2)
                *ptrS2++ = *ptrL2++ ^ *ptrR2++;
    } else {
        UInt1 *ptrL;
        UInt1 *ptrR;
        UInt1 *ptrS;
        UInt1 *endS;
        UInt x;
        const UInt1 *addtab = ADD_FIELDINFO_8BIT(info);
        ptrL = BYTES_VEC8BIT(vl) + start / elts;
        ptrR = BYTES_VEC8BIT(vr) + start / elts;
        ptrS = BYTES_VEC8BIT(sum) + start / elts;
        endS = BYTES_VEC8BIT(sum) + stop / elts + 1;
        if (vl == sum) {
            while (ptrL < endS) {
                if ((x = *ptrR) != 0)
                    * ptrL = addtab[256 * (*ptrL) + x];
                ptrR++;
                ptrL++;
            }
        } else if (vr == sum) {
            while (ptrR < endS) {
                if ((x = *ptrL) != 0)
                    * ptrR = addtab[256 * (x) + *ptrR];
                ptrR++;
                ptrL++;
            }
        } else
            while (ptrS < endS)
                *ptrS++ = addtab[256 * (*ptrL++) + *ptrR++];
    }
    return;
}

/****************************************************************************
**
*F  SumVec8BitVec8Bit( <vl>, <vr> )
**
**  This is perhaps the simplest wrapper for the Add..Inner function
**  it allocates a new vector for the result, and adds the whole vectors into
**  it. No checking is done. The result follows the new mutability convention
**  (mutable if either argument is).
*/

Obj SumVec8BitVec8Bit( Obj vl, Obj vr )
{
    Obj sum;
    Obj info;
    UInt elts;
    UInt q;
    UInt len;
    Obj type;

    q = FIELD_VEC8BIT(vl);
    len = LEN_VEC8BIT(vl);
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    sum = NewBag(T_DATOBJ, SIZE_VEC8BIT(len, elts));
    SET_LEN_VEC8BIT(sum, len);
    type = TypeVec8Bit(q, IS_MUTABLE_OBJ(vl) || IS_MUTABLE_OBJ(vr));
    SetTypeDatObj(sum, type);
    SET_FIELD_VEC8BIT(sum, q);
    CHANGED_BAG(sum);
    AddVec8BitVec8BitInner(sum, vl, vr, 1, len);
    return sum;
}

/****************************************************************************
**
*F  FuncSUM_VEC8BIT_VEC8BIT( <self>, <vl>, <vr> )
**
** This is the GAP callable method for +. The method installation should
** ensure that we have matching characteristics, but we may not have a common
** field or the same lengths
**
*/

static Obj ConvertToVectorRep;  /* BH: changed to static */


Obj FuncSUM_VEC8BIT_VEC8BIT( Obj self, Obj vl, Obj vr)
{
    Obj sum;
    if (FIELD_VEC8BIT(vl) != FIELD_VEC8BIT(vr)) {
        UInt ql = FIELD_VEC8BIT(vl), qr = FIELD_VEC8BIT(vr);
        Obj infol = GetFieldInfo8Bit(ql), infor = GetFieldInfo8Bit(qr);
        UInt newd = LcmDegree(D_FIELDINFO_8BIT(infol), D_FIELDINFO_8BIT(infor));
        UInt p, newq;
        UInt i;
        p = P_FIELDINFO_8BIT(infol);
        assert(p == P_FIELDINFO_8BIT(infor));
        newq = 1;
        for (i = 0; i < newd; i++)
            newq *= p;

        /* if the exponent is bigger than 31, overflow changes the value to 0 */
        if (newd > 8 || newq > 256 ||
            (ql != newq && True == CALL_1ARGS(IsLockedRepresentationVector, vl)) ||
            (qr != newq && True == CALL_1ARGS(IsLockedRepresentationVector, vr))) {
            sum = SumListList(vl, vr);
            return sum;
        } else {
            RewriteVec8Bit(vl, newq);
            RewriteVec8Bit(vr, newq);
        }
    }


    /* just add if they're the same length,
       otherwise copy the longer and add in the shorter */

    if (LEN_VEC8BIT(vl) == LEN_VEC8BIT(vr))
        return SumVec8BitVec8Bit(vl, vr);
    else if (LEN_VEC8BIT(vl) > LEN_VEC8BIT(vr)) {
        sum = CopyVec8Bit(vl, IS_MUTABLE_OBJ(vl) || IS_MUTABLE_OBJ(vr));
        AddVec8BitVec8BitInner(sum, sum, vr, 1, LEN_VEC8BIT(vr));
    } else {
        sum = CopyVec8Bit(vr, IS_MUTABLE_OBJ(vl) || IS_MUTABLE_OBJ(vr));
        AddVec8BitVec8BitInner(sum, sum, vl, 1, LEN_VEC8BIT(vl));
    }

    return sum;
}


/****************************************************************************
**
*F  MultVec8BitFFEInner( <prod>, <vec>, <scal>, <start>, <stop> )
**
**  This is the real vector * scalar routine. Others are all calls to this
**  one.
**  Multiplication is done from THE BLOCK containing <start> to the one
**  containing <stop> INCLUSIVE. The remainder of <prod> is unchanged.
**  <prod> may be the same vector as <vec> 
**  <scal> must be written over the field of <vec> and
**  <prod> must be
**  initialized as a vector over this field of length at least <stop>.
**
*/

void MultVec8BitFFEInner( Obj prod,
        Obj vec,
        Obj scal,
        UInt start,
        UInt stop )
{
    Obj info;
    UInt elts;
    UInt1 *ptrV;
    UInt1 *ptrS;
    UInt1 *endS;
    UInt1 *tab;

    if (!stop)
        return;
    info = GetFieldInfo8Bit(FIELD_VEC8BIT(prod));
    elts = ELS_BYTE_FIELDINFO_8BIT(info);

    assert(Q_FIELDINFO_8BIT(info) == FIELD_VEC8BIT(vec));
    assert(LEN_VEC8BIT(prod) >= stop);
    assert(LEN_VEC8BIT(vec) >= stop);
    assert(Q_FIELDINFO_8BIT(info) == SIZE_FF(FLD_FFE(scal)));


    /* convert to 0 based addressing */
    start--;
    stop--;
    tab = SCALAR_FIELDINFO_8BIT(info) +
    256 * FELT_FFE_FIELDINFO_8BIT(info)[VAL_FFE(scal)];
    ptrV = BYTES_VEC8BIT(vec) + start / elts;
    ptrS = BYTES_VEC8BIT(prod) + start / elts;
    endS = BYTES_VEC8BIT(prod) + stop / elts + 1;
    while (ptrS < endS)
        *ptrS++ = tab[*ptrV++];
    return;
}

/****************************************************************************
**
*F  MultVec8BitFFE( <vec>, <scal> ) . . . simple scalar multiply
**
**  This is a basic wrapper for Mult...Inner. It allocates space for
**  the result, promotes the scalar to the proper field if necessary and
**  runs over the whole vector
**
*/

Obj MultVec8BitFFE( Obj vec, Obj scal )
{
    Obj prod;
    Obj info;
    UInt elts;
    UInt q;
    UInt len;
    UInt v;
    Obj type;

    q = FIELD_VEC8BIT(vec);
    len = LEN_VEC8BIT(vec);
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    prod = NewBag(T_DATOBJ, SIZE_VEC8BIT(len, elts));
    SET_LEN_VEC8BIT(prod, len);
    type = TypeVec8Bit(q, IS_MUTABLE_OBJ(vec));
    SetTypeDatObj(prod, type);
    SET_FIELD_VEC8BIT(prod, q);
    CHANGED_BAG(prod);
    if (SIZE_FF(FLD_FFE(scal)) != q) {
        v = VAL_FFE(scal);
        if (v != 0)
            v = 1 + (v - 1) * (q - 1) / (SIZE_FF(FLD_FFE(scal)) - 1);
        scal = NEW_FFE(FiniteField(P_FIELDINFO_8BIT(info),
        D_FIELDINFO_8BIT(info)), v);
    }
    MultVec8BitFFEInner(prod, vec, scal, 1, len);
    return prod;
}


/****************************************************************************
**
*F  ZeroVec8Bit( <q>, <len>, <mut> ). . . . . . . . . . .return a zero vector
**
*/

Obj ZeroVec8Bit ( UInt q, UInt len, UInt mut )
{
    Obj zerov;
    UInt size;
    Obj info;
    Obj type;
    info = GetFieldInfo8Bit(q);
    size = SIZE_VEC8BIT(len, ELS_BYTE_FIELDINFO_8BIT(info));
    zerov = NewBag(T_DATOBJ, size);
    type = TypeVec8Bit(q, mut);
    SetTypeDatObj(zerov, type);
    CHANGED_BAG(zerov);
    SET_LEN_VEC8BIT(zerov, len);
    SET_FIELD_VEC8BIT(zerov, q);
    return zerov;
}


/****************************************************************************
**
*F  FuncPROD_VEC8BIT_FFE( <self>, <vec>, <ffe> )
**
** This is the GAP callable method for *. The method installation should
** ensure that we have matching characteristics, but we may not have a common
** field
**
*/

Obj FuncPROD_VEC8BIT_FFE( Obj self, Obj vec, Obj ffe)
{
    Obj prod;
    Obj info;
    UInt d;

    if (VAL_FFE(ffe) == 1) { /* ffe is the one */
        prod = CopyVec8Bit(vec, IS_MUTABLE_OBJ(vec));
    } else if (VAL_FFE(ffe) == 0)
        return ZeroVec8Bit(FIELD_VEC8BIT(vec), LEN_VEC8BIT(vec), IS_MUTABLE_OBJ(vec));

    info = GetFieldInfo8Bit(FIELD_VEC8BIT(vec));
    d = D_FIELDINFO_8BIT(info);

    /* family predicate should have handled this */
    assert(CHAR_FF(FLD_FFE(ffe)) == P_FIELDINFO_8BIT(info));

    /* check for field compatibility */
    if (d % DEGR_FF(FLD_FFE(ffe))) {
        prod = ProdListScl(vec, ffe);
        CALL_1ARGS(ConvertToVectorRep, prod);
        return prod;
    }

    /* Finally the main line */
    return MultVec8BitFFE(vec, ffe);
}

/****************************************************************************
**
*F  FuncZERO_VEC8BIT( <self>, <vec> )
**
*/

Obj FuncZERO_VEC8BIT( Obj self, Obj vec )
{
    return ZeroVec8Bit(FIELD_VEC8BIT(vec),
                       LEN_VEC8BIT(vec),
                       1);
}

/****************************************************************************
**
*F  FuncZERO_VEC8BIT_2( <self>, <q>, <len> )
**
*/

Obj FuncZERO_VEC8BIT_2( Obj self, Obj q, Obj len )
{
    if (!ARE_INTOBJS(q, len))
        ErrorQuit("ZERO_VEC8BIT2: arguments must be small integers, not a %s and a %s",
        (Int)TNAM_OBJ(q), (Int)TNAM_OBJ(len));
    return ZeroVec8Bit(INT_INTOBJ(q),
                       INT_INTOBJ(len),
                       1L);
}

/****************************************************************************
**
*F  FuncPROD_FFE_VEC8BIT( <self>, <ffe>, <vec> )
**
** This is the GAP callable method for *. The method installation should
** ensure that we have matching characteristics, but we may not have a common
** field
**
** Here we can fall back on the method above.
*/

Obj FuncPROD_FFE_VEC8BIT( Obj self, Obj ffe, Obj vec)
{
    return FuncPROD_VEC8BIT_FFE(self, vec, ffe);
}

/****************************************************************************
**
*F  FuncAINV_VEC8BIT_*( <self>, <vec>)
**
** GAP Callable methods for unary -
*/

Obj AinvVec8Bit( Obj vec, UInt mut)
{
    Obj info;
    UInt p;
    /*UInt d; */
    UInt minusOne;
    Obj neg;
    FF f;
    info = GetFieldInfo8Bit(FIELD_VEC8BIT(vec));
    p = P_FIELDINFO_8BIT(info);

    neg = CopyVec8Bit(vec, mut);
    /* characteristic 2 case */
    if (2 == p) {
        return neg;
    }

    /* Otherwise */
    f = FiniteField(p, D_FIELDINFO_8BIT(info));
    minusOne = NEG_FFV(1, SUCC_FF(f));
    MultVec8BitFFEInner(neg, neg, NEW_FFE(f, minusOne), 1, LEN_VEC8BIT(neg));
    return neg;
}

Obj FuncAINV_VEC8BIT_MUTABLE( Obj self, Obj vec )
{
    return AinvVec8Bit(vec, 1);
}

Obj FuncAINV_VEC8BIT_SAME_MUTABILITY( Obj self, Obj vec )
{
    return AinvVec8Bit(vec, IS_MUTABLE_OBJ(vec));
}

Obj FuncAINV_VEC8BIT_IMMUTABLE( Obj self, Obj vec )
{
    return AinvVec8Bit(vec, 0);
}



/****************************************************************************
**
*F  AddVec8BitVec8BitMultInner( <sum>, <vl>, <vr>, <mult> <start>, <stop> )
**
**  This is the real vector add multiple routine. Others are all calls to this
**  one. It adds <mult>*<vr> to <vl> leaving the result in <sum>
** 
**  Addition is done from THE BLOCK containing <start> to the one
**  containing <stop> INCLUSIVE. The remainder of <sum> is unchanged.
**  <sum> may be the same vector as <vl> or
**  <vr>. <vl> and <vr> must be over the same field and <sum> must be
**  initialized as a vector over this field of length at least <stop>.
**
**  <mult> is assumed to be over the correct field  and may not be zero
**
*/

void  AddVec8BitVec8BitMultInner( Obj sum,
          Obj vl,
          Obj vr,
          Obj mult,
          UInt start,
          UInt stop )
{
    Obj info;
    UInt p;
    UInt elts;
    UInt1 *ptrL;
    UInt1 *ptrR;
    UInt1 *ptrS;
    UInt1 *endS;
    UInt1 *addtab = 0;
    UInt1 *multab;
    UInt x;

    if (!stop)
        return;

    /* Handle special cases of <mult> */
    if (VAL_FFE(mult) == 0 && sum == vl)
        return;

    if (VAL_FFE(mult) == 1) {
        AddVec8BitVec8BitInner(sum, vl, vr, start, stop);
        return;
    }

    /*  so we have some work. get the tables */
    info = GetFieldInfo8Bit(FIELD_VEC8BIT(sum));

    p = P_FIELDINFO_8BIT(info);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);

    /* Convert from 1 based to zero based addressing */
    start --;
    stop --;
    if (p != 2)
        addtab = ADD_FIELDINFO_8BIT(info);

    multab = SCALAR_FIELDINFO_8BIT(info) +
    256 * FELT_FFE_FIELDINFO_8BIT(info)[VAL_FFE(mult)];

    ptrL = BYTES_VEC8BIT(vl) + start / elts;
    ptrR = BYTES_VEC8BIT(vr) + start / elts;
    ptrS = BYTES_VEC8BIT(sum) + start / elts;
    endS = BYTES_VEC8BIT(sum) + stop / elts + 1;
    if (p != 2) {
        if (sum == vl) {
            const UInt1* endS1 = endS;
            const UInt1* addtab1 = addtab;
            const UInt1* multab1 = multab;
            while (ptrL < endS1) {
                if ((x = *ptrR) != 0)
                    * ptrL = addtab1[256 * (*ptrL) + multab1[x]];
                ptrL++;
                ptrR++;
            }
        } else
            while (ptrS < endS)
                *ptrS++ = addtab[256 * (*ptrL++) + multab[*ptrR++]];
    } else if (sum == vl) {
        while (ptrL < endS) {
            if ((x = *ptrR) != 0)
                * ptrL = *ptrL ^ multab[x];
            ptrR++;
            ptrL++;
        }
    } else
        while (ptrS < endS)
            *ptrS++ = *ptrL++ ^ multab[*ptrR++];
    return;
}

/****************************************************************************
**
*F  FuncMULT_ROW_VECTOR( <self>, <vec>, <mul> )
**
**  In-place scalar multiply
*/

Obj FuncMULT_ROWVECTOR_VEC8BITS( Obj self, Obj vec, Obj mul)
{
    UInt q;
    q = FIELD_VEC8BIT(vec);

    if (VAL_FFE(mul) == 1)
        return (Obj)0;

    /* Now check the field of <mul> */
    if (q != SIZE_FF(FLD_FFE(mul))) {
        Obj info;
        UInt d, d1;
        FFV val;
        info = GetFieldInfo8Bit(q);
        d = D_FIELDINFO_8BIT(info);
        d1 = DegreeFFE(mul);
        if (d % d1)
            return TRY_NEXT_METHOD;
        val = VAL_FFE(mul);
        if (val != 0)
            val = 1 + (val - 1) * (q - 1) / (SIZE_FF(FLD_FFE(mul)) - 1);
        mul = NEW_FFE(FiniteField(P_FIELDINFO_8BIT(info), d), val);
    }
    MultVec8BitFFEInner(vec, vec, mul, 1, LEN_VEC8BIT(vec));
    return (Obj)0;
}

/****************************************************************************
**
*F  FuncADD_ROWVECTOR_VEC8BITS_5( <self>, <vl>, <vr>, <mul>, <from>, <to> )
**
**  The three argument method for AddRowVector
**
*/

Obj AddRowVector;

Obj FuncADD_ROWVECTOR_VEC8BITS_5( Obj self, Obj vl, Obj vr, Obj mul, Obj from, Obj to)
{
    UInt q;
    UInt len;
    len = LEN_VEC8BIT(vl);
    /* There may be nothing to do */
    if (LT(to, from))
        return (Obj) 0;

    if (len != LEN_VEC8BIT(vr)) {
        vr = ErrorReturnObj("AddRowVector: <left> and <right> must be vectors of the same length",
                            0L, 0L,
                            "you can replace <right> via 'return <right>;'");

        /* Now redispatch, because vr could be anything */
        return CALL_3ARGS(AddRowVector, vl, vr, mul);
    }
    while (LT(INTOBJ_INT(len), to)) {
        to = ErrorReturnObj("AddRowVector: <to> (%d) is greater than the length of the vectors (%d)",
                            INT_INTOBJ(to), len,
                            "you can replace <to> via 'return <to>;'");
    }
    if (LT(to, from))
        return (Obj) 0;

    /* Now we know that the characteristics must match, but not the fields */
    q = FIELD_VEC8BIT(vl);

    /* fix up fields if necessary */
    if (q != FIELD_VEC8BIT(vr) || q != SIZE_FF(FLD_FFE(mul))) {
        Obj info, info1;
        UInt d, d1, q1, d2, d0, q0, p, i;
        FFV val;

        /* find a common field */
        info = GetFieldInfo8Bit(q);
        d = D_FIELDINFO_8BIT(info);
        q1 = FIELD_VEC8BIT(vr);
        info1 = GetFieldInfo8Bit(q1);
        d1 = D_FIELDINFO_8BIT(info1);
        d2 = DegreeFFE(mul);
        d0 = LcmDegree(d, d1);
        d0 = LcmDegree(d0, d2);
        p = P_FIELDINFO_8BIT(info);
        assert(p == P_FIELDINFO_8BIT(info1));
        assert(p == CHAR_FF(FLD_FFE(mul)));
        q0 = 1;
        for (i = 0; i < d0; i++)
            q0 *= p;

        /* if the exponent is bigger than 31, overflow changes the value to 0 */
        if (d0 > 8 || q0 > 256)
            return TRY_NEXT_METHOD;
        if ((q0 > q && DoFilter(IsLockedRepresentationVector, vl) == True) ||
        (q0 > q1 && DoFilter(IsLockedRepresentationVector, vr) == True))
            return TRY_NEXT_METHOD;
        RewriteVec8Bit(vl, q0);
        RewriteVec8Bit(vr, q0);
        val = VAL_FFE(mul);
        if (val != 0)
            val = 1 + (val - 1) * (q0 - 1) / (SIZE_FF(FLD_FFE(mul)) - 1);
        mul = NEW_FFE(FiniteField(p, d0), val);
        q = q0;
    }

    AddVec8BitVec8BitMultInner(vl, vl, vr, mul, INT_INTOBJ(from), INT_INTOBJ(to));
    return (Obj)0;
}

/****************************************************************************
**
*F  FuncADD_ROWVECTOR_VEC8BITS_3( <self>, <vl>, <vr>, <mul> )
**
**  The three argument method for AddRowVector
**
*/

Obj FuncADD_ROWVECTOR_VEC8BITS_3( Obj self, Obj vl, Obj vr, Obj mul)
{
    UInt q;
    if (LEN_VEC8BIT(vl) != LEN_VEC8BIT(vr)) {
        vr = ErrorReturnObj("SUM: <left> and <right> must be vectors of the same length",
                            0L, 0L,
                            "you can replace <right> via 'return <right>;'");

        /* Now redispatch, because vr could be anything */
        return CALL_3ARGS(AddRowVector, vl, vr, mul);
    }
    /* Now we know that the characteristics must match, but not the fields */
    q = FIELD_VEC8BIT(vl);

    /* fix up fields if necessary */
    if (q != FIELD_VEC8BIT(vr) || q != SIZE_FF(FLD_FFE(mul))) {
        Obj info, info1;
        UInt d, d1, q1, d2, d0, q0, p, i;
        FFV val;
        /* find a common field */
        info = GetFieldInfo8Bit(q);
        d = D_FIELDINFO_8BIT(info);
        q1 = FIELD_VEC8BIT(vr);
        info1 = GetFieldInfo8Bit(q1);
        d1 = D_FIELDINFO_8BIT(info1);
        d2 = DegreeFFE(mul);
        d0 = LcmDegree(d, d1);
        d0 = LcmDegree(d0, d2);
        p = P_FIELDINFO_8BIT(info);
        assert(p == P_FIELDINFO_8BIT(info1));
        assert(p == CHAR_FF(FLD_FFE(mul)));
        q0 = 1;
        for (i = 0; i < d0; i++)
            q0 *= p;

        /* if the exponent is bigger than 31, overflow changes the value to 0 */
        if (d0 > 8 || q0 > 256)
            return TRY_NEXT_METHOD;
        if ((q0 > q && CALL_1ARGS(IsLockedRepresentationVector, vl) == True) ||
        (q0 > q1 && CALL_1ARGS(IsLockedRepresentationVector, vr) == True))
            return TRY_NEXT_METHOD;
        RewriteVec8Bit(vl, q0);
        RewriteVec8Bit(vr, q0);
        val = VAL_FFE(mul);
        if (val != 0)
            val = 1 + (val - 1) * (q0 - 1) / (SIZE_FF(FLD_FFE(mul)) - 1);
        mul = NEW_FFE(FiniteField(p, d0), val);
        q = q0;
    }
    AddVec8BitVec8BitMultInner(vl, vl, vr, mul, 1, LEN_VEC8BIT(vl));
    return (Obj)0;
}

/****************************************************************************
**
*F  FuncADD_ROWVECTOR_VEC8BITS_2( <self>, <vl>, <vr>)
**
**  The two argument method for AddRowVector
**
*/

Obj FuncADD_ROWVECTOR_VEC8BITS_2( Obj self, Obj vl, Obj vr)
{
    UInt q;
    if (LEN_VEC8BIT(vl) != LEN_VEC8BIT(vr)) {
        vr = ErrorReturnObj("SUM: <left> and <right> must be vectors of the same length",
                            0L, 0L,
                            "you can replace <right> via 'return <right>;'");

        /* Now redispatch, because vr could be anything */
        return CALL_2ARGS(AddRowVector, vl, vr);
    }
    /* Now we know that the characteristics must match, but not the fields */
    q = FIELD_VEC8BIT(vl);
    /* fix up fields if necessary */
    if (q != FIELD_VEC8BIT(vr)) {
        Obj info1;
        Obj info;
        UInt d, d1, q1, d0, q0, p, i;
        /* find a common field */
        info = GetFieldInfo8Bit(q);
        d = D_FIELDINFO_8BIT(info);
        q1 = FIELD_VEC8BIT(vr);
        info1 = GetFieldInfo8Bit(q1);
        d1 = D_FIELDINFO_8BIT(info1);
        d0 = LcmDegree(d, d1);
        p = P_FIELDINFO_8BIT(info);
        assert(p == P_FIELDINFO_8BIT(info1));
        q0 = 1;
        for (i = 0; i < d0; i++)
            q0 *= p;

        /* if the exponent is bigger than 31, overflow changes the value to 0 */
        if (d0 > 8 || q0 > 256)
            return TRY_NEXT_METHOD;
        if ((q0 > q && CALL_1ARGS(IsLockedRepresentationVector, vl) == True) ||
        (q0 > q1 && CALL_1ARGS(IsLockedRepresentationVector, vr) == True))
            return TRY_NEXT_METHOD;
        RewriteVec8Bit(vl, q0);
        RewriteVec8Bit(vr, q0);
        q = q0;
    }
    AddVec8BitVec8BitInner(vl, vl, vr, 1, LEN_VEC8BIT(vl));
    return (Obj)0;
}


/****************************************************************************
**
*F  SumVec8BitVec8BitMult( <vl>, <vr>, <mult> )
**
**  This is perhaps the simplest wrapper for the Add..MultInner function
**  it allocates a new vector for the result, and adds the whole vectors into
**  it. Mult is promoted to the proper field if necessary.
**  The result follows the new mutability convention
**  (mutable if either argument is).
*/

Obj SumVec8BitVec8BitMult( Obj vl, Obj vr, Obj mult )
{
    Obj sum;
    Obj info;
    UInt elts;
    UInt q;
    UInt len;
    FFV v;
    Obj type;

    q = FIELD_VEC8BIT(vl);
    len = LEN_VEC8BIT(vl);
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    sum = NewBag(T_DATOBJ, SIZE_VEC8BIT(len, elts));
    SET_LEN_VEC8BIT(sum, len);
    type = TypeVec8Bit(q, IS_MUTABLE_OBJ(vl) || IS_MUTABLE_OBJ(vr));
    SetTypeDatObj(sum, type);
    SET_FIELD_VEC8BIT(sum, q);
    CHANGED_BAG(sum);
    if (SIZE_FF(FLD_FFE(mult)) != q) {
        v = VAL_FFE(mult);
        if (v != 0)
            v = 1 + (v - 1) * (q - 1) / (SIZE_FF(FLD_FFE(mult)) - 1);
        mult = NEW_FFE(FiniteField(P_FIELDINFO_8BIT(info),
        D_FIELDINFO_8BIT(info)), v);
    }
    AddVec8BitVec8BitMultInner(sum, vl, vr, mult, 1, len);
    return sum;
}

/****************************************************************************
**
*F  DiffVec8BitVec8Bit( <vl>, <vr> )
**
*/

Obj DiffVec8BitVec8Bit( Obj vl, Obj vr)
{
    Obj info;
    FF f;
    FFV minusOne;
    Obj MinusOne;
    Obj dif;
    Obj type;

    info = GetFieldInfo8Bit(FIELD_VEC8BIT(vl));
    f = FiniteField(P_FIELDINFO_8BIT(info), D_FIELDINFO_8BIT(info));
    minusOne = NEG_FFV(1, SUCC_FF(f));
    MinusOne = NEW_FFE(f, minusOne);

    if (LEN_VEC8BIT(vl) == LEN_VEC8BIT(vr))
        return SumVec8BitVec8BitMult(vl, vr, MinusOne);
    else if (LEN_VEC8BIT(vl) < LEN_VEC8BIT(vr)) {
        dif = MultVec8BitFFE(vr, MinusOne);
        AddVec8BitVec8BitInner(dif, dif, vl, 1, LEN_VEC8BIT(vl));
        if (IS_MUTABLE_OBJ(vl) && !IS_MUTABLE_OBJ(vr)) {
            type = TypeVec8Bit(Q_FIELDINFO_8BIT(info), 1);
            SetTypeDatObj(dif, type);
        }
        return dif;
    } else {
        dif = CopyVec8Bit(vl, IS_MUTABLE_OBJ(vl) || IS_MUTABLE_OBJ(vr));
        AddVec8BitVec8BitMultInner(dif, dif, vr, MinusOne, 1, LEN_VEC8BIT(vr));
        return dif;
    }
}


/****************************************************************************
**
*F  FuncDIFF_VEC8BIT_VEC8BIT ( <self>, <vl>, <vr> )
**
**  GAP callable method for binary -
*/
Obj FuncDIFF_VEC8BIT_VEC8BIT( Obj self, Obj vl, Obj vr)
{
    Obj diff;
    /*UInt p; */


    if (FIELD_VEC8BIT(vl) != FIELD_VEC8BIT(vr)) {
        UInt ql = FIELD_VEC8BIT(vl), qr = FIELD_VEC8BIT(vr);
        Obj infol = GetFieldInfo8Bit(ql), infor = GetFieldInfo8Bit(qr);
        UInt newd = LcmDegree(D_FIELDINFO_8BIT(infol), D_FIELDINFO_8BIT(infor));
        UInt p, newq;
        UInt i;
        p = P_FIELDINFO_8BIT(infol);
        assert(p == P_FIELDINFO_8BIT(infor));
        newq = 1;
        for (i = 0; i < newd; i++)
            newq *= p;
        /* if the exponent is bigger than 31, overflow changes the value to 0 */
        if (newd > 8 || newq > 256 ||
        (ql != newq && True == CALL_1ARGS(IsLockedRepresentationVector, vl)) ||
        (qr != newq && True == CALL_1ARGS(IsLockedRepresentationVector, vr))) {
            diff = DiffListList(vl, vr);
            CALL_1ARGS(ConvertToVectorRep, diff);
            return diff;
        } else {
            RewriteVec8Bit(vl, newq);
            RewriteVec8Bit(vr, newq);
        }
    }

    /* Finally the main line */
    return DiffVec8BitVec8Bit(vl, vr);
}

/****************************************************************************
**
*F  CmpVec8BitVec8Bit( <vl>, <vr> ) .. comparison, returns -1, 0 or 1
**
**  characteristic and field should have been checked outside, but we must
**  deal with length variations
*/

Int CmpVec8BitVec8Bit( Obj vl, Obj vr )
{
    Obj info;
    UInt q;
    UInt lenl;
    UInt lenr;
    UInt1 *ptrL;
    UInt1 *ptrR;
    UInt1 *endL;
    UInt1 *endR;
    UInt elts;
    UInt vall, valr;
    UInt e;
    UInt1 *gettab;
    Obj *ffe_elt;
    UInt len;
    assert(FIELD_VEC8BIT(vl) == FIELD_VEC8BIT(vr));
    q = FIELD_VEC8BIT(vl);
    info = GetFieldInfo8Bit(q);
    lenl = LEN_VEC8BIT(vl);
    lenr = LEN_VEC8BIT(vr);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    ptrL = BYTES_VEC8BIT(vl);
    ptrR = BYTES_VEC8BIT(vr);

    /* we stop a little short, so as to handle the final byte
       separately */
    endL = ptrL + lenl / elts;
    endR = ptrR + lenr / elts;
    gettab = GETELT_FIELDINFO_8BIT(info);
    ffe_elt = FFE_FELT_FIELDINFO_8BIT(info);
    while (ptrL < endL && ptrR < endR) {
        if (*ptrL == *ptrR) {
            ptrL++;
            ptrR++;
        } else {
            for (e = 0; e < elts; e++) {
                vall = gettab[*ptrL + 256 * e];
                valr = gettab[*ptrR + 256 * e];
                if (vall != valr) {
                    if (LT(ffe_elt[vall], ffe_elt[valr]))
                        return -1;
                    else
                        return 1;
                }
            }
            ErrorQuit("panic: bytes differed but all entries the same",
                      0L, 0L);
        }
    }
    /* now the final byte */

    /* a quick and easy case */
    if (lenl == lenr && *ptrL == *ptrR)
        return 0;

    /* the more general case */
    if (lenl < lenr)
        len = lenl;
    else
        len = lenr;

    /* look first at the shared part */
    for (e = 0; e < (len % elts); e++) {
        vall = gettab[*ptrL + 256 * e];
        valr = gettab[*ptrR + 256 * e];
        if (vall != valr) {
            if (LT(ffe_elt[vall], ffe_elt[valr]))
                return -1;
            else
                return 1;
        }
    }
    /* if that didn't decide then the longer list is bigger */
    if (lenr > lenl)
        return -1;
    else if (lenr == lenl)
        return 0;
    else
        return 1;
}

/****************************************************************************
**
*F  ScalarProductVec8Bits( <vl>, <vr> ) scalar product of vectors
**
**  Assumes that length and field match
**
*/

Obj ScalarProductVec8Bits( Obj vl, Obj vr )
{
    Obj info;
    UInt1 acc;
    UInt1 *ptrL;
    UInt1 *ptrR;
    UInt1 *endL;
    UInt len;
    UInt q;
    UInt elts;
    UInt1 contrib;
    UInt1 *inntab;
    UInt1 *addtab;
    len = LEN_VEC8BIT(vl);
    if (len > LEN_VEC8BIT(vr))
        len = LEN_VEC8BIT(vr);
    q = FIELD_VEC8BIT(vl);
    assert(q == FIELD_VEC8BIT(vr));
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);

    ptrL = BYTES_VEC8BIT(vl);
    ptrR = BYTES_VEC8BIT(vr);
    endL = ptrL + (len + elts - 1) / elts;
    acc = 0;
    inntab = INNER_FIELDINFO_8BIT(info);
    if (P_FIELDINFO_8BIT(info) == 2) {
        while (ptrL < endL) {
            contrib = inntab [*ptrL++ + 256 * *ptrR++];
            acc ^= contrib;
        }
    } else {
        addtab = ADD_FIELDINFO_8BIT(info);
        while (ptrL < endL) {
            contrib = inntab [*ptrL++ + 256 * *ptrR++];
            acc = addtab[256 * acc + contrib];
        }

    }
    return FFE_FELT_FIELDINFO_8BIT(info)[GETELT_FIELDINFO_8BIT(info)[acc]];

}

/****************************************************************************
**
*F  FuncPROD_VEC8BIT_VEC8BIT( <self>, <vl>, <vr> )
*/

Obj FuncPROD_VEC8BIT_VEC8BIT( Obj self, Obj vl, Obj vr )
{
    if (FIELD_VEC8BIT(vl) != FIELD_VEC8BIT(vr))
        return ProdListList(vl, vr);

    return ScalarProductVec8Bits(vl, vr);
}

/****************************************************************************
**
*F  UInt DistanceVec8Bits( <vl>, <vr> ) Hamming distance
**
**  Assumes that length and field match
**
*/

UInt DistanceVec8Bits( Obj vl, Obj vr )
{
    Obj info;
    UInt1 *ptrL;
    UInt1 *ptrR;
    UInt1 *endL;
    UInt len;
    UInt q;
    UInt elts;
    UInt acc;
    UInt i;
    UInt1 *gettab;

    len = LEN_VEC8BIT(vl);
    q = FIELD_VEC8BIT(vl);
    assert(q == FIELD_VEC8BIT(vr));
    assert(len == LEN_VEC8BIT(vr));
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);

    ptrL = BYTES_VEC8BIT(vl);
    ptrR = BYTES_VEC8BIT(vr);
    endL = ptrL + (len + elts - 1) / elts;

    acc = 0;
    gettab = GETELT_FIELDINFO_8BIT(info);

    while (ptrL < endL) {
        if (*ptrL != *ptrR) {
            for (i = 0; i < elts; i++)
                if (gettab[*ptrL + 256 * i] != gettab[*ptrR + 256 * i])
                    acc++;
        }
        ptrL++;
        ptrR++;
    }
    return acc;
}

/****************************************************************************
**
*F  FuncDISTANCE_VEC8BIT_VEC8BIT( <self>, <vl>, <vr> )
*/

Obj FuncDISTANCE_VEC8BIT_VEC8BIT( Obj self, Obj vl, Obj vr )
{
    if (FIELD_VEC8BIT(vl) != FIELD_VEC8BIT(vr) ||
    LEN_VEC8BIT(vl) != LEN_VEC8BIT(vr))
        return TRY_NEXT_METHOD;

    return INTOBJ_INT(DistanceVec8Bits(vl, vr));
}



/****************************************************************************
**
*F  DistDistrib8Bits( <veclis>, <ovec>, <d>, <osum>, <pos>, <l>, <m>)
**
*/
void DistDistrib8Bits(
  Obj   veclis, /* pointers to matrix vectors and their multiples */
  Obj           vec,    /* vector we compute distance to */
  Obj   d,  /* distances list */
  Obj           sum,  /* position of the sum vector */
  UInt    pos,  /* recursion depth */
  UInt    l /* length of basis */
  ) 
{
    UInt    i;
    UInt    di;
    Obj   cnt;
    Obj   vp;
    Obj           one;
    Obj           tmp;
    UInt          len;
    UInt          q;

    vp = ELM_PLIST(veclis, pos);
    one = INTOBJ_INT(1);

    len = LEN_VEC8BIT(sum);
    q = FIELD_VEC8BIT(sum);
    for (i = 0; i < q; i++) {
        if (pos < l) {
            DistDistrib8Bits(veclis, vec, d, sum, pos + 1, l);
        } else {
            di = DistanceVec8Bits(sum, vec);
            cnt = ELM_PLIST(d, di + 1);
            if (IS_INTOBJ(cnt) && SUM_INTOBJS(tmp, cnt, one)) {
                cnt = tmp;
                SET_ELM_PLIST(d, di + 1, cnt);
            } else {
                cnt = SumInt(cnt, one);
                SET_ELM_PLIST(d, di + 1, cnt);
                CHANGED_BAG(d);
            }
        }
        AddVec8BitVec8BitInner(sum, sum, ELM_PLIST(vp, i + 1), 1, len);
    }
    TakeInterrupt();
}

Obj FuncDISTANCE_DISTRIB_VEC8BITS(
  Obj   self,
  Obj   veclis, /* pointers to matrix vectors and their multiples */
  Obj   vec,    /* vector we compute distance to */
  Obj   d ) /* distances list */

{
    Obj   sum; /* sum vector */
    UInt    len;
    UInt           q;

    len = LEN_VEC8BIT(vec);
    q = FIELD_VEC8BIT(vec);

    /* get space for sum vector and zero out */
    sum = ZeroVec8Bit(q, len, 0);
    /* do the recursive work */
    DistDistrib8Bits(veclis, vec, d, sum, 1, LEN_PLIST(veclis));

    return (Obj) 0;
}

/****************************************************************************
**
*F
*/

void OverwriteVec8Bit( Obj dst, Obj src)
{
    UInt1 *ptrS;
    UInt1 *ptrD;
    UInt size;
    UInt n;
    size = SIZE_BAG(src);
    ptrS = BYTES_VEC8BIT(src);
    ptrD = BYTES_VEC8BIT(dst);
    for (n = 3 * sizeof(UInt); n < size; n++)
        *ptrD++ = *ptrS++;
}

UInt AClosVec8Bit( 
      Obj   veclis, /* pointers to matrix vectors and their multiples */
      Obj           vec,    /* vector we compute distance to */
      Obj           sum,  /* position of the sum vector */
      UInt    pos,  /* recursion depth */
      UInt    l,  /* length of basis */
      UInt    cnt,  /* number of vectors used already */
      UInt    stop, /* stop value */
      UInt    bd, /* best distance so far */
      Obj   bv, /* best vector so far */
      Obj           coords,
      Obj           bcoords
      )
{
    UInt    i, j;
    UInt    di;
    Obj   vp;
    UInt q;
    UInt len;

    /* This is the case where we do not add any multiple of
       the current basis vector */
    if (pos + cnt < l) {
        bd = AClosVec8Bit(veclis, vec, sum, pos + 1, l, cnt, stop, bd, bv, coords, bcoords);
        if (bd <= stop) {
            return bd;
        }
    }
    q = FIELD_VEC8BIT(vec);
    len = LEN_VEC8BIT(vec);
    vp = ELM_PLIST(veclis, pos);

    /* we need to add each scalar multiple and recurse */
    for (i = 1; i <  q ; i++) {
        AddVec8BitVec8BitInner(sum, sum, ELM_PLIST(vp, i), 1, len);
        if (coords)
            SET_ELM_PLIST(coords, pos, INTOBJ_INT(i));
        if (cnt == 0) {
            /* do we have a new best case */
            di = DistanceVec8Bits(sum, vec);
            if (di < bd) {
                bd = di;
                OverwriteVec8Bit(bv, sum);
                if (coords)
                    for (j = 1; j <= l; j++) {
                        Obj x;
                        x = ELM_PLIST(coords, j);
                        SET_ELM_PLIST(bcoords, j, x);
                    }
                if (bd <= stop)
                    return bd;
            }
        } else if (pos < l) {
            bd = AClosVec8Bit(veclis, vec, sum, pos + 1, l, cnt - 1, stop, bd, bv, coords, bcoords);
            if (bd <= stop) {
                return bd;
            }
        }
    }
    /* reset component */
    AddVec8BitVec8BitInner(sum, sum, ELM_PLIST(vp, q), 1, len);
    if (coords)
        SET_ELM_PLIST(coords, pos, INTOBJ_INT(0));

    TakeInterrupt();
    return bd;
}

/****************************************************************************
**
*F  
*/

Obj FuncAClosVec8Bits( 
          Obj   self,
          Obj   veclis, /* pointers to matrix vectors and their multiples */
          Obj   vec,    /* vector we compute distance to */
          Obj   cnt,  /* distances list */
          Obj   stop) /* distances list */
{
    Obj   sum; /* sum vector */
    Obj   best; /* best vector */
    UInt  len;
    UInt q;

    if (!ARE_INTOBJS(cnt, stop))
        ErrorQuit("A_CLOSEST_VEC8BIT: cnt and stop must be small integers, not a %s and a %s",
                  (Int)TNAM_OBJ(cnt), (Int)TNAM_OBJ(stop));


    q = FIELD_VEC8BIT(vec);
    len = LEN_VEC8BIT(vec);

    /* get space for sum vector and zero out */

    sum = ZeroVec8Bit(q, len, 1);
    best = ZeroVec8Bit(q, len, 1);

    /* do the recursive work */
    AClosVec8Bit(veclis, vec, sum, 1, LEN_PLIST(veclis),
                 INT_INTOBJ(cnt), INT_INTOBJ(stop), len + 1, /* maximal value +1 */
                 best, (Obj)0, (Obj)0);

    return best;
}

/****************************************************************************
**
*F  
*/

Obj FuncAClosVec8BitsCoords( 
          Obj   self,
          Obj   veclis, /* pointers to matrix vectors and their multiples */
          Obj   vec,    /* vector we compute distance to */
          Obj   cnt,  /* distances list */
          Obj   stop) /* distances list */    
{
    Obj   sum; /* sum vector */
    Obj   best; /* best vector */
    UInt    len, len2, i;
    UInt q;
    Obj coords;
    Obj bcoords;
    Obj res;

    if (!ARE_INTOBJS(cnt, stop))
        ErrorQuit("A_CLOSEST_VEC8BIT: cnt and stop must be small integers, not a %s and a %s",
        (Int)TNAM_OBJ(cnt), (Int)TNAM_OBJ(stop));


    q = FIELD_VEC8BIT(vec);
    len = LEN_VEC8BIT(vec);

    /* get space for sum vector and zero out */

    sum = ZeroVec8Bit(q, len, 1);
    best = ZeroVec8Bit(q, len, 1);
    len2 = LEN_PLIST(veclis);
    coords = NEW_PLIST(T_PLIST_CYC, len2);
    bcoords = NEW_PLIST(T_PLIST_CYC, len2);
    SET_LEN_PLIST(coords, len2);
    SET_LEN_PLIST(bcoords, len2);
    for (i = 1; i <= len2; i++) {
        SET_ELM_PLIST(coords, i, INTOBJ_INT(0));
        SET_ELM_PLIST(bcoords, i, INTOBJ_INT(0));
    }

    /* do the recursive work */
    AClosVec8Bit(veclis, vec, sum, 1, LEN_PLIST(veclis),
    INT_INTOBJ(cnt), INT_INTOBJ(stop), len + 1, /* maximal value +1 */
    best, coords, bcoords);

    res = NEW_PLIST(T_PLIST_DENSE_NHOM, 2);
    SET_LEN_PLIST(res, 2);
    SET_ELM_PLIST(res, 1, best);
    SET_ELM_PLIST(res, 2, bcoords);
    CHANGED_BAG(res);
    return res;
}


/****************************************************************************
**
*F  FuncNUMBER_VEC8BIT( <self>, <vec> )
**
*/

Obj FuncNUMBER_VEC8BIT (Obj self, Obj vec)
{
    Obj     info;
    UInt    elts;
    UInt    len;
    UInt    i;
    Obj     elt;
    UInt1   *gettab;
    UInt1   *ptrS;
    Obj     *convtab;

    Obj     res;
    Obj     f;

    info = GetFieldInfo8Bit(FIELD_VEC8BIT(vec));
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    gettab = GETELT_FIELDINFO_8BIT(info);
    convtab = GAPSEQ_FELT_FIELDINFO_8BIT(info);
    ptrS = BYTES_VEC8BIT(vec);
    len = LEN_VEC8BIT(vec);
    res = INTOBJ_INT(0);
    f = INTOBJ_INT(FIELD_VEC8BIT(vec)); /* Field size as GAP integer */

    for (i = 0; i < len; i++) {
        elt = convtab[gettab[ptrS[i / elts] + 256 * (i % elts)]];
        res = ProdInt(res, f); /* ``shift'' */
        res = SumInt(res, elt);
        if (!IS_INTOBJ(res)) {
            /* a garbage collection might have moved the pointers */
            gettab = GETELT_FIELDINFO_8BIT(info);
            convtab = GAPSEQ_FELT_FIELDINFO_8BIT(info);
            ptrS = BYTES_VEC8BIT(vec);
        }
    }

    return res;
}

/****************************************************************************
**
*F FuncCOSET_LEADERS_INNER_8BITS( <self>, <veclis>, <weight>, <tofind>, <leaders> )
**
** Search for new coset leaders of weight <weight>
*/

UInt CosetLeadersInner8Bits( Obj veclis,
         Obj v,
         Obj w,
         UInt weight,
         UInt pos,
         Obj leaders,
         UInt tofind,
         Obj felts)
{
    UInt found = 0;
    UInt len = LEN_VEC8BIT(v);
    UInt lenw = LEN_VEC8BIT(w);
    UInt sy;
    Obj u;
    Obj vc;
    UInt i, j;
    UInt q;
    Obj info;
    UInt1 *settab;
    UInt elts;
    UInt1 *ptr, *ptrw;
    UInt1 *gettab;
    UInt1 *feltffe;
    Obj x;
    Obj vp;

    q = FIELD_VEC8BIT(v);
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    settab = SETELT_FIELDINFO_8BIT(info);
    gettab = GETELT_FIELDINFO_8BIT(info);
    ptrw = BYTES_VEC8BIT(w);
    if (weight == 1) {
        for (i = pos; i <= len; i++) {
            vp = ELM_PLIST(veclis, i);
            u = ELM_PLIST(vp, 1);
            AddVec8BitVec8BitInner(w, w, u, 1, lenw);
            ptr = BYTES_VEC8BIT(v) + (i - 1) / elts;
            *ptr = settab[*ptr + 256 * (elts + ((i - 1) % elts))];
            sy = 0;
            for (j = 0; j < lenw; j++) {
                UInt xxxx;
                sy *= q;
                xxxx = gettab[ptrw[j / elts] + 256 * (j % elts)];
                sy += xxxx;
            }
            if ((Obj) 0 == ELM_PLIST(leaders, sy + 1)) {
                UInt k;
                Obj qk;
                Obj wc;
                vc = CopyVec8Bit(v, 0);
                SET_ELM_PLIST(leaders, sy + 1, vc);
                CHANGED_BAG(leaders);
                /* Also record all the multiples here */
                wc = ZeroVec8Bit(q, lenw, 1);
                settab = SETELT_FIELDINFO_8BIT(info);
                gettab = GETELT_FIELDINFO_8BIT(info);
                ptr = BYTES_VEC8BIT(v) + (i - 1) / elts;
                ptrw = BYTES_VEC8BIT(w);
                for (k = 2; k < q; k++) {
                    qk = FFE_FELT_FIELDINFO_8BIT(info)[k];
                    MultVec8BitFFEInner(wc, w, qk, 1, lenw);
                    ptrw = BYTES_VEC8BIT(wc);
                    sy = 0;
                    for (j = 0; j < lenw; j++) {
                        UInt xxxx;
                        sy *= q;
                        xxxx = gettab[ptrw[j / elts] + 256 * (j % elts)];
                        sy += xxxx;
                    }
                    vc = ZeroVec8Bit(q, len, 0);
                    settab = SETELT_FIELDINFO_8BIT(info);
                    gettab = GETELT_FIELDINFO_8BIT(info);
                    ptr = BYTES_VEC8BIT(v) + (i - 1) / elts;
                    ptrw = BYTES_VEC8BIT(w);
                    MultVec8BitFFEInner(vc, v, qk, 1, len);
                    SET_ELM_PLIST(leaders, sy + 1, vc);
                    CHANGED_BAG(leaders);
                }
                found += (q - 1);
                if (found == tofind)
                    return found;
            }
            u = ELM_PLIST(vp, q + 1);
            AddVec8BitVec8BitInner(w, w, u, 1, lenw);
            *ptr = settab[*ptr + 256 * ((i - 1) % elts)];
        }
    } else {
        if (pos + weight <= len) {
            found += CosetLeadersInner8Bits(veclis, v, w, weight, pos + 1, leaders, tofind, felts);
            if (found == tofind)
                return found;
        }

        settab = SETELT_FIELDINFO_8BIT(info);
        feltffe = FELT_FFE_FIELDINFO_8BIT(info);
        vp = ELM_PLIST(veclis, pos);
        for (i = 1; i < q; i++) {
            u = ELM_PLIST(vp, i);
            AddVec8BitVec8BitInner(w, w, u, 1, lenw);
            ptr = BYTES_VEC8BIT(v) + (pos - 1) / elts;
            x = ELM_PLIST(felts, i + 1);
            *ptr = settab[*ptr + 256 * (elts * feltffe[VAL_FFE(x)] + ((pos - 1) % elts))];
            found += CosetLeadersInner8Bits(veclis, v, w, weight - 1, pos + 1, leaders, tofind - found, felts);
            if (found == tofind)
                return found;
        }
        settab = SETELT_FIELDINFO_8BIT(info);
        feltffe = FELT_FFE_FIELDINFO_8BIT(info);
        u = ELM_PLIST(vp, q);
        AddVec8BitVec8BitInner(w, w, u, 1, lenw);

        ptr = BYTES_VEC8BIT(v) + (pos - 1) / elts;
        *ptr = settab[*ptr + 256 * ((pos - 1) % elts)];

    }
    TakeInterrupt();
    return found;
}




Obj FuncCOSET_LEADERS_INNER_8BITS( Obj self, Obj veclis, Obj weight, Obj tofind, Obj leaders, Obj felts)
{
    Obj v, w;
    UInt lenv, lenw, q;
    if (!ARE_INTOBJS(weight, tofind))
        ErrorQuit("COSET_LEADERS_INNER_8BITS: weight and tofind must be small integers, not a %s and a %s",
        (Int)TNAM_OBJ(weight), (Int)TNAM_OBJ(tofind));
    lenv = LEN_PLIST(veclis);
    q = LEN_PLIST(felts);
    v = ZeroVec8Bit(q, lenv, 1);
    lenw = LEN_VEC8BIT(ELM_PLIST(ELM_PLIST(veclis, 1), 1));
    w = ZeroVec8Bit(q, lenw, 1);
    return INTOBJ_INT(CosetLeadersInner8Bits(veclis, v, w, INT_INTOBJ(weight), 1, leaders, INT_INTOBJ(tofind), felts));
}


/****************************************************************************
**
*F  FuncEQ_VEC8BIT_VEC8BIT( <self>, <vl>, <vr> )
**
*/

Obj FuncEQ_VEC8BIT_VEC8BIT( Obj self, Obj vl, Obj vr )
{
    if (FIELD_VEC8BIT(vl) != FIELD_VEC8BIT(vr))
        return EqListList(vl, vr) ? True : False;

    if (LEN_VEC8BIT(vl) != LEN_VEC8BIT(vr))
        return False;

    return (CmpVec8BitVec8Bit(vl, vr) == 0) ? True : False;
}

/****************************************************************************
**
*F  FuncLT_VEC8BIT_VEC8BIT( <self>, <vl>, <vr> )
**
*/

Obj FuncLT_VEC8BIT_VEC8BIT( Obj self, Obj vl, Obj vr )
{
    if (FIELD_VEC8BIT(vl) != FIELD_VEC8BIT(vr))
        return LtListList(vl, vr) ? True : False;

    return (CmpVec8BitVec8Bit(vl, vr) == -1) ? True : False;
}

/****************************************************************************
**
*F * * * * * * * * * * * * list access functions  * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FuncSHALLOWCOPY_VEC8BIT( <self>, <list> ) . shallowcopy method
**
*/


Obj FuncSHALLOWCOPY_VEC8BIT( Obj self, Obj list )
{
    return CopyVec8Bit(list, 1);
}


/****************************************************************************
**
*F  FuncLEN_VEC8BIT( <self>, <list> )  . . . . . . . .  length of a vector
*/
Obj FuncLEN_VEC8BIT (
    Obj                 self,
    Obj                 list )
{
    return INTOBJ_INT(LEN_VEC8BIT(list));
}

/****************************************************************************
**
*F  FuncQ_VEC8BIT( <self>, <list> )  . . . . . . . .  length of a vector
*/
Obj FuncQ_VEC8BIT (
    Obj                 self,
    Obj                 list )
{
    return INTOBJ_INT(FIELD_VEC8BIT(list));
}


/****************************************************************************
**
*F  FuncELM0_VEC8BIT( <self>, <list>, <pos> )  . select an elm of an 8bit vector
**
**  'ELM0_VEC8BIT'  returns the element at the  position  <pos> of the boolean
**  list <list>, or `Fail' if <list> has no assigned  object at <pos>.  It is
**  the  responsibility of  the caller to   ensure  that <pos> is  a positive
**  integer.
*/

Obj FuncELM0_VEC8BIT (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    UInt                p;
    Obj     info;
    UInt elts;

    if (!IS_INTOBJ(pos))
        ErrorQuit("ELM0_VEC8BIT: position must be a small integer, not a %s",
                  (Int)TNAM_OBJ(pos), 0L);
    p = INT_INTOBJ(pos);
    if (LEN_VEC8BIT(list) < p) {
        return Fail;
    } else {
        info = GetFieldInfo8Bit(FIELD_VEC8BIT(list));
        elts = ELS_BYTE_FIELDINFO_8BIT(info);
        return FFE_FELT_FIELDINFO_8BIT(info)[
                GETELT_FIELDINFO_8BIT(info)[BYTES_VEC8BIT(list)[(p - 1) / elts] +
                256 * ((p - 1) % elts)]];
    }
}


/****************************************************************************
**
*F  FuncELM_VEC8BIT( <self>, <list>, <pos> ) . . select an elm of a GF2 vector
**
**  'ELM_VEC8BIT' returns the element at the position <pos>  of the GF2 vector
**  <list>.   An  error  is signalled  if  <pos>  is  not bound.    It is the
**  responsibility of the caller to ensure that <pos> is a positive integer.
*/
Obj FuncELM_VEC8BIT (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    UInt                p;
    Obj     info;
    UInt elts;

    if (!IS_INTOBJ(pos))
        ErrorQuit("ELM0_VEC8BIT: position must be a small integer, not a %s",
                  (Int)TNAM_OBJ(pos), 0L);
    p = INT_INTOBJ(pos);
    if (LEN_VEC8BIT(list) < p) {
        ErrorReturnVoid(
            "List Element: <list>[%d] must have an assigned value",
            p, 0L, "you can 'return;' after assigning a value");
        return ELM_LIST(list, p);
    } else {
        info = GetFieldInfo8Bit(FIELD_VEC8BIT(list));
        elts = ELS_BYTE_FIELDINFO_8BIT(info);
        return FFE_FELT_FIELDINFO_8BIT(info)[
                GETELT_FIELDINFO_8BIT(info)[BYTES_VEC8BIT(list)[(p - 1) / elts] +
                256 * ((p - 1) % elts)]];

    }
}


/****************************************************************************
**
*F  FuncELMS_VEC8BIT( <self>, <list>, <poss> ) . select elms of an 8 bit vector
**
**  The results are returned in the compressed format
*/
Obj FuncELMS_VEC8BIT (
    Obj                 self,
    Obj                 list,
    Obj                 poss )
{
    UInt                p;
    Obj                 pos;
    Obj     info;
    UInt                elts;
    UInt                len;
    Obj                 res;
    UInt                i;
    UInt                elt;
    UInt1               *gettab;
    UInt1               *settab;
    UInt1               *ptrS;
    UInt1               *ptrD;
    UInt                 e;
    UInt1                byte;
    UInt                 len2;

    len = LEN_PLIST(poss);
    info = GetFieldInfo8Bit(FIELD_VEC8BIT(list));
    len2 = LEN_VEC8BIT(list);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    res = NewBag(T_DATOBJ, SIZE_VEC8BIT(len, elts));
    SetTypeDatObj(res, TYPE_DATOBJ(list));
    SET_FIELD_VEC8BIT(res, FIELD_VEC8BIT(list));
    SET_LEN_VEC8BIT(res, len);
    gettab = GETELT_FIELDINFO_8BIT(info);
    settab = SETELT_FIELDINFO_8BIT(info);
    ptrS = BYTES_VEC8BIT(list);
    ptrD = BYTES_VEC8BIT(res);
    e = 0;
    byte = 0;
    for (i = 1; i <= len; i++) {
        pos = ELM_PLIST(poss, i);
        if (!IS_INTOBJ(pos))
            ErrorQuit("ELMS_VEC8BIT: positions list includes a %s, should all be small integers",
                      (Int)TNAM_OBJ(pos), 0L);
        if (pos <= INTOBJ_INT(0))
            ErrorQuit("ELMS_VEC8BIT: positions list includes a non-positive number", 0L, 0L);
        p = INT_INTOBJ(pos);
        if (p > len2)
            ErrorQuit("ELMS_VEC8BIT: positions list includes index %d in a list of length %d",
                      (Int)p, (Int)len2);
        elt = gettab[ptrS[(p - 1) / elts] + 256 * ((p - 1) % elts)];
        byte = settab[ byte + 256 * (e + elts * elt)];
        e++;
        if (e == elts) {
            *ptrD++ = byte;
            e = 0;
            byte = 0;
        }
    }
    if (e)
        *ptrD = byte;

    return res;
}



/****************************************************************************
**
*F  FuncELMS_VEC8BIT_RANGE( <self>, <list>, <range> ) .
**                                         select elms of an 8 bit vector
**
**  The results are returned in the compressed format
*/
Obj FuncELMS_VEC8BIT_RANGE (
    Obj                 self,
    Obj                 list,
    Obj                 range  )
{
    UInt                p;
    Obj     info;
    UInt                elts;
    UInt                len;
    UInt                lenl;
    UInt                low;
    Int                inc;
    Obj                 res;
    UInt                i;
    UInt                elt;
    UInt1               *gettab;
    UInt1               *settab;
    UInt1               *ptrS;
    UInt1               *ptrD;
    UInt                 e;
    UInt1                byte;

    info = GetFieldInfo8Bit(FIELD_VEC8BIT(list));
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    len = GET_LEN_RANGE(range);
    low = GET_LOW_RANGE(range);
    inc = GET_INC_RANGE(range);
    lenl = LEN_VEC8BIT(list);
    if (inc < 0) {
        if (low > lenl || low + inc * (len - 1) < 1)
            ErrorQuit("ELMS_VEC8BIT_RANGE: Range includes indices which are too high or too low",
                      0L, 0L);
    } else if (low < 1 || low + inc * (len - 1) > lenl)
        ErrorQuit("ELMS_VEC8BIT_RANGE: Range includes indices which are too high or too low",
                  0L, 0L);
    res = NewBag(T_DATOBJ, SIZE_VEC8BIT(len, elts));
    SetTypeDatObj(res, TYPE_DATOBJ(list));
    SET_FIELD_VEC8BIT(res, FIELD_VEC8BIT(list));
    SET_LEN_VEC8BIT(res, len);
    gettab = GETELT_FIELDINFO_8BIT(info);
    settab = SETELT_FIELDINFO_8BIT(info);
    ptrS = BYTES_VEC8BIT(list);
    ptrD = BYTES_VEC8BIT(res);
    e = 0;
    byte = 0;
    p = low - 1;    /* the -1 converts to 0 base */
    if (p % elts == 0 && inc == 1 && len >= elts) {
        while (p < low + len - elts) {
            *ptrD++ = ptrS[p / elts];
            p += elts;
        }
        byte = 0;
        e = 0;
        if (p < low + len - 1) {
            while (p < low + len - 1) {
                elt = gettab[ptrS[p / elts] + 256 * (p % elts)];
                byte = settab[ byte + 256 * (e + elts * elt)];
                e++;
                p++;
            }
            *ptrD = byte;
        }
    } else {
        for (i = 1; i <= len; i++) {
            elt = gettab[ptrS[p / elts] + 256 * (p % elts)];
            byte = settab[ byte + 256 * (e + elts * elt)];
            e++;
            if (e == elts) {
                *ptrD++ = byte;
                e = 0;
                byte = 0;
            }
            p += inc;
        }
        if (e)
            *ptrD = byte;
    }

    return res;
}




/****************************************************************************
**
*F  FuncASS_VEC8BIT( <self>, <list>, <pos>, <elm> ) set an elm of a GF2 vector
**
**  'ASS_VEC8BIT' assigns the element  <elm> at the position  <pos> to the GF2
**  vector <list>.
**
**  It is the responsibility of the caller  to ensure that <pos> is positive,
**  and that <elm> is not 0.
*/

static Obj AsInternalFFE;

Obj FuncASS_VEC8BIT (
		     Obj                 self,
		     Obj                 list,
		     Obj                 pos,
		     Obj                 elm )
{
    UInt                p;
    Obj                 info;
    UInt                elts;
    UInt                chr;
    UInt                d;
    UInt                q;
    FF                  f;
    UInt v;
    Obj newelm;

    /* check that <list> is mutable                                        */
    if (! IS_MUTABLE_OBJ(list)) {
        ErrorReturnVoid(
            "Lists Assignment: <list> must be a mutable list",
            0L, 0L,
            "you can 'return;' and ignore the assignment");
        return 0;
    }

    /* get the position                                                    */
    if (!IS_INTOBJ(pos))
        ErrorQuit("ASS_VEC8BIT: position should be a small integer, not a %s",
                  (Int)TNAM_OBJ(pos), 0L);
    p = INT_INTOBJ(pos);
    if (p <= 0)
        ErrorQuit("ASS_VEC8BIT: position must be positive", 0L, 0L);
    info = GetFieldInfo8Bit(FIELD_VEC8BIT(list));
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    chr = P_FIELDINFO_8BIT(info);
    d = D_FIELDINFO_8BIT(info);
    q = Q_FIELDINFO_8BIT(info);


    if (p <= LEN_VEC8BIT(list) + 1) {
        if (LEN_VEC8BIT(list) + 1 == p) {
            if (True == DoFilter(IsLockedRepresentationVector, list)) {
                ErrorReturnVoid("List assignment would increase length of locked compressed vector", 0, 0,
                                "You can `return;' to ignore the assignment");
                return 0;
            }
            ResizeBag(list, SIZE_VEC8BIT(p, elts));
            SET_LEN_VEC8BIT(list, p);
            /*  Pr("Extending 8 bit vector by 1",0,0); */
        }
        if (!IS_FFE(elm)) {
            newelm = DoAttribute(AsInternalFFE, elm);
            if (newelm != Fail)
                elm = newelm;
        }
        if (IS_FFE(elm) && chr == CharFFE(elm)) {

            /* We may need to rewrite the vector over a larger field */
            if (d % DegreeFFE(elm) !=  0) {
                /*        Pr("Rewriting over larger field",0,0);*/
                f = CommonFF(FiniteField(chr, d), d,
                             FLD_FFE(elm), DegreeFFE(elm));
                if (f && SIZE_FF(f) <= 256) {
                    RewriteVec8Bit(list, SIZE_FF(f));
                    info = GetFieldInfo8Bit(FIELD_VEC8BIT(list));
                    elts = ELS_BYTE_FIELDINFO_8BIT(info);
                    chr = P_FIELDINFO_8BIT(info);
                    d = D_FIELDINFO_8BIT(info);
                    q = Q_FIELDINFO_8BIT(info);
                } else {
                    PlainVec8Bit(list);
                    AssPlistFfe(list, p, elm);
                    return 0;
                }
            }


            v = VAL_FFE(elm);

            /* may need to promote the element to a bigger field
               or restrict it to a smaller one */
            if (v != 0 && q != SIZE_FF(FLD_FFE(elm))) {
                assert(((v - 1) * (q - 1)) % (SIZE_FF(FLD_FFE(elm)) - 1) == 0);
                v = 1 + (v - 1) * (q - 1) / (SIZE_FF(FLD_FFE(elm)) - 1);
            }

            /* finally do the assignment */
            BYTES_VEC8BIT(list)[(p - 1) / elts] =
                SETELT_FIELDINFO_8BIT(info)
                [256 * (elts * FELT_FFE_FIELDINFO_8BIT(info)[v] + (p - 1) % elts) +
                 BYTES_VEC8BIT(list)[(p - 1) / elts]];
            return 0;
        }
    }

    /* We fall through here if the assignment position is so large
       as to leave a hole, or if the object to be assigned is
       not of the right characteristic, or would create too large a field */

    /*     Pr("Random assignment (8 bit)",0,0);*/

    PlainVec8Bit(list);
    AssPlistFfe(list, p, elm);
    return 0;
}



/****************************************************************************
**
*F  FuncUNB_VEC8BIT( <self>, <list>, <pos> ) . unbind position of a GFQ vector
**
**  'UNB_VEC8BIT' unbind  the element at  the position  <pos> in  a GFQ vector
**  <list>.
**
**  It is the responsibility of the caller  to ensure that <pos> is positive.
*/
Obj FuncUNB_VEC8BIT (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    UInt                p;
    Obj                 info;
    UInt elts;

    /* check that <list> is mutable                                        */
    if (! IS_MUTABLE_OBJ(list)) {
        ErrorReturnVoid(
            "Lists Assignment: <list> must be a mutable list",
            0L, 0L,
            "you can 'return;' and ignore the assignment");
        return 0;
    }
    if (True == DoFilter(IsLockedRepresentationVector, list)) {
        ErrorReturnVoid("Unbind of entry of locked compressed vector is forbidden", 0, 0,
                        "You can `return;' to ignore the assignment");
        return 0;
    }

    /* get the position                                                    */
    if (!IS_INTOBJ(pos))
        ErrorQuit("UNB_VEC8BIT: position should be a small integer, not a %s",
        (Int)TNAM_OBJ(pos), 0L);
    p = INT_INTOBJ(pos);
    if (p <= 0)
        ErrorQuit("UNB_VEC8BIT: position must be positive", 0L, 0L);

    /* if we unbind the last position keep the representation              */
    if (LEN_VEC8BIT(list) < p) {
        ;
    } else if (/* p > 1 && */ LEN_VEC8BIT(list) == p) {
        /* zero out the last entry first, for safety */
        info = GetFieldInfo8Bit(FIELD_VEC8BIT(list));
        elts = ELS_BYTE_FIELDINFO_8BIT(info);
        BYTES_VEC8BIT(list)[(p - 1) / elts] =
        SETELT_FIELDINFO_8BIT(info)[((p - 1) % elts) * 256 +
        BYTES_VEC8BIT(list)[(p - 1) / elts]];
        ResizeBag(list, 3 * sizeof(UInt) + (p + elts - 2) / elts);
        SET_LEN_VEC8BIT(list, p - 1);
    } else {
        PlainVec8Bit(list);
        UNB_LIST(list, p);
    }
    return 0;
}

/****************************************************************************
**
*F  FuncPOSITION_NONZERO_VEC8BIT( <self>, <list>, <zero> ) .
**                               
**  The pointless zero argument is because this is a method for PositionNot
**  It is *not* used in the code and can be replaced by a dummy argument.
**
*/

UInt PositionNonZeroVec8Bit ( Obj list, UInt from )
{
    Obj  info;
    UInt len;
    UInt nb;
    UInt i, j;
    UInt elts;
    UInt1 *ptr;
    UInt1 byte;
    UInt1 *gettab;

    len = LEN_VEC8BIT(list);
    info = GetFieldInfo8Bit(FIELD_VEC8BIT(list));
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    gettab = GETELT_FIELDINFO_8BIT(info);
    nb = (len + elts - 1) / elts;
    ptr = BYTES_VEC8BIT(list);
    i = from / elts;
    j = from % elts;
    /* might be an initial part byte */
    if (j) {
        if (i < nb && ptr[i])
            for (j = from % elts; j < elts && (i * elts + j < len); j++)
                if (gettab[256 * j + ptr[i]] != 0)
                    return elts * i + j + 1;
        i++;
    }

    /* skip empty bytes */
    while (i < nb && !ptr[i])
        i++;

    if (i >= nb)
        return len + 1;

    /* Found a non-empty byte, locate the entry */
    byte = ptr[i];
    j = 0;
    while (gettab[byte + 256 * j] == 0)
        j++;
    return elts * i + j + 1;
}

          

Obj FuncPOSITION_NONZERO_VEC8BIT (
    Obj                 self,
    Obj                 list,
    Obj                 zero )
{
    return INTOBJ_INT(PositionNonZeroVec8Bit(list, 0));
}

Obj FuncPOSITION_NONZERO_VEC8BIT3 (
    Obj                 self,
    Obj                 list,
    Obj                 zero,
    Obj                 from)
{
    return INTOBJ_INT(PositionNonZeroVec8Bit(list, INT_INTOBJ(from)));
}

/****************************************************************************
**
*F  FuncAPPEND_VEC8BIT( <self>, <vecl>, <vecr> ) .
**                               
**
*/
Obj FuncAPPEND_VEC8BIT (
    Obj                 self,
    Obj                 vecl,
    Obj                 vecr )
{
    Obj                 info;
    UInt lenl, lenr;
    UInt nb;
    UInt i;
    UInt elts;
    UInt1 *ptrl, *ptrr;
    UInt1 bytel, byter, elt;
    UInt1 *gettab, *settab;
    UInt posl, posr;

    if (FIELD_VEC8BIT(vecl) != FIELD_VEC8BIT(vecr))
        return TRY_NEXT_METHOD;

    lenl = LEN_VEC8BIT(vecl);
    lenr = LEN_VEC8BIT(vecr);
    if (True == DoFilter(IsLockedRepresentationVector, vecl) && lenr > 0) {
        ErrorReturnVoid("Append to locked compressed vector is forbidden", 0, 0,
                        "You can `return;' to ignore the operation");
        return 0;
    }
    info = GetFieldInfo8Bit(FIELD_VEC8BIT(vecl));
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    ResizeBag(vecl, SIZE_VEC8BIT(lenl + lenr, elts));

    if (lenl % elts == 0) {
        ptrl = BYTES_VEC8BIT(vecl) + lenl / elts;
        ptrr = BYTES_VEC8BIT(vecr);
        nb = (lenr + elts - 1) / elts;
        for (i = 0; i < nb; i++)
            *ptrl++ = *ptrr++;
    } else {
        ptrl = BYTES_VEC8BIT(vecl) + (lenl - 1) / elts;
        bytel = *ptrl;
        posl = lenl;
        posr = 0;
        ptrr = BYTES_VEC8BIT(vecr);
        byter = *ptrr;
        gettab = GETELT_FIELDINFO_8BIT(info);
        settab = SETELT_FIELDINFO_8BIT(info);
        while (posr < lenr) {
            elt = gettab[ byter + 256 * (posr % elts) ];
            bytel = settab[ bytel + 256 * (posl % elts + elts * elt)];
            if (++posl % elts == 0) {
                *ptrl++ = bytel;
                bytel = 0;
            }
            if (++posr % elts == 0) {
                byter = *++ptrr;
            }
        }
        /* Write last byte only if not already written: */
        if (posl % elts != 0) *ptrl = bytel;
    }
    SET_LEN_VEC8BIT(vecl, lenl + lenr);
    return (Obj) 0;
}


/****************************************************************************
**
*F  FuncPROD_VEC8BIT_MATRIX( <self>, <vec>, <mat> )
**
**  Method selection should ensure that <mat> is a matrix of ffes in the
**  right characteristic. We aim to be fast in the case where it is
**  actually a plain list of vec8bits over the same field as <vec>. We also
**  know that <vec> and <mat> are non-empty
** */

Obj FuncPROD_VEC8BIT_MATRIX( Obj self, Obj vec, Obj mat)
{
    Obj res;
    Obj info;
    UInt q;
    UInt len, l2;
    UInt len1;
    Obj row1;
    UInt i;
    UInt elts;
    UInt1* gettab;
    Obj *ffefelt;
    Obj x;

    len = LEN_VEC8BIT(vec);
    l2 = LEN_PLIST(mat);
    q = FIELD_VEC8BIT(vec);

    /* Get the first row, to establish the size of the result */
    row1 = ELM_PLIST(mat, 1);
    if (! IS_VEC8BIT_REP(row1) || FIELD_VEC8BIT(row1) != q)
        return TRY_NEXT_METHOD;
    len1 = LEN_VEC8BIT(row1);

    /* create the result space */
    res = ZeroVec8Bit(q, len1, IS_MUTABLE_OBJ(vec) || IS_MUTABLE_OBJ(row1));

    /* Finally, we start work */
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    gettab = GETELT_FIELDINFO_8BIT(info);
    ffefelt = FFE_FELT_FIELDINFO_8BIT(info);

    for (i = 0; i < len; i++)
        if (i < l2) {
            x = ffefelt[gettab[BYTES_VEC8BIT(vec)[i / elts] + 256 * (i % elts)]];
            if (VAL_FFE(x) != 0) {
                row1 = ELM_PLIST(mat, i + 1);
                /* This may be unduly draconian. Later we may want to be able to promote the rows
                   to a bigger field */
                if ((! IS_VEC8BIT_REP(row1)) || (FIELD_VEC8BIT(row1) != q))
                    return TRY_NEXT_METHOD;
                AddVec8BitVec8BitMultInner(res, res, row1, x, 1, len1);
            }
        }
    return res;

}


/****************************************************************************
**
*F  * * * * * * *  special rep for matrices over these fields * * * * * * *
*/

#define LEN_MAT8BIT(mat)                   INT_INTOBJ(ADDR_OBJ(mat)[1])
#define SET_LEN_MAT8BIT(mat, l)            (ADDR_OBJ(mat)[1] = INTOBJ_INT(l))
#define ELM_MAT8BIT(mat, i)                ADDR_OBJ(mat)[i+1]
#define SET_ELM_MAT8BIT(mat, i, row)       (ADDR_OBJ(mat)[i+1] = row)

/****************************************************************************
**
*F  PlainMat8Bit( <mat> )
**
*/
void PlainMat8Bit(  Obj mat)
{
    UInt i, l;
    Obj row;
    l  = LEN_MAT8BIT(mat);
    RetypeBag(mat, IS_MUTABLE_OBJ(mat) ? T_PLIST_TAB : T_PLIST_TAB + IMMUTABLE);
    SET_LEN_PLIST(mat, l);
    for (i = 1; i <= l; i++) {
        row = ELM_MAT8BIT(mat, i);
        SET_ELM_PLIST(mat, i, row);
    }
    SET_ELM_PLIST(mat, l + 1, 0);
}

/****************************************************************************
**
*F  FuncPLAIN_MAT8BIT( <self>, <mat> )
**
*/

Obj FuncPLAIN_MAT8BIT( Obj self, Obj mat)
{
    PlainMat8Bit(mat);
    return 0;
}


/****************************************************************************
**
*F  FuncCONV_MAT8BT( <self>, <list> , <q> )
**
**  The library should have taken care of <list> containing only locked
** 8 bit vectors, written over the correct field
*/

Obj FuncCONV_MAT8BIT( Obj self, Obj list, Obj q )
{
    UInt len, i, mut;
    Obj tmp;
    Obj type;

    if (!IS_INTOBJ(q))
        ErrorQuit("CONV_MAT8BIT: q must be a small integer, not a %s",
        (Int)TNAM_OBJ(q), (Int)0L);
    PLAIN_LIST(list);
    len = LEN_PLIST(list);
    mut = IS_MUTABLE_OBJ(list);
    GROW_PLIST(list, len + 1);
    for (i = len; i >= 1; i--) {
        tmp = ELM_PLIST(list, i);
        type = TypeVec8BitLocked(INT_INTOBJ(q), IS_MUTABLE_OBJ(tmp));
        SetTypeDatObj(tmp, type);
        SET_ELM_MAT8BIT(list, i, tmp);
        CHANGED_BAG(list);
    }
    SET_LEN_MAT8BIT(list, len);
    RetypeBag(list, T_POSOBJ);
    type = TypeMat8Bit(INT_INTOBJ(q), mut);
    TYPE_POSOBJ(list) = type;
    return 0;
}



/****************************************************************************
**
*F ProdVec8BitMat8Bit( <vec>, <mat> )
**
** The caller must ensure that <vec> and <mat> are compatible
*/

Obj ProdVec8BitMat8Bit( Obj vec, Obj mat )
{
    UInt q, len, len1, lenm, elts;
    UInt i, j;
    UInt1 byte;
    UInt1 *bptr;
    UInt1 y;
    Obj row1;
    Obj res;
    Obj info;
    UInt1 * gettab;
    Obj *ffefelt;
    Obj x;

    q = FIELD_VEC8BIT(vec);
    len = LEN_VEC8BIT(vec);
    lenm = LEN_MAT8BIT(mat);
    row1 = ELM_MAT8BIT(mat, 1);
    assert(q == FIELD_VEC8BIT(row1));
    len1 = LEN_VEC8BIT(row1);
    res = ZeroVec8Bit(q, len1, IS_MUTABLE_OBJ(vec) || IS_MUTABLE_OBJ(row1));

    /* Finally, we start work */
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    gettab = GETELT_FIELDINFO_8BIT(info);
    ffefelt = FFE_FELT_FIELDINFO_8BIT(info);

    bptr = BYTES_VEC8BIT(vec);
    for (i = 0; i + elts < len; i += elts, bptr++) {
        if ((byte = *bptr)) {
            for (j = 0; j < elts ; j++) {
                if (i + j < lenm) {
                    y = gettab[byte + 256 * j];
                    if (y) {
                        x = ffefelt[y];
                        row1 = ELM_MAT8BIT(mat, i + j + 1);
                        AddVec8BitVec8BitMultInner(res, res, row1, x, 1, len1);
                    }
                }
            }
        }
    }
    if ((byte = *bptr)) {
        for (j = 0; i + j < len  ; j++) {
            if (i + j < lenm) {
                y = gettab[byte + 256 * j];
                if (y) {
                    x = ffefelt[y];
                    row1 = ELM_MAT8BIT(mat, i + j + 1);
                    AddVec8BitVec8BitMultInner(res, res, row1, x, 1, len1);
                }
            }
        }
    }
    return res;
}

/****************************************************************************
**
*F  FuncPROD_VEC8BIT_MAT8BIT( <self>, <vec>, <mat> )
**
**  The caller should ensure that characteristics are right and that the
**  arguments ARE an 8 bit vector and matrix. We still have to check actual
**  fields and lengths.
*/

Obj FuncPROD_VEC8BIT_MAT8BIT( Obj self, Obj vec, Obj mat)
{
    UInt q, q1, q2;

    /* Sort out length mismatches */

    /* Now field mismatches -- consider promoting the vector */
    q = FIELD_VEC8BIT(vec);
    q1 = FIELD_VEC8BIT(ELM_MAT8BIT(mat, 1));
    if (q != q1) {
        if (q > q1 || CALL_1ARGS(IsLockedRepresentationVector, vec) == True)
            return TRY_NEXT_METHOD;
        q2 = q;
        while (q2 < q1) {
            q2 *= q;
        }
        if (q2 == q1)
            RewriteVec8Bit(vec, q1);
        else
            return TRY_NEXT_METHOD;
    }

    /* OK, now we can do the work */
    return ProdVec8BitMat8Bit(vec, mat);
}

/****************************************************************************
**
*F ProdMat8BitVec8Bit( <mat>, <vec> )
**
** The caller must ensure compatibility
*/

Obj ProdMat8BitVec8Bit( Obj mat, Obj vec)
{
    UInt len, i, q;
    Obj info;
    UInt1 *settab;
    Obj res;
    Obj row1;
    UInt1 byte;
    UInt elts;
    UInt1 *feltffe;
    UInt1* ptr;
    Obj entry;
    len = LEN_MAT8BIT(mat);
    q = FIELD_VEC8BIT(vec);
    row1 = ELM_MAT8BIT(mat, 1);
    assert(q = FIELD_VEC8BIT(row1));
    res = ZeroVec8Bit(q, len, IS_MUTABLE_OBJ(row1) || IS_MUTABLE_OBJ(vec));
    info = GetFieldInfo8Bit(q);
    settab = SETELT_FIELDINFO_8BIT(info);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    feltffe = FELT_FFE_FIELDINFO_8BIT(info);
    byte = 0;
    ptr = BYTES_VEC8BIT(res);
    for (i = 0; i < len; i++) {
        entry = ScalarProductVec8Bits(vec, ELM_MAT8BIT(mat, i + 1));
        byte = settab[ byte + 256 * (elts * feltffe[VAL_FFE(entry)] +  i % elts)];
        if (i % elts == elts - 1) {
            *ptr++ = byte;
            byte = 0;
        }
    }
    if (len % elts != 0)
        *ptr++ = byte;
    return res;
}

/****************************************************************************
**
*F  FuncPROD_MAT8BIT_VEC8BIT( <self>, <mat>, <vec> )
**
**  The caller should ensure that characteristics are right and that the
**  arguments ARE an 8 bit vector and matrix. We still have to check actual
**  fields and lengths.
*/

Obj FuncPROD_MAT8BIT_VEC8BIT( Obj self, Obj mat, Obj vec)
{
    UInt q, q1, q2;
    Obj row;

    /* Sort out length mismatches */

    row = ELM_MAT8BIT(mat, 1);

    /* Now field mismatches -- consider promoting the vector */
    q = FIELD_VEC8BIT(vec);
    q1 = FIELD_VEC8BIT(row);
    if (q != q1) {
        if (q > q1 || CALL_1ARGS(IsLockedRepresentationVector, vec) == True)
            return TRY_NEXT_METHOD;
        q2 = q;
        while (q2 < q1) {
            q2 *= q;
        }
        if (q2 == q1)
            RewriteVec8Bit(vec, q1);
        else
            return TRY_NEXT_METHOD;
    }

    /* OK, now we can do the work */
    return ProdMat8BitVec8Bit(mat, vec);
}


/****************************************************************************
**
*F  ProdMat8BitMat8Bit( <matl>, <matr> )
**
**  Caller must check matrix sizes and field
*/

Obj ProdMat8BitMat8Bit( Obj matl, Obj matr)
{
    Obj prod;
    UInt i;
    UInt len, q;
    Obj row;
    Obj locked_type;
    Obj type;

    len = LEN_MAT8BIT(matl);
    q = FIELD_VEC8BIT(ELM_MAT8BIT(matl, 1));

    assert(q == FIELD_VEC8BIT(ELM_MAT8BIT(matr, 1)));
    assert(LEN_MAT8BIT(matr) == LEN_VEC8BIT(ELM_MAT8BIT(matl, 1)));

    prod = NewBag(T_POSOBJ, sizeof(Obj) * (len + 2));
    SET_LEN_MAT8BIT(prod, len);
    type = TypeMat8Bit(q, IS_MUTABLE_OBJ(matl) || IS_MUTABLE_OBJ(matr));
    TYPE_POSOBJ(prod) = type;
    locked_type  = TypeVec8BitLocked(q, IS_MUTABLE_OBJ(ELM_MAT8BIT(matl, 1)) || IS_MUTABLE_OBJ(ELM_MAT8BIT(matr, 1)));
    for (i = 1; i <= len; i++) {
        row = ProdVec8BitMat8Bit(ELM_MAT8BIT(matl, i), matr);

        /* Since I'm going to put this vector into a matrix, I must lock its
        representation, so that it doesn't get rewritten over GF(q^k) */
        SetTypeDatObj(row, locked_type);
        SET_ELM_MAT8BIT(prod, i, row);
        CHANGED_BAG(prod);
        TakeInterrupt();
    }
    return prod;

}

/****************************************************************************
**
*F  FuncPROD_MAT8BIT_MAT8BIT( <self>, <matl>, <matr> )
**
*/

Obj FuncPROD_MAT8BIT_MAT8BIT( Obj self, Obj matl, Obj matr)
{
    UInt ql, qr;
    Obj rowl;

    rowl = ELM_MAT8BIT(matl, 1);
    ql = FIELD_VEC8BIT(rowl);
    qr = FIELD_VEC8BIT(ELM_MAT8BIT(matr, 1));

    if (ql != qr)
        return TRY_NEXT_METHOD;

    return ProdMat8BitMat8Bit(matl, matr);
}


/****************************************************************************
**
*F  InverseMat8Bit( <mat> )
**
*/

Obj InverseMat8Bit( Obj mat, UInt mut)
{
    Obj cmat, inv;
    UInt len, off;
    UInt i, j, k;
    Obj zero;
    UInt q;
    Obj info;
    UInt1 *ptr;
    UInt elts;
    UInt1 *settab, *gettab;
    UInt1 byte;
    Obj row, row1, row2;
    Obj *ffefelt;
    UInt1 *feltffe;
    UInt pos;
    UInt1 x = 0;
    UInt o;
    Obj xi;
    Obj xn;
    Obj type;

    row = ELM_MAT8BIT(mat, 1);
    q = FIELD_VEC8BIT(row);
    len = LEN_MAT8BIT(mat);
    assert(len == LEN_VEC8BIT(row));
    inv = NEW_PLIST(T_PLIST, len + 1);
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);

    if (len == 1) {
        gettab = GETELT_FIELDINFO_8BIT(info);
        ffefelt = FFE_FELT_FIELDINFO_8BIT(info);
        x = gettab[BYTES_VEC8BIT(row)[0]];
        if (x == 0)
            return Fail;
        xi = INV(ffefelt[x]);
        row1 = NewBag(T_DATOBJ, SIZE_VEC8BIT(1, elts));
        type = TypeVec8BitLocked(q, mut == 2 || (mut == 1 && IS_MUTABLE_OBJ(row)));
        SetTypeDatObj(row1, type);
        settab = SETELT_FIELDINFO_8BIT(info);
        feltffe = FELT_FFE_FIELDINFO_8BIT(info);
        BYTES_VEC8BIT(row1)[0] = settab[256 * elts * feltffe[VAL_FFE(xi)]];
        SET_LEN_VEC8BIT(row1, 1);
        SET_FIELD_VEC8BIT(row1, q);
        SET_ELM_PLIST(inv, 1, INTOBJ_INT(1));
        SET_ELM_PLIST(inv, 2, row1);
        CHANGED_BAG(inv);
        RetypeBag(inv, T_POSOBJ);
        type = TypeMat8Bit(q, mut == 2 || (mut == 1 && IS_MUTABLE_OBJ(mat)));
        TYPE_POSOBJ(inv) = type;
        SET_LEN_MAT8BIT(inv, 1);
        return inv;
    }

    /* set up cmat and inv. Note that the row numbering is offset */
    cmat = NEW_PLIST(T_PLIST, len);
    zero = ZeroVec8Bit(q, len, 1);
    o = FELT_FFE_FIELDINFO_8BIT(info)[1];
    for (i = 1; i <= len; i++) {
        row = ELM_MAT8BIT(mat, i);
        row = SHALLOW_COPY_OBJ(row);
        SET_ELM_PLIST(cmat, i, row);
        CHANGED_BAG(cmat);
        row = SHALLOW_COPY_OBJ(zero);
        ptr = BYTES_VEC8BIT(row) + (i - 1) / elts;

        /* we can't retain this pointer, because of garbage collections */
        settab = SETELT_FIELDINFO_8BIT(info);
        /* we know we are replacing a zero  */
        *ptr = settab[256 * ((i - 1) % elts + o * elts)];
        SET_ELM_PLIST(inv, i + 1, row);
        CHANGED_BAG(inv);
    }

    /* Now do Gaussian elimination in cmat and mirror it on inv
     from here, no garbage collections are allowed until the end */
    gettab = GETELT_FIELDINFO_8BIT(info);
    ffefelt = FFE_FELT_FIELDINFO_8BIT(info);

    for (i = 1; i <= len; i++) {
        off = (i - 1) / elts;
        pos = (i - 1) % elts;
        /* find a non-zero entry in column i */
        for (j = i; j <= len; j++) {
            row = ELM_PLIST(cmat, j);
            byte = BYTES_VEC8BIT(row)[off];
            if (byte != 0 && (x = gettab[byte + 256 * pos]) != 0)
                break;
        }

        /* if we didn't find one */
        if (j > len)
            return Fail;

        /* swap and normalize */
        row1 = ELM_PLIST(inv, j + 1);
        if (i != j) {
            SET_ELM_PLIST(cmat, j, ELM_PLIST(cmat, i));
            SET_ELM_PLIST(cmat, i, row);
            SET_ELM_PLIST(inv, j + 1, ELM_PLIST(inv, i + 1));
            SET_ELM_PLIST(inv, i + 1, row1);
        }
        if (x != o) {
            xi = INV(ffefelt[x]);
            MultVec8BitFFEInner(row, row, xi, i, len);
            MultVec8BitFFEInner(row1, row1, xi, 1, len);
        }

        /* Now clean out column */
        for (k = 1; k <= len; k++) {
            if (k < i || k > j) {
                row2 = ELM_PLIST(cmat, k);
                byte = BYTES_VEC8BIT(row2)[off];
                if (byte != 0 && (x = gettab[byte + 256 * pos]) != 0) {
                    xn = AINV(ffefelt[x]);
                    AddVec8BitVec8BitMultInner(row2, row2, row, xn, i, len);
                    row2 = ELM_PLIST(inv, k + 1);
                    AddVec8BitVec8BitMultInner(row2, row2, row1, xn, 1, len);
                }
            }
        }
        if (TakeInterrupt()) {
            gettab = GETELT_FIELDINFO_8BIT(info);
            ffefelt = FFE_FELT_FIELDINFO_8BIT(info);
        }
    }

    /* Now clean up inv and return it */
    SET_ELM_PLIST(inv, 1, INTOBJ_INT(len));
    type = TypeVec8BitLocked(q, mut == 2 || (mut == 1 && IS_MUTABLE_OBJ(ELM_MAT8BIT(mat, 1))));
    for (i = 2 ; i <= len + 1; i++) {
        row = ELM_PLIST(inv, i);
        SetTypeDatObj(row, type);
    }
    RetypeBag(inv, T_POSOBJ);
    type = TypeMat8Bit(q, mut == 2 || (mut == 1 && IS_MUTABLE_OBJ(mat)));
    TYPE_POSOBJ(inv) = type;
    CHANGED_BAG(inv);
    return inv;
}

/****************************************************************************
**
*F FuncINV_MAT8BIT_MUTABLE( <self>, <mat> )
**
*/

Obj FuncINV_MAT8BIT_MUTABLE( Obj self, Obj mat)
{
    if (LEN_MAT8BIT(mat) != LEN_VEC8BIT(ELM_MAT8BIT(mat, 1))) {
        mat = ErrorReturnObj("InverseOp: matrix must be square, not %d by %d",
                             LEN_MAT8BIT(mat),
                             LEN_VEC8BIT(ELM_MAT8BIT(mat, 1)),
                             "you can replace matrix <inv> via 'return <inv>;'");
        return INV(mat);
    }

    return InverseMat8Bit(mat, 2);
}

/****************************************************************************
**
*F FuncINV_MAT8BIT_SAME_MUTABILITY( <self>, <mat> )
**
*/

Obj FuncINV_MAT8BIT_SAME_MUTABILITY( Obj self, Obj mat)
{
    if (LEN_MAT8BIT(mat) != LEN_VEC8BIT(ELM_MAT8BIT(mat, 1))) {
        mat = ErrorReturnObj("INVOp: matrix must be square, not %d by %d",
                             LEN_MAT8BIT(mat),
                             LEN_VEC8BIT(ELM_MAT8BIT(mat, 1)),
                             "you can replace matrix <inv> via 'return <inv>;'");
        return INV_MUT(mat);
    }

    return InverseMat8Bit(mat, 1);
}

/****************************************************************************
**
*F FuncINV_MAT8BIT_IMMUTABLE( <self>, <mat> )
**
*/

Obj FuncINV_MAT8BIT_IMMUTABLE( Obj self, Obj mat)
{
    if (LEN_MAT8BIT(mat) != LEN_VEC8BIT(ELM_MAT8BIT(mat, 1))) {
        Obj inv;
        mat = ErrorReturnObj("Inverse: matrix must be square, not %d by %d",
                             LEN_MAT8BIT(mat),
                             LEN_VEC8BIT(ELM_MAT8BIT(mat, 1)),
                             "you can replace matrix <inv> via 'return <inv>;'");
        inv = INV_MUT(mat);
        MakeImmutable(inv);
        return inv;
    }

    return InverseMat8Bit(mat, 0);
}

/****************************************************************************
**
*F  FuncASS_MAT8BIT( <self>, <mat>, <pos>, <obj> )
**
*/

Obj FuncASS_MAT8BIT(Obj self, Obj mat, Obj p, Obj obj)
{
    UInt len;
    UInt len1;
    UInt len2;
    UInt q;
    UInt q1, q2;
    Obj row;
    UInt pos;
    Obj type;

    if (!IS_INTOBJ(p))
        ErrorQuit("ASS_MAT8BIT: position should be a small integer, not a %s",
                  (Int)TNAM_OBJ(p), 0L);
    pos = INT_INTOBJ(p);
    if (pos <= 0)
        ErrorQuit("ASS_MAT8BIT: position must be positive", 0L, 0L);

    len = LEN_MAT8BIT(mat);
    if (!IS_VEC8BIT_REP(obj) && !IS_GF2VEC_REP(obj))
        goto cantdo;

    if (pos > len + 1)
        goto cantdo;

    if (len == 1 && pos == 1) {
        if (IS_VEC8BIT_REP(obj)) {
            q = FIELD_VEC8BIT(obj);
            goto cando;
        } else {
            TYPE_POSOBJ(mat) = IS_MUTABLE_OBJ(mat) ? TYPE_LIST_GF2MAT : TYPE_LIST_GF2MAT_IMM;
            SetTypeDatObj(obj, IS_MUTABLE_OBJ(obj) ? TYPE_LIST_GF2VEC_LOCKED : TYPE_LIST_GF2VEC_IMM_LOCKED);
            SET_ELM_GF2MAT(mat, 1, obj);
            return (Obj) 0;
        }
    }

    row = ELM_MAT8BIT(mat, 1);
    len1 = LEN_VEC8BIT(row);

    if (IS_VEC8BIT_REP(obj))
        len2 = LEN_VEC8BIT(obj);
    else
        len2 = LEN_GF2VEC(obj);

    if (len2 != len1)
        goto cantdo;

    q = FIELD_VEC8BIT(row);
    if (IS_GF2VEC_REP(obj)) {
        if (q % 2 != 0 || CALL_1ARGS(IsLockedRepresentationVector, obj) == True)
            goto cantdo;
        else {
            RewriteGF2Vec(obj, q);
            goto cando;
        }
    }

    q1 = FIELD_VEC8BIT(obj);

    if (q1 == q)
        goto cando;

    if (q1 > q || CALL_1ARGS(IsLockedRepresentationVector, obj) == True)
        goto cantdo;

    q2 = q1 * q1;
    while (q2 <= 256) {
        if (q2 == q) {
            RewriteVec8Bit(obj, q);
            goto cando;
        }
        q2 *= q1;
    }
    goto cantdo;

cando:
    if (pos > len) {
        ResizeBag(mat, sizeof(Obj) * (pos + 2));
        SET_LEN_MAT8BIT(mat, pos);
    }
    type = TypeVec8BitLocked(q, IS_MUTABLE_OBJ(obj));
    SetTypeDatObj(obj, type);
    SET_ELM_MAT8BIT(mat, pos, obj);
    CHANGED_BAG(mat);
    return (Obj) 0;

cantdo:
    PlainMat8Bit(mat);
    ASS_LIST(mat, pos, obj);
    CHANGED_BAG(mat);

    return (Obj)0;
}

/****************************************************************************
**
*F  SumMat8BitMat8Bit( <ml> ,<mr>)
**
**  Caller's job to do all checks
*/

Obj SumMat8BitMat8Bit( Obj ml, Obj mr)
{
    Obj sum;
    UInt ll, lr, wl, wr, ls;
    UInt q;
    UInt i;
    Obj  row;
    Obj type;
    ll = LEN_MAT8BIT(ml);
    lr = LEN_MAT8BIT(mr);
    wl = LEN_MAT8BIT(ELM_MAT8BIT(ml, 1));
    wr = LEN_MAT8BIT(ELM_MAT8BIT(mr, 1));

    /* We have to track the cases where the result is not rectangular */
    if (((ll > lr) && (wr > wl)) ||
    ((lr > ll) && (wl > wr)))
        return TRY_NEXT_METHOD;

    /* Now sort out the size of the result */
    if (ll > lr) {
        ls = ll;
        assert(wl > wr);
    } else {
        ls = lr;
        assert(wr >= wl);
    }

    q = FIELD_VEC8BIT(ELM_MAT8BIT(ml, 1));
    sum = NewBag(T_POSOBJ, sizeof(Obj) * (ls + 2));
    type = TypeMat8Bit(q, IS_MUTABLE_OBJ(ml) || IS_MUTABLE_OBJ(mr));
    TYPE_POSOBJ(sum) = type;
    SET_LEN_MAT8BIT(sum, ls);

    type = TypeVec8BitLocked(q, IS_MUTABLE_OBJ(ELM_MAT8BIT(ml, 1)) || IS_MUTABLE_OBJ(ELM_MAT8BIT(mr, 1)));

    for (i = 1; i <= ls; i++) {
        if (i > ll)
            row = CopyVec8Bit(ELM_MAT8BIT(mr, i), 1);
        else if (i > lr)
            row = CopyVec8Bit(ELM_MAT8BIT(ml, i), 1);
        else
            row = SumVec8BitVec8Bit(ELM_MAT8BIT(ml, i), ELM_MAT8BIT(mr, i));

        SetTypeDatObj(row, type);
        SET_ELM_MAT8BIT(sum, i, row);
        CHANGED_BAG(sum);
    }
    return sum;
}

/****************************************************************************
**
*F  FuncSUM_MAT8BIT_MAT8BIT( <self>, <ml>, <mr> )
**
**  Caller should check that both args are mat8bit over the same field
*/

Obj FuncSUM_MAT8BIT_MAT8BIT( Obj self, Obj ml, Obj mr)
{
    UInt q;
    q = FIELD_VEC8BIT(ELM_MAT8BIT(ml, 1));
    if (q != FIELD_VEC8BIT(ELM_MAT8BIT(mr, 1)))
        return TRY_NEXT_METHOD;
    else
        return SumMat8BitMat8Bit(ml, mr);
}

/****************************************************************************
**
*F  DiffMat8BitMat8Bit( <ml> ,<mr>)
**
**  Caller's job to do all checks
*/

Obj DiffMat8BitMat8Bit( Obj ml, Obj mr)
{
    Obj diff;
    UInt q;
    UInt i;
    Obj  row;
    Obj type;
    Obj info;
    FF f;
    FFV minusOne;
    Obj mone;
    UInt ll, lr, wl, wr, ld;

    ll = LEN_MAT8BIT(ml);
    lr = LEN_MAT8BIT(mr);
    wl = LEN_MAT8BIT(ELM_MAT8BIT(ml, 1));
    wr = LEN_MAT8BIT(ELM_MAT8BIT(mr, 1));

    /* We have to track the cases where the result is not rectangular */
    if (((ll > lr) && (wr > wl)) ||
        ((lr > ll) && (wl > wr)))
        return TRY_NEXT_METHOD;

    /* Now sort out the size of the result */
    if (ll > lr) {
        ld = ll;
        assert(wl > wr);
    } else {
        ld = lr;
        assert(wr >= wl);
    }
    q = FIELD_VEC8BIT(ELM_MAT8BIT(ml, 1));

    if (q % 2 == 0)
        return SumMat8BitMat8Bit(ml, mr);

    diff = NewBag(T_POSOBJ, sizeof(Obj) * (ld + 2));
    type = TypeMat8Bit(q, IS_MUTABLE_OBJ(ml) || IS_MUTABLE_OBJ(mr));
    TYPE_POSOBJ(diff) = type;
    SET_LEN_MAT8BIT(diff, ld);
    type = TypeVec8BitLocked(q, IS_MUTABLE_OBJ(ELM_MAT8BIT(ml, 1)) || IS_MUTABLE_OBJ(ELM_MAT8BIT(mr, 1)));
    info = GetFieldInfo8Bit(q);
    f = FiniteField(P_FIELDINFO_8BIT(info), D_FIELDINFO_8BIT(info));
    minusOne = NEG_FFV(1, SUCC_FF(f));
    mone = NEW_FFE(f, minusOne);

    for (i = 1; i <= ld; i++) {
        if (i > ll)
            row = MultVec8BitFFE(ELM_MAT8BIT(mr, i), mone);
        else if (i > lr)
            row = CopyVec8Bit(ELM_MAT8BIT(ml, i), 1);
        else
            row = SumVec8BitVec8BitMult(ELM_MAT8BIT(ml, i), ELM_MAT8BIT(mr, i), mone);

        SetTypeDatObj(row, type);
        SET_ELM_MAT8BIT(diff, i, row);
        CHANGED_BAG(diff);
    }
    return diff;
}

/****************************************************************************
**
*F  FuncDIFF_MAT8BIT_MAT8BIT( <self>, <ml>, <mr> )
**
**  Caller should check that both args are mat8bit over the same field
*/

Obj FuncDIFF_MAT8BIT_MAT8BIT( Obj self, Obj ml, Obj mr)
{
    UInt q;

    q = FIELD_VEC8BIT(ELM_MAT8BIT(ml, 1));
    if (q != FIELD_VEC8BIT(ELM_MAT8BIT(mr, 1)))
        return TRY_NEXT_METHOD;
    else
        return DiffMat8BitMat8Bit(ml, mr);
}


/****************************************************************************
**
*f * * * * * * polynomial support functions * * * * * * * * * * * * * * * * *
**
** The first batch are utilities for the others
*/

UInt RightMostNonZeroVec8Bit( Obj vec)
{
    UInt q;
    UInt len;
    Obj info;
    UInt elts;
    UInt1 *ptr, *ptrS;
    Int i;
    UInt1 *gettab;
    /*UInt1 byte; */
    len = LEN_VEC8BIT(vec);
    if (len == 0)
        return 0;
    q = FIELD_VEC8BIT(vec);
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    ptrS = BYTES_VEC8BIT(vec);
    ptr = ptrS + (len - 1) / elts;

    /* handle last byte specially, unless it happens to be full */
    if (len % elts != 0) {
        gettab = GETELT_FIELDINFO_8BIT(info) + *ptr;
        for (i = len % elts - 1; i >= 0; i--) {
            if (gettab[256 * i] != 0)
                return (elts * (len / elts) + i + 1);
        }
        ptr--;
    }

    /* now skip over empty bytes */
    while (ptr >= ptrS && *ptr == 0)
        ptr --;
    if (ptr < ptrS)
        return 0;


    /* Now look in the rightmost non-empty byte for the position */
    gettab = GETELT_FIELDINFO_8BIT(info) + *ptr;
    for (i = elts - 1; i >= 0; i--) {
        if (gettab[256 * i]  != 0)
            return (elts * (ptr - ptrS) + i + 1);
    }
    Pr("panic: this should never happen\n", 0, 0);
    SyExit(1);
}

void ResizeVec8Bit( Obj vec, UInt newlen, UInt knownclean )
{
    UInt q;
    UInt len;
    UInt elts;
    Obj info;
    UInt1 *settab;
    UInt i;
    UInt1 *ptr, *ptr2, byte;
    len = LEN_VEC8BIT(vec);
    if (len == newlen)
        return;

    if (True == DoFilter(IsLockedRepresentationVector, vec)) {
        ErrorReturnVoid("Resize of locked compressed vector is forbidden", 0, 0,
        "You can `return;' to ignore the operation");
        return;
    }

    /*
    if (newlen == 0)
      {
        RetypeBag(vec, T_PLIST_EMPTY);
        SET_LEN_PLIST(vec,0);
        SHRINK_PLIST(vec,0);
        return;
      }
    */
    q = FIELD_VEC8BIT(vec);
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    SET_LEN_VEC8BIT(vec, newlen);
    ResizeBag(vec, SIZE_VEC8BIT(newlen, elts));
    /* vector has got shorter. */
    if (len > newlen) {
        if (newlen % elts) {
            /* clean spare entries in last byte */
            settab = SETELT_FIELDINFO_8BIT(info);
            byte = BYTES_VEC8BIT(vec)[(newlen - 1) / elts];
            for (i = newlen % elts; i < elts; i++)
                byte = settab[ byte + 256 * i];
            BYTES_VEC8BIT(vec)[(newlen - 1) / elts] = byte;
        }
        /* Clean spare bytes in last word for characteristic 2 */
        if ((q % 2) == 0)
            for (i = (newlen + elts - 1) / elts; i % sizeof(UInt); i++)
                BYTES_VEC8BIT(vec)[i] = 0;
    }

    /* vector has got longer and might be dirty */
    if (!knownclean && newlen > len) {
        settab = SETELT_FIELDINFO_8BIT(info);
        ptr = BYTES_VEC8BIT(vec);
        if (len) {
            ptr += (len - 1) / elts;
            byte = *ptr;
            for (i = (len - 1) % elts + 1; i < elts; i++)
                byte = settab[ byte + 256 * i];
            *ptr++ = byte;
        }
        ptr2 = BYTES_VEC8BIT(vec) + (newlen + elts - 1) / elts;
        while (ptr < ptr2)
            *ptr++ = (UInt1)0;
    }
    return;
}


void ShiftLeftVec8Bit( Obj vec, UInt amount)
{
    UInt q;
    Obj info;
    UInt elts;
    UInt len;
    UInt1 *ptr1, *ptr2, *end;
    UInt1 fbyte, tbyte;
    UInt from, to;
    UInt1 *gettab, *settab;
    UInt1 x;

    /* A couple of trivial cases */
    if (amount == 0)
        return;
    len = LEN_VEC8BIT(vec);
    if (amount >= len) {
        ResizeVec8Bit(vec, 0, 0);
        return;
    }

    q = FIELD_VEC8BIT(vec);
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    ptr1 = BYTES_VEC8BIT(vec);
    ptr2 = BYTES_VEC8BIT(vec) + amount / elts;

    /* The easy case is just a shift by bytes */
    if (amount % elts == 0) {
        end = BYTES_VEC8BIT(vec) + (len + elts - 1) / elts;
        while (ptr2 < end)
            *ptr1++ = *ptr2++;
    } else {
        /* The general case */
        from = amount;
        to = 0;
        fbyte = *ptr2;
        tbyte = 0;
        gettab = GETELT_FIELDINFO_8BIT(info);
        settab = SETELT_FIELDINFO_8BIT(info);

        while (from < len) {
            x = gettab[fbyte + 256 * (from % elts)];
            tbyte = settab[tbyte + 256 * (to % elts + elts * x)];
            if (++from % elts == 0)
                fbyte = *++ptr2;
            if (++to % elts == 0) {
                *ptr1++ = tbyte;
                tbyte = 0;
            }
        }
        if (to % elts != 0)
            *ptr1 = tbyte;
    }
    ResizeVec8Bit(vec, len - amount, 0);
    return;
}

void ShiftRightVec8Bit( Obj vec, UInt amount) /* pads with zeros */
{
    UInt q;
    Obj info;
    UInt elts;
    UInt len;
    UInt1 *ptr1, *ptr2, *end;
    UInt1 fbyte, tbyte;
    Int from, to;
    UInt1 *gettab, *settab;
    UInt1 x;

    /* A trivial cases */
    if (amount == 0)
        return;

    /* make room */
    len = LEN_VEC8BIT(vec);
    ResizeVec8Bit(vec, len + amount, 0);

    q = FIELD_VEC8BIT(vec);
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    ptr1 = BYTES_VEC8BIT(vec) + (len - 1 + amount) / elts;
    ptr2 = BYTES_VEC8BIT(vec) + (len - 1) / elts;

    /* The easy case is just a shift by bytes */
    if (amount % elts == 0) {
        end = BYTES_VEC8BIT(vec);
        while (ptr2 >= end)
            *ptr1-- = *ptr2--;
        while (ptr1 >= end)
            *ptr1-- = (UInt1)0;
    } else {
        /* The general case */
        from = len - 1;
        to = len + amount - 1;
        fbyte = *ptr2;
        tbyte = 0;
        gettab = GETELT_FIELDINFO_8BIT(info);
        settab = SETELT_FIELDINFO_8BIT(info);

        while (from >= 0) {
            x = gettab[fbyte + 256 * (from % elts)];
            tbyte = settab[tbyte + 256 * (to % elts + elts * x)];
            if (from-- % elts == 0)
                fbyte = *--ptr2;
            if (to-- % elts == 0) {
                *ptr1-- = tbyte;
                tbyte = 0;
            }
        }
        if (to % elts != elts - 1)
            *ptr1-- = tbyte;
        end = BYTES_VEC8BIT(vec);
        while (ptr1 >= end)
            *ptr1-- = (UInt1)0;
    }
    return;
}



/****************************************************************************
**
*F FuncADD_COEFFS_VEC8BIT_3( <self>, <vec1>, <vec2>, <mult> )
**
** This is very like AddRowVector, except that it will enlarge <vec1> if
** necessary and returns the position of the rightmost non-zero entry in the
** result.
*/

Obj FuncADD_COEFFS_VEC8BIT_3( Obj self, Obj vec1, Obj vec2, Obj mult )
{
    UInt q;
    UInt len;
    len = LEN_VEC8BIT(vec2);
    if (VAL_FFE(mult) == 0)
        return INTOBJ_INT(RightMostNonZeroVec8Bit(vec1));
    if (LEN_VEC8BIT(vec1) < len) {
        ResizeVec8Bit(vec1, len, 0);
    }

    /* Now we know that the characteristics must match, but not the fields */
    q = FIELD_VEC8BIT(vec1);

    /* fix up fields if necessary */
    if (q != FIELD_VEC8BIT(vec2) || q != SIZE_FF(FLD_FFE(mult))) {
        Obj info, info1;
        UInt d, d1, q1, d2, d0, q0, p, i;
        FFV val;
        /* find a common field */
        info = GetFieldInfo8Bit(q);
        d = D_FIELDINFO_8BIT(info);
        q1 = FIELD_VEC8BIT(vec2);
        info1 = GetFieldInfo8Bit(q1);
        d1 = D_FIELDINFO_8BIT(info1);
        d2 = DegreeFFE(mult);
        d0 = LcmDegree(d, d1);
        d0 = LcmDegree(d0, d2);
        p = P_FIELDINFO_8BIT(info);
        assert(p == P_FIELDINFO_8BIT(info1));
        assert(p == CHAR_FF(FLD_FFE(mult)));
        q0 = 1;
        for (i = 0; i < d0; i++)
            q0 *= p;

        /* if the exponent is bigger than 31, overflow changes the value to 0 */
        if (d0 > 8 || q0 > 256)
            return TRY_NEXT_METHOD;
        if ((q0 > q && CALL_1ARGS(IsLockedRepresentationVector, vec1) == True) ||
        (q0 > q1 && CALL_1ARGS(IsLockedRepresentationVector, vec2) == True))
            return TRY_NEXT_METHOD;
        RewriteVec8Bit(vec1, q0);
        RewriteVec8Bit(vec2, q0);
        val = VAL_FFE(mult);
        if (val != 0)
            val = 1 + (val - 1) * (q0 - 1) / (SIZE_FF(FLD_FFE(mult)) - 1);
        mult = NEW_FFE(FiniteField(p, d0), val);
        q = q0;
    }
    AddVec8BitVec8BitMultInner(vec1, vec1, vec2, mult, 1, len);
    return INTOBJ_INT(RightMostNonZeroVec8Bit(vec1));
}

/****************************************************************************
**
*F FuncADD_COEFFS_VEC8BIT_2( <self>, <vec1>, <vec2> )
**
** This is very like AddRowVector, except that it will enlarge <vec1> if
** necessary and returns the position of the rightmost non-zero entry in the
** result.
*/

Obj FuncADD_COEFFS_VEC8BIT_2( Obj self, Obj vec1, Obj vec2 )
{
    UInt q;
    UInt len;
    len = LEN_VEC8BIT(vec2);
    if (LEN_VEC8BIT(vec1) < len) {
        ResizeVec8Bit(vec1, len, 0);
    }

    /* Now we know that the characteristics must match, but not the fields */
    q = FIELD_VEC8BIT(vec1);

    /* fix up fields if necessary */
    if (q != FIELD_VEC8BIT(vec2)) {
        Obj info, info1;
        UInt d, d1, q1, d0, q0, p, i;

        /* find a common field */
        info = GetFieldInfo8Bit(q);
        d = D_FIELDINFO_8BIT(info);
        q1 = FIELD_VEC8BIT(vec2);
        /*Pr("q= %d q1= %d ",q,q1);*/
        info1 = GetFieldInfo8Bit(q1);
        d1 = D_FIELDINFO_8BIT(info1);
        d0 = LcmDegree(d, d1);
        p = P_FIELDINFO_8BIT(info);
        assert(p == P_FIELDINFO_8BIT(info1));
        q0 = 1;
        for (i = 0; i < d0; i++)
            q0 *= p;
        /*Pr("q0= %d d0= %d\n",q0,d0); */

        /* if the exponent is bigger than 31, overflow changes the value to 0 */
        if (d0 > 8 || q0 > 256)
            return TRY_NEXT_METHOD;
        if ((q0 > q && CALL_1ARGS(IsLockedRepresentationVector, vec1) == True) ||
            (q0 > q1 && CALL_1ARGS(IsLockedRepresentationVector, vec2) == True))
            return TRY_NEXT_METHOD;
        RewriteVec8Bit(vec1, q0);
        RewriteVec8Bit(vec2, q0);
        q = q0;
    }
    AddVec8BitVec8BitInner(vec1, vec1, vec2, 1, len);
    return INTOBJ_INT(RightMostNonZeroVec8Bit(vec1));
}

/****************************************************************************
**
*F  FuncSHIFT_VEC8BIT_LEFT( <self>, <vec>, <amount> )
**
*/

Obj FuncSHIFT_VEC8BIT_LEFT( Obj self, Obj vec, Obj amount)
{
    /* should be checked in method selection */
    assert(IS_MUTABLE_OBJ(vec));
    while (!IS_INTOBJ(amount) || INT_INTOBJ(amount) < 0) {
        amount = ErrorReturnObj("SHIFT_VEC8BIT_LEFT: <amount> must be a non-negative small integer",
                                0, 0,
                                "you can replace <amount> via 'return <amount>;'");
    }
    ShiftLeftVec8Bit(vec, INT_INTOBJ(amount));
    return (Obj) 0;
}

/****************************************************************************
**
*F  FuncSHIFT_VEC8BIT_RIGHT( <self>, <vec>, <amount>, <zero> )
**
*/

Obj FuncSHIFT_VEC8BIT_RIGHT( Obj self, Obj vec, Obj amount, Obj zero)
{
    assert(IS_MUTABLE_OBJ(vec));
    while (!IS_INTOBJ(amount) || INT_INTOBJ(amount) < 0) {
        amount = ErrorReturnObj("SHIFT_VEC8BIT_RIGHT: <amount> must be a non-negative small integer",
                                0, 0,
                                "you can replace <amount> via 'return <amount>;'");
    }
    ShiftRightVec8Bit(vec, INT_INTOBJ(amount));
    return (Obj) 0;
}

/****************************************************************************
**
*F  FuncRESIZE_VEC8BIT( <self>, <vec>, <newsize> )
**
*/

Obj FuncRESIZE_VEC8BIT( Obj self, Obj vec, Obj newsize )
{
    if (!IS_MUTABLE_OBJ(vec))
        ErrorReturnVoid("RESIZE_VEC8BIT: vector must be mutable",
                        0, 0,
                        "you can 'return;'");
    while (IS_INTOBJ(newsize) && INT_INTOBJ(newsize) < 0) {
        newsize = ErrorReturnObj("RESIZE_VEC8BIT: <amount> must be a non-negative integer, not %d",
                                 INT_INTOBJ(newsize), 0,
                                 "you can replace <amount> via 'return <amount>;'");
    }
    ResizeVec8Bit(vec, INT_INTOBJ(newsize), 0);
    return (Obj) 0;
}
  
/****************************************************************************
**
*F  FuncRIGHTMOST_NONZERO_VEC8BIT( <self>, <vec> )
**
*/

Obj FuncRIGHTMOST_NONZERO_VEC8BIT( Obj self, Obj vec)
{
    return INTOBJ_INT(RightMostNonZeroVec8Bit(vec));
}

/****************************************************************************
**
*F  ProdCoeffsVec8Bit( <res>, <vl>, <ll>, <vr>, <lr>)
**
*/

void ProdCoeffsVec8Bit ( Obj res, Obj vl, UInt ll, Obj vr, UInt lr )
{
    UInt q;
    Obj info;
    UInt elts;
    UInt1 * addtab = 0;
    UInt1 * pmulltab;
    UInt1 * pmulutab = 0;
    UInt p;
    UInt i, j;
    UInt1 *ptrl, *ptrr, *ptrp, bytel, byter;
    UInt1 byte1, byte2;
    UInt1 * gettab, *settab;
    UInt1 partl = 0, partr = 0;
    q = FIELD_VEC8BIT(vl);
    assert(q == FIELD_VEC8BIT(vr));
    assert(q == FIELD_VEC8BIT(res));
    assert(ll <= LEN_VEC8BIT(vl));
    assert(lr <= LEN_VEC8BIT(vr));
    assert(ll + lr - 1 <= LEN_VEC8BIT(res));
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    p = P_FIELDINFO_8BIT(info);
    pmulltab = PMULL_FIELDINFO_8BIT(info);
    if (q <= 16)
        pmulutab = PMULU_FIELDINFO_8BIT(info);
    if (p != 2)
        addtab = ADD_FIELDINFO_8BIT(info);
    ptrl = BYTES_VEC8BIT(vl);
    ptrr = BYTES_VEC8BIT(vr);
    ptrp = BYTES_VEC8BIT(res);

    /* This calculation is done in four parts. The first deals with the whole
       bytes from both polynomials */
    for (i = 0; i < ll / elts; i++) {
        bytel = ptrl[i];
        if (bytel != 0)
            for (j = 0; j < lr / elts; j++) {
                byter = ptrr[j];
                if (byter != 0) {
                    byte1 = pmulltab[ 256 * bytel + byter];
                    if (byte1 != 0) {
                        if (p != 2)
                            ptrp[i + j] = addtab[ ptrp[i + j] + 256 * byte1];
                        else
                            ptrp[i + j] ^= byte1;
                    }
                    if (elts > 1) {
                        byte2 = pmulutab[ 256 * bytel + byter];
                        if (byte2 != 0) {
                            if (p != 2)
                                ptrp[i + j + 1] = addtab[ ptrp[i + j + 1] + 256 * byte2];
                            else
                                ptrp[i + j + 1] ^= byte2;
                        }
                    }
                }
            }
    }

    /* The next two deal with the end byte from each polynomial, in combination with the whole
       bytes from the other polynomial */
    gettab = GETELT_FIELDINFO_8BIT(info);
    settab = SETELT_FIELDINFO_8BIT(info);
    if (ll % elts != 0) {
        bytel = ptrl[ll / elts];
        if (bytel != 0) {
            partl = 0;
            for (i = (ll / elts) * elts; i < ll; i++) {
                byte1 = gettab[bytel + 256 * (i % elts)];
                partl = settab[partl + 256 * (i  % elts + elts * byte1)];
            }
            if (partl != 0)
                for (j = 0; j < lr / elts; j++) {
                    byter = ptrr[j];
                    if (byter != 0) {
                        byte2 = pmulltab[ 256 * partl + byter];
                        if (byte2 != 0) {
                            if (p != 2)
                                ptrp[ll / elts + j] = addtab[ ptrp[ll / elts + j] + 256 * byte2];
                            else
                                ptrp[ll / elts + j] ^= byte2;
                        }
                        if (elts > 1) {
                            byte2 = pmulutab[ 256 * partl + byter];
                            if (byte2 != 0) {
                                if (p != 2)
                                    ptrp[ll / elts + j + 1] = addtab[ ptrp[ll / elts + j + 1] + 256 * byte2];
                                else
                                    ptrp[ll / elts + j + 1] ^= byte2;
                            }
                        }
                    }
                }
        }
    }
    if (lr % elts != 0) {
        byter = ptrr[lr / elts];
        if (byter != 0) {
            partr = 0;
            for (i = (lr / elts) * elts; i < lr; i++)
                partr = settab[partr + 256 * (i  % elts + elts * gettab[byter + 256 * (i % elts)])];
            if (partr != 0)
                for (i = 0; i < ll / elts; i++) {
                    bytel = ptrl[i];
                    if (bytel != 0) {
                        byte1 = pmulltab[ 256 * partr + bytel];
                        if (byte1 != 0) {
                            if (p != 2)
                                ptrp[lr / elts  + i] = addtab[ ptrp[lr / elts + i] + 256 * byte1];
                            else
                                ptrp[lr / elts + i] ^= byte1;
                        }
                        if (elts > 1) {
                            byte1 = pmulutab[ 256 * partr + bytel];
                            if (byte1 != 0) {
                                if (p != 2)
                                    ptrp[lr / elts + i + 1] = addtab[ ptrp[lr / elts + i + 1] + 256 * byte1];
                                else
                                    ptrp[lr / elts + i + 1] ^= byte1;
                            }
                        }
                    }
                }
        }
    }

    /* Finally, we have to multiply the two end bytes */
    if (ll % elts != 0 && lr % elts != 0 && partl != 0 && partr != 0) {
        byte1 = pmulltab[ partl + 256 * partr];
        if (byte1 != 0) {
            if (p != 2)
                ptrp[ll / elts + lr / elts] = addtab[ptrp[ll / elts + lr / elts] + 256 * byte1];
            else
                ptrp[ll / elts + lr / elts] ^= byte1;
        }
        if (elts > 1) {
            byte2 = pmulutab[ partl + 256 * partr];
            if (byte2 != 0) {
                if (p != 2)
                    ptrp[ll / elts + lr / elts + 1] = addtab[ptrp[ll / elts + lr / elts + 1] + 256 * byte2];
                else
                    ptrp[ll / elts + lr / elts + 1] ^= byte2;
            }
        }
    }
}

/****************************************************************************
**
*F  FuncPROD_COEFFS_VEC8BIT( <self>, <vl>, <ll>, <vr>, <lr> )
**
*/

Obj FuncPROD_COEFFS_VEC8BIT( Obj self, Obj vl, Obj ll, Obj vr, Obj lr  )
{
    Int ll1, lr1;
    UInt q;
    Obj info;
    Obj res;
    UInt lenp;
    UInt last;
    q = FIELD_VEC8BIT(vl);
    if (q != FIELD_VEC8BIT(vr)) {
        Obj  info1;
        UInt d, d1, q1, d0, q0, p, i;

        /* find a common field */
        info = GetFieldInfo8Bit(q);
        d = D_FIELDINFO_8BIT(info);
        q1 = FIELD_VEC8BIT(vr);
        info1 = GetFieldInfo8Bit(q1);
        d1 = D_FIELDINFO_8BIT(info1);
        d0 = LcmDegree(d, d1);
        p = P_FIELDINFO_8BIT(info);
        assert(p == P_FIELDINFO_8BIT(info1));
        q0 = 1;
        for (i = 0; i < d0; i++)
            q0 *= p;

        /* if the exponent is bigger than 31, overflow changes the value to 0 */
        if (d0 > 8 || q0 > 256)
            return TRY_NEXT_METHOD;
        if ((q0 > q && CALL_1ARGS(IsLockedRepresentationVector, vl) == True) ||
        (q0 > q1 && CALL_1ARGS(IsLockedRepresentationVector, vr) == True))
            return TRY_NEXT_METHOD;
        RewriteVec8Bit(vl, q0);
        RewriteVec8Bit(vr, q0);
        q = q0;
    }
    if (!ARE_INTOBJS(ll, lr))
        ErrorQuit("PROD_COEFFS_VEC8BIT: both lengths must be small integers, not a %s and a %s",
                  (Int)TNAM_OBJ(ll), (Int)TNAM_OBJ(lr));
    ll1 = INT_INTOBJ(ll);
    lr1 = INT_INTOBJ(lr);
    if (0 > ll1 || ll1 > LEN_VEC8BIT(vl))
        ErrorQuit("ProdCoeffs: given length <ll> of left argt (%d)\n is negative or longer than the argt (%d)",
                  INT_INTOBJ(ll), LEN_VEC8BIT(vl));
    if (0 > lr1 || lr1 > LEN_VEC8BIT(vr))
        ErrorQuit("ProdCoeffs: given length <lr> of right argt (%d)\n is negative or longer than the argt (%d)",
                  INT_INTOBJ(lr), LEN_VEC8BIT(vr));
    info = GetFieldInfo8Bit(q);
    if (ll1 == 0 && lr1 == 0)
        lenp = 0;
    else
        lenp = ll1 + lr1 - 1;
    res = ZeroVec8Bit(q, lenp , 1);
    ProdCoeffsVec8Bit(res, vl, ll1, vr, lr1);
    last = RightMostNonZeroVec8Bit(res);
    if (last != lenp)
        ResizeVec8Bit(res, last, 1);
    return res;
}

/****************************************************************************
**
*F  ReduceCoeffsVec8Bit( <vl>, <ll>, <vr>, <lr> )
**
*/

Obj MakeShiftedVecs( Obj v, UInt len)
{
    UInt q;
    Obj info;
    UInt elts;
    Obj shifts;
    Obj ashift;
    Obj vn, xi;
    UInt i, j;
    Obj *ffefelt;
    UInt1 *gettab;
    UInt1 *settab;
    UInt len1;
    UInt1 x;
    UInt1 *ptr;
    UInt1 *ptrs[5]; /* 5 is the largest value of elts we ever meet */
    Obj type;

    q = FIELD_VEC8BIT(v);
    assert(len <= LEN_VEC8BIT(v));
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);

    /* normalize a copy of v in vn -- normalize means monic, and actual length
       equal to length parameter */
    vn = CopyVec8Bit(v, 1);
    ResizeVec8Bit(vn, len, 0);
    len1 = (len == 0) ? 0 : RightMostNonZeroVec8Bit(vn);
    if (len1 == 0)
        ErrorReturnVoid("Zero coefficient vector for reduction", 0, 0,
                        "you can 'return;'");
    if (len1 != len) {
        ResizeVec8Bit(vn, len1, 1);
        len = len1;
    }

    gettab = GETELT_FIELDINFO_8BIT(info);
    ffefelt = FFE_FELT_FIELDINFO_8BIT(info);

    x = gettab[BYTES_VEC8BIT(vn)[(len - 1) / elts] + 256 * ((len - 1) % elts)];
    assert(x != 0);
    xi = INV(ffefelt[x]);
    MultVec8BitFFEInner(vn, vn,  xi , 1, len);
    type = TypeVec8Bit(q, 0);
    SetTypeDatObj(vn, type);

    /* Now we start to build up the result */
    shifts = NEW_PLIST(T_PLIST_TAB + IMMUTABLE, elts + 2);
    SET_ELM_PLIST(shifts, elts + 1, INTOBJ_INT(len));
    SET_ELM_PLIST(shifts, elts + 2, xi);
    SET_LEN_PLIST(shifts, elts + 2);

    /* vn can simply be stored in one place */
    SET_ELM_PLIST(shifts, (len - 1) % elts + 1, vn);
    CHANGED_BAG(shifts);

    if (elts > 1) {
        /* fill the rest up with zero vectors of suitable lengths */
        for (i = 1; i < elts; i++) {
            ashift = ZeroVec8Bit(q, len + i, 0);
            SET_ELM_PLIST(shifts, (len + i - 1) % elts + 1, ashift);
            CHANGED_BAG(shifts);
        }

        /* reload the tables, in case there was a garbage collection */
        gettab = GETELT_FIELDINFO_8BIT(info);
        settab = SETELT_FIELDINFO_8BIT(info);
        /* Now run through the entries of vn inserting them into the shifted versions */
        ptr = BYTES_VEC8BIT(vn);
        for (j = 1; j < elts; j++)
            ptrs[j] = BYTES_VEC8BIT(ELM_PLIST(shifts, (len + j - 1) % elts + 1));
        for (i = 0; i < len; i++) {
            x = gettab[*ptr + 256 * (i % elts)];
            if (x != 0) {
                for (j = 1; j < elts; j++) {
                    *(ptrs[j]) = settab[*(ptrs[j]) + 256 * ((i + j) % elts + elts * x)];
                }
            }
            if (i % elts == elts - 1)
                ptr++;
            else
                ptrs[elts - 1 - (i % elts)] ++;
        }
    }
    for (i=1; i <= elts; i++)
      MakeBagReadOnly(ELM_PLIST(shifts, i));
    MakeBagReadOnly(shifts);
    return shifts;
}

void ReduceCoeffsVec8Bit ( Obj vl, Obj vrshifted, Obj quot )
{
    UInt q;
    Obj info;
    UInt elts;
    Int i, j, jj;
    UInt1 *gettab;
    UInt1 *ptrl1, *ptrl, *ptrr, *qptr = 0;
    UInt1 x;
    UInt1 xn;
    UInt p;
    UInt lr;
    UInt lrs;
    UInt1 *multab, *settab = 0;
    UInt1 *addtab = 0;
    UInt1 * feltffe;
    UInt1 y;
    UInt ll = LEN_VEC8BIT(vl);
    Obj vrs;
    Obj *ffefelt;
    q = FIELD_VEC8BIT(vl);
    info = GetFieldInfo8Bit(q);
    p = P_FIELDINFO_8BIT(info);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    gettab = GETELT_FIELDINFO_8BIT(info);
    feltffe = FELT_FFE_FIELDINFO_8BIT(info);
    ffefelt = FFE_FELT_FIELDINFO_8BIT(info);
    if (quot) {
        settab = SETELT_FIELDINFO_8BIT(info);
        qptr = BYTES_VEC8BIT(quot);
    }
    if (p != 2)
        addtab = ADD_FIELDINFO_8BIT(info);
    ptrl = BYTES_VEC8BIT(vl);
    lr = INT_INTOBJ(ELM_PLIST(vrshifted, elts + 1));
    for (i = ll - 1, jj = ll - lr; i + 1 >= lr; i--, jj--) {
        ptrl1 = ptrl + i / elts;
        x = gettab[*ptrl1 + 256 * (i % elts)];
        if (qptr)
            qptr[jj / elts] = settab[qptr[jj / elts] + 256 * (jj % elts + elts * x)];
        if (x != 0) {

            if (p == 2)
                xn = x;
            else
                xn = feltffe[VAL_FFE(AINV(ffefelt[x]))];
            multab = SCALAR_FIELDINFO_8BIT(info) + 256 * xn;
            vrs = ELM_PLIST(vrshifted, 1 + i % elts);
            lrs = LEN_VEC8BIT(vrs);
            ptrr = BYTES_VEC8BIT(vrs) + (lrs - 1) / elts;
            for (j = (lrs - 1) / elts; j >= 0; j--) {
                y = multab[*ptrr];
                if (p == 2)
                    *ptrl1 ^= y;
                else
                    *ptrl1 = addtab[*ptrl1 + 256 * y];
                ptrl1--;
                ptrr--;
            }
            assert(! gettab[ptrl[i / elts] + 256 * (i % elts)]);
        }
    }
    if (quot) {
        MultVec8BitFFEInner(quot, quot, ELM_PLIST(vrshifted, elts + 2), 1, ll - lr + 1);
    }
    return;
}

/****************************************************************************
**
*F  FuncREDUCE_COEFFS_VEC8BIT( <self>, <vl>, <ll>, <vr>, <lr> )
**
**  NB note that these are not methods and MAY NOT return TRY_NEXT_METHOD
*/

Obj FuncMAKE_SHIFTED_COEFFS_VEC8BIT( Obj self, Obj vr, Obj lr)
{
    if (!IS_INTOBJ(lr))
        ErrorQuit("ReduceCoeffs: Length of right argument should be a small integer, not a %s",
                  (Int)TNAM_OBJ(lr), 0L);
    if (INT_INTOBJ(lr) < 0 || INT_INTOBJ(lr) > LEN_VEC8BIT(vr)) {
        ErrorQuit("ReduceCoeffs: given length <lr> of right argt (%d)\n is negative or longer than the argt (%d)",
                  INT_INTOBJ(lr), LEN_VEC8BIT(vr));
    }
    return MakeShiftedVecs(vr, INT_INTOBJ(lr));
}


Obj FuncREDUCE_COEFFS_VEC8BIT( Obj self, Obj vl, Obj ll, Obj vrshifted)
{
    UInt q;
    UInt last;
    q = FIELD_VEC8BIT(vl);
    if (q != FIELD_VEC8BIT(ELM_PLIST(vrshifted, 1)))
        return Fail;
    if (!IS_INTOBJ(ll))
        ErrorQuit("ReduceCoeffs: Length of left argument should be a small integer, not a %s",
                  (Int)TNAM_OBJ(ll), 0L);
    if (0 > INT_INTOBJ(ll) || INT_INTOBJ(ll) > LEN_VEC8BIT(vl)) {
        ErrorQuit("ReduceCoeffs: given length <ll> of left argt (%d)\n is negative or longer than the argt (%d)",
                  INT_INTOBJ(ll), LEN_VEC8BIT(vl));
    }
    ResizeVec8Bit(vl, INT_INTOBJ(ll), 0);
    ReduceCoeffsVec8Bit(vl,  vrshifted, (Obj)0);
    last = RightMostNonZeroVec8Bit(vl);
    ResizeVec8Bit(vl, last, 1);
    return INTOBJ_INT(last);
}

Obj FuncQUOTREM_COEFFS_VEC8BIT( Obj self, Obj vl, Obj ll, Obj vrshifted)
{
    UInt q;
    Obj rem, quot, ret, info;
    UInt elts;
    Int ill, lr;
    Obj type;

    q = FIELD_VEC8BIT(vl);
    if (q != FIELD_VEC8BIT(ELM_PLIST(vrshifted, 1)))
        return Fail;
    if (!IS_INTOBJ(ll))
        ErrorQuit("QuotRemCoeffs: Length of left argument should be a small integer, not a %s",
                  (Int)TNAM_OBJ(ll), 0L);
    if (0 > INT_INTOBJ(ll) || INT_INTOBJ(ll) > LEN_VEC8BIT(vl)) {
        ErrorQuit("QuotRemCoeffs: given length <ll> of left argt (%d)\n is negative or longer than the argt (%d)",
                  INT_INTOBJ(ll), LEN_VEC8BIT(vl));
    }
    ill = INT_INTOBJ(ll);
    rem = CopyVec8Bit(vl, 1);
    info = GetFieldInfo8Bit(q);
    ResizeVec8Bit(rem, ill, 0);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    lr = INT_INTOBJ(ELM_PLIST(vrshifted, elts + 1));
    quot = NewBag(T_DATOBJ, SIZE_VEC8BIT(ill - lr + 1, elts));
    type = TypeVec8Bit(q, 1);
    SetTypeDatObj(quot, type);
    SET_FIELD_VEC8BIT(quot, q);
    SET_LEN_VEC8BIT(quot, ill - lr + 1);
    ReduceCoeffsVec8Bit(rem,  vrshifted, quot);
    ret = NEW_PLIST(T_PLIST_TAB, 2);
    SET_LEN_PLIST(ret, 2);
    SET_ELM_PLIST(ret, 1, quot);
    SET_ELM_PLIST(ret, 2, rem);
    CHANGED_BAG(ret);
    return ret;
}


/****************************************************************************
**
*F  Obj SemiechelonListVec8Bits( <mat>, <transformationneeded> )
**
**
** This is essentially a method for SemiEchelonMat or SemiEchelonMatTransformation
**
** <mat> is assumed by this point to be a list of mutable 8 bit vectors over
** the same field, which can be overwritten if necessary
*/

static UInt RNheads, RNvectors, RNcoeffs, RNrelns;


Obj SemiEchelonListVec8Bits( Obj mat, UInt TransformationsNeeded )
{
    UInt nrows, ncols;
    UInt i, j, h;
    /*UInt block; */
    Obj heads, vectors, coeffs = 0, relns = 0;
    UInt nvecs, nrels = 0;
    Obj coeffrow = 0;
    Obj row;
    Obj res;
    UInt q, elts;
    Obj info;
    UInt1 *settab, *convtab, *gettab;
    Obj *convtab1;
    UInt1 zero, one;
    UInt1 x = 0;
    UInt1 *rowp;
    UInt1 byte;
    Obj y;
    Obj type;

    nrows = LEN_PLIST(mat);
    ncols = LEN_VEC8BIT(ELM_PLIST(mat, 1));

    /* Find the field info */
    q = FIELD_VEC8BIT(ELM_PLIST(mat, 1));
    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);

    /* Get the Felt numbers for zero and one */
    convtab = FELT_FFE_FIELDINFO_8BIT(info);
    zero = convtab[0];
    one = convtab[1];

    /* Set up the lists for the results */
    heads = NEW_PLIST(T_PLIST_CYC, ncols);
    SET_LEN_PLIST(heads, ncols);
    vectors = NEW_PLIST(T_PLIST_TAB_RECT, nrows);
    SET_LEN_PLIST(vectors, 0);
    nvecs = 0;
    if (TransformationsNeeded) {
        coeffs = NEW_PLIST(T_PLIST_TAB_RECT, nrows);
        SET_LEN_PLIST(coeffs, 0);
        relns  = NEW_PLIST(T_PLIST_TAB_RECT, nrows);
        SET_LEN_PLIST(relns, 0);
        nrels = 0;
    }
    for (i = 1; i <= ncols; i++)
        SET_ELM_PLIST(heads, i, INTOBJ_INT(0));

    /* Main loop starts here */
    for (i = 1; i <= nrows; i++) {
        row = ELM_PLIST(mat, i);
        if (TransformationsNeeded) {
            coeffrow = NewBag(T_DATOBJ, SIZE_VEC8BIT(nrows, elts));
            SET_LEN_VEC8BIT(coeffrow, nrows);
            type = TypeVec8Bit(q, 1);
            SetTypeDatObj(coeffrow, type);
            SET_FIELD_VEC8BIT(coeffrow, q);
            CHANGED_BAG(coeffrow);

            /* No garbage collection risk from here */
            settab = SETELT_FIELDINFO_8BIT(info);
            BYTES_VEC8BIT(coeffrow)[(i - 1) / elts] = settab[256 * ((i - 1) % elts + elts * one)];
        }
        /* No garbage collection risk from here */
        gettab = GETELT_FIELDINFO_8BIT(info);
        convtab1 = FFE_FELT_FIELDINFO_8BIT(info);

        /* Clear out the current row */
        for (j = 1; j <= ncols; j++) {
            h = INT_INTOBJ(ELM_PLIST(heads, j));
            if (h != 0) {
                byte = BYTES_VEC8BIT(row)[(j - 1) / elts];
                if (byte && zero != (x = gettab[ byte + 256 * ((j - 1) % elts)])) {
                    y = AINV(convtab1[x]);
                    AddVec8BitVec8BitMultInner(row, row, ELM_PLIST(vectors, h), y, 1, ncols);
                    if (TransformationsNeeded)
                        AddVec8BitVec8BitMultInner(coeffrow, coeffrow, ELM_PLIST(coeffs, h), y, 1, nrows);
                }
            }
        }
        j = 1;
        rowp = BYTES_VEC8BIT(row);
        while (j <= ncols && !*rowp) {
            j += elts;
            rowp++;
        }
        while (j <= ncols && (zero == (x = gettab[ *rowp + 256 * ((j - 1) % elts)])))
            j++;

        if (j <= ncols) {
            y = INV(convtab1[x]);
            MultVec8BitFFEInner(row, row, y, 1, ncols);
            SET_ELM_PLIST(vectors, ++nvecs, row);
            CHANGED_BAG(vectors);
            SET_LEN_PLIST(vectors, nvecs);
            SET_ELM_PLIST(heads, j, INTOBJ_INT(nvecs));
            if (TransformationsNeeded) {
                MultVec8BitFFEInner(coeffrow, coeffrow, y, 1, nrows);
                SET_ELM_PLIST(coeffs, nvecs, coeffrow);
                CHANGED_BAG(coeffs);
                SET_LEN_PLIST(coeffs, nvecs);
            }
            /* garbage collection OK again after here */
        } else if (TransformationsNeeded) {
            SET_ELM_PLIST(relns, ++nrels, coeffrow);
            CHANGED_BAG(relns);
            SET_LEN_PLIST(relns, nrels);
        }
        TakeInterrupt();
    }
    if (RNheads == 0) {
        RNheads = RNamName("heads");
        RNvectors = RNamName("vectors");
    }
    res = NEW_PREC(TransformationsNeeded ? 4 : 2);
    AssPRec(res, RNheads, heads);
    AssPRec(res, RNvectors, vectors);
    if (LEN_PLIST(vectors) == 0)
        RetypeBag(vectors, T_PLIST_EMPTY);
    if (TransformationsNeeded) {
        if (RNcoeffs == 0) {
            RNcoeffs = RNamName("coeffs");
            RNrelns = RNamName("relations");
        }
        AssPRec(res, RNcoeffs, coeffs);
        if (LEN_PLIST(coeffs) == 0)
            RetypeBag(coeffs, T_PLIST_EMPTY);
        AssPRec(res, RNrelns, relns);
        if (LEN_PLIST(relns) == 0)
            RetypeBag(relns, T_PLIST_EMPTY);
    }
    SortPRecRNam(res, 0);
    return res;
}


/****************************************************************************
**
*F  UInt TriangulizeListVec8Bits( <mat>, <clearup>, <deterp> ) -- returns the rank
**
*/

UInt TriangulizeListVec8Bits( Obj mat, UInt clearup, Obj *deterp)
{
    UInt nrows;
    UInt ncols;
    UInt workcol;
    UInt workrow;
    UInt rank;
    Obj row, row2;
    UInt byte;
    UInt j;
    Obj info;
    UInt elts;
    UInt1 x = 0;
    UInt1 *gettab, *getcol;
    Obj deter = 0;
    UInt sign = 0;
    Obj *convtab;
    Obj y;
    UInt1 x2;

    nrows = LEN_PLIST(mat);
    row = ELM_PLIST(mat, 1);
    ncols = LEN_VEC8BIT(row);
    rank = 0;
    info = GetFieldInfo8Bit(FIELD_VEC8BIT(row));
    elts = ELS_BYTE_FIELDINFO_8BIT(info);

    /* Nothing here can cause a garbage collection */

    gettab = GETELT_FIELDINFO_8BIT(info);
    convtab = FFE_FELT_FIELDINFO_8BIT(info);

    if (deterp != (Obj *) 0) {
        deter = ONE(convtab[1]);
        sign = 1;
    }
    for (workcol = 1; workcol <= ncols; workcol++) {
        byte = (workcol - 1) / elts;
        getcol = gettab + 256 * ((workcol - 1) % elts);

        for (workrow = rank + 1; workrow <= nrows; workrow ++) {
            row = ELM_PLIST(mat, workrow);
            x = getcol[BYTES_VEC8BIT(row)[byte]];
            if (x)
                break;
        }
        if (workrow <= nrows) {
            rank++;
            y = convtab[x];
            MultVec8BitFFEInner(row, row, INV(y), workcol, ncols);
            if (deterp)
                deter = PROD(deter, y);

            if (workrow != rank) {
                if (deterp)
                    sign = -sign;
                SET_ELM_PLIST(mat, workrow, ELM_PLIST(mat, rank));
                SET_ELM_PLIST(mat, rank, row);
            }
            if (clearup)
                for (j = 1; j < rank; j ++) {
                    row2 = ELM_PLIST(mat, j);
                    if ((x2 =  getcol[BYTES_VEC8BIT(row2)[byte]]))
                        AddVec8BitVec8BitMultInner(row2, row2, row, AINV(convtab[x2]), workcol, ncols);
                }
            for (j = workrow + 1; j <= nrows; j++) {
                row2 = ELM_PLIST(mat, j);
                if ((x2 =  getcol[BYTES_VEC8BIT(row2)[byte]]))
                    AddVec8BitVec8BitMultInner(row2, row2, row, AINV(convtab[x2]), workcol, ncols);
            }
        }
        if (TakeInterrupt()) {
            gettab = GETELT_FIELDINFO_8BIT(info);
            convtab = FFE_FELT_FIELDINFO_8BIT(info);
        }
    }
    if (deterp) {
        if (rank < nrows)
            deter = ZERO(deter);
        else if (sign == -1)
            deter = AINV(deter);
        *deterp = deter;
    }
    return rank;
}


/****************************************************************************
**
*F  FuncSEMIECHELON_LIST_VEC8BITS( <self>, <mat> )
**
**  Method for SemiEchelonMat for plain lists of 8 bit vectors
**
** Method selection can guarantee us a plain list of vectors in same char
*/

Obj FuncSEMIECHELON_LIST_VEC8BITS( Obj self, Obj mat )
{
    UInt i, len, width;
    Obj row;
    UInt q;
    /* check argts */
    len = LEN_PLIST(mat);
    if (!len)
        return TRY_NEXT_METHOD;
    row = ELM_PLIST(mat, 1);
    if (!IS_VEC8BIT_REP(row))
        return TRY_NEXT_METHOD;
    q = FIELD_VEC8BIT(row);
    width = LEN_VEC8BIT(row);
    if (width == 0)
        return TRY_NEXT_METHOD;
    for (i = 2; i <= len; i++) {
        row = ELM_PLIST(mat, i);
        if (!IS_VEC8BIT_REP(row) || FIELD_VEC8BIT(row) != q || LEN_VEC8BIT(row) != width) {
            return TRY_NEXT_METHOD;
        }
    }
    return SemiEchelonListVec8Bits(mat, 0);
}

/****************************************************************************
**
*F  FuncSEMIECHELON_LIST_VEC8BITS_TRANSFORMATIONS( <self>, <mat> )
**
**  Method for SemiEchelonMatTransformations for plain lists of 8 bit vectors
**
** Method selection can guarantee us a plain list of vectors in same characteristic
*/

Obj FuncSEMIECHELON_LIST_VEC8BITS_TRANSFORMATIONS( Obj self, Obj mat )
{
    UInt i, len;
    Obj row;
    UInt q;
    UInt width;
    /* check argts */
    len = LEN_PLIST(mat);
    if (!len)
        return TRY_NEXT_METHOD;
    row = ELM_PLIST(mat, 1);
    if (!IS_VEC8BIT_REP(row))
        return TRY_NEXT_METHOD;
    q = FIELD_VEC8BIT(row);
    width = LEN_VEC8BIT(row);
    if (width == 0)
        return TRY_NEXT_METHOD;
    for (i = 2; i <= len; i++) {
        row = ELM_PLIST(mat, i);
        if (!IS_VEC8BIT_REP(row) ||
        FIELD_VEC8BIT(row) != q ||
        LEN_VEC8BIT(row) != width) {
            return TRY_NEXT_METHOD;
        }
    }
    return SemiEchelonListVec8Bits(mat, 1);
}


/****************************************************************************
**
*F  FuncTRIANGULIZE_LIST_VEC8BITS( <self>, <mat> )
**
**  Method for TriangulizeMat for plain lists of 8 bit vectors
**
** Method selection can guarantee us a plain list of vectors in same characteristic
*/

Obj FuncTRIANGULIZE_LIST_VEC8BITS( Obj self, Obj mat )
{
    UInt i, len, width;
    Obj row;
    UInt q;
    /* check argts */
    len = LEN_PLIST(mat);
    if (!len)
        return TRY_NEXT_METHOD;
    row = ELM_PLIST(mat, 1);
    if (!IS_VEC8BIT_REP(row))
        return TRY_NEXT_METHOD;
    q = FIELD_VEC8BIT(row);
    width = LEN_VEC8BIT(row);
    if (width == 0)
        return TRY_NEXT_METHOD;
    for (i = 2; i <= len; i++) {
        row = ELM_PLIST(mat, i);
        if (!IS_MUTABLE_OBJ(row) || !IS_VEC8BIT_REP(row)
            || FIELD_VEC8BIT(row) != q || LEN_VEC8BIT(row) != width) {
            return TRY_NEXT_METHOD;
        }
    }
    TriangulizeListVec8Bits(mat, 1, (Obj *) 0);
    return (Obj) 0;
}

/****************************************************************************
**
*F  FuncRANK_LIST_VEC8BITS( <self>, <mat> )
**
**  Method for RankMatDestructive for plain lists of 8 bit vectors
**
** Method selection can guarantee us a plain list of vectors in same characteristic
*/

Obj FuncRANK_LIST_VEC8BITS( Obj self, Obj mat )
{
    UInt i, len, width;
    Obj row;
    UInt q;
    /* check argts */
    len = LEN_PLIST(mat);
    if (!len)
        return TRY_NEXT_METHOD;
    row = ELM_PLIST(mat, 1);
    if (!IS_VEC8BIT_REP(row))
        return TRY_NEXT_METHOD;
    q = FIELD_VEC8BIT(row);
    width = LEN_VEC8BIT(row);
    if (width == 0)
        return TRY_NEXT_METHOD;
    for (i = 2; i <= len; i++) {
        row = ELM_PLIST(mat, i);
        if (!IS_VEC8BIT_REP(row) || FIELD_VEC8BIT(row) != q
            || LEN_VEC8BIT(row) != width) {
            return TRY_NEXT_METHOD;
        }
    }
    return INTOBJ_INT(TriangulizeListVec8Bits(mat, 0, (Obj *) 0));
}

/****************************************************************************
**
*F  FuncDETERMINANT_LIST_VEC8BITS( <self>, <mat> )
**
**  Method for DeterminantMatDestructive for plain lists of 8 bit vectors
**
** Method selection can guarantee us a plain list of vectors in same characteristic
*/

Obj FuncDETERMINANT_LIST_VEC8BITS( Obj self, Obj mat )
{
    UInt i, len, width;
    Obj row;
    UInt q;
    Obj det;
    /* check argts */
    len = LEN_PLIST(mat);
    if (!len)
        return TRY_NEXT_METHOD;
    row = ELM_PLIST(mat, 1);
    if (!IS_VEC8BIT_REP(row))
        return TRY_NEXT_METHOD;
    q = FIELD_VEC8BIT(row);
    width = FIELD_VEC8BIT(row);
    if (width == 0)
        return TRY_NEXT_METHOD;
    for (i = 2; i <= len; i++) {
        row = ELM_PLIST(mat, i);
        if (!IS_VEC8BIT_REP(row) || FIELD_VEC8BIT(row) != q ||
            LEN_VEC8BIT(row) != width) {
            return TRY_NEXT_METHOD;
        }
    }
    TriangulizeListVec8Bits(mat, 0, &det);
    return det;
}




/****************************************************************************
**
*F  Cmp_MAT8BIT_MAT8BIT( <ml>, <mr> )   compare matrices
**
**  Assumes the matrices are over compatible fields
*/

Int Cmp_MAT8BIT_MAT8BIT( Obj ml, Obj mr)
{
    UInt l1, l2, l, i;
    Int c;
    l1 = LEN_MAT8BIT(ml);
    l2 = LEN_MAT8BIT(mr);
    l = (l1 < l2) ? l1 : l2;
    for (i = 1; i <= l; i++) {
        c = CmpVec8BitVec8Bit(ELM_MAT8BIT(ml, i), ELM_MAT8BIT(mr, i));
        if (c != 0)
            return c;
    }
    if (l1 < l2)
        return -1;
    if (l1 > l2)
        return 1;
    return 0;

}

/****************************************************************************
**
*F  FuncEQ_MAT8BIT_MAT8BIT( <ml>, <mr> )   compare matrices
*/

Obj FuncEQ_MAT8BIT_MAT8BIT( Obj self, Obj ml, Obj mr)
{
    if (LEN_MAT8BIT(ml) != LEN_MAT8BIT(mr))
        return False;
    if (LEN_MAT8BIT(ml) == 0)
        return True;
    if (FIELD_VEC8BIT(ELM_MAT8BIT(ml, 1)) != FIELD_VEC8BIT(ELM_MAT8BIT(mr, 1)))
        return EqListList(ml, mr) ? True : False;
    return (0 == Cmp_MAT8BIT_MAT8BIT(ml, mr)) ? True : False;
}

/****************************************************************************
**
*F  FuncLT_MAT8BIT_MAT8BIT( <ml>, <mr> )   compare matrices
*/

Obj FuncLT_MAT8BIT_MAT8BIT( Obj self, Obj ml, Obj mr)
{
    if (LEN_MAT8BIT(ml) == 0)
        return (LEN_MAT8BIT(mr) != 0) ? True : False;
    if (LEN_MAT8BIT(mr) == 0)
        return False;
    if (FIELD_VEC8BIT(ELM_MAT8BIT(ml, 1)) != FIELD_VEC8BIT(ELM_MAT8BIT(mr, 1)))
        return LtListList(ml, mr) ? True : False;
    return (Cmp_MAT8BIT_MAT8BIT(ml, mr) < 0) ? True : False;
}


/****************************************************************************
**
*F  FuncTRANSPOSED_MAT8BIT( <self>, <mat>) Fully mutable results
**
*/
Obj FuncTRANSPOSED_MAT8BIT( Obj self, Obj mat)
{
    UInt l, w;
    Obj tra, row;
    Obj r1;
    UInt1 vals[BIPEB];
    UInt val;
    UInt imod, nrb, nstart;
    UInt i, j, k, n, q, elts;
    UInt1 * ptr;
    Obj info;
    UInt1 *gettab = 0, *settab = 0;
    Obj type;

    /* check argument */
    if (TNUM_OBJ(mat) != T_POSOBJ) {
        mat = ErrorReturnObj(
            "TRANSPOSED_MAT8BIT: Need compressed matrix\n",
            0, 0,
            "You can return such matrix with 'return mat;'\n");
    }
    /* we will give result same type as mat */

    /* we assume here that there is a first row  -- a zero row mat8bit is a bad thing*/
    r1 = ELM_MAT8BIT(mat, 1);

    l = LEN_MAT8BIT(mat);
    w = LEN_VEC8BIT(r1);


    tra = NewBag(T_POSOBJ, sizeof(Obj) * (w + 2));
    q = FIELD_VEC8BIT(r1);
    type = TypeMat8Bit(q, 1);
    TYPE_POSOBJ(tra) = type;

    SET_LEN_MAT8BIT(tra, w);

    info = GetFieldInfo8Bit(q);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    nrb = (w + elts - 1) / elts;

    /* create new matrix */
    for (i = 1; i <= w; i++) {
        row = NewBag(T_DATOBJ, SIZE_VEC8BIT(l, elts));
        SET_LEN_VEC8BIT(row, l);
        SET_FIELD_VEC8BIT(row, q);
        type = TypeVec8BitLocked(q, 1);
        SetTypeDatObj(row, type);
        SET_ELM_MAT8BIT(tra, i, row);
        CHANGED_BAG(tra);
    }

    if (elts > 1) {
        gettab = GETELT_FIELDINFO_8BIT(info);
        settab = SETELT_FIELDINFO_8BIT(info);
    }

    /* set entries */
    /* run over elts row chunks of the original matrix */
    for (i = 1; i <= l; i += elts) {
        imod = (i - 1) / elts;

        /* run through these rows in chunks, extract the bytes corresponding to an
         elts x elts submatrix into vals */
        for (n = 0; n < nrb; n++) {
            for (j = 0; j < elts; j++) {
                if ((i + j) > l) {

                    vals[j] = 0; /* outside matrix */

                } else {
                    vals[j] = BYTES_VEC8BIT(ELM_MAT8BIT(mat, i + j))[n];
                }
            }

            /* write transposed values in new matrix */
            nstart = n * elts + 1;
            for (j = 0; j < elts; j++) { /* bit number = Row in transpose */
                if ((nstart + j) <= w) {

                    /* still within matrix */
                    if (elts > 1) {
                        val = 0;
                        for (k = 0; k < elts; k++) {
                            val = settab[val + 256 * (k + elts * gettab[vals[k] + 256 * j])];
                        }
                    } else
                        val = vals[0];

                    /* set entry */
                    ptr = BYTES_VEC8BIT(ELM_GF2MAT(tra, nstart + j)) + imod;
                    *ptr = val;
                }
            }
        }
    }
    return tra;
}


/****************************************************************************
**
*F  FuncKRONECKERPRODUCT_MAT8BIT_MAT8BIT( <self>, <matl>, <matr>)
**
*/
Obj FuncKRONECKERPRODUCT_MAT8BIT_MAT8BIT( Obj self, Obj matl, Obj matr)
{
    UInt nrowl, nrowr, ncoll, ncolr, ncol, p, q, i, j, k, l, s, zero,
    mutable, elts;
    Obj mat, type, row, info, shift[5];
    UInt1 *getelt, *setelt, *scalar, *add, *datar, *data;

    nrowl = LEN_MAT8BIT(matl);
    nrowr = LEN_MAT8BIT(matr);
    ncoll = LEN_VEC8BIT(ELM_MAT8BIT(matl, 1));
    ncolr = LEN_VEC8BIT(ELM_MAT8BIT(matr, 1));
    q = FIELD_VEC8BIT(ELM_MAT8BIT(matl, 1));
    if (q != FIELD_VEC8BIT(ELM_MAT8BIT(matr, 1)))
        return TRY_NEXT_METHOD;

    mutable = IS_MUTABLE_OBJ(matl) || IS_MUTABLE_OBJ(matr);

    info = GetFieldInfo8Bit(q);
    p = P_FIELDINFO_8BIT(info);
    elts = ELS_BYTE_FIELDINFO_8BIT(info);
    zero = FELT_FFE_FIELDINFO_8BIT(info)[0];

    /* create a matrix */
    mat = NewBag(T_POSOBJ, sizeof(Obj) * (nrowl*nrowr + 2));
    SET_LEN_MAT8BIT(mat, nrowl*nrowr);
    TYPE_POSOBJ(mat) = TypeMat8Bit(q, mutable);
    type = TypeVec8BitLocked(q, mutable);

    /* allocate 0 matrix */
    for (i = 1; i <= nrowl*nrowr; i++) {
        row = ZeroVec8Bit(q, ncoll * ncolr, mutable);
        SetTypeDatObj(row, type); /* locked type */
        SET_ELM_MAT8BIT(mat, i, row);
        CHANGED_BAG(mat);
    }

    /* allocate data for shifts of rows of matr */
    for (i = 0; i < elts; i++) {
        shift[i] = NewBag(T_DATOBJ, ncolr / elts + 200 + sizeof(Obj));
    }

    /* allocation is done. speed up operations by getting lookup tables */
    getelt = GETELT_FIELDINFO_8BIT(info);
    setelt = SETELT_FIELDINFO_8BIT(info);
    scalar = SCALAR_FIELDINFO_8BIT(info);
    add = ADD_FIELDINFO_8BIT(info);

    /* fill in matrix */
    for (j = 1; j <= nrowr; j++) {
        /* create shifts of rows of matr */
        for (i = 0; i < elts; i++) {
            data = (UInt1 *) ADDR_OBJ(shift[i]);
            datar = BYTES_VEC8BIT(ELM_MAT8BIT(matr, j));
            for (k = 0; k < ncolr; k++)
                data[(k + i) / elts] = setelt[data[(k + i) / elts] + 256 * ((k + i) % elts + getelt[datar[k / elts] + 256 * (k % elts)] * elts)];
        }
        for (i = 1; i <= nrowl; i++) {
            data = BYTES_VEC8BIT(ELM_MAT8BIT(mat, (i - 1) * nrowr + j));
            ncol = 0;
            for (k = 0; k < ncoll; k++) {
                s = getelt[BYTES_VEC8BIT(ELM_MAT8BIT(matl, i))[k / elts] + 256 * (k % elts)];
                l = 0;
                if (s != zero) {
                    /* append s*shift[ncol%elts] to data */
                    datar = (UInt1 *) ADDR_OBJ(shift[ncol % elts]);
                    if (ncol % elts) {
                        if (p == 2)
                            data[-1] ^= scalar[*datar++ + 256 * s];
                        else
                            data[-1] = add[data[-1] + 256 * scalar[*datar++ + 256 * s]];
                        l = elts - ncol % elts;
                    }
                    for (; l < ncolr; l += elts)
                        * data++ = scalar[*datar++ + 256 * s];
                } else {
                    if (ncol % elts)
                        l = elts - ncol % elts;
                    data += (ncolr + elts - 1 - l) / elts;
                }
                ncol += ncolr;
            }
        }
    }

    return mat;
}


/****************************************************************************
**
*f * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * * */




/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "CONV_VEC8BIT", 2, "list,q",
      FuncCONV_VEC8BIT, "src/vec8bit.c:CONV_VEC8BIT" },

    { "COPY_VEC8BIT", 2, "list,q",
      FuncCOPY_VEC8BIT, "src/vec8bit.c:COPY_VEC8BIT" },
      
    { "PLAIN_VEC8BIT", 1, "gfqvec",
      FuncPLAIN_VEC8BIT, "src/vec8bit.c:PLAIN_VEC8BIT" },

    { "LEN_VEC8BIT", 1, "gfqvec",
      FuncLEN_VEC8BIT, "src/vec8bit.c:LEN_VEC8BIT" },

    { "ELM0_VEC8BIT", 2, "gfqvec, pos",
      FuncELM0_VEC8BIT, "src/vec8bit.c:ELM0_VEC8BIT" },

    { "ELM_VEC8BIT", 2, "gfqvec, pos",
      FuncELM_VEC8BIT, "src/vec8bit.c:ELM_VEC8BIT" },

    { "ELMS_VEC8BIT", 2, "gfqvec, poss",
      FuncELMS_VEC8BIT, "src/vec8bit.c:ELMS_VEC8BIT" },

    { "ELMS_VEC8BIT_RANGE", 2, "gfqvec, range",
      FuncELMS_VEC8BIT_RANGE, "src/vec8bit.c:ELMS_VEC8BIT_RANGE" },

    { "ASS_VEC8BIT", 3, "gfqvec, pos, elm",
      FuncASS_VEC8BIT, "src/vec8bit.c:ASS_VEC8BIT" },

    { "UNB_VEC8BIT", 2, "gfqvec, pos",
      FuncUNB_VEC8BIT, "src/vec8bit.c:UNB_VEC8BIT" },

    { "Q_VEC8BIT", 1, "gfqvec",
      FuncQ_VEC8BIT, "src/vec8bit.c:Q_VEC8BIT" },

    { "SHALLOWCOPY_VEC8BIT", 1, "gfqvec",
      FuncSHALLOWCOPY_VEC8BIT, "src/vec8bit.c:SHALLOWCOPY_VEC8BIT" },

    { "SUM_VEC8BIT_VEC8BIT", 2, "gfqvecl, gfqvecr",
      FuncSUM_VEC8BIT_VEC8BIT, "src/vec8bit.c:SUM_VEC8BIT_VEC8BIT" },

    { "DIFF_VEC8BIT_VEC8BIT", 2, "gfqvecl, gfqvecr",
      FuncDIFF_VEC8BIT_VEC8BIT, "src/vec8bit.c:DIFF_VEC8BIT_VEC8BIT" },

    { "PROD_VEC8BIT_FFE", 2, "gfqvec, gfqelt",
      FuncPROD_VEC8BIT_FFE, "src/vec8bit.c:PROD_VEC8BIT_FFE" },

    { "PROD_FFE_VEC8BIT", 2, "gfqelt, gfqvec",
      FuncPROD_FFE_VEC8BIT, "src/vec8bit.c:PROD_FFE_VEC8BIT" },
    
    { "AINV_VEC8BIT_MUTABLE", 1, "gfqvec",
      FuncAINV_VEC8BIT_MUTABLE, "src/vec8bit.c:AINV_VEC8BIT_MUTABLE" },

    { "AINV_VEC8BIT_IMMUTABLE", 1, "gfqvec",
      FuncAINV_VEC8BIT_IMMUTABLE, "src/vec8bit.c:AINV_VEC8BIT_IMMUTABLE" },

    { "AINV_VEC8BIT_SAME_MUTABILITY", 1, "gfqvec",
      FuncAINV_VEC8BIT_SAME_MUTABILITY, "src/vec8bit.c:AINV_VEC8BIT_SAME_MUTABILITY" },

    { "ZERO_VEC8BIT", 1, "gfqvec",
      FuncZERO_VEC8BIT, "src/vec8bit.c:ZERO_VEC8BIT" },
    
    { "ZERO_VEC8BIT_2", 2, "q,len",
      FuncZERO_VEC8BIT_2, "src/vec8bit.c:ZERO_VEC8BIT_2" },

    { "EQ_VEC8BIT_VEC8BIT", 2, "gfqvecl, gfqvecr",
      FuncEQ_VEC8BIT_VEC8BIT, "src/vec8bit.c:EQ_VEC8BIT_VEC8BIT" },

    { "LT_VEC8BIT_VEC8BIT", 2, "gfqvecl, gfqvecr",
      FuncLT_VEC8BIT_VEC8BIT, "src/vec8bit.c:LT_VEC8BIT_VEC8BIT" },

    { "PROD_VEC8BIT_VEC8BIT", 2, "gfqvecl, gfqvecr",
      FuncPROD_VEC8BIT_VEC8BIT, "src/vec8bit.c:PROD_VEC8BIT_VEC8BIT" },

    { "DISTANCE_VEC8BIT_VEC8BIT", 2, "gfqvecl, gfqvecr",
      FuncDISTANCE_VEC8BIT_VEC8BIT, "src/vec8bit.c:DISTANCE_VEC8BIT_VEC8BIT" },

    {"ADD_ROWVECTOR_VEC8BITS_5", 5, "gfqvecl, gfqvecr, mul, from, to",
      FuncADD_ROWVECTOR_VEC8BITS_5, "src/vec8bit.c:ADD_ROWVECTOR_VEC8BITS_5" },

    {"ADD_ROWVECTOR_VEC8BITS_3", 3, "gfqvecl, gfqvecr, mul",
      FuncADD_ROWVECTOR_VEC8BITS_3, "src/vec8bit.c:ADD_ROWVECTOR_VEC8BITS_3" },

    {"ADD_ROWVECTOR_VEC8BITS_2", 2, "gfqvecl, gfqvecr",
      FuncADD_ROWVECTOR_VEC8BITS_2, "src/vec8bit.c:ADD_ROWVECTOR_VEC8BITS_2" },

    {"MULT_ROWVECTOR_VEC8BITS", 2, "gfqvec, ffe",
      FuncMULT_ROWVECTOR_VEC8BITS, "src/vec8bit.c:MULT_ROWVECTOR_VEC8BITS" },

    {"POSITION_NONZERO_VEC8BIT", 2, "vec8bit, zero",
       FuncPOSITION_NONZERO_VEC8BIT, "src/vec8bit.c:POSITION_NONZERO_VEC8BIT" },

    {"POSITION_NONZERO_VEC8BIT3", 3, "vec8bit, zero, from",
       FuncPOSITION_NONZERO_VEC8BIT3, "src/vec8bit.c:POSITION_NONZERO_VEC8BIT3" },

    {"APPEND_VEC8BIT", 2, "vec8bitl, vec8bitr",
       FuncAPPEND_VEC8BIT, "src/vec8bit.c:APPEND_VEC8BIT" },

    {"NUMBER_VEC8BIT", 1, "gfqvec",
       FuncNUMBER_VEC8BIT, "src/vec8bit.c:NUMBER_VEC8BIT" },

    {"PROD_VEC8BIT_MATRIX", 2, "gfqvec, mat",
       FuncPROD_VEC8BIT_MATRIX, "src/vec8bit.c:PROD_VEC8BIT_MATRIX" },

    {"CONV_MAT8BIT", 2, "list, q",
       FuncCONV_MAT8BIT, "src/vec8bit.c:CONV_MAT8BIT" },

    {"PLAIN_MAT8BIT", 1, "mat",
       FuncPLAIN_MAT8BIT, "src/vec8bit.c:PLAIN_MAT8BIT" },

    {"PROD_VEC8BIT_MAT8BIT", 2, "vec, mat",
       FuncPROD_VEC8BIT_MAT8BIT, "src/vec8bit.c:PROD_VEC8BIT_MAT8BIT" },

    {"PROD_MAT8BIT_VEC8BIT", 2, "mat, vec",
       FuncPROD_MAT8BIT_VEC8BIT, "src/vec8bit.c:PROD_MAT8BIT_VEC8BIT" },

    {"PROD_MAT8BIT_MAT8BIT", 2, "matl, matr",
       FuncPROD_MAT8BIT_MAT8BIT, "src/vec8bit.c:PROD_MAT8BIT_MAT8BIT" },

    {"INV_MAT8BIT_MUTABLE", 1, "mat",
       FuncINV_MAT8BIT_MUTABLE, "src/vec8bit.c:INV_MAT8BIT_MUTABLE" },

    {"INV_MAT8BIT_SAME_MUTABILITY", 1, "mat",
       FuncINV_MAT8BIT_SAME_MUTABILITY, "src/vec8bit.c:INV_MAT8BIT_SAME_MUTABILITY" },

    {"INV_MAT8BIT_IMMUTABLE", 1, "mat",
       FuncINV_MAT8BIT_IMMUTABLE, "src/vec8bit.c:INV_MAT8BIT_IMMUTABLE" },
    
    {"ASS_MAT8BIT", 3, "mat, pos, obj",
       FuncASS_MAT8BIT, "src/vec8bit.c:ASS_MAT8BIT" },

    {"SUM_MAT8BIT_MAT8BIT", 2, "ml, mr",
       FuncSUM_MAT8BIT_MAT8BIT, "src/vec8bit.c:SUM_MAT8BIT_MAT8BIT" },
    
    {"DIFF_MAT8BIT_MAT8BIT", 2, "ml, mr",
       FuncDIFF_MAT8BIT_MAT8BIT, "src/vec8bit.c:DIFF_MAT8BIT_MAT8BIT" },

    {"ADD_COEFFS_VEC8BIT_3", 3, "vec1, vec2, mult",
       FuncADD_COEFFS_VEC8BIT_3, "src/vec8bit.c:ADD_COEFFS_VEC8BIT_3" },

    {"ADD_COEFFS_VEC8BIT_2", 2, "vec1, vec2",
       FuncADD_COEFFS_VEC8BIT_2, "src/vec8bit.c:ADD_COEFFS_VEC8BIT_2" },

    {"SHIFT_VEC8BIT_LEFT", 2, "vec, amount",
       FuncSHIFT_VEC8BIT_LEFT, "src/vec8bit.c:SHIFT_VEC8BIT_LEFT" },

    {"SHIFT_VEC8BIT_RIGHT", 3, "vec, amount, zero",
       FuncSHIFT_VEC8BIT_RIGHT, "src/vec8bit.c:SHIFT_VEC8BIT_RIGHT" },

    {"RESIZE_VEC8BIT", 2, "vec, newsize",
       FuncRESIZE_VEC8BIT, "src/vec8bit.c:RESIZE_VEC8BIT" },

    {"RIGHTMOST_NONZERO_VEC8BIT", 1, "vec",
       FuncRIGHTMOST_NONZERO_VEC8BIT, "src/vec8bit.c:RIGHTMOST_NONZERO_VEC8BIT" },

    {"PROD_COEFFS_VEC8BIT", 4, "vl, ll, vr, lr",
       FuncPROD_COEFFS_VEC8BIT, "src/vec8bit.c:PROD_COEFFS_VEC8BIT" },
    
    {"REDUCE_COEFFS_VEC8BIT", 3, "vl, ll, vrshifted",
       FuncREDUCE_COEFFS_VEC8BIT, "src/vec8bit.c:REDUCE_COEFFS_VEC8BIT" },

    {"QUOTREM_COEFFS_VEC8BIT", 3, "vl, ll, vrshifted",
       FuncQUOTREM_COEFFS_VEC8BIT, "src/vec8bit.c:QUOTREM_COEFFS_VEC8BIT" },

    {"MAKE_SHIFTED_COEFFS_VEC8BIT", 2, " vr, lr",
       FuncMAKE_SHIFTED_COEFFS_VEC8BIT, "src/vec8bit.c:MAKE_SHIFTED_COEFFS_VEC8BIT" },
    
    {"DISTANCE_DISTRIB_VEC8BITS", 3, " veclis, vec, d",
       FuncDISTANCE_DISTRIB_VEC8BITS, "src/vec8bit.c:DISTANCE_DISTRIB_VEC8BITS" },
    
    {"A_CLOSEST_VEC8BIT", 4, " veclis, vec, k, stop",
       FuncAClosVec8Bits, "src/vec8bit.c:A_CLOSEST_VEC8BIT" },

    {"A_CLOSEST_VEC8BIT_COORDS", 4, " veclis, vec, k, stop",
       FuncAClosVec8BitsCoords, "src/vec8bit.c:A_CLOSEST_VEC8BIT_COORDS" },
    
    {"COSET_LEADERS_INNER_8BITS", 5, " veclis, weight, tofind, leaders, felts",
       FuncCOSET_LEADERS_INNER_8BITS, "src/vec8bit.c:COSET_LEADERS_INNER_8BITS" },
    
    { "SEMIECHELON_LIST_VEC8BITS", 1, "mat",
      FuncSEMIECHELON_LIST_VEC8BITS, "sec/vec8bit.c:SEMIECHELON_LIST_VEC8BITS" },

    { "SEMIECHELON_LIST_VEC8BITS_TRANSFORMATIONS", 1, "mat",
      FuncSEMIECHELON_LIST_VEC8BITS_TRANSFORMATIONS, "sec/vec8bit.c:SEMIECHELON_LIST_VEC8BITS_TRANSFORMATIONS" },

    { "TRIANGULIZE_LIST_VEC8BITS", 1, "mat",
      FuncTRIANGULIZE_LIST_VEC8BITS, "sec/vec8bit.c:TRIANGULIZE_LIST_VEC8BITS" },
    
    { "RANK_LIST_VEC8BITS", 1, "mat",
      FuncRANK_LIST_VEC8BITS, "sec/vec8bit.c:RANK_LIST_VEC8BITS" },
    
    { "DETERMINANT_LIST_VEC8BITS", 1, "mat",
      FuncDETERMINANT_LIST_VEC8BITS, "sec/vec8bit.c:DETERMINANT_LIST_VEC8BITS" },

    { "EQ_MAT8BIT_MAT8BIT", 2, "mat8bit, mat8bit",
      FuncEQ_MAT8BIT_MAT8BIT, "src/vec8bit.c:EQ_MAT8BIT_MAT8BIT" },

    { "LT_MAT8BIT_MAT8BIT", 2, "mat8bit, mat8bit",
      FuncLT_MAT8BIT_MAT8BIT, "src/vec8bit.c:LT_MAT8BIT_MAT8BIT" },

    { "TRANSPOSED_MAT8BIT", 1, "mat8bit",
      FuncTRANSPOSED_MAT8BIT, "src/vec8bit.c:TRANSPOSED_MAT8BIT" },

    { "KRONECKERPRODUCT_MAT8BIT_MAT8BIT", 2, "mat8bit, mat8bit",
      FuncKRONECKERPRODUCT_MAT8BIT_MAT8BIT, "src/vec8bit.c:KRONECKERPRODUCT_MAT8BIT_MAT8BIT" },

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  PreSave( <module ) . . . . . . discard big recoverable data before saving
**
**  It will get rebuilt automatically, both in the saving workspace and in
** the loaded one and is not endian-safe anyway
*/

static Int PreSave( StructInitInfo * module )
{
    UInt q;
    for (q = 3; q <= 256; q++)
        SET_ELM_PLIST(FieldInfo8Bit, q, (Obj) 0);

    /* return success */
    return 0;
}

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    RNheads = 0;
    RNvectors = 0;
    RNcoeffs = 0;
    RNrelns = 0;

    /* import type functions                                               */
    ImportFuncFromLibrary("TYPE_VEC8BIT",        &TYPE_VEC8BIT);
    ImportFuncFromLibrary("TYPE_VEC8BIT_LOCKED", &TYPE_VEC8BIT_LOCKED);
    ImportGVarFromLibrary("TYPES_VEC8BIT",       &TYPES_VEC8BIT);
    ImportFuncFromLibrary("TYPE_MAT8BIT",        &TYPE_MAT8BIT);
    ImportGVarFromLibrary("TYPES_MAT8BIT",       &TYPES_MAT8BIT);
    ImportFuncFromLibrary("Is8BitVectorRep",     &IsVec8bitRep);
    ImportGVarFromLibrary("TYPE_FIELDINFO_8BIT", &TYPE_FIELDINFO_8BIT);

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable(GVarFuncs);

    InitGlobalBag(&FieldInfo8Bit, "src/vec8bit.c:FieldInfo8Bit");

    InitFopyGVar("ConvertToVectorRep", &ConvertToVectorRep);
    InitFopyGVar("AddRowVector", &AddRowVector);
    InitFopyGVar("IsLockedRepresentationVector", &IsLockedRepresentationVector);
    InitFopyGVar("AsInternalFFE", &AsInternalFFE);

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    FieldInfo8Bit = NEW_PLIST(T_PLIST_NDENSE, 257);
    SET_ELM_PLIST(FieldInfo8Bit, 257, INTOBJ_INT(1));
    SET_LEN_PLIST(FieldInfo8Bit, 257);
    MakeBagPublic(FieldInfo8Bit);
    /* init filters and functions                                          */
    InitGVarFuncsFromTable(GVarFuncs);


    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoGF2Vec()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "vec8bit",                          /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    PreSave,                            /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoVec8bit ( void )
{
    return &module;
}


/****************************************************************************
**

*E  vec8bit.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
