/****************************************************************************
**
*W  objpcgel.c                  GAP source                       Frank Celler
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
*/
#include <src/system.h>                 /* Ints, UInts */
#include <src/gapstate.h>


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gvars.h>                  /* global variables */
#include <src/gap.h>                    /* error handling, initialisation */

#include <src/calls.h>                  /* generic call mechanism */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */

#include <src/ariths.h>                 /* basic arithmetic */
#include <src/bool.h>                   /* booleans */

#include <src/code.h>                   /* coder */
#include <src/hpc/tls.h>                /* thread-local storage */
#include <src/objfgelm.h>               /* objects of free groups */
#include <src/objscoll.h>               /* single collector */

#include <src/objpcgel.h>               /* objects of polycyclic groups */

#include <src/hpc/tls.h>                /* thread-local storage */
#include <src/hpc/thread.h>             /* threads */


/****************************************************************************
**
*F * * * * * * * * * * * * * * *  boxed objects * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FuncLessBoxedObj( <self>, <left>, <right> )
*/
Obj FuncLessBoxedObj ( Obj self, Obj left, Obj right )
{
    return LT( ADDR_OBJ(left)[1], ADDR_OBJ(right)[1] ) ? False : True;
}


/****************************************************************************
**
*F  FuncEqualBoxedObj( <self>, <left>, <right> )
*/
Obj FuncEqualBoxedObj ( Obj self, Obj left, Obj right )
{
    return EQ( ADDR_OBJ(left)[1], ADDR_OBJ(right)[1] ) ? False : True;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * * pc word aspect * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FuncNBitsPcWord_Comm( <self>, <left>, <right> )
*/
Obj FuncNBitsPcWord_Comm ( Obj self, Obj left, Obj right )
{
    return FuncFinPowConjCol_ReducedComm(
        self, COLLECTOR_PCWORD(left), left, right );
}


/****************************************************************************
**
*F  FuncNBitsPcWord_Conjugate( <self>, <left>, <right> )
*/
Obj FuncNBitsPcWord_Conjugate ( Obj self, Obj left, Obj right )
{
    left = FuncFinPowConjCol_ReducedProduct(
                self, COLLECTOR_PCWORD(left), left, right );
    return FuncFinPowConjCol_ReducedLeftQuotient(
                self, COLLECTOR_PCWORD(left), right, left );
}


/****************************************************************************
**
*F  FuncNBitsPcWord_LeftQuotient( <self>, <left>, <right> )
*/
Obj FuncNBitsPcWord_LeftQuotient ( Obj self, Obj left, Obj right )
{
    return FuncFinPowConjCol_ReducedLeftQuotient(
        self, COLLECTOR_PCWORD(left), left, right );
}


/****************************************************************************
**
*F  FuncNBitsPcWord_PowerSmallInt( <self>, <left>, <right> )
*/
Obj FuncNBitsPcWord_PowerSmallInt ( Obj self, Obj left, Obj right )
{
    return FuncFinPowConjCol_ReducedPowerSmallInt(
        self, COLLECTOR_PCWORD(left), left, right );
}


/****************************************************************************
**
*F  FuncNBitsPcWord_Product( <self>, <left>, <right> )
*/
Obj FuncNBitsPcWord_Product ( Obj self, Obj left, Obj right )
{
    return FuncFinPowConjCol_ReducedProduct(
        self, COLLECTOR_PCWORD(left), left, right );
}


/****************************************************************************
**
*F  FuncNBitsPcWord_Quotient( <self>, <left>, <right> )
*/
Obj FuncNBitsPcWord_Quotient ( Obj self, Obj left, Obj right )
{
    return FuncFinPowConjCol_ReducedQuotient(
        self, COLLECTOR_PCWORD(left), left, right );
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * free word aspect * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  Func8Bits_DepthOfPcElement( <self>, <pcgs>, <w> )
*/
Obj Func8Bits_DepthOfPcElement ( Obj self, Obj pcgs, Obj w )
{
    Int         ebits;          /* number of bits in the exponent          */

    /* if the pc element is the identity we have to ask the pcgs           */
    if ( NPAIRS_WORD(w) == 0 )
        return INTOBJ_INT( LEN_LIST(pcgs) + 1 );

    /* otherwise it is the generators number of the first syllable         */
    else {
        ebits = EBITS_WORD(w);
        return INTOBJ_INT(((((UInt1*)DATA_WORD(w))[0]) >> ebits)+1);
    }
}


/****************************************************************************
**
*F  Func8Bits_ExponentOfPcElement( <self>, <pcgs>, <w>, <pos> )
*/
Obj Func8Bits_ExponentOfPcElement ( Obj self, Obj pcgs, Obj w, Obj pos )
{
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        ebits;          /* number of exponent bits                 */
    UInt        npos;           /* the wanted generator number             */
    UInt        num;            /* number of syllables in <w>              */
    UInt1 *     ptr;            /* pointer to the syllables of <w>         */
    UInt        i;              /* loop                                    */
    UInt        gen;            /* current generator number                */

    /* all exponents are zero if the pc element if the identity            */
    num = NPAIRS_WORD(w);
    if ( num == 0 )
        return INTOBJ_INT(0);

    /* otherwise find the syllable belonging to <exp>                      */
    else {
        ebits = EBITS_WORD(w);
        exps  = 1UL << (ebits-1);
        expm  = exps - 1;
        npos  = INT_INTOBJ(pos);
        ptr   = ((UInt1*)DATA_WORD(w));
        for ( i = 1;  i <= num;  i++, ptr++ ) {
            gen = ((*ptr) >> ebits) + 1;
            if ( gen == npos ) {
                if ( (*ptr) & exps )
                    return INTOBJ_INT(((*ptr)&expm)-exps);
                else
                    return INTOBJ_INT((*ptr)&expm);
            }
            if ( npos < gen )
                return INTOBJ_INT(0);
        }
        return INTOBJ_INT(0);
    }
}


/****************************************************************************
**
*F  Func8Bits_LeadingExponentOfPcElement( <self>, <pcgs>, <w> )
*/
Obj Func8Bits_LeadingExponentOfPcElement ( Obj self, Obj pcgs, Obj w )
{
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt1       p;              /* first syllable                          */

    /* the leading exponent is zero iff the pc element if the identity     */
    if ( NPAIRS_WORD(w) == 0 )
        return Fail;

    /* otherwise it is the exponent of the first syllable                  */
    else {
        exps = 1UL << (EBITS_WORD(w)-1);
        expm = exps - 1;
        p = ((UInt1*)DATA_WORD(w))[0];
        if ( p & exps )
            return INTOBJ_INT((p&expm)-exps);
        else
            return INTOBJ_INT(p&expm);
    }
}

/****************************************************************************
**
*F  Func8Bits_ExponentsOfPcElement( <self>, <pcgs>, <w> )
*/
Obj Func8Bits_ExponentsOfPcElement ( Obj self, Obj pcgs, Obj w)
{
    UInt	len;		/* length of pcgs */
    Obj		el;		/* exponents list */
    UInt        le;
    UInt	indx;
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        ebits;          /* number of exponent bits                 */
 /* UInt        npos;           / the wanted generator number             */
    UInt        num;            /* number of syllables in <w>              */
    UInt1 *     ptr;            /* pointer to the syllables of <w>         */
    UInt        i,j;            /* loop                                    */
    UInt        gen;            /* current generator number                */

    len=LEN_LIST(pcgs);
    el=NEW_PLIST(T_PLIST_CYC,len);
    SET_LEN_PLIST(el,len);

    /* Check if the exponent vector is the empty list. */
    if( len == 0 ) { RetypeBag( el, T_PLIST_EMPTY ); return el; }

    indx=1; /* current index in el we assign to */
    num = NPAIRS_WORD(w);

    le=1; /* last exponent which has been assigned+1 */

    ebits = EBITS_WORD(w);
    exps  = 1UL << (ebits-1);
    expm  = exps - 1;

    ptr   = ((UInt1*)DATA_WORD(w));
    for ( i = 1;  i <= num;  i++, ptr++ ) {
      gen = ((*ptr) >> ebits) + 1;
      for (j=le; j< gen;j++) {
        /* zero out intermediate entries */
	SET_ELM_PLIST(el,indx,INTOBJ_INT(0));
	indx++;
      }

      if ( (*ptr) & exps )
	  SET_ELM_PLIST(el,indx,INTOBJ_INT(((*ptr)&expm)-exps));
      else
	  SET_ELM_PLIST(el,indx,INTOBJ_INT((*ptr)&expm));
      indx++;
      le=gen+1;
    }

    /* zeroes at the end */
    for (j=le; j<=len;j++) {
      /* zero out  */
      SET_ELM_PLIST(el,indx,INTOBJ_INT(0));
      indx++;
    }

    CHANGED_BAG(el);
    return el;
}


/****************************************************************************
**
*F  Func16Bits_DepthOfPcElement( <self>, <pcgs>, <w> )
*/
Obj Func16Bits_DepthOfPcElement ( Obj self, Obj pcgs, Obj w )
{
    Int         ebits;          /* number of bits in the exponent          */

    /* if the pc element is the identity we have to ask the pcgs           */
    if ( NPAIRS_WORD(w) == 0 )
        return INTOBJ_INT( LEN_LIST(pcgs) + 1 );

    /* otherwise it is the generators number of the first syllable         */
    else {
        ebits = EBITS_WORD(w);
        return INTOBJ_INT(((((UInt2*)DATA_WORD(w))[0]) >> ebits)+1);
    }
}


/****************************************************************************
**
*F  Func16Bits_ExponentOfPcElement( <self>, <pcgs>, <w>, <pos> )
*/
Obj Func16Bits_ExponentOfPcElement ( Obj self, Obj pcgs, Obj w, Obj pos )
{
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        ebits;          /* number of exponent bits                 */
    UInt        npos;           /* the wanted generator number             */
    UInt        num;            /* number of syllables in <w>              */
    UInt2 *     ptr;            /* pointer to the syllables of <w>         */
    UInt        i;              /* loop                                    */
    UInt        gen;            /* current generator number                */

    /* all exponents are zero if the pc element if the identity            */
    num = NPAIRS_WORD(w);
    if ( num == 0 )
        return INTOBJ_INT(0);

    /* otherwise find the syllable belonging to <exp>                      */
    else {
        ebits = EBITS_WORD(w);
        exps  = 1UL << (ebits-1);
        expm  = exps - 1;
        npos  = INT_INTOBJ(pos);
        ptr   = ((UInt2*)DATA_WORD(w));
        for ( i = 1;  i <= num;  i++, ptr++ ) {
            gen = ((*ptr) >> ebits) + 1;
            if ( gen == npos ) {
                if ( (*ptr) & exps )
                    return INTOBJ_INT(((*ptr)&expm)-exps);
                else
                    return INTOBJ_INT((*ptr)&expm);
            }
            if ( npos < gen )
                return INTOBJ_INT(0);
        }
        return INTOBJ_INT(0);
    }
}


/****************************************************************************
**
*F  Func16Bits_LeadingExponentOfPcElement( <self>, <pcgs>, <w> )
*/
Obj Func16Bits_LeadingExponentOfPcElement ( Obj self, Obj pcgs, Obj w )
{
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt2       p;              /* first syllable                          */

    /* the leading exponent is zero iff the pc element if the identity     */
    if ( NPAIRS_WORD(w) == 0 )
        return Fail;

    /* otherwise it is the exponent of the first syllable                  */
    else {
        exps = 1UL << (EBITS_WORD(w)-1);
        expm = exps - 1;
        p = ((UInt2*)DATA_WORD(w))[0];
        if ( p & exps )
            return INTOBJ_INT((p&expm)-exps);
        else
            return INTOBJ_INT(p&expm);
    }
}

/****************************************************************************
**
*F  Func16Bits_ExponentsOfPcElement( <self>, <pcgs>, <w> )
*/
Obj Func16Bits_ExponentsOfPcElement ( Obj self, Obj pcgs, Obj w)
{
    UInt	len;		/* length of pcgs */
    Obj		el;		/* exponents list */
    UInt        le;
    UInt	indx;
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        ebits;          /* number of exponent bits                 */
 /* UInt        npos;           / the wanted generator number             */
    UInt        num;            /* number of syllables in <w>              */
    UInt2 *     ptr;            /* pointer to the syllables of <w>         */
    UInt        i,j;            /* loop                                    */
    UInt        gen;            /* current generator number                */

    len=LEN_LIST(pcgs);
    el=NEW_PLIST(T_PLIST_CYC,len);
    SET_LEN_PLIST(el,len);

    /* Check if the exponent vector is the empty list. */
    if( len == 0 ) { RetypeBag( el, T_PLIST_EMPTY ); return el; }

    indx=1; /* current index in el we assign to */
    num = NPAIRS_WORD(w);

    le=1; /* last exponent which has been assigned+1 */

    ebits = EBITS_WORD(w);
    exps  = 1UL << (ebits-1);
    expm  = exps - 1;

    ptr   = ((UInt2*)DATA_WORD(w));
    for ( i = 1;  i <= num;  i++, ptr++ ) {
      gen = ((*ptr) >> ebits) + 1;
      for (j=le; j< gen;j++) {
        /* zero out intermediate entries */
	SET_ELM_PLIST(el,indx,INTOBJ_INT(0));
	indx++;
      }

      if ( (*ptr) & exps )
	  SET_ELM_PLIST(el,indx,INTOBJ_INT(((*ptr)&expm)-exps));
      else
	  SET_ELM_PLIST(el,indx,INTOBJ_INT((*ptr)&expm));
      indx++;
      le=gen+1;
    }

    /* zeroes at the end */
    for (j=le; j<=len;j++) {
      /* zero out  */
      SET_ELM_PLIST(el,indx,INTOBJ_INT(0));
      indx++;
    }

    CHANGED_BAG(el);
    return el;
}


/****************************************************************************
**
*F  Func32Bits_DepthOfPcElement( <self>, <pcgs>, <w> )
*/
Obj Func32Bits_DepthOfPcElement ( Obj self, Obj pcgs, Obj w )
{
    Int         ebits;          /* number of bits in the exponent          */

    /* if the pc element is the identity we have to ask the pcgs           */
    if ( NPAIRS_WORD(w) == 0 )
        return INTOBJ_INT( LEN_LIST(pcgs) + 1 );

    /* otherwise it is the generators number of the first syllable         */
    else {
        ebits = EBITS_WORD(w);
        return INTOBJ_INT(((((UInt4*)DATA_WORD(w))[0]) >> ebits)+1);
    }
}


/****************************************************************************
**
*F  Func32Bits_ExponentOfPcElement( <self>, <pcgs>, <w>, <pos> )
*/
Obj Func32Bits_ExponentOfPcElement ( Obj self, Obj pcgs, Obj w, Obj pos )
{
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        ebits;          /* number of exponent bits                 */
    UInt        npos;           /* the wanted generator number             */
    UInt        num;            /* number of syllables in <w>              */
    UInt4 *     ptr;            /* pointer to the syllables of <w>         */
    UInt        i;              /* loop                                    */
    UInt        gen;            /* current generator number                */

    /* all exponents are zero if the pc element if the identity            */
    num = NPAIRS_WORD(w);
    if ( num == 0 )
        return INTOBJ_INT(0);

    /* otherwise find the syllable belonging to <exp>                      */
    else {
        ebits = EBITS_WORD(w);
        exps  = 1UL << (ebits-1);
        expm  = exps - 1;
        npos  = INT_INTOBJ(pos);
        ptr   = ((UInt4*)DATA_WORD(w));
        for ( i = 1;  i <= num;  i++, ptr++ ) {
            gen = ((*ptr) >> ebits) + 1;
            if ( gen == npos ) {
                if ( (*ptr) & exps )
                    return INTOBJ_INT(((*ptr)&expm)-exps);
                else
                    return INTOBJ_INT((*ptr)&expm);
            }
            if ( npos < gen )
                return INTOBJ_INT(0);
        }
        return INTOBJ_INT(0);
    }
}


/****************************************************************************
**
*F  Func32Bits_LeadingExponentOfPcElement( <self>, <pcgs>, <w> )
*/
Obj Func32Bits_LeadingExponentOfPcElement ( Obj self, Obj pcgs, Obj w )
{
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt4       p;              /* first syllable                          */

    /* the leading exponent is zero iff the pc element if the identity     */
    if ( NPAIRS_WORD(w) == 0 )
        return Fail;

    /* otherwise it is the exponent of the first syllable                  */
    else {
        exps = 1UL << (EBITS_WORD(w)-1);
        expm = exps - 1;
        p = ((UInt4*)DATA_WORD(w))[0];
        if ( p & exps )
            return INTOBJ_INT((p&expm)-exps);
        else
            return INTOBJ_INT(p&expm);
    }
}

/****************************************************************************
**
*F  Func32Bits_ExponentsOfPcElement( <self>, <pcgs>, <w> )
*/
Obj Func32Bits_ExponentsOfPcElement ( Obj self, Obj pcgs, Obj w)
{
    UInt	len;		/* length of pcgs */
    Obj		el;		/* exponents list */
    UInt        le;
    UInt	indx;
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        ebits;          /* number of exponent bits                 */
/*  UInt        npos;           / the wanted generator number             */
    UInt        num;            /* number of syllables in <w>              */
    UInt4 *     ptr;            /* pointer to the syllables of <w>         */
    UInt        i,j;            /* loop                                    */
    UInt        gen;            /* current generator number                */

    len=LEN_LIST(pcgs);
    el=NEW_PLIST(T_PLIST_CYC,len);
    SET_LEN_PLIST(el,len);

    /* Check if the exponent vector is the empty list. */
    if( len == 0 ) { RetypeBag( el, T_PLIST_EMPTY ); return el; }

    indx=1; /* current index in el we assign to */
    num = NPAIRS_WORD(w);

    le=1; /* last exponent which has been assigned+1 */

    ebits = EBITS_WORD(w);
    exps  = 1UL << (ebits-1);
    expm  = exps - 1;

    ptr   = ((UInt4*)DATA_WORD(w));
    for ( i = 1;  i <= num;  i++, ptr++ ) {
      gen = ((*ptr) >> ebits) + 1;
      for (j=le; j< gen;j++) {
        /* zero out intermediate entries */
	SET_ELM_PLIST(el,indx,INTOBJ_INT(0));
	indx++;
      }

      if ( (*ptr) & exps )
	  SET_ELM_PLIST(el,indx,INTOBJ_INT(((*ptr)&expm)-exps));
      else
	  SET_ELM_PLIST(el,indx,INTOBJ_INT((*ptr)&expm));
      indx++;
      le=gen+1;
    }

    /* zeroes at the end */
    for (j=le; j<=len;j++) {
      /* zero out  */
      SET_ELM_PLIST(el,indx,INTOBJ_INT(0));
      indx++;
    }

    CHANGED_BAG(el);
    return el;
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

    { "LessBoxedObj", 2, "lobj, lobj",
      FuncLessBoxedObj, "src/objpcgel.c:LessBoxedObj" },

    { "EqualBoxedObj", 2, "lobj, lobj",
      FuncEqualBoxedObj, "src/objpcgel.c:EqualBoxedObj" },

    { "NBitsPcWord_Comm", 2, "n_bits_pcword, n_bits_pcword",
      FuncNBitsPcWord_Comm, "src/objpcgel.c:NBitsPcWord_Comm" },

    { "NBitsPcWord_Conjugate", 2, "n_bits_pcword, n_bits_pcword",
      FuncNBitsPcWord_Conjugate, "src/objpcgel.c:NBitsPcWord_Conjugate" },

    { "NBitsPcWord_LeftQuotient", 2, "n_bits_pcword, n_bits_pcword",
      FuncNBitsPcWord_LeftQuotient, "src/objpcgel.c:NBitsPcWord_LeftQuotient" },

    { "NBitsPcWord_PowerSmallInt", 2, "n_bits_pcword, small_integer",
      FuncNBitsPcWord_PowerSmallInt, "src/objpcgel.c:NBitsPcWord_PowerSmallInt" },

    { "NBitsPcWord_Product", 2, "n_bits_pcword, n_bits_pcword",
      FuncNBitsPcWord_Product, "src/objpcgel.c:NBitsPcWord_Product" },

    { "NBitsPcWord_Quotient", 2, "n_bits_pcword, n_bits_pcword",
      FuncNBitsPcWord_Quotient, "src/objpcgel.c:NBitsPcWord_Quotient" },

    { "8Bits_DepthOfPcElement", 2, "8_bits_pcgs, 8_bits_pcword",
      Func8Bits_DepthOfPcElement, "src/objpcgel.c:8Bits_DepthOfPcElement" },

    { "8Bits_ExponentOfPcElement", 3, "8_bits_pcgs, 8_bits_pcword, int",
      Func8Bits_ExponentOfPcElement, "src/objpcgel.c:8Bits_ExponentOfPcElement" },

    { "8Bits_LeadingExponentOfPcElement", 2, "8_bits_pcgs, 8_bits_word",
      Func8Bits_LeadingExponentOfPcElement, "src/objpcgel.c:8Bits_LeadingExponentOfPcElement" },

    { "8Bits_ExponentsOfPcElement", 2, "8_bits_pcgs, 8_bits_pcword",
      Func8Bits_ExponentsOfPcElement, "src/objpcgel.c:8Bits_ExponentsOfPcElement" },

    { "16Bits_DepthOfPcElement", 2, "16_bits_pcgs, 16_bits_pcword",
      Func16Bits_DepthOfPcElement, "src/objpcgel.c:16Bits_DepthOfPcElement" },

    { "16Bits_ExponentOfPcElement", 3, "16_bits_pcgs, 16_bits_pcword, int",
      Func16Bits_ExponentOfPcElement, "src/objpcgel.c:16Bits_ExponentOfPcElement" },

    { "16Bits_LeadingExponentOfPcElement", 2, "16_bits_pcgs, 16_bits_word",
      Func16Bits_LeadingExponentOfPcElement, "src/objpcgel.c:16Bits_LeadingExponentOfPcElement" },

    { "16Bits_ExponentsOfPcElement", 2, "16_bits_pcgs, 16_bits_pcword",
      Func16Bits_ExponentsOfPcElement, "src/objpcgel.c:16Bits_ExponentsOfPcElement" },

    { "32Bits_DepthOfPcElement", 2, "32_bits_pcgs, 32_bits_pcword",
      Func32Bits_DepthOfPcElement, "src/objpcgel.c:32Bits_DepthOfPcElement" },

    { "32Bits_ExponentOfPcElement", 3, "32_bits_pcgs, 32_bits_pcword, int",
      Func32Bits_ExponentOfPcElement, "src/objpcgel.c:32Bits_ExponentOfPcElement" },

    { "32Bits_LeadingExponentOfPcElement", 2, "32_bits_pcgs, 32_bits_word",
      Func32Bits_LeadingExponentOfPcElement, "src/objpcgel.c:32Bits_LeadingExponentOfPcElement" },

    { "32Bits_ExponentsOfPcElement", 2, "32_bits_pcgs, 32_bits_pcword",
      Func32Bits_ExponentsOfPcElement, "src/objpcgel.c:32Bits_ExponentsOfPcElement" },

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
    /* export position numbers 'PCWP_SOMETHING'                            */
    AssGVar( GVarName( "PCWP_FIRST_ENTRY" ),
             INTOBJ_INT(PCWP_FIRST_ENTRY) );
    AssGVar( GVarName( "PCWP_NAMES" ),
             INTOBJ_INT(PCWP_NAMES) );
    AssGVar( GVarName( "PCWP_COLLECTOR" ),
             INTOBJ_INT(PCWP_COLLECTOR) );
    AssGVar( GVarName( "PCWP_FIRST_FREE" ),
             INTOBJ_INT(PCWP_FIRST_FREE) );

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoPcElements()  . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "objpcgel",                         /* name                           */
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

StructInitInfo * InitInfoPcElements ( void )
{
    return &module;
}
