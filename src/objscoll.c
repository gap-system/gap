/****************************************************************************
**
*W  objscoll.c                  GAP source                       Frank Celler
**                                                           & Werner  Nickel
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains a single collector for finite polycyclic groups, as
**  well as a combinatorial collector for finite p-groups.
**
**  Unfortunately there are quite a lot of stacks required by the collectors.
**  The collector functions will adjust the lists to have physical length
**  equal  to the maximum defined  in 'maxStackSize'.  Therefore it is
**  possible to initialise all stacks with an empty list.
**
**  There  are  also    two temporary   collector    vectors  'cwVector'  and
**  'cw2Vector',  the functions   'CXBits_VectorWord' will  adjust the string
**  length to  match the number of rws  generators.  Therefore it is possible
**  to initialise these  vectors with an  empty string.  WARNING: if  you use
**  such  a  vector, you *must* clear   it afterwards, because  all functions
**  assume that the vectors are cleared.
*/

#include "objscoll.h"

#include "bool.h"
#include "error.h"
#include "gapstate.h"
#include "gvars.h"
#include "lists.h"
#include "modules.h"
#include "objccoll.h"
#include "objfgelm.h"
#include "plist.h"
#include "stringobj.h"


/****************************************************************************
**
*F * * * * * * * * * * * * * module specific state  * * * * * * * * * * * * *
*/

struct CollectorsState {
    Obj  SC_NW_STACK;
    Obj  SC_LW_STACK;
    Obj  SC_PW_STACK;
    Obj  SC_EW_STACK;
    Obj  SC_GE_STACK;
    Obj  SC_CW_VECTOR;
    Obj  SC_CW2_VECTOR;
    UInt SC_MAX_STACK_SIZE;
};

static ModuleStateOffset CollectorsStateOffset = -1;

extern inline struct CollectorsState * CollectorsState(void)
{
    return (struct CollectorsState *)StateSlotsAtOffset(CollectorsStateOffset);
}


/****************************************************************************
**
*F * * * * * * * * * * * * local defines and typedefs * * * * * * * * * * * *
*/

static Obj TYPE_KERNEL_OBJECT;

/****************************************************************************
**
*T  FinPowConjCol
**
**  'FinPowConjCol' is a structure containing  all the functions depending on
**  the number of bits used in the a finite power/conjugate collector.
*/
typedef Int (*FuncIOOO)  (Obj,Obj,Obj);
typedef Obj (*FuncOOOI)  (Obj,Obj,Int);
typedef Int (*FuncIOOI)  (Obj,Obj,Int);
typedef Obj (*FuncOOOO)  (Obj,Obj,Obj);
typedef Int (*FuncIOOOF) (Obj,Obj,Obj,FuncIOOO);

typedef struct {

    FuncOOOI    wordVectorAndClear;
    FuncIOOI    vectorWord;
    FuncIOOO    collectWord;
    FuncIOOOF   solution;

} FinPowConjCol;


/****************************************************************************
**
*F * * * * * * * * * * * internal collector functions * * * * * * * * * * * *
*/

#define WordVectorAndClear  C8Bits_WordVectorAndClear
#define VectorWord          C8Bits_VectorWord
#define SingleCollectWord   C8Bits_SingleCollectWord
#define SAddWordIntoExpVec  C8Bits_SAddWordIntoExpVec
#define SAddPartIntoExpVec  C8Bits_SAddPartIntoExpVec
#define SingleCollectWord   C8Bits_SingleCollectWord
#define Solution            C8Bits_Solution
#define UIntN               UInt1
#include "objscoll-impl.h"

/****************************************************************************
**
*V  C8Bits_SingleCollector
*/
FinPowConjCol C8Bits_SingleCollector = {
    C8Bits_WordVectorAndClear,
    C8Bits_VectorWord,
    C8Bits_SingleCollectWord,
    C8Bits_Solution
};


#define WordVectorAndClear  C16Bits_WordVectorAndClear
#define VectorWord          C16Bits_VectorWord
#define SingleCollectWord   C16Bits_SingleCollectWord
#define SAddWordIntoExpVec  C16Bits_SAddWordIntoExpVec
#define SAddPartIntoExpVec  C16Bits_SAddPartIntoExpVec
#define SingleCollectWord   C16Bits_SingleCollectWord
#define Solution            C16Bits_Solution
#define UIntN               UInt2
#include "objscoll-impl.h"

/****************************************************************************
**
*V  C16Bits_SingleCollector
*/
FinPowConjCol C16Bits_SingleCollector = {
    C16Bits_WordVectorAndClear,
    C16Bits_VectorWord,
    C16Bits_SingleCollectWord,
    C16Bits_Solution
};


#define WordVectorAndClear  C32Bits_WordVectorAndClear
#define VectorWord          C32Bits_VectorWord
#define SingleCollectWord   C32Bits_SingleCollectWord
#define SAddWordIntoExpVec  C32Bits_SAddWordIntoExpVec
#define SAddPartIntoExpVec  C32Bits_SAddPartIntoExpVec
#define SingleCollectWord   C32Bits_SingleCollectWord
#define Solution            C32Bits_Solution
#define UIntN               UInt4
#include "objscoll-impl.h"

/****************************************************************************
**
*V  C32Bits_SingleCollector
*/
FinPowConjCol C32Bits_SingleCollector = {
    C32Bits_WordVectorAndClear,
    C32Bits_VectorWord,
    C32Bits_SingleCollectWord,
    C32Bits_Solution
};

/****************************************************************************
**
*F * * * * * * * * * * *  combinatorial collectors  * * * * * * * * * * * * *
**
**  Here the combinatorial collectors are set up.  They behave like single
**  collectors and therefore can be used in the same way.
*/

#define AddWordIntoExpVec   C8Bits_AddWordIntoExpVec
#define AddCommIntoExpVec   C8Bits_AddCommIntoExpVec
#define AddPartIntoExpVec   C8Bits_AddPartIntoExpVec
#define CombiCollectWord    C8Bits_CombiCollectWord
#define UIntN       UInt1
#include "objccoll-impl.h"

/****************************************************************************
**
*V  C8Bits_CombiCollector
*/
FinPowConjCol C8Bits_CombiCollector = {
    C8Bits_WordVectorAndClear,
    C8Bits_VectorWord,
    C8Bits_CombiCollectWord,
    C8Bits_Solution
};

#define AddWordIntoExpVec   C16Bits_AddWordIntoExpVec
#define AddCommIntoExpVec   C16Bits_AddCommIntoExpVec
#define AddPartIntoExpVec   C16Bits_AddPartIntoExpVec
#define CombiCollectWord    C16Bits_CombiCollectWord
#define UIntN       UInt2
#include "objccoll-impl.h"

/****************************************************************************
**
*V  C16Bits_CombiCollector
*/
FinPowConjCol C16Bits_CombiCollector = {
    C16Bits_WordVectorAndClear,
    C16Bits_VectorWord,
    C16Bits_CombiCollectWord,
    C16Bits_Solution
};

#define AddWordIntoExpVec   C32Bits_AddWordIntoExpVec
#define AddCommIntoExpVec   C32Bits_AddCommIntoExpVec
#define AddPartIntoExpVec   C32Bits_AddPartIntoExpVec
#define CombiCollectWord    C32Bits_CombiCollectWord
#define UIntN       UInt4
#include "objccoll-impl.h"

/****************************************************************************
**
*V  C32Bits_CombiCollector
*/
FinPowConjCol C32Bits_CombiCollector = {
    C32Bits_WordVectorAndClear,
    C32Bits_VectorWord,
    C32Bits_CombiCollectWord,
    C32Bits_Solution
};

/****************************************************************************
**
*V  FinPowConjCollectors
*/
FinPowConjCol * FinPowConjCollectors [6] =
{
#define C8Bits_SingleCollectorNo        0
       &C8Bits_SingleCollector,
#define C16Bits_SingleCollectorNo       1
       &C16Bits_SingleCollector,
#define C32Bits_SingleCollectorNo       2
       &C32Bits_SingleCollector,
#define C8Bits_CombiCollectorNo         3
       &C8Bits_CombiCollector,
#define C16Bits_CombiCollectorNo        4
       &C16Bits_CombiCollector,
#define C32Bits_CombiCollectorNo        5
       &C32Bits_CombiCollector
};

/****************************************************************************
**
*F * * * * * * * * * * * * reduce something functions * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  CollectWordOrFail( <fc>, <sc>, <vv>, <w> )
*/
Obj CollectWordOrFail ( 
    FinPowConjCol *     fc, 
    Obj                 sc,
    Obj                 vv,
    Obj                 w )
{
    Int                 i;              /* loop variable                   */
    Obj *               ptr;            /* pointer into the array <vv>     */

    /* convert <vv> into a list of C integers                              */
    ptr = ADDR_OBJ(vv)+1;
    for ( i = LEN_PLIST(vv);  0 < i;  i--, ptr++ )
        *ptr = (Obj)INT_INTOBJ(*ptr);

    /* now collect <w> into <vv>                                           */
    if ( fc->collectWord( sc, vv, w ) == -1 ) {
         /* If the collector fails, we return the vector clean.            */
        ptr = ADDR_OBJ(vv)+1;
        for ( i = LEN_PLIST(vv);  0 < i;  i--, ptr++ )
            *ptr = INTOBJ_INT(0);

        return Fail;
    }

    /* and convert back                                                    */
    ptr = ADDR_OBJ(vv)+1;
    for ( i = LEN_PLIST(vv);  0 < i;  i--, ptr++ )
        *ptr = INTOBJ_INT((Int)*ptr);

    return True;
}


/****************************************************************************
**
*F  ReducedComm( <fc>, <sc>, <w>, <u> )
*/
Obj ReducedComm (
    FinPowConjCol *     fc,
    Obj                 sc,
    Obj                 w,
    Obj                 u )
{
    Obj                 type;       /* type of the returned object         */
    Int                 num;        /* number of gen/exp pairs in <data>   */
    Int                 i;          /* loop variable for gen/exp pairs     */
    Obj                 vcw;        /* collect vector                      */
    Obj                 vc2;        /* collect vector                      */
    Int *               qtr;        /* pointer into the collect vector     */

    /* use 'cwVector' to collect word <u>*<w> to                           */
    vcw = CollectorsState()->SC_CW_VECTOR;
    num = SC_NUMBER_RWS_GENERATORS(sc);

    /* check that it has the correct length, unpack <u> into it            */
    if ( fc->vectorWord( vcw, u, num ) == -1 ) {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return Fail;
    }

    /* collect <w> into it                                                 */
    if ( fc->collectWord( sc, vcw, w ) == -1 ) {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return ReducedComm( fc, sc, w, u );
    }

    /* use 'cw2Vector' to collect word <w>*<u> to                          */
    vc2 = CollectorsState()->SC_CW2_VECTOR;

    /* check that it has the correct length, unpack <w> into it            */
    if ( fc->vectorWord( vc2, w, num ) == -1 ) {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vc2)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return Fail;
    }

    /* collect <u> into it                                                 */
    if ( fc->collectWord( sc, vc2, u ) == -1 ) {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vc2)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return ReducedComm( fc, sc, w, u );
    }

    /* now use 'Solution' to solve the equation, will clear <vcw>          */
    if ( fc->solution( sc, vcw, vc2, fc->collectWord ) == -1 )
    {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vc2)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return ReducedComm( fc, sc, w, u );
    }

    /* convert the vector <vc2> into a word and clear <vc2>                */
    type = SC_DEFAULT_TYPE(sc);
    return fc->wordVectorAndClear( type, vc2, num );
}


/****************************************************************************
**
*F  ReducedForm( <fc>, <sc>, <w> )
*/
Obj ReducedForm (
    FinPowConjCol *     fc,
    Obj                 sc,
    Obj                 w )
{
    Int                 num;    /* number of gen/exp pairs in <data>       */
    Int                 i;      /* loop variable for gen/exp pairs         */
    Obj                 vcw;    /* collect vector                          */
    Obj                 type;   /* type of the return objue                */
    Int *               qtr;    /* pointer into the collect vector         */

    /* use 'cwVector' to collect word <w> to                               */
    vcw = CollectorsState()->SC_CW_VECTOR;
    num = SC_NUMBER_RWS_GENERATORS(sc);

    /* check that it has the correct length                                */
    if ( fc->vectorWord( vcw, 0, num ) == -1 )
        return Fail;

    /* and collect <w> into it                                             */
    while ( (i = fc->collectWord( sc, vcw, w )) == -1 ) {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
    }
    num = i;

    /* get the default type                                                */
    type = SC_DEFAULT_TYPE(sc);

    /* convert the vector <cvw> into a word and clear <vcw>                */
    return fc->wordVectorAndClear( type, vcw, num );
}


/****************************************************************************
**
*F  ReducedLeftQuotient( <fc>, <sc>, <w>, <u> )
*/
Obj ReducedLeftQuotient ( 
    FinPowConjCol *     fc,
    Obj                 sc,
    Obj                 w,
    Obj                 u )
{
    Obj                 type;       /* type of the return objue            */
    Int                 num;        /* number of gen/exp pairs in <data>   */
    Int                 i;          /* loop variable for gen/exp pairs     */
    Obj                 vcw;        /* collect vector                      */
    Obj                 vc2;        /* collect vector                      */
    Int *               qtr;        /* pointer into the collect vector     */

    /* use 'cwVector' to collect word <w> to                               */
    vcw = CollectorsState()->SC_CW_VECTOR;
    num = SC_NUMBER_RWS_GENERATORS(sc);

    /* check that it has the correct length, unpack <w> into it            */
    if ( fc->vectorWord( vcw, w, num ) == -1 )  {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return Fail;
    }

    /* use 'cw2Vector' to collect word <u> to                              */
    vc2 = CollectorsState()->SC_CW2_VECTOR;

    /* check that it has the correct length, unpack <u> into it            */
    if ( fc->vectorWord( vc2, u, num ) == -1 ) {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vc2)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return Fail;
    }

    /* now use 'Solution' to solve the equation, will clear <vcw>          */
    if ( fc->solution( sc, vcw, vc2, fc->collectWord ) == -1 )
    {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vc2)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return ReducedLeftQuotient( fc, sc, w, u );
    }

    /* convert the vector <vc2> into a word and clear <vc2>                */
    type = SC_DEFAULT_TYPE(sc);
    return fc->wordVectorAndClear( type, vc2, num );
}


/****************************************************************************
**
*F  ReducedProduct( <fc>, <sc>, <w>, <u> )
*/
Obj ReducedProduct ( 
    FinPowConjCol *     fc,
    Obj                 sc,
    Obj                 w,
    Obj                 u )
{
    Obj                 type;       /* type of the return objue            */
    Int                 num;        /* number of gen/exp pairs in <data>   */
    Int                 i;          /* loop variable for gen/exp pairs     */
    Obj                 vcw;        /* collect vector                      */
    Int *               qtr;        /* pointer into the collect vector     */

    /* use 'cwVector' to collect word <w> to                               */
    vcw = CollectorsState()->SC_CW_VECTOR;
    num = SC_NUMBER_RWS_GENERATORS(sc);

    /* check that it has the correct length, unpack <w> into it            */
    if ( fc->vectorWord( vcw, w, num ) == -1 )  {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return Fail;
    }

    /* collect <w> into it                                                 */
    if ( fc->collectWord( sc, vcw, u ) == -1 ) {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return ReducedProduct( fc, sc, w, u );
    }

    /* convert the vector <vcw> into a word and clear <vcw>                */
    type = SC_DEFAULT_TYPE(sc);
    return fc->wordVectorAndClear( type, vcw, num );
}


/****************************************************************************
**
*F  ReducedPowerSmallInt( <fc>, <sc>, <w>, <pow> )
*/
Obj ReducedPowerSmallInt ( 
    FinPowConjCol *     fc,
    Obj                 sc,
    Obj                 w,
    Obj                 vpow )
{
    Obj                 type;       /* type of the return objue            */
    Int                 num;        /* number of gen/exp pairs in <data>   */
    Int                 i;          /* loop variable for gen/exp pairs     */
    Obj                 vcw;        /* collect vector                      */
    Obj                 vc2;        /* collect vector                      */
    Int                 pow;        /* power to raise <w> to               */
    Int *               qtr;        /* pointer into the collect vector     */
    Obj                 res;        /* the result                          */

    /* get the integer of <vpow>                                           */
    pow = INT_INTOBJ(vpow);

    /* use 'cwVector' and 'cw2Vector to collect words to                   */
    vcw  = CollectorsState()->SC_CW_VECTOR;
    vc2  = CollectorsState()->SC_CW2_VECTOR;
    num  = SC_NUMBER_RWS_GENERATORS(sc);
    type = SC_DEFAULT_TYPE(sc);

    /* return the trivial word if <pow> is zero                            */
    if ( pow == 0 ) {
        NEW_WORD( res, type, 0 );
        return res;
    }

    /* invert <w> if <pow> is negative                                     */
    if ( pow < 0 ) {
        
        /* check that it has the correct length, unpack <w> into it        */
        if ( fc->vectorWord( vcw, w, num ) == -1 )  {
            for ( i=num, qtr=(Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--,qtr++ )
                *qtr = 0;
            return Fail;
        }

        /* use 'Solution' to invert it, this will clear <vcw>              */
        if (fc->solution(sc,vcw,vc2,fc->collectWord) == -1) {
                for ( i=num, qtr=(Int*)(ADDR_OBJ(vcw)+1);  0<i;  i--,qtr++ )
                    *qtr = 0;
                for ( i=num, qtr=(Int*)(ADDR_OBJ(vc2)+1);  0<i;  i--,qtr++ )
                    *qtr = 0;
                return ReducedPowerSmallInt(fc,sc,w,vpow);
        }

        /* and replace <pow> and <w> by its inverse                        */
        pow  = -pow;
        vpow = INTOBJ_INT(pow);
        w    = fc->wordVectorAndClear( type, vc2, num );

    }

    /* if <pow> is one, do nothing                                         */
    if ( pow == 1 ) {
        return w;
    }

    /* catch small cases                                                   */
    if ( pow < 6 ) {

        /* check that it has the correct length, unpack <w> into it        */
        if ( fc->vectorWord( vcw, w, num ) == -1 )  {
            for ( i=num, qtr=(Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--,qtr++ )
                *qtr = 0;
            return Fail;
        }

        /* multiply <w> into <vcw>                                         */
        for ( i = pow;  1 < i;  i-- ) {
            if ( fc->collectWord( sc, vcw, w ) == -1 ) {
                for ( i=num, qtr=(Int*)(ADDR_OBJ(vcw)+1);  0<i;  i--,qtr++ )
                    *qtr = 0;
                return ReducedPowerSmallInt(fc,sc,w,vpow);
            }
        }

        /* convert it back, this will clear <vcw>                          */
        return fc->wordVectorAndClear( type, vcw, num );

    }

    /* use "divide et impera" instead of repeated squaring r2l             */
    if ( pow % 2 ) {
        res = ReducedPowerSmallInt( fc, sc, w, INTOBJ_INT((pow-1)/2) );
        return ReducedProduct( fc, sc, w,
            ReducedProduct( fc, sc, res, res ) );
    }
    else {
        res = ReducedPowerSmallInt( fc, sc, w, INTOBJ_INT(pow/2) );
        return ReducedProduct( fc, sc, res, res );
    }

}


/****************************************************************************
**
*F  ReducedQuotient( <fc>, <sc>, <w>, <u> )
*/
Obj ReducedQuotient ( 
    FinPowConjCol *     fc,
    Obj                 sc,
    Obj                 w,
    Obj                 u )
{
    Obj                 type;       /* type of the return objue            */
    Int                 num;        /* number of gen/exp pairs in <data>   */
    Int                 i;          /* loop variable for gen/exp pairs     */
    Obj                 vcw;        /* collect vector                      */
    Obj                 vc2;        /* collect vector                      */
    Int *               qtr;        /* pointer into the collect vector     */

    /* use 'cwVector' to collect word <w> to                               */
    vcw  = CollectorsState()->SC_CW_VECTOR;
    vc2  = CollectorsState()->SC_CW2_VECTOR;
    num  = SC_NUMBER_RWS_GENERATORS(sc);
    type = SC_DEFAULT_TYPE(sc);

    /* check that it has the correct length, unpack <u> into it            */
    if ( fc->vectorWord( vcw, u, num ) == -1 )  {
        for ( i=num, qtr=(Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--,qtr++ )
            *qtr = 0;
        return Fail;
    }

    /* use 'Solution' to invert it, this will clear <vcw>                  */
    if ( fc->solution( sc, vcw, vc2, fc->collectWord ) == -1 ) {
        for ( i=num, qtr=(Int*)(ADDR_OBJ(vcw)+1);  0<i;  i--,qtr++ )
            *qtr = 0;
        for ( i=num, qtr=(Int*)(ADDR_OBJ(vc2)+1);  0<i;  i--,qtr++ )
            *qtr = 0;
        return ReducedQuotient( fc, sc, w, u );
    }

    /* and replace <u> by its inverse                                      */
    u = fc->wordVectorAndClear( type, vc2, num );

    /* check that it has the correct length, unpack <w> into it            */
    if ( fc->vectorWord( vcw, w, num ) == -1 )  {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return Fail;
    }

    /* collect <w> into it                                                 */
    if ( fc->collectWord( sc, vcw, u ) == -1 ) {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return ReducedQuotient( fc, sc, w, u );
    }

    /* convert the vector <vcw> into a word and clear <vcw>                */
    return fc->wordVectorAndClear( type, vcw, num );
}


/****************************************************************************
**
*F * * * * * * * * * * * * * exported GAP functions * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FuncFinPowConjCol_CollectWordOrFail( <self>, <sc>, <vv>, <w> )
*/
Obj FuncFinPowConjCol_CollectWordOrFail ( Obj self, Obj sc, Obj vv, Obj w )
{
    return CollectWordOrFail( SC_COLLECTOR(sc), sc, vv, w );
}


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedComm( <self>, <sc>, <w>, <u> )
*/
Obj FuncFinPowConjCol_ReducedComm ( Obj self, Obj sc, Obj w, Obj u )
{
    return ReducedComm( SC_COLLECTOR(sc), sc, w, u );
}


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedForm( <self>, <sc>, <w> )
*/
Obj FuncFinPowConjCol_ReducedForm ( Obj self, Obj sc, Obj w )
{
    return ReducedForm( SC_COLLECTOR(sc), sc, w );
}


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedLeftQuotient( <self>, <sc>, <w>, <u> )
*/
Obj FuncFinPowConjCol_ReducedLeftQuotient ( Obj self, Obj sc, Obj w, Obj u )
{
    return ReducedLeftQuotient( SC_COLLECTOR(sc), sc, w, u );
}


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedProduct( <self>, <sc>, <w>, <u> )
*/
Obj FuncFinPowConjCol_ReducedProduct ( Obj self, Obj sc, Obj w, Obj u )
{
    return ReducedProduct( SC_COLLECTOR(sc), sc, w, u );
}


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedPowerSmallInt( <self>, <sc>, <w>, <pow> )
*/
Obj FuncFinPowConjCol_ReducedPowerSmallInt (Obj self,Obj sc,Obj w,Obj vpow)
{
    return ReducedPowerSmallInt( SC_COLLECTOR(sc), sc, w, vpow );
}


/****************************************************************************
**
*F  FuncFinPowConjCol_ReducedQuotient( <self>, <sc>, <w>, <u> )
*/
Obj FuncFinPowConjCol_ReducedQuotient ( Obj self, Obj sc, Obj w, Obj u )
{
    return ReducedQuotient( SC_COLLECTOR(sc), sc, w, u );
}


/****************************************************************************
**
*F  SET_SCOBJ_MAX_STACK_SIZE( <self>, <size> )
*/
Obj FuncSET_SCOBJ_MAX_STACK_SIZE ( Obj self, Obj size )
{
    if (IS_INTOBJ(size) && INT_INTOBJ(size) > 0)
        CollectorsState()->SC_MAX_STACK_SIZE = INT_INTOBJ(size);
    else
        ErrorQuit( "collect vector must be a positive small integer not a %s",
                   (Int)TNAM_OBJ(size), 0L );

    return 0;
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

    GVAR_FUNC(FinPowConjCol_CollectWordOrFail, 3, "sc, list, word"),
    GVAR_FUNC(FinPowConjCol_ReducedComm, 3, "sc, word, word"),
    GVAR_FUNC(FinPowConjCol_ReducedForm, 2, "sc, word"),
    GVAR_FUNC(FinPowConjCol_ReducedLeftQuotient, 3, "sc, word, word"),
    GVAR_FUNC(FinPowConjCol_ReducedPowerSmallInt, 3, "sc, word, int"),
    GVAR_FUNC(FinPowConjCol_ReducedProduct, 3, "sc, word, word"),
    GVAR_FUNC(FinPowConjCol_ReducedQuotient, 3, "sc, word, word"),
    GVAR_FUNC(SET_SCOBJ_MAX_STACK_SIZE, 1, "size"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitHdlrFuncsFromTable( GVarFuncs );

    ImportGVarFromLibrary( "TYPE_KERNEL_OBJECT", &TYPE_KERNEL_OBJECT );

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
    /* export position numbers 'SCP_SOMETHING'                             */
    ExportAsConstantGVar(SCP_UNDERLYING_FAMILY);
    ExportAsConstantGVar(SCP_RWS_GENERATORS);
    ExportAsConstantGVar(SCP_NUMBER_RWS_GENERATORS);
    ExportAsConstantGVar(SCP_DEFAULT_TYPE);
    ExportAsConstantGVar(SCP_IS_DEFAULT_TYPE);
    ExportAsConstantGVar(SCP_RELATIVE_ORDERS);
    ExportAsConstantGVar(SCP_POWERS);
    ExportAsConstantGVar(SCP_CONJUGATES);
    ExportAsConstantGVar(SCP_INVERSES);
    ExportAsConstantGVar(SCP_COLLECTOR);
    ExportAsConstantGVar(SCP_AVECTOR);
    ExportAsConstantGVar(SCP_WEIGHTS);
    ExportAsConstantGVar(SCP_CLASS);
    ExportAsConstantGVar(SCP_AVECTOR2);

    /* export collector number                                             */
    AssConstantGVar( GVarName( "8Bits_SingleCollector" ),
             INTOBJ_INT(C8Bits_SingleCollectorNo) );
    AssConstantGVar( GVarName( "16Bits_SingleCollector" ),
             INTOBJ_INT(C16Bits_SingleCollectorNo) );
    AssConstantGVar( GVarName( "32Bits_SingleCollector" ),
             INTOBJ_INT(C32Bits_SingleCollectorNo) );

    AssConstantGVar( GVarName( "8Bits_CombiCollector" ),
             INTOBJ_INT(C8Bits_CombiCollectorNo) );
    AssConstantGVar( GVarName( "16Bits_CombiCollector" ),
             INTOBJ_INT(C16Bits_CombiCollectorNo) );
    AssConstantGVar( GVarName( "32Bits_CombiCollector" ),
             INTOBJ_INT(C32Bits_CombiCollectorNo) );

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}

static Int InitModuleState(void)
{
#ifndef HPCGAP
    InitGlobalBag( &CollectorsState()->SC_NW_STACK, "SC_NW_STACK" );
    InitGlobalBag( &CollectorsState()->SC_LW_STACK, "SC_LW_STACK" );
    InitGlobalBag( &CollectorsState()->SC_PW_STACK, "SC_PW_STACK" );
    InitGlobalBag( &CollectorsState()->SC_EW_STACK, "SC_EW_STACK" );
    InitGlobalBag( &CollectorsState()->SC_GE_STACK, "SC_GE_STACK" );
    InitGlobalBag( &CollectorsState()->SC_CW_VECTOR, "SC_CW_VECTOR" );
    InitGlobalBag( &CollectorsState()->SC_CW2_VECTOR, "SC_CW2_VECTOR" );
#endif

    const UInt maxStackSize = 256;
    const UInt desiredStackSize = sizeof(Obj) * (maxStackSize + 2);
    CollectorsState()->SC_NW_STACK = NewBag(T_DATOBJ, desiredStackSize);
    CollectorsState()->SC_LW_STACK = NewBag(T_DATOBJ, desiredStackSize);
    CollectorsState()->SC_PW_STACK = NewBag(T_DATOBJ, desiredStackSize);
    CollectorsState()->SC_EW_STACK = NewBag(T_DATOBJ, desiredStackSize);
    CollectorsState()->SC_GE_STACK = NewBag(T_DATOBJ, desiredStackSize);

    SET_TYPE_DATOBJ(CollectorsState()->SC_NW_STACK, TYPE_KERNEL_OBJECT);
    SET_TYPE_DATOBJ(CollectorsState()->SC_LW_STACK, TYPE_KERNEL_OBJECT);
    SET_TYPE_DATOBJ(CollectorsState()->SC_PW_STACK, TYPE_KERNEL_OBJECT);
    SET_TYPE_DATOBJ(CollectorsState()->SC_EW_STACK, TYPE_KERNEL_OBJECT);
    SET_TYPE_DATOBJ(CollectorsState()->SC_GE_STACK, TYPE_KERNEL_OBJECT);

    CollectorsState()->SC_CW_VECTOR = NEW_STRING(0);
    CollectorsState()->SC_CW2_VECTOR = NEW_STRING(0);
    CollectorsState()->SC_MAX_STACK_SIZE = maxStackSize;

    // return success
    return 0;
}

/****************************************************************************
**
*F  InitInfoCollectors() . . . . . . . . . . . . . .  table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "objscoll",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,

    .moduleStateSize = sizeof(struct CollectorsState),
    .moduleStateOffsetPtr = &CollectorsStateOffset,
    .initModuleState = InitModuleState,
};

StructInitInfo * InitInfoCollectors ( void )
{
    return &module;
}
