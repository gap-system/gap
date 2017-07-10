
/****************************************************************************
**
*W  vecffe.c                    GAP source                      Werner Nickel
**
**
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
*/
#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/ariths.h>                 /* basic arithmetic */
#include <src/lists.h>                  /* generic lists */

#include <src/bool.h>                   /* booleans */

#include <src/gmpints.h>                /* integers */
#include <src/finfield.h>               /* finite fields */

#include <src/gvars.h>                  /* global variables */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/listoper.h>               /* operations for generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */

#include <src/vecffe.h>                 /* functions for fin field vectors */

#include <src/range.h>                  /* ranges */

#include <src/calls.h>                  /* needed for opers.h */
#include <src/opers.h>                  /* for TRY_NEXT_METHOD */

#include <src/code.h>                   /* coder */
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/tls.h>                /* thread-local storage */

#include <assert.h>


/****************************************************************************
**
*F  SumFFEVecFFE(<elmL>,<vecR>) . . . .  sum of a finite field elm and a vector
**
**  'SumFFEVecFFE' returns the sum of the fin field elm <elmL> and the vector
**  <vecR>.  The sum is a  list, where each element is  the sum of <elmL> and
**  the corresponding element of <vecR>.
**
**  'SumFFEVecFFE' is an improved version  of  'SumSclList', which  does  not
**  call 'SUM'.
*/
Obj             SumFFEVecFFE (
    Obj                 elmL,
    Obj                 vecR )
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    FFV                 valS;           /* the value of a sum              */
    Obj *               ptrR;           /* pointer into the right operand  */
    FFV                 valR;           /* the value of an element in vecR */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    FF *                succ;           /* successor table                 */
    FFV                 valL;           /* the value of elmL               */

    /* get the field and check that elmL and vecR have the same field      */
    fld = FLD_FFE(ELM_PLIST(vecR, 1));
    if (FLD_FFE(elmL) != fld) {
        /* check the characteristic                                          */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmL)))
            return SumSclList(elmL, vecR);

        elmL = ErrorReturnObj(
            "<elm>+<vec>: <elm> and <vec> must belong to the same finite field",
            0L, 0L, "you can replace <elm> via 'return <elm>;'");
        return SUM(elmL, vecR);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecS = NEW_PLIST(IS_MUTABLE_OBJ(vecR) ?
                T_PLIST_FFE : T_PLIST_FFE + IMMUTABLE, len);
    SET_LEN_PLIST(vecS, len);

    /* to add we need the successor table                                  */
    succ = SUCC_FF(fld);

    /* loop over the elements and add                                      */
    valL = VAL_FFE(elmL);
    ptrR = ADDR_OBJ(vecR);
    ptrS = ADDR_OBJ(vecS);
    for (i = 1; i <= len; i++) {
        valR = VAL_FFE(ptrR[i]);
        valS = SUM_FFV(valL, valR, succ);
        ptrS[i] = NEW_FFE(fld, valS);
    }

    /* return the result                                                   */
    return vecS;
}


/****************************************************************************
**
*F  SumVecFFEFFE(<vecL>,<elmR>) . . . . . sum of a vector and a fin field elm
**
**  'SumVecFFEFFE' returns  the sum of   the  vector <vecL> and  the  finite
**  field element <elmR>.  The sum is a  list, where each element  is the sum
**  of <elmR> and the corresponding element of <vecL>.
**
**  'SumVecFFEFFE' is an improved version  of  'SumListScl', which  does  not
**  call 'SUM'.
*/
Obj             SumVecFFEFFE (
    Obj                 vecL,
    Obj                 elmR )
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    Obj *               ptrL;           /* pointer into the left operand   */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    FF *                succ;           /* successor table                 */
    FFV                 valR;           /* the value of elmR               */
    FFV                 valL;           /* the value of an element in vecL */
    FFV                 valS;           /* the value of a sum              */

    /* get the field and check that vecL and elmR have the same field      */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(elmR) != fld) {
        /* check the characteristic                                          */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmR)))
            return SumListScl(vecL, elmR);

        elmR = ErrorReturnObj(
            "<vec>+<elm>: <elm> and <vec> must belong to the same finite field",
            0L, 0L, "you can replace <elm> via 'return <elm>;'");
        return SUM(vecL, elmR);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecS = NEW_PLIST(IS_MUTABLE_OBJ(vecL) ?
                T_PLIST_FFE : T_PLIST_FFE + IMMUTABLE, len);
    SET_LEN_PLIST(vecS, len);

    /* to add we need the successor table                                  */
    succ = SUCC_FF(fld);

    /* loop over the elements and add                                      */
    valR = VAL_FFE(elmR);
    ptrL = ADDR_OBJ(vecL);
    ptrS = ADDR_OBJ(vecS);
    for (i = 1; i <= len; i++) {
        valL = VAL_FFE(ptrL[i]);
        valS = SUM_FFV(valL, valR, succ);
        ptrS[i] = NEW_FFE(fld, valS);
    }

    /* return the result                                                   */
    return vecS;
}

/****************************************************************************
**
*F  SumVecFFEVecFFE(<vecL>,<vecR>)  . . . . . . . . . . .  sum of two vectors
**
**  'SumVecFFEVecFFE' returns the sum  of the two  vectors <vecL> and <vecR>.
**  The sum is a new list, where each element is the sum of the corresponding
**  elements of <vecL> and <vecR>.
**
**  'SumVecFFEVecFFE' is an improved version of 'SumListList', which does not
**  call 'SUM'.
*/
Obj             SumVecFFEVecFFE (
    Obj                 vecL,
    Obj                 vecR )
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    FFV                 valS;           /* one element of sum list         */
    Obj *               ptrL;           /* pointer into the left operand   */
    FFV                 valL;           /* one element of left operand     */
    Obj *               ptrR;           /* pointer into the right operand  */
    FFV                 valR;           /* one element of right operand    */
    UInt                lenL, lenR, len; /* length                          */
    UInt                lenmin;
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    FF *                succ;           /* successor table                 */

    /* check the lengths                                                   */
    lenL = LEN_PLIST(vecL);
    lenR = LEN_PLIST(vecR);
    if (lenR > lenL) {
        len = lenR;
        lenmin = lenL;
    } else {
        len = lenL;
        lenmin = lenR;
    }

    /* check the fields                                                    */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(ELM_PLIST(vecR, 1)) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(ELM_PLIST(vecR, 1))))
            return SumListList(vecL, vecR);

        vecR = ErrorReturnObj(
            "Vector +: vectors have different fields",
            0L, 0L, "you can replace vector <right> via 'return <right>;'");
        return SUM(vecL, vecR);
    }

    /* make the result list                                                */
    vecS = NEW_PLIST((IS_MUTABLE_OBJ(vecL) || IS_MUTABLE_OBJ(vecR)) ?
                T_PLIST_FFE : T_PLIST_FFE + IMMUTABLE, len);
    SET_LEN_PLIST(vecS, len);

    /* to add we need the successor table                                  */
    succ = SUCC_FF(fld);

    /* loop over the elements and add                                      */
    ptrL = ADDR_OBJ(vecL);
    ptrR = ADDR_OBJ(vecR);
    ptrS = ADDR_OBJ(vecS);
    for (i = 1; i <= lenmin; i++) {
        valL = VAL_FFE(ptrL[i]);
        valR = VAL_FFE(ptrR[i]);
        valS = SUM_FFV(valL, valR, succ);
        ptrS[i] = NEW_FFE(fld, valS);
    }
    if (lenL < lenR)
        for (; i <= len; i++)
            ptrS[i] = ptrR[i];
    else
        for (; i <= len; i++)
            ptrS[i] = ptrL[i];

    /* return the result                                                   */
    return vecS;
}

/****************************************************************************
**
*F  DiffFFEVecFFE(<elmL>,<vecR>)   difference of a fin field elm and a vector
**
**  'DiffFFEVecFFE' returns  the difference  of  the finite field element
**  <elmL> and  the vector <vecR>.   The difference  is  a list,  where  each
**  element is the difference of <elmL> and the corresponding element of
**  <vecR>. 
**
**  'DiffFFEVecFFE'  is an improved  version of 'DiffSclList', which does not
**  call 'DIFF'.
*/
Obj             DiffFFEVecFFE (
    Obj                 elmL,
    Obj                 vecR )
{
    Obj                 vecD;           /* handle of the difference        */
    Obj *               ptrD;           /* pointer into the difference     */
    Obj *               ptrR;           /* pointer into the right operand  */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    FF *                succ;           /* successor table                 */
    FFV                 valR;           /* the value of elmL               */
    FFV                 valL;           /* the value of an element in vecR */
    FFV                 valD;           /* the value of a difference       */

    /* check the fields                                                    */
    fld = FLD_FFE(ELM_PLIST(vecR, 1));
    if (FLD_FFE(elmL) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmL)))
            return DiffSclList(elmL, vecR);

        elmL = ErrorReturnObj(
            "<elm>-<vec>: <elm> and <vec> must belong to the same finite field",
            0L, 0L, "you can replace <elm> via 'return <elm>;'");
        return DIFF(elmL, vecR);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecD = NEW_PLIST(IS_MUTABLE_OBJ(vecR) ?
                T_PLIST_FFE : T_PLIST_FFE + IMMUTABLE, len);
    SET_LEN_PLIST(vecD, len);

    /* to subtract we need the successor table                             */
    succ = SUCC_FF(fld);

    /* loop over the elements and subtract                                 */
    valL = VAL_FFE(elmL);
    ptrR = ADDR_OBJ(vecR);
    ptrD = ADDR_OBJ(vecD);
    for (i = 1; i <= len; i++) {
        valR = VAL_FFE(ptrR[i]);
        valR = NEG_FFV(valR, succ);
        valD = SUM_FFV(valL, valR, succ);
        ptrD[i] = NEW_FFE(fld, valD);
    }
    /* return the result                                                   */
    return vecD;
}


/****************************************************************************
**
*F  DiffVecFFEFFE(<vecL>,<elmR>)   difference of a vector and a fin field elm
**
**  'DiffVecFFEFFE' returns   the  difference of the  vector  <vecL>  and the
**  finite field element <elmR>.  The difference   is a list,   where each
**  element  is the difference of <elmR> and the corresponding element of
**  <vecL>. 
**
**  'DiffVecFFEFFE' is an improved  version of 'DiffListScl', which  does not
**  call 'DIFF'.
*/
Obj             DiffVecFFEFFE (
    Obj                 vecL,
    Obj                 elmR )
{
    Obj                 vecD;           /* handle of the difference        */
    Obj *               ptrD;           /* pointer into the difference     */
    FFV                 valD;           /* the value of a difference       */
    Obj *               ptrL;           /* pointer into the left operand   */
    FFV                 valL;           /* the value of an element in vecL */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    FF *                succ;           /* successor table                 */
    FFV                 valR;           /* the value of elmR               */

    /* get the field and check that vecL and elmR have the same field      */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(elmR) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmR)))
            return DiffListScl(vecL, elmR);

        elmR = ErrorReturnObj(
            "<vec>-<elm>: <elm> and <vec> must belong to the same finite field",
            0L, 0L, "you can replace <elm> via 'return <elm>;'");
        return DIFF(vecL, elmR);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecD = NEW_PLIST(IS_MUTABLE_OBJ(vecL) ?
                T_PLIST_FFE : T_PLIST_FFE + IMMUTABLE, len);
    SET_LEN_PLIST(vecD, len);

    /* to subtract we need the successor table                             */
    succ = SUCC_FF(fld);

    /* loop over the elements and subtract                                 */
    valR = VAL_FFE(elmR);
    valR = NEG_FFV(valR, succ);
    ptrL = ADDR_OBJ(vecL);
    ptrD = ADDR_OBJ(vecD);
    for (i = 1; i <= len; i++) {
        valL = VAL_FFE(ptrL[i]);
        valD = SUM_FFV(valL, valR, succ);
        ptrD[i] = NEW_FFE(fld, valD);
    }

    /* return the result                                                   */
    return vecD;
}


/****************************************************************************
**
*F  DiffVecFFEVecFFE(<vecL>,<vecR>) . . . . . . . . difference of two vectors
**
**  'DiffVecFFEVecFFE'  returns the difference of the  two vectors <vecL> and
**  <vecR>.   The  difference is   a new   list, where  each  element  is the
**  difference of the corresponding elements of <vecL> and <vecR>.
**
**  'DiffVecFFEVecFFE' is an improved  version of  'DiffListList', which does
**  not call 'DIFF'.
*/
Obj             DiffVecFFEVecFFE (
    Obj                 vecL,
    Obj                 vecR )
{
    Obj                 vecD;           /* handle of the difference        */
    Obj *               ptrD;           /* pointer into the difference     */
    FFV                 valD;           /* one element of difference list  */
    Obj *               ptrL;           /* pointer into the left operand   */
    FFV                 valL;           /* one element of left operand     */
    Obj *               ptrR;           /* pointer into the right operand  */
    FFV                 valR;           /* one element of right operand    */
    UInt                len, lenL, lenR; /* length                          */
    UInt                lenmin;
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    FF *                succ;           /* successor table                 */

    /* check the lengths                                                   */
    lenL = LEN_PLIST(vecL);
    lenR = LEN_PLIST(vecR);
    if (lenR > lenL) {
        len = lenR;
        lenmin = lenL;
    } else {
        len = lenL;
        lenmin = lenR;
    }

    /* check the fields                                                    */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(ELM_PLIST(vecR, 1)) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(ELM_PLIST(vecR, 1))))
            return DiffListList(vecL, vecR);

        vecR = ErrorReturnObj(
            "Vector -: vectors have different fields",
            0L, 0L, "you can replace vector <right> via 'return <right>;'");
        return DIFF(vecL, vecR);
    }

    /* make the result list                                                */
    vecD = NEW_PLIST((IS_MUTABLE_OBJ(vecL) || IS_MUTABLE_OBJ(vecR)) ?
                T_PLIST_FFE : T_PLIST_FFE + IMMUTABLE, len);
    SET_LEN_PLIST(vecD, len);

    /* to subtract we need the successor table                             */
    succ = SUCC_FF(fld);

    /* loop over the elements and subtract                                 */
    ptrL = ADDR_OBJ(vecL);
    ptrR = ADDR_OBJ(vecR);
    ptrD = ADDR_OBJ(vecD);
    for (i = 1; i <= lenmin; i++) {
        valL = VAL_FFE(ptrL[i]);
        valR = VAL_FFE(ptrR[i]);
        valR = NEG_FFV(valR, succ);
        valD = SUM_FFV(valL, valR, succ);
        ptrD[i] = NEW_FFE(fld, valD);
    }

    if (lenL < lenR)
        for (; i <= len; i++) {
            valR = VAL_FFE(ptrR[i]);
            valD = NEG_FFV(valR, succ);
            ptrD[i] = NEW_FFE(fld, valD);
        }
    else
        for (; i <= len; i++)
            ptrD[i] = ptrL[i];

    /* return the result                                                   */
    return vecD;
}


/****************************************************************************
**
*F  ProdFFEVecFFE(<elmL>,<vecR>)  . . product of a fin field elm and a vector
**
**  'ProdFFEVecFFE' returns the product of the finite field element  <elmL>
**  and the vector <vecR>.  The product is  the list, where  each element is
**  the product  of <elmL> and the corresponding entry of <vecR>.
**
**  'ProdFFEVecFFE'  is an  improved version of 'ProdSclList', which does not
**  call 'PROD'.
*/
Obj             ProdFFEVecFFE (
    Obj                 elmL,
    Obj                 vecR )
{
    Obj                 vecP;           /* handle of the product           */
    Obj *               ptrP;           /* pointer into the product        */
    FFV                 valP;           /* the value of a product          */
    Obj *               ptrR;           /* pointer into the right operand  */
    FFV                 valR;           /* the value of an element in vecR */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    FF *                succ;           /* successor table                 */
    FFV                 valL;           /* the value of elmL               */

    /* get the field and check that elmL and vecR have the same field      */
    fld = FLD_FFE(ELM_PLIST(vecR, 1));
    if (FLD_FFE(elmL) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmL)))
            return ProdSclList(elmL, vecR);

        elmL = ErrorReturnObj(
            "<elm>*<vec>: <elm> and <vec> must belong to the same finite field",
            0L, 0L, "you can replace <elm> via 'return <elm>;'");
        return PROD(elmL, vecR);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecP = NEW_PLIST(IS_MUTABLE_OBJ(vecR) ?
                T_PLIST_FFE : T_PLIST_FFE + IMMUTABLE, len);
    SET_LEN_PLIST(vecP, len);

    /* to multiply we need the successor table                             */
    succ = SUCC_FF(fld);

    /* loop over the elements and multiply                                 */
    valL = VAL_FFE(elmL);
    ptrR = ADDR_OBJ(vecR);
    ptrP = ADDR_OBJ(vecP);
    for (i = 1; i <= len; i++) {
        valR = VAL_FFE(ptrR[i]);
        valP = PROD_FFV(valL, valR, succ);
        ptrP[i] = NEW_FFE(fld, valP);
    }

    /* return the result                                                   */
    return vecP;
}

/****************************************************************************
**
*F  ProdVecFFEFFE(<vecL>,<elmR>)  .  product of a vector and a fin field elm
**
**  'ProdVecFFEFFE' returns the product of the finite field element  <elmR>
**  and the vector <vecL>.  The  product is the  list, where each element  is
**  the product of <elmR> and the corresponding element of <vecL>.
**
**  'ProdVecFFEFFE'  is an  improved version of 'ProdSclList', which does not
**  call 'PROD'.
*/
Obj             ProdVecFFEFFE (
    Obj                 vecL,
    Obj                 elmR )
{
    Obj                 vecP;           /* handle of the product           */
    Obj *               ptrP;           /* pointer into the product        */
    FFV                 valP;           /* the value of a product          */
    Obj *               ptrL;           /* pointer into the left operand   */
    FFV                 valL;           /* the value of an element in vecL */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    FF *                succ;           /* successor table                 */
    FFV                 valR;           /* the value of elmR               */

    /* get the field and check that vecL and elmR have the same field      */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(elmR) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmR)))
            return ProdListScl(vecL, elmR);

        elmR = ErrorReturnObj(
            "<vec>*<elm>: <elm> and <vec> must belong to the same finite field",
            0L, 0L, "you can replace <elm> via 'return <elm>;'");
        return PROD(vecL, elmR);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecP = NEW_PLIST(IS_MUTABLE_OBJ(vecL) ?
                    T_PLIST_FFE : T_PLIST_FFE + IMMUTABLE, len);
    SET_LEN_PLIST(vecP, len);

    /* to multiply we need the successor table                             */
    succ = SUCC_FF(fld);

    /* loop over the elements and multiply                                 */
    valR = VAL_FFE(elmR);
    ptrL = ADDR_OBJ(vecL);
    ptrP = ADDR_OBJ(vecP);
    for (i = 1; i <= len; i++) {
        valL = VAL_FFE(ptrL[i]);
        valP = PROD_FFV(valL, valR, succ);
        ptrP[i] = NEW_FFE(fld, valP);
    }

    /* return the result                                                   */
    return vecP;
}


/****************************************************************************
**
*F  ProdVecFFEVecFFE(<vecL>,<vecR>) . . . . . . . . .  product of two vectors
**
**  'ProdVecFFEVecFFE'  returns the product  of   the two vectors <vecL>  and
**  <vecR>.  The  product  is the  sum of the   products of the corresponding
**  elements of the two lists.
**
**  'ProdVecFFEVecFFE' is an improved version  of 'ProdListList',  which does
**  not call 'PROD'.
*/
Obj             ProdVecFFEVecFFE (
    Obj                 vecL,
    Obj                 vecR )
{
    FFV                 valP;           /* one product                     */
    FFV                 valS;           /* sum of the products             */
    Obj *               ptrL;           /* pointer into the left operand   */
    FFV                 valL;           /* one element of left operand     */
    Obj *               ptrR;           /* pointer into the right operand  */
    FFV                 valR;           /* one element of right operand    */
    UInt                lenL, lenR, len; /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    FF *                succ;           /* successor table                 */

    /* check the lengths                                                   */
    lenL = LEN_PLIST(vecL);
    lenR = LEN_PLIST(vecR);
    len = (lenL < lenR) ? lenL : lenR;

    /* check the fields                                                    */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(ELM_PLIST(vecR, 1)) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(ELM_PLIST(vecR, 1))))
            return ProdListList(vecL, vecR);

        vecR = ErrorReturnObj(
            "Vector *: vectors have different fields",
            0L, 0L,
            "you can replace vector <right> via 'return <right>;'");
        return PROD(vecL, vecR);
    }

    /* to add we need the successor table                                  */
    succ = SUCC_FF(fld);

    /* loop over the elements and add                                      */
    valS = (FFV)0;
    ptrL = ADDR_OBJ(vecL);
    ptrR = ADDR_OBJ(vecR);
    for (i = 1; i <= len; i++) {
        valL = VAL_FFE(ptrL[i]);
        valR = VAL_FFE(ptrR[i]);
        valP = PROD_FFV(valL, valR, succ);
        valS = SUM_FFV(valS, valP, succ);
    }

    /* return the result                                                   */
    return NEW_FFE(fld, valS);
}

/****************************************************************************
**
*F  FuncAddRowVectorVecFFEsMult( <self>, <vecL>, <vecR>, <mult> )
**
*/

static Obj AddRowVectorOp;   /* BH changed to static */

Obj FuncAddRowVectorVecFFEsMult( Obj self, Obj vecL, Obj vecR, Obj mult )
{
    Obj *ptrL;
    Obj *ptrR;
    FFV  valM;
    FFV  valS;
    FFV  valL;
    FFV  valR;
    FF  fld;
    FFV *succ;
    UInt len;
    UInt xtype;
    UInt i;

    if (!IS_FFE(mult))
        return TRY_NEXT_METHOD;

    if (VAL_FFE(mult) == 0)
        return (Obj) 0;

    xtype = KTNumPlist(vecL, (Obj *) 0);
    if (xtype != T_PLIST_FFE && xtype != T_PLIST_FFE + IMMUTABLE)
        return TRY_NEXT_METHOD;

    xtype = KTNumPlist(vecR, (Obj *) 0);
    if (xtype != T_PLIST_FFE && xtype != T_PLIST_FFE + IMMUTABLE)
        return TRY_NEXT_METHOD;


    /* check the lengths                                                   */
    len = LEN_PLIST(vecL);
    if (len != LEN_PLIST(vecR)) {
        vecR = ErrorReturnObj(
            "AddRowVector: vector lengths differ <left> %d,  <right> %d",
            (Int)len, (Int)LEN_PLIST(vecR),
            "you can replace vector <right> via 'return <right>;'");
        return CALL_3ARGS(AddRowVectorOp, vecL, vecR, mult);
    }

    /* check the fields                                                    */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(ELM_PLIST(vecR, 1)) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(ELM_PLIST(vecR, 1))))
            return TRY_NEXT_METHOD;

        vecR = ErrorReturnObj(
            "AddRowVector: vectors have different fields",
            0L, 0L,
            "you can replace vector <right> via 'return <right>;'");
        return CALL_3ARGS(AddRowVectorOp, vecL, vecR, mult);
    }

    /* Now check the multiplier field */
    if (FLD_FFE(mult) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) != CHAR_FF(FLD_FFE(mult))) {
            mult = ErrorReturnObj(
                "AddRowVector: <multiplier> has different field",
                0L, 0L,
                "you can replace <multiplier> via 'return <multiplier>;'");
            return CALL_3ARGS(AddRowVectorOp, vecL, vecR, mult);
        }

        /* if the multiplier is over a non subfield then redispatch */
        if ((DEGR_FF(fld) % DegreeFFE(mult)) != 0)
            return TRY_NEXT_METHOD;

        /* otherwise it's a subfield, so promote it */
        valM = VAL_FFE(mult);
        if (valM != 0)
            valM = 1 + (valM - 1) * (SIZE_FF(fld) - 1) / (SIZE_FF(FLD_FFE(mult)) - 1);
    } else
        valM = VAL_FFE(mult);


    succ = SUCC_FF(fld);
    ptrL = ADDR_OBJ(vecL);
    ptrR = ADDR_OBJ(vecR);

    /* two versions of the loop to avoid multipling by 1 */
    if (valM == 1)
        for (i = 1; i <= len; i++) {
            valL = VAL_FFE(ptrL[i]);
            valR = VAL_FFE(ptrR[i]);
            valS = SUM_FFV(valL, valR, succ);
            ptrL[i] = NEW_FFE(fld, valS);
        }
    else
        for (i = 1; i <= len; i++) {
            valL = VAL_FFE(ptrL[i]);
            valR = VAL_FFE(ptrR[i]);
            valS = PROD_FFV(valR, valM, succ);
            valS = SUM_FFV(valL, valS, succ);
            ptrL[i] = NEW_FFE(fld, valS);
        }
    return (Obj) 0;
}
/****************************************************************************
**
*F  FuncMultRowVectorVecFFEs( <self>, <vec>, <mult> )
**
*/

static Obj MultRowVectorOp;   /* BH changed to static */

Obj FuncMultRowVectorVecFFEs( Obj self, Obj vec, Obj mult )
{
    Obj *ptr;
    FFV  valM;
    FFV  valS;
    FFV  val;
    FF  fld;
    FFV *succ;
    UInt len;
    UInt xtype;
    UInt i;

    if (!IS_FFE(mult))
        return TRY_NEXT_METHOD;

    if (VAL_FFE(mult) == 1)
        return (Obj) 0;

    xtype = KTNumPlist(vec, (Obj *) 0);
    if (xtype != T_PLIST_FFE &&
    xtype != T_PLIST_FFE + IMMUTABLE)
        return TRY_NEXT_METHOD;

    /* check the lengths                                                   */
    len = LEN_PLIST(vec);

    fld = FLD_FFE(ELM_PLIST(vec, 1));
    /* Now check the multiplier field */
    if (FLD_FFE(mult) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) != CHAR_FF(FLD_FFE(mult))) {
            mult = ErrorReturnObj(
                "MultRowVector: <multiplier> has different field",
                0L, 0L,
                "you can replace <multiplier> via 'return <multiplier>;'");
            return CALL_2ARGS(MultRowVectorOp, vec, mult);
        }

        /* if the multiplier is over a non subfield then redispatch */
        if ((DEGR_FF(fld) % DegreeFFE(mult)) != 0)
            return TRY_NEXT_METHOD;

        /* otherwise it's a subfield, so promote it */
        valM = VAL_FFE(mult);
        if (valM != 0)
            valM = 1 + (valM - 1) * (SIZE_FF(fld) - 1) / (SIZE_FF(FLD_FFE(mult)) - 1);
    } else
        valM = VAL_FFE(mult);


    succ = SUCC_FF(fld);
    ptr = ADDR_OBJ(vec);

    /* two versions of the loop to avoid multipling by 0 */
    if (valM == 0) {
        Obj z;
        z = NEW_FFE(fld, 0);
        for (i = 1; i <= len; i++) {
            ptr[i] = z;
        }
    } else
        for (i = 1; i <= len; i++) {
            val = VAL_FFE(ptr[i]);
            valS = PROD_FFV(val, valM, succ);
            ptr[i] = NEW_FFE(fld, valS);
        }
    return (Obj) 0;
}

/****************************************************************************
**
*F  FuncAddRowVectorVecFFEs( <self>, <vecL>, <vecR> )
**
*/
Obj FuncAddRowVectorVecFFEs( Obj self, Obj vecL, Obj vecR )
{
    Obj *ptrL;
    Obj *ptrR;
    FFV  valS;
    FFV  valL;
    FFV  valR;
    FF  fld;
    FFV *succ;
    UInt len;
    UInt xtype;
    UInt i;

    xtype = KTNumPlist(vecL, (Obj *) 0);
    if (xtype != T_PLIST_FFE && xtype != T_PLIST_FFE + IMMUTABLE)
        return TRY_NEXT_METHOD;

    xtype = KTNumPlist(vecR, (Obj *) 0);
    if (xtype != T_PLIST_FFE && xtype != T_PLIST_FFE + IMMUTABLE)
        return TRY_NEXT_METHOD;

    /* check the lengths                                                   */
    len = LEN_PLIST(vecL);
    if (len != LEN_PLIST(vecR)) {
        vecR = ErrorReturnObj(
            "Vector *: vector lengths differ <left> %d,  <right> %d",
            (Int)len, (Int)LEN_PLIST(vecR),
            "you can replace vector <right> via 'return <right>;'");
        return CALL_2ARGS(AddRowVectorOp, vecL, vecR);
    }

    /* check the fields                                                    */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(ELM_PLIST(vecR, 1)) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(ELM_PLIST(vecR, 1))))
            return TRY_NEXT_METHOD;

        vecR = ErrorReturnObj(
            "AddRowVector: vectors have different fields",
            0L, 0L,
            "you can replace vector <right> via 'return <right>;'");
        return CALL_2ARGS(AddRowVectorOp, vecL, vecR);
    }

    succ = SUCC_FF(fld);
    ptrL = ADDR_OBJ(vecL);
    ptrR = ADDR_OBJ(vecR);

    for (i = 1; i <= len; i++) {
        valL = VAL_FFE(ptrL[i]);
        valR = VAL_FFE(ptrR[i]);
        valS = SUM_FFV(valL, valR, succ);
        ptrL[i] = NEW_FFE(fld, valS);
    }
    return (Obj) 0;
}

/****************************************************************************
**
*F  ProdVectorMatrix(<vecL>,<vecR>) . . . .  product of a vector and a matrix
**
**  'ProdVectorMatrix' returns the product of the vector <vecL> and the matrix
**  <vecR>.  The product is the sum of the  rows  of <vecR>, each multiplied by
**  the corresponding entry of <vecL>.
**
**  'ProdVectorMatrix'  is an improved version of 'ProdListList',  which does
**  not  call 'PROD' and  also accumulates  the sum into  one  fixed  vector
**  instead of allocating a new for each product and sum.
*/
Obj             ProdVecFFEMatFFE (
				  Obj                 vecL,
				  Obj                 matR )
{
    Obj                 vecP;           /* handle of the product           */
    Obj *               ptrP;           /* pointer into the product        */
    FFV *               ptrV;           /* value pointer into the product  */
    FFV                 valP;           /* one value of the product        */
    FFV                 valL;           /* one value of the left operand   */
    Obj                 vecR;           /* one vector of the right operand */
    Obj *               ptrR;           /* pointer into the right vector   */
    FFV                 valR;           /* one value from the right vector */
    UInt                len;            /* length                          */
    UInt                col;            /* length of the rows in matR      */
    UInt                i, k;           /* loop variables                  */
    FF                  fld;            /* the common finite field         */
    FF *                succ;           /* the successor table             */

    /* check the lengths                                                   */
    len = LEN_PLIST(vecL);
    col = LEN_PLIST(ELM_PLIST(matR, 1));
    if (len != LEN_PLIST(matR)) {
        matR = ErrorReturnObj(
            "<vec>*<mat>: <vec> (%d) must have the same length as <mat> (%d)",
            (Int)len, (Int)col,
            "you can replace matrix <mat> via 'return <mat>;'");
        return PROD(vecL, matR);
    }

    /* check the fields                                                    */
    vecR = ELM_PLIST(matR, 1);
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(ELM_PLIST(vecR, 1)) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(ELM_PLIST(vecR, 1))))
            return ProdListList(vecL, matR);

        matR = ErrorReturnObj(
            "<vec>*<mat>: <vec> and <mat> have different fields",
            0L, 0L,
            "you can replace matrix <mat> via 'return <mat>;'");
        return PROD(vecL, matR);
    }

    /* make the result list by multiplying the first entries               */
    vecP = ProdFFEVecFFE(ELM_PLIST(vecL, 1), vecR);

    /* to add we need the successor table                                  */
    succ = SUCC_FF(fld);

    /* convert vecP into a list of values                                  */
    /*N 5Jul1998 werner: This only works if sizeof(FFV) <= sizeof(Obj)     */
    /*N We have to be careful not to overwrite the length info             */
    ptrP = ADDR_OBJ(vecP);
    ptrV = ((FFV*)(ptrP + 1)) - 1;
    for (k = 1; k <= col; k++)
        ptrV[k] = VAL_FFE(ptrP[k]);

    /* loop over the other entries and multiply                            */
    for (i = 2; i <= len; i++) {
        valL = VAL_FFE(ELM_PLIST(vecL, i));
        vecR = ELM_PLIST(matR, i);
        ptrR = ADDR_OBJ(vecR);
        if (valL == (FFV)1) {
            for (k = 1; k <= col; k++) {
                valR = VAL_FFE(ptrR[k]);
                valP = ptrV[k];
                ptrV[k] = SUM_FFV(valP, valR, succ);
            }
        } else if (valL != (FFV)0) {
            for (k = 1; k <= col; k++) {
                valR = VAL_FFE(ptrR[k]);
                valR = PROD_FFV(valL, valR, succ);
                valP = ptrV[k];
                ptrV[k] = SUM_FFV(valP, valR, succ);
            }
        }
    }

    /* convert vecP back into a list of finite field elements              */
    /*N 5Jul1998 werner: This only works if sizeof(FFV) <= sizeof(Obj)     */
    /*N We have to be careful not to overwrite the length info             */
    for (k = col; k >= 1; k--)
        ptrP[k] = NEW_FFE(fld, ptrV[k]);

    /* return the result                                                   */
    return vecP;
}


/****************************************************************************
**
*F  ZeroVecFFE(<vec>) . . . .  zero of an FFE Vector
**
**  'ZeroVecFEE' returns the zero of the vector <vec>.
**
**  It is a better version of ZeroListDefault for the case of vecffes
**  becuase it knows tha the zero is common and the result a vecffe
*/

Obj ZeroMutVecFFE( Obj vec )
{
    UInt i, len;
    Obj res;
    Obj z;
    assert(TNUM_OBJ(vec) >= T_PLIST_FFE && \
    TNUM_OBJ(vec) <= T_PLIST_FFE + IMMUTABLE);
    len = LEN_PLIST(vec);
    assert(len);
    res  = NEW_PLIST(T_PLIST_FFE, len);
    SET_LEN_PLIST(res, len);
    z = ZERO(ELM_PLIST(vec, 1));
    for (i = 1; i <= len; i++)
        SET_ELM_PLIST(res, i, z);
    return res;
}

Obj ZeroVecFFE( Obj vec )
{
    UInt i, len;
    Obj res;
    Obj z;
    assert(TNUM_OBJ(vec) >= T_PLIST_FFE && \
    TNUM_OBJ(vec) <= T_PLIST_FFE + IMMUTABLE);
    len = LEN_PLIST(vec);
    assert(len);
    res  = NEW_PLIST(TNUM_OBJ(vec), len);
    SET_LEN_PLIST(res, len);
    z = ZERO(ELM_PLIST(vec, 1));
    for (i = 1; i <= len; i++)
        SET_ELM_PLIST(res, i, z);
    return res;
}

UInt IsVecFFE(Obj vec)
{
    UInt tn;
    tn = TNUM_OBJ(vec);
    if (tn >= T_PLIST_FFE && tn <= T_PLIST_FFE + IMMUTABLE)
        return 1;
    if (!IS_PLIST(vec))
        return 0;
    TYPE_OBJ(vec); /* force a full inspection of the list */
    tn = TNUM_OBJ(vec);
    return tn >= T_PLIST_FFE && tn <= T_PLIST_FFE + IMMUTABLE;
}


Obj FuncIS_VECFFE( Obj self, Obj vec)
{
    return IsVecFFE(vec) ? True : False;
}

Obj FuncCOMMON_FIELD_VECFFE( Obj self, Obj vec)
{
    Obj elm;
    if (!IsVecFFE(vec))
        return Fail;
    elm = ELM_PLIST(vec, 1);
    return INTOBJ_INT(SIZE_FF(FLD_FFE(elm)));
}

Obj FuncSMALLEST_FIELD_VECFFE( Obj self, Obj vec)
{
    Obj elm;
    UInt deg, deg1, deg2, i, len, p, q;
    UInt isVecFFE = IsVecFFE(vec);
    len  = LEN_PLIST(vec);
    if (len == 0)
        return Fail;
    elm = ELM_PLIST(vec, 1);
    if (!isVecFFE && !IS_FFE(elm))
        return Fail;
    deg = DegreeFFE(elm);
    p = CharFFE(elm);
    for (i = 2; i <= len; i++) {
        elm = ELM_PLIST(vec, i);
        if (!isVecFFE && (!IS_FFE(elm) || CharFFE(elm) != p))
            return Fail;
        deg2 =  DegreeFFE(elm);
        deg1 = deg;
        while (deg % deg2 != 0)
            deg += deg1;
    }
    q = p;
    for (i = 2; i <= deg; i++)
        q *= p;
    return INTOBJ_INT(q);
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

  { "ADD_ROWVECTOR_VECFFES_3", 3, "vecl, vecr, mult",
    FuncAddRowVectorVecFFEsMult, "src/vecffe.c: ADD_ROWVECTOR_VECFFES_3" },

  { "ADD_ROWVECTOR_VECFFES_2", 2, "vecl, vecr",
    FuncAddRowVectorVecFFEs, "src/vecffe.c: ADD_ROWVECTOR_VECFFES_2" },

  { "MULT_ROWVECTOR_VECFFES", 2, "vec, mult",
    FuncMultRowVectorVecFFEs, "src/vecffe.c: MULT_ROWVECTOR_VECFFES" },
  
  { "IS_VECFFE", 1, "vec",
    FuncIS_VECFFE, "src/vecffe.c: IS_VECFFE" },

  { "COMMON_FIELD_VECFFE", 1, "vec",
    FuncCOMMON_FIELD_VECFFE, "src/vecffe.c: COMMON_FIELD_VECFFE" },

  { "SMALLEST_FIELD_VECFFE", 1, "vec",
    FuncSMALLEST_FIELD_VECFFE, "src/vecffe.c: SMALLEST_FIELD_VECFFE" },
  
  { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    Int                 t1;
    Int                 t2;

    /* install the arithmetic operation methods                            */
    for (t1 = T_PLIST_FFE; t1 <= T_PLIST_FFE + IMMUTABLE; t1++) {
        SumFuncs[  T_FFE ][  t1   ] = SumFFEVecFFE;
        SumFuncs[   t1   ][ T_FFE ] = SumVecFFEFFE;
        DiffFuncs[ T_FFE ][  t1   ] = DiffFFEVecFFE;
        DiffFuncs[  t1   ][ T_FFE ] = DiffVecFFEFFE;
        ProdFuncs[ T_FFE ][  t1   ] = ProdFFEVecFFE;
        ProdFuncs[  t1   ][ T_FFE ] = ProdVecFFEFFE;
        ZeroFuncs[  t1   ] = ZeroVecFFE;
        ZeroMutFuncs[  t1   ] = ZeroMutVecFFE;
    }

    for (t1 = T_PLIST_FFE; t1 <= T_PLIST_FFE + IMMUTABLE; t1++) {
        for (t2 = T_PLIST_FFE; t2 <= T_PLIST_FFE + IMMUTABLE; t2++) {
            SumFuncs[  t1 ][ t2 ] =  SumVecFFEVecFFE;
            DiffFuncs[ t1 ][ t2 ] = DiffVecFFEVecFFE;
            ProdFuncs[ t1 ][ t2 ] = ProdVecFFEVecFFE;
        }
    }


    InitHdlrFuncsFromTable(GVarFuncs);

    InitFopyGVar("AddRowVector", &AddRowVectorOp);
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
    InitGVarFuncsFromTable(GVarFuncs);

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoVecFFE()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "vecffe",                           /* name                           */
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

StructInitInfo * InitInfoVecFFE ( void )
{
    return &module;
}
