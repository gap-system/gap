/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
*/

#include "vecffe.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "error.h"
#include "finfield.h"
#include "gvars.h"
#include "listoper.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"


/****************************************************************************
**
*F  IsVecFFE(<obj>) . . . . . . . test if <obj> is a homogeneous list of FFEs
**
**  'IsVecFFE' returns 1 if <obj> is a dense and non-empty plain list, whose
**  elements are all finite field elements defined over the same field, and
**  otherwise returns 0.
**
**  One may think of this as an optimized special case of 'KTNumPlist'.
*/
static BOOL IsVecFFE(Obj obj)
{
    UInt tnum = TNUM_OBJ(obj);
    if (tnum == T_PLIST_FFE || tnum == T_PLIST_FFE + IMMUTABLE)
        return TRUE;

    // must be a plain list of length >= 1
    if (!IS_PLIST(obj) || LEN_PLIST(obj) == 0)
        return FALSE;

    Obj x = ELM_PLIST(obj, 1);
    if (!IS_FFE(x))
        return FALSE;

    const FF  fld = FLD_FFE(x);
    const Int len = LEN_PLIST(obj);
    for (Int i = 2; i <= len; i++) {
        x = ELM_PLIST(obj, i);
        if (!IS_FFE(x) || FLD_FFE(x) != fld)
            return FALSE;
    }
    RetypeBagSM(obj, T_PLIST_FFE);
    return TRUE;
}


/****************************************************************************
**
*F  SumFFEVecFFE(<elmL>,<vecR>) . . .  sum of a finite field elm and a vector
**
**  'SumFFEVecFFE' returns the sum of the fin field elm <elmL> and the vector
**  <vecR>.  The sum is a  list, where each element is  the sum of <elmL> and
**  the corresponding element of <vecR>.
**
**  'SumFFEVecFFE' is an improved version  of  'SumSclList', which  does  not
**  call 'SUM'.
*/
static Obj SumFFEVecFFE(Obj elmL, Obj vecR)
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    FFV                 valS;           /* the value of a sum              */
    const Obj *         ptrR;           /* pointer into the right operand  */
    FFV                 valR;           /* the value of an element in vecR */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    const FFV *         succ;           /* successor table                 */
    FFV                 valL;           /* the value of elmL               */

    /* get the field and check that elmL and vecR have the same field      */
    fld = FLD_FFE(ELM_PLIST(vecR, 1));
    if (FLD_FFE(elmL) != fld) {
        /* check the characteristic                                          */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmL)))
            return SumSclList(elmL, vecR);

        ErrorMayQuit("<elm>+<vec>: <elm> and <vec> must belong to the same "
                     "finite field",
                     0, 0);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecS = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecR), T_PLIST_FFE, len);
    SET_LEN_PLIST(vecS, len);

    /* to add we need the successor table                                  */
    succ = SUCC_FF(fld);

    /* loop over the elements and add                                      */
    valL = VAL_FFE(elmL);
    ptrR = CONST_ADDR_OBJ(vecR);
    ptrS = ADDR_OBJ(vecS);
    for (i = 1; i <= len; i++) {
        valR = VAL_FFE(ptrR[i]);
        valS = SUM_FFV(valL, valR, succ);
        ptrS[i] = NEW_FFE(fld, valS);
    }

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
static Obj SumVecFFEFFE(Obj vecL, Obj elmR)
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    const Obj *         ptrL;           /* pointer into the left operand   */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    const FFV *         succ;           /* successor table                 */
    FFV                 valR;           /* the value of elmR               */
    FFV                 valL;           /* the value of an element in vecL */
    FFV                 valS;           /* the value of a sum              */

    /* get the field and check that vecL and elmR have the same field      */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(elmR) != fld) {
        /* check the characteristic                                          */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmR)))
            return SumListScl(vecL, elmR);

        ErrorMayQuit("<vec>+<elm>: <elm> and <vec> must belong to the same "
                     "finite field",
                     0, 0);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecS = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecL), T_PLIST_FFE, len);
    SET_LEN_PLIST(vecS, len);

    /* to add we need the successor table                                  */
    succ = SUCC_FF(fld);

    /* loop over the elements and add                                      */
    valR = VAL_FFE(elmR);
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrS = ADDR_OBJ(vecS);
    for (i = 1; i <= len; i++) {
        valL = VAL_FFE(ptrL[i]);
        valS = SUM_FFV(valL, valR, succ);
        ptrS[i] = NEW_FFE(fld, valS);
    }

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
static Obj SumVecFFEVecFFE(Obj vecL, Obj vecR)
{
    Obj                 vecS;           /* handle of the sum               */
    Obj *               ptrS;           /* pointer into the sum            */
    FFV                 valS;           /* one element of sum list         */
    const Obj *         ptrL;           /* pointer into the left operand   */
    FFV                 valL;           /* one element of left operand     */
    const Obj *         ptrR;           /* pointer into the right operand  */
    FFV                 valR;           /* one element of right operand    */
    UInt                lenL, lenR, len; /* length                          */
    UInt                lenmin;
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    const FFV *         succ;           /* successor table                 */

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

        ErrorMayQuit("Vector +: vectors have different fields", 0, 0);
    }

    /* make the result list                                                */
    vecS = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecL) || IS_MUTABLE_OBJ(vecR),
                         T_PLIST_FFE, len);
    SET_LEN_PLIST(vecS, len);

    /* to add we need the successor table                                  */
    succ = SUCC_FF(fld);

    /* loop over the elements and add                                      */
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrR = CONST_ADDR_OBJ(vecR);
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
static Obj DiffFFEVecFFE(Obj elmL, Obj vecR)
{
    Obj                 vecD;           /* handle of the difference        */
    Obj *               ptrD;           /* pointer into the difference     */
    const Obj *         ptrR;           /* pointer into the right operand  */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    const FFV *         succ;           /* successor table                 */
    FFV                 valR;           /* the value of elmL               */
    FFV                 valL;           /* the value of an element in vecR */
    FFV                 valD;           /* the value of a difference       */

    /* check the fields                                                    */
    fld = FLD_FFE(ELM_PLIST(vecR, 1));
    if (FLD_FFE(elmL) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmL)))
            return DiffSclList(elmL, vecR);

        ErrorMayQuit("<elm>-<vec>: <elm> and <vec> must belong to the same "
                     "finite field",
                     0, 0);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecD = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecR), T_PLIST_FFE, len);
    SET_LEN_PLIST(vecD, len);

    /* to subtract we need the successor table                             */
    succ = SUCC_FF(fld);

    /* loop over the elements and subtract                                 */
    valL = VAL_FFE(elmL);
    ptrR = CONST_ADDR_OBJ(vecR);
    ptrD = ADDR_OBJ(vecD);
    for (i = 1; i <= len; i++) {
        valR = VAL_FFE(ptrR[i]);
        valR = NEG_FFV(valR, succ);
        valD = SUM_FFV(valL, valR, succ);
        ptrD[i] = NEW_FFE(fld, valD);
    }
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
static Obj DiffVecFFEFFE(Obj vecL, Obj elmR)
{
    Obj                 vecD;           /* handle of the difference        */
    Obj *               ptrD;           /* pointer into the difference     */
    FFV                 valD;           /* the value of a difference       */
    const Obj *         ptrL;           /* pointer into the left operand   */
    FFV                 valL;           /* the value of an element in vecL */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    const FFV *         succ;           /* successor table                 */
    FFV                 valR;           /* the value of elmR               */

    /* get the field and check that vecL and elmR have the same field      */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(elmR) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmR)))
            return DiffListScl(vecL, elmR);

        ErrorMayQuit("<vec>-<elm>: <elm> and <vec> must belong to the same "
                     "finite field",
                     0, 0);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecD = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecL), T_PLIST_FFE, len);
    SET_LEN_PLIST(vecD, len);

    /* to subtract we need the successor table                             */
    succ = SUCC_FF(fld);

    /* loop over the elements and subtract                                 */
    valR = VAL_FFE(elmR);
    valR = NEG_FFV(valR, succ);
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrD = ADDR_OBJ(vecD);
    for (i = 1; i <= len; i++) {
        valL = VAL_FFE(ptrL[i]);
        valD = SUM_FFV(valL, valR, succ);
        ptrD[i] = NEW_FFE(fld, valD);
    }

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
static Obj DiffVecFFEVecFFE(Obj vecL, Obj vecR)
{
    Obj                 vecD;           /* handle of the difference        */
    Obj *               ptrD;           /* pointer into the difference     */
    FFV                 valD;           /* one element of difference list  */
    const Obj *         ptrL;           /* pointer into the left operand   */
    FFV                 valL;           /* one element of left operand     */
    const Obj *         ptrR;           /* pointer into the right operand  */
    FFV                 valR;           /* one element of right operand    */
    UInt                len, lenL, lenR; /* length                          */
    UInt                lenmin;
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    const FFV *         succ;           /* successor table                 */

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

        ErrorMayQuit("Vector -: vectors have different fields", 0, 0);
    }

    /* make the result list                                                */
    vecD = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecL) || IS_MUTABLE_OBJ(vecR),
                         T_PLIST_FFE, len);
    SET_LEN_PLIST(vecD, len);

    /* to subtract we need the successor table                             */
    succ = SUCC_FF(fld);

    /* loop over the elements and subtract                                 */
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrR = CONST_ADDR_OBJ(vecR);
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
static Obj ProdFFEVecFFE(Obj elmL, Obj vecR)
{
    Obj                 vecP;           /* handle of the product           */
    Obj *               ptrP;           /* pointer into the product        */
    FFV                 valP;           /* the value of a product          */
    const Obj *         ptrR;           /* pointer into the right operand  */
    FFV                 valR;           /* the value of an element in vecR */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    const FFV *         succ;           /* successor table                 */
    FFV                 valL;           /* the value of elmL               */

    /* get the field and check that elmL and vecR have the same field      */
    fld = FLD_FFE(ELM_PLIST(vecR, 1));
    if (FLD_FFE(elmL) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmL)))
            return ProdSclList(elmL, vecR);

        ErrorMayQuit("<elm>*<vec>: <elm> and <vec> must belong to the same "
                     "finite field",
                     0, 0);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecR);
    vecP = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecR), T_PLIST_FFE, len);
    SET_LEN_PLIST(vecP, len);

    /* to multiply we need the successor table                             */
    succ = SUCC_FF(fld);

    /* loop over the elements and multiply                                 */
    valL = VAL_FFE(elmL);
    ptrR = CONST_ADDR_OBJ(vecR);
    ptrP = ADDR_OBJ(vecP);
    for (i = 1; i <= len; i++) {
        valR = VAL_FFE(ptrR[i]);
        valP = PROD_FFV(valL, valR, succ);
        ptrP[i] = NEW_FFE(fld, valP);
    }

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
static Obj ProdVecFFEFFE(Obj vecL, Obj elmR)
{
    Obj                 vecP;           /* handle of the product           */
    Obj *               ptrP;           /* pointer into the product        */
    FFV                 valP;           /* the value of a product          */
    const Obj *         ptrL;           /* pointer into the left operand   */
    FFV                 valL;           /* the value of an element in vecL */
    UInt                len;            /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    const FFV *         succ;           /* successor table                 */
    FFV                 valR;           /* the value of elmR               */

    /* get the field and check that vecL and elmR have the same field      */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(elmR) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(elmR)))
            return ProdListScl(vecL, elmR);

        ErrorMayQuit("<vec>*<elm>: <elm> and <vec> must belong to the same "
                     "finite field",
                     0, 0);
    }

    /* make the result list                                                */
    len = LEN_PLIST(vecL);
    vecP = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(vecL), T_PLIST_FFE, len);
    SET_LEN_PLIST(vecP, len);

    /* to multiply we need the successor table                             */
    succ = SUCC_FF(fld);

    /* loop over the elements and multiply                                 */
    valR = VAL_FFE(elmR);
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrP = ADDR_OBJ(vecP);
    for (i = 1; i <= len; i++) {
        valL = VAL_FFE(ptrL[i]);
        valP = PROD_FFV(valL, valR, succ);
        ptrP[i] = NEW_FFE(fld, valP);
    }

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
static Obj ProdVecFFEVecFFE(Obj vecL, Obj vecR)
{
    FFV                 valP;           /* one product                     */
    FFV                 valS;           /* sum of the products             */
    const Obj *         ptrL;           /* pointer into the left operand   */
    FFV                 valL;           /* one element of left operand     */
    const Obj *         ptrR;           /* pointer into the right operand  */
    FFV                 valR;           /* one element of right operand    */
    UInt                lenL, lenR, len; /* length                          */
    UInt                i;              /* loop variable                   */
    FF                  fld;            /* finite field                    */
    const FFV *         succ;           /* successor table                 */

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

        ErrorMayQuit("Vector *: vectors have different fields", 0, 0);
    }

    /* to add we need the successor table                                  */
    succ = SUCC_FF(fld);

    /* loop over the elements and add                                      */
    valS = (FFV)0;
    ptrL = CONST_ADDR_OBJ(vecL);
    ptrR = ADDR_OBJ(vecR);
    for (i = 1; i <= len; i++) {
        valL = VAL_FFE(ptrL[i]);
        valR = VAL_FFE(ptrR[i]);
        valP = PROD_FFV(valL, valR, succ);
        valS = SUM_FFV(valS, valP, succ);
    }

    return NEW_FFE(fld, valS);
}

/****************************************************************************
**
*F  FuncADD_ROWVECTOR_VECFFES_3( <self>, <vecL>, <vecR>, <mult> )
**
*/
static Obj FuncADD_ROWVECTOR_VECFFES_3(Obj self, Obj vecL, Obj vecR, Obj mult)
{
    Obj *ptrL;
    const Obj *ptrR;
    FFV  valM;
    FFV  valS;
    FFV  valL;
    FFV  valR;
    FF  fld;
    const FFV *succ;
    UInt len;
    UInt i;

    if (!IS_FFE(mult))
        return TRY_NEXT_METHOD;

    if (VAL_FFE(mult) == 0)
        return (Obj) 0;

    if (!IsVecFFE(vecL))
        return TRY_NEXT_METHOD;

    if (!IsVecFFE(vecR))
        return TRY_NEXT_METHOD;

    /* check the lengths                                                   */
    CheckSameLength("AddRowVector", "dst", "src", vecL, vecR);
    len = LEN_PLIST(vecL);

    /* check the fields                                                    */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(ELM_PLIST(vecR, 1)) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(ELM_PLIST(vecR, 1))))
            return TRY_NEXT_METHOD;

        ErrorMayQuit("AddRowVector: vectors have different fields", 0, 0);
    }

    /* Now check the multiplier field */
    if (FLD_FFE(mult) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) != CHAR_FF(FLD_FFE(mult))) {
            ErrorMayQuit("AddRowVector: <multiplier> has different field", 0, 0);
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
    ptrR = CONST_ADDR_OBJ(vecR);

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
*F  FuncMULT_VECTOR_VECFFES( <self>, <vec>, <mult> )
**
*/

static Obj FuncMULT_VECTOR_VECFFES(Obj self, Obj vec, Obj mult)
{
    Obj *ptr;
    FFV  valM;
    FFV  valS;
    FFV  val;
    FF  fld;
    const FFV *succ;
    UInt len;
    UInt i;

    if (!IS_FFE(mult))
        return TRY_NEXT_METHOD;

    if (VAL_FFE(mult) == 1)
        return (Obj) 0;

    if (!IsVecFFE(vec))
        return TRY_NEXT_METHOD;

    /* check the lengths                                                   */
    len = LEN_PLIST(vec);

    fld = FLD_FFE(ELM_PLIST(vec, 1));
    /* Now check the multiplier field */
    if (FLD_FFE(mult) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) != CHAR_FF(FLD_FFE(mult))) {
            ErrorMayQuit("MultVector: <multiplier> has different field", 0, 0);
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
*F  FuncADD_ROWVECTOR_VECFFES_2( <self>, <vecL>, <vecR> )
**
*/
static Obj FuncADD_ROWVECTOR_VECFFES_2(Obj self, Obj vecL, Obj vecR)
{
    Obj *ptrL;
    const Obj *ptrR;
    FFV  valS;
    FFV  valL;
    FFV  valR;
    FF  fld;
    const FFV *succ;
    UInt len;
    UInt i;

    if (!IsVecFFE(vecL))
        return TRY_NEXT_METHOD;

    if (!IsVecFFE(vecR))
        return TRY_NEXT_METHOD;

    /* check the lengths                                                   */
    CheckSameLength("AddRowVector", "dst", "src", vecL, vecR);
    len = LEN_PLIST(vecL);

    /* check the fields                                                    */
    fld = FLD_FFE(ELM_PLIST(vecL, 1));
    if (FLD_FFE(ELM_PLIST(vecR, 1)) != fld) {
        /* check the characteristic                                        */
        if (CHAR_FF(fld) == CHAR_FF(FLD_FFE(ELM_PLIST(vecR, 1))))
            return TRY_NEXT_METHOD;

        ErrorMayQuit("AddRowVector: vectors have different fields", 0, 0);
    }

    succ = SUCC_FF(fld);
    ptrL = ADDR_OBJ(vecL);
    ptrR = CONST_ADDR_OBJ(vecR);

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
*F  ZeroVecFFE(<vec>) . . . .  zero of an FFE Vector
**
**  'ZeroVecFEE' returns the zero of the vector <vec>.
**
**  It is a better version of ZeroListDefault for the case of vecffes
**  because it knows tha the zero is common and the result a vecffe
*/

static Obj ZeroMutVecFFE(Obj vec)
{
    UInt i, len;
    Obj res;
    Obj z;
    GAP_ASSERT(TNUM_OBJ(vec) >= T_PLIST_FFE &&
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

static Obj ZeroVecFFE(Obj vec)
{
    UInt i, len;
    Obj res;
    Obj z;
    GAP_ASSERT(TNUM_OBJ(vec) >= T_PLIST_FFE &&
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


static Obj FuncIS_VECFFE(Obj self, Obj vec)
{
    return IsVecFFE(vec) ? True : False;
}

static Obj FuncCOMMON_FIELD_VECFFE(Obj self, Obj vec)
{
    Obj elm;
    if (!IsVecFFE(vec))
        return Fail;
    elm = ELM_PLIST(vec, 1);
    return INTOBJ_INT(SIZE_FF(FLD_FFE(elm)));
}

static Obj FuncSMALLEST_FIELD_VECFFE(Obj self, Obj vec)
{
    Obj elm;
    UInt deg, deg1, deg2, i, len, p, q;
    BOOL isVecFFE;
    if (!IS_PLIST(vec))
        return Fail;
    isVecFFE = IsVecFFE(vec);
    len = LEN_PLIST(vec);
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
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_3ARGS(ADD_ROWVECTOR_VECFFES_3, vecl, vecr, mult),
    GVAR_FUNC_2ARGS(ADD_ROWVECTOR_VECFFES_2, vecl, vecr),
    GVAR_FUNC_2ARGS(MULT_VECTOR_VECFFES, vec, mult),
    GVAR_FUNC_1ARGS(IS_VECFFE, vec),
    GVAR_FUNC_1ARGS(COMMON_FIELD_VECFFE, vec),
    GVAR_FUNC_1ARGS(SMALLEST_FIELD_VECFFE, vec),
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
*F  InitInfoVecFFE()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "vecffe",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoVecFFE ( void )
{
    return &module;
}
