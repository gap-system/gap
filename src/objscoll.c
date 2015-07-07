/****************************************************************************
**
*W  objscoll.c                  GAP source                       Frank Celler
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains a single collector for finite polycyclic groups.
**
**  Unfortunately, there  are quite a  lot of stacks  required  in the single
**  collector. The collector functions will adjust the lists to have physical
**  length equal  to the maximum defined  in 'maxStackSize'.  Therefore it is
**  possible to initialise all stacks with an empty list.
**
**  There  are  also    two temporary   collector    vectors  'cwVector'  and
**  'cw2Vector',  the functions   'CXBits_VectorWord' will  adjust the string
**  length to  match the number of rws  generators.  Therefore it is possible
**  to initialise these  vectors with an  empty string.  WARNING: if  you use
**  such  a  vector, you *must* clear   it afterwards, because  all functions
**  assume that the vectors are cleared.
*/
#include        "system.h"              /* Ints, UInts                     */


#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gvars.h"               /* global variables                */
#include        "gap.h"                 /* error handling, initialisation  */

#include        "calls.h"               /* generic call mechanism          */

#include        "records.h"             /* generic records                 */
#include        "lists.h"               /* generic lists                   */

#include        "bool.h"                /* booleans                        */

#include        "precord.h"             /* plain records                   */

#include        "plist.h"               /* plain lists                     */
#include        "string.h"              /* strings                         */

#include        "code.h"                /* coder                           */

#include        "tls.h"                 /* thread-local storage            */
#include        "objfgelm.h"            /* objects of free groups          */

#include        "objscoll.h"            /* single collector                */

#include        "objccoll.h"            /* combinatorial collector         */

/****************************************************************************
**

*F * * * * * * * * * * * * local defines and typedefs * * * * * * * * * * * *
*/

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

#define CB(x)       C8Bits_ ## x
#define UIntN       UInt1
#include "src/objscoll-8bit.h"

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


#define CB(x)       C16Bits_ ## x
#define UIntN       UInt2
#include "src/objscoll-16bit.h"

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


#define CB(x)       C32Bits_ ## x
#define UIntN       UInt4
#include "src/objscoll-32bit.h"

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
**  Here the combinatorial collectors are setup.  They behave like single
**  collectors and therefore can be used int the same way.
*/

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
    vcw = SC_CW_VECTOR(sc);
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
    vc2 = SC_CW2_VECTOR(sc);

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
    vcw = SC_CW_VECTOR(sc);
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
    vcw = SC_CW_VECTOR(sc);
    num = SC_NUMBER_RWS_GENERATORS(sc);

    /* check that it has the correct length, unpack <w> into it            */
    if ( fc->vectorWord( vcw, w, num ) == -1 )  {
        for ( i = num, qtr = (Int*)(ADDR_OBJ(vcw)+1);  0 < i;  i--, qtr++ )
            *qtr = 0;
        return Fail;
    }

    /* use 'cw2Vector' to collect word <u> to                              */
    vc2 = SC_CW2_VECTOR(sc);

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
    vcw = SC_CW_VECTOR(sc);
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
    vcw  = SC_CW_VECTOR(sc);
    vc2  = SC_CW2_VECTOR(sc);
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
    vcw  = SC_CW_VECTOR(sc);
    vc2  = SC_CW2_VECTOR(sc);
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
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "FinPowConjCol_CollectWordOrFail", 3, "sc, list, word",
      FuncFinPowConjCol_CollectWordOrFail, 
      "src/objscoll.c:FinPowConjCol_CollectWordOrFail" },

    { "FinPowConjCol_ReducedComm", 3, "sc, word, word",
      FuncFinPowConjCol_ReducedComm, 
      "src/objscoll.c:FinPowConjCol_ReducedComm" },

    { "FinPowConjCol_ReducedForm", 2, "sc, word",
      FuncFinPowConjCol_ReducedForm, 
      "src/objscoll.c:FinPowConjCol_ReducedForm" },

    { "FinPowConjCol_ReducedLeftQuotient", 3, "sc, word, word",
      FuncFinPowConjCol_ReducedLeftQuotient, 
      "src/objscoll.c:FinPowConjCol_ReducedLeftQuotient" },

    { "FinPowConjCol_ReducedPowerSmallInt", 3, "sc, word, int",
      FuncFinPowConjCol_ReducedPowerSmallInt,
      "src/objscoll.c:FinPowConjCol_ReducedPowerSmallInt" },

    { "FinPowConjCol_ReducedProduct", 3, "sc, word, word",
      FuncFinPowConjCol_ReducedProduct,
      "src/objscoll.c:FinPowConjCol_ReducedProduct" },

    { "FinPowConjCol_ReducedQuotient", 3, "sc, word, word",
      FuncFinPowConjCol_ReducedQuotient,
      "src/objscoll.c:FinPowConjCol_ReducedQuotient" },

    { 0 }

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
    AssGVar( GVarName( "SCP_UNDERLYING_FAMILY" ),
             INTOBJ_INT(SCP_UNDERLYING_FAMILY) );
    AssGVar( GVarName( "SCP_RWS_GENERATORS" ),
             INTOBJ_INT(SCP_RWS_GENERATORS) );
    AssGVar( GVarName( "SCP_NUMBER_RWS_GENERATORS" ),
             INTOBJ_INT(SCP_NUMBER_RWS_GENERATORS) );
    AssGVar( GVarName( "SCP_DEFAULT_TYPE" ),
             INTOBJ_INT(SCP_DEFAULT_TYPE) );
    AssGVar( GVarName( "SCP_IS_DEFAULT_TYPE" ),
             INTOBJ_INT(SCP_IS_DEFAULT_TYPE) );
    AssGVar( GVarName( "SCP_RELATIVE_ORDERS" ),
             INTOBJ_INT(SCP_RELATIVE_ORDERS) );
    AssGVar( GVarName( "SCP_POWERS" ),
             INTOBJ_INT(SCP_POWERS) );
    AssGVar( GVarName( "SCP_CONJUGATES" ),
             INTOBJ_INT(SCP_CONJUGATES) );
    AssGVar( GVarName( "SCP_INVERSES" ),
             INTOBJ_INT(SCP_INVERSES) );
    AssGVar( GVarName( "SCP_NW_STACK" ),
             INTOBJ_INT(SCP_NW_STACK) );
    AssGVar( GVarName( "SCP_LW_STACK" ),
             INTOBJ_INT(SCP_LW_STACK) );
    AssGVar( GVarName( "SCP_PW_STACK" ),
             INTOBJ_INT(SCP_PW_STACK) );
    AssGVar( GVarName( "SCP_EW_STACK" ),
             INTOBJ_INT(SCP_EW_STACK) );
    AssGVar( GVarName( "SCP_GE_STACK" ),
             INTOBJ_INT(SCP_GE_STACK) );
    AssGVar( GVarName( "SCP_CW_VECTOR" ),
             INTOBJ_INT(SCP_CW_VECTOR) );
    AssGVar( GVarName( "SCP_CW2_VECTOR" ),
             INTOBJ_INT(SCP_CW2_VECTOR) );
    AssGVar( GVarName( "SCP_MAX_STACK_SIZE" ),
             INTOBJ_INT(SCP_MAX_STACK_SIZE) );
    AssGVar( GVarName( "SCP_COLLECTOR" ),
             INTOBJ_INT(SCP_COLLECTOR) );
    AssGVar( GVarName( "SCP_AVECTOR" ),
             INTOBJ_INT(SCP_AVECTOR) );
    AssGVar( GVarName( "SCP_WEIGHTS" ),
             INTOBJ_INT(SCP_WEIGHTS) );
    AssGVar( GVarName( "SCP_CLASS" ),
             INTOBJ_INT(SCP_CLASS) );
    AssGVar( GVarName( "SCP_AVECTOR2" ),
             INTOBJ_INT(SCP_AVECTOR2) );

    /* export collector number                                             */
    AssGVar( GVarName( "8Bits_SingleCollector" ),
             INTOBJ_INT(C8Bits_SingleCollectorNo) );
    AssGVar( GVarName( "16Bits_SingleCollector" ),
             INTOBJ_INT(C16Bits_SingleCollectorNo) );
    AssGVar( GVarName( "32Bits_SingleCollector" ),
             INTOBJ_INT(C32Bits_SingleCollectorNo) );

    AssGVar( GVarName( "8Bits_CombiCollector" ),
             INTOBJ_INT(C8Bits_CombiCollectorNo) );
    AssGVar( GVarName( "16Bits_CombiCollector" ),
             INTOBJ_INT(C16Bits_CombiCollectorNo) );
    AssGVar( GVarName( "32Bits_CombiCollector" ),
             INTOBJ_INT(C32Bits_CombiCollectorNo) );

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoSingleCollector() . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "objscoll",                         /* name                           */
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

StructInitInfo * InitInfoSingleCollector ( void )
{
    return &module;
}


/****************************************************************************
**

*E  objscoll.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
