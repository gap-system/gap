/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
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

#include "vector.h"

#include "ariths.h"
#include "modules.h"
#include "plist.h"


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
static Obj SumIntVector(Obj elmL, Obj vecR)
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    Obj                 elmS;           /* one element of sum list         */
    const Obj *         ptrR;           /* pointer into the right operand  */
    Obj                 elmR;           /* one element of right operand    */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecS = NEW_PLIST(TNUM_OBJ(vecR), len);
    SET_LEN_PLIST(vecS, len);

    /* loop over the elements and add                                      */
    ptrR = CONST_ADDR_OBJ(vecR);
    ptrS = ADDR_OBJ(vecS);
    for (i = 1; i <= len; i++) {
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! SUM_INTOBJS(elmS, elmL, elmR)) {
            elmS = SUM(elmL, elmR);
            ptrR = CONST_ADDR_OBJ(vecR);
            ptrS = ADDR_OBJ(vecS);
            ptrS[i] = elmS;
            CHANGED_BAG(vecS);
        }
        else
            ptrS[i] = elmS;
    }

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
static Obj SumVectorInt(Obj vecL, Obj elmR)
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    Obj                 elmS;           /* one element of sum list         */
    const Obj *         ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecS = NEW_PLIST(TNUM_OBJ(vecL), len);
    SET_LEN_PLIST(vecS, len);

    /* loop over the elements and add                                      */
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrS = ADDR_OBJ(vecS);
    for (i = 1; i <= len; i++) {
        elmL = ptrL[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! SUM_INTOBJS(elmS, elmL, elmR)) {
            elmS = SUM(elmL, elmR);
            ptrL = CONST_ADDR_OBJ(vecL);
            ptrS = ADDR_OBJ(vecS);
            ptrS[i] = elmS;
            CHANGED_BAG(vecS);
        }
        else
            ptrS[i] = elmS;
    }

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
static Obj SumVectorVector(Obj vecL, Obj vecR)
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    Obj                 elmS;           /* one element of sum list         */
    const Obj *         ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    const Obj *         ptrR;           /* pointer into the right operand  */
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
    vecS = NEW_PLIST_WITH_MUTABILITY(
        IS_MUTABLE_OBJ(vecL) || IS_MUTABLE_OBJ(vecR), T_PLIST_CYC, len);
    SET_LEN_PLIST(vecS, len);

    /* loop over the elements and add                                      */
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrR = CONST_ADDR_OBJ(vecR);
    ptrS = ADDR_OBJ(vecS);
    for (i = 1; i <= lenmin; i++) {
        elmL = ptrL[i];
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! SUM_INTOBJS(elmS, elmL, elmR)) {
            elmS = SUM(elmL, elmR);
            ptrL = CONST_ADDR_OBJ(vecL);
            ptrR = CONST_ADDR_OBJ(vecR);
            ptrS = ADDR_OBJ(vecS);
            ptrS[i] = elmS;
            CHANGED_BAG(vecS);
        }
        else
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
static Obj DiffIntVector(Obj elmL, Obj vecR)
{
    Obj                 vecD;           /* handle of the difference        */
    Obj *               ptrD;           /* pointer into the difference     */
    Obj                 elmD;           /* one element of difference list  */
    const Obj *         ptrR;           /* pointer into the right operand  */
    Obj                 elmR;           /* one element of right operand    */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecD = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecR), T_PLIST_CYC, len);
    SET_LEN_PLIST(vecD, len);

    /* loop over the elements and subtract                                 */
    ptrR = CONST_ADDR_OBJ(vecR);
    ptrD = ADDR_OBJ(vecD);
    for (i = 1; i <= len; i++) {
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! DIFF_INTOBJS(elmD, elmL, elmR)) {
            elmD = DIFF(elmL, elmR);
            ptrR = CONST_ADDR_OBJ(vecR);
            ptrD = ADDR_OBJ(vecD);
            ptrD[i] = elmD;
            CHANGED_BAG(vecD);
        }
        else
            ptrD[i] = elmD;
    }

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
static Obj DiffVectorInt(Obj vecL, Obj elmR)
{
    Obj                 vecD;           /* handle of the difference        */
    Obj *               ptrD;           /* pointer into the difference     */
    Obj                 elmD;           /* one element of difference list  */
    const Obj *         ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecD = NEW_PLIST(TNUM_OBJ(vecL), len);
    SET_LEN_PLIST(vecD, len);

    /* loop over the elements and subtract                                 */
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrD = ADDR_OBJ(vecD);
    for (i = 1; i <= len; i++) {
        elmL = ptrL[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! DIFF_INTOBJS(elmD, elmL, elmR)) {
            elmD = DIFF(elmL, elmR);
            ptrL = CONST_ADDR_OBJ(vecL);
            ptrD = ADDR_OBJ(vecD);
            ptrD[i] = elmD;
            CHANGED_BAG(vecD);
        }
        else
            ptrD[i] = elmD;
    }

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
static Obj DiffVectorVector(Obj vecL, Obj vecR)
{
    Obj                 vecD;           /* handle of the sum               */
    Obj *               ptrD;           /* pointer into the sum            */
    Obj                 elmD;           /* one element of sum list         */
    const Obj *         ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    const Obj *         ptrR;           /* pointer into the right operand  */
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
    vecD = NEW_PLIST_WITH_MUTABILITY(
        IS_MUTABLE_OBJ(vecL) || IS_MUTABLE_OBJ(vecR), T_PLIST_CYC, len);
    SET_LEN_PLIST(vecD, len);

    /* loop over the elements and subtract                                   */
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrR = CONST_ADDR_OBJ(vecR);
    ptrD = ADDR_OBJ(vecD);
    for (i = 1; i <= lenmin; i++) {
        elmL = ptrL[i];
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! DIFF_INTOBJS(elmD, elmL, elmR)) {
            elmD = DIFF(elmL, elmR);
            ptrL = CONST_ADDR_OBJ(vecL);
            ptrR = CONST_ADDR_OBJ(vecR);
            ptrD = ADDR_OBJ(vecD);
            ptrD[i] = elmD;
            CHANGED_BAG(vecD);
        }
        else
            ptrD[i] = elmD;
    }
    if (lenL < lenR)
        for (; i <= lenR; i++) {
            elmR = ptrR[i];
            if (! IS_INTOBJ(elmR) || ! DIFF_INTOBJS(elmD, INTOBJ_INT(0), elmR)) {
                elmD = AINV(elmR);
                ptrR = CONST_ADDR_OBJ(vecR);
                ptrD = ADDR_OBJ(vecD);
                ptrD[i] = elmD;
                CHANGED_BAG(vecD);
            }
            else
                ptrD[i] = elmD;
        }
    else
        for (; i <= lenL; i++) {
            ptrD[i] = ptrL[i];
        }

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
static Obj ProdIntVector(Obj elmL, Obj vecR)
{
    Obj                 vecP;           /* handle of the product           */
    Obj *               ptrP;           /* pointer into the product        */
    Obj                 elmP;           /* one element of product list     */
    const Obj *         ptrR;           /* pointer into the right operand  */
    Obj                 elmR;           /* one element of right operand    */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecP = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecR), T_PLIST_CYC, len);
    SET_LEN_PLIST(vecP, len);

    /* loop over the entries and multiply                                  */
    ptrR = CONST_ADDR_OBJ(vecR);
    ptrP = ADDR_OBJ(vecP);
    for (i = 1; i <= len; i++) {
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! PROD_INTOBJS(elmP, elmL, elmR)) {
            elmP = PROD(elmL, elmR);
            ptrR = CONST_ADDR_OBJ(vecR);
            ptrP = ADDR_OBJ(vecP);
            ptrP[i] = elmP;
            CHANGED_BAG(vecP);
        }
        else
            ptrP[i] = elmP;
    }

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
static Obj ProdVectorInt(Obj vecL, Obj elmR)
{
    Obj                 vecP;           /* handle of the product           */
    Obj *               ptrP;           /* pointer into the product        */
    Obj                 elmP;           /* one element of product list     */
    const Obj *         ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecP = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecL), T_PLIST_CYC, len);
    SET_LEN_PLIST(vecP, len);

    /* loop over the entries and multiply                                  */
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrP = ADDR_OBJ(vecP);
    for (i = 1; i <= len; i++) {
        elmL = ptrL[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! PROD_INTOBJS(elmP, elmL, elmR)) {
            elmP = PROD(elmL, elmR);
            ptrL = CONST_ADDR_OBJ(vecL);
            ptrP = ADDR_OBJ(vecP);
            ptrP[i] = elmP;
            CHANGED_BAG(vecP);
        }
        else
            ptrP[i] = elmP;
    }

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
static Obj ProdVectorVector(Obj vecL, Obj vecR)
{
    Obj                 elmP;           /* product, result                 */
    Obj                 elmS;           /* partial sum of result           */
    Obj                 elmT;           /* one summand of result           */
    const Obj *         ptrL;           /* pointer into the left operand   */
    Obj                 elmL;           /* one element of left operand     */
    const Obj *         ptrR;           /* pointer into the right operand  */
    Obj                 elmR;           /* one element of right operand    */
    UInt                lenL, lenR, len; /* length                          */
    UInt                i;              /* loop variable                   */

    /* check that the lengths agree                                        */
    lenL = LEN_PLIST(vecL);
    lenR = LEN_PLIST(vecR);
    len = (lenL < lenR) ? lenL : lenR;

    /* loop over the entries and multiply                                  */
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrR = CONST_ADDR_OBJ(vecR);
    elmL = ptrL[1];
    elmR = ptrR[1];
    if (! ARE_INTOBJS(elmL, elmR) || ! PROD_INTOBJS(elmT, elmL, elmR)) {
        elmT = PROD(elmL, elmR);
        ptrL = CONST_ADDR_OBJ(vecL);
        ptrR = CONST_ADDR_OBJ(vecR);
    }
    elmP = elmT;
    for (i = 2; i <= len; i++) {
        elmL = ptrL[i];
        elmR = ptrR[i];
        if (! ARE_INTOBJS(elmL, elmR) || ! PROD_INTOBJS(elmT, elmL, elmR)) {
            elmT = PROD(elmL, elmR);
            ptrL = CONST_ADDR_OBJ(vecL);
            ptrR = CONST_ADDR_OBJ(vecR);
        }
        if (! ARE_INTOBJS(elmP, elmT) || ! SUM_INTOBJS(elmS, elmP, elmT)) {
            elmS = SUM(elmP, elmT);
            ptrL = CONST_ADDR_OBJ(vecL);
            ptrR = CONST_ADDR_OBJ(vecR);
        }
        elmP = elmS;
    }

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
static Obj ProdVectorMatrix(Obj vecL, Obj matR)
{
    Obj                 vecP;           /* handle of the product           */
    Obj *               ptrP;           /* pointer into the product        */
    Obj                 elmP;           /* one summand of product          */
    Obj                 elmS;           /* temporary for sum               */
    Obj                 elmT;           /* another temporary               */
    Obj                 elmL;           /* one element of left operand     */
    Obj                 vecR;           /* one vector of right operand     */
    const Obj *         ptrR;           /* pointer into the right vector   */
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

    vecP = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecL) || IS_MUTABLE_OBJ(ELM_PLIST(matR, 1)),
                         T_PLIST_CYC, col);
    SET_LEN_PLIST(vecP, col);
    for (i = 1; i <= col; i++)
        SET_ELM_PLIST(vecP, i, INTOBJ_INT(0));


    /* loop over the entries and multiply                            */
    for (i = 1; i <= len; i++) {
        elmL = ELM_PLIST(vecL, i);
        vecR = ELM_PLIST(matR, i);
        ptrR = CONST_ADDR_OBJ(vecR);
        ptrP = ADDR_OBJ(vecP);
        if (elmL == INTOBJ_INT(1)) {
            for (k = 1; k <= col; k++) {
                elmT = ptrR[k];
                elmP = ptrP[k];
                if (! ARE_INTOBJS(elmP, elmT)
                || ! SUM_INTOBJS(elmS, elmP, elmT)) {
                    elmS = SUM(elmP, elmT);
                    ptrR = CONST_ADDR_OBJ(vecR);
                    ptrP = ADDR_OBJ(vecP);
                    ptrP[k] = elmS;
                    CHANGED_BAG(vecP);
                }
                else
                    ptrP[k] = elmS;
            }
        }
        else if (elmL == INTOBJ_INT(-1)) {
            for (k = 1; k <= col; k++) {
                elmT = ptrR[k];
                elmP = ptrP[k];
                if (! ARE_INTOBJS(elmP, elmT)
                        || ! DIFF_INTOBJS(elmS, elmP, elmT)) {
                    elmS = DIFF(elmP, elmT);
                    ptrR = CONST_ADDR_OBJ(vecR);
                    ptrP = ADDR_OBJ(vecP);
                    ptrP[k] = elmS;
                    CHANGED_BAG(vecP);
                }
                else
                    ptrP[k] = elmS;

            }
        }
        else if (elmL != INTOBJ_INT(0)) {
            for (k = 1; k <= col; k++) {
                elmR = ptrR[k];
                if (elmR != INTOBJ_INT(0)) {
                    if (! ARE_INTOBJS(elmL, elmR)
                            || ! PROD_INTOBJS(elmT, elmL, elmR)) {
                        elmT = PROD(elmL, elmR);
                        ptrR = CONST_ADDR_OBJ(vecR);
                        ptrP = ADDR_OBJ(vecP);
                        elmP = ptrP[k];
                        CHANGED_BAG(vecP);
                    }
                    else
                        elmP = ptrP[k];
                    if (! ARE_INTOBJS(elmP, elmT)
                            || ! SUM_INTOBJS(elmS, elmP, elmT)) {
                        elmS = SUM(elmP, elmT);
                        ptrR = CONST_ADDR_OBJ(vecR);
                        ptrP = ADDR_OBJ(vecP);
                        ptrP[k] = elmS;
                        CHANGED_BAG(vecP);
                    }
                    else
                        ptrP[k] = elmS;
                }
            }
        }
    }

    return vecP;
}

static Obj FuncPROD_VECTOR_MATRIX(Obj self, Obj vec, Obj mat)
{
    return ProdVectorMatrix(vec, mat);
}

/****************************************************************************
**
*F  ZeroVector(<vec>) . . . . . . . . . . . . . . zero of a cyclotomic vector
**
**  'ZeroVector' returns the zero of the vector <vec>.
**
**  It is a better version of ZeroListDefault for the case of cyclotomic
**  vectors, because it knows what the cyclotomic zero is.
*/

static Obj ZeroVector(Obj vec)
{
    UInt i, len;
    Obj res;
    GAP_ASSERT(TNUM_OBJ(vec) >= T_PLIST_CYC &&
               TNUM_OBJ(vec) <= T_PLIST_CYC_SSORT + IMMUTABLE);
    len = LEN_PLIST(vec);
    res = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vec), T_PLIST_CYC, len);
    SET_LEN_PLIST(res, len);
    for (i = 1; i <= len; i++)
        SET_ELM_PLIST(res, i, INTOBJ_INT(0));
    return res;
}

static Obj ZeroMutVector(Obj vec)
{
    UInt i, len;
    Obj res;
    GAP_ASSERT(TNUM_OBJ(vec) >= T_PLIST_CYC &&
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
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

  GVAR_FUNC_2ARGS(PROD_VECTOR_MATRIX, vec, mat),
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

    return 0;
}


/****************************************************************************
**
*F  InitInfoVector()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "vector",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoVector ( void )
{
    return &module;
}
