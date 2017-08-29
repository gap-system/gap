/****************************************************************************
**
*W  rational.c                  GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains  the  functions  for  the  artithmetic  of  rationals.
**
**  Rationals  are  the union of  integers  and fractions.   A fraction  is a
**  quotient of two integers where the denominator is relatively prime to the
**  numerator.  If in the description of a function we  use the term rational
**  this  implies  that the  function is also   capable of handling integers,
**  though its  function would usually  be performed   by  a routine  in  the
**  integer package.  We will use the  term fraction to  stress the fact that
**  something must not be an integer.
**
**  A  fraction is represented  as a pair of  two integers.  The first is the
**  numerator and the second  is  the  denominator.  This representation   is
**  always reduced, i.e., numerator and denominator  are relative prime.  The
**  denominator is always  positive and  greater than 1.    If it were 1  the
**  fraction would be an integer and would be represented as  integer.  Since
**  the denominator is always positive the numerator carries the sign of  the
**  fraction.
**
**  It  is very easy to  see  that for every  fraction   there is one  unique
**  reduced representation.  Because of   this comparisons of  fractions  are
**  quite easy,  we just compare  numerator  and denominator.  Also numerator
**  and denominator are as small as possible,  reducing the effort to compute
**  with them.   Of course  computing  the reduced  representation comes at a
**  cost.   After every arithmetic operation we  have to compute the greatest
**  common divisor of numerator and denominator, and divide them by the gcd.
**
**  Effort  has been made to improve  efficiency by avoiding unneccessary gcd
**  computations.  Also if  possible this  package will compute  two gcds  of
**  smaller integers instead of one gcd of larger integers.
**
**  However no effort has  been made to write special  code for the case that
**  some of the  integers are small integers   (i.e., less than  2^28).  This
**  would reduce the overhead  introduced by the  calls to the functions like
**  'SumInt', 'ProdInt' or 'GcdInt'.
*/
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

#include <src/bool.h>                   /* booleans */

#include <src/gmpints.h>                /* integers */

#include <src/rational.h>               /* rationals */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/stringobj.h>              /* strings */

#include <src/saveload.h>               /* saving and loading */
#include <src/code.h>
#include <src/hpc/guards.h>


#if defined(DEBUG_RATIONALS)
#define CHECK_RAT(rat) if (TNUM_OBJ(rat) == T_RAT && \
                           GcdInt(NUM_RAT(rat),DEN_RAT(rat)) != INTOBJ_INT(1)) \
                             ErrorQuit("bad rational",0L,0L)
#else
#define CHECK_RAT(rat)
#endif


/****************************************************************************
**
*F  TypeRat( <rat> )  . . . . . . . . . . . . . . . . . .  type of a rational
**
**  'TypeRat' returns the type of the rational <rat>.
**
**  'TypeRat' is the function in 'TypeObjFuncs' for rationals.
*/
Obj             TYPE_RAT_POS;
Obj             TYPE_RAT_NEG;

Obj             TypeRat (
    Obj                 rat )
{
    Obj                 num;
    CHECK_RAT(rat);
    num = NUM_RAT(rat);
    if ( IS_INTOBJ(num) ) {
        if ( 0 < INT_INTOBJ(num) ) {
            return TYPE_RAT_POS;
        }
        else {
            return TYPE_RAT_NEG;
        }
    }
    else {
        if ( TNUM_OBJ(num) == T_INTPOS ) {
            return TYPE_RAT_POS;
        }
        else {
            return TYPE_RAT_NEG;
        }
    }
}


/****************************************************************************
**
*F  PrintRat( <rat> ) . . . . . . . . . . . . . . . . . . .  print a rational
**
**  'PrintRat' prints a rational <rat> in the form
**
**      <numerator> / <denominator>
*/
void            PrintRat (
    Obj                 rat )
{
    Pr( "%>", 0L, 0L );
    PrintObj( NUM_RAT(rat) );
    Pr( "%</%>", 0L, 0L );
    PrintObj( DEN_RAT(rat) );
    Pr( "%<", 0L, 0L );
}


/****************************************************************************
**
*F  EqRat( <opL>, <opR> ) . . . . . . . . . . . . . . test if <ratL> = <ratR>
**
**  'EqRat' returns 'true' if the two rationals <ratL> and <ratR>  are  equal
**  and 'false' otherwise.
*/
Int             EqRat (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 numL, denL;     /* numerator and denominator left  */
    Obj                 numR, denR;     /* numerator and denominator right */

    CHECK_RAT(opL);
    CHECK_RAT(opR);
    /* get numerator and denominator of the operands                       */
    if ( TNUM_OBJ(opL) == T_RAT ) {
        numL = NUM_RAT(opL);
        denL = DEN_RAT(opL);
    }
    else {
        numL = opL;
        denL = INTOBJ_INT( 1L );
    }
    if ( TNUM_OBJ(opR) == T_RAT ) {
        numR = NUM_RAT(opR);
        denR = DEN_RAT(opR);
    }
    else {
        numR = opR;
        denR = INTOBJ_INT( 1L );
    }

    /* compare the numerators                                              */
    if ( ! EQ( numL, numR ) ) {
        return 0L;
    }

    /* compare the denominators                                            */
    if ( ! EQ( denL, denR ) ) {
        return 0L;
    }

    /* no differences found, they must be equal                            */
    return 1L;
}


/****************************************************************************
**
*F  LtRat( <opL>, <opR> ) . . . . . . . . . . . . . . test if <ratL> < <ratR>
**
**  'LtRat' returns 'true'  if  the  rational  <ratL>  is  smaller  than  the
**  rational <ratR> and 'false' otherwise.  Either operand may be an integer.
*/
Int             LtRat (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 numL, denL;     /* numerator and denominator left  */
    Obj                 numR, denR;     /* numerator and denominator right */

    CHECK_RAT(opL);
    CHECK_RAT(opR);
    /* get numerator and denominator of the operands                       */
    if ( TNUM_OBJ(opL) == T_RAT ) {
        numL = NUM_RAT(opL);
        denL = DEN_RAT(opL);
    }
    else {
        numL = opL;
        denL = INTOBJ_INT( 1L );
    }
    if ( TNUM_OBJ(opR) == T_RAT ) {
        numR = NUM_RAT(opR);
        denR = DEN_RAT(opR);
    }
    else {
        numR = opR;
        denR = INTOBJ_INT( 1L );
    }

    /* a / b < c / d <=> a d < c b                                         */
    return LtInt( ProdInt( numL, denR ), ProdInt( numR, denL ) );
}


/****************************************************************************
**
*F  SumRat( <opL>, <opR> )  . . . . . . . . . . . . . .  sum of two rationals
**
**  'SumRat'  returns the   sum of two  rationals  <opL>  and <opR>.   Either
**  operand may also be an integer.  The sum is reduced.
*/
Obj             SumRat (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 numL, denL;     /* numerator and denominator left  */
    Obj                 numR, denR;     /* numerator and denominator right */
    Obj                 gcd1, gcd2;     /* gcd of denominators             */
    Obj                 numS, denS;     /* numerator and denominator sum   */
    Obj                 sum;            /* sum                             */

    CHECK_RAT(opL);
    CHECK_RAT(opR);
    /* get numerator and denominator of the operands                       */
    if ( TNUM_OBJ(opL) == T_RAT ) {
        numL = NUM_RAT(opL);
        denL = DEN_RAT(opL);
    }
    else {
        numL = opL;
        denL = INTOBJ_INT( 1L );
    }
    if ( TNUM_OBJ(opR) == T_RAT ) {
        numR = NUM_RAT(opR);
        denR = DEN_RAT(opR);
    }
    else {
        numR = opR;
        denR = INTOBJ_INT( 1L );
    }

    /* find the gcd of the denominators                                    */
    gcd1 = GcdInt( denL, denR );

    /* nothing can cancel if the gcd is 1                                  */
    if ( gcd1 == INTOBJ_INT( 1L ) ) {
        numS = SumInt( ProdInt( numL, denR ), ProdInt( numR, denL ) );
        denS = ProdInt( denL, denR );
    }

    /* a little bit more difficult otherwise                               */
    else {
        numS = SumInt( ProdInt( numL, QuoInt( denR, gcd1 ) ),
                       ProdInt( numR, QuoInt( denL, gcd1 ) ) );
        gcd2 = GcdInt( numS, gcd1 );
        numS = QuoInt( numS, gcd2 );
        denS = ProdInt( QuoInt( denL, gcd1 ), QuoInt( denR, gcd2 ) );
    }

    /* make the fraction or, if possible, the integer                      */
    if ( denS != INTOBJ_INT( 1L ) ) {
        sum  = NewBag( T_RAT, 2 * sizeof(Obj) );
        NUM_RAT(sum) = numS;
        DEN_RAT(sum) = denS;
        /* 'CHANGED_BAG' not needed, 'sum' is the youngest bag             */
    }
    else {
        sum = numS;
    }

    /* return the result                                                   */
    CHECK_RAT(sum);
    return sum;
}


/****************************************************************************
**
*F  ZeroRat(<op>) . . . . . . . . . . . . . . . . . . . .  zero of a rational
*/
Obj             ZeroRat (
    Obj                 op )
{
    return INTOBJ_INT( 0L );
}


/****************************************************************************
**
*F  AInvRat(<op>) . . . . . . . . . . . . . .  additive inverse of a rational
*/
Obj             AInvRat (
    Obj                 op )
{
    Obj                 res;
    Obj                 tmp;
    CHECK_RAT(op);
    res = NewBag( T_RAT, 2 * sizeof(Obj) );
    tmp = AINV( NUM_RAT(op) );
    NUM_RAT(res) = tmp;
    DEN_RAT(res) = DEN_RAT(op);
    CHANGED_BAG(res);
    CHECK_RAT(res);
    return res;
}


/****************************************************************************
**
*F  AbsRat(<op>) . . . . . . . . . . . . . . . . absolute value of a rational
*/
Obj AbsRat( Obj op )
{
    Obj res;
    Obj tmp;
    CHECK_RAT(op);
    tmp = AbsInt( NUM_RAT(op) );
    if ( tmp == NUM_RAT(op))
        return op;

    res = NewBag( T_RAT, 2 * sizeof(Obj) );
    NUM_RAT(res) = tmp;
    DEN_RAT(res) = DEN_RAT(op);
    CHANGED_BAG(res);
    CHECK_RAT(res);
    return res;

}

Obj FuncABS_RAT( Obj self, Obj op )
{
    Obj res;
    res = ( TNUM_OBJ(op) == T_RAT ) ? AbsRat(op) : AbsInt(op);
    if (res == Fail) {
        ErrorMayQuit("AbsRat: argument must be a rational or integer (not a %s)",
                     (Int)TNAM_OBJ(op), 0L);
    }
    return res;
}

/****************************************************************************
**
*F  SignRat(<op>) . . . . . . . . . . . . . . . . . . . .  sign of a rational
*/
Obj SignRat( Obj op )
{
    CHECK_RAT(op);
    return SignInt( NUM_RAT(op) );
}

Obj FuncSIGN_RAT( Obj self, Obj op )
{
    Obj res;
    res = ( TNUM_OBJ(op) == T_RAT ) ? SignRat(op) : SignInt(op);
    if (res == Fail) {
        ErrorMayQuit("SignRat: argument must be a rational or integer (not a %s)",
                     (Int)TNAM_OBJ(op), 0L);
    }
    return res;
}


/****************************************************************************
**
*F  DiffRat( <opL>, <opR> ) . . . . . . . . . . . difference of two rationals
**
**  'DiffRat' returns the  difference  of  two  rationals  <opL>  and  <opR>.
**  Either operand may also be an integer.  The difference is reduced.
*/
Obj             DiffRat (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 numL, denL;     /* numerator and denominator left  */
    Obj                 numR, denR;     /* numerator and denominator right */
    Obj                 gcd1, gcd2;     /* gcd of denominators             */
    Obj                 numD, denD;     /* numerator and denominator diff  */
    Obj                 dif;            /* diff                            */

    CHECK_RAT(opL);
    CHECK_RAT(opR);
    /* get numerator and denominator of the operands                       */
    if ( TNUM_OBJ(opL) == T_RAT ) {
        numL = NUM_RAT(opL);
        denL = DEN_RAT(opL);
    }
    else {
        numL = opL;
        denL = INTOBJ_INT( 1L );
    }
    if ( TNUM_OBJ(opR) == T_RAT ) {
        numR = NUM_RAT(opR);
        denR = DEN_RAT(opR);
    }
    else {
        numR = opR;
        denR = INTOBJ_INT( 1L );
    }

    /* find the gcd of the denominators                                    */
    gcd1 = GcdInt( denL, denR );

    /* nothing can cancel if the gcd is 1                                  */
    if ( gcd1 == INTOBJ_INT( 1L ) ) {
        numD = DiffInt( ProdInt( numL, denR ), ProdInt( numR, denL ) );
        denD = ProdInt( denL, denR );
    }

    /* a little bit more difficult otherwise                               */
    else {
        numD = DiffInt( ProdInt( numL, QuoInt( denR, gcd1 ) ),
                        ProdInt( numR, QuoInt( denL, gcd1 ) ) );
        gcd2 = GcdInt( numD, gcd1 );
        numD = QuoInt( numD, gcd2 );
        denD = ProdInt( QuoInt( denL, gcd1 ), QuoInt( denR, gcd2 ) );
    }

    /* make the fraction or, if possible, the integer                      */
    if ( denD != INTOBJ_INT( 1L ) ) {
        dif  = NewBag( T_RAT, 2 * sizeof(Obj) );
        NUM_RAT(dif) = numD;
        DEN_RAT(dif) = denD;
        /* 'CHANGED_BAG' not needed, 'dif' is the youngest bag             */
    }
    else {
        dif = numD;
    }

    /* return the result                                                   */
    CHECK_RAT(dif);
    return dif;
}


/****************************************************************************
**
*F  ProdRat( <opL>, <opR> ) . . . . . . . . . . . .  product of two rationals
**
**  'ProdRat' returns the  product of two rationals <opL> and  <opR>.  Either
**  operand may also be an integer.  The product is reduced.
*/
Obj             ProdRat (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 numL, denL;     /* numerator and denominator left  */
    Obj                 numR, denR;     /* numerator and denominator right */
    Obj                 gcd1, gcd2;     /* gcd of denominators             */
    Obj                 numP, denP;     /* numerator and denominator prod  */
    Obj                 prd;            /* prod                            */

    CHECK_RAT(opL);
    CHECK_RAT(opR);
    /* get numerator and denominator of the operands                       */
    if ( TNUM_OBJ(opL) == T_RAT ) {
        numL = NUM_RAT(opL);
        denL = DEN_RAT(opL);
    }
    else {
        numL = opL;
        denL = INTOBJ_INT( 1L );
    }
    if ( TNUM_OBJ(opR) == T_RAT ) {
        numR = NUM_RAT(opR);
        denR = DEN_RAT(opR);
    }
    else {
        numR = opR;
        denR = INTOBJ_INT( 1L );
    }

    /* find the gcds                                                       */
    gcd1 = GcdInt( numL, denR );
    gcd2 = GcdInt( numR, denL );

    /* nothing can cancel if the gcds are 1                                */
    if ( gcd1 == INTOBJ_INT( 1L ) && gcd2 == INTOBJ_INT( 1L ) ) {
        numP = ProdInt( numL, numR );
        denP = ProdInt( denL, denR );
    }

    /* a little bit more difficult otherwise                               */
    else {
        numP = ProdInt( QuoInt( numL, gcd1 ), QuoInt( numR, gcd2 ) );
        denP = ProdInt( QuoInt( denL, gcd2 ), QuoInt( denR, gcd1 ) );
    }

    /* make the fraction or, if possible, the integer                      */
    if ( denP != INTOBJ_INT( 1L ) ) {
        prd = NewBag( T_RAT, 2 * sizeof(Obj) );
        NUM_RAT(prd) = numP;
        DEN_RAT(prd) = denP;
        /* 'CHANGED_BAG' not needed, 'prd' is the youngest bag             */
    }
    else {
        prd = numP;
    }

    /* return the result                                                   */
    CHECK_RAT(prd);
    return prd;
}


/****************************************************************************
**
*F  OneRat(<op>)  . . . . . . . . . . . . . . . . . . . . . one of a rational
*/
Obj             OneRat (
    Obj                 op )
{
    return INTOBJ_INT( 1L );
}


/****************************************************************************
**
*F  InvRat(<op>)  . . . . . . . . . . . . . . . . . . . inverse of a rational
*/
extern  Obj             QuoRat (
            Obj                 opL,
            Obj                 opR );

Obj             InvRat (
    Obj                 op )
{
  Obj res;
    CHECK_RAT(op);
    if (op == INTOBJ_INT(0))
      return Fail;
    res = QuoRat( INTOBJ_INT( 1L ), op );
    CHECK_RAT(res);
    return res;
}


/****************************************************************************
**
*F  QuoRat( <opL>, <opR> )  . . . . . . . . . . . . quotient of two rationals
**
**  'QuoRat'  returns the quotient of two rationals <opL> and  <opR>.  Either
**  operand may also be an integer.  The quotient is reduced.
*/
Obj             QuoRat (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 numL, denL;     /* numerator and denominator left  */
    Obj                 numR, denR;     /* numerator and denominator right */
    Obj                 gcd1, gcd2;     /* gcd of denominators             */
    Obj                 numQ, denQ;     /* numerator and denominator Qrod  */
    Obj                 quo;            /* Qrod                            */

    CHECK_RAT(opL);
    CHECK_RAT(opR);
    /* get numerator and denominator of the operands                       */
    if ( TNUM_OBJ(opL) == T_RAT ) {
        numL = NUM_RAT(opL);
        denL = DEN_RAT(opL);
    }
    else {
        numL = opL;
        denL = INTOBJ_INT( 1L );
    }
    if ( TNUM_OBJ(opR) == T_RAT ) {
        numR = NUM_RAT(opR);
        denR = DEN_RAT(opR);
    }
    else {
        numR = opR;
        denR = INTOBJ_INT( 1L );
    }

    /* division by zero is an error                                        */
    if ( numR == INTOBJ_INT( 0L ) ) {
        opR = ErrorReturnObj(
            "Rational operations: <divisor> must not be zero",
            0L, 0L,
            "you can replace <divisor> via 'return <divisor>;'" );
        return QUO( opL, opR );
    }

    /* we multiply the left numerator with the right denominator           */
    /* so the right denominator should carry the sign of the right operand */
    if ( (IS_INTOBJ(numR) && INT_INTOBJ(numR) < 0)
      || TNUM_OBJ(numR) == T_INTNEG ) {
        numR = ProdInt( INTOBJ_INT( -1L ), numR );
        denR = ProdInt( INTOBJ_INT( -1L ), denR );
    }

    /* find the gcds                                                       */
    gcd1 = GcdInt( numL, numR );
    gcd2 = GcdInt( denR, denL );

    /* nothing can cancel if the gcds are 1                                */
    if ( gcd1 == INTOBJ_INT( 1L ) && gcd2 == INTOBJ_INT( 1L ) ) {
        numQ = ProdInt( numL, denR );
        denQ = ProdInt( denL, numR );
    }

    /* a little bit more difficult otherwise                               */
    else {
        numQ = ProdInt( QuoInt( numL, gcd1 ), QuoInt( denR, gcd2 ) );
        denQ = ProdInt( QuoInt( denL, gcd2 ), QuoInt( numR, gcd1 ) );
    }

    /* make the fraction or, if possible, the integer                      */
    if ( denQ != INTOBJ_INT( 1L ) ) {
        quo = NewBag( T_RAT, 2 * sizeof(Obj) );
        NUM_RAT(quo) = numQ;
        DEN_RAT(quo) = denQ;
        /* 'CHANGED_BAG' not needed, 'quo' is the youngest bag             */
    }
    else {
        quo = numQ;
    }

    /* return the result */
    CHECK_RAT(quo);
    return quo;
}


/****************************************************************************
**
*F  ModRat( <opL>, <opR> )  . . . . . . . . remainder of fraction mod integer
**
**  'ModRat' returns the remainder  of the fraction  <opL> modulo the integer
**  <opR>.  The remainder is always an integer.
**
**  '<r>  / <s> mod  <n>' yields  the remainder of   the fraction '<p> / <q>'
**  modulo  the  integer '<n>',  where '<p> / <q>' is  the  reduced  form  of
**  '<r>  / <s>'.
**
**  The modular remainder of $r / s$ mod $n$ is defined to be the integer $k$
**  in $0 .. n-1$ such that $p = k q$ mod $n$, where $p = r / gcd(r, s)$  and
**  $q = s / gcd(r, s)$. In particular, $1  /  s$  mod  $n$  is  the  modular
**  inverse of $s$ modulo $n$, whenever $s$ and $n$ are relatively prime.
**
**  Note that  the  remainder  will  not  exist  if  $s / gcd(r, s)$  is  not
**  relatively prime to $n$. Note that $4 / 6$ mod $32$ does  exist  (and  is
**  $22$), even though $6$ is not invertible modulo  $32$,  because  the  $2$
**  cancels.
**
**  Another possible  definition of $r/s$ mod $n$  would be  a rational $t/s$
**  such that $0 \<= t/s \< n$ and $r/s - t/s$ is a multiple of $n$.  This is
**  rarely needed while computing modular inverses is very useful.
*/
Obj             ModRat (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 a, aL, b, bL, c, cL, hdQ;

    /* make the integer positive                                           */
    if ( (IS_INTOBJ(opR) && INT_INTOBJ(opR) < 0)
      || TNUM_OBJ(opR) == T_INTNEG ) {
        opR = ProdInt( INTOBJ_INT( -1L ), opR );
    }

    /* let <p>/<q> represent <r>/<s> in reduced form                       */
    /* invert the denominator <q> modulo <n> with Euclids algorithm        */
    a = opR;           aL = INTOBJ_INT( 0L );   /* a = <n>                 */
    b = DEN_RAT(opL);  bL = INTOBJ_INT( 1L );   /* b = <q>                 */
    while ( a != INTOBJ_INT( 1L ) ) {
        while ( b != INTOBJ_INT( 0L ) ) {
            hdQ  = QuoInt( a, b );
            c  = b;  cL = bL;
            b  = DiffInt( a,  ProdInt( hdQ, b  ) );
            bL = DiffInt( aL, ProdInt( hdQ, bL ) );
            a  = c;  aL = cL;
        }

        /* check whether the denominator <q> really was invertible mod <n> */
        if ( a != INTOBJ_INT( 1L ) ) {
            opR = ErrorReturnObj(
                      "ModRat: for <r>/<s> mod <n>, <s>/gcd(<r>,<s>) and <n> must be coprime",
                      0L, 0L,
                      "you can replace the integer <n> via 'return <n>;'" );
            a = opR;           aL = INTOBJ_INT( 0L );   /* a = <n>         */
            b = DEN_RAT(opL);  bL = INTOBJ_INT( 1L );   /* b = <q>         */
        }
    }

    /* return the remainder                                                */
    return ModInt( ProdInt( NUM_RAT(opL), aL ), opR );
}


/****************************************************************************
**
*F  PowRat( <opL>, <opR> )  . . . . . .  raise a rational to an integer power
**
**  'PowRat' raises the rational <opL> to the  power  given  by  the  integer
**  <opR>.  The power is reduced.
*/
Obj             PowRat (
    Obj                 opL,
    Obj                 opR )
{
    Obj                 numP, denP;     /* numerator and denominator power */
    Obj                 pow;            /* power                           */

    CHECK_RAT(opL);

    /* if <opR> == 0 return 1                                              */
    if ( opR == INTOBJ_INT( 0L ) ) {
        pow = INTOBJ_INT( 1L );
    }

    /* if <opR> == 1 return <opL>                                          */
    else if ( opR == INTOBJ_INT( 1L ) ) {
        pow = opL;
    }

    /* if <opR> is positive raise numerator and denominator seperately    */
    else if ( (IS_INTOBJ(opR) && 0 < INT_INTOBJ(opR))
           || TNUM_OBJ(opR) == T_INTPOS ) {
        numP = PowInt( NUM_RAT(opL), opR );
        denP = PowInt( DEN_RAT(opL), opR );
        pow = NewBag( T_RAT, 2 * sizeof(Obj) );
        NUM_RAT(pow) = numP;
        DEN_RAT(pow) = denP;
        /* 'CHANGED_BAG' not needed, 'pow' is the youngest bag             */
    }

    /* if <opR> is negative and numerator is 1 just power the denominator  */
    else if ( NUM_RAT(opL) == INTOBJ_INT( 1L ) ) {
        pow = PowInt( DEN_RAT(opL), ProdInt( INTOBJ_INT(-1L), opR ) );
    }

    /* if <opR> is negative and numerator is -1 return (-1)^r * num(l)     */
    else if ( NUM_RAT(opL) == INTOBJ_INT( -1L ) ) {
        numP = PowInt( NUM_RAT(opL), ProdInt( INTOBJ_INT( -1L ), opR ) );
        denP = PowInt( DEN_RAT(opL), ProdInt( INTOBJ_INT( -1L ), opR ) );
        pow = ProdInt(numP, denP);
    }

    /* if <opR> is negative do both powers, take care of the sign          */
    else {
        numP = PowInt( DEN_RAT(opL), ProdInt( INTOBJ_INT( -1L ), opR ) );
        denP = PowInt( NUM_RAT(opL), ProdInt( INTOBJ_INT( -1L ), opR ) );
        pow  = NewBag( T_RAT, 2 * sizeof(Obj) );
        if ( (IS_INTOBJ(denP) && 0 < INT_INTOBJ(denP))
          || TNUM_OBJ(denP) == T_INTPOS ) {
            NUM_RAT(pow) = numP;
            DEN_RAT(pow) = denP;
        }
        else {
            NUM_RAT(pow) = ProdInt( INTOBJ_INT( -1L ), numP );
            DEN_RAT(pow) = ProdInt( INTOBJ_INT( -1L ), denP );
        }
        /* 'CHANGED_BAG' not needed, 'pow' is the youngest bag             */
    }

    /* return the result                                                   */
    CHECK_RAT(pow);
    return pow;
}


/****************************************************************************
**
*F  IsRatHandler(<self>,<val>)  . . . . . . . . . . . . is a value a rational
**
**  'IsRatHandler' implements the internal function 'IsRat'.
**
**  'IsRat( <val> )'
**
**  'IsRat' returns  'true' if  the  value <val> is  a  rational and  'false'
**  otherwise.
*/
Obj             IsRatFilt;

Obj             IsRatHandler (
    Obj                 self,
    Obj                 val )
{
    /* return 'true' if <val> is a rational and 'false' otherwise          */
    if ( TNUM_OBJ(val) == T_RAT    || IS_INTOBJ(val)
      || TNUM_OBJ(val) == T_INTPOS || TNUM_OBJ(val) == T_INTNEG ) {
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
*F  FuncNUMERATOR_RAT(<self>,<rat>)  . . . . . . . . . numerator of a rational
**
**  'FuncNUMERATOR_RAT' implements the internal function 'NumeratorRat'.
**
**  'NumeratorRat( <rat> )'
**
**  'NumeratorRat' returns the numerator of the rational <rat>.
*/
Obj             FuncNUMERATOR_RAT (
    Obj                 self,
    Obj                 rat )
{
    /* check the argument                                                   */
    while ( TNUM_OBJ(rat) != T_RAT    && !IS_INTOBJ(rat)
         && TNUM_OBJ(rat) != T_INTPOS && TNUM_OBJ(rat) != T_INTNEG ) {
        rat = ErrorReturnObj(
            "Numerator: <rat> must be a rational (not a %s)",
            (Int)TNAM_OBJ(rat), 0L,
            "you can replace <rat> via 'return <rat>;'" );
    }

    /* return the numerator                                                */
    if ( TNUM_OBJ(rat) == T_RAT ) {
        return NUM_RAT(rat);
    }
    else {
        return rat;
    }
}


/****************************************************************************
**
*F  FuncDENOMINATOR_RAT(<self>,<rat>)  . . . . . . . denominator of a rational
**
**  'FuncDENOMINATOR_RAT' implements the internal function 'DenominatorRat'.
**
**  'DenominatorRat( <rat> )'
**
**  'DenominatorRat' returns the denominator of the rational <rat>.
*/
Obj             FuncDENOMINATOR_RAT (
    Obj                 self,
    Obj                 rat )
{
    /* check the argument                                                  */
    while ( TNUM_OBJ(rat) != T_RAT    && !IS_INTOBJ(rat)
         && TNUM_OBJ(rat) != T_INTPOS && TNUM_OBJ(rat) != T_INTNEG ) {
        rat = ErrorReturnObj(
            "DenominatorRat: <rat> must be a rational (not a %s)",
            (Int)TNAM_OBJ(rat), 0L,
            "you can replace <rat> via 'return <rat>;'" );
    }

    /* return the denominator                                              */
    if ( TNUM_OBJ(rat) == T_RAT ) {
        return DEN_RAT(rat);
    }
    else {
        return INTOBJ_INT( 1L );
    }
}

/****************************************************************************
**
*F  SaveRat( <rat> )
**
*/

void SaveRat(Obj rat)
{
  SaveSubObj(NUM_RAT(rat));
  SaveSubObj(DEN_RAT(rat));
}

/****************************************************************************
**
*F  LoadRat( <rat> )
**
*/

void LoadRat(Obj rat)
{
  NUM_RAT(rat) = LoadSubObj();
  DEN_RAT(rat) = LoadSubObj();
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

    { "IS_RAT", "obj", &IsRatFilt,
      IsRatHandler, "src/rational.c:IS_RAT" },

    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(NUMERATOR_RAT, 1, "rat"),
    GVAR_FUNC(DENOMINATOR_RAT, 1, "rat"),
    GVAR_FUNC(ABS_RAT, 1, "rat"),
    GVAR_FUNC(SIGN_RAT, 1, "rat"),
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
    InfoBags[         T_RAT ].name = "rational";
    /* MarkTwoSubBags() is faster for Gasman, but MarkAllSubBags() is
     * more space-efficient for the Boehm GC and does not incur a
     * speed penalty.
     */
#ifndef BOEHM_GC
    InitMarkFuncBags( T_RAT, MarkTwoSubBags );
#else
    InitMarkFuncBags( T_RAT, MarkAllSubBags );
#endif

    /* install the type functions                                          */
    ImportGVarFromLibrary( "TYPE_RAT_POS", &TYPE_RAT_POS );
    ImportGVarFromLibrary( "TYPE_RAT_NEG", &TYPE_RAT_NEG );

    TypeObjFuncs[ T_RAT ] = TypeRat;

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* install a saving functions */
    SaveObjFuncs[ T_RAT ] = SaveRat;
    LoadObjFuncs[ T_RAT ] = LoadRat;

    /* install the printer                                                 */
    PrintObjFuncs[ T_RAT ] = PrintRat;

    /* install the comparisons                                             */
    EqFuncs  [ T_RAT    ][ T_RAT    ] = EqRat;

    LtFuncs  [ T_RAT    ][ T_RAT    ] = LtRat;
    LtFuncs  [ T_INT    ][ T_RAT    ] = LtRat;
    LtFuncs  [ T_INTPOS ][ T_RAT    ] = LtRat;
    LtFuncs  [ T_INTNEG ][ T_RAT    ] = LtRat;
    LtFuncs  [ T_RAT    ][ T_INT    ] = LtRat;
    LtFuncs  [ T_RAT    ][ T_INTPOS ] = LtRat;
    LtFuncs  [ T_RAT    ][ T_INTNEG ] = LtRat;

    /* install the arithmetic operations                                   */
    ZeroFuncs[ T_RAT    ] = ZeroRat;
    AInvFuncs[ T_RAT    ] = AInvRat;
    AInvMutFuncs[ T_RAT    ] = AInvRat;
    OneFuncs [ T_RAT    ] = OneRat;
    OneMutFuncs [ T_RAT    ] = OneRat;
    InvFuncs [ T_INT    ] = InvRat;
    InvFuncs [ T_INTPOS ] = InvRat;
    InvFuncs [ T_INTNEG ] = InvRat;
    InvFuncs [ T_RAT    ] = InvRat;
    InvMutFuncs [ T_INT    ] = InvRat;
    InvMutFuncs [ T_INTPOS ] = InvRat;
    InvMutFuncs [ T_INTNEG ] = InvRat;
    InvMutFuncs [ T_RAT    ] = InvRat;
    
    SumFuncs [ T_RAT    ][ T_RAT    ] = SumRat;
    SumFuncs [ T_INT    ][ T_RAT    ] = SumRat;
    SumFuncs [ T_INTPOS ][ T_RAT    ] = SumRat;
    SumFuncs [ T_INTNEG ][ T_RAT    ] = SumRat;
    SumFuncs [ T_RAT    ][ T_INT    ] = SumRat;
    SumFuncs [ T_RAT    ][ T_INTPOS ] = SumRat;
    SumFuncs [ T_RAT    ][ T_INTNEG ] = SumRat;

    DiffFuncs[ T_RAT    ][ T_RAT    ] = DiffRat;
    DiffFuncs[ T_INT    ][ T_RAT    ] = DiffRat;
    DiffFuncs[ T_INTPOS ][ T_RAT    ] = DiffRat;
    DiffFuncs[ T_INTNEG ][ T_RAT    ] = DiffRat;
    DiffFuncs[ T_RAT    ][ T_INT    ] = DiffRat;
    DiffFuncs[ T_RAT    ][ T_INTPOS ] = DiffRat;
    DiffFuncs[ T_RAT    ][ T_INTNEG ] = DiffRat;

    ProdFuncs[ T_RAT    ][ T_RAT    ] = ProdRat;
    ProdFuncs[ T_INT    ][ T_RAT    ] = ProdRat;
    ProdFuncs[ T_INTPOS ][ T_RAT    ] = ProdRat;
    ProdFuncs[ T_INTNEG ][ T_RAT    ] = ProdRat;
    ProdFuncs[ T_RAT    ][ T_INT    ] = ProdRat;
    ProdFuncs[ T_RAT    ][ T_INTPOS ] = ProdRat;
    ProdFuncs[ T_RAT    ][ T_INTNEG ] = ProdRat;

    QuoFuncs [ T_INT    ][ T_INT    ] = QuoRat;
    QuoFuncs [ T_INT    ][ T_INTPOS ] = QuoRat;
    QuoFuncs [ T_INT    ][ T_INTNEG ] = QuoRat;
    QuoFuncs [ T_INTPOS ][ T_INT    ] = QuoRat;
    QuoFuncs [ T_INTPOS ][ T_INTPOS ] = QuoRat;
    QuoFuncs [ T_INTPOS ][ T_INTNEG ] = QuoRat;
    QuoFuncs [ T_INTNEG ][ T_INT    ] = QuoRat;
    QuoFuncs [ T_INTNEG ][ T_INTPOS ] = QuoRat;
    QuoFuncs [ T_INTNEG ][ T_INTNEG ] = QuoRat;

    QuoFuncs [ T_RAT    ][ T_RAT    ] = QuoRat;
    QuoFuncs [ T_INT    ][ T_RAT    ] = QuoRat;
    QuoFuncs [ T_INTPOS ][ T_RAT    ] = QuoRat;
    QuoFuncs [ T_INTNEG ][ T_RAT    ] = QuoRat;
    QuoFuncs [ T_RAT    ][ T_INT    ] = QuoRat;
    QuoFuncs [ T_RAT    ][ T_INTPOS ] = QuoRat;
    QuoFuncs [ T_RAT    ][ T_INTNEG ] = QuoRat;

    ModFuncs [ T_RAT    ][ T_INT    ] = ModRat;
    ModFuncs [ T_RAT    ][ T_INTPOS ] = ModRat;
    ModFuncs [ T_RAT    ][ T_INTNEG ] = ModRat;

    PowFuncs [ T_RAT    ][ T_INT    ] = PowRat;
    PowFuncs [ T_RAT    ][ T_INTPOS ] = PowRat;
    PowFuncs [ T_RAT    ][ T_INTNEG ] = PowRat;

    MakeBagTypePublic(T_RAT);

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
    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoRat() . . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "rational",                         /* name                           */
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

StructInitInfo * InitInfoRat ( void )
{
    return &module;
}
