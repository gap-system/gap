/****************************************************************************
**
*W  objpcgel.c                  GAP source                       Frank Celler
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*/
char * Revision_objpcgel_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* NewBag, CHANGED_BAG             */
#include        "objects.h"             /* Obj, TYPE_OBJ, types            */
#include        "scanner.h"             /* Pr                              */

#include        "gvars.h"               /* AssGVar, GVarName               */
#include        "gap.h"                 /* Error                           */

#include        "calls.h"               /* CALL_2ARGS                      */

#include        "lists.h"               /* generic lists package           */
#include        "plist.h"               /* ELM_PLIST, SET_ELM_PLIST, ...   */

#include        "ariths.h"              /* LT, EQ                          */
#include        "bool.h"                /* True, False                     */

#include        "objfgelm.h"            /* NPAIRS_WORD, EDBITS_WORD, ...   */
#include        "objscoll.h"            /* collectors                      */

#define INCLUDE_DECLARATION_PART
#include        "objpcgel.h"
#undef  INCLUDE_DECLARATION_PART


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
    left = FuncFinPowConjCol_ReducedLeftQuotient(
	        self, COLLECTOR_PCWORD(left), right, left );
    return FuncFinPowConjCol_ReducedProduct(
                self, COLLECTOR_PCWORD(left), left, right );
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

*F  InitPcElements()  . . . . . . . . initialize the single collector package
*/
void InitPcElements ( void )
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


    /* methods for boxed objs                                              */
    InitHandlerFunc( FuncLessBoxedObj, "LessBoxedObj" );
    AssGVar( GVarName( "LessBoxedObj" ),
         NewFunctionC( "LessBoxedObj", 2L, "lobj, lobj",
                    FuncLessBoxedObj ) );

    InitHandlerFunc( FuncEqualBoxedObj, "EqualBoxedObj" );
    AssGVar( GVarName( "EqualBoxedObj" ),
         NewFunctionC( "EqualBoxedObj", 2L, "lobj, lobj",
                    FuncEqualBoxedObj ) );


    /* finite power conjugate collector words                              */
    InitHandlerFunc( FuncNBitsPcWord_Comm, "NBitsPcWord_Comm" );
    AssGVar( GVarName( "NBitsPcWord_Comm" ),
         NewFunctionC( "NBitsPcWord_Comm", 2L,
                       "n_bits_pcword, n_bits_pcword",
                    FuncNBitsPcWord_Comm ) );

    InitHandlerFunc( FuncNBitsPcWord_Conjugate,
		     "NBitsPcWord_Conjugate" );
    AssGVar( GVarName( "NBitsPcWord_Conjugate" ),
         NewFunctionC( "NBitsPcWord_Conjugate", 2L,
                       "n_bits_pcword, n_bits_pcword",
                    FuncNBitsPcWord_Conjugate ) );

    InitHandlerFunc( FuncNBitsPcWord_LeftQuotient,
		     "NBitsPcWord_LeftQuotient" );
    AssGVar( GVarName( "NBitsPcWord_LeftQuotient" ),
         NewFunctionC( "NBitsPcWord_LeftQuotient", 2L, 
                       "n_bits_pcword, n_bits_pcword",
                    FuncNBitsPcWord_LeftQuotient ) );

    InitHandlerFunc( FuncNBitsPcWord_PowerSmallInt,
		     "NBitsPcWord_PowerSmallInt" );
    AssGVar( GVarName( "NBitsPcWord_PowerSmallInt" ),
         NewFunctionC( "NBitsPcWord_PowerSmallInt", 2L, 
                       "n_bits_pcword, small_integer",
                    FuncNBitsPcWord_PowerSmallInt ) );

    InitHandlerFunc( FuncNBitsPcWord_Product,
		     "NBitsPcWord_Product" );
    AssGVar( GVarName( "NBitsPcWord_Product" ),
         NewFunctionC( "NBitsPcWord_Product", 2L, 
                       "n_bits_pcword, n_bits_pcword",
                    FuncNBitsPcWord_Product ) );

    InitHandlerFunc( FuncNBitsPcWord_Quotient,
		     "NBitsPcWord_Quotient" );
    AssGVar( GVarName( "NBitsPcWord_Quotient" ),
         NewFunctionC( "NBitsPcWord_Quotient", 2L, 
                       "n_bits_pcword, n_bits_pcword",
                    FuncNBitsPcWord_Quotient ) );


    /* 8 bits word                                                         */
    InitHandlerFunc( Func8Bits_DepthOfPcElement,
		     "8Bits_DepthOfPcElement" );
    AssGVar( GVarName( "8Bits_DepthOfPcElement" ),
         NewFunctionC( "8Bits_DepthOfPcElement", 2L, 
                       "8_bits_pcgs, 8_bits_pcword",
                    Func8Bits_DepthOfPcElement ) );

    InitHandlerFunc( Func8Bits_ExponentOfPcElement,
		     "8Bits_ExponentOfPcElement" );
    AssGVar( GVarName( "8Bits_ExponentOfPcElement" ),
         NewFunctionC( "8Bits_ExponentOfPcElement", 3L, 
                       "8_bits_pcgs, 8_bits_pcword, int",
                    Func8Bits_ExponentOfPcElement ) );

    InitHandlerFunc( Func8Bits_LeadingExponentOfPcElement,
		     "8Bits_LeadingExponentOfPcElement" );
    AssGVar( GVarName( "8Bits_LeadingExponentOfPcElement" ),
         NewFunctionC( "8Bits_LeadingExponentOfPcElement", 2L, 
                       "8_bits_pcgs, 8_bits_word",
                    Func8Bits_LeadingExponentOfPcElement ) );

    /* 16 bits word                                                        */
    InitHandlerFunc( Func16Bits_DepthOfPcElement,
		     "16Bits_DepthOfPcElement" );
    AssGVar( GVarName( "16Bits_DepthOfPcElement" ),
         NewFunctionC( "16Bits_DepthOfPcElement", 2L, 
                       "16_bits_pcgs, 16_bits_pcword",
                    Func16Bits_DepthOfPcElement ) );

    InitHandlerFunc( Func16Bits_ExponentOfPcElement,
		     "16Bits_ExponentOfPcElement" );
    AssGVar( GVarName( "16Bits_ExponentOfPcElement" ),
         NewFunctionC( "16Bits_ExponentOfPcElement", 3L, 
                       "16_bits_pcgs, 16_bits_pcword, int",
                    Func16Bits_ExponentOfPcElement ) );

    InitHandlerFunc( Func16Bits_LeadingExponentOfPcElement,
		     "16Bits_LeadingExponentOfPcElement" );
    AssGVar( GVarName( "16Bits_LeadingExponentOfPcElement" ),
         NewFunctionC( "16Bits_LeadingExponentOfPcElement", 2L, 
                       "16_bits_pcgs, 16_bits_word",
                    Func16Bits_LeadingExponentOfPcElement ) );

    /* 32 bits word                                                        */
    InitHandlerFunc( Func32Bits_DepthOfPcElement,
		     "32Bits_DepthOfPcElement" );
    AssGVar( GVarName( "32Bits_DepthOfPcElement" ),
         NewFunctionC( "32Bits_DepthOfPcElement", 2L, 
                       "32_bits_pcgs, 32_bits_pcword",
                    Func32Bits_DepthOfPcElement ) );

    InitHandlerFunc( Func32Bits_ExponentOfPcElement,
		     "32Bits_ExponentOfPcElement" );
    AssGVar( GVarName( "32Bits_ExponentOfPcElement" ),
         NewFunctionC( "32Bits_ExponentOfPcElement", 3L, 
                       "32_bits_pcgs, 32_bits_pcword, int",
                    Func32Bits_ExponentOfPcElement ) );

    InitHandlerFunc( Func32Bits_LeadingExponentOfPcElement,
		     "32Bits_LeadingExponentOfPcElement" );
    AssGVar( GVarName( "32Bits_LeadingExponentOfPcElement" ),
         NewFunctionC( "32Bits_LeadingExponentOfPcElement", 2L, 
                       "32_bits_pcgs, 32_bits_word",
                    Func32Bits_LeadingExponentOfPcElement ) );
}


/****************************************************************************
**

*E  objpcgel.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
