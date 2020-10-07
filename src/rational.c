/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
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
**  Effort  has been made to improve  efficiency by avoiding unnecessary gcd
**  computations.  Also if  possible this  package will compute  two gcds  of
**  smaller integers instead of one gcd of larger integers.
**
**  However no effort has  been made to write special  code for the case that
**  some of the  integers are small integers   (i.e., less than  2^28).  This
**  would reduce the overhead  introduced by the  calls to the functions like
**  'SumInt', 'ProdInt' or 'GcdInt'.
*/

#include "rational.h"

#include "ariths.h"
#include "bool.h"
#include "error.h"
#include "integer.h"
#include "io.h"
#include "modules.h"
#include "opers.h"
#include "saveload.h"


#if defined(DEBUG_RATIONALS)
#define CHECK_RAT(rat)                                                       \
    if (TNUM_OBJ(rat) == T_RAT &&                                            \
        (!LtInt(INTOBJ_INT(1), DEN_RAT(rat)) ||                              \
         GcdInt(NUM_RAT(rat), DEN_RAT(rat)) != INTOBJ_INT(1)))               \
    ErrorQuit("bad rational", 0, 0)
#else
#define CHECK_RAT(rat)
#endif


#define RequireRational(funcname, op)                                        \
    RequireArgumentCondition(funcname, op,                                   \
                             TNUM_OBJ(op) == T_RAT || IS_INT(op),            \
                             "must be a rational")

static inline Obj MakeRat(Obj num, Obj den)
{
    Obj rat = NewBag(T_RAT, 2 * sizeof(Obj));
    SET_NUM_RAT(rat, num);
    SET_DEN_RAT(rat, den);
    return rat;
}


/****************************************************************************
**
*F  TypeRat( <rat> )  . . . . . . . . . . . . . . . . . .  type of a rational
**
**  'TypeRat' returns the type of the rational <rat>.
**
**  'TypeRat' is the function in 'TypeObjFuncs' for rationals.
*/
static Obj TYPE_RAT_POS;
static Obj TYPE_RAT_NEG;

static Obj TypeRat(Obj rat)
{
    Obj                 num;
    CHECK_RAT(rat);
    num = NUM_RAT(rat);
    return IS_NEG_INT(num) ? TYPE_RAT_NEG : TYPE_RAT_POS;
}


/****************************************************************************
**
*F  PrintRat( <rat> ) . . . . . . . . . . . . . . . . . . .  print a rational
**
**  'PrintRat' prints a rational <rat> in the form
**
**      <numerator> / <denominator>
*/
static void PrintRat(Obj rat)
{
    Pr("%>", 0, 0);
    PrintObj( NUM_RAT(rat) );
    Pr("%</%>", 0, 0);
    PrintObj( DEN_RAT(rat) );
    Pr("%<", 0, 0);
}


/****************************************************************************
**
*F  EqRat( <opL>, <opR> ) . . . . . . . . . . . . . . test if <ratL> = <ratR>
**
**  'EqRat' returns 'true' if the two rationals <ratL> and <ratR>  are  equal
**  and 'false' otherwise.
*/
static Int EqRat(Obj opL, Obj opR)
{
    Obj                 numL, denL;     /* numerator and denominator left  */
    Obj                 numR, denR;     /* numerator and denominator right */

    CHECK_RAT(opL);
    CHECK_RAT(opR);

    /* get numerator and denominator of the operands                       */
    numL = NUM_RAT(opL);
    denL = DEN_RAT(opL);
    numR = NUM_RAT(opR);
    denR = DEN_RAT(opR);

    /* compare the numerators                                              */
    if ( ! EQ( numL, numR ) ) {
        return 0;
    }

    /* compare the denominators                                            */
    if ( ! EQ( denL, denR ) ) {
        return 0;
    }

    /* no differences found, they must be equal                            */
    return 1;
}


/****************************************************************************
**
*F  LtRat( <opL>, <opR> ) . . . . . . . . . . . . . . test if <ratL> < <ratR>
**
**  'LtRat' returns 'true'  if  the  rational  <ratL>  is  smaller  than  the
**  rational <ratR> and 'false' otherwise.  Either operand may be an integer.
*/
static Int LtRat(Obj opL, Obj opR)
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
        denL = INTOBJ_INT(1);
    }
    if ( TNUM_OBJ(opR) == T_RAT ) {
        numR = NUM_RAT(opR);
        denR = DEN_RAT(opR);
    }
    else {
        numR = opR;
        denR = INTOBJ_INT(1);
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
static Obj SumRat(Obj opL, Obj opR)
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
        denL = INTOBJ_INT(1);
    }
    if ( TNUM_OBJ(opR) == T_RAT ) {
        numR = NUM_RAT(opR);
        denR = DEN_RAT(opR);
    }
    else {
        numR = opR;
        denR = INTOBJ_INT(1);
    }

    /* find the gcd of the denominators                                    */
    gcd1 = GcdInt( denL, denR );

    /* nothing can cancel if the gcd is 1                                  */
    if (gcd1 == INTOBJ_INT(1)) {
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
    if (denS != INTOBJ_INT(1)) {
        sum = MakeRat(numS, denS);
    }
    else {
        sum = numS;
    }

    CHECK_RAT(sum);
    return sum;
}


/****************************************************************************
**
*F  ZeroRat(<op>) . . . . . . . . . . . . . . . . . . . .  zero of a rational
*/
static Obj ZeroRat(Obj op)
{
    return INTOBJ_INT(0);
}


/****************************************************************************
**
*F  AInvRat(<op>) . . . . . . . . . . . . . .  additive inverse of a rational
*/
static Obj AInvRat(Obj op)
{
    Obj                 res;
    Obj                 tmp;
    CHECK_RAT(op);
    tmp = AInvInt( NUM_RAT(op) );
    res = MakeRat(tmp, DEN_RAT(op));
    CHECK_RAT(res);
    return res;
}


/****************************************************************************
**
*F  AbsRat(<op>) . . . . . . . . . . . . . . . . absolute value of a rational
*/
static Obj AbsRat(Obj op)
{
    Obj res;
    Obj tmp;
    CHECK_RAT(op);
    tmp = AbsInt( NUM_RAT(op) );
    if ( tmp == NUM_RAT(op))
        return op;

    res = MakeRat(tmp, DEN_RAT(op));
    CHECK_RAT(res);
    return res;

}

static Obj FuncABS_RAT(Obj self, Obj op)
{
    RequireRational(SELF_NAME, op);
    return (TNUM_OBJ(op) == T_RAT) ? AbsRat(op) : AbsInt(op);
}

/****************************************************************************
**
*F  SignRat(<op>) . . . . . . . . . . . . . . . . . . . .  sign of a rational
*/
static Obj SignRat(Obj op)
{
    CHECK_RAT(op);
    return SignInt( NUM_RAT(op) );
}

static Obj FuncSIGN_RAT(Obj self, Obj op)
{
    RequireRational(SELF_NAME, op);
    return (TNUM_OBJ(op) == T_RAT) ? SignRat(op) : SignInt(op);
}


/****************************************************************************
**
*F  DiffRat( <opL>, <opR> ) . . . . . . . . . . . difference of two rationals
**
**  'DiffRat' returns the  difference  of  two  rationals  <opL>  and  <opR>.
**  Either operand may also be an integer.  The difference is reduced.
*/
static Obj DiffRat(Obj opL, Obj opR)
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
        denL = INTOBJ_INT(1);
    }
    if ( TNUM_OBJ(opR) == T_RAT ) {
        numR = NUM_RAT(opR);
        denR = DEN_RAT(opR);
    }
    else {
        numR = opR;
        denR = INTOBJ_INT(1);
    }

    /* find the gcd of the denominators                                    */
    gcd1 = GcdInt( denL, denR );

    /* nothing can cancel if the gcd is 1                                  */
    if (gcd1 == INTOBJ_INT(1)) {
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
    if (denD != INTOBJ_INT(1)) {
        dif = MakeRat(numD, denD);
    }
    else {
        dif = numD;
    }

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
static Obj ProdRat(Obj opL, Obj opR)
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
        denL = INTOBJ_INT(1);
    }
    if ( TNUM_OBJ(opR) == T_RAT ) {
        numR = NUM_RAT(opR);
        denR = DEN_RAT(opR);
    }
    else {
        numR = opR;
        denR = INTOBJ_INT(1);
    }

    /* find the gcds                                                       */
    gcd1 = GcdInt( numL, denR );
    gcd2 = GcdInt( numR, denL );

    /* nothing can cancel if the gcds are 1                                */
    if (gcd1 == INTOBJ_INT(1) && gcd2 == INTOBJ_INT(1)) {
        numP = ProdInt( numL, numR );
        denP = ProdInt( denL, denR );
    }

    /* a little bit more difficult otherwise                               */
    else {
        numP = ProdInt( QuoInt( numL, gcd1 ), QuoInt( numR, gcd2 ) );
        denP = ProdInt( QuoInt( denL, gcd2 ), QuoInt( denR, gcd1 ) );
    }

    /* make the fraction or, if possible, the integer                      */
    if (denP != INTOBJ_INT(1)) {
        prd = MakeRat(numP, denP);
    }
    else {
        prd = numP;
    }

    CHECK_RAT(prd);
    return prd;
}


/****************************************************************************
**
*F  OneRat(<op>)  . . . . . . . . . . . . . . . . . . . . . one of a rational
*/
static Obj OneRat(Obj op)
{
    return INTOBJ_INT(1);
}


/****************************************************************************
**
*F  InvRat(<op>)  . . . . . . . . . . . . . . . . . . . inverse of a rational
*/
static Obj QuoRat(Obj opL, Obj opR);

static Obj InvRat(Obj op)
{
  Obj res;
    CHECK_RAT(op);
    if (op == INTOBJ_INT(0))
      return Fail;
    res = QuoRat(INTOBJ_INT(1), op);
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
static Obj QuoRat(Obj opL, Obj opR)
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
        denL = INTOBJ_INT(1);
    }
    if ( TNUM_OBJ(opR) == T_RAT ) {
        numR = NUM_RAT(opR);
        denR = DEN_RAT(opR);
    }
    else {
        numR = opR;
        denR = INTOBJ_INT(1);
    }

    /* division by zero is an error                                        */
    if (numR == INTOBJ_INT(0)) {
        ErrorMayQuit("Rational operations: <divisor> must not be zero", 0, 0);
    }

    /* we multiply the left numerator with the right denominator           */
    /* so the right denominator should carry the sign of the right operand */
    if ( IS_NEG_INT(numR) ) {
        numR = AInvInt( numR );
        denR = AInvInt( denR );
    }

    /* find the gcds                                                       */
    gcd1 = GcdInt( numL, numR );
    gcd2 = GcdInt( denR, denL );

    /* nothing can cancel if the gcds are 1                                */
    if (gcd1 == INTOBJ_INT(1) && gcd2 == INTOBJ_INT(1)) {
        numQ = ProdInt( numL, denR );
        denQ = ProdInt( denL, numR );
    }

    /* a little bit more difficult otherwise                               */
    else {
        numQ = ProdInt( QuoInt( numL, gcd1 ), QuoInt( denR, gcd2 ) );
        denQ = ProdInt( QuoInt( denL, gcd2 ), QuoInt( numR, gcd1 ) );
    }

    /* make the fraction or, if possible, the integer                      */
    if (denQ != INTOBJ_INT(1)) {
        quo = MakeRat(numQ, denQ);
    }
    else {
        quo = numQ;
    }

    CHECK_RAT(quo);
    return quo;
}


/****************************************************************************
**
*F  ModRat( <opL>, <n> )  . . . . . . . . remainder of fraction mod integer
**
**  'ModRat' returns the remainder  of the fraction  <opL> modulo the integer
**  <n>.  The remainder is always an integer.
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
static Obj ModRat(Obj opL, Obj n)
{
    // invert the denominator
    Obj d = InverseModInt( DEN_RAT(opL), n );

    // check whether the denominator of <opL> really was invertible mod <n> */
    if ( d == Fail ) {
        ErrorMayQuit(
                  "ModRat: for <r>/<s> mod <n>, <s>/gcd(<r>,<s>) and <n> must be coprime",
                  0, 0 );
    }

    // return the remainder
    return ModInt( ProdInt( NUM_RAT(opL), d ), n );
}


/****************************************************************************
**
*F  PowRat( <opL>, <opR> )  . . . . . .  raise a rational to an integer power
**
**  'PowRat' raises the rational <opL> to the  power  given  by  the  integer
**  <opR>.  The power is reduced.
*/
static Obj PowRat(Obj opL, Obj opR)
{
    Obj                 numP, denP;     /* numerator and denominator power */
    Obj                 pow;            /* power                           */

    CHECK_RAT(opL);

    /* if <opR> == 0 return 1                                              */
    if (opR == INTOBJ_INT(0)) {
        pow = INTOBJ_INT(1);
    }

    /* if <opR> == 1 return <opL>                                          */
    else if (opR == INTOBJ_INT(1)) {
        pow = opL;
    }

    /* if <opR> is positive raise numerator and denominator separately    */
    else if ( IS_POS_INT(opR) ) {
        numP = PowInt( NUM_RAT(opL), opR );
        denP = PowInt( DEN_RAT(opL), opR );
        pow = MakeRat(numP, denP);
    }

    /* if <opR> is negative and numerator is 1 just power the denominator  */
    else if (NUM_RAT(opL) == INTOBJ_INT(1)) {
        pow = PowInt( DEN_RAT(opL), AInvInt( opR ) );
    }

    /* if <opR> is negative and numerator is -1 return (-1)^r * num(l)     */
    else if (NUM_RAT(opL) == INTOBJ_INT(-1)) {
        numP = PowInt( NUM_RAT(opL), AInvInt( opR ) );
        denP = PowInt( DEN_RAT(opL), AInvInt( opR ) );
        pow = ProdInt(numP, denP);
    }

    /* if <opR> is negative do both powers, take care of the sign          */
    else {
        numP = PowInt( DEN_RAT(opL), AInvInt( opR ) );
        denP = PowInt( NUM_RAT(opL), AInvInt( opR ) );
        if (IS_NEG_INT(denP)) {
            numP = AInvInt(numP);
            denP = AInvInt(denP);
        }
        pow = MakeRat(numP, denP);
    }

    CHECK_RAT(pow);
    return pow;
}


/****************************************************************************
**
*F  FiltIS_RAT(<self>,<val>) . . . . . . . . . . . . .  is a value a rational
**
**  'FiltIS_RAT' implements the internal function 'IsRat'.
**
**  'IsRat( <val> )'
**
**  'IsRat' returns  'true' if  the  value <val> is  a  rational and  'false'
**  otherwise.
*/
static Obj IsRatFilt;

static Obj FiltIS_RAT(Obj self, Obj val)
{
    /* return 'true' if <val> is a rational and 'false' otherwise          */
    if ( TNUM_OBJ(val) == T_RAT || IS_INT(val)  ) {
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
static Obj FuncNUMERATOR_RAT(Obj self, Obj rat)
{
    RequireRational(SELF_NAME, rat);

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
static Obj FuncDENOMINATOR_RAT(Obj self, Obj rat)
{
    RequireRational(SELF_NAME, rat);

    if ( TNUM_OBJ(rat) == T_RAT ) {
        return DEN_RAT(rat);
    }
    else {
        return INTOBJ_INT(1);
    }
}

/****************************************************************************
**
*F  SaveRat( <rat> )
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SaveRat(Obj rat)
{
  SaveSubObj(NUM_RAT(rat));
  SaveSubObj(DEN_RAT(rat));
}
#endif


/****************************************************************************
**
*F  LoadRat( <rat> )
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadRat(Obj rat)
{
  SET_NUM_RAT(rat, LoadSubObj());
  SET_DEN_RAT(rat, LoadSubObj());
}
#endif


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IS_RAT, "obj", &IsRatFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs[] = {

    GVAR_FUNC_1ARGS(NUMERATOR_RAT, rat),
    GVAR_FUNC_1ARGS(DENOMINATOR_RAT, rat),
    GVAR_FUNC_1ARGS(ABS_RAT, op),
    GVAR_FUNC_1ARGS(SIGN_RAT, op),
    { 0, 0, 0, 0, 0 }

};
/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_RAT, "rational" },
  { -1,    ""         }
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
    /* MarkTwoSubBags() is faster for Gasman, but MarkAllSubBags() is
     * more space-efficient for the Boehm GC and does not incur a
     * speed penalty.
     */
#ifdef USE_GASMAN
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

#ifdef GAP_ENABLE_SAVELOAD
    /* install a saving functions */
    SaveObjFuncs[ T_RAT ] = SaveRat;
    LoadObjFuncs[ T_RAT ] = LoadRat;
#endif

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

#ifdef HPCGAP
    MakeBagTypePublic(T_RAT);
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
    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );

    return 0;
}


/****************************************************************************
**
*F  InitInfoRat() . . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "rational",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoRat ( void )
{
    return &module;
}
