/****************************************************************************
**
*W  objfgelm.c                  GAP source                       Frank Celler
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This  file contains the  C functions for free  group elements.  There are
**  basically three different (internal) types: 8  bits, 16 bits, and 32 bits
**  for  the generator/exponent  pairs.   The  number of  bits  used for  the
**  generator numbers is determined by the number of free group generators in
**  the family.  Any object of this type looks like:
**
**    +------+-----+-------+-------+-----+-----------+
**    | TYPE | len | g1/e1 | g2/e2 | ... | glen/elen | 
**    +------+-----+-------+-------+-----+-----------+
**
**  where  <len> is a GAP integer  object and <gi>/<ei> occupies 8, 16, or 32
**  bits depending on the type.  A TYPE of such an objects looks like:
**
**    +--------+-------+--------+----------+-------+------+------+
**    | FAMILY | FLAGS | SHARED | PURETYPE | EBITS | RANK | BITS |
**    +--------+-------+--------+----------+-------+------+------+
**
**  <PURETYPE> is the kind  of a result, <EBITS>  is the number of  bits used
**  for the exponent, <RANK> is number of free group generators.  But instead
**  of accessing these entries directly you should use the following macros.
**
**
**  The file "objects.h" defines the following macros:
**
**  NEW_WORD( <result>, <kind>, <npairs> )
**    creates   a  new  objects   of   kind  <kind>  with  room  for <npairs>
**    generator/exponent pairs.
**
**  RESIZE_WORD( <word>, <npairs> ) 
**    resizes the  <word> such that  it will hold <npairs> generator/exponent
**    pairs.
**
**
**  BITS_WORD( <word> )
**    returns the number of bits as C integers
**
**  DATA_WORD( <word> )
**    returns a pointer to the beginning of the data area
**
**  EBITS_WORD( <word> )
**    returns the ebits as C integer
**
**  NPAIRS_WORD( <word> )
**    returns the number of pairs as C integer
**
**  RANK_WORD( <word> )
**    returns the rank as C integer
**
**  PURETYPE_WORD( <word> )
**    returns the result kind
**
**
**  BITS_WORDTYPE( <kind> )
**    returns the number of bits as C integers
**
**  EBITS_WORDTYPE( <kind> )
**    returns the ebits as C integer
**
**  RANK_WORDTYPE( <kind> )
**    returns the rank as C integer
**
**  PURETYPE_WORDTYPE( <kind> )
**    returns the result kind
*/
char * Revision_objfgelm_c =
   "@(#)$Id$";

#include        <assert.h>              /* assert                          */

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* NewBag, CHANGED_BAG             */
#include        "objects.h"             /* Obj, TNUM_OBJ, types            */
#include        "scanner.h"             /* Pr                              */

#include        "gvars.h"               /* AssGVar, GVarName               */
#include        "gap.h"                 /* Error                           */

#include        "calls.h"               /* CALL_2ARGS                      */

#include        "lists.h"               /* generic lists package           */
#include        "plist.h"               /* ELM_PLIST, SET_ELM_PLIST, ...   */

#include        "bool.h"                /* True, False                     */

#define INCLUDE_DECLARATION_PART
#include        "objfgelm.h"            /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

extern Obj TRY_NEXT_METHOD;


/****************************************************************************
**

*F * * * * * * * * * * * * * * * * 8 bits words * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  Func8Bits_Equal( <self>, <l>, <r> )
*/
Obj Func8Bits_Equal (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    UInt1 *     pl;             /* data area in <l>                        */
    UInt1 *     pr;             /* data area in <r>                        */

    /* if <l> or <r> is the identity it is easy                            */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( nl != nr ) {
        return False;
    }

    /* compare the generator/exponent pairs                                */
    pl = (UInt1*)DATA_WORD(l);
    pr = (UInt1*)DATA_WORD(r);
    for ( ;  0 < nl;  nl--, pl++, pr++ ) {
        if ( *pl != *pr ) {
            return False;
        }
    }
    return True;
}


/****************************************************************************
**
*F  Func8Bits_ExponentSums3( <self>, <obj>, <start>, <end> )
*/
Obj Func8Bits_ExponentSums3 (
    Obj         self,
    Obj         obj,
    Obj         vstart,
    Obj         vend )
{
    Int         start;          /* the lowest generator number             */
    Int         end;            /* the highest generator number            */
    Obj         sums;           /* result, the exponent sums               */
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         pos;            /* current generator number                */
    Int         exp;            /* current exponent                        */
    UInt1 *     ptr;            /* pointer into the data area of <obj>     */

    /* <start> must be positive                                            */
    while ( !IS_INTOBJ(vstart) || INT_INTOBJ(vstart) <= 0 )
        vstart = ErrorReturnObj( "<start> must be positive", 0L, 0L,
                                 "you can return an integer for <start>" );
    start = INT_INTOBJ(vstart);

    /* <end> must be positive                                              */
    while ( !IS_INTOBJ(vend) || INT_INTOBJ(vend) <= 0 )
        vend = ErrorReturnObj( "<end> must be positive", 0L, 0L,
                               "you can return an integer for <end>" );
    end = INT_INTOBJ(vend);

    /* <end> must be at least <start>                                      */
    if ( end < start ) {
        sums = NEW_PLIST( T_PLIST_CYC, 0 );
        SET_LEN_PLIST( sums, 0 );
        return sums;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(obj);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the number of gen/exp pairs                                     */
    num = NPAIRS_WORD(obj);

    /* create the zero vector                                              */
    sums = NEW_PLIST( T_PLIST_CYC, end-start+1 );
    SET_LEN_PLIST( sums, end-start+1 );
    for ( i = start;  i <= end;  i++ )
        SET_ELM_PLIST( sums, i-start+1, 0 );

    /* and unpack <obj> into <sums>                                        */
    ptr = (UInt1*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++ ) {
        pos = ((*ptr) >> ebits)+1;
        if ( start <= pos && pos <= end ) {
            if ( (*ptr) & exps )
                exp = ((*ptr)&expm)-exps;
            else
                exp = (*ptr)&expm;

            /* this will not cause a garbage collection                    */
            exp = exp + (Int) ELM_PLIST( sums, pos-start+1 );
            SET_ELM_PLIST( sums, pos-start+1, (Obj) exp );
            assert( ptr == (UInt1*)DATA_WORD(obj) + (i-1) );
        }
    }

    /* convert integers into values                                        */
    for ( i = start;  i <= end;  i++ ) {
        exp = (Int) ELM_PLIST( sums, i-start+1 );
        SET_ELM_PLIST( sums, i-start+1, INTOBJ_INT(exp) );
    }

    /* return the exponent sums                                            */
    return sums;
}


/****************************************************************************
**
*F  Func8Bits_ExponentSums1( <self>, <obj> )
*/
Obj Func8Bits_ExponentSums1 (
    Obj         self,
    Obj         obj )
{
    return Func8Bits_ExponentSums3( self, obj,
        INTOBJ_INT(1), INTOBJ_INT(RANK_WORD(obj)) );
}


/****************************************************************************
**
*F  Func8Bits_ExponentSyllable( <self>, <w>, <i> )
*/
Obj Func8Bits_ExponentSyllable (
    Obj         self,
    Obj         w,
    Obj         vi )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* integer corresponding to <vi>           */
    UInt1       p;              /* <i>th syllable                          */

    /* check <i>                                                           */
    num = NPAIRS_WORD(w);
    while ( !IS_INTOBJ(vi) || INT_INTOBJ(vi) <= 0 || num < INT_INTOBJ(vi) )
        vi = ErrorReturnObj( "<i> must be between 1 and %d", num, 0L,
                             "you can return an integer for <i>" );
    i = INT_INTOBJ(vi);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(w);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* return the <i> th exponent                                          */
    p = ((UInt1*)DATA_WORD(w))[i-1];
    if ( p & exps )
        return INTOBJ_INT((p&expm)-exps);
    else
        return INTOBJ_INT(p&expm);
}


/****************************************************************************
**
*F  Func8Bits_ExtRepOfObj( <self>, <obj> )
*/
Obj Func8Bits_ExtRepOfObj (
    Obj         self,
    Obj         obj )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Obj         kind;           /* kind of <obj>                           */
    UInt1 *     ptr;            /* pointer into the data area of <obj>     */
    Obj         lst;            /* result                                  */

    /* get the kind of <obj>                                               */
    kind = TYPE_DATOBJ(obj);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the number of gen/exp pairs                                     */
    num = NPAIRS_WORD(obj);

    /* construct a list with 2*<num> entries                               */
    lst = NEW_PLIST( T_PLIST, 2*num );
    SET_LEN_PLIST( lst, 2*num );

    /* and unpack <obj> into <lst>                                         */
    ptr = (UInt1*)DATA_WORD(obj);

    /* this will not cause a garbage collection                            */
    for ( i = 1;  i <= num;  i++, ptr++ ) {
        SET_ELM_PLIST( lst, 2*i-1, INTOBJ_INT(((*ptr) >> ebits)+1) );
        if ( (*ptr) & exps )
            SET_ELM_PLIST( lst, 2*i, INTOBJ_INT(((*ptr)&expm)-exps) );
        else
            SET_ELM_PLIST( lst, 2*i, INTOBJ_INT((*ptr)&expm) );
        assert( ptr == (UInt1*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(lst);

    /* return the gen/exp list                                             */
    return lst;
}


/****************************************************************************
**
*F  Func8Bits_GeneratorSyllable( <self>, <w>, <i> )
*/
Obj Func8Bits_GeneratorSyllable (
    Obj         self,
    Obj         w,
    Obj         vi )
{
    Int         ebits;          /* number of bits in the exponent          */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* integer corresponding to <vi>           */
    UInt1       p;              /* <i>th syllable                          */

    /* check <i>                                                           */
    num = NPAIRS_WORD(w);
    while ( !IS_INTOBJ(vi) || INT_INTOBJ(vi) <= 0 || num < INT_INTOBJ(vi) )
        vi = ErrorReturnObj( "<i> must be between 1 and %d", num, 0L,
                             "you can return an integer for <i>" );
    i = INT_INTOBJ(vi);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(w);

    /* return the <i> th generator                                         */
    p = ((UInt1*)DATA_WORD(w))[i-1];
    return INTOBJ_INT((p >> ebits)+1);
}


/****************************************************************************
**
*F  Func8Bits_HeadByNumber( <self>, <l>, <gen> )
*/
Obj Func8Bits_HeadByNumber (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         sl;             /* start position in <obj>                 */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         gr;             /* value of <r>                            */
    UInt1 *     pl;             /* data area in <l>                        */
    Obj         obj;            /* the result                              */
    UInt1 *     po;             /* data area in <obj>                      */

    /* get the generator number to stop                                    */
    gr = INT_INTOBJ(r) - 1;

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the generator mask                                              */
    genm = ((1UL << (8-ebits)) - 1) << ebits;

    /* if <l> is the identity return                                       */
    nl = NPAIRS_WORD(l);
    if ( 0 == nl )  return l;

    /* look closely at the generators                                      */
    sl = 0;
    pl = (UInt1*)DATA_WORD(l);
    while ( sl < nl && ((*pl & genm) >> ebits) < gr ) {
        sl++;  pl++;
    }
    if ( sl == nl )
        return l;

    /* create a new word                                                   */
    NEW_WORD( obj, PURETYPE_WORD(l), sl );

    /* copy the <l> part into the word                                     */
    po = (UInt1*)DATA_WORD(obj);
    pl = (UInt1*)DATA_WORD(l);
    while ( 0 < sl-- )
        *po++ = *pl++;

    return obj;
}


/****************************************************************************
**
*F  Func8Bits_Less( <self>, <l>, <r> )
*/
Obj Func8Bits_Less (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         exl;            /* left exponent                           */
    Int         exr;            /* right exponent                          */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    UInt1 *     pl;             /* data area in <l>                        */
    UInt1 *     pr;             /* data area in <r>                        */

    /* if <l> or <r> is the identity it is easy                            */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( nl == 0 || nr == 0 ) {
        return ( nr != 0 ) ? True : False;
    }

    /* compare the generator/exponent pairs                                */
    pl = (UInt1*)DATA_WORD(l);
    pr = (UInt1*)DATA_WORD(r);
    for ( ;  0 < nl && 0 < nr;  nl--, nr--, pl++, pr++ ) {

        /* got a difference                                                */
        if ( *pl != *pr ) {

            /* get the number of bits for exponents                        */
            ebits = EBITS_WORD(l);

            /* get the exponent masks                                      */
            exps = 1UL << (ebits-1);
            expm = exps - 1;

            /* get the generator mask                                      */
            genm = ((1UL << (8-ebits)) - 1) << ebits;

            /* compare the generators                                      */
            if ( (*pl & genm) != (*pr & genm) ) {
                return ( (*pl & genm) < (*pr & genm) ) ? True : False;
            }

            /* comapre the exponents                                       */
            exl = (*pl & expm) - ((*pl & exps)?exps:0);
            exr = (*pr & expm) - ((*pr & exps)?exps:0);
            return ( exl < exr ) ? True : False;
        }
    }
    return ( nr != 0 ) ? True : False;
}


/****************************************************************************
**
*F  Func8Bits_AssocWord( <self>, <kind>, <data> )
*/
Obj Func8Bits_AssocWord (
    Obj         self,
    Obj         kind,
    Obj         data )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Obj         vexp;           /* value of current exponent               */
    Int         nexp;           /* current exponent                        */
    Obj         vgen;           /* value of current generator              */
    Int         ngen;           /* current generator                       */
    Obj         obj;            /* result                                  */
    UInt1 *     ptr;            /* pointer into the data area of <obj>     */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* construct a new object                                              */
    num = LEN_LIST(data)/2;
    NEW_WORD( obj, kind, num );

    /* use UInt1 pointer for eight bits                                    */
    ptr = (UInt1*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++ ) {

        /* this will not cause a garbage collection                        */
        vgen = ELMW_LIST( data, 2*i-1 );
        ngen = INT_INTOBJ(vgen);
        vexp = ELMW_LIST( data, 2*i );
        nexp = INT_INTOBJ(vexp);
        while ( ! IS_INTOBJ(vexp) || nexp == 0 ) {
            vexp = ErrorReturnObj( "exponent must not be zero", 0L, 0L,
                                   "you can return a positive integer" );
            nexp = INT_INTOBJ(vexp);
            ptr  = (UInt1*)DATA_WORD(obj) + (i-1);
        }
        nexp = nexp & expm;
        *ptr = ((ngen-1) << ebits) | nexp;
        assert( ptr == (UInt1*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(obj);

    return obj;
}


/****************************************************************************
**
*F  Func8Bits_ObjByVector( <self>, <kind>, <data> )
*/
Obj Func8Bits_ObjByVector (
    Obj         self,
    Obj         kind,
    Obj         data )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         j;              /* loop variable for exponent vector       */
    Int         nexp;           /* current exponent                        */
    Obj         vexp;           /* value of current exponent               */
    Obj         obj;            /* result                                  */
    UInt1 *     ptr;            /* pointer into the data area of <obj>     */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* count the number of non-zero entries                                */
    for ( i = LEN_LIST(data), num = 0, j = 1;  0 < i;  i-- ) {
        vexp = ELMW_LIST(data,i);
        while ( ! IS_INTOBJ(vexp) ) {
            vexp = ErrorReturnObj(
                "%d element must be integer (not a %s)",
                (Int) i, (Int) (InfoBags[TNUM_OBJ(vexp)].name),
                "you can return an integer" );
        }
        if ( vexp != INTOBJ_INT(0) ) {
            j = i;
            num++;
        }
    }

    /* construct a new object                                              */
    NEW_WORD( obj, kind, num );

    /* use UInt1 pointer for eight bits                                    */
    ptr = (UInt1*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++, j++ ) {

        /* this will not cause a garbage collection                        */
        while ( ELMW_LIST(data,j) == INTOBJ_INT(0) )
            j++;
        vexp = ELMW_LIST( data, j );
        nexp = INT_INTOBJ(vexp) & expm;
        *ptr = ((j-1) << ebits) | nexp;
        assert( ptr == (UInt1*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(obj);

    return obj;
}


/****************************************************************************
**
*F  Func8Bits_Power( <self>, <l>, <r> )
*/
Obj Func8Bits_Power (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         invm;           /* mask used to invert exponent            */
    Obj         obj;            /* the result                              */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         sr;             /* start position in <r>                   */
    Int         sl;             /* start position in <obj>                 */
    UInt1 *     pl;             /* data area in <l>                        */
    UInt1 *     pr;             /* data area in <obj>                      */
    UInt1 *     pe;             /* end marker                              */
    Int         ex = 0;         /* meeting exponent                        */
    Int         pow;            /* power to take                           */
    Int         apw;            /* absolute value of <pow>                 */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;
    invm = (1UL<<ebits)-1;

    /* get the generator mask                                              */
    genm = ((1UL << (8-ebits)) - 1) << ebits;

    /* if <l> is the identity return <l>                                   */
    nl = NPAIRS_WORD(l);
    if ( 0 == nl )
        return l;

    /* if <pow> is zero return the identity                                */
    pow = INT_INTOBJ(r);
    if ( pow == 0 ) {
        NEW_WORD( obj, PURETYPE_WORD(l), 0 );
        return obj;
    }

    /* if <pow> is one return <l>                                          */
    if ( pow == 1 )
        return l;

    /* if <pow> is minus one invert <l>                                    */
    if ( pow == -1 ) {
        NEW_WORD( obj, PURETYPE_WORD(l), nl );
        pl = (UInt1*)DATA_WORD(l);
        pr = (UInt1*)DATA_WORD(obj) + (nl-1);
        sl = nl;

        /* exponents are symmtric, so we cannot get an overflow            */
        while ( 0 < sl-- ) {
            *pr-- = ( *pl++ ^ invm ) + 1;
        }
        return obj;
    }

    /* split word into w * h * w^-1                                        */
    pl = (UInt1*)DATA_WORD(l);
    pr = pl + (nl-1);
    sl = 0;
    sr = nl-1;
    while ( (*pl & genm) == (*pr & genm) ) {
        if ( (*pl&exps) == (*pr&exps) )
            break;
        if ( (*pl&expm) + (*pr&expm) != exps )
            break;
        pl++;  sl++;
        pr--;  sr--;
    }

    /* special case: w * gi^n * w^-1                                       */
    if ( sl == sr ) {
        ex = (*pl&expm);
        if ( *pl & exps )  ex -= exps;
        ex = ex * pow;

        /* check that n*pow fits into the exponent                         */
        if ( ( 0 < ex && expm < ex ) || ( ex < 0 && expm < -ex ) ) {
            return TRY_NEXT_METHOD;
        }

        /* copy <l> into <obj>                                             */
        NEW_WORD( obj, PURETYPE_WORD(l), nl );
        pl = (UInt1*)DATA_WORD(l);
        pr = (UInt1*)DATA_WORD(obj);
        sl = nl;
        while ( 0 < sl-- ) {
            *pr++ = *pl++;
        }

        /* and fix the exponent at position <sr>                           */
        pr = (UInt1*)DATA_WORD(obj);
        pr[sr] = (pr[sr] & genm) | (ex & ((1UL<<ebits)-1));
        return obj;
    }

    /* special case: w * gj^x * t * gj^y * w^-1, x != -y                   */
    if ( (*pl & genm) == (*pr & genm) ) {
        ex = (*pl&expm) + (*pr&expm);
        if ( *pl & exps )  ex -= exps;
        if ( *pr & exps )  ex -= exps;

        /* check that <ex> fits into the exponent                          */
        if ( ( 0 < ex && expm < ex ) || ( ex < 0 && expm < -ex ) ) {
            return TRY_NEXT_METHOD;
        }
        if ( 0 < pow )
            ex = ex & ((1UL<<ebits)-1);
        else
            ex = (-ex) & ((1UL<<ebits)-1);

        /* create a new word                                               */
        apw = ( pow < 0 ) ? -pow : pow;
        NEW_WORD( obj, PURETYPE_WORD(l), 2*(sl+1)+apw*(sr-sl-1)+(apw-1) );

        /* copy the beginning w * gj^x into <obj>                          */
        pl = (UInt1*)DATA_WORD(l);
        pr = (UInt1*)DATA_WORD(obj);
        pe = pl+sl;
        while ( pl <= pe ) {
            *pr++ = *pl++;
        }

        /* copy t * gj^<ex> <pow> times into <obj>                         */
        if ( 0 < pow ) {
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt1*)DATA_WORD(l) + (sl+1);
                pe = pl + (sr-sl-1);
                while ( pl <= pe ) {
                    *pr++ = *pl++;
                }
                pr[-1] = (pr[-1] & genm) | ex;
            }

            /* copy tail gj^y * w^-1 into <obj>                            */
            pr[-1] = pl[-1];
            pe = (UInt1*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr++ = *pl++;
            }
        }

        /* copy and invert t * gj^<ex> <pow> times into <obj>              */
        else {
            pr[-1] = ( pl[sr-sl-1] ^ invm ) + 1;
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt1*)DATA_WORD(l) + (sr-1);
                pe = pl + (sl-sr+1);
                while ( pe <= pl ) {
                    *pr++ = ( *pl-- ^ invm ) + 1;
                }
                pr[-1] = (pr[-1] & genm) | ex;
            }

            /* copy tail gj^x * w^-1 into <obj>                            */
            pr[-1] = ( pl[1] ^ invm ) + 1;
            pl = (UInt1*)DATA_WORD(l) + (sr+1);
            pe = (UInt1*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr ++ = *pl++;
            }
        }
        return obj;
    }

    /* general case: w * t * w^-1                                          */
    else {

        /* create a new word                                               */
        apw = ( pow < 0 ) ? -pow : pow;
        NEW_WORD( obj, PURETYPE_WORD(l), 2*sl+apw*(sr-sl+1) );

        /* copy the beginning w * gj^x into <obj>                          */
        pl = (UInt1*)DATA_WORD(l);
        pr = (UInt1*)DATA_WORD(obj);
        pe = pl+sl;
        while ( pl < pe ) {
            *pr++ = *pl++;
        }

        /* copy t <pow> times into <obj>                                   */
        if ( 0 < pow ) {
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt1*)DATA_WORD(l) + sl;
                pe = pl + (sr-sl);
                while ( pl <= pe ) {
                    *pr++ = *pl++;
                }
            }

            /* copy tail w^-1 into <obj>                                   */
            pe = (UInt1*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr++ = *pl++;
            }
        }

        /* copy and invert t <pow> times into <obj>                        */
        else {
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt1*)DATA_WORD(l) + sr;
                pe = pl + (sl-sr);
                while ( pe <= pl ) {
                    *pr++ = ( *pl-- ^ invm ) + 1;
                }
            }

            /* copy tail w^-1 into <obj>                                   */
            pl = (UInt1*)DATA_WORD(l) + (sr+1);
            pe = (UInt1*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr ++ = *pl++;
            }
        }
        return obj;
    }
}


/****************************************************************************
**
*F  Func8Bits_Product( <self>, <l>, <r> )
*/
Obj Func8Bits_Product (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    Int         sr;             /* start position in <r>                   */
    UInt1 *     pl;             /* data area in <l>                        */
    UInt1 *     pr;             /* data area in <r>                        */
    Obj         obj;            /* the result                              */
    UInt1 *     po;             /* data area in <obj>                      */
    Int         ex = 0;         /* meeting exponent                        */
    Int         over;           /* overlap                                 */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the generator mask                                              */
    genm = ((1UL << (8-ebits)) - 1) << ebits;

    /* if <l> or <r> is the identity return the other                      */
    nl = NPAIRS_WORD(l);
    if ( 0 == nl )  return r;
    nr = NPAIRS_WORD(r);
    if ( 0 == nr )  return l;

    /* look closely at the meeting point                                   */
    sr = 0;
    pl = (UInt1*)DATA_WORD(l)+(nl-1);
    pr = (UInt1*)DATA_WORD(r);
    while ( 0 < nl && sr < nr && (*pl & genm) == (*pr & genm) ) {
        if ( (*pl&exps) == (*pr&exps) )
            break;
        if ( (*pl&expm) + (*pr&expm) != exps )
            break;
        pr++;  sr++;
        pl--;  nl--;
    }

    /* create a new word                                                   */
    over = ( 0 < nl && sr < nr && (*pl & genm) == (*pr & genm) ) ? 1 : 0;
    if ( over ) {
        ex = ( *pl & expm ) + ( *pr & expm );
        if ( *pl & exps )  ex -= exps;
        if ( *pr & exps )  ex -= exps;
        if ( ( 0 < ex && expm < ex ) || ( ex < 0 && expm < -ex ) ) {
            return TRY_NEXT_METHOD;
        }
    }
    NEW_WORD( obj, PURETYPE_WORD(l), nl+(nr-sr)-over );

    /* copy the <l> part into the word                                     */
    po = (UInt1*)DATA_WORD(obj);
    pl = (UInt1*)DATA_WORD(l);
    while ( 0 < nl-- )
        *po++ = *pl++;

    /* handle the overlap                                                  */
    if ( over ) {
        po[-1] = (po[-1] & genm) | (ex & ((1UL<<ebits)-1));
        sr++;
    }

    /* copy the <r> part into the word                                     */
    pr = ((UInt1*)DATA_WORD(r)) + sr;
    while ( sr++ < nr )
        *po++ = *pr++;
    return obj;
}


/****************************************************************************
**
*F  Func8Bits_Quotient( <self>, <l>, <r> )
*/
Obj Func8Bits_Quotient (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        sepm;           /* unsigned exponent mask                  */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    UInt1 *     pl;             /* data area in <l>                        */
    UInt1 *     pr;             /* data area in <r>                        */
    Obj         obj;            /* the result                              */
    UInt1 *     po;             /* data area in <obj>                      */
    Int         ex = 0;         /* meeting exponent                        */
    Int         over;           /* overlap                                 */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;
    sepm = (1UL << ebits) - 1;

    /* get the generator mask                                              */
    genm = ((1UL << (8-ebits)) - 1) << ebits;

    /* if <r> is the identity return <l>                                   */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( 0 == nr )  return l;

    /* look closely at the meeting point                                   */
    pl = (UInt1*)DATA_WORD(l)+(nl-1);
    pr = (UInt1*)DATA_WORD(r)+(nr-1);
    while ( 0 < nl && 0 < nr && (*pl & genm) == (*pr & genm) ) {
        if ( (*pl&exps) != (*pr&exps) )
            break;
        if ( (*pl&expm) != (*pr&expm) )
            break;
        pr--;  nr--;
        pl--;  nl--;
    }

    /* create a new word                                                   */
    over = ( 0 < nl && 0 < nr && (*pl & genm) == (*pr & genm) ) ? 1 : 0;
    if ( over ) {
        ex = ( *pl & expm ) - ( *pr & expm );
        if ( *pl & exps )  ex -= exps;
        if ( *pr & exps )  ex += exps;
        if ( ( 0 < ex && expm < ex ) || ( ex < 0 && expm < -ex ) ) {
            return TRY_NEXT_METHOD;
        }
    }
    NEW_WORD( obj, PURETYPE_WORD(l), nl+nr-over );

    /* copy the <l> part into the word                                     */
    po = (UInt1*)DATA_WORD(obj);
    pl = (UInt1*)DATA_WORD(l);
    while ( 0 < nl-- )
        *po++ = *pl++;

    /* handle the overlap                                                  */
    if ( over ) {
        po[-1] = (po[-1] & genm) | (ex & sepm);
        nr--;
    }

    /* copy the <r> part into the word                                     */
    pr = ((UInt1*)DATA_WORD(r)) + (nr-1);
    while ( 0 < nr-- ) {
        *po++ = (*pr&genm) | (exps-(*pr&expm)) | (~*pr & exps);
        pr--;
    }
    return obj;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * * * * 16 bits word * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  Func16Bits_Equal( <self>, <l>, <r> )
*/
Obj Func16Bits_Equal (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    UInt2 *     pl;             /* data area in <l>                        */
    UInt2 *     pr;             /* data area in <r>                        */

    /* if <l> or <r> is the identity it is easy                            */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( nl != nr ) {
        return False;
    }

    /* compare the generator/exponent pairs                                */
    pl = (UInt2*)DATA_WORD(l);
    pr = (UInt2*)DATA_WORD(r);
    for ( ;  0 < nl;  nl--, pl++, pr++ ) {
        if ( *pl != *pr ) {
            return False;
        }
    }
    return True;
}


/****************************************************************************
**
*F  Func16Bits_ExponentSums3( <self>, <obj>, <start>, <end> )
*/
Obj Func16Bits_ExponentSums3 (
    Obj         self,
    Obj         obj,
    Obj         vstart,
    Obj         vend )
{
    Int         start;          /* the lowest generator number             */
    Int         end;            /* the highest generator number            */
    Obj         sums;           /* result, the exponent sums               */
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         pos;            /* current generator number                */
    Int         exp;            /* current exponent                        */
    UInt2 *     ptr;            /* pointer into the data area of <obj>     */

    /* <start> must be positive                                            */
    while ( !IS_INTOBJ(vstart) || INT_INTOBJ(vstart) <= 0 )
        vstart = ErrorReturnObj( "<start> must be positive", 0L, 0L,
                                 "you can return an integer for <start>" );
    start = INT_INTOBJ(vstart);

    /* <end> must be positive                                              */
    while ( !IS_INTOBJ(vend) || INT_INTOBJ(vend) <= 0 )
        vend = ErrorReturnObj( "<end> must be positive", 0L, 0L,
                               "you can return an integer for <end>" );
    end = INT_INTOBJ(vend);

    /* <end> must be at least <start>                                      */
    if ( end < start ) {
        sums = NEW_PLIST( T_PLIST_CYC, 0 );
        SET_LEN_PLIST( sums, 0 );
        return sums;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(obj);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the number of gen/exp pairs                                     */
    num = NPAIRS_WORD(obj);

    /* create the zero vector                                              */
    sums = NEW_PLIST( T_PLIST_CYC, end-start+1 );
    SET_LEN_PLIST( sums, end-start+1 );
    for ( i = start;  i <= end;  i++ )
        SET_ELM_PLIST( sums, i-start+1, 0 );

    /* and unpack <obj> into <sums>                                        */
    ptr = (UInt2*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++ ) {
        pos = ((*ptr) >> ebits)+1;
        if ( start <= pos && pos <= end ) {
            if ( (*ptr) & exps )
                exp = ((*ptr)&expm)-exps;
            else
                exp = (*ptr)&expm;

            /* this will not cause a garbage collection                    */
            exp = exp + (Int) ELM_PLIST( sums, pos-start+1 );
            SET_ELM_PLIST( sums, pos-start+1, (Obj) exp );
            assert( ptr == (UInt2*)DATA_WORD(obj) + (i-1) );
        }
    }

    /* convert integers into values                                        */
    for ( i = start;  i <= end;  i++ ) {
        exp = (Int) ELM_PLIST( sums, i-start+1 );
        SET_ELM_PLIST( sums, i-start+1, INTOBJ_INT(exp) );
    }

    /* return the exponent sums                                            */
    return sums;
}


/****************************************************************************
**
*F  Func16Bits_ExponentSums1( <self>, <obj> )
*/
Obj Func16Bits_ExponentSums1 (
    Obj         self,
    Obj         obj )
{
    return Func16Bits_ExponentSums3( self, obj,
        INTOBJ_INT(1), INTOBJ_INT(RANK_WORD(obj)) );
}


/****************************************************************************
**
*F  Func16Bits_ExponentSyllable( <self>, <w>, <i> )
*/
Obj Func16Bits_ExponentSyllable (
    Obj         self,
    Obj         w,
    Obj         vi )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* integer corresponding to <vi>           */
    UInt2       p;              /* <i>th syllable                          */

    /* check <i>                                                           */
    num = NPAIRS_WORD(w);
    while ( !IS_INTOBJ(vi) || INT_INTOBJ(vi) <= 0 || num < INT_INTOBJ(vi) )
        vi = ErrorReturnObj( "<i> must be between 1 and %d", num, 0L,
                             "you can return an integer for <i>" );
    i = INT_INTOBJ(vi);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(w);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* return the <i> th exponent                                          */
    p = ((UInt2*)DATA_WORD(w))[i-1];
    if ( p & exps )
        return INTOBJ_INT((p&expm)-exps);
    else
        return INTOBJ_INT(p&expm);
}


/****************************************************************************
**
*F  Func16Bits_ExtRepOfObj( <self>, <obj> )
*/
Obj Func16Bits_ExtRepOfObj (
    Obj         self,
    Obj         obj )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Obj         kind;           /* kind of <obj>                           */
    UInt2 *     ptr;            /* pointer into the data area of <obj>     */
    Obj         lst;            /* result                                  */

    /* get the kind of <obj>                                               */
    kind = TYPE_DATOBJ(obj);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the number of gen/exp pairs                                     */
    num = NPAIRS_WORD(obj);

    /* construct a list with 2*<num> entries                               */
    lst = NEW_PLIST( T_PLIST, 2*num );
    SET_LEN_PLIST( lst, 2*num );

    /* and unpack <obj> into <lst>                                         */
    ptr = (UInt2*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++ ) {

        /* this will not cause a garbage collection                        */
        SET_ELM_PLIST( lst, 2*i-1, INTOBJ_INT(((*ptr) >> ebits)+1) );
        if ( (*ptr) & exps )
            SET_ELM_PLIST( lst, 2*i, INTOBJ_INT(((*ptr)&expm)-exps) );
        else
            SET_ELM_PLIST( lst, 2*i, INTOBJ_INT((*ptr)&expm) );
        assert( ptr == (UInt2*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(lst);

    /* return the gen/exp list                                             */
    return lst;
}


/****************************************************************************
**
*F  Func16Bits_GeneratorSyllable( <self>, <w>, <i> )
*/
Obj Func16Bits_GeneratorSyllable (
    Obj         self,
    Obj         w,
    Obj         vi )
{
    Int         ebits;          /* number of bits in the exponent          */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* integer corresponding to <vi>           */
    UInt2       p;              /* <i>th syllable                          */

    /* check <i>                                                           */
    num = NPAIRS_WORD(w);
    while ( !IS_INTOBJ(vi) || INT_INTOBJ(vi) <= 0 || num < INT_INTOBJ(vi) )
        vi = ErrorReturnObj( "<i> must be between 1 and %d", num, 0L,
                             "you can return an integer for <i>" );
    i = INT_INTOBJ(vi);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(w);

    /* return the <i> th generator                                         */
    p = ((UInt2*)DATA_WORD(w))[i-1];
    return INTOBJ_INT((p >> ebits)+1);
}


/****************************************************************************
**
*F  Func16Bits_HeadByNumber( <self>, <l>, <gen> )
*/
Obj Func16Bits_HeadByNumber (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         sl;             /* start position in <obj>                 */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         gr;             /* value of <r>                            */
    UInt2 *     pl;             /* data area in <l>                        */
    Obj         obj;            /* the result                              */
    UInt2 *     po;             /* data area in <obj>                      */

    /* get the generator number to stop                                    */
    gr = INT_INTOBJ(r) - 1;

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the generator mask                                              */
    genm = ((1UL << (16-ebits)) - 1) << ebits;

    /* if <l> is the identity return                                       */
    nl = NPAIRS_WORD(l);
    if ( 0 == nl )  return l;

    /* look closely at the generators                                      */
    sl = 0;
    pl = (UInt2*)DATA_WORD(l);
    while ( sl < nl && ((*pl & genm) >> ebits) < gr ) {
        sl++;  pl++;
    }
    if ( sl == nl )
        return l;

    /* create a new word                                                   */
    NEW_WORD( obj, PURETYPE_WORD(l), sl );

    /* copy the <l> part into the word                                     */
    po = (UInt2*)DATA_WORD(obj);
    pl = (UInt2*)DATA_WORD(l);
    while ( 0 < sl-- )
        *po++ = *pl++;

    return obj;
}


/****************************************************************************
**
*F  Func16Bits_Less( <self>, <l>, <r> )
*/
Obj Func16Bits_Less (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         exl;            /* left exponent                           */
    Int         exr;            /* right exponent                          */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    UInt2 *     pl;             /* data area in <l>                        */
    UInt2 *     pr;             /* data area in <r>                        */

    /* if <l> or <r> is the identity it is easy                            */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( nl == 0 || nr == 0 ) {
        return ( nr != 0 ) ? True : False;
    }

    /* compare the generator/exponent pairs                                */
    pl = (UInt2*)DATA_WORD(l);
    pr = (UInt2*)DATA_WORD(r);
    for ( ;  0 < nl && 0 < nr;  nl--, nr--, pl++, pr++ ) {

        /* got a difference                                                */
        if ( *pl != *pr ) {

            /* get the number of bits for exponents                        */
            ebits = EBITS_WORD(l);

            /* get the exponent masks                                      */
            exps = 1UL << (ebits-1);
            expm = exps - 1;

            /* get the generator mask                                      */
            genm = ((1UL << (16-ebits)) - 1) << ebits;

            /* compare the generators                                      */
            if ( (*pl & genm) != (*pr & genm) ) {
                return ( (*pl & genm) < (*pr & genm) ) ? True : False;
            }

            /* compare the exponents                                       */
            exl = (*pl & expm) - ((*pl & exps)?exps:0);
            exr = (*pr & expm) - ((*pr & exps)?exps:0);
            return ( exl < exr ) ? True : False;
        }
    }
    return ( nr != 0 ) ? True : False;
}


/****************************************************************************
**
*F  Func16Bits_AssocWord( <self>, <kind>, <data> )
*/
Obj Func16Bits_AssocWord (
    Obj         self,
    Obj         kind,
    Obj         data )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Obj         vgen;           /* value of current exponent               */
    Int         nexp;           /* current exponent                        */
    Obj         vexp;           /* value of current generator              */
    Int         ngen;           /* current generator                       */
    Obj         obj;            /* result                                  */
    UInt2 *     ptr;            /* pointer into the data area of <obj>     */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* construct a new object                                              */
    num = LEN_LIST(data)/2;
    NEW_WORD( obj, kind, num );

    /* use UInt2 pointer for sixteen bits                                  */
    ptr = (UInt2*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++ ) {

        /* this will not cause a garbage collection                        */
        vgen = ELMW_LIST( data, 2*i-1 );
        ngen = INT_INTOBJ(vgen);
        vexp = ELMW_LIST( data, 2*i );
        nexp = INT_INTOBJ(vexp);
        while ( ! IS_INTOBJ(vexp) || nexp == 0 ) {
            vexp = ErrorReturnObj( "exponent must not be zero", 0L, 0L,
                                   "you can return a positive integer" );
            nexp = INT_INTOBJ(vexp);
            ptr = (UInt2*)DATA_WORD(obj) + (i-1);
        }
        nexp = nexp & expm;
        *ptr = ((ngen-1) << ebits) | nexp;
        assert( ptr == (UInt2*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(obj);

    return obj;
}


/****************************************************************************
**
*F  Func16Bits_ObjByVector( <self>, <kind>, <data> )
*/
Obj Func16Bits_ObjByVector (
    Obj         self,
    Obj         kind,
    Obj         data )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         j;              /* loop variable for exponent vector       */
    Int         nexp;           /* current exponent                        */
    Obj         vexp;           /* value of current exponent               */
    Obj         obj;            /* result                                  */
    UInt2 *     ptr;            /* pointer into the data area of <obj>     */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* count the number of non-zero entries                                */
    for ( i = LEN_LIST(data), num = 0, j = 1;  0 < i;  i-- ) {
        vexp = ELMW_LIST(data,i);
        while ( ! IS_INTOBJ(vexp) ) {
            vexp = ErrorReturnObj(
                "%d element must be integer (not a %s)",
                (Int) i, (Int) (InfoBags[TNUM_OBJ(vexp)].name),
                "you can return an integer" );
        }
        if ( vexp != INTOBJ_INT(0) ) {
            j = i;
            num++;
        }
    }

    /* construct a new object                                              */
    NEW_WORD( obj, kind, num );

    /* use UInt2 pointer for sixteen bits                                  */
    ptr = (UInt2*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++, j++ ) {

        /* this will not cause a garbage collection                        */
        while ( ELMW_LIST(data,j) == INTOBJ_INT(0) )
            j++;
        vexp = ELMW_LIST( data, j );
        nexp = INT_INTOBJ(vexp) & expm;
        *ptr = ((j-1) << ebits) | nexp;
        assert( ptr == (UInt2*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(obj);

    return obj;
}


/****************************************************************************
**
*F  Func16Bits_Power( <self>, <l>, <r> )
*/
Obj Func16Bits_Power (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         invm;           /* mask used to invert exponent            */
    Obj         obj;            /* the result                              */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         sr;             /* start position in <r>                   */
    Int         sl;             /* start position in <obj>                 */
    UInt2 *     pl;             /* data area in <l>                        */
    UInt2 *     pr;             /* data area in <obj>                      */
    UInt2 *     pe;             /* end marker                              */
    Int         ex = 0;         /* meeting exponent                        */
    Int         pow;            /* power to take                           */
    Int         apw;            /* absolute value of <pow>                 */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;
    invm = (1UL<<ebits)-1;

    /* get the generator mask                                              */
    genm = ((1UL << (16-ebits)) - 1) << ebits;

    /* if <l> is the identity return <l>                                   */
    nl = NPAIRS_WORD(l);
    if ( 0 == nl )
        return l;

    /* if <pow> is zero return the identity                                */
    pow = INT_INTOBJ(r);
    if ( pow == 0 ) {
        NEW_WORD( obj, PURETYPE_WORD(l), 0 );
        return obj;
    }

    /* if <pow> is one return <l>                                          */
    if ( pow == 1 )
        return l;

    /* if <pow> is minus one invert <l>                                    */
    if ( pow == -1 ) {
        NEW_WORD( obj, PURETYPE_WORD(l), nl );
        pl = (UInt2*)DATA_WORD(l);
        pr = (UInt2*)DATA_WORD(obj) + (nl-1);
        sl = nl;

        /* exponents are symmtric, so we cannot get an overflow            */
        while ( 0 < sl-- ) {
            *pr-- = ( *pl++ ^ invm ) + 1;
        }
        return obj;
    }

    /* split word into w * h * w^-1                                        */
    pl = (UInt2*)DATA_WORD(l);
    pr = pl + (nl-1);
    sl = 0;
    sr = nl-1;
    while ( (*pl & genm) == (*pr & genm) ) {
        if ( (*pl&exps) == (*pr&exps) )
            break;
        if ( (*pl&expm) + (*pr&expm) != exps )
            break;
        pl++;  sl++;
        pr--;  sr--;
    }

    /* special case: w * gi^n * w^-1                                       */
    if ( sl == sr ) {
        ex = (*pl&expm);
        if ( *pl & exps )  ex -= exps;
        ex = ex * pow;

        /* check that n*pow fits into the exponent                         */
        if ( ( 0 < ex && expm < ex ) || ( ex < 0 && expm < -ex ) ) {
            return TRY_NEXT_METHOD;
        }

        /* copy <l> into <obj>                                             */
        NEW_WORD( obj, PURETYPE_WORD(l), nl );
        pl = (UInt2*)DATA_WORD(l);
        pr = (UInt2*)DATA_WORD(obj);
        sl = nl;
        while ( 0 < sl-- ) {
            *pr++ = *pl++;
        }

        /* and fix the exponent at position <sr>                           */
        pr = (UInt2*)DATA_WORD(obj);
        pr[sr] = (pr[sr] & genm) | (ex & ((1UL<<ebits)-1));
        return obj;
    }

    /* special case: w * gj^x * t * gj^y * w^-1, x != -y                   */
    if ( (*pl & genm) == (*pr & genm) ) {
        ex = (*pl&expm) + (*pr&expm);
        if ( *pl & exps )  ex -= exps;
        if ( *pr & exps )  ex -= exps;

        /* check that <ex> fits into the exponent                          */
        if ( ( 0 < ex && expm < ex ) || ( ex < 0 && expm < -ex ) ) {
            return TRY_NEXT_METHOD;
        }
        if ( 0 < pow )
            ex = ex & ((1UL<<ebits)-1);
        else
            ex = (-ex) & ((1UL<<ebits)-1);

        /* create a new word                                               */
        apw = ( pow < 0 ) ? -pow : pow;
        NEW_WORD( obj, PURETYPE_WORD(l), 2*(sl+1)+apw*(sr-sl-1)+(apw-1) );

        /* copy the beginning w * gj^x into <obj>                          */
        pl = (UInt2*)DATA_WORD(l);
        pr = (UInt2*)DATA_WORD(obj);
        pe = pl+sl;
        while ( pl <= pe ) {
            *pr++ = *pl++;
        }

        /* copy t * gj^<ex> <pow> times into <obj>                         */
        if ( 0 < pow ) {
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt2*)DATA_WORD(l) + (sl+1);
                pe = pl + (sr-sl-1);
                while ( pl <= pe ) {
                    *pr++ = *pl++;
                }
                pr[-1] = (pr[-1] & genm) | ex;
            }

            /* copy tail gj^y * w^-1 into <obj>                            */
            pr[-1] = pl[-1];
            pe = (UInt2*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr++ = *pl++;
            }
        }

        /* copy and invert t * gj^<ex> <pow> times into <obj>              */
        else {
            pr[-1] = ( pl[sr-sl-1] ^ invm ) + 1;
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt2*)DATA_WORD(l) + (sr-1);
                pe = pl + (sl-sr+1);
                while ( pe <= pl ) {
                    *pr++ = ( *pl-- ^ invm ) + 1;
                }
                pr[-1] = (pr[-1] & genm) | ex;
            }

            /* copy tail gj^x * w^-1 into <obj>                            */
            pr[-1] = ( pl[1] ^ invm ) + 1;
            pl = (UInt2*)DATA_WORD(l) + (sr+1);
            pe = (UInt2*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr ++ = *pl++;
            }
        }
        return obj;
    }

    /* general case: w * t * w^-1                                          */
    else {

        /* create a new word                                               */
        apw = ( pow < 0 ) ? -pow : pow;
        NEW_WORD( obj, PURETYPE_WORD(l), 2*sl+apw*(sr-sl+1) );

        /* copy the beginning w * gj^x into <obj>                          */
        pl = (UInt2*)DATA_WORD(l);
        pr = (UInt2*)DATA_WORD(obj);
        pe = pl+sl;
        while ( pl < pe ) {
            *pr++ = *pl++;
        }

        /* copy t <pow> times into <obj>                                   */
        if ( 0 < pow ) {
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt2*)DATA_WORD(l) + sl;
                pe = pl + (sr-sl);
                while ( pl <= pe ) {
                    *pr++ = *pl++;
                }
            }

            /* copy tail w^-1 into <obj>                                   */
            pe = (UInt2*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr++ = *pl++;
            }
        }

        /* copy and invert t <pow> times into <obj>                        */
        else {
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt2*)DATA_WORD(l) + sr;
                pe = pl + (sl-sr);
                while ( pe <= pl ) {
                    *pr++ = ( *pl-- ^ invm ) + 1;
                }
            }

            /* copy tail w^-1 into <obj>                                   */
            pl = (UInt2*)DATA_WORD(l) + (sr+1);
            pe = (UInt2*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr ++ = *pl++;
            }
        }
        return obj;
    }
}


/****************************************************************************
**
*F  Func16Bits_Product( <self>, <l>, <r> )
*/
Obj Func16Bits_Product (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    Int         sr;             /* start position in <r>                   */
    UInt2 *     pl;             /* data area in <l>                        */
    UInt2 *     pr;             /* data area in <r>                        */
    Obj         obj;            /* the result                              */
    UInt2 *     po;             /* data area in <obj>                      */
    Int         ex = 0;         /* meeting exponent                        */
    Int         over;           /* overlap                                 */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the generator mask                                              */
    genm = ((1UL << (16-ebits)) - 1) << ebits;

    /* if <l> or <r> is the identity return the other                      */
    nl = NPAIRS_WORD(l);
    if ( 0 == nl )  return r;
    nr = NPAIRS_WORD(r);
    if ( 0 == nr )  return l;

    /* look closely at the meeting point                                   */
    sr = 0;
    pl = ((UInt2*)DATA_WORD(l))+(nl-1);
    pr = (UInt2*)DATA_WORD(r);
    while ( 0 < nl && sr < nr && (*pl & genm) == (*pr & genm) ) {
        if ( (*pl&exps) == (*pr&exps) )
            break;
        if ( (*pl&expm) + (*pr&expm) != exps )
            break;
        pr++;  sr++;
        pl--;  nl--;
    }

    /* create a new word                                                   */
    over = ( 0 < nl && sr < nr && (*pl & genm) == (*pr & genm) ) ? 1 : 0;
    if ( over ) {
        ex = ( *pl & expm ) + ( *pr & expm );
        if ( *pl & exps )  ex -= exps;
        if ( *pr & exps )  ex -= exps;
        if ( ( 0 < ex && expm < ex ) || ( ex < 0 && expm < -ex ) ) {
            return TRY_NEXT_METHOD;
        }
    }
    NEW_WORD( obj, PURETYPE_WORD(l), nl+(nr-sr)-over );

    /* copy the <l> part into the word                                     */
    po = (UInt2*)DATA_WORD(obj);
    pl = (UInt2*)DATA_WORD(l);
    while ( 0 < nl-- )
        *po++ = *pl++;

    /* handle the overlap                                                  */
    if ( over ) {
        po[-1] = (po[-1] & genm) | (ex & ((1UL<<ebits)-1));
        sr++;
    }

    /* copy the <r> part into the word                                     */
    pr = ((UInt2*)DATA_WORD(r)) + sr;
    while ( sr++ < nr )
        *po++ = *pr++;
    return obj;
}


/****************************************************************************
**
*F  Func16Bits_Quotient( <self>, <l>, <r> )
*/
Obj Func16Bits_Quotient (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        sepm;           /* unsigned exponent mask                  */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    UInt2 *     pl;             /* data area in <l>                        */
    UInt2 *     pr;             /* data area in <r>                        */
    Obj         obj;            /* the result                              */
    UInt2 *     po;             /* data area in <obj>                      */
    Int         ex = 0;         /* meeting exponent                        */
    Int         over;           /* overlap                                 */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;
    sepm = (1UL << ebits) - 1;

    /* get the generator mask                                              */
    genm = ((1UL << (16-ebits)) - 1) << ebits;

    /* if <r> is the identity return <l>                                   */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( 0 == nr )  return l;

    /* look closely at the meeting point                                   */
    pl = (UInt2*)DATA_WORD(l)+(nl-1);
    pr = (UInt2*)DATA_WORD(r)+(nr-1);
    while ( 0 < nl && 0 < nr && (*pl & genm) == (*pr & genm) ) {
        if ( (*pl&exps) != (*pr&exps) )
            break;
        if ( (*pl&expm) != (*pr&expm) )
            break;
        pr--;  nr--;
        pl--;  nl--;
    }

    /* create a new word                                                   */
    over = ( 0 < nl && 0 < nr && (*pl & genm) == (*pr & genm) ) ? 1 : 0;
    if ( over ) {
        ex = ( *pl & expm ) - ( *pr & expm );
        if ( *pl & exps )  ex -= exps;
        if ( *pr & exps )  ex += exps;
        if ( ( 0 < ex && expm < ex ) || ( ex < 0 && expm < -ex ) ) {
            return TRY_NEXT_METHOD;
        }
    }
    NEW_WORD( obj, PURETYPE_WORD(l), nl+nr-over );

    /* copy the <l> part into the word                                     */
    po = (UInt2*)DATA_WORD(obj);
    pl = (UInt2*)DATA_WORD(l);
    while ( 0 < nl-- )
        *po++ = *pl++;

    /* handle the overlap                                                  */
    if ( over ) {
        po[-1] = (po[-1] & genm) | (ex & sepm);
        nr--;
    }

    /* copy the <r> part into the word                                     */
    pr = ((UInt2*)DATA_WORD(r)) + (nr-1);
    while ( 0 < nr-- ) {
        *po++ = (*pr&genm) | (exps-(*pr&expm)) | (~*pr & exps);
        pr--;
    }
    return obj;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * * *  32 bits words * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  Func32Bits_Equal( <self>, <l>, <r> )
*/
Obj Func32Bits_Equal (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    UInt4 *     pl;             /* data area in <l>                        */
    UInt4 *     pr;             /* data area in <r>                        */

    /* if <l> or <r> is the identity it is easy                            */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( nl != nr ) {
        return False;
    }

    /* compare the generator/exponent pairs                                */
    pl = (UInt4*)DATA_WORD(l);
    pr = (UInt4*)DATA_WORD(r);
    for ( ;  0 < nl;  nl--, pl++, pr++ ) {
        if ( *pl != *pr ) {
            return False;
        }
    }
    return True;
}


/****************************************************************************
**
*F  Func32Bits_ExponentSums3( <self>, <obj>, <start>, <end> )
*/
Obj Func32Bits_ExponentSums3 (
    Obj         self,
    Obj         obj,
    Obj         vstart,
    Obj         vend )
{
    Int         start;          /* the lowest generator number             */
    Int         end;            /* the highest generator number            */
    Obj         sums;           /* result, the exponent sums               */
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         pos;            /* current generator number                */
    Int         exp;            /* current exponent                        */
    UInt4 *     ptr;            /* pointer into the data area of <obj>     */

    /* <start> must be positive                                            */
    while ( !IS_INTOBJ(vstart) || INT_INTOBJ(vstart) <= 0 )
        vstart = ErrorReturnObj( "<start> must be positive", 0L, 0L,
                                 "you can return an integer for <start>" );
    start = INT_INTOBJ(vstart);

    /* <end> must be positive                                              */
    while ( !IS_INTOBJ(vend) || INT_INTOBJ(vend) <= 0 )
        vend = ErrorReturnObj( "<end> must be positive", 0L, 0L,
                               "you can return an integer for <end>" );
    end = INT_INTOBJ(vend);

    /* <end> must be at least <start>                                      */
    if ( end < start ) {
        sums = NEW_PLIST( T_PLIST_CYC, 0 );
        SET_LEN_PLIST( sums, 0 );
        return sums;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(obj);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the number of gen/exp pairs                                     */
    num = NPAIRS_WORD(obj);

    /* create the zero vector                                              */
    sums = NEW_PLIST( T_PLIST_CYC, end-start+1 );
    SET_LEN_PLIST( sums, end-start+1 );
    for ( i = start;  i <= end;  i++ )
        SET_ELM_PLIST( sums, i-start+1, 0 );

    /* and unpack <obj> into <sums>                                        */
    ptr = (UInt4*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++ ) {
        pos = ((*ptr) >> ebits)+1;
        if ( start <= pos && pos <= end ) {
            if ( (*ptr) & exps )
                exp = ((*ptr)&expm)-exps;
            else
                exp = (*ptr)&expm;

            /* this will not cause a garbage collection                    */
            exp = exp + (Int) ELM_PLIST( sums, pos-start+1 );
            SET_ELM_PLIST( sums, pos-start+1, (Obj) exp );
            assert( ptr == (UInt4*)DATA_WORD(obj) + (i-1) );
        }
    }

    /* convert integers into values                                        */
    for ( i = start;  i <= end;  i++ ) {
        exp = (Int) ELM_PLIST( sums, i-start+1 );
        SET_ELM_PLIST( sums, i-start+1, INTOBJ_INT(exp) );
    }

    /* return the exponent sums                                            */
    return sums;
}


/****************************************************************************
**
*F  Func32Bits_ExponentSums1( <self>, <obj> )
*/
Obj Func32Bits_ExponentSums1 (
    Obj         self,
    Obj         obj )
{
    return Func32Bits_ExponentSums3( self, obj,
        INTOBJ_INT(1), INTOBJ_INT(RANK_WORD(obj)) );
}


/****************************************************************************
**
*F  Func32Bits_ExponentSyllable( <self>, <w>, <i> )
*/
Obj Func32Bits_ExponentSyllable (
    Obj         self,
    Obj         w,
    Obj         vi )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* integer corresponding to <vi>           */
    UInt4       p;              /* <i>th syllable                          */

    /* check <i>                                                           */
    num = NPAIRS_WORD(w);
    while ( !IS_INTOBJ(vi) || INT_INTOBJ(vi) <= 0 || num < INT_INTOBJ(vi) )
        vi = ErrorReturnObj( "<i> must be between 1 and %d", num, 0L,
                             "you can return an integer for <i>" );
    i = INT_INTOBJ(vi);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(w);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* return the <i> th exponent                                          */
    p = ((UInt4*)DATA_WORD(w))[i-1];
    if ( p & exps )
        return INTOBJ_INT((p&expm)-exps);
    else
        return INTOBJ_INT(p&expm);
}


/****************************************************************************
**
*F  Func32Bits_ExtRepOfObj( <self>, <obj> )
*/
Obj Func32Bits_ExtRepOfObj (
    Obj         self,
    Obj         obj )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Obj         kind;           /* kind of <obj>                           */
    UInt4 *     ptr;            /* pointer into the data area of <obj>     */
    Obj         lst;            /* result                                  */

    /* get the kind of <obj>                                               */
    kind = TYPE_DATOBJ(obj);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the number of gen/exp pairs                                     */
    num = NPAIRS_WORD(obj);

    /* construct a list with 2*<num> entries                               */
    lst = NEW_PLIST( T_PLIST, 2*num );
    SET_LEN_PLIST( lst, 2*num );

    /* and unpack <obj> into <lst>                                         */
    ptr = (UInt4*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++ ) {

        /* this will not cause a garbage collection                    */
        SET_ELM_PLIST( lst, 2*i-1, INTOBJ_INT(((*ptr) >> ebits)+1) );
        if ( (*ptr) & exps )
            SET_ELM_PLIST( lst, 2*i, INTOBJ_INT(((*ptr)&expm)-exps) );
        else
            SET_ELM_PLIST( lst, 2*i, INTOBJ_INT((*ptr)&expm) );
        assert( ptr == (UInt4*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(lst);

    /* return the gen/exp list                                             */
    return lst;
}


/****************************************************************************
**
*F  Func32Bits_GeneratorSyllable( <self>, <w>, <i> )
*/
Obj Func32Bits_GeneratorSyllable (
    Obj         self,
    Obj         w,
    Obj         vi )
{
    Int         ebits;          /* number of bits in the exponent          */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* integer corresponding to <vi>           */
    UInt4       p;              /* <i>th syllable                          */

    /* check <i>                                                           */
    num = NPAIRS_WORD(w);
    while ( !IS_INTOBJ(vi) || INT_INTOBJ(vi) <= 0 || num < INT_INTOBJ(vi) )
        vi = ErrorReturnObj( "<i> must be between 1 and %d", num, 0L,
                             "you can return an integer for <i>" );
    i = INT_INTOBJ(vi);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(w);

    /* return the <i> th generator                                         */
    p = ((UInt4*)DATA_WORD(w))[i-1];
    return INTOBJ_INT((p >> ebits)+1);
}


/****************************************************************************
**
*F  Func32Bits_HeadByNumber( <self>, <l>, <gen> )
*/
Obj Func32Bits_HeadByNumber (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         sl;             /* start position in <obj>                 */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         gr;             /* value of <r>                            */
    UInt4 *     pl;             /* data area in <l>                        */
    Obj         obj;            /* the result                              */
    UInt4 *     po;             /* data area in <obj>                      */

    /* get the generator number to stop                                    */
    gr = INT_INTOBJ(r) - 1;

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the generator mask                                              */
    genm = ((1UL << (32-ebits)) - 1) << ebits;

    /* if <l> is the identity return                                       */
    nl = NPAIRS_WORD(l);
    if ( 0 == nl )  return l;

    /* look closely at the generators                                      */
    sl = 0;
    pl = (UInt4*)DATA_WORD(l);
    while ( sl < nl && ((*pl & genm) >> ebits) < gr ) {
        sl++;  pl++;
    }
    if ( sl == nl )
        return l;

    /* create a new word                                                   */
    NEW_WORD( obj, PURETYPE_WORD(l), sl );

    /* copy the <l> part into the word                                     */
    po = (UInt4*)DATA_WORD(obj);
    pl = (UInt4*)DATA_WORD(l);
    while ( 0 < sl-- )
        *po++ = *pl++;

    return obj;
}


/****************************************************************************
**
*F  Func32Bits_Less( <self>, <l>, <r> )
*/
Obj Func32Bits_Less (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         exl;            /* left exponent                           */
    Int         exr;            /* right exponent                          */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    UInt4 *     pl;             /* data area in <l>                        */
    UInt4 *     pr;             /* data area in <r>                        */

    /* if <l> or <r> is the identity it is easy                            */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( nl == 0 || nr == 0 ) {
        return ( nr != 0 ) ? True : False;
    }

    /* compare the generator/exponent pairs                                */
    pl = (UInt4*)DATA_WORD(l);
    pr = (UInt4*)DATA_WORD(r);
    for ( ;  0 < nl && 0 < nr;  nl--, nr--, pl++, pr++ ) {

        /* got a difference                                                */
        if ( *pl != *pr ) {

            /* get the number of bits for exponents                        */
            ebits = EBITS_WORD(l);

            /* get the exponent masks                                      */
            exps = 1UL << (ebits-1);
            expm = exps - 1;

            /* get the generator mask                                      */
            genm = ((1UL << (32-ebits)) - 1) << ebits;

            /* compare the generators                                      */
            if ( (*pl & genm) != (*pr & genm) ) {
                return ( (*pl & genm) < (*pr & genm) ) ? True : False;
            }

            /* compare the exponents                                       */
            exl = (*pl & expm) - ((*pl & exps)?exps:0);
            exr = (*pr & expm) - ((*pr & exps)?exps:0);
            return ( exl < exr ) ? True : False;
        }
    }
    return ( nr != 0 ) ? True : False;
}


/****************************************************************************
**
*F  Func32Bits_AssocWord( <self>, <kind>, <data> )
*/
Obj Func32Bits_AssocWord (
    Obj         self,
    Obj         kind,
    Obj         data )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Obj         vgen;           /* value of current exponent               */
    Int         nexp;           /* current exponent                        */
    Obj         vexp;           /* value of current generator              */
    Int         ngen;           /* current generator                       */
    Obj         obj;            /* result                                  */
    UInt4 *     ptr;            /* pointer into the data area of <obj>     */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* construct a new object                                              */
    num = LEN_LIST(data)/2;
    NEW_WORD( obj, kind, num );

    /* use UInt4 pointer for eight bits                                    */
    ptr = (UInt4*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++ ) {

        /* this will not cause a garbage collection                        */
        vgen = ELMW_LIST( data, 2*i-1 );
        ngen = INT_INTOBJ(vgen);
        vexp = ELMW_LIST( data, 2*i );
        nexp = INT_INTOBJ(vexp);
        while ( ! IS_INTOBJ(vexp) || nexp == 0 ) {
            vexp = ErrorReturnObj( "exponent must not be zero", 0L, 0L,
                                   "you can return a positive integer" );
            nexp = INT_INTOBJ(vexp);
            ptr = (UInt4*)DATA_WORD(obj) + (i-1);
        }
        nexp = nexp & expm;
        *ptr = ((ngen-1) << ebits) | nexp;
        assert( ptr == (UInt4*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(obj);

    return obj;
}


/****************************************************************************
**
*F  Func32Bits_ObjByVector( <self>, <kind>, <data> )
*/
Obj Func32Bits_ObjByVector (
    Obj         self,
    Obj         kind,
    Obj         data )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* unsigned exponent mask                  */
    Int         num;            /* number of gen/exp pairs in <data>       */
    Int         i;              /* loop variable for gen/exp pairs         */
    Int         j;              /* loop variable for exponent vector       */
    Int         nexp;           /* current exponent                        */
    Obj         vexp;           /* value of current exponent               */
    Obj         obj;            /* result                                  */
    UInt4 *     ptr;            /* pointer into the data area of <obj>     */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(kind);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* count the number of non-zero entries                                */
    for ( i = LEN_LIST(data), num = 0, j = 1;  0 < i;  i-- ) {
        vexp = ELMW_LIST(data,i);
        while ( ! IS_INTOBJ(vexp) ) {
            vexp = ErrorReturnObj(
                "%d element must be integer (not a %s)",
                (Int) i, (Int) (InfoBags[TNUM_OBJ(vexp)].name),
                "you can return an integer" );
        }
        if ( vexp != INTOBJ_INT(0) ) {
            j = i;
            num++;
        }
    }

    /* construct a new object                                              */
    NEW_WORD( obj, kind, num );

    /* use UInt4 pointer for thirteen bits                                 */
    ptr = (UInt4*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++, j++ ) {

        /* this will not cause a garbage collection                        */
        while ( ELMW_LIST(data,j) == INTOBJ_INT(0) )
            j++;
        vexp = ELMW_LIST( data, j );
        nexp = INT_INTOBJ(vexp) & expm;
        *ptr = ((j-1) << ebits) | nexp;
        assert( ptr == (UInt4*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(obj);

    return obj;
}


/****************************************************************************
**
*F  Func32Bits_Power( <self>, <l>, <r> )
*/
Obj Func32Bits_Power (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         invm;           /* mask used to invert exponent            */
    Obj         obj;            /* the result                              */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         sr;             /* start position in <r>                   */
    Int         sl;             /* start position in <obj>                 */
    UInt4 *     pl;             /* data area in <l>                        */
    UInt4 *     pr;             /* data area in <obj>                      */
    UInt4 *     pe;             /* end marker                              */
    Int         ex = 0;         /* meeting exponent                        */
    Int         exs;            /* save <ex> for overflow test             */
    Int         pow;            /* power to take                           */
    Int         apw;            /* absolute value of <pow>                 */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;
    invm = (1UL<<ebits)-1;

    /* get the generator mask                                              */
    genm = ((1UL << (32-ebits)) - 1) << ebits;

    /* if <l> is the identity return <l>                                   */
    nl = NPAIRS_WORD(l);
    if ( 0 == nl )
        return l;

    /* if <pow> is zero return the identity                                */
    pow = INT_INTOBJ(r);
    if ( pow == 0 ) {
        NEW_WORD( obj, PURETYPE_WORD(l), 0 );
        return obj;
    }

    /* if <pow> is one return <l>                                          */
    if ( pow == 1 )
        return l;

    /* if <pow> is minus one invert <l>                                    */
    if ( pow == -1 ) {
        NEW_WORD( obj, PURETYPE_WORD(l), nl );
        pl = (UInt4*)DATA_WORD(l);
        pr = (UInt4*)DATA_WORD(obj) + (nl-1);
        sl = nl;

        /* exponents are symmtric, so we cannot get an overflow            */
        while ( 0 < sl-- ) {
            *pr-- = ( *pl++ ^ invm ) + 1;
        }
        return obj;
    }

    /* split word into w * h * w^-1                                        */
    pl = (UInt4*)DATA_WORD(l);
    pr = pl + (nl-1);
    sl = 0;
    sr = nl-1;
    while ( (*pl & genm) == (*pr & genm) ) {
        if ( (*pl&exps) == (*pr&exps) )
            break;
        if ( (*pl&expm) + (*pr&expm) != exps )
            break;
        pl++;  sl++;
        pr--;  sr--;
    }

    /* special case: w * gi^n * w^-1                                       */
    if ( sl == sr ) {
        ex = (*pl&expm);
        if ( *pl & exps )  ex -= exps;
        exs = ex;
        ex  = ex * pow;

        /* check that n*pow fits into the exponent                         */
        if ( ex/pow!=exs || (0<ex && expm<ex) || (ex<0 && expm<-ex) ) {
            return TRY_NEXT_METHOD;
        }

        /* copy <l> into <obj>                                             */
        NEW_WORD( obj, PURETYPE_WORD(l), nl );
        pl = (UInt4*)DATA_WORD(l);
        pr = (UInt4*)DATA_WORD(obj);
        sl = nl;
        while ( 0 < sl-- ) {
            *pr++ = *pl++;
        }

        /* and fix the exponent at position <sr>                           */
        pr = (UInt4*)DATA_WORD(obj);
        pr[sr] = (pr[sr] & genm) | (ex & ((1UL<<ebits)-1));
        return obj;
    }

    /* special case: w * gj^x * t * gj^y * w^-1, x != -y                   */
    if ( (*pl & genm) == (*pr & genm) ) {
        ex = (*pl&expm) + (*pr&expm);
        if ( *pl & exps )  ex -= exps;
        if ( *pr & exps )  ex -= exps;

        /* check that <ex> fits into the exponent                          */
        if ( ( 0 < ex && expm < ex ) || ( ex < 0 && expm < -ex ) ) {
            return TRY_NEXT_METHOD;
        }
        if ( 0 < pow )
            ex = ex & ((1UL<<ebits)-1);
        else
            ex = (-ex) & ((1UL<<ebits)-1);

        /* create a new word                                               */
        apw = ( pow < 0 ) ? -pow : pow;
        NEW_WORD( obj, PURETYPE_WORD(l), 2*(sl+1)+apw*(sr-sl-1)+(apw-1) );

        /* copy the beginning w * gj^x into <obj>                          */
        pl = (UInt4*)DATA_WORD(l);
        pr = (UInt4*)DATA_WORD(obj);
        pe = pl+sl;
        while ( pl <= pe ) {
            *pr++ = *pl++;
        }

        /* copy t * gj^<ex> <pow> times into <obj>                         */
        if ( 0 < pow ) {
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt4*)DATA_WORD(l) + (sl+1);
                pe = pl + (sr-sl-1);
                while ( pl <= pe ) {
                    *pr++ = *pl++;
                }
                pr[-1] = (pr[-1] & genm) | ex;
            }

            /* copy tail gj^y * w^-1 into <obj>                            */
            pr[-1] = pl[-1];
            pe = (UInt4*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr++ = *pl++;
            }
        }

        /* copy and invert t * gj^<ex> <pow> times into <obj>              */
        else {
            pr[-1] = ( pl[sr-sl-1] ^ invm ) + 1;
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt4*)DATA_WORD(l) + (sr-1);
                pe = pl + (sl-sr+1);
                while ( pe <= pl ) {
                    *pr++ = ( *pl-- ^ invm ) + 1;
                }
                pr[-1] = (pr[-1] & genm) | ex;
            }

            /* copy tail gj^x * w^-1 into <obj>                            */
            pr[-1] = ( pl[1] ^ invm ) + 1;
            pl = (UInt4*)DATA_WORD(l) + (sr+1);
            pe = (UInt4*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr ++ = *pl++;
            }
        }
        return obj;
    }

    /* general case: w * t * w^-1                                          */
    else {

        /* create a new word                                               */
        apw = ( pow < 0 ) ? -pow : pow;
        NEW_WORD( obj, PURETYPE_WORD(l), 2*sl+apw*(sr-sl+1) );

        /* copy the beginning w * gj^x into <obj>                          */
        pl = (UInt4*)DATA_WORD(l);
        pr = (UInt4*)DATA_WORD(obj);
        pe = pl+sl;
        while ( pl < pe ) {
            *pr++ = *pl++;
        }

        /* copy t <pow> times into <obj>                                   */
        if ( 0 < pow ) {
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt4*)DATA_WORD(l) + sl;
                pe = pl + (sr-sl);
                while ( pl <= pe ) {
                    *pr++ = *pl++;
                }
            }

            /* copy tail w^-1 into <obj>                                   */
            pe = (UInt4*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr++ = *pl++;
            }
        }

        /* copy and invert t <pow> times into <obj>                        */
        else {
            for ( ; 0 < apw;  apw-- ) {
                pl = (UInt4*)DATA_WORD(l) + sr;
                pe = pl + (sl-sr);
                while ( pe <= pl ) {
                    *pr++ = ( *pl-- ^ invm ) + 1;
                }
            }

            /* copy tail w^-1 into <obj>                                   */
            pl = (UInt4*)DATA_WORD(l) + (sr+1);
            pe = (UInt4*)DATA_WORD(l) + nl;
            while ( pl < pe ) {
                *pr ++ = *pl++;
            }
        }
        return obj;
    }
}


/****************************************************************************
**
*F  Func32Bits_Product( <self>, <l>, <r> )
*/
Obj Func32Bits_Product (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    Int         sr;             /* start position in <r>                   */
    UInt4 *     pl;             /* data area in <l>                        */
    UInt4 *     pr;             /* data area in <r>                        */
    Obj         obj;            /* the result                              */
    UInt4 *     po;             /* data area in <obj>                      */
    Int         ex = 0;         /* meeting exponent                        */
    Int         over;           /* overlap                                 */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;

    /* get the generator mask                                              */
    genm = ((1UL << (32-ebits)) - 1) << ebits;

    /* if <l> or <r> is the identity return the other                      */
    nl = NPAIRS_WORD(l);
    if ( 0 == nl )  return r;
    nr = NPAIRS_WORD(r);
    if ( 0 == nr )  return l;

    /* look closely at the meeting point                                   */
    sr = 0;
    pl = (UInt4*)DATA_WORD(l)+(nl-1);
    pr = (UInt4*)DATA_WORD(r);
    while ( 0 < nl && sr < nr && (*pl & genm) == (*pr & genm) ) {
        if ( (*pl&exps) == (*pr&exps) )
            break;
        if ( (*pl&expm) + (*pr&expm) != exps )
            break;
        pr++;  sr++;
        pl--;  nl--;
    }

    /* create a new word                                                   */
    over = ( 0 < nl && sr < nr && (*pl & genm) == (*pr & genm) ) ? 1 : 0;
    if ( over ) {
        ex = ( *pl & expm ) + ( *pr & expm );
        if ( *pl & exps )  ex -= exps;
        if ( *pr & exps )  ex -= exps;
        if ( ( 0 < ex && expm < ex ) || ( ex < 0 && expm < -ex ) ) {
            return TRY_NEXT_METHOD;
        }
    }
    NEW_WORD( obj, PURETYPE_WORD(l), nl+(nr-sr)-over );

    /* copy the <l> part into the word                                     */
    po = (UInt4*)DATA_WORD(obj);
    pl = (UInt4*)DATA_WORD(l);
    while ( 0 < nl-- )
        *po++ = *pl++;

    /* handle the overlap                                                  */
    if ( over ) {
        po[-1] = (po[-1] & genm) | (ex & ((1UL<<ebits)-1));
        sr++;
    }

    /* copy the <r> part into the word                                     */
    pr = ((UInt4*)DATA_WORD(r)) + sr;
    while ( sr++ < nr )
        *po++ = *pr++;
    return obj;
}


/****************************************************************************
**
*F  Func32Bits_Quotient( <self>, <l>, <r> )
*/
Obj Func32Bits_Quotient (
    Obj         self,
    Obj         l,
    Obj         r )
{
    Int         ebits;          /* number of bits in the exponent          */
    UInt        expm;           /* signed exponent mask                    */
    UInt        sepm;           /* unsigned exponent mask                  */
    UInt        exps;           /* sign exponent mask                      */
    UInt        genm;           /* generator mask                          */
    Int         nl;             /* number of pairs to consider in <l>      */
    Int         nr;             /* number of pairs in <r>                  */
    UInt4 *     pl;             /* data area in <l>                        */
    UInt4 *     pr;             /* data area in <r>                        */
    Obj         obj;            /* the result                              */
    UInt4 *     po;             /* data area in <obj>                      */
    Int         ex = 0;         /* meeting exponent                        */
    Int         over;           /* overlap                                 */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);

    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;
    sepm = (1UL << ebits) - 1;

    /* get the generator mask                                              */
    genm = ((1UL << (32-ebits)) - 1) << ebits;

    /* if <r> is the identity return <l>                                   */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( 0 == nr )  return l;

    /* look closely at the meeting point                                   */
    pl = (UInt4*)DATA_WORD(l)+(nl-1);
    pr = (UInt4*)DATA_WORD(r)+(nr-1);
    while ( 0 < nl && 0 < nr && (*pl & genm) == (*pr & genm) ) {
        if ( (*pl&exps) != (*pr&exps) )
            break;
        if ( (*pl&expm) != (*pr&expm) )
            break;
        pr--;  nr--;
        pl--;  nl--;
    }

    /* create a new word                                                   */
    over = ( 0 < nl && 0 < nr && (*pl & genm) == (*pr & genm) ) ? 1 : 0;
    if ( over ) {
        ex = ( *pl & expm ) - ( *pr & expm );
        if ( *pl & exps )  ex -= exps;
        if ( *pr & exps )  ex += exps;
        if ( ( 0 < ex && expm < ex ) || ( ex < 0 && expm < -ex ) ) {
            return TRY_NEXT_METHOD;
        }
    }
    NEW_WORD( obj, PURETYPE_WORD(l), nl+nr-over );

    /* copy the <l> part into the word                                     */
    po = (UInt4*)DATA_WORD(obj);
    pl = (UInt4*)DATA_WORD(l);
    while ( 0 < nl-- )
        *po++ = *pl++;

    /* handle the overlap                                                  */
    if ( over ) {
        po[-1] = (po[-1] & genm) | (ex & sepm);
        nr--;
    }

    /* copy the <r> part into the word                                     */
    pr = ((UInt4*)DATA_WORD(r)) + (nr-1);
    while ( 0 < nr-- ) {
        *po++ = (*pr&genm) | (exps-(*pr&expm)) | (~*pr & exps);
        pr--;
    }
    return obj;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * * * all bits words * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  FuncNBits_NumberSyllables( <self>, <w> )
*/
Obj FuncNBits_NumberSyllables (
    Obj         self,
    Obj         w )
{
    /* return the number of syllables                                      */
    return INTOBJ_INT( NPAIRS_WORD(w) );
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitFreeGroupElements()
*/
void InitFreeGroupElements ( void )
{

    /* export position numbers 'AWP_SOMETHING'                             */
    AssGVar( GVarName( "AWP_FIRST_ENTRY" ),
             INTOBJ_INT(AWP_FIRST_ENTRY) );
    AssGVar( GVarName( "AWP_PURE_TYPE" ),
             INTOBJ_INT(AWP_PURE_TYPE) );
    AssGVar( GVarName( "AWP_NR_BITS_EXP" ),
             INTOBJ_INT(AWP_NR_BITS_EXP) );
    AssGVar( GVarName( "AWP_NR_GENS" ),
             INTOBJ_INT(AWP_NR_GENS) );
    AssGVar( GVarName( "AWP_NR_BITS_PAIR" ),
             INTOBJ_INT(AWP_NR_BITS_PAIR) );
    AssGVar( GVarName( "AWP_FUN_OBJ_BY_VECTOR" ),
             INTOBJ_INT(AWP_FUN_OBJ_BY_VECTOR) );
    AssGVar( GVarName( "AWP_FUN_ASSOC_WORD" ),
             INTOBJ_INT(AWP_FUN_ASSOC_WORD) );
    AssGVar( GVarName( "AWP_FIRST_FREE" ),
             INTOBJ_INT(AWP_FIRST_FREE) );

    /* '8Bits' methods                                                     */
    InitHandlerFunc( Func8Bits_Equal, "8Bits_Equal" );
    AssGVar( GVarName( "8Bits_Equal" ),
         NewFunctionC( "8Bits_Equal", 2L, "8_bits_word, 8_bits_word",
                    Func8Bits_Equal ) );

    InitHandlerFunc( Func8Bits_ExponentSums1, "8Bits_ExponentSums1" );
    AssGVar( GVarName( "8Bits_ExponentSums1" ),
         NewFunctionC( "8Bits_ExponentSums1", 1L, "8_bits_word",
                    Func8Bits_ExponentSums1 ) );

    InitHandlerFunc( Func8Bits_ExponentSums3, "8Bits_ExponentSums3" );
    AssGVar( GVarName( "8Bits_ExponentSums3" ), 
         NewFunctionC( "8Bits_ExponentSums3", 3L, "8_bits_word, start, end",
                    Func8Bits_ExponentSums3 ) );

    InitHandlerFunc( Func8Bits_ExponentSyllable, "8Bits_ExponentSyllable" );
    AssGVar( GVarName( "8Bits_ExponentSyllable" ),
         NewFunctionC( "8Bits_ExponentSyllable", 2L, "8_bits_word, position",
                    Func8Bits_ExponentSyllable ) );

    InitHandlerFunc( Func8Bits_ExtRepOfObj, "8Bits_ExtRepOfObj" );
    AssGVar( GVarName( "8Bits_ExtRepOfObj" ),
         NewFunctionC( "8Bits_ExtRepOfObj", 1L, "8_bits_word",
                    Func8Bits_ExtRepOfObj ) );

    InitHandlerFunc( Func8Bits_GeneratorSyllable, "8Bits_GeneratorSyllable" );
    AssGVar( GVarName( "8Bits_GeneratorSyllable" ),
         NewFunctionC( "8Bits_GeneratorSyllable", 2L, "8_bits_word, position",
                    Func8Bits_GeneratorSyllable ) );

    InitHandlerFunc( Func8Bits_Less, "8Bits_Less" );
    AssGVar( GVarName( "8Bits_Less" ),
         NewFunctionC( "8Bits_Less", 2L, "8_bits_word, 8_bits_word",
                    Func8Bits_Less ) );

    InitHandlerFunc( Func8Bits_AssocWord, "8Bits_AssocWord" );
    AssGVar( GVarName( "8Bits_AssocWord" ),
         NewFunctionC( "8Bits_AssocWord", 2L, "kind, data",
                    Func8Bits_AssocWord ) );

    InitHandlerFunc( FuncNBits_NumberSyllables, "NBits_NumberSyllables" );
    AssGVar( GVarName( "8Bits_NumberSyllables" ),
         NewFunctionC( "NBits_NumberSyllables", 1L, "8_bits_word",
                    FuncNBits_NumberSyllables ) );

    InitHandlerFunc( Func8Bits_ObjByVector, "8Bits_ObjByVector" );
    AssGVar( GVarName( "8Bits_ObjByVector" ),
         NewFunctionC( "8Bits_ObjByVector", 2L, "kind, data",
                    Func8Bits_ObjByVector ) );

    InitHandlerFunc( Func8Bits_HeadByNumber, "8Bits_HeadByNumber" );
    AssGVar( GVarName( "8Bits_HeadByNumber" ),
         NewFunctionC( "8Bits_HeadByNumber", 2L, "16_bits_word, gen_num",
                    Func8Bits_HeadByNumber ) );

    InitHandlerFunc( Func8Bits_Power, "8Bits_Power" );
    AssGVar( GVarName( "8Bits_Power" ),
         NewFunctionC( "8Bits_Power", 2L, "8_bits_word, small_integer",
                    Func8Bits_Power ) );

    InitHandlerFunc( Func8Bits_Product, "8Bits_Product" );
    AssGVar( GVarName( "8Bits_Product" ),
         NewFunctionC( "8Bits_Product", 2L, "8_bits_word, 8_bits_word",
                    Func8Bits_Product ) );

    InitHandlerFunc( Func8Bits_Quotient, "8Bits_Quotient" );
    AssGVar( GVarName( "8Bits_Quotient" ),
         NewFunctionC( "8Bits_Quotient", 2L, "8_bits_word, 8_bits_word",
                    Func8Bits_Quotient ) );

    /* '16Bits' methods                                                    */
    InitHandlerFunc( Func16Bits_Equal, "16Bits_Equal" );
    AssGVar( GVarName( "16Bits_Equal" ),
         NewFunctionC( "16Bits_Equal", 2L, "16_bits_word, 16_bits_word",
                    Func16Bits_Equal ) );

    InitHandlerFunc( Func16Bits_ExponentSums1, "16Bits_ExponentSums1" );
    AssGVar( GVarName( "16Bits_ExponentSums1" ),
         NewFunctionC( "16Bits_ExponentSums1", 1L, "16_bits_word",
                    Func16Bits_ExponentSums1 ) );

    InitHandlerFunc( Func16Bits_ExponentSums3, "16Bits_ExponentSums3" );
    AssGVar( GVarName( "16Bits_ExponentSums3" ), 
         NewFunctionC( "16Bits_ExponentSums3", 3L, "16_bits_word, start, end",
                    Func16Bits_ExponentSums3 ) );

    InitHandlerFunc( Func16Bits_ExponentSyllable, "16Bits_ExponentSyllable" );
    AssGVar( GVarName( "16Bits_ExponentSyllable" ),
         NewFunctionC( "16Bits_ExponentSyllable", 2L, "16_bits_word, position",
                    Func16Bits_ExponentSyllable ) );

    InitHandlerFunc( Func16Bits_ExtRepOfObj, "16Bits_ExtRepOfObj" );
    AssGVar( GVarName( "16Bits_ExtRepOfObj" ),
         NewFunctionC( "16Bits_ExtRepOfObj", 1L, "16_bits_word",
                    Func16Bits_ExtRepOfObj ) );

    InitHandlerFunc( Func16Bits_GeneratorSyllable, "16Bits_GeneratorSyllable" );
    AssGVar( GVarName( "16Bits_GeneratorSyllable" ),
         NewFunctionC( "16Bits_GeneratorSyllable", 2L, "16_bits_word, pos",
                    Func16Bits_GeneratorSyllable ) );

    InitHandlerFunc( Func16Bits_Less, "16Bits_Less" );
    AssGVar( GVarName( "16Bits_Less" ),
         NewFunctionC( "16Bits_Less", 2L, "16_bits_word, 16_bits_word",
                    Func16Bits_Less ) );

    InitHandlerFunc( Func16Bits_AssocWord, "16Bits_AssocWord" );
    AssGVar( GVarName( "16Bits_AssocWord" ),
         NewFunctionC( "16Bits_AssocWord", 2L, "kind, data",
                    Func16Bits_AssocWord ) );

    InitHandlerFunc( FuncNBits_NumberSyllables, "NBits_NumberSyllables" );
    AssGVar( GVarName( "16Bits_NumberSyllables" ),
          NewFunctionC( "NBits_NumberSyllables", 1L, "16_bits_word",
                     FuncNBits_NumberSyllables ) );

    InitHandlerFunc( Func16Bits_ObjByVector, "16Bits_ObjByVector" );
    AssGVar( GVarName( "16Bits_ObjByVector" ),
         NewFunctionC( "16Bits_ObjByVector", 2L, "kind, data",
                    Func16Bits_ObjByVector ) );

    InitHandlerFunc( Func16Bits_HeadByNumber, "16Bits_HeadByNumber" );
    AssGVar( GVarName( "16Bits_HeadByNumber" ),
         NewFunctionC( "16Bits_HeadByNumber", 2L, "16_bits_word, gen_num",
                    Func16Bits_HeadByNumber ) );

    InitHandlerFunc( Func16Bits_Power, "16Bits_Power" );
    AssGVar( GVarName( "16Bits_Power" ),
         NewFunctionC( "16Bits_Power", 2L, "16_bits_word, small_integer",
                    Func16Bits_Power ) );

    InitHandlerFunc( Func16Bits_Product, "16Bits_Product" );
    AssGVar( GVarName( "16Bits_Product" ),
         NewFunctionC( "16Bits_Product", 2L, "16_bits_word, 16_bits_word",
                    Func16Bits_Product ) );

    InitHandlerFunc( Func16Bits_Quotient, "16Bits_Quotient" );
    AssGVar( GVarName( "16Bits_Quotient" ),
         NewFunctionC( "16Bits_Quotient", 2L, "16_bits_word, 16_bits_word",
                    Func16Bits_Quotient ) );


    /* '32Bits' methods                                                    */
    InitHandlerFunc( Func32Bits_Equal, "32Bits_Equal" );
    AssGVar( GVarName( "32Bits_Equal" ),
         NewFunctionC( "32Bits_Equal", 2L, "32_bits_word, 32_bits_word",
                    Func32Bits_Equal ) );

    InitHandlerFunc( Func32Bits_ExponentSums1, "32Bits_ExponentSums1" );
    AssGVar( GVarName( "32Bits_ExponentSums1" ),
         NewFunctionC( "32Bits_ExponentSums1", 1L, "32_bits_word",
                    Func32Bits_ExponentSums1 ) );

    InitHandlerFunc( Func32Bits_ExponentSums3, "32Bits_ExponentSums3" );
    AssGVar( GVarName( "32Bits_ExponentSums3" ), 
         NewFunctionC( "32Bits_ExponentSums3", 3L, "32_bits_word, start, end",
                    Func32Bits_ExponentSums3 ) );

    InitHandlerFunc( Func32Bits_ExponentSyllable, "32Bits_ExponentSyllable" );
    AssGVar( GVarName( "32Bits_ExponentSyllable" ),
         NewFunctionC( "32Bits_ExponentSyllable", 2L, "32_bits_word, position",
                    Func32Bits_ExponentSyllable ) );

    InitHandlerFunc( Func32Bits_ExtRepOfObj, "32Bits_ExtRepOfObj" );
    AssGVar( GVarName( "32Bits_ExtRepOfObj" ),
         NewFunctionC( "32Bits_ExtRepOfObj", 1L, "32_bits_word",
                    Func32Bits_ExtRepOfObj ) );

    InitHandlerFunc( Func32Bits_GeneratorSyllable, "32Bits_GeneratorSyllable" );
    AssGVar( GVarName( "32Bits_GeneratorSyllable" ),
         NewFunctionC( "32Bits_GeneratorSyllable", 2L, "32_bits_word, pos",
                    Func32Bits_GeneratorSyllable ) );

    InitHandlerFunc( Func32Bits_Less, "32Bits_Less" );
    AssGVar( GVarName( "32Bits_Less" ),
         NewFunctionC( "32Bits_Less", 2L, "32_bits_word, 32_bits_word",
                    Func32Bits_Less ) );

    InitHandlerFunc( Func32Bits_AssocWord, "32Bits_AssocWord" );
    AssGVar( GVarName( "32Bits_AssocWord" ),
         NewFunctionC( "32Bits_AssocWord", 2L, "kind, data",
                    Func32Bits_AssocWord ) );

    InitHandlerFunc( FuncNBits_NumberSyllables, "NBits_NumberSyllables" );
    AssGVar( GVarName( "32Bits_NumberSyllables" ),
          NewFunctionC( "NBits_NumberSyllables", 1L, "32_bits_word",
                     FuncNBits_NumberSyllables ) );

    InitHandlerFunc( Func32Bits_ObjByVector, "32Bits_ObjByVector" );
    AssGVar( GVarName( "32Bits_ObjByVector" ),
         NewFunctionC( "32Bits_ObjByVector", 2L, "kind, data",
                    Func32Bits_ObjByVector ) );

    InitHandlerFunc( Func32Bits_HeadByNumber, "32Bits_HeadByNumber" );
    AssGVar( GVarName( "32Bits_HeadByNumber" ),
         NewFunctionC( "32Bits_HeadByNumber", 2L, "16_bits_word, gen_num",
                    Func32Bits_HeadByNumber ) );

    InitHandlerFunc( Func32Bits_Power, "32Bits_Power" );
    AssGVar( GVarName( "32Bits_Power" ),
         NewFunctionC( "32Bits_Power", 2L, "32_bits_word, small_integer",
                    Func32Bits_Power ) );

    InitHandlerFunc( Func32Bits_Product, "32Bits_Product" );
    AssGVar( GVarName( "32Bits_Product" ),
         NewFunctionC( "32Bits_Product", 2L, "32_bits_word, 32_bits_word",
                    Func32Bits_Product ) );

    InitHandlerFunc( Func32Bits_Quotient, "32Bits_Quotient" );
    AssGVar( GVarName( "32Bits_Quotient" ),
         NewFunctionC( "32Bits_Quotient", 2L, "32_bits_word, 32_bits_word",
                    Func32Bits_Quotient ) );
}


/****************************************************************************
**

*E  objfgelm.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
