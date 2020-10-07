/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the  functions  to compute  with elements  from  small
**  finite fields.
**
**  The concepts of this kernel module are documented in finfield.h
*/

#include "finfield.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "error.h"
#include "finfield_conway.h"
#include "gvars.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#include "hpc/thread.h"
#endif

/****************************************************************************
**
*V  SuccFF  . . . . .  Tables for finite fields which are computed on demand
*V  TypeFF
*V  TypeFF0
**
**  SuccFF holds a plain list of successor lists.
**  TypeFF holds the types of typical elements of the finite fields.
**  TypeFF0 holds the types of the zero elements of the finite fields.
*/

Obj SuccFF;
static Obj TypeFF;
static Obj TypeFF0;


/****************************************************************************
**
*V  TYPE_FFE  . . . . . kernel copy of GAP function TYPE_FFE
*V  TYPE_FFE0 . . . . . kernel copy of GAP function TYPE_FFE0
**
**  These GAP functions are called to compute types of finite field elemnents
*/
static Obj TYPE_FFE;
static Obj TYPE_FFE0;

/****************************************************************************
**
*V  PrimitiveRootMod
**
**  Local copy of GAP function PrimitiveRootMod, used when initializing new
**  fields.
*/
static Obj PrimitiveRootMod;


/****************************************************************************
**
*F  LookupPrimePower(<q>) . . . . . . . .  search for a prime power in tables
**
**  Searches the tables of prime powers from ffdata.c for q, returns the
**  index of q in SizeFF if it is present and 0 if not (the 0 position of
**  SizeFF is unused).
*/
static FF LookupPrimePower(UInt q)
{
    UInt l, n;
    FF   ff;
    UInt e;

    /* search through the finite field table                               */
    l = 1;
    n = NUM_SHORT_FINITE_FIELDS;
    ff = 0;
    while (l <= n && SizeFF[l] <= q && q <= SizeFF[n]) {
        /* interpolation search */
        /* cuts iterations roughly in half compared to binary search at
         * the expense of additional divisions. */
        e = (q - SizeFF[l] + 1) * (n - l) / (SizeFF[n] - SizeFF[l] + 1);
        ff = l + e;
        if (SizeFF[ff] == q)
            break;
        if (SizeFF[ff] < q)
            l = ff + 1;
        else
            n = ff - 1;
    }
    if (ff < 1 || ff > NUM_SHORT_FINITE_FIELDS)
        return 0;
    if (SizeFF[ff] != q)
        return 0;
    return ff;
}


/****************************************************************************
**
*F  FiniteField(<p>,<d>) .  make the small finite field with <p>^<d> elements
*F  FiniteFieldBySize(<q>) . .  make the small finite field with <q> elements
**
**  The work is done in the Lookup function above, and in FiniteFieldBySize
**  where the successor tables are computed.
*/

FF FiniteFieldBySize(UInt q)
{
    FF    ff;            /* finite field, result            */
    Obj   tmp;           /* temporary bag                   */
    Obj   succBag;       /* successor table bag             */
    FFV * succ;          /* successor table                 */
    FFV * indx;          /* index table                     */
    UInt  p;             /* characteristic of the field     */
    UInt  poly;          /* Conway polynomial of extension  */
    UInt  i, l, f, n, e; /* loop variables                  */
    Obj   root;          /* will be a primitive root mod p  */

    ff = LookupPrimePower(q);
    if (!ff)
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

    // determine the characteristic of the field
    p = CHAR_FF(ff);

    /* allocate a bag for the successor table and one for a temporary */
    tmp = NewKernelBuffer(sizeof(Obj) + q * sizeof(FFV));
    succBag = NewKernelBuffer(sizeof(Obj) + q * sizeof(FFV));

    indx = (FFV *)(1 + ADDR_OBJ(tmp));
    succ = (FFV *)(1 + ADDR_OBJ(succBag));

    /* if q is a prime find the smallest primitive root $e$, use $x - e$   */

    if (DEGR_FF(ff) == 1) {
        if (p < 65537) {
            /* for smaller primes we do this in the kernel for performance and
            bootstrapping reasons
            TODO -- review the threshold */
            for (e = 1, i = 1; i != p - 1; ++e) {
                for (f = e, i = 1; f != 1; ++i)
                    f = (f * e) % p;
            }
        }
        else {
            /* Otherwise we ask the library */
            root = CALL_1ARGS(PrimitiveRootMod, INTOBJ_INT(p));
            e = INT_INTOBJ(root) + 1;
        }
        poly = p - (e - 1);
    }

    /* otherwise look up the polynomial used to construct this field       */
    else {
        for (i = 0; PolsFF[i] != q; i += 2)
            ;
        poly = PolsFF[i + 1];
    }

    /* construct 'indx' such that 'e = x^(indx[e]-1) % poly' for every e   */
    indx[0] = 0;
    for (e = 1, n = 0; n < q - 1; ++n) {
        indx[e] = n + 1;
        /* e =p*e mod poly =x*e mod poly =x*x^n mod poly =x^{n+1} mod poly */
        if (p != 2) {
            f = p * (e % (q / p));
            l = ((p - 1) * (e / (q / p))) % p;
            e = 0;
            for (i = 1; i < q; i *= p)
                e = e + i * ((f / i + l * (poly / i)) % p);
        }
        else {
            if (2 * e & q)
                e = 2 * e ^ poly ^ q;
            else
                e = 2 * e;
        }
    }

    /* construct 'succ' such that 'x^(n-1)+1 = x^(succ[n]-1)' for every n  */
    succ[0] = q - 1;
    for (e = 1, f = p - 1; e < q; e++) {
        if (e < f) {
            succ[indx[e]] = indx[e + 1];
        }
        else {
            succ[indx[e]] = indx[e + 1 - p];
            f += p;
        }
    }

    /* enter the finite field in the tables                                */
#ifdef HPCGAP
    MakeBagReadOnly(succBag);
    ATOMIC_SET_ELM_PLIST_ONCE(SuccFF, ff, succBag);
    CHANGED_BAG(SuccFF);
    tmp = CALL_1ARGS(TYPE_FFE, INTOBJ_INT(p));
    ATOMIC_SET_ELM_PLIST_ONCE(TypeFF, ff, tmp);
    CHANGED_BAG(TypeFF);
    tmp = CALL_1ARGS(TYPE_FFE0, INTOBJ_INT(p));
    ATOMIC_SET_ELM_PLIST_ONCE(TypeFF0, ff, tmp);
    CHANGED_BAG(TypeFF0);
#else
    ASS_LIST(SuccFF, ff, succBag);
    CHANGED_BAG(SuccFF);
    tmp = CALL_1ARGS(TYPE_FFE, INTOBJ_INT(p));
    ASS_LIST(TypeFF, ff, tmp);
    CHANGED_BAG(TypeFF);
    tmp = CALL_1ARGS(TYPE_FFE0, INTOBJ_INT(p));
    ASS_LIST(TypeFF0, ff, tmp);
    CHANGED_BAG(TypeFF0);
#endif

    /* return the finite field                                             */
    return ff;
}

FF FiniteField(UInt p, UInt d)
{
    UInt q, i;
    FF   ff;

    q = 1;
    for (i = 1; i <= d; i++)
        q *= p;

    ff = FiniteFieldBySize(q);
    if (ff != 0 && CHAR_FF(ff) != p)
        return 0;
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

    /* compute the necessary degree                                       */
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

static Obj FuncCHAR_FFE_DEFAULT(Obj self, Obj ffe)
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
        return 1;
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

static Obj FuncDEGREE_FFE_DEFAULT(Obj self, Obj ffe)
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
Obj TypeFFE(Obj ffe)
{
    Obj types = (VAL_FFE(ffe) == 0) ? TypeFF0 : TypeFF;
#ifdef HPCGAP
    return ATOMIC_ELM_PLIST(types, FLD_FFE(ffe));
#else
    return ELM_PLIST(types, FLD_FFE(ffe));
#endif
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
static Int EqFFE(Obj opL, Obj opR)
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
        return 0;
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
        return 0;
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
static Int LtFFE(Obj opL, Obj opR)
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
static void PrFFV(FF fld, FFV val)
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
        Pr("%>0*Z(%>%d%2<)", (Int)p, 0);
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
        Pr("%>Z(%>%d%<", (Int)p, 0);
        if ( d == 1 ) {
            Pr("%<)", 0, 0);
        }
        else {
            Pr("^%>%d%2<)", (Int)d, 0);
        }
        if ( val != 2 ) {
            Pr("^%>%d%<", (Int)(val-1), 0);
        }
    }

}


/****************************************************************************
**
*F  PrFFE(<ffe>)  . . . . . . . . . . . . . . .  print a finite field element
**
**  'PrFFE' prints the finite field element <ffe>.
*/
static void PrFFE(Obj ffe)
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
static Obj SUM_FFE_LARGE;

static Obj SumFFEFFE(Obj opL, Obj opR)
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

    vX = SUM_FFV( vL, vR, SUCC_FF(fX) );
    return NEW_FFE( fX, vX );
}

static Obj SumFFEInt(Obj opL, Obj opR)
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

    vX = SUM_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}

static Obj SumIntFFE(Obj opL, Obj opR)
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

    vX = SUM_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}


/****************************************************************************
**
*F  ZeroFFE(<op>) . . . . . . . . . . . . . .  zero of a finite field element
*/
static Obj ZeroFFE(Obj op)
{
    FF                  fX;             /* field of result                 */

    /* get the field for the result                                        */
    fX = FLD_FFE( op );

    return NEW_FFE( fX, 0 );
}


/****************************************************************************
**
*F  AInvFFE(<op>) . . . . . . . . . . additive inverse of finite field element
*/
static Obj AInvFFE(Obj op)
{
    FFV                 v, vX;          /* value of operand, result        */
    FF                  fX;             /* field of result                 */
    const FFV*          sX;             /* successor table of result field */

    /* get the field for the result                                        */
    fX = FLD_FFE( op );
    sX = SUCC_FF( fX );

    /* get the operand                                                     */
    v = VAL_FFE( op );

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
static Obj DIFF_FFE_LARGE;

static Obj DiffFFEFFE(Obj opL, Obj opR)
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

    vR = NEG_FFV( vR, SUCC_FF(fX) );
    vX = SUM_FFV( vL, vR, SUCC_FF(fX) );
    return NEW_FFE( fX, vX );
}

static Obj DiffFFEInt(Obj opL, Obj opR)
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

    vR = NEG_FFV( vR, sX );
    vX = SUM_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}

static Obj DiffIntFFE(Obj opL, Obj opR)
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
static Obj PROD_FFE_LARGE;

static Obj ProdFFEFFE(Obj opL, Obj opR)
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

    vX = PROD_FFV( vL, vR, SUCC_FF(fX) );
    return NEW_FFE( fX, vX );
}

static Obj ProdFFEInt(Obj opL, Obj opR)
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

    vX = PROD_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}

static Obj ProdIntFFE(Obj opL, Obj opR)
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

    vX = PROD_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}


/****************************************************************************
**
*F  OneFFE(<op>)  . . . . . . . . . . . . . . . one of a finite field element
*/
static Obj OneFFE(Obj op)
{
    FF                  fX;             /* field of result                 */

    /* get the field for the result                                        */
    fX = FLD_FFE( op );

    return NEW_FFE( fX, 1 );
}


/****************************************************************************
**
*F  InvFFE(<op>)  . . . . . . . . . . . . . . inverse of finite field element
*/
static Obj InvFFE(Obj op)
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
static Obj QUO_FFE_LARGE;

static Obj QuoFFEFFE(Obj opL, Obj opR)
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

    if ( vR == 0 ) {
        ErrorMayQuit("FFE operations: <divisor> must not be zero", 0, 0);
    }
    vX = QUO_FFV( vL, vR, SUCC_FF(fX) );
    return NEW_FFE( fX, vX );
}

static Obj QuoFFEInt(Obj opL, Obj opR)
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

    if ( vR == 0 ) {
        ErrorMayQuit("FFE operations: <divisor> must not be zero", 0, 0);
    }
    vX = QUO_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}

static Obj QuoIntFFE(Obj opL, Obj opR)
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

    if ( vR == 0 ) {
        ErrorMayQuit("FFE operations: <divisor> must not be zero", 0, 0);
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
static Obj PowFFEInt(Obj opL, Obj opR)
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
            ErrorMayQuit("FFE operations: <divisor> must not be zero", 0, 0);
        }
        vL = QUO_FFV( 1, vL, sX );
        vR = -vR;
    }

    /* catch the case when vL is zero.                                     */
    if( vL == 0 ) return NEW_FFE( fX, (vR == 0 ? 1 : 0 ) );

    /* reduce vR modulo the order of the multiplicative group first.       */
    vR %= *sX;

    vX = POW_FFV( vL, vR, sX );
    return NEW_FFE( fX, vX );
}


/****************************************************************************
**
*F  PowFFEFFE( <opL>, <opR> ) . . . . . . conjugate of a finite field element
*/
static Obj PowFFEFFE(Obj opL, Obj opR)
{
    /* get the field for the result                                        */
    if ( CHAR_FF( FLD_FFE(opL) ) != CHAR_FF( FLD_FFE(opR) ) ) {
        ErrorMayQuit("<x> and <y> have different characteristic", 0, 0);
    }

    return opL;
}


/****************************************************************************
**
*F  FiltIS_FFE( <self>, <obj> ) . . . . . . .  test for finite field elements
**
**  'FuncIsFFE' implements the internal function 'IsFFE( <obj> )'.
**
**  'IsFFE' returns  'true' if its argument  <obj> is a finite  field element
**  and 'false' otherwise.   'IsFFE' will cause  an  error if  called with an
**  unbound variable.
*/
static Obj IsFFEFilt;

static Obj FiltIS_FFE(Obj self, Obj obj)
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
static Obj LOG_FFE_LARGE;

static Obj FuncLOG_FFE_DEFAULT(Obj self, Obj opZ, Obj opR)
{
    FFV                 vZ, vR;         /* value of left, right            */
    FF                  fZ, fR, fX;     /* field of left, right, common    */
    UInt                qZ, qR, qX;     /* size  of left, right, common    */
    Int                 a, b, c, d, t;  /* temporaries                     */

    if (!IS_FFE(opZ) || VAL_FFE(opZ) == 0) {
        ErrorMayQuit("LogFFE: <z> must be a nonzero finite field element", 0,
                     0);
    }
    if (!IS_FFE(opR) || VAL_FFE(opR) == 0) {
        ErrorMayQuit("LogFFE: <r> must be a nonzero finite field element", 0,
                     0);
    }

    /* get the values, handle trivial cases                                */
    vZ = VAL_FFE( opZ );
    vR = VAL_FFE( opR );

    /* bring the two operands into a common field <fX>                     */
    fZ = FLD_FFE( opZ );
    qZ = SIZE_FF( fZ );
    fR = FLD_FFE( opR );
    qR = SIZE_FF( fR  );

    if ( qZ == qR ) {
        qX = qZ;
    }
    else if ( qZ % qR == 0 && (qZ-1) % (qR-1) == 0 ) {
        qX = qZ;
        if ( vR != 0 )  vR = (qZ-1) / (qR-1) * (vR-1) + 1;
    }
    else if ( qR % qZ == 0 && (qR-1) % (qZ-1) == 0 ) {
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

    // return the logarithm
    return INTOBJ_INT( (((UInt) (vZ-1) / c) * a) % ((UInt) (qX-1)) );
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
static Obj IntFF;
#ifdef HPCGAP
static Int NumFF;
#endif

static Obj INT_FF(FF ff)
{
    Obj                 conv;           /* conversion table, result        */
    Int                 q;              /* size of finite field            */
    Int                 p;              /* char of finite field            */
    const FFV *         succ;           /* successor table of finite field */
    FFV                 z;              /* one element of finite field     */
    UInt                i;              /* loop variable                   */

    /* if the conversion table is not already known, construct it          */
#ifdef HPCGAP
    if ( NumFF < ff || (MEMBAR_READ(), ATOMIC_ELM_PLIST(IntFF, ff) == 0)) {
        HashLock(&IntFF);
#else
    if ( LEN_PLIST(IntFF) < ff || ELM_PLIST(IntFF,ff) == 0 ) {
#endif
        q = SIZE_FF( ff );
        p = CHAR_FF( ff );
        conv = NEW_PLIST_IMM( T_PLIST, p-1 );
        succ = SUCC_FF( ff );
        SET_LEN_PLIST( conv, p-1 );
        z = 1;
        for ( i = 1; i < p; i++ ) {
            SET_ELM_PLIST( conv, (z-1)/((q-1)/(p-1))+1, INTOBJ_INT(i) );
            z = succ[ z ];
        }
#ifdef HPCGAP
        GrowPlist(IntFF, ff);
        ATOMIC_SET_ELM_PLIST( IntFF, ff, conv );
        MEMBAR_WRITE();
        NumFF = LEN_PLIST(IntFF);
        HashUnlock(&IntFF);
#else
        AssPlist( IntFF, ff, conv );
#endif
    }

    /* return the conversion table                                           */
#ifdef HPCGAP
    return ATOMIC_ELM_PLIST( IntFF, ff);
#else
    return ELM_PLIST( IntFF, ff );
#endif
}


static Obj FuncINT_FFE_DEFAULT(Obj self, Obj z)
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
        ErrorMayQuit("IntFFE: <z> must lie in prime field", 0, 0);
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

static Obj FuncZ(Obj self, Obj q)
{
    FF                  ff;             /* the finite field                */

    /* check the argument                                                  */
    if ( (IS_INTOBJ(q) && (INT_INTOBJ(q) > 65536)) ||
         (TNUM_OBJ(q) == T_INTPOS))
      return CALL_1ARGS(ZOp, q);
    
    if ( !IS_INTOBJ(q) || INT_INTOBJ(q)<=1 ) {
        RequireArgument(SELF_NAME, q, "must be a positive prime power");
    }

    ff = FiniteFieldBySize(INT_INTOBJ(q));

    if (!ff) {
        RequireArgument(SELF_NAME, q, "must be a positive prime power");
    }

    /* make the root                                                       */
    return NEW_FFE(ff, (q == INTOBJ_INT(2)) ? 1 : 2);
}

static Obj FuncZ2(Obj self, Obj p, Obj d)
{
    FF   ff;
    Int  ip, id, id1;
    UInt q;
    if (ARE_INTOBJS(p, d)) {
        ip = INT_INTOBJ(p);
        id = INT_INTOBJ(d);
        if (ip > 1 && id > 0 && id <= 16 && ip < 65536) {
            id1 = id;
            q = ip;
            while (--id1 > 0 && q <= 65536)
                q *= ip;
            if (q <= 65536) {
                /* get the finite field */
                ff = FiniteField(ip, id);

                if (ff == 0 || CHAR_FF(ff) != ip)
                    RequireArgument(SELF_NAME, p, "must be a prime");

                /* make the root */
                return NEW_FFE(ff, (ip == 2 && id == 1 ? 1 : 2));
            }
        }
    }
    return CALL_2ARGS(ZOp, p, d);
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
  { T_FFE, "ffe" },
  { -1,    "" }
};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IS_FFE, "obj", &IsFFEFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_1ARGS(CHAR_FFE_DEFAULT, z),
    GVAR_FUNC_1ARGS(DEGREE_FFE_DEFAULT, z),
    GVAR_FUNC_2ARGS(LOG_FFE_DEFAULT, z, root),
    GVAR_FUNC_1ARGS(INT_FFE_DEFAULT, z),
    GVAR_FUNC_1ARGS(Z, q),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    // set the bag type names (for error messages and debugging)
    InitBagNamesFromTable( BagNames );

    /* install the type functions                                          */
    ImportFuncFromLibrary( "TYPE_FFE", &TYPE_FFE );
    ImportFuncFromLibrary( "TYPE_FFE0", &TYPE_FFE0 );
    ImportFuncFromLibrary( "ZOp", &ZOp );
    InitFopyGVar( "PrimitiveRootMod", &PrimitiveRootMod );
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

#ifdef HPCGAP
    MakeBagPublic(SuccFF);
    MakeBagPublic(TypeFF);
    MakeBagPublic(TypeFF0);
    MakeBagPublic(IntFF);
#endif

    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );
    SET_HDLR_FUNC(ValGVar(GVarName("Z")), 2, FuncZ2);

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
