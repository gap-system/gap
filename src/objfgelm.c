/****************************************************************************
**
*W  objfgelm.c                  GAP source                       Frank Celler
**
*
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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
**  <PURETYPE> is the type  of a result, <EBITS>  is the number of  bits used
**  for the exponent, <RANK> is number of free group generators.  But instead
**  of accessing these entries directly you should use the following macros.
**
**
**  The file "objects.h" defines the following macros:
**
**  NEW_WORD( <result>, <type>, <npairs> )
**    creates   a  new  objects   of   type  <type>  with  room  for <npairs>
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
**    returns the result type
**
**
**  BITS_WORDTYPE( <type> )
**    returns the number of bits as C integers
**
**  EBITS_WORDTYPE( <type> )
**    returns the ebits as C integer
**
**  RANK_WORDTYPE( <type> )
**    returns the rank as C integer
**
**  PURETYPE_WORDTYPE( <type> )
**    returns the result type
*/
#include <assert.h>                     /* assert */
#include <src/system.h>                 /* Ints, UInts */


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */
#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */
#include <src/ariths.h>                 /* arithmetic macros */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */

#include <src/bool.h>                   /* booleans */


#include <src/objfgelm.h>               /* objects of free groups */


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
    while ( !IS_POS_INTOBJ(vstart) )
        vstart = ErrorReturnObj( "<start> must be a positive integer", 0L, 0L,
                                 "you can replace <start> via 'return <start>;'" );
    start = INT_INTOBJ(vstart);

    /* <end> must be positive                                              */
    while ( !IS_POS_INTOBJ(vend) )
        vend = ErrorReturnObj( "<end> must be a positive integer", 0L, 0L,
                               "you can replace <end> via 'return <end>;'" );
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
        vi = ErrorReturnObj( "<i> must be an integer between 1 and %d", num, 0L,
                             "you can replace <i> via 'return <i>;'" );
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
    Obj         type;           /* type of <obj>                           */
    UInt1 *     ptr;            /* pointer into the data area of <obj>     */
    Obj         lst;            /* result                                  */

    /* get the type of <obj>                                               */
    type = TYPE_DATOBJ(obj);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(type);

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
        vi = ErrorReturnObj( "<i> must be an integer between 1 and %d", num, 0L,
                             "you can replace <i> via 'return <i>;'" );
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
**
**  This  function implements    a length-plus-lexicographic   ordering   on
**  associative words.  This ordering  is translation  invariant, therefore,
**  we can  skip common prefixes.  This  is done  in  the first loop  of the
**  function.  When  a difference in  the  two words  is  encountered, it is
**  decided which is the  lexicographically smaller.  There are several case
**  that can occur:
**
**  The syllables where the difference  occurs have different generators.  In
**  this case it is sufficient to compare the two generators.  
**  Example: x^3 < y^3.
**
**  The syllables have the same generator but one exponent is the negative of
**  the other.  In this case the word with  the negative exponent is smaller.
**  Example: x^-1 < x.
**
**  Now it suffices  to compare the  unsigned  exponents.  For the  syllable
**  with the smaller exponent we  have to take  the  next generator in  that
**  word into  account.   This  means that  we  are  discarding  the smaller
**  syllable  as a common prefix.  Note  that if this  happens at the end of
**  one of the two words, then this word (ignoring the common prefix) is the
**  empty word and we can immediately decide which word is the smaller.
**  Examples: y^3 x < y^2 z, y^3 x > y^2 x z,  x^2 < x y^-1,  x^2 < x^3.
**
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
    Obj         lexico;         /* lexicographic order of <l> and <r>      */
    Obj         ll;             /* length of <l>                           */
    Obj         lr;             /* length of <r>                           */

    /* if <l> or <r> is the identity it is easy                            */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( nl == 0 || nr == 0 ) {
        return ( nr != 0 ) ? True : False;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);
    
    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;
    
    /* Skip the common prefix and determine if the first word is smaller   */
    /* with respect to the lexicographic ordering.                         */
    pl = (UInt1*)DATA_WORD(l);
    pr = (UInt1*)DATA_WORD(r);
    for ( lexico = False;  0 < nl && 0 < nr;  nl--, nr--, pl++, pr++ )
        if ( *pl != *pr ) {
            /* got a difference                                            */

            /* get the generator mask                                      */
            genm = ((1UL << (8-ebits)) - 1) << ebits;

            /* compare the generators                                      */
            if ( (*pl & genm) != (*pr & genm) ) {
                lexico = ( (*pl & genm) < (*pr & genm) ) ? True : False;
                break;
            }

            /* get the unsigned exponents                                  */
            exl = (*pl & exps) ? (exps - (*pl & expm)) : (*pl & expm);
            exr = (*pr & exps) ? (exps - (*pr & expm)) : (*pr & expm);

            /* compare the sign of the exponents                           */
            if( exl == exr && (*pl & exps) != (*pr & exps) ) {
                lexico = (*pl & exps) ? True : False;
                break;
            }

            /* compare the exponents, and check the next generator.  This  */
            /* amounts to stripping off the common prefix  x^|expl-expr|.  */
            if( exl > exr ) {
                if( nr > 0 ) {
                  lexico = (*pl & genm) < (*(pr+1) & genm) ? True : False;
                  break;
                }
                else
                    /* <r> is now essentially the empty word.             */
                    return False;
            }
            if( nl > 0 ) {  /* exl < exr                                  */
                lexico = (*(pl+1) & genm) < (*pr & genm) ? True : False;
                break;
            }
            /* <l> is now essentially the empty word.                     */
            return True;
        }

    /* compute the lengths of the rest                                    */
    for ( ll = INTOBJ_INT(0);  0 < nl;  nl--,  pl++ ) {
        exl = (*pl & exps) ? (exps - (*pl & expm)) : (*pl & expm);
        C_SUM_FIA(ll,ll,INTOBJ_INT(exl));
    }
    for ( lr = INTOBJ_INT(0);  0 < nr;  nr--,  pr++ ) {
        exr = (*pr & exps) ? (exps - (*pr & expm)) : (*pr & expm);
        C_SUM_FIA(lr,lr,INTOBJ_INT(exr));
    }

    if( EQ( ll, lr ) ) return lexico;

    return LT( ll, lr ) ? True : False;
}


/****************************************************************************
**
*F  Func8Bits_AssocWord( <self>, <type>, <data> )
*/
Obj Func8Bits_AssocWord (
    Obj         self,
    Obj         type,
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
    ebits = EBITS_WORDTYPE(type);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* construct a new object                                              */
    num = LEN_LIST(data)/2;
    NEW_WORD( obj, type, num );

    /* use UInt1 pointer for eight bits                                    */
    ptr = (UInt1*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++ ) {

        /* this will not cause a garbage collection                        */
        vgen = ELMW_LIST( data, 2*i-1 );
        ngen = INT_INTOBJ(vgen);
        vexp = ELMW_LIST( data, 2*i );
        while ( ! IS_INTOBJ(vexp) || vexp == INTOBJ_INT(0) ) {
            vexp = ErrorReturnObj( "<exponent> must be a non-zero integer", 
                                   0L, 0L,
                                   "you can replace <exponent> via 'return <exponent>;'" );
        }
        nexp = INT_INTOBJ(vexp) & expm;
        *ptr = ((ngen-1) << ebits) | nexp;
        assert( ptr == (UInt1*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(obj);

    return obj;
}


/****************************************************************************
**
*F  Func8Bits_ObjByVector( <self>, <type>, <data> )
*/
Obj Func8Bits_ObjByVector (
    Obj         self,
    Obj         type,
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
    ebits = EBITS_WORDTYPE(type);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* count the number of non-zero entries                                */
    for ( i = LEN_LIST(data), num = 0, j = 1;  0 < i;  i-- ) {
        vexp = ELMW_LIST(data,i);
        while ( ! IS_INTOBJ(vexp) ) {
            vexp = ErrorReturnObj(
                "%d element must be a small integer (not a %s)",
                (Int) i, (Int) TNAM_OBJ(vexp),
                "you can replace the element by <val> via 'return <val>;'" );
        }
        if ( vexp != INTOBJ_INT(0) ) {
            j = i;
            num++;
        }
    }

    /* construct a new object                                              */
    NEW_WORD( obj, type, num );

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
*F  Func8Bits_LengthWord( <self>, <w> )
*/

Obj Func8Bits_LengthWord (
    Obj         self,
    Obj         w )
{
  UInt npairs,i,ebits,exps,expm;
  Obj len, uexp;
  UInt1 *data, pair;

  npairs = NPAIRS_WORD(w);
  ebits = EBITS_WORD(w);
  data = (UInt1*)DATA_WORD(w);
  
  /* get the exponent masks                                              */
  exps = 1UL << (ebits-1);
  expm = exps - 1;
  
  len = INTOBJ_INT(0);
  for (i = 0; i < npairs; i++)
    {
      pair = data[i];
      if (pair & exps)
        uexp = INTOBJ_INT(exps - (pair & expm));
      else
        uexp = INTOBJ_INT(pair & expm);
      C_SUM_FIA(len,len,uexp);
    }
  return len;
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
    while ( !IS_POS_INTOBJ(vstart) )
        vstart = ErrorReturnObj( "<start> must be a positive integer", 0L, 0L,
                                 "you can replace <start> via 'return <start>;'" );
    start = INT_INTOBJ(vstart);

    /* <end> must be positive                                              */
    while ( !IS_POS_INTOBJ(vend) )
        vend = ErrorReturnObj( "<end> must be a positive integer", 0L, 0L,
                               "you can replace <end> via 'return <end>;'" );
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
        vi = ErrorReturnObj( "<i> must be an integer between 1 and %d", num, 0L,
                             "you can replace <i> via 'return <i>;'" );
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
    Obj         type;           /* type of <obj>                           */
    UInt2 *     ptr;            /* pointer into the data area of <obj>     */
    Obj         lst;            /* result                                  */

    /* get the type of <obj>                                               */
    type = TYPE_DATOBJ(obj);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(type);

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

    /* this will not cause a garbage collection                            */
    for ( i = 1;  i <= num;  i++, ptr++ ) {
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
        vi = ErrorReturnObj( "<i> must be an integer between 1 and %d", num, 0L,
                             "you can replace <i> via 'return <i>;'" );
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
**
**  For an explanation of this function, see the comments before
**  Func8Bits_Less(). 
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
    Obj         lexico;         /* lexicographic order of <l> and <r>      */
    Obj         ll;             /* length of <l>                           */
    Obj         lr;             /* length of <r>                           */

    /* if <l> or <r> is the identity it is easy                            */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( nl == 0 || nr == 0 ) {
        return ( nr != 0 ) ? True : False;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);
    
    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;
    
    /* Skip the common prefix and determine if the first word is smaller   */
    /* with respect to the lexicographic ordering.                         */
    pl = (UInt2*)DATA_WORD(l);
    pr = (UInt2*)DATA_WORD(r);
    for ( lexico = False;  0 < nl && 0 < nr;  nl--, nr--, pl++, pr++ )
        if ( *pl != *pr ) {
            /* got a difference                                            */

            /* get the generator mask                                      */
            genm = ((1UL << (16-ebits)) - 1) << ebits;

            /* compare the generators                                      */
            if ( (*pl & genm) != (*pr & genm) ) {
                lexico = ( (*pl & genm) < (*pr & genm) ) ? True : False;
                break;
            }

            /* get the unsigned exponents                                  */
            exl = (*pl & exps) ? (exps - (*pl & expm)) : (*pl & expm);
            exr = (*pr & exps) ? (exps - (*pr & expm)) : (*pr & expm);

            /* compare the sign of the exponents                           */
            if( exl == exr && (*pl & exps) != (*pr & exps) ) {
                lexico = (*pl & exps) ? True : False;
                break;
            }

            /* compare the exponents, and check the next generator.  This  */
            /* amounts to stripping off the common prefix  x^|expl-expr|.  */
            if( exl > exr ) {
                if( nr > 0 ) {
                  lexico = (*pl & genm) < (*(pr+1) & genm) ? True : False;
                  break;
                }
                else
                    /* <r> is now essentially the empty word.             */
                    return False;
            }
            if( nl > 0 ) {  /* exl < exr                                  */
                lexico = (*(pl+1) & genm) < (*pr & genm) ? True : False;
                break;
            }
            /* <l> is now essentially the empty word.                     */
            return True;
        }

    /* compute the lengths of the rest                                    */
    for ( ll = INTOBJ_INT(0);  0 < nl;  nl--,  pl++ ) {
        exl = (*pl & exps) ? (exps - (*pl & expm)) : (*pl & expm);
        C_SUM_FIA(ll,ll,INTOBJ_INT(exl));
    }
    for ( lr = INTOBJ_INT(0);  0 < nr;  nr--,  pr++ ) {
        exr = (*pr & exps) ? (exps - (*pr & expm)) : (*pr & expm);
        C_SUM_FIA(lr,lr,INTOBJ_INT(exr));
    }

    if( EQ( ll, lr ) ) return lexico;

    return LT( ll, lr ) ? True : False;
}


/****************************************************************************
**
*F  Func16Bits_AssocWord( <self>, <type>, <data> )
*/
Obj Func16Bits_AssocWord (
    Obj         self,
    Obj         type,
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
    UInt2 *     ptr;            /* pointer into the data area of <obj>     */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(type);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* construct a new object                                              */
    num = LEN_LIST(data)/2;
    NEW_WORD( obj, type, num );

    /* use UInt2 pointer for sixteen bits                                  */
    ptr = (UInt2*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++ ) {

        /* this will not cause a garbage collection                        */
        vgen = ELMW_LIST( data, 2*i-1 );
        ngen = INT_INTOBJ(vgen);
        vexp = ELMW_LIST( data, 2*i );
        while ( ! IS_INTOBJ(vexp) || vexp == INTOBJ_INT(0) ) {
            vexp = ErrorReturnObj( "<exponent> must be a non-zero integer", 
                                   0L, 0L,
                                   "you can replace <exponent> via 'return <exponent>;'" );
        }
        nexp = INT_INTOBJ(vexp) & expm;
        *ptr = ((ngen-1) << ebits) | nexp;
        assert( ptr == (UInt2*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(obj);

    return obj;
}


/****************************************************************************
**
*F  Func16Bits_ObjByVector( <self>, <type>, <data> )
*/
Obj Func16Bits_ObjByVector (
    Obj         self,
    Obj         type,
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
    ebits = EBITS_WORDTYPE(type);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* count the number of non-zero entries                                */
    for ( i = LEN_LIST(data), num = 0, j = 1;  0 < i;  i-- ) {
        vexp = ELMW_LIST(data,i);
        while ( ! IS_INTOBJ(vexp) ) {
            vexp = ErrorReturnObj(
                "%d element must be a small integer (not a %s)",
                (Int) i, (Int) TNAM_OBJ(vexp),
                "you can replace the element by <val> via 'return <val>;'" );
        }
        if ( vexp != INTOBJ_INT(0) ) {
            j = i;
            num++;
        }
    }

    /* construct a new object                                              */
    NEW_WORD( obj, type, num );

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
    pl = (UInt2*)DATA_WORD(l)+(nl-1);
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
*F  Func16Bits_LengthWord( <self>, <w> )
*/

Obj Func16Bits_LengthWord (
    Obj         self,
    Obj         w )
{
  UInt npairs,i,ebits,exps,expm;
  Obj len, uexp;
  UInt2 *data, pair;
  
  npairs = NPAIRS_WORD(w);
  ebits = EBITS_WORD(w);
  data = (UInt2*)DATA_WORD(w);
  
  /* get the exponent masks                                              */
  exps = 1UL << (ebits-1);
  expm = exps - 1;
  
  len = INTOBJ_INT(0);
  for (i = 0; i < npairs; i++)
    {
      pair = data[i];
      if (pair & exps)
        uexp = INTOBJ_INT(exps - (pair & expm));
      else
        uexp = INTOBJ_INT(pair & expm);
      C_SUM_FIA(len,len,uexp);
    }
  return len;
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
    while ( !IS_POS_INTOBJ(vstart) )
        vstart = ErrorReturnObj( "<start> must be a positive integer", 0L, 0L,
                                 "you can replace <start> via 'return <start>;'" );
    start = INT_INTOBJ(vstart);

    /* <end> must be positive                                              */
    while ( !IS_POS_INTOBJ(vend) )
        vend = ErrorReturnObj( "<end> must be a positive integer", 0L, 0L,
                               "you can replace <end> via 'return <end>;'" );
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
        vi = ErrorReturnObj( "<i> must be an integer between 1 and %d", num, 0L,
                             "you can replace <i> via 'return <i>;'" );
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
    Obj         type;           /* type of <obj>                           */
    UInt4 *     ptr;            /* pointer into the data area of <obj>     */
    Obj         lst;            /* result                                  */

    /* get the type of <obj>                                               */
    type = TYPE_DATOBJ(obj);

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(type);

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

    /* this will not cause a garbage collection                            */
    for ( i = 1;  i <= num;  i++, ptr++ ) {
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
        vi = ErrorReturnObj( "<i> must be an integer between 1 and %d", num, 0L,
                             "you can replace <i> via 'return <i>;'" );
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
**
**  For an explanation of this function, see the comments before
**  Func8Bits_Less(). 
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
    Obj         lexico;         /* lexicographic order of <l> and <r>      */
    Obj         ll;             /* length of <l>                           */
    Obj         lr;             /* length of <r>                           */

    /* if <l> or <r> is the identity it is easy                            */
    nl = NPAIRS_WORD(l);
    nr = NPAIRS_WORD(r);
    if ( nl == 0 || nr == 0 ) {
        return ( nr != 0 ) ? True : False;
    }

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORD(l);
    
    /* get the exponent masks                                              */
    exps = 1UL << (ebits-1);
    expm = exps - 1;
    
    /* Skip the common prefix and determine if the first word is smaller   */
    /* with respect to the lexicographic ordering.                         */
    pl = (UInt4*)DATA_WORD(l);
    pr = (UInt4*)DATA_WORD(r);
    for ( lexico = False;  0 < nl && 0 < nr;  nl--, nr--, pl++, pr++ )
        if ( *pl != *pr ) {
            /* got a difference                                            */

            /* get the generator mask                                      */
            genm = ((1UL << (32-ebits)) - 1) << ebits;

            /* compare the generators                                      */
            if ( (*pl & genm) != (*pr & genm) ) {
                lexico = ( (*pl & genm) < (*pr & genm) ) ? True : False;
                break;
            }

            /* get the unsigned exponents                                  */
            exl = (*pl & exps) ? (exps - (*pl & expm)) : (*pl & expm);
            exr = (*pr & exps) ? (exps - (*pr & expm)) : (*pr & expm);

            /* compare the sign of the exponents                           */
            if( exl == exr && (*pl & exps) != (*pr & exps) ) {
                lexico = (*pl & exps) ? True : False;
                break;
            }

            /* compare the exponents, and check the next generator.  This  */
            /* amounts to stripping off the common prefix  x^|expl-expr|.  */
            if( exl > exr ) {
                if( nr > 0 ) {
                  lexico = (*pl & genm) < (*(pr+1) & genm) ? True : False;
                  break;
                }
                else
                    /* <r> is now essentially the empty word.             */
                    return False;
            }
            if( nl > 0 ) {  /* exl < exr                                  */
                lexico = (*(pl+1) & genm) < (*pr & genm) ? True : False;
                break;
            }
            /* <l> is now essentially the empty word.                     */
            return True;
        }

    /* compute the lengths of the rest                                    */
    for ( ll = INTOBJ_INT(0);  0 < nl;  nl--,  pl++ ) {
        exl = (*pl & exps) ? (exps - (*pl & expm)) : (*pl & expm);
        C_SUM_FIA(ll,ll,INTOBJ_INT(exl));
    }
    for ( lr = INTOBJ_INT(0);  0 < nr;  nr--,  pr++ ) {
        exr = (*pr & exps) ? (exps - (*pr & expm)) : (*pr & expm);
        C_SUM_FIA(lr,lr,INTOBJ_INT(exr));
    }

    if( EQ( ll, lr ) ) return lexico;

    return LT( ll, lr ) ? True : False;
}


/****************************************************************************
**
*F  Func32Bits_AssocWord( <self>, <type>, <data> )
*/
Obj Func32Bits_AssocWord (
    Obj         self,
    Obj         type,
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
    UInt4 *     ptr;            /* pointer into the data area of <obj>     */

    /* get the number of bits for exponents                                */
    ebits = EBITS_WORDTYPE(type);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* construct a new object                                              */
    num = LEN_LIST(data)/2;
    NEW_WORD( obj, type, num );

    /* use UInt4 pointer for thirty-two bits                               */
    ptr = (UInt4*)DATA_WORD(obj);
    for ( i = 1;  i <= num;  i++, ptr++ ) {

        /* this will not cause a garbage collection                        */
        vgen = ELMW_LIST( data, 2*i-1 );
        ngen = INT_INTOBJ(vgen);
        vexp = ELMW_LIST( data, 2*i );
        while ( ! IS_INTOBJ(vexp) || vexp == INTOBJ_INT(0) ) {
            vexp = ErrorReturnObj( "<exponent> must be a non-zero integer", 
                                   0L, 0L,
                                   "you can replace <exponent> via 'return <exponent>;'" );
        }
        nexp = INT_INTOBJ(vexp) & expm;
        *ptr = ((ngen-1) << ebits) | nexp;
        assert( ptr == (UInt4*)DATA_WORD(obj) + (i-1) );
    }
    CHANGED_BAG(obj);

    return obj;
}


/****************************************************************************
**
*F  Func32Bits_ObjByVector( <self>, <type>, <data> )
*/
Obj Func32Bits_ObjByVector (
    Obj         self,
    Obj         type,
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
    ebits = EBITS_WORDTYPE(type);

    /* get the exponent mask                                               */
    expm = (1UL << ebits) - 1;

    /* count the number of non-zero entries                                */
    for ( i = LEN_LIST(data), num = 0, j = 1;  0 < i;  i-- ) {
        vexp = ELMW_LIST(data,i);
        while ( ! IS_INTOBJ(vexp) ) {
            vexp = ErrorReturnObj(
                "%d element must be a small integer (not a %s)",
                (Int) i, (Int) TNAM_OBJ(vexp),
                "you can replace the element by <val> via 'return <val>;'" );
        }
        if ( vexp != INTOBJ_INT(0) ) {
            j = i;
            num++;
        }
    }

    /* construct a new object                                              */
    NEW_WORD( obj, type, num );

    /* use UInt4 pointer for thirty-two bits                               */
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
        Int exs = ex;   // save <ex> for overflow test
        ex  = (Int)((UInt)ex * (UInt)pow);

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
*F  Func32Bits_LengthWord( <self>, <w> )
*/

Obj Func32Bits_LengthWord (
    Obj         self,
    Obj         w )
{
  UInt npairs,i,ebits,exps,expm;
  Obj len, uexp;
  UInt4 *data, pair;
  
  npairs = NPAIRS_WORD(w);
  ebits = EBITS_WORD(w);
  data = (UInt4*)DATA_WORD(w);
  
  /* get the exponent masks                                              */
  exps = 1UL << (ebits-1);
  expm = exps - 1;
  
  len = INTOBJ_INT(0);
  for (i = 0; i < npairs; i++)
    {
      pair = data[i];
      if (pair & exps)
        uexp = INTOBJ_INT(exps - (pair & expm));
      else
        uexp = INTOBJ_INT(pair & expm);
      C_SUM_FIA(len,len,uexp);
    }
  return len;
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


/**************************************************************************
* letter rep arithmetic */
/**************************************************************************
*F  FuncMultWorLettrep( <self>, <a>,<b> ) */
Obj FuncMultWorLettrep (
    Obj         self,
    Obj         a,
    Obj         b)
{
  UInt l,m,i,j,newlen,as,bs,ae,be;
  Obj n;
  Obj *p;
  Obj *q;

  /* short check */
  while ( ! IS_PLIST(a) ) {
      a = ErrorReturnObj(
                "first argument must be plain list (not a %s)",
                (Int) TNAM_OBJ(a), 0L,
                "you can replace the element by <val> via 'return <val>;'" );
  }
  while ( ! IS_PLIST(b) ) {
      b = ErrorReturnObj(
                "second argument must be plain list (not a %s)",
                (Int) TNAM_OBJ(b), 0L, 
                "you can replace the element by <val> via 'return <val>;'" );
  }

  /* Find overlap */
  /* l:=Length(a); */
  l=LEN_PLIST(a);
  if (l==0) {
    return b; 
  }  
  /* m:=Length(b); */
  m=LEN_PLIST(b);
  if (m==0) {
    return a; 
  }  
  /* now we know both lists are length >0 */

  /* i:=l; */
  i=l;
  /* j:=1; */
  j=1;
  /* while i>=1 and j<=m and a[i]=-b[j] do */
  while ((i>=1)&&(j<=m)&& 
    (INT_INTOBJ(ELM_PLIST(a,i))==-INT_INTOBJ(ELM_PLIST(b,j)))) {
    /* i:=i-1; */
    i--;
    /* j:=j+1; */
    j++;
  /* od; */
  }
  /* if i=0 then */
  if (i==0) {
    /* if j>m then */
    if (j>m) {
      /* full cancellation */
      /* return false; */
      return False;
    }
    /* fi; */
    /* a:=b{[j..m]}; */
    as=1;
    ae=0;
    bs=j;
    be=m;
    newlen=m-j+1;
  }
  /* elif j>m then */
  else {
    if (j>m) {
    /* a:=a{[1..i]}; */
      as=1;
      ae=i;
      bs=1;
      be=0;
      newlen=i;
    }
    else {
  /* else */
    /* a:=Concatenation(a{[1..i]},b{[j..m]}); */
      as=1;
      ae=i;
      bs=j;
      be=m;
      newlen=m-j+1+i;
    }
  /* fi; */
  }
  /* make the new list */
  n=NEW_PLIST(T_PLIST_CYC,newlen);
  q=ADDR_OBJ(n);
  q++;
  j=as;
  /* a[as] position */
  /* there must be a better way for giving this address ... */
  p=(Obj*) &(ADDR_OBJ(a)[as]);
  while (j<=ae) {
    *q++=*p++;
    j++;
  }
  j=bs;
  /* b[bs] position */
  /* there must be a better way for giving this address ... */
  p=(Obj*) &(ADDR_OBJ(b)[bs]);
  while (j<=be) {
    *q++=*p++;
    j++;
  }
  SET_LEN_PLIST(n,newlen);
  CHANGED_BAG(n);
  /* return a; */
  return n;
}

/*F  FuncMultBytLettrep( <self>, <a>,<b> ) */
Obj FuncMultBytLettrep (
    Obj         self,
    Obj         a,
    Obj         b)
{
  UInt l,m,i,j,newlen,as,bs,ae,be;
  Obj n;
  UInt1 *p,*q;
  
  /* short check, if necessary strings are compacted */
  while ( ! IsStringConv(a) ) {
      a = ErrorReturnObj(
                "first argument must be string (not a %s)",
                (Int) TNAM_OBJ(a), 0L,
                "you can replace the element by <val> via 'return <val>;'" );
  }
  while ( ! IsStringConv(b) ) {
      b = ErrorReturnObj(
                "second argument must be string (not a %s)",
                (Int) TNAM_OBJ(b), 0L, 
                "you can replace the element by <val> via 'return <val>;'" );
  }
  
  /* Find overlap */
  /* l:=Length(a); */
  l=GET_LEN_STRING(a);
  if (l==0) {
    return b; 
  }  
  /* m:=Length(b); */
  m=GET_LEN_STRING(b);
  if (m==0) {
    return a; 
  }  
  /* now we know both lists are length >0 */

  /* i:=l; */
  i=l;
  /* j:=1; */
  j=1;
  /* while i>=1 and j<=m and a[i]=-b[j] do */
  p=CHARS_STRING(a);
  q=CHARS_STRING(b);
  while ((i>=1)&&(j<=m)&&
    (SINT_CHAR(p[i-1])==-SINT_CHAR(q[j-1]))) {
    /* i:=i-1; */
    i--;
    /* j:=j+1; */
    j++;
  /* od; */
  }
  /* if i=0 then */
  if (i==0) {
    /* if j>m then */
    if (j>m) {
      /* full cancellation */
      /* return false; */
      return False;
    }
    /* fi; */
    /* a:=b{[j..m]}; */
    as=1;
    ae=0;
    bs=j;
    be=m;
    newlen=m-j+1;
  }
  /* elif j>m then */
  else {
    if (j>m) {
    /* a:=a{[1..i]}; */
      as=1;
      ae=i;
      bs=1;
      be=0;
      newlen=i;
    }
    else {
  /* else */
    /* a:=Concatenation(a{[1..i]},b{[j..m]}); */
      as=1;
      ae=i;
      bs=j;
      be=m;
      newlen=m-j+1+i;
    }
  /* fi; */
  }
  /* make the new list */
  n=NEW_STRING(newlen);
  q=CHARS_STRING(n);
  p=CHARS_STRING(a);
  j=as;
  /* a[as] position */
  while (j<=ae) {
    *q++=p[j-1];
    j++;
  }
  j=bs;
  p=CHARS_STRING(b);
  /* b[bs] position */
  while (j<=be) {
    *q++=p[j-1];
    j++;
  }
  /* return a; */
  CHANGED_BAG(n);
  return n;
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

    GVAR_FUNC(8Bits_Equal, 2, "8_bits_word, 8_bits_word"),
    GVAR_FUNC(8Bits_ExponentSums1, 1, "8_bits_word"),
    GVAR_FUNC(8Bits_ExponentSums3, 3, "8_bits_word, start, end"),
    GVAR_FUNC(8Bits_ExponentSyllable, 2, "8_bits_word, position"),
    GVAR_FUNC(8Bits_ExtRepOfObj, 1, "8_bits_word"),
    GVAR_FUNC(8Bits_GeneratorSyllable, 2, "8_bits_word, position"),
    GVAR_FUNC(8Bits_Less, 2, "8_bits_word, 8_bits_word"),
    GVAR_FUNC(8Bits_AssocWord, 2, "type, data"),
    { "8Bits_NumberSyllables", 1, "8_bits_word",
      FuncNBits_NumberSyllables, "src/objfgelm.c:8Bits_NumberSyllables" },

    GVAR_FUNC(8Bits_ObjByVector, 2, "type, data"),
    GVAR_FUNC(8Bits_HeadByNumber, 2, "16_bits_word, gen_num"),
    GVAR_FUNC(8Bits_Power, 2, "8_bits_word, small_integer"),
    GVAR_FUNC(8Bits_Product, 2, "8_bits_word, 8_bits_word"),
    GVAR_FUNC(8Bits_Quotient, 2, "8_bits_word, 8_bits_word"),
    GVAR_FUNC(8Bits_LengthWord, 1, "8_bits_word"),
    GVAR_FUNC(16Bits_Equal, 2, "16_bits_word, 16_bits_word"),
    GVAR_FUNC(16Bits_ExponentSums1, 1, "16_bits_word"),
    GVAR_FUNC(16Bits_ExponentSums3, 3, "16_bits_word, start, end"),
    GVAR_FUNC(16Bits_ExponentSyllable, 2, "16_bits_word, position"),
    GVAR_FUNC(16Bits_ExtRepOfObj, 1, "16_bits_word"),
    GVAR_FUNC(16Bits_GeneratorSyllable, 2, "16_bits_word, pos"),
    GVAR_FUNC(16Bits_Less, 2, "16_bits_word, 16_bits_word"),
    GVAR_FUNC(16Bits_AssocWord, 2, "type, data"),
    { "16Bits_NumberSyllables", 1, "16_bits_word",
      FuncNBits_NumberSyllables, "src/objfgelm.c:16Bits_NumberSyllables" },

    GVAR_FUNC(16Bits_ObjByVector, 2, "type, data"),
    GVAR_FUNC(16Bits_HeadByNumber, 2, "16_bits_word, gen_num"),
    GVAR_FUNC(16Bits_Power, 2, "16_bits_word, small_integer"),
    GVAR_FUNC(16Bits_Product, 2, "16_bits_word, 16_bits_word"),
    GVAR_FUNC(16Bits_Quotient, 2, "16_bits_word, 16_bits_word"),
    GVAR_FUNC(16Bits_LengthWord, 1, "16_bits_word"),
    GVAR_FUNC(32Bits_Equal, 2, "32_bits_word, 32_bits_word"),
    GVAR_FUNC(32Bits_ExponentSums1, 1, "32_bits_word"),
    GVAR_FUNC(32Bits_ExponentSums3, 3, "32_bits_word, start, end"),
    GVAR_FUNC(32Bits_ExponentSyllable, 2, "32_bits_word, position"),
    GVAR_FUNC(32Bits_ExtRepOfObj, 1, "32_bits_word"),
    GVAR_FUNC(32Bits_GeneratorSyllable, 2, "32_bits_word, pos"),
    GVAR_FUNC(32Bits_Less, 2, "32_bits_word, 32_bits_word"),
    GVAR_FUNC(32Bits_AssocWord, 2, "type, data"),
    { "32Bits_NumberSyllables", 1, "32_bits_word",
      FuncNBits_NumberSyllables, "src/objfgelm.c:32Bits_NumberSyllables" },

    GVAR_FUNC(32Bits_ObjByVector, 2, "type, data"),
    GVAR_FUNC(32Bits_HeadByNumber, 2, "16_bits_word, gen_num"),
    GVAR_FUNC(32Bits_Power, 2, "32_bits_word, small_integer"),
    GVAR_FUNC(32Bits_Product, 2, "32_bits_word, 32_bits_word"),
    GVAR_FUNC(32Bits_Quotient, 2, "32_bits_word, 32_bits_word"),
    GVAR_FUNC(32Bits_LengthWord, 1, "32_bits_word"),
    { "MULT_WOR_LETTREP", 2, "list,list",
      FuncMultWorLettrep, "src/objfgelm.c:MULT_WOR_LETTREP" },

    { "MULT_BYT_LETTREP", 2, "string,string",
      FuncMultBytLettrep, "src/objfgelm.c:MULT_BYT_LETTREP" },

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
    /* export position numbers 'AWP_SOMETHING'                             */
    ExportAsConstantGVar(AWP_FIRST_ENTRY);
    ExportAsConstantGVar(AWP_PURE_TYPE);
    ExportAsConstantGVar(AWP_NR_BITS_EXP);
    ExportAsConstantGVar(AWP_NR_GENS);
    ExportAsConstantGVar(AWP_NR_BITS_PAIR);
    ExportAsConstantGVar(AWP_FUN_OBJ_BY_VECTOR);
    ExportAsConstantGVar(AWP_FUN_ASSOC_WORD);
    ExportAsConstantGVar(AWP_FIRST_FREE);

    /* init filters and functions                                          */
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoFreeGroupElements() . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "objfgelm",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoFreeGroupElements ( void )
{
    return &module;
}
