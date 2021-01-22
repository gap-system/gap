/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file implements the arithmetic for elements from  cyclotomic  fields
**  $Q(e^{{2 \pi i}/n}) = Q(e_n)$,  which  we  call  cyclotomics  for  short.
**
**  The obvious way to represent cyclotomics is to write them as a polynom in
**  $e_n$, the  primitive <n>th root  of unity.  However,  if we  do  this it
**  happens that various  polynomials actually represent the same cyclotomic,
**  e.g., $2+e_3^2 = -2e_3-e_3^2$.  This  is because, if  viewed  as a vector
**  space over the rationals, $Q(e_n)$ has dimension $\phi(n)$ and not $n$.
**
**  This  is  solved by   taking  a  system of $\phi(n)$  linear  independent
**  vectors, i.e., a base, instead of the $n$ linear dependent roots $e_n^i$,
**  and writing  cyclotomics as linear combinations  in  those  vectors.    A
**  possible base would be the set of $e_n^i$ with $i=0..\phi(n)-1$.  In this
**  representation we have $2+e_3^2 = 1-e_3$.
**
**  However we take a different base.  We take  the set of roots $e_n^i$ such
**  that $i \notin (n/q)*[-(q/p-1)/2..(q/p-1)/2]$    mod $q$, for every   odd
**  prime divisor $p$ of $n$, where $q$ is the maximal power  of  $p$ in $n$,
**  and $i \notin (n/q)*[q/2..q-1]$, if $q$ is the maximal power of 2 in $n$.
**  It is not too difficult to see, that this gives in fact $\phi(n)$ roots.
**
**  For example for $n = 45$ we take the roots $e_{45}^i$ such  that  $i$  is
**  not congruent to $(45/5)*[-(5/5-1)/2..(5/5-1)/2]$ mod $5$, i.e.,   is not
**  divisible by 5, and is not congruent  to $(45/9)[-(9/3-1)/2 .. (9/3-1)/2]
**  = [-5,0,5]$ mod $9$,  i.e.,  $i \in [1,2,3,6,7,8,11,12,16,17,19,21,24,26,
**  28,29,33,34,37,38,39,42,43,44]$.
**
**  This base  has two properties, which make  computing with this base easy.
**  First we can convert an arbitrary polynom in $e_n$ into this base without
**  doing  polynom arithmetic.  This is necessary   for the base $e_n^i$ with
**  $i=0..\phi(n)$, where we have to compute modulo the  cyclotomic  polynom.
**  The algorithm for this is given in the description of 'ConvertToBase'.
**
**  It  follows  from this  algorithm that the  set   of roots is  in  fact a
**  generating system,  and because the set  contains exactly $\phi(n)$ roots
**  it is also linear independent system, so it is in fact a  base.  Actually
**  it is even an integral base, but this is not so easy to prove.
**
**  On the other hand we can test  if  a cyclotomic lies  in fact in a proper
**  cyclotomic subfield of $Q(e_n)$ and if so reduce it into  this field.  So
**  each cyclotomic now has a unique representation in its minimal cyclotomic
**  field, which makes testing for equality  easy.  Also a reduced cyclotomic
**  has less terms  than  the unreduced  cyclotomic,  which makes  arithmetic
**  operations, whose effort depends on the number of terms, cheaper.
**
**  For  odd $n$ this base  is also closed  under complex  conjugation, i.e.,
**  complex conjugation  just permutes the roots of the base  in  this  case.
**  This is not possible if $n$ is even for any  base.  This shows again that
**  2 is the oddest of all primes.
**
**  Better descriptions of the base and  related  topics  can  be  found  in:
**  Matthias Zumbroich,
**  Grundlagen  der  Kreisteilungskoerper  und deren  Implementation in  CAS,
**  Diplomarbeit Mathematik,  Lehrstuhl D für Mathematik, RWTH Aachen,  1989
**
**  We represent a cyclotomic with <d>  terms, i.e., <d> nonzero coefficients
**  in the linear  combination, by a bag  of type 'T_CYC'  with <d>+1 subbags
**  and <d>+1 unsigned integers.  All the bag identifiers are stored at the
**  beginning of the  bag and all unsigned integers are stored  at the end of
**  the bag.
**
**      +-------+-------+-------+-------+- - - -+----+----+----+----+- - -
**      | order | coeff | coeff | coeff |       | un | exp| exp| exp|
**      |       |   1   |   2   |   3   |       |used|  1 |  2 |  3 |
**      +-------+-------+-------+-------+- - - -+----+----+----+----+- - -
**
**  The first subbag is  the order  of  the primitive root of  the cyclotomic
**  field in which the cyclotomic lies.  It is an immediate positive integer,
**  therefore 'INT_INTOBJ( ADDR_OBJ(<cyc>)[ 0 ] )'  gives you the order.  The
**  first unsigned integer is unused (but reserved for future use :-).
**
**  The other subbags and exponents are paired and each pair describes one term.
**  The subbag is the coefficient and the  unsigned short gives the exponent.
**  The coefficient will usually be  an immediate integer,  but could as well
**  be a large integer or even a rational.
**
**  The terms are sorted with respect to the exponent.  Note that none of the
**  arithmetic functions need this, but it makes the equality test simpler.
*/

#include "cyclotom.h"

#include "ariths.h"
#include "bool.h"
#include "error.h"
#include "gapstate.h"
#include "integer.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "saveload.h"


/****************************************************************************
**
*/
static inline UInt SIZE_CYC(Obj cyc)
{
    return SIZE_OBJ(cyc) / (sizeof(Obj)+sizeof(UInt4));
}

static inline Obj * COEFS_CYC(Obj cyc)
{
    return ADDR_OBJ(cyc);
}

static inline const Obj * CONST_COEFS_CYC(Obj cyc)
{
    return CONST_ADDR_OBJ(cyc);
}

static inline UInt4 * EXPOS_CYC(Obj cyc, UInt len)
{
    return (UInt4 *)(ADDR_OBJ(cyc)+(len));
}

static inline const UInt4 * CONST_EXPOS_CYC(Obj cyc, UInt len)
{
    return (const UInt4 *)(CONST_ADDR_OBJ(cyc)+(len));
}

static inline Obj NOF_CYC(Obj cyc)
{
    return CONST_COEFS_CYC(cyc)[0];
}

static inline void SET_NOF_CYC(Obj cyc, Obj val)
{
    COEFS_CYC(cyc)[0] = val;
}

// #define XXX_CYC(cyc,len)        (EXPOS_CYC(cyc,len)[0])


static ModuleStateOffset CycStateOffset = -1;

struct CycModuleState {

/****************************************************************************
**
*V  ResultCyc . . . . . . . . . . . .  temporary buffer for the result, local
**
**  'ResultCyc' is used  by all the arithmetic functions  as a buffer for the
**  result.  Unlike bags of type 'T_CYC' it  stores the cyclotomics unpacked,
**  i.e., 'ADDR_OBJ( ResultCyc )[<i+1>]' is the coefficient of $e_n^i$.
**
**  It is created in 'InitCyc' with room for up to 1000 coefficients  and  is
**  resized when need arises.
*/
Obj ResultCyc;

/****************************************************************************
**
*V  LastECyc  . . . . . . . . . . . .  last constructed primitive root, local
*V  LastNCyc  . . . . . . . . order of last constructed primitive root, local
**
**  'LastECyc'  remembers  the primitive  root that  was last  constructed by
**  'FuncE'.
**
**  'LastNCyc' is the order of this primitive root.
**
**  These values are used in 'FuncE' to avoid constructing the same primitive
**  root over and over again.  This might be expensive,  because  $e_n$  need
**  itself not belong to the base.
**
**  Also these values are used in 'PowCyc' which thereby can recognize if  it
**  is called to compute $e_n^i$ and can then do this easier by just  putting
**  1 at the <i>th place in 'ResultCyc' and then calling 'Cyclotomic'.
*/
Obj  LastECyc;
UInt LastNCyc;

}; // end of struct CycModuleState

extern inline struct CycModuleState *CycState(void)
{
    return (struct CycModuleState *)StateSlotsAtOffset(CycStateOffset);
}

// For convenience and readability
#define ResultCyc   CycState()->ResultCyc
#define LastECyc    CycState()->LastECyc
#define LastNCyc    CycState()->LastNCyc


static void GrowResultCyc(UInt size)
{
    Obj *res;
    UInt i;
    if (ResultCyc == 0) {
        ResultCyc = NEW_PLIST( T_PLIST, size );
        res = BASE_PTR_PLIST(ResultCyc);
        for ( i = 0; i < size; i++ ) { res[i] = INTOBJ_INT(0); }
    } else if ( LEN_PLIST(ResultCyc) < size ) {
        GROW_PLIST( ResultCyc, size );
        SET_LEN_PLIST( ResultCyc, size );
        res = BASE_PTR_PLIST(ResultCyc);
        for ( i = 0; i < size; i++ ) { res[i] = INTOBJ_INT(0); }
    }
}

/****************************************************************************
**
*F  TypeCyc( <cyc> )  . . . . . . . . . . . . . . . . .  type of a cyclotomic
**
**  'TypeCyc' returns the type of a cyclotomic.
**
**  'TypeCyc' is the function in 'TypeObjFuncs' for cyclotomics.
*/
static Obj TYPE_CYC;

static Obj TypeCyc(Obj cyc)
{
    return TYPE_CYC;
}


/****************************************************************************
**
*F  PrintCyc( <cyc> ) . . . . . . . . . . . . . . . . . .  print a cyclotomic
**
**  'PrintCyc' prints the cyclotomic <cyc> in the standard form.
**
**  In principle this is very easy, but it is complicated because we  do  not
**  want to print stuff like '+1*', '-1*', 'E(<n>)^0', 'E(<n>)^1, etc.
*/
static void PrintCyc(Obj cyc)
{
    UInt                n;              /* order of the field              */
    UInt                len;            /* number of terms                 */
    UInt                i;              /* loop variable                   */

    n   = INT_INTOBJ( NOF_CYC(cyc) );
    len = SIZE_CYC(cyc);
    Pr("%>", 0, 0);
    for ( i = 1; i < len; i++ ) {
        // Store value in local variable, as they can change during Pr
        const Obj *   cfs = CONST_COEFS_CYC(cyc);
        const UInt4 * exs = CONST_EXPOS_CYC(cyc, len);
        Obj           cfsi = cfs[i];
        UInt4         exsi = exs[i];

        if (cfsi == INTOBJ_INT(1) && exsi == 0)
            Pr("1", 0, 0);
        else if (cfsi == INTOBJ_INT(1) && exsi == 1 && i == 1)
            Pr("%>E(%d%<)", n, 0);
        else if (cfsi == INTOBJ_INT(1) && exsi == 1)
            Pr("%>+E(%d%<)", n, 0);
        else if (cfsi == INTOBJ_INT(1) && i == 1)
            Pr("%>E(%d)%>^%2<%d", n, (Int)exsi);
        else if (cfsi == INTOBJ_INT(1))
            Pr("%>+E(%d)%>^%2<%d", n, (Int)exsi);
        else if (LT(INTOBJ_INT(0), cfsi) && exsi == 0)
            PrintObj(cfsi);
        else if (LT(INTOBJ_INT(0), cfsi) && exsi == 1 && i == 1) {
            Pr("%>", 0, 0);
            PrintObj(cfsi);
            Pr("%>*%<E(%d%<)", n, 0);
        }
        else if (LT(INTOBJ_INT(0), cfsi) && exsi == 1) {
            Pr("%>+", 0, 0);
            PrintObj(cfsi);
            Pr("%>*%<E(%d%<)", n, 0);
        }
        else if (LT(INTOBJ_INT(0), cfsi) && i == 1) {
            Pr("%>", 0, 0);
            PrintObj(cfsi);
            Pr("%>*%<E(%d)%>^%2<%d", n, (Int)exsi);
        }
        else if (LT(INTOBJ_INT(0), cfsi)) {
            Pr("%>+", 0, 0);
            PrintObj(cfsi);
            Pr("%>*%<E(%d)%>^%2<%d", n, (Int)exsi);
        }
        else if (cfsi == INTOBJ_INT(-1) && exsi == 0)
            Pr("%>-%<1", 0, 0);
        else if (cfsi == INTOBJ_INT(-1) && exsi == 1)
            Pr("%>-E(%d%<)", n, 0);
        else if (cfsi == INTOBJ_INT(-1))
            Pr("%>-E(%d)%>^%2<%d", n, (Int)exsi);
        else if (exsi == 0)
            PrintObj(cfsi);
        else if (exsi == 1) {
            Pr("%>", 0, 0);
            PrintObj(cfsi);
            Pr("%>*%<E(%d%<)", n, 0);
        }
        else {
            Pr("%>", 0, 0);
            PrintObj(cfsi);
            Pr("%>*%<E(%d)%>^%2<%d", n, (Int)exsi);
        }
    }
    Pr("%<", 0, 0);
}


/****************************************************************************
**
*F  EqCyc( <opL>, <opR> ) . . . . . . . . . test if two cyclotomics are equal
**
**  'EqCyc' returns 'true' if the two cyclotomics <opL>  and <opR>  are equal
**  and 'false' otherwise.
**
**  'EqCyc'  is  pretty  simple because   every    cyclotomic  has a   unique
**  representation, so we just have to compare the terms.
*/
static Int EqCyc(Obj opL, Obj opR)
{
    UInt                len;            /* number of terms                 */
    const Obj *         cfl;            /* ptr to coeffs of left operand   */
    const UInt4 *       exl;            /* ptr to expnts of left operand   */
    const Obj *         cfr;            /* ptr to coeffs of right operand  */
    const UInt4 *       exr;            /* ptr to expnts of right operand  */
    UInt                i;              /* loop variable                   */

    /* compare the order of both fields                                    */
    if ( NOF_CYC(opL) != NOF_CYC(opR) )
        return 0;

    /* compare the number of terms                                         */
    if ( SIZE_CYC(opL) != SIZE_CYC(opR) )
        return 0;

    /* compare the cyclotomics termwise                                    */
    len = SIZE_CYC(opL);
    cfl = CONST_COEFS_CYC(opL);
    cfr = CONST_COEFS_CYC(opR);
    exl = CONST_EXPOS_CYC(opL,len);
    exr = CONST_EXPOS_CYC(opR,len);
    for ( i = 1; i < len; i++ ) {
        if ( exl[i] != exr[i] )
            return 0;
        else if ( ! EQ(cfl[i],cfr[i]) )
            return 0;
    }

    /* all terms are equal                                                 */
    return 1;
}


/****************************************************************************
**
*F  LtCyc( <opL>, <opR> ) . . . . test if one cyclotomic is less than another
**
**  'LtCyc'  returns  'true'  if  the  cyclotomic  <opL>  is  less  than  the
**  cyclotomic <opR> and 'false' otherwise.
**
**  Cyclotomics are first sorted according to the order of the primitive root
**  they are written in.  That means that the rationals  are  smallest,  then
**  come cyclotomics from $Q(e_3)$ followed by cyclotomics from $Q(e_4)$ etc.
**  Cyclotomics from the same field are sorted lexicographicaly with  respect
**  to their representation in the base of this field.  That means  that  the
**  cyclotomic with smaller coefficient for the first base root  is  smaller,
**  for cyclotomics with the same first coefficient the second decides  which
**  is smaller, etc.
**
**  'LtCyc'  is  pretty  simple because   every    cyclotomic  has a   unique
**  representation, so we just have to compare the terms.
*/
static Int LtCyc(Obj opL, Obj opR)
{
    UInt                lel;            /* nr of terms of left operand     */
    const Obj *         cfl;            /* ptr to coeffs of left operand   */
    const UInt4 *       exl;            /* ptr to expnts of left operand   */
    UInt                ler;            /* nr of terms of right operand    */
    const Obj *         cfr;            /* ptr to coeffs of right operand  */
    const UInt4 *       exr;            /* ptr to expnts of right operand  */
    UInt                i;              /* loop variable                   */

    /* compare the order of both fields                                    */
    if ( NOF_CYC(opL) != NOF_CYC(opR) ) {
        if ( INT_INTOBJ( NOF_CYC(opL) ) < INT_INTOBJ( NOF_CYC(opR) ) )
            return 1;
        else
            return 0;
    }

    /* compare the cyclotomics termwise                                    */
    lel = SIZE_CYC(opL);
    ler = SIZE_CYC(opR);
    cfl = CONST_COEFS_CYC(opL);
    cfr = CONST_COEFS_CYC(opR);
    exl = CONST_EXPOS_CYC(opL,lel);
    exr = CONST_EXPOS_CYC(opR,ler);
    for ( i = 1; i < lel && i < ler; i++ ) {
        if ( exl[i] != exr[i] )
            if ( exl[i] < exr[i] )
                return LT( cfl[i], INTOBJ_INT(0) );
            else
                return LT( INTOBJ_INT(0), cfr[i] );
        else if ( ! EQ(cfl[i],cfr[i]) )
            return LT( cfl[i], cfr[i] );
    }

    /* if one cyclotomic has more terms than the other compare it agains 0 */
    if ( lel < ler )
        return LT( INTOBJ_INT(0), cfr[i] );
    else if ( ler < lel )
        return LT( cfl[i], INTOBJ_INT(0) );
    else
        return 0;
}

static Int LtCycYes(Obj opL, Obj opR)
{
    return 1;
}

static Int LtCycNot(Obj opL, Obj opR)
{
    return 0;
}


/****************************************************************************
**
*F  ConvertToBase(<n>)  . . . . . . convert a cyclotomic into the base, local
**
**  'ConvertToBase'  converts the cyclotomic  'ResultCyc' from the cyclotomic
**  field  of <n>th roots of  unity, into the base  form.  This means that it
**  replaces every root $e_n^i$ that does not belong to the  base by a sum of
**  other roots that do.
**
**  Suppose that $c*e_n^i$ appears in 'ResultCyc' but $e_n^i$ does not lie in
**  the base.  This happens  because, for some  prime $p$ dividing $n$,  with
**  maximal power $q$, $i \in (n/q)*[-(q/p-1)/2..(q/p-1)/2]$ mod $q$.
**
**  We take the identity  $1+e_p+e_p^2+..+e_p^{p-1}=0$, write it  using $n$th
**  roots of unity, $0=1+e_n^{n/p}+e_n^{2n/p}+..+e_n^{(p-1)n/p}$ and multiply
**  it  by $e_n^i$,   $0=e_n^i+e_n^{n/p+i}+e_n^{2n/p+i}+..+e_n^{(p-1)n/p+i}$.
**  Now we subtract $c$ times the left hand side from 'ResultCyc'.
**
**  If $p^2$  does not divide  $n$ then the roots  that are  not in the  base
**  because of $p$ are those  whose exponent is divisible  by $p$.  But $n/p$
**  is not  divisible by $p$, so  neither of the exponent $k*n/p+i, k=1..p-1$
**  is divisible by $p$, so those new roots are acceptable w.r.t. $p$.
**
**  A similar argument shows that  the new  roots  are also acceptable w.r.t.
**  $p$ even if $p^2$ divides $n$...
**
**  Note that the new roots might still not lie  in the  case because of some
**  other prime $p2$.  However, because $i = k*n/p+i$ mod $p2$, this can only
**  happen if $e_n^i$ did also not lie in the base because of $p2$.  So if we
**  remove all  roots that lie in  the base because  of $p$, the later steps,
**  which remove the roots that are not in the base because of larger primes,
**  will not add new roots that do not lie in the base because of $p$ again.
**
**  For an example, suppose 'ResultCyc' is $e_{45}+e_{45}^5 =: e+e^5$.  $e^5$
**  does  not lie in the  base  because $5  \in 5*[-1,0,1]$  mod $9$ and also
**  because it is  divisible  by 5.  After  subtracting  $e^5*(1+e_3+e_3^2) =
**  e^5+e^{20}+e^{35}$ from  'ResultCyc' we get $e-e^{20}-e^{35}$.  Those two
**  roots are  still not  in the  base because of  5.  But  after subtracting
**  $-e^{20}*(1+e_5+e_5^2+e_5^3+e_5^4)=-e^{20}-e^{29}-e^{38}-e^2-e^{11}$  and
**  $-e^{35}*(1+e_5+e_5^2+e_5^3+e_5^4)=-e^{35}-e^{44}-e^8-e^{17}-e^{26}$   we
**  get  $e+e^{20}+e^{29}+e^{38}+e^2+e^{11}+e^{35}+e^{44}+e^8+e^{17}+e^{26}$,
**  which contains only roots that lie in the base.
**
**  'ConvertToBase' and 'Cyclotomic' are the functions that  know  about  the
**  structure of the base.  'EqCyc' and 'LtCyc' only need the  property  that
**  the representation of  all  cyclotomic  integers  is  unique.  All  other
**  functions dont even require that cyclotomics  are  written  as  a  linear
**  combination of   linear  independent  roots,  they  would  work  also  if
**  cyclotomic integers were written as polynomials in $e_n$.
**
**  The inner loops in this function have been duplicated to avoid using  the
**  modulo ('%') operator to reduce the exponents into  the  range  $0..n-1$.
**  Those divisions are quite expensive  on  some  processors, e.g., MIPS and
**  SPARC, and they may singlehanded account for 20 percent of the runtime.
*/
static void ConvertToBase(UInt n)
{
    Obj *               res;            /* pointer to the result           */
    UInt                nn;             /* copy of n to factorize          */
    UInt                p, q;           /* prime and prime power           */
    UInt                i, k, l;        /* loop variables                  */
    UInt                t;              /* temporary holds n+i+(n/p-n/q)/2 */
    Obj                 sum;            /* sum of two coefficients         */

    /* get a pointer to the cyclotomic and a copy of n to factor           */
    res = BASE_PTR_PLIST(ResultCyc);
    nn  = n;

    /* first handle 2                                                      */
    if ( nn % 2 == 0 ) {
        q = 2;  while ( nn % (2*q) == 0 )  q = 2*q;
        nn = nn / q;

        /* get rid of all terms e^{a*q+b*(n/q)} a=0..(n/q)-1 b=q/2..q-1    */
        for ( i = 0; i < n; i += q ) {
            t = i + (n/q)*(q-1) + n/q;          /* end   (n <= t < 2n)     */
            k = i + (n/q)*(q/2);                /* start (0 <= k <= t)     */
            for ( ; k < n; k += n/q ) {
                if ( res[k] != INTOBJ_INT(0) ) {
                    l = (k + n/2) % n;
                    if ( ! ARE_INTOBJS( res[l], res[k] )
                      || ! DIFF_INTOBJS( sum, res[l], res[k] ) ) {
                        CHANGED_BAG( ResultCyc );
                        sum = DIFF( res[l], res[k] );
                        res = BASE_PTR_PLIST(ResultCyc);
                    }
                    res[l] = sum;
                    res[k] = INTOBJ_INT(0);
                }
            }
            t = t - n;                          /* end   (0 <= t <  n)     */
            k = k - n;                          /* cont. (0 <= k     )     */
            for ( ; k < t; k += n/q ) {
                if ( res[k] != INTOBJ_INT(0) ) {
                    l = (k + n/2) % n;
                    if ( ! ARE_INTOBJS( res[l], res[k] )
                      || ! DIFF_INTOBJS( sum, res[l], res[k] ) ) {
                        CHANGED_BAG( ResultCyc );
                        sum = DIFF( res[l], res[k] );
                        res = BASE_PTR_PLIST(ResultCyc);
                    }
                    res[l] = sum;
                    res[k] = INTOBJ_INT(0);
                }
            }
        }
    }

    /* now handle the odd primes                                           */
    for ( p = 3; p <= nn; p += 2 ) {
        if ( nn % p != 0 )  continue;
        q = p;  while ( nn % (p*q) == 0 )  q = p*q;
        nn = nn / q;

        /* get rid of e^{a*q+b*(n/q)} a=0..(n/q)-1 b=-(q/p-1)/2..(q/p-1)/2 */
        for ( i = 0; i < n; i += q ) {
            if ( n <= i+(n/p-n/q)/2 ) {
                t = i + (n/p-n/q)/2;    /* end   (n   <= t < 2n)           */
                k = i - (n/p-n/q)/2;    /* start (t-n <= k <= t)           */
            }
            else {
                t = i + (n/p-n/q)/2+n;  /* end   (n   <= t < 2n)           */
                k = i - (n/p-n/q)/2+n;  /* start (t-n <= k <= t)           */
            }
            for ( ; k < n; k += n/q ) {
                if ( res[k] != INTOBJ_INT(0) ) {
                    for ( l = k+n/p; l < k+n; l += n/p ) {
                        if ( ! ARE_INTOBJS( res[l%n], res[k] )
                          || ! DIFF_INTOBJS( sum, res[l%n], res[k] ) ) {
                            CHANGED_BAG( ResultCyc );
                            sum = DIFF( res[l%n], res[k] );
                            res = BASE_PTR_PLIST(ResultCyc);
                        }
                        res[l%n] = sum;
                    }
                    res[k] = INTOBJ_INT(0);
                }
            }
            t = t - n;                  /* end   (0   <= t <  n)           */
            k = k - n;                  /* start (0   <= k     )           */
            for ( ; k <= t; k += n/q ) {
                if ( res[k] != INTOBJ_INT(0) ) {
                    for ( l = k+n/p; l < k+n; l += n/p ) {
                        if ( ! ARE_INTOBJS( res[l%n], res[k] )
                          || ! DIFF_INTOBJS( sum, res[l%n], res[k] ) ) {
                            CHANGED_BAG( ResultCyc );
                            sum = DIFF( res[l%n], res[k] );
                            res = BASE_PTR_PLIST(ResultCyc);
                        }
                        res[l%n] = sum;
                    }
                    res[k] = INTOBJ_INT(0);
                }
            }
        }
    }

    /* notify Gasman                                                       */
    CHANGED_BAG( ResultCyc );
}


/****************************************************************************
**
*F  Cyclotomic(<n>,<m>) . . . . . . . . . . create a packed cyclotomic, local
**
**  'Cyclotomic'    reduces  the cyclotomic   'ResultCyc'   into the smallest
**  possible cyclotomic subfield and returns it in packed form.
**
**  'ResultCyc'  must   also    be already converted      into  the base   by
**  'ConvertToBase'.   <n> must be  the order of the  primitive root in which
**  written.
**
**  <m> must be a divisor of $n$ and  gives a  hint about possible subfields.
**  If a prime $p$ divides <m> then no  reduction into a subfield whose order
**  is $n /  p$  is possible.   In the  arithmetic   functions  you can  take
**  $lcm(n_l,n_r) / gcd(n_l,n_r) = n / gcd(n_l,n_r)$.  If you cannot provide
**  such a hint just pass 1.
**
**  A special case of the  reduction is the case that  the  cyclotomic  is  a
**  rational.  If this is the case 'Cyclotomic' reduces it into the rationals
**  and returns it as a rational.
**
**  After 'Cyclotomic' has  done its work it clears  the 'ResultCyc'  bag, so
**  that it only contains 'INTOBJ_INT(0)'.  Thus the arithmetic functions can
**  use this buffer without clearing it first.
**
**  'ConvertToBase' and 'Cyclotomic' are the functions that  know  about  the
**  structure of the base.  'EqCyc' and 'LtCyc' only need the  property  that
**  the representation of  all  cyclotomic  integers  is  unique.  All  other
**  functions dont even require that cyclotomics  are  written  as  a  linear
**  combination of   linear  independent  roots,  they  would  work  also  if
**  cyclotomic integers were written as polynomials in $e_n$.
*/
static Obj Cyclotomic(UInt n, UInt m)
{
    Obj                 cyc;            /* cyclotomic, result              */
    UInt                len;            /* number of terms                 */
    Obj *               cfs;            /* pointer to the coefficients     */
    UInt4 *             exs;            /* pointer to the exponents        */
    Obj *               res;            /* pointer to the result           */
    UInt                gcd, s, t;      /* gcd of the exponents, temporary */
    UInt                eql;            /* are all coefficients equal?     */
    Obj                 cof;            /* if so this is the coefficient   */
    UInt                i, k;           /* loop variables                  */
    UInt                nn;             /* copy of n to factorize          */
    UInt                p;              /* prime factor                    */
    static UInt         lastN;          /* rember last n, dont recompute:  */
    static UInt         phi;            /* Euler phi(n)                    */
    static BOOL         isSqfree;       /* is n squarefree?                */
    static UInt         nrp;            /* number of its prime factors     */

    /* get a pointer to the cyclotomic and a copy of n to factor           */
    res = BASE_PTR_PLIST(ResultCyc);

    /* count the terms and compute the gcd of the exponents with n         */
    len = 0;
    gcd = n;
    eql = 1;
    cof = 0;
    for ( i = 0; i < n; i++ ) {
        if ( res[i] != INTOBJ_INT(0) ) {
            len++;
            if ( gcd != 1 ) {
                s = i; while ( s != 0 ) { t = s; s = gcd % s; gcd = t; }
            }
            if ( eql && cof == 0 )
                cof = res[i];
            else if ( eql && ! EQ(cof,res[i]) )
                eql = 0;
        }
    }

    /* if all exps are divisible 1 < k replace $e_n^i$ by $e_{n/k}^{i/k}$  */
    /* this is the only way a prime whose square divides $n$ could reduce  */
    if ( 1 < gcd ) {
        for ( i = 1; i < n/gcd; i++ ) {
            res[i]     = res[i*gcd];
            res[i*gcd] = INTOBJ_INT(0);
        }
        n = n / gcd;
    }

    /* compute $phi(n)$, test if n is squarefree, compute number of primes */
    if ( n != lastN ) {
        lastN = n;
        phi = n;  k = n;
        isSqfree = TRUE;
        nrp = 0;
        for ( p = 2; p <= k; p++ ) {
            if ( k % p == 0 ) {
                phi = phi * (p-1) / p;
                if (k % (p * p) == 0)
                    isSqfree = FALSE;
                nrp++;
                while ( k % p == 0 )  k = k / p;
            }
        }
    }

    /* if possible reduce into the rationals, clear buffer bag             */
    if ( len == phi && eql && isSqfree ) {
        for ( i = 0; i < n; i++ )
            res[i] = INTOBJ_INT(0);
        /* return as rational $(-1)^{number primes}*{common coefficient}$  */
        if ( nrp % 2 == 0 )
            res[0] = cof;
        else {
            CHANGED_BAG( ResultCyc );
            Obj negcof = DIFF( INTOBJ_INT(0), cof );
            res = BASE_PTR_PLIST(ResultCyc);
            res[0] = negcof;
        }
        n = 1;
    }
    CHANGED_BAG( ResultCyc );

    /* for all primes $p$ try to reduce from $Q(e_n)$ into $Q(e_{n/p})$    */
    gcd = phi; s = len; while ( s != 0 ) { t = s; s = gcd % s; gcd = t; }
    nn = n;
    for ( p = 3; p <= nn && p-1 <= gcd; p += 2 ) {
        if ( nn % p != 0 )  continue;
        nn = nn / p;  while ( nn % p == 0 )  nn = nn / p;

        /* if $p$ is not quadratic and the number of terms is divisible   */
        /* $p-1$ and $p$ divides $m$ not then a reduction is possible      */
        if ( n % (p*p) != 0 && len % (p-1) == 0 && m % p != 0 ) {

            /* test that coeffs for expnts congruent mod $n/p$ are equal   */
            eql = 1;
            for ( i = 0; i < n && eql; i += p ) {
                cof = res[(i+n/p)%n];
                for ( k = i+2*n/p; k < i+n && eql; k += n/p )
                    if ( ! EQ(res[k%n],cof) )
                        eql = 0;
            }

            /* if all coeffs for expnts in all classes are equal reduce    */
            if ( eql ) {

                /* replace every sum of $p-1$ terms with expnts congruent  */
                /* to $i*p$ mod $n/p$ by the term with exponent $i*p$      */
                /* is just the inverse transformation of 'ConvertToBase'   */
                for ( i = 0; i < n; i += p ) {
                    cof = res[(i+n/p)%n];
                    if ( ! IS_INTOBJ(cof)
                      || (cof == INTOBJ_MIN) ) {
                        CHANGED_BAG( ResultCyc );
                        cof = DIFF( INTOBJ_INT(0), cof );
                        res = BASE_PTR_PLIST(ResultCyc);
                        res[i] = cof;
                    }
                    else {
                        res[i] = INTOBJ_INT( - INT_INTOBJ(cof) );
                    }
                    for ( k = i+n/p; k < i+n && eql; k += n/p )
                        res[k%n] = INTOBJ_INT(0);
                }
                len = len / (p-1);
                CHANGED_BAG( ResultCyc );

                /* now replace $e_n^{i*p}$ by $e_{n/p}^{i}$                */
                for ( i = 1; i < n/p; i++ ) {
                    res[i]   = res[i*p];
                    res[i*p] = INTOBJ_INT(0);
                }
                n = n / p;

            }

        }

    }

    /* if the cyclotomic is a rational return it as a rational             */
    if ( n == 1 ) {
        cyc  = res[0];
        res[0] = INTOBJ_INT(0);
    }

    /* otherwise copy terms into a new 'T_CYC' bag and clear 'ResultCyc'   */
    else {
        cyc = NewBag( T_CYC, (len+1)*(sizeof(Obj)+sizeof(UInt4)) );
        cfs = COEFS_CYC(cyc);
        exs = EXPOS_CYC(cyc,len+1);
        cfs[0] = INTOBJ_INT(n);
        exs[0] = 0;
        k = 1;
        res = BASE_PTR_PLIST(ResultCyc);
        for ( i = 0; i < n; i++ ) {
            if ( res[i] != INTOBJ_INT(0) ) {
                cfs[k] = res[i];
                exs[k] = i;
                k++;
                res[i] = INTOBJ_INT(0);
            }
        }
        /* 'CHANGED_BAG' not needed for last bag                           */
    }

    return cyc;
}

/****************************************************************************
**
*F  find smallest field size containing CF(nl) and CF(nr)
** Also adjusts the results bag to ensure that it is big enough 
** returns the field size n, and sets *ml and *mr to n/nl and n/nr 
** respectively.
*/

static UInt4 CyclotomicsLimit = 1000000;

static UInt FindCommonField(UInt nl, UInt nr, UInt *ml, UInt *mr)
{
  UInt n,a,b,c;
  UInt8 n8;
  
  /* get the smallest field that contains both cyclotomics               */
  /* First Euclid's Algorithm for gcd */
  if (nl > nr) {
    a = nl;
    b = nr;
  } else {
    a = nr;
    b = nl;
  }
  while (b > 0) {
    c = a % b;
    a = b;
    b = c;
  }
  *ml = nr/a;
  /* Compute the result (lcm) in 64 bit */
  n8 = (UInt8)nl * ((UInt8)*ml);  
  /* Check if it is too large for a small int */
  if (n8 > INT_INTOBJ_MAX)
    ErrorMayQuit("This computation would require a cyclotomic field too large to be handled", 0, 0);

  /* Switch to UInt now we know we can*/
  n = (UInt)n8;

  /* Handle the soft limit */
  while (n > CyclotomicsLimit) {
      ErrorReturnVoid(
          "This computation requires a cyclotomic field of degree %d, larger "
          "than the current limit of %d",
          n, (Int)CyclotomicsLimit,
          "You may return after raising the limit with SetCyclotomicsLimit");
  }
  
  /* Finish up */
  *mr = n/nr;

  /* make sure that the result bag is large enough                      */
  GrowResultCyc(n);
  return n;
}

static Obj FuncSetCyclotomicsLimit(Obj self, Obj newlimit)
{
    UInt ulimit = GetPositiveSmallInt("SetCyclotomicsLimit", newlimit);

    if (ulimit < CyclotomicsLimit) {
        ErrorMayQuit("SetCyclotomicsLimit: <newlimit> must not be less than "
                     "old limit of %d",
                     CyclotomicsLimit, 0);
    }
#ifdef SYS_IS_64_BIT
    if (ulimit >= ((UInt)1 << 32)) {
        ErrorMayQuit("Cyclotomic field size limit must be less than 2^32", 0,
                     0);
    }
#endif

    CyclotomicsLimit = ulimit;
    return 0;
}

static Obj FuncGetCyclotomicsLimit(Obj self)
{
    return INTOBJ_INT(CyclotomicsLimit);
}

/****************************************************************************
**
*F  SumCyc( <opL>, <opR> )  . . . . . . . . . . . . .  sum of two cyclotomics
**
**  'SumCyc' returns  the  sum  of  the  two  cyclotomics  <opL>  and  <opR>.
**  Either operand may also be an integer or a rational.
**
**  This   function  is lengthy  because  we  try to  use immediate   integer
**  arithmetic if possible to avoid the function call overhead.
*/
static Obj SumCyc(Obj opL, Obj opR)
{
    UInt                nl, nr;         /* order of left and right field   */
    UInt                n;              /* order of smallest superfield    */
    UInt                ml, mr;         /* cofactors into the superfield   */
    UInt                len;            /* number of terms                 */
    const Obj *         cfs;            /* pointer to the coefficients     */
    const UInt4 *       exs;            /* pointer to the exponents        */
    Obj *               res;            /* pointer to the result           */
    Obj                 sum;            /* sum of two coefficients         */
    UInt                i;              /* loop variable                   */

    /* take the cyclotomic with less terms as the right operand            */
    if ( TNUM_OBJ(opL) != T_CYC
      || (TNUM_OBJ(opR) == T_CYC && SIZE_CYC(opL) < SIZE_CYC(opR)) ) {
        sum = opL;  opL = opR;  opR = sum;
    }

    nl = (TNUM_OBJ(opL) != T_CYC ? 1 : INT_INTOBJ( NOF_CYC(opL) ));
    nr = (TNUM_OBJ(opR) != T_CYC ? 1 : INT_INTOBJ( NOF_CYC(opR) ));

    n = FindCommonField(nl, nr, &ml, &mr);
 
    /* Copy the left operand into the result                               */
    if ( TNUM_OBJ(opL) != T_CYC ) {
        res = BASE_PTR_PLIST(ResultCyc);
        res[0] = opL;
        CHANGED_BAG( ResultCyc );
    }
    else {
        len = SIZE_CYC(opL);
        cfs = CONST_COEFS_CYC(opL);
        exs = CONST_EXPOS_CYC(opL,len);
        res = BASE_PTR_PLIST(ResultCyc);
        if ( ml == 1 ) {
            for ( i = 1; i < len; i++ )
                res[exs[i]] = cfs[i];
        }
        else {
            for ( i = 1; i < len; i++ )
                res[exs[i]*ml] = cfs[i];
        }
        CHANGED_BAG( ResultCyc );
    }

    /* add the right operand to the result                                 */
    if ( TNUM_OBJ(opR) != T_CYC ) {
        res = BASE_PTR_PLIST(ResultCyc);
        sum = SUM( res[0], opR );
        res = BASE_PTR_PLIST(ResultCyc);
        res[0] = sum;
        CHANGED_BAG( ResultCyc );
    }
    else {
        len = SIZE_CYC(opR);
        cfs = CONST_COEFS_CYC(opR);
        exs = CONST_EXPOS_CYC(opR,len);
        res = BASE_PTR_PLIST(ResultCyc);
        for ( i = 1; i < len; i++ ) {
            if ( ! ARE_INTOBJS( res[exs[i]*mr], cfs[i] )
              || ! SUM_INTOBJS( sum, res[exs[i]*mr], cfs[i] ) ) {
                CHANGED_BAG( ResultCyc );
                sum = SUM( res[exs[i]*mr], cfs[i] );
                cfs = CONST_COEFS_CYC(opR);
                exs = CONST_EXPOS_CYC(opR,len);
                res = BASE_PTR_PLIST(ResultCyc);
            }
            res[exs[i]*mr] = sum;
        }
        CHANGED_BAG( ResultCyc );
    }

    /* return the base reduced packed cyclotomic                           */
    if ( nl % ml != 0 || nr % mr != 0 )  ConvertToBase( n );
    return Cyclotomic( n, ml * mr );
}


/****************************************************************************
**
*F  ZeroCyc( <op> ) . . . . . . . . . . . . . . . . . .  zero of a cyclotomic
**
**  'ZeroCyc' returns the additive neutral element of the cyclotomic <op>.
*/
static Obj ZeroCyc(Obj op)
{
    return INTOBJ_INT(0);
}


/****************************************************************************
**
*F  AInvCyc( <op> ) . . . . . . . . . . . .  additive inverse of a cyclotomic
**
**  'AInvCyc' returns the additive inverse element of the cyclotomic <op>.
*/
static Obj AInvCyc(Obj op)
{
    Obj                 res;            /* inverse, result                 */
    UInt                len;            /* number of terms                 */
    const Obj *         cfs;            /* ptr to coeffs of left operand   */
    const UInt4 *       exs;            /* ptr to expnts of left operand   */
    Obj *               cfp;            /* ptr to coeffs of product        */
    UInt4 *             exp;            /* ptr to expnts of product        */
    UInt                i;              /* loop variable                   */
    Obj                 prd;            /* product of two coefficients     */

    /* simply invert the coefficients                                      */
    res = NewBag( T_CYC, SIZE_CYC(op) * (sizeof(Obj)+sizeof(UInt4)) );
    SET_NOF_CYC(res, NOF_CYC(op));
    len = SIZE_CYC(op);
    cfs = CONST_COEFS_CYC(op);
    exs = CONST_EXPOS_CYC(op,len);
    cfp = COEFS_CYC(res);
    exp = EXPOS_CYC(res,len);
    for ( i = 1; i < len; i++ ) {
        if ( ! IS_INTOBJ( cfs[i] ) || cfs[i] == INTOBJ_MIN ) {
            CHANGED_BAG( res );
            prd = AINV( cfs[i] );
            cfs = CONST_COEFS_CYC(op);
            exs = CONST_EXPOS_CYC(op,len);
            cfp = COEFS_CYC(res);
            exp = EXPOS_CYC(res,len);
        }
        else {
            prd = INTOBJ_INT( - INT_INTOBJ(cfs[i]) );
        }
        cfp[i] = prd;
        exp[i] = exs[i];
    }
    CHANGED_BAG( res );

    return res;
}


/****************************************************************************
**
*F  DiffCyc( <opL>, <opR> ) . . . . . . . . . . difference of two cyclotomics
**
**  'DiffCyc' returns the difference of the two cyclotomic <opL>  and  <opR>.
**  Either operand may also be an integer or a rational.
**
**  This   function  is lengthy  because  we  try to  use immediate   integer
**  arithmetic if possible to avoid the function call overhead.
*/
static Obj DiffCyc(Obj opL, Obj opR)
{
    UInt                nl, nr;         /* order of left and right field   */
    UInt                n;              /* order of smallest superfield    */
    UInt                ml, mr;         /* cofactors into the superfield   */
    UInt                len;            /* number of terms                 */
    const Obj *         cfs;            /* pointer to the coefficients     */
    const UInt4 *       exs;            /* pointer to the exponents        */
    Obj *               res;            /* pointer to the result           */
    Obj                 sum;            /* difference of two coefficients  */
    UInt                i;              /* loop variable                   */

    /* get the smallest field that contains both cyclotomics               */
    nl = (TNUM_OBJ(opL) != T_CYC ? 1 : INT_INTOBJ( NOF_CYC(opL) ));
    nr = (TNUM_OBJ(opR) != T_CYC ? 1 : INT_INTOBJ( NOF_CYC(opR) ));
    n = FindCommonField(nl, nr, &ml, &mr);

    /* copy the left operand into the result                               */
    if ( TNUM_OBJ(opL) != T_CYC ) {
        res = BASE_PTR_PLIST(ResultCyc);
        res[0] = opL;
        CHANGED_BAG( ResultCyc );
    }
    else {
        len = SIZE_CYC(opL);
        cfs = CONST_COEFS_CYC(opL);
        exs = CONST_EXPOS_CYC(opL,len);
        res = BASE_PTR_PLIST(ResultCyc);
        if ( ml == 1 ) {
            for ( i = 1; i < len; i++ )
                res[exs[i]] = cfs[i];
        }
        else {
            for ( i = 1; i < len; i++ )
                res[exs[i]*ml] = cfs[i];
        }
        CHANGED_BAG( ResultCyc );
    }

    /* subtract the right operand from the result                          */
    if ( TNUM_OBJ(opR) != T_CYC ) {
        res = BASE_PTR_PLIST(ResultCyc);
        sum = DIFF( res[0], opR );
        res = BASE_PTR_PLIST(ResultCyc);
        res[0] = sum;
        CHANGED_BAG( ResultCyc );
    }
    else {
        len = SIZE_CYC(opR);
        cfs = CONST_COEFS_CYC(opR);
        exs = CONST_EXPOS_CYC(opR,len);
        res = BASE_PTR_PLIST(ResultCyc);
        for ( i = 1; i < len; i++ ) {
            if ( ! ARE_INTOBJS( res[exs[i]*mr], cfs[i] )
              || ! DIFF_INTOBJS( sum, res[exs[i]*mr], cfs[i] ) ) {
                CHANGED_BAG( ResultCyc );
                sum = DIFF( res[exs[i]*mr], cfs[i] );
                cfs = CONST_COEFS_CYC(opR);
                exs = CONST_EXPOS_CYC(opR,len);
                res = BASE_PTR_PLIST(ResultCyc);
            }
            res[exs[i]*mr] = sum;
        }
        CHANGED_BAG( ResultCyc );
    }

    /* return the base reduced packed cyclotomic                           */
    if ( nl % ml != 0 || nr % mr != 0 )  ConvertToBase( n );
    return Cyclotomic( n, ml * mr );
}


/****************************************************************************
**
*F  ProdCycInt( <opL>, <opR> )  . . .  product of a cyclotomic and an integer
**
**  'ProdCycInt'    returns the product  of a    cyclotomic and  a integer or
**  rational.  Which operand is the cyclotomic and  wich the integer does not
**  matter.
**
**  This is a special case, because if the integer is not 0, the product will
**  automatically be base reduced.  So we dont need to  call  'ConvertToBase'
**  or 'Reduce' and directly write into a result bag.
**
**  This   function  is lengthy  because  we  try to  use immediate   integer
**  arithmetic if possible to avoid the function call overhead.
*/
static Obj ProdCycInt(Obj opL, Obj opR)
{
    Obj                 hdP;            /* product, result                 */
    UInt                len;            /* number of terms                 */
    const Obj *         cfs;            /* ptr to coeffs of left operand   */
    const UInt4 *       exs;            /* ptr to expnts of left operand   */
    Obj *               cfp;            /* ptr to coeffs of product        */
    UInt4 *             exp;            /* ptr to expnts of product        */
    UInt                i;              /* loop variable                   */
    Obj                 prd;            /* product of two coefficients     */

    /* for $rat * rat$ delegate                                            */
    if ( TNUM_OBJ(opL) != T_CYC && TNUM_OBJ(opR) != T_CYC ) {
        return PROD( opL, opR );
    }

    /* make the right operand the non cyclotomic                           */
    if ( TNUM_OBJ(opL) != T_CYC ) { hdP = opL;  opL = opR;  opR = hdP; }

    /* for $cyc * 0$ return 0 and for $cyc * 1$ return $cyc$               */
    if ( opR == INTOBJ_INT(0) ) {
        hdP = INTOBJ_INT(0);
    }
    else if ( opR == INTOBJ_INT(1) ) {
        hdP = opL;
    }

    /* for $cyc * -1$ need no multiplication or division                   */
    else if ( opR == INTOBJ_INT(-1) ) {
        return AInvCyc( opL );
    }

    /* for $cyc * small$ use immediate multiplication if possible          */
    else if ( IS_INTOBJ(opR) ) {
        hdP = NewBag( T_CYC, SIZE_CYC(opL) * (sizeof(Obj)+sizeof(UInt4)) );
        SET_NOF_CYC(hdP, NOF_CYC(opL));
        len = SIZE_CYC(opL);
        cfs = CONST_COEFS_CYC(opL);
        exs = CONST_EXPOS_CYC(opL,len);
        cfp = COEFS_CYC(hdP);
        exp = EXPOS_CYC(hdP,len);
        for ( i = 1; i < len; i++ ) {
            if ( ! IS_INTOBJ( cfs[i] )
              || ! PROD_INTOBJS( prd, cfs[i], opR ) ) {
                CHANGED_BAG( hdP );
                prd = PROD( cfs[i], opR );
                cfs = CONST_COEFS_CYC(opL);
                exs = CONST_EXPOS_CYC(opL,len);
                cfp = COEFS_CYC(hdP);
                exp = EXPOS_CYC(hdP,len);
            }
            cfp[i] = prd;
            exp[i] = exs[i];
        }
        CHANGED_BAG( hdP );
    }

    /* otherwise multiply every coefficent                                 */
    else {
        len = SIZE_OBJ(opL);
        hdP = NewBag(T_CYC, len);
        memcpy( ADDR_OBJ(hdP), CONST_ADDR_OBJ(opL), len);
        len = SIZE_CYC(opL);
        cfp = COEFS_CYC(hdP);
        for ( i = 1; i < len; i++ ) {
            prd = PROD( cfp[i], opR );
            cfp = COEFS_CYC(hdP);
            cfp[i] = prd;
            CHANGED_BAG( hdP );
        }
    }

    return hdP;
}


/****************************************************************************
**
*F  ProdCyc( <opL>, <opR> ) . . . . . . . . . . .  product of two cyclotomics
**
**  'ProdCyc' returns the product of the two  cyclotomics  <opL>  and  <opR>.
**  Either operand may also be an integer or a rational.
**
**  This   function  is lengthy  because  we  try to  use immediate   integer
**  arithmetic if possible to avoid the function call overhead.
*/
static Obj ProdCyc(Obj opL, Obj opR)
{
    UInt                nl, nr;         /* order of left and right field   */
    UInt                n;              /* order of smallest superfield    */
    UInt                ml, mr;         /* cofactors into the superfield   */
    Obj                 c;              /* one coefficient of the left op  */
    UInt                e;              /* one exponent of the left op     */
    UInt                len;            /* number of terms                 */
    const Obj *         cfs;            /* pointer to the coefficients     */
    const UInt4 *       exs;            /* pointer to the exponents        */
    Obj *               res;            /* pointer to the result           */
    Obj                 sum;            /* sum of two coefficients         */
    Obj                 prd;            /* product of two coefficients     */
    UInt                i, k;           /* loop variable                   */

    /* for $rat * cyc$ and $cyc * rat$ delegate                            */
    if ( TNUM_OBJ(opL) != T_CYC || TNUM_OBJ(opR) != T_CYC ) {
        return ProdCycInt( opL, opR );
    }

    /* take the cyclotomic with less terms as the right operand            */
    if ( SIZE_CYC(opL) < SIZE_CYC(opR) ) {
        prd = opL;  opL = opR;  opR = prd;
    }

    /* get the smallest field that contains both cyclotomics               */
    nl = (TNUM_OBJ(opL) != T_CYC ? 1 : INT_INTOBJ( NOF_CYC(opL) ));
    nr = (TNUM_OBJ(opR) != T_CYC ? 1 : INT_INTOBJ( NOF_CYC(opR) ));
    n = FindCommonField(nl, nr, &ml, &mr);

    /* loop over the terms of the right operand                            */
    for ( k = 1; k < SIZE_CYC(opR); k++ ) {
        c = COEFS_CYC(opR)[k];
        e = (mr * CONST_EXPOS_CYC( opR, SIZE_CYC(opR) )[k]) % n;

        /* if the coefficient is 1 just add                                */
        if ( c == INTOBJ_INT(1) ) {
            len = SIZE_CYC(opL);
            cfs = CONST_COEFS_CYC(opL);
            exs = CONST_EXPOS_CYC(opL,len);
            res = BASE_PTR_PLIST(ResultCyc);
            for ( i = 1; i < len; i++ ) {
                if ( ! ARE_INTOBJS( res[(e+exs[i]*ml)%n], cfs[i] )
                  || ! SUM_INTOBJS( sum, res[(e+exs[i]*ml)%n], cfs[i] ) ) {
                    CHANGED_BAG( ResultCyc );
                    sum = SUM( res[(e+exs[i]*ml)%n], cfs[i] );
                    cfs = CONST_COEFS_CYC(opL);
                    exs = CONST_EXPOS_CYC(opL,len);
                    res = BASE_PTR_PLIST(ResultCyc);
                }
                res[(e+exs[i]*ml)%n] = sum;
            }
            CHANGED_BAG( ResultCyc );
        }

        /* if the coefficient is -1 just subtract                          */
        else if ( c == INTOBJ_INT(-1) ) {
            len = SIZE_CYC(opL);
            cfs = CONST_COEFS_CYC(opL);
            exs = CONST_EXPOS_CYC(opL,len);
            res = BASE_PTR_PLIST(ResultCyc);
            for ( i = 1; i < len; i++ ) {
                if ( ! ARE_INTOBJS( res[(e+exs[i]*ml)%n], cfs[i] )
                  || ! DIFF_INTOBJS( sum, res[(e+exs[i]*ml)%n], cfs[i] ) ) {
                    CHANGED_BAG( ResultCyc );
                    sum = DIFF( res[(e+exs[i]*ml)%n], cfs[i] );
                    cfs = CONST_COEFS_CYC(opL);
                    exs = CONST_EXPOS_CYC(opL,len);
                    res = BASE_PTR_PLIST(ResultCyc);
                }
                res[(e+exs[i]*ml)%n] = sum;
            }
            CHANGED_BAG( ResultCyc );
        }

        /* if the coefficient is a small integer use immediate operations  */
        else if ( IS_INTOBJ(c) ) {
            len = SIZE_CYC(opL);
            cfs = CONST_COEFS_CYC(opL);
            exs = CONST_EXPOS_CYC(opL,len);
            res = BASE_PTR_PLIST(ResultCyc);
            for ( i = 1; i < len; i++ ) {
                if ( ! ARE_INTOBJS( cfs[i], res[(e+exs[i]*ml)%n] )
                  || ! PROD_INTOBJS( prd, cfs[i], c )
                  || ! SUM_INTOBJS( sum, res[(e+exs[i]*ml)%n], prd ) ) {
                    CHANGED_BAG( ResultCyc );
                    prd = PROD( cfs[i], c );
                    exs = CONST_EXPOS_CYC(opL,len);
                    res = BASE_PTR_PLIST(ResultCyc);
                    sum = SUM( res[(e+exs[i]*ml)%n], prd );
                    cfs = CONST_COEFS_CYC(opL);
                    exs = CONST_EXPOS_CYC(opL,len);
                    res = BASE_PTR_PLIST(ResultCyc);
                }
                res[(e+exs[i]*ml)%n] = sum;
            }
            CHANGED_BAG( ResultCyc );
        }

        /* otherwise do it the normal way                                  */
        else {
            len = SIZE_CYC(opL);
            for ( i = 1; i < len; i++ ) {
                CHANGED_BAG( ResultCyc );
                cfs = CONST_COEFS_CYC(opL);
                prd = PROD( cfs[i], c );
                exs = CONST_EXPOS_CYC(opL,len);
                res = BASE_PTR_PLIST(ResultCyc);
                sum = SUM( res[(e+exs[i]*ml)%n], prd );
                exs = CONST_EXPOS_CYC(opL,len);
                res = BASE_PTR_PLIST(ResultCyc);
                res[(e+exs[i]*ml)%n] = sum;
            }
            CHANGED_BAG( ResultCyc );
        }

    }

    /* return the base reduced packed cyclotomic                           */
    ConvertToBase( n );
    return Cyclotomic( n, ml * mr );
}


/****************************************************************************
**
*F  OneCyc( <op> )  . . . . . . . . . . . . . . . . . . . one of a cyclotomic
**
**  'OneCyc'  returns  the multiplicative neutral  element  of the cyclotomic
**  <op>.
*/
static Obj OneCyc(Obj op)
{
    return INTOBJ_INT(1);
}


/****************************************************************************
**
*F  InvCyc( <op> )  . . . . . . . . . . . . . . . . . inverse of a cyclotomic
**
**  'InvCyc' returns the  multiplicative  inverse element  of  the cyclotomic
**  <op>.
**
**  'InvCyc' computes the  inverse of <op> by computing  the product $prd$ of
**  nontrivial Galois conjugates of <op>.  Then $op * (prd / (op * prd)) = 1$
**  so $prd / (op  * prd)$ is the  inverse of $op$.  Because the  denominator
**  $op *  prd$ is the norm  of $op$ over the rationals  it is rational so we
**  can compute the quotient $prd / (op * prd)$ with 'ProdCycInt'.
*T better multiply only the *different* conjugates?
*/
static Obj InvCyc(Obj op)
{
    Obj                 prd;            /* product of conjugates           */
    UInt                n;              /* order of the field              */
    UInt                sqr;            /* if n < sqr*sqr n is squarefree  */
    UInt                len;            /* number of terms                 */
    const Obj *         cfs;            /* pointer to the coefficients     */
    const UInt4 *       exs;            /* pointer to the exponents        */
    Obj *               res;            /* pointer to the result           */
    UInt                i, k;           /* loop variable                   */
    UInt                gcd, s, t;      /* gcd of i and n, temporaries     */

    /* get the order of the field, test if it is squarefree                */
    n = INT_INTOBJ( NOF_CYC(op) );
    for ( sqr = 2; sqr*sqr <= n && n % (sqr*sqr) != 0; sqr++ )
        ;

    /* compute the product of all nontrivial galois conjugates of <opL>    */
    len = SIZE_CYC(op);
    prd = INTOBJ_INT(1);
    for ( i = 2; i < n; i++ ) {

        /* if i gives a galois automorphism apply it                       */
        gcd = n; s = i; while ( s != 0 ) { t = s; s = gcd % s; gcd = t; }
        if ( gcd == 1 ) {

            /* permute the terms                                           */
            cfs = CONST_COEFS_CYC(op);
            exs = CONST_EXPOS_CYC(op,len);
            res = BASE_PTR_PLIST(ResultCyc);
            for ( k = 1; k < len; k++ )
                res[(i*exs[k])%n] = cfs[k];
            CHANGED_BAG( ResultCyc );

            /* if n is squarefree conversion and reduction are unnecessary */
            if ( n < sqr*sqr ) {
                prd = ProdCyc( prd, Cyclotomic( n, n ) );
            }
            else {
                ConvertToBase( n );
                prd = ProdCyc( prd, Cyclotomic( n, 1 ) );
            }

        }

    }

    /* the inverse is the product divided by the norm                      */
    return ProdCycInt( prd, INV( ProdCyc( op, prd ) ) );
}


/****************************************************************************
**
*F  PowCyc( <opL>, <opR> )  . . . . . . . . . . . . . . power of a cyclotomic
**
**  'PowCyc' returns the <opR>th, which must be  an  integer,  power  of  the
**  cyclotomic <opL>.  The left operand may also be an integer or a rational.
*/
static Obj PowCyc(Obj opL, Obj opR)
{
    Obj                 pow;            /* power (result)                  */
    Int                 exp;            /* exponent (right operand)        */
    Int                 n;              /* order of the field              */
    UInt                i;              /* exponent of left operand        */

    /* get the exponent                                                    */
    exp = INT_INTOBJ(opR);

    /* for $cyc^0$ return 1, for $cyc^1$ return cyc, for $rat^exp$ delegate*/
    if ( exp == 0 ) {
        pow = INTOBJ_INT(1);
    }
    else if ( exp == 1 ) {
        pow = opL;
    }
    else if ( TNUM_OBJ(opL) != T_CYC ) {
        pow = PowInt( opL, opR );
    }

    /* for $e_n^exp$ just put a 1 at the <exp>th position and convert      */
    else if ( opL == LastECyc ) {
        n = LastNCyc;
        exp = (exp % n + n) % n;
        SET_ELM_PLIST( ResultCyc, exp + 1, INTOBJ_INT(1) );
        CHANGED_BAG( ResultCyc );
        ConvertToBase( LastNCyc );
        pow = Cyclotomic( LastNCyc, 1 );
    }

    /* for $(c*e_n^i)^exp$ if $e_n^i$ belongs to the base put 1 at $i*exp$ */
    else if ( SIZE_CYC(opL) == 2 ) {
        n = INT_INTOBJ( NOF_CYC(opL) );
        pow = POW( CONST_COEFS_CYC(opL)[1], opR );
        i = CONST_EXPOS_CYC(opL,2)[1];
        exp = ((exp*(Int)i) % n + n) % n;
        SET_ELM_PLIST( ResultCyc, exp + 1, pow );
        CHANGED_BAG( ResultCyc );
        ConvertToBase( n );
        pow = Cyclotomic( n, 1 );
    }

    /* otherwise compute the power with repeated squaring                  */
    else {

        /* if necessary invert the cyclotomic                             */
        if ( exp < 0 ) {
            opL = InvCyc( opL );
            exp = -exp;
        }

        /* compute the power using repeated squaring                       */
        pow = INTOBJ_INT(1);
        while ( exp != 0 ) {
            if ( exp % 2 == 1 )  pow = ProdCyc( pow, opL );
            if ( exp     >  1 )  opL = ProdCyc( opL, opL );
            exp = exp / 2;
        }

    }

    return pow;
}


/****************************************************************************
**
*F  FuncE( <self>, <n> )  . . . . . . . . . . . . create a new primitive root
**
**  'FuncE' implements the internal function 'E'.
**
**  'E( <n> )'
**
**  'E'  returns a  primitive  root of order <n>, which must  be  a  positive
**  integer, represented as cyclotomic.
*/
static Obj EOper;

static Obj FuncE(Obj self, Obj n)
{
    Obj *               res;            /* pointer into result bag         */

    /* do full operation                                                   */
    if ( FIRST_EXTERNAL_TNUM <= TNUM_OBJ(n) ) {
        return DoOperation1Args( self, n );
    }

    GetPositiveSmallInt("E", n);

    /* for $e_1$ return 1 and for $e_2$ return -1                          */
    if ( n == INTOBJ_INT(1) )
        return INTOBJ_INT(1);
    else if ( n == INTOBJ_INT(2) )
        return INTOBJ_INT(-1);

    /* if the root is not known already construct it                       */
    if ( LastNCyc != INT_INTOBJ(n) ) {
        LastNCyc = INT_INTOBJ(n);
        GrowResultCyc(LastNCyc);
        res = BASE_PTR_PLIST(ResultCyc);
        res[1] = INTOBJ_INT(1);
        CHANGED_BAG( ResultCyc );
        ConvertToBase( LastNCyc );
        LastECyc = Cyclotomic( LastNCyc, 1 );
    }

    /* return the root                                                     */
    return LastECyc;
}


/****************************************************************************
**
*F  FiltIS_CYC( <self>, <val> ) . . . . . .  test if an object is a cyclomtic
**
**  'FiltIS_CYC' implements the internal function 'IsCyc'.
**
**  'IsCyc( <val> )'
**
**  'IsCyc' returns 'true'  if the value <val> is   a cyclotomic and  'false'
**  otherwise.
*/
static Obj IsCycFilt;

static Obj FiltIS_CYC(Obj self, Obj val)
{
    /* return 'true' if <obj> is a cyclotomic and 'false' otherwise        */
    if (IS_CYC(val))
        return True;
    else if ( TNUM_OBJ(val) < FIRST_EXTERNAL_TNUM ) {
        return False;
    }
    else {
        return DoFilter( self, val );
    }
}


/****************************************************************************
**
*F  FuncIS_CYC_INT( <self>, <val> )  test if an object is a cyclomtic integer
**
**  'FuncIS_CYC_INT' implements the internal function 'IsCycInt'.
**
**  'IsCycInt( <val> )'
**
**  'IsCycInt' returns 'true' if the value  <val> is a cyclotomic integer and
**  'false' otherwise.
**
**  'IsCycInt' relies on the fact that the base is an integral base.
*/
static Obj IsCycIntOper;

static Obj FuncIS_CYC_INT(Obj self, Obj val)
{
    UInt                len;            /* number of terms                 */
    const Obj *         cfs;            /* pointer to the coefficients     */
    UInt                i;              /* loop variable                   */

    /* return 'true' if <obj> is a cyclotomic integer and 'false' otherwise*/
    if ( IS_INT(val) ) {
        return True;
    }
    else if ( TNUM_OBJ(val) == T_RAT ) {
        return False;
    }
    else if ( TNUM_OBJ(val) == T_CYC ) {
        len = SIZE_CYC(val);
        cfs = COEFS_CYC(val);
        for ( i = 1; i < len; i++ ) {
            if ( TNUM_OBJ(cfs[i]) == T_RAT )
                return False;
        }
        return True;
    }
    else if ( TNUM_OBJ(val) < FIRST_EXTERNAL_TNUM ) {
        return False;
    }
    else {
        return DoOperation1Args( self, val );
    }
}


/****************************************************************************
**
*F  AttrCONDUCTOR( <self>, <cyc> )  . . . . . . . . . . . . N of a cyclotomic
**
**  'AttrCONDUCTOR' implements the internal function 'Conductor'.
**
**  'Conductor( <cyc> )'
**
**  'Conductor' returns the N of the cyclotomic <cyc>, i.e., the order of the
**  roots of which <cyc> is written as a linear combination.
*/
static Obj ConductorAttr;

static Obj AttrCONDUCTOR(Obj self, Obj cyc)
{
    UInt                n;              /* N of the cyclotomic, result     */
    UInt                m;              /* N of element of the list        */
    UInt                gcd, s, t;      /* gcd of n and m, temporaries     */
    Obj                 list;           /* list of cyclotomics             */
    UInt                i;              /* loop variable                   */

    /* do full operation                                                   */
    if ( FIRST_EXTERNAL_TNUM <= TNUM_OBJ(cyc) ) {
        return DoAttribute( ConductorAttr, cyc );
    }

    if (!IS_CYC(cyc) && !IS_SMALL_LIST(cyc)) {
        RequireArgument(SELF_NAME, cyc,
                        "must be a cyclotomic or a small list");
    }

    /* handle cyclotomics                                                  */
    if ( IS_INT(cyc) || TNUM_OBJ(cyc) == T_RAT ) {
        n = 1;
    }
    else if ( TNUM_OBJ(cyc) == T_CYC ) {
        n = INT_INTOBJ( NOF_CYC(cyc) );
    }

    /* handle a list by computing the lcm of the entries                   */
    else {
        list = cyc;
        n = 1;
        for ( i = 1; i <= LEN_LIST( list ); i++ ) {
            cyc = ELMV_LIST( list, i );
            if (!IS_INT(cyc) && TNUM_OBJ(cyc) != T_RAT &&
                TNUM_OBJ(cyc) != T_CYC) {
                ErrorMayQuit(
                    "Conductor: <list>[%d] must be a cyclotomic (not a %s)",
                    (Int)i, (Int)TNAM_OBJ(cyc));
            }
            if ( IS_INT(cyc) || TNUM_OBJ(cyc) == T_RAT ) {
                m = 1;
            }
            else /* if ( TNUM_OBJ(cyc) == T_CYC ) */ {
                m = INT_INTOBJ( NOF_CYC(cyc) );
            }
            gcd = n; s = m; while ( s != 0 ) { t = s; s = gcd % s; gcd = t; }
            n = n / gcd * m;
        }
    }

    /* return the N of the cyclotomic                                      */
    return INTOBJ_INT( n );
}


/****************************************************************************
**
*F  FuncCOEFFS_CYC( <self>, <cyc> ) . . . . . .  coefficients of a cyclotomic
**
**  'FuncCOEFFS_CYC' implements the internal function 'COEFFSCYC'.
**
**  'COEFFSCYC( <cyc> )'
**
**  'COEFFSCYC' returns a list of the coefficients of the  cyclotomic  <cyc>.
**  The list has length <n> if <n> is the order of the primitive  root  $e_n$
**  of which <cyc> is written as a linear combination.  The <i>th element  of
**  the list is the coefficient of $e_l^{i-1}$.
*/
static Obj CoeffsCycOper;

static Obj FuncCOEFFS_CYC(Obj self, Obj cyc)
{
    Obj                 list;           /* list of coefficients, result    */
    UInt                n;              /* order of field                  */
    UInt                len;            /* number of terms                 */
    const Obj *         cfs;            /* pointer to the coefficients     */
    const UInt4 *       exs;            /* pointer to the exponents        */
    UInt                i;              /* loop variable                   */

    /* do full operation                                                   */
    if ( FIRST_EXTERNAL_TNUM <= TNUM_OBJ(cyc) ) {
        return DoOperation1Args( self, cyc );
    }

    if (!IS_CYC(cyc)) {
        RequireArgument(SELF_NAME, cyc, "must be a cyclotomic");
    }

    /* if <cyc> is rational just put it in a list of length 1              */
    if ( IS_INT(cyc) || TNUM_OBJ(cyc) == T_RAT ) {
        list = NewPlistFromArgs(cyc);
        /* 'CHANGED_BAG' not needed for last bag                           */
    }

    /* otherwise make a list and fill it with zeroes and copy the coeffs   */
    else {
        n = INT_INTOBJ( NOF_CYC(cyc) );
        list = NEW_PLIST( T_PLIST, n );
        SET_LEN_PLIST( list, n );
        len = SIZE_CYC(cyc);
        cfs = CONST_COEFS_CYC(cyc);
        exs = CONST_EXPOS_CYC(cyc,len);
        for ( i = 1; i <= n; i++ )
            SET_ELM_PLIST( list, i, INTOBJ_INT(0) );
        for ( i = 1; i < len; i++ )
            SET_ELM_PLIST( list, exs[i]+1, cfs[i] );
        /* 'CHANGED_BAG' not needed for last bag                           */
    }

    return list;
}


/****************************************************************************
**
*F  FuncGALOIS_CYC( <self>, <cyc>, <ord> )   image of a cyc. under galois aut
**
**  'FuncGALOIS_CYC' implements the internal function 'GaloisCyc'.
**
**  'GaloisCyc( <cyc>, <ord> )'
**
**  'GaloisCyc' computes the image of the cyclotomic <cyc>  under  the galois
**  automorphism given by <ord>, which must be an integer.
**
**  The galois automorphism is the mapping that  takes  $e_n$  to  $e_n^ord$.
**  <ord> may be any integer, of course if it is not relative prime to  $ord$
**  the mapping will not be an automorphism, though still an endomorphism.
*/
static Obj GaloisCycOper;

static Obj FuncGALOIS_CYC(Obj self, Obj cyc, Obj ord)
{
    Obj                 gal;            /* galois conjugate, result        */
    Obj                 sum;            /* sum of two coefficients         */
    Int                 n;              /* order of the field              */
    UInt                sqr;            /* if n < sqr*sqr n is squarefree  */
    Int                 o;              /* galois automorphism             */
    UInt                gcd, s, t;      /* gcd of n and ord, temporaries   */
    UInt                len;            /* number of terms                 */
    const Obj *         cfs;            /* pointer to the coefficients     */
    const UInt4 *       exs;            /* pointer to the exponents        */
    Obj *               res;            /* pointer to the result           */
    UInt                i;              /* loop variable                   */

    /* do full operation for any but standard arguments */
    if (!IS_INT(ord) || !IS_CYC(cyc)) {
        return DoOperation2Args( self, cyc, ord );
    }

    /* get and check <ord>                                                 */
    if ( ! IS_INTOBJ(ord) ) {
        ord = MOD( ord, AttrCONDUCTOR( 0, cyc ) );
    }
    o = INT_INTOBJ(ord);

    /* every galois automorphism fixes the rationals                       */
    if (TNUM_OBJ(cyc) != T_CYC) {
        return cyc;
    }

    /* get the order of the field, test if it squarefree                   */
    n = INT_INTOBJ( NOF_CYC(cyc) );
    for ( sqr = 2; sqr*sqr <= n && n % (sqr*sqr) != 0; sqr++ )
        ;

    /* force <ord> into the range 0..n-1, compute the gcd of <ord> and <n> */
    o = (o % n + n) % n;
    gcd = n; s = o;  while ( s != 0 ) { t = s; s = gcd % s; gcd = t; }

    /* if <ord> = 1 just return <cyc>                                      */
    if ( o == 1 ) {
        gal = cyc;
    }

    /* if <ord> == 0 compute the sum of the entries                        */
    else if ( o == 0 ) {
        len = SIZE_CYC(cyc);
        cfs = COEFS_CYC(cyc);
        gal = INTOBJ_INT(0);
        for ( i = 1; i < len; i++ ) {
            if ( ! ARE_INTOBJS( gal, cfs[i] )
              || ! SUM_INTOBJS( sum, gal, cfs[i] ) ) {
                sum = SUM( gal, cfs[i] );
                cfs = COEFS_CYC( cyc );
            }
            gal = sum;
        }
    }

    /* if <ord> == n/2 compute alternating sum since $(e_n^i)^ord = -1^i$  */
    else if ( n % 2 == 0  && o == n/2 ) {
        gal = INTOBJ_INT(0);
        len = SIZE_CYC(cyc);
        cfs = CONST_COEFS_CYC(cyc);
        exs = CONST_EXPOS_CYC(cyc,len);
        for ( i = 1; i < len; i++ ) {
            if ( exs[i] % 2 == 1 ) {
                if ( ! ARE_INTOBJS( gal, cfs[i] )
                  || ! DIFF_INTOBJS( sum, gal, cfs[i] ) ) {
                    sum = DIFF( gal, cfs[i] );
                    cfs = CONST_COEFS_CYC(cyc);
                    exs = CONST_EXPOS_CYC(cyc,len);
                }
                gal = sum;
            }
            else {
                if ( ! ARE_INTOBJS( gal, cfs[i] )
                  || ! SUM_INTOBJS( sum, gal, cfs[i] ) ) {
                    sum = SUM( gal, cfs[i] );
                    cfs = CONST_COEFS_CYC(cyc);
                    exs = CONST_EXPOS_CYC(cyc,len);
                }
                gal = sum;
            }
        }
    }

    /* if <ord> is prime to <n> (automorphism) permute the coefficients    */
    else if ( gcd == 1 ) {

        /* permute the coefficients                                        */
        len = SIZE_CYC(cyc);
        cfs = CONST_COEFS_CYC(cyc);
        exs = CONST_EXPOS_CYC(cyc,len);
        res = BASE_PTR_PLIST(ResultCyc);
        for ( i = 1; i < len; i++ ) {
            res[(UInt8)exs[i]*(UInt8)o%(UInt8)n] = cfs[i];
        }
        CHANGED_BAG( ResultCyc );

        /* if n is squarefree conversion and reduction are unnecessary     */
        if ( n < sqr*sqr || (o == n-1 && n % 2 != 0) ) {
            gal = Cyclotomic( n, n );
        }
        else {
            ConvertToBase( n );
            gal = Cyclotomic( n, 1 );
        }

    }

    /* if <ord> is not prime to <n> (endomorphism) compute it the hard way */
    else {

        /* multiple roots may be mapped to the same root, add the coeffs   */
        len = SIZE_CYC(cyc);
        cfs = CONST_COEFS_CYC(cyc);
        exs = CONST_EXPOS_CYC(cyc,len);
        res = BASE_PTR_PLIST(ResultCyc);
        for ( i = 1; i < len; i++ ) {
            if ( ! ARE_INTOBJS( res[(UInt8)exs[i]*(UInt8)o%(UInt8)n], cfs[i] )
              || ! SUM_INTOBJS( sum, res[(UInt8)exs[i]*(UInt8)o%(UInt8)n], cfs[i] ) ) {
                CHANGED_BAG( ResultCyc );
                sum = SUM( res[(UInt8)exs[i]*(UInt8)o%(UInt8)n], cfs[i] );
                cfs = CONST_COEFS_CYC(cyc);
                exs = CONST_EXPOS_CYC(cyc,len);
                res = BASE_PTR_PLIST(ResultCyc);
            }
            res[exs[i]*o%n] = sum;
        }
        CHANGED_BAG( ResultCyc );

        /* if n is squarefree conversion and reduction are unnecessary     */
        if ( n < sqr*sqr ) {
            gal = Cyclotomic( n, 1 ); /*N?*/
        }
        else {
            ConvertToBase( n );
            gal = Cyclotomic( n, 1 );
        }

    }

    return gal;
}


/****************************************************************************
**
*F  FuncCycList( <self>, <list> ) . . . . . . . . . . . . create a cyclotomic
**
**  'FuncCycList' implements the internal function 'CycList'.
**
**  'CycList( <list> )'
**
**  'CycList' returns the cyclotomic described by the list <list>
**  of rationals.
*/
static Obj CycListOper;

static Obj FuncCycList(Obj self, Obj list)
{
    UInt                i;              /* loop variable                   */
    Obj *               res;            /* pointer into result bag         */
    Obj                 val;            /* one list entry                  */
    UInt                n;              /* length of the given list        */

    /* do full operation                                                   */
    if ( FIRST_EXTERNAL_TNUM <= TNUM_OBJ( list ) ) {
        return DoOperation1Args( self, list );
    }

    if ( ! IS_PLIST( list ) || ! IS_DENSE_LIST( list ) ) {
        RequireArgument(SELF_NAME, list, "must be a dense plain list");
    }

    /* enlarge the buffer if necessary                                     */
    n = LEN_PLIST( list );
    GrowResultCyc(n);

    /* transfer the coefficients into the buffer                           */
    res = BASE_PTR_PLIST(ResultCyc);
    for ( i = 0; i < n; i++ ) {
        val = ELM_PLIST( list, i+1 );
        if ( !IS_INT(val) && TNUM_OBJ(val) != T_RAT ) {
            // reset ResultCyc, otherwise the next operation using it will see
            // our left-over garbage data
            SET_LEN_PLIST( ResultCyc, 0 );
            RequireArgumentEx(SELF_NAME, val, 0,
                              "each entry must be a rational");
        }
        res[i] = val;
    }

    /* return the base reduced packed cyclotomic                           */
    CHANGED_BAG( ResultCyc );
    ConvertToBase( n );
    return Cyclotomic( n, 1 );
}


/****************************************************************************
**
*F  MarkCycSubBags( <bag> ) . . . . . . . .  marking function for cyclotomics
**
**  'MarkCycSubBags' is the marking function for bags of type 'T_CYC'.
*/
static void MarkCycSubBags(Obj cyc)
{
    MarkArrayOfBags( COEFS_CYC( cyc ), SIZE_CYC(cyc) );
}


/****************************************************************************
**
*F  SaveCyc() . . . . . . . . . . . . . . . . . . . . . . . save a cyclotomic
**
**  We do not save the XXX_CYC field, since it is not used.
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SaveCyc(Obj cyc)
{
  UInt len, i;
  const Obj *coefs;
  const UInt4 *expos;
  len = SIZE_CYC(cyc);
  coefs = CONST_COEFS_CYC(cyc);
  for (i = 0; i < len; i++)
    SaveSubObj(*coefs++);
  expos = CONST_EXPOS_CYC(cyc,len);
  expos++;                      /*Skip past the XXX */
  for (i = 1; i < len; i++)
    SaveUInt4(*expos++);
}
#endif


/****************************************************************************
**
*F  LoadCyc() . . . . . . . . . . . . . . . . . . . . . . . load a cyclotomic
**
**  We do not load the XXX_CYC field, since it is not used.
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadCyc(Obj cyc)
{
  UInt len, i;
  Obj *coefs;
  UInt4 *expos;
  len = SIZE_CYC(cyc);
  coefs = COEFS_CYC(cyc);
  for (i = 0; i < len; i++)
    *coefs++ = LoadSubObj();
  expos = EXPOS_CYC(cyc,len);
  expos++;                      /*Skip past the XXX */
  for (i = 1; i < len; i++)
    *expos++ = LoadUInt4();
}
#endif


/****************************************************************************
**
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_CYC, "cyclotomic" },
  { -1,    ""           }
};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IS_CYC, "obj", &IsCycFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarAttrs . . . . . . . . . . . . . . . . .  list of attributes to export
*/
static StructGVarAttr GVarAttrs [] = {

    GVAR_ATTR(CONDUCTOR, "cyc", &ConductorAttr),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers [] = {

    GVAR_OPER_1ARGS(E, n, &EOper),
    GVAR_OPER_1ARGS(IS_CYC_INT, obj, &IsCycIntOper),
    GVAR_OPER_1ARGS(COEFFS_CYC, cyc, &CoeffsCycOper),
    GVAR_OPER_2ARGS(GALOIS_CYC, cyc, n, &GaloisCycOper),
    GVAR_OPER_1ARGS(CycList, list, &CycListOper),
    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . .  list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {
  GVAR_FUNC_1ARGS(SetCyclotomicsLimit, newlimit),
  GVAR_FUNC_0ARGS(GetCyclotomicsLimit),
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

    /* install the marking function                                        */
    InitMarkFuncBags( T_CYC, MarkCycSubBags );

    /* create the result buffer                                            */
    InitGlobalBag( &ResultCyc , "src/cyclotom.c:ResultCyc" );

    /* tell Gasman about the place were we remember the primitive root     */
    InitGlobalBag( &LastECyc, "src/cyclotom.c:LastECyc" );

    /* install the type function                                           */
    ImportGVarFromLibrary( "TYPE_CYC", &TYPE_CYC );
    TypeObjFuncs[ T_CYC ] = TypeCyc;

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrAttrsFromTable( GVarAttrs );
    InitHdlrOpersFromTable( GVarOpers );
    InitHdlrFuncsFromTable( GVarFuncs );

#ifdef GAP_ENABLE_SAVELOAD
    /* and the saving function                                             */
    SaveObjFuncs[ T_CYC ] = SaveCyc;
    LoadObjFuncs[ T_CYC ] = LoadCyc;
#endif

    /* install the evaluation and print function                           */
    PrintObjFuncs[ T_CYC ] = PrintCyc;

    /* install the comparison methods                                      */
    EqFuncs[   T_CYC    ][ T_CYC    ] = EqCyc;
    LtFuncs[   T_CYC    ][ T_CYC    ] = LtCyc;
    LtFuncs[   T_INT    ][ T_CYC    ] = LtCycYes;
    LtFuncs[   T_INTPOS ][ T_CYC    ] = LtCycYes;
    LtFuncs[   T_INTNEG ][ T_CYC    ] = LtCycYes;
    LtFuncs[   T_RAT    ][ T_CYC    ] = LtCycYes;
    LtFuncs[   T_CYC    ][ T_INT    ] = LtCycNot;
    LtFuncs[   T_CYC    ][ T_INTPOS ] = LtCycNot;
    LtFuncs[   T_CYC    ][ T_INTNEG ] = LtCycNot;
    LtFuncs[   T_CYC    ][ T_RAT    ] = LtCycNot;

    /* install the unary arithmetic methods                                */
    ZeroFuncs[ T_CYC ] = ZeroCyc;
    ZeroMutFuncs[ T_CYC ] = ZeroCyc;
    AInvFuncs[ T_CYC ] = AInvCyc;
    AInvMutFuncs[ T_CYC ] = AInvCyc;
    OneFuncs [ T_CYC ] = OneCyc;
    OneMutFuncs [ T_CYC ] = OneCyc;
    InvFuncs [ T_CYC ] = InvCyc;
    InvMutFuncs [ T_CYC ] = InvCyc;

    /* install the arithmetic methods                                      */
    SumFuncs[  T_CYC    ][ T_CYC    ] = SumCyc;
    SumFuncs[  T_INT    ][ T_CYC    ] = SumCyc;
    SumFuncs[  T_INTPOS ][ T_CYC    ] = SumCyc;
    SumFuncs[  T_INTNEG ][ T_CYC    ] = SumCyc;
    SumFuncs[  T_RAT    ][ T_CYC    ] = SumCyc;
    SumFuncs[  T_CYC    ][ T_INT    ] = SumCyc;
    SumFuncs[  T_CYC    ][ T_INTPOS ] = SumCyc;
    SumFuncs[  T_CYC    ][ T_INTNEG ] = SumCyc;
    SumFuncs[  T_CYC    ][ T_RAT    ] = SumCyc;
    DiffFuncs[ T_CYC    ][ T_CYC    ] = DiffCyc;
    DiffFuncs[ T_INT    ][ T_CYC    ] = DiffCyc;
    DiffFuncs[ T_INTPOS ][ T_CYC    ] = DiffCyc;
    DiffFuncs[ T_INTNEG ][ T_CYC    ] = DiffCyc;
    DiffFuncs[ T_RAT    ][ T_CYC    ] = DiffCyc;
    DiffFuncs[ T_CYC    ][ T_INT    ] = DiffCyc;
    DiffFuncs[ T_CYC    ][ T_INTPOS ] = DiffCyc;
    DiffFuncs[ T_CYC    ][ T_INTNEG ] = DiffCyc;
    DiffFuncs[ T_CYC    ][ T_RAT    ] = DiffCyc;
    ProdFuncs[ T_CYC    ][ T_CYC    ] = ProdCyc;
    ProdFuncs[ T_INT    ][ T_CYC    ] = ProdCycInt;
    ProdFuncs[ T_INTPOS ][ T_CYC    ] = ProdCycInt;
    ProdFuncs[ T_INTNEG ][ T_CYC    ] = ProdCycInt;
    ProdFuncs[ T_RAT    ][ T_CYC    ] = ProdCycInt;
    ProdFuncs[ T_CYC    ][ T_INT    ] = ProdCycInt;
    ProdFuncs[ T_CYC    ][ T_INTPOS ] = ProdCycInt;
    ProdFuncs[ T_CYC    ][ T_INTNEG ] = ProdCycInt;
    ProdFuncs[ T_CYC    ][ T_RAT    ] = ProdCycInt;
    PowFuncs[  T_CYC    ][ T_INT    ] = PowCyc;

#ifdef HPCGAP
    MakeBagTypePublic(T_CYC);
#endif
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* create the result buffer                                            */
    GrowResultCyc( 1024 );

    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarAttrsFromTable( GVarAttrs );
    InitGVarOpersFromTable( GVarOpers );
    InitGVarFuncsFromTable( GVarFuncs );

    return 0;
}


static Int InitModuleState(void)
{
    ResultCyc = 0;
    LastECyc = 0;
    LastNCyc = 0;

    return 0;
}


/****************************************************************************
**
*F  InitInfoCyc() . . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "cyclotom",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,

    .moduleStateSize = sizeof(struct CycModuleState),
    .moduleStateOffsetPtr = &CycStateOffset,
    .initModuleState = InitModuleState,
};

StructInitInfo * InitInfoCyc ( void )
{
    return &module;
}
