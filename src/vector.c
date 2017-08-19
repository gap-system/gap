/****************************************************************************
**
*W  vector.c                    GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions  that mainly  operate  on vectors  whose
**  elements are integers, rationals, or elements from cyclotomic fields.  As
**  vectors are special lists many things are done in the list package.
**
**  A *vector* is a list that has no holes,  and whose elements all come from
**  a common field.  For the full definition of vectors see chapter "Vectors"
**  in  the {\GAP} manual.   Read also about "More   about Vectors" about the
**  vector flag and the compact representation of vectors over finite fields.
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

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/listoper.h>               /* operations for generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */

#include <src/vector.h>                 /* functions for plain vectors */

#include <src/range.h>                  /* ranges */

#include <src/code.h>                   /* coder */
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/tls.h>                /* thread-local storage */

#include <assert.h>

#define IS_IMM_PLIST(list)  ((TNUM_OBJ(list) - T_PLIST) % 2)

/****************************************************************************
**
*F  SumIntVector(<elmL>,<vecR>) . . . . . . .  sum of an integer and a vector
**
**  'SumIntVector' returns the   sum of the   integer <elmL>  and  the vector
**  <vecR>.  The sum is a  list, where each element is  the sum of <elmL> and
**  the corresponding element of <vecR>.
**
**  'SumIntVector' is an improved version  of  'SumSclList', which  does  not
**  call 'SUM' if the operands are immediate integers.
*/
Obj             SumIntVector (
    Obj                 elmL,
    Obj                 vecR )
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    Obj                 elmS;           /* one element of sum list         */
    Obj *               ptrR;           /* pointer into the right operand  */
    Obj                 elmR;           /* one element of right operand    */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecS = NEW_PLIST(TNUM_OBJ(vecR), len);
    SET_LEN_PLIST(vecS, len);

    /* loop over the elements and add                                      */
    ptrR = ADDR_OBJ(vecR);
    ptrS = ADDR_OBJ(vecS);
    for (i = 1; i <= len; i++) {
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! SUM_INTOBJS(elmS, elmL, elmR)) {
            CHANGED_BAG(vecS);
            elmS = SUM(elmL, elmR);
            ptrR = ADDR_OBJ(vecR);
            ptrS = ADDR_OBJ(vecS);
        }
        ptrS[i] = elmS;
    }

    /* return the result                                                   */
    CHANGED_BAG(vecS);
    return vecS;
}


/****************************************************************************
**
*F  SumVectorInt(<vecL>,<elmR>) . . . . . . .  sum of a vector and an integer
**
**  'SumVectorInt' returns  the sum of   the  vector <vecL> and  the  integer
**  <elmR>.  The sum is a  list, where each element  is the sum of <elmR> and
**  the corresponding element of <vecL>.
**
**  'SumVectorInt' is an improved version  of  'SumListScl', which  does  not
**  call 'SUM' if the operands are immediate integers.
*/
Obj             SumVectorInt (
    Obj                 vecL,
    Obj                 elmR )
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    Obj                 elmS;           /* one element of sum list         */
    Obj *               ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecS = NEW_PLIST(TNUM_OBJ(vecL), len);
    SET_LEN_PLIST(vecS, len);

    /* loop over the elements and add                                      */
    ptrL = ADDR_OBJ(vecL);
    ptrS = ADDR_OBJ(vecS);
    for (i = 1; i <= len; i++) {
        elmL = ptrL[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! SUM_INTOBJS(elmS, elmL, elmR)) {
            CHANGED_BAG(vecS);
            elmS = SUM(elmL, elmR);
            ptrL = ADDR_OBJ(vecL);
            ptrS = ADDR_OBJ(vecS);
        }
        ptrS[i] = elmS;
    }

    /* return the result                                                   */
    CHANGED_BAG(vecS);
    return vecS;
}


/****************************************************************************
**
*F  SumVectorVector(<vecL>,<vecR>)  . . . . . . . . . . .  sum of two vectors
**
**  'SumVectorVector' returns the sum  of the two  vectors <vecL> and <vecR>.
**  The sum is a new list, where each element is the sum of the corresponding
**  elements of <vecL> and <vecR>.
**
**  'SumVectorVector' is an improved version of 'SumListList', which does not
**  call 'SUM' if the operands are immediate integers.
*/
Obj             SumVectorVector (
    Obj                 vecL,
    Obj                 vecR )
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    Obj                 elmS;           /* one element of sum list         */
    Obj *               ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    Obj *               ptrR;           /* pointer into the right operand  */
    Obj                 elmR;           /* one element of right operand    */
    UInt                lenL, lenR, len, lenmin; /* lengths                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    lenL = LEN_PLIST(vecL);
    lenR = LEN_PLIST(vecR);
    if (lenL < lenR) {
        lenmin = lenL;
        len = lenR;
    } else {
        lenmin = lenR;
        len = lenL;
    }
    vecS = NEW_PLIST((IS_IMM_PLIST(vecL) && IS_IMM_PLIST(vecR)) ?
                      T_PLIST_CYC + IMMUTABLE : T_PLIST_CYC, len);
    SET_LEN_PLIST(vecS, len);

    /* loop over the elements and add                                      */
    ptrL = ADDR_OBJ(vecL);
    ptrR = ADDR_OBJ(vecR);
    ptrS = ADDR_OBJ(vecS);
    for (i = 1; i <= lenmin; i++) {
        elmL = ptrL[i];
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! SUM_INTOBJS(elmS, elmL, elmR)) {
            CHANGED_BAG(vecS);
            elmS = SUM(elmL, elmR);
            ptrL = ADDR_OBJ(vecL);
            ptrR = ADDR_OBJ(vecR);
            ptrS = ADDR_OBJ(vecS);
        }
        ptrS[i] = elmS;
    }
    if (lenL < lenR)
        for (; i <= lenR; i++) {
            ptrS[i] = ptrR[i];
        }
    else
        for (; i <= lenL; i++) {
            ptrS[i] = ptrL[i];
        }
    /* return the result                                                   */
    CHANGED_BAG(vecS);
    return vecS;
}


/****************************************************************************
**
*F  DiffIntVector(<elmL>,<vecR>)  . . . difference of an integer and a vector
**
**  'DiffIntVector' returns  the difference  of  the integer  <elmL> and  the
**  vector <vecR>.   The difference  is  a list,  where  each element is  the
**  difference of <elmL> and the corresponding element of <vecR>.
**
**  'DiffIntVector'  is an improved  version of 'DiffSclList', which does not
**  call 'DIFF' if the operands are immediate integers.
*/
Obj             DiffIntVector (
    Obj                 elmL,
    Obj                 vecR )
{
    Obj                 vecD;           /* handle of the difference        */
    Obj *               ptrD;           /* pointer into the difference     */
    Obj                 elmD;           /* one element of difference list  */
    Obj *               ptrR;           /* pointer into the right operand  */
    Obj                 elmR;           /* one element of right operand    */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecD = NEW_PLIST(IS_MUTABLE_OBJ(vecR) ?
                     T_PLIST_CYC : T_PLIST_CYC + IMMUTABLE, len);
    SET_LEN_PLIST(vecD, len);

    /* loop over the elements and subtract                                 */
    ptrR = ADDR_OBJ(vecR);
    ptrD = ADDR_OBJ(vecD);
    for (i = 1; i <= len; i++) {
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! DIFF_INTOBJS(elmD, elmL, elmR)) {
            CHANGED_BAG(vecD);
            elmD = DIFF(elmL, elmR);
            ptrR = ADDR_OBJ(vecR);
            ptrD = ADDR_OBJ(vecD);
        }
        ptrD[i] = elmD;
    }

    /* return the result                                                   */
    CHANGED_BAG(vecD);
    return vecD;
}


/****************************************************************************
**
*F  DiffVectorInt(<vecL>,<elmR>)  . . . difference of a vector and an integer
**
**  'DiffVectorInt' returns   the  difference of the  vector  <vecL>  and the
**  integer <elmR>.  The difference   is a list,   where each element  is the
**  difference of <elmR> and the corresponding element of <vecL>.
**
**  'DiffVectorInt' is an improved  version of 'DiffListScl', which  does not
**  call 'DIFF' if the operands are immediate integers.
*/
Obj             DiffVectorInt (
    Obj                 vecL,
    Obj                 elmR )
{
    Obj                 vecD;           /* handle of the difference        */
    Obj *               ptrD;           /* pointer into the difference     */
    Obj                 elmD;           /* one element of difference list  */
    Obj *               ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecD = NEW_PLIST(TNUM_OBJ(vecL), len);
    SET_LEN_PLIST(vecD, len);

    /* loop over the elements and subtract                                 */
    ptrL = ADDR_OBJ(vecL);
    ptrD = ADDR_OBJ(vecD);
    for (i = 1; i <= len; i++) {
        elmL = ptrL[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! DIFF_INTOBJS(elmD, elmL, elmR)) {
            CHANGED_BAG(vecD);
            elmD = DIFF(elmL, elmR);
            ptrL = ADDR_OBJ(vecL);
            ptrD = ADDR_OBJ(vecD);
        }
        ptrD[i] = elmD;
    }

    /* return the result                                                   */
    CHANGED_BAG(vecD);
    return vecD;
}


/****************************************************************************
**
*F  DiffVectorVector(<vecL>,<vecR>) . . . . . . . . difference of two vectors
**
**  'DiffVectorVector'  returns the difference of the  two vectors <vecL> and
**  <vecR>.   The  difference is   a new   list, where  each  element  is the
**  difference of the corresponding elements of <vecL> and <vecR>.
**
**  'DiffVectorVector' is an improved  version of  'DiffListList', which does
**  not call 'DIFF' if the operands are immediate integers.
*/
Obj             DiffVectorVector (
    Obj                 vecL,
    Obj                 vecR )
{
    Obj                 vecD;           /* handle of the sum               */
    Obj *               ptrD;           /* pointer into the sum            */
    Obj                 elmD;           /* one element of sum list         */
    Obj *               ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    Obj *               ptrR;           /* pointer into the right operand  */
    Obj                 elmR;           /* one element of right operand    */
    UInt                lenL, lenR, len, lenmin; /* lengths                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    lenL = LEN_PLIST(vecL);
    lenR = LEN_PLIST(vecR);
    if (lenL < lenR) {
        lenmin = lenL;
        len = lenR;
    } else {
        lenmin = lenR;
        len = lenL;
    }
    vecD = NEW_PLIST((IS_IMM_PLIST(vecL) && IS_IMM_PLIST(vecR)) ?
    T_PLIST_CYC + IMMUTABLE : T_PLIST_CYC, len);
    SET_LEN_PLIST(vecD, len);

    /* loop over the elements and subtract                                   */
    ptrL = ADDR_OBJ(vecL);
    ptrR = ADDR_OBJ(vecR);
    ptrD = ADDR_OBJ(vecD);
    for (i = 1; i <= lenmin; i++) {
        elmL = ptrL[i];
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! DIFF_INTOBJS(elmD, elmL, elmR)) {
            CHANGED_BAG(vecD);
            elmD = DIFF(elmL, elmR);
            ptrL = ADDR_OBJ(vecL);
            ptrR = ADDR_OBJ(vecR);
            ptrD = ADDR_OBJ(vecD);
        }
        ptrD[i] = elmD;
    }
    if (lenL < lenR)
        for (; i <= lenR; i++) {
            elmR = ptrR[i];
            if (! IS_INTOBJ(elmR) || ! DIFF_INTOBJS(elmD, INTOBJ_INT(0), elmR)) {
                CHANGED_BAG(vecD);
                elmD = AINV(elmR);
                ptrR = ADDR_OBJ(vecR);
                ptrD = ADDR_OBJ(vecD);
            }
            ptrD[i] = elmD;
        }
    else
        for (; i <= lenL; i++) {
            ptrD[i] = ptrL[i];
        }
    /* return the result                                                   */
    CHANGED_BAG(vecD);
    return vecD;
}


/****************************************************************************
**
*F  ProdIntVector(<elmL>,<vecR>)  . . . .  product of an integer and a vector
**
**  'ProdIntVector' returns the product of the integer  <elmL> and the vector
**  <vecR>.  The product is  the list, where  each element is the product  of
**  <elmL> and the corresponding entry of <vecR>.
**
**  'ProdIntVector'  is an  improved version of 'ProdSclList', which does not
**  call 'PROD' if the operands are immediate integers.
*/
Obj             ProdIntVector (
    Obj                 elmL,
    Obj                 vecR )
{
    Obj                 vecP;           /* handle of the product           */
    Obj *               ptrP;           /* pointer into the product        */
    Obj                 elmP;           /* one element of product list     */
    Obj *               ptrR;           /* pointer into the right operand  */
    Obj                 elmR;           /* one element of right operand    */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecP = NEW_PLIST(IS_MUTABLE_OBJ(vecR) ?
                     T_PLIST_CYC : T_PLIST_CYC + IMMUTABLE, len);
    SET_LEN_PLIST(vecP, len);

    /* loop over the entries and multiply                                  */
    ptrR = ADDR_OBJ(vecR);
    ptrP = ADDR_OBJ(vecP);
    for (i = 1; i <= len; i++) {
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! PROD_INTOBJS(elmP, elmL, elmR)) {
            CHANGED_BAG(vecP);
            elmP = PROD(elmL, elmR);
            ptrR = ADDR_OBJ(vecR);
            ptrP = ADDR_OBJ(vecP);
        }
        ptrP[i] = elmP;
    }

    /* return the result                                                   */
    CHANGED_BAG(vecP);
    return vecP;
}


/****************************************************************************
**
*F  ProdVectorInt(<vecL>,<elmR>)  . . . .  product of a scalar and an integer
**
**  'ProdVectorInt' returns the product of the integer  <elmR> and the vector
**  <vecL>.  The  product is the  list, where each element  is the product of
**  <elmR> and the corresponding element of <vecL>.
**
**  'ProdVectorInt'  is an  improved version of 'ProdSclList', which does not
**  call 'PROD' if the operands are immediate integers.
*/
Obj             ProdVectorInt (
    Obj                 vecL,
    Obj                 elmR )
{
    Obj                 vecP;           /* handle of the product           */
    Obj *               ptrP;           /* pointer into the product        */
    Obj                 elmP;           /* one element of product list     */
    Obj *               ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecP = NEW_PLIST(IS_MUTABLE_OBJ(vecL) ?
                     T_PLIST_CYC : T_PLIST_CYC + IMMUTABLE, len);
    SET_LEN_PLIST(vecP, len);

    /* loop over the entries and multiply                                  */
    ptrL = ADDR_OBJ(vecL);
    ptrP = ADDR_OBJ(vecP);
    for (i = 1; i <= len; i++) {
        elmL = ptrL[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! PROD_INTOBJS(elmP, elmL, elmR)) {
            CHANGED_BAG(vecP);
            elmP = PROD(elmL, elmR);
            ptrL = ADDR_OBJ(vecL);
            ptrP = ADDR_OBJ(vecP);
        }
        ptrP[i] = elmP;
    }

    /* return the result                                                   */
    CHANGED_BAG(vecP);
    return vecP;
}


/****************************************************************************
**
*F  ProdVectorVector(<vecL>,<vecR>) . . . . . . . . .  product of two vectors
**
**  'ProdVectorVector'  returns the product  of   the two vectors <vecL>  and
**  <vecR>.  The  product  is the  sum of the   products of the corresponding
**  elements of the two lists.
**
**  'ProdVectorVector' is an improved version  of 'ProdListList',  which does
**  not call 'PROD' if the operands are immediate integers.
*/
Obj             ProdVectorVector (
    Obj                 vecL,
    Obj                 vecR )
{
    Obj                 elmP;           /* product, result                 */
    Obj                 elmS;           /* partial sum of result           */
    Obj                 elmT;           /* one summand of result           */
    Obj *               ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    Obj *               ptrR;           /* pointer into the right operand  */
    Obj                 elmR;           /* one element of right operand    */
    UInt                lenL, lenR, len; /* length                          */
    UInt                i;              /* loop variable                   */

    /* check that the lengths agree                                        */
    lenL = LEN_PLIST(vecL);
    lenR = LEN_PLIST(vecR);
    len = (lenL < lenR) ? lenL : lenR;

    /* loop over the entries and multiply                                  */
    ptrL = ADDR_OBJ(vecL);
    ptrR = ADDR_OBJ(vecR);
    elmL = ptrL[1];
    elmR = ptrR[1];
    if (! ARE_INTOBJS(elmL, elmR) || ! PROD_INTOBJS(elmT, elmL, elmR)) {
        elmT = PROD(elmL, elmR);
        ptrL = ADDR_OBJ(vecL);
        ptrR = ADDR_OBJ(vecR);
    }
    elmP = elmT;
    for (i = 2; i <= len; i++) {
        elmL = ptrL[i];
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! PROD_INTOBJS(elmT, elmL, elmR)) {
            elmT = PROD(elmL, elmR);
            ptrL = ADDR_OBJ(vecL);
            ptrR = ADDR_OBJ(vecR);
        }
        if (! ARE_INTOBJS(elmP, elmT) || ! SUM_INTOBJS(elmS, elmP, elmT)) {
            elmS = SUM(elmP, elmT);
            ptrL = ADDR_OBJ(vecL);
            ptrR = ADDR_OBJ(vecR);
        }
        elmP = elmS;
    }

    /* return the result                                                   */
    return elmP;
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
**
**  We now need to supply a handler for this and install it as a library method,
**  
*/
Obj             ProdVectorMatrix (
    Obj                 vecL,
    Obj                 matR )
{
    Obj                 vecP;           /* handle of the product           */
    Obj *               ptrP;           /* pointer into the product        */
    Obj                 elmP;           /* one summand of product          */
    Obj                 elmS;           /* temporary for sum               */
    Obj                 elmT;           /* another temporary               */
    Obj                 elmL;           /* one element of left operand     */
    Obj                 vecR;           /* one vector of right operand     */
    Obj *               ptrR;           /* pointer into the right vector   */
    Obj                 elmR;           /* one element from right vector   */
    UInt                len;            /* length                          */
    UInt                col;            /* length of the rows              */
    UInt                i, k;           /* loop variables                  */

    /* check the lengths                                                   */
    len = LEN_PLIST(vecL);
    if (len > LEN_PLIST(matR))
        len = LEN_PLIST(matR);
    col = LEN_PLIST(ELM_PLIST(matR, 1));

    /* make the result list */

    vecP = NEW_PLIST((IS_MUTABLE_OBJ(vecL) || IS_MUTABLE_OBJ(ELM_PLIST(matR, 1))) ?
                     T_PLIST_CYC : T_PLIST_CYC + IMMUTABLE,
    col);
    SET_LEN_PLIST(vecP, col);
    for (i = 1; i <= col; i++)
        SET_ELM_PLIST(vecP, i, INTOBJ_INT(0));


    /* loop over the entries and multiply                            */
    for (i = 1; i <= len; i++) {
        elmL = ELM_PLIST(vecL, i);
        vecR = ELM_PLIST(matR, i);
        ptrR = ADDR_OBJ(vecR);
        ptrP = ADDR_OBJ(vecP);
        if (elmL == INTOBJ_INT(1L)) {
            for (k = 1; k <= col; k++) {
                elmT = ptrR[k];
                elmP = ptrP[k];
                if (! ARE_INTOBJS(elmP, elmT)
                || ! SUM_INTOBJS(elmS, elmP, elmT)) {
                    CHANGED_BAG(vecP);
                    elmS = SUM(elmP, elmT);
                    ptrR = ADDR_OBJ(vecR);
                    ptrP = ADDR_OBJ(vecP);
                }
                ptrP[k] = elmS;
            }
        } else if (elmL == INTOBJ_INT(-1L)) {
            for (k = 1; k <= col; k++) {
                elmT = ptrR[k];
                elmP = ptrP[k];
                if (! ARE_INTOBJS(elmP, elmT)
                        || ! DIFF_INTOBJS(elmS, elmP, elmT)) {
                    CHANGED_BAG(vecP);
                    elmS = DIFF(elmP, elmT);
                    ptrR = ADDR_OBJ(vecR);
                    ptrP = ADDR_OBJ(vecP);
                }
                ptrP[k] = elmS;

            }
        } else if (elmL != INTOBJ_INT(0L)) {
            for (k = 1; k <= col; k++) {
                elmR = ptrR[k];
                if (elmR != INTOBJ_INT(0L)) {
                    if (! ARE_INTOBJS(elmL, elmR)
                            || ! PROD_INTOBJS(elmT, elmL, elmR)) {
                        CHANGED_BAG(vecP);
                        elmT = PROD(elmL, elmR);
                        ptrR = ADDR_OBJ(vecR);
                        ptrP = ADDR_OBJ(vecP);
                    }
                    elmP = ptrP[k];
                    if (! ARE_INTOBJS(elmP, elmT)
                            || ! SUM_INTOBJS(elmS, elmP, elmT)) {
                        CHANGED_BAG(vecP);
                        elmS = SUM(elmP, elmT);
                        ptrR = ADDR_OBJ(vecR);
                        ptrP = ADDR_OBJ(vecP);
                    }
                    ptrP[k] = elmS;
                }
            }
        }
    }

    /* return the result                                                   */
    CHANGED_BAG(vecP);
    return vecP;
}

Obj FuncPROD_VECTOR_MATRIX(Obj self, Obj vec, Obj mat)
{
    return ProdVectorMatrix(vec, mat);
}

/****************************************************************************
**
*F  ZeroVector(<vec>) . . . .  zero of a cyclotomicVector
**
**  'ZeroVector' returns the zero of the vector <vec>.
**
**  It is a better version of ZeroListDefault for the case of cyclotomic
**  vectors, becuase it knows what the cyclotomic zero is.
*/

Obj ZeroVector( Obj vec )
{
    UInt i, len;
    Obj res;
    assert(TNUM_OBJ(vec) >= T_PLIST_CYC && \
    TNUM_OBJ(vec) <= T_PLIST_CYC_SSORT + IMMUTABLE);
    len = LEN_PLIST(vec);
    res = NEW_PLIST(IS_MUTABLE_OBJ(vec) ? T_PLIST_CYC : T_PLIST_CYC + IMMUTABLE, len);
    SET_LEN_PLIST(res, len);
    for (i = 1; i <= len; i++)
        SET_ELM_PLIST(res, i, INTOBJ_INT(0));
    return res;
}

Obj ZeroMutVector( Obj vec )
{
    UInt i, len;
    Obj res;
    assert(TNUM_OBJ(vec) >= T_PLIST_CYC && \
    TNUM_OBJ(vec) <= T_PLIST_CYC_SSORT + IMMUTABLE);
    len = LEN_PLIST(vec);
    res = NEW_PLIST(T_PLIST_CYC, len);
    SET_LEN_PLIST(res, len);
    for (i = 1; i <= len; i++)
        SET_ELM_PLIST(res, i, INTOBJ_INT(0));
    return res;
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

  GVAR_FUNC(PROD_VECTOR_MATRIX, 2, "vec, mat"),
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

    /* init filters and functions                                          */
    InitHdlrFuncsFromTable(GVarFuncs);

    /* install the arithmetic operation methods                            */
    for (t1 = T_PLIST_CYC; t1 <= T_PLIST_CYC_SSORT + IMMUTABLE; t1++) {
        ZeroFuncs[ t1 ] = ZeroVector;
        ZeroMutFuncs[ t1 ] = ZeroMutVector;

        for (t2 = T_PLIST_CYC; t2 <= T_PLIST_CYC_SSORT + IMMUTABLE; t2++) {
            SumFuncs [ T_INT     ][ t2        ] = SumIntVector;
            SumFuncs [ t1        ][ T_INT     ] = SumVectorInt;
            SumFuncs [ t1        ][ t2        ] = SumVectorVector;
            DiffFuncs[ T_INT     ][ t2        ] = DiffIntVector;
            DiffFuncs[ t1        ][ T_INT     ] = DiffVectorInt;
            DiffFuncs[ t1        ][ t2        ] = DiffVectorVector;
            ProdFuncs[ T_INT     ][ t2        ] = ProdIntVector;
            ProdFuncs[ t1        ][ T_INT     ] = ProdVectorInt;
            ProdFuncs[ t1        ][ t2        ] = ProdVectorVector;
        }
    }

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
*F  InitInfoVector()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "vector",                           /* name                           */
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

StructInitInfo * InitInfoVector ( void )
{
    return &module;
}
