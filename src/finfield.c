/****************************************************************************
**
*W  finfield.c                  GAP source                      Werner Nickel
*W                                                         & Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the  functions  to compute  with elements  from  small
**  finite fields.
**
**  Finite fields  are an  important   domain in computational   group theory
**  because the classical matrix groups are defined over those finite fields.
**  In GAP we  support  small  finite  fields  with  up  to  65536  elements,
**  larger fields can be realized  as polynomial domains over smaller fields.
**
**  Elements in small finite fields are  represented  as  immediate  objects.
**
**      +----------------+-------------+---+
**      |     <value>    |   <field>   |010|
**      +----------------+-------------+---+
**
**  The least significant 3 bits of such an immediate object are always  010,
**  flagging the object as an object of a small finite field.
**
**  The next 13 bits represent the small finite field where the element lies.
**  They are simply an index into a global table of small finite fields.
**
**  The most significant 16 bits represent the value of the element.
**
**  If the  value is 0,  then the element is the  zero from the finite field.
**  Otherwise the integer is the logarithm of this  element with respect to a
**  fixed generator of the multiplicative group of the finite field plus one.
**  In the following desriptions we denote this generator always with $z$, it
**  is an element of order $o-1$, where $o$ is the order of the finite field.
**  Thus 1 corresponds to $z^{1-1} = z^0 = 1$, i.e., the  one from the field.
**  Likewise 2 corresponds to $z^{2-1} = z^1 = z$, i.e., the root itself.
**
**  This representation  makes multiplication very easy,  we only have to add
**  the values and subtract 1 , because  $z^{a-1} * z^{b-1} = z^{(a+b-1)-1}$.
**  Addition is reduced to * by the formula $z^a +  z^b = z^b * (z^{a-b}+1)$.
**  This makes it neccessary to know the successor $z^a + 1$ of every value.
**
**  The  finite field  bag contains  the  successor for  every nonzero value,
**  i.e., 'SUCC_FF(<ff>)[<a>]' is  the successor of  the element <a>, i.e, it
**  is the  logarithm  of $z^{a-1} +   1$.  This list  is  usually called the
**  Zech-Logarithm  table.  The zeroth  entry in the  finite field bag is the
**  order of the finite field minus one.
*/

#include <src/finfield.h>

#include <src/ariths.h>
#include <src/bool.h>
#include <src/calls.h>
#include <src/gap.h>
#include <src/gvars.h>
#include <src/io.h>
#include <src/lists.h>
#include <src/opers.h>
#include <src/plist.h>

#ifdef HPCGAP
#include <src/hpc/aobjects.h>
#endif

/****************************************************************************
**
*T  FF  . . . . . . . . . . . . . . . . . . . . . type of small finite fields
**
**  'FF' is the type used to represent small finite fields.
**
**  Small finite fields are represented by an  index  into  a  global  table.
**
**  Since there are  only  6542 (prime) + 93 (nonprime)  small finite fields,
**  the index fits into a 'UInt2' (actually into 13 bits).
**
**  'FF' is defined in the declaration part of this package as follows
**
typedef UInt2       FF;
*/


/****************************************************************************
**
*F  CHAR_FF(<ff>) . . . . . . . . . . .  characteristic of small finite field
**
**  'CHAR_FF' returns the characteristic of the small finite field <ff>.
**
**  Note that  'CHAR_FF' is a macro,  so do not call  it  with arguments that
**  have side effects.
**
**  'CHAR_FF' is defined in the declaration part of this package as follows
**
#define CHAR_FF(ff)             (CharFF[ff])
*/


/****************************************************************************
**
*F  DEGR_FF(<ff>) . . . . . . . . . . . . . . .  degree of small finite field
**
**  'DEGR_FF' returns the degree of the small finite field <ff>.
**
**  Note that 'DEGR_FF' is  a macro, so do   not call it with  arguments that
**  have side effects.
**
**  'DEGR_FF' is defined in the declaration part of this package as follows
**
#define DEGR_FF(ff)             (DegrFF[ff])
*/


/****************************************************************************
**
*F  SIZE_FF(<ff>) . . . . . . . . . . . . . . . .  size of small finite field
**
**  'SIZE_FF' returns the size of the small finite field <ff>.
**
**  Note that 'SIZE_FF' is a macro, so do not call  it  with  arguments  that
**  have side effects.
**
**  'SIZE_FF' is defined in the declaration part of this package as follows
**
#define SIZE_FF(ff)             (SizeFF[ff])
*/


Obj             SuccFF;


Obj             TypeFF;
Obj             TypeFF0;

Obj             TYPE_FFE;
Obj             TYPE_FFE0;


/****************************************************************************
**
*T  FFV . . . . . . . . type of the values of elements of small finite fields
**
**  'FFV'  is the  type used  to represent  the values  of elements  of small
**  finite fields.
**
**  Values of  elements  of  small  finite  fields  are  represented  by  the
**  logarithm of the element with respect to the root plus one.
**
**  Since small finite fields contain at most 65536 elements,  the value fits
**  into a 'UInt2'.
**
**  It may be possible to change this to 'UInt4' to allow small finite fields
**  with more than than  65536 elements.  The macros  and have been coded  in
**  such a  way that they work  without problems.  The exception is 'POW_FFV'
**  which  will only work if  the product of integers  of type 'FFV' does not
**  cause an overflow.  And of course the successor table stored for a finite
**  field will become quite large for fields with more than 65536 elements.
**
**  'FFV' is defined in the declaration part of this package as follows
**
typedef UInt2           FFV;
*/


/****************************************************************************
**
*F  SUM_FFV(<a>,<b>,<f>)  . . . . . . . . . . . .  sum of finite field values
**
**  'SUM_FFV' returns the sum of the two finite field values <a> and <b> from
**  the finite field pointed to by the pointer <f>.
**
**  Note that 'SUM_FFV' may only  be used if  the operands are represented in
**  the same finite field.  If you want to add two elements where one lies in
**  a subfield of the other use 'SumFFEFFE'.
**
**  Use  'SUM_FFV' only with arguments  that are variables or array elements,
**  because it is a macro and arguments with side effects will behave strange,
**  and because it  is a complex macro  so most C  compilers will be upset by
**  complex arguments.  Especially do not use 'SUM_FFV(a,NEG_FFV(b,f),f)'.
**
**  If either operand is 0, the sum is just the other operand.
**  If $a <= b$ we have
**  $a + b ~ z^{a-1}+z^{b-1} = z^{a-1} * (z^{(b-1)-(a-1)}+1) ~ a * f[b-a+1]$,
**  otherwise we have
**  $a + b ~ z^{b-1}+z^{a-1} = z^{b-1} * (z^{(a-1)-(b-1)}+1) ~ b * f[a-b+1]$.
**
**  'SUM_FFV' is defined in the declaration part of this package as follows
**
#define SUM2_FFV(a,b,f) PROD_FFV( a, (f)[(b)-(a)+1], f )
#define SUM1_FFV(a,b,f) ( (a)<=(b) ? SUM2_FFV(a,b,f) : SUM2_FFV(b,a,f) )
#define SUM_FFV(a,b,f)  ( (a)==0 || (b)==0 ? (a)+(b) : SUM1_FFV(a,b,f) )
*/


/****************************************************************************
**
*F  NEG_FFV(<a>,<f>)  . . . . . . . . . . . .  negative of finite field value
**
**  'NEG_FFV' returns  the negative of the   finite field value  <a> from the
**  finite field pointed to by the pointer <f>.
**
**  Use  'NEG_FFV' only with arguments  that are variables or array elements,
**  because it is a macro and arguments with side effects will behave strange,
**  and because it is  a complex macro so most  C compilers will be upset  by
**  complex arguments.  Especially do not use 'NEG_FFV(PROD_FFV(a,b,f),f)'.
**
**  If the characteristic is 2, every element is its  own  additive  inverse.
**  Otherwise note that $z^{o-1} = 1 = -1^2$ so $z^{(o-1)/2} = 1^{1/2} = -1$.
**  If $a <= (o-1)/2$ we have
**  $-a ~ -1 * z^{a-1} = z^{(o-1)/2} * z^{a-1} = z^{a+(o-1)/2-1} ~ a+(o-1)/2$
**  otherwise we have
**  $-a ~ -1 * z^{a-1} = z^{a+(o-1)/2-1} = z^{a+(o-1)/2-1-(o-1)} ~ a-(o-1)/2$
**
**  'NEG_FFV' is defined in the declaration part of this package as follows
**
#define NEG2_FFV(a,f)   ( (a)<=*(f)/2 ? (a)+*(f)/2 : (a)-*(f)/2 )
#define NEG1_FFV(a,f)   ( *(f)%2==1 ? (a) : NEG2_FFV(a,f) )
#define NEG_FFV(a,f)    ( (a)==0 ? 0 : NEG1_FFV(a,f) )
*/


/****************************************************************************
**
*F  PROD_FFV(<a>,<b>,<f>) . . . . . . . . . . . product of finite field value
**
**  'PROD_FFV' returns the product of the two finite field values <a> and <b>
**  from the finite field pointed to by the pointer <f>.
**
**  Note that 'PROD_FFV' may only be used if the  operands are represented in
**  the  same finite field.  If you  want to multiply  two elements where one
**  lies in a subfield of the other use 'ProdFFEFFE'.
**
**  Use 'PROD_FFV' only with arguments that are  variables or array elements,
**  because it is a macro and arguments with side effects will behave strange,
**  and  because it is  a complex macro so most  C compilers will be upset by
**  complex arguments.  Especially do not use 'NEG_FFV(PROD_FFV(a,b,f),f)'.
**
**  If one of the values is 0 the product is 0.
**  If $a+b <= o$ we have $a * b ~ z^{a-1} * z^{b-1} = z^{(a+b-1)-1} ~ a+b-1$
**  otherwise   we   have $a * b ~ z^{(a+b-2)-(o-1)} = z^{(a+b-o)-1} ~ a+b-o$
**
**  'PROD_FF' is defined in the declaration part of this package as follows
**
#define PROD1_FFV(a,b,f) ( (a)-1<=*(f)-(b) ? (a)-1+(b) : (a)-1-(*(f)-(b)) )
#define PROD_FFV(a,b,f) ( (a)==0 || (b)==0 ? 0 : PROD1_FFV(a,b,f) )
*/


/****************************************************************************
**
*F  QUO_FFV(<a>,<b>,<f>)  . . . . . . . . . . quotient of finite field values
**
**  'QUO_FFV' returns the quotient of the two finite field values <a> and <b>
**  from the finite field pointed to by the pointer <f>.
**
**  Note that 'QUO_FFV' may  only be used  if the operands are represented in
**  the same finite field.  If you want to divide two elements where one lies
**  in a subfield of the other use 'QuoFFEFFE'.
**
**  Use 'QUO_FFV' only with arguments  that are variables or array  elements,
**  because it is a macro and arguments with side effects will behave strange,
**  and  because it is  a complex macro so most  C compilers will be upset by
**  complex arguments.  Especially do not use 'NEG_FFV(PROD_FFV(a,b,f),f)'.
**
**  A division by 0 is an error,  and dividing 0 by a nonzero value gives  0.
**  If $0 <= a-b$ we have  $a / b ~ z^{a-1} / z^{b-1} = z^{a-b+1-1} ~ a-b+1$,
**  otherwise   we   have  $a / b ~ z^{a-b+1-1}  =  z^{a-b+(o-1)}   ~ a-b+o$.
**
**  'QUO_FFV' is defined in the declaration part of this package as follows
**
#define QUO1_FFV(a,b,f) ( (b)<=(a) ? (a)-(b)+1 : *(f)-(b)+1+(a) )
#define QUO_FFV(a,b,f)  ( (a)==0 ? 0 : QUO1_FFV(a,b,f) )
*/


/****************************************************************************
**
*F  POW_FFV(<a>,<n>,<f>)  . . . . . . . . . . . power of a finite field value
**
**  'POW_FFV' returns the <n>th power of the finite  field value <a> from the
**  the finite field pointed to by the pointer <f>.
**
**  Note that 'POW_FFV' may only be used  if the right  operand is an integer
**  in the range $0..order(f)-1$.
**
**  Finally 'POW_FFV' may only be used if the  product of two integers of the
**  size of 'FFV'   does  not cause an  overflow,   i.e.  only if  'FFV'   is
**  'unsigned short'.
**
**  Note  that 'POW_FFV' is a macro,  so do not call  it  with arguments that
**  have side effects.  For optimal performance  put the operands in registers
**  before calling 'POW_FFV'.
**
**  If the finite field element is 0 the power is also 0, otherwise  we  have
**  $a^n ~ (z^{a-1})^n = z^{(a-1)*n} = z^{(a-1)*n % (o-1)} ~ (a-1)*n % (o-1)$
**
**  'POW_FFV' is defined in the declaration part of this package as follows
**
#define POW1_FFV(a,n,f) ( (((a)-1) * (n)) % *(f) + 1 )
#define POW_FFV(a,n,f)  ( (n)==0 ? 1 : ( (a)==0 ? 0 : POW1_FFV(a,n,f) ) )
*/


/****************************************************************************
**
*F  FLD_FFE(<ffe>)  . . . . . . . field of an element of a small finite field
**
**  'FLD_FFE' returns the small finite field over which the element  <ffe> is
**  represented.
**
**  Note that 'FLD_FFE' is a macro, so do not call  it  with  arguments  that
**  have side effects.
**
**  'FLD_FFE' is defined in the declaration part of this package as follows
**
#define FLD_FFE(ffe)            ((((UInt)(ffe)) & 0xFFFF) >> 3)
*/


/****************************************************************************
**
*F  VAL_FFE(<ffe>)  . . . . . . . value of an element of a small finite field
**
**  'VAL_FFE' returns the value of the element <ffe> of a small finite field.
**  Thus,  if <ffe> is $0_F$, it returns 0;  if <ffe> is $1_F$, it returns 1;
**  and otherwise if <ffe> is $z^i$, it returns $i+1$.
**
**  Note that 'VAL_FFE' is a macro, so do not call  it  with  arguments  that
**  have side effects.
**
**  'VAL_FFE' is defined in the declaration part of this package as follows
**
#define VAL_FFE(ffe)            (((UInt)(ffe)) >> 16)
*/


/****************************************************************************
**
*F  NEW_FFE(<fld>,<val>)  . . . .  make a new element of a small finite field
**
**  'NEW_FFE' returns a new element  <ffe>  of the  small finite  field <fld>
**  with the value <val>.
**
**  Note that 'NEW_FFE' is a macro, so do not  call  it  with  arguments that
**  have side effects.
**
**  'NEW_FFE' is defined in the declaration part of this package as follows
**
#define NEW_FFE(fld,val)        ((Obj)(((val) << 16) + ((fld) << 3) + 0x02))
*/


/****************************************************************************
**
*V  PolsFF  . . . . . . . . . .  list of Conway polynomials for finite fields
**
**  'PolsFF' is a  list of  Conway  polynomials for finite fields.   The even
**  entries are the  proper prime powers,  odd entries are the  corresponding
**  conway polynomials.
*/
unsigned long   PolsFF [] = {
       4, 1+2,
       8, 1+2,
      16, 1+2,
      32, 1  +4,
      64, 1+2  +8+16,
     128, 1+2,
     256, 1  +4+8+16,
     512, 1      +16,
    1024, 1+2+4+8   +32+64,
    2048, 1  +4,
    4096, 1+2  +8   +32+64+128,
    8192, 1+2  +8+16,
   16384, 1    +8   +32   +128,
   32768, 1  +4  +16+32,
   65536, 1  +4+8   +32,
       9,  2 +2*3,
      27,  1 +2*3,
      81,  2           +2*27,
     243,  1 +2*3,
     729,  2 +2*3 +1*9       +2*81,
    2187,  1      +2*9,
    6561,  2 +2*3 +2*9       +1*81 +2*243,
   19683,  1 +1*3 +2*9 +2*27,
   59049,  2 +1*3            +2*81 +2*243 +2*729,
      25,  2 +4*5,
     125,  3 +3*5,
     625,  2 +4*5 +4*25,
    3125,  3 +4*5,
   15625,  2      +1*25 +4*125 +1*625,
      49,  3 +6*7,
     343,  4      +6*49,
    2401,  3 +4*7 +5*49,
   16807,  4 +1*7,
     121,  2 + 7*11,
    1331,  9 + 2*11,
   14641,  2 +10*11 +8*121,
     169,  2 +12*13,
    2197, 11 + 2*13,
   28561,  2 +12*13 +3*169,
     289,  3 +16*17,
    4913, 14 + 1*17,
     361,  2 +18*19,
    6859, 17 + 4*19,
     529,  5 +21*23,
   12167, 18 + 2*23,
     841,  2 +24*29,
   24389, 27 + 2*29,
     961,  3 +29*31,
   29791, 28 + 1*31,
    1369,  2 +33*37,
   50653, 35 + 6*37,
    1681,  6 + 38* 41,
    1849,  3 + 42* 43,
    2209,  5 + 45* 47,
    2809,  2 + 49* 53,
    3481,  2 + 58* 59,
    3721,  2 + 60* 61,
    4489,  2 + 63* 67,
    5041,  7 + 69* 71,
    5329,  5 + 70* 73,
    6241,  3 + 78* 79,
    6889,  2 + 82* 83,
    7921,  3 + 82* 89,
    9409,  5 + 96* 97,
   10201,  2 + 97*101,
   10609,  5 +102*103,
   11449,  2 +103*107,
   11881,  6 +108*109,
   12769,  3 +101*113,
   16129,  3 +126*127,
   17161,  2 +127*131,
   18769,  3 +131*137,
   19321,  2 +138*139,
   22201,  2 +145*149,
   22801,  6 +149*151,
   24649,  5 +152*157,
   26569,  2 +159*163,
   27889,  5 +166*167,
   29929,  2 +169*173,
   32041,  2 +172*179,
   32761,  2 +177*181,
   36481, 19 +190*191,
   37249,  5 +192*193,
   38809,  2 +192*197,
   39601,  3 +193*199,
   44521,  2 +207*211,
   49729,  3 +221*223,
   51529,  2 +220*227,
   52441,  6 +228*229,
   54289,  3 +232*233,
   57121,  7 +237*239,
   58081,  7 +238*241,
   63001,  6 +242*251,
};


// used for successor bags
static Obj TYPE_KERNEL_OBJECT;

/****************************************************************************
**
*F  FiniteField(<p>,<d>)  . . . make the small finite field with <q> elements
**
**  'FiniteField' returns the small finite field with <p>^<d> elements.
*/
FF              FiniteField (
    UInt                p,
    UInt                d )
{
    FF                  ff;             /* finite field, result            */
    Obj                 tmp;            /* temporary bag                   */
    Obj                 succBag;        /* successor table bag             */
    FFV *               succ;           /* successor table                 */
    FFV *               indx;           /* index table                     */
    UInt                q;              /* size of finite field            */
    UInt                poly;           /* Conway polynomial of extension  */
    UInt                i, l, f, n, e;  /* loop variables                  */

    /* calculate size of field */
    q = 1;
    for ( i = 1; i <= d; i++ ) q *= p;

    /* search through the finite field table                               */
    l = 1; n = NUM_SHORT_FINITE_FIELDS;
    ff = 0;
    while (l <= n && SizeFF[l] <= q && q <= SizeFF[n]) {
      /* interpolation search */
      /* cuts iterations roughly in half compared to binary search at
       * the expense of additional divisions. */
      e = (q - SizeFF[l]+1) * (n-l) / (SizeFF[n]-SizeFF[l]+1);
      ff = l + e;
      if (SizeFF[ff] == q)
        break;
      if (SizeFF[ff] < q)
        l = ff+1;
      else
        n = ff-1;
    }
    if (ff < 1 || ff > NUM_SHORT_FINITE_FIELDS)
      return 0;
    if (CharFF[ff] != p)
      return 0;
    if (SizeFF[ff] != q)
      return 0;
#ifdef HPCGAP
    /* Important correctness concern here:
     *
     * The values of SuccFF, TypeFF, and TypeFF0 are set in that
     * order, separated by write barriers. This can happen concurrently
     * in a different thread.
     *
     * Thus, after observing that TypeFF0 has been set, we can be sure
     * that the thread also sees the values of SuccFF and TypeFF.
     * This is ensured by the read barrier in ATOMIC_ELM_PLIST().
     *
     * In the worst case, we may do the following calculations once per
     * thread and throw them away for all but one thread. Correctness
     * is still ensured through the use of ATOMIC_SET_ELM_PLIST_ONCE(),
     * which results in all threads sharing the same types and successor
     * tables.
     */
    if (ATOMIC_ELM_PLIST(TypeFF0, ff))
      return ff;
#else
    if (ELM_PLIST(TypeFF0, ff))
      return ff;
#endif

    /* allocate a bag for the successor table and one for a temporary         */
    tmp  = NewBag( T_DATOBJ, sizeof(Obj) + q * sizeof(FFV) );
    SET_TYPE_DATOBJ(tmp, TYPE_KERNEL_OBJECT );

    succBag = NewBag( T_DATOBJ, sizeof(Obj) + q * sizeof(FFV) );
    SET_TYPE_DATOBJ(succBag, TYPE_KERNEL_OBJECT );

    indx = (FFV*)(1+ADDR_OBJ( tmp ));
    succ = (FFV*)(1+ADDR_OBJ( succBag ));

    /* if q is a prime find the smallest primitive root $e$, use $x - e$   */
    /*N 1990/02/04 mschoene this is likely to explode if 'FFV' is 'UInt4'  */
    /*N 1990/02/04 mschoene there are few dumber ways to find prim. roots  */
    if ( d == 1 ) {
        for ( e = 1, i = 1; i != p-1; ++e ) {
            for ( f = e, i = 1; f != 1; ++i )
                f = (f * e) % p;
        }
        poly = p-(e-1);
    }

    /* otherwise look up the polynomial used to construct this field       */
    else {
        for ( i = 0; PolsFF[i] != q; i += 2 ) ;
        poly = PolsFF[i+1];
    }

    /* construct 'indx' such that 'e = x^(indx[e]-1) % poly' for every e   */
    /*N 1990/02/04 mschoene this is likely to explode if 'FFV' is 'UInt4'  */
    indx[ 0 ] = 0;
    for ( e = 1, n = 0; n < q-1; ++n ) {
        indx[ e ] = n + 1;
        /* e =p*e mod poly =x*e mod poly =x*x^n mod poly =x^{n+1} mod poly */
        if ( p != 2 ) {
            f = p * (e % (q/p));  l = ((p-1) * (e / (q/p))) % p;  e = 0;
            for ( i = 1; i < q; i *= p )
                e = e + i * ((f/i + l * (poly/i)) % p);
        }
        else {
            if ( 2*e & q )  e = 2*e ^ poly ^ q;
            else            e = 2*e;
        }
    }

    /* construct 'succ' such that 'x^(n-1)+1 = x^(succ[n]-1)' for every n  */
    succ[ 0 ] = q-1;
    for ( e = 1, f = p-1; e < q; e++ ) {
        if ( e < f ) {
            succ[ indx[e] ] = indx[ e+1 ];
        }
        else {
            succ[ indx[e] ] = indx[ e+1-p ];
            f += p;
        }
    }

    /* enter the finite field in the tables                                */
#ifdef HPCGAP
    MakeBagReadOnly(succBag);
    ATOMIC_SET_ELM_PLIST_ONCE( SuccFF, ff, succBag );
    CHANGED_BAG(SuccFF);
    tmp = CALL_1ARGS( TYPE_FFE, INTOBJ_INT(p) );
    ATOMIC_SET_ELM_PLIST_ONCE( TypeFF, ff, tmp );
    CHANGED_BAG(TypeFF);
    tmp = CALL_1ARGS( TYPE_FFE0, INTOBJ_INT(p) );
    ATOMIC_SET_ELM_PLIST_ONCE( TypeFF0, ff, tmp );
    CHANGED_BAG(TypeFF0);
#else
    ASS_LIST( SuccFF, ff, succBag );
    CHANGED_BAG(SuccFF);
    tmp = CALL_1ARGS( TYPE_FFE, INTOBJ_INT(p) );
    ASS_LIST( TypeFF, ff, tmp );
    CHANGED_BAG(TypeFF);
    tmp = CALL_1ARGS( TYPE_FFE0, INTOBJ_INT(p) );
    ASS_LIST( TypeFF0, ff, tmp );
    CHANGED_BAG(TypeFF0);
#endif

    /* return the finite field                                             */
    return ff;
}


/****************************************************************************
**
*F  CommonFF(<f1>,<d1>,<f2>,<d2>) . . . . . . . . . . . . find a common field
**
**  'CommonFF' returns  a small finite field  that can represent  elements of
**  degree <d1> from the small finite field <f1> and  elements of degree <d2>
**  from the small finite field <f2>.  Note that this is not guaranteed to be
**  the smallest such field.  If  <f1> and <f2> have different characteristic
**  or the smallest common field, is too large, 'CommonFF' returns 0.
*/
FF              CommonFF (
    FF                  f1,
    UInt                d1,
    FF                  f2,
    UInt                d2 )
{
    UInt                p;              /* characteristic                  */
    UInt                d;              /* degree                          */

    /* trivial case first                                                  */
    if ( f1 == f2 ) {
        return f1;
    }

    /* get and check the characteristics                                   */
    p = CHAR_FF( f1 );
    if ( p != CHAR_FF( f2 ) ) {
        return 0;
    }

    /* check whether one of the fields will do                             */
    if ( DEGR_FF(f1) % d2 == 0 ) {
        return f1;
    }
    if ( DEGR_FF(f2) % d1 == 0 ) {
        return f2;
    }

    /* compute the neccessary degree                                       */
    d = d1;
    while ( d % d2 != 0 ) {
        d += d1;
    }

    /* try to build the field                                              */
    return FiniteField( p, d );
}


/****************************************************************************
**
*F  CharFFE(<ffe>)  . . . . . . . . .  characteristic of a small finite field
**
**  'CharFFE' returns the characteristic of the small finite field  in  which
**  the element <ffe> lies.
*/
UInt CharFFE (
    Obj                 ffe )
{
    return CHAR_FF( FLD_FFE(ffe) );
}

Obj FuncCHAR_FFE_DEFAULT (
    Obj                 self,
    Obj                 ffe )
{
    return INTOBJ_INT( CHAR_FF( FLD_FFE(ffe) ) );
}


/****************************************************************************
**
*F  DegreeFFE(<ffe>)  . . . . . . . . . . . .  degree of a small finite field
**
**  'DegreeFFE' returns the degree of the smallest finite field in which  the
**  element <ffe> lies.
*/
UInt DegreeFFE (
    Obj                 ffe )
{
    UInt                d;              /* degree, result                  */
    FFV                 val;            /* value of element                */
    FF                  fld;            /* field of element                */
    UInt                q;              /* size  of field                  */
    UInt                p;              /* char. of field                  */
    UInt                m;              /* size  of minimal field          */

    /* get the value, the field, the size, and the characteristic          */
    val = VAL_FFE( ffe );
    fld = FLD_FFE( ffe );
    q = SIZE_FF( fld );
    p = CHAR_FF( fld );

    /* the zero element has a degree of one                                */
    if ( val == 0 ) {
        return 1L;
    }

    /* compute the degree                                                  */
    m = p;
    d = 1;
    while ( (q-1) % (m-1) != 0 || (val-1) % ((q-1)/(m-1)) != 0 ) {
        m *= p;
        d += 1;
    }

    /* return the degree                                                   */
    return d;
}

Obj FuncDEGREE_FFE_DEFAULT (
    Obj                 self,
    Obj                 ffe )
{
    return INTOBJ_INT( DegreeFFE( ffe ) );
}


/****************************************************************************
**
*F  TypeFFE(<ffe>)  . . . . . . . . . . type of element of small finite field
**
**  'TypeFFE' returns the type of the element <ffe> of a small finite field.
**
**  'TypeFFE' is the function in 'TypeObjFuncs' for  elements in small finite
**  fields.
*/
Obj             TypeFFE (
    Obj                 ffe )
{
  if (VAL_FFE(ffe) == 0)
    return TYPE_FF0( FLD_FFE( ffe ) );
  else
    return TYPE_FF( FLD_FFE( ffe ) );
}


/****************************************************************************
**
*F  EqFFE(<opL>,<opR>)  . . . . . . . test if finite field elements are equal
**
**  'EqFFE' returns  'True' if the two  finite field elements <opL> and <opR>
**  are equal and 'False' othwise.
**
**  This is complicated because it must account  for the following situation.
**  Suppose 'a' is 'Z(3)', 'b' is 'Z(3^2)^4' and  finally 'c' is 'Z(3^3)^13'.
**  Mathematically 'a' is equal to 'b', so we  want 'a =  b' to be 'true' and
**  since 'a' is represented over a  subfield of 'b'  this is no big problem.
**  Again  'a' is equal to  'c', and again we want  'a = c'  to be 'true' and
**  again this is no problem since 'a' is represented over a subfield of 'c'.
**  Since '=' ought  to be transitive we also  want 'b = c'  to be 'true' and
**  this is a problem, because they are represented over incompatible fields.
*/
Int             EqFFE (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR;         /* value of left and right         */
    FF                  fL, fR;         /* field of left and right         */
    UInt                pL, pR;         /* char. of left and right         */
    UInt                qL, qR;         /* size  of left and right         */
    UInt                mL, mR;         /* size  of minimal field          */

    /* get the values and the fields over which they are represented       */
    vL = VAL_FFE( opL );
    vR = VAL_FFE( opR );
    fL = FLD_FFE( opL );
    fR = FLD_FFE( opR );

    /* if the elements are represented over the same field, it is easy     */
    if ( fL == fR ) {
        return (vL == vR);
    }

    /* elements in fields of different characteristic are different too    */
    pL = CHAR_FF( fL );
    pR = CHAR_FF( fR );
    if ( pL != pR ) {
        return 0L;
    }

    /* the zero element is not equal to any other element                  */
    if ( vL == 0 || vR == 0 ) {
        return (vL == 0 && vR == 0);
    }

    /* compute the sizes of the minimal fields in which the elements lie   */
    qL = SIZE_FF( fL );
    mL = pL;
    while ( (qL-1) % (mL-1) != 0 || (vL-1) % ((qL-1)/(mL-1)) != 0 ) mL *= pL;
    qR = SIZE_FF( fR );
    mR = pR;
    while ( (qR-1) % (mR-1) != 0 || (vR-1) % ((qR-1)/(mR-1)) != 0 ) mR *= pR;

    /* elements in different fields are different too                      */
    if ( mL != mR ) {
        return 0L;
    }

    /* otherwise compare the elements in the common minimal field          */
    return ((vL-1)/((qL-1)/(mL-1)) == (vR-1)/((qR-1)/(mR-1)));
}


/****************************************************************************
**
*F  LtFFE(<opL>,<opR>)  . . . . . .  test if finite field elements is smaller
**
**  'LtFFEFFE' returns 'True' if the  finite field element <opL> is  strictly
**  less than the finite field element <opR> and 'False' otherwise.
*/
Int             LtFFE (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR;         /* value of left and right         */
    FF                  fL, fR;         /* field of left and right         */
    UInt                pL, pR;         /* char. of left and right         */
    UInt                qL, qR;         /* size  of left and right         */
    UInt                mL, mR;         /* size  of minimal field          */

    /* get the values and the fields over which they are represented       */
    vL = VAL_FFE( opL );
    vR = VAL_FFE( opR );
    fL = FLD_FFE( opL );
    fR = FLD_FFE( opR );

    /* elements in fields of different characteristic are not comparable   */
    pL = CHAR_FF( fL );
    pR = CHAR_FF( fR );
    if ( pL != pR ) {
        return (DoOperation2Args( LtOper, opL, opR ) == True);
    }

    /* the zero element is smaller than any other element                  */
    if ( vL == 0 || vR == 0 ) {
        return (vL == 0 && vR != 0);
    }
    
    /* get the sizes of the fields over which the elements are written */
    qL = SIZE_FF( fL );
    qR = SIZE_FF( fR );

    /* Deal quickly with the case where both elements are written over the ground field */
    if (qL ==pL &&  qR == pR)
      return vL < vR;

    /* compute the sizes of the minimal fields in which the elements lie   */
    mL = pL;
    while ( (qL-1) % (mL-1) != 0 || (vL-1) % ((qL-1)/(mL-1)) != 0 ) mL *= pL;
    mR = pR;
    while ( (qR-1) % (mR-1) != 0 || (vR-1) % ((qR-1)/(mR-1)) != 0 ) mR *= pR;

    /* elements in smaller fields are smaller too                          */
    if ( mL != mR ) {
        return (mL < mR);
    }

    /* otherwise compare the elements in the common minimal field          */
    return ((vL-1)/((qL-1)/(mL-1)) < (vR-1)/((qR-1)/(mR-1)));
}


/****************************************************************************
**
*F  PrFFV(<fld>,<val>)  . . . . . . . . . . . . .  print a finite field value
**
**  'PrFFV' prints the value <val> from the finite field <fld>.
**
*/
void            PrFFV (
    FF                  fld,
    FFV                 val )
{
    UInt                q;              /* size   of finite field          */
    UInt                p;              /* char.  of finite field          */
    UInt                m;              /* size   of minimal field         */
    UInt                d;              /* degree of minimal field         */

    /* get the characteristic, order of the minimal field and the degree   */
    q = SIZE_FF( fld );
    p = CHAR_FF( fld );

    /* print the zero                                                      */
    if ( val == 0 ) {
        Pr( "%>0*Z(%>%d%2<)", (Int)p, 0L );
    }

    /* print a nonzero element as power of the primitive root              */
    else {

        /* find the degree of the minimal field in that the element lies   */
        d = 1;  m = p;
        while ( (q-1) % (m-1) != 0 || (val-1) % ((q-1)/(m-1)) != 0 ) {
            d++;  m *= p;
        }
        val = (val-1) / ((q-1)/(m-1)) + 1;

        /* print the element                                               */
        Pr( "%>Z(%>%d%<", (Int)p, 0L );
        if ( d == 1 ) {
            Pr( "%<)", 0L, 0L );
        }
        else {
            Pr( "^%>%d%2<)", (Int)d, 0L );
        }
        if ( val != 2 ) {
            Pr( "^%>%d%<", (Int)(val-1), 0L );
        }
    }

}


/****************************************************************************
**
*F  PrFFE(<ffe>)  . . . . . . . . . . . . . . .  print a finite field element
**
**  'PrFFE' prints the finite field element <ffe>.
*/
void            PrFFE (
    Obj                 ffe )
{
    PrFFV( FLD_FFE(ffe), VAL_FFE(ffe) );
}


/****************************************************************************
**
*F  SumFFEFFE(<opL>,<opR>)  . . . . . . . . . .  sum of finite field elements
**
**  'SumFFEFFE' returns  the sum of the  two finite  field elements <opL> and
**  <opR>.  The sum is represented over the field over which the operands are
**  represented, even if it lies in a much smaller field.
**
**  If one of the  elements is represented over  a subfield of the field over
**  which the  other element  is  represented, it is  lifted  into the larger
**  field before the addition.
**
**  'SumFFEFFE' just does the conversions mentioned  above and then calls the
**  macro 'SUM_FFV' to do the actual addition.
*/
Obj             SUM_FFE_LARGE;

Obj             SumFFEFFE (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fL, fR, fX;     /* field of left, right, result    */
    UInt                qL, qR, qX;     /* size  of left, right, result    */

    /* get the values, handle trivial cases                                */
    vL = VAL_FFE( opL );
    vR = VAL_FFE( opR );

    /* bring the two operands into a common field <fX>                     */
    fL = FLD_FFE( opL );
    qL = SIZE_FF( fL );
    fR = FLD_FFE( opR );
    qR = SIZE_FF( fR  );

    /*N 1997/01/04 mschoene this is likely to explode if 'FFV' is 'UInt4'  */
    if ( qL == qR ) {
        fX = fL;
    }
    else if ( qL % qR == 0 && (qL-1) % (qR-1) == 0 ) {
        fX = fL;
        if ( vR != 0 )  vR = (qL-1) / (qR-1) * (vR-1) + 1;
    }
    else if ( qR % qL == 0 && (qR-1) % (qL-1) == 0 ) {
        fX = fR;
        if ( vL != 0 )  vL = (qR-1) / (qL-1) * (vL-1) + 1;
    }
    else {
        fX = CommonFF( fL, DegreeFFE(opL), fR, DegreeFFE(opR) );
        if ( fX == 0 )  return CALL_2ARGS( SUM_FFE_LARGE, opL, opR );
        qX = SIZE_FF( fX );
        /* if ( vL != 0 )  vL = (qX-1) / (qL-1) * (vL-1) + 1; */
        if ( vL != 0 )  vL = ((qX-1) * (vL-1)) / (qL-1) + 1;
        /* if ( vR != 0 )  vR = (qX-1) / (qR-1) * (vR-1) + 1; */
        if ( vR != 0 )  vR = ((qX-1) * (vR-1)) / (qR-1) + 1;
    }

    /* compute and return the result                                       */
    vX = SUM_FFV( vL, vR, SUCC_FF(fX) );
    return NEW_FFE( fX, vX );
}

Obj             SumFFEInt (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fX;             /* field of result                 */
    Int                 pX;             /* char. of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( opL );
    pX = CHAR_FF( fX );
    sX = SUCC_FF( fX );

    /* get the right operand                                               */
    vX = ((INT_INTOBJ( opR ) % pX) + pX) % pX;
    if ( vX == 0 ) {
        vR = 0;
    }
    else {
        vR = 1;
        for ( ; 1 < vX; vX-- )  vR = sX[vR];
    }

    /* get the left operand                                                */
    vL = VAL_FFE( opL );

    /* compute and return the result                                       */
    vX = SUM_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}

Obj             SumIntFFE (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fX;             /* field of result                 */
    Int                 pX;             /* char. of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( opR );
    pX = CHAR_FF( fX );
    sX = SUCC_FF( fX );

    /* get the left operand                                                */
    vX = ((INT_INTOBJ( opL ) % pX) + pX) % pX;
    if ( vX == 0 ) {
        vL = 0;
    }
    else {
        vL = 1;
        for ( ; 1 < vX; vX-- )  vL = sX[vL];
    }

    /* get the right operand                                               */
    vR = VAL_FFE( opR );

    /* compute and return the result                                       */
    vX = SUM_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}


/****************************************************************************
**
*F  ZeroFFE(<op>) . . . . . . . . . . . . . .  zero of a finite field element
*/
Obj             ZeroFFE (
    Obj                 op )
{
    FF                  fX;             /* field of result                 */

    /* get the field for the result                                        */
    fX = FLD_FFE( op );

    /* return the result                                                   */
    return NEW_FFE( fX, 0 );
}


/****************************************************************************
**
*F  AInvFFE(<op>) . . . . . . . . . . additive inverse of finite field element
*/
Obj             AInvFFE (
    Obj                 op )
{
    FFV                 v, vX;          /* value of operand, result        */
    FF                  fX;             /* field of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( op );
    sX = SUCC_FF( fX );

    /* get the operand                                                     */
    v = VAL_FFE( op );

    /* compute and return the result                                       */
    vX = NEG_FFV( v, sX ); 
    return NEW_FFE( fX, vX );
}


/****************************************************************************
**
*F  DiffFFEFFE(<opL>,<opR>) . . . . . . . difference of finite field elements
**
**  'DiffFFEFFE' returns  the difference  of  the two  finite  field elements
**  <opL> and <opR>.  The difference is represented over the field over which
**  the operands are represented, even if it lies in a much smaller field.
**
**  If one of the elements is  represented over a subfield  of the field over
**  which the  other element is  represented,  it is  lifted into  the larger
**  field before the subtraction.
**
**  'DiffFFEFFE' just does the conversions mentioned above and then calls the
**  macros 'NEG_FFV' and 'SUM_FFV' to do the actual subtraction.
*/
Obj             DIFF_FFE_LARGE;

Obj             DiffFFEFFE (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fL, fR, fX;     /* field of left, right, result    */
    UInt                qL, qR, qX;     /* size  of left, right, result    */

    /* get the values, handle trivial cases                                */
    vL = VAL_FFE( opL );
    vR = VAL_FFE( opR );

    /* bring the two operands into a common field <fX>                     */
    fL = FLD_FFE( opL );
    qL = SIZE_FF( fL );
    fR = FLD_FFE( opR );
    qR = SIZE_FF( fR  );

    /*N 1997/01/04 mschoene this is likely to explode if 'FFV' is 'UInt4'  */
    if ( qL == qR ) {
        fX = fL;
    }
    else if ( qL % qR == 0 && (qL-1) % (qR-1) == 0 ) {
        fX = fL;
        if ( vR != 0 )  vR = (qL-1) / (qR-1) * (vR-1) + 1;
    }
    else if ( qR % qL == 0 && (qR-1) % (qL-1) == 0 ) {
        fX = fR;
        if ( vL != 0 )  vL = (qR-1) / (qL-1) * (vL-1) + 1;
    }
    else {
        fX = CommonFF( fL, DegreeFFE(opL), fR, DegreeFFE(opR) );
        if ( fX == 0 )  return CALL_2ARGS( DIFF_FFE_LARGE, opL, opR );
        qX = SIZE_FF( fX );
        /* if ( vL != 0 )  vL = (qX-1) / (qL-1) * (vL-1) + 1; */
        if ( vL != 0 )  vL = ((qX-1) * (vL-1)) / (qL-1) + 1;
        /* if ( vR != 0 )  vR = (qX-1) / (qR-1) * (vR-1) + 1; */
        if ( vR != 0 )  vR = ((qX-1) * (vR-1)) / (qR-1) + 1;
    }

    /* compute and return the result                                       */
    vR = NEG_FFV( vR, SUCC_FF(fX) );
    vX = SUM_FFV( vL, vR, SUCC_FF(fX) );
    return NEW_FFE( fX, vX );
}

Obj             DiffFFEInt (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fX;             /* field of result                 */
    Int                 pX;             /* char. of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( opL );
    pX = CHAR_FF( fX );
    sX = SUCC_FF( fX );

    /* get the right operand                                               */
    vX = ((INT_INTOBJ( opR ) % pX) + pX) % pX;
    if ( vX == 0 ) {
        vR = 0;
    }
    else {
        vR = 1;
        for ( ; 1 < vX; vX-- )  vR = sX[vR];
    }

    /* get the left operand                                                */
    vL = VAL_FFE( opL );

    /* compute and return the result                                       */
    vR = NEG_FFV( vR, sX );
    vX = SUM_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}

Obj             DiffIntFFE (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fX;             /* field of result                 */
    Int                 pX;             /* char. of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( opR );
    pX = CHAR_FF( fX );
    sX = SUCC_FF( fX );

    /* get the left operand                                                */
    vX = ((INT_INTOBJ( opL ) % pX) + pX) % pX;
    if ( vX == 0 ) {
        vL = 0;
    }
    else {
        vL = 1;
        for ( ; 1 < vX; vX-- )  vL = sX[vL];
    }

    /* get the right operand                                               */
    vR = VAL_FFE( opR );

    /* compute and return the result                                       */
    vR = NEG_FFV( vR, sX );
    vX = SUM_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}


/****************************************************************************
**
*F  ProdFFEFFE(<opL>,<opR>) . . . . . . . .  product of finite field elements
**
**  'ProdFFEFFE'  returns the product of  the two finite field elements <opL>
**  and <opR>.   The  product is  represented  over the field  over which the
**  operands are represented, even if it lies in a much smaller field.
**
**  If one of the elements  is represented over a  subfield of the field over
**  which the other element  is  represented, it  is  lifted into the  larger
**  field before the multiplication.
**
**  'ProdFFEFFE' just does the conversions mentioned above and then calls the
**  macro 'PROD_FFV' to do the actual multiplication.
*/
Obj             PROD_FFE_LARGE;

Obj             ProdFFEFFE (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fL, fR, fX;     /* field of left, right, result    */
    UInt                qL, qR, qX;     /* size  of left, right, result    */

    /* get the values, handle trivial cases                                */
    vL = VAL_FFE( opL );
    vR = VAL_FFE( opR );

    /* bring the two operands into a common field <fX>                     */
    fL = FLD_FFE( opL );
    qL = SIZE_FF( fL );
    fR = FLD_FFE( opR );
    qR = SIZE_FF( fR  );

    /*N 1997/01/04 mschoene this is likely to explode if 'FFV' is 'UInt4'  */
    if ( qL == qR ) {
        fX = fL;
    }
    else if ( qL % qR == 0 && (qL-1) % (qR-1) == 0 ) {
        fX = fL;
        if ( vR != 0 )  vR = (qL-1) / (qR-1) * (vR-1) + 1;
    }
    else if ( qR % qL == 0 && (qR-1) % (qL-1) == 0 ) {
        fX = fR;
        if ( vL != 0 )  vL = (qR-1) / (qL-1) * (vL-1) + 1;
    }
    else {
        fX = CommonFF( fL, DegreeFFE(opL), fR, DegreeFFE(opR) );
        if ( fX == 0 )  return CALL_2ARGS( PROD_FFE_LARGE, opL, opR );
        qX = SIZE_FF( fX );
        /* if ( vL != 0 )  vL = (qX-1) / (qL-1) * (vL-1) + 1; */
        if ( vL != 0 )  vL = ((qX-1) * (vL-1)) / (qL-1) + 1;
        /* if ( vR != 0 )  vR = (qX-1) / (qR-1) * (vR-1) + 1; */
        if ( vR != 0 )  vR = ((qX-1) * (vR-1)) / (qR-1) + 1;
    }

    /* compute and return the result                                       */
    vX = PROD_FFV( vL, vR, SUCC_FF(fX) );
    return NEW_FFE( fX, vX );
}

Obj             ProdFFEInt (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fX;             /* field of result                 */
    Int                 pX;             /* char. of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( opL );
    pX = CHAR_FF( fX );
    sX = SUCC_FF( fX );

    /* get the right operand                                               */
    vX = ((INT_INTOBJ( opR ) % pX) + pX) % pX;
    if ( vX == 0 ) {
        vR = 0;
    }
    else {
        vR = 1;
        for ( ; 1 < vX; vX-- )  vR = sX[vR];
    }

    /* get the left operand                                                */
    vL = VAL_FFE( opL );

    /* compute and return the result                                       */
    vX = PROD_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}

Obj             ProdIntFFE (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fX;             /* field of result                 */
    Int                 pX;             /* char. of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( opR );
    pX = CHAR_FF( fX );
    sX = SUCC_FF( fX );

    /* get the left operand                                                */
    vX = ((INT_INTOBJ( opL ) % pX) + pX) % pX;
    if ( vX == 0 ) {
        vL = 0;
    }
    else {
        vL = 1;
        for ( ; 1 < vX; vX-- )  vL = sX[vL];
    }

    /* get the right operand                                               */
    vR = VAL_FFE( opR );

    /* compute and return the result                                       */
    vX = PROD_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}


/****************************************************************************
**
*F  OneFFE(<op>)  . . . . . . . . . . . . . . . one of a finite field element
*/
Obj             OneFFE (
    Obj                 op )
{
    FF                  fX;             /* field of result                 */

    /* get the field for the result                                        */
    fX = FLD_FFE( op );

    /* return the result                                                   */
    return NEW_FFE( fX, 1 );
}


/****************************************************************************
**
*F  InvFFE(<op>)  . . . . . . . . . . . . . . inverse of finite field element
*/
Obj             InvFFE (
    Obj                 op )
{
    FFV                 v, vX;          /* value of operand, result        */
    FF                  fX;             /* field of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( op );
    sX = SUCC_FF( fX );

    /* get the operand                                                     */
    v = VAL_FFE( op );
    if ( v == 0 ) return Fail;

    /* compute and return the result                                       */
    vX = QUO_FFV( 1, v, sX ); 
    return NEW_FFE( fX, vX );
}


/****************************************************************************
**
*F  QuoFFEFFE(<opL>,<opR>) . . . . . . . .  quotient of finite field elements
**
**  'QuoFFEFFE' returns  the quotient of  the two finite field elements <opL>
**  and <opR>.  The  quotient is represented  over  the field  over which the
**  operands are represented, even if it lies in a much smaller field.
**
**  If one of the  elements is represented over  a subfield of the field over
**  which the  other  element is represented,  it is  lifted into the  larger
**  field before the division.
**
**  'QuoFFEFFE' just does the conversions mentioned  above and then calls the
**  macro 'QUO_FFV' to do the actual division.
*/
Obj             QUO_FFE_LARGE;

Obj             QuoFFEFFE (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fL, fR, fX;     /* field of left, right, result    */
    UInt                qL, qR, qX;     /* size  of left, right, result    */

    /* get the values, handle trivial cases                                */
    vL = VAL_FFE( opL );
    vR = VAL_FFE( opR );

    /* bring the two operands into a common field <fX>                     */
    fL = FLD_FFE( opL );
    qL = SIZE_FF( fL );
    fR = FLD_FFE( opR );
    qR = SIZE_FF( fR  );

    /*N 1997/01/04 mschoene this is likely to explode if 'FFV' is 'UInt4'  */
    if ( qL == qR ) {
        fX = fL;
    }
    else if ( qL % qR == 0 && (qL-1) % (qR-1) == 0 ) {
        fX = fL;
        if ( vR != 0 )  vR = (qL-1) / (qR-1) * (vR-1) + 1;
    }
    else if ( qR % qL == 0 && (qR-1) % (qL-1) == 0 ) {
        fX = fR;
        if ( vL != 0 )  vL = (qR-1) / (qL-1) * (vL-1) + 1;
    }
    else {
        fX = CommonFF( fL, DegreeFFE(opL), fR, DegreeFFE(opR) );
        if ( fX == 0 )  return CALL_2ARGS( QUO_FFE_LARGE, opL, opR );
        qX = SIZE_FF( fX );
        /* if ( vL != 0 )  vL = (qX-1) / (qL-1) * (vL-1) + 1; */
        if ( vL != 0 )  vL = ((qX-1) * (vL-1)) / (qL-1) + 1;
        /* if ( vR != 0 )  vR = (qX-1) / (qR-1) * (vR-1) + 1; */
        if ( vR != 0 )  vR = ((qX-1) * (vR-1)) / (qR-1) + 1;
    }

    /* compute and return the result                                       */
    if ( vR == 0 ) {
        opR = ErrorReturnObj(
            "FFE operations: <divisor> must not be zero",
            0L, 0L,
            "you can replace <divisor> via 'return <divisor>;'" );
        return QUO( opL, opR );
    }
    vX = QUO_FFV( vL, vR, SUCC_FF(fX) );
    return NEW_FFE( fX, vX );
}

Obj             QuoFFEInt (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fX;             /* field of result                 */
    Int                 pX;             /* char. of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( opL );
    pX = CHAR_FF( fX );
    sX = SUCC_FF( fX );

    /* get the right operand                                               */
    vX = ((INT_INTOBJ( opR ) % pX) + pX) % pX;
    if ( vX == 0 ) {
        vR = 0;
    }
    else {
        vR = 1;
        for ( ; 1 < vX; vX-- )  vR = sX[vR];
    }

    /* get the left operand                                                */
    vL = VAL_FFE( opL );

    /* compute and return the result                                       */
    if ( vR == 0 ) {
        opR = ErrorReturnObj(
            "FFE operations: <divisor> must not be zero",
            0L, 0L,
            "you can replace <divisor> via 'return <divisor>;'" );
        return QUO( opL, opR );
    }
    vX = QUO_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}

Obj             QuoIntFFE (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vR, vX;     /* value of left, right, result    */
    FF                  fX;             /* field of result                 */
    Int                 pX;             /* char. of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( opR );
    pX = CHAR_FF( fX );
    sX = SUCC_FF( fX );

    /* get the left operand                                                */
    vX = ((INT_INTOBJ( opL ) % pX) + pX) % pX;
    if ( vX == 0 ) {
        vL = 0;
    }
    else {
        vL = 1;
        for ( ; 1 < vX; vX-- )  vL = sX[vL];
    }

    /* get the right operand                                               */
    vR = VAL_FFE( opR );

    /* compute and return the result                                       */
    if ( vR == 0 ) {
        opR = ErrorReturnObj(
            "FFE operations: <divisor> must not be zero",
            0L, 0L,
            "you can replace <divisor> via 'return <divisor>;'" );
        return QUO( opL, opR );
    }
    vX = QUO_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}


/****************************************************************************
**
*F  PowFFEInt(<opL>,<opR>)  . . . . . . . . . power of a finite field element
**
**  'PowFFEInt' returns the  power of the finite  field element <opL> and the
**  integer <opR>.  The power is  represented over the  field over which  the
**  left operand is represented, even if it lies in a much smaller field.
**
**  'PowFFEInt' just does the conversions mentioned  above and then calls the
**  macro 'POW_FFV' to do the actual exponentiation.
*/
Obj             PowFFEInt (
    Obj                 opL,
    Obj                 opR )
{
    FFV                 vL, vX;         /* value of left, result           */
    Int                 vR;             /* value of right                  */
    FF                  fX;             /* field of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( opL );
    sX = SUCC_FF( fX );

    /* get the right operand                                               */
    vR = INT_INTOBJ( opR );

    /* get the left operand                                                */
    vL = VAL_FFE( opL );

    /* if the exponent is negative, invert the left operand                */
    if ( vR < 0 ) {
        if ( vL == 0 ) {
            opL = ErrorReturnObj(
                "FFE operations: <divisor> must not be zero",
                0L, 0L,
                "you can replace <divisor> via 'return <divisor>;'" );
            return POW( opL, opR );
        }
        vL = QUO_FFV( 1, vL, sX );
        vR = -vR;
    }

    /* catch the case when vL is zero.                                     */
    if( vL == 0 ) return NEW_FFE( fX, (vR == 0 ? 1 : 0 ) );

    /* reduce vR modulo the order of the multiplicative group first.       */
    vR %= *sX;

    /* compute and return the result                                       */
    vX = POW_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}


/****************************************************************************
**
*F  PowFFEFFE( <opL>, <opR> ) . . . . . . conjugate of a finite field element
*/
Obj PowFFEFFE (
    Obj                 opL,
    Obj                 opR )
{
    /* get the field for the result                                        */
    if ( CHAR_FF( FLD_FFE(opL) ) != CHAR_FF( FLD_FFE(opR) ) ) {
        opR = ErrorReturnObj(
          "FFE operations: characteristic of conjugating element must be %d",
          (Int)CHAR_FF(FLD_FFE(opL)), 0L,
          "you can replace conjugating element <elt> via 'return <elt>;'" );
        return POW( opL, opR );
    }

    /* compute and return the result                                       */
    return opL;
}


/****************************************************************************
**
*F  FuncIS_FFE( <self>, <obj> ) . . . . . . .  test for finite field elements
**
**  'FuncIsFFE' implements the internal function 'IsFFE( <obj> )'.
**
**  'IsFFE' returns  'true' if its argument  <obj> is a finite  field element
**  and 'false' otherwise.   'IsFFE' will cause  an  error if  called with an
**  unbound variable.
*/
Obj IsFFEFilt;

Obj FuncIS_FFE (
    Obj                 self,
    Obj                 obj )
{
    /* return 'true' if <obj> is a finite field element                    */
    if ( IS_FFE(obj) ) {
        return True;
    }
    else if ( TNUM_OBJ(obj) < FIRST_EXTERNAL_TNUM ) {
        return False;
    }
    else {
        return DoFilter( self, obj );
    }
}


/****************************************************************************
**
*F  FuncLOG_FFE_DEFAULT( <self>, <opZ>, <opR> ) .  logarithm of a ff constant
**
**  'FuncLOG_FFE_DEFAULT' implements the function 'LogFFE( <z>, <r> )'.
**
**  'LogFFE'  returns the logarithm of  the nonzero finite  field element <z>
**  with respect to the root <r> which must lie in the same field like <z>.
*/
Obj LOG_FFE_LARGE;

Obj FuncLOG_FFE_DEFAULT (
    Obj                 self,
    Obj                 opZ,
    Obj                 opR )
{
    FFV                 vZ, vR;         /* value of left, right            */
    FF                  fZ, fR, fX;     /* field of left, right, common    */
    UInt                qZ, qR, qX;     /* size  of left, right, common    */
    Int                 a, b, c, d, t;  /* temporaries                     */

    /* check the arguments                                                 */
    if ( ! IS_FFE(opZ) || VAL_FFE(opZ) == 0 ) {
        opZ = ErrorReturnObj(
            "LogFFE: <z> must be a nonzero finite field element",
             0L, 0L,
             "you can replace <z> via 'return <z>;'" );
        return FuncLOG_FFE_DEFAULT( self, opZ, opR );
    }
    if ( ! IS_FFE(opR) || VAL_FFE(opR) == 0 ) {
        opR = ErrorReturnObj(
            "LogFFE: <r> must be a nonzero finite field element",
             0L, 0L,
             "you can replace <r> via 'return <r>;'" );
        return FuncLOG_FFE_DEFAULT( self, opZ, opR );
    }

    /* get the values, handle trivial cases                                */
    vZ = VAL_FFE( opZ );
    vR = VAL_FFE( opR );

    /* bring the two operands into a common field <fX>                     */
    fZ = FLD_FFE( opZ );
    qZ = SIZE_FF( fZ );
    fR = FLD_FFE( opR );
    qR = SIZE_FF( fR  );

    /*N 1997/01/04 mschoene this is likely to explode if 'FFV' is 'UInt4'  */
    if ( qZ == qR ) {
        fX = fZ;
        qX = qZ;
    }
    else if ( qZ % qR == 0 && (qZ-1) % (qR-1) == 0 ) {
        fX = fZ;
        qX = qZ;
        if ( vR != 0 )  vR = (qZ-1) / (qR-1) * (vR-1) + 1;
    }
    else if ( qR % qZ == 0 && (qR-1) % (qZ-1) == 0 ) {
        fX = fR;
        qX = qR;
        if ( vZ != 0 )  vZ = (qR-1) / (qZ-1) * (vZ-1) + 1;
    }
    else {
        fX = CommonFF( fZ, DegreeFFE(opZ), fR, DegreeFFE(opR) );
        if ( fX == 0 )  return CALL_2ARGS( LOG_FFE_LARGE, opZ, opR );
        qX = SIZE_FF( fX );
        /* if ( vZ != 0 )  vZ = (qX-1) / (qZ-1) * (vZ-1) + 1; */
        if ( vZ != 0 )  vZ = ((qX-1) * (vZ-1)) / (qZ-1) + 1;
        /* if ( vR != 0 )  vR = (qX-1) / (qR-1) * (vR-1) + 1; */
        if ( vR != 0 )  vR = ((qX-1) * (vR-1)) / (qR-1) + 1;
    }

    /* now solve <l> * (<vR>-1) = (<vZ>-1) % (<qX>-1)                      */
    /*N 1990/02/04 mschoene this is likely to explode if 'FFV' is 'UInt4'  */
    a = 1;             b = 0;
    c = (Int) (vR-1);  d = (Int) (qX-1);
    while ( d != 0 ) {
        t = b;  b = a - (c/d) * b;  a = t;
        t = d;  d = c - (c/d) * d;  c = t;
    }
    if ( ((Int) (vZ-1)) % c != 0 ) {
      return Fail;
    }


    while (a < 0)
      a+= (qX -1)/c;
    /* return the logarithm                                                */
    

    return INTOBJ_INT( (((Int) (vZ-1) / c) * a) % ((Int) (qX-1)) );

}


/****************************************************************************
**
*F  FuncINT_FFE_DEFAULT( <self>, <z> )  . . . .   convert a ffe to an integer
**
**  'FuncINT_FFE_DEFAULT' implements the internal function 'IntFFE( <z> )'.
**
**  'IntFFE'  returns  the integer  that  corresponds  to  the  finite  field
**  element <z>, which must of course be  an element  of a prime field, i.e.,
**  the smallest integer <i> such that '<i> * <z>^0 = <z>'.
*/
Obj IntFF;

Obj INT_FF (
    FF                  ff )
{
    Obj                 conv;           /* conversion table, result        */
    Int                 q;              /* size of finite field            */
    Int                 p;              /* char of finite field            */
    const FFV *         succ;           /* successor table of finite field */
    FFV                 z;              /* one element of finite field     */
    UInt                i;              /* loop variable                   */

    /* if the conversion table is not already known, construct it          */
    if ( LEN_PLIST(IntFF) < ff || ELM_PLIST(IntFF,ff) == 0 ) {
        q = SIZE_FF( ff );
        p = CHAR_FF( ff );
        conv = NEW_PLIST( T_PLIST+IMMUTABLE, p-1 );
        succ = SUCC_FF( ff );
        SET_LEN_PLIST( conv, p-1 );
        z = 1;
        for ( i = 1; i < p; i++ ) {
            SET_ELM_PLIST( conv, (z-1)/((q-1)/(p-1))+1, INTOBJ_INT(i) );
            z = succ[ z ];
        }
        AssPlist( IntFF, ff, conv );
    }

    /* return the conversion table                                           */
    return ELM_PLIST( IntFF, ff );
}



Obj FuncINT_FFE_DEFAULT (
    Obj                 self,
    Obj                 z )
{
    FFV                 v;              /* value of finite field element   */
    FF                  ff;             /* finite field                    */
    Int                 q;              /* size of finite field            */
    Int                 p;              /* char of finite field            */
    Obj                 conv;           /* conversion table                */

    /* get the value                                                       */
    v  = VAL_FFE( z );

    /* special case for 0                                                  */
    if ( v == 0 ) {
        return INTOBJ_INT( 0 );
    }

    /* get the field, size, characteristic, and conversion table           */
    ff   = FLD_FFE( z );
    q    = SIZE_FF( ff );
    p    = CHAR_FF( ff );
    conv = INT_FF( ff );

    /* check the argument                                                  */
    if ( (v-1) % ((q-1)/(p-1)) != 0 ) {
        z = ErrorReturnObj(
            "IntFFE: <z> must lie in prime field",
            0L, 0L,
            "you can replace <z> via 'return <z>;'" );
        return FuncINT_FFE_DEFAULT( self, z );
    }

    /* convert the value into the prime field                              */
    v = (v-1) / ((q-1)/(p-1)) + 1;

    /* return the integer value                                            */
    return ELM_PLIST( conv, v );
}


/****************************************************************************
**
*F  FuncZ( <self>, <q> )  . . .  return the generator of a small finite field
**
**  'FuncZ' implements the internal function 'Z( <q> )'.
**
**  'Z' returns the generators  of the small finite  field with <q> elements.
**  <q> must be a positive prime power.
*/
static Obj ZOp;




Obj FuncZ (
    Obj                 self,
    Obj                 q )
{
    FF                  ff;             /* the finite field                */
    UInt                p;              /* characteristic                  */
    UInt                d;              /* degree                          */
    UInt                r;              /* temporary                       */

    /* check the argument                                                  */
    if ( (IS_INTOBJ(q) && (INT_INTOBJ(q) > 65536)) ||
         (TNUM_OBJ(q) == T_INTPOS))
      return CALL_1ARGS(ZOp, q);
    
    if ( !IS_INTOBJ(q) || INT_INTOBJ(q)<=1 ) {
        q = ErrorReturnObj(
            "Z: <q> must be a positive prime power (not a %s)",
            (Int)TNAM_OBJ(q), 0L,
            "you can replace <q> via 'return <q>;'" );
        return FuncZ( self, q );
    }

    /* compute the prime and check that <q> is a prime power               */
    if ( INT_INTOBJ(q) % 2 == 0 ) {
        p = 2;
    }
    else {
        p = 3;
        while ( INT_INTOBJ(q) % p != 0 ) {
            p += 2;
        }
    }
    d = 1;
    r = p;
    while ( r < INT_INTOBJ(q) ) {
        d = d + 1;
        r = r * p;
    }
    if ( r != INT_INTOBJ(q) ) {
        q = ErrorReturnObj(
            "Z: <q> must be a positive prime power (not a %s)",
            (Int)TNAM_OBJ(q), 0L,
            "you can replace <q> via 'return <q>;'" );
        return FuncZ( self, q );
    }

    /* get the finite field                                                */
    ff = FiniteField( p, d );

    /* make the root                                                       */
    return NEW_FFE( ff, (p == 2 && d == 1 ? 1 : 2) );
}

Obj FuncZ2 ( Obj self, Obj p, Obj d)
{
  FF ff;
  Int ip,id,id1;
  UInt q;
  if (ARE_INTOBJS(p,d))
    {
      ip = INT_INTOBJ(p);
      id = INT_INTOBJ(d);
      if (ip > 1 && id > 0 && id <= 16 && ip <= 65536)
        {
          id1 = id;
          q = ip;
          while (--id1 > 0 && q <= 65536)
            q *= ip;
          if (q <= 65536)
            {
              /* get the finite field                                                */
              ff = FiniteField( ip, id );

              if ( ff == 0 || CHAR_FF(ff) != ip )
                ErrorMayQuit("Z: <p> must be a prime", 0, 0);

              /* make the root                                                       */
              return NEW_FFE( ff, (ip == 2 && id == 1 ? 1 : 2) );
            }
        }
    }
  return CALL_2ARGS(ZOp, p, d);
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

    GVAR_FILTER(IS_FFE, "obj", &IsFFEFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(CHAR_FFE_DEFAULT, 1, "z"),
    GVAR_FUNC(DEGREE_FFE_DEFAULT, 1, "z"),
    GVAR_FUNC(LOG_FFE_DEFAULT, 2, "z, root"),
    GVAR_FUNC(INT_FFE_DEFAULT, 1, "z"),
    GVAR_FUNC(Z, 1, "q"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* install the marking function                                        */
    InfoBags[ T_FFE ].name = "ffe";
    /* InitMarkFuncBags( T_FFE, MarkNoSubBags ); */

    /* install the type functions                                          */
    ImportFuncFromLibrary( "TYPE_FFE", &TYPE_FFE );
    ImportFuncFromLibrary( "TYPE_FFE0", &TYPE_FFE0 );
    ImportFuncFromLibrary( "ZOp", &ZOp );
    TypeObjFuncs[ T_FFE ] = TypeFFE;

    /* create the fields and integer conversion bags                       */
    InitGlobalBag( &SuccFF, "src/finfield.c:SuccFF" );
    InitGlobalBag( &TypeFF, "src/finfield.c:TypeFF" );
    InitGlobalBag( &TypeFF0, "src/finfield.c:TypeFF0" );
    InitGlobalBag( &IntFF, "src/finfield.c:IntFF" );

    /* install the functions that handle overflow                          */
    ImportFuncFromLibrary( "SUM_FFE_LARGE",  &SUM_FFE_LARGE  );
    ImportFuncFromLibrary( "DIFF_FFE_LARGE", &DIFF_FFE_LARGE );
    ImportFuncFromLibrary( "PROD_FFE_LARGE", &PROD_FFE_LARGE );
    ImportFuncFromLibrary( "QUO_FFE_LARGE",  &QUO_FFE_LARGE  );
    ImportFuncFromLibrary( "LOG_FFE_LARGE",  &LOG_FFE_LARGE  );

    ImportGVarFromLibrary( "TYPE_KERNEL_OBJECT", &TYPE_KERNEL_OBJECT );
    
    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );
    InitHandlerFunc( FuncZ2, "src/finfield.c: Z (2 args)");


    /* install the printing method                                         */
    PrintObjFuncs[ T_FFE ] = PrFFE;

    /* install the comparison methods                                      */
    EqFuncs[   T_FFE ][ T_FFE ] = EqFFE;
    LtFuncs[   T_FFE ][ T_FFE ] = LtFFE;

    /* install the arithmetic methods                                      */
    ZeroFuncs[ T_FFE ] = ZeroFFE;
    ZeroMutFuncs[ T_FFE ] = ZeroFFE;
    AInvFuncs[ T_FFE ] = AInvFFE;
    AInvMutFuncs[ T_FFE ] = AInvFFE;
    OneFuncs [ T_FFE ] = OneFFE;
    OneMutFuncs [ T_FFE ] = OneFFE;
    InvFuncs [ T_FFE ] = InvFFE;
    InvMutFuncs [ T_FFE ] = InvFFE;
    SumFuncs[  T_FFE ][ T_FFE ] = SumFFEFFE;
    SumFuncs[  T_FFE ][ T_INT ] = SumFFEInt;
    SumFuncs[  T_INT ][ T_FFE ] = SumIntFFE;
    DiffFuncs[ T_FFE ][ T_FFE ] = DiffFFEFFE;
    DiffFuncs[ T_FFE ][ T_INT ] = DiffFFEInt;
    DiffFuncs[ T_INT ][ T_FFE ] = DiffIntFFE;
    ProdFuncs[ T_FFE ][ T_FFE ] = ProdFFEFFE;
    ProdFuncs[ T_FFE ][ T_INT ] = ProdFFEInt;
    ProdFuncs[ T_INT ][ T_FFE ] = ProdIntFFE;
    QuoFuncs[  T_FFE ][ T_FFE ] = QuoFFEFFE;
    QuoFuncs[  T_FFE ][ T_INT ] = QuoFFEInt;
    QuoFuncs[  T_INT ][ T_FFE ] = QuoIntFFE;
    PowFuncs[  T_FFE ][ T_INT ] = PowFFEInt;
    PowFuncs[  T_FFE ][ T_FFE ] = PowFFEFFE;

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
    /* create the fields and integer conversion bags                       */
    SuccFF = NEW_PLIST( T_PLIST, NUM_SHORT_FINITE_FIELDS );
    SET_LEN_PLIST( SuccFF, NUM_SHORT_FINITE_FIELDS );

    TypeFF = NEW_PLIST( T_PLIST, NUM_SHORT_FINITE_FIELDS );
    SET_LEN_PLIST( TypeFF, NUM_SHORT_FINITE_FIELDS );

    TypeFF0 = NEW_PLIST( T_PLIST, NUM_SHORT_FINITE_FIELDS );
    SET_LEN_PLIST( TypeFF0, NUM_SHORT_FINITE_FIELDS );

    IntFF = NEW_PLIST( T_PLIST, NUM_SHORT_FINITE_FIELDS );
    SET_LEN_PLIST( IntFF, NUM_SHORT_FINITE_FIELDS );

    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );
    SET_HDLR_FUNC(ValGVar(GVarName("Z")), 2, FuncZ2);

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoFinfield()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "finfield",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoFinfield ( void )
{
    return &module;
}
