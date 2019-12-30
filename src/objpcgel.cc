/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

extern "C" {

#include "objpcgel.h"

#include "bool.h"
#include "collectors.h"
#include "gvars.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"

} // extern "C"


/****************************************************************************
**
*F * * * * * * * * * * * * * * free word aspect * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  DepthOfPcElement( <self>, <pcgs>, <w> )
*/
template <typename UIntN>
static Obj DepthOfPcElement(Obj self, Obj pcgs, Obj w)
{
    Int         ebits;          /* number of bits in the exponent          */

    /* if the pc element is the identity we have to ask the pcgs           */
    if ( NPAIRS_WORD(w) == 0 )
        return INTOBJ_INT( LEN_LIST(pcgs) + 1 );

    /* otherwise it is the generators number of the first syllable         */
    else {
        ebits = EBITS_WORD(w);
        return INTOBJ_INT((CONST_DATA_WORD(w)[0] >> ebits)+1);
    }
}


/****************************************************************************
**
*F  ExponentOfPcElement( <self>, <pcgs>, <w>, <pos> )
*/
template <typename UIntN>
static Obj ExponentOfPcElement(Obj self, Obj pcgs, Obj w, Obj pos)
{
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        ebits;          /* number of exponent bits                 */
    UInt        npos;           /* the wanted generator number             */
    UInt        num;            /* number of syllables in <w>              */
    const UIntN * ptr;          /* pointer to the syllables of <w>         */
    UInt        i;              /* loop                                    */
    UInt        gen;            /* current generator number                */

    /* all exponents are zero if the pc element if the identity            */
    num = NPAIRS_WORD(w);
    if ( num == 0 )
        return INTOBJ_INT(0);

    /* otherwise find the syllable belonging to <exp>                      */
    else {
        ebits = EBITS_WORD(w);
        exps  = (UInt)1 << (ebits-1);
        expm  = exps - 1;
        npos  = INT_INTOBJ(pos);
        ptr   = CONST_DATA_WORD(w);
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
*F  LeadingExponentOfPcElement( <self>, <pcgs>, <w> )
*/
template <typename UIntN>
static Obj LeadingExponentOfPcElement(Obj self, Obj pcgs, Obj w)
{
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UIntN       p;              /* first syllable                          */

    /* the leading exponent is zero iff the pc element if the identity     */
    if ( NPAIRS_WORD(w) == 0 )
        return Fail;

    /* otherwise it is the exponent of the first syllable                  */
    else {
        exps = (UInt)1 << (EBITS_WORD(w)-1);
        expm = exps - 1;
        p = CONST_DATA_WORD(w)[0];
        if ( p & exps )
            return INTOBJ_INT((p&expm)-exps);
        else
            return INTOBJ_INT(p&expm);
    }
}

/****************************************************************************
**
*F  ExponentsOfPcElement( <self>, <pcgs>, <w> )
*/
template <typename UIntN>
static Obj ExponentsOfPcElement(Obj self, Obj pcgs, Obj w)
{
    UInt        len;            /* length of pcgs */
    Obj         el;             /* exponents list */
    UInt        le;
    UInt        indx;
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        ebits;          /* number of exponent bits                 */
    UInt        num;            /* number of syllables in <w>              */
    const UIntN * ptr;          /* pointer to the syllables of <w>         */
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
    exps  = (UInt)1 << (ebits-1);
    expm  = exps - 1;

    ptr   = CONST_DATA_WORD(w);
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
*F  Func8Bits_DepthOfPcElement( <self>, <pcgs>, <w> )
*/
static Obj Func8Bits_DepthOfPcElement(Obj self, Obj pcgs, Obj w)
{
    return DepthOfPcElement<UInt1>(self, pcgs, w);
}


/****************************************************************************
**
*F  Func8Bits_ExponentOfPcElement( <self>, <pcgs>, <w>, <pos> )
*/
static Obj Func8Bits_ExponentOfPcElement(Obj self, Obj pcgs, Obj w, Obj pos)
{
    return ExponentOfPcElement<UInt1>(self, pcgs, w, pos);
}


/****************************************************************************
**
*F  Func8Bits_LeadingExponentOfPcElement( <self>, <pcgs>, <w> )
*/
static Obj Func8Bits_LeadingExponentOfPcElement(Obj self, Obj pcgs, Obj w)
{
    return LeadingExponentOfPcElement<UInt1>(self, pcgs, w);
}

/****************************************************************************
**
*F  Func8Bits_ExponentsOfPcElement( <self>, <pcgs>, <w> )
*/
static Obj Func8Bits_ExponentsOfPcElement(Obj self, Obj pcgs, Obj w)
{
    return ExponentsOfPcElement<UInt1>(self, pcgs, w);
}


/****************************************************************************
**
*F  Func16Bits_DepthOfPcElement( <self>, <pcgs>, <w> )
*/
static Obj Func16Bits_DepthOfPcElement(Obj self, Obj pcgs, Obj w)
{
    return DepthOfPcElement<UInt2>(self, pcgs, w);
}


/****************************************************************************
**
*F  Func16Bits_ExponentOfPcElement( <self>, <pcgs>, <w>, <pos> )
*/
static Obj Func16Bits_ExponentOfPcElement(Obj self, Obj pcgs, Obj w, Obj pos)
{
    return ExponentOfPcElement<UInt2>(self, pcgs, w, pos);
}


/****************************************************************************
**
*F  Func16Bits_LeadingExponentOfPcElement( <self>, <pcgs>, <w> )
*/
static Obj Func16Bits_LeadingExponentOfPcElement(Obj self, Obj pcgs, Obj w)
{
    return LeadingExponentOfPcElement<UInt2>(self, pcgs, w);
}

/****************************************************************************
**
*F  Func16Bits_ExponentsOfPcElement( <self>, <pcgs>, <w> )
*/
static Obj Func16Bits_ExponentsOfPcElement(Obj self, Obj pcgs, Obj w)
{
    return ExponentsOfPcElement<UInt2>(self, pcgs, w);
}


/****************************************************************************
**
*F  Func32Bits_DepthOfPcElement( <self>, <pcgs>, <w> )
*/
static Obj Func32Bits_DepthOfPcElement(Obj self, Obj pcgs, Obj w)
{
    return DepthOfPcElement<UInt4>(self, pcgs, w);
}


/****************************************************************************
**
*F  Func32Bits_ExponentOfPcElement( <self>, <pcgs>, <w>, <pos> )
*/
static Obj Func32Bits_ExponentOfPcElement(Obj self, Obj pcgs, Obj w, Obj pos)
{
    return ExponentOfPcElement<UInt4>(self, pcgs, w, pos);
}


/****************************************************************************
**
*F  Func32Bits_LeadingExponentOfPcElement( <self>, <pcgs>, <w> )
*/
static Obj Func32Bits_LeadingExponentOfPcElement(Obj self, Obj pcgs, Obj w)
{
    return LeadingExponentOfPcElement<UInt4>(self, pcgs, w);
}

/****************************************************************************
**
*F  Func32Bits_ExponentsOfPcElement( <self>, <pcgs>, <w> )
*/
static Obj Func32Bits_ExponentsOfPcElement(Obj self, Obj pcgs, Obj w)
{
    return ExponentsOfPcElement<UInt4>(self, pcgs, w);
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

    GVAR_FUNC_2ARGS(8Bits_DepthOfPcElement, 8_bits_pcgs, 8_bits_pcword),
    GVAR_FUNC_3ARGS(8Bits_ExponentOfPcElement, 8_bits_pcgs, 8_bits_pcword, int),
    GVAR_FUNC_2ARGS(8Bits_LeadingExponentOfPcElement, 8_bits_pcgs, 8_bits_word),
    GVAR_FUNC_2ARGS(8Bits_ExponentsOfPcElement, 8_bits_pcgs, 8_bits_pcword),
    GVAR_FUNC_2ARGS(16Bits_DepthOfPcElement, 16_bits_pcgs, 16_bits_pcword),
    GVAR_FUNC_3ARGS(16Bits_ExponentOfPcElement, 16_bits_pcgs, 16_bits_pcword, int),
    GVAR_FUNC_2ARGS(16Bits_LeadingExponentOfPcElement, 16_bits_pcgs, 16_bits_word),
    GVAR_FUNC_2ARGS(16Bits_ExponentsOfPcElement, 16_bits_pcgs, 16_bits_pcword),
    GVAR_FUNC_2ARGS(32Bits_DepthOfPcElement, 32_bits_pcgs, 32_bits_pcword),
    GVAR_FUNC_3ARGS(32Bits_ExponentOfPcElement, 32_bits_pcgs, 32_bits_pcword, int),
    GVAR_FUNC_2ARGS(32Bits_LeadingExponentOfPcElement, 32_bits_pcgs, 32_bits_word),
    GVAR_FUNC_2ARGS(32Bits_ExponentsOfPcElement, 32_bits_pcgs, 32_bits_pcword),

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
    ExportAsConstantGVar(PCWP_FIRST_ENTRY);
    ExportAsConstantGVar(PCWP_NAMES);
    ExportAsConstantGVar(PCWP_COLLECTOR);
    ExportAsConstantGVar(PCWP_LAST_ENTRY);

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    return 0;
}


/****************************************************************************
**
*F  InitInfoPcElements()  . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
 /* type        = */ MODULE_BUILTIN,
 /* name        = */ "objpcgel",
 /* revision_c  = */ 0,
 /* revision_h  = */ 0,
 /* version     = */ 0,
 /* crc         = */ 0,
 /* initKernel  = */ InitKernel,
 /* initLibrary = */ InitLibrary,
 /* checkInit   = */ 0,
 /* preSave     = */ 0,
 /* postSave    = */ 0,
 /* postRestore = */ 0,
 /* moduleStateSize      = */ 0,
 /* moduleStateOffsetPtr = */ 0,
 /* initModuleState      = */ 0,
 /* destroyModuleState   = */ 0,
};

StructInitInfo * InitInfoPcElements ( void )
{
    return &module;
}
